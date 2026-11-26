# Advanced Bullish Pattern Engine Tuple Syntax

- url: https://www.tradingview.com/script/dU55qAbj-Advanced-Bullish-Pattern-Engine-Tuple-Syntax/
- type: indicator
- pine_id: PUB;60a519314ad74f9d8ca676cde1a79ad9
- version: 1.0

## Description

Here’s the complete TradingView Pine Script v5 with:

* ✅ True Minervini Stage 2 Trend Template
* ✅ 50 / 150 / 200 SMA alignment
* ✅ Rising 200 SMA
* ✅ 52-week high/low filters
* ✅ 1-Year Relative Strength vs NIFTY
* ✅ RS Rating
* ✅ RVOL
* ✅ Liquidity Filter (₹10 Cr+ average traded value)
* ✅ NR7
* ✅ Inside Bar
* ✅ Breakout Detection
* ✅ ATR Stop Loss
* ✅ Institutional Accumulation Detection
* ✅ Quality Score
* ✅ Elite Buy Signal
* ✅ Dashboard

## Source Code

````pine
//@version=6
indicator("Advanced Bullish Pattern Engine v6 Fixed Tuple Syntax", overlay=true, max_labels_count=300)

//====================================================
// Inputs
//====================================================
groupTrend   = "Trend"
groupPattern = "Pattern Logic"
groupPivot   = "Pivot Settings"
groupRisk    = "Risk"
groupDisplay = "Display"

emaFastLen = input.int(20, "EMA Fast", minval=1, group=groupTrend)
emaMidLen  = input.int(50, "EMA Mid", minval=1, group=groupTrend)
emaSlowLen = input.int(200, "EMA Slow", minval=1, group=groupTrend)

rsiLen   = input.int(14, "RSI Length", minval=1, group=groupTrend)
rsiMin   = input.int(55, "Min RSI", minval=1, maxval=100, group=groupTrend)
rocLen   = input.int(10, "ROC Length", minval=1, group=groupTrend)
volLen   = input.int(20, "Volume Avg Length", minval=1, group=groupTrend)
volMult  = input.float(1.5, "Volume Spike Multiplier", minval=0.1, step=0.1, group=groupTrend)

pivotLeft       = input.int(4, "Pivot Left Bars", minval=2, group=groupPivot)
pivotRight      = input.int(4, "Pivot Right Bars", minval=2, group=groupPivot)
maxStoredPivots = input.int(40, "Max Stored Pivots", minval=10, maxval=100, group=groupPivot)

shoulderTolPct      = input.float(8.0, "Shoulder Symmetry %", minval=1.0, step=0.5, group=groupPattern)
timeSymTolBars      = input.int(12, "Time Symmetry Tolerance Bars", minval=1, group=groupPattern)
cupLipTolPct        = input.float(5.0, "Cup Lip Symmetry %", minval=1.0, step=0.5, group=groupPattern)
cupMinDepthPct      = input.float(8.0, "Cup Min Depth %", minval=1.0, step=0.5, group=groupPattern)
cupMaxDepthPct      = input.float(35.0, "Cup Max Depth %", minval=5.0, step=0.5, group=groupPattern)
handleMaxRetracePct = input.float(45.0, "Handle Max Retrace % of Cup", minval=10.0, maxval=80.0, step=1.0, group=groupPattern)
doubleBottomTolPct  = input.float(2.5, "Double Bottom Low Tolerance %", minval=0.2, step=0.1, group=groupPattern)
flagMaxPullbackPct  = input.float(38.0, "Flag Max Pullback %", minval=5.0, step=1.0, group=groupPattern)
triangleTolPct      = input.float(1.0, "Ascending Triangle Resistance Tolerance %", minval=0.2, step=0.1, group=groupPattern)

atrLen     = input.int(14, "ATR Length", minval=1, group=groupRisk)
maxRiskPct = input.float(4.0, "Max Risk %", minval=0.1, step=0.1, group=groupRisk)

showTable       = input.bool(true, "Show Dashboard", group=groupDisplay)
showLabels      = input.bool(true, "Show Labels", group=groupDisplay)
showEMAs        = input.bool(true, "Show EMAs", group=groupDisplay)
showPivotMarks  = input.bool(false, "Show Pivot Marks", group=groupDisplay)
highlightStrong = input.bool(true, "Highlight Strong Signals", group=groupDisplay)

//====================================================
// Core calculations
//====================================================
emaFast = ta.ema(close, emaFastLen)
emaMid  = ta.ema(close, emaMidLen)
emaSlow = ta.ema(close, emaSlowLen)

rsiVal   = ta.rsi(close, rsiLen)
rocVal   = ta.roc(close, rocLen)
avgVol   = ta.sma(volume, volLen)
volRatio = avgVol > 0 ? volume / avgVol : na
atrVal   = ta.atr(atrLen)

trendStrong  = close > emaFast and emaFast > emaMid and emaMid > emaSlow
trendHealthy = close > emaMid and emaMid > emaSlow
momentumPass = rsiVal >= rsiMin and rocVal > 0
volumePass   = na(volume) ? false : volume > avgVol * volMult
rsiStatus    = rsiVal >= 65 ? "Strong" : rsiVal >= rsiMin ? "Positive" : rsiVal >= 45 ? "Neutral" : "Weak"

bodySize     = math.abs(close - open)
rangeSize    = math.max(high - low, syminfo.mintick)
upperWick    = high - math.max(open, close)
lowerWick    = math.min(open, close) - low
bullClosePos = (close - low) / rangeSize

bullishEngulf = close > open and close[1] < open[1] and open <= close[1] and close >= open[1]
hammerLike    = close > open and lowerWick > bodySize * 1.5 and upperWick <= bodySize and bullClosePos > 0.6
strongBullBar = close > open and bullClosePos > 0.7 and bodySize / rangeSize > 0.5
insideBar     = high < high[1] and low > low[1]
nr7           = (high - low) < ta.lowest(high - low, 7)[1]
candlePass    = bullishEngulf or hammerLike or strongBullBar

//====================================================
// Pivot detection
//====================================================
ph = ta.pivothigh(high, pivotLeft, pivotRight)
pl = ta.pivotlow(low, pivotLeft, pivotRight)

phBar = bar_index - pivotRight
plBar = bar_index - pivotRight

plotshape(showPivotMarks and not na(ph), title="Pivot High", style=shape.xcross, location=location.abovebar, color=color.red, size=size.tiny, offset=-pivotRight)
plotshape(showPivotMarks and not na(pl), title="Pivot Low", style=shape.xcross, location=location.belowbar, color=color.lime, size=size.tiny, offset=-pivotRight)

//====================================================
// Pivot arrays
//====================================================
var float[] pivotHighVals = array.new_float()
var int[] pivotHighBars = array.new_int()
var float[] pivotLowVals = array.new_float()
var int[] pivotLowBars = array.new_int()

if not na(ph)
    array.push(pivotHighVals, ph)
    array.push(pivotHighBars, phBar)
    if array.size(pivotHighVals) > maxStoredPivots
        array.shift(pivotHighVals)
        array.shift(pivotHighBars)

if not na(pl)
    array.push(pivotLowVals, pl)
    array.push(pivotLowBars, plBar)
    if array.size(pivotLowVals) > maxStoredPivots
        array.shift(pivotLowVals)
        array.shift(pivotLowBars)

//====================================================
// Helpers
//====================================================
f_pctDiff(a, b) =>
    float base = math.max(math.abs(a), syminfo.mintick)
    math.abs(a - b) / base * 100.0

f_betweenBars(barA, barB, testBar) =>
    testBar >= math.min(barA, barB) and testBar <= math.max(barA, barB)

f_getHighValFromEnd(offset) =>
    int sz = array.size(pivotHighVals)
    sz > offset ? array.get(pivotHighVals, sz - 1 - offset) : na

f_getHighBarFromEnd(offset) =>
    int sz = array.size(pivotHighBars)
    sz > offset ? array.get(pivotHighBars, sz - 1 - offset) : na

f_getLowValFromEnd(offset) =>
    int sz = array.size(pivotLowVals)
    sz > offset ? array.get(pivotLowVals, sz - 1 - offset) : na

f_getLowBarFromEnd(offset) =>
    int sz = array.size(pivotLowBars)
    sz > offset ? array.get(pivotLowBars, sz - 1 - offset) : na

f_findHighestPivotHighBetween(startBar, endBar) =>
    float bestVal = na
    int bestBar = na
    int sz = array.size(pivotHighVals)
    if sz > 0
        for i = 0 to sz - 1
            float hVal = array.get(pivotHighVals, i)
            int hBar = array.get(pivotHighBars, i)
            if f_betweenBars(startBar, endBar, hBar)
                if na(bestVal) or hVal > bestVal
                    bestVal := hVal
                    bestBar := hBar
    [bestVal, bestBar]

f_findLowestPivotLowBetween(startBar, endBar) =>
    float bestVal = na
    int bestBar = na
    int sz = array.size(pivotLowVals)
    if sz > 0
        for i = 0 to sz - 1
            float lVal = array.get(pivotLowVals, i)
            int lBar = array.get(pivotLowBars, i)
            if f_betweenBars(startBar, endBar, lBar)
                if na(bestVal) or lVal < bestVal
                    bestVal := lVal
                    bestBar := lBar
    [bestVal, bestBar]

f_lineValueAt(bar1, price1, bar2, price2, targetBar) =>
    int span = bar2 - bar1
    float out = na
    if span != 0
        out := price1 + (price2 - price1) * (targetBar - bar1) / span
    out

f_registerPattern(_currName, _currBar, _currPriority, _currScore, _currStop, _newName, _isValid, _confirmBar, _priority, _score, _stop) =>
    string outName = _currName
    int outBar = _currBar
    int outPriority = _currPriority
    float outScore = _currScore
    float outStop = _currStop

    if _isValid and not na(_confirmBar)
        bool shouldReplace = false
        if outName == "None"
            shouldReplace := true
        else if _priority > outPriority
            shouldReplace := true
        else if _priority == outPriority and (na(outBar) or _confirmBar > outBar)
            shouldReplace := true
        else if _priority == outPriority and _confirmBar == outBar and (na(outScore) or _score > outScore)
            shouldReplace := true

        if shouldReplace
            outName := _newName
            outBar := _confirmBar
            outPriority := _priority
            outScore := _score
            outStop := _stop

    [outName, outBar, outPriority, outScore, outStop]

//====================================================
// Winner state
//====================================================
var string latestPatternName = "None"
var int latestPatternBar = na
var int latestPatternPriority = 0
var float latestPatternScore = na
var float latestPatternStop = na

latestPatternName := "None"
latestPatternBar := na
latestPatternPriority := 0
latestPatternScore := na
latestPatternStop := na

bullishPatternCount = 0

//====================================================
// Breakout
//====================================================
prevHigh20 = ta.highest(high[1], 20)
breakoutLevel = prevHigh20 * 1.003
patternBreakout = close > breakoutLevel and close > emaFast and volumePass
breakoutScore = (trendStrong ? 20.0 : 0.0) + (momentumPass ? 15.0 : 0.0) + (volumePass ? 15.0 : 0.0) + 10.0

if patternBreakout
    bullishPatternCount += 1

[breakoutNameTmp, breakoutBarTmp, breakoutPriorityTmp, breakoutScoreTmp, breakoutStopTmp] = f_registerPattern(latestPatternName, latestPatternBar, latestPatternPriority, latestPatternScore, latestPatternStop, "Breakout", patternBreakout, bar_index, 40, breakoutScore, emaFast)
latestPatternName := breakoutNameTmp
latestPatternBar := breakoutBarTmp
latestPatternPriority := breakoutPriorityTmp
latestPatternScore := breakoutScoreTmp
latestPatternStop := breakoutStopTmp

//====================================================
// Pullback
//====================================================
nearEmaFast = math.abs(close - emaFast) <= atrVal
patternPullback = trendStrong and nearEmaFast and close > emaFast and strongBullBar
pullbackScore = (trendStrong ? 20.0 : 0.0) + (momentumPass ? 15.0 : 0.0) + (candlePass ? 10.0 : 0.0) + 8.0

if patternPullback
    bullishPatternCount += 1

[pullNameTmp, pullBarTmp, pullPriorityTmp, pullScoreTmp, pullStopTmp] = f_registerPattern(latestPatternName, latestPatternBar, latestPatternPriority, latestPatternScore, latestPatternStop, "Pullback", patternPullback, bar_index, 35, pullbackScore, emaMid)
latestPatternName := pullNameTmp
latestPatternBar := pullBarTmp
latestPatternPriority := pullPriorityTmp
latestPatternScore := pullScoreTmp
latestPatternStop := pullStopTmp

//====================================================
// Compression breakout
//====================================================
patternCompression = trendHealthy and insideBar and nr7 and volume < avgVol
patternExpansion = patternCompression[1] and close > high[1] and volumePass
compressionScore = (trendHealthy ? 10.0 : 0.0) + (volumePass ? 15.0 : 0.0) + 12.0

if patternExpansion
    bullishPatternCount += 1

[compNameTmp, compBarTmp, compPriorityTmp, compScoreTmp, compStopTmp] = f_registerPattern(latestPatternName, latestPatternBar, latestPatternPriority, latestPatternScore, latestPatternStop, "Compression BO", patternExpansion, bar_index, 45, compressionScore, low[1])
latestPatternName := compNameTmp
latestPatternBar := compBarTmp
latestPatternPriority := compPriorityTmp
latestPatternScore := compScoreTmp
latestPatternStop := compStopTmp

//====================================================
// Inverse Head and Shoulders
//====================================================
float ihsLs = na
float ihsHead = na
float ihsRs = na
int ihsLsBar = na
int ihsHeadBar = na
int ihsRsBar = na
float ihsNeckLeft = na
float ihsNeckRight = na
int ihsNeckLeftBar = na
int ihsNeckRightBar = na
float ihsNeckline = na
bool patternIHS = false
float ihsScore = na
float ihsStop = na
int ihsConfirmBar = na

if array.size(pivotLowVals) >= 3
    ihsRs := f_getLowValFromEnd(0)
    ihsHead := f_getLowValFromEnd(1)
    ihsLs := f_getLowValFromEnd(2)
    ihsRsBar := f_getLowBarFromEnd(0)
    ihsHeadBar := f_getLowBarFromEnd(1)
    ihsLsBar := f_getLowBarFromEnd(2)

    [ihsNeckLeft, ihsNeckLeftBar] = f_findHighestPivotHighBetween(ihsLsBar, ihsHeadBar)
    [ihsNeckRight, ihsNeckRightBar] = f_findHighestPivotHighBetween(ihsHeadBar, ihsRsBar)

    shoulderSym = not na(ihsLs) and not na(ihsRs) and f_pctDiff(ihsLs, ihsRs) <= shoulderTolPct
    headLower = not na(ihsHead) and not na(ihsLs) and not na(ihsRs) and ihsHead < ihsLs and ihsHead < ihsRs
    timeSym = not na(ihsLsBar) and not na(ihsHeadBar) and not na(ihsRsBar) and math.abs((ihsHeadBar - ihsLsBar) - (ihsRsBar - ihsHeadBar)) <= timeSymTolBars
    necklineReady = not na(ihsNeckLeft) and not na(ihsNeckRight) and not na(ihsNeckLeftBar) and not na(ihsNeckRightBar)

    if necklineReady
        ihsNeckline := f_lineValueAt(ihsNeckLeftBar, ihsNeckLeft, ihsNeckRightBar, ihsNeckRight, bar_index)

    breakoutIHS = necklineReady and not na(ihsNeckline) and close > ihsNeckline and volumePass and close > emaFast

    patternIHS := shoulderSym and headLower and timeSym and breakoutIHS
    ihsScore := (trendHealthy ? 10.0 : 0.0) + (momentumPass ? 15.0 : 0.0) + (volumePass ? 15.0 : 0.0) + 20.0
    ihsStop := ihsRs
    ihsConfirmBar := bar_index

if patternIHS
    bullishPatternCount += 1

[ihsNameTmp, ihsBarTmp, ihsPriorityTmp, ihsScoreTmp2, ihsStopTmp] = f_registerPattern(latestPatternName, latestPatternBar, latestPatternPriority, latestPatternScore, latestPatternStop, "Inv H&S", patternIHS, ihsConfirmBar, 90, ihsScore, ihsStop)
latestPatternName := ihsNameTmp
latestPatternBar := ihsBarTmp
latestPatternPriority := ihsPriorityTmp
latestPatternScore := ihsScoreTmp2
latestPatternStop := ihsStopTmp

//====================================================
// Cup and Handle
//====================================================
float cupLeftLip = na
float cupRightLip = na
float cupBottom = na
int cupLeftLipBar = na
int cupRightLipBar = na
int cupBottomBar = na
bool cupValid = false
bool handleValid = false
bool patternCupHandle = false
float cupDepthPct = na
float handleDepthPct = na
float cupScore = na
float cupStop = na
int cupConfirmBar = na

if array.size(pivotHighVals) >= 2 and array.size(pivotLowVals) >= 1
    cupRightLip := f_getHighValFromEnd(0)
    cupLeftLip := f_getHighValFromEnd(1)
    cupRightLipBar := f_getHighBarFromEnd(0)
    cupLeftLipBar := f_getHighBarFromEnd(1)

    [cupBottom, cupBottomBar] = f_findLowestPivotLowBetween(cupLeftLipBar, cupRightLipBar)

    lipSym = not na(cupLeftLip) and not na(cupRightLip) and f_pctDiff(cupLeftLip, cupRightLip) <= cupLipTolPct
    cupDepthPct := not na(cupBottom) ? ((math.min(cupLeftLip, cupRightLip) - cupBottom) / math.max(math.min(cupLeftLip, cupRightLip), syminfo.mintick)) * 100.0 : na
    cupValid := lipSym and not na(cupDepthPct) and cupDepthPct >= cupMinDepthPct and cupDepthPct <= cupMaxDepthPct and not na(cupBottomBar) and cupBottomBar > cupLeftLipBar and cupBottomBar < cupRightLipBar

    barsSinceRightLip = not na(cupRightLipBar) ? math.max(1, bar_index - cupRightLipBar + 1) : 1
    handleLow = ta.lowest(low, barsSinceRightLip)
    handleDepthPct := cupValid ? ((cupRightLip - handleLow) / math.max(cupRightLip - cupBottom, syminfo.mintick)) * 100.0 : na
    handleValid := cupValid and not na(handleDepthPct) and handleDepthPct >= 0 and handleDepthPct <= handleMaxRetracePct

    breakoutCup = cupValid and handleValid and close > math.max(cupLeftLip, cupRightLip) and volumePass and close > emaFast

    patternCupHandle := breakoutCup
    cupScore := (trendHealthy ? 10.0 : 0.0) + (momentumPass ? 15.0 : 0.0) + (volumePass ? 15.0 : 0.0) + 18.0
    cupStop := emaFast
    cupConfirmBar := bar_index

if patternCupHandle
    bullishPatternCount += 1

[cupNameTmp, cupBarTmp, cupPriorityTmp, cupScoreTmp2, cupStopTmp] = f_registerPattern(latestPatternName, latestPatternBar, latestPatternPriority, latestPatternScore, latestPatternStop, "Cup&Handle", patternCupHandle, cupConfirmBar, 85, cupScore, cupStop)
latestPatternName := cupNameTmp
latestPatternBar := cupBarTmp
latestPatternPriority := cupPriorityTmp
latestPatternScore := cupScoreTmp2
latestPatternStop := cupStopTmp

//====================================================
// Double Bottom
//====================================================
float dbLow1 = na
float dbLow2 = na
int dbLow1Bar = na
int dbLow2Bar = na
float dbNeck = na
int dbNeckBar = na
bool patternDoubleBottom = false
float dbScore = na
float dbStop = na
int dbConfirmBar = na

if array.size(pivotLowVals) >= 2
    dbLow2 := f_getLowValFromEnd(0)
    dbLow1 := f_getLowValFromEnd(1)
    dbLow2Bar := f_getLowBarFromEnd(0)
    dbLow1Bar := f_getLowBarFromEnd(1)

    [dbNeck, dbNeckBar] = f_findHighestPivotHighBetween(dbLow1Bar, dbLow2Bar)

    sameLows = not na(dbLow1) and not na(dbLow2) and f_pctDiff(dbLow1, dbLow2) <= doubleBottomTolPct
    breakoutDB = not na(dbNeck) and close > dbNeck and volumePass

    patternDoubleBottom := sameLows and breakoutDB and close > emaFast
    dbScore := (trendHealthy ? 10.0 : 0.0) + (momentumPass ? 15.0 : 0.0) + (volumePass ? 15.0 : 0.0) + 16.0
    dbStop := dbLow2
    dbConfirmBar := bar_index

if patternDoubleBottom
    bullishPatternCount += 1

[dbNameTmp, dbBarTmp, dbPriorityTmp, dbScoreTmp2, dbStopTmp] = f_registerPattern(latestPatternName, latestPatternBar, latestPatternPriority, latestPatternScore, latestPatternStop, "Double Bottom", patternDoubleBottom, dbConfirmBar, 75, dbScore, dbStop)
latestPatternName := dbNameTmp
latestPatternBar := dbBarTmp
latestPatternPriority := dbPriorityTmp
latestPatternScore := dbScoreTmp2
latestPatternStop := dbStopTmp

//====================================================
// Bull Flag
//====================================================
impulseHigh20 = ta.highest(high, 20)
impulseLow20 = ta.lowest(low, 20)
impulseRange20 = impulseHigh20 - impulseLow20
flagPullbackPct = impulseRange20 > syminfo.mintick ? ((impulseHigh20 - close) / impulseRange20) * 100.0 : na
flagTrend = trendHealthy and close > emaMid
flagConsolidation = not na(flagPullbackPct) and flagPullbackPct > 5 and flagPullbackPct <= flagMaxPullbackPct
flagBreakout = flagTrend and flagConsolidation and close > high[1] and volumePass
flagScore = (trendStrong ? 20.0 : 0.0) + (momentumPass ? 15.0 : 0.0) + (volumePass ? 15.0 : 0.0) + 14.0

if flagBreakout
    bullishPatternCount += 1

[flagNameTmp, flagBarTmp, flagPriorityTmp, flagScoreTmp2, flagStopTmp] = f_registerPattern(latestPatternName, latestPatternBar, latestPatternPriority, latestPatternScore, latestPatternStop, "Bull Flag", flagBreakout, bar_index, 70, flagScore, emaMid)
latestPatternName := flagNameTmp
latestPatternBar := flagBarTmp
latestPatternPriority := flagPriorityTmp
latestPatternScore := flagScoreTmp2
latestPatternStop := flagStopTmp

//====================================================
// Ascending Triangle
//====================================================
float triHigh1 = na
float triHigh2 = na
int triHigh1Bar = na
int triHigh2Bar = na
float triLow1 = na
float triLow2 = na
int triLow1Bar = na
int triLow2Bar = na
bool patternAscendingTriangle = false
float triScore = na
float triStop = na
int triConfirmBar = na

if array.size(pivotHighVals) >= 2 and array.size(pivotLowVals) >= 2
    triHigh2 := f_getHighValFromEnd(0)
    triHigh1 := f_getHighValFromEnd(1)
    triHigh2Bar := f_getHighBarFromEnd(0)
    triHigh1Bar := f_getHighBarFromEnd(1)

    triLow2 := f_getLowValFromEnd(0)
    triLow1 := f_getLowValFromEnd(1)
    triLow2Bar := f_getLowBarFromEnd(0)
    triLow1Bar := f_getLowBarFromEnd(1)

    flatTop = not na(triHigh1) and not na(triHigh2) and f_pctDiff(triHigh1, triHigh2) <= triangleTolPct
    risingLows = not na(triLow1) and not na(triLow2) and triLow2 > triLow1
    triResistance = not na(triHigh1) and not na(triHigh2) ? math.max(triHigh1, triHigh2) : na
    triBreakout = not na(triResistance) and close > triResistance and volumePass

    patternAscendingTriangle := flatTop and risingLows and triBreakout and close > emaFast
    triScore := (trendHealthy ? 10.0 : 0.0) + (momentumPass ? 15.0 : 0.0) + (volumePass ? 15.0 : 0.0) + 15.0
    triStop := triLow2
    triConfirmBar := bar_index

if patternAscendingTriangle
    bullishPatternCount += 1

[triNameTmp, triBarTmp, triPriorityTmp, triScoreTmp2, triStopTmp] = f_registerPattern(latestPatternName, latestPatternBar, latestPatternPriority, latestPatternScore, latestPatternStop, "Asc Triangle", patternAscendingTriangle, triConfirmBar, 65, triScore, triStop)
latestPatternName := triNameTmp
latestPatternBar := triBarTmp
latestPatternPriority := triPriorityTmp
latestPatternScore := triScoreTmp2
latestPatternStop := triStopTmp

//====================================================
// Risk / final score
//====================================================
riskPct = na(latestPatternStop) ? na : ((close - latestPatternStop) / close) * 100.0
riskPass = na(riskPct) ? false : riskPct > 0 and riskPct <= maxRiskPct

finalScore = nz(latestPatternScore, 0) + (riskPass ? 10 : 0) + (candlePass ? 5 : 0)
scoreRounded = math.round(finalScore)

grade = scoreRounded >= 90 ? "A+" : scoreRounded >= 85 ? "A" : scoreRounded >= 70 ? "B" : scoreRounded >= 55 ? "C" : "D"
candidate = latestPatternName != "None" and scoreRounded >= 70
strongBuy = latestPatternName != "None" and scoreRounded >= 85 and barstate.isconfirmed

//====================================================
// Visuals
//====================================================
plot(showEMAs ? emaFast : na, "EMA Fast", color=color.new(color.teal, 0), linewidth=2)
plot(showEMAs ? emaMid : na, "EMA Mid", color=color.new(color.orange, 0), linewidth=2)
plot(showEMAs ? emaSlow : na, "EMA Slow", color=color.new(color.gray, 20), linewidth=2)

bgcolor(highlightStrong and strongBuy ? color.new(color.green, 88) : na)

plotshape(candidate and not strongBuy, title="Candidate Marker", style=shape.circle, location=location.belowbar, color=color.new(color.yellow, 0), size=size.tiny)
plotshape(strongBuy, title="Strong Buy Marker", style=shape.triangleup, location=location.belowbar, color=color.new(color.green, 0), size=size.small)

if showLabels and strongBuy
    label.new(bar_index, low, "BUY " + grade + "\n" + latestPatternName + "\nRSI: " + str.tostring(rsiVal, "#.0") + "\nScore: " + str.tostring(scoreRounded), yloc=yloc.belowbar, style=label.style_label_up, color=color.new(color.green, 0), textcolor=color.white, size=size.small)

//====================================================
// Alerts
//====================================================
alertcondition(candidate and barstate.isconfirmed, title="Bullish Candidate", message="Bullish candidate on {{ticker}}")
alertcondition(strongBuy, title="Strong Buy", message="Strong buy on {{ticker}}")
alertcondition(patternIHS and barstate.isconfirmed, title="Inverse Head and Shoulders", message="Inverse Head and Shoulders breakout on {{ticker}}")
alertcondition(patternCupHandle and barstate.isconfirmed, title="Cup and Handle", message="Cup and Handle breakout on {{ticker}}")
alertcondition(patternDoubleBottom and barstate.isconfirmed, title="Double Bottom", message="Double Bottom breakout on {{ticker}}")
alertcondition(flagBreakout and barstate.isconfirmed, title="Bull Flag", message="Bull Flag breakout on {{ticker}}")
alertcondition(patternAscendingTriangle and barstate.isconfirmed, title="Ascending Triangle", message="Ascending Triangle breakout on {{ticker}}")

//====================================================
// Dashboard
//====================================================
var table dash = table.new(position.top_right, 2, 11, border_width=1)

signalText = strongBuy ? "STRONG BUY" : candidate ? "WATCH" : "NO TRADE"
signalColor = strongBuy ? color.lime : candidate ? color.yellow : color.red
marketState = trendStrong ? "Bullish" : close > emaSlow ? "Neutral" : "Weak"
rsiColor = rsiVal >= 65 ? color.lime : rsiVal >= rsiMin ? color.yellow : color.red
volColor = volumePass ? color.lime : color.red
patternColor = latestPatternName != "None" ? color.aqua : color.gray

if barstate.islast and showTable
    table.cell(dash, 0, 0, "Metric", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 0, "Value", text_color=color.white, bgcolor=color.black)

    table.cell(dash, 0, 1, "Trend")
    table.cell(dash, 1, 1, trendStrong ? "STRONG" : trendHealthy ? "HEALTHY" : "WEAK", text_color=trendStrong ? color.lime : trendHealthy ? color.yellow : color.red)

    table.cell(dash, 0, 2, "Market State")
    table.cell(dash, 1, 2, marketState, text_color=trendStrong ? color.lime : color.orange)

    table.cell(dash, 0, 3, "Momentum")
    table.cell(dash, 1, 3, momentumPass ? "PASS" : "FAIL", text_color=momentumPass ? color.lime : color.red)

    table.cell(dash, 0, 4, "Volume Ratio")
    table.cell(dash, 1, 4, na(volRatio) ? "NA" : str.tostring(volRatio, "#.00") + "x", text_color=volColor)

    table.cell(dash, 0, 5, "RSI Value")
    table.cell(dash, 1, 5, str.tostring(rsiVal, "#.0"), text_color=rsiColor)

    table.cell(dash, 0, 6, "RSI Status")
    table.cell(dash, 1, 6, rsiStatus, text_color=rsiColor)

    table.cell(dash, 0, 7, "Pattern")
    table.cell(dash, 1, 7, latestPatternName, text_color=patternColor)

    table.cell(dash, 0, 8, "Pattern Count")
    table.cell(dash, 1, 8, str.tostring(bullishPatternCount), text_color=bullishPatternCount >= 2 ? color.lime : color.white)

    table.cell(dash, 0, 9, "Risk %")
    table.cell(dash, 1, 9, na(riskPct) ? "NA" : str.tostring(riskPct, "#.##"), text_color=riskPass ? color.lime : color.red)

    table.cell(dash, 0, 10, "Score / Signal")
    table.cell(dash, 1, 10, str.tostring(scoreRounded) + " / " + signalText, text_color=signalColor)
````
