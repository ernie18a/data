<!-- tradingview-pine-id: PUB;3675e69422a440f7ad02902347aa660b -->
<!-- tradingviewscripts-format: 1 -->
# TSF Risk Manager

Source: https://www.tradingview.com/script/k0PgoKxS/

## Description

TSF Risk Manager

═══════════════════════════════════════ ENGLISH ═══════════════════════════════════════

OVERVIEW A visual position-size and risk calculator. Mark your entry and stop-loss on the chart and it instantly computes the exact lot size for your chosen account risk, draws the full trade (entry, stop, take-profits) and shows the REAL risk in your account currency.

Important: TradingView / Pine cannot access your broker account or place orders. This is a calculator and visual planner — you enter your account size and risk %, and it does the math. It does not execute trades.

WHAT IT DOES

Click-to-place entry and stop-loss directly on the chart.
Calculates position size (lots) for your target risk %, rounded DOWN to your broker's lot step so you never exceed the intended risk.
Shows the REAL risk of the rounded lot (in money and %), so what you see is what you actually risk — not just the target.
Warns when your account size and stop distance don't allow the target risk (i.e., when the broker's minimum lot already risks more than your %).
Draws the trade: entry, stop and three take-profit levels at configurable R multiples, with a green reward zone and a red risk zone.
Detects direction (long / short) automatically from where the stop is placed.

HOW IT WORKS

Risk amount = account balance × risk %.
Lot size = risk amount ÷ (stop distance × value-per-1.00-move-per-lot), floored to the broker's lot step.
The "Value of 1.00 move per lot" must match your instrument. For XAUUSD (gold) it is 100 (1 standard lot = 100 oz, so a 1.00 price move = $100 per lot). Adjust it for other instruments / brokers.

HOW TO USE

Add the indicator; when prompted, click your entry and then your stop-loss on the chart.
In the settings, set your account size, risk %, and the value-per-point for your instrument (100 for gold).
Read the lot size and the real risk in the panel; the trade is drawn on the chart.
To plan another trade without deleting the current one, simply add the indicator again.

USER-INTERFACE TEXT (English translation) The panel and labels are written in Spanish. English meaning:

"TSF RISK" = panel title · "COMPRA" = Buy (long) · "VENTA" = Sell (short).
"Capital" = Account balance · "Riesgo objetivo" = Target risk · "Distancia SL" = Stop distance.
"LOTAJE" = Lot size · "Riesgo real" = Actual risk · "Estado" = Status.
"⚠ Mín 0.01 = X% del capital" = Warning: the broker's minimum lot risks X% of the account.
"✔ Riesgo bajo control" = Risk under control · "marcá entrada y stop" = mark entry and stop.
"TP1 / TP2 / TP3 (R)" = take-profit levels at R multiples · "Trading Sin Fronteras" = the author's brand.

This script is open-source. Feel free to study it, learn from it and adapt it.

═══════════════════════════════════════ ESPAÑOL ═══════════════════════════════════════

Calculadora visual de gestión de riesgo y tamaño de posición. Marcás tu entrada y tu stop en el gráfico y te calcula al instante el lotaje exacto para el riesgo que elegiste, dibuja la operación completa (entrada, stop, take-profits) y te muestra el riesgo REAL en el dinero de tu cuenta.

Importante: TradingView no accede a tu cuenta del broker ni ejecuta órdenes. Esto es una calculadora y planificador visual — vos cargás tu capital y tu % de riesgo, y hace el cálculo. No opera por vos.

QUÉ HACE

Marcás entrada y stop con un clic en el gráfico.
Calcula el lotaje para tu % de riesgo, redondeado HACIA ABAJO al mínimo de tu broker para que nunca te pases del riesgo objetivo.
Muestra el riesgo REAL del lote redondeado (en $ y en %), así lo que ves es lo que de verdad arriesgás.
Te avisa cuando tu capital y tu stop no permiten el riesgo objetivo (cuando el lote mínimo del broker ya arriesga más que tu %).
Dibuja la operación: entrada, stop y tres take-profits en múltiplos de R, con zona verde de beneficio y roja de riesgo.
Detecta la dirección (compra / venta) según dónde pongas el stop.

CÓMO USARLO Agregá el indicador y, cuando lo pida, hacé clic en tu entrada y luego en tu stop. En los ajustes cargá tu capital, tu % de riesgo y el "valor de 1.00 por lote" de tu instrumento (100 para el oro). Leé el lotaje y el riesgo real en el panel. Para planificar otra operación sin borrar la anterior, agregá el indicador de nuevo.

Script de código abierto — Trading Sin Fronteras.

---

## Source Code

````pine
//@version=6
// ================================================================
//  TSF RISK MANAGER  —  Trading Sin Fronteras © Rodrigo Pérez
//  v1.0 — Calculadora visual de gestión de riesgo (Pine v6)
//  Marcás entrada y stop → calcula LOTAJE, riesgo $, R:R y dibuja la operación.
//  Nota: TradingView no accede a tu cuenta ni ejecuta órdenes; esto es una
//  calculadora + visualizador. El lotaje se calcula con el valor por punto.
// ================================================================
indicator("TSF Risk Manager", shorttitle="TSF Risk", overlay=true, max_boxes_count=20, max_lines_count=20, max_labels_count=40)

// ============================ PALETA ============================
cTxt    = #E7EAF0
cDim    = #7B818C
cHead   = #08090D
cCellA  = #12141A
cCellB  = #191C24
cBorder = #2A2E37
cCel    = #00BFFF
cUp     = #00E19B
cDn     = #FF3B5C
cGold   = #E7B84B

// ============================ CUENTA ============================
gC = "▶ Cuenta y Riesgo"
capital = input.float(1000, "Capital de la cuenta ($)", minval=1, group=gC)
riskPct = input.float(1.0,  "Riesgo por operación (%)", minval=0.01, step=0.1, group=gC)
autoAsset = input.bool(true, "Detectar instrumento automáticamente", group=gC, tooltip="Calcula el valor por lote según el activo del gráfico (oro, plata, forex, cripto). Desactivalo solo si tu broker usa contratos no estándar.")
valPPman  = input.float(100, "Valor de 1.00 por lote (MANUAL)", minval=0.0001, group=gC, tooltip="Solo se usa si la detección automática está apagada. Referencia: XAUUSD=100, plata=5000, forex estándar=100000.")
lotDec  = input.int(2, "Decimales del lotaje", minval=0, maxval=3, group=gC)
lotStep = input.float(0.01, "Lote mínimo / step del broker", minval=0.0001, step=0.01, group=gC, tooltip="El menor incremento de lote que permite tu broker (normalmente 0.01). El lotaje se redondea HACIA ABAJO a este paso para que nunca te pases del riesgo objetivo.")

// ============================ OPERACIÓN ============================
gO = "▶ Operación (marcá en el gráfico)"
anchorMode = input.string("Vela marcada (simulación)", "Modo de la caja", options=["Vela marcada (simulación)","En espera (proyección)"], group=gO, tooltip="'Vela marcada': la caja arranca en la vela que clickeás (para simular una operación sobre el gráfico ya dibujado). 'En espera': la caja se proyecta desde la vela actual hacia adelante (para planear una entrada que todavía no se ejecutó).")
entryTime = input.time(0, "① Vela de entrada (solo modo 'Vela marcada')", confirm=true, group=gO)
entry     = input.price(0.0, "② Precio de entrada", confirm=true, group=gO)
sl        = input.price(0.0, "③ Stop Loss", confirm=true, group=gO)
rr1   = input.float(1.0, "TP1 (R)", minval=0.1, step=0.5, group=gO)
rr2   = input.float(2.0, "TP2 (R)", minval=0.1, step=0.5, group=gO)
rr3   = input.float(3.0, "TP3 (R)", minval=0.1, step=0.5, group=gO)

// ============================ VISUAL ============================
gV = "▶ Visual"
showTrade = input.bool(true, "Dibujar la operación", group=gV)
boxLen    = input.int(25, "Ancho de la caja (barras)", minval=5, group=gV)
showPanel = input.bool(true, "Panel de resultados", group=gV)
panelPos  = input.string("Arriba Derecha", "Posición panel", options=["Arriba Derecha","Arriba Izquierda","Abajo Derecha","Abajo Izquierda"], group=gV)

// ============================ CÁLCULOS ============================
// Barra de la vela de entrada (para anclar el dibujo donde el usuario marcó)
var int entryBar = na
if time <= entryTime
    entryBar := bar_index

valid   = entry > 0 and sl > 0 and entry != sl
dirLong = sl < entry
stopDist = math.abs(entry - sl)
riskAmt  = capital * riskPct / 100.0

// Valor de 1.00 de movimiento por lote según el instrumento (detección automática)
symU  = str.upper(syminfo.ticker)
fiats = "USD,EUR,JPY,GBP,CHF,AUD,CAD,NZD,SGD,"
isFx  = str.length(syminfo.basecurrency) >= 3 and str.contains(fiats, syminfo.basecurrency + ",") and str.contains(fiats, syminfo.currency + ",")
detVal = str.contains(symU, "XAU") ? 100.0 : str.contains(symU, "XAG") ? 5000.0 : isFx ? (syminfo.currency == "JPY" ? 100000.0 / close : 100000.0) : syminfo.type == "crypto" ? 1.0 : syminfo.pointvalue
valPP  = autoAsset ? detVal : valPPman

riskPerLot = stopDist * valPP
lotsExact  = valid and riskPerLot > 0 ? riskAmt / riskPerLot : na
lotsFloor  = na(lotsExact) ? na : math.floor(lotsExact / lotStep) * lotStep   // redondeo HACIA ABAJO al step
realRisk   = na(lotsFloor) ? na : lotsFloor * riskPerLot                       // riesgo real del lote redondeado
realRiskPct= na(realRisk) or capital <= 0 ? na : realRisk / capital * 100.0
minLotRisk = riskPerLot * lotStep
minLotPct  = capital > 0 ? minLotRisk / capital * 100.0 : na
belowMin   = valid and not na(lotsFloor) and lotsFloor < lotStep               // el exacto quedó por debajo del mínimo

tp1 = dirLong ? entry + stopDist*rr1 : entry - stopDist*rr1
tp2 = dirLong ? entry + stopDist*rr2 : entry - stopDist*rr2
tp3 = dirLong ? entry + stopDist*rr3 : entry - stopDist*rr3

dirTxt = dirLong ? "COMPRA" : "VENTA"
dirCol = dirLong ? cUp : cDn

// ============================ DIBUJO DE LA OPERACIÓN ============================
var box   bxProfit = na
var box   bxRisk   = na
var line  lnEntry  = na
var line  lnSL     = na
var line  lnTP1    = na
var line  lnTP2    = na
var line  lnTP3    = na
var label lbEntry  = na
var label lbSL     = na
var label lbTP1    = na
var label lbTP2    = na
var label lbTP3    = na

if barstate.islast
    box.delete(bxProfit)
    box.delete(bxRisk)
    line.delete(lnEntry)
    line.delete(lnSL)
    line.delete(lnTP1)
    line.delete(lnTP2)
    line.delete(lnTP3)
    label.delete(lbEntry)
    label.delete(lbSL)
    label.delete(lbTP1)
    label.delete(lbTP2)
    label.delete(lbTP3)
    if showTrade and valid
        useEntryBar = anchorMode == "Vela marcada (simulación)" and not na(entryBar)
        x1 = useEntryBar ? entryBar : bar_index
        x2 = useEntryBar ? math.max(entryBar + boxLen, bar_index + 5) : bar_index + boxLen
        bxProfit := box.new(x1, math.max(entry, tp3), x2, math.min(entry, tp3), border_color=color.new(cUp,55), bgcolor=color.new(cUp,90))
        bxRisk   := box.new(x1, math.max(entry, sl),  x2, math.min(entry, sl),  border_color=color.new(cDn,55), bgcolor=color.new(cDn,90))
        lnEntry := line.new(x1, entry, x2, entry, color=cGold, width=2)
        lnSL    := line.new(x1, sl,  x2, sl,  color=color.new(cDn,0), width=1, style=line.style_dashed)
        lnTP1   := line.new(x1, tp1, x2, tp1, color=color.new(cUp,20), style=line.style_dotted)
        lnTP2   := line.new(x1, tp2, x2, tp2, color=color.new(cUp,35), style=line.style_dotted)
        lnTP3   := line.new(x1, tp3, x2, tp3, color=color.new(cUp,50), style=line.style_dotted)
        lbEntry := label.new(x2, entry, dirTxt + " @ " + str.tostring(math.round_to_mintick(entry)), style=label.style_label_left, color=cHead, textcolor=cGold, size=size.small)
        lbSL    := label.new(x2, sl,  "SL  " + str.tostring(math.round_to_mintick(sl)),  style=label.style_none, textcolor=cDn, size=size.small)
        lbTP1   := label.new(x2, tp1, "TP1 " + str.tostring(math.round_to_mintick(tp1)), style=label.style_none, textcolor=cUp, size=size.small)
        lbTP2   := label.new(x2, tp2, "TP2 " + str.tostring(math.round_to_mintick(tp2)), style=label.style_none, textcolor=cUp, size=size.small)
        lbTP3   := label.new(x2, tp3, "TP3 " + str.tostring(math.round_to_mintick(tp3)), style=label.style_none, textcolor=cUp, size=size.small)

// ============================ PANEL DE RESULTADOS ============================
posTbl = panelPos=="Arriba Derecha" ? position.top_right : panelPos=="Arriba Izquierda" ? position.top_left : panelPos=="Abajo Derecha" ? position.bottom_right : position.bottom_left
var table t = table.new(posTbl, 2, 12, border_width=1, frame_color=cBorder, frame_width=1, bgcolor=cHead)

lotFmt   = lotDec==0 ? "0" : lotDec==1 ? "0.0" : lotDec==3 ? "0.000" : "0.00"
lotsTxt  = na(lotsFloor) ? "—" : str.tostring(lotsFloor, lotFmt)
pipSz    = syminfo.currency == "JPY" ? 0.01 : 0.0001
distTxt  = not valid ? "—" : isFx ? str.tostring(math.round((stopDist / pipSz) * 10) / 10) + " pips" : str.tostring(math.round_to_mintick(stopDist)) + " pts"
realTxt  = (belowMin or na(realRisk)) ? "—" : "$" + str.tostring(math.round(realRisk*100)/100) + "  (" + str.tostring(math.round(realRiskPct*10)/10) + "%)"
estadoTxt = not valid ? "— marcá entrada y stop —" : belowMin ? "⚠ Mín " + str.tostring(lotStep, lotFmt) + " = " + str.tostring(math.round(minLotPct*10)/10) + "% del capital" : "✔ Riesgo bajo control"
estadoCol = not valid ? cDim : belowMin ? cDn : cUp
lotCol    = belowMin ? cDn : cGold
tpVal(float rr) => (belowMin or na(realRisk)) ? "—" : "$" + str.tostring(math.round(realRisk*rr*100)/100)

if showPanel and barstate.islast
    table.cell(t, 0, 0, "◆ TSF RISK", text_color=cCel, text_size=size.large, text_halign=text.align_left, bgcolor=cHead)
    table.cell(t, 1, 0, valid ? dirTxt : "—", text_color=valid ? dirCol : cDim, text_size=size.normal, text_halign=text.align_right, bgcolor=cHead)
    table.cell(t, 0, 1, "Capital", text_color=cDim, text_size=size.small, text_halign=text.align_left, bgcolor=cCellA)
    table.cell(t, 1, 1, "$" + str.tostring(capital), text_color=cTxt, text_size=size.small, text_halign=text.align_right, bgcolor=cCellA)
    table.cell(t, 0, 2, "Riesgo objetivo", text_color=cDim, text_size=size.small, text_halign=text.align_left, bgcolor=cCellB)
    table.cell(t, 1, 2, str.tostring(riskPct) + "%  ($" + str.tostring(math.round(riskAmt*100)/100) + ")", text_color=cTxt, text_size=size.small, text_halign=text.align_right, bgcolor=cCellB)
    table.cell(t, 0, 3, "Distancia SL", text_color=cDim, text_size=size.small, text_halign=text.align_left, bgcolor=cCellA)
    table.cell(t, 1, 3, distTxt, text_color=cTxt, text_size=size.small, text_halign=text.align_right, bgcolor=cCellA)
    table.cell(t, 0, 4, "LOTAJE", text_color=lotCol, text_size=size.normal, text_halign=text.align_left, bgcolor=cCellB)
    table.cell(t, 1, 4, lotsTxt, text_color=lotCol, text_size=size.normal, text_halign=text.align_right, bgcolor=cCellB)
    table.cell(t, 0, 5, "Riesgo real", text_color=cDim, text_size=size.small, text_halign=text.align_left, bgcolor=cCellA)
    table.cell(t, 1, 5, realTxt, text_color=belowMin ? cDn : cCel, text_size=size.small, text_halign=text.align_right, bgcolor=cCellA)
    table.cell(t, 0, 6, "Estado", text_color=cDim, text_size=size.small, text_halign=text.align_left, bgcolor=cCellB)
    table.cell(t, 1, 6, estadoTxt, text_color=estadoCol, text_size=size.small, text_halign=text.align_right, bgcolor=cCellB)
    table.cell(t, 0, 7, "TP1 (" + str.tostring(rr1) + "R)", text_color=cDim, text_size=size.small, text_halign=text.align_left, bgcolor=cCellA)
    table.cell(t, 1, 7, tpVal(rr1), text_color=cUp, text_size=size.small, text_halign=text.align_right, bgcolor=cCellA)
    table.cell(t, 0, 8, "TP2 (" + str.tostring(rr2) + "R)", text_color=cDim, text_size=size.small, text_halign=text.align_left, bgcolor=cCellB)
    table.cell(t, 1, 8, tpVal(rr2), text_color=cUp, text_size=size.small, text_halign=text.align_right, bgcolor=cCellB)
    table.cell(t, 0, 9, "TP3 (" + str.tostring(rr3) + "R)", text_color=cDim, text_size=size.small, text_halign=text.align_left, bgcolor=cCellA)
    table.cell(t, 1, 9, tpVal(rr3), text_color=cUp, text_size=size.small, text_halign=text.align_right, bgcolor=cCellA)
    table.cell(t, 0, 10, "Activo (auto)", text_color=cDim, text_size=size.tiny, text_halign=text.align_left, bgcolor=cCellB)
    table.cell(t, 1, 10, syminfo.ticker + "  ·  $" + str.tostring(math.round(valPP)) + "/lote", text_color=cTxt, text_size=size.tiny, text_halign=text.align_right, bgcolor=cCellB)
    table.cell(t, 0, 11, "Trading Sin Fronteras", text_color=cCel, text_size=size.tiny, text_halign=text.align_left, bgcolor=cHead)
    table.cell(t, 1, 11, "TSF", text_color=cCel, text_size=size.tiny, text_halign=text.align_right, bgcolor=cHead)
````
