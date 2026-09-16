<!-- tradingview-pine-id: PUB;4a8a3a129a314c10a6fd04e8cbbb74ad -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Fib Gravity [GBB]

Source: https://www.tradingview.com/script/Xms6vNhu-Fibonacci-Gravity-Clusters-GBB/

## Description

Fib Gravity Clusters[GBB] — Fibonacci confluence as a heatmap

The problem with Fibonacci retracements was never the ratios but the correct swing selection. Two traders, same chart, different anchor points, completely different levels and both will find "confirmation" for theirs. I wanted to take that choice away from myself.

So this script runs six ZigZag lines in parallel (pivot lengths 3, 8, 21, 55, 144, 377 by default, but they're configurable), keeps the last 13 legs of each, projects the usual retracement ratios from every single confirmed leg, and adds it all up into a density field on the price axis. Where lots of independent swings project into the same area, the chart glows. Where they don't, nothing.

THE BOOKKEEPING

Legs smaller than 0.5 ATR get thrown out because they're noise. Every surviving leg projects the enabled ratios (0.236 / 0.382 / 0.5 / 0.618 / 0.786, plus 0.886 if you want it). Each projected level drops heat into fine price bins, a quarter ATR tall, smeared with a small Gaussian kernel so neighboring projections merge into zones instead of producing a picket fence.

Not every projection counts the same:

[*]- bigger swings contribute more (leg size in ATR, raised to a configurable exponent, capped at 8 so one monster leg can't drown everything else)
[*]- old legs fade out with a half-life, default 144 bars. This matters more than it sounds — without decay the chart slowly fills up with structure the market stopped caring about weeks ago
[*]- optional golden pocket mode adds 0.65 and gives the 0.618–0.65 area a 1.618x weight, if that's your thing

The field gets normalized, gamma-corrected and painted. Four palettes (Thermal, Ember, Ice, Mono) are selectable. The top 5 local peaks get a line and a label with the exact price and a hit count, so you can see how many raw projections actually built that zone. A ×14 zone and a ×3 zone are not the same thing even if they look similar in color.

There's also an optional HTF layer: the same field computed on Daily/Weekly/Monthly (auto-mapped from your chart TF, or fixed) and rendered behind the intraday one, dimmed, in its own palette. Built from closed HTF bars only. When an intraday hot band sits inside an HTF hot band, that's the most interesting picture this tool produces.

NON-REPAINTING

Everything is built from confirmed pivots. A level shows up once its pivot confirms which is N bars after the extreme, that's the nature of pivots and after that it doesn't move and doesn't disappear. HTF layer is lookahead_off, closed bars only. Alerts fire on bar close.

One exception: the Live Leg overlay. It projects ratios from the swing that's still forming. Dashed, labeled "forming", off by default, and it repaints by definition because the leg isn't finished. I left it in because it's occasionally useful context on fast timeframes. It is not a signal. If you turn it on and then complain about repainting, that one's on you.

ALERTS

Three of them: close enters a hot band, close enters an HTF hot band, and a new core zone forming in the top 5. Plus an optional visual flash on the touched band.

---

## Source Code

````pine
//@version=6
indicator("Fib Gravity [GBB]", "FibGravityClusters", overlay = true,
     max_boxes_count = 500, max_lines_count = 100, max_labels_count = 50, max_polylines_count = 10)

// Fib Gravity [GBB] — Fibonacci-retracement confluence rendered as a thermal
// heat field across six swing degrees.
// NON-REPAINTING: built on confirmed swings only — every level appears exactly
// once its pivot is confirmed (N bars after the extreme) and never moves or
// disappears on realtime updates. The optional Live Leg overlay is explicitly
// provisional (dashed, labeled "forming") and off by default.

// ---------- Inputs ----------
grpS = "Swings"
enab1 = input.bool(true, "", inline = "d1", group = grpS)
len1  = input.int(3, "Degree 1 length", minval = 1, inline = "d1", group = grpS)
enab2 = input.bool(true, "", inline = "d2", group = grpS)
len2  = input.int(8, "Degree 2 length", minval = 1, inline = "d2", group = grpS)
enab3 = input.bool(true, "", inline = "d3", group = grpS)
len3  = input.int(21, "Degree 3 length", minval = 1, inline = "d3", group = grpS)
enab4 = input.bool(true, "", inline = "d4", group = grpS)
len4  = input.int(55, "Degree 4 length", minval = 1, inline = "d4", group = grpS)
enab5 = input.bool(true, "", inline = "d5", group = grpS)
len5  = input.int(144, "Degree 5 length", minval = 1, inline = "d5", group = grpS)
enab6 = input.bool(true, "", inline = "d6", group = grpS)
len6  = input.int(377, "Degree 6 length", minval = 1, inline = "d6", group = grpS)
maxLegs    = input.int(13, "Max legs per degree", minval = 1, group = grpS)
minSizeAtr = input.float(0.5, "Min leg size (ATR)", minval = 0.0, step = 0.1, group = grpS)

grpR = "Ratios"
r236 = input.bool(true,  "0.236", group = grpR)
r382 = input.bool(true,  "0.382", group = grpR)
r500 = input.bool(true,  "0.5",   group = grpR)
r618 = input.bool(true,  "0.618", group = grpR)
r786 = input.bool(true,  "0.786", group = grpR)
r886 = input.bool(false, "0.886", group = grpR)
golden = input.bool(false, "Golden-pocket emphasis (0.618 & 0.65 x1.618)", group = grpR)

grpH = "Heat model"
alphaExp  = input.float(1.0, "Size exponent alpha", minval = 0.0, step = 0.1, group = grpH)
halfLife  = input.int(144, "Half-life (bars)", minval = 1, group = grpH)
sigmaBins = input.float(1.0, "Kernel width (bins)", minval = 0.1, step = 0.1, group = grpH)
binFactor = input.float(0.25, "Bin height (ATR x)", minval = 0.01, step = 0.05, group = grpH)
lookback  = input.int(610, "Lookback window (bars)", minval = 10, group = grpH)

grpD = "Rendering"
paletteSel = input.string("Thermal", "Palette", options = ["Thermal", "Ember", "Ice", "Mono"], group = grpD)
gammaExp   = input.float(0.6, "Gamma", minval = 0.1, step = 0.1, group = grpD)
maxOpacity = input.int(85, "Max opacity %", minval = 1, maxval = 100, group = grpD)
minHeat    = input.float(0.05, "Min heat to draw", minval = 0.0, step = 0.01, group = grpD)
topK       = input.int(5, "Core lines (top K)", minval = 0, group = grpD)
zzShow     = input.bool(false, "ZigZag overlay", group = grpD)
flashOn  = input.bool(true, "Contact flash", group = grpD)
flashThr = input.float(0.5, "Flash threshold", minval = 0.0, maxval = 1.0, step = 0.05, group = grpD)

grpF = "HTF layer"
htfEnable    = input.bool(false, "Enable", group = grpF)
htfTfSel     = input.string("Auto", "Timeframe", options = ["Auto", "240", "D", "W", "M"], group = grpF)
htfLen       = input.int(21, "HTF pivot length", minval = 1, group = grpF)
htfPalSel    = input.string("Ice", "HTF palette", options = ["Thermal", "Ember", "Ice", "Mono"], group = grpF)
htfBinFactor = input.float(0.5, "HTF bin height (ATR x)", minval = 0.01, step = 0.05, group = grpF)

grpL = "Live Leg"
liveShow = input.bool(false, "Enable (provisional, repaints)", group = grpL)

grpV = "Style"
htfIntensity = input.int(40, "HTF intensity %", minval = 0, maxval = 100, group = grpV)
labelSizeSel = input.string("Normal", "Label size", options = ["Small", "Normal", "Large"], group = grpV)
labelBg      = input.bool(true, "Label background", group = grpV)
coreColor    = input.color(#FFF4D6, "Core line & label color", group = grpV)
liveColor    = input.color(#00E5FF, "Live Leg color", group = grpV)

lblSize  = labelSizeSel == "Small" ? size.small : labelSizeSel == "Large" ? size.large : size.normal
lblBgCol = labelBg ? color.new(color.black, 25) : color.new(color.black, 100)

// Spec constants (not inputs)
int BIN_CAP = 233
int HTF_BIN_CAP = 117
int MIN_SEP = 3
int ATR_LEN = 144

// ---------- Types & swing engine ----------
type Leg
    float priceA
    float priceB
    int   barB
    int   timeB   // unix seconds of bar B
    float sizeAtr
    int   timeA = na  // unix seconds of pivot A (overlay only; never dumped)

type DegreeState
    int   deg
    int   lastKind = 0     // 0 = none, 1 = high, -1 = low
    float lastPrice = na
    int   lastBar = na
    int   lastTime = na
    float legA = na        // price A of the current last leg's pivot pair
    int   legATime = na
    bool  hasA = false
    bool  lastInBuf = false
    array<Leg> legs

method pushLeg(DegreeState s, float a, float b, int barB, int timeB, float atrB, int timeA) =>
    // Filters run BEFORE ring-buffer insertion (oracle legs_from_pivots).
    bool ok = not na(atrB) and atrB > 0
    float size = ok ? math.abs(b - a) / atrB : na
    if ok and size >= minSizeAtr
        s.legs.push(Leg.new(a, b, barB, timeB, size, timeA))
        // one-slot spare: only the tail leg is mutable, so consumers skip index 0 when over maxLegs (keeps stream == batch after a tail pop)
        if s.legs.size() > maxLegs + 1
            s.legs.shift()
        s.lastInBuf := true
    else
        s.lastInBuf := false

method refreshLeg(DegreeState s, float atrB) =>
    // Same-kind replacement moved B: recompute the (legA -> lastPrice) leg,
    // re-apply the size filter, update / remove / insert in place.
    bool ok = not na(atrB) and atrB > 0
    float size = ok ? math.abs(s.lastPrice - s.legA) / atrB : na
    if s.lastInBuf
        if ok and size >= minSizeAtr
            s.legs.set(s.legs.size() - 1, Leg.new(s.legA, s.lastPrice, s.lastBar, s.lastTime, size, s.legATime))
            s.lastInBuf := true    // no-op: branch tails must share one type (CE10235)
        else
            s.legs.pop()
            s.lastInBuf := false
    else if ok and size >= minSizeAtr
        s.legs.push(Leg.new(s.legA, s.lastPrice, s.lastBar, s.lastTime, size, s.legATime))
        if s.legs.size() > maxLegs + 1
            s.legs.shift()
        s.lastInBuf := true

method onPivot(DegreeState s, int kind, float p, int barB, int timeB, float atrB) =>
    if s.lastKind == 0
        s.lastKind := kind
        s.lastPrice := p
        s.lastBar := barB
        s.lastTime := timeB
        s.hasA := false    // no-op: branch tails must share one type (CE10235)
    else if s.lastKind == kind
        // ZigZag rule: same-kind consecutive pivots keep the more extreme.
        bool better = kind == 1 ? p > s.lastPrice : p < s.lastPrice
        if better
            s.lastPrice := p
            s.lastBar := barB
            s.lastTime := timeB
            if s.hasA
                s.refreshLeg(atrB)
    else
        s.legA := s.lastPrice
        s.legATime := s.lastTime
        s.hasA := true
        s.lastKind := kind
        s.lastPrice := p
        s.lastBar := barB
        s.lastTime := timeB
        // pushLeg reads none of the fields above; tail call keeps branch types aligned (CE10235)
        s.pushLeg(s.legA, p, barB, timeB, atrB, s.legATime)

f_step(DegreeState s, bool en, float ph, float pl, float atrB, int barB, int timeB) =>
    if en
        if not na(ph) and not na(pl)
            // Same-bar tie: emit the kind that alternates with the previous
            // pivot first; with no prior pivot, high first (mirrors oracle).
            if s.lastKind == 1
                s.onPivot(-1, pl, barB, timeB, atrB)
                s.onPivot(1, ph, barB, timeB, atrB)
            else
                s.onPivot(1, ph, barB, timeB, atrB)
                s.onPivot(-1, pl, barB, timeB, atrB)
        else if not na(ph)
            s.onPivot(1, ph, barB, timeB, atrB)
        else if not na(pl)
            s.onPivot(-1, pl, barB, timeB, atrB)

// Auto mapping per spec §3 note: chart ≤4H → D, ≤D → W, else M.
f_htfAuto() =>
    int cs = timeframe.in_seconds(timeframe.period)
    cs <= 4 * 60 * 60 ? "D" : cs < 7 * 24 * 60 * 60 ? "W" : "M"

// Runs inside request.security on the HTF series. Every returned element is
// [1]-offset so only CLOSED HTF bars contribute (spec §2 / design §1).
// ATR and pivot time are sampled AT THE PIVOT BAR (index n), mirroring the
// intraday f_step call sites exactly.
f_htfCtx(int n) =>
    float ph = ta.pivothigh(high, n, n)
    float pl = ta.pivotlow(low, n, n)
    float av = ta.atr(ATR_LEN)
    float atrAtPivot = av[n]
    int   pt = int(time[n] / 1000)
    [ph[1], pl[1], atrAtPivot[1], pt[1], av[1], time[1]]

htfTf = htfTfSel == "Auto" ? f_htfAuto() : htfTfSel
htfActive = htfEnable and timeframe.in_seconds(timeframe.period) < timeframe.in_seconds(htfTf)

var DegreeState s1 = DegreeState.new(deg = len1, legs = array.new<Leg>())
var DegreeState s2 = DegreeState.new(deg = len2, legs = array.new<Leg>())
var DegreeState s3 = DegreeState.new(deg = len3, legs = array.new<Leg>())
var DegreeState s4 = DegreeState.new(deg = len4, legs = array.new<Leg>())
var DegreeState s5 = DegreeState.new(deg = len5, legs = array.new<Leg>())
var DegreeState s6 = DegreeState.new(deg = len6, legs = array.new<Leg>())

atrSeries = ta.atr(ATR_LEN)

ph1 = ta.pivothigh(high, len1, len1)
pl1 = ta.pivotlow(low, len1, len1)
ph2 = ta.pivothigh(high, len2, len2)
pl2 = ta.pivotlow(low, len2, len2)
ph3 = ta.pivothigh(high, len3, len3)
pl3 = ta.pivotlow(low, len3, len3)
ph4 = ta.pivothigh(high, len4, len4)
pl4 = ta.pivotlow(low, len4, len4)
ph5 = ta.pivothigh(high, len5, len5)
pl5 = ta.pivotlow(low, len5, len5)
ph6 = ta.pivothigh(high, len6, len6)
pl6 = ta.pivotlow(low, len6, len6)

f_step(s1, enab1, ph1, pl1, atrSeries[len1], bar_index - len1, int(time[len1] / 1000))
f_step(s2, enab2, ph2, pl2, atrSeries[len2], bar_index - len2, int(time[len2] / 1000))
f_step(s3, enab3, ph3, pl3, atrSeries[len3], bar_index - len3, int(time[len3] / 1000))
f_step(s4, enab4, ph4, pl4, atrSeries[len4], bar_index - len4, int(time[len4] / 1000))
f_step(s5, enab5, ph5, pl5, atrSeries[len5], bar_index - len5, int(time[len5] / 1000))
f_step(s6, enab6, ph6, pl6, atrSeries[len6], bar_index - len6, int(time[len6] / 1000))

var DegreeState sH = DegreeState.new(deg = 0, legs = array.new<Leg>())
var int htfBarNow = -1
var int lastHtfT = na
var float hAtrC = na

[hPh, hPl, hPivAtr, hPivT, hAtr, hTime] = request.security(syminfo.tickerid, htfTf,
     f_htfCtx(htfLen), lookahead = barmerge.lookahead_off)

if htfActive and not na(hTime) and (na(lastHtfT) or hTime != lastHtfT)
    // one new CLOSED HTF bar: advance the HTF decay clock, cache closed-bar
    // context, and feed any pivot it confirmed into the HTF leg engine.
    lastHtfT := hTime
    htfBarNow += 1
    hAtrC := hAtr
    f_step(sH, true, hPh, hPl, hPivAtr, htfBarNow - htfLen, hPivT)

// ---------- Field computation (called on one bar only) ----------
f_ratios() =>
    rs = array.new_float()
    if r236
        rs.push(0.236)
    if r382
        rs.push(0.382)
    if r500
        rs.push(0.5)
    if r618
        rs.push(0.618)
    if r786
        rs.push(0.786)
    if r886
        rs.push(0.886)
    if golden and not rs.includes(0.65)
        rs.push(0.65)
    rs

f_states() =>
    dstates = array.new<DegreeState>()
    dstates.push(s1)
    dstates.push(s2)
    dstates.push(s3)
    dstates.push(s4)
    dstates.push(s5)
    dstates.push(s6)
    dstates

f_buildField(array<DegreeState> dstates, float atrLast, float wLo, float wHi, float binF, int binCap, int nowBar, array<float> rs, int kTop) =>
    float lo = na
    float h = na
    int nbins = 0
    array<float> heat = na
    array<int> counts = na
    array<int> zones = na
    if not na(atrLast) and atrLast > 0 and not na(wLo)
        h := atrLast * binF
        // Order pinned to the oracle: pad from the PRE-cap bin height, then cap.
        lo := wLo - 2 * h
        float hi = wHi + 2 * h
        nbins := int(math.ceil((hi - lo) / h))
        if nbins > binCap
            h := (hi - lo) / binCap
            nbins := binCap
        heat := array.new_float(nbins, 0.0)
        counts := array.new_int(nbins, 0)
        int reach = int(math.floor(3 * sigmaBins + 1e-9))
        float twoSigSq = 2 * sigmaBins * sigmaBins
        if dstates.size() > 0
            for di = 0 to dstates.size() - 1
                DegreeState s = dstates.get(di)
                if s.legs.size() > 0 and rs.size() > 0
                    int j0 = s.legs.size() > maxLegs ? 1 : 0
                    for j = j0 to s.legs.size() - 1
                        Leg lg = s.legs.get(j)
                        for k = 0 to rs.size() - 1
                            float r = rs.get(k)
                            float level = lg.priceB - r * (lg.priceB - lg.priceA)
                            int c = int(math.floor((level - lo) / h))
                            if c >= -reach and c <= nbins - 1 + reach
                                float mult = golden and (r == 0.618 or r == 0.65) ? 1.618 : 1.0
                                float w = math.pow(math.min(math.max(lg.sizeAtr, 0.0), 8.0), alphaExp) *
                                     math.pow(0.5, (nowBar - lg.barB) / float(halfLife)) * mult
                                if c >= 0 and c < nbins
                                    counts.set(c, counts.get(c) + 1)
                                for b = math.max(0, c - reach) to math.min(nbins - 1, c + reach)
                                    heat.set(b, heat.get(b) + w * math.exp(-((b - c) * (b - c)) / twoSigSq))
        float maxHeat = heat.max()
        // two complementary ifs, not if/else: the branch tails (void vs array) may not mix (CE10235)
        bool hasHeat = maxHeat > 0
        if hasHeat
            for b = 0 to nbins - 1
                heat.set(b, heat.get(b) / maxHeat)
            // Top-K strict local maxima, min separation, ties to the lower bin.
            zones := array.new_int()
            while zones.size() < kTop
                int bestBin = -1
                float bestHeat = -1.0
                if nbins >= 3
                    for b = 1 to nbins - 2
                        float hb = heat.get(b)
                        if hb > heat.get(b - 1) and hb > heat.get(b + 1) and hb > bestHeat
                            bool okSep = true
                            if zones.size() > 0
                                for q = 0 to zones.size() - 1
                                    if math.abs(b - zones.get(q)) < MIN_SEP
                                        okSep := false
                            if okSep
                                bestBin := b
                                bestHeat := hb
                if bestBin == -1
                    break
                zones.push(bestBin)
            zones.sort()
        if not hasHeat
            heat := na
            counts := na
    [lo, h, nbins, heat, counts, zones]

f_field() =>
    float atrLast = atrSeries
    float wLo = na
    float wHi = na
    if not na(atrLast) and atrLast > 0
        int window = math.min(lookback, bar_index + 1)
        for i = 0 to window - 1
            wLo := na(wLo) ? low[i] : math.min(wLo, low[i])
            wHi := na(wHi) ? high[i] : math.max(wHi, high[i])
    f_buildField(f_states(), atrLast, wLo, wHi, binFactor, BIN_CAP, bar_index, f_ratios(), topK)

// ---------- Palettes & rendering ----------
var array<color> palThermal = array.from(#12061F, #4B1A8C, #C41E8A, #FF7A1A, #FFF4D6)
var array<color> palIce     = array.from(#061A1F, #0E5F6E, #19B2C4, #7FE8F2, #EAFFFF)
var array<color> palEmber   = array.from(#1A0800, #5C1E00, #A34400, #E87E1C, #FFD9A0)
var array<color> palMono    = array.from(#101014, #3A3A44, #71717E, #ABABB8, #F2F2F6)

f_palStops(string sel) =>
    sel == "Ice" ? palIce : sel == "Ember" ? palEmber :
     sel == "Mono" ? palMono : palThermal

f_palColor(float t, array<color> stops) =>
    float tt = math.min(math.max(t, 0.0), 1.0)
    float pos = tt * (stops.size() - 1)
    int i = math.min(int(pos), stops.size() - 2)
    float f = pos - i
    color c1 = stops.get(i)
    color c2 = stops.get(i + 1)
    color.rgb(color.r(c1) * (1 - f) + color.r(c2) * f,
         color.g(c1) * (1 - f) + color.g(c2) * f,
         color.b(c1) * (1 - f) + color.b(c2) * f)

var array<box> gBoxes = array.new<box>()
var array<line> gLines = array.new<line>()
var array<label> gLabels = array.new<label>()
var array<polyline> gPolys = array.new<polyline>()

var bool alertHotNow = false
var bool alertNewZone = false
var bool alertHtfHotNow = false
var bool prevHot = false
var bool prevHtfHot = false
var bool prevZonesSeeded = false
var array<float> prevZones = array.new_float()

f_clearDrawings() =>
    if gBoxes.size() > 0
        for i = 0 to gBoxes.size() - 1
            box.delete(gBoxes.get(i))
        gBoxes.clear()
    if gLines.size() > 0
        for i = 0 to gLines.size() - 1
            line.delete(gLines.get(i))
        gLines.clear()
    if gLabels.size() > 0
        for i = 0 to gLabels.size() - 1
            label.delete(gLabels.get(i))
        gLabels.clear()
    if gPolys.size() > 0
        for i = 0 to gPolys.size() - 1
            polyline.delete(gPolys.get(i))
        gPolys.clear()

if barstate.islast
    f_clearDrawings()
    [lo, h, nbins, heatN, counts, zoneBins] = f_field()
    float hLoG = na
    float hHG = na
    int hNb = 0
    array<float> hHeatN = na
    if htfActive
        hStates = array.new<DegreeState>()
        hStates.push(sH)
        // HTF grid clipped to the intraday field's DRAWN extent: background
        // context must never stretch the price scale beyond the thermal field.
        float cwLo = na
        float cwHi = na
        if not na(heatN)
            for b = 0 to nbins - 1
                if heatN.get(b) >= minHeat
                    cwLo := na(cwLo) ? lo + b * h : math.min(cwLo, lo + b * h)
                    cwHi := na(cwHi) ? lo + (b + 1) * h : math.max(cwHi, lo + (b + 1) * h)
        if na(cwLo)
            // intraday field empty: fall back to the chart's lookback window
            int cwin = math.min(lookback, bar_index + 1)
            for i = 0 to cwin - 1
                cwLo := na(cwLo) ? low[i] : math.min(cwLo, low[i])
                cwHi := na(cwHi) ? high[i] : math.max(cwHi, high[i])
        [hl, hh, hn, hht, hct, hzn] = f_buildField(hStates, hAtrC, cwLo, cwHi,
             htfBinFactor, HTF_BIN_CAP, htfBarNow, f_ratios(), 0)
        hLoG := hl
        hHG := hh
        hNb := hn
        hHeatN := hht
        if not na(hHeatN)
            htfStops = f_palStops(htfPalSel)
            int hLeft = math.max(bar_index - lookback, 0)
            for b = 0 to hNb - 1
                float t = hHeatN.get(b)
                if t >= minHeat
                    int transp = 100 - int(math.round(maxOpacity * htfIntensity / 100.0 * math.pow(t, gammaExp)))
                    gBoxes.push(box.new(hLeft, hLoG + (b + 1) * hHG, bar_index + 1, hLoG + b * hHG,
                         border_color = na, bgcolor = color.new(f_palColor(t, htfStops), transp),
                         extend = extend.right))
    else if htfEnable
        gLabels.push(label.new(bar_index, na, "HTF layer off: chart TF >= HTF timeframe",
             yloc = yloc.abovebar, style = label.style_label_down,
             color = color.new(color.gray, 60), textcolor = color.white, size = size.small))
    if not na(heatN)
        int leftIdx = math.max(bar_index - lookback, 0)
        intraStops = f_palStops(paletteSel)
        for b = 0 to nbins - 1
            float t = heatN.get(b)
            if t >= minHeat
                int transp = 100 - int(math.round(maxOpacity * math.pow(t, gammaExp)))
                gBoxes.push(box.new(leftIdx, lo + (b + 1) * h, bar_index + 1, lo + b * h,
                     border_color = na, bgcolor = color.new(f_palColor(t, intraStops), transp),
                     extend = extend.right))
        if not na(zoneBins) and zoneBins.size() > 0
            for i = 0 to zoneBins.size() - 1
                int zb = zoneBins.get(i)
                float zp = lo + (zb + 0.5) * h
                gLines.push(line.new(leftIdx, zp, bar_index, zp, extend = extend.right,
                     color = coreColor, width = 1))
                gLabels.push(label.new(bar_index + 1, zp,
                     str.tostring(zp, format.mintick) + " ×" + str.tostring(counts.get(zb)),
                     style = label.style_label_left, color = lblBgCol,
                     textcolor = coreColor, size = lblSize))
    if zzShow
        var array<color> zzColors = array.from(color.silver, color.orange, color.aqua,
             color.fuchsia, color.lime, color.yellow)
        dstates = f_states()
        for di = 0 to 5
            DegreeState s = dstates.get(di)
            if s.legs.size() > 0
                int j0 = s.legs.size() > maxLegs ? 1 : 0
                pts = array.new<chart.point>()
                Leg first = s.legs.get(j0)
                if not na(first.timeA)
                    pts.push(chart.point.from_time(first.timeA * 1000, first.priceA))
                for j = j0 to s.legs.size() - 1
                    Leg lg = s.legs.get(j)
                    pts.push(chart.point.from_time(lg.timeB * 1000, lg.priceB))
                if pts.size() >= 2
                    gPolys.push(polyline.new(pts, xloc = xloc.bar_time,
                         line_color = zzColors.get(di), line_width = 1))
    if liveShow and (enab1 or enab2 or enab3 or enab4 or enab5 or enab6)
        DegreeState sLive = enab1 ? s1 : enab2 ? s2 : enab3 ? s3 : enab4 ? s4 : enab5 ? s5 : s6
        if sLive.lastKind != 0
            int back = bar_index - sLive.lastBar
            float ext = na
            if back >= 1 and back <= 4999    // history-reference buffer guard (degenerate configs)
                if sLive.lastKind == 1
                    for i = 0 to back - 1
                        ext := na(ext) ? low[i] : math.min(ext, low[i])
                else
                    for i = 0 to back - 1
                        ext := na(ext) ? high[i] : math.max(ext, high[i])
            if not na(ext) and ext != sLive.lastPrice
                rs = f_ratios()
                if rs.size() > 0
                    for k = 0 to rs.size() - 1
                        float lvl = ext - rs.get(k) * (ext - sLive.lastPrice)
                        gLines.push(line.new(sLive.lastBar, lvl, bar_index, lvl,
                             extend = extend.right, color = color.new(liveColor, 30),
                             style = line.style_dashed, width = 1))
                gLabels.push(label.new(bar_index + 1, ext, "forming",
                     style = label.style_label_left, color = lblBgCol,
                     textcolor = liveColor, size = lblSize))
    bool nowHot = false
    int cbFlash = -1
    if not na(heatN)
        int cb = int(math.floor((close - lo) / h))
        if cb >= 0 and cb < nbins and heatN.get(cb) >= flashThr
            nowHot := true
            cbFlash := cb
    bool nowHtfHot = false
    if not na(hHeatN)
        int hb = int(math.floor((close - hLoG) / hHG))
        if hb >= 0 and hb < hNb and hHeatN.get(hb) >= flashThr
            nowHtfHot := true
    bool newZone = false
    if not na(heatN) and not na(zoneBins) and zoneBins.size() > 0
        for i = 0 to zoneBins.size() - 1
            float zp = lo + (zoneBins.get(i) + 0.5) * h
            bool seen = false
            if prevZones.size() > 0
                for q = 0 to prevZones.size() - 1
                    if math.abs(zp - prevZones.get(q)) <= h * 0.5
                        seen := true
            if not seen and prevZonesSeeded
                newZone := true
    alertHotNow := nowHot and not prevHot
    alertHtfHotNow := nowHtfHot and not prevHtfHot
    alertNewZone := newZone
    prevHot := nowHot
    prevHtfHot := nowHtfHot
    if not na(heatN) and not na(zoneBins) and zoneBins.size() > 0
        prevZones.clear()
        for i = 0 to zoneBins.size() - 1
            prevZones.push(lo + (zoneBins.get(i) + 0.5) * h)
        prevZonesSeeded := true
    if flashOn and nowHot and cbFlash >= 0
        int fLeft = math.max(bar_index - lookback, 0)
        flashStops = f_palStops(paletteSel)
        gBoxes.push(box.new(fLeft, lo + (cbFlash + 1) * h, bar_index + 1, lo + cbFlash * h,
             border_color = na,
             bgcolor = color.new(f_palColor(heatN.get(cbFlash), flashStops), 100 - maxOpacity),
             extend = extend.right))
        gLabels.push(label.new(bar_index, close, "", style = label.style_circle,
             size = size.tiny, color = coreColor))

alertcondition(alertHotNow, "Close enters hot band", "Fib Gravity: close entered a hot band (heat >= flash threshold)")
alertcondition(alertNewZone, "New core zone formed", "Fib Gravity: a new core zone entered the top-K")
alertcondition(alertHtfHotNow, "Close enters HTF hot band", "Fib Gravity: close entered an HTF hot band")
````
