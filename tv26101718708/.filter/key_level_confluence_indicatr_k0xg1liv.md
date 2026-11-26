# Key Level Confluence [Indicatr]

- url: https://www.tradingview.com/script/K0xG1liv-Key-Level-Confluence-Indicatr/
- type: indicator
- pine_id: PUB;3edafcb4195e4c9fbd9e4c119f0b3599
- version: 2.0

## Description

[b]Key Level Confluence[/b] collects the levels most traders already watch - previous day and week highs and lows, the previous close, daily pivot points and the Fibonacci retracement of the last swing - and only highlights the prices where several of these independent sources meet. One level is a line. Two or three different levels at the same price are a zone.

[b]WHAT IT DOES[/b]
Charts with every pivot, every previous high and every Fibonacci line quickly turn into noise. This script keeps the single levels in the background and draws gradient zones only where at least two different sources cluster. Zones above price are red, zones below price are green, and stronger zones (more sources) are drawn more intense. A table shows the nearest zone above and below, how many sources it contains and how far away it is.

[b]HOW IT WORKS[/b]
[list=1]
[*][b]Levels:[/b] previous day high / low / close (intraday charts), previous week high / low, optional previous month high / low, daily pivot points (Classic, Fibonacci or Camarilla) and auto Fibonacci 38.2 / 50 / 61.8 of the last confirmed swing.
[*][b]No lookahead:[/b] previous period values are built from the chart's own bars when a new day, week or month starts - no request.security, nothing repaints into the past.
[*][b]Reference range:[/b] on intraday charts distances are measured in the average daily range (ADR) of the last 14 days, so zones keep the same width on 1 minute and on 4 hours. Daily and higher charts use the ATR.
[*][b]Clustering:[/b] levels are sorted by price and grouped when they lie within 0.12 x reference of each other.
[*][b]Distinct sources only:[/b] a zone needs at least two different sources (day, week, month, pivots, Fibonacci). Three Fibonacci ratios close to each other are not counted as confluence.
[*][b]Drawing:[/b] each zone is drawn as a gradient from a light edge to a deep core, starts at the beginning of the current day and extends to the right. The tag shows one dot per source and the names of all levels inside.
[/list]

[b]HOW TO USE[/b]
[list]
[*]Use the zones as areas where reactions are more likely to be watched by many participants - for long and short ideas alike.
[*]A red zone above price is a potential area for profit taking on longs or for short setups; a green zone below price works the other way round.
[*]Combine with your own entry trigger; the zones are context, not signals.
[*]Alerts: zone above touched, zone below touched, any zone touched.
[/list]

[b]THE CHART[/b]
Gold (XAUUSD) 15 minutes. A red zone above price where R1 and the previous week high meet, green zones below where the previous close, Fibonacci levels and the daily pivot cluster, and another green zone at the previous week low and S2. Single levels such as PDH, PDL, S1 and R2 stay as thin dotted lines. The table shows the nearest zone above and below with its distance in ADR.

[b]WHAT IS ORIGINAL[/b]
Pivot, previous-period and Fibonacci tools exist separately. This script combines them, counts only distinct sources as confluence, normalises the zone width to the average daily range so it works on every intraday timeframe, and reduces the chart to the few prices where the levels actually overlap.

[b]CREDITS[/b]
Pivot point formulas (Classic, Fibonacci, Camarilla) and Fibonacci retracements are standard public methods. Swings use the built-in ta.pivothigh and ta.pivotlow functions.

[b]LIMITATIONS[/b]
[list]
[*]Daily levels depend on the session of the symbol (exchange time).
[*]The Fibonacci swing is confirmed after the swing length (default 20 bars), so it updates with a delay.
[*]Zones are drawn for the current day only and are recalculated when a new day starts.
[/list]

[b]Disclaimer[/b]
For educational and analytical purposes only. Not financial advice. Marks and signals are not buy or sell recommendations. Past behaviour does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("Key Level Confluence [Indicatr]", shorttitle="Level Confluence [Indicatr]", overlay=true, max_boxes_count=200, max_labels_count=100, max_lines_count=120, behind_chart=false)

// ===== Inputs =====
grpL = "Levels"
usePD   = input.bool(true,  "Previous day high / low / close", group=grpL)
usePW   = input.bool(true,  "Previous week high / low", group=grpL)
usePM   = input.bool(false, "Previous month high / low", group=grpL)
pivType = input.string("Classic", "Daily pivot points", options=["Off", "Classic", "Fibonacci", "Camarilla"], group=grpL)
useFib  = input.bool(true,  "Auto Fibonacci of the last swing (38.2 / 50 / 61.8)", group=grpL)
swLen   = input.int(20, "Swing detection length", minval=2, group=grpL)

grpC = "Confluence"
atrLen   = input.int(14, "Reference length (days / bars)", minval=1, group=grpC, tooltip="Intraday charts use the average daily range (ADR) of the last N days as reference, so zones keep the same width on 1m and 4h. Daily and higher charts use the ATR.")
tol      = input.float(0.12, "Levels form one zone within (x reference)", minval=0.01, step=0.01, group=grpC)
minScore = input.int(2, "Minimum different sources per zone", minval=2, maxval=5, group=grpC)
maxDist  = input.float(1.5, "Draw zones within (x reference) of price", minval=0.1, step=0.1, group=grpC)

grpD = "Display"
showLines = input.bool(true, "Show single levels (thin lines)", group=grpD, tooltip="Levels that are not part of a zone are shown as dotted lines with their name.")
showTbl   = input.bool(true, "Show nearest zones table", group=grpD)
colRes    = input.color(#D32F2F, "Zones above price: core", group=grpD, inline="r")
colResL   = input.color(#FF8A65, "edge", group=grpD, inline="r")
colSup    = input.color(#00796B, "Zones below price: core", group=grpD, inline="s")
colSupL   = input.color(#4DB6AC, "edge", group=grpD, inline="s")
layers    = input.int(6, "Gradient steps", minval=1, maxval=10, group=grpD)

// ===== Previous period high / low / close (no request.security, no lookahead) =====
prevHLC(simple string tf) =>
    var float curH = na
    var float curL = na
    var float curC = na
    var float pH = na
    var float pL = na
    var float pC = na
    if timeframe.change(tf)
        pH := curH
        pL := curL
        pC := curC
        curH := high
        curL := low
    else
        curH := math.max(nz(curH, high), high)
        curL := math.min(nz(curL, low), low)
    curC := close
    [pH, pL, pC]

atr = ta.atr(atrLen)
[pdH, pdL, pdC] = prevHLC("D")
// average daily range from completed days (intraday reference)
var array<float> dRanges = array.new_float()
if timeframe.change("D") and not na(pdH)
    dRanges.push(pdH - pdL)
    if dRanges.size() > atrLen
        dRanges.shift()
adr = dRanges.size() > 0 ? dRanges.avg() : na
ref = timeframe.isintraday and not na(adr) ? adr : atr
refName = timeframe.isintraday and not na(adr) ? "ADR" : "ATR"
[pwH, pwL, pwC] = prevHLC("W")
[pmH, pmL, pmC] = prevHLC("M")

// ===== Last swing for auto Fibonacci =====
ph = ta.pivothigh(high, swLen, swLen)
pl = ta.pivotlow(low, swLen, swLen)
var float swH = na
var float swL = na
var int lastSw = 0
if not na(ph)
    swH := ph
    lastSw := 1
if not na(pl)
    swL := pl
    lastSw := -1

// ===== Collect levels =====
// every level carries a source tag; confluence counts distinct sources only
addL(array<float> a, array<string> b, array<string> g, float v, string n, string src) =>
    if not na(v)
        a.push(v)
        b.push(n)
        g.push(src)

lv = array.new_float()
nm = array.new_string()
sg = array.new_string()
if usePD and not timeframe.isdwm
    addL(lv, nm, sg, pdH, "PDH", "d")
    addL(lv, nm, sg, pdL, "PDL", "d")
    addL(lv, nm, sg, pdC, "PDC", "d")
if usePW and timeframe.in_seconds() < timeframe.in_seconds("W")
    addL(lv, nm, sg, pwH, "PWH", "w")
    addL(lv, nm, sg, pwL, "PWL", "w")
if usePM and timeframe.in_seconds() < timeframe.in_seconds("M")
    addL(lv, nm, sg, pmH, "PMH", "m")
    addL(lv, nm, sg, pmL, "PML", "m")
if pivType != "Off" and not na(pdH)
    rng = pdH - pdL
    p = (pdH + pdL + pdC) / 3
    if pivType == "Classic"
        addL(lv, nm, sg, p, "P", "p")
        addL(lv, nm, sg, 2 * p - pdL, "R1", "p")
        addL(lv, nm, sg, 2 * p - pdH, "S1", "p")
        addL(lv, nm, sg, p + rng, "R2", "p")
        addL(lv, nm, sg, p - rng, "S2", "p")
    else if pivType == "Fibonacci"
        addL(lv, nm, sg, p, "P", "p")
        addL(lv, nm, sg, p + 0.382 * rng, "R1", "p")
        addL(lv, nm, sg, p - 0.382 * rng, "S1", "p")
        addL(lv, nm, sg, p + 0.618 * rng, "R2", "p")
        addL(lv, nm, sg, p - 0.618 * rng, "S2", "p")
    else
        addL(lv, nm, sg, pdC + rng * 1.1 / 4, "R3", "p")
        addL(lv, nm, sg, pdC - rng * 1.1 / 4, "S3", "p")
        addL(lv, nm, sg, pdC + rng * 1.1 / 2, "R4", "p")
        addL(lv, nm, sg, pdC - rng * 1.1 / 2, "S4", "p")
if useFib and not na(swH) and not na(swL) and swH > swL
    d = swH - swL
    for r in array.from(0.382, 0.5, 0.618)
        v = lastSw == 1 ? swH - r * d : swL + r * d
        addL(lv, nm, sg, v, "Fib " + str.tostring(r * 100, "#.#"), "f")

// ===== Cluster levels into zones =====
zLo  = array.new_float()
zHi  = array.new_float()
zN   = array.new_int()
zTxt = array.new_string()
n = lv.size()
if n > 0
    idx = lv.sort_indices()
    float gLo = na
    float gHi = na
    int gCnt = 0
    string gTxt = ""
    string gSrc = ""
    int gDist = 0
    for k = 0 to n - 1
        v = lv.get(idx.get(k))
        s = nm.get(idx.get(k))
        g = sg.get(idx.get(k))
        if gCnt > 0 and v - gLo <= tol * ref
            gHi := v
            gCnt += 1
            gTxt += " · " + s
            if not str.contains(gSrc, g)
                gSrc += g
                gDist += 1
        else
            if gDist >= minScore
                zLo.push(gLo)
                zHi.push(gHi)
                zN.push(gDist)
                zTxt.push(gTxt)
            gLo := v
            gHi := v
            gCnt := 1
            gTxt := s
            gSrc := g
            gDist := 1
    if gDist >= minScore
        zLo.push(gLo)
        zHi.push(gHi)
        zN.push(gDist)
        zTxt.push(gTxt)

// pad very thin zones so they stay visible
pad = 0.03 * ref

// ===== Touch detection =====
touchRes = false
touchSup = false
nz_ = zN.size()
if nz_ > 0
    for j = 0 to nz_ - 1
        lo = zLo.get(j) - pad
        hi = zHi.get(j) + pad
        if high >= lo and low <= hi
            if close[1] < lo
                touchRes := true
            else if close[1] > hi
                touchSup := true

// ===== Drawing (last bar) =====
var array<box>   bxs = array.new_box()
var array<label> lbs = array.new_label()
var array<line>  lns = array.new_line()
var int dStart = 0
if timeframe.change("D")
    dStart := bar_index
var table tb = table.new(position.top_right, 4, 3, bgcolor=color.new(chart.bg_color, 0), frame_color=color.new(chart.fg_color, 85), frame_width=1, border_color=color.new(chart.fg_color, 92), border_width=1)

if barstate.islast
    for b in bxs
        b.delete()
    for l in lbs
        l.delete()
    for l in lns
        l.delete()
    bxs.clear()
    lbs.clear()
    lns.clear()
    x0 = timeframe.isintraday ? math.min(dStart, bar_index - 20) : bar_index - 20
    x1 = bar_index + 3
    float aboveLo = na
    float aboveHi = na
    int aboveN = 0
    float belowLo = na
    float belowHi = na
    int belowN = 0
    if nz_ > 0
        for j = 0 to nz_ - 1
            lo = zLo.get(j) - pad
            hi = zHi.get(j) + pad
            mid = (lo + hi) / 2
            c = mid > close ? colRes : colSup
            if math.abs(mid - close) <= maxDist * ref
                // stronger zones (more sources) are drawn more opaque
                // gradient zone: stacked layers from a light edge to a deep core,
                // stronger zones (more sources) are more opaque
                cEdge = mid > close ? colResL : colSupL
                half = (hi - lo) / 2
                alpha = math.min(0.22, 0.10 + 0.04 * (zN.get(j) - 2))
                for L = 0 to layers - 1
                    hL = half * (1 - float(L) / layers)
                    cL = layers > 1 ? color.from_gradient(L, 0, layers - 1, cEdge, c) : c
                    bxs.push(box.new(x0, mid + hL, x1, mid - hL, border_color=color.new(c, 100), bgcolor=color.new(cL, 100 - alpha * 100), extend=extend.right))
                lns.push(line.new(x0, mid, x1, mid, color=color.new(c, 25), width=1, extend=extend.right))
                dots = ""
                for q = 1 to zN.get(j)
                    dots += "●"
                lbs.push(label.new(x0, mid, dots + "  " + zTxt.get(j), style=label.style_label_left, color=color.new(c, 0), textcolor=color.white, size=size.small))
            if lo > close and (na(aboveLo) or lo < aboveLo)
                aboveLo := lo
                aboveHi := hi
                aboveN := zN.get(j)
            if hi < close and (na(belowHi) or hi > belowHi)
                belowLo := lo
                belowHi := hi
                belowN := zN.get(j)
    // single levels that are not part of a zone
    if showLines and n > 0
        for k = 0 to n - 1
            v = lv.get(k)
            inZone = false
            if nz_ > 0
                for j = 0 to nz_ - 1
                    if v >= zLo.get(j) - pad and v <= zHi.get(j) + pad
                        inZone := true
            if not inZone and math.abs(v - close) <= maxDist * ref
                lns.push(line.new(x0, v, x1, v, color=color.new(chart.fg_color, 65), width=1, style=line.style_dotted, extend=extend.right))
                lbs.push(label.new(x0, v, nm.get(k), style=label.style_label_lower_left, color=color.new(color.white, 100), textcolor=color.new(chart.fg_color, 45), size=size.small))
    if showTbl
        hdr = color.new(chart.fg_color, 45)
        table.cell(tb, 0, 0, "Nearest zone", text_color=hdr, text_size=size.tiny, text_halign=text.align_left)
        table.cell(tb, 1, 0, "Range", text_color=hdr, text_size=size.tiny)
        table.cell(tb, 2, 0, "Sources", text_color=hdr, text_size=size.tiny)
        table.cell(tb, 3, 0, "Distance", text_color=hdr, text_size=size.tiny)
        table.cell(tb, 0, 1, "Above", text_color=colRes, text_size=size.small, text_halign=text.align_left)
        table.cell(tb, 1, 1, na(aboveLo) ? "none in range" : str.tostring(aboveLo, format.mintick) + " - " + str.tostring(aboveHi, format.mintick), text_color=na(aboveLo) ? color.new(chart.fg_color, 50) : chart.fg_color, text_size=size.small)
        table.cell(tb, 2, 1, na(aboveLo) ? "" : str.tostring(aboveN), text_color=chart.fg_color, text_size=size.small)
        table.cell(tb, 3, 1, na(aboveLo) ? "" : str.tostring((aboveLo - close) / ref, "0.00") + " " + refName, text_color=chart.fg_color, text_size=size.small)
        table.cell(tb, 0, 2, "Below", text_color=colSup, text_size=size.small, text_halign=text.align_left)
        table.cell(tb, 1, 2, na(belowHi) ? "none in range" : str.tostring(belowLo, format.mintick) + " - " + str.tostring(belowHi, format.mintick), text_color=na(belowHi) ? color.new(chart.fg_color, 50) : chart.fg_color, text_size=size.small)
        table.cell(tb, 2, 2, na(belowHi) ? "" : str.tostring(belowN), text_color=chart.fg_color, text_size=size.small)
        table.cell(tb, 3, 2, na(belowHi) ? "" : str.tostring((close - belowHi) / ref, "0.00") + " " + refName, text_color=chart.fg_color, text_size=size.small)

// ===== Alerts =====
alertcondition(touchRes, "Zone above touched", "Level Confluence {{ticker}} {{interval}}: price reached a confluence zone from below ({{close}})")
alertcondition(touchSup, "Zone below touched", "Level Confluence {{ticker}} {{interval}}: price reached a confluence zone from above ({{close}})")
alertcondition(touchRes or touchSup, "Any zone touched", "Level Confluence {{ticker}} {{interval}}: price reached a confluence zone ({{close}})")
````
