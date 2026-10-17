# CPI Buy/Sell Stop

- url: https://www.tradingview.com/script/lNz4KGtR-CPI-Buy-Sell-Stop/
- type: indicator
- pine_id: PUB;090377b8cee84ada9f73cc46cd845060
- version: 1.0

## Description

puts buy and sell stops lines at certain price points for CPI

use between 25-35 points.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Price Level Lines

//@version=6
indicator("CPI Buy/Sell Stop", overlay=true, max_lines_count=500, max_labels_count=500)

// --- Inputs ---
pointSpacing    = input.float(10.0, "Points Between Levels", minval=0.25, step=0.25, tooltip="Distance in points between each level line")
levelsAbove     = input.int(5, "Levels Above", minval=0, maxval=50)
levelsBelow     = input.int(5, "Levels Below", minval=0, maxval=50)
srcPrice        = input.source(close, "Price Source")
aboveColor      = input.color(color.new(color.green, 30), "Above Line Color")
belowColor      = input.color(color.new(color.red, 30), "Below Line Color")
lineWidth       = input.int(1, "Line Width", minval=1, maxval=4)
lineStyle       = input.string("Dashed", "Line Style", options=["Solid", "Dashed", "Dotted"])
showLabels      = input.bool(true, "Show Price Labels")
labelSize       = input.string("small", "Label Size", options=["tiny", "small", "normal", "large"])
extendLines     = input.bool(false, "Extend Lines Full Width", tooltip="Extend lines across the entire chart instead of just recent bars")

// --- Helpers ---
getLineStyle(s) =>
    switch s
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted

getLabelSize(s) =>
    switch s
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large

// --- Draw only on the last bar ---
if barstate.islast
    // Clean up previous drawings
    while array.size(line.all) > 0
        line.delete(array.pop(line.all))
    while array.size(label.all) > 0
        label.delete(array.pop(label.all))

    basePrice  = srcPrice
    lStyle     = getLineStyle(lineStyle)
    lSize      = getLabelSize(labelSize)
    barLen     = 20
    extSetting = extendLines ? extend.both : extend.none
    x1         = extendLines ? bar_index - barLen : bar_index - barLen
    x2         = bar_index + 10

    // Draw levels above
    for i = 1 to levelsAbove
        lvl = basePrice + i * pointSpacing
        line.new(x1, lvl, x2, lvl, color=aboveColor, width=lineWidth, style=lStyle, extend=extSetting)
        if showLabels
            label.new(x2, lvl, str.tostring(lvl, format.mintick), style=label.style_none, textcolor=aboveColor, size=lSize)

    // Draw levels below
    for i = 1 to levelsBelow
        lvl = basePrice - i * pointSpacing
        line.new(x1, lvl, x2, lvl, color=belowColor, width=lineWidth, style=lStyle, extend=extSetting)
        if showLabels
            label.new(x2, lvl, str.tostring(lvl, format.mintick), style=label.style_none, textcolor=belowColor, size=lSize)

    // Draw base price line
    line.new(x1, basePrice, x2, basePrice, color=color.white, width=lineWidth + 1, style=line.style_solid, extend=extSetting)
    if showLabels
        label.new(x2, basePrice, str.tostring(basePrice, format.mintick), style=label.style_none, textcolor=color.white, size=lSize)
````
