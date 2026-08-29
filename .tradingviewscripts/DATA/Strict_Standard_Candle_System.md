<!-- tradingview-pine-id: PUB;0d64fc31fb46499282bbc0a498a3b8a3 -->
<!-- tradingviewscripts-format: 1 -->
# Strict Standard Candle System

Source: https://www.tradingview.com/script/mVhwA8el-Strict-Standard-Candle-System/

## Description

//@version=6
indicator("Strict Standard Candle System", overlay=true)

// ==========================================
// 1. STANDARD CANDLE DATA MAPPING
// ==========================================
sOpen  = open
sHigh  = high
sLow   = low
sClose = close

// ==========================================
// 2. WICK DEFINITIONS  (Spec item 1)
// ==========================================
isBullishCandle = sClose >= sOpen
isBearishCandle = sClose <  sOpen

upperWick = isBullishCandle ? (sHigh - sClose) : (sHigh - sOpen)
lowerWick = isBullishCandle ? (sOpen - sLow)   : (sClose - sLow)

// ==========================================
// 3. REAL BODY / DOJI DEFINITIONS  (Spec items 2 & 3)
// ==========================================
tbody = sHigh - sLow
vbody = math.abs(sClose - sOpen)

safeTbody  = tbody == 0 ? 0.00001 : tbody
vbodyRatio = (vbody / safeTbody) * 100

bodyRatioCondition   = vbodyRatio > 75.0
bullishUpperWickOnly = isBullishCandle and lowerWick == 0
bearishLowerWickOnly = isBearishCandle and upperWick == 0

isRealBodyCandle = bodyRatioCondition or bullishUpperWickOnly or bearishLowerWickOnly
isDojiCandle     = not isRealBodyCandle
signalIsNotDoji  = isRealBodyCandle

// ==========================================
// 4. EMA 15 (red) / EMA 59 (purple) ONLY  (Spec item 4)
// ==========================================
emaFast = ta.ema(sClose, 15)
emaSlow = ta.ema(sClose, 59)

plot(emaFast, color=color.red,    title="15 EMA", linewidth=3)
plot(emaSlow, color=color.purple, title="59 EMA", linewidth=3)

// ==========================================
// 5. CASE (a) - EMA crossed a Real Body candle, with at least 3 CONSECUTIVE
//    doji candles found somewhere WITHIN the previous 6 candles (not
//    necessarily the 3 candles immediately before the signal).
//    UPDATED RULE: "at least 3 consecutive candles out of previous 6 as doji"
// ==========================================
dojiConsecutiveRequired = input.int(3, title="Minimum Consecutive Doji Candles", minval=1, group="Case A - Candle / EMA")
dojiLookbackWindow      = input.int(6, title="Doji Search Window (Previous N Candles)", minval=3, group="Case A - Candle / EMA")

dojiStreakOk = false
for s = 1 to (dojiLookbackWindow - dojiConsecutiveRequired + 1)
    streakFound = true
    for k = 0 to dojiConsecutiveRequired - 1
        if not isDojiCandle[s + k]
            streakFound := false
    if streakFound
        dojiStreakOk := true

ema15CrossCandle = (sLow <= emaFast and sHigh >= emaFast) and isRealBodyCandle
ema59CrossCandle = (sLow <= emaSlow and sHigh >= emaSlow) and isRealBodyCandle
emaCrossedRealBodyCore = ema15CrossCandle or ema59CrossCandle

ema15TiltingUp   = emaFast > emaFast[1]
ema59TiltingUp   = emaSlow > emaSlow[1]
ema15TiltingDown = emaFast < emaFast[1]
ema59TiltingDown = emaSlow < emaSlow[1]

// FIX: changed from "or" to "and" -- with "or", EMA15 turning up while EMA59
// is still turning down (common right at a trend change) made BOTH
// coreA_bullish and coreA_bearish true on the same bar. Requiring both EMAs
// to agree makes the two mutually exclusive by construction.
coreA_bullish = emaCrossedRealBodyCore and dojiStreakOk and signalIsNotDoji and (ema15TiltingUp and ema59TiltingUp)
coreA_bearish = emaCrossedRealBodyCore and dojiStreakOk and signalIsNotDoji and (ema15TiltingDown and ema59TiltingDown)

// "Recently" = the qualifying core event happened on this bar or the previous bar
caseA_bullish = coreA_bullish or coreA_bullish[1]
caseA_bearish = coreA_bearish or coreA_bearish[1]

// ==========================================
// 6. MACD (16, 26, 9) + PCO / NCO  (Spec items 5, 6, 7)
// ==========================================
fast_length   = input.int(16, title="MACD Fast Length", group="Case B/C/D - MACD Crossover")
slow_length   = input.int(26, title="MACD Slow Length", group="Case B/C/D - MACD Crossover")
signal_length = input.int(9,  title="MACD Signal Length", group="Case B/C/D - MACD Crossover")

[macdLine, signalLine, macdHist] = ta.macd(sClose, fast_length, slow_length, signal_length)

PCO = ta.crossover(macdLine, signalLine)
NCO = ta.crossunder(macdLine, signalLine)

// ==========================================
// 7. VOLATILITY REFERENCE
// ==========================================
atrLen = input.int(14, title="ATR Length", group="Volatility")
atrNormalized = ta.atr(atrLen)
safeAtr = atrNormalized == 0 ? 0.00001 : atrNormalized

macdChange = macdLine - macdLine[1]
macdSlope  = macdChange / safeAtr
macdAngle  = math.todegrees(math.atan(macdSlope))

// ==========================================
// 7b. MACD/SIGNAL LINE OVERLAP FILTER
//     RESTORED FIX: opt-in toggle (default OFF). Checking "not overlapping"
//     unconditionally at the exact crossover bar fights the crossover
//     detection itself, since lines are always closest right at the cross.
// ==========================================
overlapThresholdPct = input.float(1.0, title="MACD/Signal Overlap Threshold (% of ATR)", minval=0.1, group="Overlap Filter")
applyOverlapFilter   = input.bool(false, title="Require Lines Not Overlapping at Signal Bar (extra filter)", group="Overlap Filter")

macdSignalGap    = math.abs(macdLine - signalLine)
macdSignalGapPct = (macdSignalGap / safeAtr) * 100
linesOverlapping = macdSignalGapPct <= overlapThresholdPct

// ==========================================
// 8. MACD HISTOGRAM FADE / BOLD CLASSIFICATION
// ==========================================
histGreenFade = macdHist >= 0 and macdHist <= macdHist[1]
histRedFade   = macdHist <  0 and macdHist >= macdHist[1]

histGreenBold = macdHist >= 0 and macdHist >  macdHist[1]
histRedBold   = macdHist <  0 and macdHist <  macdHist[1]

// ==========================================
// 9. CASE (b) + (c) - MACD crossover lookback with the angle filter and
//    Case (c) bypass. Case (d)'s fade check now lives entirely in section 12
//    (checked on the current/signal bar) instead of here at the historical
//    crossover bar -- removed so there's only one fade check, on one bar.
// ==========================================
angleThreshold   = input.float(40.0, title="Minimum MACD Crossover Angle (Degrees)", group="Case B/C/D - MACD Crossover")
macdLookbackBars = input.int(6, title="MACD Crossover Lookback (Last N Histograms)", minval=2, group="Case B/C/D - MACD Crossover")

bcdBullish = false
bcdBearish = false
for i = 0 to macdLookbackBars - 1
    angleOk = (i <= 1) or (math.abs(macdAngle) > angleThreshold)   // Case (c): current/previous bar skips the angle check
    if PCO and angleOk
        bcdBullish := true
    if NCO and angleOk
        bcdBearish := true

caseABD_bullish = caseA_bullish and bcdBullish
caseABD_bearish = caseA_bearish and bcdBearish

// ==========================================
// 10. CASE (e) - delayed confirmation, BOTH ORDERINGS ALLOWED
// ==========================================
caseELookbackMin = input.int(1, title="Case E: Minimum Bars Apart", minval=1, group="Case E - Delayed Confirmation")
caseELookbackMax = input.int(4, title="Case E: Maximum Bars Apart", minval=1, group="Case E - Delayed Confirmation")
includeCaseE     = input.bool(true, title="Include Case E as a trigger", group="Case E - Delayed Confirmation")

bcdBullishInWindow = false
bcdBearishInWindow = false
coreABullishInWindow = false
coreABearishInWindow = false
for i = caseELookbackMin to caseELookbackMax
    if bcdBullish
        bcdBullishInWindow := true
    if bcdBearish
        bcdBearishInWindow := true
    if coreA_bullish
        coreABullishInWindow := true
    if coreA_bearish
        coreABearishInWindow := true

caseE1_bullish = caseA_bullish and bcdBullishInWindow      // bcd -> then caseA
caseE1_bearish = caseA_bearish and bcdBearishInWindow

caseE2_bullish = bcdBullish and coreABullishInWindow       // caseA -> then bcd
caseE2_bearish = bcdBearish and coreABearishInWindow

caseE_bullish = caseE1_bullish or caseE2_bullish
caseE_bearish = caseE1_bearish or caseE2_bearish

// ==========================================
// 11. CASE (f) / (g) - MACD Bold-Reversal Override
// ==========================================
minFadeStreakFG = input.int(3, title="Case F/G: Minimum Fade Streak Before Bold Pair", minval=1, group="Case F/G - MACD Bold Reversal")

firstBoldGreen  = histGreenBold[1]
secondBoldGreen = histGreenBold
firstBoldRed    = histRedBold[1]
secondBoldRed   = histRedBold

greenFadeStreakOk = true
for i = 2 to (1 + minFadeStreakFG)
    if not histGreenFade
        greenFadeStreakOk := false

redFadeStreakOk = true
for i = 2 to (1 + minFadeStreakFG)
    if not histRedFade
        redFadeStreakOk := false

greenHeightBeatsFades = math.abs(macdHist) > math.abs(macdHist[2]) and math.abs(macdHist) > math.abs(macdHist[3])
redHeightBeatsFades   = math.abs(macdHist) > math.abs(macdHist[2]) and math.abs(macdHist) > math.abs(macdHist[3])

caseF_bullish = firstBoldGreen and secondBoldGreen and greenFadeStreakOk and greenHeightBeatsFades
caseG_bearish = firstBoldRed   and secondBoldRed   and redFadeStreakOk   and redHeightBeatsFades

// ==========================================
// 12. COMBINED STRATEGY TRIGGERS
// ==========================================
rawBuySignal  = caseABD_bullish or (includeCaseE and caseE_bullish) or caseF_bullish
rawSellSignal = caseABD_bearish or (includeCaseE and caseE_bearish) or caseG_bearish

// FINAL GUARANTEE: caseABD / caseE / caseF-G are three independent mechanisms
// combined with "or". Even after the coreA fix above, it's still possible in
// principle for one mechanism to justify a buy while a different one
// independently justifies a sell on the same bar (e.g. an older MACD
// crossover inside the case b/c/d lookback vs. a fresh histogram
// bold-reversal pattern from case f/g). Rather than guess which one should
// "win", both are suppressed on any bar where this happens -- buySignal and
// sellSignal can never both be true.
bothTriggered = rawBuySignal and rawSellSignal

// NEW: distinct from the fade check inside the section 9 loop (which only
// looks at whichever historical bar the crossover happened on). This checks
// the CURRENT bar specifically -- at the moment the signal is generating,
// the histogram itself must not be fading. Applies to every mechanism
// (case a-d, case e, case f/g) since it's checked on the final signal.
buySignal  = rawBuySignal  and not bothTriggered and (not applyOverlapFilter or not linesOverlapping) and not histGreenFade
sellSignal = rawSellSignal and not bothTriggered and (not applyOverlapFilter or not linesOverlapping) and not histRedFade

plotshape(series=buySignal,  title="Strict Buy Trigger",  style=shape.triangleup,   location=location.belowbar, color=color.green, size=size.small)
plotshape(series=sellSignal, title="Strict Sell Trigger", style=shape.triangledown, location=location.abovebar, color=color.red,   size=size.small)

// ==========================================
// 13. DEBUG MARKERS
// ==========================================
//showDebug = input.bool(true, title="Show Debug Markers", group="Debug")

//plotchar(showDebug and isDojiCandle,        title="Doji Marker",     char="D", location=location.belowbar, color=color.gray,   size=size.tiny)
//plotchar(showDebug and isRealBodyCandle,    title="Real Body Marker",char="R", location=location.abovebar, color=color.teal,   size=size.tiny)
//plotchar(showDebug and emaCrossedRealBodyCore, title="EMA Cross Marker", char="X", location=location.abovebar, color=color.blue, size=size.tiny)
//plotchar(showDebug and (coreA_bullish or coreA_bearish), title="Case A Core Marker", char="S", location=location.belowbar, color=color.orange, size=size.tiny)
//plotchar(showDebug and bothTriggered, title="Conflict Suppressed Marker", char="!", location=location.top, color=color.fuchsia, size=size.tiny)

---

## Source Code

````pine
//@version=6
indicator("Strict Standard Candle System", overlay=true)

// ==========================================
// 1. STANDARD CANDLE DATA MAPPING
// ==========================================
sOpen  = open
sHigh  = high
sLow   = low
sClose = close

// ==========================================
// 2. WICK DEFINITIONS  (Spec item 1)
// ==========================================
isBullishCandle = sClose >= sOpen
isBearishCandle = sClose <  sOpen

upperWick = isBullishCandle ? (sHigh - sClose) : (sHigh - sOpen)
lowerWick = isBullishCandle ? (sOpen - sLow)   : (sClose - sLow)

// ==========================================
// 3. REAL BODY / DOJI DEFINITIONS  (Spec items 2 & 3)
// ==========================================
tbody = sHigh - sLow
vbody = math.abs(sClose - sOpen)

safeTbody  = tbody == 0 ? 0.00001 : tbody
vbodyRatio = (vbody / safeTbody) * 100

bodyRatioCondition   = vbodyRatio > 75.0
bullishUpperWickOnly = isBullishCandle and lowerWick == 0
bearishLowerWickOnly = isBearishCandle and upperWick == 0

isRealBodyCandle = bodyRatioCondition or bullishUpperWickOnly or bearishLowerWickOnly
isDojiCandle     = not isRealBodyCandle
signalIsNotDoji  = isRealBodyCandle

// ==========================================
// 4. EMA 15 (red) / EMA 59 (purple) ONLY  (Spec item 4)
// ==========================================
emaFast = ta.ema(sClose, 15)
emaSlow = ta.ema(sClose, 59)

plot(emaFast, color=color.red,    title="15 EMA", linewidth=3)
plot(emaSlow, color=color.purple, title="59 EMA", linewidth=3)

// ==========================================
// 5. CASE (a) - EMA crossed a Real Body candle, with at least 3 CONSECUTIVE
//    doji candles found somewhere WITHIN the previous 6 candles (not
//    necessarily the 3 candles immediately before the signal).
//    UPDATED RULE: "at least 3 consecutive candles out of previous 6 as doji"
// ==========================================
dojiConsecutiveRequired = input.int(3, title="Minimum Consecutive Doji Candles", minval=1, group="Case A - Candle / EMA")
dojiLookbackWindow      = input.int(6, title="Doji Search Window (Previous N Candles)", minval=3, group="Case A - Candle / EMA")

dojiStreakOk = false
for s = 1 to (dojiLookbackWindow - dojiConsecutiveRequired + 1)
    streakFound = true
    for k = 0 to dojiConsecutiveRequired - 1
        if not isDojiCandle[s + k]
            streakFound := false
    if streakFound
        dojiStreakOk := true

ema15CrossCandle = (sLow <= emaFast and sHigh >= emaFast) and isRealBodyCandle
ema59CrossCandle = (sLow <= emaSlow and sHigh >= emaSlow) and isRealBodyCandle
emaCrossedRealBodyCore = ema15CrossCandle or ema59CrossCandle

ema15TiltingUp   = emaFast > emaFast[1]
ema59TiltingUp   = emaSlow > emaSlow[1]
ema15TiltingDown = emaFast < emaFast[1]
ema59TiltingDown = emaSlow < emaSlow[1]

// FIX: changed from "or" to "and" -- with "or", EMA15 turning up while EMA59
// is still turning down (common right at a trend change) made BOTH
// coreA_bullish and coreA_bearish true on the same bar. Requiring both EMAs
// to agree makes the two mutually exclusive by construction.
coreA_bullish = emaCrossedRealBodyCore and dojiStreakOk and signalIsNotDoji and (ema15TiltingUp and ema59TiltingUp)
coreA_bearish = emaCrossedRealBodyCore and dojiStreakOk and signalIsNotDoji and (ema15TiltingDown and ema59TiltingDown)

// "Recently" = the qualifying core event happened on this bar or the previous bar
caseA_bullish = coreA_bullish or coreA_bullish[1]
caseA_bearish = coreA_bearish or coreA_bearish[1]

// ==========================================
// 6. MACD (16, 26, 9) + PCO / NCO  (Spec items 5, 6, 7)
// ==========================================
fast_length   = input.int(16, title="MACD Fast Length", group="Case B/C/D - MACD Crossover")
slow_length   = input.int(26, title="MACD Slow Length", group="Case B/C/D - MACD Crossover")
signal_length = input.int(9,  title="MACD Signal Length", group="Case B/C/D - MACD Crossover")

[macdLine, signalLine, macdHist] = ta.macd(sClose, fast_length, slow_length, signal_length)

PCO = ta.crossover(macdLine, signalLine)
NCO = ta.crossunder(macdLine, signalLine)

// ==========================================
// 7. VOLATILITY REFERENCE
// ==========================================
atrLen = input.int(14, title="ATR Length", group="Volatility")
atrNormalized = ta.atr(atrLen)
safeAtr = atrNormalized == 0 ? 0.00001 : atrNormalized

macdChange = macdLine - macdLine[1]
macdSlope  = macdChange / safeAtr
macdAngle  = math.todegrees(math.atan(macdSlope))

// ==========================================
// 7b. MACD/SIGNAL LINE OVERLAP FILTER
//     RESTORED FIX: opt-in toggle (default OFF). Checking "not overlapping"
//     unconditionally at the exact crossover bar fights the crossover
//     detection itself, since lines are always closest right at the cross.
// ==========================================
overlapThresholdPct = input.float(1.0, title="MACD/Signal Overlap Threshold (% of ATR)", minval=0.1, group="Overlap Filter")
applyOverlapFilter   = input.bool(false, title="Require Lines Not Overlapping at Signal Bar (extra filter)", group="Overlap Filter")

macdSignalGap    = math.abs(macdLine - signalLine)
macdSignalGapPct = (macdSignalGap / safeAtr) * 100
linesOverlapping = macdSignalGapPct <= overlapThresholdPct

// ==========================================
// 8. MACD HISTOGRAM FADE / BOLD CLASSIFICATION
// ==========================================
histGreenFade = macdHist >= 0 and macdHist <= macdHist[1]
histRedFade   = macdHist <  0 and macdHist >= macdHist[1]

histGreenBold = macdHist >= 0 and macdHist >  macdHist[1]
histRedBold   = macdHist <  0 and macdHist <  macdHist[1]

// ==========================================
// 9. CASE (b) + (c) - MACD crossover lookback with the angle filter and
//    Case (c) bypass. Case (d)'s fade check now lives entirely in section 12
//    (checked on the current/signal bar) instead of here at the historical
//    crossover bar -- removed so there's only one fade check, on one bar.
// ==========================================
angleThreshold   = input.float(40.0, title="Minimum MACD Crossover Angle (Degrees)", group="Case B/C/D - MACD Crossover")
macdLookbackBars = input.int(6, title="MACD Crossover Lookback (Last N Histograms)", minval=2, group="Case B/C/D - MACD Crossover")

bcdBullish = false
bcdBearish = false
for i = 0 to macdLookbackBars - 1
    angleOk = (i <= 1) or (math.abs(macdAngle[i]) > angleThreshold)   // Case (c): current/previous bar skips the angle check
    if PCO[i] and angleOk
        bcdBullish := true
    if NCO[i] and angleOk
        bcdBearish := true

caseABD_bullish = caseA_bullish and bcdBullish
caseABD_bearish = caseA_bearish and bcdBearish

// ==========================================
// 10. CASE (e) - delayed confirmation, BOTH ORDERINGS ALLOWED
// ==========================================
caseELookbackMin = input.int(1, title="Case E: Minimum Bars Apart", minval=1, group="Case E - Delayed Confirmation")
caseELookbackMax = input.int(4, title="Case E: Maximum Bars Apart", minval=1, group="Case E - Delayed Confirmation")
includeCaseE     = input.bool(true, title="Include Case E as a trigger", group="Case E - Delayed Confirmation")

bcdBullishInWindow = false
bcdBearishInWindow = false
coreABullishInWindow = false
coreABearishInWindow = false
for i = caseELookbackMin to caseELookbackMax
    if bcdBullish[i]
        bcdBullishInWindow := true
    if bcdBearish[i]
        bcdBearishInWindow := true
    if coreA_bullish[i]
        coreABullishInWindow := true
    if coreA_bearish[i]
        coreABearishInWindow := true

caseE1_bullish = caseA_bullish and bcdBullishInWindow      // bcd -> then caseA
caseE1_bearish = caseA_bearish and bcdBearishInWindow

caseE2_bullish = bcdBullish and coreABullishInWindow       // caseA -> then bcd
caseE2_bearish = bcdBearish and coreABearishInWindow

caseE_bullish = caseE1_bullish or caseE2_bullish
caseE_bearish = caseE1_bearish or caseE2_bearish

// ==========================================
// 11. CASE (f) / (g) - MACD Bold-Reversal Override
// ==========================================
minFadeStreakFG = input.int(3, title="Case F/G: Minimum Fade Streak Before Bold Pair", minval=1, group="Case F/G - MACD Bold Reversal")

firstBoldGreen  = histGreenBold[1]
secondBoldGreen = histGreenBold
firstBoldRed    = histRedBold[1]
secondBoldRed   = histRedBold

greenFadeStreakOk = true
for i = 2 to (1 + minFadeStreakFG)
    if not histGreenFade[i]
        greenFadeStreakOk := false

redFadeStreakOk = true
for i = 2 to (1 + minFadeStreakFG)
    if not histRedFade[i]
        redFadeStreakOk := false

greenHeightBeatsFades = math.abs(macdHist) > math.abs(macdHist[2]) and math.abs(macdHist) > math.abs(macdHist[3])
redHeightBeatsFades   = math.abs(macdHist) > math.abs(macdHist[2]) and math.abs(macdHist) > math.abs(macdHist[3])

caseF_bullish = firstBoldGreen and secondBoldGreen and greenFadeStreakOk and greenHeightBeatsFades
caseG_bearish = firstBoldRed   and secondBoldRed   and redFadeStreakOk   and redHeightBeatsFades

// ==========================================
// 12. COMBINED STRATEGY TRIGGERS
// ==========================================
rawBuySignal  = caseABD_bullish or (includeCaseE and caseE_bullish) or caseF_bullish
rawSellSignal = caseABD_bearish or (includeCaseE and caseE_bearish) or caseG_bearish

// FINAL GUARANTEE: caseABD / caseE / caseF-G are three independent mechanisms
// combined with "or". Even after the coreA fix above, it's still possible in
// principle for one mechanism to justify a buy while a different one
// independently justifies a sell on the same bar (e.g. an older MACD
// crossover inside the case b/c/d lookback vs. a fresh histogram
// bold-reversal pattern from case f/g). Rather than guess which one should
// "win", both are suppressed on any bar where this happens -- buySignal and
// sellSignal can never both be true.
bothTriggered = rawBuySignal and rawSellSignal

// NEW: distinct from the fade check inside the section 9 loop (which only
// looks at whichever historical bar the crossover happened on). This checks
// the CURRENT bar specifically -- at the moment the signal is generating,
// the histogram itself must not be fading. Applies to every mechanism
// (case a-d, case e, case f/g) since it's checked on the final signal.
buySignal  = rawBuySignal  and not bothTriggered and (not applyOverlapFilter or not linesOverlapping) and not histGreenFade
sellSignal = rawSellSignal and not bothTriggered and (not applyOverlapFilter or not linesOverlapping) and not histRedFade

plotshape(series=buySignal,  title="Strict Buy Trigger",  style=shape.triangleup,   location=location.belowbar, color=color.green, size=size.small)
plotshape(series=sellSignal, title="Strict Sell Trigger", style=shape.triangledown, location=location.abovebar, color=color.red,   size=size.small)

// ==========================================
// 13. DEBUG MARKERS
// ==========================================
//showDebug = input.bool(true, title="Show Debug Markers", group="Debug")

//plotchar(showDebug and isDojiCandle,        title="Doji Marker",     char="D", location=location.belowbar, color=color.gray,   size=size.tiny)
//plotchar(showDebug and isRealBodyCandle,    title="Real Body Marker",char="R", location=location.abovebar, color=color.teal,   size=size.tiny)
//plotchar(showDebug and emaCrossedRealBodyCore, title="EMA Cross Marker", char="X", location=location.abovebar, color=color.blue, size=size.tiny)
//plotchar(showDebug and (coreA_bullish or coreA_bearish), title="Case A Core Marker", char="S", location=location.belowbar, color=color.orange, size=size.tiny)
//plotchar(showDebug and bothTriggered, title="Conflict Suppressed Marker", char="!", location=location.top, color=color.fuchsia, size=size.tiny)
````
