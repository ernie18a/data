# Auto Andrews' Pitchfork  Adaptive Channel

- url: https://www.tradingview.com/script/zRD4hNzf-Auto-Andrews-Pitchfork-Adaptive-Channel/
- type: indicator
- pine_id: PUB;90137c9c6e5741f0ad2a33577910b7a6
- version: 1.0

## Description

# Auto Andrews' Pitchfork — Adaptive Median-Line Channel, Regime & Calibration

## What it is

On TradingView an Andrews' Pitchfork is a manual drawing tool: you place three points by hand and it draws a median line with two parallel tines. This script automates that geometry and, more importantly, surrounds the raw lines with the decision context a drawn pitchfork can never give you — whether the channel currently fits the market, whether a touch is likely to revert or break, and how the median and tines have actually behaved on the symbol you are looking at.

It detects the swing pivots, builds the channel, auto-selects the variation (Standard / Schiff / Modified Schiff) whose median best bisects the recent price path, and then runs a regime, reversion, break-strength and calibration stack on top of that one channel. It works on any symbol and any timeframe; every raw-data series is user-selectable in Settings.

## Why these components are combined (how the parts work together)

A bare auto-pitchfork only answers "where are the lines." On its own it shows the same picture in a quiet range, where price rotates back to the median, and in a strong trend, where price rides a tine and keeps going — the classic median-line failure. Every layer in this script exists to remove one specific blind spot of the bare geometry, and each layer feeds the next. They are not independent indicators stacked together; they are all derived from, or applied to, the same auto-built channel.

- **Auto-geometry (pivot detection + variation fit)** draws the channel and chooses the variation that best fits the actual price path, so the median is meaningful rather than an arbitrary hand placement.
- **Regime (efficiency ratio + ADX + volatility clustering)** decides whether a tine touch should be expected to fade (revert) or be ridden (continue) — the question the geometry alone cannot answer.
- **Reversion math (variance ratio + Ornstein-Uhlenbeck half-life)** is the statistical check on that decision: is the series actually mean-reverting, and if so, in roughly how many bars does a stretch to the median decay.
- **Break-strength scoring** rates how decisive a move beyond a tine is — magnitude versus ATR, volume participation, range expansion, the close's position within the bar (an anti-wick check), and a compression-then-release pattern. This turns "price crossed the tine" into a graded Fade / Ride / Invalid read instead of a binary one.
- **Volume nodes (POC, HVN/LVN)** classify whether each tine sits on a high-volume acceptance shelf (reaction likely) or a low-volume gap (likely sliced through), so proximity becomes a quality read.
- **Confluence (anchored VWAP, volume POC, higher-timeframe swing levels)** marks where the auto-geometry agrees with independent reference levels.
- **Calibration** measures, past-only, how often the median and each tine were actually respected on this symbol, reported with Wilson confidence intervals and a containment percentage, so the reliability read is earned from data rather than assumed.

The histogram of these reads is the synthesis: the dashboard ranks and states the channel's current condition in plain terms, but every figure is descriptive context, never a trade instruction.

## How to use it

1. Add it to any chart and set your data sources under "Data Source (any market)." For symbols with no native volume (some cash indices and FX feeds), enter a volume-bearing proxy in "Borrow volume from symbol."
2. Read the channel as a map: the median is equilibrium, the tines are the channel edges, and the warning lines mark over-extension.
3. Read the Status row: FADE means expect rotation inside the channel; RIDE means a strong break in a trend (the tine is being ridden); INVALID means the channel broke and a re-anchor is expected.
4. Use Regime, Half-life and Var-ratio to judge whether a tine touch is a fade or a continuation; use the volume-node tag and Confluence to judge whether a level is likely to hold; use Respect and Containment to judge whether the fork fits this symbol at all.
5. Treat every value as probabilistic context to combine with your own analysis and risk management.

## Optional context (off by default)

Two optional layers extend the tool without cluttering the default view:

Higher-timeframe context forks overlay lightweight median-and-tine outlines of the same auto-geometry on 5× and/or 15× the chart timeframe, so you can see how the current channel sits inside the larger structure. Only the higher-timeframe pivots are pulled (non-repainting, confirmed bars), and the outlines are drawn in time coordinates so they align across resolutions. They are intentionally minimal — no fills, glow, or analytics — because the full regime, break-strength and calibration stack stays on the current-timeframe fork, which is the one the dashboard describes. Enable them only when you want the multi-scale picture; on very high chart timeframes a 15× resolution can be non-standard and that outline will not populate.

Re-anchor on break lets a fresh fork begin building from post-break structure whenever the channel is invalidated, rather than only when new prominent pivots form. The broken channel stays on screen (dashed) until enough post-break pivots confirm to render the new one — there is an inherent pivot-confirmation lag, so the new fork appears a few bars after the break, not at the exact break bar. A minimum-bars guard prevents repeated re-anchoring in choppy conditions.

## Settings for any market

The High, Low and Price source inputs select the raw series the engine runs on, so it is not tied to one instrument. The volume-borrow input is blank by default and only activates on symbols that truly report no native volume. All optional layers degrade gracefully when their data is unavailable, and a data-health read flags when volume is unreliable.

## Originality

This is an original implementation. The contribution is not any single layer but the closed loop built around an automatically generated pitchfork: auto-geometry feeds a regime and break-strength engine that classifies the channel state, a half-life and variance-ratio core that quantifies reversion, volume-node context that grades each tine, and a past-only calibration tracker that reports how the lines have actually behaved — all from the one channel, rather than as separate tools placed side by side.

## Limitations (honest)

Pivots confirm after the configured right-bars lag and are non-repainting by construction. Volume-based layers require real volume. Calibration figures are descriptive of past behaviour only — they are not a backtest and not a probability of future results. Every read is probabilistic context.

## Disclaimer

This is a study / indicator for chart analysis and education only. It is not a strategy, not a recommendation, and not financial advice. It places no orders and guarantees no result. Markets involve risk, and a level's past behaviour does not assure future behaviour. Do your own research and manage your own risk.

## Source Code

````pine
// =============================================================================
//  AUTO ANDREWS' PITCHFORK — Adaptive Median-Line Channel, Regime & Calibration
//  shorttitle: Auto Pitchfork                                       Pine Script v6
// -----------------------------------------------------------------------------
//  WHAT THIS SCRIPT DOES
//    On TradingView an Andrews' Pitchfork (a median-line channel) is a manual
//    drawing tool: you place three points by hand and it draws a median line
//    with two parallel tines. This script AUTOMATES that geometry — it detects the swing pivots,
//    builds the channel for you, and then surrounds the raw geometry with the
//    context a drawn pitchfork can never give you: whether the channel currently
//    fits, whether a touch is likely to revert or break, and how its own lines
//    have actually behaved on this symbol in the past. It works on any symbol and
//    any timeframe; every raw-data series is user-selectable in Settings.
//
//  WHY THESE COMPONENTS ARE COMBINED  (mashup rationale — please read)
//    A raw auto-pitchfork only answers "where are the lines." On its own it gives
//    the same picture in a quiet range (where price rotates back to the median)
//    and in a strong trend (where price rides a tine and keeps going) — the
//    classic median-line failure. Each layer below exists to remove ONE specific
//    blind spot of the bare geometry, and every layer feeds the next; they are
//    not independent indicators stacked together:
//      * AUTO-GEOMETRY (pivots + variation fit) draws the channel and picks the
//        Standard / Schiff / Modified-Schiff variation that best bisects the
//        actual price path, so the median is meaningful rather than arbitrary.
//      * REGIME (efficiency ratio + ADX + volatility clustering) decides whether
//        a tine touch should be expected to FADE (revert) or be RIDDEN (trend),
//        which is the question the geometry alone cannot answer.
//      * REVERSION MATH (variance ratio + Ornstein-Uhlenbeck half-life) is the
//        statistical check on that decision: is the series actually mean-
//        reverting, and if so, in how many bars.
//      * BREAK-STRENGTH scores how decisive a move beyond a tine is (magnitude,
//        participation, range expansion, close position, compression-release),
//        turning "price crossed the tine" into FADE / RIDE / INVALID.
//      * VOLUME NODES classify whether each tine sits on a high-volume acceptance
//        shelf (reaction likely) or a low-volume gap (likely sliced through).
//      * CONFLUENCE (anchored VWAP, volume POC, higher-timeframe swing levels)
//        marks where the geometry agrees with independent reference levels.
//      * CALIBRATION measures, past-only, how often the median and tines were
//        actually respected on THIS symbol, with confidence intervals, so the
//        reliability read is earned rather than assumed.
//    The geometry is the raw material; every other layer transforms that same
//    structure into a context read, a classification, or an honest statistic.
//    That is why they live in one script rather than as separate indicators.
//
//  HOW TO USE
//    1. Add to any chart. Pick your data sources in "Data Source" (works on any
//       market; for no-volume symbols set a volume-bearing proxy to borrow from).
//    2. Read the channel as a map: median = equilibrium, tines = the channel
//       edges, warning lines = over-extension. The dashboard states the rest.
//    3. Status tells you the read: FADE = expect rotation inside the channel,
//       RIDE = a strong break in a trend (the tine is being ridden), INVALID =
//       the channel broke, re-anchor expected.
//    4. Use Regime, Half-life and Var-ratio to judge whether a tine touch is a
//       fade or a continuation; use the volume-node tag and Confluence to judge
//       whether a level is likely to hold; use Respect / Containment to judge
//       whether the fork fits this symbol at all.
//    5. Treat every figure as descriptive context, never as a trade instruction.
//
//  OPTIONAL CONTEXT
//    "Higher-Timeframe Context Forks" (default off) overlay lightweight median+
//    tine outlines of the same auto-geometry on 5x and/or 15x the chart timeframe,
//    so you can see how the current channel sits inside the larger structure; the
//    full analytics remain on the current-timeframe fork only. "Re-anchor on
//    break" lets a fresh fork begin building from post-break structure whenever
//    the channel is invalidated, instead of only on new prominent pivots.
//
//  INPUTS FOR ANY MARKET
//    "High / Low / Price source" select the raw series the engine runs on, so it
//    is not tied to one instrument. "Borrow volume from symbol" is blank by
//    default and only activates on symbols with no native volume. All optional
//    layers degrade gracefully if their data is unavailable.
//
//  ORIGINALITY
//    Original implementation. The novelty is not any single layer but the closed
//    loop: auto-geometry feeds a regime/break-strength engine that classifies the
//    channel state, a half-life / variance-ratio core that quantifies reversion,
//    and a past-only calibration tracker that reports how the lines actually
//    behaved — all derived from the one auto-built channel.
//
//  LIMITATIONS (honest)
//    Pivots confirm after the configured right-bars lag (non-repainting by
//    construction). Volume-based layers need real volume. Calibration figures are
//    descriptive of PAST behaviour only — they are not a backtest and not a
//    probability of future results. All reads are probabilistic context.
//
//  DISCLAIMER
//    Study / indicator for chart analysis and education only. NOT a strategy, NOT
//    a recommendation, and NOT financial advice. It places no orders and
//    guarantees no result. Markets involve risk; a level's past behaviour does
//    not assure future behaviour. Do your own research and manage your own risk.
// =============================================================================

//@version=6
indicator("Auto Andrews' Pitchfork — Adaptive Median-Line Channel, Regime & Calibration", "Auto Pitchfork", overlay = true,
     max_lines_count = 500, max_labels_count = 200, max_bars_back = 2000)

// ───────────────────────────── INPUTS ──────────────────────────────────────
gS = "Data Source (any market)"
srcHigh = input.source(high,  "High source (swing top)",   group = gS, tooltip = "Series used to find swing highs and measure upper-tine touches. Default = bar high. Lets the engine run on any instrument.")
srcLow  = input.source(low,   "Low source (swing bottom)", group = gS, tooltip = "Series used to find swing lows. Default = bar low.")
srcPx   = input.source(close, "Price source (position)",   group = gS, tooltip = "Series used for channel position, touches and alerts. Default = close.")
volBorrowSym = input.symbol("", "Borrow volume from symbol (no-volume fix)", group = gS, tooltip = "Optional, for symbols with no native volume (cash indices, some FX feeds). Enter a volume-bearing proxy for the same instrument (its future / continuous contract) and the volume layers use that. Only activates when the chart truly has no native volume. Blank = never borrow.")

gP = "Swing / Pivots"
leftBars   = input.int(13, "Pivot left bars",  minval = 1, group = gP)
rightBars  = input.int(13, "Pivot right bars", minval = 1, group = gP, tooltip = "Confirmation lag — pivots confirm this many bars after the fact (non-repainting).")
minPromATR = input.float(1.0, "Min swing prominence (× ATR)", minval = 0.0, step = 0.1, group = gP, tooltip = "A pivot anchors the fork only if the leg into it clears this many ATRs. Filters noise.")
pqTightWt  = input.float(0.6, "Anchor quality: prominence vs recency", minval = 0.0, maxval = 1.0, step = 0.05, group = gP, tooltip = "Anchor-quality score weight: prominence (significant legs) vs recency. 1 = all prominence, 0 = all recency.")

gF = "Pitchfork"
variationMode = input.string("Auto (best fit)", "Variation", options = ["Auto (best fit)", "Standard", "Schiff", "Modified Schiff"], group = gF, tooltip = "Auto picks the variation whose median best bisects the recent price path.")
projBars   = input.int(120, "Project forward (bars)", minval = 10, maxval = 400, group = gF)
showWarn   = input.bool(true,  "Warning lines (2× tine)", group = gF)
showFib    = input.bool(true,  "Inner 25% / 75% lines",  group = gF)
showCone   = input.bool(false, "Forward volatility cone", group = gF)

gReg = "Regime (4-state)"
erLen     = input.int(20, "Efficiency-ratio length", minval = 2, group = gReg)
erTrend   = input.float(0.30, "ER trend threshold", minval = 0.05, maxval = 0.95, step = 0.01, group = gReg)
adxLen    = input.int(14, "ADX length", minval = 2, group = gReg)
adxTrend  = input.float(20.0, "ADX trend threshold", minval = 5, maxval = 50, group = gReg)
regMaLen  = input.int(50, "Trend MA length", minval = 5, group = gReg)
normLen   = input.int(100, "Vol-cluster / VR window", minval = 20, group = gReg)
clustDecay= input.float(0.20, "Vol-cluster decay", minval = 0.02, maxval = 0.9, step = 0.01, group = gReg)
clustThr  = input.float(1.5, "Vol-cluster z threshold", minval = 0.5, maxval = 4.0, step = 0.1, group = gReg)
vrLen     = input.int(20, "Variance-ratio window", minval = 5, maxval = 100, group = gReg)

gBrk = "Break Strength & Fade/Ride"
embedBars  = input.int(5, "Embedded streak (closes beyond tine)", minval = 2, maxval = 30, group = gBrk, tooltip = "Consecutive closes beyond a tine before the channel is treated as broken.")
rideMinStr = input.int(3, "Min break strength for RIDE (0-5)", minval = 1, maxval = 5, group = gBrk, tooltip = "A break in a trend with at least this strength reads as RIDE (tine ridden); weaker breaks read as INVALID (re-anchor).")
breakMagATR= input.float(0.30, "Break magnitude (× ATR)", minval = 0.05, maxval = 2.0, step = 0.05, group = gBrk)
volPartMult= input.float(1.30, "Volume participation (× 20-avg)", minval = 1.0, maxval = 3.0, step = 0.05, group = gBrk)
rangeExpMult=input.float(1.50, "Range expansion (TR ÷ ATR)", minval = 1.0, maxval = 3.0, step = 0.1, group = gBrk)
antiWick   = input.float(0.70, "Anti-wick close position (0-1)", minval = 0.5, maxval = 0.95, step = 0.05, group = gBrk, tooltip = "Break bar must close this far into the favorable side of its range (no rejection wick).")
erCompShort= input.int(10, "Coil ER short window", minval = 3, maxval = 30, group = gBrk)
erCompLong = input.int(30, "Coil ER long window", minval = 10, maxval = 60, group = gBrk)
erCompThr  = input.float(0.30, "Coil 'was compressed' ER (≤)", minval = 0.1, maxval = 0.5, step = 0.05, group = gBrk)
usePolarity= input.bool(true, "Polarity flip (held-beyond tine → S/R)", group = gBrk)
reanchorOnBreak = input.bool(true, "Re-anchor a new fork on break (INVALID)", group = gBrk, tooltip = "When the channel breaks (INVALID), reset the anchoring window so a fresh fork builds only from post-break structure. The new fork renders once enough post-break pivots confirm (inherent pivot lag).")
reanchorMinBars = input.int(20, "Min bars between re-anchors", minval = 3, maxval = 300, group = gBrk, tooltip = "Guard against thrashing: ignore further break-triggered re-anchors for this many bars.")
reanchorPivLen = input.int(5, "Re-anchor pivot length (faster reform)", minval = 2, maxval = 30, group = gBrk, tooltip = "After a break the new fork uses this shorter, looser pivot length so it reforms quickly (seeded at the break point), then tightens as standard pivots confirm. Smaller = faster but less stable.")

gRev = "Reversion Math"
hlLen     = input.int(100, "Half-life window", minval = 20, maxval = 300, group = gRev, tooltip = "Window for the Ornstein-Uhlenbeck half-life estimate on the price-median spread.")
rrStopATR = input.float(0.5, "Reversion stop (× ATR beyond tine)", minval = 0.1, maxval = 3.0, step = 0.1, group = gRev)
stabThr   = input.float(2.0, "Fork-instability threshold (decayed re-anchors)", minval = 0.5, maxval = 6.0, step = 0.5, group = gRev)

gC = "Confluence"
useAVWAP   = input.bool(true,  "Anchored VWAP from origin", group = gC)
usePOC     = input.bool(true,  "Volume POC + HVN/LVN nodes", group = gC)
pocBins    = input.int(24, "POC / node resolution", minval = 8, maxval = 50, group = gC)
hvnPct     = input.float(80, "HVN percentile", minval = 55, maxval = 99, step = 1, group = gC, tooltip = "A tine on a bin above this percentile of volume sits on an acceptance shelf (reaction likely).")
lvnPct     = input.float(25, "LVN percentile", minval = 1, maxval = 45, step = 1, group = gC, tooltip = "A tine on a bin below this percentile sits in a volume gap (likely sliced through fast).")
useMTF     = input.bool(true,  "Higher-timeframe levels (non-repaint)", group = gC)
htfMult1   = input.int(3,  "HTF multiple 1", minval = 2, maxval = 60, group = gC)
htfMult2   = input.int(5,  "HTF multiple 2", minval = 2, maxval = 120, group = gC)
mtfLookback= input.int(60, "HTF swing lookback", minval = 10, group = gC)
confTolPct = input.float(0.10, "Base confluence tolerance (% price)", minval = 0.02, maxval = 1.0, step = 0.02, group = gC)
volLen     = input.int(20, "ATR-average length (adaptive tol)", minval = 5, group = gC)

gHTF = "Higher-Timeframe Context Forks"
showHTF    = input.bool(false, "Show higher-timeframe context forks", group = gHTF, tooltip = "Off by default. Overlays lightweight median+tine outlines of the pitchfork on higher timeframes (5× and/or 15× the chart). The full analytics (regime, break-strength, calibration) stay on the current-timeframe fork only.")
useHTF5    = input.bool(true,  "  5× pitchfork", group = gHTF)
useHTF15   = input.bool(true,  "  15× pitchfork", group = gHTF)
htfPivLen  = input.int(8, "  HTF pivot length (left/right)", minval = 2, group = gHTF)

gCal = "Calibration (past-only)"
calEnable  = input.bool(true,  "Track line respect-rate", group = gCal)
calHorizon = input.int(10, "Evaluation horizon (bars)", minval = 3, maxval = 100, group = gCal)
calMoveATR = input.float(0.5, "Min reaction (× ATR)", minval = 0.1, maxval = 3.0, step = 0.1, group = gCal)
calShowPanel = input.bool(false, "Show per-line calibration panel", group = gCal)
calPanelPos  = input.string("Bottom Right", "Panel position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gCal)

gStat = "Stretch / Confirmation"
robustStretch = input.bool(true, "Robust (median/MAD) stretch read", group = gStat)
statLen    = input.int(200, "Standardization window", minval = 20, group = gStat)
confirmClose = input.bool(true, "Confirm touches/alerts on bar close", group = gStat)

gV = "Visuals"
themeMode  = input.string("Auto (match chart)", "Theme", options = ["Auto (match chart)", "Dark", "Light"], group = gV)
glow       = input.bool(true,  "Glow", inline = "g", group = gV)
glowStr    = input.float(0.85, "strength", inline = "g", minval = 0.2, maxval = 1.6, step = 0.05, group = gV)
shade      = input.bool(true,  "Reversion-heat fill", group = gV)
bullCol    = input.color(#089981, "Bull / support", group = gV)
bearCol    = input.color(#f23645, "Bear / resistance", group = gV)
medColInp  = input.color(#ffd700, "Median (1x1)", group = gV)
showLabels = input.bool(true,  "Line labels", group = gV)
showTable  = input.bool(true,  "Snapshot table", group = gV)
tblPosStr  = input.string("Top Right", "Table position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gV)
showId     = input.bool(true,  "Identity strip (name · symbol · timeframe)", group = gV, tooltip = "Keeps the script name, symbol and timeframe visible on the chart.")

// ───────────────────────────── PURE HELPERS ────────────────────────────────
f_luma(color c) => na(c) ? 0.0 : color.r(c) * 0.299 + color.g(c) * 0.587 + color.b(c) * 0.114

f_pos(string s) =>
    switch s
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        => position.top_right

f_origin(int v, float p0b, float p0p, float p1b, float p1p) =>
    float ob = p0b
    float op = p0p
    if v == 1
        op := (p0p + p1p) / 2.0
    else if v == 2
        ob := (p0b + p1b) / 2.0
        op := (p0p + p1p) / 2.0
    [ob, op]

f_geo(int v, float p0b, float p0p, float p1b, float p1p, float p2b, float p2p) =>
    float mb = (p1b + p2b) / 2.0
    float mp = (p1p + p2p) / 2.0
    [ob, op] = f_origin(v, p0b, p0p, p1b, p1p)
    float sl = (mb - ob) != 0.0 ? (mp - op) / (mb - ob) : 0.0
    float o1 = p1p - (op + sl * (p1b - ob))
    float o2 = p2p - (op + sl * (p2b - ob))
    float upOff = math.max(o1, o2)
    float loOff = math.min(o1, o2)
    [ob, op, sl, upOff, loOff]

f_gline(int x1, float y1, int x2, float y2, color col, int w, string st, bool g, float gs, line[] store) =>
    if g
        int t1 = int(math.min(95, math.max(16, math.round((100 - 19 * gs) * 0.8))))
        int t2 = int(math.min(92, math.max(14, math.round((100 - 36 * gs) * 0.8))))
        array.push(store, line.new(x1, y1, x2, y2, xloc = xloc.bar_index, color = color.new(col, t1), width = w + 4))
        array.push(store, line.new(x1, y1, x2, y2, xloc = xloc.bar_index, color = color.new(col, t2), width = w + 2))
    line core = line.new(x1, y1, x2, y2, xloc = xloc.bar_index, color = col, width = w, style = st)
    array.push(store, core)
    core

f_wilson(int hits, int total) =>
    float lo = na
    float hi = na
    if total >= 5
        float p = hits / float(total)
        float z = 1.96
        float den = 1.0 + z * z / total
        float c = (p + z * z / (2.0 * total)) / den
        float h = z * math.sqrt(p * (1.0 - p) / total + z * z / (4.0 * total * total)) / den
        lo := math.max(0.0, c - h)
        hi := math.min(1.0, c + h)
    [lo, hi]

f_addPivot(int b, float p, bool isHigh, float atrv, float minProm, int[] sigB, float[] sigP, bool[] sigH) =>
    bool changed = false
    int n = array.size(sigH)
    if n == 0
        array.push(sigB, b)
        array.push(sigP, p)
        array.push(sigH, isHigh)
        changed := true
    else if array.get(sigH, n - 1) == isHigh
        float prev = array.get(sigP, n - 1)
        if (isHigh and p > prev) or (not isHigh and p < prev)
            array.set(sigB, n - 1, b)
            array.set(sigP, n - 1, p)
            changed := true
    else
        float prevP = array.get(sigP, n - 1)
        float leg = atrv > 0 ? math.abs(p - prevP) / atrv : 0.0
        if leg >= minProm
            array.push(sigB, b)
            array.push(sigP, p)
            array.push(sigH, isHigh)
            changed := true
            if array.size(sigH) > 6
                array.shift(sigB)
                array.shift(sigP)
                array.shift(sigH)
    changed

f_tfstr(int mult) =>
    int s = timeframe.in_seconds() * mult
    string r = s < 60 ? str.tostring(s) + "S" : s < 86400 ? str.tostring(int(s / 60)) : s < 604800 ? str.tostring(int(s / 86400)) + "D" : str.tostring(int(s / 604800)) + "W"
    r

htfHL(int n) => [ta.highest(srcHigh, n)[1], ta.lowest(srcLow, n)[1]]

htfPivots(int len) =>
    float hh = ta.pivothigh(srcHigh, len, len)
    float ll = ta.pivotlow(srcLow, len, len)
    int   tt = time[len]
    [hh, ll, tt]

f_drawHTFFork(int[] bt, float[] bp, bool[] bh, color col, string tag, int rightT, bool doLabel, line[] store, label[] lstore) =>
    int n = array.size(bh)
    if n >= 3
        float p0t = array.get(bt, n - 3)
        float p0p = array.get(bp, n - 3)
        float p1t = array.get(bt, n - 2)
        float p1p = array.get(bp, n - 2)
        float p2t = array.get(bt, n - 1)
        float p2p = array.get(bp, n - 1)
        [ob, op, sl, uo, lo] = f_geo(0, p0t, p0p, p1t, p1p, p2t, p2p)
        int x1 = int(p0t)
        float yL = op + sl * (p0t - ob)
        float yR = op + sl * (rightT - ob)
        array.push(store, line.new(x1, yL,      rightT, yR,      xloc = xloc.bar_time, color = col, width = 2))
        array.push(store, line.new(x1, yL + uo, rightT, yR + uo, xloc = xloc.bar_time, color = color.new(col, 45), width = 1))
        array.push(store, line.new(x1, yL + lo, rightT, yR + lo, xloc = xloc.bar_time, color = color.new(col, 45), width = 1))
        if doLabel
            array.push(lstore, label.new(rightT, yR, tag, xloc = xloc.bar_time, style = label.style_label_left, size = size.tiny, textcolor = col, color = color.new(col, 80)))

// ───────────────────────────── THEME ───────────────────────────────────────
_luma = f_luma(chart.bg_color)
uiDark = themeMode == "Dark" ? true : themeMode == "Light" ? false : (na(chart.bg_color) or _luma < 140)
uiBull = uiDark ? bullCol  : color.from_gradient(0.22, 0.0, 1.0, bullCol, color.black)
uiBear = uiDark ? bearCol  : color.from_gradient(0.18, 0.0, 1.0, bearCol, color.black)
uiMed  = uiDark ? medColInp: color.from_gradient(0.45, 0.0, 1.0, medColInp, color.black)
uiWarn = uiDark ? color.rgb(227, 179, 65) : color.rgb(176, 120, 0)
cPanel = uiDark ? color.rgb(10, 14, 26)  : color.rgb(244, 246, 248)
cSub   = uiDark ? color.rgb(22, 27, 34)  : color.rgb(233, 237, 242)
cTxt   = uiDark ? color.rgb(226, 232, 240): color.rgb(20, 26, 38)
cDim   = uiDark ? color.rgb(168, 178, 190): color.rgb(74, 82, 94)
cFrame = uiDark ? color.rgb(42, 52, 88)  : color.rgb(196, 204, 212)
cBord  = uiDark ? color.rgb(26, 34, 56)  : color.rgb(210, 216, 224)
uiAcc  = uiDark ? color.rgb(179, 157, 219): color.rgb(94, 53, 177)
labelBg= uiDark ? color.new(color.rgb(10, 14, 26), 20) : color.new(color.rgb(244, 246, 248), 14)

// ───────────────────────────── VOLUME (with borrow) ────────────────────────
var bool nativeVolSeen = false
if volume > 0
    nativeVolSeen := true
useBorrow = str.length(volBorrowSym) > 0 and not nativeVolSeen
volBorrowRaw = useBorrow ? request.security(volBorrowSym, timeframe.period, volume, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true) : na
volEff = useBorrow and not na(volBorrowRaw) ? volBorrowRaw : volume
bool volReliable = not na(volEff) and volEff > 0

// ───────────────────────────── CORE SERIES ─────────────────────────────────
atr = ta.atr(14)
atrSafe = atr > 0 ? atr : close * 0.001

erNum = math.abs(srcPx - srcPx[erLen])
erDen = math.sum(math.abs(srcPx - srcPx[1]), erLen)
er = erDen > 0 ? erNum / erDen : 0.0

// ── 4-state regime ──
[diP, diM, adx] = ta.dmi(adxLen, adxLen)
logRet = math.abs(nz(ta.change(math.log(close))))
var float clustI = 0.0
clustI := clustI * math.exp(-clustDecay) + logRet
hMean = ta.sma(clustI, normLen)
hStd  = ta.stdev(clustI, normLen)
clustZ = hStd != 0 ? (clustI - hMean) / hStd : 0.0
volCluster = clustZ > clustThr
trendMa = ta.ema(close, regMaLen)
bull = close > trendMa
trending = adx > adxTrend and er > erTrend
string regime = volCluster and not trending ? "Volatile" : trending ? (bull ? "Trend Up" : "Trend Dn") : "Range"
bool forkReliable = trending and not volCluster

// ── variance ratio ──
ret1 = nz(ta.change(math.log(close)))
retK = math.log(close) - math.log(nz(close[vrLen], close))
var1 = ta.variance(ret1, normLen)
varK = ta.variance(retK, normLen)
vr = var1 > 0 ? varK / (vrLen * var1) : 1.0
vrMeanRev = vr < 1.0

// ── break-strength ingredients ──
volAvg20 = ta.sma(volEff, 20)
volPartic = volReliable and not na(volAvg20) and volAvg20 > 0 and volEff >= volPartMult * volAvg20
trVal = ta.tr(true)
rangeExp = trVal > rangeExpMult * atrSafe and atr > nz(atr[1])
barRng = high - low
cpUp = barRng > 0 ? (close - low) / barRng : 0.5
cpDn = barRng > 0 ? (high - close) / barRng : 0.5
erCsNet = math.abs(close - close[erCompShort])
erCsPath = math.sum(math.abs(close - close[1]), erCompShort)
erCsV = erCsPath > 0 ? erCsNet / erCsPath : 0.0
erClNet = math.abs(close - close[erCompLong])
erClPath = math.sum(math.abs(close - close[1]), erCompLong)
erClV = erClPath > 0 ? erClNet / erClPath : 0.0
coilWasLow = nz(erClV[5], 1.0) <= erCompThr
coilRising = erCsV > nz(erCsV[3], 0.0)
coilRelease = coilWasLow and coilRising

// ── housekeeping ──
bool warmedUp = bar_index >= math.max(leftBars + rightBars, math.max(erLen, statLen)) + 5
sigConfirm = (not confirmClose) or barstate.isconfirmed

// ───────────────────────────── PIVOT BUFFER ────────────────────────────────
var int[]   sigB = array.new_int()
var float[] sigP = array.new_float()
var bool[]  sigH = array.new_bool()

var int blockPivotsBefore = 0
var bool reanchorPending = false
ph  = ta.pivothigh(srcHigh, leftBars, rightBars)
pl  = ta.pivotlow(srcLow,  leftBars, rightBars)
phF = ta.pivothigh(srcHigh, reanchorPivLen, reanchorPivLen)
plF = ta.pivotlow(srcLow,  reanchorPivLen, reanchorPivLen)

bool pivotChanged = false
if reanchorPending
    // faster, looser pivots so the new fork reforms quickly after a break
    bool aF = (bar_index - reanchorPivLen) >= blockPivotsBefore
    float promF = minPromATR * 0.4
    if not na(phF) and aF
        pivotChanged := f_addPivot(bar_index - reanchorPivLen, phF, true,  atrSafe, promF, sigB, sigP, sigH) or pivotChanged
    if not na(plF) and aF
        pivotChanged := f_addPivot(bar_index - reanchorPivLen, plF, false, atrSafe, promF, sigB, sigP, sigH) or pivotChanged
else
    bool aN = (bar_index - rightBars) >= blockPivotsBefore
    if not na(ph) and aN
        pivotChanged := f_addPivot(bar_index - rightBars, ph, true,  atrSafe, minPromATR, sigB, sigP, sigH) or pivotChanged
    if not na(pl) and aN
        pivotChanged := f_addPivot(bar_index - rightBars, pl, false, atrSafe, minPromATR, sigB, sigP, sigH) or pivotChanged

// ───────────────────────────── GEOMETRY STATE ──────────────────────────────
var bool  vHave  = false
var int   vVar   = 0
var float vOb    = na
var float vOp    = na
var float vSlope = na
var float vUpOff = na
var float vLoOff = na
var float vP0b   = na
var float vP1b   = na
var float vP2b   = na
var float vQual  = na

bool forkReanchored = false

if pivotChanged and array.size(sigH) >= 3
    int nn = array.size(sigH)
    float p0b = array.get(sigB, nn - 3)
    float p0p = array.get(sigP, nn - 3)
    float p1b = array.get(sigB, nn - 2)
    float p1p = array.get(sigP, nn - 2)
    float p2b = array.get(sigB, nn - 1)
    float p2p = array.get(sigP, nn - 1)

    int chosenV = 0
    if variationMode == "Standard"
        chosenV := 0
    else if variationMode == "Schiff"
        chosenV := 1
    else if variationMode == "Modified Schiff"
        chosenV := 2
    else
        float bestDev = 1e18
        for v = 0 to 2
            [ob_, op_, sl_, uo_, lo_] = f_geo(v, p0b, p0p, p1b, p1p, p2b, p2p)
            float dev = 0.0
            int cnt = 0
            int sb = math.max(int(p0b), bar_index - 500)
            for b = sb to bar_index
                float m = op_ + sl_ * (b - ob_)
                dev += math.abs(close[bar_index - b] - m)
                cnt += 1
            float dn = cnt > 0 ? dev / cnt : 1e18
            if dn < bestDev
                bestDev := dn
                chosenV := v

    [gob, gop, gsl, guo, glo] = f_geo(chosenV, p0b, p0p, p1b, p1p, p2b, p2p)
    vVar := chosenV
    vOb := gob
    vOp := gop
    vSlope := gsl
    vUpOff := guo
    vLoOff := glo
    vP0b := p0b
    vP1b := p1b
    vP2b := p2b
    vHave := true
    forkReanchored := true
    float leg1 = atrSafe > 0 ? math.abs(p1p - p0p) / atrSafe : 0.0
    float leg2 = atrSafe > 0 ? math.abs(p2p - p1p) / atrSafe : 0.0
    float promScore = math.min(1.0, ((leg1 + leg2) / 2.0) / math.max(minPromATR * 3.0, 0.5))
    float recScore = math.max(0.0, math.min(1.0, 1.0 - (bar_index - p2b) / 200.0))
    vQual := pqTightWt * promScore + (1.0 - pqTightWt) * recScore
    reanchorPending := false

bool haveFork = vHave

float medNow = na
float upNow  = na
float loNow  = na
float halfW  = na
float zPos   = na
if haveFork
    medNow := vOp + vSlope * (bar_index - vOb)
    upNow  := medNow + vUpOff
    loNow  := medNow + vLoOff
    halfW  := (vUpOff - vLoOff) / 2.0
    zPos   := halfW != 0.0 ? (srcPx - medNow) / halfW : 0.0

// fork stability — decayed re-anchor rate (high = unstable, lines low-confidence)
var float reanchorAcc = 0.0
reanchorAcc := reanchorAcc * math.exp(-0.15) + (forkReanchored ? 1.0 : 0.0)
bool forkUnstable = reanchorAcc > stabThr

// ── robust stretch ──
float devN = haveFork ? (srcPx - medNow) / atrSafe : 0.0
float medD = ta.percentile_linear_interpolation(devN, statLen, 50)
float madD = ta.percentile_linear_interpolation(math.abs(devN - medD), statLen, 50)
float robZ = (robustStretch and not na(madD) and madD != 0.0) ? 0.6745 * (devN - medD) / madD : zPos

// ── Ornstein-Uhlenbeck half-life on price-median spread ──
float spr = haveFork ? (srcPx - medNow) : 0.0
float spr1 = nz(spr[1], spr)
float mS = ta.sma(spr, hlLen)
float mS1 = ta.sma(spr1, hlLen)
float covS = ta.sma(spr * spr1, hlLen) - mS * mS1
float varS1 = ta.sma(spr1 * spr1, hlLen) - mS1 * mS1
float betaAR = varS1 > 0 ? covS / varS1 : na
float halfLife = (not na(betaAR) and betaAR > 0 and betaAR < 1) ? -math.log(2) / math.log(betaAR) : na

// ── embedded streak → break strength → FADE / RIDE / INVALID (inline) ──
var int embUp = 0
var int embDn = 0
embUp := (haveFork and zPos > 1.0) ? embUp + 1 : 0
embDn := (haveFork and zPos < -1.0) ? embDn + 1 : 0
bool embeddedUp = embUp >= embedBars
bool embeddedDn = embDn >= embedBars
bool broke = haveFork and (embeddedUp or embeddedDn)
bool brkUp = embeddedUp
int breakStr = 0
if broke
    float mag = brkUp ? (close - upNow) / atrSafe : (loNow - close) / atrSafe
    breakStr := breakStr + (mag >= breakMagATR ? 1 : 0)
    breakStr := breakStr + (volPartic ? 1 : 0)
    breakStr := breakStr + (rangeExp ? 1 : 0)
    breakStr := breakStr + ((brkUp ? cpUp : cpDn) >= antiWick ? 1 : 0)
    breakStr := breakStr + (coilRelease ? 1 : 0)
string forkState = not haveFork ? "—" : broke ? ((trending and breakStr >= rideMinStr) ? "RIDE" : "INVALID") : "FADE"
bool forkInvalid = forkState == "INVALID"
bool forkRiding  = forkState == "RIDE"

// ── polarity flip: tine held beyond flips role and is remembered as S/R ──
var float flipPx = na
var int   flipRole = 0
if usePolarity and forkRiding and na(flipPx)
    flipPx := brkUp ? upNow : loNow
    flipRole := brkUp ? 1 : -1
if not na(flipPx) and ((flipRole > 0 and close < flipPx) or (flipRole < 0 and close > flipPx))
    flipPx := na
    flipRole := 0
if forkReanchored
    flipPx := na
    flipRole := 0

// ── re-anchor a new fork when the channel breaks (INVALID), guarded vs thrashing ──
var int lastReanchorBar = -1000000
bool invalidEdge = forkInvalid and not forkInvalid[1]
if reanchorOnBreak and invalidEdge and (bar_index - lastReanchorBar) >= reanchorMinBars
    array.clear(sigB)
    array.clear(sigP)
    array.clear(sigH)
    blockPivotsBefore := bar_index
    lastReanchorBar := bar_index
    reanchorPending := true
    // seed the break extreme as the new fork's first anchor (head start)
    if brkUp
        f_addPivot(bar_index, srcHigh, true, 0.0, 0.0, sigB, sigP, sigH)
    else
        f_addPivot(bar_index, srcLow, false, 0.0, 0.0, sigB, sigP, sigH)

// ── containment % (current fork; resets on re-anchor) ──
var int contIn = 0
var int contTot = 0
if forkReanchored
    contIn := 0
    contTot := 0
if haveFork and barstate.isconfirmed
    contTot += 1
    if srcPx <= upNow and srcPx >= loNow
        contIn += 1
float containPct = contTot >= 5 ? contIn / float(contTot) * 100.0 : na

// ── reversion R:R (reference geometry only) ──
float rrStop = rrStopATR * atrSafe
float rrRev = na
if haveFork and not na(halfW)
    float nearT = zPos >= 0 ? upNow : loNow
    float rwd = math.abs(close - medNow)
    float rsk = math.abs(nearT - close) + rrStop
    rrRev := rsk > 0 ? rwd / rsk : na

// ───────────────────────────── MTF LEVELS (non-repaint) ────────────────────
htf1 = f_tfstr(htfMult1)
htf2 = f_tfstr(htfMult2)
[hh1, ll1] = request.security(syminfo.tickerid, htf1, htfHL(mtfLookback), lookahead = barmerge.lookahead_off)
[hh2, ll2] = request.security(syminfo.tickerid, htf2, htfHL(mtfLookback), lookahead = barmerge.lookahead_off)
int mtfAgree = 0
if useMTF and haveFork
    bool forkUp = vSlope > 0
    bool h1Up = not na(hh1) and not na(ll1) and close > (hh1 + ll1) / 2.0
    bool h2Up = not na(hh2) and not na(ll2) and close > (hh2 + ll2) / 2.0
    mtfAgree := (h1Up == forkUp ? 1 : 0) + (h2Up == forkUp ? 1 : 0)

// volatility-adaptive tolerance
float volAvg = ta.sma(atr, volLen)
float volRatio = (not na(volAvg) and volAvg > 0) ? atr / volAvg : 1.0
float volFactor = math.max(0.6, math.min(2.5, volRatio))

// ── higher-timeframe context-fork buffers (time-anchored, non-repaint) ──
var int[]   b5t  = array.new_int()
var float[] b5p  = array.new_float()
var bool[]  b5h  = array.new_bool()
var int[]   b15t = array.new_int()
var float[] b15p = array.new_float()
var bool[]  b15h = array.new_bool()
tf5s  = f_tfstr(5)
tf15s = f_tfstr(15)
[p5h, p5l, p5t]    = request.security(syminfo.tickerid, tf5s,  htfPivots(htfPivLen), lookahead = barmerge.lookahead_off)
[p15h, p15l, p15t] = request.security(syminfo.tickerid, tf15s, htfPivots(htfPivLen), lookahead = barmerge.lookahead_off)
if showHTF and useHTF5
    if not na(p5h) and (na(p5h[1]) or p5h != p5h[1])
        f_addPivot(int(p5t), p5h, true, 0.0, 0.0, b5t, b5p, b5h)
    if not na(p5l) and (na(p5l[1]) or p5l != p5l[1])
        f_addPivot(int(p5t), p5l, false, 0.0, 0.0, b5t, b5p, b5h)
if showHTF and useHTF15
    if not na(p15h) and (na(p15h[1]) or p15h != p15h[1])
        f_addPivot(int(p15t), p15h, true, 0.0, 0.0, b15t, b15p, b15h)
    if not na(p15l) and (na(p15l[1]) or p15l != p15l[1])
        f_addPivot(int(p15t), p15l, false, 0.0, 0.0, b15t, b15p, b15h)

// ───────────────────────────── CALIBRATION ─────────────────────────────────
// types: 0 = median, 1 = upper tine, 2 = lower tine
var int[]   calTot = array.new_int(3, 0)
var int[]   calHit = array.new_int(3, 0)
var int[]   pBar   = array.new_int(0)
var float[] pPx    = array.new_float(0)
var float[] pAtr   = array.new_float(0)
var int[]   pDir   = array.new_int(0)
var int[]   pTyp   = array.new_int(0)

if calEnable and haveFork and barstate.isconfirmed
    bool medX = ta.cross(srcPx, medNow)
    bool upHit = srcHigh >= upNow and srcPx < upNow
    bool loHit = srcLow  <= loNow and srcPx > loNow
    if medX
        array.push(pBar, bar_index)
        array.push(pPx, srcPx)
        array.push(pAtr, atrSafe)
        array.push(pDir, srcPx < open ? -1 : 1)
        array.push(pTyp, 0)
    if upHit
        array.push(pBar, bar_index)
        array.push(pPx, srcPx)
        array.push(pAtr, atrSafe)
        array.push(pDir, -1)
        array.push(pTyp, 1)
    if loHit
        array.push(pBar, bar_index)
        array.push(pPx, srcPx)
        array.push(pAtr, atrSafe)
        array.push(pDir, 1)
        array.push(pTyp, 2)
    int idx = 0
    while idx < array.size(pBar)
        if bar_index - array.get(pBar, idx) >= calHorizon
            float p0 = array.get(pPx, idx)
            float a0 = array.get(pAtr, idx)
            int   dr = array.get(pDir, idx)
            int   ty = array.get(pTyp, idx)
            float mv = close - p0
            bool hit = dr == 1 ? mv >= calMoveATR * a0 : mv <= -calMoveATR * a0
            array.set(calTot, ty, array.get(calTot, ty) + 1)
            if hit
                array.set(calHit, ty, array.get(calHit, ty) + 1)
            array.remove(pBar, idx)
            array.remove(pPx, idx)
            array.remove(pAtr, idx)
            array.remove(pDir, idx)
            array.remove(pTyp, idx)
        else
            idx += 1
    while array.size(pBar) > 300
        array.shift(pBar)
        array.shift(pPx)
        array.shift(pAtr)
        array.shift(pDir)
        array.shift(pTyp)

// ───────────────────────────── DRAW STORE ──────────────────────────────────
var line[]     L  = array.new<line>()
var label[]    LB = array.new<label>()
var linefill[] LF = array.new<linefill>()
var float avwapVal = na
var float pocVal   = na
var int   confCount = 0
var string nodeMed = "—"
var string nodeUp  = "—"
var string nodeLo  = "—"

bool rebuild = barstate.islast and haveFork

if rebuild
    for x in L
        line.delete(x)
    array.clear(L)
    for x in LB
        label.delete(x)
    array.clear(LB)
    for x in LF
        linefill.delete(x)
    array.clear(LF)

    color dirCol = forkInvalid ? color.new(uiWarn, 50) : forkRiding ? (brkUp ? uiBull : uiBear) : (vSlope >= 0 ? uiBull : uiBear)
    color medDraw = forkInvalid ? color.new(uiWarn, 30) : uiMed
    string medStyle = forkInvalid ? line.style_dashed : line.style_solid
    bool glowOn = glow and not forkInvalid
    int leftX  = int(math.min(vOb, math.min(vP0b, math.min(vP1b, vP2b))))
    int rightX = bar_index + projBars
    float mL = vOp + vSlope * (leftX - vOb)
    float mR = vOp + vSlope * (rightX - vOb)

    line cMed = f_gline(leftX, mL, rightX, mR, medDraw, 3, medStyle, glowOn, glowStr, L)
    line cUp  = f_gline(leftX, mL + vUpOff, rightX, mR + vUpOff, dirCol, 2, medStyle, glowOn, glowStr, L)
    line cLo  = f_gline(leftX, mL + vLoOff, rightX, mR + vLoOff, dirCol, 2, medStyle, glowOn, glowStr, L)

    line cFu = na
    line cFl = na
    if showFib and not forkInvalid
        cFu := f_gline(leftX, mL + 0.5 * vUpOff, rightX, mR + 0.5 * vUpOff, color.new(dirCol, 28), 1, line.style_dashed, false, glowStr, L)
        cFl := f_gline(leftX, mL + 0.5 * vLoOff, rightX, mR + 0.5 * vLoOff, color.new(dirCol, 28), 1, line.style_dashed, false, glowStr, L)

    if showWarn and not forkInvalid
        f_gline(leftX, mL + 2.0 * vUpOff, rightX, mR + 2.0 * vUpOff, color.new(uiWarn, 20), 1, line.style_dotted, false, glowStr, L)
        f_gline(leftX, mL + 2.0 * vLoOff, rightX, mR + 2.0 * vLoOff, color.new(uiWarn, 20), 1, line.style_dotted, false, glowStr, L)

    if shade and not forkInvalid
        if showFib
            array.push(LF, linefill.new(cMed, cFu, color.new(uiBear, 72)))
            array.push(LF, linefill.new(cFu,  cUp, color.new(uiBear, 66)))
            array.push(LF, linefill.new(cMed, cFl, color.new(uiBull, 72)))
            array.push(LF, linefill.new(cFl,  cLo, color.new(uiBull, 66)))
        else
            array.push(LF, linefill.new(cMed, cUp, color.new(uiBear, 69)))
            array.push(LF, linefill.new(cMed, cLo, color.new(uiBull, 69)))

    if showCone and not forkInvalid
        float sig = atrSafe * math.sqrt(projBars)
        f_gline(bar_index, medNow, rightX, mR + sig, color.new(uiMed, 48), 1, line.style_dotted, false, glowStr, L)
        f_gline(bar_index, medNow, rightX, mR - sig, color.new(uiMed, 48), 1, line.style_dotted, false, glowStr, L)

    if showLabels
        string medTxt = forkInvalid ? "Median (re-anchor)" : forkRiding ? "Median (riding)" : "Median"
        array.push(LB, label.new(rightX, mR, medTxt, xloc = xloc.bar_index, style = label.style_label_left, size = size.small, textcolor = medDraw, color = labelBg))
        array.push(LB, label.new(rightX, mR + vUpOff, "Upper", xloc = xloc.bar_index, style = label.style_label_left, size = size.tiny, textcolor = dirCol, color = labelBg))
        array.push(LB, label.new(rightX, mR + vLoOff, "Lower", xloc = xloc.bar_index, style = label.style_label_left, size = size.tiny, textcolor = dirCol, color = labelBg))

    avwapVal := na
    if useAVWAP and volReliable
        float pvSum = 0.0
        float vSum = 0.0
        int ob0 = math.max(int(vP0b), bar_index - 1000)
        for b = ob0 to bar_index
            int off = bar_index - b
            float prc = (high[off] + low[off] + close[off]) / 3.0
            float vol = nz(volEff[off], 0.0)
            pvSum += prc * vol
            vSum += vol
        avwapVal := vSum > 0 ? pvSum / vSum : na
        if not na(avwapVal)
            f_gline(ob0, avwapVal, bar_index, avwapVal, color.new(#9aa0a6, 20), 1, line.style_solid, false, glowStr, L)

    pocVal := na
    nodeMed := "—"
    nodeUp := "—"
    nodeLo := "—"
    if usePOC and volReliable
        int ob0 = math.max(int(vP0b), bar_index - 1000)
        float wHi = high
        float wLo = low
        for b = ob0 to bar_index
            int off = bar_index - b
            wHi := math.max(wHi, high[off])
            wLo := math.min(wLo, low[off])
        float stepP = (wHi - wLo) / pocBins
        if stepP > 0
            var float[] bins = array.new_float(0)
            array.clear(bins)
            for i = 0 to pocBins - 1
                array.push(bins, 0.0)
            for b = ob0 to bar_index
                int off = bar_index - b
                int bi = math.max(0, math.min(pocBins - 1, int(((high[off] + low[off] + close[off]) / 3.0 - wLo) / stepP)))
                array.set(bins, bi, array.get(bins, bi) + nz(volEff[off], 0.0))
            int pocBin = array.indexof(bins, array.max(bins))
            pocVal := wLo + (pocBin + 0.5) * stepP
            f_gline(ob0, pocVal, bar_index, pocVal, color.new(#ffa600, 24), 1, line.style_dotted, false, glowStr, L)
            nzB = array.new_float(0)
            for i = 0 to pocBins - 1
                if array.get(bins, i) > 0
                    array.push(nzB, array.get(bins, i))
            float hvnThr = array.size(nzB) >= 5 ? array.percentile_linear_interpolation(nzB, hvnPct) : array.avg(bins) * 1.4
            float lvnThr = array.size(nzB) >= 5 ? array.percentile_linear_interpolation(nzB, lvnPct) : array.avg(bins) * 0.5
            for ti = 0 to 2
                float tpx = ti == 0 ? medNow : ti == 1 ? upNow : loNow
                if tpx >= wLo and tpx <= wHi
                    int tb = math.max(0, math.min(pocBins - 1, int((tpx - wLo) / stepP)))
                    float bvol = array.get(bins, tb)
                    string tag = bvol >= hvnThr ? "HVN" : bvol <= lvnThr ? "LVN" : "mid"
                    if ti == 0
                        nodeMed := tag
                    else if ti == 1
                        nodeUp := tag
                    else
                        nodeLo := tag

    if usePolarity and not na(flipPx)
        color fc = flipRole > 0 ? uiBull : uiBear
        f_gline(leftX, flipPx, rightX, flipPx, color.new(fc, 8), 2, line.style_dotted, false, glowStr, L)
        array.push(LB, label.new(rightX, flipPx, flipRole > 0 ? "flip→sup" : "flip→res", xloc = xloc.bar_index, style = label.style_label_left, size = size.tiny, textcolor = fc, color = labelBg))

    confCount := 0
    float tol = math.max(math.abs(halfW) * 0.20, close * confTolPct / 100.0) * volFactor
    refA = array.new_float()
    if not na(avwapVal)
        array.push(refA, avwapVal)
    if not na(pocVal)
        array.push(refA, pocVal)
    if usePolarity and not na(flipPx)
        array.push(refA, flipPx)
    if useMTF
        if not na(hh1)
            array.push(refA, hh1)
        if not na(ll1)
            array.push(refA, ll1)
        if not na(hh2)
            array.push(refA, hh2)
        if not na(ll2)
            array.push(refA, ll2)
    tineA = array.from(medNow, upNow, loNow)
    for ti = 0 to array.size(tineA) - 1
        float tv = array.get(tineA, ti)
        bool hitC = false
        for ri = 0 to array.size(refA) - 1
            if math.abs(tv - array.get(refA, ri)) <= tol
                hitC := true
        if hitC
            confCount += 1
            array.push(LB, label.new(bar_index, tv, "◆", xloc = xloc.bar_index, style = label.style_label_left, size = size.tiny, textcolor = uiWarn, color = color.new(uiWarn, 64)))

    if showHTF
        int barMs = timeframe.in_seconds() * 1000
        int rightT = time + projBars * barMs
        if useHTF5
            f_drawHTFFork(b5t, b5p, b5h, color.new(uiAcc, 12), "5×", rightT, showLabels, L, LB)
        if useHTF15
            f_drawHTFFork(b15t, b15p, b15h, color.new(#26c6da, 12), "15×", rightT, showLabels, L, LB)

// ───────────────────────────── DATA HEALTH ─────────────────────────────────
bool barRangeValid = high > low and not na(high) and not na(low)
bool volMatters = useAVWAP or usePOC
bool htfStale = useMTF and bar_index >= 50 and (na(hh1) or na(hh2))
int healthCode = not barRangeValid ? 2 : ((not warmedUp) or (volMatters and not volReliable) or htfStale) ? 1 : 0
string healthTxt = healthCode == 2 ? "CRITICAL" : healthCode == 1 ? "DEGRADED" : "OK"

// ───────────────────────────── ALERTS ──────────────────────────────────────
medCrossA = haveFork and ta.cross(srcPx, medNow) and sigConfirm
upTouchA  = haveFork and srcHigh >= upNow and srcPx < upNow and sigConfirm
loTouchA  = haveFork and srcLow  <= loNow and srcPx > loNow and sigConfirm
regimeFlipA = regime != regime[1]
rideA    = forkRiding and not forkRiding[1]
invalidA = forkInvalid and not forkInvalid[1]
alertcondition(medCrossA, "Median cross", "Andrews' Pitchfork: price crossed the median line")
alertcondition(upTouchA,  "Upper tine rejection", "Andrews' Pitchfork: price rejected the upper tine")
alertcondition(loTouchA,  "Lower tine rejection", "Andrews' Pitchfork: price rejected the lower tine")
alertcondition(regimeFlipA, "Regime flip", "Andrews' Pitchfork: regime changed")
alertcondition(rideA, "Fork riding", "Andrews' Pitchfork: strong break in trend — channel being ridden")
alertcondition(invalidA, "Fork invalidated", "Andrews' Pitchfork: channel broken — re-anchor")

// ───────────────────────────── TABLE ───────────────────────────────────────
var table tbl = table.new(f_pos(tblPosStr), 2, 14, border_width = 1, frame_width = 1)

if showTable and barstate.islast and haveFork
    string varTxt = vVar == 0 ? "Standard" : vVar == 1 ? "Schiff" : "Mod-Schiff"
    bool up = vSlope >= 0
    color hdr = forkInvalid ? uiWarn : forkRiding ? (brkUp ? uiBull : uiBear) : (up ? uiBull : uiBear)
    string posTxt = na(robZ) ? "—" : str.tostring(robZ, "0.00") + "σ"
    int totAll = array.get(calTot, 0) + array.get(calTot, 1) + array.get(calTot, 2)
    int hitAll = array.get(calHit, 0) + array.get(calHit, 1) + array.get(calHit, 2)
    [wlo, whi] = f_wilson(hitAll, totAll)
    string respTxt = totAll < 5 ? "warming up" : str.tostring(math.round(hitAll * 100.0 / totAll)) + "%  [" + (na(wlo) ? "—" : str.tostring(math.round(wlo * 100)) + "–" + str.tostring(math.round(whi * 100))) + "]"
    string regTxt = regime + " " + str.tostring(adx, "0") + (forkReliable ? " · reliable" : volCluster ? " · unreliable" : " · caution")
    color regCol = forkReliable ? uiBull : volCluster ? uiBear : uiWarn
    string vrTxt = str.tostring(vr, "0.00") + (vrMeanRev ? " mean-rev" : " trending")
    string hlTxt = na(halfLife) ? "trending" : str.tostring(math.round(halfLife)) + " bars"
    string contTxt = na(containPct) ? "warming up" : str.tostring(math.round(containPct)) + "%"
    string upTxt = str.tostring(math.round_to_mintick(upNow)) + (nodeUp == "—" ? "" : " · " + nodeUp)
    string loTxt = str.tostring(math.round_to_mintick(loNow)) + (nodeLo == "—" ? "" : " · " + nodeLo)
    string confTxt = (useAVWAP or usePOC or useMTF or usePolarity) ? (confCount > 0 ? str.tostring(confCount) + " line(s)" : "none") : "off"
    string mtfTxt = useMTF ? str.tostring(mtfAgree) + "/2 agree" : "off"
    string rrTxt = na(rrRev) ? "—" : str.tostring(rrRev, "0.0") + "R"
    string qualTxt = (na(vQual) ? "—" : str.tostring(math.round(vQual * 100)) + "%") + (forkUnstable ? " · unstable" : " · stable")
    color qualCol = forkUnstable ? uiBear : (na(vQual) ? cDim : vQual >= 0.6 ? uiBull : uiWarn)
    string statusTxt = forkState + (forkState == "FADE" or forkState == "—" ? "" : " (str " + str.tostring(breakStr) + ")")
    color statusCol = forkInvalid ? uiBear : forkRiding ? uiBull : cTxt
    string nodeTag = nodeMed == "—" ? "" : "med@" + nodeMed

    table.set_bgcolor(tbl, cPanel)
    table.set_frame_color(tbl, cFrame)
    table.set_border_color(tbl, cBord)
    table.cell(tbl, 0, 0, "PITCHFORK", text_color = color.white, text_size = size.small, bgcolor = color.new(hdr, 0))
    table.cell(tbl, 1, 0, varTxt, text_color = color.white, text_size = size.small, bgcolor = color.new(hdr, 0))
    table.cell(tbl, 0, 1, "Bias", text_color = cDim, text_size = size.small, bgcolor = cSub)
    table.cell(tbl, 1, 1, up ? "▲ Up" : "▼ Down", text_color = up ? uiBull : uiBear, text_size = size.small, bgcolor = cSub)
    table.cell(tbl, 0, 2, "Position", text_color = cDim, text_size = size.small, bgcolor = cSub)
    table.cell(tbl, 1, 2, posTxt + (nodeTag == "" ? "" : " · " + nodeTag), text_color = cTxt, text_size = size.small, bgcolor = cSub)
    table.cell(tbl, 0, 3, "Upper", text_color = cDim, text_size = size.small, bgcolor = cSub)
    table.cell(tbl, 1, 3, upTxt, text_color = uiBear, text_size = size.small, bgcolor = cSub)
    table.cell(tbl, 0, 4, "Lower", text_color = cDim, text_size = size.small, bgcolor = cSub)
    table.cell(tbl, 1, 4, loTxt, text_color = uiBull, text_size = size.small, bgcolor = cSub)
    table.cell(tbl, 0, 5, "Regime", text_color = cDim, text_size = size.small, bgcolor = cSub)
    table.cell(tbl, 1, 5, regTxt, text_color = regCol, text_size = size.small, bgcolor = cSub)
    table.cell(tbl, 0, 6, "Half-life", text_color = cDim, text_size = size.small, bgcolor = cSub, tooltip = "Ornstein-Uhlenbeck estimate of bars for a stretch to the median to revert. 'trending' = no mean reversion (don't fade).")
    table.cell(tbl, 1, 6, hlTxt, text_color = na(halfLife) ? uiWarn : cTxt, text_size = size.small, bgcolor = cSub)
    table.cell(tbl, 0, 7, "Var-ratio", text_color = cDim, text_size = size.small, bgcolor = cSub)
    table.cell(tbl, 1, 7, vrTxt, text_color = vrMeanRev ? uiBull : uiWarn, text_size = size.small, bgcolor = cSub)
    table.cell(tbl, 0, 8, "Containment", text_color = cDim, text_size = size.small, bgcolor = cSub, tooltip = "Share of bars inside the current channel since it was anchored. Higher = the geometry fits this symbol.")
    table.cell(tbl, 1, 8, contTxt, text_color = na(containPct) ? cDim : containPct >= 70 ? uiBull : containPct >= 50 ? uiWarn : uiBear, text_size = size.small, bgcolor = cSub)
    table.cell(tbl, 0, 9, "Confluence", text_color = cDim, text_size = size.small, bgcolor = cSub)
    table.cell(tbl, 1, 9, confTxt + (useMTF ? " · " + mtfTxt : ""), text_color = cTxt, text_size = size.small, bgcolor = cSub)
    table.cell(tbl, 0, 10, "Respect", text_color = cDim, text_size = size.small, bgcolor = cSub, tooltip = "Past-only: share of median/tine touches that reacted ≥ " + str.tostring(calMoveATR) + "×ATR within " + str.tostring(calHorizon) + " bars. Wilson 95% CI in brackets.")
    table.cell(tbl, 1, 10, respTxt, text_color = totAll < 5 ? cDim : cTxt, text_size = size.small, bgcolor = cSub)
    table.cell(tbl, 0, 11, "Reversion", text_color = cDim, text_size = size.small, bgcolor = cSub, tooltip = "Reference geometry: reward:risk of a tine→median rotation with a stop " + str.tostring(rrStopATR) + "×ATR beyond the tine. Not a signal.")
    table.cell(tbl, 1, 11, rrTxt, text_color = cTxt, text_size = size.small, bgcolor = cSub)
    table.cell(tbl, 0, 12, "Quality", text_color = cDim, text_size = size.small, bgcolor = cSub, tooltip = "Anchor quality (pivot prominence + recency) and whether the fork is re-anchoring too often (unstable).")
    table.cell(tbl, 1, 12, qualTxt, text_color = qualCol, text_size = size.small, bgcolor = cSub)
    table.cell(tbl, 0, 13, "Status", text_color = cDim, text_size = size.small, bgcolor = cSub, tooltip = "FADE = normal reversion inside the channel. RIDE = strong break in a trend (tine ridden). INVALID = channel broken, re-anchor.")
    table.cell(tbl, 1, 13, statusTxt, text_color = statusCol, text_size = size.small, bgcolor = cSub)

// ───────────────────────────── CALIBRATION PANEL ───────────────────────────
if calEnable and calShowPanel and barstate.islast
    var table calT = table.new(f_pos(calPanelPos), 4, 6, border_width = 1, frame_width = 1)
    table.set_bgcolor(calT, cPanel)
    table.set_frame_color(calT, uiAcc)
    table.set_border_color(calT, cBord)
    table.cell(calT, 0, 0, "Line respect (past)", text_color = uiAcc, bgcolor = cSub, text_size = size.tiny, text_halign = text.align_left, tooltip = "Descriptive only. Share of touches that reacted ≥ " + str.tostring(calMoveATR) + "×ATR toward the median within " + str.tostring(calHorizon) + " bars. NOT a backtest or prediction.")
    table.cell(calT, 1, 0, "N",      text_color = uiAcc, bgcolor = cSub, text_size = size.tiny, text_halign = text.align_center)
    table.cell(calT, 2, 0, "Resp",   text_color = uiAcc, bgcolor = cSub, text_size = size.tiny, text_halign = text.align_center)
    table.cell(calT, 3, 0, "95% CI", text_color = uiAcc, bgcolor = cSub, text_size = size.tiny, text_halign = text.align_right)
    string[] rl = array.from("Median", "Upper", "Lower", "All")
    int[] rt = array.from(array.get(calTot, 0), array.get(calTot, 1), array.get(calTot, 2), array.get(calTot, 0) + array.get(calTot, 1) + array.get(calTot, 2))
    int[] rh = array.from(array.get(calHit, 0), array.get(calHit, 1), array.get(calHit, 2), array.get(calHit, 0) + array.get(calHit, 1) + array.get(calHit, 2))
    for r = 0 to 3
        int t = array.get(rt, r)
        int h = array.get(rh, r)
        float rate = t > 0 ? h * 100.0 / t : na
        [lo, hi] = f_wilson(h, t)
        string rateTxt = t == 0 ? "—" : t < 5 ? "warm" : str.tostring(rate, "0") + "%"
        string ciTxt = na(lo) ? "—" : str.tostring(math.round(lo * 100)) + "–" + str.tostring(math.round(hi * 100)) + "%"
        color rc = t < 5 ? cDim : rate >= 60 ? uiBull : rate >= 50 ? uiWarn : uiBear
        table.cell(calT, 0, r + 1, array.get(rl, r), text_color = cTxt, bgcolor = cSub, text_size = size.tiny, text_halign = text.align_left)
        table.cell(calT, 1, r + 1, str.tostring(t), text_color = cTxt, bgcolor = cSub, text_size = size.tiny, text_halign = text.align_center)
        table.cell(calT, 2, r + 1, rateTxt, text_color = rc, bgcolor = cSub, text_size = size.tiny, text_halign = text.align_center)
        table.cell(calT, 3, r + 1, ciTxt, text_color = cTxt, bgcolor = cSub, text_size = size.tiny, text_halign = text.align_right)
    table.cell(calT, 0, 5, "past data only — no forward guarantee", text_color = cDim, bgcolor = cSub, text_size = size.tiny, text_halign = text.align_left)
    table.cell(calT, 1, 5, "", bgcolor = cSub)
    table.cell(calT, 2, 5, "", bgcolor = cSub)
    table.cell(calT, 3, 5, "", bgcolor = cSub)
    table.merge_cells(calT, 0, 5, 3, 5)

// ───────────────────────────── IDENTITY STRIP ──────────────────────────────
var table idTbl = table.new(position.bottom_center, 1, 1)
if showId and barstate.islast
    table.cell(idTbl, 0, 0, "Auto Andrews' Pitchfork   ·   " + syminfo.ticker + "   ·   " + timeframe.period, text_color = cDim, text_size = size.small, text_halign = text.align_center, bgcolor = color.new(color.gray, 100))

// ───────────────────────────── EXP_* EXPORTS ───────────────────────────────
int totAllE = array.get(calTot, 0) + array.get(calTot, 1) + array.get(calTot, 2)
int hitAllE = array.get(calHit, 0) + array.get(calHit, 1) + array.get(calHit, 2)
float respRate = totAllE > 0 ? hitAllE / float(totAllE) : na
int regimeCode = regime == "Trend Up" ? 2 : regime == "Trend Dn" ? -2 : regime == "Volatile" ? 1 : 0
int stateCode = forkState == "RIDE" ? 2 : forkState == "FADE" ? 1 : forkState == "INVALID" ? -1 : 0

plot(medNow,                         "EXP_Median",     color = color.new(color.gray, 100), display = display.data_window)
plot(zPos,                           "EXP_ZPos",       color = color.new(color.gray, 100), display = display.data_window)
plot(robZ,                           "EXP_Stretch",    color = color.new(color.gray, 100), display = display.data_window)
plot(haveFork ? (vSlope >= 0 ? 1 : -1) : 0, "EXP_ForkDir", color = color.new(color.gray, 100), display = display.data_window)
plot(regimeCode,                     "EXP_Regime",     color = color.new(color.gray, 100), display = display.data_window)
plot(forkReliable ? 1 : 0,           "EXP_Reliable",   color = color.new(color.gray, 100), display = display.data_window)
plot(vr,                             "EXP_VarRatio",   color = color.new(color.gray, 100), display = display.data_window)
plot(nz(halfLife, -1),               "EXP_HalfLife",   color = color.new(color.gray, 100), display = display.data_window)
plot(nz(containPct, -1),             "EXP_Containment",color = color.new(color.gray, 100), display = display.data_window)
plot(breakStr,                       "EXP_BreakStr",   color = color.new(color.gray, 100), display = display.data_window)
plot(confCount,                      "EXP_Confluence", color = color.new(color.gray, 100), display = display.data_window)
plot(stateCode,                      "EXP_State",      color = color.new(color.gray, 100), display = display.data_window)
plot(nz(respRate, -1),               "EXP_RespectRate",color = color.new(color.gray, 100), display = display.data_window)
plot(healthCode,                     "EXP_Health",     color = color.new(color.gray, 100), display = display.data_window)
````
