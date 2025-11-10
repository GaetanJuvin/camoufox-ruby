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
        @pages = []
      end

      def new_page
        page = Page.new(@launch_options)
        @pages << page
        page.on_close { @pages.delete(page) }
        page
      end

      def close
        @pages.each(&:close)
        @pages.clear
        nil
      end
    end

    class Page
      def initialize(launch_options)
        @launch_options = launch_options
        @session = NodeRunner::Session.new(@launch_options)
        @title = nil
        @content = nil
        @closed = false
        @on_close = nil
      end

      def on_close(&block)
        @on_close = block
      end

      def goto(url)
        ensure_open!
        result = @session.request('goto', 'url' => url)
        @title = result['title']
        @content = result['content']&.to_s
        self
      end

      def wait_for_selector(selector, **options)
        ensure_open!
        raise ArgumentError, "selector must be provided" if selector.to_s.empty?

        wait_options = options.compact
        params = { 'selector' => selector }
        params['options'] = Utils.camelize_hash(wait_options) unless wait_options.empty?
        @session.request('wait_for_selector', params)

        @title = nil
        @content = nil
        self
      end

      def content
        ensure_open!
        @content ||= begin
          result = @session.request('content')
          result['content']&.to_s
        end
      end

      def title
        ensure_open!
        @title ||= begin
          result = @session.request('title')
          result['title']
        end
      end

      def close
        return if closed?

        @session.close
        @closed = true
        @on_close&.call(self)
        nil
      end

      def closed?
        @closed
      end

      private

      def ensure_open!
        raise Camoufox::Error, "Page is closed" if closed?
      end
    end

    module NodeRunner
      class Session
        def initialize(launch_options)
          @launch_options = launch_options
          @command_id = 0
          @closed = false
          spawn_session
          wait_for_ready
        end

        def request(action, params = {})
          raise Camoufox::Error, "Page session is closed" if @closed

          @command_id += 1
          payload = {
            'id' => @command_id,
            'action' => action,
            'params' => params,
          }
          write_message(payload)
          handle_response(@command_id)
        end

        def close
          return if @closed

          begin
            request('close')
          rescue NodeExecutionFailed
            # swallow shutdown errors
          ensure
            @closed = true
            cleanup
          end
        end

        private

        def spawn_session
          node_path = ::Camoufox.configuration.node_path || 'node'
          script_path = File.expand_path('syncSession.js', __dir__)
          env = {}

          if (driver_dir = ::Camoufox.configuration.playwright_driver_dir)
            env['NODE_PATH'] = [driver_dir, ENV['NODE_PATH']].compact.join(File::PATH_SEPARATOR)
            env['CAMOUFOX_PLAYWRIGHT_DRIVER_DIR'] = driver_dir
          end

          @stdin, @stdout, stderr, @wait_thr = Open3.popen3(env, node_path, script_path)
          @stdin.sync = true
          @stdout.sync = true

          @stderr_thread = Thread.new do
            begin
              stderr.each_line { |line| warn(line.chomp) }
            rescue IOError
              nil
            ensure
              stderr.close unless stderr.closed?
            end
          end

          payload = Base64.strict_encode64(
            JSON.generate(
              options: Utils.camelize_hash(@launch_options),
            ),
          )
          @stdin.puts(payload)
        rescue Errno::ENOENT => e
          raise NodeExecutionFailed.new("Failed to execute #{node_path}: #{e.message}", nil)
        end

        def wait_for_ready
          message = read_message
          return if message['event'] == 'ready'

          raise NodeExecutionFailed.new("Invalid handshake from Playwright bridge", nil)
        end

        def handle_response(expected_id)
          message = read_message
          unless message['id'] == expected_id
            raise NodeExecutionFailed.new("Mismatched response id from Playwright bridge", nil)
          end

          if (error = message['error'])
            raise NodeExecutionFailed.new("Playwright bridge error: #{error['message']}", nil)
          end

          message['result']
        end

        def write_message(payload)
          encoded = Base64.strict_encode64(JSON.generate(payload))
          @stdin.puts(encoded)
        rescue IOError => e
          raise NodeExecutionFailed.new("Failed to talk to Playwright bridge: #{e.message}", nil)
        end

        def read_message
          line = nil
          loop do
            line = @stdout.gets
            raise NodeExecutionFailed.new("Playwright bridge closed unexpectedly", nil) if line.nil?

            stripped = line.strip
            next if stripped.empty?

            line = stripped
            break
          end

          decoded = Base64.strict_decode64(line)
          JSON.parse(decoded)
        rescue ArgumentError, JSON::ParserError => e
          raise NodeExecutionFailed.new("Invalid response from Playwright bridge: #{e.message}", nil)
        rescue IOError => e
          raise NodeExecutionFailed.new("Failed to read from Playwright bridge: #{e.message}", nil)
        end

        def cleanup
          @stdin.close unless @stdin.closed?
          @stdout.close unless @stdout.closed?
          if @wait_thr&.alive?
            Process.kill('TERM', @wait_thr.pid)
            @wait_thr.join
          else
            @wait_thr&.value
          end
          @stderr_thread&.join
        rescue Errno::ESRCH, IOError
          nil
        end
      end
    end
  end
end
