require_relative '../lib/wheat'

RSpec.describe Wheat::Printer do
  let(:data_path) { File.join(__dir__, 'resources', 'data.json') }
  let(:meteo_data) { Wheat::MeteoData.new(data_path) }
  subject(:printer) do
    described_class.new(meteo_data, config: {
      'min_wind_speed' => 0,
      'min_rain_proba' => 1,
      'glyph' => true,
      'color' => true,
    })
  end

  before do
    allow(printer).to receive(:clear_screen).and_return(nil)
  end

  describe '#display_current_section' do
    it 'outputs title section' do
      regex = %r{=== Maintenant \(\s*7 km/h\) ===}
      expect { printer.display_current_section }.to output(regex).to_stdout
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

    describe 'when use_glyph is false' do
      let(:printer_no_glyph) do
        described_class.new(meteo_data, config: { 'glyph' => false, 'min_wind_speed' => 0 })
      end

      before do
        allow(printer_no_glyph).to receive(:clear_screen).and_return(nil)
      end

      it 'outputs wind without glyph' do
        expect {
          printer_no_glyph.display_current_section
        }.to output(%r{=== Maintenant \(\s*7 km/h\) ===}).to_stdout
      end
    end

    describe 'when wind below min_wind_speed' do
      let(:printer_low_wind) do
        described_class.new(meteo_data, config: { 'min_wind_speed' => 10 })
      end

      before do
        allow(printer_low_wind).to receive(:clear_screen).and_return(nil)
      end

      it 'outputs title without wind' do
        expect {
          printer_low_wind.display_current_section
        }.to output(/=== Maintenant ===/).to_stdout
      end
    end
  end

  describe '#display_tomorrow' do
    it 'outputs title section' do
      regex = %r{=== Demain \(\s*8 km/h\) ===}
      expect { printer.display_tomorrow }.to output(regex).to_stdout
    end

    describe 'when use_glyph is false' do
      let(:printer_no_glyph) do
        described_class.new(meteo_data, config: { 'glyph' => false, 'min_wind_speed' => 0 })
      end

      before do
        allow(printer_no_glyph).to receive(:clear_screen).and_return(nil)
      end

      it 'outputs wind without glyph' do
        expect {
          printer_no_glyph.display_tomorrow
        }.to output(%r{=== Demain \(\s*8 km/h\) ===}).to_stdout
      end
    end

    describe 'when wind below min_wind_speed' do
      let(:printer_low_wind) do
        described_class.new(meteo_data, config: { 'min_wind_speed' => 10 })
      end

      before do
        allow(printer_low_wind).to receive(:clear_screen).and_return(nil)
      end

      it 'outputs title without wind' do
        expect {
          printer_low_wind.display_tomorrow
        }.to output(/=== Demain ===/).to_stdout
      end
    end
  end

  describe '#display_next_hours' do
    it 'outputs Aujourd hui section' do
      regex = %r[=== Aujourd'hui \(\s*4 km/h\) ===]
      expect { printer.display_next_hours }.to output(regex).to_stdout
    end

    it 'outputs hours from current hour to midnight' do
      output = capture_stdout { printer.display_next_hours }
      expect(output.scan(/\d{2}h/).count).to eq(6)
    end

    describe 'when use_glyph is false' do
      let(:printer_no_glyph) do
        described_class.new(meteo_data,
                            config: { 'glyph' => false,
                                      'min_rain_proba' => 1,
                                      'min_wind_speed' => 0 })
      end

      before do
        allow(printer_no_glyph).to receive(:clear_screen).and_return(nil)
      end

      it 'outputs wind without glyph' do
        expect {
          printer_no_glyph.display_next_hours
        }.to output(%r[=== Aujourd'hui \(\s*4 km/h\) ===]).to_stdout
      end
    end

    describe 'when wind below min_wind_speed' do
      let(:printer_low_wind) do
        described_class.new(meteo_data,
                            config: { 'min_wind_speed' => 10,
                                      'min_rain_proba' => 1 })
      end

      before do
        allow(printer_low_wind).to receive(:clear_screen).and_return(nil)
      end

      it 'outputs title without wind' do
        expect {
          printer_low_wind.display_next_hours
        }.to output(/=== Aujourd'hui ===/).to_stdout
      end
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

  describe '#precipitation_bar' do
    describe 'when probability is 75-100' do
      it 'outputs three characters' do
        value = printer.precipitation_bar('80')
        expect(value).to eq Wheat::PRECIPITATION_BAR_GLYPH * 3
      end
    end

    describe 'when probability is 50-74' do
      it 'outputs two characters' do
        value = printer.precipitation_bar('60')
        expect(value).to eq Wheat::PRECIPITATION_BAR_GLYPH * 2
      end
    end

    describe 'when probability is 1-49' do
      it 'outputs one character' do
        value = printer.precipitation_bar('7')
        expect(value).to eq Wheat::PRECIPITATION_BAR_GLYPH
      end
    end

    describe 'when probability is 0' do
      it 'outputs no character' do
        value = printer.precipitation_bar('0')
        expect(value).to eq ''
      end
    end

    describe 'when use_glyph is false' do
      let(:printer_no_glyph) do
        described_class.new(meteo_data, config: { 'glyph' => false })
      end

      it 'outputs empty string for any probability' do
        expect(printer_no_glyph.precipitation_bar('80')).to eq ''
        expect(printer_no_glyph.precipitation_bar('60')).to eq ''
        expect(printer_no_glyph.precipitation_bar('7')).to eq ''
        expect(printer_no_glyph.precipitation_bar('0')).to eq ''
      end
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
        "| \e[31m 31°\e[0m    | \e[38;5;208m 26°\e[0m    |  11°    |   6°    |   8°    |   9°    |   9°    |\n" \
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

  describe '#wind_description' do
    subject(:wind_threshold) do
      described_class.new(meteo_data, config: { 'min_wind_speed' => 10 })
    end

    it 'returns empty string when wind is below threshold' do
      expect(wind_threshold.wind_description(5)).to be_nil
    end

    it 'returns wind string when wind equals threshold' do
      expect(wind_threshold.wind_description(10)).to eq '(10 km/h)'
    end

    it 'returns wind string when wind is above threshold' do
      expect(wind_threshold.wind_description(11)).to eq '(11 km/h)'
    end
  end

  describe '#colorize_temperature' do
    let(:printer_no_color) do
      described_class.new(meteo_data, config: { 'color' => false })
    end

    let(:printer_with_color) do
      described_class.new(meteo_data, config: { 'color' => true })
    end

    describe 'when color is disabled' do
      it 'returns temperature without color codes' do
        result = printer_no_color.send(:colorize_temperature, '15')
        expect(result).to eq '15°'
      end
    end

    describe 'when color is enabled' do
      it 'returns blue for negative temperatures' do
        result = printer_with_color.send(:colorize_temperature, '-5')
        expect(result).to include(Wheat::BLUE)
        expect(result).to include('-5°')
      end

      it 'returns red for temperature >= 30' do
        result = printer_with_color.send(:colorize_temperature, '30')
        expect(result).to include(Wheat::RED)
        expect(result).to include('30°')
      end

      it 'returns orange for temperature >= 25 and < 30' do
        result = printer_with_color.send(:colorize_temperature, '27')
        expect(result).to include(Wheat::ORANGE)
        expect(result).to include('27°')
      end

      it 'returns green for temperature >= 20 and < 25' do
        result = printer_with_color.send(:colorize_temperature, '22')
        expect(result).to include(Wheat::GREEN)
        expect(result).to include('22°')
      end

      it 'returns no color for temperature < 20 and > 0' do
        result = printer_with_color.send(:colorize_temperature, '18')
        expect(result).to eq '18°'
      end

    end
  end

  describe '#title_for_section' do
    let(:printer_no_wind) do
      described_class.new(meteo_data, config: { 'min_wind_speed' => 100 })
    end

    it 'formats section title with wind' do
      result = printer.send(:title_for_section, 'Test', '10')
      expect(result).to include('===')
      expect(result).to include('Test')
      expect(result).to include('10 km/h')
    end

    it 'formats section title without wind when below threshold' do
      result = printer_no_wind.send(:title_for_section, 'Test', '5')
      expect(result).to eq '=== Test ==='
    end
  end

  describe 'constants' do
    it 'PRECIPITATION_BAR_GLYPH is defined' do
      expect(Wheat::PRECIPITATION_BAR_GLYPH).to be_a(String)
    end

    it 'DEFAULT_WIND_GLYPH is defined' do
      expect(Wheat::DEFAULT_WIND_GLYPH).to be_a(String)
    end

    it 'EXIT_CODE_API_TOO_SLOW is defined' do
      expect(Wheat::EXIT_CODE_API_TOO_SLOW).to eq 1
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
