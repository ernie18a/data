# ICT Precision Model v9.1 [Victor FSM + Hidden OTE]

- url: https://www.tradingview.com/script/NfnuEBrA-ICT-Precision-Model-v9-1-Victor-FSM-Hidden-OTE/
- type: indicator
- pine_id: PUB;0df48ae5cfca49489c3abfaa36040951
- version: 1.0

## Description

ICT Concepted Using Built in OTE level for Precise Entries and Variable RR. Used for discretion to help ICT Traders

## Source Code

````pine
//@version=6
indicator("ICT Precision Model v9.1 [Victor FSM + Hidden OTE]", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// =====================
// INPUTS
// =====================
swingLen      = input.int(5, "Swing Length", minval=2)
dispMult      = input.float(1.6, "Displacement Body Multiplier", step=0.1)
extendBars    = input.int(20, "Zone Extension Bars", minval=5)
keyBufferTick = input.int(8, "Key Level Sweep Buffer Ticks", minval=1)
maxWait       = input.int(80, "Max Bars to Complete Setup", minval=10)
manipCooldown = input.int(20, "Manipulation Cooldown Bars", minval=5)
maxSignalsDay = input.int(2, "Max Signals Per Day", minval=1, maxval=3)

showKeyLevels = input.bool(true, "Show Key Levels")
showHTFFVG    = input.bool(true, "Show 15m / 1H / 4H FVG Context")
showSetupZone = input.bool(true, "Show Final Setup Zone")

smtSymbol = input.symbol("CME_MINI:ESM2026", "SMT Comparison Symbol")

// =====================
// HIDDEN OTE VALUES
// =====================
float OTE_MIN = 0.689
float OTE_MID = 0.705
float OTE_MAX = 0.790

// =====================
// COLORS
// =====================
bullColor  = color.new(color.lime, 0)
bearColor  = color.new(color.red, 0)
bullZone   = color.new(color.lime, 88)
bearZone   = color.new(color.red, 88)
htfBullCol = color.new(color.teal, 93)
htfBearCol = color.new(color.maroon, 93)

buffer = syminfo.mintick * keyBufferTick

// =====================
// KEY TIME WINDOWS — UTC
// =====================
hourUTC = hour(time, "UTC")
minUTC  = minute(time, "UTC")
timeUTC = hourUTC * 100 + minUTC

preOpenWindow = timeUTC >= 1300 and timeUTC < 1330
nyOpenWindow  = timeUTC >= 1330 and timeUTC < 1405
tenAMWindow   = timeUTC >= 1350 and timeUTC < 1415
nyAMWindow    = timeUTC >= 1430 and timeUTC < 1830

keyTradeTime = preOpenWindow or nyOpenWindow or tenAMWindow or nyAMWindow

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
// SWING PIVOTS
// =====================
pivotHigh = ta.pivothigh(high, swingLen, swingLen)
pivotLow  = ta.pivotlow(low, swingLen, swingLen)

var float lastSwingHigh = na
var float lastSwingLow = na

if not na(pivotHigh)
    lastSwingHigh := pivotHigh

if not na(pivotLow)
    lastSwingLow := pivotLow

// =====================
// HTF FVG ENGINE
// =====================
f_fvg() =>
    bool bull = low > high[2]
    bool bear = high < low[2]
    float bullTop = low
    float bullBot = high[2]
    float bearTop = low[2]
    float bearBot = high
    int t = time
    [bull, bullTop, bullBot, bear, bearTop, bearBot, t]

[tf15Bull, tf15BullTop, tf15BullBot, tf15Bear, tf15BearTop, tf15BearBot, tf15Time] =
     request.security(syminfo.tickerid, "15", f_fvg(), lookahead=barmerge.lookahead_on)

[tf60Bull, tf60BullTop, tf60BullBot, tf60Bear, tf60BearTop, tf60BearBot, tf60Time] =
     request.security(syminfo.tickerid, "60", f_fvg(), lookahead=barmerge.lookahead_on)

[tf240Bull, tf240BullTop, tf240BullBot, tf240Bear, tf240BearTop, tf240BearBot, tf240Time] =
     request.security(syminfo.tickerid, "240", f_fvg(), lookahead=barmerge.lookahead_on)

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

bullHTFTop  = tf240Bull ? tf240BullTop : tf60Bull ? tf60BullTop : tf15BullTop
bullHTFBot  = tf240Bull ? tf240BullBot : tf60Bull ? tf60BullBot : tf15BullBot
bullHTFTime = tf240Bull ? tf240Time : tf60Bull ? tf60Time : tf15Time

bearHTFTop  = tf240Bear ? tf240BearTop : tf60Bear ? tf60BearTop : tf15BearTop
bearHTFBot  = tf240Bear ? tf240BearBot : tf60Bear ? tf60BearBot : tf15BearBot
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
// FSM STATE VARIABLES
// =====================
var int marketState = 0
var int stateStartBar = na

var float manipHigh = na
var float manipLow = na
var float cisdRefOpen = na
var float cisdRefHigh = na
var float cisdRefLow = na
var float dispHigh = na
var float dispLow = na
var float fvgTop = na
var float fvgBot = na
var float fvgMid = na

var bool zoneTapped = false
var bool oteTapped = false

// =====================
// PREMIUM / DISCOUNT FILTER
// =====================
bullDiscount = not na(manipLow) and (manipLow < dayMid or manipLow < sessionMid)
bearPremium  = not na(manipHigh) and (manipHigh > dayMid or manipHigh > sessionMid)

// =====================
// MANIPULATION CONDITIONS
// =====================
sweepPDL = low < pdl - buffer and close > pdl
sweepPWL = low < pwl - buffer and close > pwl
sweepSwingLow = not na(lastSwingLow) and low < lastSwingLow - buffer and close > lastSwingLow
sweepSessionLow = low < sessionLow[1] - buffer and close > sessionLow[1]

sweepPDH = high > pdh + buffer and close < pdh
sweepPWH = high > pwh + buffer and close < pwh
sweepSwingHigh = not na(lastSwingHigh) and high > lastSwingHigh + buffer and close < lastSwingHigh
sweepSessionHigh = high > sessionHigh[1] + buffer and close < sessionHigh[1]

// =====================
// COOLDOWN + SIGNAL LIMIT
// =====================
var int lastManipBar = na
onCooldown = not na(lastManipBar) and (bar_index - lastManipBar) < manipCooldown

canSignal = keyTradeTime and signalsToday < maxSignalsDay

bullManipCandidate = canSignal and (sweepPDL or sweepPWL or sweepSwingLow or sweepSessionLow or tapBullHTF)
bearManipCandidate = canSignal and (sweepPDH or sweepPWH or sweepSwingHigh or sweepSessionHigh or tapBearHTF)

bullManipRaw = not onCooldown and bullManipCandidate and marketState <= 0
bearManipRaw = not onCooldown and bearManipCandidate and marketState >= 0

// =====================
// RESET EXPIRED SETUP
// =====================
resetNow = not na(stateStartBar) and marketState != 0 and (bar_index - stateStartBar) > maxWait

if resetNow
    marketState := 0
    stateStartBar := na
    manipHigh := na
    manipLow := na
    cisdRefOpen := na
    cisdRefHigh := na
    cisdRefLow := na
    dispHigh := na
    dispLow := na
    fvgTop := na
    fvgBot := na
    fvgMid := na
    zoneTapped := false
    oteTapped := false

// =====================
// STATE ±1 — MANIPULATION
// =====================
if bullManipRaw
    marketState := 1
    stateStartBar := bar_index
    lastManipBar := bar_index
    manipHigh := high
    manipLow := low
    cisdRefOpen := na
    cisdRefHigh := na
    cisdRefLow := na
    dispHigh := na
    dispLow := na
    fvgTop := na
    fvgBot := na
    fvgMid := na
    zoneTapped := false
    oteTapped := false

if bearManipRaw
    marketState := -1
    stateStartBar := bar_index
    lastManipBar := bar_index
    manipHigh := high
    manipLow := low
    cisdRefOpen := na
    cisdRefHigh := na
    cisdRefLow := na
    dispHigh := na
    dispLow := na
    fvgTop := na
    fvgBot := na
    fvgMid := na
    zoneTapped := false
    oteTapped := false

// =====================
// INTERNAL BODY SHIFT
// =====================
if marketState == 1
    if close < open and low >= manipLow and high <= manipHigh * 1.01
        cisdRefOpen := open
        cisdRefHigh := high
        cisdRefLow := low

if marketState == -1
    if close > open and high <= manipHigh and low >= manipLow * 0.99
        cisdRefOpen := open
        cisdRefHigh := high
        cisdRefLow := low

bullShift = marketState == 1 and not na(cisdRefOpen) and close > cisdRefOpen and close > open
bearShift = marketState == -1 and not na(cisdRefOpen) and close < cisdRefOpen and close < open

if bullShift
    marketState := 2

if bearShift
    marketState := -2

// =====================
// DISPLACEMENT
// =====================
body = math.abs(close - open)
avgBody = ta.sma(math.abs(close - open), 20)
recentSwingHigh = ta.highest(high, swingLen)
recentSwingLow = ta.lowest(low, swingLen)

bullDisp = marketState == 2 and close > open and body > avgBody * dispMult and close > recentSwingHigh[1]
bearDisp = marketState == -2 and close < open and body > avgBody * dispMult and close < recentSwingLow[1]

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
    oteTapped := false
    marketState := 4

if marketState == -3 and bearFVG
    fvgTop := low[2]
    fvgBot := high
    fvgMid := (fvgTop + fvgBot) / 2
    zoneTapped := false
    oteTapped := false
    marketState := -4

// =====================
// HIDDEN OTE
// =====================
bullRange = not na(dispHigh) and not na(manipLow) ? dispHigh - manipLow : na
bullOTEHigh = not na(bullRange) ? dispHigh - bullRange * OTE_MIN : na
bullOTELow = not na(bullRange) ? dispHigh - bullRange * OTE_MAX : na

bearRange = not na(manipHigh) and not na(dispLow) ? manipHigh - dispLow : na
bearOTELow = not na(bearRange) ? dispLow + bearRange * OTE_MIN : na
bearOTEHigh = not na(bearRange) ? dispLow + bearRange * OTE_MAX : na

bullOTEHit = marketState == 4 and not na(bullOTELow) and low <= bullOTEHigh and high >= bullOTELow
bearOTEHit = marketState == -4 and not na(bearOTELow) and high >= bearOTELow and low <= bearOTEHigh

if bullOTEHit
    oteTapped := true

if bearOTEHit
    oteTapped := true

// =====================
// RETRACE + BODY CONFIRMATION
// =====================
if marketState == 4 and not na(fvgTop) and not na(fvgBot)
    if low <= fvgTop and high >= fvgBot
        zoneTapped := true

if marketState == -4 and not na(fvgTop) and not na(fvgBot)
    if high >= fvgBot and low <= fvgTop
        zoneTapped := true

bullConfirm = marketState == 4 and canSignal and bullDiscount and zoneTapped and oteTapped and close > open and close > fvgMid and open >= fvgBot
bearConfirm = marketState == -4 and canSignal and bearPremium and zoneTapped and oteTapped and close < open and close < fvgMid and open <= fvgTop

// =====================
// FINAL SIGNAL ONLY
// =====================
if bullConfirm
    signalsToday += 1
    if showSetupZone
        box.new(bar_index[2], fvgTop, bar_index + extendBars, fvgBot, bgcolor=bullZone, border_color=color.new(color.lime, 20))
    label.new(bar_index, low, "BUY ▲\nOTE", style=label.style_label_up, color=bullColor, textcolor=color.black, size=size.normal)
    marketState := 5

if bearConfirm
    signalsToday += 1
    if showSetupZone
        box.new(bar_index[2], fvgTop, bar_index + extendBars, fvgBot, bgcolor=bearZone, border_color=color.new(color.red, 20))
    label.new(bar_index, high, "SELL ▼\nOTE", style=label.style_label_down, color=bearColor, textcolor=color.white, size=size.normal)
    marketState := -5

// =====================
// RESET AFTER SIGNAL
// =====================
if marketState == 5 or marketState == -5
    marketState := 0
    stateStartBar := na
    manipHigh := na
    manipLow := na
    cisdRefOpen := na
    cisdRefHigh := na
    cisdRefLow := na
    dispHigh := na
    dispLow := na
    fvgTop := na
    fvgBot := na
    fvgMid := na
    zoneTapped := false
    oteTapped := false
````
