# frozen_string_literal: true

module Camoufox
  module Locale
    COUNTRY_LANGUAGE = {
      "US" => "en-US", "GB" => "en-GB", "AU" => "en-AU", "CA" => "en-CA",
      "NZ" => "en-NZ", "IE" => "en-IE", "ZA" => "en-ZA", "IN" => "en-IN",
      "FR" => "fr-FR", "BE" => "fr-BE", "CH" => "fr-CH", "LU" => "fr-LU",
      "DE" => "de-DE", "AT" => "de-AT",
      "ES" => "es-ES", "MX" => "es-MX", "AR" => "es-AR", "CO" => "es-CO",
      "CL" => "es-CL", "PE" => "es-PE", "VE" => "es-VE",
      "PT" => "pt-PT", "BR" => "pt-BR",
      "IT" => "it-IT",
      "NL" => "nl-NL",
      "PL" => "pl-PL",
      "RU" => "ru-RU",
      "UA" => "uk-UA",
      "JP" => "ja-JP",
      "KR" => "ko-KR",
      "CN" => "zh-CN", "TW" => "zh-TW", "HK" => "zh-HK",
      "TR" => "tr-TR",
      "SE" => "sv-SE",
      "NO" => "nb-NO",
      "DK" => "da-DK",
      "FI" => "fi-FI",
      "CZ" => "cs-CZ",
      "RO" => "ro-RO",
      "HU" => "hu-HU",
      "GR" => "el-GR",
      "TH" => "th-TH",
      "VN" => "vi-VN",
      "ID" => "id-ID",
      "MY" => "ms-MY",
      "PH" => "fil-PH",
      "SA" => "ar-SA", "EG" => "ar-EG", "AE" => "ar-AE",
      "IL" => "he-IL",
      "IR" => "fa-IR",
      "PK" => "ur-PK",
      "BD" => "bn-BD",
      "NG" => "en-NG",
      "KE" => "sw-KE",
    }.freeze

    module_function

    def handle(locale_input, config)
      locales = normalize(locale_input)
      return config if locales.empty?

      primary = locales.first
      parts = primary.split("-")
      language = parts[0]
      region = parts[1] || ""

      config["locale:language"] = primary
      config["locale:region"] = region
      config["locale:all"] = locales.join(",")
      config["navigator.language"] = primary
      config["navigator.languages"] = locales.flat_map { |l| [l, l.split("-").first] }.uniq
      config["headers.Accept-Language"] = build_accept_language(locales)

      config
    end

    def from_country(country_code)
      COUNTRY_LANGUAGE.fetch(country_code.to_s.upcase, "en-US")
    end

    def normalize(input)
      case input
      when nil then []
      when String then [input]
      when Array then input.map(&:to_s)
      else [input.to_s]
      end
    end

    def build_accept_language(locales)
      parts = []
      locales.each_with_index do |locale, i|
        if i == 0
          parts << locale
        else
          q = (1.0 - i * 0.1).round(1)
          q = 0.1 if q < 0.1
          parts << "#{locale};q=#{q}"
        end
      end
      parts.join(",")
    end
  end
end
