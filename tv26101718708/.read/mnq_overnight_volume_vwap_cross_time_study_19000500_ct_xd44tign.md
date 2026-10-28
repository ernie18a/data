# MNQ Overnight Volume + VWAP Cross Time Study (19:00-05:00 CT)

- url: https://www.tradingview.com/script/XD44tIgN-MNQ-Overnight-Volume-VWAP-Cross-Time-Study-19-00-05-00-CT/
- type: indicator
- pine_id: PUB;fec19a9f600746a69704510a60e63842
- version: 1.0

## Description

Analyzes MNQ overnight trading from 19:00 to 05:00 Central Time by measuring hourly volume and counting VWAP crosses to identify which overnight hour has the highest volume and which hour price crosses VWAP most often.

## Source Code

````pine
//@version=6
indicator("MNQ Overnight Volume + VWAP Cross Time Study (19:00-05:00 CT)", overlay=true, max_labels_count=500)

// =====================================================
// INPUTS
// =====================================================
tz = input.string("America/Chicago", "Timezone")
sess = input.session("1900-0459", "Overnight Session")
crossMode = input.string("Close Cross", "VWAP Cross Type", options=["Close Cross", "Intrabar Cross"])
showTable = input.bool(true, "Show Summary Table")
showSessionBg = input.bool(true, "Highlight Session")
showCrossLabels = input.bool(false, "Show Cross Labels")
showVWAP = input.bool(true, "Plot VWAP")

// =====================================================
// CORE SERIES
// =====================================================
vwapValue = ta.vwap
plot(showVWAP ? vwapValue : na, "VWAP", color=color.orange, linewidth=2)

// Session detection using Pine's time(session, timezone) behavior
inSess = not na(time(timeframe.period, sess + ":1234567", tz))
newSess = inSess and not inSess[1]
endSess = not inSess and inSess[1]

bgcolor(showSessionBg and inSess ? color.new(color.blue, 92) : na)

// =====================================================
// HELPERS
// =====================================================
f_hourBucket(_h) =>
    // Maps Central-time hour to bucket index
    // 19 -> 0, 20 -> 1, 21 -> 2, 22 -> 3, 23 -> 4
    // 00 -> 5, 01 -> 6, 02 -> 7, 03 -> 8, 04 -> 9
    _h == 19 ? 0 :
     _h == 20 ? 1 :
     _h == 21 ? 2 :
     _h == 22 ? 3 :
     _h == 23 ? 4 :
     _h == 0  ? 5 :
     _h == 1  ? 6 :
     _h == 2  ? 7 :
     _h == 3  ? 8 :
     _h == 4  ? 9 : -1

f_bucketLabel(_i) =>
    _i == 0 ? "19:00" :
     _i == 1 ? "20:00" :
     _i == 2 ? "21:00" :
     _i == 3 ? "22:00" :
     _i == 4 ? "23:00" :
     _i == 5 ? "00:00" :
     _i == 6 ? "01:00" :
     _i == 7 ? "02:00" :
     _i == 8 ? "03:00" :
     _i == 9 ? "04:00" : "n/a"

f_pad2(_n) =>
    _n < 10 ? "0" + str.tostring(_n) : str.tostring(_n)

// =====================================================
// ARRAYS FOR HOURLY STATS
// =====================================================
var volByHour = array.new_float(10, 0.0)
var crossByHour = array.new_int(10, 0)
var sessionsTouchingHour = array.new_int(10, 0)

// Count each session's participation in each hour only once
var touchedThisSession = array.new_bool(10, false)

if newSess
    for i = 0 to 9
        array.set(touchedThisSession, i, false)

// =====================================================
// HOURLY BUCKETING
// =====================================================
ctHour = hour(time, tz)
bucket = f_hourBucket(ctHour)

if inSess and bucket >= 0
    // volume accumulation
    prevVol = array.get(volByHour, bucket)
    array.set(volByHour, bucket, prevVol + volume)

    // sessions touching this hour
    if not array.get(touchedThisSession, bucket)
        array.set(touchedThisSession, bucket, true)
        prevSessCount = array.get(sessionsTouchingHour, bucket)
        array.set(sessionsTouchingHour, bucket, prevSessCount + 1)

// =====================================================
// VWAP CROSS LOGIC
// =====================================================
closeCrossUp = close[1] < vwapValue[1] and close > vwapValue
closeCrossDn = close[1] > vwapValue[1] and close < vwapValue
closeCross = closeCrossUp or closeCrossDn

intrabarCross = low <= vwapValue and high >= vwapValue

didCross = crossMode == "Close Cross" ? closeCross : intrabarCross

if inSess and bucket >= 0 and didCross
    prevCross = array.get(crossByHour, bucket)
    array.set(crossByHour, bucket, prevCross + 1)

    if showCrossLabels
        label.new(
             bar_index,
             high,
             text="VWAP Cross\n" + f_bucketLabel(bucket),
             style=label.style_label_down,
             color=color.new(color.purple, 0),
             textcolor=color.white
         )

plotshape(inSess and didCross, title="VWAP Cross", style=shape.circle, location=location.abovebar, color=color.new(color.purple, 0), size=size.tiny)

// =====================================================
// SESSION COUNT
// =====================================================
var int sessionsTested = 0
if newSess
    sessionsTested += 1

// =====================================================
// FIND BEST HOUR
// =====================================================
var float maxVol = na
var int maxVolIdx = na
var int maxCross = na
var int maxCrossIdx = na

maxVol := array.get(volByHour, 0)
maxVolIdx := 0
maxCross := array.get(crossByHour, 0)
maxCrossIdx := 0

for i = 1 to 9
    thisVol = array.get(volByHour, i)
    thisCross = array.get(crossByHour, i)

    if thisVol > maxVol
        maxVol := thisVol
        maxVolIdx := i

    if thisCross > maxCross
        maxCross := thisCross
        maxCrossIdx := i

// =====================================================
// TABLE
// =====================================================
var table t = table.new(position.top_right, 5, 14, border_width=1)

if barstate.islast and showTable
    table.cell(t, 0, 0, "Hour", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 0, "Total Vol", text_color=color.white, bgcolor=color.black)
    table.cell(t, 2, 0, "VWAP Crosses", text_color=color.white, bgcolor=color.black)
    table.cell(t, 3, 0, "Sessions", text_color=color.white, bgcolor=color.black)
    table.cell(t, 4, 0, "Avg Vol/Session", text_color=color.white, bgcolor=color.black)

    for i = 0 to 9
        hourLabel = f_bucketLabel(i)
        totalVol = array.get(volByHour, i)
        totalCross = array.get(crossByHour, i)
        sessCount = array.get(sessionsTouchingHour, i)
        avgVol = sessCount > 0 ? totalVol / sessCount : na

        rowBg = i == maxVolIdx ? color.new(color.green, 80) : i == maxCrossIdx ? color.new(color.orange, 82) : na

        table.cell(t, 0, i + 1, hourLabel, bgcolor=rowBg)
        table.cell(t, 1, i + 1, str.tostring(totalVol, "#"), bgcolor=rowBg)
        table.cell(t, 2, i + 1, str.tostring(totalCross), bgcolor=rowBg)
        table.cell(t, 3, i + 1, str.tostring(sessCount), bgcolor=rowBg)
        table.cell(t, 4, i + 1, str.tostring(avgVol, "#.##"), bgcolor=rowBg)

    table.cell(t, 0, 11, "Best Vol Hour", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 11, f_bucketLabel(maxVolIdx))
    table.cell(t, 2, 11, "Best Cross Hour", text_color=color.white, bgcolor=color.black)
    table.cell(t, 3, 11, f_bucketLabel(maxCrossIdx))

    table.cell(t, 0, 12, "Sessions Tested", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 12, str.tostring(sessionsTested))
    table.cell(t, 2, 12, "Cross Type", text_color=color.white, bgcolor=color.black)
    table.cell(t, 3, 12, crossMode)

    table.cell(t, 0, 13, "Session", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 13, "19:00-04:59 CT")
    table.cell(t, 2, 13, "Chart TF", text_color=color.white, bgcolor=color.black)
    table.cell(t, 3, 13, timeframe.period)
````
