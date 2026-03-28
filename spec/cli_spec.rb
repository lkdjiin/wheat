require_relative '../lib/wheat'

RSpec.describe Wheat::CLI do
  subject(:cli) { described_class.new }

  describe '#parse_options' do
    it 'parses --help' do
      expect { cli.parse_options(['--help']) }.to output(/Usage: wheat/).to_stdout
    rescue SystemExit
      nil
    end

    it 'parses -h' do
      expect { cli.parse_options(['-h']) }.to output(/Usage: wheat/).to_stdout
    rescue SystemExit
      nil
    end

    it 'parses --version' do
      expect { cli.parse_options(['--version']) }.to output(/wheat/).to_stdout
    rescue SystemExit
      nil
    end

    it 'parses --offline' do
      options = cli.parse_options(['--offline'])
      expect(options[:offline]).to be true
    end

    it 'parses --force-refresh' do
      options = cli.parse_options(['--force-refresh'])
      expect(options[:force_refresh]).to be true
    end

    it 'parses --data FILE' do
      options = cli.parse_options(['--data', '/path/to/data.json'])
      expect(options[:data_file]).to eq '/path/to/data.json'
      expect(options[:offline]).to be true
    end

    it 'parses -l --location LAT,LON' do
      options = cli.parse_options(['--location', '48.85,2.35'])
      expect(options[:location]).to eq [48.85, 2.35]
    end

    it 'parses -l LAT,LON (short form)' do
      options = cli.parse_options(['-l', '48.85,2.35'])
      expect(options[:location]).to eq [48.85, 2.35]
    end

    it 'returns default options' do
      options = cli.parse_options([])
      expect(options[:offline]).to be false
      expect(options[:data_file]).to be_nil
      expect(options[:location]).to be_nil
      expect(options[:force_refresh]).to be false
    end
  end

  describe '#determine_data_path' do
    it 'returns custom data file path when specified' do
      options = { data_file: '/custom/path/data.json' }
      expect(cli.determine_data_path(options)).to eq '/custom/path/data.json'
    end

    it 'returns DATA_FILE constant when no custom file' do
      expect(cli.determine_data_path({})).to eq Wheat::ApiClient::DATA_FILE
    end
  end

  describe '#implicit_offline?' do
    before do
      allow(Wheat::ApiClient).to receive(:cache_fresh_enough?).and_return(false)
    end

    it 'returns false when data_file is specified' do
      options = { data_file: '/path/to/data.json' }
      expect(cli.implicit_offline?(options)).to be false
    end

    it 'returns cache_fresh_enough? result when no data_file' do
      allow(Wheat::ApiClient).to receive(:cache_fresh_enough?).and_return(true)
      expect(cli.implicit_offline?( {})).to be true
    end
  end
end
