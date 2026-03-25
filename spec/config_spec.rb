require_relative '../lib/wheat'

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
      expect(config.glyph).to eq(true)
    end
  end
end
