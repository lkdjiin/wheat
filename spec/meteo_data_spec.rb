require_relative '../lib/wheat'

RSpec.describe Wheat::MeteoData do
  let(:data_path) { File.join(__dir__, 'resources', 'data.json') }
  subject(:meteo_data) { described_class.new(data_path) }

  describe '#current_temperature' do
    it 'returns a temperature string' do
      expect(meteo_data.current_temperature).to match(/\d+/)
    end
  end

  describe '#current_wind' do
    it 'returns the wind rounded' do
      desc = meteo_data.current_wind
      expect(desc).to eq '7'
    end
  end

  describe '#current_description' do
    it 'returns a weather description' do
      desc = meteo_data.current_description
      expect(desc).to be_a(String)
      expect(desc.length).to be > 0
    end
  end

  describe '#current_time' do
    it 'returns the time string' do
      expect(meteo_data.current_time).to eq '2026-03-23T18:00'
    end
  end

  describe '#wind_today' do
    it 'returns the rounded mean wind for today' do
      value = meteo_data.wind_today
      expect(value).to eq '4'
    end
  end

  describe '#wind_tomorrow' do
    it 'returns the rounded wind for tomorrow' do
      value = meteo_data.wind_tomorrow
      expect(value).to eq '8'
    end
  end

  describe '#hourly_temperature' do
    it 'returns temperature for a given hour' do
      expect(meteo_data.hourly_temperature(0)).to match(/\d+/)
    end
  end

  describe '#hourly_precipitation_probability' do
    it 'returns precipitation probability for a given hour' do
      prob = meteo_data.hourly_precipitation_probability(0)
      expect(prob).to be_a(String)
    end
  end

  describe '#hourly_description' do
    it 'returns description for a given hour' do
      desc = meteo_data.hourly_description(0)
      expect(desc).to be_a(String)
    end
  end

  describe '#temperature_tomorrow_at_0600' do
    it 'returns temperature for hour index 30' do
      temp = meteo_data.temperature_tomorrow_at_0600
      expect(temp).to match(/\d+/)
    end
  end

  describe '#temperature_tomorrow_at_1100' do
    it 'returns temperature for hour index 35' do
      temp = meteo_data.temperature_tomorrow_at_1100
      expect(temp).to match(/\d+/)
    end
  end

  describe '#precipitation_probability_tomorrow_morning' do
    it 'returns average probability for morning hours' do
      proba = meteo_data.precipitation_probability_tomorrow_morning
      expect(proba).to match(/\d*/)
    end
  end

  describe '#temperature_tomorrow_at_1200' do
    it 'returns temperature for hour index 36' do
      temp = meteo_data.temperature_tomorrow_at_1200
      expect(temp).to match(/\d+/)
    end
  end

  describe '#temperature_tomorrow_at_1700' do
    it 'returns temperature for hour index 41' do
      temp = meteo_data.temperature_tomorrow_at_1700
      expect(temp).to match(/\d+/)
    end
  end

  describe '#precipitation_probability_tomorrow_afternoon' do
    it 'returns average probability for afternoon hours' do
      proba = meteo_data.precipitation_probability_tomorrow_afternoon
      expect(proba).to match(/\d*/)
    end
  end

  describe '#two_weeks_date' do
    it 'returns an array of dates' do
      dates = meteo_data.two_weeks_date
      expect(dates).to be_an(Array)
      expect(dates.length).to eq 14
    end
  end

  describe '#two_weeks_mean_precipitation_probability' do
    it 'returns 14 precipitation probability values' do
      probs = meteo_data.two_weeks_mean_precipitation_probability
      expect(probs).to be_an(Array)
      expect(probs.length).to eq 14
    end
  end

  describe 'with use_glyph: false' do
    let(:meteo_data_no_glyph) do
      described_class.new(data_path, config: { 'glyph' => false })
    end

    describe '#current_description' do
      it 'returns description without emoji' do
        desc = meteo_data_no_glyph.current_description
        expect(desc).to eq 'Couvert'
      end
    end

    describe '#hourly_description' do
      it 'returns description without emoji' do
        desc = meteo_data_no_glyph.hourly_description(0)
        expect(desc).not_to match(/\p{Emoji}/)
      end
    end
  end

  describe '#two_weeks_max_temperature' do
    it 'returns 14 temperatures' do
      temps = meteo_data.two_weeks_max_temperature
      expect(temps.count).to eq(14)
    end
  end

  describe '#two_weeks_min_temperature' do
    it 'returns 14 temperatures' do
      temps = meteo_data.two_weeks_min_temperature
      expect(temps.count).to eq(14)
    end
  end

  describe '#two_weeks_wind' do
    it 'returns the 14 values' do
      expect(meteo_data.two_weeks_wind)
        .to eq(%w( 4 8 18 18 10 15 12 9 17 16 9 5 9 12 ))
    end
  end

  describe 'WEATHER_CODE_DESCRIPTION' do
    it 'has known weather codes' do
      expect(Wheat::WEATHER_CODE_DESCRIPTION['0']).to eq('Ciel clair')
      expect(Wheat::WEATHER_CODE_DESCRIPTION['3']).to eq('Couvert')
    end
  end

  describe 'WEATHER_CODE_GLYPH' do
    it 'has known weather glyphs' do
      expect(Wheat::WEATHER_CODE_GLYPH['0']).to eq('🌣')
      expect(Wheat::WEATHER_CODE_GLYPH['3']).to eq('🌥')
    end
  end

  describe 'unknown weather codes' do
    let(:unknown_code_meteo) { described_class.new(data_path) }

    it 'returns CODE INCONNU for unknown weather codes in current' do
      allow(unknown_code_meteo).to receive(:current).and_return({ 'weather_code' => 999 })
      desc = unknown_code_meteo.current_description
      expect(desc).to include('CODE INCONNU')
      expect(desc).to include('999')
    end

    it 'returns CODE INCONNU for unknown weather codes in hourly' do
      allow(unknown_code_meteo).to receive(:hourly).and_return({
        'weather_code' => [999]
      })
      desc = unknown_code_meteo.hourly_description(0)
      expect(desc).to include('CODE INCONNU')
      expect(desc).to include('999')
    end
  end
end
