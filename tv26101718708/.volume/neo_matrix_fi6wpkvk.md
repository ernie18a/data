# _Neo Matrix_

- url: https://www.tradingview.com/script/fI6wPkvk/
- type: indicator
- pine_id: PUB;85e1edfb87bf4d16b584389cdc2761e0
- version: 3.0

## Description

_Neo Matrix_ is a market-state and structure reading system — built to make premium-style market structure tools freely accessible to the TradingView community.

The main idea is simple:
Core shows the market center.
Wall shows the structural defense line.
Trend Guide shows adaptive price boundaries.
Stretch Zones show expansion and exhaustion areas.
Dashboard summarizes the current state.

Neo Matrix is intended as a visual framework for reading structure, pressure, expansion, and tactical context more clearly.

The system combines several visual and contextual components:

• Neo Core  
Neo Core acts as the central reference layer of the system, helping traders observe whether price is moving near, above, or below its main market center.

[image]https://www.tradingview.com/x/vwH9MUZq/[/image]


• Neo Wall 
Neo Wall is a structural defense line designed to show the active market regime and the area where price structure is being defended.

[url=https://www.tradingview.com/x/HudhU6dF/]https://www.tradingview.com/x/HudhU6dF/[/url]


• Trend Guide
Trend Guide is an adaptive boundary-based layer that helps visualize meaningful price displacement. Its upper and lower boundaries can be displayed to observe where price needs to move before the guide updates.

[image]https://www.tradingview.com/x/kjRj8N7o/]https://www.tradingview.com/x/kjRj8N7o/[image]


• Stretch Zones
Stretch Zones are expansion areas around the Core. They help identify when price is moving far away from its central structure and entering a stretched condition.

[image]https://www.tradingview.com/x/usY4G3AK/]https://www.tradingview.com/x/usY4G3AK/[image]


• Candle Coloring
Candle Coloring is a momentum-based visual layer that helps traders read short-term market tone directly on the candles.

[image]https://www.tradingview.com/x/yisxlCaq/]https://www.tradingview.com/x/yisxlCaq/[image]


• State Dashboard
State Dashboard is a compact panel that summarizes the current market state through three simple fields:

REGIME — structural alignment between Wall and Trend Guide.
FLOW — volume-flow-based pressure reading; neutral, bullish, bearish, or stronger pressure zones.
WATCH — tactical watch state based on context and active setup areas.

[image]https://www.tradingview.com/x/JMMLB0Vu/]https://www.tradingview.com/x/JMMLB0Vu/[image]

The market has its own Matrix. Neo helps you read it.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Reeduck
// _Neo Matrix_

//@version=6 
indicator("_Neo Matrix_", overlay=true, max_bars_back=5000)

//====================================================
// INPUTS
//====================================================
groupDisplay = "Display"

showNeoCore               = input.bool(true,  "Neo Core", group=groupDisplay)
showNeoCoreBand           = input.bool(true,  "Core Inner Bands", group=groupDisplay)
neoCoreBandFillTransp     = input.int(55, "Core Band Fill Transparency", minval=0, maxval=100, group=groupDisplay)

showNeoWall               = input.bool(true,  "Neo Wall", group=groupDisplay)
neoWallMode               = input.string("Standard", "Wall Mode", options=["Early", "Standard", "Strict"], group=groupDisplay)
showNeoWallShadow         = input.bool(true,  "Defense Shadow", group=groupDisplay)

showNeoTrendGuide         = input.bool(true,  "Trend Guide", group=groupDisplay)
showNeoTrendGuideBounds   = input.bool(false, "Trend Guide Boundaries", group=groupDisplay)
neoTrendGuideMode         = input.string("Standard", "Trend Guide Mode", options=["Early", "Standard", "Strict"], group=groupDisplay)

showNeoCoreStretchZones   = input.bool(true,  "Stretch Zones", group=groupDisplay)
neoCoreStretchFillTransp  = input.int(55, "Stretch Fill Transparency", minval=0, maxval=100, group=groupDisplay)

showNeoBarColor           = input.bool(true,  "Candle Coloring", group=groupDisplay)
neoCandleColorMode        = input.string("Standard", "Candle Mode", options=["Early", "Standard", "Strict"], group=groupDisplay)

groupDashboard = "State Dashboard"

showNeoStateDashboard =
     input.bool(true, "State Dashboard", group=groupDashboard)

showNeoCompareDashboard =
     input.bool(false, "Compare Mode", group=groupDashboard)

neoDashboardSide =
     input.string("Right", "Dashboard Side", options=["Right", "Left"], group=groupDashboard)

neoCompareSymbol =
     input.symbol("BINANCE:BTCUSDT.P", "Compare Pair", group=groupDashboard)

neoCompareTimeframe =
     input.timeframe("240", "Compare Timeframe", group=groupDashboard)

//====================================================
// QUALITY FILTERS
//====================================================

neoContextLookback = 8

histDirectionLookback = 3
histFibLookback       = 144
histFibRatio          = 0.0382

neoCoreSlopeLookback    = 8
neoCoreSlopeFibLookback = 144
neoCoreSlopeFibRatio    = 0.0236

neoFlowFibLookback = 144
neoFlowFibRatio    = 0.0618

//====================================================
// CORE PARAMETERS
//====================================================

// Neo Corridor
neoShadowMult           = 1.3
neoShadowTrans          = 77
neoWallWidth            = 2

// Neo Flow / MFI
neoFlowLen               = 34
neoFlowSmooth            = 8
neoFlowDirectionLookback = 3
neoFlowStrongOffset      = 10.0
neoFlowMemory            = neoFlowLen

// Neo Core
neoCoreSrc           = hlc3
neoCoreLen           = 200
neoCoreInnerBandMult = 0.60

// Neo Core Stretch
neoCoreStretchRangeLen     = 89
neoCoreStretchBaseMult     = 1.854
neoCoreStretchGradientSize = 0.55

// Neo Score Weights
neoScoreFlowWeight      = 1.10
neoScoreCoreSlopeWeight = 1.00
neoScoreHistWeight      = 0.90
neoScoreStretchWeight   = 0.90

//====================================================
// COLORS
//====================================================
groupColors = "Colors"

neoCoreColor = input.color(color.white, "Core Line", group=groupColors)

neoWallUpColor   = input.color(color.rgb(96, 92, 255), "Long Wall / Lower Stretch", group=groupColors)
neoWallDownColor = input.color(color.rgb(233, 0, 0), "Short Wall / Upper Stretch", group=groupColors)

neoTrendGuideCenterColor = input.color(color.white, "Trend Guide Center", group=groupColors)
neoTrendGuideUpperColor  = input.color(color.rgb(255, 93, 0), "Trend Guide Upper Boundary", group=groupColors)
neoTrendGuideLowerColor  = input.color(color.rgb(220, 220, 220), "Trend Guide Lower Boundary", group=groupColors)

neoBullColorInput       = input.color(color.rgb(0, 233, 13), "Bull Candle", group=groupColors)
neoBearColorInput       = input.color(color.rgb(233, 0, 0), "Bear Candle", group=groupColors)
neoTransitionColorInput = input.color(color.rgb(89, 55, 144), "Transition Candle", group=groupColors)

eps = 1e-10
var float PI = 2.0 * math.asin(1.0)

//====================================================
// HELPERS
//====================================================
f_array_avg(float[] arr) =>
    int sz = array.size(arr)

    if sz == 0
        na
    else
        float sum = 0.0

        for i = 0 to sz - 1
            sum += array.get(arr, i)

        sum / sz

supersmoother(_src, _length) =>
    a1 = math.exp(-math.sqrt(2.0) * PI / _length)
    b1 = 2.0 * a1 * math.cos(math.sqrt(2.0) * PI / _length)
    c3 = -math.pow(a1, 2)
    c2 = b1
    c1 = 1.0 - c2 - c3

    ss = 0.0
    ss := c1 * _src + c2 * nz(ss[1], _src[1]) + c3 * nz(ss[2], _src[2])
    ss

f_neo_trend_guide_held(_src, _length, _mult) =>
    currentRange =
         nz(ta.atr(_length)) * _mult

    var float guideAvg = na
    var float heldRange = na

    guidePrev =
         nz(guideAvg[1], _src)

    heldRangePrev =
         nz(heldRange[1], currentRange)

    upperTrigger =
         guidePrev + heldRangePrev

    lowerTrigger =
         guidePrev - heldRangePrev

    moveUp =
         _src > upperTrigger

    moveDown =
         _src < lowerTrigger

    guideCandidate =
         moveUp   ? guidePrev + currentRange :
         moveDown ? guidePrev - currentRange :
         guidePrev

    heldRangeCandidate =
         moveUp or moveDown ? currentRange : heldRangePrev

    guideAvg :=
         barstate.isconfirmed ? guideCandidate : guidePrev

    heldRange :=
         barstate.isconfirmed ? heldRangeCandidate : heldRangePrev

    liveGuide =
         barstate.isconfirmed ? guideAvg : guideCandidate

    liveRange =
         barstate.isconfirmed ? heldRange : heldRangeCandidate

    liveUpper =
         liveGuide + liveRange

    liveLower =
         liveGuide - liveRange

    [liveGuide, liveUpper, liveLower]

f_neo_trend_guide_held_confirmed(_src, _length, _mult) =>
    currentRange =
         nz(ta.atr(_length)) * _mult

    var float guideAvg = na
    var float heldRange = na

    guidePrev =
         nz(guideAvg[1], _src)

    heldRangePrev =
         nz(heldRange[1], currentRange)

    upperTrigger =
         guidePrev + heldRangePrev

    lowerTrigger =
         guidePrev - heldRangePrev

    moveUp =
         _src > upperTrigger

    moveDown =
         _src < lowerTrigger

    guideAvg :=
         moveUp   ? guidePrev + currentRange :
         moveDown ? guidePrev - currentRange :
         guidePrev

    heldRange :=
         moveUp or moveDown ? currentRange : heldRangePrev

    upperBoundary =
         guideAvg + heldRange

    lowerBoundary =
         guideAvg - heldRange

    [guideAvg, upperBoundary, lowerBoundary]

//====================================================
// NEO CORE
//====================================================
neoCore = supersmoother(neoCoreSrc, neoCoreLen)

neoCoreRawRange =
     supersmoother(ta.tr, neoCoreLen)

neoCoreUpperBand =
     neoCore + neoCoreRawRange * neoCoreInnerBandMult

neoCoreLowerBand =
     neoCore - neoCoreRawRange * neoCoreInnerBandMult

neoCoreAdaptLen = math.max(20, int(neoCoreLen * 0.5))

neoCoreStdevRaw    = ta.stdev(neoCoreSrc, neoCoreAdaptLen)
neoCoreStdevBase   = ta.ema(neoCoreStdevRaw, neoCoreLen)
neoCoreStdRatioRaw = neoCoreStdevBase != 0.0 ? neoCoreStdevRaw / neoCoreStdevBase : 1.0
neoCoreStdRatio    = ta.ema(neoCoreStdRatioRaw, 10)

neoCoreRawAdaptive    = 1.0 + (neoCoreStdRatio - 1.0) * 0.25
neoCoreAdaptiveFactor = math.max(0.92, math.min(neoCoreRawAdaptive, 1.10))

neoCoreStretchRawRange =
     supersmoother(ta.tr, neoCoreStretchRangeLen)

neoCoreStretchBase =
     neoCoreStretchRawRange * PI * neoCoreStretchBaseMult * neoCoreAdaptiveFactor

neoCoreStretchStep =
     neoCoreStretchRawRange * neoCoreStretchGradientSize * 4.0

neoCoreUpperStretchInnerLine =
     neoCore + neoCoreStretchBase

neoCoreUpperStretchOuterLine =
     neoCore + neoCoreStretchBase + neoCoreStretchStep

neoCoreLowerStretchInnerLine =
     neoCore - neoCoreStretchBase

neoCoreLowerStretchOuterLine =
     neoCore - neoCoreStretchBase - neoCoreStretchStep

neoCoreUpperStretchFadeOuterLine =
     neoCoreUpperStretchOuterLine + neoCoreStretchStep

neoCoreLowerStretchFadeOuterLine =
     neoCoreLowerStretchOuterLine - neoCoreStretchStep

neoCoreStretchFadeFillTransp =
     math.min(100, neoCoreStretchFillTransp + 13)

neoCoreStretch =
     neoCoreStretchBase > eps ? (close - neoCore) / neoCoreStretchBase : 0.0

neoUpperStretchZoneTouch =
     high >= neoCoreUpperStretchInnerLine

neoLowerStretchZoneTouch =
     low <= neoCoreLowerStretchInnerLine

neoStretchZoneTouch =
     neoUpperStretchZoneTouch or neoLowerStretchZoneTouch

//====================================================
// NEO CORE SLOPE DIRECTION
//====================================================
neoCoreSlope =
     neoCore - neoCore[neoCoreSlopeLookback]

neoCoreSlopeRangeHigh = ta.highest(neoCoreSlope, neoCoreSlopeFibLookback)
neoCoreSlopeRangeLow  = ta.lowest(neoCoreSlope, neoCoreSlopeFibLookback)
neoCoreSlopeRange     = neoCoreSlopeRangeHigh - neoCoreSlopeRangeLow

neoCoreSlopeMoveThreshold =
     not na(neoCoreSlopeRange) and neoCoreSlopeRange > eps ? neoCoreSlopeRange * neoCoreSlopeFibRatio : na

neoCoreSlopeLongBias =
     not na(neoCoreSlopeMoveThreshold) and
     neoCoreSlope > neoCoreSlopeMoveThreshold

neoCoreSlopeShortBias =
     not na(neoCoreSlopeMoveThreshold) and
     neoCoreSlope < -neoCoreSlopeMoveThreshold

//====================================================
// NEO FLOW / MFI CONTEXT + STRONG FLOW BLOCKER
//====================================================
neoFlowValue =
     ta.sma(ta.mfi(hl2, neoFlowLen) - 50.0, neoFlowSmooth)

var float[] neoFlowPosMemory = array.new_float()
var float[] neoFlowNegMemory = array.new_float()

if barstate.isconfirmed
    if neoFlowValue > 0
        array.unshift(neoFlowPosMemory, neoFlowValue)

        if array.size(neoFlowPosMemory) > neoFlowMemory
            array.pop(neoFlowPosMemory)

        if array.size(neoFlowNegMemory) > 1
            array.pop(neoFlowNegMemory)

    else if neoFlowValue < 0
        array.unshift(neoFlowNegMemory, neoFlowValue)

        if array.size(neoFlowNegMemory) > neoFlowMemory
            array.pop(neoFlowNegMemory)

        if array.size(neoFlowPosMemory) > 1
            array.pop(neoFlowPosMemory)

neoFlowPosAvg = f_array_avg(neoFlowPosMemory)
neoFlowNegAvg = f_array_avg(neoFlowNegMemory)

neoFlowBullStrongThreshold =
     not na(neoFlowPosAvg) ? math.max(neoFlowPosAvg, neoFlowStrongOffset) : na

neoFlowBearStrongThreshold =
     not na(neoFlowNegAvg) ? math.min(neoFlowNegAvg, -neoFlowStrongOffset) : na

neoFlowBullStrongZone =
     not na(neoFlowBullStrongThreshold) ? math.max(neoFlowValue - neoFlowBullStrongThreshold, 0.0) : na

neoFlowBearStrongZone =
     not na(neoFlowBearStrongThreshold) ? math.min(neoFlowValue - neoFlowBearStrongThreshold, 0.0) : na

bullishStrongFlow =
     not na(neoFlowBullStrongZone) and neoFlowBullStrongZone > 0

bearishStrongFlow =
     not na(neoFlowBearStrongZone) and neoFlowBearStrongZone < 0

neoFlowRangeHigh = ta.highest(neoFlowValue, neoFlowFibLookback)
neoFlowRangeLow  = ta.lowest(neoFlowValue, neoFlowFibLookback)
neoFlowRange     = neoFlowRangeHigh - neoFlowRangeLow

neoFlowMoveThreshold =
     not na(neoFlowRange) and neoFlowRange > eps ? neoFlowRange * neoFlowFibRatio : na

neoFlowDeltaFromPast =
     neoFlowValue - neoFlowValue[neoFlowDirectionLookback]

neoFlowLongBias =
     (
         not na(neoFlowDeltaFromPast) and
         not na(neoFlowMoveThreshold) and
         neoFlowDeltaFromPast > neoFlowMoveThreshold
     ) or
     (neoFlowValue > 0 and neoFlowValue > nz(neoFlowValue[1]))

neoFlowShortBias =
     (
         not na(neoFlowDeltaFromPast) and
         not na(neoFlowMoveThreshold) and
         neoFlowDeltaFromPast < -neoFlowMoveThreshold
     ) or
     (neoFlowValue < 0 and neoFlowValue < nz(neoFlowValue[1]))

//====================================================
// NEO WALL
//====================================================
neoWallLen = switch neoWallMode
    "Early"    => 13
    "Standard" => 21
    => 55

neoWallMult = switch neoWallMode
    "Early"    => 3.618
    "Standard" => 4.236
    => 5.236

neoWallSmooth = switch neoWallMode
    "Early"    => 8
    "Standard" => 13
    => 34

neoWallConfirmCloses = 2

neoWallSmoothedSrc =
     supersmoother(close, neoWallSmooth)

neoWallAtrValue =
     ta.atr(neoWallLen)

var float neoWall = 0.0
var int   neoDir  = 1

var int neoBelowCloseCount = 0
var int neoAboveCloseCount = 0

neoUpper =
     neoWallSmoothedSrc + neoWallMult * neoWallAtrValue

neoLower =
     neoWallSmoothedSrc - neoWallMult * neoWallAtrValue

neoWall :=
     neoDir == 1
     ? math.max(neoLower, nz(neoWall[1], neoLower))
     : math.min(neoUpper, nz(neoWall[1], neoUpper))

if barstate.isconfirmed
    if neoDir == 1
        neoBelowCloseCount := close < neoWall ? nz(neoBelowCloseCount[1]) + 1 : 0
        neoAboveCloseCount := 0

        if neoBelowCloseCount >= neoWallConfirmCloses
            neoDir := -1
            neoWall := neoUpper
            neoBelowCloseCount := 0
            neoAboveCloseCount := 0

    else
        neoAboveCloseCount := close > neoWall ? nz(neoAboveCloseCount[1]) + 1 : 0
        neoBelowCloseCount := 0

        if neoAboveCloseCount >= neoWallConfirmCloses
            neoDir := 1
            neoWall := neoLower
            neoBelowCloseCount := 0
            neoAboveCloseCount := 0

//====================================================
// NEO TREND GUIDE
//====================================================
int neoTrendGuideLen = switch neoTrendGuideMode
    "Early"    => 120
    "Standard" => 144
    => 233

float neoTrendGuideMult = switch neoTrendGuideMode
    "Early"    => 2.618
    "Standard" => 4.236
    => 6.854

neoTrendGuideSrc =
     hlc3

[neoTrendGuide, neoTrendGuideUpperBoundary, neoTrendGuideLowerBoundary] =
     f_neo_trend_guide_held(
         neoTrendGuideSrc,
         neoTrendGuideLen,
         neoTrendGuideMult
     )

neoTrendGuideRawDir =
     neoTrendGuide > nz(neoTrendGuide[1], neoTrendGuide) ? 1 :
     neoTrendGuide < nz(neoTrendGuide[1], neoTrendGuide) ? -1 :
     0

var int neoTrendGuideColorDir = 1

if neoTrendGuideRawDir == 1
    neoTrendGuideColorDir := 1
else if neoTrendGuideRawDir == -1
    neoTrendGuideColorDir := -1
else
    neoTrendGuideColorDir := nz(neoTrendGuideColorDir[1], 1)

neoTrendGuidePlotColor =
     neoTrendGuideCenterColor

//====================================================
// NEO STRUCTURE
//====================================================
neoWallShadowLine =
     neoWall + (neoDir == 1 ? neoShadowMult * neoWallAtrValue : -neoShadowMult * neoWallAtrValue)

neoColor =
     neoDir == 1 ? neoWallUpColor : neoWallDownColor

prevNeoDir =
     nz(neoDir[1], neoDir)

prevNeoWall =
     nz(neoWall[1], neoWall)

prevNeoAtr =
     nz(neoWallAtrValue[1], neoWallAtrValue)

prevNeoWallShadowLine =
     prevNeoWall + (prevNeoDir == 1 ? neoShadowMult * prevNeoAtr : -neoShadowMult * prevNeoAtr)

neoBufferTouchPrevRegime =
     prevNeoDir == 1  ? low <= prevNeoWallShadowLine :
     prevNeoDir == -1 ? high >= prevNeoWallShadowLine :
     false

neoLineTouchOrBreakPrevRegime =
     prevNeoDir == 1  ? low <= prevNeoWall :
     prevNeoDir == -1 ? high >= prevNeoWall :
     false

neoWallSetupTouch =
     neoBufferTouchPrevRegime or
     neoLineTouchOrBreakPrevRegime

neoSetupTouch =
     neoWallSetupTouch or
     neoStretchZoneTouch

//====================================================
// NEO CANDLE COLORING
//====================================================
neoMacdFastLen = switch neoCandleColorMode
    "Early"    => 13
    "Standard" => 7
    => 13

neoMacdSlowLen = switch neoCandleColorMode
    "Early"    => 21
    "Standard" => 12
    => 21

neoMacdSignalLen = switch neoCandleColorMode
    "Early"    => 8
    "Standard" => 5
    => 8

neoCandleMacdSource =
     neoCandleColorMode == "Early" ? neoCoreSrc : neoCore

[neoMacdVal, neoMacdSignal, neoMacdHist] =
     ta.macd(neoCandleMacdSource, neoMacdFastLen, neoMacdSlowLen, neoMacdSignalLen)

neoBullAligned =
     neoMacdVal > 0 and neoMacdHist > 0

neoBearAligned =
     neoMacdVal < 0 and neoMacdHist < 0

neoTransition =
     (neoMacdVal > 0 and neoMacdHist < 0) or
     (neoMacdVal < 0 and neoMacdHist > 0)

neoBullColor =
     neoBullColorInput

neoBearColor =
     neoBearColorInput

neoTransitionColor =
     neoTransitionColorInput

neoCandleBody =
     neoTransitionColor

if neoBullAligned
    neoCandleBody := neoBullColor
else if neoBearAligned
    neoCandleBody := neoBearColor
else if neoTransition
    neoCandleBody := neoTransitionColor

neoHistRangeHigh =
     ta.highest(neoMacdHist, histFibLookback)

neoHistRangeLow =
     ta.lowest(neoMacdHist, histFibLookback)

neoHistRange =
     neoHistRangeHigh - neoHistRangeLow

neoHistMoveThreshold =
     not na(neoHistRange) and neoHistRange > eps ? neoHistRange * histFibRatio : na

neoHistAbsNow =
     math.abs(neoMacdHist)

neoHistAbsPast =
     math.abs(neoMacdHist[histDirectionLookback])

neoHistAbsMove =
     neoHistAbsNow - neoHistAbsPast

neoHistPowerGrowing =
     not na(neoHistAbsMove) and
     not na(neoHistMoveThreshold) and
     neoHistAbsMove > neoHistMoveThreshold

neoHistPowerShrinking =
     not na(neoHistAbsMove) and
     not na(neoHistMoveThreshold) and
     neoHistAbsMove < -neoHistMoveThreshold

neoCandleLongBias =
     (neoMacdHist > 0 and neoHistPowerGrowing) or
     (neoMacdHist < 0 and neoHistPowerShrinking)

neoCandleShortBias =
     (neoMacdHist < 0 and neoHistPowerGrowing) or
     (neoMacdHist > 0 and neoHistPowerShrinking)

//====================================================
// CONTEXT SCORE ENGINE
//====================================================

neoLongContextScoreRaw =
     (neoFlowLongBias ? neoScoreFlowWeight : 0.0) +
     (neoCoreSlopeLongBias ? neoScoreCoreSlopeWeight : 0.0) +
     (neoCandleLongBias ? neoScoreHistWeight : 0.0)

neoShortContextScoreRaw =
     (neoFlowShortBias ? neoScoreFlowWeight : 0.0) +
     (neoCoreSlopeShortBias ? neoScoreCoreSlopeWeight : 0.0) +
     (neoCandleShortBias ? neoScoreHistWeight : 0.0)

neoLongContextScore =
     nz(ta.sma(neoLongContextScoreRaw, neoContextLookback)[1], 0.0)

neoShortContextScore =
     nz(ta.sma(neoShortContextScoreRaw, neoContextLookback)[1], 0.0)

neoContextBearishStrongFlow =
     nz(ta.highest(bearishStrongFlow ? 1.0 : 0.0, neoContextLookback)[1], 0.0) > 0.0

neoContextBullishStrongFlow =
     nz(ta.highest(bullishStrongFlow ? 1.0 : 0.0, neoContextLookback)[1], 0.0) > 0.0

//====================================================
// PLOTS
//====================================================

// 1) Neo Core
pNeoCore = plot(
     showNeoCore ? neoCore : na,
     "Neo Core",
     color=neoCoreColor,
     linewidth=2
)

// 2) Core Inner Bands
pNeoCoreUpperBand = plot(
     showNeoCore and showNeoCoreBand ? neoCoreUpperBand : na,
     "Core Upper Inner Band",
     color=color.new(neoWallUpColor, 0),
     linewidth=1
)

pNeoCoreLowerBand = plot(
     showNeoCore and showNeoCoreBand ? neoCoreLowerBand : na,
     "Core Lower Inner Band",
     color=color.new(neoWallDownColor, 0),
     linewidth=1
)

fill(
     pNeoCoreUpperBand,
     pNeoCoreLowerBand,
     color=showNeoCore and showNeoCoreBand ? color.new(color.gray, neoCoreBandFillTransp) : na,
     title="Core Inner Band Fill"
)

// 3) Neo Wall
pNeoWall = plot(
     showNeoWall ? neoWall : na,
     "Neo Wall",
     neoColor,
     neoWallWidth
)

pNeoWallShadow = plot(
     showNeoWallShadow ? neoWallShadowLine : na,
     "Defense Shadow",
     display=display.none,
     editable=false
)

fill(
     pNeoWall,
     pNeoWallShadow,
     showNeoWallShadow ? color.new(neoColor, neoShadowTrans) : na,
     title="Defense Shadow Fill",
     editable=false
)

// 4) Trend Guide + Boundaries
plot(
     showNeoTrendGuide and showNeoTrendGuideBounds ? neoTrendGuideUpperBoundary : na,
     "Trend Guide Upper Boundary",
     color=color.new(neoTrendGuideUpperColor, 55),
     linewidth=3
)

plot(
     showNeoTrendGuide ? neoTrendGuide : na,
     "Trend Guide",
     color=neoTrendGuidePlotColor,
     linewidth=2
)

plot(
     showNeoTrendGuide and showNeoTrendGuideBounds ? neoTrendGuideLowerBoundary : na,
     "Trend Guide Lower Boundary",
     color=color.new(neoTrendGuideLowerColor, 55),
     linewidth=3
)

// 5) Stretch Zones

neoCoreStretchUpperFadeOuter = plot(
     showNeoCoreStretchZones ? neoCoreUpperStretchFadeOuterLine : na,
     "Upper Stretch Halo Outer",
     color=color.new(color.black, 100),
     editable=false
)

neoCoreStretchUpperOuter = plot(
     showNeoCoreStretchZones ? neoCoreUpperStretchOuterLine : na,
     "Upper Stretch Zone Outer",
     color=color.new(color.black, 100),
     editable=false
)

neoCoreStretchUpperInner = plot(
     showNeoCoreStretchZones ? neoCoreUpperStretchInnerLine : na,
     "Upper Stretch Zone Inner",
     color=color.new(color.black, 100),
     editable=false
)

neoCoreStretchLowerInner = plot(
     showNeoCoreStretchZones ? neoCoreLowerStretchInnerLine : na,
     "Lower Stretch Zone Inner",
     color=color.new(color.black, 100),
     editable=false
)

neoCoreStretchLowerOuter = plot(
     showNeoCoreStretchZones ? neoCoreLowerStretchOuterLine : na,
     "Lower Stretch Zone Outer",
     color=color.new(color.black, 100),
     editable=false
)

neoCoreStretchLowerFadeOuter = plot(
     showNeoCoreStretchZones ? neoCoreLowerStretchFadeOuterLine : na,
     "Lower Stretch Halo Outer",
     color=color.new(color.black, 100),
     editable=false
)

// Stretch Halo - upper
fill(
     neoCoreStretchUpperFadeOuter,
     neoCoreStretchUpperOuter,
     color=showNeoCoreStretchZones ? color.new(neoWallDownColor, neoCoreStretchFadeFillTransp) : na,
     title="Upper Stretch Halo",
     editable=false
)

// Stretch Zone - upper
fill(
     neoCoreStretchUpperOuter,
     neoCoreStretchUpperInner,
     color=showNeoCoreStretchZones ? color.new(neoWallDownColor, neoCoreStretchFillTransp) : na,
     title="Upper Stretch Zone",
     editable=false
)

// Stretch Zone - lower
fill(
     neoCoreStretchLowerInner,
     neoCoreStretchLowerOuter,
     color=showNeoCoreStretchZones ? color.new(neoWallUpColor, neoCoreStretchFillTransp) : na,
     title="Lower Stretch Zone",
     editable=false
)

// Stretch Halo - lower
fill(
     neoCoreStretchLowerOuter,
     neoCoreStretchLowerFadeOuter,
     color=showNeoCoreStretchZones ? color.new(neoWallUpColor, neoCoreStretchFadeFillTransp) : na,
     title="Lower Stretch Halo",
     editable=false
)

// Candle coloring
barcolor(showNeoBarColor ? neoCandleBody : na)

//====================================================
// NEO MATRIX STATE DASHBOARD
//====================================================
neoDashTitleColor =
     color.rgb(112, 78, 238)

neoDashBg =
     color.rgb(0, 0, 0)

neoDashClearBg =
     color.new(color.black, 100)

neoDashLabelColor =
     color.new(color.white, 35)

//----------------------------------------------------
// Dashboard helpers
//----------------------------------------------------
f_dash_color(_code) =>
    _code > 0 ? neoWallUpColor : _code < 0 ? neoWallDownColor : color.white

f_clean_symbol(_symbol) =>
    string s = _symbol
    s := str.replace_all(s, "BINANCE:", "")
    s := str.replace_all(s, "BYBIT:", "")
    s := str.replace_all(s, "OKX:", "")
    s := str.replace_all(s, "COINBASE:", "")
    s := str.replace_all(s, "KRAKEN:", "")
    s

f_tf_label(_tf) =>
    switch _tf
        "1"   => "1m"
        "3"   => "3m"
        "5"   => "5m"
        "15"  => "15m"
        "30"  => "30m"
        "45"  => "45m"
        "60"  => "1h"
        "120" => "2h"
        "180" => "3h"
        "240" => "4h"
        "360" => "6h"
        "480" => "8h"
        "720" => "12h"
        "D"   => "1D"
        "W"   => "1W"
        "M"   => "1M"
        => _tf

f_regime_text(_code) =>
    _code == 1 ? "BULLISH" : _code == -1 ? "BEARISH" : "GLITCH"

f_flow_text(_code) =>
    _code == 2 ? "BULL+" : _code == 1 ? "BULL" : _code == -1 ? "BEAR" : _code == -2 ? "BEAR+" : "NEUTRAL"

f_watch_text(_code) =>
    _code == 1 ? "LONG WATCH" : _code == -1 ? "SHORT WATCH" : "WAIT"

//----------------------------------------------------
// Current dashboard states
//----------------------------------------------------
neoDashRegimeCode =
     neoDir == 1 and neoTrendGuideColorDir == 1 ? 1 :
     neoDir == -1 and neoTrendGuideColorDir == -1 ? -1 :
     0

neoDashFlowCode =
     bullishStrongFlow ? 2 :
     bearishStrongFlow ? -2 :
     neoFlowValue > 0 and not na(neoFlowPosAvg) and neoFlowValue >= neoFlowPosAvg ? 1 :
     neoFlowValue < 0 and not na(neoFlowNegAvg) and neoFlowValue <= neoFlowNegAvg ? -1 :
     0

neoDashLongWatchScore =
     neoLongContextScore + (neoLowerStretchZoneTouch ? neoScoreStretchWeight : 0.0)

neoDashShortWatchScore =
     neoShortContextScore + (neoUpperStretchZoneTouch ? neoScoreStretchWeight : 0.0)

neoDashLongWatchAllowed =
     not neoContextBearishStrongFlow and
     not neoUpperStretchZoneTouch

neoDashShortWatchAllowed =
     not neoContextBullishStrongFlow and
     not neoLowerStretchZoneTouch

neoDashWatchCode =
     not neoSetupTouch ? 0 :
     neoDashLongWatchAllowed and not neoDashShortWatchAllowed ? 1 :
     neoDashShortWatchAllowed and not neoDashLongWatchAllowed ? -1 :
     neoDashLongWatchAllowed and neoDashShortWatchAllowed and neoDashLongWatchScore > neoDashShortWatchScore ? 1 :
     neoDashLongWatchAllowed and neoDashShortWatchAllowed and neoDashShortWatchScore > neoDashLongWatchScore ? -1 :
     0

//----------------------------------------------------
// Compare dashboard state function
//----------------------------------------------------
f_neo_dashboard_states() =>
    // ----------------------------
    // Core / Stretch
    // ----------------------------
    dNeoCore =
         supersmoother(hlc3, neoCoreLen)

    dNeoCoreAdaptLen =
         math.max(20, int(neoCoreLen * 0.5))

    dNeoCoreStdevRaw =
         ta.stdev(hlc3, dNeoCoreAdaptLen)

    dNeoCoreStdevBase =
         ta.ema(dNeoCoreStdevRaw, neoCoreLen)

    dNeoCoreStdRatioRaw =
         dNeoCoreStdevBase != 0.0 ? dNeoCoreStdevRaw / dNeoCoreStdevBase : 1.0

    dNeoCoreStdRatio =
         ta.ema(dNeoCoreStdRatioRaw, 10)

    dNeoCoreRawAdaptive =
         1.0 + (dNeoCoreStdRatio - 1.0) * 0.25

    dNeoCoreAdaptiveFactor =
         math.max(0.92, math.min(dNeoCoreRawAdaptive, 1.10))

    dNeoCoreStretchRawRange =
         supersmoother(ta.tr, neoCoreStretchRangeLen)

    dNeoCoreStretchBase =
         dNeoCoreStretchRawRange * PI * neoCoreStretchBaseMult * dNeoCoreAdaptiveFactor

    dNeoCoreUpperStretchInnerLine =
         dNeoCore + dNeoCoreStretchBase

    dNeoCoreLowerStretchInnerLine =
         dNeoCore - dNeoCoreStretchBase

    dNeoUpperStretchZoneTouch =
         high >= dNeoCoreUpperStretchInnerLine

    dNeoLowerStretchZoneTouch =
         low <= dNeoCoreLowerStretchInnerLine

    dNeoStretchZoneTouch =
         dNeoUpperStretchZoneTouch or dNeoLowerStretchZoneTouch

    // ----------------------------
    // Core slope
    // ----------------------------
    dNeoCoreSlope =
         dNeoCore - dNeoCore[neoCoreSlopeLookback]

    dNeoCoreSlopeRangeHigh =
         ta.highest(dNeoCoreSlope, neoCoreSlopeFibLookback)

    dNeoCoreSlopeRangeLow =
         ta.lowest(dNeoCoreSlope, neoCoreSlopeFibLookback)

    dNeoCoreSlopeRange =
         dNeoCoreSlopeRangeHigh - dNeoCoreSlopeRangeLow

    dNeoCoreSlopeMoveThreshold =
         not na(dNeoCoreSlopeRange) and dNeoCoreSlopeRange > eps ? dNeoCoreSlopeRange * neoCoreSlopeFibRatio : na

    dNeoCoreSlopeLongBias =
         not na(dNeoCoreSlopeMoveThreshold) and
         dNeoCoreSlope > dNeoCoreSlopeMoveThreshold

    dNeoCoreSlopeShortBias =
         not na(dNeoCoreSlopeMoveThreshold) and
         dNeoCoreSlope < -dNeoCoreSlopeMoveThreshold

    // ----------------------------
    // Flow / MFI
    // ----------------------------
    dNeoFlowValue =
         ta.sma(ta.mfi(hl2, neoFlowLen) - 50.0, neoFlowSmooth)

    var float[] dNeoFlowPosMemory = array.new_float()
    var float[] dNeoFlowNegMemory = array.new_float()

    if barstate.isconfirmed
        if dNeoFlowValue > 0
            array.unshift(dNeoFlowPosMemory, dNeoFlowValue)

            if array.size(dNeoFlowPosMemory) > neoFlowMemory
                array.pop(dNeoFlowPosMemory)

            if array.size(dNeoFlowNegMemory) > 1
                array.pop(dNeoFlowNegMemory)

        else if dNeoFlowValue < 0
            array.unshift(dNeoFlowNegMemory, dNeoFlowValue)

            if array.size(dNeoFlowNegMemory) > neoFlowMemory
                array.pop(dNeoFlowNegMemory)

            if array.size(dNeoFlowPosMemory) > 1
                array.pop(dNeoFlowPosMemory)

    dNeoFlowPosAvg =
         f_array_avg(dNeoFlowPosMemory)

    dNeoFlowNegAvg =
         f_array_avg(dNeoFlowNegMemory)

    dNeoFlowBullStrongThreshold =
         not na(dNeoFlowPosAvg) ? math.max(dNeoFlowPosAvg, neoFlowStrongOffset) : na

    dNeoFlowBearStrongThreshold =
         not na(dNeoFlowNegAvg) ? math.min(dNeoFlowNegAvg, -neoFlowStrongOffset) : na

    dNeoFlowBullStrongZone =
         not na(dNeoFlowBullStrongThreshold) ? math.max(dNeoFlowValue - dNeoFlowBullStrongThreshold, 0.0) : na

    dNeoFlowBearStrongZone =
         not na(dNeoFlowBearStrongThreshold) ? math.min(dNeoFlowValue - dNeoFlowBearStrongThreshold, 0.0) : na

    dBullishStrongFlow =
         not na(dNeoFlowBullStrongZone) and dNeoFlowBullStrongZone > 0

    dBearishStrongFlow =
         not na(dNeoFlowBearStrongZone) and dNeoFlowBearStrongZone < 0

    dNeoFlowDeltaFromPast =
         dNeoFlowValue - dNeoFlowValue[neoFlowDirectionLookback]

    dNeoFlowRangeHigh =
         ta.highest(dNeoFlowValue, neoFlowFibLookback)

    dNeoFlowRangeLow =
         ta.lowest(dNeoFlowValue, neoFlowFibLookback)

    dNeoFlowRange =
         dNeoFlowRangeHigh - dNeoFlowRangeLow

    dNeoFlowMoveThreshold =
         not na(dNeoFlowRange) and dNeoFlowRange > eps ? dNeoFlowRange * neoFlowFibRatio : na

    dNeoFlowLongBias =
         (
             not na(dNeoFlowDeltaFromPast) and
             not na(dNeoFlowMoveThreshold) and
             dNeoFlowDeltaFromPast > dNeoFlowMoveThreshold
         ) or
         (dNeoFlowValue > 0 and dNeoFlowValue > nz(dNeoFlowValue[1]))

    dNeoFlowShortBias =
         (
             not na(dNeoFlowDeltaFromPast) and
             not na(dNeoFlowMoveThreshold) and
             dNeoFlowDeltaFromPast < -dNeoFlowMoveThreshold
         ) or
         (dNeoFlowValue < 0 and dNeoFlowValue < nz(dNeoFlowValue[1]))

    dFlowCode =
         dBullishStrongFlow ? 2 :
         dBearishStrongFlow ? -2 :
         dNeoFlowValue > 0 and not na(dNeoFlowPosAvg) and dNeoFlowValue >= dNeoFlowPosAvg ? 1 :
         dNeoFlowValue < 0 and not na(dNeoFlowNegAvg) and dNeoFlowValue <= dNeoFlowNegAvg ? -1 :
         0

    // ----------------------------
    // Neo Wall
    // ----------------------------
    dNeoWallLen = switch neoWallMode
        "Early"    => 13
        "Standard" => 21
        => 55

    dNeoWallMult = switch neoWallMode
        "Early"    => 3.618
        "Standard" => 4.236
        => 5.236

    dNeoWallSmooth = switch neoWallMode
        "Early"    => 8
        "Standard" => 13
        => 34

    dNeoWallConfirmCloses = 2

    dNeoWallSmoothedSrc =
         supersmoother(close, dNeoWallSmooth)

    dNeoWallAtrValue =
         ta.atr(dNeoWallLen)

    var float dNeoWall = 0.0
    var int dNeoDir = 1

    var int dNeoBelowCloseCount = 0
    var int dNeoAboveCloseCount = 0

    dNeoUpper =
         dNeoWallSmoothedSrc + dNeoWallMult * dNeoWallAtrValue

    dNeoLower =
         dNeoWallSmoothedSrc - dNeoWallMult * dNeoWallAtrValue

    dNeoWall :=
         dNeoDir == 1
         ? math.max(dNeoLower, nz(dNeoWall[1], dNeoLower))
         : math.min(dNeoUpper, nz(dNeoWall[1], dNeoUpper))

    if barstate.isconfirmed
        if dNeoDir == 1
            dNeoBelowCloseCount := close < dNeoWall ? nz(dNeoBelowCloseCount[1]) + 1 : 0
            dNeoAboveCloseCount := 0

            if dNeoBelowCloseCount >= dNeoWallConfirmCloses
                dNeoDir := -1
                dNeoWall := dNeoUpper
                dNeoBelowCloseCount := 0
                dNeoAboveCloseCount := 0

        else
            dNeoAboveCloseCount := close > dNeoWall ? nz(dNeoAboveCloseCount[1]) + 1 : 0
            dNeoBelowCloseCount := 0

            if dNeoAboveCloseCount >= dNeoWallConfirmCloses
                dNeoDir := 1
                dNeoWall := dNeoLower
                dNeoBelowCloseCount := 0
                dNeoAboveCloseCount := 0

    // ----------------------------
    // Trend Guide
    // ----------------------------
    dNeoTrendGuideLen = switch neoTrendGuideMode
        "Early"    => 89
        "Standard" => 120
        => 144

    dNeoTrendGuideMult = switch neoTrendGuideMode
        "Early"    => 1.618
        "Standard" => 2.618
        => 4.236

    dNeoTrendGuideSrc =
         hlc3

    [dNeoTrendGuide, dNeoTrendGuideUpperBoundary, dNeoTrendGuideLowerBoundary] =
         f_neo_trend_guide_held_confirmed(
             dNeoTrendGuideSrc,
             dNeoTrendGuideLen,
             dNeoTrendGuideMult
         )

    dNeoTrendGuideRawDir =
         dNeoTrendGuide > nz(dNeoTrendGuide[1], dNeoTrendGuide) ? 1 :
         dNeoTrendGuide < nz(dNeoTrendGuide[1], dNeoTrendGuide) ? -1 :
         0

    var int dNeoTrendGuideColorDir = 1

    if dNeoTrendGuideRawDir == 1
        dNeoTrendGuideColorDir := 1
    else if dNeoTrendGuideRawDir == -1
        dNeoTrendGuideColorDir := -1
    else
        dNeoTrendGuideColorDir := nz(dNeoTrendGuideColorDir[1], 1)

    dRegimeCode =
         dNeoDir == 1 and dNeoTrendGuideColorDir == 1 ? 1 :
         dNeoDir == -1 and dNeoTrendGuideColorDir == -1 ? -1 :
         0

    // ----------------------------
    // Structure / setup
    // ----------------------------
    dNeoWallShadowLine =
         dNeoWall + (dNeoDir == 1 ? neoShadowMult * dNeoWallAtrValue : -neoShadowMult * dNeoWallAtrValue)

    dPrevNeoDir =
         nz(dNeoDir[1], dNeoDir)

    dPrevNeoWall =
         nz(dNeoWall[1], dNeoWall)

    dPrevNeoAtr =
         nz(dNeoWallAtrValue[1], dNeoWallAtrValue)

    dPrevNeoWallShadowLine =
         dPrevNeoWall + (dPrevNeoDir == 1 ? neoShadowMult * dPrevNeoAtr : -neoShadowMult * dPrevNeoAtr)

    dNeoBufferTouchPrevRegime =
         dPrevNeoDir == 1  ? low <= dPrevNeoWallShadowLine :
         dPrevNeoDir == -1 ? high >= dPrevNeoWallShadowLine :
         false

    dNeoLineTouchOrBreakPrevRegime =
         dPrevNeoDir == 1  ? low <= dPrevNeoWall :
         dPrevNeoDir == -1 ? high >= dPrevNeoWall :
         false

    dNeoWallSetupTouch =
         dNeoBufferTouchPrevRegime or dNeoLineTouchOrBreakPrevRegime

    dNeoSetupTouch =
         dNeoWallSetupTouch or dNeoStretchZoneTouch

    // ----------------------------
    // Candle momentum / histogram
    // ----------------------------
    dNeoMacdFastLen = switch neoCandleColorMode
        "Early"    => 13
        "Standard" => 7
        => 13

    dNeoMacdSlowLen = switch neoCandleColorMode
        "Early"    => 21
        "Standard" => 12
        => 21

    dNeoMacdSignalLen = switch neoCandleColorMode
        "Early"    => 8
        "Standard" => 5
        => 8

    dNeoCandleMacdSource =
         neoCandleColorMode == "Early" ? hlc3 : dNeoCore

    [dNeoMacdVal, dNeoMacdSignal, dNeoMacdHist] =
         ta.macd(dNeoCandleMacdSource, dNeoMacdFastLen, dNeoMacdSlowLen, dNeoMacdSignalLen)

    dNeoHistRangeHigh =
         ta.highest(dNeoMacdHist, histFibLookback)

    dNeoHistRangeLow =
         ta.lowest(dNeoMacdHist, histFibLookback)

    dNeoHistRange =
         dNeoHistRangeHigh - dNeoHistRangeLow

    dNeoHistMoveThreshold =
         not na(dNeoHistRange) and dNeoHistRange > eps ? dNeoHistRange * histFibRatio : na

    dNeoHistAbsNow =
         math.abs(dNeoMacdHist)

    dNeoHistAbsPast =
         math.abs(dNeoMacdHist[histDirectionLookback])

    dNeoHistAbsMove =
         dNeoHistAbsNow - dNeoHistAbsPast

    dNeoHistPowerGrowing =
         not na(dNeoHistAbsMove) and
         not na(dNeoHistMoveThreshold) and
         dNeoHistAbsMove > dNeoHistMoveThreshold

    dNeoHistPowerShrinking =
         not na(dNeoHistAbsMove) and
         not na(dNeoHistMoveThreshold) and
         dNeoHistAbsMove < -dNeoHistMoveThreshold

    dNeoCandleLongBias =
         (dNeoMacdHist > 0 and dNeoHistPowerGrowing) or
         (dNeoMacdHist < 0 and dNeoHistPowerShrinking)

    dNeoCandleShortBias =
         (dNeoMacdHist < 0 and dNeoHistPowerGrowing) or
         (dNeoMacdHist > 0 and dNeoHistPowerShrinking)

    // ----------------------------
    // Context scores
    // ----------------------------
    dNeoLongContextScoreRaw =
         (dNeoFlowLongBias ? neoScoreFlowWeight : 0.0) +
         (dNeoCoreSlopeLongBias ? neoScoreCoreSlopeWeight : 0.0) +
         (dNeoCandleLongBias ? neoScoreHistWeight : 0.0)

    dNeoShortContextScoreRaw =
         (dNeoFlowShortBias ? neoScoreFlowWeight : 0.0) +
         (dNeoCoreSlopeShortBias ? neoScoreCoreSlopeWeight : 0.0) +
         (dNeoCandleShortBias ? neoScoreHistWeight : 0.0)

    dNeoLongContextScore =
         nz(ta.sma(dNeoLongContextScoreRaw, neoContextLookback)[1], 0.0)

    dNeoShortContextScore =
         nz(ta.sma(dNeoShortContextScoreRaw, neoContextLookback)[1], 0.0)

    dNeoContextBearishStrongFlow =
         nz(ta.highest(dBearishStrongFlow ? 1.0 : 0.0, neoContextLookback)[1], 0.0) > 0.0

    dNeoContextBullishStrongFlow =
         nz(ta.highest(dBullishStrongFlow ? 1.0 : 0.0, neoContextLookback)[1], 0.0) > 0.0

    dLongWatchScore =
         dNeoLongContextScore + (dNeoLowerStretchZoneTouch ? neoScoreStretchWeight : 0.0)

    dShortWatchScore =
         dNeoShortContextScore + (dNeoUpperStretchZoneTouch ? neoScoreStretchWeight : 0.0)

    dLongWatchAllowed =
         not dNeoContextBearishStrongFlow and
         not dNeoUpperStretchZoneTouch

    dShortWatchAllowed =
         not dNeoContextBullishStrongFlow and
         not dNeoLowerStretchZoneTouch

    dWatchCode =
         not dNeoSetupTouch ? 0 :
         dLongWatchAllowed and not dShortWatchAllowed ? 1 :
         dShortWatchAllowed and not dLongWatchAllowed ? -1 :
         dLongWatchAllowed and dShortWatchAllowed and dLongWatchScore > dShortWatchScore ? 1 :
         dLongWatchAllowed and dShortWatchAllowed and dShortWatchScore > dLongWatchScore ? -1 :
         0

    [dRegimeCode, dFlowCode, dWatchCode]

//----------------------------------------------------
// Compare states
//----------------------------------------------------
[neoCompareRegimeCode, neoCompareFlowCode, neoCompareWatchCode] =
     request.security(
         neoCompareSymbol,
         neoCompareTimeframe,
         f_neo_dashboard_states(),
         barmerge.gaps_off,
         barmerge.lookahead_off
     )

//----------------------------------------------------
// Dashboard table
//----------------------------------------------------
neoDashboardPosition =
     neoDashboardSide == "Right" ? position.bottom_right : position.bottom_left

var table neoStateDash =
     table.new(
         neoDashboardPosition,
         5,
         6,
         bgcolor=neoDashClearBg,
         frame_color=neoDashClearBg,
         frame_width=0,
         border_color=neoDashClearBg,
         border_width=0
     )

var bool neoDashMerged = false

if not neoDashMerged
    table.merge_cells(neoStateDash, 0, 0, 1, 0)
    table.merge_cells(neoStateDash, 3, 0, 4, 0)
    neoDashMerged := true

neoCurrentPair =
     syminfo.ticker

neoCurrentTf =
     f_tf_label(timeframe.period)

neoComparePair =
     f_clean_symbol(neoCompareSymbol)

neoCompareTf =
     f_tf_label(neoCompareTimeframe)

//----------------------------------------------------
// Draw dashboard
//----------------------------------------------------
if barstate.islast
    table.cell(neoStateDash, 0, 0, "", bgcolor=neoDashClearBg)
    table.cell(neoStateDash, 2, 0, "", bgcolor=neoDashClearBg)
    table.cell(neoStateDash, 3, 0, "", bgcolor=neoDashClearBg)

    table.cell(neoStateDash, 0, 1, "", bgcolor=neoDashClearBg)
    table.cell(neoStateDash, 1, 1, "", bgcolor=neoDashClearBg)
    table.cell(neoStateDash, 2, 1, "", bgcolor=neoDashClearBg)
    table.cell(neoStateDash, 3, 1, "", bgcolor=neoDashClearBg)
    table.cell(neoStateDash, 4, 1, "", bgcolor=neoDashClearBg)

    table.cell(neoStateDash, 0, 2, "", bgcolor=neoDashClearBg)
    table.cell(neoStateDash, 1, 2, "", bgcolor=neoDashClearBg)
    table.cell(neoStateDash, 2, 2, "", bgcolor=neoDashClearBg)
    table.cell(neoStateDash, 3, 2, "", bgcolor=neoDashClearBg)
    table.cell(neoStateDash, 4, 2, "", bgcolor=neoDashClearBg)

    table.cell(neoStateDash, 0, 3, "", bgcolor=neoDashClearBg)
    table.cell(neoStateDash, 1, 3, "", bgcolor=neoDashClearBg)
    table.cell(neoStateDash, 2, 3, "", bgcolor=neoDashClearBg)
    table.cell(neoStateDash, 3, 3, "", bgcolor=neoDashClearBg)
    table.cell(neoStateDash, 4, 3, "", bgcolor=neoDashClearBg)

    table.cell(neoStateDash, 0, 4, "", bgcolor=neoDashClearBg)
    table.cell(neoStateDash, 1, 4, "", bgcolor=neoDashClearBg)
    table.cell(neoStateDash, 2, 4, "", bgcolor=neoDashClearBg)
    table.cell(neoStateDash, 3, 4, "", bgcolor=neoDashClearBg)
    table.cell(neoStateDash, 4, 4, "", bgcolor=neoDashClearBg)

    table.cell(neoStateDash, 0, 5, "", bgcolor=neoDashClearBg)
    table.cell(neoStateDash, 1, 5, "", bgcolor=neoDashClearBg)
    table.cell(neoStateDash, 2, 5, "", bgcolor=neoDashClearBg)
    table.cell(neoStateDash, 3, 5, "", bgcolor=neoDashClearBg)
    table.cell(neoStateDash, 4, 5, "", bgcolor=neoDashClearBg)

    if showNeoStateDashboard
        // ----------------------------
        // CURRENT PANEL
        // ----------------------------
        table.cell(
             neoStateDash,
             0,
             0,
             "_Neo Matrix_",
             text_color=neoDashTitleColor,
             bgcolor=neoDashBg,
             text_size=size.normal,
             text_halign=text.align_center
        )

        table.cell(neoStateDash, 0, 1, "PAIR", text_color=neoDashLabelColor, bgcolor=neoDashBg, text_size=size.small, text_halign=text.align_left)
        table.cell(neoStateDash, 1, 1, neoCurrentPair, text_color=color.white, bgcolor=neoDashBg, text_size=size.small, text_halign=text.align_right)

        table.cell(neoStateDash, 0, 2, "TIMEFRAME", text_color=neoDashLabelColor, bgcolor=neoDashBg, text_size=size.small, text_halign=text.align_left)
        table.cell(neoStateDash, 1, 2, neoCurrentTf, text_color=color.white, bgcolor=neoDashBg, text_size=size.small, text_halign=text.align_right)

        table.cell(neoStateDash, 0, 3, "REGIME", text_color=neoDashLabelColor, bgcolor=neoDashBg, text_size=size.small, text_halign=text.align_left)
        table.cell(neoStateDash, 1, 3, f_regime_text(neoDashRegimeCode), text_color=f_dash_color(neoDashRegimeCode), bgcolor=neoDashBg, text_size=size.small, text_halign=text.align_right)

        table.cell(neoStateDash, 0, 4, "FLOW", text_color=neoDashLabelColor, bgcolor=neoDashBg, text_size=size.small, text_halign=text.align_left)
        table.cell(neoStateDash, 1, 4, f_flow_text(neoDashFlowCode), text_color=f_dash_color(neoDashFlowCode), bgcolor=neoDashBg, text_size=size.small, text_halign=text.align_right)

        table.cell(neoStateDash, 0, 5, "WATCH", text_color=neoDashLabelColor, bgcolor=neoDashBg, text_size=size.small, text_halign=text.align_left)
        table.cell(neoStateDash, 1, 5, f_watch_text(neoDashWatchCode), text_color=f_dash_color(neoDashWatchCode), bgcolor=neoDashBg, text_size=size.small, text_halign=text.align_right)

        // Spacer column
        table.cell(neoStateDash, 2, 0, " ", bgcolor=neoDashClearBg)
        table.cell(neoStateDash, 2, 1, " ", bgcolor=neoDashClearBg)
        table.cell(neoStateDash, 2, 2, " ", bgcolor=neoDashClearBg)
        table.cell(neoStateDash, 2, 3, " ", bgcolor=neoDashClearBg)
        table.cell(neoStateDash, 2, 4, " ", bgcolor=neoDashClearBg)
        table.cell(neoStateDash, 2, 5, " ", bgcolor=neoDashClearBg)

        // ----------------------------
        // COMPARE PANEL
        // ----------------------------
        if showNeoCompareDashboard
            table.cell(
                 neoStateDash,
                 3,
                 0,
                 "_Neo Matrix_",
                 text_color=neoDashTitleColor,
                 bgcolor=neoDashBg,
                 text_size=size.normal,
                 text_halign=text.align_center
            )

            table.cell(neoStateDash, 3, 1, "PAIR", text_color=neoDashLabelColor, bgcolor=neoDashBg, text_size=size.small, text_halign=text.align_left)
            table.cell(neoStateDash, 4, 1, neoComparePair, text_color=color.white, bgcolor=neoDashBg, text_size=size.small, text_halign=text.align_right)

            table.cell(neoStateDash, 3, 2, "TIMEFRAME", text_color=neoDashLabelColor, bgcolor=neoDashBg, text_size=size.small, text_halign=text.align_left)
            table.cell(neoStateDash, 4, 2, neoCompareTf, text_color=color.white, bgcolor=neoDashBg, text_size=size.small, text_halign=text.align_right)

            table.cell(neoStateDash, 3, 3, "REGIME", text_color=neoDashLabelColor, bgcolor=neoDashBg, text_size=size.small, text_halign=text.align_left)
            table.cell(neoStateDash, 4, 3, f_regime_text(neoCompareRegimeCode), text_color=f_dash_color(neoCompareRegimeCode), bgcolor=neoDashBg, text_size=size.small, text_halign=text.align_right)

            table.cell(neoStateDash, 3, 4, "FLOW", text_color=neoDashLabelColor, bgcolor=neoDashBg, text_size=size.small, text_halign=text.align_left)
            table.cell(neoStateDash, 4, 4, f_flow_text(neoCompareFlowCode), text_color=f_dash_color(neoCompareFlowCode), bgcolor=neoDashBg, text_size=size.small, text_halign=text.align_right)

            table.cell(neoStateDash, 3, 5, "WATCH", text_color=neoDashLabelColor, bgcolor=neoDashBg, text_size=size.small, text_halign=text.align_left)
            table.cell(neoStateDash, 4, 5, f_watch_text(neoCompareWatchCode), text_color=f_dash_color(neoCompareWatchCode), bgcolor=neoDashBg, text_size=size.small, text_halign=text.align_right)
````
