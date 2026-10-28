# Multi-Timeframe Candles

- url: https://www.tradingview.com/script/YDDBhfyl/
- type: indicator
- pine_id: PUB;86f23cfa222c40b4a1b2162a07f08599
- version: 1.0

## Description

MULTI-TIMEFRAME CANDLES

WHAT IT IS

Multi-Timeframe Candles is a visual context tool that displays the current (still-forming) candle from higher timeframes directly on your chart, without requiring you to switch the chart's timeframe. Instead of flipping back and forth between 5m, 15m, 1h, 4h, and Daily charts to check what the bigger picture looks like, this indicator brings that information to you in real time, rendered as a small set of candles off to the side of the price action.

The timeframe list is fixed: 5 minutes, 15 minutes, 1 hour, 4 hours, and Daily. The indicator automatically compares each of these against the timeframe you are currently viewing and only draws the ones that are strictly higher. For example, if you are on a 5-minute chart, you will see 15m, 1h, 4h, and D. If you are on a 1-hour chart, you will only see 4h and D, since 5m and 15m are no longer higher timeframes relative to your current view. This keeps the display relevant no matter which timeframe you trade on.

WHAT IT IS MADE OF

Each higher timeframe is represented by a single candle, built from three drawing elements:

- A rectangular body showing the open and close of that timeframe's current candle, colored green (bullish) if close is greater than or equal to open, or red (bearish) otherwise.
- A thin vertical wick showing the full high-to-low range of that timeframe's current candle.
- A text label positioned below the candle, identifying which timeframe it represents (5m, 15m, 1h, 4h, or D).

These candles are placed in a horizontal row to the right of your current price action, spaced evenly apart, ordered from the smallest qualifying timeframe to the largest (left to right). They update live as price moves, since each candle reflects the still-forming candle of its respective timeframe, not a closed historical one.

HOW TO READ IT

Each candle should be read exactly like you would read it on its native timeframe's chart:

- A green candle means that timeframe is currently trading above where it opened — net bullish pressure so far on that timeframe.
- A red candle means that timeframe is currently trading below where it opened — net bearish pressure so far on that timeframe.
- The length of the wick relative to the body tells you about volatility and rejection within that timeframe's current candle: a long wick with a small body suggests indecision or a strong intra-candle reversal, while a large body with short wicks suggests a strong, decisive directional move.
- Comparing the candles across timeframes side by side lets you quickly judge alignment: if your lower timeframe and the higher timeframes are all the same color, you have multi-timeframe confluence in one direction. If they disagree (e.g., the 5m candle is red while the 4h and Daily candles are green), you are likely looking at a short-term pullback or reaction within a larger prevailing trend, which carries very different implications than a same-direction move.

HOW TO USE IT

This indicator is meant purely as a contextual reference, not a standalone signal generator. The intended use is:

1. Stay on your working timeframe (the one you actually use for entries, e.g., 1m or 5m).
2. Glance at the row of higher-timeframe candles to instantly understand where price stands relative to the open of each larger timeframe, without needing to switch charts and lose your current view, drawings, or zoom level.
3. Use this context to filter or qualify setups on your working timeframe. For example, a bullish setup on a lower timeframe may carry more weight if the higher timeframe candles are also green, indicating you are trading with the larger trend rather than against it.
4. Use it to anticipate behavior near higher-timeframe candle opens, since price often reacts around these levels even when they are not explicitly plotted as horizontal lines.

All visual aspects (candle width, spacing between candles, distance from the last bar on the chart, bullish/bearish colors, and label size) are configurable through the indicator's settings panel to fit your chart layout and personal style.

## Source Code

````pine
//@version=6
indicator("Multi-Timeframe Candles", shorttitle="MTF Candles", overlay=true, max_boxes_count=20, max_lines_count=20, max_labels_count=20)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
candle_width      = input.int(8, "Candle Width", minval=2, maxval=30, group="Visual")
candle_spacing    = input.int(20, "Spacing Between Candles", minval=5, maxval=60, group="Visual")
offset_from_chart = input.int(20, "Offset From Last Price", minval=5, maxval=100, group="Visual")

bull_color = input.color(color.new(#089981, 0), "Bullish Candle Color", group="Visual")
bear_color = input.color(color.new(#F23645, 0), "Bearish Candle Color", group="Visual")
label_size = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal", "Large"], group="Visual")

// ─────────────────────────────────────────────
// Fixed list of higher timeframes to evaluate
// ─────────────────────────────────────────────
TF_LIST = array.from("5", "15", "60", "240", "1D")
TF_LABELS = array.from("5m", "15m", "1h", "4h", "D")

getLabelSize() =>
    switch label_size
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

// ─────────────────────────────────────────────
// Determine which timeframes are higher than the current chart timeframe
// timeframe.in_seconds() allows comparing any TF uniformly
// ─────────────────────────────────────────────
currentTFSeconds = timeframe.in_seconds()

// ─────────────────────────────────────────────
// Fetch OHLC for each fixed timeframe via request.security
// (all are always fetched; which ones to draw is decided afterward)
// ─────────────────────────────────────────────
[o5, h5, l5, c5]     = request.security(syminfo.tickerid, "5",   [open, high, low, close], lookahead=barmerge.lookahead_off)
[o15, h15, l15, c15] = request.security(syminfo.tickerid, "15",  [open, high, low, close], lookahead=barmerge.lookahead_off)
[o60, h60, l60, c60] = request.security(syminfo.tickerid, "60",  [open, high, low, close], lookahead=barmerge.lookahead_off)
[o240, h240, l240, c240] = request.security(syminfo.tickerid, "240", [open, high, low, close], lookahead=barmerge.lookahead_off)
[oD, hD, lD, cD]     = request.security(syminfo.tickerid, "1D",  [open, high, low, close], lookahead=barmerge.lookahead_off)

tfSecondsFor(tf) =>
    switch tf
        "5"   => 300
        "15"  => 900
        "60"  => 3600
        "240" => 14400
        "1D"  => 86400
        => 0

// ─────────────────────────────────────────────
// Cleanup and drawing
// ─────────────────────────────────────────────
var box[]   candleBoxes  = array.new_box(0)
var line[]  candleWicks  = array.new_line(0)
var label[] candleLabels = array.new_label(0)

drawCandle(x, o, h, l, c, tfText, col) =>
    is_bull = c >= o
    body_top = is_bull ? c : o
    body_bot = is_bull ? o : c

    wick = line.new(x, h, x, l, color=col, width=1)
    array.push(candleWicks, wick)

    body = box.new(left=x - candle_width / 2, top=body_top, right=x + candle_width / 2, bottom=body_bot, border_color=col, bgcolor=color.new(col, 0))
    array.push(candleBoxes, body)

    lbl = label.new(x, l, tfText, xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.black, 100), textcolor=col, size=getLabelSize(), style=label.style_label_up)
    array.push(candleLabels, lbl)

if barstate.islast
    // clear previous drawings
    for bx in candleBoxes
        box.delete(bx)
    array.clear(candleBoxes)
    for ln in candleWicks
        line.delete(ln)
    array.clear(candleWicks)
    for lb in candleLabels
        label.delete(lb)
    array.clear(candleLabels)

    int drawnCount = 0
    x = bar_index + offset_from_chart

    for i = 0 to array.size(TF_LIST) - 1
        tf = array.get(TF_LIST, i)
        tfLabel = array.get(TF_LABELS, i)
        tfSec = tfSecondsFor(tf)

        if tfSec > currentTFSeconds
            float o = na
            float h = na
            float l = na
            float c = na

            if tf == "5"
                o := o5
                h := h5
                l := l5
                c := c5
            else if tf == "15"
                o := o15
                h := h15
                l := l15
                c := c15
            else if tf == "60"
                o := o60
                h := h60
                l := l60
                c := c60
            else if tf == "240"
                o := o240
                h := h240
                l := l240
                c := c240
            else if tf == "1D"
                o := oD
                h := hD
                l := lD
                c := cD

            if not na(o)
                is_bull = c >= o
                col = is_bull ? bull_color : bear_color
                xPos = x + drawnCount * candle_spacing
                drawCandle(xPos, o, h, l, c, tfLabel, col)
                drawnCount += 1
````
