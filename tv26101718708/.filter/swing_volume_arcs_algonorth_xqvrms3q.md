# Swing Volume Arcs [AlgoNorth]

- url: https://www.tradingview.com/script/Xqvrms3q-Swing-Volume-Arcs-AlgoNorth/
- type: indicator
- pine_id: PUB;727bb9ffcf124ec8937624cf4a1f7b77
- version: 1.0

## Description

Swing Volume Arcs 

Every swing on your chart carries a volume story. This script draws it, one arc per swing, right on the price. The heavier the volume behind a move, the taller and thicker its arc. The swing in progress is traced live and sets solid the moment it completes, so the chart reads as a run of arcs that tell you, before you read a label, which legs the market leaned into and which it barely touched.

Volume usually lives in a pane at the bottom, one bar at a time. Here it lives on the price itself, one swing at a time. A dotted 1× arc sits beside each one, so heavier or lighter than typical is obvious at a glance. Glowing sails, percentiles, an effort vs result ◆ and a live stats table finish it off.

🔶 USAGE

🔸 Watch the forming arc. Drawn dashed, it runs from the last swing point to the current extreme, with a live dot at the extreme, a "forming" label carrying the running volume and size, and a dotted line at the price that would complete the swing. The table's "Wave confirms on" row prints that price.

🔸 When the swing completes, the arc turns solid. Green arcs bow above up swings; red arcs bow below down swings. In Volume mode the arc rises above its swing point in proportion to volume ÷ typical volume: a 2.0× swing rises exactly twice as far as a 1.0× swing, up to the cap.

🔸 Compare each arc with its dotted 1× reference arc, drawn where a typical-volume swing of that size would sit. Solid arc outside the dots = heavier than typical; inside = lighter.

🔸 Read the detail labels on the latest swings: volume, × typical, percentile, +vol / -vol against the previous swing in the same direction, size in ATR and bar count.

🔸 A ◆ marks a swing that took heavy volume for a small move: (volume ÷ typical volume) ÷ (size ÷ typical size) at or above the Effort vs result flag. The table's row 6 spells it out.

🔸 Sails fill the space between each arc and the straight line joining its swing points, fading in the direction you choose.

🔸 The live table (any corner) shows swings counted, typical swing volume, the last up and down swing, the up/down volume ratio over the last 5 of each, the last effort vs result value, the forming swing, the completion price, how arc height is being measured, and the bar count with the last-bar timestamp.

🔸 Alerts: up swing completed, down swing completed, effort vs result swing.

🔶 DETAILS

🔸 Swing definition. A swing runs from one extreme to the next. It ends when a bar closes the Reversal distance (in ATR) back from the extreme without making a new extreme. The extreme is then the swing point, the opposite extreme found back to that point starts the next swing, and the volume of every bar between the two extremes is the swing's volume.

🔸 Volume source. Swing volume is the sum of each bar's exchange volume. The script has no bid/ask or trade-side data; it does not know who was the aggressor, only how much traded.

🔸 Typical swing. The median volume of the previous N swings (default 20). Each swing's multiple is measured against the swings before it, so a swing is never compared with itself.

🔸 Percentiles. Volume and size percentiles are measured against the previous swings in the lookback (default 100) and fixed when the swing completes.

🔸 Arc geometry. The arc is a curve from swing point to swing point whose peak sits exactly the chosen height above the swing. In Volume mode that height is Rise per 1× volume × (volume ÷ typical), clamped between 0.2× and the cap. In Wave-height mode, and on symbols without volume data, it is a fraction of the price move with a minimum in ATR.

🔸 Thickness. Line width also scales with the volume multiple in every style, so heavy swings are both taller and thicker.

🔸 Age fade. Older arcs are drawn slightly dimmer as newer swings arrive. Only their opacity changes.

🔸 Statistics are kept over the most recent 400 swings; the drawn set is the latest N (default 12).

🔶 SETTINGS

🔸 Waves: Reversal (× ATR), ATR length, Typical wave = median of (waves), Percentile lookback, Effort vs result flag.

🔸 Arcs: Style (Balanced / Quant / Glow), Arc height from (Volume / Wave height), Rise per 1× volume, Rise cap, 1× reference arc, Rise (× wave height), Minimum rise, Brightness, Arcs shown, Sail bands, Maximum arc width (Glow), Up and Down colours, Glow, Sails, Sail fade, Sail strength, Swing dots, Wave volume at swings, Detail labels, Label text size, Effort vs result diamonds, Forming wave.

🔸 Table: Show table, Table corner. Hover the table header for a full dump of the live settings.

🔸 Styles: Balanced (medium lines, soft glow), Quant (thin lines, light sails, no glow), Glow (bright arcs for screenshots, wider font). Balanced and Quant print percentiles on chart labels; Glow does not.

🔶 NOTES

🔸 Each arc is set solid once a bar closes the Reversal distance back from the swing's extreme, so the completed arc lands a few bars after the turn. Until then you have the forming arc to watch.

🔸 The forming arc is the only thing that moves. Once an arc is drawn its position and numbers never change; older arcs only dim as newer swings arrive. Applies to standard candle and bar charts.

🔸 Volume is the exchange volume traded within each swing, so it shows how much traded rather than the bid/ask split. Symbols without volume data still get their arcs, sized from swing height, with a note in the table header.

🔸 Typical volume and percentiles are learned from the swings on your chart, so the more history you load, the steadier the reference.

🔸 Renko, Kagi and Point & Figure charts can rebuild past bars, which can move stored swing points. The table header flags these chart types for you.

🔶 SUMMARY

Volume, drawn where it happened. Each swing leaves an arc that shows how much the market put behind it, the swing in progress is traced live, and the arcs tell the story before you read a label.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © AlgoNorth
//@version=6
indicator("Swing Volume Arcs [AlgoNorth]", overlay = true, behind_chart = true, max_bars_back = 1500, max_polylines_count = 100, max_labels_count = 60, max_lines_count = 1)

// ---------- Inputs ----------
gW = "Waves"
revATR = input.float(2.0, "Reversal (× ATR)", minval = 0.5, maxval = 20.0, step = 0.25, group = gW, tooltip = "A wave ends when a bar CLOSES this many ATR back from the wave's extreme without making a new extreme. Its swing points and all of its numbers are fixed at that close and never change on standard candle and bar charts; older arcs only fade. Smaller = more, shorter waves.")
atrLen = input.int(14, "ATR length", minval = 1, maxval = 200, group = gW, tooltip = "ATR used for the reversal distance and for wave size.")
avgN   = input.int(20, "Typical wave = median of (waves)", minval = 3, maxval = 400, group = gW, tooltip = "Wave volume is compared with the MEDIAN volume of this many previous waves. 1.0× = a typical wave.")
pctN   = input.int(100, "Percentile lookback (waves)", minval = 10, maxval = 400, group = gW, tooltip = "Volume and size percentiles are measured against this many PREVIOUS waves. A confirmed wave's percentile is fixed when it confirms.")
erThr  = input.float(1.5, "Effort vs result flag", minval = 1.0, maxval = 10.0, step = 0.1, group = gW, tooltip = "Effort vs result = (wave volume / typical wave volume) / (wave size / typical wave size). At or above this value a wave took heavy volume for a small move and is marked with a diamond. Needs volume data.")
gA = "Arcs"
styleIn = input.string("Balanced", "Style", options = ["Balanced", "Quant", "Glow"], group = gA, tooltip = "Balanced: medium lines, soft glow. Quant: thin lines, light sails, no glow. Balanced and Quant use monospace labels with percentiles. Glow: bright glowing arcs for screenshots, with a wider font and no percentiles on chart labels.")
bowMode = input.string("Volume", "Arc height from", options = ["Volume", "Wave height"], group = gA, tooltip = "Volume: the arc rises above its swing in proportion to wave volume / typical wave volume, so heavier waves stand taller. Wave height: the rise scales with the price move instead. Symbols without volume data always use wave height.")
volK    = input.float(0.5, "Rise per 1× volume (× ATR)", minval = 0.1, maxval = 5.0, step = 0.1, group = gA, tooltip = "Volume mode only. How far the arc of a typical (1.0×) wave rises above its swing point, in ATR. This is the height actually drawn: a 2.0× wave rises exactly twice as far, up to the cap, whatever the wave's size. Waves under 0.2× are drawn at 0.2× so they stay visible.")
volCap  = input.float(2.5, "Rise cap (× typical)", minval = 1.0, maxval = 10.0, step = 0.5, group = gA, tooltip = "Waves above this multiple of typical volume are drawn at the cap height in Volume mode. In Balanced and Quant it also caps arc thickness, in both modes. Labels and table still show the true multiple.")
showRef = input.bool(true, "1× reference arc", group = gA, tooltip = "Dotted arc showing where a typical-volume wave would sit. Arc outside the dots = heavier than typical, inside = lighter. Volume mode only. Not drawn on symbols without volume data, on waves only a bar wide, or where typical volume can't yet be measured.")
bowF    = input.float(0.07, "Rise (× wave height)", minval = 0.0, maxval = 0.6, step = 0.01, group = gA, tooltip = "Wave-height mode, and Volume mode on symbols without volume data. How far the arc rises above its swing, as a fraction of the wave's height. This is the height actually drawn, unless the minimum rise below is larger.")
bowMin  = input.float(0.2, "Minimum rise (× ATR)", minval = 0.0, maxval = 5.0, step = 0.05, group = gA, tooltip = "Wave-height mode, and Volume mode on symbols without volume data. Smallest rise above the swing for short waves, in ATR.")
bright  = input.int(85, "Brightness", minval = 30, maxval = 100, group = gA, tooltip = "Overall intensity of arcs, sails, glow, the 1× reference arc and the live markers. Labels and the effort-vs-result diamond keep a readable minimum.")
keepN   = input.int(12, "Arcs shown", minval = 2, maxval = 16, group = gA, tooltip = "Number of completed waves drawn as arcs. Older arcs fade slightly. Statistics use every confirmed wave up to the most recent 400.")
bandsIn = input.int(16, "Sail bands", minval = 4, maxval = 24, group = gA, tooltip = "Gradient steps in the sails. More = smoother. Automatically reduced if the drawing budget would be exceeded; the table header tooltip shows the number actually drawn.")
maxW    = input.int(7, "Maximum arc width (Glow)", minval = 2, maxval = 10, group = gA, tooltip = "Glow style: width of the heaviest-volume arcs. Balanced uses 2 to 5, Quant 1 to 4.")
colUp   = input.color(#1ed9a6, "Up wave", group = gA, tooltip = "Colour of up waves (arc bows above). Defaults are tuned for dark charts; on a light background choose a deeper shade.")
colDn   = input.color(#ff5566, "Down wave", group = gA, tooltip = "Colour of down waves (arc bows below). Defaults are tuned for dark charts; on a light background choose a deeper shade.")
showGlow = input.bool(true, "Glow (Balanced and Glow styles)", group = gA, tooltip = "Soft glow layers and a highlight thread on each arc. Half strength in Balanced. Quant never glows.")
showSail = input.bool(true, "Sails", group = gA, tooltip = "Gradient fill between each arc and the straight line joining its two swing points.")
fadeDir  = input.string("Bright at arc", "Sail fade", options = ["Bright at arc", "Bright at chord"], group = gA, tooltip = "Bright at arc: strongest along the arc, fading to nothing at the straight chord. Bright at chord: the reverse.")
sailO   = input.int(45, "Sail strength", minval = 5, maxval = 90, group = gA, tooltip = "Peak opacity of the sail, in percent, before brightness scaling. Balanced draws sails at about 70% of this, Quant at about a third.")
showDots = input.bool(true, "Swing dots", group = gA, tooltip = "Dot on each confirmed swing point.")
showVolTxt = input.bool(false, "Wave volume at swings", group = gA, tooltip = "Prints each older wave's total volume at its swing point. Only applies to waves outside the Detail-labels set.")
apexN   = input.int(4, "Detail labels (latest waves)", minval = 0, maxval = 8, group = gA, tooltip = "The latest waves get a full label at the arc's peak (or above the dotted 1× arc when that is higher): volume, × typical, percentile, +vol / -vol against the previous wave in the same direction, size in ATR and bars. Never more than the number of arcs shown.")
lblPt   = input.int(15, "Label text size (pt)", minval = 8, maxval = 30, group = gA, tooltip = "Text size of the detail labels and the forming-wave label, in points.")
showER  = input.bool(true, "Effort vs result diamonds", group = gA, tooltip = "Diamond at the peak of waves at or above the effort vs result flag. Turning this off also removes the diamond text in labels and the table.")
showLive = input.bool(true, "Forming wave", group = gA, tooltip = "Dashed arc from the last swing to the current extreme, with a live dot and a dotted line at the price that would confirm the wave. These are the only drawings that move, and they update at each bar close. The table's live rows also update every tick. The forming volume counts from the last swing to the current extreme. Confirmed arcs never move on standard candle and bar charts; older ones only fade.")
gT = "Table"
showTbl = input.bool(true, "Show table", group = gT, tooltip = "Live statistics panel. Hover the header for the full settings.")
tblPos  = input.string("Top right", "Table corner", options = ["Top left", "Top right", "Bottom left", "Bottom right"], group = gT, tooltip = "Move the table so stacked instances do not overlap.")

// ---------- Setup ----------
isQ   = styleIn == "Quant"
isB   = styleIn == "Balanced"
isG   = styleIn == "Glow"
lblQ  = not isG
isVol = bowMode == "Volume"
fnt   = lblQ ? font.family_monospace : font.family_default
gk    = isB ? 0.5 : 1.0
sailK = isQ ? 0.36 : isB ? 0.68 : 1.0
synth = chart.is_heikinashi or chart.is_renko or chart.is_kagi or chart.is_pnf or chart.is_linebreak or chart.is_range
atr  = ta.atr(atrLen)
cumV = ta.cum(nz(volume))
hasVol = cumV > 0
var array<int>   lx1 = array.new<int>()
var array<float> ly1 = array.new<float>()
var array<int>   lx2 = array.new<int>()
var array<float> ly2 = array.new<float>()
var array<float> lv  = array.new<float>()
var array<float> la  = array.new<float>()
var array<float> lr  = array.new<float>()
var array<float> ls  = array.new<float>()
var array<float> le  = array.new<float>()
var array<bool>  lu  = array.new<bool>()
var array<float> lp  = array.new<float>()
var array<float> cyC = array.new<float>()

// ---------- Statistics ----------
f_medLast(array<float> arr, int k) =>
    n = array.size(arr)
    n == 0 ? na : array.median(array.slice(arr, math.max(0, n - k), n))
f_pctBelow(array<float> arr, float v) =>
    n = array.size(arr)
    int c = 0
    for x in arr
        if x < v
            c += 1
    n == 0 ? na : 100.0 * c / n
f_pctLast(array<float> arr, int k, float v) =>
    n = array.size(arr)
    n == 0 ? na : f_pctBelow(array.slice(arr, math.max(0, n - k), n), v)
f_push(int x1, float y1, int x2, float y2, float v, float a, bool up) =>
    sz   = math.abs(y2 - y1) / a
    medV = f_medLast(lv, avgN)
    medS = f_medLast(ls, avgN)
    float r = na(medV) or medV == 0 ? na : v / medV
    float er = na(r) or na(medS) or medS == 0 or sz == 0 ? na : r / (sz / medS)
    float pc = na(r) ? na : f_pctLast(lv, pctN, v)
    array.push(lx1, x1)
    array.push(ly1, y1)
    array.push(lx2, x2)
    array.push(ly2, y2)
    array.push(lv, v)
    array.push(la, a)
    array.push(lr, r)
    array.push(ls, sz)
    array.push(le, er)
    array.push(lu, up)
    array.push(lp, pc)
    while array.size(lx1) > 400
        array.shift(lx1)
        array.shift(ly1)
        array.shift(lx2)
        array.shift(ly2)
        array.shift(lv)
        array.shift(la)
        array.shift(lr)
        array.shift(ls)
        array.shift(le)
        array.shift(lu)
        array.shift(lp)

// ---------- Wave engine ----------
var int   dir    = 0
var int   pivB   = na
var float pivP   = na
var float pivCum = na
var int   extB   = na
var float extP   = na
var float extCum = na
var float extA   = na
var int   nUp = 0
var int   nDn = 0
var int   nConf = 0
bool newUp = false
bool newDn = false
bool newER = false
if barstate.isconfirmed and not na(atr) and atr > 0
    if dir == 0
        dir    := 1
        pivB   := bar_index
        pivP   := low
        pivCum := cumV
        extB   := bar_index
        extP   := high
        extCum := cumV
        extA   := atr
    else if dir == 1
        if high > extP
            extB   := bar_index
            extP   := high
            extCum := cumV
            extA   := atr
        else if close <= extP - revATR * atr
            if nConf > 0
                f_push(pivB, pivP, extB, extP, extCum - pivCum, extA, true)
                nUp += 1
                newUp := true
                lastE = array.last(le)
                newER := not na(lastE) and lastE >= erThr
            nConf += 1
            n = math.min(bar_index - extB, 1400)
            float lo  = low
            int   loB = bar_index
            float loC = cumV
            float loA = atr
            if n > 1
                for i = 1 to n - 1
                    if low[i] < lo
                        lo  := low[i]
                        loB := bar_index - i
                        loC := cumV[i]
                        loA := atr[i]
            pivB   := extB
            pivP   := extP
            pivCum := extCum
            dir    := -1
            extB   := loB
            extP   := lo
            extCum := loC
            extA   := na(loA) or loA <= 0 ? atr : loA
    else
        if low < extP
            extB   := bar_index
            extP   := low
            extCum := cumV
            extA   := atr
        else if close >= extP + revATR * atr
            if nConf > 0
                f_push(pivB, pivP, extB, extP, extCum - pivCum, extA, false)
                nDn += 1
                newDn := true
                lastE = array.last(le)
                newER := not na(lastE) and lastE >= erThr
            nConf += 1
            n = math.min(bar_index - extB, 1400)
            float hi  = high
            int   hiB = bar_index
            float hiC = cumV
            float hiA = atr
            if n > 1
                for i = 1 to n - 1
                    if high[i] > hi
                        hi  := high[i]
                        hiB := bar_index - i
                        hiC := cumV[i]
                        hiA := atr[i]
            pivB   := extB
            pivP   := extP
            pivCum := extCum
            dir    := 1
            extB   := hiB
            extP   := hi
            extCum := hiC
            extA   := na(hiA) or hiA <= 0 ? atr : hiA

// ---------- Formatting ----------
f_vol(float v) =>
    av = math.abs(v)
    av >= 999.95e9 ? str.tostring(v / 1e12, "0.0") + "T" : av >= 999.95e6 ? str.tostring(v / 1e9, "0.0") + "B" : av >= 999.95e3 ? str.tostring(v / 1e6, "0.0") + "M" : av >= 999.95 ? str.tostring(v / 1e3, "0.0") + "K" : av >= 100 ? str.tostring(v, "0") : av >= 1 ? str.tostring(v, "0.0") : str.tostring(v, "0.000")
f_ord(float p) =>
    int k = int(math.round(p))
    r100 = k % 100
    r10 = k % 10
    sfx = r100 >= 11 and r100 <= 13 ? "th" : r10 == 1 ? "st" : r10 == 2 ? "nd" : r10 == 3 ? "rd" : "th"
    str.tostring(k) + sfx
f_bars(int b) => str.tostring(b) + (b == 1 ? " bar" : " bars")
f_tr(float opacity) => math.min(99, math.max(0, int(100 - 100 * opacity)))
f_af(int j, int last, int span) => 0.6 + 0.4 * math.pow(1.0 - (last - j) * 1.0 / span, 1.4)
f_pTxt(float p) => na(p) ? "" : "p" + str.tostring(p, "0")
f_lin(float x) => x <= 0.03928 ? x / 12.92 : math.pow((x + 0.055) / 1.055, 2.4)
f_rl(color c) => 0.2126 * f_lin(color.r(c) / 255.0) + 0.7152 * f_lin(color.g(c) / 255.0) + 0.0722 * f_lin(color.b(c) / 255.0)
f_con(color a, color b) =>
    la0 = f_rl(a)
    lb0 = f_rl(b)
    (math.max(la0, lb0) + 0.05) / (math.min(la0, lb0) + 0.05)
f_ink(color c) => f_con(#0a0a0c, c) >= f_con(#f0f1f5, c) ? #0a0a0c : #f0f1f5
f_flat(color c, color bg) =>
    a = 1.0 - color.t(c) / 100.0
    color.rgb(color.r(c) * a + color.r(bg) * (1 - a), color.g(c) * a + color.g(bg) * (1 - a), color.b(c) * a + color.b(bg) * (1 - a))
f_rowInk(color c) =>
    fb = color.new(chart.fg_color, 35)
    f_con(f_flat(c, chart.bg_color), chart.bg_color) >= 4.5 ? c : f_con(f_flat(fb, chart.bg_color), chart.bg_color) >= 4.5 ? fb : chart.fg_color

// ---------- Geometry ----------
f_arcY(int x, int x1, float y1, int x2, float y2, float cy) =>
    t = (x - x1) * 1.0 / math.max(x2 - x1, 1)
    (1 - t) * (1 - t) * y1 + 2 * t * (1 - t) * cy + t * t * y2
f_ext(int j, float bow) =>
    y1 = array.get(ly1, j)
    y2 = array.get(ly2, j)
    array.get(lu, j) ? math.max(y1, y2) + bow : math.min(y1, y2) - bow
// A quadratic curve never reaches its control point, so the control offset is solved
// backwards from the rise we actually want to see above the swing:
//   rise = ctrl^2 / (H + 2*ctrl)  =>  ctrl = rise + sqrt(rise^2 + rise*H)
f_ctrl(float rise, float H) => rise <= 0 ? 0.0 : rise + math.sqrt(rise * rise + rise * H)
f_rise(int j) =>
    a = array.get(la, j)
    H = math.abs(array.get(ly2, j) - array.get(ly1, j))
    r = array.get(lr, j)
    isVol and not na(r) ? volK * math.max(0.2, math.min(r, volCap)) * a : math.max(bowF * H, bowMin * a)
f_bow(int j) => f_ctrl(f_rise(j), math.abs(array.get(ly2, j) - array.get(ly1, j)))
f_refBow(int j) => f_ctrl(volK * array.get(la, j), math.abs(array.get(ly2, j) - array.get(ly1, j)))
f_refOk(int j) => array.get(lx2, j) - array.get(lx1, j) >= 2 and not na(array.get(lr, j))
f_cy(int j) => f_ext(j, f_bow(j))
f_arcPts(int x1, float y1, int x2, float y2, float cy) =>
    pts = array.new<chart.point>()
    len = x2 - x1
    if len <= 0
        array.push(pts, chart.point.from_index(x1, y1))
        array.push(pts, chart.point.from_index(x2, y2))
    else
        step = math.max(1, int(len / 48))
        int x = x1
        while x < x2
            array.push(pts, chart.point.from_index(x, f_arcY(x, x1, y1, x2, y2, cy)))
            x += step
        array.push(pts, chart.point.from_index(x2, y2))
    pts
f_curve(array<chart.point> pts, int x1, float y1, int x2, float y2, float cy, bool fwd) =>
    len  = x2 - x1
    step = math.max(1, int(len / 64))
    if fwd
        int x = x1 + step
        while x < x2
            array.push(pts, chart.point.from_index(x, f_arcY(x, x1, y1, x2, y2, cy)))
            x += step
        array.push(pts, chart.point.from_index(x2, y2))
    else
        int x = x2 - step
        while x > x1
            array.push(pts, chart.point.from_index(x, f_arcY(x, x1, y1, x2, y2, cy)))
            x -= step
        array.push(pts, chart.point.from_index(x1, y1))
f_chain(int first, int last, bool wantUp, float fA, float fB) =>
    pts = array.new<chart.point>()
    array.push(pts, chart.point.from_index(array.get(lx1, first), array.get(ly1, first)))
    for j = first to last
        x1 = array.get(lx1, j)
        y1 = array.get(ly1, j)
        x2 = array.get(lx2, j)
        y2 = array.get(ly2, j)
        if array.get(lu, j) == wantUp and x2 - x1 >= 2
            cy  = array.get(cyC, j - first)
            ch  = (y1 + y2) / 2.0
            f_curve(pts, x1, y1, x2, y2, ch + (cy - ch) * fA, true)
        else
            array.push(pts, chart.point.from_index(x2, y2))
    for j = last to first
        x1 = array.get(lx1, j)
        y1 = array.get(ly1, j)
        x2 = array.get(lx2, j)
        y2 = array.get(ly2, j)
        if array.get(lu, j) == wantUp and x2 - x1 >= 2
            cy  = array.get(cyC, j - first)
            ch  = (y1 + y2) / 2.0
            f_curve(pts, x1, y1, x2, y2, ch + (cy - ch) * fB, false)
        else
            array.push(pts, chart.point.from_index(x1, y1))
    pts
f_updn(int k) =>
    n = array.size(lv)
    float su = 0.0
    float sd = 0.0
    int cu = 0
    int cd = 0
    if n > 0
        for j = n - 1 to 0
            if array.get(lu, j) and cu < k
                su += array.get(lv, j)
                cu += 1
            else if not array.get(lu, j) and cd < k
                sd += array.get(lv, j)
                cd += 1
            if cu >= k and cd >= k
                break
    cu > 0 and cd > 0 and sd > 0 ? (su / cu) / (sd / cd) : na
f_lastIdx(bool wantUp) =>
    n = array.size(lu)
    int idx = -1
    if n > 0
        for j = n - 1 to 0
            if array.get(lu, j) == wantUp
                idx := j
                break
    idx
f_lvl() =>
    float lv0 = dir == 1 ? extP - revATR * atr : dir == -1 ? extP + revATR * atr : na
    na(lv0) ? na : dir == 1 ? math.floor(lv0 / syminfo.mintick) * syminfo.mintick : math.ceil(lv0 / syminfo.mintick) * syminfo.mintick

// ---------- Drawing ----------
// Confirmed layer (arcs, sails, dots, labels) is rebuilt only when a wave confirms, on a confirmed bar close.
// Live layer (forming arc, live dot, forming label) is the only thing redrawn on each tick.
var array<polyline> polys    = array.new<polyline>()
var array<label>    labs     = array.new<label>()
var array<polyline> livePoly = array.new<polyline>()
var array<label>    liveLabs = array.new<label>()
var line confLn = na
var int bandsUsed = 0
var int drawnN = -1
B  = bright / 100.0
glowOn = showGlow and not isQ
refOn  = isVol and showRef and hasVol
nW = array.size(lx1)
staticNow = (barstate.islastconfirmedhistory or (barstate.isrealtime and barstate.isconfirmed)) and nConf != drawnN
if barstate.islast or staticNow
    for p in livePoly
        polyline.delete(p)
    array.clear(livePoly)
    for l in liveLabs
        label.delete(l)
    array.clear(liveLabs)
if staticNow
    drawnN := nConf
    for p in polys
        polyline.delete(p)
    array.clear(polys)
    for l in labs
        label.delete(l)
    array.clear(labs)
    n = nW
    perArc = (glowOn ? 3 : 0) + 1 + (refOn ? 1 : 0)
    shown  = math.min(keepN, n)
    // 100 = Pine polyline hard max; 2 = live arc + one slot of headroom. Do not reduce.
    spare  = 100 - 2 - shown * perArc
    bands  = showSail ? math.min(bandsIn, int(spare / 2)) : 0
    bandsUsed := bands
    sep = lblQ ? "  " : " · "
    if n > 0
        first = n - shown
        last  = n - 1
        span  = math.max(1, last - first)
        array.clear(cyC)
        for j = first to last
            array.push(cyC, f_cy(j))
        if bands > 0
            peakO = sailO / 100.0 * B * sailK
            for k = 0 to bands - 1
                fA = 1.0 - k * 1.0 / bands
                fB = 1.0 - (k + 1) * 1.0 / bands
                pos = (k + 0.5) / bands
                ramp = fadeDir == "Bright at arc" ? math.pow(1.0 - pos, 1.6) : math.pow(pos, 1.6)
                opa = peakO * ramp
                ptsU = f_chain(first, last, true, fA, fB)
                ptsD = f_chain(first, last, false, fA, fB)
                array.push(polys, polyline.new(ptsU, curved = false, closed = true, xloc = xloc.bar_index, line_color = color.new(colUp, 100), fill_color = color.new(colUp, f_tr(opa)), line_width = 1))
                array.push(polys, polyline.new(ptsD, curved = false, closed = true, xloc = xloc.bar_index, line_color = color.new(colDn, 100), fill_color = color.new(colDn, f_tr(opa)), line_width = 1))
        if refOn
            for j = first to last
                x1 = array.get(lx1, j)
                x2 = array.get(lx2, j)
                if f_refOk(j)
                    afR = f_af(j, last, span)
                    refSeg = f_arcPts(x1, array.get(ly1, j), x2, array.get(ly2, j), f_ext(j, f_refBow(j)))
                    array.push(polys, polyline.new(refSeg, curved = true, closed = false, xloc = xloc.bar_index, line_color = color.new(chart.fg_color, f_tr(0.5 * B * afR)), line_style = line.style_dotted, line_width = 2))
        for j = first to last
            x1 = array.get(lx1, j)
            y1 = array.get(ly1, j)
            x2 = array.get(lx2, j)
            y2 = array.get(ly2, j)
            v  = array.get(lv, j)
            r  = array.get(lr, j)
            sz = array.get(ls, j)
            er = array.get(le, j)
            up = array.get(lu, j)
            pc = array.get(lp, j)
            rr = na(r) ? 1.0 : r
            erHit = showER and not na(er) and er >= erThr
            col = up ? colUp : colDn
            af  = f_af(j, last, span)
            vf  = math.min(math.max(rr / 2.0, 0.35), 1.0)
            cy  = array.get(cyC, j - first)
            pts = f_arcPts(x1, y1, x2, y2, cy)
            rc  = math.min(rr, volCap)
            w   = isQ ? math.min(4, math.max(1, math.round(1 + rc))) : isB ? math.min(5, math.max(2, math.round(1.5 + 1.5 * rc))) : math.min(maxW, math.max(2, math.round(2 + rr * 2)))
            coreO = B * af * (0.75 + 0.25 * vf)
            if glowOn
                glowA = color.new(col, f_tr(0.17 * gk * B * af * vf))
                glowB = color.new(col, f_tr(0.36 * gk * B * af * (0.6 + 0.4 * vf)))
                array.push(polys, polyline.new(pts, curved = true, closed = false, xloc = xloc.bar_index, line_color = glowA, line_width = w + 8))
                array.push(polys, polyline.new(pts, curved = true, closed = false, xloc = xloc.bar_index, line_color = glowB, line_width = w + 3))
            array.push(polys, polyline.new(pts, curved = true, closed = false, xloc = xloc.bar_index, line_color = color.new(col, f_tr(coreO)), line_width = w))
            if glowOn
                array.push(polys, polyline.new(pts, curved = true, closed = false, xloc = xloc.bar_index, line_color = color.new(chart.fg_color, f_tr(0.42 * B * af)), line_width = 1))
            int   px = x1
            float py = up ? -1e18 : 1e18
            for p in pts
                if up ? p.price > py : p.price < py
                    py := p.price
                    px := p.index
            dotT = f_tr(coreO)
            if showDots
                array.push(labs, label.new(x2, y2, "", xloc = xloc.bar_index, style = label.style_circle, color = color.new(col, dotT), size = size.tiny))
                if j == first
                    array.push(labs, label.new(x1, y1, "", xloc = xloc.bar_index, style = label.style_circle, color = color.new(up ? colDn : colUp, dotT), size = size.tiny))
            if erHit
                array.push(labs, label.new(px, py, "", xloc = xloc.bar_index, style = label.style_diamond, color = color.new(chart.fg_color, f_tr(0.9 * math.max(af, 0.8))), size = size.tiny))
            if apexN > 0 and j >= n - apexN
                int   tx = px
                float ty = py
                if refOn and f_refOk(j)
                    refArc = f_arcPts(x1, y1, x2, y2, f_ext(j, f_refBow(j)))
                    for p in refArc
                        if up ? p.price > ty : p.price < ty
                            ty := p.price
                            tx := p.index
                line2 = str.tostring(sz, "0.0") + " ATR" + sep + f_bars(x2 - x1)
                string txt = line2
                if not na(r)
                    prevSame = j >= 2 ? array.get(lv, j - 2) : na
                    arrow = na(prevSame) ? "" : v > prevSame ? " +vol" : v < prevSame ? " -vol" : ""
                    dia = erHit ? "◆ " : ""
                    line1 = dia + f_vol(v) + sep + str.tostring(r, "0.0") + "×" + (lblQ and not na(pc) ? sep + f_pTxt(pc) : "") + arrow
                    txt := line1 + "\n" + line2
                sty = up ? label.style_label_down : label.style_label_up
                array.push(labs, label.new(tx, ty, txt, xloc = xloc.bar_index, style = sty, color = color.new(col, 100), textcolor = color.new(chart.fg_color, f_tr(0.95 * af)), size = lblPt, text_font_family = fnt))
            else if showVolTxt and hasVol
                sty = up ? label.style_label_down : label.style_label_up
                array.push(labs, label.new(x2, y2, f_vol(v), xloc = xloc.bar_index, style = sty, color = color.new(col, 100), textcolor = color.new(col, f_tr(0.85 * af)), size = size.tiny, text_font_family = fnt))
if barstate.islast
    if showLive and dir != 0 and extB > pivB
        col  = dir == 1 ? colUp : colDn
        H    = math.abs(extP - pivP)
        liveV = extCum - pivCum
        medV  = f_medLast(lv, avgN)
        liveR = not hasVol or na(medV) or medV == 0 ? na : liveV / medV
        rise = isVol and hasVol ? volK * math.max(0.2, na(liveR) ? 1.0 : math.min(liveR, volCap)) * extA : math.max(bowF * H, bowMin * extA)
        bow  = f_ctrl(rise, H)
        cy   = dir == 1 ? math.max(pivP, extP) + bow : math.min(pivP, extP) - bow
        pts  = f_arcPts(pivB, pivP, extB, extP, cy)
        array.push(livePoly, polyline.new(pts, curved = true, closed = false, xloc = xloc.bar_index, line_color = color.new(col, f_tr(0.8 * B)), line_style = line.style_dashed, line_width = isQ ? 1 : 2))
        array.push(liveLabs, label.new(extB, extP, "", xloc = xloc.bar_index, style = label.style_circle, color = color.new(col, 65), size = size.small))
        array.push(liveLabs, label.new(extB, extP, "", xloc = xloc.bar_index, style = label.style_circle, color = color.new(chart.fg_color, f_tr(1.0 * B)), size = size.tiny))
        liveS = H / extA
        pctS  = f_pctLast(ls, pctN, liveS)
        pctV  = hasVol ? f_pctLast(lv, pctN, liveV) : na
        t1 = "forming"
        t2 = str.tostring(liveS, "0.0") + " ATR"
        if hasVol
            if lblQ
                t1 := "forming  " + f_vol(liveV) + (na(liveR) ? "" : "  " + str.tostring(liveR, "0.0") + "×") + (na(pctV) ? "" : "  " + f_pTxt(pctV))
            else
                t1 := "forming · " + f_vol(liveV) + (na(liveR) ? "" : " · " + str.tostring(liveR, "0.0") + "×")
        if not na(pctS) and lblQ
            t2 := t2 + "  size p" + str.tostring(pctS, "0")
        sty   = dir == 1 ? label.style_label_down : label.style_label_up
        lblY = extP + (dir == 1 ? 0.35 : -0.35) * extA
        array.push(liveLabs, label.new(extB, lblY, t1 + "\n" + t2, xloc = xloc.bar_index, style = sty, color = color.new(col, 100), textcolor = color.new(chart.fg_color, f_tr(0.95 * B)), size = lblPt, text_font_family = fnt))
        lvlR = f_lvl()
        if na(confLn)
            confLn := line.new(bar_index, lvlR, bar_index + 4, lvlR, xloc = xloc.bar_index, color = color.new(col, f_tr(0.6 * B)), width = 1, style = line.style_dotted)
        line.set_xy1(confLn, bar_index, lvlR)
        line.set_xy2(confLn, bar_index + 4, lvlR)
        line.set_color(confLn, color.new(col, f_tr(0.6 * B)))

// ---------- Table ----------
f_pos(string s) =>
    s == "Top left" ? position.top_left : s == "Top right" ? position.top_right : s == "Bottom left" ? position.bottom_left : position.bottom_right
var table tbl = table.new(f_pos(tblPos), 2, 11, bgcolor = color.new(chart.bg_color, 10), frame_color = color.new(chart.fg_color, 80), frame_width = 1, border_color = color.new(chart.fg_color, 80), border_width = 1)
f_row(int r, string a, string b, color ca) =>
    table.cell(tbl, 0, r, a, text_color = ca, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, r, b, text_color = chart.fg_color, text_size = size.small, text_halign = text.align_right, text_font_family = fnt)
f_waveTxt(int idx) =>
    string s = "-"
    if idx >= 0
        sep = lblQ ? "  " : " · "
        r = array.get(lr, idx)
        szTxt = str.tostring(array.get(ls, idx), "0.0") + " ATR" + sep + f_bars(array.get(lx2, idx) - array.get(lx1, idx))
        if not na(r)
            s := f_vol(array.get(lv, idx)) + sep + str.tostring(r, "0.0") + "×"
            pc = array.get(lp, idx)
            if not na(pc)
                s := s + sep + f_pTxt(pc)
            s := s + sep + szTxt
        else
            s := szTxt
    s
grey = color.new(chart.fg_color, 35)
if showTbl and barstate.islast
    hdr = "Swing Volume Arcs · " + styleIn + " · rev " + str.tostring(revATR, "0.0#")
    hdr := hdr + (isVol and hasVol ? " · rise " + str.tostring(volK, "0.0#") + "/" + str.tostring(volCap, "0.0#") : " · rise from height")
    if not hasVol
        hdr := hdr + " · no volume data"
    if synth
        hdr := hdr + " · synthetic chart prices"
    tip = "Swing Volume Arcs [AlgoNorth]"
    tip := tip + "\nStyle: " + styleIn + " · arc height from " + bowMode + (isVol and not hasVol ? " (no volume data: wave height used)" : "")
    tip := tip + "\nVolume mode: rise per 1× volume " + str.tostring(volK, "0.0#") + " ATR · cap " + str.tostring(volCap, "0.0#") + "× · 1× reference arc " + (refOn ? "on" : "off")
    tip := tip + "\nWave-height mode: rise " + str.tostring(bowF, "0.0##") + " × wave height · min " + str.tostring(bowMin, "0.0##") + " ATR"
    tip := tip + "\nReversal: " + str.tostring(revATR, "0.0#") + " ATR · ATR length " + str.tostring(atrLen)
    tip := tip + "\nTypical = median of " + str.tostring(avgN) + " waves · percentile lookback " + str.tostring(pctN)
    tip := tip + "\nEffort vs result flag: " + str.tostring(erThr, "0.0#")
    tip := tip + "\nArcs shown: " + str.tostring(keepN) + " · sail bands drawn " + str.tostring(bandsUsed) + (not showSail ? " (sails off)" : bandsUsed < bandsIn ? " (reduced from " + str.tostring(bandsIn) + ")" : "")
    tip := tip + "\nSail strength " + str.tostring(sailO) + " · sail fade " + fadeDir + " · brightness " + str.tostring(bright)
    tip := tip + "\nMax arc width (Glow) " + str.tostring(maxW) + " · detail labels " + str.tostring(apexN) + " · labels " + str.tostring(lblPt) + " pt"
    tip := tip + "\nColours: up " + (colUp == #1ed9a6 ? "default" : "custom") + " · down " + (colDn == #ff5566 ? "default" : "custom")
    tip := tip + "\nShown: " + (glowOn ? "glow " : "") + (showSail ? "sails " : "") + (showDots ? "dots " : "") + (showVolTxt ? "swing-volume " : "") + (showER ? "diamonds " : "") + (showLive ? "forming" : "")
    tip := tip + "\nTable: " + tblPos
    table.cell(tbl, 0, 0, hdr, text_color = f_ink(colUp), bgcolor = colUp, text_size = size.small, text_halign = text.align_left, tooltip = tip)
    table.merge_cells(tbl, 0, 0, 1, 0)
    n = array.size(lv)
    r1 = str.tostring(nUp + nDn) + " (" + str.tostring(nUp) + " · " + str.tostring(nDn) + ")"
    f_row(1, "Waves confirmed (up · down)", r1, grey)
    medV = f_medLast(lv, avgN)
    r2 = hasVol and not na(medV) ? f_vol(medV) : "-"
    f_row(2, "Typical wave volume (median of last " + str.tostring(avgN) + ", incl. latest)", r2, grey)
    f_row(3, "Last up wave", f_waveTxt(f_lastIdx(true)), f_rowInk(colUp))
    f_row(4, "Last down wave", f_waveTxt(f_lastIdx(false)), f_rowInk(colDn))
    ud = hasVol ? f_updn(5) : na
    r5 = na(ud) ? "-" : str.tostring(ud, "0.00") + "×"
    f_row(5, "Up-wave / down-wave volume (last 5 each)", r5, grey)
    lastER = n == 0 ? na : array.last(le)
    r6 = not hasVol or na(lastER) ? "-" : str.tostring(lastER, "0.00")
    if showER and hasVol and not na(lastER) and lastER >= erThr
        r6 := r6 + "  ◆ heavy volume, small move"
    f_row(6, "Last wave effort vs result", r6, grey)
    liveTxt = "-"
    if dir != 0
        H     = math.abs(extP - pivP)
        liveS = H / extA
        pctS  = f_pctLast(ls, pctN, liveS)
        liveR = not hasVol or na(medV) or medV == 0 ? na : (extCum - pivCum) / medV
        liveTxt := (dir == 1 ? "▲ " : "▼ ") + str.tostring(liveS, "0.0") + " ATR"
        if not na(pctS)
            liveTxt := liveTxt + " (" + f_ord(pctS) + " pct)"
        if not na(liveR)
            liveTxt := liveTxt + " · vol " + str.tostring(liveR, "0.0") + "×"
    f_row(7, "Forming wave", liveTxt, f_rowInk(dir == 1 ? colUp : colDn))
    lvlR = f_lvl()
    lvlTxt = "-"
    if dir == 1 and not na(lvlR)
        lvlTxt := "close ≤ " + str.tostring(lvlR, format.mintick) + " (no new high)"
    else if dir == -1 and not na(lvlR)
        lvlTxt := "close ≥ " + str.tostring(lvlR, format.mintick) + " (no new low)"
    f_row(8, "Wave confirms on", lvlTxt, grey)
    r9 = isVol ? (hasVol ? "wave vol / typical" + (showRef ? " · dotted = 1.0×" : "") : "wave height (no volume data)") : "wave height"
    f_row(9, "Arc height above swing", r9, grey)
    r10 = str.tostring(bar_index + 1) + " · " + str.format_time(time, timeframe.isseconds ? "dd MMM HH:mm:ss" : timeframe.isdwm ? "dd MMM yyyy" : "dd MMM HH:mm", syminfo.timezone)
    f_row(10, "Bars · last bar (exchange time)", r10, grey)

// ---------- Alerts ----------
alertcondition(newUp, "Up wave confirmed", "Swing Volume Arcs: up wave confirmed on {{ticker}} {{interval}}")
alertcondition(newDn, "Down wave confirmed", "Swing Volume Arcs: down wave confirmed on {{ticker}} {{interval}}")
alertcondition(newER, "Effort vs result wave", "Swing Volume Arcs: effort vs result wave (heavy volume, small move) on {{ticker}} {{interval}}")
````
