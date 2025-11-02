# frozen_string_literal: true

module Camoufox
  module Addons
    DefaultAddons = [].freeze

    module_function

    def default_addons
      DefaultAddons
    end

    def maybe_download_addons(_addons)
      warn("[camoufox] addon management is not yet implemented in the native port")
    end

    def confirm_paths(_addons)
      true
    end
  end
end
