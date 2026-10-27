# VWAP Reversal Signals

- url: https://www.tradingview.com/script/KaZsF52v-VWAP-Reversal-Signals/
- type: indicator
- pine_id: PUB;d2a75322cb2047eea69363f2a4dee568
- version: 2.0

## Description

This script displays long or short flags after a touch of the VWAP 2 standard deviation line occurs according to the script rules which attempt to determine when there is a bounce toward VWAP. A flag also indicates if VWAP is hit or else if a settings-configurable distance from VWAP is touched. If, instead, the stop is reached, a red "X" is displayed.

## Source Code

````pine
//@version=5
indicator("VWAP 2σ Reversal", overlay=true)

// This script flags possible long or short reversals after a touch of
// the VWAP 2 standard deviation line. To see all long or short flags,
// use Replay mode for back testing or else live mode.
// A "VWAP" flag is shown if the price touches or crosses VWAP after
// a long or short flag was displayed.
// A "~VWAP" (near VWAP) flag is shown if the price touches the point that is
// the number of ticks away from VWAP as defined in the settings.
// A red "X" is displayed if the stop loss is hit after a long or short
// flag.
// Long and short flags also contain a possible Stop Loss value which
// may be adjusted in settings.
// Note that the location of the VWAP 2 standard deviation line changes
// when using Regular Trading Hours versus Electronic Trading Hours.
// Testing during the New York session hours (starting 9:30AM ET) 
// used the Regular Trading Hours setting in Tradingview.

//=========================
// INPUTS
//=========================
startHour        = input.int(10,    "Start Hour (ET)")
startMinute      = input.int(0,    "Start Minute (ET)")
stopLookback     = input.int(4,     "Stop Lookback Bars", minval=1,
     tooltip="Number of recent candles used to calculate the stop loss level. Uses the lowest low (long) or highest high (short) over this range.")
stopBufferTicks  = input.int(40,    "Stop Loss Display Buffer (Ticks)", minval=0,
     tooltip="Additional buffer in ticks subtracted from (long) or added to (short) the stop level shown in the signal label")
vwapProximity    = input.float(20.0,"VWAP Reset Distance (Ticks)",
     tooltip="For a long trade, exit when a candle's high gets within this many ticks below VWAP, or touches/crosses VWAP. For a short trade, exit when a candle's low gets within this many ticks above VWAP, or touches/crosses VWAP.")
armExpiry        = input.int(7,     "Signal Expiry (Bars Since 2σ Touch)", minval=1,
     tooltip="Maximum number of candles allowed between the 2σ band touch and a confirming entry candle. If no signal forms within this window, the setup is cancelled.")
minStdDist       = input.float(0.7, "Minimum Distance from VWAP (Std Dev)", minval=0.1, step=0.1,
     tooltip="The confirming candle's close must be at least this many standard deviations away from VWAP. Prevents entries where price has already reverted too close to VWAP, leaving little room to profit.")

// --- Hammer / Inverted Hammer Filter ---
wickDominantPct  = input.float(70.0, "Hammer/Inv. Hammer: Dominant Wick % of Range", minval=50.0, maxval=99.0, step=1.0, group="Hammer Filter",
     tooltip="The relevant wick (lower for hammer, upper for inverted hammer) must be at least this % of the total candle range (high - low) to be classified as a hammer or inverted hammer.")
wickOppositePct  = input.float(15.0, "Hammer/Inv. Hammer: Max Opposite Wick % of Range", minval=1.0, maxval=49.0, step=1.0, group="Hammer Filter",
     tooltip="The opposite wick must be no larger than this % of the total candle range for the pattern to qualify. Keeps the filter strict — both conditions must be met.")

//=========================
// STATE ENUM
//=========================
var int STATE_IDLE  = 0
var int STATE_TRADE = 2

var int   state      = STATE_IDLE
var float activeStop = na
var bool  isLong     = false

//=========================
// SESSION VWAP
//=========================
newSession = timeframe.change("D")

var float cumVol = 0.0
var float cumPV  = 0.0
var float cumVar = 0.0

if newSession
    cumVol     := 0
    cumPV      := 0
    cumVar     := 0
    state      := STATE_IDLE
    activeStop := na
    isLong     := false

cumVol += volume
typicalPrice = (high + low + close) / 3
cumPV  += typicalPrice * volume

var float vwap = 0.0
vwap := cumVol > 0 ? cumPV / cumVol : close

cumVar += volume * math.pow(typicalPrice - vwap, 2)
std     = cumVol > 0 and cumVar > 0 ? math.sqrt(cumVar / cumVol) : (high - low) / 2

upperBand = vwap + 2 * std
lowerBand = vwap - 2 * std

//=========================
// TIME FILTER
//=========================
startTime  = timestamp("America/New_York", year, month, dayofmonth, startHour, startMinute)
afterStart = time >= startTime

//=========================
// VWAP PROXIMITY
// Two separate calculations:
//   nearVWAP     — used during an active trade, directional via isLong
//   armNearVWAP  — used during the arm window, directional via touchDir
//=========================
nearVWAP_long  = high >= (vwap - vwapProximity * syminfo.mintick)
nearVWAP_short = low  <= (vwap + vwapProximity * syminfo.mintick)
nearVWAP       = (isLong and nearVWAP_long) or (not isLong and nearVWAP_short)

//=========================
// FRESH BAND TOUCH DETECTION
//=========================
freshTouchLower = low  <= lowerBand
freshTouchUpper = high >= upperBand

var int touchBar = na
var int touchDir = 0

if newSession
    touchBar := na
    touchDir := 0

if state == STATE_IDLE and afterStart and na(touchBar)
    if freshTouchLower and not freshTouchUpper
        touchBar := bar_index
        touchDir := 1
    else if freshTouchUpper and not freshTouchLower
        touchBar := bar_index
        touchDir := -1
    else if freshTouchLower and freshTouchUpper
        touchBar := bar_index
        touchDir := close < vwap ? 1 : -1

barsSinceTouch = na(touchBar) ? na : bar_index - touchBar

inArmWindow = not na(barsSinceTouch) and barsSinceTouch > 0 and barsSinceTouch <= armExpiry

//=========================
// ARM-WINDOW VWAP PROXIMITY
//=========================
armNearVWAP_long  = touchDir == 1  and high >= (vwap - vwapProximity * syminfo.mintick)
armNearVWAP_short = touchDir == -1 and low  <= (vwap + vwapProximity * syminfo.mintick)
armNearVWAP       = armNearVWAP_long or armNearVWAP_short

//=========================
// BODY LOGIC
//=========================
bodyCurr = math.abs(close - open)
bodyPrev = math.abs(close[1] - open[1])
bodyRef  = math.abs(close[2] - open[2])

bullish = close > open
bearish = close < open
bodyOK  = bodyCurr > bodyPrev

//=========================
// DOJI FILTER
//=========================
candleRange = high - low
isDoji      = candleRange > 0 ? (bodyCurr / candleRange) <= 0.10 : false
notDoji     = not isDoji

//=========================
// HAMMER / INVERTED HAMMER FILTER
//=========================
upperWick = high - math.max(close, open)
lowerWick = math.min(close, open) - low
wickRange = high - low

dominantPct = wickRange > 0 ? wickDominantPct / 100.0 : 1.0
oppositePct = wickRange > 0 ? wickOppositePct / 100.0 : 0.0

isHammer         = wickRange > 0 and (lowerWick / wickRange >= dominantPct) and (upperWick / wickRange <= oppositePct)
isInvertedHammer = wickRange > 0 and (upperWick / wickRange >= dominantPct) and (lowerWick / wickRange <= oppositePct)

notHammer         = not isHammer
notInvertedHammer = not isInvertedHammer

//=========================
// 2-CANDLE MOMENTUM
//=========================
twoBull = close > open and close[1] > open[1]
twoBear = close < open and close[1] < open[1]

bullMomentum = twoBull and (bodyCurr + bodyPrev > bodyRef)
bearMomentum = twoBear and (bodyCurr + bodyPrev > bodyRef)

//=========================
// VWAP LOCATION FILTER
//=========================
bullLocationOK = close < vwap
bearLocationOK = close > vwap

//=========================
// CLOSE PROGRESSION FILTERS
//=========================
longProgressOK  = close > close[1]
shortProgressOK = close < close[1]

//=========================
// MINIMUM VWAP DISTANCE FILTER
//=========================
minDistPoints     = minStdDist * std
closeDistToVWAP   = math.abs(close - vwap)
farEnoughFromVWAP = closeDistToVWAP >= minDistPoints

//=========================
// STOP LEVELS
//=========================
stopBufferPoints = stopBufferTicks * syminfo.mintick
longStop  = ta.lowest(low,   stopLookback) - stopBufferPoints
shortStop = ta.highest(high, stopLookback) + stopBufferPoints

//=========================
// EVENT FLAGS (reset each bar)
//=========================
var bool longSignal     = false
var bool shortSignal    = false
var bool resetTriggered = false
var bool stopTriggered  = false
var bool showNearVWAP   = false
var bool showProxVWAP   = false
var bool exitedThisBar  = false

longSignal     := false
shortSignal    := false
resetTriggered := false
stopTriggered  := false
showNearVWAP   := false
showProxVWAP   := false
exitedThisBar  := false

//=========================
// EXIT LOGIC (active trade only)
//=========================
if state == STATE_TRADE and not na(activeStop)
    longHit  =  isLong    and low  <= activeStop
    shortHit = not isLong and high >= activeStop

    if longHit or shortHit
        stopTriggered := true
        exitedThisBar := true
        state         := STATE_IDLE
        activeStop    := na
        isLong        := false

    else if nearVWAP
        resetTriggered := true
        exitedThisBar  := true
        if (isLong and high >= vwap) or (not isLong and low <= vwap)
            showNearVWAP := true
        else
            showProxVWAP := true
        state      := STATE_IDLE
        activeStop := na
        isLong     := false

//=========================
// STATE MACHINE
//=========================
if state == STATE_IDLE and inArmWindow and not exitedThisBar

    singleBull = bullish and bodyOK
    singleBear = bearish and bodyOK

    longSetupOK  = touchDir == 1  and bullLocationOK and (singleBull or bullMomentum) and longProgressOK  and notDoji and farEnoughFromVWAP and notInvertedHammer
    shortSetupOK = touchDir == -1 and bearLocationOK and (singleBear or bearMomentum) and shortProgressOK and notDoji and farEnoughFromVWAP and notHammer

    if longSetupOK
        longSignal := true
        isLong     := true
        state      := STATE_TRADE
        activeStop := longStop
        touchBar   := na
        touchDir   := 0

    else if shortSetupOK
        shortSignal := true
        isLong      := false
        state       := STATE_TRADE
        activeStop  := shortStop
        touchBar    := na
        touchDir    := 0

    else if armNearVWAP
        touchBar := na
        touchDir := 0

// Window expired with no signal — clean up
if not na(touchBar) and not na(barsSinceTouch) and barsSinceTouch > armExpiry
    touchBar := na
    touchDir := 0

//=========================
// PLOTS
//=========================
plot(vwap,      color=color.yellow, title="VWAP", linewidth=3)
plot(upperBand, color=color.red,    title="Upper 2σ", linewidth=2)
plot(lowerBand, color=color.green,  title="Lower 2σ", linewidth=2)

minDistUpper = vwap + minDistPoints
minDistLower = vwap - minDistPoints
plot(minDistUpper, color=color.new(color.yellow, 70), style=plot.style_line, title="Min Distance Upper (nσ)")
plot(minDistLower, color=color.new(color.yellow, 70), style=plot.style_line, title="Min Distance Lower (nσ)")

//=========================
// VWAP RIGHT-SIDE LABEL
//=========================
var label vwapLabel = na

if barstate.islast
    label.delete(vwapLabel)
    vwapLabel := label.new(
         bar_index + 2, vwap,
         "VWAP: " + str.tostring(vwap, format.mintick),
         xloc=xloc.bar_index,
         style=label.style_label_left,
         color=color.yellow,
         textcolor=color.black,
         size=size.small)

//=========================
// SIGNAL LABELS
//=========================
var label pendingLongLabel  = na
var label pendingShortLabel = na

// -- Confirmed bar: delete pending ...label, draw confirmed label
if barstate.isconfirmed
    if longSignal
        label.delete(pendingLongLabel)
        pendingLongLabel := na
        label.new(bar_index, low,
             "LONG\nSL: " + str.tostring(activeStop, format.mintick),
             style=label.style_label_up,
             color=color.green,
             textcolor=color.white)

    if shortSignal
        label.delete(pendingShortLabel)
        pendingShortLabel := na
        label.new(bar_index, high,
             "SHORT\nSL: " + str.tostring(activeStop, format.mintick),
             style=label.style_label_down,
             color=color.red,
             textcolor=color.white)

// -- Live bar: draw or refresh ...Long / ...Short
if barstate.islast
    if longSignal
        label.delete(pendingLongLabel)
        pendingLongLabel := label.new(bar_index, low,
             "...LONG\nSL: " + str.tostring(activeStop, format.mintick),
             style=label.style_label_up,
             color=color.new(color.green, 50),
             textcolor=color.white,
             size=size.normal)
    else
        label.delete(pendingLongLabel)
        pendingLongLabel := na

    if shortSignal
        label.delete(pendingShortLabel)
        pendingShortLabel := label.new(bar_index, high,
             "...SHORT\nSL: " + str.tostring(activeStop, format.mintick),
             style=label.style_label_down,
             color=color.new(color.red, 50),
             textcolor=color.white,
             size=size.normal)
    else
        label.delete(pendingShortLabel)
        pendingShortLabel := na

//=========================
// VISUAL MARKERS
//=========================

// 🔵 VWAP touch/cross exit
plotshape(showNearVWAP,
     title="VWAP Touch/Cross Exit",
     style=shape.labeldown,
     text="VWAP",
     location=location.abovebar,
     color=color.blue,
     textcolor=color.white,
     size=size.small)

// 🟠 Proximity exit
plotshape(showProxVWAP,
     title="Near VWAP Exit (Proximity Only)",
     style=shape.labeldown,
     text="~VWAP",
     location=location.abovebar,
     color=color.orange,
     textcolor=color.white,
     size=size.small)

// ❌ Stop hit
plotshape(stopTriggered,
     title="Stop Hit",
     style=shape.xcross,
     location=location.abovebar,
     color=color.red,
     size=size.normal)
````
