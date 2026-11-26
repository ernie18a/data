# Current + Previous Day High/Low

- url: https://www.tradingview.com/script/eXyIxQQ1-Current-Previous-Day-High-Low/
- type: indicator
- pine_id: PUB;f71dc211e5e3445a9bae21d1a7cae021
- version: 1.0

## Description

marks the previous and current high and low - day timeframe.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © dre4169

//@version=6
indicator("Current + Previous Day High/Low", overlay=true, max_lines_count=20, max_labels_count=50)

//==================================================
// CURRENT DAY LEVELS
//==================================================
dayHigh = request.security(
     syminfo.tickerid,
     "D",
     high,
     lookahead=barmerge.lookahead_on)

dayLow = request.security(
     syminfo.tickerid,
     "D",
     low,
     lookahead=barmerge.lookahead_on)

//==================================================
// PREVIOUS DAY LEVELS
//==================================================
prevDayHigh = request.security(
     syminfo.tickerid,
     "D",
     high[1],
     lookahead=barmerge.lookahead_on)

prevDayLow = request.security(
     syminfo.tickerid,
     "D",
     low[1],
     lookahead=barmerge.lookahead_on)

//==================================================
// LINE OBJECTS
//==================================================
var line dayHighLine = na
var line dayLowLine = na

var line prevHighLine = na
var line prevLowLine = na

//==================================================
// CREATE LINES
//==================================================
if na(dayHighLine)

    // Current Day
    dayHighLine := line.new(
         bar_index,
         dayHigh,
         bar_index + 1,
         dayHigh,
         extend=extend.right,
         color=color.lime,
         width=2)

    dayLowLine := line.new(
         bar_index,
         dayLow,
         bar_index + 1,
         dayLow,
         extend=extend.right,
         color=color.lime,
         width=2)

    // Previous Day
    prevHighLine := line.new(
         bar_index,
         prevDayHigh,
         bar_index + 1,
         prevDayHigh,
         extend=extend.right,
         color=color.fuchsia,
         width=2)

    prevLowLine := line.new(
         bar_index,
         prevDayLow,
         bar_index + 1,
         prevDayLow,
         extend=extend.right,
         color=color.fuchsia,
         width=2)

//==================================================
// UPDATE LEVELS
//==================================================
line.set_y1(dayHighLine, dayHigh)
line.set_y2(dayHighLine, dayHigh)

line.set_y1(dayLowLine, dayLow)
line.set_y2(dayLowLine, dayLow)

line.set_y1(prevHighLine, prevDayHigh)
line.set_y2(prevHighLine, prevDayHigh)

line.set_y1(prevLowLine, prevDayLow)
line.set_y2(prevLowLine, prevDayLow)

//==================================================
// LABELS
//==================================================
var label dayHighLabel = na
var label dayLowLabel = na

var label prevHighLabel = na
var label prevLowLabel = na

if barstate.islast

    label.delete(dayHighLabel)
    label.delete(dayLowLabel)

    label.delete(prevHighLabel)
    label.delete(prevLowLabel)

    dayHighLabel := label.new(
         bar_index,
         dayHigh,
         "Day's High",
         style=label.style_label_down,
         color=color.lime,
         textcolor=color.black,
         size=size.small)

    dayLowLabel := label.new(
         bar_index,
         dayLow,
         "Day's Low",
         style=label.style_label_up,
         color=color.lime,
         textcolor=color.black,
         size=size.small)

    prevHighLabel := label.new(
         bar_index,
         prevDayHigh,
         "Previous Day High",
         style=label.style_label_down,
         color=color.fuchsia,
         textcolor=color.white,
         size=size.small)

    prevLowLabel := label.new(
         bar_index,
         prevDayLow,
         "Previous Day Low",
         style=label.style_label_up,
         color=color.fuchsia,
         textcolor=color.white,
         size=size.small)

//==================================================
// PREVIOUS DAY TOUCH DETECTION
//==================================================
newDay = timeframe.change("D")

var bool prevHighTouched = false
var bool prevLowTouched = false

if newDay
    prevHighTouched := false
    prevLowTouched := false

touchPrevHigh = not prevHighTouched and high >= prevDayHigh
touchPrevLow = not prevLowTouched and low <= prevDayLow

if touchPrevHigh
    prevHighTouched := true

    label.new(
         bar_index,
         prevDayHigh,
         "▼",
         style=label.style_none,
         textcolor=color.yellow,
         size=size.large)

if touchPrevLow
    prevLowTouched := true

    label.new(
         bar_index,
         prevDayLow,
         "▲",
         style=label.style_none,
         textcolor=color.yellow,
         size=size.large)

//==================================================
// ALERTS
//==================================================
alertcondition(
     touchPrevHigh,
     title="Previous Day High Taken",
     message="Price has touched or exceeded the Previous Day High.")

alertcondition(
     touchPrevLow,
     title="Previous Day Low Taken",
     message="Price has touched or fallen below the Previous Day Low.")
````
