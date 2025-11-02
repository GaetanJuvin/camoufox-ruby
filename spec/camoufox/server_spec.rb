# frozen_string_literal: true

require "spec_helper"

RSpec.describe Camoufox::Server do
  let(:launch_hash) do
    {
      "executable_path" => "/tmp/camoufox",
      "headless" => true,
      "env" => {},
    }
  end

  before do
    allow(Camoufox::Utils).to receive(:launch_options).and_return(Camoufox::LaunchOptions.new(launch_hash))
  end

  after do
    Camoufox.reset_configuration!
  end

  describe ".launch" do
    it "raises when the Playwright driver directory is missing" do
      Camoufox.configuration.playwright_driver_dir = nil
      expect { described_class.launch }.to raise_error(Camoufox::MissingPlaywrightDriver)
    end

    it "invokes the node script when configuration is present" do
      Camoufox.configuration.playwright_driver_dir = "/tmp/playwright-driver"
      Camoufox.configuration.node_path = "/usr/local/bin/node"

      allow(Dir).to receive(:exist?).with("/tmp/playwright-driver").and_return(true)

      expect(described_class).to receive(:run_node_script).with(
        "/usr/local/bin/node",
        a_string_matching(/launchServer\.js$/),
        "/tmp/playwright-driver",
        kind_of(String)
      )

      described_class.launch
    end
  end
end
