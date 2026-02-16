# frozen_string_literal: true

module Camoufox
  module Addons
    module_function

    def resolve(addon_paths)
      paths = Array(addon_paths).dup
      validate!(paths) unless paths.empty?
      paths
    end

    def validate!(paths)
      paths.each do |p|
        unless File.directory?(p)
          raise AddonError, "Addon directory does not exist: #{p}"
        end

        unless File.exist?(File.join(p, "manifest.json"))
          raise AddonError, "Addon missing manifest.json: #{p}"
        end
      end
    end
  end
end
