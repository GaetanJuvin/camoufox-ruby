# frozen_string_literal: true

module Camoufox
  module CLI
    module_function

    def run(command, args = [], env: {})
      warn("[camoufox] Native CLI does not yet honour environment overrides") if env && !env.empty?
      NativeBridge.run_cli(command, args)
    end
  end
end
