# x8 mm black po

- url: https://www.tradingview.com/script/J3VsTigJ/
- type: indicator
- pine_id: PUB;a59889e3830f412c80a38b33cc3d96bd
- version: 1.0

## Description

x8 mm black po by 221, Danimanipulation e Matte, based on mm model 4 black project

## Source Code

````pine
//@version=6
// =============================================================================
// SM ADR Marker - TradingView port
// Original: "!SM_ADR Marker.ex4" (Steve Mauro ADR Marker)
// Calcola l'Average Daily Range su N giorni e disegna High/Low giornaliero +
// proiezione ADR Up/Down dall'open del giorno corrente. Etichetta valori in pip.
// =============================================================================
indicator("x8 mm black po", overlay=true, max_lines_count=500, max_labels_count=500)

// ---- Inputs ----
adrPeriod   = input.int(5, "ADR period (giorni)", minval=1, maxval=30)
useMedian   = input.bool(false, "Usa mediana invece di media")
showHL      = input.bool(true,  "Mostra High/Low del giorno")
showProj    = input.bool(true,  "Mostra proiezione ADR Up/Down")
showLabels  = input.bool(true,  "Mostra labels in pip")
colUp       = input.color(color.new(color.green, 30), "Color Up")
colDn       = input.color(color.new(color.red, 30),   "Color Down")
colHL       = input.color(color.new(color.yellow, 0), "Color H/L")

// ---- Pip size ----
pipSize = syminfo.mintick * (syminfo.type == "forex" and (syminfo.basecurrency == "JPY" or syminfo.currency == "JPY") ? 100 : 10)

// ---- Daily H/L/Open via request.security ----
dHigh  = request.security(syminfo.tickerid, "D", high,  lookahead=barmerge.lookahead_off)
dLow   = request.security(syminfo.tickerid, "D", low,   lookahead=barmerge.lookahead_off)
dOpen  = request.security(syminfo.tickerid, "D", open,  lookahead=barmerge.lookahead_off)

// ---- ADR calc (su barre daily storiche, escluso oggi) ----
adrMedian = request.security(syminfo.tickerid, "D", ta.percentile_nearest_rank(high[1] - low[1], adrPeriod, 50), lookahead=barmerge.lookahead_off)
adrMean   = request.security(syminfo.tickerid, "D", ta.sma(high[1] - low[1], adrPeriod), lookahead=barmerge.lookahead_off)
adr = useMedian ? adrMedian : adrMean

// ---- Proiezione ----
adrUp = dOpen + adr / 2
adrDn = dOpen - adr / 2

// ---- Plots ----
plot(showHL    ? dHigh : na, "Day High", color=colHL, style=plot.style_linebr, linewidth=1)
plot(showHL    ? dLow  : na, "Day Low",  color=colHL, style=plot.style_linebr, linewidth=1)
plot(showProj  ? adrUp : na, "ADR Up",   color=colUp, style=plot.style_linebr, linewidth=2)
plot(showProj  ? adrDn : na, "ADR Down", color=colDn, style=plot.style_linebr, linewidth=2)
plot(showProj  ? dOpen : na, "Day Open", color=color.new(color.gray, 0), style=plot.style_linebr, linewidth=1)

// ---- Labels su nuova candela giornaliera ----
isNewDay = ta.change(time("D")) != 0
if showLabels and barstate.islast
    pipsAdr  = adr / pipSize
    pipsDone = (high - low) / pipSize
    label.new(bar_index, adrUp,
              "ADR " + str.tostring(pipsAdr, "#.0") + "p\nDone " + str.tostring(pipsDone, "#.0") + "p",
              style=label.style_label_left, color=color.new(color.black, 30), textcolor=color.white, size=size.small)
````
