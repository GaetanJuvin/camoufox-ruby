# frozen_string_literal: true

module Camoufox
  module MCP
    module Tools
      class FrameEvaluate < ::MCP::Tool
        tool_name "camoufox_frame_evaluate"
        description "Execute JavaScript inside an iframe (e.g. read reCAPTCHA challenge text)"

        input_schema(
          properties: {
            frame_selector: {
              type: "string",
              description: "CSS selector for the iframe element",
            },
            expression: {
              type: "string",
              description: "JavaScript expression to evaluate inside the frame",
            },
          },
          required: ["frame_selector", "expression"],
        )

        class << self
          def call(frame_selector:, expression:, server_context:)
            session = server_context[:session]
            session.ensure_ready!
            result = session.page.frame_evaluate(frame_selector, expression)

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
