# AKP alternative days indicator

- url: https://www.tradingview.com/script/Mcun68Cx-AKP-alternative-days-indicator/
- type: indicator
- pine_id: PUB;94a88cb9d38f44d18a906a7f3ce2de66
- version: 1.0

## Description

Help to differentiate alternative days

Its usage mainly helpful when you start analysis in intraday time frame anything like below daily time frame

we can customize colors what ever we want

## Source Code

````pine
//@version=5
indicator("Alternate Day Backgrounds", overlay=true)

// --- Inputs ---
color1 = input.color(color.new(color.blue, 92), title="Color A")
color2 = input.color(color.new(color.purple, 92), title="Color B")

// --- Logic ---
// Check if a new day has started based on the exchange time
is_new_day = ta.change(time("D")) != 0

// Maintain a toggle variable that switches between true and false every new day
var bool toggle = false
if is_new_day
    toggle := not toggle

// Determine the background color based on the toggle state
// Only apply if the current timeframe is an intraday timeframe (lower than Daily)
bg_color = timeframe.isintraday ? (toggle ? color1 : color2) : na

// --- Render ---
bgcolor(bg_color, title="Day Shading")
````
