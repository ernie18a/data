# Next Open / Close Marker

- url: https://www.tradingview.com/script/rq4nqDX4-Next-Open-Close-Marker/
- type: indicator
- pine_id: PUB;fe04c9a6312e4092b19a564f6c6735af
- version: 1.0

## Description

lays out RTH end during RTH, and AH end during AH to give visual on how much time is left for the session. marks the break into the future, and is self deleting once the session ends to provide for a clean chart. will only show the one relevant line at a time. adjustable for different time zones

## Source Code

````pine
//@version=5
indicator("Next Open / Close Marker", overlay=true, max_lines_count=10)

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

// Current day's session timestamps
todayOpen  = timestamp(tzInput, yr, mo, dy, openHour, openMinute)
todayClose = timestamp(tzInput, yr, mo, dy, closeHour, closeMinute)

// Are we currently inside session hours?
inSession = time >= todayOpen and time < todayClose

// ===== Choose target line time =====
int targetTime = na

if inSession
    // During session, show today's close marker
    targetTime := todayClose
else
    // Outside session, show next open marker
    if time < todayOpen
        // Before today's open
        targetTime := todayOpen
    else
        // After today's close, move to next trading day
        int addDays = 1

        if dow == dayofweek.friday
            addDays := 3
        else if dow == dayofweek.saturday
            addDays := 2
        else
            addDays := 1

        targetTime := timestamp(tzInput, yr, mo, dy + addDays, openHour, openMinute)

// ===== Draw one active vertical line =====
var line activeLine = na

if barstate.islast
    if not na(activeLine)
        line.delete(activeLine)

    activeLine := line.new(
         x1 = targetTime,
         y1 = -100000000.0,
         x2 = targetTime,
         y2 =  100000000.0,
         xloc = xloc.bar_time,
         extend = extend.none,
         color = lineColor,
         width = lineWidth,
         style = line.style_solid
     )
````
