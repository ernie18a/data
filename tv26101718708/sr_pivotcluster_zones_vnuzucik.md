# S/R Pivot-Cluster Zones

- url: https://www.tradingview.com/script/vNUZuCIK-S-R-Pivot-Cluster-Zones/
- type: indicator
- pine_id: PUB;d4f053cdf0ee47c8af22388b5d47e1a1
- version: 1.0

## Description

S/R Pivot-Cluster Zones draws support and resistance as zones, not single lines. Each zone is built from confirmed swing highs and lows that cluster at similar prices, and each zone is labelled with how strong it is. The goal is to replace subjective, hand-drawn levels with a fixed rule set. Two traders using the same settings on the same chart get the same zones.

HOW IT WORKS

Swing pivots. A bar is a swing high if its high is the highest of the bars on each side of it (default 5 bars on each side, an 11-bar window). Swing lows work the same way with the bar’s low. A pivot is confirmed only after those bars have closed. After that it never moves, so confirmed zones do not repaint.
Lookback. Only pivots from the last N bars are used (default 250, about one trading year on a daily chart). This keeps the zones relevant to current price.
Clustering. All pivot prices, highs and lows together, are sorted. A pivot joins the current group when it lies within a set distance of the previous one: 0.5 × ATR(14) by default. Because the distance is based on ATR, it adapts to each instrument’s volatility. A level that acted as resistance and later as support ends up in one zone.
Zone width. Each zone runs from the lowest pivot in its group to the highest, plus a padding of 0.25 × ATR on both sides.
Strength. Every zone is labelled with two numbers:
• piv: the number of swing pivots that formed the zone (separate turning points at this price).
• touches: the number of bars in the lookback whose range traded into the zone (how often the market returned to it).
Classification relative to the current close:
• Green = support (below price)
• Red = resistance (above price)
• Amber = price is currently inside the zone
By default, the nearest zones on each side are shown.
Unconfirmed swing. The most recent high and low, which cannot be confirmed as pivots yet, are drawn as dashed lines. The newest swing stays visible before it becomes a zone.
Table. A small table shows the nearest support and resistance zones and their distance from the current price in percent.

HOW TO USE IT

Use it as a map of where buyers or sellers acted before. It is not a buy or sell signal.
Zones with more pivots and more touches have been more significant in the past. Single-pivot zones are weaker.
A common approach: wait for price to reach a zone, then look for a reaction (a reversal candle, a lower-timeframe structure break, or a volume change) before acting.
A daily close beyond a zone suggests the level is breaking. A broken zone often flips role, so old resistance may act as support.
Daily and weekly charts give the most meaningful swing-trading levels. On intraday charts, zones are smaller and closer together.

SETTINGS

Pivot strength: bars on each side of a swing (default 5). Higher values give fewer, more significant pivots.
Lookback: number of bars to analyse (default 250).
ATR length: default 14.
Cluster distance: how close pivots must be to merge (default 0.5 × ATR).
Zone padding: extra width on each side of a zone (default 0.25 × ATR).
Min pivots per zone: set to 2 or more to show only zones formed by several turning points.
Zones on each side: how many supports and resistances to display.
Show the unconfirmed high/low lines and the summary table (on/off).
Colours for support, resistance and price-inside zones.

NOTES AND LIMITATIONS

Zones are computed on the last bar from confirmed historical pivots. The most recent swing appears as a zone only once it is confirmed (after the set number of bars).
When many pivots sit close together, clustering can produce a wide zone. Treat it as a broad area of interest, not one precise price.
Support and resistance describe past behaviour. Price can move through any zone.
This script is for educational and analytical purposes only and is not financial advice.

## Source Code

````pine

plot(close)
//@version=6
// S/R Pivot-Cluster Zones — same method as the EGX scan reports
// 1. Swing high/low = highest high / lowest low of k bars on each side (default 5).
//    Confirmed only k bars later, so a confirmed zone never moves.
// 2. Only swings inside the last N bars (default 250 = about one year, daily).
// 3. Swing prices within 0.5 x ATR(14) of each other are grouped into one zone.
// 4. Zone = group low - 0.25 x ATR  to  group high + 0.25 x ATR.
// 5. Label shows: number of swings in the zone + number of candles that touched it.
// 6. Green = support (below price), red = resistance (above), amber = price inside.
// Dashed lines = newest high/low of the last k bars (not confirmed yet).
indicator("S/R Pivot-Cluster Zones", shorttitle = "S/R Zones", overlay = true,
     max_boxes_count = 200, max_lines_count = 10, max_labels_count = 10, max_bars_back = 1000)

// ── Inputs ──
k          = input.int(5,    "Pivot strength (bars each side)", minval = 2, maxval = 20)
lookback   = input.int(250,  "Lookback (bars)",                 minval = 50, maxval = 1000)
atrLen     = input.int(14,   "ATR length",                      minval = 2)
clusterMul = input.float(0.5,  "Cluster distance (x ATR)",      minval = 0.05, step = 0.05)
padMul     = input.float(0.25, "Zone padding (x ATR)",          minval = 0.0,  step = 0.05)
minPivots  = input.int(1,    "Min pivots per zone (2+ = stronger only)", minval = 1)
maxSide    = input.int(4,    "Zones to show on each side of price", minval = 1, maxval = 20)
showUnconf = input.bool(true, "Show unconfirmed recent high / low")
showTable  = input.bool(true, "Show nearest support / resistance table")
extendBars = input.int(15,   "Extend zones right (bars)", minval = 0)

colSup  = input.color(color.new(color.teal,  80), "Support fill")
colRes  = input.color(color.new(color.red,   80), "Resistance fill")
colIn   = input.color(color.new(color.orange,75), "Price-inside fill")

// ── Calculated on every bar ──
atr   = ta.atr(atrLen)
winHi = ta.highest(high, 2 * k + 1)
winLo = ta.lowest(low,  2 * k + 1)
recHi = ta.highest(high, k)
recLo = ta.lowest(low,  k)

var float[] pivPrice = array.new<float>()
var int[]   pivBar   = array.new<int>()

if bar_index >= 2 * k
    if high[k] == winHi
        array.push(pivPrice, high[k])
        array.push(pivBar,   bar_index - k)
    if low[k] == winLo
        array.push(pivPrice, low[k])
        array.push(pivBar,   bar_index - k)
    while array.size(pivBar) > 0 and array.get(pivBar, 0) < bar_index - lookback - 2 * k
        array.shift(pivBar)
        array.shift(pivPrice)

// ── Build and draw zones on the last bar ──
var box[]  boxes = array.new<box>()
var line[] lns   = array.new<line>()
var table  tbl   = table.new(position.top_right, 3, 3, border_width = 1)

if barstate.islast
    for b in boxes
        box.delete(b)
    array.clear(boxes)
    for l in lns
        line.delete(l)
    array.clear(lns)

    n         = math.min(lookback, bar_index + 1)
    startBar  = bar_index - n + 1
    a         = atr

    float[] P = array.new<float>()
    if array.size(pivBar) > 0
        for i = 0 to array.size(pivBar) - 1
            if array.get(pivBar, i) - k >= startBar
                array.push(P, array.get(pivPrice, i))
    array.sort(P, order.ascending)

    float[] cMin = array.new<float>()
    float[] cMax = array.new<float>()
    int[]   cCnt = array.new<int>()
    if array.size(P) > 0
        for i = 0 to array.size(P) - 1
            p = array.get(P, i)
            last = array.size(cMax) - 1
            if last >= 0 and p - array.get(cMax, last) <= a * clusterMul
                array.set(cMax, last, p)
                array.set(cCnt, last, array.get(cCnt, last) + 1)
            else
                array.push(cMin, p)
                array.push(cMax, p)
                array.push(cCnt, 1)

    float[] zLo = array.new<float>()
    float[] zHi = array.new<float>()
    int[]   zPv = array.new<int>()
    int[]   zT  = array.new<int>()
    if array.size(cMin) > 0
        for j = 0 to array.size(cMin) - 1
            if array.get(cCnt, j) >= minPivots
                lo_ = array.get(cMin, j) - a * padMul
                hi_ = array.get(cMax, j) + a * padMul
                t = 0
                for i = 0 to n - 1
                    if low[i] <= hi_ and high[i] >= lo_
                        t += 1
                array.push(zLo, lo_)
                array.push(zHi, hi_)
                array.push(zPv, array.get(cCnt, j))
                array.push(zT,  t)

    float nearSupHi = na
    float nearSupLo = na
    float nearResLo = na
    float nearResHi = na
    supShown = 0
    resShown = 0
    m = array.size(zLo)
    if m > 0
        for j = m - 1 to 0
            lo_ = array.get(zLo, j)
            hi_ = array.get(zHi, j)
            inside = close >= lo_ and close <= hi_
            isSup  = hi_ < close
            show = inside or (isSup and supShown < maxSide)
            if isSup and supShown < maxSide
                supShown += 1
                if na(nearSupHi)
                    nearSupHi := hi_
                    nearSupLo := lo_
            if show
                fillC = inside ? colIn : colSup
                txt = (inside ? "IN ZONE " : "S ") + str.tostring(lo_, format.mintick) + " - " + str.tostring(hi_, format.mintick) +
                      "  |  " + str.tostring(array.get(zPv, j)) + " piv / " + str.tostring(array.get(zT, j)) + " touches"
                array.push(boxes, box.new(startBar, hi_, bar_index + extendBars, lo_,
                     border_color = color.new(fillC, 40), bgcolor = fillC, text = txt,
                     text_color = color.gray, text_size = size.small, text_halign = text.align_right))
        for j = 0 to m - 1
            lo_ = array.get(zLo, j)
            hi_ = array.get(zHi, j)
            if lo_ > close and resShown < maxSide
                resShown += 1
                if na(nearResLo)
                    nearResLo := lo_
                    nearResHi := hi_
                txt = "R " + str.tostring(lo_, format.mintick) + " - " + str.tostring(hi_, format.mintick) +
                      "  |  " + str.tostring(array.get(zPv, j)) + " piv / " + str.tostring(array.get(zT, j)) + " touches"
                array.push(boxes, box.new(startBar, hi_, bar_index + extendBars, lo_,
                     border_color = color.new(colRes, 40), bgcolor = colRes, text = txt,
                     text_color = color.gray, text_size = size.small, text_halign = text.align_right))

    if showUnconf
        array.push(lns, line.new(bar_index - k + 1, recHi, bar_index + extendBars, recHi,
             color = color.red, style = line.style_dashed, width = 1))
        array.push(lns, line.new(bar_index - k + 1, recLo, bar_index + extendBars, recLo,
             color = color.teal, style = line.style_dashed, width = 1))

    if showTable
        table.cell(tbl, 0, 0, "",           text_size = size.small)
        table.cell(tbl, 1, 0, "Zone",       text_size = size.small)
        table.cell(tbl, 2, 0, "Distance",   text_size = size.small)
        table.cell(tbl, 0, 1, "Resistance", text_color = color.red,  text_size = size.small)
        table.cell(tbl, 1, 1, na(nearResLo) ? "none" : str.tostring(nearResLo, format.mintick) + " - " + str.tostring(nearResHi, format.mintick), text_size = size.small)
````
