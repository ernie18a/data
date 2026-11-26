# Gold Trading Assistant v2.0

- url: https://www.tradingview.com/script/qsV6VAqj-Gold-Trading-Assistant-v2-0/
- type: indicator
- pine_id: PUB;e243a2321ddb41a6a89c597ba5ffae6d
- version: 1.0

## Description

new update for Gold Trading Assistant v1, as this one giving signals for daily and scalping traders

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════════
// Gold Trading Assistant — v2.0 (Indicator)
// ────────────────────────────────────────────────────────────────────────────
// STRATEGY-FIRST REBUILD. See STRATEGY_SPEC_v2_0.md for the full design doc.
//
// Two modes:
//   Day Mode   (15m) — Trend Pullback
//   Scalp Mode (5m)  — Mean Reversion (BB + RSI)
//
// Philosophy: Show all qualified patterns with A/B/C/D/F grade. User decides.
// No-repaint: close[1] + lookahead_off + barstate.isconfirmed.
// ════════════════════════════════════════════════════════════════════════════
indicator("Gold Trading Assistant v2.0", "GTA v2.0", overlay=true,
     max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// ════════════════════════════════════════════════════════════════════════════
// INPUTS — Mode + Display
// ════════════════════════════════════════════════════════════════════════════
grpMode = "🎯 Mode"
modeSel = input.string("Day", "Trading Mode", options=["Day", "Scalp"], group=grpMode, tooltip="Day = Trend Pullback (best on 15m). Scalp = Mean Reversion (best on 5m).")
strictMode = input.bool(true, "Strict mode (bar-close only)", group=grpMode)

grpDisplay = "🎨 Display"
showAllPatterns  = input.bool(true, "Show ALL qualified patterns", group=grpDisplay)
alertMinGradeIn  = input.string("A + B", "Alert minimum grade", options=["A only","A + B","A + B + C","All grades"], group=grpDisplay)
linesMinGradeIn  = input.string("A + B", "Draw SL/TP lines for", options=["A only","A + B","A + B + C","All grades"], group=grpDisplay)
showScoreLbl     = input.bool(true, "Show score label on signals", group=grpDisplay)
showDash         = input.bool(true, "Show dashboard", group=grpDisplay)
showLines        = input.bool(true, "Show SL/TP lines", group=grpDisplay)
showEMA20        = input.bool(true, "Show EMA20 (Day Mode reference)", group=grpDisplay)
showBB           = input.bool(true, "Show Bollinger Bands (Scalp Mode reference)", group=grpDisplay)
dashPos          = input.string("Top Right", "Dashboard position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=grpDisplay)
theme            = input.string("Dark", "Theme", options=["Dark","Light"], group=grpDisplay)

isDay   = modeSel == "Day"
isScalp = modeSel == "Scalp"

// ─── Day Mode params ───────────────────────────────────────────────────────
grpDay = "📊 Day Mode (Trend Pullback)"
htfDayTF       = input.timeframe("60", "Day: Higher TF for trend",      group=grpDay)
emaFastLen     = input.int(20, "Day: Fast EMA",                          group=grpDay, minval=5, maxval=100)
emaSlowLen     = input.int(50, "Day: Slow EMA",                          group=grpDay, minval=10, maxval=200)
trendSlopeBars = input.int(5,  "Day: HTF slope lookback bars",           group=grpDay, minval=2, maxval=20)
pullbackLookback = input.int(10, "Day: Pullback lookback bars",          group=grpDay, minval=3, maxval=30, tooltip="Bars to scan for swing high/low used in pullback depth.")
minPullbackATR = input.float(0.5,   "Day: Min pullback depth (× ATR)",   group=grpDay, minval=0.1, maxval=3.0, step=0.1)
maxPullbackFib = input.float(0.618, "Day: Max pullback (Fib %)",         group=grpDay, minval=0.3, maxval=0.9, step=0.018)
ema20TouchATR  = input.float(0.3,   "Day: EMA20 touch tolerance (× ATR)",group=grpDay, minval=0.0, maxval=2.0, step=0.1, tooltip="How close to EMA20 counts as 'touched'. 0 = exact touch, 0.3 = within 0.3 ATR.")

// ─── Scalp Mode params ─────────────────────────────────────────────────────
grpScalp = "⚡ Scalp Mode (Mean Reversion)"
bbPeriod = input.int(20,   "Scalp: BB period",        group=grpScalp, minval=5, maxval=50)
bbStd    = input.float(2.0,"Scalp: BB std dev",       group=grpScalp, minval=1.0, maxval=4.0, step=0.1)
rsiLen   = input.int(14,   "Scalp: RSI period",       group=grpScalp, minval=5, maxval=30)
rsiOB    = input.int(70,   "Scalp: RSI overbought",   group=grpScalp, minval=60, maxval=90)
rsiOS    = input.int(30,   "Scalp: RSI oversold",     group=grpScalp, minval=10, maxval=40)
scalpExtremeBars = input.int(3, "Scalp: Extreme lookback for SL", group=grpScalp, minval=1, maxval=10, tooltip="How many recent bars to look at for the 'extreme wick high/low' used in SL.")

// ─── Patterns (shared) ─────────────────────────────────────────────────────
grpPat = "🕯️ Patterns"
useEngulf      = input.bool(true, "Engulfing", group=grpPat)
engulfBodyMult = input.float(0.8, "Engulfing body ratio", minval=0.3, maxval=3.0, step=0.1, group=grpPat)
usePinBar      = input.bool(true, "Pin Bar / Hammer / Shooting Star", group=grpPat)
pinRatio       = input.float(1.7, "Pin wick:body ratio", minval=1.2, maxval=4.0, step=0.1, group=grpPat)

// ─── Risk / SL / TP ────────────────────────────────────────────────────────
grpRisk = "💰 Risk & Targets"
atrLen       = input.int(14, "ATR length", group=grpRisk, minval=5, maxval=50)
slBufferATR  = input.float(0.2, "SL structural buffer (× ATR)", group=grpRisk, minval=0.0, maxval=2.0, step=0.05)
dayATRSLMult = input.float(1.5, "Day: ATR-floor SL multiplier", group=grpRisk, minval=0.5, maxval=5.0, step=0.1)
scalpATRSLMult = input.float(0.5,"Scalp: ATR-floor SL multiplier", group=grpRisk, minval=0.2, maxval=2.0, step=0.1)
dayTP1RR    = input.float(1.5, "Day: TP1 R:R", group=grpRisk, minval=0.5, maxval=5.0, step=0.1)
dayTP2RR    = input.float(2.5, "Day: TP2 R:R", group=grpRisk, minval=1.0, maxval=10.0, step=0.1)
dayTrailEMA = input.int(20, "Day: Trail by EMA length (for TP3 runner)", group=grpRisk, minval=5, maxval=100)
suggestedRiskDay   = input.float(1.0, "Day: Suggested risk % (dashboard)",  group=grpRisk, minval=0.1, maxval=5.0, step=0.1)
suggestedRiskScalp = input.float(0.5, "Scalp: Suggested risk % (dashboard)",group=grpRisk, minval=0.1, maxval=5.0, step=0.1)

// ─── Hybrid R:R ────────────────────────────────────────────────────────────
grpRR = "🎯 Hybrid R:R"
hardRejectRR = input.float(0.8, "Hard reject below", group=grpRR, minval=0.1, maxval=2.0, step=0.1)
fullRRThr    = input.float(1.5, "Full credit above", group=grpRR, minval=0.5, maxval=5.0, step=0.1)
maxRRPenalty = input.int(15, "Max R:R penalty (points)", group=grpRR, minval=0, maxval=50)

// ─── Macro (Day Mode only) ─────────────────────────────────────────────────
grpMacro = "🌍 Macro (Day only — grade modifier)"
useMacro     = input.bool(true, "Enable macro modifier (Day mode)", group=grpMacro)
dxySym       = input.symbol("TVC:DXY",    "DXY",    group=grpMacro)
silverSym    = input.symbol("TVC:SILVER", "Silver", group=grpMacro)
yieldsSym    = input.symbol("TVC:US10Y",  "US10Y",  group=grpMacro)
macroTF      = input.timeframe("15", "Macro TF", group=grpMacro)
macroLookback = input.int(96,  "Macro lookback bars", group=grpMacro, minval=20, maxval=500)
zScorePeriod  = input.int(100, "Z-Score period",     group=grpMacro, minval=20, maxval=500)
zStrongThr    = input.float(2.0, "Z strong threshold", group=grpMacro, minval=1.0, maxval=4.0, step=0.1)
zMildThr      = input.float(1.0, "Z mild threshold",   group=grpMacro, minval=0.5, maxval=2.0, step=0.1)
macroMaxBonus = input.int(15, "Max macro grade bonus/penalty", group=grpMacro, minval=0, maxval=30)

// ─── Pacing ────────────────────────────────────────────────────────────────
grpPace = "⏱️ Pacing"
minBarsBetweenIn   = input.int(4, "Min bars between displayed signals", group=grpPace, minval=1, maxval=50)
maxSignalsPerDayIn = input.int(10,"Max displayed signals per day",      group=grpPace, minval=1, maxval=50)

// Mode-aware pacing defaults
minBarsBetween   = isScalp ? 2 : minBarsBetweenIn
maxSignalsPerDay = isScalp ? 15 : maxSignalsPerDayIn

// ════════════════════════════════════════════════════════════════════════════
// THEME
// ════════════════════════════════════════════════════════════════════════════
bgCol     = theme == "Dark" ? color.new(color.black, 15) : color.new(color.white, 5)
textCol   = theme == "Dark" ? color.white : color.black
borderCol = theme == "Dark" ? color.new(color.gray, 40) : color.new(color.gray, 60)
headerBg  = theme == "Dark" ? color.new(color.purple, 40) : color.new(color.purple, 70)
dPos = dashPos == "Top Right" ? position.top_right : dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : position.bottom_left

// ════════════════════════════════════════════════════════════════════════════
// CORE INDICATORS
// ════════════════════════════════════════════════════════════════════════════
atr     = ta.atr(atrLen)
body    = math.abs(close - open)
bodyHi  = math.max(close, open)
bodyLo  = math.min(close, open)
upWick  = high - bodyHi
dnWick  = bodyLo - low
isBull  = close > open
isBear  = close < open

// EMAs (used by Day Mode)
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
emaTrail = ta.ema(close, dayTrailEMA)

// Bollinger Bands (used by Scalp Mode)
bbBasis = ta.sma(close, bbPeriod)
bbDev   = bbStd * ta.stdev(close, bbPeriod)
bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev

// RSI (used by Scalp Mode)
rsi = ta.rsi(close, rsiLen)

// ════════════════════════════════════════════════════════════════════════════
// PATTERN DETECTION (shared)
// ════════════════════════════════════════════════════════════════════════════
bullEngulf   = useEngulf and isBull and close[1] < open[1] and close >= open[1] and open <= close[1] and body >= body[1] * engulfBodyMult
bearEngulf   = useEngulf and isBear and close[1] > open[1] and close <= open[1] and open >= close[1] and body >= body[1] * engulfBodyMult
hammer       = usePinBar and dnWick >= body * pinRatio and upWick <= body * 0.5 and body > 0
shootingStar = usePinBar and upWick >= body * pinRatio and dnWick <= body * 0.5 and body > 0

bullPattern = bullEngulf or hammer
bearPattern = bearEngulf or shootingStar

// Pattern strength (used for scoring)
bullPatternStrong = (bullEngulf and body >= body[1] * 1.5) or (hammer and dnWick >= body * 2.5)
bearPatternStrong = (bearEngulf and body >= body[1] * 1.5) or (shootingStar and upWick >= body * 2.5)

confirmed = not strictMode or barstate.isconfirmed

// ════════════════════════════════════════════════════════════════════════════
// DAY MODE — Trend Pullback
// ════════════════════════════════════════════════════════════════════════════

// ─── 1. Trend Identification (Multi-Confirmation) ─────────────────────────
htfFastEMA = isDay ? request.security(syminfo.tickerid, htfDayTF, ta.ema(close, emaFastLen)[1], lookahead=barmerge.lookahead_off) : na
htfSlowEMA = isDay ? request.security(syminfo.tickerid, htfDayTF, ta.ema(close, emaSlowLen)[1], lookahead=barmerge.lookahead_off) : na

// Condition 1: HTF EMA cross
htfBullCross = isDay and not na(htfFastEMA) and not na(htfSlowEMA) and htfFastEMA > htfSlowEMA
htfBearCross = isDay and not na(htfFastEMA) and not na(htfSlowEMA) and htfFastEMA < htfSlowEMA

// Condition 2: Current structure (HH+HL for bull, LH+LL for bear)
swHi = ta.pivothigh(high, 3, 3)
swLo = ta.pivotlow(low, 3, 3)
var float lastSwHi = na
var float prevSwHi = na
var float lastSwLo = na
var float prevSwLo = na
if not na(swHi)
    prevSwHi := lastSwHi
    lastSwHi := swHi
if not na(swLo)
    prevSwLo := lastSwLo
    lastSwLo := swLo
hasHH = not na(lastSwHi) and not na(prevSwHi) and lastSwHi > prevSwHi
hasHL = not na(lastSwLo) and not na(prevSwLo) and lastSwLo > prevSwLo
hasLH = not na(lastSwHi) and not na(prevSwHi) and lastSwHi < prevSwHi
hasLL = not na(lastSwLo) and not na(prevSwLo) and lastSwLo < prevSwLo
curBullStruct = hasHH and hasHL
curBearStruct = hasLH and hasLL

// Condition 3: HTF EMA slope
htfSlope = isDay and not na(htfSlowEMA) ? ta.change(htfSlowEMA, trendSlopeBars) : 0.0
htfBullSlope = isDay and htfSlope > 0
htfBearSlope = isDay and htfSlope < 0

// Aggregate trend strength
trendBullStrength = (htfBullCross ? 1 : 0) + (curBullStruct ? 1 : 0) + (htfBullSlope ? 1 : 0)
trendBearStrength = (htfBearCross ? 1 : 0) + (curBearStruct ? 1 : 0) + (htfBearSlope ? 1 : 0)
bullTrendActive = isDay and trendBullStrength >= 2
bearTrendActive = isDay and trendBearStrength >= 2

// ─── 2. Pullback Validation ────────────────────────────────────────────────
// Recent swing high/low for measuring pullback depth
swingHighRecent = ta.highest(high, pullbackLookback)
swingLowRecent  = ta.lowest(low, pullbackLookback)
biggerHigh      = ta.highest(high, pullbackLookback * 2)
biggerLow       = ta.lowest(low, pullbackLookback * 2)

// EMA20 touch detection — was EMA touched in last N bars?
lowestLowRecent  = ta.lowest(low, pullbackLookback)
highestHighRecent = ta.highest(high, pullbackLookback)
bullEMATouched = lowestLowRecent  <= emaFast + atr * ema20TouchATR  // dipped to/below EMA20 area
bearEMATouched = highestHighRecent >= emaFast - atr * ema20TouchATR // rallied to/above EMA20 area

// Pullback depth (price units)
bullPullbackDepth = swingHighRecent - lowestLowRecent
bearPullbackDepth = highestHighRecent - swingLowRecent

// Min depth check (avoids micro-pullbacks)
bullMinDepthOK = bullPullbackDepth >= atr * minPullbackATR
bearMinDepthOK = bearPullbackDepth >= atr * minPullbackATR

// Max depth check (Fib 61.8% of the bigger wave — beyond this, the trend ended)
bigBullWave = biggerHigh - biggerLow
bigBearWave = biggerHigh - biggerLow
bullMaxDepthOK = bullPullbackDepth <= bigBullWave * maxPullbackFib
bearMaxDepthOK = bearPullbackDepth <= bigBearWave * maxPullbackFib

bullPullbackOK = isDay and bullEMATouched and bullMinDepthOK and bullMaxDepthOK
bearPullbackOK = isDay and bearEMATouched and bearMinDepthOK and bearMaxDepthOK

// Pullback quality score (0-20)
bullPullbackQuality = bullPullbackOK ? (bullPullbackDepth / atr >= 1.0 and bullPullbackDepth / atr <= 3.0 ? 20 : 12) : 0
bearPullbackQuality = bearPullbackOK ? (bearPullbackDepth / atr >= 1.0 and bearPullbackDepth / atr <= 3.0 ? 20 : 12) : 0

// ─── 3. Entry Trigger (Pattern + Break) ────────────────────────────────────
// Pattern was on PREVIOUS bar; THIS bar must break the pattern bar's high/low.
bullPatternPrev = bullPattern[1]
bearPatternPrev = bearPattern[1]

// Break confirmation (current bar)
bullBreak = high > high[1]
bearBreak = low  < low[1]

// Break strength = how far past pattern bar's high (0-10 points)
bullBreakStrength = bullBreak ? math.min(10, math.round((high - high[1]) / atr * 5)) : 0
bearBreakStrength = bearBreak ? math.min(10, math.round((low[1] - low) / atr * 5)) : 0

// Day Mode raw signal candidates (no R:R, no scoring yet)
dayBullCandidate = isDay and confirmed and bullPatternPrev and bullPullbackOK[1] and bullTrendActive[1] and bullBreak
dayBearCandidate = isDay and confirmed and bearPatternPrev and bearPullbackOK[1] and bearTrendActive[1] and bearBreak

// ─── 4. Day Mode SL ───────────────────────────────────────────────────────
// Pullback low = recent low before the entry
dayBuyEntry  = close
daySellEntry = close
dayBuySL_structural  = lowestLowRecent  - atr * slBufferATR
daySellSL_structural = highestHighRecent + atr * slBufferATR
dayBuySL_atr  = close - atr * dayATRSLMult
daySellSL_atr = close + atr * dayATRSLMult
// Hybrid Smart: select the SL that's FURTHER from entry (safer)
dayBuySL  = math.min(dayBuySL_structural,  dayBuySL_atr)
daySellSL = math.max(daySellSL_structural, daySellSL_atr)

dayBuyRisk  = dayBuyEntry  - dayBuySL
daySellRisk = daySellSL    - daySellEntry

// ─── 5. Day Mode TPs ──────────────────────────────────────────────────────
dayBuyTP1  = dayBuyEntry  + dayBuyRisk  * dayTP1RR
dayBuyTP2  = dayBuyEntry  + dayBuyRisk  * dayTP2RR
daySellTP1 = daySellEntry - daySellRisk * dayTP1RR
daySellTP2 = daySellEntry - daySellRisk * dayTP2RR
// TP3 is trailing (no fixed price)

// ════════════════════════════════════════════════════════════════════════════
// SCALP MODE — Mean Reversion (BB + RSI)
// ════════════════════════════════════════════════════════════════════════════

// ─── 1. Extreme Detection ─────────────────────────────────────────────────
// BB extreme on bar N (we use [1] when computing the signal on bar N+1)
bbUpperExtreme = isScalp and high >= bbUpper
bbLowerExtreme = isScalp and low  <= bbLower

// RSI extreme
rsiOverbought = isScalp and rsi >= rsiOB
rsiOversold   = isScalp and rsi <= rsiOS

// Combined extreme
sellExtremeNow = bbUpperExtreme and rsiOverbought
buyExtremeNow  = bbLowerExtreme and rsiOversold

// Extreme strength (how far past BB / how extreme RSI)
sellBBStrength = bbUpperExtreme ? math.min(25, math.round((high - bbUpper) / atr * 12)) : 0
buyBBStrength  = bbLowerExtreme ? math.min(25, math.round((bbLower - low) / atr * 12)) : 0
sellRSIStrength = rsiOverbought ? math.min(20, math.round((rsi - rsiOB) * 0.5 + 10)) : 0
buyRSIStrength  = rsiOversold   ? math.min(20, math.round((rsiOS - rsi) * 0.5 + 10)) : 0

// ─── 2. Entry Trigger (Pattern at extreme + BB Re-entry) ──────────────────
// Pattern was at extreme on previous bar; current bar closes back inside BB.
sellPatternAtExtreme = sellExtremeNow[1] and shootingStar[1]
buyPatternAtExtreme  = buyExtremeNow[1]  and hammer[1]

// Re-entry confirmation
sellBBReentry = close < bbUpper
buyBBReentry  = close > bbLower

scalpSellCandidate = isScalp and confirmed and sellPatternAtExtreme and sellBBReentry
scalpBuyCandidate  = isScalp and confirmed and buyPatternAtExtreme  and buyBBReentry

// Re-entry score (0-15)
sellReentryScore = sellBBReentry ? math.min(15, math.round((bbUpper - close) / atr * 6) + 5) : 0
buyReentryScore  = buyBBReentry  ? math.min(15, math.round((close - bbLower) / atr * 6) + 5) : 0

// ─── 3. Scalp Mode SL ─────────────────────────────────────────────────────
// Extreme high/low from recent N bars (wick high of rejection)
scalpExtremeHigh = ta.highest(high, scalpExtremeBars)
scalpExtremeLow  = ta.lowest(low,  scalpExtremeBars)
scalpBuyEntry  = close
scalpSellEntry = close
scalpBuySL_structural  = scalpExtremeLow  - atr * slBufferATR
scalpSellSL_structural = scalpExtremeHigh + atr * slBufferATR
scalpBuySL_atr  = close - atr * scalpATRSLMult
scalpSellSL_atr = close + atr * scalpATRSLMult
scalpBuySL  = math.min(scalpBuySL_structural,  scalpBuySL_atr)
scalpSellSL = math.max(scalpSellSL_structural, scalpSellSL_atr)
scalpBuyRisk  = scalpBuyEntry  - scalpBuySL
scalpSellRisk = scalpSellSL    - scalpSellEntry

// ─── 4. Scalp Mode TP (BB Middle) ─────────────────────────────────────────
scalpBuyTP  = bbBasis
scalpSellTP = bbBasis

// ════════════════════════════════════════════════════════════════════════════
// UNIFIED SIGNAL — pick mode-appropriate values
// ════════════════════════════════════════════════════════════════════════════
buyEntry  = isDay ? dayBuyEntry  : scalpBuyEntry
sellEntry = isDay ? daySellEntry : scalpSellEntry
buySL  = isDay ? dayBuySL  : scalpBuySL
sellSL = isDay ? daySellSL : scalpSellSL
buyRisk  = isDay ? dayBuyRisk  : scalpBuyRisk
sellRisk = isDay ? daySellRisk : scalpSellRisk
buyTP1   = isDay ? dayBuyTP1   : scalpBuyTP
sellTP1  = isDay ? daySellTP1  : scalpSellTP
buyTP2   = isDay ? dayBuyTP2   : na
sellTP2  = isDay ? daySellTP2  : na

buyRR  = buyRisk  > 0 ? (buyTP1  - buyEntry)  / buyRisk  : 0
sellRR = sellRisk > 0 ? (sellEntry - sellTP1) / sellRisk : 0

// Mode-specific candidate
buyCandidate  = isDay ? dayBullCandidate : scalpBuyCandidate
sellCandidate = isDay ? dayBearCandidate : scalpSellCandidate

// ════════════════════════════════════════════════════════════════════════════
// HYBRID R:R LOGIC
// ════════════════════════════════════════════════════════════════════════════
f_rrPenalty(float rr) =>
    if rr < hardRejectRR
        -999.0
    else if rr >= fullRRThr
        0.0
    else
        maxRRPenalty * (fullRRThr - rr) / (fullRRThr - hardRejectRR)

buyRRpenalty  = f_rrPenalty(buyRR)
sellRRpenalty = f_rrPenalty(sellRR)
buyRROK   = buyRRpenalty  > -100
sellRROK  = sellRRpenalty > -100

// ════════════════════════════════════════════════════════════════════════════
// MACRO (Day Mode only — grade modifier)
// ════════════════════════════════════════════════════════════════════════════
[dxyNow, dxyPast] = request.security(dxySym,    macroTF, [close[1], close[macroLookback + 1]], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
[xagNow, xagPast] = request.security(silverSym, macroTF, [close[1], close[macroLookback + 1]], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
[yldNow, yldPast] = request.security(yieldsSym, macroTF, [close[1], close[macroLookback + 1]], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

dxyOK = not na(dxyNow) and not na(dxyPast) and dxyPast != 0
xagOK = not na(xagNow) and not na(xagPast) and xagPast != 0
yldOK = not na(yldNow) and not na(yldPast)
macroAvailable = (dxyOK ? 1 : 0) + (xagOK ? 1 : 0) + (yldOK ? 1 : 0)

dxyRet = dxyOK ? (dxyNow - dxyPast) / dxyPast * 100 : 0.0
xagRet = xagOK ? (xagNow - xagPast) / xagPast * 100 : 0.0
yldBps = yldOK ? (yldNow - yldPast) * 100 : 0.0

dxyRetSeries = request.security(dxySym,    macroTF, ((close[1] - close[macroLookback+1]) / close[macroLookback+1] * 100), lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
xagRetSeries = request.security(silverSym, macroTF, ((close[1] - close[macroLookback+1]) / close[macroLookback+1] * 100), lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
yldChgSeries = request.security(yieldsSym, macroTF, ((close[1] - close[macroLookback+1]) * 100), lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

dxyMean = ta.sma(nz(dxyRetSeries), zScorePeriod), dxyStd = ta.stdev(nz(dxyRetSeries), zScorePeriod)
xagMean = ta.sma(nz(xagRetSeries), zScorePeriod), xagStd = ta.stdev(nz(xagRetSeries), zScorePeriod)
yldMean = ta.sma(nz(yldChgSeries), zScorePeriod), yldStd = ta.stdev(nz(yldChgSeries), zScorePeriod)

dxyZ = dxyStd > 0 ? (dxyRet - dxyMean) / dxyStd : 0.0
xagZ = xagStd > 0 ? (xagRet - xagMean) / xagStd : 0.0
yldZ = yldStd > 0 ? (yldBps - yldMean) / yldStd : 0.0

// Gold bullish: DXY down (-), Silver up (+), Yields down (-)
dxySig = dxyZ <= -zStrongThr ? 2 : dxyZ <= -zMildThr ? 1 : dxyZ >= zStrongThr ? -2 : dxyZ >= zMildThr ? -1 : 0
xagSig = xagZ >=  zStrongThr ? 2 : xagZ >=  zMildThr ? 1 : xagZ <= -zStrongThr ? -2 : xagZ <= -zMildThr ? -1 : 0
yldSig = yldZ <= -zStrongThr ? 2 : yldZ <= -zMildThr ? 1 : yldZ >=  zStrongThr ? -2 : yldZ >=  zMildThr ? -1 : 0
macroRaw = (dxyOK ? dxySig*1.0 : 0) + (xagOK ? xagSig*1.2 : 0) + (yldOK ? yldSig*0.8 : 0)
macroMax = (dxyOK ? 2.0 : 0) + (xagOK ? 2.4 : 0) + (yldOK ? 1.6 : 0)
macroPct = macroMax > 0 ? macroRaw / macroMax : 0.0
macroBuyMod  = isDay and useMacro ? math.round(macroPct *  macroMaxBonus) : 0
macroSellMod = isDay and useMacro ? math.round(-macroPct * macroMaxBonus) : 0
macroMode = not (isDay and useMacro) ? "OFF" : macroAvailable == 3 ? "FULL" : macroAvailable >= 1 ? "PARTIAL" : "NONE"

// ════════════════════════════════════════════════════════════════════════════
// SCORING (0-100)
// ════════════════════════════════════════════════════════════════════════════
patternScoreBull = bullPatternStrong[1] ? 20 : bullPatternPrev ? 12 : 0
patternScoreBear = bearPatternStrong[1] ? 20 : bearPatternPrev ? 12 : 0
patternScoreBullScalp = bullPatternStrong[1] ? 25 : bullPatternPrev ? 15 : 0
patternScoreBearScalp = bearPatternStrong[1] ? 25 : bearPatternPrev ? 15 : 0

// Day Mode (max ~100):
// Trend 25, Pullback 20, Pattern 20, Break 10, R:R 15, Macro 10
buyScoreDay  = (trendBullStrength == 3 ? 25 : trendBullStrength == 2 ? 17 : 0) +
   bullPullbackQuality[1] + patternScoreBull + bullBreakStrength +
   math.max(0, 15 - math.round(buyRRpenalty)) +
   math.max(0, math.min(10, macroBuyMod * 10 / math.max(1, macroMaxBonus)))
sellScoreDay = (trendBearStrength == 3 ? 25 : trendBearStrength == 2 ? 17 : 0) +
   bearPullbackQuality[1] + patternScoreBear + bearBreakStrength +
   math.max(0, 15 - math.round(sellRRpenalty)) +
   math.max(0, math.min(10, macroSellMod * 10 / math.max(1, macroMaxBonus)))

// Scalp Mode (max ~100):
// BB 25, RSI 20, Pattern 25, Re-entry 15, R:R 15
buyScoreScalp  = buyBBStrength[1] + buyRSIStrength[1] + patternScoreBullScalp + buyReentryScore +
   math.max(0, 15 - math.round(buyRRpenalty))
sellScoreScalp = sellBBStrength[1] + sellRSIStrength[1] + patternScoreBearScalp + sellReentryScore +
   math.max(0, 15 - math.round(sellRRpenalty))

buyScore  = isDay ? buyScoreDay  : buyScoreScalp
sellScore = isDay ? sellScoreDay : sellScoreScalp
buyScore  := math.max(0, math.min(100, buyScore))
sellScore := math.max(0, math.min(100, sellScore))

// Grade
gradeOf(float s) => s >= 85 ? "A" : s >= 70 ? "B" : s >= 50 ? "C" : s >= 30 ? "D" : "F"
buyGrade  = gradeOf(buyScore)
sellGrade = gradeOf(sellScore)

// ════════════════════════════════════════════════════════════════════════════
// PACING — daily count + spacing
// ════════════════════════════════════════════════════════════════════════════
var int lastSignalBar = -1000
var int signalsToday  = 0
var int lastDay       = na
isNewDay = na(lastDay) or dayofmonth != lastDay
if isNewDay
    signalsToday := 0
    lastDay := dayofmonth
spacingOK = bar_index - lastSignalBar >= minBarsBetween
dailyCapOK = signalsToday < maxSignalsPerDay

// ════════════════════════════════════════════════════════════════════════════
// FINAL SIGNAL GATES
// ════════════════════════════════════════════════════════════════════════════
buyShown  = buyCandidate  and buyRROK  and spacingOK and dailyCapOK
sellShown = sellCandidate and sellRROK and spacingOK and dailyCapOK

if buyShown or sellShown
    lastSignalBar := bar_index
    signalsToday  := signalsToday + 1

// Per-grade daily counter
var int cntA = 0, var int cntB = 0, var int cntC = 0, var int cntD = 0, var int cntF = 0
if isNewDay
    cntA := 0, cntB := 0, cntC := 0, cntD := 0, cntF := 0
if buyShown or sellShown
    g = buyShown ? buyGrade : sellGrade
    if g == "A"
        cntA := cntA + 1
    else if g == "B"
        cntB := cntB + 1
    else if g == "C"
        cntC := cntC + 1
    else if g == "D"
        cntD := cntD + 1
    else
        cntF := cntF + 1

// ════════════════════════════════════════════════════════════════════════════
// HELPERS
// ════════════════════════════════════════════════════════════════════════════
f_gradePassesAlert(string g) =>
    if alertMinGradeIn == "A only"
        g == "A"
    else if alertMinGradeIn == "A + B"
        g == "A" or g == "B"
    else if alertMinGradeIn == "A + B + C"
        g == "A" or g == "B" or g == "C"
    else
        true
f_gradePassesLines(string g) =>
    if linesMinGradeIn == "A only"
        g == "A"
    else if linesMinGradeIn == "A + B"
        g == "A" or g == "B"
    else if linesMinGradeIn == "A + B + C"
        g == "A" or g == "B" or g == "C"
    else
        true
emojiOf(string g) => g == "A" ? "💎" : g == "B" ? "✅" : g == "C" ? "🟡" : g == "D" ? "⚪" : "·"

// ════════════════════════════════════════════════════════════════════════════
// TRADE TRACKING (indicative)
// ════════════════════════════════════════════════════════════════════════════
var string trkDir   = ""
var float  trkEntry = na
var float  trkSL    = na
var float  trkTP1   = na
var float  trkTP2   = na
var string trkStatus = "None"
var int    trkBarOpen = na
var string trkGrade   = ""
var string trkMode    = ""

if buyShown
    trkDir := "BUY", trkEntry := buyEntry, trkSL := buySL, trkTP1 := buyTP1, trkTP2 := isDay ? buyTP2 : buyTP1, trkStatus := "Pending", trkBarOpen := bar_index, trkGrade := buyGrade, trkMode := modeSel
if sellShown
    trkDir := "SELL", trkEntry := sellEntry, trkSL := sellSL, trkTP1 := sellTP1, trkTP2 := isDay ? sellTP2 : sellTP1, trkStatus := "Pending", trkBarOpen := bar_index, trkGrade := sellGrade, trkMode := modeSel

if trkStatus != "None" and trkStatus != "SL Hit" and trkStatus != "TP2 Hit" and trkStatus != "TP3 Trailed"
    if trkDir == "BUY"
        slHit = low <= trkSL
        tp1   = high >= trkTP1
        tp2   = trkMode == "Day" and high >= trkTP2
        trailExit = trkMode == "Day" and (trkStatus == "TP1 Hit" or trkStatus == "TP2 Hit") and close < emaTrail
        if slHit and (tp1 or tp2)
            trkStatus := "SL Hit (ambig)"
        else if slHit
            trkStatus := "SL Hit"
        else if tp2
            trkStatus := "TP2 Hit"
        else if tp1 and trkStatus == "Pending"
            trkStatus := "TP1 Hit"
        else if trailExit
            trkStatus := "TP3 Trailed"
    else if trkDir == "SELL"
        slHit = high >= trkSL
        tp1   = low  <= trkTP1
        tp2   = trkMode == "Day" and low <= trkTP2
        trailExit = trkMode == "Day" and (trkStatus == "TP1 Hit" or trkStatus == "TP2 Hit") and close > emaTrail
        if slHit and (tp1 or tp2)
            trkStatus := "SL Hit (ambig)"
        else if slHit
            trkStatus := "SL Hit"
        else if tp2
            trkStatus := "TP2 Hit"
        else if tp1 and trkStatus == "Pending"
            trkStatus := "TP1 Hit"
        else if trailExit
            trkStatus := "TP3 Trailed"

barsSinceTrk = na(trkBarOpen) ? na : bar_index - trkBarOpen

// ════════════════════════════════════════════════════════════════════════════
// VISUALS
// ════════════════════════════════════════════════════════════════════════════
// Reference lines on chart
plot(showEMA20 and isDay ? emaFast : na, "EMA Fast (Day)",  color=color.new(color.yellow, 30), linewidth=1)
plot(showEMA20 and isDay ? emaSlow : na, "EMA Slow (Day)",  color=color.new(color.orange, 50), linewidth=1)
plot(showBB and isScalp ? bbUpper : na, "BB Upper (Scalp)", color=color.new(color.aqua, 50))
plot(showBB and isScalp ? bbBasis : na, "BB Middle (Scalp)",color=color.new(color.aqua, 30), linewidth=1)
plot(showBB and isScalp ? bbLower : na, "BB Lower (Scalp)", color=color.new(color.aqua, 50))

// Tiered plotshapes
plotshape(buyShown  and buyGrade  == "A", "BUY A",  shape.triangleup,   location.belowbar, color.new(color.green,0),  size=size.large, text="A")
plotshape(buyShown  and buyGrade  == "B", "BUY B",  shape.triangleup,   location.belowbar, color.new(color.green,20), size=size.small)
plotshape(buyShown  and buyGrade  == "C", "BUY C",  shape.triangleup,   location.belowbar, color.new(color.green,50), size=size.tiny)
plotshape(buyShown  and buyGrade  == "D", "BUY D",  shape.circle,       location.belowbar, color.new(color.green,70), size=size.tiny)
plotshape(buyShown  and buyGrade  == "F", "BUY F",  shape.circle,       location.belowbar, color.new(color.gray, 70), size=size.tiny)
plotshape(sellShown and sellGrade == "A", "SELL A", shape.triangledown, location.abovebar, color.new(color.red,0),    size=size.large, text="A")
plotshape(sellShown and sellGrade == "B", "SELL B", shape.triangledown, location.abovebar, color.new(color.red,20),   size=size.small)
plotshape(sellShown and sellGrade == "C", "SELL C", shape.triangledown, location.abovebar, color.new(color.red,50),   size=size.tiny)
plotshape(sellShown and sellGrade == "D", "SELL D", shape.circle,       location.abovebar, color.new(color.red,70),   size=size.tiny)
plotshape(sellShown and sellGrade == "F", "SELL F", shape.circle,       location.abovebar, color.new(color.gray, 70), size=size.tiny)

// Score labels
if showScoreLbl and buyShown and f_gradePassesLines(buyGrade)
    label.new(bar_index, low - atr * 0.6,
       emojiOf(buyGrade) + " BUY " + str.tostring(buyScore, "#") + " [" + buyGrade + "] " + modeSel + "\nE " + str.tostring(buyEntry, "#.##") + " SL " + str.tostring(buySL, "#.##") + "\nTP1 " + str.tostring(buyTP1, "#.##") + " R:R " + str.tostring(buyRR, "#.##"),
       color=color.new(color.green, 20), style=label.style_label_up, textcolor=color.white, size=size.small)
if showScoreLbl and sellShown and f_gradePassesLines(sellGrade)
    label.new(bar_index, high + atr * 0.6,
       emojiOf(sellGrade) + " SELL " + str.tostring(sellScore, "#") + " [" + sellGrade + "] " + modeSel + "\nE " + str.tostring(sellEntry, "#.##") + " SL " + str.tostring(sellSL, "#.##") + "\nTP1 " + str.tostring(sellTP1, "#.##") + " R:R " + str.tostring(sellRR, "#.##"),
       color=color.new(color.red, 20), style=label.style_label_down, textcolor=color.white, size=size.small)

// SL/TP lines
buyDrawLines  = buyShown  and f_gradePassesLines(buyGrade)
sellDrawLines = sellShown and f_gradePassesLines(sellGrade)
var line slLn = na, var line tp1Ln = na, var line tp2Ln = na
if showLines and (buyDrawLines or sellDrawLines)
    line.delete(slLn), line.delete(tp1Ln), line.delete(tp2Ln)
    slPx = buyDrawLines ? buySL  : sellSL
    t1   = buyDrawLines ? buyTP1 : sellTP1
    t2   = isDay ? (buyDrawLines ? buyTP2 : sellTP2) : na
    slLn  := line.new(bar_index, slPx, bar_index + 30, slPx, color=color.red,   width=2, style=line.style_dashed, extend=extend.right)
    tp1Ln := line.new(bar_index, t1,   bar_index + 30, t1,   color=color.green, width=1, extend=extend.right)
    if isDay and not na(t2)
        tp2Ln := line.new(bar_index, t2, bar_index + 30, t2, color=color.green, width=2, extend=extend.right)

// ════════════════════════════════════════════════════════════════════════════
// DASHBOARD
// ════════════════════════════════════════════════════════════════════════════
var table dash = table.new(dPos, 2, 20, bgcolor=bgCol, border_width=1, border_color=borderCol, frame_color=borderCol, frame_width=1)
f_row(int r, string k, string v, color c) =>
    table.cell(dash, 0, r, k, text_color=textCol, bgcolor=color.new(color.gray, 90), text_size=size.small)
    table.cell(dash, 1, r, v, text_color=c, bgcolor=color.new(color.gray, 95), text_size=size.small)

if showDash and barstate.islast
    table.clear(dash, 0, 0, 1, 19)
    table.cell(dash, 0, 0, "GTA v2.0", text_color=textCol, bgcolor=headerBg, text_size=size.small)
    table.cell(dash, 1, 0, modeSel + " Mode", text_color=textCol, bgcolor=headerBg, text_size=size.small)
    if isDay
        f_row(1, "Trend Bull", str.tostring(trendBullStrength) + "/3" + (trendBullStrength==3?" STRONG":trendBullStrength==2?" weak":" —"), trendBullStrength >= 2 ? color.green : textCol)
        f_row(2, "Trend Bear", str.tostring(trendBearStrength) + "/3" + (trendBearStrength==3?" STRONG":trendBearStrength==2?" weak":" —"), trendBearStrength >= 2 ? color.red : textCol)
        f_row(3, "HTF EMAs", str.tostring(htfFastEMA, "#.##") + " / " + str.tostring(htfSlowEMA, "#.##"), textCol)
        f_row(4, "Pullback Bull", bullPullbackOK ? "OK depth " + str.tostring(bullPullbackDepth/atr, "#.#") + "×ATR" : "—", bullPullbackOK ? color.green : textCol)
        f_row(5, "Pullback Bear", bearPullbackOK ? "OK depth " + str.tostring(bearPullbackDepth/atr, "#.#") + "×ATR" : "—", bearPullbackOK ? color.red : textCol)
        f_row(6, "Macro Mode", macroMode, macroMode == "FULL" ? color.green : macroMode == "PARTIAL" ? color.orange : macroMode == "NONE" ? color.red : textCol)
        f_row(7, "Macro Bias", str.tostring(math.round(macroPct * 100)) + "%", macroPct > 0 ? color.green : macroPct < 0 ? color.red : textCol)
    else
        f_row(1, "BB Upper",  str.tostring(bbUpper, "#.##"), textCol)
        f_row(2, "BB Middle", str.tostring(bbBasis, "#.##"), textCol)
        f_row(3, "BB Lower",  str.tostring(bbLower, "#.##"), textCol)
        f_row(4, "RSI(14)", str.tostring(rsi, "#.#") + (rsi >= rsiOB ? " OB" : rsi <= rsiOS ? " OS" : ""), rsi >= rsiOB ? color.red : rsi <= rsiOS ? color.green : textCol)
        f_row(5, "Buy extreme",  buyExtremeNow  ? "✓ active"   : "—", buyExtremeNow  ? color.green : textCol)
        f_row(6, "Sell extreme", sellExtremeNow ? "✓ active"   : "—", sellExtremeNow ? color.red   : textCol)
        f_row(7, "—", "", textCol)
    f_row(8,  "Buy Score",   str.tostring(buyScore,  "#") + " [" + buyGrade  + "]",  buyScore  >= 70 ? color.green : buyScore  >= 50 ? color.orange : textCol)
    f_row(9,  "Sell Score",  str.tostring(sellScore, "#") + " [" + sellGrade + "]",  sellScore >= 70 ? color.green : sellScore >= 50 ? color.orange : textCol)
    f_row(10, "Today (any)", str.tostring(signalsToday) + "/" + str.tostring(maxSignalsPerDay), signalsToday >= maxSignalsPerDay ? color.red : textCol)
    f_row(11, "Today grades", "A:"+str.tostring(cntA)+" B:"+str.tostring(cntB)+" C:"+str.tostring(cntC)+" D:"+str.tostring(cntD)+" F:"+str.tostring(cntF), textCol)
    f_row(12, "Last Signal", trkDir == "" ? "—" : trkDir + " [" + trkGrade + "] " + trkMode + " @ " + str.tostring(trkEntry, "#.##"), trkDir == "BUY" ? color.green : trkDir == "SELL" ? color.red : textCol)
    f_row(13, "Status",  trkStatus, trkStatus == "SL Hit" or trkStatus == "SL Hit (ambig)" ? color.red : str.contains(trkStatus, "TP") ? color.green : textCol)
    f_row(14, "SL / TP1", na(trkSL) ? "—" : str.tostring(trkSL, "#.##") + " / " + str.tostring(trkTP1, "#.##"), textCol)
    f_row(15, "Bars since", na(barsSinceTrk) ? "—" : str.tostring(barsSinceTrk), textCol)
    f_row(16, "Alerts on",  alertMinGradeIn, textCol)
    f_row(17, "Hybrid R:R", "≥"+str.tostring(fullRRThr,"#.#")+" full · <"+str.tostring(hardRejectRR,"#.#")+" reject", textCol)
    f_row(18, "Suggested risk", isDay ? str.tostring(suggestedRiskDay, "#.#")+"%" : str.tostring(suggestedRiskScalp,"#.#")+"%", textCol)
    f_row(19, "TF / Strict", timeframe.period + " | " + (strictMode ? "Strict" : "Early"), textCol)

// ════════════════════════════════════════════════════════════════════════════
// ALERTS — JSON + per-grade conditions
// ════════════════════════════════════════════════════════════════════════════
f_json(string ev, string dir, float e, float sl, float t1, float t2, float sc, string gr, string md) =>
    '{"event":"' + ev + '","symbol":"' + syminfo.tickerid + '","timeframe":"' + timeframe.period +
     '","mode":"' + md + '","direction":"' + dir + '","grade":"' + gr +
     '","entry":' + str.tostring(e, "#.##") +
     ',"sl":' + str.tostring(sl, "#.##") +
     ',"tp1":' + str.tostring(t1, "#.##") +
     ',"tp2":' + str.tostring(t2, "#.##") +
     ',"score":' + str.tostring(sc, "#") +
     ',"timestamp":"' + str.tostring(time) + '"}'

buyMsg  = f_json("buy_signal",  "BUY",  buyEntry,  buySL,  buyTP1,  isDay ? buyTP2 : buyTP1,  buyScore,  buyGrade,  modeSel)
sellMsg = f_json("sell_signal", "SELL", sellEntry, sellSL, sellTP1, isDay ? sellTP2 : sellTP1, sellScore, sellGrade, modeSel)

alertcondition(buyShown  and buyGrade  == "A", "GTA v2.0 BUY  A",  "BUY-A")
alertcondition(sellShown and sellGrade == "A", "GTA v2.0 SELL A",  "SELL-A")
alertcondition(buyShown  and buyGrade  == "B", "GTA v2.0 BUY  B",  "BUY-B")
alertcondition(sellShown and sellGrade == "B", "GTA v2.0 SELL B",  "SELL-B")
alertcondition(buyShown  and (buyGrade  == "A" or buyGrade  == "B"), "GTA v2.0 BUY  A+B",  "BUY-AB")
alertcondition(sellShown and (sellGrade == "A" or sellGrade == "B"), "GTA v2.0 SELL A+B",  "SELL-AB")
alertcondition(buyShown,  "GTA v2.0 BUY  any",  "BUY")
alertcondition(sellShown, "GTA v2.0 SELL any",  "SELL")

if buyShown and f_gradePassesAlert(buyGrade)
    alert(buyMsg,  alert.freq_once_per_bar_close)
if sellShown and f_gradePassesAlert(sellGrade)
    alert(sellMsg, alert.freq_once_per_bar_close)
````
