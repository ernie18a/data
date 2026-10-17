# Dynamic Pump Day Highlighter

- url: https://www.tradingview.com/script/jDGyYvnh-Dynamic-Pump-Day-Highlighter/
- type: indicator
- pine_id: PUB;d4e25eccd3134f778014fd73185e7e59
- version: 1.0

## Description

Dynamic Pump Day Highlighter just a simple chart highlighter for any time frame being used that the stock gained or lost a selected %

## Source Code

````pine
//@version=5
indicator("Dynamic Pump Day Highlighter", overlay=true)

// Adds a setting option in the UI (defaults to 10%)
targetPct = input.float(10.0, title="Target Percentage Change (%)")

// Calculate percentage change from previous close
pctChange = (close - close[1]) / close[1] * 100

// Check if the current bar met or exceeded the user's setting
isBigDay = pctChange >= targetPct

// Highlight the background and plot a green arrow under the bar
bgcolor(isBigDay ? color.new(color.green, 85) : na)
plotshape(isBigDay, style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, title="Target Met")
````
