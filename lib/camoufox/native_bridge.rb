# frozen_string_literal: true

require "json"

module Camoufox
  module NativeBridge
    CACHE_PREFS = {
      "browser.cache.disk.enable" => true,
      "browser.cache.memory.enable" => true,
      "browser.cache.offline.enable" => true,
      "network.http.use-cache" => true,
    }.freeze

    CHUNK_SIZE = 32_767

    module_function

    def ensure_loaded!
      return if defined?(@loaded) && @loaded

      require 'camoufox_native'
      @loaded = true
    rescue LoadError => e
      raise MissingNativeExtension, "camoufox_native extension is not available: #{e.message}"
    end

    def resolve_executable_path(explicit_path = nil)
      return explicit_path if explicit_path

      # Check env var
      env_path = ENV["CAMOUFOX_EXECUTABLE_PATH"]
      return env_path if env_path && !env_path.empty?

      # Auto-install if needed, then return the installed path
      Pkgman.ensure_installed!
      Pkgman.executable_path
    end

    def launch_options(
      config: {},
      proxy: nil,
      block_images: false,
      block_webrtc: false,
      block_webgl: false,
      disable_coop: false,
      geoip: nil,
      locale: nil,
      addons: [],
      fonts: nil,
      screen: nil,
      window: nil,
      headless: false,
      firefox_user_prefs: {},
      enable_cache: false,
      args: [],
      env: {},
      debug: false,
      executable_path: nil,
      user_data_dir: nil,
      ff_version: nil,
      os: nil,
      **extra_launch_options
    )
      # 1. Resolve executable path
      resolved_executable = resolve_executable_path(executable_path)

      # 2. Generate fingerprint config
      fp_options = {}
      fp_options[:os] = os if os
      fp_options[:screen] = screen if screen
      fp_options[:window] = window if window
      fp_options[:locale] = locale if locale
      fp_options[:ff_version] = ff_version if ff_version

      fp_config = Fingerprints.generate(fp_options)

      # 3. Merge user config on top (user overrides win)
      config.each do |key, value|
        fp_config[key.to_s] = value
      end

      # 4. Handle locale
      if locale
        Locale.handle(locale, fp_config)
      end

      # 5. Handle fonts
      if fonts
        existing_fonts = fp_config["fonts"] || []
        fp_config["fonts"] = (existing_fonts + Array(fonts)).uniq
      end

      # 6. Handle addons
      unless Array(addons).empty?
        resolved_addons = Addons.resolve(addons)
        fp_config["addons"] = resolved_addons unless resolved_addons.empty?
      end

      # 7. Handle geoip
      if geoip
        apply_geoip!(geoip, fp_config, proxy: proxy)
      end

      # 8. Warn about proxy without geoip
      Warnings.check_proxy_leak(proxy: proxy, geoip: geoip)

      # 9. Validate config
      ConfigValidator.validate!(fp_config)

      # 10. Debug output
      Warnings.debug_config(fp_config, enabled: debug)

      # 11. Build Firefox user prefs
      prefs = build_firefox_prefs(
        firefox_user_prefs: firefox_user_prefs,
        block_webrtc: block_webrtc,
        block_webgl: block_webgl,
        block_images: block_images,
        disable_coop: disable_coop,
        enable_cache: enable_cache,
      )

      # 12. Chunk config into env vars
      config_env = chunk_config(fp_config)
      merged_env = env.transform_keys(&:to_s).merge(config_env)

      # 13. Build final options hash
      options = {
        executable_path: resolved_executable,
        headless: headless,
        args: Array(args),
        env: merged_env,
      }

      options[:user_data_dir] = user_data_dir if user_data_dir
      options[:firefox_user_prefs] = prefs unless prefs.empty?

      # 14. Handle proxy
      if proxy
        options[:proxy] = normalize_proxy(proxy)
      end

      # 15. Merge extra launch options
      extra_launch_options.each do |key, value|
        options[key] = value
      end

      options
    end

    def run_cli(command, args = [])
      ensure_loaded!
      CamoufoxNative.run_cli(command.to_s)
    end

    def available?
      ensure_loaded!
      true
    rescue MissingNativeExtension
      false
    end

    # Private helpers

    def chunk_config(config_hash)
      json = JSON.generate(config_hash)
      chunks = {}
      (0...json.bytesize).step(CHUNK_SIZE).each_with_index do |offset, i|
        chunks["CAMOU_CONFIG_#{i + 1}"] = json.byteslice(offset, CHUNK_SIZE)
      end
      chunks
    end

    def build_firefox_prefs(firefox_user_prefs:, block_webrtc:, block_webgl:, block_images:, disable_coop:, enable_cache:)
      prefs = firefox_user_prefs.dup
      prefs["media.peerconnection.enabled"] = false if block_webrtc
      prefs["webgl.disabled"] = true if block_webgl
      prefs["permissions.default.image"] = 2 if block_images
      prefs["browser.tabs.remote.useCrossOriginOpenerPolicy"] = false if disable_coop
      prefs.merge!(CACHE_PREFS) if enable_cache
      prefs
    end

    def normalize_proxy(proxy)
      case proxy
      when Hash
        normalized = { server: proxy[:server] || proxy["server"] }
        username = proxy[:username] || proxy["username"]
        password = proxy[:password] || proxy["password"]
        bypass = proxy[:bypass] || proxy["bypass"]
        normalized[:username] = username if username
        normalized[:password] = password if password
        normalized[:bypass] = bypass if bypass
        normalized
      when String
        { server: proxy }
      else
        proxy
      end
    end

    def apply_geoip!(geoip, config, proxy: nil)
      ip = case geoip
           when true
             IP.public_ip(proxy: proxy)
           when String
             geoip
           else
             return
           end

      # Set WebRTC IP protection
      if IP.ipv4?(ip)
        config["webrtc:ipv4"] = ip
        config["network.dns.disableIPv6"] = true
      elsif IP.ipv6?(ip)
        config["webrtc:ipv6"] = ip
      end

      # Geolocate for timezone and location
      begin
        geo = IP.geolocate(ip)
        config["geolocation:latitude"] = geo[:latitude] if geo[:latitude]
        config["geolocation:longitude"] = geo[:longitude] if geo[:longitude]
        config["timezone"] = geo[:timezone] if geo[:timezone]

        # Set locale from country if not already specified
        unless config.key?("locale:language") && config["locale:language"] != "en-US"
          country_locale = Locale.from_country(geo[:country])
          Locale.handle(country_locale, config)
        end
      rescue GeoIPError => e
        Kernel.warn("[camoufox] GeoIP lookup failed: #{e.message}")
      end
    end
  end
end
