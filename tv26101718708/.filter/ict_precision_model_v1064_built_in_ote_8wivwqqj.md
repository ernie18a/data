# ICT Precision Model v10.6.4 (Built in OTE)

- url: https://www.tradingview.com/script/8wiVWQqJ-ICT-Precision-Model-v10-6-4-Built-in-OTE/
- type: indicator
- pine_id: PUB;f7a3784f56ee46628ee18eadd0292c5a
- version: 1.0

## Description

Built in ICT OTE levels, Uses the Judas Swing and HTF alignment for Buy/Sell signals. Integrated ICT Concepts. Meant to be used in traders discretion.

## Source Code

````pine
//@version=6
indicator("ICT Precision Model v10.6.4 [Victor Structure Master]", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// =====================
// INPUTS
// =====================
swingLen = input.int(5, "Swing Length", minval=2)
dispMult = input.float(1.6, "Displacement Body Multiplier", step=0.1)
extendBars = input.int(20, "Zone Extension Bars", minval=5)
keyBufferTick = input.int(8, "Key Level Sweep Buffer Ticks", minval=1)
eqToleranceTicks = input.int(12, "Relative Equal High/Low Tolerance Ticks", minval=1)
htfSwingLen = input.int(3, "15m HTF Liquidity Swing Length", minval=2)
maxWait = input.int(80, "Max Bars to Complete Setup", minval=10)
manipCooldown = input.int(20, "Manipulation Cooldown Bars", minval=5)
maxSignalsDay = input.int(2, "Max Signals Per Day", minval=1, maxval=3)
flipCooldownBars = input.int(12, "Flip Lockout Bars", minval=3)

showKeyLevels = input.bool(true, "Show Key Levels")
showEqualLevels = input.bool(true, "Show EQH / EQL")
showHTFFVG = input.bool(true, "Show 15m / 1H / 4H FVG Context")
showSetupZone = input.bool(true, "Show Final Setup Zone")

// =====================
// HIDDEN LEVELS
// =====================
float REV_LEVEL = 0.391
float EQ_LEVEL = 0.500
float CONT_LEVEL = 0.659
float OTE_MIN = 0.689
float OTE_MID = 0.705
float OTE_MAX = 0.790

// =====================
// COLORS
// =====================
bullColor = color.new(color.lime, 0)
bearColor = color.new(color.red, 0)
flipColor = color.new(color.yellow, 0)
pivotColor = color.new(color.orange, 0)
bullZone = color.new(color.lime, 88)
bearZone = color.new(color.red, 88)
htfBullCol = color.new(color.teal, 93)
htfBearCol = color.new(color.maroon, 93)

buffer = syminfo.mintick * keyBufferTick
eqTol = syminfo.mintick * eqToleranceTicks
atr14 = ta.atr(14)
avgATR = ta.sma(atr14, 50)

// =====================
// KEY TIMES — SESSION WINDOWS
// 3m / 1m execution model, 5m+ context model
// =====================
hourNY = hour(time, "America/New_York")
minNY = minute(time, "America/New_York")
timeNY = hourNY * 100 + minNY

asiaWindow = timeNY >= 1930 and timeNY < 2300
londonWindow = timeNY >= 200 and timeNY < 500
judasWindow = timeNY >= 900 and timeNY < 930
nyOpenWindow = timeNY >= 930 and timeNY < 1005
tenAMWindow = timeNY >= 950 and timeNY < 1015
continuationWindow = timeNY >= 1030 and timeNY < 1130
bPlusWindow = timeNY >= 1030 and timeNY < 1430
cutoffWindow = timeNY < 1430

aPlusTime = asiaWindow or londonWindow or judasWindow or nyOpenWindow or tenAMWindow
keyTradeTime = cutoffWindow and (asiaWindow or londonWindow or judasWindow or nyOpenWindow or tenAMWindow or continuationWindow or bPlusWindow)

isOneMinute = timeframe.isminutes and timeframe.multiplier == 1
isThreeMinute = timeframe.isminutes and timeframe.multiplier == 3
isFiveMinutePlus = timeframe.isminutes and timeframe.multiplier >= 5
execTimeframe = isOneMinute or isThreeMinute
contextTimeframe = isFiveMinutePlus

// =====================
// DAILY / WEEKLY LEVELS
// =====================
pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)
pwh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_on)
pwl = request.security(syminfo.tickerid, "W", low[1], lookahead=barmerge.lookahead_on)

plot(showKeyLevels ? pdh : na, "PDH", color=color.new(color.red, 20), linewidth=1)
plot(showKeyLevels ? pdl : na, "PDL", color=color.new(color.green, 20), linewidth=1)
plot(showKeyLevels ? pwh : na, "PWH", color=color.new(color.red, 0), linewidth=2)
plot(showKeyLevels ? pwl : na, "PWL", color=color.new(color.green, 0), linewidth=2)

// =====================
// DAILY RANGE
// =====================
newDay = ta.change(time("D")) != 0

var float dayHigh = na
var float dayLow = na
var int signalsToday = 0

if newDay or na(dayHigh) or na(dayLow)
    dayHigh := high
    dayLow := low
    signalsToday := 0
else
    dayHigh := math.max(dayHigh, high)
    dayLow := math.min(dayLow, low)

dayMid = (dayHigh + dayLow) / 2

// =====================
// SESSION RANGE
// =====================
var float sessionHigh = na
var float sessionLow = na

if newDay or na(sessionHigh) or na(sessionLow)
    sessionHigh := high
    sessionLow := low
else
    sessionHigh := math.max(sessionHigh, high)
    sessionLow := math.min(sessionLow, low)

sessionMid = (sessionHigh + sessionLow) / 2

// =====================
// SWINGS + EQH / EQL
// =====================
pivotHigh = ta.pivothigh(high, swingLen, swingLen)
pivotLow = ta.pivotlow(low, swingLen, swingLen)

var float lastSwingHigh = na
var float lastSwingLow = na
var float prevPivotHigh = na
var float prevPivotLow = na
var float equalHighLevel = na
var float equalLowLevel = na

if newDay
    equalHighLevel := na
    equalLowLevel := na

if not na(pivotHigh)
    lastSwingHigh := pivotHigh
    if not na(prevPivotHigh) and math.abs(pivotHigh - prevPivotHigh) <= eqTol
        equalHighLevel := (pivotHigh + prevPivotHigh) / 2
    prevPivotHigh := pivotHigh

if not na(pivotLow)
    lastSwingLow := pivotLow
    if not na(prevPivotLow) and math.abs(pivotLow - prevPivotLow) <= eqTol
        equalLowLevel := (pivotLow + prevPivotLow) / 2
    prevPivotLow := pivotLow

plot(showEqualLevels ? equalHighLevel : na, "EQH / Relative EQH", color=color.new(color.red, 35), linewidth=1)
plot(showEqualLevels ? equalLowLevel : na, "EQL / Relative EQL", color=color.new(color.lime, 35), linewidth=1)

recentSwingHigh = ta.highest(high, swingLen)
recentSwingLow = ta.lowest(low, swingLen)

// =====================
// 15m HTF LIQUIDITY ANCHOR ENGINE
// =====================
htf15PivotHigh = request.security(syminfo.tickerid, "15", ta.pivothigh(high, htfSwingLen, htfSwingLen), lookahead=barmerge.lookahead_on)
htf15PivotLow = request.security(syminfo.tickerid, "15", ta.pivotlow(low, htfSwingLen, htfSwingLen), lookahead=barmerge.lookahead_on)

var float last15SwingHigh = na
var float last15SwingLow = na
var float prev15SwingHigh = na
var float prev15SwingLow = na
var float equal15HighLevel = na
var float equal15LowLevel = na

if newDay
    equal15HighLevel := na
    equal15LowLevel := na

if not na(htf15PivotHigh)
    last15SwingHigh := htf15PivotHigh
    if not na(prev15SwingHigh) and math.abs(htf15PivotHigh - prev15SwingHigh) <= eqTol
        equal15HighLevel := (htf15PivotHigh + prev15SwingHigh) / 2
    prev15SwingHigh := htf15PivotHigh

if not na(htf15PivotLow)
    last15SwingLow := htf15PivotLow
    if not na(prev15SwingLow) and math.abs(htf15PivotLow - prev15SwingLow) <= eqTol
        equal15LowLevel := (htf15PivotLow + prev15SwingLow) / 2
    prev15SwingLow := htf15PivotLow

plot(showEqualLevels ? equal15HighLevel : na, "15m EQH", color=color.new(color.red, 20), linewidth=2)
plot(showEqualLevels ? equal15LowLevel : na, "15m EQL", color=color.new(color.lime, 20), linewidth=2)
plot(showKeyLevels ? last15SwingHigh : na, "15m Swing High", color=color.new(color.red, 65), linewidth=1)
plot(showKeyLevels ? last15SwingLow : na, "15m Swing Low", color=color.new(color.lime, 65), linewidth=1)

// =====================
// HTF FVG — PINE SAFE
// =====================
tf15Bull = request.security(syminfo.tickerid, "15", low > high[2], lookahead=barmerge.lookahead_on)
tf15Bear = request.security(syminfo.tickerid, "15", high < low[2], lookahead=barmerge.lookahead_on)
tf15BullTop = request.security(syminfo.tickerid, "15", low, lookahead=barmerge.lookahead_on)
tf15BullBot = request.security(syminfo.tickerid, "15", high[2], lookahead=barmerge.lookahead_on)
tf15BearTop = request.security(syminfo.tickerid, "15", low[2], lookahead=barmerge.lookahead_on)
tf15BearBot = request.security(syminfo.tickerid, "15", high, lookahead=barmerge.lookahead_on)
tf15Time = request.security(syminfo.tickerid, "15", time, lookahead=barmerge.lookahead_on)

tf60Bull = request.security(syminfo.tickerid, "60", low > high[2], lookahead=barmerge.lookahead_on)
tf60Bear = request.security(syminfo.tickerid, "60", high < low[2], lookahead=barmerge.lookahead_on)
tf60BullTop = request.security(syminfo.tickerid, "60", low, lookahead=barmerge.lookahead_on)
tf60BullBot = request.security(syminfo.tickerid, "60", high[2], lookahead=barmerge.lookahead_on)
tf60BearTop = request.security(syminfo.tickerid, "60", low[2], lookahead=barmerge.lookahead_on)
tf60BearBot = request.security(syminfo.tickerid, "60", high, lookahead=barmerge.lookahead_on)
tf60Time = request.security(syminfo.tickerid, "60", time, lookahead=barmerge.lookahead_on)

tf240Bull = request.security(syminfo.tickerid, "240", low > high[2], lookahead=barmerge.lookahead_on)
tf240Bear = request.security(syminfo.tickerid, "240", high < low[2], lookahead=barmerge.lookahead_on)
tf240BullTop = request.security(syminfo.tickerid, "240", low, lookahead=barmerge.lookahead_on)
tf240BullBot = request.security(syminfo.tickerid, "240", high[2], lookahead=barmerge.lookahead_on)
tf240BearTop = request.security(syminfo.tickerid, "240", low[2], lookahead=barmerge.lookahead_on)
tf240BearBot = request.security(syminfo.tickerid, "240", high, lookahead=barmerge.lookahead_on)
tf240Time = request.security(syminfo.tickerid, "240", time, lookahead=barmerge.lookahead_on)

var float activeBullHTFTop = na
var float activeBullHTFBot = na
var float activeBearHTFTop = na
var float activeBearHTFBot = na
var box bullHTFBox = na
var box bearHTFBox = na
var int lastBullHTFTime = na
var int lastBearHTFTime = na

newBullHTF = tf240Bull or tf60Bull or tf15Bull
newBearHTF = tf240Bear or tf60Bear or tf15Bear

bullHTFTop = tf240Bull ? tf240BullTop : tf60Bull ? tf60BullTop : tf15BullTop
bullHTFBot = tf240Bull ? tf240BullBot : tf60Bull ? tf60BullBot : tf15BullBot
bullHTFTime = tf240Bull ? tf240Time : tf60Bull ? tf60Time : tf15Time

bearHTFTop = tf240Bear ? tf240BearTop : tf60Bear ? tf60BearTop : tf15BearTop
bearHTFBot = tf240Bear ? tf240BearBot : tf60Bear ? tf60BearBot : tf15BearBot
bearHTFTime = tf240Bear ? tf240Time : tf60Bear ? tf60Time : tf15Time

if newBullHTF and bullHTFTime != lastBullHTFTime
    activeBullHTFTop := bullHTFTop
    activeBullHTFBot := bullHTFBot
    lastBullHTFTime := bullHTFTime
    if showHTFFVG
        if not na(bullHTFBox)
            box.delete(bullHTFBox)
        bullHTFBox := box.new(bar_index[2], bullHTFTop, bar_index + extendBars, bullHTFBot, bgcolor=htfBullCol, border_color=color.new(color.teal, 70))

if newBearHTF and bearHTFTime != lastBearHTFTime
    activeBearHTFTop := bearHTFTop
    activeBearHTFBot := bearHTFBot
    lastBearHTFTime := bearHTFTime
    if showHTFFVG
        if not na(bearHTFBox)
            box.delete(bearHTFBox)
        bearHTFBox := box.new(bar_index[2], bearHTFTop, bar_index + extendBars, bearHTFBot, bgcolor=htfBearCol, border_color=color.new(color.red, 70))

tapBullHTF = not na(activeBullHTFBot) and low <= activeBullHTFTop and high >= activeBullHTFBot
tapBearHTF = not na(activeBearHTFTop) and high >= activeBearHTFBot and low <= activeBearHTFTop

if not na(activeBullHTFBot) and close < activeBullHTFBot
    activeBullHTFTop := na
    activeBullHTFBot := na

if not na(activeBearHTFTop) and close > activeBearHTFTop
    activeBearHTFTop := na
    activeBearHTFBot := na

// =====================
// BODY / STRUCTURE
// =====================
body = math.abs(close - open)
avgBody = ta.sma(math.abs(close - open), 20)
bodyStrong = body > avgBody * dispMult

candleRange = high - low
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

ema20 = ta.ema(close, 20)
ema50 = ta.ema(close, 50)

bullTrend = ema20 > ema50 and close > ema20
bearTrend = ema20 < ema50 and close < ema20

bullStructure = close > recentSwingHigh[1] and low > recentSwingLow[1]
bearStructure = close < recentSwingLow[1] and high < recentSwingHigh[1]

// =====================
// CONSOLIDATION FILTER
// =====================
rangeNow = ta.highest(high, 12) - ta.lowest(low, 12)
avgRange = ta.sma(high - low, 30)
smallRange = rangeNow < avgRange * 6.5
atrCompressed = atr14 < avgATR * 0.85
overlapBars = math.abs(close - close[5]) < atr14 * 0.6
weakBodies = body < avgBody * 0.75

consolidating = smallRange and atrCompressed and overlapBars and weakBodies

// =====================
// STRUCTURE MASTER ENGINE — v10.6.4
// =====================
rangeExpand = (ta.highest(high, 10) - ta.lowest(low, 10)) > atr14 * 1.8

bullImpulse = bullTrend and bullStructure and bodyStrong and rangeExpand
bearImpulse = bearTrend and bearStructure and bodyStrong and rangeExpand

bullCorrection = bullTrend and not bullImpulse and close > ema50 and body < avgBody
bearCorrection = bearTrend and not bearImpulse and close < ema50 and body < avgBody

structureState = bullImpulse ? 1 : bearImpulse ? -1 : bullCorrection ? 2 : bearCorrection ? -2 : 0

inBullImpulse = structureState == 1
inBearImpulse = structureState == -1
inBullCorrection = structureState == 2
inBearCorrection = structureState == -2
inCorrection = inBullCorrection or inBearCorrection
inChopState = structureState == 0

deepChop = consolidating and inChopState
lightChop = consolidating and not inChopState

bullBOS = close > recentSwingHigh[1] and bodyStrong
bearBOS = close < recentSwingLow[1] and bodyStrong

// =====================
// FSM VARIABLES
// =====================
var int marketState = 0
var int stateStartBar = na

var float manipHigh = na
var float manipLow = na
var float cisdRefOpen = na
var float dispHigh = na
var float dispLow = na
var float fvgTop = na
var float fvgBot = na
var float fvgMid = na

var bool zoneTapped = false
var bool fibTapped = false
var bool wasInZone = false
var int retestCount = 0

bullDiscount = not na(manipLow) and (manipLow < dayMid or manipLow < sessionMid)
bearPremium = not na(manipHigh) and (manipHigh > dayMid or manipHigh > sessionMid)

// =====================
// SIGNAL MEMORY / FLIP
// =====================
var int lastSignalDir = 0
var int lastSignalBar = na
var float lastSignalHigh = na
var float lastSignalLow = na

oppositeTooSoon = not na(lastSignalBar) and (bar_index - lastSignalBar) <= flipCooldownBars

buyBlockedByRecentSell = lastSignalDir == -1 and oppositeTooSoon
sellBlockedByRecentBuy = lastSignalDir == 1 and oppositeTooSoon

// =====================
// LIQUIDITY SWEEPS
// =====================
sweepPDL = low < pdl - buffer and close > pdl
sweepPWL = low < pwl - buffer and close > pwl
sweepSwingLow = not na(lastSwingLow) and low < lastSwingLow - buffer and close > lastSwingLow
sweepSessionLow = low < sessionLow[1] - buffer and close > sessionLow[1]
sweepEQL = not na(equalLowLevel) and low < equalLowLevel - buffer and close > equalLowLevel
sweep15Low = not na(last15SwingLow) and low < last15SwingLow - buffer and close > last15SwingLow
sweep15EQL = not na(equal15LowLevel) and low < equal15LowLevel - buffer and close > equal15LowLevel

sweepPDH = high > pdh + buffer and close < pdh
sweepPWH = high > pwh + buffer and close < pwh
sweepSwingHigh = not na(lastSwingHigh) and high > lastSwingHigh + buffer and close < lastSwingHigh
sweepSessionHigh = high > sessionHigh[1] + buffer and close < sessionHigh[1]
sweepEQH = not na(equalHighLevel) and high > equalHighLevel + buffer and close < equalHighLevel
sweep15High = not na(last15SwingHigh) and high > last15SwingHigh + buffer and close < last15SwingHigh
sweep15EQH = not na(equal15HighLevel) and high > equal15HighLevel + buffer and close < equal15HighLevel

majorBullLiquidity = sweepPDL or sweepPWL or sweep15Low or sweep15EQL or tapBullHTF
majorBearLiquidity = sweepPDH or sweepPWH or sweep15High or sweep15EQH or tapBearHTF

bullLiquidity = sweepPDL or sweepPWL or sweepSwingLow or sweepSessionLow or sweepEQL or sweep15Low or sweep15EQL or tapBullHTF
bearLiquidity = sweepPDH or sweepPWH or sweepSwingHigh or sweepSessionHigh or sweepEQH or sweep15High or sweep15EQH or tapBearHTF

// =====================
// MANIPULATION
// =====================
var int lastManipBar = na
onCooldown = not na(lastManipBar) and (bar_index - lastManipBar) < manipCooldown

canSignal = keyTradeTime and signalsToday < maxSignalsDay and not deepChop
allowBPlus = bPlusWindow and signalsToday == 0

bullManipRaw = not onCooldown and canSignal and marketState <= 0 and bullLiquidity
bearManipRaw = not onCooldown and canSignal and marketState >= 0 and bearLiquidity

// =====================
// RESET EXPIRED
// =====================
if not na(stateStartBar) and marketState != 0 and (bar_index - stateStartBar) > maxWait
    marketState := 0
    stateStartBar := na
    manipHigh := na
    manipLow := na
    cisdRefOpen := na
    dispHigh := na
    dispLow := na
    fvgTop := na
    fvgBot := na
    fvgMid := na
    zoneTapped := false
    fibTapped := false
    wasInZone := false
    retestCount := 0

// =====================
// STATE 1 / -1 — MANIPULATION
// =====================
if bullManipRaw
    marketState := 1
    stateStartBar := bar_index
    lastManipBar := bar_index
    manipHigh := high
    manipLow := low
    cisdRefOpen := na
    dispHigh := na
    dispLow := na
    fvgTop := na
    fvgBot := na
    fvgMid := na
    zoneTapped := false
    fibTapped := false
    wasInZone := false
    retestCount := 0

if bearManipRaw
    marketState := -1
    stateStartBar := bar_index
    lastManipBar := bar_index
    manipHigh := high
    manipLow := low
    cisdRefOpen := na
    dispHigh := na
    dispLow := na
    fvgTop := na
    fvgBot := na
    fvgMid := na
    zoneTapped := false
    fibTapped := false
    wasInZone := false
    retestCount := 0

// =====================
// INTERNAL BODY SHIFT
// =====================
if marketState == 1
    if close < open and low >= manipLow and high <= manipHigh * 1.01
        cisdRefOpen := open

if marketState == -1
    if close > open and high <= manipHigh and low >= manipLow * 0.99
        cisdRefOpen := open

bullShift = marketState == 1 and not na(cisdRefOpen) and close > cisdRefOpen and close > open
bearShift = marketState == -1 and not na(cisdRefOpen) and close < cisdRefOpen and close < open

if bullShift
    marketState := 2

if bearShift
    marketState := -2

// =====================
// DISPLACEMENT
// =====================
bullDisp = marketState == 2 and close > open and bodyStrong and close > recentSwingHigh[1]
bearDisp = marketState == -2 and close < open and bodyStrong and close < recentSwingLow[1]

if bullDisp
    dispHigh := high
    dispLow := low
    marketState := 3

if bearDisp
    dispHigh := high
    dispLow := low
    marketState := -3

// =====================
// FVG STORE
// =====================
bullFVG = low > high[2]
bearFVG = high < low[2]

if marketState == 3 and bullFVG
    fvgTop := low
    fvgBot := high[2]
    fvgMid := (fvgTop + fvgBot) / 2
    zoneTapped := false
    fibTapped := false
    wasInZone := false
    retestCount := 0
    marketState := 4

if marketState == -3 and bearFVG
    fvgTop := low[2]
    fvgBot := high
    fvgMid := (fvgTop + fvgBot) / 2
    zoneTapped := false
    fibTapped := false
    wasInZone := false
    retestCount := 0
    marketState := -4

// =====================
// HIDDEN OTE — SWEEP TO DISPLACEMENT
// =====================
bullRange = not na(dispHigh) and not na(manipLow) ? dispHigh - manipLow : na
bullRev = not na(bullRange) ? dispHigh - bullRange * REV_LEVEL : na
bullEQ = not na(bullRange) ? dispHigh - bullRange * EQ_LEVEL : na
bullCont = not na(bullRange) ? dispHigh - bullRange * CONT_LEVEL : na
bullOTEHigh = not na(bullRange) ? dispHigh - bullRange * OTE_MIN : na
bullOTEMid = not na(bullRange) ? dispHigh - bullRange * OTE_MID : na
bullOTELow = not na(bullRange) ? dispHigh - bullRange * OTE_MAX : na

bearRange = not na(manipHigh) and not na(dispLow) ? manipHigh - dispLow : na
bearRev = not na(bearRange) ? dispLow + bearRange * REV_LEVEL : na
bearEQ = not na(bearRange) ? dispLow + bearRange * EQ_LEVEL : na
bearCont = not na(bearRange) ? dispLow + bearRange * CONT_LEVEL : na
bearOTELow = not na(bearRange) ? dispLow + bearRange * OTE_MIN : na
bearOTEMid = not na(bearRange) ? dispLow + bearRange * OTE_MID : na
bearOTEHigh = not na(bearRange) ? dispLow + bearRange * OTE_MAX : na

bullOTEHit = marketState == 4 and not na(bullOTELow) and low <= bullOTEHigh and high >= bullOTELow
bearOTEHit = marketState == -4 and not na(bearOTELow) and high >= bearOTELow and low <= bearOTEHigh

bullContHit = marketState == 4 and not na(bullCont) and low <= bullCont and high >= bullCont
bearContHit = marketState == -4 and not na(bearCont) and high >= bearCont and low <= bearCont

bullRevHit = marketState == 4 and not na(bullRev) and low <= bullRev and high >= bullRev
bearRevHit = marketState == -4 and not na(bearRev) and high >= bearRev and low <= bearRev

if bullOTEHit or bullContHit or bullRevHit or bearOTEHit or bearContHit or bearRevHit
    fibTapped := true

// =====================
// MICRO CONFIRMATION
// =====================
narrowBody = candleRange > 0 and body <= candleRange * 0.45

bullVReject = narrowBody and lowerWick >= body * 1.5 and close > open and close > high[1]
bearVReject = narrowBody and upperWick >= body * 1.5 and close < open and close < low[1]

bullMicroConfirm = not na(bullEQ) and close > open and close > bullEQ
bearMicroConfirm = not na(bearEQ) and close < open and close < bearEQ

// =====================
// RETEST LOGIC
// =====================
inBullZone = marketState == 4 and not na(fvgTop) and low <= fvgTop and high >= fvgBot
inBearZone = marketState == -4 and not na(fvgTop) and high >= fvgBot and low <= fvgTop
inSetupZone = inBullZone or inBearZone

if inSetupZone and not wasInZone
    retestCount += 1

wasInZone := inSetupZone

isBPlusRetest = allowBPlus and retestCount >= 1 and retestCount < 2
isAPlusRetest = retestCount >= 2
zoneTapped := isAPlusRetest or isBPlusRetest

// =====================
// SCORE ENGINE
// =====================
bullScoreLiquidity = bullLiquidity ? 3 : 0
bullScoreHTF = majorBullLiquidity ? 3 : 0
bullScoreEQ = (sweepEQL or sweep15EQL) ? 2 : 0
bullScoreTime = aPlusTime ? 2 : bPlusWindow ? 1 : 0
bullScoreDisplacement = marketState == 4 ? 2 : 0
bullScoreOTE = bullOTEHit ? 3 : bullContHit ? 2 : bullRevHit ? 1 : 0
bullScoreMicro = bullMicroConfirm or bullVReject ? 2 : 0
bullScoreTrend = bullTrend ? 1 : 0
bullScoreStructure = inBullImpulse ? 2 : inBullCorrection ? 0 : inBearImpulse ? -2 : 0
bullScoreTF = execTimeframe ? 1 : contextTimeframe ? 0 : 0
bullScorePenalty = deepChop ? -5 : lightChop ? -2 : 0
bullScore = bullScoreLiquidity + bullScoreHTF + bullScoreEQ + bullScoreTime + bullScoreDisplacement + bullScoreOTE + bullScoreMicro + bullScoreTrend + bullScoreStructure + bullScoreTF + bullScorePenalty

bearScoreLiquidity = bearLiquidity ? 3 : 0
bearScoreHTF = majorBearLiquidity ? 3 : 0
bearScoreEQ = (sweepEQH or sweep15EQH) ? 2 : 0
bearScoreTime = aPlusTime ? 2 : bPlusWindow ? 1 : 0
bearScoreDisplacement = marketState == -4 ? 2 : 0
bearScoreOTE = bearOTEHit ? 3 : bearContHit ? 2 : bearRevHit ? 1 : 0
bearScoreMicro = bearMicroConfirm or bearVReject ? 2 : 0
bearScoreTrend = bearTrend ? 1 : 0
bearScoreStructure = inBearImpulse ? 2 : inBearCorrection ? 0 : inBullImpulse ? -2 : 0
bearScoreTF = execTimeframe ? 1 : contextTimeframe ? 0 : 0
bearScorePenalty = deepChop ? -5 : lightChop ? -2 : 0
bearScore = bearScoreLiquidity + bearScoreHTF + bearScoreEQ + bearScoreTime + bearScoreDisplacement + bearScoreOTE + bearScoreMicro + bearScoreTrend + bearScoreStructure + bearScoreTF + bearScorePenalty

bullGradeA = bullScore >= 9
bullGradeB = bullScore >= 7 and bullScore < 9
bearGradeA = bearScore >= 9
bearGradeB = bearScore >= 7 and bearScore < 9

// =====================
// CONFIRMATIONS
// =====================
trueBullReversal = bullLiquidity and close > open and bullBOS and bodyStrong
trueBearReversal = bearLiquidity and close < open and bearBOS and bodyStrong

bullReversalConfirmRaw = marketState == 4 and canSignal and bullDiscount and fibTapped and bullVReject and trueBullReversal and bullScore >= 7
bearReversalConfirmRaw = marketState == -4 and canSignal and bearPremium and fibTapped and bearVReject and trueBearReversal and bearScore >= 7

bullConfirmRaw = marketState == 4 and canSignal and bullDiscount and zoneTapped and bullMicroConfirm and bullScore >= 7
bearConfirmRaw = marketState == -4 and canSignal and bearPremium and zoneTapped and bearMicroConfirm and bearScore >= 7

buyFlipAllowed = buyBlockedByRecentSell and close > lastSignalHigh and body > avgBody * 1.2 and close > open
sellFlipAllowed = sellBlockedByRecentBuy and close < lastSignalLow and body > avgBody * 1.2 and close < open

bullReversalConfirm = bullReversalConfirmRaw and (not buyBlockedByRecentSell or buyFlipAllowed)
bearReversalConfirm = bearReversalConfirmRaw and (not sellBlockedByRecentBuy or sellFlipAllowed)

bullConfirm = bullConfirmRaw and (not buyBlockedByRecentSell or buyFlipAllowed)
bearConfirm = bearConfirmRaw and (not sellBlockedByRecentBuy or sellFlipAllowed)

// =====================
// PIVOT RECLAIM ENGINE
// =====================
pivotEngineAllowed = marketState == 0 and canSignal

pivotBuyRaw = pivotEngineAllowed and bullLiquidity and (low < dayMid or low < sessionMid) and close > open and close > high[1] and lowerWick >= body * 1.2 and not deepChop
pivotSellRaw = pivotEngineAllowed and bearLiquidity and (high > dayMid or high > sessionMid) and close < open and close < low[1] and upperWick >= body * 1.2 and not deepChop

pivotBuyScore = 3 + (majorBullLiquidity ? 3 : 0) + ((sweepEQL or sweep15EQL) ? 2 : 0) + (aPlusTime ? 2 : 1) + (bullTrend ? 1 : 0) + (execTimeframe ? 1 : 0)
pivotSellScore = 3 + (majorBearLiquidity ? 3 : 0) + ((sweepEQH or sweep15EQH) ? 2 : 0) + (aPlusTime ? 2 : 1) + (bearTrend ? 1 : 0) + (execTimeframe ? 1 : 0)

pivotBuy = pivotBuyRaw and pivotBuyScore >= 7 and (not buyBlockedByRecentSell or buyFlipAllowed)
pivotSell = pivotSellRaw and pivotSellScore >= 7 and (not sellBlockedByRecentBuy or sellFlipAllowed)

// =====================
// CONTINUATION ENGINE
// =====================
majorBullDisplacement = canSignal and continuationWindow and inBullImpulse and bullTrend and bullStructure and close > open and body > avgBody * 2.0 and close > dayMid
majorBearDisplacement = canSignal and continuationWindow and inBearImpulse and bearTrend and bearStructure and close < open and body > avgBody * 2.0 and close < dayMid

var float bullContTop = na
var float bullContBot = na
var float bullContEQ = na
var int bullContBar = na

var float bearContTop = na
var float bearContBot = na
var float bearContEQ = na
var int bearContBar = na

if majorBullDisplacement
    bullContTop := open
    bullContBot := low
    bullContEQ := (open + low) / 2
    bullContBar := bar_index

if majorBearDisplacement
    bearContTop := high
    bearContBot := open
    bearContEQ := (high + open) / 2
    bearContBar := bar_index

bullContRetest = not na(bullContTop) and bar_index > bullContBar and low <= bullContTop and high >= bullContBot
bearContRetest = not na(bearContTop) and bar_index > bearContBar and high >= bearContBot and low <= bearContTop

continuationAllowed = marketState == 0 and not deepChop and not inCorrection

bullContinuationRaw = continuationAllowed and canSignal and inBullImpulse and signalsToday < maxSignalsDay and bullTrend and bullStructure and bullContRetest and close > open and close > bullContEQ and close > dayMid
bearContinuationRaw = continuationAllowed and canSignal and inBearImpulse and signalsToday < maxSignalsDay and bearTrend and bearStructure and bearContRetest and close < open and close < bearContEQ and close < dayMid

bullContinuationConfirm = bullContinuationRaw and (not buyBlockedByRecentSell or buyFlipAllowed)
bearContinuationConfirm = bearContinuationRaw and (not sellBlockedByRecentBuy or sellFlipAllowed)

// =====================
// FINAL SIGNALS
// =====================
if pivotBuy
    signalsToday += 1
    label.new(bar_index, low, buyFlipAllowed ? "BUY ▲\nFLIP" : majorBullLiquidity ? "BUY ▲\nHTF PIV" : "BUY ▲\nPIV", style=label.style_label_up, color=buyFlipAllowed ? flipColor : pivotColor, textcolor=color.black, size=size.normal)
    lastSignalDir := 1
    lastSignalBar := bar_index
    lastSignalHigh := high
    lastSignalLow := low

else if pivotSell
    signalsToday += 1
    label.new(bar_index, high, sellFlipAllowed ? "SELL ▼\nFLIP" : majorBearLiquidity ? "SELL ▼\nHTF PIV" : "SELL ▼\nPIV", style=label.style_label_down, color=sellFlipAllowed ? flipColor : pivotColor, textcolor=color.black, size=size.normal)
    lastSignalDir := -1
    lastSignalBar := bar_index
    lastSignalHigh := high
    lastSignalLow := low

else if bullReversalConfirm
    signalsToday += 1
    label.new(bar_index, low, buyFlipAllowed ? "BUY ▲\nFLIP" : bullGradeA ? "BUY ▲\nA+" : "BUY ▲\nB+", style=label.style_label_up, color=buyFlipAllowed ? flipColor : bullColor, textcolor=color.black, size=size.normal)
    lastSignalDir := 1
    lastSignalBar := bar_index
    lastSignalHigh := high
    lastSignalLow := low
    marketState := 5

else if bearReversalConfirm
    signalsToday += 1
    label.new(bar_index, high, sellFlipAllowed ? "SELL ▼\nFLIP" : bearGradeA ? "SELL ▼\nA+" : "SELL ▼\nB+", style=label.style_label_down, color=sellFlipAllowed ? flipColor : bearColor, textcolor=sellFlipAllowed ? color.black : color.white, size=size.normal)
    lastSignalDir := -1
    lastSignalBar := bar_index
    lastSignalHigh := high
    lastSignalLow := low
    marketState := -5

else if bullConfirm
    signalsToday += 1
    if showSetupZone
        box.new(bar_index[2], fvgTop, bar_index + extendBars, fvgBot, bgcolor=bullZone, border_color=color.new(color.lime, 20))
    label.new(bar_index, low, buyFlipAllowed ? "BUY ▲\nFLIP" : bullGradeA ? "BUY ▲\nA+" : "BUY ▲\nB+", style=label.style_label_up, color=buyFlipAllowed ? flipColor : bullColor, textcolor=color.black, size=size.normal)
    lastSignalDir := 1
    lastSignalBar := bar_index
    lastSignalHigh := high
    lastSignalLow := low
    marketState := 5

else if bearConfirm
    signalsToday += 1
    if showSetupZone
        box.new(bar_index[2], fvgTop, bar_index + extendBars, fvgBot, bgcolor=bearZone, border_color=color.new(color.red, 20))
    label.new(bar_index, high, sellFlipAllowed ? "SELL ▼\nFLIP" : bearGradeA ? "SELL ▼\nA+" : "SELL ▼\nB+", style=label.style_label_down, color=sellFlipAllowed ? flipColor : bearColor, textcolor=sellFlipAllowed ? color.black : color.white, size=size.normal)
    lastSignalDir := -1
    lastSignalBar := bar_index
    lastSignalHigh := high
    lastSignalLow := low
    marketState := -5

else if bullContinuationConfirm
    signalsToday += 1
    label.new(bar_index, low, buyFlipAllowed ? "BUY ▲\nFLIP" : "BUY ▲\nCONT", style=label.style_label_up, color=buyFlipAllowed ? flipColor : bullColor, textcolor=color.black, size=size.normal)
    lastSignalDir := 1
    lastSignalBar := bar_index
    lastSignalHigh := high
    lastSignalLow := low
    bullContTop := na
    bullContBot := na
    bullContEQ := na
    bullContBar := na

else if bearContinuationConfirm
    signalsToday += 1
    label.new(bar_index, high, sellFlipAllowed ? "SELL ▼\nFLIP" : "SELL ▼\nCONT", style=label.style_label_down, color=sellFlipAllowed ? flipColor : bearColor, textcolor=sellFlipAllowed ? color.black : color.white, size=size.normal)
    lastSignalDir := -1
    lastSignalBar := bar_index
    lastSignalHigh := high
    lastSignalLow := low
    bearContTop := na
    bearContBot := na
    bearContEQ := na
    bearContBar := na

// =====================
// RESET AFTER FSM SIGNAL
// =====================
if marketState == 5 or marketState == -5
    marketState := 0
    stateStartBar := na
    manipHigh := na
    manipLow := na
    cisdRefOpen := na
    dispHigh := na
    dispLow := na
    fvgTop := na
    fvgBot := na
    fvgMid := na
    zoneTapped := false
    fibTapped := false
    wasInZone := false
    retestCount := 0
````
