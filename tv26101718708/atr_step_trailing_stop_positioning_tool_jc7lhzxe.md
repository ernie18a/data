# ATR Step Trailing Stop Positioning Tool

- url: https://www.tradingview.com/script/jC7LhZxE-ATR-Step-Trailing-Stop-Positioning-Tool/
- type: indicator
- pine_id: PUB;400336144b1b44fd8f1e66f8e622fb50
- version: 1.0

## Description

This indicator is an ATR-based trailing stop positioning tool.

It is not designed to generate buy or sell signals. Its purpose is to help traders visualize possible trailing stop levels based on volatility.

How it works:

The indicator calculates a stepped trailing level using the ATR distance from the high or low of the last closed candle.

For long-position management, the stop level can be positioned below price using the candle low and an ATR-based distance.

For short-position management, the stop level can be positioned above price using the candle high and an ATR-based distance.

Because the calculation is based on the last closed candle, the level is designed to behave like a step-style trailing reference instead of constantly moving tick by tick.

How this is different from a standard ATR trailing stop:

Many ATR stop indicators use a continuous trailing line or a single shared configuration for both long and short conditions.

This version is focused specifically on stop placement structure. It allows the trader to visualize ATR-based stop levels as stepped references from the most recent completed candle.

Another practical difference is that traders can add two instances of the indicator to the same chart. For example, one instance can be adjusted for long trailing stop management and another for short trailing stop management. By changing the visibility or transparency settings, it is possible to show only the positive or negative side of each instance and compare different ATR lengths or ATR multipliers for long and short positioning.

This makes the tool useful when a trader wants different trailing stop behavior for long and short positions instead of using one universal setting.

Possible use cases:

* Visualizing ATR-based trailing stop zones
* Managing open trades with a volatility-adjusted stop reference
* Comparing different ATR lengths or multipliers
* Separating long-side and short-side stop logic
* Studying how price behaves around volatility-based stop levels

Important limitation:

This indicator does not predict direction. It does not provide entry signals, exit signals, buy signals, or sell signals. The plotted levels are only a technical reference for trailing stop positioning based on ATR and closed candle structure.

Traders should combine this tool with their own entry logic, market structure analysis, risk management rules, and broader trading plan.

## Source Code

````pine
//@version=5
indicator("Stop ATR [TAG]", overlay=true)

//This indicator is different because we have a step under/above previous closed bar.
//It's ideal as a trailing stop.
//I use as trade signal with 2 ATR breakout and 3 ATR trailing stop

// Input parameters
length = input.int(20, "ATR Length", minval=1)
multiplier = input.float(2.0, "ATR Multiplier", minval=0.1, step=0.1)
src = input(close, "Source")

// Colors
upColor = input.color(color.green, "Up Trend Color")
downColor = input.color(color.red, "Down Trend Color")

// Candle coloring option
colorCandles = input.bool(true, "Color Candles")

// Calculate ATR
atr = ta.atr(length)

// Initialize variables
var float stopLevel = na
var bool isUpTrend = true

// Calculate stop levels
longStop = src - atr * multiplier
shortStop = src + atr * multiplier

// Initialize stop level on first bar
if na(stopLevel)
    stopLevel := longStop
    isUpTrend := true

// Update stop level and trend
if isUpTrend
    // In uptrend, use long stop (below price)
    stopLevel := math.max(stopLevel, longStop)
    
    // Check if price broke below stop
    if close < stopLevel
        isUpTrend := false
        stopLevel := shortStop
else
    // In downtrend, use short stop (above price)
    stopLevel := math.min(stopLevel, shortStop)
    
    // Check if price broke above stop
    if close > stopLevel
        isUpTrend := true
        stopLevel := longStop

// Plot the stop line
plot(stopLevel, "Stop ATR", color=isUpTrend ? upColor : downColor, linewidth=2, style=plot.style_stepline)

// Color candles based on trend
barcolor(colorCandles ? (isUpTrend ? upColor : downColor) : na, title="Bar Color")

// Optional: Plot buy/sell signals when trend changes
plotshape(isUpTrend and not isUpTrend[1], "Buy Signal", shape.triangleup, location.belowbar, color.green, size=size.small)
plotshape(not isUpTrend and isUpTrend[1], "Sell Signal", shape.triangledown, location.abovebar, color.red, size=size.small)

// Alert conditions
alertcondition(isUpTrend and not isUpTrend[1], "Bullish Reversal", "Stop ATR: Bullish reversal detected")
alertcondition(not isUpTrend and isUpTrend[1], "Bearish Reversal", "Stop ATR: Bearish reversal detected")
````
