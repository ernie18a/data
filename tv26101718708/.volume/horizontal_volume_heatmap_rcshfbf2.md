# Horizontal Volume Heatmap 

- url: https://www.tradingview.com/script/RcSHFbF2/
- type: indicator
- pine_id: PUB;caee88652ed34ac3933468c98f6961b3
- version: 1.0

## Description

Der **Horizontal Volume Heatmap Indicator** zeigt, auf welchen Preisniveaus innerhalb eines frei wählbaren Zeitraums besonders viel Volumen gehandelt wurde. Die Volumenverteilung wird als farbige Heatmap direkt im Chart dargestellt und bleibt beim Zoomen oder Wechseln des Timeframes an den jeweiligen Kurswerten verankert.

Der Indikator unterstützt einen Lookback nach Bars oder Kalendertagen, wobei Handelstage nach deutscher Zeit um 00:00 Uhr beginnen. Zusätzlich werden ein horizontales Volumenprofil und der Point of Control angezeigt. Bis zu 1.000 Preiszonen können für eine detaillierte Analyse berechnet werden.

## Source Code

````pine
//@version=6
indicator(
     "Horizontal Volume Heatmap – Anchored",
     shorttitle      = "HV Heatmap (Anchored)",
     overlay         = true,
     behind_chart    = true,
     max_bars_back   = 5000,
     max_boxes_count = 500,
     max_lines_count = 10
)

// WICHTIG:
// Es wird absichtlich KEIN scale-Parameter verwendet.
// Dadurch verwendet der Indikator die Preisskala des Hauptcharts.

//──────────────────────────────────────────────────────────────────────────────
// Gruppen und Konstanten
//──────────────────────────────────────────────────────────────────────────────

const string GROUP_CALC   = "Berechnung"
const string GROUP_VIEW   = "Darstellung"
const string GROUP_COLORS = "Farben"

const string BERLIN_TIMEZONE = "Europe/Berlin"

const int MAX_HISTORY_BARS = 5000
const int MAX_BOXES        = 500

//──────────────────────────────────────────────────────────────────────────────
// Berechnung
//──────────────────────────────────────────────────────────────────────────────

string lookbackMode = input.string(
     "Tage",
     "Lookback-Modus",
     options = ["Bars", "Tage"],
     group   = GROUP_CALC,
     tooltip = "Bars verwendet eine feste Kerzenanzahl. Tage beginnt immer um 00:00 Uhr deutscher Zeit."
)

int lookbackBars = input.int(
     300,
     "Lookback in Bars",
     minval = 20,
     maxval = 5000,
     group  = GROUP_CALC
)

int lookbackDays = input.int(
     1,
     "Lookback in Tagen",
     minval = 1,
     maxval = 365,
     group  = GROUP_CALC,
     tooltip = "1 = heute ab 00:00 Uhr Europe/Berlin. 2 = gestern ab 00:00 Uhr bis jetzt."
)

int rows = input.int(
     100,
     "Preiszonen",
     minval = 10,
     maxval = 1000,
     group  = GROUP_CALC,
     tooltip = "Bis zu 1.000 Preiszonen werden intern berechnet. Die sichtbaren Boxen werden bei Bedarf automatisch gruppiert."
)

//──────────────────────────────────────────────────────────────────────────────
// Darstellung
//──────────────────────────────────────────────────────────────────────────────

bool showHeatmap = input.bool(
     true,
     "Heatmap anzeigen",
     group = GROUP_VIEW
)

bool showProfile = input.bool(
     true,
     "Horizontales Volumenprofil anzeigen",
     group = GROUP_VIEW
)

bool showPOC = input.bool(
     true,
     "POC anzeigen",
     group = GROUP_VIEW
)

bool showBerlinStart = input.bool(
     false,
     "Beginn um 00:00 markieren",
     group = GROUP_VIEW
)

int profileOffsetBars = input.int(
     2,
     "Profilabstand zum letzten Bar",
     minval = 0,
     maxval = 50,
     group  = GROUP_VIEW,
     tooltip = "Horizontaler Abstand zwischen dem letzten Bar und dem Volumenprofil."
)

int profileWidthBars = input.int(
     40,
     "Maximale Profilbreite",
     minval = 5,
     maxval = 200,
     group  = GROUP_VIEW,
     tooltip = "Breite des größten Profilbalkens, gemessen in Chartbars."
)

int heatmapMinTransparency = input.int(
     30,
     "Heatmap: minimale Transparenz",
     minval = 0,
     maxval = 100,
     group  = GROUP_VIEW,
     tooltip = "Transparenz der stärksten Volumenzone."
)

int heatmapMaxTransparency = input.int(
     94,
     "Heatmap: maximale Transparenz",
     minval = 0,
     maxval = 100,
     group  = GROUP_VIEW,
     tooltip = "Transparenz der schwächsten Volumenzone."
)

int profileTransparency = input.int(
     20,
     "Profil-Transparenz",
     minval = 0,
     maxval = 100,
     group  = GROUP_VIEW
)

//──────────────────────────────────────────────────────────────────────────────
// Farben
//──────────────────────────────────────────────────────────────────────────────

color coldColor = input.color(
     #174EA6,
     "Niedriges Volumen",
     group = GROUP_COLORS
)

color mediumColor = input.color(
     #00BCD4,
     "Mittleres Volumen",
     group = GROUP_COLORS
)

color hotColor = input.color(
     #FFD600,
     "Hohes Volumen",
     group = GROUP_COLORS
)

color pocColor = input.color(
     #FF1744,
     "POC",
     group = GROUP_COLORS
)

color berlinStartColor = input.color(
     color.new(color.white, 50),
     "00:00-Markierung",
     group = GROUP_COLORS
)

//──────────────────────────────────────────────────────────────────────────────
// Hilfsfunktionen
//──────────────────────────────────────────────────────────────────────────────

// Begrenzt einen Preiszonenindex auf den gültigen Arraybereich.
f_binIndex(
     float price,
     float rangeLow,
     float rowSize,
     int rowCount
) =>
    int rawIndex = int(
         math.floor(
             (price - rangeLow) / rowSize
         )
    )

    math.max(
         0,
         math.min(rowCount - 1, rawIndex)
    )

// Dreistufiger Farbverlauf.
f_gradient(
     float value,
     color cold,
     color medium,
     color hot
) =>
    float normalized = math.max(
         0.0,
         math.min(1.0, value)
    )

    normalized <= 0.5
         ? color.from_gradient(
             normalized,
             0.0,
             0.5,
             cold,
             medium
         )
         : color.from_gradient(
             normalized,
             0.5,
             1.0,
             medium,
             hot
         )

// Berechnet die Transparenz der Heatmap.
f_heatTransparency(
     float intensity,
     int minimumTransparency,
     int maximumTransparency
) =>
    float normalized = math.max(
         0.0,
         math.min(1.0, intensity)
    )

    int result = int(
         math.round(
             maximumTransparency -
             (
                 maximumTransparency -
                 minimumTransparency
             ) *
             normalized
         )
    )

    math.max(
         0,
         math.min(100, result)
    )

//──────────────────────────────────────────────────────────────────────────────
// Zeichenobjekte
//──────────────────────────────────────────────────────────────────────────────

var array<box> drawingBoxes = array.new<box>()

var line pocLine          = na
var line berlinStartLine  = na

//──────────────────────────────────────────────────────────────────────────────
// Hauptberechnung
//──────────────────────────────────────────────────────────────────────────────

if barstate.islast

    //──────────────────────────────────────────────────────────────────────────
    // Alte Objekte löschen
    //──────────────────────────────────────────────────────────────────────────

    while array.size(drawingBoxes) > 0
        box.delete(
             array.pop(drawingBoxes)
        )

    if not na(pocLine)
        line.delete(pocLine)
        pocLine := na

    if not na(berlinStartLine)
        line.delete(berlinStartLine)
        berlinStartLine := na

    //──────────────────────────────────────────────────────────────────────────
    // Verfügbaren historischen Bereich bestimmen
    //──────────────────────────────────────────────────────────────────────────

    int availableBars = math.min(
         MAX_HISTORY_BARS,
         bar_index + 1
    )

    int oldestOffset = na
    int cutoffTime   = na

    //──────────────────────────────────────────────────────────────────────────
    // Lookback in Bars
    //──────────────────────────────────────────────────────────────────────────

    if lookbackMode == "Bars"

        int barsToUse = math.min(
             lookbackBars,
             availableBars
        )

        oldestOffset := barsToUse - 1

    //──────────────────────────────────────────────────────────────────────────
    // Lookback in deutschen Kalendertagen
    //──────────────────────────────────────────────────────────────────────────

    else

        int berlinYear = year(
             time,
             BERLIN_TIMEZONE
        )

        int berlinMonth = month(
             time,
             BERLIN_TIMEZONE
        )

        int berlinDay = dayofmonth(
             time,
             BERLIN_TIMEZONE
        )

        // 1 Tag:
        // Heute 00:00 Uhr bis zur letzten Kerze.
        //
        // 2 Tage:
        // Gestern 00:00 Uhr bis zur letzten Kerze.
        cutoffTime := timestamp(
             BERLIN_TIMEZONE,
             berlinYear,
             berlinMonth,
             berlinDay - (lookbackDays - 1),
             0,
             0
        )

        for barOffset = 0 to availableBars - 1

            int barOpenTime  = time[barOffset]
            int barCloseTime = time_close[barOffset]

            bool hasValidCloseTime =
                 not na(barCloseTime) and
                 barCloseTime > barOpenTime

            // Eine Bar wird berücksichtigt, wenn wenigstens ein Teil
            // zeitlich nach dem deutschen Tagesbeginn liegt.
            bool overlapsCutoff = hasValidCloseTime
                 ? barCloseTime > cutoffTime
                 : barOpenTime >= cutoffTime

            if overlapsCutoff
                oldestOffset := barOffset
            else
                break

    bool hasSelectedBars =
         not na(oldestOffset) and
         oldestOffset >= 0

    if hasSelectedBars

        //──────────────────────────────────────────────────────────────────────
        // Preisbereich aus den gewählten Bars ermitteln
        //──────────────────────────────────────────────────────────────────────

        float rangeHigh = na
        float rangeLow  = na

        for barOffset = 0 to oldestOffset

            float timeWeight = 1.0

            if lookbackMode == "Tage"

                int barOpenTime  = time[barOffset]
                int barCloseTime = time_close[barOffset]

                bool hasValidCloseTime =
                     not na(barCloseTime) and
                     barCloseTime > barOpenTime

                if hasValidCloseTime

                    int overlapStartTime = math.max(
                         barOpenTime,
                         cutoffTime
                    )

                    int overlapDuration = math.max(
                         0,
                         barCloseTime - overlapStartTime
                    )

                    int completeBarDuration =
                         barCloseTime - barOpenTime

                    timeWeight := completeBarDuration > 0
                         ? float(overlapDuration) /
                           float(completeBarDuration)
                         : 0.0

                else

                    timeWeight := barOpenTime >= cutoffTime
                         ? 1.0
                         : 0.0

            if timeWeight > 0.0

                rangeHigh := na(rangeHigh)
                     ? high[barOffset]
                     : math.max(
                         rangeHigh,
                         high[barOffset]
                     )

                rangeLow := na(rangeLow)
                     ? low[barOffset]
                     : math.min(
                         rangeLow,
                         low[barOffset]
                     )

        bool validPriceRange =
             not na(rangeHigh) and
             not na(rangeLow) and
             rangeHigh > rangeLow

        if validPriceRange

            float rowSize =
                 (rangeHigh - rangeLow) /
                 rows

            // Exakte Volumenwerte für bis zu 1.000 Preiszonen.
            array<float> volumeProfile =
                 array.new<float>(
                     rows,
                     0.0
                 )

            // Differenzarray für effizientere Verteilung auf vollständige
            // Preiszonen innerhalb einer Kerze.
            array<float> fullBinDifference =
                 array.new<float>(
                     rows + 1,
                     0.0
                 )

            //──────────────────────────────────────────────────────────────────
            // Volumen auf Preiszonen verteilen
            //──────────────────────────────────────────────────────────────────

            for barOffset = 0 to oldestOffset

                float timeWeight = 1.0

                if lookbackMode == "Tage"

                    int barOpenTime  = time[barOffset]
                    int barCloseTime = time_close[barOffset]

                    bool hasValidCloseTime =
                         not na(barCloseTime) and
                         barCloseTime > barOpenTime

                    if hasValidCloseTime

                        int overlapStartTime = math.max(
                             barOpenTime,
                             cutoffTime
                        )

                        int overlapDuration = math.max(
                             0,
                             barCloseTime - overlapStartTime
                        )

                        int completeBarDuration =
                             barCloseTime - barOpenTime

                        timeWeight := completeBarDuration > 0
                             ? float(overlapDuration) /
                               float(completeBarDuration)
                             : 0.0

                    else

                        timeWeight := barOpenTime >= cutoffTime
                             ? 1.0
                             : 0.0

                float candleLow =
                     low[barOffset]

                float candleHigh =
                     high[barOffset]

                float candleClose =
                     close[barOffset]

                float candleVolume =
                     nz(
                         volume[barOffset],
                         0.0
                     ) *
                     timeWeight

                float candleRange =
                     candleHigh -
                     candleLow

                if (
                     candleVolume > 0.0 and
                     timeWeight > 0.0
                )

                    //──────────────────────────────────────────────────────────
                    // Kerze ohne High-Low-Range
                    //──────────────────────────────────────────────────────────

                    if candleRange <= 0.0

                        int closeBin = f_binIndex(
                             candleClose,
                             rangeLow,
                             rowSize,
                             rows
                        )

                        float existingVolume =
                             array.get(
                                 volumeProfile,
                                 closeBin
                             )

                        array.set(
                             volumeProfile,
                             closeBin,
                             existingVolume +
                             candleVolume
                        )

                    //──────────────────────────────────────────────────────────
                    // Kerze mit High-Low-Range
                    //──────────────────────────────────────────────────────────

                    else

                        int firstBin = f_binIndex(
                             candleLow,
                             rangeLow,
                             rowSize,
                             rows
                        )

                        int lastBin = f_binIndex(
                             candleHigh,
                             rangeLow,
                             rowSize,
                             rows
                        )

                        float volumePerPriceUnit =
                             candleVolume /
                             candleRange

                        // Kerze befindet sich vollständig innerhalb
                        // einer Preiszone.
                        if firstBin == lastBin

                            float existingVolume =
                                 array.get(
                                     volumeProfile,
                                     firstBin
                                 )

                            array.set(
                                 volumeProfile,
                                 firstBin,
                                 existingVolume +
                                 candleVolume
                            )

                        else

                            // Erster teilweise oder vollständig
                            // berührter Bin.
                            float firstBinHigh =
                                 rangeLow +
                                 (firstBin + 1) *
                                 rowSize

                            float firstOverlap =
                                 math.max(
                                     0.0,
                                     math.min(
                                         candleHigh,
                                         firstBinHigh
                                     ) -
                                     candleLow
                                 )

                            if firstOverlap > 0.0

                                float firstVolume =
                                     volumePerPriceUnit *
                                     firstOverlap

                                float existingFirstVolume =
                                     array.get(
                                         volumeProfile,
                                         firstBin
                                     )

                                array.set(
                                     volumeProfile,
                                     firstBin,
                                     existingFirstVolume +
                                     firstVolume
                                )

                            // Letzter teilweise oder vollständig
                            // berührter Bin.
                            float lastBinLow =
                                 rangeLow +
                                 lastBin *
                                 rowSize

                            float lastOverlap =
                                 math.max(
                                     0.0,
                                     candleHigh -
                                     math.max(
                                         candleLow,
                                         lastBinLow
                                     )
                                 )

                            if lastOverlap > 0.0

                                float lastVolume =
                                     volumePerPriceUnit *
                                     lastOverlap

                                float existingLastVolume =
                                     array.get(
                                         volumeProfile,
                                         lastBin
                                     )

                                array.set(
                                     volumeProfile,
                                     lastBin,
                                     existingLastVolume +
                                     lastVolume
                                )

                            // Alle vollständig berührten Zonen dazwischen
                            // erhalten denselben Volumenbetrag.
                            if lastBin - firstBin > 1

                                int fullRangeStart =
                                     firstBin + 1

                                int fullRangeEndExclusive =
                                     lastBin

                                float fullBinVolume =
                                     volumePerPriceUnit *
                                     rowSize

                                float existingStartDifference =
                                     array.get(
                                         fullBinDifference,
                                         fullRangeStart
                                     )

                                float existingEndDifference =
                                     array.get(
                                         fullBinDifference,
                                         fullRangeEndExclusive
                                     )

                                array.set(
                                     fullBinDifference,
                                     fullRangeStart,
                                     existingStartDifference +
                                     fullBinVolume
                                )

                                array.set(
                                     fullBinDifference,
                                     fullRangeEndExclusive,
                                     existingEndDifference -
                                     fullBinVolume
                                )

            // Differenzarray auflösen.
            float runningFullBinVolume = 0.0

            for row = 0 to rows - 1

                runningFullBinVolume += array.get(
                     fullBinDifference,
                     row
                )

                if runningFullBinVolume != 0.0

                    float existingVolume =
                         array.get(
                             volumeProfile,
                             row
                         )

                    array.set(
                         volumeProfile,
                         row,
                         existingVolume +
                         runningFullBinVolume
                    )

            //──────────────────────────────────────────────────────────────────
            // Exakten POC aus allen Berechnungszonen bestimmen
            //──────────────────────────────────────────────────────────────────

            float maxCalculationVolume =
                 array.max(
                     volumeProfile
                 )

            int pocIndex =
                 array.indexof(
                     volumeProfile,
                     maxCalculationVolume
                 )

            //──────────────────────────────────────────────────────────────────
            // Verfügbare sichtbare Zonen bestimmen
            //──────────────────────────────────────────────────────────────────

            int boxesPerVisibleRow =
                 (showHeatmap ? 1 : 0) +
                 (showProfile ? 1 : 0)

            int maximumVisibleRows =
                 boxesPerVisibleRow > 0
                 ? int(
                     math.floor(
                         float(MAX_BOXES) /
                         float(boxesPerVisibleRow)
                     )
                 )
                 : 1

            int visibleRows = math.max(
                 1,
                 math.min(
                     rows,
                     maximumVisibleRows
                 )
            )

            array<float> visibleVolumes =
                 array.new<float>(
                     visibleRows,
                     0.0
                 )

            array<int> visibleFirstRows =
                 array.new<int>(
                     visibleRows,
                     0
                 )

            array<int> visibleLastRows =
                 array.new<int>(
                     visibleRows,
                     0
                 )

            //──────────────────────────────────────────────────────────────────
            // Berechnungszonen zu sichtbaren Gruppen zusammenfassen
            //──────────────────────────────────────────────────────────────────

            for visibleRow = 0 to visibleRows - 1

                int firstCalculationRow = int(
                     math.floor(
                         float(visibleRow * rows) /
                         float(visibleRows)
                     )
                )

                int nextCalculationRow = int(
                     math.floor(
                         float((visibleRow + 1) * rows) /
                         float(visibleRows)
                     )
                )

                int lastCalculationRow = math.max(
                     firstCalculationRow,
                     nextCalculationRow - 1
                )

                lastCalculationRow := math.min(
                     rows - 1,
                     lastCalculationRow
                )

                float groupedVolume = 0.0

                for calculationRow =
                     firstCalculationRow to
                     lastCalculationRow

                    groupedVolume += array.get(
                         volumeProfile,
                         calculationRow
                    )

                array.set(
                     visibleVolumes,
                     visibleRow,
                     groupedVolume
                )

                array.set(
                     visibleFirstRows,
                     visibleRow,
                     firstCalculationRow
                )

                array.set(
                     visibleLastRows,
                     visibleRow,
                     lastCalculationRow
                )

            float maxVisibleVolume =
                 array.max(
                     visibleVolumes
                 )

            //──────────────────────────────────────────────────────────────────
            // Exakte Zeitkoordinaten
            //──────────────────────────────────────────────────────────────────

            int heatmapLeftTime =
                 lookbackMode == "Tage"
                 ? cutoffTime
                 : time[oldestOffset]

            int heatmapRightTime =
                 not na(time_close) and
                 time_close > time
                 ? time_close
                 : time

            // Dauer einer aktuellen Chartkerze.
            int currentBarDuration = 60000

            if (
                 not na(time_close) and
                 time_close > time
            )

                currentBarDuration :=
                     time_close - time

            else if (
                 bar_index > 0 and
                 time > time[1]
            )

                currentBarDuration :=
                     time - time[1]

            currentBarDuration :=
                 math.max(
                     1,
                     currentBarDuration
                 )

            int profileLeftTime =
                 heatmapRightTime +
                 profileOffsetBars *
                 currentBarDuration

            //──────────────────────────────────────────────────────────────────
            // Heatmap und Profil zeichnen
            //──────────────────────────────────────────────────────────────────

            if maxVisibleVolume > 0.0

                for visibleRow = 0 to visibleRows - 1

                    int firstCalculationRow =
                         array.get(
                             visibleFirstRows,
                             visibleRow
                         )

                    int lastCalculationRow =
                         array.get(
                             visibleLastRows,
                             visibleRow
                         )

                    float binLow =
                         rangeLow +
                         firstCalculationRow *
                         rowSize

                    float binHigh =
                         rangeLow +
                         (lastCalculationRow + 1) *
                         rowSize

                    // Obere Grenze exakt auf den berechneten
                    // höchsten Preis begrenzen.
                    binHigh := math.min(
                         rangeHigh,
                         binHigh
                    )

                    float binVolume =
                         array.get(
                             visibleVolumes,
                             visibleRow
                         )

                    float intensity =
                         binVolume /
                         maxVisibleVolume

                    bool containsPOC =
                         pocIndex >= firstCalculationRow and
                         pocIndex <= lastCalculationRow

                    color rowColor =
                         containsPOC
                         ? pocColor
                         : f_gradient(
                             intensity,
                             coldColor,
                             mediumColor,
                             hotColor
                         )

                    int currentHeatTransparency =
                         f_heatTransparency(
                             intensity,
                             heatmapMinTransparency,
                             heatmapMaxTransparency
                         )

                    //──────────────────────────────────────────────────────────
                    // Heatmap
                    //
                    // X-Werte = echte UNIX-Zeitstempel
                    // Y-Werte = echte Kurswerte
                    //──────────────────────────────────────────────────────────

                    if (
                         showHeatmap and
                         binVolume > 0.0
                    )

                        box heatBox = box.new(
                             left          = heatmapLeftTime,
                             top           = binHigh,
                             right         = heatmapRightTime,
                             bottom        = binLow,
                             xloc          = xloc.bar_time,
                             border_color  = color.new(
                                 rowColor,
                                 100
                             ),
                             border_width  = 1,
                             bgcolor       = color.new(
                                 rowColor,
                                 currentHeatTransparency
                             ),
                             force_overlay = true
                        )

                        array.push(
                             drawingBoxes,
                             heatBox
                        )

                    //──────────────────────────────────────────────────────────
                    // Horizontales Volumenprofil
                    //
                    // Auch hier sind top und bottom echte Kurswerte.
                    //──────────────────────────────────────────────────────────

                    if (
                         showProfile and
                         binVolume > 0.0
                    )

                        int currentWidthBars = math.max(
                             1,
                             int(
                                 math.round(
                                     profileWidthBars *
                                     intensity
                                 )
                             )
                        )

                        int profileRightTime =
                             profileLeftTime +
                             currentWidthBars *
                             currentBarDuration

                        box profileBox = box.new(
                             left          = profileLeftTime,
                             top           = binHigh,
                             right         = profileRightTime,
                             bottom        = binLow,
                             xloc          = xloc.bar_time,
                             border_color  = color.new(
                                 rowColor,
                                 100
                             ),
                             border_width  = 1,
                             bgcolor       = color.new(
                                 rowColor,
                                 profileTransparency
                             ),
                             force_overlay = true
                        )

                        array.push(
                             drawingBoxes,
                             profileBox
                        )

                //──────────────────────────────────────────────────────────────
                // Exakte POC-Linie
                //──────────────────────────────────────────────────────────────

                if (
                     showPOC and
                     pocIndex >= 0 and
                     maxCalculationVolume > 0.0
                )

                    float pocPrice =
                         rangeLow +
                         (pocIndex + 0.5) *
                         rowSize

                    pocLine := line.new(
                         x1            = heatmapLeftTime,
                         y1            = pocPrice,
                         x2            = heatmapRightTime,
                         y2            = pocPrice,
                         xloc          = xloc.bar_time,
                         extend        = extend.none,
                         color         = pocColor,
                         style         = line.style_solid,
                         width         = 2,
                         force_overlay = true
                    )

                //──────────────────────────────────────────────────────────────
                // Deutsche 00:00-Uhr-Grenze
                //──────────────────────────────────────────────────────────────

                if (
                     lookbackMode == "Tage" and
                     showBerlinStart
                )

                    berlinStartLine := line.new(
                         x1            = cutoffTime,
                         y1            = rangeLow,
                         x2            = cutoffTime,
                         y2            = rangeHigh,
                         xloc          = xloc.bar_time,
                         extend        = extend.none,
                         color         = berlinStartColor,
                         style         = line.style_dashed,
                         width         = 1,
                         force_overlay = true
                    )
````
