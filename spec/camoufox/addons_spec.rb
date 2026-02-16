# frozen_string_literal: true

require "spec_helper"

RSpec.describe Camoufox::Addons do
  describe ".resolve" do
    it "returns an empty array for no addons" do
      expect(described_class.resolve([])).to eq([])
    end

    it "returns an empty array for nil" do
      expect(described_class.resolve(nil)).to eq([])
    end

    it "raises AddonError for missing directory" do
      expect {
        described_class.resolve(["/nonexistent/addon"])
      }.to raise_error(Camoufox::AddonError, /does not exist/)
    end

    it "raises AddonError for directory without manifest.json" do
      Dir.mktmpdir do |dir|
        expect {
          described_class.resolve([dir])
        }.to raise_error(Camoufox::AddonError, /missing manifest\.json/)
      end
    end

    it "accepts valid addon directories" do
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, "manifest.json"), "{}")
        result = described_class.resolve([dir])
        expect(result).to eq([dir])
      end
    end
  end
end
