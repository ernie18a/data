# Supertrend Tempered [Probalist Essentials]

- url: https://www.tradingview.com/script/XZc6g4ra-Supertrend-Tempered-Probalist-Essentials/
- type: indicator
- pine_id: PUB;74267fb1ebcc4b30a34f2bc21c82e2fe
- version: 1.0

## Description

Supertrend Tempered is a trend-direction tool that places a trailing ATR stop above or below price and flips when price closes through it. Gold line means the trend is up; blue means it's down. The flip is the signal.

The Tempered version adds ATR-adaptive sensitivity so the band breathes with volatility — tighter when markets are calm, wider during spikes — reducing false flips without sacrificing responsiveness. On top of the classic, it tracks what actually happened after past flips on this chart and shows the distribution as a forward projection and a bell curve panel.

🟡 WHY THIS VERSION

A Supertrend that shows you what its own flips have historically led to, right on the chart. Most Supertrend scripts just draw the line and fire an alert — this one keeps score. After enough flips, the distribution panel and cone tell you the median outcome and the spread, separately for bull and bear flips, so you can judge the flip in context rather than treating every one the same. The adaptive mode is on by default because it cuts noise on most instruments without any extra fiddling. Flips only confirm on a closed bar so no midnight-print surprises. The alerts have a history-backed tier that fires only when your chart's past flips actually showed follow-through — a useful filter, not a promise.

🟡 HOW IT WORKS

The core is a two-sided trailing stop built from ATR. On each bar, a raw upper band sits above the midpoint by a multiple of ATR and a raw lower band sits below by the same amount. The bands are ratcheted: the upper band can only move down (or reset if price breaks above it), and the lower band can only move up (or reset if price breaks below it). When price closes above the upper band, trend flips to bullish and the lower band becomes the active trailing stop. When price closes below the lower band, trend flips to bearish and the upper band takes over.

In adaptive mode the multiplier is scaled by the ratio of short-term ATR to a longer-run ATR baseline. A high ratio means volatility is spiking relative to its norm — the band widens to avoid a false flip. A low ratio means conditions are quiet — the band tightens to stay close to price. The result tracks trend direction through choppy patches better than a fixed multiplier.

The probability read counts every confirmed flip, then looks up the close N bars later. Those returns go into per-direction arrays. The distribution panel draws a kernel-smoothed density of those returns, with a Gaussian overlay so you can see fat tails and skew at a glance. The projection cone after the most recent flip spans the 16th–84th percentile of that history, anchored at the flip price.

🟡 KEY FEATURES
[list]
[*]ATR-adaptive multiplier that scales with short/long ATR ratio — fewer whipsaws in low-vol periods, wider band during spikes
[*]Clean ▲/▼ flip labels at each trend-change bar with hover tooltips showing signal strength and historical stats at fire time
[*]Weighted signal dots: size reflects excursion depth (ATR-scaled), glyph shows evidence tier at the moment of the flip
[*]Forward-return distribution: separate bull and bear outcome arrays, KDE bell curve panel with Gaussian overlay
[*]Projection cone anchored at the flip price, spanning the 16th–84th percentile of past outcomes in that direction
[*]Optional higher-timeframe Supertrend reference line — display only, no scoring or gating
[*]Heat colour ramp: line and fill breathe hot/cold with how far price has moved through the band
[*]Eight alert conditions including history-backed and strong-flip tiers, all confirmed on bar close
[*]Regime-aware reads: besides the long-run record, a recent-form window (default last 40 outcomes) with a Wilson-score evidence test — the Read tells you whether the signal works NOW, and an edge clock shows when each side last had it
[/list]

🟡 HOW TO USE
[list]
[*]Use the line colour as a bias filter: gold = bullish bias, worth considering long-side setups; blue = bearish, consider the short side or stay flat.
[*]A flip label marks the moment the trend changed. Hover the dot to see the strength and what past flips at this signal tier averaged — use that as context, not a guarantee.
[*]ATR-adaptive mode is on by default. On trending instruments with variable volatility it cuts noise well. For very stable, range-bound markets you may prefer fixed multiplier.
[*]The projection cone after a flip shows the 16th–84th percentile of past outcomes in that direction, anchored at the flip price. A tight cone on a backed signal adds conviction; a wide or centred cone around zero is a caution.
[*]The distribution panel (top-right of the price pane) shows the full return distribution separately for bull and bear flips. The gap between the KDE fill and the Gaussian overlay reveals skew and fat tails.
[*]Run the optional HTF line to see whether the higher-timeframe trend agrees — a flip that aligns with the HTF direction has broader context; a counter-HTF flip is a fade candidate, not a trend trade.
[*]Realtime mode (Confirm bars = 0) updates the signal on the live bar — useful for watching; default 1-bar confirmation is the honest, non-repainting mode for alerts.
[*]Weigh the median move against your round-trip costs — a backed flip with a tiny median (say +0.04% on a 5-minute chart) doesn't survive fees and spread on most venues; the edge read is about direction, not net profit
[/list]

🟡 PAIRS WELL WITH

A momentum read (RSI, MACD) pairs naturally here — a bullish Supertrend flip is worth more when momentum was oversold before the flip or is now turning up from a low base. A volume indicator adds the missing liquidity dimension: a flip on elevated volume has more conviction than one on thin air. For swing setups, a higher-timeframe structure read (S/R levels, swing highs/lows) tells you whether the flip is happening into open space or straight into overhead supply. The Supertrend alone doesn't read overextension — it just tracks the trend — so a volatility or mean-reversion tool alongside it flags when a quiet trend is tightening toward a potential squeeze release.

Supertrend Tempered gives you the classic ATR trailing stop with adaptive sensitivity and an honest historical context. It tells you which way the trend is running, how far price has moved through the band, and what past flips in that direction have actually produced on this chart. That's the read — what you do with it is yours.

[i]Open source under MPL-2.0. The probability layer describes past signals on your chart — it is a measurement, not a prediction, and nothing here is financial advice.[/i]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//
// ██████╗ ██████╗  ██████╗ ██████╗  █████╗ ██╗     ██╗███████╗████████╗
// ██╔══██╗██╔══██╗██╔═══██╗██╔══██╗██╔══██╗██║     ██║██╔════╝╚══██╔══╝
// ██████╔╝██████╔╝██║   ██║██████╔╝███████║██║     ██║███████╗   ██║
// ██╔═══╝ ██╔══██╗██║   ██║██╔══██╗██╔══██║██║     ██║╚════██║   ██║
// ██║     ██║  ██║╚██████╔╝██████╔╝██║  ██║███████╗██║███████║   ██║
// ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝╚══════╝   ╚═╝

// What it shows: Supertrend (ATR trailing stop) coloured by trend direction, with ATR-adaptive
//   sensitivity, clean flip labels, and a forward-return distribution anchored to each flip.
// Method: Classic Vandemark/Oliver Supertrend — upper/lower bands built from ATR around the
//   hl2 midpoint; when price closes above the upper band the trend flips bullish, below lower
//   flips bearish. ATR-adaptive mode scales the multiplier inversely with a long-run ATR ratio
//   so the band tightens in low-vol and widens in spikes, reducing whipsaw.
// How to use:
//   • Gold line = bullish trend; blue line = bearish trend.
//   • Flip-up label (▲) and flip-down label (▼) mark trend changes.
//   • Probability panel (top-right) shows what happened N bars after past flips.
//   • HTF line (optional) shows higher-timeframe trend as a faint reference — display only.

//@version=6
indicator("Supertrend Tempered [Probalist Essentials]", shorttitle = "ST [P]", overlay = true, max_labels_count = 500, max_lines_count = 20, max_boxes_count = 200, max_polylines_count = 5)

// ═══════════════════════════════════════════════════════════
// § INPUTS
// ═══════════════════════════════════════════════════════════

// ■ Calculation
i_atrLen     = input.int(10,    "ATR Length",          minval = 1,   maxval = 200, group = "■ Calculation", tooltip = "Lookback for ATR. Lower = more responsive, higher = smoother band.")
i_mult       = input.float(3.0, "Base Multiplier",     minval = 0.5, maxval = 20.0, step = 0.1, group = "■ Calculation", tooltip = "Band width in ATR units. Higher = fewer signals, wider trailing stop.")
i_adaptive   = input.bool(true, "ATR-Adaptive Mode",   group = "■ Calculation", tooltip = "Scales the multiplier by the short/long ATR ratio. Tightens in calm markets, widens in volatility spikes — reduces whipsaw.")
i_adaptLen   = input.int(50,    "Adaptive ATR Length", minval = 10,  maxval = 500, group = "■ Calculation", tooltip = "Long-run ATR used as the normalisation baseline for adaptive mode.")
i_src        = input.source(hl2, "Source",             group = "■ Calculation", tooltip = "Midpoint for band construction. hl2 is the canonical choice; close shifts the band slightly.")

// ■ Signals
i_flipLabels = input.bool(true,  "Show Flip Labels",   group = "■ Signals", tooltip = "Draw ▲/▼ labels at each trend flip bar.")
i_confirm    = input.int(1,      "Confirm bars",        minval = 0, maxval = 5, group = "■ Signals", tooltip = "0 = realtime (may repaint on the unconfirmed bar); 1+ = confirmed, non-repainting. Default 1 is the honest mode.")

// ■ Higher Timeframe
i_htfOn      = input.bool(false,  "Show HTF Trend Line", group = "■ Higher Timeframe", tooltip = "Display a faint higher-timeframe Supertrend line for context. Display only — does not gate or score signals.")
i_htfTf      = input.timeframe("D", "HTF Timeframe",    group = "■ Higher Timeframe", tooltip = "Timeframe for the optional reference Supertrend line.")

// ■ Visuals
i_lineWidth  = input.int(2, "Line Width",              minval = 1, maxval = 5, group = "■ Visuals", tooltip = "Thickness of the Supertrend line.")
i_glow       = input.bool(true, "Glow Effect",          group = "■ Visuals", tooltip = "Stacked fill halo around the Supertrend line. Turn off for a clean single line.")
i_showFill   = input.bool(true, "Price-to-Line Fill",   group = "■ Visuals", tooltip = "Gradient fill between price and the Supertrend line — strong at the line, fading toward price.")

// ■ Probalist Theme
i_col_hot    = input.color(color.rgb(249, 115, 22),   "Wave hot (bullish end)",   group = "■ Probalist Theme", tooltip = "Hot end of the heat ramp — colour when trend is strongly bullish.")
i_col_cold   = input.color(color.rgb(37, 99, 235),  "Wave cold (bearish end)",  group = "■ Probalist Theme", tooltip = "Cold end of the heat ramp — colour when trend is strongly bearish.")
i_dist_gold  = input.color(color.rgb(224, 168, 0),   "Gold accent (bullish)",    group = "■ Probalist Theme", tooltip = "Accent colour for bullish signals, labels, and the distribution panel warm side.")
i_dist_cold  = input.color(color.rgb(50, 160, 255),  "Blue accent (bearish)",    group = "■ Probalist Theme", tooltip = "Accent colour for bearish signals, labels, and the distribution panel cool side.")

// ■ Probability Read
i_probOn     = input.bool(true,  "Probability Read (master)",      group = "■ Probability Read", tooltip = "Track forward returns after each trend flip. Descriptive stats of this chart's own history — not a prediction.")
i_horizon    = input.int(10,     "Horizon (bars)",                minval = 1, maxval = 100, group = "■ Probability Read", tooltip = "How many bars forward to measure the outcome after each flip.")
i_maxSamp    = input.int(200,    "Max Samples",                   minval = 50, maxval = 500, group = "■ Probability Read", tooltip = "Cap on stored past outcomes per direction. Oldest are dropped first.")
i_minSamp    = input.int(20,     "Min Samples (show stats)",      minval = 5,  maxval = 100, group = "■ Probability Read", tooltip = "Below this count, show 'gathering' instead of stats to avoid misleading thin-sample numbers.")
i_recentN    = input.int(60,     "Recent Window (outcomes)",     minval = 15, maxval = 100, group = "■ Probability Read", tooltip = "How many of the most recent outcomes per direction form the RECENT FORM read. Markets move in regimes — the recent window shows whether the signal works NOW, not averaged over years.")
i_evid       = input.string("80%", "Evidence Strictness (Wilson)", group = "■ Probability Read", options = ["80%", "90%", "95%"], tooltip = "Confidence level for the Wilson evidence test behind the backed verdict. 80% = more sensitive (edge shows sooner), 95% = strictest.")
float zEv    = i_evid == "95%" ? 1.960 : i_evid == "90%" ? 1.645 : 1.282
i_coneOn     = input.bool(true,  "↳ Projection Cone",         group = "■ Probability Read", tooltip = "After the most recent flip, draw a forward box (16th–84th percentile) and median line anchored at the flip price.")
i_panelOn    = input.bool(true,  "↳ Distribution Panel (bell curve)",      group = "■ Probability Read", tooltip = "Kernel-smoothed density of past flip outcomes, drawn to the right of the last bar.")
i_readoutOn  = input.bool(true,  "↳ Readout panel",             group = "■ Probability Read", tooltip = "The chart-anchored info block bottom right (state, per-direction stats, edge clock, Read). Hidden when the master is off.")

// ═══════════════════════════════════════════════════════════
// § PROBALIST HEAT
// ═══════════════════════════════════════════════════════════

normScore(float score) =>
    (math.max(-100.0, math.min(100.0, score)) + 100.0) / 200.0

// Probalist VIBRANT ramp (8 stops): deep blue → strong blue → cyan → light blue →
// mint (neutral) → yellow → amber → orange. col_cold/col_hot are the picker extremes.
heatCol(float pos, float transp, color col_hot, color col_cold) =>
    color col = na
    if pos >= 0.80
        col := color.from_gradient(pos, 0.80, 1.0, color.rgb(245, 158, 11), col_hot)
    else if pos >= 0.62
        col := color.from_gradient(pos, 0.62, 0.80, color.rgb(251, 191, 36), color.rgb(245, 158, 11))
    else if pos >= 0.50
        col := color.from_gradient(pos, 0.50, 0.62, color.rgb(167, 243, 208), color.rgb(251, 191, 36))
    else if pos >= 0.40
        col := color.from_gradient(pos, 0.40, 0.50, color.rgb(56, 189, 248), color.rgb(167, 243, 208))
    else if pos >= 0.22
        col := color.from_gradient(pos, 0.22, 0.40, color.rgb(6, 182, 212), color.rgb(56, 189, 248))
    else
        col := color.from_gradient(pos, 0.0, 0.22, col_cold, color.rgb(6, 182, 212))
    color.new(col, transp)

// ═══════════════════════════════════════════════════════════
// § SUPERTREND CALCULATION
// ═══════════════════════════════════════════════════════════

// ATR — use RMA (Wilder) to match canonical Supertrend
atrRaw = ta.atr(i_atrLen)
atrLong = ta.atr(i_adaptLen)

// Adaptive multiplier: scale by short/long ATR ratio, clamped 0.5–2×
adaptRatio = (atrLong > 0) ? (atrRaw / atrLong) : 1.0
effMult = i_adaptive ? math.max(0.5, math.min(6.0, i_mult * adaptRatio)) : i_mult

// Band construction
upperBandRaw = i_src + effMult * atrRaw
lowerBandRaw = i_src - effMult * atrRaw

// Trailing bands — lock in the tightest seen while price stays on that side
var float upperBand = na
var float lowerBand = na
var int   trendDir  = 1   // 1 = bullish, -1 = bearish

upperBand := (na(upperBand[1]) or upperBandRaw < upperBand[1] or close[1] > upperBand[1]) ? upperBandRaw : upperBand[1]
lowerBand := (na(lowerBand[1]) or lowerBandRaw > lowerBand[1] or close[1] < lowerBand[1]) ? lowerBandRaw : lowerBand[1]

// Direction flip logic
trendDir := trendDir[1]
if close > upperBand[1]
    trendDir := 1
if close < lowerBand[1]
    trendDir := -1

// The Supertrend line is the relevant trailing band
stLine = trendDir == 1 ? lowerBand : upperBand

// Flip detection (confirmed with i_confirm offset)
flipUp   = trendDir == 1 and trendDir[1] == -1
flipDown = trendDir == -1 and trendDir[1] == 1

flipUpConf   = flipUp[i_confirm]
flipDownConf = flipDown[i_confirm]

// ═══════════════════════════════════════════════════════════
// § HTF SUPERTREND (display only)
// ═══════════════════════════════════════════════════════════

htfTrendDir = request.security(syminfo.tickerid, i_htfTf, trendDir[1], lookahead = barmerge.lookahead_off)
htfStLine   = request.security(syminfo.tickerid, i_htfTf, stLine[1],   lookahead = barmerge.lookahead_off)

// ═══════════════════════════════════════════════════════════
// § HEAT COLOUR — map trend state to ±100
// ═══════════════════════════════════════════════════════════

// State: +100 = strongly bullish (price well above ST), -100 = strongly bearish
// Use distance from ST relative to recent ATR as the magnitude
stDist    = close - stLine
stDistNorm = (atrRaw > 0) ? math.max(-100.0, math.min(100.0, stDist / atrRaw * 33.0)) : (trendDir * 60.0)
heatPos   = normScore(stDistNorm)
cMain     = heatCol(heatPos, 0, i_col_hot, i_col_cold)
cMainFill = heatCol(heatPos, 55, i_col_hot, i_col_cold)
cGlow1    = heatCol(heatPos, 65, i_col_hot, i_col_cold)
cGlow2    = heatCol(heatPos, 80, i_col_hot, i_col_cold)
cGlow3    = heatCol(heatPos, 90, i_col_hot, i_col_cold)

// ═══════════════════════════════════════════════════════════
// § PLOTS — Supertrend line + glow + price fill
// ═══════════════════════════════════════════════════════════

pST     = plot(stLine, "Supertrend", color = cMain, linewidth = i_lineWidth, style = plot.style_line)
pClose  = plot(close, "Close ref", color = na, editable = false, display = display.none)

// Price-to-line gradient fill (strong at the ST line, fading toward price)
fillTop    = trendDir == 1 ? stLine : close
fillBottom = trendDir == 1 ? close  : stLine
pFillTop    = plot(fillTop,    "Fill top",    color = na, editable = false, display = display.none)
pFillBottom = plot(fillBottom, "Fill bottom", color = na, editable = false, display = display.none)
fill(pFillTop, pFillBottom, top_value = fillTop, bottom_value = fillBottom, top_color = i_showFill ? color.new(cMain, 28) : na, bottom_color = i_showFill ? color.new(cMain, 92) : na)

// Glow layers — stacked halo around the ST line
pGlowA = plot(stLine, "GlowA", color = i_glow ? cGlow1 : na, linewidth = i_lineWidth + 4, display = display.none, editable = false)
pGlowB = plot(stLine, "GlowB", color = i_glow ? cGlow2 : na, linewidth = i_lineWidth + 8, display = display.none, editable = false)
pGlowC = plot(stLine, "GlowC", color = i_glow ? cGlow3 : na, linewidth = i_lineWidth + 14, display = display.none, editable = false)
fill(pST, pGlowA, color = i_glow ? color.new(cMain, 75) : na)
fill(pGlowA, pGlowB, color = i_glow ? color.new(cMain, 85) : na)
fill(pGlowB, pGlowC, color = i_glow ? color.new(cMain, 93) : na)

// HTF reference line
htfCol = htfTrendDir == 1 ? color.new(i_dist_gold, 55) : color.new(i_dist_cold, 55)
plot(i_htfOn ? htfStLine : na, "HTF Supertrend", color = htfCol, linewidth = 3, style = plot.style_line)

// ═══════════════════════════════════════════════════════════
// § FLIP LABELS (killer extra — clean labels at each flip)
// ═══════════════════════════════════════════════════════════

if i_flipLabels and flipUp
    label.new(bar_index, low * 0.9995, "▲", style = label.style_label_up, color = color.new(i_dist_gold, 20), textcolor = color.white, size = size.small)

if i_flipLabels and flipDown
    label.new(bar_index, high * 1.0005, "▼", style = label.style_label_down, color = color.new(i_dist_cold, 20), textcolor = color.white, size = size.small)

// ═══════════════════════════════════════════════════════════
// § SIGNAL DOTS (primary signal dots with weight tiers)
// ═══════════════════════════════════════════════════════════

// Self-scaling strength: price distance through ST at flip, in ATR units (captured at flip bar)
var float flipStrength = 0.0

// On each confirmed flip, measure excursion magnitude
if flipUpConf
    flipStrength := math.abs(close[i_confirm] - stLine[i_confirm]) / math.max(atrRaw[i_confirm], 0.0001)
if flipDownConf
    flipStrength := math.abs(stLine[i_confirm] - close[i_confirm]) / math.max(atrRaw[i_confirm], 0.0001)

dotSize(float s) =>
    string sz = size.normal
    if s >= 0.9
        sz := size.huge
    else if s >= 0.4
        sz := size.large
    sz

dotTransp(float s) =>
    float t = 28.0
    if s >= 0.9
        t := 0.0
    else if s >= 0.4
        t := 12.0
    t

// ═══════════════════════════════════════════════════════════
// § PROBABILITY READ — forward return tracking
// ═══════════════════════════════════════════════════════════

var array<float> probArrBull = array.new<float>(0)
var array<float> probArrBear = array.new<float>(0)

// Record outcomes: detect a confirmed flip from i_horizon bars ago, measure outcome now
bullSigPast = flipUp[i_horizon]
bearSigPast = flipDown[i_horizon]

if i_probOn and barstate.isconfirmed
    if bullSigPast
        float ret = (close - close[i_horizon]) / math.max(close[i_horizon], 0.0001) * 100.0
        array.push(probArrBull, ret)
        if array.size(probArrBull) > i_maxSamp
            array.shift(probArrBull)
    if bearSigPast
        float ret = -((close - close[i_horizon]) / math.max(close[i_horizon], 0.0001) * 100.0)
        array.push(probArrBear, ret)
        if array.size(probArrBear) > i_maxSamp
            array.shift(probArrBear)

// Stats helper
calcStats(array<float> arr) =>
    int   n      = array.size(arr)
    float med    = n > 0 ? array.median(arr) : na
    float avg    = n > 0 ? array.avg(arr)    : na
    float stdev  = n > 0 ? array.stdev(arr)  : na
    float p16    = n > 0 ? array.percentile_nearest_rank(arr, 16) : na
    float p84    = n > 0 ? array.percentile_nearest_rank(arr, 84) : na
    float wins   = 0.0
    if n > 0
        for i = 0 to n - 1
            if array.get(arr, i) > 0
                wins += 1.0
    float wr     = n > 0 ? wins / n * 100.0 : na
    [n, med, avg, stdev, p16, p84, wr]

[bN, bMed, bAvg, bStdev, bP16, bP84, bWr] = calcStats(probArrBull)
[dN, dMed, dAvg, dStdev, dP16, dP84, dWr] = calcStats(probArrBear)

// ── A. RECENT FORM — stats over the last K outcomes per direction (the current regime).
calcRecent(array<float> arr, int k) =>
    int n = array.size(arr)
    int m = math.min(k, n)
    bool has = m >= 15
    float med = na
    float wr  = na
    if has
        array<float> sl = array.slice(arr, n - m, n)
        med := array.median(sl)
        int wins = 0
        for i = 0 to m - 1
            if array.get(sl, i) > 0
                wins += 1
        wr := wins / m * 100.0
    [m, has, med, wr]

[rbN, rbHas, rbMed, rbWr] = calcRecent(probArrBull, i_recentN)
[rdN, rdHas, rdMed, rdWr] = calcRecent(probArrBear, i_recentN)

// ── B. WILSON lower bound (90% one-sided): "backed" = statistical evidence the win
// rate exceeds 50%, automatically strict on small samples — not an arbitrary fixed bar.
wilsonLB(float wrPct, int n) =>
    float lb = na
    if n > 0 and not na(wrPct)
        float p   = wrPct / 100.0
        float z   = zEv
        float den = 1.0 + z * z / n
        float ctr = p + z * z / (2.0 * n)
        float mrg = z * math.sqrt(p * (1.0 - p) / n + z * z / (4.0 * n * n))
        lb := (ctr - mrg) / den * 100.0
    lb

bool bullBackedLong   = bN >= i_minSamp and wilsonLB(bWr, bN) > 50.0 and bMed > 0
bool bearBackedLong   = dN >= i_minSamp and wilsonLB(dWr, dN) > 50.0 and dMed > 0
bool bullBackedRecent = rbHas and wilsonLB(rbWr, rbN) > 50.0 and rbMed > 0
bool bearBackedRecent = rdHas and wilsonLB(rdWr, rdN) > 50.0 and rdMed > 0
// LEAN: a building edge — point estimate ≥ 55% but the Wilson bar not yet cleared.
bool bullLeanRecent = rbHas and not bullBackedRecent and rbWr >= 55.0 and rbMed > 0
bool bearLeanRecent = rdHas and not bearBackedRecent and rdWr >= 55.0 and rdMed > 0

// Edge clock: when did the recent form last qualify as backed, per direction.
var int lastEdgeBullT = na
var int lastEdgeBearT = na
if barstate.isconfirmed and bullBackedRecent
    lastEdgeBullT := time
if barstate.isconfirmed and bearBackedRecent
    lastEdgeBearT := time
agoTxt(int t) =>
    string s = "—"
    if not na(t)
        float dh = (time - t) / 3600000.0
        s := dh < 1 ? "now" : dh < 48 ? str.tostring(math.round(dh, 0)) + "h ago" : str.tostring(math.round(dh / 24.0, 0)) + "d ago"
    s

// Active-direction aliases — pick the side of the most recent confirmed signal
var bool lastSigBull = true
if flipUpConf
    lastSigBull := true
if flipDownConf
    lastSigBull := false

probN    = lastSigBull ? bN   : dN
probMed  = lastSigBull ? bMed : dMed
probP16  = lastSigBull ? bP16 : dP16
probP84  = lastSigBull ? bP84 : dP84
probWr   = lastSigBull ? bWr  : dWr
probStd  = lastSigBull ? bStdev : dStdev
hasStats = probN >= i_minSamp

recBackedAct  = lastSigBull ? bullBackedRecent : bearBackedRecent
longBackedAct = lastSigBull ? bullBackedLong   : bearBackedLong
leanAct       = lastSigBull ? bullLeanRecent   : bearLeanRecent
evBacked = recBackedAct
evMixed  = not evBacked and (leanAct or longBackedAct or (hasStats and (probWr >= 48.0 or probMed > -0.2)))

dotGlyph = evBacked ? "●" : (evMixed ? "◐" : "○")

// Draw signal dots (label-based for tooltips)
string bullVerdict = "\n→ " + (bullBackedRecent and bullBackedLong ? "recent + long-run back follow-through" : bullBackedRecent ? "recent form backs it — long-run mixed" : bullLeanRecent ? "recent form leans bullish — building, not yet evidence" : bullBackedLong ? "long-run backed, recent form cooled" : "no edge in history here — reads as noise")
string bearVerdict = "\n→ " + (bearBackedRecent and bearBackedLong ? "recent + long-run back follow-through" : bearBackedRecent ? "recent form backs it — long-run mixed" : bearLeanRecent ? "recent form leans bearish — building, not yet evidence" : bearBackedLong ? "long-run backed, recent form cooled" : "no edge in history here — reads as noise")
bullStatsTip = (bN >= i_minSamp ? ("Read at fire: recent " + (rbHas ? str.tostring(rbWr, "0.0") + "% ↑ (last " + str.tostring(rbN) + ")" : "n<15") + " · long-run " + str.tostring(bWr, "0.0") + "% ↑ · med " + str.tostring(bMed, "0.00") + "% · n=" + str.tostring(bN)) : ("Read at fire: history still gathering (n=" + str.tostring(bN) + ")")) + bullVerdict
bearStatsTip = (dN >= i_minSamp ? ("Read at fire: recent " + (rdHas ? str.tostring(rdWr, "0.0") + "% ↑ (last " + str.tostring(rdN) + ")" : "n<15") + " · long-run " + str.tostring(dWr, "0.0") + "% ↑ · med " + str.tostring(dMed, "0.00") + "% · n=" + str.tostring(dN)) : ("Read at fire: history still gathering (n=" + str.tostring(dN) + ")")) + bearVerdict

var array<label> dotLabels    = array.new<label>(0)
var array<int>   dotBars      = array.new<int>(0)
var array<string> dotBaseTips = array.new<string>(0)
var array<bool>  dotIsBull   = array.new<bool>(0)

if barstate.isconfirmed
    // Update pending outcomes
    if array.size(dotBars) > 0
        for i = 0 to array.size(dotBars) - 1
            int   db  = array.get(dotBars, i)
            int   age = bar_index - db
            if age == i_horizon
                label lbl        = array.get(dotLabels, i)
                string baseTip   = array.get(dotBaseTips, i)
                bool   isBull    = array.get(dotIsBull, i)
                float  entryClose = close[i_horizon]
                float  exitClose  = close
                float  rawRet    = entryClose > 0 ? (exitClose - entryClose) / entryClose * 100.0 : 0.0
                float  dirRet    = isBull ? rawRet : -rawRet
                string outcomeTxt = "\nOutcome after " + str.tostring(i_horizon) + "b: " + (dirRet > 0 ? "+" : "") + str.tostring(dirRet, "0.00") + "% (in signal direction)"
                label.set_tooltip(lbl, baseTip + outcomeTxt)
    // Fire new dots
    if flipUpConf
        float  sz   = flipStrength
        string glyph = evBacked ? "●" : (evMixed ? "◐" : "○")
        string tip  = "Bull flip (▲) · strength " + str.tostring(sz, "0.00") + " ATR\n" + bullStatsTip + "\nOutcome after " + str.tostring(i_horizon) + "b: pending…"
        label lbl   = label.new(bar_index[i_confirm], low[i_confirm] - atrRaw[i_confirm] * 1.4, glyph, style = label.style_none, color = color.new(color.black, 100), textcolor = color.new(i_dist_gold, dotTransp(sz)), size = dotSize(sz), tooltip = tip)
        array.push(dotLabels, lbl)
        array.push(dotBars, bar_index[i_confirm])
        array.push(dotBaseTips, "Bull flip (▲) · strength " + str.tostring(sz, "0.00") + " ATR\n" + bullStatsTip)
        array.push(dotIsBull, true)
        if array.size(dotLabels) > 400
            label.delete(array.shift(dotLabels))
            array.shift(dotBars)
            array.shift(dotBaseTips)
            array.shift(dotIsBull)
    if flipDownConf
        float  sz   = flipStrength
        string glyph = evBacked ? "●" : (evMixed ? "◐" : "○")
        string tip  = "Bear flip (▼) · strength " + str.tostring(sz, "0.00") + " ATR\n" + bearStatsTip + "\nOutcome after " + str.tostring(i_horizon) + "b: pending…"
        label lbl   = label.new(bar_index[i_confirm], high[i_confirm] + atrRaw[i_confirm] * 1.4, glyph, style = label.style_none, color = color.new(color.black, 100), textcolor = color.new(i_dist_cold, dotTransp(sz)), size = dotSize(sz), tooltip = tip)
        array.push(dotLabels, lbl)
        array.push(dotBars, bar_index[i_confirm])
        array.push(dotBaseTips, "Bear flip (▼) · strength " + str.tostring(sz, "0.00") + " ATR\n" + bearStatsTip)
        array.push(dotIsBull, false)
        if array.size(dotLabels) > 400
            label.delete(array.shift(dotLabels))
            array.shift(dotBars)
            array.shift(dotBaseTips)
            array.shift(dotIsBull)

// Background history circles (plot-based, no label cap)
bullDotY = flipUp  ? low  * 0.998 : na
bearDotY = flipDown ? high * 1.002 : na
plot(bullDotY, "Bull history", color = color.new(i_dist_gold, 55), style = plot.style_circles, linewidth = 2)
plot(bearDotY, "Bear history", color = color.new(i_dist_cold, 55), style = plot.style_circles, linewidth = 2)

// ═══════════════════════════════════════════════════════════
// § PROJECTION CONE (anchored at flip price)
// ═══════════════════════════════════════════════════════════

var box  coneBox    = na
var line coneMed    = na
var label coneLabel = na
var float coneBase  = na
var int   coneBar   = na
var bool  coneBull  = true

if flipUpConf
    coneBase := close[i_confirm]
    coneBar  := bar_index[i_confirm]
    coneBull := true
if flipDownConf
    coneBase := close[i_confirm]
    coneBar  := bar_index[i_confirm]
    coneBull := false

if i_probOn and i_coneOn and barstate.islast and not na(coneBase) and hasStats
    box.delete(coneBox)
    line.delete(coneMed)
    label.delete(coneLabel)
    float cBase   = coneBase
    int   cBar    = coneBar
    float pricePct = cBase / 100.0
    float loPrice = cBase + probP16 * pricePct
    float hiPrice = cBase + probP84 * pricePct
    float medPrice = cBase + probMed * pricePct
    int   x2      = cBar + i_horizon
    color boxClr  = coneBull ? i_dist_gold : i_dist_cold
    coneBox   := box.new(cBar, hiPrice, x2, loPrice, border_color = color.new(boxClr, 50), bgcolor = color.new(boxClr, 82))
    coneMed   := line.new(cBar, medPrice, x2, medPrice, color = color.new(boxClr, 20), style = line.style_dashed, width = 1)
    string medTxt = "med " + (probMed >= 0 ? "+" : "") + str.tostring(probMed, "0.00") + "%"
    coneLabel := label.new(x2, medPrice, medTxt, style = label.style_label_left, color = color.new(color.black, 60), textcolor = color.rgb(224, 168, 0), size = size.small)

// ═══════════════════════════════════════════════════════════
// § DISTRIBUTION PANEL (KDE bell curve)
// ═══════════════════════════════════════════════════════════

// Panel draws to the right of the last bar — bounded oscillator-style coords not applicable
// for price overlay: we place the panel in a fixed price-range above recent price action

var array<box>     panelSlices  = array.new<box>(0)
var line           panelZero    = na
var label          panelZeroLbl = na
var line           panelMedLine = na
var label          panelMedLbl  = na
var line           panelLiveLine = na
var label          panelLiveLbl  = na
var polyline       panelGauss   = na
var label          panelGather  = na

// ta.* must run every bar — calling it inside the islast block returns na.
float panelRefHi = ta.highest(high, 50)
float panelRefLo = ta.lowest(low, 50)

if i_probOn and i_panelOn and barstate.islast
    // Clean up old objects
    if array.size(panelSlices) > 0
        for i = 0 to array.size(panelSlices) - 1
            box.delete(array.get(panelSlices, i))
    array.clear(panelSlices)
    line.delete(panelZero)
    label.delete(panelZeroLbl)
    line.delete(panelMedLine)
    label.delete(panelMedLbl)
    line.delete(panelLiveLine)
    label.delete(panelLiveLbl)
    polyline.delete(panelGauss)
    label.delete(panelGather)
    // Use active-direction array
    array<float> activeArr = lastSigBull ? probArrBull : probArrBear
    int   pN     = array.size(activeArr)
    // Panel anchor — ta.* hoisted to global scope (rule 7: never call ta.* conditionally)
    float recentHi  = panelRefHi
    float recentLo  = panelRefLo
    float pRange    = math.max(recentHi - recentLo, close * 0.01)
    float panelH    = pRange * 0.20
    float panelBase = recentHi + pRange * 0.04
    float panelTop  = panelBase + panelH
    int   xStart    = bar_index + i_horizon + 6
    int   xEnd      = xStart + 40
    int   xWidth    = xEnd - xStart
    if pN < i_minSamp
        panelGather := label.new(xStart + 5, panelBase + panelH * 0.5, "gathering — n=" + str.tostring(pN), style = label.style_label_center, color = color.new(color.black, 60), textcolor = color.new(color.white, 45), size = size.small)
    else
        float pMed  = array.median(activeArr)
        float pAvg  = array.avg(activeArr)
        float pStd  = array.stdev(activeArr)
        float p16v  = array.percentile_nearest_rank(activeArr, 16)
        float p84v  = array.percentile_nearest_rank(activeArr, 84)
        float halfBand = math.max(math.abs(p84v - p16v) / 2.0, 0.01)
        float domLo  = pMed - 2.5 * halfBand
        float domHi  = pMed + 2.5 * halfBand
        float domW   = math.max(domHi - domLo, 0.01)
        int   nSlices = 40
        float bw     = math.max(1.06 * nz(pStd, halfBand) * math.pow(pN, -0.2), domW / 40.0)
        // Compute KDE densities
        array<float> dens = array.new<float>(nSlices, 0.0)
        float maxDens = 0.0
        for s = 0 to nSlices - 1
            float cx   = domLo + (s + 0.5) * domW / nSlices
            float d    = 0.0
            for j = 0 to pN - 1
                float v = array.get(activeArr, j)
                float z = (cx - v) / bw
                d += math.exp(-0.5 * z * z)
            array.set(dens, s, d)
            if d > maxDens
                maxDens := d
        // Draw slices
        for s = 0 to nSlices - 1
            float nd = maxDens > 0 ? array.get(dens, s) / maxDens : 0.0
            if nd > 0.02
                float sliceX1   = xStart + s
                float sliceX2   = xStart + s + 1
                float sliceVal  = domLo + (s + 0.5) * domW / nSlices
                // Map slice position in domain [0..1] to colour
                float colPos    = (sliceVal - domLo) / domW
                color c1 = heatCol(colPos, 28, i_dist_gold, i_dist_cold)
                color c2 = heatCol(colPos, 55, i_dist_gold, i_dist_cold)
                color c3 = heatCol(colPos, 80, i_dist_gold, i_dist_cold)
                // Three stacked vertical segments
                float h0 = panelBase
                float h1 = panelBase + panelH * nd * 0.30
                float h2 = panelBase + panelH * nd * 0.62
                float h3 = panelBase + panelH * nd
                box b3 = box.new(int(sliceX1), h3, int(sliceX2), h2, border_color = na, bgcolor = c1)
                box b2 = box.new(int(sliceX1), h2, int(sliceX2), h1, border_color = na, bgcolor = c2)
                box b1 = box.new(int(sliceX1), h1, int(sliceX2), h0, border_color = na, bgcolor = c3)
                array.push(panelSlices, b3)
                array.push(panelSlices, b2)
                array.push(panelSlices, b1)
        // Zero line
        float zeroX  = domW > 0 ? xStart + int((0.0 - domLo) / domW * nSlices) : xStart + nSlices / 2
        panelZero    := line.new(int(zeroX), panelBase, int(zeroX), panelTop, color = color.new(color.gray, 55), style = line.style_dotted, width = 1)
        panelZeroLbl := label.new(int(zeroX), panelBase, "0", style = label.style_label_up, color = color.new(color.black, 80), textcolor = color.new(color.gray, 40), size = size.tiny)
        // Median line
        float medX   = domW > 0 ? xStart + int((pMed - domLo) / domW * nSlices) : xStart + nSlices / 2
        panelMedLine := line.new(int(medX), panelBase, int(medX), panelTop + panelH * 0.08, color = color.new(color.rgb(224, 168, 0), 20), style = line.style_dashed, width = 1)
        string medLblTxt = (lastSigBull ? "bull · " : "bear · ") + "med " + (pMed >= 0 ? "+" : "") + str.tostring(pMed, "0.00") + "%"
        panelMedLbl  := label.new(int(medX), panelTop + panelH * 0.10, medLblTxt, style = label.style_label_center, color = color.new(color.black, 55), textcolor = color.rgb(224, 168, 0), size = size.small)
        // Live return line (most recent signal still inside horizon)
        bool inHorizon = not na(coneBar) and (bar_index - coneBar) < i_horizon
        if inHorizon and not na(coneBase)
            float liveRet = coneBase > 0 ? (close - coneBase) / coneBase * 100.0 : 0.0
            float dirLive = coneBull ? liveRet : -liveRet
            float liveX   = domW > 0 ? xStart + int((dirLive - domLo) / domW * nSlices) : xStart + nSlices / 2
            panelLiveLine := line.new(int(liveX), panelBase, int(liveX), panelBase + panelH * 0.70, color = color.new(color.white, 20), style = line.style_solid, width = 1)
            string liveTxt = "live " + (dirLive >= 0 ? "+" : "") + str.tostring(dirLive, "0.00") + "%"
            panelLiveLbl  := label.new(int(liveX), panelBase + panelH * 0.72, liveTxt, style = label.style_label_center, color = color.new(color.black, 55), textcolor = color.white, size = size.tiny)
        // Gaussian overlay
        if not na(pStd) and pStd > 0
            array<chart.point> gPts = array.new<chart.point>(0)
            int gSteps = 25
            for gi = 0 to gSteps - 1
                float gx  = domLo + gi * domW / (gSteps - 1)
                float gz  = (gx - pAvg) / pStd
                float gpdf = math.exp(-0.5 * gz * gz)
                int   gxi  = xStart + int(gi * nSlices / (gSteps - 1))
                float gyi  = panelBase + panelH * gpdf
                array.push(gPts, chart.point.from_index(gxi, gyi))
            panelGauss := polyline.new(gPts, curved = true, line_color = color.new(color.white, 45), line_width = 1)

// ═══════════════════════════════════════════════════════════
// § MINI-READOUT (chart-anchored label stack)
// ═══════════════════════════════════════════════════════════

var array<label> readoutLabels = array.new<label>(0)

// Build readout text values
string stateDir  = trendDir == 1 ? "bullish" : "bearish"
string stateZone = trendDir == 1 ? "above ST" : "below ST"
string stateRow  = "ST " + str.tostring(math.round(stLine, 2)) + " · " + stateDir + " · " + stateZone

string adaptTxt  = i_adaptive ? "adaptive mult " + str.tostring(effMult, "0.00") : "fixed mult " + str.tostring(i_mult, "0.0")
string htfTxt    = i_htfOn ? "HTF " + i_htfTf + ": " + (htfTrendDir == 1 ? "bull" : "bear") : ""
string ctxRow    = adaptTxt + (i_htfOn ? "  |  " + htfTxt : "")

string bullRow   = bN >= i_minSamp ? ("Bull flips (" + str.tostring(i_horizon) + "b n=" + str.tostring(bN) + "):  " + str.tostring(bWr, "0.0") + "% ↑  med " + str.tostring(bMed, "0.00") + "%  1σ " + str.tostring(bP16, "0.00") + "…" + str.tostring(bP84, "0.00") + "%") : ("Bull flips (" + str.tostring(i_horizon) + "b n=" + str.tostring(bN) + "):  gathering")
string bearRow   = dN >= i_minSamp ? ("Bear flips (" + str.tostring(i_horizon) + "b n=" + str.tostring(dN) + "):  " + str.tostring(dWr, "0.0") + "% ↓  med " + str.tostring(dMed, "0.00") + "%  1σ " + str.tostring(dP16, "0.00") + "…" + str.tostring(dP84, "0.00") + "%") : ("Bear flips (" + str.tostring(i_horizon) + "b n=" + str.tostring(dN) + "):  gathering")

// Build the Read sentence
float recWrAct  = lastSigBull ? rbWr : rdWr
int   recNAct   = lastSigBull ? rbN  : rdN
bool  recHasAct = lastSigBull ? rbHas : rdHas
string readVerdict = ""
if recBackedAct and longBackedAct
    readVerdict := "Read: recent + long-run back follow-through (" + str.tostring(recWrAct, "0.0") + "% ↑ last " + str.tostring(recNAct) + ", " + str.tostring(probWr, "0.0") + "% ↑ n=" + str.tostring(probN) + ")"
else if recBackedAct
    readVerdict := "Read: recent form backs it (" + str.tostring(recWrAct, "0.0") + "% ↑ last " + str.tostring(recNAct) + ") — long-run mixed"
else if leanAct
    readVerdict := "Read: recent form leans " + (lastSigBull ? "bullish" : "bearish") + " (" + str.tostring(recWrAct, "0.0") + "% ↑ last " + str.tostring(recNAct) + ") — building, not yet evidence"
else if longBackedAct
    readVerdict := "Read: long-run backed, but recent form cooled (" + str.tostring(recWrAct, "0.0") + "% ↑ last " + str.tostring(recNAct) + ")"
else if hasStats
    readVerdict := "Read: no edge in history here (recent " + (recHasAct ? str.tostring(recWrAct, "0.0") + "% ↑" : "n<15") + ", long-run " + str.tostring(probWr, "0.0") + "% ↑) — treat as noise"
else
    readVerdict := "Read: " + stateDir + " posture — gathering flip history (n<" + str.tostring(i_minSamp) + ")"

string footRow   = "Essentials · past flip outcomes on this chart, not a prediction"

// Y positions anchored below/right of chart (price-relative, above panel)
float recentHiR  = ta.highest(high, 50)
float recentLoR  = ta.lowest(low, 50)
float pRangeR    = math.max(recentHiR - recentLoR, close * 0.01)
float readBase   = recentLoR - pRangeR * 0.10
float rowStep    = pRangeR * 0.105

if barstate.islast and i_probOn and i_readoutOn
    if array.size(readoutLabels) > 0
        for i = 0 to array.size(readoutLabels) - 1
            label.delete(array.get(readoutLabels, i))
    array.clear(readoutLabels)
    int rxBase = bar_index + 3
    color accentActive = lastSigBull ? i_dist_gold : i_dist_cold
    label l0 = label.new(rxBase, readBase - rowStep * 0, stateRow, style = label.style_label_center, color = color.new(color.black, 15), textcolor = color.white, size = size.normal)
    label l1 = label.new(rxBase, readBase - rowStep * 1, ctxRow, style = label.style_label_center, color = color.new(color.black, 15), textcolor = color.new(color.white, 20), size = size.small)
    label l2 = label.new(rxBase, readBase - rowStep * 2, bullRow, style = label.style_label_center, color = color.new(color.black, 15), textcolor = color.new(i_dist_gold, 0), size = size.small)
    label l3 = label.new(rxBase, readBase - rowStep * 3, bearRow, style = label.style_label_center, color = color.new(color.black, 15), textcolor = color.new(i_dist_cold, 0), size = size.small)
    string edgeRow = "Edge last seen — bull " + agoTxt(lastEdgeBullT) + " · bear " + agoTxt(lastEdgeBearT)
    label l4 = label.new(rxBase, readBase - rowStep * 4, edgeRow, style = label.style_label_center, color = color.new(color.black, 35), textcolor = color.new(color.silver, 20), size = size.small)
    label l5 = label.new(rxBase, readBase - rowStep * 5, readVerdict, style = label.style_label_center, color = color.new(color.black, 15), textcolor = color.new(accentActive, 0), size = size.small)
    label l6 = label.new(rxBase, readBase - rowStep * 6, footRow, style = label.style_label_center, color = color.new(color.black, 15), textcolor = color.new(color.gray, 30), size = size.tiny)
    array.push(readoutLabels, l0)
    array.push(readoutLabels, l1)
    array.push(readoutLabels, l2)
    array.push(readoutLabels, l3)
    array.push(readoutLabels, l4)
    array.push(readoutLabels, l5)
    array.push(readoutLabels, l6)

// ═══════════════════════════════════════════════════════════
// § ALERTS
// ═══════════════════════════════════════════════════════════

bullFlipAlert  = flipUpConf   and barstate.isconfirmed
bearFlipAlert  = flipDownConf and barstate.isconfirmed
bullStrongAlert = flipUpConf  and flipStrength >= 0.9 and barstate.isconfirmed
bearStrongAlert = flipDownConf and flipStrength >= 0.9 and barstate.isconfirmed
bullBackedAlert = flipUpConf  and evBacked and barstate.isconfirmed
bearBackedAlert = flipDownConf and evBacked and barstate.isconfirmed
bullStrongBacked = flipUpConf and flipStrength >= 0.9 and evBacked and barstate.isconfirmed
bearStrongBacked = flipDownConf and flipStrength >= 0.9 and evBacked and barstate.isconfirmed

alertcondition(bullFlipAlert, title = "ST [P] — Trend flip UP", message = "Supertrend Tempered: trend flipped bullish. Past flip stats on this chart as context — not a prediction.")
alertcondition(bearFlipAlert, title = "ST [P] — Trend flip DOWN", message = "Supertrend Tempered: trend flipped bearish. Past flip stats on this chart as context — not a prediction.")
alertcondition(bullStrongAlert, title = "ST [P] — Strong flip UP", message = "Supertrend Tempered: strong bullish flip (deep ATR excursion). Past flip stats on this chart as context — not a prediction.")
alertcondition(bearStrongAlert, title = "ST [P] — Strong flip DOWN", message = "Supertrend Tempered: strong bearish flip (deep ATR excursion). Past flip stats on this chart as context — not a prediction.")
alertcondition(bullBackedAlert, title = "ST [P] — Flip UP (history-backed)", message = "Supertrend Tempered: bullish flip where this chart's own history backed follow-through (win rate >= 55%, positive median). Description of past signals, not a prediction.")
alertcondition(bearBackedAlert, title = "ST [P] — Flip DOWN (history-backed)", message = "Supertrend Tempered: bearish flip where this chart's own history backed follow-through (win rate >= 55%, positive median). Description of past signals, not a prediction.")
alertcondition(bullStrongBacked, title = "ST [P] — Strong flip UP (history-backed)", message = "Supertrend Tempered: strong bullish flip AND this chart's own history backed follow-through. Description of past signals, not a prediction.")
alertcondition(bearStrongBacked, title = "ST [P] — Strong flip DOWN (history-backed)", message = "Supertrend Tempered: strong bearish flip AND this chart's own history backed follow-through. Description of past signals, not a prediction.")
````
