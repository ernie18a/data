# HTF Levels

- url: https://www.tradingview.com/script/Y7K6PFKo-HTF-Levels/
- type: indicator
- pine_id: PUB;a6d0bbd69ecf4b308c8d3e29ab58b3d3
- version: 2.0

## Description

Plots higher-timeframe support/resistance from 2-bar reversals on the Daily, Weekly and Monthly charts. Each level is detected and pruned (removed on a close through it) over the full higher-timeframe history inside request.security, so coverage is independent of your chart timeframe. Active levels are drawn as horizontal lines anchored at the reversal, each with a clean text label showing the timeframe and price (e.g. "daily - 77,526.4"). Line and label colors are configurable per timeframe (Daily / Weekly / Monthly), with a dedup tolerance and "close through" vs "any touch" removal modes. Open-source: study and adapt freely.

## Source Code

````pine
//@version=6
indicator("HTF Levels", overlay=true, max_lines_count=500, max_labels_count=500)

// =================================================================================
// HTF Levels  v58
// 2-bar reversal levels on D/W/M, detected + close-through-pruned over the ENTIRE
// HTF history INSIDE request.security (coverage independent of chart TF). Levels
// anchored at the close of the last bar before the reversal (xloc.bar_time),
// extend right. One clean text label per level: "daily - 77,526.40".
// Line color and label text color are independent per TF.
//
// v57 (2026-06-01) — works identically on ANY ticker / price / timeframe:
//   1. Decimals now AUTO-derived from syminfo.mintick, floored at 2. BTC shows
//      "77,526.40"; low-priced alts (NEARUSDT.P, etc.) show full tick precision
//      (e.g. "2.847"). Replaces the hardcoded "#,##0.0" (1dp).
//   2. Cross-TF dedup tolerance is now a % OF PRICE (+ a mintick floor), not a
//      flat $1. The flat $1 was ~30-50% of a $2-3 alt, so it silently SKIPPED
//      nearly every daily & weekly level on NEARUSDT.P (only monthly, drawn
//      first/unrestricted, survived). Percent-relative preserves BTC behavior
//      (~$1 at 70k) and shows the full alt level set.
// v58 (2026-10-01) — pivots older than LINE_BACK chart bars draw full-width. A
//   level whose pivot predates the RENDERED history (the chart loads ~300 bars;
//   Pine computes on more) got a null x on the chart and was never drawn: TV
//   painted it for a moment after a recalc, then dropped it. Hit most W/M levels
//   on an alt that just ran (ENA 30m). Labels were fine (bar_index-anchored).
// (Inputs carry display=display.none so the chart legend stays clean.)
// =================================================================================

// ---------- Global ----------
string g_removal   = input.string("Close through", "Removal Mode", options=["Close through", "Any touch"], group="Global", display=display.none)
bool   g_showLbl   = input.bool(true,  "Show labels", group="Global", display=display.none)
int    g_offset    = input.int(30,     "Label offset (bars from last)", minval=0, maxval=200, group="Global", display=display.none)
string g_labelSize = input.string("Small", "Text size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Global", display=display.none)
float  g_dedupPct  = input.float(0.0015, "Cross-TF dedup tolerance (% of price)", minval=0.0, step=0.001, group="Global", display=display.none)

// ---------- Daily ----------
bool   d_enabled = input.bool(true, "Enable Daily", group="Daily", display=display.none)
color  d_color   = input.color(#5B9CF6, "Line color",  group="Daily", display=display.none)
color  d_lblCol  = input.color(#5B9CF6, "Label color", group="Daily", display=display.none)
int    d_width   = input.int(1, "Width", minval=1, maxval=5, group="Daily", display=display.none)
string d_style   = input.string("Solid", "Style", options=["Solid", "Dashed", "Dotted"], group="Daily", display=display.none)

// ---------- Weekly ----------
bool   w_enabled = input.bool(true, "Enable Weekly", group="Weekly", display=display.none)
color  w_color   = input.color(#FFEB3B, "Line color",  group="Weekly", display=display.none)
color  w_lblCol  = input.color(#FFEB3B, "Label color", group="Weekly", display=display.none)
int    w_width   = input.int(1, "Width", minval=1, maxval=5, group="Weekly", display=display.none)
string w_style   = input.string("Solid", "Style", options=["Solid", "Dashed", "Dotted"], group="Weekly", display=display.none)

// ---------- Monthly ----------
bool   m_enabled = input.bool(true, "Enable Monthly", group="Monthly", display=display.none)
color  m_color   = input.color(#9C27B0, "Line color",  group="Monthly", display=display.none)
color  m_lblCol  = input.color(#FFFFFF, "Label color", group="Monthly", display=display.none)
int    m_width   = input.int(1, "Width", minval=1, maxval=5, group="Monthly", display=display.none)
string m_style   = input.string("Solid", "Style", options=["Solid", "Dashed", "Dotted"], group="Monthly", display=display.none)

// ---------- Helpers ----------
f_lineStyle(string s) =>
    switch s
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        =>         line.style_solid

f_txtSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.small

// Decimals: at least 2, more for low-tick symbols. Derived from syminfo.mintick
// so the same code formats BTC (mintick 0.1 -> 2dp) and a $2 alt (mintick 0.001
// -> 3dp) correctly with no per-symbol input.
f_decimals() =>
    float mt = syminfo.mintick
    int d = (na(mt) or mt <= 0.0) ? 2 : int(math.ceil(-math.log10(mt)))
    math.max(2, d)

// Build a comma-grouped format string "#,##0.00..." with the symbol's decimals.
f_priceFmt() =>
    int dec = f_decimals()
    string f = "#,##0."
    for i = 1 to dec
        f := f + "0"
    f

string priceFmt = f_priceFmt()

// ---------- Full-history detector (evaluated in HTF context by request.security) ----------
f_detect(string removal) =>
    var array<float> prices = array.new_float()
    var array<int>   dirs   = array.new_int()
    var array<int>   times  = array.new_int()
    float o2 = open[2]
    float c2 = close[2]
    float o1 = open[1]
    float c1 = close[1]
    float h1 = high[1]
    float l1 = low[1]
    if not na(o2) and not na(c2) and not na(o1) and not na(c1)
        // prune existing levels using the most recent confirmed bar [1]
        int sz = array.size(prices)
        if sz > 0
            for i = sz - 1 to 0
                float p = array.get(prices, i)
                int   d = array.get(dirs, i)
                bool  rm = false
                if removal == "Close through"
                    rm := (d == -1 and c1 > p) or (d == 1 and c1 < p)
                else
                    rm := l1 <= p and h1 >= p
                if rm
                    array.remove(prices, i)
                    array.remove(dirs, i)
                    array.remove(times, i)
        // detect 2-bar reversal: bar [2] (older) vs bar [1] (newer)
        bool b1G = c2 >= o2
        bool b1R = c2 <  o2
        bool b2G = c1 >= o1
        bool b2R = c1 <  o1
        if b1G and b2R
            array.push(prices, c2)
            array.push(dirs, -1)
            array.push(times, time[1])   // close of pivot bar = open of reversal bar
        if b1R and b2G
            array.push(prices, c2)
            array.push(dirs, +1)
            array.push(times, time[1])
    [prices, dirs, times]

[d_p, d_d, d_t] = request.security(syminfo.tickerid, "D", f_detect(g_removal), lookahead=barmerge.lookahead_off)
[w_p, w_d, w_t] = request.security(syminfo.tickerid, "W", f_detect(g_removal), lookahead=barmerge.lookahead_off)
[m_p, m_d, m_t] = request.security(syminfo.tickerid, "M", f_detect(g_removal), lookahead=barmerge.lookahead_off)

// request.security can return `na` (not an empty array) on the first bars / some
// chart TFs — normalize to empty arrays so array.* calls never hit a na id.
array<float> dP = na(d_p) ? array.new_float() : d_p
array<int>   dT = na(d_t) ? array.new_int()   : d_t
array<float> wP = na(w_p) ? array.new_float() : w_p
array<int>   wT = na(w_t) ? array.new_int()   : w_t
array<float> mP = na(m_p) ? array.new_float() : m_p
array<int>   mT = na(m_t) ? array.new_int()   : m_t

// A pivot older than this many bars is anchored here instead and drawn with
// extend.both, so it always renders and never shows a fake start (see v58).
// 200 stays under TV's ~300-bar initial chart load.
int LINE_BACK = 200

// ---------- Drawing (rebuilt only when the active set changes) ----------
var array<line>  allLines  = array.new_line()
var array<label> allLabels = array.new_label()
var array<int>   allLblOff = array.new_int()
var float prevSig = na

f_clearAll() =>
    for ln in allLines
        line.delete(ln)
    for lb in allLabels
        label.delete(lb)
    array.clear(allLines)
    array.clear(allLabels)
    array.clear(allLblOff)

// Cross-TF dedup tolerance for `price`: % of price, floored at one mintick so it
// always at least merges identical-tick levels but never wipes whole TFs on alts.
f_tol(float price) =>
    math.max(syminfo.mintick, math.abs(price) * g_dedupPct / 100.0)

f_near(float price, array<float> seen) =>
    bool hit = false
    float tol = f_tol(price)
    if array.size(seen) > 0
        for p in seen
            if math.abs(p - price) <= tol
                hit := true
                break
    hit

f_sig(array<float> a) =>
    float s = 0.0
    if array.size(a) > 0
        for v in a
            s += v
    s

// draws one TF's active levels, skipping any price already claimed by a higher TF.
f_drawTF(array<float> pr, array<int> tm, bool en, color lineCol, color lblCol, int wid, string sty, string tfName, int spanMs, int lastX, int minT, array<float> skipA, array<float> skipB, array<float> claimed) =>
    if en and array.size(pr) > 0
        for i = 0 to array.size(pr) - 1
            float price = array.get(pr, i)
            int   t1    = array.get(tm, i)
            if not na(price) and not na(t1) and not f_near(price, skipA) and not f_near(price, skipB)
                bool old = t1 < minT
                int  x1  = old ? minT : t1
                line ln = line.new(x1, price, x1 + spanMs, price, xloc=xloc.bar_time, extend=old ? extend.both : extend.right, color=lineCol, width=wid, style=f_lineStyle(sty))
                array.push(allLines, ln)
                if g_showLbl
                    string txt = tfName + " - " + str.tostring(price, priceFmt)
                    label lb = label.new(lastX + g_offset, price, txt, xloc=xloc.bar_index, style=label.style_none, textcolor=lblCol, size=f_txtSize(g_labelSize), textalign=text.align_left)
                    array.push(allLabels, lb)
                    array.push(allLblOff, g_offset)
                array.push(claimed, price)

if barstate.islast
    float sig = f_sig(mP) + f_sig(wP) * 1.3 + f_sig(dP) * 1.7 + array.size(mP) * 7 + array.size(wP) * 13 + array.size(dP) * 17
    if na(prevSig) or sig != prevSig
        prevSig := sig
        f_clearAll()
        int lastX  = bar_index
        int spanMs = timeframe.in_seconds() * 1000 * 3   // 3 chart bars (never sub-bar)
        int minT   = time[math.min(bar_index, LINE_BACK)]
        array<float> mDrawn = array.new_float()
        array<float> wDrawn = array.new_float()
        array<float> dDrawn = array.new_float()
        array<float> emptyA = array.new_float()
        // priority: Monthly > Weekly > Daily
        f_drawTF(mP, mT, m_enabled, m_color, m_lblCol, m_width, m_style, "monthly", spanMs, lastX, minT, emptyA, emptyA, mDrawn)
        f_drawTF(wP, wT, w_enabled, w_color, w_lblCol, w_width, w_style, "weekly",  spanMs, lastX, minT, mDrawn, emptyA, wDrawn)
        f_drawTF(dP, dT, d_enabled, d_color, d_lblCol, d_width, d_style, "daily",   spanMs, lastX, minT, mDrawn, wDrawn, dDrawn)
    // keep labels glued to the right edge as new bars form
    if array.size(allLabels) > 0
        for i = 0 to array.size(allLabels) - 1
            label.set_x(array.get(allLabels, i), bar_index + array.get(allLblOff, i))
````
