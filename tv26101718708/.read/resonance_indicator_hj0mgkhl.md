# Resonance Indicator

- url: https://www.tradingview.com/script/hj0mGkHL/
- type: indicator
- pine_id: PUB;e773d849b19349a98a72252875e63b12
- version: 2.0

## Description

**Resonance**

Overview
Resonance combines three of my earlier scripts (Multi-Confluence Indicator, Blended Momentum Oscillator, Echo Levels) into one overlay. The goal is simple: show at a glance whether short-term momentum and the higher-timeframe trend agree, and where the most recent momentum turning points were on several timeframes.

Why these parts belong together
All parts are driven by the same momentum oscillator and the same higher-timeframe trend score, so they are connected rather than placed side by side:
- One oscillator colors the candles, creates the pivot labels and places the Echo Levels.
- The higher-timeframe score filters the pivot labels and the alerts, so signals against a strong trend are suppressed.
- The alert message combines price, the recent momentum state on 1h and 15m, and the trend score in one line.

1. Candle colors (momentum)
The oscillator averages a smoothed RSI (14, HMA-smoothed) and a long stochastic (200, EMA-smoothed). It runs from 0 to 100 and colors the candles on a gradient:
- Green/teal: low momentum (below 30, oversold below 20)
- Yellow: neutral (around 50)
- Orange/red/maroon: high momentum (above 70, overbought above 80)

2. Higher-timeframe steplines (trend)
For 4H, D, W, M and 3M, a 7-period HMA is calculated and drawn as a stepline with the timeframe name at the right edge. Arrows on each line show its state:
- ↑ / ↓ trend intact (step in the same direction and at least as large as the previous one)
- ↗ / ↘ trend weakening (same direction, smaller step)
- ⤴ / ⤵ fresh turn (direction just changed)
Higher-timeframe values are taken from the last confirmed bar, so they do not repaint.

3. Trend score and table
The states of 1H, 4H, D, W, M and 3M are weighted by how often they update (1H counts most) and combined into one score. On charts of 1h or lower, a small table at the bottom shows the score symbol, the current oscillator value and all timeframes, sorted by the price level of their lines from top to bottom.

4. Pivot labels
On minute charts, a label marks the extreme price when the 1-minute oscillator forms a pivot above 80 (high) or below 20 (low), but only if the trend score is not strongly in the opposite direction. While the move continues, the label follows the new extreme.

5. Echo Levels
For 1m, 15m, 1h, 4h and D, a horizontal line marks the price of the most recent momentum event on that timeframe: an oscillator pivot high (red), pivot low (green) or a cross of the 50 line (gray). Lines on similar prices are merged into one label. Each level appears only on charts at or below its timeframe.

How to read it
- Candle color tells you short-term momentum.
- Arrows and line order tell you the trend on higher timeframes.
- Echo Levels show where momentum last turned and often act as reference prices.
- The strongest situations are those where momentum, trend score and levels point the same way.

Alerts
Create an alert on the indicator with "Any alert() function call". An alert fires at bar close when an oscillator pivot high or low appears and the trend score does not strongly oppose it. The message contains price, change versus the previous daily close, the 1h and 15m state, and the score.

Limitations
- The oscillator pivots are confirmed one bar after they form.
- Echo Levels and the table use lower-timeframe data that can change until the respective bar closes.
- Steplines are only shown on intraday and daily charts and only cover the most recent stretch of bars.
- This is an analysis tool, not a trading system. It does not predict price and gives no buy or sell recommendation.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © wick_vaporup

//@version=6
indicator("Resonance Indicator", overlay = true, max_labels_count = 500, max_bars_back = 4900)

// ═══════════════════════════════════════════════════════════════════
// 1 · INPUTS
// ═══════════════════════════════════════════════════════════════════
stepHide  = input.bool(true, "Hide steplines (100% transparency)", group = "Appearance")
stepOff   = input.bool(false, "Hide steplines completely.", group = "Appearance")
stepTrans = stepHide ? 100 : 0

// ═══════════════════════════════════════════════════════════════════
// 2 · CONSTANTS
// ═══════════════════════════════════════════════════════════════════
S_UP = "↑", S_DN = "↓", S_uP = "↗", S_dN = "↘", S_wU = "⤴", S_wD = "⤵"
S_NO = "—"
MAX_ARROWS = 10, MAX_PIVOTS_SHORT = 4
arrowStride = 100
int LBL_OFFSET = 8

float THR = 0.65

// --- 2.0 Theme autodetect (perceived luminance of chart background) ---
float BG_LUMA   = 0.299 * color.r(chart.bg_color) + 0.587 * color.g(chart.bg_color) + 0.114 * color.b(chart.bg_color)
bool  darkTheme = nz(BG_LUMA, 0.0) < 128

// --- 2.1 State colors (steplines, arrows, TF labels, table) ---------
color C_UP_FLIP  = darkTheme ? color.rgb(112, 191, 115) : color.green   // #4CAF50
color C_UP_TREND = darkTheme ? color.rgb( 51, 161, 149) : color.teal    // #00897B
color C_UP_WEAK  = darkTheme ? color.rgb( 51, 235, 145) : color.lime    // #00E676
color C_DN_TREND = darkTheme ? color.rgb(160,  62, 114) : color.maroon  // #880E4F
color C_DN_FLIP  = darkTheme ? color.rgb(255, 117, 117) : color.red     // #FF5252
color C_DN_WEAK  = darkTheme ? color.rgb(255, 173,  51) : color.orange  // #FF9800
color C_NEUTRAL  = darkTheme ? color.rgb(147, 149, 158) : color.gray    // #787B86
color C_CLEAR    = color.new(color.white, 100)

// --- 2.2 Oscillator gradient (anchors from extreme low to extreme high)
color G_EXT_LO = darkTheme ? color.rgb( 51, 161, 149) : color.teal    // #00897B
color G_LO     = darkTheme ? color.rgb(112, 191, 115) : color.green   // #4CAF50
color G_MID_LO = darkTheme ? color.rgb( 51, 235, 145) : color.lime    // #00E676
color G_MID_HI = darkTheme ? color.rgb(255, 239,  98) : color.yellow  // #FFEB3B
color G_HI     = darkTheme ? color.rgb(255, 173,  51) : color.orange  // #FF9800
color G_TOP    = darkTheme ? color.rgb(255, 117, 117) : color.red     // #FF5252
color G_EXT_HI = darkTheme ? color.rgb(160,  62, 114) : color.maroon  // #880E4F

// --- 2.3 Trend gold, pivot labels -----------------------------------
color C_GOLD      = #D4AF37
color C_PIV_HI    = darkTheme ? color.rgb(255, 70, 70)   : color.red
color C_PIV_LO    = darkTheme ? color.rgb(0, 220, 120)   : color.green
color C_PIV_HI_TX = darkTheme ? color.rgb(255, 200, 200) : color.maroon
color C_PIV_LO_TX = darkTheme ? color.rgb(200, 255, 225) : color.teal

// --- 2.4 Pivot transparency ---
int T_PIV_SHORT = darkTheme ? 75 : 70

// ═══════════════════════════════════════════════════════════════════
// 3 · GLOBALS READ BY FUNCTIONS
// ═══════════════════════════════════════════════════════════════════
showHTF  = timeframe.isdaily or timeframe.isminutes
stepVis  = showHTF and not stepOff
curr_sec = timeframe.in_seconds(timeframe.period)

// ═══════════════════════════════════════════════════════════════════
// 4 · TYPES
// ═══════════════════════════════════════════════════════════════════
type TFState
    int    st  = 0
    float  hma = na
    float  s1  = 0.0
    string sym = "—"
    int    lim = 0
    color  col = na

type Stack
    TFState h1
    TFState h4
    TFState d
    TFState w
    TFState m
    TFState q

type PivotTracker
    int    state = 0
    float  hold  = na
    label  lbl   = na
    array<label> hist = na

// ═══════════════════════════════════════════════════════════════════
// 5 · FUNCTIONS
// ═══════════════════════════════════════════════════════════════════

// --- 5.1 Primitives -------------------------------------------------
clampForce(x) => math.max(0.5, math.min(nz(x, 1.0), 1.5))

f_decode_state(st) =>
    switch st
        1  => S_wU
        2  => S_UP
        -1 => S_wD
        -2 => S_DN
        3  => S_uP
        -3 => S_dN
        => S_NO

f_dir(st) => st == 1 or st == 2 ? 1 : st == 3 ? 0.5 : st == -1 or st == -2 ? -1 : st == -3 ? -0.5 : 0.0

f_col(_st) =>
    switch _st
        2  => C_UP_TREND
        1  => C_UP_FLIP
        3  => C_UP_WEAK
        -2 => C_DN_TREND
        -1 => C_DN_FLIP
        -3 => C_DN_WEAK
        => C_NEUTRAL

f_get_color(val) =>
    switch
        val >= 80 => color.from_gradient(val, 80, 81, G_TOP,    G_EXT_HI)
        val >= 70 => color.from_gradient(val, 70, 80, G_HI,     G_TOP)
        val >= 50 => color.from_gradient(val, 50, 70, G_MID_HI, G_HI)
        val >= 30 => color.from_gradient(val, 30, 50, G_MID_LO, G_MID_HI)
        val >= 20 => color.from_gradient(val, 20, 30, G_LO,     G_MID_LO)
        => color.from_gradient(val, 19, 20, G_EXT_LO, G_LO)

f_trend_color(k, color base) => color.new(base, int(math.pow(k - 0.5, 0.3) * stepTrans))

f_score_color(sc) => sc > THR ? C_UP_TREND : sc > 0 ? C_UP_WEAK : sc < -THR ? C_DN_TREND : sc < 0 ? C_DN_WEAK : C_NEUTRAL

f_bars_since_change(val) => ta.barssince(ta.change(val) != 0)

f_fmt(float v) =>
    float a   = math.abs(nz(v))
    int   dec = a >= 1 or a == 0 ? 2 : math.min(16, 2 + math.max(0, math.ceil(-math.log10(a))))
    str.tostring(v, "0." + str.repeat("0", dec))

// --- 5.2 Step engine -------------------------------------------------
f_get_step_data(src) =>
    var float prevSrc = na
    var float p1_val  = na
    var float p2_val  = na

    if ta.change(src) != 0
        p2_val := p1_val
        p1_val := nz(prevSrc, src)

    prevSrc := src

    p1 = nz(p1_val, src)
    p2 = nz(p2_val, src)

    s1 = src - p1
    s2 = p1 - p2
    is_up     = s1 > 0
    is_down   = s1 < 0
    dir_ch    = (is_up and s2 < 0) or (is_down and s2 > 0)
    is_intact = not dir_ch and math.abs(s1) >= math.abs(s2)

    state = (na(p2_val) and na(p1_val)) ? 0 : dir_ch ? (is_up ? 1 : -1) : is_up ? (is_intact ? 2 : 3) : is_down ? (is_intact ? -2 : -3) : 0
    force = (na(p2_val) or math.abs(s2) == 0) ? 1.0 : clampForce(math.abs(s1) / math.abs(s2))
    [state, force]

// --- 5.3 Oscillator & pivots -----------------------------------------
f_osc() =>
    stoch_raw = ta.stoch(close, high, low, 200)
    (nz(ta.hma(ta.rsi(close, 14), 14), 50.0) + nz(ta.ema(nz(stoch_raw, 50.0), 50), 50.0)) / 2

f_pivot_signals(val) =>
    ph = ta.pivothigh(val, 1, 1)
    pl = ta.pivotlow(val, 1, 1)
    [not na(ph) and ph > 80, not na(pl) and pl < 20]

f_get_htf_signals_cnt() =>
    o = f_osc()
    [ph, pl] = f_pivot_signals(o)
    float eP = ph ? high[1] : low[1]
    var int cH = 0, var int cL = 0, var int cE = 0
    var int   zone = 0
    var int   eT   = 0
    var float eY   = na
    cH   += ph ? 1 : 0
    cL   += pl ? 1 : 0
    zone := o > 80 ? 1 : o < 20 ? -1 : zone
    if ph or pl
        cE += 1
        eT := ph ? 1 : -1
        eY := eP
    [cH, cL, zone, o, cE, eT, eY]

f_get_tf_data(simple string res) =>
    [cH, cL, zone, o, cE, eT, eY] = request.security(syminfo.tickerid, res, f_get_htf_signals_cnt())
    sH = ta.change(cH) != 0
    sL = ta.change(cL) != 0
    sE = ta.change(cE) != 0

    var string last_sig = na
    last_sig := sH ? "H" : sL ? "L" : last_sig

    string disp = not na(last_sig) ? last_sig : zone == 1 ? "h" : zone == -1 ? "l" : str.tostring(nz(o, 50), "#")
    [sH, sL, disp, sE, eT, eY]

// --- 5.4 HTF aggregation ---------------------------------------------
f_get_htf_data() =>
    _h = nz(ta.hma(close, 7), close)
    [_st, _kr] = f_get_step_data(_h)
    s1 = _h - nz(_h[1], _h)
    [_st[1], _h[1], _kr[1], s1[1]]

f_tf(simple string res) =>
    [s, hm, k, d1] = request.security(syminfo.tickerid, res, f_get_htf_data(), lookahead = barmerge.lookahead_on)
    int   si   = nz(s, 0)
    float h    = nz(hm, close)
    color base = close > h ? C_PIV_LO : close < h ? C_PIV_HI : C_NEUTRAL
    TFState.new(si, h, nz(d1, 0.0), f_decode_state(si), int(timeframe.in_seconds(res) / curr_sec), f_trend_color(nz(k, 1.0), base))
    
// --- 5.5 Score & stack -----------------------------------------------
f_close_symbol(Stack x) =>
    score = f_dir(x.h1.st) + f_dir(x.h4.st) * (1.0/4) + f_dir(x.d.st) * (1.0/24) + f_dir(x.w.st) * (1.0/(7*24)) + f_dir(x.m.st) * (1.0/(30*24)) + f_dir(x.q.st) * (1.0/(3*30*24))
    sym = score > THR ? S_UP : score > 0 ? S_uP : score < -THR ? S_DN : score < 0 ? S_dN : S_NO
    [sym, score]

f_sorted_stack(Stack x, string cSym, float cScore) =>
    string[] nm  = array.from(cSym, "4H" + x.h4.sym, "D" + x.d.sym, "W" + x.w.sym, "M" + x.m.sym, "3M" + x.q.sym)
    color[]  cl  = array.from(f_score_color(cScore), f_col(x.h4.st), f_col(x.d.st), f_col(x.w.st), f_col(x.m.st), f_col(x.q.st))
    float[]  vl  = array.from(close, x.h4.hma, x.d.hma, x.w.hma, x.m.hma, x.q.hma)
    int[]    ord = array.from(0, 1, 2, 3, 4, 5)
    for i = 1 to 5
        j = i
        while j > 0 and vl.get(ord.get(j)) > vl.get(ord.get(j - 1))
            t = ord.get(j)
            ord.set(j, ord.get(j - 1)), ord.set(j - 1, t)
            j -= 1
    [nm, cl, ord]

// --- 5.6 Rendering ----------------------------------------------------
f_spread(label[] arr, val, s1, sym, len, sz, txt_col) =>
    if barstate.islast
        arr_sz = arr.size()
        if not stepVis or sym == S_NO
            if arr_sz > 0
                for i = 0 to arr_sz - 1
                    arr.get(i).set_y(na)
        else
            a_sym     = s1 > 0 ? sym + "\n" : "\n" + sym
            maxNeeded = math.floor(math.min(bar_index, 4500) / arrowStride)
            needed    = math.min(math.floor(nz(len) / arrowStride) + 1, maxNeeded, MAX_ARROWS)

            if math.max(needed, arr_sz) > 0
                for i = 0 to math.max(needed, arr_sz) - 1
                    if i < needed
                        x_pos = bar_index - (i * arrowStride)
                        if i < arr_sz
                            lbl = arr.get(i)
                            lbl.set_xy(x_pos, val), lbl.set_text(a_sym), lbl.set_textcolor(txt_col), lbl.set_size(sz)
                        else
                            arr.push(label.new(x_pos, val, a_sym, color = C_CLEAR, textcolor = txt_col, style = label.style_label_center, size = sz))
                    else
                        arr.get(i).set_y(na)

f_lbl(id, val, txt, sz, col) =>
    if na(id)
        label.new(bar_index, val, txt, color = C_CLEAR, textcolor = col, style = label.style_label_left, size = sz)
    else
        id.set_xy(bar_index, val), id.set_text(txt), id.set_textcolor(col), id.set_size(sz)
        id

f_hline(line id, float y, color col, string sty, int w = 1) =>
    if na(id)
        line.new(bar_index - 1, y, bar_index, y, extend = extend.left, style = sty, color = col, width = w)
    else
        id.set_xy1(bar_index - 1, y), id.set_xy2(bar_index, y), id.set_color(col), id.set_width(w)
        id

f_evt_col(int t) => t == 1 ? C_PIV_HI : t == -1 ? C_PIV_LO : C_NEUTRAL

f_merge(float[] ys, string[] ts, color[] cs, float y, string t, color c, float tol) =>
    int idx = -1
    for [i, v] in ys
        if idx < 0 and math.abs(v - y) <= tol and cs.get(i) == c
            idx := i
    if idx < 0
        ys.push(y), ts.push(t), cs.push(c)
    else
        ts.set(idx, ts.get(idx) + " · " + t)

f_tf_name() =>
    timeframe.isminutes ? (timeframe.multiplier % 60 == 0 ? str.tostring(timeframe.multiplier / 60) + "h" : str.tostring(timeframe.multiplier) + "min") : timeframe.period

// --- 5.7 Method -------------------------------------------------------
method update(PivotTracker t, bool isOB, bool isOS, int transp, int maxHist) =>
    int st = isOB ? 1 : isOS ? 2 : 0

    if st > 0 and t.state != st
        float pVal = st == 1 ? high : low
        t.state := st, t.hold := pVal
        col    = color.new(st == 1 ? C_PIV_HI    : C_PIV_LO,    transp)
        txtCol = color.new(st == 1 ? C_PIV_HI_TX : C_PIV_LO_TX, transp / 2)
        style  = st == 1 ? label.style_label_down : label.style_label_up
        t.lbl := label.new(bar_index, pVal, f_fmt(pVal), color = col, textcolor = txtCol, style = style)
        t.hist.push(t.lbl)
        if t.hist.size() > maxHist
            label.delete(t.hist.shift())

    if not na(t.lbl) and ((t.state == 1 and high > t.hold) or (t.state == 2 and low < t.hold))
        t.hold := t.state == 1 ? high : low
        t.lbl.set_xy(bar_index, t.hold)
        t.lbl.set_text(f_fmt(t.hold))

// ═══════════════════════════════════════════════════════════════════
// 6 · EXECUTION
// ═══════════════════════════════════════════════════════════════════

// --- 6.1 Base ---------------------------------------------------------
slow = f_osc()

Stack x = Stack.new(f_tf("60"), f_tf("240"), f_tf("D"), f_tf("W"), f_tf("M"), f_tf("3M"))

[scoreSym, score] = f_close_symbol(x)
color slowCol = na(slow) ? C_NEUTRAL : f_get_color(slow)

// --- 6.2 Plots --------------------------------------------------------
plotcandle(open, high, low, close, color = slowCol, wickcolor = slowCol, bordercolor = slowCol)
barcolor(slowCol)

plot(stepVis and bar_index > (last_bar_index - x.h4.lim) ? x.h4.hma : na, color = x.h4.col, style = plot.style_stepline, linewidth = 4)
plot(stepVis and bar_index > (last_bar_index - x.d.lim)  ? x.d.hma  : na, color = x.d.col,  style = plot.style_stepline, linewidth = 3)
plot(stepVis and bar_index > (last_bar_index - x.d.lim)  ? x.w.hma  : na, color = x.w.col,  style = plot.style_stepline, linewidth = 2)
plot(stepVis and bar_index > (last_bar_index - x.d.lim)  ? x.m.hma  : na, color = x.m.col,  style = plot.style_stepline, linewidth = 1)
plot(stepVis and bar_index > (last_bar_index - x.d.lim)  ? x.q.hma  : na, color = x.q.col,  style = plot.style_stepline, linewidth = 1)

// --- 6.3 Arrow vectors ------------------------------------------------
var a4h = array.new<label>(), var aD = array.new<label>(), var aW = array.new<label>()
var aM  = array.new<label>(), var a3M = array.new<label>()

f_spread(a4h, x.h4.hma, x.h4.s1, x.h4.sym, math.min(f_bars_since_change(x.h4.hma), x.h4.lim), size.huge,   x.h4.col)
f_spread(aD,  x.d.hma,  x.d.s1,  x.d.sym,  math.min(f_bars_since_change(x.d.hma),  x.d.lim), size.large,  x.d.col)
f_spread(aW,  x.w.hma,  x.w.s1,  x.w.sym,  math.min(f_bars_since_change(x.w.hma),  x.d.lim), size.large,  x.w.col)
f_spread(aM,  x.m.hma,  x.m.s1,  x.m.sym,  math.min(f_bars_since_change(x.m.hma),  x.d.lim), size.normal, x.m.col)
f_spread(a3M, x.q.hma,  x.q.s1,  x.q.sym,  math.min(f_bars_since_change(x.q.hma),  x.d.lim), size.normal, x.q.col)

// --- 6.4 Timeframe labels ---------------------------------------------
var label l4h = na, var label lD = na, var label lW = na
var label lM  = na, var label l3M = na

if barstate.islast and stepVis
    l4h := f_lbl(l4h, x.h4.hma, "4H", size.normal, x.h4.col)
    lD  := f_lbl(lD,  x.d.hma,  "D",  size.normal, x.d.col)
    lW  := f_lbl(lW,  x.w.hma,  "W",  size.normal, x.w.col)
    lM  := f_lbl(lM,  x.m.hma,  "M",  size.normal, x.m.col)
    l3M := f_lbl(l3M, x.q.hma,  "3M", size.normal, x.q.col)

// --- 6.5 Pivots & gates -----------------------------------------------
[signalHIGH, signalLOW] = f_pivot_signals(slow)

bool ltfOn = timeframe.isminutes
bool on15  = timeframe.in_seconds() <= timeframe.in_seconds("60")
bool on1h  = timeframe.in_seconds() <= timeframe.in_seconds("60")
bool on4h  = timeframe.in_seconds() <= timeframe.in_seconds("240")
bool onD   = timeframe.in_seconds() <= timeframe.in_seconds("D")

[sH_1,  sL_1,  _last1, sE_1,  eT_1,  eY_1]  = f_get_tf_data("1")
[_sH15, _sL15, last15, sE_15, eT_15, eY_15] = f_get_tf_data("15")
[_sH60, _sL60, last60, sE_60, eT_60, eY_60] = f_get_tf_data("60")
[_sH4,  _sL4,  _last4, sE_4,  eT_4,  eY_4]  = f_get_tf_data("240")
[_sHD,  _sLD,  _lastD, sE_D,  eT_D,  eY_D]  = f_get_tf_data("D")

var tExtr = PivotTracker.new(hist = array.new_label())

if ltfOn
    tExtr.update(sH_1 and score <= THR, sL_1 and score >= -THR, T_PIV_SHORT, MAX_PIVOTS_SHORT)

// --- 6.5b Letztes Event: horizontale Linien (15m / 1m / 1h / 4h / D) ---
float lblTol = nz(ta.atr(14), 0.0) * 0.5

var float lvlQY = na, var color lvlQCol = na, var line lvlQLn = na
var float lvl1Y = na, var color lvl1Col = na, var line lvl1Ln = na
var float lvlHY = na, var color lvlHCol = na, var line lvlHLn = na
var float lvl4Y = na, var color lvl4Col = na, var line lvl4Ln = na
var float lvlDY = na, var color lvlDCol = na, var line lvlDLn = na
var hLbls = array.new_label()

if on15 and sE_15 and not na(eY_15)
    lvlQY := eY_15, lvlQCol := f_evt_col(eT_15)
if ltfOn and sE_1 and not na(eY_1)
    lvl1Y := eY_1, lvl1Col := f_evt_col(eT_1)
if on1h and sE_60 and not na(eY_60)
    lvlHY := eY_60, lvlHCol := f_evt_col(eT_60)
if on4h and sE_4 and not na(eY_4)
    lvl4Y := eY_4, lvl4Col := f_evt_col(eT_4)
if onD and sE_D and not na(eY_D)
    lvlDY := eY_D, lvlDCol := f_evt_col(eT_D)

if barstate.islast
    float[]  ys = array.new_float()
    string[] ts = array.new_string()
    color[]  cs = array.new_color()
    if on15 and not na(lvlQY)
        lvlQLn := f_hline(lvlQLn, lvlQY, lvlQCol, line.style_solid, 4)
        f_merge(ys, ts, cs, lvlQY, "15min", lvlQCol, lblTol)
    if ltfOn and not na(lvl1Y)
        lvl1Ln := f_hline(lvl1Ln, lvl1Y, lvl1Col, line.style_solid, 5)
        f_merge(ys, ts, cs, lvl1Y, "1min", lvl1Col, lblTol)
    if on1h and not na(lvlHY)
        lvlHLn := f_hline(lvlHLn, lvlHY, lvlHCol, line.style_solid, 3)
        f_merge(ys, ts, cs, lvlHY, "1h", lvlHCol, lblTol)
    if on4h and not na(lvl4Y)
        lvl4Ln := f_hline(lvl4Ln, lvl4Y, lvl4Col, line.style_solid, 2)
        f_merge(ys, ts, cs, lvl4Y, "4h", lvl4Col, lblTol)
    if onD and not na(lvlDY)
        lvlDLn := f_hline(lvlDLn, lvlDY, lvlDCol, line.style_solid, 1)
        f_merge(ys, ts, cs, lvlDY, "D", lvlDCol, lblTol)

    for l in hLbls
        l.delete()
    hLbls.clear()
    float gap = -lblTol * 0.75
    for [i, y] in ys
        int n = 0
        if i > 0
            for j = 0 to i - 1
                n += math.abs(ys.get(j) - y) <= lblTol ? 1 : 0
        float yy = y + (n % 2 == 1 ? 1 : -1) * math.ceil(n / 2) * lblTol * 1.5
        hLbls.push(label.new(bar_index, yy, " " + ts.get(i), color = C_CLEAR, textcolor = cs.get(i), style = label.style_label_left, size = size.normal))
        
// --- 6.7 Alert gate ----------------------------------------------------
var int gateState = 0

if signalHIGH
    gateState :=  1
if signalLOW
    gateState := -1

fireHighGate = gateState ==  1 and score <=  THR
fireLowGate  = gateState == -1 and score >= -THR

if fireHighGate or fireLowGate
    gateState := 0

bool doAlert = barstate.isconfirmed and (fireHighGate or fireLowGate)

// --- 6.8 Stack / table -------------------------------------------------
bool showTable = timeframe.in_seconds() <= 3600
var table tStatus = table.new(position.bottom_center, 6, 2, bgcolor = C_CLEAR, border_width = 0)

if barstate.islast and showTable
    [nm, cl, ord] = f_sorted_stack(x, scoreSym, score)
    for c = 0 to 5
        int k = ord.get(c)
        string txt = k == 0 ? nm.get(k) + str.tostring(nz(slow, 50), "#") : nm.get(k)
        table.cell(tStatus, c, 0, txt, text_color = cl.get(k), text_size = size.normal, bgcolor = k == 0 ? color.new(cl.get(k), darkTheme ? 70 : 80) : C_CLEAR)
    table.cell(tStatus, 0, 1, " ", text_size = size.normal)

// --- 6.9 Alerts ---------------------------------------------------------
ref_raw = request.security(syminfo.tickerid, "D", close[1], lookahead = barmerge.lookahead_on)

if doAlert
    safe_close = close == 0 ? 1.0 : close
    ref  = na(ref_raw) or ref_raw == 0 ? safe_close : ref_raw
    pct  = ((close - ref) / ref) * 100
    curr = na(syminfo.currency) or syminfo.currency == "" ? syminfo.ticker : syminfo.currency
    pStr = (close >= 0.01 ? str.tostring(close, format.mintick) : str.tostring(close, "0.00")) + " " + curr + " " + (pct > 0 ? "+" : "") + str.tostring(pct, "0.0") + "%"
    tail = "\n1h " + last60 + " 15m " + last15 + " 1m " + (fireHighGate ? "H" : "L") + " " + scoreSym + str.tostring(nz(slow, 50), "#")
    alert(pStr + tail, alert.freq_once_per_bar_close)
````
