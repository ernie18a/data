# Session Opening Candles (Tokyo / London / New York)

- url: https://www.tradingview.com/script/qTud2E7i-Session-Opening-Candles-Tokyo-London-New-York/
- type: indicator
- pine_id: PUB;78ee0283e3354222a3cd660b2c073a5c
- version: 1.0

## Description

Indicator that show first 2 H1 candles of a session open. If the candle closes bullish, button will be red and vice versa.

## Source Code

````pine
//@version=5
indicator("Session Opening Candles (Tokyo / London / New York)", overlay=true, max_labels_count=500)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
show_tokyo  = input.bool(true, "Show Tokyo Session",    group="Sessions")
show_london = input.bool(true, "Show London Session",   group="Sessions")
show_ny     = input.bool(true, "Show New York Session", group="Sessions")

max_candles = input.int(2, "Opening candles to mark (1 or 2)", minval=1, maxval=2, group="Settings")
show_vlines = input.bool(false, "Show session-open vertical lines", group="Settings")

bull_col = input.color(color.new(color.green, 0), "Bullish colour", group="Colours")
bear_col = input.color(color.new(color.red,   0), "Bearish colour", group="Colours")
btn_size = input.string("small", "Button size", options=["tiny","small","normal","large","huge"], group="Colours")

label_style = label.style_label_up

// ─────────────────────────────────────────────
// LABEL SIZE HELPER
// ─────────────────────────────────────────────
f_size(s) =>
    s == "tiny"   ? size.tiny   :
     s == "small"  ? size.small  :
     s == "normal" ? size.normal :
     s == "large"  ? size.large  : size.huge

// ─────────────────────────────────────────────
// DST DETECTION
// ─────────────────────────────────────────────
f_us_dst() =>
    m  = month
    d  = dayofmonth
    dw = dayofweek
    in_dst = false
    if m > 3 and m < 11
        in_dst := true
    else if m == 3
        in_dst := d >= 8 and (dw == 1 ? true : d - dw + 1 >= 8)
    else if m == 11
        in_dst := not (d >= 8 or (d < 8 and dw == 1))
    in_dst

f_eu_dst() =>
    m  = month
    d  = dayofmonth
    dw = dayofweek
    in_dst = false
    if m > 3 and m < 10
        in_dst := true
    else if m == 3
        in_dst := d >= 25 and (dw == 1 ? true : d - ((dw - 1 + 6) % 7) >= 25)
    else if m == 10
        in_dst := not (d >= 25 and (dw == 1 ? true : d - ((dw - 1 + 6) % 7) >= 25))
    in_dst

// ─────────────────────────────────────────────
// SESSION OPEN TIMES IN UTC MINUTES
//   Tokyo  : always 00:00 UTC (09:00 JST, no DST)
//   London : 08:00 UTC winter / 07:00 UTC summer
//   NY     : 14:30 UTC winter / 13:30 UTC summer
// ─────────────────────────────────────────────
tokyo_open_mins  = 0
london_open_mins = f_eu_dst() ? 7 * 60 : 8 * 60
ny_open_mins     = f_us_dst() ? 13 * 60 + 30 : 14 * 60 + 30

// ─────────────────────────────────────────────
// BAR TIME IN UTC MINUTES FROM DAY START
// ─────────────────────────────────────────────
bar_h        = hour(time, "UTC")
bar_m        = minute(time, "UTC")
bar_mins_utc = bar_h * 60 + bar_m

// Timeframe in minutes (used to define session window)
tf_mins = timeframe.in_seconds() / 60

// ─────────────────────────────────────────────
// CANDLE INDEX WITHIN SESSION
// Returns 1 for first candle, 2 for second, 0 otherwise
// Uses bar open time vs session open time
// ─────────────────────────────────────────────
f_candle_num(session_open_mins) =>
    // How many minutes after session open does this bar start?
    diff = bar_mins_utc - session_open_mins
    candle_num = 0
    if diff >= 0 and diff < tf_mins
        candle_num := 1
    else if diff >= tf_mins and diff < tf_mins * 2
        candle_num := 2
    candle_num

// ─────────────────────────────────────────────
// DRAW LABEL HELPER
// ─────────────────────────────────────────────
f_draw(candle_num, prefix) =>
    is_bull = close >= open
    col     = is_bull ? bull_col : bear_col
    txt     = prefix + str.tostring(candle_num)
    label.new(bar_index, low, txt, style=label_style, color=col, textcolor=color.white, size=f_size(btn_size))

// ─────────────────────────────────────────────
// TOKYO
// ─────────────────────────────────────────────
if show_tokyo
    cn = f_candle_num(tokyo_open_mins)
    if cn > 0 and cn <= max_candles
        f_draw(cn, "TK")

// ─────────────────────────────────────────────
// LONDON
// ─────────────────────────────────────────────
if show_london
    cn = f_candle_num(london_open_mins)
    if cn > 0 and cn <= max_candles
        f_draw(cn, "LN")

// ─────────────────────────────────────────────
// NEW YORK
// ─────────────────────────────────────────────
if show_ny
    cn = f_candle_num(ny_open_mins)
    if cn > 0 and cn <= max_candles
        f_draw(cn, "NY")

// ─────────────────────────────────────────────
// OPTIONAL VERTICAL LINES
// ─────────────────────────────────────────────
if show_vlines
    if show_tokyo  and bar_mins_utc == tokyo_open_mins
        line.new(bar_index, high * 1.002, bar_index, low * 0.998, color=color.new(color.aqua,   60), width=1, style=line.style_dashed)
    if show_london and bar_mins_utc == london_open_mins
        line.new(bar_index, high * 1.002, bar_index, low * 0.998, color=color.new(color.yellow, 60), width=1, style=line.style_dashed)
    if show_ny     and bar_mins_utc == ny_open_mins
        line.new(bar_index, high * 1.002, bar_index, low * 0.998, color=color.new(color.orange, 60), width=1, style=line.style_dashed)
````
