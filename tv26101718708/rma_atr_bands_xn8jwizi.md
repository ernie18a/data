# RMA ATR Bands

- url: https://www.tradingview.com/script/xN8JwiZI-RMA-ATR-Bands/
- type: indicator
- pine_id: PUB;dbce97468e5740cb97af387e00acb73b
- version: 2.0

## Description

[b]RMA ATR Bands[/b] is a directional volatility trend indicator built around a smoothed RMA baseline combined with asymmetric ATR expansion bands.

Unlike traditional symmetric ATR envelopes, the indicator uses independent upper and lower ATR multipliers to create adaptive directional filtering and trend regime detection. This allows the system to respond differently to bullish and bearish volatility conditions while maintaining a smoother baseline structure through RMA smoothing.

[b]Bullish regime: [/b]
• Price closes above the upper ATR expansion band

[b]Bearish regime:[/b]
• Price closes below the lower ATR expansion band

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SchizoQuant

//@version=6
indicator("RMA ATR Bands", overlay=true)

// USER INPUTS
maSrc        = input.source(title="Source", defval=high, group="RMA Settings", tooltip="Choose the price source used to calculate the RMA trendline.")
maLength     = input.int(title="Length", defval=14, minval=1, group="RMA Settings", tooltip="Controls the speed of the RMA trendline. Lower values react faster, while higher values are smoother.")
atrLength    = input.int(title="ATR Length", defval=13, minval=1, group="ATR Bands", tooltip="Sets how many bars are used to measure average volatility for the ATR bands.")
upperMult    = input.float(title="Upper ATR Multiplier", defval=0.4, step=0.1, group="ATR Bands", tooltip="Controls how far the upper band is placed above the RMA. Higher values require stronger bullish movement.")
lowerMult    = input.float(title="Lower ATR Multiplier", defval=1.6, step=0.1, group="ATR Bands", tooltip="Controls how far the lower band is placed below the RMA. Higher values require stronger bearish movement.")
showATRBands = input.bool(title="Show ATR Bands", defval=true, group="Visualization", tooltip="Turn the upper and lower ATR bands on or off.")
colorBars    = input.bool(title="Color Bars", defval=true, group="Visualization", tooltip="Color the candles based on the current trend direction.")
showSignals  = input.bool(title="Show Signals", defval=true, group="Visualization", tooltip="Show LONG and SHORT signal markers on the chart.")

// MA CALCULATION
ma = ta.rma(maSrc, maLength)

// ATR BAND CALCULATION
atr = ta.atr(atrLength)

upperLine = ma + atr * upperMult
lowerLine = ma - atr * lowerMult

// LONG AND SHORT SIGNALS
long  = close > upperLine
short = close < lowerLine

var int trend = 0

if long
    trend := 1

if short
    trend := -1

longSignal = trend == 1 and trend[1] != 1
shortSignal = trend == -1 and trend[1] != -1

// COLORS
longColor  = color.rgb(57, 255, 20)
shortColor = color.rgb(138, 43, 226)

bandColor = trend == 1 ? longColor : trend == -1 ? shortColor : color.gray

// PLOTS
maPlot = plot(ma, title="MA", color=bandColor, linewidth=2)
upperPlot = plot(showATRBands ? upperLine : na, title="Upper ATR Band", color=bandColor, linewidth=1)
lowerPlot = plot(showATRBands ? lowerLine : na, title="Lower ATR Band", color=bandColor, linewidth=1)
fill(maPlot, upperPlot, color=showATRBands ? color.new(bandColor, 88) : na, title="Upper Fill")
fill(maPlot, lowerPlot, color=showATRBands ? color.new(bandColor, 88) : na, title="Lower Fill")
plotshape(showSignals and longSignal, title="Long Signal", style=shape.triangleup, location=location.belowbar, color=longColor, size=size.small, text="LONG", textcolor=color.white)
plotshape(showSignals and shortSignal, title="Short Signal", style=shape.triangledown, location=location.abovebar, color=shortColor, size=size.small, text="SHORT", textcolor=color.white)
barcolor(colorBars ? bandColor : na)

// ALERTS
alertcondition(longSignal, title="RMA ATR Bands Long", message="RMA ATR Bands Long Signal on {{ticker}}")
alertcondition(shortSignal, title="RMA ATR Bands Short", message="RMA ATR Bands Short Signal on {{ticker}}")
````
