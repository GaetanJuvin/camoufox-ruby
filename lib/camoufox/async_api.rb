# frozen_string_literal: true

module Camoufox
  module AsyncAPI
    module_function

    def new_browser(**launch_kwargs)
      Utils.launch_options(**launch_kwargs)
    end
  end
end
