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
  RESET = "\e[0m"

  class Printer
    def initialize(data)
      @d = data
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
      wind = @d.current_wind
      puts "=== Maintenant (#{wind} km/h) ==="
      puts "#{colorize_temperature(temp)} · #{desc} · #{date}"
      puts
    end

    def display_next_hours
      wind = @d.wind_today
      puts "=== Aujourd'hui (#{wind} km/h) ==="
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
      precip = p == '0' ? '' : " (#{p}%)"
      hour = sprintf('%2d', i)
      temp = colorize_temperature(sprintf('% 3d', t))
      puts "#{hour}h #{temp} · #{d}#{precip}"
    end

    def display_tomorrow
      wind = @d.wind_tomorrow
      puts "=== Demain (#{wind} km/h) ==="
      temp_lo = @d.temperature_tomorrow_at_0600
      temp_hi = @d.temperature_tomorrow_at_1100
      proba = @d.precipitation_probability_tomorrow_morning
      temps = "#{colorize_temperature(temp_lo)}/" \
        "#{colorize_temperature(temp_hi)}"
      print "matin #{temps} #{proba}% · "
      temp_lo = @d.temperature_tomorrow_at_1200
      temp_hi = @d.temperature_tomorrow_at_1700
      proba = @d.precipitation_probability_tomorrow_afternoon
      temps = "#{colorize_temperature(temp_lo)}/" \
        "#{colorize_temperature(temp_hi)}"
      print "après-midi #{temps} #{proba}%"
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

    private

    def colorize_temperature(temp)
      t = temp.to_i
      t <= 0 ? "#{BLUE}#{temp}°#{RESET}" : "#{temp}°"
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

      wind = @d.two_weeks_wind[from_to].map { sprintf('| % 3dkm/h', _1) }
      puts wind.join(" ") + " |"

      puts horizontal_separator
    end
  end
end
