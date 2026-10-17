# Bar Count (Cash Open)

- url: https://www.tradingview.com/script/px643Gek-Bar-Count-Cash-Open/
- type: indicator
- pine_id: PUB;cf46f0008ff7497297f632da83698bd1
- version: 1.0

## Description

This is a bar count tool to show you the bar numbers throughout the NY session.

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

// ATR-based label spacing (works across YM, NQ, ES, RTY)
atrLength       = input.int(14, title="ATR Length", minval=1)
offsetATR       = input.float(0.04, title="Counter Offset (ATR Multiplier)", step=0.01, minval=0.01)

atrValue = ta.atr(atrLength)

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
         low - (atrValue * offsetATR),
         str.tostring(count),
         yloc = yloc.price,
         style = label.style_none,
         textcolor = counterColor,
         size = labelSize
     )
````
