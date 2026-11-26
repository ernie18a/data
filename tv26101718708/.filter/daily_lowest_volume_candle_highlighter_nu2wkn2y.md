# Daily Lowest Volume Candle Highlighter

- url: https://www.tradingview.com/script/Nu2WKn2y-Daily-Lowest-Volume-Candle-Highlighter/
- type: indicator
- pine_id: PUB;05e030e56aae4ab490b382bca5550f50
- version: 1.0

## Description

highlights the lowest volume bullish and bearish candles

## Source Code

````pine
//@version=5
indicator("Daily Lowest Volume Candle Highlighter", overlay=true)

// Color Inputs
bullColor = input.color(color.new(#4c00ff, 0), title="Lowest Volume Bullish Candle")
bearColor = input.color(color.new(#b3ff00, 0), title="Lowest Volume Bearish Candle")

// Detect a new trading day
is_new_day = ta.change(time("D")) != 0

// Persistent tracking variables for the current session
var float min_bull_vol = na
var float min_bear_vol = na
var int min_bull_index = na
var int min_bear_index = na

// Reset values at the start of every new day
if is_new_day
    min_bull_vol := na
    min_bear_vol := na
    min_bull_index := na
    min_bear_index := na

// Define directional candles
is_bullish = close > open
is_bearish = close < open

// Track the lowest bullish volume bar of the day
if is_bullish and (na(min_bull_vol) or volume < min_bull_vol)
    min_bull_vol := volume
    min_bull_index := bar_index

// Track the lowest bearish volume bar of the day
if is_bearish and (na(min_bear_vol) or volume < min_bear_vol)
    min_bear_vol := volume
    min_bear_index := bar_index

// Check if the current historical or real-time candle matches the recorded daily lowest index
is_lowest_bull = (bar_index == min_bull_index)
is_lowest_bear = (bar_index == min_bear_index)

// Apply dynamic coloring to chart candles
barcolor(is_lowest_bull ? bullColor : is_lowest_bear ? bearColor : na)
````
