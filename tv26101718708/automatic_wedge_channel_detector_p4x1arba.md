# Automatic Wedge & Channel Detector

- url: https://www.tradingview.com/script/p4X1arBA-Automatic-Wedge-Channel-Detector/
- type: indicator
- pine_id: PUB;e2641b58779a4d808dbac324b116c170
- version: 1.0

## Description

[url=https://www.tradingview.com/x/fCoZjNsv/]https://www.tradingview.com/x/fCoZjNsv/[/url]

Automatic Wedge & Channel Detector identifies developing price structures directly on the chart, helping traders recognize where price is compressing, expanding, or moving within established boundaries.

Instead of requiring trendlines to be drawn manually, the indicator analyzes confirmed pivot highs and lows, tests multiple boundary combinations, and selects the structure that best fits recent price action. It can detect parallel channels, converging wedges, symmetrical triangles, ascending or descending triangle-style formations, and expanding structures.

The goal is not simply to draw two lines. The indicator evaluates how well price respects both boundaries by considering touches, spacing, violations, structural width, balance between the upper and lower sides, and the age of the pattern. This helps reduce arbitrary trendlines and prioritize structures that are better supported by actual price behavior.

[b]KEY FEATURES[/b]

[b]Automatic Structure Detection[/b]
Auto Mode searches recent confirmed pivots and selects the highest-scoring upper and lower boundary combination.

[b]Manual Structure Selection[/b]
Manual Mode allows advanced users to choose which historical pivots anchor each boundary.

[b]Multiple Pattern Types[/b]
Recognizes parallel channels, converging wedges, symmetrical triangles, ascending and descending triangle/wedge structures, and expanding formations.

[b]Dynamic Support and Resistance Zones[/b]
Optional shaded regions highlight the areas near each boundary where price may be more likely to react.

[b]Middle No-Trade Zone[/b]
An optional neutral zone identifies the center of the structure, where entries may offer less favorable positioning compared with trades near the boundaries.

[b]Centerline[/b]
The midpoint of the structure can be displayed as an additional reference for equilibrium, potential reactions, and profit management.

[b]Confirmed Breakout Detection[/b]
A breakout is recognized only after price closes beyond the structure by a configurable ATR-based distance for the required number of confirmation bars. This helps filter minor boundary breaches and wick-only moves.

Breakout Alerts
Alerts are available for confirmed upside and downside structural breaks.

Breakout and Reclaim Logic
If price returns inside the structure for the required number of bars, the previous breakout is treated as reclaimed.

[b]Structure Lifecycle Management[/b]
The indicator tracks whether a formation is active, approaching its apex, broken, reclaimed, or expired. Broken structures can remain visible temporarily so traders can review the breakout and watch for possible retests.

[b]Late-Stage Recognition[/b]
Converging formations change color when price approaches the apex or when the remaining width becomes unusually narrow. This warns that the structure may be mature and increasingly vulnerable to a breakout.

[b]Volatility-Adjusted Analysis[/b]
Touch tolerance, boundary violations, minimum width, breakout distance, and late-stage conditions are measured relative to ATR so the logic can adapt across markets and timeframes.


[b]HOW TO USE IT[/b]

For range or mean-reversion setups, traders can watch for reactions near the lower support zone or upper resistance zone while the structure remains active. The center of the formation is marked as a potential no-trade area because entries taken there often have less room to the next boundary and weaker risk-to-reward characteristics.

For breakout setups, traders can wait for a confirmed close beyond a boundary rather than reacting to the first wick through the line. A broken boundary may later become an area of support or resistance during a retest.

Converging wedges and triangles can also be used to identify volatility compression. As the boundaries narrow and price approaches the apex, traders can prepare for expansion without assuming the breakout direction in advance.

[b]AUTO MODE VS. MANUAL MODE[/b]

Auto Mode is designed for traders who want the indicator to continuously identify the strongest recent structure.

Manual Mode is intended for traders who prefer greater control over which pivots define the pattern. Pivot #0 represents the most recently confirmed pivot, Pivot #1 is the previous pivot, and so on.

[b]CUSTOM SOURCE[/b]

By default, the upper boundary is calculated from pivot highs and the lower boundary from pivot lows. Enabling Use Custom Source applies the selected source to both pivot calculations. This can be useful for traders who prefer structures based on closing prices or another custom data series rather than candle extremes.

[b]IMPORTANT NOTES[/b]

Pivot-based detection requires future bars to confirm a swing. Pivot markers are placed on the original pivot bars after confirmation, so structures are not identified at the exact moment the pivot first forms.

In Auto Mode, the selected structure may update when new pivots are confirmed or when a different combination earns a better score. This is expected behavior for a continuously adapting market-structure tool.

Wedges and channels provide context—not certainty. A boundary touch does not guarantee a reversal, and a confirmed break does not guarantee continuation. Traders should combine the indicator with their own trend analysis, price-action confirmation, volume analysis, risk management, and broader market context.

Automatic Wedge & Channel Detector is designed to make complex chart structure easier to see while preserving the discretion required to trade it intelligently.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// Original concept © veryfid
// Expanded / modernized version
//@version=6

indicator(
     "Wedge & Channel Detector",
     overlay = true,
     max_bars_back = 5000,
     max_lines_count = 60,
     max_labels_count = 100
)

// ============================================================================
// INPUTS
// ============================================================================

//-----------------------------------------------------------------------------
// Structure Selection
//-----------------------------------------------------------------------------
groupMode = "Structure Selection"

selectionMode = input.string(
     "Auto",
     "Selection Mode",
     options = ["Auto", "Manual"],
     group = groupMode
)

autoPivotCount = input.int(
     5,
     "Recent Pivots To Test",
     minval = 3,
     maxval = 7,
     group = groupMode
)

autoLookbackBars = input.int(
     250,
     "Auto Scoring Lookback",
     minval = 50,
     maxval = 500,
     group = groupMode
)

minAnchorSpacing = input.int(
     10,
     "Minimum Anchor Spacing",
     minval = 2,
     maxval = 200,
     group = groupMode
)

//-----------------------------------------------------------------------------
// Pivot Detection
//-----------------------------------------------------------------------------
groupPivot = "Pivot Detection"

upperLen = input.int(
     20,
     "Upper Pivot Length",
     minval = 1,
     group = groupPivot
)

lowerLen = input.int(
     20,
     "Lower Pivot Length",
     minval = 1,
     group = groupPivot
)

//-----------------------------------------------------------------------------
// Manual Pivot Selection
//-----------------------------------------------------------------------------
groupManual = "Manual Pivot Selection"

manualUpperStart = input.int(
     2,
     "Upper: From Pivot #",
     minval = 0,
     group = groupManual,
     inline = "upper"
)

manualUpperEnd = input.int(
     0,
     "To Pivot #",
     minval = 0,
     group = groupManual,
     inline = "upper"
)

manualLowerStart = input.int(
     3,
     "Lower: From Pivot #",
     minval = 0,
     group = groupManual,
     inline = "lower"
)

manualLowerEnd = input.int(
     0,
     "To Pivot #",
     minval = 0,
     group = groupManual,
     inline = "lower"
)

//-----------------------------------------------------------------------------
// Source
//-----------------------------------------------------------------------------
groupSource = "Source"

useCustomSource = input.bool(
     false,
     "Use Custom Source",
     group = groupSource
)

customSource = input.source(
     close,
     "Custom Source",
     group = groupSource
)

//-----------------------------------------------------------------------------
// Zones
//-----------------------------------------------------------------------------
groupZones = "Structure Zones"

showCenterline = input.bool(
     true,
     "Show Centerline",
     group = groupZones
)

showNoTradeZone = input.bool(
     true,
     "Show Middle No-Trade Zone",
     group = groupZones
)

noTradeLowPct = input.float(
     40.0,
     "No-Trade Lower %",
     minval = 0.0,
     maxval = 100.0,
     step = 1.0,
     group = groupZones
)

noTradeHighPct = input.float(
     60.0,
     "No-Trade Upper %",
     minval = 0.0,
     maxval = 100.0,
     step = 1.0,
     group = groupZones
)

showBoundaryZones = input.bool(
     true,
     "Show Support / Resistance Zones",
     group = groupZones
)

boundaryZonePct = input.float(
     20.0,
     "Boundary Zone %",
     minval = 1.0,
     maxval = 49.0,
     step = 1.0,
     group = groupZones
)

//-----------------------------------------------------------------------------
// Lifecycle
//-----------------------------------------------------------------------------
groupLifecycle = "Structure Lifecycle"

breakoutATR = input.float(
     0.30,
     "Breakout Distance (ATR)",
     minval = 0.05,
     maxval = 3.0,
     step = 0.05,
     group = groupLifecycle
)

breakoutConfirmBars = input.int(
     2,
     "Breakout Confirmation Bars",
     minval = 1,
     maxval = 10,
     group = groupLifecycle
)

expireAfterBreakBars = input.int(
     10,
     "Expire After Break Bars",
     minval = 1,
     maxval = 100,
     group = groupLifecycle
)

reclaimBars = input.int(
     2,
     "Reclaim Bars",
     minval = 1,
     maxval = 10,
     group = groupLifecycle
)

lateStageWidthATR = input.float(
     1.5,
     "Late Stage Width (ATR)",
     minval = 0.1,
     maxval = 10.0,
     step = 0.1,
     group = groupLifecycle
)

lateStageApexBars = input.int(
     15,
     "Late Stage Apex Distance",
     minval = 1,
     maxval = 100,
     group = groupLifecycle
)

showBrokenStructures = input.bool(
     true,
     "Keep Broken Structure Visible",
     group = groupLifecycle
)

//-----------------------------------------------------------------------------
// Quality
//-----------------------------------------------------------------------------
groupQuality = "Structure Quality"

touchToleranceATR = input.float(
     0.20,
     "Touch Tolerance (ATR)",
     minval = 0.05,
     maxval = 2.0,
     step = 0.05,
     group = groupQuality
)

violationToleranceATR = input.float(
     0.35,
     "Violation Tolerance (ATR)",
     minval = 0.05,
     maxval = 3.0,
     step = 0.05,
     group = groupQuality
)

minTouchSpacing = input.int(
     5,
     "Minimum Bars Between Touches",
     minval = 1,
     maxval = 100,
     group = groupQuality
)

minStructureWidthATR = input.float(
     1.0,
     "Minimum Width (ATR)",
     minval = 0.1,
     maxval = 20.0,
     step = 0.1,
     group = groupQuality
)

maxStructureWidthATR = input.float(
     20.0,
     "Maximum Preferred Width (ATR)",
     minval = 2.0,
     maxval = 100.0,
     step = 1.0,
     group = groupQuality
)

balancePenaltyStart = input.float(
     1.50,
     "Touch Imbalance Penalty Starts At",
     minval = 1.0,
     maxval = 5.0,
     step = 0.25,
     group = groupQuality
)

balancePenaltyStrength = input.float(
     8.0,
     "Touch Imbalance Penalty Strength",
     minval = 1.0,
     maxval = 20.0,
     step = 1.0,
     group = groupQuality
)

//-----------------------------------------------------------------------------
// Convergence Strength
//-----------------------------------------------------------------------------
groupConvergence = "Convergence Strength"

convergenceProjectionBars = input.int(
     50,
     "Measure Convergence Over Bars",
     minval = 10,
     maxval = 250,
     group = groupConvergence
)

weakConvergencePct = input.float(
     10.0,
     "Weak Convergence %",
     minval = 0.0,
     maxval = 100.0,
     step = 1.0,
     group = groupConvergence
)

strongConvergencePct = input.float(
     30.0,
     "Strong Convergence %",
     minval = 0.0,
     maxval = 100.0,
     step = 1.0,
     group = groupConvergence
)

//-----------------------------------------------------------------------------
// Confidence
//-----------------------------------------------------------------------------
groupConfidence = "Structure Confidence"

highConfidenceQuality = input.float(
     82.0,
     "High Confidence Minimum Quality",
     minval = 0.0,
     maxval = 100.0,
     step = 1.0,
     group = groupConfidence
)

mediumConfidenceQuality = input.float(
     65.0,
     "Medium Confidence Minimum Quality",
     minval = 0.0,
     maxval = 100.0,
     step = 1.0,
     group = groupConfidence
)

highConfidenceMinTouches = input.int(
     3,
     "High Confidence Min Touches Each Side",
     minval = 1,
     maxval = 10,
     group = groupConfidence
)

mediumConfidenceMinTouches = input.int(
     2,
     "Medium Confidence Min Touches Each Side",
     minval = 1,
     maxval = 10,
     group = groupConfidence
)

highConfidenceMaxViolations = input.int(
     2,
     "High Confidence Max Total Violations",
     minval = 0,
     maxval = 25,
     group = groupConfidence
)

mediumConfidenceMaxViolations = input.int(
     5,
     "Medium Confidence Max Total Violations",
     minval = 0,
     maxval = 50,
     group = groupConfidence
)

//-----------------------------------------------------------------------------
// Visuals
//-----------------------------------------------------------------------------
groupVisual = "Visuals"

// Fixed True Strength Index Ribbon palette. Keeping these as constants prevents
// TradingView from restoring older saved color-input values on existing charts.
color upperColor = #A83A68
color lowerColor = #26C6B8
color centerColor = #667582
color noTradeColor = color.new(#667582, 88)
color supportZoneColor = color.new(#26C6B8, 90)
color resistanceZoneColor = color.new(#A83A68, 90)
color brokenColor = #FF4F87
color lateStageColor = #67F5C4

lineWidth = input.int(
     2,
     "Boundary Width",
     minval = 1,
     maxval = 4,
     group = groupVisual
)

showPivotMarkers = input.bool(
     true,
     "Show Pivot Markers",
     group = groupVisual
)

// ============================================================================
// BASIC SERIES
// ============================================================================

float upperSource = useCustomSource ? customSource : high
float lowerSource = useCustomSource ? customSource : low
float atr = ta.atr(14)

// ============================================================================
// FUNCTIONS
// ============================================================================

f_line_price(
     int x1,
     float y1,
     int x2,
     float y2,
     int targetX
) =>
    float result = na

    if (
         not na(x1) and
         not na(x2) and
         x1 != x2
    )
        float slope = (y2 - y1) / float(x2 - x1)
        result := y1 + slope * float(targetX - x1)

    result

// ============================================================================
// JOINT STRUCTURE SCORE
// ============================================================================

f_score_structure(
     int ux1,
     float uy1,
     int ux2,
     float uy2,
     int lx1,
     float ly1,
     int lx2,
     float ly2
) =>
    float finalScore = na

    int upperTouchesLocal = 0
    int lowerTouchesLocal = 0
    int upperViolationsLocal = 0
    int lowerViolationsLocal = 0

    int lastUpperTouchX = na
    int lastLowerTouchX = na

    bool candidateValid = (
         ux2 > ux1 and
         lx2 > lx1 and
         ux2 - ux1 >= minAnchorSpacing and
         lx2 - lx1 >= minAnchorSpacing
    )

    if candidateValid

        float uSlope = (uy2 - uy1) / float(ux2 - ux1)
        float lSlope = (ly2 - ly1) / float(lx2 - lx1)

        int structureStart = math.max(
             ux1,
             lx1
        )

        float upperAtStart = f_line_price(
             ux1,
             uy1,
             ux2,
             uy2,
             structureStart
        )

        float lowerAtStart = f_line_price(
             lx1,
             ly1,
             lx2,
             ly2,
             structureStart
        )

        float widthAtStart = (
             upperAtStart -
             lowerAtStart
        )

        float upperCurrent = f_line_price(
             ux1,
             uy1,
             ux2,
             uy2,
             bar_index
        )

        float lowerCurrent = f_line_price(
             lx1,
             ly1,
             lx2,
             ly2,
             bar_index
        )

        float currentWidthLocal = (
             upperCurrent -
             lowerCurrent
        )

        bool convergingCandidate = (
             uSlope < lSlope
        )

        float candidateApexX = na

        float denominator = (
             uSlope -
             lSlope
        )

        if math.abs(denominator) > 0.0000001

            float upperIntercept = (
                 uy1 -
                 uSlope *
                 float(ux1)
            )

            float lowerIntercept = (
                 ly1 -
                 lSlope *
                 float(lx1)
            )

            candidateApexX := (
                 lowerIntercept -
                 upperIntercept
            ) / denominator

        bool apexAlreadyPassed = (
             convergingCandidate and
             not na(candidateApexX) and
             candidateApexX <= float(bar_index)
        )

        bool orderedAtStart = (
             widthAtStart > 0.0
        )

        bool orderedNow = (
             currentWidthLocal > 0.0
        )

        if (
             orderedAtStart and
             orderedNow and
             not apexAlreadyPassed
        )

            int availableBars = (
                 bar_index -
                 structureStart
            )

            int scanBars = math.min(
                 autoLookbackBars,
                 math.max(
                      0,
                      availableBars
                 )
            )

            for offset = 0 to scanBars

                int testX = (
                     bar_index -
                     offset
                )

                if testX >= structureStart

                    float testUpper = f_line_price(
                         ux1,
                         uy1,
                         ux2,
                         uy2,
                         testX
                    )

                    float testLower = f_line_price(
                         lx1,
                         ly1,
                         lx2,
                         ly2,
                         testX
                    )

                    float testATR = atr[offset]

                    float touchTol = (
                         not na(testATR)
                         ? testATR * touchToleranceATR
                         : 0.0
                    )

                    float violationTol = (
                         not na(testATR)
                         ? testATR * violationToleranceATR
                         : 0.0
                    )

                    bool upperNear = (
                         math.abs(
                              high[offset] -
                              testUpper
                         ) <= touchTol
                    )

                    bool lowerNear = (
                         math.abs(
                              low[offset] -
                              testLower
                         ) <= touchTol
                    )

                    bool upperViolation = (
                         close[offset] >
                         testUpper +
                         violationTol
                    )

                    bool lowerViolation = (
                         close[offset] <
                         testLower -
                         violationTol
                    )

                    if upperNear

                        bool spacedUpper = (
                             na(lastUpperTouchX) or
                             math.abs(
                                  testX -
                                  lastUpperTouchX
                             ) >= minTouchSpacing
                        )

                        if spacedUpper
                            upperTouchesLocal += 1
                            lastUpperTouchX := testX

                    if lowerNear

                        bool spacedLower = (
                             na(lastLowerTouchX) or
                             math.abs(
                                  testX -
                                  lastLowerTouchX
                             ) >= minTouchSpacing
                        )

                        if spacedLower
                            lowerTouchesLocal += 1
                            lastLowerTouchX := testX

                    if upperViolation
                        upperViolationsLocal += 1

                    if lowerViolation
                        lowerViolationsLocal += 1

            int totalTouchesLocal = (
                 upperTouchesLocal +
                 lowerTouchesLocal
            )

            int totalViolationsLocal = (
                 upperViolationsLocal +
                 lowerViolationsLocal
            )

            int minTouches = math.min(
                 upperTouchesLocal,
                 lowerTouchesLocal
            )

            int maxTouches = math.max(
                 upperTouchesLocal,
                 lowerTouchesLocal
            )

            float touchScore = math.min(
                 35.0,
                 float(totalTouchesLocal) *
                 5.0
            )

            float balanceFactor = (
                 totalTouchesLocal > 0
                 ? (
                      1.0 -
                      math.abs(
                           float(
                                upperTouchesLocal -
                                lowerTouchesLocal
                           )
                      ) /
                      float(totalTouchesLocal)
                   )
                 : 0.0
            )

            float balanceScore = (
                 balanceFactor *
                 15.0
            )

            float violationScore = math.max(
                 0.0,
                 25.0 -
                 float(totalViolationsLocal) *
                 3.0
            )

            int upperSpan = (
                 ux2 -
                 ux1
            )

            int lowerSpan = (
                 lx2 -
                 lx1
            )

            float averageSpan = (
                 float(upperSpan) +
                 float(lowerSpan)
            ) / 2.0

            float spanScore = math.min(
                 10.0,
                 averageSpan /
                 15.0
            )

            int newestAnchor = math.max(
                 ux2,
                 lx2
            )

            float recencyScore = math.max(
                 0.0,
                 10.0 -
                 float(
                      bar_index -
                      newestAnchor
                 ) *
                 0.15
            )

            float candidateWidthATR = (
                 atr > 0.0
                 ? currentWidthLocal /
                   atr
                 : na
            )

            float widthScore = 0.0

            if not na(candidateWidthATR)

                if (
                     candidateWidthATR >= minStructureWidthATR and
                     candidateWidthATR <= maxStructureWidthATR
                )

                    widthScore := 5.0

                else if (
                     candidateWidthATR <
                     minStructureWidthATR
                )

                    widthScore := math.max(
                         0.0,
                         (
                              candidateWidthATR /
                              minStructureWidthATR
                         ) *
                         5.0
                    )

                else

                    widthScore := math.max(
                         0.0,
                         5.0 -
                         (
                              candidateWidthATR -
                              maxStructureWidthATR
                         ) *
                         0.25
                    )

            finalScore := (
                 touchScore +
                 balanceScore +
                 violationScore +
                 spanScore +
                 recencyScore +
                 widthScore
            )

            // -----------------------------------------------------------
            // Bilateral validation
            // -----------------------------------------------------------

            if minTouches < 2

                finalScore := math.min(
                     finalScore,
                     59.0
                )

            else if minTouches < 3

                finalScore := math.min(
                     finalScore,
                     84.0
                )

            // -----------------------------------------------------------
            // Stronger imbalance penalty
            // -----------------------------------------------------------

            if minTouches > 0

                float touchRatio = float(maxTouches) / float(minTouches)

                if touchRatio > balancePenaltyStart

                    float imbalancePenalty = (touchRatio - balancePenaltyStart) * balancePenaltyStrength

                    finalScore -= imbalancePenalty

                // 2:1 or worse can never be Excellent.
                if touchRatio >= 2.0
                    finalScore := math.min(finalScore, 84.0)

                // 2.5:1 or worse gets capped below strong Good.
                if touchRatio >= 2.5
                    finalScore := math.min(finalScore, 74.0)

                // 3:1 or worse is only Fair.
                if touchRatio >= 3.0
                    finalScore := math.min(finalScore, 59.0)

            finalScore := math.max(0.0, math.min(100.0, finalScore))

// ============================================================================
// PIVOTS
// ============================================================================

float pivotHigh = ta.pivothigh(
     upperSource,
     upperLen,
     upperLen
)

float pivotLow = ta.pivotlow(
     lowerSource,
     lowerLen,
     lowerLen
)

bool newUpperPivot = (
     not na(pivotHigh)
)

bool newLowerPivot = (
     not na(pivotLow)
)

// ============================================================================
// PIVOT ARRAYS
// ============================================================================

var array<int> upperPivotBars = array.new_int()
var array<float> upperPivotPrices = array.new_float()

var array<int> lowerPivotBars = array.new_int()
var array<float> lowerPivotPrices = array.new_float()

if newUpperPivot

    array.unshift(
         upperPivotBars,
         bar_index -
         upperLen
    )

    array.unshift(
         upperPivotPrices,
         pivotHigh
    )

    if (
         array.size(
              upperPivotBars
         ) >
         autoPivotCount
    )

        array.pop(
             upperPivotBars
        )

        array.pop(
             upperPivotPrices
        )

if newLowerPivot

    array.unshift(
         lowerPivotBars,
         bar_index -
         lowerLen
    )

    array.unshift(
         lowerPivotPrices,
         pivotLow
    )

    if (
         array.size(
              lowerPivotBars
         ) >
         autoPivotCount
    )

        array.pop(
             lowerPivotBars
        )

        array.pop(
             lowerPivotPrices
        )

// ============================================================================
// AUTO STRUCTURE SELECTION
// ============================================================================

var int autoUpperX1 = na
var float autoUpperY1 = na

var int autoUpperX2 = na
var float autoUpperY2 = na

var int autoLowerX1 = na
var float autoLowerY1 = na

var int autoLowerX2 = na
var float autoLowerY2 = na

var float autoSelectionScore = na

bool shouldRescanAuto = (
     selectionMode == "Auto" and
     (
          newUpperPivot or
          newLowerPivot or
          na(autoSelectionScore)
     )
)

if (
     shouldRescanAuto and
     array.size(
          upperPivotBars
     ) >= 2 and
     array.size(
          lowerPivotBars
     ) >= 2
)

    float bestScore = na

    int bestUX1 = na
    float bestUY1 = na

    int bestUX2 = na
    float bestUY2 = na

    int bestLX1 = na
    float bestLY1 = na

    int bestLX2 = na
    float bestLY2 = na

    int upperCount = array.size(
         upperPivotBars
    )

    int lowerCount = array.size(
         lowerPivotBars
    )

    for uNew = 0 to upperCount - 2

        for uOld = uNew + 1 to upperCount - 1

            int testUX1 = array.get(
                 upperPivotBars,
                 uOld
            )

            float testUY1 = array.get(
                 upperPivotPrices,
                 uOld
            )

            int testUX2 = array.get(
                 upperPivotBars,
                 uNew
            )

            float testUY2 = array.get(
                 upperPivotPrices,
                 uNew
            )

            for lNew = 0 to lowerCount - 2

                for lOld = lNew + 1 to lowerCount - 1

                    int testLX1 = array.get(
                         lowerPivotBars,
                         lOld
                    )

                    float testLY1 = array.get(
                         lowerPivotPrices,
                         lOld
                    )

                    int testLX2 = array.get(
                         lowerPivotBars,
                         lNew
                    )

                    float testLY2 = array.get(
                         lowerPivotPrices,
                         lNew
                    )

                    float candidateScore = f_score_structure(
                         testUX1,
                         testUY1,
                         testUX2,
                         testUY2,
                         testLX1,
                         testLY1,
                         testLX2,
                         testLY2
                    )

                    bool betterCandidate = (
                         not na(candidateScore) and
                         (
                              na(bestScore) or
                              candidateScore >
                              bestScore
                         )
                    )

                    if betterCandidate

                        bestScore := candidateScore

                        bestUX1 := testUX1
                        bestUY1 := testUY1

                        bestUX2 := testUX2
                        bestUY2 := testUY2

                        bestLX1 := testLX1
                        bestLY1 := testLY1

                        bestLX2 := testLX2
                        bestLY2 := testLY2

    if not na(bestUX1)

        autoUpperX1 := bestUX1
        autoUpperY1 := bestUY1

        autoUpperX2 := bestUX2
        autoUpperY2 := bestUY2

        autoLowerX1 := bestLX1
        autoLowerY1 := bestLY1

        autoLowerX2 := bestLX2
        autoLowerY2 := bestLY2

        autoSelectionScore := bestScore

// ============================================================================
// MANUAL ANCHORS
// ============================================================================

float manualUpperY1 = ta.valuewhen(
     newUpperPivot,
     pivotHigh,
     manualUpperStart
)

float manualUpperY2 = ta.valuewhen(
     newUpperPivot,
     pivotHigh,
     manualUpperEnd
)

int manualUpperX1 = int(
     ta.valuewhen(
          newUpperPivot,
          bar_index -
          upperLen,
          manualUpperStart
     )
)

int manualUpperX2 = int(
     ta.valuewhen(
          newUpperPivot,
          bar_index -
          upperLen,
          manualUpperEnd
     )
)

float manualLowerY1 = ta.valuewhen(
     newLowerPivot,
     pivotLow,
     manualLowerStart
)

float manualLowerY2 = ta.valuewhen(
     newLowerPivot,
     pivotLow,
     manualLowerEnd
)

int manualLowerX1 = int(
     ta.valuewhen(
          newLowerPivot,
          bar_index -
          lowerLen,
          manualLowerStart
     )
)

int manualLowerX2 = int(
     ta.valuewhen(
          newLowerPivot,
          bar_index -
          lowerLen,
          manualLowerEnd
     )
)

// ============================================================================
// ACTIVE ANCHORS
// ============================================================================

int upperX1 = (
     selectionMode ==
     "Auto"
     ? autoUpperX1
     : manualUpperX1
)

float upperY1 = (
     selectionMode ==
     "Auto"
     ? autoUpperY1
     : manualUpperY1
)

int upperX2 = (
     selectionMode ==
     "Auto"
     ? autoUpperX2
     : manualUpperX2
)

float upperY2 = (
     selectionMode ==
     "Auto"
     ? autoUpperY2
     : manualUpperY2
)

int lowerX1 = (
     selectionMode ==
     "Auto"
     ? autoLowerX1
     : manualLowerX1
)

float lowerY1 = (
     selectionMode ==
     "Auto"
     ? autoLowerY1
     : manualLowerY1
)

int lowerX2 = (
     selectionMode ==
     "Auto"
     ? autoLowerX2
     : manualLowerX2
)

float lowerY2 = (
     selectionMode ==
     "Auto"
     ? autoLowerY2
     : manualLowerY2
)

// ============================================================================
// VALIDATION
// ============================================================================

bool validUpper = (
     not na(upperX1) and
     not na(upperX2) and
     not na(upperY1) and
     not na(upperY2) and
     upperX1 != upperX2
)

bool validLower = (
     not na(lowerX1) and
     not na(lowerX2) and
     not na(lowerY1) and
     not na(lowerY2) and
     lowerX1 != lowerX2
)

bool structureValid = (
     validUpper and
     validLower
)

// ============================================================================
// CURRENT VALUES
// ============================================================================

float upperNow = (
     validUpper
     ? f_line_price(
          upperX1,
          upperY1,
          upperX2,
          upperY2,
          bar_index
       )
     : na
)

float lowerNow = (
     validLower
     ? f_line_price(
          lowerX1,
          lowerY1,
          lowerX2,
          lowerY2,
          bar_index
       )
     : na
)

float structureWidth = (
     structureValid
     ? upperNow -
       lowerNow
     : na
)

bool boundariesOrdered = (
     structureValid and
     not na(structureWidth) and
     structureWidth > 0.0
)

// ============================================================================
// SLOPES / GEOMETRY
// ============================================================================

float upperSlope = (
     validUpper
     ? (
          upperY2 -
          upperY1
       ) /
       float(
          upperX2 -
          upperX1
       )
     : na
)

float lowerSlope = (
     validLower
     ? (
          lowerY2 -
          lowerY1
       ) /
       float(
          lowerX2 -
          lowerX1
       )
     : na
)

bool converging = (
     structureValid and
     upperSlope <
     lowerSlope
)

bool expanding = (
     structureValid and
     upperSlope >
     lowerSlope
)

float slopeDiff = (
     structureValid
     ? math.abs(
          upperSlope -
          lowerSlope
       )
     : na
)

float largestSlope = (
     structureValid
     ? math.max(
          math.abs(
               upperSlope
          ),
          math.abs(
               lowerSlope
          )
       )
     : na
)

bool roughlyParallel = (
     structureValid and
     (
          largestSlope == 0.0 or
          slopeDiff <=
          largestSlope *
          0.10
     )
)

// ============================================================================
// APEX
// ============================================================================

float apexX = na

if (
     structureValid and
     not roughlyParallel
)

    float upperIntercept = (
         upperY1 -
         upperSlope *
         float(
              upperX1
         )
    )

    float lowerIntercept = (
         lowerY1 -
         lowerSlope *
         float(
              lowerX1
         )
    )

    float denominator = (
         upperSlope -
         lowerSlope
    )

    if (
         math.abs(
              denominator
         ) >
         0.0000001
    )

        apexX := (lowerIntercept - upperIntercept) / denominator

float barsToApex = (
     converging and
     not na(apexX)
     ? apexX -
       float(
            bar_index
       )
     : na
)

bool apexPassed = (
     converging and
     not na(
          barsToApex
     ) and
     barsToApex <= 0.0
)

// ============================================================================
// WIDTH
// ============================================================================

float widthATR = (
     boundariesOrdered and
     atr > 0.0
     ? structureWidth /
       atr
     : na
)

// ============================================================================
// CONVERGENCE STRENGTH
// ============================================================================

float projectedUpper = (
     structureValid
     ? f_line_price(
          upperX1,
          upperY1,
          upperX2,
          upperY2,
          bar_index +
          convergenceProjectionBars
       )
     : na
)

float projectedLower = (
     structureValid
     ? f_line_price(
          lowerX1,
          lowerY1,
          lowerX2,
          lowerY2,
          bar_index +
          convergenceProjectionBars
       )
     : na
)

float projectedWidth = (
     structureValid
     ? projectedUpper -
       projectedLower
     : na
)

float convergencePct = (
     converging and
     not na(
          structureWidth
     ) and
     structureWidth > 0.0 and
     not na(
          projectedWidth
     )
     ? (
          (
               structureWidth -
               projectedWidth
          ) /
          structureWidth
       ) *
       100.0
     : na
)

string convergenceText = (
     "N/A"
)

if (
     converging and
     not na(
          convergencePct
     )
)

    if (
         convergencePct >=
         strongConvergencePct
    )

        convergenceText := "Strong"

    else if (
         convergencePct >=
         weakConvergencePct
    )

        convergenceText := "Moderate"

    else

        convergenceText := "Weak"

// ============================================================================
// LATE STAGE
// ============================================================================

bool lateByWidth = (
     converging and
     not na(
          widthATR
     ) and
     widthATR <=
     lateStageWidthATR
)

bool lateByApex = (
     converging and
     not na(
          barsToApex
     ) and
     barsToApex > 0.0 and
     barsToApex <=
     lateStageApexBars
)

bool lateStage = (
     not apexPassed and
     (
          lateByWidth or
          lateByApex
     )
)

// ============================================================================
// STRUCTURE TYPE
// ============================================================================

string structureType = (
     "Unavailable"
)

if structureValid

    if roughlyParallel

        structureType := "Channel"

    else if converging

        if (
             upperSlope < 0.0 and
             lowerSlope > 0.0
        )

            structureType := (
                 "Symmetrical Triangle"
            )

        else if (
             upperSlope < 0.0 and
             lowerSlope >= 0.0
        )

            structureType := (
                 "Descending Triangle/Wedge"
            )

        else if (
             upperSlope <= 0.0 and
             lowerSlope > 0.0
        )

            structureType := (
                 "Ascending Triangle/Wedge"
            )

        else

            structureType := (
                 "Converging Wedge"
            )

    else if expanding

        structureType := (
             "Expanding Structure"
        )

    else

        structureType := (
             "Structure"
        )

// ============================================================================
// STRUCTURE CHANGE
// ============================================================================

bool structureChanged = (
     structureValid and
     (
          upperX1 !=
          upperX1[1] or
          upperX2 !=
          upperX2[1] or
          lowerX1 !=
          lowerX1[1] or
          lowerX2 !=
          lowerX2[1]
     )
)

// ============================================================================
// LIVE QUALITY METRICS
// ============================================================================

int liveUpperTouches = 0
int liveLowerTouches = 0

int liveUpperViolations = 0
int liveLowerViolations = 0

int lastUpperTouchBar = na
int lastLowerTouchBar = na

if structureValid

    int metricStartX = math.max(
         upperX1,
         lowerX1
    )

    int metricAvailableBars = (
         bar_index -
         metricStartX
    )

    int metricScanBars = math.min(
         autoLookbackBars,
         math.max(
              0,
              metricAvailableBars
         )
    )

    for offset = 0 to metricScanBars

        int testX = (
             bar_index -
             offset
        )

        if (
             testX >=
             metricStartX
        )

            float metricUpper = f_line_price(
                 upperX1,
                 upperY1,
                 upperX2,
                 upperY2,
                 testX
            )

            float metricLower = f_line_price(
                 lowerX1,
                 lowerY1,
                 lowerX2,
                 lowerY2,
                 testX
            )

            float metricATR = (
                 atr[offset]
            )

            float metricTouchTol = (
                 not na(metricATR)
                 ? metricATR *
                   touchToleranceATR
                 : 0.0
            )

            float metricViolationTol = (
                 not na(metricATR)
                 ? metricATR *
                   violationToleranceATR
                 : 0.0
            )

            bool metricUpperNear = (
                 math.abs(
                      high[offset] -
                      metricUpper
                 ) <=
                 metricTouchTol
            )

            bool metricLowerNear = (
                 math.abs(
                      low[offset] -
                      metricLower
                 ) <=
                 metricTouchTol
            )

            bool metricUpperViolation = (
                 close[offset] >
                 metricUpper +
                 metricViolationTol
            )

            bool metricLowerViolation = (
                 close[offset] <
                 metricLower -
                 metricViolationTol
            )

            if metricUpperNear

                bool spacedUpper = (
                     na(
                          lastUpperTouchBar
                     ) or
                     math.abs(
                          testX -
                          lastUpperTouchBar
                     ) >=
                     minTouchSpacing
                )

                if spacedUpper

                    liveUpperTouches += 1
                    lastUpperTouchBar := testX

            if metricLowerNear

                bool spacedLower = (
                     na(
                          lastLowerTouchBar
                     ) or
                     math.abs(
                          testX -
                          lastLowerTouchBar
                     ) >=
                     minTouchSpacing
                )

                if spacedLower

                    liveLowerTouches += 1
                    lastLowerTouchBar := testX

            if metricUpperViolation

                liveUpperViolations += 1

            if metricLowerViolation

                liveLowerViolations += 1

float liveQualityScore = (
     structureValid
     ? f_score_structure(
          upperX1,
          upperY1,
          upperX2,
          upperY2,
          lowerX1,
          lowerY1,
          lowerX2,
          lowerY2
       )
     : na
)

// ============================================================================
// LIFECYCLE
// ============================================================================

var int breakDirection = 0
var int breakBar = na

var float frozenQualityScore = na

var int frozenUpperTouches = na
var int frozenLowerTouches = na

var int frozenUpperViolations = na
var int frozenLowerViolations = na

var bool frozenAtApex = false

if structureChanged

    breakDirection := 0
    breakBar := na

    frozenQualityScore := na

    frozenUpperTouches := na
    frozenLowerTouches := na

    frozenUpperViolations := na
    frozenLowerViolations := na

    frozenAtApex := false

int aboveBreakCount = 0
int belowBreakCount = 0

if (
     boundariesOrdered and
     not apexPassed
)

    for offset = 0 to breakoutConfirmBars - 1

        int testX = (
             bar_index -
             offset
        )

        float testUpper = f_line_price(
             upperX1,
             upperY1,
             upperX2,
             upperY2,
             testX
        )

        float testLower = f_line_price(
             lowerX1,
             lowerY1,
             lowerX2,
             lowerY2,
             testX
        )

        float testATR = (
             atr[offset]
        )

        if (
             not na(testATR) and
             close[offset] >
             testUpper +
             testATR *
             breakoutATR
        )

            aboveBreakCount += 1

        if (
             not na(testATR) and
             close[offset] <
             testLower -
             testATR *
             breakoutATR
        )

            belowBreakCount += 1

bool confirmedBreakUp = (
     aboveBreakCount ==
     breakoutConfirmBars
)

bool confirmedBreakDown = (
     belowBreakCount ==
     breakoutConfirmBars
)

if (
     breakDirection == 0 and
     confirmedBreakUp
)

    breakDirection := 1
    breakBar := bar_index

    frozenQualityScore := liveQualityScore

    frozenUpperTouches := liveUpperTouches
    frozenLowerTouches := liveLowerTouches

    frozenUpperViolations := liveUpperViolations
    frozenLowerViolations := liveLowerViolations

if (
     breakDirection == 0 and
     confirmedBreakDown
)

    breakDirection := -1
    breakBar := bar_index

    frozenQualityScore := liveQualityScore

    frozenUpperTouches := liveUpperTouches
    frozenLowerTouches := liveLowerTouches

    frozenUpperViolations := liveUpperViolations
    frozenLowerViolations := liveLowerViolations

if (
     apexPassed and
     not frozenAtApex and
     na(
          frozenQualityScore
     )
)

    frozenQualityScore := (
         not na(
              liveQualityScore
         )
         ? liveQualityScore
         : autoSelectionScore
    )

    frozenUpperTouches := liveUpperTouches
    frozenLowerTouches := liveLowerTouches

    frozenUpperViolations := liveUpperViolations
    frozenLowerViolations := liveLowerViolations

    frozenAtApex := true

// ============================================================================
// RECLAIM
// ============================================================================

int reclaimCount = 0

if (
     breakDirection != 0 and
     boundariesOrdered
)

    for offset = 0 to reclaimBars - 1

        int testX = (
             bar_index -
             offset
        )

        float testUpper = f_line_price(
             upperX1,
             upperY1,
             upperX2,
             upperY2,
             testX
        )

        float testLower = f_line_price(
             lowerX1,
             lowerY1,
             lowerX2,
             lowerY2,
             testX
        )

        if (
             close[offset] <=
             testUpper and
             close[offset] >=
             testLower
        )

            reclaimCount += 1

bool confirmedReclaim = (
     breakDirection != 0 and
     reclaimCount ==
     reclaimBars
)

if confirmedReclaim

    breakDirection := 0
    breakBar := na

    frozenQualityScore := na

    frozenUpperTouches := na
    frozenLowerTouches := na

    frozenUpperViolations := na
    frozenLowerViolations := na

bool structureExpired = (
     apexPassed or
     (
          breakDirection != 0 and
          not na(
               breakBar
          ) and
          bar_index -
          breakBar >=
          expireAfterBreakBars
     )
)

// ============================================================================
// DISPLAY QUALITY
// ============================================================================

float displayQualityScore = (
     not na(
          frozenQualityScore
     )
     ? frozenQualityScore
     : liveQualityScore
)

int displayUpperTouches = (
     not na(
          frozenUpperTouches
     )
     ? frozenUpperTouches
     : liveUpperTouches
)

int displayLowerTouches = (
     not na(
          frozenLowerTouches
     )
     ? frozenLowerTouches
     : liveLowerTouches
)

int displayUpperViolations = (
     not na(
          frozenUpperViolations
     )
     ? frozenUpperViolations
     : liveUpperViolations
)

int displayLowerViolations = (
     not na(
          frozenLowerViolations
     )
     ? frozenLowerViolations
     : liveLowerViolations
)

int displayTotalViolations = (
     displayUpperViolations +
     displayLowerViolations
)

int displayMinTouches = math.min(
     displayUpperTouches,
     displayLowerTouches
)

int displayMaxTouches = math.max(
     displayUpperTouches,
     displayLowerTouches
)

float displayTouchRatio = (
     displayMinTouches > 0
     ? float(
          displayMaxTouches
       ) /
       float(
          displayMinTouches
       )
     : na
)

string qualityText = (
     "Unavailable"
)

if not na(
     displayQualityScore
)

    if (
         displayQualityScore >= 85.0 and
         displayMinTouches >= 3
    )

        qualityText := "Excellent"

    else if (
         displayQualityScore >= 65.0 and
         displayMinTouches >= 2
    )

        qualityText := "Good"

    else if (
         displayQualityScore >= 45.0
    )

        qualityText := "Fair"

    else

        qualityText := "Poor"

// ============================================================================
// STRUCTURE CONFIDENCE
// ============================================================================

string confidenceText = (
     "Low"
)

bool confidenceBalanceHigh = (
     not na(
          displayTouchRatio
     ) and
     displayTouchRatio <=
     1.75
)

bool confidenceBalanceMedium = (
     not na(
          displayTouchRatio
     ) and
     displayTouchRatio <=
     2.25
)

bool highConfidence = (
     not na(
          displayQualityScore
     ) and
     displayQualityScore >=
     highConfidenceQuality and
     displayMinTouches >=
     highConfidenceMinTouches and
     displayTotalViolations <=
     highConfidenceMaxViolations and
     confidenceBalanceHigh
)

bool mediumConfidence = (
     not na(
          displayQualityScore
     ) and
     displayQualityScore >=
     mediumConfidenceQuality and
     displayMinTouches >=
     mediumConfidenceMinTouches and
     displayTotalViolations <=
     mediumConfidenceMaxViolations and
     confidenceBalanceMedium
)

if highConfidence

    confidenceText := "High"

else if mediumConfidence

    confidenceText := "Medium"

else

    confidenceText := "Low"

// ============================================================================
// STATUS
// ============================================================================

string lifecycleStatus = (
     "Unavailable"
)

if structureValid

    if apexPassed

        lifecycleStatus := (
             "Apex Passed"
        )

    else if structureExpired

        lifecycleStatus := (
             "Expired"
        )

    else if breakDirection == 1

        lifecycleStatus := (
             "Broken Up"
        )

    else if breakDirection == -1

        lifecycleStatus := (
             "Broken Down"
        )

    else if lateStage

        lifecycleStatus := (
             "Late Stage"
        )

    else

        lifecycleStatus := (
             "Active"
        )

// ============================================================================
// POSITION
// ============================================================================

float positionPct = (
     boundariesOrdered
     ? (
          (
               close -
               lowerNow
          ) /
          structureWidth
       ) *
       100.0
     : na
)

string locationText = (
     "Unavailable"
)

if boundariesOrdered

    if structureExpired

        locationText := (
             "Expired Structure"
        )

    else if breakDirection == 1

        locationText := (
             "Above Structure"
        )

    else if breakDirection == -1

        locationText := (
             "Below Structure"
        )

    else if positionPct < 0.0

        locationText := (
             "Below Support"
        )

    else if positionPct > 100.0

        locationText := (
             "Above Resistance"
        )

    else if (
         positionPct <=
         boundaryZonePct
    )

        locationText := (
             "Support Zone"
        )

    else if (
         positionPct >=
         (
              100.0 -
              boundaryZonePct
         )
    )

        locationText := (
             "Resistance Zone"
        )

    else if (
         positionPct >=
         noTradeLowPct and
         positionPct <=
         noTradeHighPct
    )

        locationText := (
             "Middle / No-Trade"
        )

    else if positionPct < 50.0

        locationText := (
             "Lower Half"
        )

    else

        locationText := (
             "Upper Half"
        )

// ============================================================================
// TRADEABILITY
// ============================================================================

bool structureTradable = (
     boundariesOrdered and
     breakDirection == 0 and
     not structureExpired and
     not lateStage and
     not apexPassed
)

// ============================================================================
// MAIN LINES
// ============================================================================

var line upperLine = na
var line lowerLine = na

color currentUpperColor = (
     structureExpired or
     breakDirection != 0
     ? brokenColor
     : lateStage
     ? lateStageColor
     : upperColor
)

color currentLowerColor = (
     structureExpired or
     breakDirection != 0
     ? brokenColor
     : lateStage
     ? lateStageColor
     : lowerColor
)

if validUpper

    if na(
         upperLine
    )

        upperLine := line.new(
             upperX1,
             upperY1,
             upperX2,
             upperY2,
             xloc = xloc.bar_index,
             extend = extend.right,
             color = currentUpperColor,
             width = lineWidth
        )

    else

        line.set_xy1(
             upperLine,
             upperX1,
             upperY1
        )

        line.set_xy2(
             upperLine,
             upperX2,
             upperY2
        )

        line.set_extend(
             upperLine,
             extend.right
        )

        line.set_color(
             upperLine,
             currentUpperColor
        )

        line.set_width(
             upperLine,
             lineWidth
        )

else

    if not na(
         upperLine
    )

        line.delete(
             upperLine
        )

        upperLine := na

if validLower

    if na(
         lowerLine
    )

        lowerLine := line.new(
             lowerX1,
             lowerY1,
             lowerX2,
             lowerY2,
             xloc = xloc.bar_index,
             extend = extend.right,
             color = currentLowerColor,
             width = lineWidth
        )

    else

        line.set_xy1(
             lowerLine,
             lowerX1,
             lowerY1
        )

        line.set_xy2(
             lowerLine,
             lowerX2,
             lowerY2
        )

        line.set_extend(
             lowerLine,
             extend.right
        )

        line.set_color(
             lowerLine,
             currentLowerColor
        )

        line.set_width(
             lowerLine,
             lineWidth
        )

else

    if not na(
         lowerLine
    )

        line.delete(
             lowerLine
        )

        lowerLine := na

// ============================================================================
// DERIVED COORDINATES
// ============================================================================

int derivedX1 = (
     structureValid
     ? math.max(
          math.min(
               upperX1,
               upperX2
          ),
          math.min(
               lowerX1,
               lowerX2
          )
       )
     : na
)

int derivedX2 = (
     structureValid
     ? math.max(
          upperX2,
          lowerX2
       )
     : na
)

int safeDerivedX2 = (
     structureValid
     ? math.max(
          derivedX2,
          derivedX1 + 1
       )
     : na
)

float u1 = (
     structureValid
     ? f_line_price(
          upperX1,
          upperY1,
          upperX2,
          upperY2,
          derivedX1
       )
     : na
)

float l1 = (
     structureValid
     ? f_line_price(
          lowerX1,
          lowerY1,
          lowerX2,
          lowerY2,
          derivedX1
       )
     : na
)

float u2 = (
     structureValid
     ? f_line_price(
          upperX1,
          upperY1,
          upperX2,
          upperY2,
          safeDerivedX2
       )
     : na
)

float l2 = (
     structureValid
     ? f_line_price(
          lowerX1,
          lowerY1,
          lowerX2,
          lowerY2,
          safeDerivedX2
       )
     : na
)

float w1 = (
     structureValid
     ? u1 -
       l1
     : na
)

float w2 = (
     structureValid
     ? u2 -
       l2
     : na
)

bool derivedValid = (
     structureValid and
     not na(
          w1
     ) and
     not na(
          w2
     ) and
     w1 > 0.0 and
     w2 > 0.0
)

// ============================================================================
// DERIVED PRICES
// ============================================================================

float center1 = (
     derivedValid
     ? l1 +
       w1 *
       0.50
     : na
)

float center2 = (
     derivedValid
     ? l2 +
       w2 *
       0.50
     : na
)

float ntLow1 = (
     derivedValid
     ? l1 +
       w1 *
       noTradeLowPct /
       100.0
     : na
)

float ntLow2 = (
     derivedValid
     ? l2 +
       w2 *
       noTradeLowPct /
       100.0
     : na
)

float ntHigh1 = (
     derivedValid
     ? l1 +
       w1 *
       noTradeHighPct /
       100.0
     : na
)

float ntHigh2 = (
     derivedValid
     ? l2 +
       w2 *
       noTradeHighPct /
       100.0
     : na
)

float supportZone1 = (
     derivedValid
     ? l1 +
       w1 *
       boundaryZonePct /
       100.0
     : na
)

float supportZone2 = (
     derivedValid
     ? l2 +
       w2 *
       boundaryZonePct /
       100.0
     : na
)

float resistanceZone1 = (
     derivedValid
     ? l1 +
       w1 *
       (
            1.0 -
            boundaryZonePct /
            100.0
       )
     : na
)

float resistanceZone2 = (
     derivedValid
     ? l2 +
       w2 *
       (
            1.0 -
            boundaryZonePct /
            100.0
       )
     : na
)

// ============================================================================
// CENTERLINE
// ============================================================================

var line centerLine = na

if (
     showCenterline and
     derivedValid
)

    if na(
         centerLine
    )

        centerLine := line.new(
             derivedX1,
             center1,
             safeDerivedX2,
             center2,
             xloc = xloc.bar_index,
             extend = extend.right,
             color = centerColor,
             style = line.style_dashed,
             width = 1
        )

    else

        line.set_xy1(
             centerLine,
             derivedX1,
             center1
        )

        line.set_xy2(
             centerLine,
             safeDerivedX2,
             center2
        )

        line.set_extend(
             centerLine,
             extend.right
        )

else

    if not na(
         centerLine
    )

        line.delete(
             centerLine
        )

        centerLine := na

// ============================================================================
// ZONE DRAWING
// ============================================================================

bool drawZones = (
     derivedValid and
     (
          showBrokenStructures or
          structureTradable
     )
)

// ============================================================================
// NO-TRADE ZONE
// ============================================================================

var line ntLowLine = na
var line ntHighLine = na
var linefill ntFill = na

if (
     showNoTradeZone and
     drawZones
)

    if na(
         ntLowLine
    )

        ntLowLine := line.new(
             derivedX1,
             ntLow1,
             safeDerivedX2,
             ntLow2,
             xloc = xloc.bar_index,
             extend = extend.right,
             color = color.new(
                  centerColor,
                  70
             )
        )

        ntHighLine := line.new(
             derivedX1,
             ntHigh1,
             safeDerivedX2,
             ntHigh2,
             xloc = xloc.bar_index,
             extend = extend.right,
             color = color.new(
                  centerColor,
                  70
             )
        )

        ntFill := linefill.new(
             ntLowLine,
             ntHighLine,
             noTradeColor
        )

    else

        line.set_xy1(
             ntLowLine,
             derivedX1,
             ntLow1
        )

        line.set_xy2(
             ntLowLine,
             safeDerivedX2,
             ntLow2
        )

        line.set_xy1(
             ntHighLine,
             derivedX1,
             ntHigh1
        )

        line.set_xy2(
             ntHighLine,
             safeDerivedX2,
             ntHigh2
        )

        linefill.set_color(
             ntFill,
             noTradeColor
        )

else

    if not na(
         ntFill
    )

        linefill.delete(
             ntFill
        )

        ntFill := na

    if not na(
         ntLowLine
    )

        line.delete(
             ntLowLine
        )

        ntLowLine := na

    if not na(
         ntHighLine
    )

        line.delete(
             ntHighLine
        )

        ntHighLine := na

// ============================================================================
// SUPPORT ZONE
// ============================================================================

var line supportZoneLine = na
var line supportClone = na
var linefill supportFill = na

if (
     showBoundaryZones and
     drawZones
)

    if na(
         supportZoneLine
    )

        supportZoneLine := line.new(
             derivedX1,
             supportZone1,
             safeDerivedX2,
             supportZone2,
             xloc = xloc.bar_index,
             extend = extend.right,
             color = color.new(
                  lowerColor,
                  80
             )
        )

        supportClone := line.new(
             derivedX1,
             l1,
             safeDerivedX2,
             l2,
             xloc = xloc.bar_index,
             extend = extend.right,
             color = color.new(
                  lowerColor,
                  100
             )
        )

        supportFill := linefill.new(
             supportClone,
             supportZoneLine,
             supportZoneColor
        )

    else

        line.set_xy1(
             supportZoneLine,
             derivedX1,
             supportZone1
        )

        line.set_xy2(
             supportZoneLine,
             safeDerivedX2,
             supportZone2
        )

        line.set_xy1(
             supportClone,
             derivedX1,
             l1
        )

        line.set_xy2(
             supportClone,
             safeDerivedX2,
             l2
        )

        linefill.set_color(
             supportFill,
             supportZoneColor
        )

else

    if not na(
         supportFill
    )

        linefill.delete(
             supportFill
        )

        supportFill := na

    if not na(
         supportZoneLine
    )

        line.delete(
             supportZoneLine
        )

        supportZoneLine := na

    if not na(
         supportClone
    )

        line.delete(
             supportClone
        )

        supportClone := na

// ============================================================================
// RESISTANCE ZONE
// ============================================================================

var line resistanceZoneLine = na
var line resistanceClone = na
var linefill resistanceFill = na

if (
     showBoundaryZones and
     drawZones
)

    if na(
         resistanceZoneLine
    )

        resistanceZoneLine := line.new(
             derivedX1,
             resistanceZone1,
             safeDerivedX2,
             resistanceZone2,
             xloc = xloc.bar_index,
             extend = extend.right,
             color = color.new(
                  upperColor,
                  80
             )
        )

        resistanceClone := line.new(
             derivedX1,
             u1,
             safeDerivedX2,
             u2,
             xloc = xloc.bar_index,
             extend = extend.right,
             color = color.new(
                  upperColor,
                  100
             )
        )

        resistanceFill := linefill.new(
             resistanceZoneLine,
             resistanceClone,
             resistanceZoneColor
        )

    else

        line.set_xy1(
             resistanceZoneLine,
             derivedX1,
             resistanceZone1
        )

        line.set_xy2(
             resistanceZoneLine,
             safeDerivedX2,
             resistanceZone2
        )

        line.set_xy1(
             resistanceClone,
             derivedX1,
             u1
        )

        line.set_xy2(
             resistanceClone,
             safeDerivedX2,
             u2
        )

        linefill.set_color(
             resistanceFill,
             resistanceZoneColor
        )

else

    if not na(
         resistanceFill
    )

        linefill.delete(
             resistanceFill
        )

        resistanceFill := na

    if not na(
         resistanceZoneLine
    )

        line.delete(
             resistanceZoneLine
        )

        resistanceZoneLine := na

    if not na(
         resistanceClone
    )

        line.delete(
             resistanceClone
        )

        resistanceClone := na

// ============================================================================
// MARKERS
// ============================================================================

plotshape(
     showPivotMarkers and
     newUpperPivot,
     title = "Pivot High",
     style = shape.triangledown,
     location = location.abovebar,
     color = upperColor,
     size = size.tiny,
     offset = -upperLen
)

plotshape(
     showPivotMarkers and
     newLowerPivot,
     title = "Pivot Low",
     style = shape.triangleup,
     location = location.belowbar,
     color = lowerColor,
     size = size.tiny,
     offset = -lowerLen
)

// ============================================================================
// ALERTS
// ============================================================================

alertcondition(
     confirmedBreakUp,
     "Structure Break Up",
     "Price confirmed an upside structural breakout."
)

alertcondition(
     confirmedBreakDown,
     "Structure Break Down",
     "Price confirmed a downside structural breakout."
)
````
