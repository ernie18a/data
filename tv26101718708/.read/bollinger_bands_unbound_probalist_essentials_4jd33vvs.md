# Bollinger Bands Unbound [Probalist Essentials]

- url: https://www.tradingview.com/script/4JD33vvs-Bollinger-Bands-Unbound-Probalist-Essentials/
- type: indicator
- pine_id: PUB;a31d66b2812141e3b2de03babae21005
- version: 1.0

## Description

A Bollinger Bands that actually tells you when not to fade the band. Most BBand scripts show a band touch and leave you to guess whether it's a reversal or the first bar of a trend walk. This one answers that. The Band-Walk Guard flags every stretch where price keeps closing outside the band — trend mode, fade suppressed — and the Reversion Map measures, on your actual chart history, where confirmed fades went: what fraction tagged the basis, what the median reversion distance was, how wide the 1σ spread is, and whether the recent regime still matches the long-run.

Built for traders who want more than a line on a chart. The squeeze regime, the walk length, the basis-reach rate, the distribution panel — each answers a specific question about volatility state and mean-reversion quality that the default indicator leaves you to figure out yourself.

🟡 WHY THIS VERSION

Most Bollinger scripts treat every band touch as a trade. This one flags the band walk so you know when it's a trend, not a fade. The Reversion Map goes further: it counts how often your own chart's confirmed fades actually tagged the basis, shows the median reversion distance and a 1σ spread as a bell curve right of price, and splits bull from bear (they're different animals in a drifting market). You get a Wilson-backed verdict — not a fixed 60% bar, but a proper statistical lower bound — plus recent vs long-run form so you can see when the edge has changed regime. The edge clock shows when backed evidence last fired, not just whether it 'exists'. It keeps score honestly: small n prints 'gathering', wide bands stay wide, no numbers are hidden.

🟡 HOW IT WORKS

Bollinger Bands: basis = SMA(src, len) — or EMA via the Basis MA type input (the bands stay basis ± mult × stdev either way); upper/lower = basis ± mult × stdev(src, len). %B = (src − lower) / (upper − lower). Bandwidth = (upper − lower) / basis × 100, expressed as a percentage of price so it's scale-free across any instrument.

The Band-Walk Guard counts consecutive confirmed closes outside each band. A walk counter ticking upward is trend state — the outer band edge ignites in the heat ramp colour so you see it immediately. The Reversion Map fires only when price confirms back inside: a confirmed re-entry after a close beyond the lower band is a bullish fade; beyond the upper band is bearish. Each confirmed fade's outcome is recorded i_horizon bars later (the distance in %return, signed in the signal's direction), building two rolling arrays (bull/bear) of up to 200 outcomes. From those arrays: win-rate, median, 16th–84th percentile (≈1σ), Wilson lower bound, and recent-form over the last 60 outcomes. The bell curve drawn right of price is the kernel-smoothed empirical density of those returns — what actually happened, not a fitted model. Squeeze uses a rolling bandwidth percentile: self-calibrating, never an absolute number, works across all volatility regimes. With the optional RSI confluence filter on, a fade only counts when RSI was at an extreme on the excursion bar — and because the outcome arrays rebuild over the full history, toggling the filter shows like-for-like what the classic BB+RSI double-confirm does to the numbers on this chart.

🟡 KEY FEATURES
[list]
[*]Band-Walk Guard: counts consecutive outside closes and flags trend state with an ignited band edge. During a walk no fade can fire by definition — a fade requires the confirmed close back inside, the very bar that ends the walk — so the guard shows you why the tool is silent
[*]Reversion Map: empirical forward-return distribution per direction (bull/bear fades tracked separately), shown as a kernel-smoothed bell curve right of price
[*]Basis-reach rate: % of past fades that tagged the basis within the horizon, displayed as a compact label on the basis line — the natural mean-reversion target with its own base rate
[*]Squeeze detection: self-calibrating bandwidth percentile (default 10th over 120 bars), squeeze shading, release-breakout alert
[*]Weighted signal dots: excursion depth (in rolling stdev units) drives dot size via self-calibrating 60th/90th percentile thresholds — tier 3 dots are the deep outlier fades
[*]Wilson-backed verdict: lower bound of win-rate tested against 50% at user-chosen confidence (80/90/95%); recent form (last 60 outcomes) vs long-run both shown
[*]Edge clock: stamps when backed (●) and leaning (◐) evidence last appeared on an actual signal — tells you if the edge is live or stale
[*]Probalist heat ramp: %B mapped to ±100 drives the fill colour from strong blue (price at lower band) through mint neutral to orange/amber (price at upper band)
[*]Optional RSI confluence filter — the classic BB+RSI double-confirm, built in. With the filter on, the Reversion Map measures the filtered signal, so you can A/B on your own chart whether the famous combo actually improves the outcomes.
[*]Reversion-complete markers: a small ✓ on the basis line the moment a live fade tags its mean-reversion target — the exact event the basis-reach rate counts, so the entry dot and the exit ✓ tell the whole arc on the chart.
[/list]

🟡 HOW TO USE
[list]
[*]Band walk in readout? That's trend state. The outer band edge ignites — use it as a filter, not a fade setup. Wait for the walk to end and a confirmed re-entry before looking for a fade.
[*]Fade signal (gold dot below price = bullish, blue dot above = bearish) fires on confirmed close back inside the band. Dot size = excursion depth; larger dots = deeper, statistically rarer excursions.
[*]Check the Reversion Map rows in the readout: 'n' below 20 = gathering, don't weight the stats. Once n grows, median and the 1σ band tell you how far fades typically carried and how consistent they were.
[*]Basis-reach rate on the basis line: if 70%+ of past lower-band fades tagged the basis within 20 bars, the basis is the realistic mean-reversion target on this chart — a number to weigh, not an instruction.
[*]Squeeze shading (green tint) = bandwidth at the bottom decile. A squeeze release with a close outside the band often starts a new walk, not a fade — the readout flags it.
[*]Evidence-gated alerts fire only when Wilson lower bound > 50% — that's a statistical bar, not a 50/50 flip. A backed signal with a small median (e.g. +0.15% on a 5-minute chart) may not survive round-trip costs; the edge read is about direction bias, not net P&L.
[*]Combine with a trend filter above (e.g. price vs 200 SMA) to take only same-direction fades — bullish fades when above the 200, bearish when below. Reduces signal count, improves composition.
[*]Non-repainting by construction: the confirmation bar closes, then the signal fires. Realtime mode (confirm=0) updates on the unconfirmed bar — note the repaint risk if you use it.
[*]Curious whether the BB+RSI double-confirm helps on your chart? Turn on the RSI confluence filter and compare the readout stats with the filter off — the arrays rebuild over the full history, so the comparison is like-for-like.
[/list]

🟡 PAIRS WELL WITH

A simple trend filter (price vs a longer moving average, or ADX slope direction) tells you which side of the mean-reversion to favour — the Reversion Map treats bull and bear fades separately, but a trend context makes even those reads sharper. Volume (relative volume or OBV) helps validate whether a fade has the force to carry: a low-volume re-entry into the band after a walk is weaker context than one with a volume spike. For timing confluence, a momentum oscillator (RSI or Stochastic) reaching oversold/overbought at the same time as a fade signal gives a second read on exhaustion. Key daily or weekly support/resistance levels provide a structural backdrop — a lower-band fade off a major S/R is meaningfully different from one in open air. None of these gate the signal here; they're the context a trader builds around it.

Bollinger Bands Unbound gives you the two answers the default version never does: whether a band excursion is a walk (stay out) or a confirmed fade (measure it), and where that fade actually went on your own chart. The statistics are descriptive — your history, counted honestly. Use the walk guard to stay out of trend mode, the Reversion Map to understand what confirmed fades have been worth, and the evidence-gated alerts when the record actually supports a bias.

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

// What it shows: Bollinger Bands with a Band-Walk Guard (suppress naive fades during trends)
// and a Reversion Map (empirical stats on where confirmed fades actually carried).
// Method: Classic BB = SMA(src,len) ± mult×stdev(src,len). Fade signal = confirmed close
// back inside the band after closing beyond it. Walk = consecutive closes outside.
// How to use:
//   • Gold/blue dots = confirmed fade signals (bullish/bearish). Size = excursion depth.
//   • 'Walking' state in readout = trend mode; no fade dot fires during a walk.
//   • Distribution panel (right of price) = empirical forward-return density of past fades.
//   • Basis-reach tag on the basis line = % of past fades that tagged the middle band.
//   • Squeeze shading = low-volatility regime; release breakout often starts a new walk.
//   • ✓ on the basis line = a live fade tagged its mean-reversion target (what the reach-stat counts).
//   • Optional RSI confluence filter (BB+RSI double-confirm) — the stats then measure the filtered signal.

//@version=6
indicator("Bollinger Bands Unbound [Probalist Essentials]", shorttitle="BB [P]", overlay=true, max_lines_count=200, max_labels_count=500, max_boxes_count=300, max_polylines_count=10)

// ─────────────────────────────────────────────────────────────
// § INPUTS
// ─────────────────────────────────────────────────────────────

// ■ Calculation
i_src       = input.source(close,  "Source",            group="■ Calculation", tooltip="Price series for the BB calculation. Close is standard.", display=display.none)
i_len       = input.int(20,         "Length",            group="■ Calculation", minval=2, maxval=500, tooltip="SMA/stdev lookback. 20 is the John Bollinger default.", display=display.none)
i_mult      = input.float(2.0,      "Multiplier",        group="■ Calculation", minval=0.1, maxval=10.0, step=0.1, tooltip="Band width in standard deviations. 2.0 = ~95% of price action inside.", display=display.none)
i_maType    = input.string("SMA",     "Basis MA type",     group="■ Calculation", options=["SMA","EMA"], tooltip="Moving-average type for the basis (middle band). SMA is the John Bollinger classic; EMA hugs price tighter and turns earlier.", display=display.none)
i_confirm   = input.int(1,          "Confirm bars",      group="■ Calculation", minval=0, maxval=5, tooltip="0 = realtime (may repaint on the live bar). 1+ = confirmed close, non-repainting. Default 1 = one closed bar after re-entry.", display=display.none)

// ■ Squeeze
i_sqzLen    = input.int(120,        "Squeeze window",    group="■ Squeeze", minval=20, maxval=500, tooltip="Rolling window for bandwidth percentile. Wider = smoother regime detection.", display=display.none)
i_sqzPct    = input.int(10,         "Squeeze percentile",group="■ Squeeze", minval=1, maxval=40, tooltip="Bandwidth at or below this rolling percentile = squeeze ON. 10 = bottom decile.", display=display.none)

// ■ Momentum confirm
i_rsiConf   = input.bool(false,     "RSI confluence filter", group="■ Momentum confirm", tooltip="The classic BB+RSI double-confirm: a fade only counts when RSI was at an extreme on the excursion bar. Toggle it and watch the Reversion Map rebuild — it then measures the filtered signal, so you see exactly what the filter does to win rate and median on this chart.", display=display.none)
i_rsiLen    = input.int(14,         "↳ RSI length",          group="■ Momentum confirm", minval=2, maxval=100, tooltip="Lookback for the confluence RSI.", display=display.none)
i_rsiOS     = input.int(30,         "↳ Oversold level",      group="■ Momentum confirm", minval=1, maxval=49, tooltip="Bull fades require RSI at or below this on the excursion bar.", display=display.none)
i_rsiOB     = input.int(70,         "↳ Overbought level",    group="■ Momentum confirm", minval=51, maxval=99, tooltip="Bear fades require RSI at or above this on the excursion bar.", display=display.none)

// ■ Probability Read
i_probOn    = input.bool(true,      "Probability Read (master)",    group="■ Probability Read", tooltip="Master switch for all empirical stats, distribution panel, cone, tooltips, and evidence-gated alerts. Disabling speeds up the script.", display=display.none)
i_horizon   = input.int(20,         "↳ Horizon (bars)",              group="■ Probability Read", minval=1, maxval=100, tooltip="How many bars forward to measure each fade's outcome. Default 20 matches the BB length.", display=display.none)
i_maxSamp   = input.int(200,        "↳ Max samples",                 group="■ Probability Read", minval=30, maxval=1000, tooltip="Maximum outcomes kept in each direction's rolling array. Older ones drop off.", display=display.none)
i_minSamp   = input.int(20,         "↳ Min samples",                 group="■ Probability Read", minval=5, maxval=100, tooltip="Below this count, show 'gathering' instead of statistics.", display=display.none)
i_spacing   = input.int(20,         "↳ Signal spacing (bars)",       group="■ Probability Read", minval=1, maxval=200, tooltip="Minimum bars between recorded signals per direction. Prevents correlated samples from band-hugging.", display=display.none)
i_recentW   = input.int(60,         "↳ Recent window (outcomes)",    group="■ Probability Read", minval=15, maxval=500, tooltip="Tail of each array used for 'recent form'. Smaller = more responsive to regime change.", display=display.none)
i_wilson    = input.string("80%",   "↳ Evidence strictness (Wilson)",group="■ Probability Read", options=["80%","90%","95%"], tooltip="Confidence level for Wilson lower bound. 80% is the recommended default — demanding 95% on short histories almost always returns 'no edge'.", display=display.none)
i_cone      = input.bool(true,      "↳ Projection Cone",             group="■ Probability Read", tooltip="Draw a 1σ projection box from the most recent signal bar to the horizon.", display=display.none)
i_panel     = input.bool(true,      "↳ Distribution Panel (bell)",   group="■ Probability Read", tooltip="Kernel-smoothed empirical density of past fade returns, drawn right of the last bar.", display=display.none)
i_readout   = input.bool(true,      "↳ Readout panel",               group="■ Probability Read", tooltip="Corner-docked mini-readout showing current state, stats, and the Read verdict.", display=display.none)
i_readPos   = input.string("Top right", "↳ Readout corner",          group="■ Probability Read", options=["Top right","Top left","Bottom right","Bottom left","Middle right"], tooltip="Move the readout to a clear corner if the distribution panel overlaps.", display=display.none)
i_sigDens   = input.string("Medium+","↳ Signal density",             group="■ Probability Read", options=["All","Medium+","Backed"], tooltip="All = every spaced signal; Medium+ = medium/heavy strength tiers; Backed = Wilson-backed direction only.", display=display.none)

// ■ Higher Timeframe
i_htfOn     = input.bool(false,     "Show HTF BB line",  group="■ Higher Timeframe", tooltip="Display a single HTF basis line as quiet context. Display-only — does not gate or score signals.", display=display.none)
i_htfAuto   = input.bool(true,      "Auto rung (chart TF)", group="■ Higher Timeframe", tooltip="Automatically derives the next timeframe rung from your chart period.", display=display.none)
i_htfMan    = input.timeframe("D",  "HTF (manual)",      group="■ Higher Timeframe", tooltip="Used when Auto rung is OFF.", display=display.none)

// ■ Probalist Theme
i_col_hot   = input.color(color.rgb(249,115,22),  "Wave hot (bullish end)",  group="■ Probalist Theme", tooltip="Upper end of the heat ramp — price running the upper band.", display=display.none)
i_col_cold  = input.color(color.rgb(37,99,235),   "Wave cold (bearish end)", group="■ Probalist Theme", tooltip="Lower end of the heat ramp — price running the lower band.", display=display.none)
i_dist_gold = input.color(color.rgb(224,168,0),   "Gold accent (bullish)",   group="■ Probalist Theme", tooltip="Colour for bullish signals, upper band, and distribution warm side.", display=display.none)
i_dist_cold = input.color(color.rgb(50,160,255),  "Blue accent (bearish)",   group="■ Probalist Theme", tooltip="Colour for bearish signals, lower band, and distribution cool side.", display=display.none)
i_glow      = input.bool(true,      "Glow Effect",       group="■ Probalist Theme", tooltip="ON = layered halo behind the band fill. OFF = clean bands only.", display=display.none)


// ─────────────────────────────────────────────────────────────
// § PROBALIST HEAT
// ─────────────────────────────────────────────────────────────
normScore(float score) =>
    (math.max(-100.0, math.min(100.0, score)) + 100.0) / 200.0

heatCol(float pos, float transp, color col_hot, color col_cold) =>
    color col = na
    if pos >= 0.80
        col := color.from_gradient(pos, 0.80, 1.0, color.rgb(245,158,11), col_hot)
    else if pos >= 0.62
        col := color.from_gradient(pos, 0.62, 0.80, color.rgb(251,191,36), color.rgb(245,158,11))
    else if pos >= 0.50
        col := color.from_gradient(pos, 0.50, 0.62, color.rgb(167,243,208), color.rgb(251,191,36))
    else if pos >= 0.40
        col := color.from_gradient(pos, 0.40, 0.50, color.rgb(56,189,248), color.rgb(167,243,208))
    else if pos >= 0.22
        col := color.from_gradient(pos, 0.22, 0.40, color.rgb(6,182,212), color.rgb(56,189,248))
    else
        col := color.from_gradient(pos, 0.0, 0.22, col_cold, color.rgb(6,182,212))
    color.new(col, transp)

// ─────────────────────────────────────────────────────────────
// § CORE BB CALCULATION
// ─────────────────────────────────────────────────────────────
basisSma = ta.sma(i_src, i_len)
basisEma = ta.ema(i_src, i_len)
basis    = i_maType == "EMA" ? basisEma : basisSma
dev   = ta.stdev(i_src, i_len)
upper = basis + i_mult * dev
lower = basis - i_mult * dev

// %B: 0=lower band, 0.5=basis, 1=upper band
pctB  = dev != 0.0 ? (i_src - lower) / (upper - lower) : 0.5

// Bandwidth as % of basis (scale-free)
bw    = basis != 0.0 ? (upper - lower) / basis * 100.0 : 0.0

// Confluence RSI (computed always; the filter only gates the signal definition)
float rsiVal = ta.rsi(i_src, i_rsiLen)

// Globals hoisted so ta.* never runs inside conditional blocks (rule 7)
float atr14   = ta.atr(14)
float recHi50 = ta.highest(50)
float recLo50 = ta.lowest(50)

// Signed percent text — manual sign; a "+0.00" format pattern renders "-+x" on negatives
signFmt(float v) =>
    (v >= 0 ? "+" : "") + str.tostring(v, "0.00")

// ─────────────────────────────────────────────────────────────
// § SQUEEZE DETECTION (self-calibrating bandwidth percentile)
// ─────────────────────────────────────────────────────────────
var array<float> bwArr = array.new<float>()
array.push(bwArr, bw)
if array.size(bwArr) > i_sqzLen
    array.shift(bwArr)

bwPct     = array.size(bwArr) >= 2 ? array.percentile_nearest_rank(bwArr, i_sqzPct) : bw
sqzOn     = bw <= bwPct
// Percentile rank of current bw for display
var int bwRankPct = 0
if array.size(bwArr) >= 2
    int cnt = 0
    for k = 0 to array.size(bwArr) - 1
        if array.get(bwArr, k) <= bw
            cnt += 1
    bwRankPct := math.round(cnt * 100.0 / array.size(bwArr))

var bool sqzWas = false
sqzRelease = sqzWas and not sqzOn
if barstate.isconfirmed
    sqzWas := sqzOn

// ─────────────────────────────────────────────────────────────
// § BAND-WALK GUARD
// ─────────────────────────────────────────────────────────────
// Track consecutive closes outside each band
var int walkUpBars   = 0
var int walkDnBars   = 0
var bool walkingUp   = false
var bool walkingDn   = false

if barstate.isconfirmed
    if close > upper
        walkUpBars := walkUpBars + 1
        walkDnBars := 0
    else if close < lower
        walkDnBars := walkDnBars + 1
        walkUpBars := 0
    else
        walkUpBars := 0
        walkDnBars := 0
    walkingUp := walkUpBars > 0
    walkingDn := walkDnBars > 0


// ─────────────────────────────────────────────────────────────
// § FADE SIGNAL DETECTION (non-repainting, confirmed close)
// ─────────────────────────────────────────────────────────────
// Raw fade: was outside, now back inside
rawBullFade = close[1] < lower[1] and close > lower and close < upper and (not i_rsiConf or rsiVal[1] <= i_rsiOS)
rawBearFade = close[1] > upper[1] and close < upper and close > lower and (not i_rsiConf or rsiVal[1] >= i_rsiOB)

// Confirmation gating per rule 11b
bullFadeRaw = rawBullFade[i_confirm] and barstate.isconfirmed
bearFadeRaw = rawBearFade[i_confirm] and barstate.isconfirmed

// Signal spacing per §H6-b2
var int lastBullBar = -9999
var int lastBearBar = -9999
bullSpaced = bar_index - lastBullBar >= i_spacing
bearSpaced = bar_index - lastBearBar >= i_spacing
bullFade   = bullFadeRaw and bullSpaced
bearFade   = bearFadeRaw and bearSpaced

if bullFade
    lastBullBar := bar_index
if bearFade
    lastBearBar := bar_index

// Band-walk start detection
var bool wasInsidePrev = true
bullWalkStart = barstate.isconfirmed and close > upper and wasInsidePrev
bearWalkStart = barstate.isconfirmed and close < lower and wasInsidePrev
if barstate.isconfirmed
    wasInsidePrev := close >= lower and close <= upper

// Squeeze release breakout
sqzRelBull = sqzRelease and close > upper and barstate.isconfirmed
sqzRelBear = sqzRelease and close < lower and barstate.isconfirmed

// ─────────────────────────────────────────────────────────────
// § EXCURSION DEPTH (self-calibrating signal strength)
// ─────────────────────────────────────────────────────────────
// Depth = how far beyond the band price closed, in stdev units
depthBull = dev[1 + i_confirm] > 0.0 ? (lower[1 + i_confirm] - close[1 + i_confirm]) / dev[1 + i_confirm] : 0.0
depthBear = dev[1 + i_confirm] > 0.0 ? (close[1 + i_confirm] - upper[1 + i_confirm]) / dev[1 + i_confirm] : 0.0

var array<float> depthsBull = array.new<float>()
var array<float> depthsBear = array.new<float>()

if bullFade
    array.push(depthsBull, math.max(0.0, depthBull))
    if array.size(depthsBull) > 300
        array.shift(depthsBull)
if bearFade
    array.push(depthsBear, math.max(0.0, depthBear))
    if array.size(depthsBear) > 300
        array.shift(depthsBear)

// Percentile thresholds for dot sizing (self-calibrating)
bullP60 = array.size(depthsBull) >= 30 ? array.percentile_nearest_rank(depthsBull, 60) : 0.3
bullP90 = array.size(depthsBull) >= 30 ? array.percentile_nearest_rank(depthsBull, 90) : 0.6
bearP60 = array.size(depthsBear) >= 30 ? array.percentile_nearest_rank(depthsBear, 60) : 0.3
bearP90 = array.size(depthsBear) >= 30 ? array.percentile_nearest_rank(depthsBear, 90) : 0.6

dotSizeTxt(float depth, float p60, float p90) =>
    string s = size.normal
    if depth >= p90
        s := size.huge
    else if depth >= p60
        s := size.large
    s

dotTransp(float depth, float p60, float p90) =>
    float t = 28.0
    if depth >= p90
        t := 0.0
    else if depth >= p60
        t := 12.0
    t

// ─────────────────────────────────────────────────────────────
// § PROBABILITY READ — OUTCOME RECORDING
// ─────────────────────────────────────────────────────────────
var array<float> probArrBull   = array.new<float>()
var array<float> probArrBear   = array.new<float>()
var array<float> basisReachBull = array.new<float>() // 1 = reached basis, 0 = not
var array<float> basisReachBear = array.new<float>()

// Pending queues: [bar_index_of_signal, entry_close]
var array<int>   pendBullBar   = array.new<int>()
var array<float> pendBullEntry = array.new<float>()
var array<bool>  pendBullBasis = array.new<bool>() // did basis get hit yet
var array<int>   pendBearBar   = array.new<int>()
var array<float> pendBearEntry = array.new<float>()
var array<bool>  pendBearBasis = array.new<bool>()

// Enqueue on signal
if i_probOn and bullFade
    array.push(pendBullBar,   bar_index)
    array.push(pendBullEntry, close)
    array.push(pendBullBasis, false)

if i_probOn and bearFade
    array.push(pendBearBar,   bar_index)
    array.push(pendBearEntry, close)
    array.push(pendBearBasis, false)

// Per-bar flags: a pending fade tags the basis for the FIRST time on this bar
// (= the reversion-complete / exit moment that the basis-reach stat counts)
bool bullTagNow = false
bool bearTagNow = false

// Update pending — mark basis touches
if i_probOn and barstate.isconfirmed
    if array.size(pendBullBar) > 0
        for qi = 0 to array.size(pendBullBar) - 1
            if not array.get(pendBullBasis, qi)
                if high >= basis
                    array.set(pendBullBasis, qi, true)
                    bullTagNow := true
    if array.size(pendBearBar) > 0
        for qi = 0 to array.size(pendBearBar) - 1
            if not array.get(pendBearBasis, qi)
                if low <= basis
                    array.set(pendBearBasis, qi, true)
                    bearTagNow := true

// Finalise outcomes when horizon completes
if i_probOn and barstate.isconfirmed
    if array.size(pendBullBar) > 0
        bool keepLooping = true
        while keepLooping and array.size(pendBullBar) > 0
            int signalBar   = array.get(pendBullBar,   0)
            float entryPx   = array.get(pendBullEntry, 0)
            bool  hitBasis  = array.get(pendBullBasis, 0)
            if bar_index - signalBar >= i_horizon
                float ret = entryPx != 0.0 ? (close - entryPx) / entryPx * 100.0 : 0.0
                array.push(probArrBull, ret)
                array.push(basisReachBull, hitBasis ? 1.0 : 0.0)
                if array.size(probArrBull) > i_maxSamp
                    array.shift(probArrBull)
                if array.size(basisReachBull) > i_maxSamp
                    array.shift(basisReachBull)
                array.shift(pendBullBar)
                array.shift(pendBullEntry)
                array.shift(pendBullBasis)
            else
                keepLooping := false
    if array.size(pendBearBar) > 0
        bool keepLooping2 = true
        while keepLooping2 and array.size(pendBearBar) > 0
            int signalBar2   = array.get(pendBearBar,   0)
            float entryPx2   = array.get(pendBearEntry, 0)
            bool  hitBasis2  = array.get(pendBearBasis, 0)
            if bar_index - signalBar2 >= i_horizon
                float ret2 = entryPx2 != 0.0 ? (entryPx2 - close) / entryPx2 * 100.0 : 0.0
                array.push(probArrBear, ret2)
                array.push(basisReachBear, hitBasis2 ? 1.0 : 0.0)
                if array.size(probArrBear) > i_maxSamp
                    array.shift(probArrBear)
                if array.size(basisReachBear) > i_maxSamp
                    array.shift(basisReachBear)
                array.shift(pendBearBar)
                array.shift(pendBearEntry)
                array.shift(pendBearBasis)
            else
                keepLooping2 := false

// ─────────────────────────────────────────────────────────────
// § STATS HELPER
// ─────────────────────────────────────────────────────────────
calcStats(array<float> arr) =>
    int   n      = array.size(arr)
    float wr     = 0.0
    float med    = 0.0
    float p16    = 0.0
    float p84    = 0.0
    float avg    = 0.0
    float stdev  = 0.0
    if n > 0
        int wins = 0
        for k = 0 to n - 1
            if array.get(arr, k) > 0.0
                wins += 1
        wr    := wins * 100.0 / n
        med   := array.median(arr)
        p16   := array.percentile_nearest_rank(arr, 16)
        p84   := array.percentile_nearest_rank(arr, 84)
        avg   := array.avg(arr)
        stdev := array.stdev(arr)
    [n, wr, med, p16, p84, avg, stdev]

// Wilson lower bound helper
wilsonLB(float wr, int n, float z) =>
    float p = wr / 100.0
    float denom = 1.0 + z * z / n
    float centre = p + z * z / (2.0 * n)
    float margin = z * math.sqrt(p * (1.0 - p) / n + z * z / (4.0 * n * n))
    denom > 0.0 ? (centre - margin) / denom * 100.0 : 0.0

float zScore = i_wilson == "95%" ? 1.960 : i_wilson == "90%" ? 1.645 : 1.282

[nB,  wrB,  medB,  p16B,  p84B,  avgB,  sdB]  = calcStats(probArrBull)
[nBr, wrBr, medBr, p16Br, p84Br, avgBr, sdBr] = calcStats(probArrBear)

// Recent-form slices
recentArrBull = nB  > 0 ? array.slice(probArrBull,  math.max(0, nB  - i_recentW), nB)  : array.new<float>(0)
recentArrBear = nBr > 0 ? array.slice(probArrBear, math.max(0, nBr - i_recentW), nBr) : array.new<float>(0)

[rnB,  rwrB,  rmedB,  rp16B,  rp84B,  ravgB,  rsdB]  = calcStats(recentArrBull)
[rnBr, rwrBr, rmedBr, rp16Br, rp84Br, ravgBr, rsdBr] = calcStats(recentArrBear)

// Wilson verdicts
bullHasStats   = nB  >= i_minSamp
bearHasStats   = nBr >= i_minSamp
bullRecentOk   = rnB  >= 15
bearRecentOk   = rnBr >= 15

bullWilsonLR   = bullHasStats  ? wilsonLB(wrB,   nB,  zScore) : 0.0
bearWilsonLR   = bearHasStats  ? wilsonLB(wrBr,  nBr, zScore) : 0.0
bullWilsonRec  = bullRecentOk  ? wilsonLB(rwrB,  rnB,  zScore) : 0.0
bearWilsonRec  = bearRecentOk  ? wilsonLB(rwrBr, rnBr, zScore) : 0.0

bullBackedLR   = bullHasStats  and bullWilsonLR  > 50.0 and medB  > 0.0
bearBackedLR   = bearHasStats  and bearWilsonLR  > 50.0 and medBr > 0.0
bullBackedRec  = bullRecentOk  and bullWilsonRec > 50.0 and rmedB  > 0.0
bearBackedRec  = bearRecentOk  and bearWilsonRec > 50.0 and rmedBr > 0.0
bullLeans      = bullRecentOk  and rwrB  >= 55.0 and rmedB  > 0.0 and not bullBackedRec
bearLeans      = bearRecentOk  and rwrBr >= 55.0 and rmedBr > 0.0 and not bearBackedRec

// Evidence for active signal
lastSigBull    = lastBullBar >= lastBearBar
activeMed      = lastSigBull ? medB  : medBr
activep16      = lastSigBull ? p16B  : p16Br
activep84      = lastSigBull ? p84B  : p84Br
activeHasStats = lastSigBull ? bullHasStats : bearHasStats

// Dot glyph
dotGlyph(bool backRec, bool backLR, bool lean) =>
    string g = "○"
    if backRec
        g := "●"
    else if lean or backLR
        g := "◐"
    g


// Basis-reach rates
basisReachRateBull = array.size(basisReachBull) > 0 ? array.avg(basisReachBull) * 100.0 : -1.0
basisReachRateBear = array.size(basisReachBear) > 0 ? array.avg(basisReachBear) * 100.0 : -1.0

// ─────────────────────────────────────────────────────────────
// § EDGE CLOCK
// ─────────────────────────────────────────────────────────────
var int bullClockBacked = na
var int bullClockLean   = na
var int bearClockBacked = na
var int bearClockLean   = na

if bullFade and barstate.isconfirmed
    if bullBackedRec
        bullClockBacked := bar_index
    if bullBackedRec or bullLeans
        bullClockLean   := bar_index

if bearFade and barstate.isconfirmed
    if bearBackedRec
        bearClockBacked := bar_index
    if bearBackedRec or bearLeans
        bearClockLean   := bar_index

fmtClock(int stamp) =>
    string txt = "—"
    if not na(stamp)
        int barsAgo = bar_index - stamp
        float secAgo = barsAgo * timeframe.in_seconds(timeframe.period)
        if barsAgo == 0
            txt := "now"
        else if secAgo < 3600.0
            txt := str.tostring(math.round(secAgo / 60.0)) + "m"
        else if secAgo < 172800.0
            txt := str.tostring(math.round(secAgo / 3600.0)) + "h"
        else
            txt := str.tostring(math.round(secAgo / 86400.0)) + "d"
    txt

// ─────────────────────────────────────────────────────────────
// § HEAT COLOUR (state = %B mapped to ±100)
// ─────────────────────────────────────────────────────────────
float bbState = (pctB - 0.5) * 200.0
color cMain   = heatCol(normScore(bbState), 0, i_col_hot, i_col_cold)

// ─────────────────────────────────────────────────────────────
// § HTF AUTO RUNG
// ─────────────────────────────────────────────────────────────
float chartSec = timeframe.in_seconds(timeframe.period)
string effHtf  = chartSec < 300 ? "5" : chartSec < 900 ? "15" : chartSec < 3600 ? "60" : chartSec < 14400 ? "240" : chartSec < 86400 ? "D" : chartSec < 604800 ? "W" : "M"
string htfTf   = i_htfAuto ? effHtf : i_htfMan

htfBasis = i_htfOn ? request.security(syminfo.tickerid, htfTf, (i_maType == "EMA" ? ta.ema(close, i_len) : ta.sma(close, i_len))[1], lookahead=barmerge.lookahead_off) : na

// ─────────────────────────────────────────────────────────────
// § WALK COLOUR (ignite the walking band edge)
// ─────────────────────────────────────────────────────────────
color walkColUp  = walkingUp ? color.new(i_col_hot,  5)  : color.new(i_dist_gold, 30)
color walkColDn  = walkingDn ? color.new(i_col_cold, 5)  : color.new(i_dist_cold, 30)
color upperCol   = walkColUp
color lowerCol   = walkColDn

// Squeeze shading: a faint bg when squeeze is on
color sqzBgCol   = sqzOn ? color.new(color.rgb(167,243,208), 90) : na

// ─────────────────────────────────────────────────────────────
// § PLOTS — BANDS + FILL
// ─────────────────────────────────────────────────────────────
// Big-area fill: use white-lift so band-to-band doesn't read as a dark block
color fillTop  = color.from_gradient(math.min(1.0, math.max(0.0, pctB)), 0.0, 1.0, color.new(color.white, 45), color.new(i_col_hot,  38))
color fillBot  = color.from_gradient(math.min(1.0, math.max(0.0, pctB)), 0.0, 1.0, color.new(i_col_cold, 38), color.new(color.white, 45))

pUpper  = plot(upper,  "Upper Band",  color=upperCol, linewidth=2, display=display.all)
pLower  = plot(lower,  "Lower Band",  color=lowerCol, linewidth=2, display=display.all)
plot(basis,  "Basis",       color=color.new(color.gray, 50), linewidth=1, display=display.all)
plot(htfBasis, "HTF Basis", color=color.new(color.gray, 65), linewidth=1, style=plot.style_linebr, display=display.all)

// Band fill — gradient that breathes with %B
fill(pUpper, pLower, top_value=upper, bottom_value=lower, top_color=fillTop, bottom_color=fillBot)

// Squeeze background
bgcolor(sqzBgCol, title="Squeeze shading", display=display.all)

// Glow layers under the upper/lower bands
pGlowU1 = plot(upper, "GlowU1", color=i_glow ? color.new(upperCol, 65) : na, linewidth=6,  display=display.all, editable=false)
pGlowU2 = plot(upper, "GlowU2", color=i_glow ? color.new(upperCol, 80) : na, linewidth=10, display=display.all, editable=false)
pGlowL1 = plot(lower, "GlowL1", color=i_glow ? color.new(lowerCol, 65) : na, linewidth=6,  display=display.all, editable=false)
pGlowL2 = plot(lower, "GlowL2", color=i_glow ? color.new(lowerCol, 80) : na, linewidth=10, display=display.all, editable=false)


// ─────────────────────────────────────────────────────────────
// § SIGNAL DOTS (weighted, with history tooltips)
// ─────────────────────────────────────────────────────────────
var array<label> dotLabels   = array.new<label>()
var array<int>   dotBars     = array.new<int>()
var array<string> dotTips    = array.new<string>()
var array<bool>  dotIsBull   = array.new<bool>()

buildReadVerdict(bool backRec, bool backLR, bool lean, float wr, int n, float med, float rwr, int rn) =>
    string v = ""
    if n < 1
        v := "gathering"
    else if backRec and backLR
        v := "recent + long-run back follow-through (" + str.tostring(math.round(rwr)) + "% ↑, last " + str.tostring(rn) + ")"
    else if backRec
        v := "recent form backs it (" + str.tostring(math.round(rwr)) + "% ↑, last " + str.tostring(rn) + ") — long-run mixed"
    else if lean
        v := "recent form leans (" + str.tostring(math.round(rwr)) + "% ↑, last " + str.tostring(rn) + ") — building, not yet evidence"
    else if backLR
        v := "long-run backed, but recent form cooled"
    else
        v := "no edge in history here — treat as noise"
    v

// Reversion-complete markers: the fade tagged its basis target (the exit the reach-stat counts)
plotchar(bullTagNow ? basis : na, "Reversion complete (bull fade tagged basis)", "✓", location.absolute, color.new(i_dist_gold, 10), size=size.tiny, display=display.pane)
plotchar(bearTagNow ? basis : na, "Reversion complete (bear fade tagged basis)", "✓", location.absolute, color.new(i_dist_cold, 10), size=size.tiny, display=display.pane)

// Draw baseline circles (plot, unlimited)
plot(bullFade ? low - atr14 * 1.4 : na,  "Bull baseline", style=plot.style_circles, color=color.new(i_dist_gold, 55), linewidth=2, offset=-i_confirm, display=display.all)
plot(bearFade ? high + atr14 * 1.4 : na, "Bear baseline", style=plot.style_circles, color=color.new(i_dist_cold, 55), linewidth=2, offset=-i_confirm, display=display.all)

// Build dot on fade signal
if i_probOn and (bullFade or bearFade) and barstate.isconfirmed
    bool  isBull   = bullFade
    float depth    = isBull ? depthBull : depthBear
    float p60      = isBull ? bullP60   : bearP60
    float p90      = isBull ? bullP90   : bearP90
    string szTxt   = dotSizeTxt(depth, p60, p90)
    float  trTxt   = dotTransp(depth, p60, p90)
    bool   bkRec   = isBull ? bullBackedRec  : bearBackedRec
    bool   bkLR    = isBull ? bullBackedLR   : bearBackedLR
    bool   ln      = isBull ? bullLeans      : bearLeans
    float  wr_     = isBull ? wrB    : wrBr
    int    n_      = isBull ? nB     : nBr
    float  med_    = isBull ? medB   : medBr
    float  rwr_    = isBull ? rwrB   : rwrBr
    int    rn_     = isBull ? rnB    : rnBr
    float  rp16_   = isBull ? rp16B  : rp16Br
    float  rp84_   = isBull ? rp84B  : rp84Br
    string glyph   = dotGlyph(bkRec, bkLR, ln)
    string verdict = buildReadVerdict(bkRec, bkLR, ln, wr_, n_, med_, rwr_, rn_)
    float  rsiExt  = rsiVal[i_confirm + 1]
    string baseTip = (isBull ? "Bull fade" : "Bear fade") + " · depth " + str.tostring(depth, "0.00") + "σ · RSI " + str.tostring(math.round(rsiExt)) + (i_rsiConf ? " (filter on)" : "") + "\nRead at fire: " + str.tostring(math.round(wr_)) + "% ↑ · med " + str.tostring(med_, "0.00") + "% · 1σ " + str.tostring(rp16_, "0.00") + "…" + str.tostring(rp84_, "0.00") + "% · n=" + str.tostring(n_) + "\n→ " + verdict
    string fullTip = baseTip + "\nOutcome after " + str.tostring(i_horizon) + "b: pending…"
    color  dotCol  = isBull ? color.new(i_dist_gold, trTxt) : color.new(i_dist_cold, trTxt)
    float  dotY    = isBull ? low  - atr14 * 1.4 : high + atr14 * 1.4
    // Density filter
    bool drawDot = true
    if i_sigDens == "Medium+"
        drawDot := depth >= p60
    else if i_sigDens == "Backed"
        drawDot := bkRec or bkLR
    if drawDot
        label newDot = label.new(bar_index - i_confirm, dotY, glyph, style=label.style_none, color=color.new(color.black,100), textcolor=dotCol, size=szTxt, tooltip=fullTip)
        array.push(dotLabels, newDot)
        array.push(dotBars,   bar_index)
        array.push(dotTips,   baseTip)
        array.push(dotIsBull, isBull)
        if array.size(dotLabels) > 400
            label.delete(array.shift(dotLabels))
            array.shift(dotBars)
            array.shift(dotTips)
            array.shift(dotIsBull)

// Update tooltips for completed outcomes
if i_probOn and barstate.isconfirmed
    int dlSize = array.size(dotLabels)
    if dlSize > 0
        for di = 0 to dlSize - 1
            int dBar = array.get(dotBars, di)
            if bar_index - dBar == i_horizon
                float entryClose = close[i_horizon]
                bool  dIsBull    = array.get(dotIsBull, di)
                float ret        = entryClose != 0.0 ? (close - entryClose) / entryClose * 100.0 : 0.0
                float signedRet  = dIsBull ? ret : -ret
                string outLine   = "\nOutcome after " + str.tostring(i_horizon) + "b: " + signFmt(signedRet) + "% (in signal direction)"
                label.set_tooltip(array.get(dotLabels, di), array.get(dotTips, di) + outLine)

// ─────────────────────────────────────────────────────────────
// § PROJECTION CONE
// ─────────────────────────────────────────────────────────────
var box    coneBox    = na
var line   coneMed    = na
var label  coneLabel  = na
var float  coneEntry  = na
var int    coneSigBar = na
var bool   coneIsBull = true

if bullFade or bearFade
    coneEntry  := close
    coneSigBar := bar_index
    coneIsBull := bullFade

if i_probOn and i_cone and barstate.islast
    box.delete(coneBox)
    line.delete(coneMed)
    label.delete(coneLabel)
    if not na(coneSigBar) and activeHasStats
        float ep   = nz(coneEntry, close)
        float lo_  = activep16
        float hi_  = activep84
        float med_ = activeMed
        float pxLo = ep * (1.0 + lo_  / 100.0)
        float pxHi = ep * (1.0 + hi_  / 100.0)
        float pxMd = ep * (1.0 + med_ / 100.0)
        color cCone = coneIsBull ? color.new(i_dist_gold, 50) : color.new(i_dist_cold, 50)
        int   x1   = coneSigBar
        int   x2   = coneSigBar + i_horizon
        coneBox   := box.new(x1, pxHi, x2, pxLo, border_color=cCone, bgcolor=color.new(cCone, 82))
        coneMed   := line.new(x1, pxMd, x2, pxMd, color=color.new(color.rgb(224,168,0), 30), style=line.style_dashed, width=1)
        coneLabel := label.new(x2, pxMd, "med " + signFmt(med_) + "%", style=label.style_none, color=color.new(color.black,100), textcolor=color.rgb(224,168,0), size=size.tiny)

// ─────────────────────────────────────────────────────────────
// § BASIS-REACH RATE LABEL
// ─────────────────────────────────────────────────────────────
// One multi-line label — intra-label line spacing is pixel-based, so the two
// rows can never collide on zoom (two separate labels with price-unit spacing do)
var label basisLabel = na

if barstate.islast
    label.delete(basisLabel)
    if i_probOn
        string brrBullTxt = basisReachRateBull >= 0.0 and array.size(basisReachBull) >= i_minSamp ? str.tostring(math.round(basisReachRateBull)) + "% tag basis (" + str.tostring(i_horizon) + "b, n=" + str.tostring(array.size(basisReachBull)) + ")" : "basis reach: gathering"
        string brrBearTxt = basisReachRateBear >= 0.0 and array.size(basisReachBear) >= i_minSamp ? str.tostring(math.round(basisReachRateBear)) + "% tag basis (" + str.tostring(i_horizon) + "b, n=" + str.tostring(array.size(basisReachBear)) + ")" : "basis reach: gathering"
        basisLabel := label.new(bar_index + 3, basis, "↑ " + brrBullTxt + "\n↓ " + brrBearTxt, style=label.style_label_left, color=color.new(color.black, 35), textcolor=color.new(color.white, 12), size=size.tiny, tooltip="Share of past fades (per direction) where price tagged the basis within the horizon — the natural mean-reversion target, measured on this chart.")

// ─────────────────────────────────────────────────────────────
// § DISTRIBUTION PANEL (bell curve)
// ─────────────────────────────────────────────────────────────
var array<box>  panelBoxes  = array.new<box>()
var line        panelZero   = na
var line        panelMed    = na
var line        panelLive   = na
var label       panelZeroL  = na
var label       panelMedL   = na
var label       panelLiveL  = na
var label       panelGather = na
var polyline    gaussPoly   = na

if i_probOn and i_panel and barstate.islast
    // Cleanup
    if array.size(panelBoxes) > 0
        for bi = 0 to array.size(panelBoxes) - 1
            box.delete(array.get(panelBoxes, bi))
    array.clear(panelBoxes)
    line.delete(panelZero)
    line.delete(panelMed)
    line.delete(panelLive)
    label.delete(panelZeroL)
    label.delete(panelMedL)
    label.delete(panelLiveL)
    label.delete(panelGather)
    polyline.delete(gaussPoly)

    // Use active direction's array for panel
    array<float> panArr  = lastSigBull ? probArrBull : probArrBear
    int          panN    = array.size(panArr)
    float        panMed  = lastSigBull ? medB  : medBr
    float        panAvg  = lastSigBull ? avgB  : avgBr
    float        panSd   = lastSigBull ? sdB   : sdBr
    float        panP16  = lastSigBull ? p16B  : p16Br
    float        panP84  = lastSigBull ? p84B  : p84Br
    color        panAccent = lastSigBull ? i_dist_gold : i_dist_cold

    // Panel geometry — overlay: 45% of recent high-low range above price action
    float recentHi   = recHi50
    float recentLo   = recLo50
    float rangeSize  = recentHi - recentLo
    float panelBase  = recentHi + rangeSize * 0.05
    float panelH     = rangeSize * 0.45
    int   startBar   = bar_index + i_horizon + 6
    int   nSlices    = 40

    if panN < i_minSamp
        panelGather := label.new(startBar + 20, panelBase + panelH * 0.5, "gathering — n=" + str.tostring(panN), style=label.style_none, color=color.new(color.black,100), textcolor=color.new(color.gray, 40), size=size.small)
    else
        float halfBand  = math.max(0.01, (panP84 - panP16) / 2.0)
        float domCenter = panMed
        float domLo     = domCenter - 2.5 * halfBand
        float domHi     = domCenter + 2.5 * halfBand
        float domW      = domHi - domLo
        float bw_kde    = math.max(1.06 * nz(panSd, halfBand) * math.pow(panN, -0.2), domW / nSlices)

        // Compute densities
        array<float> dens = array.new<float>(nSlices, 0.0)
        float maxD = 0.0001
        for si = 0 to nSlices - 1
            float xc = domLo + (si + 0.5) * domW / nSlices
            float d  = 0.0
            for ki = 0 to panN - 1
                float diff = (xc - array.get(panArr, ki)) / bw_kde
                d += math.exp(-0.5 * diff * diff)
            array.set(dens, si, d)
            if d > maxD
                maxD := d

        // Draw slice boxes (3-layer vertical fade)
        for si = 0 to nSlices - 1
            float normD = array.get(dens, si) / maxD
            if normD > 0.02
                float slicePos = (si + 0.5) / nSlices
                color sc = heatCol(slicePos, 0, i_dist_gold, i_dist_cold)
                int   bx1 = startBar + si
                int   bx2 = startBar + si + 1
                float yTop  = panelBase + normD * panelH
                float yMid1 = panelBase + normD * panelH * 0.62
                float yMid2 = panelBase + normD * panelH * 0.30
                box b1 = box.new(bx1, yTop,  bx2, yMid1, border_color=na, bgcolor=color.new(sc, 28))
                box b2 = box.new(bx1, yMid1, bx2, yMid2, border_color=na, bgcolor=color.new(sc, 55))
                box b3 = box.new(bx1, yMid2, bx2, panelBase, border_color=na, bgcolor=color.new(sc, 80))
                array.push(panelBoxes, b1)
                array.push(panelBoxes, b2)
                array.push(panelBoxes, b3)

        // Gaussian overlay polyline
        array<chart.point> gPts = array.new<chart.point>()
        int nGauss = 25
        for gi = 0 to nGauss - 1
            float xg  = domLo + gi * domW / (nGauss - 1)
            float zg  = panSd > 0.0 ? (xg - panAvg) / panSd : 0.0
            float pdf = math.exp(-0.5 * zg * zg)
            float yg  = panelBase + pdf * panelH
            int   xbi = startBar + math.round((xg - domLo) / domW * nSlices)
            array.push(gPts, chart.point.from_index(xbi, yg))
        gaussPoly := polyline.new(gPts, curved=true, line_color=color.new(color.white, 45), line_width=1)

        // Zero line
        float zeroX_ = domW > 0.0 ? (0.0 - domLo) / domW * nSlices : 0.0
        int   zeroXi = startBar + math.round(zeroX_)
        panelZero := line.new(zeroXi, panelBase, zeroXi, panelBase + panelH * 0.85, color=color.new(color.gray, 60), style=line.style_dotted, width=1)
        panelZeroL := label.new(zeroXi, panelBase - rangeSize * 0.01, "0", style=label.style_none, color=color.new(color.black,100), textcolor=color.new(color.gray,50), size=size.tiny)

        // Median line
        float medX_ = domW > 0.0 ? (panMed - domLo) / domW * nSlices : 0.0
        int   medXi = startBar + math.round(medX_)
        panelMed  := line.new(medXi, panelBase, medXi, panelBase + panelH, color=color.new(color.rgb(224,168,0), 30), style=line.style_dashed, width=1)
        panelMedL := label.new(medXi, panelBase + panelH + rangeSize * 0.01, "med " + signFmt(panMed) + "%", style=label.style_none, color=color.new(color.black,100), textcolor=color.rgb(224,168,0), size=size.tiny)

        // Live return line (if inside horizon)
        bool inHorizon = not na(coneSigBar) and (bar_index - coneSigBar) < i_horizon and (bar_index - coneSigBar) >= 0
        if inHorizon and not na(coneEntry) and coneEntry != 0.0
            float liveRet  = coneIsBull ? (close - coneEntry) / coneEntry * 100.0 : (coneEntry - close) / coneEntry * 100.0
            float liveX_   = domW > 0.0 ? (liveRet - domLo) / domW * nSlices : 0.0
            int   liveXi   = startBar + math.round(liveX_)
            panelLive  := line.new(liveXi, panelBase, liveXi, panelBase + panelH * 0.70, color=color.white, style=line.style_solid, width=1)
            panelLiveL := label.new(liveXi, panelBase + panelH * 0.72, "live " + signFmt(liveRet) + "%", style=label.style_none, color=color.new(color.black,100), textcolor=color.white, size=size.tiny)

// ─────────────────────────────────────────────────────────────
// § MINI-READOUT TABLE
// ─────────────────────────────────────────────────────────────
string posStr = i_readPos == "Top left" ? position.top_left : i_readPos == "Bottom right" ? position.bottom_right : i_readPos == "Bottom left" ? position.bottom_left : i_readPos == "Middle right" ? position.middle_right : position.top_right

var table readTbl = table.new(posStr, 1, 6, bgcolor=color.new(color.black, 16), frame_color=color.new(color.gray, 65), frame_width=1, border_width=0)

if barstate.islast
    if i_probOn and i_readout
        // Row 0 — state
        string walkTxt   = walkingUp ? " · walk ↑ (" + str.tostring(walkUpBars) + "b)" : walkingDn ? " · walk ↓ (" + str.tostring(walkDnBars) + "b)" : " · walk —"
        string zoneTxt   = pctB > 0.90 ? "OB" : pctB < 0.10 ? "OS" : pctB > 0.60 ? "upper half" : pctB < 0.40 ? "lower half" : "mid"
        string row0      = "BB  %B " + str.tostring(pctB, "0.00") + walkTxt
        table.cell(readTbl, 0, 0, row0, text_color=cMain, text_size=size.normal, text_halign=text.align_left)
        // Row 1 — context
        string sqzTxt    = sqzOn ? "SQUEEZE ON · bw p" + str.tostring(bwRankPct) : "bw " + str.tostring(bw, "0.0") + "% (p" + str.tostring(bwRankPct) + ") · " + zoneTxt
        table.cell(readTbl, 0, 1, sqzTxt, text_color=color.new(color.white, 30), text_size=size.small, text_halign=text.align_left)
        // Row 2 — bull stats
        string bullStatRow = ""
        if bullHasStats
            bullStatRow := "Bull fades (" + str.tostring(i_horizon) + "b n=" + str.tostring(nB) + "):  " + str.tostring(math.round(wrB)) + "% ↑  med " + str.tostring(medB, "0.00") + "%  1σ " + str.tostring(p16B, "0.00") + "…" + str.tostring(p84B, "0.00") + "%"
        else
            bullStatRow := "Bull fades: gathering — n=" + str.tostring(nB)
        table.cell(readTbl, 0, 2, bullStatRow, text_color=color.new(i_dist_gold, 20), text_size=size.small, text_halign=text.align_left)
        // Row 3 — bear stats
        string bearStatRow = ""
        if bearHasStats
            bearStatRow := "Bear fades (" + str.tostring(i_horizon) + "b n=" + str.tostring(nBr) + "):  " + str.tostring(math.round(wrBr)) + "% ↑  med " + str.tostring(medBr, "0.00") + "%  1σ " + str.tostring(p16Br, "0.00") + "…" + str.tostring(p84Br, "0.00") + "%"
        else
            bearStatRow := "Bear fades: gathering — n=" + str.tostring(nBr)
        table.cell(readTbl, 0, 3, bearStatRow, text_color=color.new(i_dist_cold, 20), text_size=size.small, text_halign=text.align_left)
        // Row 4 — Read
        bool   aIsBull  = lastSigBull
        bool   aBkRec   = aIsBull ? bullBackedRec : bearBackedRec
        bool   aBkLR    = aIsBull ? bullBackedLR  : bearBackedLR
        bool   aLean    = aIsBull ? bullLeans      : bearLeans
        float  aWr      = aIsBull ? wrB   : wrBr
        int    aN       = aIsBull ? nB    : nBr
        float  aMed     = aIsBull ? medB  : medBr
        float  aRwr     = aIsBull ? rwrB  : rwrBr
        int    aRn      = aIsBull ? rnB   : rnBr
        string sigName  = aIsBull ? "Bull fade" : "Bear fade"
        int    sigBarsAgo = aIsBull ? bar_index - lastBullBar : bar_index - lastBearBar
        color  readCol  = aIsBull ? color.new(i_dist_gold, 15) : color.new(i_dist_cold, 15)
        string readVerd = aN < i_minSamp ? "gathering history — no read yet" : buildReadVerdict(aBkRec, aBkLR, aLean, aWr, aN, aMed, aRwr, aRn)
        string readRow  = (aIsBull ? lastBullBar : lastBearBar) < 0 ? "Read: no confirmed fade yet on this chart" : "Read: " + sigName + " " + str.tostring(sigBarsAgo) + "b ago — " + readVerd
        table.cell(readTbl, 0, 4, readRow, text_color=readCol, text_size=size.small, text_halign=text.align_left)
        // Row 5 — footer + edge clock
        string clockRow = "Edge last seen — bull ●" + fmtClock(bullClockBacked) + " ◐" + fmtClock(bullClockLean) + " · bear ●" + fmtClock(bearClockBacked) + " ◐" + fmtClock(bearClockLean)
        table.cell(readTbl, 0, 5, clockRow + "  ·  Essentials · this chart", text_color=color.new(color.gray, 40), text_size=size.tiny, text_halign=text.align_left)
    else
        table.clear(readTbl, 0, 0, 0, 5)

// ─────────────────────────────────────────────────────────────
// § ALERTS
// ─────────────────────────────────────────────────────────────
bool evBullBacked = i_probOn and bullBackedRec
bool evBearBacked = i_probOn and bearBackedRec
bool evBullBkStr  = evBullBacked and bullFade and depthBull >= bullP90
bool evBearBkStr  = evBearBacked and bearFade and depthBear >= bearP90

alertcondition(bullFade,             title="BB Unbound: Bullish fade",                        message="Bollinger Bands Unbound — bullish fade confirmed (price closed back inside lower band). Past signals on this chart, not a prediction.")
alertcondition(bearFade,             title="BB Unbound: Bearish fade",                        message="Bollinger Bands Unbound — bearish fade confirmed (price closed back inside upper band). Past signals on this chart, not a prediction.")
alertcondition(sqzOn and not sqzOn[1], title="BB Unbound: Squeeze ON",                        message="Bollinger Bands Unbound — squeeze detected: bandwidth entered bottom percentile. Low-volatility regime, breakout risk rising.")
alertcondition(sqzRelBull or sqzRelBear, title="BB Unbound: Squeeze Release",                message="Bollinger Bands Unbound — squeeze released with a close outside the band. Potential trend start. Past signals on this chart, not a prediction.")
alertcondition(bullWalkStart,        title="BB Unbound: Band-walk start (up)",                message="Bollinger Bands Unbound — price started walking the upper band. Fade signals suppressed during walk. This is trend context, not a reversal call.")
alertcondition(bearWalkStart,        title="BB Unbound: Band-walk start (down)",              message="Bollinger Bands Unbound — price started walking the lower band. Fade signals suppressed during walk. This is trend context, not a reversal call.")
alertcondition(evBullBacked and bullFade, title="BB Unbound: Bull fade (history-backed)",     message="Bollinger Bands Unbound — bullish fade where this chart's history backed follow-through (Wilson lower bound > 50%). Description of past signals, not a prediction.")
alertcondition(evBearBacked and bearFade, title="BB Unbound: Bear fade (history-backed)",     message="Bollinger Bands Unbound — bearish fade where this chart's history backed follow-through (Wilson lower bound > 50%). Description of past signals, not a prediction.")
alertcondition(evBullBkStr,          title="BB Unbound: Bull fade strong + history-backed",   message="Bollinger Bands Unbound — strong-depth bullish fade (top 10% excursion depth) where history backed follow-through. Description of past signals, not a prediction.")
alertcondition(evBearBkStr,          title="BB Unbound: Bear fade strong + history-backed",   message="Bollinger Bands Unbound — strong-depth bearish fade (top 10% excursion depth) where history backed follow-through. Description of past signals, not a prediction.")
````
