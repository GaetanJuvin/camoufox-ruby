# frozen_string_literal: true

module Camoufox
  module MCP
    module Tools
      class Evaluate < ::MCP::Tool
        tool_name "camoufox_evaluate"
        description "Execute JavaScript on the current page and return the result"

        input_schema(
          properties: {
            expression: {
              type: "string",
              description: "JavaScript expression or function to evaluate (e.g. '() => document.title' or '(a, b) => a + b')",
            },
            args: {
              type: "array",
              description: "Arguments to pass to the JavaScript function",
              items: {},
            },
          },
          required: ["expression"],
        )

        class << self
          def call(expression:, server_context:, args: [])
            session = server_context[:session]
            session.ensure_ready!

            result = session.page.evaluate(expression, *args)

            ::MCP::Tool::Response.new([{
              type: "text",
              text: result.is_a?(String) ? result : JSON.generate(result),
            }])
          end
        end
      end
    end
  end
end
