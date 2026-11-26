# vwap jjr

- url: https://www.tradingview.com/script/NjNFyaVC-vwap-jjr/
- type: indicator
- pine_id: PUB;b8eac273b1d442d3882e2ade33d66b17
- version: 1.0

## Description

vwap on the daily and ny market. volume weighted average price

## Source Code

````pine
//@version=6
indicator("vwap jjr", overlay=true, max_lines_count=20, max_labels_count=20)

// ── Inputs ───────────────────────────────────────────────────────────────────
show_daily   = input.bool(true,  "Show Daily VWAP")
show_nyopen  = input.bool(true,  "Show NY Open VWAP")
show_weekly  = input.bool(true,  "Show Weekly VWAP")
show_bands   = input.bool(false, "Show ±1σ Bands")
daily_col    = input.color(color.new(color.orange, 0), "Daily VWAP")
nyopen_col   = input.color(color.new(color.blue,   0), "NY Open VWAP")
weekly_col   = input.color(color.new(color.lime,   0), "Weekly VWAP")

tz = "America/New_York"

// ── CME Globex day: resets at 6 PM ET (18:00) — standard futures daily anchor
// time("D", "1800-1759", tz) gives a new "day" starting at 6 PM ET each evening
globex_day   = time("D", "1800-1759", tz)
is_new_globex_day = ta.change(globex_day) != 0

// ── RTH session: 9:30 AM – 4:00 PM ET, Mon–Fri
rth_session  = "0930-1600:23456"
in_rth       = not na(time(timeframe.period, rth_session, tz))
rth_start    = in_rth and not in_rth[1]

// ── Weekly: new CME week starts Sunday 6 PM ET
globex_week  = time("W", "1800-1759:1", tz)   // "1" = Sunday
is_new_week  = ta.change(globex_week) != 0

typical = hlc3

// ── Daily VWAP (CME session, resets 6 PM ET) ─────────────────────────────────
var float d_num = na
var float d_den = na
var float d_sq  = na

if is_new_globex_day or na(d_num)
    d_num := 0.0
    d_den := 0.0
    d_sq  := 0.0

d_num += typical * volume
d_den += volume
d_sq  += typical * typical * volume

daily_vwap = d_den > 0 ? d_num / d_den : na
daily_var  = d_den > 0 ? math.max(d_sq / d_den - daily_vwap * daily_vwap, 0.0) : na
daily_std  = not na(daily_var) ? math.sqrt(daily_var) : na

plot(show_daily ? daily_vwap : na, "Daily VWAP", color=daily_col, linewidth=1)
plot(show_daily and show_bands ? daily_vwap + daily_std : na, "DVWAP +1σ", color=color.new(daily_col,55), linewidth=1, style=plot.style_linebr)
plot(show_daily and show_bands ? daily_vwap - daily_std : na, "DVWAP -1σ", color=color.new(daily_col,55), linewidth=1, style=plot.style_linebr)

// ── NY Open VWAP (anchored to 9:30 ET, RTH bars only) ────────────────────────
var float ny_num = na
var float ny_den = na

if rth_start
    ny_num := 0.0
    ny_den := 0.0

if in_rth and not na(ny_num)
    ny_num += typical * volume
    ny_den += volume

ny_vwap = in_rth and ny_den > 0 ? ny_num / ny_den : na
plot(show_nyopen ? ny_vwap : na, "NY Open VWAP", color=nyopen_col, linewidth=1, style=plot.style_linebr)

// ── Weekly VWAP (CME week, resets Sunday 6 PM ET) ────────────────────────────
var float w_num = na
var float w_den = na

if is_new_week or na(w_num)
    w_num := 0.0
    w_den := 0.0

w_num += typical * volume
w_den += volume

weekly_vwap = w_den > 0 ? w_num / w_den : na
plot(show_weekly ? weekly_vwap : na, "Weekly VWAP", color=weekly_col, linewidth=1)
````
