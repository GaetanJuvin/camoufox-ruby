# frozen_string_literal: true

module Camoufox
  module MCP
    module Tools
      class Screenshot < ::MCP::Tool
        tool_name "camoufox_screenshot"
        description "Take a screenshot of the current page"

        input_schema(
          properties: {
            full_page: {
              type: "boolean",
              description: "Capture the full scrollable page instead of just the viewport",
            },
            save_path: {
              type: "string",
              description: "Save screenshot to this file path instead of returning base64",
            },
          },
        )

        class << self
          def call(server_context:, full_page: false, save_path: nil)
            session = server_context[:session]
            session.ensure_ready!

            if save_path
              session.page.screenshot(full_page: full_page, save_path: save_path)
              ::MCP::Tool::Response.new([{
                type: "text",
                text: "Screenshot saved to #{save_path}",
              }])
            else
              data = session.page.screenshot(full_page: full_page)
              ::MCP::Tool::Response.new([{
                type: "text",
                text: data,
              }])
            end
          end
        end
      end
    end
  end
end
