# Killzones + TP1 & TP2

- url: https://www.tradingview.com/script/6XwTooI1-Killzones-TP1-TP2/
- type: indicator
- pine_id: PUB;ca36d6c551e54f5eb4e867b13b31a29f
- version: 3.0

## Description

33 Killzone Direction Gann Zones

A custom TradingView indicator built around session direction, untapped liquidity, and automatic Gann target projections.

This indicator automatically maps:
• Asia Killzone
• London Killzone
• NY AM Killzone
• NY Lunch Killzone
• NY APM Killzone

How it works:
If a session closes bullish, bullish targets are projected automatically.
If a session closes bearish, bearish targets are projected automatically.

Features:
• Automatic session direction detection
• TP1 and TP2 projections
• 0.75 Gann expansion targets
• Untapped liquidity tracking
• Levels extend until tapped
• Clean minimal chart design
• Fully customizable colors
• Adjustable line thickness
• Session visibility toggles
• Asia / London / NY AM session support
• No manual Gann box plotting needed

TP Logic:
TP1 = Session High or Low
TP2 = 0.75 Gann projection based on session range

Designed for traders who focus on:
• Session liquidity
• Killzone trading
• Continuation moves
• Untapped targets
• Directional expansion setups

Built from real session behavior and manual chart mapping concepts to create a cleaner and faster workflow directly on TradingView.

As always happy trading everyone.

## Source Code

````pine
//@version=6
indicator("33 Ultimate Killzone Direction Gann Zones", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// GLOBAL SETTINGS
tz = input.string("Etc/GMT+4", "Timezone UTC-4")

showBoxes = input.bool(true, "Show Killzone Boxes")
lineWidth = input.int(1, "Line Thickness", minval=1, maxval=5)
keepZones = input.int(100, "Max Zones To Keep", minval=5, maxval=100)

// TIMEFRAME VISIBILITY
maxVisibleTF = input.int(15, "Show Indicator Up To Timeframe Minutes", options=[1, 3, 5, 10, 15, 30])
tfMinutes = timeframe.in_seconds(timeframe.period) / 60
tfAllowed = tfMinutes <= maxVisibleTF

// LABEL SIZE
labelSizeInput = input.string("small", "Label Size", options=["tiny", "small", "normal", "large"])

labelSize =
     labelSizeInput == "tiny" ? size.tiny :
     labelSizeInput == "small" ? size.small :
     labelSizeInput == "normal" ? size.normal :
     size.large

// DIRECTION FILTER
useBodyFilter = input.bool(true, "Use Direction Strength Filter")

minBodyPercent = input.float(
     15.0,
     "Minimum Direction Strength %",
     minval=0.0,
     maxval=100.0,
     step=1.0)

// SESSION SETTINGS
showAsia   = input.bool(true, "Show Asia Killzone")
asiaSess   = input.session("2000-0000", "Asia Killzone")
asiaTP1    = input.bool(true, "Asia TP1")
asiaTP2    = input.bool(true, "Asia TP2")
asiaTP3    = input.bool(false, "Asia TP3")

showLondon = input.bool(true, "Show London Killzone")
londonSess = input.session("0200-0500", "London Killzone")
londonTP1  = input.bool(true, "London TP1")
londonTP2  = input.bool(true, "London TP2")
londonTP3  = input.bool(false, "London TP3")

showNYAM   = input.bool(true, "Show NY AM Killzone")
nyamSess   = input.session("0930-1100", "NY AM Killzone")
nyamTP1    = input.bool(true, "NY AM TP1")
nyamTP2    = input.bool(true, "NY AM TP2")
nyamTP3    = input.bool(false, "NY AM TP3")

showNYLunch   = input.bool(true, "Show NY Lunch Killzone")
nyLunchSess   = input.session("1200-1300", "NY Lunch Killzone")
nyLunchTP1    = input.bool(true, "NY Lunch TP1")
nyLunchTP2    = input.bool(true, "NY Lunch TP2")
nyLunchTP3    = input.bool(false, "NY Lunch TP3")

showNYPM   = input.bool(true, "Show NY PM Killzone")
nyPMSess   = input.session("1330-1600", "NY PM Killzone")
nyPMTP1    = input.bool(true, "NY PM TP1")
nyPMTP2    = input.bool(true, "NY PM TP2")
nyPMTP3    = input.bool(false, "NY PM TP3")

// COLOR SETTINGS
asiaBoxColor     = input.color(color.new(color.blue, 90), "Asia Box Color")
londonBoxColor   = input.color(color.new(color.red, 90), "London Box Color")
nyamBoxColor     = input.color(color.new(color.gray, 90), "NY AM Box Color")
nyLunchBoxColor  = input.color(color.new(color.purple, 90), "NY Lunch Box Color")
nyPMBoxColor     = input.color(color.new(color.teal, 90), "NY PM Box Color")

bullTP1Color = input.color(color.black, "Bullish TP1 Color")
bullTP2Color = input.color(color.orange, "Bullish TP2 Color")
bullTP3Color = input.color(color.blue, "Bullish TP3 Color")

bearTP1Color = input.color(color.black, "Bearish TP1 Color")
bearTP2Color = input.color(color.orange, "Bearish TP2 Color")
bearTP3Color = input.color(color.blue, "Bearish TP3 Color")

bullTextColor = input.color(color.black, "Bullish Label Color")
bearTextColor = input.color(color.black, "Bearish Label Color")

// STORAGE ARRAYS
var line[] activeLines = array.new_line()
var float[] activePrices = array.new_float()
var string[] activeTypes = array.new_string()
var bool[] activeHit = array.new_bool()
var label[] activeLabels = array.new_label()
var box[] activeBoxes = array.new_box()

// HELPERS
priceText(price) =>
    str.tostring(price, format.mintick)

addTarget(sessionName, endBar, price, targetName, direction, lineColor, textColor) =>
    newLine = line.new(
         endBar,
         price,
         endBar + 1,
         price,
         extend=extend.right,
         color=lineColor,
         width=lineWidth)

    newLabel = label.new(
         endBar,
         price,
         sessionName + " " + targetName + " " + priceText(price),
         style=label.style_none,
         textcolor=textColor,
         size=labelSize)

    array.push(activeLines, newLine)
    array.push(activePrices, price)
    array.push(activeTypes, direction)
    array.push(activeHit, false)
    array.push(activeLabels, newLabel)

// CREATE SESSION TARGETS
createZone(sessionName, startBar, endBar, o, h, l, c, boxColor, useTP1, useTP2, useTP3) =>

    rangeSize = h - l
    bodySize = math.abs(c - o)

    bodyPercent =
         rangeSize > 0 ?
         (bodySize / rangeSize) * 100 :
         0

    validDirection =
         not useBodyFilter or
         bodyPercent >= minBodyPercent

    bull = c > o and validDirection
    bear = c < o and validDirection

    if bull
        tp1 = h
        tp2 = l + rangeSize * 1.5
        tp3 = l + rangeSize * 2.0

        if useTP1
            addTarget(sessionName, endBar, tp1, "TP 1", "bull", bullTP1Color, bullTextColor)

        if useTP2
            addTarget(sessionName, endBar, tp2, "TP 2", "bull", bullTP2Color, bullTextColor)

        if useTP3
            addTarget(sessionName, endBar, tp3, "TP 3", "bull", bullTP3Color, bullTextColor)

    if bear
        tp1 = l
        tp2 = h - rangeSize * 1.5
        tp3 = h - rangeSize * 2.0

        if useTP1
            addTarget(sessionName, endBar, tp1, "TP 1", "bear", bearTP1Color, bearTextColor)

        if useTP2
            addTarget(sessionName, endBar, tp2, "TP 2", "bear", bearTP2Color, bearTextColor)

        if useTP3
            addTarget(sessionName, endBar, tp3, "TP 3", "bear", bearTP3Color, bearTextColor)

// SESSION FUNCTION
trackSession(showSession, sessionTime, sessionName, boxColor, useTP1, useTP2, useTP3) =>

    sessionIn  = showSession and tfAllowed and not na(time(timeframe.period, sessionTime, tz))
    sessionNew = sessionIn and not sessionIn[1]
    sessionEnd = not sessionIn and sessionIn[1]

    var float sOpen = na
    var float sHigh = na
    var float sLow = na
    var float sClose = na
    var int sStart = na
    var box sBox = na

    if sessionNew
        sOpen := open
        sHigh := high
        sLow := low
        sStart := bar_index

        if showBoxes
            sBox := box.new(
                 sStart,
                 sHigh,
                 bar_index,
                 sLow,
                 bgcolor=boxColor,
                 border_color=color.new(boxColor, 40))

    if sessionIn
        sHigh := math.max(sHigh, high)
        sLow := math.min(sLow, low)

        if showBoxes and not na(sBox)
            box.set_right(sBox, bar_index)
            box.set_top(sBox, sHigh)
            box.set_bottom(sBox, sLow)

    if sessionEnd
        sClose := close[1]

        if showBoxes and not na(sBox)
            box.set_right(sBox, bar_index)
            array.push(activeBoxes, sBox)

        createZone(sessionName, sStart, bar_index, sOpen, sHigh, sLow, sClose, boxColor, useTP1, useTP2, useTP3)

// TRACK ALL SESSIONS
trackSession(showAsia, asiaSess, "Asia", asiaBoxColor, asiaTP1, asiaTP2, asiaTP3)
trackSession(showLondon, londonSess, "London", londonBoxColor, londonTP1, londonTP2, londonTP3)
trackSession(showNYAM, nyamSess, "NY AM", nyamBoxColor, nyamTP1, nyamTP2, nyamTP3)
trackSession(showNYLunch, nyLunchSess, "NY Lunch", nyLunchBoxColor, nyLunchTP1, nyLunchTP2, nyLunchTP3)
trackSession(showNYPM, nyPMSess, "NY PM", nyPMBoxColor, nyPMTP1, nyPMTP2, nyPMTP3)

// STOP EXTENDING WHEN HIT
lineCount = array.size(activeLines)

if lineCount > 0
    for i = 0 to lineCount - 1

        alreadyHit = array.get(activeHit, i)

        if not alreadyHit

            levelPrice = array.get(activePrices, i)
            levelType  = array.get(activeTypes, i)

            touched =
                 (levelType == "bull" and high >= levelPrice) or
                 (levelType == "bear" and low <= levelPrice)

            if touched
                currentLine = array.get(activeLines, i)

                line.set_extend(currentLine, extend.none)
                line.set_x2(currentLine, bar_index)

                array.set(activeHit, i, true)

// CLEANUP OLD OBJECTS
while array.size(activeLines) > keepZones * 15
    line.delete(array.shift(activeLines))
    array.shift(activePrices)
    array.shift(activeTypes)
    array.shift(activeHit)

while array.size(activeLabels) > keepZones * 15
    label.delete(array.shift(activeLabels))

while array.size(activeBoxes) > keepZones * 5
    box.delete(array.shift(activeBoxes))
````
