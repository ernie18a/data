# Steel Scrip Sessions

- url: https://www.tradingview.com/script/GswUuOzs-Steel-Scrip-Sessions/
- type: indicator
- pine_id: PUB;8ab5f28275b54adb82a9e4c1ea868f5d
- version: 1.0

## Description

marks out all session untested highs and lows to look foir rejections opff of.

## Source Code

````pine
//@version=5
indicator("Asia, London & New York Session Highs/Lows", overlay=true, max_lines_count=500, max_labels_count=500)

// === SESSION INPUTS ===
asiaSession   = input.session("1900-0300", "Asia Session")
londonSession = input.session("0300-0800", "London Session")
nySession     = input.session("0800-1200", "New York Session")

showAsia      = input.bool(true, "Show Asia")
showLondon    = input.bool(true, "Show London")
showNY        = input.bool(true, "Show New York")
untestedOnly  = input.bool(false, "Show Untested Levels Only")

asiaHighColor   = input.color(color.blue, "Asia High Color")
asiaLowColor    = input.color(color.blue, "Asia Low Color")
londonHighColor = input.color(color.yellow, "London High Color")
londonLowColor  = input.color(color.yellow, "London Low Color")
nyHighColor     = input.color(color.red, "New York High Color")
nyLowColor      = input.color(color.red, "New York Low Color")

lineWidth = input.int(2, "Line Width", minval=1, maxval=5)

// === TIME SETTINGS (ET) ===
cutoffHour    = input.int(9, "Cutoff Hour (ET)", minval=0, maxval=23)
cutoffMinute  = input.int(30, "Cutoff Minute (ET)", minval=0, maxval=59)
lineEndHour   = input.int(11, "Line End Hour (ET)", minval=0, maxval=23)
lineEndMinute = input.int(35, "Line End Minute (ET)", minval=0, maxval=59)
tz            = "America/New_York"

// === SESSION DETECTION ===
inAsia   = not na(time(timeframe.period, asiaSession, tz))
inLondon = not na(time(timeframe.period, londonSession, tz))
inNY     = not na(time(timeframe.period, nySession, tz))

newAsia    = inAsia and not inAsia[1]
endAsia    = not inAsia and inAsia[1]
newLondon  = inLondon and not inLondon[1]
endLondon  = not inLondon and inLondon[1]
newNY      = inNY and not inNY[1]
endNY      = not inNY and inNY[1]

// === ET TIME LOGIC ===
etHour   = hour(time, tz)
etMinute = minute(time, tz)
etDay    = dayofmonth(time, tz)
newDay   = etDay != dayofmonth(time[1], tz)

beforeCutoff = (etHour < cutoffHour) or (etHour == cutoffHour and etMinute < cutoffMinute)
cutoffBar    = not beforeCutoff and beforeCutoff[1]

beforeLineEnd = (etHour < lineEndHour) or (etHour == lineEndHour and etMinute < lineEndMinute)

// === VARIABLES ===
var float asiaHigh = na
var float asiaLow = na
var float londonHigh = na
var float londonLow = na
var float nyHigh = na
var float nyLow = na

var line asiaHighLine = na
var line asiaLowLine = na
var line londonHighLine = na
var line londonLowLine = na
var line nyHighLine = na
var line nyLowLine = na

var bool asiaHighUntested = false
var bool asiaLowUntested = false
var bool londonHighUntested = false
var bool londonLowUntested = false
var bool nyHighUntested = false
var bool nyLowUntested = false

var bool asiaHighLocked = false
var bool asiaLowLocked = false
var bool londonHighLocked = false
var bool londonLowLocked = false
var bool nyHighLocked = false
var bool nyLowLocked = false

// === DAILY RESET ===
if newDay
    asiaHighUntested := false
    asiaLowUntested := false
    londonHighUntested := false
    londonLowUntested := false
    nyHighUntested := false
    nyLowUntested := false

    asiaHighLocked := false
    asiaLowLocked := false
    londonHighLocked := false
    londonLowLocked := false
    nyHighLocked := false
    nyLowLocked := false

// === RESET / TRACK ASIA ===
if newAsia
    asiaHigh := high
    asiaLow := low
    asiaHighUntested := false
    asiaLowUntested := false
    asiaHighLocked := false
    asiaLowLocked := false

    if not na(asiaHighLine)
        line.delete(asiaHighLine)
    if not na(asiaLowLine)
        line.delete(asiaLowLine)

    asiaHighLine := line.new(bar_index, asiaHigh, bar_index, asiaHigh, extend=extend.none, color=asiaHighColor, width=lineWidth)
    asiaLowLine  := line.new(bar_index, asiaLow,  bar_index, asiaLow,  extend=extend.none, color=asiaLowColor, width=lineWidth)

if inAsia
    asiaHigh := math.max(asiaHigh, high)
    asiaLow := math.min(asiaLow, low)

    if showAsia
        line.set_xy1(asiaHighLine, line.get_x1(asiaHighLine), asiaHigh)
        if beforeLineEnd
            line.set_xy2(asiaHighLine, bar_index, asiaHigh)

        line.set_xy1(asiaLowLine, line.get_x1(asiaLowLine), asiaLow)
        if beforeLineEnd
            line.set_xy2(asiaLowLine, bar_index, asiaLow)

if endAsia
    asiaHighUntested := true
    asiaLowUntested := true

// === TRACK LONDON ===
if newLondon
    londonHigh := high
    londonLow := low
    londonHighUntested := false
    londonLowUntested := false
    londonHighLocked := false
    londonLowLocked := false

    if not na(londonHighLine)
        line.delete(londonHighLine)
    if not na(londonLowLine)
        line.delete(londonLowLine)

    londonHighLine := line.new(bar_index, londonHigh, bar_index, londonHigh, extend=extend.none, color=londonHighColor, width=lineWidth)
    londonLowLine  := line.new(bar_index, londonLow,  bar_index, londonLow,  extend=extend.none, color=londonLowColor, width=lineWidth)

if inLondon
    londonHigh := math.max(londonHigh, high)
    londonLow := math.min(londonLow, low)

    if showLondon
        line.set_xy1(londonHighLine, line.get_x1(londonHighLine), londonHigh)
        if beforeLineEnd
            line.set_xy2(londonHighLine, bar_index, londonHigh)

        line.set_xy1(londonLowLine, line.get_x1(londonLowLine), londonLow)
        if beforeLineEnd
            line.set_xy2(londonLowLine, bar_index, londonLow)

if endLondon
    londonHighUntested := true
    londonLowUntested := true

// === TRACK NEW YORK ===
if newNY
    nyHigh := high
    nyLow := low
    nyHighUntested := false
    nyLowUntested := false
    nyHighLocked := false
    nyLowLocked := false

    if not na(nyHighLine)
        line.delete(nyHighLine)
    if not na(nyLowLine)
        line.delete(nyLowLine)

    nyHighLine := line.new(bar_index, nyHigh, bar_index, nyHigh, extend=extend.none, color=nyHighColor, width=lineWidth)
    nyLowLine  := line.new(bar_index, nyLow,  bar_index, nyLow,  extend=extend.none, color=nyLowColor, width=lineWidth)

if inNY
    nyHigh := math.max(nyHigh, high)
    nyLow := math.min(nyLow, low)

    if showNY
        line.set_xy1(nyHighLine, line.get_x1(nyHighLine), nyHigh)
        if beforeLineEnd
            line.set_xy2(nyHighLine, bar_index, nyHigh)

        line.set_xy1(nyLowLine, line.get_x1(nyLowLine), nyLow)
        if beforeLineEnd
            line.set_xy2(nyLowLine, bar_index, nyLow)

if endNY
    nyHighUntested := true
    nyLowUntested := true

// === KEEP LINES EXTENDING UNTIL 11:30 ET ===
if beforeLineEnd
    if not na(asiaHighLine)
        line.set_xy2(asiaHighLine, bar_index, asiaHigh)
    if not na(asiaLowLine)
        line.set_xy2(asiaLowLine, bar_index, asiaLow)

    if not na(londonHighLine)
        line.set_xy2(londonHighLine, bar_index, londonHigh)
    if not na(londonLowLine)
        line.set_xy2(londonLowLine, bar_index, londonLow)

    if not na(nyHighLine)
        line.set_xy2(nyHighLine, bar_index, nyHigh)
    if not na(nyLowLine)
        line.set_xy2(nyLowLine, bar_index, nyLow)

// === UNTESTED LOGIC ONLY BEFORE 9:30 ET ===
if beforeCutoff
    if asiaHighUntested and not inAsia and high >= asiaHigh
        asiaHighUntested := false
    if asiaLowUntested and not inAsia and low <= asiaLow
        asiaLowUntested := false

    if londonHighUntested and not inLondon and high >= londonHigh
        londonHighUntested := false
    if londonLowUntested and not inLondon and low <= londonLow
        londonLowUntested := false

    if nyHighUntested and not inNY and high >= nyHigh
        nyHighUntested := false
    if nyLowUntested and not inNY and low <= nyLow
        nyLowUntested := false

// === LOCK SURVIVORS AT 9:30 ET ===
if cutoffBar
    asiaHighLocked := asiaHighUntested
    asiaLowLocked := asiaLowUntested
    londonHighLocked := londonHighUntested
    londonLowLocked := londonLowUntested
    nyHighLocked := nyHighUntested
    nyLowLocked := nyLowUntested

// === SHOW / HIDE LOGIC ===
asiaHighVisible   = showAsia and (not untestedOnly or inAsia or (beforeCutoff ? asiaHighUntested : asiaHighLocked))
asiaLowVisible    = showAsia and (not untestedOnly or inAsia or (beforeCutoff ? asiaLowUntested : asiaLowLocked))

londonHighVisible = showLondon and (not untestedOnly or inLondon or (beforeCutoff ? londonHighUntested : londonHighLocked))
londonLowVisible  = showLondon and (not untestedOnly or inLondon or (beforeCutoff ? londonLowUntested : londonLowLocked))

nyHighVisible     = showNY and (not untestedOnly or inNY or (beforeCutoff ? nyHighUntested : nyHighLocked))
nyLowVisible      = showNY and (not untestedOnly or inNY or (beforeCutoff ? nyLowUntested : nyLowLocked))

line.set_color(asiaHighLine, asiaHighVisible ? asiaHighColor : color.new(asiaHighColor, 100))
line.set_color(asiaLowLine, asiaLowVisible ? asiaLowColor : color.new(asiaLowColor, 100))

line.set_color(londonHighLine, londonHighVisible ? londonHighColor : color.new(londonHighColor, 100))
line.set_color(londonLowLine, londonLowVisible ? londonLowColor : color.new(londonLowColor, 100))

line.set_color(nyHighLine, nyHighVisible ? nyHighColor : color.new(nyHighColor, 100))
line.set_color(nyLowLine, nyLowVisible ? nyLowColor : color.new(nyLowColor, 100))
````
