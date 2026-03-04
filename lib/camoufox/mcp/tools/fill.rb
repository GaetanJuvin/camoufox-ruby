# frozen_string_literal: true

module Camoufox
  module MCP
    module Tools
      class Fill < ::MCP::Tool
        tool_name "camoufox_fill"
        description "Fill an input field with text (clears existing value first)"

        input_schema(
          properties: {
            selector: {
              type: "string",
              description: "CSS selector of the input field",
            },
            value: {
              type: "string",
              description: "Value to fill in",
            },
          },
          required: ["selector", "value"],
        )

        class << self
          def call(selector:, value:, server_context:)
            session = server_context[:session]
            session.ensure_ready!
            session.page.fill(selector, value)

            ::MCP::Tool::Response.new([{
              type: "text",
              text: "Filled #{selector} with value",
            }])
          end
        end
      end
    end
  end
end
