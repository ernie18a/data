<!-- tradingview-pine-id: PUB;4eef04c9c26d479abda3b6de75d28c3a -->
<!-- tradingviewscripts-format: 1 -->
# MAUI Body Gaps INEF V2

Source: https://www.tradingview.com/script/7HevOPds/

## Description

## MAUI Body Gaps MTF

The **MAUI Body Gaps MTF** indicator identifies price gaps between the closing price of one candle and the opening price of the next candle across multiple timeframes.

The indicator supports the following timeframes:

**Current Chart, M1, M2, M3, M4, M5, M15, M30, M45, H1, H2, H3, H4, and Daily.**

Each timeframe can be enabled or disabled individually. Bullish and bearish gap colors can also be configured separately for every timeframe.

### Gap Detection Modes

The indicator offers two detection methods:

* **Previous Close → Next Open**
  Detects a gap between the previous candle’s closing price and the next candle’s opening price.

* **Completely Separated Candle Bodies**
  Detects gaps where the candle bodies do not overlap.

### Main Features

* Multi-timeframe gap detection
* Individual color settings for every timeframe
* Separate bullish and bearish gap colors
* Adjustable minimum gap size in ticks
* Adjustable line width and line style
* Optional display of bullish or bearish gaps
* Optional deletion of fully filled gaps
* Gap mitigation based on wick or candle body
* Maximum number of displayed gaps can be configured
* Alert conditions for new bullish and bearish gaps
* Optional setting to display only confirmed, fully printed gaps

When **“Only confirmed printed gaps”** is enabled, a gap is displayed only after the relevant candle has fully closed. This prevents unfinished gaps from appearing while a candle is still forming.

Filled gaps can either be stopped at the mitigation candle or removed completely from the chart.

This indicator is designed to provide a clear overview of open body gaps across several intraday and higher timeframes.

---

## Source Code

````pine
//@version=6
indicator(
     title            = "MAUI Body Gaps INEF V2",
     shorttitle       = "MAUI Body Gaps INEF V2",
     overlay          = true,
     max_lines_count  = 500
)

//────────────────────────────────────────────────────────────
// EINSTELLUNGEN
//────────────────────────────────────────────────────────────

groupDetection = "Erkennung"

gapDefinition = input.string(
     defval  = "Schlusskurs → nächster Open",
     title   = "Definition der Body-Lücke",
     options = [
         "Schlusskurs → nächster Open",
         "Komplett getrennte Kerzenkörper"
     ],
     group = groupDetection
)

minimumTicks = input.int(
     defval = 1,
     title  = "Mindestgröße in Ticks",
     minval = 1,
     group  = groupDetection
)

showBullishGaps = input.bool(
     defval = true,
     title  = "Bullische Lücken anzeigen",
     group  = groupDetection
)

showBearishGaps = input.bool(
     defval = true,
     title  = "Bärische Lücken anzeigen",
     group  = groupDetection
)

onlyPrintedGaps = input.bool(
     defval = true,
     title  = "Nur bereits geprintete Gaps",
     tooltip = "Aktiviert: Ein Gap wird erst übernommen, nachdem die Gap-Kerze vollständig geschlossen und damit bestätigt ist. Deaktiviert: Das Gap kann bereits während der noch laufenden Gap-Kerze angezeigt werden.",
     group  = groupDetection
)


//────────────────────────────────────────────────────────────

groupDisplay = "Darstellung"

lineWidth = input.int(
     defval = 1,
     title  = "Linienstärke",
     minval = 1,
     maxval = 4,
     group  = groupDisplay
)

lineStyleInput = input.string(
     defval  = "Durchgezogen",
     title   = "Linienart",
     options = [
         "Durchgezogen",
         "Gestrichelt",
         "Gepunktet"
     ],
     group = groupDisplay
)

maximumZones = input.int(
     defval = 100,
     title  = "Maximale Anzahl angezeigter Lücken",
     minval = 1,
     maxval = 250,
     group  = groupDisplay
)


//────────────────────────────────────────────────────────────

groupMitigation = "Schließen der Lücken"

stopWhenFilled = input.bool(
     defval = true,
     title  = "Linien stoppen, wenn Lücke vollständig geschlossen",
     group  = groupMitigation
)

fillSource = input.string(
     defval  = "Docht",
     title   = "Lücke gilt als geschlossen durch",
     options = [
         "Docht",
         "Kerzenkörper"
     ],
     group = groupMitigation
)

deleteFilledZones = input.bool(
     defval = false,
     title  = "Geschlossene Lücken vollständig löschen",
     group  = groupMitigation
)


//────────────────────────────────────────────────────────────
// TIMEFRAMES UND INDIVIDUELLE FARBEN
// Jede Zeile: Anzeigen | bullische Farbe | bärische Farbe
//────────────────────────────────────────────────────────────

groupTimeframes = "Timeframes und Farben"

showChartTf = input.bool(true, "Aktueller Chart", group = groupTimeframes, inline = "CHART")
chartBullColor = input.color(color.aqua, "Bull", group = groupTimeframes, inline = "CHART")
chartBearColor = input.color(color.orange, "Bär", group = groupTimeframes, inline = "CHART")

showM1 = input.bool(true, "M1", group = groupTimeframes, inline = "M1")
m1BullColor = input.color(color.aqua, "Bull", group = groupTimeframes, inline = "M1")
m1BearColor = input.color(color.orange, "Bär", group = groupTimeframes, inline = "M1")

showM2 = input.bool(true, "M2", group = groupTimeframes, inline = "M2")
m2BullColor = input.color(color.aqua, "Bull", group = groupTimeframes, inline = "M2")
m2BearColor = input.color(color.orange, "Bär", group = groupTimeframes, inline = "M2")

showM3 = input.bool(true, "M3", group = groupTimeframes, inline = "M3")
m3BullColor = input.color(color.aqua, "Bull", group = groupTimeframes, inline = "M3")
m3BearColor = input.color(color.orange, "Bär", group = groupTimeframes, inline = "M3")

showM4 = input.bool(true, "M4", group = groupTimeframes, inline = "M4")
m4BullColor = input.color(color.aqua, "Bull", group = groupTimeframes, inline = "M4")
m4BearColor = input.color(color.orange, "Bär", group = groupTimeframes, inline = "M4")

showM5 = input.bool(true, "M5", group = groupTimeframes, inline = "M5")
m5BullColor = input.color(color.aqua, "Bull", group = groupTimeframes, inline = "M5")
m5BearColor = input.color(color.orange, "Bär", group = groupTimeframes, inline = "M5")

showM15 = input.bool(true, "M15", group = groupTimeframes, inline = "M15")
m15BullColor = input.color(color.aqua, "Bull", group = groupTimeframes, inline = "M15")
m15BearColor = input.color(color.orange, "Bär", group = groupTimeframes, inline = "M15")

showM30 = input.bool(true, "M30", group = groupTimeframes, inline = "M30")
m30BullColor = input.color(color.aqua, "Bull", group = groupTimeframes, inline = "M30")
m30BearColor = input.color(color.orange, "Bär", group = groupTimeframes, inline = "M30")

showM45 = input.bool(true, "M45", group = groupTimeframes, inline = "M45")
m45BullColor = input.color(color.aqua, "Bull", group = groupTimeframes, inline = "M45")
m45BearColor = input.color(color.orange, "Bär", group = groupTimeframes, inline = "M45")

showH1 = input.bool(true, "H1", group = groupTimeframes, inline = "H1")
h1BullColor = input.color(color.aqua, "Bull", group = groupTimeframes, inline = "H1")
h1BearColor = input.color(color.orange, "Bär", group = groupTimeframes, inline = "H1")

showH2 = input.bool(true, "H2", group = groupTimeframes, inline = "H2")
h2BullColor = input.color(color.aqua, "Bull", group = groupTimeframes, inline = "H2")
h2BearColor = input.color(color.orange, "Bär", group = groupTimeframes, inline = "H2")

showH3 = input.bool(true, "H3", group = groupTimeframes, inline = "H3")
h3BullColor = input.color(color.aqua, "Bull", group = groupTimeframes, inline = "H3")
h3BearColor = input.color(color.orange, "Bär", group = groupTimeframes, inline = "H3")

showH4 = input.bool(true, "H4", group = groupTimeframes, inline = "H4")
h4BullColor = input.color(color.aqua, "Bull", group = groupTimeframes, inline = "H4")
h4BearColor = input.color(color.orange, "Bär", group = groupTimeframes, inline = "H4")

showD = input.bool(true, "D", group = groupTimeframes, inline = "D")
dBullColor = input.color(color.aqua, "Bull", group = groupTimeframes, inline = "D")
dBearColor = input.color(color.orange, "Bär", group = groupTimeframes, inline = "D")


//────────────────────────────────────────────────────────────
// LINIENSTIL UND PREISWERTE
//────────────────────────────────────────────────────────────

selectedLineStyle = switch lineStyleInput
    "Gestrichelt" => line.style_dashed
    "Gepunktet"   => line.style_dotted
    => line.style_solid

minimumGapSize = minimumTicks * syminfo.mintick


//────────────────────────────────────────────────────────────
// SPEICHER FÜR DIE LÜCKEN
//────────────────────────────────────────────────────────────

var array<line> topLines         = array.new<line>()
var array<line> bottomLines      = array.new<line>()
var array<float> zoneTops        = array.new<float>()
var array<float> zoneBottoms     = array.new<float>()
var array<int> zoneDirections    = array.new<int>()
var array<int> zoneCreationTimes = array.new<int>()
var array<bool> activeZones      = array.new<bool>()


//────────────────────────────────────────────────────────────
// HILFSFUNKTIONEN
//────────────────────────────────────────────────────────────

// Entfernt eine gespeicherte Zone vollständig.
f_removeZone(int index) =>
    line upperLine = array.get(topLines, index)
    line lowerLine = array.get(bottomLines, index)

    line.delete(upperLine)
    line.delete(lowerLine)

    array.remove(topLines, index)
    array.remove(bottomLines, index)
    array.remove(zoneTops, index)
    array.remove(zoneBottoms, index)
    array.remove(zoneDirections, index)
    array.remove(zoneCreationTimes, index)
    array.remove(activeZones, index)

    true


// Sorgt dafür, dass vor einer neuen Zone genug Platz vorhanden ist.
f_makeRoomForNewZone() =>
    while array.size(topLines) >= maximumZones
        f_removeZone(0)

    true


// Prüft aktive Zonen auf vollständige Schließung.
f_checkMitigation(float testedLow, float testedHigh, int eventTime) =>
    if stopWhenFilled and not na(eventTime) and array.size(topLines) > 0
        for i = array.size(topLines) - 1 to 0
            bool zoneIsActive = array.get(activeZones, i)

            if zoneIsActive
                int creationTime = array.get(zoneCreationTimes, i)

                // Die Gap-Kerze selbst gilt nicht als spätere Mitigation.
                if eventTime > creationTime
                    int direction = array.get(zoneDirections, i)
                    float zoneTop = array.get(zoneTops, i)
                    float zoneBottom = array.get(zoneBottoms, i)

                    bool zoneFilled = direction == 1 ?
                         testedLow <= zoneBottom :
                         testedHigh >= zoneTop

                    if zoneFilled
                        line upperLine = array.get(topLines, i)
                        line lowerLine = array.get(bottomLines, i)

                        if deleteFilledZones
                            f_removeZone(i)
                        else
                            line.set_extend(upperLine, extend.none)
                            line.set_extend(lowerLine, extend.none)

                            line.set_x2(upperLine, eventTime)
                            line.set_x2(lowerLine, eventTime)

                            array.set(activeZones, i, false)

    true


// Zeichnet und speichert eine neue Body-Lücke.
f_createGap(
     int direction,
     float gapTop,
     float gapBottom,
     int topStartTime,
     int bottomStartTime,
     int creationTime,
     color bullishTfColor,
     color bearishTfColor
) =>
    bool directionAllowed = direction == 1 ? showBullishGaps : direction == -1 ? showBearishGaps : false

    if directionAllowed and not na(gapTop) and not na(gapBottom) and not na(topStartTime) and not na(bottomStartTime) and not na(creationTime)
        f_makeRoomForNewZone()

        color gapColor = direction == 1 ? bullishTfColor : bearishTfColor
        int lineEndTime = creationTime + 1

        line newTopLine = line.new(
             x1     = topStartTime,
             y1     = gapTop,
             x2     = lineEndTime,
             y2     = gapTop,
             xloc   = xloc.bar_time,
             extend = extend.right,
             color  = gapColor,
             style  = selectedLineStyle,
             width  = lineWidth
        )

        line newBottomLine = line.new(
             x1     = bottomStartTime,
             y1     = gapBottom,
             x2     = lineEndTime,
             y2     = gapBottom,
             xloc   = xloc.bar_time,
             extend = extend.right,
             color  = gapColor,
             style  = selectedLineStyle,
             width  = lineWidth
        )

        array.push(topLines, newTopLine)
        array.push(bottomLines, newBottomLine)
        array.push(zoneTops, gapTop)
        array.push(zoneBottoms, gapBottom)
        array.push(zoneDirections, direction)
        array.push(zoneCreationTimes, creationTime)
        array.push(activeZones, true)

    directionAllowed


// Berechnet die Gap-Daten im jeweils angefragten Timeframe.
// Rückgabe:
// Richtung, Oberkante, Unterkante, Startzeit Oberkante,
// Startzeit Unterkante, Entstehungszeit, getestetes Tief, getestetes Hoch
f_getGapData() =>
    float previousClose = math.round_to_mintick(close[1])
    float currentOpen = math.round_to_mintick(open)

    float previousBodyHigh = math.round_to_mintick(math.max(open[1], close[1]))
    float previousBodyLow = math.round_to_mintick(math.min(open[1], close[1]))

    float currentBodyHigh = math.round_to_mintick(math.max(open, close))
    float currentBodyLow = math.round_to_mintick(math.min(open, close))

    int gapDirection = 0
    float gapTop = na
    float gapBottom = na
    int topStartTime = na
    int bottomStartTime = na

    if not na(close[1])
        if gapDefinition == "Schlusskurs → nächster Open"
            float openingDifference = currentOpen - previousClose

            if openingDifference >= minimumGapSize
                gapDirection := 1
                gapTop := currentOpen
                gapBottom := previousClose
                topStartTime := time
                bottomStartTime := time[1]

            else if openingDifference <= -minimumGapSize
                gapDirection := -1
                gapTop := previousClose
                gapBottom := currentOpen
                topStartTime := time[1]
                bottomStartTime := time

        else
            if currentBodyLow - previousBodyHigh >= minimumGapSize
                gapDirection := 1
                gapTop := currentBodyLow
                gapBottom := previousBodyHigh
                topStartTime := time
                bottomStartTime := time[1]

            else if previousBodyLow - currentBodyHigh >= minimumGapSize
                gapDirection := -1
                gapTop := previousBodyLow
                gapBottom := currentBodyHigh
                topStartTime := time[1]
                bottomStartTime := time

    float testedLow = fillSource == "Docht" ? low : math.min(open, close)
    float testedHigh = fillSource == "Docht" ? high : math.max(open, close)

    // Optional nur vollständig abgeschlossene („geprintete“) Gap-Kerzen verwenden.
    // Die Gap-Daten werden dann um genau eine Kerze verzögert ausgegeben.
    int outputDirection = onlyPrintedGaps ? gapDirection[1] : gapDirection
    float outputGapTop = onlyPrintedGaps ? gapTop[1] : gapTop
    float outputGapBottom = onlyPrintedGaps ? gapBottom[1] : gapBottom
    int outputTopStartTime = onlyPrintedGaps ? topStartTime[1] : topStartTime
    int outputBottomStartTime = onlyPrintedGaps ? bottomStartTime[1] : bottomStartTime
    int outputCreationTime = onlyPrintedGaps ? time[1] : time

    [outputDirection, outputGapTop, outputGapBottom, outputTopStartTime, outputBottomStartTime, outputCreationTime, testedLow, testedHigh]


// Verarbeitet genau einen auswählbaren Timeframe.
// Gleiches oder höheres TF: request.security()
// Niedrigeres TF: request.security_lower_tf() mit allen Intrabars
f_processTimeframe(
     string requestedTf,
     bool enabled,
     color bullishTfColor,
     color bearishTfColor,
     bool skipChartDuplicate
) =>
    bool newBullishGap = false
    bool newBearishGap = false

    float chartSeconds = timeframe.in_seconds()
    float requestedSeconds = timeframe.in_seconds(requestedTf)
    bool isChartDuplicate = skipChartDuplicate and requestedSeconds == chartSeconds

    var int lastProcessedTime = na

    if enabled and not isChartDuplicate
        if requestedSeconds < chartSeconds
            [directionData, topData, bottomData, topTimeData, bottomTimeData, creationTimeData, testedLowData, testedHighData] = request.security_lower_tf(
                 syminfo.tickerid,
                 requestedTf,
                 f_getGapData()
            )

            int intrabarCount = array.size(directionData)

            if intrabarCount > 0
                for i = 0 to intrabarCount - 1
                    int intrabarTime = array.get(creationTimeData, i)

                    if na(lastProcessedTime) or intrabarTime > lastProcessedTime
                        float intrabarTestedLow = array.get(testedLowData, i)
                        float intrabarTestedHigh = array.get(testedHighData, i)

                        // Bereits bestehende Zonen zuerst mit diesem Intrabar prüfen.
                        f_checkMitigation(intrabarTestedLow, intrabarTestedHigh, intrabarTime)

                        int direction = array.get(directionData, i)

                        if direction != 0
                            float gapTop = array.get(topData, i)
                            float gapBottom = array.get(bottomData, i)
                            int topStartTime = array.get(topTimeData, i)
                            int bottomStartTime = array.get(bottomTimeData, i)

                            bool created = f_createGap(
                                 direction,
                                 gapTop,
                                 gapBottom,
                                 topStartTime,
                                 bottomStartTime,
                                 intrabarTime,
                                 bullishTfColor,
                                 bearishTfColor
                            )

                            if created
                                newBullishGap := newBullishGap or direction == 1
                                newBearishGap := newBearishGap or direction == -1

                        lastProcessedTime := intrabarTime

        else
            [direction, gapTop, gapBottom, topStartTime, bottomStartTime, creationTime, _, _] = request.security(
                 syminfo.tickerid,
                 requestedTf,
                 f_getGapData(),
                 gaps      = barmerge.gaps_off,
                 lookahead = barmerge.lookahead_on
            )

            bool isUnprocessedTime = not na(creationTime) and (na(lastProcessedTime) or creationTime > lastProcessedTime)

            if isUnprocessedTime
                if direction != 0
                    bool created = f_createGap(
                         direction,
                         gapTop,
                         gapBottom,
                         topStartTime,
                         bottomStartTime,
                         creationTime,
                         bullishTfColor,
                         bearishTfColor
                    )

                    if created
                        newBullishGap := direction == 1
                        newBearishGap := direction == -1

                lastProcessedTime := creationTime

    [newBullishGap, newBearishGap]


//────────────────────────────────────────────────────────────
// TIMEFRAMES VERARBEITEN
//────────────────────────────────────────────────────────────

// Der aktuelle Chart wird zuerst verarbeitet. Dadurch bleibt die bisherige
// Funktion erhalten. Feste Timeframes mit identischer Dauer werden danach
// automatisch übersprungen, damit keine doppelten Linien entstehen.
[chartBullAlert, chartBearAlert] = f_processTimeframe(
     timeframe.period,
     showChartTf,
     chartBullColor,
     chartBearColor,
     false
)

[m1BullAlert, m1BearAlert] = f_processTimeframe("1", showM1, m1BullColor, m1BearColor, showChartTf)
[m2BullAlert, m2BearAlert] = f_processTimeframe("2", showM2, m2BullColor, m2BearColor, showChartTf)
[m3BullAlert, m3BearAlert] = f_processTimeframe("3", showM3, m3BullColor, m3BearColor, showChartTf)
[m4BullAlert, m4BearAlert] = f_processTimeframe("4", showM4, m4BullColor, m4BearColor, showChartTf)
[m5BullAlert, m5BearAlert] = f_processTimeframe("5", showM5, m5BullColor, m5BearColor, showChartTf)
[m15BullAlert, m15BearAlert] = f_processTimeframe("15", showM15, m15BullColor, m15BearColor, showChartTf)
[m30BullAlert, m30BearAlert] = f_processTimeframe("30", showM30, m30BullColor, m30BearColor, showChartTf)
[m45BullAlert, m45BearAlert] = f_processTimeframe("45", showM45, m45BullColor, m45BearColor, showChartTf)
[h1BullAlert, h1BearAlert] = f_processTimeframe("60", showH1, h1BullColor, h1BearColor, showChartTf)
[h2BullAlert, h2BearAlert] = f_processTimeframe("120", showH2, h2BullColor, h2BearColor, showChartTf)
[h3BullAlert, h3BearAlert] = f_processTimeframe("180", showH3, h3BullColor, h3BearColor, showChartTf)
[h4BullAlert, h4BearAlert] = f_processTimeframe("240", showH4, h4BullColor, h4BearColor, showChartTf)
[dBullAlert, dBearAlert] = f_processTimeframe("1D", showD, dBullColor, dBearColor, showChartTf)


//────────────────────────────────────────────────────────────
// BEREITS VORHANDENE LÜCKEN MIT DEM CHARTBAR PRÜFEN
//────────────────────────────────────────────────────────────

float chartTestedLow = fillSource == "Docht" ? low : math.min(open, close)
float chartTestedHigh = fillSource == "Docht" ? high : math.max(open, close)

f_checkMitigation(chartTestedLow, chartTestedHigh, time)


//────────────────────────────────────────────────────────────
// ALARME
//────────────────────────────────────────────────────────────

bool newBullishGap =
     chartBullAlert or
     m1BullAlert or
     m2BullAlert or
     m3BullAlert or
     m4BullAlert or
     m5BullAlert or
     m15BullAlert or
     m30BullAlert or
     m45BullAlert or
     h1BullAlert or
     h2BullAlert or
     h3BullAlert or
     h4BullAlert or
     dBullAlert

bool newBearishGap =
     chartBearAlert or
     m1BearAlert or
     m2BearAlert or
     m3BearAlert or
     m4BearAlert or
     m5BearAlert or
     m15BearAlert or
     m30BearAlert or
     m45BearAlert or
     h1BearAlert or
     h2BearAlert or
     h3BearAlert or
     h4BearAlert or
     dBearAlert

alertcondition(
     condition = newBullishGap,
     title     = "Neue bullische Body-Lücke",
     message   = "Eine neue bullische Body-Lücke wurde erkannt."
)

alertcondition(
     condition = newBearishGap,
     title     = "Neue bärische Body-Lücke",
     message   = "Eine neue bärische Body-Lücke wurde erkannt."
)
````
