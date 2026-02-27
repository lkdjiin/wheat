require 'json'
require 'date'

WEATHER_CODE = {
  '0' => 'Ciel clair',
  '1' => 'Dégagé',
  '2' => 'Nuageux',
  '3' => 'Couvert',
  '45' => 'Brouillard',
  '51' => 'Averses faibles',
  '53' => 'Averses faibles',
  '55' => 'Averses fortes',
  '61' => 'Pluie faible',
  '63' => 'Pluie faible',
  '65' => 'Pluie forte',
}

DAYS = {
  'Sun' => 'dim',
  'Mon' => 'lun',
  'Tue' => 'mar',
  'Wed' => 'mer',
  'Thu' => 'jeu',
  'Fri' => 'ven',
  'Sat' => 'sam'
}

# ----------------------------------------------------------------------
# Let's try that all public methods return a string.
class MeteoData
  def initialize
    @data = JSON.load_file('open-meteo.json')
  end

  def current_temperature
    "#{current['temperature_2m'].round}"
  end

  def current_description
    desc = current['weather_code'].to_s
    WEATHER_CODE[desc] || "CODE INCONNU #{desc}"
  end

  def current_time
    current['time']
  end

  def hourly_temperature(hour)
    hourly['temperature_2m'][hour].round.to_s
  end

  def hourly_precipitation_probability(hour)
    hourly['precipitation_probability'][hour].to_s
  end

  def hourly_description(hour)
    desc = hourly['weather_code'][hour].to_s
    WEATHER_CODE[desc] || "CODE INCONNU #{desc}"
  end

  def temperature_tomorrow_at_0600
    hourly['temperature_2m'][30].round.to_s
  end

  def temperature_tomorrow_at_1100
    hourly['temperature_2m'][35].round.to_s
  end

  def precipitation_probability_tomorrow_morning
    proba = 0
    30.upto(35).each { |i| proba += hourly['precipitation_probability'][i] }
    (proba / 6).to_s
  end

  def temperature_tomorrow_at_1200
    hourly['temperature_2m'][36].round.to_s
  end

  def temperature_tomorrow_at_1700
    hourly['temperature_2m'][41].round.to_s
  end

  def precipitation_probability_tomorrow_afternoon
    proba = 0
    36.upto(41).each { |i| proba += hourly['precipitation_probability'][i] }
    (proba / 6).to_s
  end

  def two_weeks_date
    daily['time']
  end

  def two_weeks_max_temperature
    daily['temperature_2m_max'].map { _1.round.to_s }
  end

  def two_weeks_min_temperature
    daily['temperature_2m_min'].map { _1.round.to_s }
  end

  def two_weeks_mean_precipitation_probability
    daily['precipitation_probability_mean'].map(&:to_s)
  end

  private

  def current
    @data['current']
  end

  def hourly
    @data['hourly']
  end

  def daily
    @data['daily']
  end
end

# ----------------------------------------------------------------------
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
      puts "#{sprintf('%2d', i)}h #{t}° · #{p}% · #{d}"
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
    14.times do |i|
      print DAYS[temp_d.strftime('%a')]
      print '  '
      temp_d = temp_d.next
    end
    puts
    puts @d.two_weeks_max_temperature.map { sprintf('% 3d°', _1) }.join(" ")
    puts @d.two_weeks_min_temperature.map { sprintf('% 3d°', _1) }.join(" ")
    puts @d.two_weeks_mean_precipitation_probability.map { sprintf('%3d%%', _1) }.join(" ")
    puts
  end
end

# ----------------------------------------------------------------------
data = MeteoData.new
printer = Printer.new(data)
printer.display_current_section
printer.display_next_hours
printer.display_tomorrow
printer.display_two_weeks
