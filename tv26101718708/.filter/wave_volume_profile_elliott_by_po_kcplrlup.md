# Wave Volume Profile - Elliott by Po

- url: https://www.tradingview.com/script/kCplrLUp-Wave-Volume-Profile-Elliott-by-Po/
- type: indicator
- pine_id: PUB;2a1fb193a2f945d691930da91b7e52b3
- version: 1.0

## Description

This indicator is the volume trade automatic find the accumulate zone

## Source Code

````pine
//@version=6
// =============================================================================
// WAVE VOLUME PROFILE - ELLIOTT v3.6.1
//
// v3.6.1 fixes (compile errors):
//   - CE10088: f_clearPendingVisuals can't assign global vars
//     -> Refactored pending visuals to use arrays (pendingBoxes, pendingLabels)
//   - CE10088: f_finalizeStruct can't assign global vars
//     -> Function now returns tuple of computed values + draws visuals only
//     -> Outer code (Static path + Dynamic path) assigns global vars itself
//
// v3.6 features:
//   + Dynamic C (Sideways Box Extension) - opt-in
//     - After ABC detected, enter PENDING state instead of building profile
//     - Profile right boundary extends bar-by-bar through accumulation
//     - CONFIRM triggers (whichever first):
//         * Breakout: close > B + ATR*X with volume confirmation
//         * Higher Pivot Low: new pivot low > Wave C low
//         * Time Cap: pending exceeds N bars (safety net)
//     - INVALIDATE: close < C - ATR*X (pattern broken)
//   - Removed table views: Live, Per Tier, Per Strategy, Trades,
//                          Force vs Natural, Exit Timing, Debug
//     (kept: Recommendation, Entry Quality, Hide)
// =============================================================================
indicator("Wave Volume Profile - Elliott v3.6.1", "WVP-E v3.6.1", overlay=true,
     max_boxes_count=500, max_lines_count=500, max_labels_count=500, max_bars_back=5000)

// =============================================================================
// INPUTS
// =============================================================================
gPivot = "1. Pivot Detection"
leftBars  = input.int(5, "Pivot Left Bars",  minval=2, maxval=20, group=gPivot)
rightBars = input.int(5, "Pivot Right Bars", minval=2, maxval=20, group=gPivot)

gWave = "2. Elliott ABC Detection"
strictnessMode = input.string("Standard", "Strictness Preset",
     options=["Strict", "Standard", "Loose", "Custom"], group=gWave)
useAdaptive = input.bool(true, "Use Adaptive Threshold", group=gWave)
minPullbackPctIn = input.float(5.0,  "Custom: Min Wave A (%)", minval=2, maxval=30, step=0.5, group=gWave)
maxBHighPctIn    = input.float(90.0, "Custom: Max Wave B Retrace (%)", minval=30, maxval=120, step=5, group=gWave)
allowDeepC       = input.bool(true,  "Allow Wave C Below A-low", group=gWave)
impulseLookback  = input.int(7, "Impulse Confirmation Lookback", minval=3, maxval=15, group=gWave)
cooldownBars     = input.int(30, "Cooldown Bars After ABC", minval=0, maxval=200, group=gWave)

gDynC = "2b. Dynamic C (Sideways Box Extension)"
useDynamicC     = input.bool(true, "Enable Dynamic C", group=gDynC,
     tooltip="ON: defer profile build until breakout / higher-pivot-low / time cap. Profile range extends right to capture full accumulation. OFF: original behavior (build profile at C immediately).")
pendingMaxBars  = input.int(100, "Time Cap (max pending bars)", minval=10, maxval=500, group=gDynC,
     tooltip="Force-finalize profile after this many bars even without breakout. ~5 months on daily.")
breakoutAtrMult = input.float(0.3, "Breakout: close > B + ATR x", minval=0.0, maxval=3.0, step=0.1, group=gDynC,
     tooltip="Confirms bullish exit from sideways. 0.3 = mild, 1.0 = strong breakout.")
breakoutVolPct  = input.float(110.0, "Breakout: Volume % of baseline", minval=80, maxval=300, step=10, group=gDynC)
invalidAtrMult  = input.float(1.5, "Invalid: close < C - ATR x", minval=0.5, maxval=5.0, step=0.5, group=gDynC,
     tooltip="If close drops this far below Wave C low, pattern is discarded.")
showPendingBox  = input.bool(true, "Show Pending Box", group=gDynC)

gProfile = "3. Volume Profile"
profileMode     = input.string("Full ABC", "Profile Range",
     options=["Full ABC", "Sideways Only (B-C)"], group=gProfile)
nRows           = input.int(20, "Profile Rows", minval=10, maxval=50, group=gProfile)
profileWidthPct = input.float(40.0, "Profile Width (%)", minval=10, maxval=100, step=5, group=gProfile)
valueAreaPct    = input.float(70.0, "Value Area (%)", minval=50, maxval=90, step=5, group=gProfile)

gSignal = "4. Entry Signals (3 Tiers)"
weakBars     = input.int(1, "Weak: bars closing > POC",   minval=1, maxval=5, group=gSignal)
mediumBars   = input.int(2, "Medium: bars closing > POC", minval=2, maxval=5, group=gSignal)
strongVolThr = input.float(130.0, "Strong: volume % required", minval=100, maxval=300, step=10, group=gSignal)
volBaseLen   = input.int(50, "Volume Baseline Length", minval=10, maxval=200, group=gSignal)

gTargets = "5. R-Multiple Targets"
t1RMult      = input.float(1.0, "T1 = R x", minval=0.5, maxval=5.0, step=0.5, group=gTargets)
t2RMult      = input.float(2.0, "T2 = R x", minval=1.0, maxval=10.0, step=0.5, group=gTargets)
t3RMult      = input.float(4.0, "T3 = R x", minval=2.0, maxval=20.0, step=0.5, group=gTargets)
trailAtrMult = input.float(2.5, "Trail Stop ATR Multiplier", minval=1.0, maxval=5.0, step=0.5, group=gTargets)
atrLen       = input.int(14, "ATR Length (for Trail)", minval=5, maxval=50, group=gTargets)

gAuto = "6. Auto-Best Selection"
minTradesForAuto = input.int(5, "Min Trades for Auto-Best", minval=3, maxval=20, group=gAuto)
fullCreditN      = input.int(10, "Full-Credit Sample Size", minval=3, maxval=50, group=gAuto,
     tooltip="Bucket gets full weight at n>=this; below this, score is penalized linearly")

gDisp = "7. Display"
showABC      = input.bool(true, "Label A/B/C Pivots", group=gDisp)
showProfile  = input.bool(true, "Show Volume Profile", group=gDisp)
showTargets  = input.bool(true, "Show T1/T2/T3/Stop Lines", group=gDisp)
showMarkers  = input.bool(true, "Show Trade Markers", group=gDisp)
extendPOC    = input.bool(true, "Extend POC Right (live S/R)", group=gDisp)
tableView    = input.string("Recommendation", "Table View",
     options=["Recommendation", "Entry Quality", "Hide"], group=gDisp)
tablePos     = input.string("top_right", "Table Position",
     options=["top_right","top_left","bottom_right","bottom_left","middle_right","middle_left"], group=gDisp)
tableSizeIn  = input.string("small", "Table Size",
     options=["tiny","small","normal"], group=gDisp)

gColor = "8. Colors"
colorProfile  = input.color(color.new(color.purple, 0), "Profile", group=gColor)
profileTransp = input.int(70, "Profile Transparency", minval=0, maxval=95, group=gColor)
colorPending  = input.color(color.new(color.yellow, 0), "Pending Box", group=gColor)

gEval = "9. Long-Term Evaluation"
maxTrackedSignals = input.int(300, "Max Tracked Signals", minval=20, maxval=1000, group=gEval)
fwd1Bars = input.int(20,  "Forward Window 1 (bars)", minval=5, group=gEval, tooltip="~1 month on daily")
fwd2Bars = input.int(60,  "Forward Window 2 (bars)", minval=5, group=gEval, tooltip="~3 months on daily")
fwd3Bars = input.int(120, "Forward Window 3 (bars)", minval=5, group=gEval, tooltip="~6 months on daily")
fwd4Bars = input.int(250, "Forward Window 4 (bars)", minval=5, group=gEval, tooltip="~1 year on daily")
hitThr1Pct = input.float(20.0, "Hit Threshold 1 (%)", minval=5, group=gEval)
hitThr2Pct = input.float(50.0, "Hit Threshold 2 (%)", minval=10, group=gEval)
useTrendExit = input.bool(true, "Track Trend-Follow Exit (parallel)", group=gEval)
trendExitMA = input.int(50, "Trend Exit EMA Length", minval=10, group=gEval)
qualityScope = input.string("All Signals", "Aggregate Scope",
     options=["All Signals", "Weak Tier Only", "Medium Tier Only", "Strong Tier Only"], group=gEval)

// === APPLY PRESETS ===
presetMinPullback = strictnessMode == "Strict" ? 8.0 : strictnessMode == "Standard" ? 5.0 : strictnessMode == "Loose" ? 3.0 : minPullbackPctIn
presetMaxBHigh    = strictnessMode == "Strict" ? 80.0 : strictnessMode == "Standard" ? 90.0 : strictnessMode == "Loose" ? 100.0 : maxBHighPctIn

// === TOP-LEVEL CALC ===
ph = ta.pivothigh(high, leftBars, rightBars)
pl_pivot = ta.pivotlow(low, leftBars, rightBars)
volBaseline = ta.sma(volume, volBaseLen)
atrVal = ta.atr(atrLen)
trendMA = ta.ema(close, trendExitMA)

// === STATE: Pivots ===
var array<float>  pPrices = array.new<float>()
var array<int>    pBars   = array.new<int>()
var array<string> pTypes  = array.new<string>()
var array<float> pullbackHist = array.new<float>()

// === STATE: Current ABC structure ===
var float curImpPrice = na
var int   curImpBar   = na
var float curAPrice   = na
var int   curABar     = na
var float curBPrice   = na
var int   curBBar     = na
var float curCPrice   = na
var int   curCBar     = na
var float curPOC      = na
var float curVAH      = na
var float curVAL      = na
var float curT1       = na
var float curT2       = na
var float curT3       = na
var float curStop     = na
var int   curBarsAbove = 0
var bool  hasActiveStruct = false
var int   cooldownCounter = 0

// === STATE: Pending ABC (using ARRAYS to avoid CE10088) ===
var bool  pendingABC = false
var float pP2Price = na
var int   pP2Bar   = na
var float pP3Price = na
var int   pP3Bar   = na
var float pP4Price = na
var int   pP4Bar   = na
var float pP5Price = na
var int   pP5Bar   = na
var int   pendingDetectBar = na
// Index 0 in pendingBoxes  = main pending box (the one whose right edge extends)
// Index 0 in pendingLabels = "PENDING" text label (the one whose x extends)
// Index 1..3 in pendingLabels = optional A?, B?, C? markers
var array<box>   pendingBoxes  = array.new<box>()
var array<label> pendingLabels = array.new<label>()

var int totalPendingConfirmed   = 0
var int totalPendingInvalidated = 0
var int totalPendingTimedOut    = 0
var int totalConfirmedByBO      = 0
var int totalConfirmedByHL      = 0

// === STATE: 9 buckets ===
var array<bool>  bktOpen      = array.new<bool>(9, false)
var array<float> bktEntry     = array.new<float>(9, na)
var array<int>   bktEntryBar  = array.new<int>(9, na)
var array<float> bktRemSize   = array.new<float>(9, 0.0)
var array<float> bktRealPL    = array.new<float>(9, 0.0)
var array<bool>  bktT1Hit     = array.new<bool>(9, false)
var array<bool>  bktT2Hit     = array.new<bool>(9, false)
var array<bool>  bktT3Hit     = array.new<bool>(9, false)
var array<float> bktTrailHigh = array.new<float>(9, na)

var array<int>   bktTrades    = array.new<int>(9, 0)
var array<int>   bktWins      = array.new<int>(9, 0)
var array<float> bktSumWin    = array.new<float>(9, 0.0)
var array<float> bktSumLoss   = array.new<float>(9, 0.0)
var array<int>   bktReachT1   = array.new<int>(9, 0)
var array<int>   bktReachT2   = array.new<int>(9, 0)
var array<int>   bktReachT3   = array.new<int>(9, 0)
var array<int>   bktHitStop   = array.new<int>(9, 0)
var array<int>   bktBarsHeld  = array.new<int>(9, 0)

var array<int>   bktForceTrades  = array.new<int>(9, 0)
var array<int>   bktForceWins    = array.new<int>(9, 0)
var array<float> bktForceSumWin  = array.new<float>(9, 0.0)
var array<float> bktForceSumLoss = array.new<float>(9, 0.0)

var array<bool> tierFired = array.new<bool>(3, false)

// Trade history
var array<string> hTier   = array.new<string>()
var array<string> hStrat  = array.new<string>()
var array<float>  hPL     = array.new<float>()
var array<int>    hBars   = array.new<int>()
var array<string> hReason = array.new<string>()

// === Visuals (active structure) ===
var array<box>   activeBoxes  = array.new<box>()
var array<line>  activeLines  = array.new<line>()
var array<label> activeLabels = array.new<label>()
var line  livePOCExt = na

var bool firedT1Once   = false
var bool firedT2Once   = false
var bool firedT3Once   = false
var bool firedStopOnce = false

var int totalABCDetected      = 0
var int totalABCRejected      = 0
var int totalForceClosed      = 0
var int totalCooldownBlocked  = 0
var int lastABCBar            = na
var float lastUsedThreshold   = na

// === Tracked signals (event-study) ===
var array<int>    tsBar       = array.new<int>()
var array<float>  tsEntry     = array.new<float>()
var array<int>    tsTier      = array.new<int>()
var array<float>  tsMFE       = array.new<float>()
var array<float>  tsMAE       = array.new<float>()
var array<float>  tsR1        = array.new<float>()
var array<float>  tsR2        = array.new<float>()
var array<float>  tsR3        = array.new<float>()
var array<float>  tsR4        = array.new<float>()
var array<bool>   tsHit1      = array.new<bool>()
var array<bool>   tsHit2      = array.new<bool>()
var array<float>  tsTrendExit = array.new<float>()
var array<bool>   tsTrendDone = array.new<bool>()

// Per-bar fire flags
bool fireWeak    = false
bool fireMedium  = false
bool fireStrong  = false
bool fireT1      = false
bool fireT2      = false
bool fireT3      = false
bool fireStop    = false

// =============================================================================
// HELPERS (no global scalar assigns; only array ops + local vars + return)
// =============================================================================
f_anyOpen() =>
    res = false
    for i = 0 to 8
        if array.get(bktOpen, i)
            res := true
    res

f_adaptiveThreshold() =>
    n = array.size(pullbackHist)
    result = presetMinPullback
    if useAdaptive and n >= 10
        sorted = array.copy(pullbackHist)
        array.sort(sorted, order.ascending)
        medianVal = array.get(sorted, n / 2)
        adaptive = medianVal * 0.75
        result := math.max(2.5, math.min(15.0, adaptive))
    result

f_clearActiveVisuals() =>
    while array.size(activeBoxes) > 0
        box.delete(array.shift(activeBoxes))
    while array.size(activeLines) > 0
        line.delete(array.shift(activeLines))
    while array.size(activeLabels) > 0
        label.delete(array.shift(activeLabels))

// Refactored: uses arrays only (no global scalar assigns)
f_clearPendingVisuals() =>
    while array.size(pendingBoxes) > 0
        box.delete(array.shift(pendingBoxes))
    while array.size(pendingLabels) > 0
        label.delete(array.shift(pendingLabels))

f_pushTrackedSignal(int tier) =>
    if array.size(tsBar) < maxTrackedSignals
        array.push(tsBar, bar_index)
        array.push(tsEntry, close)
        array.push(tsTier, tier)
        array.push(tsMFE, close)
        array.push(tsMAE, close)
        array.push(tsR1, na)
        array.push(tsR2, na)
        array.push(tsR3, na)
        array.push(tsR4, na)
        array.push(tsHit1, false)
        array.push(tsHit2, false)
        array.push(tsTrendExit, na)
        array.push(tsTrendDone, false)

// =============================================================================
// PROFILE BUILDER
// =============================================================================
f_buildProfile(int startBar, int endBar) =>
    waveHigh = -1e20
    waveLow = 1e20
    barsInRange = endBar - startBar
    if barsInRange > 0 and barsInRange < 1500
        for i = 0 to barsInRange
            absBar = endBar - i
            offset = bar_index - absBar
            if offset >= 0 and offset < 1500
                h = high[offset]
                l = low[offset]
                if h > waveHigh
                    waveHigh := h
                if l < waveLow
                    waveLow := l
    rangeSize = waveHigh - waveLow
    pocLocal = (waveHigh + waveLow) / 2
    vahLocal = waveHigh
    valLocal = waveLow
    if rangeSize > 0 and barsInRange > 0
        rowSize = rangeSize / nRows
        rowVols = array.new<float>(nRows, 0.0)
        for i = 0 to barsInRange
            absBar = endBar - i
            offset = bar_index - absBar
            if offset >= 0 and offset < 1500
                bh = high[offset]
                bl = low[offset]
                bv = nz(volume[offset])
                barRange = bh - bl
                if barRange > 0 and bv > 0
                    volPerUnit = bv / barRange
                    rowStart = math.floor((bl - waveLow) / rowSize)
                    rowEnd = math.floor((bh - waveLow) / rowSize)
                    rowStart := math.max(0, math.min(nRows - 1, rowStart))
                    rowEnd := math.max(0, math.min(nRows - 1, rowEnd))
                    for r = rowStart to rowEnd
                        rowBot = waveLow + r * rowSize
                        rowTop = rowBot + rowSize
                        overlap = math.min(bh, rowTop) - math.max(bl, rowBot)
                        if overlap > 0
                            curr = array.get(rowVols, r)
                            array.set(rowVols, r, curr + overlap * volPerUnit)
                else if bv > 0
                    rowIdx = math.floor((bl - waveLow) / rowSize)
                    rowIdx := math.max(0, math.min(nRows - 1, rowIdx))
                    curr = array.get(rowVols, rowIdx)
                    array.set(rowVols, rowIdx, curr + bv)
        maxV = 0.0
        maxIdx = 0
        totalV = 0.0
        for r = 0 to nRows - 1
            v = array.get(rowVols, r)
            totalV := totalV + v
            if v > maxV
                maxV := v
                maxIdx := r
        pocLocal := waveLow + (maxIdx + 0.5) * rowSize
        targetV = totalV * valueAreaPct / 100
        accumV = maxV
        upIdx = maxIdx
        dnIdx = maxIdx
        while accumV < targetV and (upIdx < nRows - 1 or dnIdx > 0)
            upV = upIdx < nRows - 1 ? array.get(rowVols, upIdx + 1) : 0.0
            dnV = dnIdx > 0 ? array.get(rowVols, dnIdx - 1) : 0.0
            if upV >= dnV and upIdx < nRows - 1
                upIdx := upIdx + 1
                accumV := accumV + upV
            else if dnIdx > 0
                dnIdx := dnIdx - 1
                accumV := accumV + dnV
            else
                break
        vahLocal := waveLow + (upIdx + 1) * rowSize
        valLocal := waveLow + dnIdx * rowSize
        if showProfile
            maxWidth = math.round(barsInRange * profileWidthPct / 100)
            if maxWidth < 1
                maxWidth := 1
            for r = 0 to nRows - 1
                v = array.get(rowVols, r)
                if v > 0 and maxV > 0
                    w = math.round(v / maxV * maxWidth)
                    if w >= 1
                        rowBot = waveLow + r * rowSize
                        rowTop = rowBot + rowSize
                        bx = box.new(endBar - w, rowTop, endBar, rowBot,
                             border_color=color.new(colorProfile, 90),
                             bgcolor=color.new(colorProfile, profileTransp),
                             border_width=1)
                        array.push(activeBoxes, bx)
    [pocLocal, vahLocal, valLocal]

// =============================================================================
// FINALIZE: Build profile + draw visuals + RETURN computed values
// (No global scalar assigns inside this function — outer code does that)
// =============================================================================
f_finalizeStruct(int p2B, float p2P, int p3B, float p3P, int p4B, float p4P, int p5B, float p5P, int profileEndBar) =>
    profileStart = profileMode == "Full ABC" ? p2B : p3B
    [pocV, vahV, valV] = f_buildProfile(profileStart, profileEndBar)
    
    entryProxy = pocV
    riskAbs = entryProxy - p5P
    if riskAbs <= 0
        riskAbs := p5P * 0.02
    t1Calc = entryProxy + riskAbs * t1RMult
    t2Calc = entryProxy + riskAbs * t2RMult
    t3Calc = entryProxy + riskAbs * t3RMult
    
    // POC line
    pocLn = line.new(profileStart, pocV, profileEndBar, pocV,
         color=color.new(colorProfile, 10), width=2)
    array.push(activeLines, pocLn)
    vahLn = line.new(profileStart, vahV, profileEndBar, vahV,
         color=color.new(colorProfile, 50), width=1, style=line.style_dotted)
    valLn = line.new(profileStart, valV, profileEndBar, valV,
         color=color.new(colorProfile, 50), width=1, style=line.style_dotted)
    array.push(activeLines, vahLn)
    array.push(activeLines, valLn)
    pocLbl = label.new(profileEndBar, pocV, "POC " + str.tostring(pocV, format.mintick),
         color=color.new(colorProfile, 20), textcolor=color.white,
         style=label.style_label_left, size=size.small)
    array.push(activeLabels, pocLbl)
    
    if showTargets
        t1Ln = line.new(profileEndBar, t1Calc, profileEndBar + 50, t1Calc,
             color=color.new(#9fe1cb, 30), width=1, style=line.style_dashed, extend=extend.right)
        t2Ln = line.new(profileEndBar, t2Calc, profileEndBar + 50, t2Calc,
             color=color.new(#1d9e75, 20), width=1, style=line.style_dashed, extend=extend.right)
        t3Ln = line.new(profileEndBar, t3Calc, profileEndBar + 50, t3Calc,
             color=color.new(#085041, 10), width=2, style=line.style_dashed, extend=extend.right)
        stopLn = line.new(profileEndBar, p5P, profileEndBar + 50, p5P,
             color=color.new(color.red, 20), width=1, style=line.style_dashed, extend=extend.right)
        array.push(activeLines, t1Ln)
        array.push(activeLines, t2Ln)
        array.push(activeLines, t3Ln)
        array.push(activeLines, stopLn)
        t1Lbl = label.new(profileEndBar, t1Calc, "T1 (1R) " + str.tostring(t1Calc, format.mintick),
             color=color.new(#9fe1cb, 30), textcolor=color.white,
             style=label.style_label_left, size=size.tiny)
        t2Lbl = label.new(profileEndBar, t2Calc, "T2 (2R) " + str.tostring(t2Calc, format.mintick),
             color=color.new(#1d9e75, 20), textcolor=color.white,
             style=label.style_label_left, size=size.tiny)
        t3Lbl = label.new(profileEndBar, t3Calc, "T3 (4R) " + str.tostring(t3Calc, format.mintick),
             color=color.new(#085041, 10), textcolor=color.white,
             style=label.style_label_left, size=size.tiny)
        stopLbl = label.new(profileEndBar, p5P, "STOP " + str.tostring(p5P, format.mintick),
             color=color.new(color.red, 20), textcolor=color.white,
             style=label.style_label_left, size=size.tiny)
        array.push(activeLabels, t1Lbl)
        array.push(activeLabels, t2Lbl)
        array.push(activeLabels, t3Lbl)
        array.push(activeLabels, stopLbl)
    
    if showABC
        aLbl = label.new(p3B, p3P, "A",
             color=color.new(color.gray, 0), textcolor=color.white,
             style=label.style_label_up, size=size.small)
        bLbl = label.new(p4B, p4P, "B",
             color=color.new(color.gray, 0), textcolor=color.white,
             style=label.style_label_down, size=size.small)
        cLbl = label.new(p5B, p5P, "C",
             color=color.new(color.gray, 0), textcolor=color.white,
             style=label.style_label_up, size=size.small)
        array.push(activeLabels, aLbl)
        array.push(activeLabels, bLbl)
        array.push(activeLabels, cLbl)
    
    // Reset tier fire flags (array op — allowed in function)
    for ti = 0 to 2
        array.set(tierFired, ti, false)
    
    // Return tuple — outer code assigns global scalar vars
    [pocV, vahV, valV, t1Calc, t2Calc, t3Calc]

// =============================================================================
// BUCKET MGMT
// =============================================================================
f_closeBucket(int idx, string reason) =>
    if array.get(bktOpen, idx)
        remSize = array.get(bktRemSize, idx)
        entryP = array.get(bktEntry, idx)
        addPL = remSize > 0 and not na(entryP) ? (close - entryP) / entryP * 100 * remSize : 0.0
        finalPL = array.get(bktRealPL, idx) + addPL
        
        array.set(bktTrades, idx, array.get(bktTrades, idx) + 1)
        if finalPL > 0
            array.set(bktWins, idx, array.get(bktWins, idx) + 1)
            array.set(bktSumWin, idx, array.get(bktSumWin, idx) + finalPL)
        else
            array.set(bktSumLoss, idx, array.get(bktSumLoss, idx) + math.abs(finalPL))
        
        if reason == "INVALID"
            array.set(bktForceTrades, idx, array.get(bktForceTrades, idx) + 1)
            if finalPL > 0
                array.set(bktForceWins, idx, array.get(bktForceWins, idx) + 1)
                array.set(bktForceSumWin, idx, array.get(bktForceSumWin, idx) + finalPL)
            else
                array.set(bktForceSumLoss, idx, array.get(bktForceSumLoss, idx) + math.abs(finalPL))
        
        entryB = array.get(bktEntryBar, idx)
        barsThisTrade = na(entryB) ? 0 : bar_index - entryB
        if not na(entryB)
            array.set(bktBarsHeld, idx, array.get(bktBarsHeld, idx) + barsThisTrade)
        
        tierIdx = idx / 3
        stratIdx = idx % 3
        tierStr = tierIdx == 0 ? "W" : tierIdx == 1 ? "M" : "S"
        stratStr = stratIdx == 0 ? "A" : stratIdx == 1 ? "B" : "C"
        array.push(hTier, tierStr)
        array.push(hStrat, stratStr)
        array.push(hPL, finalPL)
        array.push(hBars, barsThisTrade)
        array.push(hReason, reason)
        while array.size(hTier) > 10
            array.shift(hTier)
            array.shift(hStrat)
            array.shift(hPL)
            array.shift(hBars)
            array.shift(hReason)
        
        array.set(bktOpen, idx, false)
        array.set(bktEntry, idx, na)
        array.set(bktEntryBar, idx, na)
        array.set(bktRemSize, idx, 0.0)
        array.set(bktRealPL, idx, 0.0)
        array.set(bktT1Hit, idx, false)
        array.set(bktT2Hit, idx, false)
        array.set(bktT3Hit, idx, false)
        array.set(bktTrailHigh, idx, na)

f_openBucket(int idx) =>
    if not array.get(bktOpen, idx)
        array.set(bktOpen, idx, true)
        array.set(bktEntry, idx, close)
        array.set(bktEntryBar, idx, bar_index)
        array.set(bktRemSize, idx, 1.0)
        array.set(bktRealPL, idx, 0.0)
        array.set(bktT1Hit, idx, false)
        array.set(bktT2Hit, idx, false)
        array.set(bktT3Hit, idx, false)
        array.set(bktTrailHigh, idx, close)

f_forceCloseAll() =>
    closedAny = false
    for i = 0 to 8
        if array.get(bktOpen, i)
            f_closeBucket(i, "INVALID")
            closedAny := true
    closedAny

// =============================================================================
// COOLDOWN COUNTER
// =============================================================================
if cooldownCounter > 0
    cooldownCounter := cooldownCounter - 1

// =============================================================================
// PIVOT MGMT + ABC DETECTION
// =============================================================================
isNewPH = not na(ph)
isNewPL = not na(pl_pivot)

if isNewPH or isNewPL
    pivotPrice = isNewPH ? ph : pl_pivot
    pivotType = isNewPH ? "H" : "L"
    pivotBar = bar_index - rightBars
    nP = array.size(pPrices)
    addPivot = true
    if nP > 0
        lastT = array.get(pTypes, nP - 1)
        if lastT == pivotType
            lastP = array.get(pPrices, nP - 1)
            shouldReplace = (pivotType == "H" and pivotPrice > lastP) or (pivotType == "L" and pivotPrice < lastP)
            if shouldReplace
                array.set(pPrices, nP - 1, pivotPrice)
                array.set(pBars, nP - 1, pivotBar)
            addPivot := false
    if addPivot
        if pivotType == "L" and nP > 0
            lastTypeX = array.get(pTypes, nP - 1)
            if lastTypeX == "H"
                priorHigh = array.get(pPrices, nP - 1)
                drop = (priorHigh - pivotPrice) / priorHigh * 100
                if drop > 0 and drop < 80
                    array.push(pullbackHist, drop)
                    while array.size(pullbackHist) > 50
                        array.shift(pullbackHist)
        array.push(pPrices, pivotPrice)
        array.push(pBars, pivotBar)
        array.push(pTypes, pivotType)
        nP2 = array.size(pPrices)
        if pivotType == "L" and nP2 >= 5 and cooldownCounter == 0
            p1T = array.get(pTypes, nP2 - 5)
            p2T = array.get(pTypes, nP2 - 4)
            p3T = array.get(pTypes, nP2 - 3)
            p4T = array.get(pTypes, nP2 - 2)
            p5T = array.get(pTypes, nP2 - 1)
            if p1T == "L" and p2T == "H" and p3T == "L" and p4T == "H" and p5T == "L"
                p2Price = array.get(pPrices, nP2 - 4)
                p3Price = array.get(pPrices, nP2 - 3)
                p4Price = array.get(pPrices, nP2 - 2)
                p5Price = array.get(pPrices, nP2 - 1)
                p2Bar = array.get(pBars, nP2 - 4)
                p3Bar = array.get(pBars, nP2 - 3)
                p4Bar = array.get(pBars, nP2 - 2)
                p5Bar = array.get(pBars, nP2 - 1)
                effThreshold = f_adaptiveThreshold()
                lastUsedThreshold := effThreshold
                aDropPct = (p2Price - p3Price) / p2Price * 100
                rule1 = aDropPct >= effThreshold
                aRange = p2Price - p3Price
                bRetracePct = aRange > 0 ? (p4Price - p3Price) / aRange * 100 : 0
                rule2 = bRetracePct <= presetMaxBHigh and p4Price < p2Price
                rule3 = allowDeepC ? true : p5Price >= p3Price * 0.97
                rule4 = true
                lookbackStart = math.max(0, nP2 - impulseLookback - 1)
                if nP2 - 5 >= lookbackStart
                    for k = lookbackStart to nP2 - 5
                        pkType = array.get(pTypes, k)
                        pkPrice = array.get(pPrices, k)
                        if pkType == "H" and pkPrice >= p2Price and k != nP2 - 4
                            rule4 := false
                if rule1 and rule2 and rule3 and rule4
                    // Common: clear current active position/struct/visuals
                    if f_anyOpen()
                        if f_forceCloseAll()
                            totalForceClosed := totalForceClosed + 1
                    f_clearActiveVisuals()
                    hasActiveStruct := false
                    
                    totalABCDetected := totalABCDetected + 1
                    lastABCBar := p5Bar
                    cooldownCounter := cooldownBars
                    
                    if useDynamicC
                        // === DYNAMIC C PATH: enter PENDING state ===
                        if pendingABC
                            f_clearPendingVisuals()
                        pendingABC := true
                        pP2Price := p2Price
                        pP2Bar   := p2Bar
                        pP3Price := p3Price
                        pP3Bar   := p3Bar
                        pP4Price := p4Price
                        pP4Bar   := p4Bar
                        pP5Price := p5Price
                        pP5Bar   := p5Bar
                        pendingDetectBar := bar_index
                        if showPendingBox
                            // [0] main pending box — its right edge will extend
                            pBox = box.new(p3Bar, p4Price, bar_index, p5Price,
                                 border_color=color.new(colorPending, 30),
                                 bgcolor=color.new(colorPending, 92),
                                 border_width=1, border_style=line.style_dashed)
                            array.push(pendingBoxes, pBox)
                            // [0] PENDING text label — its x will extend
                            pLbl = label.new(bar_index, (p4Price + p5Price) / 2, "PENDING",
                                 color=color.new(colorPending, 30), textcolor=color.black,
                                 style=label.style_label_left, size=size.small)
                            array.push(pendingLabels, pLbl)
                            if showABC
                                // [1..3] A?, B?, C? markers (static, won't be updated)
                                aPLbl = label.new(p3Bar, p3Price, "A?",
                                     color=color.new(color.gray, 30), textcolor=color.white,
                                     style=label.style_label_up, size=size.tiny)
                                bPLbl = label.new(p4Bar, p4Price, "B?",
                                     color=color.new(color.gray, 30), textcolor=color.white,
                                     style=label.style_label_down, size=size.tiny)
                                cPLbl = label.new(p5Bar, p5Price, "C?",
                                     color=color.new(color.gray, 30), textcolor=color.white,
                                     style=label.style_label_up, size=size.tiny)
                                array.push(pendingLabels, aPLbl)
                                array.push(pendingLabels, bPLbl)
                                array.push(pendingLabels, cPLbl)
                    else
                        // === STATIC C PATH: build profile immediately at p5 ===
                        [pocV_S, vahV_S, valV_S, t1V_S, t2V_S, t3V_S] = f_finalizeStruct(p2Bar, p2Price, p3Bar, p3Price, p4Bar, p4Price, p5Bar, p5Price, p5Bar)
                        // Outer code assigns global scalar vars
                        curImpPrice := p2Price
                        curImpBar   := p2Bar
                        curAPrice   := p3Price
                        curABar     := p3Bar
                        curBPrice   := p4Price
                        curBBar     := p4Bar
                        curCPrice   := p5Price
                        curCBar     := p5Bar
                        curPOC      := pocV_S
                        curVAH      := vahV_S
                        curVAL      := valV_S
                        curT1       := t1V_S
                        curT2       := t2V_S
                        curT3       := t3V_S
                        curStop     := p5Price
                        curBarsAbove := 0
                        hasActiveStruct := true
                        firedT1Once   := false
                        firedT2Once   := false
                        firedT3Once   := false
                        firedStopOnce := false
                else
                    totalABCRejected := totalABCRejected + 1
            else if pivotType == "L" and nP2 >= 5 and cooldownCounter > 0
                p1T2 = array.get(pTypes, nP2 - 5)
                p2T2 = array.get(pTypes, nP2 - 4)
                p3T2 = array.get(pTypes, nP2 - 3)
                p4T2 = array.get(pTypes, nP2 - 2)
                p5T2 = array.get(pTypes, nP2 - 1)
                if p1T2 == "L" and p2T2 == "H" and p3T2 == "L" and p4T2 == "H" and p5T2 == "L"
                    totalCooldownBlocked := totalCooldownBlocked + 1
        while array.size(pPrices) > 100
            array.shift(pPrices)
            array.shift(pBars)
            array.shift(pTypes)

// =============================================================================
// PENDING STATE MANAGEMENT (Dynamic C) — runs every bar in outer scope
// =============================================================================
if pendingABC and useDynamicC
    // Extend pending box right edge + pending label x (outer-scope ops are fine)
    if array.size(pendingBoxes) > 0
        box.set_right(array.get(pendingBoxes, 0), bar_index)
    if array.size(pendingLabels) > 0
        label.set_x(array.get(pendingLabels, 0), bar_index)
    
    barsInPending = bar_index - pendingDetectBar
    
    // === Check INVALIDATE ===
    invalidLevel = pP5Price - atrVal * invalidAtrMult
    if close < invalidLevel
        f_clearPendingVisuals()
        pendingABC := false
        totalPendingInvalidated := totalPendingInvalidated + 1
    else
        // === Check CONFIRM triggers ===
        confirmedHL = false
        if not na(pl_pivot)
            newPLBar = bar_index - rightBars
            if newPLBar > pP5Bar and pl_pivot > pP5Price
                confirmedHL := true
        
        volPct = volBaseline > 0 ? volume / volBaseline * 100 : 0.0
        breakoutLevel = pP4Price + atrVal * breakoutAtrMult
        confirmedBO = close > breakoutLevel and volPct >= breakoutVolPct
        
        confirmedTC = barsInPending >= pendingMaxBars
        
        if confirmedHL or confirmedBO or confirmedTC
            // FINALIZE — clear pending, build profile, assign globals
            f_clearPendingVisuals()
            [pocV_D, vahV_D, valV_D, t1V_D, t2V_D, t3V_D] = f_finalizeStruct(pP2Bar, pP2Price, pP3Bar, pP3Price, pP4Bar, pP4Price, pP5Bar, pP5Price, bar_index)
            curImpPrice := pP2Price
            curImpBar   := pP2Bar
            curAPrice   := pP3Price
            curABar     := pP3Bar
            curBPrice   := pP4Price
            curBBar     := pP4Bar
            curCPrice   := pP5Price
            curCBar     := pP5Bar
            curPOC      := pocV_D
            curVAH      := vahV_D
            curVAL      := valV_D
            curT1       := t1V_D
            curT2       := t2V_D
            curT3       := t3V_D
            curStop     := pP5Price
            curBarsAbove := 0
            hasActiveStruct := true
            firedT1Once   := false
            firedT2Once   := false
            firedT3Once   := false
            firedStopOnce := false
            
            cooldownCounter := cooldownBars
            pendingABC := false
            totalPendingConfirmed := totalPendingConfirmed + 1
            if confirmedBO
                totalConfirmedByBO := totalConfirmedByBO + 1
            else if confirmedHL
                totalConfirmedByHL := totalConfirmedByHL + 1
            else if confirmedTC
                totalPendingTimedOut := totalPendingTimedOut + 1

// =============================================================================
// SIGNAL DETECTION + BUCKET MGMT (unchanged)
// =============================================================================
if hasActiveStruct and not na(curPOC) and bar_index > curCBar
    if close > curPOC
        curBarsAbove := curBarsAbove + 1
    else
        curBarsAbove := 0
    volPctSig = volBaseline > 0 ? volume / volBaseline * 100 : 0.0
    triggerW = not array.get(tierFired, 0) and curBarsAbove >= weakBars
    triggerM = not array.get(tierFired, 1) and curBarsAbove >= mediumBars
    triggerS = not array.get(tierFired, 2) and curBarsAbove >= weakBars and volPctSig >= strongVolThr
    if triggerW
        array.set(tierFired, 0, true)
        fireWeak := true
        for s = 0 to 2
            f_openBucket(0 * 3 + s)
    if triggerM
        array.set(tierFired, 1, true)
        fireMedium := true
        for s = 0 to 2
            f_openBucket(1 * 3 + s)
    if triggerS
        array.set(tierFired, 2, true)
        fireStrong := true
        for s = 0 to 2
            f_openBucket(2 * 3 + s)
    if not firedT1Once and high >= curT1
        firedT1Once := true
        fireT1 := true
    if not firedT2Once and high >= curT2
        firedT2Once := true
        fireT2 := true
    if not firedT3Once and high >= curT3
        firedT3Once := true
        fireT3 := true
    if not firedStopOnce and low <= curStop
        firedStopOnce := true
        fireStop := true
    for tier = 0 to 2
        for strat = 0 to 2
            idx = tier * 3 + strat
            if array.get(bktOpen, idx)
                entryP = array.get(bktEntry, idx)
                remSize = array.get(bktRemSize, idx)
                t1Hit = array.get(bktT1Hit, idx)
                t2Hit = array.get(bktT2Hit, idx)
                t3Hit = array.get(bktT3Hit, idx)
                trailH = array.get(bktTrailHigh, idx)
                if high > trailH
                    array.set(bktTrailHigh, idx, high)
                    trailH := high
                if high >= curT1 and not t1Hit
                    array.set(bktT1Hit, idx, true)
                    t1Hit := true
                    array.set(bktReachT1, idx, array.get(bktReachT1, idx) + 1)
                if high >= curT2 and not t2Hit
                    array.set(bktT2Hit, idx, true)
                    t2Hit := true
                    array.set(bktReachT2, idx, array.get(bktReachT2, idx) + 1)
                if high >= curT3 and not t3Hit
                    array.set(bktT3Hit, idx, true)
                    t3Hit := true
                    array.set(bktReachT3, idx, array.get(bktReachT3, idx) + 1)
                shouldClose = false
                closeReason = ""
                if low <= curStop
                    shouldClose := true
                    closeReason := "STOP"
                    array.set(bktHitStop, idx, array.get(bktHitStop, idx) + 1)
                if not shouldClose
                    if strat == 0
                        trailStop = trailH - atrVal * trailAtrMult
                        if high >= curT3
                            shouldClose := true
                            closeReason := "T3"
                        else if t1Hit and low <= trailStop
                            shouldClose := true
                            closeReason := "TRAIL"
                    else if strat == 1
                        if high >= curT1 and remSize > 0.66
                            realized = (curT1 - entryP) / entryP * 100 * (1.0 / 3.0)
                            array.set(bktRealPL, idx, array.get(bktRealPL, idx) + realized)
                            array.set(bktRemSize, idx, remSize - 1.0 / 3.0)
                            remSize := remSize - 1.0 / 3.0
                        if high >= curT2 and remSize > 0.33
                            realized = (curT2 - entryP) / entryP * 100 * (1.0 / 3.0)
                            array.set(bktRealPL, idx, array.get(bktRealPL, idx) + realized)
                            array.set(bktRemSize, idx, remSize - 1.0 / 3.0)
                            remSize := remSize - 1.0 / 3.0
                        trailStop = trailH - atrVal * trailAtrMult
                        if remSize <= 0.34 and remSize > 0
                            if high >= curT3
                                shouldClose := true
                                closeReason := "T3"
                            else if low <= trailStop
                                shouldClose := true
                                closeReason := "TRAIL"
                    else
                        if high >= curT3
                            shouldClose := true
                            closeReason := "T3"
                        else if t1Hit and low <= entryP
                            shouldClose := true
                            closeReason := "BE"
                if shouldClose
                    f_closeBucket(idx, closeReason)
    if not f_anyOpen() and (high >= curT3 or low <= curStop)
        hasActiveStruct := false

// === Push tracked signals on fire ===
if fireWeak
    f_pushTrackedSignal(0)
if fireMedium
    f_pushTrackedSignal(1)
if fireStrong
    f_pushTrackedSignal(2)

// === Update tracked signals each bar ===
nTracked = array.size(tsBar)
if nTracked > 0
    for i = 0 to nTracked - 1
        eb = array.get(tsBar, i)
        ep = array.get(tsEntry, i)
        age = bar_index - eb
        if age > 0 and ep > 0
            if high > array.get(tsMFE, i)
                array.set(tsMFE, i, high)
            if low < array.get(tsMAE, i)
                array.set(tsMAE, i, low)
            if age == fwd1Bars and na(array.get(tsR1, i))
                array.set(tsR1, i, (close - ep) / ep * 100)
            if age == fwd2Bars and na(array.get(tsR2, i))
                array.set(tsR2, i, (close - ep) / ep * 100)
            if age == fwd3Bars and na(array.get(tsR3, i))
                array.set(tsR3, i, (close - ep) / ep * 100)
            if age == fwd4Bars and na(array.get(tsR4, i))
                array.set(tsR4, i, (close - ep) / ep * 100)
            curRetHigh = (high - ep) / ep * 100
            if not array.get(tsHit1, i) and curRetHigh >= hitThr1Pct
                array.set(tsHit1, i, true)
            if not array.get(tsHit2, i) and curRetHigh >= hitThr2Pct
                array.set(tsHit2, i, true)
            if useTrendExit and not array.get(tsTrendDone, i) and close < trendMA
                array.set(tsTrendExit, i, (close - ep) / ep * 100)
                array.set(tsTrendDone, i, true)

// === EXTEND POC LIVE ===
if extendPOC and barstate.islast
    if not na(livePOCExt)
        line.delete(livePOCExt)
        livePOCExt := na
    if not na(curPOC) and not na(curCBar)
        extCol = close > curPOC ? color.new(#1d9e75, 30) : color.new(color.red, 30)
        livePOCExt := line.new(curCBar, curPOC, bar_index, curPOC,
             color=extCol, width=1, style=line.style_dashed)

// === PLOT MARKERS ===
plotshape(showMarkers and fireWeak,   "Weak",   shape.triangleup, location.belowbar, color.new(color.yellow, 0), text="W", textcolor=color.yellow, size=size.tiny)
plotshape(showMarkers and fireMedium, "Medium", shape.triangleup, location.belowbar, color.new(color.orange, 0), text="M", textcolor=color.orange, size=size.small)
plotshape(showMarkers and fireStrong, "Strong", shape.triangleup, location.belowbar, color.new(color.green, 0),  text="S", textcolor=color.green,  size=size.normal)
plotshape(showMarkers and fireT1, "T1 Hit", shape.diamond, location.abovebar, color.new(#9fe1cb, 0), text="T1", textcolor=color.aqua, size=size.tiny)
plotshape(showMarkers and fireT2, "T2 Hit", shape.diamond, location.abovebar, color.new(#1d9e75, 0), text="T2", textcolor=#1d9e75, size=size.tiny)
plotshape(showMarkers and fireT3, "T3 Hit", shape.diamond, location.abovebar, color.new(#085041, 0), text="T3", textcolor=#085041, size=size.small)
plotshape(showMarkers and fireStop, "Stop", shape.xcross, location.abovebar, color.new(color.red, 0), text="STOP", textcolor=color.red, size=size.small)

// === AUTO-BEST (sample-size-aware) ===
totalClosed = 0
for i = 0 to 8
    totalClosed := totalClosed + array.get(bktTrades, i)

isLearning = totalClosed < minTradesForAuto

bestIdx = 7
bestScore = -1e10
if not isLearning
    for i = 0 to 8
        n = array.get(bktTrades, i)
        if n >= 2
            sw = array.get(bktSumWin, i)
            sl = array.get(bktSumLoss, i)
            exp = (sw - sl) / n
            penalty = math.min(1.0, n / float(fullCreditN))
            score = exp * penalty
            if score > bestScore
                bestScore := score
                bestIdx := i

bestTier  = bestIdx / 3
bestStrat = bestIdx % 3
bestTierStr  = bestTier == 0 ? "W" : bestTier == 1 ? "M" : "S"
bestStratStr = bestStrat == 0 ? "A (Hold)" : bestStrat == 1 ? "B (Scale)" : "C (BE+Hold)"

// =============================================================================
// COMPACT TABLE — only Recommendation + Entry Quality
// =============================================================================
f_pos(p) =>
    switch p
        "top_right"     => position.top_right
        "top_left"      => position.top_left
        "bottom_right"  => position.bottom_right
        "bottom_left"   => position.bottom_left
        "middle_right"  => position.middle_right
        "middle_left"   => position.middle_left
        => position.top_right

f_size(s) =>
    switch s
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        => size.small

var table tbl = table.new(f_pos(tablePos), 2, 14, border_width=1, frame_color=color.gray, frame_width=1)

if tableView != "Hide" and barstate.islast
    cBlack = color.new(color.black, 10)
    cNavy  = color.new(color.navy, 0)
    cGreen = color.new(color.green, 30)
    cRed   = color.new(color.red, 30)
    cAmber = color.new(#854f0b, 30)
    cGray  = color.new(color.gray, 50)
    sz = f_size(tableSizeIn)
    table.clear(tbl, 0, 0, 1, 13)
    headerSuffix = pendingABC ? " . PENDING" : ""
    table.cell(tbl, 0, 0, "WVP-E v3.6.1 . " + tableView + headerSuffix, text_color=color.white, bgcolor=cNavy, text_size=sz)
    table.cell(tbl, 1, 0, syminfo.ticker, text_color=color.white, bgcolor=cNavy, text_size=sz)
    
    if tableView == "Recommendation"
        statusTxt = isLearning ? "Learning (" + str.tostring(totalClosed) + "/" + str.tostring(minTradesForAuto) + ")" : "Active"
        statusCol = isLearning ? cAmber : cGreen
        table.cell(tbl, 0, 1, "Status", text_color=color.white, bgcolor=cBlack, text_size=sz)
        table.cell(tbl, 1, 1, statusTxt, text_color=color.white, bgcolor=statusCol, text_size=sz)
        table.cell(tbl, 0, 2, "Total Trades", text_color=color.white, bgcolor=cBlack, text_size=sz)
        table.cell(tbl, 1, 2, str.tostring(totalClosed), text_color=color.white, bgcolor=cBlack, text_size=sz)
        if isLearning
            table.cell(tbl, 0, 3, "Using default", text_color=color.white, bgcolor=cBlack, text_size=sz)
            table.cell(tbl, 1, 3, "Tier S + B", text_color=color.white, bgcolor=cAmber, text_size=sz)
        else
            table.cell(tbl, 0, 3, "BEST TIER", text_color=color.white, bgcolor=cBlack, text_size=sz)
            table.cell(tbl, 1, 3, bestTierStr, text_color=color.white, bgcolor=cGreen, text_size=sz)
            table.cell(tbl, 0, 4, "BEST STRATEGY", text_color=color.white, bgcolor=cBlack, text_size=sz)
            table.cell(tbl, 1, 4, bestStratStr, text_color=color.white, bgcolor=cGreen, text_size=sz)
            
            bestN = array.get(bktTrades, bestIdx)
            bestW = array.get(bktWins, bestIdx)
            bestSW = array.get(bktSumWin, bestIdx)
            bestSL = array.get(bktSumLoss, bestIdx)
            bestExpVal = bestN > 0 ? (bestSW - bestSL) / bestN : 0.0
            bestWR = bestN > 0 ? bestW / bestN * 100 : 0.0
            bestPF = bestSL > 0 ? bestSW / bestSL : (bestSW > 0 ? 99.0 : 0.0)
            
            table.cell(tbl, 0, 5, "Avg Profit", text_color=color.white, bgcolor=cBlack, text_size=sz)
            apCol = bestExpVal > 0 ? cGreen : cRed
            table.cell(tbl, 1, 5, (bestExpVal >= 0 ? "+" : "") + str.tostring(bestExpVal, "#.##") + "%", text_color=color.white, bgcolor=apCol, text_size=sz)
            
            table.cell(tbl, 0, 6, "Win Rate", text_color=color.white, bgcolor=cBlack, text_size=sz)
            wrCol = bestWR >= 50 ? cGreen : cRed
            table.cell(tbl, 1, 6, str.tostring(bestWR, "#.#") + "%", text_color=color.white, bgcolor=wrCol, text_size=sz)
            
            table.cell(tbl, 0, 7, "Profit Factor", text_color=color.white, bgcolor=cBlack, text_size=sz)
            pfCol = bestPF >= 2.0 ? cGreen : (bestPF >= 1.5 ? cAmber : cRed)
            pfTxt = bestPF >= 99 ? "inf" : str.tostring(bestPF, "#.##") + "x"
            table.cell(tbl, 1, 7, pfTxt, text_color=color.white, bgcolor=pfCol, text_size=sz)
            
            tT1 = 0
            tT2 = 0
            tT3 = 0
            tStop = 0
            for i = 0 to 8
                tT1 := tT1 + array.get(bktReachT1, i)
                tT2 := tT2 + array.get(bktReachT2, i)
                tT3 := tT3 + array.get(bktReachT3, i)
                tStop := tStop + array.get(bktHitStop, i)
            tTot = tT1 + tStop
            r1Pct = tTot > 0 ? tT1 * 100.0 / tTot : 0.0
            r2Pct = tTot > 0 ? tT2 * 100.0 / tTot : 0.0
            r3Pct = tTot > 0 ? tT3 * 100.0 / tTot : 0.0
            stPct = tTot > 0 ? tStop * 100.0 / tTot : 0.0
            
            table.cell(tbl, 0, 8, "T1/T2/T3 reach", text_color=color.white, bgcolor=cBlack, text_size=sz)
            table.cell(tbl, 1, 8, str.tostring(r1Pct, "#") + "/" + str.tostring(r2Pct, "#") + "/" + str.tostring(r3Pct, "#") + "%", text_color=color.white, bgcolor=cGreen, text_size=sz)
            
            table.cell(tbl, 0, 9, "Hit Stop", text_color=color.white, bgcolor=cBlack, text_size=sz)
            table.cell(tbl, 1, 9, str.tostring(stPct, "#") + "%", text_color=color.white, bgcolor=cRed, text_size=sz)
            
            bestBarsHeld = array.get(bktBarsHeld, bestIdx)
            avgBarsBest = bestN > 0 ? bestBarsHeld / bestN : 0
            table.cell(tbl, 0, 10, "Avg Bars (best)", text_color=color.white, bgcolor=cBlack, text_size=sz)
            table.cell(tbl, 1, 10, str.tostring(avgBarsBest) + " bars", text_color=color.white, bgcolor=cBlack, text_size=sz)
            
            if useDynamicC
                pInfoTxt = pendingABC ? str.tostring(bar_index - pendingDetectBar) + "/" + str.tostring(pendingMaxBars) + " bars" : "Confirmed: " + str.tostring(totalPendingConfirmed) + " (BO:" + str.tostring(totalConfirmedByBO) + " HL:" + str.tostring(totalConfirmedByHL) + ")"
                pInfoCol = pendingABC ? cAmber : cBlack
                table.cell(tbl, 0, 11, "Dynamic C", text_color=color.white, bgcolor=cBlack, text_size=sz)
                table.cell(tbl, 1, 11, pInfoTxt, text_color=color.white, bgcolor=pInfoCol, text_size=sz)
    
    else if tableView == "Entry Quality"
        n = array.size(tsBar)
        nIncl = 0
        sumMFE = 0.0
        sumMAE = 0.0
        sumR1 = 0.0
        nR1 = 0
        sumR2 = 0.0
        nR2 = 0
        sumR3 = 0.0
        nR3 = 0
        sumR4 = 0.0
        nR4 = 0
        nH1 = 0
        nH2 = 0
        sumTE = 0.0
        nTE = 0
        nTEW = 0
        if n > 0
            for i = 0 to n - 1
                tierI = array.get(tsTier, i)
                include = true
                if qualityScope == "Weak Tier Only" and tierI != 0
                    include := false
                if qualityScope == "Medium Tier Only" and tierI != 1
                    include := false
                if qualityScope == "Strong Tier Only" and tierI != 2
                    include := false
                if include
                    nIncl := nIncl + 1
                    ep = array.get(tsEntry, i)
                    mfe = array.get(tsMFE, i)
                    mae = array.get(tsMAE, i)
                    if ep > 0
                        sumMFE := sumMFE + (mfe - ep) / ep * 100
                        sumMAE := sumMAE + (mae - ep) / ep * 100
                    r1 = array.get(tsR1, i)
                    if not na(r1)
                        sumR1 := sumR1 + r1
                        nR1 := nR1 + 1
                    r2 = array.get(tsR2, i)
                    if not na(r2)
                        sumR2 := sumR2 + r2
                        nR2 := nR2 + 1
                    r3 = array.get(tsR3, i)
                    if not na(r3)
                        sumR3 := sumR3 + r3
                        nR3 := nR3 + 1
                    r4 = array.get(tsR4, i)
                    if not na(r4)
                        sumR4 := sumR4 + r4
                        nR4 := nR4 + 1
                    if array.get(tsHit1, i)
                        nH1 := nH1 + 1
                    if array.get(tsHit2, i)
                        nH2 := nH2 + 1
                    te = array.get(tsTrendExit, i)
                    if not na(te)
                        sumTE := sumTE + te
                        nTE := nTE + 1
                        if te > 0
                            nTEW := nTEW + 1
        avgMFE = nIncl > 0 ? sumMFE / nIncl : 0.0
        avgMAE = nIncl > 0 ? sumMAE / nIncl : 0.0
        avgR1 = nR1 > 0 ? sumR1 / nR1 : 0.0
        avgR2 = nR2 > 0 ? sumR2 / nR2 : 0.0
        avgR3 = nR3 > 0 ? sumR3 / nR3 : 0.0
        avgR4 = nR4 > 0 ? sumR4 / nR4 : 0.0
        hitR1 = nIncl > 0 ? nH1 * 100.0 / nIncl : 0.0
        hitR2 = nIncl > 0 ? nH2 * 100.0 / nIncl : 0.0
        avgTE = nTE > 0 ? sumTE / nTE : 0.0
        teWR = nTE > 0 ? nTEW * 100.0 / nTE : 0.0
        edgeRatio = math.abs(avgMAE) > 0.01 ? avgMFE / math.abs(avgMAE) : 0.0
        
        table.cell(tbl, 0, 1, "Scope", text_color=color.white, bgcolor=cBlack, text_size=sz)
        table.cell(tbl, 1, 1, qualityScope + " (n=" + str.tostring(nIncl) + ")", text_color=color.white, bgcolor=cAmber, text_size=sz)
        table.cell(tbl, 0, 2, "Avg +" + str.tostring(fwd1Bars) + "b", text_color=color.white, bgcolor=cBlack, text_size=sz)
        c1 = avgR1 > 0 ? cGreen : cRed
        table.cell(tbl, 1, 2, (avgR1 >= 0 ? "+" : "") + str.tostring(avgR1, "#.#") + "% (" + str.tostring(nR1) + ")", text_color=color.white, bgcolor=c1, text_size=sz)
        table.cell(tbl, 0, 3, "Avg +" + str.tostring(fwd2Bars) + "b", text_color=color.white, bgcolor=cBlack, text_size=sz)
        c2 = avgR2 > 0 ? cGreen : cRed
        table.cell(tbl, 1, 3, (avgR2 >= 0 ? "+" : "") + str.tostring(avgR2, "#.#") + "% (" + str.tostring(nR2) + ")", text_color=color.white, bgcolor=c2, text_size=sz)
        table.cell(tbl, 0, 4, "Avg +" + str.tostring(fwd3Bars) + "b", text_color=color.white, bgcolor=cBlack, text_size=sz)
        c3 = avgR3 > 0 ? cGreen : cRed
        table.cell(tbl, 1, 4, (avgR3 >= 0 ? "+" : "") + str.tostring(avgR3, "#.#") + "% (" + str.tostring(nR3) + ")", text_color=color.white, bgcolor=c3, text_size=sz)
        table.cell(tbl, 0, 5, "Avg +" + str.tostring(fwd4Bars) + "b", text_color=color.white, bgcolor=cBlack, text_size=sz)
        c4 = avgR4 > 0 ? cGreen : cRed
        table.cell(tbl, 1, 5, (avgR4 >= 0 ? "+" : "") + str.tostring(avgR4, "#.#") + "% (" + str.tostring(nR4) + ")", text_color=color.white, bgcolor=c4, text_size=sz)
        table.cell(tbl, 0, 6, "Avg MFE", text_color=color.white, bgcolor=cBlack, text_size=sz)
        table.cell(tbl, 1, 6, "+" + str.tostring(avgMFE, "#.#") + "%", text_color=color.white, bgcolor=cGreen, text_size=sz)
        table.cell(tbl, 0, 7, "Avg MAE", text_color=color.white, bgcolor=cBlack, text_size=sz)
        table.cell(tbl, 1, 7, str.tostring(avgMAE, "#.#") + "%", text_color=color.white, bgcolor=cRed, text_size=sz)
        table.cell(tbl, 0, 8, "Edge (MFE/MAE)", text_color=color.white, bgcolor=cBlack, text_size=sz)
        edgeCol = edgeRatio >= 2.0 ? cGreen : (edgeRatio >= 1.0 ? cAmber : cRed)
        table.cell(tbl, 1, 8, str.tostring(edgeRatio, "#.##") + "x", text_color=color.white, bgcolor=edgeCol, text_size=sz)
        table.cell(tbl, 0, 9, "Hit +" + str.tostring(hitThr1Pct, "#") + "%", text_color=color.white, bgcolor=cBlack, text_size=sz)
        h1Col = hitR1 >= 50 ? cGreen : cAmber
        table.cell(tbl, 1, 9, str.tostring(hitR1, "#") + "% (" + str.tostring(nH1) + "/" + str.tostring(nIncl) + ")", text_color=color.white, bgcolor=h1Col, text_size=sz)
        table.cell(tbl, 0, 10, "Hit +" + str.tostring(hitThr2Pct, "#") + "%", text_color=color.white, bgcolor=cBlack, text_size=sz)
        h2Col = hitR2 >= 30 ? cGreen : cAmber
        table.cell(tbl, 1, 10, str.tostring(hitR2, "#") + "% (" + str.tostring(nH2) + "/" + str.tostring(nIncl) + ")", text_color=color.white, bgcolor=h2Col, text_size=sz)
        table.cell(tbl, 0, 11, "Trend-Exit Avg", text_color=color.white, bgcolor=cBlack, text_size=sz)
        teCol = avgTE > 0 ? cGreen : cRed
        table.cell(tbl, 1, 11, (avgTE >= 0 ? "+" : "") + str.tostring(avgTE, "#.#") + "% (" + str.tostring(nTE) + ")", text_color=color.white, bgcolor=teCol, text_size=sz)
        table.cell(tbl, 0, 12, "Trend-Exit WR", text_color=color.white, bgcolor=cBlack, text_size=sz)
        teWRCol = teWR >= 50 ? cGreen : cRed
        table.cell(tbl, 1, 12, str.tostring(teWR, "#") + "%", text_color=color.white, bgcolor=teWRCol, text_size=sz)
        table.cell(tbl, 0, 13, "Trend MA", text_color=color.white, bgcolor=cBlack, text_size=sz)
        table.cell(tbl, 1, 13, "EMA(" + str.tostring(trendExitMA) + ")", text_color=color.white, bgcolor=cBlack, text_size=sz)

// =============================================================================
// ALERTS
// =============================================================================
weakI = fireWeak ? 1 : 0
medI = fireMedium ? 1 : 0
strongI = fireStrong ? 1 : 0
t1I = fireT1 ? 1 : 0
t2I = fireT2 ? 1 : 0
t3I = fireT3 ? 1 : 0
stopI = fireStop ? 1 : 0
alertcondition(weakI > 0,   "Weak Entry",   "Tier W signal fired")
alertcondition(medI > 0,    "Medium Entry", "Tier M signal fired")
alertcondition(strongI > 0, "Strong Entry", "Tier S signal fired")
alertcondition(t1I > 0,     "T1 Hit",       "Target 1 reached")
alertcondition(t2I > 0,     "T2 Hit",       "Target 2 reached")
alertcondition(t3I > 0,     "T3 Hit",       "Target 3 reached")
alertcondition(stopI > 0,   "Stop Hit",     "Stop loss triggered")
````
