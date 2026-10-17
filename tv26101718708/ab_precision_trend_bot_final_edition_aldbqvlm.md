# AB Precision Trend Bot - Final Edition

- url: https://www.tradingview.com/script/aLdbqVlm/
- type: indicator
- pine_id: PUB;a46d045374394568b55d120754d655d0
- version: 2.0

## Description

Precision Trend Bot es un indicador de tendencia que usa ATR Trailing Stop, EMA 200 y ADX para detectar posibles movimientos alcistas o bajistas.

Cuando aparece BUY, indica una posible oportunidad alcista, que en opciones podría interpretarse como posible CALL.

Cuando aparece SELL, indica una posible oportunidad bajista, que en opciones podría interpretarse como posible PUT.

## Source Code

````pine
//@version=5
// @description AB Precision Trend Bot - Suite Profesional
// @version 2.1.2
// @author Abdias Daniel Fernandez Pinto
indicator(title="AB Precision Trend Bot - V2.1.2", shorttitle="AB_V2.1.2", overlay=true, max_lines_count=100, max_labels_count=100)

// ─────────────────────────────────────────────
// CONFIGURACIÓN / INPUTS
// ─────────────────────────────────────────────
grp_ver = "Versión"
version_info = input.string("V 2.1.2 - Clean Architecture", "Build Actual", group=grp_ver)

grp_trend = "Configuración de Tendencia"
sensitivity = input.float(1.5, "Sensibilidad ATR", minval=0.1, step=0.1, group=grp_trend)
atrPeriod = input.int(10, "Periodo ATR", minval=1, group=grp_trend)
useHeikin = input.bool(false, "Cálculos con Heikin Ashi", group=grp_trend)
showAtrStop = input.bool(true, "Mostrar ATR Trailing Stop", group=grp_trend)

grp_filters = "Filtros de Confirmación"
useAdxFilter = input.bool(true, "Usar Filtro ADX", group=grp_filters)
adxThreshold = input.int(20, "Mínimo ADX", minval=1, group=grp_filters)
useTrendFilter = input.bool(true, "Usar EMA 200", group=grp_filters)
trendEmaLen = input.int(200, "Longitud EMA 200", minval=1, group=grp_filters)
confirmClose = input.bool(true, "Confirmar al cierre de vela", group=grp_filters)

grp_ema50 = "EMA 50 Rejection / Structure"
useEma50Module = input.bool(true, "Activar módulo EMA 50", group=grp_ema50)
useEma50AsFilter = input.bool(false, "Usar EMA 50 como filtro", group=grp_ema50)
strictEma50Reject = input.bool(false, "Filtro estricto rechazo", group=grp_ema50)
ema50Len = input.int(50, "Longitud EMA 50", minval=1, group=grp_ema50)
showEma50 = input.bool(true, "Mostrar EMA 50", group=grp_ema50)
showEma50Reject = input.bool(true, "Mostrar rechazos EMA 50", group=grp_ema50)

grp_risk = "Gestión de Riesgo & Risk Free"
showRisk = input.bool(true, "Mostrar ENTRY / SL / TP1 / TP2", group=grp_risk)
useRiskFree = input.bool(true, "Breakeven automático en TP1", group=grp_risk)
rr_tp1 = input.float(1.5, "Ratio TP1", minval=0.1, step=0.1, group=grp_risk)
rr_tp2 = input.float(3.0, "Ratio TP2", minval=0.1, step=0.1, group=grp_risk)
lineExtension = input.int(15, "Extensión de líneas", minval=1, group=grp_risk)

// ─────────────────────────────────────────────
// CÁLCULOS TÉCNICOS
// ─────────────────────────────────────────────
haTicker = ticker.heikinashi(syminfo.tickerid)
src = useHeikin ? request.security(haTicker, timeframe.period, close, lookahead=barmerge.lookahead_off) : close

[plusDI, minusDI, adxValue] = ta.dmi(14, 14)
isTrending = not useAdxFilter or adxValue > adxThreshold

xATR = ta.atr(atrPeriod)
nLoss = sensitivity * xATR

var float xATRTrailingStop = na
prevStop = nz(xATRTrailingStop[1], src)

if src > prevStop and src[1] > prevStop
    xATRTrailingStop := math.max(prevStop, src - nLoss)
else if src < prevStop and src[1] < prevStop
    xATRTrailingStop := math.min(prevStop, src + nLoss)
else if src > prevStop
    xATRTrailingStop := src - nLoss
else
    xATRTrailingStop := src + nLoss

trendEma = ta.ema(close, trendEmaLen)
ema50 = ta.ema(close, ema50Len)

// ─────────────────────────────────────────────
// LÓGICA DE SEÑALES
// ─────────────────────────────────────────────
emaFast = ta.ema(src, 1)

crossUp = ta.crossover(emaFast, xATRTrailingStop)
crossDown = ta.crossover(xATRTrailingStop, emaFast)

isConfirmed = not confirmClose or barstate.isconfirmed

bullEma50Reject = useEma50Module and close > ema50 and low <= ema50 and close > open
bearEma50Reject = useEma50Module and close < ema50 and high >= ema50 and close < open

ema50BullAllowed = not useEma50AsFilter or not useEma50Module ? true : strictEma50Reject ? bullEma50Reject : close > ema50
ema50BearAllowed = not useEma50AsFilter or not useEma50Module ? true : strictEma50Reject ? bearEma50Reject : close < ema50

buySignal = src > xATRTrailingStop and crossUp and (not useTrendFilter or close > trendEma) and isTrending and ema50BullAllowed and isConfirmed
sellSignal = src < xATRTrailingStop and crossDown and (not useTrendFilter or close < trendEma) and isTrending and ema50BearAllowed and isConfirmed

// ─────────────────────────────────────────────
// VISUALIZACIÓN DINÁMICA DE RIESGO & RE-ESTADO
// ─────────────────────────────────────────────
var line l_entry = na
var line l_sl = na
var line l_tp1 = na
var line l_tp2 = na

var label lbl_entry = na
var label lbl_sl = na
var label lbl_tp1 = na
var label lbl_tp2 = na

var float currentEntry = na
var float currentSL = na
var float currentTP1 = na
var float currentTP2 = na
var int signalDir = 0
var int signalBar = na

if not showRisk
    currentEntry := na
    currentSL := na
    currentTP1 := na
    currentTP2 := na
    signalDir := 0
    signalBar := na

if (buySignal or sellSignal) and showRisk
    line.delete(l_entry)
    line.delete(l_sl)
    line.delete(l_tp1)
    line.delete(l_tp2)

    label.delete(lbl_entry)
    label.delete(lbl_sl)
    label.delete(lbl_tp1)
    label.delete(lbl_tp2)

    currentEntry := close
    currentSL := xATRTrailingStop
    signalDir := buySignal ? 1 : -1
    signalBar := bar_index

    risk = math.abs(currentEntry - currentSL)

    if risk > 0
        currentTP1 := buySignal ? currentEntry + risk * rr_tp1 : currentEntry - risk * rr_tp1
        currentTP2 := buySignal ? currentEntry + risk * rr_tp2 : currentEntry - risk * rr_tp2

        l_entry := line.new(bar_index, currentEntry, bar_index + lineExtension, currentEntry, color=color.gray, width=1, style=line.style_dashed)
        l_sl := line.new(bar_index, currentSL, bar_index + lineExtension, currentSL, color=color.red, width=2)
        l_tp1 := line.new(bar_index, currentTP1, bar_index + lineExtension, currentTP1, color=color.green, width=2)
        l_tp2 := line.new(bar_index, currentTP2, bar_index + lineExtension, currentTP2, color=color.blue, width=2)

        lbl_entry := label.new(bar_index + lineExtension, currentEntry, "ENTRY: " + str.tostring(currentEntry, "#.##"), style=label.style_label_left, color=color.gray, textcolor=color.white, size=size.small)
        lbl_sl := label.new(bar_index + lineExtension, currentSL, "SL: ACTIVO", style=label.style_label_left, color=color.red, textcolor=color.white, size=size.small)
        lbl_tp1 := label.new(bar_index + lineExtension, currentTP1, "TP1: " + str.tostring(currentTP1, "#.##"), style=label.style_label_left, color=color.green, textcolor=color.white, size=size.small)
        lbl_tp2 := label.new(bar_index + lineExtension, currentTP2, "TP2: " + str.tostring(currentTP2, "#.##"), style=label.style_label_left, color=color.blue, textcolor=color.white, size=size.small)

// ─────────────────────────────────────────────
// RISK FREE / BREAKEVEN
// ─────────────────────────────────────────────
if useRiskFree and showRisk and not na(currentTP1) and not na(l_sl) and not na(lbl_sl) and bar_index > signalBar
    hitTP1 = (signalDir == 1 and high >= currentTP1) or (signalDir == -1 and low <= currentTP1)

    if hitTP1 and currentSL != currentEntry
        currentSL := currentEntry
        line.set_y1(l_sl, currentSL)
        line.set_y2(l_sl, currentSL)
        line.set_color(l_sl, color.orange)
        label.set_y(lbl_sl, currentSL)
        label.set_text(lbl_sl, "SL: BREAKEVEN")
        label.set_color(lbl_sl, color.orange)

// ─────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────
plotshape(buySignal, title="BUY", style=shape.labelup, location=location.belowbar, color=color.green, text="BUY", textcolor=color.white, size=size.small)
plotshape(sellSignal, title="SELL", style=shape.labeldown, location=location.abovebar, color=color.red, text="SELL", textcolor=color.white, size=size.small)

plotshape(showEma50Reject and bullEma50Reject, title="EMA50 Bull Reject", style=shape.triangleup, location=location.belowbar, color=color.lime, text="50R", textcolor=color.white, size=size.tiny)
plotshape(showEma50Reject and bearEma50Reject, title="EMA50 Bear Reject", style=shape.triangledown, location=location.abovebar, color=color.red, text="50R", textcolor=color.white, size=size.tiny)

plot(showAtrStop ? xATRTrailingStop : na, title="ATR Trail", color=src > xATRTrailingStop ? color.green : color.red, linewidth=2, style=plot.style_linebr)
plot(useTrendFilter ? trendEma : na, title="EMA 200", color=color.new(color.orange, 40), linewidth=2)
plot(showEma50 ? ema50 : na, title="EMA 50", color=color.new(color.blue, 30), linewidth=2)

// ─────────────────────────────────────────────
// ALERTAS
// ─────────────────────────────────────────────
alertcondition(buySignal, title="BUY V2.1.2", message="Compra Confirmada @ {{close}}")
alertcondition(sellSignal, title="SELL V2.1.2", message="Venta Confirmada @ {{close}}")
alertcondition(bullEma50Reject, title="EMA50 Bull Reject", message="EMA 50 Bullish Rejection @ {{close}}")
alertcondition(bearEma50Reject, title="EMA50 Bear Reject", message="EMA 50 Bearish Rejection @ {{close}}")
````
