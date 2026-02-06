# frozen_string_literal: true

require "spec_helper"
require "camoufox/mcp"

RSpec.describe Camoufox::MCP do
  describe ".server" do
    it "creates an MCP::Server with all tools registered" do
      server = described_class.server
      expect(server).to be_a(::MCP::Server)
    end
  end

  describe Camoufox::MCP::Session do
    let(:session) { described_class.new }
    let(:node_session) { instance_double("Camoufox::SyncAPI::NodeRunner::Session", close: nil) }
    let(:stub_options) { { executable_path: "/usr/bin/firefox", args: [], env: {}, headless: true } }

    before do
      allow(Camoufox::NativeBridge).to receive(:launch_options).and_return(stub_options)
      allow(Camoufox::SyncAPI::NodeRunner::Session).to receive(:new).and_return(node_session)
      allow(node_session).to receive(:request).and_return({})
    end

    it "starts with no browser or page" do
      expect(session.browser).to be_nil
      expect(session.page).to be_nil
    end

    it "launches a browser and creates a page" do
      session.launch(headless: true)
      expect(session.browser).to be_a(Camoufox::SyncAPI::Camoufox)
      expect(session.page).to be_a(Camoufox::SyncAPI::Page)
    ensure
      session.close
    end

    it "raises when ensure_ready! is called without launch" do
      expect { session.ensure_ready! }.to raise_error(Camoufox::Error, /not launched/)
    end

    it "closes the browser on close" do
      session.launch(headless: true)
      session.close
      expect(session.browser).to be_nil
      expect(session.page).to be_nil
    end
  end
end

RSpec.describe Camoufox::MCP::Tools do
  let(:mcp_session) { Camoufox::MCP::Session.new }
  let(:node_session) { instance_double("Camoufox::SyncAPI::NodeRunner::Session", close: nil) }
  let(:server_context) { { session: mcp_session } }
  let(:stub_options) { { executable_path: "/usr/bin/firefox", args: [], env: {}, headless: true } }

  before do
    allow(Camoufox::NativeBridge).to receive(:launch_options).and_return(stub_options)
    allow(Camoufox::SyncAPI::NodeRunner::Session).to receive(:new).and_return(node_session)
    allow(node_session).to receive(:request).and_return({})
  end

  describe Camoufox::MCP::Tools::Launch do
    it "launches the browser session" do
      result = described_class.call(headless: true, server_context: server_context)
      expect(result).to be_a(::MCP::Tool::Response)
      expect(mcp_session.browser).not_to be_nil
    ensure
      mcp_session.close
    end
  end

  describe Camoufox::MCP::Tools::Goto do
    it "raises when browser is not launched" do
      expect {
        described_class.call(url: "https://example.com", server_context: server_context)
      }.to raise_error(Camoufox::Error, /not launched/)
    end

    it "navigates to the given URL" do
      allow(node_session).to receive(:request).with('goto', anything).and_return({ 'title' => 'Example', 'content' => '<html></html>' })

      mcp_session.launch(headless: true)
      result = described_class.call(url: "https://example.com", server_context: server_context)
      expect(result).to be_a(::MCP::Tool::Response)
    ensure
      mcp_session.close
    end
  end

  describe Camoufox::MCP::Tools::GetContent do
    it "returns page HTML content" do
      allow(node_session).to receive(:request).with('goto', anything).and_return({ 'title' => 'Test', 'content' => '<html><body>Hello</body></html>' })

      mcp_session.launch(headless: true)
      mcp_session.page.goto("https://example.com")
      result = described_class.call(server_context: server_context)
      expect(result).to be_a(::MCP::Tool::Response)
    ensure
      mcp_session.close
    end
  end

  describe Camoufox::MCP::Tools::GetTitle do
    it "returns page title" do
      allow(node_session).to receive(:request).with('goto', anything).and_return({ 'title' => 'My Title', 'content' => '<html></html>' })

      mcp_session.launch(headless: true)
      mcp_session.page.goto("https://example.com")
      result = described_class.call(server_context: server_context)
      expect(result).to be_a(::MCP::Tool::Response)
    ensure
      mcp_session.close
    end
  end

  describe Camoufox::MCP::Tools::Evaluate do
    it "evaluates JavaScript and returns the result" do
      allow(node_session).to receive(:request).with('evaluate', hash_including('expression' => '() => 42')).and_return({ 'value' => 42 })

      mcp_session.launch(headless: true)
      result = described_class.call(expression: "() => 42", server_context: server_context)
      expect(result).to be_a(::MCP::Tool::Response)
    ensure
      mcp_session.close
    end
  end

  describe Camoufox::MCP::Tools::WaitForSelector do
    it "waits for the selector and returns success" do
      allow(node_session).to receive(:request).with('wait_for_selector', anything).and_return({ 'resolved' => true })

      mcp_session.launch(headless: true)
      result = described_class.call(selector: "#content", server_context: server_context)
      expect(result).to be_a(::MCP::Tool::Response)
    ensure
      mcp_session.close
    end
  end

  describe Camoufox::MCP::Tools::Screenshot do
    it "returns an image response" do
      allow(node_session).to receive(:request).with('screenshot', anything).and_return({ 'data' => 'iVBORw0KGgo=' })

      mcp_session.launch(headless: true)
      result = described_class.call(server_context: server_context)
      expect(result).to be_a(::MCP::Tool::Response)
    ensure
      mcp_session.close
    end
  end

  describe Camoufox::MCP::Tools::Close do
    it "closes the browser session" do
      mcp_session.launch(headless: true)
      result = described_class.call(server_context: server_context)
      expect(result).to be_a(::MCP::Tool::Response)
      expect(mcp_session.browser).to be_nil
    end
  end
end
