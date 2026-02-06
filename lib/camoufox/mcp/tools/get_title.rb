# frozen_string_literal: true

module Camoufox
  module MCP
    module Tools
      class GetTitle < ::MCP::Tool
        tool_name "camoufox_get_title"
        description "Get the title of the current page"

        input_schema(
          properties: {},
        )

        class << self
          def call(server_context:)
            session = server_context[:session]
            session.ensure_ready!

            ::MCP::Tool::Response.new([{
              type: "text",
              text: session.page.title,
            }])
          end
        end
      end
    end
  end
end
