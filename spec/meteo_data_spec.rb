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

  describe '#hourly_description' do
    it 'returns description for a given hour' do
      desc = meteo_data.hourly_description(0)
      expect(desc).to be_a(String)
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

  describe 'WEATHER_CODE' do
    it 'has known weather codes' do
      expect(Wheat::WEATHER_CODE['0']).to eq('🌣 Ciel clair')
      expect(Wheat::WEATHER_CODE['3']).to eq('🌥 Couvert')
    end
  end
end
