# 5m Indicator

- url: https://www.tradingview.com/script/CkeKwRI5-5m-Indicator/
- type: indicator
- pine_id: PUB;4f6ca6f9495c4ef2b28da708177604fc
- version: 1.0

## Description

This indicator shows a sign if the 5 min candle closes outside BB

## Source Code

````pine
//@version=5
indicator("5m Indicator", overlay=true)

// =========================
// 🔵 BOLLINGER BANDS (5m)
// =========================
length = input.int(20, "BB Length")
mult   = input.float(2.0, "BB Mult")

basis = ta.sma(close, length)
dev   = mult * ta.stdev(close, length)

upper = basis + dev
lower = basis - dev

plot(basis, color=color.gray)
plot(upper, color=color.blue)
plot(lower, color=color.blue)

// =========================
// 🔵 CONDICIONES 5m
// =========================
bullBreak = close > upper
bearBreak = close < lower

// =========================
// 🔵 MARCADORES
// =========================
plotshape(bullBreak, title="5m Bull Close Outside", location=location.abovebar, style=shape.triangleup, color=color.green, size=size.small)
plotshape(bearBreak, title="5m Bear Close Outside", location=location.belowbar, style=shape.triangledown, color=color.red, size=size.small)

// =========================
// 🔵 OPCIONAL: COLOR DE VELA
// =========================
barcolor(bullBreak ? color.green : bearBreak ? color.red : na)
````
