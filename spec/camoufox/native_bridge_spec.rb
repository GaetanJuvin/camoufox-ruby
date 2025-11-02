# frozen_string_literal: true

require "spec_helper"

RSpec.describe Camoufox::NativeBridge do
  describe ".launch_options" do
    it "returns a stubbed hash" do
      options = described_class.launch_options(headless: true)
      expect(options).to include(:executable_path)
      expect(options[:env]).to be_a(Hash)
    end
  end

  describe ".run_cli" do
    it "returns stub output for known commands" do
      expect(described_class.run_cli(:version)).to include("Camoufox native stub")
    end
  end
end
