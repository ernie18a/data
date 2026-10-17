# JRI SMC System

- url: https://www.tradingview.com/script/gAu2Alyn-JRI-SMC-System/
- type: indicator
- pine_id: PUB;259c613f12bc49de843832dbbaf9e3e3
- version: 1.0

## Description

1.	Trend / Market Structure (Daily, 4HR, 1HR, 15min)
	2.	Liquidity
	3.	Institutional Move
	4.	Imbalance
	5.	CHOCH
	6.	Mitigation
	7.	Divergence / Correlation
	8.	Entry (FIB, Level, Inefficiency)
	9.	Risk to Reward

## Source Code

````pine
//@version=6
indicator("JRI SMC System", shorttitle="JRI SMC", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// ============================================================
// JRI SMC SYSTEM — Universal Asset | Powerhouse University
// 9-Point Confirmation Checklist + Dashboard Panel
// Timeframes: Weekly / Daily / 4H / 1H / 15M
// ============================================================

// ─── INPUTS ──────────────────────────────────────────────────
var g1 = "Structure"
swing_len = input.int(10, "Swing Lookback", minval=3, maxval=50, group=g1)

var g2 = "Fair Value Gaps"
show_fvg    = input.bool(true, "Show FVGs", group=g2)
fvg_bull_col = input.color(color.new(color.green, 80), "Bullish FVG", group=g2)
fvg_bear_col = input.color(color.new(color.red, 80),   "Bearish FVG", group=g2)

var g3 = "Order Blocks"
show_ob     = input.bool(true, "Show Order Blocks", group=g3)
ob_bull_col = input.color(color.new(color.teal, 75),   "Bullish OB", group=g3)
ob_bear_col = input.color(color.new(color.orange, 75), "Bearish OB", group=g3)

var g4 = "Liquidity"
show_liq    = input.bool(true, "Show Liquidity Levels", group=g4)
liq_col     = input.color(color.new(color.yellow, 40), "Liquidity Color", group=g4)

var g5 = "Risk"
rr1 = input.float(1.0, "T1 R:R", group=g5)
rr2 = input.float(2.0, "T2 R:R", group=g5)
rr3 = input.float(3.0, "T3 R:R", group=g5)

var g6 = "Dashboard"
dash_pos = input.string("Top Right", "Panel Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=g6)

// ─── COLORS ──────────────────────────────────────────────────
C_BULL  = #00e5a0
C_BEAR  = #ff4d6d
C_NEUT  = #888888
C_BG    = color.new(#0a0e1a, 5)
C_TEXT  = #e8eaf6
C_DIM   = #4a4e6a
C_GOLD  = #f5c518

// ─── STRUCTURE: HH / HL / LH / LL ───────────────────────────
ph = ta.pivothigh(high, swing_len, swing_len)
pl = ta.pivotlow(low,  swing_len, swing_len)

var float last_ph = na
var float last_pl = na
var float prev_ph = na
var float prev_pl = na

var int   struct_bull_count = 0
var int   struct_bear_count = 0

if not na(ph)
    prev_ph := last_ph
    last_ph := ph
    label.new(bar_index[swing_len], ph, "PHH", style=label.style_label_down,
              color=color.new(C_BEAR,60), textcolor=C_TEXT, size=size.tiny)

if not na(pl)
    prev_pl := last_pl
    last_pl := pl
    label.new(bar_index[swing_len], pl, "PLL", style=label.style_label_up,
              color=color.new(C_BULL,60), textcolor=C_TEXT, size=size.tiny)

// HH/HL = bullish structure | LH/LL = bearish
bool is_hh = not na(last_ph) and not na(prev_ph) and last_ph > prev_ph
bool is_hl = not na(last_pl) and not na(prev_pl) and last_pl > prev_pl
bool is_lh = not na(last_ph) and not na(prev_ph) and last_ph < prev_ph
bool is_ll = not na(last_pl) and not na(prev_pl) and last_pl < prev_pl

bool bull_struct = is_hh and is_hl
bool bear_struct = is_lh and is_ll

// ─── CHOCH / BOS ─────────────────────────────────────────────
var float choch_level = na
var bool  choch_bull  = false
var bool  choch_bear  = false

if not na(last_pl) and close > last_ph[1]
    choch_bull := true
    choch_level := last_ph[1]

if not na(last_ph) and close < last_pl[1]
    choch_bear := true
    choch_level := last_pl[1]

plotshape(choch_bull, "CHOCH Bull", shape.labelup,   location.belowbar, C_BULL, text="CHOCH", textcolor=C_TEXT, size=size.tiny)
plotshape(choch_bear, "CHOCH Bear", shape.labeldown, location.abovebar, C_BEAR, text="CHOCH", textcolor=C_TEXT, size=size.tiny)

// ─── FAIR VALUE GAPS ─────────────────────────────────────────
bull_fvg = show_fvg and low > high[2]
bear_fvg = show_fvg and high < low[2]

if bull_fvg
    box.new(bar_index[2], high[2], bar_index + 20, low, border_color=color.new(C_BULL,60), bgcolor=fvg_bull_col)

if bear_fvg
    box.new(bar_index[2], low[2], bar_index + 20, high, border_color=color.new(C_BEAR,60), bgcolor=fvg_bear_col)

// ─── ORDER BLOCKS ────────────────────────────────────────────
bull_ob = show_ob and close[1] < open[1] and close > open and close > high[1]
bear_ob = show_ob and close[1] > open[1] and close < open and close < low[1]

if bull_ob
    box.new(bar_index[1], high[1], bar_index + 30, low[1], border_color=color.new(C_BULL,50), bgcolor=ob_bull_col)

if bear_ob
    box.new(bar_index[1], high[1], bar_index + 30, low[1], border_color=color.new(C_BEAR,50), bgcolor=ob_bear_col)

// ─── LIQUIDITY LEVELS ────────────────────────────────────────
var float liq_high = ta.highest(high, 50)
var float liq_low  = ta.lowest(low,  50)

if show_liq
    line.new(bar_index - 50, liq_high, bar_index, liq_high, color=liq_col, style=line.style_dashed, width=1)
    line.new(bar_index - 50, liq_low,  bar_index, liq_low,  color=liq_col, style=line.style_dashed, width=1)

// ─── IMBALANCE CHECK ─────────────────────────────────────────
bool imbalance = bull_fvg or bear_fvg

// ─── INSTITUTIONAL MOVE ──────────────────────────────────────
bull_inst = close > open and close[1] > open[1] and close[2] > open[2]
bear_inst = close < open and close[1] < open[1] and close[2] < open[2]
bool inst_move = bull_inst or bear_inst

// ─── DIVERGENCE PROXY ────────────────────────────────────────
rsi_val   = ta.rsi(close, 14)
rsi_val_5 = rsi_val[5]
bool bull_div = low < low[5]  and rsi_val > rsi_val_5
bool bear_div = high > high[5] and rsi_val < rsi_val_5
bool divergence = bull_div or bear_div

// ─── ENTRY CONFLUENCE ────────────────────────────────────────
bool entry_zone = (bull_fvg or bear_fvg or bull_ob or bear_ob)

// ─── RISK TO REWARD ──────────────────────────────────────────
atr_val = ta.atr(14)
bool rr_valid = atr_val > 0

// ─── 9-POINT SCORE ───────────────────────────────────────────
int s1 = (bull_struct or bear_struct) ? 1 : 0
int s2 = (high >= liq_high * 0.999 or low <= liq_low * 1.001) ? 1 : 0
int s3 = inst_move ? 1 : 0
int s4 = imbalance ? 1 : 0
int s5 = (choch_bull or choch_bear) ? 1 : 0
int s6 = (bull_ob or bear_ob) ? 1 : 0
int s7 = divergence ? 1 : 0
int s8 = entry_zone ? 1 : 0
int s9 = rr_valid ? 1 : 0

int total_score = s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8 + s9

// ─── BIAS ────────────────────────────────────────────────────
string bias_label = total_score >= 7 and bull_struct ? "BULLISH" : total_score >= 7 and bear_struct ? "BEARISH" : total_score >= 5 ? "NEUTRAL" : "NO SETUP"

color bias_col = bias_label == "BULLISH" ? C_BULL : bias_label == "BEARISH" ? C_BEAR : bias_label == "NEUTRAL" ? C_GOLD : C_DIM

// ─── ENTRY SIGNALS ───────────────────────────────────────────
bool long_signal  = total_score >= 7 and bull_struct and (bull_fvg or bull_ob) and choch_bull
bool short_signal = total_score >= 7 and bear_struct and (bear_fvg or bear_ob) and choch_bear

plotshape(long_signal,  "Long Entry",  shape.triangleup,   location.belowbar, C_BULL, size=size.small)
plotshape(short_signal, "Short Entry", shape.triangledown, location.abovebar, C_BEAR, size=size.small)

// ─── TP LEVELS ───────────────────────────────────────────────
if long_signal
    sl  = low - atr_val
    t1  = close + (close - sl) * rr1
    t2  = close + (close - sl) * rr2
    t3  = close + (close - sl) * rr3
    line.new(bar_index, t1, bar_index + 10, t1, color=color.new(C_BULL, 40), style=line.style_dotted)
    line.new(bar_index, t2, bar_index + 10, t2, color=color.new(C_BULL, 20), style=line.style_dotted)
    line.new(bar_index, t3, bar_index + 10, t3, color=color.new(C_BULL, 0),  style=line.style_dotted)
    label.new(bar_index + 10, t1, "T1 " + str.tostring(rr1) + "R", color=color.new(C_BULL,70), textcolor=C_TEXT, size=size.tiny, style=label.style_label_left)
    label.new(bar_index + 10, t2, "T2 " + str.tostring(rr2) + "R", color=color.new(C_BULL,50), textcolor=C_TEXT, size=size.tiny, style=label.style_label_left)
    label.new(bar_index + 10, t3, "T3 " + str.tostring(rr3) + "R", color=color.new(C_BULL,30), textcolor=C_TEXT, size=size.tiny, style=label.style_label_left)

if short_signal
    sl  = high + atr_val
    t1  = close - (sl - close) * rr1
    t2  = close - (sl - close) * rr2
    t3  = close - (sl - close) * rr3
    line.new(bar_index, t1, bar_index + 10, t1, color=color.new(C_BEAR, 40), style=line.style_dotted)
    line.new(bar_index, t2, bar_index + 10, t2, color=color.new(C_BEAR, 20), style=line.style_dotted)
    line.new(bar_index, t3, bar_index + 10, t3, color=color.new(C_BEAR, 0),  style=line.style_dotted)
    label.new(bar_index + 10, t1, "T1 " + str.tostring(rr1) + "R", color=color.new(C_BEAR,70), textcolor=C_TEXT, size=size.tiny, style=label.style_label_left)
    label.new(bar_index + 10, t2, "T2 " + str.tostring(rr2) + "R", color=color.new(C_BEAR,50), textcolor=C_TEXT, size=size.tiny, style=label.style_label_left)
    label.new(bar_index + 10, t3, "T3 " + str.tostring(rr3) + "R", color=color.new(C_BEAR,30), textcolor=C_TEXT, size=size.tiny, style=label.style_label_left)

// ─── DASHBOARD TABLE ─────────────────────────────────────────
var table dash = table.new(
     dash_pos == "Top Right"    ? position.top_right    :
     dash_pos == "Top Left"     ? position.top_left     :
     dash_pos == "Bottom Right" ? position.bottom_right : position.bottom_left,
     3, 14,
     bgcolor=C_BG, border_color=C_DIM, border_width=1, frame_color=C_GOLD, frame_width=1)

f_bar(val, max) =>
    filled = math.round(val / max * 10)
    empty  = 10 - filled
    bar = ""
    for i = 0 to filled - 1
        bar := bar + "█"
    for i = 0 to empty - 1
        bar := bar + "░"
    bar

table.cell(dash, 0, 0, "JRI SMC SYSTEM", text_color=C_GOLD,  text_size=size.small, bgcolor=color.new(#0a0e1a,0), text_halign=text.align_left)
table.cell(dash, 1, 0, "",               bgcolor=color.new(#0a0e1a,0))
table.cell(dash, 2, 0, syminfo.tickerid, text_color=C_DIM,   text_size=size.tiny,  bgcolor=color.new(#0a0e1a,0), text_halign=text.align_right)

table.cell(dash, 0, 1, "BIAS",     text_color=C_DIM,    text_size=size.tiny,  bgcolor=color.new(#0d1220,0), text_halign=text.align_left)
table.cell(dash, 1, 1, bias_label, text_color=bias_col, text_size=size.small, bgcolor=color.new(#0d1220,0))
table.cell(dash, 2, 1, str.tostring(total_score) + "/9", text_color=bias_col, text_size=size.small, bgcolor=color.new(#0d1220,0), text_halign=text.align_right)

table.cell(dash, 0, 2, "SCORE",               text_color=C_DIM,    text_size=size.tiny, bgcolor=color.new(#0d1220,0), text_halign=text.align_left)
table.cell(dash, 1, 2, f_bar(total_score, 9), text_color=bias_col, text_size=size.tiny, bgcolor=color.new(#0d1220,0))
table.cell(dash, 2, 2, "",                    bgcolor=color.new(#0d1220,0))

table.cell(dash, 0, 3, "─────────────────", text_color=C_DIM, text_size=size.tiny, bgcolor=color.new(#0a0e1a,0), text_halign=text.align_left)
table.cell(dash, 1, 3, "", bgcolor=color.new(#0a0e1a,0))
table.cell(dash, 2, 3, "", bgcolor=color.new(#0a0e1a,0))

f_check(score) => score == 1 ? "●" : "○"
f_col(score)   => score == 1 ? C_BULL : C_DIM

criteria_names  = array.from("1. Structure","2. Liquidity","3. Inst. Move","4. Imbalance","5. CHOCH","6. Mitigation","7. Divergence","8. Entry Zone","9. R:R Valid")
criteria_scores = array.from(s1, s2, s3, s4, s5, s6, s7, s8, s9)

for i = 0 to 8
    row = i + 4
    sc  = array.get(criteria_scores, i)
    nm  = array.get(criteria_names, i)
    table.cell(dash, 0, row, nm,          text_color=sc == 1 ? C_TEXT : C_DIM, text_size=size.tiny, bgcolor=color.new(#0d1220,0), text_halign=text.align_left)
    table.cell(dash, 1, row, f_bar(sc,1), text_color=f_col(sc),                text_size=size.tiny, bgcolor=color.new(#0d1220,0))
    table.cell(dash, 2, row, f_check(sc), text_color=f_col(sc),                text_size=size.tiny, bgcolor=color.new(#0d1220,0), text_halign=text.align_center)

table.cell(dash, 0, 13, "Powerhouse University", text_color=C_DIM, text_size=size.tiny, bgcolor=color.new(#0a0e1a,0), text_halign=text.align_left)
table.cell(dash, 1, 13, "",                       bgcolor=color.new(#0a0e1a,0))
table.cell(dash, 2, 13, "@ibarra_jojo",            text_color=C_DIM, text_size=size.tiny, bgcolor=color.new(#0a0e1a,0), text_halign=text.align_right)
````
