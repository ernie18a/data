# Confluence Zones [ThetaLoop]

- url: https://www.tradingview.com/script/w9V3jYh2-Confluence-Zones-ThetaLoop/
- type: indicator
- pine_id: PUB;89eebb5e391a425da661ebe78749fa9d
- version: 1.0

## Description

Most charts carry more lines than decisions. A 200-day average here, a Fibonacci level there, a pivot from last spring, an anchored VWAP someone swears by. Each line on its own is a maybe. When four of them land inside the same narrow band of price, the maybe turns into a place that a lot of different traders, using a lot of different methods, are all watching at the same time.

This indicator does the stacking for you. It collects the levels most swing traders already use, measures how close they sit to each other, and merges the overlapping ones into shaded zones with a score. The score is simply the number of independent levels inside the zone. One line is a line. Three or four lines in one band is confluence.

[b]Why combine them at all?
[/b]Every one of these tools is popular with a different group of traders. Moving averages are watched by trend followers, anchored VWAP by volume-based traders, Fibonacci by swing traders, pivots by price-action traders. A level that shows up in several of these methods at once is more likely to produce a reaction than any single line, because more participants have a reason to act there. Plotting all of them separately turns the chart into spaghetti. Clustering them answers the only question that matters: where do they agree?

[b]What goes into the pot
[/b]- SMA 200, EMA 200 and SMA 50
- Anchored VWAP from the major high and from the major low of the lookback (re-anchors automatically whenever a new major high or low prints)
- Fibonacci 38.2 / 50 / 61.8 of the major swing (labels follow the swing direction)
- The last two confirmed pivot highs and pivot lows

Everything is calculated on the level timeframe (Daily by default), no matter which chart timeframe you are looking at. You can watch daily confluence while trading a 15-minute chart.

[b]How zones are built
[/b]All levels are sorted by price. Starting from the lowest, every level within X x ATR of the first level of the current group joins that group (default 0.6 x ATR(14) of the level timeframe). Using ATR instead of a fixed percentage keeps the zone width proportional to the symbol's volatility: 0.6 ATR is narrow on a quiet utility and wide on a semiconductor. Groups below the minimum score are not drawn.

[b]Reading the chart
[/b]- Green zone: below price, potential support
- Red zone: above price, potential resistance
- Orange zone: price is inside it right now
- Darker shading means a higher score
- The label shows the score and which levels formed the zone
- The table lists the six nearest zones with their distance in percent and in ATR units

The ATR distance is the more useful of the two. "4% away" means very different things on different symbols. "1.2 ATR away" means roughly the same thing everywhere.

[b]Repainting
[/b]All levels come from the last completed bar of the level timeframe. Zones update once per new level-timeframe bar and do not move around during the current one. Pivots need "pivot strength" bars on their right side before they are confirmed, so they appear with that delay by design.

[b]Alerts
[/b]Create an alert with the condition "Any alert() function call". It fires once per bar close when price closes inside a zone whose score is at or above the alert threshold.

[b]Settings worth touching
[/b]- Level timeframe: D for swing trading, W for longer-term positioning
- Zone width: smaller gives fewer, tighter zones; larger merges more aggressively
- Minimum score: 2 shows every overlap, 3 shows only the strong areas
- Ignore levels farther than: keeps distant levels out of the clustering

[b]Limitations
[/b]Confluence is a map, not a signal. A zone tells you where a reaction is more likely to be watched, not whether it will hold. Anchored VWAP relies on volume; on symbols without real volume data (some indices, forex) switch it off. On charts above the level timeframe, the chart timeframe is used instead.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ThetaLoop
//@version=6
indicator("Confluence Zones [ThetaLoop]", shorttitle = "Confluence [TL]", overlay = true, max_boxes_count = 60, max_labels_count = 60)

// ───────────────────────────── Inputs ─────────────────────────────
grpS      = "Level sources"
tfIn      = input.timeframe("D", "Level timeframe", group = grpS, tooltip = "Timeframe the levels are calculated on. Values come from the last completed bar of this timeframe, so zones do not repaint. On charts above this timeframe, the chart timeframe is used instead.")
useSma200 = input.bool(true, "SMA 200", group = grpS, inline = "ma")
useEma200 = input.bool(true, "EMA 200", group = grpS, inline = "ma")
useSma50  = input.bool(true, "SMA 50", group = grpS, inline = "ma")
useAvwap  = input.bool(true, "Anchored VWAP from major high and low", group = grpS)
useFib    = input.bool(true, "Fibonacci 38.2 / 50 / 61.8 of the major swing", group = grpS)
usePiv    = input.bool(true, "Last two pivot highs and lows", group = grpS)
swingLen  = input.int(252, "Major swing lookback", minval = 20, group = grpS, tooltip = "Bars of the level timeframe. 252 daily bars = about one year.")
pivLen    = input.int(10, "Pivot strength", minval = 2, group = grpS, tooltip = "Bars required on each side of a pivot high / low.")

grpC      = "Clustering"
tolMult   = input.float(0.6, "Zone width (x ATR)", minval = 0.1, step = 0.1, group = grpC, tooltip = "Levels closer together than this many ATRs of the level timeframe are merged into one zone.")
atrLen    = input.int(14, "ATR length", minval = 1, group = grpC)
minScore  = input.int(2, "Minimum score to draw", minval = 1, group = grpC)
maxDist   = input.float(25.0, "Ignore levels farther than (%)", minval = 1.0, group = grpC)

grpD      = "Display"
drawBack  = input.int(150, "Draw zones back (bars)", minval = 10, group = grpD)
supCol    = input.color(#26a69a, "Support", group = grpD, inline = "col")
resCol    = input.color(#ef5350, "Resistance", group = grpD, inline = "col")
inCol     = input.color(#ff9800, "At price", group = grpD, inline = "col")
showTable = input.bool(true, "Show zone table", group = grpD)
tablePos  = input.string("Top right", "Table position", options = ["Top right", "Bottom right", "Top left", "Bottom left"], group = grpD)

grpA       = "Alerts"
alertScore = input.int(3, "Alert when a bar closes inside a zone with score ≥", minval = 1, group = grpA, tooltip = "Create an alert with the condition 'Any alert() function call'.")

// ───────────────────────── Higher-timeframe levels ─────────────────────────
f_levels(simple int swingN, simple int pivN, simple int atrN) =>
    s200 = ta.sma(close, 200)
    e200 = ta.ema(close, 200)
    s50  = ta.sma(close, 50)
    hh   = ta.highest(high, swingN)
    ll   = ta.lowest(low, swingN)
    // 1 = the major high came after the major low (up-swing), 0 = down-swing
    upSw = ta.highestbars(high, swingN) > ta.lowestbars(low, swingN) ? 1 : 0
    // anchored VWAPs reset each time a new major high / low is printed
    avH  = ta.vwap(hlc3, high >= hh)
    avL  = ta.vwap(hlc3, low <= ll)
    ph   = ta.pivothigh(high, pivN, pivN)
    pl   = ta.pivotlow(low, pivN, pivN)
    ph1  = ta.valuewhen(not na(ph), ph, 0)
    ph2  = ta.valuewhen(not na(ph), ph, 1)
    pl1  = ta.valuewhen(not na(pl), pl, 0)
    pl2  = ta.valuewhen(not na(pl), pl, 1)
    atrV = ta.atr(atrN)
    // [1] + lookahead_on = values of the last COMPLETED bar → no repainting
    [s200[1], e200[1], s50[1], hh[1], ll[1], upSw[1], avH[1], avL[1], ph1[1], ph2[1], pl1[1], pl2[1], atrV[1]]

tfUse = timeframe.in_seconds(tfIn) >= timeframe.in_seconds(timeframe.period) ? tfIn : timeframe.period

[lvSma200, lvEma200, lvSma50, lvHigh, lvLow, lvUp, lvAvH, lvAvL, lvPh1, lvPh2, lvPl1, lvPl2, lvAtr] = request.security(syminfo.tickerid, tfUse, f_levels(swingLen, pivLen, atrLen), lookahead = barmerge.lookahead_on)

// Source levels in the Data Window (not drawn on the chart)
plot(lvSma200, "SMA 200 (level TF)", display = display.data_window)
plot(lvEma200, "EMA 200 (level TF)", display = display.data_window)
plot(lvSma50,  "SMA 50 (level TF)",  display = display.data_window)
plot(lvAvH,    "AVWAP from major high", display = display.data_window)
plot(lvAvL,    "AVWAP from major low",  display = display.data_window)
plot(lvAtr,    "ATR (level TF)",        display = display.data_window)

// ───────────────────────────── Helpers ─────────────────────────────
f_add(array<float> prices, array<string> names, float v, string name, bool on) =>
    if on and not na(v) and math.abs(v - close) / close * 100.0 <= maxDist
        array.push(prices, v)
        array.push(names, name)

var array<box>   zBoxes  = array.new<box>()
var array<label> zLabels = array.new<label>()
var table zt = table.new(tablePos == "Top right" ? position.top_right : tablePos == "Bottom right" ? position.bottom_right : tablePos == "Top left" ? position.top_left : position.bottom_left, 4, 8, bgcolor = color.new(#131722, 10), border_color = color.new(color.gray, 70), border_width = 1)

// ───────────────────────────── Build zones ─────────────────────────────
if barstate.islast
    for b in zBoxes
        box.delete(b)
    array.clear(zBoxes)
    for l in zLabels
        label.delete(l)
    array.clear(zLabels)

    // 1) collect levels
    prices = array.new<float>()
    names  = array.new<string>()
    f_add(prices, names, lvSma200, "SMA200", useSma200)
    f_add(prices, names, lvEma200, "EMA200", useEma200)
    f_add(prices, names, lvSma50, "SMA50", useSma50)
    f_add(prices, names, lvAvH, "AVWAP high", useAvwap)
    f_add(prices, names, lvAvL, "AVWAP low", useAvwap)
    rng = lvHigh - lvLow
    up  = lvUp == 1
    f_add(prices, names, lvHigh - 0.382 * rng, up ? "Fib 38.2" : "Fib 61.8", useFib)
    f_add(prices, names, lvHigh - 0.500 * rng, "Fib 50", useFib)
    f_add(prices, names, lvHigh - 0.618 * rng, up ? "Fib 61.8" : "Fib 38.2", useFib)
    f_add(prices, names, lvPh1, "Pivot H", usePiv)
    f_add(prices, names, lvPh2, "Pivot H2", usePiv)
    f_add(prices, names, lvPl1, "Pivot L", usePiv)
    f_add(prices, names, lvPl2, "Pivot L2", usePiv)

    // 2) cluster neighbouring levels (span of a zone ≤ tolerance)
    tol = lvAtr * tolMult
    zLo = array.new<float>()
    zHi = array.new<float>()
    zSc = array.new<int>()
    zNm = array.new<string>()
    n   = array.size(prices)
    if n > 0 and not na(tol)
        idx = array.sort_indices(prices, order.ascending)
        float  cLo  = na
        float  cHi  = na
        int    cCnt = 0
        string cNm  = ""
        for i = 0 to n - 1
            k  = array.get(idx, i)
            p  = array.get(prices, k)
            nm = array.get(names, k)
            if na(cLo)
                cLo  := p
                cHi  := p
                cCnt := 1
                cNm  := nm
            else if p - cLo <= tol
                cHi  := p
                cCnt += 1
                cNm  := cNm + " · " + nm
            else
                array.push(zLo, cLo)
                array.push(zHi, cHi)
                array.push(zSc, cCnt)
                array.push(zNm, cNm)
                cLo  := p
                cHi  := p
                cCnt := 1
                cNm  := nm
        array.push(zLo, cLo)
        array.push(zHi, cHi)
        array.push(zSc, cCnt)
        array.push(zNm, cNm)

    // 3) draw zones
    pad    = na(tol) ? 0.0 : tol * 0.15
    tDist  = array.new<float>()
    tRow   = array.new<int>()
    zCount = array.size(zLo)
    if zCount > 0
        for j = 0 to zCount - 1
            sc = array.get(zSc, j)
            if sc >= minScore
                lo   = array.get(zLo, j) - pad
                hi   = array.get(zHi, j) + pad
                mid  = (lo + hi) / 2
                inZ  = close >= lo and close <= hi
                base = inZ ? inCol : mid < close ? supCol : resCol
                tr   = sc >= 4 ? 60 : sc == 3 ? 72 : 84
                array.push(zBoxes, box.new(bar_index - drawBack, hi, bar_index, lo, border_color = color.new(base, 35), bgcolor = color.new(base, tr), extend = extend.right))
                array.push(zLabels, label.new(bar_index + 3, mid, "Score " + str.tostring(sc) + "  |  " + array.get(zNm, j), style = label.style_label_left, color = color.new(base, 20), textcolor = color.white, size = size.small))
                array.push(tDist, math.abs(mid - close))
                array.push(tRow, j)
                if sc >= alertScore and inZ
                    alert(syminfo.ticker + ": closed inside confluence zone " + str.tostring(lo, format.mintick) + " – " + str.tostring(hi, format.mintick) + " (score " + str.tostring(sc) + ")", alert.freq_once_per_bar_close)

    // 4) table: nearest zones first
    if showTable
        table.clear(zt, 0, 0, 3, 7)
        table.cell(zt, 0, 0, "Zone",     text_color = color.silver, text_size = size.small)
        table.cell(zt, 1, 0, "Score",    text_color = color.silver, text_size = size.small)
        table.cell(zt, 2, 0, "Dist %",   text_color = color.silver, text_size = size.small)
        table.cell(zt, 3, 0, "Dist ATR", text_color = color.silver, text_size = size.small)
        rows = array.size(tDist)
        if rows == 0
            table.cell(zt, 0, 1, "no zone with score ≥ " + str.tostring(minScore), text_color = color.gray, text_size = size.small)
        else
            ord = array.sort_indices(tDist, order.ascending)
            for r = 0 to math.min(rows, 6) - 1
                j    = array.get(tRow, array.get(ord, r))
                lo   = array.get(zLo, j) - pad
                hi   = array.get(zHi, j) + pad
                mid  = (lo + hi) / 2
                dPct = (mid - close) / close * 100
                dAtr = (mid - close) / lvAtr
                c    = close >= lo and close <= hi ? inCol : mid < close ? supCol : resCol
                table.cell(zt, 0, r + 1, str.tostring(lo, format.mintick) + " – " + str.tostring(hi, format.mintick), text_color = c, text_size = size.small)
                table.cell(zt, 1, r + 1, str.tostring(array.get(zSc, j)), text_color = color.white, text_size = size.small)
                table.cell(zt, 2, r + 1, (dPct >= 0 ? "+" : "") + str.tostring(dPct, "0.0") + "%", text_color = color.white, text_size = size.small)
                table.cell(zt, 3, r + 1, (dAtr >= 0 ? "+" : "") + str.tostring(dAtr, "0.0"), text_color = color.white, text_size = size.small)
````
