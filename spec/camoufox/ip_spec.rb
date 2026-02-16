# frozen_string_literal: true

require "spec_helper"

RSpec.describe Camoufox::IP do
  describe ".valid_ipv4?" do
    it "accepts valid IPv4 addresses" do
      expect(described_class.valid_ipv4?("1.2.3.4")).to be true
      expect(described_class.valid_ipv4?("192.168.1.1")).to be true
      expect(described_class.valid_ipv4?("255.255.255.255")).to be true
    end

    it "rejects invalid IPv4 addresses" do
      expect(described_class.valid_ipv4?("999.1.1.1")).to be false
      expect(described_class.valid_ipv4?("abc")).to be false
      expect(described_class.valid_ipv4?(nil)).to be false
      expect(described_class.valid_ipv4?("")).to be false
    end
  end

  describe ".valid_ipv6?" do
    it "accepts valid IPv6 addresses" do
      expect(described_class.valid_ipv6?("::1")).to be true
      expect(described_class.valid_ipv6?("2001:0db8:85a3:0000:0000:8a2e:0370:7334")).to be true
      expect(described_class.valid_ipv6?("fe80::1")).to be true
    end

    it "rejects invalid IPv6 addresses" do
      expect(described_class.valid_ipv6?("1.2.3.4")).to be false
      expect(described_class.valid_ipv6?(nil)).to be false
      expect(described_class.valid_ipv6?("")).to be false
    end
  end
end
