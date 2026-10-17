# ES Wick Points Counter

- url: https://www.tradingview.com/script/t8zZJm03-ES-Wick-Points-Counter/
- type: indicator
- pine_id: PUB;195ec4cafe65416585c68c96e6e7e411
- version: 1.0

## Description

This Pine Script code is a TradingView indicator (version 6) designed to quantify and display the size of candlestick wicks specifically for the E-mini S&P 500 futures contract (/ES) in points.

## Source Code

````pine
//@version=6
indicator("ES Wick Points Counter", overlay=true)

// Calculate Wick Sizes in points
// /ES moves in 0.25 point increments (ticks)
tickSize = 0.25
upperWick = (high - math.max(open, close)) / tickSize * tickSize
lowerWick = (math.min(open, close) - low) / tickSize * tickSize

// Only display if there is a wick
if barstate.isconfirmed
    // Upper Wick Label
    if upperWick > 0
        label.new(bar_index, high, text=str.tostring(upperWick, "#.##"), 
             style=label.style_none, textcolor=color.black, 
             yloc=yloc.abovebar)
    
    // Lower Wick Label
    if lowerWick > 0
        label.new(bar_index, low, text=str.tostring(lowerWick, "#.##"), 
             style=label.style_none, textcolor=color.black, 
             yloc=yloc.belowbar)
````
