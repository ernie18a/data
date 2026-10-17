# EMA 3/9 Cruce + Cloud

- url: https://www.tradingview.com/script/Y7PlcdQc/
- type: indicator
- pine_id: PUB;cee08a8b037346fb87ac06b594c1bd47
- version: 1.0

## Description

EMA 3/9 Crossover Cloud

Indicador simple y visual que muestra el cruce entre la EMA 3 y EMA 9 con un cloud de fondo entre ambas medias.

Características:
• Fondo (cloud) verde cuando la EMA 3 está por encima de la EMA 9 (alcista)
• Fondo negro cuando la EMA 3 está por debajo de la EMA 9 (bajista)
• Señales claras de BUY y SELL en cada cruce
• Velas coloreadas solo en el momento exacto del cruce

Ideal para scalping e intradía en Oro (XAUUSD), Forex y otros activos volátiles. Muy limpio y fácil de leer.

Configuración por defecto:
- EMA Rápida: 3
- EMA Lenta: 9
- Cloud con transparencia suave

## Source Code

````pine
//@version=5
indicator("EMA 3/9 Cruce + Cloud", shorttitle="EMA 3-9 Cloud", overlay=true)

// === EMAs ===
ema3 = ta.ema(close, 3)
ema9 = ta.ema(close, 9)

// === Cruce ===
cruce_alcista = ta.crossover(ema3, ema9)
cruce_bajista = ta.crossunder(ema3, ema9)

// === Colores ===
color_ema3 = ema3 > ema9 ? #5dba8a : #000000
color_ema9 = ema3 > ema9 ? #000000 : #5dba8a

plot(ema3, color=color_ema3, linewidth=2, title="EMA 3")
plot(ema9, color=color_ema9, linewidth=2, title="EMA 9")

// === Fondo entre las dos EMAs (Cloud) ===
fillcolor = ema3 > ema9 ? color.new(#5dba8a, 85) : color.new(#000000, 85)
fill(plot(ema3), plot(ema9), color=fillcolor, title="Cloud entre EMAs")

// === Señales BUY / SELL (más pequeñas y limpias) ===
plotshape(cruce_alcista, title="BUY", location=location.belowbar, 
          color=#5dba8a, style=shape.labelup, text="BUY", textcolor=color.white, size=size.tiny)

plotshape(cruce_bajista, title="SELL", location=location.abovebar, 
          color=#000000, style=shape.labeldown, text="SELL", textcolor=color.white, size=size.tiny)

// === Colorear velas solo en el cruce ===
barcolor(cruce_alcista ? #5dba8a : na)
barcolor(cruce_bajista ? #000000 : na)
````
