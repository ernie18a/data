# ES Opening 30s Range

- url: https://www.tradingview.com/script/n9VQO4KQ-ES-Opening-30s-Range/
- type: indicator
- pine_id: PUB;839b4bcbb9824cdb8c374615046eff19
- version: 1.0

## Description

Displays the high and low of the opening 30 seconds of RTH. This is a significant level on ES/ NQ

## Source Code

````pine
//@version=6
indicator("ES Opening 30s Range", overlay=true, max_lines_count=500)

tz = "America/New_York"

// Settings
lineColour = input.color(color.black, "Line Colour")
lineWidth  = input.int(1, "Line Width", minval=1, maxval=5)
lineStyleInput = input.string("Dotted", "Line Style", options=["Solid", "Dashed", "Dotted"])

lineStyle = lineStyleInput == "Solid"  ? line.style_solid :
     lineStyleInput == "Dashed" ? line.style_dashed :
     line.style_dotted

// --- Opening range high
f_hi() =>
    y = year(time, tz)
    m = month(time, tz)
    d = dayofmonth(time, tz)

    sessStart = timestamp(tz, y, m, d, 9, 30)
    sessEnd   = sessStart + 30 * 1000

    var float hi = na
    newDay = time >= sessStart and time[1] < sessStart

    if newDay
        hi := na

    if time >= sessStart and time < sessEnd
        hi := na(hi) ? high : math.max(hi, high)

    hi

// --- Opening range low
f_lo() =>
    y = year(time, tz)
    m = month(time, tz)
    d = dayofmonth(time, tz)

    sessStart = timestamp(tz, y, m, d, 9, 30)
    sessEnd   = sessStart + 30 * 1000

    var float lo = na
    newDay = time >= sessStart and time[1] < sessStart

    if newDay
        lo := na

    if time >= sessStart and time < sessEnd
        lo := na(lo) ? low : math.min(lo, low)

    lo

// Pull 30-second values — this is your working logic
orHigh = request.security(syminfo.tickerid, "30S", f_hi())
orLow  = request.security(syminfo.tickerid, "30S", f_lo())

// RTH session timing
y = year(time, tz)
m = month(time, tz)
d = dayofmonth(time, tz)

rthOpen = timestamp(tz, y, m, d, 9, 30)

// Extend to 14:15 London time on the next trading day
endTz = "Europe/London"

isFriday = dayofweek(time, tz) == dayofweek.friday
nextDayOffset = isFriday ? 3 : 1

rthClose = timestamp(endTz, y, m, d + nextDayOffset, 14, 15)

newSession = time >= rthOpen and time[1] < rthOpen

// Lines
var line hiLine = na
var line loLine = na

if newSession
    hiLine := line.new(x1=rthOpen, y1=orHigh, x2=rthClose, y2=orHigh, xloc=xloc.bar_time, color=lineColour, style=lineStyle, width=lineWidth)
    loLine := line.new(x1=rthOpen, y1=orLow,  x2=rthClose, y2=orLow,  xloc=xloc.bar_time, color=lineColour, style=lineStyle, width=lineWidth)

if not na(hiLine)
    line.set_y1(hiLine, orHigh)
    line.set_y2(hiLine, orHigh)
    line.set_color(hiLine, lineColour)
    line.set_style(hiLine, lineStyle)
    line.set_width(hiLine, lineWidth)

if not na(loLine)
    line.set_y1(loLine, orLow)
    line.set_y2(loLine, orLow)
    line.set_color(loLine, lineColour)
    line.set_style(loLine, lineStyle)
    line.set_width(loLine, lineWidth)
````
