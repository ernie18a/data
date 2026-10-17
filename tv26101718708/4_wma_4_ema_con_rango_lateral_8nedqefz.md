# 4 WMA + 4 EMA con Rango Lateral

- url: https://www.tradingview.com/script/8NEDqEFZ/
- type: indicator
- pine_id: PUB;40fbed12696c46089cf61ad57e0b457e
- version: 1.0

## Description

En este script tenemos agregando el rango de enmedio que no debemos operar, mas el conjutno de medias emas y ponderadas

## Source Code

````pine
//@version=6
indicator(title="4 WMA + 4 EMA con Rango Lateral", shorttitle="4 WMA + 4 EMA + Rango", overlay=true, timeframe="", timeframe_gaps=true)

// Fuente
src = input.source(close, title="Source")

// Offset
offset = input.int(title="Offset", defval=0, minval=-500, maxval=500, display=display.none)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// WMA INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
wmaLen1 = input.int(9, minval=1, title="WMA 1 Length")
wmaLen2 = input.int(20, minval=1, title="WMA 2 Length")
wmaLen3 = input.int(40, minval=1, title="WMA 3 Length")
wmaLen4 = input.int(200, minval=1, title="WMA 4 Length")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMA INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
emaLen1 = input.int(9, minval=1, title="EMA 1 Length")
emaLen2 = input.int(20, minval=1, title="EMA 2 Length")
emaLen3 = input.int(40, minval=1, title="EMA 3 Length")
emaLen4 = input.int(200, minval=1, title="EMA 4 Length")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DETECCIÓN DEL PERIODO MEDIO (130 MINUTOS DE ENMEDIO)
// Sesión regular NY: 09:30 a 16:00 EST
// Periodo 1: 09:30 - 11:40 (130 min)
// Periodo 2 (Almuerzo/Lateral): 11:40 - 13:50 (130 min) -> ESTE SE PINTA
// Periodo 3: 13:50 - 16:00 (130 min)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Usamos "America/New_York" para que sea exacto independientemente de tu zona horaria local
en_periodo_medio = not na(time(timeframe.period, "1140-1350:23456", "America/New_York"))

// Color de fondo con opacidad (85% de transparencia para que no tape las velas ni los indicadores)
bgcolor(en_periodo_medio ? color.new(color.red, 85) : na, title="Fondo Periodo Lateral NY")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// WMA CALCULATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
wma1 = ta.wma(src, wmaLen1)
wma2 = ta.wma(src, wmaLen2)
wma3 = ta.wma(src, wmaLen3)
wma4 = ta.wma(src, wmaLen4)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMA CALCULATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ema1 = ta.ema(src, emaLen1)
ema2 = ta.ema(src, emaLen2)
ema3 = ta.ema(src, emaLen3)
ema4 = ta.ema(src, emaLen4)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// WMA PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(wma1, title="WMA 1", color=color.blue, offset=offset, linewidth=2)
plot(wma2, title="WMA 2", color=color.orange, offset=offset, linewidth=2)
plot(wma3, title="WMA 3", color=color.green, offset=offset, linewidth=2)
plot(wma4, title="WMA 4", color=color.purple, offset=offset, linewidth=2)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMA PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(ema1, title="EMA 1", color=color.aqua, offset=offset, linewidth=2)
plot(ema2, title="EMA 2", color=color.red, offset=offset, linewidth=2)
plot(ema3, title="EMA 3", color=color.lime, offset=offset, linewidth=2)
plot(ema4, title="EMA 4", color=color.fuchsia, offset=offset, linewidth=2)
````
