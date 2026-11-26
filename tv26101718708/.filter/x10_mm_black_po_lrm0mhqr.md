# x10 mm black po

- url: https://www.tradingview.com/script/LRM0MhQr/
- type: indicator
- pine_id: PUB;800641d1eba2496181f753f4629f99f7
- version: 1.0

## Description

x10 mm black po by 221, Danimanipulation e Matte, based on mm model 4 black project

## Source Code

````pine
//@version=6
// =============================================================================
// Visual ADR - TradingView port
// Original: "VisualADR.ex4 / VisualADR.ex5" v3.00 by Fauzaan Gasim
//   (https://www.fauzaanu.com)
// Versione "visiva" dell'ADR: barra/progress bar laterale che mostra in tempo
// reale quanto del range ADR è stato consumato, con zone color-coded.
// =============================================================================
indicator("x10 mm black po", overlay=true, max_labels_count=500, max_boxes_count=500)

// ---- Inputs ----
adrPeriod  = input.int(14, "ADR period (giorni)", minval=2, maxval=200)
warnPct    = input.float(70, "Warning %", minval=10, maxval=200, step=5)
dangerPct  = input.float(100, "Danger %", minval=10, maxval=300, step=5)
showLines  = input.bool(true, "Mostra linee ADR sul chart")
showBar    = input.bool(true, "Mostra barra progress in alto a destra")
showLabel  = input.bool(true, "Mostra label numerica vicino al prezzo")
adrCol     = input.color(color.new(color.aqua, 30), "Color ADR lines")

// ---- Pip size ----
pipSize = syminfo.mintick * (syminfo.type == "forex" and (syminfo.basecurrency == "JPY" or syminfo.currency == "JPY") ? 100 : 10)

// ---- ADR ----
dHigh = request.security(syminfo.tickerid, "D", high,  lookahead=barmerge.lookahead_off)
dLow  = request.security(syminfo.tickerid, "D", low,   lookahead=barmerge.lookahead_off)
dOpen = request.security(syminfo.tickerid, "D", open,  lookahead=barmerge.lookahead_off)
adr   = request.security(syminfo.tickerid, "D", ta.sma(high[1] - low[1], adrPeriod), lookahead=barmerge.lookahead_off)

adrUp = dOpen + adr / 2
adrDn = dOpen - adr / 2

plot(showLines ? adrUp : na, "ADR Up",   color=adrCol, style=plot.style_linebr, linewidth=2)
plot(showLines ? adrDn : na, "ADR Down", color=adrCol, style=plot.style_linebr, linewidth=2)

// ---- Range / completion ----
todayRange = dHigh - dLow
pctDone    = adr > 0 ? todayRange / adr * 100 : 0
pipsAdr    = adr / pipSize
pipsDone   = todayRange / pipSize
pipsLeft   = math.max(adr - todayRange, 0) / pipSize

zoneCol = pctDone >= dangerPct ? color.new(color.red, 20) :
          pctDone >= warnPct   ? color.new(color.orange, 20) :
                                  color.new(color.green, 20)

// ---- Progress bar (table) ----
// 10 celle, ognuna 10% del cammino verso "100% ADR"
filledCells = math.min(math.floor(pctDone / 10), 15)  // cap a 15 (150%)
var table bar = table.new(position=position.top_right, columns=12, rows=2, border_width=0)
if showBar and barstate.islast
    table.cell(bar, 0, 0, "ADR " + str.tostring(pipsAdr, "#.0") + "p", bgcolor=color.new(color.black, 0), text_color=color.white, text_size=size.small)
    table.cell(bar, 11, 0, str.tostring(pctDone, "#.0")+"%", bgcolor=zoneCol, text_color=color.white, text_size=size.small)
    // celle progress
    for i = 0 to 9
        col = i < filledCells ? (i < 7 ? color.new(color.green, 30) : i < 9 ? color.new(color.orange, 30) : color.new(color.red, 30)) : color.new(color.gray, 80)
        table.cell(bar, i + 1, 0, " ", bgcolor=col)
    table.cell(bar, 0, 1, "Done " + str.tostring(pipsDone, "#.0")+"p", bgcolor=color.new(color.black, 0), text_color=color.aqua, text_size=size.small)
    table.cell(bar, 11, 1, "Left " + str.tostring(pipsLeft, "#.0")+"p", bgcolor=color.new(color.black, 0), text_color=color.yellow, text_size=size.small)

// ---- Inline label ----
if showLabel and barstate.islast
    label.new(bar_index, close,
              str.tostring(pctDone, "#.0") + "% ADR",
              style=label.style_label_left, color=zoneCol, textcolor=color.white, size=size.small)

// ---- Alert ----
// alertcondition richiede 'const string' come message — niente concatenazioni con var. Usa placeholder {{plot_0}} se vuoi il valore dinamico.
alertcondition(ta.crossover(pctDone, warnPct),   "ADR warning crossed", "Price has consumed warning % of ADR (vedi indicatore)")
alertcondition(ta.crossover(pctDone, dangerPct), "ADR danger crossed",  "Price has consumed danger % of ADR (vedi indicatore)")
````
