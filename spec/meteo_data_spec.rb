require_relative '../lib/wheat'

RSpec.describe Wheat::MeteoData do
  let(:data_path) { File.join(__dir__, 'resources', 'data.json') }
  subject(:meteo_data) { described_class.new(data_path) }

  describe '#current_temperature' do
    it 'returns a temperature string' do
      expect(meteo_data.current_temperature).to match(/\d+/)
    end
  end

  describe '#current_description' do
    it 'returns a weather description' do
      desc = meteo_data.current_description
      expect(desc).to be_a(String)
      expect(desc.length).to be > 0
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

  describe 'WEATHER_CODE' do
    it 'has known weather codes' do
      expect(Wheat::WEATHER_CODE['0']).to eq('Ciel clair')
      expect(Wheat::WEATHER_CODE['3']).to eq('Couvert')
    end
  end
end
