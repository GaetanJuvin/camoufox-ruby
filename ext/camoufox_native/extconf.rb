# frozen_string_literal: true

require "mkmf"

extension_name = "camoufox_native"

# Enable C++ compilation
$CXXFLAGS << " -std=c++20 -Wall -Wextra"
$CFLAGS << " -std=c99"
$LDFLAGS << " "

create_makefile(extension_name)
