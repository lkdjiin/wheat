require 'optparse'
require 'io/console'

module Wheat
  class CLI
    def run(args)
      options = parse_options(args)
      execute(options)
    end

    def parse_options(args)
      options = { offline: false, data_file: nil, location: nil }

      OptionParser.new do |opts|
        opts.banner = "Usage: wheat [options]"

        opts.on('-h', '--help', 'Show this help message') do
          puts opts
          puts
          puts "How is the weather today?"
          exit
        end

        opts.on('--version', 'Show gem version') do
          puts "wheat #{Wheat.version}"
          exit
        end

        opts.on('--offline', 'Use cached data without fetching from API') do
          options[:offline] = true
        end

        opts.on('--data FILE', 'Load JSON data from FILE') do |file|
          options[:data_file] = file
          options[:offline] = true
        end

        opts.on('-l',
                '--location LAT,LON',
                'Override config location (e.g., 48.85,2.35)') do |loc|
          lat, lon = loc.split(',').map(&:to_f)
          options[:location] = [lat, lon]
        end
      end.parse!(args)

      options
    end

    def execute(options)
      data_path = determine_data_path(options)
      config = Config.new

      unless options[:offline]
        lat, lon = options[:location] || [config.latitude, config.longitude]
        ApiClient.fetch(lat, lon)
      end

      data = MeteoData.new(data_path)
      printer = Printer.new(data)
      interactive_loop(printer)
    end

    def interactive_loop(printer)
      print_summary

      loop do
        key = STDIN.getch.upcase
        case key
        when 'A'
          print_today
        when 'R'
          print_summary
        when 'Q'
          break
        end
      end
    end

    def determine_data_path(options)
      if options[:data_file]
        File.expand_path(options[:data_file])
      else
        ApiClient::DATA_FILE
      end
    end

    private

    def print_summary
      printer.clear_screen
      printer.display_all
      printer.display_footer
    end

    def print_today
      printer.clear_screen
      printer.display_all_today_hours
      printer.display_footer
    end
  end
end
