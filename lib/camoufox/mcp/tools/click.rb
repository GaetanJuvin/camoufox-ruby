# frozen_string_literal: true

module Camoufox
  module MCP
    module Tools
      class Click < ::MCP::Tool
        tool_name "camoufox_click"
        description "Click on an element"

        input_schema(
          properties: {
            selector: {
              type: "string",
              description: "CSS selector of the element to click",
            },
            button: {
              type: "string",
              description: "Mouse button: left, right, or middle (default: left)",
            },
            click_count: {
              type: "integer",
              description: "Number of clicks (default: 1, use 2 for double-click)",
            },
            timeout: {
              type: "integer",
              description: "Timeout in milliseconds",
            },
          },
          required: ["selector"],
        )

        class << self
          def call(selector:, server_context:, button: nil, click_count: nil, timeout: nil)
            session = server_context[:session]
            session.ensure_ready!

            opts = {}
            opts[:button] = button if button
            opts[:click_count] = click_count if click_count
            opts[:timeout] = timeout if timeout
            session.page.click(selector, **opts)

            ::MCP::Tool::Response.new([{
              type: "text",
              text: "Clicked #{selector}",
            }])
          end
        end
      end
    end
  end
end
