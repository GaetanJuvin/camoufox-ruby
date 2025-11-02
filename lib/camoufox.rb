# frozen_string_literal: true

require_relative "camoufox/__version__"
require_relative "camoufox/exceptions"
require_relative "camoufox/configuration"
# Core helpers
require_relative "camoufox/utils"
require_relative "camoufox/addons"
require_relative "camoufox/fingerprints"
require_relative "camoufox/ip"
require_relative "camoufox/locale"
require_relative "camoufox/pkgman"
require_relative "camoufox/sync_api"
require_relative "camoufox/async_api"
require_relative "camoufox/server"
require_relative "camoufox/virtdisplay"
require_relative "camoufox/warnings"
require_relative "camoufox/native_bridge"
require_relative "camoufox/__main__"

module Camoufox
  class << self
    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def reset_configuration!
      @configuration = Configuration.new
    end

    def launch_options(**kwargs)
      Utils.launch_options(**kwargs)
    end

    def fetch(update_browserforge: false, env: {})
      CLI.run("fetch", update_browserforge ? ["--browserforge"] : [], env: env)
    end

    def remove(env: {})
      CLI.run("remove", [], env: env)
    end

    def path(env: {})
      CLI.run("path", [], env: env).strip
    end

    def version(env: {})
      CLI.run("version", [], env: env)
    end
  end
end
