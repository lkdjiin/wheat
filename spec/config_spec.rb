require_relative '../lib/wheat'

RSpec.describe Wheat::Config do
  let(:default_config) do
    {
      'latitude' => 12.34,
      'longitude' => 98.76,
      'color' => false,
      'glyph' => false,
      'wind_glyph' => 'x',
    }
  end

  describe '.load_file' do
    it 'creates config directory if needed' do
      allow(FileUtils).to receive(:mkdir_p)
      described_class.load_file
      expect(FileUtils).to have_received(:mkdir_p)
    end

    it 'copy/paste config file default if needed' do
      allow(File)
        .to receive(:exist?)
        .with(Wheat::Config::CONFIG_FILE)
        .and_return(false)
      allow(FileUtils).to receive(:cp)
      described_class.load_file
      expect(FileUtils).to have_received(:cp)
    end

    it 'returns a Hash' do
      expect(described_class.load_file).to be_a Hash
    end
  end

  describe '#ensure_default_values' do
    let(:instance) { described_class.new }

    it 'makes sure latitude exist' do
      value = instance.ensure_default_values({})['latitude']
      expect(value).to eq 49.77
      value = instance.ensure_default_values(default_config)['latitude']
      expect(value).to eq 12.34
    end

    it 'makes sure longitude exist' do
      value = instance.ensure_default_values({})['longitude']
      expect(value).to eq 4.72
      value = instance.ensure_default_values(default_config)['longitude']
      expect(value).to eq 98.76
    end

    it 'makes sure color exist' do
      value = instance.ensure_default_values({})['color']
      expect(value).to eq true
      value = instance.ensure_default_values(default_config)['color']
      expect(value).to eq false
    end

    it 'makes sure glyph exist' do
      value = instance.ensure_default_values({})['glyph']
      expect(value).to eq true
      value = instance.ensure_default_values(default_config)['glyph']
      expect(value).to eq false
    end

    it 'makes sure wind_glyph exist' do
      value = instance.ensure_default_values({})['wind_glyph']
      expect(value).to eq ''
      value = instance.ensure_default_values(default_config)['wind_glyph']
      expect(value).to eq 'x'
    end
  end
end
