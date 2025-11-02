# frozen_string_literal: true

require "spec_helper"

RSpec.describe Camoufox::LaunchOptions do
  let(:data) do
    {
      "executable_path" => "/tmp/camoufox",
      "env" => { "CAMOU_CONFIG_1" => "{}" },
      "args" => ["--foo"],
      "headless" => false
    }
  end

  subject(:launch_options) { described_class.new(data) }

  it "symbolizes only the top-level keys" do
    expect(launch_options.raw.keys).to contain_exactly(:executable_path, :env, :args, :headless)
    expect(launch_options.raw[:env].keys).to contain_exactly("CAMOU_CONFIG_1")
  end

  it "returns a dup hash via to_h" do
    expect(launch_options.to_h).to eq(launch_options.raw)
    expect(launch_options.to_h).not_to be(launch_options.raw)
  end
end

RSpec.describe Camoufox do
  describe ".launch_options" do
    it "wraps the native bridge output" do
      expect(described_class.launch_options.to_h).to include(:executable_path)
    end
  end
end
