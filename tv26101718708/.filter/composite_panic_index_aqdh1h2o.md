# Composite Panic Index

- url: https://www.tradingview.com/script/aqdh1H2O/
- type: indicator
- pine_id: PUB;e340da4b8d4445bc91a0aebd9db25c48
- version: 1.0

## Description

ENGLISH VERSION

Composite Panic Index (Gold + VIX + DXY)

Overview
The Composite Panic Index is a multi-asset indicator designed to identify periods of market-wide fear and uncertainty by combining three key macro components:

VIX (CBOE Volatility Index): measures market fear via implied volatility
DXY (US Dollar Index): reflects USD strength as a safe haven
Gold (XAUUSD): traditional store of value during uncertainty

Instead of relying on news or subjective interpretation, this indicator measures how the market behaves under stress, providing an objective view of panic conditions.

Core Logic

Momentum Extraction
For each asset (Gold, VIX, DXY), the indicator calculates a short-term rate of change (ROC) to detect acceleration and shifts in market sentiment.
Normalization (Z-score)
Each component is normalized using a Z-score to:
Align different assets into a comparable scale
Remove bias from price magnitude differences
Highlight statistically abnormal movements
Composite Score
All components are combined into a single value using a weighted average and smoothed with an EMA. This produces the Composite Panic Score.

Indicator Components

Composite Panic Score (white line): represents the overall panic level
Panic Level (orange line): threshold for elevated uncertainty
Extreme Panic Level (red line): threshold for strong panic conditions
Background color:
Orange = panic regime
Red = extreme panic regime
Signals:
PANIC = new panic phase
EXT = new extreme panic phase
Table:
Displays Gold, VIX, and DXY direction, current score, and regime

Filters and Confirmation

Optional filters ensure that panic is only detected when:

Gold is rising
VIX is rising
DXY is rising

Signals are confirmed over multiple bars to reduce noise and false positives.

How to Use

Low values: normal conditions
Medium values: increasing uncertainty
High values: panic environment

The most relevant moments are when panic or extreme panic begins, often associated with volatility expansion and strong market movements.

This indicator should be used as a context tool, not as a standalone entry signal.

Limitations

Not all panic is synchronized across assets
Gold and DXY may diverge depending on macro conditions
The indicator does not read news directly, only market reactions

Summary

The Composite Panic Index transforms macro behavior into a single readable metric, helping identify when markets are driven by fear.






VERSIÓN EN ESPAÑOL

Composite Panic Index (Oro + VIX + DXY)

Descripción
El Composite Panic Index es un indicador multi-activo diseñado para identificar momentos de miedo e incertidumbre en el mercado combinando tres referencias clave:

VIX: mide el miedo mediante volatilidad implícita
DXY: refleja la fortaleza del dólar como activo refugio
Oro (XAUUSD): activo refugio tradicional

En lugar de basarse en noticias, el indicador mide directamente cómo reacciona el mercado ante situaciones de estrés.

Lógica interna

Cálculo de momentum
Se utiliza el ROC (rate of change) para detectar aceleraciones y cambios de sentimiento.
Normalización (Z-score)
Se aplica Z-score para:
Igualar escalas entre activos
Eliminar sesgos por magnitud de precio
Detectar movimientos anómalos
Score compuesto
Se combinan los tres activos mediante una media ponderada y se suaviza con una EMA, generando el nivel de pánico.

Componentes del indicador

Línea principal (blanca): nivel de pánico
Nivel de pánico (naranja)
Nivel de pánico extremo (rojo)
Fondo:
Naranja = pánico
Rojo = pánico extremo
Señales:
PANIC = inicio de pánico
EXT = inicio de pánico extremo
Tabla:
Muestra dirección de oro, VIX y DXY, valor del índice y estado actual

Filtros

Opcionales:

Oro subiendo
VIX subiendo
DXY subiendo

Permiten confirmar que el pánico es coherente entre activos.

Cómo usarlo

Valores bajos: mercado normal
Valores medios: aumento de incertidumbre
Valores altos: entorno de pánico

Los momentos más importantes son cuando comienza el pánico o el pánico extremo.

No es un sistema de entrada, sino una herramienta de contexto y confirmación.

Limitaciones

No siempre hay alineación entre activos
Oro y dólar pueden comportarse de forma distinta
No detecta noticias, solo sus efectos

Resumen

El Composite Panic Index convierte señales macro complejas en un único valor que permite identificar cuándo el mercado está dominado por el miedo.

## Source Code

````pine
//@version=6
indicator("Composite Panic Index", shorttitle="Panic Index", overlay=false, max_labels_count=500)

//---------------------------------------------------------
// Inputs
//---------------------------------------------------------
groupSymbols = "Symbols"
symGold = input.symbol("OANDA:XAUUSD", "Gold symbol", group=groupSymbols)
symVix  = input.symbol("CBOE:VIX", "VIX symbol", group=groupSymbols)
symDxy  = input.symbol("TVC:DXY", "DXY symbol", group=groupSymbols)
tfData  = input.timeframe("", "Data timeframe (blank = chart TF)", group=groupSymbols)

groupCalc = "Calculation"
lenReturn = input.int(5, "Return lookback", minval=1, group=groupCalc)
lenZscore = input.int(50, "Z-score length", minval=10, group=groupCalc)
lenSmooth = input.int(5, "Smoothing", minval=1, group=groupCalc)

groupWeights = "Weights"
wGold = input.float(1.0, "Gold weight", minval=0.0, step=0.1, group=groupWeights)
wVix  = input.float(1.5, "VIX weight", minval=0.0, step=0.1, group=groupWeights)
wDxy  = input.float(1.0, "DXY weight", minval=0.0, step=0.1, group=groupWeights)

groupThresholds = "Thresholds"
panicLevel   = input.float(1.2, "Panic threshold", step=0.1, group=groupThresholds)
extremeLevel = input.float(2.0, "Extreme panic threshold", step=0.1, group=groupThresholds)
confirmBars  = input.int(2, "Bars required for confirmation", minval=1, group=groupThresholds)

groupFilters = "Filters"
useGoldFilter = input.bool(true, "Require gold rising", group=groupFilters)
useDxyFilter  = input.bool(true, "Require DXY rising", group=groupFilters)
useVixFilter  = input.bool(true, "Require VIX rising", group=groupFilters)

//---------------------------------------------------------
// Helpers
//---------------------------------------------------------
f_zscore(src, len) =>
    ma = ta.sma(src, len)
    sd = ta.stdev(src, len)
    sd == 0.0 or na(sd) ? 0.0 : (src - ma) / sd

f_secure_close(symbol) =>
    request.security(
         symbol,
         tfData == "" ? timeframe.period : tfData,
         close,
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off)

//---------------------------------------------------------
// External data
//---------------------------------------------------------
gold = f_secure_close(symGold)
vix  = f_secure_close(symVix)
dxy  = f_secure_close(symDxy)

//---------------------------------------------------------
// Normalized momentum / panic components
//---------------------------------------------------------
goldRet = ta.roc(gold, lenReturn)
vixRet  = ta.roc(vix, lenReturn)
dxyRet  = ta.roc(dxy, lenReturn)

goldZ = f_zscore(goldRet, lenZscore)
vixZ  = f_zscore(vixRet, lenZscore)
dxyZ  = f_zscore(dxyRet, lenZscore)

// Composite panic score
weightSum = math.max(wGold + wVix + wDxy, 0.0001)
panicRaw  = (goldZ * wGold + vixZ * wVix + dxyZ * wDxy) / weightSum
panic     = ta.ema(panicRaw, lenSmooth)

//---------------------------------------------------------
// Direction filters
//---------------------------------------------------------
goldUp = goldRet > 0
vixUp  = vixRet > 0
dxyUp  = dxyRet > 0

dirOk = (
     (not useGoldFilter or goldUp) and
     (not useVixFilter or vixUp) and
     (not useDxyFilter or dxyUp)
)

//---------------------------------------------------------
// Panic states
//---------------------------------------------------------
panicNow   = panic > panicLevel and dirOk
extremeNow = panic > extremeLevel and dirOk

panicBars   = math.sum(panicNow ? 1.0 : 0.0, confirmBars)
extremeBars = math.sum(extremeNow ? 1.0 : 0.0, confirmBars)

panicConfirmed   = panicBars >= confirmBars
extremeConfirmed = extremeBars >= confirmBars

newPanic   = panicConfirmed and not panicConfirmed[1]
newExtreme = extremeConfirmed and not extremeConfirmed[1]

//---------------------------------------------------------
// Plots
//---------------------------------------------------------
hline(0, "Zero", color=color.gray)
hline(panicLevel, "Panic", color=color.orange)
hline(extremeLevel, "Extreme", color=color.red)

plot(panic, "Composite Panic Score", color=color.white, linewidth=2)
plot(goldZ, "Gold z-score", color=color.yellow, display=display.none)
plot(vixZ, "VIX z-score", color=color.aqua, display=display.none)
plot(dxyZ, "DXY z-score", color=color.lime, display=display.none)

bgcolor(
     extremeConfirmed ? color.new(color.red, 82) :
     panicConfirmed ? color.new(color.orange, 85) :
     na
)

plotshape(newPanic, title="New Panic", style=shape.triangleup, location=location.bottom, color=color.orange, size=size.small, text="PANIC")
plotshape(newExtreme, title="New Extreme Panic", style=shape.triangleup, location=location.bottom, color=color.red, size=size.small, text="EXT")

//---------------------------------------------------------
// Table
//---------------------------------------------------------
var table t = table.new(position.top_right, 2, 6, border_width=1)

if barstate.islast
    table.cell(t, 0, 0, "Component", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 0, "State", text_color=color.white, bgcolor=color.black)

    table.cell(t, 0, 1, "Gold")
    table.cell(t, 1, 1, goldUp ? "Rising" : "Falling", text_color=goldUp ? color.lime : color.red)

    table.cell(t, 0, 2, "VIX")
    table.cell(t, 1, 2, vixUp ? "Rising" : "Falling", text_color=vixUp ? color.lime : color.red)

    table.cell(t, 0, 3, "DXY")
    table.cell(t, 1, 3, dxyUp ? "Rising" : "Falling", text_color=dxyUp ? color.lime : color.red)

    table.cell(t, 0, 4, "Score")
    table.cell(t, 1, 4, str.tostring(panic, format.mintick), text_color=color.white)

    regimeText = extremeConfirmed ? "Extreme panic" : panicConfirmed ? "Panic" : "Normal"
    regimeColor = extremeConfirmed ? color.red : panicConfirmed ? color.orange : color.silver
    table.cell(t, 0, 5, "Regime")
    table.cell(t, 1, 5, regimeText, text_color=regimeColor)

//---------------------------------------------------------
// Alerts
//---------------------------------------------------------
alertcondition(newPanic, "New Panic Detected", "Composite Panic Index has entered PANIC regime.")
alertcondition(newExtreme, "New Extreme Panic Detected", "Composite Panic Index has entered EXTREME PANIC regime.")
````
