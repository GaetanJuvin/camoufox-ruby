# frozen_string_literal: true

require "spec_helper"

RSpec.describe Camoufox::SyncAPI::Camoufox do
  let(:session) { instance_double("Camoufox::SyncAPI::NodeRunner::Session", close: nil) }

  before do
    allow(Camoufox::SyncAPI::NodeRunner::Session).to receive(:new).and_return(session)
    allow(session).to receive(:request).with('goto', anything).and_return({ 'title' => 'Example Domain', 'content' => '<html></html>' })
  end

  it "yields a browser when using .open" do
    described_class.open do |browser|
      page = browser.new_page
      page.goto('https://example.com')
      expect(page.title).to eq('Example Domain')
    end
  end

  it "returns a browser when no block is given and closes open pages" do
    browser = described_class.open
    page = browser.new_page
    page.goto('https://example.com')
    browser.close
    expect(session).to have_received(:close)
  ensure
    browser&.close
  end
end

RSpec.describe Camoufox::SyncAPI::Page do
  let(:session) { instance_double("Camoufox::SyncAPI::NodeRunner::Session", close: nil) }

  before do
    allow(Camoufox::SyncAPI::NodeRunner::Session).to receive(:new).and_return(session)
  end

  it "delegates wait_for_selector to the Node session" do
    allow(session).to receive(:request).and_return({ 'resolved' => true })

    page = described_class.new({})
    page.wait_for_selector('#root', timeout: 500, no_wait_after: true)

    expect(session).to have_received(:request).with(
      'wait_for_selector',
      hash_including(
        'selector' => '#root',
        'options' => hash_including('timeout' => 500, 'noWaitAfter' => true),
      ),
    )
  ensure
    page.close
  end

  it "invalidates cached content after waiting for a selector" do
    allow(session).to receive(:request).with('goto', anything).and_return({ 'title' => 'Example', 'content' => 'initial' })
    allow(session).to receive(:request).with('wait_for_selector', anything).and_return({ 'resolved' => true })

    page = described_class.new({})
    page.goto('https://example.com')
    expect(page.content).to eq('initial')

    page.wait_for_selector('#late-content')

    expect(session).to receive(:request).with('content').and_return({ 'content' => 'fresh' })
    expect(page.content).to eq('fresh')
  ensure
    page.close
  end
end
