api = 'https://api.open-meteo.com/v1/forecast?latitude=49.771295&longitude=4.724286'
daily = '&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_mean'
hourly = '&hourly=temperature_2m,precipitation_probability,weather_code'
current = '&current=temperature_2m,weather_code'
tz = '&timezone=auto'
forecast = '&forecast_days=14'

url = "#{api}#{daily}#{hourly}#{current}#{tz}#{forecast}"

command = "curl '#{url}' > open-meteo.json"

system(command)
