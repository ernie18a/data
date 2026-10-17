# Equal & Relative Equal Highs/Lows

- url: https://www.tradingview.com/script/oUb4PEV5-Equal-Relative-Equal-Highs-Lows/
- type: indicator
- pine_id: PUB;08d6f45672e5427b8aa7ec69a71df89f
- version: 2.0

## Description

This indicator plots horizontal lines between equal highs and lows and relative equal highs and lows.

This tool is ideal for spotting equal & relative highs/lows (a classic price action concept), swing failure patterns, support/resistance zones based on liquidity, and areas where the market has previously shown equilibrium.

Price tends to create these highs and lows, as a zone of liquidity in which price will return to and sweep similar to the devils mark concept.

Key Features
--------------------

- Equal Lows (default: white lines) – Connects the current bar's low with the most recent prior low that matches it.
- Equal Highs (default: yellow lines) – Connects the current bar's high with the most recent prior high that matches it.
- Two Matching Modes:
-- Exact – Requires identical price levels.
-- Relative – Allows tolerance in ticks (1–3 ticks) for near-equal levels.

Conditions
-------------------

- Lines are drawn only when no lower low (for lows) or higher high (for highs) has occurred between the two matching bars — ensuring the level remains relevant.
- Lines are automatically removed once price sweeps through them (price closes below an equal-low line or above an equal-high line).

Settings
-------------------

- Max bars between equal levels – How far back to search for matching highs/lows (default 500).
- Max stored lines (per side) – Limits memory usage and clutter (default 100).
- Equal level matching – Exact or Relative mode.
- Relative tolerance (ticks) – Adjustable precision in Relative mode.
- Line colors & width – Fully customizable.

## Source Code

````pine
//@version=6
indicator("Equal & Relative Equal Highs/Lows", shorttitle = "EQ/RLTV H's/L's", overlay=true, max_lines_count=500)

lookbackBars = input.int(500, "Max bars between equal levels", minval=1)
maxLines     = input.int(100, "Max stored lines (per side)", minval=1, maxval=500)
matchMode    = input.string("Exact", "Equal level matching", options=["Exact", "Relative"])
relativeTicks = input.int(1, "Relative tolerance (ticks)", minval=1, maxval=60)
lowLineCol   = input.color(color.white, "Equal low line color")
highLineCol  = input.color(color.yellow, "Equal high line color")
lineWidth    = input.int(1, "Line width", minval=1, maxval=4)

float tol = matchMode == "Relative" ? relativeTicks * syminfo.mintick : 0.0
bool isRelative = matchMode == "Relative"

var line[] eqLowLines = array.new_line()
var line[] eqHighLines = array.new_line()

// Remove equal-low lines once price sweeps below them.
if array.size(eqLowLines) > 0
    for idx = array.size(eqLowLines) - 1 to 0
        line ln = array.get(eqLowLines, idx)
        float lvl = line.get_y1(ln)
        if low < lvl
            line.delete(ln)
            array.remove(eqLowLines, idx)

// Remove equal-high lines once price sweeps above them.
if array.size(eqHighLines) > 0
    for idx = array.size(eqHighLines) - 1 to 0
        line ln = array.get(eqHighLines, idx)
        float lvl = line.get_y1(ln)
        if high > lvl
            line.delete(ln)
            array.remove(eqHighLines, idx)

int lowMatchOffset = na
for i = 1 to lookbackBars
    bool lowMatched = isRelative ? math.abs(low - low[i]) <= tol : low == low[i]
    if na(lowMatchOffset) and lowMatched
        lowMatchOffset := i

if not na(lowMatchOffset)
    bool lowCrossed = false
    for j = 1 to lowMatchOffset - 1
        if low[j] < low
            lowCrossed := true

    if not lowCrossed
        int x1 = bar_index - lowMatchOffset
        int x2 = bar_index
        float y = low

        line l = line.new(x1, y, x2, y, xloc=xloc.bar_index, extend=extend.none, color=lowLineCol, width=lineWidth)
        array.push(eqLowLines, l)

        if array.size(eqLowLines) > maxLines
            line.delete(array.shift(eqLowLines))

int highMatchOffset = na
for i = 1 to lookbackBars
    bool highMatched = isRelative ? math.abs(high - high[i]) <= tol : high == high[i]
    if na(highMatchOffset) and highMatched
        highMatchOffset := i

if not na(highMatchOffset)
    bool highCrossed = false
    for j = 1 to highMatchOffset - 1
        if high[j] > high
            highCrossed := true

    if not highCrossed
        int x1 = bar_index - highMatchOffset
        int x2 = bar_index
        float y = high

        line h = line.new(x1, y, x2, y, xloc=xloc.bar_index, extend=extend.none, color=highLineCol, width=lineWidth)
        array.push(eqHighLines, h)

        if array.size(eqHighLines) > maxLines
            line.delete(array.shift(eqHighLines))
````
