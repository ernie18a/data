# CTZ Cycle support and resistance 

- url: https://www.tradingview.com/script/q345A9VX-CTZ-Cycle-support-and-resistance/
- type: indicator
- pine_id: PUB;1395b8394c2845938d72f2957f59d9cf
- version: 1.0

## Description

**CTZ A/D + Anchored Volume Profile S/R**

A confluence-based support and resistance tool that fuses two independent reads of market structure: an auto-anchored volume profile that maps where the market has accepted price, and an Accumulation/Distribution engine that reveals where smart money has been quietly positioning against price.

**How it works**

*Anchored Volume Profile.* The indicator automatically finds the defining swing of the current market structure and anchors a volume profile to it — the range high in a downtrend, the range low in an uptrend, the same way a professional would anchor manually. From that anchored segment it calculates the Point of Control (the single price level with the most traded volume), plus the Value Area High and Value Area Low containing the majority of the range's volume. These three levels are the market's memory: where business was done, and where it wasn't.

*A/D Divergence Engine.* In parallel, a cumulative Accumulation/Distribution line runs bar by bar, weighting volume by where price closes within each bar's range. At every confirmed price pivot the indicator compares price structure against A/D structure. When price makes a lower low but A/D makes a higher low, buyers are absorbing supply into weakness — an accumulation zone is drawn. When price makes a higher high but A/D makes a lower high, distribution is underway into strength — a distribution zone is drawn.

*Confluence.* When an A/D divergence pivot lands on the POC, VAH, or VAL, that level is tagged ⚡DIV — volume acceptance and smart money divergence at the same price. These are the highest-conviction levels the indicator produces.

**Cycle-based lookback**

The anchor window is defined in cycle degrees rather than arbitrary bar counts: Daily Cycle (60D), Intermediate Cycle (140D), Yearly Cycle (365D), and 4-Year Cycle (1461D), plus a Manual mode. The default is the 4-Year Cycle — on Bitcoin this anchors the profile to the true cycle extreme and maps the macro acceptance structure of the entire cycle. An Auto mode is also included, which starts at the Intermediate degree and automatically escalates to Yearly and then 4-Year whenever the swing that defines the range is older than the window — so the anchor always sits on a genuine structural extreme, never an arbitrary cutoff.

Run two instances at different degrees — 4-Year for the macro map, Intermediate or Daily for tactical levels — to nest cycle context the same way DCL, ICL, YCL, and 4YCL nest within each other.

**On the chart**

Red POC line, white VAH/VAL lines, all drawn from the anchor point (marked ⚓) and extended right. Teal ACCUM and red DIST zones extend from each divergence pivot, sized by ATR. A status panel shows the detected trend, the active cycle window, anchor age, POC price, and divergence count — with a clip warning if the structural swing is older than the selected window. Alerts fire when price approaches the POC, VAH, or VAL.

**How to use it**

Trend context first: the anchor tells you the structure (anchored to a high = declining structure; to a low = advancing structure). POC is the gravitational center — price far above it is extended, far below it is discounted, and revisits are common. VAH and VAL are the acceptance boundaries: rejection there keeps price in balance; acceptance beyond them signals initiative activity and range extension. ACCUM zones below price are demand candidates; DIST zones above price are supply candidates; ⚡DIV-tagged levels are where both systems agree.

**Settings**

Lookback mode (cycle degree), profile rows, value area percentage, A/D signal length, pivot sensitivity, zone height, and all colors are configurable.

**Limitations**

Levels recalculate when a new range extreme redefines the anchor — correct behaviour for anchored profiles, but it means levels are not static. Divergence pivots confirm a few bars after they form, as with all pivot-based detection. Profile quality depends on the volume feed of the chart's symbol. The A/D line does not account for gaps between bars. Best used as a structural map alongside your execution tools, not as a standalone entry signal.

## Source Code

````pine
//@version=6
indicator("CTZ Cycle support and resistance ", shorttitle="CTZ Cycle support and resistance ", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=100, max_bars_back=5000)

// ═══════════════════════════ INPUTS ═══════════════════════════
grpV = "Anchored Volume Profile"
lbMode   = input.string("Auto (Cycle)", "Lookback Mode", options=["Auto (Cycle)", "Daily Cycle (60D)", "Intermediate (140D)", "Yearly (365D)", "4-Year (1461D)", "Manual"], group=grpV, tooltip="Auto: starts at the Intermediate cycle window, escalates to Yearly then 4-Year if the anchor clips the window edge — so the anchor is always a real structural swing")
manLB    = input.int(200, "Manual Lookback (bars)", minval=50, maxval=4900, group=grpV)
vpBins   = input.int(100, "Profile Rows", minval=20, maxval=200, group=grpV)
vaPct    = input.float(70, "Value Area %", minval=50, maxval=95, group=grpV)

grpA = "A/D Engine"
sigLen   = input.int(21, "A/D Signal EMA", minval=1, group=grpA)
pivotLen = input.int(10, "Pivot Lookback", minval=2, group=grpA)

grpS = "Levels"
showDebug = input.bool(true, "Show Status Table", group=grpS)
showZones = input.bool(true, "Show Accum/Dist Zones", group=grpS)
zoneMult  = input.float(0.75, "Zone Height (ATR)", minval=0.25, maxval=3, step=0.25, group=grpS)
extendOpt = input.string("Right", "Extend Lines", options=["Right", "Both"], group=grpS)

grpC = "Colors"
pocCol = input.color(color.red,   "POC",            group=grpC)
vaCol  = input.color(color.white, "VAH / VAL",      group=grpC)
divCol = input.color(color.aqua,  "A/D Divergence", group=grpC)

// ═══════ CYCLE WINDOWS (day counts → bars, works on any timeframe) ═══════
barsPerDay = math.max(1, math.round(86400.0 / timeframe.in_seconds(timeframe.period)))
dcW = math.min(60   * barsPerDay, 4900)   // Daily cycle degree
icW = math.min(140  * barsPerDay, 4900)   // Intermediate (~20 weeks)
ycW = math.min(365  * barsPerDay, 4900)   // Yearly cycle degree
c4W = math.min(1461 * barsPerDay, 4900)   // 4-Year cycle degree

// ═══════ GLOBAL SERIES — every bar ═══════
mfm = high == low ? 0.0 : ((close - low) - (high - close)) / (high - low)
var float ad = 0.0
ad += mfm * volume
adSig = ta.ema(ad, sigLen)
atr14 = ta.atr(14)

// Range extremes for every cycle window (must all run every bar)
hhDC = -ta.highestbars(high, dcW)
llDC = -ta.lowestbars(low, dcW)
hhIC = -ta.highestbars(high, icW)
llIC = -ta.lowestbars(low, icW)
hhYC = -ta.highestbars(high, ycW)
llYC = -ta.lowestbars(low, ycW)
hh4Y = -ta.highestbars(high, c4W)
ll4Y = -ta.lowestbars(low, c4W)
hhMN = -ta.highestbars(high, manLB)
llMN = -ta.lowestbars(low, manLB)

// A window is "clipped" when the anchor sits at its edge → the real swing is older
edgeBuf(w) =>
    math.max(5, w / 50)
clipped(hOff, lOff, w) =>
    a = math.max(hOff, lOff)
    na(hOff) or na(lOff) or a >= w - edgeBuf(w)

// Auto ladder: Intermediate → Yearly → 4-Year
var int   useW  = 0
var float hhOff = na
var float llOff = na
if lbMode == "Daily Cycle (60D)"
    useW := dcW
    hhOff := hhDC
    llOff := llDC
else if lbMode == "Intermediate (140D)"
    useW := icW
    hhOff := hhIC
    llOff := llIC
else if lbMode == "Yearly (365D)"
    useW := ycW
    hhOff := hhYC
    llOff := llYC
else if lbMode == "4-Year (1461D)"
    useW := c4W
    hhOff := hh4Y
    llOff := ll4Y
else if lbMode == "Manual"
    useW := manLB
    hhOff := hhMN
    llOff := llMN
else  // Auto (Cycle)
    if not clipped(hhIC, llIC, icW)
        useW := icW
        hhOff := hhIC
        llOff := llIC
    else if not clipped(hhYC, llYC, ycW)
        useW := ycW
        hhOff := hhYC
        llOff := llYC
    else
        useW := c4W
        hhOff := hh4Y
        llOff := ll4Y

autoLabel = useW == icW ? "IC (140D)" : useW == ycW ? "YC (365D)" : useW == c4W ? "4YC (1461D)" : useW == dcW ? "DC (60D)" : "Manual"

// Downtrend: high is OLDER than low → anchor at the high. Uptrend: reverse.
isDown    = hhOff > llOff
anchorOff = int(math.max(nz(hhOff), nz(llOff)))
isClipped = clipped(hhOff, llOff, useW)

pl = ta.pivotlow(low, pivotLen, pivotLen)
ph = ta.pivothigh(high, pivotLen, pivotLen)

// keep history buffers deep
dummyH = high[4899]
dummyL = low[4899]
dummyV = volume[4899]

// ═══════════════════════════ A/D DIVERGENCE PIVOTS ═══════════════════════════
var array<float> dvPrice = array.new_float()
var array<int>   dvBar   = array.new_int()
var array<int>   dvBull  = array.new_int()   // 1 = bullish (accumulation), 0 = bearish (distribution)

var float lastPL   = na
var float lastPLad = na
var float lastPH   = na
var float lastPHad = na

capDiv() =>
    if array.size(dvPrice) > 40
        array.shift(dvPrice)
        array.shift(dvBar)
        array.shift(dvBull)

if not na(pl)
    adAtP = ad[pivotLen]
    if not na(lastPL) and pl < lastPL and adAtP > lastPLad
        array.push(dvPrice, pl)
        array.push(dvBar, bar_index - pivotLen)
        array.push(dvBull, 1)
        capDiv()
    lastPL   := pl
    lastPLad := adAtP

if not na(ph)
    adAtP = ad[pivotLen]
    if not na(lastPH) and ph > lastPH and adAtP < lastPHad
        array.push(dvPrice, ph)
        array.push(dvBar, bar_index - pivotLen)
        array.push(dvBull, 0)
        capDiv()
    lastPH   := ph
    lastPHad := adAtP

// ═══════════════════════════ ANCHORED PROFILE + RENDER ═══════════════════════════
var array<line>  drawL = array.new_line()
var array<label> drawT = array.new_label()
var array<box>   drawB = array.new_box()

var float pocP = na
var float vahP = na
var float valP = na

if barstate.islast
    while array.size(drawL) > 0
        line.delete(array.pop(drawL))
    while array.size(drawT) > 0
        label.delete(array.pop(drawT))
    while array.size(drawB) > 0
        box.delete(array.pop(drawB))

    lb = math.min(anchorOff, bar_index)
    lb := math.max(lb, 1)

    // range of the anchored segment only
    segHi = high
    segLo = low
    for i = 0 to lb
        segHi := math.max(segHi, high[i])
        segLo := math.min(segLo, low[i])
    rng = segHi - segLo

    if rng > 0
        binSize = rng / vpBins
        binVol  = array.new_float(vpBins, 0.0)

        for i = 0 to lb
            bh = high[i]
            bl = low[i]
            bv = nz(volume[i])
            span = bh - bl
            b0 = math.max(0, math.min(vpBins - 1, int((bl - segLo) / binSize)))
            b1 = math.max(0, math.min(vpBins - 1, int((bh - segLo) / binSize)))
            if b0 == b1 or span == 0
                array.set(binVol, b0, array.get(binVol, b0) + bv)
            else
                for b = b0 to b1
                    binLo = segLo + b * binSize
                    binHi = binLo + binSize
                    overlap = math.max(0.0, math.min(bh, binHi) - math.max(bl, binLo))
                    array.set(binVol, b, array.get(binVol, b) + bv * overlap / span)

        // POC
        totalV = array.sum(binVol)
        pocBin = 0
        pocV   = 0.0
        for b = 0 to vpBins - 1
            if array.get(binVol, b) > pocV
                pocV   := array.get(binVol, b)
                pocBin := b

        // Value Area: expand from POC until vaPct of total volume covered
        vaTarget = totalV * vaPct / 100
        upB = pocBin
        dnB = pocBin
        cum = pocV
        while cum < vaTarget and (upB < vpBins - 1 or dnB > 0)
            vUp = upB < vpBins - 1 ? array.get(binVol, upB + 1) : -1.0
            vDn = dnB > 0 ? array.get(binVol, dnB - 1) : -1.0
            if vUp >= vDn
                upB += 1
                cum += vUp
            else
                dnB -= 1
                cum += vDn

        pocP := segLo + (pocBin + 0.5) * binSize
        vahP := segLo + (upB + 1.0) * binSize
        valP := segLo + (dnB) * binSize

        anchorBar = bar_index - lb
        ext = extendOpt == "Both" ? extend.both : extend.right

        // ── Draw POC / VAH / VAL from the anchor ──
        array.push(drawL, line.new(anchorBar, pocP, bar_index, pocP, color=pocCol, width=2, extend=ext))
        array.push(drawL, line.new(anchorBar, vahP, bar_index, vahP, color=vaCol, width=1, extend=ext))
        array.push(drawL, line.new(anchorBar, valP, bar_index, valP, color=vaCol, width=1, extend=ext))

        // ── Confluence: A/D divergence pivots near a level boost it ──
        tol = atr14 * 0.5
        pocDiv = false
        vahDiv = false
        valDiv = false
        if array.size(dvPrice) > 0
            for i = 0 to array.size(dvPrice) - 1
                if array.get(dvBar, i) < anchorBar
                    continue
                p = array.get(dvPrice, i)
                isBull = array.get(dvBull, i) == 1
                if math.abs(p - pocP) <= tol
                    pocDiv := true
                if math.abs(p - vahP) <= tol
                    vahDiv := true
                if math.abs(p - valP) <= tol
                    valDiv := true
                // accumulation / distribution zone box at the divergence pivot
                if showZones
                    zTop = isBull ? p + atr14 * zoneMult : p
                    zBot = isBull ? p : p - atr14 * zoneMult
                    zCol = isBull ? color.teal : color.red
                    array.push(drawB, box.new(array.get(dvBar, i), zTop, bar_index, zBot, bgcolor=color.new(zCol, 85), border_color=color.new(zCol, 40), border_width=1, text=isBull ? "ACCUM" : "DIST", text_color=zCol, text_size=size.small, text_halign=text.align_right, text_valign=text.align_center))
                array.push(drawT, label.new(array.get(dvBar, i), p, "⚡", style=isBull ? label.style_label_up : label.style_label_down, color=color.new(divCol, 70), textcolor=divCol, size=size.tiny))

        // ── Level labels ──
        array.push(drawT, label.new(bar_index, pocP, "POC " + str.tostring(pocP, format.mintick) + (pocDiv ? " ⚡DIV" : ""), style=label.style_label_left, color=color.new(pocCol, 80), textcolor=pocCol, size=size.small))
        array.push(drawT, label.new(bar_index, vahP, "VAH " + str.tostring(vahP, format.mintick) + (vahDiv ? " ⚡DIV" : ""), style=label.style_label_left, color=color.new(vaCol, 85), textcolor=vaCol, size=size.small))
        array.push(drawT, label.new(bar_index, valP, "VAL " + str.tostring(valP, format.mintick) + (valDiv ? " ⚡DIV" : ""), style=label.style_label_left, color=color.new(vaCol, 85), textcolor=vaCol, size=size.small))

        // anchor marker
        array.push(drawT, label.new(anchorBar, isDown ? segHi : segLo, isDown ? "⚓ Range High" : "⚓ Range Low", style=isDown ? label.style_label_down : label.style_label_up, color=color.new(color.orange, 70), textcolor=color.orange, size=size.small))

// ═══════════════════════════ STATUS TABLE ═══════════════════════════
var table dbg = table.new(position.top_right, 2, 6, bgcolor=color.new(color.black, 80), border_width=1)
if barstate.islast and showDebug
    table.cell(dbg, 0, 0, "Trend",      text_color=color.white, text_size=size.small)
    table.cell(dbg, 1, 0, isDown ? "Down (anchor: High)" : "Up (anchor: Low)", text_color=isDown ? color.red : color.teal, text_size=size.small)
    table.cell(dbg, 0, 1, "Cycle window", text_color=color.white, text_size=size.small)
    table.cell(dbg, 1, 1, autoLabel + " = " + str.tostring(useW) + " bars", text_color=color.orange, text_size=size.small)
    table.cell(dbg, 0, 2, "Anchor age", text_color=color.white, text_size=size.small)
    table.cell(dbg, 1, 2, str.tostring(anchorOff) + " bars" + (isClipped ? " ⚠ CLIPPED" : ""), text_color=isClipped ? color.orange : color.white, text_size=size.small)
    table.cell(dbg, 0, 3, "POC",        text_color=color.white, text_size=size.small)
    table.cell(dbg, 1, 3, str.tostring(pocP, format.mintick), text_color=color.aqua, text_size=size.small)
    table.cell(dbg, 0, 4, "Div pivots", text_color=color.white, text_size=size.small)
    table.cell(dbg, 1, 4, str.tostring(array.size(dvPrice)), text_color=color.white, text_size=size.small)
    if isClipped
        table.cell(dbg, 0, 5, "⚠ Anchor at window edge", text_color=color.orange, text_size=size.small)
        table.cell(dbg, 1, 5, "true swing is older", text_color=color.orange, text_size=size.small)

// ═══════════════════════════ ALERTS ═══════════════════════════
nearPOC = not na(pocP) and math.abs(close - pocP) <= atr14 * 0.25
nearVAH = not na(vahP) and math.abs(close - vahP) <= atr14 * 0.25
nearVAL = not na(valP) and math.abs(close - valP) <= atr14 * 0.25
alertcondition(nearPOC, "Price Near POC", "Price within 0.25 ATR of anchored POC")
alertcondition(nearVAH, "Price Near VAH", "Price within 0.25 ATR of anchored VAH")
alertcondition(nearVAL, "Price Near VAL", "Price within 0.25 ATR of anchored VAL")
````
