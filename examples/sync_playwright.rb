# frozen_string_literal: true

require "bundler/setup"
require "camoufox"

# Ensure Playwright driver is available. Defaults to node_modules/playwright.
playwright_dir = ENV.fetch("CAMOUFOX_PLAYWRIGHT_DRIVER_DIR", File.expand_path("../node_modules/playwright", __dir__))

Camoufox.configure do |config|
  config.playwright_driver_dir = playwright_dir
  config.node_path = ENV["CAMOUFOX_NODE_PATH"] if ENV["CAMOUFOX_NODE_PATH"]
end

Camoufox::SyncAPI::Camoufox.open(headless: true) do |browser|
  page = browser.new_page
  page.goto("https://example.com")
  puts "Title: #{page.title}"
end
