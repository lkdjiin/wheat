require 'json'

module Wheat
  WEATHER_CODE = {
    '0' => '🌣 Ciel clair',
    '1' => '🌣 Dégagé',
    '2' => '🌤 Nuageux',
    '3' => '🌥 Couvert',
    '45' => '🌫 Brouillard',
    '51' => '🌦 Averses faibles',
    '53' => '🌦 Averses faibles',
    '55' => '🌧 Averses fortes',
    '61' => '🌦 Pluie faible',
    '63' => '🌦 Pluie faible',
    '65' => '🌧 Pluie forte',
    '71' => '❄ Neige',
    '73' => '❄ Neige',
    '75' => '❄ Forte chute de neige',
  }

  class MeteoData
    def initialize(data_path)
      @data = JSON.load_file(data_path)
    end

    def current_temperature
      "#{current['temperature_2m'].round}"
    end

    def current_description
      desc = current['weather_code'].to_s
      WEATHER_CODE[desc] || "CODE INCONNU #{desc}"
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
      desc = hourly['weather_code'][hour].to_s
      WEATHER_CODE[desc] || "CODE INCONNU #{desc}"
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
  end
end
