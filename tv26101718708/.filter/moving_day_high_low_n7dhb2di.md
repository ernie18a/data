# Moving Day High & Low

- url: https://www.tradingview.com/script/n7dHB2dI-Moving-Day-High-Low/
- type: indicator
- pine_id: PUB;25ecf75f61204d418a127c63e76a42ed
- version: 1.0

## Description

day time frame - green bar for high and low insight

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © dre4169

//@version=6
indicator("Moving Day High & Low", overlay=true, max_lines_count=10, max_labels_count=10)

// Current day high/low
dayHigh = request.security(syminfo.tickerid, "D", high, lookahead=barmerge.lookahead_on)
dayLow  = request.security(syminfo.tickerid, "D", low,  lookahead=barmerge.lookahead_on)

// Line objects
var line highLine = na
var line lowLine = na

// Label objects
var label highLabel = na
var label lowLabel = na

// Create lines once
if na(highLine)
    highLine := line.new(
         bar_index,
         dayHigh,
         bar_index + 1,
         dayHigh,
         extend=extend.right,
         color=color.lime,
         width=2)

    lowLine := line.new(
         bar_index,
         dayLow,
         bar_index + 1,
         dayLow,
         extend=extend.right,
         color=color.lime,
         width=2)

// Update lines continuously
line.set_y1(highLine, dayHigh)
line.set_y2(highLine, dayHigh)

line.set_y1(lowLine, dayLow)
line.set_y2(lowLine, dayLow)

// Update labels
if barstate.islast
    label.delete(highLabel)
    label.delete(lowLabel)

    highLabel := label.new(
         bar_index,
         dayHigh,
         "Day's High",
         style=label.style_label_down,
         color=color.lime,
         textcolor=color.black,
         size=size.small)

    lowLabel := label.new(
         bar_index,
         dayLow,
         "Day's Low",
         style=label.style_label_up,
         color=color.lime,
         textcolor=color.black,
         size=size.small)
````
