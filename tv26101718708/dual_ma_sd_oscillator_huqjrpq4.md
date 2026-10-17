# Dual MA SD Oscillator

- url: https://www.tradingview.com/script/hUqjrpQ4-Dual-MA-SD-Oscillator/
- type: indicator
- pine_id: PUB;13de5032c8ba4e82ad4144ea3040eb15
- version: 2.0

## Description

[b]The Dual MA SD Oscillator[/b] is a momentum and trend-following oscillator designed to measure the spread between a fast and slow moving average, then dynamically filter signals using Standard Deviation bands.

Instead of relying on static thresholds, the oscillator adapts to changing market conditions by expanding and contracting its SD bands based on volatility. This helps reduce noise while still reacting quickly to strong directional moves.

[b]🔹 How It Works:[/b]

[list]
[*]Calculates the spread between a fast and slow EMA
[*]Smooths the spread to reduce market noise
[*]Builds dynamic Standard Deviation bands around the oscillator
[*]Generates a bullish signal when momentum expands above the upper SD band
[*]Generates a bearish signal when momentum drops below the lower SD band
[/list]

[b]🔹 Features:[/b]

[list]
[*]Dynamic volatility-adjusted oscillator
[*]Adaptive Standard Deviation bands
[*]BULL / BEAR trend signals
[*]Optional candle coloring based on trend direction
[*]Clean visual structure for trend confirmation and momentum analysis
[/list]

[b]🔹 Inputs:[/b]

[list]
[*]Fast Length: Lower values react faster to price movement
[*]Slow Length: Higher values create a smoother trend baseline
[*]Smooth Length: Additional smoothing to reduce oscillator noise
[*]SD Lengths: Control the sensitivity of bullish and bearish volatility bands
[/list]

[b]🔹 Best Used For:[/b]

[list]
[*]Momentum confirmation
[*]Trend-following systems
[*]Identifying volatility expansions
[*]Filtering weak market conditions
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SchizoQuant

//@version=6
indicator("Dual MA SD Oscillator", overlay=false)

// USER INPUTS
maSrc       = input.source(title="Source", defval=close, group="MA Settings", tooltip="Choose the price source used to calculate the fast and slow moving averages.")
maFast      = input.int(title="Fast Length", defval=1, minval=1, group="MA Settings", tooltip="Controls the fast EMA. Lower values react faster to price movement.")
maSlow      = input.int(title="Slow Length", defval=30, minval=1, group="MA Settings", tooltip="Controls the slow EMA. Higher values create a smoother baseline trend.")
maSmooth    = input.int(title="Smooth Length", defval=1, minval=1, group="Smoothing", tooltip="Smooths the final oscillator. Increase this if the oscillator feels too noisy.")
upperSDLen  = input.int(title="Upper SD Length", defval=25, minval=1, group="Standard Deviation", tooltip="Sets the lookback for the upper standard deviation band used for bullish signals.")
lowerSDLen  = input.int(title="Lower SD Length", defval=25, minval=1, group="Standard Deviation", tooltip="Sets the lookback for the lower standard deviation band used for bearish signals.")
showSignals = input.bool(title="Show Signals", defval=true, group="Visualization", tooltip="Turn chart BULL and BEAR signal markers on or off.")
colorBars   = input.bool(title="Color Bars", defval=true, group="Visualization", tooltip="Color the price candles based on the current oscillator trend.")
longColor   = input.color(title="Bullish Color", defval=color.rgb(57, 255, 20), group="Color Settings", inline="1", tooltip="Main bullish color used for the oscillator, signals, and candle coloring.")
shortColor  = input.color(title="Bearish Color", defval=color.rgb(138, 43, 226), group="Color Settings", inline="1", tooltip="Main bearish color used for the oscillator, signals, and candle coloring.")

// CALCULATIONS
fastMA = ta.ema(maSrc, maFast)
slowMA = ta.ema(maSrc, maSlow)

spread     = fastMA - slowMA
smoothedMA = ta.ema(spread, maSmooth)

upperBand = ta.stdev(smoothedMA, upperSDLen)
lowerBand = -ta.stdev(smoothedMA, lowerSDLen)

// SIGNALS
long = smoothedMA > upperBand
short = smoothedMA < lowerBand

var int SQ = 0

if long
    SQ := 1

if short
    SQ := -1

longSignal = SQ == 1 and SQ[1] != 1
shortSignal = SQ == -1 and SQ[1] != -1

// COLORS
col = SQ == 1 ? longColor : shortColor

// PLOTS
upperPlot = plot(upperBand, title="Upper SD Band", color=color.new(longColor, 45), linewidth=1)
lowerPlot = plot(lowerBand, title="Lower SD Band", color=color.new(shortColor, 45), linewidth=1)
fill(upperPlot, lowerPlot, title="SD Band Fill", color=color.new(color.gray, 93))
plot(smoothedMA, title="Histogram", style=plot.style_columns, color=SQ == 1 ? color.new(longColor, 70) : color.new(shortColor, 70))
hline(0, "Zero Line", color=color.gray)
plotshape(showSignals and longSignal, title="Bull Signal", style=shape.triangleup, location=location.belowbar, size=size.small, color=longColor, force_overlay=true, text="BULL", textcolor=color.white)
plotshape(showSignals and shortSignal, title="Bear Signal", style=shape.triangledown, location=location.abovebar, size=size.small, color=shortColor, force_overlay=true, text="BEAR", textcolor=color.white)
barcolor(colorBars ? col : na)

// ALERTS
alertcondition(longSignal, title="Bull Signal", message="Dual MA SD Oscillator Bull Signal on {{ticker}}")
alertcondition(shortSignal, title="Bear Signal", message="Dual MA SD Oscillator Bear Signal on {{ticker}}")
````
