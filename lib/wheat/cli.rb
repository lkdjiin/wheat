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

      unless options[:offline] || implicit_offline?(options)
        lat, lon = options[:location] || [config.latitude, config.longitude]
        result = ApiClient.fetch(lat, lon)
        if result == :timeout
          puts "The API is currently too slow. Try again in a few minutes."
          exit EXIT_CODE_API_TOO_SLOW
        end
      end

      data = MeteoData.new(data_path, use_glyph: config.glyph)

      # TODO I think it would be better to pass a single configuration hash
      #      instead of all those key/value pairs.
      printer = Printer.new(data,
                            use_color: config.color,
                            use_glyph: config.glyph,
                            wind_glyph: config.wind_glyph)
      printer.print_summary_screen
      interactive_loop(printer)
    end

    def implicit_offline?(options)
      return false if options[:data_file]
      ApiClient.cache_fresh_enough?
    end

    def interactive_loop(printer)
      loop do
        key = STDIN.getch.upcase
        case key
        when 'A'
          printer.print_today_screen
        when 'R'
          printer.print_summary_screen
        when 'T'
          printer.print_tendencies_screen
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
  end
end
