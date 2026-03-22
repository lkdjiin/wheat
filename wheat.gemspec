require './lib/wheat/version'

Gem::Specification.new do |s|
  s.name = 'wheat'
  s.version = Wheat.version
  s.summary = 'A simple CLI weather application using Open-Meteo API'
  s.description = 'Fetches weather data from Open-Meteo API and displays current conditions, hourly forecasts, tomorrow weather, and 2-week trend.'
  s.authors = ['Wheat Author']
  s.email = 'author@example.com'
  s.files = Dir['lib/**/*.rb', 'bin/*', 'config/*']
  s.require_paths = ['lib']
  s.executables = ['wheat']
  s.homepage = 'https://github.com/lkdjiin/wheat'
  s.required_ruby_version = '>= 3.0'
end
