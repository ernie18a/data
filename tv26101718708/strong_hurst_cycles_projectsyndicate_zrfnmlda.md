# Strong Hurst Cycles | ProjectSyndicate

- url: https://www.tradingview.com/script/ZRfNMldA-Strong-Hurst-Cycles-ProjectSyndicate/
- type: indicator
- pine_id: PUB;071928dab35f4a1084bf1f1e60fc9378
- version: 1.0

## Description

Hurst Cycles Pro decomposes the chart into a nest of harmonic cycles and projects when the next low of each one is due — so instead of guessing where a turn might land, you can see the cycle structure, read which cycles are lining up, and frame your analysis around the moments several of them are set to bottom together. It builds 4–8 nested cycles each one double the length of the cycle below it, following Hurst's harmonic principle, auto-sizes them to your timeframe, confirms every cycle low on a centred non-repainting window, and renders the whole structure as smooth scalloped arcs in a dedicated pane with a ranked turning-point strip beneath. A dashboard then translates every cycle into plain language — its period, how long since its last low, when its next low is projected, and whether it is currently rising or falling.

[b]IMPORTANT NOTE: Run system on H1 H4 D1 timeframes.[/b]

🌀 NESTED HARMONIC CYCLES
4–8 cycles, each exactly double the length of the one below it (Hurst's harmonic doubling), drawn as smooth scalloped polylines. Longer cycles are given taller arcs, so amplitude scales with period the way real cyclic structure does. The base cycle either auto-scales to your timeframe — shorter on intraday, expanding on H4 / D1 — or you set it manually.

🔮 NEXT-LOW PROJECTION
Each cycle's next arc is projected forward as a dashed scallop, and the dashboard reports the projected time of every cycle's next low. The longest cycle anchors the structure; the shorter ones nest inside it.

💎 TURNING-POINT DIAMONDS
Two synchronised views of the same lows. A full-history diamond strip lives in the cycle pane — drawn with plotshape, so it covers ALL history with no 500-object limit, one row per cycle. Matching diamond stacks are pinned to the actual cycle-low candles on the price chart, stacked by cycle order. Independent size controls for each.

🥇 MAJOR SYNCHRONISED LOWS
When a chosen number of cycles bottom within tolerance of one another, the level is flagged as a MAJOR low and marked with a triangle in the pane — Hurst's synchronicity principle, where cycles tend to trough together. The alignment threshold and the confluence tolerance are both adjustable (tolerance can auto-size from the base cycle).

📊 CYCLE DASHBOARD
A pinned table grades the whole structure at a glance: for every cycle it shows the period, the last low (how long ago, in time), the next low (projected, in time), and the live phase (▲ up / ▼ down). A footer line projects the next major turn as a calendar date and time, with how many cycles are converging on it. Four corner positions.

🎯 DOMINANT-CYCLE TOOLS — VTL & FLD
Nominate a dominant cycle and the indicator overlays its classic Hurst tools onto the price chart: the VTL (Valid Trend Line) drawn through its last two lows and extended forward, and the FLD (Future Line of Demarcation), the price midline displaced forward by half the dominant cycle. Both are optional and force-overlaid onto price.

🔒 NON-REPAINTING BY CONSTRUCTION
Every trough is confirmed on a centred window — only after P/2 bars have closed on each side. A printed cycle low is locked in and never shifts as new bars arrive; only the still-forming right edge can update.

🎨 OWN PANE, LOCKED SCALE
The cycles and the diamond strip share their own pane on a single flat baseline, perfectly aligned, with the vertical scale locked so the arcs and rows don't jump around as detections land. Eight fully configurable cycle colours run short → long.

🔔 NATIVE ALERTS
Dedicated alerts for a major synchronised low forming and for the dominant cycle confirming a trough.

🔧 FULLY ADJUSTABLE
Number of cycles, auto vs manual base, arc heights and smoothness, history span and next-arc projection; diamond visibility, size and history span, plus pane row spacing and price stack spacing; confluence tolerance and the major-low alignment threshold; dominant-cycle selection and VTL / FLD toggles; dashboard position; and the full eight-colour cycle theme.

[b]🚀 Works on gold (XAUUSD), silver, forex, crypto, stocks and indices, H1/H4/D1 TF.[/b]

────────────────────────
HOW TO USE IT — TWO WORKFLOWS
The cycles give you timing and context, not orders. Use them to decide WHEN and in WHICH direction to apply your own method.

TIME THE TURN — synchronised cycle lows
Use when several cycles are projected to bottom together.

Watch the dashboard's "Next low" column and the "Next major turn" footer for a date where multiple cycles converge.
The strongest windows are the MAJOR synchronised lows (triangle in the pane) — more aligned cycles, more weight.
Treat the projected date/time as a window to focus your analysis, not as an automatic entry.
Wait for your own price-action confirmation at the level before acting, and define risk beyond the structure that would invalidate the low.

READ THE TREND — dominant cycle, VTL & FLD
Use to judge whether a projected low is likely trend-resuming or just a counter-trend bounce.

Set the dominant cycle to the one that best fits the swings you trade.
The VTL frames the prevailing trend off the last two dominant lows; how price holds relative to it describes trend health.
The FLD acts as the dominant cycle's demarcation line; interactions with it describe momentum shifts of that cycle.
Combine the dashboard phase (▲ / ▼) with VTL / FLD context to weight the conviction of the next projected low.

Rule of thumb: many cycles bottoming together, with a fresh dominant-cycle phase, is the highest-conviction timing window. A lone short-cycle low against a falling dominant cycle is weaker context.
────────────────────────
⚠️ THIS IS NOT A SIGNAL SYSTEM. Hurst Cycles is an analytical timing-and-context tool built for advanced traders who already have a method. It projects cycle structure and probable turning windows — it does NOT generate buy / sell signals, and it makes no promise that a projected low will actually occur. Cycles drift, skip and occasionally invert in live markets, and the projection is only as good as the recent cyclic rhythm. Always combine it with your own strategy, price-action analysis and risk management to confirm setups. Past cyclic behaviour does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("Strong Hurst Cycles ", overlay = false, max_polylines_count = 100, max_labels_count = 500, max_lines_count = 500)

max_bars_back(low, 1001)
max_bars_back(high, 1001)

gC = "Cycle Configuration"
autoMode  = input.bool(true,  "Auto-scale base cycle to timeframe",                group = gC, tooltip = "ON: base cycle length is chosen from the chart timeframe (shorter on H1, expanding on H4 / D1). OFF: use the manual base below.")
numCycles = input.int(6, "Number of nested cycles", minval = 4, maxval = 8,        group = gC, tooltip = "Each successive cycle is double the previous (harmonic principle).")
manualBase= input.int(20, "Manual base cycle length (bars)", minval = 6, maxval = 200, group = gC)

gA = "Cycle Arcs"
showArcs   = input.bool(true,  "Show cycle arcs",                                  group = gA)
hMaxArc    = input.float(3.0, "Longest-cycle arc height",  minval = 0.5, maxval = 8.0, step = 0.1, group = gA)
hMinArc    = input.float(0.6, "Shortest-cycle arc height", minval = 0.2, maxval = 4.0, step = 0.1, group = gA)
arcMaxSegs = input.int(40, "Arc smoothness (max segments)", minval = 10, maxval = 80, group = gA)
drawSpan   = input.int(5000, "Bars of history for arcs", minval = 300, maxval = 10000, group = gA, tooltip = "Arcs are polylines; raise this to extend cycle history.")
showProj   = input.bool(true, "Project next cycle arc (dashed)",                   group = gA)

gD = "Turning-Point Diamonds"
showPaneDia  = input.bool(true,  "Diamond strip in cycle pane (full history)",     group = gD, tooltip = "Drawn with plotshape, so it covers ALL history with no object limit.")
showPriceDia = input.bool(true,  "Diamond stacks on price (at cycle lows)",        group = gD)
paneDiaSize  = input.string("Tiny", "Pane diamond size", options = ["Tiny", "Small", "Normal", "Auto (by cycle)"], group = gD)
priceDiaSize = input.string("Tiny", "Price diamond size", options = ["Tiny", "Small", "Normal", "Large", "Auto (by cycle)"], group = gD)
priceDiaSpan = input.int(2500, "Bars of history for PRICE diamonds", minval = 200, maxval = 6000, group = gD, tooltip = "Price-chart diamonds use chart labels (hard-capped at 500 by TradingView). Pane diamonds are unaffected.")
stripOff     = input.float(0.7, "Pane: first row below baseline", minval = 0.1, maxval = 4.0, step = 0.1, group = gD)
stripGap     = input.float(0.55,"Pane: row spacing per cycle",    minval = 0.1, maxval = 2.0, step = 0.05,group = gD)
priceGap     = input.float(0.30,"Price: stack spacing (× ATR)",   minval = 0.05,maxval = 2.0, step = 0.05,group = gD)
confTolIn    = input.int(0, "Confluence tolerance (bars, 0 = auto)", minval = 0, maxval = 50, group = gD)
majorThr     = input.int(3, "Cycles aligned to flag a MAJOR low", minval = 2, maxval = 8, group = gD)
showMajor    = input.bool(true,  "Mark major synchronised lows",                   group = gD)

gT = "Price-pane tools"
domSel  = input.int(4, "Dominant cycle (1 = shortest)", minval = 1, maxval = 8,    group = gT, tooltip = "Drives the VTL and FLD.")
showVTL = input.bool(false, "Show VTL (Valid Trend Line)",                         group = gT)
showFLD = input.bool(false, "Show FLD (Future Line of Demarcation)",               group = gT)

gDash = "Dashboard"
showDash = input.bool(true, "Show cycle dashboard (top-right of price)",           group = gDash)
dashPos  = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = gDash)

gP = "Cycle Colours (short → long)"
col0 = input.color(#b06bff, "Cycle 1", group = gP, inline = "p1")
col1 = input.color(#6b8cff, "2",       group = gP, inline = "p1")
col2 = input.color(#3aa0ff, "3",       group = gP, inline = "p1")
col3 = input.color(#1fc8c8, "4",       group = gP, inline = "p2")
col4 = input.color(#25d07a, "5",       group = gP, inline = "p2")
col5 = input.color(#b8d62b, "6",       group = gP, inline = "p2")
col6 = input.color(#ffb02b, "7",       group = gP, inline = "p3")
col7 = input.color(#ff5d5d, "8",       group = gP, inline = "p3")

tfSec = timeframe.in_seconds()
tfMin = tfSec / 60.0
tfLabel = tfMin < 60 ? str.tostring(tfMin, "#") + "m" : tfMin < 1440 ? str.tostring(tfMin / 60.0, "#.#") + "h" : str.tostring(tfMin / 1440.0, "#.#") + "d"

autoBase = tfMin <= 1 ? 80 : tfMin <= 5 ? 60 : tfMin <= 15 ? 45 : tfMin <= 30 ? 34 : tfMin <= 60 ? 24 : tfMin <= 240 ? 18 : tfMin <= 1440 ? 12 : 9
baseLen  = autoMode ? autoBase : manualBase
domSlot  = domSel - 1

p0 = baseLen
p1 = baseLen * 2
p2 = baseLen * 4
p3 = baseLen * 8
p4 = baseLen * 16
p5 = baseLen * 32
p6 = baseLen * 64
p7 = baseLen * 128

h0 = p0 / 2 > 500 ? 500 : int(p0 / 2)
h1 = p1 / 2 > 500 ? 500 : int(p1 / 2)
h2 = p2 / 2 > 500 ? 500 : int(p2 / 2)
h3 = p3 / 2 > 500 ? 500 : int(p3 / 2)
h4 = p4 / 2 > 500 ? 500 : int(p4 / 2)
h5 = p5 / 2 > 500 ? 500 : int(p5 / 2)
h6 = p6 / 2 > 500 ? 500 : int(p6 / 2)
h7 = p7 / 2 > 500 ? 500 : int(p7 / 2)

l0 = ta.lowest(low, 2 * h0 + 1)
l1 = ta.lowest(low, 2 * h1 + 1)
l2 = ta.lowest(low, 2 * h2 + 1)
l3 = ta.lowest(low, 2 * h3 + 1)
l4 = ta.lowest(low, 2 * h4 + 1)
l5 = ta.lowest(low, 2 * h5 + 1)
l6 = ta.lowest(low, 2 * h6 + 1)
l7 = ta.lowest(low, 2 * h7 + 1)

isT0 = 0 < numCycles and bar_index > 2 * h0 + 1 and low[h0] == l0
isT1 = 1 < numCycles and bar_index > 2 * h1 + 1 and low[h1] == l1
isT2 = 2 < numCycles and bar_index > 2 * h2 + 1 and low[h2] == l2
isT3 = 3 < numCycles and bar_index > 2 * h3 + 1 and low[h3] == l3
isT4 = 4 < numCycles and bar_index > 2 * h4 + 1 and low[h4] == l4
isT5 = 5 < numCycles and bar_index > 2 * h5 + 1 and low[h5] == l5
isT6 = 6 < numCycles and bar_index > 2 * h6 + 1 and low[h6] == l6
isT7 = 7 < numCycles and bar_index > 2 * h7 + 1 and low[h7] == l7

isTArr = array.from(isT0, isT1, isT2, isT3, isT4, isT5, isT6, isT7)
hArr   = array.from(h0, h1, h2, h3, h4, h5, h6, h7)
pArr   = array.from(p0, p1, p2, p3, p4, p5, p6, p7)
prcArr = array.from(low[h0], low[h1], low[h2], low[h3], low[h4], low[h5], low[h6], low[h7])

var palArr = array.from(col0, col1, col2, col3, col4, col5, col6, col7)

confTol = confTolIn > 0 ? confTolIn : math.max(2, int(baseLen * 0.20))
atr     = ta.atr(14)

paneTop = hMaxArc * 1.12
paneBot = -(stripOff + (numCycles - 1) * stripGap + 0.7)

slotColor(int s) => array.get(palArr, s)

ampBase(int s) =>
    frac = numCycles > 1 ? s / (numCycles - 1) : 0.0
    hMinArc + (hMaxArc - hMinArc) * frac

rowY(int s) => -(stripOff + s * stripGap)

durStr(int bars) =>
    m = bars * tfMin
    m >= 1440 ? str.tostring(m / 1440.0, "#.#") + "d" : m >= 60 ? str.tostring(m / 60.0, "#.#") + "h" : str.tostring(m, "#") + "m"

nextLowBar(int lastBarOfLow, int per) =>
    nb = lastBarOfLow
    if nb >= 0
        while nb <= bar_index
            nb := nb + per
    nb

var tBar   = array.new<int>()
var tSlot  = array.new<int>()
var tPrice = array.new<float>()

var fldBar = array.new<int>()
var fldVal = array.new<float>()

var cyclePL  = array.new<polyline>()
var projPL   = array.new<polyline>()
var priceDia = array.new<label>()
var line vtlLine = na
var polyline fldPL = na

for s = 0 to 7
    if s < numCycles and barstate.isconfirmed and array.get(isTArr, s)
        h  = array.get(hArr, s)
        cb = bar_index - h
        cp = array.get(prcArr, s)
        array.push(tBar, cb)
        array.push(tSlot, s)
        array.push(tPrice, cp)
        if array.size(tBar) > 8000
            array.shift(tBar)
            array.shift(tSlot)
            array.shift(tPrice)

if showFLD
    array.push(fldBar, bar_index)
    array.push(fldVal, hl2)
    if array.size(fldBar) > 10000
        array.shift(fldBar)
        array.shift(fldVal)

hLong = numCycles == 4 ? h3 : numCycles == 5 ? h4 : numCycles == 6 ? h5 : numCycles == 7 ? h6 : h7
R     = bar_index - hLong
mc    = 0
szt   = array.size(tBar)
stt   = math.max(0, szt - 90)
if showMajor and szt > 0
    for sl = 0 to numCycles - 1
        f = false
        for jj = stt to szt - 1
            if array.get(tSlot, jj) == sl and math.abs(array.get(tBar, jj) - R) <= confTol
                f := true
                break
        if f
            mc += 1
majorNow  = mc >= majorThr
majorMark = showMajor and majorNow and not majorNow[1]

d0 = showPaneDia and isT0 and barstate.isconfirmed ? rowY(0) : na
d1 = showPaneDia and isT1 and barstate.isconfirmed ? rowY(1) : na
d2 = showPaneDia and isT2 and barstate.isconfirmed ? rowY(2) : na
d3 = showPaneDia and isT3 and barstate.isconfirmed ? rowY(3) : na
d4 = showPaneDia and isT4 and barstate.isconfirmed ? rowY(4) : na
d5 = showPaneDia and isT5 and barstate.isconfirmed ? rowY(5) : na
d6 = showPaneDia and isT6 and barstate.isconfirmed ? rowY(6) : na
d7 = showPaneDia and isT7 and barstate.isconfirmed ? rowY(7) : na
pTiny = paneDiaSize == "Tiny"
pSml  = paneDiaSize == "Small"
pNrm  = paneDiaSize == "Normal"
pAuto = paneDiaSize == "Auto (by cycle)"
plotshape((pTiny or pAuto) ? d0 : na, "C1 ·t", shape.diamond, location.absolute, col0, offset = -h0, size = size.tiny)
plotshape(pSml  ? d0 : na, "C1 ·s", shape.diamond, location.absolute, col0, offset = -h0, size = size.small)
plotshape(pNrm  ? d0 : na, "C1 ·n", shape.diamond, location.absolute, col0, offset = -h0, size = size.normal)
plotshape((pTiny or pAuto) ? d1 : na, "C2 ·t", shape.diamond, location.absolute, col1, offset = -h1, size = size.tiny)
plotshape(pSml  ? d1 : na, "C2 ·s", shape.diamond, location.absolute, col1, offset = -h1, size = size.small)
plotshape(pNrm  ? d1 : na, "C2 ·n", shape.diamond, location.absolute, col1, offset = -h1, size = size.normal)
plotshape(pTiny ? d2 : na, "C3 ·t", shape.diamond, location.absolute, col2, offset = -h2, size = size.tiny)
plotshape((pSml or pAuto) ? d2 : na, "C3 ·s", shape.diamond, location.absolute, col2, offset = -h2, size = size.small)
plotshape(pNrm  ? d2 : na, "C3 ·n", shape.diamond, location.absolute, col2, offset = -h2, size = size.normal)
plotshape(pTiny ? d3 : na, "C4 ·t", shape.diamond, location.absolute, col3, offset = -h3, size = size.tiny)
plotshape((pSml or pAuto) ? d3 : na, "C4 ·s", shape.diamond, location.absolute, col3, offset = -h3, size = size.small)
plotshape(pNrm  ? d3 : na, "C4 ·n", shape.diamond, location.absolute, col3, offset = -h3, size = size.normal)
plotshape(pTiny ? d4 : na, "C5 ·t", shape.diamond, location.absolute, col4, offset = -h4, size = size.tiny)
plotshape(pSml  ? d4 : na, "C5 ·s", shape.diamond, location.absolute, col4, offset = -h4, size = size.small)
plotshape((pNrm or pAuto) ? d4 : na, "C5 ·n", shape.diamond, location.absolute, col4, offset = -h4, size = size.normal)
plotshape(pTiny ? d5 : na, "C6 ·t", shape.diamond, location.absolute, col5, offset = -h5, size = size.tiny)
plotshape(pSml  ? d5 : na, "C6 ·s", shape.diamond, location.absolute, col5, offset = -h5, size = size.small)
plotshape((pNrm or pAuto) ? d5 : na, "C6 ·n", shape.diamond, location.absolute, col5, offset = -h5, size = size.normal)
plotshape(pTiny ? d6 : na, "C7 ·t", shape.diamond, location.absolute, col6, offset = -h6, size = size.tiny)
plotshape(pSml  ? d6 : na, "C7 ·s", shape.diamond, location.absolute, col6, offset = -h6, size = size.small)
plotshape((pNrm or pAuto) ? d6 : na, "C7 ·n", shape.diamond, location.absolute, col6, offset = -h6, size = size.normal)
plotshape(pTiny ? d7 : na, "C8 ·t", shape.diamond, location.absolute, col7, offset = -h7, size = size.tiny)
plotshape(pSml  ? d7 : na, "C8 ·s", shape.diamond, location.absolute, col7, offset = -h7, size = size.small)
plotshape((pNrm or pAuto) ? d7 : na, "C8 ·n", shape.diamond, location.absolute, col7, offset = -h7, size = size.normal)
plotshape(majorMark ? paneTop * 0.94 : na, "Major synchronised low", shape.triangledown, location.absolute, #ffd54a, offset = -hLong, size = size.small)

plot(paneTop, "scale top", color = color.new(color.gray, 100))
plot(paneBot, "scale bot", color = color.new(color.gray, 100))
hline(0.0, "Cycle baseline", color = color.new(color.gray, 65), linestyle = hline.style_dotted)

tablePos = dashPos == "Top Right" ? position.top_right : dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : position.bottom_left
var table dash = table.new(tablePos, 5, 12, border_width = 1, frame_color = color.new(color.gray, 55), frame_width = 1, force_overlay = true)

if barstate.islast
    while array.size(cyclePL) > 0
        polyline.delete(array.pop(cyclePL))
    while array.size(projPL) > 0
        polyline.delete(array.pop(projPL))
    while array.size(priceDia) > 0
        label.delete(array.pop(priceDia))
    if not na(vtlLine)
        line.delete(vtlLine)
        vtlLine := na
    if not na(fldPL)
        polyline.delete(fldPL)
        fldPL := na

    minBar    = bar_index - drawSpan
    minPxDia  = bar_index - priceDiaSpan
    sz        = array.size(tBar)

    lastArr = array.new<int>(8, -1)
    prevArr = array.new<int>(8, -1)

    for s = 0 to numCycles - 1
        per = array.get(pArr, s)
        col = slotColor(s)
        aB  = ampBase(s)
        dsz = priceDiaSize == "Auto (by cycle)" ? (s >= 4 ? size.normal : s >= 2 ? size.small : size.tiny) : priceDiaSize == "Small" ? size.small : priceDiaSize == "Normal" ? size.normal : priceDiaSize == "Large" ? size.large : size.tiny

        pts = array.new<chart.point>()
        int prevArcB = na
        int lastB    = na
        int prev2B   = na
        float lastP  = na
        float prev2P = na

        if sz > 0
            for j = 0 to sz - 1
                if array.get(tSlot, j) == s
                    tb = array.get(tBar, j)
                    pp = array.get(tPrice, j)
                    if tb >= minBar and showArcs
                        if not na(prevArcB)
                            w = tb - prevArcB
                            if w > 0
                                wf   = math.min(1.15, math.max(0.35, w / per))
                                amp  = aB * wf
                                segs = int(math.min(arcMaxSegs + 0.0, math.max(8.0, w * 0.6)))
                                for k = 0 to segs
                                    t  = k / segs
                                    xx = prevArcB + int(math.round(t * w))
                                    yy = amp * math.sin(math.pi * t)
                                    array.push(pts, chart.point.from_index(xx, yy))
                        prevArcB := tb
                    if tb >= minPxDia and showPriceDia
                        yPx = pp - (s + 1) * atr * priceGap
                        pl2 = label.new(tb, yPx, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_diamond, color = col, size = dsz, force_overlay = true)
                        array.push(priceDia, pl2)
                    prev2B := lastB
                    prev2P := lastP
                    lastB  := tb
                    lastP  := pp

        array.set(lastArr, s, na(lastB) ? -1 : lastB)
        array.set(prevArr, s, na(prev2B) ? -1 : prev2B)

        if showArcs and array.size(pts) > 1
            pl = polyline.new(pts, curved = true, closed = false, line_color = col, line_style = line.style_solid, line_width = 2)
            array.push(cyclePL, pl)

        if showProj and showArcs and not na(lastB)
            ppts  = array.new<chart.point>()
            segsP = int(math.min(arcMaxSegs + 0.0, math.max(10.0, per * 0.6)))
            for k = 0 to segsP
                t  = k / segsP
                xx = lastB + int(math.round(t * per))
                yy = aB * math.sin(math.pi * t)
                array.push(ppts, chart.point.from_index(xx, yy))
            np = polyline.new(ppts, curved = true, closed = false, line_color = color.new(col, 45), line_style = line.style_dashed, line_width = 1)
            array.push(projPL, np)

        if showVTL and s == domSlot and not na(prev2B) and not na(lastB) and not na(prev2P) and not na(lastP)
            vtlLine := line.new(prev2B, prev2P, lastB, lastP, xloc = xloc.bar_index, color = color.new(#ff4dff, 0), style = line.style_dashed, width = 2, extend = extend.right, force_overlay = true)

    if showFLD
        domPeriod = domSel == 1 ? p0 : domSel == 2 ? p1 : domSel == 3 ? p2 : domSel == 4 ? p3 : domSel == 5 ? p4 : domSel == 6 ? p5 : domSel == 7 ? p6 : p7
        fldHalf   = int(domPeriod / 2)
        fsz       = array.size(fldBar)
        fstart    = math.max(0, fsz - drawSpan)
        fpts      = array.new<chart.point>()
        if fsz > 0
            for j = fstart to fsz - 1
                array.push(fpts, chart.point.from_index(array.get(fldBar, j) + fldHalf, array.get(fldVal, j)))
        if array.size(fpts) > 1
            fldPL := polyline.new(fpts, curved = false, closed = false, line_color = color.new(#26c6da, 0), line_style = line.style_solid, line_width = 1, force_overlay = true)

    if showDash
        table.cell(dash, 0, 0, "Cycle " + tfLabel, text_color = color.white, bgcolor = color.new(color.black, 25), text_size = size.small)
        table.cell(dash, 1, 0, "Period",   text_color = color.white, bgcolor = color.new(color.black, 25), text_size = size.small)
        table.cell(dash, 2, 0, "Last low", text_color = color.white, bgcolor = color.new(color.black, 25), text_size = size.small)
        table.cell(dash, 3, 0, "Next low", text_color = color.white, bgcolor = color.new(color.black, 25), text_size = size.small)
        table.cell(dash, 4, 0, "Phase",    text_color = color.white, bgcolor = color.new(color.black, 25), text_size = size.small)

        int bestBar = na
        bestCnt = 0
        for s = 0 to numCycles - 1
            per   = array.get(pArr, s)
            hh    = array.get(hArr, s)
            lb4   = array.get(lastArr, s)
            since = lb4 >= 0 ? bar_index - lb4 : na
            nbar  = nextLowBar(lb4, per)
            nextIn= nbar >= 0 ? nbar - bar_index : na
            rising= not na(since) and since < hh
            row   = s + 1
            tag   = "C" + str.tostring(s + 1) + (s == domSlot ? " ◆" : "")
            table.cell(dash, 0, row, tag, text_color = slotColor(s), bgcolor = color.new(color.black, 50), text_size = size.small)
            table.cell(dash, 1, row, durStr(per), text_color = color.white, bgcolor = color.new(color.black, 60), text_size = size.small)
            table.cell(dash, 2, row, na(since) ? "–" : durStr(since) + " ago", text_color = color.silver, bgcolor = color.new(color.black, 60), text_size = size.small)
            table.cell(dash, 3, row, na(nextIn) ? "–" : "in " + durStr(nextIn), text_color = color.silver, bgcolor = color.new(color.black, 60), text_size = size.small)
            table.cell(dash, 4, row, na(since) ? "–" : (rising ? "▲ up" : "▼ dn"), text_color = rising ? color.lime : color.red, bgcolor = color.new(color.black, 60), text_size = size.small)

            if lb4 >= 0
                c2 = 0
                for s2 = 0 to numCycles - 1
                    nb2 = nextLowBar(array.get(lastArr, s2), array.get(pArr, s2))
                    if nb2 >= 0 and math.abs(nb2 - nbar) <= confTol
                        c2 += 1
                if c2 > bestCnt
                    bestCnt := c2
                    bestBar := nbar

        footRow = numCycles + 1
        string ft = "Next major turn: –"
        if not na(bestBar)
            ahead   = bestBar - bar_index
            ftMs    = time + int(ahead * tfSec * 1000)
            dateStr = str.format_time(ftMs, "dd MMM HH:mm", syminfo.timezone)
            ft := "Next major turn: in " + durStr(ahead) + "  (" + dateStr + ")  ·  " + str.tostring(bestCnt) + " cycles"
        table.cell(dash, 0, footRow, ft, text_color = color.new(#ffd54a, 0), bgcolor = color.new(color.black, 25), text_size = size.small)
        table.merge_cells(dash, 0, footRow, 4, footRow)

domTroughNow = domSlot < numCycles and barstate.isconfirmed and array.get(isTArr, domSlot)
alertcondition(majorMark,    "Hurst — Major synchronised low", "Multiple Hurst cycles bottomed together (major low).")
alertcondition(domTroughNow, "Hurst — Dominant cycle trough",  "Dominant Hurst cycle confirmed a trough.")
````
