# frozen_string_literal: true

require "json"

module Camoufox
  module ConfigValidator
    module_function

    def validate!(config)
      props = load_properties
      return if props.empty?

      known_keys = props.map { |p| p["property"] }
      unknown = config.keys.select { |k| k.is_a?(String) } - known_keys
      return if unknown.empty?

      Kernel.warn("[camoufox] Unknown config keys: #{unknown.join(', ')}")
    end

    def load_properties
      properties_path = File.join(Pkgman.install_dir, "properties.json")
      return [] unless File.exist?(properties_path)

      JSON.parse(File.read(properties_path))
    rescue JSON::ParserError
      []
    end
  end
end
