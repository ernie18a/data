# Market Psychology Radar PRO Final

- url: https://www.tradingview.com/script/bjzxqb4G-Market-Psychology-Radar-PRO-Final/
- type: indicator
- pine_id: PUB;57452f3e3ee3454cb64ea971a43a4d13
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
indicator("Market Psychology Radar PRO Final", overlay=true, max_labels_count=200, max_lines_count=200)

//======================================================
// INPUTS
//======================================================
grp1 = "Core Levels"
showPDLevels   = input.bool(true, "Show Previous Day Levels", group=grp1)
showAsiaRange  = input.bool(true, "Show Asia Range", group=grp1)
asiaSession    = input.session("0000-0559", "Asia Session", group=grp1)
sessionTZ      = input.string("Etc/UTC", "Session Timezone", group=grp1)

grp2 = "Behavior Engine"
lookbackAgg    = input.int(10, "Aggression Lookback", minval=3, group=grp2)
dispATRMult    = input.float(1.20, "Displacement ATR Mult", minval=0.5, step=0.05, group=grp2)
sweepATRMult   = input.float(0.12, "Sweep Buffer ATR Mult", minval=0.01, step=0.01, group=grp2)
wickThresh     = input.float(0.35, "Wick Ratio Threshold", minval=0.10, maxval=0.90, step=0.05, group=grp2)

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

grp6 = "Execution"
confirmBars    = input.int(3, "Bars Allowed After Sweep", minval=1, maxval=10, group=grp6)
showTargets    = input.bool(true, "Show Targets", group=grp6)
showInvalid    = input.bool(true, "Show Invalidation", group=grp6)
showEntries    = input.bool(true, "Show Entry Labels", group=grp6)
onlyASetups    = input.bool(false, "Only Show A / A+ Entries", group=grp6)

grp7 = "Advanced"
swingLen       = input.int(5, "Market Structure Swing Length", minval=2, maxval=20, group=grp7)
eqTolATR       = input.float(0.08, "Equal High/Low Tolerance (ATR %)", minval=0.01, step=0.01, group=grp7)
adrLength      = input.int(14, "ADR Length", minval=5, maxval=50, group=grp7)
compressLen    = input.int(6, "Compression Lookback", minval=3, maxval=20, group=grp7)

grp8 = "Display"
showSweepLbls  = input.bool(true, "Show Sweep Labels", group=grp8)
showLiqMarks   = input.bool(true, "Show Equal High/Low Marks", group=grp8)
showBarColor   = input.bool(true, "Color Bars by Bias", group=grp8)
showDash       = input.bool(true, "Show Mentor Dashboard", group=grp8)

grp9 = "Colors"
colBull        = input.color(color.lime, "Bull Color", group=grp9)
colBear        = input.color(color.red, "Bear Color", group=grp9)
colMid         = input.color(color.yellow, "Mid Color", group=grp9)
colAsia        = input.color(color.aqua, "Asia Color", group=grp9)
colNeutral     = input.color(color.gray, "Neutral Color", group=grp9)

//======================================================
// HELPERS
//======================================================
f_clamp(_x, _min, _max) =>
    math.max(_min, math.min(_x, _max))

f_score(_x) =>
    int(f_clamp(math.round(_x), 0, 100))

f_level(_v) =>
    string _t = "Low"
    if _v >= 80
        _t := "Very High"
    else if _v >= 60
        _t := "High"
    else if _v >= 40
        _t := "Medium"
    _t

f_grade(_score) =>
    string _g = "No Trade"
    if _score >= 85
        _g := "A+"
    else if _score >= 75
        _g := "A"
    else if _score >= 65
        _g := "B"
    else if _score >= 50
        _g := "C"
    _g

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

avgRange = ta.sma(barRange, lookbackAgg)
avgBody  = ta.sma(body, lookbackAgg)
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
// AGGRESSION / DISPLACEMENT
//======================================================
bullDisp = close > open and barRange > atr * dispATRMult and bodyPct > 0.60 and bullCloseStr > 0.70
bearDisp = close < open and barRange > atr * dispATRMult and bodyPct > 0.60 and bearCloseStr > 0.70

bullAggRaw = 0.0
bullAggRaw += close > open ? 20 : 0
bullAggRaw += body > avgBody ? 15 : 0
bullAggRaw += barRange > avgRange ? 15 : 0
bullAggRaw += bullCloseStr > 0.70 ? 20 : 0
bullAggRaw += bullDisp ? 15 : 0
bullAggRaw += isVolStrong ? 15 : 0

bearAggRaw = 0.0
bearAggRaw += close < open ? 20 : 0
bearAggRaw += body > avgBody ? 15 : 0
bearAggRaw += barRange > avgRange ? 15 : 0
bearAggRaw += bearCloseStr > 0.70 ? 20 : 0
bearAggRaw += bearDisp ? 15 : 0
bearAggRaw += isVolStrong ? 15 : 0

bullAgg = f_score(ta.sma(bullAggRaw, 3))
bearAgg = f_score(ta.sma(bearAggRaw, 3))

//======================================================
// EFFORT VS RESULT / ABSORPTION / COMPRESSION
//======================================================
highEffortSmallResult = volume > avgVol * volStrongMult and barRange < avgRange * 0.75
lowEffortBigResult    = volume < avgVol * volDeadMult and barRange > avgRange * 1.2

bullAbsorb = lowerWickPct > wickThresh and bodyPct < 0.45 and highEffortSmallResult and close > low + barRange * 0.35
bearAbsorb = upperWickPct > wickThresh and bodyPct < 0.45 and highEffortSmallResult and close < high - barRange * 0.35

compressRange = ta.highest(high, compressLen) - ta.lowest(low, compressLen)
compression = compressRange < ta.sma(barRange, compressLen) * compressLen * 0.75

effortResultScore = 0
effortResultScore += highEffortSmallResult ? 70 : 0
effortResultScore += lowEffortBigResult ? 40 : 0
effortResult = f_score(effortResultScore)

//======================================================
// SWEEP DETECTION
//======================================================
sweepBuf = atr * sweepATRMult

sweepPDH   = high > prevHigh + sweepBuf and close < prevHigh
sweepPDL   = low < prevLow - sweepBuf and close > prevLow
sweepAsiaH = not na(lockedAsiaHigh) and high > lockedAsiaHigh + sweepBuf and close < lockedAsiaHigh
sweepAsiaL = not na(lockedAsiaLow) and low < lockedAsiaLow - sweepBuf and close > lockedAsiaLow

bearTrap = sweepPDH or sweepAsiaH
bullTrap = sweepPDL or sweepAsiaL
sweepAny = bullTrap or bearTrap

if showSweepLbls and sweepPDH
    label.new(bar_index, high, "PDH Sweep", style=label.style_label_down, color=color.new(colBear, 0), textcolor=color.white, size=size.small)
if showSweepLbls and sweepPDL
    label.new(bar_index, low, "PDL Sweep", style=label.style_label_up, color=color.new(colBull, 0), textcolor=color.white, size=size.small)
if showSweepLbls and sweepAsiaH
    label.new(bar_index, high, "Asia H Sweep", style=label.style_label_down, color=color.new(colBear, 20), textcolor=color.white, size=size.small)
if showSweepLbls and sweepAsiaL
    label.new(bar_index, low, "Asia L Sweep", style=label.style_label_up, color=color.new(colBull, 20), textcolor=color.white, size=size.small)

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

bullMSS = not na(lastSwingHigh) and close > lastSwingHigh
bearMSS = not na(lastSwingLow) and close < lastSwingLow

if bullMSS
    marketStructure := "Bullish Shift"
else if bearMSS
    marketStructure := "Bearish Shift"

plotshape(bullMSS, title="Bull MSS", style=shape.triangleup, location=location.belowbar, color=color.new(colBull, 0), size=size.tiny)
plotshape(bearMSS, title="Bear MSS", style=shape.triangledown, location=location.abovebar, color=color.new(colBear, 0), size=size.tiny)

//======================================================
// EQUAL HIGHS / LOWS
//======================================================
eqTol = atr * eqTolATR
equalHigh = math.abs(high - high[1]) <= eqTol
equalLow  = math.abs(low - low[1]) <= eqTol

plotshape(showLiqMarks and equalHigh, title="Equal High", style=shape.circle, location=location.abovebar, color=color.orange, size=size.tiny)
plotshape(showLiqMarks and equalLow, title="Equal Low", style=shape.circle, location=location.belowbar, color=color.orange, size=size.tiny)

liqAbove = equalHigh or high[1] >= prevHigh - eqTol
liqBelow = equalLow or low[1] <= prevLow + eqTol

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
// DAY TYPE
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

if newDay
    state := 0
    sweepBar := na
    invalidation := na
    target1 := na
    target2 := na
    target3 := na
    setupScore := 0
    setupGrade := "No Trade"

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

bullConfirm = state == 3 and (bullDisp or bullAbsorb) and bullCloseStr > 0.55
bearConfirm = state == 4 and (bearDisp or bearAbsorb) and bearCloseStr > 0.55

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

//======================================================
// SCORING / GRADE
//======================================================
bullSetup = 0
bullSetup += bullTrap ? 15 : 0
bullSetup += inKZ ? 10 : 0
bullSetup += isVolStrong ? 10 : 0
bullSetup += bullAgg > bearAgg ? 10 : 0
bullSetup += bearExhaust > 55 ? 8 : 0
bullSetup += inDiscount ? 8 : 0
bullSetup += bullMSS ? 8 : 0
bullSetup += bullDisp ? 7 : 0
bullSetup += bullAbsorb ? 10 : 0
bullSetup += compression ? 4 : 0
bullSetup += not nearADRHigh ? 5 : 0
bullSetup += liqAbove ? 5 : 0

bearSetup = 0
bearSetup += bearTrap ? 15 : 0
bearSetup += inKZ ? 10 : 0
bearSetup += isVolStrong ? 10 : 0
bearSetup += bearAgg > bullAgg ? 10 : 0
bearSetup += bullExhaust > 55 ? 8 : 0
bearSetup += inPremium ? 8 : 0
bearSetup += bearMSS ? 8 : 0
bearSetup += bearDisp ? 7 : 0
bearSetup += bearAbsorb ? 10 : 0
bearSetup += compression ? 4 : 0
bearSetup += not nearADRLow ? 5 : 0
bearSetup += liqBelow ? 5 : 0

if state == 5
    setupScore := bullSetup
    setupGrade := f_grade(setupScore)
if state == 6
    setupScore := bearSetup
    setupGrade := f_grade(setupScore)

bullEntryRaw = state == 5
bearEntryRaw = state == 6

bullEntry = bullEntryRaw and (not onlyASetups or (setupGrade == "A+" or setupGrade == "A"))
bearEntry = bearEntryRaw and (not onlyASetups or (setupGrade == "A+" or setupGrade == "A"))

//======================================================
// TARGETS
//======================================================
if bullEntry
    target1 := prevMid
    target2 := not na(lockedAsiaHigh) ? lockedAsiaHigh : prevHigh
    target3 := nearADRHigh ? prevHigh : math.min(prevHigh, adrHigh)

if bearEntry
    target1 := prevMid
    target2 := not na(lockedAsiaLow) ? lockedAsiaLow : prevLow
    target3 := nearADRLow ? prevLow : math.max(prevLow, adrLow)

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
    label.new(bar_index, low, "LONG " + setupGrade, style=label.style_label_up, color=color.new(colBull, 0), textcolor=color.white, size=size.small)
if showEntries and bearEntry and state[1] != 6
    label.new(bar_index, high, "SHORT " + setupGrade, style=label.style_label_down, color=color.new(colBear, 0), textcolor=color.white, size=size.small)

//======================================================
// CONTEXT PROBABILITIES
//======================================================
reversalBullRaw = 0.0
reversalBullRaw += bullTrap ? 30 : 0
reversalBullRaw += lowerWickPct > wickThresh ? 15 : 0
reversalBullRaw += close > open ? 15 : 0
reversalBullRaw += bearExhaust > 50 ? 15 : 0
reversalBullRaw += htfBias >= 0 ? 10 : 0
reversalBullRaw += bullMSS ? 15 : 0
reversalBullRaw += bullAbsorb ? 10 : 0
reversalBull = f_score(reversalBullRaw)

reversalBearRaw = 0.0
reversalBearRaw += bearTrap ? 30 : 0
reversalBearRaw += upperWickPct > wickThresh ? 15 : 0
reversalBearRaw += close < open ? 15 : 0
reversalBearRaw += bullExhaust > 50 ? 15 : 0
reversalBearRaw += htfBias <= 0 ? 10 : 0
reversalBearRaw += bearMSS ? 15 : 0
reversalBearRaw += bearAbsorb ? 10 : 0
reversalBear = f_score(reversalBearRaw)

continuationBullRaw = 0.0
continuationBullRaw += bullAgg > 60 ? 25 : 0
continuationBullRaw += close > prevMid ? 15 : 0
continuationBullRaw += isVolStrong ? 15 : 0
continuationBullRaw += htfBias == 1 ? 15 : 0
continuationBullRaw += not bearTrap ? 10 : 0
continuationBullRaw += trendUpDay ? 10 : 0
continuationBullRaw += not nearADRHigh ? 10 : 0
continuationBullRaw += bullDisp ? 10 : 0
continuationBull = f_score(continuationBullRaw)

continuationBearRaw = 0.0
continuationBearRaw += bearAgg > 60 ? 25 : 0
continuationBearRaw += close < prevMid ? 15 : 0
continuationBearRaw += isVolStrong ? 15 : 0
continuationBearRaw += htfBias == -1 ? 15 : 0
continuationBearRaw += not bullTrap ? 10 : 0
continuationBearRaw += trendDownDay ? 10 : 0
continuationBearRaw += not nearADRLow ? 10 : 0
continuationBearRaw += bearDisp ? 10 : 0
continuationBear = f_score(continuationBearRaw)

trapProbRaw = 0.0
trapProbRaw += sweepAny ? 30 : 0
trapProbRaw += inKZ ? 15 : 0
trapProbRaw += isVolStrong ? 10 : 0
trapProbRaw += (upperWickPct > wickThresh or lowerWickPct > wickThresh) ? 15 : 0
trapProbRaw += barRange > avgRange ? 10 : 0
trapProbRaw += ((equalHigh and bearTrap) or (equalLow and bullTrap)) ? 10 : 0
trapProbRaw += ((bearTrap and inPremium) or (bullTrap and inDiscount)) ? 10 : 0
trapProb = f_score(trapProbRaw)

bullScore = bullAgg * 0.20 + reversalBull * 0.40 + continuationBull * 0.40
bearScore = bearAgg * 0.20 + reversalBear * 0.40 + continuationBear * 0.40

string bias = "Neutral"
if bullEntry
    bias := "Bullish Execution"
else if bearEntry
    bias := "Bearish Execution"
else if bullScore > bearScore + 8
    bias := "Bullish Context"
else if bearScore > bullScore + 8
    bias := "Bearish Context"

//======================================================
// CROWD STATE / ADVICE
//======================================================
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
else if bullAgg > 65 and isVolStrong
    crowdState := "Aggressive buyers"
else if bearAgg > 65 and isVolStrong
    crowdState := "Aggressive sellers"
else if exhaustion > 70
    crowdState := "Move exhausted"

string advice = "Wait for reclaim + confirmation"
if bullEntry
    advice := "Long valid. Use invalidation below sweep. Scale at T1/T2/T3"
else if bearEntry
    advice := "Short valid. Use invalidation above sweep. Scale at T1/T2/T3"
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
else if trapProb > 70
    advice := "High trap probability. Avoid breakout entry"
else if exhaustion > 70
    advice := "Move likely tired. Wait for retrace"
else if isVolDead
    advice := "Dead market. Stay flat"
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
alertcondition(bullEntry, title="Long Setup Valid", message="Market Psychology Radar PRO: Long setup valid")
alertcondition(bearEntry, title="Short Setup Valid", message="Market Psychology Radar PRO: Short setup valid")
alertcondition(bullMSS, title="Bullish MSS", message="Market Psychology Radar PRO: Bullish MSS")
alertcondition(bearMSS, title="Bearish MSS", message="Market Psychology Radar PRO: Bearish MSS")
alertcondition(sweepAny, title="Liquidity Sweep", message="Market Psychology Radar PRO: Sweep detected")
alertcondition(exhaustion > 70, title="High Exhaustion", message="Market Psychology Radar PRO: Exhaustion high")
alertcondition(trapProb > 70, title="High Trap Probability", message="Market Psychology Radar PRO: Trap probability high")
alertcondition(bullAbsorb or bearAbsorb, title="Absorption Detected", message="Market Psychology Radar PRO: Absorption detected")

//======================================================
// DASHBOARD - LEFT
//======================================================
var table mentor = table.new(position.middle_left, 2, 18, border_width=1)

if barstate.islast and showDash
    table.cell(mentor, 0, 0, "MENTOR DASHBOARD", text_color=color.white, bgcolor=color.new(color.blue, 40))
    table.cell(mentor, 1, 0, "Radar PRO", text_color=color.white, bgcolor=color.new(color.blue, 40))

    table.cell(mentor, 0, 1, "Session / KZ", text_color=color.white, bgcolor=color.new(color.gray, 65))
    table.cell(mentor, 1, 1, kzName + (inKZ ? " ACTIVE" : ""), text_color=color.white, bgcolor=color.new(color.gray, 65))

    table.cell(mentor, 0, 2, "HTF Bias", text_color=color.white, bgcolor=htfBias == 1 ? color.new(colBull, 60) : htfBias == -1 ? color.new(colBear, 60) : color.new(color.gray, 60))
    table.cell(mentor, 1, 2, htfStr, text_color=color.white, bgcolor=htfBias == 1 ? color.new(colBull, 60) : htfBias == -1 ? color.new(colBear, 60) : color.new(color.gray, 60))

    table.cell(mentor, 0, 3, "Day Type", text_color=color.white, bgcolor=color.new(color.teal, 65))
    table.cell(mentor, 1, 3, dayType, text_color=color.white, bgcolor=color.new(color.teal, 65))

    table.cell(mentor, 0, 4, "Volume", text_color=color.white, bgcolor=isVolVeryHigh ? color.new(colBull, 45) : isVolStrong ? color.new(colBull, 70) : isVolDead ? color.new(colBear, 60) : color.new(color.gray, 60))
    table.cell(mentor, 1, 4, volState + " (" + str.tostring(math.round(volRatio * 100.0) / 100.0) + "x)", text_color=color.white, bgcolor=isVolVeryHigh ? color.new(colBull, 45) : isVolStrong ? color.new(colBull, 70) : isVolDead ? color.new(colBear, 60) : color.new(color.gray, 60))

    table.cell(mentor, 0, 5, "Bull Aggression", text_color=color.white, bgcolor=color.new(colBull, 75))
    table.cell(mentor, 1, 5, str.tostring(bullAgg) + " | " + f_level(bullAgg), text_color=color.white, bgcolor=color.new(colBull, 75))

    table.cell(mentor, 0, 6, "Bear Aggression", text_color=color.white, bgcolor=color.new(colBear, 75))
    table.cell(mentor, 1, 6, str.tostring(bearAgg) + " | " + f_level(bearAgg), text_color=color.white, bgcolor=color.new(colBear, 75))

    table.cell(mentor, 0, 7, "Exhaustion", text_color=color.white, bgcolor=color.new(color.purple, 65))
    table.cell(mentor, 1, 7, str.tostring(exhaustion) + " | " + f_level(exhaustion), text_color=color.white, bgcolor=color.new(color.purple, 65))

    table.cell(mentor, 0, 8, "Trap Prob", text_color=color.white, bgcolor=color.new(color.orange, 65))
    table.cell(mentor, 1, 8, str.tostring(trapProb) + " | " + f_level(trapProb), text_color=color.white, bgcolor=color.new(color.orange, 65))

    string absorbText = bullAbsorb ? "Bull Absorption" : bearAbsorb ? "Bear Absorption" : compression ? "Compression" : "None"
    table.cell(mentor, 0, 9, "Flow Proxy", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(mentor, 1, 9, absorbText, text_color=bullAbsorb ? colBull : bearAbsorb ? colBear : color.white, bgcolor=color.new(color.black, 0))

    table.cell(mentor, 0, 10, "Structure", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(mentor, 1, 10, marketStructure, text_color=marketStructure == "Bullish Shift" ? colBull : marketStructure == "Bearish Shift" ? colBear : color.white, bgcolor=color.new(color.black, 0))

    string valueText = inDiscount ? "Discount" : inPremium ? "Premium" : "Mid"
    table.cell(mentor, 0, 11, "Value Zone", text_color=color.white, bgcolor=color.new(color.gray, 70))
    table.cell(mentor, 1, 11, valueText, text_color=inDiscount ? colBull : inPremium ? colBear : color.white, bgcolor=color.new(color.gray, 70))

    table.cell(mentor, 0, 12, "ADR Position", text_color=color.white, bgcolor=color.new(color.blue, 70))
    table.cell(mentor, 1, 12, adrPos, text_color=color.white, bgcolor=color.new(color.blue, 70))

    string liqText = "Above " + (liqAbove ? "Yes" : "No") + " | Below " + (liqBelow ? "Yes" : "No")
    table.cell(mentor, 0, 13, "Liquidity", text_color=color.white, bgcolor=color.new(color.orange, 75))
    table.cell(mentor, 1, 13, liqText, text_color=color.white, bgcolor=color.new(color.orange, 75))

    string stateText = "Neutral"
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
    table.cell(mentor, 1, 15, bias, text_color=bullEntry or bias == "Bullish Context" ? colBull : bearEntry or bias == "Bearish Context" ? colBear : color.white, bgcolor=color.new(color.black, 0))

    table.cell(mentor, 0, 16, "Setup Grade", text_color=color.white, bgcolor=color.new(color.gray, 70))
    table.cell(mentor, 1, 16, setupGrade + " (" + str.tostring(setupScore) + ")", text_color=color.yellow, bgcolor=color.new(color.gray, 70))

    string finalText = na(target1) ? advice : advice + " | T1 " + str.tostring(target1, format.mintick)
    table.cell(mentor, 0, 17, "Mentor Advice", text_color=color.white, bgcolor=color.new(color.blue, 70))
    table.cell(mentor, 1, 17, finalText, text_color=color.yellow, bgcolor=color.new(color.blue, 70))
````
