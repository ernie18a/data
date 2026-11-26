# RAGUL Multi-TF Structure & Levels

- url: https://www.tradingview.com/script/w5TciH2e-RAGUL-Multi-TF-Structure-Levels/
- type: indicator
- pine_id: PUB;54920b3ca84c43dba193e9b486814dfd
- version: 3.0

## Description

Price Levels + Swing Structure + Candle Patterns
Overview
The indicator is a comprehensive all-in-one price structure tool built for intraday and positional traders who need clean, non-overlapping reference levels across multiple timeframes on a single chart. Every module is independently togglable so you use only what you need.

What This Indicator Does
It combines six functional modules into one clean overlay — previous period price levels, live session highs and lows across four timeframes, multi-timeframe swing structure detection, and candlestick pattern labelling at swing points — all managed through a Unified Smart Label Engine that eliminates label overlap by automatically printing colliding labels side by side horizontally.

MODULES
M1 — Previous Period Price Levels
Plots horizontal lines for the previous Day, Week and Month High, Low, Open, Close and Midpoint (EQ). All levels auto-update and extend to the right. Each level has individual show/hide toggle, colour, line width and style (solid/dashed/dotted).

M1B — Today's Day High / Low
Tracks the running session high and low from the start of the current trading day. Resets automatically each new day. Line extends both directions across the chart.

M1C — Today's 1H High / Low
Tracks the highest high and lowest low made on the 1-Hour timeframe within today's session. Useful for identifying intraday structure boundaries.

M1D — Today's 15M High / Low
Same as M1C but sourced from the 15-Minute timeframe. Useful for scalping reference and session breakout identification.

M1E — Today's 75M High / Low
Tracks today's session high and low on the 75-Minute timeframe, a popular intermediate reference for Indian index traders (Nifty, Banknifty, Sensex).

M2 — Chart Timeframe Swing Structure
Detects pivot swing highs and lows directly on the current chart timeframe using configurable left/right bar strength. Current swing level extends dynamically to the right. Past levels are preserved as faded lines with a configurable maximum count.

M3 — Swing Structure with Candle Patterns
Labels swing highs and lows as HH / HL / LH / LL with extending lines. Additionally identifies the candlestick pattern that formed at each swing point — Hammer, Inverted Hammer, Bullish Engulfing, Hanging Man, Shooting Star, Bearish Engulfing — each individually togglable.

M4 — 1H Swing Structure
Pivot-based swing detection running on the 1-Hour timeframe, displayed on any chart timeframe. Current level extends right dynamically. Past levels archived as dashed lines.

M5 — 15M Swing Structure
Same as M4 but on the 15-Minute timeframe. Ideal for scalpers and intraday traders tracking lower timeframe structure.

M6 — 75M Swing Structure
Pivot-based swing detection on the 75-Minute timeframe. Particularly relevant for Indian derivatives markets where 75M is a widely used structural reference.

UNIFIED SMART LABEL ENGINE
All price labels across all modules are managed centrally. The engine collects every active level, sorts them by price, detects collisions within a configurable tolerance band, and automatically prints overlapping labels side by side horizontally at the same price rather than stacking them on top of each other. Label anchor position (Right Edge or Left Edge), horizontal gap between stacked labels, and collision tolerance are all user-configurable.

PRESET TEMPLATE SELECTOR
Three saved colour presets (My Preset 1, 2, 3) plus the Default. Switch between them with a single dropdown. To customise a preset, edit the hex colour values directly in the source code under each preset block.

STATUS TABLE
A compact corner table shows the ON/OFF state of all 11 modules at a glance. Table position is configurable (top-right, top-left, bottom-right, bottom-left).

Settings Summary
Independent enable/disable for every module
Individual colour, line width and line style per level
Label anchor: Right Edge or Left Edge
Collision tolerance and stacking gap fully adjustable
Three saveable colour presets
Works on all timeframes and all instruments

Instrument
NSE / BSE Indices (Nifty, Banknifty, Sensex, Finnifty), Futures, Stocks. Works on any instrument and any timeframe on TradingView.

Disclaimer

This indicator is for educational and analytical purposes only. It does not constitute financial advice or trading signals. Past price structure does not guarantee future price behaviour. Always use proper risk management.

## Source Code

````pine
//@version=6
// ============================================================
// RAGUL INDICATOR SUITE v2.0
// Author      : Ragul
// Description : Multi-module price structure indicator
//               combining HTF levels, intraday session
//               highs/lows, and multi-timeframe swing
//               structure with candle pattern detection.
// Modules     : M1  — Previous Period Levels (D/W/M)
//               M1B — Today's Day High / Low
//               M1C — Today's 1H High / Low
//               M1D — Today's 15M High / Low
//               M1E — Today's 75M High / Low
//               M2  — Chart TF Swing Structure
//               M3  — Swing Structure + Candle Patterns
//               M4  — 1H Swing Structure
//               M5  — 15M Swing Structure
//               M6  — 75M Swing Structure
// ============================================================

indicator("RAGUL Indicator Suite", overlay=true, max_lines_count=500, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════
//   HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════

f_ls(s) =>
    s == "dashed" ? line.style_dashed : s == "dotted" ? line.style_dotted : line.style_solid

f_lbl_size(s) =>
    s == "tiny" ? size.tiny : s == "small" ? size.small : s == "large" ? size.large : size.normal

f_tbl_pos(p) =>
    p == "top_left"     ? position.top_left     :
     p == "bottom_right" ? position.bottom_right :
     p == "bottom_left"  ? position.bottom_left  :
     position.top_right

chart_high_300 = ta.highest(high, 300)
chart_low_300  = ta.lowest(low,  300)

// ═══════════════════════════════════════════════════════════════
//   PRESET SELECTOR
// ═══════════════════════════════════════════════════════════════

grp_preset  = "━━━ RAGUL · PRESET TEMPLATE SELECTOR ━━━"
preset_mode = input.string("Default", "Active Template",
     options = ["Default", "My Preset 1", "My Preset 2", "My Preset 3"],
     tooltip = "Select a preset. To customise, edit colour hex values in the script source.",
     group   = grp_preset)

// ═══════════════════════════════════════════════════════════════
//   LABEL POSITION SETTINGS
// ═══════════════════════════════════════════════════════════════

grp_lp = "━━━ RAGUL · LABEL POSITION SETTINGS ━━━"
lbl_anchor    = input.string("Right Edge", "Label Anchor Position",
     options  = ["Right Edge", "Left Edge"],
     tooltip  = "Right Edge — labels at right end. Left Edge — labels at left end.",
     group    = grp_lp)
lbl_stack_gap = input.int(3, "Horizontal Gap Between Stacked Labels (bars)",
     minval   = 1, maxval = 20,
     tooltip  = "Bar spacing between labels at the same price level.",
     group    = grp_lp)
lbl_price_tol = input.float(0.05, "Price Collision Tolerance (% of Range)",
     minval   = 0.01, maxval = 1.0, step = 0.01,
     tooltip  = "Levels within this % of visible range are grouped side by side.",
     group    = grp_lp)

// ═══════════════════════════════════════════════════════════════
//   RAGUL MODULE 1 — PREVIOUS PERIOD PRICE LEVELS
// ═══════════════════════════════════════════════════════════════

grp1  = "━━━ RAGUL M1 · PREVIOUS PERIOD PRICE LEVELS ━━━"
pdpwpm_on    = input.bool(true, "Enable Previous Period Levels", group=grp1)

grp1a = "M1 · Daily — Previous Day"
show_PDH     = input.bool(true,  "Show PDH — Prev Day High",     group=grp1a)
show_PDL     = input.bool(true,  "Show PDL — Prev Day Low",      group=grp1a)
show_PDC     = input.bool(true,  "Show PDC — Prev Day Close",    group=grp1a)
show_PDO     = input.bool(false, "Show PDO — Prev Day Open",     group=grp1a)
show_PDEQ    = input.bool(true,  "Show EQ  — Prev Day Midpoint", group=grp1a)
col_PDH      = input.color(color.new(#00E5FF, 0),  "PDH Colour", group=grp1a)
col_PDL      = input.color(color.new(#00E5FF, 0),  "PDL Colour", group=grp1a)
col_PDC      = input.color(color.new(#FFD600, 0),  "PDC Colour", group=grp1a)
col_PDO      = input.color(color.new(#FFD600, 60), "PDO Colour", group=grp1a)
col_PDEQ     = input.color(color.new(#78909C, 0),  "EQ Colour",  group=grp1a)
pd_lw        = input.int(1, "Line Width", minval=1, maxval=4, group=grp1a)
pd_style     = input.string("solid", "Line Style", options=["solid","dashed","dotted"], group=grp1a)

grp1b = "M1 · Weekly — Previous Week"
show_PWH     = input.bool(true,  "Show PWH — Prev Week High",  group=grp1b)
show_PWL     = input.bool(true,  "Show PWL — Prev Week Low",   group=grp1b)
show_PWC     = input.bool(false, "Show PWC — Prev Week Close", group=grp1b)
show_PWO     = input.bool(false, "Show PWO — Prev Week Open",  group=grp1b)
col_PWH      = input.color(color.new(#FF6D00, 0),  "PWH Colour", group=grp1b)
col_PWL      = input.color(color.new(#FF6D00, 0),  "PWL Colour", group=grp1b)
col_PWC      = input.color(color.new(#FFAB40, 60), "PWC Colour", group=grp1b)
col_PWO      = input.color(color.new(#FFAB40, 60), "PWO Colour", group=grp1b)
pw_lw        = input.int(1, "Line Width", minval=1, maxval=4, group=grp1b)
pw_style     = input.string("dashed", "Line Style", options=["solid","dashed","dotted"], group=grp1b)

grp1c = "M1 · Monthly — Previous Month"
show_PMH     = input.bool(true,  "Show PMH — Prev Month High",  group=grp1c)
show_PML     = input.bool(true,  "Show PML — Prev Month Low",   group=grp1c)
show_PMC     = input.bool(false, "Show PMC — Prev Month Close", group=grp1c)
show_PMO     = input.bool(false, "Show PMO — Prev Month Open",  group=grp1c)
col_PMH      = input.color(color.new(#E040FB, 0),  "PMH Colour", group=grp1c)
col_PML      = input.color(color.new(#E040FB, 0),  "PML Colour", group=grp1c)
col_PMC      = input.color(color.new(#CE93D8, 60), "PMC Colour", group=grp1c)
col_PMO      = input.color(color.new(#CE93D8, 60), "PMO Colour", group=grp1c)
pm_lw        = input.int(1, "Line Width", minval=1, maxval=4, group=grp1c)
pm_style     = input.string("dotted", "Line Style", options=["solid","dashed","dotted"], group=grp1c)

// Preset colour overrides
pdh_col  = preset_mode == "My Preset 1" ? color.new(#FF0000,0)  : preset_mode == "My Preset 2" ? color.new(#FFD700,0)  : preset_mode == "My Preset 3" ? color.new(#00BFFF,0)  : col_PDH
pdl_col  = preset_mode == "My Preset 1" ? color.new(#FF0000,0)  : preset_mode == "My Preset 2" ? color.new(#FFD700,0)  : preset_mode == "My Preset 3" ? color.new(#00BFFF,0)  : col_PDL
pdc_col  = preset_mode == "My Preset 1" ? color.new(#FFA500,0)  : preset_mode == "My Preset 2" ? color.new(#ADFF2F,0)  : preset_mode == "My Preset 3" ? color.new(#DA70D6,0)  : col_PDC
pdo_col  = preset_mode == "My Preset 1" ? color.new(#FFA500,60) : preset_mode == "My Preset 2" ? color.new(#ADFF2F,60) : preset_mode == "My Preset 3" ? color.new(#DA70D6,60) : col_PDO
pdeq_col = preset_mode == "My Preset 1" ? color.new(#808080,0)  : preset_mode == "My Preset 2" ? color.new(#708090,0)  : preset_mode == "My Preset 3" ? color.new(#696969,0)  : col_PDEQ
pwh_col  = preset_mode == "My Preset 1" ? color.new(#FF6347,0)  : preset_mode == "My Preset 2" ? color.new(#FF8C00,0)  : preset_mode == "My Preset 3" ? color.new(#FF4500,0)  : col_PWH
pwl_col  = preset_mode == "My Preset 1" ? color.new(#FF6347,0)  : preset_mode == "My Preset 2" ? color.new(#FF8C00,0)  : preset_mode == "My Preset 3" ? color.new(#FF4500,0)  : col_PWL
pwc_col  = preset_mode == "My Preset 1" ? color.new(#FF6347,60) : preset_mode == "My Preset 2" ? color.new(#FF8C00,60) : preset_mode == "My Preset 3" ? color.new(#FF4500,60) : col_PWC
pwo_col  = preset_mode == "My Preset 1" ? color.new(#FF6347,60) : preset_mode == "My Preset 2" ? color.new(#FF8C00,60) : preset_mode == "My Preset 3" ? color.new(#FF4500,60) : col_PWO
pmh_col  = preset_mode == "My Preset 1" ? color.new(#9400D3,0)  : preset_mode == "My Preset 2" ? color.new(#8A2BE2,0)  : preset_mode == "My Preset 3" ? color.new(#9932CC,0)  : col_PMH
pml_col  = preset_mode == "My Preset 1" ? color.new(#9400D3,0)  : preset_mode == "My Preset 2" ? color.new(#8A2BE2,0)  : preset_mode == "My Preset 3" ? color.new(#9932CC,0)  : col_PML
pmc_col  = preset_mode == "My Preset 1" ? color.new(#9400D3,60) : preset_mode == "My Preset 2" ? color.new(#8A2BE2,60) : preset_mode == "My Preset 3" ? color.new(#9932CC,60) : col_PMC
pmo_col  = preset_mode == "My Preset 1" ? color.new(#9400D3,60) : preset_mode == "My Preset 2" ? color.new(#8A2BE2,60) : preset_mode == "My Preset 3" ? color.new(#9932CC,60) : col_PMO

// Fetch HTF OHLC
[d_o, d_h, d_l, d_c] = request.security(syminfo.tickerid, "D", [open[1], high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
[w_o, w_h, w_l, w_c] = request.security(syminfo.tickerid, "W", [open[1], high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
[m_o, m_h, m_l, m_c] = request.security(syminfo.tickerid, "M", [open[1], high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
pd_eq = (d_h + d_l) / 2

var line[] m1_lines = array.new_line()

if pdpwpm_on and barstate.islast
    for ln in m1_lines
        line.delete(ln)
    array.clear(m1_lines)
    if show_PDH and not na(d_h)
        array.push(m1_lines, line.new(bar_index-500, d_h,   bar_index, d_h,   color=pdh_col,  width=pd_lw, style=f_ls(pd_style), extend=extend.right))
    if show_PDL and not na(d_l)
        array.push(m1_lines, line.new(bar_index-500, d_l,   bar_index, d_l,   color=pdl_col,  width=pd_lw, style=f_ls(pd_style), extend=extend.right))
    if show_PDC and not na(d_c)
        array.push(m1_lines, line.new(bar_index-500, d_c,   bar_index, d_c,   color=pdc_col,  width=pd_lw, style=f_ls(pd_style), extend=extend.right))
    if show_PDO and not na(d_o)
        array.push(m1_lines, line.new(bar_index-500, d_o,   bar_index, d_o,   color=pdo_col,  width=pd_lw, style=f_ls(pd_style), extend=extend.right))
    if show_PDEQ and not na(pd_eq)
        array.push(m1_lines, line.new(bar_index-500, pd_eq, bar_index, pd_eq, color=pdeq_col, width=pd_lw, style=f_ls(pd_style), extend=extend.right))
    if show_PWH and not na(w_h)
        array.push(m1_lines, line.new(bar_index-500, w_h,   bar_index, w_h,   color=pwh_col,  width=pw_lw, style=f_ls(pw_style), extend=extend.right))
    if show_PWL and not na(w_l)
        array.push(m1_lines, line.new(bar_index-500, w_l,   bar_index, w_l,   color=pwl_col,  width=pw_lw, style=f_ls(pw_style), extend=extend.right))
    if show_PWC and not na(w_c)
        array.push(m1_lines, line.new(bar_index-500, w_c,   bar_index, w_c,   color=pwc_col,  width=pw_lw, style=f_ls(pw_style), extend=extend.right))
    if show_PWO and not na(w_o)
        array.push(m1_lines, line.new(bar_index-500, w_o,   bar_index, w_o,   color=pwo_col,  width=pw_lw, style=f_ls(pw_style), extend=extend.right))
    if show_PMH and not na(m_h)
        array.push(m1_lines, line.new(bar_index-500, m_h,   bar_index, m_h,   color=pmh_col,  width=pm_lw, style=f_ls(pm_style), extend=extend.right))
    if show_PML and not na(m_l)
        array.push(m1_lines, line.new(bar_index-500, m_l,   bar_index, m_l,   color=pml_col,  width=pm_lw, style=f_ls(pm_style), extend=extend.right))
    if show_PMC and not na(m_c)
        array.push(m1_lines, line.new(bar_index-500, m_c,   bar_index, m_c,   color=pmc_col,  width=pm_lw, style=f_ls(pm_style), extend=extend.right))
    if show_PMO and not na(m_o)
        array.push(m1_lines, line.new(bar_index-500, m_o,   bar_index, m_o,   color=pmo_col,  width=pm_lw, style=f_ls(pm_style), extend=extend.right))

// ═══════════════════════════════════════════════════════════════
//   RAGUL MODULE 1B — TODAY'S DAY HIGH / LOW
// ═══════════════════════════════════════════════════════════════

grp1e = "━━━ RAGUL M1B · TODAY'S DAY HIGH / LOW ━━━"
show_today   = input.bool(true,  "Enable Today High / Low", group=grp1e)
show_TDH     = input.bool(true,  "Show Today High (TDH)",   group=grp1e)
show_TDL     = input.bool(true,  "Show Today Low  (TDL)",   group=grp1e)
col_TDH      = input.color(color.new(#00FF88, 0), "TDH Colour", group=grp1e)
col_TDL      = input.color(color.new(#FF4444, 0), "TDL Colour", group=grp1e)
tdhl_lw      = input.int(1, "Line Width", minval=1, maxval=4, group=grp1e)
tdhl_style   = input.string("solid", "Line Style", options=["solid","dashed","dotted"], group=grp1e)

tdh_col_rt = preset_mode == "My Preset 1" ? color.new(#00FF7F,0) : preset_mode == "My Preset 2" ? color.new(#32CD32,0) : preset_mode == "My Preset 3" ? color.new(#7CFC00,0) : col_TDH
tdl_col_rt = preset_mode == "My Preset 1" ? color.new(#DC143C,0) : preset_mode == "My Preset 2" ? color.new(#B22222,0) : preset_mode == "My Preset 3" ? color.new(#FF6347,0) : col_TDL

is_new_day = ta.change(time("D")) != 0
var float today_high = na
var float today_low  = na

if is_new_day or na(today_high)
    today_high := high
    today_low  := low
else
    today_high := math.max(today_high, high)
    today_low  := math.min(today_low,  low)

var line tdh_line = na
var line tdl_line = na

if show_today
    if show_TDH and not na(today_high)
        if not na(tdh_line)
            line.delete(tdh_line)
        tdh_line := line.new(bar_index, today_high, bar_index+1, today_high, color=tdh_col_rt, width=tdhl_lw, style=f_ls(tdhl_style), extend=extend.both)
    if show_TDL and not na(today_low)
        if not na(tdl_line)
            line.delete(tdl_line)
        tdl_line := line.new(bar_index, today_low, bar_index+1, today_low, color=tdl_col_rt, width=tdhl_lw, style=f_ls(tdhl_style), extend=extend.both)

// ═══════════════════════════════════════════════════════════════
//   RAGUL MODULE 1C — TODAY'S 1H HIGH / LOW
// ═══════════════════════════════════════════════════════════════

grp1f = "━━━ RAGUL M1C · TODAY'S 1H HIGH / LOW ━━━"
show_td1h    = input.bool(true, "Enable Today 1H High / Low", group=grp1f)
show_TD1HH   = input.bool(true, "Show Today 1H High",         group=grp1f)
show_TD1HL   = input.bool(true, "Show Today 1H Low",          group=grp1f)
col_TD1HH    = input.color(color.new(#FF9800,0), "1H High Colour", group=grp1f)
col_TD1HL    = input.color(color.new(#00BCD4,0), "1H Low Colour",  group=grp1f)
td1h_lw      = input.int(1, "Line Width", minval=1, maxval=4, group=grp1f)
td1h_style   = input.string("dashed", "Line Style", options=["solid","dashed","dotted"], group=grp1f)

h1_sess_high = request.security(syminfo.tickerid, "60", high, lookahead=barmerge.lookahead_off)
h1_sess_low  = request.security(syminfo.tickerid, "60", low,  lookahead=barmerge.lookahead_off)
h1_new_day   = ta.change(request.security(syminfo.tickerid, "60", time("D"), lookahead=barmerge.lookahead_off)) != 0

var float td1h_high = na
var float td1h_low  = na

if h1_new_day or na(td1h_high)
    td1h_high := h1_sess_high
    td1h_low  := h1_sess_low
else
    td1h_high := math.max(td1h_high, h1_sess_high)
    td1h_low  := math.min(td1h_low,  h1_sess_low)

var line td1h_hline = na
var line td1h_lline = na

if show_td1h
    if show_TD1HH and not na(td1h_high)
        if not na(td1h_hline)
            line.delete(td1h_hline)
        td1h_hline := line.new(bar_index, td1h_high, bar_index+1, td1h_high, color=col_TD1HH, width=td1h_lw, style=f_ls(td1h_style), extend=extend.both)
    if show_TD1HL and not na(td1h_low)
        if not na(td1h_lline)
            line.delete(td1h_lline)
        td1h_lline := line.new(bar_index, td1h_low, bar_index+1, td1h_low, color=col_TD1HL, width=td1h_lw, style=f_ls(td1h_style), extend=extend.both)

// ═══════════════════════════════════════════════════════════════
//   RAGUL MODULE 1D — TODAY'S 15M HIGH / LOW
// ═══════════════════════════════════════════════════════════════

grp1g = "━━━ RAGUL M1D · TODAY'S 15M HIGH / LOW ━━━"
show_td15m   = input.bool(true, "Enable Today 15M High / Low", group=grp1g)
show_TD15MH  = input.bool(true, "Show Today 15M High",         group=grp1g)
show_TD15ML  = input.bool(true, "Show Today 15M Low",          group=grp1g)
col_TD15MH   = input.color(color.new(#CDDC39,0), "15M High Colour", group=grp1g)
col_TD15ML   = input.color(color.new(#AB47BC,0), "15M Low Colour",  group=grp1g)
td15m_lw     = input.int(1, "Line Width", minval=1, maxval=4, group=grp1g)
td15m_style  = input.string("dashed", "Line Style", options=["solid","dashed","dotted"], group=grp1g)

m15_sess_high = request.security(syminfo.tickerid, "15", high, lookahead=barmerge.lookahead_off)
m15_sess_low  = request.security(syminfo.tickerid, "15", low,  lookahead=barmerge.lookahead_off)
m15_new_day   = ta.change(request.security(syminfo.tickerid, "15", time("D"), lookahead=barmerge.lookahead_off)) != 0

var float td15m_high = na
var float td15m_low  = na

if m15_new_day or na(td15m_high)
    td15m_high := m15_sess_high
    td15m_low  := m15_sess_low
else
    td15m_high := math.max(td15m_high, m15_sess_high)
    td15m_low  := math.min(td15m_low,  m15_sess_low)

var line td15m_hline = na
var line td15m_lline = na

if show_td15m
    if show_TD15MH and not na(td15m_high)
        if not na(td15m_hline)
            line.delete(td15m_hline)
        td15m_hline := line.new(bar_index, td15m_high, bar_index+1, td15m_high, color=col_TD15MH, width=td15m_lw, style=f_ls(td15m_style), extend=extend.both)
    if show_TD15ML and not na(td15m_low)
        if not na(td15m_lline)
            line.delete(td15m_lline)
        td15m_lline := line.new(bar_index, td15m_low, bar_index+1, td15m_low, color=col_TD15ML, width=td15m_lw, style=f_ls(td15m_style), extend=extend.both)

// ═══════════════════════════════════════════════════════════════
//   RAGUL MODULE 1E — TODAY'S 75M HIGH / LOW
// ═══════════════════════════════════════════════════════════════

grp1h = "━━━ RAGUL M1E · TODAY'S 75M HIGH / LOW ━━━"
show_td75m   = input.bool(true, "Enable Today 75M High / Low", group=grp1h)
show_TD75MH  = input.bool(true, "Show Today 75M High",         group=grp1h)
show_TD75ML  = input.bool(true, "Show Today 75M Low",          group=grp1h)
col_TD75MH   = input.color(color.new(#FF5722,0), "75M High Colour", group=grp1h)
col_TD75ML   = input.color(color.new(#29B6F6,0), "75M Low Colour",  group=grp1h)
td75m_lw     = input.int(1, "Line Width", minval=1, maxval=4, group=grp1h)
td75m_style  = input.string("dashed", "Line Style", options=["solid","dashed","dotted"], group=grp1h)

m75_sess_high = request.security(syminfo.tickerid, "75", high, lookahead=barmerge.lookahead_off)
m75_sess_low  = request.security(syminfo.tickerid, "75", low,  lookahead=barmerge.lookahead_off)
m75_new_day   = ta.change(request.security(syminfo.tickerid, "75", time("D"), lookahead=barmerge.lookahead_off)) != 0

var float td75m_high = na
var float td75m_low  = na

if m75_new_day or na(td75m_high)
    td75m_high := m75_sess_high
    td75m_low  := m75_sess_low
else
    td75m_high := math.max(td75m_high, m75_sess_high)
    td75m_low  := math.min(td75m_low,  m75_sess_low)

var line td75m_hline = na
var line td75m_lline = na

if show_td75m
    if show_TD75MH and not na(td75m_high)
        if not na(td75m_hline)
            line.delete(td75m_hline)
        td75m_hline := line.new(bar_index, td75m_high, bar_index+1, td75m_high, color=col_TD75MH, width=td75m_lw, style=f_ls(td75m_style), extend=extend.both)
    if show_TD75ML and not na(td75m_low)
        if not na(td75m_lline)
            line.delete(td75m_lline)
        td75m_lline := line.new(bar_index, td75m_low, bar_index+1, td75m_low, color=col_TD75ML, width=td75m_lw, style=f_ls(td75m_style), extend=extend.both)

// ═══════════════════════════════════════════════════════════════
//   RAGUL MODULE 2 — CHART TF SWING STRUCTURE
// ═══════════════════════════════════════════════════════════════

grp2 = "━━━ RAGUL M2 · CHART TF SWING STRUCTURE ━━━"
rv5_on        = input.bool(true, "Enable Chart TF Swing Structure", group=grp2)
rv5_sh_left   = input.int(5, "Swing High — Bars Left",  minval=1, group=grp2)
rv5_sh_right  = input.int(5, "Swing High — Bars Right", minval=1, group=grp2)
rv5_sl_left   = input.int(5, "Swing Low  — Bars Left",  minval=1, group=grp2)
rv5_sl_right  = input.int(5, "Swing Low  — Bars Right", minval=1, group=grp2)

grp2a = "M2 · Current Swing Style"
rv5_cur_sh_col = input.color(color.new(#F44336,0), "Current High Colour", group=grp2a)
rv5_cur_sl_col = input.color(color.new(#4CAF50,0), "Current Low Colour",  group=grp2a)
rv5_cur_sh_st  = input.string("solid", "Current High Style", options=["solid","dashed","dotted"], group=grp2a)
rv5_cur_sl_st  = input.string("solid", "Current Low Style",  options=["solid","dashed","dotted"], group=grp2a)
rv5_cur_lw     = input.int(2, "Current Line Width", minval=1, maxval=4, group=grp2a)

grp2b = "M2 · Past Swing Style"
rv5_past_sh_col = input.color(color.new(#F44336,70), "Past High Colour", group=grp2b)
rv5_past_sl_col = input.color(color.new(#4CAF50,70), "Past Low Colour",  group=grp2b)
rv5_past_sh_st  = input.string("dashed", "Past High Style", options=["solid","dashed","dotted"], group=grp2b)
rv5_past_sl_st  = input.string("dashed", "Past Low Style",  options=["solid","dashed","dotted"], group=grp2b)
rv5_past_lw     = input.int(1, "Past Line Width", minval=1, maxval=4, group=grp2b)
rv5_max_past    = input.int(5, "Max Past Levels", minval=1, maxval=20, group=grp2b)

rv5_ph = ta.pivothigh(high, rv5_sh_left, rv5_sh_right)
rv5_pl = ta.pivotlow(low,   rv5_sl_left, rv5_sl_right)

var float  rv5_cur_sh_val  = na
var int    rv5_cur_sh_bar  = na
var float  rv5_cur_sl_val  = na
var int    rv5_cur_sl_bar  = na
var line   rv5_cur_sh_line = na
var line   rv5_cur_sl_line = na
var line[] rv5_past_sh_lns = array.new_line()
var line[] rv5_past_sl_lns = array.new_line()

if rv5_on
    if not na(rv5_ph)
        ph_bar = bar_index - rv5_sh_right
        if not na(rv5_cur_sh_val) and not na(rv5_cur_sh_line)
            line.set_color(rv5_cur_sh_line,  rv5_past_sh_col)
            line.set_style(rv5_cur_sh_line,  f_ls(rv5_past_sh_st))
            line.set_width(rv5_cur_sh_line,  rv5_past_lw)
            line.set_extend(rv5_cur_sh_line, extend.none)
            array.push(rv5_past_sh_lns, rv5_cur_sh_line)
            if array.size(rv5_past_sh_lns) > rv5_max_past
                line.delete(array.shift(rv5_past_sh_lns))
        rv5_cur_sh_val  := rv5_ph
        rv5_cur_sh_bar  := ph_bar
        rv5_cur_sh_line := line.new(ph_bar, rv5_ph, bar_index, rv5_ph, color=rv5_cur_sh_col, style=f_ls(rv5_cur_sh_st), width=rv5_cur_lw, extend=extend.right)

    if not na(rv5_pl)
        pl_bar = bar_index - rv5_sl_right
        if not na(rv5_cur_sl_val) and not na(rv5_cur_sl_line)
            line.set_color(rv5_cur_sl_line,  rv5_past_sl_col)
            line.set_style(rv5_cur_sl_line,  f_ls(rv5_past_sl_st))
            line.set_width(rv5_cur_sl_line,  rv5_past_lw)
            line.set_extend(rv5_cur_sl_line, extend.none)
            array.push(rv5_past_sl_lns, rv5_cur_sl_line)
            if array.size(rv5_past_sl_lns) > rv5_max_past
                line.delete(array.shift(rv5_past_sl_lns))
        rv5_cur_sl_val  := rv5_pl
        rv5_cur_sl_bar  := pl_bar
        rv5_cur_sl_line := line.new(pl_bar, rv5_pl, bar_index, rv5_pl, color=rv5_cur_sl_col, style=f_ls(rv5_cur_sl_st), width=rv5_cur_lw, extend=extend.right)

    if not na(rv5_cur_sh_line)
        line.set_x2(rv5_cur_sh_line, bar_index)
    if not na(rv5_cur_sl_line)
        line.set_x2(rv5_cur_sl_line, bar_index)

// ═══════════════════════════════════════════════════════════════
//   RAGUL MODULE 3 — SWING STRUCTURE + CANDLE PATTERNS
// ═══════════════════════════════════════════════════════════════

grp3 = "━━━ RAGUL M3 · SWING STRUCTURE + CANDLE PATTERNS ━━━"
m3_on            = input.bool(true, "Enable Swing + Candle Patterns", group=grp3)
m3_length        = input.int(5, "Swing Sensitivity (Length)", minval=1, maxval=100,
     tooltip = "Lower value = faster label, more signals. Higher value = confirmed swing but label appears later. Recommended: 3 to 7 for intraday.",
     group   = grp3)

grp3a = "M3 · Swing Labels and Lines"
m3_show_HH       = input.bool(true, "Show HH — Higher High", group=grp3a)
m3_show_HL       = input.bool(true, "Show HL — Higher Low",  group=grp3a)
m3_show_LH       = input.bool(true, "Show LH — Lower High",  group=grp3a)
m3_show_LL       = input.bool(true, "Show LL — Lower Low",   group=grp3a)
m3_col_high      = input.color(color.new(#EF5350,0), "Swing High Colour", group=grp3a)
m3_col_low       = input.color(color.new(#26A69A,0), "Swing Low Colour",  group=grp3a)
m3_extend_lines  = input.bool(true, "Extend Lines to Right", group=grp3a)
m3_line_style    = input.string("dashed", "Line Style", options=["solid","dashed","dotted"], group=grp3a)
m3_high_lw       = input.int(1, "High Line Width", minval=1, maxval=4, group=grp3a)
m3_low_lw        = input.int(1, "Low Line Width",  minval=1, maxval=4, group=grp3a)
m3_max_lines     = input.int(10, "Max Lines to Show", minval=1, maxval=50, group=grp3a)
m3_lbl_size      = input.string("small", "Label Size", options=["tiny","small","normal","large"], group=grp3a)

grp3b = "M3 · Candle Pattern Detection"
m3_patterns_on   = input.bool(true, "Show Candle Pattern Labels", group=grp3b)
m3_pat_hammer    = input.bool(true, "Hammer",            group=grp3b)
m3_pat_inv_ham   = input.bool(true, "Inverted Hammer",   group=grp3b)
m3_pat_bull_eng  = input.bool(true, "Bullish Engulfing", group=grp3b)
m3_pat_hang      = input.bool(true, "Hanging Man",       group=grp3b)
m3_pat_shoot     = input.bool(true, "Shooting Star",     group=grp3b)
m3_pat_bear_eng  = input.bool(true, "Bearish Engulfing", group=grp3b)

grp3c = "M3 · Detection Mode"
m3_early_mode = input.bool(true, "Early Detection Mode (labels on same candle)", 
     tooltip  = "OFF = Confirmed mode, zero repaint, label appears after right-bar confirmation. ON = Early mode, label appears on the actual swing candle.",
     group    = grp3c)
m3_early_bars = input.int(2, "Early Mode — Bars Right Confirmation", minval=1, maxval=10,
     tooltip  = "Number of bars to the right used for early confirmation. Lower = faster, higher = more reliable.",
     group    = grp3c)

m3_ph_confirmed = ta.pivothigh(m3_length, m3_length)
m3_pl_confirmed = ta.pivotlow(m3_length,  m3_length)
m3_ph_early     = ta.pivothigh(m3_length, m3_early_bars)
m3_pl_early     = ta.pivotlow(m3_length,  m3_early_bars)

m3_ph           = m3_early_mode ? m3_ph_early     : m3_ph_confirmed
m3_pl           = m3_early_mode ? m3_pl_early     : m3_pl_confirmed
m3_ph_offset    = m3_early_mode ? m3_early_bars   : m3_length
m3_pl_offset    = m3_early_mode ? m3_early_bars   : m3_length

var float  m3_prev_ph    = na
var float  m3_prev_pl    = na
var line[] m3_high_lines = array.new_line()
var line[] m3_low_lines  = array.new_line()

m3_detect_pattern(off) =>
    string res  = ""
    float  o    = open[off]
    float  h    = high[off]
    float  l    = low[off]
    float  c    = close[off]
    float  rng  = h - l
    float  body = math.abs(c - o)
    float  top  = math.max(o, c)
    float  bot  = math.min(o, c)
    float shd_upper = rng > 0 ? (h - top) / rng : 0.0
    float shd_lower = rng > 0 ? (bot - l) / rng  : 0.0
    float body_pct  = rng > 0 ? body / rng        : 0.0
    bool  bull_bar  = c > o
    bool  bear_bar  = c < o
    float prev_o    = open[off+1]
    float prev_c    = close[off+1]
    bool pat_hammer   = shd_lower >= 0.55 and shd_upper <= 0.08 and body_pct <= 0.35 and bull_bar and rng > 0
    bool pat_inv_ham  = shd_upper >= 0.55 and shd_lower <= 0.08 and body_pct <= 0.35 and bull_bar and rng > 0
    bool pat_hang     = shd_lower >= 0.55 and shd_upper <= 0.08 and body_pct <= 0.35 and bear_bar and rng > 0
    bool pat_shoot    = shd_upper >= 0.55 and shd_lower <= 0.08 and body_pct <= 0.35 and bear_bar and rng > 0
    bool pat_bull_eng = bull_bar and (prev_c < prev_o) and c > prev_o and o < prev_c
    bool pat_bear_eng = bear_bar and (prev_c > prev_o) and c < prev_o and o > prev_c
    if pat_hammer and m3_pat_hammer
        res := "Hammer"
    else if pat_inv_ham and m3_pat_inv_ham
        res := "Inv Hammer"
    else if pat_bull_eng and m3_pat_bull_eng
        res := "Bull Eng"
    else if pat_hang and m3_pat_hang
        res := "Hang Man"
    else if pat_shoot and m3_pat_shoot
        res := "Shoot Star"
    else if pat_bear_eng and m3_pat_bear_eng
        res := "Bear Eng"
    res

if m3_on
    if not na(m3_ph)
        ph_bar   = bar_index - m3_ph_offset
        is_HH    = na(m3_prev_ph) or m3_ph > m3_prev_ph
        tag      = is_HH ? "HH" : "LH"
        show_tag = (is_HH and m3_show_HH) or (not is_HH and m3_show_LH)
        if show_tag
            pat = m3_patterns_on ? m3_detect_pattern(m3_ph_offset) : ""
            lbl = tag + (pat != "" ? " " + pat : "")
            label.new(ph_bar, m3_ph, lbl,
                 color     = color.new(m3_col_high, 80),
                 textcolor = m3_col_high,
                 style     = label.style_label_down,
                 size      = f_lbl_size(m3_lbl_size))
            ln = line.new(ph_bar, m3_ph, ph_bar+1, m3_ph,
                 color  = m3_col_high,
                 style  = f_ls(m3_line_style),
                 width  = m3_high_lw,
                 extend = m3_extend_lines ? extend.right : extend.none)
            array.push(m3_high_lines, ln)
            if array.size(m3_high_lines) > m3_max_lines
                line.delete(array.shift(m3_high_lines))
        m3_prev_ph := m3_ph

    if not na(m3_pl)
        pl_bar   = bar_index - m3_pl_offset
        is_HL    = na(m3_prev_pl) or m3_pl > m3_prev_pl
        tag      = is_HL ? "HL" : "LL"
        show_tag = (is_HL and m3_show_HL) or (not is_HL and m3_show_LL)
        if show_tag
            pat = m3_patterns_on ? m3_detect_pattern(m3_pl_offset) : ""
            lbl = tag + (pat != "" ? " " + pat : "")
            label.new(pl_bar, m3_pl, lbl,
                 color     = color.new(m3_col_low, 80),
                 textcolor = m3_col_low,
                 style     = label.style_label_up,
                 size      = f_lbl_size(m3_lbl_size))
            ln = line.new(pl_bar, m3_pl, pl_bar+1, m3_pl,
                 color  = m3_col_low,
                 style  = f_ls(m3_line_style),
                 width  = m3_low_lw,
                 extend = m3_extend_lines ? extend.right : extend.none)
            array.push(m3_low_lines, ln)
            if array.size(m3_low_lines) > m3_max_lines
                line.delete(array.shift(m3_low_lines))
        m3_prev_pl := m3_pl

// ═══════════════════════════════════════════════════════════════
//   RAGUL MODULE 4 — 1H SWING STRUCTURE
// ═══════════════════════════════════════════════════════════════

grp4 = "━━━ RAGUL M4 · 1H SWING STRUCTURE ━━━"
h1_on         = input.bool(true, "Enable 1H Swing Structure", group=grp4)
h1_left       = input.int(5, "Bars Left",  minval=1, group=grp4)
h1_right      = input.int(5, "Bars Right", minval=1, group=grp4)
h1_max_past   = input.int(5, "Max Past Levels", minval=1, maxval=20, group=grp4)

grp4a = "M4 · Current Level Style"
h1_cur_sh_col = input.color(color.new(#FF9800,0), "Current High Colour", group=grp4a)
h1_cur_sl_col = input.color(color.new(#00BCD4,0), "Current Low Colour",  group=grp4a)
h1_cur_st     = input.string("solid", "Current Line Style", options=["solid","dashed","dotted"], group=grp4a)
h1_cur_lw     = input.int(2, "Current Line Width", minval=1, maxval=4, group=grp4a)

grp4b = "M4 · Past Level Style"
h1_past_sh_col = input.color(color.new(#FF9800,70), "Past High Colour", group=grp4b)
h1_past_sl_col = input.color(color.new(#00BCD4,70), "Past Low Colour",  group=grp4b)
h1_past_st     = input.string("dashed", "Past Line Style", options=["solid","dashed","dotted"], group=grp4b)
h1_past_lw     = input.int(1, "Past Line Width", minval=1, maxval=4, group=grp4b)

h1_high = request.security(syminfo.tickerid, "60", high, lookahead=barmerge.lookahead_off)
h1_low  = request.security(syminfo.tickerid, "60", low,  lookahead=barmerge.lookahead_off)
h1_ph   = ta.pivothigh(h1_high, h1_left, h1_right)
h1_pl   = ta.pivotlow(h1_low,   h1_left, h1_right)

var float  h1_cur_sh_val  = na
var float  h1_cur_sl_val  = na
var line   h1_cur_sh_line = na
var line   h1_cur_sl_line = na
var line[] h1_past_sh_lns = array.new_line()
var line[] h1_past_sl_lns = array.new_line()

if h1_on
    if not na(h1_ph)
        ph_bar = bar_index - h1_right
        if not na(h1_cur_sh_val) and not na(h1_cur_sh_line)
            line.set_color(h1_cur_sh_line,  h1_past_sh_col)
            line.set_style(h1_cur_sh_line,  f_ls(h1_past_st))
            line.set_width(h1_cur_sh_line,  h1_past_lw)
            line.set_extend(h1_cur_sh_line, extend.none)
            array.push(h1_past_sh_lns, h1_cur_sh_line)
            if array.size(h1_past_sh_lns) > h1_max_past
                line.delete(array.shift(h1_past_sh_lns))
        h1_cur_sh_val  := h1_ph
        h1_cur_sh_line := line.new(ph_bar, h1_ph, bar_index, h1_ph, color=h1_cur_sh_col, style=f_ls(h1_cur_st), width=h1_cur_lw, extend=extend.right)

    if not na(h1_pl)
        pl_bar = bar_index - h1_right
        if not na(h1_cur_sl_val) and not na(h1_cur_sl_line)
            line.set_color(h1_cur_sl_line,  h1_past_sl_col)
            line.set_style(h1_cur_sl_line,  f_ls(h1_past_st))
            line.set_width(h1_cur_sl_line,  h1_past_lw)
            line.set_extend(h1_cur_sl_line, extend.none)
            array.push(h1_past_sl_lns, h1_cur_sl_line)
            if array.size(h1_past_sl_lns) > h1_max_past
                line.delete(array.shift(h1_past_sl_lns))
        h1_cur_sl_val  := h1_pl
        h1_cur_sl_line := line.new(pl_bar, h1_pl, bar_index, h1_pl, color=h1_cur_sl_col, style=f_ls(h1_cur_st), width=h1_cur_lw, extend=extend.right)

    if not na(h1_cur_sh_line)
        line.set_x2(h1_cur_sh_line, bar_index)
    if not na(h1_cur_sl_line)
        line.set_x2(h1_cur_sl_line, bar_index)

// ═══════════════════════════════════════════════════════════════
//   RAGUL MODULE 5 — 15M SWING STRUCTURE
// ═══════════════════════════════════════════════════════════════

grp5 = "━━━ RAGUL M5 · 15M SWING STRUCTURE ━━━"
m15_on        = input.bool(true, "Enable 15M Swing Structure", group=grp5)
m15_left      = input.int(5, "Bars Left",  minval=1, group=grp5)
m15_right     = input.int(5, "Bars Right", minval=1, group=grp5)
m15_max_past  = input.int(5, "Max Past Levels", minval=1, maxval=20, group=grp5)

grp5a = "M5 · Current Level Style"
m15_cur_sh_col = input.color(color.new(#CDDC39,0), "Current High Colour", group=grp5a)
m15_cur_sl_col = input.color(color.new(#AB47BC,0), "Current Low Colour",  group=grp5a)
m15_cur_st     = input.string("solid", "Current Line Style", options=["solid","dashed","dotted"], group=grp5a)
m15_cur_lw     = input.int(2, "Current Line Width", minval=1, maxval=4, group=grp5a)

grp5b = "M5 · Past Level Style"
m15_past_sh_col = input.color(color.new(#CDDC39,70), "Past High Colour", group=grp5b)
m15_past_sl_col = input.color(color.new(#AB47BC,70), "Past Low Colour",  group=grp5b)
m15_past_st     = input.string("dashed", "Past Line Style", options=["solid","dashed","dotted"], group=grp5b)
m15_past_lw     = input.int(1, "Past Line Width", minval=1, maxval=4, group=grp5b)

m15_high = request.security(syminfo.tickerid, "15", high, lookahead=barmerge.lookahead_off)
m15_low  = request.security(syminfo.tickerid, "15", low,  lookahead=barmerge.lookahead_off)
m15_ph   = ta.pivothigh(m15_high, m15_left, m15_right)
m15_pl   = ta.pivotlow(m15_low,   m15_left, m15_right)

var float  m15_cur_sh_val  = na
var float  m15_cur_sl_val  = na
var line   m15_cur_sh_line = na
var line   m15_cur_sl_line = na
var line[] m15_past_sh_lns = array.new_line()
var line[] m15_past_sl_lns = array.new_line()

if m15_on
    if not na(m15_ph)
        ph_bar = bar_index - m15_right
        if not na(m15_cur_sh_val) and not na(m15_cur_sh_line)
            line.set_color(m15_cur_sh_line,  m15_past_sh_col)
            line.set_style(m15_cur_sh_line,  f_ls(m15_past_st))
            line.set_width(m15_cur_sh_line,  m15_past_lw)
            line.set_extend(m15_cur_sh_line, extend.none)
            array.push(m15_past_sh_lns, m15_cur_sh_line)
            if array.size(m15_past_sh_lns) > m15_max_past
                line.delete(array.shift(m15_past_sh_lns))
        m15_cur_sh_val  := m15_ph
        m15_cur_sh_line := line.new(ph_bar, m15_ph, bar_index, m15_ph, color=m15_cur_sh_col, style=f_ls(m15_cur_st), width=m15_cur_lw, extend=extend.right)

    if not na(m15_pl)
        pl_bar = bar_index - m15_right
        if not na(m15_cur_sl_val) and not na(m15_cur_sl_line)
            line.set_color(m15_cur_sl_line,  m15_past_sl_col)
            line.set_style(m15_cur_sl_line,  f_ls(m15_past_st))
            line.set_width(m15_cur_sl_line,  m15_past_lw)
            line.set_extend(m15_cur_sl_line, extend.none)
            array.push(m15_past_sl_lns, m15_cur_sl_line)
            if array.size(m15_past_sl_lns) > m15_max_past
                line.delete(array.shift(m15_past_sl_lns))
        m15_cur_sl_val  := m15_pl
        m15_cur_sl_line := line.new(pl_bar, m15_pl, bar_index, m15_pl, color=m15_cur_sl_col, style=f_ls(m15_cur_st), width=m15_cur_lw, extend=extend.right)

    if not na(m15_cur_sh_line)
        line.set_x2(m15_cur_sh_line, bar_index)
    if not na(m15_cur_sl_line)
        line.set_x2(m15_cur_sl_line, bar_index)

// ═══════════════════════════════════════════════════════════════
//   RAGUL MODULE 6 — 75M SWING STRUCTURE
// ═══════════════════════════════════════════════════════════════

grp6sw = "━━━ RAGUL M6 · 75M SWING STRUCTURE ━━━"
m75_on        = input.bool(true, "Enable 75M Swing Structure", group=grp6sw)
m75_left      = input.int(5, "Bars Left",  minval=1, group=grp6sw)
m75_right     = input.int(5, "Bars Right", minval=1, group=grp6sw)
m75_max_past  = input.int(5, "Max Past Levels", minval=1, maxval=20, group=grp6sw)

grp6swa = "M6 · Current Level Style"
m75_cur_sh_col = input.color(color.new(#FF5722,0), "Current High Colour", group=grp6swa)
m75_cur_sl_col = input.color(color.new(#29B6F6,0), "Current Low Colour",  group=grp6swa)
m75_cur_st     = input.string("solid", "Current Line Style", options=["solid","dashed","dotted"], group=grp6swa)
m75_cur_lw     = input.int(2, "Current Line Width", minval=1, maxval=4, group=grp6swa)

grp6swb = "M6 · Past Level Style"
m75_past_sh_col = input.color(color.new(#FF5722,70), "Past High Colour", group=grp6swb)
m75_past_sl_col = input.color(color.new(#29B6F6,70), "Past Low Colour",  group=grp6swb)
m75_past_st     = input.string("dashed", "Past Line Style", options=["solid","dashed","dotted"], group=grp6swb)
m75_past_lw     = input.int(1, "Past Line Width", minval=1, maxval=4, group=grp6swb)

m75_high = request.security(syminfo.tickerid, "75", high, lookahead=barmerge.lookahead_off)
m75_low  = request.security(syminfo.tickerid, "75", low,  lookahead=barmerge.lookahead_off)
m75_ph   = ta.pivothigh(m75_high, m75_left, m75_right)
m75_pl   = ta.pivotlow(m75_low,   m75_left, m75_right)

var float  m75_cur_sh_val  = na
var float  m75_cur_sl_val  = na
var line   m75_cur_sh_line = na
var line   m75_cur_sl_line = na
var line[] m75_past_sh_lns = array.new_line()
var line[] m75_past_sl_lns = array.new_line()

if m75_on
    if not na(m75_ph)
        ph_bar = bar_index - m75_right
        if not na(m75_cur_sh_val) and not na(m75_cur_sh_line)
            line.set_color(m75_cur_sh_line,  m75_past_sh_col)
            line.set_style(m75_cur_sh_line,  f_ls(m75_past_st))
            line.set_width(m75_cur_sh_line,  m75_past_lw)
            line.set_extend(m75_cur_sh_line, extend.none)
            array.push(m75_past_sh_lns, m75_cur_sh_line)
            if array.size(m75_past_sh_lns) > m75_max_past
                line.delete(array.shift(m75_past_sh_lns))
        m75_cur_sh_val  := m75_ph
        m75_cur_sh_line := line.new(ph_bar, m75_ph, bar_index, m75_ph, color=m75_cur_sh_col, style=f_ls(m75_cur_st), width=m75_cur_lw, extend=extend.right)

    if not na(m75_pl)
        pl_bar = bar_index - m75_right
        if not na(m75_cur_sl_val) and not na(m75_cur_sl_line)
            line.set_color(m75_cur_sl_line,  m75_past_sl_col)
            line.set_style(m75_cur_sl_line,  f_ls(m75_past_st))
            line.set_width(m75_cur_sl_line,  m75_past_lw)
            line.set_extend(m75_cur_sl_line, extend.none)
            array.push(m75_past_sl_lns, m75_cur_sl_line)
            if array.size(m75_past_sl_lns) > m75_max_past
                line.delete(array.shift(m75_past_sl_lns))
        m75_cur_sl_val  := m75_pl
        m75_cur_sl_line := line.new(pl_bar, m75_pl, bar_index, m75_pl, color=m75_cur_sl_col, style=f_ls(m75_cur_st), width=m75_cur_lw, extend=extend.right)

    if not na(m75_cur_sh_line)
        line.set_x2(m75_cur_sh_line, bar_index)
    if not na(m75_cur_sl_line)
        line.set_x2(m75_cur_sl_line, bar_index)

// ═══════════════════════════════════════════════════════════════
//   RAGUL UNIFIED SMART LABEL ENGINE
// ═══════════════════════════════════════════════════════════════

var float[]  ule_price = array.new_float()
var string[] ule_txt   = array.new_string()
var color[]  ule_col   = array.new_color()
var label[]  ule_lbls  = array.new_label()

if barstate.islast
    for lb in ule_lbls
        label.delete(lb)
    array.clear(ule_lbls)
    array.clear(ule_price)
    array.clear(ule_txt)
    array.clear(ule_col)

    if pdpwpm_on
        if show_PDH and not na(d_h)
            array.push(ule_price, d_h)
            array.push(ule_txt, "PDH " + str.tostring(d_h, format.mintick))
            array.push(ule_col, pdh_col)
        if show_PDL and not na(d_l)
            array.push(ule_price, d_l)
            array.push(ule_txt, "PDL " + str.tostring(d_l, format.mintick))
            array.push(ule_col, pdl_col)
        if show_PDC and not na(d_c)
            array.push(ule_price, d_c)
            array.push(ule_txt, "PDC " + str.tostring(d_c, format.mintick))
            array.push(ule_col, pdc_col)
        if show_PDO and not na(d_o)
            array.push(ule_price, d_o)
            array.push(ule_txt, "PDO " + str.tostring(d_o, format.mintick))
            array.push(ule_col, pdo_col)
        if show_PDEQ and not na(pd_eq)
            array.push(ule_price, pd_eq)
            array.push(ule_txt, "EQ " + str.tostring(pd_eq, format.mintick))
            array.push(ule_col, pdeq_col)
        if show_PWH and not na(w_h)
            array.push(ule_price, w_h)
            array.push(ule_txt, "PWH " + str.tostring(w_h, format.mintick))
            array.push(ule_col, pwh_col)
        if show_PWL and not na(w_l)
            array.push(ule_price, w_l)
            array.push(ule_txt, "PWL " + str.tostring(w_l, format.mintick))
            array.push(ule_col, pwl_col)
        if show_PWC and not na(w_c)
            array.push(ule_price, w_c)
            array.push(ule_txt, "PWC " + str.tostring(w_c, format.mintick))
            array.push(ule_col, pwc_col)
        if show_PWO and not na(w_o)
            array.push(ule_price, w_o)
            array.push(ule_txt, "PWO " + str.tostring(w_o, format.mintick))
            array.push(ule_col, pwo_col)
        if show_PMH and not na(m_h)
            array.push(ule_price, m_h)
            array.push(ule_txt, "PMH " + str.tostring(m_h, format.mintick))
            array.push(ule_col, pmh_col)
        if show_PML and not na(m_l)
            array.push(ule_price, m_l)
            array.push(ule_txt, "PML " + str.tostring(m_l, format.mintick))
            array.push(ule_col, pml_col)
        if show_PMC and not na(m_c)
            array.push(ule_price, m_c)
            array.push(ule_txt, "PMC " + str.tostring(m_c, format.mintick))
            array.push(ule_col, pmc_col)
        if show_PMO and not na(m_o)
            array.push(ule_price, m_o)
            array.push(ule_txt, "PMO " + str.tostring(m_o, format.mintick))
            array.push(ule_col, pmo_col)

    if show_today
        if show_TDH and not na(today_high)
            array.push(ule_price, today_high)
            array.push(ule_txt, "TDH " + str.tostring(today_high, format.mintick))
            array.push(ule_col, tdh_col_rt)
        if show_TDL and not na(today_low)
            array.push(ule_price, today_low)
            array.push(ule_txt, "TDL " + str.tostring(today_low, format.mintick))
            array.push(ule_col, tdl_col_rt)

    if show_td1h
        if show_TD1HH and not na(td1h_high)
            array.push(ule_price, td1h_high)
            array.push(ule_txt, "1H TDH " + str.tostring(td1h_high, format.mintick))
            array.push(ule_col, col_TD1HH)
        if show_TD1HL and not na(td1h_low)
            array.push(ule_price, td1h_low)
            array.push(ule_txt, "1H TDL " + str.tostring(td1h_low, format.mintick))
            array.push(ule_col, col_TD1HL)

    if show_td15m
        if show_TD15MH and not na(td15m_high)
            array.push(ule_price, td15m_high)
            array.push(ule_txt, "15M TDH " + str.tostring(td15m_high, format.mintick))
            array.push(ule_col, col_TD15MH)
        if show_TD15ML and not na(td15m_low)
            array.push(ule_price, td15m_low)
            array.push(ule_txt, "15M TDL " + str.tostring(td15m_low, format.mintick))
            array.push(ule_col, col_TD15ML)

    if show_td75m
        if show_TD75MH and not na(td75m_high)
            array.push(ule_price, td75m_high)
            array.push(ule_txt, "75M TDH " + str.tostring(td75m_high, format.mintick))
            array.push(ule_col, col_TD75MH)
        if show_TD75ML and not na(td75m_low)
            array.push(ule_price, td75m_low)
            array.push(ule_txt, "75M TDL " + str.tostring(td75m_low, format.mintick))
            array.push(ule_col, col_TD75ML)

    if rv5_on
        if not na(rv5_cur_sh_val)
            array.push(ule_price, rv5_cur_sh_val)
            array.push(ule_txt, "SH " + str.tostring(rv5_cur_sh_val, format.mintick))
            array.push(ule_col, rv5_cur_sh_col)
        if not na(rv5_cur_sl_val)
            array.push(ule_price, rv5_cur_sl_val)
            array.push(ule_txt, "SL " + str.tostring(rv5_cur_sl_val, format.mintick))
            array.push(ule_col, rv5_cur_sl_col)

    if h1_on
        if not na(h1_cur_sh_val)
            array.push(ule_price, h1_cur_sh_val)
            array.push(ule_txt, "1H High " + str.tostring(h1_cur_sh_val, format.mintick))
            array.push(ule_col, h1_cur_sh_col)
        if not na(h1_cur_sl_val)
            array.push(ule_price, h1_cur_sl_val)
            array.push(ule_txt, "1H Low " + str.tostring(h1_cur_sl_val, format.mintick))
            array.push(ule_col, h1_cur_sl_col)

    if m15_on
        if not na(m15_cur_sh_val)
            array.push(ule_price, m15_cur_sh_val)
            array.push(ule_txt, "15M High " + str.tostring(m15_cur_sh_val, format.mintick))
            array.push(ule_col, m15_cur_sh_col)
        if not na(m15_cur_sl_val)
            array.push(ule_price, m15_cur_sl_val)
            array.push(ule_txt, "15M Low " + str.tostring(m15_cur_sl_val, format.mintick))
            array.push(ule_col, m15_cur_sl_col)

    if m75_on
        if not na(m75_cur_sh_val)
            array.push(ule_price, m75_cur_sh_val)
            array.push(ule_txt, "75M High " + str.tostring(m75_cur_sh_val, format.mintick))
            array.push(ule_col, m75_cur_sh_col)
        if not na(m75_cur_sl_val)
            array.push(ule_price, m75_cur_sl_val)
            array.push(ule_txt, "75M Low " + str.tostring(m75_cur_sl_val, format.mintick))
            array.push(ule_col, m75_cur_sl_col)

    int ule_n = array.size(ule_price)
    if ule_n > 1
        for i = 0 to ule_n - 2
            for j = 0 to ule_n - 2 - i
                float pa = array.get(ule_price, j)
                float pb = array.get(ule_price, j + 1)
                if pa > pb
                    array.set(ule_price, j,     pb)
                    array.set(ule_price, j + 1, pa)
                    string sa = array.get(ule_txt, j)
                    string sb = array.get(ule_txt, j + 1)
                    array.set(ule_txt, j,     sb)
                    array.set(ule_txt, j + 1, sa)
                    color ca = array.get(ule_col, j)
                    color cb = array.get(ule_col, j + 1)
                    array.set(ule_col, j,     cb)
                    array.set(ule_col, j + 1, ca)

    float crange = chart_high_300 - chart_low_300
    if crange <= 0
        crange := close * 0.05
    float tol = crange * (lbl_price_tol / 100)

    int  base_x  = lbl_anchor == "Left Edge" ? bar_index - 490 : bar_index + 2
    bool is_left = lbl_anchor == "Left Edge"

    int i = 0
    while i < ule_n
        float group_price = array.get(ule_price, i)
        int   slot        = 0
        int   j           = i
        while j < ule_n and math.abs(array.get(ule_price, j) - group_price) <= tol
            float  lp = array.get(ule_price, j)
            string lt = array.get(ule_txt,   j)
            color  lc = array.get(ule_col,   j)
            int    lx = base_x + slot * lbl_stack_gap
            array.push(ule_lbls,
                 label.new(lx, lp, lt,
                      color     = color.new(lc, 75),
                      textcolor = lc,
                      style     = is_left ? label.style_label_right : label.style_label_left,
                      size      = size.small))
            slot += 1
            j    += 1
        i := j

// ═══════════════════════════════════════════════════════════════
//   RAGUL STATUS TABLE
// ═══════════════════════════════════════════════════════════════

grp_tbl    = "━━━ RAGUL · STATUS TABLE ━━━"
show_table = input.bool(true, "Show Status Table", group=grp_tbl)
tbl_pos    = input.string("top_right", "Table Position", options=["top_right","top_left","bottom_right","bottom_left"], group=grp_tbl)

if show_table and barstate.islast
    tbl = table.new(f_tbl_pos(tbl_pos), 2, 11,
         bgcolor      = color.new(color.black, 10),
         border_color = color.new(color.gray,  50), border_width = 1,
         frame_color  = color.new(color.gray,  40), frame_width  = 1)
    table.cell(tbl, 0, 0,  "RAGUL Module",             text_color=color.silver, text_size=size.small, bgcolor=color.new(color.navy,10))
    table.cell(tbl, 1, 0,  "Status",                   text_color=color.silver, text_size=size.small, bgcolor=color.new(color.navy,10))
    table.cell(tbl, 0, 1,  "M1  · Prev Period Levels", text_color=color.white,  text_size=size.small)
    table.cell(tbl, 1, 1,  pdpwpm_on  ? "ON ✓" : "OFF ✗", text_color=pdpwpm_on  ? color.green : color.red, text_size=size.small)
    table.cell(tbl, 0, 2,  "M1B · Today Day H/L",      text_color=color.white,  text_size=size.small)
    table.cell(tbl, 1, 2,  show_today ? "ON ✓" : "OFF ✗", text_color=show_today ? color.green : color.red, text_size=size.small)
    table.cell(tbl, 0, 3,  "M1C · Today 1H H/L",       text_color=color.white,  text_size=size.small)
    table.cell(tbl, 1, 3,  show_td1h  ? "ON ✓" : "OFF ✗", text_color=show_td1h  ? color.green : color.red, text_size=size.small)
    table.cell(tbl, 0, 4,  "M1D · Today 15M H/L",      text_color=color.white,  text_size=size.small)
    table.cell(tbl, 1, 4,  show_td15m ? "ON ✓" : "OFF ✗", text_color=show_td15m ? color.green : color.red, text_size=size.small)
    table.cell(tbl, 0, 5,  "M1E · Today 75M H/L",      text_color=color.white,  text_size=size.small)
    table.cell(tbl, 1, 5,  show_td75m ? "ON ✓" : "OFF ✗", text_color=show_td75m ? color.green : color.red, text_size=size.small)
    table.cell(tbl, 0, 6,  "M2  · Chart TF Swing",     text_color=color.white,  text_size=size.small)
    table.cell(tbl, 1, 6,  rv5_on     ? "ON ✓" : "OFF ✗", text_color=rv5_on     ? color.green : color.red, text_size=size.small)
    table.cell(tbl, 0, 7,  "M3  · Swing + Patterns",   text_color=color.white,  text_size=size.small)
    table.cell(tbl, 1, 7,  m3_on      ? "ON ✓" : "OFF ✗", text_color=m3_on      ? color.green : color.red, text_size=size.small)
    table.cell(tbl, 0, 8,  "M4  · 1H Swing",           text_color=color.white,  text_size=size.small)
    table.cell(tbl, 1, 8,  h1_on      ? "ON ✓" : "OFF ✗", text_color=h1_on      ? color.green : color.red, text_size=size.small)
    table.cell(tbl, 0, 9,  "M5  · 15M Swing",          text_color=color.white,  text_size=size.small)
    table.cell(tbl, 1, 9,  m15_on     ? "ON ✓" : "OFF ✗", text_color=m15_on     ? color.green : color.red, text_size=size.small)
    table.cell(tbl, 0, 10, "M6  · 75M Swing",          text_color=color.white,  text_size=size.small)
    table.cell(tbl, 1, 10, m75_on     ? "ON ✓" : "OFF ✗", text_color=m75_on     ? color.green : color.red, text_size=size.small)
````
