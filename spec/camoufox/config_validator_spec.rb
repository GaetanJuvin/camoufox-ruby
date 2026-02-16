# frozen_string_literal: true

require "spec_helper"
require "tmpdir"

RSpec.describe Camoufox::ConfigValidator do
  describe ".validate!" do
    it "does not warn when properties.json is missing" do
      allow(Camoufox::Pkgman).to receive(:install_dir).and_return("/nonexistent")
      expect(Kernel).not_to receive(:warn)
      described_class.validate!({ "navigator.userAgent" => "test" })
    end

    it "warns about unknown config keys when properties.json exists" do
      Dir.mktmpdir do |dir|
        props = [{ "property" => "navigator.userAgent" }]
        File.write(File.join(dir, "properties.json"), JSON.generate(props))
        allow(Camoufox::Pkgman).to receive(:install_dir).and_return(dir)

        expect(Kernel).to receive(:warn).with(/Unknown config keys.*unknownKey/)
        described_class.validate!({ "navigator.userAgent" => "test", "unknownKey" => "value" })
      end
    end

    it "does not warn when all keys are known" do
      Dir.mktmpdir do |dir|
        props = [{ "property" => "navigator.userAgent" }, { "property" => "fonts" }]
        File.write(File.join(dir, "properties.json"), JSON.generate(props))
        allow(Camoufox::Pkgman).to receive(:install_dir).and_return(dir)

        expect(Kernel).not_to receive(:warn)
        described_class.validate!({ "navigator.userAgent" => "test", "fonts" => [] })
      end
    end
  end
end
