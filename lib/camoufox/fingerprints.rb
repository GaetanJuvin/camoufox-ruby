# frozen_string_literal: true

require "json"

module Camoufox
  module Fingerprints
    FONT_DATA = JSON.parse(File.read(File.join(__dir__, "fonts.json"))).freeze

    SCREENS = [
      { width: 1920, height: 1080 },
      { width: 2560, height: 1440 },
      { width: 1512, height: 982 },
      { width: 1440, height: 900 },
      { width: 1680, height: 1050 },
      { width: 1280, height: 800 }
    ].freeze

    HARDWARE_CONCURRENCIES = [4, 8, 10, 12, 16].freeze

    APPLE_GPUS = [
      "Apple M1", "Apple M1 Pro", "Apple M1 Max", "Apple M1 Ultra",
      "Apple M2", "Apple M2 Pro", "Apple M2 Max", "Apple M2 Ultra",
      "Apple M3", "Apple M3 Pro", "Apple M3 Max",
      "Apple M4", "Apple M4 Pro", "Apple M4 Max"
    ].freeze

    WINDOWS_GPUS = [
      { vendor: "Google Inc. (Intel)", renderer: "ANGLE (Intel, Intel(R) UHD Graphics 630, D3D11)" },
      { vendor: "Google Inc. (Intel)", renderer: "ANGLE (Intel, Intel(R) UHD Graphics 770, D3D11)" },
      { vendor: "Google Inc. (Intel)", renderer: "ANGLE (Intel, Intel(R) Iris(R) Xe Graphics, D3D11)" },
      { vendor: "Google Inc. (NVIDIA)", renderer: "ANGLE (NVIDIA, NVIDIA GeForce GTX 1060, D3D11)" },
      { vendor: "Google Inc. (NVIDIA)", renderer: "ANGLE (NVIDIA, NVIDIA GeForce GTX 1650, D3D11)" },
      { vendor: "Google Inc. (NVIDIA)", renderer: "ANGLE (NVIDIA, NVIDIA GeForce GTX 1660 Ti, D3D11)" },
      { vendor: "Google Inc. (NVIDIA)", renderer: "ANGLE (NVIDIA, NVIDIA GeForce RTX 2060, D3D11)" },
      { vendor: "Google Inc. (NVIDIA)", renderer: "ANGLE (NVIDIA, NVIDIA GeForce RTX 2070, D3D11)" },
      { vendor: "Google Inc. (NVIDIA)", renderer: "ANGLE (NVIDIA, NVIDIA GeForce RTX 3060, D3D11)" },
      { vendor: "Google Inc. (NVIDIA)", renderer: "ANGLE (NVIDIA, NVIDIA GeForce RTX 3070, D3D11)" },
      { vendor: "Google Inc. (NVIDIA)", renderer: "ANGLE (NVIDIA, NVIDIA GeForce RTX 3080, D3D11)" },
      { vendor: "Google Inc. (NVIDIA)", renderer: "ANGLE (NVIDIA, NVIDIA GeForce RTX 4060, D3D11)" },
      { vendor: "Google Inc. (NVIDIA)", renderer: "ANGLE (NVIDIA, NVIDIA GeForce RTX 4070, D3D11)" },
      { vendor: "Google Inc. (NVIDIA)", renderer: "ANGLE (NVIDIA, NVIDIA GeForce RTX 4080, D3D11)" },
      { vendor: "Google Inc. (NVIDIA)", renderer: "ANGLE (NVIDIA, NVIDIA GeForce RTX 4090, D3D11)" },
      { vendor: "Google Inc. (AMD)", renderer: "ANGLE (AMD, AMD Radeon RX 580, D3D11)" },
      { vendor: "Google Inc. (AMD)", renderer: "ANGLE (AMD, AMD Radeon RX 6600 XT, D3D11)" },
      { vendor: "Google Inc. (AMD)", renderer: "ANGLE (AMD, AMD Radeon RX 6700 XT, D3D11)" },
      { vendor: "Google Inc. (AMD)", renderer: "ANGLE (AMD, AMD Radeon RX 7800 XT, D3D11)" },
      { vendor: "Google Inc. (AMD)", renderer: "ANGLE (AMD, AMD Radeon RX 7900 XTX, D3D11)" },
    ].freeze

    LINUX_GPUS = [
      { vendor: "Intel", renderer: "Mesa Intel(R) UHD Graphics 630 (CFL GT2)" },
      { vendor: "Intel", renderer: "Mesa Intel(R) UHD Graphics 770 (ADL-S GT1)" },
      { vendor: "Intel", renderer: "Mesa Intel(R) Xe Graphics (TGL GT2)" },
      { vendor: "NVIDIA Corporation", renderer: "NVIDIA GeForce GTX 1060/PCIe/SSE2" },
      { vendor: "NVIDIA Corporation", renderer: "NVIDIA GeForce GTX 1650/PCIe/SSE2" },
      { vendor: "NVIDIA Corporation", renderer: "NVIDIA GeForce RTX 3060/PCIe/SSE2" },
      { vendor: "NVIDIA Corporation", renderer: "NVIDIA GeForce RTX 3070/PCIe/SSE2" },
      { vendor: "NVIDIA Corporation", renderer: "NVIDIA GeForce RTX 4070/PCIe/SSE2" },
      { vendor: "X.Org", renderer: "AMD Radeon RX 580 (polaris10, LLVM 15.0.7, DRM 3.49, 6.1.0)" },
      { vendor: "X.Org", renderer: "AMD Radeon RX 6700 XT (navi22, LLVM 15.0.7, DRM 3.49, 6.1.0)" },
    ].freeze

    WEBGL_EXTENSIONS = %w[
      ANGLE_instanced_arrays EXT_blend_minmax EXT_color_buffer_half_float
      EXT_float_blend EXT_frag_depth EXT_shader_texture_lod EXT_sRGB
      EXT_texture_compression_bptc EXT_texture_compression_rgtc
      EXT_texture_filter_anisotropic OES_element_index_uint
      OES_fbo_render_mipmap OES_standard_derivatives OES_texture_float
      OES_texture_float_linear OES_texture_half_float
      OES_texture_half_float_linear OES_vertex_array_object
      WEBGL_color_buffer_float WEBGL_compressed_texture_astc
      WEBGL_compressed_texture_etc WEBGL_compressed_texture_s3tc
      WEBGL_compressed_texture_s3tc_srgb WEBGL_debug_renderer_info
      WEBGL_debug_shaders WEBGL_depth_texture WEBGL_draw_buffers
      WEBGL_lose_context WEBGL_provoking_vertex
    ].freeze

    WEBGL2_EXTENSIONS = %w[
      EXT_color_buffer_float EXT_color_buffer_half_float EXT_float_blend
      EXT_texture_compression_bptc EXT_texture_compression_rgtc
      EXT_texture_filter_anisotropic EXT_texture_norm16
      OES_draw_buffers_indexed OES_texture_float_linear
      WEBGL_compressed_texture_astc WEBGL_compressed_texture_etc
      WEBGL_compressed_texture_s3tc WEBGL_compressed_texture_s3tc_srgb
      WEBGL_debug_renderer_info WEBGL_debug_shaders WEBGL_lose_context
      WEBGL_provoking_vertex
    ].freeze

    OS_PROFILES = {
      macos: {
        ua_part: "Macintosh; Intel Mac OS X 10.15",
        app_version: "5.0 (Macintosh)",
        platform: "MacIntel",
        oscpu: "Intel Mac OS X 10.15",
        menubar_height: 25,
      },
      windows: {
        ua_part: "Windows NT 10.0; Win64; x64",
        app_version: "5.0 (Windows)",
        platform: "Win32",
        oscpu: "Windows NT 10.0; Win64; x64",
        menubar_height: 0,
      },
      linux: {
        ua_part: "X11; Linux x86_64",
        app_version: "5.0 (X11)",
        platform: "Linux x86_64",
        oscpu: "Linux x86_64",
        menubar_height: 0,
      },
    }.freeze

    module_function

    def detect_os
      case RbConfig::CONFIG["host_os"]
      when /darwin/i then :macos
      when /linux/i then :linux
      when /mingw|mswin|cygwin/i then :windows
      else :macos
      end
    end

    def filter_screens(screens, constraints)
      return screens unless constraints.is_a?(Hash)

      screens.select do |s|
        next false if constraints[:min_width] && s[:width] < constraints[:min_width]
        next false if constraints[:max_width] && s[:width] > constraints[:max_width]
        next false if constraints[:min_height] && s[:height] < constraints[:min_height]
        next false if constraints[:max_height] && s[:height] > constraints[:max_height]

        true
      end
    end

    def gpu_for_os(target_os)
      case target_os
      when :macos
        gpu = APPLE_GPUS.sample
        { vendor: "Apple", renderer: gpu }
      when :windows
        WINDOWS_GPUS.sample
      when :linux
        LINUX_GPUS.sample
      else
        gpu = APPLE_GPUS.sample
        { vendor: "Apple", renderer: gpu }
      end
    end

    def fonts_for_os(target_os)
      key = case target_os
            when :macos then "mac"
            when :windows then "win"
            when :linux then "lin"
            else "mac"
            end
      FONT_DATA.fetch(key, FONT_DATA["mac"])
    end

    def generate(options = {})
      target_os = options[:os] || detect_os
      target_os = target_os.to_sym if target_os.is_a?(String)
      profile = OS_PROFILES.fetch(target_os, OS_PROFILES[:macos])

      ff_version = options[:ff_version] || firefox_version

      available_screens = filter_screens(SCREENS, options[:screen])
      available_screens = SCREENS if available_screens.empty?
      screen = available_screens.sample

      cores = HARDWARE_CONCURRENCIES.sample
      dpr = target_os == :macos ? [1.0, 2.0].sample : [1.0, 1.25, 1.5, 2.0].sample
      color_depth = [24, 30].sample
      gpu_info = gpu_for_os(target_os)

      menubar_height = profile[:menubar_height]
      toolbar_height = rand(72..88)
      screen_w = screen[:width]
      screen_h = screen[:height]
      avail_w = screen_w
      avail_h = screen_h - menubar_height

      if options[:window].is_a?(Array) && options[:window].length == 2
        outer_w = options[:window][0]
        outer_h = options[:window][1]
      else
        outer_w = avail_w - rand(0..100)
        outer_h = avail_h - rand(0..50)
      end

      inner_w = outer_w
      inner_h = outer_h - toolbar_height
      screen_x = rand(0..100)
      screen_y = rand(menubar_height..menubar_height + 50)

      charging = [true, false].sample
      battery_level = (rand(20..100) / 100.0).round(2)
      discharging_time = charging ? 0.0 : rand(1800..36000).to_f

      sample_rate = [44100, 48000].sample
      output_latency = (rand(1..15) / 1000.0).round(6)

      language = options.fetch("locale:language", options.fetch(:locale, "en-US"))
      language = language.first if language.is_a?(Array)
      region = options.fetch("locale:region", language.split("-").last)

      ua_string = "Mozilla/5.0 (#{profile[:ua_part]}; rv:#{ff_version}.0) Gecko/20100101 Firefox/#{ff_version}.0"

      fonts = fonts_for_os(target_os)

      config = {
        # Navigator
        "navigator.userAgent" => ua_string,
        "navigator.appVersion" => profile[:app_version],
        "navigator.platform" => profile[:platform],
        "navigator.oscpu" => profile[:oscpu],
        "navigator.hardwareConcurrency" => cores,
        "navigator.language" => language,
        "navigator.languages" => [language, language.split("-").first].uniq,
        "navigator.product" => "Gecko",
        "navigator.productSub" => "20100101",
        "navigator.appCodeName" => "Mozilla",
        "navigator.appName" => "Netscape",
        "navigator.buildID" => "20181001000000",
        "navigator.doNotTrack" => "unspecified",
        "navigator.maxTouchPoints" => 0,
        "navigator.cookieEnabled" => true,
        "navigator.globalPrivacyControl" => false,
        "navigator.onLine" => true,

        # Screen
        "screen.width" => screen_w,
        "screen.height" => screen_h,
        "screen.availWidth" => avail_w,
        "screen.availHeight" => avail_h,
        "screen.availTop" => menubar_height,
        "screen.availLeft" => 0,
        "screen.colorDepth" => color_depth,
        "screen.pixelDepth" => color_depth,
        "screen.pageXOffset" => 0.0,
        "screen.pageYOffset" => 0.0,

        # Window
        "window.outerWidth" => outer_w,
        "window.outerHeight" => outer_h,
        "window.innerWidth" => inner_w,
        "window.innerHeight" => inner_h,
        "window.screenX" => screen_x,
        "window.screenY" => screen_y,
        "window.scrollMinX" => 0,
        "window.scrollMinY" => 0,
        "window.scrollMaxX" => 0,
        "window.scrollMaxY" => 0,
        "window.history.length" => rand(1..5),
        "window.devicePixelRatio" => dpr,

        # Document body
        "document.body.clientWidth" => inner_w,
        "document.body.clientHeight" => inner_h,
        "document.body.clientTop" => 0,
        "document.body.clientLeft" => 0,

        # Headers
        "headers.User-Agent" => ua_string,
        "headers.Accept-Language" => "#{language},#{language.split('-').first};q=0.9",

        # WebGL
        "webGl:vendor" => gpu_info[:vendor],
        "webGl:renderer" => gpu_info[:renderer],
        "webGl:supportedExtensions" => WEBGL_EXTENSIONS,
        "webGl2:supportedExtensions" => WEBGL2_EXTENSIONS,

        # Canvas
        "canvas:aaOffset" => rand(-50..50),
        "canvas:aaCapOffset" => true,

        # Battery
        "battery:charging" => charging,
        "battery:chargingTime" => charging ? 0.0 : 0.0,
        "battery:dischargingTime" => discharging_time,
        "battery:level" => battery_level,

        # Audio
        "AudioContext:sampleRate" => sample_rate,
        "AudioContext:outputLatency" => output_latency,
        "AudioContext:maxChannelCount" => 2,

        # Fonts
        "fonts" => fonts,
        "fonts:spacing_seed" => rand(1..1000),

        # Locale
        "locale:language" => language,
        "locale:region" => region,
        "locale:script" => "",
        "locale:all" => language,

        # Media devices
        "mediaDevices:micros" => 1,
        "mediaDevices:webcams" => 1,
        "mediaDevices:speakers" => 1,
        "mediaDevices:enabled" => true,

        # Misc
        "pdfViewerEnabled" => true
      }

      # Allow user overrides
      options.each do |key, value|
        config[key.to_s] = value if config.key?(key.to_s)
      end

      config
    end

    def firefox_version
      version_file = File.join(Pkgman.cache_dir, "version.json")
      if File.exist?(version_file)
        data = JSON.parse(File.read(version_file))
        if (ver = data["version"])
          match = ver.match(/(\d+)/)
          return match[1] if match
        end
      end
      "135"
    end

  end
end
