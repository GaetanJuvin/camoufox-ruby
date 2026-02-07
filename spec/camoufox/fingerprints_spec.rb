# frozen_string_literal: true

require "spec_helper"

RSpec.describe Camoufox::Fingerprints do
  describe ".generate" do
    subject(:config) { described_class.generate }

    it "returns a Hash" do
      expect(config).to be_a(Hash)
    end

    it "includes navigator.userAgent with Firefox version" do
      expect(config["navigator.userAgent"]).to match(/Firefox\/\d+\.0$/)
    end

    it "includes navigator.platform" do
      expect(config["navigator.platform"]).to eq("MacIntel")
    end

    it "includes navigator.hardwareConcurrency from valid set" do
      expect(Camoufox::Fingerprints::HARDWARE_CONCURRENCIES).to include(config["navigator.hardwareConcurrency"])
    end

    it "has consistent screen dimensions" do
      expect(config["screen.availWidth"]).to eq(config["screen.width"])
      expect(config["screen.availHeight"]).to be < config["screen.height"]
    end

    it "has window dimensions smaller than or equal to screen" do
      expect(config["window.outerWidth"]).to be <= config["screen.availWidth"]
      expect(config["window.outerHeight"]).to be <= config["screen.availHeight"]
      expect(config["window.innerWidth"]).to be <= config["window.outerWidth"]
      expect(config["window.innerHeight"]).to be < config["window.outerHeight"]
    end

    it "has matching document.body.clientWidth to window.innerWidth" do
      expect(config["document.body.clientWidth"]).to eq(config["window.innerWidth"])
      expect(config["document.body.clientHeight"]).to eq(config["window.innerHeight"])
    end

    it "has a valid WebGL vendor and renderer" do
      expect(config["webGl:vendor"]).to eq("Apple")
      expect(config["webGl:renderer"]).to be_a(String)
      expect(config["webGl:renderer"]).not_to be_empty
    end

    it "has WebGL extensions as arrays" do
      expect(config["webGl:supportedExtensions"]).to be_an(Array)
      expect(config["webGl:supportedExtensions"]).not_to be_empty
      expect(config["webGl2:supportedExtensions"]).to be_an(Array)
    end

    it "has canvas:aaOffset in range -50..50" do
      expect(config["canvas:aaOffset"]).to be_between(-50, 50)
    end

    it "has battery values in valid ranges" do
      expect(config["battery:level"]).to be_between(0.0, 1.0)
      expect([true, false]).to include(config["battery:charging"])
    end

    it "has valid audio context values" do
      expect([44100, 48000]).to include(config["AudioContext:sampleRate"])
      expect(config["AudioContext:maxChannelCount"]).to eq(2)
      expect(config["AudioContext:outputLatency"]).to be_between(0.0, 0.02)
    end

    it "includes fonts as a non-empty array" do
      expect(config["fonts"]).to be_an(Array)
      expect(config["fonts"]).not_to be_empty
    end

    it "includes media devices" do
      expect(config["mediaDevices:micros"]).to eq(1)
      expect(config["mediaDevices:webcams"]).to eq(1)
      expect(config["mediaDevices:speakers"]).to eq(1)
      expect(config["mediaDevices:enabled"]).to eq(true)
    end

    it "matches headers.User-Agent to navigator.userAgent" do
      expect(config["headers.User-Agent"]).to eq(config["navigator.userAgent"])
    end

    it "includes locale" do
      expect(config["locale:language"]).to eq("en-US")
      expect(config["locale:region"]).to eq("US")
    end

    it "has colorDepth matching pixelDepth" do
      expect(config["screen.colorDepth"]).to eq(config["screen.pixelDepth"])
    end

    it "has devicePixelRatio as 1.0 or 2.0" do
      expect([1.0, 2.0]).to include(config["window.devicePixelRatio"])
    end
  end

  describe ".generate with overrides" do
    it "respects locale:language override" do
      config = described_class.generate("locale:language" => "fr-FR", "locale:region" => "FR")
      expect(config["locale:language"]).to eq("fr-FR")
      expect(config["locale:region"]).to eq("FR")
      expect(config["navigator.language"]).to eq("fr-FR")
    end

    it "respects locale:region override" do
      config = described_class.generate("locale:region" => "GB")
      expect(config["locale:region"]).to eq("GB")
    end
  end

  describe ".firefox_version" do
    it "returns a version string" do
      version = described_class.firefox_version
      expect(version).to match(/\A\d+\z/)
    end
  end
end
