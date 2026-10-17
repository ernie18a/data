# 3 EMA CROSSES - Real Time / Close

- url: https://www.tradingview.com/script/MlKFkIUs/
- type: indicator
- pine_id: PUB;bb651910cdd74b08a38e2f5bbfe897d3
- version: 1.0

## Description

cruce de ema en tiempo rea, se confirma al cierre de vela

## Source Code

````pine
//@version=6
indicator("3 EMA CROSSES - Real Time / Close", overlay=true)

ema1Len = input.int(50, "EMA 1")
ema2Len = input.int(100, "EMA 2")
ema3Len = input.int(200, "EMA 3")

modo = input.string("En tiempo real", "Modo de señal", options=["En tiempo real", "Al cierre"])

ema1 = ta.ema(close, ema1Len)
ema2 = ta.ema(close, ema2Len)
ema3 = ta.ema(close, ema3Len)

plot(ema1, color=color.yellow, linewidth=1)
plot(ema2, color=color.orange, linewidth=1)
plot(ema3, color=color.red, linewidth=1)

confirmada = modo == "Al cierre" ? barstate.isconfirmed : true

cruceAlcista12 = ta.crossover(ema1, ema2) and confirmada
cruceAlcista13 = ta.crossover(ema1, ema3) and confirmada
cruceAlcista23 = ta.crossover(ema2, ema3) and confirmada

cruceBajista12 = ta.crossunder(ema1, ema2) and confirmada
cruceBajista13 = ta.crossunder(ema1, ema3) and confirmada
cruceBajista23 = ta.crossunder(ema2, ema3) and confirmada

plot(cruceAlcista12 ? ema1 : na, style=plot.style_cross, linewidth=4, color=color.lime)
plot(cruceAlcista13 ? ema1 : na, style=plot.style_cross, linewidth=6, color=color.lime)
plot(cruceAlcista23 ? ema2 : na, style=plot.style_cross, linewidth=8, color=color.lime)

plot(cruceBajista12 ? ema1 : na, style=plot.style_cross, linewidth=4, color=color.red)
plot(cruceBajista13 ? ema1 : na, style=plot.style_cross, linewidth=6, color=color.red)
plot(cruceBajista23 ? ema2 : na, style=plot.style_cross, linewidth=8, color=color.red)
````
