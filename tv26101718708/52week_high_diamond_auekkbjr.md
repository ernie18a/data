# 52-Week High Diamond

- url: https://www.tradingview.com/script/AuEkKbjR-52-Week-High-Diamond/
- type: indicator
- pine_id: PUB;d74ef4c2ee4e4ec49466537e829c2ae0
- version: 9.0

## Description

Marks every bar that made a new 52-week high with a small diamond above the wick. The most recent 52-week high is highlighted in full color so it stands out at a glance. All prior highs display at reduced opacity to keep the chart clean without losing the historical context.
Useful for quickly identifying where a stock has been making new highs, how frequently it's been doing so, and how far back the most recent high occurred — all without cluttering your chart.

[b]Settings[/b]
[list]
[*]Toggle all historical 52-week high diamonds on/off
[*]Toggle the most recent 52-week high diamond on/off
[*]Custom color picker
[*]Adjustable vertical offset
[/list]

## Source Code

````pine
//@version=6
// @author=Vin Thomas
indicator("Diamond Highs - 52 Week High Indicator with ATH", shorttitle="Diamond Highs", overlay=true)

// Diamond settings
showAll    = input.bool(true,  "Show All 52-Week Highs",        group = "Diamonds")
showLatest = input.bool(true,  "Show Most Recent 52-Week High", group = "Diamonds")
highColor  = input.color(color.green, "Diamond Color",          group = "Diamonds")
offsetPct  = input.float(0.5,  "Vertical Offset %", minval=0.0, step=0.2, group = "Diamonds") / 100

// All-time high settings
showATH      = input.bool(true,  "Highlight All-Time High",    group = "All-Time High")
athColor     = input.color(color.rgb(233, 30, 99), "ATH Diamond Color", group = "All-Time High")
showATHLabel = input.bool(false, "Show ATH Label",             group = "All-Time High")

// Line settings
showLine       = input.bool(false, "Show 52-Week High Line",   group = "High Line")
lineColor      = input.color(color.rgb(76, 175, 80), "Line Color", group = "High Line")
lineStyleInput = input.string("Dotted", "Line Style",
     options = ["Solid", "Dashed", "Dotted"],
     group   = "High Line")

lineStyle = switch lineStyleInput
    "Solid"  => line.style_solid
    "Dashed" => line.style_dashed
    => line.style_dotted

// Timeframe-aware lookback: 252 daily bars, 52 weekly bars, 12 monthly bars
barsPerYear = timeframe.isweekly  ? 52  :
              timeframe.ismonthly ? 12  : 252
minBars     = barsPerYear - 1

// Logic — suppress entirely if fewer than barsPerYear bars exist
is52WeekHigh = bar_index >= minBars and high == ta.highest(high, barsPerYear)

var float lastHighPrice = na
var int   lastHighTime  = na
var float[] highPrices  = array.new_float()
var int[]   highTimes   = array.new_int()

if is52WeekHigh
    lastHighPrice := high
    lastHighTime  := time
    array.push(highPrices, high)
    array.push(highTimes,  time)

if barstate.islast and array.size(highPrices) > 0
    athPrice = array.max(highPrices)

    if showAll
        for i = 0 to array.size(highTimes) - 2
            barPrice     = array.get(highPrices, i)
            barTime      = array.get(highTimes,  i)
            isBarATH     = showATH and barPrice == athPrice
            diamondColor = isBarATH ? athColor : color.new(highColor, 70)
            label.new(
                 x         = barTime,
                 y         = barPrice * (1 + offsetPct),
                 text      = "◆",
                 xloc      = xloc.bar_time,
                 style     = label.style_none,
                 textcolor = diamondColor,
                 size      = size.small,
                 yloc      = yloc.price)
            if isBarATH and showATHLabel
                label.new(
                     x         = barTime,
                     y         = barPrice * (1 + offsetPct),
                     text      = "ATH",
                     xloc      = xloc.bar_time,
                     style     = label.style_label_down,
                     color     = athColor,
                     textcolor = color.white,
                     size      = size.small,
                     yloc      = yloc.price)

    if showLatest and not na(lastHighTime)
        isLatestATH = showATH and lastHighPrice == athPrice
        latestColor = isLatestATH ? athColor : highColor
        label.new(
             x         = lastHighTime,
             y         = lastHighPrice * (1 + offsetPct),
             text      = "◆",
             xloc      = xloc.bar_time,
             style     = label.style_none,
             textcolor = latestColor,
             size      = size.small,
             yloc      = yloc.price)
        if isLatestATH and showATHLabel
            label.new(
                 x         = lastHighTime,
                 y         = lastHighPrice * (1 + offsetPct),
                 text      = "ATH",
                 xloc      = xloc.bar_time,
                 style     = label.style_label_down,
                 color     = athColor,
                 textcolor = color.white,
                 size      = size.small,
                 yloc      = yloc.price)

    if showLine and not na(lastHighTime)
        line.new(
             x1     = lastHighTime,
             y1     = lastHighPrice,
             x2     = time,
             y2     = lastHighPrice,
             xloc   = xloc.bar_time,
             extend = extend.right,
             color  = lineColor,
             style  = lineStyle,
             width  = 1)
````
