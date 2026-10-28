# 480 EMA

- url: https://www.tradingview.com/script/iQ92sT9v-480-EMA/
- type: indicator
- pine_id: PUB;a92c6359cda94ac18adaab3d2644be16
- version: 1.0

## Description

Green/Red band = current timeframe 480 EMA
Blue/Orange band = fixed 1H 480 EMA
Both bands stay visible together.

## Source Code

````pine
//@version=6
indicator("480 EMA", overlay=true)

// =====================
// INPUT
// =====================
length = input.int(480, "EMA Length")

// =====================
// FLEXIBLE 480 EMA BAND
// (Current chart timeframe)
// =====================

flexHigh = ta.ema(high, length)
flexLow  = ta.ema(low, length)

flexHighPlot = plot(flexHigh, "Flexible 480 EMA High", color=color.lime, linewidth=2)
flexLowPlot  = plot(flexLow, "Flexible 480 EMA Low", color=color.red, linewidth=2)

fill(flexHighPlot, flexLowPlot, color=color.new(color.green, 90))


// =====================
// FIXED HOURLY 480 EMA BAND
// (Always 1H)
// =====================

hourHigh = request.security(syminfo.tickerid, "60", ta.ema(high, length))
hourLow  = request.security(syminfo.tickerid, "60", ta.ema(low, length))

hourHighPlot = plot(hourHigh, "Hourly 480 EMA High", color=color.blue, linewidth=2)
hourLowPlot  = plot(hourLow, "Hourly 480 EMA Low", color=color.orange, linewidth=2)

fill(hourHighPlot, hourLowPlot, color=color.new(color.blue, 85))
````
