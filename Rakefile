# frozen_string_literal: true

require "bundler/setup"
require "rake/extensiontask"

Rake::ExtensionTask.new("camoufox_native") do |ext|
  ext.lib_dir = "lib"
end

task default: :compile

namespace :camoufox do
  desc "Download the Camoufox binary for the current platform"
  task :fetch do
    require "camoufox"
    Camoufox::Pkgman.install
  end

  desc "Remove the downloaded Camoufox binary"
  task :remove do
    require "camoufox"
    Camoufox::Pkgman.remove
  end

  desc "Print the Camoufox executable path"
  task :path do
    require "camoufox"
    puts Camoufox::Pkgman.executable_path
  end
end
