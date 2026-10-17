# Session High/Low + Sweep Markers (NY, London, Asia)

- url: https://www.tradingview.com/script/F7nNUkep-Session-High-Low-Sweep-Markers-NY-London-Asia/
- type: indicator
- pine_id: PUB;7a7aaf3dc6cc40428ceac6ed5d3e3577
- version: 1.0

## Description

Marks previous three days session high and lows with sweep markers

## Source Code

````pine
//@version=6
indicator("Session High/Low + Sweep Markers (NY, London, Asia)", overlay=true, max_lines_count=500, max_labels_count=500)

//=========================
// Session settings
//=========================
nySession      = "0930-1600:23456"
londonSession  = "0300-1100:23456"
asiaSession    = "0000-0800:1234567"

nyTz      = "America/New_York"
londonTz  = "Europe/London"
asiaTz    = "Asia/Tokyo"

keepSessions = 3

//=========================
// Colors
//=========================
nyColor     = color.blue
londonColor = color.orange
asiaColor   = color.green

lineWidth = 1
lineStyle = line.style_solid

//=========================
// Arrays to store lines and values
//=========================
var line[] nyHighLines = array.new_line()
var line[] nyLowLines  = array.new_line()
var float[] nyHighVals = array.new_float()
var float[] nyLowVals  = array.new_float()

var line[] ldnHighLines = array.new_line()
var line[] ldnLowLines  = array.new_line()
var float[] ldnHighVals = array.new_float()
var float[] ldnLowVals  = array.new_float()

var line[] asiaHighLines = array.new_line()
var line[] asiaLowLines  = array.new_line()
var float[] asiaHighVals = array.new_float()
var float[] asiaLowVals  = array.new_float()

//=========================
// Helpers
//=========================
f_trim_lines_and_values(_highLines, _lowLines, _highVals, _lowVals, _keep) =>
    while array.size(_highLines) > _keep
        oldLine = array.shift(_highLines)
        line.delete(oldLine)
        array.shift(_highVals)
    while array.size(_lowLines) > _keep
        oldLine = array.shift(_lowLines)
        line.delete(oldLine)
        array.shift(_lowVals)

f_add_session(_startBar, _hi, _lo, _color, _highLines, _lowLines, _highVals, _lowVals) =>
    hiLine = line.new(_startBar, _hi, bar_index, _hi,
         xloc=xloc.bar_index,
         extend=extend.right,
         color=_color,
         width=lineWidth,
         style=lineStyle)
    loLine = line.new(_startBar, _lo, bar_index, _lo,
         xloc=xloc.bar_index,
         extend=extend.right,
         color=_color,
         width=lineWidth,
         style=lineStyle)

    array.push(_highLines, hiLine)
    array.push(_lowLines, loLine)
    array.push(_highVals, _hi)
    array.push(_lowVals, _lo)

f_swept_high(_vals) =>
    bool swept = false
    for i = 0 to array.size(_vals) - 1
        lvl = array.get(_vals, i)
        swept := swept or (high > lvl and close < lvl)
    swept

f_swept_low(_vals) =>
    bool swept = false
    for i = 0 to array.size(_vals) - 1
        lvl = array.get(_vals, i)
        swept := swept or (low < lvl and close > lvl)
    swept

//=========================
// NY session tracking
//=========================
nyInSession = not na(time(timeframe.period, nySession, nyTz))
nyStart = nyInSession and not nyInSession[1]
nyEnd   = not nyInSession and nyInSession[1]

var float nyHi = na
var float nyLo = na
var int nyStartBar = na

if nyStart
    nyHi := high
    nyLo := low
    nyStartBar := bar_index

if nyInSession
    nyHi := na(nyHi) ? high : math.max(nyHi, high)
    nyLo := na(nyLo) ? low : math.min(nyLo, low)

if nyEnd and not na(nyHi) and not na(nyLo) and not na(nyStartBar)
    f_add_session(nyStartBar, nyHi, nyLo, nyColor, nyHighLines, nyLowLines, nyHighVals, nyLowVals)
    f_trim_lines_and_values(nyHighLines, nyLowLines, nyHighVals, nyLowVals, keepSessions)
    nyHi := na
    nyLo := na
    nyStartBar := na

//=========================
// London session tracking
//=========================
ldnInSession = not na(time(timeframe.period, londonSession, londonTz))
ldnStart = ldnInSession and not ldnInSession[1]
ldnEnd   = not ldnInSession and ldnInSession[1]

var float ldnHi = na
var float ldnLo = na
var int ldnStartBar = na

if ldnStart
    ldnHi := high
    ldnLo := low
    ldnStartBar := bar_index

if ldnInSession
    ldnHi := na(ldnHi) ? high : math.max(ldnHi, high)
    ldnLo := na(ldnLo) ? low : math.min(ldnLo, low)

if ldnEnd and not na(ldnHi) and not na(ldnLo) and not na(ldnStartBar)
    f_add_session(ldnStartBar, ldnHi, ldnLo, londonColor, ldnHighLines, ldnLowLines, ldnHighVals, ldnLowVals)
    f_trim_lines_and_values(ldnHighLines, ldnLowLines, ldnHighVals, ldnLowVals, keepSessions)
    ldnHi := na
    ldnLo := na
    ldnStartBar := na

//=========================
// Asia session tracking
//=========================
asiaInSession = not na(time(timeframe.period, asiaSession, asiaTz))
asiaStart = asiaInSession and not asiaInSession[1]
asiaEnd   = not asiaInSession and asiaInSession[1]

var float asiaHi = na
var float asiaLo = na
var int asiaStartBar = na

if asiaStart
    asiaHi := high
    asiaLo := low
    asiaStartBar := bar_index

if asiaInSession
    asiaHi := na(asiaHi) ? high : math.max(asiaHi, high)
    asiaLo := na(asiaLo) ? low : math.min(asiaLo, low)

if asiaEnd and not na(asiaHi) and not na(asiaLo) and not na(asiaStartBar)
    f_add_session(asiaStartBar, asiaHi, asiaLo, asiaColor, asiaHighLines, asiaLowLines, asiaHighVals, asiaLowVals)
    f_trim_lines_and_values(asiaHighLines, asiaLowLines, asiaHighVals, asiaLowVals, keepSessions)
    asiaHi := na
    asiaLo := na
    asiaStartBar := na

//=========================
// Sweep detection
//=========================
nyHighSweep   = f_swept_high(nyHighVals)
nyLowSweep    = f_swept_low(nyLowVals)

ldnHighSweep  = f_swept_high(ldnHighVals)
ldnLowSweep   = f_swept_low(ldnLowVals)

asiaHighSweep = f_swept_high(asiaHighVals)
asiaLowSweep  = f_swept_low(asiaLowVals)

//=========================
// Plot sweep markers
//=========================
plotshape(nyHighSweep,   title="NY High Sweep",   style=shape.triangledown, location=location.abovebar, color=nyColor,     size=size.tiny)
plotshape(nyLowSweep,    title="NY Low Sweep",    style=shape.triangleup,   location=location.belowbar, color=nyColor,     size=size.tiny)

plotshape(ldnHighSweep,  title="London High Sweep", style=shape.triangledown, location=location.abovebar, color=londonColor, size=size.tiny)
plotshape(ldnLowSweep,   title="London Low Sweep",  style=shape.triangleup,   location=location.belowbar, color=londonColor, size=size.tiny)

plotshape(asiaHighSweep, title="Asia High Sweep", style=shape.triangledown, location=location.abovebar, color=asiaColor,   size=size.tiny)
plotshape(asiaLowSweep,  title="Asia Low Sweep",  style=shape.triangleup,   location=location.belowbar, color=asiaColor,   size=size.tiny)
````
