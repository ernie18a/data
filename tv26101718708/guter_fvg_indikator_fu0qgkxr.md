# Guter FVG Indikator

- url: https://www.tradingview.com/script/fu0qgKxr/
- type: indicator
- pine_id: PUB;13ad28d643094bff9996f2b0f2f46a7e
- version: 1.0

## Description

Dieses Pine Script v6 ist ein erweiterter Fair Value Gap Indikator auf Basis des ursprünglichen FVG-Heatmap-Konzepts von Hash Capital Research.

Der Indikator erkennt automatisch Bullish und Bearish Fair Value Gaps, zeichnet diese direkt im Chart ein und verwaltet aktive Zonen inklusive optionaler Mitigation-Logik, Midline, Labels und Dashboard.

Was macht der Indikator?

Der Indikator sucht nach klassischen 3-Kerzen-Fair-Value-Gaps:

Bullish FVG: wenn high[2] < low
Bearish FVG: wenn low[2] > high
Gefundene Zonen werden als Boxen im Chart angezeigt. Optional wird zusätzlich die 50%-Mittellinie der FVG-Zone eingezeichnet.

Wichtige Funktionen

automatische Erkennung von Bullish und Bearish FVGs
ATR-basierter Mindestfilter für Gap-Größe
optionaler Prozentfilter für Mindestgröße des FVGs
einstellbare Mitigation-Regeln:
Full Fill
50% Fill
First Touch
optionale Entfernung gefüllter Zonen
Midline-Anzeige für die 50%-Zone
Labels für neue FVGs und gefüllte Zonen
Dashboard mit Regime-Auswertung
Alerts für neue Bullish/Bearish FVGs
Neue Dashboard-Erweiterung

Zusätzlich zeigt das Dashboard jetzt die nächsten aktiven FVGs zur aktuellen Preisposition an:

Long FVG 1
Long FVG 2
Short FVG 1
Short FVG 2
Dabei werden nur aktive FVG-Zonen berücksichtigt.

Ein Long FVG entspricht einem Bullish FVG.
Ein Short FVG entspricht einem Bearish FVG.

Die Distanz wird immer zur Mittellinie des jeweiligen FVGs berechnet:

distanceToMidPercent = ((zone.midpoint - close) / close) * 100
Für die Sortierung wird die absolute Distanz verwendet. Dadurch werden die nächstgelegenen FVGs unabhängig davon gefunden, ob sie oberhalb oder unterhalb des aktuellen Preises liegen.

Ausschlussregel für sehr nahe FVGs

FVGs, deren Mittellinie bereits sehr nahe am aktuellen Preis liegt, werden nicht mehr im Dashboard angezeigt.

Wenn die Distanz zur Midline kleiner oder gleich 0.2% ist, wird diese Zone ignoriert:

math.abs(distanceToMidPercent) <= 0.2
Das soll verhindern, dass bereits fast erreichte FVGs weiterhin als relevante „nächste“ Ziele angezeigt werden.

Farblogik im Dashboard

Long FVGs werden cyan/grünlich angezeigt
Short FVGs werden rot/pink angezeigt
FVGs nahe am Ausschlussbereich, also unter 0.5%, werden orange angezeigt
Wenn kein passendes FVG vorhanden ist, erscheint n/a
Regime Dashboard

Das Dashboard zeigt außerdem Statistiken zur bisherigen FVG-Füllung:

aktuelles Marktregime
durchschnittliche Fill-Dauer
Median-Fill-Dauer
schnelle Fills
langsame Fills
Sample Size
aktive Zonen
Das Regime basiert auf der Geschwindigkeit, mit der historische FVGs gefüllt wurden. Dadurch kann der Indikator Hinweise geben, ob der Markt eher mean-reverting, trending oder gemischt ist.

Wofür kann der Indikator genutzt werden?

Dieses Tool kann helfen, aktive Fair Value Gaps besser zu verfolgen und potenzielle Zielbereiche im Chart schneller zu erkennen.

Besonders nützlich ist die Anzeige der nächsten Long- und Short-FVGs, da sie direkt zeigt, welche aktiven FVG-Midlines dem aktuellen Preis am nächsten liegen.

Der Indikator ist nicht als eigenständiges Handelssystem gedacht, sondern als visuelles Analysewerkzeug zur Unterstützung bei Marktstruktur, Liquiditätszonen und möglichen Reaktionsbereichen.

Hinweis

Dieses Skript stellt keine Finanzberatung dar. Es dient ausschließlich zu Analyse- und Bildungszwecken. Trading ist mit Risiko verbunden. Nutze den Indikator immer zusammen mit eigener Analyse, Risikomanagement und einem klaren Handelsplan.


Erklärung der Marktregime

Das Dashboard versucht anhand der historischen FVG-Fill-Geschwindigkeit einzuschätzen, in welchem Marktumfeld sich der Chart aktuell eher befindet.

Dabei werden drei Regime unterschieden:

1. CHOPPY / MEAN-REVERT

Dieses Regime erscheint, wenn viele FVGs relativ schnell wieder gefüllt werden.

Das deutet häufig auf einen seitwärts laufenden, unruhigen oder stark zurücklaufenden Markt hin. Preisbewegungen halten in solchen Phasen oft nicht lange an, sondern kehren schnell zu vorherigen Ungleichgewichten zurück.

Möglicher Trading-Ansatz:

eher vorsichtig mit Breakout-Trades sein
FVGs können häufiger als kurzfristige Ziele genutzt werden
Mean-Reversion-Setups können besser funktionieren
Gewinne eher schneller sichern
nicht zu aggressiv auf starke Trendfortsetzung setzen
2. TRENDING / DISPLACEMENT

Dieses Regime erscheint, wenn FVGs langsamer oder seltener gefüllt werden.

Das kann darauf hindeuten, dass der Markt stärker in eine Richtung läuft und Ungleichgewichte länger offen bleiben. In solchen Phasen kann Momentum wichtiger sein als sofortige Rückläufe.

Möglicher Trading-Ansatz:

eher mit dem Trend arbeiten
Pullbacks in Richtung aktiver FVGs beobachten
FVGs können als mögliche Re-Entry- oder Discount/Premium-Zonen dienen
nicht jedes offene FVG sofort als Fill-Ziel behandeln
laufende Trends nicht zu früh gegenhandeln
3. MIXED / TRANSITIONAL

Dieses Regime erscheint, wenn weder schnelle noch langsame Fills klar dominieren.

Der Markt befindet sich dann oft in einer Übergangsphase. Es kann zu Richtungswechseln, wechselnder Volatilität oder unklarer Struktur kommen.

Möglicher Trading-Ansatz:

selektiver handeln
auf zusätzliche Bestätigung warten
kleinere Positionsgrößen oder konservativeres Risiko nutzen
wichtige FVGs mit Marktstruktur, Liquidität und höheren Zeiteinheiten kombinieren
keine zu starke Annahme über Trend oder Mean Reversion treffen
Wichtig

Die Regime-Anzeige ist keine Kauf- oder Verkaufsempfehlung. Sie beschreibt nur, wie sich FVGs in der jüngeren Vergangenheit verhalten haben. Am besten funktioniert sie als Kontextfilter zusammen mit Marktstruktur, Liquidität, Session-Zeiten, Volumen und sauberem Risikomanagement.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//  adrian_lot

// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//  HashCapitalResearch
// Modified: Added optional minimum FVG size filter in percent + push alert

//@version=6
indicator("FVG Heatmap [Hash Capital Research] + % Filter", "FVG Heat %", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=100)

// Zone Detection
grp_detect = "Zone Detection"
atrLength       = input.int(14, "ATR Length", minval=1, group=grp_detect)
minAtrMult      = input.float(0.25, "Min Gap Size (ATR Multiple)", minval=0.1, step=0.05, group=grp_detect)
usePercentFilter = input.bool(true, "Use % Gap Filter", group=grp_detect)
minGapPercent  = input.float(1.5, "Min Gap Size (%)", minval=0.0, step=0.1, group=grp_detect)
maxLookback     = input.int(500, "Max Lookback Bars", minval=50, group=grp_detect)

// Alerts
grp_alerts = "Alerts"
enableNewFVGAlert = input.bool(true, "Enable New FVG Alert", group=grp_alerts)

// Mitigation Rules
grp_mitig = "Mitigation Rules"
mitigationType  = input.string("Full Fill", "Mitigation Type", options=["Full Fill", "50% Fill", "First Touch"], group=grp_mitig)
removeOnFill    = input.bool(true, "Remove Zone on Fill", group=grp_mitig)
showPartialFill = input.bool(true, "Show Partial Fill Overlay", group=grp_mitig)

// Visual Settings
grp_visual = "Visual Design"
maxZones        = input.int(30, "Max Active Zones", minval=5, maxval=50, group=grp_visual)
bullColor       = input.color(color.new(#00FFFF, 70), "Bullish Zone", group=grp_visual)
bearColor       = input.color(color.new(#FF0055, 70), "Bearish Zone", group=grp_visual)
bullBorder      = input.color(color.new(#00FFFF, 30), "Bullish Border", group=grp_visual)
bearBorder      = input.color(color.new(#FF0055, 30), "Bearish Border", group=grp_visual)
fillColor       = input.color(color.new(#FFFFFF, 80), "Fill Overlay", group=grp_visual)
showMidline     = input.bool(true, "Show 50% Midline", group=grp_visual)
midlineStyle    = input.string("Dashed", "Midline Style", options=["Solid", "Dashed", "Dotted"], group=grp_visual)
strengthShading = input.bool(true, "Strength-Based Opacity", group=grp_visual)
ageFade         = input.bool(false, "Age Fade (older = fainter)", group=grp_visual)
ageFadeBars     = input.int(100, "Age Fade Period (bars)", minval=20, group=grp_visual)

// Labels
grp_labels = "Labels"
showLabels      = input.bool(true, "Show Zone Labels", group=grp_labels)
showFillLabels  = input.bool(true, "Show Fill Labels", group=grp_labels)
labelSize       = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal"], group=grp_labels)

// Dashboard
grp_dash = "Regime Dashboard"
showDashboard   = input.bool(true, "Show Dashboard", group=grp_dash)
dashPosition    = input.string("Top Right", "Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grp_dash)
dashBgColor     = input.color(color.new(#0a0a0a, 15), "Background", group=grp_dash)
dashTextColor   = input.color(#00FFFF, "Text Color", group=grp_dash)
regimeLookback  = input.int(50, "Regime Lookback (fills)", minval=10, maxval=200, group=grp_dash)
fastThreshold   = input.int(10, "Fast Fill Threshold (bars)", minval=1, group=grp_dash)
slowThreshold   = input.int(30, "Slow Fill Threshold (bars)", minval=10, group=grp_dash)

// Type Definitions
type FVGZone
    int     id
    int     createdBar
    float   top
    float   bottom
    float   midpoint
    bool    isBullish
    float   gapSize
    float   atrAtCreation
    float   strength
    bool    isActive
    float   filledTop
    float   filledBottom
    int     mitigatedBar
    box     zoneBox
    box     fillBox
    line    midLine
    label   zoneLabel

type FillRecord
    int     barsToFill
    bool    isBullish
    float   gapSize

// Global State
var array<FVGZone>    zones       = array.new<FVGZone>()
var array<FillRecord> fillHistory = array.new<FillRecord>()
var int               zoneCounter = 0

// Helper Functions
getLabelSize() =>
    switch labelSize
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal

getMidlineStyle() =>
    switch midlineStyle
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted

getDashPosition() =>
    switch dashPosition
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left

calcOpacity(float strength, int age, int maxAge, bool isBull) =>
    baseOpacity = strengthShading ? math.min(85, 50 + strength * 35) : 70
    if ageFade and maxAge > 0
        ageFactor = 1.0 - (age / maxAge) * 0.6
        baseOpacity := baseOpacity * ageFactor
    math.round(math.max(baseOpacity, 20))

formatFVGDistanceText(float distanceToMidPercent) =>
    prefix = distanceToMidPercent > 0 ? "+" : ""
    prefix + str.tostring(distanceToMidPercent, "#.##") + "% to mid"

getFVGDistanceColor(bool isBullish, float absDistance) =>
    absDistance < 0.5 ? #FFAA00 : isBullish ? #00FFFF : #FF0055

calcNearestFVGs() =>
    float long1Distance = na
    float long2Distance = na
    float short1Distance = na
    float short2Distance = na
    float long1Abs = na
    float long2Abs = na
    float short1Abs = na
    float short2Abs = na

    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            zone = array.get(zones, i)
            if zone.isActive
                distanceToMidPercent = ((zone.midpoint - close) / close) * 100
                absDistance = math.abs(distanceToMidPercent)
                if absDistance > 0.2
                    if zone.isBullish
                        if na(long1Abs) or absDistance < long1Abs
                            long2Abs := long1Abs
                            long2Distance := long1Distance
                            long1Abs := absDistance
                            long1Distance := distanceToMidPercent
                        else if na(long2Abs) or absDistance < long2Abs
                            long2Abs := absDistance
                            long2Distance := distanceToMidPercent
                    else
                        if na(short1Abs) or absDistance < short1Abs
                            short2Abs := short1Abs
                            short2Distance := short1Distance
                            short1Abs := absDistance
                            short1Distance := distanceToMidPercent
                        else if na(short2Abs) or absDistance < short2Abs
                            short2Abs := absDistance
                            short2Distance := distanceToMidPercent

    long1Text = na(long1Distance) ? "n/a" : formatFVGDistanceText(long1Distance)
    long2Text = na(long2Distance) ? "n/a" : formatFVGDistanceText(long2Distance)
    short1Text = na(short1Distance) ? "n/a" : formatFVGDistanceText(short1Distance)
    short2Text = na(short2Distance) ? "n/a" : formatFVGDistanceText(short2Distance)
    long1Color = na(long1Abs) ? color.new(dashTextColor, 60) : getFVGDistanceColor(true, long1Abs)
    long2Color = na(long2Abs) ? color.new(dashTextColor, 60) : getFVGDistanceColor(true, long2Abs)
    short1Color = na(short1Abs) ? color.new(dashTextColor, 60) : getFVGDistanceColor(false, short1Abs)
    short2Color = na(short2Abs) ? color.new(dashTextColor, 60) : getFVGDistanceColor(false, short2Abs)
    [long1Text, long1Color, long2Text, long2Color, short1Text, short1Color, short2Text, short2Color]

// FVG Detection
atrValue = ta.atr(atrLength)
minGapSize = atrValue * minAtrMult

bullishFVG = high[2] < low
bullGapTop = low
bullGapBottom = high[2]
bullGapSize = bullGapTop - bullGapBottom
bullGapPercent = bullGapSize / close * 100

bearishFVG = low[2] > high
bearGapTop = low[2]
bearGapBottom = high
bearGapSize = bearGapTop - bearGapBottom
bearGapPercent = bearGapSize / close * 100

bullPassFilter = bullishFVG and bullGapSize >= minGapSize and (not usePercentFilter or bullGapPercent >= minGapPercent)
bearPassFilter = bearishFVG and bearGapSize >= minGapSize and (not usePercentFilter or bearGapPercent >= minGapPercent)
newValidFVG = enableNewFVGAlert and (bullPassFilter or bearPassFilter)

// Zone Creation
createZone(bool isBull, float top, float bottom, float gapSize, float atr, int zoneId) =>
    strength = math.min(gapSize / atr, 2.0) / 2.0
    midpoint = (top + bottom) / 2
    opacity = calcOpacity(strength, 0, ageFadeBars, isBull)
    zoneColor = isBull ? color.new(bullColor, opacity) : color.new(bearColor, opacity)
    borderCol = isBull ? bullBorder : bearBorder
    newBox = box.new(bar_index, top, bar_index + 1, bottom, border_color=borderCol, border_width=1, bgcolor=zoneColor, border_style=line.style_solid)
    fillBox = box(na)
    if showPartialFill
        fillBox := box.new(bar_index, top, bar_index + 1, top, border_color=color.new(fillColor, 90), border_width=0, bgcolor=fillColor)
    midLine = line(na)
    if showMidline
        midLine := line.new(bar_index, midpoint, bar_index + 1, midpoint, color=borderCol, style=getMidlineStyle(), width=1)
    zoneLbl = label(na)
    if showLabels
        lblText = isBull ? "▲ FVG" : "▼ FVG"
        lblColor = isBull ? bullBorder : bearBorder
        lblPos = isBull ? label.style_label_up : label.style_label_down
        lblY = isBull ? bottom : top
        zoneLbl := label.new(bar_index, lblY, lblText, style=lblPos, color=color.new(lblColor, 80), textcolor=lblColor, size=getLabelSize())
    zone = FVGZone.new(zoneId, bar_index, top, bottom, midpoint, isBull, gapSize, atr, strength, true, top, bottom, 0, newBox, fillBox, midLine, zoneLbl)
    array.push(zones, zone)

if bullPassFilter
    zoneCounter += 1
    createZone(true, bullGapTop, bullGapBottom, bullGapSize, atrValue, zoneCounter)

if bearPassFilter
    zoneCounter += 1
    createZone(false, bearGapTop, bearGapBottom, bearGapSize, atrValue, zoneCounter)

// Zone Update & Mitigation
updateZones() =>
    if array.size(zones) > 0
        for i = array.size(zones) - 1 to 0
            zone = array.get(zones, i)
            if not zone.isActive
                continue
            age = bar_index - zone.createdBar
            if age > maxLookback
                box.delete(zone.zoneBox)
                box.delete(zone.fillBox)
                line.delete(zone.midLine)
                label.delete(zone.zoneLabel)
                array.remove(zones, i)
                continue
            box.set_right(zone.zoneBox, bar_index + 5)
            if not na(zone.midLine)
                line.set_x2(zone.midLine, bar_index + 5)
            if ageFade
                opacity = calcOpacity(zone.strength, age, ageFadeBars, zone.isBullish)
                zoneColor = zone.isBullish ? color.new(bullColor, opacity) : color.new(bearColor, opacity)
                box.set_bgcolor(zone.zoneBox, zoneColor)
            mitigated = false
            if zone.isBullish
                if low <= zone.top
                    fillLevel = math.max(low, zone.bottom)
                    zone.filledBottom := math.min(zone.filledBottom, fillLevel)
                    if showPartialFill and not na(zone.fillBox)
                        box.set_right(zone.fillBox, bar_index + 5)
                        box.set_bottom(zone.fillBox, zone.filledBottom)
                    switch mitigationType
                        "Full Fill"   => mitigated := low <= zone.bottom
                        "50% Fill"    => mitigated := low <= zone.midpoint
                        "First Touch" => mitigated := true
            else
                if high >= zone.bottom
                    fillLevel = math.min(high, zone.top)
                    zone.filledTop := math.max(zone.filledTop, fillLevel)
                    if showPartialFill and not na(zone.fillBox)
                        box.set_right(zone.fillBox, bar_index + 5)
                        box.set_top(zone.fillBox, zone.filledTop)
                        box.set_bottom(zone.fillBox, zone.bottom)
                    switch mitigationType
                        "Full Fill"   => mitigated := high >= zone.top
                        "50% Fill"    => mitigated := high >= zone.midpoint
                        "First Touch" => mitigated := true
            if mitigated and zone.isActive
                zone.isActive := false
                zone.mitigatedBar := bar_index
                barsToFill = bar_index - zone.createdBar
                fillRec = FillRecord.new(barsToFill, zone.isBullish, zone.gapSize)
                array.push(fillHistory, fillRec)
                if array.size(fillHistory) > regimeLookback * 2
                    array.shift(fillHistory)
                if showFillLabels
                    lblText = str.tostring(barsToFill) + " bars"
                    lblY = zone.isBullish ? zone.bottom : zone.top
                    lblStyle = zone.isBullish ? label.style_label_up : label.style_label_down
                    lblCol = barsToFill <= fastThreshold ? color.new(#00FF00, 50) : barsToFill >= slowThreshold ? color.new(#FF0000, 50) : color.new(#FFAA00, 50)
                    label.new(bar_index, lblY, lblText, style=lblStyle, color=lblCol, textcolor=color.white, size=getLabelSize())
                if removeOnFill
                    box.delete(zone.zoneBox)
                    box.delete(zone.fillBox)
                    line.delete(zone.midLine)
                    label.delete(zone.zoneLabel)
                    array.remove(zones, i)

updateZones()

// Zone Limit Management
manageZoneLimit() =>
    int activeCount = 0
    for zone in zones
        if zone.isActive
            activeCount += 1
    while activeCount > maxZones and array.size(zones) > 0
        int oldestIdx = -1
        int oldestBar = bar_index
        for i = 0 to array.size(zones) - 1
            zone = array.get(zones, i)
            if zone.isActive and zone.createdBar < oldestBar
                oldestBar := zone.createdBar
                oldestIdx := i
        if oldestIdx >= 0
            zone = array.get(zones, oldestIdx)
            box.delete(zone.zoneBox)
            box.delete(zone.fillBox)
            line.delete(zone.midLine)
            label.delete(zone.zoneLabel)
            array.remove(zones, oldestIdx)
            activeCount -= 1
        else
            break
    true

_ = manageZoneLimit()

// Regime Analysis & Dashboard
calcRegimeStats() =>
    if array.size(fillHistory) == 0
        [0.0, 0.0, 0.0, 0.0, 0, "Insufficient Data"]
    else
        sumBars = 0.0
        fastCount = 0
        slowCount = 0
        totalCount = math.min(array.size(fillHistory), regimeLookback)
        barsArray = array.new_int()
        startIdx = math.max(0, array.size(fillHistory) - regimeLookback)
        for i = startIdx to array.size(fillHistory) - 1
            rec = array.get(fillHistory, i)
            array.push(barsArray, rec.barsToFill)
            sumBars += rec.barsToFill
            if rec.barsToFill <= fastThreshold
                fastCount += 1
            if rec.barsToFill >= slowThreshold
                slowCount += 1
        avgBars = totalCount > 0 ? sumBars / totalCount : 0.0
        medianBars = 0.0
        if array.size(barsArray) > 0
            array.sort(barsArray)
            midIdx = array.size(barsArray) / 2
            medianBars := array.get(barsArray, int(midIdx))
        fastPct = totalCount > 0 ? (fastCount / totalCount) * 100 : 0.0
        slowPct = totalCount > 0 ? (slowCount / totalCount) * 100 : 0.0
        regime = fastPct > 50 ? "CHOPPY / MEAN-REVERT" : slowPct > 50 ? "TRENDING / DISPLACEMENT" : "MIXED / TRANSITIONAL"
        [avgBars, medianBars, fastPct, slowPct, totalCount, regime]

[avgFill, medianFill, fastPct, slowPct, fillCount, regimeText] = calcRegimeStats()
[long1Text, long1Color, long2Text, long2Color, short1Text, short1Color, short2Text, short2Color] = calcNearestFVGs()

if showDashboard and barstate.islast
    var table dash = table.new(getDashPosition(), 2, 12, bgcolor=dashBgColor, border_width=1, border_color=color.new(dashTextColor, 70), frame_width=2, frame_color=dashTextColor)
    table.cell(dash, 0, 0, "HASH FVG REGIME", text_color=dashTextColor, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 0, "════════════", text_color=color.new(dashTextColor, 50), text_size=size.small)
    table.merge_cells(dash, 0, 0, 1, 0)
    regimeColor = str.contains(regimeText, "CHOPPY") ? #00FF00 : str.contains(regimeText, "TRENDING") ? #FF0055 : #FFAA00
    table.cell(dash, 0, 1, "Regime:", text_color=color.new(dashTextColor, 30), text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 1, regimeText, text_color=regimeColor, text_size=size.tiny, text_halign=text.align_right)
    table.cell(dash, 0, 2, "Avg Fill:", text_color=color.new(dashTextColor, 30), text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(avgFill, "#.#") + " bars", text_color=dashTextColor, text_size=size.tiny, text_halign=text.align_right)
    table.cell(dash, 0, 3, "Median Fill:", text_color=color.new(dashTextColor, 30), text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(medianFill, "#") + " bars", text_color=dashTextColor, text_size=size.tiny, text_halign=text.align_right)
    table.cell(dash, 0, 4, "Fast Fills (<" + str.tostring(fastThreshold) + "):", text_color=color.new(dashTextColor, 30), text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(fastPct, "#.#") + "%", text_color=#00FF00, text_size=size.tiny, text_halign=text.align_right)
    table.cell(dash, 0, 5, "Slow Fills (>" + str.tostring(slowThreshold) + "):", text_color=color.new(dashTextColor, 30), text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(slowPct, "#.#") + "%", text_color=#FF0055, text_size=size.tiny, text_halign=text.align_right)
    table.cell(dash, 0, 6, "Sample Size:", text_color=color.new(dashTextColor, 30), text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 6, str.tostring(fillCount) + " fills", text_color=dashTextColor, text_size=size.tiny, text_halign=text.align_right)
    activeZones = 0
    for zone in zones
        if zone.isActive
            activeZones += 1
    table.cell(dash, 0, 7, "Active Zones:", text_color=color.new(dashTextColor, 30), text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(activeZones), text_color=dashTextColor, text_size=size.tiny, text_halign=text.align_right)
    table.cell(dash, 0, 8, "Long FVG 1:", text_color=color.new(dashTextColor, 30), text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 8, long1Text, text_color=long1Color, text_size=size.tiny, text_halign=text.align_right)
    table.cell(dash, 0, 9, "Long FVG 2:", text_color=color.new(dashTextColor, 30), text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 9, long2Text, text_color=long2Color, text_size=size.tiny, text_halign=text.align_right)
    table.cell(dash, 0, 10, "Short FVG 1:", text_color=color.new(dashTextColor, 30), text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 10, short1Text, text_color=short1Color, text_size=size.tiny, text_halign=text.align_right)
    table.cell(dash, 0, 11, "Short FVG 2:", text_color=color.new(dashTextColor, 30), text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 11, short2Text, text_color=short2Color, text_size=size.tiny, text_halign=text.align_right)

// Alerts
alertcondition(newValidFVG, "New FVG", "new fvg just dropped")
alertcondition(bullPassFilter, "Bullish FVG Created", "new fvg just dropped")
alertcondition(bearPassFilter, "Bearish FVG Created", "new fvg just dropped")
````
