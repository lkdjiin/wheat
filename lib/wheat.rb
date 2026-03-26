require 'fileutils'
require 'time'
require 'wheat/version'
require 'wheat/config'
require 'wheat/api_client'
require 'wheat/meteo_data'
require 'wheat/printer'
require 'wheat/cli'

module Wheat
  EXIT_CODE_API_TOO_SLOW = 1
  PRECIPITATION_BAR_GLYPH = '' # It's an umbrella in my terminal font.
  DEFAULT_WIND_GLYPH = ''

  # Default configuration hash for weather display and API requests.
  #
  # - latitude   - Float default latitude for Open-Meteo API
  # - longitude  - Float default longitude for Open-Meteo API
  # - color      - Boolean enable colorized temperature display
  # - glyph      - Boolean enable weather and precipitation glyphs
  # - wind_glyph - String wind glyph character
  DEFAULT_CONFIG = {
    'latitude' => 49.77,
    'longitude' => 4.72,
    'color' => true,
    'glyph' => true,
    'wind_glyph' => DEFAULT_WIND_GLYPH,
  }
end
