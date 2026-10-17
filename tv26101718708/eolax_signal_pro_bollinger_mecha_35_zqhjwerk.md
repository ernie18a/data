# EOLAX Signal Pro - Bollinger Mecha 35%

- url: https://www.tradingview.com/script/ZqhjweRk/
- type: indicator
- pine_id: PUB;882e4e2a54f34d5c9aad0e8e1d42524a
- version: 1.0

## Description

este indicador combina 3 indicadores juntos, sobre compra o sobre venta agotada combinado con rsi y bandas de bollinguer. una combinacion perfecta para la entrada.

## Source Code

````pine
//@version=6
indicator("EOLAX Signal Pro - Bollinger Mecha 35%", overlay=true)

// Inputs
lengthBB = input.int(20, "Bollinger Length")
multBB   = input.float(2.0, "Bollinger Multiplier")
emaLen   = input.int(200, "EMA Tendencia")
rsiLen   = input.int(14, "RSI Length")

sensibilidad = input.float(0.35, "Porcentaje mecha fuera", step=0.05)
rsiVenta     = input.int(60, "RSI mínimo venta")
rsiCompra    = input.int(40, "RSI máximo compra")

// Cálculos
basis = ta.sma(close, lengthBB)
dev   = multBB * ta.stdev(close, lengthBB)
upper = basis + dev
lower = basis - dev

ema200 = ta.ema(close, emaLen)
rsi = ta.rsi(close, rsiLen)

// Porcentaje de mecha/rango fuera de Bollinger
rangeSize = high - low

outsideUp = rangeSize > 0 ? math.max(high - upper, 0) / rangeSize : 0
outsideDn = rangeSize > 0 ? math.max(lower - low, 0) / rangeSize : 0

// Señales más sensibles
sellSignal = outsideUp >= sensibilidad and rsi > rsiVenta
buySignal  = outsideDn >= sensibilidad and rsi < rsiCompra

// Plots
plot(basis, "BB Media", color=color.gray)
plot(upper, "BB Superior", color=color.new(color.red, 0))
plot(lower, "BB Inferior", color=color.new(color.green, 0))
plot(ema200, "EMA 200", color=color.orange)

plotshape(
     buySignal,
     title="Compra",
     style=shape.labelup,
     location=location.belowbar,
     text="BUY",
     color=color.green,
     textcolor=color.white,
     size=size.small
)

plotshape(
     sellSignal,
     title="Venta",
     style=shape.labeldown,
     location=location.abovebar,
     text="SELL",
     color=color.red,
     textcolor=color.white,
     size=size.small
)

// Alertas
alertcondition(
     buySignal,
     title="Alerta Compra",
     message="Señal BUY: mecha/rango fuera de Bollinger inferior"
)

alertcondition(
     sellSignal,
     title="Alerta Venta",
     message="Señal SELL: mecha/rango fuera de Bollinger superior"
)
````
