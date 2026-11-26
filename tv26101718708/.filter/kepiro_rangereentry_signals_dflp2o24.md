# Kepiro RangeReEntry Signals

- url: https://www.tradingview.com/script/DFlP2o24-Kepiro-RangeReEntry-Signals/
- type: indicator
- pine_id: PUB;26b9d0bb18ff49f9acc12d245a7e2a4a
- version: 2.0

## Description

Kepiro Range Re-Entry Signals
This indicator is tested on NASDAQ and is based on overnight trading range breakouts with re-entry confirmations.

Main features:

Identifies overnight session high and overnight session low for a specified time range.

Detects price breakouts of at least X points (default: 20 points) outside the range, followed by a return inside.

Long signal: Price breaks at least X points below the overnight low, then closes back above it.

Short signal: Price breaks at least X points above the overnight high, then closes back below it.

Automatic TP and SL level plotting for each signal.

Tip: At the midpoint of the range, consider moving your stop to breakeven to lock in a risk-free trade.

Usage:

Ideal for time-based breakout–pullback strategies on NASDAQ.

Works for both manual and algorithmic trading.

The “Minimum breakout distance” parameter lets you control how strict the signals are.

## Source Code

````pine
//@version=5
//Kepiro
indicator("Kepiro RangeReEntry Signals", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// --- Inputs ---
minBreakPoints = input.float(20.0, "Minimum breakout distance (points)", step=0.1)
tz = input.string("Europe/Budapest", "Timezone")

// --- Date values in selected timezone ---
y = year(time, tz)
m = month(time, tz)
d = dayofmonth(time, tz)

// --- Range box settings ---
startSession = timestamp(tz, y, m, d, 0, 0)
endSession   = timestamp(tz, y, m, d, 10, 0)

// --- Entry window ---
entryStart = timestamp(tz, y, m, d, 10, 15)
entryEnd   = timestamp(tz, y, m, d, 15, 15)

// --- Variables ---
var float sessionHigh = na
var float sessionLow  = na
var float lastLow     = na
var float lastHigh    = na

var bool rangeDrawnToday = false

var bool brokeLow      = false
var bool brokeHigh     = false
var bool longSignaled  = false
var bool shortSignaled = false

// --- Session checks ---
inSession    = time >= startSession and time < endSession
afterSession = time >= endSession
entryWindow  = time >= entryStart and time <= entryEnd

// --- New day reset ---
newDay = ta.change(time("D")) != 0

if newDay
    sessionHigh := na
    sessionLow  := na
    lastLow     := na
    lastHigh    := na
    rangeDrawnToday := false
    brokeLow      := false
    brokeHigh     := false
    longSignaled  := false
    shortSignaled := false

// --- Build 00:00 - 10:00 range ---
if inSession
    sessionHigh := na(sessionHigh) ? high : math.max(sessionHigh, high)
    sessionLow  := na(sessionLow) ? low : math.min(sessionLow, low)

// --- Draw range box once after 10:00 ---
if afterSession and not rangeDrawnToday and not na(sessionHigh) and not na(sessionLow)
    mid = (sessionHigh + sessionLow) / 2
    box.new(left=startSession, right=endSession, top=sessionHigh, bottom=sessionLow, xloc=xloc.bar_time, border_color=color.green, bgcolor=color.new(color.green, 80))
    line.new(x1=startSession, y1=mid, x2=endSession, y2=mid, xloc=xloc.bar_time, color=color.green, style=line.style_dashed)
    lastLow  := sessionLow
    lastHigh := sessionHigh
    rangeDrawnToday := true

// --- Entry signal logic ---
if not na(lastLow) and not na(lastHigh)
    if entryWindow
        rangeSize = lastHigh - lastLow

        // Long setup: break below range low, then return above range low
        if not brokeLow and low < lastLow - minBreakPoints
            brokeLow := true

        if brokeLow and close > lastLow and not longSignaled
            longTp = lastHigh
            longSl = lastLow - rangeSize * 0.454
            label.new(bar_index, low, "Long", style=label.style_label_up, color=color.green, textcolor=color.white)
            line.new(x1=bar_index, y1=longTp, x2=bar_index + 10, y2=longTp, color=color.green, style=line.style_dotted)
            line.new(x1=bar_index, y1=longSl, x2=bar_index + 10, y2=longSl, color=color.red, style=line.style_dotted)
            longSignaled := true

        // Short setup: break above range high, then return below range high
        if not brokeHigh and high > lastHigh + minBreakPoints
            brokeHigh := true

        if brokeHigh and close < lastHigh and not shortSignaled
            shortTp = lastLow
            shortSl = lastHigh + rangeSize * 0.454
            label.new(bar_index, high, "Short", style=label.style_label_down, color=color.orange, textcolor=color.white)
            line.new(x1=bar_index, y1=shortTp, x2=bar_index + 10, y2=shortTp, color=color.green, style=line.style_dotted)
            line.new(x1=bar_index, y1=shortSl, x2=bar_index + 10, y2=shortSl, color=color.red, style=line.style_dotted)
            shortSignaled := true

// --- Hidden plots, only for data-window/reference ---
plot(lastHigh, "Last Range High", color=color.new(color.green, 100))
plot(lastLow, "Last Range Low", color=color.new(color.red, 100))
````
