# frozen_string_literal: true

module Camoufox
  module MCP
    module Tools
      class Check < ::MCP::Tool
        tool_name "camoufox_check"
        description "Check a checkbox"

        input_schema(
          properties: {
            selector: {
              type: "string",
              description: "CSS selector of the checkbox",
            },
          },
          required: ["selector"],
        )

        class << self
          def call(selector:, server_context:)
            session = server_context[:session]
            session.ensure_ready!
            session.page.check(selector)

            ::MCP::Tool::Response.new([{
              type: "text",
              text: "Checked #{selector}",
            }])
          end
        end
      end
    end
  end
end
