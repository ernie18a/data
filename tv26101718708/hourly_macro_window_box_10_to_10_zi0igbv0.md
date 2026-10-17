# Hourly Macro Window Box (-10 to +10)

- url: https://www.tradingview.com/script/ZI0iGBV0-Hourly-Macro-Window-Box-10-to-10/
- type: indicator
- pine_id: PUB;906eaa1945d343b0ace4636f2a82ab3a
- version: 1.0

## Description

This just gives range. Of the movement cross section during the macro time frame. On every hourly. 15 minute. 5 minute. One minute. 15 seconds. These time frames only.

## Source Code

````pine
//@version=6
indicator("Hourly Macro Window Box (-10 to +10)", overlay=true, max_boxes_count=500)

minsBefore = input.int(10, "Minutes BEFORE the hour", minval=1, maxval=59)
minsAfter  = input.int(10, "Minutes AFTER the hour",  minval=1, maxval=59)

boxFill   = input.color(color.new(color.yellow, 85), "Box fill color")
boxBorder = input.color(color.new(color.orange, 0),  "Box border color")
borderW   = input.int(1, "Border width", minval=0, maxval=4)

showLabel = input.bool(true, "Label High/Low when window completes")

// In-window: last minsBefore of previous hour OR first minsAfter of current hour
inWindow = (minute >= (60 - minsBefore)) or (minute <= minsAfter)

windowStart = inWindow and not inWindow[1]
windowEnd   = not inWindow and inWindow[1]

var float winHigh = na
var float winLow  = na
var box   winBox  = box(na)

if windowStart
    winHigh := high
    winLow  := low
    winBox := box.new(left=time, top=winHigh, right=time, bottom=winLow, xloc=xloc.bar_time, bgcolor=boxFill, border_color=boxBorder, border_width=borderW)

if inWindow
    winHigh := math.max(nz(winHigh, high), high)
    winLow  := math.min(nz(winLow,  low),  low)
    if not na(winBox)
        box.set_right(winBox, time)
        box.set_top(winBox, winHigh)
        box.set_bottom(winBox, winLow)

if windowEnd
    if not na(winBox)
        box.set_right(winBox, time[1])
        box.set_top(winBox, winHigh)
        box.set_bottom(winBox, winLow)

    if showLabel
        label.new(x=time[1], y=winHigh, 
          text="Hi: " + str.tostring(winHigh, format.mintick) + "\nLo: " + str.tostring(winLow, format.mintick), 
          xloc=xloc.bar_time, style=label.style_label_down, color=color.new(color.yellow, 0), textcolor=color.black)

    winHigh := na
    winLow  := na
    winBox  := na
````
