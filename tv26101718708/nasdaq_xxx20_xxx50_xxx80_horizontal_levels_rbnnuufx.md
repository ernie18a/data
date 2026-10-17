# Nasdaq XXX20 / XXX50 / XXX80 Horizontal Levels

- url: https://www.tradingview.com/script/rbNnuufx-Nasdaq-XXX20-XXX50-XXX80-Horizontal-Levels/
- type: indicator
- pine_id: PUB;7ef82b8452d8488b896503fdc03cbb96
- version: 2.0

## Description

This indicator automatically plots Nasdaq horizontal levels at  XXX20, XXX50, and XXX80. Ideal for intraday trading on NQ, MNQ, NDQ, and NDX, with timeframes less than or equal to 5min.

This script highlights powerful reaction levels for entries, exits, stops, and targets.

Key Features
----------------
- Draws XXX20 (teal), XXX50 (light gray/ivory), and XXX80 (orange) levels extending across the chart.

- Dynamically anchors around the current price, showing ±25 blocks by default (50+ levels total, adjustable).

- Optional price range filter to declutter charts by limiting levels to a specific zone.

Inputs
--------------
- Toggle individual level types (XXX20 / XXX50 / XXX80).
- Line colors and width.
- Block size (default 100).
- Price range filter (show only levels between Min and Max price).

## Source Code

````pine
//@version=6
indicator("XXX00/ XXX20 / XXX50 / XXX80 Horizontal Levels", shorttitle = "Nasdaq 00/20/50/80 LVLs", overlay=true, max_lines_count=500)

int levelsAboveBelow = 25
float blockSize = 100.0
float mintick   = syminfo.mintick < 0.0000001 ? 0.25 : syminfo.mintick
f_round_to_tick(_p) => math.round(_p / mintick) * mintick

show00Levels     = input.bool(true, " xxx00 Levels")
show20Levels     = input.bool(true, " xxx20 Levels")
show50Levels     = input.bool(true, " xxx50 Levels")
show80Levels     = input.bool(true, " xxx80 Levels")
lineColor00      = input.color(color.new(color.gray, 0), " xxx00")
lineColor20      = input.color(color.new(color.teal, 0), " xxx20")
lineColor50      = input.color(color.new(#eeede4, 50), " xxx50")
lineColor80      = input.color(color.new(color.orange, 0), " xxx80")
lineWidth        = input.int(1, "Line Width", minval=1, maxval=3)

usePriceRange    = input.bool(false, "Use Price Range Filter")
rangeMinPrice    = input.float(0.0, "Range Min Price", step=0.25)
rangeMaxPrice    = input.float(9999999.0, "Range Max Price", step=0.25)

var line[] levelLines = array.new_line()

if barstate.islast
    // Clear previous grid
    while array.size(levelLines) > 0
        line.delete(array.shift(levelLines))

    // Anchor around current xxx00 block (e.g., 43000, 1.1200 if blockSize is set accordingly)
    float baseBlock = math.floor(close / blockSize) * blockSize
    float minP = math.min(rangeMinPrice, rangeMaxPrice)
    float maxP = math.max(rangeMinPrice, rangeMaxPrice)

    // Build xxx00, xxx20, xxx50, and xxx80 levels around current price block
    for i = -levelsAboveBelow to levelsAboveBelow
        float anchor = baseBlock + (i * blockSize)
        float lvl00 = f_round_to_tick(anchor)
        float lvl20 = f_round_to_tick(anchor + (0.20 * blockSize))
        float lvl50 = f_round_to_tick(anchor + (0.50 * blockSize))
        float lvl80 = f_round_to_tick(anchor + (0.80 * blockSize))

        bool inRange00 = not usePriceRange or (lvl00 >= minP and lvl00 <= maxP)
        bool inRange20 = not usePriceRange or (lvl20 >= minP and lvl20 <= maxP)
        bool inRange50 = not usePriceRange or (lvl50 >= minP and lvl50 <= maxP)
        bool inRange80 = not usePriceRange or (lvl80 >= minP and lvl80 <= maxP)

        if show00Levels and inRange00
            line l00 = line.new(bar_index - 500, lvl00, bar_index + 500, lvl00, extend=extend.both, color=lineColor00, width=lineWidth)
            array.push(levelLines, l00)
        if show20Levels and inRange20
            line l20 = line.new(bar_index - 500, lvl20, bar_index + 500, lvl20, extend=extend.both, color=lineColor20, width=lineWidth)
            array.push(levelLines, l20)
        if show50Levels and inRange50
            line l50 = line.new(bar_index - 500, lvl50, bar_index + 500, lvl50, extend=extend.both, color=lineColor50, width=lineWidth)
            array.push(levelLines, l50)
        if show80Levels and inRange80
            line l80 = line.new(bar_index - 500, lvl80, bar_index + 500, lvl80, extend=extend.both, color=lineColor80, width=lineWidth)
            array.push(levelLines, l80)
````
