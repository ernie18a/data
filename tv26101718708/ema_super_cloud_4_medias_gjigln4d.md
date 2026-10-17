# EMA Super Cloud - 4 Medias

- url: https://www.tradingview.com/script/gJIgLn4d/
- type: indicator
- pine_id: PUB;deab25ee80ac46f4af40c95519fb2de0
- version: 1.0

## Description

EMA Super Cloud - 4 Medias
Indicador profesional para Scalping e Intradía
Características principales:
•  Nube dinámica entre MA 20 y MA 60 (verde en alcista / negro en bajista)
•  4 Medias Móviles configurables:
	•  MA 20 (rápida - Nube)
	•  MA 60 (lenta - Nube)
	•  MA 200
	•  MA 800
•  Velas coloreadas en tiempo real según la MA 20:
	•  Verde → Precio por encima de MA 20 (momentum alcista fuerte)
	•  Negro → Precio por debajo de MA 20 (momentum bajista fuerte)
•  Señales BUY y SELL solo cuando el precio sale de la nube cruzando la MA 60 (altamente confiable, evita señales falsas)
•  Soporta SMA, EMA y WMA (fácil de cambiar)
•  Alertas integradas para Buy y Sell
Ideal para:
•  Scalping en M1, M2, M5
•  Intradía en M15, M30 y H1
•  Especialmente optimizado para XAUUSD (Oro) y pares Forex mayores
Configuración recomendada para Oro:
•  Tipo de Media: EMA
•  MA Rápida: 20
•  MA Lenta: 50
•  MA3: 200
•  MA4: 800
Este indicador combina muy bien la fuerza del momentum (velas coloreadas + nube) con tendencia de más largo plazo (MA 200 y 800).

## Source Code

````pine
//@version=5
indicator("EMA Super Cloud - 4 Medias", shorttitle="EMA Super Cloud", overlay=true, max_bars_back=500)

// ==================== INPUTS ====================
maType20  = input.string("SMA", "Tipo MA 20 (Nube)",  options=["SMA", "EMA", "WMA"])
maType60  = input.string("SMA", "Tipo MA 60 (Nube)",  options=["SMA", "EMA", "WMA"])
maType200 = input.string("EMA", "Tipo MA 200",        options=["SMA", "EMA", "WMA"])
maType800 = input.string("WMA", "Tipo MA 800",        options=["SMA", "EMA", "WMA"])

len20  = input.int(20,  "Periodo MA 20",  minval=1)
len60  = input.int(60,  "Periodo MA 60",  minval=1)
len200 = input.int(200, "Periodo MA 200", minval=1)
len800 = input.int(800, "Periodo MA 800", minval=1)

// ==================== FUNCION MA ====================
ma(src, len, type) =>
    switch type
        "EMA" => ta.ema(src, len)
        "WMA" => ta.wma(src, len)
        =>       ta.sma(src, len)

ma20  = ma(close, len20,  maType20)
ma60  = ma(close, len60,  maType60)
ma200 = ma(close, len200, maType200)
ma800 = ma(close, len800, maType800)

// ==================== COLORES ====================
colorBull = color.new(#5dba8a, 0)
colorBear = color.new(#000000, 0)

// ==================== NUBE ====================
trendBull = ma20 > ma60

p1 = plot(ma20, color=trendBull ? colorBull : colorBear, linewidth=2, title="MA 20")
p2 = plot(ma60, color=trendBull ? colorBear : colorBull, linewidth=2, title="MA 60")
fill(p1, p2, color=trendBull ? color.new(#5dba8a, 80) : color.new(#000000, 80), title="Nube")

// ==================== MEDIAS ADICIONALES ====================
plot(ma200, color=trendBull ? colorBull : colorBear, linewidth=2, title="MA 200")
plot(ma800, color=trendBull ? colorBull : colorBear, linewidth=5, title="MA 800 Halo")
plot(ma800, color=trendBull ? colorBull : colorBear, linewidth=2, title="MA 800")

// ==================== COLOREADO DE VELAS ====================
barcolor(close > ma20 ? colorBull : colorBear)

// ==================== SENALES ====================
bullEntry = ta.crossover(close, ma60)  and close > ma20
bearEntry = ta.crossunder(close, ma60) and close < ma20

plotshape(bullEntry, title="BUY",  location=location.belowbar, color=colorBull, style=shape.labelup,   text="BUY",  textcolor=color.white, size=size.tiny)
plotshape(bearEntry, title="SELL", location=location.abovebar, color=colorBear, style=shape.labeldown, text="SELL", textcolor=color.white, size=size.tiny)

// ==================== ALERTAS ====================
alertcondition(bullEntry, title="BUY Alert",  message="EMA Super Cloud - BUY")
alertcondition(bearEntry, title="SELL Alert", message="EMA Super Cloud - SELL")
````
