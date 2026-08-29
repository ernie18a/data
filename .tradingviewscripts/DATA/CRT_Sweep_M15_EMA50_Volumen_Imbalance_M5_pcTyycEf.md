<!-- tradingview-pine-id: PUB;9078538cb50b44feac26cec428201a74 -->
<!-- tradingviewscripts-format: 1 -->
# CRT Sweep M15 + EMA50 + Volumen + Imbalance M5

Source: https://www.tradingview.com/script/pcTyycEf/

## Description

CRT Sweep M15 + EMA50 + Volumen + Imbalance M5 basado en la estragia crt

---

## Source Code

````pine
//@version=6
indicator("CRT Sweep M15 + EMA50 + Volumen + Imbalance M5", overlay=true, max_boxes_count=200, max_labels_count=200)

// ============================================================
// CRT (Candle Range Theory) - versión M15 + EMA50
// Lógica en 2 pasos:
//  PASO 1 - SETUP: se detecta un sweep de liquidez en M15
//     (mecha que perfora un máximo/mínimo reciente y cierra
//     de nuevo adentro) + volumen del lado contrario +
//     imbalance/FVG reciente en M5.
//  PASO 2 - ENTRADA: una vez que hay un "setup" válido, se
//     espera a que el precio CRUCE la EMA de 50 periodos en
//     la dirección del setup. Ahí recién se dibuja la cajita
//     de entrada con SL (ATR) y TP (R:R).
// ============================================================

// ---------------- INPUTS ----------------
grpSweep = "Sweep en M15"
sweepTF      = input.timeframe("15", "Temporalidad del sweep", group=grpSweep, tooltip="Por defecto M15. El script busca el sweep sobre velas de esta temporalidad.")
swingLookback = input.int(20, "Velas M15 hacia atrás para el máximo/mínimo de referencia", minval=3, group=grpSweep)

grpEma = "Entrada por EMA"
emaLen       = input.int(50, "Periodo EMA de entrada", minval=1, group=grpEma)
entryWindow  = input.int(10, "Ventana: velas M15 tras el setup para esperar el cruce de EMA", minval=1, maxval=50, group=grpEma)

grpVol = "Confirmación de Volumen"
ltfRes    = input.string("1", "Timeframe inferior para medir volumen", options=["1","5"], group=grpVol)
volLookback = input.int(20, "Periodo promedio de volumen/delta", minval=5, group=grpVol)
volMult   = input.float(1.3, "Fuerza mínima del delta (x veces la media)", minval=1.0, step=0.1, group=grpVol)

grpImb = "Imbalance M5"
imbWindow = input.int(6, "Ventana: velas M5 recientes para validar imbalance", minval=1, maxval=30, group=grpImb)

grpVis = "Visual"
colBuy    = input.color(color.new(color.green, 0), "Color TP (ganancia)", group=grpVis)
colSell   = input.color(color.new(#FF8A8A, 0), "Color SL (pérdida, rojo claro)", group=grpVis)
boxWidth  = input.int(15, "Ancho de la cajita (velas hacia la derecha)", minval=3, group=grpVis)
showEma   = input.bool(true, "Mostrar EMA en el gráfico", group=grpVis)

grpRisk = "Gestión de Riesgo (cajita Long/Short)"
atrLen     = input.int(14, "Periodo ATR", minval=1, group=grpRisk)
atrMult    = input.float(1.5, "Multiplicador ATR para el Stop Loss", minval=0.1, step=0.1, group=grpRisk)
rrRatio    = input.float(2.0, "Relación Riesgo:Beneficio (TP)", minval=0.5, step=0.5, group=grpRisk)

// ---------------- RANGO DE REFERENCIA EN M15 ----------------
f_refHigh() =>
    ta.highest(high[1], swingLookback)
f_refLow() =>
    ta.lowest(low[1], swingLookback)

refHigh = request.security(syminfo.tickerid, sweepTF, f_refHigh(), lookahead=barmerge.lookahead_off)
refLow  = request.security(syminfo.tickerid, sweepTF, f_refLow(),  lookahead=barmerge.lookahead_off)

// ---------------- SWEEP (SACADA DE LIQUIDEZ) EN M15 ----------------
sweepLow  = low  < refLow  and close > refLow
sweepHigh = high > refHigh and close < refHigh

// ---------------- VOLUMEN / DELTA ----------------
[upVol, downVol] = request.security_lower_tf(syminfo.tickerid, ltfRes,
     [ta.change(close) > 0 ? volume : 0.0,
      ta.change(close) < 0 ? volume : 0.0])

buyVol  = array.sum(upVol)
sellVol = array.sum(downVol)
delta   = buyVol - sellVol

avgDelta = ta.sma(math.abs(delta), volLookback)

volConfirmBuy  = delta > 0 and math.abs(delta) > avgDelta * volMult
volConfirmSell = delta < 0 and math.abs(delta) > avgDelta * volMult

// ---------------- IMBALANCE / FVG EN M5 ----------------
fvgUpM5   = request.security(syminfo.tickerid, "5", low  > high[2], lookahead=barmerge.lookahead_off)
fvgDownM5 = request.security(syminfo.tickerid, "5", high < low[2],  lookahead=barmerge.lookahead_off)

barsSinceFvgUp   = ta.barssince(fvgUpM5)
barsSinceFvgDown = ta.barssince(fvgDownM5)

imbalanceUpOk   = not na(barsSinceFvgUp)   and barsSinceFvgUp   <= imbWindow
imbalanceDownOk = not na(barsSinceFvgDown) and barsSinceFvgDown <= imbWindow

// ---------------- PASO 1: SETUP (sweep + volumen + imbalance) ----------------
setupBuy  = sweepLow  and volConfirmBuy  and imbalanceUpOk
setupSell = sweepHigh and volConfirmSell and imbalanceDownOk

barsSinceSetupBuy  = ta.barssince(setupBuy)
barsSinceSetupSell = ta.barssince(setupSell)

setupBuyActive  = not na(barsSinceSetupBuy)  and barsSinceSetupBuy  <= entryWindow
setupSellActive = not na(barsSinceSetupSell) and barsSinceSetupSell <= entryWindow

// ---------------- PASO 2: ENTRADA POR CRUCE DE EMA ----------------
emaVal = ta.ema(close, emaLen)
plot(showEma ? emaVal : na, title="EMA Entrada", color=color.new(color.yellow, 20), linewidth=2)

crossUp   = ta.crossover(close, emaVal)
crossDown = ta.crossunder(close, emaVal)

buySignal  = setupBuyActive  and crossUp
sellSignal = setupSellActive and crossDown

// ---------------- ATR / STOP LOSS / TAKE PROFIT ----------------
atrVal = ta.atr(atrLen)

entryPrice  = close
slBuy       = entryPrice - atrVal * atrMult
riskBuy     = entryPrice - slBuy
tpBuy       = entryPrice + riskBuy * rrRatio

slSell      = entryPrice + atrVal * atrMult
riskSell    = slSell - entryPrice
tpSell      = entryPrice - riskSell * rrRatio

// ---------------- CAJITA ESTILO "LONG POSITION" (compra) ----------------
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

// ---------------- CAJITA ESTILO "SHORT POSITION" (venta) ----------------
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

// Marca visual del setup (antes de la entrada), para ver que quedó "armado"
plotshape(setupBuy,  title="Setup Compra (sweep)", style=shape.circle, location=location.belowbar, color=color.new(colBuy, 40), size=size.tiny)
plotshape(setupSell, title="Setup Venta (sweep)",  style=shape.circle, location=location.abovebar, color=color.new(colSell, 40), size=size.tiny)

// Flechas de entrada real (cruce de EMA confirmado)
plotshape(buySignal, title="Entrada Compra", style=shape.triangleup,
     location=location.belowbar, color=colBuy, size=size.small)
plotshape(sellSignal, title="Entrada Venta", style=shape.triangledown,
     location=location.abovebar, color=colSell, size=size.small)

// ---------------- ALERTAS ----------------
alertcondition(setupBuy,  title="CRT Setup Compra", message="CRT: sweep de mínimo M15 + volumen + imbalance M5 (esperando cruce EMA)")
alertcondition(setupSell, title="CRT Setup Venta",  message="CRT: sweep de máximo M15 + volumen + imbalance M5 (esperando cruce EMA)")
alertcondition(buySignal,  title="CRT Entrada Compra", message="CRT: entrada de COMPRA confirmada por cruce de EMA")
alertcondition(sellSignal, title="CRT Entrada Venta",  message="CRT: entrada de VENTA confirmada por cruce de EMA")
````
