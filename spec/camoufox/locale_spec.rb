# frozen_string_literal: true

require "spec_helper"

RSpec.describe Camoufox::Locale do
  describe ".handle" do
    it "sets locale fields from a single locale string" do
      config = {}
      described_class.handle("fr-FR", config)

      expect(config["locale:language"]).to eq("fr-FR")
      expect(config["locale:region"]).to eq("FR")
      expect(config["locale:all"]).to eq("fr-FR")
      expect(config["navigator.language"]).to eq("fr-FR")
    end

    it "sets locale fields from an array of locales" do
      config = {}
      described_class.handle(["en-US", "fr-FR"], config)

      expect(config["locale:language"]).to eq("en-US")
      expect(config["locale:all"]).to eq("en-US,fr-FR")
      expect(config["navigator.languages"]).to include("en-US", "fr-FR")
    end

    it "returns config unchanged for nil input" do
      config = { "foo" => "bar" }
      described_class.handle(nil, config)
      expect(config).to eq({ "foo" => "bar" })
    end

    it "builds Accept-Language header with quality values" do
      config = {}
      described_class.handle(["en-US", "fr-FR", "de-DE"], config)
      expect(config["headers.Accept-Language"]).to eq("en-US,fr-FR;q=0.9,de-DE;q=0.8")
    end
  end

  describe ".from_country" do
    it "returns locale for known country" do
      expect(described_class.from_country("FR")).to eq("fr-FR")
      expect(described_class.from_country("US")).to eq("en-US")
      expect(described_class.from_country("JP")).to eq("ja-JP")
    end

    it "returns en-US for unknown country" do
      expect(described_class.from_country("XX")).to eq("en-US")
    end

    it "handles lowercase country codes" do
      expect(described_class.from_country("fr")).to eq("fr-FR")
    end
  end

  describe ".normalize" do
    it "wraps string in array" do
      expect(described_class.normalize("en-US")).to eq(["en-US"])
    end

    it "passes arrays through" do
      expect(described_class.normalize(["en-US", "fr-FR"])).to eq(["en-US", "fr-FR"])
    end

    it "returns empty array for nil" do
      expect(described_class.normalize(nil)).to eq([])
    end
  end
end
