# Nambou Reclaim Radar

- url: https://www.tradingview.com/script/ib0Z66HV-Nambou-Reclaim-Radar/
- type: indicator
- pine_id: PUB;705a39bcbe7f43b3b0ac36d32d996574
- version: 1.0

## Description

WHAT IT DOES
Reclaim Radar finds recent swing highs and lows, draws them as levels, and then watches what price does at each one.

When price closes back above an old swing high, that level counts as reclaimed and its line turns green. When price closes below an old swing low, the level is lost and its line turns red. After that, the indicator waits for the first retest: a bar that comes back to touch the level and still closes on the right side of it.

WHAT YOU SEE ON THE CHART
• A table of every level being tracked, highest at the top, showing whether each one is still resistance or support, has been reclaimed or lost, and whether it has been retested yet. It also shows how far each level is from the current price, with the price slotted in between them.
• Labels on the levels closest to price, so you can read the price, the status and the distance at a glance. If two labels would run into each other, one is dropped from the chart (it stays in the table), so the text never overlaps.
• Small markers on the candles: ▲ under a bar that closed back above a swing high, ▼ over a bar that closed below a swing low, and ● on the first retest.

HOW I USE IT
A level that flips and then holds on the retest is a natural place to build a trade around, because it tells you exactly where the idea stops being valid. The indicator only points these moments out. The entry, stop and target are your call.

SETTINGS
• Pivot left and Pivot right: how many bars on each side it takes to count as a swing. Higher numbers mean fewer, stronger levels.
• Max levels tracked per side: once there are more than this, the oldest ones drop off.
• How many levels to label on each side of price, and how much space to keep between labels.
• Table on or off, where it sits, and one text size for everything.
• Optional alerts for the flip and for the retest.

WORTH KNOWING
A swing is only confirmed once the "Pivot right" number of bars has passed, so new levels show up with that delay. Once a level is drawn, it stays put. Works on any symbol and any timeframe.

This is a charting tool, not financial advice, and it doesn't predict where price will go.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Nambou_Signals
//
// Nambou Reclaim Radar  v1.4
// Tracks recent swing highs and lows as levels and follows what price does to them:
//   1. the FLIP: a close back above a swing high (the level is "reclaimed" and
//      its line turns green) or a close below a swing low (the level is "lost"
//      and its line turns red);
//   2. the RETEST: the first bar after the flip that touches the level and
//      closes back on the right side of it.
// A table lists every tracked level from the highest to the lowest with its
// state and its distance from the price, the levels nearest to the price are
// labelled on the chart, and the bars where a flip or a retest happened carry
// a marker.
// A swing is only confirmed "Pivot right" bars after it forms, so levels appear
// with that delay; once drawn they do not move. This marks structure. It is not
// a signal to trade and it does not predict anything.
//@version=6
indicator("Nambou Reclaim Radar", "Reclaim Radar", overlay = true, max_lines_count = 500, max_labels_count = 500, max_bars_back = 1000)

// -- Inputs --
gP = "Levels"
lenL = input.int(8, "Pivot left",  minval = 1, group = gP)
lenR = input.int(8, "Pivot right", minval = 1, group = gP)
maxN = input.int(6, "Max levels tracked per side", minval = 1, maxval = 25, group = gP)

gD = "Display"
labN       = input.int(3, "Label this many levels on each side of the price", minval = 0, maxval = 10, group = gD, tooltip = "The nearest levels are labelled first. 0 hides the labels. Every level is always listed in the table.")
gapPct     = input.float(4.0, "Level labels: minimum spacing (% of the visible price range)", minval = 0.5, maxval = 20.0, step = 0.5, group = gD, tooltip = "A level whose label would sit closer than this to another label is not labelled on the chart, so the texts never overlap. Raise it if labels touch.")
showMarks  = input.bool(true, "Mark flips and retests on the bars", group = gD)
showTable  = input.bool(true, "Show the level table", group = gD)
tablePosIn = input.string("Top right", "Table position", options = ["Top right", "Bottom right", "Bottom left", "Top left"], group = gD)
txtSizeIn  = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = gD)
offBars    = input.int(3, "Level labels: bars to the right of the last bar", minval = 1, maxval = 50, group = gD)
cRes = input.color(#FF3D71, "Resistance / lost", group = gD)
cSup = input.color(#00E5A0, "Support / reclaimed", group = gD)
cTxt = input.color(#D1D4DC, "Neutral text", group = gD)

gA = "Alerts"
aReclaim = input.bool(true, "Alert on reclaim / lost (the flip)", group = gA)
aRetest  = input.bool(true, "Alert on retest", group = gA)

// one text size everywhere
txtSize = txtSizeIn == "Tiny" ? size.tiny : txtSizeIn == "Normal" ? size.normal : size.small

// -- State (parallel arrays; state 0 intact, 1 flipped, 2 retested) --
var array<float> rLvl   = array.new_float()
var array<line>  rLn    = array.new_line()
var array<int>   rState = array.new_int()

var array<float> sLvl   = array.new_float()
var array<line>  sLn    = array.new_line()
var array<int>   sState = array.new_int()

prune(lns, lvls, st) =>
    while array.size(lvls) > maxN
        line.delete(array.shift(lns))
        array.shift(lvls)
        array.shift(st)

// -- New pivots become tracked levels --
ph = ta.pivothigh(lenL, lenR)
pl = ta.pivotlow(lenL, lenR)

if not na(ph)
    array.push(rLvl, ph)
    array.push(rLn, line.new(bar_index - lenR, ph, bar_index, ph, color = cRes, width = 2, extend = extend.right))
    array.push(rState, 0)
    prune(rLn, rLvl, rState)

if not na(pl)
    array.push(sLvl, pl)
    array.push(sLn, line.new(bar_index - lenR, pl, bar_index, pl, color = cSup, width = 2, extend = extend.right))
    array.push(sState, 0)
    prune(sLn, sLvl, sState)

// what happened on this bar (at most one marker of each kind, whatever the number of levels)
bool upFlip = false
bool upRet  = false
bool dnFlip = false
bool dnRet  = false

// -- Resistance -> reclaimed -> retest (bullish) --
if array.size(rLvl) > 0
    for i = 0 to array.size(rLvl) - 1
        lvl = array.get(rLvl, i)
        st  = array.get(rState, i)
        if st == 0 and close > lvl and close[1] <= lvl
            line.set_color(array.get(rLn, i), cSup)
            array.set(rState, i, 1)
            upFlip := true
            if aReclaim
                alert("Reclaim Radar: " + syminfo.ticker + " closed back above " + str.tostring(lvl, format.mintick), alert.freq_once_per_bar)
        else if st == 1 and low <= lvl and close >= lvl
            array.set(rState, i, 2)
            upRet := true
            if aRetest
                alert("Reclaim Radar: " + syminfo.ticker + " retested reclaimed level " + str.tostring(lvl, format.mintick), alert.freq_once_per_bar)

// -- Support -> lost -> retest from below (bearish) --
if array.size(sLvl) > 0
    for i = 0 to array.size(sLvl) - 1
        lvl = array.get(sLvl, i)
        st  = array.get(sState, i)
        if st == 0 and close < lvl and close[1] >= lvl
            line.set_color(array.get(sLn, i), cRes)
            array.set(sState, i, 1)
            dnFlip := true
            if aReclaim
                alert("Reclaim Radar: " + syminfo.ticker + " closed below " + str.tostring(lvl, format.mintick), alert.freq_once_per_bar)
        else if st == 1 and high >= lvl and close <= lvl
            array.set(sState, i, 2)
            dnRet := true
            if aRetest
                alert("Reclaim Radar: " + syminfo.ticker + " retested lost level " + str.tostring(lvl, format.mintick), alert.freq_once_per_bar)

// -- Markers on the bars: one small glyph per bar and side, not words, so nothing can overlap --
if showMarks
    if upFlip
        label.new(bar_index, low, "▲", yloc = yloc.belowbar, style = label.style_none, textcolor = cSup, size = size.huge)
    else if upRet
        label.new(bar_index, low, "●", yloc = yloc.belowbar, style = label.style_none, textcolor = cSup, size = size.huge)
    if dnFlip
        label.new(bar_index, high, "▼", yloc = yloc.abovebar, style = label.style_none, textcolor = cRes, size = size.huge)
    else if dnRet
        label.new(bar_index, high, "●", yloc = yloc.abovebar, style = label.style_none, textcolor = cRes, size = size.huge)

// -- Right-edge labels and the table: rebuilt on the last bar --
nameR(int st) => st == 0 ? "Resistance" : st == 1 ? "Reclaimed, not retested yet" : "Reclaimed and retested"
nameS(int st) => st == 0 ? "Support" : st == 1 ? "Lost, not retested yet" : "Lost and retested"

var array<label> tags = array.new_label()

// the label sits ON its own line with the chart's background behind the text,
// so the line does not run through the words
tag(float price, string txt, int side) =>
    color c = side > 0 ? cSup : cRes
    array.push(tags, label.new(bar_index + offBars, price, txt, style = label.style_label_left, color = chart.bg_color, textcolor = c, size = txtSize, textalign = text.align_left))

tPos = switch tablePosIn
    "Top right"    => position.top_right
    "Bottom right" => position.bottom_right
    "Bottom left"  => position.bottom_left
    => position.top_left

// rows: every level (2 x 25 at most) + the price row + the key
var table ladder = table.new(tPos, 3, 56, bgcolor = color.new(#131722, 10), border_color = color.new(#787B86, 85), border_width = 1, frame_color = color.new(#787B86, 60), frame_width = 1)

cell(int c, int r, string v, color col) =>
    table.cell(ladder, c, r, v, text_color = col, text_halign = c == 1 ? text.align_left : text.align_right, text_size = txtSize)

pctFrom(float p) => (p >= close ? "+" : "") + str.tostring((p - close) / close * 100.0, "0.00") + "%"

if barstate.islast
    for t in tags
        label.delete(t)
    array.clear(tags)
    table.clear(ladder, 0, 0, 2, 55)

    // every tracked level: price, state name, side (+1 green, -1 red)
    px = array.new_float()
    nm = array.new_string()
    sd = array.new_int()
    if array.size(rLvl) > 0
        for i = 0 to array.size(rLvl) - 1
            st = array.get(rState, i)
            array.push(px, array.get(rLvl, i))
            array.push(nm, nameR(st))
            array.push(sd, st == 0 ? -1 : 1)
    if array.size(sLvl) > 0
        for i = 0 to array.size(sLvl) - 1
            st = array.get(sState, i)
            array.push(px, array.get(sLvl, i))
            array.push(nm, nameS(st))
            array.push(sd, st == 0 ? 1 : -1)

    int n = array.size(px)
    if n > 0
        idx = array.sort_indices(px, order.descending)

        // labels: the levels nearest to the price first, a few on each side. A level
        // is skipped (it stays in the table) when its label would touch one already
        // placed, judged against the price range that is visible on the chart.
        if labN > 0
            float vHi = high
            float vLo = low
            int j = 0
            while j < 999 and time[j] >= chart.left_visible_bar_time
                vHi := math.max(vHi, high[j])
                vLo := math.min(vLo, low[j])
                j += 1
            float gap = (vHi - vLo) * gapPct / 100.0
            dist = array.new_float()
            for k = 0 to n - 1
                array.push(dist, math.abs(array.get(px, k) - close))
            near = array.sort_indices(dist, order.ascending)
            placed = array.new_float()
            int nUp = 0
            int nDn = 0
            for k = 0 to n - 1
                i = array.get(near, k)
                pi = array.get(px, i)
                bool isUp = pi > close
                bool room = isUp ? nUp < labN : nDn < labN
                bool clear = true
                if array.size(placed) > 0
                    for q = 0 to array.size(placed) - 1
                        if math.abs(array.get(placed, q) - pi) < gap
                            clear := false
                if room and clear
                    tag(pi, str.tostring(pi, format.mintick) + "  " + array.get(nm, i) + "  " + pctFrom(pi), array.get(sd, i))
                    array.push(placed, pi)
                    if isUp
                        nUp += 1
                    else
                        nDn += 1

        // the ladder: highest level first, the price in its place between them
        if showTable
            int r = 0
            bool priceDone = false
            for k = 0 to n - 1
                i = array.get(idx, k)
                pi = array.get(px, i)
                if not priceDone and pi <= close
                    cell(0, r, str.tostring(close, format.mintick), cTxt)
                    cell(1, r, "◀ price now", cTxt)
                    cell(2, r, "", cTxt)
                    priceDone := true
                    r += 1
                color c = array.get(sd, i) > 0 ? cSup : cRes
                cell(0, r, str.tostring(pi, format.mintick), c)
                cell(1, r, array.get(nm, i), c)
                cell(2, r, pctFrom(pi), c)
                r += 1
            if not priceDone
                cell(0, r, str.tostring(close, format.mintick), cTxt)
                cell(1, r, "◀ price now", cTxt)
                cell(2, r, "", cTxt)
                r += 1
            if showMarks
                table.cell(ladder, 0, r, "▲ ▼  a close through a level      ●  its first retest", text_color = color.new(cTxt, 30), text_halign = text.align_left, text_size = txtSize)
                table.merge_cells(ladder, 0, r, 2, r)
````
