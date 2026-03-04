# frozen_string_literal: true

module Camoufox
  module MCP
    module Tools
      class Scroll < ::MCP::Tool
        tool_name "camoufox_scroll"
        description "Scroll the page or scroll an element into view"

        input_schema(
          properties: {
            selector: {
              type: "string",
              description: "CSS selector to scroll into view",
            },
            x: {
              type: "integer",
              description: "Horizontal scroll amount in pixels",
            },
            y: {
              type: "integer",
              description: "Vertical scroll amount in pixels",
            },
          },
        )

        class << self
          def call(server_context:, selector: nil, x: nil, y: nil)
            session = server_context[:session]
            session.ensure_ready!
            session.page.scroll(selector: selector, x: x, y: y)

            msg = selector ? "Scrolled #{selector} into view" : "Scrolled page by (#{x || 0}, #{y || 0})"
            ::MCP::Tool::Response.new([{
              type: "text",
              text: msg,
            }])
          end
        end
      end
    end
  end
end
