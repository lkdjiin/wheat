require_relative '../lib/wheat'

# Weather codes mapped to French descriptions
WEATHER_CODE = {
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

RSpec.describe Wheat::MeteoData do
  let(:data_path) { File.join(__dir__, '..', 'open-meteo.json') }
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

RSpec.describe Wheat::Config do
  describe '#initialize' do
    it 'creates config directory if needed' do
      allow(FileUtils).to receive(:mkdir_p)
      described_class.new
      expect(FileUtils).to have_received(:mkdir_p)
    end

    it 'returns default coordinates when no config file exists' do
      allow(File).to receive(:exist?).and_return(false)
      config = described_class.new
      expect(config.latitude).to eq(49.771295)
      expect(config.longitude).to eq(4.724286)
    end
  end
end

RSpec.describe Wheat::ApiClient do
  describe '.build_url' do
    it 'builds a valid API URL' do
      url = described_class.build_url(48.85, 2.35)
      expect(url).to include('api.open-meteo.com')
      expect(url).to include('latitude=48.85')
      expect(url).to include('longitude=2.35')
    end
  end
end
