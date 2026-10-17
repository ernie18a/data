# EURUSD Position Size Calculator

- url: https://www.tradingview.com/script/eECYwnHc/
- type: indicator
- pine_id: PUB;a6653db13ab04d778c0666fc5ca6dd59
- version: 1.0

## Description

EURUSD Position Size Calculator. Calculates the Lot size that you have to use after putting your account size and the stoploss.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Position Size Calculator für EURUSD

//@version=6
indicator("EURUSD Position Size Calculator", overlay=true)

// ══════════════════════════════════════════════════════════════════════════════
// EINGABEN / INPUTS
// ══════════════════════════════════════════════════════════════════════════════

// Konto-Einstellungen
grp_account = "💰 Konto-Einstellungen"
accountBalance = input.float(10000, "Kontostand ($)", minval=100, step=100, group=grp_account)
riskPercent = input.float(1.0, "Risiko pro Trade (%)", minval=0.1, maxval=100, step=0.1, group=grp_account)
riskFixed = input.float(0, "ODER: Festes Risiko ($)", minval=0, step=10, group=grp_account, tooltip="Wenn > 0, wird dieser Wert statt % verwendet")

// Trade-Einstellungen
grp_trade = "📊 Trade-Einstellungen"
useCurrentPrice = input.bool(true, "Aktuellen Preis als Entry verwenden", group=grp_trade)
manualEntry = input.float(0, "Manueller Entry-Preis", minval=0, step=0.0001, group=grp_trade)
stopLossPrice = input.float(0, "Stop-Loss Preis", minval=0, step=0.0001, group=grp_trade)
stopLossPips = input.float(20, "ODER: Stop-Loss in Pips", minval=0.1, step=1, group=grp_trade, tooltip="Wird verwendet wenn SL-Preis = 0. 1 Pip = 0.0001")
tradeDirection = input.string("Long", "Trade-Richtung", options=["Long", "Short"], group=grp_trade)

// Broker-Einstellungen
grp_broker = "🏦 Broker-Einstellungen"
pipValue = input.float(10.0, "Wert pro Pip (1 Lot)", minval=0.1, step=0.5, group=grp_broker, tooltip="Standard: 10$ pro Pip bei 1 Lot EURUSD (100.000 Einheiten)")
minLotSize = input.float(0.01, "Minimale Lot-Größe", minval=0.001, step=0.01, group=grp_broker)
lotStep = input.float(0.01, "Lot-Schritt", minval=0.001, step=0.01, group=grp_broker)

// Anzeige-Einstellungen
grp_display = "🎨 Anzeige"
showTable = input.bool(true, "Tabelle anzeigen", group=grp_display)
tablePosition = input.string("top_right", "Tabellen-Position", options=["top_right", "top_left", "bottom_right", "bottom_left", "middle_right", "middle_left"], group=grp_display)
showLines = input.bool(true, "Entry/SL Linien anzeigen", group=grp_display)
textSize = input.string("normal", "Textgröße", options=["tiny", "small", "normal", "large"], group=grp_display)

// ══════════════════════════════════════════════════════════════════════════════
// BERECHNUNGEN
// ══════════════════════════════════════════════════════════════════════════════

// Entry-Preis bestimmen
entryPrice = useCurrentPrice ? close : manualEntry

// Pip-Größe für EURUSD (0.0001)
pipSize = 0.0001

// Stop-Loss Distanz berechnen (in Pips)
float slDistancePips = 0.0
float actualSLPrice = 0.0

if stopLossPrice > 0
    slDistancePips := math.abs(entryPrice - stopLossPrice) / pipSize
    actualSLPrice := stopLossPrice
else
    slDistancePips := stopLossPips
    if tradeDirection == "Long"
        actualSLPrice := entryPrice - (stopLossPips * pipSize)
    else
        actualSLPrice := entryPrice + (stopLossPips * pipSize)

// Risiko in Dollar berechnen
riskAmount = riskFixed > 0 ? riskFixed : (accountBalance * riskPercent / 100)

// Lot-Größe berechnen
// Formel: Lot = Risiko $ / (SL-Pips × Wert pro Pip pro Lot)
rawLotSize = slDistancePips > 0 ? riskAmount / (slDistancePips * pipValue) : 0

// Auf Lot-Schritte runden (abrunden für Sicherheit)
roundedLotSize = math.floor(rawLotSize / lotStep) * lotStep

// Mindest-Lot-Größe prüfen
finalLotSize = math.max(roundedLotSize, minLotSize)

// Tatsächliches Risiko mit gerundeter Lot-Größe
actualRisk = finalLotSize * slDistancePips * pipValue
actualRiskPercent = (actualRisk / accountBalance) * 100

// Potentieller Gewinn bei verschiedenen R:R
rr1 = actualRisk
rr2 = actualRisk * 2
rr3 = actualRisk * 3

// Take-Profit Preise
tp1Price = tradeDirection == "Long" ? entryPrice + (slDistancePips * pipSize) : entryPrice - (slDistancePips * pipSize)
tp2Price = tradeDirection == "Long" ? entryPrice + (slDistancePips * pipSize * 2) : entryPrice - (slDistancePips * pipSize * 2)
tp3Price = tradeDirection == "Long" ? entryPrice + (slDistancePips * pipSize * 3) : entryPrice - (slDistancePips * pipSize * 3)

// ══════════════════════════════════════════════════════════════════════════════
// TABELLE
// ══════════════════════════════════════════════════════════════════════════════

// Text-Größe bestimmen
getTextSize(s) =>
    switch s
        "tiny" => size.tiny
        "small" => size.small
        "normal" => size.normal
        "large" => size.large
        => size.normal

// Tabellen-Position bestimmen
getTablePos(p) =>
    switch p
        "top_right" => position.top_right
        "top_left" => position.top_left
        "bottom_right" => position.bottom_right
        "bottom_left" => position.bottom_left
        "middle_right" => position.middle_right
        "middle_left" => position.middle_left
        => position.top_right

if showTable
    var table infoTable = table.new(getTablePos(tablePosition), 2, 14, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.gray)
    
    tSize = getTextSize(textSize)
    headerColor = color.new(#1E90FF, 30)  // Blau für EUR
    
    // Header
    table.cell(infoTable, 0, 0, "📐 EURUSD POSITION CALCULATOR", text_color=color.white, text_size=tSize, bgcolor=headerColor)
    table.merge_cells(infoTable, 0, 0, 1, 0)
    
    // Konto-Info
    table.cell(infoTable, 0, 1, "Kontostand:", text_color=color.white, text_size=tSize, text_halign=text.align_left)
    table.cell(infoTable, 1, 1, str.tostring(accountBalance, "#,##0.00") + " $", text_color=color.green, text_size=tSize, text_halign=text.align_right)
    
    table.cell(infoTable, 0, 2, "Risiko-Einstellung:", text_color=color.white, text_size=tSize, text_halign=text.align_left)
    riskText = riskFixed > 0 ? str.tostring(riskFixed, "#,##0.00") + " $ (fest)" : str.tostring(riskPercent, "#0.00") + " %"
    table.cell(infoTable, 1, 2, riskText, text_color=color.orange, text_size=tSize, text_halign=text.align_right)
    
    // Trennlinie
    table.cell(infoTable, 0, 3, "─────────────────", text_color=color.gray, text_size=tSize)
    table.merge_cells(infoTable, 0, 3, 1, 3)
    
    // Trade-Info
    dirColor = tradeDirection == "Long" ? color.green : color.red
    table.cell(infoTable, 0, 4, "Richtung:", text_color=color.white, text_size=tSize, text_halign=text.align_left)
    table.cell(infoTable, 1, 4, tradeDirection, text_color=dirColor, text_size=tSize, text_halign=text.align_right)
    
    table.cell(infoTable, 0, 5, "Entry-Preis:", text_color=color.white, text_size=tSize, text_halign=text.align_left)
    table.cell(infoTable, 1, 5, str.tostring(entryPrice, "#.#####"), text_color=color.white, text_size=tSize, text_halign=text.align_right)
    
    table.cell(infoTable, 0, 6, "Stop-Loss:", text_color=color.white, text_size=tSize, text_halign=text.align_left)
    table.cell(infoTable, 1, 6, str.tostring(actualSLPrice, "#.#####") + " (" + str.tostring(slDistancePips, "#0.0") + " Pips)", text_color=color.red, text_size=tSize, text_halign=text.align_right)
    
    // Trennlinie
    table.cell(infoTable, 0, 7, "─────────────────", text_color=color.gray, text_size=tSize)
    table.merge_cells(infoTable, 0, 7, 1, 7)
    
    // ERGEBNIS
    table.cell(infoTable, 0, 8, "🎯 LOT-GRÖßE:", text_color=#1E90FF, text_size=tSize, text_halign=text.align_left, bgcolor=color.new(#1E90FF, 80))
    table.cell(infoTable, 1, 8, str.tostring(finalLotSize, "#0.00"), text_color=#1E90FF, text_size=tSize, text_halign=text.align_right, bgcolor=color.new(#1E90FF, 80))
    
    table.cell(infoTable, 0, 9, "Tatsächliches Risiko:", text_color=color.white, text_size=tSize, text_halign=text.align_left)
    table.cell(infoTable, 1, 9, str.tostring(actualRisk, "#,##0.00") + " $ (" + str.tostring(actualRiskPercent, "#0.00") + "%)", text_color=color.orange, text_size=tSize, text_halign=text.align_right)
    
    // Trennlinie
    table.cell(infoTable, 0, 10, "─────────────────", text_color=color.gray, text_size=tSize)
    table.merge_cells(infoTable, 0, 10, 1, 10)
    
    // Take-Profit Ziele
    table.cell(infoTable, 0, 11, "TP1 (1:1):", text_color=color.white, text_size=tSize, text_halign=text.align_left)
    table.cell(infoTable, 1, 11, str.tostring(tp1Price, "#.#####") + " (+" + str.tostring(rr1, "#0.00") + "$)", text_color=color.green, text_size=tSize, text_halign=text.align_right)
    
    table.cell(infoTable, 0, 12, "TP2 (1:2):", text_color=color.white, text_size=tSize, text_halign=text.align_left)
    table.cell(infoTable, 1, 12, str.tostring(tp2Price, "#.#####") + " (+" + str.tostring(rr2, "#0.00") + "$)", text_color=color.green, text_size=tSize, text_halign=text.align_right)
    
    table.cell(infoTable, 0, 13, "TP3 (1:3):", text_color=color.white, text_size=tSize, text_halign=text.align_left)
    table.cell(infoTable, 1, 13, str.tostring(tp3Price, "#.#####") + " (+" + str.tostring(rr3, "#0.00") + "$)", text_color=color.green, text_size=tSize, text_halign=text.align_right)

// ══════════════════════════════════════════════════════════════════════════════
// LINIEN
// ══════════════════════════════════════════════════════════════════════════════

if showLines
    // Entry-Linie
    entryLine = line.new(bar_index - 20, entryPrice, bar_index + 10, entryPrice, color=color.blue, width=2, style=line.style_solid)
    line.delete(entryLine[1])
    
    // Stop-Loss-Linie
    slLine = line.new(bar_index - 20, actualSLPrice, bar_index + 10, actualSLPrice, color=color.red, width=2, style=line.style_dashed)
    line.delete(slLine[1])
    
    // TP1-Linie
    tp1Line = line.new(bar_index - 20, tp1Price, bar_index + 10, tp1Price, color=color.green, width=1, style=line.style_dotted)
    line.delete(tp1Line[1])
    
    // TP2-Linie
    tp2Line = line.new(bar_index - 20, tp2Price, bar_index + 10, tp2Price, color=color.green, width=1, style=line.style_dotted)
    line.delete(tp2Line[1])
    
    // Labels
    if barstate.islast
        label.new(bar_index + 12, entryPrice, "Entry: " + str.tostring(entryPrice, "#.#####"), color=color.blue, textcolor=color.white, style=label.style_label_left, size=size.small)
        label.new(bar_index + 12, actualSLPrice, "SL: " + str.tostring(actualSLPrice, "#.#####"), color=color.red, textcolor=color.white, style=label.style_label_left, size=size.small)
        label.new(bar_index + 12, tp1Price, "TP1", color=color.green, textcolor=color.white, style=label.style_label_left, size=size.tiny)
        label.new(bar_index + 12, tp2Price, "TP2", color=color.green, textcolor=color.white, style=label.style_label_left, size=size.tiny)

// ══════════════════════════════════════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════════════════════════════════════

// Alert wenn Preis Entry erreicht
alertcondition(ta.cross(close, entryPrice), "Entry erreicht", "EURUSD: Entry-Preis erreicht!")
alertcondition(ta.cross(close, actualSLPrice), "Stop-Loss erreicht", "EURUSD: Stop-Loss erreicht!")
alertcondition(ta.cross(close, tp1Price), "TP1 erreicht", "EURUSD: Take-Profit 1 erreicht!")
alertcondition(ta.cross(close, tp2Price), "TP2 erreicht", "EURUSD: Take-Profit 2 erreicht!")

// ══════════════════════════════════════════════════════════════════════════════
// PLOT (für bessere Sichtbarkeit im Chart)
// ══════════════════════════════════════════════════════════════════════════════

plot(showLines ? entryPrice : na, "Entry", color=color.blue, linewidth=1, style=plot.style_linebr)
plot(showLines ? actualSLPrice : na, "Stop-Loss", color=color.red, linewidth=1, style=plot.style_linebr)
plot(showLines ? tp1Price : na, "TP1", color=color.green, linewidth=1, style=plot.style_linebr)
plot(showLines ? tp2Price : na, "TP2", color=color.teal, linewidth=1, style=plot.style_linebr)
````
