# frozen_string_literal: true

require "net/http"
require "uri"

module Camoufox
  module IP
    IP_SERVICES = %w[
      https://api.ipify.org
      https://checkip.amazonaws.com
      https://ipinfo.io/ip
    ].freeze

    IPV4_REGEX = /\A(\d{1,3}\.){3}\d{1,3}\z/
    IPV6_REGEX = /\A[\da-fA-F:]+\z/

    module_function

    def public_ip(proxy: nil)
      IP_SERVICES.each do |service_url|
        ip = fetch_ip(service_url, proxy: proxy)
        return ip if ip
      rescue StandardError
        next
      end

      raise GeoIPError, "Failed to detect public IP from any service"
    end

    def valid_ipv4?(ip)
      return false unless ip.is_a?(String)
      return false unless IPV4_REGEX.match?(ip)

      ip.split(".").all? { |octet| octet.to_i.between?(0, 255) }
    end

    def valid_ipv6?(ip)
      return false unless ip.is_a?(String)

      IPV6_REGEX.match?(ip) && ip.include?(":")
    end

    def ipv4?(ip)
      valid_ipv4?(ip)
    end

    def ipv6?(ip)
      valid_ipv6?(ip)
    end

    def fetch_ip(service_url, proxy: nil)
      uri = URI(service_url)

      http = if proxy
               proxy_uri = URI(proxy.is_a?(Hash) ? proxy[:server] : proxy)
               Net::HTTP.new(uri.host, uri.port, proxy_uri.host, proxy_uri.port)
             else
               Net::HTTP.new(uri.host, uri.port)
             end

      if uri.scheme == "https"
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      end

      http.open_timeout = 5
      http.read_timeout = 5

      response = http.start { |h| h.request(Net::HTTP::Get.new(uri)) }
      return nil unless response.is_a?(Net::HTTPSuccess)

      ip = response.body.strip
      return ip if valid_ipv4?(ip) || valid_ipv6?(ip)

      nil
    end

    def geolocate(ip)
      uri = URI("https://ipapi.co/#{ip}/json/")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      http.open_timeout = 5
      http.read_timeout = 5

      response = http.start { |h| h.request(Net::HTTP::Get.new(uri)) }
      raise GeoIPError, "GeoIP lookup failed: #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      data = JSON.parse(response.body)
      raise GeoIPError, "GeoIP lookup returned error: #{data['reason']}" if data["error"]

      {
        country: data["country_code"],
        latitude: data["latitude"],
        longitude: data["longitude"],
        timezone: data["timezone"],
        city: data["city"],
        region: data["region"],
      }
    end
  end
end
