# frozen_string_literal: true

require "bundler/setup"
require "camoufox"

# Use the local Playwright installation by default.
playwright_dir = ENV.fetch("CAMOUFOX_PLAYWRIGHT_DRIVER_DIR", File.expand_path("../node_modules/playwright", __dir__))

Camoufox.configure do |config|
  config.playwright_driver_dir = playwright_dir
  config.node_path = ENV["CAMOUFOX_NODE_PATH"] if ENV["CAMOUFOX_NODE_PATH"]
end

Camoufox::SyncAPI::Camoufox.open(headless: true) do |browser|
  page = browser.new_page
  page.goto("https://example.com")

  summary = page.evaluate(<<~'JS') || {}
    () => ({
      url: window.location.href,
      title: document.title,
      heading: document.querySelector('h1')?.textContent || null,
      linkCount: document.querySelectorAll('a').length,
    })
  JS

  sum = page.evaluate('(a, b) => a + b', 40, 2)

  puts "Summary: #{summary.inspect}"
  puts "Title: #{summary['title']}"
  puts "Heading: #{summary['heading']}"
  puts "Link count: #{summary['linkCount']}"
  puts "URL: #{summary['url']}"
  puts "40 + 2 = #{sum}"
end
