# frozen_string_literal: true

module Camoufox
  module Warnings
    module_function

    def warn(feature, message = nil)
      note = message || "#{feature} is not yet implemented"
      Kernel.warn("[camoufox] #{note}")
    end

    def check_proxy_leak(proxy:, geoip:)
      return unless proxy
      return if geoip

      Kernel.warn("[camoufox] WARNING: Using proxy without geoip may leak timezone/locale information. " \
                  "Set geoip: true or provide an IP string to match fingerprint to proxy location.")
    end

    def debug_config(config, enabled: false)
      return unless enabled

      Kernel.warn("[camoufox] DEBUG: CAMOU_CONFIG keys (#{config.keys.size}):")
      config.each do |key, value|
        display = value.is_a?(Array) ? "[#{value.size} items]" : value.inspect.truncate(80)
        Kernel.warn("[camoufox]   #{key}: #{display}")
      end
    end
  end
end

class String
  def truncate(length, omission: "...")
    return self if self.length <= length

    self[0, length - omission.length] + omission
  end
end unless String.method_defined?(:truncate)
