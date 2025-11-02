# frozen_string_literal: true

require "camoufox"

driver_dir = ENV['CAMOUFOX_PLAYWRIGHT_DRIVER_DIR'] or abort "Set CAMOUFOX_PLAYWRIGHT_DRIVER_DIR to the Playwright driver directory"

Camoufox.configure do |config|
  config.playwright_driver_dir = driver_dir
  config.node_path = ENV['CAMOUFOX_NODE_PATH'] if ENV['CAMOUFOX_NODE_PATH']
end

Camoufox::SyncAPI::Camoufox.open(headless: true) do |browser|
  page = browser.new_page
  page.goto("https://example.com")
  puts "Title: #{page.title}"
end
