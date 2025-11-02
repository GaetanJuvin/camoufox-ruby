# frozen_string_literal: true

require "spec_helper"

RSpec.describe Camoufox::SyncAPI::Camoufox do
  before do
    allow(Camoufox::SyncAPI::NodeRunner).to receive(:visit).and_return({ 'title' => 'Example Domain' })
  end

  it "yields a browser when using .open" do
    described_class.open do |browser|
      page = browser.new_page
      page.goto('https://example.com')
      expect(page.title).to eq('Example Domain')
    end
  end

  it "returns a browser when no block is given" do
    browser = described_class.open
    expect(browser).to be_a(described_class)
  ensure
    browser&.close
  end
end
