# RTH and AH Vertical Breaks

- url: https://www.tradingview.com/script/69Ayx7kM-RTH-and-AH-Vertical-Breaks/
- type: indicator
- pine_id: PUB;89ebf7f3178149bcb16028ba125fc743
- version: 1.0

## Description

Auto deleting and time zone customizable vertical markings for RTH and AH sessions. will only show the relevant session break for the session you are in. During RTH, it will show you the line for when the RTH market closes. when RTH ends, and AH begins, the previous RTH line disappear, and the line representing the end of AH appears.

## Source Code

````pine
//@version=5
indicator("RTH and AH Vertical Breaks", overlay=true, max_lines_count=10)

// ===== Inputs =====
tzInput      = input.string("America/New_York", "Timezone")
openHour     = input.int(9, "Market Open Hour", minval=0, maxval=23)
openMinute   = input.int(30, "Market Open Minute", minval=0, maxval=59)
closeHour    = input.int(16, "Market Close Hour", minval=0, maxval=23)
closeMinute  = input.int(0, "Market Close Minute", minval=0, maxval=59)
lineColor    = input.color(color.red, "Line Color")
lineWidth    = input.int(1, "Line Width", minval=1, maxval=5)

// ===== Time values in chosen timezone =====
yr   = year(time, tzInput)
mo   = month(time, tzInput)
dy   = dayofmonth(time, tzInput)
dow  = dayofweek(time, tzInput)

todayOpen  = timestamp(tzInput, yr, mo, dy, openHour, openMinute)
todayClose = timestamp(tzInput, yr, mo, dy, closeHour, closeMinute)

inSession = time >= todayOpen and time < todayClose

int targetTime = na

if inSession
    targetTime := todayClose
else
    if time < todayOpen
        targetTime := todayOpen
    else
        int addDays = 1
        if dow == dayofweek.friday
            addDays := 3
        else if dow == dayofweek.saturday
            addDays := 2
        else
            addDays := 1

        targetTime := timestamp(tzInput, yr, mo, dy + addDays, openHour, openMinute)

var line activeLine = na

if barstate.islast
    if not na(activeLine)
        line.delete(activeLine)

    float y1 = low
    float y2 = high

    activeLine := line.new(
         x1 = targetTime,
         y1 = y1,
         x2 = targetTime,
         y2 = y2,
         xloc = xloc.bar_time,
         extend = extend.both,
         color = lineColor,
         width = lineWidth,
         style = line.style_solid
     )
````
