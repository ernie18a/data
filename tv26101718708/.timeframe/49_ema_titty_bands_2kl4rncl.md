# 49 EMA Titty Bands

- url: https://www.tradingview.com/script/2KL4RnCl-49-EMA-Titty-Bands/
- type: indicator
- pine_id: PUB;91b36320d3b1439495f590bc43c97560
- version: 1.0

## Description

The whole point of the custom indicator is that the EMAs stay anchored to 5-minute bars even when you drop to a 1-minute or 15-second chart. Normally if you put a 4/9 EMA on a 1-minute chart, it shows the last 4 and 9 one-minute bars — totally different data. Her indicator forces it to always show the 5-minute trend regardless of what timeframe you're on.

## Source Code

````pine
//@version=5
indicator(title="4/9 EMA Trend Bands", overlay=true, max_lines_count=500)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
tf = input.timeframe("5", title="EMA Timeframe (default 5m)")
ema_fast_len = input.int(4, title="Fast EMA Length")
ema_slow_len = input.int(9, title="Slow EMA Length")

yellow_zone = input.float(0.05, title="Yellow Zone Threshold (%)", step=0.01,
     tooltip="How close the EMAs need to be (as % of price) to trigger yellow")

show_fill    = input.bool(true,  title="Fill band between EMAs")
show_signals = input.bool(true,  title="Show reversal signal labels")

// ─────────────────────────────────────────────
// EMA CALCULATIONS (pinned to chosen timeframe)
// ─────────────────────────────────────────────
ema_fast = request.security(syminfo.tickerid, tf, ta.ema(close, ema_fast_len), lookahead=barmerge.lookahead_off)
ema_slow = request.security(syminfo.tickerid, tf, ta.ema(close, ema_slow_len), lookahead=barmerge.lookahead_off)

// ─────────────────────────────────────────────
// TREND STATE LOGIC
// ─────────────────────────────────────────────
gap_pct = math.abs(ema_fast - ema_slow) / ema_slow * 100

is_yellow = gap_pct < yellow_zone
is_green  = ema_fast > ema_slow and not is_yellow
is_red    = ema_fast < ema_slow and not is_yellow

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────
col_green  = color.new(color.green,  0)
col_red    = color.new(color.red,    0)
col_yellow = color.new(color.yellow, 0)

col_fill_green  = color.new(color.green,  80)
col_fill_red    = color.new(color.red,    80)
col_fill_yellow = color.new(color.yellow, 80)

band_color = is_green ? col_green : is_red ? col_red : col_yellow
fill_color  = is_green ? col_fill_green : is_red ? col_fill_red : col_fill_yellow

// ─────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────
p_fast = plot(ema_fast, title="Fast EMA (4)", color=band_color, linewidth=2)
p_slow = plot(ema_slow, title="Slow EMA (9)", color=band_color, linewidth=2)

fill(p_fast, p_slow, color=show_fill ? fill_color : na, title="Band Fill")

// ─────────────────────────────────────────────
// REVERSAL SIGNAL LABELS
// ─────────────────────────────────────────────
prev_green  = is_green[1]
prev_red    = is_red[1]
prev_yellow = is_yellow[1]

// Bullish reversal: crossed from red/yellow → green
bull_signal = show_signals and is_green and (prev_red or prev_yellow) and not (prev_green)

// Bearish reversal: crossed from green/yellow → red
bear_signal = show_signals and is_red and (prev_green or prev_yellow) and not (prev_red)

// Caution: entering yellow zone
caution_signal = show_signals and is_yellow and not prev_yellow

if bull_signal
    label.new(bar_index, ema_slow,
         text="▲ BULL",
         style=label.style_label_up,
         color=color.new(color.green, 20),
         textcolor=color.white,
         size=size.small)

if bear_signal
    label.new(bar_index, ema_fast,
         text="▼ BEAR",
         style=label.style_label_down,
         color=color.new(color.red, 20),
         textcolor=color.white,
         size=size.small)

if caution_signal
    label.new(bar_index, math.avg(ema_fast, ema_slow),
         text="⚠ CAUTION",
         style=label.style_label_right,
         color=color.new(color.yellow, 20),
         textcolor=color.black,
         size=size.small)

// ─────────────────────────────────────────────
// BACKGROUND SHADING (optional subtle tint)
// ─────────────────────────────────────────────
bgcolor(is_green  ? color.new(color.green,  95) : na, title="Bullish background")
bgcolor(is_red    ? color.new(color.red,    95) : na, title="Bearish background")
bgcolor(is_yellow ? color.new(color.yellow, 95) : na, title="Caution background")

// ─────────────────────────────────────────────
// RSI EXHAUSTION WARNING (plotted as a table)
// ─────────────────────────────────────────────
rsi_len   = input.int(14, title="RSI Length (for exhaustion check)")
rsi_ob    = input.int(70,  title="RSI Overbought Level")
rsi_os    = input.int(30,  title="RSI Oversold Level")

rsi_val   = ta.rsi(close, rsi_len)
is_ob     = rsi_val >= rsi_ob
is_os     = rsi_val <= rsi_os

// Warn when trend direction conflicts with RSI exhaustion
// (e.g. in downtrend but oversold — don't chase shorts)
exhaustion_warning = (is_red and is_os) or (is_green and is_ob)

var table info_table = table.new(position.top_right, 2, 4,
     border_width=1,
     border_color=color.new(color.gray, 60),
     bgcolor=color.new(color.black, 75))

if barstate.islast
    trend_text  = is_green ? "▲ UPTREND" : is_red ? "▼ DOWNTREND" : "◆ NEUTRAL"
    trend_color = is_green ? color.green  : is_red ? color.red      : color.yellow

    table.cell(info_table, 0, 0, "TREND",      text_color=color.gray,  text_size=size.small)
    table.cell(info_table, 1, 0, trend_text,   text_color=trend_color, text_size=size.small)

    table.cell(info_table, 0, 1, "RSI",        text_color=color.gray,  text_size=size.small)
    table.cell(info_table, 1, 1, str.tostring(math.round(rsi_val, 1)),
         text_color = is_ob ? color.red : is_os ? color.aqua : color.white,
         text_size=size.small)

    table.cell(info_table, 0, 2, "EXHAUSTED?", text_color=color.gray,  text_size=size.small)
    table.cell(info_table, 1, 2,
         exhaustion_warning ? "⚠ YES — be careful" : "No",
         text_color = exhaustion_warning ? color.orange : color.gray,
         text_size=size.small)

    table.cell(info_table, 0, 3, "EMA Gap",    text_color=color.gray,  text_size=size.small)
    table.cell(info_table, 1, 3, str.tostring(math.round(gap_pct, 3)) + "%",
         text_color=color.white, text_size=size.small)
````
