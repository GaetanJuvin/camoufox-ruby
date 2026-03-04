# frozen_string_literal: true

module Camoufox
  module MCP
    module Tools
      class FrameClick < ::MCP::Tool
        tool_name "camoufox_frame_click"
        description "Click on an element inside an iframe (e.g. reCAPTCHA)"

        input_schema(
          properties: {
            frame_selector: {
              type: "string",
              description: "CSS selector for the iframe element",
            },
            selector: {
              type: "string",
              description: "CSS selector of the element inside the frame",
            },
          },
          required: ["frame_selector", "selector"],
        )

        class << self
          def call(frame_selector:, selector:, server_context:)
            session = server_context[:session]
            session.ensure_ready!
            session.page.frame_click(frame_selector, selector)

            ::MCP::Tool::Response.new([{
              type: "text",
              text: "Clicked #{selector} inside frame #{frame_selector}",
            }])
          end
        end
      end
    end
  end
end
