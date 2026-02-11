# frozen_string_literal: true

require "json"

module Camoufox
  module Fingerprints
    SCREENS = [
      { width: 1920, height: 1080 },
      { width: 2560, height: 1440 },
      { width: 1512, height: 982 },
      { width: 1440, height: 900 },
      { width: 1680, height: 1050 },
      { width: 1280, height: 800 }
    ].freeze

    HARDWARE_CONCURRENCIES = [4, 8, 10, 12, 16].freeze

    APPLE_GPUS = [
      "Apple M1",
      "Apple M1 Pro",
      "Apple M1 Max",
      "Apple M1 Ultra",
      "Apple M2",
      "Apple M2 Pro",
      "Apple M2 Max",
      "Apple M2 Ultra",
      "Apple M3",
      "Apple M3 Pro",
      "Apple M3 Max",
      "Apple M4",
      "Apple M4 Pro",
      "Apple M4 Max"
    ].freeze

    WEBGL_EXTENSIONS = %w[
      ANGLE_instanced_arrays
      EXT_blend_minmax
      EXT_color_buffer_half_float
      EXT_float_blend
      EXT_frag_depth
      EXT_shader_texture_lod
      EXT_sRGB
      EXT_texture_compression_bptc
      EXT_texture_compression_rgtc
      EXT_texture_filter_anisotropic
      OES_element_index_uint
      OES_fbo_render_mipmap
      OES_standard_derivatives
      OES_texture_float
      OES_texture_float_linear
      OES_texture_half_float
      OES_texture_half_float_linear
      OES_vertex_array_object
      WEBGL_color_buffer_float
      WEBGL_compressed_texture_astc
      WEBGL_compressed_texture_etc
      WEBGL_compressed_texture_s3tc
      WEBGL_compressed_texture_s3tc_srgb
      WEBGL_debug_renderer_info
      WEBGL_debug_shaders
      WEBGL_depth_texture
      WEBGL_draw_buffers
      WEBGL_lose_context
      WEBGL_provoking_vertex
    ].freeze

    WEBGL2_EXTENSIONS = %w[
      EXT_color_buffer_float
      EXT_color_buffer_half_float
      EXT_float_blend
      EXT_texture_compression_bptc
      EXT_texture_compression_rgtc
      EXT_texture_filter_anisotropic
      EXT_texture_norm16
      OES_draw_buffers_indexed
      OES_texture_float_linear
      WEBGL_compressed_texture_astc
      WEBGL_compressed_texture_etc
      WEBGL_compressed_texture_s3tc
      WEBGL_compressed_texture_s3tc_srgb
      WEBGL_debug_renderer_info
      WEBGL_debug_shaders
      WEBGL_lose_context
      WEBGL_provoking_vertex
    ].freeze

    MACOS_FONTS = [
      "Academy Engraved LET",
      "Al Bayan", "Al Nile", "Al Tarikh",
      "American Typewriter",
      "Andale Mono",
      "Apple Braille", "Apple Chancery", "Apple Color Emoji",
      "Apple SD Gothic Neo", "Apple Symbols",
      "AppleGothic", "AppleMyungjo",
      "Arial", "Arial Black", "Arial Hebrew", "Arial Narrow",
      "Arial Rounded MT Bold", "Arial Unicode MS",
      "Avenir", "Avenir Next", "Avenir Next Condensed",
      "Baskerville",
      "Big Caslon",
      "Bodoni 72", "Bodoni 72 Oldstyle", "Bodoni 72 Smallcaps",
      "Bodoni Ornaments",
      "Bradley Hand",
      "Brush Script MT",
      "Chalkboard", "Chalkboard SE", "Chalkduster",
      "Charter",
      "Cochin", "Comic Sans MS",
      "Copperplate",
      "Corsiva Hebrew",
      "Courier", "Courier New",
      "Damascus",
      "DecoType Naskh",
      "Devanagari MT", "Devanagari Sangam MN",
      "Didot",
      "DIN Alternate", "DIN Condensed",
      "Euphemia UCAS",
      "Futura",
      "Galvji",
      "Geeza Pro",
      "Geneva",
      "Georgia",
      "Gill Sans",
      "Gujarati MT", "Gujarati Sangam MN",
      "Gurmukhi MN", "Gurmukhi Sangam MN",
      "Heiti SC", "Heiti TC",
      "Helvetica", "Helvetica Neue",
      "Herculanum",
      "Hiragino Kaku Gothic Pro", "Hiragino Kaku Gothic ProN",
      "Hiragino Maru Gothic ProN",
      "Hiragino Mincho ProN", "Hiragino Sans",
      "Hoefler Text",
      "Impact",
      "InaiMathi",
      "Kailasa",
      "Kannada MN", "Kannada Sangam MN",
      "Kefa",
      "Khmer MN", "Khmer Sangam MN",
      "Kohinoor Bangla", "Kohinoor Devanagari", "Kohinoor Gujarati", "Kohinoor Telugu",
      "Kokonor",
      "Krungthep",
      "KufiStandardGK",
      "Lao MN", "Lao Sangam MN",
      "Lucida Grande",
      "Luminari",
      "Malayalam MN", "Malayalam Sangam MN",
      "Marker Felt",
      "Menlo",
      "Microsoft Sans Serif",
      "Mishafi", "Mishafi Gold",
      "Monaco",
      "Mshtakan",
      "Mukta Mahee",
      "Muna",
      "Myanmar MN", "Myanmar Sangam MN",
      "Nadeem",
      "New Peninim MT",
      "Noteworthy",
      "Noto Nastaliq Urdu", "Noto Sans Kannada", "Noto Sans Myanmar", "Noto Sans Oriya",
      "Noto Serif Myanmar",
      "Optima",
      "Oriya MN", "Oriya Sangam MN",
      "Palatino",
      "Papyrus",
      "Party LET",
      "Phosphate",
      "PingFang HK", "PingFang SC", "PingFang TC",
      "Plantagenet Cherokee",
      "PT Mono", "PT Sans", "PT Sans Caption", "PT Sans Narrow", "PT Serif", "PT Serif Caption",
      "Raanana",
      "Rockwell",
      "Sana",
      "Sathu",
      "Savoye LET",
      "Shree Devanagari 714",
      "SignPainter",
      "Silom",
      "Sinhala MN", "Sinhala Sangam MN",
      "Skia",
      "Snell Roundhand",
      "Songti SC", "Songti TC",
      "STIXGeneral", "STIXIntegralsD", "STIXIntegralsSm", "STIXIntegralsUp",
      "STIXIntegralsUpD", "STIXIntegralsUpSm", "STIXNonUnicode", "STIXSizeFiveSym",
      "STIXSizeFourSym", "STIXSizeOneSym", "STIXSizeThreeSym", "STIXSizeTwoSym",
      "STIXVariants",
      "STSong",
      "Sukhumvit Set",
      "Symbol",
      "Tahoma",
      "Tamil MN", "Tamil Sangam MN",
      "Telugu MN", "Telugu Sangam MN",
      "Thonburi",
      "Times", "Times New Roman",
      "Trebuchet MS",
      "Verdana",
      "Waseem",
      "Webdings",
      "Wingdings", "Wingdings 2", "Wingdings 3",
      "Zapf Dingbats", "Zapfino"
    ].freeze

    module_function

    def generate(options = {})
      ff_version = firefox_version
      screen = SCREENS.sample
      cores = HARDWARE_CONCURRENCIES.sample
      dpr = [1.0, 2.0].sample
      color_depth = [24, 30].sample
      gpu = APPLE_GPUS.sample

      menubar_height = 25
      toolbar_height = rand(72..88)
      screen_w = screen[:width]
      screen_h = screen[:height]
      avail_w = screen_w
      avail_h = screen_h - menubar_height
      outer_w = avail_w - rand(0..100)
      outer_h = avail_h - rand(0..50)
      inner_w = outer_w
      inner_h = outer_h - toolbar_height
      screen_x = rand(0..100)
      screen_y = rand(menubar_height..menubar_height + 50)

      charging = [true, false].sample
      battery_level = (rand(20..100) / 100.0).round(2)
      discharging_time = charging ? 0.0 : rand(1800..36000).to_f

      sample_rate = [44100, 48000].sample
      output_latency = (rand(1..15) / 1000.0).round(6)

      language = options.fetch("locale:language", "en-US")
      region = options.fetch("locale:region", "US")

      config = {
        # Navigator
        "navigator.userAgent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:#{ff_version}.0) Gecko/20100101 Firefox/#{ff_version}.0",
        "navigator.appVersion" => "5.0 (Macintosh)",
        "navigator.platform" => "MacIntel",
        "navigator.oscpu" => "Intel Mac OS X 10.15",
        "navigator.hardwareConcurrency" => cores,
        "navigator.language" => language,
        "navigator.languages" => [language, language.split("-").first].uniq,
        "navigator.product" => "Gecko",
        "navigator.productSub" => "20100101",
        "navigator.appCodeName" => "Mozilla",
        "navigator.appName" => "Netscape",
        "navigator.buildID" => "20181001000000",
        "navigator.doNotTrack" => "unspecified",
        "navigator.maxTouchPoints" => 0,
        "navigator.cookieEnabled" => true,
        "navigator.globalPrivacyControl" => false,
        "navigator.onLine" => true,

        # Screen
        "screen.width" => screen_w,
        "screen.height" => screen_h,
        "screen.availWidth" => avail_w,
        "screen.availHeight" => avail_h,
        "screen.availTop" => menubar_height,
        "screen.availLeft" => 0,
        "screen.colorDepth" => color_depth,
        "screen.pixelDepth" => color_depth,
        "screen.pageXOffset" => 0.0,
        "screen.pageYOffset" => 0.0,

        # Window
        "window.outerWidth" => outer_w,
        "window.outerHeight" => outer_h,
        "window.innerWidth" => inner_w,
        "window.innerHeight" => inner_h,
        "window.screenX" => screen_x,
        "window.screenY" => screen_y,
        "window.scrollMinX" => 0,
        "window.scrollMinY" => 0,
        "window.scrollMaxX" => 0,
        "window.scrollMaxY" => 0,
        "window.history.length" => rand(1..5),
        "window.devicePixelRatio" => dpr,

        # Document body
        "document.body.clientWidth" => inner_w,
        "document.body.clientHeight" => inner_h,
        "document.body.clientTop" => 0,
        "document.body.clientLeft" => 0,

        # Headers
        "headers.User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:#{ff_version}.0) Gecko/20100101 Firefox/#{ff_version}.0",
        "headers.Accept-Language" => "#{language},#{language.split('-').first};q=0.9",
        "headers.Accept-Encoding" => "gzip, deflate, br",

        # WebGL
        "webGl:vendor" => "Apple",
        "webGl:renderer" => gpu,
        "webGl:supportedExtensions" => WEBGL_EXTENSIONS,
        "webGl2:supportedExtensions" => WEBGL2_EXTENSIONS,

        # Canvas
        "canvas:aaOffset" => rand(-50..50),
        "canvas:aaCapOffset" => true,

        # Battery
        "battery:charging" => charging,
        "battery:chargingTime" => charging ? 0.0 : 0.0,
        "battery:dischargingTime" => discharging_time,
        "battery:level" => battery_level,

        # Audio
        "AudioContext:sampleRate" => sample_rate,
        "AudioContext:outputLatency" => output_latency,
        "AudioContext:maxChannelCount" => 2,

        # Fonts
        "fonts" => MACOS_FONTS,
        "fonts:spacing_seed" => rand(1..1000),

        # Locale (timezone omitted — crashes Camoufox v146-beta)
        "locale:language" => language,
        "locale:region" => region,
        "locale:script" => "",
        "locale:all" => language,

        # Media devices
        "mediaDevices:micros" => 1,
        "mediaDevices:webcams" => 1,
        "mediaDevices:speakers" => 1,
        "mediaDevices:enabled" => true,

        # Misc
        "pdfViewerEnabled" => true
      }

      # Allow user overrides
      options.each do |key, value|
        config[key.to_s] = value if config.key?(key.to_s)
      end

      config
    end

    def firefox_version
      version_file = File.join(Pkgman.cache_dir, "version.json")
      if File.exist?(version_file)
        data = JSON.parse(File.read(version_file))
        if (ver = data["version"])
          match = ver.match(/(\d+)/)
          return match[1] if match
        end
      end
      "135"
    end

  end
end
