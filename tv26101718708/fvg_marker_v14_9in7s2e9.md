# FVG Marker v1.4

- url: https://www.tradingview.com/script/9In7s2E9/
- type: indicator
- pine_id: PUB;a79a9db45fc04029af28cfe6a59bde70
- version: 1.0

## Description

Erkennt bullische und bearische Fair Value Gaps ( FVG ) auf Basis von 3-Kerzen-Mustern. Zeigt Retest-Punkte als farbige Kreise, FVG-Zonen als Boxen sowie Entry, SL umd TP als Linien. Berechnet Chance-Risiko-Verhaeltnis automatisch.

## Source Code

````pine
//@version=6
// ================================================================
// FVG MARKER v1.4 — Erkennung, Markierung & Ziel-Projektion fuer
// Fair Value Gaps (klassische 3-Kerzen-Definition).
// NEU in v1.4: Wenn der Kurs eine offene FVG-Zone erneut anlaeuft
// und im Trend abprallt (Retest/Abholung), zeichnet das Skript
// automatisch Entry-/Stop-Loss-/Ziel-Linien + Info-Label mit
// Reichweite (Punkte + Prozent) und Chance/Risiko-Verhaeltnis.
// Ziel = naechste offene Gegen-Zone (FVG-Magnet); Fallback =
// ATR-Vielfaches, wenn keine Zone in sinnvoller Reichweite liegt.
// Reiner Indikator — keine echten Trades, keine Strategie-Ausfuehrung,
// keine personalisierte Anlageberatung (zeigt nur, wie der Algorithmus
// rechnen wuerde).
// ================================================================
indicator('FVG Marker v1.4', overlay = true, max_boxes_count = 300, max_labels_count = 300, max_lines_count = 50)

// ── PARAMETER ───────────────────────────────────────────────────
grp = 'FVG Erkennung'
atrLen = input.int(14, 'ATR Periode (fuer Mindestgroesse)', group = grp)
minGapATR = input.float(0.0, 'Mindestgroesse der Luecke (x ATR)', group = grp, minval = 0.0, step = 0.05, tooltip = '0 = jede Luecke wird erkannt, auch sehr kleine. Hoeherer Wert = nur deutliche Luecken.')
showBull = input.bool(true, 'Bullische FVGs markieren (Long-Luecken)', group = grp)
showBear = input.bool(true, 'Bearische FVGs markieren (Short-Luecken)', group = grp)

grpZ = 'Zonen-Anzeige'
showZone = input.bool(true, 'Luecken-Zone als Box einzeichnen', group = grpZ)
zoneBars = input.int(40, 'Zone sichtbar fuer X Kerzen', group = grpZ, minval = 5)
fillFilled = input.bool(true, 'Geschlossene Zonen ausblenden', group = grpZ, tooltip = 'Wenn der Kurs die Luecke wieder vollstaendig durchgelaufen hat, wird die Zone entfernt.')

grpM = 'Markierung'
bullColor = input.color(color.new(color.aqua, 0), 'Farbe bullische Markierung', group = grpM)
bearColor = input.color(color.new(color.orange, 0), 'Farbe bearische Markierung', group = grpM)
// Hinweis: Kreis-Groesse ist fest (size.* muss "const string" sein -
// ein per input.string waehlbarer Wert wird von Pine als "input string"
// behandelt und von plotshape/label.new abgelehnt -> Compile-Fehler).

grpP = 'Ziel-Projektion (Trade-Reichweite)'
showProjection = input.bool(true, 'Ziel-Projektion bei FVG-Retest anzeigen', group = grpP, tooltip = 'Wenn der Kurs eine offene FVG-Zone erneut anlaeuft und im Trend wieder abprallt, zeichnet das Skript Entry/Stop/Ziel mit Reichweite und Chance-Risiko-Verhaeltnis.')
slATRmult = input.float(0.5, 'Stop-Loss Puffer (x ATR)', group = grpP, minval = 0.0, step = 0.1)
minRR = input.float(1.5, 'Mindest-Chance/Risiko fuer Zonen-Ziel', group = grpP, minval = 0.5, step = 0.1, tooltip = 'Liefert die naechste offene Gegen-Zone (FVG-Magnet) ein kleineres Verhaeltnis, nutzt das Skript stattdessen das ATR-Ziel.')
fallbackATRmult = input.float(2.0, 'Fallback-Ziel, wenn keine Zone passt (x ATR)', group = grpP, minval = 0.5, step = 0.5)

// ── KLASSISCHE 3-KERZEN-FVG-ERKENNUNG ───────────────────────────
a = ta.atr(atrLen)

// Bullisches FVG: Tief der aktuellen Kerze liegt ueber dem Hoch der Kerze von vor 2 Bars
bullGap = low - high[2]
bullFVG = showBull and bullGap > 0 and bullGap > minGapATR * a

// Bearisches FVG: Hoch der aktuellen Kerze liegt unter dem Tief der Kerze von vor 2 Bars
bearGap = low[2] - high
bearFVG = showBear and bearGap > 0 and bearGap > minGapATR * a

// ── HILFSFUNKTIONEN: naechste offene Gegen-Zone als Ziel-Magnet ─
nearestZoneAbove(arr, refPrice) =>
    float result = na
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1 by 1
            bx = array.get(arr, i)
            zb = box.get_bottom(bx)
            if zb > refPrice and (na(result) or zb < result)
                result := zb
                result
    result

nearestZoneBelow(arr, refPrice) =>
    float result = na
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1 by 1
            bx = array.get(arr, i)
            zt = box.get_top(bx)
            if zt < refPrice and (na(result) or zt > result)
                result := zt
                result
    result

// ── MARKIERUNG DIREKT AN DER KERZE ──────────────────────────────
// plotshape mit location.belowbar/abovebar haengt den Kreis IMMER
// exakt an die ausloesende Kerze (bleibt beim Zoomen/Scrollen an der
// Kerze kleben — anders als ein Label an fester Preis-Koordinate).
plotshape(bullFVG, title = 'Bullisches FVG (an Kerze)', style = shape.circle, location = location.belowbar, color = bullColor, size = size.tiny, offset = 0)

plotshape(bearFVG, title = 'Bearisches FVG (an Kerze)', style = shape.circle, location = location.abovebar, color = bearColor, size = size.tiny, offset = 0)

// Zusaetzlich: kleiner Ring direkt auf der Luecke selbst (zwischen
// Kerze 1 und Kerze 3), damit die Luecke optisch "eingekreist" wirkt —
// wird an die erste Luecken-Kerze (bar_index-2) gehaengt:
if bullFVG
    label.new(bar_index - 2, high[2], text = '○', style = label.style_none, textcolor = bullColor, size = size.small, xloc = xloc.bar_index)
if bearFVG
    label.new(bar_index - 2, low[2], text = '○', style = label.style_none, textcolor = bearColor, size = size.small, xloc = xloc.bar_index)

// ── ZONEN-BOXEN (optional) ──────────────────────────────────────
var array<box> bullBoxes = array.new_box()
var array<box> bearBoxes = array.new_box()

if showZone and bullFVG
    bx = box.new(bar_index - 2, low, bar_index + zoneBars, high[2], border_color = color.new(bullColor, 30), bgcolor = color.new(bullColor, 82), border_width = 1, text = 'FVG', text_color = bullColor, text_size = size.tiny, text_halign = text.align_center, text_valign = text.align_center)
    array.push(bullBoxes, bx)

if showZone and bearFVG
    bx = box.new(bar_index - 2, low[2], bar_index + zoneBars, high, border_color = color.new(bearColor, 30), bgcolor = color.new(bearColor, 82), border_width = 1, text = 'FVG', text_color = bearColor, text_size = size.tiny, text_halign = text.align_center, text_valign = text.align_center)
    array.push(bearBoxes, bx)

// Geschlossene Zonen entfernen, wenn der Kurs komplett durchgelaufen ist
if fillFilled
    if array.size(bullBoxes) > 0
        for i = array.size(bullBoxes) - 1 to 0 by 1
            bx = array.get(bullBoxes, i)
            top = box.get_top(bx)
            bot = box.get_bottom(bx)
            if close < bot
                box.delete(bx)
                array.remove(bullBoxes, i)
    if array.size(bearBoxes) > 0
        for i = array.size(bearBoxes) - 1 to 0 by 1
            bx = array.get(bearBoxes, i)
            top = box.get_top(bx)
            bot = box.get_bottom(bx)
            if close > top
                box.delete(bx)
                array.remove(bearBoxes, i)

// ── ZIEL-PROJEKTION: Retest/Abholung einer offenen Zone -> Setup ─
// Erkennung "Retest mit Abprall": der Kurs taucht mit dem Docht in
// eine offene Zone ein, schliesst die Kerze aber wieder im Trend
// (bullisch: close > Zonen-Unterkante UND close > open; umgekehrt
// fuer bearisch). Das ist die Stelle, an der laut Konzept ein Trade
// "starten kann". Es wird je Bar nur die naechstgelegene passende
// Zone gewertet (erste Treffer von "neuester zuerst").
var line entryLine = na
var line slLine = na
var line tpLine = na
var label projLabel = na
var string lastSetup = '—'

bullSig = false
bullSigTop = float(na)
bullSigBot = float(na)
if showProjection and array.size(bullBoxes) > 0
    for i = array.size(bullBoxes) - 1 to 0 by 1
        bx = array.get(bullBoxes, i)
        zt = box.get_top(bx)
        zb = box.get_bottom(bx)
        if not bullSig and low <= zt and close > zb and close > open
            bullSig := true
            bullSigTop := zt
            bullSigBot := zb
            bullSigBot

bearSig = false
bearSigTop = float(na)
bearSigBot = float(na)
if showProjection and array.size(bearBoxes) > 0
    for i = array.size(bearBoxes) - 1 to 0 by 1
        bx = array.get(bearBoxes, i)
        zt = box.get_top(bx)
        zb = box.get_bottom(bx)
        if not bearSig and high >= zb and close < zt and close < open
            bearSig := true
            bearSigTop := zt
            bearSigBot := zb
            bearSigBot

if bullSig or bearSig
    // alte Projektion entfernen, bevor die neue gezeichnet wird
    if not na(entryLine)
        line.delete(entryLine)
    if not na(slLine)
        line.delete(slLine)
    if not na(tpLine)
        line.delete(tpLine)
    if not na(projLabel)
        label.delete(projLabel)

    isLong = bullSig
    entry = close
    sl = isLong ? bullSigBot - slATRmult * a : bearSigTop + slATRmult * a
    risk = math.abs(entry - sl)

    // Ziel = naechste offene Gegen-Zone in Trade-Richtung (Magnet),
    // nur verwendet wenn das Chance/Risiko-Verhaeltnis mindestens
    // "minRR" erreicht — sonst ATR-Fallback-Ziel.
    zoneTP = isLong ? nearestZoneAbove(bearBoxes, entry) : nearestZoneBelow(bullBoxes, entry)
    zoneRR = na(zoneTP) ? na : math.abs(zoneTP - entry) / risk
    useZone = not na(zoneTP) and zoneRR >= minRR
    // Fallback-Distanz: groesser von (ATR-Vielfaches) und (Mindest-RR x Risiko) -
    // dadurch erreicht JEDES Setup mindestens "minRR", auch ohne passenden Zonen-Magnet.
    fallbackDist = math.max(fallbackATRmult * a, minRR * risk)
    tp = useZone ? zoneTP : isLong ? entry + fallbackDist : entry - fallbackDist
    finalRR = math.abs(tp - entry) / risk
    distPts = math.abs(tp - entry)
    distPct = distPts / entry * 100

    lineColor = isLong ? bullColor : bearColor
    zoneTxt = useZone ? 'Zonen-Ziel / FVG-Magnet' : 'ATR-Ziel (kein Magnet in Reichweite)'
    dirTxt = isLong ? 'LONG-Setup (Retest bullische FVG)' : 'SHORT-Setup (Retest bearische FVG)'
    lastSetup := isLong ? 'LONG (aktiv)' : 'SHORT (aktiv)'

    entryLine := line.new(bar_index, entry, bar_index + zoneBars, entry, color = color.new(color.white, 35), style = line.style_dotted, width = 1)
    slLine := line.new(bar_index, sl, bar_index + zoneBars, sl, color = color.new(color.red, 15), style = line.style_dashed, width = 1)
    tpLine := line.new(bar_index, tp, bar_index + zoneBars, tp, color = color.new(color.lime, 15), style = line.style_dashed, width = 1)

    lblTxt = dirTxt + '\nEntry: ' + str.tostring(entry, '#.##') + '\nSL: ' + str.tostring(sl, '#.##') + '  (Risiko ' + str.tostring(risk, '#.##') + ')' + '\nZiel (' + zoneTxt + '): ' + str.tostring(tp, '#.##') + '\nReichweite: ' + str.tostring(distPts, '#.##') + ' Punkte (' + str.tostring(distPct, '#.##') + ' %)' + '\nChance/Risiko = 1 : ' + str.tostring(finalRR, '#.##') + '\n(Algorithmus-Berechnung, keine Anlageberatung)'

    projLabel := label.new(bar_index, isLong ? sl : tp, text = lblTxt, style = isLong ? label.style_label_up : label.style_label_down, color = color.new(color.black, 10), textcolor = lineColor, size = size.small)
    projLabel

alertcondition(bullSig, title = 'LONG-Setup: Retest bullische FVG', message = 'Kurs testet offene bullische FVG-Zone und prallt im Trend ab — Ziel-Projektion aktualisiert')
alertcondition(bearSig, title = 'SHORT-Setup: Retest bearische FVG', message = 'Kurs testet offene bearische FVG-Zone und prallt im Trend ab — Ziel-Projektion aktualisiert')

// ── ZAEHLER / STATUS ────────────────────────────────────────────
var int bullCount = 0
var int bearCount = 0
if bullFVG
    bullCount := bullCount + 1
    bullCount
if bearFVG
    bearCount := bearCount + 1
    bearCount

var table info = table.new(position.top_right, 2, 4, bgcolor = color.new(color.black, 20), border_width = 1)
if barstate.islast
    table.cell(info, 0, 0, 'FVG Marker', text_color = color.white, bgcolor = color.new(color.blue, 30), text_size = size.small)
    table.cell(info, 1, 0, 'v1.4', text_color = color.white, bgcolor = color.new(color.blue, 30), text_size = size.small)
    table.cell(info, 0, 1, 'Bullische FVGs', text_color = color.white, text_size = size.small)
    table.cell(info, 1, 1, str.tostring(bullCount), text_color = bullColor, text_size = size.small)
    table.cell(info, 0, 2, 'Bearische FVGs', text_color = color.white, text_size = size.small)
    table.cell(info, 1, 2, str.tostring(bearCount), text_color = bearColor, text_size = size.small)
    table.cell(info, 0, 3, 'Letztes Setup', text_color = color.white, text_size = size.small)
    table.cell(info, 1, 3, lastSetup, text_color = color.white, text_size = size.small)

alertcondition(bullFVG, title = 'Bullisches FVG erkannt', message = 'Neue bullische Fair Value Gap erkannt')
alertcondition(bearFVG, title = 'Bearisches FVG erkannt', message = 'Neue bearische Fair Value Gap erkannt')
````
