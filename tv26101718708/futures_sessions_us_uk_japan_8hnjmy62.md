# Futures Sessions US+ UK+ Japan

- url: https://www.tradingview.com/script/8HnjMy62-Futures-Sessions-US-UK-Japan/
- type: indicator
- pine_id: PUB;cfa68127098744ebb19936f1d78817ac
- version: 1.0

## Description

This indicator displays key market session open and close times directly on the chart using clean vertical lines.

It includes session markers for:

US Futures session
UK session
Asia / Japan session

Each session can be individually switched on or off, and users can customise the open and close times, colours, line style, line width, and previous session visibility.

The US Futures lines are anchored to America/New_York time, so they automatically adjust when UK and US daylight saving time changes occur. This helps UK-based traders keep the correct futures open and close reference points without needing to manually update the script.

Main Features

Toggle US Futures, UK, and Japan session lines on/off
Separate open and close lines for each session
Custom colours for each session
Optional previous session lines
Adjustable previous session transparency
Session names displayed next to each line
Session names can be positioned at the top, middle, or bottom of the line
Adjustable label text colour, background colour, and font size
Built-in alerts for session open and close times
Designed for intraday traders who want clean session timing references

Default Session Times

US Futures Close: 16:45 New York time
US Futures Open: 18:00 New York time
UK Open: 08:00 London time
UK Close: 16:30 London time
Japan Open: 09:00 Tokyo time
Japan Close: 15:00 Tokyo time

All session times are editable in the indicator settings.

## Source Code

````pine
//@version=5
indicator("Futures Sessions US+ UK+ Japan", overlay=true, max_lines_count=500, max_labels_count=500)

//──────────────────────────────────────────────────────────────
// Global settings
//──────────────────────────────────────────────────────────────
showPrevious  = input.bool(false, "Show Previous Session Lines")
previousDays  = input.int(5, "Previous Days To Show", minval=1, maxval=50)

lineWidth     = input.int(2, "Main Line Width", minval=1, maxval=5)
prevLineWidth = input.int(2, "Previous Line Width", minval=1, maxval=5)

lineStyleInput = input.string("Dashed", "Main Line Style", options=["Solid", "Dashed", "Dotted"])
prevStyleInput = input.string("Dashed", "Previous Line Style", options=["Solid", "Dashed", "Dotted"])

previousTransparency = input.int(20, "Previous Line Transparency", minval=0, maxval=100)

mainStyle = lineStyleInput == "Solid" ? line.style_solid : lineStyleInput == "Dotted" ? line.style_dotted : line.style_dashed
prevStyle = prevStyleInput == "Solid" ? line.style_solid : prevStyleInput == "Dotted" ? line.style_dotted : line.style_dashed

msOneDay = 24 * 60 * 60 * 1000

//──────────────────────────────────────────────────────────────
// Session name / label settings
// Pine labels cannot truly rotate text, so names are stacked vertically.
// Label position can be moved to Top / Middle / Bottom of the session line.
//──────────────────────────────────────────────────────────────
showLabels       = input.bool(true, "Show Session Names")
showPrevLabels   = input.bool(false, "Show Previous Session Names")
labelPosition    = input.string("Top", "Session Name Position", options=["Top", "Middle", "Bottom"])
labelSizeInput   = input.string("Small", "Session Name Font Size", options=["Tiny", "Small", "Normal", "Large", "Huge"])
labelTextColor   = input.color(color.white, "Main Name Text Colour")
labelBgColor     = input.color(color.new(color.black, 15), "Main Name Background Colour")
prevLabelTextCol = input.color(color.white, "Previous Name Text Colour")
prevLabelBgCol   = input.color(color.new(color.black, 40), "Previous Name Background Colour")

labelSize = labelSizeInput == "Tiny" ? size.tiny : labelSizeInput == "Normal" ? size.normal : labelSizeInput == "Large" ? size.large : labelSizeInput == "Huge" ? size.huge : size.small

//──────────────────────────────────────────────────────────────
// US futures settings
//──────────────────────────────────────────────────────────────
showUS          = input.bool(true, "Show US Futures Lines")
usTz            = input.string("America/New_York", "US Futures Time Zone")
showUSClose     = input.bool(true, "Show US Close Line")
showUSOpen      = input.bool(true, "Show US Open Line")
usCloseHour     = input.int(16, "US Close Hour", minval=0, maxval=23)
usCloseMinute   = input.int(45, "US Close Minute", minval=0, maxval=59)
usOpenHour      = input.int(18, "US Open Hour", minval=0, maxval=23)
usOpenMinute    = input.int(0, "US Open Minute", minval=0, maxval=59)
usCloseColor    = input.color(color.red, "US Close Colour")
usOpenColor     = input.color(color.green, "US Open Colour")
usPrevCloseBase = input.color(color.red, "US Previous Close Colour")
usPrevOpenBase  = input.color(color.green, "US Previous Open Colour")

usCloseName     = input.string("US\nFutures\nClose", "US Close Vertical Name")
usOpenName      = input.string("US\nFutures\nOpen", "US Open Vertical Name")

//──────────────────────────────────────────────────────────────
// UK session settings
//──────────────────────────────────────────────────────────────
showUK          = input.bool(true, "Show UK Session Lines")
ukTz            = input.string("Europe/London", "UK Session Time Zone")
showUKOpen      = input.bool(true, "Show UK Open Line")
showUKClose     = input.bool(true, "Show UK Close Line")
ukOpenHour      = input.int(8, "UK Open Hour", minval=0, maxval=23)
ukOpenMinute    = input.int(0, "UK Open Minute", minval=0, maxval=59)
ukCloseHour     = input.int(16, "UK Close Hour", minval=0, maxval=23)
ukCloseMinute   = input.int(30, "UK Close Minute", minval=0, maxval=59)
ukOpenColor     = input.color(color.blue, "UK Open Colour")
ukCloseColor    = input.color(color.purple, "UK Close Colour")
ukPrevOpenBase  = input.color(color.blue, "UK Previous Open Colour")
ukPrevCloseBase = input.color(color.purple, "UK Previous Close Colour")

ukOpenName      = input.string("UK\nOpen", "UK Open Vertical Name")
ukCloseName     = input.string("UK\nClose", "UK Close Vertical Name")

//──────────────────────────────────────────────────────────────
// Japan session settings
//──────────────────────────────────────────────────────────────
showJP          = input.bool(true, "Show Asia / Japan Session Lines")
jpTz            = input.string("Asia/Tokyo", "Japan Session Time Zone")
showJPOpen      = input.bool(true, "Show Japan Open Line")
showJPClose     = input.bool(true, "Show Japan Close Line")
jpOpenHour      = input.int(9, "Japan Open Hour", minval=0, maxval=23)
jpOpenMinute    = input.int(0, "Japan Open Minute", minval=0, maxval=59)
jpCloseHour     = input.int(15, "Japan Close Hour", minval=0, maxval=23)
jpCloseMinute   = input.int(0, "Japan Close Minute", minval=0, maxval=59)
jpOpenColor     = input.color(color.orange, "Japan Open Colour")
jpCloseColor    = input.color(color.yellow, "Japan Close Colour")
jpPrevOpenBase  = input.color(color.orange, "Japan Previous Open Colour")
jpPrevCloseBase = input.color(color.yellow, "Japan Previous Close Colour")

jpOpenName      = input.string("Japan\nOpen", "Japan Open Vertical Name")
jpCloseName     = input.string("Japan\nClose", "Japan Close Vertical Name")

//──────────────────────────────────────────────────────────────
// Previous line colours with transparency applied by setting
//──────────────────────────────────────────────────────────────
usPrevCloseCol = color.new(usPrevCloseBase, previousTransparency)
usPrevOpenCol  = color.new(usPrevOpenBase, previousTransparency)
ukPrevOpenCol  = color.new(ukPrevOpenBase, previousTransparency)
ukPrevCloseCol = color.new(ukPrevCloseBase, previousTransparency)
jpPrevOpenCol  = color.new(jpPrevOpenBase, previousTransparency)
jpPrevCloseCol = color.new(jpPrevCloseBase, previousTransparency)

//──────────────────────────────────────────────────────────────
// Vertical line height and label position
//──────────────────────────────────────────────────────────────
atrValue = ta.atr(14)
topY = high + atrValue * 10
botY = low - atrValue * 10
midY = (topY + botY) / 2

labelY = labelPosition == "Top" ? topY : labelPosition == "Bottom" ? botY : midY
labelStyle = labelPosition == "Bottom" ? label.style_label_up : labelPosition == "Top" ? label.style_label_down : label.style_label_left

//──────────────────────────────────────────────────────────────
// Function: next timestamp for a timezone/session time
//──────────────────────────────────────────────────────────────
f_nextTime(_tz, _hour, _minute) =>
    y = year(time, _tz)
    m = month(time, _tz)
    d = dayofmonth(time, _tz)
    h = hour(time, _tz)
    minNow = minute(time, _tz)
    minsNow = h * 60 + minNow
    targetMins = _hour * 60 + _minute
    todayTarget = timestamp(_tz, y, m, d, _hour, _minute)
    minsNow < targetMins ? todayTarget : todayTarget + msOneDay

// Next line times
usNextClose = f_nextTime(usTz, usCloseHour, usCloseMinute)
usNextOpen  = f_nextTime(usTz, usOpenHour, usOpenMinute)
ukNextOpen  = f_nextTime(ukTz, ukOpenHour, ukOpenMinute)
ukNextClose = f_nextTime(ukTz, ukCloseHour, ukCloseMinute)
jpNextOpen  = f_nextTime(jpTz, jpOpenHour, jpOpenMinute)
jpNextClose = f_nextTime(jpTz, jpCloseHour, jpCloseMinute)

// Current objects
var line usCloseLine = na
var line usOpenLine = na
var line ukOpenLine = na
var line ukCloseLine = na
var line jpOpenLine = na
var line jpCloseLine = na

var label usCloseLabel = na
var label usOpenLabel = na
var label ukOpenLabel = na
var label ukCloseLabel = na
var label jpOpenLabel = na
var label jpCloseLabel = na

// Previous objects
var line[] previousLines = array.new_line()
var label[] previousLabels = array.new_label()

if barstate.islast
    // Delete current lines
    line.delete(usCloseLine)
    line.delete(usOpenLine)
    line.delete(ukOpenLine)
    line.delete(ukCloseLine)
    line.delete(jpOpenLine)
    line.delete(jpCloseLine)

    // Delete current labels
    label.delete(usCloseLabel)
    label.delete(usOpenLabel)
    label.delete(ukOpenLabel)
    label.delete(ukCloseLabel)
    label.delete(jpOpenLabel)
    label.delete(jpCloseLabel)

    // Delete previous lines
    if array.size(previousLines) > 0
        for i = 0 to array.size(previousLines) - 1
            line.delete(array.get(previousLines, i))
        array.clear(previousLines)

    // Delete previous labels
    if array.size(previousLabels) > 0
        for i = 0 to array.size(previousLabels) - 1
            label.delete(array.get(previousLabels, i))
        array.clear(previousLabels)

    // US futures lines and vertical labels
    if showUS
        if showUSClose
            usCloseLine := line.new(usNextClose, botY, usNextClose, topY, xloc.bar_time, extend.both, usCloseColor, mainStyle, lineWidth)
            if showLabels
                usCloseLabel := label.new(usNextClose, labelY, usCloseName, xloc=xloc.bar_time, style=labelStyle, textcolor=labelTextColor, color=labelBgColor, size=labelSize)
        if showUSOpen
            usOpenLine := line.new(usNextOpen, botY, usNextOpen, topY, xloc.bar_time, extend.both, usOpenColor, mainStyle, lineWidth)
            if showLabels
                usOpenLabel := label.new(usNextOpen, labelY, usOpenName, xloc=xloc.bar_time, style=labelStyle, textcolor=labelTextColor, color=labelBgColor, size=labelSize)

    // UK session lines and vertical labels
    if showUK
        if showUKOpen
            ukOpenLine := line.new(ukNextOpen, botY, ukNextOpen, topY, xloc.bar_time, extend.both, ukOpenColor, mainStyle, lineWidth)
            if showLabels
                ukOpenLabel := label.new(ukNextOpen, labelY, ukOpenName, xloc=xloc.bar_time, style=labelStyle, textcolor=labelTextColor, color=labelBgColor, size=labelSize)
        if showUKClose
            ukCloseLine := line.new(ukNextClose, botY, ukNextClose, topY, xloc.bar_time, extend.both, ukCloseColor, mainStyle, lineWidth)
            if showLabels
                ukCloseLabel := label.new(ukNextClose, labelY, ukCloseName, xloc=xloc.bar_time, style=labelStyle, textcolor=labelTextColor, color=labelBgColor, size=labelSize)

    // Japan / Asia session lines and vertical labels
    if showJP
        if showJPOpen
            jpOpenLine := line.new(jpNextOpen, botY, jpNextOpen, topY, xloc.bar_time, extend.both, jpOpenColor, mainStyle, lineWidth)
            if showLabels
                jpOpenLabel := label.new(jpNextOpen, labelY, jpOpenName, xloc=xloc.bar_time, style=labelStyle, textcolor=labelTextColor, color=labelBgColor, size=labelSize)
        if showJPClose
            jpCloseLine := line.new(jpNextClose, botY, jpNextClose, topY, xloc.bar_time, extend.both, jpCloseColor, mainStyle, lineWidth)
            if showLabels
                jpCloseLabel := label.new(jpNextClose, labelY, jpCloseName, xloc=xloc.bar_time, style=labelStyle, textcolor=labelTextColor, color=labelBgColor, size=labelSize)

    // Optional previous lines and vertical labels
    if showPrevious
        for d = 1 to previousDays
            dayOffset = d * msOneDay

            if showUS
                if showUSClose
                    l1 = line.new(usNextClose - dayOffset, botY, usNextClose - dayOffset, topY, xloc.bar_time, extend.both, usPrevCloseCol, prevStyle, prevLineWidth)
                    array.push(previousLines, l1)
                    if showPrevLabels
                        lb1 = label.new(usNextClose - dayOffset, labelY, usCloseName, xloc=xloc.bar_time, style=labelStyle, textcolor=prevLabelTextCol, color=prevLabelBgCol, size=labelSize)
                        array.push(previousLabels, lb1)
                if showUSOpen
                    l2 = line.new(usNextOpen - dayOffset, botY, usNextOpen - dayOffset, topY, xloc.bar_time, extend.both, usPrevOpenCol, prevStyle, prevLineWidth)
                    array.push(previousLines, l2)
                    if showPrevLabels
                        lb2 = label.new(usNextOpen - dayOffset, labelY, usOpenName, xloc=xloc.bar_time, style=labelStyle, textcolor=prevLabelTextCol, color=prevLabelBgCol, size=labelSize)
                        array.push(previousLabels, lb2)

            if showUK
                if showUKOpen
                    l3 = line.new(ukNextOpen - dayOffset, botY, ukNextOpen - dayOffset, topY, xloc.bar_time, extend.both, ukPrevOpenCol, prevStyle, prevLineWidth)
                    array.push(previousLines, l3)
                    if showPrevLabels
                        lb3 = label.new(ukNextOpen - dayOffset, labelY, ukOpenName, xloc=xloc.bar_time, style=labelStyle, textcolor=prevLabelTextCol, color=prevLabelBgCol, size=labelSize)
                        array.push(previousLabels, lb3)
                if showUKClose
                    l4 = line.new(ukNextClose - dayOffset, botY, ukNextClose - dayOffset, topY, xloc.bar_time, extend.both, ukPrevCloseCol, prevStyle, prevLineWidth)
                    array.push(previousLines, l4)
                    if showPrevLabels
                        lb4 = label.new(ukNextClose - dayOffset, labelY, ukCloseName, xloc=xloc.bar_time, style=labelStyle, textcolor=prevLabelTextCol, color=prevLabelBgCol, size=labelSize)
                        array.push(previousLabels, lb4)

            if showJP
                if showJPOpen
                    l5 = line.new(jpNextOpen - dayOffset, botY, jpNextOpen - dayOffset, topY, xloc.bar_time, extend.both, jpPrevOpenCol, prevStyle, prevLineWidth)
                    array.push(previousLines, l5)
                    if showPrevLabels
                        lb5 = label.new(jpNextOpen - dayOffset, labelY, jpOpenName, xloc=xloc.bar_time, style=labelStyle, textcolor=prevLabelTextCol, color=prevLabelBgCol, size=labelSize)
                        array.push(previousLabels, lb5)
                if showJPClose
                    l6 = line.new(jpNextClose - dayOffset, botY, jpNextClose - dayOffset, topY, xloc.bar_time, extend.both, jpPrevCloseCol, prevStyle, prevLineWidth)
                    array.push(previousLines, l6)
                    if showPrevLabels
                        lb6 = label.new(jpNextClose - dayOffset, labelY, jpCloseName, xloc=xloc.bar_time, style=labelStyle, textcolor=prevLabelTextCol, color=prevLabelBgCol, size=labelSize)
                        array.push(previousLabels, lb6)

// Alerts
usCloseNow = time >= usNextClose and time[1] < usNextClose
usOpenNow  = time >= usNextOpen and time[1] < usNextOpen
ukOpenNow  = time >= ukNextOpen and time[1] < ukNextOpen
ukCloseNow = time >= ukNextClose and time[1] < ukNextClose
jpOpenNow  = time >= jpNextOpen and time[1] < jpNextOpen
jpCloseNow = time >= jpNextClose and time[1] < jpNextClose

alertcondition(usCloseNow, "US Futures Close", "US futures close line reached.")
alertcondition(usOpenNow, "US Futures Open", "US futures open line reached.")
alertcondition(ukOpenNow, "UK Session Open", "UK session open line reached.")
alertcondition(ukCloseNow, "UK Session Close", "UK session close line reached.")
alertcondition(jpOpenNow, "Japan Session Open", "Japan session open line reached.")
alertcondition(jpCloseNow, "Japan Session Close", "Japan session close line reached.")
````
