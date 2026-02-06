# frozen_string_literal: true

module Camoufox
  module MCP
    module Tools
      class WaitForSelector < ::MCP::Tool
        tool_name "camoufox_wait_for_selector"
        description "Wait for a DOM element matching a CSS selector to appear on the page"

        input_schema(
          properties: {
            selector: {
              type: "string",
              description: "CSS selector to wait for (e.g. '#login-form', '.results')",
            },
            timeout: {
              type: "integer",
              description: "Maximum time to wait in milliseconds (default: 30000)",
            },
            state: {
              type: "string",
              description: "State to wait for: 'attached', 'detached', 'visible', or 'hidden'",
              enum: %w[attached detached visible hidden],
            },
          },
          required: ["selector"],
        )

        class << self
          def call(selector:, server_context:, timeout: nil, state: nil)
            session = server_context[:session]
            session.ensure_ready!

            opts = {}
            opts[:timeout] = timeout if timeout
            opts[:state] = state if state

            session.page.wait_for_selector(selector, **opts)

            ::MCP::Tool::Response.new([{
              type: "text",
              text: "Selector '#{selector}' resolved.",
            }])
          end
        end
      end
    end
  end
end
