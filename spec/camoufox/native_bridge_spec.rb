# frozen_string_literal: true

require "spec_helper"

RSpec.describe Camoufox::NativeBridge do
  let(:pkgman_path) { File.join(Camoufox::Pkgman.install_dir, "camoufox") }
  let(:env_key) { "CAMOUFOX_EXECUTABLE_PATH" }

  before do
    @original_exec_path = ENV[env_key]
    ENV.delete(env_key)
  end

  after do
    if @original_exec_path
      ENV[env_key] = @original_exec_path
    else
      ENV.delete(env_key)
    end
  end

  describe ".launch_options" do
    it "returns a stubbed hash" do
      options = described_class.launch_options(headless: true)
      expect(options[:executable_path]).to eq(pkgman_path)
      expect(options[:env]).to be_a(Hash)
    end

    it "respects the headless option" do
      headless_options = described_class.launch_options(headless: true)
      headful_options = described_class.launch_options(headless: false)

      expect(headless_options[:headless]).to eq(true)
      expect(headful_options[:headless]).to eq(false)
    end

    it "uses the provided executable_path when supplied" do
      options = described_class.launch_options(executable_path: "/opt/camoufox")
      expect(options[:executable_path]).to eq("/opt/camoufox")
    end

    it "falls back to CAMOUFOX_EXECUTABLE_PATH when no option is provided" do
      ENV[env_key] = "/env/camoufox"

      options = described_class.launch_options
      expect(options[:executable_path]).to eq("/env/camoufox")
    end

    it "uses Camoufox::Pkgman.install_dir/camoufox as the default" do
      options = described_class.launch_options
      expect(options[:executable_path]).to eq(pkgman_path)
    end

    it "passes through the user_data_dir option so Playwright can launch persistent contexts" do
      options = described_class.launch_options(user_data_dir: "/tmp/camoufox-profile")
      expect(options[:user_data_dir]).to eq("/tmp/camoufox-profile")
    end
  end

  describe ".run_cli" do
    it "returns stub output for known commands" do
      expect(described_class.run_cli(:version)).to include("Camoufox native stub")
    end
  end
end
