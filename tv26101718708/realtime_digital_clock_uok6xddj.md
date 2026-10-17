# Real-Time Digital Clock

- url: https://www.tradingview.com/script/UOK6XDDJ-Real-Time-Digital-Clock/
- type: indicator
- pine_id: PUB;49fa31b7f62b4d6e863acb99368ac64a
- version: 1.0

## Description

This is a Minimalist 12-Hour Digital Clock for TradingView that stays fixed to your screen while you trade.
What it does:
Live 12-Hour Time: Displays the current time in HH:MM:SS AM/PM format.
Stays in Place: Unlike price labels, this clock is "pinned" to your screen so it won't move when you scroll your chart.
Real-World Time: It uses your computer's current time (timenow) rather than the time on the candles.
Customizable: You can change the size, colors, and corner position (Top-Right, Bottom-Left, etc.) in the settings.
Auto-Timezone: Matches the time to the exchange you are currently viewing.
Note: For the smoothest "always-running" experience, use this on 24/7 markets like Crypto or Forex.

## Source Code

````pine
//@version=5
indicator("Real-Time Digital Clock", overlay = true)

// Settings: Change where the clock sits on your screen
pos_v = input.string("top", "Vertical Position", options = ["top", "middle", "bottom"])
pos_h = input.string("right", "Horizontal Position", options = ["left", "center", "right"])
t_size = input.string("large", "Clock Size", options = ["small", "normal", "large", "huge"])

// 1. Create a table that stays fixed on the screen (not the candles)
var table clockTable = table.new(pos_v + "_" + pos_h, 1, 1)

// 2. Logic to update the time
// We use 'timenow' for real-world time and 'hh:mm:ss a' for 12hr + AM/PM
if barstate.islast
    string liveTime = str.format_time(timenow, "hh:mm:ss a", syminfo.timezone)
    
    // 3. Put the time into the table cell
    table.cell(clockTable, 0, 0, liveTime, 
         text_color = color.white, 
         bgcolor = color.new(#131722, 0), // TradingView dark theme background
         text_size = t_size)
````
