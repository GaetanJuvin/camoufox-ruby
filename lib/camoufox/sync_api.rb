# frozen_string_literal: true

require "json"
require "base64"
require "open3"

module Camoufox
  module SyncAPI
    class Camoufox
      def self.open(**kwargs)
        browser = new(**kwargs)
        return browser unless block_given?

        begin
          yield browser
        ensure
          browser.close
        end
      end

      def initialize(**kwargs)
        @launch_options = Utils.launch_options(**kwargs).to_h
      end

      def new_page
        Page.new(@launch_options)
      end

      def close
        # Nothing to cleanup yet – placeholder for future native resources.
        nil
      end
    end

    class Page
      attr_reader :title, :content

      def initialize(launch_options)
        @launch_options = launch_options
        @title = nil
        @content = nil
      end

      def goto(url)
        result = NodeRunner.visit(@launch_options, url)
        @title = result['title']
        @content = result['content']&.to_s
        self
      end
    end

    module NodeRunner
      module_function

      def visit(launch_options, url)
        node_path = ::Camoufox.configuration.node_path || 'node'
        script_path = File.expand_path('visit.js', __dir__)

        payload = Base64.strict_encode64(
          JSON.generate(
            options: Utils.camelize_hash(launch_options),
            url: url,
          ),
        )

        env = {}
        if (driver_dir = ::Camoufox.configuration.playwright_driver_dir)
          env['NODE_PATH'] = [driver_dir, ENV['NODE_PATH']].compact.join(File::PATH_SEPARATOR)
          env['CAMOUFOX_PLAYWRIGHT_DRIVER_DIR'] = driver_dir
        end

        stdout, stderr, status = Open3.capture3(env, node_path, script_path, stdin_data: payload)

        unless status.success?
          message = stderr.empty? ? stdout : stderr
          raise NodeExecutionFailed.new("Playwright visit failed: #{message.strip}", status)
        end

        JSON.parse(stdout)
      rescue Errno::ENOENT => e
        raise NodeExecutionFailed.new("Failed to execute #{node_path}: #{e.message}", nil)
      rescue JSON::ParserError => e
        raise NodeExecutionFailed.new("Invalid response from Playwright visit: #{e.message}", nil)
      end
    end
  end
end
