# Key Swing Levels

- url: https://www.tradingview.com/script/xv6F9wPg-Key-Swing-Levels/
- type: indicator
- pine_id: PUB;da8646fb2c4f4bf29427462a6f632fdd
- version: 1.0

## Description

Key Swing Levels (KSL) plots higher-timeframe reference levels — Weekly High/Low, Monthly High/Low, Previous Day High/Low, Weekly & Monthly Open, and configurable round numbers — on any chart, any timeframe.

A proximity dashboard in the top-right corner shows real-time distance in pips to each level, with cells highlighting red when price comes within range.
Features:

Auto-detects pip size for JPY pairs, other forex, metals, indices, and crypto — no manual configuration
Current week & month levels (solid) and previous week & month levels (dashed) for AMD / SMC analysis
Round number plotting with optional 50-pip half levels
Configurable label offset so levels don't cover forming candles
Built-in alerts when price approaches any major level

How to use:

Use it as a daily/weekly bias map. Levels mark areas where price is likely to react — sweeps, rejections, or breaks. Particularly useful for session-based traders watching for liquidity grabs at PDH/PDL or weekly extremes during London/NY opens.

Open-source. Feedback and forks welcome.

## Source Code

````pine
//@version=5
// =============================================================================
// Key Swing Levels (KSL) — v2.0
// -----------------------------------------------------------------------------
// Plots higher-timeframe swing levels (Weekly, Monthly, Daily) plus configurable
// round numbers, with a proximity dashboard showing distance in pips to each
// level. Auto-detects pip size for JPY pairs, other forex pairs, and non-forex
// instruments — works correctly on EURUSD, USDJPY, GBPJPY, XAUUSD, indices,
// and crypto without any manual configuration.
//
// Author: [your handle]
// Version: 2.0
// =============================================================================

indicator("Key Swing Levels", shorttitle="KSL", overlay=true, max_lines_count=500, max_labels_count=500)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
g_weekly  = "Weekly Levels"
g_monthly = "Monthly Levels"
g_daily   = "Daily Levels"
g_round   = "Round Numbers"
g_display = "Display"

// Weekly
show_weekly      = input.bool(true,  "Show Current Week High/Low",  group=g_weekly)
show_weekly_open = input.bool(true,  "Show Current Week Open",      group=g_weekly)
show_prev_week   = input.bool(true,  "Show Previous Week High/Low", group=g_weekly)
col_w_high       = input.color(color.new(#00C853, 0),  "Week High",  group=g_weekly, inline="w1")
col_w_low        = input.color(color.new(#FF1744, 0),  "Week Low",   group=g_weekly, inline="w1")
col_pw_high      = input.color(color.new(#69F0AE, 30), "PW High",    group=g_weekly, inline="w2")
col_pw_low       = input.color(color.new(#FF8A80, 30), "PW Low",     group=g_weekly, inline="w2")

// Monthly
show_monthly      = input.bool(true,  "Show Current Month High/Low",  group=g_monthly)
show_monthly_open = input.bool(true,  "Show Current Month Open",      group=g_monthly)
show_prev_month   = input.bool(true,  "Show Previous Month High/Low", group=g_monthly)
col_m_high        = input.color(color.new(#AA00FF, 0),  "Month High", group=g_monthly, inline="m1")
col_m_low         = input.color(color.new(#FF6D00, 0),  "Month Low",  group=g_monthly, inline="m1")
col_pm_high       = input.color(color.new(#CE93D8, 30), "PM High",    group=g_monthly, inline="m2")
col_pm_low        = input.color(color.new(#FFCC80, 30), "PM Low",     group=g_monthly, inline="m2")

// Daily
show_daily = input.bool(true, "Show Previous Day High/Low", group=g_daily)
col_d_high = input.color(color.new(#40C4FF, 0), "PD High", group=g_daily, inline="d1")
col_d_low  = input.color(color.new(#F48FB1, 0), "PD Low",  group=g_daily, inline="d1")

// Round Numbers
show_round  = input.bool(true,  "Show Round Numbers",                   group=g_round)
show_half   = input.bool(true,  "Include 50-pip Half Levels",           group=g_round)
round_range = input.int(50,     "Range Around Price (pips each side)",  group=g_round, minval=10, maxval=300)
col_round   = input.color(color.new(#FFD740, 40), "Round Number Color", group=g_round)

// Display
line_width        = input.int(1,   "Line Width",                  group=g_display, minval=1, maxval=4)
line_lookback     = input.int(300, "Line Length (bars back)",     group=g_display, minval=50, maxval=1000)
extend_lines      = input.bool(true, "Extend Lines Right",        group=g_display)
show_labels       = input.bool(true, "Show Level Labels",         group=g_display)
label_offset_bars = input.int(8,   "Label Offset (bars right)",   group=g_display, minval=0, maxval=50, tooltip="Pushes labels right of current price so they don't cover forming candles. Increase if labels overlap your chart, decrease if they sit too far away.")
label_size_in     = input.string("small", "Label Size",           group=g_display, options=["tiny","small","normal"])
proximity_alert   = input.int(5,   "Proximity Threshold (pips)",  group=g_display, minval=1, maxval=50, tooltip="Dashboard cell turns red when price is within this many pips of a level. Also controls alert distance.")

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────

// Auto-detect pip size for any instrument
get_pip_size() =>
    is_jpy = str.contains(syminfo.ticker, "JPY")
    if syminfo.type == "forex"
        is_jpy ? 0.01 : 0.0001
    else
        syminfo.mintick * 10

pip_size = get_pip_size()

f_label_size() =>
    label_size_in == "tiny" ? size.tiny : label_size_in == "normal" ? size.normal : size.small

f_extend() =>
    extend_lines ? extend.right : extend.none

// Distance to level in pips (rounded to 1 decimal)
f_dist(lvl) =>
    math.round(math.abs(close - lvl) / pip_size, 1)

// Dashboard cell color: red if close to level
f_prox_color(lvl) =>
    f_dist(lvl) <= proximity_alert ? color.new(#C00000, 0) : color.new(#1a1a2e, 80)

// Format price using symbol's native precision
f_price_str(p) =>
    str.tostring(p, format.mintick)

// DRY drawing helper — one line + one label per call
draw_level(price, line_color, lbl_text, line_style, lbl_color) =>
    line.new(bar_index - line_lookback, price, bar_index, price, color=line_color, width=line_width, style=line_style, extend=f_extend())
    if show_labels
        label.new(bar_index + label_offset_bars, price, lbl_text + " " + f_price_str(price), color=lbl_color, textcolor=color.white, style=label.style_label_left, size=f_label_size(), xloc=xloc.bar_index, yloc=yloc.price)

// ─────────────────────────────────────────────
// HTF DATA (consolidated tuple calls)
// ─────────────────────────────────────────────

[w_high, w_low, w_open] = request.security(syminfo.tickerid, "W", [high, low, open], lookahead=barmerge.lookahead_off)
[pw_high, pw_low]       = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead=barmerge.lookahead_on)

[m_high, m_low, m_open] = request.security(syminfo.tickerid, "M", [high, low, open], lookahead=barmerge.lookahead_off)
[pm_high, pm_low]       = request.security(syminfo.tickerid, "M", [high[1], low[1]], lookahead=barmerge.lookahead_on)

[pd_high, pd_low]       = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead=barmerge.lookahead_on)

// ─────────────────────────────────────────────
// DRAW LEVELS (only on last bar to avoid line spam)
// ─────────────────────────────────────────────

if barstate.islast
    if show_weekly
        draw_level(w_high, col_w_high, "W.High", line.style_solid, col_w_high)
        draw_level(w_low,  col_w_low,  "W.Low",  line.style_solid, col_w_low)

    if show_weekly_open
        draw_level(w_open, color.new(color.white, 60), "W.Open", line.style_dashed, color.new(#333333, 20))

    if show_prev_week
        draw_level(pw_high, col_pw_high, "PW.High", line.style_dashed, col_pw_high)
        draw_level(pw_low,  col_pw_low,  "PW.Low",  line.style_dashed, col_pw_low)

    if show_monthly
        draw_level(m_high, col_m_high, "M.High", line.style_solid, col_m_high)
        draw_level(m_low,  col_m_low,  "M.Low",  line.style_solid, col_m_low)

    if show_monthly_open
        draw_level(m_open, color.new(color.white, 70), "M.Open", line.style_dotted, color.new(#333333, 20))

    if show_prev_month
        draw_level(pm_high, col_pm_high, "PM.High", line.style_dashed, col_pm_high)
        draw_level(pm_low,  col_pm_low,  "PM.Low",  line.style_dashed, col_pm_low)

    if show_daily
        draw_level(pd_high, col_d_high, "PDH", line.style_solid, col_d_high)
        draw_level(pd_low,  col_d_low,  "PDL", line.style_solid, col_d_low)

    // ─────────────────────────────────────────
    // ROUND NUMBERS — auto-scales by pip_size
    // ─────────────────────────────────────────
    if show_round
        range_dist = round_range * pip_size
        price_step = show_half ? pip_size * 50 : pip_size * 100
        big_step   = pip_size * 100
        base       = math.floor(close / price_step) * price_step
        levels_n   = math.ceil(range_dist / price_step)

        for i = -levels_n to levels_n
            lvl  = base + i * price_step
            dist = math.abs(close - lvl)
            if dist <= range_dist and dist > pip_size * 2
                is_big_round = math.abs(lvl - math.round(lvl / big_step) * big_step) < pip_size * 0.5
                lw       = is_big_round ? line_width + 1 : line_width
                ls_round = is_big_round ? line.style_solid : line.style_dotted
                line.new(bar_index - line_lookback, lvl, bar_index, lvl, color=col_round, width=lw, style=ls_round, extend=f_extend())
                if show_labels and is_big_round
                    label.new(bar_index + label_offset_bars, lvl, " " + f_price_str(lvl), color=color.new(#FFD740, 20), textcolor=color.new(#FFD740, 0), style=label.style_label_left, size=size.tiny, xloc=xloc.bar_index, yloc=yloc.price)

// ─────────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────────

var table proximity = table.new(position.top_right, 2, 8, border_width=1, border_color=color.new(color.gray, 60), frame_width=2, frame_color=color.new(#1F4E79, 0))

if barstate.islast
    c_hdr = color.new(#1F4E79, 0)
    c_txt = color.white

    table.cell(proximity, 0, 0, "LEVEL",     text_color=c_txt, bgcolor=c_hdr, text_size=size.small)
    table.cell(proximity, 1, 0, "PIPS AWAY", text_color=c_txt, bgcolor=c_hdr, text_size=size.small)

    table.cell(proximity, 0, 1, "W.High", text_color=c_txt, bgcolor=f_prox_color(w_high), text_size=size.small)
    table.cell(proximity, 1, 1, str.tostring(f_dist(w_high)) + "p", text_color=c_txt, bgcolor=f_prox_color(w_high), text_size=size.small)

    table.cell(proximity, 0, 2, "W.Low", text_color=c_txt, bgcolor=f_prox_color(w_low), text_size=size.small)
    table.cell(proximity, 1, 2, str.tostring(f_dist(w_low)) + "p", text_color=c_txt, bgcolor=f_prox_color(w_low), text_size=size.small)

    table.cell(proximity, 0, 3, "M.High", text_color=c_txt, bgcolor=f_prox_color(m_high), text_size=size.small)
    table.cell(proximity, 1, 3, str.tostring(f_dist(m_high)) + "p", text_color=c_txt, bgcolor=f_prox_color(m_high), text_size=size.small)

    table.cell(proximity, 0, 4, "M.Low", text_color=c_txt, bgcolor=f_prox_color(m_low), text_size=size.small)
    table.cell(proximity, 1, 4, str.tostring(f_dist(m_low)) + "p", text_color=c_txt, bgcolor=f_prox_color(m_low), text_size=size.small)

    table.cell(proximity, 0, 5, "PDH", text_color=c_txt, bgcolor=f_prox_color(pd_high), text_size=size.small)
    table.cell(proximity, 1, 5, str.tostring(f_dist(pd_high)) + "p", text_color=c_txt, bgcolor=f_prox_color(pd_high), text_size=size.small)

    table.cell(proximity, 0, 6, "PDL", text_color=c_txt, bgcolor=f_prox_color(pd_low), text_size=size.small)
    table.cell(proximity, 1, 6, str.tostring(f_dist(pd_low)) + "p", text_color=c_txt, bgcolor=f_prox_color(pd_low), text_size=size.small)

    table.cell(proximity, 0, 7, "PW.High", text_color=c_txt, bgcolor=f_prox_color(pw_high), text_size=size.small)
    table.cell(proximity, 1, 7, str.tostring(f_dist(pw_high)) + "p", text_color=c_txt, bgcolor=f_prox_color(pw_high), text_size=size.small)

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────

alert_dist = pip_size * proximity_alert

alertcondition(math.abs(close - w_high)  <= alert_dist, title="Price Near Weekly High",       message="KSL: Price near Weekly High")
alertcondition(math.abs(close - w_low)   <= alert_dist, title="Price Near Weekly Low",        message="KSL: Price near Weekly Low")
alertcondition(math.abs(close - m_high)  <= alert_dist, title="Price Near Monthly High",      message="KSL: Price near Monthly High")
alertcondition(math.abs(close - m_low)   <= alert_dist, title="Price Near Monthly Low",       message="KSL: Price near Monthly Low")
alertcondition(math.abs(close - pd_high) <= alert_dist, title="Price Near Previous Day High", message="KSL: Price near Previous Day High")
alertcondition(math.abs(close - pd_low)  <= alert_dist, title="Price Near Previous Day Low",  message="KSL: Price near Previous Day Low")
````
