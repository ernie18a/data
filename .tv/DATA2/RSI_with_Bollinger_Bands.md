<!-- tradingview-pine-id: PUB;3051377e2d424f299af4d7f565574f52 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# RSI with Bollinger Bands

Source: https://www.tradingview.com/script/5Nje4Zof-RSI-with-Bollinger-Bands/

## Description

RSI with Bollinger Bands combines the Relative Strength Index with Bollinger Bands calculated directly on the RSI itself.

This indicator is designed to help identify periods when RSI momentum becomes unusually stretched relative to its recent behavior, instead of relying only on the traditional fixed 30 and 70 RSI levels.

The RSI is displayed together with a Bollinger Band basis, upper band, and lower band. When RSI moves outside the bands, the indicator can display overbought or oversold breach signals and highlight the background.

Features
RSI oscillator
Standard RSI calculation
Default RSI Length: 14
Adjustable price source
Bollinger Bands on RSI
Bollinger Bands are calculated from the RSI value
Default BB Length: 20
Default Upper Multiplier: 2.0
Default Lower Multiplier: 2.0
Upper and lower multipliers can be adjusted independently
Overbought Breach Signals
Displays an OB signal when RSI moves above the upper Bollinger Band
Red background highlighting can appear during the condition
Oversold Breach Signals
Displays an OS signal when RSI moves below the lower Bollinger Band
Green background highlighting can appear during the condition
Traditional RSI Reference Levels
70 level
50 level
30 level
These levels can be shown or hidden
Customizable Display
Show or hide breach signals
Show or hide the Bollinger Band fill
Show or hide the 30 / 50 / 70 RSI levels
Settings

Length
Controls the RSI calculation period.
Default: 14

BB Length
Controls the lookback period used to calculate the Bollinger Band basis and standard deviation on RSI.
Default: 20

BB Up
Controls the standard-deviation multiplier for the upper Bollinger Band.
Default: 2.0

BB Down
Controls the standard-deviation multiplier for the lower Bollinger Band.
Default: 2.0

Price Source
Selects the price source used for the RSI calculation.
Default: Close

Show Breach Signals
Turns the OB and OS markers on or off.

Fill Bands
Turns the shaded area between the upper and lower Bollinger Bands on or off.

Show RSI 30/50/70 Levels
Turns the traditional RSI reference levels on or off.

How to Read the Indicator

When RSI moves above the upper Bollinger Band, it means RSI is unusually strong relative to its recent range. This can indicate elevated bullish momentum or a potentially overextended condition.

When RSI moves below the lower Bollinger Band, it means RSI is unusually weak relative to its recent range. This can indicate elevated bearish momentum or a potentially oversold condition.

The traditional 30 and 70 RSI levels remain available as additional reference points.

Alerts

The indicator includes built-in alert conditions for:

RSI Above Upper Band
RSI Below Lower Band

These alerts can be used to notify you when RSI breaches either Bollinger Band.

Important

A breach of the upper or lower band should not automatically be treated as a reversal signal. Strong trends can keep RSI extended for a significant period.

This indicator is best used together with price action, trend analysis, support and resistance, volume, or other forms of confirmation.

For educational and informational purposes only. This indicator does not constitute financial advice.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at
// https://mozilla.org/MPL/2.0/
// © KMT_rader

//@version=6

indicator("RSI with Bollinger Bands", shorttitle="RSI BB", overlay=false)

// Inputs
rsiLength   = input.int(14, "Length", minval=1)
bbLength    = input.int(20, "BB Length", minval=1)
bbUp        = input.float(2.0, "BB Up", minval=0.1, step=0.1)
bbDown      = input.float(2.0, "BB Down", minval=0.1, step=0.1)
src         = input.source(close, "Price Source")

showSignals = input.bool(true, "Show Breach Signals")
showFill    = input.bool(true, "Fill Bands")
showLevels  = input.bool(true, "Show RSI 30/50/70 Levels")

// RSI
rsiValue = ta.rsi(src, rsiLength)

// Bollinger Bands on RSI
basis     = ta.sma(rsiValue, bbLength)
dev       = ta.stdev(rsiValue, bbLength)
upperBand = basis + dev * bbUp
lowerBand = basis - dev * bbDown

// Conditions
overboughtSignal = rsiValue > upperBand
oversoldSignal   = rsiValue < lowerBand

// Plots
rsiPlot   = plot(rsiValue, title="RSI", color=color.blue, linewidth=2)
basisPlot = plot(basis, title="BB Basis", color=color.orange, linewidth=1)
upperPlot = plot(upperBand, title="Upper Band", color=color.red, linewidth=1)
lowerPlot = plot(lowerBand, title="Lower Band", color=color.green, linewidth=1)

// fill must stay in global scope
fill(upperPlot, lowerPlot, color=showFill ? color.new(color.gray, 90) : na, title="Band Fill")

// Levels
plot(showLevels ? 70 : na, title="70 Level", color=color.new(color.red, 65))
plot(showLevels ? 50 : na, title="50 Level", color=color.new(color.gray, 70))
plot(showLevels ? 30 : na, title="30 Level", color=color.new(color.green, 65))

// Signals
plotshape(showSignals and overboughtSignal, title="Overbought Breach", style=shape.triangledown, location=location.top, color=color.red, size=size.tiny, text="OB")
plotshape(showSignals and oversoldSignal, title="Oversold Breach", style=shape.triangleup, location=location.bottom, color=color.lime, size=size.tiny, text="OS")

// Background
bgcolor(overboughtSignal ? color.new(color.red, 90) : na, title="Overbought Background")
bgcolor(oversoldSignal ? color.new(color.green, 90) : na, title="Oversold Background")

// Alerts
alertcondition(overboughtSignal, title="RSI Above Upper Band", message="RSI has moved above the upper Bollinger Band: possible overbought condition.")
alertcondition(oversoldSignal, title="RSI Below Lower Band", message="RSI has moved below the lower Bollinger Band: possible oversold condition.")
````
