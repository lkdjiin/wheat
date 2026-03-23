require_relative '../lib/wheat'

RSpec.describe Wheat::Printer do
  let(:data_path) { File.join(__dir__, 'resources', 'data.json') }
  let(:meteo_data) { Wheat::MeteoData.new(data_path) }
  subject(:printer) { described_class.new(meteo_data) }

  before do
    allow(printer).to receive(:clear_screen).and_return(nil)
  end

  describe '#display_current_section' do
    it 'outputs Maintenant section' do
      expect { printer.display_current_section }.to output(/=== Maintenant ===/).to_stdout
    end

    it 'outputs temperature' do
      expect { printer.display_current_section }.to output(/15°/).to_stdout
    end

    it 'outputs description' do
      expect { printer.display_current_section }.to output(/Couvert/).to_stdout
    end

    it 'outputs timestamp' do
      expect { printer.display_current_section }.to output(/rapport/).to_stdout
    end
  end

  describe '#display_next_hours' do
    it 'outputs Aujourd hui section' do
      expect { printer.display_next_hours }.to output(/=== Aujourd'hui ===/).to_stdout
    end

    it 'outputs hours from current hour to midnight' do
      output = capture_stdout { printer.display_next_hours }
      expect(output.scan(/\d{2}h/).count).to eq(6)
    end
  end

  describe '#display_all_today_hours' do
    it 'outputs 24 hours of weather data' do
      output = capture_stdout { printer.display_all_today_hours }
      expect(output.scan(/\d{1,2}h/).count).to eq(24)
    end
  end

  describe '#display_footer' do
    it 'outputs navigation hints' do
      expect { printer.display_footer }.to output(/\[Q\]uit/).to_stdout
      expect { printer.display_footer }.to output(/\[R\]ésumé/).to_stdout
      expect { printer.display_footer }.to output(/\[A\]ujourd'hui/).to_stdout
    end
  end

  describe '#display_all' do
    it 'outputs weather information' do
      expect { printer.display_all }.to output(/Maintenant/).to_stdout
      expect { printer.display_all }.to output(/Aujourd'hui/).to_stdout
      expect { printer.display_all }.to output(/Demain/).to_stdout
      expect { printer.display_all }.to output(/Tendances/).to_stdout
    end
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
