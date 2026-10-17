# Precision ORB Clean v12 - 5M

- url: https://www.tradingview.com/script/yUsf6E05-Precision-ORB-Clean-v12-5M/
- type: indicator
- pine_id: PUB;4be92a4384334301ab1d4dcbe1bae85c
- version: 1.0

## Description

5 min opening range. Use on 5min ES chart. Still tweaking TP

## Source Code

````pine
//@version=6
indicator("Precision ORB Clean v12 - 5M", overlay=true, max_labels_count=300, max_lines_count=300, max_boxes_count=50)

// === SETTINGS ===
tz = input.string("America/New_York", "Timezone")
useBodyRange = input.bool(true, "Use Candle Body ORB")

thursdayMode = input.string("Warn", "Thursday Mode", options=["Normal", "Warn", "Strict", "Disable"])

minBreakPoints = input.float(0.25, "Minimum Break Distance", step=0.25)
closeStrengthPct = input.float(55.0, "Close Strength %", minval=50, maxval=95)

thursdayBreakMultiplier = input.float(1.5, "Thursday Break Multiplier", step=0.25)
thursdayCloseStrengthAdd = input.float(10.0, "Thursday Extra Close Strength %", step=1.0)

swingLen = input.int(2, "Swing Pivot Strength", minval=1, maxval=10)
maxSwingLookback = input.int(75, "Swing Lookback Bars", minval=25, maxval=300)

minTargetR = input.float(0.25, "Minimum Target R", step=0.25)
maxTargetR = input.float(3.0, "Maximum Target R", step=0.25)

tp1R = input.float(1.0, "Fallback TP1 R", step=0.25)
tp2R = input.float(2.0, "Fallback TP2 R", step=0.25)

targetBars = input.int(24, "Target Line Length", minval=10, maxval=100)

// === TIME ===
hr = hour(time, tz)
mn = minute(time, tz)

isOpenBar = hr == 9 and mn == 30
tradeWindow = (hr > 9 or (hr == 9 and mn >= 35)) and hr < 11
activeSession = hr >= 9 and hr <= 13
newDay = dayofmonth != dayofmonth[1]

isThursday = dayofweek == dayofweek.thursday
thursdayBlocked = thursdayMode == "Disable" and isThursday
thursdayStrict = thursdayMode == "Strict" and isThursday

breakNeeded = thursdayStrict ? minBreakPoints * thursdayBreakMultiplier : minBreakPoints
closeStrengthNeeded = thursdayStrict ? closeStrengthPct + thursdayCloseStrengthAdd : closeStrengthPct

// === VARIABLES ===
var float orbHigh = na
var float orbLow = na
var bool rangeSet = false
var bool signalDone = false

var box orbBox = na
var label orbText = na

if newDay
    orbHigh := na
    orbLow := na
    rangeSet := false
    signalDone := false
    orbBox := na
    orbText := na

// === 5M OPENING RANGE ===
if isOpenBar
    bodyHigh = math.max(open, close)
    bodyLow = math.min(open, close)

    orbHigh := useBodyRange ? bodyHigh : high
    orbLow := useBodyRange ? bodyLow : low
    rangeSet := true

    orbBox := box.new(
         left=bar_index,
         top=orbHigh,
         right=bar_index,
         bottom=orbLow,
         bgcolor=color.new(color.rgb(20, 105, 255), 90),
         border_color=color.new(color.rgb(20, 105, 255), 60))

    orbText := label.new(
         bar_index,
         (orbHigh + orbLow) / 2,
         "OR",
         style=label.style_none,
         textcolor=color.new(color.rgb(20, 105, 255), 20),
         size=size.tiny)

    if isThursday and thursdayMode != "Normal"
        label.new(
             bar_index,
             orbHigh,
             "⚠",
             style=label.style_label_down,
             color=color.new(color.orange, 80),
             textcolor=color.rgb(130, 70, 0),
             size=size.tiny)

if rangeSet and activeSession and not na(orbBox)
    box.set_right(orbBox, bar_index)

if rangeSet and activeSession and not na(orbText)
    label.set_x(orbText, math.round((box.get_left(orbBox) + box.get_right(orbBox)) / 2))
    label.set_y(orbText, (orbHigh + orbLow) / 2)

// === CLOSE STRENGTH ===
barRange = high - low
closePos = barRange > 0 ? ((close - low) / barRange) * 100 : 50

bullStrong = closePos >= closeStrengthNeeded
bearStrong = closePos <= (100 - closeStrengthNeeded)

// === SIGNALS ===
buySignal =
     rangeSet and
     tradeWindow and
     not signalDone and
     not thursdayBlocked and
     close > orbHigh and
     close - orbHigh >= breakNeeded and
     bullStrong

sellSignal =
     rangeSet and
     tradeWindow and
     not signalDone and
     not thursdayBlocked and
     close < orbLow and
     orbLow - close >= breakNeeded and
     bearStrong

// === SWING TARGET LOGIC ===
pivotHigh = ta.pivothigh(high, swingLen, swingLen)
pivotLow = ta.pivotlow(low, swingLen, swingLen)

findBuyTP(_entry, _risk, _targetNumber) =>
    fallback = _entry + _risk * (_targetNumber == 1 ? tp1R : tp2R)

    minPrice = _entry + _risk * minTargetR
    maxPrice = _entry + _risk * maxTargetR

    float first = na
    float second = na

    for i = swingLen to maxSwingLookback
        ph = pivotHigh[i]

        if not na(ph) and ph >= minPrice and ph <= maxPrice
            if na(first) or ph < first
                second := first
                first := ph
            else if ph > first and (na(second) or ph < second)
                second := ph

    result = _targetNumber == 1 ? first : second
    na(result) ? fallback : result

findSellTP(_entry, _risk, _targetNumber) =>
    fallback = _entry - _risk * (_targetNumber == 1 ? tp1R : tp2R)

    maxPrice = _entry - _risk * minTargetR
    minPrice = _entry - _risk * maxTargetR

    float first = na
    float second = na

    for i = swingLen to maxSwingLookback
        pl = pivotLow[i]

        if not na(pl) and pl <= maxPrice and pl >= minPrice
            if na(first) or pl > first
                second := first
                first := pl
            else if pl < first and (na(second) or pl > second)
                second := pl

    result = _targetNumber == 1 ? first : second
    na(result) ? fallback : result

// === DRAW TARGETS ===
drawTargets(_tp1, _tp2) =>
    tpColor = color.rgb(20, 105, 255)

    line.new(bar_index, _tp1, bar_index + targetBars, _tp1, color=tpColor, width=2, style=line.style_dotted)
    line.new(bar_index, _tp2, bar_index + targetBars, _tp2, color=tpColor, width=2, style=line.style_dotted)

    label.new(bar_index + targetBars, _tp1, "TP1 ●", style=label.style_label_left, color=color.new(color.blue, 100), textcolor=tpColor)
    label.new(bar_index + targetBars, _tp2, "TP2 ●", style=label.style_label_left, color=color.new(color.blue, 100), textcolor=tpColor)

// === BUY ===
if buySignal
    signalDone := true

    entry = close
    stop = orbLow
    risk = entry - stop

    tp1 = findBuyTP(entry, risk, 1)
    tp2 = findBuyTP(entry, risk, 2)

    if tp2 <= tp1
        tp2 := entry + risk * tp2R

    label.new(bar_index, low, "BUY", style=label.style_label_up, color=color.rgb(20, 95, 230), textcolor=color.white)
    drawTargets(tp1, tp2)

// === SELL ===
if sellSignal
    signalDone := true

    entry = close
    stop = orbHigh
    risk = stop - entry

    tp1 = findSellTP(entry, risk, 1)
    tp2 = findSellTP(entry, risk, 2)

    if tp2 >= tp1
        tp2 := entry - risk * tp2R

    label.new(bar_index, high, "SELL", style=label.style_label_down, color=color.rgb(230, 120, 25), textcolor=color.white)
    drawTargets(tp1, tp2)

// === PLOTS ===
show = rangeSet and activeSession

plot(show ? orbHigh : na, "ORB High", color=color.rgb(20, 105, 255), linewidth=2, style=plot.style_linebr)
plot(show ? orbLow : na, "ORB Low", color=color.rgb(20, 105, 255), linewidth=2, style=plot.style_linebr)

// === ALERTS ===
alertcondition(buySignal, title="Precision ORB 5M BUY", message="Precision ORB 5M BUY")
alertcondition(sellSignal, title="Precision ORB 5M SELL", message="Precision ORB 5M SELL")
````
