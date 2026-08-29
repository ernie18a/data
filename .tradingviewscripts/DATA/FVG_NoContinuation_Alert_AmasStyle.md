<!-- tradingview-pine-id: PUB;e983251bd8134b498172f6e8a1640927 -->
<!-- tradingviewscripts-format: 1 -->
# FVG No-Continuation Alert (Amas-Style)

Source: https://www.tradingview.com/script/GH4UnSWr/

## Description

FVG No-Continuation Alert (ICT-Style)

This indicator detects a 3-candle Fair Value Gap (FVG) setup combined with a specific rejection/no-continuation close on the third candle, and alerts you as soon as the pattern confirms — with an optional early-warning signal while the third candle is still forming.

Concept credit: The underlying strategy concept was shared by Amas (@AmasPFT on X and YouTube). This script is an independent implementation of that concept and is not affiliated with or endorsed by Amas.

How it works

Using three consecutive candles (A → oldest, B → impulse candle, C → most recent):

A Fair Value Gap forms when candle C's high/low doesn't overlap with candle A's low/high (the classic 3-candle FVG definition).
The setup is confirmed when candle C closes back on the "wrong" side of candle B's high/low — i.e. it fails to confirm continuation of the impulse move (whether or not it swept beyond B's extreme intrabar first).
The idea: price is expected to first revisit the FVG (internal liquidity) before candle B's high/low (external liquidity) gets taken.

Multi-timeframe by design: run it on your entry timeframe (e.g. M1) while it monitors a higher timeframe (e.g. M15) for the FVG pattern — set via the "FVG Timeframe" input. All confirmed signals use only closed higher-timeframe candles, so there's no repainting on the confirmed signal.

Features

Draws the FVG zone as a box, plus a dashed line marking candle B's high/low (the external liquidity target)
Confirmed alerts (bullish/bearish), fired the moment the higher-timeframe candle closes
Optional early-warning alert while the third candle is still forming — clearly labeled as preliminary/unconfirmed, since it can still change until the candle closes
Adjustable lookback window and object limits to keep the script fast on lower timeframes with long history

Notes

Use "Any alert() function call" when creating alerts in TradingView, so the built-in alert frequency logic (fires immediately on confirmation, not delayed to the entry-timeframe candle's close) is respected.
The early-warning signal is intentionally unconfirmed — treat it as a heads-up to watch the entry timeframe, not as a trade trigger on its own.
This is a tool for identifying a specific price-action pattern, not a complete trading system. Always combine with your own risk management and market context.

---

## Source Code

````pine
//@version=6
indicator("FVG No-Continuation Alert (Amas-Style)", overlay=true, max_boxes_count=100, max_lines_count=50, max_labels_count=100)

// =========================================================================
// FVG "kein Fortsetzungs-Close" Konzept:
// Kerze A (älteste) -> Kerze B (Impulskerze) -> Kerze C (jüngste, geschlossene Kerze)
// Bärisch: FVG = High(C) < Low(A). Kerze C bestätigt NICHT weiter nach unten,
//          sie schließt wieder ÜBER dem Low von B (egal ob sie es vorher gesweept
//          hat oder gar nicht erreicht hat).
//          -> Erwartung: Preis läuft zuerst in das FVG (interne Liquidität),
//          bevor das Low von B (externe Liquidität) angegriffen wird.
// Bullisch: spiegelbildlich, FVG = Low(C) > High(A). Kerze C schließt wieder
//          UNTER dem High von B.
//
// Alle BESTÄTIGTEN Signale basieren ausschließlich auf bereits GESCHLOSSENEN Kerzen
// des gewählten FVG-Timeframes (Offset [1]/[2]/[3]) -> kein Repainting.
// Die FRÜHWARNUNG + Vorschau-Box nutzen bewusst die noch laufende, unbestätigte
// Kerze 3 (Offset 0) -> kann sich bis zum Kerzenschluss noch ändern.
//
// NACH der Bestätigung wird pro Setup weiterverfolgt, ob das FVG zuerst gefüllt
// wird (Erfolg) oder das Level von Kerze B/C zuerst bricht (Invalidierung).
// Das Tracking nutzt bewusst die M15-Live-Daten (liveHighC/liveLowC), NICHT das
// native High/Low des aktuellen Charts - so verhält sich das Ergebnis auf M1
// und M15 identisch. Das Label wird entsprechend aktualisiert. Falls beides im
// selben Bar passiert, wird "gefüllt" priorisiert, da das Erreichen der
// internen Liquidität (FVG) als primäres Erfolgskriterium der Strategie gilt.
// =========================================================================

grp1 = "Higher-Timeframe FVG Detection"
htf         = input.timeframe("15", "FVG-Timeframe (z.B. 15 für 15M-FVG, Entry-Chart z.B. M1)", group = grp1)
showBullish = input.bool(true, "Bullische Setups anzeigen", group = grp1)
showBearish = input.bool(true, "Bärische Setups anzeigen", group = grp1)

grp2 = "Darstellung"
fvgUpColor   = input.color(color.new(color.teal, 70), "FVG-Box (bullisch)", group = grp2)
fvgDownColor = input.color(color.new(color.red, 70), "FVG-Box (bärisch)", group = grp2)
extendBars   = input.int(5, "Box/Linie nach rechts verlängern (Bars)", minval = 1, group = grp2)
showLabels   = input.bool(true, "Labels anzeigen (aus = nur Boxen/Linien)", group = grp2)
autoHideLabelsOnLTF = input.bool(true, "Labels automatisch ausblenden auf niedrigerem Timeframe als FVG-TF", group = grp2, tooltip = "Zeigt Labels nur, wenn der Chart-Timeframe >= FVG-Timeframe ist (z.B. an auf M15 bei 15M-FVG, aus auf M1). Box/Linie bleiben trotzdem sichtbar.")

grp3 = "Frühwarnung (Kerze 3 läuft noch, unbestätigt)"
showEarlyWarning = input.bool(true, "Frühwarnung + Live-Vorschau-Box aktivieren", group = grp3)

grp4 = "Performance"
lookbackBars = input.int(2000, "Nur die letzten X Chart-Bars berücksichtigen", minval = 20, maxval = 20000, group = grp4, tooltip = "Begrenzt, wie weit in die Historie zurück Setups berechnet und gezeichnet werden. Kleinerer Wert = schnellerer Indikator. Auf M1 braucht man tendenziell einen höheren Wert als auf M15, um denselben Zeitraum abzudecken.")

grp5 = "Anzeige-Limit"
limitSetups = input.bool(true, "Nur letzte Setups anzeigen", group = grp5)
maxSetups   = input.int(2, "Anzahl anzuzeigender Setups", minval = 1, maxval = 50, group = grp5, tooltip = "Zeigt nur die letzten X bestätigten Setups (Box/Linie/Label). Ältere werden automatisch entfernt. 2 = aktuelles + letztes abgelaufenes Setup.")

grp6 = "Rejection-Candle-Gewichtung"
showConfidence   = input.bool(true, "Starke Rejection-Kerzen markieren (★)", group = grp6, tooltip = "Markiert Setups, bei denen Kerze C optisch wie ein Shooting Star (bullisches Setup) bzw. Hammer (bärisches Setup) aussieht - langer Docht, kleiner Body.")
wickRatioThresh  = input.float(0.5, "Mindest-Docht-Anteil an der Kerzenrange", minval = 0.1, maxval = 0.9, step = 0.05, group = grp6)

// --- Timeframe-Validierung ---
if timeframe.in_seconds(htf) < timeframe.in_seconds(timeframe.period)
    runtime.error("FVG-Timeframe muss größer oder gleich dem Chart-Timeframe sein (z.B. 15M-FVG auf M1-Chart anzeigen, nicht umgekehrt).")

// Labels nur zeigen, wenn gewünscht UND (Auto-Ausblendung aus ODER Chart-TF >= FVG-TF)
effectiveShowLabels = showLabels and (not autoHideLabelsOnLTF or timeframe.in_seconds(timeframe.period) >= timeframe.in_seconds(htf))

// --- HTF Daten: EIN gebündelter Aufruf statt vieler Einzelaufrufe (Performance) ---
// Offset 1 = Kerze C (bestätigt), Offset 2 = Kerze B, Offset 3 = Kerze A
[htfTime, openC, highC, lowC, closeC, highB, lowB, highA, lowA, htfBarBStart] =
     request.security(syminfo.tickerid, htf,
     [time, open[1], high[1], low[1], close[1], high[2], low[2], high[3], low[3], time[2]],
     lookahead = barmerge.lookahead_off)

// --- Live-Daten der GERADE LAUFENDEN (noch nicht geschlossenen) Kerze 3 ---
// Ebenfalls ein gebündelter Aufruf. Offset 0 = laufende Kerze 3, Offset 1 = Kerze B, Offset 2 = Kerze A
[liveHtfTime, liveHighC, liveLowC, liveCloseC, liveHighB, liveLowB, liveHighA, liveLowA] =
     request.security(syminfo.tickerid, htf,
     [time, high, low, close, high[1], low[1], high[2], low[2]],
     lookahead = barmerge.lookahead_off)

// --- Neue HTF-Kerze erkennen, damit das Pattern nur 1x pro HTF-Bar ausgewertet wird ---
var float lastHtfTime = na
isNewHtfBar = na(lastHtfTime) or htfTime != lastHtfTime
lastHtfTime := htfTime

// --- Neue LAUFENDE HTF-Kerze erkennen, um Frühwarnung/Vorschau nur 1x pro Kerze 3 zu resetten ---
var float lastLiveHtfTime   = na
var bool  earlyWarnedBull   = false
var bool  earlyWarnedBear   = false
isNewLiveHtfBar = na(lastLiveHtfTime) or liveHtfTime != lastLiveHtfTime
if isNewLiveHtfBar
    earlyWarnedBull := false
    earlyWarnedBear := false
lastLiveHtfTime := liveHtfTime

// --- Historie begrenzen: außerhalb des Fensters wird weder gezeichnet noch gealertet ---
onlyRecent = bar_index >= last_bar_index - lookbackBars

// --- FVG + "kein Fortsetzungs-Close" Bedingungen (bestätigt) ---
bullFVG    = lowC > highA
bullNoConf = closeC < highB
bullSignal = isNewHtfBar and bullFVG and bullNoConf and showBullish and onlyRecent

bearFVG    = highC < lowA
bearNoConf = closeC > lowB
bearSignal = isNewHtfBar and bearFVG and bearNoConf and showBearish and onlyRecent

// --- Gleiche Logik auf Basis der noch LAUFENDEN Kerze 3 (unbestätigt) ---
liveBullFVG    = liveLowC > liveHighA
liveBullNoConf = liveCloseC < liveHighB
liveBullActive = liveBullFVG and liveBullNoConf and showBullish and showEarlyWarning and onlyRecent
liveBullEarly  = liveBullActive and not earlyWarnedBull

liveBearFVG    = liveHighC < liveLowA
liveBearNoConf = liveCloseC > liveLowB
liveBearActive = liveBearFVG and liveBearNoConf and showBearish and showEarlyWarning and onlyRecent
liveBearEarly  = liveBearActive and not earlyWarnedBear

// --- Rejection-Candle-Qualität von Kerze C (Shooting Star / Hammer-Optik) ---
rangeC       = highC - lowC
upperWickC   = highC - math.max(openC, closeC)
lowerWickC   = math.min(openC, closeC) - lowC
bullWickRatio = rangeC > 0 ? upperWickC / rangeC : 0.0   // relevant für Bull-Setup (Ablehnung am High)
bearWickRatio = rangeC > 0 ? lowerWickC / rangeC : 0.0   // relevant für Bear-Setup (Ablehnung am Low)

// --- Deterministischer Zeitanker für bestätigte Signale ---
// Statt dem nativen "time" des aktuellen Charts (verhält sich in Echtzeit/Replay
// nicht zuverlässig - Labels landeten teils 1 Bar zu früh bzw. im Replay random)
// wird der Start von Kerze 4 direkt aus den zuverlässigen HTF-Daten berechnet:
// Start von Kerze C (htfTime) + eine HTF-Periodenlänge.
htfSeconds    = timeframe.in_seconds(htf)
candle4Start  = htfTime + htfSeconds * 1000

// --- Rechter Rand für Box/Linie (in Chart-Bar-Zeiteinheiten verlängert) ---
barDelta         = time - time[1]
rightEdge        = time + extendBars * barDelta          // für Frühwarnung/Vorschau (an "jetzt" gebunden)
rightEdgeConfirmed = candle4Start + extendBars * barDelta // für bestätigte Signale (deterministisch verankert)

// =========================================================================
// LIVE-VORSCHAU-BOX: zeigt die sich entwickelnde FVG-Zone, bevor Kerze 3 schließt
// =========================================================================
var box previewBullBox = na
var box previewBearBox = na
var label earlyBullLabel = na
var label earlyBearLabel = na

if isNewLiveHtfBar
    if not na(previewBullBox)
        box.delete(previewBullBox)
        previewBullBox := na
    if not na(previewBearBox)
        box.delete(previewBearBox)
        previewBearBox := na
    if not na(earlyBullLabel)
        label.delete(earlyBullLabel)
        earlyBullLabel := na
    if not na(earlyBearLabel)
        label.delete(earlyBearLabel)
        earlyBearLabel := na

if liveBullActive
    if na(previewBullBox)
        previewBullBox := box.new(left = htfBarBStart, top = liveLowC, bottom = liveHighA, right = rightEdge, xloc = xloc.bar_time, border_color = color.teal, border_style = line.style_dashed, bgcolor = color.new(color.teal, 85))
    else
        box.set_top(previewBullBox, liveLowC)
        box.set_bottom(previewBullBox, liveHighA)
        box.set_right(previewBullBox, rightEdge)
else
    if not na(previewBullBox)
        box.delete(previewBullBox)
        previewBullBox := na

if liveBearActive
    if na(previewBearBox)
        previewBearBox := box.new(left = htfBarBStart, top = liveLowA, bottom = liveHighC, right = rightEdge, xloc = xloc.bar_time, border_color = color.red, border_style = line.style_dashed, bgcolor = color.new(color.red, 85))
    else
        box.set_top(previewBearBox, liveLowA)
        box.set_bottom(previewBearBox, liveHighC)
        box.set_right(previewBearBox, rightEdge)
else
    if not na(previewBearBox)
        box.delete(previewBearBox)
        previewBearBox := na

// --- Frühwarnung: Label + Alert (vorläufig, Kerze 3 noch nicht geschlossen) ---
if liveBullEarly
    earlyWarnedBull := true
    if effectiveShowLabels
        earlyBullLabel := label.new(x = time, y = high, xloc = xloc.bar_time, text = "? Bull Setup", style = label.style_label_down, color = color.new(color.teal, 40), textcolor = color.white, size = size.tiny)
    alert("VORLÄUFIG: Bullish FVG-Setup zeichnet sich ab | TF=" + htf + " | Kerze 3 läuft noch, Bestätigung erst mit Kerzenschluss | FVG-Zone (Stand jetzt): " + str.tostring(highA, format.mintick) + " - " + str.tostring(liveLowC, format.mintick), alert.freq_once_per_bar)

if liveBearEarly
    earlyWarnedBear := true
    if effectiveShowLabels
        earlyBearLabel := label.new(x = time, y = low, xloc = xloc.bar_time, text = "? Bear Setup", style = label.style_label_up, color = color.new(color.red, 40), textcolor = color.white, size = size.tiny)
    alert("VORLÄUFIG: Bearish FVG-Setup zeichnet sich ab | TF=" + htf + " | Kerze 3 läuft noch, Bestätigung erst mit Kerzenschluss | FVG-Zone (Stand jetzt): " + str.tostring(liveHighC, format.mintick) + " - " + str.tostring(lowA, format.mintick), alert.freq_once_per_bar)

// =========================================================================
// SETUP-VERWALTUNG: jedes bestätigte Setup als Objekt in einer Liste, damit
// wir sauber auf die letzten N begrenzen und pro Setup den Fortschritt
// (gefüllt / invalidiert) einzeln nachverfolgen können.
// =========================================================================
type Setup
    box   b
    line  ln
    label lbl
    float zoneTop
    float zoneBottom
    float invalidLevel
    bool  pending
    bool  isBull
    bool  isStrong
    float runningHigh
    float runningLow

var array<Setup> setups = array.new<Setup>()

addSetup(Setup s) =>
    array.push(setups, s)
    if limitSetups and array.size(setups) > maxSetups
        old = array.shift(setups)
        box.delete(old.b)
        line.delete(old.ln)
        if not na(old.lbl)
            label.delete(old.lbl)

if bullSignal
    if not na(previewBullBox)
        box.delete(previewBullBox)
        previewBullBox := na
    bullInvalidLevel = math.max(highB, highC)   // höchster Punkt von Kerze B ODER C - falls C's Docht B's High schon genommen hat, ist C's High der relevante, noch nicht genommene Punkt
    bullStrong = showConfidence and bullWickRatio >= wickRatioThresh
    bullLabelText = (bullStrong ? "★ " : "") + "Bull FVG"
    newBox   = box.new(left = htfBarBStart, top = lowC, bottom = highA, right = rightEdgeConfirmed, xloc = xloc.bar_time, border_color = color.teal, border_width = bullStrong ? 2 : 1, bgcolor = fvgUpColor, extend = extend.none)
    newLine  = line.new(htfBarBStart, bullInvalidLevel, rightEdgeConfirmed, bullInvalidLevel, xloc = xloc.bar_time, color = color.teal, style = line.style_dashed)
    newLabel = effectiveShowLabels ? label.new(x = candle4Start, y = lowC, xloc = xloc.bar_time, text = bullLabelText, style = label.style_label_down, color = color.teal, textcolor = color.white, size = size.tiny) : na
    addSetup(Setup.new(b = newBox, ln = newLine, lbl = newLabel, zoneTop = lowC, zoneBottom = highA, invalidLevel = bullInvalidLevel, pending = true, isBull = true, isStrong = bullStrong, runningHigh = na, runningLow = na))

if bearSignal
    if not na(previewBearBox)
        box.delete(previewBearBox)
        previewBearBox := na
    bearInvalidLevel = math.min(lowB, lowC)     // tiefster Punkt von Kerze B ODER C - falls C's Docht B's Low schon genommen hat, ist C's Low der relevante, noch nicht genommene Punkt
    bearStrong = showConfidence and bearWickRatio >= wickRatioThresh
    bearLabelText = (bearStrong ? "★ " : "") + "Bear FVG"
    newBox   = box.new(left = htfBarBStart, top = lowA, bottom = highC, right = rightEdgeConfirmed, xloc = xloc.bar_time, border_color = color.red, border_width = bearStrong ? 2 : 1, bgcolor = fvgDownColor, extend = extend.none)
    newLine  = line.new(htfBarBStart, bearInvalidLevel, rightEdgeConfirmed, bearInvalidLevel, xloc = xloc.bar_time, color = color.red, style = line.style_dashed)
    newLabel = effectiveShowLabels ? label.new(x = candle4Start, y = highC, xloc = xloc.bar_time, text = bearLabelText, style = label.style_label_up, color = color.red, textcolor = color.white, size = size.tiny) : na
    addSetup(Setup.new(b = newBox, ln = newLine, lbl = newLabel, zoneTop = lowA, zoneBottom = highC, invalidLevel = bearInvalidLevel, pending = true, isBull = false, isStrong = bearStrong, runningHigh = na, runningLow = na))

// =========================================================================
// SETUP-TRACKING: für jedes noch offene Setup in der Liste prüfen, ob das
// FVG zuerst gefüllt wird (Erfolg) oder das Level von Kerze B/C zuerst bricht
// (Invalidierung). Nutzt die M15-Live-Daten, unabhängig vom Chart-Timeframe.
// =========================================================================
if array.size(setups) > 0
    for i = 0 to array.size(setups) - 1
        s = array.get(setups, i)
        if s.pending
            // Laufendes Hoch/Tief seit Bestätigung auf Basis der M15-Daten (liveHighC/liveLowC),
            // NICHT des nativen Chart-High/Low - dadurch identisches Ergebnis auf M1 wie auf M15.
            s.runningHigh := math.max(nz(s.runningHigh, liveHighC), liveHighC)
            s.runningLow  := math.min(nz(s.runningLow, liveLowC), liveLowC)
            filled      = s.isBull ? (s.runningLow <= s.zoneTop and s.runningHigh >= s.zoneBottom) : (s.runningHigh >= s.zoneBottom and s.runningLow <= s.zoneTop)
            invalidated = s.isBull ? (s.runningHigh > s.invalidLevel) : (s.runningLow < s.invalidLevel)
            if filled
                if effectiveShowLabels and not na(s.lbl)
                    label.set_text(s.lbl, (s.isStrong ? "★ " : "") + (s.isBull ? "✓ Bull FVG gefüllt" : "✓ Bear FVG gefüllt"))
                    label.set_x(s.lbl, time)
                    label.set_y(s.lbl, s.isBull ? high : low)
                s.pending := false
            else if invalidated
                if effectiveShowLabels and not na(s.lbl)
                    label.set_text(s.lbl, (s.isStrong ? "★ " : "") + (s.isBull ? "✗ Bull FVG invalidiert" : "✗ Bear FVG invalidiert"))
                    label.set_color(s.lbl, color.new(color.gray, 40))
                    label.set_x(s.lbl, time)
                    label.set_y(s.lbl, s.isBull ? high : low)
                if not na(s.b)
                    box.set_border_color(s.b, color.new(color.gray, 40))
                    box.set_bgcolor(s.b, color.new(color.gray, 90))
                s.pending := false

// --- Alerts ---
alertcondition(bullSignal, title = "Bullish FVG No-Continuation", message = "Bullisches FVG mit No-Continuation-Close erkannt (bestätigt)")
alertcondition(bearSignal, title = "Bearish FVG No-Continuation", message = "Bärisches FVG mit No-Continuation-Close erkannt (bestätigt)")

if bullSignal
    alert("BESTÄTIGT: BULLISH FVG No-Continuation | TF=" + htf + " | FVG-Zone: " + str.tostring(highA, format.mintick) + " - " + str.tostring(lowC, format.mintick) + " | Ziel (nicht zuerst erwartet): " + str.tostring(math.max(highB, highC), format.mintick), alert.freq_once_per_bar)

if bearSignal
    alert("BESTÄTIGT: BEARISH FVG No-Continuation | TF=" + htf + " | FVG-Zone: " + str.tostring(highC, format.mintick) + " - " + str.tostring(lowA, format.mintick) + " | Ziel (nicht zuerst erwartet): " + str.tostring(math.min(lowB, lowC), format.mintick), alert.freq_once_per_bar)
````
