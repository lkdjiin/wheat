require_relative '../lib/wheat'

RSpec.describe Wheat::Printer do
  let(:data_path) { File.join(__dir__, 'resources', 'data.json') }
  let(:meteo_data) { Wheat::MeteoData.new(data_path) }
  subject(:printer) { described_class.new(meteo_data) }

  before do
    allow(printer).to receive(:clear_screen).and_return(nil)
  end

  describe '#display_current_section' do
    it 'outputs title section' do
      expect {
        printer.display_current_section
      }.to output(%r{=== Maintenant \(7 km/h\) ===}).to_stdout
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

  describe '#display_tomorrow' do
    it 'outputs title section' do
      expect {
        printer.display_tomorrow
      }.to output(%r{=== Demain \(8 km/h\) ===}).to_stdout
    end
  end

  describe '#display_next_hours' do
    it 'outputs Aujourd hui section' do
      expect {
        printer.display_next_hours
      }.to output(%r[=== Aujourd'hui \(4 km/h\) ===]).to_stdout
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

  describe '#display_summary' do
    it 'outputs weather information' do
      expect { printer.display_summary }.to output(/Maintenant/).to_stdout
      expect { printer.display_summary }.to output(/Aujourd'hui/).to_stdout
      expect { printer.display_summary }.to output(/Demain/).to_stdout
      expect { printer.display_summary }.to output(/Tendances/).to_stdout
    end
  end

  describe '#display_two_weeks' do
    it 'outputs title section' do
      expect {
        printer.display_two_weeks
      }.to output(%r{=== Tendances sur 2 semaines ===}).to_stdout
    end

    it 'outputs 14 days of dates' do
      output = capture_stdout { printer.display_two_weeks }
      expect(output.scan(/\d{2}/)
        .first(14)
        .map(&:to_i))
        .to eq([23, 24, 25, 26, 27, 28, 29, 30, 31, 1, 2, 3, 4, 5])
    end

    it 'outputs 14 day abbreviations' do
      output = capture_stdout { printer.display_two_weeks }
      expect(output.scan(/\b(dim|lun|mar|mer|jeu|ven|sam)\b/).count).to eq(14)
    end

    it 'outputs temperatures with degree symbol' do
      output = capture_stdout { printer.display_two_weeks }
      expect(output.scan(/°/).count).to eq(28)
    end

    it 'outputs precipitation probabilities' do
      output = capture_stdout { printer.display_two_weeks }
      expect(output.scan(/\d+%/).count).to be > 0
    end
  end

  describe '#display_tendencies' do
    it 'outputs title section' do
      expect {
        printer.display_tendencies
      }.to output(
        "=== Tendances sur 2 semaines ===\n" \
        "\n" \
        "|---------|---------|---------|---------|---------|---------|---------|\n" \
        "|  23     |  24     |  25     |  26     |  27     |  28     |  29     |\n" \
        "| lundi   | mardi   | mercredi| jeudi   | vendredi| samedi  | dimanche|\n" \
        "|---------|---------|---------|---------|---------|---------|---------|\n" \
        "|  17°    |  16°    |  11°    |   6°    |   8°    |   9°    |   9°    |\n" \
        "|   4°    |   5°    |   3°    | \e[34m  0°\e[0m    | \e[34m -1°\e[0m    |   3°    |   2°    |\n" \
        "|---------|---------|---------|---------|---------|---------|---------|\n" \
        "|         |         |  61%    |  34%    |  10%    |  49%    |   5%    |\n" \
        "|   4km/h |   8km/h |  18km/h |  18km/h |  10km/h |  15km/h |  12km/h |\n" \
        "|---------|---------|---------|---------|---------|---------|---------|\n" \
        "\n" \
        "|---------|---------|---------|---------|---------|---------|---------|\n" \
        "|  30     |  31     |  01     |  02     |  03     |  04     |  05     |\n" \
        "| lundi   | mardi   | mercredi| jeudi   | vendredi| samedi  | dimanche|\n" \
        "|---------|---------|---------|---------|---------|---------|---------|\n" \
        "|  10°    |  12°    |  10°    |  11°    |  11°    |  11°    |  11°    |\n" \
        "|   1°    |   6°    |   4°    |   2°    | \e[34m  0°\e[0m    |   7°    |   6°    |\n" \
        "|---------|---------|---------|---------|---------|---------|---------|\n" \
        "|  33%    |  24%    |  24%    |  21%    |  15%    |  12%    |  11%    |\n" \
        "|   9km/h |  17km/h |  16km/h |   9km/h |   5km/h |   9km/h |  12km/h |\n" \
        "|---------|---------|---------|---------|---------|---------|---------|\n"
      ).to_stdout
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
