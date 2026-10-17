# BearScope Pattern Radar

- url: https://www.tradingview.com/script/RkPqdWk4-BearScope-Pattern-Radar/
- type: indicator
- pine_id: PUB;0d761290a7a140f984e58c4747bf199e
- version: 1.0

## Description

BearScope - Bearish Pattern Scanner

OVERVIEW

BearScope is a bearish chart-pattern research indicator that identifies five commonly followed bearish formations on the current symbol and timeframe.

The indicator displays pattern-shaped outlines directly over the price chart and provides a separate lower panel showing when each formation was identified throughout the available chart history.

PATTERNS IDENTIFIED

• Classic Bear Flag
• Descending Triangle
• Rising Wedge
• Double Top
• Inverse Cup and Handle

HOW IT WORKS

Classic Bear Flag

BearScope searches for a strong downward flagpole followed by a controlled, upward-sloping consolidation channel. The upper and lower channel slopes must be reasonably parallel, and the consolidation must remain within the selected maximum retracement.

Descending Triangle

The indicator looks for approximately horizontal support combined with descending resistance and repeated tests near the support area. The pattern is identified when price confirms a downside breakdown beneath the fitted support line.

Rising Wedge

BearScope searches for rising upper and lower boundaries that converge as the pattern develops. The lower boundary must rise faster than the upper boundary, creating a narrowing structure. Identification requires a confirmed downside breakdown.

Double Top

Two confirmed pivot highs must occur within the selected price tolerance and bar-separation limits. A meaningful decline must appear between the two tops.

Because pivot highs require subsequent candles for confirmation, a Double Top is recognized only after the selected pivot-strength period has elapsed.

Inverse Cup and Handle

The indicator searches for two similar lower rim areas separated by a rounded price advance, followed by a smaller upward handle. Identification requires price to break below the rim area.

CHART DISPLAY

Pattern-shaped outlines are drawn directly on the main price chart:

• Red — Classic Bear Flag
• Yellow — Descending Triangle
• Orange — Rising Wedge
• Purple — Double Top
• Aqua — Inverse Cup and Handle

LOWER PATTERN PANEL

The lower panel contains five permanently labeled rows corresponding to the five pattern types.

• Faint dotted lines identify each pattern row.
• Thick colored segments show the complete historical duration of identified patterns.
• Colored confirmation markers identify the candle on which the script confirmed the pattern.
• Pattern names remain positioned at the left edge of the visible chart and automatically adjust when the chart is scrolled or zoomed.

ALERTS

Individual alert conditions are available for:

• Bear Flag
• Descending Triangle breakdown
• Rising Wedge breakdown
• Double Top
• Inverse Cup and Handle breakdown

IMPORTANT INFORMATION

BearScope evaluates only the symbol and timeframe currently displayed on the chart. It does not scan the entire stock market or a TradingView watchlist.

Pattern detection is based on mathematical approximations of price structure. Real-world formations are subjective, and no automated method will identify every valid pattern or exclude every questionable one.

Historical markings show when the script’s programmed conditions were satisfied. They are not evidence that a trade would have been profitable.

Double Top detection uses confirmed pivots and therefore occurs after the actual pivot candle. Pattern drawings may extend back to the formation’s earlier bars, but the information was not available until confirmation occurred.

DISCLAIMER

BearScope is provided solely for educational, informational and historical research purposes. It is not financial or investment advice and does not constitute a recommendation to buy, sell or short any security.

A detected pattern does not guarantee a downside move. Bearish formations can fail, reverse or break upward. Users should independently evaluate trend, volume, liquidity, market conditions, news, risk tolerance and position sizing before making any trading decision.

Past performance and historical chart patterns are not reliable indicators of future results.

## Source Code

````pine
//@version=6
indicator("BearScope - Bearish Pattern Scanner", shorttitle="BearScope", overlay=false, max_bars_back=300, max_boxes_count=500, max_lines_count=500, max_labels_count=50)

//====================================================================
// INPUTS
//====================================================================

groupFlag = "1. Bear Flag"
groupChannel = "2. Wedges and Triangles"
groupTop = "3. Double Top"
groupCup = "4. Inverse Cup and Handle"

flagMinBars = input.int(3, "Minimum Flag Bars", minval=3, maxval=10, group=groupFlag)
flagMaxBars = input.int(12, "Maximum Flag Bars", minval=4, maxval=20, group=groupFlag)
poleMaxBars = input.int(20, "Maximum Pole Bars", minval=5, maxval=50, group=groupFlag)
minimumPoleDrop = input.float(10.0, "Minimum Pole Drop %", minval=3.0, maxval=50.0, step=0.5, group=groupFlag)
maximumFlagRetracement = input.float(50.0, "Maximum Flag Retracement %", minval=20.0, maxval=80.0, step=5.0, group=groupFlag)
maximumFlagSlopeDifference = input.float(0.75, "Maximum Flag Slope Difference", minval=0.10, maxval=3.0, step=0.05, group=groupFlag)

channelMinBars = input.int(10, "Minimum Wedge/Triangle Bars", minval=8, maxval=30, group=groupChannel)
channelMaxBars = input.int(40, "Maximum Wedge/Triangle Bars", minval=15, maxval=60, group=groupChannel)
patternTolerance = input.float(2.0, "Price Tolerance %", minval=0.5, maxval=5.0, step=0.25, group=groupChannel)
minimumSupportTouches = input.int(2, "Minimum Support Touches", minval=2, maxval=5, group=groupChannel)

pivotStrength = input.int(3, "Pivot Strength", minval=2, maxval=6, group=groupTop)
minimumTopSeparation = input.int(7, "Minimum Bars Between Tops", minval=4, maxval=20, group=groupTop)
maximumTopSeparation = input.int(40, "Maximum Bars Between Tops", minval=15, maxval=80, group=groupTop)
minimumMiddleDecline = input.float(3.0, "Minimum Middle Decline %", minval=1.0, maxval=20.0, step=0.5, group=groupTop)

cupMinBars = input.int(30, "Minimum Cup Bars", minval=20, maxval=60, group=groupCup)
cupMaxBars = input.int(90, "Maximum Cup Bars", minval=40, maxval=150, group=groupCup)
handleMinBars = input.int(5, "Minimum Handle Bars", minval=3, maxval=15, group=groupCup)
handleMaxBars = input.int(15, "Maximum Handle Bars", minval=6, maxval=30, group=groupCup)
maximumRimDifference = input.float(5.0, "Maximum Rim Difference %", minval=1.0, maxval=10.0, step=0.5, group=groupCup)
minimumCupHeight = input.float(10.0, "Minimum Inverse Cup Height %", minval=5.0, maxval=30.0, step=1.0, group=groupCup)
maximumCupHeight = input.float(45.0, "Maximum Inverse Cup Height %", minval=20.0, maxval=70.0, step=5.0, group=groupCup)
maximumHandleHeight = input.float(35.0, "Maximum Handle / Cup Height %", minval=10.0, maxval=60.0, step=5.0, group=groupCup)

//====================================================================
// DRAW A MATCHING BOTTOM-ROW SEGMENT
//====================================================================

drawRow(int leftBar, int rightBar, float row, color patternColor) =>
    box.new(left=leftBar, top=row + 0.12, right=rightBar + 1, bottom=row - 0.12, xloc=xloc.bar_index, border_color=patternColor, border_width=1, bgcolor=patternColor)

//====================================================================
// CLASSIC BEAR FLAG
//====================================================================

bool bearFlagDetected = false
int bearFlagLength = na
float bearFlagUpperStart = na
float bearFlagUpperEnd = na
float bearFlagLowerStart = na
float bearFlagLowerEnd = na

for flagLen = flagMinBars to flagMaxBars
    bool enoughFlagHistory = not na(low[flagLen + poleMaxBars])

    if enoughFlagHistory
        float poleLow = low[flagLen]
        float poleHigh = na
        float poleDrop = na

        for poleAge = flagLen + 1 to flagLen + poleMaxBars
            float possiblePoleHigh = high[poleAge]
            float possiblePoleDrop = possiblePoleHigh > 0.0 ? (1.0 - poleLow / possiblePoleHigh) * 100.0 : na

            if not na(possiblePoleDrop) and (na(poleDrop) or possiblePoleDrop > poleDrop)
                poleHigh := possiblePoleHigh
                poleDrop := possiblePoleDrop

        float sumX = 0.0
        float sumX2 = 0.0
        float sumHigh = 0.0
        float sumLow = 0.0
        float sumXHigh = 0.0
        float sumXLow = 0.0
        float highestFlagHigh = na

        for x = 0 to flagLen - 1
            int offset = flagLen - 1 - x
            float xValue = x
            sumX += xValue
            sumX2 += xValue * xValue
            sumHigh += high[offset]
            sumLow += low[offset]
            sumXHigh += xValue * high[offset]
            sumXLow += xValue * low[offset]
            highestFlagHigh := na(highestFlagHigh) ? high[offset] : math.max(highestFlagHigh, high[offset])

        float n = flagLen
        float denominator = n * sumX2 - sumX * sumX
        float highSlope = denominator != 0.0 ? (n * sumXHigh - sumX * sumHigh) / denominator : na
        float lowSlope = denominator != 0.0 ? (n * sumXLow - sumX * sumLow) / denominator : na
        float highIntercept = not na(highSlope) ? (sumHigh - highSlope * sumX) / n : na
        float lowIntercept = not na(lowSlope) ? (sumLow - lowSlope * sumX) / n : na
        float averagePrice = (sumHigh + sumLow) / (2.0 * n)
        float highSlopePct = averagePrice > 0.0 ? highSlope / averagePrice * 100.0 : na
        float lowSlopePct = averagePrice > 0.0 ? lowSlope / averagePrice * 100.0 : na
        float poleHeight = poleHigh - poleLow
        float retracement = poleHeight > 0.0 ? (highestFlagHigh - poleLow) / poleHeight * 100.0 : na
        bool polePass = not na(poleDrop) and poleDrop >= minimumPoleDrop
        bool ascendingChannel = highSlopePct > 0.05 and lowSlopePct > 0.05
        bool parallelChannel = math.abs(highSlopePct - lowSlopePct) <= maximumFlagSlopeDifference
        bool retracementPass = not na(retracement) and retracement >= 0.0 and retracement <= maximumFlagRetracement
        bool holdsBelowPoleHigh = not na(poleHigh) and highestFlagHigh < poleHigh
        bool flagCandidate = polePass and ascendingChannel and parallelChannel and retracementPass and holdsBelowPoleHigh

        if flagCandidate
            bearFlagDetected := true
            bearFlagLength := flagLen
            bearFlagUpperStart := highIntercept
            bearFlagUpperEnd := highIntercept + highSlope * (flagLen - 1)
            bearFlagLowerStart := lowIntercept
            bearFlagLowerEnd := lowIntercept + lowSlope * (flagLen - 1)

bool newBearFlag = bearFlagDetected and not bearFlagDetected[1]

if newBearFlag and not na(bearFlagLength)
    int flagLeft = bar_index - bearFlagLength + 1
    line.new(flagLeft, bearFlagUpperStart, bar_index, bearFlagUpperEnd, xloc=xloc.bar_index, color=color.red, width=2, force_overlay=true)
    line.new(flagLeft, bearFlagLowerStart, bar_index, bearFlagLowerEnd, xloc=xloc.bar_index, color=color.red, width=2, force_overlay=true)
    line.new(flagLeft, bearFlagUpperStart, flagLeft, bearFlagLowerStart, xloc=xloc.bar_index, color=color.red, width=2, force_overlay=true)
    line.new(bar_index, bearFlagUpperEnd, bar_index, bearFlagLowerEnd, xloc=xloc.bar_index, color=color.red, width=2, force_overlay=true)
    drawRow(flagLeft, bar_index, 4.0, color.red)

//====================================================================
// VARIABLE-LENGTH DESCENDING TRIANGLE AND RISING WEDGE
// The completed channel occupies bars [length ... 1].
// The current bar must confirm a downside breakdown.
//====================================================================

bool triangleDetected = false
bool wedgeDetected = false
int triangleLength = na
int wedgeLength = na
float triangleFirstHigh = na
float triangleFirstLow = na
float wedgeFirstHigh = na
float wedgeFirstLow = na
float triangleUpperStart = na
float triangleUpperEnd = na
float triangleLowerStart = na
float triangleLowerEnd = na
float wedgeUpperStart = na
float wedgeUpperEnd = na
float wedgeLowerStart = na
float wedgeLowerEnd = na

for patternLen = channelMinBars to channelMaxBars
    bool enoughChannelHistory = not na(low[patternLen])

    if enoughChannelHistory
        float sumX = 0.0
        float sumX2 = 0.0
        float sumHigh = 0.0
        float sumLow = 0.0
        float sumXHigh = 0.0
        float sumXLow = 0.0
        float lowestPatternLow = na

        for x = 0 to patternLen - 1
            int offset = patternLen - x
            float xValue = x
            sumX += xValue
            sumX2 += xValue * xValue
            sumHigh += high[offset]
            sumLow += low[offset]
            sumXHigh += xValue * high[offset]
            sumXLow += xValue * low[offset]
            lowestPatternLow := na(lowestPatternLow) ? low[offset] : math.min(lowestPatternLow, low[offset])

        float n = patternLen
        float denominator = n * sumX2 - sumX * sumX
        float highSlope = denominator != 0.0 ? (n * sumXHigh - sumX * sumHigh) / denominator : na
        float lowSlope = denominator != 0.0 ? (n * sumXLow - sumX * sumLow) / denominator : na
        float highIntercept = not na(highSlope) ? (sumHigh - highSlope * sumX) / n : na
        float lowIntercept = not na(lowSlope) ? (sumLow - lowSlope * sumX) / n : na
        float averagePrice = (sumHigh + sumLow) / (2.0 * n)
        float highSlopePct = averagePrice > 0.0 ? highSlope / averagePrice * 100.0 : na
        float lowSlopePct = averagePrice > 0.0 ? lowSlope / averagePrice * 100.0 : na
        float oldWidth = highIntercept - lowIntercept
        float recentWidth = (highIntercept + highSlope * (patternLen - 1)) - (lowIntercept + lowSlope * (patternLen - 1))
        float widthRatio = oldWidth > 0.0 ? recentWidth / oldWidth : na
        float resistanceNow = highIntercept + highSlope * patternLen
        float supportNow = lowIntercept + lowSlope * patternLen
        float supportPrior = lowIntercept + lowSlope * (patternLen - 1)
        bool breakdownPass = close < supportNow and close[1] >= supportPrior and high < resistanceNow

        int supportTouches = 0

        for offset = 1 to patternLen
            bool nearSupport = lowestPatternLow > 0.0 and math.abs(low[offset] - lowestPatternLow) / lowestPatternLow * 100.0 <= patternTolerance
            if nearSupport
                supportTouches += 1

        bool triangleGeometry = math.abs(lowSlopePct) <= 0.20 and highSlopePct <= -0.10 and supportTouches >= minimumSupportTouches and not na(widthRatio) and widthRatio > 0.0 and widthRatio <= 0.90
        bool wedgeGeometry = highSlopePct > 0.0 and lowSlopePct > 0.05 and lowSlopePct > highSlopePct and not na(widthRatio) and widthRatio >= 0.10 and widthRatio <= 0.95

        if triangleGeometry and breakdownPass
            triangleDetected := true
            triangleLength := patternLen
            triangleFirstHigh := high[patternLen]
            triangleFirstLow := low[patternLen]
            triangleUpperStart := highIntercept
            triangleUpperEnd := resistanceNow
            triangleLowerStart := lowIntercept
            triangleLowerEnd := supportNow

        if wedgeGeometry and breakdownPass
            wedgeDetected := true
            wedgeLength := patternLen
            wedgeFirstHigh := high[patternLen]
            wedgeFirstLow := low[patternLen]
            wedgeUpperStart := highIntercept
            wedgeUpperEnd := resistanceNow
            wedgeLowerStart := lowIntercept
            wedgeLowerEnd := supportNow

if triangleDetected and not na(triangleLength)
    int triangleLeft = bar_index - triangleLength
    line.new(triangleLeft, triangleUpperStart, bar_index, triangleUpperEnd, xloc=xloc.bar_index, color=color.yellow, width=2, force_overlay=true)
    line.new(triangleLeft, triangleLowerStart, bar_index, triangleLowerEnd, xloc=xloc.bar_index, color=color.yellow, width=2, force_overlay=true)
    line.new(triangleLeft, triangleUpperStart, triangleLeft, triangleLowerStart, xloc=xloc.bar_index, color=color.yellow, width=2, force_overlay=true)
    drawRow(triangleLeft, bar_index, 3.0, color.yellow)

// Merge overlapping wedge detections into one converging outline and row segment.
var line mergedWedgeUpperLine = na
var line mergedWedgeLowerLine = na
var line mergedWedgeLeftLine = na
var line mergedWedgeRightLine = na
var box mergedWedgeRowBox = na
var int mergedWedgeLeft = na
var int mergedWedgeRight = na
var float mergedWedgeUpperStart = na
var float mergedWedgeLowerStart = na

if wedgeDetected and not na(wedgeLength)
    int candidateLeft = bar_index - wedgeLength
    int candidateRight = bar_index
    bool overlapsExistingWedge = not na(mergedWedgeRight) and candidateLeft <= mergedWedgeRight + 1

    if not overlapsExistingWedge
        mergedWedgeLeft := candidateLeft
        mergedWedgeRight := candidateRight
        mergedWedgeUpperStart := wedgeUpperStart
        mergedWedgeLowerStart := wedgeLowerStart
        mergedWedgeUpperLine := line.new(mergedWedgeLeft, mergedWedgeUpperStart, mergedWedgeRight, wedgeUpperEnd, xloc=xloc.bar_index, color=color.orange, width=2, force_overlay=true)
        mergedWedgeLowerLine := line.new(mergedWedgeLeft, mergedWedgeLowerStart, mergedWedgeRight, wedgeLowerEnd, xloc=xloc.bar_index, color=color.orange, width=2, force_overlay=true)
        mergedWedgeLeftLine := line.new(mergedWedgeLeft, mergedWedgeUpperStart, mergedWedgeLeft, mergedWedgeLowerStart, xloc=xloc.bar_index, color=color.orange, width=2, force_overlay=true)
        mergedWedgeRightLine := line.new(mergedWedgeRight, wedgeUpperEnd, mergedWedgeRight, wedgeLowerEnd, xloc=xloc.bar_index, color=color.orange, width=2, force_overlay=true)
        mergedWedgeRowBox := box.new(left=mergedWedgeLeft, top=2.12, right=mergedWedgeRight + 1, bottom=1.88, xloc=xloc.bar_index, border_color=color.orange, border_width=1, bgcolor=color.orange)
    else
        if candidateLeft < mergedWedgeLeft
            mergedWedgeLeft := candidateLeft
            mergedWedgeUpperStart := wedgeUpperStart
            mergedWedgeLowerStart := wedgeLowerStart

        mergedWedgeRight := math.max(mergedWedgeRight, candidateRight)
        line.set_xy1(mergedWedgeUpperLine, mergedWedgeLeft, mergedWedgeUpperStart)
        line.set_xy2(mergedWedgeUpperLine, mergedWedgeRight, wedgeUpperEnd)
        line.set_xy1(mergedWedgeLowerLine, mergedWedgeLeft, mergedWedgeLowerStart)
        line.set_xy2(mergedWedgeLowerLine, mergedWedgeRight, wedgeLowerEnd)
        line.set_xy1(mergedWedgeLeftLine, mergedWedgeLeft, mergedWedgeUpperStart)
        line.set_xy2(mergedWedgeLeftLine, mergedWedgeLeft, mergedWedgeLowerStart)
        line.set_xy1(mergedWedgeRightLine, mergedWedgeRight, wedgeUpperEnd)
        line.set_xy2(mergedWedgeRightLine, mergedWedgeRight, wedgeLowerEnd)
        box.set_left(mergedWedgeRowBox, mergedWedgeLeft)
        box.set_right(mergedWedgeRowBox, mergedWedgeRight + 1)

//====================================================================
// DOUBLE TOP
//====================================================================

float confirmedPivotHigh = ta.pivothigh(high, pivotStrength, pivotStrength)
var float priorTopPrice = na
var int priorTopBar = na
bool doubleTopDetected = false

if not na(confirmedPivotHigh)
    int secondTopBar = bar_index - pivotStrength
    float secondTopPrice = confirmedPivotHigh

    if not na(priorTopPrice) and not na(priorTopBar)
        int separation = secondTopBar - priorTopBar
        float topDifference = priorTopPrice > 0.0 ? math.abs(secondTopPrice - priorTopPrice) / priorTopPrice * 100.0 : na
        float neckline = na
        int necklineBar = na

        for offset = pivotStrength to maximumTopSeparation + pivotStrength
            if offset <= separation + pivotStrength
                if na(neckline) or low[offset] < neckline
                    neckline := low[offset]
                    necklineBar := bar_index - offset

        float higherTop = math.max(priorTopPrice, secondTopPrice)
        float decline = not na(neckline) and higherTop > 0.0 ? (1.0 - neckline / higherTop) * 100.0 : na
        bool separationPass = separation >= minimumTopSeparation and separation <= maximumTopSeparation
        bool matchingTops = not na(topDifference) and topDifference <= patternTolerance
        bool declinePass = not na(decline) and decline >= minimumMiddleDecline

        if separationPass and matchingTops and declinePass
            doubleTopDetected := true
            line.new(priorTopBar, priorTopPrice, necklineBar, neckline, xloc=xloc.bar_index, color=color.purple, width=2, force_overlay=true)
            line.new(necklineBar, neckline, secondTopBar, secondTopPrice, xloc=xloc.bar_index, color=color.purple, width=2, force_overlay=true)
            drawRow(priorTopBar, secondTopBar, 1.0, color.purple)

    priorTopPrice := secondTopPrice
    priorTopBar := secondTopBar

//====================================================================
// INVERSE CUP AND HANDLE
//====================================================================

bool inverseCupHandleDetected = false
int detectedCupLeftBar = na
int detectedCupTopBar = na
int detectedRightRimBar = na
int detectedHandleHighBar = na
float detectedLeftRim = na
float detectedCupHigh = na
float detectedRightRim = na
float detectedHandleHigh = na

for handleLen = handleMinBars to handleMaxBars
    for cupLen = cupMinBars to cupMaxBars by 5
        bool enoughCupHistory = not na(high[cupLen + handleLen])

        if enoughCupHistory
            int leftRimOffset = cupLen + handleLen
            int rightRimOffset = handleLen
            float leftRim = low[leftRimOffset]
            float rightRim = low[rightRimOffset]
            float rimAverage = (leftRim + rightRim) / 2.0
            float rimDifference = rimAverage > 0.0 ? math.abs(leftRim - rightRim) / rimAverage * 100.0 : na
            float cupHigh = na
            int cupHighOffset = na

            for offset = rightRimOffset to leftRimOffset
                if na(cupHigh) or high[offset] > cupHigh
                    cupHigh := high[offset]
                    cupHighOffset := offset

            float handleHigh = na
            int handleHighOffset = na

            for offset = 1 to handleLen - 1
                if na(handleHigh) or high[offset] > handleHigh
                    handleHigh := high[offset]
                    handleHighOffset := offset

            float cupHeightPrice = cupHigh - rimAverage
            float cupHeightPct = rimAverage > 0.0 ? cupHeightPrice / rimAverage * 100.0 : na
            float handleHeightPct = cupHeightPrice > 0.0 ? (handleHigh - rimAverage) / cupHeightPrice * 100.0 : na
            int topFromLeft = leftRimOffset - cupHighOffset
            bool topPositionPass = topFromLeft >= int(cupLen * 0.20) and topFromLeft <= int(cupLen * 0.80)
            bool rimsPass = not na(rimDifference) and rimDifference <= maximumRimDifference
            bool cupHeightPass = not na(cupHeightPct) and cupHeightPct >= minimumCupHeight and cupHeightPct <= maximumCupHeight
            bool handleHeightPass = not na(handleHeightPct) and handleHeightPct >= 0.0 and handleHeightPct <= maximumHandleHeight
            bool handleLowerHalfPass = handleHigh <= cupHigh - cupHeightPrice * 0.50
            float breakdownRim = math.min(leftRim, rightRim)
            bool cupBreakdownPass = close < breakdownRim and close[1] >= breakdownRim
            bool cupCandidate = rimsPass and cupHeightPass and topPositionPass and handleHeightPass and handleLowerHalfPass and cupBreakdownPass

            if cupCandidate
                inverseCupHandleDetected := true
                detectedCupLeftBar := bar_index - leftRimOffset
                detectedCupTopBar := bar_index - cupHighOffset
                detectedRightRimBar := bar_index - rightRimOffset
                detectedHandleHighBar := bar_index - handleHighOffset
                detectedLeftRim := leftRim
                detectedCupHigh := cupHigh
                detectedRightRim := rightRim
                detectedHandleHigh := handleHigh

if inverseCupHandleDetected
    line.new(detectedCupLeftBar, detectedLeftRim, detectedCupTopBar, detectedCupHigh, xloc=xloc.bar_index, color=color.aqua, width=2, force_overlay=true)
    line.new(detectedCupTopBar, detectedCupHigh, detectedRightRimBar, detectedRightRim, xloc=xloc.bar_index, color=color.aqua, width=2, force_overlay=true)
    line.new(detectedRightRimBar, detectedRightRim, detectedHandleHighBar, detectedHandleHigh, xloc=xloc.bar_index, color=color.aqua, width=2, force_overlay=true)
    line.new(detectedHandleHighBar, detectedHandleHigh, bar_index, close, xloc=xloc.bar_index, color=color.aqua, width=2, force_overlay=true)
    drawRow(detectedCupLeftBar, bar_index, 0.0, color.aqua)

//====================================================================
// BOTTOM-PANE SCALE AND SCREEN-ANCHORED PATTERN KEY
//====================================================================

plot(4.5, title="Upper Scale", color=color.new(color.white, 100), editable=false)
plot(-0.5, title="Lower Scale", color=color.new(color.white, 100), editable=false)

// Permanent row guides keep the five-pattern layout visible even when the
// displayed chart area contains no detections. Thick colored segments drawn
// by drawRow() still show the exact first and last bars of every pattern.
hline(4.0, "Bear Flag Row", color=color.new(color.red, 78), linestyle=hline.style_dotted)
hline(3.0, "Descending Triangle Row", color=color.new(color.yellow, 78), linestyle=hline.style_dotted)
hline(2.0, "Rising Wedge Row", color=color.new(color.orange, 78), linestyle=hline.style_dotted)
hline(1.0, "Double Top Row", color=color.new(color.purple, 78), linestyle=hline.style_dotted)
hline(0.0, "Inverse Cup and Handle Row", color=color.new(color.aqua, 78), linestyle=hline.style_dotted)

// Confirmation markers ensure one-bar signals remain visible in addition to
// the full-width historical pattern segments.
plot(newBearFlag ? 4.0 : na, title="Bear Flag Confirmations", color=color.red, linewidth=5, style=plot.style_circles)
plot(triangleDetected ? 3.0 : na, title="Descending Triangle Confirmations", color=color.yellow, linewidth=5, style=plot.style_circles)
plot(wedgeDetected ? 2.0 : na, title="Rising Wedge Confirmations", color=color.orange, linewidth=5, style=plot.style_circles)
plot(doubleTopDetected ? 1.0 : na, title="Double Top Confirmations", color=color.purple, linewidth=5, style=plot.style_circles)
plot(inverseCupHandleDetected ? 0.0 : na, title="Inverse Cup and Handle Confirmations", color=color.aqua, linewidth=5, style=plot.style_circles)

// Independent viewport-responsive labels. Using the left visible bar's time
// keeps the badges at the left edge while allowing every box to auto-size to
// its own text instead of sharing the longest table-column width.
var label bearFlagName = label.new(na, na, "", xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_left, color=color.red, textcolor=color.white, size=size.large)
var label triangleName = label.new(na, na, "", xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_left, color=color.yellow, textcolor=color.black, size=size.large)
var label wedgeName = label.new(na, na, "", xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_left, color=color.orange, textcolor=color.white, size=size.large)
var label doubleTopName = label.new(na, na, "", xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_left, color=color.purple, textcolor=color.white, size=size.large)
var label inverseCupName = label.new(na, na, "", xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_left, color=color.aqua, textcolor=color.black, size=size.large)

if barstate.islast
    int leftVisibleTime = chart.left_visible_bar_time
    label.set_xy(bearFlagName, leftVisibleTime, 4.0)
    label.set_text(bearFlagName, "Classic Bear Flag")
    label.set_xy(triangleName, leftVisibleTime, 3.0)
    label.set_text(triangleName, "Descending Triangle")
    label.set_xy(wedgeName, leftVisibleTime, 2.0)
    label.set_text(wedgeName, "Rising Wedge")
    label.set_xy(doubleTopName, leftVisibleTime, 1.0)
    label.set_text(doubleTopName, "Double Top")
    label.set_xy(inverseCupName, leftVisibleTime, 0.0)
    label.set_text(inverseCupName, "Inverse Cup and Handle")

alertcondition(newBearFlag, title="Bear Flag", message="Bear flag detected on {{ticker}}")
alertcondition(triangleDetected, title="Descending Triangle", message="Descending triangle breakdown detected on {{ticker}}")
alertcondition(wedgeDetected, title="Rising Wedge", message="Rising wedge breakdown detected on {{ticker}}")
alertcondition(doubleTopDetected, title="Double Top", message="Double top detected on {{ticker}}")
alertcondition(inverseCupHandleDetected, title="Inverse Cup and Handle", message="Inverse cup and handle breakdown detected on {{ticker}}")
````
