<!-- tradingview-pine-id: PUB;a5107c47702c4cb0bc0cf90c63e5117c -->
<!-- tradingviewscripts-format: 1 -->
# CRT + Cruce EMA 9/21 + Filtro Tendencia 50

Source: https://www.tradingview.com/script/ewQ725NZ/

## Description

CRT + Cruce EMA 9/21 + Filtro Tendencia 50 con el CRT como principal estrategia

---

## Source Code

````pine
//@version=6
indicator("CRT + Cruce EMA 9/21 + Filtro Tendencia 50", overlay=true, max_boxes_count=200, max_labels_count=200)

// ============================================================
// Sistema simplificado, señales más claras:
//  1) TENDENCIA: precio arriba de EMA50 = solo compras.
//     Precio abajo de EMA50 = solo ventas.
//  2) DISPARADOR: cruce de EMA9 sobre/bajo EMA21 (rápido y
//     frecuente, es de los cruces más usados en trading).
//  3) FILTRO DE CALIDAD (opcional): que haya habido un sweep
//     de liquidez reciente en M15, para no operar cualquier
//     cruce suelto sino uno cerca de una zona relevante.
// ============================================================

// ---------------- INPUTS ----------------
grpEma = "Cruce de EMAs"
emaFastLen = input.int(9,  "EMA rápida", minval=1, group=grpEma)
emaSlowLen = input.int(21, "EMA lenta",  minval=1, group=grpEma)
emaTrendLen = input.int(50, "EMA de tendencia (filtro)", minval=1, group=grpEma)
useTrendFilter = input.bool(true, "Solo operar a favor de la tendencia (EMA50)", group=grpEma)

grpSweep = "Filtro de Sweep en M15 (opcional)"
useSweepFilter = input.bool(true, "Exigir sweep de liquidez reciente", group=grpSweep)
sweepTF       = input.timeframe("15", "Temporalidad del sweep", group=grpSweep)
swingLookback = input.int(20, "Velas M15 hacia atrás para el máximo/mínimo de referencia", minval=3, group=grpSweep)
sweepWindow   = input.int(10, "Ventana: velas tras el sweep para validar el cruce", minval=1, maxval=50, group=grpSweep)

grpVis = "Visual"
colBuy    = input.color(color.new(color.green, 0), "Color TP (ganancia)", group=grpVis)
colSell   = input.color(color.new(#FF8A8A, 0), "Color SL (pérdida, rojo claro)", group=grpVis)
boxWidth  = input.int(15, "Ancho de la cajita (velas hacia la derecha)", minval=3, group=grpVis)
showEmas  = input.bool(true, "Mostrar las 3 EMAs en el gráfico", group=grpVis)

grpRisk = "Gestión de Riesgo (cajita Long/Short)"
atrLen     = input.int(14, "Periodo ATR", minval=1, group=grpRisk)
atrMult    = input.float(1.5, "Multiplicador ATR para el Stop Loss", minval=0.1, step=0.1, group=grpRisk)
rrRatio    = input.float(2.0, "Relación Riesgo:Beneficio (TP)", minval=0.5, step=0.5, group=grpRisk)

// ---------------- EMAs ----------------
emaFast  = ta.ema(close, emaFastLen)
emaSlow  = ta.ema(close, emaSlowLen)
emaTrend = ta.ema(close, emaTrendLen)

plot(showEmas ? emaFast  : na, title="EMA Rápida",    color=color.new(color.aqua, 0),   linewidth=1)
plot(showEmas ? emaSlow  : na, title="EMA Lenta",     color=color.new(color.orange, 0), linewidth=1)
plot(showEmas ? emaTrend : na, title="EMA Tendencia", color=color.new(color.yellow, 30), linewidth=2)

trendUp   = close > emaTrend
trendDown = close < emaTrend

crossUp   = ta.crossover(emaFast, emaSlow)
crossDown = ta.crossunder(emaFast, emaSlow)

// ---------------- SWEEP EN M15 (filtro opcional) ----------------
f_refHigh() =>
    ta.highest(high[1], swingLookback)
f_refLow() =>
    ta.lowest(low[1], swingLookback)

refHigh = request.security(syminfo.tickerid, sweepTF, f_refHigh(), lookahead=barmerge.lookahead_off)
refLow  = request.security(syminfo.tickerid, sweepTF, f_refLow(),  lookahead=barmerge.lookahead_off)

sweepLow  = low  < refLow  and close > refLow
sweepHigh = high > refHigh and close < refHigh

barsSinceSweepLow  = ta.barssince(sweepLow)
barsSinceSweepHigh = ta.barssince(sweepHigh)

sweepLowOk  = not useSweepFilter or (not na(barsSinceSweepLow)  and barsSinceSweepLow  <= sweepWindow)
sweepHighOk = not useSweepFilter or (not na(barsSinceSweepHigh) and barsSinceSweepHigh <= sweepWindow)

// ---------------- SEÑAL FINAL ----------------
buySignal  = crossUp   and (not useTrendFilter or trendUp)   and sweepLowOk
sellSignal = crossDown and (not useTrendFilter or trendDown) and sweepHighOk

// ---------------- ATR / STOP LOSS / TAKE PROFIT ----------------
atrVal = ta.atr(atrLen)

entryPrice  = close
slBuy       = entryPrice - atrVal * atrMult
riskBuy     = entryPrice - slBuy
tpBuy       = entryPrice + riskBuy * rrRatio

slSell      = entryPrice + atrVal * atrMult
riskSell    = slSell - entryPrice
tpSell      = entryPrice - riskSell * rrRatio

// ---------------- CAJITA COMPRA ----------------
if buySignal
    box.new(left=bar_index, top=tpBuy, bottom=entryPrice,
         right=bar_index + boxWidth, border_color=colBuy,
         bgcolor=color.new(colBuy, 85), text="TP " + str.tostring(math.round(tpBuy, 2)),
         text_color=colBuy, text_size=size.small)
    box.new(left=bar_index, top=entryPrice, bottom=slBuy,
         right=bar_index + boxWidth, border_color=color.new(colSell, 30),
         bgcolor=color.new(colSell, 85), text="SL " + str.tostring(math.round(slBuy, 2)),
         text_color=colSell, text_size=size.small)
    label.new(bar_index, entryPrice, "COMPRA\nEntrada " + str.tostring(math.round(entryPrice, 2)),
         style=label.style_label_right, color=colBuy, textcolor=color.white, size=size.small)
    msgBuy = "🟢 COMPRA " + syminfo.ticker + " (" + timeframe.period + ")\n" +
             "Entrada: " + str.tostring(entryPrice, format.mintick) + "\n" +
             "SL: " + str.tostring(slBuy, format.mintick) + "\n" +
             "TP: " + str.tostring(tpBuy, format.mintick) + "\n" +
             "R:R 1:" + str.tostring(rrRatio)
    alert(msgBuy, alert.freq_once_per_bar)

// ---------------- CAJITA VENTA ----------------
if sellSignal
    box.new(left=bar_index, top=entryPrice, bottom=tpSell,
         right=bar_index + boxWidth, border_color=colBuy,
         bgcolor=color.new(colBuy, 85), text="TP " + str.tostring(math.round(tpSell, 2)),
         text_color=colBuy, text_size=size.small)
    box.new(left=bar_index, top=slSell, bottom=entryPrice,
         right=bar_index + boxWidth, border_color=color.new(colSell, 30),
         bgcolor=color.new(colSell, 85), text="SL " + str.tostring(math.round(slSell, 2)),
         text_color=colSell, text_size=size.small)
    label.new(bar_index, entryPrice, "VENTA\nEntrada " + str.tostring(math.round(entryPrice, 2)),
         style=label.style_label_right, color=color.new(color.red, 0), textcolor=color.white, size=size.small)
    msgSell = "🔴 VENTA " + syminfo.ticker + " (" + timeframe.period + ")\n" +
              "Entrada: " + str.tostring(entryPrice, format.mintick) + "\n" +
              "SL: " + str.tostring(slSell, format.mintick) + "\n" +
              "TP: " + str.tostring(tpSell, format.mintick) + "\n" +
              "R:R 1:" + str.tostring(rrRatio)
    alert(msgSell, alert.freq_once_per_bar)

// ---------------- FLECHAS DE ENTRADA ----------------
plotshape(buySignal, title="Entrada Compra", style=shape.triangleup,
     location=location.belowbar, color=colBuy, size=size.small)
plotshape(sellSignal, title="Entrada Venta", style=shape.triangledown,
     location=location.abovebar, color=color.new(color.red,0), size=size.small)

// ---------------- ALERTAS (para el desplegable de nombre fijo) ----------------
alertcondition(buySignal,  title="Señal de Compra", message="Cruce EMA9/21 a favor de tendencia + sweep M15: señal de COMPRA")
alertcondition(sellSignal, title="Señal de Venta",  message="Cruce EMA9/21 a favor de tendencia + sweep M15: señal de VENTA")
````
