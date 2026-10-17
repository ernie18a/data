# 9AM ORB (UTC+2)

- url: https://www.tradingview.com/script/5aFVGUKQ-9AM-ORB-UTC-2/
- type: indicator
- pine_id: PUB;c9177dbc55f943e9a05f0e716c3c01a9
- version: 1.0

## Description

9am orb from 9am utc+2 up until 10am 
Wait for breakout

## Source Code

````pine
//@version=5
indicator("9AM ORB (UTC+2)", overlay=true)

// --- Settings
sessionStartHour = 9
sessionEndHour = 10

// --- Detect session
inSession = (hour == sessionStartHour)

// --- Variables
var float orbHigh = na
var float orbLow = na
var line highLine = na
var line lowLine = na

// --- Reset every day
newDay = ta.change(time("D"))

if newDay
    orbHigh := na
    orbLow := na
    line.delete(highLine)
    line.delete(lowLine)

// --- Capture 9AM candle range
if hour == sessionStartHour
    orbHigh := high
    orbLow := low

// --- Draw lines after 10AM
if hour >= sessionEndHour and not na(orbHigh)
    if na(highLine)
        highLine := line.new(bar_index, orbHigh, bar_index + 50, orbHigh, extend=extend.right, color=color.green, width=2)
        lowLine := line.new(bar_index, orbLow, bar_index + 50, orbLow, extend=extend.right, color=color.red, width=2)
````
