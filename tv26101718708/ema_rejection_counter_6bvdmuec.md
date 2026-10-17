# EMA Rejection Counter

- url: https://www.tradingview.com/script/6bVdmuEc-EMA-Rejection-Counter/
- type: indicator
- pine_id: PUB;f01fbe28efd94c65b43b0db2e08416be
- version: 1.0

## Description

[b]EMA Rejection Counter[/b]
EMA Rejection Counter is a simple yet powerful tool designed to measure how often price gets rejected from key exponential moving averages. Instead of guessing which EMA “respects price” the most, this indicator gives you actual data.

[b]What It Does[/b]
This indicator tracks and counts rejection events on up to three customizable EMAs.

A rejection is defined as:

Price approaches the EMA
Touches the EMA during the candle
Then closes away from it

This helps identify which EMA is acting as the most reliable dynamic support/resistance.

[b]Features[/b]
✅ Track 3 customizable EMAs (default: 25 / 50 / 100)
✅ Automatic detection of bullish & bearish rejections
✅ Live rejection counter for each EMA
✅ On-chart labels (R1, R2, R3) to visualize rejection points
✅ Clean table display showing total counts
✅ Highlights the most respected EMA in real-time

[b]How to Use[/b]
Use this tool to identify which EMA price is reacting to most
Combine with your trend strategy (e.g., pullbacks, continuations)
The EMA with the highest rejection count often acts as the key level

[b]Example Use Cases[/b]
Finding the best EMA for your strategy
Confirming dynamic support/resistance
Filtering entries based on EMA reactions
Enhancing trend-following systems

[b]Notes[/b]
This is a statistical tool, not a standalone trading signal
Works best when combined with price action and market structure
Results may vary across timeframes and assets

## Source Code

````pine
//alicanbayar
//@version=5
indicator("EMA Rejection Counter", overlay=true, max_labels_count=500)

// ─── Inputs ────────────────────────────────────────────────────────────────
ema1_len = input.int(25,  "EMA 1 Length", minval=1, group="EMA Settings")
ema2_len = input.int(50,  "EMA 2 Length", minval=1, group="EMA Settings")
ema3_len = input.int(100, "EMA 3 Length", minval=1, group="EMA Settings")

show_ema1 = input.bool(true, "Show EMA 1", group="EMA Settings")
show_ema2 = input.bool(true, "Show EMA 2", group="EMA Settings")
show_ema3 = input.bool(true, "Show EMA 3", group="EMA Settings")

show_labels = input.bool(true, "Show Rejection Labels on Chart", group="Display")

// ─── EMA Calculations ──────────────────────────────────────────────────────
ema1 = ta.ema(close, ema1_len)
ema2 = ta.ema(close, ema2_len)
ema3 = ta.ema(close, ema3_len)

// Plot EMAs
plot(show_ema1 ? ema1 : na, title="EMA 1", color=color.new(color.orange, 0),  linewidth=1)
plot(show_ema2 ? ema2 : na, title="EMA 2", color=color.new(color.aqua, 0),    linewidth=1)
plot(show_ema3 ? ema3 : na, title="EMA 3", color=color.new(color.fuchsia, 0), linewidth=1)

// ─── Rejection Logic ───────────────────────────────────────────────────────
f_dist(price, ema_val) =>
    math.abs(price - ema_val)

f_rejection(ema_val) =>
    prev_dist      = f_dist(close[1], ema_val[1])
    prev_prev_dist = f_dist(close[2], ema_val[2])
    approaching    = prev_dist < prev_prev_dist

    ema_above_open = ema_val > open
    ema_below_open = ema_val < open

    bearish_touch = high >= ema_val and ema_above_open
    bullish_touch = low  <= ema_val and ema_below_open

    bearish_close = close < ema_val
    bullish_close = close > ema_val

    bearish_rejection = approaching and bearish_touch and bearish_close
    bullish_rejection = approaching and bullish_touch and bullish_close

    bearish_rejection or bullish_rejection

// Detect rejections for each EMA
rej1 = f_rejection(ema1)
rej2 = f_rejection(ema2)
rej3 = f_rejection(ema3)

// ─── Running Totals ────────────────────────────────────────────────────────
var int count1 = 0
var int count2 = 0
var int count3 = 0

if rej1
    count1 += 1
if rej2
    count2 += 1
if rej3
    count3 += 1

// ─── Optional: Labels on chart ─────────────────────────────────────────────
if show_labels and rej1
    label.new(bar_index, high + syminfo.mintick * 5,
     text="R1", style=label.style_label_down,
     color=color.new(color.orange, 60), textcolor=color.white, size=size.tiny)

if show_labels and rej2
    label.new(bar_index, high + syminfo.mintick * 10,
     text="R2", style=label.style_label_down,
     color=color.new(color.aqua, 60), textcolor=color.white, size=size.tiny)

if show_labels and rej3
    label.new(bar_index, high + syminfo.mintick * 15,
     text="R3", style=label.style_label_down,
     color=color.new(color.fuchsia, 60), textcolor=color.white, size=size.tiny)

// ─── Table ─────────────────────────────────────────────────────────────────
var table info_table = table.new(
 position.top_right, 2, 4,
 bgcolor      = color.new(color.black, 60),
 border_width = 1,
 border_color = color.new(color.gray, 70),
 frame_width  = 1,
 frame_color  = color.new(color.gray, 50))

if barstate.islast
    table.cell(info_table, 0, 0, "EMA",        text_color=color.new(color.gray, 20), text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(info_table, 1, 0, "Rejections", text_color=color.new(color.gray, 20), text_size=size.small, bgcolor=color.new(color.black, 50))

    max_count = math.max(count1, math.max(count2, count3))

    col1 = (count1 >= max_count and max_count > 0) ? color.green : color.white
    table.cell(info_table, 0, 1, "EMA " + str.tostring(ema1_len), text_color=col1, text_size=size.small)
    table.cell(info_table, 1, 1, str.tostring(count1),            text_color=col1, text_size=size.small)

    col2 = (count2 >= max_count and max_count > 0) ? color.green : color.white
    table.cell(info_table, 0, 2, "EMA " + str.tostring(ema2_len), text_color=col2, text_size=size.small)
    table.cell(info_table, 1, 2, str.tostring(count2),            text_color=col2, text_size=size.small)

    col3 = (count3 >= max_count and max_count > 0) ? color.green : color.white
    table.cell(info_table, 0, 3, "EMA " + str.tostring(ema3_len), text_color=col3, text_size=size.small)
    table.cell(info_table, 1, 3, str.tostring(count3),            text_color=col3, text_size=size.small)
````
