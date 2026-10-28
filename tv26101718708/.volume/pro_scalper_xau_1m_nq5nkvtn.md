# PRO SCALPER XAU 1M 

- url: https://www.tradingview.com/script/Nq5nkvtn/
- type: indicator
- pine_id: PUB;d37dcec565d244e9af25c711467ed79e
- version: 3.0

## Description

excelente para scalping.
solo en el par xau/usd
PRO SCALPER XAU 1M

Indicador diseñado para scalping en 1 minuto, especialmente en XAU/USD (oro), que combina múltiples herramientas clave en un solo sistema para generar señales de entrada limpias.

 Qué incluye
EMA 200 → filtro de tendencia principal
VWAP → contexto intradía (compra/venta institucional)
Supertrend (ATR) → dirección y timing
RSI (opcional) → mejora la precisión en entradas
 Cómo funciona

El indicador genera señales LONG / SHORT solo cuando hay confluencia de:

Tendencia (EMA 200)
Contexto (VWAP)
Dirección (Supertrend)
Timing (RSI opcional)

Esto reduce señales falsas y evita operar en zonas de rango.

Enfoque
Pensado para scalping real, no para sobreoperar
Permite entradas en continuación de tendencia
Evita condiciones de mercado sin dirección
 Configuración recomendada
Timeframe: 1 minuto
Activo: XAU/USD
Usar filtro VWAP: Activado
Usar filtro RSI: Opcional (más precisión, menos señales)
 Importante
No es un sistema automático
Funciona mejor en mercados con tendencia
Puede dar pocas señales en rango (esto es intencional)

## Source Code

````pine
//@version=5
indicator("PRO SCALPER XAU 1M - CONTROL SWING V2", overlay=true)

// === INPUTS ===
emaLen = input.int(200, "EMA")
atrPeriod = input.int(10, "ATR Period")
factor = input.float(2.0, "Supertrend Multiplier")

useVWAP = input.bool(true, "Usar VWAP")
cooldownBars = input.int(10, "Velas mínimas entre señales", minval=1)
swingLookback = input.int(10, "Filtro nuevo swing", minval=3)
pullbackBars = input.int(3, "Pullback real en velas", minval=2)

// === CÁLCULOS ===
ema200 = ta.ema(close, emaLen)
vwapValue = ta.vwap(close)

[supertrend, direction] = ta.supertrend(factor, atrPeriod)

// En TradingView:
// direction < 0 = tendencia alcista
// direction > 0 = tendencia bajista
superBull = direction < 0
superBear = direction > 0

// === FILTROS PRINCIPALES ===
trendBull = close > ema200
trendBear = close < ema200

vwapBull = not useVWAP or close > vwapValue
vwapBear = not useVWAP or close < vwapValue

bullSetup = trendBull and vwapBull and superBull
bearSetup = trendBear and vwapBear and superBear

// === NUEVO SWING ===
newHigh = high > ta.highest(high[1], swingLookback)
newLow = low < ta.lowest(low[1], swingLookback)

// === PULLBACK REAL ===
// Evita entradas por mini retrocesos débiles.
pullbackBull = low < ta.lowest(low[1], pullbackBars)
pullbackBear = high > ta.highest(high[1], pullbackBars)

// === SEÑALES ===
longSignal = bullSetup and pullbackBull and newHigh
shortSignal = bearSetup and pullbackBear and newLow

// === COOLDOWN ===
var int lastSignalBar = na
canSignal = na(lastSignalBar) or bar_index - lastSignalBar > cooldownBars

longFinal = longSignal and canSignal
shortFinal = shortSignal and canSignal

if longFinal or shortFinal
    lastSignalBar := bar_index

// === PLOTS ===
plot(ema200, "EMA 200", color=color.orange, linewidth=2)
plot(vwapValue, "VWAP", color=color.blue, linewidth=2)
plot(supertrend, "Supertrend", color=superBull ? color.green : color.red)

// === SEÑALES ===
plotshape(longFinal, title="LONG", text="LONG",
     style=shape.labelup, location=location.belowbar,
     color=color.green, textcolor=color.white, size=size.small)

plotshape(shortFinal, title="SHORT", text="SHORT",
     style=shape.labeldown, location=location.abovebar,
     color=color.red, textcolor=color.white, size=size.small)

// === ALERTAS ===
alertcondition(longFinal, title="LONG ALERT", message="LONG XAU/USD 1M")
alertcondition(shortFinal, title="SHORT ALERT", message="SHORT XAU/USD 1M")
````
