# frozen_string_literal: true

module Camoufox
  class Configuration
    attr_accessor :data_dir, :cache_dir, :node_path, :playwright_driver_dir

    def initialize
      reset_defaults
    end

    def reset_defaults
      @data_dir = ENV['CAMOUFOX_DATA_DIR']
      @cache_dir = ENV['CAMOUFOX_CACHE_DIR']
      @node_path = ENV['CAMOUFOX_NODE_PATH'] || 'node'
      @playwright_driver_dir = ENV['CAMOUFOX_PLAYWRIGHT_DRIVER_DIR']
    end
  end
end
