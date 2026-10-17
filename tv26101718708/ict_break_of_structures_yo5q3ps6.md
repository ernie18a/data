# ICT Break of Structures

- url: https://www.tradingview.com/script/YO5Q3PS6-ICT-Break-of-Structures/
- type: indicator
- pine_id: PUB;f4be3c4917344611879d88b7f0d88e3b
- version: 1.0

## Description

Break of structures MTF timeframe, can be use to determine whether the trend is over or not.

## Source Code

````pine
//@version=6
indicator("TJR's BOS strategy 2.0 (improved version)", overlay=true)

// Inputs
showBOS = input.bool(true, "Show BOS")
bosColorUp = input.color(color.blue, "Up BOS Color")
bosColorDown = input.color(color.red, "Down BOS Color")

// Variables
var float lastHigh = na
var float lastLow = na
var int lastHighBar = na
var int lastLowBar = na
var line[] allBosLines = array.new_line()
var bool allowUpBOS = true
var bool allowDownBOS = true

// --- Strict Swing Detection ---
// High = Bullish -> Bearish (using highest wick)
if close[1] > open[1] and close < open
    lastHigh := math.max(high[1], high) // Takes highest wick between the two candles
    lastHighBar := high[1] > high ? bar_index[1] : bar_index

// Low = Bearish -> Bullish (using lowest wick)
if close[1] < open[1] and close > open
    lastLow := math.min(low[1], low) // Takes lowest wick between the two candles
    lastLowBar := low[1] < low ? bar_index[1] : bar_index

// --- BOS Logic ---
// UP BOS (only if allowed)
if showBOS and not na(lastHigh) and close > lastHigh and allowUpBOS
    array.push(allBosLines, line.new(lastHighBar, lastHigh, bar_index, lastHigh,  color=bosColorUp, width=2))
    allowUpBOS := false
    allowDownBOS := true

// DOWN BOS (only if allowed)
if showBOS and not na(lastLow) and close < lastLow and allowDownBOS
    array.push(allBosLines, line.new(lastLowBar, lastLow, bar_index, lastLow,color=bosColorDown, width=2))
    allowDownBOS := false
    allowUpBOS := true

// Keep last 500 BOS marks
if array.size(allBosLines) > 500
    line.delete(array.shift(allBosLines))
````
