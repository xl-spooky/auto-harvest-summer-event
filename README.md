# Auto Harvest Summer Event

Improved auto-harvest script for **Roblox Grow a Garden** Summer Event, featuring an in-game GUI toggle, exit functionality, efficient plot caching, and high-speed concurrent harvesting.

## Features

- **GUI Toggle**: Easily enable/disable auto-harvesting in-game.
- **Exit Button**: Safely stop the script and remove GUI.
- **Plot Caching**: Keeps an up-to-date list of garden plots for minimal overhead.
- **Concurrent Harvesting**: Fires multiple harvest requests in parallel for speed.
- **Adjustable Interval**: Tweak `HarvestInterval` in `Config.lua` to balance speed and server load.

## Installation

1. Create a new executor script in your preferred Roblox executor.
2. Copy the following line into the executor to load the script dynamically:
   ```lua
   loadstring(game:HttpGet("https://raw.githubusercontent.com/xl-spooky/auto-harvest-summer-event/main/Loader.lua"))()
   ```
3. Run the loader—everything else is fetched automatically from this repo.

## Usage

- **Toggle Auto-Harvest**: Click the **AutoHarvest** button in the top-left corner to turn harvesting on or off.
- **Exit Script**: Click the **Exit** button below the toggle to stop all harvesting loops and remove the GUI.

## File Structure

```
auto-harvest-summer-event/
├── Loader.lua        # Single-line loader for your executor
└── src/
    ├── Main.lua      # Entry point wiring modules together
    ├── Config.lua    # User-configurable settings
    ├── PlotCache.lua # Live caching of garden plots
    ├── Harvester.lua # Concurrent harvest logic
    └── GUI.lua       # In-game toggle & exit buttons
```

## Configuration

- **HarvestInterval**: Modify the delay between harvest cycles in `src/Config.lua` (default `0.1` seconds).

## Contributing

Pull requests, issues, and suggestions are welcome! Feel free to fork the repo, make changes, and submit a PR.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.