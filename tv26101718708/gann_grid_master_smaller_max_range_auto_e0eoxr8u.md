# Gann Grid Master smaller- Max Range Auto

- url: https://www.tradingview.com/script/E0EoXR8u-Gann-Grid-Master-smaller-Max-Range-Auto/
- type: indicator
- pine_id: PUB;08d0b1941e5e49768da287f1de24b206
- version: 1.0

## Description

Gann Grid Master  is a Pine Script v6 indicator that automatically draws a sophisticated Gann-style horizontal grid on the chart.

It starts from a user-defined Base Price (anchor) and Base Range (main unit), then creates layered subdivisions by repeatedly halving the interval (1/2, 1/4, 1/8, 1/16, etc.) up to a chosen max depth. 

Key Smart Features:
Automatic range calculation — It intelligently determines the maximum number of steps it can draw without exceeding TradingView’s 500-line limit.
Dynamic line styling (different width + solid/dashed/dotted) based on importance/depth.
Only draws lines near current price (performance optimized).
Thick base anchor line.
Info label showing current max range and lines used.

The result is a clean, dense grid of horizontal support/resistance levels based on geometric proportions (Gann’s mathematical approach).

Main Use Cases:
Gann Theory Traders: Core tool for those who use Gann Squares, geometric angles, and cardinal levels. The grid helps identify high-probability reversal or breakout zones.
Support/Resistance Trading: Excellent for spotting confluence zones — areas where multiple grid lines cluster often act as strong magnets or barriers.

Scalping & Intraday: On lower timeframes (1m–15m), the finer subdivisions (depth 3–5) give precise micro-levels.

Swing/Position Trading: On higher timeframes, it reveals major structural levels derived from important anchors (e.g., round numbers, all-time highs, earnings gaps, etc.).

Range-Bound Markets: Very effective in sideways or contracting volatility environments where price respects mathematical divisions.

Psychological Level Trading: Set the Base Price to a major round number (e.g., 100.00, 4500, etc.) and let the grid expand outward automatically.

Pro Tip: Combine it with volume profile, order blocks, or Fibonacci for even stronger confluences. Many Gann traders also use the base price/range from significant swing highs/lows.This version is particularly clean and practical because it solves the common problem of hitting TradingView’s line limit by automatically optimizing the visible range.

## Source Code

````pine
//@version=6
indicator('Gann Grid Master smaller- Max Range Auto', overlay = true, max_lines_count = 500)

// --- INPUTS ---
grp_base = 'Base Settings'
basePrice = input.float(title = 'Base Price (Anchor)', defval = 95.00, step = 0.01, group = grp_base)
baseRange = input.float(title = 'Base Range (Main Unit)', defval = 5.0, step = 0.01, group = grp_base)
maxDepth = input.int(title = 'Max Division Depth (1/2^n)', defval = 5, minval = 1, maxval = 6, group = grp_base)
// We remove manual stepsCount and calculate it automatically
// But we keep a "Target Range" input so you can see the result
targetRangeInput = input.float(title = 'Desired Range (Auto-Calculated if 0)', defval = 0.0, step = 1.0, group = grp_base)

grp_vis = 'Visual Settings'
lineColor = input.color(title = 'Line Color (Dark Blue)', defval = color.blue, group = grp_vis)
baseLineColor = input.color(title = 'Base Line Color', defval = color.blue, group = grp_vis)

// --- HELPER FUNCTIONS ---
snapToTick(float val) =>
    if syminfo.mintick == 0
        val
    else
        math.round(val / syminfo.mintick) * syminfo.mintick

getLineStyle(int depth) =>
    width = 1
    style = line.style_solid
    if depth == 0
        width := 2
        style := line.style_solid
        style
    else if depth == 1
        width := 2
        style := line.style_dashed
        style
    else if depth == 2
        width := 2
        style := line.style_solid
        style
    else if depth == 3
        width := 2
        style := line.style_dashed
        style
    else if depth == 4
        width := 2
        style := line.style_dashed
        style
    else if depth == 5
        width := 2
        style := line.style_dotted
        style
    [width, style]

// --- AUTO-CALCULATION LOGIC ---
// Calculate max stepsCount (N) that fits in 500 lines for the given maxDepth
// Formula: 2 * N * (2^(maxDepth+1) - 1) <= 500
// N <= 500 / (2 * (2^(maxDepth+1) - 1))
maxLines = 500
divisor = 2 * (math.pow(2, maxDepth + 1) - 1)
calculatedSteps = math.floor(maxLines / divisor)

// If user entered a desired range, try to match it, but cap at calculatedSteps
// If user entered 0, use the calculated max
finalSteps = targetRangeInput > 0 ? math.floor(targetRangeInput / baseRange) : calculatedSteps

// Safety cap: Ensure we don't exceed the calculated limit
finalSteps := math.min(finalSteps, calculatedSteps)

// Display info
var label infoLabel = na
if barstate.islast
    if na(infoLabel)
        infoLabel := label.new(bar_index, high, text = 'Max Range: $' + str.tostring(finalSteps * baseRange) + '\nLines Used: ' + str.tostring(2 * finalSteps * (math.pow(2, maxDepth + 1) - 1)), color = color.black, textcolor = color.white, style = label.style_label_down)
        infoLabel
    else
        label.set_text(infoLabel, 'Max Range: $' + str.tostring(finalSteps * baseRange) + '\nLines Used: ' + str.tostring(2 * finalSteps * (math.pow(2, maxDepth + 1) - 1)))
        label.set_x(infoLabel, bar_index)

// --- MAIN LOGIC ---
currentPrice = close
rangeLimit = baseRange * 20 // Keep this high enough to catch the max range
isInRange(p) =>
    p >= currentPrice - rangeLimit and p <= currentPrice + rangeLimit

// 1. DELETE OLD LINES
var array<line> prevLines = array.new_line()
if array.size(prevLines) > 0
    for i = 0 to array.size(prevLines) - 1 by 1
        line.delete(array.get(prevLines, i))
    array.clear(prevLines)

// 2. DRAW LINES
for depth = maxDepth to 0 by 1
    divisor = math.pow(2, depth)
    fraction = 1.0 / divisor
    stepSize = baseRange * fraction

    [w, s] = getLineStyle(depth)

    // Calculate steps for this depth to match the target range
    // stepsForDepth = finalSteps * 2^depth
    stepsForDepth = finalSteps * math.pow(2, depth)

    // Draw ABOVE
    for i = 1 to stepsForDepth by 1
        rawPrice = basePrice + i * stepSize
        snapped = snapToTick(rawPrice)
        if isInRange(snapped)
            l = line.new(x1 = bar_index - 4000, y1 = snapped, x2 = bar_index, y2 = snapped, color = lineColor, width = w, style = s, extend = extend.right)
            array.push(prevLines, l)

    // Draw BELOW
    for i = 1 to stepsForDepth by 1
        rawPrice = basePrice - i * stepSize
        snapped = snapToTick(rawPrice)
        if isInRange(snapped)
            l = line.new(x1 = bar_index - 4000, y1 = snapped, x2 = bar_index, y2 = snapped, color = lineColor, width = w, style = s, extend = extend.right)
            array.push(prevLines, l)

// 3. BASE LINE
var line baseLine = na
if na(baseLine)
    baseLine := line.new(x1 = bar_index - 4000, y1 = basePrice, x2 = bar_index, y2 = basePrice, color = baseLineColor, width = 8, style = line.style_solid, extend = extend.right)
    baseLine
else
    line.set_x2(baseLine, bar_index)
````
