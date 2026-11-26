# Oracle-local

- url: https://www.tradingview.com/script/7REtBDT3-Oracle-local/
- type: indicator
- pine_id: PUB;a49ddd4582c943b6943ca9b1d15ea36d
- version: 1.0

## Description

bbbghfghtrgfnbvcnfg dsfidsjfoeflsdv.xcvjxcbv
jcbdshiudsnv.cx 
xzjknvlncxv,
 cxvlkds9fevnz.v
 dshdsn

## Source Code

````pine
//@version=6
indicator("Oracle", overlay=true, max_labels_count=500)

// --- 1. INPUTS ---
grp_c = "Trend Logic"
ema_len      = input.int(50, "Trend EMA Period", minval=1, group=grp_c)
rsi_len      = input.int(14, "Momentum RSI Period", minval=1, group=grp_c)

grp_o = "Visual Aesthetics"
show_candles = input.bool(true, "Enable Custom Candles", group=grp_o)
bull_col     = input.color(#06a80c, "Bull Candle Color", group=grp_o)
bear_col     = input.color(#c804ea, "Bear Candle Color", group=grp_o)
ema_width    = input.int(2, "EMA Thickness", minval=1, group=grp_o)
show_vwap    = input.bool(false, "Show VWAP", group=grp_o)
vwap_col     = input.color(#00e6ff, "VWAP Color", group=grp_o)
vwap_width   = input.int(2, "VWAP Thickness", minval=1, group=grp_o)

grp_d = "Dashboard Settings"
show_table   = input.bool(true, "Show Dashboard", group=grp_d)
// View modes: Default = compact 3-col, Extended = descriptive 2-col with sources, Mini = signal only
view_mode    = input.string("Default", "View Mode", options=["Default", "Extended", "Mini"], group=grp_d)
table_pos    = input.string(position.top_right, "Dashboard Position", options=[position.top_left, position.top_center, position.top_right, position.middle_left, position.middle_center, position.middle_right, position.bottom_left, position.bottom_center, position.bottom_right], group=grp_d)
dash_color   = input.color(#0a0a0a, "Table BG", group=grp_d)
col_q_input  = input.color(#00e6ff, "Question Text Color", group=grp_d)
col_s_input  = input.color(#ffffff, "Source Text Color", group=grp_d)
table_size   = input.string("Normal", "Table Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=grp_d)

// --- 2. CORE CALCULATIONS ---
ema_val    = ta.ema(close, ema_len)
vwap_v     = ta.vwap(close)

candle_col = close > ema_val ? bull_col : bear_col
plotcandle(show_candles ? open : na, high, low, close, title="Trend Candles", color=candle_col, wickcolor=candle_col, bordercolor=candle_col)

// --- 3. OVERLAYS ---
ema_trend_col = close > ema_val ? bull_col : bear_col
plot(ema_val, "EMA", color=ema_trend_col, linewidth=ema_width)
plot(show_vwap ? vwap_v : na, "VWAP", color=vwap_col, linewidth=vwap_width, style=plot.style_stepline)

// --- 4. METRIC CALCULATIONS ---
rsi_v      = ta.rsi(close, rsi_len)
[m_l, s_l, _] = ta.macd(close, 12, 26, 9)
[_, _, adx_v] = ta.dmi(14, 14)
ema_slope  = (ema_val - ema_val[1]) / ema_val[1] * 100
price_ema  = (close - ema_val) / ema_val * 100
stoch_k    = ta.stoch(close, high, low, 14)
wpr_v      = ta.wpr(14)
cci_v      = ta.cci(close, 20)
mfi_v      = ta.mfi(close, 7)
roc_v      = ta.roc(close, 10)
atr_v      = ta.atr(14)
[bb_m, bb_u, bb_l] = ta.bb(close, 20, 2)
bb_width   = (bb_u - bb_l) / bb_m * 100
hist_vol   = ta.stdev(math.log(close / close[1]), 20) * math.sqrt(252) * 100
true_range = ta.tr(true)
mf_val     = ((close - low) - (high - close)) / math.max(high - low, 1e-10) * volume
cmf_v      = ta.sma(mf_val, 10) / ta.sma(volume, 10)
vol_rel    = volume / ta.sma(volume, 20)
obv_v      = ta.obv
price_chg  = ta.change(close) / close[1] * 100
dist_vwap  = (close - vwap_v) / vwap_v * 100

// --- 5. SIGNAL LOGIC ---
ema_sloping_up   = ema_slope > 0
ema_sloping_down = ema_slope < 0

rsi_exit_long  = rsi_v < 50 and rsi_v[1] >= 50
rsi_exit_short = rsi_v > 50 and rsi_v[1] <= 50

var int current_status = 0

is_buy_entry  = (close > ema_val and rsi_v > 55 and vol_rel >= 1.0 and ema_sloping_up)
is_sell_entry = (close < ema_val and rsi_v < 45 and vol_rel >= 1.0 and ema_sloping_down)

if current_status == 1
    if close < ema_val or rsi_exit_long
        current_status := 0
else if current_status == 2
    if close > ema_val or rsi_exit_short
        current_status := 0
else
    if is_buy_entry
        current_status := 1
    else if is_sell_entry
        current_status := 2

string signal     = current_status == 1 ? "BUY" : current_status == 2 ? "SELL" : "NOACT"
color  signal_col = current_status == 1 ? color.lime : current_status == 2 ? color.red : color.orange

if ta.change(current_status) != 0
    alert("Signal Changed to: " + signal, alert.freq_once_per_bar_close)

// --- 6. METER HELPER ---
f_meter(score) =>
    score >= 5 ? "▰▰▰▰▰" :
     score == 4 ? "▰▰▰▰▱" :
     score == 3 ? "▰▰▰▱▱" :
     score == 2 ? "▰▰▱▱▱" :
     score == 1 ? "▰▱▱▱▱" : "▱▱▱▱▱"

// --- 7. SCORES ---
trend_score = (close > ema_val ? 2 : 0) + (ema_sloping_up ? 2 : 0) + (m_l > s_l ? 1 : 0)
adx_score   = adx_v >= 40 ? 5 : adx_v >= 30 ? 4 : adx_v >= 25 ? 3 : adx_v >= 15 ? 2 : 1

rsi_pts   = rsi_v >= 60 ? 2 : rsi_v >= 50 ? 1 : 0
roc_pts   = roc_v >= 1.0 ? 2 : roc_v >= 0 ? 1 : 0
stoch_pts = stoch_k >= 50 ? 1 : 0
mom_score = math.min(rsi_pts + roc_pts + stoch_pts, 5)

vol_pts   = vol_rel >= 2.0 ? 2 : vol_rel >= 1.0 ? 1 : 0
cmf_pts   = cmf_v > 0.05 ? 2 : cmf_v > 0 ? 1 : 0
obv_pts   = obv_v > obv_v[1] ? 1 : 0
crowd_score = math.min(vol_pts + cmf_pts + obv_pts, 5)

mfi_pts  = mfi_v >= 60 ? 2 : mfi_v >= 50 ? 1 : mfi_v <= 30 ? -2 : mfi_v <= 40 ? -1 : 0
cmf_pts2 = cmf_v > 0.1 ? 2 : cmf_v > 0 ? 1 : cmf_v < -0.1 ? -2 : cmf_v < 0 ? -1 : 0
vwap_pts = dist_vwap > 0 ? 1 : -1
flow_raw  = mfi_pts + cmf_pts2 + vwap_pts
flow_score = math.round(math.min(math.max((flow_raw + 5) / 2, 0), 5))

ob_rsi = rsi_v >= 70 ? 2 : rsi_v >= 60 ? 1 : rsi_v <= 30 ? -2 : rsi_v <= 40 ? -1 : 0
ob_wpr = wpr_v >= -20 ? 2 : wpr_v >= -40 ? 1 : wpr_v <= -80 ? -2 : wpr_v <= -60 ? -1 : 0
ob_cci = cci_v >= 100 ? 2 : cci_v >= 50 ? 1 : cci_v <= -100 ? -2 : cci_v <= -50 ? -1 : 0
ob_raw  = ob_rsi + ob_wpr + ob_cci
ob_score = math.min(math.abs(ob_raw), 5)
ob_hot   = ob_raw > 0

atr_pct    = atr_v / close * 100
risk_pts   = (atr_pct >= 2.0 ? 2 : atr_pct >= 1.0 ? 1 : 0) + (bb_width >= 3.0 ? 2 : bb_width >= 1.5 ? 1 : 0) + (hist_vol >= 30 ? 1 : 0)
risk_score = math.min(risk_pts, 5)

// --- 8. VERDICT WORDS & COLORS ---
trend_word = trend_score >= 4 ? "CLIMBING UP" : trend_score >= 3 ? "RISING" : trend_score == 2 ? "FLAT" : trend_score == 1 ? "FALLING" : "DROPPING"
trend_col  = trend_score >= 3 ? color.lime : trend_score == 2 ? color.orange : color.red

str_word = adx_score >= 4 ? "POWERFUL" : adx_score == 3 ? "STRONG" : adx_score == 2 ? "MODERATE" : "WEAK"
str_col  = adx_score >= 3 ? color.lime : adx_score == 2 ? color.yellow : color.orange

mom_word = mom_score >= 4 ? "SPEEDING UP" : mom_score >= 3 ? "MOVING FAST" : mom_score == 2 ? "STEADY" : mom_score == 1 ? "SLOWING" : "STALLING"
mom_col  = mom_score >= 3 ? color.lime : mom_score == 2 ? color.yellow : color.orange

crowd_word = crowd_score >= 4 ? "HUGE CROWD" : crowd_score >= 3 ? "BUSY" : crowd_score == 2 ? "NORMAL" : crowd_score == 1 ? "QUIET" : "EMPTY"
crowd_col  = crowd_score >= 3 ? color.lime : crowd_score == 2 ? color.yellow : color.orange

flow_word = flow_score >= 4 ? "BUYING IN" : flow_score >= 3 ? "MORE BUYERS" : flow_score == 2 ? "BALANCED" : flow_score == 1 ? "MORE SELLERS" : "SELLING OUT"
flow_col  = flow_score >= 4 ? color.lime : flow_score >= 3 ? color.yellow : flow_score == 2 ? color.gray : flow_score == 1 ? color.orange : color.red

ob_word = ob_score <= 1 ? "NORMAL" : ob_hot ? (ob_score >= 4 ? "TOO HOT!" : "GETTING HOT") : (ob_score >= 4 ? "TOO COLD!" : "GETTING COLD")
ob_col  = ob_score <= 1 ? color.gray : ob_score >= 4 ? color.red : color.orange

risk_word = risk_score >= 4 ? "VERY BUMPY" : risk_score >= 3 ? "BUMPY" : risk_score == 2 ? "MODERATE" : "SMOOTH"
risk_col  = risk_score >= 4 ? color.red : risk_score >= 3 ? color.orange : risk_score >= 2 ? color.yellow : color.lime

// Overall score (shared across both views)
total_bull     = trend_score + adx_score + mom_score + crowd_score + flow_score
total_possible = 25
overall_pct    = math.round(total_bull / total_possible * 100)
overall_word   = overall_pct >= 75 ? "STRONG BUY ZONE" : overall_pct >= 55 ? "LEANING UP" : overall_pct >= 45 ? "MIXED" : overall_pct >= 30 ? "LEANING DOWN" : "STRONG SELL ZONE"
overall_col    = overall_pct >= 65 ? color.lime : overall_pct >= 50 ? color.yellow : overall_pct >= 40 ? color.orange : color.red
overall_meter  = math.round(total_bull / total_possible * 5)

// --- 9. DASHBOARD ---
color col_bg   = color.new(dash_color, 0)
color col_sect = color.rgb(20, 20, 20)
color col_q    = col_q_input
color col_src  = col_s_input

t_q = table_size == "Tiny"  ? size.tiny   :
      table_size == "Small"  ? size.small  :
      table_size == "Large"  ? size.large  :
      table_size == "Huge"   ? size.huge   : size.normal

t_s = table_size == "Tiny"  ? size.tiny   :
      table_size == "Small"  ? size.tiny   :
      table_size == "Large"  ? size.small  :
      table_size == "Huge"   ? size.normal : size.small

t_v = table_size == "Tiny"  ? size.tiny   :
      table_size == "Small"  ? size.small  :
      table_size == "Large"  ? size.large  :
      table_size == "Huge"   ? size.huge   : size.normal

// Table has 3 cols to support Default view (question | meter | verdict)
// Extended view uses col 0 only for left side and col 1+2 merged for right
var table dash = table.new(table_pos, 3, 20,
     border_width=1, border_color=color.rgb(40, 40, 40), bgcolor=col_bg)

f_cell(tbl, c, r, txt, color t_col, color b_col, t_size=size.normal) =>
    table.cell(tbl, c, r, txt, text_color=t_col, bgcolor=b_col,
               text_size=t_size, text_halign=text.align_center, text_valign=text.align_center)

if barstate.islast and show_table
    table.clear(dash, 0, 0, 2, 19)

    sig_bg = current_status == 1 ? color.rgb(0, 45, 0) : current_status == 2 ? color.rgb(45, 0, 0) : color.rgb(35, 25, 0)

    // ════════════════════════════════════════════════
    // MINI VIEW — signal row only
    // ════════════════════════════════════════════════
    if view_mode == "Mini"
        // Row 0: signal
        f_cell(dash, 0, 0, "SIGNAL", col_q, color.rgb(12, 12, 40), t_q)
        f_cell(dash, 1, 0, signal, signal_col, sig_bg, t_q)
        f_cell(dash, 2, 0, signal == "NOACT" ? "WAIT" : "ACTIVE", signal_col, sig_bg, t_q)
        // Row 1: overall picture
        f_cell(dash, 0, 1, "OVERALL PICTURE", col_q, col_sect, t_q)
        f_cell(dash, 1, 1, f_meter(overall_meter), overall_col, col_sect, t_v)
        f_cell(dash, 2, 1, overall_word, overall_col, col_sect, t_v)

    // ════════════════════════════════════════════════
    // DEFAULT VIEW — 3 cols: question | meter | verdict
    // ════════════════════════════════════════════════
    else if view_mode == "Default"
        // Row 0: signal — col 0 label, col 1 BUY/SELL/NOACT, col 2 ACTIVE/WAIT
        f_cell(dash, 0, 0, "SIGNAL",                                            col_q,      color.rgb(12, 12, 40), t_q)
        f_cell(dash, 1, 0, signal,                                               signal_col, sig_bg,                t_q)
        f_cell(dash, 2, 0, signal == "NOACT" ? "WAIT" : "ACTIVE",               signal_col, sig_bg,                t_q)

        // Row 1: column headers
        f_cell(dash, 0, 1, "QUESTION",  col_src, col_sect, t_s)
        f_cell(dash, 1, 1, "METER",     col_src, col_sect, t_s)
        f_cell(dash, 2, 1, "VERDICT",   col_src, col_sect, t_s)

        // Rows 2-9: one row per question
        f_cell(dash, 0, 2, "Which way is it going?",    col_q,      col_bg, t_q)
        f_cell(dash, 1, 2, f_meter(trend_score),         trend_col,  col_bg, t_v)
        f_cell(dash, 2, 2, trend_word,                   trend_col,  col_bg, t_v)

        f_cell(dash, 0, 3, "How strong is the move?",   col_q,      col_bg, t_q)
        f_cell(dash, 1, 3, f_meter(adx_score),           str_col,    col_bg, t_v)
        f_cell(dash, 2, 3, str_word,                     str_col,    col_bg, t_v)

        f_cell(dash, 0, 4, "Is it speeding up?",        col_q,      col_bg, t_q)
        f_cell(dash, 1, 4, f_meter(mom_score),            mom_col,    col_bg, t_v)
        f_cell(dash, 2, 4, mom_word,                     mom_col,    col_bg, t_v)

        f_cell(dash, 0, 5, "How many people are in?",   col_q,      col_bg, t_q)
        f_cell(dash, 1, 5, f_meter(crowd_score),          crowd_col,  col_bg, t_v)
        f_cell(dash, 2, 5, crowd_word,                   crowd_col,  col_bg, t_v)

        f_cell(dash, 0, 6, "Is big money buying?",      col_q,      col_bg, t_q)
        f_cell(dash, 1, 6, f_meter(flow_score),           flow_col,   col_bg, t_v)
        f_cell(dash, 2, 6, flow_word,                    flow_col,   col_bg, t_v)

        f_cell(dash, 0, 7, "Is it too hot or cold?",    col_q,      col_bg, t_q)
        f_cell(dash, 1, 7, f_meter(ob_score),             ob_col,     col_bg, t_v)
        f_cell(dash, 2, 7, ob_word,                      ob_col,     col_bg, t_v)

        f_cell(dash, 0, 8, "How bumpy is the ride?",    col_q,      col_bg, t_q)
        f_cell(dash, 1, 8, f_meter(risk_score),           risk_col,   col_bg, t_v)
        f_cell(dash, 2, 8, risk_word,                    risk_col,   col_bg, t_v)

        // Row 9: overall
        f_cell(dash, 0, 9, "OVERALL PICTURE",            col_q,       col_sect, t_q)
        f_cell(dash, 1, 9, f_meter(overall_meter),        overall_col, col_sect, t_v)
        f_cell(dash, 2, 9, overall_word,                  overall_col, col_sect, t_v)

    // ════════════════════════════════════════════════
    // EXTENDED VIEW — 2 cols: question+source | meter+verdict
    // Uses cols 0 and 1; col 2 hidden (empty)
    // Right col merges across question+source row pairs
    // ════════════════════════════════════════════════
    else
        // Row 0: signal
        f_cell(dash, 0, 0, "SIGNAL",                                            col_q,      color.rgb(12, 12, 40), t_q)
        f_cell(dash, 1, 0, signal + "  |  " + (signal == "NOACT" ? "WAIT" : "ACTIVE"), signal_col, sig_bg, t_q)
        f_cell(dash, 2, 0, "",                                                   col_q,      sig_bg,                t_s)

        // Row 1: headers
        f_cell(dash, 0, 1, "QUESTION", col_src, col_sect, t_s)
        f_cell(dash, 1, 1, "METER  ·  VERDICT", col_src, col_sect, t_s)
        f_cell(dash, 2, 1, "", col_src, col_sect, t_s)

        // ── Rows 2-3: Which way ──
        f_cell(dash, 0, 2, "Which way is it going?",      col_q,   col_bg, t_q)
        f_cell(dash, 0, 3, "· EMA side · Slope · MACD",   col_src, col_bg, t_s)
        f_cell(dash, 1, 2, f_meter(trend_score) + "\n" + trend_word, trend_col, col_bg, t_v)
        f_cell(dash, 2, 2, "", col_q, col_bg, t_s)
        table.merge_cells(dash, 1, 2, 2, 3)

        // ── Rows 4-5: How strong ──
        f_cell(dash, 0, 4, "How strong is the move?",     col_q,   col_bg, t_q)
        f_cell(dash, 0, 5, "· ADX (14)",                  col_src, col_bg, t_s)
        f_cell(dash, 1, 4, f_meter(adx_score) + "\n" + str_word, str_col, col_bg, t_v)
        f_cell(dash, 2, 4, "", col_q, col_bg, t_s)
        table.merge_cells(dash, 1, 4, 2, 5)

        // ── Rows 6-7: Speeding up ──
        f_cell(dash, 0, 6, "Is it speeding up?",          col_q,   col_bg, t_q)
        f_cell(dash, 0, 7, "· RSI · ROC · Stoch K",       col_src, col_bg, t_s)
        f_cell(dash, 1, 6, f_meter(mom_score) + "\n" + mom_word, mom_col, col_bg, t_v)
        f_cell(dash, 2, 6, "", col_q, col_bg, t_s)
        table.merge_cells(dash, 1, 6, 2, 7)

        // ── Rows 8-9: Crowd ──
        f_cell(dash, 0, 8, "How many people are in?",     col_q,   col_bg, t_q)
        f_cell(dash, 0, 9, "· Rel Volume · CMF · OBV",    col_src, col_bg, t_s)
        f_cell(dash, 1, 8, f_meter(crowd_score) + "\n" + crowd_word, crowd_col, col_bg, t_v)
        f_cell(dash, 2, 8, "", col_q, col_bg, t_s)
        table.merge_cells(dash, 1, 8, 2, 9)

        // ── Rows 10-11: Money flow ──
        f_cell(dash, 0, 10, "Is big money buying?",       col_q,   col_bg, t_q)
        f_cell(dash, 0, 11, "· MFI · CMF · VWAP Dist",   col_src, col_bg, t_s)
        f_cell(dash, 1, 10, f_meter(flow_score) + "\n" + flow_word, flow_col, col_bg, t_v)
        f_cell(dash, 2, 10, "", col_q, col_bg, t_s)
        table.merge_cells(dash, 1, 10, 2, 11)

        // ── Rows 12-13: Hot or cold ──
        f_cell(dash, 0, 12, "Is it too hot or cold?",     col_q,   col_bg, t_q)
        f_cell(dash, 0, 13, "· RSI · Williams %R · CCI",  col_src, col_bg, t_s)
        f_cell(dash, 1, 12, f_meter(ob_score) + "\n" + ob_word, ob_col, col_bg, t_v)
        f_cell(dash, 2, 12, "", col_q, col_bg, t_s)
        table.merge_cells(dash, 1, 12, 2, 13)

        // ── Rows 14-15: Bumpy ride ──
        f_cell(dash, 0, 14, "How bumpy is the ride?",       col_q,   col_bg, t_q)
        f_cell(dash, 0, 15, "· ATR% · BB Width · Hist Vol", col_src, col_bg, t_s)
        f_cell(dash, 1, 14, f_meter(risk_score) + "\n" + risk_word, risk_col, col_bg, t_v)
        f_cell(dash, 2, 14, "", col_q, col_bg, t_s)
        table.merge_cells(dash, 1, 14, 2, 15)

        // ── Rows 16-17: Overall ──
        f_cell(dash, 0, 16, "OVERALL PICTURE",             col_q,       col_sect, t_q)
        f_cell(dash, 0, 17, "· Top 5 scores combined",     col_src,     col_sect, t_s)
        f_cell(dash, 1, 16, f_meter(overall_meter) + "\n" + overall_word, overall_col, col_sect, t_v)
        f_cell(dash, 2, 16, "", col_q, col_sect, t_s)
        table.merge_cells(dash, 1, 16, 2, 17)
````
