# frozen_string_literal: true

module Camoufox
  module MCP
    module Tools
      class Type < ::MCP::Tool
        tool_name "camoufox_type"
        description "Type text into the currently focused element, character by character"

        input_schema(
          properties: {
            selector: {
              type: "string",
              description: "CSS selector of the element to type into",
            },
            text: {
              type: "string",
              description: "Text to type",
            },
            delay: {
              type: "integer",
              description: "Delay between key presses in milliseconds",
            },
          },
          required: ["selector", "text"],
        )

        class << self
          def call(selector:, text:, server_context:, delay: nil)
            session = server_context[:session]
            session.ensure_ready!
            session.page.type_text(selector, text, delay: delay)

            ::MCP::Tool::Response.new([{
              type: "text",
              text: "Typed into #{selector}",
            }])
          end
        end
      end
    end
  end
end
