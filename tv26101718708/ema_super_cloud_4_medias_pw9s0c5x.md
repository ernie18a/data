# EMA Super Cloud - 4 Medias

- url: https://www.tradingview.com/script/Pw9s0c5x/
- type: indicator
- pine_id: PUB;e41b84906d78435baa34e4897487c9e0
- version: 1.0

## Description

EMA Super Cloud - 4 Medias  
Indicador profesional para Scalping e Intradía

Características principales:

- Nube dinámica entre MA 20 y MA 60 (verde en alcista / negro en bajista)
- 4 Medias Móviles configurables:
  - MA 20 (rápida - Nube)
  - MA 60 (lenta - Nube)
  - MA 200 
  - MA 800
- Velas coloreadas en tiempo real según la MA 20:
  - Verde → Precio por encima de MA 20 (momentum alcista fuerte)
  - Negro → Precio por debajo de MA 20 (momentum bajista fuerte)
- Señales BUY y SELL solo cuando el precio sale de la nube cruzando la MA 60 (altamente confiable, evita señales falsas)
- Soporta SMA, EMA y WMA (fácil de cambiar)
- Alertas integradas para Buy y Sell

Ideal para:
- Scalping en M1, M2, M5
- Intradía en M15, M30 y H1
- Especialmente optimizado para XAUUSD (Oro) y pares Forex mayores

Configuración recomendada para Oro:
- Tipo de Media: EMA
- MA Rápida: 20
- MA Lenta: 60
- MA3: 200
- MA4: 800

Este indicador combina muy bien la fuerza del momentum (velas coloreadas + nube) con tendencia de más largo plazo (MA 200 y 800).

## Source Code

````pine
//@version=5
indicator("EMA Super Cloud - 4 Medias", shorttitle="EMA Super Cloud", overlay=true, max_bars_back=500)

// ==================== INPUTS ====================
maType = input.string("SMA", "Tipo de Media", options=["SMA", "EMA", "WMA"])

// Medias principales (Nube)
len20  = input.int(20,  "Período MA Rápida (Nube)", minval=1)
len60  = input.int(60,  "Período MA Lenta (Nube)", minval=1)

// Medias adicionales
lenMA3 = input.int(200, "Período MA3 (ej: 200)", minval=1)
lenMA4 = input.int(800, "Período MA4 (ej: 800)", minval=1)

// ==================== FUNCIÓN DE MEDIAS ====================
ma(src, len, type) =>
    if type == "EMA"
        ta.ema(src, len)
    else if type == "WMA"
        ta.wma(src, len)
    else
        ta.sma(src, len)

ma20 = ma(close, len20, maType)
ma60 = ma(close, len60, maType)
ma200 = ma(close, lenMA3, maType)
ma800 = ma(close, lenMA4, maType)

// ==================== NUBE ====================
trendBull = ma20 > ma60

p1 = plot(ma20, color=trendBull ? #5dba8a : #000000, linewidth=2, title="MA 20")
p2 = plot(ma60, color=trendBull ? #000000 : #5dba8a, linewidth=2, title="MA 60")
fill(p1, p2, color = trendBull ? color.new(#5dba8a, 80) : color.new(#000000, 80), title="Super Cloud")

// ==================== MEDIAS ADICIONALES ====================
plot(ma200, color=trendBull ? #5dba8a : #000000, linewidth=1, title="MA 200")
plot(ma800, color=trendBull ? #5dba8a : #000000, linewidth=1, title="MA 800")

// ==================== COLOREADO DE VELAS ====================
barcolor(close > ma20 ? #5dba8a : #000000)

// ==================== SEÑALES (Salida de la nube) ====================
bullEntry = ta.crossover(close, ma60) and close > ma20
bearEntry = ta.crossunder(close, ma60) and close < ma20

plotshape(bullEntry, title="BUY",  location=location.belowbar, color=#5dba8a, style=shape.labelup,   text="BUY",  textcolor=color.white, size=size.normal)
plotshape(bearEntry, title="SELL", location=location.abovebar, color=#000000, style=shape.labeldown, text="SELL", textcolor=color.white, size=size.normal)

// ==================== ALERTAS ====================
alertcondition(bullEntry, title="🚀 EMA Super Cloud BUY",  message="🚀 BUY - Salida alcista fuerte de la nube")
alertcondition(bearEntry, title="🔻 EMA Super Cloud SELL", message="🔻 SELL - Salida bajista fuerte de la nube")
````
