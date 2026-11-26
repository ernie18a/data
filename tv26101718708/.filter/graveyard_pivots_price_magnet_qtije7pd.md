# Graveyard Pivots Price Magnet

- url: https://www.tradingview.com/script/QtijE7PD-Graveyard-Pivots-Price-Magnet/
- type: indicator
- pine_id: PUB;e80c6940d0b8481cb5140eff2e60a0b4
- version: 3.0

## Description

[b][b]Graveyard Pivots
[/b][/b]

Graveyard Pivots draws a fresh grid of price levels every day, measured from the daily open. It marks the quarter levels (.25, .50 and .75) between each pair of main round-number levels, so you can see where price may stall, react or reverse.

[b]How it works[/b]

*Daily anchor. The grid starts from the daily open, so it resets at the start of each new day.

*Automatic step size. The gap between main levels is set from the timeframe and the instrument's tick size and price scale, so it works on forex, stocks, crypto and indices without manual setup.

*Quarter levels. Between each pair of main levels, the script draws a .25 line, a .50 core line and a .75 line.

*Core line. The .50 line is drawn thicker, in black, with a soft glow, so it stands out as the key level.

*Edge lines. The .25 and .75 lines are drawn in light blue.

[i][b]Settings[/b][/i]

*Graves each side of price: how many levels to show above and below price (up to 60 each side).

*Anchor source: Daily Open (default), Prev Day Close, Weekly Open, Monthly Open, Yearly Open, or Zero for a fixed grid that never resets.

*Line widths and colours for the core and edge lines.

*Price tags: optional labels showing each level's price, with an adjustable distance from the last bar.

[image]https://www.tradingview.com/x/jbRB2Sc0/[/image]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChartTrader-X


//@version=6
indicator(title = 'Graveyard Pivots Price Magnet', shorttitle = 'GVP Price Magnet', overlay = true, precision = 5, max_lines_count = 300, max_labels_count = 120)

// === GRAVEYARD INPUTS ===
gyZonesPerSide = input.int(30, minval = 1, maxval = 60, title = 'Graves Each Side of Price', group = 'Graveyard Grid')
gyAnchorMode = input.string('Daily Open', title = 'Anchor Source (resets each period)', options = ['Daily Open', 'Prev Day Close', 'Weekly Open', 'Monthly Open', 'Yearly Open', 'Zero'], group = 'Graveyard Grid', tooltip = 'Daily Open = a fresh grid every day. Zero = original fixed grid that never resets.')

gyCoreThick = input.int(3, minval = 1, maxval = 4, title = 'Core Grave Line Width (.50)', group = 'Graveyard Look')
gyEdgeThick = input.int(3, minval = 1, maxval = 4, title = 'Edge Grave Line Width (.25 / .75)', group = 'Graveyard Look')

gyCoreHue = input.color(color.black, title = 'Core Grave Level (.50)', group = 'Graveyard Colours')
gyEdgeHue = input.color(color.new(color.rgb(138, 160, 188), 30), title = 'Edge Grave Levels (.25 / .75)', group = 'Graveyard Colours')

gyShowTags = input.bool(false, title = 'Show Grave Level Prices', group = 'Graveyard Tags')
gyTagDistance = input.int(3, minval = 0, maxval = 30, title = 'Tag Distance From Last Bar', group = 'Graveyard Tags')

gyGlowHue = color.new(gyCoreHue, 88)
gyTagBg = color.new(color.rgb(18, 20, 26), 8)

// === GRAVEYARD HELPERS ===
// Count of digits left of the decimal point
gyCountDigits(_gyVal) =>
    _gyAbs = math.abs(_gyVal)
    _gyAbs > 0 ? int(math.floor(math.log10(_gyAbs))) + 1 : 0

// === GRAVE SIZE (automatic, based on timeframe) ===
gyPullUnits = timeframe.ismonthly ? 10000 : timeframe.isweekly ? 10000 : timeframe.isdaily ? 5000 : timeframe.isintraday ? timeframe.multiplier >= 240 ? 5000 : 1000 : 1000

gyRefPrice = hl2[1]
gyDigitCount = gyCountDigits(math.round(gyRefPrice))
gyTick = syminfo.mintick

gyScale = syminfo.prefix == 'BATS' ? gyDigitCount <= 1 ? 1.0 : gyTick < 0.05 and gyDigitCount >= 2 ? math.pow(10, gyDigitCount - 3) : gyTick < 0.5 and gyDigitCount >= 3 ? math.pow(10, gyDigitCount - 4) : gyTick < 5.0 and gyDigitCount >= 4 ? math.pow(10, gyDigitCount - 5) : gyTick < 50.0 and gyDigitCount >= 5 ? math.pow(10, gyDigitCount - 6) : gyTick < 500.0 and gyDigitCount >= 6 ? math.pow(10, gyDigitCount - 7) : 1.0 : gyDigitCount <= 1 ? 1.0 : gyTick < 0.00005 and gyDigitCount >= 2 ? math.pow(10, gyDigitCount - 1) : gyTick < 0.0005 and gyDigitCount >= 2 ? math.pow(10, gyDigitCount - 2) : gyTick < 0.005 and gyDigitCount >= 3 ? math.pow(10, gyDigitCount - 3) : gyTick < 0.005 and gyDigitCount >= 2 ? math.pow(10, gyDigitCount - 2) : gyTick < 0.05 and gyDigitCount >= 4 ? math.pow(10, gyDigitCount - 4) : gyTick < 0.05 and gyDigitCount >= 2 ? math.pow(10, gyDigitCount - 3) : gyTick < 0.2 and gyDigitCount >= 5 ? math.pow(10, gyDigitCount - 5) : gyTick < 0.9 and gyDigitCount >= 4 ? math.pow(10, gyDigitCount - 5) : gyTick < 5.0 and gyDigitCount >= 5 ? math.pow(10, gyDigitCount - 6) : gyTick < 5.0 and gyDigitCount >= 4 ? math.pow(10, gyDigitCount - 5) : 1.0

gyGap = gyTick * gyPullUnits * gyScale // distance from one .00 grave to the next

// === ANCHOR SOURCES (higher-timeframe opens / closes) ===
gyOpenDay = request.security(syminfo.tickerid, 'D', open, lookahead = barmerge.lookahead_on)
gyPrevCloseDay = request.security(syminfo.tickerid, 'D', close[1], lookahead = barmerge.lookahead_on)
gyOpenWeek = request.security(syminfo.tickerid, 'W', open, lookahead = barmerge.lookahead_on)
gyOpenMonth = request.security(syminfo.tickerid, 'M', open, lookahead = barmerge.lookahead_on)
gyOpenYear = request.security(syminfo.tickerid, '12M', open, lookahead = barmerge.lookahead_on)

gyAnchorRaw = gyAnchorMode == 'Zero' ? 0.0 : gyAnchorMode == 'Prev Day Close' ? gyPrevCloseDay : gyAnchorMode == 'Weekly Open' ? gyOpenWeek : gyAnchorMode == 'Monthly Open' ? gyOpenMonth : gyAnchorMode == 'Yearly Open' ? gyOpenYear : gyOpenDay

// Snap the anchor to a round price (nearest 25 ticks, e.g. 0.25 on gold) so every grave lands on a clean number
gyAnchorSnap = gyTick * 25
gyAnchorPrice = gyAnchorMode == 'Zero' ? 0.0 : math.round(nz(gyAnchorRaw, 0.0) / gyAnchorSnap) * gyAnchorSnap

// Grid is pinned to the anchor price and centred on the grave nearest to current price.
gyBase = gyAnchorPrice + math.round((close - gyAnchorPrice) / gyGap) * gyGap

// Graves per side that fit inside the line / label limits (4 lines per grave, 3 labels per grave)
gyZones = math.min(gyZonesPerSide, gyShowTags ? 20 : 37)

// === GRAVE LEVEL DRAWING ===
var array<line> gyLineStore = array.new<line>()
var array<label> gyTagStore = array.new<label>()

if barstate.islast
    for gyLn in gyLineStore
        line.delete(gyLn)
    for gyTg in gyTagStore
        label.delete(gyTg)
    array.clear(gyLineStore)
    array.clear(gyTagStore)

    // Grave levels (.25 / .50 / .75) between each pair of graves
    for gyIdx = -gyZones to gyZones - 1 by 1
        for gyQtr = 1 to 3 by 1
            gyLevel = gyBase + gyIdx * gyGap + gyQtr * gyGap / 4
            if gyLevel <= 0
                continue
            gyIsCore = gyQtr == 2
            gyLineHue = gyIsCore ? gyCoreHue : gyEdgeHue

            // Soft glow under the core line
            if gyIsCore
                array.push(gyLineStore, line.new(bar_index - 1, gyLevel, bar_index, gyLevel, extend = extend.both, color = gyGlowHue, width = gyCoreThick + 4, style = line.style_solid))

            array.push(gyLineStore, line.new(bar_index - 1, gyLevel, bar_index, gyLevel, extend = extend.both, color = gyLineHue, width = gyIsCore ? gyCoreThick : gyEdgeThick, style = line.style_solid))

            // Pill-style price tag (price only)
            if gyShowTags
                array.push(gyTagStore, label.new(bar_index + gyTagDistance, gyLevel, str.tostring(gyLevel, format.mintick), style = label.style_label_left, color = gyTagBg, textcolor = color.white, size = size.normal, text_font_family = font.family_monospace))
````
