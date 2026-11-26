# EMA 10/20 + VWAP Trend Zones

- url: https://www.tradingview.com/script/L27rE1FG/
- type: indicator
- pine_id: PUB;21c3e2b85c654666a6643f682bc82591
- version: 1.0

## Description

The EMA method, is a public indicator of a ema cross strategy

## Source Code

````pine
//@version=5
indicator("EMA 10/20 + VWAP Trend Zones", overlay=true)

// Inputs
emaFastLen = input.int(10, "EMA rápida")
emaSlowLen = input.int(20, "EMA lenta")

bullColor = input.color(color.lime, "Color Bullish")
bearColor = input.color(color.red, "Color Bearish")

fillBullColor = input.color(color.new(color.lime, 80), "Zona Bullish")
fillBearColor = input.color(color.new(color.red, 80), "Zona Bearish")

vwapColor = input.color(color.orange, "Color VWAP")

// Cálculos
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
vwapValue = ta.vwap(close)

// Condiciones
bullish = emaFast > emaSlow
bearish = emaFast < emaSlow

trendColor = bullish ? bullColor : bearish ? bearColor : color.gray
zoneColor = bullish ? fillBullColor : bearish ? fillBearColor : color.new(color.gray, 85)

// Plots
plotEmaFast = plot(emaFast, "EMA 10", color=trendColor, linewidth=2)
plotEmaSlow = plot(emaSlow, "EMA 20", color=trendColor, linewidth=2)

plot(vwapValue, "VWAP", color=vwapColor, linewidth=2)

// Relleno entre EMAs
fill(plotEmaFast, plotEmaSlow, color=zoneColor)
````
