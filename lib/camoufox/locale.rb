# frozen_string_literal: true

module Camoufox
  module Locale
    module_function

    def handle_locales(_locales, config)
      config
    end

    def geoip_allowed?
      false
    end

    def download_mmdb
      warn("[camoufox] GeoIP database download is not yet implemented")
    end

    def remove_mmdb
      warn("[camoufox] GeoIP cleanup is not yet implemented")
    end
  end
end
