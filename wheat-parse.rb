require 'json'
require 'date'

WEATHER_CODE = {
  '0' => 'Ciel clair',
  '1' => 'Dégagé',
  '2' => 'Nuageux',
  '3' => 'Couvert',
  '51' => 'Bruine légère',
  '53' => 'Bruine modérée',
  '55' => 'Bruine forte',
}

# Parse data
data = JSON.load_file('open-meteo.json')

current = data['current']
date = current['time'].sub('T', ' · ')
temperature = "#{current['temperature_2m'].round}°"
description = WEATHER_CODE[current['weather_code'].to_s] || 'CODE INCONNU'

# Format data
current_line = "#{temperature} · #{description} · #{date}"

# Display data
puts "=== Maintenant ==="
puts current_line
puts

puts "=== Les prochaines heures ==="
d = DateTime.iso8601(current['time'])
d.hour.upto(d.hour + 7).each do |i|
  break if i >= 24
  t = sprintf('% 3d', data['hourly']['temperature_2m'][i].round)
  p = data['hourly']['precipitation_probability'][i]
  puts "#{i}h #{t}° #{p}%"
end
puts

puts "=== Demain ==="
# Tomorrow morning
# Mean of hours 30 to 35
temp_low = data['hourly']['temperature_2m'][30].round
temp_high = data['hourly']['temperature_2m'][35].round
proba = 0
30.upto(35).each do |i|
  proba += data['hourly']['precipitation_probability'][i]
end
proba = proba / 6
print "matin #{temp_low}°/#{temp_high}° #{proba}% · "

# Tomorrow afternoon
# Mean of hours 36 to 41
temp_low = data['hourly']['temperature_2m'][36].round
temp_high = data['hourly']['temperature_2m'][41].round
proba = 0
36.upto(41).each do |i|
  proba += data['hourly']['precipitation_probability'][i]
end
proba = proba / 6
puts "après-midi #{temp_low}°/#{temp_high}° #{proba}%"
