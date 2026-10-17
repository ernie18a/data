# Volume Delta Pivot Matrix with alerts

- url: https://www.tradingview.com/script/SE30h3kX-Volume-Delta-Pivot-Matrix-with-alerts/
- type: indicator
- pine_id: PUB;ab5134784ae9494fb9a8fbca507460bd
- version: 1.0

## Description

Volume Delta Pivot Matrix with Alerts

Based on the original "Volume Delta Pivot Matrix" by BigBeluga.
Original script: BigBeluga,

OVERVIEW
This indicator finds swing-based support and resistance levels and grades each one by how much buying or selling volume formed it. Only levels with enough volume behind them are kept. This version is built for automation: it doesn't repaint, and every point on the chart matches a signal you can use in TradingView alerts.

HOW IT WORKS
1. Pivot detection
   A swing low becomes a support candidate and a swing high becomes a resistance candidate. A swing is the lowest low (or highest high) with "Pivot Swing Length" candles on each side (default 5).

2. Volume delta
   For every candle in the pivot window, volume counts as buying or selling depending on where the candle closed within its range. A close near the high counts as buying, a close near the low counts as selling. Adding these up gives the level's volume delta.

3. Strength filter
   Each new level's delta is compared with the strongest delta among the currently active levels, giving a strength %. The level is accepted only if it meets the "Minimum Delta % Filter". This % is calculated once, when the point forms, and never changes afterwards.

4. Signal and marker
   When a level is accepted:
   • Support: a small green ▲ is drawn at the level, and "Support Point" = 1
   • Resistance: a small red ▼ is drawn at the level, and "Resistance Point" = 1
   The marker appears on the candle where the swing is confirmed, which is "Pivot Swing Length" candles after the actual high or low. The level line starts back at the original swing candle.

5. Level management
   • A level is broken when a candle closes through it. Its line stops at that candle and is left on the chart.
   • Only the newest "Max Active Levels" stay active and keep extending.

AMENDMENTS FROM THE ORIGINAL
- Non-repainting. The original redrew all levels and recalculated their % on the latest candle, so the chart showed only levels that survived, judged with hindsight. This version decides everything in real time, on confirmed candles only.
- Broken levels are kept on the chart instead of deleted, so you can see every level that was ever signalled.
- The multi-size yellow delta circles and the price/delta text labels are replaced with simple ▲ / ▼ markers. Hover over a marker to see its price, delta and strength %.
- Two Strategy Builder outputs added: "Support Point" and "Resistance Point" (1 on the signal candle, 0 otherwise). They line up exactly with the markers on the chart.
- Two alert conditions added: "Support Point" and "Resistance Point", for webhook automation.
- Settings simplified. A "Show Level Lines" toggle was added.

SETTINGS
- Pivot Swing Length: candles on each side needed to confirm a swing. Higher means fewer, more significant levels but a later signal.
- Max Active Levels: how many recent levels stay active at once.
- Minimum Delta % Filter: raise this for fewer, stronger points.
- Colours, line style, line width, and level lines on/off.

## Source Code

````pine

//@version=6
indicator("Volume Delta Pivot Matrix with alerts", overlay = true, max_lines_count = 500, max_labels_count = 500, max_bars_back = 5000)

// ＩＮＰＵＴＳ ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
g_piv  = "Pivot Settings"
lbars  = input.int(5, "Pivot Swing Length", minval = 1, group = g_piv)
rbars  = lbars
mxlvl  = input.int(10, "Max Active Levels", minval = 1, maxval = 50, group = g_piv)
mdpct  = input.float(20.0, "Minimum Delta % Filter", minval = 0.0, maxval = 100.0, step = 5.0, group = g_piv)

g_sty  = "Visual Styling"
cbull  = input.color(color.rgb(24, 206, 33), "Support Color", group = g_sty)
cbear  = input.color(#FF3D00, "Resistance Color", group = g_sty)
showLn = input.bool(true, "Show Level Lines", group = g_sty)
lopt   = input.string("Solid", "Line Style", options = ["Solid", "Dotted", "Dashed"], group = g_sty)
lwidth = input.int(2, "Line Width", minval = 1, group = g_sty)
// }

// ＣＡＬＣＵＬＡＴＩＯＮＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
type Plvl
    float lvl
    float dlta
    bool  supp
    line  ln

var parr = array.new<Plvl>()

lnStyle = switch lopt
    "Dotted" => line.style_dotted
    "Dashed" => line.style_dashed
    => line.style_solid

// Volume delta over the whole pivot window (close position within each bar's range)
pivotDelta() =>
    float d = 0.0
    for i = 0 to (lbars + rbars)
        float rng = high[i] - low[i]
        d += rng > 0 ? volume[i] * (((close[i] - low[i]) / rng) * 2 - 1) : (close[i] >= open[i] ? volume[i] : -volume[i])
    d

float ph   = ta.pivothigh(high, lbars, rbars)
float pl   = ta.pivotlow(low, lbars, rbars)
float dNow = pivotDelta()

// 1) BREAKS: a level is broken when a bar CLOSES through it. Line stops there (not deleted).
if barstate.isconfirmed and array.size(parr) > 0
    for i = array.size(parr) - 1 to 0
        Plvl l = array.get(parr, i)
        if (l.supp and close <= l.lvl) or (not l.supp and close >= l.lvl)
            if not na(l.ln)
                line.set_x2(l.ln, bar_index)
            array.remove(parr, i)

// 2) NEW POINTS: delta % is measured against the biggest delta among active levels AT THIS BAR
float maxD = math.abs(dNow)
for l in parr
    maxD := math.max(maxD, math.abs(l.dlta))
maxD := math.max(maxD, 0.0001)
float pct = math.abs(dNow) / maxD * 100.0

bool supportPoint    = barstate.isconfirmed and not na(pl) and pct >= mdpct
bool resistancePoint = barstate.isconfirmed and not na(ph) and pct >= mdpct

addLevel(float price, bool isSupp) =>
    color c  = isSupp ? cbull : cbear
    line  ln = showLn ? line.new(bar_index - rbars, price, bar_index, price, color = color.new(c, 30), width = lwidth, style = lnStyle) : na
    array.push(parr, Plvl.new(price, dNow, isSupp, ln))
    string tip = (isSupp ? "Support " : "Resistance ") + str.tostring(price, format.mintick) + "\nDelta: " + str.tostring(dNow, format.volume) + "\nStrength: " + str.tostring(pct, "#.#") + "%"
    label.new(bar_index, price, "", xloc = xloc.bar_index, yloc = yloc.price, color = c,
         style = isSupp ? label.style_triangleup : label.style_triangledown, size = size.tiny, tooltip = tip)

if supportPoint
    addLevel(pl, true)
if resistancePoint
    addLevel(ph, false)

// 3) CAPACITY: keep only the newest `mxlvl` levels active; older ones simply stop extending
while array.size(parr) > mxlvl
    array.shift(parr)

// 4) EXTEND active lines to the current bar
for l in parr
    if not na(l.ln)
        line.set_x2(l.ln, bar_index)
// }

// ＳＴＲＡＴＥＧＹ ＢＵＩＬＤＥＲ ＯＵＴＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――{
// 1 on the bar the triangle appears, 0 otherwise. Same bar as the triangle on the chart.
plot(supportPoint    ? 1 : 0, "Support Point",    color = cbull, display = display.data_window)
plot(resistancePoint ? 1 : 0, "Resistance Point", color = cbear, display = display.data_window)

alertcondition(supportPoint,    "Support Point",    "New support point on {{ticker}} at {{close}}")
alertcondition(resistancePoint, "Resistance Point", "New resistance point on {{ticker}} at {{close}}")
// }
````
