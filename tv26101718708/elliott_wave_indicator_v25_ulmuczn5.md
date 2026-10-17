# Elliott Wave Indicator V2.5

- url: https://www.tradingview.com/script/uLmuczN5-Elliott-Wave-Indicator-V2-5/
- type: indicator
- pine_id: PUB;dcf3476f8be146b4a63e606a98c20a6f
- version: 1.0

## Description

// Elliott Wave Visualizer + Projection Zones
// Purpose: draw historical Elliott-style wave counts and forward projection path
// Pine Script v5, non-repainting confirmed pivot logic

## Source Code

````pine
// ============================================================
// ELLIOTT WAVE INDICATOR V2.5 - READABILITY UPGRADE
// Pine Script v6
// ============================================================
// V2.5 CHANGES:
//   - Display mode selector (Active / Completed / Both / Historical)
//   - Historical wave storage with configurable cap
//   - ATR-offset label placement for readability
//   - Larger dashboard with simplified rows
//   - Status line cleanup via display=display.none
//   - Per-direction toggles (Bull / Bear)
//   - Active structure cleanup before redraw
//   - All previous fixes preserved
// ============================================================

//@version=6
indicator(
     title            = "Elliott Wave Indicator V2.5",
     shorttitle       = "EW-V2.5",
     overlay          = true,
     max_lines_count  = 500,
     max_labels_count = 500,
     max_boxes_count  = 100
     )

// ============================================================
// SECTION 1: ASSET CLASS DETECTION
// ============================================================

assetClass = syminfo.type == "crypto"  ? "Crypto"  :
             syminfo.type == "stock"   ? "Equity"  :
             syminfo.type == "forex"   ? "Forex"   :
             syminfo.type == "index"   ? "Index"   :
             syminfo.type == "fund"    ? "Fund"    :
             syminfo.type == "futures" ? "Futures" :
             "Other"

adaptiveFibTolerance = assetClass == "Crypto" ? 0.08 :
                       assetClass == "Forex"  ? 0.04 : 0.05

adaptiveADX = assetClass == "Crypto"  ? 20.0 :
              assetClass == "Forex"   ? 18.0 :
              assetClass == "Equity"  ? 25.0 :
              assetClass == "Index"   ? 25.0 :
              assetClass == "Fund"    ? 25.0 :
              assetClass == "Futures" ? 22.0 : 22.0

adaptiveVolFilter = assetClass != "Forex"

adaptiveMaxBarsPerWave = timeframe.period == "240" ? 80 :
                         timeframe.period == "D"   ? 80 :
                         timeframe.period == "W"   ? 40 :
                         timeframe.period == "M"   ? 36 : 80

// ============================================================
// SECTION 2: USER INPUTS
// ============================================================

grpAdaptive = "Adaptive Defaults"
i_useAdaptive        = input.bool(true, "Use Adaptive Defaults", group=grpAdaptive)
i_useAdaptiveTimeout = input.bool(true, "Use Adaptive Max Bars Per Wave", group=grpAdaptive)

grpPivot = "Pivot Detection"
i_manualPivotDepth = input.int(5,   "Pivot Depth (7=crypto, 3=forex)", minval=2, maxval=20, group=grpPivot)
i_pivotDeviation   = input.float(5.0, "Deviation (%)", minval=0.1, maxval=20, step=0.1, group=grpPivot)

grpEW = "Elliott Wave Rules"
i_manualFibTolerance   = input.float(0.05, "Fibonacci Tolerance", minval=0.01, maxval=0.2, step=0.01, group=grpEW)
i_allowExtension       = input.bool(true,  "Allow Wave 5 Extension (up to 3x W3)", group=grpEW)
i_showABC              = input.bool(true,  "Detect ABC Corrections", group=grpEW)
i_manualMaxBarsPerWave = input.int(80, "Manual Max Bars Per Wave", minval=10, maxval=500, group=grpEW)
i_maxBarsABC           = input.int(80, "Max Bars for ABC Correction", minval=10, maxval=500, group=grpEW)

grpConf = "Confidence Thresholds"
i_confW2         = input.int(50, "Min Confidence W2 Entry",       minval=0, maxval=100, group=grpConf)
i_confW4         = input.int(55, "Min Confidence W4 Entry",       minval=0, maxval=100, group=grpConf)
i_confW5         = input.int(60, "Min Confidence W5 Completion",  minval=0, maxval=100, group=grpConf)
i_useDynamicConf = input.bool(true, "Volatility-Adjusted Thresholds", group=grpConf)

grpScore = "Score Weights"
i_fibWeight   = input.float(0.50, "Fibonacci Weight",     minval=0.0, maxval=1.0, step=0.05, group=grpScore)
i_ratioWeight = input.float(0.30, "Wave Ratio Weight",    minval=0.0, maxval=1.0, step=0.05, group=grpScore)
i_timeWeight  = input.float(0.20, "Time Symmetry Weight", minval=0.0, maxval=1.0, step=0.05, group=grpScore)

grpRegime = "Regime Filter"
i_useRegime          = input.bool(true,  "Enable Regime Filter",        group=grpRegime)
i_emaFast            = input.int(50,     "EMA Fast",  minval=10, maxval=200, group=grpRegime)
i_emaSlow            = input.int(200,    "EMA Slow",  minval=50, maxval=500, group=grpRegime)
i_adxLength          = input.int(14,     "ADX Length", minval=5, maxval=50, group=grpRegime)
i_manualADXThreshold = input.float(25.0, "ADX Threshold (manual)", minval=10, maxval=50, step=1, group=grpRegime)

grpMTF = "Multi-Timeframe"
i_useMTF = input.bool(true, "Enable MTF Confirmation", group=grpMTF)

grpVol = "Volume Filter"
i_useManualVolume    = input.bool(true,   "Volume Confirmation at W3", group=grpVol)
i_volMultiplier      = input.float(1.5,   "Volume Spike Multiplier", minval=1.0, maxval=5.0, step=0.1, group=grpVol)
i_useManualLiquidity = input.bool(true,   "Liquidity Filter",         group=grpVol)
i_minAvgVol          = input.int(100000,  "Minimum Average Volume",   minval=0, group=grpVol)

grpRSI = "RSI Divergence"
i_useRSI    = input.bool(true, "RSI Divergence at W5", group=grpRSI)
i_rsiLength = input.int(14,   "RSI Length", minval=5, maxval=50, group=grpRSI)

grpMode = "Signal Direction"
i_signalMode   = input.string("Both", "Signal Direction", options=["Both", "Long Only", "Short Only"], group=grpMode)
i_enableShorts = input.bool(true, "Enable Shorts (master)", group=grpMode)

grpSig = "Signal Settings"
i_cooldownBars = input.int(10,  "Cooldown Bars", minval=0, maxval=200, group=grpSig)
i_wave4entry   = input.bool(true, "Allow Wave 4 Entry", group=grpSig)

// V2.5: Display mode controls
grpDisplay = "Display Mode"
i_displayMode = input.string("Active Only", "Wave Display Mode",
     options=["Active Only", "Completed Only", "Active + Completed", "Historical"],
     group=grpDisplay)
i_maxHistoricalCycles = input.int(2, "Max Historical Cycles", minval=1, maxval=10, group=grpDisplay)
i_showBull        = input.bool(true,  "Show Bull Waves",        group=grpDisplay)
i_showBear        = input.bool(true,  "Show Bear Waves",        group=grpDisplay)
i_showProjection  = input.bool(true,  "Show Projection",        group=grpDisplay)
i_showABCZones    = input.bool(true,  "Show ABC Projection Zones", group=grpDisplay)
i_showGuideLine   = input.bool(false, "Show Projection Guide Line", group=grpDisplay)
i_showDashboard   = input.bool(true,  "Show Dashboard",         group=grpDisplay)
i_showSignals     = input.bool(true,  "Show Buy/Sell Signals",  group=grpDisplay)

grpViz = "Label Styling"
i_showLabels      = input.bool(true,  "Show Wave Labels",                group=grpViz)
i_showConfidence  = input.bool(true,  "Show Confidence Score on Labels", group=grpViz)
i_labelOffsetATR  = input.float(0.5,  "Label Offset (x ATR)", minval=0.1, maxval=3.0, step=0.1, group=grpViz)

// ============================================================
// SECTION 3: EFFECTIVE PARAMETERS
// ============================================================

pivotDepth        = i_manualPivotDepth
effFibTolerance   = i_useAdaptive ? adaptiveFibTolerance : i_manualFibTolerance
effADXThreshold   = i_useAdaptive ? adaptiveADX          : i_manualADXThreshold
effUseVolume      = i_useAdaptive ? adaptiveVolFilter     : i_useManualVolume
effUseLiquidity   = i_useAdaptive ? adaptiveVolFilter     : i_useManualLiquidity
effMaxBarsPerWave = i_useAdaptiveTimeout ? adaptiveMaxBarsPerWave : i_manualMaxBarsPerWave

// V2.5: Resolve display flags from mode selector
bool showActiveBull    = (i_displayMode == "Active Only" or i_displayMode == "Active + Completed") and i_showBull
bool showActiveBear    = (i_displayMode == "Active Only" or i_displayMode == "Active + Completed") and i_showBear
bool showCompletedBull = (i_displayMode == "Completed Only" or i_displayMode == "Active + Completed") and i_showBull
bool showCompletedBear = (i_displayMode == "Completed Only" or i_displayMode == "Active + Completed") and i_showBear
bool showHistoricalBull = i_displayMode == "Historical" and i_showBull
bool showHistoricalBear = i_displayMode == "Historical" and i_showBear

// ============================================================
// SECTION 4: WEIGHT NORMALIZATION
// ============================================================

totalWeight = i_fibWeight + i_ratioWeight + i_timeWeight
wFib   = totalWeight > 0 ? i_fibWeight   / totalWeight : 0.5
wRatio = totalWeight > 0 ? i_ratioWeight / totalWeight : 0.3
wTime  = totalWeight > 0 ? i_timeWeight  / totalWeight : 0.2

// ============================================================
// SECTION 5: MTF MAPPING
// ============================================================

higherTF = timeframe.period == "240" ? "D"  :
           timeframe.period == "D"   ? "W"  :
           timeframe.period == "W"   ? "M"  :
           timeframe.period == "M"   ? "3M" : ""

// ============================================================
// SECTION 6: VOLATILITY + ATR
// ============================================================

atrValue         = ta.atr(14)
volatilityFactor = atrValue / close
dynamicDeviation = i_pivotDeviation * (1 + volatilityFactor * 10)

// V2.5: Label offset distance based on ATR
labelOffset = atrValue * i_labelOffsetATR

// ============================================================
// SECTION 7: REGIME FILTER
// ============================================================

[diPlus, diMinus, adxValue] = ta.dmi(i_adxLength, i_adxLength)
emaFast        = ta.ema(close, i_emaFast)
emaSlow        = ta.ema(close, i_emaSlow)
isTrendingUp   = emaFast > emaSlow
isTrendingDown = emaFast < emaSlow
isStrongTrend  = adxValue > effADXThreshold
isChoppy = adxValue < (effADXThreshold * 0.8)

f_adxValue(len) =>
    [dPlus, dMinus, dmiAdx] = ta.dmi(len, len)
    dmiAdx

var bool mtfTrendUpRaw     = false
var bool mtfTrendDownRaw   = false
var bool mtfStrongTrendRaw = false

if i_useMTF and higherTF != ""
    mtfTrendUpRaw := request.security(syminfo.tickerid, higherTF,
         ta.ema(close, 20) > ta.ema(close, 50), lookahead=barmerge.lookahead_off)
    mtfTrendDownRaw := request.security(syminfo.tickerid, higherTF,
         ta.ema(close, 20) < ta.ema(close, 50), lookahead=barmerge.lookahead_off)
    mtfStrongTrendRaw := request.security(syminfo.tickerid, higherTF,
         f_adxValue(i_adxLength) > effADXThreshold, lookahead=barmerge.lookahead_off)

bool mtfTrendUp   = (i_useMTF and higherTF != "") ? (mtfTrendUpRaw   and mtfStrongTrendRaw) : isTrendingUp
bool mtfTrendDown = (i_useMTF and higherTF != "") ? (mtfTrendDownRaw and mtfStrongTrendRaw) : isTrendingDown

isValidBullRegime = i_useRegime ? (isTrendingUp   and isStrongTrend and mtfTrendUp)   : true
isValidBearRegime = i_useRegime ? (isTrendingDown and isStrongTrend and mtfTrendDown) : true

// ============================================================
// SECTION 8: VOLUME + LIQUIDITY
// ============================================================

avgVolume     = ta.sma(volume, 20)
isLiquid      = effUseLiquidity ? avgVolume > i_minAvgVol : true
isVolumeSpike = effUseVolume    ? volume > avgVolume * i_volMultiplier : true

// ============================================================
// SECTION 9: RSI
// ============================================================

rsiValue = ta.rsi(close, i_rsiLength)
rsiSafePivot = bar_index > pivotDepth ? rsiValue[pivotDepth] : na

// ============================================================
// SECTION 10: DYNAMIC CONFIDENCE THRESHOLDS
// ============================================================

f_dynamicThreshold(baseThreshold, vf) =>
    float baseFloat = float(baseThreshold)
    float result    = baseFloat
    if i_useDynamicConf
        float adj = math.min(15.0, vf * 200)
        result := math.min(95.0, baseFloat + adj)
    result

dynConfW2 = f_dynamicThreshold(i_confW2, volatilityFactor)
dynConfW4 = f_dynamicThreshold(i_confW4, volatilityFactor)
dynConfW5 = f_dynamicThreshold(i_confW5, volatilityFactor)

// ============================================================
// SECTION 11: WARMUP
// ============================================================

minBarsRequired = math.max(i_emaSlow, 100)
isWarmedUp      = bar_index >= minBarsRequired

// ============================================================
// SECTION 12: TIME HELPER
// ============================================================

f_barTime(pivotBar) =>
    barsAgo = bar_index - pivotBar
    int result = int(time)
    if barsAgo >= 0 and barsAgo < 5000
        result := int(time[barsAgo])
    result

// ============================================================
// SECTION 13: RAW PIVOT DETECTION
// ============================================================

phRaw = ta.pivothigh(high, pivotDepth, pivotDepth)
plRaw = ta.pivotlow(low,   pivotDepth, pivotDepth)

// ============================================================
// SECTION 14: ZIGZAG WITH ALTERNATION
// ============================================================

var array<float> zzPrices = array.new<float>(0)
var array<int>   zzBars   = array.new<int>(0)
var array<int>   zzTypes  = array.new<int>(0)

f_pushZigzag(price, bar, ptype) =>
    bool didUpdate = false
    int sz = array.size(zzPrices)
    if sz == 0
        array.push(zzPrices, price)
        array.push(zzBars, bar)
        array.push(zzTypes, ptype)
        didUpdate := true
    else
        int   lastType  = array.get(zzTypes,  sz - 1)
        float lastPrice = array.get(zzPrices, sz - 1)
        if ptype == lastType
            bool shouldReplace = false
            if ptype == 1  and price > lastPrice
                shouldReplace := true
            if ptype == -1 and price < lastPrice
                shouldReplace := true
            if shouldReplace
                array.set(zzPrices, sz - 1, price)
                array.set(zzBars,   sz - 1, bar)
                didUpdate := true
        else
            float deviation = 0.0
            if lastPrice != 0.0
                deviation := math.abs(price - lastPrice) / lastPrice * 100.0
            if deviation >= dynamicDeviation
                array.push(zzPrices, price)
                array.push(zzBars, bar)
                array.push(zzTypes, ptype)
                didUpdate := true
                if array.size(zzPrices) > 50
                    array.shift(zzPrices)
                    array.shift(zzBars)
                    array.shift(zzTypes)
    didUpdate

bool hasHigh = not na(phRaw)
bool hasLow  = not na(plRaw)

if hasHigh and hasLow
    int sz = array.size(zzPrices)
    if sz > 0
        float lastZZ  = array.get(zzPrices, sz - 1)
        float distH   = math.abs(phRaw - lastZZ)
        float distL   = math.abs(plRaw  - lastZZ)
        if distH >= distL
            bool d1 = f_pushZigzag(phRaw, bar_index - pivotDepth, 1)
        else
            bool d2 = f_pushZigzag(plRaw, bar_index - pivotDepth, -1)
    else
        bool d3 = f_pushZigzag(phRaw, bar_index - pivotDepth, 1)
else if hasHigh
    bool d4 = f_pushZigzag(phRaw, bar_index - pivotDepth, 1)
else if hasLow
    bool d5 = f_pushZigzag(plRaw, bar_index - pivotDepth, -1)

// ============================================================
// SECTION 15: FIBONACCI HELPERS
// ============================================================

f_fibRetracement(startPrice, endPrice, retracementPrice) =>
    float moveSize = math.abs(endPrice - startPrice)
    float result   = 0.0
    if moveSize != 0.0
        result := math.abs(retracementPrice - endPrice) / moveSize
    result

f_nearFib(value, target, tolerance) =>
    math.abs(value - target) <= tolerance

// ============================================================
// SECTION 16: PARTIAL SCORERS
// ============================================================

f_scoreWave2Partial(p0, p1, p2, tolerance) =>
    float retrace = f_fibRetracement(p0, p1, p2)
    float score   = 0.0
    if f_nearFib(retrace, 0.618, tolerance)
        score := 100.0
    else if f_nearFib(retrace, 0.500, tolerance)
        score := 85.0
    else if f_nearFib(retrace, 0.786, tolerance)
        score := 75.0
    else if f_nearFib(retrace, 0.382, tolerance)
        score := 60.0
    else if retrace >= 0.236 and retrace <= 0.886
        score := 40.0
    math.min(100.0, math.max(0.0, score))

f_scoreWave4Partial(p0, p1, p2, p3, p4, tolerance, volScore) =>
    float w1size = math.abs(p1 - p0)
    float w3size = math.abs(p3 - p2)
    float w3ratio = 0.0
    if w1size > 0.0
        w3ratio := w3size / w1size
    float w3str = 0.0
    if f_nearFib(w3ratio, 1.618, tolerance)
        w3str := 100.0
    else if f_nearFib(w3ratio, 2.618, tolerance)
        w3str := 85.0
    else if w3ratio >= 1.0 and w3ratio <= 4.236
        w3str := 60.0
    else if w3ratio >= 0.9
        w3str := 30.0
    float w4ret = f_fibRetracement(p2, p3, p4)
    float w4fib = 0.0
    if f_nearFib(w4ret, 0.382, tolerance)
        w4fib := 100.0
    else if f_nearFib(w4ret, 0.236, tolerance)
        w4fib := 85.0
    else if f_nearFib(w4ret, 0.500, tolerance)
        w4fib := 70.0
    else if w4ret >= 0.146 and w4ret <= 0.618
        w4fib := 40.0
    float composite = w4fib * 0.5 + w3str * 0.3 + volScore * 0.2
    math.min(100.0, math.max(0.0, composite))

// ============================================================
// SECTION 17: FULL SCORERS
// ============================================================

f_scoreFibonacci(p0, p1, p2, p3, p4, p5, tolerance) =>
    float w2r = f_fibRetracement(p0, p1, p2)
    float w2s = 0.0
    if f_nearFib(w2r, 0.618, tolerance)
        w2s := 25.0
    else if f_nearFib(w2r, 0.500, tolerance)
        w2s := 20.0
    else if f_nearFib(w2r, 0.786, tolerance)
        w2s := 15.0
    else if w2r >= 0.382 and w2r <= 0.886
        w2s := 5.0
    float w1sz = math.abs(p1 - p0)
    float w3sz = math.abs(p3 - p2)
    float w3r  = 0.0
    if w1sz > 0.0
        w3r := w3sz / w1sz
    float w3s = 0.0
    if f_nearFib(w3r, 1.618, tolerance)
        w3s := 35.0
    else if f_nearFib(w3r, 2.618, tolerance)
        w3s := 25.0
    else if f_nearFib(w3r, 1.000, tolerance)
        w3s := 15.0
    else if w3r >= 1.0 and w3r <= 4.236
        w3s := 5.0
    float w4r = f_fibRetracement(p2, p3, p4)
    float w4s = 0.0
    if f_nearFib(w4r, 0.382, tolerance)
        w4s := 20.0
    else if f_nearFib(w4r, 0.236, tolerance)
        w4s := 15.0
    else if f_nearFib(w4r, 0.500, tolerance)
        w4s := 10.0
    else if w4r >= 0.146 and w4r <= 0.618
        w4s := 5.0
    float w5sz = math.abs(p5 - p4)
    float w5r  = 0.0
    if w1sz > 0.0
        w5r := w5sz / w1sz
    float w5s = 0.0
    if f_nearFib(w5r, 1.000, tolerance)
        w5s := 20.0
    else if f_nearFib(w5r, 0.618, tolerance)
        w5s := 15.0
    else if f_nearFib(w5r, 1.618, tolerance)
        w5s := 10.0
    else if w5r >= 0.382 and w5r <= 1.618
        w5s := 5.0
    math.min(100.0, math.max(0.0, w2s + w3s + w4s + w5s))

f_scoreWaveRatios(p0, p1, p2, p3, p4, p5, allowExt) =>
    float w1 = math.abs(p1 - p0)
    float w2 = math.abs(p2 - p1)
    float w3 = math.abs(p3 - p2)
    float w4 = math.abs(p4 - p3)
    float w5 = math.abs(p5 - p4)
    float score = 0.0
    if w3 >= math.min(w1, w5)
        score += 40.0
    float w2pct = 0.0
    if w1 > 0.0
        w2pct := w2 / w1
    if w2pct >= 0.382 and w2pct <= 0.886
        score += 30.0
    if w4 < w2
        score += 15.0
    float w5lim = allowExt ? w3 * 3.0 : w3 * 2.0
    if w5 <= w5lim
        score += 15.0
    math.min(100.0, math.max(0.0, score))

f_scoreTimeSymmetry(b0, b1, b2, b3, b4, b5) =>
    float t1 = float(math.abs(b1 - b0))
    float t3 = float(math.abs(b3 - b2))
    float t5 = float(math.abs(b5 - b4))
    float score = 0.0
    float avg = (t1 + t3 + t5) / 3.0
    if avg > 0.0
        var array<float> devs = array.new<float>(0)
        array.clear(devs)
        array.push(devs, math.abs(t1 - avg) / avg)
        array.push(devs, math.abs(t3 - avg) / avg)
        array.push(devs, math.abs(t5 - avg) / avg)
        array.sort(devs)
        score := math.max(0.0, 100.0 - array.get(devs, 1) * 100.0)
    math.min(100.0, math.max(0.0, score))

f_compositeScore(fibScore, ratioScore, timeScore, nFib, nRatio, nTime) =>
    float raw = fibScore * nFib + ratioScore * nRatio + timeScore * nTime
    math.min(100.0, math.max(0.0, raw))

f_bearishDivergence(pH1, rsi1, pH2, rsi2) =>
    pH2 > pH1 and rsi2 < rsi1

f_bullishDivergence(pL1, rsi1, pL2, rsi2) =>
    pL2 < pL1 and rsi2 > rsi1

// ============================================================
// SECTION 18: ABC DETECTORS
// ============================================================

f_detectZigzagBull(a0, a1, b1, c1, tolerance) =>
    float wA = math.abs(a1 - a0)
    float bR  = wA != 0.0 ? math.abs(b1 - a1) / wA : 0.0
    float cR  = wA != 0.0 ? math.abs(c1 - b1) / wA : 0.0
    bool bV   = bR >= (0.382 - tolerance) and bR <= (0.786 + tolerance)
    bool cV   = cR >= (0.618 - tolerance) and cR <= (1.618 + tolerance)
    bool dV   = (a1 < a0) and (b1 > a1) and (c1 < b1)
    float sc  = 0.0
    if bV
        sc += 50.0
    if cV
        sc += 30.0
    if dV
        sc += 20.0
    [bV and cV and dV, math.min(100.0, sc)]

f_detectFlatBull(a0, a1, b1, c1, tolerance) =>
    float wA = math.abs(a1 - a0)
    float bR  = wA != 0.0 ? math.abs(b1 - a1) / wA : 0.0
    float cR  = wA != 0.0 ? math.abs(c1 - b1) / wA : 0.0
    bool bV   = bR >= (0.80 - tolerance) and bR <= (1.10 + tolerance)
    bool cV   = cR >= (0.80 - tolerance) and cR <= (1.25 + tolerance)
    bool dV   = (a1 < a0) and (b1 > a1) and (c1 < b1)
    float sc  = 0.0
    if bV
        sc += 50.0
    if cV
        sc += 30.0
    if dV
        sc += 20.0
    [bV and cV and dV, math.min(100.0, sc)]

f_detectZigzagBear(a0, a1, b1, c1, tolerance) =>
    float wA = math.abs(a1 - a0)
    float bR  = wA != 0.0 ? math.abs(b1 - a1) / wA : 0.0
    float cR  = wA != 0.0 ? math.abs(c1 - b1) / wA : 0.0
    bool bV   = bR >= (0.382 - tolerance) and bR <= (0.786 + tolerance)
    bool cV   = cR >= (0.618 - tolerance) and cR <= (1.618 + tolerance)
    bool dV   = (a1 > a0) and (b1 < a1) and (c1 > b1)
    float sc  = 0.0
    if bV
        sc += 50.0
    if cV
        sc += 30.0
    if dV
        sc += 20.0
    [bV and cV and dV, math.min(100.0, sc)]

f_detectFlatBear(a0, a1, b1, c1, tolerance) =>
    float wA = math.abs(a1 - a0)
    float bR  = wA != 0.0 ? math.abs(b1 - a1) / wA : 0.0
    float cR  = wA != 0.0 ? math.abs(c1 - b1) / wA : 0.0
    bool bV   = bR >= (0.80 - tolerance) and bR <= (1.10 + tolerance)
    bool cV   = cR >= (0.80 - tolerance) and cR <= (1.25 + tolerance)
    bool dV   = (a1 > a0) and (b1 < a1) and (c1 > b1)
    float sc  = 0.0
    if bV
        sc += 50.0
    if cV
        sc += 30.0
    if dV
        sc += 20.0
    [bV and cV and dV, math.min(100.0, sc)]

// ============================================================
// SECTION 19: STATE VARIABLES
// ============================================================

var float bull_w0 = na, var int bull_b0 = na
var float bull_w1 = na, var int bull_b1 = na
var float bull_w2 = na, var int bull_b2 = na
var float bull_w3 = na, var int bull_b3 = na
var float bull_w4 = na, var int bull_b4 = na
var float bull_w5 = na, var int bull_b5 = na
var int   bull_state  = 0
var float bull_rsiW3  = na
var float bull_rsiW5  = na
var float bull_confW2 = 0.0
var float bull_confW4 = 0.0
var float bull_confW5 = 0.0
var bool  bull_w3VolOK = false
var bool  bull_w2Fired = false
var bool  bull_w4Fired = false
var bool  bull_w5Fired = false

var float bear_w0 = na, var int bear_b0 = na
var float bear_w1 = na, var int bear_b1 = na
var float bear_w2 = na, var int bear_b2 = na
var float bear_w3 = na, var int bear_b3 = na
var float bear_w4 = na, var int bear_b4 = na
var float bear_w5 = na, var int bear_b5 = na
var int   bear_state  = 0
var float bear_rsiW3  = na
var float bear_rsiW5  = na
var float bear_confW2 = 0.0
var float bear_confW4 = 0.0
var float bear_confW5 = 0.0
var bool  bear_w3VolOK = false
var bool  bear_w2Fired = false
var bool  bear_w4Fired = false
var bool  bear_w5Fired = false

// V2.5: Historical wave storage (last N completed cycles)
var array<float> histBull_w0 = array.new<float>(0)
var array<int>   histBull_b0 = array.new<int>(0)
var array<float> histBull_w1 = array.new<float>(0)
var array<int>   histBull_b1 = array.new<int>(0)
var array<float> histBull_w2 = array.new<float>(0)
var array<int>   histBull_b2 = array.new<int>(0)
var array<float> histBull_w3 = array.new<float>(0)
var array<int>   histBull_b3 = array.new<int>(0)
var array<float> histBull_w4 = array.new<float>(0)
var array<int>   histBull_b4 = array.new<int>(0)
var array<float> histBull_w5 = array.new<float>(0)
var array<int>   histBull_b5 = array.new<int>(0)
var array<float> histBull_conf = array.new<float>(0)

var array<float> histBear_w0 = array.new<float>(0)
var array<int>   histBear_b0 = array.new<int>(0)
var array<float> histBear_w1 = array.new<float>(0)
var array<int>   histBear_b1 = array.new<int>(0)
var array<float> histBear_w2 = array.new<float>(0)
var array<int>   histBear_b2 = array.new<int>(0)
var array<float> histBear_w3 = array.new<float>(0)
var array<int>   histBear_b3 = array.new<int>(0)
var array<float> histBear_w4 = array.new<float>(0)
var array<int>   histBear_b4 = array.new<int>(0)
var array<float> histBear_w5 = array.new<float>(0)
var array<int>   histBear_b5 = array.new<int>(0)
var array<float> histBear_conf = array.new<float>(0)

// Last completed (single-cycle quick reference)
var float lastBull_w0 = na, var int lastBull_b0 = na
var float lastBull_w1 = na, var int lastBull_b1 = na
var float lastBull_w2 = na, var int lastBull_b2 = na
var float lastBull_w3 = na, var int lastBull_b3 = na
var float lastBull_w4 = na, var int lastBull_b4 = na
var float lastBull_w5 = na, var int lastBull_b5 = na
var float lastBull_confW5 = 0.0

var float lastBear_w0 = na, var int lastBear_b0 = na
var float lastBear_w1 = na, var int lastBear_b1 = na
var float lastBear_w2 = na, var int lastBear_b2 = na
var float lastBear_w3 = na, var int lastBear_b3 = na
var float lastBear_w4 = na, var int lastBear_b4 = na
var float lastBear_w5 = na, var int lastBear_b5 = na
var float lastBear_confW5 = 0.0

var int lastZZBarBull = na
var int lastZZBarBear = na

var bool   bull_w5_complete     = false
var int    bull_w5_completeBar  = na
var float  bull_abc_a0  = na, var int bull_abc_a0Bar = na
var float  bull_abc_a1  = na, var int bull_abc_a1Bar = na
var float  bull_abc_b1  = na, var int bull_abc_b1Bar = na
var float  bull_abc_c1  = na, var int bull_abc_c1Bar = na
var bool   bull_abc_valid = false
var float  bull_abc_score = 0.0
var string bull_abc_type  = ""
var int    lastZZBullABC  = na

var bool   bear_w5_complete     = false
var int    bear_w5_completeBar  = na
var float  bear_abc_a0  = na, var int bear_abc_a0Bar = na
var float  bear_abc_a1  = na, var int bear_abc_a1Bar = na
var float  bear_abc_b1  = na, var int bear_abc_b1Bar = na
var float  bear_abc_c1  = na, var int bear_abc_c1Bar = na
var bool   bear_abc_valid = false
var float  bear_abc_score = 0.0
var string bear_abc_type  = ""
var int    lastZZBearABC  = na

var box bullProjBox = na
var box bearProjBox = na
var box bullABCBox  = na
var box bearABCBox  = na

// ============================================================
// SECTION 19b: OBJECT MANAGEMENT
// V2.5: Separate arrays for active vs completed/historical
// ============================================================

// Active structure objects (cleared when state resets)
var array<line>  activeBullLines  = array.new<line>(0)
var array<label> activeBullLabels = array.new<label>(0)
var array<line>  activeBearLines  = array.new<line>(0)
var array<label> activeBearLabels = array.new<label>(0)

// Completed/historical objects
var array<line>  completedLines  = array.new<line>(0)
var array<label> completedLabels = array.new<label>(0)

// General object cap safety
var array<line>  managedLines  = array.new<line>(0)
var array<label> managedLabels = array.new<label>(0)

int LINE_LIMIT  = 480
int LABEL_LIMIT = 480

f_addLine(ln) =>
    array.push(managedLines, ln)
    if array.size(managedLines) > LINE_LIMIT
        line.delete(array.shift(managedLines))

f_addLabel(lb) =>
    array.push(managedLabels, lb)
    if array.size(managedLabels) > LABEL_LIMIT
        label.delete(array.shift(managedLabels))

// V2.5: Clear active structure objects (called when state resets)
f_clearActiveBull() =>
    while array.size(activeBullLines) > 0
        line.delete(array.shift(activeBullLines))
    while array.size(activeBullLabels) > 0
        label.delete(array.shift(activeBullLabels))

f_clearActiveBear() =>
    while array.size(activeBearLines) > 0
        line.delete(array.shift(activeBearLines))
    while array.size(activeBearLabels) > 0
        label.delete(array.shift(activeBearLabels))

// ============================================================
// SECTION 20: STATE MACHINES
// ============================================================

int zzSize = array.size(zzPrices)

if barstate.isconfirmed and zzSize > 0

    float latestPrice = array.get(zzPrices, zzSize - 1)
    int   latestBar   = array.get(zzBars,   zzSize - 1)
    int   latestType  = array.get(zzTypes,  zzSize - 1)

    bool isNewZZBull = na(lastZZBarBull) or latestBar != lastZZBarBull
    bool isNewZZBear = na(lastZZBarBear) or latestBar != lastZZBarBear

    if bull_state > 0 and bull_state < 6
        int lb = bull_state == 1 ? bull_b0 :
                 bull_state == 2 ? bull_b1 :
                 bull_state == 3 ? bull_b2 :
                 bull_state == 4 ? bull_b3 :
                 bull_state == 5 ? bull_b4 : bull_b5
        if not na(lb) and (bar_index - lb) > effMaxBarsPerWave
            bull_state := 0
            bull_w0 := na
            bull_w1 := na
            bull_w2 := na
            bull_w3 := na
            bull_w4 := na
            bull_w5 := na
            bull_rsiW3 := na
            bull_rsiW5 := na
            bull_confW2 := 0.0
            bull_confW4 := 0.0
            bull_confW5 := 0.0
            bull_w3VolOK := false
            bull_w2Fired := false
            bull_w4Fired := false
            bull_w5Fired := false
            f_clearActiveBull()

    if isNewZZBull
        if bull_state == 0
            if latestType == -1
                bull_w0 := latestPrice
                bull_b0 := latestBar
                bull_state := 1
        else if bull_state == 1
            if latestType == 1 and latestBar > bull_b0
                if latestPrice > bull_w0
                    bull_w1 := latestPrice
                    bull_b1 := latestBar
                    bull_state := 2
            else if latestType == -1 and latestPrice < bull_w0
                bull_w0 := latestPrice
                bull_b0 := latestBar
        else if bull_state == 2
            if latestType == -1 and latestBar > bull_b1
                if latestPrice > bull_w0 and latestPrice < bull_w1
                    bull_w2 := latestPrice
                    bull_b2 := latestBar
                    bull_confW2 := f_scoreWave2Partial(bull_w0, bull_w1, bull_w2, effFibTolerance)
                    bull_state := 3
                else
                    bull_state := 0
                    bull_w0 := na
                    bull_w1 := na
                    bull_w2 := na
                    f_clearActiveBull()
        else if bull_state == 3
            if latestType == 1 and latestBar > bull_b2
                if latestPrice > bull_w1
                    float w1sz = bull_w1 - bull_w0
                    float w3sz = latestPrice - bull_w2
                    if w3sz >= w1sz * 0.9
                        bull_w3 := latestPrice
                        bull_b3 := latestBar
                        bull_rsiW3 := rsiSafePivot
                        bull_w3VolOK := isVolumeSpike
                        bull_state := 4
                    else
                        bull_state := 0
                        bull_w0 := na
                        bull_w1 := na
                        bull_w2 := na
                        bull_w3 := na
                        f_clearActiveBull()
        else if bull_state == 4
            if latestType == -1 and latestBar > bull_b3
                if latestPrice > bull_w1 and latestPrice < bull_w3
                    bull_w4 := latestPrice
                    bull_b4 := latestBar
                    float vs = bull_w3VolOK ? 100.0 : (effUseVolume ? 30.0 : 70.0)
                    bull_confW4 := f_scoreWave4Partial(bull_w0, bull_w1, bull_w2, bull_w3, bull_w4, effFibTolerance, vs)
                    bull_state := 5
                else
                    bull_state := 0
                    bull_w0 := na
                    bull_w1 := na
                    bull_w2 := na
                    bull_w3 := na
                    bull_w4 := na
                    f_clearActiveBull()
        else if bull_state == 5
            if latestType == 1 and latestBar > bull_b4
                if latestPrice > bull_w3
                    float w1s = bull_w1 - bull_w0
                    float w3s = bull_w3 - bull_w2
                    float w5s = latestPrice - bull_w4
                    bool w3ok = w3s >= math.min(w1s, w5s)
                    if w3ok
                        bull_w5 := latestPrice
                        bull_b5 := latestBar
                        bull_rsiW5 := rsiSafePivot
                        float fS = f_scoreFibonacci(bull_w0, bull_w1, bull_w2, bull_w3, bull_w4, bull_w5, effFibTolerance)
                        float rS = f_scoreWaveRatios(bull_w0, bull_w1, bull_w2, bull_w3, bull_w4, bull_w5, i_allowExtension)
                        float tS = f_scoreTimeSymmetry(bull_b0, bull_b1, bull_b2, bull_b3, bull_b4, bull_b5)
                        bull_confW5 := f_compositeScore(fS, rS, tS, wFib, wRatio, wTime)
                        float boost = isValidBullRegime ? 5.0 : -5.0
                        bull_confW5 := math.min(100.0, math.max(0.0, bull_confW5 + boost))
                        bull_state := 6
                        // Save to last
                        lastBull_w0 := bull_w0, lastBull_b0 := bull_b0
                        lastBull_w1 := bull_w1, lastBull_b1 := bull_b1
                        lastBull_w2 := bull_w2, lastBull_b2 := bull_b2
                        lastBull_w3 := bull_w3, lastBull_b3 := bull_b3
                        lastBull_w4 := bull_w4, lastBull_b4 := bull_b4
                        lastBull_w5 := bull_w5, lastBull_b5 := bull_b5
                        lastBull_confW5 := bull_confW5
                        // Push to history (cap at i_maxHistoricalCycles)
                        array.push(histBull_w0, bull_w0)
                        array.push(histBull_b0, bull_b0)
                        array.push(histBull_w1, bull_w1)
                        array.push(histBull_b1, bull_b1)
                        array.push(histBull_w2, bull_w2)
                        array.push(histBull_b2, bull_b2)
                        array.push(histBull_w3, bull_w3)
                        array.push(histBull_b3, bull_b3)
                        array.push(histBull_w4, bull_w4)
                        array.push(histBull_b4, bull_b4)
                        array.push(histBull_w5, bull_w5)
                        array.push(histBull_b5, bull_b5)
                        array.push(histBull_conf, bull_confW5)
                        if array.size(histBull_w0) > i_maxHistoricalCycles
                            array.shift(histBull_w0)
                            array.shift(histBull_b0)
                            array.shift(histBull_w1)
                            array.shift(histBull_b1)
                            array.shift(histBull_w2)
                            array.shift(histBull_b2)
                            array.shift(histBull_w3)
                            array.shift(histBull_b3)
                            array.shift(histBull_w4)
                            array.shift(histBull_b4)
                            array.shift(histBull_w5)
                            array.shift(histBull_b5)
                            array.shift(histBull_conf)
                    else
                        bull_state := 0
                        bull_w0 := na
                        bull_w1 := na
                        bull_w2 := na
                        bull_w3 := na
                        bull_w4 := na
                        bull_w5 := na
                        f_clearActiveBull()
        lastZZBarBull := latestBar

    if bear_state > 0 and bear_state < 6
        int lb = bear_state == 1 ? bear_b0 :
                 bear_state == 2 ? bear_b1 :
                 bear_state == 3 ? bear_b2 :
                 bear_state == 4 ? bear_b3 :
                 bear_state == 5 ? bear_b4 : bear_b5
        if not na(lb) and (bar_index - lb) > effMaxBarsPerWave
            bear_state := 0
            bear_w0 := na
            bear_w1 := na
            bear_w2 := na
            bear_w3 := na
            bear_w4 := na
            bear_w5 := na
            bear_rsiW3 := na
            bear_rsiW5 := na
            bear_confW2 := 0.0
            bear_confW4 := 0.0
            bear_confW5 := 0.0
            bear_w3VolOK := false
            bear_w2Fired := false
            bear_w4Fired := false
            bear_w5Fired := false
            f_clearActiveBear()

    if isNewZZBear
        if bear_state == 0
            if latestType == 1
                bear_w0 := latestPrice
                bear_b0 := latestBar
                bear_state := 1
        else if bear_state == 1
            if latestType == -1 and latestBar > bear_b0
                if latestPrice < bear_w0
                    bear_w1 := latestPrice
                    bear_b1 := latestBar
                    bear_state := 2
            else if latestType == 1 and latestPrice > bear_w0
                bear_w0 := latestPrice
                bear_b0 := latestBar
        else if bear_state == 2
            if latestType == 1 and latestBar > bear_b1
                if latestPrice < bear_w0 and latestPrice > bear_w1
                    bear_w2 := latestPrice
                    bear_b2 := latestBar
                    bear_confW2 := f_scoreWave2Partial(bear_w0, bear_w1, bear_w2, effFibTolerance)
                    bear_state := 3
                else
                    bear_state := 0
                    bear_w0 := na
                    bear_w1 := na
                    bear_w2 := na
                    f_clearActiveBear()
        else if bear_state == 3
            if latestType == -1 and latestBar > bear_b2
                if latestPrice < bear_w1
                    float w1sz = bear_w0 - bear_w1
                    float w3sz = bear_w2 - latestPrice
                    if w3sz >= w1sz * 0.9
                        bear_w3 := latestPrice
                        bear_b3 := latestBar
                        bear_rsiW3 := rsiSafePivot
                        bear_w3VolOK := isVolumeSpike
                        bear_state := 4
                    else
                        bear_state := 0
                        bear_w0 := na
                        bear_w1 := na
                        bear_w2 := na
                        bear_w3 := na
                        f_clearActiveBear()
        else if bear_state == 4
            if latestType == 1 and latestBar > bear_b3
                if latestPrice < bear_w1 and latestPrice > bear_w3
                    bear_w4 := latestPrice
                    bear_b4 := latestBar
                    float vs = bear_w3VolOK ? 100.0 : (effUseVolume ? 30.0 : 70.0)
                    bear_confW4 := f_scoreWave4Partial(bear_w0, bear_w1, bear_w2, bear_w3, bear_w4, effFibTolerance, vs)
                    bear_state := 5
                else
                    bear_state := 0
                    bear_w0 := na
                    bear_w1 := na
                    bear_w2 := na
                    bear_w3 := na
                    bear_w4 := na
                    f_clearActiveBear()
        else if bear_state == 5
            if latestType == -1 and latestBar > bear_b4
                if latestPrice < bear_w3
                    float w1s = bear_w0 - bear_w1
                    float w3s = bear_w2 - bear_w3
                    float w5s = bear_w4 - latestPrice
                    bool w3ok = w3s >= math.min(w1s, w5s)
                    if w3ok
                        bear_w5 := latestPrice
                        bear_b5 := latestBar
                        bear_rsiW5 := rsiSafePivot
                        float fS = f_scoreFibonacci(bear_w0, bear_w1, bear_w2, bear_w3, bear_w4, bear_w5, effFibTolerance)
                        float rS = f_scoreWaveRatios(bear_w0, bear_w1, bear_w2, bear_w3, bear_w4, bear_w5, i_allowExtension)
                        float tS = f_scoreTimeSymmetry(bear_b0, bear_b1, bear_b2, bear_b3, bear_b4, bear_b5)
                        bear_confW5 := f_compositeScore(fS, rS, tS, wFib, wRatio, wTime)
                        float boost = isValidBearRegime ? 5.0 : -5.0
                        bear_confW5 := math.min(100.0, math.max(0.0, bear_confW5 + boost))
                        bear_state := 6
                        lastBear_w0 := bear_w0, lastBear_b0 := bear_b0
                        lastBear_w1 := bear_w1, lastBear_b1 := bear_b1
                        lastBear_w2 := bear_w2, lastBear_b2 := bear_b2
                        lastBear_w3 := bear_w3, lastBear_b3 := bear_b3
                        lastBear_w4 := bear_w4, lastBear_b4 := bear_b4
                        lastBear_w5 := bear_w5, lastBear_b5 := bear_b5
                        lastBear_confW5 := bear_confW5
                        array.push(histBear_w0, bear_w0)
                        array.push(histBear_b0, bear_b0)
                        array.push(histBear_w1, bear_w1)
                        array.push(histBear_b1, bear_b1)
                        array.push(histBear_w2, bear_w2)
                        array.push(histBear_b2, bear_b2)
                        array.push(histBear_w3, bear_w3)
                        array.push(histBear_b3, bear_b3)
                        array.push(histBear_w4, bear_w4)
                        array.push(histBear_b4, bear_b4)
                        array.push(histBear_w5, bear_w5)
                        array.push(histBear_b5, bear_b5)
                        array.push(histBear_conf, bear_confW5)
                        if array.size(histBear_w0) > i_maxHistoricalCycles
                            array.shift(histBear_w0)
                            array.shift(histBear_b0)
                            array.shift(histBear_w1)
                            array.shift(histBear_b1)
                            array.shift(histBear_w2)
                            array.shift(histBear_b2)
                            array.shift(histBear_w3)
                            array.shift(histBear_b3)
                            array.shift(histBear_w4)
                            array.shift(histBear_b4)
                            array.shift(histBear_w5)
                            array.shift(histBear_b5)
                            array.shift(histBear_conf)
                    else
                        bear_state := 0
                        bear_w0 := na
                        bear_w1 := na
                        bear_w2 := na
                        bear_w3 := na
                        bear_w4 := na
                        bear_w5 := na
                        f_clearActiveBear()
        lastZZBarBear := latestBar

// ============================================================
// SECTION 21: ABC DETECTION
// ============================================================

if i_showABC and barstate.isconfirmed and zzSize > 0
    float lp = array.get(zzPrices, zzSize - 1)
    int   lb = array.get(zzBars,   zzSize - 1)
    int   lt = array.get(zzTypes,  zzSize - 1)
    bool newBullABC = na(lastZZBullABC) or lb != lastZZBullABC
    bool newBearABC = na(lastZZBearABC) or lb != lastZZBearABC

    if bull_w5_complete and not bull_abc_valid and newBullABC
        if not na(bull_w5_completeBar) and (bar_index - bull_w5_completeBar) > i_maxBarsABC
            bull_w5_complete := false
            bull_abc_a0 := na
            bull_abc_a1 := na
            bull_abc_b1 := na
            bull_abc_c1 := na
        if bull_w5_complete
            if na(bull_abc_a0) and not na(bull_w5)
                bull_abc_a0 := bull_w5
                bull_abc_a0Bar := bull_b5
            if not na(bull_abc_a0) and na(bull_abc_a1) and lt == -1 and lb > bull_abc_a0Bar
                bull_abc_a1 := lp
                bull_abc_a1Bar := lb
            if not na(bull_abc_a1) and na(bull_abc_b1) and lt == 1 and lb > bull_abc_a1Bar
                bull_abc_b1 := lp
                bull_abc_b1Bar := lb
            if not na(bull_abc_b1) and na(bull_abc_c1) and lt == -1 and lb > bull_abc_b1Bar
                bull_abc_c1 := lp
                bull_abc_c1Bar := lb
                [zv, zs] = f_detectZigzagBull(bull_abc_a0, bull_abc_a1, bull_abc_b1, bull_abc_c1, effFibTolerance)
                [fv, fs] = f_detectFlatBull(bull_abc_a0, bull_abc_a1, bull_abc_b1, bull_abc_c1, effFibTolerance)
                if zv and (not fv or zs >= fs)
                    bull_abc_valid := true
                    bull_abc_score := zs
                    bull_abc_type := "Zigzag"
                else if fv
                    bull_abc_valid := true
                    bull_abc_score := fs
                    bull_abc_type := "Flat"
                else
                    bull_abc_a0 := na
                    bull_abc_a1 := na
                    bull_abc_b1 := na
                    bull_abc_c1 := na
        lastZZBullABC := lb

    if bear_w5_complete and not bear_abc_valid and newBearABC
        if not na(bear_w5_completeBar) and (bar_index - bear_w5_completeBar) > i_maxBarsABC
            bear_w5_complete := false
            bear_abc_a0 := na
            bear_abc_a1 := na
            bear_abc_b1 := na
            bear_abc_c1 := na
        if bear_w5_complete
            if na(bear_abc_a0) and not na(bear_w5)
                bear_abc_a0 := bear_w5
                bear_abc_a0Bar := bear_b5
            if not na(bear_abc_a0) and na(bear_abc_a1) and lt == 1 and lb > bear_abc_a0Bar
                bear_abc_a1 := lp
                bear_abc_a1Bar := lb
            if not na(bear_abc_a1) and na(bear_abc_b1) and lt == -1 and lb > bear_abc_a1Bar
                bear_abc_b1 := lp
                bear_abc_b1Bar := lb
            if not na(bear_abc_b1) and na(bear_abc_c1) and lt == 1 and lb > bear_abc_b1Bar
                bear_abc_c1 := lp
                bear_abc_c1Bar := lb
                [zv, zs] = f_detectZigzagBear(bear_abc_a0, bear_abc_a1, bear_abc_b1, bear_abc_c1, effFibTolerance)
                [fv, fs] = f_detectFlatBear(bear_abc_a0, bear_abc_a1, bear_abc_b1, bear_abc_c1, effFibTolerance)
                if zv and (not fv or zs >= fs)
                    bear_abc_valid := true
                    bear_abc_score := zs
                    bear_abc_type := "Zigzag"
                else if fv
                    bear_abc_valid := true
                    bear_abc_score := fs
                    bear_abc_type := "Flat"
                else
                    bear_abc_a0 := na
                    bear_abc_a1 := na
                    bear_abc_b1 := na
                    bear_abc_c1 := na
        lastZZBearABC := lb

// ============================================================
// SECTION 22: SIGNALS
// ============================================================

var int lastSignalBar = na
bool canFireSignal = na(lastSignalBar) or (bar_index - lastSignalBar) >= i_cooldownBars
bool allowLong  = (i_signalMode == "Both" or i_signalMode == "Long Only")
bool allowShort = (i_signalMode == "Both" or i_signalMode == "Short Only") and i_enableShorts

bool validBullProjection = bull_confW4 >= dynConfW4 and isValidBullRegime and bull_state == 5
bool validBearProjection = bear_confW4 >= dynConfW4 and isValidBearRegime and bear_state == 5

bool bullProjectionInvalid = bull_state < 5 or (not na(bull_w4) and close < bull_w4)
bool bearProjectionInvalid = bear_state < 5 or (not na(bear_w4) and close > bear_w4)

bool validBullW3 = false
if not na(bull_w3) and not na(bull_w2) and not na(bull_w1) and not na(bull_w0)
    float w3sz = bull_w3 - bull_w2
    float w1sz = bull_w1 - bull_w0
    bool szOK = w3sz >= w1sz * 0.9
    bool vOK  = effUseVolume ? bull_w3VolOK : true
    validBullW3 := szOK and vOK

bool validBearW3 = false
if not na(bear_w3) and not na(bear_w2) and not na(bear_w1) and not na(bear_w0)
    float w3sz = bear_w2 - bear_w3
    float w1sz = bear_w0 - bear_w1
    bool szOK = w3sz >= w1sz * 0.9
    bool vOK  = effUseVolume ? bear_w3VolOK : true
    validBearW3 := szOK and vOK

bool bullW5DivOK = true
if i_useRSI and not na(bull_rsiW3) and not na(bull_rsiW5)
    bullW5DivOK := f_bearishDivergence(bull_w3, bull_rsiW3, bull_w5, bull_rsiW5)

bool bearW5DivOK = true
if i_useRSI and not na(bear_rsiW3) and not na(bear_rsiW5)
    bearW5DivOK := f_bullishDivergence(bear_w3, bear_rsiW3, bear_w5, bear_rsiW5)

bool buySignalW2 = barstate.isconfirmed and isWarmedUp and
     bull_state == 3 and not bull_w2Fired and
     bull_confW2 >= dynConfW2 and isValidBullRegime and isLiquid and
     canFireSignal and allowLong and not isChoppy

bool buySignalW4 = barstate.isconfirmed and isWarmedUp and
     bull_state == 5 and not bull_w4Fired and i_wave4entry and
     bull_confW4 >= dynConfW4 and isValidBullRegime and isLiquid and
     canFireSignal and allowLong and not isChoppy and
     validBullW3 and validBullProjection

bool sellSignalW5 = barstate.isconfirmed and isWarmedUp and
     bull_state == 6 and not bull_w5Fired and
     bull_confW5 >= dynConfW5 and (not i_useRSI or bullW5DivOK)

bool shortSignalW2 = barstate.isconfirmed and isWarmedUp and
     bear_state == 3 and not bear_w2Fired and
     bear_confW2 >= dynConfW2 and isValidBearRegime and isLiquid and
     canFireSignal and allowShort and not isChoppy

bool shortSignalW4 = barstate.isconfirmed and isWarmedUp and
     bear_state == 5 and not bear_w4Fired and i_wave4entry and
     bear_confW4 >= dynConfW4 and isValidBearRegime and isLiquid and
     canFireSignal and allowShort and not isChoppy and
     validBearW3 and validBearProjection

bool coverSignalW5 = barstate.isconfirmed and isWarmedUp and
     bear_state == 6 and not bear_w5Fired and
     bear_confW5 >= dynConfW5 and (not i_useRSI or bearW5DivOK)

if buySignalW2
    bull_w2Fired := true
    lastSignalBar := bar_index
if buySignalW4
    bull_w4Fired := true
    lastSignalBar := bar_index
if shortSignalW2
    bear_w2Fired := true
    lastSignalBar := bar_index
if shortSignalW4
    bear_w4Fired := true
    lastSignalBar := bar_index

if sellSignalW5
    bull_w5Fired := true
    lastSignalBar := bar_index
    bull_w5_complete := true
    bull_w5_completeBar := bar_index
    bull_state := 0
    f_clearActiveBull()

if bull_w5_complete and bull_abc_valid
    bull_w5_complete := false
    bull_w5_completeBar := na
    bull_abc_valid := false
    bull_abc_a0 := na
    bull_abc_a1 := na
    bull_abc_b1 := na
    bull_abc_c1 := na
    bull_abc_score := 0.0
    bull_abc_type := ""
    bull_w0 := na
    bull_w1 := na
    bull_w2 := na
    bull_w3 := na
    bull_w4 := na
    bull_w5 := na
    bull_rsiW3 := na
    bull_rsiW5 := na
    bull_confW2 := 0.0
    bull_confW4 := 0.0
    bull_confW5 := 0.0
    bull_w3VolOK := false
    bull_w2Fired := false
    bull_w4Fired := false
    bull_w5Fired := false

if coverSignalW5
    bear_w5Fired := true
    lastSignalBar := bar_index
    bear_w5_complete := true
    bear_w5_completeBar := bar_index
    bear_state := 0
    f_clearActiveBear()

if bear_w5_complete and bear_abc_valid
    bear_w5_complete := false
    bear_w5_completeBar := na
    bear_abc_valid := false
    bear_abc_a0 := na
    bear_abc_a1 := na
    bear_abc_b1 := na
    bear_abc_c1 := na
    bear_abc_score := 0.0
    bear_abc_type := ""
    bear_w0 := na
    bear_w1 := na
    bear_w2 := na
    bear_w3 := na
    bear_w4 := na
    bear_w5 := na
    bear_rsiW3 := na
    bear_rsiW5 := na
    bear_confW2 := 0.0
    bear_confW4 := 0.0
    bear_confW5 := 0.0
    bear_w3VolOK := false
    bear_w2Fired := false
    bear_w4Fired := false
    bear_w5Fired := false

// Hard safety resets
if bull_w5_complete and not na(bull_w5_completeBar) and (bar_index - bull_w5_completeBar) > i_maxBarsABC
    bull_w5_complete := false
    bull_w5_completeBar := na
    bull_abc_valid := false
    bull_abc_a0 := na
    bull_abc_a1 := na
    bull_abc_b1 := na
    bull_abc_c1 := na
    bull_abc_score := 0.0
    bull_abc_type := ""

if bear_w5_complete and not na(bear_w5_completeBar) and (bar_index - bear_w5_completeBar) > i_maxBarsABC
    bear_w5_complete := false
    bear_w5_completeBar := na
    bear_abc_valid := false
    bear_abc_a0 := na
    bear_abc_a1 := na
    bear_abc_b1 := na
    bear_abc_c1 := na
    bear_abc_score := 0.0
    bear_abc_type := ""

if bull_state < 3
    bull_w2Fired := false
if bull_state < 5
    bull_w4Fired := false
if bull_state < 6
    bull_w5Fired := false
if bear_state < 3
    bear_w2Fired := false
if bear_state < 5
    bear_w4Fired := false
if bear_state < 6
    bear_w5Fired := false

// ============================================================
// SECTION 23: VISUALIZATION (V2.5: redrawn each bar)
// ============================================================

f_confColor(score) =>
    color c = color.red
    if score >= 80
        c := color.lime
    else if score >= 60
        c := color.yellow
    c

// Helper: add line tracked in active or completed bucket
f_drawBullLine(x1, y1, x2, y2, col, w, sty, isActive) =>
    line ln = line.new(x1, y1, x2, y2, xloc=xloc.bar_time, color=col, width=w, style=sty)
    if isActive
        array.push(activeBullLines, ln)
    else
        array.push(completedLines, ln)
    f_addLine(ln)

f_drawBearLine(x1, y1, x2, y2, col, w, sty, isActive) =>
    line ln = line.new(x1, y1, x2, y2, xloc=xloc.bar_time, color=col, width=w, style=sty)
    if isActive
        array.push(activeBearLines, ln)
    else
        array.push(completedLines, ln)
    f_addLine(ln)

f_drawBullLabel(x, y, txt, col, tcol, sty, sz, isActive) =>
    label lb = label.new(x, y, txt, xloc=xloc.bar_time, color=col, textcolor=tcol, style=sty, size=sz)
    if isActive
        array.push(activeBullLabels, lb)
    else
        array.push(completedLabels, lb)
    f_addLabel(lb)

f_drawBearLabel(x, y, txt, col, tcol, sty, sz, isActive) =>
    label lb = label.new(x, y, txt, xloc=xloc.bar_time, color=col, textcolor=tcol, style=sty, size=sz)
    if isActive
        array.push(activeBearLabels, lb)
    else
        array.push(completedLabels, lb)
    f_addLabel(lb)

// V2.5: Redraw active bull on every confirmed bar (clears prior, draws fresh)
if barstate.isconfirmed and showActiveBull and bull_state >= 6
    f_clearActiveBull()
    if not na(bull_w0) and not na(bull_w1)
        f_drawBullLine(f_barTime(bull_b0), bull_w0, f_barTime(bull_b1), bull_w1,
             color.new(color.blue, 20), 2, line.style_solid, true)
    if not na(bull_w1) and not na(bull_w2)
        f_drawBullLine(f_barTime(bull_b1), bull_w1, f_barTime(bull_b2), bull_w2,
             color.new(color.red, 20), 2, line.style_solid, true)
    if not na(bull_w2) and not na(bull_w3)
        f_drawBullLine(f_barTime(bull_b2), bull_w2, f_barTime(bull_b3), bull_w3,
             color.new(color.green, 20), 2, line.style_solid, true)
    if not na(bull_w3) and not na(bull_w4)
        f_drawBullLine(f_barTime(bull_b3), bull_w3, f_barTime(bull_b4), bull_w4,
             color.new(color.orange, 20), 2, line.style_solid, true)
    if not na(bull_w4) and not na(bull_w5)
        f_drawBullLine(f_barTime(bull_b4), bull_w4, f_barTime(bull_b5), bull_w5,
             color.new(color.purple, 20), 2, line.style_solid, true)

    if i_showLabels
        if not na(bull_w1)
            f_drawBullLabel(f_barTime(bull_b1), bull_w1 + labelOffset, "1",
                 color.blue, color.white, label.style_label_down, size.small, true)
        if not na(bull_w2) and i_showConfidence
            f_drawBullLabel(f_barTime(bull_b2), bull_w2 - labelOffset,
                 "2 [" + str.tostring(math.round(bull_confW2)) + "%]",
                 f_confColor(bull_confW2), color.black, label.style_label_up, size.small, true)
        if not na(bull_w3)
            f_drawBullLabel(f_barTime(bull_b3), bull_w3 + labelOffset, "3",
                 color.green, color.white, label.style_label_down, size.small, true)
        if not na(bull_w4) and i_showConfidence
            f_drawBullLabel(f_barTime(bull_b4), bull_w4 - labelOffset,
                 "4 [" + str.tostring(math.round(bull_confW4)) + "%]",
                 f_confColor(bull_confW4), color.black, label.style_label_up, size.small, true)
        if not na(bull_w5) and i_showConfidence
            f_drawBullLabel(f_barTime(bull_b5), bull_w5 + labelOffset,
                 "5 [" + str.tostring(math.round(bull_confW5)) + "%]",
                 f_confColor(bull_confW5), color.black, label.style_label_down, size.small, true)

// Active bear redraw
if barstate.isconfirmed and showActiveBear and bear_state >= 6 and i_enableShorts
    f_clearActiveBear()
    if not na(bear_w0) and not na(bear_w1)
        f_drawBearLine(f_barTime(bear_b0), bear_w0, f_barTime(bear_b1), bear_w1,
             color.new(color.maroon, 20), 2, line.style_dashed, true)
    if not na(bear_w1) and not na(bear_w2)
        f_drawBearLine(f_barTime(bear_b1), bear_w1, f_barTime(bear_b2), bear_w2,
             color.new(color.red, 20), 2, line.style_dashed, true)
    if not na(bear_w2) and not na(bear_w3)
        f_drawBearLine(f_barTime(bear_b2), bear_w2, f_barTime(bear_b3), bear_w3,
             color.new(color.maroon, 20), 2, line.style_dashed, true)
    if not na(bear_w3) and not na(bear_w4)
        f_drawBearLine(f_barTime(bear_b3), bear_w3, f_barTime(bear_b4), bear_w4,
             color.new(color.orange, 20), 2, line.style_dashed, true)
    if not na(bear_w4) and not na(bear_w5)
        f_drawBearLine(f_barTime(bear_b4), bear_w4, f_barTime(bear_b5), bear_w5,
             color.new(color.purple, 20), 2, line.style_dashed, true)

    if i_showLabels
        if not na(bear_w1)
            f_drawBearLabel(f_barTime(bear_b1), bear_w1 - labelOffset, "B1",
                 color.maroon, color.white, label.style_label_up, size.small, true)
        if not na(bear_w2) and i_showConfidence
            f_drawBearLabel(f_barTime(bear_b2), bear_w2 + labelOffset,
                 "B2 [" + str.tostring(math.round(bear_confW2)) + "%]",
                 f_confColor(bear_confW2), color.black, label.style_label_down, size.small, true)
        if not na(bear_w3)
            f_drawBearLabel(f_barTime(bear_b3), bear_w3 - labelOffset, "B3",
                 color.maroon, color.white, label.style_label_up, size.small, true)
        if not na(bear_w4) and i_showConfidence
            f_drawBearLabel(f_barTime(bear_b4), bear_w4 + labelOffset,
                 "B4 [" + str.tostring(math.round(bear_confW4)) + "%]",
                 f_confColor(bear_confW4), color.black, label.style_label_down, size.small, true)
        if not na(bear_w5) and i_showConfidence
            f_drawBearLabel(f_barTime(bear_b5), bear_w5 - labelOffset,
                 "B5 [" + str.tostring(math.round(bear_confW5)) + "%]",
                 f_confColor(bear_confW5), color.black, label.style_label_up, size.small, true)

// V2.5: Last completed (single cycle) - drawn once on bar with state == 6 transition
var bool lastBullDrawn = false
var bool lastBearDrawn = false

if showCompletedBull and barstate.isconfirmed and bull_state == 6 and not lastBullDrawn and not na(lastBull_w5)
    f_drawBullLine(f_barTime(lastBull_b0), lastBull_w0, f_barTime(lastBull_b1), lastBull_w1,
         color.new(color.blue, 60), 1, line.style_solid, false)
    f_drawBullLine(f_barTime(lastBull_b1), lastBull_w1, f_barTime(lastBull_b2), lastBull_w2,
         color.new(color.red, 60), 1, line.style_solid, false)
    f_drawBullLine(f_barTime(lastBull_b2), lastBull_w2, f_barTime(lastBull_b3), lastBull_w3,
         color.new(color.green, 60), 1, line.style_solid, false)
    f_drawBullLine(f_barTime(lastBull_b3), lastBull_w3, f_barTime(lastBull_b4), lastBull_w4,
         color.new(color.orange, 60), 1, line.style_solid, false)
    f_drawBullLine(f_barTime(lastBull_b4), lastBull_w4, f_barTime(lastBull_b5), lastBull_w5,
         color.new(color.purple, 60), 1, line.style_solid, false)
    lastBullDrawn := true

if bull_state < 6
    lastBullDrawn := false

if showCompletedBear and barstate.isconfirmed and bear_state == 6 and not lastBearDrawn and not na(lastBear_w5) and i_enableShorts
    f_drawBearLine(f_barTime(lastBear_b0), lastBear_w0, f_barTime(lastBear_b1), lastBear_w1,
         color.new(color.maroon, 60), 1, line.style_dashed, false)
    f_drawBearLine(f_barTime(lastBear_b1), lastBear_w1, f_barTime(lastBear_b2), lastBear_w2,
         color.new(color.red, 60), 1, line.style_dashed, false)
    f_drawBearLine(f_barTime(lastBear_b2), lastBear_w2, f_barTime(lastBear_b3), lastBear_w3,
         color.new(color.maroon, 60), 1, line.style_dashed, false)
    f_drawBearLine(f_barTime(lastBear_b3), lastBear_w3, f_barTime(lastBear_b4), lastBear_w4,
         color.new(color.orange, 60), 1, line.style_dashed, false)
    f_drawBearLine(f_barTime(lastBear_b4), lastBear_w4, f_barTime(lastBear_b5), lastBear_w5,
         color.new(color.purple, 60), 1, line.style_dashed, false)
    lastBearDrawn := true

if bear_state < 6
    lastBearDrawn := false

// V2.5: Historical mode - draw all stored cycles on bar 1 only
var bool historicalDrawn = false

if barstate.islast and not historicalDrawn
    if showHistoricalBull
        int hb = array.size(histBull_w0)
        for i = 0 to hb - 1
            float h0 = array.get(histBull_w0, i)
            int   b0i = array.get(histBull_b0, i)
            float h1 = array.get(histBull_w1, i)
            int   b1i = array.get(histBull_b1, i)
            float h2 = array.get(histBull_w2, i)
            int   b2i = array.get(histBull_b2, i)
            float h3 = array.get(histBull_w3, i)
            int   b3i = array.get(histBull_b3, i)
            float h4 = array.get(histBull_w4, i)
            int   b4i = array.get(histBull_b4, i)
            float h5 = array.get(histBull_w5, i)
            int   b5i = array.get(histBull_b5, i)
            f_drawBullLine(f_barTime(b0i), h0, f_barTime(b1i), h1, color.new(color.blue, 70), 1, line.style_solid, false)
            f_drawBullLine(f_barTime(b1i), h1, f_barTime(b2i), h2, color.new(color.red, 70), 1, line.style_solid, false)
            f_drawBullLine(f_barTime(b2i), h2, f_barTime(b3i), h3, color.new(color.green, 70), 1, line.style_solid, false)
            f_drawBullLine(f_barTime(b3i), h3, f_barTime(b4i), h4, color.new(color.orange, 70), 1, line.style_solid, false)
            f_drawBullLine(f_barTime(b4i), h4, f_barTime(b5i), h5, color.new(color.purple, 70), 1, line.style_solid, false)
    if showHistoricalBear and i_enableShorts
        int hb = array.size(histBear_w0)
        for i = 0 to hb - 1
            float h0 = array.get(histBear_w0, i)
            int   b0i = array.get(histBear_b0, i)
            float h1 = array.get(histBear_w1, i)
            int   b1i = array.get(histBear_b1, i)
            float h2 = array.get(histBear_w2, i)
            int   b2i = array.get(histBear_b2, i)
            float h3 = array.get(histBear_w3, i)
            int   b3i = array.get(histBear_b3, i)
            float h4 = array.get(histBear_w4, i)
            int   b4i = array.get(histBear_b4, i)
            float h5 = array.get(histBear_w5, i)
            int   b5i = array.get(histBear_b5, i)
            f_drawBearLine(f_barTime(b0i), h0, f_barTime(b1i), h1, color.new(color.maroon, 70), 1, line.style_dashed, false)
            f_drawBearLine(f_barTime(b1i), h1, f_barTime(b2i), h2, color.new(color.red, 70), 1, line.style_dashed, false)
            f_drawBearLine(f_barTime(b2i), h2, f_barTime(b3i), h3, color.new(color.maroon, 70), 1, line.style_dashed, false)
            f_drawBearLine(f_barTime(b3i), h3, f_barTime(b4i), h4, color.new(color.orange, 70), 1, line.style_dashed, false)
            f_drawBearLine(f_barTime(b4i), h4, f_barTime(b5i), h5, color.new(color.purple, 70), 1, line.style_dashed, false)
    historicalDrawn := true

// ABC visualization (active only)
if bull_abc_valid and barstate.isconfirmed and showActiveBull
    if not na(bull_abc_a0) and not na(bull_abc_a1)
        f_addLine(line.new(f_barTime(bull_abc_a0Bar), bull_abc_a0, f_barTime(bull_abc_a1Bar), bull_abc_a1,
             xloc=xloc.bar_time, color=color.new(color.yellow, 20), width=2, style=line.style_dotted))
    if not na(bull_abc_a1) and not na(bull_abc_b1)
        f_addLine(line.new(f_barTime(bull_abc_a1Bar), bull_abc_a1, f_barTime(bull_abc_b1Bar), bull_abc_b1,
             xloc=xloc.bar_time, color=color.new(color.yellow, 20), width=2, style=line.style_dotted))
    if not na(bull_abc_b1) and not na(bull_abc_c1)
        f_addLine(line.new(f_barTime(bull_abc_b1Bar), bull_abc_b1, f_barTime(bull_abc_c1Bar), bull_abc_c1,
             xloc=xloc.bar_time, color=color.new(color.yellow, 20), width=2, style=line.style_dotted))

if i_showLabels and bull_abc_valid and barstate.isconfirmed and showActiveBull
    if not na(bull_abc_a1)
        f_addLabel(label.new(f_barTime(bull_abc_a1Bar), bull_abc_a1 - labelOffset, "A",
             xloc=xloc.bar_time, color=color.yellow, textcolor=color.black,
             style=label.style_label_up, size=size.small))
    if not na(bull_abc_b1)
        f_addLabel(label.new(f_barTime(bull_abc_b1Bar), bull_abc_b1 + labelOffset, "B",
             xloc=xloc.bar_time, color=color.yellow, textcolor=color.black,
             style=label.style_label_down, size=size.small))
    if not na(bull_abc_c1)
        f_addLabel(label.new(f_barTime(bull_abc_c1Bar), bull_abc_c1 - labelOffset,
             "C [" + bull_abc_type + "]",
             xloc=xloc.bar_time, color=color.yellow, textcolor=color.black,
             style=label.style_label_up, size=size.small))

if bear_abc_valid and barstate.isconfirmed and showActiveBear and i_enableShorts
    if not na(bear_abc_a0) and not na(bear_abc_a1)
        f_addLine(line.new(f_barTime(bear_abc_a0Bar), bear_abc_a0, f_barTime(bear_abc_a1Bar), bear_abc_a1,
             xloc=xloc.bar_time, color=color.new(color.aqua, 20), width=2, style=line.style_dotted))
    if not na(bear_abc_a1) and not na(bear_abc_b1)
        f_addLine(line.new(f_barTime(bear_abc_a1Bar), bear_abc_a1, f_barTime(bear_abc_b1Bar), bear_abc_b1,
             xloc=xloc.bar_time, color=color.new(color.aqua, 20), width=2, style=line.style_dotted))
    if not na(bear_abc_b1) and not na(bear_abc_c1)
        f_addLine(line.new(f_barTime(bear_abc_b1Bar), bear_abc_b1, f_barTime(bear_abc_c1Bar), bear_abc_c1,
             xloc=xloc.bar_time, color=color.new(color.aqua, 20), width=2, style=line.style_dotted))
             
if i_showLabels and bear_abc_valid and barstate.isconfirmed and showActiveBear and i_enableShorts
    if not na(bear_abc_a1)
        f_addLabel(label.new(f_barTime(bear_abc_a1Bar), bear_abc_a1 + labelOffset, "a",
             xloc=xloc.bar_time, color=color.aqua, textcolor=color.black,
             style=label.style_label_down, size=size.small))
    if not na(bear_abc_b1)
        f_addLabel(label.new(f_barTime(bear_abc_b1Bar), bear_abc_b1 - labelOffset, "b",
             xloc=xloc.bar_time, color=color.aqua, textcolor=color.black,
             style=label.style_label_up, size=size.small))
    if not na(bear_abc_c1)
        f_addLabel(label.new(f_barTime(bear_abc_c1Bar), bear_abc_c1 + labelOffset,
             "c [" + bear_abc_type + "]",
             xloc=xloc.bar_time, color=color.aqua, textcolor=color.black,
             style=label.style_label_down, size=size.small))

// Signal plotshapes (display=display.all to keep visible)
plotshape(i_showSignals and buySignalW2,   title="Buy W2",   location=location.belowbar, color=color.lime,    style=shape.triangleup,   size=size.normal, text="BUY W2")
plotshape(i_showSignals and buySignalW4,   title="Buy W4",   location=location.belowbar, color=color.green,   style=shape.triangleup,   size=size.small,  text="BUY W4")
plotshape(i_showSignals and sellSignalW5,  title="Sell W5",  location=location.abovebar, color=color.red,     style=shape.triangledown, size=size.normal, text="SELL W5")
plotshape(i_showSignals and shortSignalW2, title="Short W2", location=location.abovebar, color=color.fuchsia, style=shape.triangledown, size=size.normal, text="SHORT W2")
plotshape(i_showSignals and shortSignalW4, title="Short W4", location=location.abovebar, color=color.purple,  style=shape.triangledown, size=size.small,  text="SHORT W4")
plotshape(i_showSignals and coverSignalW5, title="Cover W5", location=location.belowbar, color=color.aqua,    style=shape.triangleup,   size=size.normal, text="COVER W5")

// V2.5: EMAs hidden from status line
plot(i_useRegime ? emaFast : na, title="EMA Fast", color=color.new(color.blue, 60), linewidth=1, display=display.pane)
plot(i_useRegime ? emaSlow : na, title="EMA Slow", color=color.new(color.red,  60), linewidth=1, display=display.pane)

// Signal quality labels (use time, ATR offset)
if i_showLabels and buySignalW2 and barstate.isconfirmed
    string sq = bull_confW2 >= 80 ? "W2 Strong" : bull_confW2 >= 60 ? "W2 Medium" : "W2 Weak"
    color  sc = bull_confW2 >= 80 ? color.lime  : bull_confW2 >= 60 ? color.yellow : color.orange
    f_addLabel(label.new(time, low - labelOffset, sq,
         xloc=xloc.bar_time, color=sc, textcolor=color.black,
         style=label.style_label_up, size=size.tiny))

if i_showLabels and buySignalW4 and barstate.isconfirmed
    string sq = bull_confW4 >= 80 ? "W4 Strong" : bull_confW4 >= 60 ? "W4 Medium" : "W4 Weak"
    color  sc = bull_confW4 >= 80 ? color.lime  : bull_confW4 >= 60 ? color.yellow : color.orange
    f_addLabel(label.new(time, low - labelOffset, sq,
         xloc=xloc.bar_time, color=sc, textcolor=color.black,
         style=label.style_label_up, size=size.tiny))

if i_showLabels and sellSignalW5 and barstate.isconfirmed
    string sq = bull_confW5 >= 80 ? "W5 Strong" : bull_confW5 >= 60 ? "W5 Medium" : "W5 Weak"
    color  sc = bull_confW5 >= 80 ? color.lime  : bull_confW5 >= 60 ? color.yellow : color.orange
    f_addLabel(label.new(time, high + labelOffset, sq,
         xloc=xloc.bar_time, color=sc, textcolor=color.black,
         style=label.style_label_down, size=size.tiny))

if i_showLabels and shortSignalW2 and barstate.isconfirmed
    string sq = bear_confW2 >= 80 ? "BW2 Strong" : bear_confW2 >= 60 ? "BW2 Medium" : "BW2 Weak"
    color  sc = bear_confW2 >= 80 ? color.lime   : bear_confW2 >= 60 ? color.yellow  : color.orange
    f_addLabel(label.new(time, high + labelOffset, sq,
         xloc=xloc.bar_time, color=sc, textcolor=color.black,
         style=label.style_label_down, size=size.tiny))

if i_showLabels and shortSignalW4 and barstate.isconfirmed
    string sq = bear_confW4 >= 80 ? "BW4 Strong" : bear_confW4 >= 60 ? "BW4 Medium" : "BW4 Weak"
    color  sc = bear_confW4 >= 80 ? color.lime   : bear_confW4 >= 60 ? color.yellow  : color.orange
    f_addLabel(label.new(time, high + labelOffset, sq,
         xloc=xloc.bar_time, color=sc, textcolor=color.black,
         style=label.style_label_down, size=size.tiny))

if i_showLabels and coverSignalW5 and barstate.isconfirmed
    string sq = bear_confW5 >= 80 ? "BW5 Strong" : bear_confW5 >= 60 ? "BW5 Medium" : "BW5 Weak"
    color  sc = bear_confW5 >= 80 ? color.lime   : bear_confW5 >= 60 ? color.yellow  : color.orange
    f_addLabel(label.new(time, low - labelOffset, sq,
         xloc=xloc.bar_time, color=sc, textcolor=color.black,
         style=label.style_label_up, size=size.tiny))

// ============================================================
// SECTION 24: PROJECTION LAYER
// ============================================================

bool bull_w5_active  = bull_state == 5 and not na(bull_w4) and not na(bull_w1) and not na(bull_w0)
bool bear_w5_active  = bear_state == 5 and not na(bear_w4) and not na(bear_w1) and not na(bear_w0)
bool bull_abc_active = bull_state == 6 and not na(bull_w5) and not na(bull_w4)
bool bear_abc_active = bear_state == 6 and not na(bear_w5) and not na(bear_w4)

float bull_tp1 = na, float bull_tp2 = na, float bull_tp3 = na
float bear_tp1 = na, float bear_tp2 = na, float bear_tp3 = na
float bull_aZone = na, float bull_bZone = na, float bull_cZone = na
float bear_aZone = na, float bear_bZone = na, float bear_cZone = na

if i_showProjection
    if bullProjectionInvalid and not na(bullProjBox)
        box.delete(bullProjBox)
        bullProjBox := na
    if bearProjectionInvalid and not na(bearProjBox)
        box.delete(bearProjBox)
        bearProjBox := na
    if bullProjectionInvalid and not na(bullABCBox)
        box.delete(bullABCBox)
        bullABCBox := na
    if bearProjectionInvalid and not na(bearABCBox)
        box.delete(bearABCBox)
        bearABCBox := na

    if bull_w5_active and validBullProjection and not bullProjectionInvalid
        float w1sz = bull_w1 - bull_w0
        bull_tp1 := bull_w4 + w1sz * 1.0
        bull_tp2 := bull_w4 + w1sz * 1.618
        bull_tp3 := bull_w4 + w1sz * 2.618
        if barstate.islast and not na(bull_tp2) and not na(bull_tp3)
            int bLeft  = f_barTime(bull_b4)
            int bRight = int(time) + int(time - time[1]) * 30
            float bTop = math.max(bull_tp2, bull_tp3)
            float bBot = math.min(bull_tp2, bull_tp3)
            if na(bullProjBox)
                bullProjBox := box.new(left=bLeft, top=bTop, right=bRight, bottom=bBot,
                     xloc=xloc.bar_time, border_color=color.new(color.orange, 60), border_width=1,
                     bgcolor=color.new(color.orange, 85))
            else
                box.set_right(bullProjBox, bRight)
                box.set_top(bullProjBox, bTop)
                box.set_bottom(bullProjBox, bBot)

    if bear_w5_active and validBearProjection and not bearProjectionInvalid
        float w1sz = bear_w0 - bear_w1
        bear_tp1 := bear_w4 - w1sz * 1.0
        bear_tp2 := bear_w4 - w1sz * 1.618
        bear_tp3 := bear_w4 - w1sz * 2.618
        if barstate.islast and not na(bear_tp2) and not na(bear_tp3)
            int bLeft  = f_barTime(bear_b4)
            int bRight = int(time) + int(time - time[1]) * 30
            float bTop = math.max(bear_tp2, bear_tp3)
            float bBot = math.min(bear_tp2, bear_tp3)
            if na(bearProjBox)
                bearProjBox := box.new(left=bLeft, top=bTop, right=bRight, bottom=bBot,
                     xloc=xloc.bar_time, border_color=color.new(color.fuchsia, 60), border_width=1,
                     bgcolor=color.new(color.fuchsia, 85))
            else
                box.set_right(bearProjBox, bRight)
                box.set_top(bearProjBox, bTop)
                box.set_bottom(bearProjBox, bBot)

    if i_showABCZones and bull_abc_active and not bullProjectionInvalid
        float w5sz = bull_w5 - bull_w4
        bull_aZone := bull_w5 - w5sz * 0.382
        bull_bZone := bull_w5 - w5sz * 0.618
        bull_cZone := bull_w5 - w5sz * 1.0
        if barstate.islast and not na(bull_aZone) and not na(bull_cZone)
            int bLeft  = f_barTime(bull_b5)
            int bRight = int(time) + int(time - time[1]) * 30
            float bTop = math.max(bull_aZone, bull_cZone)
            float bBot = math.min(bull_aZone, bull_cZone)
            if na(bullABCBox)
                bullABCBox := box.new(left=bLeft, top=bTop, right=bRight, bottom=bBot,
                     xloc=xloc.bar_time, border_color=color.new(color.yellow, 60), border_width=1,
                     bgcolor=color.new(color.yellow, 88))
            else
                box.set_right(bullABCBox, bRight)
                box.set_top(bullABCBox, bTop)
                box.set_bottom(bullABCBox, bBot)

    if i_showABCZones and bear_abc_active and not bearProjectionInvalid
        float w5sz = bear_w4 - bear_w5
        bear_aZone := bear_w5 + w5sz * 0.382
        bear_bZone := bear_w5 + w5sz * 0.618
        bear_cZone := bear_w5 + w5sz * 1.0
        if barstate.islast and not na(bear_aZone) and not na(bear_cZone)
            int bLeft  = f_barTime(bear_b5)
            int bRight = int(time) + int(time - time[1]) * 30
            float bTop = math.max(bear_aZone, bear_cZone)
            float bBot = math.min(bear_aZone, bear_cZone)
            if na(bearABCBox)
                bearABCBox := box.new(left=bLeft, top=bTop, right=bRight, bottom=bBot,
                     xloc=xloc.bar_time, border_color=color.new(color.aqua, 60), border_width=1,
                     bgcolor=color.new(color.aqua, 88))
            else
                box.set_right(bearABCBox, bRight)
                box.set_top(bearABCBox, bTop)
                box.set_bottom(bearABCBox, bBot)

    if i_showGuideLine and barstate.islast
        if bull_w5_active and not na(bull_tp2) and validBullProjection
            int nbt = int(time) + int(time - time[1]) * 20
            f_addLine(line.new(f_barTime(bull_b4), bull_w4, nbt, bull_tp2,
                 xloc=xloc.bar_time, color=color.new(color.orange, 60),
                 width=1, style=line.style_dotted))
        if bear_w5_active and not na(bear_tp2) and validBearProjection
            int nbt = int(time) + int(time - time[1]) * 20
            f_addLine(line.new(f_barTime(bear_b4), bear_w4, nbt, bear_tp2,
                 xloc=xloc.bar_time, color=color.new(color.orange, 60),
                 width=1, style=line.style_dotted))

// V2.5: Projection plots hidden from status line
plot(not bullProjectionInvalid ? bull_tp1 : na, title="Bull TP1", color=color.new(color.yellow, 30), linewidth=1, style=plot.style_linebr, display=display.pane)
plot(not bullProjectionInvalid ? bull_tp2 : na, title="Bull TP2", color=color.new(color.orange, 30), linewidth=1, style=plot.style_linebr, display=display.pane)
plot(not bullProjectionInvalid ? bull_tp3 : na, title="Bull TP3", color=color.new(color.red,    30), linewidth=1, style=plot.style_linebr, display=display.pane)
plot(not bearProjectionInvalid ? bear_tp1 : na, title="Bear TP1", color=color.new(color.yellow, 30), linewidth=1, style=plot.style_linebr, display=display.pane)
plot(not bearProjectionInvalid ? bear_tp2 : na, title="Bear TP2", color=color.new(color.orange, 30), linewidth=1, style=plot.style_linebr, display=display.pane)
plot(not bearProjectionInvalid ? bear_tp3 : na, title="Bear TP3", color=color.new(color.red,    30), linewidth=1, style=plot.style_linebr, display=display.pane)
plot(bull_aZone, title="Bull A", color=color.new(color.yellow, 50), linewidth=1, style=plot.style_circles, display=display.pane)
plot(bull_bZone, title="Bull B", color=color.new(color.orange, 50), linewidth=1, style=plot.style_circles, display=display.pane)
plot(bull_cZone, title="Bull C", color=color.new(color.red,    50), linewidth=1, style=plot.style_circles, display=display.pane)
plot(bear_aZone, title="Bear A", color=color.new(color.yellow, 50), linewidth=1, style=plot.style_circles, display=display.pane)
plot(bear_bZone, title="Bear B", color=color.new(color.orange, 50), linewidth=1, style=plot.style_circles, display=display.pane)
plot(bear_cZone, title="Bear C", color=color.new(color.red,    50), linewidth=1, style=plot.style_circles, display=display.pane)

string projectionStrength = "None"
float  projectionConf     = 0.0

if bull_w5_active and validBullProjection
    projectionConf := bull_confW4
    if bull_confW4 >= 80
        projectionStrength := "Strong"
    else if bull_confW4 >= 60
        projectionStrength := "Medium"
    else
        projectionStrength := "Weak"
else if bear_w5_active and validBearProjection
    projectionConf := bear_confW4
    if bear_confW4 >= 80
        projectionStrength := "Strong"
    else if bear_confW4 >= 60
        projectionStrength := "Medium"
    else
        projectionStrength := "Weak"
else if bull_abc_active
    projectionConf := bull_confW5
    if bull_confW5 >= 80
        projectionStrength := "Strong"
    else if bull_confW5 >= 60
        projectionStrength := "Medium"
    else
        projectionStrength := "Weak"
else if bear_abc_active
    projectionConf := bear_confW5
    if bear_confW5 >= 80
        projectionStrength := "Strong"
    else if bear_confW5 >= 60
        projectionStrength := "Medium"
    else
        projectionStrength := "Weak"

// ============================================================
// SECTION 25: DASHBOARD (V2.5: simplified, larger text)
// ============================================================

if i_showDashboard and barstate.islast
    var table dash = table.new(position.top_right, 2, 10,
         bgcolor=color.new(color.black, 15),
         border_color=color.gray, border_width=1,
         frame_color=color.gray, frame_width=1)

    // Header
    table.cell(dash, 0, 0, "Elliott Wave V2.5", text_color=color.white, bgcolor=color.new(color.blue, 30), text_size=size.normal)
    table.cell(dash, 1, 0, "Status",            text_color=color.white, bgcolor=color.new(color.blue, 30), text_size=size.normal)

    // Asset
    table.cell(dash, 0, 1, "Asset", text_color=color.silver, text_size=size.normal)
    table.cell(dash, 1, 1, assetClass, text_color=color.white, text_size=size.normal)

    // Timeframe
    string htfTxt = higherTF != "" ? " / " + higherTF : ""
    table.cell(dash, 0, 2, "TF", text_color=color.silver, text_size=size.normal)
    table.cell(dash, 1, 2, timeframe.period + htfTxt, text_color=color.white, text_size=size.normal)

    // Trend
    string trendTxt = "Choppy"
    color  trendCol = color.orange
    if isValidBullRegime
        trendTxt := "Bull Trend"
        trendCol := color.lime
    else if isValidBearRegime
        trendTxt := "Bear Trend"
        trendCol := color.red
    table.cell(dash, 0, 3, "Trend", text_color=color.silver, text_size=size.normal)
    table.cell(dash, 1, 3, trendTxt, text_color=trendCol, text_size=size.normal)

    // Bull state
    string bst = "Idle"
    if bull_state == 1
        bst := "W1"
    else if bull_state == 2
        bst := "W2 building"
    else if bull_state == 3
        bst := "W2 done"
    else if bull_state == 4
        bst := "W3 done"
    else if bull_state == 5
        bst := "W4 done"
    else if bull_state == 6
        bst := "W5 done"
    table.cell(dash, 0, 4, "Bull", text_color=color.silver, text_size=size.normal)
    table.cell(dash, 1, 4, bst, text_color=color.lime, text_size=size.normal)

    // Bear state
    string brt = "Idle"
    if bear_state == 1
        brt := "W1"
    else if bear_state == 2
        brt := "W2 building"
    else if bear_state == 3
        brt := "W2 done"
    else if bear_state == 4
        brt := "W3 done"
    else if bear_state == 5
        brt := "W4 done"
    else if bear_state == 6
        brt := "W5 done"
    table.cell(dash, 0, 5, "Bear", text_color=color.silver, text_size=size.normal)
    table.cell(dash, 1, 5, brt, text_color=color.red, text_size=size.normal)

    // Bull conf
    float bcs = 0.0
    if bull_state == 3
        bcs := bull_confW2
    else if bull_state == 5
        bcs := bull_confW4
    else if bull_state == 6
        bcs := bull_confW5
    table.cell(dash, 0, 6, "Bull Conf", text_color=color.silver, text_size=size.normal)
    table.cell(dash, 1, 6, str.tostring(math.round(bcs)) + "%", text_color=f_confColor(bcs), text_size=size.normal)

    // Bear conf
    float rcs = 0.0
    if bear_state == 3
        rcs := bear_confW2
    else if bear_state == 5
        rcs := bear_confW4
    else if bear_state == 6
        rcs := bear_confW5
    table.cell(dash, 0, 7, "Bear Conf", text_color=color.silver, text_size=size.normal)
    table.cell(dash, 1, 7, str.tostring(math.round(rcs)) + "%", text_color=f_confColor(rcs), text_size=size.normal)

    // Projection
    color projCol = color.gray
    if projectionStrength == "Strong"
        projCol := color.lime
    else if projectionStrength == "Medium"
        projCol := color.yellow
    else if projectionStrength == "Weak"
        projCol := color.orange
    string projTxt = "None"
    if projectionStrength != "None"
        projTxt := projectionStrength + " [" + str.tostring(math.round(projectionConf)) + "%]"
    table.cell(dash, 0, 8, "Projection", text_color=color.silver, text_size=size.normal)
    table.cell(dash, 1, 8, projTxt, text_color=projCol, text_size=size.normal)

    // Bias
    string biasTxt = "Neutral"
    color  biasCol = color.gray
    if bull_w5_active
        biasTxt := "Bull W5 forming"
        biasCol := color.lime
    else if bear_w5_active
        biasTxt := "Bear W5 forming"
        biasCol := color.red
    else if bull_abc_active
        biasTxt := "Bull ABC pullback"
        biasCol := color.yellow
    else if bear_abc_active
        biasTxt := "Bear ABC bounce"
        biasCol := color.aqua
    table.cell(dash, 0, 9, "Bias", text_color=color.silver, text_size=size.normal)
    table.cell(dash, 1, 9, biasTxt, text_color=biasCol, text_size=size.normal)

// ============================================================
// SECTION 26: ALERTS
// ============================================================

alertcondition(buySignalW2,   title="EW: Buy W2",   message="EW V2.5: Long W2 on {{ticker}} {{interval}}")
alertcondition(buySignalW4,   title="EW: Buy W4",   message="EW V2.5: Long W4 on {{ticker}} {{interval}}")
alertcondition(sellSignalW5,  title="EW: Sell W5",  message="EW V2.5: Sell W5 on {{ticker}} {{interval}}")
alertcondition(shortSignalW2, title="EW: Short W2", message="EW V2.5: Short W2 on {{ticker}} {{interval}}")
alertcondition(shortSignalW4, title="EW: Short W4", message="EW V2.5: Short W4 on {{ticker}} {{interval}}")
alertcondition(coverSignalW5, title="EW: Cover W5", message="EW V2.5: Cover W5 on {{ticker}} {{interval}}")
````
