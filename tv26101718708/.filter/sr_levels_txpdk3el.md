# SR Levels

- url: https://www.tradingview.com/script/TxpdK3EL-SR-Levels/
- type: indicator
- pine_id: PUB;ee1d10f3973c4b46bd8a3f92db34ef31
- version: 4.0

## Description

SR Levels  — Multi-Timeframe Support & Resistance with SR-Anchored VWAP

OVERVIEW

SR Levels Pro is an overlay indicator that plots higher-timeframe support and resistance levels on your chart with a clean, minimal layout. It focuses on widely used structural levels — previous day/week/month/year highs and lows — plus optional session levels (Asia, London, New York).

The goal is simple: show where price is relative to key reference levels, how far away each level is, and whether volume-weighted price action is accepting or rejecting a level after a touch.

This script is designed for traders who use HTF structure, session context, and level-based decision making on lower timeframes.

KEY FEATURES

• HTF Structure Levels
  Previous Day/Week/Month/Year High and Low (PDH, PDL, PWH, PWL, PMH, PML, PYH, PYL)
  Each timeframe uses a distinct color for quick identification

• Smart Level Display
  Thin cross markers on a short right-side segment — not full-width lines
  Optional proximity filter: hide levels until price is within range
  Price labels show level name, exact price, and % distance from current price
  Example: PDH 77766.4 +1.42%

• Session Levels (Optional, Off by Default)
  Previous session high, low, and open for Asia, London, and New York
  Customizable session times and timezone

• SR-Anchored VWAP
  When price touches an active S/R level, VWAP begins tracking from that anchor
  Green VWAP above anchor = potential acceptance
  Red VWAP below anchor = potential rejection
  Shaded fill between VWAP and anchor shows the acceptance/rejection gap
  Auto-deactivates after max bars or when price moves too far from the level

• Optional Signals (Off by Default)
  Triangles = bullish/bearish rejection at scored S/R levels
  Diamonds = PDH/PDL volume breakouts
  Confluence scoring, EMA trend filter, volume filter, and cooldown
  Built-in alerts for rejections and breakouts

HOW TO USE

1. Add to any chart (stocks, crypto, forex, futures).
2. Defaults show PDH, PDL, PWH, PWL. Session levels and signals are off.
3. Read right-edge labels for price and % distance from each level.
4. Watch SR-Anchored VWAP when price approaches a level for acceptance vs rejection.
5. Enable signals only if you want entry markers. Adjust score and cooldown for your timeframe.
6. For forex/futures, set Session Timezone and session hours to match your market.

SETTINGS

Core: touch tolerance, visibility range, cross segment length, price labels
HTF: toggle day/week/month/year levels and colors
Session: Asia/London/NY H/L/O with custom times
VWAP: max bars, deactivate distance, bull/bear colors
Signals: master toggle, breakout diamonds, min score, cooldown, filters

ALERTS

• SR: Long Rejection
• SR: Short Rejection
• SR: Bull Breakout (above PDH)
• SR: Bear Breakout (below PDL)

RECOMMENDED TIMEFRAMES

Intraday (1m–15m): PDH/PDL + PWH/PWL, optional sessions
Swing (1H–4H): PWH/PWL + PMH/PML
Position (D/W): PMH/PML + PYH/PYL

DISCLAIMER

This indicator is for educational and informational purposes only. It is not financial advice and does not recommend buying or selling any instrument. Trading involves risk. Past results do not guarantee future performance. Always do your own research and use proper risk management.

NOTES

HTF levels use the prior completed period high/low. Signals are optional and disabled by default. SR-Anchored VWAP accumulates on confirmed bars only.

## Source Code

````pine
//@version=6
indicator("SR Levels Pro", shorttitle="SR Levels", overlay=true, max_labels_count=200, max_lines_count=500, max_boxes_count=50)

// ========== INPUTS ==========
grpCore = "Core Settings"
srTouchTolerance = input.float(0.5, "SR Touch Tolerance %", minval=0.1, maxval=2.0, step=0.1, group=grpCore)
srVisibilityRange = input.float(2.0, "SR Visibility Range %", minval=0.5, step=0.1, group=grpCore)
alwaysShowSR = input.bool(true, "Always Show SR Lines", group=grpCore)
srRightBars = input.int(28, "SR Cross Segment (bars)", minval=8, maxval=120, group=grpCore)
showPriceLabels = input.bool(true, "Show Price Labels on Levels", group=grpCore)

grpHTF = "HTF + Prior Period Levels"
showPDH = input.bool(true, "Previous Day High", group=grpHTF)
showPDL = input.bool(true, "Previous Day Low", group=grpHTF)
showPWH = input.bool(true, "Previous Week High", group=grpHTF)
showPWL = input.bool(true, "Previous Week Low", group=grpHTF)
showPMH = input.bool(false, "Previous Month High", group=grpHTF)
showPML = input.bool(false, "Previous Month Low", group=grpHTF)
showPYH = input.bool(false, "Previous Year High", group=grpHTF)
showPYL = input.bool(false, "Previous Year Low", group=grpHTF)

grpHTFColors = "HTF Level Colors"
colorPDH = input.color(#FF4444, "PDH Color", group=grpHTFColors)
colorPDL = input.color(#00FF00, "PDL Color", group=grpHTFColors)
colorPWH = input.color(#FFA500, "PWH Color", group=grpHTFColors)
colorPWL = input.color(#FFCC66, "PWL Color", group=grpHTFColors)
colorPMH = input.color(#CC00FF, "PMH Color", group=grpHTFColors)
colorPML = input.color(#DA70D6, "PML Color", group=grpHTFColors)
colorPYH = input.color(#FFFFFF, "PYH Color", group=grpHTFColors)
colorPYL = input.color(#FFFFFF, "PYL Color", group=grpHTFColors)

grpSession = "Session Levels"
sessionTz = input.string("Etc/UTC", "Session Timezone", group=grpSession)
asiaSession = input.session("0000-0800", "Asia Session", group=grpSession)
londonSession = input.session("0800-1300", "London Session", group=grpSession)
nySession = input.session("1300-2100", "New York Session", group=grpSession)
showAsia = input.bool(false, "Show Prev Asia Levels", group=grpSession)
showLondon = input.bool(false, "Show Prev London Levels", group=grpSession)
showNY = input.bool(false, "Show Prev NY Levels", group=grpSession)
showSessionOpen = input.bool(false, "Show Prev Session Open", group=grpSession)

grpSessionColors = "Session Level Colors"
colorAsia = input.color(#00FFFF, "Asia Color", group=grpSessionColors)
colorLondon = input.color(#FFD700, "London Color", group=grpSessionColors)
colorNY = input.color(#4169E1, "NY Color", group=grpSessionColors)

grpSignals = "Signals"
showSignals = input.bool(false, "Show Signals", group=grpSignals)
showBreakoutSignals = input.bool(false, "Show Breakout Diamonds", group=grpSignals)
minSignalScore = input.int(20, "Minimum Signal Score", minval=5, maxval=80, group=grpSignals)
signalCooldown = input.int(8, "Signal Cooldown (bars)", minval=1, maxval=100, group=grpSignals)
useTrendFilter = input.bool(true, "Use EMA Trend Filter", group=grpSignals)
useVolumeFilter = input.bool(true, "Use Volume Spike Filter", group=grpSignals)
breakoutVolMult = input.float(1.2, "Breakout Volume Multiplier", minval=1.0, maxval=3.0, step=0.1, group=grpSignals)

// ========== FUTURE STRUCTURE ZONES (Pivot Extension) ==========
grpFuture = "Future Structure Zones"
showFutureRes = input.bool(true, "Future Resistance (Short Zones)", group=grpFuture)
showFutureSup = input.bool(true, "Future Support (Long Zones)", group=grpFuture)
futureTrendReq = input.bool(true, "Only show when trending", group=grpFuture)
futureZoneOpacity = input.int(85, "Zone opacity", minval=50, maxval=95, group=grpFuture)
futureRightBars = input.int(28, "Future Zone Cross Segment (bars)", minval=8, maxval=120, group=grpFuture)
futurePivotLookback = input.int(5, "Pivot Lookback", minval=3, maxval=10, group=grpFuture)
futurePivotDepth = input.int(6, "Future Reference Depth (older pivots)", minval=2, maxval=15, group=grpFuture)
futureAvgMoves = input.int(3, "Future Move Average Count", minval=1, maxval=6, group=grpFuture)
colorFutureRes = input.color(#FF8800, "Future Resistance Color", group=grpFuture)
colorFutureSup = input.color(#00CCFF, "Future Support Color", group=grpFuture)

// ========== SR-ANCHORED VWAP INPUTS ==========
grpVWAP = "SR-Anchored VWAP"
showSRVWAP = input.bool(true, "Show SR-Anchored VWAP", group=grpVWAP)
srVwapLifetime = input.string("Extend Until Next Zone", "VWAP Lifetime", options=["Extend Until Next Zone", "Auto Deactivate"], group=grpVWAP)
srVwapMaxBars = input.int(100, "VWAP Max Bars (Auto mode)", minval=20, maxval=500, group=grpVWAP)
srVwapDeactivatePct = input.float(1.5, "VWAP Deactivate % (Auto mode)", minval=0.5, maxval=5.0, step=0.5, group=grpVWAP)
srVwapResetMode = input.string("Re-anchor On New Touch", "VWAP Reset Mode", options=["Re-anchor On New Touch", "Hold Until Deactivate"], group=grpVWAP)
srVwapMinBarsBeforeSwitch = input.int(0, "Min Bars Before Re-anchor", minval=0, maxval=100, group=grpVWAP)
srVwapColorBull = input.color(#00FF88, "VWAP Bull Color", group=grpVWAP)
srVwapColorBear = input.color(#FF4444, "VWAP Bear Color", group=grpVWAP)

// ========== CORE CALCS ==========
atr = ta.atr(14)
ema50 = ta.ema(close, 50)
ema200 = ta.ema(close, 200)
emaBull = close > ema50 and ema50 > ema200
emaBear = close < ema50 and ema50 < ema200

volAvg = ta.sma(volume, 20)
volSpike = volume > volAvg * breakoutVolMult

// ========== FUTURE STRUCTURE ZONES (Pivot Extension) ==========
ph = ta.pivothigh(high, futurePivotLookback, futurePivotLookback)
pl = ta.pivotlow(low, futurePivotLookback, futurePivotLookback)

// Store pivot history so future zones can reference older structure, not just immediate pivots.
var float[] phHist = array.new_float()
var float[] phCloseHist = array.new_float()
var float[] plHist = array.new_float()
var float[] plCloseHist = array.new_float()

getHist(float[] arr, int idx) =>
    array.size(arr) > idx ? array.get(arr, idx) : na

if not na(ph)
    array.unshift(phHist, ph)
    array.unshift(phCloseHist, close[futurePivotLookback])
    if array.size(phHist) > 30
        array.pop(phHist)
    if array.size(phCloseHist) > 30
        array.pop(phCloseHist)

if not na(pl)
    array.unshift(plHist, pl)
    array.unshift(plCloseHist, close[futurePivotLookback])
    if array.size(plHist) > 30
        array.pop(plHist)
    if array.size(plCloseHist) > 30
        array.pop(plCloseHist)

resBaseClose = getHist(phCloseHist, 0)
supBaseClose = getHist(plCloseHist, 0)

resDistSum = 0.0
resDistCount = 0
if not na(resBaseClose)
    for i = 0 to futureAvgMoves - 1
        idx = futurePivotDepth - 1 + i
        oldPH = getHist(phHist, idx)
        if not na(oldPH)
            d = resBaseClose - oldPH
            if d > 0
                resDistSum += d
                resDistCount += 1

supDistSum = 0.0
supDistCount = 0
if not na(supBaseClose)
    for i = 0 to futureAvgMoves - 1
        idx = futurePivotDepth - 1 + i
        oldPL = getHist(plHist, idx)
        if not na(oldPL)
            d = oldPL - supBaseClose
            if d > 0
                supDistSum += d
                supDistCount += 1

resDist = resDistCount > 0 ? resDistSum / resDistCount : na
supDist = supDistCount > 0 ? supDistSum / supDistCount : na

// Future Resistance Zone (Short): project from latest pivot-close using averaged older-pivot thrust.
futureResHigh = not na(resBaseClose) and not na(resDist) ? resBaseClose + resDist : na
futureResLow  = not na(resBaseClose) and not na(resDist) ? resBaseClose + resDist * 0.85 : na

// Future Support Zone (Long): project from latest pivot-close using averaged older-pivot drop.
futureSupLow  = not na(supBaseClose) and not na(supDist) ? supBaseClose - supDist : na
futureSupHigh = not na(supBaseClose) and not na(supDist) ? supBaseClose - supDist * 0.85 : na

// Trend filter for future zones (reuse ema trend, or always show)
futureTrending = not futureTrendReq or emaBull or emaBear

// Future zone touch detection (for potential signal integration)
futureResTouch = not na(futureResLow) and not na(futureResHigh) and low <= futureResHigh and high >= futureResLow
futureSupTouch = not na(futureSupLow) and not na(futureSupHigh) and low <= futureSupHigh and high >= futureSupLow

// ========== SR LEVELS ==========
pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)
pwh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_on)
pwl = request.security(syminfo.tickerid, "W", low[1], lookahead=barmerge.lookahead_on)
pmh = request.security(syminfo.tickerid, "M", high[1], lookahead=barmerge.lookahead_on)
pml = request.security(syminfo.tickerid, "M", low[1], lookahead=barmerge.lookahead_on)
pyh = request.security(syminfo.tickerid, "12M", high[1], lookahead=barmerge.lookahead_on)
pyl = request.security(syminfo.tickerid, "12M", low[1], lookahead=barmerge.lookahead_on)

// ========== SESSION LEVEL TRACKING ==========
inAsia = not na(time(timeframe.period, asiaSession, sessionTz))
inLondon = not na(time(timeframe.period, londonSession, sessionTz))
inNY = not na(time(timeframe.period, nySession, sessionTz))

asiaStart = inAsia and not inAsia[1]
asiaEnd = not inAsia and inAsia[1]
londonStart = inLondon and not inLondon[1]
londonEnd = not inLondon and inLondon[1]
nyStart = inNY and not inNY[1]
nyEnd = not inNY and inNY[1]

var float asiaCurHigh = na
var float asiaCurLow = na
var float asiaCurOpen = na
var float asiaPrevHigh = na
var float asiaPrevLow = na
var float asiaPrevOpen = na

var float londonCurHigh = na
var float londonCurLow = na
var float londonCurOpen = na
var float londonPrevHigh = na
var float londonPrevLow = na
var float londonPrevOpen = na

var float nyCurHigh = na
var float nyCurLow = na
var float nyCurOpen = na
var float nyPrevHigh = na
var float nyPrevLow = na
var float nyPrevOpen = na

if asiaStart
    asiaCurHigh := high
    asiaCurLow := low
    asiaCurOpen := open
if inAsia
    asiaCurHigh := math.max(nz(asiaCurHigh, high), high)
    asiaCurLow := math.min(nz(asiaCurLow, low), low)
if asiaEnd
    asiaPrevHigh := asiaCurHigh
    asiaPrevLow := asiaCurLow
    asiaPrevOpen := asiaCurOpen

if londonStart
    londonCurHigh := high
    londonCurLow := low
    londonCurOpen := open
if inLondon
    londonCurHigh := math.max(nz(londonCurHigh, high), high)
    londonCurLow := math.min(nz(londonCurLow, low), low)
if londonEnd
    londonPrevHigh := londonCurHigh
    londonPrevLow := londonCurLow
    londonPrevOpen := londonCurOpen

if nyStart
    nyCurHigh := high
    nyCurLow := low
    nyCurOpen := open
if inNY
    nyCurHigh := math.max(nz(nyCurHigh, high), high)
    nyCurLow := math.min(nz(nyCurLow, low), low)
if nyEnd
    nyPrevHigh := nyCurHigh
    nyPrevLow := nyCurLow
    nyPrevOpen := nyCurOpen

// ========== VISIBILITY HELPERS (GPS_Pro pattern) ==========
isNearSR(level) =>
    not na(level) and math.abs(close - level) / close < srVisibilityRange / 100

showSRLevel(level, enabled) =>
    enabled and (alwaysShowSR or isNearSR(level))

touchSR(level) =>
    not na(level) and low <= level + close * (srTouchTolerance / 100) and high >= level - close * (srTouchTolerance / 100)

bullReject(level) =>
    touchSR(level) and close > level and close > open

bearReject(level) =>
    touchSR(level) and close < level and close < open

// ========== SR-ANCHORED VWAP ==========
pickNearest(float level, bool enabled, float bestLvl, float bestDist) =>
    if enabled and not na(level)
        d = math.abs(close - level)
        if d < bestDist
            [level, d]
        else
            [bestLvl, bestDist]
    else
        [bestLvl, bestDist]

[nA, dA] = pickNearest(pdh, showPDH, float(na), 1e10)
[nB, dB] = pickNearest(pdl, showPDL, nA, dA)
[nC, dC] = pickNearest(pwh, showPWH, nB, dB)
[nD, dD] = pickNearest(pwl, showPWL, nC, dC)
[nE, dE] = pickNearest(pmh, showPMH, nD, dD)
[nF, dF] = pickNearest(pml, showPML, nE, dE)
[nG, dG] = pickNearest(pyh, showPYH, nF, dF)
[nH, dH] = pickNearest(pyl, showPYL, nG, dG)
[nI, dI] = pickNearest(asiaPrevHigh, showAsia, nH, dH)
[nJ, dJ] = pickNearest(asiaPrevLow, showAsia, nI, dI)
[nK, dK] = pickNearest(londonPrevHigh, showLondon, nJ, dJ)
[nL, dL] = pickNearest(londonPrevLow, showLondon, nK, dK)
[nM, dM] = pickNearest(nyPrevHigh, showNY, nL, dL)
[nearestLevel, nearestDist] = pickNearest(nyPrevLow, showNY, nM, dM)

pickTouchedNearest(float level, bool enabled, float bestLvl, float bestDist) =>
    if enabled and touchSR(level)
        d = math.abs(close - level)
        if d < bestDist
            [level, d]
        else
            [bestLvl, bestDist]
    else
        [bestLvl, bestDist]

[tA, tdA] = pickTouchedNearest(pdh, showPDH, float(na), 1e10)
[tB, tdB] = pickTouchedNearest(pdl, showPDL, tA, tdA)
[tC, tdC] = pickTouchedNearest(pwh, showPWH, tB, tdB)
[tD, tdD] = pickTouchedNearest(pwl, showPWL, tC, tdC)
[tE, tdE] = pickTouchedNearest(pmh, showPMH, tD, tdD)
[tF, tdF] = pickTouchedNearest(pml, showPML, tE, tdE)
[tG, tdG] = pickTouchedNearest(pyh, showPYH, tF, tdF)
[tH, tdH] = pickTouchedNearest(pyl, showPYL, tG, tdG)
[tI, tdI] = pickTouchedNearest(asiaPrevHigh, showAsia, tH, tdH)
[tJ, tdJ] = pickTouchedNearest(asiaPrevLow, showAsia, tI, tdI)
[tK, tdK] = pickTouchedNearest(londonPrevHigh, showLondon, tJ, tdJ)
[tL, tdL] = pickTouchedNearest(londonPrevLow, showLondon, tK, tdK)
[tM, tdM] = pickTouchedNearest(nyPrevHigh, showNY, tL, tdL)
[touchedLevel, touchedDist] = pickTouchedNearest(nyPrevLow, showNY, tM, tdM)

var float srVwapSum = 0.0
var float srVwapVolSum = 0.0
var float srVwap = na
var bool srVwapActive = false
var int srVwapBars = 0
var float srVwapAnchor = na

withinTouch = not na(touchedLevel)
newLevelTouch = withinTouch and (na(srVwapAnchor) or math.abs(touchedLevel - srVwapAnchor) / close > srTouchTolerance / 100)
canSwitchAnchor = not srVwapActive or srVwapBars >= srVwapMinBarsBeforeSwitch
newAnchor = srVwapLifetime == "Extend Until Next Zone" ? (newLevelTouch and canSwitchAnchor) : srVwapResetMode == "Re-anchor On New Touch" ? (newLevelTouch and canSwitchAnchor) : (not srVwapActive and newLevelTouch)

if newAnchor
    srVwapSum := 0.0
    srVwapVolSum := 0.0
    srVwapActive := true
    srVwapBars := 0
    srVwapAnchor := touchedLevel

if srVwapActive
    typicalPrice = hlc3
    srVwapSum += typicalPrice * volume
    srVwapVolSum += volume
    srVwap := srVwapVolSum > 0 ? srVwapSum / srVwapVolSum : na
    srVwapBars += 1
    if srVwapLifetime == "Auto Deactivate" and (srVwapBars > srVwapMaxBars or (not na(srVwapAnchor) and math.abs(close - srVwapAnchor) / close > srVwapDeactivatePct / 100))
        srVwapActive := false
        srVwap := na

srVwapBullState = not na(srVwap) and not na(srVwapAnchor) and srVwap > srVwapAnchor
srVwapColor = not na(srVwap) and not na(srVwapAnchor) ? (srVwapBullState ? srVwapColorBull : srVwapColorBear) : color.gray

// ========== SCORING ENGINE ==========
longScore = 0.0
shortScore = 0.0

// HTF levels
longScore += bullReject(pdl) ? 18 : 0
longScore += bullReject(pwl) ? 22 : 0
longScore += bullReject(pml) ? 26 : 0
longScore += bullReject(pyl) ? 30 : 0

shortScore += bearReject(pdh) ? 18 : 0
shortScore += bearReject(pwh) ? 22 : 0
shortScore += bearReject(pmh) ? 26 : 0
shortScore += bearReject(pyh) ? 30 : 0

// Session levels
longScore += bullReject(asiaPrevLow) ? 10 : 0
longScore += bullReject(londonPrevLow) ? 12 : 0
longScore += bullReject(nyPrevLow) ? 14 : 0
shortScore += bearReject(asiaPrevHigh) ? 10 : 0
shortScore += bearReject(londonPrevHigh) ? 12 : 0
shortScore += bearReject(nyPrevHigh) ? 14 : 0

// Confluence boosters
nearHTF = isNearSR(pwh) or isNearSR(pwl) or isNearSR(pmh) or isNearSR(pml) or isNearSR(pyh) or isNearSR(pyl)
nearSession = isNearSR(asiaPrevHigh) or isNearSR(asiaPrevLow) or isNearSR(londonPrevHigh) or isNearSR(londonPrevLow) or isNearSR(nyPrevHigh) or isNearSR(nyPrevLow)

longScore += nearHTF ? 8 : 0
shortScore += nearHTF ? 8 : 0
longScore += nearSession ? 4 : 0
shortScore += nearSession ? 4 : 0
longScore += volSpike ? 6 : 0
shortScore += volSpike ? 6 : 0

// Final signals
longSignalRaw = longScore >= minSignalScore
shortSignalRaw = shortScore >= minSignalScore

longSignal = longSignalRaw and (not useTrendFilter or emaBull) and (not useVolumeFilter or volSpike)
shortSignal = shortSignalRaw and (not useTrendFilter or emaBear) and (not useVolumeFilter or volSpike)

// Cooldown
var int lastLongBar = na
var int lastShortBar = na
longReady = na(lastLongBar) or bar_index - lastLongBar > signalCooldown
shortReady = na(lastShortBar) or bar_index - lastShortBar > signalCooldown

plotLong = longSignal and longReady
plotShort = shortSignal and shortReady

if plotLong
    lastLongBar := bar_index
if plotShort
    lastShortBar := bar_index

// Breakouts
bullBreakout = close > pdh and close[1] <= pdh and volSpike
bearBreakout = close < pdl and close[1] >= pdl and volSpike

// ========== SR PLOTS (thin crosses, right segment only — no full-width lines) ==========
inRightSegment = bar_index >= last_bar_index - srRightBars
inFutureSegment = bar_index >= last_bar_index - futureRightBars

srPlot(level, enabled, lvlColor) =>
    showSRLevel(level, enabled) and inRightSegment ? level : na

// Future Zone plots (dashed lines, right segment)
futureResHighPlot = plot(showFutureRes and futureTrending and inFutureSegment ? futureResHigh : na, "Future Res High", color=color.new(colorFutureRes, futureZoneOpacity), linewidth=1, style=plot.style_line)
futureResLowPlot  = plot(showFutureRes and futureTrending and inFutureSegment ? futureResLow  : na, "Future Res Low",  color=color.new(colorFutureRes, futureZoneOpacity + 10), linewidth=1, style=plot.style_line)
fill(futureResHighPlot, futureResLowPlot, color=color.new(colorFutureRes, 90), title="Future Resistance Zone")

futureSupHighPlot = plot(showFutureSup and futureTrending and inFutureSegment ? futureSupHigh : na, "Future Sup High", color=color.new(colorFutureSup, futureZoneOpacity + 10), linewidth=1, style=plot.style_line)
futureSupLowPlot  = plot(showFutureSup and futureTrending and inFutureSegment ? futureSupLow  : na, "Future Sup Low",  color=color.new(colorFutureSup, futureZoneOpacity), linewidth=1, style=plot.style_line)
fill(futureSupHighPlot, futureSupLowPlot, color=color.new(colorFutureSup, 90), title="Future Support Zone")

// HTF — levels only, no fills
pdhPlot = plot(srPlot(pdh, showPDH, colorPDH), "PDH", color=color.new(colorPDH, 40), linewidth=1, style=plot.style_cross)
pdlPlot = plot(srPlot(pdl, showPDL, colorPDL), "PDL", color=color.new(colorPDL, 40), linewidth=1, style=plot.style_cross)

pwhPlot = plot(srPlot(pwh, showPWH, colorPWH), "PWH", color=color.new(colorPWH, 40), linewidth=1, style=plot.style_cross)
pwlPlot = plot(srPlot(pwl, showPWL, colorPWL), "PWL", color=color.new(colorPWL, 40), linewidth=1, style=plot.style_cross)

pmhPlot = plot(srPlot(pmh, showPMH, colorPMH), "PMH", color=color.new(colorPMH, 40), linewidth=1, style=plot.style_cross)
pmlPlot = plot(srPlot(pml, showPML, colorPML), "PML", color=color.new(colorPML, 40), linewidth=1, style=plot.style_cross)

pyhPlot = plot(srPlot(pyh, showPYH, colorPYH), "PYH", color=color.new(colorPYH, 40), linewidth=1, style=plot.style_cross)
pylPlot = plot(srPlot(pyl, showPYL, colorPYL), "PYL", color=color.new(colorPYL, 40), linewidth=1, style=plot.style_cross)

// Session
plot(srPlot(asiaPrevHigh, showAsia, colorAsia), "Asia H", color=color.new(colorAsia, 40), linewidth=1, style=plot.style_cross)
plot(srPlot(asiaPrevLow, showAsia, colorAsia), "Asia L", color=color.new(colorAsia, 40), linewidth=1, style=plot.style_cross)
plot(srPlot(asiaPrevOpen, showAsia and showSessionOpen, colorAsia), "Asia O", color=color.new(colorAsia, 55), linewidth=1, style=plot.style_cross)
plot(srPlot(londonPrevHigh, showLondon, colorLondon), "London H", color=color.new(colorLondon, 40), linewidth=1, style=plot.style_cross)
plot(srPlot(londonPrevLow, showLondon, colorLondon), "London L", color=color.new(colorLondon, 40), linewidth=1, style=plot.style_cross)
plot(srPlot(londonPrevOpen, showLondon and showSessionOpen, colorLondon), "London O", color=color.new(colorLondon, 55), linewidth=1, style=plot.style_cross)
plot(srPlot(nyPrevHigh, showNY, colorNY), "NY H", color=color.new(colorNY, 40), linewidth=1, style=plot.style_cross)
plot(srPlot(nyPrevLow, showNY, colorNY), "NY L", color=color.new(colorNY, 40), linewidth=1, style=plot.style_cross)
plot(srPlot(nyPrevOpen, showNY and showSessionOpen, colorNY), "NY O", color=color.new(colorNY, 55), linewidth=1, style=plot.style_cross)

// ========== PRICE LABELS (right edge, on the level) ==========
var label[] srLabels = array.new_label()

priceLabelText(name, price) =>
    pct = (price - close) / close * 100
    sign = pct >= 0 ? "+" : ""
    name + " " + str.tostring(price, format.mintick) + " " + sign + str.tostring(pct, "#.##") + "%"

pushPriceLabel(float level, bool enabled, string name, color lvlColor) =>
    if showPriceLabels and showSRLevel(level, enabled)
        array.push(srLabels, label.new(bar_index + 2, level, priceLabelText(name, level), style=label.style_label_left, color=color.new(lvlColor, 85), textcolor=lvlColor, size=size.tiny))

if barstate.islast
    if array.size(srLabels) > 0
        for i = 0 to array.size(srLabels) - 1
            label.delete(array.get(srLabels, i))
    array.clear(srLabels)
    pushPriceLabel(pdh, showPDH, "PDH", colorPDH)
    pushPriceLabel(pdl, showPDL, "PDL", colorPDL)
    pushPriceLabel(pwh, showPWH, "PWH", colorPWH)
    pushPriceLabel(pwl, showPWL, "PWL", colorPWL)
    pushPriceLabel(pmh, showPMH, "PMH", colorPMH)
    pushPriceLabel(pml, showPML, "PML", colorPML)
    pushPriceLabel(pyh, showPYH, "PYH", colorPYH)
    pushPriceLabel(pyl, showPYL, "PYL", colorPYL)
    pushPriceLabel(asiaPrevHigh, showAsia, "Asia H", colorAsia)
    pushPriceLabel(asiaPrevLow, showAsia, "Asia L", colorAsia)
    pushPriceLabel(asiaPrevOpen, showAsia and showSessionOpen, "Asia O", colorAsia)
    pushPriceLabel(londonPrevHigh, showLondon, "Lon H", colorLondon)
    pushPriceLabel(londonPrevLow, showLondon, "Lon L", colorLondon)
    pushPriceLabel(londonPrevOpen, showLondon and showSessionOpen, "Lon O", colorLondon)
    pushPriceLabel(nyPrevHigh, showNY, "NY H", colorNY)
    pushPriceLabel(nyPrevLow, showNY, "NY L", colorNY)
    pushPriceLabel(nyPrevOpen, showNY and showSessionOpen, "NY O", colorNY)
    // Future zone labels
    pushPriceLabel(futureResHigh, showFutureRes and futureTrending, "FutRes", colorFutureRes)
    pushPriceLabel(futureSupLow,  showFutureSup and futureTrending, "FutSup", colorFutureSup)

// ========== SIGNALS (triangles = entries, diamonds = breakouts) ==========
plotshape(showSignals and plotLong, title="Long", style=shape.triangleup, location=location.belowbar, color=color.new(color.lime, 0), size=size.tiny)
plotshape(showSignals and plotShort, title="Short", style=shape.triangledown, location=location.abovebar, color=color.new(color.red, 0), size=size.tiny)
plotshape(showSignals and showBreakoutSignals and bullBreakout, title="Breakout Up", style=shape.diamond, location=location.belowbar, color=color.new(color.green, 0), size=size.tiny)
plotshape(showSignals and showBreakoutSignals and bearBreakout, title="Breakout Down", style=shape.diamond, location=location.abovebar, color=color.new(color.red, 0), size=size.tiny)

// SR-Anchored VWAP plot — extends continuously until next zone re-anchor
srVwapFillColor = showSRVWAP and srVwapActive ? color.new(srVwapColor, 90) : na
srVwapAnchorPlot = plot(showSRVWAP and srVwapActive ? srVwapAnchor : na, "SR VWAP Anchor", color=color.new(srVwapColor, 50), linewidth=1, style=plot.style_line)
srVwapPlot = plot(showSRVWAP and srVwapActive ? srVwap : na, "SR VWAP Line", color=color.new(srVwapColor, 20), linewidth=2, style=plot.style_line)
fill(srVwapAnchorPlot, srVwapPlot, color=srVwapFillColor, title="SR VWAP Fill")

// ========== ALERTS ==========
alertcondition(plotLong, "SR: Long Rejection", "Bullish rejection at support on {{ticker}}")
alertcondition(plotShort, "SR: Short Rejection", "Bearish rejection at resistance on {{ticker}}")
alertcondition(bullBreakout, "SR: Bull Breakout", "Bullish breakout above PDH on {{ticker}}")
alertcondition(bearBreakout, "SR: Bear Breakout", "Bearish breakout below PDL on {{ticker}}")
alertcondition(showFutureRes and futureTrending and not na(futureResHigh) and close >= futureResLow and close <= futureResHigh, "SR: Near Future Resistance", "Price approaching future resistance zone on {{ticker}}")
alertcondition(showFutureSup and futureTrending and not na(futureSupLow) and close >= futureSupLow and close <= futureSupHigh, "SR: Near Future Support", "Price approaching future support zone on {{ticker}}")
````
