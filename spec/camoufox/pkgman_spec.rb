# frozen_string_literal: true

require "spec_helper"

RSpec.describe Camoufox::Pkgman do
  describe ".os_name" do
    it "returns a recognized platform string" do
      expect(%w[mac lin win]).to include(described_class.os_name)
    end
  end

  describe ".arch_name" do
    it "returns a recognized architecture string" do
      expect(%w[x86_64 arm64 i686]).to include(described_class.arch_name)
    end
  end

  describe ".platform_string" do
    it "combines os and arch with a dot" do
      expect(described_class.platform_string).to match(/\A(mac|lin|win)\.(x86_64|arm64|i686)\z/)
    end
  end

  describe ".install_dir" do
    it "returns a path under the user home directory" do
      expect(described_class.install_dir).to include(Dir.home)
    end
  end

  describe ".executable_path" do
    it "returns a platform-appropriate executable path" do
      path = described_class.executable_path
      case described_class.os_name
      when "mac"
        expect(path).to end_with("Camoufox.app/Contents/MacOS/camoufox")
      when "lin"
        expect(path).to end_with("camoufox-bin")
      when "win"
        expect(path).to end_with("camoufox.exe")
      end
    end

    it "is rooted under install_dir" do
      expect(described_class.executable_path).to start_with(described_class.install_dir)
    end
  end

  describe ".find_matching_asset" do
    let(:mock_release) do
      {
        "tag_name" => "v0.1.0",
        "assets" => [
          { "name" => "camoufox-mac.x86_64.zip", "browser_download_url" => "https://example.com/mac-x86.zip" },
          { "name" => "camoufox-mac.arm64.zip", "browser_download_url" => "https://example.com/mac-arm.zip" },
          { "name" => "camoufox-lin.x86_64.zip", "browser_download_url" => "https://example.com/lin-x86.zip" },
          { "name" => "camoufox-win.x86_64.zip", "browser_download_url" => "https://example.com/win-x86.zip" },
          { "name" => "camoufox-mac.arm64.tar.gz", "browser_download_url" => "https://example.com/mac-arm.tar.gz" }
        ]
      }
    end

    it "finds the matching ZIP asset for the current platform" do
      asset = described_class.find_matching_asset(mock_release)
      expect(asset).not_to be_nil
      expect(asset["name"]).to include(described_class.platform_string)
      expect(asset["name"]).to end_with(".zip")
    end

    it "does not match non-ZIP assets" do
      release = {
        "assets" => [
          { "name" => "camoufox-#{described_class.platform_string}.tar.gz", "browser_download_url" => "https://example.com/file.tar.gz" }
        ]
      }
      expect(described_class.find_matching_asset(release)).to be_nil
    end

    it "returns nil when no assets match" do
      release = { "assets" => [] }
      expect(described_class.find_matching_asset(release)).to be_nil
    end
  end

  describe "CAMOUFOX_CACHE_DIR env var" do
    around do |example|
      original = ENV["CAMOUFOX_CACHE_DIR"]
      example.run
    ensure
      if original
        ENV["CAMOUFOX_CACHE_DIR"] = original
      else
        ENV.delete("CAMOUFOX_CACHE_DIR")
      end
    end

    it "overrides the default cache directory" do
      ENV["CAMOUFOX_CACHE_DIR"] = "/custom/cache/path"
      expect(described_class.cache_dir).to eq("/custom/cache/path")
      expect(described_class.install_dir).to eq("/custom/cache/path")
    end

    it "uses the default when not set" do
      ENV.delete("CAMOUFOX_CACHE_DIR")
      expect(described_class.cache_dir).to include(Dir.home)
    end
  end

  describe ".version_string" do
    it "returns 'not installed' when no version.json exists" do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(File.join(described_class.install_dir, "version.json")).and_return(false)
      expect(described_class.version_string).to eq("not installed")
    end
  end
end
