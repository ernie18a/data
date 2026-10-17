# Cash Open Bar Count

- url: https://www.tradingview.com/script/57m82vMu-Cash-Open-Bar-Count/
- type: indicator
- pine_id: PUB;536e195eadf2488999e5703b51f84b6c
- version: 1.0

## Description

This is a indicator that I will be updating through out, but the main purpose of it, is to provide a bar count from the cash open to close.

## Source Code

````pine
//@version=6
indicator("Bar Count From 9:30 Open", overlay = true, max_labels_count = 500)

// ===== SETTINGS =====
labelSize       = size.normal
counterColor    = color.gray
labelPosition   = input.string("Above", title="Label Position", options=["Above", "Below"])
labelDistance   = input.int(10, title="Label Distance")
specialBarColor = input.color(color.purple, title="9:30 Bar Color")
showOpenLabel   = input.bool(true, title="Show Open Label")
counterOffset   = input.int(10, title="Counter Offset (Ticks)", minval=1)

// ===== TIME LOGIC (New York Time) =====
nyHour   = hour(time, "America/New_York")
nyMinute = minute(time, "America/New_York")

isOpenBar = (nyHour == 9 and nyMinute == 30)

inRTH = (
     (nyHour > 9 or (nyHour == 9 and nyMinute >= 30))
     and nyHour < 16
)

// ===== LABEL Y POSITION =====
labelY = labelPosition == "Above" ? high + labelDistance : low - labelDistance

// ===== MARK 9:30 BAR =====
if isOpenBar and showOpenLabel
    label.new(
         bar_index,
         labelY,
         "Open",
         yloc = yloc.price,
         color = color.orange,
         size = labelSize
     )

barcolor(isOpenBar ? specialBarColor : na)

// ===== COUNTER =====
var int count = na

if isOpenBar
    count := 1
else if inRTH and not na(count)
    count += 1
else if not inRTH
    count := na

// ===== DISPLAY COUNTER =====
// Show only odd-numbered bars: 1,3,5,7,9...
if inRTH and not na(count) and (count % 2 == 1)
    label.new(
         bar_index,
         low - (syminfo.mintick * counterOffset),
         str.tostring(count),
         yloc = yloc.price,
         style = label.style_none,
         textcolor = counterColor,
         size = labelSize
     )
````
