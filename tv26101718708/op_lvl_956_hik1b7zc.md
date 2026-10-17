# op lvl 956

- url: https://www.tradingview.com/script/hIk1b7Zc-op-lvl-956/
- type: indicator
- pine_id: PUB;f77fd10a66d14c9c8b34522f648c7f2c
- version: 1.0

## Description

regular trading hours (830 am CST opening bar level auto print)

## Source Code

````pine
//@version=6
indicator("RTH Opening Print (8:30 CST)", overlay = true, max_lines_count = 500)

// ─── Inputs ──────────────────────────────────────────────────────────────────
openTime    = input.session("0830-0831", "Open Time (1-min window)")
timezone    = input.string("America/Chicago", "Timezone",
                           options = ["America/Chicago", "America/New_York", "Etc/UTC"])
lineColor   = input.color(color.yellow, "Line Color")
lineWidth   = input.int(2, "Line Width", minval = 1, maxval = 5)
lineStyle   = input.string("Solid", "Line Style", options = ["Solid", "Dashed", "Dotted"])
extendRight = input.bool(true, "Extend Line to Right Edge")
showHistory = input.bool(true, "Show Previous Days")

getStyle(s) =>
    s == "Dashed" ? line.style_dashed :
     s == "Dotted" ? line.style_dotted :
     line.style_solid

// ─── Detect the first bar at/after 8:30 CST each day ────────────────────────
inOpenWindow = not na(time(timeframe.period, openTime, timezone))
isOpeningBar = inOpenWindow and not inOpenWindow[1]

var float dayOpen  = na
var line  openLine = na

if isOpeningBar
    if not showHistory and not na(openLine)
        line.delete(openLine)

    dayOpen := open

    openLine := line.new(
         x1 = bar_index,     y1 = dayOpen,
         x2 = bar_index + 1, y2 = dayOpen,
         color = lineColor, width = lineWidth,
         style = getStyle(lineStyle),
         extend = extendRight ? extend.right : extend.none)

// Stretch current day's line forward (only when not extending right)
if not na(openLine) and not extendRight
    line.set_x2(openLine, bar_index)
````
