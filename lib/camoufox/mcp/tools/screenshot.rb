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
          },
        )

        class << self
          def call(server_context:, full_page: false)
            session = server_context[:session]
            session.ensure_ready!

            data = session.page.screenshot(full_page: full_page)

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
