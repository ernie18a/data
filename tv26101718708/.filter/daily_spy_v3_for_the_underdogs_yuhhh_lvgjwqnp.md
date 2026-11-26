# Daily spy v3 for the underdogs yuhhh

- url: https://www.tradingview.com/script/LVgJwqnP-Daily-spy-v3-for-the-underdogs-yuhhh/
- type: indicator
- pine_id: PUB;4c23865cfb2941f88ca043517f8a46a1
- version: 1.0

## Description

its private and only for the underdogs, only real ones get to know lmao

## Source Code

````pine
//@version=6
indicator("Daily spy", overlay=true, max_lines_count=500)

// =========================
// Inputs
// =========================
gammaMVC  = input.float(defval=500.00, title="Gamma MVC (Center Level)", step=0.01)
straddle  = input.float(defval=5.00, title="Straddle", step=0.01)
lineWidth = input.int(defval=2, title="Line Width", minval=1, maxval=5)
forwardBars = input.int(defval=300, title="Forward Projection Bars")

// =========================
// Colors
// =========================
centerColor = color.white
aboveColor  = color.green
belowColor  = color.red

// =========================
// Multipliers
// =========================
var float[] multipliers = array.from(0.25, 0.50, 0.75, 1.00, 1.25, 1.50, 1.75, 2.00, 2.25, 2.50, 2.75, 3.00)

// =========================
// Storage
// =========================
var line centerLine = na
var line[] aboveLines = array.new_line()
var line[] belowLines = array.new_line()

// =========================
// Detect new day
// =========================
isNewDay = ta.change(time("D")) != 0

var int dayStartBar = na

if barstate.isfirst
    dayStartBar := bar_index

if isNewDay
    dayStartBar := bar_index

// =========================
// Reset on new day
// =========================
if isNewDay
    if not na(centerLine)
        line.delete(centerLine)

    for i = 0 to array.size(aboveLines) - 1
        line.delete(array.get(aboveLines, i))

    for i = 0 to array.size(belowLines) - 1
        line.delete(array.get(belowLines, i))

    array.clear(aboveLines)
    array.clear(belowLines)

    // Center
    centerLine := line.new(
         x1=dayStartBar, y1=gammaMVC,
         x2=bar_index + forwardBars, y2=gammaMVC,
         xloc=xloc.bar_index,
         extend=extend.none,
         color=centerColor,
         width=lineWidth
     )

    // Levels
    for i = 0 to array.size(multipliers) - 1
        mult = array.get(multipliers, i)

        upperLevel = gammaMVC + (straddle * mult)
        lowerLevel = gammaMVC - (straddle * mult)

        upperLine = line.new(
             x1=dayStartBar, y1=upperLevel,
             x2=bar_index + forwardBars, y2=upperLevel,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=aboveColor,
             width=lineWidth
         )

        lowerLine = line.new(
             x1=dayStartBar, y1=lowerLevel,
             x2=bar_index + forwardBars, y2=lowerLevel,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=belowColor,
             width=lineWidth
         )

        array.push(aboveLines, upperLine)
        array.push(belowLines, lowerLine)

// =========================
// First load
// =========================
if barstate.isfirst
    centerLine := line.new(
         x1=dayStartBar, y1=gammaMVC,
         x2=bar_index + forwardBars, y2=gammaMVC,
         xloc=xloc.bar_index,
         extend=extend.none,
         color=centerColor,
         width=lineWidth
     )

    for i = 0 to array.size(multipliers) - 1
        mult = array.get(multipliers, i)

        upperLevel = gammaMVC + (straddle * mult)
        lowerLevel = gammaMVC - (straddle * mult)

        upperLine = line.new(
             x1=dayStartBar, y1=upperLevel,
             x2=bar_index + forwardBars, y2=upperLevel,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=aboveColor,
             width=lineWidth
         )

        lowerLine = line.new(
             x1=dayStartBar, y1=lowerLevel,
             x2=bar_index + forwardBars, y2=lowerLevel,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=belowColor,
             width=lineWidth
         )

        array.push(aboveLines, upperLine)
        array.push(belowLines, lowerLine)

// =========================
// Update every bar
// =========================
if not na(centerLine)
    line.set_x1(centerLine, dayStartBar)
    line.set_x2(centerLine, bar_index + forwardBars)
    line.set_y1(centerLine, gammaMVC)
    line.set_y2(centerLine, gammaMVC)

for i = 0 to array.size(aboveLines) - 1
    mult = array.get(multipliers, i)
    lvl = gammaMVC + (straddle * mult)
    l = array.get(aboveLines, i)

    line.set_x1(l, dayStartBar)
    line.set_x2(l, bar_index + forwardBars)
    line.set_y1(l, lvl)
    line.set_y2(l, lvl)

for i = 0 to array.size(belowLines) - 1
    mult = array.get(multipliers, i)
    lvl = gammaMVC - (straddle * mult)
    l = array.get(belowLines, i)

    line.set_x1(l, dayStartBar)
    line.set_x2(l, bar_index + forwardBars)
    line.set_y1(l, lvl)
    line.set_y2(l, lvl)
````
