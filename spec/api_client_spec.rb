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

  describe '.cache_fresh_enough?' do
    let(:data_file) { Wheat::ApiClient::DATA_FILE }

    before do
      allow(File).to receive(:exist?).and_return(true)
    end

    context 'when cache file does not exist' do
      before do
        allow(File).to receive(:exist?).with(data_file).and_return(false)
      end

      it 'returns false' do
        expect(described_class.cache_fresh_enough?).to be false
      end
    end

    context 'when cached time is invalid' do
      before do
        allow(JSON).to receive(:load_file).and_return({ 'current' => { 'time' => nil } })
      end

      it 'returns false' do
        expect(described_class.cache_fresh_enough?).to be false
      end
    end
  end

  describe '.cached_report_time' do
    let(:data_file) { Wheat::ApiClient::DATA_FILE }

    before do
      allow(JSON).to receive(:load_file).with(data_file).and_return({
        'current' => { 'time' => '2026-03-23T18:00' }
      })
    end

    it 'returns the cached time string' do
      expect(described_class.cached_report_time).to eq '2026-03-23T18:00'
    end
  end

  describe '.current_quarter' do
    it 'returns integer quarter of current hour' do
      quarter = described_class.current_quarter
      expect(quarter).to be_an(Integer)
      expect(quarter).to be_between(0, 3)
    end
  end

  describe '.cached_quarter' do
    it 'returns 0 for times at minute 0-14' do
      expect(described_class.cached_quarter('2026-03-23T18:00')).to eq 0
    end

    it 'returns 1 for times at minute 15-29' do
      expect(described_class.cached_quarter('2026-03-23T18:20')).to eq 1
    end

    it 'returns 2 for times at minute 30-44' do
      expect(described_class.cached_quarter('2026-03-23T18:30')).to eq 2
    end

    it 'returns 3 for times at minute 45-59' do
      expect(described_class.cached_quarter('2026-03-23T18:50')).to eq 3
    end
  end

  describe '.fetch' do
    it 'executes curl command and returns output path' do
      fake_status = double('Process::Status', exitstatus: 0)
      allow($?).to receive(:exitstatus).and_return(0)
      allow($?).to receive(:success?).and_return(true)

      allow_any_instance_of(described_class).to receive(:system).and_return(true)

      result = described_class.fetch(48.85, 2.35, '/tmp/test.json')

      expect(result).to eq '/tmp/test.json'
    end

    it 'returns :timeout when curl times out (exit code 28)' do
      allow($?).to receive(:exitstatus).and_return(28)
      allow($?).to receive(:success?).and_return(false)

      allow_any_instance_of(described_class).to receive(:system).and_return(false)

      result = described_class.fetch(48.85, 2.35)

      expect(result).to eq :timeout
    end
  end
end
