require 'optparse'

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
          puts "Options:"
          puts "  --offline              Use cached data without fetching from API"
          puts "  --data FILE            Load JSON data from FILE"
          puts "  -l, --location LAT,LON Override config location (e.g., 48.85,2.35)"
          puts "  --version              Show gem version"
          exit
        end

        opts.on('--version', 'Show gem version') do
          puts "wheat #{VERSION}"
          exit
        end

        opts.on('--offline', 'Use cached data without fetching') do
          options[:offline] = true
        end

        opts.on('--data FILE', 'Load JSON data from FILE') do |file|
          options[:data_file] = file
          options[:offline] = true
        end

        opts.on('-l', '--location LAT,LON', 'Override config location') do |loc|
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
      printer.display_all
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
