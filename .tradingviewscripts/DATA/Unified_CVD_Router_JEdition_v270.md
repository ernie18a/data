<!-- tradingview-pine-id: PUB;36ac700813b54018a17ed4d4ba25ead7 -->
<!-- tradingviewscripts-format: 1 -->
# Unified CVD Router J-Edition v2.7.0

Source: https://www.tradingview.com/script/YOXuU4IO-Unified-CVD-Router-J-Edition-v2-7-0/

## Description

Overview:

The Unified CVD Router J-Edition is an experimental indicator designed to provide a significantly more accurate Cumulative Volume Delta (CVD) estimation than TradingView’s standard built-in methodology when you are constrained by non-Professional plan limits (specifically, using 1-second (1S) as the lowest lower-timeframe calculation resolution).

Standard synthetic CVD indicators rely on basic bar-color or tick-direction assumptions. This script replaces those primitive rules with sub-bar econometric modeling and probabilistic inference to better estimate aggressive buying and selling pressure.

Key Features:

Multi-Engine 1S Sub-Bar Router: Evaluates sub-bar volume through Geometric, Bulk Volume Classification (BVC), and Flow engines.

Distrust & Jump Layers: Employs Bipower Variation and Hawkes excitation intensity to isolate hidden liquidity ("icebergs"), market jumps, and auction open/close distortions.

Bayesian Soft-Routing: Dynamically calculates the probability of passive absorption versus directional flow to weight delta estimations smoothly.

Effort vs. Result Overlays: Incorporates Amihud illiquidity and Kyle’s Lambda market impact models at the chart-bar level to gauge how effectively volume moves price.

Experimental Notice & Disclaimer:

This script is experimental and does not claim to represent absolute "ground truth."

Because non-Professional TradingView plans lack true tick-by-tick aggressor tagging and tick charts, this indicator uses advanced statistical modeling to infer delta. It is an algorithmic approximation, not a direct replacement for native Level 2 execution feeds.

Call for Testing & Benchmarking:

I welcome feedback and testing from the community! Because this is an ongoing experiment in order flow modeling, it needs to be benchmarked against true tick data.

It would be especially helpful if users with access to the following could compare results and share insights in the comments:

TradingView Ultimate Plan users using the built-in CVD on a 1-tick (1T) resolution.

Dedicated Order Flow Platforms with direct tick feeds (such as ATAS, Sierra Chart, or Bookmap).

---

## Source Code

````pine
//@version=6
indicator("Unified CVD Router J-Edition v2.7.0", "CVD Router J-Ed v2.7.0", format = format.volume, precision = 0)

// ============================================================================
// CVD Router v2.7.0
// Core design:
//   1) 1S lower-timeframe synthetic delta router
//   2) distrust layers for hidden liquidity / jumps / auction windows
//   3) chart-bar effort-vs-result and path-shape overlays
//   4) optional chart-bar Hamilton regime multiplier
//
// Notes:
// - This script intentionally avoids request.footprint() and native footprint
//   methods. It relies on custom 1S OHLCV routing.
// - request.security_lower_tf() can still repaint slightly because TradingView's
//   realtime and historical intrabar feeds may differ.
// ============================================================================

// ----------------------------------------------------------------------------
// INPUT GROUPS
// ----------------------------------------------------------------------------
grpTF      = "Timeframe & Resolution"
grpRoute   = "Router"
grpGeo     = "Geometric Engine"
grpSLD     = "Liquidity Density Regime"
grpBVC     = "BVC Engine"
grpFlow    = "Flow Engine"
grpSweep   = "Aggressive Sweep Markers"
grpJump    = "Advanced — Jump Layer"
grpHawk    = "Advanced — Hawkes Excitation"
grpBayes   = "Advanced — Bayesian Soft-Router"
grpRob     = "Advanced — Robust SLD"
grpCap     = "Advanced — Auction Guard"
grpSess    = "Advanced — Session Windows"
grpXR      = "Cross-Pollinated Upgrades"
grpVis     = "Visuals"

// ----------------------------------------------------------------------------
// INPUTS
// ----------------------------------------------------------------------------
anchorInput = input.timeframe("1D", "CVD Reset Period", group = grpTF)
lowerTimeframe = input.timeframe("1S", "Calculation Resolution", group = grpTF, tooltip = "Designed for 1-second lower-timeframe routing on Premium plan constraints.")

routeMode = input.string("Auto (shape vs BVC)", "Routing Mode",
     options = ["Auto (shape vs BVC)", "Flow (ATAS-style)", "Bayesian soft-route", "Geometric only", "BVC only"],
     group = grpRoute)

shapelessEngine = input.string("Flow (range + carry)", "Auto: shapeless-bar engine",
     options = ["BVC", "Flow (range + carry)"], group = grpRoute,
     tooltip = "Recommended default for liquid US equities: Flow. BVC remains available and is strongest when used through the volume clock.")

trustGeoInAbsorption = input.bool(true, "Force geometric in absorption regime", group = grpRoute)
flagDisagreement = input.bool(true, "Flag engine disagreement", group = grpRoute)

lookbackLength = input.int(36, "Z-Score lookback (1S bars)", minval = 10, group = grpGeo)
wickGamma = input.float(0.6, "Wick sensitivity multiplier", minval = 0.1, maxval = 2.0, step = 0.1, group = grpGeo)
maruMinTicks = input.int(3, "Marubozu min range (ticks)", minval = 1, group = grpGeo)
maruAbsorbConv = input.float(0.70, "Marubozu conviction in absorption", minval = 0.50, maxval = 1.0, step = 0.05, group = grpGeo)
maruNormalConv = input.float(0.95, "Marubozu conviction normal / sweep", minval = 0.50, maxval = 1.0, step = 0.05, group = grpGeo)

absThreshold = input.float(1.9, "Absorption threshold", minval = 0.5, maxval = 3.5, step = 0.1, group = grpSLD)
icebergThreshold = input.float(3.2, "Hidden-liquidity distrust threshold", minval = 1.5, maxval = 6.0, step = 0.1, group = grpSLD)
sweepThreshold = input.float(-1.0, "Vacuum sweep threshold", minval = -3.0, maxval = -0.1, step = 0.1, group = grpSLD)
sldLookback = input.int(18, "SLD z-score lookback", minval = 10, group = grpSLD)
betaArchetypeScale = input.float(0.5, "Beta amplification on archetypes", minval = 0.0, maxval = 1.0, step = 0.1, group = grpSLD)

sigmaLen = input.int(48, "BVC return-volatility lookback", minval = 10, group = grpBVC)
bvcDist = input.string("Student-t (fat tails)", "BVC distribution", options = ["Student-t (fat tails)", "Logistic (normal approx)"], group = grpBVC)
bvcNu = input.float(0.50, "Student-t degrees of freedom", minval = 0.05, maxval = 5.0, step = 0.05, group = grpBVC)
cdfConst = input.float(1.30, "Logistic CDF constant", minval = 1.0, maxval = 1.9, step = 0.01, group = grpBVC)
bvcScaleMode = input.string("Bipower (jump-robust)", "BVC scale estimator",
     options = ["MAD (robust)", "Bipower (jump-robust)", "Stdev"], group = grpBVC)
bvcWarmupNeutral = input.bool(true, "Neutralize BVC until buffer warm", group = grpBVC)
bvcAggMode = input.string("Volume clock (ELO)", "BVC aggregation",
     options = ["Per 1S bar", "Volume clock (ELO)"], group = grpBVC)
vcBucketMult = input.float(6.0, "Volume-clock bucket (x median 1S volume)", minval = 2.0, maxval = 50.0, step = 1.0, group = grpBVC)

flowClassMode = input.string("Continuous CLV (proportional)", "Sub-bar classification rule",
     options = ["Continuous CLV (proportional)", "Binary close vs open (bar color)", "Strict tick rule (up/down-tick)", "Hybrid CLNV (zone + tick rule)"],
     group = grpFlow)
flowClvGamma = input.float(0.75, "CLV shaping exponent", minval = 0.1, maxval = 3.0, step = 0.05, group = grpFlow)
flowClnvZone = input.float(0.30, "CLNV one-sided zone", minval = 0.05, maxval = 0.50, step = 0.05, group = grpFlow)
flowZeroRange = input.string("Own tick only (no carry)", "Zero-range volume handling",
     options = ["Tick sign + carry (legacy)", "Own tick only (no carry)", "Exclude (0 delta)"], group = grpFlow)
flowVolFilterMode = input.string("Off", "Min-volume block filter",
     options = ["Off", "Absolute", "x median 1S volume"], group = grpFlow)
flowVolFilterAbs = input.float(500.0, "Absolute volume floor", minval = 0.0, group = grpFlow)
flowVolFilterMult = input.float(2.0, "Adaptive floor (x median 1S volume)", minval = 0.1, maxval = 50.0, step = 0.1, group = grpFlow)

showSweeps = input.bool(false, "Show aggressive-sweep markers on the price chart", group = grpSweep)
sweepImbalance = input.float(0.80, "Min one-sided volume fraction", minval = 0.50, maxval = 1.0, step = 0.05, group = grpSweep)
sweepVolZ = input.float(2.0, "Volume outlier z (robust)", minval = 0.5, maxval = 6.0, step = 0.25, group = grpSweep)

useJumpFilter = input.bool(true, "Enable jump filter", group = grpJump)
jumpZThresh = input.float(4.25, "Jump threshold k", minval = 2.0, maxval = 8.0, step = 0.25, group = grpJump)
distrustJumpsBVC = input.bool(true, "Route jump bars to geometric", group = grpJump)

useHawkes = input.bool(true, "Enable Hawkes distrust intensity", group = grpHawk)
hawkesMu = input.float(0.03, "Hawkes baseline", minval = 0.0, maxval = 1.0, step = 0.01, group = grpHawk)
hawkesPhi = input.float(0.75, "Hawkes persistence", minval = 0.0, maxval = 0.99, step = 0.01, group = grpHawk)
hawkesKappa = input.float(0.65, "Hawkes excitation", minval = 0.0, maxval = 2.0, step = 0.05, group = grpHawk)
hawkesTrigger = input.float(1.0, "Hawkes distrust trigger", minval = 0.1, maxval = 3.0, step = 0.05, group = grpHawk)

bayesP00 = input.float(0.93, "P(stay directional)", minval = 0.50, maxval = 0.999, step = 0.01, group = grpBayes)
bayesP11 = input.float(0.85, "P(stay absorption)", minval = 0.50, maxval = 0.999, step = 0.01, group = grpBayes)
bayesVolRatio = input.float(0.35, "Absorption / continuous vol ratio", minval = 0.1, maxval = 0.99, step = 0.05, group = grpBayes)
bayesShapeGate = input.bool(true, "Bayesian: hard-route shaped bars to geometric", group = grpBayes)

sldRobust = input.bool(true, "Robust SLD scaling (median/MAD)", group = grpRob)

useDeltaCap = input.bool(true, "Cap sub-bar |delta| vs median volume", group = grpCap)
capMult = input.float(40.0, "Cap multiple (x median 1S volume)", minval = 5.0, maxval = 200.0, step = 5.0, group = grpCap)
capLookback = input.int(40, "Volume median lookback", minval = 20, maxval = 300, group = grpCap)
reanchorOpen = input.bool(true, "Re-anchor guard median at RTH open", group = grpCap)

useSessionDistrust = input.bool(true, "Distrust open/close auction windows", group = grpSess)
sessRouteGeo = input.bool(true, "Route window bars to geometric", group = grpSess)
openWindowSess = input.session("0930-0931", "RTH-open distrust window", group = grpSess)
closeWindowSess = input.session("1555-1601", "Closing-auction distrust window", group = grpSess)
sessTz = input.string("America/New_York", "Window timezone", group = grpSess)

useEffort = input.bool(true, "Enable effort-vs-result overlay", group = grpXR, tooltip = "Amihud + Kyle-style impact overlay at the chart-bar level.")
effBaseLen = input.int(16, "Effort baseline length", minval = 4, group = grpXR)
effMin = input.float(0.50, "Min effort multiplier", minval = 0.1, maxval = 2.0, step = 0.05, group = grpXR)
effMax = input.float(1.75, "Max effort multiplier", minval = 0.5, maxval = 4.0, step = 0.05, group = grpXR)

useShapeTilt = input.bool(true, "Enable VR / jump-share shape tilt", group = grpXR)
shapeBaseLen = input.int(16, "Shape baseline length", minval = 4, group = grpXR)
shapeGain = input.float(0.45, "Shape tilt gain", minval = 0.0, maxval = 2.0, step = 0.05, group = grpXR)

useRegimeFilter = input.bool(true, "Enable chart-bar Hamilton regime filter", group = grpXR)
regStates = input.int(2, "Regime states", minval = 2, maxval = 3, group = grpXR)
regStay = input.float(0.90, "Regime stay probability", minval = 0.50, maxval = 0.999, step = 0.01, group = grpXR)
regGain = input.float(0.60, "Regime routing gain", minval = 0.0, maxval = 2.0, step = 0.05, group = grpXR)
regLen = input.int(48, "Regime moment length", minval = 16, group = grpXR)

showDivergence = input.bool(true, "Show price / delta divergence", group = grpVis)
showAbsorptionFlag = input.bool(true, "Flag hidden-liquidity bars (purple bg)", group = grpVis)

// ----------------------------------------------------------------------------
// CONSTANTS AND GENERIC HELPERS
// ----------------------------------------------------------------------------
float BIG = 1e100
float EPS = 1e-12
float PI_OVER_2 = 1.5707963267948966

isFinite(float x) =>
    not na(x) and math.abs(x) < BIG

clampf(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

safeDiv(float num, float den, float fallback) =>
    isFinite(num) and isFinite(den) and math.abs(den) > EPS ? num / den : fallback

logNormPdf(float y, float mu, float sd) =>
    float ss = math.max(nz(sd, 1.0), 1e-8)
    float z = (nz(y, 0.0) - nz(mu, 0.0)) / ss
    -0.9189385332046727 - math.log(ss) - 0.5 * z * z

pushTrim(array<float> arr, float v, int maxLen) =>
    array.push(arr, v)
    if array.size(arr) > maxLen
        array.shift(arr)

arrMean(array<float> arr) =>
    int n = array.size(arr)
    float out = na
    if n > 0
        float s = 0.0
        for i = 0 to n - 1
            s += array.get(arr, i)
        out := s / n
    out

arrStdev(array<float> arr, float meanVal) =>
    int n = array.size(arr)
    float out = na
    if n > 1 and isFinite(meanVal)
        float ss = 0.0
        for i = 0 to n - 1
            float d = array.get(arr, i) - meanVal
            ss += d * d
        out := math.sqrt(ss / n)
    out

gammaln(float xx) =>
    float x = xx
    float y = xx
    float tmp = x + 5.5
    tmp := tmp - (x + 0.5) * math.log(tmp)
    float ser = 1.000000000190015
    ser += 76.18009172947146 / (y + 1.0)
    ser += -86.50532032941677 / (y + 2.0)
    ser += 24.01409824083091 / (y + 3.0)
    ser += -1.231739572450155 / (y + 4.0)
    ser += 0.001208650973866179 / (y + 5.0)
    ser += -0.000005395239384953 / (y + 6.0)
    math.log(2.5066282746310005 * ser / x) - tmp

betacf(float a, float b, float x) =>
    float FPMIN = 1.0e-30
    float BEPS = 3.0e-7
    float qab = a + b
    float qap = a + 1.0
    float qam = a - 1.0
    float c = 1.0
    float d = 1.0 - qab * x / qap
    if math.abs(d) < FPMIN
        d := FPMIN
    d := 1.0 / d
    float h = d
    for m = 1 to 100
        float fm = m
        float m2 = 2.0 * fm
        float aa = fm * (b - fm) * x / ((qam + m2) * (a + m2))
        d := 1.0 + aa * d
        if math.abs(d) < FPMIN
            d := FPMIN
        c := 1.0 + aa / c
        if math.abs(c) < FPMIN
            c := FPMIN
        d := 1.0 / d
        h *= d * c
        aa := -(a + fm) * (qab + fm) * x / ((a + m2) * (qap + m2))
        d := 1.0 + aa * d
        if math.abs(d) < FPMIN
            d := FPMIN
        c := 1.0 + aa / c
        if math.abs(c) < FPMIN
            c := FPMIN
        d := 1.0 / d
        float del = d * c
        h *= del
        if math.abs(del - 1.0) < BEPS
            break
    h

betaiReg(float a, float b, float x) =>
    float out = 0.0
    if x <= 0.0
        out := 0.0
    else if x >= 1.0
        out := 1.0
    else
        float bt = math.exp(gammaln(a + b) - gammaln(a) - gammaln(b) + a * math.log(x) + b * math.log(1.0 - x))
        out := x < (a + 1.0) / (a + b + 2.0) ? bt * betacf(a, b, x) / a : 1.0 - bt * betacf(b, a, 1.0 - x) / b
    out

studentTCDF(float z, float nu) =>
    float out = 0.5
    if isFinite(z) and isFinite(nu) and nu > 0.0
        float xib = nu / (nu + z * z)
        float tailHalf = 0.5 * betaiReg(nu / 2.0, 0.5, xib)
        out := z >= 0.0 ? 1.0 - tailHalf : tailHalf
    out

phiApprox(float z) =>
    float x = clampf(cdfConst * z, -60.0, 60.0)
    1.0 / (1.0 + math.exp(-x))

bvcBuyFrac(float z) =>
    bvcDist == "Student-t (fat tails)" ? studentTCDF(z, bvcNu) : phiApprox(z)

// ----------------------------------------------------------------------------
// LOWER-TIMEFRAME ENGINE
// Returns per 1S bar:
// [chosenDelta, geoDir, bvcDir, bothRan, iceberg, jumpFlag, pAbsorb*100,
//  lambdaPrior*100, rvbvRatio, sweepFlag, flowFilteredVol, sessFlag, logRet]
// ----------------------------------------------------------------------------
calcRoutedDelta() =>
    float geomEps = 1e-12
    float tinyProb = 1e-300
    float tickSize = math.max(syminfo.mintick, 1e-12)

    bool validOHLC = not na(open) and not na(high) and not na(low) and not na(close) and high >= low
    float tr = validOHLC ? high - low : na
    float vol = math.max(nz(volume), 0.0)

    float bodyTop = validOHLC ? math.max(open, close) : na
    float bodyBot = validOHLC ? math.min(open, close) : na
    float upperWick = validOHLC ? math.max(high - bodyTop, 0.0) : na
    float lowerWick = validOHLC ? math.max(bodyBot - low, 0.0) : na

    float meanUw = ta.sma(upperWick, lookbackLength)
    float stdUw = ta.stdev(upperWick, lookbackLength)
    float meanLw = ta.sma(lowerWick, lookbackLength)
    float stdLw = ta.stdev(lowerWick, lookbackLength)

    var float[] sldArr = array.new_float(0)
    var float[] sldDevArr = array.new_float(0)
    var float sldMedC = 0.0
    var float sldRobC = 0.0
    var float sldSumC = 0.0
    var float sldSqSumC = 0.0
    var int sldPushes = 0

    var float[] retArr = array.new_float(0)
    var float[] retDevArr = array.new_float(0)
    var float retMedC = 0.0
    var float madRawC = 0.0
    var float retSumC = 0.0
    var float retSqSumC = 0.0
    var float bvPairSumC = 0.0
    var float stdevSigmaC = 0.0
    var float rvEventC = 0.0
    var float bvEventC = 0.0
    var float rvbvRatioC = 1.0
    var int retPushes = 0

    var float[] volArr = array.new_float(0)
    var float[] volDevArr = array.new_float(0)
    var float medVolC = 0.0
    var float volMadC = 0.0
    var int volPushes = 0

    var float xi1 = 0.5
    var float lambdaH = hawkesMu
    var int flowCarry = 0

    var float vcVol = 0.0
    var float vcRetSum = 0.0
    var int vcBars = 0

    bool rthNow = session.ismarket
    var bool prevRth = false
    bool modelReset = timeframe.change(anchorInput)

    if modelReset
        array.clear(sldArr)
        array.clear(sldDevArr)
        sldMedC := 0.0
        sldRobC := 0.0
        sldSumC := 0.0
        sldSqSumC := 0.0
        sldPushes := 0

        array.clear(retArr)
        array.clear(retDevArr)
        retMedC := 0.0
        madRawC := 0.0
        retSumC := 0.0
        retSqSumC := 0.0
        bvPairSumC := 0.0
        stdevSigmaC := 0.0
        rvEventC := 0.0
        bvEventC := 0.0
        rvbvRatioC := 1.0
        retPushes := 0

        array.clear(volArr)
        array.clear(volDevArr)
        medVolC := 0.0
        volMadC := 0.0
        volPushes := 0

        xi1 := 0.5
        lambdaH := hawkesMu
        flowCarry := 0
        vcVol := 0.0
        vcRetSum := 0.0
        vcBars := 0
        prevRth := rthNow

    bool rthFirstBar = session.isfirstbar_regular
    bool sessChanged = rthNow != prevRth
    prevRth := rthNow

    bool inOpenWin = useSessionDistrust and not na(time(timeframe.period, openWindowSess, sessTz))
    bool inCloseWin = useSessionDistrust and not na(time(timeframe.period, closeWindowSess, sessTz))
    bool sessionDistrust = inOpenWin or inCloseWin
    bool sessForceGeo = sessionDistrust and sessRouteGeo

    // --- SLD scored against prior committed baseline ---
    float rangeTicks = validOHLC ? tr / tickSize : na
    bool sldValid = validOHLC and (vol > 0.0 or tr > 0.0)
    float sld = sldValid ? vol / math.max(rangeTicks, 1.0) : 0.0

    int nSldPrior = array.size(sldArr)
    bool sldWarm = nSldPrior >= sldLookback
    float zSld = 0.0
    if sldValid and sldWarm
        if sldRobust
            zSld := sldRobC > 0.0 ? (sld - sldMedC) / sldRobC : 0.0
        else
            float sldMeanPrior = nSldPrior > 0 ? sldSumC / nSldPrior : 0.0
            float sldVarPrior = nSldPrior > 1 ? math.max(sldSqSumC / nSldPrior - sldMeanPrior * sldMeanPrior, 0.0) : 0.0
            float sldSdPrior = math.sqrt(sldVarPrior)
            zSld := sldSdPrior > 0.0 ? (sld - sldMeanPrior) / sldSdPrior : 0.0

    bool icebergSuspect = vol > 0.0 and zSld >= icebergThreshold

    float prevHigh = modelReset ? na : high[1]
    float prevLow = modelReset ? na : low[1]
    float prevClose = modelReset ? na : close[1]

    float logRet = validOHLC and not na(prevClose) and prevClose > 0.0 and close > 0.0 ? math.log(close / prevClose) : na
    bool hasEvent = not na(logRet) and vol > 0.0
    bool nonZeroRet = hasEvent and logRet != 0.0

    int nRetPrior = array.size(retArr)
    bool bufWarm = nRetPrior >= sigmaLen

    float robustSigma = 1.4826 * madRawC
    float bipowerSigma = math.sqrt(math.max(bvEventC, 0.0))
    bool jumpFlag = nonZeroRet and bufWarm and bipowerSigma > 0.0 and math.abs(logRet) >= jumpZThresh * bipowerSigma
    bool jumpSuspect = useJumpFilter and jumpFlag

    float tickRet = validOHLC and close > 0.0 ? tickSize / close : 0.0
    float scaleFloor = math.max(0.5 * tickRet, 0.25 * bipowerSigma)
    float chosenScale = bvcScaleMode == "Bipower (jump-robust)" ? bipowerSigma : bvcScaleMode == "Stdev" ? stdevSigmaC : robustSigma
    float bvcSigma = math.max(chosenScale, scaleFloor)

    float zRet = 0.0
    bool zValid = hasEvent and (bufWarm or not bvcWarmupNeutral) and bvcSigma > 0.0
    if zValid
        zRet := logRet / bvcSigma

    float bvcDelta = na
    int bvcDir = 0
    if zValid
        bvcDir := zRet > 0.0 ? 1 : zRet < 0.0 ? -1 : 0
        bool needPerBarBvcMagnitude = routeMode == "Bayesian soft-route" or
             (bvcAggMode == "Per 1S bar" and (routeMode == "BVC only" or (routeMode == "Auto (shape vs BVC)" and shapelessEngine == "BVC")))
        if needPerBarBvcMagnitude
            float buyFracBvc = clampf(bvcBuyFrac(zRet), 0.0, 1.0)
            bvcDelta := vol * (2.0 * buyFracBvc - 1.0)
        else if hasEvent and logRet == 0.0
            bvcDelta := 0.0

    // --- Bayesian posterior: zero-return volume bars are valid absorption evidence ---
    float pAbsorb = xi1
    if zValid
        float xi1p = xi1
        float xi0p = 1.0 - xi1p
        float pred0 = bayesP00 * xi0p + (1.0 - bayesP11) * xi1p
        float pred1 = (1.0 - bayesP00) * xi0p + bayesP11 * xi1p

        float rho = bayesVolRatio
        float logNum0 = math.log(math.max(pred0, tinyProb)) - 0.5 * zRet * zRet
        float logNum1 = math.log(math.max(pred1, tinyProb)) - math.log(rho) - zRet * zRet / (2.0 * rho * rho)

        float logMax = math.max(logNum0, logNum1)
        float num0 = math.exp(logNum0 - logMax)
        float num1 = math.exp(logNum1 - logMax)
        float den = num0 + num1
        xi1 := den > 0.0 ? clampf(num1 / den, 0.01, 0.99) : xi1p
        pAbsorb := xi1

    // --- Hawkes route uses prior committed intensity, then current event is committed later ---
    float lambdaPrior = lambdaH
    bool hawkesDistrust = useHawkes and lambdaPrior >= hawkesTrigger

    // === GEOMETRIC ENGINE ===
    float geoDelta = 0.0
    int geoDir = 0
    bool shaped = false
    if validOHLC and tr > 0.0
        float wBuy = na
        float wSell = na
        float body = math.abs(close - open)
        float uwr = clampf(upperWick / tr, 0.0, 1.0)
        float lwr = clampf(lowerWick / tr, 0.0, 1.0)
        float bodyr = clampf(body / tr, 0.0, 1.0)
        bool bull = close > open
        bool bear = close < open
        float marTol = 0.02
        bool maruShape = uwr <= marTol and lwr <= marTol and rangeTicks >= maruMinTicks

        if maruShape and bull
            float conv = zSld >= absThreshold ? maruAbsorbConv : maruNormalConv
            wBuy := conv
            wSell := 1.0 - conv
        else if maruShape and bear
            float conv = zSld >= absThreshold ? maruAbsorbConv : maruNormalConv
            wSell := conv
            wBuy := 1.0 - conv
        else if bodyr <= 0.01 and uwr <= 0.05 and lwr >= 0.70
            wBuy := 0.80
            wSell := 0.20
        else if bodyr <= 0.01 and uwr >= 0.70 and lwr <= 0.05
            wBuy := 0.20
            wSell := 0.80
        else if bodyr <= 0.05 and uwr >= 0.40 and lwr >= 0.40
            wBuy := 0.50
            wSell := 0.50
        else if uwr <= 0.10 and lwr >= 0.60 and bodyr >= 0.20
            wBuy := close >= open ? 0.75 : 0.60
            wSell := close >= open ? 0.25 : 0.40
        else if uwr >= 0.60 and lwr <= 0.10 and bodyr >= 0.20
            wBuy := close <= open ? 0.25 : 0.40
            wSell := close <= open ? 0.75 : 0.60
        else if not na(prevHigh) and not na(prevLow) and high > prevHigh and low < prevLow and bull and close > prevHigh
            wBuy := math.max(0.60, math.min(1.0, (close - low) / tr))
            wSell := 1.0 - wBuy
        else if not na(prevHigh) and not na(prevLow) and high > prevHigh and low < prevLow and bear and close < prevLow
            wSell := math.max(0.60, math.min(1.0, (high - close) / tr))
            wBuy := 1.0 - wSell
        else if not na(prevHigh) and not na(prevLow) and high <= prevHigh and low >= prevLow
            wBuy := clampf((close - low) / tr, 0.0, 1.0)
            wSell := 1.0 - wBuy

        shaped := not na(wBuy)

        float raw = 0.0
        bool isArchetype = false
        if not na(wBuy)
            raw := vol * (wBuy - wSell)
            isArchetype := true
        else
            float zUw = na(stdUw) or stdUw <= 0.0 ? 0.0 : (upperWick - meanUw) / stdUw
            float zLw = na(stdLw) or stdLw <= 0.0 ? 0.0 : (lowerWick - meanLw) / stdLw
            float aUw = clampf(1.0 + wickGamma * zUw, 0.1, 3.0)
            float aLw = clampf(1.0 + wickGamma * zLw, 0.1, 3.0)
            float wbr = math.max(aLw * (close - low), 0.0)
            float wsr = math.max(aUw * (high - close), 0.0)
            float twr = wbr + wsr
            raw := twr > geomEps ? vol * (wbr - wsr) / twr : 0.0

        float beta = zSld >= absThreshold ? 1.5 : zSld <= sweepThreshold ? 0.5 : 1.0
        float effBeta = isArchetype ? 1.0 + (beta - 1.0) * betaArchetypeScale : beta
        geoDelta := raw * effBeta
        geoDir := geoDelta > 0.0 ? 1 : geoDelta < 0.0 ? -1 : 0

    // === FLOW ENGINE ===
    int ownTick = na(logRet) ? 0 : logRet > 0.0 ? 1 : logRet < 0.0 ? -1 : 0
    int tickSign = ownTick != 0 ? ownTick : flowCarry
    float flowDelta = 0.0
    float flowFilteredVol = 0.0

    int nVolPrior = array.size(volArr)
    bool volWarmPrior = nVolPrior >= 20 and medVolC > 0.0
    float volSigC = 1.4826 * volMadC

    if vol > 0.0 and validOHLC
        bool volFilterActive = flowVolFilterMode == "Absolute" or (flowVolFilterMode == "x median 1S volume" and volWarmPrior)
        float volFloor = flowVolFilterMode == "Absolute" ? flowVolFilterAbs : flowVolFilterMult * medVolC

        if volFilterActive and vol < volFloor
            flowFilteredVol := vol
        else if tr > 0.0
            if flowClassMode == "Binary close vs open (bar color)"
                flowDelta := vol * (close > open ? 1 : close < open ? -1 : tickSign)
            else if flowClassMode == "Strict tick rule (up/down-tick)"
                flowDelta := vol * tickSign
            else if flowClassMode == "Hybrid CLNV (zone + tick rule)"
                float posInRange = clampf((close - low) / tr, 0.0, 1.0)
                flowDelta := posInRange >= 1.0 - flowClnvZone ? vol : posInRange <= flowClnvZone ? -vol : vol * tickSign
            else
                float clv = clampf(((close - low) - (high - close)) / tr, -1.0, 1.0)
                flowDelta := flowClvGamma == 1.0 ? vol * clv : vol * math.sign(clv) * math.pow(math.abs(clv), flowClvGamma)
        else
            if flowZeroRange == "Exclude (0 delta)"
                flowDelta := 0.0
            else if flowZeroRange == "Own tick only (no carry)"
                flowDelta := vol * ownTick
            else
                flowDelta := vol * tickSign

    // === SWEEP MARKERS ===
    int sweepFlag = 0
    if showSweeps and vol > 0.0 and validOHLC and volWarmPrior and volSigC > 0.0 and vol >= medVolC + sweepVolZ * volSigC
        float buyFrac = tr > 0.0 ? clampf((close - low) / tr, 0.0, 1.0) : ownTick > 0 ? 1.0 : ownTick < 0 ? 0.0 : 0.5
        sweepFlag := buyFrac >= sweepImbalance ? 1 : buyFrac <= 1.0 - sweepImbalance ? -1 : 0

    // === ROUTER ===
    float chosen = 0.0
    bool forceGeo = icebergSuspect or (distrustJumpsBVC and jumpSuspect) or hawkesDistrust or sessForceGeo

    float bvcRouteDelta = bvcDelta
    bool vcActive = bvcAggMode == "Volume clock (ELO)" and (routeMode == "BVC only" or (routeMode == "Auto (shape vs BVC)" and shapelessEngine == "BVC"))
    if vcActive
        bool wantBVC = routeMode == "BVC only" or (validOHLC and tr > 0.0 and not shaped and not forceGeo and not (trustGeoInAbsorption and zSld >= absThreshold))
        bool bucketBreak = modelReset or sessChanged or not wantBVC or forceGeo
        if bucketBreak
            vcVol := 0.0
            vcRetSum := 0.0
            vcBars := 0

        if forceGeo
            if routeMode == "BVC only" and zValid
                float fracF = clampf(bvcBuyFrac(zRet), 0.0, 1.0)
                bvcRouteDelta := vol * (2.0 * fracF - 1.0)
            else
                bvcRouteDelta := na
        else if wantBVC and vol > 0.0 and (bufWarm or not bvcWarmupNeutral) and volWarmPrior and bvcSigma > 0.0
            vcVol += vol
            vcBars += 1
            vcRetSum += nz(logRet, 0.0)

            float bucketTarget = vcBucketMult * medVolC
            if bucketTarget > 0.0 and vcVol >= bucketTarget
                float zB = vcRetSum / (bvcSigma * math.sqrt(math.max(vcBars, 1)))
                float fB = clampf(bvcBuyFrac(zB), 0.0, 1.0)
                bvcRouteDelta := vcVol * (2.0 * fB - 1.0)
                vcVol := 0.0
                vcRetSum := 0.0
                vcBars := 0
            else
                bvcRouteDelta := 0.0
        else
            bvcRouteDelta := na
    else
        vcVol := 0.0
        vcRetSum := 0.0
        vcBars := 0

    if routeMode == "Geometric only"
        chosen := geoDelta
    else if routeMode == "BVC only"
        chosen := na(bvcRouteDelta) ? 0.0 : bvcRouteDelta
    else if routeMode == "Flow (ATAS-style)"
        chosen := flowDelta
    else if routeMode == "Bayesian soft-route"
        if not validOHLC or tr <= 0.0
            chosen := 0.0
        else if forceGeo
            chosen := geoDelta
        else if bayesShapeGate and shaped
            chosen := geoDelta
        else
            float bvcComp = na(bvcDelta) ? 0.0 : bvcDelta
            chosen := pAbsorb * geoDelta + (1.0 - pAbsorb) * bvcComp
    else
        if not validOHLC or tr <= 0.0
            chosen := 0.0
        else if shaped
            chosen := geoDelta
        else if forceGeo
            chosen := geoDelta
        else if trustGeoInAbsorption and zSld >= absThreshold
            chosen := geoDelta
        else
            chosen := shapelessEngine == "Flow (range + carry)" ? flowDelta : (na(bvcRouteDelta) ? geoDelta : bvcRouteDelta)

    if useDeltaCap and volWarmPrior
        float capAbs = capMult * medVolC
        chosen := clampf(chosen, -capAbs, capAbs)

    bool bothRan = geoDir != 0 and bvcDir != 0

    // --- Commit current Hawkes state after routing ---
    float excite = icebergSuspect or jumpSuspect ? 1.0 : 0.0
    lambdaH := hawkesMu + hawkesPhi * (lambdaH - hawkesMu) + hawkesKappa * excite

    // --- Commit current observation for future intrabars only ---
    if sldValid
        int nOld = array.size(sldArr)
        array.push(sldArr, sld)
        sldSumC += sld
        sldSqSumC += sld * sld
        if array.size(sldArr) > sldLookback
            float oldSld = array.shift(sldArr)
            sldSumC -= oldSld
            sldSqSumC -= oldSld * oldSld
        sldPushes += 1
        int nNew = array.size(sldArr)
        bool refresh = nNew < sldLookback or (nOld < sldLookback and nNew >= sldLookback) or sldPushes % 2 == 0
        if sldRobust and refresh and nNew > 0
            sldMedC := array.median(sldArr)
            array.clear(sldDevArr)
            for i = 0 to nNew - 1
                array.push(sldDevArr, math.abs(array.get(sldArr, i) - sldMedC))
            sldRobC := nNew > 1 ? 1.4826 * array.median(sldDevArr) : 0.0

    if nonZeroRet
        int nOldRet = array.size(retArr)
        if nOldRet > 0
            float newestRet = array.get(retArr, nOldRet - 1)
            bvPairSumC += math.abs(newestRet) * math.abs(logRet)

        array.push(retArr, logRet)
        retSumC += logRet
        retSqSumC += logRet * logRet

        if array.size(retArr) > sigmaLen
            float oldRet = array.shift(retArr)
            retSumC -= oldRet
            retSqSumC := math.max(retSqSumC - oldRet * oldRet, 0.0)
            if array.size(retArr) > 0
                float nextOldest = array.get(retArr, 0)
                bvPairSumC -= math.abs(oldRet) * math.abs(nextOldest)
            bvPairSumC := math.max(bvPairSumC, 0.0)

        retPushes += 1
        int nNewRet = array.size(retArr)

        float meanRet = nNewRet > 0 ? retSumC / nNewRet : 0.0
        float varRet = nNewRet > 1 ? math.max(retSqSumC / nNewRet - meanRet * meanRet, 0.0) : 0.0
        stdevSigmaC := math.sqrt(varRet)
        rvEventC := nNewRet > 0 ? retSqSumC / nNewRet : 0.0
        bvEventC := nNewRet > 1 ? (math.pi / 2.0) * math.max(bvPairSumC, 0.0) / (nNewRet - 1) : 0.0
        rvbvRatioC := bvEventC > 0.0 ? rvEventC / bvEventC : 1.0

        bool refreshMad = nNewRet < sigmaLen or (nOldRet < sigmaLen and nNewRet >= sigmaLen) or retPushes % 2 == 0
        if refreshMad and nNewRet > 0
            retMedC := array.median(retArr)
            array.clear(retDevArr)
            for i = 0 to nNewRet - 1
                array.push(retDevArr, math.abs(array.get(retArr, i) - retMedC))
            madRawC := nNewRet > 1 ? array.median(retDevArr) : 0.0

    bool skipVolumeCommit = reanchorOpen and rthFirstBar
    if skipVolumeCommit
        array.clear(volArr)
        array.clear(volDevArr)
        medVolC := 0.0
        volMadC := 0.0
        volPushes := 0
    else if vol > 0.0 and validOHLC
        array.push(volArr, vol)
        if array.size(volArr) > capLookback
            array.shift(volArr)
        volPushes += 1
        int nVolNew = array.size(volArr)
        if nVolNew < 20 or volPushes % 5 == 0
            medVolC := array.median(volArr)
            if showSweeps
                array.clear(volDevArr)
                for i = 0 to nVolNew - 1
                    array.push(volDevArr, math.abs(array.get(volArr, i) - medVolC))
                volMadC := nVolNew > 1 ? array.median(volDevArr) : 0.0

    flowCarry := ownTick != 0 ? ownTick : flowCarry

    [chosen, geoDir, bvcDir, bothRan ? 1 : 0, icebergSuspect ? 1 : 0, jumpFlag ? 1 : 0, pAbsorb * 100.0, lambdaPrior * 100.0, rvbvRatioC, sweepFlag, flowFilteredVol, sessionDistrust ? 1 : 0, logRet]

// ----------------------------------------------------------------------------
// REQUEST LOWER-TIMEFRAME ARRAYS
// ----------------------------------------------------------------------------
[rawDeltaArr, geoDirArr, bvcDirArr, bothRanArr, icebergArr, jumpArr, pAbsorbArr, lambdaArr, ratioArr, sweepArr, filtVolArr, sessWinArr, retArrOut] = request.security_lower_tf(syminfo.tickerid, lowerTimeframe, calcRoutedDelta(), ignore_invalid_timeframe = true, calc_bars_count = 100000)

// ----------------------------------------------------------------------------
// CHART-BAR AGGREGATION
// ----------------------------------------------------------------------------
var float cumDelta = 0.0
var float prevValue = 0.0

var float ewN = 0.0
var float ewD = 0.0

var float regP1 = 0.3333333333
var float regP2 = 0.3333333334
var float regP3 = 0.3333333333

var float[] amihudArr = array.new_float(0)
var float[] kyleArr = array.new_float(0)
var float[] jumpShareArr = array.new_float(0)
var float[] y2Arr = array.new_float(0)
var float[] dirArr = array.new_float(0)

bool anchorReset = timeframe.change(anchorInput)
if anchorReset
    cumDelta := 0.0
    prevValue := 0.0
    ewN := 0.0
    ewD := 0.0
    regP1 := regStates == 2 ? 0.5 : 1.0 / 3.0
    regP2 := regStates == 2 ? 0.5 : 1.0 / 3.0
    regP3 := regStates == 2 ? 0.0 : 1.0 / 3.0
    array.clear(amihudArr)
    array.clear(kyleArr)
    array.clear(jumpShareArr)
    array.clear(y2Arr)
    array.clear(dirArr)

float barDeltaSum = 0.0
float currentSum = 0.0
float highPoint = 0.0
float lowPoint = 0.0

int bothRanCount = 0
int disagreeCount = 0
int icebergCount = 0
int jumpCount = 0
float pAbsorbSum = 0.0
float lambdaMax = 0.0
int buySweeps = 0
int sellSweeps = 0
float filtVolSum = 0.0
int sessWinCount = 0

float sumRet = 0.0
float rv = 0.0
float bpv = 0.0
float prevAbsRet = na
int retObs = 0

int ltfSize = array.size(rawDeltaArr)
if ltfSize > 0
    for i = 0 to ltfSize - 1
        float stepDelta = nz(array.get(rawDeltaArr, i), 0.0)
        barDeltaSum += stepDelta

        if array.get(bothRanArr, i) == 1
            bothRanCount += 1
            if array.get(geoDirArr, i) != array.get(bvcDirArr, i)
                disagreeCount += 1

        if array.get(icebergArr, i) == 1
            icebergCount += 1
        if array.get(jumpArr, i) == 1
            jumpCount += 1

        pAbsorbSum += nz(array.get(pAbsorbArr, i), 50.0)
        lambdaMax := math.max(lambdaMax, nz(array.get(lambdaArr, i), 0.0))

        int sw = nz(array.get(sweepArr, i), 0)
        if sw > 0
            buySweeps += 1
        else if sw < 0
            sellSweeps += 1

        filtVolSum += nz(array.get(filtVolArr, i), 0.0)
        if nz(array.get(sessWinArr, i), 0) == 1
            sessWinCount += 1

        float r = array.get(retArrOut, i)
        if not na(r)
            sumRet += r
            rv += r * r
            float ar = math.abs(r)
            if not na(prevAbsRet)
                bpv += prevAbsRet * ar
            prevAbsRet := ar
            retObs += 1

// ----------------------------------------------------------------------------
// CHART-BAR OVERLAYS FROM CCV RESEARCH
// ----------------------------------------------------------------------------
float dClose = nz(close - close[1], 0.0)
float barLogRet = not na(close[1]) and close > 0.0 and close[1] > 0.0 ? math.log(close / close[1]) : 0.0
float dollarVol = close * math.max(nz(volume), 0.0)

// --- Effort vs result ---
float amihudBase = arrMean(amihudArr)
float amihudRaw = dollarVol > EPS ? math.abs(barLogRet) / dollarVol : na
float amihudRatio = isFinite(amihudRaw) and isFinite(amihudBase) and amihudBase > EPS ? amihudRaw / amihudBase : 1.0

float alphaLambda = 2.0 / (effBaseLen + 1.0)
float qSq = barDeltaSum * barDeltaSum
float ewNNew = (1.0 - alphaLambda) * ewN + alphaLambda * (dClose * barDeltaSum)
float ewDNew = (1.0 - alphaLambda) * ewD + alphaLambda * qSq
float kyleLambda = ewDNew > EPS ? math.max(ewNNew / ewDNew, 0.0) : na
float kyleBase = arrMean(kyleArr)
float kyleRatio = isFinite(kyleLambda) and isFinite(kyleBase) and kyleBase > EPS ? kyleLambda / kyleBase : 1.0

float effRaw = useEffort ? (amihudRatio + kyleRatio) * 0.5 : 1.0
float effWeight = clampf(effRaw, effMin, effMax)

// --- VR / jump-share shape tilt ---
float vrRaw = rv > EPS ? (sumRet * sumRet) / rv : 1.0
float vrMax = math.max(float(retObs), 1.0)
float vr = clampf(vrRaw, 0.0, vrMax)
float vr01 = vr / (vr + 1.0)

float smallSampleCorrection = retObs > 1 ? float(retObs) / (float(retObs) - 1.0) : 1.0
float bvAdjusted = bpv * PI_OVER_2 * smallSampleCorrection
float jumpShare = rv > EPS and retObs > 2 ? clampf((rv - bvAdjusted) / rv, 0.0, 1.0) : 0.0
float jumpBase = arrMean(jumpShareArr)
float jumpDeviation = isFinite(jumpBase) ? jumpShare - jumpBase : 0.0
float shapeConfidence = clampf((float(retObs) - 4.0) / 8.0, 0.0, 1.0)
float shapeCore = 0.7 * (2.0 * vr01 - 1.0) + 0.6 * jumpDeviation
float shapeTilt = useShapeTilt ? clampf(1.0 + shapeGain * shapeConfidence * shapeCore, 0.35, 1.85) : 1.0

// --- Hamilton regime filter ---
float y2 = math.log(math.max(vr, 1e-6))
float dirSignal = rv > EPS ? sumRet / math.sqrt(rv) : 0.0
dirSignal := clampf(dirSignal, -math.sqrt(vrMax), math.sqrt(vrMax))

float meanY2 = arrMean(y2Arr)
float sdY2 = arrStdev(y2Arr, meanY2)
float meanDir = arrMean(dirArr)
float sdDir = arrStdev(dirArr, meanDir)

bool ready2 = array.size(y2Arr) >= regLen and isFinite(meanY2) and isFinite(sdY2) and sdY2 > 1e-4
bool ready3 = array.size(dirArr) >= regLen and isFinite(meanDir) and isFinite(sdDir) and sdDir > 1e-4
bool regimeReady = regStates == 2 ? ready2 : ready3

float displacementPrior = regStates == 2 ? 0.5 : 2.0 / 3.0
float pDisp = displacementPrior

if useRegimeFilter and regimeReady
    if regStates == 2
        float off2 = 1.0 - regStay
        float eMean1 = meanY2 - sdY2
        float eMean2 = meanY2 + sdY2
        float logE1 = logNormPdf(y2, eMean1, sdY2)
        float logE2 = logNormPdf(y2, eMean2, sdY2)

        float pred1 = regStay * regP1 + off2 * regP2
        float pred2 = off2 * regP1 + regStay * regP2

        float lp1 = math.log(math.max(pred1, EPS)) + logE1
        float lp2 = math.log(math.max(pred2, EPS)) + logE2

        float mx = math.max(lp1, lp2)
        float ex1 = math.exp(lp1 - mx)
        float ex2 = math.exp(lp2 - mx)
        float den = ex1 + ex2

        if den > EPS
            regP1 := ex1 / den
            regP2 := ex2 / den
            regP3 := 0.0
        else
            regP1 := 0.5
            regP2 := 0.5
            regP3 := 0.0

        pDisp := regP2
    else
        float off3 = (1.0 - regStay) / 2.0
        float eMean1 = meanDir - sdDir
        float eMean2 = meanDir
        float eMean3 = meanDir + sdDir
        float logE1 = logNormPdf(dirSignal, eMean1, sdDir)
        float logE2 = logNormPdf(dirSignal, eMean2, sdDir)
        float logE3 = logNormPdf(dirSignal, eMean3, sdDir)

        float pred1 = regStay * regP1 + off3 * regP2 + off3 * regP3
        float pred2 = off3 * regP1 + regStay * regP2 + off3 * regP3
        float pred3 = off3 * regP1 + off3 * regP2 + regStay * regP3

        float lp1 = math.log(math.max(pred1, EPS)) + logE1
        float lp2 = math.log(math.max(pred2, EPS)) + logE2
        float lp3 = math.log(math.max(pred3, EPS)) + logE3

        float mx = math.max(lp1, math.max(lp2, lp3))
        float ex1 = math.exp(lp1 - mx)
        float ex2 = math.exp(lp2 - mx)
        float ex3 = math.exp(lp3 - mx)
        float den = ex1 + ex2 + ex3

        if den > EPS
            regP1 := ex1 / den
            regP2 := ex2 / den
            regP3 := ex3 / den
        else
            regP1 := 1.0 / 3.0
            regP2 := 1.0 / 3.0
            regP3 := 1.0 / 3.0

        pDisp := regP1 + regP3

float regimeScore = pDisp >= displacementPrior ?
     safeDiv(pDisp - displacementPrior, 1.0 - displacementPrior, 0.0) :
     safeDiv(pDisp - displacementPrior, displacementPrior, 0.0)
regimeScore := clampf(regimeScore, -1.0, 1.0)
float regimeMultiplier = useRegimeFilter ? clampf(1.0 + regGain * regimeScore, 0.35, 1.85) : 1.0

// --- Final chart-bar multiplier ---
float totalMultiplier = clampf(effWeight * shapeTilt * regimeMultiplier, 0.20, 2.75)
float barDeltaAdj = barDeltaSum * totalMultiplier

// Build intrabar path after chart-bar multiplier
if ltfSize > 0
    for i = 0 to ltfSize - 1
        float stepDeltaAdj = nz(array.get(rawDeltaArr, i), 0.0) * totalMultiplier
        currentSum += stepDeltaAdj
        highPoint := math.max(highPoint, currentSum)
        lowPoint := math.min(lowPoint, currentSum)

// Commit overlay states after they have scored against prior baselines
if isFinite(amihudRaw)
    pushTrim(amihudArr, amihudRaw, effBaseLen)
ewN := ewNNew
ewD := ewDNew
if isFinite(kyleLambda)
    pushTrim(kyleArr, kyleLambda, effBaseLen)
if isFinite(jumpShare)
    pushTrim(jumpShareArr, jumpShare, shapeBaseLen)
if isFinite(y2)
    pushTrim(y2Arr, y2, regLen)
if isFinite(dirSignal)
    pushTrim(dirArr, dirSignal, regLen)

cumDelta += barDeltaAdj
float displayHigh = cumDelta - barDeltaAdj + highPoint
float displayLow = cumDelta - barDeltaAdj + lowPoint

// ----------------------------------------------------------------------------
// COLORS AND VISUALS
// ----------------------------------------------------------------------------
bool priceUp = close > open
bool priceDn = close < open
bool deltaUp = cumDelta > prevValue
bool deltaDn = cumDelta < prevValue
bool isDivergence = (priceUp and deltaDn) or (priceDn and deltaUp)
bool engineDisagree = flagDisagreement and bothRanCount > 0 and disagreeCount * 2 >= bothRanCount
bool absorptionSuspect = showAbsorptionFlag and ltfSize > 0 and icebergCount * 4 >= ltfSize
bool sessionWindowActive = useSessionDistrust and ltfSize > 0 and sessWinCount * 2 >= ltfSize

color candleCol = cumDelta >= prevValue ? color.new(#00ffbb, 20) : color.new(#ff0055, 20)
if engineDisagree
    candleCol := color.new(color.yellow, 0)
if showDivergence and isDivergence
    candleCol := color.new(color.orange, 0)

color bgTint = absorptionSuspect ? color.new(color.purple, 80) : sessionWindowActive ? color.new(#3d5a80, 82) : na
bgcolor(bgTint, title = "Distrust tint")

plotcandle(prevValue, displayHigh, displayLow, cumDelta, title = "Routed CVD", color = candleCol, wickcolor = candleCol, bordercolor = candleCol)
hline(0, color = color.gray, linestyle = hline.style_dotted, title = "Zero Balance Line")
prevValue := cumDelta

plotshape(showSweeps and buySweeps > 0, "Aggressive buy sweep", style = shape.triangleup, location = location.belowbar, color = color.new(#00ffbb, 0), size = size.tiny, force_overlay = true)
plotshape(showSweeps and sellSweeps > 0, "Aggressive sell sweep", style = shape.triangledown, location = location.abovebar, color = color.new(#ff0055, 0), size = size.tiny, force_overlay = true)

// ----------------------------------------------------------------------------
// DATA WINDOW DIAGNOSTICS
// ----------------------------------------------------------------------------
float diagAvgAbsorb = ltfSize > 0 ? pAbsorbSum / ltfSize : na
float diagMaxLambda = ltfSize > 0 ? lambdaMax / 100.0 : na
float diagJumpShare = ltfSize > 0 ? 100.0 * jumpCount / ltfSize : na
float diagIcebergShare = ltfSize > 0 ? 100.0 * icebergCount / ltfSize : na
float diagRvBv = ltfSize > 0 ? nz(array.get(ratioArr, ltfSize - 1), 1.0) : na
float diagFiltShare = flowVolFilterMode != "Off" and nz(volume) > 0.0 ? 100.0 * filtVolSum / nz(volume) : na
float diagSessShare = useSessionDistrust and ltfSize > 0 ? 100.0 * sessWinCount / ltfSize : na

plot(diagAvgAbsorb, "Diag: avg P(absorption) %", color = color.new(color.aqua, 0), display = display.data_window)
plot(diagMaxLambda, "Diag: max Hawkes intensity", color = color.new(color.fuchsia, 0), display = display.data_window)
plot(diagJumpShare, "Diag: jump-flag share %", color = color.new(color.silver, 0), display = display.data_window)
plot(diagIcebergShare, "Diag: hidden-liq share %", color = color.new(color.purple, 0), display = display.data_window)
plot(diagRvBv, "Diag: RV/BV window ratio", color = color.new(color.gray, 0), display = display.data_window)
plot(diagFiltShare, "Diag: Flow vol filtered %", color = color.new(color.teal, 0), display = display.data_window)
plot(diagSessShare, "Diag: session-window share %", color = color.new(color.blue, 0), display = display.data_window)

plot(amihudRaw, "Diag: Amihud illiquidity", color = color.new(color.silver, 0), display = display.data_window)
plot(kyleLambda, "Diag: Kyle lambda", color = color.new(color.white, 0), display = display.data_window)
plot(vr, "Diag: variance ratio", color = color.new(color.lime, 0), display = display.data_window)
plot(jumpShare, "Diag: jump-share", color = color.new(color.orange, 0), display = display.data_window)
plot(pDisp, "Diag: P(displacement)", color = color.new(color.blue, 0), display = display.data_window)
plot(totalMultiplier, "Diag: total XR multiplier", color = color.new(color.yellow, 0), display = display.data_window)

// --- Volume sanity guard ---
var float cumVol = 0.0
cumVol += nz(volume)
if barstate.islastconfirmedhistory and cumVol == 0
    runtime.error("The data vendor doesn't provide volume data for this symbol.")
````
