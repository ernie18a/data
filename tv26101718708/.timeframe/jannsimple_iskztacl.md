# JannSimple

- url: https://www.tradingview.com/script/iSKzTAcL-JannSimple/
- type: indicator
- pine_id: PUB;a8fa7a3fbc594d7fb2a0218a77841c08
- version: 1.0

## Description

UPDATE >
 removed orb
 removed signal
 checklist is now based on candle closure and toggleable (in settings)
 removed lots of unnecessary code

## Source Code

````pine
//@version=5
indicator("JannSimple", overlay=true, max_labels_count=500, max_lines_count=100)

// ═══════════════════════════════════════════════════════
//  EMA
// ═══════════════════════════════════════════════════════
g_ema    = "EMA"
ema5_len = input.int(5,        "5 EMA Length",  minval=1, maxval=50,  group=g_ema)
ema9_len = input.int(9,        "9 EMA Length",  minval=1, maxval=50,  group=g_ema)
ema5_col = input.color(#ffffff,"5 EMA Color",                         group=g_ema)
ema9_col = input.color(#f48fb1,"9 EMA Color",                         group=g_ema)
ema5_op  = input.int(0,        "5 EMA Opacity", minval=0, maxval=100, group=g_ema, tooltip="0 = solid · 100 = hidden")
ema9_op  = input.int(0,        "9 EMA Opacity", minval=0, maxval=100, group=g_ema, tooltip="0 = solid · 100 = hidden")

// ═══════════════════════════════════════════════════════
//  VWAP
// ═══════════════════════════════════════════════════════
g_vwap    = "VWAP"
show_vwap = input.bool(true,     "Show VWAP",    group=g_vwap)
vwap_col  = input.color(#5b9cf6, "VWAP Color",   group=g_vwap)
vwap_op   = input.int(0,         "VWAP Opacity", minval=0, maxval=100, group=g_vwap, tooltip="0 = solid · 100 = hidden")

// ═══════════════════════════════════════════════════════
//  SIGNALS
// ═══════════════════════════════════════════════════════
g_sig         = "Signals"
thresh_min    = input.int(12,    "Min Score",           minval=1, maxval=16, group=g_sig, tooltip="Minimum score out of 16 required to fire a signal.")
cross_window  = input.int(3,     "Confluence Window",   minval=1, maxval=10, group=g_sig, tooltip="EMA cross and VWAP cross must both happen within this many bars.")
require_both  = input.bool(true, "Require EMA + VWAP Cross", group=g_sig,   tooltip="Both events must occur within the confluence window. Greatly reduces noise.")
cooldown_bars = input.int(2,     "Cooldown Bars",       minval=1, maxval=20, group=g_sig, tooltip="Minimum bars between signals for the same direction.")
show_score    = input.bool(true, "Show Score on Label", group=g_sig)

// ═══════════════════════════════════════════════════════
//  FILTERS
// ═══════════════════════════════════════════════════════
g_filters    = "Filters"
use_time     = input.bool(true,  "Enable Time Filter",        group=g_filters, tooltip="Blocks signals outside session windows.")
sess1_start  = input.int(930,    "AM Session Start (HHMM ET)", minval=0, maxval=2359, group=g_filters)
sess1_end    = input.int(1130,   "AM Session End   (HHMM ET)", minval=0, maxval=2359, group=g_filters)
sess2_start  = input.int(1330,   "PM Session Start (HHMM ET)", minval=0, maxval=2359, group=g_filters)
sess2_end    = input.int(1530,   "PM Session End   (HHMM ET)", minval=0, maxval=2359, group=g_filters)
use_trend    = input.bool(true,  "Enable 15m Trend Filter",   group=g_filters, tooltip="Long blocked if 15m close below 15m EMA. Short blocked if above.")
trend_len    = input.int(20,     "15m Trend EMA Length",      minval=5, maxval=50, group=g_filters)

// ═══════════════════════════════════════════════════════
//  SIGNAL LABELS
// ═══════════════════════════════════════════════════════
g_lbl     = "Signal Labels"
long_bg   = input.color(#ffffff, "Long Background",  group=g_lbl)
long_txt  = input.color(#000000, "Long Text",        group=g_lbl)
short_bg  = input.color(#2e2e2e, "Short Background", group=g_lbl)
short_txt = input.color(#ffffff, "Short Text",       group=g_lbl)

// ═══════════════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════════════
g_tbl          = "Dashboard"
show_dash      = input.bool(true,   "Show Dashboard",       group=g_tbl)
tbl_hdr_bg     = input.color(#0d1520, "Header Background",  group=g_tbl)
tbl_hdr_txt    = input.color(#3a6070, "Header Text",        group=g_tbl)
tbl_long_hdr   = input.color(#00c853, "Long Header",        group=g_tbl)
tbl_short_hdr  = input.color(#ff1744, "Short Header",       group=g_tbl)
tbl_row_bg     = input.color(#0a0f16, "Row Background",     group=g_tbl)
tbl_row_txt    = input.color(#5a7080, "Row Text",           group=g_tbl)
tbl_yes_long   = input.color(#00ff9d, "YES Long",           group=g_tbl)
tbl_yes_short  = input.color(#ff4f4f, "YES Short",          group=g_tbl)
tbl_no         = input.color(#1e3040, "No",                 group=g_tbl)
tbl_score_bg   = input.color(#0d1520, "Score Background",   group=g_tbl)
tbl_score_txt  = input.color(#ffffff, "Score Label",        group=g_tbl)
tbl_score_long = input.color(#00c853, "Score Long",         group=g_tbl)
tbl_score_shrt = input.color(#ff1744, "Score Short",        group=g_tbl)

// ═══════════════════════════════════════════════════════
//  PIVOT ZONES
// ═══════════════════════════════════════════════════════
g_pvt      = "Pivot Zones"
show_pivot = input.bool(true,     "Show Daily Pivots", group=g_pvt)
pvt_p_col  = input.color(#ffffff, "P Color",           group=g_pvt)
pvt_r_col  = input.color(#f8bbd0, "R1/R2 Color",       group=g_pvt)
pvt_s_col  = input.color(#fff9c4, "S1/S2 Color",       group=g_pvt)

// ═══════════════════════════════════════════════════════
//  PSYCHOLOGICAL LEVELS
// ═══════════════════════════════════════════════════════
g_psy       = "Psychological Levels"
show_strong = input.bool(true,     "Show Strong (whole numbers)",   group=g_psy)
show_medium = input.bool(true,     "Show Medium (half numbers)",    group=g_psy)
show_weak   = input.bool(false,    "Show Weak   (quarter numbers)", group=g_psy)
psy_s_col   = input.color(#00e676, "Strong Color", group=g_psy)
psy_m_col   = input.color(#90bff9, "Medium Color", group=g_psy)
psy_w_col   = input.color(#9c27b0, "Weak Color",   group=g_psy)
psy_s_op    = input.int(0,  "Strong Opacity", minval=0, maxval=100, group=g_psy, tooltip="0 = solid · 100 = hidden")
psy_m_op    = input.int(20, "Medium Opacity", minval=0, maxval=100, group=g_psy)
psy_w_op    = input.int(40, "Weak Opacity",   minval=0, maxval=100, group=g_psy)

// ═══════════════════════════════════════════════════════
//  CALCULATIONS
// ═══════════════════════════════════════════════════════
ema5     = ta.ema(close, ema5_len)
ema9     = ta.ema(close, ema9_len)
vwap_val = ta.vwap(hlc3)

// Time filter
bar_hhmm   = hour(time, "America/New_York") * 100 + minute(time, "America/New_York")
in_sess1   = bar_hhmm >= sess1_start and bar_hhmm < sess1_end
in_sess2   = bar_hhmm >= sess2_start and bar_hhmm < sess2_end
in_session = not use_time or (in_sess1 or in_sess2)

// 15m trend filter
htf_close   = request.security(syminfo.tickerid, "15", close, lookahead=barmerge.lookahead_off)
htf_ema     = request.security(syminfo.tickerid, "15", ta.ema(close, trend_len), lookahead=barmerge.lookahead_off)
htf_bull    = htf_close > htf_ema
htf_bear    = htf_close < htf_ema
trend_long  = not use_trend or htf_bull
trend_short = not use_trend or htf_bear

// Base conditions
bull_cross   = ta.crossover(ema5, ema9)
bear_cross   = ta.crossunder(ema5, ema9)
vwap_reclaim = close > vwap_val and close[1] < vwap_val[1]
vwap_reject  = close < vwap_val and close[1] > vwap_val[1]
above_ema    = ema5 > ema9
below_ema    = ema5 < ema9
above_vwap   = close > vwap_val
below_vwap   = close < vwap_val

// Candle confirmation
bull_body    = close > open and (close - open) > (high - low) * 0.6
bear_body    = close < open and (open - close) > (high - low) * 0.6
bull_engulf  = close > open and close > open[1] and open < close[1] and close[1] < open[1] and close > vwap_val
bear_engulf  = close < open and close < open[1] and open > close[1] and close[1] > open[1] and close < vwap_val
bull_confirm = bull_body or bull_engulf
bear_confirm = bear_body or bear_engulf

vol_avg   = ta.sma(volume, 20)
vol_surge = volume > vol_avg * 1.5

// Confluence window
var bool bc_rec  = false
var bool bec_rec = false
var bool brc_rec = false
var bool bre_rec = false
bc_rec  := false
bec_rec := false
brc_rec := false
bre_rec := false
for j = 0 to cross_window - 1
    if bull_cross[j]
        bc_rec := true
    if bear_cross[j]
        bec_rec := true
    if vwap_reclaim[j]
        brc_rec := true
    if vwap_reject[j]
        bre_rec := true

long_raw  = require_both ? (bc_rec and brc_rec) : (bull_cross or vwap_reclaim)
short_raw = require_both ? (bec_rec and bre_rec) : (bear_cross or vwap_reject)
long_new  = long_raw  and not long_raw[1]
short_new = short_raw and not short_raw[1]

// Cooldown
var int since_long  = 999
var int since_short = 999
since_long  := since_long  + 1
since_short := since_short + 1
cd_long  = since_long  > cooldown_bars
cd_short = since_short > cooldown_bars

// Psychological levels
f_psych(p, n, inc) =>
    n2   = p < 1.0 ? n + 1 : n
    unit = math.pow(10, int(math.log10(p)) - n2 + 1)
    int(p / unit) * unit + unit * inc

ps_above = f_psych(close, 1, 1.0)
ps_half  = f_psych(close, 1, 0.5)
ps_below = f_psych(close, 1, 0.0)
pm_above = f_psych(close, 2, 1.0)
pm_half  = f_psych(close, 2, 0.5)
pm_below = f_psych(close, 2, 0.0)
pw_above = f_psych(close, 3, 1.0)
pw_below = f_psych(close, 3, 0.0)

ptol       = close * 0.002
near_psych = math.abs(close - ps_above) < ptol or math.abs(close - ps_below) < ptol or math.abs(close - ps_half) < ptol or math.abs(close - pm_above) < ptol or math.abs(close - pm_below) < ptol or math.abs(close - pm_half) < ptol

// Daily pivots
d_high  = request.security(syminfo.tickerid, "D", high[1],  lookahead=barmerge.lookahead_on)
d_low   = request.security(syminfo.tickerid, "D", low[1],   lookahead=barmerge.lookahead_on)
d_close = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)
pp      = (d_high + d_low + d_close) / 3
r1      = 2 * pp - d_low
r2      = pp + (d_high - d_low)
s1      = 2 * pp - d_high
s2      = pp - (d_high - d_low)
pvt_tol  = (d_high - d_low) * 0.08
near_sup = math.abs(close - pp) < pvt_tol or math.abs(close - s1) < pvt_tol or math.abs(close - s2) < pvt_tol
near_res = math.abs(close - pp) < pvt_tol or math.abs(close - r1) < pvt_tol or math.abs(close - r2) < pvt_tol

// Scoring
l_score = (above_ema ? 3 : 0) + (above_vwap ? 3 : 0) + (vwap_reclaim ? 2 : 0) + (bull_confirm ? 2 : 0) + (near_sup ? 2 : 0) + (near_psych ? 2 : 0) + (htf_bull ? 1 : 0) + (vol_surge ? 1 : 0)
s_score = (below_ema ? 3 : 0) + (below_vwap ? 3 : 0) + (vwap_reject  ? 2 : 0) + (bear_confirm ? 2 : 0) + (near_res ? 2 : 0) + (near_psych ? 2 : 0) + (htf_bear ? 1 : 0) + (vol_surge ? 1 : 0)

// Final trigger
l_trigger = long_new  and l_score >= thresh_min and trend_long  and in_session and cd_long
s_trigger = short_new and s_score >= thresh_min and trend_short and in_session and cd_short

if l_trigger
    since_long := 0
if s_trigger
    since_short := 0

// HIGH qualifier
l_location = htf_bull and (near_sup or near_psych)
s_location = htf_bear and (near_res or near_psych)
l_is_high  = l_score == thresh_min and l_location
s_is_high  = s_score == thresh_min and s_location
l_is_clean = l_score > thresh_min
s_is_clean = s_score > thresh_min
l_show     = l_trigger and (l_is_clean or l_is_high)
s_show     = s_trigger and (s_is_clean or s_is_high)

// ═══════════════════════════════════════════════════════
//  PLOTS
// ═══════════════════════════════════════════════════════
plot(ema5, "5 EMA", color=color.new(ema5_col, ema5_op), linewidth=2)
plot(ema9, "9 EMA", color=color.new(ema9_col, ema9_op), linewidth=2)
plot(show_vwap ? vwap_val : na, "VWAP", color=color.new(vwap_col, vwap_op), linewidth=2)

// Psych level circles
plot(show_strong ? ps_above : na, "S Above", color=color.new(psy_s_col, psy_s_op), linewidth=3, style=plot.style_circles, display=display.pane)
plot(show_strong ? ps_half  : na, "S Half",  color=color.new(psy_s_col, psy_s_op), linewidth=3, style=plot.style_circles, display=display.pane)
plot(show_strong ? ps_below : na, "S Below", color=color.new(psy_s_col, psy_s_op), linewidth=3, style=plot.style_circles, display=display.pane)
plot(show_medium ? pm_above : na, "M Above", color=color.new(psy_m_col, psy_m_op), linewidth=2, style=plot.style_circles, display=display.pane)
plot(show_medium ? pm_half  : na, "M Half",  color=color.new(psy_m_col, psy_m_op), linewidth=2, style=plot.style_circles, display=display.pane)
plot(show_medium ? pm_below : na, "M Below", color=color.new(psy_m_col, psy_m_op), linewidth=2, style=plot.style_circles, display=display.pane)
plot(show_weak   ? pw_above : na, "W Above", color=color.new(psy_w_col, psy_w_op), linewidth=1, style=plot.style_circles, display=display.pane)
plot(show_weak   ? pw_below : na, "W Below", color=color.new(psy_w_col, psy_w_op), linewidth=1, style=plot.style_circles, display=display.pane)

// Hidden pivot scale plots
plot(show_pivot ? pp : na, "Pivot P",  color=color.new(pvt_p_col, 99), linewidth=1)
plot(show_pivot ? r1 : na, "Pivot R1", color=color.new(pvt_r_col, 99), linewidth=1)
plot(show_pivot ? r2 : na, "Pivot R2", color=color.new(pvt_r_col, 99), linewidth=1)
plot(show_pivot ? s1 : na, "Pivot S1", color=color.new(pvt_s_col, 99), linewidth=1)
plot(show_pivot ? s2 : na, "Pivot S2", color=color.new(pvt_s_col, 99), linewidth=1)

// Pivot lines — dotted, right only
var line ln_pp = line.new(bar_index, pp, bar_index+1, pp, extend=extend.right, style=line.style_dotted, color=color.new(pvt_p_col, 15), width=1)
var line ln_r1 = line.new(bar_index, r1, bar_index+1, r1, extend=extend.right, style=line.style_dotted, color=color.new(pvt_r_col, 30), width=1)
var line ln_r2 = line.new(bar_index, r2, bar_index+1, r2, extend=extend.right, style=line.style_dotted, color=color.new(pvt_r_col, 50), width=1)
var line ln_s1 = line.new(bar_index, s1, bar_index+1, s1, extend=extend.right, style=line.style_dotted, color=color.new(pvt_s_col, 30), width=1)
var line ln_s2 = line.new(bar_index, s2, bar_index+1, s2, extend=extend.right, style=line.style_dotted, color=color.new(pvt_s_col, 50), width=1)

if show_pivot
    line.set_x1(ln_pp, bar_index)
    line.set_y1(ln_pp, pp)
    line.set_y2(ln_pp, pp)
    line.set_color(ln_pp, color.new(pvt_p_col, 15))
    line.set_x1(ln_r1, bar_index)
    line.set_y1(ln_r1, r1)
    line.set_y2(ln_r1, r1)
    line.set_color(ln_r1, color.new(pvt_r_col, 30))
    line.set_x1(ln_r2, bar_index)
    line.set_y1(ln_r2, r2)
    line.set_y2(ln_r2, r2)
    line.set_color(ln_r2, color.new(pvt_r_col, 50))
    line.set_x1(ln_s1, bar_index)
    line.set_y1(ln_s1, s1)
    line.set_y2(ln_s1, s1)
    line.set_color(ln_s1, color.new(pvt_s_col, 30))
    line.set_x1(ln_s2, bar_index)
    line.set_y1(ln_s2, s2)
    line.set_y2(ln_s2, s2)
    line.set_color(ln_s2, color.new(pvt_s_col, 50))
else
    line.set_color(ln_pp, color.new(color.black, 100))
    line.set_color(ln_r1, color.new(color.black, 100))
    line.set_color(ln_r2, color.new(color.black, 100))
    line.set_color(ln_s1, color.new(color.black, 100))
    line.set_color(ln_s2, color.new(color.black, 100))

// Signal labels
if l_show
    l_pfx = l_is_high ? "HIGH " : ""
    l_lbl = show_score ? l_pfx + "Long\n" + str.tostring(l_score) + "/16" : l_pfx + "Long"
    label.new(bar_index, low * 0.9995, text=l_lbl, color=long_bg, textcolor=long_txt, style=label.style_label_up, size=size.small)

if s_show
    s_pfx = s_is_high ? "HIGH " : ""
    s_lbl = show_score ? s_pfx + "Short\n" + str.tostring(s_score) + "/16" : s_pfx + "Short"
    label.new(bar_index, high * 1.0005, text=s_lbl, color=short_bg, textcolor=short_txt, style=label.style_label_down, size=size.small)

// ═══════════════════════════════════════════════════════
//  DASHBOARD TABLE — updates on candle close only
// ═══════════════════════════════════════════════════════
var table dash = table.new(position.top_right, 3, 10, bgcolor=color.new(#080c10, 10), border_color=color.new(#1a2a38, 0), border_width=1, frame_color=color.new(#1a2a38, 0), frame_width=1)

// Candle-close locked values — only update when barstate.isconfirmed
var bool lv0 = false
var bool lv1 = false
var bool lv2 = false
var bool lv3 = false
var bool lv4 = false
var bool lv5 = false
var bool lv6 = false
var bool lv7 = false
var bool sv0 = false
var bool sv1 = false
var bool sv2 = false
var bool sv3 = false
var bool sv4 = false
var bool sv5 = false
var bool sv6 = false
var bool sv7 = false
var int  lsc = 0
var int  ssc = 0

if barstate.isconfirmed
    lv0 := above_ema
    lv1 := above_vwap
    lv2 := vwap_reclaim
    lv3 := bull_confirm
    lv4 := near_sup
    lv5 := near_psych
    lv6 := htf_bull
    lv7 := vol_surge
    sv0 := below_ema
    sv1 := below_vwap
    sv2 := vwap_reject
    sv3 := bear_confirm
    sv4 := near_res
    sv5 := near_psych
    sv6 := htf_bear
    sv7 := vol_surge
    lsc := l_score
    ssc := s_score

if show_dash
    table.cell(dash, 0, 0, "CONDITION",   text_color=tbl_hdr_txt,   text_size=size.small, bgcolor=tbl_hdr_bg)
    table.cell(dash, 1, 0, "Long",        text_color=tbl_long_hdr,  text_size=size.small, bgcolor=tbl_hdr_bg)
    table.cell(dash, 2, 0, "Short",       text_color=tbl_short_hdr, text_size=size.small, bgcolor=tbl_hdr_bg)

    table.cell(dash, 0, 1, "EMA Aligned (+3)", text_color=tbl_row_txt, text_size=size.small, bgcolor=tbl_row_bg)
    table.cell(dash, 1, 1, lv0 ? "YES" : "-",  text_color=lv0 ? tbl_yes_long  : tbl_no, text_size=size.small, bgcolor=tbl_row_bg)
    table.cell(dash, 2, 1, sv0 ? "YES" : "-",  text_color=sv0 ? tbl_yes_short : tbl_no, text_size=size.small, bgcolor=tbl_row_bg)

    table.cell(dash, 0, 2, "VWAP Side   (+3)", text_color=tbl_row_txt, text_size=size.small, bgcolor=tbl_row_bg)
    table.cell(dash, 1, 2, lv1 ? "YES" : "-",  text_color=lv1 ? tbl_yes_long  : tbl_no, text_size=size.small, bgcolor=tbl_row_bg)
    table.cell(dash, 2, 2, sv1 ? "YES" : "-",  text_color=sv1 ? tbl_yes_short : tbl_no, text_size=size.small, bgcolor=tbl_row_bg)

    table.cell(dash, 0, 3, "VWAP Event  (+2)", text_color=tbl_row_txt, text_size=size.small, bgcolor=tbl_row_bg)
    table.cell(dash, 1, 3, lv2 ? "YES" : "-",  text_color=lv2 ? tbl_yes_long  : tbl_no, text_size=size.small, bgcolor=tbl_row_bg)
    table.cell(dash, 2, 3, sv2 ? "YES" : "-",  text_color=sv2 ? tbl_yes_short : tbl_no, text_size=size.small, bgcolor=tbl_row_bg)

    table.cell(dash, 0, 4, "Candle Conf (+2)", text_color=tbl_row_txt, text_size=size.small, bgcolor=tbl_row_bg)
    table.cell(dash, 1, 4, lv3 ? "YES" : "-",  text_color=lv3 ? tbl_yes_long  : tbl_no, text_size=size.small, bgcolor=tbl_row_bg)
    table.cell(dash, 2, 4, sv3 ? "YES" : "-",  text_color=sv3 ? tbl_yes_short : tbl_no, text_size=size.small, bgcolor=tbl_row_bg)

    table.cell(dash, 0, 5, "Pivot Zone  (+2)", text_color=tbl_row_txt, text_size=size.small, bgcolor=tbl_row_bg)
    table.cell(dash, 1, 5, lv4 ? "YES" : "-",  text_color=lv4 ? tbl_yes_long  : tbl_no, text_size=size.small, bgcolor=tbl_row_bg)
    table.cell(dash, 2, 5, sv4 ? "YES" : "-",  text_color=sv4 ? tbl_yes_short : tbl_no, text_size=size.small, bgcolor=tbl_row_bg)

    table.cell(dash, 0, 6, "Psych Level (+2)", text_color=tbl_row_txt, text_size=size.small, bgcolor=tbl_row_bg)
    table.cell(dash, 1, 6, lv5 ? "YES" : "-",  text_color=lv5 ? tbl_yes_long  : tbl_no, text_size=size.small, bgcolor=tbl_row_bg)
    table.cell(dash, 2, 6, sv5 ? "YES" : "-",  text_color=sv5 ? tbl_yes_short : tbl_no, text_size=size.small, bgcolor=tbl_row_bg)

    table.cell(dash, 0, 7, "HTF 15m     (+1)", text_color=tbl_row_txt, text_size=size.small, bgcolor=tbl_row_bg)
    table.cell(dash, 1, 7, lv6 ? "YES" : "-",  text_color=lv6 ? tbl_yes_long  : tbl_no, text_size=size.small, bgcolor=tbl_row_bg)
    table.cell(dash, 2, 7, sv6 ? "YES" : "-",  text_color=sv6 ? tbl_yes_short : tbl_no, text_size=size.small, bgcolor=tbl_row_bg)

    table.cell(dash, 0, 8, "Vol Surge   (+1)", text_color=tbl_row_txt, text_size=size.small, bgcolor=tbl_row_bg)
    table.cell(dash, 1, 8, lv7 ? "YES" : "-",  text_color=lv7 ? tbl_yes_long  : tbl_no, text_size=size.small, bgcolor=tbl_row_bg)
    table.cell(dash, 2, 8, sv7 ? "YES" : "-",  text_color=sv7 ? tbl_yes_short : tbl_no, text_size=size.small, bgcolor=tbl_row_bg)

    table.cell(dash, 0, 9, "SCORE",                       text_color=tbl_score_txt,  text_size=size.small, bgcolor=tbl_score_bg)
    table.cell(dash, 1, 9, str.tostring(lsc) + "/16",     text_color=tbl_score_long, text_size=size.small, bgcolor=tbl_score_bg)
    table.cell(dash, 2, 9, str.tostring(ssc) + "/16",     text_color=tbl_score_shrt, text_size=size.small, bgcolor=tbl_score_bg)

// ═══════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════
alertcondition(l_show and l_score >= 14, "Perfect Long",    "Perfect long entry - check chart")
alertcondition(s_show and s_score >= 14, "Perfect Short",   "Perfect short entry - check chart")
alertcondition(l_show and l_score >= 12, "High Conv Long",  "High conviction long - check chart")
alertcondition(s_show and s_score >= 12, "High Conv Short", "High conviction short - check chart")
alertcondition(l_show,                   "Any Long Signal", "Long signal fired - check chart")
alertcondition(s_show,                   "Any Short Signal","Short signal fired - check chart")
````
