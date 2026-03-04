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

      def screenshot(full_page: false, save_path: nil)
        ensure_open!
        params = { 'fullPage' => full_page }
        params['savePath'] = save_path if save_path
        result = @session.request('screenshot', params)
        save_path ? result['saved'] : result['data']
      end

      def click(selector, **opts)
        ensure_open!
        params = { 'selector' => selector }
        params['button'] = opts[:button] if opts[:button]
        params['clickCount'] = opts[:click_count] if opts[:click_count]
        params['timeout'] = opts[:timeout] if opts[:timeout]
        @session.request('click', params)
        self
      end

      def fill(selector, value)
        ensure_open!
        @session.request('fill', { 'selector' => selector, 'value' => value })
        self
      end

      def type_text(selector, text, delay: nil)
        ensure_open!
        params = { 'selector' => selector, 'text' => text }
        params['delay'] = delay if delay
        @session.request('type', params)
        self
      end

      def select_option(selector, value: nil, label: nil)
        ensure_open!
        params = { 'selector' => selector }
        params['value'] = value if value
        params['label'] = label if label
        @session.request('select_option', params)
        self
      end

      def press(selector, key)
        ensure_open!
        @session.request('press', { 'selector' => selector, 'key' => key })
        self
      end

      def hover(selector)
        ensure_open!
        @session.request('hover', { 'selector' => selector })
        self
      end

      def focus(selector)
        ensure_open!
        @session.request('focus', { 'selector' => selector })
        self
      end

      def check(selector)
        ensure_open!
        @session.request('check', { 'selector' => selector })
        self
      end

      def uncheck(selector)
        ensure_open!
        @session.request('uncheck', { 'selector' => selector })
        self
      end

      def get_url
        ensure_open!
        result = @session.request('get_url')
        result['url']
      end

      def scroll(selector: nil, x: nil, y: nil)
        ensure_open!
        params = {}
        params['selector'] = selector if selector
        params['x'] = x if x
        params['y'] = y if y
        @session.request('scroll', params)
        self
      end

      def mouse_click(x, y, button: 'left')
        ensure_open!
        @session.request('mouse_click', { 'x' => x, 'y' => y, 'button' => button })
        self
      end

      def frame_evaluate(frame_selector, expression)
        ensure_open!
        result = @session.request('frame_evaluate', { 'frameSelector' => frame_selector, 'expression' => expression })
        result['value']
      end

      def frame_screenshot(frame_selector, save_path: nil)
        ensure_open!
        params = { 'frameSelector' => frame_selector }
        params['savePath'] = save_path if save_path
        result = @session.request('frame_screenshot', params)
        save_path ? result['saved'] : result['data']
      end

      def frame_click(frame_selector, selector)
        ensure_open!
        @session.request('frame_click', { 'frameSelector' => frame_selector, 'selector' => selector })
        self
      end

      def frame_check(frame_selector, selector)
        ensure_open!
        @session.request('frame_check', { 'frameSelector' => frame_selector, 'selector' => selector })
        self
      end

      def evaluate(expression, *args)
        ensure_open!
        expression_source = expression.to_s
        raise ArgumentError, "expression must be provided" if expression_source.strip.empty?

        params = { 'expression' => expression_source }
        unless args.empty?
          params['expression'] = "(__camoufoxArgs) => (#{expression_source})(...__camoufoxArgs)"
          params['arg'] = args
        end
        result = @session.request('evaluate', params)
        result['value']
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

          # Extract :env from launch options BEFORE camelization to preserve
          # uppercase env var names like CAMOU_CONFIG_1
          camoufox_env = @launch_options.delete(:env) || {}
          camoufox_env.each { |k, v| env[k.to_s] = v.to_s }

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
