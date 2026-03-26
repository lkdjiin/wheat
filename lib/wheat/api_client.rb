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
        daily: 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_mean,wind_speed_10m_mean',
        hourly: 'temperature_2m,precipitation_probability,weather_code',
        current: 'temperature_2m,weather_code,wind_speed_10m',
        timezone: 'auto',
        forecast_days: 14
      }
      query = params.map { |k, v| "#{k}=#{v}" }.join('&')
      "#{BASE_URL}?#{query}"
    end

    def fetch(url, output_path)
      command = "curl --no-progress-meter --max-time 5 '#{url}' > '#{output_path}'"
      system(command)
      return :timeout if $?.exitstatus == 28
      output_path
    end

    def self.cache_fresh_enough?
      return false unless File.exist?(DATA_FILE)
      cached_time = cached_report_time
      return false unless cached_time

      current_hour = Time.now.strftime("%H").to_i
      cached_hour = Time.parse(cached_time).strftime("%H").to_i

      return false if current_hour != cached_hour
      current_quarter == cached_quarter(cached_time)
    end

    def self.cached_report_time
      JSON.load_file(DATA_FILE)['current']['time']
    end

    def self.current_quarter
      Time.now.strftime("%M").to_i / 15
    end

    def self.cached_quarter(time_str)
      Time.parse(time_str).strftime("%M").to_i / 15
    end
  end
end
