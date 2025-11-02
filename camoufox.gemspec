# frozen_string_literal: true

require_relative "lib/camoufox/__version__"

Gem::Specification.new do |spec|
  spec.name          = "camoufox"
  spec.version       = Camoufox::VERSION
  spec.authors       = ["Camoufox contributors"]
  spec.email         = ["opensource@camoufox.dev"]

  spec.summary       = "Native rewrite of the Camoufox stealth Firefox toolkit"
  spec.description   = "Reimplements the pythonlib/camoufox package structure in Ruby with a native extension stub while the full feature set is ported over."
  spec.homepage      = "https://github.com/daijro/camoufox"
  spec.license       = "MIT"

  spec.required_ruby_version = Gem::Requirement.new(">= 3.0")

  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => "https://github.com/daijro/camoufox-ruby",
    "changelog_uri" => "https://github.com/daijro/camoufox-ruby/blob/main/CHANGELOG.md"
  }

  spec.files = Dir.glob("lib/**/*", File::FNM_DOTMATCH).select { |f| File.file?(f) }
  spec.files += Dir.glob("ext/**/*", File::FNM_DOTMATCH).select { |f| File.file?(f) }
  spec.files += Dir.glob("docs/**/*", File::FNM_DOTMATCH).select { |f| File.file?(f) }
  spec.files += %w[README.md LICENSE Gemfile CHANGELOG.md]
  spec.executables = Dir.children("bin").map { |f| f if File.executable?(File.join("bin", f)) }.compact
  spec.require_paths = ["lib"]
  spec.extensions = ["ext/camoufox_native/extconf.rb"]

  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "rubocop", "~> 1.60"
  spec.add_development_dependency "rake-compiler", "~> 1.2"
end
