<!-- tradingview-pine-id: PUB;412e96eae77e42269b547df599601eba -->
<!-- tradingviewscripts-format: 1 -->
# 09:30 Candle ATR % (5m + 15m)

Source: https://www.tradingview.com/script/d9NX3GZq-ATR-THRESHOLD/

## Description

ATR indicator designed for the 15m chart to show the atr of that candle reflection on the daily overall atr.

---

## Source Code

````pine
//@version=6
indicator("09:30 Candle ATR % (5m + 15m)", overlay=true, max_labels_count=500, max_boxes_count=500)

// ---------- Inputs ----------
atrLength   = input.int(14, "Daily ATR Length", minval=1)
refTz       = input.string("UTC-3", "Reference Timezone", options=["UTC-3", "America/New_York", "UTC+0", "Europe/London"])
targetHour  = input.int(9, "Target Hour", minval=0, maxval=23)
targetMin   = input.int(30, "Target Minute", minval=0, maxval=59)
showBox     = input.bool(true, "Show Range Box")
showLabel   = input.bool(true, "Show ATR % Label")
keepHistory = input.bool(true, "Keep Historical Objects")
threshold   = input.float(25.0, "ATR % Threshold", step=0.1)

// ---------- Timeframe checks ----------
is5m  = timeframe.period == "5"
is15m = timeframe.period == "15"

// ---------- Daily ATR ----------
dailyATR = request.security(syminfo.tickerid, "D", ta.atr(atrLength), barmerge.gaps_off, barmerge.lookahead_off)

// ---------- Session string ----------
endMinRaw = targetMin + 15
endHour   = targetHour + math.floor(endMinRaw / 60)
endMin    = endMinRaw % 60
endHourClamped = endHour % 24

pad(n) => str.tostring(n, "00")
sessionStr = pad(targetHour) + pad(targetMin) + "-" + pad(endHourClamped) + pad(endMin)

// ---------- Detect selected 15m window in chosen timezone ----------
inWindow = not na(time(timeframe.period, sessionStr, refTz))

// ---------- Storage ----------
var float winHigh = na
var float winLow = na
var int startBar = na
var int endBar = na
var bool building = false

var box[] boxes = array.new_box()
var label[] labels = array.new_label()

deleteLastObjects() =>
    if array.size(boxes) > 0
        b = array.get(boxes, array.size(boxes) - 1)
        box.delete(b)
        array.pop(boxes)
    if array.size(labels) > 0
        l = array.get(labels, array.size(labels) - 1)
        label.delete(l)
        array.pop(labels)

// ---------- 5m logic ----------
if is5m
    if inWindow and not inWindow[1]
        winHigh := high
        winLow  := low
        startBar := bar_index
        endBar := bar_index
        building := true

    else if building and inWindow
        winHigh := math.max(winHigh, high)
        winLow  := math.min(winLow, low)
        endBar := bar_index

    if building and not inWindow and inWindow[1]
        candleRange = winHigh - winLow
        atrPercent = dailyATR > 0 ? (candleRange / dailyATR) * 100.0 : na

        fillCol   = atrPercent >= threshold ? color.new(color.green, 82) : color.new(color.red, 82)
        borderCol = atrPercent >= threshold ? color.green : color.red

        if not keepHistory
            deleteLastObjects()

        if showBox
            b = box.new(startBar, winHigh, endBar, winLow, bgcolor=fillCol, border_color=borderCol)
            array.push(boxes, b)

        if showLabel and not na(atrPercent)
            txt = "09:30 ATR: " + str.tostring(atrPercent, "#.##") + "%"
            l = label.new(endBar, winHigh, txt, style=label.style_label_down, color=color.black, textcolor=color.white)
            array.push(labels, l)

        building := false

// ---------- 15m logic ----------
if is15m and inWindow
    candleRange = high - low
    atrPercent = dailyATR > 0 ? (candleRange / dailyATR) * 100.0 : na

    fillCol   = atrPercent >= threshold ? color.new(color.green, 82) : color.new(color.red, 82)
    borderCol = atrPercent >= threshold ? color.green : color.red

    if not keepHistory
        deleteLastObjects()

    if showBox
        b = box.new(bar_index, high, bar_index, low, bgcolor=fillCol, border_color=borderCol)
        array.push(boxes, b)

    if showLabel and not na(atrPercent)
        txt = "09:30 ATR: " + str.tostring(atrPercent, "#.##") + "%"
        l = label.new(bar_index, high, txt, style=label.style_label_down, color=color.black, textcolor=color.white)
        array.push(labels, l)

if barstate.islast and not is5m and not is15m
    label.new(bar_index, high, "Use on 5m or 15m only", style=label.style_label_down, color=color.red, textcolor=color.white)
````
