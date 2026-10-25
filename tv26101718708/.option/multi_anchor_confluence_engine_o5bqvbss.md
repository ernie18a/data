# Multi Anchor Confluence Engine

- url: https://www.tradingview.com/script/O5BqvBSS-Multi-Anchor-Confluence-Engine/
- type: indicator
- pine_id: PUB;7e3f1b3f09694f96ad38d7d2b9132259
- version: 1.0

## Description

A price-chart ribbon indicator that lets you choose how the trend anchor and its surrounding envelope are calculated, while a 16-instrument, 4-benchmark cross-asset engine determines how much to trust what's showing — via a Signal Strength score that controls the ribbon's color, opacity, and width in real time.

How it works

The core visual is a single anchor line with a multi-layer gradient ribbon around it, plus optional lean-colored candles. Two independent dropdowns control the shape of that visual:

Anchor Mode — 11 selectable algorithms for the centerline itself: Session VWAP, KNN Trend (nearest-neighbor smoothed regression), Dynamic Flow Ribbons' adaptive trailing band, Hull MA, Twin Range Filter, Ichimoku Kijun, a long EMA trend, a momentum-scaled "Quantum Field" center, a harmonic RMA baseline, a Wilder's-ATR chandelier trail, and a session-adaptive SuperTrend whose multiplier reacts to how current volatility compares to the prior session's.
Envelope Mode — 9 selectable algorithms for the band shape around that anchor: statistical standard deviation, K-means price clustering, ATR deviation bands, Ichimoku's Kumo cloud, a momentum-scaled amplitude band, Donchian channel, prior-day high/low, a dual-timeframe auction corridor, and a classic Keltner Channel.

Underneath, 16 futures/instruments (indices, metals, energy, crypto, agriculturals, and volatility) are each scored for relative strength against a user-weighted blend of four macro benchmarks (equity index, dollar index, and two Treasury yields). Two outputs from that engine feed back into the ribbon:

Composite — the net bullish/bearish lean across all enabled instruments, which sets the ribbon and candle color direction.
Confluence — what fraction of instruments are simultaneously reading a strong signal, blended with Composite magnitude into a single Signal Strength score. Low strength renders as a faded, wider ribbon (low conviction — don't over-read it); high strength renders as vivid and tighter (broad agreement across markets).

Every one of the 20 algorithms has its own dedicated, clearly labeled settings group, so tuning one doesn't require hunting through unrelated options.

Settings overview

Display: text scale, dashboard toggle
Ribbon: colors, layer count, dynamic width/layer behavior
Benchmark 1–4: symbol, price source, and blend weight for each macro benchmark
Anchor: one settings group per algorithm (11 total)
Envelope: one settings group per algorithm (9 total)
Instruments: enable, symbol, price source, and weight for each of the 16 tracked markets

Notes

This is a discretionary confluence tool, not a signal generator — it's designed to help you gauge whether current price action is broadly corroborated across markets, not to produce buy/sell calls on its own.
Running many instruments and algorithms simultaneously is computationally heavy; if you hit Pine's memory limit, reducing the number of enabled instruments is the most direct fix.
Default symbols for a few of the 16 tracked instruments are best-guess placeholders — verify they match what you intend to track before relying on the readings.

Credits

This indicator adapts concepts and, in places, code structure from several publicly shared scripts. With thanks to:

LuxAlgo — AI Channels (K-means clustering envelope), CC BY-NC-SA 4.0
BigBeluga — Dynamic Flow Ribbons (adaptive trailing band, iridescent ribbon rendering), CC BY-NC-SA 4.0
Zeiierman — AI Trend Navigator (KNN nearest-neighbor trend line)
J. Ehlers / PineCoders — SuperSmoother filter concept
BCeyhan / Hassonya — Hull MA system
The Twin Range Filter, Blackflag FTS, HAFT Acceleration, Ichimoku [LucF], VIX Bars, UCS Snapback, Foundry Range Ledger, Sequences of Fibonacci, ScalpMaster Pro, CSVWAP, and CoffeeShopCrypto Supertrend Liquidity Engine authors, whose published concepts informed individual anchor/envelope options.

## Source Code

````pine
// ═══════════════════════════════════════════════════════════════════════════
//  Multi-Instrument Flow Ribbon  —  v1
//
//  A fourth articulation of the same 16-instrument probability engine —
//  this time compressed entirely into a price-chart overlay, styled after
//  two of the uploaded reference scripts:
//   - CSVWAP: the anchor line is a session-reset VWAP with a statistical
//     stdev envelope (simplified here to a daily reset — CSVWAP's full
//     comma-separated multi-schedule reset system is more flexibility than
//     this needs, but that pattern is available if finer control is wanted
//     later).
//   - Dynamic Flow Ribbons: multi-layer gradient bands around the anchor
//     line, direction-colored candles.
//   - Iridescent Helix: the actual gradient-layer coloring technique
//     (f_layerColor — interpolating a base color toward an accent color
//     across stepped-transparency layers) is reused directly for the
//     ribbon's visual rendering.
//
//  The 16 instruments and 4 blended benchmarks (same engine as the
//  Oscillator version — same crash-prevention symbol substitution, same
//  Ehlers SuperSmoother noise filtering) are NOT plotted individually here.
//  Instead they're compressed into two outputs that drive the ribbon and
//  candles:
//   - Composite lean (bull/bear) sets the ribbon/candle color direction.
//   - Confluence % (how many instruments agree, simultaneously) sets how
//     VIVID and TIGHT the ribbon renders — strong agreement across
//     instruments = vivid, tighter ribbon (real conviction); weak/no
//     agreement = faded, wider ribbon (uncertain, don't over-trust it).
// ═══════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Multi Anchor Confluence Engine", overlay = true, max_labels_count = 50, max_lines_count = 50)

// ---------- DISPLAY ----------
grpVis = "Display"
textScale = input.string("Normal", "Text Scale", options = ["Compact", "Normal", "Large"], group = grpVis)
showDash = input.bool(true, "Show Dashboard", group = grpVis)

f_sizeFromIndex(int idx) =>
    string s = size.normal
    if idx <= 0
        s := size.tiny
    else if idx == 1
        s := size.small
    else if idx == 2
        s := size.normal
    else if idx == 3
        s := size.large
    else
        s := size.huge
    s

textShift = textScale == "Compact" ? -1 : textScale == "Large" ? 1 : 0
labelIdx  = math.max(0, math.min(4, 1 + textShift))
labelSize = f_sizeFromIndex(labelIdx)

// ---------- COLOR LANGUAGE (shared with the rest of the family) ----------
colUp        = #00c896
colDown      = #ff4466
colClimax    = #ffb020
colNeutral   = #4a5568
colBg        = color.new(#0d1117, 0)

// ---------- RIBBON VISUALS ----------
grpRibbon = "Ribbon"
bullColor    = input.color(#00c896, "Bull Base Color", group = grpRibbon, inline = "rc1")
bullAccent   = input.color(#00bbff, "Bull Iridescent Accent", group = grpRibbon, inline = "rc1")
bearColor    = input.color(#ff4466, "Bear Base Color", group = grpRibbon, inline = "rc2")
bearAccent   = input.color(#ff00bb, "Bear Iridescent Accent", group = grpRibbon, inline = "rc2")
ribbonLayers = input.int(4, "Ribbon Layers (per side)", minval = 2, maxval = 4, group = grpRibbon, tooltip = "Capped at 4 (down from an earlier 8) to reduce this script's fixed rendering overhead — a real contributor to the memory limit this script can hit given it already runs 20 simultaneous multi-symbol data requests underneath.")

showCandles  = input.bool(true, "Color Candles by Composite Lean", group = grpRibbon)

// Iridescent layer color — interpolates baseCol to accentCol with stepped transparency.
// (technique from the uploaded "Iridescent Helix [JOAT]" reference)
// Widened dynamic range: at full strength, inner layers approach near-solid;
// at zero strength, every layer approaches near-invisible — a much more
// pronounced swing than a narrow, capped transparency range would give.
f_layerColor(color baseCol, color accentCol, int i, int totalLayers, float vividness) =>
    layerHue = color.from_gradient(i / (totalLayers * 1.0), 0.0, 1.0, baseCol, accentCol)
    baseAlpha = 6 + i * 8
    alpha = math.round(math.max(0.0, math.min(98.0, baseAlpha + (100.0 - vividness) * 0.9)))
    color.new(layerHue, alpha)

// ---------- BENCHMARKS  (blended — all four affect every instrument) ----------
grpBench1 = "Benchmark 1 — SPX"
spxSym = input.symbol("TVC:SPX", "Symbol", group = grpBench1, inline = "b1")
spxSrc = input.string("Close", "Source", options = ["Close", "Open", "HL2", "HLC3", "OHLC4"], group = grpBench1, inline = "b1")
spxWt  = input.float(1.0, "Weight", minval = 0.0, step = 0.1, group = grpBench1, inline = "b1")

grpBench2 = "Benchmark 2 — DXY"
dxySym = input.symbol("TVC:DXY", "Symbol", group = grpBench2, inline = "b2")
dxySrc = input.string("Close", "Source", options = ["Close", "Open", "HL2", "HLC3", "OHLC4"], group = grpBench2, inline = "b2")
dxyWt  = input.float(1.0, "Weight", minval = 0.0, step = 0.1, group = grpBench2, inline = "b2")

grpBench3 = "Benchmark 3 — US10Y"
us10ySym = input.symbol("TVC:US10Y", "Symbol", group = grpBench3, inline = "b3")
us10ySrc = input.string("Close", "Source", options = ["Close", "Open", "HL2", "HLC3", "OHLC4"], group = grpBench3, inline = "b3")
us10yWt  = input.float(1.0, "Weight", minval = 0.0, step = 0.1, group = grpBench3, inline = "b3")

grpBench4 = "Benchmark 4 — US5YR"
us5ySym = input.symbol("TVC:US05Y", "Symbol", group = grpBench4, inline = "b4")
us5ySrc = input.string("Close", "Source", options = ["Close", "Open", "HL2", "HLC3", "OHLC4"], group = grpBench4, inline = "b4")
us5yWt  = input.float(1.0, "Weight", minval = 0.0, step = 0.1, group = grpBench4, inline = "b4")

// ---------- CALCULATION ----------
grpCalc = "Calculation"
rsLen     = input.int(20, "RS-Ratio Smoothing Length", minval = 2, group = grpCalc)
momLen    = input.int(10, "RS-Momentum Length", minval = 2, group = grpCalc)
atrLen    = input.int(14, "ATR Length", minval = 2, group = grpCalc)
atrBaseLen = input.int(50, "ATR Baseline Length", minval = 5, group = grpCalc)
pressLen  = input.int(15, "Directional Pressure Lookback", minval = 2, group = grpCalc)
pivotLen  = input.int(10, "Structure Pivot Length", minval = 2, group = grpCalc)

// ---------- PROBABILITY / CONFLUENCE ----------
grpProb = "Probability / Confluence"
probMed  = input.float(50.0, "Medium Probability Threshold (%)", minval = 0, maxval = 100, group = grpProb)
probHigh = input.float(75.0, "High Probability Threshold (%)", minval = 0, maxval = 100, group = grpProb)

// ---------- NOISE FILTERING ----------
grpFilter = "Noise Filtering"
useSmoothing = input.bool(true, "Smooth Probability Scores (Ehlers SuperSmoother)", group = grpFilter)
smoothLen = input.int(10, "Smoothing Length", minval = 2, maxval = 50, group = grpFilter)

f_superSmoother(float src, int len) =>
    float a1 = math.exp(-1.414 * math.pi / len)
    float b1 = 2.0 * a1 * math.cos(1.414 * math.pi / len)
    float c2 = b1
    float c3 = -a1 * a1
    float c1 = 1.0 - c2 - c3
    var float ss1 = na
    var float ss2 = na
    float filt = (na(ss1) or na(ss2)) ? src : c1 * (src + nz(src[1])) / 2.0 + c2 * ss1 + c3 * ss2
    ss2 := ss1
    ss1 := filt
    filt

// ---------- SOURCE SELECTION HELPER ----------
f_srcSelect(string mode, float o, float h, float l, float c) =>
    float r = c
    if mode == "Close"
        r := c
    else if mode == "Open"
        r := o
    else if mode == "HL2"
        r := (h + l) / 2.0
    else if mode == "HLC3"
        r := (h + l + c) / 3.0
    else if mode == "OHLC4"
        r := (o + h + l + c) / 4.0
    r

// ─────────────────────────────────────────────────────────────────────────
// FOUR BENCHMARKS — each fetched ONCE, then blended per-instrument below
// ─────────────────────────────────────────────────────────────────────────
[spxO, spxH, spxL, spxC] = request.security(spxSym, timeframe.period, [open, high, low, close], lookahead = barmerge.lookahead_off)
b1 = f_srcSelect(spxSrc, spxO, spxH, spxL, spxC)

[dxyO, dxyH, dxyL, dxyC] = request.security(dxySym, timeframe.period, [open, high, low, close], lookahead = barmerge.lookahead_off)
b2 = f_srcSelect(dxySrc, dxyO, dxyH, dxyL, dxyC)

[u10O, u10H, u10L, u10C] = request.security(us10ySym, timeframe.period, [open, high, low, close], lookahead = barmerge.lookahead_off)
b3 = f_srcSelect(us10ySrc, u10O, u10H, u10L, u10C)

[u5O, u5H, u5L, u5C] = request.security(us5ySym, timeframe.period, [open, high, low, close], lookahead = barmerge.lookahead_off)
b4 = f_srcSelect(us5ySrc, u5O, u5H, u5L, u5C)

bw1 = spxWt
bw2 = dxyWt
bw3 = us10yWt
bw4 = us5yWt

// ─────────────────────────────────────────────────────────────────────────
// PER-INSTRUMENT METRICS — ratio blended across all 4 benchmarks BEFORE
// smoothing/z-scoring (same engine as the Oscillator version).
// ─────────────────────────────────────────────────────────────────────────
f_instrumentMetrics(string sym, string srcMode, float bench1, float bench2, float bench3, float bench4, float w1, float w2, float w3, float w4, int rLen, int mLen, int aLen, int aBaseLen, int pLen, int pivLen) =>
    [o, h, l, c] = request.security(sym, timeframe.period, [open, high, low, close], lookahead = barmerge.lookahead_off)
    src = f_srcSelect(srcMode, o, h, l, c)

    r1 = bench1 != 0 ? src / bench1 * 100.0 : na
    r2 = bench2 != 0 ? src / bench2 * 100.0 : na
    r3 = bench3 != 0 ? src / bench3 * 100.0 : na
    r4 = bench4 != 0 ? src / bench4 * 100.0 : na

    float wSum = 0.0
    float rSum = 0.0
    if not na(r1)
        wSum += w1
        rSum += r1 * w1
    if not na(r2)
        wSum += w2
        rSum += r2 * w2
    if not na(r3)
        wSum += w3
        rSum += r3 * w3
    if not na(r4)
        wSum += w4
        rSum += r4 * w4
    ratio = wSum > 0 ? rSum / wSum : na

    ratioSmooth = ta.sma(ratio, rLen)
    ratioStdev  = ta.stdev(ratio, rLen)
    rsRatio = (na(ratioStdev) or ratioStdev == 0) ? 100.0 : 100.0 + (ratio - ratioSmooth) / ratioStdev * 10.0
    rsMomentum = (na(ratioStdev) or ratioStdev == 0) ? 100.0 : 100.0 + (rsRatio - rsRatio[mLen]) / ratioStdev * 10.0

    tr = math.max(h - l, math.max(math.abs(h - c[1]), math.abs(l - c[1])))
    atrNow = ta.rma(tr, aLen)
    atrBase = ta.sma(atrNow, aBaseLen)
    atrCompression = (na(atrBase) or atrBase == 0) ? 1.0 : atrNow / atrBase

    pressHigh = ta.highest(h, pLen)
    pressLow  = ta.lowest(l, pLen)
    pressRange = pressHigh - pressLow
    pressure = pressRange == 0 ? 0.0 : ((c - pressLow) - (pressHigh - c)) / pressRange * 100.0

    ph = ta.pivothigh(h, pivLen, pivLen)
    pl = ta.pivotlow(l, pivLen, pivLen)
    var float lastPh = na
    var float lastPl = na
    if not na(ph)
        lastPh := ph
    if not na(pl)
        lastPl := pl
    float structScore = 0.0
    if not na(lastPh) and c > lastPh
        structScore := 1.0
    else if not na(lastPl) and c < lastPl
        structScore := -1.0

    momDevNorm = math.min(1.0, math.abs(rsMomentum - 100.0) / 20.0)
    compressionScore = math.max(0.0, math.min(1.0, 1.0 - atrCompression))
    pressureNorm = math.min(1.0, math.abs(pressure) / 100.0)
    structBonus = math.abs(structScore)

    probability = math.min(100.0, momDevNorm * 35.0 + compressionScore * 25.0 + pressureNorm * 25.0 + structBonus * 15.0)
    direction = rsRatio >= 100 ? 1 : -1

    [rsRatio, rsMomentum, atrCompression, pressure, structScore, probability, direction]

// ─────────────────────────────────────────────────────────────────────────
// SESSION VWAP ANCHOR  (CSVWAP method, simplified to a daily reset)
// ─────────────────────────────────────────────────────────────────────────
grpVwap = "Anchor: VWAP"
vwapResetDaily = input.bool(true, "Reset Each Trading Day", group = grpVwap, tooltip = "CSVWAP's full comma-separated multi-schedule reset (specific hours/minutes/days/months) is available as a future option if a finer session boundary is ever needed — this uses a straightforward daily reset.")

newDay = ta.change(time("D")) != 0
var float sumPV  = 0.0
var float sumV   = 0.0
var float sumPPV = 0.0
resetNow = vwapResetDaily and newDay
sumPV  := resetNow ? hlc3 * volume : sumPV + hlc3 * volume
sumV   := resetNow ? volume : sumV + volume
sumPPV := resetNow ? volume * hlc3 * hlc3 : sumPPV + volume * hlc3 * hlc3

vwapVal = sumV > 0 ? sumPV / sumV : na
vwapVariance = sumV > 0 ? sumPPV / sumV - vwapVal * vwapVal : na
vwapVarianceClamped = na(vwapVariance) ? na : math.max(0.0, vwapVariance)
vwapStdev = na(vwapVarianceClamped) ? na : math.sqrt(vwapVarianceClamped)

// ─────────────────────────────────────────────────────────────────────────
// ALTERNATE ANCHOR — adapted from the uploaded "AI Trend Navigator" (KNN
// nearest-neighbor smoothed trend line). Off by default (VWAP is lighter);
// a simplified adaptation — the source script's full price/target dropdown
// matrix is collapsed to fixed hl2/close inputs to keep the added input
// surface reasonable.
// ─────────────────────────────────────────────────────────────────────────
grpAnchor = "Anchor Line"
grpAnchorMode = "Anchor Mode"
anchorMode = input.string("VWAP", "Select Anchor Algorithm", options = ["VWAP", "KNN Trend (AI Trend Navigator)", "Dynamic Flow Ribbons (Adaptive Trail)", "Hull MA (BCeyhan)", "Twin Range Filter", "Ichimoku Kijun", "EMA Trend (Smart Money)", "Quantum Field Center (Fibonacci)", "HAFT Harmonic RMA", "Blackflag ATR Trail", "CoffeeShopCrypto Adaptive SuperTrend"], group = grpAnchorMode)
grpAnchorKNN = "Anchor: KNN Trend (AI Trend Navigator)"
knnMaLen      = input.int(5, "KNN Price Smoothing Length", minval = 2, maxval = 200, group = grpAnchorKNN)
knnTargetLen  = input.int(5, "KNN Target Smoothing Length", minval = 2, maxval = 200, group = grpAnchorKNN)
knnNeighbors  = input.int(3, "KNN Number of Closest Values", minval = 2, maxval = 200, group = grpAnchorKNN)
knnWindow = math.max(knnNeighbors, 30)

f_meanOfKClosest(float value_, float target_, int numClosest, int windowSize) =>
    closestDistances = array.new_float(numClosest, 1e10)
    closestValues    = array.new_float(numClosest, 0.0)
    for i = 1 to windowSize
        value = value_[i]
        distance = math.abs(target_ - value)
        maxDistIndex = 0
        maxDistValue = closestDistances.get(0)
        for j = 1 to numClosest - 1
            if closestDistances.get(j) > maxDistValue
                maxDistIndex := j
                maxDistValue := closestDistances.get(j)
        if distance < maxDistValue
            closestDistances.set(maxDistIndex, distance)
            closestValues.set(maxDistIndex, value)
    closestValues.sum() / numClosest

knnValueIn  = ta.sma(hl2, knnMaLen)
knnTargetIn = ta.rma(close, knnTargetLen)
knnMA = f_meanOfKClosest(knnValueIn, knnTargetIn, knnNeighbors, knnWindow)

// ─────────────────────────────────────────────────────────────────────────
// THIRD ANCHOR OPTION — adapted from the uploaded "Dynamic Flow Ribbons
// [BigBeluga]" (adaptive EMA/ATR trailing-stop trend line with direction
// flip — the same style of mechanism as a SuperTrend, computed on this
// chart's own price only, same as the VWAP and KNN options).
// ─────────────────────────────────────────────────────────────────────────
grpAnchorDFR = "Anchor: Dynamic Flow Ribbons (Adaptive Trail)"
dfrFactor = input.float(3.0, "DFR Trail Factor", step = 0.01, group = grpAnchorDFR)
dfrDist = ta.sma(high - low, 200)
dfrSrc = hlc3
dfrUpperRaw = ta.ema(dfrSrc, 15) + dfrFactor * dfrDist
dfrLowerRaw = ta.ema(dfrSrc, 15) - dfrFactor * dfrDist
var float dfrUpperBand = na
var float dfrLowerBand = na
dfrPrevLower = nz(dfrLowerBand[1])
dfrPrevUpper = nz(dfrUpperBand[1])
dfrLowerBand := dfrLowerRaw > dfrPrevLower or dfrSrc[1] < dfrPrevLower ? dfrLowerRaw : dfrPrevLower
dfrUpperBand := dfrUpperRaw < dfrPrevUpper or dfrSrc[1] > dfrPrevUpper ? dfrUpperRaw : dfrPrevUpper

var int dfrDirection = 1
var float dfrTrendLine = na
dfrPrevTrendLine = dfrTrendLine[1]
if na(dfrDist[1])
    dfrDirection := 1
else if dfrPrevTrendLine == dfrPrevUpper
    dfrDirection := dfrSrc > dfrUpperBand ? -1 : 1
else
    dfrDirection := dfrSrc < dfrLowerBand ? 1 : -1
dfrTrendLine := dfrDirection == -1 ? dfrLowerBand : dfrUpperBand
dfrLine = math.avg(dfrLowerBand, dfrUpperBand)

// ─────────────────────────────────────────────────────────────────────────
// MORE ANCHOR OPTIONS
// ─────────────────────────────────────────────────────────────────────────

// Hull MA (from "BCeyhan Hull System")
grpAnchorHull = "Anchor: Hull MA (BCeyhan)"
hullLen = input.int(14, "Hull MA Length", minval = 2, group = grpAnchorHull)
hullAnchor = ta.wma(2 * ta.wma(close, hullLen / 2) - ta.wma(close, hullLen), math.round(math.sqrt(hullLen)))

// Twin Range Filter (adaptive smoothed range filter with trailing logic)
grpAnchorTRF = "Anchor: Twin Range Filter"
trfPer1 = input.int(27, "Twin Range Fast Period", minval = 1, group = grpAnchorTRF)
trfMult1 = input.float(1.6, "Twin Range Fast Mult", minval = 0.1, group = grpAnchorTRF)
trfPer2 = input.int(55, "Twin Range Slow Period", minval = 1, group = grpAnchorTRF)
trfMult2 = input.float(2.0, "Twin Range Slow Mult", minval = 0.1, group = grpAnchorTRF)

f_smoothrng(float x, int t, float m) =>
    wper = t * 2 - 1
    avrng = ta.ema(math.abs(x - x[1]), t)
    ta.ema(avrng, wper) * m

trfSmrng1 = f_smoothrng(close, trfPer1, trfMult1)
trfSmrng2 = f_smoothrng(close, trfPer2, trfMult2)
trfSmrng = (trfSmrng1 + trfSmrng2) / 2.0

var float trfFilt = na
trfFiltPrev = nz(trfFilt[1])
trfFilt := close > trfFiltPrev ? (close - trfSmrng < trfFiltPrev ? trfFiltPrev : close - trfSmrng) : (close + trfSmrng > trfFiltPrev ? trfFiltPrev : close + trfSmrng)

// Ichimoku Kijun (from "Ichimoku [LucF]")
grpAnchorIchimoku = "Anchor: Ichimoku Kijun"
kijunLen = input.int(26, "Ichimoku Kijun Length", minval = 2, group = grpAnchorIchimoku)
ichiKijun = math.avg(ta.lowest(low, kijunLen), ta.highest(high, kijunLen))

// EMA Trend (from "Smart Money Trend Engine")
grpAnchorEMA = "Anchor: EMA Trend (Smart Money)"
emaTrendLen = input.int(200, "Smart Money EMA Trend Length", minval = 5, group = grpAnchorEMA)
emaTrendAnchor = ta.ema(close, emaTrendLen)

// Quantum Field Center (from "Sequences of Fibonacci")
grpAnchorQF = "Anchor: Quantum Field Center (Fibonacci)"
qfLen = input.int(13, "Quantum Field EMA Length", minval = 2, group = grpAnchorQF)
qfCenter = ta.ema(close, qfLen)

// ─────────────────────────────────────────────────────────────────────────
// MORE ANCHOR OPTIONS
// ─────────────────────────────────────────────────────────────────────────

// HAFT Harmonic RMA (from "HAFT Acceleration") — the underlying centered-
// hexagonal-number RMA baseline, used here as a smoothed trend line rather
// than its original %-deviation oscillator form.
grpAnchorHAFT = "Anchor: HAFT Harmonic RMA"
haftLen = input.int(7, "HAFT RMA Base Period", minval = 2, group = grpAnchorHAFT)
haftHarmonic = input.int(1, "HAFT Harmonic Multiplier", minval = 1, maxval = 7, group = grpAnchorHAFT)
haftRma = ta.rma(hlc3, haftLen * haftHarmonic)

// Blackflag ATR Trail (from "Blackflag FTS") — Wilder's ATR-based chandelier-
// style trailing stop with directional ratchet.
grpAnchorBlackflag = "Anchor: Blackflag ATR Trail"
bfAtrPeriod = input.int(28, "Blackflag ATR Period", minval = 2, group = grpAnchorBlackflag)
bfAtrFactor = input.float(5.0, "Blackflag ATR Factor", minval = 0.5, group = grpAnchorBlackflag)

f_wildMa(float src, int len) =>
    var float wild = na
    wild := nz(wild[1]) + (src - nz(wild[1])) / len
    wild

bfHiLo = math.min(high - low, 1.5 * nz(ta.sma(high - low, bfAtrPeriod)))
bfHRef = low <= high[1] ? high - close[1] : (high - close[1]) - 0.5 * (low - high[1])
bfLRef = high >= low[1] ? close[1] - low : (close[1] - low) - 0.5 * (low[1] - high)
bfTrueRange = math.max(bfHiLo, math.max(bfHRef, bfLRef))
bfLoss = bfAtrFactor * f_wildMa(bfTrueRange, bfAtrPeriod)

var float bfTrendUp = na
var float bfTrendDown = na
bfUp = close - bfLoss
bfDn = close + bfLoss
bfTrendUp := close[1] > nz(bfTrendUp[1]) ? math.max(bfUp, nz(bfTrendUp[1])) : bfUp
bfTrendDown := close[1] < nz(bfTrendDown[1]) ? math.min(bfDn, nz(bfTrendDown[1])) : bfDn

var int bfTrend = 1
bfTrend := close > nz(bfTrendDown[1]) ? 1 : close < nz(bfTrendUp[1]) ? -1 : nz(bfTrend[1], 1)
blackflagTrail = bfTrend == 1 ? bfTrendUp : bfTrendDown

// ─────────────────────────────────────────────────────────────────────────
// MORE ANCHOR OPTIONS
// ─────────────────────────────────────────────────────────────────────────
grpAnchorCSC = "Anchor: CoffeeShopCrypto Adaptive SuperTrend"

// Adaptive SuperTrend (from "CoffeeShopCrypto Supertrend Liquidity Engine")
// The ATR multiplier isn't fixed — it steps through 4 zones based on how
// today's ATR compares to the PRIOR SESSION's ATR, so the stop tightens or
// loosens with actual volatility context instead of a single guessed factor.
cscAtrLen = input.int(20, "CSC ATR Length", minval = 2, group = grpAnchorCSC)
cscTf = input.timeframe("D", "CSC Prior-Session Timeframe", group = grpAnchorCSC)
cscPriorAtr = request.security(syminfo.tickerid, cscTf, ta.atr(cscAtrLen)[1], lookahead = barmerge.lookahead_on)
cscCurrentAtr = ta.atr(cscAtrLen)

f_cscDynamicFactor(float curAtr, float priorAtr) =>
    float zoneSize = priorAtr / 4.0
    float factor = 1.0
    if curAtr <= zoneSize * 1.0
        factor := 5.0
    else if curAtr <= zoneSize * 2.0
        factor := 3.0
    else if curAtr <= zoneSize * 3.0
        factor := 1.5
    else
        factor := 1.0
    factor

cscFactor = f_cscDynamicFactor(cscCurrentAtr, cscPriorAtr)
[cscSupertrend, cscDirection] = ta.supertrend(cscFactor, cscAtrLen)

float anchorVal = vwapVal
if anchorMode == "KNN Trend (AI Trend Navigator)"
    anchorVal := knnMA
else if anchorMode == "Dynamic Flow Ribbons (Adaptive Trail)"
    anchorVal := dfrLine
else if anchorMode == "Hull MA (BCeyhan)"
    anchorVal := hullAnchor
else if anchorMode == "Twin Range Filter"
    anchorVal := trfFilt
else if anchorMode == "Ichimoku Kijun"
    anchorVal := ichiKijun
else if anchorMode == "EMA Trend (Smart Money)"
    anchorVal := emaTrendAnchor
else if anchorMode == "Quantum Field Center (Fibonacci)"
    anchorVal := qfCenter
else if anchorMode == "HAFT Harmonic RMA"
    anchorVal := haftRma
else if anchorMode == "Blackflag ATR Trail"
    anchorVal := blackflagTrail
else if anchorMode == "CoffeeShopCrypto Adaptive SuperTrend"
    anchorVal := cscSupertrend

// ─────────────────────────────────────────────────────────────────────────
// ALTERNATE ENVELOPE — adapted from the uploaded "AI Channels (Clustering)"
// (K-means clustering of recent closes into K bands; upper/lower cluster
// centroids become the envelope). Off by default — this is the heavier of
// the two additions (up to 500 iterations/bar even with its own safety
// caps), on top of a script that already runs 20 simultaneous multi-symbol
// data requests. If you enable this and hit memory limits again, reducing
// the number of enabled instruments is the most direct way to make room.
// ─────────────────────────────────────────────────────────────────────────
grpEnvelope = "Envelope Shape"
grpEnvelopeMode = "Envelope Mode"
envelopeMode = input.string("Statistical (StDev)", "Select Envelope Algorithm", options = ["Statistical (StDev)", "AI Clusters (K-Means)", "UCS Snapback ATR Bands", "Ichimoku Kumo Cloud", "Quantum Field (Fibonacci)", "Donchian Channel", "Prior Day High/Low", "Foundry Auction Corridor", "Keltner Channel"], group = grpEnvelopeMode, tooltip = "K-Means is computationally heavier than the statistical option — see the note in this script's header comment before enabling it alongside many active instruments.")

grpEnvelopeStat = "Envelope: Statistical (StDev)"
stdevMult = input.float(1.0, "Base Envelope Width (x stdev)", minval = 0.1, step = 0.1, group = grpEnvelopeStat)
grpEnvelopeKMeans = "Envelope: AI Clusters (K-Means)"
kmeansLength = input.int(30, "K-Means Window Size", group = grpEnvelopeKMeans)
kmeansK      = input.int(5, "K-Means Clusters", minval = 3, maxval = 10, group = grpEnvelopeKMeans)
kmeansMaxIter = input.int(500, "K-Means Max Iterations", minval = 0, group = grpEnvelopeKMeans)
kmeansMaxData = input.int(5000, "K-Means Historical Bars Cap", minval = 0, group = grpEnvelopeKMeans)

type kmVector
    array<float> out

kmData = array.new<float>(0)
if envelopeMode == "AI Clusters (K-Means)" and last_bar_index - bar_index <= kmeansMaxData
    for i = 0 to kmeansLength - 1
        kmData.push(close[i])

kmCentroids = array.new<float>(0)
if envelopeMode == "AI Clusters (K-Means)"
    for i = 1 to kmeansK
        per = int(i / (kmeansK + 1) * 100)
        kmCentroids.push(kmData.percentile_linear_interpolation(per))

var array<kmVector> kmClusters = na

if envelopeMode == "AI Clusters (K-Means)" and last_bar_index - bar_index <= kmeansMaxData
    for _ = 0 to kmeansMaxIter
        kmClusters := array.new<kmVector>(0)
        for i = 0 to kmeansK - 1
            kmClusters.push(kmVector.new(array.new<float>(0)))

        for value in kmData
            dist = array.new<float>(0)
            for centroid in kmCentroids
                dist.push(math.abs(value - centroid))
            idx = dist.indexof(dist.min())
            if idx != -1
                kmClusters.get(idx).out.push(value)

        new_centroids = array.new<float>(0)
        for cluster_ in kmClusters
            new_centroids.push(cluster_.out.avg())

        if new_centroids.get(0) == kmCentroids.get(0) and new_centroids.get(1) == kmCentroids.get(1) and new_centroids.get(2) == kmCentroids.get(2)
            break
        kmCentroids := new_centroids

float kmUpper = na
float kmLower = na
if envelopeMode == "AI Clusters (K-Means)" and not na(kmClusters)
    kmUpper := nz(kmCentroids.get(kmeansK - 1), close)
    kmLower := nz(kmCentroids.get(0), close)


// ─────────────────────────────────────────────────────────────────────────
// MORE ENVELOPE OPTIONS
// ─────────────────────────────────────────────────────────────────────────

// UCS Snapback ATR deviation bands (outermost/high-probability tier)
grpEnvelopeUCS = "Envelope: UCS Snapback ATR Bands"
ucsLen1 = input.int(7, "UCS Snapback Fast Length", minval = 2, group = grpEnvelopeUCS)
ucsLen2 = input.int(14, "UCS Snapback Mid Length", minval = 2, group = grpEnvelopeUCS)
ucsLen3 = input.int(21, "UCS Snapback Slow Length", minval = 2, group = grpEnvelopeUCS)
ucsMa2 = ta.sma(ohlc4, ucsLen2)
ucsRng1 = ta.sma(ta.tr, ucsLen1)
ucsRng2 = ta.sma(ta.tr, ucsLen2)
ucsRng3 = ta.sma(ta.tr, ucsLen3)
ucsUp3 = ucsMa2 + ucsRng3 * 3.2
ucsDn3 = ucsMa2 - ucsRng2 * 3.2

// Ichimoku Kumo Cloud (naturally asymmetric upper/lower)
grpEnvelopeKumo = "Envelope: Ichimoku Kumo Cloud"
kumoTenkanLen = input.int(9, "Ichimoku Tenkan Length", minval = 2, group = grpEnvelopeKumo)
kumoBLen = input.int(52, "Ichimoku Kumo B Length", minval = 2, group = grpEnvelopeKumo)
kumoTenkan = math.avg(ta.lowest(low, kumoTenkanLen), ta.highest(high, kumoTenkanLen))
kumoA = math.avg(kumoTenkan, ichiKijun)
kumoB = math.avg(ta.lowest(low, kumoBLen), ta.highest(high, kumoBLen))
kumoUpper = math.max(kumoA, kumoB)
kumoLower = math.min(kumoA, kumoB)

// Quantum Field amplitude (simplified — the original's full "unified field" blends
// price momentum, volume momentum, and trend strength; this keeps that structure
// but with lighter sub-calculations to control added cost)
qfAtr = ta.atr(14)
qfPriceMom = ta.roc(close, 10)
qfVolMom = ta.roc(ta.sma(volume, 5), 10)
qfTrendStrength = (ta.ema(close, 20) - ta.ema(close, 50)) / ta.ema(close, 50) * 100
qfUnifiedField = (qfPriceMom * 0.4 + qfVolMom * 0.2 + qfTrendStrength * 1.0) / 3.0
qfAmplitude = qfAtr * (1.0 + math.abs(qfUnifiedField) / 10.0) * 1.618

// ─────────────────────────────────────────────────────────────────────────
// MORE ENVELOPE OPTIONS
// ─────────────────────────────────────────────────────────────────────────

// Donchian Channel (from "VIX Bars")
grpEnvelopeDonch = "Envelope: Donchian Channel"
donchLen = input.int(52, "Donchian Channel Length", minval = 2, group = grpEnvelopeDonch)
donchUpper = ta.highest(high, donchLen)
donchLower = ta.lowest(low, donchLen)

// Prior Day High/Low (from "AI-Enhanced MSS Hunter")
[pdHigh, pdLow] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead = barmerge.lookahead_off)

// Foundry Auction Corridor (from "Foundry Range Ledger [JOAT]") — simplified
// to its core ceiling/floor concept: the tightest of a fast/slow range pair.
grpEnvelopeFoundry = "Envelope: Foundry Auction Corridor"
foundryFastLen = input.int(10, "Foundry Fast Range Length", minval = 2, group = grpEnvelopeFoundry)
foundrySlowLen = input.int(30, "Foundry Slow Range Length", minval = 2, group = grpEnvelopeFoundry)
foundryFastHi = ta.highest(high, foundryFastLen)
foundryFastLo = ta.lowest(low, foundryFastLen)
foundrySlowHi = ta.highest(high, foundrySlowLen)
foundrySlowLo = ta.lowest(low, foundrySlowLen)
foundryCeiling = math.min(foundryFastHi, foundrySlowHi)
foundryFloor = math.max(foundryFastLo, foundrySlowLo)

// ─────────────────────────────────────────────────────────────────────────
// MORE ENVELOPE OPTIONS
// ─────────────────────────────────────────────────────────────────────────
grpEnvelopeKeltner = "Envelope: Keltner Channel"

// Keltner Channel (from "ScalpMaster Pro") — basis EMA ± ATR multiple
kcLen = input.int(20, "Keltner EMA Length", minval = 2, group = grpEnvelopeKeltner)
kcAtrLen = input.int(10, "Keltner ATR Length", minval = 2, group = grpEnvelopeKeltner)
kcMult = input.float(2.0, "Keltner Multiplier", minval = 0.1, step = 0.1, group = grpEnvelopeKeltner)
kcBasis = ta.ema(close, kcLen)
kcAtrVal = ta.atr(kcAtrLen)
kcUpper = kcBasis + kcMult * kcAtrVal
kcLower = kcBasis - kcMult * kcAtrVal

// ─────────────────────────────────────────────────────────────────────────
// INSTRUMENTS + PER-INSTRUMENT ENGINE — placed last among the settings
// groups by design (see conversation), so Anchor and Envelope algorithm
// settings all appear before the 16-instrument roster in the panel.
// ─────────────────────────────────────────────────────────────────────────
gInstr = "Instruments  (Enable | Symbol | Source | Weight)"

nqOn   = input.bool(true, "NQ", group = gInstr, inline = "i1")
nqSym  = input.symbol("CME_MINI:NQ1!", "", group = gInstr, inline = "i1")
nqSrc  = input.string("Close", "", options = ["Close", "Open", "HL2", "HLC3", "OHLC4"], group = gInstr, inline = "i1")
nqWt   = input.float(1.0, "", minval = 0.0, step = 0.1, group = gInstr, inline = "i1")

esOn   = input.bool(true, "ES", group = gInstr, inline = "i2")
esSym  = input.symbol("CME_MINI:ES1!", "", group = gInstr, inline = "i2")
esSrc  = input.string("Close", "", options = ["Close", "Open", "HL2", "HLC3", "OHLC4"], group = gInstr, inline = "i2")
esWt   = input.float(1.0, "", minval = 0.0, step = 0.1, group = gInstr, inline = "i2")

ymOn   = input.bool(true, "YM", group = gInstr, inline = "i3")
ymSym  = input.symbol("CBOT_MINI:YM1!", "", group = gInstr, inline = "i3")
ymSrc  = input.string("Close", "", options = ["Close", "Open", "HL2", "HLC3", "OHLC4"], group = gInstr, inline = "i3")
ymWt   = input.float(1.0, "", minval = 0.0, step = 0.1, group = gInstr, inline = "i3")

rtyOn   = input.bool(true, "RTY", group = gInstr, inline = "i4")
rtySym  = input.symbol("CME_MINI:RTY1!", "", group = gInstr, inline = "i4")
rtySrc  = input.string("Close", "", options = ["Close", "Open", "HL2", "HLC3", "OHLC4"], group = gInstr, inline = "i4")
rtyWt   = input.float(1.0, "", minval = 0.0, step = 0.1, group = gInstr, inline = "i4")

gcOn   = input.bool(true, "GC", group = gInstr, inline = "i5")
gcSym  = input.symbol("COMEX:GC1!", "", group = gInstr, inline = "i5")
gcSrc  = input.string("Close", "", options = ["Close", "Open", "HL2", "HLC3", "OHLC4"], group = gInstr, inline = "i5")
gcWt   = input.float(1.0, "", minval = 0.0, step = 0.1, group = gInstr, inline = "i5")

sOn   = input.bool(true, "S", group = gInstr, inline = "i6")
sSym  = input.symbol("CBOT:ZS1!", "", group = gInstr, inline = "i6")
sSrc  = input.string("Close", "", options = ["Close", "Open", "HL2", "HLC3", "OHLC4"], group = gInstr, inline = "i6")
sWt   = input.float(1.0, "", minval = 0.0, step = 0.1, group = gInstr, inline = "i6")

iOn   = input.bool(true, "I", group = gInstr, inline = "i7")
iSym  = input.symbol("COMEX:SI1!", "", group = gInstr, inline = "i7")
iSrc  = input.string("Close", "", options = ["Close", "Open", "HL2", "HLC3", "OHLC4"], group = gInstr, inline = "i7")
iWt   = input.float(1.0, "", minval = 0.0, step = 0.1, group = gInstr, inline = "i7")

hgOn   = input.bool(true, "HG", group = gInstr, inline = "i8")
hgSym  = input.symbol("COMEX:HG1!", "", group = gInstr, inline = "i8")
hgSrc  = input.string("Close", "", options = ["Close", "Open", "HL2", "HLC3", "OHLC4"], group = gInstr, inline = "i8")
hgWt   = input.float(1.0, "", minval = 0.0, step = 0.1, group = gInstr, inline = "i8")

btcOn   = input.bool(true, "BTC", group = gInstr, inline = "i9")
btcSym  = input.symbol("CME:BTC1!", "", group = gInstr, inline = "i9")
btcSrc  = input.string("Close", "", options = ["Close", "Open", "HL2", "HLC3", "OHLC4"], group = gInstr, inline = "i9")
btcWt   = input.float(1.0, "", minval = 0.0, step = 0.1, group = gInstr, inline = "i9")

ethOn   = input.bool(true, "ETH", group = gInstr, inline = "i10")
ethSym  = input.symbol("CME:ETH1!", "", group = gInstr, inline = "i10")
ethSrc  = input.string("Close", "", options = ["Close", "Open", "HL2", "HLC3", "OHLC4"], group = gInstr, inline = "i10")
ethWt   = input.float(1.0, "", minval = 0.0, step = 0.1, group = gInstr, inline = "i10")

nkdOn   = input.bool(true, "NKD", group = gInstr, inline = "i11")
nkdSym  = input.symbol("CME:NKD1!", "", group = gInstr, inline = "i11")
nkdSrc  = input.string("Close", "", options = ["Close", "Open", "HL2", "HLC3", "OHLC4"], group = gInstr, inline = "i11")
nkdWt   = input.float(1.0, "", minval = 0.0, step = 0.1, group = gInstr, inline = "i11")

hhiOn   = input.bool(true, "HHI", group = gInstr, inline = "i12")
hhiSym  = input.symbol("HKEX:HSI1!", "", group = gInstr, inline = "i12")
hhiSrc  = input.string("Close", "", options = ["Close", "Open", "HL2", "HLC3", "OHLC4"], group = gInstr, inline = "i12")
hhiWt   = input.float(1.0, "", minval = 0.0, step = 0.1, group = gInstr, inline = "i12")

vixOn   = input.bool(true, "VIX", group = gInstr, inline = "i13")
vixSym  = input.symbol("CBOE:VIX", "", group = gInstr, inline = "i13")
vixSrc  = input.string("Close", "", options = ["Close", "Open", "HL2", "HLC3", "OHLC4"], group = gInstr, inline = "i13")
vixWt   = input.float(1.0, "", minval = 0.0, step = 0.1, group = gInstr, inline = "i13")

clOn   = input.bool(true, "CL", group = gInstr, inline = "i14")
clSym  = input.symbol("NYMEX:CL1!", "", group = gInstr, inline = "i14")
clSrc  = input.string("Close", "", options = ["Close", "Open", "HL2", "HLC3", "OHLC4"], group = gInstr, inline = "i14")
clWt   = input.float(1.0, "", minval = 0.0, step = 0.1, group = gInstr, inline = "i14")

fxxpOn   = input.bool(true, "FXXP", group = gInstr, inline = "i15")
fxxpSym  = input.symbol("ICEEUR:Z1!", "", group = gInstr, inline = "i15")
fxxpSrc  = input.string("Close", "", options = ["Close", "Open", "HL2", "HLC3", "OHLC4"], group = gInstr, inline = "i15")
fxxpWt   = input.float(1.0, "", minval = 0.0, step = 0.1, group = gInstr, inline = "i15")

mwlOn   = input.bool(true, "MWL", group = gInstr, inline = "i16")
mwlSym  = input.symbol("CBOT:ZW1!", "", group = gInstr, inline = "i16")
mwlSrc  = input.string("Close", "", options = ["Close", "Open", "HL2", "HLC3", "OHLC4"], group = gInstr, inline = "i16")
mwlWt   = input.float(1.0, "", minval = 0.0, step = 0.1, group = gInstr, inline = "i16")

// ─────────────────────────────────────────────────────────────────────────
// CALL METRICS FOR EACH INSTRUMENT (disabled rows substitute SPX symbol)
// ─────────────────────────────────────────────────────────────────────────
[nqRat, nqMom, nqComp, nqPress, nqStruct, nqProb, nqDir] = f_instrumentMetrics(nqOn ? nqSym : spxSym, nqSrc, b1, b2, b3, b4, bw1, bw2, bw3, bw4, rsLen, momLen, atrLen, atrBaseLen, pressLen, pivotLen)
[esRat, esMom, esComp, esPress, esStruct, esProb, esDir] = f_instrumentMetrics(esOn ? esSym : spxSym, esSrc, b1, b2, b3, b4, bw1, bw2, bw3, bw4, rsLen, momLen, atrLen, atrBaseLen, pressLen, pivotLen)
[ymRat, ymMom, ymComp, ymPress, ymStruct, ymProb, ymDir] = f_instrumentMetrics(ymOn ? ymSym : spxSym, ymSrc, b1, b2, b3, b4, bw1, bw2, bw3, bw4, rsLen, momLen, atrLen, atrBaseLen, pressLen, pivotLen)
[rtyRat, rtyMom, rtyComp, rtyPress, rtyStruct, rtyProb, rtyDir] = f_instrumentMetrics(rtyOn ? rtySym : spxSym, rtySrc, b1, b2, b3, b4, bw1, bw2, bw3, bw4, rsLen, momLen, atrLen, atrBaseLen, pressLen, pivotLen)
[gcRat, gcMom, gcComp, gcPress, gcStruct, gcProb, gcDir] = f_instrumentMetrics(gcOn ? gcSym : spxSym, gcSrc, b1, b2, b3, b4, bw1, bw2, bw3, bw4, rsLen, momLen, atrLen, atrBaseLen, pressLen, pivotLen)
[sRat, sMom, sComp, sPress, sStruct, sProb, sDir] = f_instrumentMetrics(sOn ? sSym : spxSym, sSrc, b1, b2, b3, b4, bw1, bw2, bw3, bw4, rsLen, momLen, atrLen, atrBaseLen, pressLen, pivotLen)
[iRat, iMom, iComp, iPress, iStruct, iProb, iDir] = f_instrumentMetrics(iOn ? iSym : spxSym, iSrc, b1, b2, b3, b4, bw1, bw2, bw3, bw4, rsLen, momLen, atrLen, atrBaseLen, pressLen, pivotLen)
[hgRat, hgMom, hgComp, hgPress, hgStruct, hgProb, hgDir] = f_instrumentMetrics(hgOn ? hgSym : spxSym, hgSrc, b1, b2, b3, b4, bw1, bw2, bw3, bw4, rsLen, momLen, atrLen, atrBaseLen, pressLen, pivotLen)
[btcRat, btcMom, btcComp, btcPress, btcStruct, btcProb, btcDir] = f_instrumentMetrics(btcOn ? btcSym : spxSym, btcSrc, b1, b2, b3, b4, bw1, bw2, bw3, bw4, rsLen, momLen, atrLen, atrBaseLen, pressLen, pivotLen)
[ethRat, ethMom, ethComp, ethPress, ethStruct, ethProb, ethDir] = f_instrumentMetrics(ethOn ? ethSym : spxSym, ethSrc, b1, b2, b3, b4, bw1, bw2, bw3, bw4, rsLen, momLen, atrLen, atrBaseLen, pressLen, pivotLen)
[nkdRat, nkdMom, nkdComp, nkdPress, nkdStruct, nkdProb, nkdDir] = f_instrumentMetrics(nkdOn ? nkdSym : spxSym, nkdSrc, b1, b2, b3, b4, bw1, bw2, bw3, bw4, rsLen, momLen, atrLen, atrBaseLen, pressLen, pivotLen)
[hhiRat, hhiMom, hhiComp, hhiPress, hhiStruct, hhiProb, hhiDir] = f_instrumentMetrics(hhiOn ? hhiSym : spxSym, hhiSrc, b1, b2, b3, b4, bw1, bw2, bw3, bw4, rsLen, momLen, atrLen, atrBaseLen, pressLen, pivotLen)
[vixRat, vixMom, vixComp, vixPress, vixStruct, vixProb, vixDir] = f_instrumentMetrics(vixOn ? vixSym : spxSym, vixSrc, b1, b2, b3, b4, bw1, bw2, bw3, bw4, rsLen, momLen, atrLen, atrBaseLen, pressLen, pivotLen)
[clRat, clMom, clComp, clPress, clStruct, clProb, clDir] = f_instrumentMetrics(clOn ? clSym : spxSym, clSrc, b1, b2, b3, b4, bw1, bw2, bw3, bw4, rsLen, momLen, atrLen, atrBaseLen, pressLen, pivotLen)
[fxxpRat, fxxpMom, fxxpComp, fxxpPress, fxxpStruct, fxxpProb, fxxpDir] = f_instrumentMetrics(fxxpOn ? fxxpSym : spxSym, fxxpSrc, b1, b2, b3, b4, bw1, bw2, bw3, bw4, rsLen, momLen, atrLen, atrBaseLen, pressLen, pivotLen)
[mwlRat, mwlMom, mwlComp, mwlPress, mwlStruct, mwlProb, mwlDir] = f_instrumentMetrics(mwlOn ? mwlSym : spxSym, mwlSrc, b1, b2, b3, b4, bw1, bw2, bw3, bw4, rsLen, momLen, atrLen, atrBaseLen, pressLen, pivotLen)
// ─────────────────────────────────────────────────────────────────────────
// NOISE FILTERING — applied per instrument before anything downstream uses it
// ─────────────────────────────────────────────────────────────────────────
nqProbFinal = useSmoothing ? f_superSmoother(nqProb, smoothLen) : nqProb
esProbFinal = useSmoothing ? f_superSmoother(esProb, smoothLen) : esProb
ymProbFinal = useSmoothing ? f_superSmoother(ymProb, smoothLen) : ymProb
rtyProbFinal = useSmoothing ? f_superSmoother(rtyProb, smoothLen) : rtyProb
gcProbFinal = useSmoothing ? f_superSmoother(gcProb, smoothLen) : gcProb
sProbFinal = useSmoothing ? f_superSmoother(sProb, smoothLen) : sProb
iProbFinal = useSmoothing ? f_superSmoother(iProb, smoothLen) : iProb
hgProbFinal = useSmoothing ? f_superSmoother(hgProb, smoothLen) : hgProb
btcProbFinal = useSmoothing ? f_superSmoother(btcProb, smoothLen) : btcProb
ethProbFinal = useSmoothing ? f_superSmoother(ethProb, smoothLen) : ethProb
nkdProbFinal = useSmoothing ? f_superSmoother(nkdProb, smoothLen) : nkdProb
hhiProbFinal = useSmoothing ? f_superSmoother(hhiProb, smoothLen) : hhiProb
vixProbFinal = useSmoothing ? f_superSmoother(vixProb, smoothLen) : vixProb
clProbFinal = useSmoothing ? f_superSmoother(clProb, smoothLen) : clProb
fxxpProbFinal = useSmoothing ? f_superSmoother(fxxpProb, smoothLen) : fxxpProb
mwlProbFinal = useSmoothing ? f_superSmoother(mwlProb, smoothLen) : mwlProb
// ─────────────────────────────────────────────────────────────────────────
// AGGREGATION — the 16 instruments compressed into two drivers: Composite
// lean (direction) and Confluence % (how vivid/tight the ribbon renders)
// ─────────────────────────────────────────────────────────────────────────
float totalWeight = 0.0
float weightedProbSum = 0.0
int bullCount = 0
int bearCount = 0
int enabledCount = 0
int confluenceHighCount = 0
if nqOn
    totalWeight += nqWt
    weightedProbSum += nqWt * nqProbFinal
    enabledCount += 1
    if nqDir > 0
        bullCount += 1
    else
        bearCount += 1
    if nqProbFinal >= probHigh
        confluenceHighCount += 1
if esOn
    totalWeight += esWt
    weightedProbSum += esWt * esProbFinal
    enabledCount += 1
    if esDir > 0
        bullCount += 1
    else
        bearCount += 1
    if esProbFinal >= probHigh
        confluenceHighCount += 1
if ymOn
    totalWeight += ymWt
    weightedProbSum += ymWt * ymProbFinal
    enabledCount += 1
    if ymDir > 0
        bullCount += 1
    else
        bearCount += 1
    if ymProbFinal >= probHigh
        confluenceHighCount += 1
if rtyOn
    totalWeight += rtyWt
    weightedProbSum += rtyWt * rtyProbFinal
    enabledCount += 1
    if rtyDir > 0
        bullCount += 1
    else
        bearCount += 1
    if rtyProbFinal >= probHigh
        confluenceHighCount += 1
if gcOn
    totalWeight += gcWt
    weightedProbSum += gcWt * gcProbFinal
    enabledCount += 1
    if gcDir > 0
        bullCount += 1
    else
        bearCount += 1
    if gcProbFinal >= probHigh
        confluenceHighCount += 1
if sOn
    totalWeight += sWt
    weightedProbSum += sWt * sProbFinal
    enabledCount += 1
    if sDir > 0
        bullCount += 1
    else
        bearCount += 1
    if sProbFinal >= probHigh
        confluenceHighCount += 1
if iOn
    totalWeight += iWt
    weightedProbSum += iWt * iProbFinal
    enabledCount += 1
    if iDir > 0
        bullCount += 1
    else
        bearCount += 1
    if iProbFinal >= probHigh
        confluenceHighCount += 1
if hgOn
    totalWeight += hgWt
    weightedProbSum += hgWt * hgProbFinal
    enabledCount += 1
    if hgDir > 0
        bullCount += 1
    else
        bearCount += 1
    if hgProbFinal >= probHigh
        confluenceHighCount += 1
if btcOn
    totalWeight += btcWt
    weightedProbSum += btcWt * btcProbFinal
    enabledCount += 1
    if btcDir > 0
        bullCount += 1
    else
        bearCount += 1
    if btcProbFinal >= probHigh
        confluenceHighCount += 1
if ethOn
    totalWeight += ethWt
    weightedProbSum += ethWt * ethProbFinal
    enabledCount += 1
    if ethDir > 0
        bullCount += 1
    else
        bearCount += 1
    if ethProbFinal >= probHigh
        confluenceHighCount += 1
if nkdOn
    totalWeight += nkdWt
    weightedProbSum += nkdWt * nkdProbFinal
    enabledCount += 1
    if nkdDir > 0
        bullCount += 1
    else
        bearCount += 1
    if nkdProbFinal >= probHigh
        confluenceHighCount += 1
if hhiOn
    totalWeight += hhiWt
    weightedProbSum += hhiWt * hhiProbFinal
    enabledCount += 1
    if hhiDir > 0
        bullCount += 1
    else
        bearCount += 1
    if hhiProbFinal >= probHigh
        confluenceHighCount += 1
if vixOn
    totalWeight += vixWt
    weightedProbSum += vixWt * vixProbFinal
    enabledCount += 1
    if vixDir > 0
        bullCount += 1
    else
        bearCount += 1
    if vixProbFinal >= probHigh
        confluenceHighCount += 1
if clOn
    totalWeight += clWt
    weightedProbSum += clWt * clProbFinal
    enabledCount += 1
    if clDir > 0
        bullCount += 1
    else
        bearCount += 1
    if clProbFinal >= probHigh
        confluenceHighCount += 1
if fxxpOn
    totalWeight += fxxpWt
    weightedProbSum += fxxpWt * fxxpProbFinal
    enabledCount += 1
    if fxxpDir > 0
        bullCount += 1
    else
        bearCount += 1
    if fxxpProbFinal >= probHigh
        confluenceHighCount += 1
if mwlOn
    totalWeight += mwlWt
    weightedProbSum += mwlWt * mwlProbFinal
    enabledCount += 1
    if mwlDir > 0
        bullCount += 1
    else
        bearCount += 1
    if mwlProbFinal >= probHigh
        confluenceHighCount += 1
compositeProb = totalWeight > 0 ? weightedProbSum / totalWeight : na
netLean = bullCount - bearCount
isBullLean = netLean >= 0
confluencePct = enabledCount > 0 ? confluenceHighCount / enabledCount * 100.0 : 0.0
leanColorBase = isBullLean ? bullColor : bearColor
leanColorAccent = isBullLean ? bullAccent : bearAccent

// ─────────────────────────────────────────────────────────────────────────
// RIBBON RENDERING
// ─────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────
// SIGNAL STRENGTH — combines Confluence (how many instruments agree) with
// Composite (how strong the underlying reading is) into one score. This
// drives fade, width, layer count, and candle intensity everywhere below,
// instead of confluence alone — so a high-magnitude reading with weak
// agreement, or strong agreement on a weak reading, both get pulled back
// toward "don't over-trust this," and only true strong+aligned readings
// get the full vivid, tight, fully-populated ribbon treatment.
// ─────────────────────────────────────────────────────────────────────────
signalStrength = math.max(0.0, math.min(100.0, (confluencePct + nz(compositeProb, 0.0)) / 2.0))

dynamicWidth  = input.bool(false, "Dynamic Width (tighten bands with strength)", group = grpRibbon, tooltip = "Off by default: bands stay a fixed width, like classic deviation/stdev lines. Turn on to let Signal Strength tighten the bands as conviction rises — more visually dramatic, but can make the ribbon read as unusually tight/compressed most of the time.")
dynamicLayers = input.bool(false, "Dynamic Layer Count (hide bands when weak)", group = grpRibbon, tooltip = "Off by default: all selected Ribbon Layers always render, like classic deviation lines. Turn on to have weak Signal Strength hide outer layers entirely, showing only the strongest reading as a fully-populated ribbon.")

visibleLayers = dynamicLayers ? math.max(1, math.round(ribbonLayers * signalStrength / 100.0)) : ribbonLayers
widthMult = dynamicWidth ? (1.5 - signalStrength / 100.0) : 1.0

float envelopeUpBase = 0.0
float envelopeDnBase = 0.0
if envelopeMode == "AI Clusters (K-Means)" and not na(kmUpper) and not na(kmLower)
    envelopeUpBase := math.max(0.0, (kmUpper - anchorVal)) * widthMult
    envelopeDnBase := math.max(0.0, (anchorVal - kmLower)) * widthMult
else if envelopeMode == "UCS Snapback ATR Bands"
    envelopeUpBase := math.max(0.0, (ucsUp3 - anchorVal)) * widthMult
    envelopeDnBase := math.max(0.0, (anchorVal - ucsDn3)) * widthMult
else if envelopeMode == "Ichimoku Kumo Cloud"
    envelopeUpBase := math.max(0.0, (kumoUpper - anchorVal)) * widthMult
    envelopeDnBase := math.max(0.0, (anchorVal - kumoLower)) * widthMult
else if envelopeMode == "Quantum Field (Fibonacci)"
    envelopeUpBase := qfAmplitude * widthMult
    envelopeDnBase := qfAmplitude * widthMult
else if envelopeMode == "Donchian Channel"
    envelopeUpBase := math.max(0.0, (donchUpper - anchorVal)) * widthMult
    envelopeDnBase := math.max(0.0, (anchorVal - donchLower)) * widthMult
else if envelopeMode == "Prior Day High/Low"
    envelopeUpBase := math.max(0.0, (pdHigh - anchorVal)) * widthMult
    envelopeDnBase := math.max(0.0, (anchorVal - pdLow)) * widthMult
else if envelopeMode == "Foundry Auction Corridor"
    envelopeUpBase := math.max(0.0, (foundryCeiling - anchorVal)) * widthMult
    envelopeDnBase := math.max(0.0, (anchorVal - foundryFloor)) * widthMult
else if envelopeMode == "Keltner Channel"
    envelopeUpBase := math.max(0.0, (kcUpper - anchorVal)) * widthMult
    envelopeDnBase := math.max(0.0, (anchorVal - kcLower)) * widthMult
else
    float statBase = na(vwapStdev) ? 0.0 : vwapStdev * stdevMult * widthMult
    envelopeUpBase := statBase
    envelopeDnBase := statBase

p_vwap = plot(anchorVal, "Anchor Line", color = color.new(color.gray, 20), linewidth = 2)

// Fixed 8-layer maximum per side (Pine requires a static plot() count); layers
// beyond the user's "Ribbon Layers" setting are fed na so they simply don't render.

up1Val = 1 <= visibleLayers ? anchorVal + envelopeUpBase * 1 / ribbonLayers : na
up1Col = f_layerColor(leanColorBase, leanColorAccent, 0, ribbonLayers, signalStrength)
up2Val = 2 <= visibleLayers ? anchorVal + envelopeUpBase * 2 / ribbonLayers : na
up2Col = f_layerColor(leanColorBase, leanColorAccent, 1, ribbonLayers, signalStrength)
up3Val = 3 <= visibleLayers ? anchorVal + envelopeUpBase * 3 / ribbonLayers : na
up3Col = f_layerColor(leanColorBase, leanColorAccent, 2, ribbonLayers, signalStrength)
up4Val = 4 <= visibleLayers ? anchorVal + envelopeUpBase * 4 / ribbonLayers : na
up4Col = f_layerColor(leanColorBase, leanColorAccent, 3, ribbonLayers, signalStrength)

dn1Val = 1 <= visibleLayers ? anchorVal - envelopeDnBase * 1 / ribbonLayers : na
dn1Col = f_layerColor(leanColorBase, leanColorAccent, 0, ribbonLayers, signalStrength)
dn2Val = 2 <= visibleLayers ? anchorVal - envelopeDnBase * 2 / ribbonLayers : na
dn2Col = f_layerColor(leanColorBase, leanColorAccent, 1, ribbonLayers, signalStrength)
dn3Val = 3 <= visibleLayers ? anchorVal - envelopeDnBase * 3 / ribbonLayers : na
dn3Col = f_layerColor(leanColorBase, leanColorAccent, 2, ribbonLayers, signalStrength)
dn4Val = 4 <= visibleLayers ? anchorVal - envelopeDnBase * 4 / ribbonLayers : na
dn4Col = f_layerColor(leanColorBase, leanColorAccent, 3, ribbonLayers, signalStrength)

p_up1 = plot(up1Val, "Ribbon Up 1", color = up1Col, linewidth = 1)
p_up2 = plot(up2Val, "Ribbon Up 2", color = up2Col, linewidth = 1)
p_up3 = plot(up3Val, "Ribbon Up 3", color = up3Col, linewidth = 1)
p_up4 = plot(up4Val, "Ribbon Up 4", color = up4Col, linewidth = 1)
p_dn1 = plot(dn1Val, "Ribbon Down 1", color = dn1Col, linewidth = 1)
p_dn2 = plot(dn2Val, "Ribbon Down 2", color = dn2Col, linewidth = 1)
p_dn3 = plot(dn3Val, "Ribbon Down 3", color = dn3Col, linewidth = 1)
p_dn4 = plot(dn4Val, "Ribbon Down 4", color = dn4Col, linewidth = 1)
fill(p_vwap, p_up1, color = up1Col, title = "Fill VWAP-Up1")
fill(p_up1, p_up2, color = up2Col, title = "Fill Up1-Up2")
fill(p_up2, p_up3, color = up3Col, title = "Fill Up2-Up3")
fill(p_up3, p_up4, color = up4Col, title = "Fill Up3-Up4")
fill(p_vwap, p_dn1, color = dn1Col, title = "Fill VWAP-Down1")
fill(p_dn1, p_dn2, color = dn2Col, title = "Fill Down1-Down2")
fill(p_dn2, p_dn3, color = dn3Col, title = "Fill Down2-Down3")
fill(p_dn3, p_dn4, color = dn4Col, title = "Fill Down3-Down4")
// ─────────────────────────────────────────────────────────────────────────
// CANDLE COLORING — direction by Composite lean, vividness by Confluence %
// (technique from Dynamic Flow Ribbons' direction-based plotcandle, driven
// here by the multi-instrument composite rather than a single trailing stop)
// ─────────────────────────────────────────────────────────────────────────
candleAlpha = math.round(math.max(5, 90 - signalStrength * 0.9))
candleCol = color.new(isBullLean ? bullColor : bearColor, candleAlpha)
plotcandle(showCandles ? open : na, showCandles ? high : na, showCandles ? low : na, showCandles ? close : na, title = "Composite-Colored Candles", color = candleCol, wickcolor = candleCol, bordercolor = candleCol)

// ─────────────────────────────────────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 7, bgcolor = colBg, border_width = 1, border_color = color.new(color.gray, 70))
compositeColor = na(compositeProb) ? colNeutral : compositeProb >= probHigh ? colClimax : compositeProb >= probMed ? colUp : colNeutral
leanText = isBullLean ? "BULLISH LEAN" : "BEARISH LEAN"
if showDash and barstate.islast
    table.cell(dash, 0, 0, "Composite", text_color = color.gray, text_size = labelSize)
    table.cell(dash, 1, 0, na(compositeProb) ? "—" : str.tostring(compositeProb, "#") + "%", text_color = compositeColor, text_size = labelSize)
    table.cell(dash, 0, 1, "Lean", text_color = color.gray, text_size = labelSize)
    table.cell(dash, 1, 1, leanText + " (" + str.tostring(bullCount) + "▲/" + str.tostring(bearCount) + "▼)", text_color = color.white, text_size = labelSize)
    table.cell(dash, 0, 2, "Confluence", text_color = color.gray, text_size = labelSize)
    table.cell(dash, 1, 2, str.tostring(confluencePct, "#") + "% (" + str.tostring(confluenceHighCount) + "/" + str.tostring(enabledCount) + ")", text_color = confluencePct >= probMed ? colClimax : color.gray, text_size = labelSize)
    table.cell(dash, 0, 3, "Signal Strength", text_color = color.gray, text_size = labelSize)
    strengthColor = signalStrength >= probHigh ? colClimax : signalStrength >= probMed ? colUp : color.gray
    table.cell(dash, 1, 3, str.tostring(signalStrength, "#") + "%  (" + str.tostring(visibleLayers) + "/" + str.tostring(ribbonLayers) + " layers)", text_color = strengthColor, text_size = labelSize)
    table.cell(dash, 0, 4, "Ribbon Width x", text_color = color.gray, text_size = labelSize)
    table.cell(dash, 1, 4, str.tostring(widthMult, "#.##"), text_color = color.white, text_size = labelSize)
    table.cell(dash, 0, 5, "Anchor Mode", text_color = color.gray, text_size = labelSize)
    table.cell(dash, 1, 5, anchorMode, text_color = color.white, text_size = labelSize)
    table.cell(dash, 0, 6, "Envelope Mode", text_color = color.gray, text_size = labelSize)
    table.cell(dash, 1, 6, envelopeMode, text_color = color.white, text_size = labelSize)

// ─────────────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────────────
alertcondition(not na(compositeProb) and compositeProb >= probHigh, "Composite High Probability", "Multi-Instrument Flow Ribbon: composite crossed the high threshold.")
alertcondition(confluencePct >= probHigh and confluencePct[1] < probHigh, "Real Confluence Detected", "Multi-Instrument Flow Ribbon: strong agreement across enabled instruments — ribbon should be reading vivid and tight.")
````
