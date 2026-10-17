# Psych Levels [SkaleHub]

- url: https://www.tradingview.com/script/RHapEzgN-Psych-Levels-SkaleHub/
- type: indicator
- pine_id: PUB;cc4a3c52c92f43a68757ac1e5af52a2f
- version: 1.0

## Description

Overview
Markets notoriously react to whole, round numbers. This indicator automatically plots subtle background lines at these psychological grid points to highlight the invisible structural walls of the market.

The Edge
It highlights the exact areas where retail traders typically place their stop-losses and take-profit orders, and where price action frequently stalls out or reverses due to heavy institutional option clustering.

Key Features:

Algorithmic Grid: Automatically calculates and draws horizontal lines at round psychological intervals around the current active price.

Universal Asset Scaling: Fully customizable interval spacing so the tool works perfectly on anything from Bitcoin (1000s) to traditional Stocks (10s) to Forex (0.01s).

Uncluttered Interface: Uses subtle, non-intrusive dotted lines that fade smoothly into the background until the price directly interacts with them.

How to Use

Apply the indicator to your chart.

Adjust the "Grid Interval" in the settings to match the asset you are trading (e.g., set to 10 for a $150 stock, or 0.01 for a forex pair).

Watch for price action to stall, consolidate, or aggressively reject when it hits these lines. Use them as logical, high-probability take-profit targets for your existing trades.

Author's Note
This indicator is part of the SkaleHub Free Starter Library. It is designed to be paired with the SkaleHub Training System to help newer traders build mechanical discipline and systemize their trading process.

## Source Code

````pine
//@version=5
indicator("Psych Levels [SkaleHub]", overlay=true, max_lines_count=100)

// =========================================================================
// 1. INPUT PARAMETERS
// =========================================================================
intervalRaw = input.float(100, title="Grid Interval (Spacing)", tooltip="Set to 1000 for Crypto, 10 or 100 for Stocks, 0.01 for Forex", group="Grid Settings")
lineColor   = input.color(color.new(color.gray, 60), title="Line Color", group="Visuals")
lineStyle   = input.string("Dotted", options=["Solid", "Dotted", "Dashed"], title="Line Style", group="Visuals")

// Prevent division by zero if a user accidentally types 0
interval = math.max(intervalRaw, 0.000001)

// Convert string input to actual line style
get_style(style_str) =>
    style_str == "Solid" ? line.style_solid : style_str == "Dotted" ? line.style_dotted : line.style_dashed

// =========================================================================
// 2. MATH & LINE GENERATION
// =========================================================================
// Create an empty array to store the line IDs
var line[] linesArray = array.new_line()

// Only execute the drawing logic on the most recent live bar to save processing power
if barstate.islast
    // Clear out the old lines from the previous tick to prevent chart clutter
    if array.size(linesArray) > 0
        for i = 0 to array.size(linesArray) - 1
            line.delete(array.get(linesArray, i))
        array.clear(linesArray)
        
    // Calculate the nearest round number based on the current price and user interval
    basePrice = math.floor(close / interval) * interval
    
    // Draw 20 psychological lines above and 20 below the current price
    for i = -20 to 20
        lvl = basePrice + (i * interval)
        
        // Draw the line and extend it infinitely to the left and right
        l = line.new(bar_index - 1, lvl, bar_index, lvl, color=lineColor, style=get_style(lineStyle), width=1, extend=extend.both)
        
        // Save the line ID to the array so it can be managed/deleted on the next tick
        array.push(linesArray, l)
````
