# [Dark Data] Psychological Levels

- url: https://www.tradingview.com/script/rzYVr9VJ-Dark-Data-Psychological-Levels/
- type: indicator
- pine_id: PUB;0436f67e1b6049b7bebbc8eafd395f68
- version: 1.0

## Description

[b]Objective[/b]
Adds levels on your chart based on chosen intervals for rounded numbers.

[b]Theory[/b]
Rounded price levels attract order flow due to psychological bias. This increased interest can influence price action and liquidity behaviour.

[b]How To Use[/b]
Increase the division value to generate wider and typically stronger psychological levels, especially divisions ending in 1 or 5. 
Designed to stay lightweight so multiple instances can be stacked to visualize levels of different significance.

## Source Code

````pine
// This Pine Script code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Copyright DarkData_Official

//@version=6
indicator("[Dark Data] Psychological Levels", shorttitle="Psychological Levels", overlay=true)

// ============================================================================
// INPUT SETTINGS
// ============================================================================

grpCore = "Core Settings"
levelDivision = input.float(0.01, "Level Division", minval=0.00001, step=0.00001, group=grpCore,
                             tooltip="The interval for each level (e.g. 0.01, 0.005, 100)")
totalLines = input.int(10, "Total Lines", minval=2, maxval=500, step=1, group=grpCore,
                         tooltip="Total number of lines to draw, split above and below current price.")

grpStyle = "Visuals"
levelColor = input.color(color.new(color.gray, 50), "Level Color", group=grpStyle)
levelWidth = input.int(2, "Line Width", minval=1, maxval=4, group=grpStyle)
levelStyle = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group=grpStyle)

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

// Convert input string to line.style
f_lineStyle(styleStr) =>
    switch styleStr
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

// Calculate the nearest psychological level to current price.
f_nearestPsychLevel(price, division) =>
    lowerLevel = math.floor(price / division) * division
    upperLevel = lowerLevel + division
    price - lowerLevel <= upperLevel - price ? lowerLevel : upperLevel

// ============================================================================
// MAIN LOGIC
// ============================================================================

var line[] psychLines = array.new_line()
var float currentBottom = na
var float currentTop = na
var float prevLevelDivision = na
var int prevTotalLines = na
var color prevLevelColor = na
var int prevLevelWidth = na
var string prevLevelStyle = na

levelsBelow = int(math.floor((totalLines - 1) / 2.0))
levelsAbove = totalLines - levelsBelow - 1
centerLevel = f_nearestPsychLevel(close, levelDivision)
targetBottom = centerLevel - levelsBelow * levelDivision
targetTop = centerLevel + levelsAbove * levelDivision
rebuild = barstate.isfirst or levelDivision != prevLevelDivision or totalLines != prevTotalLines or na(currentBottom) or close <= currentBottom or close >= currentTop

if rebuild
    while array.size(psychLines) > 0
        line.delete(array.pop(psychLines))

    // Build levels from the nearest level to current price and work outward.
    for i = 0 to totalLines - 1
        price = centerLevel - levelsBelow * levelDivision + i * levelDivision
        newLine = line.new(bar_index, price, bar_index + 1, price,
                           xloc=xloc.bar_index, extend=extend.both,
                           color=levelColor, width=levelWidth,
                           style=f_lineStyle(levelStyle))
        array.push(psychLines, newLine)

    currentBottom := targetBottom
    currentTop := targetTop
    prevLevelDivision := levelDivision
    prevTotalLines := totalLines
    prevLevelColor := levelColor
    prevLevelWidth := levelWidth
    prevLevelStyle := levelStyle
else
    styleChanged = levelColor != prevLevelColor or levelWidth != prevLevelWidth or levelStyle != prevLevelStyle
    if styleChanged and array.size(psychLines) > 0
        for i = 0 to array.size(psychLines) - 1
            l = array.get(psychLines, i)
            line.set_color(l, levelColor)
            line.set_width(l, levelWidth)
            line.set_style(l, f_lineStyle(levelStyle))
        prevLevelColor := levelColor
        prevLevelWidth := levelWidth
        prevLevelStyle := levelStyle
````
