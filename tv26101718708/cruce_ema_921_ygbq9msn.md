# Cruce EMA 9/21

- url: https://www.tradingview.com/script/YGbq9MSN-Cruce-EMA-9-21/
- type: indicator
- pine_id: PUB;f1f85f66fe3a4e63af3ab83e802934fe
- version: 1.0

## Description

Identifica cambios de tendencia basándose en la posición que ocupan las EMA, 
Usar en 15m

## Source Code

````pine
//@version=5
indicator("Cruce EMA 9/21", overlay=true)

// Parámetros
emaFastLength = 9
emaSlowLength = 21

// Cálculo de EMAs
emaFast = ta.ema(close, emaFastLength)
emaSlow = ta.ema(close, emaSlowLength)

// Condiciones de cruce
compra = ta.crossover(emaFast, emaSlow)
venta = ta.crossunder(emaFast, emaSlow)

// Dibujar EMAs
plot(emaFast, color=color.green, title="EMA 9")
plot(emaSlow, color=color.red, title="EMA 21")

// Señales visuales
plotshape(compra, title="Compra", location=location.belowbar, color=color.green, style=shape.labelup, text="BUY")
plotshape(venta, title="Venta", location=location.abovebar, color=color.red, style=shape.labeldown, text="SELL")

// Alertas
alertcondition(compra, title="Alerta Compra", message="Cruce EMA 9 sobre EMA 21 (Compra)")
alertcondition(venta, title="Alerta Venta", message="Cruce EMA 9 bajo EMA 21 (Venta)")
````
