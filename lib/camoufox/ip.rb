# frozen_string_literal: true

module Camoufox
  module IP
    module_function

    def public_ip(_proxy = nil)
      warn("[camoufox] public IP resolution is not yet implemented")
      "0.0.0.0"
    end

    def valid_ipv4(_value)
      false
    end

    def valid_ipv6(_value)
      false
    end
  end
end
