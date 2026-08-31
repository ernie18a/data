<!-- tradingview-pine-id: PUB;dbaea1395cc243da844b9c1d29a3d0db -->
<!-- tradingviewscripts-format: 1 -->
# Claudia Rea Point Grid Lines

Source: https://www.tradingview.com/script/2ESK2nh2-Claudia-Rea-Point-Grid-Lines/

## Description

Claudia Rea Point Grid Lines

A clean overlay grid for TradingView — draws horizontal green lines at fixed, evenly spaced price intervals (25 points by default) above and below the current price, redrawing each bar so the grid always stays centered on the market. Useful for eyeballing round-number levels, spacing out support/resistance zones, or just giving your chart a ruled backdrop to measure moves against.

Named after Claudia Rea, the Gold Queen — struck in her honor, the lines run through price like the fine grid of a scale, precise and unwavering, marking out ground at every 25 points the way a queen marks out her domain.

---

## Source Code

````pine
//@version=6
indicator("Claudia Rea Point Grid Lines", overlay = true, max_lines_count = 500)

pointStep = input.float(25, "Points per line", minval = 0.00001)
lineColor = input.color(color.green, "Line color")
levels    = input.int(20, "Levels above/below price", minval = 1, maxval = 200)

var line[] gridLines = array.new_line()

if barstate.islast
    while array.size(gridLines) > 0
        line.delete(array.pop(gridLines))

    base = math.floor(close / pointStep) * pointStep
    for i = -levels to levels
        level = base + i * pointStep
        array.push(gridLines, line.new(bar_index - 1, level, bar_index, level, xloc.bar_index, extend.both, lineColor, line.style_solid, 1))
````
