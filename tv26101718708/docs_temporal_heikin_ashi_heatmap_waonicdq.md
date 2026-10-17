# Doc's Temporal Heikin Ashi Heatmap

- url: https://www.tradingview.com/script/wAonICDQ-Doc-s-Temporal-Heikin-Ashi-Heatmap/
- type: indicator
- pine_id: PUB;8a51c997c50a47a68fdf66dfe12b802d
- version: 1.0

## Description

This simple script is used to identify the current trend.  It is based on Heikin Akin Ashi candles on 4 custom timeframes and uses them to generate a heatmap on the current chart.  Quickly, the Heikin Ashi Open is computed on the selected timeframes and compared to the current Heikin Ashi Close.  The direction of each timeframe is used to create the background heatmap.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © grnghost

//@version=6
indicator("Doc's Temporal Heikin Ashi Heatmap","HA Heatmap", overlay = true, precision = 2)

HAopen = math.avg(open[1], close[1])
higher_tf = input.timeframe("15", "High Timeframe")
higher_tf1 = input.timeframe("30", "High Timeframe")
higher_tf2 = input.timeframe("60", "High Timeframe")
higher_tf3 = input.timeframe("240", "High Timeframe")

HTF_HAopen = request.security(syminfo.tickerid, higher_tf, HAopen)
HTF_HAopen1 = request.security(syminfo.tickerid, higher_tf1, HAopen)
HTF_HAopen2 = request.security(syminfo.tickerid, higher_tf2, HAopen)
HTF_HAopen3 = request.security(syminfo.tickerid, higher_tf3, HAopen)

HA3 = ohlc4 > HTF_HAopen3 ? 1 : 0
HA2 = ohlc4 > HTF_HAopen2 ? 1 : 0
HA1 = ohlc4 > HTF_HAopen1 ? 1 : 0
HA = ohlc4 > HTF_HAopen ? 1 : 0
HAc = ohlc4 > HAopen ? 1 : 0

pct = 100*ta.sma(math.avg(HA3, HA2, HA1, HA, HAc), 3)
// Colour the background
buyColour  = color.new(color.green, 97)
sellColour = color.new(color.red, 97)

plot(pct, color = pct > 50 ? color.green : color.red, display = display.status_line)
bgcolor(ohlc4 > HTF_HAopen3 ? buyColour : sellColour)
bgcolor(ohlc4 > HTF_HAopen2 ? buyColour : sellColour)
bgcolor(ohlc4 > HTF_HAopen1 ? buyColour : sellColour)
bgcolor(ohlc4 > HTF_HAopen ? buyColour : sellColour)
bgcolor(ohlc4 > HAopen ? buyColour : sellColour)
````
