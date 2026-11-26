# NEXT LEVEL VIP

- url: https://www.tradingview.com/script/jYQhEwzM/
- type: indicator
- pine_id: PUB;076f482c25b84ad5ae2364b672433200
- version: 1.0

## Description

........................................................................

## Source Code

````pine
//@version=5
indicator("NEXT LEVEL VIP", overlay=true)

// === Inputs ===
timeframe_input = input.timeframe("15", title="Timeframe")
emaLength = input.int(50, "EMA Length", minval=10)
atrLength = input.int(14, "ATR Length", minval=5)
rsiLength = input.int(14, "RSI Length", minval=5)
volLength = input.int(20, "Volume MA Length", minval=5)
adxLength = input.int(14, "ADX Length", minval=5)
adxThreshold = input.int(20, "ADX Threshold", minval=10)
rsiOverbought = input.int(70, "RSI Overbought", minval=50)
rsiOversold = input.int(30, "RSI Oversold", minval=20)
atrMultSL = input.float(2.0, "ATR Multiplier SL", step=0.1)
atrMultTP = input.float(3.0, "ATR Multiplier TP", step=0.1)
volMultiplier = input.float(1.2, "Volume Multiplier", step=0.1)
whaleVolThreshold = input.float(1.4, "Whale Volume Threshold", step=0.1)
maxLossPercent = input.float(1.5, "Max Loss %", step=0.1) / 100
pullbackLookback = input.int(5, "Pullback Lookback Bars", minval=3)  // Nuevo: Ventana para detectar pullbacks
pullbackAtrMult = input.float(1.5, "Pullback ATR Multiplier", step=0.1)  // Nuevo: Umbral de retroceso

// Ajuste dinámico según temporalidad
var int timeframe_minutes = 60
if timeframe.period == "1"
    timeframe_minutes := 1
else if timeframe.period == "5"
    timeframe_minutes := 5
else if timeframe.period == "15"
    timeframe_minutes := 15
else if timeframe.period == "30"
    timeframe_minutes := 30
else if timeframe.period == "60"
    timeframe_minutes := 60
else if timeframe.period == "240"
    timeframe_minutes := 240
else if timeframe.period == "D"
    timeframe_minutes := 1440
else if timeframe.period == "W"
    timeframe_minutes := 10080

timeframe_multiplier = math.min(timeframe_minutes / 15, 16)
trendFilterBars = math.round(input.int(8, "Base Trend Filter Bars", minval=5) * timeframe_multiplier)
whaleVolSustainBars = math.round(input.int(3, "Base Whale Volume Sustain Bars", minval=1) * math.min(timeframe_multiplier, 8))
confirmBars = math.round(input.int(1, "Base Confirm Bars", minval=0) * math.min(timeframe_multiplier, 8))
lookbackBars = input.int(50, "Lookback Bars for VWAP", minval=20)

// === Cálculos Base ===
ema = ta.ema(close, emaLength)
atr = ta.atr(atrLength)
rsi = ta.rsi(close, rsiLength)
avgVol = ta.sma(volume, volLength)

// VWAP Manual
var float price_volume_sum = 0.0
var float volume_sum = 0.0
typical_price = (high + low + close) / 3
price_volume_sum := typical_price * volume + (ta.barssince(barstate.isfirst) >= lookbackBars ? price_volume_sum[lookbackBars] : 0)
volume_sum := volume + (ta.barssince(barstate.isfirst) >= lookbackBars ? volume_sum[lookbackBars] : 0)
vwap_manual = volume_sum != 0 ? price_volume_sum / volume_sum : typical_price

// Indicadores Derivados
rsiTrend = rsi > 50 ? 1 : -1
volSpike = volume > avgVol * volMultiplier
whaleVol = volume > avgVol * whaleVolThreshold * (atr / ta.sma(atr, 20)) * (timeframe_multiplier > 4 ? 1.2 : timeframe_multiplier > 1 ? 1.5 : 1)
whaleVolSustained = ta.barssince(not whaleVol) <= whaleVolSustainBars

// ADX (Tendencia)
[diplus, diminus, _] = ta.dmi(adxLength, adxLength)
dx = 100 * math.abs(diplus - diminus) / (diplus + diminus)
adx = ta.rma(dx, adxLength)
trendStrength = adx > adxThreshold or adx > 15

// Filtro de Tendencia Dinámico
highestHigh = ta.highest(high, trendFilterBars)
lowestLow = ta.lowest(low, trendFilterBars)
rawTrendDirection = close > highestHigh[1] ? 1 : close < lowestLow[1] ? -1 : 0
trendDirection = ta.sma(rawTrendDirection, math.min(timeframe_multiplier, 8))

// Momentum y Confirmación de EMA
priceChange3 = ta.change(close, 3)
priceMomentum = priceChange3 > 0 ? 1 : priceChange3 < 0 ? -1 : 0
emaSlope = ta.change(ema, 2)
trendConfirmation = trendDirection > 0 and priceMomentum > 0 and emaSlope > 0 ? 1 : trendDirection < 0 and priceMomentum < 0 and emaSlope < 0 ? -1 : 0

// Filtro de Volatilidad
atrAvg = ta.sma(atr, 20)
volatilityFilter = atr < atrAvg * 2.0 and atr > atrAvg * 0.5 and ta.change(atr, 1) < atrAvg * 0.5

// === Detección de Actividad de Ballenas ===
vwaUp = whaleVol and whaleVolSustained and close > vwap_manual and ta.change(close) > 0 and volume > ta.sma(volume, 5) * 1.1
vwaDown = whaleVol and whaleVolSustained and close < vwap_manual and ta.change(close) < 0 and volume > ta.sma(volume, 5) * 1.1

// === Sistema de Scoring ===
score = 0.0
score := score + (trendStrength ? 1.5 : 0.0)
score := score + (volSpike ? 1.0 : 0.0)
score := score + (whaleVol ? 1.5 : 0.0)
score := score + (rsiTrend == 1 and rsi < rsiOverbought ? 1.0 : rsiTrend == -1 and rsi > rsiOversold ? 1.0 : 0.0)
score := score + (trendDirection > 0 and close > ema ? 1.0 : trendDirection < 0 and close < ema ? 1.0 : 0.0)
score := score + (vwaUp ? 1.5 : vwaDown ? -1.5 : 0.0) + (whaleVolSustained ? 0.5 : 0.0)
scoreThreshold = timeframe_multiplier <= 1 ? 3.2 : 3.0

// === Super Identificadores de Pullbacks ===
pullbackUpCondition = false
pullbackDownCondition = false

// Pullback Alcista Mejorado
pullbackHigh = ta.highest(high, pullbackLookback)
pullbackLow = ta.lowest(low, pullbackLookback)
pullbackDepth = (pullbackHigh - pullbackLow) / atr
pullbackUpCondition := ta.lowest(low, pullbackLookback) < ema and close > ema and rsi > 35 and rsi < 75 and pullbackDepth > pullbackAtrMult and close > vwap_manual and volume > avgVol and trendConfirmation > 0

// Pullback Bajista Mejorado
pullbackDownCondition := ta.highest(high, pullbackLookback) > ema and close < ema and rsi < 65 and rsi > 25 and pullbackDepth > pullbackAtrMult and close < vwap_manual and volume > avgVol and trendConfirmation < 0

// Breakouts
breakoutUp = ta.crossover(close, ema) or (vwaUp and close > ema[1])
breakoutDown = ta.crossunder(close, ema) or (vwaDown and close < ema[1])

// Señales Finales con Pullbacks Reforzados
buySignal = (breakoutUp or pullbackUpCondition) and score >= scoreThreshold and volatilityFilter
sellSignal = (breakoutDown or pullbackDownCondition) and score >= scoreThreshold and volatilityFilter

// === Gestión de Operaciones ===
var bool inLong = false
var bool inShort = false
var float entryLong = 0.0
var float entryShort = 0.0
var float slLong = 0.0
var float slShort = 0.0
var float tpLong = 0.0
var float tpShort = 0.0
var float trailingStopLong = 0.0
var float trailingStopShort = 0.0

// Cálculo de SL/TP y Trailing Stop
lowestLow3 = ta.lowest(low, 3)
highestHigh3 = ta.highest(high, 3)
if buySignal
    slLong := lowestLow3 - atr * atrMultSL
    tpLong := highestHigh3 + atr * atrMultTP
    trailingStopLong := slLong
if sellSignal
    slShort := highestHigh3 + atr * atrMultSL
    tpShort := lowestLow3 - atr * atrMultTP
    trailingStopShort := slShort

// Trailing Stop Dinámico
atrFactor = atr / atrAvg
trailingMult = atrMultSL * math.max(1.0, atrFactor)
if inLong
    trailingStopLong := math.max(trailingStopLong, close - atr * trailingMult)
if inShort
    trailingStopShort := math.min(trailingStopShort, close + atr * trailingMult)

// Entradas
if buySignal and not inLong
    inLong := true
    entryLong := close
    label.new(bar_index, low, "COMPRA YA", color=color.green, style=label.style_label_up, textcolor=color.white)

if sellSignal and not inShort
    inShort := true
    entryShort := close
    label.new(bar_index, high, "VENTA YA", color=color.red, style=label.style_label_down, textcolor=color.white)

// Salidas
exitLong = inLong and (close < entryLong * (1 - maxLossPercent) or close >= tpLong or close <= trailingStopLong or trendConfirmation < 0)
exitShort = inShort and (close > entryShort * (1 + maxLossPercent) or close <= tpShort or close >= trailingStopShort or trendConfirmation > 0)

if exitLong
    inLong := false

if exitShort
    inShort := false

// === Alertas con Tendencia ===
buySignalUpTrend = buySignal and trendConfirmation > 0
buySignalDownTrend = buySignal and trendConfirmation < 0
buySignalNeutralTrend = buySignal and trendConfirmation == 0

sellSignalUpTrend = sellSignal and trendConfirmation > 0
sellSignalDownTrend = sellSignal and trendConfirmation < 0
sellSignalNeutralTrend = sellSignal and trendConfirmation == 0

alertcondition(buySignalUpTrend, title="Compra - Up Trend", message="🚀 COMPRA YA | Price: {{close}} | Ticker: {{ticker}} | Tendencia alcista fuerte")
alertcondition(buySignalDownTrend, title="Compra - Down Trend", message="🚀 COMPRA YA | Price: {{close}} | Ticker: {{ticker}} | Tendencia bajista, cuidado")
alertcondition(buySignalNeutralTrend, title="Compra - Neutral Trend", message="🚀 COMPRA YA | Price: {{close}} | Ticker: {{ticker}} | Tendencia neutral")

alertcondition(sellSignalUpTrend, title="Venta - Up Trend", message="🚀 VENTA YA | Price: {{close}} | Ticker: {{ticker}} | Tendencia alcista, cuidado")
alertcondition(sellSignalDownTrend, title="Venta - Down Trend", message="🚀 VENTA YA | Price: {{close}} | Ticker: {{ticker}} | Tendencia bajista fuerte")
alertcondition(sellSignalNeutralTrend, title="Venta - Neutral Trend", message="🚀 VENTA YA | Price: {{close}} | Ticker: {{ticker}} | Tendencia neutral")

// === ALERTAS GENERALES (SIN FILTRO DE TENDENCIA) ===
alertcondition(buySignal, title="Compra General", message="🚀 COMPRA YA | Price: {{close}} | Ticker: {{ticker}} | Señal general")

alertcondition(sellSignal, title="Venta General", message="🚀 VENTA YA | Price: {{close}} | Ticker: {{ticker}} | Señal general")

// === Visualización ===
plot(ema, title="EMA", color=color.blue, linewidth=2)
plot(vwap_manual, title="VWAP", color=color.yellow, linewidth=1)
plotshape(series=breakoutUp, title="Breakout Up", style=shape.diamond, location=location.abovebar, color=color.blue, size=size.tiny)
plotshape(series=pullbackUpCondition, title="Super Pullback Up", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small)
plotshape(series=breakoutDown, title="Breakout Down", style=shape.diamond, location=location.belowbar, color=color.red, size=size.tiny)
plotshape(series=pullbackDownCondition, title="Super Pullback Down", style=shape.triangledown, location=location.abovebar, color=color.fuchsia, size=size.small)
plotshape(series=whaleVol, title="Whale Volume", style=shape.circle, location=location.abovebar, color=color.purple, size=size.tiny)

// Diagnósticos Avanzados: Tabla
var table diagTable = table.new(position.top_right, 3, 4, border_width=1)
if barstate.islastconfirmedhistory
    table.cell(diagTable, 0, 0, "Score", bgcolor=color.new(color.gray, 90), text_color=color.white)
    table.cell(diagTable, 1, 0, str.tostring(score), bgcolor=color.new(color.gray, 90), text_color=color.white)
    table.cell(diagTable, 0, 1, "ATR/ATR Avg", bgcolor=color.new(color.gray, 90), text_color=color.white)
    table.cell(diagTable, 1, 1, str.tostring(atrFactor), bgcolor=color.new(color.gray, 90), text_color=color.white)
    table.cell(diagTable, 0, 2, "Dist to VWAP", bgcolor=color.new(color.gray, 90), text_color=color.white)
    table.cell(diagTable, 1, 2, str.tostring((close - vwap_manual) / atr), bgcolor=color.new(color.gray, 90), text_color=color.white)
    table.cell(diagTable, 0, 3, "Pullback Depth", bgcolor=color.new(color.gray, 90), text_color=color.white)
    table.cell(diagTable, 1, 3, str.tostring(pullbackDepth), bgcolor=color.new(color.gray, 90), text_color=color.white)

// Diagnósticos Gráficos
hline(price=adxThreshold, title="ADX Threshold", color=color.gray, linestyle=hline.style_dashed)
plot(adx, title="ADX", color=color.orange)
plot(rsi, title="RSI", color=color.purple)
plot(score, title="Signal Score", color=color.teal)
````
