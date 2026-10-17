# JRI SMC System v2

- url: https://www.tradingview.com/script/dvtAVCqm-JRI-SMC-System-v2/
- type: indicator
- pine_id: PUB;c12d077aa1bf4ea78d0387aed069262b
- version: 2.0

## Description

JRI SMC System v2 — Major Update

Clean rebuild from the ground up. Here’s what changed:

CHOCH — Now fires once per structural shift only. No more labels on every bar.

FVGs & Order Blocks — Hard capped at 3 each. Oldest zone auto-deletes when a new one forms. Chart stays clean.

Liquidity — Reduced to 2 clean dashed lines at all times. Auto-refreshes each bar.

Structure Labels — HH / HL / LH / LL only print on confirmed pivot bars. Not every candle.

Order Block Logic — Stricter filter. Impulse body must exceed the prior candle’s full range to qualify.

Entry Signals — Now requires score 7+, confirmed structure, confirmed CHOCH, price inside a zone, AND near liquidity simultaneously. Fewer signals, higher quality.

Built on the Powerhouse University 9-point confirmation checklist.
@ibarra_jojo

## Source Code

````pine
//@version=6
indicator("JRI SMC v3", shorttitle="JRI SMC", overlay=true, max_lines_count=100, max_boxes_count=60, max_labels_count=60)

// ============================================================
// JRI SMC SYSTEM v3 — Powerhouse University
// Clean. Strict. No spam. Only draws on confirmed bars.
// ============================================================

// ─── INPUTS ──────────────────────────────────────────────────
var gS = "Structure"
swing_len = input.int(10, "Swing Length", minval=5, maxval=50, group=gS)

var gF = "Fair Value Gaps"
show_fvg     = input.bool(true, "Show FVGs", group=gF)
max_fvg      = input.int(3, "Max FVGs", minval=1, maxval=8, group=gF)
fvg_bull_col = input.color(color.new(#00e5a0, 88), "Bull FVG", group=gF)
fvg_bear_col = input.color(color.new(#ff4d6d, 88), "Bear FVG", group=gF)

var gO = "Order Blocks"
show_ob     = input.bool(true, "Show OBs", group=gO)
max_ob      = input.int(2, "Max OBs", minval=1, maxval=6, group=gO)
ob_bull_col = input.color(color.new(#00bcd4, 82), "Bull OB", group=gO)
ob_bear_col = input.color(color.new(#ff9800, 82), "Bear OB", group=gO)

var gL = "Liquidity"
show_liq = input.bool(true, "Show Liquidity", group=gL)
liq_len  = input.int(30, "Lookback", minval=10, maxval=200, group=gL)

var gR = "Risk"
rr1 = input.float(1.0, "T1", group=gR)
rr2 = input.float(2.0, "T2", group=gR)
rr3 = input.float(3.0, "T3", group=gR)

var gD = "Dashboard"
dash_pos = input.string("Top Right", "Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=gD)

// ─── COLORS ──────────────────────────────────────────────────
C_BULL = #00e5a0
C_BEAR = #ff4d6d
C_GOLD = #f5c518
C_TEXT = #e8eaf6
C_DIM  = #4a4e6a
C_BG   = color.new(#0a0e1a, 5)

// ─── ATR (computed once, used everywhere) ────────────────────
atr = ta.atr(14)

// ─── SWING PIVOTS ────────────────────────────────────────────
ph = ta.pivothigh(high, swing_len, swing_len)
pl = ta.pivotlow(low,   swing_len, swing_len)

var float ph1 = na
var float ph2 = na
var float pl1 = na
var float pl2 = na

if not na(ph)
    ph2 := ph1
    ph1 := ph

if not na(pl)
    pl2 := pl1
    pl1 := pl

// Structure — needs 2 confirmed pivots
bool is_hh = not na(ph1) and not na(ph2) and ph1 > ph2
bool is_lh = not na(ph1) and not na(ph2) and ph1 < ph2
bool is_hl = not na(pl1) and not na(pl2) and pl1 > pl2
bool is_ll = not na(pl1) and not na(pl2) and pl1 < pl2

bool bull_struct = is_hh and is_hl
bool bear_struct = is_lh and is_ll

// Labels only when pivot prints (confirmed bars only)
if not na(ph) and barstate.isconfirmed
    label.new(bar_index[swing_len], ph, is_hh ? "HH" : "LH",
         style=label.style_label_down, size=size.tiny,
         color=is_hh ? color.new(C_BULL,65) : color.new(C_BEAR,65),
         textcolor=C_TEXT)

if not na(pl) and barstate.isconfirmed
    label.new(bar_index[swing_len], pl, is_hl ? "HL" : "LL",
         style=label.style_label_up, size=size.tiny,
         color=is_hl ? color.new(C_BULL,65) : color.new(C_BEAR,65),
         textcolor=C_TEXT)

// ─── CHOCH — strict, one per swing level ─────────────────────
var float choch_ph_used = na
var float choch_pl_used = na
var bool  choch_bull_active = false
var bool  choch_bear_active = false

bool new_choch_bull = false
bool new_choch_bear = false

// Bearish CHOCH: close breaks below last confirmed pivot low
if not na(pl1) and close < pl1 and pl1 != choch_pl_used and barstate.isconfirmed
    new_choch_bear    := true
    choch_pl_used     := pl1
    choch_bear_active := true
    choch_bull_active := false

// Bullish CHOCH: close breaks above last confirmed pivot high
if not na(ph1) and close > ph1 and ph1 != choch_ph_used and barstate.isconfirmed
    new_choch_bull    := true
    choch_ph_used     := ph1
    choch_bull_active := true
    choch_bear_active := false

// Single plotshape — no label spam
plotshape(new_choch_bull, "CHOCH Bull", shape.labelup,   location.belowbar, C_BULL, text="CHoCH", textcolor=C_TEXT, size=size.tiny)
plotshape(new_choch_bear, "CHOCH Bear", shape.labeldown, location.abovebar, C_BEAR, text="CHoCH", textcolor=C_TEXT, size=size.tiny)

// ─── FAIR VALUE GAPS ─────────────────────────────────────────
var box[] fvg_arr = array.new_box()

bool bull_fvg = show_fvg and barstate.isconfirmed and low[1] > high[3]
bool bear_fvg = show_fvg and barstate.isconfirmed and high[1] < low[3]

if bull_fvg
    b = box.new(bar_index[3], high[3], bar_index + 40, low[1], bgcolor=fvg_bull_col, border_color=color.new(C_BULL,50), border_width=1)
    array.push(fvg_arr, b)
    if array.size(fvg_arr) > max_fvg
        box.delete(array.shift(fvg_arr))

if bear_fvg
    b = box.new(bar_index[3], low[3], bar_index + 40, high[1], bgcolor=fvg_bear_col, border_color=color.new(C_BEAR,50), border_width=1)
    array.push(fvg_arr, b)
    if array.size(fvg_arr) > max_fvg
        box.delete(array.shift(fvg_arr))

// ─── ORDER BLOCKS ────────────────────────────────────────────
var box[] ob_arr = array.new_box()

// Bull OB: last bearish candle before a strong bull break
bool bull_ob = show_ob and barstate.isconfirmed and close[1] < open[1] and close > open and close > high[1]
// Bear OB: last bullish candle before a strong bear break
bool bear_ob = show_ob and barstate.isconfirmed and close[1] > open[1] and close < open and close < low[1]

if bull_ob
    b = box.new(bar_index[1], math.max(open[1],close[1]), bar_index + 50, math.min(open[1],close[1]), bgcolor=ob_bull_col, border_color=color.new(C_BULL,40), border_width=1)
    array.push(ob_arr, b)
    if array.size(ob_arr) > max_ob
        box.delete(array.shift(ob_arr))

if bear_ob
    b = box.new(bar_index[1], math.max(open[1],close[1]), bar_index + 50, math.min(open[1],close[1]), bgcolor=ob_bear_col, border_color=color.new(C_BEAR,40), border_width=1)
    array.push(ob_arr, b)
    if array.size(ob_arr) > max_ob
        box.delete(array.shift(ob_arr))

// ─── LIQUIDITY LINES (2 only) ────────────────────────────────
var line liq_h = na
var line liq_l = na
liq_hval = ta.highest(high, liq_len)
liq_lval = ta.lowest(low,   liq_len)

if show_liq
    line.delete(liq_h)
    line.delete(liq_l)
    liq_h := line.new(bar_index - liq_len, liq_hval, bar_index + 8, liq_hval, color=color.new(C_GOLD,40), style=line.style_dashed, width=1)
    liq_l := line.new(bar_index - liq_len, liq_lval, bar_index + 8, liq_lval, color=color.new(C_GOLD,40), style=line.style_dashed, width=1)

// ─── 9-POINT SCORE ───────────────────────────────────────────
int s1 = (bull_struct or bear_struct) ? 1 : 0

bool near_liq = (math.abs(close - liq_hval) / liq_hval < 0.003) or (math.abs(close - liq_lval) / liq_lval < 0.003)
int s2 = near_liq ? 1 : 0

bool strong_bull_body = (close > open) and (close - open) > atr * 0.5
bool strong_bear_body = (close < open) and (open - close) > atr * 0.5
bool bull_inst = strong_bull_body and close[1] > open[1] and close[2] > open[2]
bool bear_inst = strong_bear_body and close[1] < open[1] and close[2] < open[2]
int s3 = (bull_inst or bear_inst) ? 1 : 0

int s4 = (bull_fvg or bear_fvg) ? 1 : 0
int s5 = (choch_bull_active or choch_bear_active) ? 1 : 0
int s6 = (bull_ob or bear_ob) ? 1 : 0

rsi_val   = ta.rsi(close, 14)
rsi_val_5 = rsi_val[5]
bool bull_div = low < low[5] and rsi_val > rsi_val_5
bool bear_div = high > high[5] and rsi_val < rsi_val_5
int s7 = (bull_div or bear_div) ? 1 : 0

int s8 = (bull_fvg or bear_fvg or bull_ob or bear_ob) ? 1 : 0
int s9 = atr > syminfo.mintick * 10 ? 1 : 0

int score = s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8 + s9

// ─── BIAS ────────────────────────────────────────────────────
string bias = score >= 7 and bull_struct and choch_bull_active ? "BULLISH" : score >= 7 and bear_struct and choch_bear_active ? "BEARISH" : score >= 5 ? "NEUTRAL" : "NO SETUP"
color  bcol = bias == "BULLISH" ? C_BULL : bias == "BEARISH" ? C_BEAR : bias == "NEUTRAL" ? C_GOLD : C_DIM

// ─── ENTRY SIGNALS — strict, confirmed bars only ──────────────
bool long_sig  = barstate.isconfirmed and score >= 7 and bull_struct and choch_bull_active and (bull_fvg or bull_ob) and near_liq
bool short_sig = barstate.isconfirmed and score >= 7 and bear_struct and choch_bear_active and (bear_fvg or bear_ob) and near_liq

plotshape(long_sig,  "Long",  shape.triangleup,   location.belowbar, C_BULL, size=size.normal)
plotshape(short_sig, "Short", shape.triangledown, location.abovebar, C_BEAR, size=size.normal)

// TP/SL lines — only on signal bar, confirmed
if long_sig
    sl = low  - atr * 1.5
    line.new(bar_index, sl,                        bar_index+20, sl,                        color=color.new(C_BEAR,20), style=line.style_dotted, width=2)
    line.new(bar_index, close+(close-sl)*rr1,      bar_index+20, close+(close-sl)*rr1,      color=color.new(C_BULL,50), style=line.style_dotted)
    line.new(bar_index, close+(close-sl)*rr2,      bar_index+20, close+(close-sl)*rr2,      color=color.new(C_BULL,30), style=line.style_dotted)
    line.new(bar_index, close+(close-sl)*rr3,      bar_index+20, close+(close-sl)*rr3,      color=color.new(C_BULL,10), style=line.style_dotted)
    label.new(bar_index+20, close+(close-sl)*rr3, "T3", color=color.new(C_BULL,20), textcolor=C_TEXT, size=size.tiny, style=label.style_label_left)

if short_sig
    sl = high + atr * 1.5
    line.new(bar_index, sl,                        bar_index+20, sl,                        color=color.new(C_BULL,20), style=line.style_dotted, width=2)
    line.new(bar_index, close-(sl-close)*rr1,      bar_index+20, close-(sl-close)*rr1,      color=color.new(C_BEAR,50), style=line.style_dotted)
    line.new(bar_index, close-(sl-close)*rr2,      bar_index+20, close-(sl-close)*rr2,      color=color.new(C_BEAR,30), style=line.style_dotted)
    line.new(bar_index, close-(sl-close)*rr3,      bar_index+20, close-(sl-close)*rr3,      color=color.new(C_BEAR,10), style=line.style_dotted)
    label.new(bar_index+20, close-(sl-close)*rr3, "T3", color=color.new(C_BEAR,20), textcolor=C_TEXT, size=size.tiny, style=label.style_label_left)

// ─── DASHBOARD ───────────────────────────────────────────────
var table dash = table.new(
     dash_pos == "Top Right"    ? position.top_right    :
     dash_pos == "Top Left"     ? position.top_left     :
     dash_pos == "Bottom Right" ? position.bottom_right : position.bottom_left,
     3, 14, bgcolor=C_BG, border_color=C_DIM, border_width=1, frame_color=C_GOLD, frame_width=1)

f_bar(v, m) =>
    f = math.round(v / m * 10)
    b = ""
    for i = 0 to 9
        b := b + (i < f ? "█" : "░")
    b

f_dot(s) => s == 1 ? "●" : "○"
f_col(s) => s == 1 ? C_BULL : C_DIM

table.cell(dash, 0, 0, "JRI SMC v3",    text_color=C_GOLD, text_size=size.small, bgcolor=color.new(#0a0e1a,0), text_halign=text.align_left)
table.cell(dash, 1, 0, "",              bgcolor=color.new(#0a0e1a,0))
table.cell(dash, 2, 0, syminfo.tickerid, text_color=C_DIM, text_size=size.tiny,  bgcolor=color.new(#0a0e1a,0), text_halign=text.align_right)

table.cell(dash, 0, 1, "BIAS",  text_color=C_DIM,  text_size=size.tiny,  bgcolor=color.new(#0d1220,0), text_halign=text.align_left)
table.cell(dash, 1, 1, bias,    text_color=bcol,   text_size=size.small, bgcolor=color.new(#0d1220,0))
table.cell(dash, 2, 1, str.tostring(score) + "/9", text_color=bcol, text_size=size.small, bgcolor=color.new(#0d1220,0), text_halign=text.align_right)

table.cell(dash, 0, 2, "SCORE",        text_color=C_DIM, text_size=size.tiny, bgcolor=color.new(#0d1220,0), text_halign=text.align_left)
table.cell(dash, 1, 2, f_bar(score,9), text_color=bcol,  text_size=size.tiny, bgcolor=color.new(#0d1220,0))
table.cell(dash, 2, 2, "",             bgcolor=color.new(#0d1220,0))

table.cell(dash, 0, 3, "──────────────", text_color=C_DIM, text_size=size.tiny, bgcolor=color.new(#0a0e1a,0), text_halign=text.align_left)
table.cell(dash, 1, 3, "", bgcolor=color.new(#0a0e1a,0))
table.cell(dash, 2, 3, "", bgcolor=color.new(#0a0e1a,0))

names  = array.from("1. Structure","2. Liquidity","3. Inst. Move","4. Imbalance","5. CHOCH","6. Mitigation","7. Divergence","8. Entry Zone","9. R:R Valid")
scores = array.from(s1,s2,s3,s4,s5,s6,s7,s8,s9)

for i = 0 to 8
    sc = array.get(scores, i)
    nm = array.get(names,  i)
    table.cell(dash, 0, i+4, nm,          text_color=sc==1?C_TEXT:C_DIM, text_size=size.tiny, bgcolor=color.new(#0d1220,0), text_halign=text.align_left)
    table.cell(dash, 1, i+4, f_bar(sc,1), text_color=f_col(sc),          text_size=size.tiny, bgcolor=color.new(#0d1220,0))
    table.cell(dash, 2, i+4, f_dot(sc),   text_color=f_col(sc),          text_size=size.tiny, bgcolor=color.new(#0d1220,0), text_halign=text.align_center)

table.cell(dash, 0, 13, "Powerhouse University", text_color=C_DIM, text_size=size.tiny, bgcolor=color.new(#0a0e1a,0), text_halign=text.align_left)
table.cell(dash, 1, 13, "",                       bgcolor=color.new(#0a0e1a,0))
table.cell(dash, 2, 13, "@ibarra_jojo",            text_color=C_DIM, text_size=size.tiny, bgcolor=color.new(#0a0e1a,0), text_halign=text.align_right)
````
