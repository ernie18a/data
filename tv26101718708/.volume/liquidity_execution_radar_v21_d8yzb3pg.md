# Liquidity Execution Radar v2.1

- url: https://www.tradingview.com/script/D8YZb3Pg-Liquidity-Execution-Radar-v2-1/
- type: indicator
- pine_id: PUB;d63cc2a374e94412991c71c977ec4ff6
- version: 1.0

## Description

1. Reversal and continuation are no longer mixed

That was one of the biggest weaknesses before. Your original script blended those models into one scoring engine, which can make signals look smart while actually reflecting different trade ideas at once.

2. Regime is now a hard governor

Instead of just describing conditions, this version actively downgrades weak regimes so you do not get false confidence in dead or overextended markets.

3. Liquidity mapping is better

This version uses cluster logic instead of mostly adjacent equal highs/lows, which is closer to how real resting liquidity tends to form.

4. RR affects the grade

Now A/A+ needs both:

a strong setup
a strong reward relative to invalidation

That is a much more honest grading model.

5. Labels are more useful

You now see:

REVERSAL LONG
CONTINUATION SHORT
the grade
the RR

That is much more actionable than generic long/short labels.

## Source Code

````pine
//@version=5
indicator("Liquidity Execution Radar v2.1", overlay=true, max_labels_count=300, max_lines_count=300)

//======================================================
// INPUTS
//======================================================
grp1 = "Core Levels"
showPDLevels   = input.bool(true, "Show Previous Day Levels", group=grp1)
showAsiaRange  = input.bool(true, "Show Asia Range", group=grp1)
asiaSession    = input.session("0000-0559", "Asia Session", group=grp1)
sessionTZ      = input.string("Etc/UTC", "Session Timezone", group=grp1)

grp2 = "Execution Engine"
dispATRMult    = input.float(1.20, "Displacement ATR Mult", minval=0.5, step=0.05, group=grp2)
sweepATRMult   = input.float(0.12, "Sweep Buffer ATR Mult", minval=0.01, step=0.01, group=grp2)
wickThresh     = input.float(0.35, "Wick Ratio Threshold", minval=0.10, maxval=0.90, step=0.05, group=grp2)
confirmBars    = input.int(3, "Bars Allowed After Sweep", minval=1, maxval=10, group=grp2)
minRR_A        = input.float(2.0, "Min RR for A / A+", minval=0.5, step=0.1, group=grp2)
minRR_B        = input.float(1.5, "Min RR for B", minval=0.5, step=0.1, group=grp2)

grp3 = "Volume Filter"
volStrongMult  = input.float(1.20, "Strong Volume >= x Avg", minval=0.5, step=0.05, group=grp3)
volVeryStrong  = input.float(1.50, "Very Strong Volume >= x Avg", minval=0.5, step=0.05, group=grp3)
volDeadMult    = input.float(0.65, "Dead Volume < x Avg", minval=0.1, step=0.05, group=grp3)

grp4 = "HTF Bias"
htfTF          = input.timeframe("240", "HTF Timeframe", group=grp4)

grp5 = "Kill Zones (UTC)"
kzLondonH      = input.int(7, "London Open Hour", minval=0, maxval=23, group=grp5)
kzNYH          = input.int(13, "New York Open Hour", minval=0, maxval=23, group=grp5)
kzAsianH       = input.int(0, "Asia Open Hour", minval=0, maxval=23, group=grp5)
kzDuration     = input.int(2, "KZ Duration (hrs)", minval=1, maxval=6, group=grp5)

grp6 = "Structure"
swingLen       = input.int(5, "Swing Length", minval=2, maxval=20, group=grp6)
mssBreakATR    = input.float(0.05, "MSS Break Buffer ATR", minval=0.01, step=0.01, group=grp6)
compressLen    = input.int(6, "Compression Lookback", minval=3, maxval=20, group=grp6)

grp7 = "Liquidity Mapping"
clusterBars    = input.int(15, "Cluster Lookback", minval=5, maxval=50, group=grp7)
eqTolATR       = input.float(0.10, "Cluster Tolerance ATR %", minval=0.01, step=0.01, group=grp7)
showLiqMarks   = input.bool(true, "Show Liquidity Cluster Marks", group=grp7)

grp8 = "ADR / Day Filter"
adrLength      = input.int(14, "ADR Length", minval=5, maxval=50, group=grp8)
useADRFilter   = input.bool(true, "Use ADR Overextension Filter", group=grp8)

grp9 = "Display"
showSweepLbls  = input.bool(true, "Show Sweep Labels", group=grp9)
showEntries    = input.bool(true, "Show Entry Labels", group=grp9)
showTargets    = input.bool(true, "Show Targets", group=grp9)
showInvalid    = input.bool(true, "Show Invalidation", group=grp9)
showBarColor   = input.bool(true, "Color Bars by Bias", group=grp9)
showDash       = input.bool(true, "Show Dashboard", group=grp9)
onlyASetups    = input.bool(false, "Only Show A / A+ Entries", group=grp9)

grp10 = "Colors"
colBull        = input.color(color.lime, "Bull Color", group=grp10)
colBear        = input.color(color.red, "Bear Color", group=grp10)
colMid         = input.color(color.yellow, "Mid Color", group=grp10)
colAsia        = input.color(color.aqua, "Asia Color", group=grp10)
colNeutral     = input.color(color.gray, "Neutral Color", group=grp10)

//======================================================
// HELPERS
//======================================================
f_clamp(_x, _min, _max) =>
    math.max(_min, math.min(_x, _max))

f_score(_x) =>
    int(f_clamp(math.round(_x), 0, 100))

f_grade(_score, _rr) =>
    string _g = "No Trade"
    if _score >= 85 and _rr >= minRR_A
        _g := "A+"
    else if _score >= 75 and _rr >= minRR_A
        _g := "A"
    else if _score >= 65 and _rr >= minRR_B
        _g := "B"
    else if _score >= 55
        _g := "C"
    _g

f_level(_v) =>
    string _t = "Low"
    if _v >= 80
        _t := "Very High"
    else if _v >= 60
        _t := "High"
    else if _v >= 40
        _t := "Medium"
    _t

f_rr(_entry, _stop, _target) =>
    float _risk = math.abs(_entry - _stop)
    float _reward = math.abs(_target - _entry)
    _risk > 0 ? _reward / _risk : 0.0

//======================================================
// DAILY LEVELS
//======================================================
prevHigh  = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
prevLow   = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)
prevMid   = (prevHigh + prevLow) / 2.0
todayOpen = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_on)

plot(showPDLevels ? prevHigh : na, "PDH", color=colBear, linewidth=2)
plot(showPDLevels ? prevLow : na, "PDL", color=colBull, linewidth=2)
plot(showPDLevels ? prevMid : na, "PDM", color=colMid, linewidth=2)

//======================================================
// ASIA RANGE
//======================================================
inAsia = not na(time(timeframe.period, asiaSession, sessionTZ))
newDay = ta.change(time("D")) != 0

var float asiaHigh = na
var float asiaLow = na
var float lockedAsiaHigh = na
var float lockedAsiaLow = na

if newDay
    asiaHigh := na
    asiaLow := na
    lockedAsiaHigh := na
    lockedAsiaLow := na

if inAsia
    asiaHigh := na(asiaHigh) ? high : math.max(asiaHigh, high)
    asiaLow := na(asiaLow) ? low : math.min(asiaLow, low)

if not inAsia and inAsia[1]
    lockedAsiaHigh := asiaHigh
    lockedAsiaLow := asiaLow

plot(showAsiaRange ? lockedAsiaHigh : na, "Asia High", color=colAsia, linewidth=1, style=plot.style_linebr)
plot(showAsiaRange ? lockedAsiaLow : na, "Asia Low", color=colAsia, linewidth=1, style=plot.style_linebr)

//======================================================
// KILL ZONES
//======================================================
barHour  = hour(time, "UTC")
inLondon = barHour >= kzLondonH and barHour < kzLondonH + kzDuration
inNY     = barHour >= kzNYH and barHour < kzNYH + kzDuration
inAsianK = barHour >= kzAsianH and barHour < kzAsianH + kzDuration
inKZ     = inLondon or inNY or inAsianK

string kzName = "OFF"
if inLondon
    kzName := "LONDON"
else if inNY
    kzName := "NEW YORK"
else if inAsianK
    kzName := "ASIAN"

bgcolor(inLondon ? color.new(color.blue, 93) : na)
bgcolor(inNY ? color.new(color.green, 93) : na)
bgcolor(inAsianK ? color.new(color.purple, 93) : na)

//======================================================
// HTF BIAS
//======================================================
htfClose = request.security(syminfo.tickerid, htfTF, close, lookahead=barmerge.lookahead_on)
htfHigh  = request.security(syminfo.tickerid, htfTF, high, lookahead=barmerge.lookahead_on)
htfLow   = request.security(syminfo.tickerid, htfTF, low, lookahead=barmerge.lookahead_on)
htfMid   = (htfHigh + htfLow) / 2.0
htfEma20 = request.security(syminfo.tickerid, htfTF, ta.ema(close, 20), lookahead=barmerge.lookahead_on)

htfBull = htfClose > htfMid and htfClose > htfEma20
htfBear = htfClose < htfMid and htfClose < htfEma20
htfBias = htfBull ? 1 : htfBear ? -1 : 0

string htfStr = "Neutral"
if htfBull
    htfStr := "Bullish"
else if htfBear
    htfStr := "Bearish"

//======================================================
// PRICE / VOLUME METRICS
//======================================================
atr = ta.atr(14)
barRange = high - low
body = math.abs(close - open)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

bodyPct      = barRange > 0 ? body / barRange : 0.0
upperWickPct = barRange > 0 ? upperWick / barRange : 0.0
lowerWickPct = barRange > 0 ? lowerWick / barRange : 0.0
bullCloseStr = barRange > 0 ? (close - low) / barRange : 0.5
bearCloseStr = barRange > 0 ? (high - close) / barRange : 0.5

avgRange = ta.sma(barRange, 10)
avgBody  = ta.sma(body, 10)
avgVol   = ta.sma(volume, 20)

volRatio      = avgVol > 0 ? volume / avgVol : 1.0
isVolStrong   = volRatio >= volStrongMult
isVolVeryHigh = volRatio >= volVeryStrong
isVolDead     = volRatio < volDeadMult

string volState = "Average"
if isVolVeryHigh
    volState := "Very Strong"
else if isVolStrong
    volState := "Strong"
else if isVolDead
    volState := "Dead"

//======================================================
// DISPLACEMENT / ABSORPTION / COMPRESSION
//======================================================
bullDisp = close > open and barRange > atr * dispATRMult and bodyPct > 0.60 and bullCloseStr > 0.75 and not isVolDead
bearDisp = close < open and barRange > atr * dispATRMult and bodyPct > 0.60 and bearCloseStr > 0.75 and not isVolDead

highEffortSmallResult = volume > avgVol * volStrongMult and barRange < avgRange * 0.75
bullAbsorb = lowerWickPct > wickThresh and bodyPct < 0.45 and highEffortSmallResult and close > low + barRange * 0.35
bearAbsorb = upperWickPct > wickThresh and bodyPct < 0.45 and highEffortSmallResult and close < high - barRange * 0.35

compressRange = ta.highest(high, compressLen) - ta.lowest(low, compressLen)
compression = compressRange < ta.sma(barRange, compressLen) * compressLen * 0.75

//======================================================
// LIQUIDITY CLUSTERS
//======================================================
liqTol = atr * eqTolATR

f_clusterHigh(_len, _tol) =>
    float _cluster = na
    int _hits = 0
    float _top = ta.highest(high, _len)
    for i = 1 to _len
        if math.abs(high[i] - _top) <= _tol
            _cluster := na(_cluster) ? high[i] : math.max(_cluster, high[i])
            _hits += 1
    [_cluster, _hits]

f_clusterLow(_len, _tol) =>
    float _cluster = na
    int _hits = 0
    float _bot = ta.lowest(low, _len)
    for i = 1 to _len
        if math.abs(low[i] - _bot) <= _tol
            _cluster := na(_cluster) ? low[i] : math.min(_cluster, low[i])
            _hits += 1
    [_cluster, _hits]

[liqHigh, liqHighHits] = f_clusterHigh(clusterBars, liqTol)
[liqLow, liqLowHits]   = f_clusterLow(clusterBars, liqTol)

hasLiqAbove = liqHighHits >= 2 or high[1] >= prevHigh - liqTol or (not na(lockedAsiaHigh) and high[1] >= lockedAsiaHigh - liqTol)
hasLiqBelow = liqLowHits >= 2 or low[1] <= prevLow + liqTol or (not na(lockedAsiaLow) and low[1] <= lockedAsiaLow + liqTol)

plot(showLiqMarks and hasLiqAbove ? liqHigh : na, "Cluster High", color=color.new(colBear, 35), linewidth=1, style=plot.style_linebr)
plot(showLiqMarks and hasLiqBelow ? liqLow : na, "Cluster Low", color=color.new(colBull, 35), linewidth=1, style=plot.style_linebr)

//======================================================
// SWEEP DETECTION
//======================================================
sweepBuf = atr * sweepATRMult

sweepPDH   = high > prevHigh + sweepBuf and close < prevHigh
sweepPDL   = low < prevLow - sweepBuf and close > prevLow
sweepAsiaH = not na(lockedAsiaHigh) and high > lockedAsiaHigh + sweepBuf and close < lockedAsiaHigh
sweepAsiaL = not na(lockedAsiaLow) and low < lockedAsiaLow - sweepBuf and close > lockedAsiaLow
sweepLiqH  = hasLiqAbove and not na(liqHigh) and high > liqHigh + sweepBuf and close < liqHigh
sweepLiqL  = hasLiqBelow and not na(liqLow) and low < liqLow - sweepBuf and close > liqLow

bearTrap = sweepPDH or sweepAsiaH or sweepLiqH
bullTrap = sweepPDL or sweepAsiaL or sweepLiqL
sweepAny = bullTrap or bearTrap

if showSweepLbls and sweepPDH
    label.new(bar_index, high, "PDH Sweep", style=label.style_label_down, color=color.new(colBear, 0), textcolor=color.white, size=size.small)
if showSweepLbls and sweepPDL
    label.new(bar_index, low, "PDL Sweep", style=label.style_label_up, color=color.new(colBull, 0), textcolor=color.white, size=size.small)
if showSweepLbls and sweepAsiaH
    label.new(bar_index, high, "Asia H Sweep", style=label.style_label_down, color=color.new(colBear, 20), textcolor=color.white, size=size.small)
if showSweepLbls and sweepAsiaL
    label.new(bar_index, low, "Asia L Sweep", style=label.style_label_up, color=color.new(colBull, 20), textcolor=color.white, size=size.small)
if showSweepLbls and sweepLiqH
    label.new(bar_index, high, "Cluster H Sweep", style=label.style_label_down, color=color.new(colBear, 40), textcolor=color.white, size=size.small)
if showSweepLbls and sweepLiqL
    label.new(bar_index, low, "Cluster L Sweep", style=label.style_label_up, color=color.new(colBull, 40), textcolor=color.white, size=size.small)

//======================================================
// EXHAUSTION
//======================================================
upRun = ta.rising(close, 3)
downRun = ta.falling(close, 3)

volDivBull = upRun and volRatio < volRatio[1] and volRatio[1] < volRatio[2]
volDivBear = downRun and volRatio < volRatio[1] and volRatio[1] < volRatio[2]

bullExhaustRaw = 0.0
bullExhaustRaw += upRun ? 25 : 0
bullExhaustRaw += upperWickPct > wickThresh ? 25 : 0
bullExhaustRaw += close < high - barRange * 0.5 ? 15 : 0
bullExhaustRaw += volDivBull ? 20 : 0
bullExhaustRaw += close > prevHigh ? 15 : 0

bearExhaustRaw = 0.0
bearExhaustRaw += downRun ? 25 : 0
bearExhaustRaw += lowerWickPct > wickThresh ? 25 : 0
bearExhaustRaw += close > low + barRange * 0.5 ? 15 : 0
bearExhaustRaw += volDivBear ? 20 : 0
bearExhaustRaw += close < prevLow ? 15 : 0

bullExhaust = f_score(ta.sma(bullExhaustRaw, 3))
bearExhaust = f_score(ta.sma(bearExhaustRaw, 3))
exhaustion  = math.max(bullExhaust, bearExhaust)

//======================================================
// MARKET STRUCTURE SHIFT
//======================================================
swingHigh = ta.pivothigh(high, swingLen, swingLen)
swingLow  = ta.pivotlow(low, swingLen, swingLen)

var float lastSwingHigh = na
var float lastSwingLow = na
var string marketStructure = "Neutral"

if not na(swingHigh)
    lastSwingHigh := swingHigh
if not na(swingLow)
    lastSwingLow := swingLow

bullMSS = not na(lastSwingHigh) and close > lastSwingHigh + atr * mssBreakATR and bullDisp
bearMSS = not na(lastSwingLow) and close < lastSwingLow - atr * mssBreakATR and bearDisp

if bullMSS
    marketStructure := "Bullish Shift"
else if bearMSS
    marketStructure := "Bearish Shift"

plotshape(bullMSS, title="Bull MSS", style=shape.triangleup, location=location.belowbar, color=color.new(colBull, 0), size=size.tiny)
plotshape(bearMSS, title="Bear MSS", style=shape.triangledown, location=location.abovebar, color=color.new(colBear, 0), size=size.tiny)

//======================================================
// PREMIUM / DISCOUNT
//======================================================
inPremium  = close > prevMid
inDiscount = close < prevMid

//======================================================
// ADR
//======================================================
dailyRange = request.security(syminfo.tickerid, "D", high - low, lookahead=barmerge.lookahead_on)
ADR = ta.sma(dailyRange, adrLength)
adrHigh = todayOpen + ADR
adrLow  = todayOpen - ADR

plot(adrHigh, "ADR High", color=color.new(color.blue, 55), linewidth=1, style=plot.style_linebr)
plot(adrLow, "ADR Low", color=color.new(color.blue, 55), linewidth=1, style=plot.style_linebr)

nearADRHigh = close >= adrHigh - atr * 0.25
nearADRLow  = close <= adrLow + atr * 0.25

string adrPos = "Inside ADR"
if nearADRHigh
    adrPos := "Near ADR High"
else if nearADRLow
    adrPos := "Near ADR Low"

//======================================================
// DAY TYPE / REGIME
//======================================================
rangeToday = high - low
rangeAvg20 = ta.sma(rangeToday, 20)

trendUpDay   = close > prevHigh and close > prevMid
trendDownDay = close < prevLow and close < prevMid
rangeDay     = rangeToday < rangeAvg20 * 0.8
expansionDay = rangeToday > rangeAvg20 * 1.3
reversalDay  = (bullTrap and bullMSS) or (bearTrap and bearMSS)

string dayType = "Normal Day"
if trendUpDay
    dayType := "Trend Up Day"
else if trendDownDay
    dayType := "Trend Down Day"
else if reversalDay
    dayType := "Reversal Day"
else if expansionDay
    dayType := "Expansion Day"
else if rangeDay
    dayType := "Range Day"

midChop = math.abs(close - prevMid) < atr * 0.35
regimeGood = inKZ and not isVolDead and not midChop and not (useADRFilter and ((nearADRHigh and htfBull) or (nearADRLow and htfBear)))
regimeBad  = isVolDead or (useADRFilter and ((nearADRHigh and htfBull and not bearTrap) or (nearADRLow and htfBear and not bullTrap)))
regimeScore = regimeGood ? 80 : regimeBad ? 25 : 55

//======================================================
// STATE MACHINE
//======================================================
var int state = 0
var int sweepBar = na
var float invalidation = na
var float target1 = na
var float target2 = na
var float target3 = na
var int setupScore = 0
var string setupGrade = "No Trade"
var string activeFamily = "None"

if newDay
    state := 0
    sweepBar := na
    invalidation := na
    target1 := na
    target2 := na
    target3 := na
    setupScore := 0
    setupGrade := "No Trade"
    activeFamily := "None"

if state == 0 and bullTrap
    state := 1
    sweepBar := bar_index
    invalidation := low

if state == 0 and bearTrap
    state := 2
    sweepBar := bar_index
    invalidation := high

bullReclaim = state == 1 and bar_index - sweepBar <= confirmBars and close > prevLow and close > open
bearReclaim = state == 2 and bar_index - sweepBar <= confirmBars and close < prevHigh and close < open

if bullReclaim
    state := 3
if bearReclaim
    state := 4

bullConfirm = state == 3 and bullDisp and (bullMSS or close > prevMid) and not isVolDead
bearConfirm = state == 4 and bearDisp and (bearMSS or close < prevMid) and not isVolDead

if bullConfirm
    state := 5
if bearConfirm
    state := 6

if (state == 1 or state == 2 or state == 3 or state == 4) and bar_index - sweepBar > confirmBars
    state := 0
    sweepBar := na
    invalidation := na
    target1 := na
    target2 := na
    target3 := na
    setupScore := 0
    setupGrade := "No Trade"
    activeFamily := "None"

//======================================================
// SETUP FAMILIES
//======================================================
// Reversal models
bullReversalScore = 0
bullReversalScore += bullTrap ? 25 : 0
bullReversalScore += bullReclaim ? 15 : 0
bullReversalScore += bullDisp ? 20 : 0
bullReversalScore += bullMSS ? 12 : 0
bullReversalScore += bearExhaust > 55 ? 8 : 0
bullReversalScore += inDiscount ? 7 : 0
bullReversalScore += regimeGood ? 8 : 0
bullReversalScore += hasLiqAbove ? 5 : 0

bearReversalScore = 0
bearReversalScore += bearTrap ? 25 : 0
bearReversalScore += bearReclaim ? 15 : 0
bearReversalScore += bearDisp ? 20 : 0
bearReversalScore += bearMSS ? 12 : 0
bearReversalScore += bullExhaust > 55 ? 8 : 0
bearReversalScore += inPremium ? 7 : 0
bearReversalScore += regimeGood ? 8 : 0
bearReversalScore += hasLiqBelow ? 5 : 0

// Continuation models
bullContinuationScore = 0
bullContinuationScore += htfBull ? 20 : 0
bullContinuationScore += close > prevMid ? 10 : 0
bullContinuationScore += bullDisp ? 20 : 0
bullContinuationScore += isVolStrong ? 10 : 0
bullContinuationScore += not bearTrap ? 10 : 0
bullContinuationScore += trendUpDay ? 10 : 0
bullContinuationScore += not nearADRHigh ? 10 : 0
bullContinuationScore += compression ? 5 : 0

bearContinuationScore = 0
bearContinuationScore += htfBear ? 20 : 0
bearContinuationScore += close < prevMid ? 10 : 0
bearContinuationScore += bearDisp ? 20 : 0
bearContinuationScore += isVolStrong ? 10 : 0
bearContinuationScore += not bullTrap ? 10 : 0
bearContinuationScore += trendDownDay ? 10 : 0
bearContinuationScore += not nearADRLow ? 10 : 0
bearContinuationScore += compression ? 5 : 0

//======================================================
// TARGET ENGINE
//======================================================
bullTargetPrimary = not na(liqHigh) ? liqHigh : prevHigh
bearTargetPrimary = not na(liqLow) ? liqLow : prevLow

bullTarget1 = prevMid
bullTarget2 = not na(lockedAsiaHigh) ? lockedAsiaHigh : prevHigh
bullTarget3 = math.min(bullTargetPrimary, adrHigh)

bearTarget1 = prevMid
bearTarget2 = not na(lockedAsiaLow) ? lockedAsiaLow : prevLow
bearTarget3 = math.max(bearTargetPrimary, adrLow)

// RR-aware selection
bullRR1 = f_rr(close, invalidation, bullTarget1)
bullRR2 = f_rr(close, invalidation, bullTarget2)
bullRR3 = f_rr(close, invalidation, bullTarget3)

bearRR1 = f_rr(close, invalidation, bearTarget1)
bearRR2 = f_rr(close, invalidation, bearTarget2)
bearRR3 = f_rr(close, invalidation, bearTarget3)

bullRRBest = math.max(math.max(bullRR1, bullRR2), bullRR3)
bearRRBest = math.max(math.max(bearRR1, bearRR2), bearRR3)

bullRRScore = bullRRBest >= 3 ? 20 : bullRRBest >= 2 ? 15 : bullRRBest >= 1.5 ? 10 : 0
bearRRScore = bearRRBest >= 3 ? 20 : bearRRBest >= 2 ? 15 : bearRRBest >= 1.5 ? 10 : 0

//======================================================
// FINAL SCORE / GRADE
//======================================================
bullBase = math.max(bullReversalScore, bullContinuationScore)
bearBase = math.max(bearReversalScore, bearContinuationScore)

bullFamily = bullReversalScore > bullContinuationScore ? "REVERSAL LONG" : "CONTINUATION LONG"
bearFamily = bearReversalScore > bearContinuationScore ? "REVERSAL SHORT" : "CONTINUATION SHORT"

bullFinalRaw = bullBase + bullRRScore + int(regimeScore * 0.10)
bearFinalRaw = bearBase + bearRRScore + int(regimeScore * 0.10)

// hard cap weak regime
bullFinal = regimeBad ? math.min(bullFinalRaw, 54) : bullFinalRaw
bearFinal = regimeBad ? math.min(bearFinalRaw, 54) : bearFinalRaw

bullGrade = f_grade(bullFinal, bullRRBest)
bearGrade = f_grade(bearFinal, bearRRBest)

bullEntryRaw = state == 5 and bullFinal >= 65
bearEntryRaw = state == 6 and bearFinal >= 65

bullEntry = bullEntryRaw and (not onlyASetups or (bullGrade == "A+" or bullGrade == "A"))
bearEntry = bearEntryRaw and (not onlyASetups or (bearGrade == "A+" or bearGrade == "A"))

if bullEntry
    activeFamily := bullFamily
    setupScore := bullFinal
    setupGrade := bullGrade
    target1 := bullTarget1
    target2 := bullTarget2
    target3 := bullTarget3

if bearEntry
    activeFamily := bearFamily
    setupScore := bearFinal
    setupGrade := bearGrade
    target1 := bearTarget1
    target2 := bearTarget2
    target3 := bearTarget3

//======================================================
// PLOTS
//======================================================
plot(showTargets and bullEntry ? target1 : na, "Bull T1", color=color.new(colMid, 0), linewidth=1, style=plot.style_circles)
plot(showTargets and bullEntry ? target2 : na, "Bull T2", color=color.new(colAsia, 0), linewidth=1, style=plot.style_circles)
plot(showTargets and bullEntry ? target3 : na, "Bull T3", color=color.new(colBull, 0), linewidth=2, style=plot.style_circles)

plot(showTargets and bearEntry ? target1 : na, "Bear T1", color=color.new(colMid, 0), linewidth=1, style=plot.style_circles)
plot(showTargets and bearEntry ? target2 : na, "Bear T2", color=color.new(colAsia, 0), linewidth=1, style=plot.style_circles)
plot(showTargets and bearEntry ? target3 : na, "Bear T3", color=color.new(colBear, 0), linewidth=2, style=plot.style_circles)

plot(showInvalid and bullEntry ? invalidation : na, "Bull Invalid", color=color.new(colBear, 20), linewidth=2, style=plot.style_linebr)
plot(showInvalid and bearEntry ? invalidation : na, "Bear Invalid", color=color.new(colBull, 20), linewidth=2, style=plot.style_linebr)

//======================================================
// LABELS
//======================================================
if showEntries and bullEntry and state[1] != 5
    label.new(bar_index, low, activeFamily + " " + bullGrade + "\nRR " + str.tostring(math.round(bullRRBest * 100.0) / 100.0), style=label.style_label_up, color=color.new(colBull, 0), textcolor=color.white, size=size.small)

if showEntries and bearEntry and state[1] != 6
    label.new(bar_index, high, activeFamily + " " + bearGrade + "\nRR " + str.tostring(math.round(bearRRBest * 100.0) / 100.0), style=label.style_label_down, color=color.new(colBear, 0), textcolor=color.white, size=size.small)

//======================================================
// BIAS / ADVICE
//======================================================
bullScore = bullFinal
bearScore = bearFinal

string bias = "Neutral"
if bullEntry
    bias := "Bullish Execution"
else if bearEntry
    bias := "Bearish Execution"
else if bullScore > bearScore + 8
    bias := "Bullish Context"
else if bearScore > bullScore + 8
    bias := "Bearish Context"

string crowdState = "Balanced"
if bullEntry
    crowdState := "Crowd trapped short / long valid"
else if bearEntry
    crowdState := "Crowd trapped long / short valid"
else if bullTrap and inKZ and isVolStrong
    crowdState := "High-prob sweep low"
else if bearTrap and inKZ and isVolStrong
    crowdState := "High-prob sweep high"
else if isVolDead
    crowdState := "Dead participation"
else if bullAbsorb
    crowdState := "Buy absorption"
else if bearAbsorb
    crowdState := "Sell absorption"
else if bullDisp and isVolStrong
    crowdState := "Aggressive buyers"
else if bearDisp and isVolStrong
    crowdState := "Aggressive sellers"
else if exhaustion > 70
    crowdState := "Move exhausted"

string advice = "Wait for reclaim + displacement"
if bullEntry
    advice := "Long valid. Protect below sweep. Scale at T1/T2/T3"
else if bearEntry
    advice := "Short valid. Protect above sweep. Scale at T1/T2/T3"
else if bullTrap and not inKZ
    advice := "Sweep low outside kill zone. Lower quality"
else if bearTrap and not inKZ
    advice := "Sweep high outside kill zone. Lower quality"
else if bullAbsorb and bullMSS
    advice := "Absorption + shift. Watch long continuation"
else if bearAbsorb and bearMSS
    advice := "Absorption + shift. Watch short continuation"
else if nearADRHigh and bullScore > bearScore
    advice := "Bullish but near ADR high. Do not chase"
else if nearADRLow and bearScore > bullScore
    advice := "Bearish but near ADR low. Do not chase"
else if exhaustion > 70
    advice := "Move likely tired. Wait for retrace"
else if isVolDead
    advice := "Dead market. Stay flat"
else if regimeBad
    advice := "Bad regime. Downgrade all setups"
else if bias == "Neutral"
    advice := "No clean edge. Stay patient"

//======================================================
// BAR COLORING
//======================================================
color barCol = na
if showBarColor
    if bullEntry
        barCol := color.new(colBull, 0)
    else if bearEntry
        barCol := color.new(colBear, 0)
    else if bias == "Bullish Context"
        barCol := color.new(colBull, 35)
    else if bias == "Bearish Context"
        barCol := color.new(colBear, 35)
    else
        barCol := color.new(colNeutral, 55)
barcolor(barCol)

//======================================================
// ALERTS
//======================================================
alertcondition(bullEntry, title="Bull Entry Valid", message="Liquidity Execution Radar: Bull setup valid")
alertcondition(bearEntry, title="Bear Entry Valid", message="Liquidity Execution Radar: Bear setup valid")
alertcondition(bullMSS, title="Bullish MSS", message="Liquidity Execution Radar: Bullish MSS")
alertcondition(bearMSS, title="Bearish MSS", message="Liquidity Execution Radar: Bearish MSS")
alertcondition(sweepAny, title="Liquidity Sweep", message="Liquidity Execution Radar: Sweep detected")
alertcondition(exhaustion > 70, title="High Exhaustion", message="Liquidity Execution Radar: Exhaustion high")
alertcondition(bullAbsorb or bearAbsorb, title="Absorption Detected", message="Liquidity Execution Radar: Absorption detected")

//======================================================
// DASHBOARD
//======================================================
var table mentor = table.new(position.middle_left, 2, 18, border_width=1)

if barstate.islast and showDash
    table.cell(mentor, 0, 0, "EXECUTION RADAR", text_color=color.white, bgcolor=color.new(color.blue, 40))
    table.cell(mentor, 1, 0, "v2.1", text_color=color.white, bgcolor=color.new(color.blue, 40))

    table.cell(mentor, 0, 1, "Session / KZ", text_color=color.white, bgcolor=color.new(color.gray, 65))
    table.cell(mentor, 1, 1, kzName + (inKZ ? " ACTIVE" : ""), text_color=color.white, bgcolor=color.new(color.gray, 65))

    table.cell(mentor, 0, 2, "HTF Bias", text_color=color.white, bgcolor=htfBias == 1 ? color.new(colBull, 60) : htfBias == -1 ? color.new(colBear, 60) : color.new(color.gray, 60))
    table.cell(mentor, 1, 2, htfStr, text_color=color.white, bgcolor=htfBias == 1 ? color.new(colBull, 60) : htfBias == -1 ? color.new(colBear, 60) : color.new(color.gray, 60))

    table.cell(mentor, 0, 3, "Regime", text_color=color.white, bgcolor=regimeGood ? color.new(colBull, 65) : regimeBad ? color.new(colBear, 65) : color.new(color.orange, 65))
    table.cell(mentor, 1, 3, regimeGood ? "GOOD" : regimeBad ? "BAD" : "MIXED", text_color=color.white, bgcolor=regimeGood ? color.new(colBull, 65) : regimeBad ? color.new(colBear, 65) : color.new(color.orange, 65))

    table.cell(mentor, 0, 4, "Day Type", text_color=color.white, bgcolor=color.new(color.teal, 65))
    table.cell(mentor, 1, 4, dayType, text_color=color.white, bgcolor=color.new(color.teal, 65))

    table.cell(mentor, 0, 5, "Volume", text_color=color.white, bgcolor=isVolVeryHigh ? color.new(colBull, 45) : isVolStrong ? color.new(colBull, 70) : isVolDead ? color.new(colBear, 60) : color.new(color.gray, 60))
    table.cell(mentor, 1, 5, volState + " (" + str.tostring(math.round(volRatio * 100.0) / 100.0) + "x)", text_color=color.white, bgcolor=isVolVeryHigh ? color.new(colBull, 45) : isVolStrong ? color.new(colBull, 70) : isVolDead ? color.new(colBear, 60) : color.new(color.gray, 60))

    table.cell(mentor, 0, 6, "Bull Setup", text_color=color.white, bgcolor=color.new(colBull, 75))
    table.cell(mentor, 1, 6, bullGrade + " (" + str.tostring(bullFinal) + ")", text_color=color.white, bgcolor=color.new(colBull, 75))

    table.cell(mentor, 0, 7, "Bear Setup", text_color=color.white, bgcolor=color.new(colBear, 75))
    table.cell(mentor, 1, 7, bearGrade + " (" + str.tostring(bearFinal) + ")", text_color=color.white, bgcolor=color.new(colBear, 75))

    table.cell(mentor, 0, 8, "Bull RR", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(mentor, 1, 8, str.tostring(math.round(bullRRBest * 100.0) / 100.0), text_color=color.white, bgcolor=color.new(color.black, 0))

    table.cell(mentor, 0, 9, "Bear RR", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(mentor, 1, 9, str.tostring(math.round(bearRRBest * 100.0) / 100.0), text_color=color.white, bgcolor=color.new(color.black, 0))

    table.cell(mentor, 0, 10, "Structure", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(mentor, 1, 10, marketStructure, text_color=marketStructure == "Bullish Shift" ? colBull : marketStructure == "Bearish Shift" ? colBear : color.white, bgcolor=color.new(color.black, 0))

    table.cell(mentor, 0, 11, "Value Zone", text_color=color.white, bgcolor=color.new(color.gray, 70))
    table.cell(mentor, 1, 11, inDiscount ? "Discount" : inPremium ? "Premium" : "Mid", text_color=inDiscount ? colBull : inPremium ? colBear : color.white, bgcolor=color.new(color.gray, 70))

    table.cell(mentor, 0, 12, "ADR Position", text_color=color.white, bgcolor=color.new(color.blue, 70))
    table.cell(mentor, 1, 12, adrPos, text_color=color.white, bgcolor=color.new(color.blue, 70))

    table.cell(mentor, 0, 13, "Crowd State", text_color=color.white, bgcolor=color.new(color.orange, 75))
    table.cell(mentor, 1, 13, crowdState, text_color=color.white, bgcolor=color.new(color.orange, 75))

    string stateText = "Idle"
    if state == 1
        stateText := "Bull Sweep"
    else if state == 2
        stateText := "Bear Sweep"
    else if state == 3
        stateText := "Bull Reclaim"
    else if state == 4
        stateText := "Bear Reclaim"
    else if state == 5
        stateText := "Bull Entry"
    else if state == 6
        stateText := "Bear Entry"

    table.cell(mentor, 0, 14, "State", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(mentor, 1, 14, stateText, text_color=color.white, bgcolor=color.new(color.black, 0))

    table.cell(mentor, 0, 15, "Bias", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(mentor, 1, 15, bias, text_color=bias == "Bullish Execution" or bias == "Bullish Context" ? colBull : bias == "Bearish Execution" or bias == "Bearish Context" ? colBear : color.white, bgcolor=color.new(color.black, 0))

    table.cell(mentor, 0, 16, "Setup Type", text_color=color.white, bgcolor=color.new(color.gray, 70))
    table.cell(mentor, 1, 16, activeFamily, text_color=color.yellow, bgcolor=color.new(color.gray, 70))

    string finalText = advice
    table.cell(mentor, 0, 17, "Mentor Advice", text_color=color.white, bgcolor=color.new(color.blue, 70))
    table.cell(mentor, 1, 17, finalText, text_color=color.yellow, bgcolor=color.new(color.blue, 70))
````
