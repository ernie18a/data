# NQ Key Levels (20/33/66/80)

- url: https://www.tradingview.com/script/nDqYULwu-NQ-Key-Levels-20-33-66-80/
- type: indicator
- pine_id: PUB;60757bd9ec8d42a2b64648c6a295c1e3
- version: 1.0

## Description

This script highlights 20, 33, 66 and 80 levels on NQ

## Source Code

````pine
//@version=5
indicator("NQ Key Levels (20/33/66/80)", overlay=true, max_lines_count=500)

// Settings
lookback    = input.int(50, "Levels Above/Below", minval=10, maxval=100)
color20     = input.color(color.new(#00BFFF, 0),  "XX20 Color")
color80     = input.color(color.new(#FF4500, 0),  "XX80 Color")
color33     = input.color(color.new(#ADFF2F, 0),  "XX33 Color")
color66     = input.color(color.new(#FF69B4, 0),  "XX66 Color")
lineWidth   = input.int(1, "Line Width", minval=1, maxval=4)
lineStyle   = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"])

getStyle(s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

style = getStyle(lineStyle)

var line[] allLines = array.new_line()

if barstate.islast
    // Delete existing lines safely
    if array.size(allLines) > 0
        for i = 0 to array.size(allLines) - 1
            line.delete(array.get(allLines, i))
        array.clear(allLines)

    // Draw new lines around current price
    startBase = (math.floor(close / 100) - lookback) * 100

    for i = 0 to lookback * 2
        b = startBase + i * 100

        l20 = line.new(bar_index, b + 20, bar_index + 1, b + 20,
             color=color20, width=lineWidth, style=style, extend=extend.both)
        l80 = line.new(bar_index, b + 80, bar_index + 1, b + 80,
             color=color80, width=lineWidth, style=style, extend=extend.both)
        l33 = line.new(bar_index, b + 33, bar_index + 1, b + 33,
             color=color33, width=lineWidth, style=style, extend=extend.both)
        l66 = line.new(bar_index, b + 66, bar_index + 1, b + 66,
             color=color66, width=lineWidth, style=style, extend=extend.both)

        array.push(allLines, l20)
        array.push(allLines, l80)
        array.push(allLines, l33)
        array.push(allLines, l66)
````
