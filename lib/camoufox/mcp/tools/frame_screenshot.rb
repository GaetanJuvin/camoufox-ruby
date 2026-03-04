# frozen_string_literal: true

module Camoufox
  module MCP
    module Tools
      class FrameScreenshot < ::MCP::Tool
        tool_name "camoufox_frame_screenshot"
        description "Take a screenshot of an iframe's content (e.g. reCAPTCHA challenge)"

        input_schema(
          properties: {
            frame_selector: {
              type: "string",
              description: "CSS selector for the iframe element",
            },
            save_path: {
              type: "string",
              description: "Save screenshot to this file path",
            },
          },
          required: ["frame_selector"],
        )

        class << self
          def call(frame_selector:, server_context:, save_path: nil)
            session = server_context[:session]
            session.ensure_ready!

            if save_path
              session.page.frame_screenshot(frame_selector, save_path: save_path)
              ::MCP::Tool::Response.new([{
                type: "text",
                text: "Frame screenshot saved to #{save_path}",
              }])
            else
              data = session.page.frame_screenshot(frame_selector)
              ::MCP::Tool::Response.new([{
                type: "image",
                data: data,
                mimeType: "image/png",
              }])
            end
          end
        end
      end
    end
  end
end
