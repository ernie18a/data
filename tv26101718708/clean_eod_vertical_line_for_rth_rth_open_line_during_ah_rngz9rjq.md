# *CLEAN* EOD Vertical line for RTH & RTH open line during AH.

- url: https://www.tradingview.com/script/RnGz9Rjq-CLEAN-EOD-Vertical-line-for-RTH-RTH-open-line-during-AH/
- type: indicator
- pine_id: PUB;cccfa9751dc34048bf6e1c1d7a4fdb69
- version: 1.0

## Description

Gives a visual for when the RTH will close, and during the after hours, will show you when the AH trading session is over/when RTH begins again. Vertical lines are self deleting when session switches over. Provides future lines which for some reason no other indicator does

## Source Code

````pine
//@version=5
indicator("Next Open / Close Marker", overlay=true, max_lines_count=10)

// Fixed timezone
tz = "America/New_York"

// ----- Helper values from current bar time in New York -----
nyYear   = year(time, tz)
nyMonth  = month(time, tz)
nyDay    = dayofmonth(time, tz)
nyHour   = hour(time, tz)
nyMinute = minute(time, tz)
nyDOW    = dayofweek(time, tz)

// Current day's RTH timestamps
todayOpen  = timestamp(tz, nyYear, nyMonth, nyDay, 9, 30)
todayClose = timestamp(tz, nyYear, nyMonth, nyDay, 16, 0)

// Are we currently inside regular market hours?
inRTH = time >= todayOpen and time < todayClose

// ----- Figure out next target timestamp -----
int targetTime = na

if inRTH
    // During market hours, show today's 16:00 line
    targetTime := todayClose
else
    // Outside market hours, show next 9:30 line
    if time < todayOpen
        // Before today's open
        targetTime := todayOpen
    else
        // After today's close (or weekend), move to next trading day
        int addDays = 1
        
        if nyDOW == dayofweek.friday
            addDays := 3
        else if nyDOW == dayofweek.saturday
            addDays := 2
        else
            addDays := 1

        nextOpen = timestamp(tz, nyYear, nyMonth, nyDay + addDays, 9, 30)
        targetTime := nextOpen

// ----- Draw only one active vertical line -----
var line activeLine = na

if barstate.islast
    if not na(activeLine)
        line.delete(activeLine)

    // Use a very tall line so it looks infinite
    float topY = 100000000.0
    float botY = -100000000.0

    activeLine := line.new(
         x1 = targetTime,
         y1 = botY,
         x2 = targetTime,
         y2 = topY,
         xloc = xloc.bar_time,
         extend = extend.none,
         color = color.red,
         width = 1,
         style = line.style_solid
     )
````
