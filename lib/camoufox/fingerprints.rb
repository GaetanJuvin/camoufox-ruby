# frozen_string_literal: true

module Camoufox
  module Fingerprints
    module_function

    def generate(_options = {})
      warn("[camoufox] fingerprint generation is not yet implemented in the native port")
      {}
    end

    def from_browserforge(_fingerprint, _ff_version)
      warn("[camoufox] BrowserForge integration is not yet implemented")
      {}
    end
  end
end
