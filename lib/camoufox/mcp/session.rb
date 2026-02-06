# frozen_string_literal: true

module Camoufox
  module MCP
    class Session
      attr_reader :browser, :page

      def initialize
        @browser = nil
        @page = nil
      end

      def launch(**kwargs)
        close if @browser
        @browser = SyncAPI::Camoufox.new(**kwargs)
        @page = @browser.new_page
        { status: "launched" }
      end

      def ensure_ready!
        raise Camoufox::Error, "Browser not launched. Call camoufox_launch first." unless @browser
        raise Camoufox::Error, "No page available. Call camoufox_launch first." unless @page
      end

      def close
        @page = nil
        @browser&.close
        @browser = nil
      end
    end
  end
end
