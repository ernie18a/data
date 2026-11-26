# NZ 1:30AM Range Tool 

- url: https://www.tradingview.com/script/F6e9JJ7M-NZ-1-30AM-Range-Tool/
- type: indicator
- pine_id: PUB;f892222fe25c497692877115cbf6e15f
- version: 1.0

## Description

handmade specificity for the 15m orb strategy designed to execute with these certain levels

## Source Code

````pine
//@version=5
indicator("NZ 1:30AM Range Tool (Clean)", overlay=true, max_lines_count=500, max_labels_count=500)

//────────────────────────────
// TIMEZONE
//────────────────────────────
tz = "Pacific/Auckland"

//────────────────────────────
// SETTINGS
//────────────────────────────
highColor = input.color(color.rgb(0, 0, 0), "High Color")
lowColor  = input.color(color.rgb(0, 0, 0), "Low Color")
midColor  = input.color(color.rgb(10, 214, 250), "Mid Color")

highWidth = input.int(1, "High Width", 1, 5)
lowWidth  = input.int(1, "Low Width", 1, 5)
midWidth  = input.int(1, "Mid Width", 1, 5)

showMid   = input.bool(true, "Show Midpoint")
showText  = input.bool(true, "Show Labels")

//────────────────────────────
// 15m DATA
//────────────────────────────
htfTime = request.security(syminfo.tickerid, "15", time)
htfHigh = request.security(syminfo.tickerid, "15", high)
htfLow  = request.security(syminfo.tickerid, "15", low)

//────────────────────────────
// OBJECTS
//────────────────────────────
var line highLine = na
var line lowLine  = na
var line midLine  = na

var label highLabel = na
var label lowLabel  = na
var label midLabel  = na

//────────────────────────────
// DETECT 1:30 AM CANDLE
//────────────────────────────
is130 = hour(htfTime, tz) == 1 and minute(htfTime, tz) == 30
newBar = ta.change(htfTime)

//────────────────────────────
// LOGIC
//────────────────────────────
if newBar and is130

    hi = htfHigh
    lo = htfLow
    mid = (hi + lo) / 2

    startTime = htfTime

    endTime = timestamp(tz, year(htfTime, tz), month(htfTime, tz), dayofmonth(htfTime, tz), 9, 0)

    // Delete old drawings
    if not na(highLine)
        line.delete(highLine)
    if not na(lowLine)
        line.delete(lowLine)
    if not na(midLine)
        line.delete(midLine)

    if not na(highLabel)
        label.delete(highLabel)
    if not na(lowLabel)
        label.delete(lowLabel)
    if not na(midLabel)
        label.delete(midLabel)

    // HIGH
    highLine := line.new(startTime, hi, endTime, hi, xloc=xloc.bar_time, color=highColor, width=highWidth)

    // LOW
    lowLine := line.new(startTime, lo, endTime, lo, xloc=xloc.bar_time, color=lowColor, width=lowWidth)

    // MID
    if showMid
        midLine := line.new(startTime, mid, endTime, mid, xloc=xloc.bar_time, color=midColor, width=midWidth, style=line.style_dashed)

    // LABELS
    if showText
        highLabel := label.new(endTime, hi, "ORD HIGH", xloc=xloc.bar_time, color=highColor, textcolor=color.white)
        lowLabel  := label.new(endTime, lo, "ORD LOW", xloc=xloc.bar_time, color=lowColor, textcolor=color.white)
        midLabel  := label.new(endTime, mid, "MID POINT", xloc=xloc.bar_time, color=midColor, textcolor=color.white)
````
