# Signal Engine [Backtest]

- url: https://www.tradingview.com/script/yewrshAO-Signal-Engine-Backtest/
- type: indicator
- pine_id: PUB;61802c9c39b6400d8a32517885867433
- version: 1.0

## Description

This indicator will work as a strategy tester for any open sourced tradingveiw indicator that produces signals, added a few filters and will build it out more going forward.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Traderbradg

//@version=5
indicator("Signal Engine [Backtest]", overlay=true, max_labels_count=500, max_lines_count=500)

// ═══════════════════════════════════════════════════════════
// SECTION 1 — SIGNAL INPUT
// ═══════════════════════════════════════════════════════════

var g_sig = "── Custom Indicator Signal ──"

src_long  = input.source(close, "Long Signal Source",  group=g_sig, tooltip="Point this at any plot from another indicator on your chart.")
src_short = input.source(close, "Short Signal Source", group=g_sig, tooltip="Can be the same source as Long, or a different one.")

long_mode  = input.string("CrossOver B",   "Long Trigger Mode",  options=["CrossOver B", "CrossUnder B", "Above Level", "Below Level", "Non-Zero Event"], group=g_sig)
short_mode = input.string("CrossUnder B",  "Short Trigger Mode", options=["CrossOver B", "CrossUnder B", "Above Level", "Below Level", "Non-Zero Event"], group=g_sig)

src_long_b  = input.source(close, "Long Source B (crossover modes)", group=g_sig)
src_short_b = input.source(close, "Short Source B (crossover modes)", group=g_sig)

long_level  = input.float(0.0, "Long Level (level modes)",  group=g_sig)
short_level = input.float(0.0, "Short Level (level modes)", group=g_sig)

enable_long  = input.bool(true,  "Enable Long Signals",  group=g_sig)
enable_short = input.bool(true,  "Enable Short Signals", group=g_sig)

// ═══════════════════════════════════════════════════════════
// SECTION 2 — BASELINE FILTER (optional)
// ═══════════════════════════════════════════════════════════

var g_base = "── Baseline Filter ──"
use_baseline   = input.bool(false, "Enable Baseline Filter", group=g_base, tooltip="Only take longs above baseline, shorts below.")
baseline_type  = input.string("EMA", "Type", options=["EMA","SMA","HMA","WMA"], group=g_base)
baseline_len   = input.int(200, "Length", group=g_base)
baseline_src   = input.source(close, "Source", group=g_base)

// ═══════════════════════════════════════════════════════════
// SECTION 3 — RISK MANAGEMENT
// ═══════════════════════════════════════════════════════════

var g_risk = "── Risk Management ──"
use_atr_sl = input.bool(true,  "Use ATR-Based SL/TP", group=g_risk)
atr_len    = input.int(14,     "ATR Length",           group=g_risk)
sl_atr     = input.float(1.5,  "SL — ATR Multiple",   group=g_risk, step=0.1)
tp1_atr    = input.float(2.0,  "TP1 — ATR Multiple",  group=g_risk, step=0.1)
tp2_atr    = input.float(3.5,  "TP2 — ATR Multiple",  group=g_risk, step=0.1)
sl_fixed   = input.float(50.0, "SL — Fixed Points (if not ATR)", group=g_risk)
tp1_fixed  = input.float(50.0, "TP1 — Fixed Points",  group=g_risk)
tp2_fixed  = input.float(100.0,"TP2 — Fixed Points",  group=g_risk)
use_tp2    = input.bool(true,  "Use Second Take Profit", group=g_risk)

// ═══════════════════════════════════════════════════════════
// SECTION 4 — DATE FILTER
// ═══════════════════════════════════════════════════════════

var g_date = "── Date Range ──"
use_date   = input.bool(false, "Filter by Date Range", group=g_date)
start_date = input.time(timestamp("2020-01-01"), "Start Date", group=g_date)
end_date   = input.time(timestamp("2030-12-31"), "End Date",   group=g_date)

// ═══════════════════════════════════════════════════════════
// SECTION 5 — ADX FILTER
// ═══════════════════════════════════════════════════════════

var g_adx = "── ADX Trend Filter ──"
use_adx     = input.bool(false, "Enable ADX Filter",    group=g_adx, tooltip="Only take signals when the market is trending. Skips choppy, sideways conditions.")
adx_len     = input.int(14,     "ADX Length",           group=g_adx)
adx_smooth  = input.int(14,     "ADX Smoothing",        group=g_adx)
adx_min     = input.float(20.0, "Min ADX (trend threshold)", group=g_adx, step=1.0, tooltip="20-25 = moderate trend required. 30+ = strong trend only.")

// ═══════════════════════════════════════════════════════════
// SECTION 6 — VOLATILITY FILTER
// ═══════════════════════════════════════════════════════════

var g_vol = "── Volatility Filter ──"
use_vol     = input.bool(false, "Enable Volatility Filter", group=g_vol, tooltip="Skips signals when the market is too quiet or too explosive.")
vol_atr_len = input.int(14,     "ATR Length (Volatility)",  group=g_vol)
vol_ma_len  = input.int(50,     "ATR MA Length",            group=g_vol, tooltip="ATR is compared against its own moving average to judge relative volatility.")
vol_min_pct = input.float(70.0, "Min Volatility (% of ATR MA)",  group=g_vol, step=5.0, tooltip="Below this = too quiet. E.g. 70 means ATR must be at least 70% of its average.")
vol_max_pct = input.float(200.0,"Max Volatility (% of ATR MA)", group=g_vol, step=5.0, tooltip="Above this = too explosive/news spike. E.g. 200 means ATR can't be more than 2x its average.")

// ═══════════════════════════════════════════════════════════
// SECTION 7 — SUPPORT & RESISTANCE FILTER
// ═══════════════════════════════════════════════════════════

var g_sr = "── Support & Resistance Filter ──"
use_sr        = input.bool(false, "Enable S/R Filter",          group=g_sr, tooltip="Skips signals that trigger too close to key daily or weekly S/R levels.")
use_daily_sr  = input.bool(true,  "Use Previous Day High/Low",  group=g_sr)
use_weekly_sr = input.bool(true,  "Use Previous Week High/Low", group=g_sr)
sr_buffer_atr = input.float(0.5,  "Buffer Distance (ATR Multiple)", group=g_sr, step=0.1, tooltip="If entry is within this many ATRs of a key level, the signal is skipped. 0.5 = half an ATR buffer around each level.")
show_sr_lines = input.bool(true,  "Show S/R Levels on Chart",   group=g_sr)

// ═══════════════════════════════════════════════════════════
// SECTION 8 — DISPLAY
// ═══════════════════════════════════════════════════════════

var g_disp = "── Display ──"
show_sl_tp      = input.bool(true,  "Show SL/TP Lines on Chart", group=g_disp)
show_signals    = input.bool(true,  "Show Entry Arrows",         group=g_disp)
table_pos       = input.string("Top Right", "Stats Table Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=g_disp)

// ═══════════════════════════════════════════════════════════
// CALCULATIONS
// ═══════════════════════════════════════════════════════════

// Baseline
baseline = switch baseline_type
    "EMA"  => ta.ema(baseline_src, baseline_len)
    "SMA"  => ta.sma(baseline_src, baseline_len)
    "HMA"  => ta.hma(baseline_src, baseline_len)
    "WMA"  => ta.wma(baseline_src, baseline_len)
    => ta.ema(baseline_src, baseline_len)

baseline_ok_long  = not use_baseline or close > baseline
baseline_ok_short = not use_baseline or close < baseline

// Date filter
in_date = not use_date or (time >= start_date and time <= end_date)

// ATR
atr_val = ta.atr(atr_len)

// ── ADX Calculation ──
[diplus, diminus, adx_val] = ta.dmi(adx_len, adx_smooth)
adx_ok = not use_adx or adx_val >= adx_min

// ── Volatility Calculation ──
vol_atr     = ta.atr(vol_atr_len)
vol_atr_ma  = ta.sma(vol_atr, vol_ma_len)
vol_ratio   = vol_atr_ma > 0 ? (vol_atr / vol_atr_ma) * 100 : 100.0
vol_ok      = not use_vol or (vol_ratio >= vol_min_pct and vol_ratio <= vol_max_pct)

// ── S/R Levels — Previous Day & Week High/Low ──
prev_day_high  = request.security(syminfo.tickerid, "D", high[1],  lookahead=barmerge.lookahead_on)
prev_day_low   = request.security(syminfo.tickerid, "D", low[1],   lookahead=barmerge.lookahead_on)
prev_week_high = request.security(syminfo.tickerid, "W", high[1],  lookahead=barmerge.lookahead_on)
prev_week_low  = request.security(syminfo.tickerid, "W", low[1],   lookahead=barmerge.lookahead_on)

sr_buffer = atr_val * sr_buffer_atr

f_near_level(price, level) =>
    math.abs(price - level) <= sr_buffer

// Check if entry price is too close to any active S/R level
f_sr_clear(price) =>
    near_dh = use_daily_sr  and f_near_level(price, prev_day_high)
    near_dl = use_daily_sr  and f_near_level(price, prev_day_low)
    near_wh = use_weekly_sr and f_near_level(price, prev_week_high)
    near_wl = use_weekly_sr and f_near_level(price, prev_week_low)
    not (near_dh or near_dl or near_wh or near_wl)

sr_ok_long  = not use_sr or f_sr_clear(close)
sr_ok_short = not use_sr or f_sr_clear(close)

// Plot S/R lines
var line pdh_line = na
var line pdl_line = na
var line pwh_line = na
var line pwl_line = na

if show_sr_lines and use_sr
    if use_daily_sr
        if na(pdh_line) or line.get_y1(pdh_line) != prev_day_high
            pdh_line := line.new(bar_index, prev_day_high, bar_index+1, prev_day_high, color=color.new(color.orange, 30), width=1, style=line.style_dashed, extend=extend.right)
        if na(pdl_line) or line.get_y1(pdl_line) != prev_day_low
            pdl_line := line.new(bar_index, prev_day_low,  bar_index+1, prev_day_low,  color=color.new(color.orange, 30), width=1, style=line.style_dashed, extend=extend.right)
    if use_weekly_sr
        if na(pwh_line) or line.get_y1(pwh_line) != prev_week_high
            pwh_line := line.new(bar_index, prev_week_high, bar_index+1, prev_week_high, color=color.new(color.purple, 30), width=1, style=line.style_dotted, extend=extend.right)
        if na(pwl_line) or line.get_y1(pwl_line) != prev_week_low
            pwl_line := line.new(bar_index, prev_week_low,  bar_index+1, prev_week_low,  color=color.new(color.purple, 30), width=1, style=line.style_dotted, extend=extend.right)

// Signal trigger logic
f_long_trigger() =>
    switch long_mode
        "CrossOver B"    => ta.crossover(src_long, src_long_b)
        "CrossUnder B"   => ta.crossunder(src_long, src_long_b)
        "Above Level"    => src_long > long_level and src_long[1] <= long_level
        "Below Level"    => src_long < long_level and src_long[1] >= long_level
        "Non-Zero Event" => src_long != 0 and src_long[1] == 0
        => false

f_short_trigger() =>
    switch short_mode
        "CrossOver B"    => ta.crossover(src_short, src_short_b)
        "CrossUnder B"   => ta.crossunder(src_short, src_short_b)
        "Above Level"    => src_short > short_level and src_short[1] <= short_level
        "Below Level"    => src_short < short_level and src_short[1] >= short_level
        "Non-Zero Event" => src_short != 0 and src_short[1] == 0
        => false

raw_long  = enable_long  and f_long_trigger()  and baseline_ok_long  and in_date and adx_ok and vol_ok and sr_ok_long
raw_short = enable_short and f_short_trigger() and baseline_ok_short and in_date and adx_ok and vol_ok and sr_ok_short

// ═══════════════════════════════════════════════════════════
// TRADE SIMULATION
// ═══════════════════════════════════════════════════════════

var bool  in_trade    = false
var bool  is_long     = false
var float entry_price = na
var float sl_price    = na
var float tp1_price   = na
var float tp2_price   = na
var line  sl_line     = na
var line  tp1_line    = na
var line  tp2_line    = na

// Stats trackers
var int   total_trades  = 0
var int   wins          = 0
var int   losses        = 0
var float gross_profit  = 0.0
var float gross_loss    = 0.0
var int   open_trades   = 0  // currently unused but useful for extensions
var float total_r       = 0.0  // sum of R multiples

// Determine SL/TP distances
sl_dist  = use_atr_sl ? atr_val * sl_atr  : sl_fixed  * syminfo.mintick
tp1_dist = use_atr_sl ? atr_val * tp1_atr : tp1_fixed * syminfo.mintick
tp2_dist = use_atr_sl ? atr_val * tp2_atr : tp2_fixed * syminfo.mintick

// Enter trade
enter_long  = raw_long  and not in_trade
enter_short = raw_short and not in_trade

if enter_long
    in_trade    := true
    is_long     := true
    entry_price := close
    sl_price    := close - sl_dist
    tp1_price   := close + tp1_dist
    tp2_price   := close + tp2_dist
    total_trades += 1
    if show_signals
        label.new(bar_index, low, "▲", color=color.new(color.green,0), textcolor=color.white, style=label.style_label_up, size=size.small)

if enter_short
    in_trade    := true
    is_long     := false
    entry_price := close
    sl_price    := close + sl_dist
    tp1_price   := close - tp1_dist
    tp2_price   := close - tp2_dist
    total_trades += 1
    if show_signals
        label.new(bar_index, high, "▼", color=color.new(color.red,0), textcolor=color.white, style=label.style_label_down, size=size.small)

// Draw SL/TP lines on entry
if (enter_long or enter_short) and show_sl_tp
    sl_line  := line.new(bar_index, sl_price,  bar_index+1, sl_price,  color=color.red,                width=1, style=line.style_dashed)
    tp1_line := line.new(bar_index, tp1_price, bar_index+1, tp1_price, color=color.green,              width=1, style=line.style_dashed)
    if use_tp2
        tp2_line := line.new(bar_index, tp2_price, bar_index+1, tp2_price, color=color.new(color.green,40), width=1, style=line.style_dotted)

// Extend lines while in trade
if in_trade and show_sl_tp and not na(sl_line)
    line.set_x2(sl_line,  bar_index+1)
    line.set_x2(tp1_line, bar_index+1)
    if use_tp2 and not na(tp2_line)
        line.set_x2(tp2_line, bar_index+1)

// Exit logic — check SL and TP hits
exit_reason = ""

if in_trade
    hit_sl  = is_long ? low  <= sl_price  : high >= sl_price
    hit_tp1 = is_long ? high >= tp1_price : low  <= tp1_price
    hit_tp2 = use_tp2 and (is_long ? high >= tp2_price : low <= tp2_price)

    r_size = math.abs(entry_price - sl_price)

    if hit_sl and not hit_tp1
        // Full stop loss
        pnl = is_long ? (sl_price - entry_price) : (entry_price - sl_price)
        gross_loss  += math.abs(pnl)
        total_r     += -1.0
        losses      += 1
        in_trade    := false
        exit_reason := "SL"
        if show_signals
            label.new(bar_index, is_long ? low : high, "✕", color=color.new(color.red,30), textcolor=color.white, style=is_long ? label.style_label_up : label.style_label_down, size=size.tiny)

    else if hit_tp2
        // Full TP2 hit — best case
        pnl = is_long ? (tp2_price - entry_price) : (entry_price - tp2_price)
        gross_profit += pnl
        total_r      += tp2_atr / sl_atr
        wins         += 1
        in_trade     := false
        exit_reason  := "TP2"
        if show_signals
            label.new(bar_index, is_long ? high : low, "✓", color=color.new(color.lime,20), textcolor=color.black, style=is_long ? label.style_label_down : label.style_label_up, size=size.tiny)

    else if hit_tp1
        // TP1 hit only
        pnl = is_long ? (tp1_price - entry_price) : (entry_price - tp1_price)
        gross_profit += pnl
        total_r      += tp1_atr / sl_atr
        wins         += 1
        in_trade     := false
        exit_reason  := "TP1"
        if show_signals
            label.new(bar_index, is_long ? high : low, "✓", color=color.new(color.green,20), textcolor=color.white, style=is_long ? label.style_label_down : label.style_label_up, size=size.tiny)

// ═══════════════════════════════════════════════════════════
// STATS TABLE
// ═══════════════════════════════════════════════════════════

t_pos = switch table_pos
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right

var table stats = table.new(t_pos, 2, 11, bgcolor=color.new(color.black, 20), border_color=color.new(color.gray,60), border_width=1, frame_color=color.new(color.gray,40), frame_width=1)

win_rate      = total_trades > 0 ? (wins / total_trades) * 100 : 0.0
profit_factor = gross_loss > 0   ? gross_profit / gross_loss   : gross_profit > 0 ? 999.0 : 0.0
avg_r         = total_trades > 0 ? total_r / total_trades      : 0.0
completed     = wins + losses

f_cell(col, row, txt, txt_color) =>
    table.cell(stats, col, row, txt, text_color=txt_color, text_size=size.small, bgcolor=color.new(color.black,30))

f_label(row, txt) =>
    table.cell(stats, 0, row, txt, text_color=color.new(color.gray,20), text_size=size.small, bgcolor=color.new(color.black,50))

if barstate.islast
    // Header
    table.cell(stats, 0, 0, "SIGNAL ENGINE", text_color=color.white, text_size=size.normal, bgcolor=color.new(color.blue,60), text_halign=text.align_center)
    table.cell(stats, 1, 0, "BACKTEST",       text_color=color.white, text_size=size.normal, bgcolor=color.new(color.blue,60), text_halign=text.align_center)

    f_label(1, "Total Trades")
    f_cell(1, 1, str.tostring(total_trades), color.white)

    f_label(2, "Wins / Losses")
    f_cell(1, 2, str.tostring(wins) + " / " + str.tostring(losses), wins > losses ? color.green : color.red)

    f_label(3, "Win Rate")
    wr_color = win_rate >= 55 ? color.green : win_rate >= 45 ? color.yellow : color.red
    f_cell(1, 3, str.tostring(math.round(win_rate, 1)) + "%", wr_color)

    f_label(4, "Profit Factor")
    pf_color = profit_factor >= 1.5 ? color.green : profit_factor >= 1.0 ? color.yellow : color.red
    f_cell(1, 4, str.tostring(math.round(profit_factor, 2)), pf_color)

    f_label(5, "Avg R Per Trade")
    r_color = avg_r >= 1.0 ? color.green : avg_r >= 0 ? color.yellow : color.red
    f_cell(1, 5, str.tostring(math.round(avg_r, 2)) + "R", r_color)

    f_label(6, "In Trade")
    f_cell(1, 6, in_trade ? (is_long ? "LONG 🟢" : "SHORT 🔴") : "—", in_trade ? color.yellow : color.gray)

    f_label(7, "Baseline Filter")
    f_cell(1, 7, use_baseline ? baseline_type + " " + str.tostring(baseline_len) : "Off", use_baseline ? color.aqua : color.gray)

    f_label(8, "ADX Filter")
    adx_status = use_adx ? (adx_ok ? "✓ " + str.tostring(math.round(adx_val, 1)) : "✕ " + str.tostring(math.round(adx_val, 1))) : "Off"
    f_cell(1, 8, adx_status, not use_adx ? color.gray : adx_ok ? color.green : color.red)

    f_label(9, "Volatility Filter")
    vol_status = use_vol ? (vol_ok ? "✓ " + str.tostring(math.round(vol_ratio, 0)) + "%" : "✕ " + str.tostring(math.round(vol_ratio, 0)) + "%") : "Off"
    f_cell(1, 9, vol_status, not use_vol ? color.gray : vol_ok ? color.green : color.red)

    f_label(10, "S/R Filter")
    sr_live = f_sr_clear(close)
    sr_status = use_sr ? (sr_live ? "✓ Clear" : "✕ Too Close") : "Off"
    f_cell(1, 10, sr_status, not use_sr ? color.gray : sr_live ? color.green : color.red)

// ═══════════════════════════════════════════════════════════
// BASELINE PLOT
// ═══════════════════════════════════════════════════════════

plot(use_baseline ? baseline : na, "Baseline", color=color.new(color.yellow, 40), linewidth=1)

// S/R level plots (as horizontal lines via plot on security data)
plot(show_sr_lines and use_sr and use_daily_sr  ? prev_day_high  : na, "Prev Day High",  color=color.new(color.orange, 30), linewidth=1, style=plot.style_linebr)
plot(show_sr_lines and use_sr and use_daily_sr  ? prev_day_low   : na, "Prev Day Low",   color=color.new(color.orange, 30), linewidth=1, style=plot.style_linebr)
plot(show_sr_lines and use_sr and use_weekly_sr ? prev_week_high : na, "Prev Week High", color=color.new(color.purple, 40), linewidth=1, style=plot.style_linebr)
plot(show_sr_lines and use_sr and use_weekly_sr ? prev_week_low  : na, "Prev Week Low",  color=color.new(color.purple, 40), linewidth=1, style=plot.style_linebr)

// Background tint when any filter is blocking signals
filter_blocked = (use_adx and not adx_ok) or (use_vol and not vol_ok) or (use_sr and not f_sr_clear(close))
bgcolor(filter_blocked ? color.new(color.gray, 92) : na, title="Filter Active")
````
