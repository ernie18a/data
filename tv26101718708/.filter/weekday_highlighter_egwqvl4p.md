# Weekday Highlighter

- url: https://www.tradingview.com/script/EgwqvL4p-Weekday-Highlighter/
- type: indicator
- pine_id: PUB;b0554cebccd648e8baa3bc4c6e9f5e58
- version: 1.0

## Description

# Weekday Highlighter & Daily Separator

This indicator highlights each trading day with a unique background colour and automatically draws vertical separator lines between days to improve chart structure and readability.

Designed for traders who analyse intraday price action, sessions, liquidity, or daily market behaviour, the script makes it easier to visually distinguish between Monday, Tuesday, Wednesday, Thursday, and Friday directly on the chart.

## Features

• Individual background colour for each weekday
• Automatic vertical separator lines at the start of every new trading day
• Clean and lightweight overlay
• Works on all intraday timeframes
• Useful for forex, indices, crypto, and futures markets

## Weekday Colours

• Monday — Blue
• Tuesday — Green
• Wednesday — Orange
• Thursday — Purple
• Friday — Red

This tool is especially useful for traders who want clearer visual separation between trading sessions and improved day-by-day market analysis.

## Source Code

````pine
//@version=5
indicator("Weekday Highlighter", overlay=true)

// === Day Detection ===
isMonday    = dayofweek == dayofweek.monday
isTuesday   = dayofweek == dayofweek.tuesday
isWednesday = dayofweek == dayofweek.wednesday
isThursday  = dayofweek == dayofweek.thursday
isFriday    = dayofweek == dayofweek.friday

// === Background Colours ===
bgcolor(isMonday    ? color.new(color.orange,    85) : na)
bgcolor(isTuesday   ? color.new(color.green,   85) : na)
bgcolor(isWednesday ? color.new(color.blue,  85) : na)
bgcolor(isThursday  ? color.new(color.purple,  85) : na)
bgcolor(isFriday    ? color.new(color.red,     85) : na)

// === Day Separation Lines ===
newDay = ta.change(time("D"))

if newDay
    line.new(
         x1 = bar_index,
         y1 = low - (ta.atr(14) * 2),
         x2 = bar_index,
         y2 = high + (ta.atr(14) * 2),
         extend = extend.both,
         color = color.white,
         style = line.style_dashed,
         width = 1)
````
