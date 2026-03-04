# frozen_string_literal: true

require "mcp"
require "camoufox"

require_relative "mcp/session"
require_relative "mcp/tools/launch"
require_relative "mcp/tools/goto"
require_relative "mcp/tools/get_content"
require_relative "mcp/tools/get_title"
require_relative "mcp/tools/evaluate"
require_relative "mcp/tools/wait_for_selector"
require_relative "mcp/tools/screenshot"
require_relative "mcp/tools/click"
require_relative "mcp/tools/fill"
require_relative "mcp/tools/type"
require_relative "mcp/tools/select_option"
require_relative "mcp/tools/press"
require_relative "mcp/tools/hover"
require_relative "mcp/tools/focus"
require_relative "mcp/tools/check"
require_relative "mcp/tools/uncheck"
require_relative "mcp/tools/scroll"
require_relative "mcp/tools/get_url"
require_relative "mcp/tools/mouse_click"
require_relative "mcp/tools/frame_evaluate"
require_relative "mcp/tools/frame_screenshot"
require_relative "mcp/tools/frame_click"
require_relative "mcp/tools/close"

module Camoufox
  module MCP
    TOOLS = [
      Tools::Launch,
      Tools::Goto,
      Tools::GetContent,
      Tools::GetTitle,
      Tools::Evaluate,
      Tools::WaitForSelector,
      Tools::Screenshot,
      Tools::Click,
      Tools::Fill,
      Tools::Type,
      Tools::SelectOption,
      Tools::Press,
      Tools::Hover,
      Tools::Focus,
      Tools::Check,
      Tools::Uncheck,
      Tools::Scroll,
      Tools::GetUrl,
      Tools::MouseClick,
      Tools::FrameEvaluate,
      Tools::FrameScreenshot,
      Tools::FrameClick,
      Tools::Close,
    ].freeze

    def self.server
      session = Session.new

      ::MCP::Server.new(
        name: "camoufox",
        version: Camoufox::VERSION,
        tools: TOOLS,
        server_context: { session: session },
      )
    end

    def self.start
      transport = ::MCP::Server::Transports::StdioTransport.new(server)
      transport.open
    end
  end
end
