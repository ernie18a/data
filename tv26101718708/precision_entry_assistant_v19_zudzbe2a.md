# Precision Entry Assistant v19

- url: https://www.tradingview.com/script/ZuDzbe2A-Precision-Entry-Assistant-v19/
- type: indicator
- pine_id: PUB;80de2acacdf940499f3ed2bd9beaf5b6
- version: 1.0

## Description

Precision Entry Assistant v19 is a clean execution tool built for ORB, VWAP, and session-based trading. It filters for stronger market states using VWAP slope, displacement, expansion, and chop control, then highlights potential long or short execution ideas during NY AM, Asia, and London sessions. It is designed to assist entries, not replace full trade planning.

## Source Code

````pine
//@version=6
indicator("Precision Entry Assistant v19 Clean Execution - Market State Filter", overlay=true, max_labels_count=300, max_lines_count=300, max_boxes_count=50)

// =====================
// SETTINGS
// =====================
tz = input.string("America/New_York", "Timezone")

nySession     = input.session("0930-1130", "NY AM Execution Session")
asiaSession   = input.session("1800-0000", "Asia Session")
londonSession = input.session("0200-0500", "London Session")
orbSession    = input.session("0930-1000", "ORB Window")

maxSignalsNY      = input.int(2, "Max NY Signals", minval=1, maxval=5)
maxSignalsOffSess = input.int(2, "Max Asia/London Signals", minval=1, maxval=5)

showORB       = input.bool(true, "Show ORB Box")
showVWAP      = input.bool(true, "Show VWAP")
showDashboard = input.bool(true, "Show Small Dashboard")

emaFastLen = input.int(9, "Fast EMA")
emaSlowLen = input.int(21, "Slow EMA")
atrLen     = input.int(14, "ATR Length")

cooldownBars = input.int(9, "Signal Cooldown Bars", minval=1)
targetATR    = input.float(1.35, "Single TP ATR Distance", step=0.05)

// Market State Filter
useMarketStateFilter = input.bool(true, "Use Market State Filter")
minVWAPSlopeMult     = input.float(0.10, "Min VWAP Slope Filter", step=0.01)
minBodyATR           = input.float(0.30, "Min Displacement Body ATR", step=0.05)
minRangeATR          = input.float(1.15, "Min 8-Bar Expansion ATR", step=0.05)
vwapAvoidATR         = input.float(0.15, "Avoid Flat VWAP Zone ATR", step=0.05)
chopLookback         = input.int(10, "Chop Lookback", minval=5)
minDirectionalClose  = input.float(55.0, "Min Directional Close %", minval=45, maxval=90)

// =====================
// COLORS
// =====================
green = color.rgb(22, 120, 70)
red   = color.rgb(150, 42, 42)
blue  = color.rgb(0, 90, 210)
gray  = color.rgb(90, 90, 90)

// =====================
// SESSIONS
// =====================
inNY     = not na(time(timeframe.period, nySession, tz))
inAsia   = not na(time(timeframe.period, asiaSession, tz))
inLondon = not na(time(timeframe.period, londonSession, tz))
inORB    = not na(time(timeframe.period, orbSession, tz))
inOff    = inAsia or inLondon

newDay = ta.change(time("D")) != 0

// =====================
// CORE INDICATORS
// =====================
vwap = ta.vwap(close)
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
atr = ta.atr(atrLen)

plot(showVWAP ? vwap : na, "VWAP", color=color.black, linewidth=2)

// =====================
// ORB
// =====================
var float orbHigh = na
var float orbLow = na
var bool orbLocked = false
var box orbBox = na

if newDay
    orbHigh := na
    orbLow := na
    orbLocked := false
    if not na(orbBox)
        box.delete(orbBox)

if inORB
    orbHigh := na(orbHigh) ? high : math.max(orbHigh, high)
    orbLow := na(orbLow) ? low : math.min(orbLow, low)

if not inORB and not orbLocked and not na(orbHigh) and not na(orbLow)
    orbLocked := true
    if showORB
        orbBox := box.new(bar_index, orbHigh, bar_index + 60, orbLow, border_color=color.new(blue, 10), bgcolor=color.new(blue, 92))

if showORB and orbLocked and not na(orbBox)
    box.set_right(orbBox, bar_index + 25)

// =====================
// MARKET STATE FILTER
// =====================
body = math.abs(close - open)
candleRange = high - low
range8 = ta.highest(high, 8) - ta.lowest(low, 8)

vwapSlope = math.abs(vwap - vwap[5])
strongVWAP = vwapSlope > atr * minVWAPSlopeMult

notCompressed = range8 > atr * minRangeATR
tooCloseVWAP = math.abs(close - vwap) < atr * vwapAvoidATR

closePosition = candleRange > 0 ? ((close - low) / candleRange) * 100 : 50
bullCloseStrong = closePosition >= minDirectionalClose
bearCloseStrong = closePosition <= 100 - minDirectionalClose

bullDisplacement = close > open and body > atr * minBodyATR and bullCloseStrong
bearDisplacement = close < open and body > atr * minBodyATR and bearCloseStrong

emaBull = emaFast > emaSlow
emaBear = emaFast < emaSlow

aboveVWAP = close > vwap
belowVWAP = close < vwap

// chop filter: if price keeps crossing VWAP/EMA, avoid it
vwapCrosses = 0
emaCrosses = 0

for i = 1 to chopLookback
    vwapCrosses += close[i] > vwap[i] and close[i + 1] < vwap[i + 1] ? 1 : 0
    vwapCrosses += close[i] < vwap[i] and close[i + 1] > vwap[i + 1] ? 1 : 0
    emaCrosses += emaFast[i] > emaSlow[i] and emaFast[i + 1] < emaSlow[i + 1] ? 1 : 0
    emaCrosses += emaFast[i] < emaSlow[i] and emaFast[i + 1] > emaSlow[i + 1] ? 1 : 0

notChoppy = vwapCrosses <= 3 and emaCrosses <= 2

marketReady =
     not useMarketStateFilter or
     (
         strongVWAP and
         notCompressed and
         not tooCloseVWAP and
         notChoppy
     )

// =====================
// ORB / RETEST LOGIC
// =====================
breakoutLong = orbLocked and close > orbHigh
breakoutShort = orbLocked and close < orbLow

retestLong = orbLocked and low <= orbHigh and close > orbHigh
retestShort = orbLocked and high >= orbLow and close < orbLow

vwapBounceLong = low <= vwap and close > vwap and close > open
vwapRejectShort = high >= vwap and close < vwap and close < open

sweepLow = low < ta.lowest(low[1], 8) and close > low
sweepHigh = high > ta.highest(high[1], 8) and close < high

// =====================
// SESSION COUNTS
// =====================
var int nyCount = 0
var int offCount = 0
var int lastSignalBar = na

newNY = inNY and not inNY[1]
newOff = inOff and not inOff[1]

if newNY
    nyCount := 0

if newOff
    offCount := 0

canFire = na(lastSignalBar) or bar_index - lastSignalBar > cooldownBars

// =====================
// SIGNAL LOGIC
// =====================
nyLong =
     inNY and
     nyCount < maxSignalsNY and
     canFire and
     marketReady and
     emaBull and
     aboveVWAP and
     bullDisplacement and
     (retestLong or vwapBounceLong or breakoutLong)

nyShort =
     inNY and
     nyCount < maxSignalsNY and
     canFire and
     marketReady and
     emaBear and
     belowVWAP and
     bearDisplacement and
     (retestShort or vwapRejectShort or breakoutShort)

offLong =
     inOff and
     offCount < maxSignalsOffSess and
     canFire and
     marketReady and
     bullDisplacement and
     aboveVWAP and
     (sweepLow or vwapBounceLong)

offShort =
     inOff and
     offCount < maxSignalsOffSess and
     canFire and
     marketReady and
     bearDisplacement and
     belowVWAP and
     (sweepHigh or vwapRejectShort)

longSignal = nyLong or offLong
shortSignal = nyShort or offShort

// =====================
// TARGETS
// =====================
longTP = close + atr * targetATR
shortTP = close - atr * targetATR

// =====================
// DRAW SIGNALS
// =====================
if longSignal
    label.new(bar_index, low, "LONG", style=label.style_label_up, color=green, textcolor=color.white, size=size.small)
    line.new(bar_index, longTP, bar_index + 18, longTP, style=line.style_dotted, color=color.new(green, 25), width=1)
    label.new(bar_index + 18, longTP, "●", style=label.style_none, textcolor=green, size=size.normal)
    lastSignalBar := bar_index
    if inNY
        nyCount += 1
    if inOff
        offCount += 1

if shortSignal
    label.new(bar_index, high, "SHORT", style=label.style_label_down, color=red, textcolor=color.white, size=size.small)
    line.new(bar_index, shortTP, bar_index + 18, shortTP, style=line.style_dotted, color=color.new(red, 25), width=1)
    label.new(bar_index + 18, shortTP, "●", style=label.style_none, textcolor=red, size=size.normal)
    lastSignalBar := bar_index
    if inNY
        nyCount += 1
    if inOff
        offCount += 1

// =====================
// DASHBOARD
// =====================
biasText = emaBull and aboveVWAP ? "LONG" : emaBear and belowVWAP ? "SHORT" : "MIXED"
sessionText = inNY ? "NY" : inAsia ? "ASIA" : inLondon ? "LONDON" : "OFF"
vwapText = aboveVWAP ? "ABOVE" : belowVWAP ? "BELOW" : "MID"
stateText = marketReady ? "READY" : "FILTER"

var table dash = table.new(position.top_right, 2, 4, bgcolor=color.new(color.black, 70))

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "Bias", text_color=color.white, bgcolor=color.new(gray, 20), text_size=size.tiny)
    table.cell(dash, 1, 0, biasText, text_color=color.white, bgcolor=color.new(gray, 55), text_size=size.tiny)

    table.cell(dash, 0, 1, "Session", text_color=color.white, bgcolor=color.new(gray, 20), text_size=size.tiny)
    table.cell(dash, 1, 1, sessionText, text_color=color.white, bgcolor=color.new(gray, 55), text_size=size.tiny)

    table.cell(dash, 0, 2, "VWAP", text_color=color.white, bgcolor=color.new(gray, 20), text_size=size.tiny)
    table.cell(dash, 1, 2, vwapText, text_color=color.white, bgcolor=color.new(gray, 55), text_size=size.tiny)

    table.cell(dash, 0, 3, "State", text_color=color.white, bgcolor=color.new(gray, 20), text_size=size.tiny)
    table.cell(dash, 1, 3, stateText, text_color=color.white, bgcolor=color.new(gray, 55), text_size=size.tiny)

// =====================
// ALERTS
// =====================
alertcondition(longSignal, title="Precision LONG", message="Precision Entry Assistant LONG")
alertcondition(shortSignal, title="Precision SHORT", message="Precision Entry Assistant SHORT")
````
