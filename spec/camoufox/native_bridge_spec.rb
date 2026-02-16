# frozen_string_literal: true

require "spec_helper"

RSpec.describe Camoufox::NativeBridge do
  let(:pkgman_path) { Camoufox::Pkgman.executable_path }
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
    it "returns a hash with fingerprint config in CAMOU_CONFIG env vars" do
      options = described_class.launch_options(headless: true)
      expect(options[:executable_path]).to eq(pkgman_path)
      expect(options[:env]).to be_a(Hash)

      config_json = options[:env]["CAMOU_CONFIG_1"]
      expect(config_json).to be_a(String)
      config = JSON.parse(config_json)
      expect(config).to be_a(Hash)
      expect(config["navigator.userAgent"]).to match(/Firefox\/\d+\.0$/)
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

    it "uses Camoufox::Pkgman.executable_path as the default" do
      options = described_class.launch_options
      expect(options[:executable_path]).to eq(pkgman_path)
    end

    it "passes through the user_data_dir option" do
      options = described_class.launch_options(user_data_dir: "/tmp/camoufox-profile")
      expect(options[:user_data_dir]).to eq("/tmp/camoufox-profile")
    end

    it "sets block_webrtc as a Firefox user pref" do
      options = described_class.launch_options(block_webrtc: true)
      expect(options[:firefox_user_prefs]["media.peerconnection.enabled"]).to eq(false)
    end

    it "sets block_webgl as a Firefox user pref" do
      options = described_class.launch_options(block_webgl: true)
      expect(options[:firefox_user_prefs]["webgl.disabled"]).to eq(true)
    end

    it "sets block_images as a Firefox user pref" do
      options = described_class.launch_options(block_images: true)
      expect(options[:firefox_user_prefs]["permissions.default.image"]).to eq(2)
    end

    it "sets disable_coop as a Firefox user pref" do
      options = described_class.launch_options(disable_coop: true)
      expect(options[:firefox_user_prefs]["browser.tabs.remote.useCrossOriginOpenerPolicy"]).to eq(false)
    end

    it "sets cache prefs when enable_cache is true" do
      options = described_class.launch_options(enable_cache: true)
      expect(options[:firefox_user_prefs]["browser.cache.disk.enable"]).to eq(true)
    end

    it "does not include firefox_user_prefs when no prefs are needed" do
      options = described_class.launch_options
      expect(options).not_to have_key(:firefox_user_prefs)
    end

    it "merges custom firefox_user_prefs" do
      options = described_class.launch_options(firefox_user_prefs: { "custom.pref" => 42 })
      expect(options[:firefox_user_prefs]["custom.pref"]).to eq(42)
    end

    it "normalizes proxy hash" do
      options = described_class.launch_options(proxy: { server: "http://proxy:8080", username: "user", password: "pass" })
      expect(options[:proxy]).to eq({ server: "http://proxy:8080", username: "user", password: "pass" })
    end

    it "normalizes proxy string" do
      options = described_class.launch_options(proxy: "http://proxy:8080")
      expect(options[:proxy]).to eq({ server: "http://proxy:8080" })
    end

    it "does not include proxy when not specified" do
      options = described_class.launch_options
      expect(options).not_to have_key(:proxy)
    end

    it "passes os: through to fingerprint generation" do
      options = described_class.launch_options(os: :windows)
      config_json = options[:env]["CAMOU_CONFIG_1"]
      config = JSON.parse(config_json)
      expect(config["navigator.platform"]).to eq("Win32")
    end

    it "allows user config overrides" do
      options = described_class.launch_options(config: { "navigator.maxTouchPoints" => 5 })
      config_json = options[:env]["CAMOU_CONFIG_1"]
      config = JSON.parse(config_json)
      expect(config["navigator.maxTouchPoints"]).to eq(5)
    end

    it "handles extra launch options" do
      options = described_class.launch_options(slow_mo: 100, timeout: 30000)
      expect(options[:slow_mo]).to eq(100)
      expect(options[:timeout]).to eq(30000)
    end
  end

  describe ".chunk_config" do
    it "produces a single chunk for small configs" do
      chunks = described_class.chunk_config({ "key" => "value" })
      expect(chunks.keys).to eq(["CAMOU_CONFIG_1"])
    end

    it "produces multiple chunks for large configs" do
      large_value = "x" * 40_000
      chunks = described_class.chunk_config({ "key" => large_value })
      expect(chunks.keys.size).to be > 1
      expect(chunks.keys.first).to eq("CAMOU_CONFIG_1")
      expect(chunks.keys.last).to eq("CAMOU_CONFIG_2")
    end

    it "reconstructs to original JSON when concatenated" do
      config = { "key1" => "value1", "key2" => "value2" }
      chunks = described_class.chunk_config(config)
      reconstructed = chunks.sort_by { |k, _| k }.map(&:last).join
      expect(JSON.parse(reconstructed)).to eq(config)
    end
  end

  describe ".run_cli" do
    it "returns output for known commands" do
      expect(described_class.run_cli(:version)).to include("Camoufox")
    end
  end
end
