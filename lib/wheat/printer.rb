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

  class Printer
    def initialize(data)
      @d = data
      @date = DateTime.iso8601(@d.current_time)
    end

    def display_current_section
      temp = @d.current_temperature
      desc = @d.current_description
      date = @d.current_time.sub('T', ' · rapport : ')
      puts "=== Maintenant ==="
      puts "#{temp}° · #{desc} · #{date}"
      puts
    end

    def display_next_hours
      puts "=== Aujourd'hui ==="
      @date.hour.upto(@date.hour + 7).each do |i|
        break if i >= 24
        t = sprintf('% 3d', @d.hourly_temperature(i))
        p = @d.hourly_precipitation_probability(i)
        d = @d.hourly_description(i)
        puts "#{sprintf('%2d', i)}h #{t}° · #{d}" + (p == '0' ? "" : " (#{p}%)")
      end
      puts
    end

    def display_tomorrow
      puts "=== Demain ==="
      temp_lo = @d.temperature_tomorrow_at_0600
      temp_hi = @d.temperature_tomorrow_at_1100
      proba = @d.precipitation_probability_tomorrow_morning
      print "matin #{temp_lo}°/#{temp_hi}° #{proba}% · "
      temp_lo = @d.temperature_tomorrow_at_1200
      temp_hi = @d.temperature_tomorrow_at_1700
      proba = @d.precipitation_probability_tomorrow_afternoon
      puts "après-midi #{temp_lo}°/#{temp_hi}° #{proba}%"
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
      puts @d.two_weeks_max_temperature.map { sprintf('% 3d°', _1) }.join(" ")
      puts @d.two_weeks_min_temperature.map { sprintf('% 3d°', _1) }.join(" ")
      puts @d.two_weeks_mean_precipitation_probability.map {
        _1 == '0' ? '    ' : sprintf('%3d%%', _1)
      }.join(" ")
      puts
    end

    def display_all
      display_current_section
      display_next_hours
      display_tomorrow
      display_two_weeks
    end
  end
end
