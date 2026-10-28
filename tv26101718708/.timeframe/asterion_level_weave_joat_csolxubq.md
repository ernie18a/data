# Asterion Level Weave [JOAT]

- url: https://www.tradingview.com/script/cSolXuBQ-Asterion-Level-Weave-JOAT/
- type: indicator
- pine_id: PUB;ca12095d2f9f423b9aa808fc804d8e32
- version: 1.0

## Description

[b]Asterion Level Weave [JOAT][/b]

[b]Introduction[/b]

Asterion Level Weave is an open-source reference-level and directional-bias overlay built around daily pivots, weekly pivots, a weighted EMA weave, and opening-range structure. Its purpose is to show where price is located relative to higher-order reference levels while also showing whether internal directional pressure is aligned with those levels.

The problem this script solves is context stacking. Traders frequently use pivot lattices, moving averages, and opening ranges separately, then mentally combine them. Asterion Level Weave places those components into one framework so the user can evaluate premium versus discount location, directional weave bias, and session structure from a single chart layer.

[image]https://www.tradingview.com/x/WlZ7xXWX/[/image]

[b]Core Concepts[/b]

[b]1. Daily And Weekly Pivot Lattice[/b]
The script calculates prior-day and prior-week pivot references and extends them forward on the chart. Daily pivot, R1, S1, R2, and S2 create the near-term lattice, while weekly pivot references provide a slower macro anchor.

[b]2. Weighted EMA Weave[/b]
Instead of averaging EMAs equally, the script weights multiple EMAs by their recent slope magnitude. This gives more influence to the parts of the curve that are moving with stronger directional intent.

[b]3. Equilibrium And Location Model[/b]
The script derives an equilibrium box around the daily pivot and uses price location relative to that structure to frame premium, discount, and balance.

[b]4. Opening Range Structure[/b]
An opening-session range is captured and projected forward with a midpoint reference. This adds a session-specific structure layer that can be compared against pivot and weave alignment.

[b]Features[/b]

[list]
[*][b]Daily pivot lattice:[/b] D-pivot, R1, S1, R2, and S2 with forward extension
[*][b]Weekly pivot lattice:[/b] Weekly pivot references for broader context
[*][b]Daily equilibrium box:[/b] Optional box around the central daily balance zone
[*][b]Weighted EMA weave:[/b] Multi-EMA directional cloud with weighted centerline
[*][b]Location labeling:[/b] Right-edge labels for major active references
[*][b]Opening range projection:[/b] Session range and midpoint extension
[*][b]Directional candle tint:[/b] Candle state can reflect weave direction
[*][b]Dashboard:[/b] Displays location, directional bias, pivot state, and opening structure context
[*][b]Higher-order reference integration:[/b] Daily, weekly, session, and EMA structure in one chart layer
[/list]

[b]Input Parameters[/b]

[b]Reference Levels:[/b]
[list]
[*]Daily and weekly pivot toggles
[*]Forward extension controls
[*]Equilibrium box toggle
[/list]

[b]Ribbon Engine And Display:[/b]
[list]
[*]EMA weave toggle, centerline toggle, ribbon smoothing, and slope lookback for weighting
[*]Opening range session and extension
[*]Dashboard, candle-color, and background toggles
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1:[/b] Determine whether price is trading above or below the daily pivot and weekly pivot.
[b]Step 2:[/b] Use the weave centerline and cloud direction to judge whether internal momentum aligns with that location.
[b]Step 3:[/b] Treat the equilibrium box as a balance region and the pivot lattice as directional reference.
[b]Step 4:[/b] Use the opening range and midpoint to see whether the session is accepting above or below initial balance.
[b]Step 5:[/b] Prefer trades where location, weave bias, and opening-range behavior point in the same direction.

[b]Indicator Limitations[/b]

[list]
[*]Pivot references are static for the active session and do not adapt intraday until the next period begins
[*]The weighted weave still relies on lagging EMA calculations and will trail abrupt reversals
[*]Opening range significance depends on the instrument and session chosen
[*]This script is best used as a context framework rather than as a standalone entry trigger
[/list]

[b]Originality Statement[/b]

Asterion Level Weave is original in how it combines forward pivot lattices, a slope-weighted EMA weave, and opening-range structure into one location-versus-bias framework. Each component answers a different part of the same question: where price is, how it is moving, and how the active session is organizing around reference levels.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Pivot levels, equilibrium zones, and moving-average structure are analytical tools and should not be treated as guaranteed reaction levels.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Asterion Level Weave [JOAT]", shorttitle="ALW [JOAT]", overlay=true, max_lines_count=250, max_boxes_count=120, max_labels_count=120)

//==============================================================================
// INPUTS
//==============================================================================
grp_pivot = "Reference Levels"
show_daily_pivots = input.bool(true, "Show Daily Pivot Lattice", group=grp_pivot)
show_weekly_pivots = input.bool(true, "Show Weekly Pivot Lattice", group=grp_pivot)
daily_extend = input.int(80, "Daily Level Extension", minval=10, maxval=400, group=grp_pivot)
weekly_extend = input.int(140, "Weekly Level Extension", minval=10, maxval=500, group=grp_pivot)
show_equilibrium_box = input.bool(true, "Show Daily Equilibrium Box", group=grp_pivot)

grp_ribbon = "Ribbon Engine"
show_ribbon = input.bool(true, "Show EMA Weave", group=grp_ribbon)
show_centerline = input.bool(true, "Show Weighted Centerline", group=grp_ribbon)
ribbon_smooth = input.int(3, "Ribbon Smoothing", minval=1, maxval=10, group=grp_ribbon)
weight_lookback = input.int(3, "Slope Lookback", minval=1, maxval=10, group=grp_ribbon)

grp_opening = "Opening Structure"
show_opening_range = input.bool(true, "Show Cash Opening Range", group=grp_opening)
opening_session = input.session("0930-1000", "Opening Range Session", group=grp_opening)
opening_extend = input.int(50, "Opening Range Extension", minval=10, maxval=200, group=grp_opening)

grp_visual = "Visuals"
show_dashboard = input.bool(true, "Show Dashboard", group=grp_visual)
show_bar_state = input.bool(true, "Color Candles", group=grp_visual)
show_background = input.bool(false, "Show Background Tint", group=grp_visual)

//==============================================================================
// PALETTE
//==============================================================================
panel_bg = color.rgb(10, 16, 24)
panel_header = color.rgb(21, 31, 43)
panel_cell = color.rgb(16, 24, 35)
panel_grid = color.rgb(41, 56, 75)
text_main = color.rgb(228, 234, 242)
text_dim = color.rgb(145, 161, 180)

pivot_col = color.rgb(123, 143, 255)
res_col = color.rgb(255, 114, 138)
sup_col = color.rgb(0, 208, 150)
weekly_col = color.rgb(228, 181, 79)
ribbon_bull = color.rgb(0, 214, 143)
ribbon_bear = color.rgb(255, 93, 126)
ribbon_neutral = color.rgb(126, 155, 255)
accent_gold = color.rgb(229, 182, 80)

//==============================================================================
// DAILY AND WEEKLY REFERENCE DATA
//==============================================================================
[prev_day_high, prev_day_low, prev_day_close] = request.security(syminfo.tickerid, "D", [high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
[prev_week_high, prev_week_low, prev_week_close] = request.security(syminfo.tickerid, "W", [high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)

day_pivot = (prev_day_high + prev_day_low + prev_day_close) / 3.0
day_r1 = 2.0 * day_pivot - prev_day_low
day_s1 = 2.0 * day_pivot - prev_day_high
day_r2 = day_pivot + (prev_day_high - prev_day_low)
day_s2 = day_pivot - (prev_day_high - prev_day_low)
day_eq_hi = day_pivot + (day_r1 - day_pivot) * 0.382
day_eq_lo = day_pivot - (day_pivot - day_s1) * 0.382

week_pivot = (prev_week_high + prev_week_low + prev_week_close) / 3.0
week_r1 = 2.0 * week_pivot - prev_week_low
week_s1 = 2.0 * week_pivot - prev_week_high

new_day = ta.change(time("D")) != 0
new_week = ta.change(time("W")) != 0

//==============================================================================
// PERSISTENT DRAWING STATE
//==============================================================================
var line day_pivot_line = na
var line day_r1_line = na
var line day_s1_line = na
var line day_r2_line = na
var line day_s2_line = na
var box day_eq_box = na

var line week_pivot_line = na
var line week_r1_line = na
var line week_s1_line = na

var label day_pivot_label = na
var label day_r1_label = na
var label day_s1_label = na
var label week_pivot_label = na

//==============================================================================
// DRAW DAILY LATTICE
//==============================================================================
if show_daily_pivots and (barstate.isfirst or new_day)
    line.delete(day_pivot_line)
    line.delete(day_r1_line)
    line.delete(day_s1_line)
    line.delete(day_r2_line)
    line.delete(day_s2_line)
    box.delete(day_eq_box)

    day_pivot_line := line.new(bar_index, day_pivot, bar_index + daily_extend, day_pivot, color=pivot_col, width=2)
    day_r1_line := line.new(bar_index, day_r1, bar_index + daily_extend, day_r1, color=res_col, style=line.style_dashed)
    day_s1_line := line.new(bar_index, day_s1, bar_index + daily_extend, day_s1, color=sup_col, style=line.style_dashed)
    day_r2_line := line.new(bar_index, day_r2, bar_index + daily_extend, day_r2, color=color.new(res_col, 30), style=line.style_dotted)
    day_s2_line := line.new(bar_index, day_s2, bar_index + daily_extend, day_s2, color=color.new(sup_col, 30), style=line.style_dotted)
    if show_equilibrium_box
        day_eq_box := box.new(bar_index, day_eq_hi, bar_index + daily_extend, day_eq_lo, bgcolor=color.new(pivot_col, 92), border_color=color.new(pivot_col, 75), text="DAILY EQ", text_color=text_dim, text_size=size.tiny, text_halign=text.align_right)

if show_daily_pivots and not na(day_pivot_line)
    line.set_x2(day_pivot_line, bar_index + daily_extend)
    line.set_x2(day_r1_line, bar_index + daily_extend)
    line.set_x2(day_s1_line, bar_index + daily_extend)
    line.set_x2(day_r2_line, bar_index + daily_extend)
    line.set_x2(day_s2_line, bar_index + daily_extend)
    if show_equilibrium_box and not na(day_eq_box)
        box.set_right(day_eq_box, bar_index + daily_extend)

if not show_daily_pivots
    line.delete(day_pivot_line)
    line.delete(day_r1_line)
    line.delete(day_s1_line)
    line.delete(day_r2_line)
    line.delete(day_s2_line)
    box.delete(day_eq_box)
    label.delete(day_pivot_label)
    label.delete(day_r1_label)
    label.delete(day_s1_label)
    day_pivot_line := na
    day_r1_line := na
    day_s1_line := na
    day_r2_line := na
    day_s2_line := na
    day_eq_box := na
    day_pivot_label := na
    day_r1_label := na
    day_s1_label := na

//==============================================================================
// DRAW WEEKLY LATTICE
//==============================================================================
if show_weekly_pivots and (barstate.isfirst or new_week)
    line.delete(week_pivot_line)
    line.delete(week_r1_line)
    line.delete(week_s1_line)
    week_pivot_line := line.new(bar_index, week_pivot, bar_index + weekly_extend, week_pivot, color=weekly_col, width=2)
    week_r1_line := line.new(bar_index, week_r1, bar_index + weekly_extend, week_r1, color=color.new(weekly_col, 20), style=line.style_dashed)
    week_s1_line := line.new(bar_index, week_s1, bar_index + weekly_extend, week_s1, color=color.new(weekly_col, 20), style=line.style_dashed)

if show_weekly_pivots and not na(week_pivot_line)
    line.set_x2(week_pivot_line, bar_index + weekly_extend)
    line.set_x2(week_r1_line, bar_index + weekly_extend)
    line.set_x2(week_s1_line, bar_index + weekly_extend)

if not show_weekly_pivots
    line.delete(week_pivot_line)
    line.delete(week_r1_line)
    line.delete(week_s1_line)
    label.delete(week_pivot_label)
    week_pivot_line := na
    week_r1_line := na
    week_s1_line := na
    week_pivot_label := na

//==============================================================================
// LABEL THE ACTIVE LEVELS
//==============================================================================
if barstate.islast and show_daily_pivots and not na(day_pivot_line)
    label.delete(day_pivot_label)
    label.delete(day_r1_label)
    label.delete(day_s1_label)
    day_pivot_label := label.new(bar_index + 8, day_pivot, "D-PIVOT", style=label.style_label_left, color=color.new(pivot_col, 10), textcolor=text_main, size=size.tiny)
    day_r1_label := label.new(bar_index + 8, day_r1, "D-R1", style=label.style_label_left, color=color.new(res_col, 8), textcolor=text_main, size=size.tiny)
    day_s1_label := label.new(bar_index + 8, day_s1, "D-S1", style=label.style_label_left, color=color.new(sup_col, 8), textcolor=text_main, size=size.tiny)

if barstate.islast and show_weekly_pivots and not na(week_pivot_line)
    label.delete(week_pivot_label)
    week_pivot_label := label.new(bar_index + 14, week_pivot, "W-PIVOT", style=label.style_label_left, color=color.new(weekly_col, 12), textcolor=color.black, size=size.tiny)

//==============================================================================
// EMA WEAVE ENGINE
//==============================================================================
ema_12 = ta.ema(close, 12)
ema_21 = ta.ema(close, 21)
ema_34 = ta.ema(close, 34)
ema_55 = ta.ema(close, 55)
ema_89 = ta.ema(close, 89)
ema_144 = ta.ema(close, 144)

w_12 = math.max(math.abs(ema_12 - ema_12[weight_lookback]), syminfo.mintick)
w_21 = math.max(math.abs(ema_21 - ema_21[weight_lookback]), syminfo.mintick)
w_34 = math.max(math.abs(ema_34 - ema_34[weight_lookback]), syminfo.mintick)
w_55 = math.max(math.abs(ema_55 - ema_55[weight_lookback]), syminfo.mintick)
w_89 = math.max(math.abs(ema_89 - ema_89[weight_lookback]), syminfo.mintick)
w_144 = math.max(math.abs(ema_144 - ema_144[weight_lookback]), syminfo.mintick)

weight_sum = w_12 + w_21 + w_34 + w_55 + w_89 + w_144
raw_center = (ema_12 * w_12 + ema_21 * w_21 + ema_34 * w_34 + ema_55 * w_55 + ema_89 * w_89 + ema_144 * w_144) / weight_sum
weave_center = ta.ema(raw_center, ribbon_smooth)
weave_upper = math.max(math.max(math.max(ema_12, ema_21), math.max(ema_34, ema_55)), math.max(ema_89, ema_144))
weave_lower = math.min(math.min(math.min(ema_12, ema_21), math.min(ema_34, ema_55)), math.min(ema_89, ema_144))

center_slope = weave_center - weave_center[3]
weave_bias = close > weave_center and center_slope > 0 ? 1 : close < weave_center and center_slope < 0 ? -1 : 0
weave_color = weave_bias == 1 ? ribbon_bull : weave_bias == -1 ? ribbon_bear : ribbon_neutral

p_weave_upper = plot(show_ribbon ? weave_upper : na, "Weave Upper", color=color.new(weave_color, 70), linewidth=1)
p_weave_lower = plot(show_ribbon ? weave_lower : na, "Weave Lower", color=color.new(weave_color, 70), linewidth=1)
fill(p_weave_upper, p_weave_lower, color.new(weave_color, 88), title="Weave Fill")
plot(show_centerline ? weave_center : na, "Weave Center", color=weave_color, linewidth=2)

//==============================================================================
// OPENING RANGE
//==============================================================================
in_opening_range = not na(time(timeframe.period, opening_session))
opening_range_start = in_opening_range and not in_opening_range[1]
opening_range_end = not in_opening_range and in_opening_range[1]

var float opening_high = na
var float opening_low = na
var box opening_box = na
var line opening_mid = na

if opening_range_start
    opening_high := high
    opening_low := low
    box.delete(opening_box)
    line.delete(opening_mid)
    if show_opening_range
        opening_box := box.new(bar_index, high, bar_index, low, bgcolor=color.new(weekly_col, 92), border_color=color.new(weekly_col, 55))

if in_opening_range
    opening_high := na(opening_high) ? high : math.max(opening_high, high)
    opening_low := na(opening_low) ? low : math.min(opening_low, low)
    if show_opening_range and not na(opening_box)
        box.set_top(opening_box, opening_high)
        box.set_bottom(opening_box, opening_low)
        box.set_right(opening_box, bar_index)

if opening_range_end and show_opening_range and not na(opening_box)
    box.set_right(opening_box, bar_index + opening_extend)
    float opening_midpoint = (opening_high + opening_low) * 0.5
    opening_mid := line.new(bar_index, opening_midpoint, bar_index + opening_extend, opening_midpoint, color=color.new(weekly_col, 25), style=line.style_dotted)

if not in_opening_range and show_opening_range and not na(opening_box)
    box.set_right(opening_box, bar_index + opening_extend)
    if not na(opening_mid)
        line.set_x2(opening_mid, bar_index + opening_extend)

//==============================================================================
// BAR STATE AND BACKGROUND
//==============================================================================
day_bias = close > day_pivot ? 1 : -1
context_bias = weave_bias == day_bias ? weave_bias : 0
bar_color = context_bias == 1 ? color.new(ribbon_bull, 28) : context_bias == -1 ? color.new(ribbon_bear, 28) : color.new(ribbon_neutral, 40)
barcolor(show_bar_state ? bar_color : na)
bgcolor(show_background ? (context_bias == 1 ? color.new(ribbon_bull, 95) : context_bias == -1 ? color.new(ribbon_bear, 95) : na) : na)

//==============================================================================
// DASHBOARD
//==============================================================================
var table dash = table.new(position.top_right, 2, 7, bgcolor=panel_bg, border_width=1, border_color=panel_grid, frame_color=panel_grid, frame_width=1)

f_dash_row(_row, _label, _value, _color, _bg) =>
    table.cell(dash, 0, _row, _label, text_color=text_dim, bgcolor=_bg, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, _row, _value, text_color=_color, bgcolor=_bg, text_size=size.small, text_halign=text.align_right)

if show_dashboard and barstate.islast
    string weave_state = weave_bias == 1 ? "Upstream" : weave_bias == -1 ? "Downstream" : "Balanced"
    string day_state = close > day_eq_hi ? "Premium" : close < day_eq_lo ? "Discount" : "Equilibrium"
    string opening_state = not na(opening_high) and not na(opening_low) ? str.tostring(opening_high - opening_low, format.mintick) : "n/a"
    table.cell(dash, 0, 0, "ASTERION LEVELS", text_color=text_main, bgcolor=panel_header, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 0, weave_state, text_color=weave_color, bgcolor=panel_header, text_size=size.small, text_halign=text.align_right)
    f_dash_row(1, "Daily Pivot", str.tostring(day_pivot, format.mintick), pivot_col, panel_cell)
    f_dash_row(2, "Weekly Pivot", str.tostring(week_pivot, format.mintick), weekly_col, panel_bg)
    f_dash_row(3, "Location", day_state, day_state == "Premium" ? res_col : day_state == "Discount" ? sup_col : accent_gold, panel_cell)
    f_dash_row(4, "Center Slope", str.tostring(center_slope, format.mintick), center_slope >= 0 ? ribbon_bull : ribbon_bear, panel_bg)
    f_dash_row(5, "Opening Range", opening_state, weekly_col, panel_cell)
    f_dash_row(6, "Bias Sync", context_bias == 1 ? "Bullish" : context_bias == -1 ? "Bearish" : "Mixed", context_bias == 1 ? ribbon_bull : context_bias == -1 ? ribbon_bear : accent_gold, panel_bg)

//==============================================================================
// ALERTS
//==============================================================================
alertcondition(barstate.isconfirmed and ta.crossover(close, day_pivot), "Cross Above Daily Pivot", "Asterion Level Weave [JOAT] detected a confirmed cross above the daily pivot on {{ticker}} {{interval}}.")
alertcondition(barstate.isconfirmed and ta.crossunder(close, day_pivot), "Cross Below Daily Pivot", "Asterion Level Weave [JOAT] detected a confirmed cross below the daily pivot on {{ticker}} {{interval}}.")
alertcondition(barstate.isconfirmed and context_bias == 1 and context_bias[1] != 1, "Bias Sync Bullish", "Asterion Level Weave [JOAT] aligned bullish context on {{ticker}} {{interval}}.")
alertcondition(barstate.isconfirmed and context_bias == -1 and context_bias[1] != -1, "Bias Sync Bearish", "Asterion Level Weave [JOAT] aligned bearish context on {{ticker}} {{interval}}.")
````
