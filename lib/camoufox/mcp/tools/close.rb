# frozen_string_literal: true

module Camoufox
  module MCP
    module Tools
      class Close < ::MCP::Tool
        tool_name "camoufox_close"
        description "Close the Camoufox browser session"

        input_schema(
          properties: {},
        )

        class << self
          def call(server_context:)
            session = server_context[:session]
            session.close

            ::MCP::Tool::Response.new([{
              type: "text",
              text: "Browser session closed.",
            }])
          end
        end
      end
    end
  end
end
