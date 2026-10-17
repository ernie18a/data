# EMAs JDAM

- url: https://www.tradingview.com/script/xeDVc2nF/
- type: indicator
- pine_id: PUB;b365203751e8448885fb3b73334b2c64
- version: 1.0

## Description

Este indicador muestra un conjunto de medias móviles exponenciales (EMA) diseñadas para representar la tendencia de distintos marcos temporales dentro de un mismo gráfico.

Medias incluidas:

EMA 200 M15: referencia de tendencia de largo plazo equivalente a 200 períodos en 15 minutos.
EMA 14 H4: tendencia principal de 14 períodos en gráfico de 4 horas.
EMA 200 M5: tendencia de largo plazo en 5 minutos.
EMA 14 H1: tendencia de 14 períodos en gráfico de 1 hora.
EMA 200 M1: tendencia de largo plazo en 1 minuto.
EMA 14 M15: tendencia de 14 períodos en gráfico de 15 minutos.
EMA 50 M1: media de referencia intermedia para seguimiento de impulso.
EMA 14 M1 Suav: media suavizada para identificar cambios de dirección y filtrar ruido del mercado.

## Source Code

````pine
//@version=5
indicator("Guppy", shorttitle="EMA", overlay=true)

// EMA 200m15
EMA200m15len = input.int(3000, minval=1, title="EMA200m15 Length")
EMA200m15 = ta.ema(close, EMA200m15len)
plot(EMA200m15, title="EMA200m15", color=#3399FF, linewidth=1)

// EMA 14H4
EMA14H4len = input.int(3360, minval=1, title="EMA14H4 Length")
EMA14H4 = ta.ema(close, EMA14H4len)
plot(EMA14H4, title="EMA14H4", color=#008AE6, linewidth=1)

// EMA 200m5
EMA200m5len = input.int(1000, minval=1, title="EMA200m5 Length")
EMA200m5 = ta.ema(close, EMA200m5len)
plot(EMA200m5, title="EMA200m5", color=#008AE6, linewidth=1)

// EMA 14H1
EMA14H1len = input.int(840, minval=1, title="EMA14H1 Length")
EMA14H1 = ta.ema(close, EMA14H1len)
plot(EMA14H1, title="EMA14H1", color=#008AE6, linewidth=1)

// EMA 200m1
EMA200m1len = input.int(200, minval=1, title="EMA200m1 Length")
EMA200m1 = ta.ema(close, EMA200m1len)
plot(EMA200m1, title="EMA200m1", color=#008AE6, linewidth=1)

// EMA 14m15
EMA14m15len = input.int(210, minval=1, title="EMA14m15 Length")
EMA14m15 = ta.ema(close, EMA14m15len)
plot(EMA14m15, title="EMA14m15", color=#008AE6, linewidth=1)

// EMA 50m1
EMA50m1len = input.int(50, minval=1, title="EMA50m1 Length")
EMA50m1 = ta.ema(close, EMA50m1len)
plot(EMA50m1, title="EMA50m1", color=color.red, linewidth=1)


// EMA 14m1 suav
smmaLen = input.int(14, minval=1, title="EMA 14m1 suav Length")

var float smma = na
smma := na(smma[1]) ? ta.sma(close, smmaLen) : (smma[1] * (smmaLen - 1) + close) / smmaLen

plot(smma, title="EMA 14m1 suav", color=color.purple, linewidth=2)
````
