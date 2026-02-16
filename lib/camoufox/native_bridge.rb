# frozen_string_literal: true

require "json"

module Camoufox
  module NativeBridge
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

      ensure_loaded!
      CamoufoxNative.executable_path({})
    end

    def launch_options(**kwargs)
      executable = resolve_executable_path(kwargs[:executable_path])

      # Generate fingerprint config and inject into env
      config = Fingerprints.generate(kwargs)
      config_json = JSON.generate(config)

      options = {
        executable_path: executable,
        headless: kwargs.fetch(:headless, false),
        args: kwargs.fetch(:args, []),
        env: { "CAMOU_CONFIG_1" => config_json },
      }

      options[:user_data_dir] = kwargs[:user_data_dir] if kwargs.key?(:user_data_dir)

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
  end

end
