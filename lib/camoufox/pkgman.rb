# frozen_string_literal: true

module Camoufox
  module Pkgman
    InstallInfo = Struct.new(:path, :version, keyword_init: true)

    module_function

    def fetch_latest
      warn("[camoufox] binary fetch is not yet implemented in the native port")
      InstallInfo.new(path: "/usr/local/share/camoufox", version: "0.0.0")
    end

    def install
      fetch_latest
    end

    def remove
      warn("[camoufox] binary removal is not yet implemented")
      false
    end

    def install_dir
      "/usr/local/share/camoufox"
    end

    def version_string
      "0.0.0"
    end
  end
end
