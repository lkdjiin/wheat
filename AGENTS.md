# AGENTS.md

## Project Overview
**Wheat** is a Ruby gem that fetches weather data from the Open-Meteo API and displays current conditions, hourly forecasts, tomorrow's weather, and a 2-week trend.

## Running the Application

```bash
wheat                          # Fetch fresh data and display weather
wheat --offline               # Use cached data without fetching
wheat --data FILE             # Load JSON from FILE (for testing)
wheat --help                  # Show help message
wheat --version               # Show gem version
```

## Gem Commands

```bash
bundle install                 # Install dependencies
rake build                    # Build gem: pkg/wheat-*.gem
rake install                  # Install gem locally
rake test                     # Run tests
bundle exec rspec             # Run tests with bundler
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | API timeout (too slow after 5 seconds) |

## Running Tests

```bash
rake test                      # Run all tests
bundle exec rspec             # Run tests with bundler
bundle exec rspec spec/wheat_spec.rb  # Run single test file
```

## Code Style Guidelines

### General Principles
- Write clean, readable code prioritizing clarity over cleverness
- Keep methods short and focused on a single responsibility
- Use descriptive names for variables, methods, and classes

### Naming Conventions
| Element | Convention | Example |
|---------|------------|---------|
| Classes | CamelCase | `MeteoData`, `Printer`, `ApiClient` |
| Methods | snake_case | `current_temperature`, `display_tomorrow` |
| Constants | UPPER_SNAKE_CASE | `WEATHER_CODE`, `DAYS`, `VERSION` |
| Variables | snake_case | `@data`, `@d`, `@date` |

### Ruby Idioms
- Use string interpolation (`"#{variable}"`) instead of concatenation
- Use `require_relative` for loading local files in the same project
- Use numbered parameters in blocks when the meaning is clear: `{ _1.round.to_s }`
- Prefer `||=` for memoization when appropriate
- Use `system()` for executing shell commands

### Formatting
- Use 2 spaces for indentation (no tabs)
- No trailing whitespace
- One space after `#` in comments
- Separate logical sections with `# ------` comment lines
- Line length should be less than 80 characters and MUST be less than 100 characters

### Error Handling
- Use `||` with fallback values for missing keys: `WEATHER_CODE[desc] || "DEFAULT"`
- Format unknown codes clearly: `"CODE INCONNU #{desc}"`
- Consider edge cases (e.g., `break` when index exceeds bounds)

### Constants and Data Structures
```ruby
WEATHER_CODE = {
  '0' => 'Ciel clair',
  '1' => 'Dégagé',
  # ...
}

DAYS = {
  'Sun' => 'dim',
  'Mon' => 'lun',
  # ...
}
```

## Project Structure

```
wheat/
├── lib/
│   ├── wheat.rb               # Main require: require 'wheat'
│   └── wheat/
│       ├── version.rb         # WHEAT_VERSION
│       ├── api_client.rb      # API fetching logic
│       ├── config.rb          # Config file management
│       ├── meteo_data.rb      # Weather data parsing
│       ├── printer.rb         # Display output
│       └── cli.rb             # CLI argument parsing
├── bin/
│   └── wheat                  # CLI executable
├── spec/
│   └── wheat_spec.rb          # Tests
├── config/
│   └── wheat.yml.example      # Example config
├── Gemfile                    # Dependencies
├── wheat.gemspec              # Gem specification
├── Rakefile                   # Rake tasks
└── AGENTS.md                  # This file
```

## Dependencies
- Ruby standard library only (`json`, `date`, `yaml`, `optparse`)
- External: `curl` for HTTP requests

## Configuration

Config file location: `~/.config/wheat/wheat.yml`
Data cache location: `~/.config/wheat/data.json`

```yaml
latitude: 49.771295
longitude: 4.724286
```

### Implicit Offline Mode

The app automatically runs in offline mode when the cached data is fresh enough. Open-Meteo API updates data every 15 minutes (at minutes 0, 15, 30, and 45 of each hour). If the current time is within the same quarter-hour as the cached report time, no fresh data is available yet, so the app uses cached data.

| Current Time | Cached Time | Action |
|--------------|-------------|--------|
| 16h43 | 16h30 | Run offline (same quarter) |
| 16h46 | 16h30 | Fetch fresh (different quarter) |
| 17h05 | 16h30 | Fetch fresh (different hour) |

This behavior can be overridden with `--offline` to force using cache, or by specifying `--data FILE` to load from a specific file.

## Key Classes

### `Wheat::MeteoData`
- Reads and provides access to weather data from JSON
- Public methods return formatted strings for display
- Private helpers: `current`, `hourly`, `daily`

### `Wheat::Printer`
- Takes a `MeteoData` instance
- Contains display methods for each section of the report
- Uses `@d` for data, `@date` for date parsing

### `Wheat::Config`
- Loads `~/.config/wheat/wheat.yml`
- Provides `latitude` and `longitude` attributes

### `Wheat::ApiClient`
- Fetches data from Open-Meteo API via curl
- Saves to `~/.config/wheat/data.json`

### `Wheat::CLI`
- Handles command-line options via OptionParser
- Options: `--help`, `--version`, `--offline`, `--data`, `--location`

## Common Tasks

### Adding a New Weather Code
Edit `WEATHER_CODE` hash in `lib/wheat/meteo_data.rb`

### Adding a New Display Section
1. Add a public method to `Wheat::MeteoData` that returns a string
2. Add a display method to `Wheat::Printer`
3. Call the new method from `Printer#display_all`

### Modifying API Request
Edit URL construction in `lib/wheat/api_client.rb`

## API Reference
Open-Meteo API documentation: https://open-meteo.com/en/docs
