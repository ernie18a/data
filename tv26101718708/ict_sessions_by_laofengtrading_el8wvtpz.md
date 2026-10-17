# ICT Sessions by Laofengtrading

- url: https://www.tradingview.com/script/El8wVTpZ-ICT-Sessions-by-Laofengtrading/
- type: indicator
- pine_id: PUB;2be92fbdbbde41cb85666c3447da3890
- version: 1.0

## Description

This indicator highlights three commonly used ICT trading sessions directly on the chart, using New York time.

Sessions included:

Asia Session: 20:00 - 23:59
London Session: 02:00 - 04:59
New York Session: 07:00 - 09:59

All session times are based on America/New_York and automatically adjust for daylight saving time.

The indicator draws a range box for each session, tracking the session high and low as price develops. Optional labels can be displayed to identify each session clearly.

Features:

- Highlights Asia, London, and New York ICT sessions
- Uses fixed New York time
- Automatically adjusts for daylight saving time
- Tracks each session high and low
- Customizable session colors
- Optional session labels

## Source Code

````pine
//@version=6
indicator("ICT Sessions by Laofengtrading", overlay=true, max_boxes_count=500, max_labels_count=500)

// === Inputs ===
showAsia = input.bool(true, "Show Asia Session")
asiaColor = input.color(color.new(color.blue, 85), "Asia Color")

showLondon = input.bool(true, "Show London Session")
londonColor = input.color(color.new(color.orange, 85), "London Color")

showNewYork = input.bool(true, "Show New York Session")
newYorkColor = input.color(color.new(color.green, 85), "New York Color")

showLabels = input.bool(true, "Show Session Labels")

timezone = "America/New_York"

h = hour(time, timezone)
m = minute(time, timezone)

inAsia = h >= 20 and h <= 23
inLondon = h >= 2 and h <= 4
inNewYork = h >= 7 and h <= 9

asiaStart = h == 20 and m == 0
londonStart = h == 2 and m == 0
newYorkStart = h == 7 and m == 0

var box asiaBox = na
var box londonBox = na
var box newYorkBox = na

var label asiaLabel = na
var label londonLabel = na
var label newYorkLabel = na

var float asiaHigh = na
var float asiaLow = na
var float londonHigh = na
var float londonLow = na
var float newYorkHigh = na
var float newYorkLow = na

// === Asia Session ===
if showAsia and asiaStart
    asiaHigh := high
    asiaLow := low
    asiaBox := box.new(left=time, right=time, top=asiaHigh, bottom=asiaLow, xloc=xloc.bar_time, bgcolor=asiaColor, border_color=color.new(color.blue, 80))
    if showLabels
        asiaLabel := label.new(x=time, y=asiaHigh, xloc=xloc.bar_time, text="Asia\n20:00-23:59", style=label.style_label_down, textcolor=color.white, color=color.new(color.blue, 20), size=size.small)

if showAsia and inAsia and not na(asiaBox)
    asiaHigh := math.max(asiaHigh, high)
    asiaLow := math.min(asiaLow, low)
    box.set_right(asiaBox, time)
    box.set_top(asiaBox, asiaHigh)
    box.set_bottom(asiaBox, asiaLow)
    box.set_bgcolor(asiaBox, asiaColor)
    if showLabels and not na(asiaLabel)
        label.set_x(asiaLabel, time)
        label.set_y(asiaLabel, asiaHigh)

// === London Session ===
if showLondon and londonStart
    londonHigh := high
    londonLow := low
    londonBox := box.new(left=time, right=time, top=londonHigh, bottom=londonLow, xloc=xloc.bar_time, bgcolor=londonColor, border_color=color.new(color.orange, 80))
    if showLabels
        londonLabel := label.new(x=time, y=londonHigh, xloc=xloc.bar_time, text="London\n02:00-04:59", style=label.style_label_down, textcolor=color.white, color=color.new(color.orange, 20), size=size.small)

if showLondon and inLondon and not na(londonBox)
    londonHigh := math.max(londonHigh, high)
    londonLow := math.min(londonLow, low)
    box.set_right(londonBox, time)
    box.set_top(londonBox, londonHigh)
    box.set_bottom(londonBox, londonLow)
    box.set_bgcolor(londonBox, londonColor)
    if showLabels and not na(londonLabel)
        label.set_x(londonLabel, time)
        label.set_y(londonLabel, londonHigh)

// === New York Session ===
if showNewYork and newYorkStart
    newYorkHigh := high
    newYorkLow := low
    newYorkBox := box.new(left=time, right=time, top=newYorkHigh, bottom=newYorkLow, xloc=xloc.bar_time, bgcolor=newYorkColor, border_color=color.new(color.green, 80))
    if showLabels
        newYorkLabel := label.new(x=time, y=newYorkHigh, xloc=xloc.bar_time, text="New York\n07:00-09:59", style=label.style_label_down, textcolor=color.white, color=color.new(color.green, 20), size=size.small)

if showNewYork and inNewYork and not na(newYorkBox)
    newYorkHigh := math.max(newYorkHigh, high)
    newYorkLow := math.min(newYorkLow, low)
    box.set_right(newYorkBox, time)
    box.set_top(newYorkBox, newYorkHigh)
    box.set_bottom(newYorkBox, newYorkLow)
    box.set_bgcolor(newYorkBox, newYorkColor)
    if showLabels and not na(newYorkLabel)
        label.set_x(newYorkLabel, time)
        label.set_y(newYorkLabel, newYorkHigh)
````
