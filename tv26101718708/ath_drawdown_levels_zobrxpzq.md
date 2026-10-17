# ATH Drawdown Levels

- url: https://www.tradingview.com/script/ZObRXpzQ-ATH-Drawdown-Levels/
- type: indicator
- pine_id: PUB;12fad5b6afd14b08a503f22b01f36865
- version: 1.0

## Description

Overview
This script provides a clean, automated way to track key psychological and technical retracement levels from an asset's All-Time High (ATH). Instead of manually drawing Fibonacci levels or horizontal rays every time a new high is reached, this indicator dynamically updates and projects critical drawdown thresholds across your chart.

Key Features

Dynamic ATH Tracking: Automatically identifies the highest price point in the symbol's history and adjusts levels instantly if a new ATH is set.

Key Retracement Levels: Specifically plots the -5%, -10%, and -15% drawdown marks—common "buy the dip" zones and correction milestones used by long-term investors.

Clean Visuals: Uses dashed lines and price labels positioned to the right of the current bar to ensure your main chart area remains uncluttered.

Ghosting Prevention: Optimized logic ensures that labels and lines move with the price action, preventing the "label stacking" common in many drawdown scripts.

How to Use
Simply add the script to your chart. The levels will automatically appear based on the symbol's historical peak. This is particularly useful for:

Risk Management: Visualizing how far the current price is from its peak.

Entry Strategies: Identifying entry points during healthy market pullbacks.

Portfolio Rebalancing: Monitoring correction depths for long-term holds.

Customization
You can easily adjust the colors for each drawdown level in the Settings > Inputs menu to match your specific chart theme.

## Source Code

````pine
//@version=6
indicator("ATH Drawdown Levels v6", overlay=true, max_lines_count=10, max_labels_count=10)

// --- Inputs ---
color5  = input.color(color.new(color.green, 20), "-5% Color")
color10 = input.color(color.new(color.orange, 20), "-10% Color")
color15 = input.color(color.new(color.red, 20), "-15% Color")

// --- Logic ---
// Track the All-Time High
var float ath = 0.0
ath := math.max(high, ath)

// Calculate the specific drawdown price points
level5  = ath * 0.95
level10 = ath * 0.90
level15 = ath * 0.85

// --- Rendering Function ---
// This function handles the drawing and ensures only one set of lines exists
render_ath_line(float price, string txt, color col) =>
    var line l = na
    var label lb = na
    
    // Remove previous objects to prevent "ghosting" as price moves
    line.delete(l)
    label.delete(lb)
    
    // Create new line and label at the current bar
    l := line.new(bar_index - 50, price, bar_index, price, 
         extend=extend.both, color=col, style=line.style_dashed, width=1)
    lb := label.new(bar_index, price, txt, 
          style=label.style_label_left, textcolor=color.white, color=col, size=size.small)

// Only execute the drawing on the very last bar of the chart
if barstate.islast
    render_ath_line(level5,  "ATH -5%: "  + str.format("{0,number,#.##}", level5),  color5)
    render_ath_line(level10, "ATH -10%: " + str.format("{0,number,#.##}", level10), color10)
    render_ath_line(level15, "ATH -15%: " + str.format("{0,number,#.##}", level15), color15)
````
