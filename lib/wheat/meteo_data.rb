require 'json'

module Wheat

  WEATHER_CODE_DESCRIPTION = {
    '0' => 'Ciel clair',
    '1' => 'Dégagé',
    '2' => 'Nuageux',
    '3' => 'Couvert',
    '45' => 'Brouillard',
    '51' => 'Averses faibles',
    '53' => 'Averses faibles',
    '55' => 'Averses fortes',
    '61' => 'Pluie faible',
    '63' => 'Pluie faible',
    '65' => 'Pluie forte',
    '71' => 'Neige',
    '73' => 'Neige',
    '75' => 'Forte chute de neige',
  }

  WEATHER_CODE_GLYPH = {
    '0' => '🌣',
    '1' => '🌣',
    '2' => '🌤',
    '3' => '🌥',
    '45' => '🌫',
    '51' => '🌦',
    '53' => '🌦',
    '55' => '🌧',
    '61' => '🌦',
    '63' => '🌦',
    '65' => '🌧',
    '71' => '❄',
    '73' => '❄',
    '75' => '❄',
  }

  class MeteoData
    # Initializes a new MeteoData with weather data from a JSON file.
    #
    # data_path - Path to JSON file containing weather data from Open-Meteo API
    # config    - Configuration hash (default: DEFAULT_CONFIG)
    #             'glyph' - Boolean whether or not using glyphs in descriptions.
    #             All other keys are ignored.
    #
    # Returns a new MeteoData instance.
    def initialize(data_path, config: DEFAULT_CONFIG)
      @data = JSON.load_file(data_path)
      @use_glyph = config['glyph']
    end

    def current_description
      code = current['weather_code'].to_s
      description_line_for(code)
    end

    def current_temperature
      "#{current['temperature_2m'].round}"
    end

    def current_time
      current['time']
    end

    def current_wind
      current['wind_speed_10m'].round.to_s
    end

    def hourly_temperature(hour)
      hourly['temperature_2m'][hour].round.to_s
    end

    def hourly_precipitation_probability(hour)
      hourly['precipitation_probability'][hour].to_s
    end

    def hourly_description(hour)
      code = hourly['weather_code'][hour].to_s
      description_line_for(code)
    end

    def temperature_tomorrow_at_0600
      hourly['temperature_2m'][30].round.to_s
    end

    def temperature_tomorrow_at_1100
      hourly['temperature_2m'][35].round.to_s
    end

    def precipitation_probability_tomorrow_morning
      proba = 0
      30.upto(35).each { |i| proba += hourly['precipitation_probability'][i] }
      (proba / 6).to_s
    end

    def temperature_tomorrow_at_1200
      hourly['temperature_2m'][36].round.to_s
    end

    def temperature_tomorrow_at_1700
      hourly['temperature_2m'][41].round.to_s
    end

    def precipitation_probability_tomorrow_afternoon
      proba = 0
      36.upto(41).each { |i| proba += hourly['precipitation_probability'][i] }
      (proba / 6).to_s
    end

    def wind_tomorrow
      daily['wind_speed_10m_mean'][1].round.to_s
    end

    def wind_today
      daily['wind_speed_10m_mean'][0].round.to_s
    end

    def two_weeks_date
      daily['time']
    end

    def two_weeks_max_temperature
      daily['temperature_2m_max'].map { _1.round.to_s }
    end

    def two_weeks_min_temperature
      daily['temperature_2m_min'].map { _1.round.to_s }
    end

    def two_weeks_mean_precipitation_probability
      daily['precipitation_probability_mean'].map(&:to_s)
    end

    def two_weeks_wind
      daily['wind_speed_10m_mean'].map { _1.round.to_s }
    end

    private

    def current
      @data['current']
    end

    def hourly
      @data['hourly']
    end

    def daily
      @data['daily']
    end

    def description_line_for(code)
      description = WEATHER_CODE_DESCRIPTION[code] || "CODE INCONNU #{code}"
      glyph = WEATHER_CODE_GLYPH[code] || ''
      @use_glyph ? "#{glyph} #{description}" : description
    end
  end
end
