# frozen_string_literal: true

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

    def launch_options(**kwargs)
      ensure_loaded!
      options = CamoufoxNative.launch_options(kwargs)
      if kwargs.key?(:user_data_dir)
        options = options.dup
        options[:user_data_dir] = kwargs[:user_data_dir]
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
  end

end
