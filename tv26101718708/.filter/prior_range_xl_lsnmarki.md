# Prior Range XL

- url: https://www.tradingview.com/script/lSnMArKI-Prior-Range-XL/
- type: indicator
- pine_id: PUB;58fee575ec6d43249e2ed1e872767d15
- version: 1.0

## Description

**Prior Range XL — Overview**

Prior Range XL plots the previous period's trading range directly on the chart and marks the key levels inside it. It answers a simple question at a glance: where did price trade last period, and where are the meaningful levels within that zone? The prior high and low from a higher timeframe (day, week, or month) often act as support, resistance, and targets in the current period, and this tool keeps them visible and updated without manual drawing.

**What it draws on the chart**

- **Range box** — a shaded rectangle spanning the prior period's high down to its low, giving an immediate visual sense of the zone price is working within.
- **Prior High line** — the top of the range, extended across the current period.
- **Prior Low line** — the bottom of the range, extended across the current period.
- **Midline** — the exact midpoint (50%) of the range, often treated as the "fair value" or equilibrium of the zone.
- **Two internal levels** — user-placed lines inside the range (defaults sit at 20% and 80%), useful for spotting partial retracements, entries, and profit zones between the extremes.

All lines and the box extend to the right and refresh as the current period develops. Range values are calculated from the regular trading session only, so overnight or extended-hours spikes don't distort the prior high and low.

**The inputs, grouped**

*Structure*
- **Structure Timeframe** — the heart of the tool. Choose Daily, Weekly, or Monthly to decide which prior period defines the range. Daily uses yesterday's range, Weekly uses last week's, Monthly uses last month's. This should be set at or above the chart's timeframe for correct behavior.

*Internal Levels*
- **Show Internal Level 1 / Level 2** — toggles each of the two inner lines on or off.
- **Level 1 Value / Level 2 Value** — sets where each inner line sits within the range on a 0-to-1 scale. Zero is the range low, one is the range high, and 0.5 is the midpoint. Setting a level to exactly 0.5 hides it, since the dedicated midline already covers that spot.

*Colors*
- **Box Fill Color** — the shade and transparency of the range rectangle.
- **Box Border Color** — the outline of the box.
- **Prior High Line Color** — color of the top line (labeled PDH).
- **Prior Low Line Color** — color of the bottom line (labeled PDL).
- **Midline Color** — color of the 50% line.
- **Internal Level Color** — color applied to both inner levels.

*Lines & Styles*
- **Line Width** — thickness of the box border and every line.
- **Midline Style** — solid, dashed, or dotted for the midpoint line.
- **Internal Level Style** — solid, dashed, or dotted for the two inner levels.

**How to use it**

- **Frame the session** — set the Structure Timeframe to the period that matters for the trading approach. Intraday traders typically use Daily; swing traders lean toward Weekly or Monthly.
- **Read the edges** — the prior high and low act as natural decision points. Price approaching an edge often stalls, reverses, or breaks through with momentum, and either outcome is tradable information.
- **Use the midline as a pivot** — trading above the midline leans bullish within the range; below it leans bearish. It's a quick read on which half of the zone price favors.
- **Place the internal levels intentionally** — the defaults at 20% and 80% highlight the outer quarters of the range, a common area for reactions before price tests the extremes. Adjust them to match a preferred method, such as thirds or a specific retracement depth.
- **Style for clarity** — assign distinct colors so the high, low, midline, and internal levels are instantly distinguishable, and use dashed or dotted styles to keep the inner lines from competing visually with the range boundaries.

**One practical note**

Because the title is "Prior Range XL," the chart platform treats it as its own indicator. Any earlier version under a different name stays separate and should be removed manually to avoid overlapping boxes and lines.

*(This description is drawn entirely from the indicator's own settings and logic — no outside sources involved.)*

## Source Code

````pine
//@version=6
indicator('Prior Range XL', overlay = true, max_boxes_count = 50, max_lines_count = 200)

//============================
// Input Groups
//============================
string GRP_STRUCT = 'Structure'
string GRP_LEVELS = 'Internal Levels'
string GRP_COLORS = 'Colors'
string GRP_STYLE  = 'Lines & Styles'

//============================
// Structure Timeframe
//============================
structureTFInput = input.string('Daily', 'Structure Timeframe', options = ['Daily', 'Weekly', 'Monthly'], group = GRP_STRUCT, tooltip = 'Higher timeframe used to build the prior-period range.\n\nDaily = prior day high/low\nWeekly = prior week high/low\nMonthly = prior month high/low\n\nKeep this at or above your chart timeframe, otherwise the new-period detection will not fire correctly.')

structureTF = structureTFInput == 'Weekly' ? 'W' : structureTFInput == 'Monthly' ? 'M' : 'D'

//============================
// Internal Levels
//============================
showLevel1 = input.bool(true, 'Show Internal Level 1', group = GRP_LEVELS, tooltip = 'Toggle the first internal level drawn inside the range.')
level1Value = input.float(0.2, 'Level 1 Value', minval = 0.0, maxval = 1.0, step = 0.01, group = GRP_LEVELS, tooltip = 'Position of Level 1 within the range.\n\n0.0 = range low\n1.0 = range high\n0.5 = midline (hidden here; use the dedicated midline instead)')

showLevel2 = input.bool(true, 'Show Internal Level 2', group = GRP_LEVELS, tooltip = 'Toggle the second internal level drawn inside the range.')
level2Value = input.float(0.8, 'Level 2 Value', minval = 0.0, maxval = 1.0, step = 0.01, group = GRP_LEVELS, tooltip = 'Position of Level 2 within the range.\n\n0.0 = range low\n1.0 = range high\n0.5 = midline (hidden here; use the dedicated midline instead)')

//============================
// Colors
//============================
boxFill = input.color(color.new(color.orange, 85), 'Box Fill Color', group = GRP_COLORS, tooltip = 'Fill color and transparency of the range box.')
boxBorder = input.color(color.orange, 'Box Border Color', group = GRP_COLORS, tooltip = 'Color of the range box outline.')
highLineColor = input.color(color.green, 'PDH Line Color', group = GRP_COLORS, tooltip = 'Color of the prior-period high line.')
lowLineColor = input.color(color.red, 'PDL Line Color', group = GRP_COLORS, tooltip = 'Color of the prior-period low line.')
midLineColor = input.color(color.black, 'Midline Color', group = GRP_COLORS, tooltip = 'Color of the midpoint line (50% of the range).')
levelLineColor = input.color(color.red, 'Internal Level Color', group = GRP_COLORS, tooltip = 'Color applied to both internal levels.')

//============================
// Lines & Styles
//============================
lineWidth = input.int(1, 'Line Width', minval = 1, maxval = 5, group = GRP_STYLE, tooltip = 'Thickness applied to the box border and all lines.')
midLineStyleInput = input.string('Dashed', 'Midline Style', options = ['Solid', 'Dashed', 'Dotted'], group = GRP_STYLE, tooltip = 'Line style for the midpoint line.')
levelLineStyleInput = input.string('Dashed', 'Internal Level Style', options = ['Solid', 'Dashed', 'Dotted'], group = GRP_STYLE, tooltip = 'Line style for both internal levels.')

//============================
// Style Mapping
//============================
midLineStyle = midLineStyleInput == 'Solid' ? line.style_solid : midLineStyleInput == 'Dotted' ? line.style_dotted : line.style_dashed

levelLineStyle = levelLineStyleInput == 'Solid' ? line.style_solid : levelLineStyleInput == 'Dotted' ? line.style_dotted : line.style_dashed

//============================
// RTH Prior Period Values
//============================
regularTicker = ticker.new(syminfo.prefix, syminfo.ticker, session.regular)

pdh = request.security(regularTicker, structureTF, high[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
pdl = request.security(regularTicker, structureTF, low[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
pdm = (pdh + pdl) / 2.0

//============================
// New Period Detection
//============================
newDay = timeframe.change(structureTF)

var int currentDayStart = na

if newDay
    currentDayStart := time
    currentDayStart

if barstate.isfirst and na(currentDayStart)
    currentDayStart := time
    currentDayStart

//============================
// Objects
//============================
var box pdrBox = na
var line pdhLine = na
var line pdlLine = na
var line pdmLine = na
var line lvl1Line = na
var line lvl2Line = na

//============================
// Helpers
//============================
f_is_valid_level(_lvl) =>
    not na(_lvl) and _lvl > 0 and _lvl < 1

f_level_price(_pdh, _pdl, _lvl) =>
    _pdl + (_pdh - _pdl) * _lvl

f_delete_all() =>
    if not na(pdrBox)
        box.delete(pdrBox)
    if not na(pdhLine)
        line.delete(pdhLine)
    if not na(pdlLine)
        line.delete(pdlLine)
    if not na(pdmLine)
        line.delete(pdmLine)
    if not na(lvl1Line)
        line.delete(lvl1Line)
    if not na(lvl2Line)
        line.delete(lvl2Line)

f_create_level_line(_startTime, _price) =>
    line.new(x1 = _startTime, y1 = _price, x2 = time_close, y2 = _price, xloc = xloc.bar_time, color = levelLineColor, width = lineWidth, style = levelLineStyle, extend = extend.right)

//============================
// Create / Reset Each New Period
//============================
if barstate.isfirst or newDay
    if not na(pdh) and not na(pdl)
        f_delete_all()

        pdrBox := box.new(left = currentDayStart, top = pdh, right = time_close, bottom = pdl, xloc = xloc.bar_time, bgcolor = boxFill, border_color = boxBorder, border_width = lineWidth)

        pdhLine := line.new(x1 = currentDayStart, y1 = pdh, x2 = time_close, y2 = pdh, xloc = xloc.bar_time, color = highLineColor, width = lineWidth, extend = extend.right)

        pdlLine := line.new(x1 = currentDayStart, y1 = pdl, x2 = time_close, y2 = pdl, xloc = xloc.bar_time, color = lowLineColor, width = lineWidth, extend = extend.right)

        pdmLine := line.new(x1 = currentDayStart, y1 = pdm, x2 = time_close, y2 = pdm, xloc = xloc.bar_time, color = midLineColor, width = lineWidth, style = midLineStyle, extend = extend.right)

        if showLevel1 and f_is_valid_level(level1Value) and level1Value != 0.5
            lvl1Line := f_create_level_line(currentDayStart, f_level_price(pdh, pdl, level1Value))
            lvl1Line

        if showLevel2 and f_is_valid_level(level2Value) and level2Value != 0.5
            lvl2Line := f_create_level_line(currentDayStart, f_level_price(pdh, pdl, level2Value))
            lvl2Line

//============================
// Update Current Period Objects
//============================
if not na(pdh) and not na(pdl) and not na(currentDayStart)
    if not na(pdrBox)
        box.set_left(pdrBox, currentDayStart)
        box.set_right(pdrBox, time_close)
        box.set_top(pdrBox, pdh)
        box.set_bottom(pdrBox, pdl)
        box.set_bgcolor(pdrBox, boxFill)
        box.set_border_color(pdrBox, boxBorder)
        box.set_border_width(pdrBox, lineWidth)

    if not na(pdhLine)
        line.set_x1(pdhLine, currentDayStart)
        line.set_y1(pdhLine, pdh)
        line.set_x2(pdhLine, time_close)
        line.set_y2(pdhLine, pdh)
        line.set_color(pdhLine, highLineColor)
        line.set_width(pdhLine, lineWidth)
        line.set_extend(pdhLine, extend.right)

    if not na(pdlLine)
        line.set_x1(pdlLine, currentDayStart)
        line.set_y1(pdlLine, pdl)
        line.set_x2(pdlLine, time_close)
        line.set_y2(pdlLine, pdl)
        line.set_color(pdlLine, lowLineColor)
        line.set_width(pdlLine, lineWidth)
        line.set_extend(pdlLine, extend.right)

    if not na(pdmLine)
        line.set_x1(pdmLine, currentDayStart)
        line.set_y1(pdmLine, pdm)
        line.set_x2(pdmLine, time_close)
        line.set_y2(pdmLine, pdm)
        line.set_color(pdmLine, midLineColor)
        line.set_width(pdmLine, lineWidth)
        line.set_style(pdmLine, midLineStyle)
        line.set_extend(pdmLine, extend.right)

    lvl1Price = f_level_price(pdh, pdl, level1Value)
    lvl2Price = f_level_price(pdh, pdl, level2Value)

    if showLevel1 and f_is_valid_level(level1Value) and level1Value != 0.5
        if na(lvl1Line)
            lvl1Line := f_create_level_line(currentDayStart, lvl1Price)
            lvl1Line
        else
            line.set_x1(lvl1Line, currentDayStart)
            line.set_y1(lvl1Line, lvl1Price)
            line.set_x2(lvl1Line, time_close)
            line.set_y2(lvl1Line, lvl1Price)
            line.set_color(lvl1Line, levelLineColor)
            line.set_width(lvl1Line, lineWidth)
            line.set_style(lvl1Line, levelLineStyle)
            line.set_extend(lvl1Line, extend.right)
    else
        if not na(lvl1Line)
            line.delete(lvl1Line)
            lvl1Line := na
            lvl1Line

    if showLevel2 and f_is_valid_level(level2Value) and level2Value != 0.5
        if na(lvl2Line)
            lvl2Line := f_create_level_line(currentDayStart, lvl2Price)
            lvl2Line
        else
            line.set_x1(lvl2Line, currentDayStart)
            line.set_y1(lvl2Line, lvl2Price)
            line.set_x2(lvl2Line, time_close)
            line.set_y2(lvl2Line, lvl2Price)
            line.set_color(lvl2Line, levelLineColor)
            line.set_width(lvl2Line, lineWidth)
            line.set_style(lvl2Line, levelLineStyle)
            line.set_extend(lvl2Line, extend.right)
    else
        if not na(lvl2Line)
            line.delete(lvl2Line)
            lvl2Line := na
            lvl2Line
````
