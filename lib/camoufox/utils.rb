# frozen_string_literal: true

module Camoufox
  module Utils
    module_function

    def launch_options(**kwargs)
      LaunchOptions.new(NativeBridge.launch_options(**kwargs))
    end

    def camel_case(key)
      segments = key.to_s.split('_')
      return key.to_s if segments.length < 2

      [segments.first, *segments[1..].map { |segment| segment[0].to_s.upcase + segment[1..].to_s }].join
    end

    def camelize_hash(hash)
      camelize(hash)
    end

    def camelize(value)
      case value
      when Hash
        value.each_with_object({}) do |(k, v), acc|
          acc[camel_case(k)] = camelize(v)
        end
      when Array
        value.map { |element| camelize(element) }
      else
        value
      end
    end
  end

  class LaunchOptions
    attr_reader :raw

    def initialize(raw_hash)
      @raw = symbolize_top_level(raw_hash)
    end

    def to_h
      raw.dup
    end

    private

    def symbolize_top_level(hash)
      hash.each_with_object({}) do |(key, value), acc|
        sym_key = key.respond_to?(:to_sym) ? key.to_sym : key
        acc[sym_key] = deep_dup(value)
      end
    end

    def deep_dup(value)
      case value
      when Hash
        value.each_with_object({}) do |(k, v), acc|
          acc[k] = deep_dup(v)
        end
      when Array
        value.map { |element| deep_dup(element) }
      else
        value
      end
    end
  end
end
