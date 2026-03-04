# frozen_string_literal: true

module Camoufox
  module MCP
    module Tools
      class MouseClick < ::MCP::Tool
        tool_name "camoufox_mouse_click"
        description "Click at specific page coordinates (useful for iframes like reCAPTCHA)"

        input_schema(
          properties: {
            x: {
              type: "number",
              description: "X coordinate in pixels",
            },
            y: {
              type: "number",
              description: "Y coordinate in pixels",
            },
            button: {
              type: "string",
              description: "Mouse button: left, right, or middle (default: left)",
            },
          },
          required: ["x", "y"],
        )

        class << self
          def call(x:, y:, server_context:, button: nil)
            session = server_context[:session]
            session.ensure_ready!
            session.page.mouse_click(x, y, button: button || 'left')

            ::MCP::Tool::Response.new([{
              type: "text",
              text: "Clicked at (#{x}, #{y})",
            }])
          end
        end
      end
    end
  end
end
