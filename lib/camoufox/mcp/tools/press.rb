# frozen_string_literal: true

module Camoufox
  module MCP
    module Tools
      class Press < ::MCP::Tool
        tool_name "camoufox_press"
        description "Press a keyboard key on an element"

        input_schema(
          properties: {
            selector: {
              type: "string",
              description: "CSS selector of the element",
            },
            key: {
              type: "string",
              description: "Key to press (e.g. Enter, Tab, ArrowDown, a, Shift+A)",
            },
          },
          required: ["selector", "key"],
        )

        class << self
          def call(selector:, key:, server_context:)
            session = server_context[:session]
            session.ensure_ready!
            session.page.press(selector, key)

            ::MCP::Tool::Response.new([{
              type: "text",
              text: "Pressed #{key} on #{selector}",
            }])
          end
        end
      end
    end
  end
end
