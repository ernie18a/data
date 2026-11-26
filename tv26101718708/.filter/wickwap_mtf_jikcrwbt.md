# Wickwap MTF

- url: https://www.tradingview.com/script/JikCRWbT-Wickwap-MTF/
- type: indicator
- pine_id: PUB;c73f36aaeb9349f7a2345eb916f6e895
- version: 1.0

## Description

Wickwap MTF is a Multi-Timeframe Pine Script indicator that automatically detects strong candlestick wicks on a chosen timeframe and draws clean supply/demand blocks anchored to swing pivots. It measures the average upper and lower wick length, then highlights only "significant" wicks (those exceeding a user-defined multiple of the average). These strong wicks are turned into visual rectangular blocks (boxes) extending from swing highs (upper blocks) and swing lows (lower blocks).

Core Logic:
Upper blocks (red) = Strong selling rejection / Supply zones
Lower blocks (green) = Strong buying rejection / Demand zones

Fully MTF — you can view higher-timeframe wick zones on your current chart
Uses swing pivots for precise anchoring

Summary:
Wickwap MTF is a clean, visual wick-based Supply & Demand indicator focused on real market rejection rather than just bodies or simple highs/lows. Excellent for price action and ICT/SMC traders who respect strong wicks.

## Source Code

````pine
//@version=6
indicator('Wickwap MTF', shorttitle = 'Wickwap MTF', overlay = true, max_boxes_count = 800, max_labels_count = 100)

// ── Settings ─────────────────────────────────────
mtfTimeframe = input.timeframe('1', 'Timeframe', group = 'MTF', tooltip = 'Calculate wicks from this timeframe')

useSwings = input.bool(true, 'Use Swing-Anchored Blocks', group = 'Block Settings')
swingLen = input.int(5, 'Swing Pivot Length', minval = 2, group = 'Block Settings')

len = input.int(14, 'Avg Wick Length', minval = 1, group = 'Wick Settings')
mult = input.float(1.1, 'Wick Multiplier', minval = 0.1, step = 0.1, group = 'Wick Settings')
minWickMult = input.float(0.7, 'Minimum Wick Strength', minval = 0.3, group = 'Wick Settings')

showBlocks = input.bool(true, 'Show Blocks', group = 'Display')
extendRight = input.bool(true, 'Extend Blocks Right', group = 'Display')
transp = input.int(70, 'Block Transparency', minval = 0, maxval = 90, group = 'Display')

blockColorUpper = input.color(color.red, 'Upper Block Color', group = 'Display')
blockColorLower = input.color(color.green, 'Lower Block Color', group = 'Display')

// ── Calculations (will run on MTF timeframe via security) ───────────────────────────────
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

avgUpper = ta.sma(upperWick, len)
avgLower = ta.sma(lowerWick, len)

upperStrong = upperWick >= avgUpper * minWickMult
lowerStrong = lowerWick >= avgLower * minWickMult

ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

// ── Pull Data From Selected Timeframe ───────────────────────────────
[mtfWickUpper, mtfWickLower, mtfAvgUpper, mtfAvgLower, mtfPh, mtfPl] = request.security(syminfo.tickerid, mtfTimeframe, [upperWick, lowerWick, avgUpper, avgLower, ph, pl])

mtfUpperStrong = mtfWickUpper >= mtfAvgUpper * minWickMult
mtfLowerStrong = mtfWickLower >= mtfAvgLower * minWickMult

// ── Block Creation ─────────────────────────────
var array<box> upperBoxes = array.new_box()
var array<box> lowerBoxes = array.new_box()

if showBlocks
    // Upper Block from MTF
    if mtfUpperStrong and not na(mtfPh)
        topPrice = mtfPh
        leftBar = bar_index - swingLen
        b = box.new(left = leftBar, top = topPrice + mtfAvgUpper * mult, right = extendRight ? bar_index + 100 : bar_index + 8, bottom = topPrice, bgcolor = color.new(blockColorUpper, transp), border_color = blockColorUpper, border_width = 2)
        array.push(upperBoxes, b)

    // Lower Block from MTF
    if mtfLowerStrong and not na(mtfPl)
        botPrice = mtfPl
        leftBar = bar_index - swingLen
        b = box.new(left = leftBar, top = botPrice, right = extendRight ? bar_index + 100 : bar_index + 8, bottom = botPrice - mtfAvgLower * mult, bgcolor = color.new(blockColorLower, transp), border_color = blockColorLower, border_width = 2)
        array.push(lowerBoxes, b)

// Cleanup old boxes
maxKeep = 800
if array.size(upperBoxes) > maxKeep
    box.delete(array.shift(upperBoxes))
if array.size(lowerBoxes) > maxKeep
    box.delete(array.shift(lowerBoxes))

// ── Info Table ─────────────────────────────────
var table t = table.new(position.top_right, 1, 4, bgcolor = color.new(#1e222d, 85))
if barstate.islast
    table.cell(t, 0, 0, 'Wickwap MTF - ' + mtfTimeframe, text_color = color.white)
    table.cell(t, 0, 1, 'Avg Upper: ' + str.tostring(mtfAvgUpper, '#.####'), text_color = color.red)
    table.cell(t, 0, 2, 'Avg Lower: ' + str.tostring(mtfAvgLower, '#.####'), text_color = color.lime)
    table.cell(t, 0, 3, 'Upper Strong: ' + str.tostring(mtfUpperStrong), text_color = mtfUpperStrong ? color.green : color.gray)
````
