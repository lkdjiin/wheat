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
end
