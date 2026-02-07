# frozen_string_literal: true

require "net/http"
require "openssl"
require "json"
require "fileutils"
require "zip"

module Camoufox
  module Pkgman
    GITHUB_REPO = "daijro/camoufox"

    module_function

    def os_name
      case RbConfig::CONFIG["host_os"]
      when /darwin/i then "mac"
      when /linux/i  then "lin"
      when /mingw|mswin|cygwin/i then "win"
      else
        raise Error, "Unsupported OS: #{RbConfig::CONFIG['host_os']}"
      end
    end

    def arch_name
      cpu = RbConfig::CONFIG["host_cpu"]
      case cpu
      when /x86_64|x64|amd64/i then "x86_64"
      when /aarch64|arm64/i    then "arm64"
      when /i[3-6]86/i         then "i686"
      else
        raise Error, "Unsupported architecture: #{cpu}"
      end
    end

    def platform_string
      "#{os_name}.#{arch_name}"
    end

    def cache_dir
      if (custom = ENV["CAMOUFOX_CACHE_DIR"])
        return custom
      end

      case os_name
      when "mac"
        File.join(Dir.home, "Library", "Caches", "camoufox")
      when "lin"
        File.join(ENV.fetch("XDG_CACHE_HOME", File.join(Dir.home, ".cache")), "camoufox")
      when "win"
        File.join(ENV.fetch("LOCALAPPDATA", File.join(Dir.home, "AppData", "Local")), "camoufox")
      end
    end

    def install_dir
      cache_dir
    end

    def executable_path
      case os_name
      when "mac"
        File.join(install_dir, "Camoufox.app", "Contents", "MacOS", "camoufox")
      when "lin"
        File.join(install_dir, "camoufox-bin")
      when "win"
        File.join(install_dir, "camoufox.exe")
      end
    end

    def installed?
      File.exist?(executable_path) && File.exist?(File.join(install_dir, "version.json"))
    end

    def ensure_installed!
      install unless installed?
    end

    def install
      FileUtils.mkdir_p(install_dir)

      release = fetch_latest_release
      asset = find_matching_asset(release)
      raise Error, "No matching Camoufox binary for #{platform_string}" unless asset

      zip_path = File.join(install_dir, asset["name"])
      download_file(asset["browser_download_url"], zip_path)
      extract_zip(zip_path, install_dir)
      FileUtils.rm_f(zip_path)

      if os_name != "win"
        FileUtils.chmod(0o755, executable_path) if File.exist?(executable_path)
      end

      version_info = { "version" => release["tag_name"], "asset" => asset["name"] }
      File.write(File.join(install_dir, "version.json"), JSON.pretty_generate(version_info))

      warn("[camoufox] Installed #{release['tag_name']} to #{install_dir}")
      true
    end

    def remove
      if Dir.exist?(install_dir)
        FileUtils.rm_rf(install_dir)
        warn("[camoufox] Removed #{install_dir}")
        true
      else
        warn("[camoufox] Nothing to remove at #{install_dir}")
        false
      end
    end

    def version_string
      version_file = File.join(install_dir, "version.json")
      return "not installed" unless File.exist?(version_file)

      data = JSON.parse(File.read(version_file))
      data["version"] || "unknown"
    end

    def http_get(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      if uri.scheme == "https"
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        store = OpenSSL::X509::Store.new
        store.set_default_paths
        http.cert_store = store
      end
      http.start { |h| h.request(Net::HTTP::Get.new(uri)) }
    end

    def fetch_latest_release
      uri = URI("https://api.github.com/repos/#{GITHUB_REPO}/releases/latest")
      response = http_get(uri)
      raise Error, "GitHub API error: #{response.code} #{response.message}" unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    end

    def find_matching_asset(release)
      pattern = platform_string
      release["assets"]&.find { |a| a["name"]&.include?(pattern) && a["name"]&.end_with?(".zip") }
    end

    def download_file(url, dest)
      uri = URI(url)
      max_redirects = 5
      redirects = 0

      loop do
        response = http_get(uri)

        case response
        when Net::HTTPSuccess
          File.binwrite(dest, response.body)
          return
        when Net::HTTPRedirection
          redirects += 1
          raise Error, "Too many redirects downloading #{url}" if redirects > max_redirects
          uri = URI(response["location"])
        else
          raise Error, "Download failed: #{response.code} #{response.message}"
        end
      end
    end

    def extract_zip(zip_path, dest_dir)
      Zip::File.open(zip_path) do |zip_file|
        zip_file.each do |entry|
          target = File.join(dest_dir, entry.name)
          FileUtils.mkdir_p(File.dirname(target))
          entry.extract(target) { true }
        end
      end
    end
  end
end
