# ES Balance Inventory Market Profile

- url: https://www.tradingview.com/script/WeZzkils-ES-Balance-Inventory-Market-Profile/
- type: indicator
- pine_id: PUB;3ef5c97abd03479698d70e07d21d131b
- version: 1.0

## Description

ES Balance Inventory Market Profile plots projected ES market-structure levels using a major historical balance zone as the anchor.

The script starts from a user-defined base balance range and projects that balance width upward in repeated increments. The purpose is to visualize how an important historical balance area can continue to act as a structural reference framework as price moves into higher regimes.

Psychology behind the indicator:

This indicator is inspired by inventory psychology, auction-market behavior, and balance-zone theory. The core idea is that markets often behave like inventory-driven businesses: price builds around a cost basis, then moves higher when inventory is marked up for distribution or lower when inventory has to be repriced.

A major balance zone can become a psychological anchor because traders, funds, and algorithms may continue to reference prior areas where meaningful business was done. The projected levels are meant to represent repeated inventory shelves above the original balance.

When price approaches one of these shelves, the key question is not whether the level will automatically hold. The useful information comes from how market participants behave around it: acceptance, rejection, failed breakdowns, failed breakouts, reclaim attempts, compression, expansion, volume response, and volatility response.

The psychology is also rooted in memory, positioning, and auction behavior. Large historical balance areas can leave a lasting footprint because traders remember them, systematic models may reference them, and price often rotates between structural zones when liquidity, positioning, or volatility changes.

Features:
• Uses a user-defined historical balance zone as the base range
• Projects repeated balance-width levels up to 10,000
• Plots clean horizontal structure levels directly on the chart
• Right-side labels make each level easy to read
• Current market zones from 5,000 to 8,000 are visible by default
• Users can enable or disable level ranges in 1,000-point increments
• Customizable colors, label spacing, and line extension settings

Suggested use:
Use these levels as structural reference zones, not as automatic buy or sell signals. The most useful information comes from how price behaves around a level: acceptance, rejection, reclaim, failure, compression, or expansion away from the zone.

This indicator can be used alongside price action, volume, VWAP, market profile, volatility, and broader market context to support discretionary analysis.

This script does not generate trade signals, does not predict future price movement, and does not provide financial advice. It is an educational and visual market-structure tool only. Trading involves risk, and users should make their own decisions based on their own analysis and risk tolerance.

## Source Code

````pine
//@version=6
indicator("ES Balance Inventory Market Profile", shorttitle="ES BalLvls", overlay=true, max_lines_count=500, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupBase = "Base Balance"
baseLow  = input.float(2749.75, "Base Balance Low", step=0.25, group=groupBase)
baseHigh = input.float(2810.25, "Base Balance High", step=0.25, group=groupBase)
maxLevel = input.float(10000.0, "Project Levels Up To", step=1.0, group=groupBase)

groupDisplay = "Display"
extendLeftBars  = input.int(1000, "Extend Left Bars", minval=50, maxval=5000, group=groupDisplay)
extendRightBars = input.int(300, "Extend Right Bars", minval=10, maxval=1000, group=groupDisplay)
showLabels      = input.bool(true, "Show Right-Side Labels", group=groupDisplay)
labelOffset     = input.int(8, "Label Offset", minval=1, maxval=100, group=groupDisplay)

labelBgColor   = input.color(color.new(color.black, 80), "Label Background Color", group=groupDisplay)
labelTextColor = input.color(color.white, "Label Text Color", group=groupDisplay)

groupLineStyle = "Line Style Settings"

regularColor = input.color(color.gray, "Regular Level Color", group=groupLineStyle)
regularWidth = input.int(1, "Regular Level Width", minval=1, maxval=5, group=groupLineStyle)
regularStyle = input.string("Dashed", "Regular Level Style", options=["Solid", "Dashed", "Dotted"], group=groupLineStyle)

baseColor = input.color(color.fuchsia, "Base Balance Color", group=groupLineStyle)
baseWidth = input.int(2, "Base Balance Width", minval=1, maxval=5, group=groupLineStyle)
baseStyle = input.string("Solid", "Base Balance Style", options=["Solid", "Dashed", "Dotted"], group=groupLineStyle)

majorColor = input.color(color.yellow, "1,000-Level Color", group=groupLineStyle)
majorWidth = input.int(2, "1,000-Level Width", minval=1, maxval=5, group=groupLineStyle)
majorStyle = input.string("Solid", "1,000-Level Style", options=["Solid", "Dashed", "Dotted"], group=groupLineStyle)

groupBuckets = "Enable / Disable Level Ranges"

// Default visible range: current market zones from 5k to 8k
show2000s  = input.bool(false, "Show 2,000 - 2,999", group=groupBuckets)
show3000s  = input.bool(false, "Show 3,000 - 3,999", group=groupBuckets)
show4000s  = input.bool(false, "Show 4,000 - 4,999", group=groupBuckets)
show5000s  = input.bool(true,  "Show 5,000 - 5,999", group=groupBuckets)
show6000s  = input.bool(true,  "Show 6,000 - 6,999", group=groupBuckets)
show7000s  = input.bool(true,  "Show 7,000 - 7,999", group=groupBuckets)
show8000s  = input.bool(false, "Show 8,000 - 8,999", group=groupBuckets)
show9000s  = input.bool(false, "Show 9,000 - 9,999", group=groupBuckets)
show10000s = input.bool(false, "Show 10,000+", group=groupBuckets)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Helpers
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_lineStyle(string styleInput) =>
    out = line.style_dashed

    if styleInput == "Solid"
        out := line.style_solid
    else if styleInput == "Dotted"
        out := line.style_dotted
    else
        out := line.style_dashed

    out

f_bucketEnabled(float lvl) =>
    bool enabled = false

    if lvl >= 2000 and lvl < 3000
        enabled := show2000s
    else if lvl >= 3000 and lvl < 4000
        enabled := show3000s
    else if lvl >= 4000 and lvl < 5000
        enabled := show4000s
    else if lvl >= 5000 and lvl < 6000
        enabled := show5000s
    else if lvl >= 6000 and lvl < 7000
        enabled := show6000s
    else if lvl >= 7000 and lvl < 8000
        enabled := show7000s
    else if lvl >= 8000 and lvl < 9000
        enabled := show8000s
    else if lvl >= 9000 and lvl < 10000
        enabled := show9000s
    else if lvl >= 10000
        enabled := show10000s

    enabled

f_isBaseLevel(float lvl) =>
    math.abs(lvl - baseLow) <= 0.01 or math.abs(lvl - baseHigh) <= 0.01

f_isMajorThousand(float lvl) =>
    math.abs(lvl % 1000) <= 0.25 or math.abs((lvl % 1000) - 1000) <= 0.25

f_levelColor(float lvl) =>
    color out = regularColor

    if f_isBaseLevel(lvl)
        out := baseColor
    else if f_isMajorThousand(lvl)
        out := majorColor

    out

f_levelWidth(float lvl) =>
    int out = regularWidth

    if f_isBaseLevel(lvl)
        out := baseWidth
    else if f_isMajorThousand(lvl)
        out := majorWidth

    out

f_levelStyle(float lvl) =>
    out = f_lineStyle(regularStyle)

    if f_isBaseLevel(lvl)
        out := f_lineStyle(baseStyle)
    else if f_isMajorThousand(lvl)
        out := f_lineStyle(majorStyle)

    out

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Drawing Storage
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var line[]  levelLines  = array.new_line()
var label[] levelLabels = array.new_label()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Clear Previous Drawings
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if barstate.islast
    if array.size(levelLines) > 0
        for i = 0 to array.size(levelLines) - 1
            line.delete(array.get(levelLines, i))
        array.clear(levelLines)

    if array.size(levelLabels) > 0
        for i = 0 to array.size(levelLabels) - 1
            label.delete(array.get(levelLabels, i))
        array.clear(levelLabels)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Level Generation
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Base balance anchor:
// 2749.75 - 2810.25
// Range = 60.50 points
balanceRange = math.abs(baseHigh - baseLow)

if barstate.islast and balanceRange > 0
    float lvl = baseLow

    while lvl <= maxLevel
        roundedLvl = math.round(lvl / syminfo.mintick) * syminfo.mintick

        if f_bucketEnabled(roundedLvl)
            lvlColor = f_levelColor(roundedLvl)
            lvlWidth = f_levelWidth(roundedLvl)
            lvlStyle = f_levelStyle(roundedLvl)

            newLine = line.new(
                 x1 = bar_index - extendLeftBars,
                 y1 = roundedLvl,
                 x2 = bar_index + extendRightBars,
                 y2 = roundedLvl,
                 color = lvlColor,
                 width = lvlWidth,
                 style = lvlStyle
            )

            array.push(levelLines, newLine)

            if showLabels
                newLabel = label.new(
                     x = bar_index + labelOffset,
                     y = roundedLvl,
                     text = str.tostring(roundedLvl, "#.##"),
                     color = labelBgColor,
                     textcolor = labelTextColor,
                     style = label.style_label_left,
                     size = size.tiny
                )

                array.push(levelLabels, newLabel)

        lvl += balanceRange
````
