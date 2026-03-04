# frozen_string_literal: true

module Camoufox
  module MCP
    module Tools
      class SelectOption < ::MCP::Tool
        tool_name "camoufox_select_option"
        description "Select an option from a dropdown"

        input_schema(
          properties: {
            selector: {
              type: "string",
              description: "CSS selector of the select element",
            },
            value: {
              type: "string",
              description: "Option value to select",
            },
            label: {
              type: "string",
              description: "Option label text to select (used if value not provided)",
            },
          },
          required: ["selector"],
        )

        class << self
          def call(selector:, server_context:, value: nil, label: nil)
            session = server_context[:session]
            session.ensure_ready!
            session.page.select_option(selector, value: value, label: label)

            ::MCP::Tool::Response.new([{
              type: "text",
              text: "Selected option in #{selector}",
            }])
          end
        end
      end
    end
  end
end
