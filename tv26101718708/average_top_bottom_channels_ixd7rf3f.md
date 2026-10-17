# Average Top / Bottom Channels

- url: https://www.tradingview.com/script/ixD7rF3f-Average-Top-Bottom-Channels/
- type: indicator
- pine_id: PUB;9bd8d0fc09ef4d40ae50bb5bd2c318c3
- version: 1.0

## Description

This script is designed to simplify price action by creating an average top and average bottom channel around the market. Instead of focusing on every candle, wick, and short-term price fluctuation, the indicator calculates recent swing highs and swing lows, averages them, and displays a clean visual range where price is moving over time.

The upper line represents the average of recent price tops, while the lower line represents the average of recent price bottoms. The area between them acts like a simplified trend channel, helping identify whether price is moving higher, lower, sideways, or stretching outside its normal range.

My preferred way to use this script is to hide the regular price chart after adding the indicator. This removes visual noise from the candles and makes it easier to focus on the overall direction, structure, and trend behavior. After that, I adjust the settings to fit the market and timeframe I am viewing.

Lower sensitivity settings make the channel react faster to recent price movement, while higher sensitivity settings create a smoother channel for broader trend analysis. The goal is not to predict every candle, but to simplify the chart so the larger trend and average price range become easier to see.

## Source Code

````pine
//@version=6
indicator("Average Top / Bottom Channel", overlay=true, max_labels_count=500)

// Inputs
pivotLen  = input.int(5, "Swing sensitivity", minval=1, tooltip="Higher = smoother, slower channel. Lower = faster, noisier channel.")
avgCount  = input.int(8, "Number of tops/bottoms to average", minval=1)
useWicks  = input.bool(true, "Use wicks instead of closes")
atrBuffer = input.float(0.0, "ATR buffer", step=0.1, tooltip="Adds extra space above/below the channel.")
atrLen    = input.int(14, "ATR length", minval=1)
showBreaks = input.bool(true, "Show breakout markers")

// Sources
topSource = useWicks ? high : close
botSource = useWicks ? low : close

// Detect swing highs/lows
pivotHigh = ta.pivothigh(topSource, pivotLen, pivotLen)
pivotLow  = ta.pivotlow(botSource, pivotLen, pivotLen)

// Store recent swing highs/lows
var float[] topArray = array.new_float()
var float[] botArray = array.new_float()

if not na(pivotHigh)
    array.unshift(topArray, pivotHigh)
    if array.size(topArray) > avgCount
        array.pop(topArray)

if not na(pivotLow)
    array.unshift(botArray, pivotLow)
    if array.size(botArray) > avgCount
        array.pop(botArray)

// Average tops and bottoms
avgTop = array.size(topArray) > 0 ? array.avg(topArray) : na
avgBot = array.size(botArray) > 0 ? array.avg(botArray) : na

// Optional ATR buffer
atr = ta.atr(atrLen)
upperChannel = avgTop + atr * atrBuffer
lowerChannel = avgBot - atr * atrBuffer
middleChannel = not na(upperChannel) and not na(lowerChannel) ? (upperChannel + lowerChannel) / 2 : na

// Plots
upperPlot = plot(upperChannel, "Average Top", color=color.new(color.red, 0), linewidth=2)
lowerPlot = plot(lowerChannel, "Average Bottom", color=color.new(color.green, 0), linewidth=2)
middlePlot = plot(middleChannel, "Middle", color=color.new(color.gray, 0), linewidth=1)

fill(upperPlot, lowerPlot, color=color.new(color.gray, 88), title="Channel Fill")

// Breakout signals
breakAbove = ta.crossover(close, upperChannel)
breakBelow = ta.crossunder(close, lowerChannel)

plotshape(showBreaks and breakAbove, title="Break Above", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, text="Break ↑")
plotshape(showBreaks and breakBelow, title="Break Below", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="Break ↓")

// Alerts
alertcondition(breakAbove, title="Price broke above channel", message="Price broke above the average top channel.")
alertcondition(breakBelow, title="Price broke below channel", message="Price broke below the average bottom channel.")
````
