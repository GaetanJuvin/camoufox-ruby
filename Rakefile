# frozen_string_literal: true

require "bundler/setup"
require "rake/extensiontask"

Rake::ExtensionTask.new("camoufox_native") do |ext|
  ext.lib_dir = "lib"
end

task default: :compile
