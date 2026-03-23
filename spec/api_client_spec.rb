require_relative '../lib/wheat'

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
