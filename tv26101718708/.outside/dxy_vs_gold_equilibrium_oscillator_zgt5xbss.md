# DXY vs GOLD Equilibrium Oscillator

- url: https://www.tradingview.com/script/zgT5XBsS-DXY-vs-GOLD-Equilibrium-Oscillator/
- type: indicator
- pine_id: PUB;494b2f80531346c3be2515eea2caf6a8
- version: 1.0

## Description

This script builds a relative-value oscillator between:

DXY = US Dollar Index
Gold = XAUUSD

Since Gold and DXY often move inversely, the script tries to measure whether:

Gold is acting too strong relative to DXY
Gold is acting too weak relative to DXY
Or both are in a more balanced “equilibrium”

It does not predict price by itself.
It is a context / bias tool.

Think of it like this:

If Gold is much stronger than where DXY suggests it “should” be, the oscillator rises
If Gold is much weaker than where DXY suggests it “should” be, the oscillator falls

So the script is essentially asking:

“Compared to the dollar, is gold stretched high, stretched low, or near fair value?”

The script converts both DXY and Gold into a normalized score from 0 to 100 based on their own recent 100-bar range.

Example:

If over the last 100 candles:

Gold’s lowest price = 3000
Gold’s highest price = 3100
Current price = 3075

Then Gold is near the upper part of its recent range, so its normalized value might be around 75.

The same happens for DXY.

Why do this?

Because DXY and Gold trade at completely different price scales.

DXY might be around 100
Gold might be around 3200

You can’t compare raw prices directly.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Dani_DaCosta

//@version=6
//@version=6
//@version=6
indicator("DXY vs GOLD Equilibrium Oscillator", shorttitle="DXY-XAU Eq", overlay=false)

// === Inputs ===
dxySymbol   = input.symbol("TVC:DXY", "DXY Symbol")
goldSymbol  = input.symbol("OANDA:XAUUSD", "Gold Symbol")
lookback    = input.int(100, "Normalization Lookback", minval=10)
smoothLen   = input.int(5, "Smoothing", minval=1)
thresh30    = input.float(30.0, "Threshold 30")
thresh70    = input.float(70.0, "Threshold 70")

// === Data ===
dxyClose  = request.security(dxySymbol, timeframe.period, close)
goldClose = request.security(goldSymbol, timeframe.period, close)

// === Normalize both markets ===
dxyLow    = ta.lowest(dxyClose, lookback)
dxyHigh   = ta.highest(dxyClose, lookback)
goldLow   = ta.lowest(goldClose, lookback)
goldHigh  = ta.highest(goldClose, lookback)

dxyNorm   = dxyHigh != dxyLow ? ((dxyClose - dxyLow) / (dxyHigh - dxyLow)) * 100 : 50
goldNorm  = goldHigh != goldLow ? ((goldClose - goldLow) / (goldHigh - goldLow)) * 100 : 50

// === Core relationship ===
rawSpread = goldNorm - dxyNorm

// Smooth
osc = ta.ema(rawSpread, smoothLen)

// === Dynamic Color ===
oscColor =
     osc >= 100 ? color.red :
     osc <= -100 ? color.red :
     osc > 0 ? color.orange :
     osc < 0 ? color.teal :
     color.gray

// === Plot oscillator ===
plot(osc, title="Equilibrium Line", linewidth=4, color=oscColor)

// === Center Line ===
hline(0, "Equilibrium", color=color.white, linestyle=hline.style_solid, linewidth=2)

// === Thresholds ===
hline(thresh30, "+30", color=color.yellow, linestyle=hline.style_dashed, linewidth=2)
hline(thresh70, "+70", color=color.orange, linestyle=hline.style_dashed, linewidth=3)

hline(-thresh30, "-30", color=color.yellow, linestyle=hline.style_dashed, linewidth=2)
hline(-thresh70, "-70", color=color.orange, linestyle=hline.style_dashed, linewidth=3)

// === Extreme Levels ===
hline(100, "+100 EXTREME", color=color.red, linestyle=hline.style_solid, linewidth=4)
hline(-100, "-100 EXTREME", color=color.red, linestyle=hline.style_solid, linewidth=4)

// === Background zones ===
bgcolor(osc >= 100 ? color.new(color.red,85) :
       osc <= -100 ? color.new(color.red,85) :
       osc > thresh70 ? color.new(color.orange,90) :
       osc < -thresh70 ? color.new(color.teal,90) : na)

// === Signals ===
goldOvervalued = osc > thresh30
goldUndervalued = osc < -thresh30

plotshape(goldOvervalued, title="Gold Overvalued",
     style=shape.triangledown, location=location.top,
     color=color.red, size=size.tiny)

plotshape(goldUndervalued, title="Gold Undervalued",
     style=shape.triangleup, location=location.bottom,
     color=color.green, size=size.tiny)
````
