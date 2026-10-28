# Echo Levels

- url: https://www.tradingview.com/script/FEUiuw7s/
- type: indicator
- pine_id: PUB;31c3fc5751014b5686d8b76fe00bcaaa
- version: 2.0

## Description

Echo Levels

Echo Levels marks the price of the most recent momentum event on five timeframes (1m, 15m, 1h, 4h, D) as horizontal lines. Each line is the "echo" of the last significant turn in momentum on its timeframe, a level the market has recently reacted at.

HOW IT WORKS

1. Oscillator
A smoothed momentum oscillator (0–100) is the average of:
• HMA(14) of RSI(14) – fast momentum
• EMA(50) of Stochastic(200) – position within the long-term range

2. Events
On each timeframe, three event types are tracked:
• Overbought turn: oscillator pivot high above 80 → level = high of the pivot bar (red)
• Oversold turn: oscillator pivot low below 20 → level = low of the pivot bar (green)
• Midline cross: oscillator crosses 50 → level = close of the crossing bar (gray)

Pivots use 1 bar on each side, so they are confirmed one bar after the turn.

3. Lines
Only the latest event per timeframe is drawn and extended across the chart. A new event replaces the old line.

• 15m – solid, width 4
• 1m – dashed, width 1
• 1h – solid, width 3
• 4h – solid, width 2
• D – solid, width 1

VISIBILITY

• 1m and 15m: minute and hourly charts
• 1h: charts up to 1h
• 4h: charts up to 4h
• D: charts up to 1D

LABELS

Each line has a timeframe label on the right. When several levels sit at nearly the same price (within 0.5 × ATR(14)), their labels merge into one, e.g. "15min · 1h", to avoid overlap. Merged labels indicate confluence: several timeframes reacted at the same price.

Colors adapt automatically to light and dark chart themes.

HOW TO USE

• Red levels: momentum exhausted to the upside – potential resistance
• Green levels: momentum exhausted to the downside – potential support
• Gray levels: momentum shift through neutral – pivot zone
• Merged labels: multi-timeframe confluence, typically stronger levels

NOTES

• Higher-timeframe values are requested without lookahead. Events on a still-open higher-timeframe bar can change until that bar closes.
• When a lower timeframe (e.g. 1m) is shown on a higher chart, only the last event within each chart bar is captured.
• This indicator does not generate buy/sell signals. Use it as context together with your own analysis.
```

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © wick_vaporup

//@version=6
indicator("Echo Levels", overlay = true, max_lines_count = 50, max_labels_count = 50)

// ═══════════════════════════════════════════════════════════════════
// 1 · THEME & COLORS
// ═══════════════════════════════════════════════════════════════════
float BG_LUMA   = 0.299 * color.r(chart.bg_color) + 0.587 * color.g(chart.bg_color) + 0.114 * color.b(chart.bg_color)
bool  darkTheme = nz(BG_LUMA, 0.0) < 128

color C_PIV_HI  = darkTheme ? color.rgb(255, 70, 70)    : color.red
color C_PIV_LO  = darkTheme ? color.rgb(0, 220, 120)    : color.green
color C_NEUTRAL = darkTheme ? color.rgb(147, 149, 158)  : color.gray
color C_CLEAR   = color.new(color.white, 100)

// ═══════════════════════════════════════════════════════════════════
// 2 · FUNCTIONS
// ═══════════════════════════════════════════════════════════════════
f_osc() =>
    stoch_raw = ta.stoch(close, high, low, 200)
    (nz(ta.hma(ta.rsi(close, 14), 14), 50.0) + nz(ta.ema(nz(stoch_raw, 50.0), 50), 50.0)) / 2

f_pivot_signals(val) =>
    ph = ta.pivothigh(val, 1, 1)
    pl = ta.pivotlow(val, 1, 1)
    [not na(ph) and ph > 80, not na(pl) and pl < 20]

// Event-Stream im Security-Kontext: cE zählt jedes Event (Pivot H/L, Osc×50),
// eT/eY halten Typ (1=H, -1=L, 0=Cross) und Preis des letzten Events.
f_events() =>
    o = f_osc()
    [ph, pl] = f_pivot_signals(o)
    bool  xo = ta.cross(o, 50)
    float eP = ph ? high[1] : pl ? low[1] : close
    var int   cE = 0
    var int   eT = 0
    var float eY = na
    if ph or pl or xo
        cE += 1
        eT := ph ? 1 : pl ? -1 : 0
        eY := eP
    [cE, eT, eY]

f_tf_events(simple string res) =>
    [cE, eT, eY] = request.security(syminfo.tickerid, res, f_events())
    [ta.change(cE) != 0, eT, eY]

f_evt_col(int t) => t == 1 ? C_PIV_HI : t == -1 ? C_PIV_LO : C_NEUTRAL

f_hline(line id, float y, color col, string sty, int w = 1) =>
    if na(id)
        line.new(bar_index - 1, y, bar_index, y, extend = extend.left, style = sty, color = col, width = w)
    else
        id.set_xy1(bar_index - 1, y), id.set_xy2(bar_index, y), id.set_color(col), id.set_width(w)
        id

f_merge(float[] ys, string[] ts, color[] cs, float y, string t, color c, float tol) =>
    int idx = -1
    for [i, v] in ys
        if idx < 0 and math.abs(v - y) <= tol and cs.get(i) == c
            idx := i
    if idx < 0
        ys.push(y), ts.push(t), cs.push(c)
    else
        ts.set(idx, ts.get(idx) + " · " + t)

// ═══════════════════════════════════════════════════════════════════
// 3 · GATES & DATA
// ═══════════════════════════════════════════════════════════════════
bool ltfOn = timeframe.isminutes
bool on15  = timeframe.in_seconds() <= timeframe.in_seconds("60")
bool on1h  = timeframe.in_seconds() <= timeframe.in_seconds("60")
bool on4h  = timeframe.in_seconds() <= timeframe.in_seconds("240")
bool onD   = timeframe.in_seconds() <= timeframe.in_seconds("D")

[sE_1,  eT_1,  eY_1]  = f_tf_events("1")
[sE_15, eT_15, eY_15] = f_tf_events("15")
[sE_60, eT_60, eY_60] = f_tf_events("60")
[sE_4,  eT_4,  eY_4]  = f_tf_events("240")
[sE_D,  eT_D,  eY_D]  = f_tf_events("D")

// ═══════════════════════════════════════════════════════════════════
// 4 · LEVELS (15m / 1m / 1h / 4h / D)
// ═══════════════════════════════════════════════════════════════════
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

// ═══════════════════════════════════════════════════════════════════
// 5 · RENDERING
// ═══════════════════════════════════════════════════════════════════
if barstate.islast
    float[]  ys = array.new_float()
    string[] ts = array.new_string()
    color[]  cs = array.new_color()
    if on15 and not na(lvlQY)
        lvlQLn := f_hline(lvlQLn, lvlQY, lvlQCol, line.style_solid, 4)
        f_merge(ys, ts, cs, lvlQY, "15min", lvlQCol, lblTol)
    if ltfOn and not na(lvl1Y)
        lvl1Ln := f_hline(lvl1Ln, lvl1Y, lvl1Col, line.style_dashed, 1)
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
    for [i, y] in ys
        int n = 0
        if i > 0
            for j = 0 to i - 1
                n += math.abs(ys.get(j) - y) <= lblTol ? 1 : 0
        float yy = y + (n % 2 == 1 ? 1 : -1) * math.ceil(n / 2) * lblTol * 1.5
        hLbls.push(label.new(bar_index, yy, " " + ts.get(i), color = C_CLEAR, textcolor = cs.get(i), style = label.style_label_left, size = size.normal))
````
