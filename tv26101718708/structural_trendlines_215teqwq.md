# Structural Trendlines

- url: https://www.tradingview.com/script/215tEQWQ-Structural-Trendlines/
- type: indicator
- pine_id: PUB;6adeb17da8904b339887c0746c8d76b1
- version: 2.0

## Description

Automatically detects structural trendlines anchored at confirmed pivot highs (Lower Highs) and pivot lows (Higher Lows), drawing only lines the market
  has genuinely respected — every bar between the anchor and touch pivot must stay clean, with no wick violations beyond tolerance. Steep, parabolic lines
  are filtered out using rolling angle normalization, and anchors expire after a configurable number of bars so the indicator never draws from forgotten
  history. A signal fires only when price closes beyond the projected line — not a wick — eliminating false breakouts from intraday noise. Stop-loss is
  automatically set to the low of the break candle (bullish) or the high (bearish).

## Source Code

````pine
//@version=6
indicator("Structural Trendlines", overlay=true, max_lines_count=500)

PIVOT_LEN       = input.int(7,      "Pivot Length",          minval=2,  maxval=20)
max_angle_deg   = input.float(60.0, "Max Angle (°)",         minval=1.0, maxval=89.0, step=0.5)
max_look_ahead  = input.int(100,    "Max Look-Ahead Bars",   minval=10,  maxval=1000)
angle_norm_bars = input.int(2000,    "Angle Norm Bars",       minval=50,  maxval=2000)
chart_aspect    = input.float(1.0,  "Chart Aspect (H/W)",    minval=0.1, maxval=5.0,  step=0.1)
wick_tolerance  = input.float(0.0, "Wick Tolerance (pts)",  minval=0.0, maxval=200.0, step=0.5)

var sup_anc_bar   = array.new_int(0)
var sup_anc_price = array.new_float(0)
var res_anc_bar   = array.new_int(0)
var res_anc_price = array.new_float(0)
var line_objs     = array.new_line(0)
var line_anc_bar  = array.new_int(0)
var line_side     = array.new_int(0)
var line_live     = array.new_bool(0)
var line_slope    = array.new_float(0)   // ← slope stored per line
var line_p2_bar   = array.new_int(0)     // ← P2 bar stored for break-delay check

f_visual_angle(anchor_b, touch_b, price_chg, p_range, tot_bars, aspect) =>
    bar_span = touch_b - anchor_b
    if bar_span <= 0 or p_range <= 0.0 or tot_bars <= 0
        0.0
    else
        norm_p = math.abs(price_chg) / p_range
        norm_b = bar_span / float(tot_bars)
        math.atan(norm_p / norm_b * aspect) * 180.0 / math.pi

f_expire_anchors(anc_bar_arr, anc_price_arr, cur_bar, max_la) =>
    i = array.size(anc_bar_arr) - 1
    while i >= 0
        if cur_bar - array.get(anc_bar_arr, i) > max_la
            array.remove(anc_bar_arr,   i)
            array.remove(anc_price_arr, i)
        i := i - 1

f_clean_between(anc_bar, anc_price, p2_bar, p2_price, side, tol) =>
    valid  = true
    span   = p2_bar - anc_bar
    if span > 1
        slope  = (p2_price - anc_price) / float(span)
        k      = 1
        cur_bi = bar_index
        while k <= span - 1 and valid
            off    = cur_bi - (anc_bar + k)
            proj_k = anc_price + slope * float(k)
            if side == 0
                if low[off] < proj_k - tol
                    valid := false
            else
                if high[off] > proj_k + tol
                    valid := false
            k := k + 1
    valid

p_range  = ta.highest(high, angle_norm_bars) - ta.lowest(low, angle_norm_bars)
tot_bars = math.min(bar_index + 1, angle_norm_bars)
piv_lo   = ta.pivotlow(low,   PIVOT_LEN, PIVOT_LEN)
piv_hi   = ta.pivothigh(high, PIVOT_LEN, PIVOT_LEN)
p_bar    = bar_index - PIVOT_LEN

// ── SUPPORT ────────────────────────────────────────────────────────────────
if not na(piv_lo)
    piv_price = piv_lo
    f_expire_anchors(sup_anc_bar, sup_anc_price, p_bar, max_look_ahead)
    n = array.size(sup_anc_bar)
    if n > 0
        j = n - 1
        while j >= 0
            anc_bar   = array.get(sup_anc_bar,   j)
            anc_price = array.get(sup_anc_price, j)
            if piv_price > anc_price
                ang = f_visual_angle(anc_bar, p_bar, piv_price - anc_price, p_range, tot_bars, chart_aspect)
                if ang <= max_angle_deg
                    if f_clean_between(anc_bar, anc_price, p_bar, piv_price, 0, wick_tolerance)
                        sl = (piv_price - anc_price) / float(p_bar - anc_bar)
                        ln = line.new(x1=anc_bar, y1=anc_price, x2=p_bar, y2=piv_price,
                                      xloc=xloc.bar_index, extend=extend.none,
                                      color=color.red, width=2)
                        array.push(line_objs,    ln)
                        array.push(line_anc_bar, anc_bar)
                        array.push(line_side,    0)
                        array.push(line_live,    true)
                        array.push(line_slope,   sl)
                        array.push(line_p2_bar,  p_bar)
            j := j - 1
    array.push(sup_anc_bar,   p_bar)
    array.push(sup_anc_price, piv_price)

// ── RESISTANCE ─────────────────────────────────────────────────────────────
if not na(piv_hi)
    piv_price = piv_hi
    f_expire_anchors(res_anc_bar, res_anc_price, p_bar, max_look_ahead)
    n = array.size(res_anc_bar)
    if n > 0
        j = n - 1
        while j >= 0
            anc_bar   = array.get(res_anc_bar,   j)
            anc_price = array.get(res_anc_price, j)
            if piv_price < anc_price
                ang = f_visual_angle(anc_bar, p_bar, anc_price - piv_price, p_range, tot_bars, chart_aspect)
                if ang <= max_angle_deg
                    if f_clean_between(anc_bar, anc_price, p_bar, piv_price, 1, wick_tolerance)
                        sl = (piv_price - anc_price) / float(p_bar - anc_bar)
                        ln = line.new(x1=anc_bar, y1=anc_price, x2=p_bar, y2=piv_price,
                                      xloc=xloc.bar_index, extend=extend.none,
                                      color=color.green, width=2)
                        array.push(line_objs,    ln)
                        array.push(line_anc_bar, anc_bar)
                        array.push(line_side,    1)
                        array.push(line_live,    true)
                        array.push(line_slope,   sl)
                        array.push(line_p2_bar,  p_bar)
            j := j - 1
    array.push(res_anc_bar,   p_bar)
    array.push(res_anc_price, piv_price)

// ── Per-bar: extend live lines to current candle; detect breaks ────────────
n_lines = array.size(line_objs)
if n_lines > 0
    for i = 0 to n_lines - 1
        if array.get(line_live, i)
            ln    = array.get(line_objs,   i)
            lx1   = line.get_x1(ln)
            ly1   = line.get_y1(ln)
            sl    = array.get(line_slope,  i)
            p2b   = array.get(line_p2_bar, i)
            proj  = ly1 + sl * (bar_index - lx1)
            // Always draw line body up to the current (last) candle
            line.set_x2(ln, bar_index)
            line.set_y2(ln, proj)
            // Only start checking for break after PIVOT_LEN bars past P2
            if bar_index > p2b + PIVOT_LEN
                side   = array.get(line_side, i)
                broken = side == 0 and close < proj
                if not broken
                    broken := side == 1 and close > proj
                if broken
                    line.set_color(ln, side == 0 ? color.new(color.red, 60) : color.new(color.green, 60))
                    array.set(line_live, i, false)
                    // x2/y2 already set to break bar above — leave them

// ── Prune oldest when near Pine's 500-line cap ────────────────────────────
if array.size(line_objs) > 480
    line.delete(array.shift(line_objs))
    array.shift(line_anc_bar)
    array.shift(line_side)
    array.shift(line_live)
    array.shift(line_slope)
    array.shift(line_p2_bar)
````
