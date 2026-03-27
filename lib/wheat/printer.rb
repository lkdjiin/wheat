require 'date'

module Wheat
  DAYS = {
    'Sun' => 'dim',
    'Mon' => 'lun',
    'Tue' => 'mar',
    'Wed' => 'mer',
    'Thu' => 'jeu',
    'Fri' => 'ven',
    'Sat' => 'sam'
  }

  FULL_DAYS = {
    'Sun' => 'dimanche',
    'Mon' => 'lundi',
    'Tue' => 'mardi',
    'Wed' => 'mercredi',
    'Thu' => 'jeudi',
    'Fri' => 'vendredi',
    'Sat' => 'samedi'
  }

  BLUE = "\e[34m"
  RED = "\e[31m"
  ORANGE = "\033[38;5;208m"
  RESET = "\e[0m"

  class Printer

    # Initializes a new Printer to display weather data.
    #
    # data   - MeteoData instance containing weather information
    # config - Configuration hash with color, glyph, wind_glyph settings
    #          'color'          - Boolean whether or not use colors in output.
    #          'glyph'          - Boolean whether or not use glyphs in output.
    #          'wind_glyph'     - String the glyph to symbolize the wind.
    #          'min_wind_speed' - Integer minimum speed to display.
    #
    # Returns a new Printer instance.
    def initialize(data, config: DEFAULT_CONFIG)
      @d = data
      @use_color = config['color']
      @use_glyph = config['glyph']
      @wind_glyph = config['wind_glyph']
      @min_wind_speed = config['min_wind_speed']
      @date = DateTime.iso8601(@d.current_time)
    end

    def print_summary_screen
      clear_screen
      display_summary
      display_footer
    end

    def print_today_screen
      clear_screen
      display_all_today_hours
      display_footer
    end

    def print_tendencies_screen
      clear_screen
      display_tendencies
      display_footer
    end

    def display_current_section
      temp = @d.current_temperature
      desc = @d.current_description
      date = @d.current_time.sub('T', ' · rapport de ')
      puts title_for_section('Maintenant', @d.current_wind)
      puts "#{colorize_temperature(temp)} · #{desc} · #{date}"
      puts
    end

    def display_next_hours
      puts title_for_section("Aujourd'hui", @d.wind_today)
      @date.hour.upto(@date.hour + 7).each do |i|
        break if i >= 24
        display_hour(i)
      end
      puts
    end

    def display_all_today_hours
      puts "=== Aujourd'hui ==="
      0.upto(23).each { |i| display_hour(i) }
      puts
    end

    def display_footer
      puts "[Q]uit [R]ésumé [A]ujourd'hui [T]endances"
    end

    def clear_screen
      system('clear')
    end

    def display_summary
      display_current_section
      display_next_hours
      display_tomorrow
      display_two_weeks
    end

    def display_hour(i)
      t = @d.hourly_temperature(i)
      p = @d.hourly_precipitation_probability(i)
      d = @d.hourly_description(i)
      precip = p == '0' ? '' : " #{precipitation_bar(p)}"
      hour = sprintf('%2d', i)
      temp = colorize_temperature(sprintf('% 3d', t))
      puts "#{hour}h #{temp} · #{d}#{precip}"
    end

    def display_tomorrow
      puts title_for_section('Demain', @d.wind_tomorrow)
      temp_lo = @d.temperature_tomorrow_at_0600
      temp_hi = @d.temperature_tomorrow_at_1100
      proba = @d.precipitation_probability_tomorrow_morning
      temps = "#{colorize_temperature(temp_lo)}/" \
        "#{colorize_temperature(temp_hi)}"
      print "matin #{temps} #{precipitation_bar(proba)} · "
      temp_lo = @d.temperature_tomorrow_at_1200
      temp_hi = @d.temperature_tomorrow_at_1700
      proba = @d.precipitation_probability_tomorrow_afternoon
      temps = "#{colorize_temperature(temp_lo)}/" \
        "#{colorize_temperature(temp_hi)}"
      print "après-midi #{temps} #{precipitation_bar(proba)}"
      puts
      puts
    end

    def display_two_weeks
      puts "=== Tendances sur 2 semaines ==="
      puts " " + @d.two_weeks_date.map { |e| e[8..9] }.join("   ")
      temp_d = @date
      14.times do
        print DAYS[temp_d.strftime('%a')]
        print '  '
        temp_d = temp_d.next
      end
      puts
      max_temps = @d.two_weeks_max_temperature.map {
        colorize_temperature(sprintf('% 3d', _1))
      }.join(" ")
      puts max_temps
      min_temps = @d.two_weeks_min_temperature.map {
        colorize_temperature(sprintf('% 3d', _1))
      }.join(" ")
      puts min_temps
      precip = @d.two_weeks_mean_precipitation_probability.map {
        _1 == '0' ? '    ' : sprintf('%3d%%', _1)
      }.join(" ")
      puts precip
      puts
    end

    def display_tendencies
      puts "=== Tendances sur 2 semaines ==="
      display_tendencies_first_week
      display_tendencies_second_week
    end

    def precipitation_bar(probability)
      return '' unless @use_glyph

      case probability.to_i
      when 75..100
        PRECIPITATION_BAR_GLYPH * 3
      when 50..74
        PRECIPITATION_BAR_GLYPH * 2
      when 1..49
        PRECIPITATION_BAR_GLYPH
      else
        ''
      end
    end

    def wind_description(wind)
      return nil if wind.to_i < @min_wind_speed

      @use_glyph ? "(#{@wind_glyph} #{wind} km/h)" : "(#{wind} km/h)"
    end

    private

    def title_for_section(section_name, wind_speed)
      decoration = '==='
      wind = wind_description(wind_speed)
      [decoration, section_name, wind, decoration].compact.join(' ')
    end

    def colorize_temperature(temp)
      return "#{temp}°" unless @use_color

      t = temp.to_i

      if t <= 0
        "#{BLUE}#{temp}°#{RESET}"
      elsif t >= 30
        "#{RED}#{temp}°#{RESET}"
      elsif t >= 25
        "#{ORANGE}#{temp}°#{RESET}"
      else
        "#{temp}°"
      end
    end

    def display_tendencies_first_week
      display_tendency(0..6)
    end

    def display_tendencies_second_week
      display_tendency(7..13)
    end

    def display_tendency(from_to)
      horizontal_separator = '|' + '---------|' * 7

      puts
      puts horizontal_separator

      dates = @d.two_weeks_date[from_to].map { |e| "  " + e[8..9] + "     |" }
      puts "|" + dates.join

      temp_d = @date
      7.times do
        print sprintf('| %-8s', FULL_DAYS[temp_d.strftime('%a')])
        temp_d = temp_d.next
      end
      puts "|"

      puts horizontal_separator

      max_temps = @d.two_weeks_max_temperature[from_to].map {
        t = sprintf('% 3d', _1)
        "| " + colorize_temperature(t)
      }.join("    ") + "    |"
      puts max_temps

      min_temps = @d.two_weeks_min_temperature[from_to].map {
        t = sprintf('% 3d', _1)
        "| " + colorize_temperature(t)
      }.join("    ") + "    |"
      puts min_temps

      puts horizontal_separator

      precip = @d.two_weeks_mean_precipitation_probability[from_to].map {
        _1 == '0' ? '|     ' : sprintf('| %3d%%', _1)
      }.join("    ") + "    |"
      puts precip

      wind = @d.two_weeks_wind[from_to].map do |value|
        if value.to_i < @min_wind_speed
          '|        '
        else
          sprintf('| % 3dkm/h', value)
        end
      end
      puts wind.join(" ") + " |"

      puts horizontal_separator
    end
  end
end
