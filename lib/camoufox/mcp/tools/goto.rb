# frozen_string_literal: true

module Camoufox
  module MCP
    module Tools
      class Goto < ::MCP::Tool
        tool_name "camoufox_goto"
        description "Navigate the browser to a URL"

        input_schema(
          properties: {
            url: {
              type: "string",
              description: "The URL to navigate to",
            },
          },
          required: ["url"],
        )

        class << self
          def call(url:, server_context:)
            session = server_context[:session]
            session.ensure_ready!
            session.page.goto(url)

            ::MCP::Tool::Response.new([{
              type: "text",
              text: "Navigated to #{url}. Title: #{session.page.title}",
            }])
          end
        end
      end
    end
  end
end
