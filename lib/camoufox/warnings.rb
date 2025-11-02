# frozen_string_literal: true

module Camoufox
  module Warnings
    module_function

    def warn(feature, message = nil)
      note = message || "#{feature} is not yet implemented"
      Kernel.warn("[camoufox] #{note}")
    end
  end
end
