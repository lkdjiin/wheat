require 'yaml'

module Wheat
  class Config
    CONFIG_DIR = File.expand_path('~/.config/wheat')
    CONFIG_FILE = File.join(CONFIG_DIR, 'wheat.yml')

    attr_reader :latitude, :longitude, :color, :glyph, :wind_glyph

    def initialize
      ensure_config_dir
      @latitude, @longitude, @color, @glyph, @wind_glyph = load_config
    end

    def ensure_config_dir
      FileUtils.mkdir_p(CONFIG_DIR)
    end

    def load_config
      if File.exist?(CONFIG_FILE)
        config = YAML.load_file(CONFIG_FILE)
        [config['latitude'], config['longitude'],
         config.fetch('color', true), config.fetch('glyph', true),
         config.fetch('wind_glyph', WIND_GLYPH)]
      else
        [49.771295, 4.724286, true, true, WIND_GLYPH]
      end
    end

    def self.ensure_config_dir
      FileUtils.mkdir_p(CONFIG_DIR)
    end

    def self.config_file_path
      CONFIG_FILE
    end
  end
end
