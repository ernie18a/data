# XAUUSD High Probability Signals per Gram v6

- url: https://www.tradingview.com/script/eIqCzxrZ/
- type: indicator
- pine_id: PUB;0a6ec46b30e04395a89b8c664cbc20eb
- version: 1.0

## Description

Indicator created based on the price per gram of 24K gold
Use only on the XAUUSD pair with a 15-minute timeframe
Configuration:
0,05   
3
5
1

## Source Code

````pine
//@version=6
indicator("XAUUSD – Señales por Gramo (Alta Probabilidad v6)", overlay=true, max_lines_count=80)

//----------------------------------------------------
// CONFIGURACIÓN
//----------------------------------------------------
GRAMS = 31.1035

showMain = input.bool(true, "Niveles principales ($1/g)")
showHalf = input.bool(true, "Niveles secundarios ($0.5/g)")

proxPct   = input.float(0.35, "Proximidad (%)", minval=0.05, maxval=1.0)
forceBars = input.int(10, "Barras de fuerza", minval=3, maxval=50)
threshold = input.float(30, "Umbral fuerza (%)", minval=5, maxval=70)
volMult   = input.float(1.1, "Volumen mínimo (x media)", minval=1, maxval=3)

//----------------------------------------------------
// FUNCIONES
//----------------------------------------------------
priceToGram(p) => p / GRAMS
gramToPrice(g) => g * GRAMS
clamp(v, mn, mx) => v < mn ? mn : v > mx ? mx : v

//----------------------------------------------------
// CÁLCULO DE NIVELES
//----------------------------------------------------
gramPrice = priceToGram(close)

nearestMain = math.round(gramPrice)
nearestHalf = math.round(gramPrice * 2) / 2

priceMain = gramToPrice(nearestMain)
priceHalf = gramToPrice(nearestHalf)

isMain = math.abs(close - priceMain) < math.abs(close - priceHalf)

levelPrice = isMain ? priceMain : priceHalf

near = math.abs(close - levelPrice) <= close * (proxPct / 100)

//----------------------------------------------------
// FUERZA (delta suavizado)
//----------------------------------------------------
delta = close > open ? volume : close < open ? -volume : 0

sumDelta = ta.sma(delta, forceBars) * forceBars
maxAbs = math.max(1, math.abs(sumDelta))
strength = clamp((sumDelta / maxAbs) * 100, -100, 100)

// señales por cruce del umbral
crossBuy  = near and strength > threshold  and strength[1] <= threshold
crossSell = near and strength < -threshold and strength[1] >= -threshold

//----------------------------------------------------
// FILTROS SUAVES PERO EFECTIVOS
//----------------------------------------------------
volStrong = volume > ta.sma(volume, 20) * volMult

//----------------------------------------------------
// SEÑALES FINALES
//----------------------------------------------------
var bool buySignal  = false
var bool sellSignal = false

buySignal  := crossBuy  and volStrong
sellSignal := crossSell and volStrong

//----------------------------------------------------
// MOSTRAR SEÑALES
//----------------------------------------------------
plotshape(buySignal, title="Compra", style=shape.triangleup, 
     color=color.new(color.green, 0), size=size.large, location=location.belowbar)

plotshape(sellSignal, title="Venta", style=shape.triangledown, 
     color=color.new(color.red, 0), size=size.large, location=location.abovebar)

//----------------------------------------------------
// NIVELES DE GRAMO
//----------------------------------------------------
float hi = ta.highest(high, 200)
float lo = ta.lowest(low, 200)

startGram = math.floor(priceToGram(lo) * 2) / 2
endGram   = math.ceil(priceToGram(hi) * 2) / 2

var int lastDraw = na

if bar_index != lastDraw
    lastDraw := bar_index

    float g = startGram * 1.0
    while g <= endGram
        p = gramToPrice(g)
        isMainLevel = g == math.round(g)

        if (isMainLevel and showMain) or (not isMainLevel and showHalf)
            col = isMainLevel ? color.new(color.yellow, 10) : color.new(color.yellow, 75)
            st  = isMainLevel ? line.style_solid : line.style_dotted
            line.new(bar_index - 200, p, bar_index + 5, p, color=col, style=st)

        g += 0.5

//----------------------------------------------------
// ALERTAS
//----------------------------------------------------
alertcondition(buySignal,  "Señal de Compra", "Compra por nivel de gramo.")
alertcondition(sellSignal, "Señal de Venta",  "Venta por nivel de gramo.")
````
