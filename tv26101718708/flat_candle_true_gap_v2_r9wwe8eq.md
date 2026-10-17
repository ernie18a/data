# Flat Candle + True Gap v2

- url: https://www.tradingview.com/script/R9WWe8eq-Flat-Candle-True-Gap-v2/
- type: indicator
- pine_id: PUB;b96f0d53be7d4884ac4fb060af52a19e
- version: 2.0

## Description

**Flat Candle + True Gap**

This indicator is designed to identify and display two simple price-action elements: **Flat Candles** and **True Gaps**.

A **Flat Candle** is defined as a candle with no wick on one side:

- No upper wick → a horizontal line is drawn from the candle's high.
- No lower wick → a horizontal line is drawn from the candle's low.
- If both sides are flat, both levels are displayed.

Each Flat Candle level extends to the right until a future candle touches it. When the level is touched, the line can either stop at the touching candle and remain visible as historical reference, or be removed completely, depending on the selected setting.

A **True Gap** is a real price gap between two consecutive candles:

- Bullish True Gap: the current candle's low is above the previous candle's high.
- Bearish True Gap: the current candle's high is below the previous candle's low.

The indicator draws a band covering the exact untraded price area between the two candles. The band extends to the right until price touches any part of the gap. Once touched, the band can remain on the chart and stop at the mitigation candle, or disappear completely.

### Features

- Detects upper and lower Flat Candle levels
- Detects bullish and bearish True Gaps
- Flat Candle lines begin directly from the originating candle
- True Gap bands cover only the actual gap area
- Levels remain active until first price contact
- Optional historical display after mitigation
- Adjustable Flat Candle line color and thickness
- Adjustable True Gap band and border colors
- Optional labels for Flat Candles and True Gaps
- Adjustable number of historical Flat Candle lines
- Adjustable number of historical True Gap bands
- Works directly on the price chart

The purpose of the indicator is to provide a clean visual reference for untested Flat Candle levels and genuine price gaps without adding trade signals, market structure, or additional filters.

It is intended as a simple charting tool rather than a complete trading strategy.

## Source Code

````pine
//@version=6
indicator(
     "Flat Candle + True Gap v3",
     overlay = true,
     max_lines_count = 500,
     max_labels_count = 500,
     max_boxes_count = 500)

// =====================================================
// SETTINGS — HISTORY
// =====================================================

groupHistory = "Historique"

keepAfterTouch = input.bool(
     true,
     "Conserver après croisement",
     tooltip = "Activé : la ligne/bande reste visible et s'arrête à la première chandelle qui la touche. Désactivé : elle disparaît au toucher.",
     group = groupHistory)

maxFlatHistory = input.int(
     30,
     "Flat Candles historiques à conserver",
     minval = 0,
     maxval = 400,
     tooltip = "Limite uniquement les lignes déjà touchées. Les Flat Candles encore actives ne sont PAS comptées dans cette limite.",
     group = groupHistory)

maxGapHistory = input.int(
     30,
     "True Gaps historiques à conserver",
     minval = 0,
     maxval = 400,
     tooltip = "Limite uniquement les bandes déjà touchées. Les True Gaps encore actifs ne sont PAS comptés dans cette limite.",
     group = groupHistory)

// =====================================================
// SETTINGS — FLAT CANDLE DETECTION
// =====================================================

groupDetection = "Détection Flat Candle"

flatDetectionMode = input.string(
     "Visual tolerance",
     "Mode de détection",
     options = ["Strict (exact)", "Visual tolerance"],
     tooltip = "Strict : absolument aucune mèche. Visual tolerance : accepte une très petite mèche relativement à la taille totale de la chandelle.",
     group = groupDetection)

maxWickPercent = input.float(
     1.0,
     "Mèche maximale (% du range)",
     minval = 0.0,
     maxval = 10.0,
     step = 0.1,
     tooltip = "Utilisé uniquement en mode Visual tolerance. Exemple : 1.0 signifie qu'une mèche <= 1% du range total de la chandelle est considérée comme flat.",
     group = groupDetection)

// =====================================================
// SETTINGS — FLAT CANDLE STYLE
// =====================================================

groupFlat = "Flat Candle"

showFlat = input.bool(true, "Afficher Flat Candles", group = groupFlat)
flatColor = input.color(color.yellow, "Couleur", group = groupFlat)
flatWidth = input.int(2, "Épaisseur", minval = 1, maxval = 5, group = groupFlat)
showFlatText = input.bool(true, "Texte FLAT CANDLE", group = groupFlat)

// =====================================================
// SETTINGS — TRUE GAP
// =====================================================

groupGap = "True Gap"

showTrueGap = input.bool(true, "Afficher True Gaps", group = groupGap)
gapColor = input.color(color.new(color.aqua, 80), "Couleur bande", group = groupGap)
gapBorderColor = input.color(color.aqua, "Couleur bordure", group = groupGap)
showGapText = input.bool(true, "Texte TRUE GAP", group = groupGap)

// =====================================================
// ACTIVE FLAT CANDLES
// =====================================================

var line[] activeFlatLines = array.new_line()
var label[] activeFlatLabels = array.new_label()
var float[] activeFlatPrices = array.new_float()
var int[] activeFlatCreatedBars = array.new_int()

// Historical / already mitigated Flat Candles.
var line[] historicalFlatLines = array.new_line()
var label[] historicalFlatLabels = array.new_label()

// =====================================================
// ACTIVE TRUE GAPS
// =====================================================

var box[] activeGapBoxes = array.new_box()
var float[] activeGapTops = array.new_float()
var float[] activeGapBottoms = array.new_float()
var int[] activeGapCreatedBars = array.new_int()

// Historical / already mitigated True Gaps.
var box[] historicalGapBoxes = array.new_box()

// =====================================================
// MANAGE ACTIVE FLAT CANDLES
// =====================================================

if array.size(activeFlatLines) > 0
    int i = array.size(activeFlatLines) - 1

    while i >= 0
        line ln = array.get(activeFlatLines, i)
        label lbl = array.get(activeFlatLabels, i)
        float price = array.get(activeFlatPrices, i)
        int createdBar = array.get(activeFlatCreatedBars, i)

        bool futureBar = bar_index > createdBar

        // Any future wick/body contact with the level = mitigation.
        bool touched =
             futureBar and
             high >= price and
             low <= price

        if touched
            if keepAfterTouch
                // Stop exactly at the first touching candle.
                line.set_extend(ln, extend.none)
                line.set_x2(ln, bar_index)
                line.set_y2(ln, price)

                if not na(lbl)
                    label.set_x(lbl, bar_index)
                    label.set_y(lbl, price)

                // Move the finished object to historical storage.
                array.push(historicalFlatLines, ln)
                array.push(historicalFlatLabels, lbl)

            else
                line.delete(ln)

                if not na(lbl)
                    label.delete(lbl)

            // Remove from ACTIVE storage in both cases.
            array.remove(activeFlatLines, i)
            array.remove(activeFlatLabels, i)
            array.remove(activeFlatPrices, i)
            array.remove(activeFlatCreatedBars, i)

        else
            // Keep active label at the current right side of the chart.
            if not na(lbl)
                label.set_x(lbl, bar_index)
                label.set_y(lbl, price)

        i -= 1

// =====================================================
// MANAGE ACTIVE TRUE GAPS
// =====================================================

if array.size(activeGapBoxes) > 0
    int i = array.size(activeGapBoxes) - 1

    while i >= 0
        box gap = array.get(activeGapBoxes, i)
        float gapTop = array.get(activeGapTops, i)
        float gapBottom = array.get(activeGapBottoms, i)
        int createdBar = array.get(activeGapCreatedBars, i)

        bool futureBar = bar_index > createdBar

        // Any contact with any part of the band = mitigation.
        bool touched =
             futureBar and
             high >= gapBottom and
             low <= gapTop

        if touched
            if keepAfterTouch
                // Stop exactly at the first touching candle.
                box.set_extend(gap, extend.none)
                box.set_right(gap, bar_index)

                // Move the finished object to historical storage.
                array.push(historicalGapBoxes, gap)

            else
                box.delete(gap)

            // Remove from ACTIVE storage.
            array.remove(activeGapBoxes, i)
            array.remove(activeGapTops, i)
            array.remove(activeGapBottoms, i)
            array.remove(activeGapCreatedBars, i)

        i -= 1

// =====================================================
// FLAT CANDLE DETECTION
// =====================================================

float bodyHigh = math.max(open, close)
float bodyLow = math.min(open, close)

float upperWick = math.max(0.0, high - bodyHigh)
float lowerWick = math.max(0.0, bodyLow - low)
float candleRange = math.max(high - low, syminfo.mintick)

// Strict mode = literally zero wick.
// Visual tolerance mode = wick can be a very small percentage
// of the candle's full High-Low range.
float allowedWick =
     flatDetectionMode == "Strict (exact)" ?
     0.0 :
     candleRange * (maxWickPercent / 100.0)

bool flatHigh =
     flatDetectionMode == "Strict (exact)" ?
     high == bodyHigh :
     upperWick <= allowedWick

bool flatLow =
     flatDetectionMode == "Strict (exact)" ?
     low == bodyLow :
     lowerWick <= allowedWick

// =====================================================
// CREATE FLAT CANDLES
// =====================================================

if barstate.isconfirmed and showFlat

    // FLAT HIGH
    if flatHigh
        float price = high

        line ln = line.new(
             x1 = bar_index,
             y1 = price,
             x2 = bar_index + 1,
             y2 = price,
             xloc = xloc.bar_index,
             extend = extend.right,
             color = flatColor,
             width = flatWidth)

        label lbl = na

        if showFlatText
            lbl := label.new(
                 x = bar_index,
                 y = price,
                 text = "FLAT CANDLE",
                 xloc = xloc.bar_index,
                 style = label.style_none,
                 textcolor = flatColor,
                 size = size.tiny)

        array.push(activeFlatLines, ln)
        array.push(activeFlatLabels, lbl)
        array.push(activeFlatPrices, price)
        array.push(activeFlatCreatedBars, bar_index)

    // FLAT LOW
    if flatLow
        float price = low

        line ln = line.new(
             x1 = bar_index,
             y1 = price,
             x2 = bar_index + 1,
             y2 = price,
             xloc = xloc.bar_index,
             extend = extend.right,
             color = flatColor,
             width = flatWidth)

        label lbl = na

        if showFlatText
            lbl := label.new(
                 x = bar_index,
                 y = price,
                 text = "FLAT CANDLE",
                 xloc = xloc.bar_index,
                 style = label.style_none,
                 textcolor = flatColor,
                 size = size.tiny)

        array.push(activeFlatLines, ln)
        array.push(activeFlatLabels, lbl)
        array.push(activeFlatPrices, price)
        array.push(activeFlatCreatedBars, bar_index)

// =====================================================
// TRUE GAP DETECTION
// =====================================================

bool bullishTrueGap =
     bar_index > 0 and
     low > high[1]

bool bearishTrueGap =
     bar_index > 0 and
     high < low[1]

// =====================================================
// CREATE TRUE GAPS
// =====================================================

if barstate.isconfirmed and showTrueGap

    // BULLISH TRUE GAP
    if bullishTrueGap
        float top = low
        float bottom = high[1]

        box gap = box.new(
             left = bar_index - 1,
             top = top,
             right = bar_index,
             bottom = bottom,
             xloc = xloc.bar_index,
             extend = extend.right,
             bgcolor = gapColor,
             border_color = gapBorderColor,
             border_width = 1,
             text = showGapText ? "TRUE GAP" : "",
             text_color = gapBorderColor,
             text_size = size.tiny,
             text_halign = text.align_left,
             text_valign = text.align_center)

        array.push(activeGapBoxes, gap)
        array.push(activeGapTops, top)
        array.push(activeGapBottoms, bottom)
        array.push(activeGapCreatedBars, bar_index)

    // BEARISH TRUE GAP
    if bearishTrueGap
        float top = low[1]
        float bottom = high

        box gap = box.new(
             left = bar_index - 1,
             top = top,
             right = bar_index,
             bottom = bottom,
             xloc = xloc.bar_index,
             extend = extend.right,
             bgcolor = gapColor,
             border_color = gapBorderColor,
             border_width = 1,
             text = showGapText ? "TRUE GAP" : "",
             text_color = gapBorderColor,
             text_size = size.tiny,
             text_halign = text.align_left,
             text_valign = text.align_center)

        array.push(activeGapBoxes, gap)
        array.push(activeGapTops, top)
        array.push(activeGapBottoms, bottom)
        array.push(activeGapCreatedBars, bar_index)

// =====================================================
// HISTORICAL LIMIT — FLAT CANDLES ONLY
// =====================================================

// IMPORTANT:
// Active Flat Candles are NEVER removed by this setting.
// Only already-touched historical lines are limited.
while array.size(historicalFlatLines) > maxFlatHistory
    line oldestLine = array.shift(historicalFlatLines)
    label oldestLabel = array.shift(historicalFlatLabels)

    line.delete(oldestLine)

    if not na(oldestLabel)
        label.delete(oldestLabel)

// =====================================================
// HISTORICAL LIMIT — TRUE GAPS ONLY
// =====================================================

// IMPORTANT:
// Active True Gaps are NEVER removed by this setting.
// Only already-touched historical bands are limited.
while array.size(historicalGapBoxes) > maxGapHistory
    box oldestGap = array.shift(historicalGapBoxes)
    box.delete(oldestGap)
````
