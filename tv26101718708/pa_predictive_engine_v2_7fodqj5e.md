# PA Predictive Engine v2

- url: https://www.tradingview.com/script/7fODQJ5E-PA-Predictive-Engine-v2/
- type: indicator
- pine_id: PUB;5bf7dd3950424056a74595e20cc1a2c7
- version: 1.0

## Description

predictive price targets based on price action and removal of noise

## Source Code

````pine
// ============================================================
// PA PREDICTIVE ENGINE v2.0
// Pure Price Action Futures Prediction System
// with Price Target Ladder
//
// Methods:
//   1. Fractal Regression Channel
//   2. Adaptive Hull Momentum Oscillator
//   3. Institutional Order Block Detection
//   4. Market Structure (CHoCH / BOS)
//   5. Volatility-Weighted Projection Cone
//   6. K-NN Pattern Similarity Scoring
//   7. Price Target Engine (ATR, Fib, Swing, Regression, KNN)
// ============================================================

//@version=5
indicator("PA Predictive Engine v2", overlay=true, max_lines_count=500, max_labels_count=300, max_boxes_count=200)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
grp1 = "Core Settings"
lookback  = input.int(100, "Regression Lookback",     minval=20,  maxval=300, group=grp1)
proj_bars = input.int(20,  "Projection Bars Forward", minval=5,   maxval=50,  group=grp1)
swing_len = input.int(10,  "Swing Detection Length",  minval=3,   maxval=30,  group=grp1)
knn_depth = input.int(50,  "K-NN History Depth",      minval=20,  maxval=200, group=grp1)

grp2 = "Display"
show_reg     = input.bool(true,  "Show Regression Channel",  group=grp2)
show_ob      = input.bool(true,  "Show Order Blocks",        group=grp2)
show_struct  = input.bool(true,  "Show Market Structure",    group=grp2)
show_proj    = input.bool(true,  "Show Projection Cone",     group=grp2)
show_targets = input.bool(true,  "Show Price Targets",       group=grp2)
show_dash    = input.bool(true,  "Show Dashboard",           group=grp2)
tgt_extend   = input.int(40,     "Target Line Length (bars)", minval=10, maxval=200, group=grp2)

grp3 = "Colors"
bull_col = input.color(color.new(#00e5ff, 0), "Bullish Color", group=grp3)
bear_col = input.color(color.new(#ff1744, 0), "Bearish Color", group=grp3)
neut_col = input.color(color.new(#ffd600, 0), "Neutral Color", group=grp3)
tgt_col  = input.color(color.new(#b388ff, 0), "Target Color",  group=grp3)

// ─────────────────────────────────────────────
// UTILITIES
// ─────────────────────────────────────────────
pine_hma(src, len) =>
    wma1 = ta.wma(src, math.round(len / 2))
    wma2 = ta.wma(src, len)
    ta.wma(2 * wma1 - wma2, math.round(math.sqrt(len)))

normalize(val, len) =>
    lo  = ta.lowest(val,  len)
    hi  = ta.highest(val, len)
    rng = hi - lo
    rng == 0 ? 0.5 : (val - lo) / rng

price_str(p) =>
    str.tostring(math.round(p, 2))

// ─────────────────────────────────────────────
// 1. FRACTAL REGRESSION CHANNEL
// ─────────────────────────────────────────────
reg_src   = close
reg_y     = ta.linreg(reg_src, lookback, 0)
reg_slope = ta.linreg(reg_src, lookback, 0) - ta.linreg(reg_src, lookback, 1)

reg_std_close = ta.stdev(reg_src, lookback)
reg_corr      = ta.correlation(reg_src, bar_index, lookback)
reg_r2        = reg_corr * reg_corr
reg_std       = reg_std_close * math.sqrt(math.max(0, 1 - reg_r2))

reg_upper = reg_y + 2.0 * reg_std
reg_lower = reg_y - 2.0 * reg_std
reg_mid   = reg_y
reg_bull  = close > reg_mid
reg_col   = reg_bull ? color.new(bull_col, 75) : color.new(bear_col, 75)

plot(show_reg ? reg_upper : na, "Reg Upper", color=color.new(bull_col, 50), linewidth=1)
plot(show_reg ? reg_mid   : na, "Reg Mid",   color=color.new(neut_col, 30), linewidth=1)
plot(show_reg ? reg_lower : na, "Reg Lower", color=color.new(bear_col, 50), linewidth=1)
p_reg_upper = plot(show_reg ? reg_upper : na, display=display.none)
p_reg_lower = plot(show_reg ? reg_lower : na, display=display.none)
fill(p_reg_upper, p_reg_lower, color=reg_col, title="Reg Fill")

// ─────────────────────────────────────────────
// 2. ADAPTIVE HULL MOMENTUM OSCILLATOR
// ─────────────────────────────────────────────
mom_len    = math.round(lookback / 4)
roc_raw    = (close - close[mom_len]) / close[mom_len] * 100
hull_mom   = pine_hma(roc_raw, mom_len)
hull_mom_s = pine_hma(roc_raw, mom_len * 2)

mom_accel = hull_mom - hull_mom[2]
mom_bull  = hull_mom > hull_mom_s and mom_accel > 0
mom_bear  = hull_mom < hull_mom_s and mom_accel < 0
mom_score = normalize(hull_mom, lookback)

// ─────────────────────────────────────────────
// 3. INSTITUTIONAL ORDER BLOCK DETECTION
// ─────────────────────────────────────────────
body      = math.abs(close - open)
avg_body  = ta.sma(body, 20)
is_ob_bar = body > avg_body * 1.5

bull_run = close > close[3] and close[1] > close[4]
bear_run = close < close[3] and close[1] < close[4]

bull_ob_hi = float(na)
bull_ob_lo = float(na)
bear_ob_hi = float(na)
bear_ob_lo = float(na)

if is_ob_bar[1] and close[1] < open[1] and bull_run
    bull_ob_hi := math.max(open[1], close[1])
    bull_ob_lo := math.min(open[1], close[1])

if is_ob_bar[1] and close[1] > open[1] and bear_run
    bear_ob_hi := math.max(open[1], close[1])
    bear_ob_lo := math.min(open[1], close[1])

var box bull_ob_box = na
var box bear_ob_box = na

if show_ob and not na(bull_ob_hi)
    bull_ob_box := box.new(bar_index - 1, bull_ob_hi, bar_index + proj_bars, bull_ob_lo,
         border_color=color.new(bull_col, 30), bgcolor=color.new(bull_col, 85), border_width=1)

if show_ob and not na(bear_ob_hi)
    bear_ob_box := box.new(bar_index - 1, bear_ob_hi, bar_index + proj_bars, bear_ob_lo,
         border_color=color.new(bear_col, 30), bgcolor=color.new(bear_col, 85), border_width=1)

ob_bull_dist = na(bull_ob_lo) ? 0.0 : math.max(0, 1 - math.abs(close - (bull_ob_hi + bull_ob_lo) / 2) / (close * 0.01))
ob_bear_dist = na(bear_ob_hi) ? 0.0 : math.max(0, 1 - math.abs(close - (bear_ob_hi + bear_ob_lo) / 2) / (close * 0.01))
ob_score     = ob_bull_dist - ob_bear_dist

// ─────────────────────────────────────────────
// 4. MARKET STRUCTURE: SWING DETECTION + BOS
// ─────────────────────────────────────────────
swing_hi = ta.pivothigh(high, swing_len, swing_len)
swing_lo = ta.pivotlow(low,  swing_len, swing_len)

var float last_hh     = na
var float last_lh     = na
var float last_ll     = na
var float last_hl     = na
var int   last_hh_bar = na
var int   last_ll_bar = na
var int   struct_bias = 0

if not na(swing_hi)
    if na(last_hh) or swing_hi > last_hh
        last_hh     := swing_hi
        last_hh_bar := bar_index - swing_len
    else
        last_lh := swing_hi

if not na(swing_lo)
    if na(last_ll) or swing_lo < last_ll
        last_ll     := swing_lo
        last_ll_bar := bar_index - swing_len
    else
        last_hl := swing_lo

bos_bull = not na(last_hh) and close > last_hh
bos_bear = not na(last_ll)  and close < last_ll

hh_hl = not na(last_hh) and not na(last_hl) and last_hh > last_hh[1] and last_hl > last_hl[1]
ll_lh = not na(last_ll)  and not na(last_lh)  and last_ll  < last_ll[1]  and last_lh  < last_lh[1]
struct_bias := hh_hl ? 1 : ll_lh ? -1 : struct_bias

if show_struct and bos_bull and not bos_bull[1]
    label.new(bar_index, high, "BOS ▲", color=color.new(bull_col, 20),
         textcolor=color.white, style=label.style_label_down, size=size.small)

if show_struct and bos_bear and not bos_bear[1]
    label.new(bar_index, low, "BOS ▼", color=color.new(bear_col, 20),
         textcolor=color.white, style=label.style_label_up, size=size.small)

plotshape(show_struct and not na(swing_hi), "Swing High", shape.triangledown, location.abovebar,
     color=color.new(bear_col, 40), size=size.tiny, offset=-swing_len)
plotshape(show_struct and not na(swing_lo), "Swing Low",  shape.triangleup,   location.belowbar,
     color=color.new(bull_col, 40), size=size.tiny, offset=-swing_len)

// ─────────────────────────────────────────────
// 5. VOLATILITY-WEIGHTED PROJECTION CONE
// ─────────────────────────────────────────────
atr_len  = 14
atr_val  = ta.atr(atr_len)
atr_norm = atr_val / close

combined_bias = (mom_score - 0.5) * 0.4 + float(struct_bias) * 0.3 + ob_score * 0.3
proj_dir      = combined_bias > 0.05 ? 1 : combined_bias < -0.05 ? -1 : 0

if show_proj and barstate.islast
    slope_per_bar = proj_dir * atr_val * 0.5
    for i = 1 to proj_bars
        t1    = bar_index + i - 1
        t2    = bar_index + i
        mid1  = close + slope_per_bar * (i - 1)
        mid2  = close + slope_per_bar * i
        exp   = math.sqrt(i) * atr_val * 0.5
        u1    = mid1 + exp * (i - 1) / proj_bars
        u2    = mid2 + exp * i / proj_bars
        l1    = mid1 - exp * (i - 1) / proj_bars
        l2    = mid2 - exp * i / proj_bars
        pc    = proj_dir > 0 ? bull_col : proj_dir < 0 ? bear_col : neut_col
        line.new(t1, mid1, t2, mid2, color=color.new(pc, 0),  width=2, style=line.style_dashed)
        line.new(t1, u1,   t2, u2,   color=color.new(pc, 60), width=1, style=line.style_dotted)
        line.new(t1, l1,   t2, l2,   color=color.new(pc, 60), width=1, style=line.style_dotted)

// ─────────────────────────────────────────────
// 6. K-NN PATTERN SIMILARITY ENGINE
// ─────────────────────────────────────────────
f1 = (close - open)    / close
f2 = (high  - low)     / close
f3 = (close - close[1]) / close[1]
f4 = (close - close[2]) / close[2]
f5 = (close - close[4]) / close[4]

dist(i) =>
    g1 = (close[i] - open[i])    / close[i]
    g2 = (high[i]  - low[i])     / close[i]
    g3 = (close[i] - close[i+1]) / close[i+1]
    g4 = (close[i] - close[i+2]) / close[i+2]
    g5 = (close[i] - close[i+4]) / close[i+4]
    math.sqrt(math.pow(f1-g1,2) + math.pow(f2-g2,2) + math.pow(f3-g3,2) + math.pow(f4-g4,2) + math.pow(f5-g5,2))

var float knn_sum_ret = 0.0
var float knn_sum_wgt = 0.0
knn_sum_ret := 0.0
knn_sum_wgt := 0.0

for i = 6 to knn_depth
    d = dist(i)
    if d > 0
        w           = 1.0 / (d * d + 1e-10)
        fwd_ret     = (close[i - 5] - close[i]) / close[i]
        knn_sum_ret += fwd_ret * w
        knn_sum_wgt += w

knn_pred_ret   = knn_sum_wgt > 0 ? knn_sum_ret / knn_sum_wgt : 0.0
knn_pred_dir   = knn_pred_ret > 0.0005 ? 1 : knn_pred_ret < -0.0005 ? -1 : 0
knn_confidence = math.min(100, math.abs(knn_pred_ret) * 10000)
knn_score      = normalize(knn_pred_ret, lookback)
knn_move       = close * knn_pred_ret  // absolute predicted price move

// ─────────────────────────────────────────────
// COMPOSITE PREDICTION SCORE
// ─────────────────────────────────────────────
composite  = (reg_bull ? 1.0 : -1.0)  * 0.15 +
     (mom_score - 0.5) * 2 * 0.25 +
     ob_score * 0.15 +
     float(struct_bias) * 0.20 +
     (knn_score - 0.5) * 2 * 0.25

comp_norm    = math.max(-1, math.min(1, composite))
comp_bull    = comp_norm > 0.1
comp_bear    = comp_norm < -0.1
comp_pct     = math.round(math.abs(comp_norm) * 100)
comp_dir_str = comp_bull ? "BULLISH" : comp_bear ? "BEARISH" : "NEUTRAL"
comp_col     = comp_bull ? bull_col  : comp_bear ? bear_col  : neut_col

// ─────────────────────────────────────────────
// 7. PRICE TARGET ENGINE
// ─────────────────────────────────────────────
// Derives realistic price targets from 5 independent PA sources.
// All targets drawn as labeled horizontal lines extending right.
// Bull targets above price, bear targets below price.
// Targets are graded: T1 (nearest/highest prob) → T3 (extended)
// ─────────────────────────────────────────────

// ── Fibonacci swing leg ──────────────────────
// Use last swing high and low to project fib extensions
var float fib_swing_lo = na
var float fib_swing_hi = na

if not na(swing_lo)
    fib_swing_lo := swing_lo
if not na(swing_hi)
    fib_swing_hi := swing_hi

fib_rng = not na(fib_swing_hi) and not na(fib_swing_lo) ? fib_swing_hi - fib_swing_lo : atr_val * 5

// Bull fib extensions (projecting up from swing low using swing range)
fib_bull_618  = not na(fib_swing_hi) ? fib_swing_hi + fib_rng * 0.618 : close + atr_val * 2
fib_bull_100  = not na(fib_swing_hi) ? fib_swing_hi + fib_rng * 1.000 : close + atr_val * 3
fib_bull_1618 = not na(fib_swing_hi) ? fib_swing_hi + fib_rng * 1.618 : close + atr_val * 5

// Bear fib extensions (projecting down from swing high)
fib_bear_618  = not na(fib_swing_lo) ? fib_swing_lo - fib_rng * 0.618 : close - atr_val * 2
fib_bear_100  = not na(fib_swing_lo) ? fib_swing_lo - fib_rng * 1.000 : close - atr_val * 3
fib_bear_1618 = not na(fib_swing_lo) ? fib_swing_lo - fib_rng * 1.618 : close - atr_val * 5

// ── ATR-based targets ────────────────────────
atr_t1_bull = close + atr_val * 1.0
atr_t2_bull = close + atr_val * 2.0
atr_t3_bull = close + atr_val * 3.5

atr_t1_bear = close - atr_val * 1.0
atr_t2_bear = close - atr_val * 2.0
atr_t3_bear = close - atr_val * 3.5

// ── KNN predicted target ─────────────────────
knn_target = close + knn_move

// ── Composite final targets ──────────────────
// Blend sources by weighting: ATR(30%) + Fib(35%) + Reg channel(20%) + KNN(15%)
// For BULL targets:
bull_t1 = atr_t1_bull * 0.30 + fib_bull_618  * 0.35 + reg_upper * 0.20 + (close + math.abs(knn_move)) * 0.15
bull_t2 = atr_t2_bull * 0.30 + fib_bull_100  * 0.35 + reg_upper * 0.20 + (close + math.abs(knn_move) * 1.5) * 0.15
bull_t3 = atr_t3_bull * 0.30 + fib_bull_1618 * 0.35 + (reg_upper + reg_std) * 0.20 + (close + math.abs(knn_move) * 2.5) * 0.15

// For BEAR targets:
bear_t1 = atr_t1_bear * 0.30 + fib_bear_618  * 0.35 + reg_lower * 0.20 + (close - math.abs(knn_move)) * 0.15
bear_t2 = atr_t2_bear * 0.30 + fib_bear_100  * 0.35 + reg_lower * 0.20 + (close - math.abs(knn_move) * 1.5) * 0.15
bear_t3 = atr_t3_bear * 0.30 + fib_bear_1618 * 0.35 + (reg_lower - reg_std) * 0.20 + (close - math.abs(knn_move) * 2.5) * 0.15

// Invalidation / stop reference (opposite ATR + reg boundary)
inval_bull = comp_bull ? (atr_t1_bear * 0.5 + reg_lower * 0.5) : na
inval_bear = comp_bear ? (atr_t1_bull * 0.5 + reg_upper * 0.5) : na

// ── Draw price target lines ──────────────────
draw_target(price, lbl, is_bull, opacity, lbl_style) =>
    col = is_bull ? bull_col : bear_col
    x1  = bar_index
    x2  = bar_index + tgt_extend
    ln  = line.new(x1, price, x2, price,
         color    = color.new(col, opacity),
         width    = 2,
         style    = line.style_dashed,
         extend   = extend.none)
    lb  = label.new(x2, price, lbl + "  " + price_str(price),
         color    = color.new(col, opacity - 20 < 0 ? 0 : opacity - 20),
         textcolor = color.white,
         style    = lbl_style,
         size     = size.small)

if show_targets and barstate.islast
    if comp_bull
        // Bull targets — draw T1, T2, T3 above price
        draw_target(bull_t1, "T1 ▲", true,  10, label.style_label_left)
        draw_target(bull_t2, "T2 ▲", true,  30, label.style_label_left)
        draw_target(bull_t3, "T3 ▲", true,  55, label.style_label_left)

        // Invalidation level below (where the bull case breaks)
        if not na(inval_bull)
            line.new(bar_index, inval_bull, bar_index + tgt_extend, inval_bull,
                 color=color.new(bear_col, 30), width=1, style=line.style_dotted)
            label.new(bar_index + tgt_extend, inval_bull, "INVAL  " + price_str(inval_bull),
                 color=color.new(bear_col, 30), textcolor=color.white,
                 style=label.style_label_left, size=size.small)

        // Swing magnet reference
        if not na(last_hh)
            line.new(bar_index, last_hh, bar_index + tgt_extend, last_hh,
                 color=color.new(neut_col, 40), width=1, style=line.style_dotted)
            label.new(bar_index + tgt_extend, last_hh, "HH MAG  " + price_str(last_hh),
                 color=color.new(neut_col, 40), textcolor=color.white,
                 style=label.style_label_left, size=size.small)

        // KNN target
        if knn_pred_dir > 0
            line.new(bar_index, knn_target, bar_index + tgt_extend, knn_target,
                 color=color.new(tgt_col, 20), width=1, style=line.style_dashed)
            label.new(bar_index + tgt_extend, knn_target, "KNN ▲  " + price_str(knn_target),
                 color=color.new(tgt_col, 20), textcolor=color.white,
                 style=label.style_label_left, size=size.small)

    else if comp_bear
        // Bear targets — draw T1, T2, T3 below price
        draw_target(bear_t1, "T1 ▼", false, 10, label.style_label_left)
        draw_target(bear_t2, "T2 ▼", false, 30, label.style_label_left)
        draw_target(bear_t3, "T3 ▼", false, 55, label.style_label_left)

        // Invalidation level above (where the bear case breaks)
        if not na(inval_bear)
            line.new(bar_index, inval_bear, bar_index + tgt_extend, inval_bear,
                 color=color.new(bull_col, 30), width=1, style=line.style_dotted)
            label.new(bar_index + tgt_extend, inval_bear, "INVAL  " + price_str(inval_bear),
                 color=color.new(bull_col, 30), textcolor=color.white,
                 style=label.style_label_left, size=size.small)

        // Swing magnet reference
        if not na(last_ll)
            line.new(bar_index, last_ll, bar_index + tgt_extend, last_ll,
                 color=color.new(neut_col, 40), width=1, style=line.style_dotted)
            label.new(bar_index + tgt_extend, last_ll, "LL MAG  " + price_str(last_ll),
                 color=color.new(neut_col, 40), textcolor=color.white,
                 style=label.style_label_left, size=size.small)

        // KNN target
        if knn_pred_dir < 0
            line.new(bar_index, knn_target, bar_index + tgt_extend, knn_target,
                 color=color.new(tgt_col, 20), width=1, style=line.style_dashed)
            label.new(bar_index + tgt_extend, knn_target, "KNN ▼  " + price_str(knn_target),
                 color=color.new(tgt_col, 20), textcolor=color.white,
                 style=label.style_label_left, size=size.small)

    else
        // Neutral — show both nearest targets + swing magnets
        draw_target(bull_t1, "R1 ▲", true,  20, label.style_label_left)
        draw_target(bear_t1, "S1 ▼", false, 20, label.style_label_left)
        if not na(last_hh)
            line.new(bar_index, last_hh, bar_index + tgt_extend, last_hh,
                 color=color.new(neut_col, 40), width=1, style=line.style_dotted)
            label.new(bar_index + tgt_extend, last_hh, "HH  " + price_str(last_hh),
                 color=color.new(neut_col, 40), textcolor=color.white,
                 style=label.style_label_left, size=size.small)
        if not na(last_ll)
            line.new(bar_index, last_ll, bar_index + tgt_extend, last_ll,
                 color=color.new(neut_col, 40), width=1, style=line.style_dotted)
            label.new(bar_index + tgt_extend, last_ll, "LL  " + price_str(last_ll),
                 color=color.new(neut_col, 40), textcolor=color.white,
                 style=label.style_label_left, size=size.small)

// ─────────────────────────────────────────────
// TARGET SUMMARY TABLE (bottom-left)
// ─────────────────────────────────────────────
if show_targets and show_dash and barstate.islast
    var table tgt_table = table.new(position.bottom_left, 3, 6,
         bgcolor=color.new(#0a0e1a, 5),
         border_color=color.new(#ffffff, 80), border_width=1,
         frame_color=color.new(#ffffff, 70), frame_width=1)

    hdr_bg = color.new(#1a1f35, 0)
    row_bg = color.new(#0d1321, 10)

    table.cell(tgt_table, 0, 0, "TARGET",     text_color=color.white, bgcolor=hdr_bg, text_size=size.small)
    table.cell(tgt_table, 1, 0, "PRICE",      text_color=color.white, bgcolor=hdr_bg, text_size=size.small)
    table.cell(tgt_table, 2, 0, "DIST %",     text_color=color.white, bgcolor=hdr_bg, text_size=size.small)

    t_prices = comp_bull ? array.from(bull_t1, bull_t2, bull_t3) :
         comp_bear ? array.from(bear_t1, bear_t2, bear_t3) :
         array.from(bull_t1, bear_t1, float(na))

    t_labels = comp_bull ? array.from("T1 ▲ (61.8%)", "T2 ▲ (100%)", "T3 ▲ (161.8%)") :
         comp_bear ? array.from("T1 ▼ (61.8%)", "T2 ▼ (100%)", "T3 ▼ (161.8%)") :
         array.from("R1 ▲ Resist", "S1 ▼ Supprt", "—")

    t_cols = comp_bull ? array.from(bull_col, bull_col, bull_col) :
         comp_bear ? array.from(bear_col, bear_col, bear_col) :
         array.from(bull_col, bear_col, neut_col)

    for r = 0 to 2
        tp  = array.get(t_prices, r)
        tlb = array.get(t_labels, r)
        tc  = array.get(t_cols, r)
        if not na(tp)
            dist_pct = math.round((tp - close) / close * 1000) / 10
            dist_str = (dist_pct >= 0 ? "+" : "") + str.tostring(dist_pct) + "%"
            table.cell(tgt_table, 0, r + 1, tlb,             text_color=tc,           bgcolor=row_bg, text_size=size.small)
            table.cell(tgt_table, 1, r + 1, price_str(tp),   text_color=color.white,  bgcolor=row_bg, text_size=size.small)
            table.cell(tgt_table, 2, r + 1, dist_str,        text_color=tc,           bgcolor=row_bg, text_size=size.small)
        else
            table.cell(tgt_table, 0, r + 1, "—", text_color=neut_col, bgcolor=row_bg, text_size=size.small)
            table.cell(tgt_table, 1, r + 1, "—", text_color=neut_col, bgcolor=row_bg, text_size=size.small)
            table.cell(tgt_table, 2, r + 1, "—", text_color=neut_col, bgcolor=row_bg, text_size=size.small)

    // KNN row
    knn_dist = math.round((knn_target - close) / close * 1000) / 10
    knn_dist_str = (knn_dist >= 0 ? "+" : "") + str.tostring(knn_dist) + "%"
    table.cell(tgt_table, 0, 4, "KNN Pattern Tgt", text_color=tgt_col,      bgcolor=row_bg, text_size=size.small)
    table.cell(tgt_table, 1, 4, price_str(knn_target), text_color=color.white, bgcolor=row_bg, text_size=size.small)
    table.cell(tgt_table, 2, 4, knn_dist_str,       text_color=tgt_col,      bgcolor=row_bg, text_size=size.small)

    // Inval row
    inval_price = comp_bull ? inval_bull : comp_bear ? inval_bear : na
    if not na(inval_price)
        inval_dist = math.round((inval_price - close) / close * 1000) / 10
        inval_str  = (inval_dist >= 0 ? "+" : "") + str.tostring(inval_dist) + "%"
        inval_lbl  = comp_bull ? "Inval (bear flip)" : "Inval (bull flip)"
        table.cell(tgt_table, 0, 5, inval_lbl,           text_color=bear_col,    bgcolor=row_bg, text_size=size.small)
        table.cell(tgt_table, 1, 5, price_str(inval_price), text_color=color.white, bgcolor=row_bg, text_size=size.small)
        table.cell(tgt_table, 2, 5, inval_str,           text_color=bear_col,    bgcolor=row_bg, text_size=size.small)

// ─────────────────────────────────────────────
// SIGNAL DASHBOARD (top-right)
// ─────────────────────────────────────────────
if show_dash and barstate.islast
    var table dash = table.new(position.top_right, 2, 9,
         bgcolor=color.new(#0a0e1a, 5),
         border_color=color.new(#ffffff, 80), border_width=1,
         frame_color=color.new(#ffffff, 70), frame_width=1)

    table.cell(dash, 0, 0, "PA PREDICTIVE ENGINE v2", text_color=color.white,
         bgcolor=color.new(#0a0e1a, 0), text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 1, 0, "SIGNAL", text_color=color.white,
         bgcolor=color.new(#0a0e1a, 0), text_size=size.small, text_halign=text.align_center)

    row_bg = color.new(#0d1321, 10)

    reg_str = reg_bull ? "↑ ABOVE MID" : "↓ BELOW MID"
    table.cell(dash, 0, 1, "Regression",    text_color=color.new(#aaaaaa, 0), bgcolor=row_bg, text_size=size.small)
    table.cell(dash, 1, 1, reg_str,         text_color=reg_bull ? bull_col : bear_col, bgcolor=row_bg, text_size=size.small)

    mom_str = mom_bull ? "↑ ACCEL UP" : mom_bear ? "↓ ACCEL DN" : "→ FLAT"
    table.cell(dash, 0, 2, "Hull Momentum", text_color=color.new(#aaaaaa, 0), bgcolor=row_bg, text_size=size.small)
    table.cell(dash, 1, 2, mom_str,         text_color=mom_bull ? bull_col : mom_bear ? bear_col : neut_col, bgcolor=row_bg, text_size=size.small)

    ob_str = ob_score > 0.1 ? "↑ BULL OB" : ob_score < -0.1 ? "↓ BEAR OB" : "→ NONE"
    table.cell(dash, 0, 3, "Order Block",   text_color=color.new(#aaaaaa, 0), bgcolor=row_bg, text_size=size.small)
    table.cell(dash, 1, 3, ob_str,          text_color=ob_score > 0.1 ? bull_col : ob_score < -0.1 ? bear_col : neut_col, bgcolor=row_bg, text_size=size.small)

    str_str = struct_bias > 0 ? "↑ BULLISH" : struct_bias < 0 ? "↓ BEARISH" : "→ UNDEF"
    table.cell(dash, 0, 4, "Mkt Structure", text_color=color.new(#aaaaaa, 0), bgcolor=row_bg, text_size=size.small)
    table.cell(dash, 1, 4, str_str,         text_color=struct_bias > 0 ? bull_col : struct_bias < 0 ? bear_col : neut_col, bgcolor=row_bg, text_size=size.small)

    knn_str = knn_pred_dir > 0 ? "↑ UP " + str.tostring(math.round(knn_confidence)) + "bp" :
         knn_pred_dir < 0 ? "↓ DN " + str.tostring(math.round(knn_confidence)) + "bp" : "→ NEUT"
    table.cell(dash, 0, 5, "K-NN Pattern",  text_color=color.new(#aaaaaa, 0), bgcolor=row_bg, text_size=size.small)
    table.cell(dash, 1, 5, knn_str,         text_color=knn_pred_dir > 0 ? bull_col : knn_pred_dir < 0 ? bear_col : neut_col, bgcolor=row_bg, text_size=size.small)

    table.cell(dash, 0, 6, "ATR",           text_color=color.new(#aaaaaa, 0), bgcolor=row_bg, text_size=size.small)
    table.cell(dash, 1, 6, str.tostring(math.round(atr_norm * 10000) / 100) + "% | " + price_str(atr_val),
         text_color=neut_col, bgcolor=row_bg, text_size=size.small)

    table.cell(dash, 0, 7, "Proj Direction", text_color=color.new(#aaaaaa, 0), bgcolor=row_bg, text_size=size.small)
    table.cell(dash, 1, 7, proj_dir > 0 ? "↑ LONG BIAS" : proj_dir < 0 ? "↓ SHORT BIAS" : "→ NEUTRAL",
         text_color=proj_dir > 0 ? bull_col : proj_dir < 0 ? bear_col : neut_col, bgcolor=row_bg, text_size=size.small)

    comp_bg = comp_bull ? color.new(#00e5ff, 60) : comp_bear ? color.new(#ff1744, 60) : color.new(#ffd600, 60)
    table.cell(dash, 0, 8, "▶ COMPOSITE",   text_color=color.white, bgcolor=comp_bg, text_size=size.small)
    table.cell(dash, 1, 8, comp_dir_str + " " + str.tostring(comp_pct) + "%",
         text_color=color.white, bgcolor=comp_bg, text_size=size.small)

// ─────────────────────────────────────────────
// BAR COLOR + ALERTS
// ─────────────────────────────────────────────
barcolor(comp_bull ? color.new(bull_col, 60) : comp_bear ? color.new(bear_col, 60) : na)

alertcondition(comp_bull and not comp_bull[1], "Composite BULLISH", "PA Engine: Bias flipped BULLISH")
alertcondition(comp_bear and not comp_bear[1], "Composite BEARISH", "PA Engine: Bias flipped BEARISH")
alertcondition(bos_bull,                       "BOS Bullish",       "PA Engine: Bullish BOS")
alertcondition(bos_bear,                       "BOS Bearish",       "PA Engine: Bearish BOS")
alertcondition(ta.crossover(close, bull_t1),   "Hit T1 Bull",       "PA Engine: Price hit Bull T1 target")
alertcondition(ta.crossunder(close, bear_t1),  "Hit T1 Bear",       "PA Engine: Price hit Bear T1 target")
````
