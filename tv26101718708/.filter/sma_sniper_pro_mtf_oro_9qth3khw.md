# SMA SNIPER PRO MTF - Oro

- url: https://www.tradingview.com/script/9qTh3KHW/
- type: indicator
- pine_id: PUB;b1b38da34fad45f09a277cb887d4a207
- version: 1.0

## Description

Entrada de SMA 100 y 200 en TF 15M

Recorridos largos TPs mas de 300 pips
Funciona mejor en 15M con SMA 200

## Source Code

````pine
//@version=5
indicator("SMA SNIPER PRO MTF - Oro", overlay=true)

// INPUTS
tf = input.timeframe("5", "Temporalidad (5, 15, 30)")
length = input.int(200, "Periodo SMA", options=[100, 200])

// DATOS MTF
mtf_close = request.security(syminfo.tickerid, tf, close)
mtf_open  = request.security(syminfo.tickerid, tf, open)
mtf_high  = request.security(syminfo.tickerid, tf, high)
mtf_low   = request.security(syminfo.tickerid, tf, low)

// SMA MTF
sma = request.security(syminfo.tickerid, tf, ta.sma(close, length))

// Dibujar SMA
plot(sma, color=color.yellow, linewidth=2, title="SMA MTF")

// Tendencia
trend_up = mtf_close > sma
trend_down = mtf_close < sma

// Toque
touch = mtf_low <= sma and mtf_high >= sma

// Rechazo (mechas)
body = math.abs(mtf_close - mtf_open)
upper_wick = mtf_high - math.max(mtf_close, mtf_open)
lower_wick = math.min(mtf_close, mtf_open) - mtf_low

rejection_buy = lower_wick > body * 1.5
rejection_sell = upper_wick > body * 1.5

// Señales SNIPER
buySignal = touch and trend_up and rejection_buy
sellSignal = touch and trend_down and rejection_sell

// Visual
plotshape(buySignal,
     title="BUY SNIPER",
     location=location.belowbar,
     color=color.green,
     style=shape.labelup,
     text="BUY")

plotshape(sellSignal,
     title="SELL SNIPER",
     location=location.abovebar,
     color=color.red,
     style=shape.labeldown,
     text="SELL")

// Alertas
alertcondition(buySignal,
     title="BUY SNIPER",
     message="Compra SNIPER SMA en TF seleccionado")

alertcondition(sellSignal,
     title="SELL SNIPER",
     message="Venta SNIPER SMA en TF seleccionado")
````
