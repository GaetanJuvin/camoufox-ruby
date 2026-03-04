# frozen_string_literal: true

module Camoufox
  module MCP
    module Tools
      class Uncheck < ::MCP::Tool
        tool_name "camoufox_uncheck"
        description "Uncheck a checkbox"

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
            session.page.uncheck(selector)

            ::MCP::Tool::Response.new([{
              type: "text",
              text: "Unchecked #{selector}",
            }])
          end
        end
      end
    end
  end
end
