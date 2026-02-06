# frozen_string_literal: true

module Camoufox
  module MCP
    module Tools
      class Launch < ::MCP::Tool
        tool_name "camoufox_launch"
        description "Launch a stealth Camoufox browser session"

        input_schema(
          properties: {
            headless: {
              type: "boolean",
              description: "Run the browser without a visible window",
            },
            user_data_dir: {
              type: "string",
              description: "Path to a user data directory for persistent browser profiles",
            },
          },
        )

        class << self
          def call(server_context:, **kwargs)
            session = server_context[:session]
            opts = {}
            opts[:headless] = kwargs[:headless] unless kwargs[:headless].nil?
            opts[:user_data_dir] = kwargs[:user_data_dir] if kwargs[:user_data_dir]

            session.launch(**opts)

            ::MCP::Tool::Response.new([{
              type: "text",
              text: "Browser launched successfully#{opts[:headless] ? ' (headless)' : ''}.",
            }])
          end
        end
      end
    end
  end
end
