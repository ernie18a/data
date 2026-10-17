# Buy/Sell Volume Surge Analyst [Multi-Format] by Yogesh Raoot 

- url: https://www.tradingview.com/script/S6fLeCLU-Buy-Sell-Volume-Surge-Analyst-Multi-Format-by-Yogesh-Raoot/
- type: indicator
- pine_id: PUB;be5a47fdd9f644508245b0ce5117a657
- version: 1.0

## Description

The Buy/Sell Volume Surge Analyst is a high-performance order flow tool designed to decode what is happening inside the volume bars. By analyzing intrabar price action, it partitions total volume into buying and selling pressure, allowing traders to see who is in control of the market.

Unique Features

Dynamic Volume Partitioning: Uses a sophisticated algorithm to attribute volume to buyers or sellers based on candle body size and wick placement.

Customizable Surge Detection: Instantly identifies "climax" volume or institutional activity when volume exceeds a user-defined multiple of the lookback average.

Global/Local Unit Scaling: Supports Indian Market units (Crores/Lakhs) and International units (Millions/Billions/Trillions), making it readable on any asset—from Penny Stocks to Crypto and Forex.

Heads-Up Dashboard: Includes a real-time table showing precise Buy/Sell figures and the current Volume-to-Average ratio.

How to Trade with this Script

Volume Climax: A yellow surge bar at the end of a long trend often indicates a reversal.

Absorption: If price is falling but the "Buy Volume" in the table is significantly higher than "Sell Volume," it indicates buyers are absorbing the sell orders at a support level.

Breakout Validation: Ensure a breakout is accompanied by a "Surge" (Yellow bar) to confirm it isn't a fake-out.

Disclaimer:
This script is for educational and informational purposes only. It does not constitute financial, investment, or trading advice. Past performance is not indicative of future results. The "Buy/Sell" volume split is an estimation based on price action and not a direct feed of exchange-level buyer/seller data. Trading involves significant risk of loss; always perform your own due diligence or consult a certified financial advisor before making any trading decisions. The author assumes no responsibility for any financial losses incurred from the use of this indicator.

## Source Code

````pine
//@version=5
// © YourUsername
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
indicator("Buy/Sell Volume Surge Analyst", shorttitle="BS-Surge Pro", overlay=false, precision=2)

// --- Inputs ---
g_logic = "Calculation Logic"
lookback = input.int(20, "Lookback Period", minval=1, group=g_logic, tooltip="Number of bars used to calculate average volume.")
surgeMultiplier = input.float(2.0, "Surge Threshold (x Times)", minval=0.1, step=0.1, group=g_logic, tooltip="Highlight bars where volume is X times the average.")

g_display = "Visual & Units"
useCrores = input.bool(true, "Use Indian Units (Cr/L)", group=g_display, tooltip="Toggle between Crore/Lakh and Million/Billion formatting.")
upColor = input.color(color.new(color.green, 50), "Buy Volume Color", group=g_display)
downColor = input.color(color.new(color.red, 50), "Sell Volume Color", group=g_display)
surgeColor = input.color(color.yellow, "Surge Highlight Color", group=g_display)

// --- Formatting Function ---
formatVolume(val) =>
    absVal = math.abs(val)
    result = ""
    if useCrores
        if absVal >= 10000000 
            result := str.tostring(absVal / 10000000, "#.##") + "Cr"
        else if absVal >= 100000 
            result := str.tostring(absVal / 100000, "#.##") + "L"
        else
            result := str.tostring(absVal, "#")
    else
        if absVal >= 1000000000000 
            result := str.tostring(absVal / 1000000000000, "#.##") + "T"
        else if absVal >= 1000000000 
            result := str.tostring(absVal / 1000000000, "#.##") + "B"
        else if absVal >= 1000000 
            result := str.tostring(absVal / 1000000, "#.##") + "M"
        else
            result := str.tostring(absVal, "#")
    result

// --- Calculations ---
totalVol = volume
rangeVal = high - low
divisor = rangeVal == 0 ? 1 : rangeVal
bodySize = math.abs(close - open)
lowerWick = math.min(open, close) - low
upperWick = high - math.max(open, close)

buyVol = totalVol * ((bodySize + lowerWick) / divisor)
sellVol = totalVol * ((bodySize + upperWick) / divisor)

avgVol = ta.sma(totalVol, lookback)
isSurging = totalVol > (avgVol * surgeMultiplier)

// --- Plotting ---
plot(buyVol, title="Buy Volume", style=plot.style_columns, color=isSurging ? surgeColor : upColor)
plot(-sellVol, title="Sell Volume", style=plot.style_columns, color=isSurging ? surgeColor : downColor)
hline(0, "Zero Line", color=color.new(color.gray, 50))

// --- Dashboard Table ---
var table volTable = table.new(position.top_right, 3, 2, border_width = 1, frame_color=color.gray)

if barstate.islast
    float surgeRatio = totalVol / (avgVol == 0 ? 1 : avgVol)
    color ratioColor = isSurging ? color.orange : color.rgb(80, 80, 80)
    
    table.cell(volTable, 0, 0, "Buy Vol", bgcolor=color.new(color.green, 70), text_color=color.white)
    table.cell(volTable, 1, 0, "Sell Vol", bgcolor=color.new(color.red, 70), text_color=color.white)
    table.cell(volTable, 2, 0, "Ratio", bgcolor=color.gray, text_color=color.white)
    
    table.cell(volTable, 0, 1, formatVolume(buyVol), text_color=color.white, bgcolor=color.new(color.black, 20))
    table.cell(volTable, 1, 1, formatVolume(sellVol), text_color=color.white, bgcolor=color.new(color.black, 20))
    table.cell(volTable, 2, 1, str.tostring(surgeRatio, "#.##") + "x", bgcolor=ratioColor, text_color=color.white)
````
