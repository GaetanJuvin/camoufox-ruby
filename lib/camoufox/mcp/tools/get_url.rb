# frozen_string_literal: true

module Camoufox
  module MCP
    module Tools
      class GetUrl < ::MCP::Tool
        tool_name "camoufox_get_url"
        description "Get the current page URL"

        input_schema(
          properties: {},
        )

        class << self
          def call(server_context:)
            session = server_context[:session]
            session.ensure_ready!
            url = session.page.get_url

            ::MCP::Tool::Response.new([{
              type: "text",
              text: url,
            }])
          end
        end
      end
    end
  end
end
