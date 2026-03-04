# frozen_string_literal: true

module Camoufox
  module MCP
    module Tools
      class Hover < ::MCP::Tool
        tool_name "camoufox_hover"
        description "Hover over an element"

        input_schema(
          properties: {
            selector: {
              type: "string",
              description: "CSS selector of the element to hover",
            },
          },
          required: ["selector"],
        )

        class << self
          def call(selector:, server_context:)
            session = server_context[:session]
            session.ensure_ready!
            session.page.hover(selector)

            ::MCP::Tool::Response.new([{
              type: "text",
              text: "Hovered over #{selector}",
            }])
          end
        end
      end
    end
  end
end
