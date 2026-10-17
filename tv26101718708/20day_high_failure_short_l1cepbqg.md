# 20-Day High Failure Short

- url: https://www.tradingview.com/script/L1cEpBqG-20-Day-High-Failure-Short/
- type: indicator
- pine_id: PUB;4a07b6330fe747058e737977595498dd
- version: 1.0

## Description

Detect a 20-day high breakout, then short only if that breakout fails within a small number of bars.

So it is a 2-stage setup:

Breakout happens
Breakout fails shortly after
Short signal prints

## Source Code

````pine
//@version=5
indicator("20-Day High Failure Short", overlay=true)

lookback = input.int(20, "Lookback", minval=2)
maxBarsAfterBreakout = input.int(3, "Max bars after breakout for short", minval=1, maxval=10)
showHighLine = input.bool(true, "Show Prior 20D High")

prior20High = ta.highest(high, lookback)[1]

// Step 1: detect breakout above prior 20D high
breakout = close > prior20High and close[1] <= prior20High[1]

// Track most recent breakout bar
var int breakoutBar = na
if breakout
    breakoutBar := bar_index

barsSinceBreakout = na(breakoutBar) ? na : bar_index - breakoutBar

// Step 2: define failed breakout / rejection
// Price made the breakout, then closes back below prior 20D high soon after
failedBreakout = not na(barsSinceBreakout) and barsSinceBreakout <= maxBarsAfterBreakout and close < prior20High

// fire only once per breakout episode
shortSignal = failedBreakout and not failedBreakout[1]

// optional visual for the initial breakout
plotshape(breakout, title="20D Breakout",
     style=shape.circle, location=location.abovebar,
     color=color.new(color.green, 0), size=size.tiny, text="BO")

plotshape(shortSignal, title="Short Failed 20D High",
     style=shape.triangledown, location=location.abovebar,
     color=color.red, size=size.small, text="Short")

plot(showHighLine ? prior20High : na, "Prior 20D High", color=color.blue, linewidth=2)
````
