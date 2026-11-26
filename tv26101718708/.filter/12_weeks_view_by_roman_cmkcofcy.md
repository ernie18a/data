# 12 Weeks View [by Roman]

- url: https://www.tradingview.com/script/CmKcoFcY-12-Weeks-View-by-Roman/
- type: indicator
- pine_id: PUB;83df3b0ce88b4a229d9127d1097ddbed
- version: 1.0

## Description

A clean market structure indicator designed for traders who focus on liquidity, key levels, and higher-timeframe context.

[b]Features[/b]
[list]
[*]Weekly Start Markers
[*]Draws vertical lines at the beginning of each week.
[*]Displays only the most recent 12 weeks to keep the chart clean.
[*]Weekly line color is fully customizable.
[*]12-Week Extreme Levels
[*]Calculates the highest high from the previous 12 completed weeks.
[*]Calculates the lowest low from the previous 12 completed weeks.
[*]Displays a single horizontal level for each extreme.
[*]High and Low line colors can be customized independently.
[/list]

[b]Why Use It?[/b]
The highest and lowest points of the last 12 weeks often act as significant liquidity pools and major support/resistance levels. These areas are frequently referenced by:
[list]
[*]Smart Money Concept (SMC) traders
[*]ICT traders
[*]Swing traders
[*]Position traders
[*]Market structure analysts
[/list]

The weekly separators provide clear temporal context, helping traders identify:
[list]
[*]Weekly range development
[*]Liquidity sweeps
[*]Breakouts from multi-week consolidation
[*]Reactions at major higher-timeframe levels
[*]Settings
[*]Weekly Start Line Color
[/list]

Controls the color of the weekly separator lines.

[b]Best Used For[/b]
[list]
[*]Cryptocurrency markets
[*]Forex markets
[*]Indices
[*]Stocks
[*]Multi-timeframe analysis
[/list]

This indicator is intentionally minimalistic, providing only the most relevant weekly structure information without cluttering the chart.

## Source Code

````pine
//@version=6
indicator("12 Weeks View [by Roman]", overlay=true, max_lines_count=500)

// === Inputs ===
weekLineColor = input.color(color.rgb(238, 238, 238), "Weekly Start Line Color")
highLineColor = input.color(color.rgb(255, 197, 197), "12W Highest High Color")
lowLineColor  = input.color(color.rgb(255, 197, 197), "12W Lowest Low Color")

// === Weekly Start Lines ===
var line[] weekLines = array.new_line()

isNewWeek = ta.change(time("W")) != 0

if isNewWeek
    weekLine = line.new(
         bar_index,
         low,
         bar_index,
         high,
         extend=extend.both,
         color=weekLineColor,
         width=1
     )

    array.push(weekLines, weekLine)

    if array.size(weekLines) > 12
        line.delete(array.shift(weekLines))

// === Highest / Lowest of Previous 12 Completed Weeks ===
highest12W = request.security(
     syminfo.tickerid,
     "W",
     ta.highest(high[1], 12),
     lookahead=barmerge.lookahead_on)

lowest12W = request.security(
     syminfo.tickerid,
     "W",
     ta.lowest(low[1], 12),
     lookahead=barmerge.lookahead_on)

// === Persistent Lines ===
var line highestLine = na
var line lowestLine  = na

if barstate.isfirst
    highestLine := line.new(
         bar_index,
         highest12W,
         bar_index + 1,
         highest12W,
         extend=extend.right,
         color=highLineColor,
         width=1)

    lowestLine := line.new(
         bar_index,
         lowest12W,
         bar_index + 1,
         lowest12W,
         extend=extend.right,
         color=lowLineColor,
         width=1)

// Update lines continuously
line.set_y1(highestLine, highest12W)
line.set_y2(highestLine, highest12W)
line.set_color(highestLine, highLineColor)

line.set_y1(lowestLine, lowest12W)
line.set_y2(lowestLine, lowest12W)
line.set_color(lowestLine, lowLineColor)
````
