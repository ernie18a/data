# Anchor S&R Suite - Parallel

- url: https://www.tradingview.com/script/PKnyzG0h-Anchor-S-R-Suite-Parallel/
- type: indicator
- pine_id: PUB;977f9330885349d29bde857f0fd1f32e
- version: 1.0

## Description

[b]Anchor S&R Suite — Parallel
[/b]A data-driven, zero-repaint parallel support/resistance grid built from the market's own swing pivots.

Instead of eyeballing a range and dragging parallel lines by hand, this indicator finds the swing pivots automatically, groups the ones that cluster at similar prices into support/resistance levels, picks the single strongest Resistance/Support pair, and repeats that channel's height up and down as an evenly-spaced grid — recomputed on a higher-time-frame (HTF) rhythm and held flat in between.


[b]WHAT MAKES IT DIFFERENT
[/b]
• Data-driven, not arbitrary. The channel is built from REAL swing pivots that actually printed. A level's weight comes from how many pivots cluster on it and how long they span — not from a hand-placed box.

• Anchored to a time frame. You set the cadence (e.g. Weekly); the channel recomputes once per closed HTF candle and stays perfectly flat until the next close — clean horizontal steps, not sloping lines.

• Zero repaint. Pivots are confirmed and only closed HTF periods are used. A level you saw earlier sits in the exact same place now. Warm-up is not repaint: if a period has too few qualifying levels, the previous channel simply CARRIES FORWARD — no past value is ever rewritten.


[b]HOW IT WORKS
[/b]
1. Pivots — confirmed swing highs/lows on your CHART bars (strength = Pivot Period).
2. Window — at each cadence close, keep the pivots from the last `Lookback` closed HTF periods.
3. Clustering — sort pivots by price and merge those within Cluster Tolerance (% of price) into one level, carrying its touch COUNT and time SPAN.
4. Best channel — among levels with at least Min Touches, pick the Resistance/Support pair with the highest score (see below), subject to the width filters.
5. Grid — repeat that channel's height up and down: price = resistance − height × j. The base channel (Resistance & Support) is highlighted; the lines above/below are projected S/R.


[b]THE ALGORITHM 
[/b]
For every Resistance cluster R and Support cluster S with R.price > S.price and height H = R − S > 0:
   width%  = H / basis × 100        (basis = Support or Resistance — see Width Basis)
   reject if width% < Min%  or  width% > Max%        (0 disables that bound)
   score   = (R.count + S.count) × (R.span + S.span + 1)
→ keep the highest-scoring pair; if none qualifies, carry the previous channel forward.

Why that score: (count) rewards levels touched many times; (span) rewards levels respected over a long stretch. Multiplying them favours a channel whose BOTH edges are repeatedly AND durably defended.


[b]SETTINGS[/b]

• Cadence TF — when the channel recomputes and how macro it is. Higher = fewer, wider, slower channels; lower = tighter, more reactive. Must be greater than the chart TF.

• Lookback (1–20) — how many closed HTF periods of pivots feed the search. More = steadier, better-tested channel; less = tracks the latest swing but can be noisier or carry forward.

• Pivot Period — swing strength: a pivot needs this many bars on each side. Higher = bigger, fewer, more significant swings; lower = finer, busier levels. (A pivot is confirmed `period` bars after it forms — a delay, not repaint.)

• Price Source — High/Low (wicks, true extremes) or Open/Close (bodies only, cleaner on wick-heavy assets).

• Cluster Tolerance % — how close two pivots must be to count as the same level. Larger = fewer, fatter, better-touched levels; smaller = more, thinner levels (which may fall below Min Touches).

• Min Touches — minimum pivots in a cluster to qualify as a level. Higher = only well-tested levels (more robust, fewer candidates); lower = looser.

• Min / Max Channel Width % (+ Width Basis) — a FILTER on which R/S pairs are allowed, by channel height as a percentage. It does not resize a channel; it decides how tall the chosen one may be (and therefore the grid spacing).
   width% = height / basis × 100, with basis = Support (“Bottom to Top”) or Resistance (“Top to Bottom”).
   Example: R = 70 000, S = 63 000 → height 7 000 → 11.1% (Bottom to Top) or 10.0% (Top to Bottom).
   Raise Min → forces a taller channel / wider grid; lower Max → forces a shorter channel / tighter grid; 0 = bound off. If the band is too strict, no pair passes and the channel carries forward.

[image]https://www.tradingview.com/x/w7ddDoCi/[/image]
Lookback = 1 (reactive) vs Lookback = 3 (broader, steadier).

• Parallel Lines (per side) — how many grid repeats are drawn above/below the base channel (total = 2 × N + 1). Coverage only.

• Display — colour & width for the Grid and the Base channel, and optional channel-height % labels.

[image]https://www.tradingview.com/x/uMSt8HTJ/[/image]
The base channel (bold Resistance / Support) with the % labels on, and the lighter grid repeating around it.


[b]HOW TO TRADE THE GRID
[/b]
• Trade reactions, not the line itself — watch for a rejection, reclaim or stall at a line rather than assuming it stops there.
• The base channel is the anchor: inside it = range conditions (fade the edges); a clean break-and-hold often runs to the next grid line (one channel height away).
• Grid spacing = a measured-move unit — the next line up/down is a natural first target after a breakout.
• Confluence first — a line matters most where it lines up with prior structure, a round number, or (with the rest of the suite) a Volume/OI zone or a Fib level.


[b]EXAMPLE SETUPS
[/b]
• Swing (default): 1h–4h chart, Cadence = Weekly, Lookback = 3, Pivot Period = 5.
• Intraday: 5–15m chart, Cadence = Daily, Lookback = 2–3, Pivot Period = 3–5.
• Macro: Daily chart, Cadence = Monthly, Pivot Period = 8–15.
Nothing showing? Raise Cluster Tolerance, then lower Min Touches, then widen the Min/Max width band, then increase Lookback.

Works on any market and any timeframe.

[i]This indicator is a charting / analysis tool. It is not financial advice and does not generate buy or sell signals.[/i]

## Source Code

````pine
// ═══════════════════════════════════════════════════════════════════════════
// Anchor S&R Suite — Parallel
// ═══════════════════════════════════════════════════════════════════════════
//
// A data-driven horizontal channel grid built from clustered swing pivots.
//
// Concept: on each CADENCE (HTF) candle close, look back over the last
// `lookback` CLOSED HTF periods, detect swing pivots on the CHART bars in that
// window, cluster them into resistance/support levels, pick the best horizontal
// channel (height + ref price), then project an equally-spaced GRID of levels
// valid for the whole NEXT (forming) HTF period.
//
// ── ZERO REPAINT (mandatory) ────────────────────────────────────────────────
//   • Pivots are CONFIRMED only (ta.pivothigh/low confirm `period` bars later).
//   • The channel/grid is recomputed only at the HTF boundary and held fixed
//     for the whole next period. We never use the in-progress data.
//   • Cadence boundary = timeframe.change(cadenceTf) (atomic, single bar).
//
// ── Pipeline per HTF boundary ───────────────────────────────────────────────
//   1. Prune the pivot buffers to the last `lookback` closed HTF periods.
//   2. Cluster the pivots: sort by price, greedy-merge those within tolerance
//      (= Cluster Tolerance % of price) → clusters {price, count, span}.
//   3. Keep clusters with count >= Min Touches.
//   4. Best horizontal channel: the (Resistance, Support) cluster pair with
//      R.price > S.price maximising score = (R.count + S.count) ×
//      (R.span + S.span + 1), subject to the width filters.
//   5. channel = {ref price = R, height = R − S}; carry forward if none found.
//   6. Grid: price = ref − height·j for j in −n_lines..n_lines.
//
// ── Rendering (same engine as Fib Levels) ───────────────────────────────────
//   One plot per grid line, value held across the period (step line, full
//   history, no ~500 object cap). The VALUE is always present (level spans the
//   whole HTF period); segments are cut by COLOR = na on the single boundary
//   bar → hides the diagonal transition WITHOUT leaving a 1-bar hole.
//   A plot whose COLOUR is a series counts double in Pine's plot budget →
//   2·15 + 1 = 31 plots × 2 = 62 ≤ 64.
//
// ── TradingView limitation note ─────────────────────────────────────────────
//   Pivots are detected on CHART bars (no LTF request.security → no LTF history
//   limit). The only constraint is having enough chart bars inside the window
//   (low chart TF + high cadence = many bars); if short, the channel simply
//   carries forward.
// ═══════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Anchor S&R Suite — Parallel", shorttitle = "Anchor SR — Parallel",
     overlay = true, max_labels_count = 100)

// ── Constant ──
MAXLINES = 15   // hard cap per side (compile-time: 2·15+1 = 31 plots × 2 = 62 ≤ 64)

// ═══════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════

// ── "Cadence" group (shared across the whole suite) ──
gCad = "Cadence"
cadenceTf = input.timeframe("W", "Cadence TF", group = gCad,
     tooltip = "HTF that defines WHEN to recompute the channel. Must be > chart TF.")
lookback = input.int(3, "Lookback (HTF candles)", minval = 1, maxval = 20, group = gCad,
     tooltip = "Number of closed HTF periods whose chart pivots feed the channel search.")

// ── "Parallel S/R" group ──
gPar = "Parallel S/R"
pivotPeriod = input.int(5, "Pivot Period", minval = 2, maxval = 50, group = gPar,
     tooltip = "Swing pivot strength: a pivot needs `period` bars on each side. Detected on chart bars.")
priceSource = input.string("High/Low", "Price Source", options = ["High/Low", "Open/Close"], group = gPar,
     tooltip = "Which prices the swing pivots use: candle High/Low (wicks included) or Open/Close (bodies only).")
clusterPct = input.float(0.5, "Cluster Tolerance %", minval = 0.05, maxval = 5.0, step = 0.05, group = gPar,
     tooltip = "Max price distance (% of price) to merge pivots into one cluster.")
minTouches = input.int(2, "Min Touches", minval = 1, maxval = 20, group = gPar,
     tooltip = "Minimum pivots per cluster to qualify as a level.")
minChannelPct = input.float(0.0, "Min Channel Width %", minval = 0.0, maxval = 50.0, step = 0.1, group = gPar,
     tooltip = "Minimum channel height as % of price (0 = no limit).")
maxChannelPct = input.float(0.0, "Max Channel Width %", minval = 0.0, maxval = 100.0, step = 0.1, group = gPar,
     tooltip = "Maximum channel height as % of price (0 = no limit).")
widthBasis = input.string("Bottom to Top", "Min/Max Width Basis", options = ["Bottom to Top", "Top to Bottom"], group = gPar,
     tooltip = "Reference for the Min/Max Width % filter: % of support (Bottom to Top) or % of resistance (Top to Bottom).")
nLines = input.int(10, "Parallel Lines (per side)", minval = 1, maxval = MAXLINES, group = gPar,
     tooltip = "Grid lines drawn above and below: total = 2·N + 1.")

// ── "Display" group ──
gDsp = "Display"
gridCol   = input.color(color.new(#ff9800, 55), "Grid",         inline = "c", group = gDsp,
     tooltip = "Colour of the repeated grid lines above and below the base channel.")
baseCol   = input.color(color.new(#ff9800, 0),  "Base channel", inline = "c", group = gDsp,
     tooltip = "Colour of the base channel — its Resistance (j=0) and Support (j=1), the strongest detected pair.")
lineWidth = input.int(1, "Grid width",         minval = 1, maxval = 4, group = gDsp,
     tooltip = "Line thickness of the grid lines.")
baseWidth = input.int(2, "Base channel width", minval = 1, maxval = 4, group = gDsp,
     tooltip = "Line thickness of the base channel (Resistance / Support).")
showInfo  = input.bool(false, "Channel % labels", group = gDsp,
     tooltip = "Show 'Top: x% from bottom' and 'Bottom: x% from top' on the base channel (current period).")

// ═══════════════════════════════════════════════════════════════════════════
// STATE
// ═══════════════════════════════════════════════════════════════════════════
var array<float> phPrice = array.new_float()   // confirmed pivot-high prices (chronological)
var array<int>   phBar   = array.new_int()     // their pivot bar_index
var array<float> plPrice = array.new_float()   // confirmed pivot-low prices
var array<int>   plBar   = array.new_int()
var array<int>   periodStarts = array.new_int()  // bar_index at each HTF period start

var float gridRef    = na   // ref price (resistance) of the active channel
var float gridHeight = na   // channel height (grid spacing)

MAXPIV = 400   // safety cap on buffered pivots (protects per-bar runtime)

// ═══════════════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════════════

// Cluster pivots: sort by price, then greedy-merge those within `tol`.
// Returns parallel arrays [clusterPrice, clusterCount, clusterSpan].
clusterLevels(array<float> prices, array<int> bars, float tol) =>
    int n = array.size(prices)
    cP = array.new_float()
    cC = array.new_int()
    cS = array.new_int()
    if n > 0
        sp = array.copy(prices)
        sb = array.copy(bars)
        // selection sort by price ascending (n is small per window).
        // Guard n>1: Pine for-loops auto-reverse when start>end, so
        // "for a = 0 to n-2" with n=1 would run backwards (0, -1) → OOB.
        if n > 1
            for a = 0 to n - 2
                int mi = a
                for b = a + 1 to n - 1
                    if array.get(sp, b) < array.get(sp, mi)
                        mi := b
                if mi != a
                    float tp = array.get(sp, a)
                    array.set(sp, a, array.get(sp, mi)), array.set(sp, mi, tp)
                    int tb = array.get(sb, a)
                    array.set(sb, a, array.get(sb, mi)), array.set(sb, mi, tb)
        // greedy sweep
        int start = 0
        while start < n
            float csum = array.get(sp, start)
            int   ccnt = 1
            int   minB = array.get(sb, start)
            int   maxB = array.get(sb, start)
            int   en = start + 1
            bool  go = true
            while en < n and go
                if math.abs(array.get(sp, en) - csum / ccnt) <= tol
                    csum := csum + array.get(sp, en)
                    ccnt := ccnt + 1
                    minB := math.min(minB, array.get(sb, en))
                    maxB := math.max(maxB, array.get(sb, en))
                    en := en + 1
                else
                    go := false
            array.push(cP, csum / ccnt)
            array.push(cC, ccnt)
            array.push(cS, maxB - minB)
            start := en
    [cP, cC, cS]

// Best horizontal channel: the highest-scoring (Resistance, Support) cluster pair.
// Width filter is per-pair: pct = height / (support if basisBottom else resistance) × 100.
// Returns [found, refPrice, height].
bestChannel(array<float> hP, array<int> hC, array<int> hS, array<float> lP, array<int> lC, array<int> lS, int minT, float minPct, float maxPct, bool basisBottom) =>
    int   bestScore = 0
    float bestRef = na
    float bestHt  = na
    int nh = array.size(hP)
    int nl = array.size(lP)
    if nh > 0 and nl > 0
        for a = 0 to nh - 1
            if array.get(hC, a) >= minT
                float rp = array.get(hP, a)
                for b = 0 to nl - 1
                    if array.get(lC, b) >= minT
                        float sLow = array.get(lP, b)
                        float ht = rp - sLow
                        bool ok = ht > 0
                        if ok and (minPct > 0 or maxPct > 0)
                            float basis = basisBottom ? sLow : rp
                            float pct = basis > 0 ? ht / basis * 100.0 : na
                            if minPct > 0 and (na(pct) or pct < minPct)
                                ok := false
                            if maxPct > 0 and not na(pct) and pct > maxPct
                                ok := false
                        if ok
                            int score = (array.get(hC, a) + array.get(lC, b)) * (array.get(hS, a) + array.get(lS, b) + 1)
                            if score > bestScore
                                bestScore := score
                                bestRef := rp
                                bestHt  := ht
    [bestScore > 0, bestRef, bestHt]

// ═══════════════════════════════════════════════════════════════════════════
// PIVOT DETECTION (chart bars, confirmed)
// ═══════════════════════════════════════════════════════════════════════════
srcHi = priceSource == "High/Low" ? high : math.max(open, close)
srcLo = priceSource == "High/Low" ? low  : math.min(open, close)

ph = ta.pivothigh(srcHi, pivotPeriod, pivotPeriod)
pl = ta.pivotlow(srcLo, pivotPeriod, pivotPeriod)

if not na(ph)
    array.push(phPrice, ph)
    array.push(phBar, bar_index - pivotPeriod)
    if array.size(phPrice) > MAXPIV
        array.shift(phPrice), array.shift(phBar)
if not na(pl)
    array.push(plPrice, pl)
    array.push(plBar, bar_index - pivotPeriod)
    if array.size(plPrice) > MAXPIV
        array.shift(plPrice), array.shift(plBar)

isNew    = timeframe.change(cadenceTf)
validCad = timeframe.in_seconds(cadenceTf) > timeframe.in_seconds()

// ═══════════════════════════════════════════════════════════════════════════
// RECOMPUTE THE CHANNEL AT EACH HTF BOUNDARY
// ═══════════════════════════════════════════════════════════════════════════
if isNew and validCad
    // 1) Window = last `lookback` closed HTF periods → prune older pivots.
    array.push(periodStarts, bar_index)
    while array.size(periodStarts) > lookback + 1
        array.shift(periodStarts)
    int cutoff = array.get(periodStarts, 0)
    while array.size(phBar) > 0 and array.get(phBar, 0) < cutoff
        array.shift(phBar), array.shift(phPrice)
    while array.size(plBar) > 0 and array.get(plBar, 0) < cutoff
        array.shift(plBar), array.shift(plPrice)

    // 2) Cluster + best channel.
    float tol = clusterPct / 100.0 * close          // cluster merge distance (% of current price)
    bool basisBottom = widthBasis == "Bottom to Top" // Min/Max width % reference

    [hP, hC, hS] = clusterLevels(phPrice, phBar, tol)
    [lP, lC, lS] = clusterLevels(plPrice, plBar, tol)
    [found, refP, ht] = bestChannel(hP, hC, hS, lP, lC, lS, minTouches, minChannelPct, maxChannelPct, basisBottom)

    if found
        gridRef    := refP
        gridHeight := ht
    // else: carry forward the previous channel (gridRef / gridHeight unchanged)

// ═══════════════════════════════════════════════════════════════════════════
// RENDER — grid of 2·n_lines+1 levels (value always present; color = na cut)
// ═══════════════════════════════════════════════════════════════════════════
gridReady = not na(gridRef) and not na(gridHeight) and gridHeight > 0
showGrid  = validCad and gridReady

// j = 0 → resistance (ref), j = 1 → support (ref - height), j<0 → above, j>1 → below.
gLvl(int j) => showGrid and math.abs(j) <= nLines ? gridRef - gridHeight * j : na

// Color = na on the boundary bar → hides the diagonal transition (×2 plots).
cGrid = isNew ? na : gridCol
cBase = isNew ? na : baseCol

plot(gLvl(-15), "L-15", color = cGrid, linewidth = lineWidth)
plot(gLvl(-14), "L-14", color = cGrid, linewidth = lineWidth)
plot(gLvl(-13), "L-13", color = cGrid, linewidth = lineWidth)
plot(gLvl(-12), "L-12", color = cGrid, linewidth = lineWidth)
plot(gLvl(-11), "L-11", color = cGrid, linewidth = lineWidth)
plot(gLvl(-10), "L-10", color = cGrid, linewidth = lineWidth)
plot(gLvl(-9),  "L-9",  color = cGrid, linewidth = lineWidth)
plot(gLvl(-8),  "L-8",  color = cGrid, linewidth = lineWidth)
plot(gLvl(-7),  "L-7",  color = cGrid, linewidth = lineWidth)
plot(gLvl(-6),  "L-6",  color = cGrid, linewidth = lineWidth)
plot(gLvl(-5),  "L-5",  color = cGrid, linewidth = lineWidth)
plot(gLvl(-4),  "L-4",  color = cGrid, linewidth = lineWidth)
plot(gLvl(-3),  "L-3",  color = cGrid, linewidth = lineWidth)
plot(gLvl(-2),  "L-2",  color = cGrid, linewidth = lineWidth)
plot(gLvl(-1),  "L-1",  color = cGrid, linewidth = lineWidth)
plot(gLvl(0),   "Resistance", color = cBase, linewidth = baseWidth)
plot(gLvl(1),   "Support",    color = cBase, linewidth = baseWidth)
plot(gLvl(2),   "L2",  color = cGrid, linewidth = lineWidth)
plot(gLvl(3),   "L3",  color = cGrid, linewidth = lineWidth)
plot(gLvl(4),   "L4",  color = cGrid, linewidth = lineWidth)
plot(gLvl(5),   "L5",  color = cGrid, linewidth = lineWidth)
plot(gLvl(6),   "L6",  color = cGrid, linewidth = lineWidth)
plot(gLvl(7),   "L7",  color = cGrid, linewidth = lineWidth)
plot(gLvl(8),   "L8",  color = cGrid, linewidth = lineWidth)
plot(gLvl(9),   "L9",  color = cGrid, linewidth = lineWidth)
plot(gLvl(10),  "L10", color = cGrid, linewidth = lineWidth)
plot(gLvl(11),  "L11", color = cGrid, linewidth = lineWidth)
plot(gLvl(12),  "L12", color = cGrid, linewidth = lineWidth)
plot(gLvl(13),  "L13", color = cGrid, linewidth = lineWidth)
plot(gLvl(14),  "L14", color = cGrid, linewidth = lineWidth)
plot(gLvl(15),  "L15", color = cGrid, linewidth = lineWidth)

// ═══════════════════════════════════════════════════════════════════════════
// INFO LABELS — base channel width %, both references (current period, optional)
// ═══════════════════════════════════════════════════════════════════════════
// Top: % the resistance sits ABOVE the support  = height / support  × 100
// Bottom: % the support sits BELOW the resistance = height / resistance × 100
var label topLbl = na
var label botLbl = na
if showInfo and barstate.islast and showGrid
    label.delete(topLbl)
    label.delete(botLbl)
    float topPx = gridRef
    float botPx = gridRef - gridHeight
    float pctFromBottom = botPx > 0 ? gridHeight / botPx * 100.0 : na
    float pctFromTop    = topPx > 0 ? gridHeight / topPx * 100.0 : na
    topLbl := label.new(bar_index, topPx,
         "Top: " + str.tostring(pctFromBottom, "#.##") + "% from bottom",
         style = label.style_label_left, color = color.new(baseCol, 20),
         textcolor = color.white, size = size.small)
    botLbl := label.new(bar_index, botPx,
         "Bottom: " + str.tostring(pctFromTop, "#.##") + "% from top",
         style = label.style_label_left, color = color.new(baseCol, 20),
         textcolor = color.white, size = size.small)

// ── Guard: invalid cadence ──
if barstate.islast and not validCad
    label.new(bar_index, high, "⚠ Cadence TF must be > chart TF",
         style = label.style_label_down, color = color.new(color.red, 0),
         textcolor = color.white, size = size.normal)
````
