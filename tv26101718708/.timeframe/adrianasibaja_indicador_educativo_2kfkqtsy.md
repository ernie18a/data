# @adrianasibaja_ Indicador Educativo

- url: https://www.tradingview.com/script/2kFkqtsY-adrianasibaja-Indicador-Educativo/
- type: indicator
- pine_id: PUB;f8083e1d56df4c4cac43338714a4a9f9
- version: 12.0

## Description

Indicador Educativo
EMAS y BB

Educacional para principiantes

## Source Code

````pine
//@version=6
indicator("@adrianasibaja_ Indicador Educativo", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS – Visualización general
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showTrend         = false
showSR            = true
showLiquidity     = true
showEMAs          = true
showBB            = true
showBOS           = true
showCHOCH         = true
showDashboard     = true
showMarketStructure = false

// FVG y Order Blocks
showFVG    = input.bool(true, "Mostrar FVG (Fair Value Gap)",      group="FVG y Order Blocks")
maxFVGZones = input.int(5,    "Max FVGs visibles", minval=1, maxval=20, group="FVG y Order Blocks")
showOB     = input.bool(true, "Mostrar Order Blocks",              group="FVG y Order Blocks")
maxOBZones  = input.int(5,    "Max Order Blocks visibles", minval=1, maxval=20, group="FVG y Order Blocks")

// Extras
showVwap       = input.bool(false, "Mostrar VWAP",                               group="Extras")
showPDLevels   = input.bool(false, "Mostrar PDH / PDL / PDC (dia anterior)",     group="Extras")
showSessions   = input.bool(false, "Mostrar sesiones (Asia / Londres / NY)",      group="Extras")
showDivergences = input.bool(false, "Mostrar divergencias RSI",                   group="Extras")

// EMAs
emaFastLen = input.int(9,   "EMA rapida")
emaMidLen  = input.int(50,  "EMA zona")
emaSlowLen = input.int(200, "EMA tendencia")

// Bollinger
bbLen  = input.int(20,     "Bollinger Length")
bbMult = input.float(2.0,  "Bollinger Desviacion")

// Estructura
pivotLen = input.int(10, "Sensibilidad estructura (HH/HL + Liquidez)", minval=2,
     tooltip="Subir reduce el ruido de etiquetas. Recomendado: 10 en M15, 15 en H1.")

// S/R
srPivotLen = input.int(20, "Sensibilidad Soportes/Resistencias", minval=5,
     tooltip="Mas alto = menos lineas pero mas significativas. Recomendado: 15-25 segun timeframe.")

// Liquidez
liqAtrMult   = input.float(0.5, "Grosor zona liquidez (x ATR)", step=0.05,
     tooltip="0.5 = zonas mas precisas (recomendado). 1.0 = zonas mas anchas.")
liqExtendBars = input.int(80, "Extension zonas de liquidez", minval=10)

// Indicadores
rsiLen    = input.int(14, "RSI Length")
atrLen    = input.int(14, "ATR Length")
adxLen    = input.int(14, "ADX Length")
adxSmooth = input.int(14, "ADX Smoothing")

// Tendencia
trendMinScore = input.int(3, "Puntos minimos para confirmar tendencia", minval=2, maxval=4,
     tooltip="2=mas senales | 3=equilibrado (recomendado) | 4=solo tendencias perfectas")

// HTF
htfTf = input.timeframe("60", "Timeframe superior (sesgo HTF)",
     tooltip="H1 por defecto. Cambia a H4 si operas en M15 o menos.")

// Senal de calidad
showQualitySignal = input.bool(true, "Mostrar senal de alta calidad (triangulos en grafico)",
     tooltip="Aparece cuando tendencia >= trendMinScore + ADX > 25 + RSI en zona neutral")
adxQualityMin    = input.float(25.0, "ADX minimo para senal de calidad", step=1.0)
qualityCooldown  = input.int(20, "Barras minimas entre senales de calidad", minval=5,
     tooltip="Evita racimos de triangulos. 20 barras = ~5 horas en M15.")

// Dashboard – filas visibles individualmente
_dTend   = input.bool(true,  "Tendencia",    group="Dashboard")
_dScore  = input.bool(false, "Puntuacion",   group="Dashboard")
_dHtf    = input.bool(false, "HTF",          group="Dashboard")
_dAlign  = input.bool(false, "HTF alineado", group="Dashboard")
_dCal    = input.bool(false, "Calidad",      group="Dashboard")
_dRsi    = input.bool(true,  "RSI",          group="Dashboard")
_dAdx    = input.bool(true,  "ADX",          group="Dashboard")
_dAtr    = input.bool(true,  "ATR",          group="Dashboard")
_dFuerza = input.bool(false, "Fuerza",       group="Dashboard")
_dSes    = input.bool(true,  "Sesion",       group="Dashboard")
_dDiv    = input.bool(false, "Divergencia",  group="Dashboard")

// Liquidez (complemento)
maxLiquidityZones = input.int(20, "Maximo de zonas de liquidez visibles", minval=1, maxval=100)
showLiqLabels     = input.bool(true, "Mostrar etiquetas de liquidez")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CALCULOS BASE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ema9   = ta.ema(close, emaFastLen)
ema50  = ta.ema(close, emaMidLen)
ema200 = ta.ema(close, emaSlowLen)

basis = ta.sma(close, bbLen)
dev   = bbMult * ta.stdev(close, bbLen)
bbUp  = basis + dev
bbLow = basis - dev

rsi = ta.rsi(close, rsiLen)
atr = ta.atr(atrLen)
[diPlus, diMinus, adx] = ta.dmi(adxLen, adxSmooth)

// Pivotes para estructura y liquidez (pivotLen)
pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow  = ta.pivotlow(low,  pivotLen, pivotLen)

// Pivotes para S/R (srPivotLen)
srPivotHigh = ta.pivothigh(high, srPivotLen, srPivotLen)
srPivotLow  = ta.pivotlow(low,  srPivotLen, srPivotLen)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VWAP
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vwapVal = ta.vwap(hlc3)
plot(showVwap ? vwapVal : na, "VWAP", color=color.new(color.white, 0), linewidth=2)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NIVELES DIA ANTERIOR (PDH / PDL / PDC)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pdh = request.security(syminfo.tickerid, "D", high[1],  lookahead=barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, "D", low[1],   lookahead=barmerge.lookahead_on)
pdc = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)

plot(showPDLevels ? pdh : na, "PDH", color=color.new(color.red,    30), linewidth=1, style=plot.style_stepline)
plot(showPDLevels ? pdl : na, "PDL", color=color.new(color.green,  30), linewidth=1, style=plot.style_stepline)
plot(showPDLevels ? pdc : na, "PDC", color=color.new(color.yellow, 30), linewidth=1, style=plot.style_stepline)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SESIONES – Asia / Londres / Nueva York (UTC)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
sessionHour = hour(time, "UTC")
isAsia   = sessionHour >= 0  and sessionHour < 7
isLondon = sessionHour >= 7  and sessionHour < 13
isNY     = sessionHour >= 13 and sessionHour < 22

bgcolor(showSessions and isAsia   ? color.new(color.blue,   93) : na, title="Sesion Asia")
bgcolor(showSessions and isLondon ? color.new(color.yellow, 93) : na, title="Sesion Londres")
bgcolor(showSessions and isNY     ? color.new(color.orange, 93) : na, title="Sesion NY")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HTF – SESGO DE TIMEFRAME SUPERIOR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
htf_close  = request.security(syminfo.tickerid, htfTf, close,                   lookahead=barmerge.lookahead_off)
htf_ema50  = request.security(syminfo.tickerid, htfTf, ta.ema(close, emaMidLen), lookahead=barmerge.lookahead_off)
htf_ema200 = request.security(syminfo.tickerid, htfTf, ta.ema(close, emaSlowLen), lookahead=barmerge.lookahead_off)

htf_bull = htf_close > htf_ema50 and htf_close > htf_ema200
htf_bear = htf_close < htf_ema50 and htf_close < htf_ema200

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMAs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(showEMAs ? ema9   : na, "EMA 9",   color=color.new(color.aqua,   0), linewidth=2)
plot(showEMAs ? ema50  : na, "EMA 50",  color=color.new(color.purple, 0), linewidth=2)
plot(showEMAs ? ema200 : na, "EMA 200", color=color.new(color.yellow, 0), linewidth=3)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BOLLINGER BANDS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pBBUp  = plot(showBB ? bbUp   : na, "Bollinger Superior", color=color.new(color.orange, 0))
pBBMid = plot(showBB ? basis  : na, "Bollinger Media",    color=color.new(color.orange,   0))
pBBLow = plot(showBB ? bbLow  : na, "Bollinger Inferior", color=color.new(color.orange, 0))
fill(pBBUp, pBBLow, color=showBB ? color.new(color.orange, 90) : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TENDENCIA – Sistema de puntuacion de 4 condiciones
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
c1_bull = close > ema200
c1_bear = close < ema200
c2_bull = ema50  > ema200
c2_bear = ema50  < ema200
c3_bull = ema9   > ema50
c3_bear = ema9   < ema50
c4_bull = diPlus  > diMinus
c4_bear = diMinus > diPlus

bullScore = (c1_bull ? 1 : 0) + (c2_bull ? 1 : 0) + (c3_bull ? 1 : 0) + (c4_bull ? 1 : 0)
bearScore = (c1_bear ? 1 : 0) + (c2_bear ? 1 : 0) + (c3_bear ? 1 : 0) + (c4_bear ? 1 : 0)

bullTrend = bullScore >= trendMinScore
bearTrend = bearScore >= trendMinScore
bullWeak  = bullScore == 2 and not bearTrend
bearWeak  = bearScore == 2 and not bullTrend

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DIVERGENCIAS RSI
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
rsiPivotHigh = ta.pivothigh(rsi, pivotLen, pivotLen)
rsiPivotLow  = ta.pivotlow(rsi,  pivotLen, pivotLen)

var float prevPriceSwingHigh = na
var float prevPriceSwingLow  = na
var float prevRsiSwingHigh   = na
var float prevRsiSwingLow    = na

bullDivRaw = not na(pivotLow)  and not na(rsiPivotLow)  and
     not na(prevPriceSwingLow)  and not na(prevRsiSwingLow)  and
     pivotLow  < prevPriceSwingLow  and rsiPivotLow  > prevRsiSwingLow

bearDivRaw = not na(pivotHigh) and not na(rsiPivotHigh) and
     not na(prevPriceSwingHigh) and not na(prevRsiSwingHigh) and
     pivotHigh > prevPriceSwingHigh and rsiPivotHigh < prevRsiSwingHigh

if not na(pivotLow) and not na(rsiPivotLow)
    prevPriceSwingLow := pivotLow
    prevRsiSwingLow   := rsiPivotLow

if not na(pivotHigh) and not na(rsiPivotHigh)
    prevPriceSwingHigh := pivotHigh
    prevRsiSwingHigh   := rsiPivotHigh

var int lastBullDivBar = -999
var int lastBearDivBar = -999

bullDiv = showDivergences and bullDivRaw and (bar_index - lastBullDivBar) > qualityCooldown
bearDiv = showDivergences and bearDivRaw and (bar_index - lastBearDivBar) > qualityCooldown

if bullDiv
    lastBullDivBar := bar_index
if bearDiv
    lastBearDivBar := bar_index

plotshape(bullDiv, "Div. Alcista RSI", shape.circle, location.belowbar,
     color=color.new(color.aqua,    0), size=size.tiny)
plotshape(bearDiv, "Div. Bajista RSI", shape.circle, location.abovebar,
     color=color.new(color.fuchsia, 0), size=size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SENAL DE ALTA CALIDAD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
adxFuerte      = adx > adxQualityMin
qualityBuyRaw  = bullTrend and adxFuerte and rsi > 35 and rsi < 65 and htf_bull
qualitySellRaw = bearTrend and adxFuerte and rsi > 35 and rsi < 65 and htf_bear

var int lastQualityBuyBar  = -999
var int lastQualitySellBar = -999

qualityBuy  = qualityBuyRaw  and (bar_index - lastQualityBuyBar)  > qualityCooldown
qualitySell = qualitySellRaw and (bar_index - lastQualitySellBar) > qualityCooldown

if qualityBuy
    lastQualityBuyBar  := bar_index
if qualitySell
    lastQualitySellBar := bar_index

plotshape(showQualitySignal and qualityBuy,  "Senal Calidad BUY",
     shape.triangleup,   location.belowbar,
     color=color.new(color.lime, 0), size=size.small)
plotshape(showQualitySignal and qualitySell, "Senal Calidad SELL",
     shape.triangledown, location.abovebar,
     color=color.new(color.red,  0), size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SOPORTES Y RESISTENCIAS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var line lastResistance = na
var line lastSupport    = na

if showSR and not na(srPivotHigh)
    line.delete(lastResistance)
    lastResistance := line.new(bar_index - srPivotLen, srPivotHigh, bar_index + 40, srPivotHigh,
         extend=extend.none, color=color.new(color.red,   0), width=3)

if showSR and not na(srPivotLow)
    line.delete(lastSupport)
    lastSupport := line.new(bar_index - srPivotLen, srPivotLow, bar_index + 40, srPivotLow,
         extend=extend.none, color=color.new(color.green, 0), width=3)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ZONAS DE LIQUIDEZ
// LZ ↑ (rojo)   = liquidez sobre maximos: precio podria subir a barrerse
// LZ ↓ (verde)  = liquidez bajo minimos:  precio podria bajar a barrerse
//
// Estados:
//   Activa → borde solido visible, fondo semitransparente, se extiende derecha
//   Tomada → congelada (borde derecho fijo), fondo casi invisible
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var box[]   buyLiqBoxes   = array.new_box()
var box[]   sellLiqBoxes  = array.new_box()
var label[] buyLiqLabels  = array.new_label()
var label[] sellLiqLabels = array.new_label()
var bool[]  buyLiqTaken   = array.new_bool()
var bool[]  sellLiqTaken  = array.new_bool()

liqZone = atr * liqAtrMult

if showLiquidity and not na(pivotHigh)
    boxLeft   = bar_index - pivotLen
    newBuyBox = box.new(
         left=boxLeft, top=pivotHigh + liqZone, right=bar_index, bottom=pivotHigh,
         bgcolor=color.new(color.red, 82), border_color=color.new(color.red, 20), border_width=1)
    array.push(buyLiqBoxes, newBuyBox)
    array.push(buyLiqTaken, false)
    if showLiqLabels
        array.push(buyLiqLabels, label.new(
             x=boxLeft + math.round(pivotLen / 2), y=pivotHigh + liqZone / 2,
             text="Zona de liquidez",
             style=label.style_none, textcolor=color.new(color.red, 0), size=size.small))
    else
        array.push(buyLiqLabels, na)

if showLiquidity and not na(pivotLow)
    boxLeft    = bar_index - pivotLen
    newSellBox = box.new(
         left=boxLeft, top=pivotLow, right=bar_index, bottom=pivotLow - liqZone,
         bgcolor=color.new(color.green, 82), border_color=color.new(color.green, 20), border_width=1)
    array.push(sellLiqBoxes, newSellBox)
    array.push(sellLiqTaken, false)
    if showLiqLabels
        array.push(sellLiqLabels, label.new(
             x=boxLeft + math.round(pivotLen / 2), y=pivotLow - liqZone / 2,
             text="Zona de liquidez",
             style=label.style_none, textcolor=color.new(color.green, 0), size=size.small))
    else
        array.push(sellLiqLabels, na)

// Actualizar zonas: extender mientras activas, congelar al ser tomadas
if array.size(buyLiqBoxes) > 0
    for i = array.size(buyLiqBoxes) - 1 to 0
        b     = array.get(buyLiqBoxes, i)
        taken = array.get(buyLiqTaken, i)
        if not na(b) and not taken
            if high >= box.get_bottom(b)  // Precio barre la zona
                box.set_right(b, bar_index)
                box.set_bgcolor(b,       color.new(color.red, 96))
                box.set_border_color(b,  color.new(color.red, 80))
                array.set(buyLiqTaken, i, true)
            else
                box.set_right(b, bar_index)

if array.size(sellLiqBoxes) > 0
    for i = array.size(sellLiqBoxes) - 1 to 0
        b     = array.get(sellLiqBoxes, i)
        taken = array.get(sellLiqTaken, i)
        if not na(b) and not taken
            if low <= box.get_top(b)
                box.set_right(b, bar_index)
                box.set_bgcolor(b,      color.new(color.green, 96))
                box.set_border_color(b, color.new(color.green, 80))
                array.set(sellLiqTaken, i, true)
            else
                box.set_right(b, bar_index)

while array.size(buyLiqBoxes) > maxLiquidityZones
    box.delete(array.shift(buyLiqBoxes))
    lbl = array.shift(buyLiqLabels)
    if not na(lbl)
        label.delete(lbl)
    array.shift(buyLiqTaken)

while array.size(sellLiqBoxes) > maxLiquidityZones
    box.delete(array.shift(sellLiqBoxes))
    lbl = array.shift(sellLiqLabels)
    if not na(lbl)
        label.delete(lbl)
    array.shift(sellLiqTaken)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BOS / CHOCH – ESTILO LIMPIO
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float lastSwingHigh    = na
var float lastSwingLow     = na
var int   lastSwingHighBar = na
var int   lastSwingLowBar  = na
var int   marketBias       = 0

if not na(pivotHigh)
    lastSwingHigh    := pivotHigh
    lastSwingHighBar := bar_index - pivotLen

if not na(pivotLow)
    lastSwingLow    := pivotLow
    lastSwingLowBar := bar_index - pivotLen

bullBreak = not na(lastSwingHigh) and ta.crossover(close,  lastSwingHigh)
bearBreak = not na(lastSwingLow)  and ta.crossunder(close, lastSwingLow)

isBullBos   = bullBreak and marketBias ==  1
isBearBos   = bearBreak and marketBias == -1
isBullChoch = bullBreak and marketBias !=  1
isBearChoch = bearBreak and marketBias != -1

bosBullColor = color.new(color.teal,   0)
bosBearColor = color.new(color.red,    0)
chochColor   = color.new(color.orange, 0)
labelOffset  = atr * 0.4

if showBOS and isBullBos
    line.new(lastSwingHighBar, lastSwingHigh, bar_index, lastSwingHigh,
         color=bosBullColor, width=2, style=line.style_solid)
    label.new(math.floor((lastSwingHighBar + bar_index) / 2),
         lastSwingHigh + labelOffset,
         "BOS", style=label.style_none, textcolor=bosBullColor, size=size.small)

if showBOS and isBearBos
    line.new(lastSwingLowBar, lastSwingLow, bar_index, lastSwingLow,
         color=bosBearColor, width=2, style=line.style_solid)
    label.new(math.floor((lastSwingLowBar + bar_index) / 2),
         lastSwingLow - labelOffset,
         "BOS", style=label.style_none, textcolor=bosBearColor, size=size.small)

if showCHOCH and isBullChoch
    line.new(lastSwingHighBar, lastSwingHigh, bar_index, lastSwingHigh,
         color=chochColor, width=1, style=line.style_dashed)
    label.new(math.floor((lastSwingHighBar + bar_index) / 2),
         lastSwingHigh + labelOffset,
         "CHoCH", style=label.style_none, textcolor=chochColor, size=size.small)

if showCHOCH and isBearChoch
    line.new(lastSwingLowBar, lastSwingLow, bar_index, lastSwingLow,
         color=chochColor, width=1, style=line.style_dashed)
    label.new(math.floor((lastSwingLowBar + bar_index) / 2),
         lastSwingLow - labelOffset,
         "CHoCH", style=label.style_none, textcolor=chochColor, size=size.small)

if bullBreak
    marketBias := 1
if bearBreak
    marketBias := -1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ORDER BLOCKS
//
// Concepto SMC: el OB es la ULTIMA vela contraria antes de un impulso fuerte.
// Las instituciones dejan sus ordenes en esa zona; el precio suele regresar a retestearla.
//
// Bullish OB (teal):   vela BAJISTA en el pivot LOW  → instituciones compraron aqui
//                      → Precio deberia rebotar al alza si regresa
// Bearish OB (violeta): vela ALCISTA en el pivot HIGH → instituciones vendieron aqui
//                      → Precio deberia rebotar a la baja si regresa
//
// Estados:
//   Fresco   → caja solida, se extiende a la derecha
//   Mitigado → el precio cerro MAS ALLA del OB (zona invalida), caja apagada, congelada
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var box[]   bullOBBoxes    = array.new_box()
var box[]   bearOBBoxes    = array.new_box()
var label[] bullOBLabels   = array.new_label()
var label[] bearOBLabels   = array.new_label()
var bool[]  bullOBMitigated = array.new_bool()
var bool[]  bearOBMitigated = array.new_bool()

// Bullish OB: vela bajista en el minimo del pivot
if showOB and not na(pivotLow)
    cClose = close[pivotLen]
    cOpen  = open[pivotLen]
    cHigh  = high[pivotLen]
    cLow   = low[pivotLen]
    if cClose < cOpen  // Vela bajista = acumulacion institucional
        obLeft  = bar_index - pivotLen
        obRight = bar_index
        obMidY  = cLow + (cHigh - cLow) / 2
        newBox  = box.new(obLeft, cHigh, obRight, cLow,
             bgcolor=color.new(color.teal, 78), border_color=color.new(color.teal, 10), border_width=1)
        array.push(bullOBBoxes, newBox)
        array.push(bullOBMitigated, false)
        lblX = obLeft + math.round((obRight - obLeft) / 2)
        array.push(bullOBLabels, label.new(lblX, obMidY, "OB",
             style=label.style_none, textcolor=color.new(color.teal, 0), size=size.tiny))

// Bearish OB: vela alcista en el maximo del pivot
if showOB and not na(pivotHigh)
    cClose = close[pivotLen]
    cOpen  = open[pivotLen]
    cHigh  = high[pivotLen]
    cLow   = low[pivotLen]
    if cClose > cOpen  // Vela alcista = distribucion institucional
        obLeft  = bar_index - pivotLen
        obRight = bar_index
        obMidY  = cLow + (cHigh - cLow) / 2
        newBox  = box.new(obLeft, cHigh, obRight, cLow,
             bgcolor=color.new(color.purple, 78), border_color=color.new(color.purple, 10), border_width=1)
        array.push(bearOBBoxes, newBox)
        array.push(bearOBMitigated, false)
        lblX = obLeft + math.round((obRight - obLeft) / 2)
        array.push(bearOBLabels, label.new(lblX, obMidY, "OB",
             style=label.style_none, textcolor=color.new(color.purple, 0), size=size.tiny))

// Actualizar OBs: extender y detectar mitigacion
// Bullish OB mitigado cuando el precio cierra POR DEBAJO del minimo del OB
if array.size(bullOBBoxes) > 0
    for i = array.size(bullOBBoxes) - 1 to 0
        b         = array.get(bullOBBoxes, i)
        mitigated = array.get(bullOBMitigated, i)
        if not na(b) and not mitigated
            if low < box.get_bottom(b)  // Precio rompio bajo el OB: invalido
                box.set_bgcolor(b,      color.new(color.teal, 96))
                box.set_border_color(b, color.new(color.teal, 75))
                array.set(bullOBMitigated, i, true)
            else
                box.set_right(b, bar_index)

// Bearish OB mitigado cuando el precio cierra POR ENCIMA del maximo del OB
if array.size(bearOBBoxes) > 0
    for i = array.size(bearOBBoxes) - 1 to 0
        b         = array.get(bearOBBoxes, i)
        mitigated = array.get(bearOBMitigated, i)
        if not na(b) and not mitigated
            if high > box.get_top(b)  // Precio rompio sobre el OB: invalido
                box.set_bgcolor(b,      color.new(color.purple, 96))
                box.set_border_color(b, color.new(color.purple, 75))
                array.set(bearOBMitigated, i, true)
            else
                box.set_right(b, bar_index)

while array.size(bullOBBoxes) > maxOBZones
    box.delete(array.shift(bullOBBoxes))
    lbl = array.shift(bullOBLabels)
    if not na(lbl)
        label.delete(lbl)
    array.shift(bullOBMitigated)

while array.size(bearOBBoxes) > maxOBZones
    box.delete(array.shift(bearOBBoxes))
    lbl = array.shift(bearOBLabels)
    if not na(lbl)
        label.delete(lbl)
    array.shift(bearOBMitigated)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FVG – FAIR VALUE GAP (dinamico con mitigacion)
//
// El FVG es un hueco de precio que el mercado tiende a "rellenar".
// Se forma cuando 3 velas consecutivas dejan un hueco entre la vela 1 y la vela 3.
//
// Bullish FVG (verde):   low_actual > high[2]  → hueco hacia arriba
//                        → El precio podria bajar a rellenarlo (iman de liquidez)
// Bearish FVG (naranja): high_actual < low[2]  → hueco hacia abajo
//                        → El precio podria subir a rellenarlo
//
// Mitigado = el precio entro en el hueco desde el lado opuesto
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var box[]   bullFVGBoxes     = array.new_box()
var box[]   bearFVGBoxes     = array.new_box()
var label[] bullFVGLabels    = array.new_label()
var label[] bearFVGLabels    = array.new_label()
var bool[]  bullFVGMitigated = array.new_bool()
var bool[]  bearFVGMitigated = array.new_bool()
var int[]   bullFVGCreatedAt = array.new_int()
var int[]   bearFVGCreatedAt = array.new_int()

bullFVG = low  > high[2]
bearFVG = high < low[2]

if showFVG and bullFVG
    fTop   = low        // borde superior del hueco (minimo de la vela actual)
    fBot   = high[2]    // borde inferior del hueco (maximo de hace 2 velas)
    fMid   = fBot + (fTop - fBot) / 2
    fLeft  = bar_index - 2
    newBox = box.new(fLeft, fTop, bar_index, fBot,
         bgcolor=color.new(color.lime, 82), border_color=color.new(color.lime, 20), border_width=1)
    array.push(bullFVGBoxes, newBox)
    array.push(bullFVGMitigated, false)
    array.push(bullFVGCreatedAt, bar_index)
    array.push(bullFVGLabels, label.new(fLeft + 1, fMid, "FVG",
         style=label.style_none, textcolor=color.new(color.lime, 0), size=size.tiny))

if showFVG and bearFVG
    fTop   = low[2]     // borde superior del hueco (minimo de hace 2 velas)
    fBot   = high       // borde inferior del hueco (maximo de la vela actual)
    fMid   = fBot + (fTop - fBot) / 2
    fLeft  = bar_index - 2
    newBox = box.new(fLeft, fTop, bar_index, fBot,
         bgcolor=color.new(color.orange, 82), border_color=color.new(color.orange, 20), border_width=1)
    array.push(bearFVGBoxes, newBox)
    array.push(bearFVGMitigated, false)
    array.push(bearFVGCreatedAt, bar_index)
    array.push(bearFVGLabels, label.new(fLeft + 1, fMid, "FVG",
         style=label.style_none, textcolor=color.new(color.orange, 0), size=size.tiny))

// Actualizar FVGs: extender y detectar cuando el precio rellena el hueco
// Bullish FVG mitigado cuando el precio cae DENTRO del hueco (low <= techo del gap)
if array.size(bullFVGBoxes) > 0
    for i = array.size(bullFVGBoxes) - 1 to 0
        b         = array.get(bullFVGBoxes, i)
        mitigated = array.get(bullFVGMitigated, i)
        createdAt = array.get(bullFVGCreatedAt, i)
        if not na(b) and not mitigated
            if bar_index > createdAt and low <= box.get_top(b)
                box.set_bgcolor(b,      color.new(color.lime, 96))
                box.set_border_color(b, color.new(color.lime, 75))
                array.set(bullFVGMitigated, i, true)
            else
                box.set_right(b, bar_index)

// Bearish FVG mitigado cuando el precio sube DENTRO del hueco (high >= suelo del gap)
if array.size(bearFVGBoxes) > 0
    for i = array.size(bearFVGBoxes) - 1 to 0
        b         = array.get(bearFVGBoxes, i)
        mitigated = array.get(bearFVGMitigated, i)
        createdAt = array.get(bearFVGCreatedAt, i)
        if not na(b) and not mitigated
            if bar_index > createdAt and high >= box.get_bottom(b)
                box.set_bgcolor(b,      color.new(color.orange, 96))
                box.set_border_color(b, color.new(color.orange, 75))
                array.set(bearFVGMitigated, i, true)
            else
                box.set_right(b, bar_index)

while array.size(bullFVGBoxes) > maxFVGZones
    box.delete(array.shift(bullFVGBoxes))
    lbl = array.shift(bullFVGLabels)
    if not na(lbl)
        label.delete(lbl)
    array.shift(bullFVGMitigated)
    array.shift(bullFVGCreatedAt)

while array.size(bearFVGBoxes) > maxFVGZones
    box.delete(array.shift(bearFVGBoxes))
    lbl = array.shift(bearFVGLabels)
    if not na(lbl)
        label.delete(lbl)
    array.shift(bearFVGMitigated)
    array.shift(bearFVGCreatedAt)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD – tamano dinamico segun features activas
// Filas siempre visibles (8): Tendencia, Puntuacion, HTF, HTF alineado, RSI, ADX, ATR, Fuerza
// Filas condicionales: Calidad (showQualitySignal), Sesion (showSessions), Div (showDivergences)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
trendText  = bullTrend ? "ALCISTA ↑" : bearTrend ? "BAJISTA ↓" :
     bullWeak  ? "ALCISTA ?" : bearWeak  ? "BAJISTA ?" : "LATERAL –"
trendColor = bullTrend ? color.new(color.green, 0) : bearTrend ? color.new(color.red, 0) :
     bullWeak  ? color.new(color.green, 40) : bearWeak  ? color.new(color.red, 40) :
     color.gray

scoreText = str.tostring(bullTrend or bullWeak ? bullScore : bearScore) + " / 4"

htfText  = htf_bull ? "ALCISTA ↑" : htf_bear ? "BAJISTA ↓" : "NEUTRO –"
htfColor = htf_bull ? color.new(color.green, 0) : htf_bear ? color.new(color.red, 0) : color.gray

htfAligned = (bullTrend and htf_bull) or (bearTrend and htf_bear)

qualityText  = qualityBuy  ? "ALTA ↑ BUY" :
     qualitySell ? "ALTA ↓ SELL" : "–"
qualityColor = qualityBuy  ? color.new(color.lime, 0) :
     qualitySell ? color.new(color.red,  0) : color.new(color.gray, 40)

sessionText  = isNY     ? "Nueva York" :
     isLondon ? "Londres"    :
     isAsia   ? "Asia"       : "Fuera sesion"
sessionColor = isNY     ? color.new(color.orange, 20) :
     isLondon ? color.new(color.yellow, 40) :
     isAsia   ? color.new(color.blue,   30) :
     color.new(color.gray, 50)

divWindow     = 50
recentBullDiv = (bar_index - lastBullDivBar) < divWindow
recentBearDiv = (bar_index - lastBearDivBar) < divWindow
showBullDivDash = recentBullDiv and (not recentBearDiv or lastBullDivBar >= lastBearDivBar)
showBearDivDash = recentBearDiv and not showBullDivDash

divText  = showBullDivDash ? "DIV ALCISTA ↑" :
     showBearDivDash ? "DIV BAJISTA ↓" : "–"
divColor = showBullDivDash ? color.new(color.aqua,    20) :
     showBearDivDash ? color.new(color.fuchsia, 20) :
     color.new(color.gray, 40)

// ── Indices de fila: cada fila ocupa su slot solo si su toggle esta ON ──
// Se calculan en cadena: si una fila esta desactivada, las siguientes suben un puesto.
_rTend   = 0
_rScore  = _rTend   + (_dTend   ? 1 : 0)
_rHtf    = _rScore  + (_dScore  ? 1 : 0)
_rAlign  = _rHtf    + (_dHtf    ? 1 : 0)
_rCal    = _rAlign  + (_dAlign  ? 1 : 0)
_rRsi    = _rCal    + (_dCal    ? 1 : 0)
_rAdx    = _rRsi    + (_dRsi    ? 1 : 0)
_rAtr    = _rAdx    + (_dAdx    ? 1 : 0)
_rFuerza = _rAtr    + (_dAtr    ? 1 : 0)
_rSes    = _rFuerza + (_dFuerza ? 1 : 0)
_rDiv    = _rSes    + (_dSes    ? 1 : 0)

// Total de filas = indice del ultimo slot + 1 si esta activo
_nDashRows = math.max(_rDiv + (_dDiv ? 1 : 0), 1)

// La tabla se elimina y recrea en cada barstate.islast para que el
// numero de filas se ajuste en tiempo real segun los inputs activos.
var table dash = na
if showDashboard and barstate.islast
    if not na(dash)
        table.delete(dash)
    dash := table.new(position.top_right, 2, _nDashRows,
         border_width=1, border_color=color.new(color.gray, 60))

    if _dTend
        table.cell(dash, 0, _rTend, "Tendencia",  bgcolor=color.black, text_color=color.white)
        table.cell(dash, 1, _rTend, trendText,    bgcolor=trendColor,  text_color=color.white)

    if _dScore
        table.cell(dash, 0, _rScore, "Puntuacion", bgcolor=color.black, text_color=color.white)
        table.cell(dash, 1, _rScore, scoreText,
             bgcolor = bullScore >= trendMinScore ? color.new(color.green, 30) :
                       bearScore >= trendMinScore ? color.new(color.red,   30) : color.new(color.gray, 30),
             text_color=color.white)

    if _dHtf
        table.cell(dash, 0, _rHtf, "HTF " + htfTf, bgcolor=color.black, text_color=color.white)
        table.cell(dash, 1, _rHtf, htfText,         bgcolor=htfColor,    text_color=color.white)

    if _dAlign
        table.cell(dash, 0, _rAlign, "HTF alineado", bgcolor=color.black, text_color=color.white)
        table.cell(dash, 1, _rAlign, htfAligned ? "SI ✓" : "NO ✗",
             bgcolor=htfAligned ? color.new(color.green, 30) : color.new(color.gray, 40),
             text_color=color.white)

    if _dCal
        table.cell(dash, 0, _rCal, "Calidad",   bgcolor=color.black, text_color=color.white)
        table.cell(dash, 1, _rCal, qualityText, bgcolor=qualityColor, text_color=color.white)

    if _dRsi
        table.cell(dash, 0, _rRsi, "RSI", bgcolor=color.black, text_color=color.white)
        table.cell(dash, 1, _rRsi, str.tostring(rsi, "#.##"),
             bgcolor=rsi > 70 ? color.red : rsi < 30 ? color.green : color.gray,
             text_color=color.white)

    if _dAdx
        table.cell(dash, 0, _rAdx, "ADX", bgcolor=color.black, text_color=color.white)
        table.cell(dash, 1, _rAdx, str.tostring(adx, "#.##"),
             bgcolor=adx > adxQualityMin ? color.green : color.gray,
             text_color=color.white)

    if _dAtr
        table.cell(dash, 0, _rAtr, "ATR", bgcolor=color.black, text_color=color.white)
        table.cell(dash, 1, _rAtr, str.tostring(atr, "#.##"), bgcolor=color.gray, text_color=color.white)

    if _dFuerza
        table.cell(dash, 0, _rFuerza, "Fuerza", bgcolor=color.black, text_color=color.white)
        table.cell(dash, 1, _rFuerza, adx > adxQualityMin ? "FUERTE" : "DEBIL",
             bgcolor=adx > adxQualityMin ? color.green : color.orange,
             text_color=color.white)

    if _dSes
        table.cell(dash, 0, _rSes, "Sesion",    bgcolor=color.black,  text_color=color.white)
        table.cell(dash, 1, _rSes, sessionText, bgcolor=sessionColor, text_color=color.white)

    if _dDiv
        table.cell(dash, 0, _rDiv, "Divergencia", bgcolor=color.black, text_color=color.white)
        table.cell(dash, 1, _rDiv, divText,        bgcolor=divColor,    text_color=color.white)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARKET STRUCTURE – HH / HL / LL / LH
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float previousPivotHigh = na
var float previousPivotLow  = na

if showMarketStructure and not na(pivotHigh)
    structureText = na(previousPivotHigh) ? "H" : pivotHigh > previousPivotHigh ? "HH" : "LH"
    label.new(
         x=bar_index - pivotLen, y=pivotHigh,
         text=structureText, style=label.style_none, size=size.normal,
         textcolor=pivotHigh > previousPivotHigh or na(previousPivotHigh)
             ? color.new(color.teal, 0) : color.new(color.red, 0))
    previousPivotHigh := pivotHigh

if showMarketStructure and not na(pivotLow)
    structureText = na(previousPivotLow) ? "L" : pivotLow > previousPivotLow ? "HL" : "LL"
    label.new(
         x=bar_index - pivotLen, y=pivotLow,
         text=structureText, style=label.style_none, size=size.normal,
         textcolor=pivotLow > previousPivotLow or na(previousPivotLow)
             ? color.new(color.teal, 0) : color.new(color.red, 0))
    previousPivotLow := pivotLow
````
