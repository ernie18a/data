# ATR Stack of 3 v1

- url: https://www.tradingview.com/script/XkUwjJfQ-ATR-Stack-of-3-v1/
- type: indicator
- pine_id: PUB;eea0717cce0844d58b34204cfb6dcc8f
- version: 1.0

## Description

OM ATR Stack — Volatility & Stop Guide

Purpose:
Measure current volatility and estimate reasonable stop distance. ATR Stack does not predict direction. Use it with your trend and entry systems.

Columns:

ATR%
Average movement per candle as a percentage of price.

Guide:

* <1% = Calm / compressed
* 1–3% = Healthy trading conditions
* 3–5% = Elevated volatility
* 5%+ = Extreme movement

HEAT
Compares current ATR to recent ATR average.

Guide:

* LOW = Quiet market, setups forming
* NORMAL = Healthy environment
* HIGH = Larger moves, reduce size
* EXTREME = Expansion, caution

SL
Suggested stop distance using ATR multiplier.

Guide:

* 1.0 ATR = Tight
* 1.5 ATR = Balanced (default)
* 2.0 ATR = Conservative
* 2.5+ ATR = High volatility assets

How to use:

* Higher ATR → Further stop
* Lower ATR → Tighter stop
* Keep risk constant by adjusting position size

Suggested workflow:
Trend Stack → Direction
MR Engine → Entry
ATR Stack → Risk

ATR measures how hard price is breathing, not where price is going.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CryptOmar210


plot(close)
//@version=5
indicator("OM ATR Stack v1", overlay=true)

grpATR = "ATR Settings"
atrLen = input.int(14, "ATR Length", minval=1, group=grpATR)
atrAvgLen = input.int(50, "ATR Average Length", minval=5, group=grpATR)
slMult = input.float(1.5, "SL ATR Multiplier", minval=0.1, step=0.1, group=grpATR)

grpDisplay = "Display"
labelPos = input.string("Bottom Right", "Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpDisplay)

atr = ta.atr(atrLen)
atrPct = atr / close * 100
atrAvg = ta.sma(atr, atrAvgLen)
atrRatio = atrAvg > 0 ? atr / atrAvg : na

heatLabel = atrRatio < 0.8 ? "LOW" :
     atrRatio <= 1.2 ? "NORMAL" :
     atrRatio <= 1.8 ? "HIGH" :
     "EXTREME"

heatColor = atrRatio < 0.8 ? color.new(color.lime, 0) :
     atrRatio <= 1.2 ? color.new(color.yellow, 0) :
     atrRatio <= 1.8 ? color.new(color.orange, 0) :
     color.new(color.red, 0)

slDistance = atr * slMult
slPct = slDistance / close * 100

atrPctLabel = str.tostring(math.round(atrPct, 2)) + "%"
slLabel = str.tostring(slMult) + "x / " + str.tostring(math.round(slPct, 2)) + "%"

lPos = labelPos == "Top Right" ? position.top_right :
     labelPos == "Top Left" ? position.top_left :
     labelPos == "Bottom Right" ? position.bottom_right :
     position.bottom_left

var table t = table.new(lPos, 3, 2, bgcolor=color.new(color.black, 10), border_color=color.new(color.gray, 40), border_width=1)

if barstate.islast
    table.cell(t, 0, 0, "ATR%", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 0, "HEAT", text_color=color.gray, text_size=size.small)
    table.cell(t, 2, 0, "SL", text_color=color.gray, text_size=size.small)

    table.cell(t, 0, 1, atrPctLabel, text_color=color.white, text_size=size.small)
    table.cell(t, 1, 1, heatLabel, text_color=heatColor, text_size=size.small)
    table.cell(t, 2, 1, slLabel, text_color=color.white, text_size=size.small)
````
