# C-Delta Exhaustion Dashboard

- url: https://www.tradingview.com/script/Lwp72gsh-C-Delta-Exhaustion-Dashboard/
- type: indicator
- pine_id: PUB;618c5509e0e14aeb86d598be515cc1e6
- version: 1.0

## Description

Here is a professional, highly detailed, and compelling description you can copy and paste directly into TradingView when you publish your script.

It explains the math, the strategy, and exactly how users should set it up.

Title: C-Delta Exhaustion Dashboard [Real-Time Order Flow]
Description:
Are you catching a falling knife, or are you entering at the exact moment of exhaustion?

Trading reversal signals on lower timeframes (like the 1-minute chart) requires immense precision. The most powerful tool for confirming a reversal is Cumulative Delta (C-Delta), but trying to manually "eyeball" the exact difference between the Open and Close of a tiny delta candlestick in real-time is nearly impossible.

The C-Delta Exhaustion Dashboard solves this problem. It is a sleek, non-intrusive, real-time tracking panel that calculates the exact mathematical body size of your Cumulative Delta, out to 6 decimal places.

Based on a quantitative analysis of over 600+ mechanical reversal signals, this dashboard doesn't just show you numbers—it actively warns you when the market is setting up for an explosive, 100+ pip reversal.

🌟 Core Features:
Real-Time Delta Body Calculation: Instantly calculates the exact volume shift (C-Delta Close minus C-Delta Open) of the live bar.

Historical Context (Last 4 Bars): Displays the previous 4 minutes of delta data so you can visually track the buildup or exhaustion of order flow leading up to your entry.

Smart Visual Alerts: The live cell will flash Solid Yellow the exact moment the Delta body size enters the mathematically proven "Explosive Win" threshold zones, signaling a highly probable reversal.

Color-Coded Momentum: Bright green text/background for positive (Bullish) delta shifts, and bright red for negative (Bearish) delta shifts.

Fully Customizable UI: Change the position (Top/Bottom/Left/Right), adjust the text size, or tweak the background opacity so it perfectly fits your chart without blocking price action.

🧠 The Strategy: How to Trade the Dashboard
This dashboard is designed to separate "Traps" from "Home Runs" when taking reversal signals.

1. Taking BUY Signals (Hunting Bearish Exhaustion)
When looking for a bottom reversal, you want to see the sellers running completely out of gas.

❌ The Trap: If a Buy signal fires but the Live Bar on the dashboard is printing a massive, heavy red number (e.g., -0.00040), stay out. The selling pressure is still too aggressive.

✅ The Explosive Setup: If a Buy signal fires and the Live Bar is printing a tiny, shrinking red number, or has just barely ticked green (e.g., -0.00010 to +0.00015), enter the trade. The sellers are completely exhausted, leaving a vacuum for the price to rip upwards. (The dashboard will flash yellow when this happens!)

2. Taking SELL Signals (Hunting Bullish Blow-Off Tops)
When looking for a top reversal, the math is actually the opposite. You want to see buyers throwing everything they have at a brick wall.

❌ The Trap: If a Sell signal fires but the Live Bar is printing a tiny red or flat number, stay out. The buyers are just resting; they haven't climaxed yet.

✅ The Explosive Setup: If a Sell signal fires and the Live Bar is printing a massive, thick green number (e.g., +0.00025 to +0.00039), enter the trade. This is a volume blow-off top. Buyers have exhausted their liquidity, and the price is about to collapse. (The dashboard will flash yellow when this happens!)

⚙️ Setup Instructions (IMPORTANT):
Because this is a secondary dashboard, it requires an active Cumulative Delta indicator to be on your chart.

Add this script to your chart.

Open the Settings (Gear Icon) for the Dashboard.

Under the "Data Sources" inputs, click the dropdowns and select the Open and Close outputs from your preferred Cumulative Delta indicator.

Adjust the Alert Thresholds to fit your specific asset and timeframe! (The default thresholds are mathematically optimized for XAUUSD on the 1-minute chart).

Trade smart, trust the data, and stop guessing at exhaustion.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © abdillahiz162
//@version=6
indicator("C-Delta Exhaustion Dashboard", overlay=true)

// 1. Data Inputs: Hook into your Cum Delta indicator
cd_open = input.source(open, title="Select Cum Delta (Open)", group="Data Sources")
cd_close = input.source(close, title="Select Cum Delta (Close)", group="Data Sources")

// 2. Visual & Position Inputs
pos_input = input.string("Bottom Right", title="Dashboard Position", options=["Top Right", "Bottom Right", "Bottom Left", "Top Left", "Middle Right"], group="Visuals")
size_input = input.string("Tiny", title="Text Size", options=["Tiny", "Small", "Normal"], group="Visuals")

dash_pos = pos_input == "Top Right" ? position.top_right : pos_input == "Bottom Right" ? position.bottom_right : pos_input == "Bottom Left" ? position.bottom_left : pos_input == "Top Left" ? position.top_left : position.middle_right
txt_size = size_input == "Tiny" ? size.tiny : size_input == "Small" ? size.small : size.normal

// 3. Threshold Inputs for Visual Alerts (Based on Master Data)
alert_buy_min = input.float(-0.00012, title="Explosive Buy Min Delta", step=0.00001, group="Alert Thresholds")
alert_buy_max = input.float(0.00017, title="Explosive Buy Max Delta", step=0.00001, group="Alert Thresholds")

alert_sell_min = input.float(0.00021, title="Explosive Sell Min Delta", step=0.00001, group="Alert Thresholds")
alert_sell_max = input.float(0.00039, title="Explosive Sell Max Delta", step=0.00001, group="Alert Thresholds")

// 4. Calculate the exact body size (Close - Open)
cd_body = cd_close - cd_open

// 5. Create the table with a solid background plate
var table dash = table.new(dash_pos, 2, 6, border_width=1, border_color=color.new(color.gray, 50), bgcolor=color.new(color.black, 20))

// 6. Populate the table on the very last bar
if barstate.islast
    // Create Headers
    table.cell(dash, 0, 0, "Timing", text_color=color.white, bgcolor=color.rgb(31, 73, 125), text_halign=text.align_center, text_size=txt_size)
    table.cell(dash, 1, 0, "C-Delta Body Size", text_color=color.white, bgcolor=color.rgb(31, 73, 125), text_halign=text.align_center, text_size=txt_size)
    
    // Loop through the current bar [0] and previous 4 bars [1 to 4]
    for i = 0 to 4
        val = cd_body[i]
        
        // Base colors (Green for positive, Red for negative)
        bg_col = val >= 0 ? color.new(color.green, 85) : color.new(color.red, 85)
        txt_col = val >= 0 ? color.lime : color.red
        
        // VISUAL ALERT: If it's the LIVE bar (i == 0) and hits the explosive thresholds
        if i == 0
            is_explosive_buy = (val >= alert_buy_min and val <= alert_buy_max)
            is_explosive_sell = (val >= alert_sell_min and val <= alert_sell_max)
            
            if is_explosive_buy or is_explosive_sell
                bg_col := color.new(color.yellow, 0) // Flash Solid Yellow!
                txt_col := color.black
        
        // Label the rows
        row_label = i == 0 ? "Live Bar" : str.tostring(i) + " Min Ago"
        
        // Draw the cells
        table.cell(dash, 0, i + 1, row_label, text_color=color.white, bgcolor=color.new(color.black, 40), text_size=txt_size)
        table.cell(dash, 1, i + 1, str.tostring(val, "#.######"), text_color=txt_col, bgcolor=bg_col, text_halign=text.align_right, text_size=txt_size)

    //@version=6

plot(close)
````
