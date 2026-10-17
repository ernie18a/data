# Midnight NY Open

- url: https://www.tradingview.com/script/XEKg7SOh-Midnight-NY-Open/
- type: indicator
- pine_id: PUB;1e65bfe6728f454fae661e436b2a63a4
- version: 1.0

## Description

[i][b]Marks one of the more important price levels of each day — the price at midnight New York time. A simple dark blue line labeled with "Midnight NY" and its price. The indicator resets daily: each line ends right as the next midnight begins, giving a clean, simple guide to reference throughout the trading session.[/b][/i]

## Source Code

````pine

//@version=6
indicator("NY Midnight Open Line", overlay=true, max_lines_count=500)

// ───────────────────────────────────────────────────────────
// INPUTS
// ───────────────────────────────────────────────────────────
lineColor   = input.color(#1E3A8A, "Line Color")
lineWidth   = input.int(2, "Line Width", minval=1, maxval=5)
lineStyleIn = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"])
extendRight = input.bool(false, "Extend last line into the future (until next midnight arrives)")
showLabel   = input.bool(true, "Show Price Label")
nyTimezone  = "America/New_York"

lineStyle = lineStyleIn == "Solid" ? line.style_solid : lineStyleIn == "Dashed" ? line.style_dashed : line.style_dotted

// ───────────────────────────────────────────────────────────
// DETECT NEW NY DAY (MIDNIGHT) — robust version
// ───────────────────────────────────────────────────────────
// Instead of relying on the session-string time() function (which can
// misfire on certain timeframes/chart types), we directly compare the
// calendar date in New York time, bar to bar.
nyYear  = year(time, nyTimezone)
nyMonth = month(time, nyTimezone)
nyDate  = dayofmonth(time, nyTimezone)

newNYDay = ta.change(nyDate) != 0 or ta.change(nyMonth) != 0 or ta.change(nyYear) != 0

// ───────────────────────────────────────────────────────────
// STATE
// ───────────────────────────────────────────────────────────
var line  currentLine    = na
var label currentLabel   = na
var float midnightPrice  = na
var int   midnightBarIdx = na

if newNYDay
    // freeze the previous line exactly where it is — do not touch it again
    if not na(currentLine)
        line.set_extend(currentLine, extend.none)

    // anchor a brand new line at this bar's open price (the midnight open)
    midnightPrice  := open
    midnightBarIdx := bar_index

    currentLine := line.new(
         x1=bar_index, y1=midnightPrice,
         x2=bar_index, y2=midnightPrice,
         xloc=xloc.bar_index,
         extend=extend.none,
         color=lineColor,
         style=lineStyle,
         width=lineWidth)

    if showLabel
        currentLabel := label.new(
             x=bar_index, y=midnightPrice,
             text="Midnight NY: " + str.tostring(midnightPrice),
             xloc=xloc.bar_index,
             style=label.style_label_left,
             color=color.new(color.black, 100),
             textcolor=lineColor,
             size=size.small)

// only the CURRENT (most recent) line's right edge moves forward each bar.
// every prior day's line was frozen above and is never touched again.
if not na(currentLine) and bar_index >= midnightBarIdx
    newX2 = extendRight ? bar_index + 50 : bar_index
    line.set_x2(currentLine, newX2)
    // y2 is intentionally NOT reset every bar beyond creation — it was fixed at midnightPrice on creation
    if showLabel and not na(currentLabel)
        label.set_x(currentLabel, bar_index)
````
