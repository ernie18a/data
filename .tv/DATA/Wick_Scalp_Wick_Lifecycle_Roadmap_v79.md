<!-- tradingview-pine-id: PUB;a47504f7df014e3c9bd0c92f22f4c6bf -->
<!-- tradingviewscripts-format: 1 -->
# Wick Scalp - Wick Lifecycle Roadmap v7.9

Source: https://www.tradingview.com/script/2L8dBYV4-Wick-Scalp-Wick-Lifecycle-Roadmap-v7-9/

## Description

Wick Scalp – Wick Lifecycle Roadmap

Most wick indicators stop once a wick forms.

Wick Lifecycle Roadmap follows the entire life of every significant wick—from creation, to magnet attraction, to retest, and finally continuation or failure.

Instead of simply marking long wicks, the indicator builds a dynamic map of where price is statistically attracted next and what is most likely to happen after that level is reached.

Features
Intelligent Wick Detection
Detects significant upper and lower liquidity wicks
Adjustable minimum wick size
Optional wick/body ratio filter
Ignores insignificant market noise
Clean vs Delayed Magnets

Every wick is classified as either:

Clean Magnet

Fresh liquidity
Higher probability
Higher priority target

Delayed Magnet

Overlapping liquidity
Lower priority
Optional filtering
Magnet Quality Grading

Each magnet receives a quality score based on:

Relative wick size
Liquidity sweep
Higher timeframe bonus
Magnet cleanliness

Grades:

A+
A
B
C

This allows traders to quickly focus on the highest-quality liquidity targets.

Next Magnet Selection

The indicator continuously evaluates every active magnet and automatically selects the most probable next destination using:

Distance from price
EMA trend
RSI momentum
Price momentum
Magnet quality
Cleanliness bonus

Instead of dozens of lines, the indicator highlights the one magnet currently considered most relevant.

Dynamic Entry Model

For the selected magnet the script calculates:

Last acceptable entry
Preferred entry zone
Acceptable entry zone
Remaining move to target
Estimated leveraged return
Entry quality

Status is classified as:

Best Entry Zone
Entry Acceptable
Too Late
Wait
Skip
Complete Wick Lifecycle

After a magnet is hit, the indicator does not stop.

It continues tracking the expected market structure.

Phase 1

Price reaches the remembered wick.

Phase 2

Price must reclaim the entire wick.

Phase 3

R1 becomes active.

R1 represents the reclaimed wick extreme.

Phase 4

If R1 fails,
R2 becomes the next support/resistance.

Phase 5

If R2 also fails,
the pullback is classified as unhealthy.

This creates a complete roadmap instead of a single target.

Continuation Projection

After the current target is completed the indicator automatically searches for the next same-direction magnet.

This creates a natural roadmap showing:

Current Target → Pullback → Continuation

Magnet Table

The integrated table displays:

Current target
Direction
Grade
Distance
Entry model
Entry state
R1
R2
Pullback health
Next continuation target

Everything updates automatically in real time.

Visual Design

The indicator keeps charts clean by using:

Short magnet lines
Hover tooltips
Quality colouring
Optional source dots
Optional candle IDs
Configurable lookback
Selected magnet highlighting
Ideal For
BTC
Crypto
Futures
Forex
Indices
Stocks

Works on all timeframes.

What Makes It Different

Most wick indicators only identify where liquidity was taken.

Wick Lifecycle Roadmap tracks what happens before, during, and after the wick is revisited, providing a complete decision framework rather than isolated signals.

It combines liquidity mapping, probability ranking, dynamic entry planning, retest analysis, and continuation forecasting into a single workflow.

Disclaimer: This indicator is designed as a decision-support tool and should be used alongside your own market analysis and risk management. It does not guarantee future price movements or trading outcomes.

---

## Source Code

````pine
//@version=6
indicator(
     "Wick Scalp - Wick Lifecycle Roadmap v7.9",
     shorttitle="Wick Lifecycle v7.9",
     overlay=true,
     max_lines_count=500,
     max_labels_count=500
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 1. WICK DETECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupDetection = "1. Wick Detection"

minWickSizePct = input.float(
     0.6,
     "Minimum Wick Size (% of price)",
     minval=0.0,
     step=0.1,
     group=groupDetection
)

useBodyRatio = input.bool(
     true,
     "Require Wick / Body Ratio",
     group=groupDetection
)

minWickBodyRatio = input.float(
     1.5,
     "Minimum Wick / Body Ratio",
     minval=0.0,
     step=0.1,
     group=groupDetection
)

rememberUpperWicks = input.bool(
     true,
     "Remember Upper Wicks as Upside Magnets",
     group=groupDetection
)

rememberLowerWicks = input.bool(
     true,
     "Remember Lower Wicks as Downside Magnets",
     group=groupDetection
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 2. TARGET QUALITY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupQuality = "2. Target Quality"

useImmediateOverlapFilter = input.bool(
     true,
     "Classify Immediate Wick Overlap as Delayed",
     group=groupQuality,
     tooltip="A new same-side wick that overlaps the previous candle's wick is treated as a slower, lower-priority magnet."
)

storeDelayedTargets = input.bool(
     true,
     "Keep Delayed Magnets",
     group=groupQuality
)

signalDelayedTargets = input.bool(
     false,
     "Allow Delayed Magnet Hit Signals",
     group=groupQuality
)

minBarsBetweenNewTargets = input.int(
     0,
     "Minimum Bars Between Same-Side Magnets",
     minval=0,
     maxval=100,
     group=groupQuality
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 3. MAGNET SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupTargets = "3. Magnet Settings"

targetLevelMode = input.string(
     "Body Edge",
     "Magnet Level",
     options=["Body Edge", "50% Wick", "Wick Extreme"],
     group=groupTargets,
     tooltip="Body Edge front-runs the wick and follows the latest feedback."
)

minBarsBeforeTargetHit = input.int(
     1,
     "Minimum Bars Before Magnet Can Be Hit",
     minval=1,
     maxval=500,
     group=groupTargets
)

maxTargetAgeBars = input.int(
     0,
     "Maximum Magnet Age (0 = no expiry)",
     minval=0,
     maxval=100000,
     group=groupTargets
)

maxActiveTargets = input.int(
     180,
     "Maximum Stored Magnets",
     minval=20,
     maxval=220,
     group=groupTargets
)

showHitLabels = input.bool(
     true,
     "Show Magnet-Hit Labels",
     group=groupTargets
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 4. CLEAN DISPLAY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupDisplay = "4. Clean Display"

lookbackBars = input.int(
     300,
     "Only Show Magnets From Last N Candles",
     minval=20,
     maxval=10000,
     group=groupDisplay,
     tooltip="Limits stored and displayed magnets to recent candles only. This reduces chart noise."
)

showCleanTargets = input.bool(
     true,
     "Show Clean Magnets",
     group=groupDisplay
)

showDelayedTargets = input.bool(
     true,
     "Show Delayed Magnets",
     group=groupDisplay
)

showOnlyUntouchedMagnets = input.bool(
     false,
     "Show Only Untouched Magnets",
     group=groupDisplay,
     tooltip="When enabled, hides any active magnet whose original wick zone has already been revisited after the source candle. Untouched means price has not entered the wick zone since it formed."
)

lineBarsLeft = input.int(
     1,
     "Line Bars Left of Source Candle",
     minval=0,
     maxval=20,
     group=groupDisplay
)

lineBarsRight = input.int(
     7,
     "Line Bars Right of Source Candle",
     minval=1,
     maxval=100,
     group=groupDisplay,
     tooltip="Draws a short horizontal magnet line close to the source wick candle."
)

showSourceDots = input.bool(
     true,
     "Show Dot at End of Source Line",
     group=groupDisplay,
     tooltip="Places a small hoverable dot at the end of each short source-candle magnet line."
)

showOnlyNextMagnet = input.bool(
     false,
     "Show Only Selected Next Magnet",
     group=groupDisplay,
     tooltip="Hides all other source lines and dots. The table still evaluates every stored magnet."
)

extendSelectedMagnet = input.bool(
     true,
     "Extend Table Magnet While Bias Agrees",
     group=groupDisplay,
     tooltip="The magnet selected in the bottom table extends from its source candle toward the current chart edge only while price-action bias still points toward it."
)

selectedLineBarsRight = input.int(
     3,
     "Selected Line Projection Bars",
     minval=1,
     maxval=30,
     group=groupDisplay
)

showEntrySuggestion = input.bool(
     true,
     "Show Suggested Entry Zone",
     group=groupDisplay,
     tooltip="For the magnet selected in the table, calculates the last entry price that still leaves the configured minimum profit to the target."
)

minimumPriceMovePct = input.float(
     1.0,
     "Minimum Price Move to Target (%)",
     minval=0.05,
     maxval=20.0,
     step=0.05,
     group=groupDisplay,
     tooltip="This is the minimum underlying market move still required from entry to the selected magnet. Leverage is applied separately for informational gross-return estimates."
)

expectedLeverage = input.float(
     3.0,
     "Expected Leverage",
     minval=1.0,
     maxval=200.0,
     step=0.5,
     group=groupDisplay,
     tooltip="Used only to estimate gross leveraged return. It does not include fees, funding, slippage or liquidation risk."
)

minimumGrossLeveragedReturnPct = input.float(
     3.0,
     "Minimum Gross Leveraged Return (%)",
     minval=0.1,
     maxval=500.0,
     step=0.5,
     group=groupDisplay,
     tooltip="Optional confirmation threshold. The selected entry must provide at least this estimated gross leveraged return to the target."
)

useLeveragedReturnThreshold = input.bool(
     true,
     "Require Minimum Gross Leveraged Return",
     group=groupDisplay
)

betterEntryZonePct = input.float(
     1.0,
     "Better Entry Zone Width (%)",
     minval=0.05,
     maxval=20.0,
     step=0.05,
     group=groupDisplay,
     tooltip="Bullish magnets show a preferred zone below the last acceptable entry. Bearish magnets show a preferred zone above it."
)

entryProjectionBars = input.int(
     12,
     "Entry Zone Projection Bars",
     minval=2,
     maxval=100,
     group=groupDisplay
)

requireBiasForEntry = input.bool(
     true,
     "Require Price-Action Bias for Entry Suggestion",
     group=groupDisplay,
     tooltip="When enabled, the entry zone is active only while the price-action model points toward the selected target."
)

showPostTargetRoadmap = input.bool(
     true,
     "Show Post-Target Roadmap",
     group=groupDisplay,
     tooltip="Plans two possible steps after the selected magnet is reached: the nearest opposite magnet for a possible pullback and the next same-direction magnet for continuation."
)

showRoadmapLines = input.bool(
     true,
     "Show Pullback and Continuation Lines",
     group=groupDisplay
)

roadmapProjectionBars = input.int(
     8,
     "Roadmap Line Length",
     minval=2,
     maxval=50,
     group=groupDisplay
)

showSecondRetestLevel = input.bool(
     true,
     "Show Reclaimed Wick Body Level (R2)",
     group=groupDisplay,
     tooltip="R1 is the reclaimed wick extreme. R2 is the original body-edge target of that same wick. Neither is shown until price closes beyond the wick extreme."
)

reclaimConfirmationCloses = input.int(
     1,
     "Closes Required to Reclaim Wick",
     minval=1,
     maxval=5,
     group=groupDisplay,
     tooltip="Upper wick: close above the wick extreme. Lower wick: close below the wick extreme."
)

reclaimBufferPct = input.float(
     0.0,
     "Reclaim Buffer Beyond Wick (%)",
     minval=0.0,
     maxval=5.0,
     step=0.05,
     group=groupDisplay
)

retestFailureCloses = input.int(
     1,
     "Closes Required to Fail a Retest Level",
     minval=1,
     maxval=5,
     group=groupDisplay
)

retestFailureBufferPct = input.float(
     0.0,
     "Retest Failure Buffer (%)",
     minval=0.0,
     maxval=5.0,
     step=0.05,
     group=groupDisplay,
     tooltip="Requires price to close beyond a retest level by this percentage before counting a failure."
)

keepPostHitRoadmapBars = input.int(
     30,
     "Keep Post-Hit Roadmap for Bars",
     minval=1,
     maxval=500,
     group=groupDisplay
)

useReclaimedWickRetest = input.bool(
     true,
     "Retest Current Reclaimed Wick Boundary",
     group=groupDisplay,
     tooltip="After the selected wick target is reached and reclaimed, the first pullback level is that same wick boundary: body high for an upper wick, body low for a lower wick."
)

maxStoredHitTargets = input.int(
     100,
     "Maximum Stored Previous Hit Targets",
     minval=10,
     maxval=300,
     group=groupDisplay
)

showCandleIds = input.bool(
     false,
     "Show Source Candle IDs",
     group=groupDisplay,
     tooltip="Shows U# or D# with the source bar index on the original wick candle."
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 5. MAGNET GRADING
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupGrades = "5. Magnet Grading"

averageWickLookback = input.int(
     50,
     "Average Wick Lookback",
     minval=5,
     maxval=500,
     group=groupGrades
)

largeWickMultiplier = input.float(
     1.5,
     "Large Wick = Average ×",
     minval=1.0,
     step=0.1,
     group=groupGrades
)

veryLargeWickMultiplier = input.float(
     2.5,
     "Very Large Wick = Average ×",
     minval=1.0,
     step=0.1,
     group=groupGrades
)

liquiditySweepLookback = input.int(
     10,
     "Liquidity Sweep Lookback",
     minval=2,
     maxval=100,
     group=groupGrades,
     tooltip="Upper wick sweeps the previous highest high, or lower wick sweeps the previous lowest low."
)

higherTimeframeMinutes = input.int(
     60,
     "Higher-Timeframe Threshold (minutes)",
     minval=1,
     maxval=10080,
     group=groupGrades,
     tooltip="Magnets created on chart timeframes at or above this threshold receive a higher-timeframe bonus."
)

gradeAPlusMin = input.float(
     80.0,
     "A+ Minimum Score",
     minval=0,
     maxval=100,
     step=1,
     group=groupGrades
)

gradeAMin = input.float(
     60.0,
     "A Minimum Score",
     minval=0,
     maxval=100,
     step=1,
     group=groupGrades
)

gradeBMin = input.float(
     35.0,
     "B Minimum Score",
     minval=0,
     maxval=100,
     step=1,
     group=groupGrades
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 6. NEXT-MAGNET PRICE-ACTION MODEL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupModel = "6. Next-Magnet Model"

biasEmaFastLen = input.int(
     20,
     "Fast EMA",
     minval=1,
     group=groupModel
)

biasEmaSlowLen = input.int(
     50,
     "Slow EMA",
     minval=2,
     group=groupModel
)

biasRsiLen = input.int(
     14,
     "RSI Length",
     minval=2,
     group=groupModel
)

momentumLookback = input.int(
     5,
     "Momentum Lookback",
     minval=1,
     maxval=100,
     group=groupModel
)

maxCandidateDistancePct = input.float(
     20.0,
     "Maximum Candidate Distance (%)",
     minval=0.1,
     step=0.5,
     group=groupModel
)

cleanMagnetBonus = input.float(
     20.0,
     "Clean Magnet Bonus",
     minval=0.0,
     step=1.0,
     group=groupModel
)

directionBiasBonus = input.float(
     30.0,
     "Price-Action Direction Bonus",
     minval=0.0,
     step=1.0,
     group=groupModel
)

showNextMagnetTable = input.bool(
     true,
     "Show One-Line Next Magnet Table",
     group=groupModel
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GRADING HELPERS
// Functions must be declared before they are called in Pine.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
gradeName(_score) =>
    _score >= gradeAPlusMin ? "A+" :
     _score >= gradeAMin ? "A" :
     _score >= gradeBMin ? "B" :
     "C"

gradeColor(_grade) =>
    _grade == "A+" ? color.lime :
     _grade == "A" ? color.green :
     _grade == "B" ? color.yellow :
     color.red

calculateGradeScore(_isUpside, _isDelayed, _wickSize, _avgWick, _sweptLiquidity) =>
    relativeWick = _avgWick > 0.0 ? _wickSize / _avgWick : 0.0
    timeframeSeconds = timeframe.in_seconds()
    higherTf = not na(timeframeSeconds) and timeframeSeconds >= higherTimeframeMinutes * 60

    float score = 0.0

    // Wick-size component: up to 40 points.
    score += relativeWick >= veryLargeWickMultiplier ? 40.0 :
     relativeWick >= largeWickMultiplier ? 28.0 :
     relativeWick >= 1.0 ? 16.0 :
     6.0

    // Cleanliness: clean receives 25; delayed receives only 3.
    score += _isDelayed ? 3.0 : 25.0

    // Liquidity sweep: 25 points.
    score += _sweptLiquidity ? 25.0 : 0.0

    // Higher chart timeframe: 10 points.
    score += higherTf ? 10.0 : 0.0

    math.min(score, 100.0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CANDLE STRUCTURE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bodyTop  = math.max(open, close)
bodyBot  = math.min(open, close)
bodySize = math.abs(close - open)

upperWick = math.max(high - bodyTop, 0.0)
lowerWick = math.max(bodyBot - low, 0.0)

upperWickPctPrice = high > 0.0 ? upperWick / high * 100.0 : 0.0
lowerWickPctPrice = low > 0.0 ? lowerWick / low * 100.0 : 0.0

upperRatio = bodySize > 0.0 ? upperWick / bodySize : upperWick > 0.0 ? 999.0 : 0.0
lowerRatio = bodySize > 0.0 ? lowerWick / bodySize : lowerWick > 0.0 ? 999.0 : 0.0

bigUpperWick =
     rememberUpperWicks and
     upperWickPctPrice >= minWickSizePct and
     (not useBodyRatio or upperRatio >= minWickBodyRatio)

bigLowerWick =
     rememberLowerWicks and
     lowerWickPctPrice >= minWickSizePct and
     (not useBodyRatio or lowerRatio >= minWickBodyRatio)

// Previous same-side wick zones
prevBodyTop = math.max(open[1], close[1])
prevBodyBot = math.min(open[1], close[1])

prevHasUpperWick = not na(high[1]) and high[1] > prevBodyTop
prevHasLowerWick = not na(low[1]) and low[1] < prevBodyBot

upperWickTouchesPrevious =
     prevHasUpperWick and
     upperWick > 0.0 and
     math.max(bodyTop, prevBodyTop) <= math.min(high, high[1])

lowerWickTouchesPrevious =
     prevHasLowerWick and
     lowerWick > 0.0 and
     math.max(low, low[1]) <= math.min(bodyBot, prevBodyBot)

upperIsDelayed = useImmediateOverlapFilter and upperWickTouchesPrevious
lowerIsDelayed = useImmediateOverlapFilter and lowerWickTouchesPrevious

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MAGNET LEVELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
upperTargetLevel =
     targetLevelMode == "Body Edge" ? bodyTop :
     targetLevelMode == "50% Wick" ? bodyTop + upperWick * 0.5 :
     high

lowerTargetLevel =
     targetLevelMode == "Body Edge" ? bodyBot :
     targetLevelMode == "50% Wick" ? bodyBot - lowerWick * 0.5 :
     low


averageUpperWick = ta.sma(upperWick, averageWickLookback)
averageLowerWick = ta.sma(lowerWick, averageWickLookback)

upperSweptLiquidity =
     high > ta.highest(high[1], liquiditySweepLookback)

lowerSweptLiquidity =
     low < ta.lowest(low[1], liquiditySweepLookback)

upperGradeScore = calculateGradeScore(
     true,
     upperIsDelayed,
     upperWick,
     averageUpperWick,
     upperSweptLiquidity
)

lowerGradeScore = calculateGradeScore(
     false,
     lowerIsDelayed,
     lowerWick,
     averageLowerWick,
     lowerSweptLiquidity
)

upperGrade = gradeName(upperGradeScore)
lowerGrade = gradeName(lowerGradeScore)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ARRAYS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float[] targetLevelArr = array.new_float()
var float[] wickExtremeArr = array.new_float()
var float[] wickBaseArr = array.new_float()
var float[] bodyFarEdgeArr = array.new_float()
var int[] sourceBarArr = array.new_int()
var bool[] isUpsideArr = array.new_bool()
var bool[] isDelayedArr = array.new_bool()
var bool[] wasTouchedArr = array.new_bool()
var float[] gradeScoreArr = array.new_float()
var string[] gradeArr = array.new_string()
var line[] targetLineArr = array.new_line()
var label[] targetDotArr = array.new_label()
var label[] sourceIdArr = array.new_label()

// Archive of targets already fulfilled.
// These remain available as possible future retest/support/resistance levels.
var float[] hitLevelArr = array.new_float()
var float[] hitBodyFarEdgeArr = array.new_float()
var bool[] hitWasUpsideArr = array.new_bool()
var int[] hitSourceBarArr = array.new_int()
var int[] hitBarArr = array.new_int()
var string[] hitGradeArr = array.new_string()

var int lastUpperTargetBar = na
var int lastLowerTargetBar = na

var line selectedEntryLine = na
var box selectedEntryBox = na
var box selectedAcceptableBox = na
var label selectedEntryLabel = na
var line pullbackRoadmapLine = na
var line pullback2RoadmapLine = na
var line continuationRoadmapLine = na
var label pullbackRoadmapLabel = na
var label pullback2RoadmapLabel = na
var label continuationRoadmapLabel = na

// Persistent state for the most recently fulfilled magnet.
var bool postHitActive = false
var bool postHitUpside = false
var bool postHitReclaimed = false
var float postHitWickExtreme = na
var float postHitBodyEdge = na
var float postHitR1 = na
var float postHitR2 = na
var int postHitBar = na
var int postHitSourceBar = na
var string postHitGrade = ""
var int postHitReclaimCount = 0
var int postHitR1FailCount = 0
var int postHitR2FailCount = 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
targetVisible(_isDelayed) =>
    _isDelayed ? showDelayedTargets : showCleanTargets

targetColor(_isUpside, _isDelayed) =>
    base = _isUpside ? color.lime : color.red
    _isDelayed ? color.new(base, 55) : base

targetId(_isUpside, _sourceBar) =>
    (_isUpside ? "U#" : "D#") + str.tostring(_sourceBar)

targetTooltip(_isUpside, _isDelayed, _level, _extreme, _sourceBar, _grade, _score) =>
    directionText = _isUpside ? "UPPER WICK MAGNET" : "LOWER WICK MAGNET"
    qualityText = _isDelayed ? "Delayed / lower priority" : "Clean / higher priority"
    actionText = _isUpside
         ? "Price may be attracted upward toward this level."
         : "Price may be attracted downward toward this level."

    directionText +
     "\n" + qualityText +
     "\n" + actionText +
     "\nTarget: " + str.tostring(_level, format.mintick) +
     "\nWick extreme: " + str.tostring(_extreme, format.mintick) +
     "\nGrade: " + _grade + " (" + str.tostring(_score, "#") + "/100)" +
     "\nCandle ID: " + targetId(_isUpside, _sourceBar)


archiveHitTarget(_index) =>
    hitLevel = array.get(targetLevelArr, _index)
    hitBodyFarEdge = array.get(bodyFarEdgeArr, _index)
    hitWasUpside = array.get(isUpsideArr, _index)
    hitSourceBar = array.get(sourceBarArr, _index)
    hitGrade = array.get(gradeArr, _index)

    array.push(hitLevelArr, hitLevel)
    array.push(hitBodyFarEdgeArr, hitBodyFarEdge)
    array.push(hitWasUpsideArr, hitWasUpside)
    array.push(hitSourceBarArr, hitSourceBar)
    array.push(hitBarArr, bar_index)
    array.push(hitGradeArr, hitGrade)

    if array.size(hitLevelArr) > maxStoredHitTargets
        array.shift(hitLevelArr)
        array.shift(hitBodyFarEdgeArr)
        array.shift(hitWasUpsideArr)
        array.shift(hitSourceBarArr)
        array.shift(hitBarArr)
        array.shift(hitGradeArr)

deleteTargetAt(_index) =>
    line ln = array.get(targetLineArr, _index)
    label dot = array.get(targetDotArr, _index)
    label sourceIdLabel = array.get(sourceIdArr, _index)

    if not na(ln)
        line.delete(ln)

    if not na(dot)
        label.delete(dot)

    if not na(sourceIdLabel)
        label.delete(sourceIdLabel)

    array.remove(targetLevelArr, _index)
    array.remove(wickExtremeArr, _index)
    array.remove(wickBaseArr, _index)
    array.remove(bodyFarEdgeArr, _index)
    array.remove(sourceBarArr, _index)
    array.remove(isUpsideArr, _index)
    array.remove(isDelayedArr, _index)
    array.remove(wasTouchedArr, _index)
    array.remove(gradeScoreArr, _index)
    array.remove(gradeArr, _index)
    array.remove(targetLineArr, _index)
    array.remove(targetDotArr, _index)
    array.remove(sourceIdArr, _index)

addTarget(_level, _extreme, _wickBase, _bodyFarEdge, _sourceBar, _isUpside, _isDelayed, _gradeScore, _grade) =>
    line ln = na
    label dot = na
    label idLabel = na

    visible = targetVisible(_isDelayed)

    if visible
        ln := line.new(
             x1=_sourceBar - lineBarsLeft,
             y1=_level,
             x2=_sourceBar + lineBarsRight,
             y2=_level,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=gradeColor(_grade),
             style=_isDelayed ? line.style_dashed : line.style_solid,
             width=_isDelayed ? 1 : 2
        )

        if showSourceDots
            dot := label.new(
                 x=_sourceBar + lineBarsRight,
                 y=_level,
                 xloc=xloc.bar_index,
                 yloc=yloc.price,
                 text="",
                 style=label.style_circle,
                 color=targetColor(_isUpside, _isDelayed),
                 textcolor=color.white,
                 size=size.tiny,
                 tooltip=targetTooltip(_isUpside, _isDelayed, _level, _extreme, _sourceBar, _grade, _gradeScore)
            )

    if showCandleIds
        idLabel := label.new(
             x=_sourceBar,
             y=_extreme,
             xloc=xloc.bar_index,
             yloc=yloc.price,
             text=targetId(_isUpside, _sourceBar),
             style=_isUpside ? label.style_label_down : label.style_label_up,
             color=color.new(gradeColor(_grade), 70),
             textcolor=color.white,
             size=size.tiny,
             tooltip=targetTooltip(_isUpside, _isDelayed, _level, _extreme, _sourceBar, _grade, _gradeScore)
        )

    array.push(targetLevelArr, _level)
    array.push(wickExtremeArr, _extreme)
    array.push(wickBaseArr, _wickBase)
    array.push(bodyFarEdgeArr, _bodyFarEdge)
    array.push(sourceBarArr, _sourceBar)
    array.push(isUpsideArr, _isUpside)
    array.push(isDelayedArr, _isDelayed)
    array.push(wasTouchedArr, false)
    array.push(gradeScoreArr, _gradeScore)
    array.push(gradeArr, _grade)
    array.push(targetLineArr, ln)
    array.push(targetDotArr, dot)
    array.push(sourceIdArr, idLabel)

    if array.size(targetLevelArr) > maxActiveTargets
        deleteTargetAt(0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STORE NEW MAGNETS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
canAddUpper =
     na(lastUpperTargetBar) or
     bar_index - lastUpperTargetBar >= minBarsBetweenNewTargets

canAddLower =
     na(lastLowerTargetBar) or
     bar_index - lastLowerTargetBar >= minBarsBetweenNewTargets

storeUpper =
     bigUpperWick and
     canAddUpper and
     (not upperIsDelayed or storeDelayedTargets)

storeLower =
     bigLowerWick and
     canAddLower and
     (not lowerIsDelayed or storeDelayedTargets)

if storeUpper
    addTarget(upperTargetLevel, high, bodyTop, bodyBot, bar_index, true, upperIsDelayed, upperGradeScore, upperGrade)
    lastUpperTargetBar := bar_index

if storeLower
    addTarget(lowerTargetLevel, low, bodyBot, bodyTop, bar_index, false, lowerIsDelayed, lowerGradeScore, lowerGrade)
    lastLowerTargetBar := bar_index

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRACK WHETHER ACTIVE WICK ZONES HAVE BEEN TOUCHED
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// A magnet starts untouched. From the candle after its creation onward:
// - Upper wick: touched when price trades back to or above the wick base.
// - Lower wick: touched when price trades back to or below the wick base.
// The target remains stored until the normal magnet-hit or expiry logic removes it.

if array.size(targetLevelArr) > 0
    for i = 0 to array.size(targetLevelArr) - 1
        sourceBar = array.get(sourceBarArr, i)
        alreadyTouched = array.get(wasTouchedArr, i)

        if not alreadyTouched and bar_index > sourceBar
            wickBase = array.get(wickBaseArr, i)
            isUpside = array.get(isUpsideArr, i)

            touchedNow =
                 isUpside
                 ? high >= wickBase
                 : low <= wickBase

            if touchedNow
                array.set(wasTouchedArr, i, true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PRICE-ACTION BIAS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
emaFast = ta.ema(close, biasEmaFastLen)
emaSlow = ta.ema(close, biasEmaSlowLen)
biasRsi = ta.rsi(close, biasRsiLen)
momentum = close - close[momentumLookback]

float bullishPoints = 0.0
float bearishPoints = 0.0

bullishPoints += emaFast > emaSlow ? 1.0 : 0.0
bearishPoints += emaFast < emaSlow ? 1.0 : 0.0

bullishPoints += close > emaFast ? 1.0 : 0.0
bearishPoints += close < emaFast ? 1.0 : 0.0

bullishPoints += biasRsi > 52.0 ? 1.0 : 0.0
bearishPoints += biasRsi < 48.0 ? 1.0 : 0.0

bullishPoints += momentum > 0.0 ? 1.0 : 0.0
bearishPoints += momentum < 0.0 ? 1.0 : 0.0

int priceActionBias =
     bullishPoints > bearishPoints ? 1 :
     bearishPoints > bullishPoints ? -1 :
     0

biasText =
     priceActionBias == 1 ? "Bullish" :
     priceActionBias == -1 ? "Bearish" :
     "Neutral"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SELECT POSSIBLE NEXT MAGNET
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
int selectedIndex = na
float selectedScore = na
float selectedDistancePct = na

if array.size(targetLevelArr) > 0
    for i = 0 to array.size(targetLevelArr) - 1
        level = array.get(targetLevelArr, i)
        isUpside = array.get(isUpsideArr, i)
        isDelayed = array.get(isDelayedArr, i)
        wasTouched = array.get(wasTouchedArr, i)
        magnetGradeScore = array.get(gradeScoreArr, i)

        eligibleByTouch =
             not showOnlyUntouchedMagnets or
             not wasTouched

        correctSide =
             isUpside ? level > close : level < close

        distancePct =
             close != 0.0 ? math.abs(level - close) / close * 100.0 : na

        withinDistance =
             not na(distancePct) and
             distancePct <= maxCandidateDistancePct

        if eligibleByTouch and correctSide and withinDistance
            proximityScore = 100.0 - math.min(distancePct / maxCandidateDistancePct * 100.0, 100.0)
            qualityScore = isDelayed ? 0.0 : cleanMagnetBonus
            biasMatches =
                 (priceActionBias == 1 and isUpside) or
                 (priceActionBias == -1 and not isUpside)

            biasScore = biasMatches ? directionBiasBonus : 0.0
            neutralScore = priceActionBias == 0 ? directionBiasBonus * 0.35 : 0.0
            candidateScore = proximityScore + qualityScore + biasScore + neutralScore + magnetGradeScore * 0.35

            if na(selectedScore) or candidateScore > selectedScore
                selectedScore := candidateScore
                selectedIndex := i
                selectedDistancePct := distancePct

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// POST-TARGET ROADMAP
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
int continuationIndex = na
float plannedR1 = na
float plannedR2 = na
float continuationLevel = na
float continuationDistanceFromTargetPct = na
int plannedSourceBar = na
string plannedGrade = ""
bool plannedUpside = false

if not na(selectedIndex) and selectedIndex < array.size(targetLevelArr)
    plannedR1 := array.get(wickExtremeArr, selectedIndex)
    plannedR2 := array.get(targetLevelArr, selectedIndex)
    plannedSourceBar := array.get(sourceBarArr, selectedIndex)
    plannedGrade := array.get(gradeArr, selectedIndex)
    plannedUpside := array.get(isUpsideArr, selectedIndex)

    // Find the nearest same-direction magnet beyond the current target.
    for i = 0 to array.size(targetLevelArr) - 1
        if i != selectedIndex
            candidateLevel = array.get(targetLevelArr, i)
            candidateUpside = array.get(isUpsideArr, i)

            isContinuationCandidate =
                 plannedUpside
                 ? candidateUpside and candidateLevel > plannedR2
                 : not candidateUpside and candidateLevel < plannedR2

            if isContinuationCandidate
                betterContinuation =
                     na(continuationLevel) or
                     (
                         plannedUpside
                         ? candidateLevel < continuationLevel
                         : candidateLevel > continuationLevel
                     )

                if betterContinuation
                    continuationIndex := i
                    continuationLevel := candidateLevel

    if not na(continuationLevel) and plannedR2 != 0.0
        continuationDistanceFromTargetPct :=
             math.abs(continuationLevel - plannedR2) / plannedR2 * 100.0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ENTRY SUGGESTION FOR THE SELECTED MAGNET
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float selectedTargetLevel = na
bool selectedTargetUpside = false
float lastAcceptableEntry = na
float betterEntryZoneLow = na
float betterEntryZoneHigh = na
float displayedEntryLow = na
float displayedEntryHigh = na
float preferredRangeLow = na
float preferredRangeHigh = na
float acceptableRangeLow = na
float acceptableRangeHigh = na
float profitFromClosePct = na
float grossLeveragedReturnPct = na
float grossReturnAtLastEntryPct = na
bool selectedBiasAgrees = false
bool entryStillAcceptable = false
bool leveragedReturnOk = false
bool priceInsideBetterZone = false
string entryState = "No target"

if not na(selectedIndex) and selectedIndex < array.size(targetLevelArr)
    selectedTargetLevel := array.get(targetLevelArr, selectedIndex)
    selectedTargetUpside := array.get(isUpsideArr, selectedIndex)

    selectedBiasAgrees :=
         (priceActionBias == 1 and selectedTargetUpside) or
         (priceActionBias == -1 and not selectedTargetUpside)

    minMoveDecimal = minimumPriceMovePct / 100.0

    // Long toward an upside target:
    // (target - entry) / entry = required price move
    // entry = target / (1 + required price move)
    //
    // Short toward a downside target:
    // (entry - target) / entry = required price move
    // entry = target / (1 - required price move)
    lastAcceptableEntry :=
         selectedTargetUpside
         ? selectedTargetLevel / (1.0 + minMoveDecimal)
         : minMoveDecimal < 1.0
         ? selectedTargetLevel / (1.0 - minMoveDecimal)
         : na

    if not na(lastAcceptableEntry)
        betterEntryZoneLow :=
             selectedTargetUpside
             ? lastAcceptableEntry * (1.0 - betterEntryZonePct / 100.0)
             : lastAcceptableEntry

        betterEntryZoneHigh :=
             selectedTargetUpside
             ? lastAcceptableEntry
             : lastAcceptableEntry * (1.0 + betterEntryZonePct / 100.0)

        // Dynamic display:
        // Bullish target: when current price is below the predefined zone,
        // extend the preferred entry range down to current price.
        // Bearish target: when current price is above the predefined zone,
        // extend the preferred entry range up to current price.
        displayedEntryLow :=
             selectedTargetUpside
             ? math.min(close, betterEntryZoneLow)
             : lastAcceptableEntry

        displayedEntryHigh :=
             selectedTargetUpside
             ? lastAcceptableEntry
             : math.max(close, betterEntryZoneHigh)

        // Preferred section starts at current price when price is already
        // better than the original preferred zone.
        preferredRangeLow :=
             selectedTargetUpside
             ? math.min(close, betterEntryZoneLow)
             : math.max(lastAcceptableEntry, betterEntryZoneHigh)

        preferredRangeHigh :=
             selectedTargetUpside
             ? math.min(lastAcceptableEntry, math.max(close, betterEntryZoneLow))
             : math.max(close, betterEntryZoneHigh)

        // Acceptable section sits between the preferred boundary
        // and the last acceptable entry.
        acceptableRangeLow :=
             selectedTargetUpside
             ? math.max(close, betterEntryZoneLow)
             : lastAcceptableEntry

        acceptableRangeHigh :=
             selectedTargetUpside
             ? lastAcceptableEntry
             : math.min(close, betterEntryZoneHigh)

        profitFromClosePct :=
             selectedTargetUpside
             ? (selectedTargetLevel - close) / close * 100.0
             : (close - selectedTargetLevel) / close * 100.0

        grossLeveragedReturnPct := profitFromClosePct * expectedLeverage
        grossReturnAtLastEntryPct := minimumPriceMovePct * expectedLeverage
        leveragedReturnOk :=
             not useLeveragedReturnThreshold or
             grossLeveragedReturnPct >= minimumGrossLeveragedReturnPct

        entryStillAcceptable :=
             leveragedReturnOk and
             (
                 selectedTargetUpside
                 ? close <= lastAcceptableEntry and close < selectedTargetLevel
                 : close >= lastAcceptableEntry and close > selectedTargetLevel
             )

        priceInsideBetterZone :=
             close >= betterEntryZoneLow and
             close <= betterEntryZoneHigh

        entryState :=
             requireBiasForEntry and not selectedBiasAgrees
             ? "WAIT: bias disagrees"
             : not leveragedReturnOk
             ? "SKIP: leverage return too small"
             : priceInsideBetterZone
             ? "BEST ENTRY ZONE"
             : entryStillAcceptable
             ? "ENTRY ACCEPTABLE"
             : "TOO LATE"

// Draw only the selected magnet's entry information.
if barstate.islast
    if not na(selectedEntryLine)
        line.delete(selectedEntryLine)
        selectedEntryLine := na

    if not na(selectedEntryBox)
        box.delete(selectedEntryBox)
        selectedEntryBox := na

    if not na(selectedAcceptableBox)
        box.delete(selectedAcceptableBox)
        selectedAcceptableBox := na

    if not na(selectedEntryLabel)
        label.delete(selectedEntryLabel)
        selectedEntryLabel := na

    entryModelActive =
         showEntrySuggestion and
         not na(selectedTargetLevel) and
         not na(lastAcceptableEntry) and
         (not requireBiasForEntry or selectedBiasAgrees)

    if entryModelActive
        entryColor = selectedTargetUpside ? color.lime : color.red
        zoneColor = priceInsideBetterZone ? color.new(entryColor, 72) : color.new(entryColor, 86)

        selectedEntryLine := line.new(
             x1=bar_index,
             y1=lastAcceptableEntry,
             x2=bar_index + entryProjectionBars,
             y2=lastAcceptableEntry,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=entryColor,
             style=line.style_dashed,
             width=2
        )

        // Green preferred range. It begins at current price when current
        // price is already better than the original preferred zone.
        preferredTop = math.max(preferredRangeLow, preferredRangeHigh)
        preferredBottom = math.min(preferredRangeLow, preferredRangeHigh)

        if preferredTop > preferredBottom
            selectedEntryBox := box.new(
                 left=bar_index,
                 top=preferredTop,
                 right=bar_index + entryProjectionBars,
                 bottom=preferredBottom,
                 xloc=xloc.bar_index,
                 border_color=color.new(color.lime, 20),
                 border_width=1,
                 bgcolor=color.new(color.lime, priceInsideBetterZone ? 72 : 84)
            )

        // Yellow section = still acceptable, but closer to the last entry.
        acceptableTop = math.max(acceptableRangeLow, acceptableRangeHigh)
        acceptableBottom = math.min(acceptableRangeLow, acceptableRangeHigh)

        if acceptableTop > acceptableBottom
            selectedAcceptableBox := box.new(
                 left=bar_index,
                 top=acceptableTop,
                 right=bar_index + entryProjectionBars,
                 bottom=acceptableBottom,
                 xloc=xloc.bar_index,
                 border_color=color.new(color.yellow, 25),
                 border_width=1,
                 bgcolor=color.new(color.yellow, 86)
            )

        entryTooltip =
             (selectedTargetUpside ? "LONG ENTRY MODEL" : "SHORT ENTRY MODEL") +
             "\nTarget: " + str.tostring(selectedTargetLevel, format.mintick) +
             "\nMinimum price move: " + str.tostring(minimumPriceMovePct, "#.##") + "%" +
             "\nExpected leverage: " + str.tostring(expectedLeverage, "#.##") + "x" +
             "\nLast acceptable entry: " + str.tostring(lastAcceptableEntry, format.mintick) +
             "\nDynamic entry range: " + str.tostring(displayedEntryLow, format.mintick) +
             " – " + str.tostring(displayedEntryHigh, format.mintick) +
             "\nOriginal preferred zone: " + str.tostring(betterEntryZoneLow, format.mintick) +
             " – " + str.tostring(betterEntryZoneHigh, format.mintick) +
             "\nUnderlying move left: " + str.tostring(profitFromClosePct, "#.##") + "%" +
             "\nEstimated gross leveraged return: " + str.tostring(grossLeveragedReturnPct, "#.##") + "%" +
             "\nGross return at last entry: " + str.tostring(grossReturnAtLastEntryPct, "#.##") + "%" +
             "\nFees, funding and slippage are not included." +
             "\nStatus: " + entryState

        selectedEntryLabel := label.new(
             x=bar_index + entryProjectionBars,
             y=lastAcceptableEntry,
             xloc=xloc.bar_index,
             yloc=yloc.price,
             text="E",
             style=selectedTargetUpside ? label.style_label_left : label.style_label_left,
             color=entryColor,
             textcolor=color.white,
             size=size.tiny,
             tooltip=entryTooltip
        )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAW TWO-LEVEL RETEST ROADMAP
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Update persistent post-hit wick lifecycle.
postHitExpired =
     postHitActive and
     not na(postHitBar) and
     bar_index - postHitBar > keepPostHitRoadmapBars

if postHitExpired
    postHitActive := false
    postHitReclaimed := false
    postHitReclaimCount := 0
    postHitR1FailCount := 0
    postHitR2FailCount := 0

if postHitActive
    reclaimBuffer = reclaimBufferPct / 100.0

    // A fulfilled wick is NOT a pullback level yet.
    // It becomes eligible only after price closes beyond the wick extreme.
    reclaimClose =
         postHitUpside
         ? close > postHitWickExtreme * (1.0 + reclaimBuffer)
         : close < postHitWickExtreme * (1.0 - reclaimBuffer)

    postHitReclaimCount :=
         reclaimClose
         ? postHitReclaimCount + 1
         : 0

    if not postHitReclaimed and postHitReclaimCount >= reclaimConfirmationCloses
        postHitReclaimed := true
        postHitR1 := postHitWickExtreme
        postHitR2 := postHitBodyEdge
        postHitR1FailCount := 0
        postHitR2FailCount := 0

    failureBuffer = retestFailureBufferPct / 100.0

    r1FailedNow =
         postHitUpside
         ? close < postHitR1 * (1.0 - failureBuffer)
         : close > postHitR1 * (1.0 + failureBuffer)

    r2FailedNow =
         postHitUpside
         ? close < postHitR2 * (1.0 - failureBuffer)
         : close > postHitR2 * (1.0 + failureBuffer)

    if postHitReclaimed
        postHitR1FailCount := r1FailedNow ? postHitR1FailCount + 1 : 0
        postHitR2FailCount := r2FailedNow ? postHitR2FailCount + 1 : 0

r1ConfirmedFailed =
     postHitActive and
     postHitReclaimed and
     postHitR1FailCount >= retestFailureCloses

r2ConfirmedFailed =
     postHitActive and
     postHitReclaimed and
     postHitR2FailCount >= retestFailureCloses

postHitHealth =
     not postHitActive ? "PLANNING" :
     not postHitReclaimed ? "FULFILLED — WAITING RECLAIM" :
     r2ConfirmedFailed ? "UNHEALTHY PULLBACK" :
     r1ConfirmedFailed ? "WARNING: TESTING R2" :
     "HEALTHY: R1 HOLDING"

// Prefer persistent post-hit levels after a target was fulfilled.
// Otherwise show the planned levels for the active target.
displayR1 =
     postHitActive
     ? postHitReclaimed ? postHitR1 : na
     : plannedR1

displayR2 =
     postHitActive
     ? postHitReclaimed ? postHitR2 : na
     : plannedR2

displayRoadmapUpside =
     postHitActive ? postHitUpside : plannedUpside

displayRoadmapSourceBar =
     postHitActive ? postHitSourceBar : plannedSourceBar

displayRoadmapGrade =
     postHitActive ? postHitGrade : plannedGrade

if barstate.islast
    if not na(pullbackRoadmapLine)
        line.delete(pullbackRoadmapLine)
        pullbackRoadmapLine := na

    if not na(pullback2RoadmapLine)
        line.delete(pullback2RoadmapLine)
        pullback2RoadmapLine := na

    if not na(continuationRoadmapLine)
        line.delete(continuationRoadmapLine)
        continuationRoadmapLine := na

    if not na(pullbackRoadmapLabel)
        label.delete(pullbackRoadmapLabel)
        pullbackRoadmapLabel := na

    if not na(pullback2RoadmapLabel)
        label.delete(pullback2RoadmapLabel)
        pullback2RoadmapLabel := na

    if not na(continuationRoadmapLabel)
        label.delete(continuationRoadmapLabel)
        continuationRoadmapLabel := na

    if showPostTargetRoadmap and showRoadmapLines and not na(displayR1)
        r1Color =
             postHitActive and r1ConfirmedFailed
             ? color.red
             : color.orange

        pullbackRoadmapLine := line.new(
             x1=bar_index + 1,
             y1=displayR1,
             x2=bar_index + roadmapProjectionBars,
             y2=displayR1,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=r1Color,
             style=line.style_dashed,
             width=2
        )

        pullbackRoadmapLabel := label.new(
             x=bar_index + roadmapProjectionBars,
             y=displayR1,
             xloc=xloc.bar_index,
             yloc=yloc.price,
             text="R1",
             style=label.style_label_left,
             color=r1Color,
             textcolor=color.white,
             size=size.tiny,
             tooltip="R1 = reclaimed wick extreme.\nIt becomes eligible only after price closes beyond the full wick.\nLevel: " +
                 str.tostring(displayR1, format.mintick) +
                 "\nCandle ID: " + (na(displayRoadmapSourceBar) ? "-" : str.tostring(displayRoadmapSourceBar)) +
                 "\nGrade: " + (displayRoadmapGrade == "" ? "-" : displayRoadmapGrade) +
                 "\nState: " + postHitHealth
        )

        if showSecondRetestLevel and not na(displayR2)
            r2Color =
                 postHitActive and r2ConfirmedFailed
                 ? color.red
                 : color.yellow

            pullback2RoadmapLine := line.new(
                 x1=bar_index + 1,
                 y1=displayR2,
                 x2=bar_index + roadmapProjectionBars,
                 y2=displayR2,
                 xloc=xloc.bar_index,
                 extend=extend.none,
                 color=r2Color,
                 style=line.style_dotted,
                 width=2
            )

            pullback2RoadmapLabel := label.new(
                 x=bar_index + roadmapProjectionBars,
                 y=displayR2,
                 xloc=xloc.bar_index,
                 yloc=yloc.price,
                 text="R2",
                 style=label.style_label_left,
                 color=r2Color,
                 textcolor=color.black,
                 size=size.tiny,
                 tooltip="R2 = original body-edge target of the same reclaimed wick.\nDeeper support/resistance if R1 fails.\nLevel: " +
                     str.tostring(displayR2, format.mintick) +
                     "\nIf R2 also fails on the configured closes, the pullback is classified as unhealthy." +
                     "\nState: " + postHitHealth
            )

        if not na(continuationLevel)
            continuationRoadmapLine := line.new(
                 x1=bar_index + 1,
                 y1=continuationLevel,
                 x2=bar_index + roadmapProjectionBars,
                 y2=continuationLevel,
                 xloc=xloc.bar_index,
                 extend=extend.none,
                 color=color.aqua,
                 style=line.style_dotted,
                 width=2
            )

            continuationRoadmapLabel := label.new(
                 x=bar_index + roadmapProjectionBars,
                 y=continuationLevel,
                 xloc=xloc.bar_index,
                 yloc=yloc.price,
                 text="NEXT",
                 style=label.style_label_left,
                 color=color.aqua,
                 textcolor=color.black,
                 size=size.tiny,
                 tooltip="NEXT = next same-direction magnet if price continues.\nLevel: " +
                     str.tostring(continuationLevel, format.mintick) +
                     "\nDistance beyond current target: " +
                     str.tostring(continuationDistanceFromTargetPct, "#.##") + "%"
            )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// UPDATE SOURCE-LINE VISIBILITY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if array.size(targetLevelArr) > 0
    for i = 0 to array.size(targetLevelArr) - 1
        level = array.get(targetLevelArr, i)
        extreme = array.get(wickExtremeArr, i)
        sourceBar = array.get(sourceBarArr, i)
        isUpside = array.get(isUpsideArr, i)
        isDelayed = array.get(isDelayedArr, i)
        wasTouched = array.get(wasTouchedArr, i)
        magnetGradeScore = array.get(gradeScoreArr, i)
        magnetGrade = array.get(gradeArr, i)

        selected = not na(selectedIndex) and i == selectedIndex
        inLookback = bar_index - sourceBar <= lookbackBars
        eligibleByTouch = not showOnlyUntouchedMagnets or not wasTouched
        shouldShow = inLookback and eligibleByTouch and targetVisible(isDelayed) and (not showOnlyNextMagnet or selected)

        line ln = array.get(targetLineArr, i)
        label dot = array.get(targetDotArr, i)

        if shouldShow
            if na(ln)
                biasAgrees =
                     (priceActionBias == 1 and isUpside) or
                     (priceActionBias == -1 and not isUpside)

                selectedExtended = selected and extendSelectedMagnet and biasAgrees
                lineEndX = selectedExtended ? bar_index + selectedLineBarsRight : sourceBar + lineBarsRight

                ln := line.new(
                     x1=sourceBar - lineBarsLeft,
                     y1=level,
                     x2=lineEndX,
                     y2=level,
                     xloc=xloc.bar_index,
                     extend=extend.none,
                     color=gradeColor(magnetGrade),
                     style=isDelayed ? line.style_dashed : line.style_solid,
                     width=selected ? 3 : isDelayed ? 1 : 2
                )
                array.set(targetLineArr, i, ln)
            else
                biasAgrees =
                     (priceActionBias == 1 and isUpside) or
                     (priceActionBias == -1 and not isUpside)

                selectedExtended = selected and extendSelectedMagnet and biasAgrees
                lineEndX = selectedExtended ? bar_index + selectedLineBarsRight : sourceBar + lineBarsRight

                line.set_xy1(ln, sourceBar - lineBarsLeft, level)
                line.set_xy2(ln, lineEndX, level)
                line.set_color(ln, gradeColor(magnetGrade))
                line.set_width(ln, selected ? 3 : isDelayed ? 1 : 2)

            if showSourceDots
                if na(dot)
                    dot := label.new(
                         x=(selected and extendSelectedMagnet and ((priceActionBias == 1 and isUpside) or (priceActionBias == -1 and not isUpside))) ? bar_index + selectedLineBarsRight : sourceBar + lineBarsRight,
                         y=level,
                         xloc=xloc.bar_index,
                         yloc=yloc.price,
                         text="",
                         style=label.style_circle,
                         color=gradeColor(magnetGrade),
                         textcolor=color.white,
                         size=selected ? size.small : size.tiny,
                         tooltip=targetTooltip(isUpside, isDelayed, level, extreme, sourceBar, magnetGrade, magnetGradeScore)
                    )
                    array.set(targetDotArr, i, dot)
                else
                    label.set_x(dot, (selected and extendSelectedMagnet and ((priceActionBias == 1 and isUpside) or (priceActionBias == -1 and not isUpside))) ? bar_index + selectedLineBarsRight : sourceBar + lineBarsRight)
                    label.set_y(dot, level)
                    label.set_size(dot, selected ? size.small : size.tiny)
                    label.set_tooltip(dot, targetTooltip(isUpside, isDelayed, level, extreme, sourceBar, magnetGrade, magnetGradeScore))
            else if not na(dot)
                label.delete(dot)
                array.set(targetDotArr, i, na)
        else
            if not na(ln)
                line.delete(ln)
                array.set(targetLineArr, i, na)

            if not na(dot)
                label.delete(dot)
                array.set(targetDotArr, i, na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MAGNET-HIT LOGIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool upsideTargetHit = false
bool downsideTargetHit = false
bool delayedUpsideTargetHit = false
bool delayedDownsideTargetHit = false

if array.size(targetLevelArr) > 0
    for i = array.size(targetLevelArr) - 1 to 0
        targetLevel = array.get(targetLevelArr, i)
        sourceBar = array.get(sourceBarArr, i)
        isUpside = array.get(isUpsideArr, i)
        isDelayed = array.get(isDelayedArr, i)

        ageBars = bar_index - sourceBar
        oldEnough = ageBars >= minBarsBeforeTargetHit
        expiredByAge = maxTargetAgeBars > 0 and ageBars > maxTargetAgeBars
        expiredByLookback = ageBars > lookbackBars
        expired = expiredByAge or expiredByLookback

        upsideHit =
             oldEnough and
             isUpside and
             high[1] < targetLevel and
             high >= targetLevel

        downsideHit =
             oldEnough and
             not isUpside and
             low[1] > targetLevel and
             low <= targetLevel

        delayedAllowed = not isDelayed or signalDelayedTargets

        if upsideHit and delayedAllowed
            upsideTargetHit := not isDelayed
            delayedUpsideTargetHit := isDelayed

            postHitActive := true
            postHitUpside := true
            postHitReclaimed := false
            postHitWickExtreme := array.get(wickExtremeArr, i)
            postHitBodyEdge := targetLevel
            postHitR1 := na
            postHitR2 := na
            postHitBar := bar_index
            postHitSourceBar := sourceBar
            postHitGrade := array.get(gradeArr, i)
            postHitReclaimCount := 0
            postHitR1FailCount := 0
            postHitR2FailCount := 0

            archiveHitTarget(i)
            deleteTargetAt(i)

        else if downsideHit and delayedAllowed
            downsideTargetHit := not isDelayed
            delayedDownsideTargetHit := isDelayed

            postHitActive := true
            postHitUpside := false
            postHitReclaimed := false
            postHitWickExtreme := array.get(wickExtremeArr, i)
            postHitBodyEdge := targetLevel
            postHitR1 := na
            postHitR2 := na
            postHitBar := bar_index
            postHitSourceBar := sourceBar
            postHitGrade := array.get(gradeArr, i)
            postHitReclaimCount := 0
            postHitR1FailCount := 0
            postHitR2FailCount := 0

            archiveHitTarget(i)
            deleteTargetAt(i)

        else if expired
            deleteTargetAt(i)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HIT MARKERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plotshape(
     showHitLabels and upsideTargetHit,
     title="Clean Upside Magnet Hit",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.lime,
     size=size.tiny,
     text="UT",
     textcolor=color.white
)

plotshape(
     showHitLabels and downsideTargetHit,
     title="Clean Downside Magnet Hit",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.tiny,
     text="DT",
     textcolor=color.white
)

plotshape(
     showHitLabels and delayedUpsideTargetHit,
     title="Delayed Upside Magnet Hit",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.new(color.lime, 55),
     size=size.tiny,
     text="DUT",
     textcolor=color.white
)

plotshape(
     showHitLabels and delayedDownsideTargetHit,
     title="Delayed Downside Magnet Hit",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.new(color.red, 55),
     size=size.tiny,
     text="DDT",
     textcolor=color.white
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// THREE-ROW TWO-LEVEL ROADMAP TABLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table nextMagnetTable = table.new(
     position.bottom_center,
     6,
     3,
     border_width=1
)

if barstate.islast
    if showNextMagnetTable
        table.clear(nextMagnetTable, 0, 0, 5, 2)

        if not na(selectedIndex) and selectedIndex < array.size(targetLevelArr)
            selectedLevel = array.get(targetLevelArr, selectedIndex)
            selectedUpside = array.get(isUpsideArr, selectedIndex)
            selectedDelayed = array.get(isDelayedArr, selectedIndex)
            selectedSourceBar = array.get(sourceBarArr, selectedIndex)
            selectedGrade = array.get(gradeArr, selectedIndex)
            selectedGradeScore = array.get(gradeScoreArr, selectedIndex)

            direction = selectedUpside ? "UP" : "DOWN"
            quality = selectedDelayed ? "Delayed" : "Clean"
            idText = targetId(selectedUpside, selectedSourceBar)
            distanceText = str.tostring(selectedDistancePct, "#.##") + "%"
            levelText = str.tostring(selectedLevel, format.mintick)
            bg = selectedUpside ? color.new(color.green, 75) : color.new(color.red, 75)

            entryText = not na(lastAcceptableEntry) ? str.tostring(lastAcceptableEntry, format.mintick) : "-"
            zoneText = not na(displayedEntryLow) and not na(displayedEntryHigh)
                 ? str.tostring(displayedEntryLow, format.mintick) + "–" + str.tostring(displayedEntryHigh, format.mintick)
                 : "-"
            potentialText = not na(profitFromClosePct) ? str.tostring(profitFromClosePct, "#.##") + "%" : "-"
            leverageText = not na(grossLeveragedReturnPct)
                 ? str.tostring(expectedLeverage, "#.##") + "x ≈ " + str.tostring(grossLeveragedReturnPct, "#.##") + "%"
                 : "-"

            r1Text =
                 postHitActive and not postHitReclaimed
                 ? "WAIT"
                 : not na(displayR1)
                 ? str.tostring(displayR1, format.mintick)
                 : "-"

            r2Text =
                 postHitActive and not postHitReclaimed
                 ? "WAIT"
                 : not na(displayR2)
                 ? str.tostring(displayR2, format.mintick)
                 : "-"
            nextText = not na(continuationLevel) ? str.tostring(continuationLevel, format.mintick) : "None"

            // Row 1: current target
            table.cell(nextMagnetTable, 0, 0, "TARGET", text_color=color.white, bgcolor=color.black)
            table.cell(nextMagnetTable, 1, 0, direction + " | " + levelText, text_color=color.white, bgcolor=bg)
            table.cell(nextMagnetTable, 2, 0, "Grade " + selectedGrade + " | " + str.tostring(selectedGradeScore, "#"), text_color=color.white, bgcolor=color.new(gradeColor(selectedGrade), 35))
            table.cell(nextMagnetTable, 3, 0, distanceText, text_color=color.white, bgcolor=bg)
            table.cell(nextMagnetTable, 4, 0, quality, text_color=color.white, bgcolor=bg)
            table.cell(nextMagnetTable, 5, 0, idText, text_color=color.white, bgcolor=bg)

            // Row 2: current entry
            table.cell(nextMagnetTable, 0, 1, "ENTRY", text_color=color.white, bgcolor=color.black)
            table.cell(nextMagnetTable, 1, 1, "Last " + entryText, text_color=color.white, bgcolor=bg)
            table.cell(nextMagnetTable, 2, 1, "Zone " + zoneText, text_color=color.white, bgcolor=bg)
            table.cell(nextMagnetTable, 3, 1, "Move " + potentialText, text_color=color.white, bgcolor=bg)
            table.cell(nextMagnetTable, 4, 1, leverageText, text_color=color.white, bgcolor=bg)
            table.cell(nextMagnetTable, 5, 1, entryState, text_color=color.white, bgcolor=bg)

            // Row 3: after target is hit
            healthBg =
                 postHitHealth == "UNHEALTHY PULLBACK" ? color.new(color.red, 25) :
                 postHitHealth == "WARNING: TESTING R2" ? color.new(color.orange, 25) :
                 postHitHealth == "HEALTHY: R1 HOLDING" ? color.new(color.green, 35) :
                 color.new(color.gray, 55)

            table.cell(nextMagnetTable, 0, 2, "AFTER HIT", text_color=color.white, bgcolor=color.black)
            table.cell(nextMagnetTable, 1, 2, "R1 " + r1Text, text_color=color.white, bgcolor=color.new(color.orange, 35))
            table.cell(nextMagnetTable, 2, 2, "R2 " + r2Text, text_color=color.black, bgcolor=color.new(color.yellow, 25))
            table.cell(nextMagnetTable, 3, 2, postHitHealth, text_color=color.white, bgcolor=healthBg)
            table.cell(nextMagnetTable, 4, 2, "NEXT " + nextText, text_color=color.black, bgcolor=color.new(color.aqua, 25))
            table.cell(nextMagnetTable, 5, 2, "No reclaim = no retest; R1 fail → R2; R2 fail → unhealthy", text_color=color.white, bgcolor=color.new(color.gray, 55))
        else
            table.cell(nextMagnetTable, 0, 0, "TARGET", text_color=color.white, bgcolor=color.black)
            table.cell(nextMagnetTable, 1, 0, "None", text_color=color.silver, bgcolor=color.new(color.black, 15))
            table.cell(nextMagnetTable, 0, 1, "ENTRY", text_color=color.white, bgcolor=color.black)
            table.cell(nextMagnetTable, 1, 1, "-", text_color=color.silver, bgcolor=color.new(color.black, 15))
            table.cell(nextMagnetTable, 0, 2, "AFTER HIT", text_color=color.white, bgcolor=color.black)
            table.cell(nextMagnetTable, 1, 2, postHitHealth, text_color=color.silver, bgcolor=color.new(color.black, 15))
    else
        table.clear(nextMagnetTable, 0, 0, 5, 2)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(
     upsideTargetHit,
     title="Clean Upside Magnet Hit",
     message="Price reached a clean remembered upper-wick magnet."
)

alertcondition(
     downsideTargetHit,
     title="Clean Downside Magnet Hit",
     message="Price reached a clean remembered lower-wick magnet."
)

alertcondition(
     delayedUpsideTargetHit,
     title="Delayed Upside Magnet Hit",
     message="Price reached a delayed upper-wick magnet."
)

alertcondition(
     delayedDownsideTargetHit,
     title="Delayed Downside Magnet Hit",
     message="Price reached a delayed lower-wick magnet."
)
````
