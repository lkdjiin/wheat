require 'yaml'

module Wheat
  class Config
    CONFIG_DIR = File.expand_path('~/.config/wheat')
    CONFIG_FILE = File.join(CONFIG_DIR, 'wheat.yml')
    EXAMPLE_FILE = File.expand_path('../../config/wheat.yml.example', __dir__)

    def self.load_file
      config = self.new
      config.ensure_config_dir
      config.ensure_config_file
      config.ensure_default_values(YAML.load_file(CONFIG_FILE))
    end

    def ensure_config_dir
      FileUtils.mkdir_p(CONFIG_DIR)
    end

    def ensure_config_file
      return if File.exist?(CONFIG_FILE)
      FileUtils.cp(EXAMPLE_FILE, CONFIG_FILE)
    end

    def ensure_default_values(hash)
      DEFAULT_CONFIG.merge(hash)
    end
  end
end
