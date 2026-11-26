# 1 HR Fair Value Gap

- url: https://www.tradingview.com/script/IIgWPMA2-1-HR-Fair-Value-Gap/
- type: indicator
- pine_id: PUB;989e833dc9064dc397bd903e3d8113fa
- version: 1.0

## Description

It draws 1-hour fair value gaps on your chart, no matter what timeframe you're looking at.

A fair value gap is a 3-candle imbalance: price moves so fast that the first and third candles don't overlap, leaving a gap. The code checks confirmed 1-hour candles and finds two kinds — bullish (gap up, `h3 < l1`) and bearish (gap down, `l3 > h1`).

When it finds one, it does two things: draws a colored box marking the gap, and draws a line at the 50% midpoint of that gap extended 24 hours to the right. The midline is the part you actually trade off of — where price is likely to return and react.

The `bars24h` piece just makes "24 hours" translate correctly to any chart, since 24 hours is 288 bars on a 5-minute chart but only 24 bars on a 1-hour chart. And the age-out at the bottom stops tracking each midline once it's 24 hours old, so old levels drop off.

That's the whole thing — pure levels, no signals, no bias, no alerts.

## Source Code

````pine
//@version=6
indicator("1HR Fair Value Gap", overlay=true, max_boxes_count=500, max_lines_count=500)

// 24 hours expressed in bars of the current chart: 5M → 288, 15M → 96, 1H → 24
int bars24h = math.max(1, math.round(86400.0 / timeframe.in_seconds()))

// ════════════════════════════════════════════════════════════════
// 1 HR FVG — MIDLINE EXTENDED 24 HOURS, ANY TIMEFRAME
// ════════════════════════════════════════════════════════════════

// --- SETTINGS ---
tf_input = "60"
bull_col = input.color(color.new(#3cff00, 80), "Bullish FVG Color", group="FVG")
bear_col = input.color(color.new(#ff1745, 80), "Bearish FVG Color", group="FVG")
mid_col  = input.color(color.new(#b615f5, 0),  "50% Midline Color", group="FVG")
max_bars = input.int(500, "Max Lookback (Bars)", group="FVG")

// --- DATA ACQUISITION (CONFIRMED 1H CANDLES ONLY) ---
[h1, l1, h3, l3, b_idx] = request.security(syminfo.tickerid, tf_input,
     [high[1], low[1], high[3], low[3], bar_index])

// --- FIRST PRINCIPLES LOGIC ---
bull_fvg = h3 < l1
bear_fvg = l3 > h1

var box[]   boxes     = array.new_box()
var float[] tops      = array.new_float()
var float[] bots      = array.new_float()
var bool[]  mitigated = array.new_bool()
var float[] midPrices = array.new_float()
var float[] midTops   = array.new_float()
var float[] midBots   = array.new_float()
var int[]   midBars   = array.new_int()

is_new_1h_bar = ta.change(b_idx) != 0

if is_new_1h_bar
    if bull_fvg
        _top = l1
        _bot = h3
        _mid = (_top + _bot) / 2
        b = box.new(bar_index, _top, bar_index + 1, _bot, bgcolor=bull_col, border_color=na)
        line.new(bar_index, _mid, bar_index + bars24h, _mid, color=mid_col, width=3)
        array.push(boxes, b)
        array.push(tops, _top)
        array.push(bots, _bot)
        array.push(mitigated, false)
        array.push(midPrices, _mid)
        array.push(midTops, _top)
        array.push(midBots, _bot)
        array.push(midBars, bar_index)

    if bear_fvg
        _top = l3
        _bot = h1
        _mid = (_top + _bot) / 2
        b = box.new(bar_index, _top, bar_index + 1, _bot, bgcolor=bear_col, border_color=na)
        line.new(bar_index, _mid, bar_index + bars24h, _mid, color=mid_col, width=3)
        array.push(boxes, b)
        array.push(tops, _top)
        array.push(bots, _bot)
        array.push(mitigated, false)
        array.push(midPrices, _mid)
        array.push(midTops, _top)
        array.push(midBots, _bot)
        array.push(midBars, bar_index)

// --- AGE-OUT MIDLINES WHEN THE VISIBLE LINE ENDS (24 HOURS) ---
if array.size(midBars) > 0
    for i = array.size(midBars) - 1 to 0
        if (bar_index - array.get(midBars, i)) > bars24h
            array.remove(midPrices, i)
            array.remove(midTops, i)
            array.remove(midBots, i)
            array.remove(midBars, i)
````
