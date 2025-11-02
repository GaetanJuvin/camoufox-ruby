# frozen_string_literal: true

require "json"
require "base64"
require "open3"

module Camoufox
  module Server
    module_function

    def launch(**kwargs)
      launch_config = Utils.launch_options(**kwargs).to_h
      payload = Base64.strict_encode64(JSON.generate(Utils.camelize_hash(launch_config)))

      driver_dir = Camoufox.configuration.playwright_driver_dir
      raise MissingPlaywrightDriver, missing_driver_message unless driver_dir && Dir.exist?(driver_dir)

      node_path = Camoufox.configuration.node_path || 'node'
      script_path = File.expand_path("launchServer.js", __dir__)

      run_node_script(node_path, script_path, driver_dir, payload)
    end

    def missing_driver_message
      'Set CAMOUFOX_PLAYWRIGHT_DRIVER_DIR to the Playwright driver directory (contains lib/browserServerImpl.js)'
    end

    def run_node_script(node_path, script_path, working_dir, payload)
      env = { 'CAMOUFOX_PLAYWRIGHT_DRIVER_DIR' => working_dir }
      Open3.popen2e(env, node_path, script_path, chdir: working_dir) do |stdin, stdout_err, wait_thr|
        stdin.write(payload)
        stdin.close

        stdout_err.each { |line| puts line }

        status = wait_thr.value
        return if status.success?

        raise NodeExecutionFailed.new("Playwright server exited with status #{status.exitstatus}", status)
      end
    rescue Errno::ENOENT => e
      raise NodeExecutionFailed.new("Failed to execute #{node_path}: #{e.message}", nil)
    end
  end
end
