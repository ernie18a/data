# Phantom Range Bar

- url: https://www.tradingview.com/script/yB0BjTnY-Phantom-Range-Bar/
- type: indicator
- pine_id: PUB;c77408649ee548539b674a0cf1410c24
- version: 1.0

## Description

Phantom Range Bar is a specialized visual utility designed specifically for traders using Range charts (such as CME NQ/ES futures). It provides a clean, "Phantom" aesthetic to the live developing candle, allowing traders to distinguish between confirmed historical data and the active, high-volatility price action of the current bar.

Key Features
Phantom Developing Candle: Unlike standard indicators that recolor the entire chart, this script targets ONLY the live developing bar (barstate.islast). It applies a distinct "Phantom" color scheme—defaulting to professional Grey for bullish movement and Deep Charcoal for bearish movement.
Intelligent Range Detection: The script is built with a self-aware engine that detects the chart type. It automatically remains invisible on standard time-based charts (1m, 5m, Daily, etc.) and only activates when it detects a Range timeframe modifier ("R"). This keeps your workspace clean when switching between different chart types.
Independent Wick & Body Control: High-precision traders can independently adjust the colors for both the candle body and the wicks, ensuring the "Phantom" bar is perfectly tuned to your specific chart background and theme.
Zero Historical Interference: Historical bars remain completely untouched and retain their native chart colors, ensuring your backtesting and technical analysis remain clear and undistorted.
Why use Phantom Range Bar?
On Range charts, the live bar can often be visually distracting or blend too much with historical data. By applying a "Phantom" state to the active bar, traders get an immediate visual cue that price is currently in a state of flux. This indicator is designed to be used alongside the platform’s native Ask/Bid price lines for a high-performance, lag-free execution environment.

Settings

**TURN OFF PHANTOM BARS IN CANDLE STICK SETTINGS ON YOUR CHART SETTINGS

Phantom Bull/Bear Body: Set the color for the live candle body.
Wick Colors: Customize the wicks and borders to match or contrast with your body colors.
Automatic Suppression: No settings required—the script stays hidden on non-range charts automatically.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("Phantom Range Bar", overlay = true)

// --- Inputs ---
gp1 = "Phantom Candle"
bullColorInput     = input.color(color.gray, "Phantom Bull Body", inline = "c1", group = gp1)
bullWickColorInput = input.color(color.gray, "Wick", inline = "c1", group = gp1)

bearColorInput     = input.color(#131722, "Phantom Bear Body", inline = "c2", group = gp1)
bearWickColorInput = input.color(#131722, "Wick", inline = "c2", group = gp1)

// --- Chart Type Validation ---
// Range charts use 'R' in their timeframe period string (e.g., '24R').
// We check for this to ensure the indicator only runs on Range charts.
isRangeChart = str.contains(timeframe.period, "R")

// --- Phantom Developing Candle ---
// Only trigger if we are on the last bar AND it is a Range chart.
isLastAndRange = barstate.islast and isRangeChart

plotCandleOpen   = isLastAndRange ? open  : na
plotCandleHigh   = isLastAndRange ? high  : na
plotCandleLow    = isLastAndRange ? low   : na
plotCandleClose  = isLastAndRange ? close : na

// Determine colors
isBull = close >= open
bodyColor = isBull ? bullColorInput : bearColorInput
wickColor = isBull ? bullWickColorInput : bearWickColorInput

// Render the Phantom Candle
plotcandle(plotCandleOpen, plotCandleHigh, plotCandleLow, plotCandleClose, 
     title       = "Phantom Candle", 
     color       = bodyColor, 
     wickcolor   = wickColor, 
     bordercolor = wickColor)

// Hide the native candle color on the last bar only if it's a Range chart.
// On time-based charts, this remains 'na', so original candles are shown.
barcolor(isLastAndRange ? color.new(chart.bg_color, 100) : na, title = "Hide Native Last Bar")
````
