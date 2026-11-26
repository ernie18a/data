# BTC Sniper Signals (High Accuracy, No Repaint)

- url: https://www.tradingview.com/script/eQ10Me0K-BTC-Sniper-Signals-High-Accuracy-No-Repaint/
- type: indicator
- pine_id: PUB;c1b23a39f82642438ec17697702d2765
- version: 1.0

## Description

High-accuracy BTC signals built to catch real moves — not fakeouts.

This system focuses on:

trend continuation entries
liquidity grabs (smart money moves)
momentum confirmation
precise entry timing

It avoids:

late signals
choppy conditions
overextended entries

What makes it different:

dynamic scoring system
smart filters instead of lagging confirmations
built specifically for BTC behavior

✔ No repaint
✔ Fast signals for 5m–1H
✔ Designed for consistency, not noise

## Source Code

````pine
//@version=6
indicator("BTC ICSS", shorttitle="BTC ICSS", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=100)

// ============================================================================
// INPUTS — SIGNAL ENGINE
// ============================================================================

grpMode = "Signal Mode"
signalMode   = input.string("Conservative", "Mode", options=["Conservative","Aggressive"], group=grpMode)
breakoutMode = input.bool(true, "Allow Breakout / Reversal Against Structure", group=grpMode)
useEarlyEntry= input.bool(true, "Allow Early Entries (lower threshold)", group=grpMode)
grpEarly = "Early Entry Quality"
earlyRsiBullMin = input.float(52.0, "Early Bull RSI Min", minval=45.0, maxval=70.0, step=0.5, group=grpEarly)
earlyRsiBearMax = input.float(48.0, "Early Bear RSI Max", minval=30.0, maxval=55.0, step=0.5, group=grpEarly)
requireFreshMacdForEarly = input.bool(true, "Require Fresh MACD For Early Entries", group=grpEarly)

grpTrend = "Trend Filters (EMA / SMA)"
useEma20   = input.bool(true,  "Use EMA 20",  group=grpTrend)
useEma50   = input.bool(true,  "Use EMA 50",  group=grpTrend)
useEma200  = input.bool(true,  "Use EMA 200", group=grpTrend)
useSma200  = input.bool(true,  "Use SMA 200 Confirmation", group=grpTrend)
lenEma20   = input.int(20,  "EMA 20 Length",  minval=1, group=grpTrend)
lenEma50   = input.int(50,  "EMA 50 Length",  minval=1, group=grpTrend)
lenEma200  = input.int(200, "EMA 200 Length", minval=1, group=grpTrend)
lenSma200  = input.int(200, "SMA 200 Length", minval=1, group=grpTrend)
useAntiChase = input.bool(true, "Anti-Chase Filter (EMA 50)", group=grpTrend)
maxDistPct   = input.float(3.5, "Max % Distance From EMA 50", minval=0.5, step=0.1, group=grpTrend)

grpVwap   = "VWAP"
useVwap   = input.bool(true, "Use VWAP", group=grpVwap)
vwapMode  = input.string("Standard", "VWAP Mode", options=["Standard","Strict","Bias Only"], group=grpVwap)
vwapSlope = input.int(5, "VWAP Slope Lookback", minval=1, group=grpVwap)
useVwapDistanceFilter = input.bool(true, "Anti-Chase Filter (VWAP Distance)", group=grpVwap)
maxVwapDistPct        = input.float(2.5, "Max % Distance From VWAP", minval=0.2, step=0.1, group=grpVwap)
vwapRetestAtrMult = input.float(0.25, "VWAP Retest Tolerance (x ATR)", minval=0.05, step=0.05, group=grpVwap)

grpMfi      = "Money Flow"
useMfi      = input.bool(true, "Use MFI", group=grpMfi)
mfiLen      = input.int(14, "MFI Length", minval=2, group=grpMfi)
mfiBullTh   = input.float(50.0, "MFI Bullish Threshold", group=grpMfi)
mfiBearTh   = input.float(50.0, "MFI Bearish Threshold", group=grpMfi)
mfiOb       = input.float(80.0, "MFI Overbought", group=grpMfi)
mfiOs       = input.float(20.0, "MFI Oversold", group=grpMfi)
useCmfExtra = input.bool(false, "Additionally require CMF alignment", group=grpMfi)
cmfLen      = input.int(20, "CMF Length", minval=2, group=grpMfi)

grpRsi       = "RSI"
useRsi       = input.bool(true, "Use RSI", group=grpRsi)
rsiLen       = input.int(14, "RSI Length", minval=2, group=grpRsi)
rsiOb        = input.float(70.0, "RSI Overbought", group=grpRsi)
rsiOs        = input.float(30.0, "RSI Oversold", group=grpRsi)
rsiBullTh    = input.float(50.0, "RSI Bullish Threshold", group=grpRsi)
rsiBearTh    = input.float(50.0, "RSI Bearish Threshold", group=grpRsi)
rsiChopBlock = input.bool(true, "Suppress signals when RSI 45-55", group=grpRsi)
grpRsiQual  = "RSI Quality"
minRsiDelta = input.float(0.5, "Min RSI Delta", minval=0.1, step=0.1, group=grpRsiQual)

grpMacd     = "MACD"
useMacd     = input.bool(true, "Use MACD", group=grpMacd)
macdFast    = input.int(12, "Fast", group=grpMacd)
macdSlow    = input.int(26, "Slow", group=grpMacd)
macdSig     = input.int(9,  "Signal", group=grpMacd)
macdConfMode= input.string("Cross OR Histogram", "MACD Confirmation", options=["Cross Only","Histogram Only","Cross OR Histogram","Cross AND Histogram"], group=grpMacd)
macdFreshBars = input.int(8, "MACD Cross Freshness (bars)", minval=1, maxval=50, group=grpMacd, tooltip="MACD cross must have occurred within this many bars to count. Prevents stale 'above signal line' from inflating score.")

grpSR        = "Support / Resistance"
pivotLeft    = input.int(10, "Pivot Left",  minval=1, group=grpSR)
pivotRight   = input.int(5,  "Pivot Right", minval=1, group=grpSR)
maxSR        = input.int(5,  "Max Levels", minval=1, maxval=10, group=grpSR)
srProxAtr    = input.float(1.0, "Proximity (x ATR)", minval=0.1, step=0.1, group=grpSR)
breakConfBars= input.int(1, "Breakout Confirmation Bars", minval=1, group=grpSR)
srMaxAge     = input.int(150, "Max Level Age (bars)", minval=20, maxval=500, group=grpSR, tooltip="S/R levels older than this are auto-removed.")

grpAtr       = "ATR / Volatility Filter"
useAtrFilter = input.bool(true, "Use ATR Filter", group=grpAtr)
atrLen       = input.int(14, "ATR Length", minval=1, group=grpAtr)
atrMinPct    = input.float(0.15, "Min ATR % of Price", minval=0.0, step=0.05, group=grpAtr)
grpChop = "Chop Filter"
useEmaCompressionChop = input.bool(true, "Use EMA Compression Chop Filter", group=grpChop)
emaCompressionAtrMult = input.float(0.25, "EMA Compression Max Distance (x ATR)", minval=0.05, step=0.05, group=grpChop)

grpVol       = "Volume Filter"
useVolFilter = input.bool(false, "Require Above-Average Volume", group=grpVol)
volLen       = input.int(20,  "Volume MA Length", minval=1, group=grpVol)
volMult      = input.float(1.05, "Volume Multiplier", minval=0.1, step=0.05, group=grpVol)
breakoutVolMult = input.float(1.10, "Breakout Volume Multiplier", minval=0.5, step=0.05, group=grpVol)

grpCandle        = "Candle Quality"
useCandleFilter  = input.bool(true, "Use Candle Quality Filter", group=grpCandle)
minBodyPct       = input.float(40.0, "Min Body % of Range", minval=10.0, maxval=90.0, step=1.0, group=grpCandle)
bullClosePosMin  = input.float(0.55, "Bull Close Position Min", minval=0.5, maxval=1.0, step=0.05, group=grpCandle)
bearClosePosMax  = input.float(0.45, "Bear Close Position Max", minval=0.0, maxval=0.5, step=0.05, group=grpCandle)

grpAdx           = "ADX Trend Strength"
useAdxFilter     = input.bool(false, "Use ADX Filter", group=grpAdx)
adxLen           = input.int(14, "ADX Length", minval=2, group=grpAdx)
adxThreshold     = input.float(15.0, "ADX Minimum", minval=5.0, step=1.0, group=grpAdx)

grpHtf     = "Higher Timeframe"
useHtf     = input.bool(true, "Use HTF Bias", group=grpHtf)
htfTf      = input.timeframe("240", "HTF", group=grpHtf)
htfUseEma  = input.bool(true, "HTF EMA 200 Bias", group=grpHtf)
htfUseVwap = input.bool(true, "HTF VWAP Bias", group=grpHtf)
useHtfMomentum   = input.bool(false, "Require HTF Momentum for Strong Signals", group=grpHtf)
wHtfMomentum     = input.int(1, "Weight: HTF Momentum Boost", minval=0, maxval=3, group=grpHtf)

grpScore           = "Scoring / Thresholds"
buyThreshold       = input.int(5, "Buy Threshold",        minval=1, maxval=15, group=grpScore)
strongBuyThreshold = input.int(7, "Strong Buy Threshold", minval=1, maxval=15, group=grpScore)
sellThreshold      = input.int(5, "Sell Threshold",       minval=1, maxval=15, group=grpScore)
strongSellThresh   = input.int(7, "Strong Sell Threshold",minval=1, maxval=15, group=grpScore)
wStructure = input.int(3, "Weight: Structure",  minval=0, group=grpScore)
wVwap      = input.int(2, "Weight: VWAP",       minval=0, group=grpScore)
wMfi       = input.int(1, "Weight: Money Flow", minval=0, group=grpScore)
wRsi       = input.int(1, "Weight: RSI",        minval=0, group=grpScore)
wMacd      = input.int(1, "Weight: MACD",       minval=0, group=grpScore)
wSR        = input.int(1, "Weight: S/R",        minval=0, group=grpScore)
wHtf       = input.int(1, "Weight: HTF",        minval=0, group=grpScore)
minScoreGap        = input.int(1, "Min Score Gap", minval=0, maxval=10, group=grpScore)
requireRisingScore = input.bool(false, "Require Rising Score", group=grpScore)

grpCD         = "Cooldown / Anti-Duplicate"
cooldownBars  = input.int(8, "Min bars between signals", minval=0, group=grpCD)
useTrendReset = input.bool(true, "One Signal Per Move (Trend Reset)", group=grpCD)

grpVis         = "Visuals"
showMAs        = input.bool(true,  "Show Moving Averages", group=grpVis)
showVwapLine   = input.bool(true,  "Show VWAP",            group=grpVis)
showSR         = input.bool(true,  "Show S/R Levels",      group=grpVis)
showBgBias     = input.bool(false, "Shade Bias Background",group=grpVis)
showBarColor   = input.bool(true,  "Color Bars on Strong Signals", group=grpVis)
showDashboard  = input.bool(true,  "Show Dashboard",       group=grpVis)
dashPos        = input.string("top_right", "Dashboard Position", options=["top_right","top_left","bottom_right","bottom_left","middle_right"], group=grpVis)

// ============================================================================
// CORE CALCULATIONS
// ============================================================================

ema20  = ta.ema(close, lenEma20)
ema50  = ta.ema(close, lenEma50)
ema200 = ta.ema(close, lenEma200)
sma200 = ta.sma(close, lenSma200)

vwap        = ta.vwap(hlc3)
vwapRising  = vwap > vwap[vwapSlope]
vwapFalling = vwap < vwap[vwapSlope]

mfiVal      = ta.mfi(hlc3, mfiLen)
mfiRising   = mfiVal > mfiVal[1]
mfiFalling  = mfiVal < mfiVal[1]

cmfRange = high - low
cmfMult  = cmfRange == 0 ? 0.0 : ((close - low) - (high - close)) / cmfRange
volSum = math.sum(volume, cmfLen)
flowSum = math.sum(cmfMult * volume, cmfLen)
cmfVal = volSum != 0 ? flowSum / volSum : 0.0

rsiVal     = ta.rsi(close, rsiLen)

[macdLine, signalLine, histLine] = ta.macd(close, macdFast, macdSlow, macdSig)

atrVal = ta.atr(atrLen)
atrPct = close == 0 ? 0.0 : atrVal / close * 100.0
volMa  = ta.sma(volume, volLen)
breakoutVolOk = volume > volMa * breakoutVolMult

[diPlus, diMinus, adxVal] = ta.dmi(adxLen, adxLen)

candleRange  = high - low
candleBody   = math.abs(close - open)
bodyPct      = candleRange > 0 ? (candleBody / candleRange) * 100.0 : 0.0
closePos     = candleRange > 0 ? (close - low) / candleRange : 0.5
strongBody   = bodyPct >= minBodyPct
bullCandleOk = (not useCandleFilter) or (strongBody and closePos >= bullClosePosMin)
bearCandleOk = (not useCandleFilter) or (strongBody and closePos <= bearClosePosMax)

adxOk = (not useAdxFilter) or (adxVal >= adxThreshold)

// ============================================================================
// TREND STRUCTURE
// ============================================================================

bullStructPass = (not useEma20 or close > ema20) and (not useEma50 or (close > ema50 and ema20 > ema50)) and (not useEma200 or (close > ema200 and ema50 > ema200)) and (not useSma200 or close > sma200)
bearStructPass = (not useEma20 or close < ema20) and (not useEma50 or (close < ema50 and ema20 < ema50)) and (not useEma200 or (close < ema200 and ema50 < ema200)) and (not useSma200 or close < sma200)

ema20CrossUp = ta.crossover(ema20, ema50)
ema20CrossDn = ta.crossunder(ema20, ema50)

distFromEma50Pct = ema50 != 0 ? math.abs(close - ema50) / ema50 * 100.0 : 0.0
extendedAbove    = useAntiChase and close > ema50 and math.abs(close - ema50) > atrVal * 3.0
extendedBelow    = useAntiChase and close < ema50 and math.abs(close - ema50) > atrVal * 3.0

distFromVwapPct = vwap != 0 ? math.abs(close - vwap) / vwap * 100.0 : 0.0
tooFarAboveVwap = useVwapDistanceFilter and close > vwap and math.abs(close - vwap) > atrVal * 2.0
tooFarBelowVwap = useVwapDistanceFilter and close < vwap and math.abs(close - vwap) > atrVal * 2.0

// ============================================================================
// VWAP LOGIC
// ============================================================================

priceAboveVwap = close > vwap
priceBelowVwap = close < vwap
vwapTol = atrVal * vwapRetestAtrMult

vwapRetestHoldBull = priceAboveVwap and low <= vwap + vwapTol and close > vwap and vwapRising
vwapRetestFailBear = priceBelowVwap and high >= vwap - vwapTol and close < vwap and vwapFalling

vwapBull = switch vwapMode
    "Standard"  => priceAboveVwap and vwapRising
    "Strict"    => vwapRetestHoldBull
    "Bias Only" => priceAboveVwap
    => false

vwapBear = switch vwapMode
    "Standard"  => priceBelowVwap and vwapFalling
    "Strict"    => vwapRetestFailBear
    "Bias Only" => priceBelowVwap
    => false

// ============================================================================
// COMPONENT CONFIRMATIONS — FIX #1: disabled = false, NOT true
// ============================================================================

mfiBullRaw  = mfiVal > mfiBullTh and mfiRising
mfiBearRaw  = mfiVal < mfiBearTh and mfiFalling
cmfBullPass = not useCmfExtra or cmfVal > 0
cmfBearPass = not useCmfExtra or cmfVal < 0
mfiBull     = useMfi and mfiBullRaw and cmfBullPass
mfiBear     = useMfi and mfiBearRaw and cmfBearPass

rsiDelta   = rsiVal - rsiVal[1]
rsiBullRaw = rsiVal > rsiBullTh and rsiDelta >= minRsiDelta and rsiVal < rsiOb
rsiBearRaw = rsiVal < rsiBearTh and rsiDelta <= -minRsiDelta and rsiVal > rsiOs
rsiBull    = useRsi and rsiBullRaw
rsiBear    = useRsi and rsiBearRaw
rsiInChop  = rsiChopBlock and rsiVal >= 45 and rsiVal <= 55

// ============================================================================
// MACD LOGIC — FIX #2: freshness requirement
// ============================================================================

macdCrossUp  = ta.crossover(macdLine, signalLine)
macdCrossDn  = ta.crossunder(macdLine, signalLine)
macdAbove    = macdLine > signalLine
macdBelow    = macdLine < signalLine
histRising   = histLine > histLine[1]
histFalling  = histLine < histLine[1]
histPositive = histLine > 0
histNegative = histLine < 0
macdMomentumBull = histLine > histLine[1] and histLine[1] > histLine[2]
macdMomentumBear = histLine < histLine[1] and histLine[1] < histLine[2]

var int barsSinceBullCross = 999
var int barsSinceBearCross = 999
if macdCrossUp
    barsSinceBullCross := 0
else
    barsSinceBullCross += 1
if macdCrossDn
    barsSinceBearCross := 0
else
    barsSinceBearCross += 1

macdBullFresh = barsSinceBullCross <= macdFreshBars
macdBearFresh = barsSinceBearCross <= macdFreshBars

macdBullRaw = switch macdConfMode
    "Cross Only"          => macdCrossUp or (macdAbove and macdBullFresh)
    "Histogram Only"      => histPositive and histRising
    "Cross OR Histogram"  => (macdCrossUp or (macdAbove and macdBullFresh)) or (histPositive and histRising)
    "Cross AND Histogram" => (macdCrossUp or (macdAbove and macdBullFresh)) and (histPositive and histRising)
    => false

macdBearRaw = switch macdConfMode
    "Cross Only"          => macdCrossDn or (macdBelow and macdBearFresh)
    "Histogram Only"      => histNegative and histFalling
    "Cross OR Histogram"  => (macdCrossDn or (macdBelow and macdBearFresh)) or (histNegative and histFalling)
    "Cross AND Histogram" => (macdCrossDn or (macdBelow and macdBearFresh)) and (histNegative and histFalling)
    => false

macdBull = useMacd and (macdBullRaw or macdMomentumBull)
macdBear = useMacd and (macdBearRaw or macdMomentumBear)

// ============================================================================
// SUPPORT / RESISTANCE — FIX #3: age-based expiry
// ============================================================================

ph = ta.pivothigh(high, pivotLeft, pivotRight)
pl = ta.pivotlow(low,  pivotLeft, pivotRight)

var array<float> resLevels = array.new<float>()
var array<int>   resBars   = array.new<int>()
var array<float> supLevels = array.new<float>()
var array<int>   supBars   = array.new<int>()
var array<line>  resLines  = array.new<line>()
var array<line>  supLines  = array.new<line>()

if not na(ph)
    array.unshift(resLevels, ph)
    array.unshift(resBars, bar_index - pivotRight)
    if array.size(resLevels) > maxSR
        array.pop(resLevels)
        array.pop(resBars)
    if showSR
        ln = line.new(bar_index - pivotRight, ph, bar_index + 20, ph, color=color.new(color.red, 30), width=1, extend=extend.right)
        array.unshift(resLines, ln)
        if array.size(resLines) > maxSR
            line.delete(array.pop(resLines))

if not na(pl)
    array.unshift(supLevels, pl)
    array.unshift(supBars, bar_index - pivotRight)
    if array.size(supLevels) > maxSR
        array.pop(supLevels)
        array.pop(supBars)
    if showSR
        ln = line.new(bar_index - pivotRight, pl, bar_index + 20, pl, color=color.new(color.green, 30), width=1, extend=extend.right)
        array.unshift(supLines, ln)
        if array.size(supLines) > maxSR
            line.delete(array.pop(supLines))

// Expire old resistance levels
if array.size(resLevels) > 0
    int idx = array.size(resLevels) - 1
    while idx >= 0
        if (bar_index - array.get(resBars, idx)) > srMaxAge
            array.remove(resLevels, idx)
            array.remove(resBars, idx)
            if idx < array.size(resLines)
                line.delete(array.get(resLines, idx))
                array.remove(resLines, idx)
        idx -= 1

// Expire old support levels
if array.size(supLevels) > 0
    int idx = array.size(supLevels) - 1
    while idx >= 0
        if (bar_index - array.get(supBars, idx)) > srMaxAge
            array.remove(supLevels, idx)
            array.remove(supBars, idx)
            if idx < array.size(supLines)
                line.delete(array.get(supLines, idx))
                array.remove(supLines, idx)
        idx -= 1

f_nearest(array<float> arr, float px, bool above) =>
    float nearest = na
    sz = array.size(arr)
    if sz > 0
        for i = 0 to sz - 1
            lvl = array.get(arr, i)
            if above and lvl > px
                if na(nearest) or lvl < nearest
                    nearest := lvl
            if not above and lvl < px
                if na(nearest) or lvl > nearest
                    nearest := lvl
    nearest

nearestRes = f_nearest(resLevels, close, true)
nearestSup = f_nearest(supLevels, close, false)
proximity  = atrVal * srProxAtr

nearSupport    = not na(nearestSup) and math.abs(close - nearestSup) <= proximity
nearResistance = not na(nearestRes) and math.abs(close - nearestRes) <= proximity

supportBounce    = nearSupport    and low  <= nearestSup + proximity * 0.5 and close > open and close > nearestSup
resistanceReject = nearResistance and high >= nearestRes - proximity * 0.5 and close < open and close < nearestRes

liquiditySweepHigh = not na(nearestRes) and high > nearestRes and close < nearestRes and breakoutVolOk and bearCandleOk and bodyPct >= minBodyPct
liquiditySweepLow  = not na(nearestSup) and low  < nearestSup and close > nearestSup and breakoutVolOk and bullCandleOk and bodyPct >= minBodyPct

var float lastBrokenRes = na
var int   resBreakBar   = na
var float lastBrokenSup = na
var int   supBreakBar   = na

if not na(nearestRes) and close > nearestRes and close[1] <= nearestRes
    lastBrokenRes := nearestRes
    resBreakBar   := bar_index
if not na(nearestSup) and close < nearestSup and close[1] >= nearestSup
    lastBrokenSup := nearestSup
    supBreakBar   := bar_index

bullishBreakout  = not na(resBreakBar) and (bar_index - resBreakBar) <= breakConfBars and close > lastBrokenRes and close > lastBrokenRes + atrVal * 0.15 and breakoutVolOk and bullCandleOk
bearishBreakdown = not na(supBreakBar) and (bar_index - supBreakBar) <= breakConfBars and close < lastBrokenSup and close < lastBrokenSup - atrVal * 0.15 and breakoutVolOk and bearCandleOk
reclaimedResistance = not na(lastBrokenRes) and close > lastBrokenRes and low  <= lastBrokenRes * 1.005 and close > open
lostSupport         = not na(lastBrokenSup) and close < lastBrokenSup and high >= lastBrokenSup * 0.995 and close < open

srBullContext = supportBounce    or reclaimedResistance or bullishBreakout
srBearContext = resistanceReject or lostSupport         or bearishBreakdown

sweepBull = liquiditySweepLow
sweepBear = liquiditySweepHigh

// ============================================================================
// HIGHER TIMEFRAME
// ============================================================================

f_htfHist() =>
    [_m, _s, h] = ta.macd(close, 12, 26, 9)
    h

htfEma200 = request.security(syminfo.tickerid, htfTf, ta.ema(close, 200),  lookahead=barmerge.lookahead_off)
htfClose  = request.security(syminfo.tickerid, htfTf, close,               lookahead=barmerge.lookahead_off)
htfVwap   = request.security(syminfo.tickerid, htfTf, ta.vwap(hlc3),       lookahead=barmerge.lookahead_off)
htfRsi    = request.security(syminfo.tickerid, htfTf, ta.rsi(close, 14),   lookahead=barmerge.lookahead_off)
htfHist   = request.security(syminfo.tickerid, htfTf, f_htfHist(),         lookahead=barmerge.lookahead_off)

htfBull = (not useHtf) or ((not htfUseEma or htfClose > htfEma200) and (not htfUseVwap or htfClose > htfVwap))
htfBear = (not useHtf) or ((not htfUseEma or htfClose < htfEma200) and (not htfUseVwap or htfClose < htfVwap))

htfHistRising  = not na(htfHist) and not na(htfHist[1]) and htfHist > htfHist[1]
htfHistFalling = not na(htfHist) and not na(htfHist[1]) and htfHist < htfHist[1]
htfMomBull = htfHistRising  and htfRsi > 50
htfMomBear = htfHistFalling and htfRsi < 50

// ============================================================================
// FILTERS
// ============================================================================

atrOk = (not useAtrFilter) or (atrPct >= atrMinPct)
volOk = (not useVolFilter) or (volume > volMa * volMult)

priceStuckNearMAs = math.abs(close - ema50) < atrVal * 0.4 and math.abs(close - vwap) < atrVal * 0.4
avgHistAbs        = ta.sma(math.abs(histLine), 20)
macdFlat          = math.abs(histLine) < nz(avgHistAbs) * 0.5
rsiMid            = rsiVal >= 45 and rsiVal <= 55

emaCompression = math.abs(ema20 - ema50) <= atrVal * emaCompressionAtrMult

chopDetected = ((priceStuckNearMAs and macdFlat) or (useEmaCompressionChop and emaCompression and macdFlat) or (not atrOk))

// ============================================================================
// EARLY ENTRY
// ============================================================================

earlyBullTrigger = (
    useEarlyEntry and
    ema20CrossUp and
    priceAboveVwap and
    vwapRising and
    rsiVal >= earlyRsiBullMin and
    not chopDetected and
    (not requireFreshMacdForEarly or macdBullFresh)
)

earlyBearTrigger = (
    useEarlyEntry and
    ema20CrossDn and
    priceBelowVwap and
    vwapFalling and
    rsiVal <= earlyRsiBearMax and
    not chopDetected and
    (not requireFreshMacdForEarly or macdBearFresh)
)

// ============================================================================
// SCORING
// ============================================================================

bullScore = (bullStructPass ? wStructure : 0) + (vwapBull ? wVwap : 0) + (mfiBull ? wMfi : 0) + (rsiBull ? wRsi : 0) + (macdBull ? wMacd : 0) + (srBullContext ? wSR : 0) + ((htfBull and useHtf) ? wHtf : 0) + ((htfMomBull and useHtfMomentum) ? wHtfMomentum : 0) + (sweepBull ? 2 : 0) + (adxVal >= adxThreshold ? 1 : 0) - (rsiInChop ? 1 : 0)

bearScore = (bearStructPass ? wStructure : 0) + (vwapBear ? wVwap : 0) + (mfiBear ? wMfi : 0) + (rsiBear ? wRsi : 0) + (macdBear ? wMacd : 0) + (srBearContext ? wSR : 0) + ((htfBear and useHtf) ? wHtf : 0) + ((htfMomBear and useHtfMomentum) ? wHtfMomentum : 0) + (sweepBear ? 2 : 0) + (adxVal >= adxThreshold ? 1 : 0) - (rsiInChop ? 1 : 0)

scoreDiff = math.abs(bullScore - bearScore)
bullScoreRising = bullScore > nz(bullScore[1], 0)
bearScoreRising = bearScore > nz(bearScore[1], 0)

// ============================================================================
// STRUCTURE GATE
// ============================================================================

buyGate  = supportBounce    or reclaimedResistance or vwapRetestHoldBull or (ema20CrossUp and bullStructPass) or bullishBreakout  or liquiditySweepLow  or (close > ema20 and math.abs(close - ema20) <= atrVal * 1.0 and vwapBull)
sellGate = resistanceReject or lostSupport         or vwapRetestFailBear or (ema20CrossDn and bearStructPass) or bearishBreakdown or liquiditySweepHigh or (close < ema20 and math.abs(close - ema20) <= atrVal * 1.0 and vwapBear)

conservativeBuyOk  = bullStructPass and (not useVwap or vwapBull) and (not useMacd or macdBull) and (not useRsi or rsiBull) and buyGate
conservativeSellOk = bearStructPass and (not useVwap or vwapBear) and (not useMacd or macdBear) and (not useRsi or rsiBear) and sellGate
aggressiveBuyOk  = buyGate  and (not useMacd or macdBull) and (bullStructPass or (breakoutMode and bullishBreakout))
aggressiveSellOk = sellGate and (not useMacd or macdBear) and (bearStructPass or (breakoutMode and bearishBreakdown))

modeBuyOk  = signalMode == "Conservative" ? conservativeBuyOk  : aggressiveBuyOk
modeSellOk = signalMode == "Conservative" ? conservativeSellOk : aggressiveSellOk

buyReady  = modeBuyOk  and not chopDetected and atrOk and volOk and not extendedAbove and not tooFarAboveVwap and barstate.isconfirmed
sellReady = modeSellOk and not chopDetected and atrOk and volOk and not extendedBelow and not tooFarBelowVwap and barstate.isconfirmed

earlyBuyReady  = earlyBullTrigger and (bullStructPass or breakoutMode) and not chopDetected and atrOk and volOk and not extendedAbove and not tooFarAboveVwap and not macdFlat and barstate.isconfirmed
earlyBearReady = earlyBearTrigger and (bearStructPass or breakoutMode) and not chopDetected and atrOk and volOk and not extendedBelow and not tooFarBelowVwap and not macdFlat and barstate.isconfirmed

// ============================================================================
// TREND RESET
// ============================================================================

var bool allowBullSignal = true
var bool allowBearSignal = true
bullReset = close < ema20
bearReset = close > ema20

if useTrendReset
    if bullReset
        allowBullSignal := true
    if bearReset
        allowBearSignal := true
else
    allowBullSignal := true
    allowBearSignal := true

// ============================================================================
// FINAL SIGNAL GATING
// ============================================================================

var int lastSignalBar = na
canFire = na(lastSignalBar) or (bar_index - lastSignalBar) >= cooldownBars

bullWins = bullScore > bearScore and scoreDiff >= minScoreGap and (not requireRisingScore or bullScoreRising)
bearWins = bearScore > bullScore and scoreDiff >= minScoreGap and (not requireRisingScore or bearScoreRising)

bullHitsStrong = (buyReady  and bullScore >= strongBuyThreshold) or (earlyBuyReady  and bullScore >= (strongBuyThreshold - 1))
bullHitsBuy    = (buyReady  and bullScore >= buyThreshold)       or (earlyBuyReady  and bullScore >= (buyThreshold - 1))
bearHitsStrong = (sellReady and bearScore >= strongSellThresh)   or (earlyBearReady and bearScore >= (strongSellThresh - 1))
bearHitsSell   = (sellReady and bearScore >= sellThreshold)      or (earlyBearReady and bearScore >= (sellThreshold - 1))

strongBullMomOk = (not useHtfMomentum) or htfMomBull
strongBearMomOk = (not useHtfMomentum) or htfMomBear

bullSignalGate = (buyReady  or earlyBuyReady)  and canFire and bullWins and allowBullSignal
bearSignalGate = (sellReady or earlyBearReady) and canFire and bearWins and allowBearSignal

finalStrongBuy  = bullSignalGate and bullHitsStrong and strongBullMomOk and htfBull
finalStrongSell = bearSignalGate and bearHitsStrong and strongBearMomOk and htfBear
finalBuy        = bullSignalGate and bullHitsBuy  and not finalStrongBuy
finalSell       = bearSignalGate and bearHitsSell and not finalStrongSell

isEarlyBuy  = (finalBuy  or finalStrongBuy)  and earlyBuyReady  and (not buyReady  or bullScore < buyThreshold)
isEarlySell = (finalSell or finalStrongSell) and earlyBearReady and (not sellReady or bearScore < sellThreshold)

if finalBuy or finalStrongBuy
    lastSignalBar   := bar_index
    allowBullSignal := false
if finalSell or finalStrongSell
    lastSignalBar   := bar_index
    allowBearSignal := false

// ============================================================================
// PLOTS
// ============================================================================

plot(showMAs and useEma20  ? ema20  : na, "EMA 20",  color=color.new(color.yellow, 0),  linewidth=1)
plot(showMAs and useEma50  ? ema50  : na, "EMA 50",  color=color.new(color.orange, 0),  linewidth=1)
plot(showMAs and useEma200 ? ema200 : na, "EMA 200", color=color.new(color.red, 0),     linewidth=2)
plot(showMAs and useSma200 ? sma200 : na, "SMA 200", color=color.new(color.white, 30),  linewidth=1)
plot(showVwapLine          ? vwap   : na, "VWAP",    color=color.new(color.aqua, 0),    linewidth=2)

bgcolor(showBgBias and bullStructPass ? color.new(color.green, 92) : showBgBias and bearStructPass ? color.new(color.red, 92) : na)
barcolor(showBarColor and finalStrongBuy ? color.new(#00ff88, 0) : showBarColor and finalStrongSell ? color.new(#ff2277, 0) : na)

// Signal labels (FIFO for object safety)
var array<label> entryLabels = array.new<label>()
maxEntryLabels = 200

f_addEntryLabel(int x, float y, string txt, color bg, color txtcol, bool above, string sz) =>
    lb = label.new(x, y, txt, yloc=above ? yloc.abovebar : yloc.belowbar, color=bg, textcolor=txtcol, style=above ? label.style_label_down : label.style_label_up, size=sz == "normal" ? size.normal : size.small)
    array.unshift(entryLabels, lb)
    if array.size(entryLabels) > maxEntryLabels
        label.delete(array.pop(entryLabels))

if finalStrongBuy
    lbl = (isEarlyBuy ? "⚡ " : "★ ") + "STRONG BUY\n" + str.tostring(bullScore)
    f_addEntryLabel(bar_index, low, lbl, color.new(#00ff88, 0), color.black, false, "normal")
else if finalBuy
    lbl = (isEarlyBuy ? "⚡ BUY " : "BUY ") + str.tostring(bullScore)
    f_addEntryLabel(bar_index, low, lbl, color.new(color.green, 20), color.white, false, "small")

if finalStrongSell
    lbl = (isEarlySell ? "⚡ " : "★ ") + "STRONG SELL\n" + str.tostring(bearScore)
    f_addEntryLabel(bar_index, high, lbl, color.new(#ff2277, 0), color.white, true, "normal")
else if finalSell
    lbl = (isEarlySell ? "⚡ SELL " : "SELL ") + str.tostring(bearScore)
    f_addEntryLabel(bar_index, high, lbl, color.new(color.red, 20), color.white, true, "small")

plotshape(finalBuy,        "Buy",         shape.triangleup,   location.belowbar, color.new(color.green, 50), size=size.tiny)
plotshape(finalStrongBuy,  "Strong Buy",  shape.triangleup,   location.belowbar, color.new(#00ff88, 0),       size=size.small)
plotshape(finalSell,       "Sell",        shape.triangledown, location.abovebar, color.new(color.red, 50),   size=size.tiny)
plotshape(finalStrongSell, "Strong Sell", shape.triangledown, location.abovebar, color.new(#ff2277, 0),       size=size.small)

// ============================================================================
// DASHBOARD (signal-only, no trade state)
// ============================================================================

posVal = dashPos == "top_right" ? position.top_right : dashPos == "top_left" ? position.top_left : dashPos == "bottom_right" ? position.bottom_right : dashPos == "bottom_left" ? position.bottom_left : position.middle_right

var table dash = showDashboard ? table.new(posVal, 2, 18, border_width=1, border_color=color.new(color.gray, 50)) : na

if showDashboard and barstate.islast and not na(dash)
    bgHead   = color.new(color.black, 0)
    txtHead  = color.yellow
    cBull    = color.new(color.green, 25)
    cBear    = color.new(color.red, 25)
    cNeut    = color.new(color.gray, 50)
    cLabel   = color.new(#111111, 20)
    cWarn    = color.new(color.orange, 25)
    txtWhite = color.white

    table.cell(dash, 0, 0, "BTC ICSS",  bgcolor=bgHead, text_color=txtHead, text_size=size.small)
    table.cell(dash, 1, 0, signalMode,  bgcolor=bgHead, text_color=txtHead, text_size=size.small)

    table.cell(dash, 0, 1, "Structure", bgcolor=cLabel, text_color=txtWhite, text_size=size.small)
    table.cell(dash, 1, 1, bullStructPass ? "BULL" : bearStructPass ? "BEAR" : "NEUTRAL", bgcolor=bullStructPass ? cBull : bearStructPass ? cBear : cNeut, text_color=txtWhite, text_size=size.small)

    table.cell(dash, 0, 2, "VWAP", bgcolor=cLabel, text_color=txtWhite, text_size=size.small)
    table.cell(dash, 1, 2, vwapBull ? "BULL" : vwapBear ? "BEAR" : "—", bgcolor=vwapBull ? cBull : vwapBear ? cBear : cNeut, text_color=txtWhite, text_size=size.small)

    table.cell(dash, 0, 3, "MFI " + str.tostring(nz(mfiVal), "#.0"), bgcolor=cLabel, text_color=txtWhite, text_size=size.small)
    table.cell(dash, 1, 3, mfiBull ? "BULL" : mfiBear ? "BEAR" : "—", bgcolor=mfiBull ? cBull : mfiBear ? cBear : cNeut, text_color=txtWhite, text_size=size.small)

    table.cell(dash, 0, 4, "RSI " + str.tostring(nz(rsiVal), "#.0"), bgcolor=cLabel, text_color=txtWhite, text_size=size.small)
    table.cell(dash, 1, 4, rsiBull ? "BULL" : rsiBear ? "BEAR" : "—", bgcolor=rsiBull ? cBull : rsiBear ? cBear : cNeut, text_color=txtWhite, text_size=size.small)

    // MACD shows freshness state
    macdFreshDisp = macdBullFresh ? " F" + str.tostring(barsSinceBullCross) : macdBearFresh ? " F" + str.tostring(barsSinceBearCross) : ""
    macdLabel = macdBull ? ("BULL" + macdFreshDisp) : macdBear ? ("BEAR" + macdFreshDisp) : (macdAbove ? "stale ↑" : macdBelow ? "stale ↓" : "—")
    macdBg    = macdBull ? cBull : macdBear ? cBear : (macdAbove or macdBelow ? cWarn : cNeut)
    table.cell(dash, 0, 5, "MACD", bgcolor=cLabel, text_color=txtWhite, text_size=size.small)
    table.cell(dash, 1, 5, macdLabel, bgcolor=macdBg, text_color=txtWhite, text_size=size.small)

    srLabel = liquiditySweepLow ? "SWEEP LOW" : liquiditySweepHigh ? "SWEEP HIGH" : srBullContext ? "BULL" : srBearContext ? "BEAR" : "—"
    table.cell(dash, 0, 6, "S/R", bgcolor=cLabel, text_color=txtWhite, text_size=size.small)
    table.cell(dash, 1, 6, srLabel, bgcolor=srBullContext ? cBull : srBearContext ? cBear : cNeut, text_color=txtWhite, text_size=size.small)

    srCountDisp = str.tostring(array.size(supLevels)) + "s / " + str.tostring(array.size(resLevels)) + "r"
    table.cell(dash, 0, 7, "S/R Levels", bgcolor=cLabel, text_color=txtWhite, text_size=size.small)
    table.cell(dash, 1, 7, srCountDisp, bgcolor=cLabel, text_color=txtWhite, text_size=size.small)

    htfDisplay = not useHtf ? "OFF" : (htfBull and not htfBear ? "BULL" : htfBear and not htfBull ? "BEAR" : "—")
    htfBg      = not useHtf ? cNeut : (htfBull and not htfBear ? cBull : htfBear and not htfBull ? cBear : cNeut)
    table.cell(dash, 0, 8, "HTF (" + htfTf + ")", bgcolor=cLabel, text_color=txtWhite, text_size=size.small)
    table.cell(dash, 1, 8, htfDisplay, bgcolor=htfBg, text_color=txtWhite, text_size=size.small)

    htfMomDisp = not useHtfMomentum ? "OFF" : htfMomBull ? "BULL" : htfMomBear ? "BEAR" : "—"
    htfMomBg   = not useHtfMomentum ? cNeut : htfMomBull ? cBull : htfMomBear ? cBear : cNeut
    table.cell(dash, 0, 9, "HTF Momentum", bgcolor=cLabel, text_color=txtWhite, text_size=size.small)
    table.cell(dash, 1, 9, htfMomDisp, bgcolor=htfMomBg, text_color=txtWhite, text_size=size.small)

    adxDisp = not useAdxFilter ? str.tostring(nz(adxVal), "#.0") + " (off)" : str.tostring(nz(adxVal), "#.0") + " / " + str.tostring(adxThreshold, "#.0")
    adxBg   = not useAdxFilter ? cNeut : adxOk ? cBull : cWarn
    table.cell(dash, 0, 10, "ADX", bgcolor=cLabel, text_color=txtWhite, text_size=size.small)
    table.cell(dash, 1, 10, adxDisp, bgcolor=adxBg, text_color=txtWhite, text_size=size.small)

    candleDisp = not useCandleFilter ? "OFF" : bullCandleOk ? "BULL ok" : bearCandleOk ? "BEAR ok" : "weak body"
    candleBg   = not useCandleFilter ? cNeut : bullCandleOk ? cBull : bearCandleOk ? cBear : cWarn
    table.cell(dash, 0, 11, "Candle " + str.tostring(bodyPct, "#.0") + "%", bgcolor=cLabel, text_color=txtWhite, text_size=size.small)
    table.cell(dash, 1, 11, candleDisp, bgcolor=candleBg, text_color=txtWhite, text_size=size.small)

    table.cell(dash, 0, 12, "Bull Score", bgcolor=cLabel, text_color=txtWhite, text_size=size.small)
    table.cell(dash, 1, 12, str.tostring(bullScore) + " / " + str.tostring(strongBuyThreshold), bgcolor=bullScore >= strongBuyThreshold ? cBull : bullScore >= buyThreshold ? color.new(color.green, 55) : cNeut, text_color=txtWhite, text_size=size.small)

    table.cell(dash, 0, 13, "Bear Score", bgcolor=cLabel, text_color=txtWhite, text_size=size.small)
    table.cell(dash, 1, 13, str.tostring(bearScore) + " / " + str.tostring(strongSellThresh), bgcolor=bearScore >= strongSellThresh ? cBear : bearScore >= sellThreshold ? color.new(color.red, 55) : cNeut, text_color=txtWhite, text_size=size.small)

    gapOk = scoreDiff >= minScoreGap
    gapStr = str.tostring(scoreDiff) + " / " + str.tostring(minScoreGap) + (requireRisingScore ? "  ▲rise" : "")
    table.cell(dash, 0, 14, "Score Gap", bgcolor=cLabel, text_color=txtWhite, text_size=size.small)
    table.cell(dash, 1, 14, gapStr, bgcolor=gapOk ? cBull : cWarn, text_color=txtWhite, text_size=size.small)

    table.cell(dash, 0, 15, "Chop", bgcolor=cLabel, text_color=txtWhite, text_size=size.small)
    table.cell(dash, 1, 15, chopDetected ? "ACTIVE" : "clear", bgcolor=chopDetected ? cWarn : cBull, text_color=txtWhite, text_size=size.small)

    bullResetDisp = not useTrendReset ? "OFF" : allowBullSignal ? "READY" : "BLOCKED"
    bearResetDisp = not useTrendReset ? "OFF" : allowBearSignal ? "READY" : "BLOCKED"
    table.cell(dash, 0, 16, "Reset B/Br", bgcolor=cLabel, text_color=txtWhite, text_size=size.small)
    table.cell(dash, 1, 16, bullResetDisp + " | " + bearResetDisp, bgcolor=allowBullSignal and allowBearSignal ? cBull : cWarn, text_color=txtWhite, text_size=size.small)

    macdFreshStr = "Bull:" + str.tostring(barsSinceBullCross) + "b  Bear:" + str.tostring(barsSinceBearCross) + "b  (max " + str.tostring(macdFreshBars) + ")"
    macdFreshBg  = (macdBullFresh or macdBearFresh) ? cBull : cWarn
    table.cell(dash, 0, 17, "MACD Fresh", bgcolor=cLabel, text_color=txtWhite, text_size=size.small)
    table.cell(dash, 1, 17, macdFreshStr, bgcolor=macdFreshBg, text_color=txtWhite, text_size=size.small)

// ============================================================================
// ALERTS
// ============================================================================

alertcondition(finalBuy,         "Buy Signal",         "BTC ICSS: BUY confluence met")
alertcondition(finalStrongBuy,   "Strong Buy Signal",  "BTC ICSS: STRONG BUY confluence met")
alertcondition(finalSell,        "Sell Signal",        "BTC ICSS: SELL confluence met")
alertcondition(finalStrongSell,  "Strong Sell Signal", "BTC ICSS: STRONG SELL confluence met")
alertcondition(bullishBreakout,  "Bullish Breakout",   "BTC ICSS: Bullish breakout")
alertcondition(bearishBreakdown, "Bearish Breakdown",  "BTC ICSS: Bearish breakdown")
alertcondition(liquiditySweepLow,  "Sweep Low",  "BTC ICSS: Liquidity sweep low")
alertcondition(liquiditySweepHigh, "Sweep High", "BTC ICSS: Liquidity sweep high")
````
