# Chart Pattern Structure

- url: https://www.tradingview.com/script/WaTeoaDd-Chart-Pattern-Structure/
- type: indicator
- pine_id: PUB;23bbdab223424500a497c97774554c7a
- version: 1.0

## Description

Chart Pattern Structure detects classic chart patterns by analyzing confirmed swing highs and swing lows rather than relying on simple visual pattern matching.

The indicator identifies Double Top, Double Bottom, Head & Shoulders, and Inverse Head & Shoulders structures based on swing sequence, price similarity, and pattern width. Detected patterns are displayed directly on the chart with their underlying swing structure and neckline.

The goal is to provide a clearer structural view of how a chart pattern develops, helping traders study potential formations and their key structural levels without turning the pattern itself into an automatic trading signal.

Pattern detection uses confirmed pivots, so newly forming swings are only recognized after sufficient price action has developed. This helps keep the structure more consistent and avoids treating every temporary price fluctuation as a completed pattern.

Disclaimer:
For educational and informational purposes only. Detected patterns are based on historical price action and do not guarantee future market movements or trading results. Not financial advice.

## Source Code

````pine
//@version=6
indicator("Chart Pattern Structure", shorttitle="CPS", overlay=true, max_lines_count=200, max_labels_count=100)

// ═════════════════════════════════════════════════════════════════════════════
// SETTINGS
// ═════════════════════════════════════════════════════════════════════════════

groupStructure = "Structure"

pivotLen = input.int(5, "Swing Strength", minval=2, maxval=20, group=groupStructure)
tolerance = input.float(2.0, "Similarity Tolerance (%)", minval=0.1, maxval=10.0, step=0.1, group=groupStructure)
minWidth = input.int(10, "Minimum Pattern Width", minval=2, maxval=200, group=groupStructure)
maxWidth = input.int(150, "Maximum Pattern Width", minval=10, maxval=500, group=groupStructure)

groupDisplay = "Display"

showStructure = input.bool(true, "Show Swing Structure", group=groupDisplay)
showNeckline = input.bool(true, "Show Neckline", group=groupDisplay)
showLabels = input.bool(true, "Show Pattern Labels", group=groupDisplay)

groupPatterns = "Patterns"

enableDoubleTop = input.bool(true, "Double Top", group=groupPatterns)
enableDoubleBottom = input.bool(true, "Double Bottom", group=groupPatterns)
enableHS = input.bool(true, "Head & Shoulders", group=groupPatterns)
enableIHS = input.bool(true, "Inverse Head & Shoulders", group=groupPatterns)

// ═════════════════════════════════════════════════════════════════════════════
// SWING DETECTION
// ═════════════════════════════════════════════════════════════════════════════

pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow = ta.pivotlow(low, pivotLen, pivotLen)

var float[] swingPrices = array.new_float()
var int[] swingBars = array.new_int()
var int[] swingTypes = array.new_int()

// ═════════════════════════════════════════════════════════════════════════════
// ADD SWING
// ═════════════════════════════════════════════════════════════════════════════

if not na(pivotHigh)

    float price = pivotHigh
    int swingBar = bar_index - pivotLen
    int swingType = 1

    int count = array.size(swingPrices)

    if count == 0

        array.push(swingPrices, price)
        array.push(swingBars, swingBar)
        array.push(swingTypes, swingType)

    else

        int lastType = array.get(swingTypes, count - 1)
        float lastPrice = array.get(swingPrices, count - 1)

        if lastType == swingType

            if price > lastPrice
                array.set(swingPrices, count - 1, price)
                array.set(swingBars, count - 1, swingBar)

        else

            array.push(swingPrices, price)
            array.push(swingBars, swingBar)
            array.push(swingTypes, swingType)

            if array.size(swingPrices) > 30
                array.shift(swingPrices)
                array.shift(swingBars)
                array.shift(swingTypes)


if not na(pivotLow)

    float price = pivotLow
    int swingBar = bar_index - pivotLen
    int swingType = -1

    int count = array.size(swingPrices)

    if count == 0

        array.push(swingPrices, price)
        array.push(swingBars, swingBar)
        array.push(swingTypes, swingType)

    else

        int lastType = array.get(swingTypes, count - 1)
        float lastPrice = array.get(swingPrices, count - 1)

        if lastType == swingType

            if price < lastPrice
                array.set(swingPrices, count - 1, price)
                array.set(swingBars, count - 1, swingBar)

        else

            array.push(swingPrices, price)
            array.push(swingBars, swingBar)
            array.push(swingTypes, swingType)

            if array.size(swingPrices) > 30
                array.shift(swingPrices)
                array.shift(swingBars)
                array.shift(swingTypes)

// ═════════════════════════════════════════════════════════════════════════════
// HELPERS
// ═════════════════════════════════════════════════════════════════════════════

similar(float a, float b) =>
    math.abs(a - b) / math.max(math.abs(a), math.abs(b)) * 100.0 <= tolerance

validWidth(int firstBar, int lastBar) =>
    int width = lastBar - firstBar
    width >= minWidth and width <= maxWidth

// ═════════════════════════════════════════════════════════════════════════════
// PATTERN VARIABLES
// ═════════════════════════════════════════════════════════════════════════════

bool doubleTop = false
bool doubleBottom = false
bool headShoulders = false
bool inverseHeadShoulders = false

float doubleTopNeck = na
float doubleBottomNeck = na
float hsNeck = na
float ihsNeck = na

int patternLeftBar = na
int patternRightBar = na

// ═════════════════════════════════════════════════════════════════════════════
// DOUBLE TOP
//
// H → L → H
// ═════════════════════════════════════════════════════════════════════════════

if enableDoubleTop and array.size(swingPrices) >= 3

    int n = array.size(swingPrices)

    int i0 = n - 3
    int i1 = n - 2
    int i2 = n - 1

    int t0 = array.get(swingTypes, i0)
    int t1 = array.get(swingTypes, i1)
    int t2 = array.get(swingTypes, i2)

    float p0 = array.get(swingPrices, i0)
    float p1 = array.get(swingPrices, i1)
    float p2 = array.get(swingPrices, i2)

    int b0 = array.get(swingBars, i0)
    int b2 = array.get(swingBars, i2)

    bool sequence = t0 == 1 and t1 == -1 and t2 == 1
    bool validHeights = similar(p0, p2) and p1 < p0 and p1 < p2
    bool widthOK = validWidth(b0, b2)

    if sequence and validHeights and widthOK

        doubleTop := true
        doubleTopNeck := p1
        patternLeftBar := b0
        patternRightBar := b2

// ═════════════════════════════════════════════════════════════════════════════
// DOUBLE BOTTOM
//
// L → H → L
// ═════════════════════════════════════════════════════════════════════════════

if enableDoubleBottom and array.size(swingPrices) >= 3

    int n = array.size(swingPrices)

    int i0 = n - 3
    int i1 = n - 2
    int i2 = n - 1

    int t0 = array.get(swingTypes, i0)
    int t1 = array.get(swingTypes, i1)
    int t2 = array.get(swingTypes, i2)

    float p0 = array.get(swingPrices, i0)
    float p1 = array.get(swingPrices, i1)
    float p2 = array.get(swingPrices, i2)

    int b0 = array.get(swingBars, i0)
    int b2 = array.get(swingBars, i2)

    bool sequence = t0 == -1 and t1 == 1 and t2 == -1
    bool validLows = similar(p0, p2) and p1 > p0 and p1 > p2
    bool widthOK = validWidth(b0, b2)

    if sequence and validLows and widthOK

        doubleBottom := true
        doubleBottomNeck := p1
        patternLeftBar := b0
        patternRightBar := b2

// ═════════════════════════════════════════════════════════════════════════════
// HEAD & SHOULDERS
//
// H → L → H → L → H
// ═════════════════════════════════════════════════════════════════════════════

if enableHS and array.size(swingPrices) >= 5

    int n = array.size(swingPrices)

    int i0 = n - 5
    int i1 = n - 4
    int i2 = n - 3
    int i3 = n - 2
    int i4 = n - 1

    int t0 = array.get(swingTypes, i0)
    int t1 = array.get(swingTypes, i1)
    int t2 = array.get(swingTypes, i2)
    int t3 = array.get(swingTypes, i3)
    int t4 = array.get(swingTypes, i4)

    float h1 = array.get(swingPrices, i0)
    float l1 = array.get(swingPrices, i1)
    float h2 = array.get(swingPrices, i2)
    float l2 = array.get(swingPrices, i3)
    float h3 = array.get(swingPrices, i4)

    int b0 = array.get(swingBars, i0)
    int b4 = array.get(swingBars, i4)

    bool sequence =
         t0 == 1 and
         t1 == -1 and
         t2 == 1 and
         t3 == -1 and
         t4 == 1

    bool validHead =
         h2 > h1 and
         h2 > h3

    bool validShoulders =
         similar(h1, h3)

    bool validValleys =
         l1 < h1 and
         l1 < h2 and
         l2 < h2 and
         l2 < h3

    bool widthOK = validWidth(b0, b4)

    if sequence and validHead and validShoulders and validValleys and widthOK

        headShoulders := true
        hsNeck := (l1 + l2) / 2.0
        patternLeftBar := b0
        patternRightBar := b4

// ═════════════════════════════════════════════════════════════════════════════
// INVERSE HEAD & SHOULDERS
//
// L → H → L → H → L
// ═════════════════════════════════════════════════════════════════════════════

if enableIHS and array.size(swingPrices) >= 5

    int n = array.size(swingPrices)

    int i0 = n - 5
    int i1 = n - 4
    int i2 = n - 3
    int i3 = n - 2
    int i4 = n - 1

    int t0 = array.get(swingTypes, i0)
    int t1 = array.get(swingTypes, i1)
    int t2 = array.get(swingTypes, i2)
    int t3 = array.get(swingTypes, i3)
    int t4 = array.get(swingTypes, i4)

    float l1 = array.get(swingPrices, i0)
    float h1 = array.get(swingPrices, i1)
    float l2 = array.get(swingPrices, i2)
    float h2 = array.get(swingPrices, i3)
    float l3 = array.get(swingPrices, i4)

    int b0 = array.get(swingBars, i0)
    int b4 = array.get(swingBars, i4)

    bool sequence =
         t0 == -1 and
         t1 == 1 and
         t2 == -1 and
         t3 == 1 and
         t4 == -1

    bool validHead =
         l2 < l1 and
         l2 < l3

    bool validShoulders =
         similar(l1, l3)

    bool validPeaks =
         h1 > l1 and
         h1 > l2 and
         h2 > l2 and
         h2 > l3

    bool widthOK = validWidth(b0, b4)

    if sequence and validHead and validShoulders and validPeaks and widthOK

        inverseHeadShoulders := true
        ihsNeck := (h1 + h2) / 2.0
        patternLeftBar := b0
        patternRightBar := b4

// ═════════════════════════════════════════════════════════════════════════════
// SWING STRUCTURE VISUAL
// ═════════════════════════════════════════════════════════════════════════════

var int lastDrawnSwingCount = 0

if showStructure and array.size(swingPrices) >= 2

    int currentCount = array.size(swingPrices)

    if currentCount > lastDrawnSwingCount

        int n = currentCount

        float p1 = array.get(swingPrices, n - 2)
        float p2 = array.get(swingPrices, n - 1)

        int b1 = array.get(swingBars, n - 2)
        int b2 = array.get(swingBars, n - 1)

        line.new(
             b1,
             p1,
             b2,
             p2,
             width=1)

        lastDrawnSwingCount := currentCount

// ═════════════════════════════════════════════════════════════════════════════
// NECKLINE
// ═════════════════════════════════════════════════════════════════════════════

var line activeNeckline = na

if doubleTop or doubleBottom or headShoulders or inverseHeadShoulders

    if not na(activeNeckline)
        line.delete(activeNeckline)

    float neckline = na

    if doubleTop
        neckline := doubleTopNeck

    else if doubleBottom
        neckline := doubleBottomNeck

    else if headShoulders
        neckline := hsNeck

    else if inverseHeadShoulders
        neckline := ihsNeck

    if showNeckline and not na(neckline)

        activeNeckline := line.new(
             patternLeftBar,
             neckline,
             patternRightBar,
             neckline,
             extend=extend.right,
             width=2)

// ═════════════════════════════════════════════════════════════════════════════
// LABELS
// ═════════════════════════════════════════════════════════════════════════════

if showLabels and doubleTop

    label.new(
         patternRightBar,
         array.get(swingPrices, array.size(swingPrices) - 1),
         "Double Top",
         style=label.style_label_down,
         size=size.small)

if showLabels and doubleBottom

    label.new(
         patternRightBar,
         array.get(swingPrices, array.size(swingPrices) - 1),
         "Double Bottom",
         style=label.style_label_up,
         size=size.small)

if showLabels and headShoulders

    label.new(
         patternRightBar,
         array.get(swingPrices, array.size(swingPrices) - 1),
         "Head & Shoulders",
         style=label.style_label_down,
         size=size.small)

if showLabels and inverseHeadShoulders

    label.new(
         patternRightBar,
         array.get(swingPrices, array.size(swingPrices) - 1),
         "Inverse H&S",
         style=label.style_label_up,
         size=size.small)

// ═════════════════════════════════════════════════════════════════════════════
// ALERTS
// ═════════════════════════════════════════════════════════════════════════════

alertcondition(
     doubleTop,
     "Double Top",
     "Vertex Chart Pattern Structure detected a Double Top.")

alertcondition(
     doubleBottom,
     "Double Bottom",
     "Vertex Chart Pattern Structure detected a Double Bottom.")

alertcondition(
     headShoulders,
     "Head & Shoulders",
     "Vertex Chart Pattern Structure detected a Head & Shoulders pattern.")

alertcondition(
     inverseHeadShoulders,
     "Inverse Head & Shoulders",
     "Vertex Chart Pattern Structure detected an Inverse Head & Shoulders pattern.")
````
