# frozen_string_literal: true

module Camoufox
  module MCP
    module Tools
      class GetContent < ::MCP::Tool
        tool_name "camoufox_get_content"
        description "Get the full HTML content of the current page"

        input_schema(
          properties: {},
        )

        class << self
          def call(server_context:)
            session = server_context[:session]
            session.ensure_ready!

            ::MCP::Tool::Response.new([{
              type: "text",
              text: session.page.content,
            }])
          end
        end
      end
    end
  end
end
