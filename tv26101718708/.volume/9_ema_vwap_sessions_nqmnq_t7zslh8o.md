# 9 EMA / VWAP + Sessions [NQ/MNQ]

- url: https://www.tradingview.com/script/t7zslH8O-9-EMA-VWAP-Sessions-NQ-MNQ/
- type: indicator
- pine_id: PUB;4a115e76ee71480b8689a9af7cfe97c4
- version: 1.0

## Description

A combined trend bias and session awareness indicator built specifically for NQ/MNQ futures trading on the 5-minute chart.

9 EMA / VWAP Signal System:
Uses the crossover of the 9-period EMA and VWAP (Volume Weighted Average Price) to identify potential trend shifts with three-condition confirmation:

The cross — 9 EMA crosses above or below VWAP, signaling a shift in short-term momentum relative to the day's volume-weighted price
Price filter — price must be on the correct side of VWAP at the time of the cross. No longing below VWAP, no shorting above it
Slope confirmation — the 9 EMA must be actively rising for longs and falling for shorts, ensuring momentum is genuine and not just a flat cross

When all three conditions align a ▲ LONG or ▼ SHORT label fires on the chart. Crosses that don't meet all conditions appear as a small faded ⚠ label so you can see what was filtered and learn from it.
The background color reflects current bias at a glance — green when the 9 EMA is above VWAP, red when below. Optional VWAP standard deviation bands can be toggled on as natural support and resistance targets.

Key MNQ Session Times:
Vertical lines mark the six most important time events for MNQ futures traders:

⚡ 6:00 PM ET — Futures reopen, sets overnight direction
📊 8:30 AM ET — Economic data releases, expect volatility spikes
🗽 9:30 AM ET — NY cash open, highest volume of the day, strongest signals
🍽 12:00 PM ET — Lunch lull, volume dries up, choppy price action
📈 2:00 PM ET — Afternoon session, second momentum window of the day
🔔 4:00 PM ET — NY cash close, sharp moves common

All session lines and labels are fully toggleable individually. A subtle background highlight marks the core NY session from 9:30 AM to 4:00 PM ET.

Best used as a confluence tool — when a 9 EMA / VWAP signal fires near a key session open, especially the NY open or 8:30 AM data window, that's your highest probability setup of the day.


BUILT WITH CLAUDE AI

## Source Code

````pine
//@version=6
indicator("9 EMA / VWAP + Sessions [NQ/MNQ]", overlay=true, max_labels_count=500, max_lines_count=500)

// ═══════════════════════════════════════════════════════════
//  INPUTS — 9 EMA / VWAP
// ═══════════════════════════════════════════════════════════
grp1 = "EMA / VWAP Settings"
ema_len           = input.int(9,     "EMA Length",                             minval=1,  group=grp1)
slope_bars        = input.int(3,     "Slope Lookback (bars)",                  minval=1,  group=grp1)
use_price_filter  = input.bool(true, "Require Price on Correct Side of VWAP",            group=grp1)
use_slope_filter  = input.bool(true, "Require 9 EMA Slope Confirmation",                 group=grp1)
min_ema_vwap_dist = input.float(0.0, "Min Distance EMA/VWAP (points)",         minval=0.0, step=0.5, group=grp1)

grp2 = "EMA / VWAP Display"
bull_col         = input.color(color.new(#00E676, 0), "Bullish Color",         group=grp2)
bear_col         = input.color(color.new(#FF1744, 0), "Bearish Color",         group=grp2)
ema_col          = input.color(color.new(#FFD700, 0), "9 EMA Color",           group=grp2)
vwap_col         = input.color(color.new(#2962FF, 0), "VWAP Color",            group=grp2)
show_bg          = input.bool(true,  "Show Bias Background",                   group=grp2)
bg_opacity       = input.int(93,     "Background Opacity", minval=50, maxval=99, group=grp2)
show_labels      = input.bool(true,  "Show Signal Labels",                     group=grp2)
show_vwap_bands  = input.bool(false, "Show VWAP Bands (±1 StdDev)",            group=grp2)

// ═══════════════════════════════════════════════════════════
//  INPUTS — KEY MNQ SESSION TIMES
// ═══════════════════════════════════════════════════════════
grp3 = "Key MNQ Times"
show_futures     = input.bool(true,  "Futures Open — 6:00 PM ET",   group=grp3)
show_econ        = input.bool(true,  "Economic Data — 8:30 AM ET",  group=grp3)
show_ny          = input.bool(true,  "NY Cash Open — 9:30 AM ET",   group=grp3)
show_lunch       = input.bool(true,  "Lunch Lull — 12:00 PM ET",    group=grp3)
show_afternoon   = input.bool(true,  "Afternoon — 2:00 PM ET",      group=grp3)
show_close       = input.bool(true,  "NY Cash Close — 4:00 PM ET",  group=grp3)

grp4 = "Session Display"
futures_col      = input.color(color.new(#AA00FF, 0), "Futures Open Color",   group=grp4)
econ_col         = input.color(color.new(#FF6D00, 0), "Economic Data Color",  group=grp4)
ny_col           = input.color(color.new(#00E676, 0), "NY Open Color",        group=grp4)
lunch_col        = input.color(color.new(#FFD700, 0), "Lunch Lull Color",     group=grp4)
afternoon_col    = input.color(color.new(#00BCD4, 0), "Afternoon Color",      group=grp4)
close_col        = input.color(color.new(#FF1744, 0), "NY Close Color",       group=grp4)
show_vert_lines  = input.bool(true, "Show Vertical Lines",                    group=grp4)
sess_line_width  = input.int(1, "Vertical Line Width", minval=1, maxval=4,    group=grp4)
show_sess_labels = input.bool(true, "Show Session Labels",                    group=grp4)
show_ny_bg       = input.bool(true, "Highlight NY Session (9:30–4:00 ET)",    group=grp4)

// ═══════════════════════════════════════════════════════════
//  TIME
// ═══════════════════════════════════════════════════════════
et_hour = hour(time, "America/New_York")
et_min  = minute(time, "America/New_York")

// ═══════════════════════════════════════════════════════════
//  9 EMA / VWAP CALCULATIONS
// ═══════════════════════════════════════════════════════════
ema9     = ta.ema(close, ema_len)
vwap_val = ta.vwap(hlc3)

// VWAP Standard Deviation Bands
var float sum_vol        = 0.0
var float sum_vol_price  = 0.0
var float sum_vol_price2 = 0.0

if ta.change(time("D")) != 0
    sum_vol        := 0.0
    sum_vol_price  := 0.0
    sum_vol_price2 := 0.0

sum_vol        := sum_vol        + volume
sum_vol_price  := sum_vol_price  + volume * hlc3
sum_vol_price2 := sum_vol_price2 + volume * hlc3 * hlc3

vwap_std   = math.sqrt(math.max(sum_vol_price2 / sum_vol - math.pow(sum_vol_price / sum_vol, 2), 0))
vwap_upper = vwap_val + vwap_std
vwap_lower = vwap_val - vwap_std

// Slope, bias, filters
ema_slope_up   = ema9 > ema9[slope_bars]
ema_slope_down = ema9 < ema9[slope_bars]
above_vwap     = close > vwap_val
below_vwap     = close < vwap_val
prev_dist      = math.abs(ema9[1] - vwap_val[1])
dist_ok        = prev_dist >= min_ema_vwap_dist

bull_cross = ta.crossover(ema9,  vwap_val)
bear_cross = ta.crossunder(ema9, vwap_val)

price_ok_long  = use_price_filter ? above_vwap     : true
price_ok_short = use_price_filter ? below_vwap     : true
slope_ok_long  = use_slope_filter ? ema_slope_up   : true
slope_ok_short = use_slope_filter ? ema_slope_down : true

long_sig  = bull_cross and price_ok_long  and slope_ok_long  and dist_ok
short_sig = bear_cross and price_ok_short and slope_ok_short and dist_ok

is_bullish = ema9 > vwap_val
is_bearish = ema9 < vwap_val

// ═══════════════════════════════════════════════════════════
//  SIGNAL LABELS
// ═══════════════════════════════════════════════════════════
if long_sig and show_labels
    label.new(bar_index, low * 0.9997,
              "▲ LONG\n9 EMA ✕ VWAP\nVWAP: " + str.tostring(vwap_val, "#.00") +
              "\n9 EMA: " + str.tostring(ema9, "#.00"),
              color=bull_col, textcolor=color.white,
              style=label.style_label_up, size=size.normal)

if short_sig and show_labels
    label.new(bar_index, high * 1.0003,
              "▼ SHORT\n9 EMA ✕ VWAP\nVWAP: " + str.tostring(vwap_val, "#.00") +
              "\n9 EMA: " + str.tostring(ema9, "#.00"),
              color=bear_col, textcolor=color.white,
              style=label.style_label_down, size=size.normal)

if bull_cross and not long_sig and show_labels
    label.new(bar_index, low * 0.9997, "⚠ Cross\n(filtered)",
              color=color.new(bull_col, 60), textcolor=color.new(color.white, 30),
              style=label.style_label_up, size=size.tiny)

if bear_cross and not short_sig and show_labels
    label.new(bar_index, high * 1.0003, "⚠ Cross\n(filtered)",
              color=color.new(bear_col, 60), textcolor=color.new(color.white, 30),
              style=label.style_label_down, size=size.tiny)

// ═══════════════════════════════════════════════════════════
//  SESSION LINES + LABELS
// ═══════════════════════════════════════════════════════════
draw_session(condition, col, label_text) =>
    if condition
        if show_vert_lines
            line.new(bar_index, low * 0.998, bar_index, high * 1.002,
                     color=col, width=sess_line_width,
                     style=line.style_solid, extend=extend.both)
        if show_sess_labels
            label.new(bar_index, high * 1.001, label_text,
                      color=color.new(col, 15),
                      textcolor=color.white,
                      style=label.style_label_down,
                      size=size.small)

draw_session(show_futures   and et_hour == 18 and et_min == 0,  futures_col,  "⚡ Futures Open\n6:00 PM ET")
draw_session(show_econ      and et_hour == 8  and et_min == 30, econ_col,     "📊 Econ Data\n8:30 AM ET")
draw_session(show_ny        and et_hour == 9  and et_min == 30, ny_col,       "🗽 NY Open\n9:30 AM ET")
draw_session(show_lunch     and et_hour == 12 and et_min == 0,  lunch_col,    "🍽 Lunch Lull\n12:00 PM ET")
draw_session(show_afternoon and et_hour == 14 and et_min == 0,  afternoon_col,"📈 Afternoon\n2:00 PM ET")
draw_session(show_close     and et_hour == 16 and et_min == 0,  close_col,    "🔔 NY Close\n4:00 PM ET")

// ═══════════════════════════════════════════════════════════
//  PLOTS
// ═══════════════════════════════════════════════════════════
plot(ema9,     "9 EMA", color=ema_col,  linewidth=2)
plot(vwap_val, "VWAP",  color=vwap_col, linewidth=2)

plot(show_vwap_bands ? vwap_upper : na, "VWAP +1σ", color=color.new(vwap_col, 50), linewidth=1, style=plot.style_linebr)
plot(show_vwap_bands ? vwap_lower : na, "VWAP -1σ", color=color.new(vwap_col, 50), linewidth=1, style=plot.style_linebr)

// Bias background
bgcolor(show_bg and is_bullish ? color.new(bull_col, bg_opacity) : na, title="Bullish Bias")
bgcolor(show_bg and is_bearish ? color.new(bear_col, bg_opacity) : na, title="Bearish Bias")

// NY session highlight
in_ny_session = et_hour >= 9 and et_hour < 16 and not (et_hour == 9 and et_min < 30)
bgcolor(show_ny_bg and in_ny_session ? color.new(ny_col, 97) : na, title="NY Session")

// ═══════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════
alertcondition(long_sig,              "9EMA/VWAP Long",        "LONG — 9 EMA crossed above VWAP with confirmation.")
alertcondition(short_sig,             "9EMA/VWAP Short",       "SHORT — 9 EMA crossed below VWAP with confirmation.")
alertcondition(long_sig or short_sig, "9EMA/VWAP Any Signal",  "9EMA/VWAP signal fired — check chart for direction.")
````
