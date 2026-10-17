# Major Historical S&R Zones

- url: https://www.tradingview.com/script/u11NqO82-Major-Historical-S-R-Zones/
- type: indicator
- pine_id: PUB;fd288287441e4f339465fabab33adaaa
- version: 1.0

## Description

[u][b]Major Historical Support & Resistance Zones[/b][/u]

Major Historical Support & Resistance Zones is designed to objectively identify and rank the most significant historical support and resistance areas on any market or timeframe. Rather than relying on manually drawn horizontal lines, the indicator automatically analyses historical price action, groups significant reactions into zones, and scores each zone based on its historical importance.

The indicator looks for meaningful pivot highs and lows, measures the strength of the subsequent price reaction using ATR (Average True Range), evaluates rejection quality through wick analysis, and clusters nearby reactions into a single support or resistance zone. When multiple significant reactions occur around the same price level, the zone becomes stronger and receives a higher score.

Unlike traditional support and resistance indicators that simply draw every swing high and low, this indicator attempts to filter out market noise and highlight only the price areas that have repeatedly influenced market direction.

[u][b]Features[/b][/u]

* Automatically detects major historical support and resistance zones.
* Clusters multiple historical reactions into a single zone.
* Scores each zone based on reaction quality and historical significance.
* Counts the number of independent reactions ("Hits") at each level.
* Identifies Support/Resistance Flip zones where price has historically acted as both support and resistance.
* Adjustable ATR sensitivity and clustering distance.
* Built-in colour and scoring guide that can be enabled or disabled from the settings.

[u][b]Colour Guide[/b][/u]

🟩 Green Zone

* Price is currently above the zone.
* The zone is acting as historical support.

🟥 Red Zone

* Price is currently below the zone.
* The zone is acting as historical resistance.

🟨 Orange Zone

* Price is currently trading inside the historical zone.
* This represents a decision area where the market is testing historical support or resistance.

[u][b]Understanding the Score[/b][/u]

Each zone receives a strength score based on:

* Size of the historical reaction.
* Quality of price rejection (wick analysis).
* Number of independent reactions.
* Support/Resistance Flip bonus.

General interpretation:

* 0–3 = Weak
* 3–5 = Minor
* 5–7 = Good
* 7–10 = Strong
* 10–15 = Very Strong
* 15+ = Exceptional

Higher scores indicate areas where price has historically shown stronger reactions.

[u][b]Understanding Hits[/b][/u]

Hits represent the number of separate significant reactions that occurred within the zone.

General guide:

* 1 = Single historical reaction
* 2 = Confirmed level
* 3 = Strong level
* 4–5 = Very strong level
* 6+ = Major historical level

More hits generally indicate greater historical recognition of that price area.

[u][b]S/R Flip[/b][/u]

When a zone displays S/R Flip, it means that the same price area has historically acted as both:

* Support
* Resistance

These zones often represent some of the strongest historical price levels because market participants have repeatedly recognised them from both directions.

[u][b]Suggested Workflow[/b][/u]

For the best results:

1. Open the Weekly chart to identify the strongest long-term support and resistance zones.
2. Switch to the Daily chart to refine those major levels.
3. Use the 4H, 8H, or 12H chart for additional precision.
4. Execute trades using your preferred lower timeframe confirmation.

This top-down approach helps maintain focus on the most significant historical levels before refining entries.

[u][b]Inputs[/b][/u]

The indicator provides several adjustable settings:

* Pivot Strength – Controls how significant a swing must be before it is considered.
* ATR Length – Used to normalise reaction size across different markets.
* Minimum Reaction ATR – Filters out weak reactions.
* Cluster Distance ATR – Controls how close reactions must be before they are grouped together.
* Zone Width ATR – Determines the thickness of each support/resistance zone.
* Minimum Hits – Minimum number of reactions required before displaying a zone.
* Minimum Score – Minimum strength score required before displaying a zone.
* Display Options – Toggle labels and the built-in legend on or off.

[u][b]Best Practices[/b][/u]

This indicator is designed to identify historically important price zones, not generate buy or sell signals.

The strongest trading opportunities often occur when:

* High-scoring zones align with your own market structure analysis.
* Higher timeframe zones overlap with lower timeframe confirmations.
* Price shows clear rejection or acceptance at the identified historical levels.

As with all technical analysis tools, this indicator should be used alongside sound risk management and your broader trading methodology rather than in isolation.

## Source Code

````pine
//@version=6
indicator(
     "Major Historical S&R Zones",
     shorttitle = "Major S&R",
     overlay = true,
     max_boxes_count = 100
)

//=============================================================================
// SETTINGS
//=============================================================================

groupDetection = "Detection"

pivotLength = input.int(
     8,
     "Pivot strength",
     minval = 2,
     group = groupDetection
)

atrLength = input.int(
     14,
     "ATR length",
     minval = 1,
     group = groupDetection
)

minimumReactionATR = input.float(
     1.25,
     "Minimum reaction size (ATR)",
     minval = 0.25,
     step = 0.25,
     group = groupDetection
)

minimumBarsBetweenHits = input.int(
     10,
     "Minimum bars between reactions",
     minval = 1,
     group = groupDetection
)

//=============================================================================
// ZONE SETTINGS
//=============================================================================

groupZones = "Zones"

clusterDistanceATR = input.float(
     0.50,
     "Combine levels within (ATR)",
     minval = 0.10,
     step = 0.05,
     group = groupZones
)

zoneWidthATR = input.float(
     0.20,
     "Zone half-width (ATR)",
     minval = 0.05,
     step = 0.05,
     group = groupZones
)

minimumHits = input.int(
     2,
     "Minimum separate reactions",
     minval = 1,
     group = groupZones
)

minimumScore = input.float(
     5.0,
     "Minimum major-zone score",
     minval = 1.0,
     step = 0.5,
     group = groupZones
)

maximumZones = input.int(
     30,
     "Maximum stored zones",
     minval = 5,
     maxval = 80,
     group = groupZones
)

//=============================================================================
// DISPLAY SETTINGS
//=============================================================================

groupDisplay = "Display"

showLabelsInBox = input.bool(
     true,
     "Show score and hit count",
     group = groupDisplay
)

showLegend = input.bool(
     true,
     "Show colour and rating guide",
     group = groupDisplay
)

supportColor = input.color(
     color.rgb(0, 150, 100),
     "Support colour",
     group = groupDisplay
)

resistanceColor = input.color(
     color.rgb(210, 55, 55),
     "Resistance colour",
     group = groupDisplay
)

insideZoneColor = input.color(
     color.rgb(220, 150, 20),
     "Price inside zone colour",
     group = groupDisplay
)

zoneTransparency = input.int(
     85,
     "Zone transparency",
     minval = 0,
     maxval = 100,
     group = groupDisplay
)

//=============================================================================
// CORE CALCULATIONS
//=============================================================================

atr = ta.atr(atrLength)

pivotHigh = ta.pivothigh(
     high,
     pivotLength,
     pivotLength
)

pivotLow = ta.pivotlow(
     low,
     pivotLength,
     pivotLength
)

//=============================================================================
// STORAGE ARRAYS
//=============================================================================

var zonePrices = array.new_float()
var zoneATRs = array.new_float()
var zoneScores = array.new_float()

var zoneHits = array.new_int()
var zoneSupportHits = array.new_int()
var zoneResistanceHits = array.new_int()

var zoneFirstBars = array.new_int()
var zoneLastBars = array.new_int()

var zoneBoxes = array.new_box()

//=============================================================================
// FIND NEAREST EXISTING ZONE
//=============================================================================

findNearestZone(float price, float eventATR) =>
    int result = -1
    float nearestDistance = 10000000000.0
    int count = array.size(zonePrices)

    if count > 0
        for i = 0 to count - 1
            float storedPrice = array.get(zonePrices, i)
            float storedATR = array.get(zoneATRs, i)

            float allowedDistance =
                 math.max(eventATR, storedATR) *
                 clusterDistanceATR

            float distance =
                 math.abs(price - storedPrice)

            if distance <= allowedDistance and distance < nearestDistance
                result := i
                nearestDistance := distance

    result

//=============================================================================
// REMOVE OLDEST ZONE
//=============================================================================

removeOldestZone() =>
    bool removed = false

    if array.size(zonePrices) > maximumZones
        box oldestBox = array.shift(zoneBoxes)

        if not na(oldestBox)
            box.delete(oldestBox)

        array.shift(zonePrices)
        array.shift(zoneATRs)
        array.shift(zoneScores)

        array.shift(zoneHits)
        array.shift(zoneSupportHits)
        array.shift(zoneResistanceHits)

        array.shift(zoneFirstBars)
        array.shift(zoneLastBars)

        removed := true

    removed

//=============================================================================
// REGISTER REACTION
//=============================================================================

registerReaction(
     float reactionPrice,
     float eventATR,
     float eventScore,
     bool isSupport,
     int reactionBar
) =>
    bool reactionRegistered = false

    int zoneIndex =
         findNearestZone(
             reactionPrice,
             eventATR
         )

    if zoneIndex == -1
        array.push(zonePrices, reactionPrice)
        array.push(zoneATRs, eventATR)
        array.push(zoneScores, eventScore)

        array.push(zoneHits, 1)
        array.push(zoneSupportHits, isSupport ? 1 : 0)
        array.push(zoneResistanceHits, isSupport ? 0 : 1)

        array.push(zoneFirstBars, reactionBar)
        array.push(zoneLastBars, reactionBar)

        array.push(zoneBoxes, na)

        removeOldestZone()

        reactionRegistered := true

    else
        int lastReactionBar =
             array.get(
                 zoneLastBars,
                 zoneIndex
             )

        bool separateReaction =
             reactionBar - lastReactionBar >=
             minimumBarsBetweenHits

        if separateReaction
            int oldHits =
                 array.get(
                     zoneHits,
                     zoneIndex
                 )

            float oldPrice =
                 array.get(
                     zonePrices,
                     zoneIndex
                 )

            float oldATR =
                 array.get(
                     zoneATRs,
                     zoneIndex
                 )

            float updatedPrice =
                 (
                     oldPrice * oldHits +
                     reactionPrice
                 ) /
                 (
                     oldHits + 1
                 )

            float updatedATR =
                 (
                     oldATR * oldHits +
                     eventATR
                 ) /
                 (
                     oldHits + 1
                 )

            array.set(
                 zonePrices,
                 zoneIndex,
                 updatedPrice
            )

            array.set(
                 zoneATRs,
                 zoneIndex,
                 updatedATR
            )

            array.set(
                 zoneScores,
                 zoneIndex,
                 array.get(zoneScores, zoneIndex) +
                 eventScore
            )

            array.set(
                 zoneHits,
                 zoneIndex,
                 oldHits + 1
            )

            if isSupport
                array.set(
                     zoneSupportHits,
                     zoneIndex,
                     array.get(zoneSupportHits, zoneIndex) + 1
                )
            else
                array.set(
                     zoneResistanceHits,
                     zoneIndex,
                     array.get(zoneResistanceHits, zoneIndex) + 1
                )

            array.set(
                 zoneLastBars,
                 zoneIndex,
                 reactionBar
            )

            reactionRegistered := true

    reactionRegistered

//=============================================================================
// PROCESS PIVOT LOWS
//=============================================================================

if not na(pivotLow)
    int reactionBar =
         bar_index - pivotLength

    float eventATR =
         atr[pivotLength]

    float candleHigh =
         high[pivotLength]

    float candleLow =
         low[pivotLength]

    float candleOpen =
         open[pivotLength]

    float candleClose =
         close[pivotLength]

    float candleRange =
         candleHigh - candleLow

    float lowerBody =
         math.min(
             candleOpen,
             candleClose
         )

    float lowerWick =
         lowerBody - candleLow

    float wickRatio =
         candleRange > 0
         ? lowerWick / candleRange
         : 0.0

    float highestAfterPivot =
         ta.highest(
             high,
             pivotLength + 1
         )

    float reactionDistance =
         highestAfterPivot - pivotLow

    float reactionSizeATR =
         eventATR > 0
         ? reactionDistance / eventATR
         : 0.0

    bool validReaction =
         not na(eventATR) and
         reactionSizeATR >= minimumReactionATR

    if validReaction
        float reactionScore =
             1.0 +
             math.min(reactionSizeATR, 4.0) +
             wickRatio * 2.0

        registerReaction(
             pivotLow,
             eventATR,
             reactionScore,
             true,
             reactionBar
        )

//=============================================================================
// PROCESS PIVOT HIGHS
//=============================================================================

if not na(pivotHigh)
    int reactionBar =
         bar_index - pivotLength

    float eventATR =
         atr[pivotLength]

    float candleHigh =
         high[pivotLength]

    float candleLow =
         low[pivotLength]

    float candleOpen =
         open[pivotLength]

    float candleClose =
         close[pivotLength]

    float candleRange =
         candleHigh - candleLow

    float upperBody =
         math.max(
             candleOpen,
             candleClose
         )

    float upperWick =
         candleHigh - upperBody

    float wickRatio =
         candleRange > 0
         ? upperWick / candleRange
         : 0.0

    float lowestAfterPivot =
         ta.lowest(
             low,
             pivotLength + 1
         )

    float reactionDistance =
         pivotHigh - lowestAfterPivot

    float reactionSizeATR =
         eventATR > 0
         ? reactionDistance / eventATR
         : 0.0

    bool validReaction =
         not na(eventATR) and
         reactionSizeATR >= minimumReactionATR

    if validReaction
        float reactionScore =
             1.0 +
             math.min(reactionSizeATR, 4.0) +
             wickRatio * 2.0

        registerReaction(
             pivotHigh,
             eventATR,
             reactionScore,
             false,
             reactionBar
        )

//=============================================================================
// DRAW MAJOR ZONES
//=============================================================================

int zoneCount =
     array.size(zonePrices)

if zoneCount > 0
    for i = 0 to zoneCount - 1
        float centre =
             array.get(
                 zonePrices,
                 i
             )

        float storedATR =
             array.get(
                 zoneATRs,
                 i
             )

        float score =
             array.get(
                 zoneScores,
                 i
             )

        int hits =
             array.get(
                 zoneHits,
                 i
             )

        int supportHits =
             array.get(
                 zoneSupportHits,
                 i
             )

        int resistanceHits =
             array.get(
                 zoneResistanceHits,
                 i
             )

        int firstBar =
             array.get(
                 zoneFirstBars,
                 i
             )

        bool roleReversal =
             supportHits > 0 and
             resistanceHits > 0

        float finalScore =
             score +
             (
                 roleReversal
                 ? 2.0
                 : 0.0
             )

        bool majorZone =
             hits >= minimumHits and
             finalScore >= minimumScore

        float halfWidth =
             storedATR *
             zoneWidthATR

        float zoneTop =
             centre + halfWidth

        float zoneBottom =
             centre - halfWidth

        color currentColor =
             close > zoneTop
             ? supportColor
             : close < zoneBottom
             ? resistanceColor
             : insideZoneColor

        box currentBox =
             array.get(
                 zoneBoxes,
                 i
             )

        if majorZone
            string zoneText = ""

            if showLabelsInBox
                zoneText :=
                     "Score " +
                     str.tostring(finalScore, "#.0") +
                     " | Hits " +
                     str.tostring(hits) +
                     (
                         roleReversal
                         ? " | S/R flip"
                         : ""
                     )

            if na(currentBox)
                currentBox :=
                     box.new(
                         left = firstBar,
                         top = zoneTop,
                         right = bar_index,
                         bottom = zoneBottom,
                         xloc = xloc.bar_index,
                         extend = extend.right,
                         border_color = currentColor,
                         border_width = 2,
                         bgcolor = color.new(
                             currentColor,
                             zoneTransparency
                         )
                     )

                array.set(
                     zoneBoxes,
                     i,
                     currentBox
                 )

            else
                box.set_left(
                     currentBox,
                     firstBar
                 )

                box.set_right(
                     currentBox,
                     bar_index
                 )

                box.set_top(
                     currentBox,
                     zoneTop
                 )

                box.set_bottom(
                     currentBox,
                     zoneBottom
                 )

                box.set_border_color(
                     currentBox,
                     currentColor
                 )

                box.set_bgcolor(
                     currentBox,
                     color.new(
                         currentColor,
                         zoneTransparency
                     )
                 )

            box.set_text(
                 currentBox,
                 zoneText
             )

            box.set_text_color(
                 currentBox,
                 currentColor
             )

            box.set_text_size(
                 currentBox,
                 size.tiny
             )

            box.set_text_halign(
                 currentBox,
                 text.align_right
             )

        else
            if not na(currentBox)
                box.delete(currentBox)

                array.set(
                     zoneBoxes,
                     i,
                     na
                )

//=============================================================================
// TOP-RIGHT GUIDE
//=============================================================================

var table legendTable = table.new(
     position.top_right,
     2,
     18,
     border_width = 1,
     frame_width = 1,
     frame_color = color.gray
)

if barstate.islast
    table.clear(
         legendTable,
         0,
         0,
         1,
         17
    )

    if showLegend
        color legendBackground =
             color.new(
                 color.black,
                 15
             )

        color legendText =
             color.white

        table.cell(
             legendTable,
             0,
             0,
             "MAJOR S&R GUIDE",
             bgcolor = legendBackground,
             text_color = legendText,
             text_size = size.small
        )

        table.merge_cells(
             legendTable,
             0,
             0,
             1,
             0
        )

        table.cell(
             legendTable,
             0,
             1,
             "GREEN",
             bgcolor = supportColor,
             text_color = color.white,
             text_size = size.tiny
        )

        table.cell(
             legendTable,
             1,
             1,
             "Support",
             bgcolor = legendBackground,
             text_color = legendText,
             text_size = size.tiny
        )

        table.cell(
             legendTable,
             0,
             2,
             "RED",
             bgcolor = resistanceColor,
             text_color = color.white,
             text_size = size.tiny
        )

        table.cell(
             legendTable,
             1,
             2,
             "Resistance",
             bgcolor = legendBackground,
             text_color = legendText,
             text_size = size.tiny
        )

        table.cell(
             legendTable,
             0,
             3,
             "ORANGE",
             bgcolor = insideZoneColor,
             text_color = color.white,
             text_size = size.tiny
        )

        table.cell(
             legendTable,
             1,
             3,
             "Inside zone",
             bgcolor = legendBackground,
             text_color = legendText,
             text_size = size.tiny
        )

        table.cell(
             legendTable,
             0,
             4,
             "SCORE",
             bgcolor = legendBackground,
             text_color = legendText,
             text_size = size.tiny
        )

        table.cell(
             legendTable,
             1,
             4,
             "STRENGTH",
             bgcolor = legendBackground,
             text_color = legendText,
             text_size = size.tiny
        )

        table.cell(legendTable, 0, 5, "0-3", bgcolor = legendBackground, text_color = legendText, text_size = size.tiny)
        table.cell(legendTable, 1, 5, "Weak", bgcolor = legendBackground, text_color = legendText, text_size = size.tiny)

        table.cell(legendTable, 0, 6, "3-5", bgcolor = legendBackground, text_color = legendText, text_size = size.tiny)
        table.cell(legendTable, 1, 6, "Minor", bgcolor = legendBackground, text_color = legendText, text_size = size.tiny)

        table.cell(legendTable, 0, 7, "5-7", bgcolor = legendBackground, text_color = legendText, text_size = size.tiny)
        table.cell(legendTable, 1, 7, "Good", bgcolor = legendBackground, text_color = legendText, text_size = size.tiny)

        table.cell(legendTable, 0, 8, "7-10", bgcolor = legendBackground, text_color = legendText, text_size = size.tiny)
        table.cell(legendTable, 1, 8, "Strong", bgcolor = legendBackground, text_color = legendText, text_size = size.tiny)

        table.cell(legendTable, 0, 9, "10-15", bgcolor = legendBackground, text_color = legendText, text_size = size.tiny)
        table.cell(legendTable, 1, 9, "Very strong", bgcolor = legendBackground, text_color = legendText, text_size = size.tiny)

        table.cell(legendTable, 0, 10, "15+", bgcolor = legendBackground, text_color = legendText, text_size = size.tiny)
        table.cell(legendTable, 1, 10, "Exceptional", bgcolor = legendBackground, text_color = legendText, text_size = size.tiny)

        table.cell(
             legendTable,
             0,
             11,
             "HITS",
             bgcolor = legendBackground,
             text_color = legendText,
             text_size = size.tiny
        )

        table.cell(
             legendTable,
             1,
             11,
             "REACTIONS",
             bgcolor = legendBackground,
             text_color = legendText,
             text_size = size.tiny
        )

        table.cell(legendTable, 0, 12, "1", bgcolor = legendBackground, text_color = legendText, text_size = size.tiny)
        table.cell(legendTable, 1, 12, "Single", bgcolor = legendBackground, text_color = legendText, text_size = size.tiny)

        table.cell(legendTable, 0, 13, "2", bgcolor = legendBackground, text_color = legendText, text_size = size.tiny)
        table.cell(legendTable, 1, 13, "Confirmed", bgcolor = legendBackground, text_color = legendText, text_size = size.tiny)

        table.cell(legendTable, 0, 14, "3", bgcolor = legendBackground, text_color = legendText, text_size = size.tiny)
        table.cell(legendTable, 1, 14, "Strong", bgcolor = legendBackground, text_color = legendText, text_size = size.tiny)

        table.cell(legendTable, 0, 15, "4-5", bgcolor = legendBackground, text_color = legendText, text_size = size.tiny)
        table.cell(legendTable, 1, 15, "Very strong", bgcolor = legendBackground, text_color = legendText, text_size = size.tiny)

        table.cell(legendTable, 0, 16, "6+", bgcolor = legendBackground, text_color = legendText, text_size = size.tiny)
        table.cell(legendTable, 1, 16, "Major zone", bgcolor = legendBackground, text_color = legendText, text_size = size.tiny)

        table.cell(
             legendTable,
             0,
             17,
             "S/R FLIP",
             bgcolor = legendBackground,
             text_color = legendText,
             text_size = size.tiny
        )

        table.cell(
             legendTable,
             1,
             17,
             "Both roles",
             bgcolor = legendBackground,
             text_color = legendText,
             text_size = size.tiny
        )
````
