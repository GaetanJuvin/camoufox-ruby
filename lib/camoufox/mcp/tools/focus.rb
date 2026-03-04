# frozen_string_literal: true

module Camoufox
  module MCP
    module Tools
      class Focus < ::MCP::Tool
        tool_name "camoufox_focus"
        description "Focus on an element"

        input_schema(
          properties: {
            selector: {
              type: "string",
              description: "CSS selector of the element to focus",
            },
          },
          required: ["selector"],
        )

        class << self
          def call(selector:, server_context:)
            session = server_context[:session]
            session.ensure_ready!
            session.page.focus(selector)

            ::MCP::Tool::Response.new([{
              type: "text",
              text: "Focused on #{selector}",
            }])
          end
        end
      end
    end
  end
end
