# Projected Crossover Trend

- url: https://www.tradingview.com/script/KOrW5AtY-Projected-Crossover-Trend/
- type: indicator
- pine_id: PUB;e592755d718b407386e3c3b41e00bf54
- version: 1.0

## Description

[b]Projected Crossover Trend[/b] is a directional trend-following indicator built around projected moving average crossover momentum and Market Direction Indicator (MDI) calculations.

Instead of waiting for a traditional moving average crossover, this indicator attempts to measure projected crossover momentum before the crossover fully develops. This helps identify directional shifts earlier while smoothing market noise through the MDI calculation.

[b]Bullish Regime:[/b]
• MDI is positive
• Price is above the slow-length reference close

[b]Bearish Regime:[/b]
• MDI is negative
• Price is below the slow-length reference close

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SchizoQuant

//@version=6
indicator("Projected Crossover Trend", overlay=true)

// USER INPUTS
src         = input.source(title="Source", defval=close, group="MA Settings", tooltip="Choose the price source used to calculate the fast and slow moving averages.")
fastLen     = input.int(title="Fast MA Length", defval=10, minval=2, group="MA Settings", tooltip="Controls the fast EMA. Lower values react faster to short-term price movement.")
slowLen     = input.int(title="Slow MA Length", defval=30, minval=3, group="MA Settings", tooltip="Controls the slow EMA. Higher values create a smoother baseline trend.")
smoothLen   = input.int(title="MDI Smooth Length", defval=5, minval=1, group="Smoothing", tooltip="Smooths the Market Direction Indicator. Increase this if the projected momentum feels too noisy.")
colorBars   = input.bool(title="Color Bars", defval=true, group="Visualization", tooltip="Color the price candles based on the current projected trend direction.")
showSignals = input.bool(title="Show Signals", defval=true, group="Visualization", tooltip="Turn chart LONG and SHORT signal markers on or off.")
longColor   = input.color(title="Bullish Color", defval=color.rgb(57, 255, 20), group="Color Settings", inline="1", tooltip="Main bullish color used for moving averages, signals, and candle coloring.")
shortColor  = input.color(title="Bearish Color", defval=color.rgb(138, 43, 226), group="Color Settings", inline="1", tooltip="Main bearish color used for moving averages, signals, and candle coloring.")

// CALCULATIONS
fastMA = ta.ema(src, fastLen)
slowMA = ta.sma(src, slowLen)

projectedCross = fastLen * (fastMA - slowMA)

mdiRaw = 100 * (projectedCross - projectedCross[1]) / close
mdi = ta.ema(mdiRaw, smoothLen)

var int SQ = 0

if mdi > 0 and close > close[slowLen]
    SQ := 1

if mdi < 0 and close < close[slowLen]
    SQ := -1

longSignal = SQ == 1 and SQ[1] != 1
shortSignal = SQ == -1 and SQ[1] != -1

// PLOTS
barcolor(colorBars ? (SQ == 1 ? longColor : shortColor) : na)
plot(fastMA, title="Fast MA", color=longColor, linewidth=2)
plot(slowMA, title="Slow MA", color=shortColor, linewidth=2)
plotshape(showSignals and longSignal, title="Long Signal", style=shape.triangleup, location=location.belowbar, color=longColor, size=size.small, text="LONG", textcolor=color.white)
plotshape(showSignals and shortSignal, title="Short Signal", style=shape.triangledown, location=location.abovebar, color=shortColor, size=size.small, text="SHORT", textcolor=color.white)

// ALERTS
alertcondition(longSignal, title="Long Signal", message="Projected Crossover Trend LONG Signal on {{ticker}}")
alertcondition(shortSignal, title="Short Signal", message="Projected Crossover Trend SHORT Signal on {{ticker}}")
````
