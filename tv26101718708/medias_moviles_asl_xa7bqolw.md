# MEDIAS MOVILES ASL

- url: https://www.tradingview.com/script/Xa7bQOLW/
- type: indicator
- pine_id: PUB;1a117a67194d48f2a97428e6aa8f1112
- version: 1.0

## Description

medidas moviles de 21, 30, 150 y 200 a vision de 4 horas, 3 horas, 2 horas, 1 hora y 45 minutos, 30 minutos, 15 minutos, 5 minutos, 3 minutos, 2 minutos, 1 minut

## Source Code

````pine
//@version=5
indicator(title="EMAs 21-30-150-200", overlay=true)

// --- EMAs calculadas sobre el timeframe actual del gráfico ---
ema21  = ta.ema(close, 21)
ema30  = ta.ema(close, 30)
ema150 = ta.ema(close, 150)
ema200 = ta.ema(close, 200)

// --- Plotear las EMAs ---
plot(ema21,  title="EMA 21",  color=color.blue,   linewidth=2)
plot(ema30,  title="EMA 30",  color=color.orange, linewidth=2)
plot(ema150, title="EMA 150", color=color.red,    linewidth=2)
plot(ema200, title="EMA 200", color=color.black,  linewidth=2)
````
