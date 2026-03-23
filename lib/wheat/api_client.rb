require 'json'

module Wheat
  class ApiClient
    BASE_URL = 'https://api.open-meteo.com/v1/forecast'
    DATA_FILE = File.join(Config::CONFIG_DIR, 'data.json')

    def self.fetch(lat, lon, output_path = DATA_FILE)
      url = build_url(lat, lon)
      new.fetch(url, output_path)
    end

    def self.build_url(lat, lon)
      params = {
        latitude: lat,
        longitude: lon,
        daily: 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_mean',
        hourly: 'temperature_2m,precipitation_probability,weather_code',
        current: 'temperature_2m,weather_code',
        timezone: 'auto',
        forecast_days: 14
      }
      query = params.map { |k, v| "#{k}=#{v}" }.join('&')
      "#{BASE_URL}?#{query}"
    end

    def fetch(url, output_path)
      Config.ensure_config_dir
      command = "curl --no-progress-meter --max-time 5 '#{url}' > '#{output_path}'"
      system(command)
      return :timeout if $?.exitstatus == 28
      output_path
    end
  end
end
