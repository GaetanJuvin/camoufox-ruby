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
