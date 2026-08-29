<!-- tradingview-pine-id: PUB;387ac5d39fe64276aecbddc569605eeb -->
<!-- tradingviewscripts-format: 1 -->
# MAUI Open/Close Body Gaps

Source: https://www.tradingview.com/script/MHeB5qgV/

## Description

**MTF Open Body Gaps**

This indicator identifies open gaps between the closing price of one candle body and the opening price of the following candle body.

A bullish body gap is detected when a bearish candle is followed by a bullish candle that opens above the previous candle’s close.

A bearish body gap is detected when a bullish candle is followed by a bearish candle that opens below the previous candle’s close.

The indicator supports multiple timeframes and can display gaps from:

M1, M2, M3, M4, M5, M10, M15, M30, M45, H1, H2, H3, H4 and Daily.

The current chart timeframe can also be enabled separately.

Only unfilled body gaps remain visible. A gap is automatically removed once a later candle body reaches or fills the relevant gap level.

The minimum and maximum gap size can be defined in ticks, allowing small or unusually large gaps to be filtered out.

**Features**

• Multi-timeframe body gap detection
• Bullish and bearish gap recognition
• Minimum gap size in ticks
• Maximum gap size in ticks
• Automatic removal of filled gaps
• Adjustable colors, line style and line width
• Adjustable maximum number of open gaps
• Protection against duplicate signals from identical timeframes

This indicator focuses exclusively on gaps between candle bodies. Candle wicks are not used to create or fill a gap.

---

## Source Code

````pine
//@version=6
indicator("MAUI Open/Close Body Gaps", shorttitle = "MAUI Open/Close Body Gaps", overlay = true, max_lines_count = 500)

// =====================================================================
// EINSTELLUNGEN
// =====================================================================

const string GROUP_TF = "Timeframes"
const string GROUP_FILTER = "Filter"
const string GROUP_STYLE = "Darstellung"

// Aktueller Chart-Timeframe

bool showCurrentChart = input.bool(
     true,
     "Aktueller Chart",
     group = GROUP_TF
)

// Minuten

bool showM1 = input.bool(
     true,
     "M1",
     group = GROUP_TF,
     inline = "m1"
)

bool showM2 = input.bool(
     false,
     "M2",
     group = GROUP_TF,
     inline = "m1"
)

bool showM3 = input.bool(
     false,
     "M3",
     group = GROUP_TF,
     inline = "m1"
)

bool showM4 = input.bool(
     false,
     "M4",
     group = GROUP_TF,
     inline = "m1"
)

bool showM5 = input.bool(
     true,
     "M5",
     group = GROUP_TF,
     inline = "m1"
)

bool showM10 = input.bool(
     false,
     "M10",
     group = GROUP_TF,
     inline = "m2"
)

bool showM15 = input.bool(
     true,
     "M15",
     group = GROUP_TF,
     inline = "m2"
)

bool showM30 = input.bool(
     false,
     "M30",
     group = GROUP_TF,
     inline = "m2"
)

bool showM45 = input.bool(
     false,
     "M45",
     group = GROUP_TF,
     inline = "m2"
)

// Stunden

bool showH1 = input.bool(
     true,
     "H1",
     group = GROUP_TF,
     inline = "h1"
)

bool showH2 = input.bool(
     false,
     "H2",
     group = GROUP_TF,
     inline = "h1"
)

bool showH3 = input.bool(
     false,
     "H3",
     group = GROUP_TF,
     inline = "h1"
)

bool showH4 = input.bool(
     true,
     "H4",
     group = GROUP_TF,
     inline = "h1"
)

// Daily

bool showD = input.bool(
     true,
     "D",
     group = GROUP_TF
)

// =====================================================================
// FILTER
// =====================================================================

int minimumGapTicks = input.int(
     1,
     "Minimale Lücke in Ticks",
     minval = 1,
     group = GROUP_FILTER
)

int maximumGapTicks = input.int(
     100,
     "Maximale Lücke in Ticks",
     minval = 1,
     group = GROUP_FILTER
)

int maximumOpenGaps = input.int(
     200,
     "Maximale Anzahl offener Lücken",
     minval = 1,
     maxval = 250,
     group = GROUP_FILTER
)

// =====================================================================
// DARSTELLUNG
// =====================================================================

color bullishGapColor = input.color(
     color.aqua,
     "Bullische Lücke",
     group = GROUP_STYLE,
     inline = "colors"
)

color bearishGapColor = input.color(
     color.aqua,
     "Bärische Lücke",
     group = GROUP_STYLE,
     inline = "colors"
)

int gapLineWidth = input.int(
     1,
     "Linienstärke",
     minval = 1,
     maxval = 4,
     group = GROUP_STYLE
)

string gapLineStyleInput = input.string(
     "Durchgezogen",
     "Linienart",
     options = [
         "Durchgezogen",
         "Gestrichelt",
         "Gepunktet"
     ],
     group = GROUP_STYLE
)

gapLineStyle =
     gapLineStyleInput == "Gestrichelt" ?
     line.style_dashed :
     gapLineStyleInput == "Gepunktet" ?
     line.style_dotted :
     line.style_solid

// =====================================================================
// ARRAYS FÜR OFFENE LÜCKEN
// =====================================================================

var line[] gapUpperLines = array.new_line()
var line[] gapLowerLines = array.new_line()

var float[] gapUpperPrices = array.new_float()
var float[] gapLowerPrices = array.new_float()

var int[] gapDirections = array.new_int()
var int[] gapTimeframeIds = array.new_int()

// Richtung:
//
//  1 = bullische Lücke
// -1 = bärische Lücke

// =====================================================================
// LÜCKE AN EINEM ARRAY-INDEX LÖSCHEN
// =====================================================================

f_deleteGap(int gapIndex) =>
    line upperLine = array.get(
         gapUpperLines,
         gapIndex
     )

    line lowerLine = array.get(
         gapLowerLines,
         gapIndex
     )

    line.delete(upperLine)
    line.delete(lowerLine)

    array.remove(
         gapUpperLines,
         gapIndex
     )

    array.remove(
         gapLowerLines,
         gapIndex
     )

    array.remove(
         gapUpperPrices,
         gapIndex
     )

    array.remove(
         gapLowerPrices,
         gapIndex
     )

    array.remove(
         gapDirections,
         gapIndex
     )

    array.remove(
         gapTimeframeIds,
         gapIndex
     )

    true

// =====================================================================
// ÄLTESTE LÜCKE LÖSCHEN
// =====================================================================

f_deleteOldestGap() =>
    if array.size(gapUpperLines) > 0
        f_deleteGap(0)

    true

// =====================================================================
// NEUE LÜCKE ERSTELLEN
// =====================================================================

f_createGap(
     int gapTimeframeId,
     int startTime,
     int endTime,
     float upperPrice,
     float lowerPrice,
     int direction
 ) =>

    color selectedColor =
         direction == 1 ?
         bullishGapColor :
         bearishGapColor

    line upperLine = line.new(
         x1 = startTime,
         y1 = upperPrice,
         x2 = endTime,
         y2 = upperPrice,
         xloc = xloc.bar_time,
         extend = extend.right,
         color = selectedColor,
         style = gapLineStyle,
         width = gapLineWidth
     )

    line lowerLine = line.new(
         x1 = startTime,
         y1 = lowerPrice,
         x2 = endTime,
         y2 = lowerPrice,
         xloc = xloc.bar_time,
         extend = extend.right,
         color = selectedColor,
         style = gapLineStyle,
         width = gapLineWidth
     )

    array.push(
         gapUpperLines,
         upperLine
     )

    array.push(
         gapLowerLines,
         lowerLine
     )

    array.push(
         gapUpperPrices,
         upperPrice
     )

    array.push(
         gapLowerPrices,
         lowerPrice
     )

    array.push(
         gapDirections,
         direction
     )

    array.push(
         gapTimeframeIds,
         gapTimeframeId
     )

    if array.size(gapUpperLines) > maximumOpenGaps
        f_deleteOldestGap()

    true

// =====================================================================
// GEFÜLLTE LÜCKEN EINES TIMEFRAMES LÖSCHEN
// =====================================================================

f_deleteFilledGaps(
     int selectedTimeframeId,
     float candleBodyLow,
     float candleBodyHigh
 ) =>

    int gapIndex =
         array.size(gapUpperLines) - 1

    while gapIndex >= 0
        int storedTimeframeId =
             array.get(
                 gapTimeframeIds,
                 gapIndex
             )

        if storedTimeframeId == selectedTimeframeId
            int direction =
                 array.get(
                     gapDirections,
                     gapIndex
                 )

            float upperPrice =
                 array.get(
                     gapUpperPrices,
                     gapIndex
                 )

            float lowerPrice =
                 array.get(
                     gapLowerPrices,
                     gapIndex
                 )

            // Bullische Lücke:
            // Gelöscht, sobald ein späterer Kerzenkörper
            // die untere Linie erreicht.
            //
            // Bärische Lücke:
            // Gelöscht, sobald ein späterer Kerzenkörper
            // die obere Linie erreicht.

            bool gapFilled =
                 direction == 1 ?
                 candleBodyLow <= lowerPrice :
                 candleBodyHigh >= upperPrice

            if gapFilled
                f_deleteGap(gapIndex)

        gapIndex -= 1

    true

// =====================================================================
// TIMEFRAME AUSWERTEN
// =====================================================================

f_processTimeframe(
     string selectedTimeframe,
     int selectedTimeframeId,
     bool enabled
 ) =>

    [currentOpen, currentClose, previousOpen, previousClose, currentTime, currentTimeClose] = request.security(
         syminfo.tickerid,
         selectedTimeframe,
         [
             open[1],
             close[1],
             open[2],
             close[2],
             time[1],
             time_close[1]
         ],
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_on
     )

    int chartTimeframeSeconds =
         timeframe.in_seconds()

    int requestedTimeframeSeconds =
         timeframe.in_seconds(
             selectedTimeframe
         )

    bool timeframeAllowed =
         requestedTimeframeSeconds >=
         chartTimeframeSeconds

    bool newCompletedCandle =
         not na(currentTime) and
         (
             na(currentTime[1]) or
             currentTime != currentTime[1]
         )

    if enabled and timeframeAllowed and newCompletedCandle
        float currentBodyLow =
             math.min(
                 currentOpen,
                 currentClose
             )

        float currentBodyHigh =
             math.max(
                 currentOpen,
                 currentClose
             )

        // Zuerst ältere, inzwischen gefüllte Lücken löschen.

        f_deleteFilledGaps(
             selectedTimeframeId,
             currentBodyLow,
             currentBodyHigh
         )

        float minimumGapSize =
             minimumGapTicks *
             syminfo.mintick

        float maximumGapSize =
             maximumGapTicks *
             syminfo.mintick

        // -------------------------------------------------------------
        // BULLISCHE LÜCKE WIE BILD 1
        //
        // Vorherige Kerze ist bärisch.
        // Aktuelle Kerze ist bullisch.
        // Aktuelle Kerze eröffnet über dem vorherigen Schlusskurs.
        // -------------------------------------------------------------

        bool previousCandleBearish =
             previousClose <
             previousOpen

        bool currentCandleBullish =
             currentClose >
             currentOpen

        float bullishGapSize =
             currentOpen -
             previousClose

        bool validBullishGap =
             previousCandleBearish and
             currentCandleBullish and
             currentOpen > previousClose and
             bullishGapSize >= minimumGapSize and
             bullishGapSize <= maximumGapSize

        // -------------------------------------------------------------
        // BÄRISCHE LÜCKE WIE BILD 2
        //
        // Vorherige Kerze ist bullisch.
        // Aktuelle Kerze ist bärisch.
        // Aktuelle Kerze eröffnet unter dem vorherigen Schlusskurs.
        // -------------------------------------------------------------

        bool previousCandleBullish =
             previousClose >
             previousOpen

        bool currentCandleBearish =
             currentClose <
             currentOpen

        float bearishGapSize =
             previousClose -
             currentOpen

        bool validBearishGap =
             previousCandleBullish and
             currentCandleBearish and
             currentOpen < previousClose and
             bearishGapSize >= minimumGapSize and
             bearishGapSize <= maximumGapSize

        if validBullishGap
            f_createGap(
                 selectedTimeframeId,
                 currentTime,
                 currentTimeClose,
                 currentOpen,
                 previousClose,
                 1
             )

        if validBearishGap
            f_createGap(
                 selectedTimeframeId,
                 currentTime,
                 currentTimeClose,
                 previousClose,
                 currentOpen,
                 -1
             )

    true

// =====================================================================
// DOPPELTE DARSTELLUNG VERHINDERN
//
// Ist "Aktueller Chart" aktiviert, wird ein identischer fest
// ausgewählter Timeframe nicht noch einmal berechnet.
// =====================================================================

f_useFixedTimeframe(
     string selectedTimeframe,
     bool enabled
 ) =>

    int selectedSeconds =
         timeframe.in_seconds(
             selectedTimeframe
         )

    int currentChartSeconds =
         timeframe.in_seconds()

    bool sameAsCurrentChart =
         selectedSeconds ==
         currentChartSeconds

    enabled and
     (
         not showCurrentChart or
         not sameAsCurrentChart
     )

// =====================================================================
// AKTUELLEN CHART-TIMEFRAME BERECHNEN
// =====================================================================

f_processTimeframe(
     timeframe.period,
     0,
     showCurrentChart
)

// =====================================================================
// FESTE TIMEFRAMES BERECHNEN
// =====================================================================

// Minuten

f_processTimeframe(
     "1",
     1,
     f_useFixedTimeframe(
         "1",
         showM1
     )
)

f_processTimeframe(
     "2",
     2,
     f_useFixedTimeframe(
         "2",
         showM2
     )
)

f_processTimeframe(
     "3",
     3,
     f_useFixedTimeframe(
         "3",
         showM3
     )
)

f_processTimeframe(
     "4",
     4,
     f_useFixedTimeframe(
         "4",
         showM4
     )
)

f_processTimeframe(
     "5",
     5,
     f_useFixedTimeframe(
         "5",
         showM5
     )
)

f_processTimeframe(
     "10",
     10,
     f_useFixedTimeframe(
         "10",
         showM10
     )
)

f_processTimeframe(
     "15",
     15,
     f_useFixedTimeframe(
         "15",
         showM15
     )
)

f_processTimeframe(
     "30",
     30,
     f_useFixedTimeframe(
         "30",
         showM30
     )
)

f_processTimeframe(
     "45",
     45,
     f_useFixedTimeframe(
         "45",
         showM45
     )
)

// Stunden

f_processTimeframe(
     "60",
     60,
     f_useFixedTimeframe(
         "60",
         showH1
     )
)

f_processTimeframe(
     "120",
     120,
     f_useFixedTimeframe(
         "120",
         showH2
     )
)

f_processTimeframe(
     "180",
     180,
     f_useFixedTimeframe(
         "180",
         showH3
     )
)

f_processTimeframe(
     "240",
     240,
     f_useFixedTimeframe(
         "240",
         showH4
     )
)

// Daily

f_processTimeframe(
     "1D",
     1440,
     f_useFixedTimeframe(
         "1D",
         showD
     )
)
````
