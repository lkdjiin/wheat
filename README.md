# Wheat

CLI weather report that fetches data from the
[Open-Meteo API](https://open-meteo.com/).

- No API key required (uses the free Open-Meteo API)
- (only) French language output

## Requirements

- Ruby >= 3.0
- `curl`

## Installation

### First build the gem

Clone the repository and install dependencies:

```bash
git clone https://github.com/lkdjiin/wheat.git
cd wheat
bundle install
```

Build the gem:

```bash
rake build
```

This creates the gem file in `pkg/wheat-<version>.gem`.

### Then install it

```bash
rake install
```

## Uninstallation

Remove the gem from your system:

```bash
gem uninstall wheat
```

Also remove the configuration and cache files if desired:

```bash
rm -rf ~/.config/wheat
```

## Configuration

Running `wheat` for the first time will create a config file in
`~/.config/wheat/wheat.yml`.

Replace the coordinates with your location. You can find coordinates on
[latlong.net](https://latlong.net) or similar services.


## Usage

Try `wheat --help` for all options.

### Fetch and display weather

```bash
wheat
```

### Override location

```bash
wheat --location 48.8566,2.3522
```

### Use cached data
Reuse the previously fetched data. Useful for testing.

```bash
wheat --offline
```

### Load data from a file
Also useful for testing.

```bash
wheat --data file.json
```
