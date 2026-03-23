require_relative '../lib/wheat'

RSpec.describe Wheat::Printer do
  let(:data_path) { File.join(__dir__, 'resources', 'data.json') }
  let(:meteo_data) { Wheat::MeteoData.new(data_path) }
  subject(:printer) { described_class.new(meteo_data) }

  describe '#display_all' do
    it 'outputs weather information' do
      expect { printer.display_all }.to output(/Maintenant/).to_stdout
      expect { printer.display_all }.to output(/Aujourd'hui/).to_stdout
      expect { printer.display_all }.to output(/Demain/).to_stdout
      expect { printer.display_all }.to output(/Tendances/).to_stdout
    end
  end

  describe '#display_all_today_hours' do
    it 'outputs 24 hours of weather data' do
      output = capture_stdout { printer.display_all_today_hours }
      expect(output.scan(/\d{1,2}h/).count).to eq(24)
    end

    def capture_stdout
      StringIO.new.tap do |stream|
        $stdout = stream
        yield
      ensure
        $stdout = STDOUT
      end.string
    end
  end
end
