# frozen_string_literal: true

module Camoufox
  class Error < StandardError; end

  class MissingNativeExtension < Error; end

  class MissingPlaywrightDriver < Error; end

  class NodeExecutionFailed < Error
    attr_reader :status

    def initialize(message, status)
      super(message)
      @status = status
    end
  end
end
