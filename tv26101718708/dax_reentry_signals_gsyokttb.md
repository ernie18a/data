# DAX ReEntry Signals

- url: https://www.tradingview.com/script/gsyOKTTB-DAX-ReEntry-Signals/
- type: indicator
- pine_id: PUB;13110a8984da4c5db784e64ebbd98790
- version: 1.0

## Description

DAX ReEntry Signals

DAX Re-Entry Signals
This indicator is tested on NASDAQ and is based on session trading range breakouts with re-entry confirmations.

Main features:

Identifies session high and overnight session low for a specified time range.

Detects price breakouts of at least X points (default: 30 points) outside the range, followed by a return inside.

Long signal: Price breaks at least X points below the overnight low, then closes back above it.

Short signal: Price breaks at least X points above the overnight high, then closes back below it.

Automatic TP and SL level plotting for each signal.

Tip: At the midpoint of the range, consider moving your stop to breakeven to lock in a risk-free trade.

Usage:

Ideal for time-based breakout–pullback strategies on DAX.

Works for both manual and algorithmic trading.

The “Minimum breakout distance” parameter lets you control how strict the signals are.

## Source Code

````pine
//@version=5
//Kepiro
indicator("DAX ReEntry Signals", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// --- Inputs ---
minBreakPoints = input.float(20.0, "Minimum breakout distance (points)", step=0.1)
tz = input.string("Europe/Budapest", "Timezone")

if not timeframe.isminutes or timeframe.multiplier != 5
    runtime.error("Ezt az indikátort 5 perces charton használd.")

// --- Date values in selected timezone ---
y = year(time, tz)
m = month(time, tz)
d = dayofmonth(time, tz)

// --- Entry window ---
entryStart = timestamp(tz, y, m, d, 10, 15)
entryEnd   = timestamp(tz, y, m, d, 15, 15)

// --- Variables ---
var float sessionHigh = na
var float sessionLow  = na
var float lastLow     = na
var float lastHigh    = na

var int rangeStartTime = na
var int rangeEndTime   = na

var bool rangeDrawnToday = false

var bool brokeLow      = false
var bool brokeHigh     = false
var bool longSignaled  = false
var bool shortSignaled = false

// --- Session checks ---
inSession   = not na(time(timeframe.period, "0935-1205", tz))
afterSession = not inSession and inSession[1]
entryWindow = time >= entryStart and time <= entryEnd

// --- New day reset ---
newDay = ta.change(dayofmonth(time, tz)) != 0

if newDay
    sessionHigh := na
    sessionLow  := na
    lastLow     := na
    lastHigh    := na
    rangeStartTime := na
    rangeEndTime   := na
    rangeDrawnToday := false
    brokeLow      := false
    brokeHigh     := false
    longSignaled  := false
    shortSignaled := false

// --- Build 09:35 - 12:05 range ---
if inSession
    if na(rangeStartTime)
        rangeStartTime := time

    rangeEndTime := time_close
    sessionHigh := na(sessionHigh) ? high : math.max(sessionHigh, high)
    sessionLow  := na(sessionLow) ? low : math.min(sessionLow, low)

// --- Draw range box once after 12:05 ---
if afterSession and not rangeDrawnToday and not na(sessionHigh) and not na(sessionLow)
    mid = (sessionHigh + sessionLow) / 2

    box.new(
         left=rangeStartTime,
         right=rangeEndTime,
         top=sessionHigh,
         bottom=sessionLow,
         xloc=xloc.bar_time,
         border_color=color.green,
         bgcolor=color.new(color.green, 80)
     )

    line.new(
         x1=rangeStartTime,
         y1=mid,
         x2=rangeEndTime,
         y2=mid,
         xloc=xloc.bar_time,
         color=color.green,
         style=line.style_dashed
     )

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
