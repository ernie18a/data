# OBV Trend Candles

- url: https://www.tradingview.com/script/apyrqqJf-OBV-Trend-Candles/
- type: indicator
- pine_id: PUB;46b5d362a43b4d94b6c59a3637175661
- version: 4.0

## Description

[b]OBV Trend Candles[/b]

This indicator colors your candles based on the relationship between On-Balance Volume (OBV) and a moving average of OBV. It's a simple way to keep volume-based trend context visible directly on the price chart, without having to watch a separate OBV pane.

[b]How it works[/b]

OBV accumulates volume on up-closes and subtracts it on down-closes, so a rising OBV means volume is flowing into the asset and a falling OBV means it's flowing out. This script takes that OBV line and compares it to a simple moving average of itself:

When OBV is above its SMA, volume momentum is building → candles are painted green.
When OBV is below its SMA, volume momentum is fading → candles are painted red.

The idea is that volume often shifts before or alongside price, so the color flips can give you a read on whether the current move is backed by participation.

[b]The Sensitivity input[/b]

The single setting that matters is Sensitivity, which is the length of the SMA applied to OBV. Lower values make the indicator react faster to changes in volume flow (more color flips, more noise), while higher values smooth things out and only flip on more established shifts. Tune it to your timeframe and trading style — there's no universally "correct" value.

[b]Notes[/b]

It works on any timeframe and any asset, as long as that asset reports volume data. On symbols without volume (some forex pairs and certain indices), OBV can't be calculated and the script will let you know. Colors are fully customizable in the settings.

This is a context/confirmation tool, not a standalone signal — it tells you about volume flow, not where to enter or exit. Use it alongside your own analysis.

## Source Code

````pine
//@version=6
indicator("OBV Trend Detection", overlay = true, behind_chart = false)

var color BUY  = #089981
var color SELL = #ee0d56

// === Inputs ===
sensitivity = input.int(40, "Sensitivity", minval = 1, group = "OBV",
     tooltip = "Length of the SMA applied to OBV. Lower = more reactive, higher = smoother.")

satMode = input.string("Smooth", "Transition", options = ["Sharp", "Smooth", "Very smooth"], group = "Gradient",
     tooltip = "How quickly candles reach full color as OBV pulls away from its SMA. Sharp = snappy, almost binary. Very smooth = gentle, gradual fades.")

saturation = satMode == "Sharp" ? 0.01 : satMode == "Smooth" ? 1.0 : 2.5
normLen    = 100
bullCol    = BUY
bearCol    = SELL
neutralCol = color.rgb(110, 110, 110)

// === Calculation ===
obv    = ta.obv
obvSma = ta.sma(obv, sensitivity)
spread = obv - obvSma
sd     = ta.stdev(spread, normLen)

// normalized strength: how many std devs OBV sits above/below its SMA
strength = na(sd) or sd == 0 ? 0.0 : spread / sd

// === Volume guard ===
if barstate.islast and na(volume)
    runtime.error("This symbol has no volume data, so OBV can't be calculated.")

// === Color ===
col = strength >= 0
     ? color.from_gradient(strength,  0.0, saturation, neutralCol, bullCol)
     : color.from_gradient(strength, -saturation, 0.0, bearCol, neutralCol)

//barcolor(col)
plotcandle(open, high, low, close, color=col, wickcolor=col, bordercolor=col)
````
