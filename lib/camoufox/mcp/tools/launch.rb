# frozen_string_literal: true

module Camoufox
  module MCP
    module Tools
      class Launch < ::MCP::Tool
        tool_name "camoufox_launch"
        description "Launch a stealth Camoufox browser session with anti-detection features"

        input_schema(
          properties: {
            headless: {
              type: "boolean",
              description: "Run the browser without a visible window",
            },
            user_data_dir: {
              type: "string",
              description: "Path to a user data directory for persistent browser profiles",
            },
            proxy_server: {
              type: "string",
              description: "Proxy server URL (e.g. http://proxy:8080 or socks5://proxy:1080)",
            },
            proxy_username: {
              type: "string",
              description: "Proxy authentication username",
            },
            proxy_password: {
              type: "string",
              description: "Proxy authentication password",
            },
            block_images: {
              type: "boolean",
              description: "Block all images from loading",
            },
            block_webrtc: {
              type: "boolean",
              description: "Disable WebRTC entirely to prevent IP leaks",
            },
            block_webgl: {
              type: "boolean",
              description: "Disable WebGL to prevent GPU fingerprinting",
            },
            locale: {
              type: "string",
              description: "Browser locale (e.g. en-US, fr-FR)",
            },
            os: {
              type: "string",
              description: "Target OS for fingerprint (macos, windows, linux)",
            },
            geoip: {
              type: "string",
              description: "IP address for geolocation matching, or 'auto' to detect",
            },
            enable_cache: {
              type: "boolean",
              description: "Enable browser disk and memory cache",
            },
            disable_coop: {
              type: "boolean",
              description: "Disable Cross-Origin-Opener-Policy",
            },
          },
        )

        class << self
          def call(server_context:, **kwargs)
            session = server_context[:session]
            opts = {}
            opts[:headless] = kwargs[:headless] unless kwargs[:headless].nil?
            opts[:user_data_dir] = kwargs[:user_data_dir] if kwargs[:user_data_dir]
            opts[:block_images] = kwargs[:block_images] if kwargs[:block_images]
            opts[:block_webrtc] = kwargs[:block_webrtc] if kwargs[:block_webrtc]
            opts[:block_webgl] = kwargs[:block_webgl] if kwargs[:block_webgl]
            opts[:locale] = kwargs[:locale] if kwargs[:locale]
            opts[:enable_cache] = kwargs[:enable_cache] if kwargs[:enable_cache]
            opts[:disable_coop] = kwargs[:disable_coop] if kwargs[:disable_coop]
            opts[:os] = kwargs[:os].to_sym if kwargs[:os]

            if kwargs[:geoip]
              opts[:geoip] = kwargs[:geoip] == "auto" ? true : kwargs[:geoip]
            end

            if kwargs[:proxy_server]
              proxy = { server: kwargs[:proxy_server] }
              proxy[:username] = kwargs[:proxy_username] if kwargs[:proxy_username]
              proxy[:password] = kwargs[:proxy_password] if kwargs[:proxy_password]
              opts[:proxy] = proxy
            end

            session.launch(**opts)

            features = []
            features << "headless" if opts[:headless]
            features << "proxy" if opts[:proxy]
            features << "webrtc blocked" if opts[:block_webrtc]
            features << "images blocked" if opts[:block_images]
            features << "webgl blocked" if opts[:block_webgl]
            features << "locale=#{opts[:locale]}" if opts[:locale]
            features << "os=#{opts[:os]}" if opts[:os]

            detail = features.empty? ? "" : " (#{features.join(', ')})"

            ::MCP::Tool::Response.new([{
              type: "text",
              text: "Browser launched successfully#{detail}.",
            }])
          end
        end
      end
    end
  end
end
