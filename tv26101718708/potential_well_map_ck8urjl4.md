# Potential Well Map

- url: https://www.tradingview.com/script/cK8urjL4-Potential-Well-Map/
- type: indicator
- pine_id: PUB;5740cf22b2f74770b9ab6c325b8a34d3
- version: 2.0

## Description

Overview

A volume or time profile tells you where price spent time. Potential Well Map tells you the forces acting at each level. It models the market as a particle drifting in a one-dimensional energy landscape and estimates that landscape directly from recent price action — the local drift (average next move) and diffusion (variance of the next move) at each price level — then integrates them into a potential curve. Its valleys are attractors (dynamical support/resistance that pulls price in); its peaks are barriers (levels price is repelled from). Two levels with identical occupancy can be opposite in dynamics — one an attractor, one a barrier — and this map tells them apart. It is a descriptive structure-and-risk map, not a predictive signal.

Why these components are ONE tool (mashup justification)

This is a four-stage chain where each stage produces something the previous one can't, and the honesty layer keeps the whole thing accountable:


Drift + diffusion per level — the raw forces. For every price bin, exponentially-decayed accumulators track the count, sum, and sum-of-squares of the next one-bar move that started there, giving the conditional first two moments (drift and diffusion) with recent regime weighted most. This is O(N) per bar — no window rebuild, no timeout.
The potential curve — the integral of drift ÷ diffusion. This turns the raw forces into a landscape whose valleys and peaks are attractors and barriers. It is the object an occupancy profile fundamentally cannot produce, because occupancy measures time spent, not the pull at a level.
Escape pressure — a bounded 0–100 breakout gauge derived from the remaining wall height between price and the nearest barrier. Because the potential is already diffusion-normalized, the escape factor is a clean exponential of the wall height, and it concentrates toward 100 as price approaches a wall.
The calibration harness — the honesty layer. When a barrier escape is flagged, did price actually travel that way more often than the unconditional base rate? It reports Hit / Base / Edge, resolved forward on confirmed bars only. The forces are a picture; the harness is the proof. Remove any one stage and the map either asserts structure it never tested, or shows a level with no dynamics behind it.


How it works

Price is detrended into a coordinate x = ln(price) − ln(slow anchor) so the distribution stays roughly centred as price trends. A grid of x-bins spans a few volatility units either side of zero. For each bin, the decayed accumulators build drift and diffusion; neighbour bins are sample-weighted-smoothed; the force (drift ÷ diffusion) is integrated into the potential; valleys and peaks that clear a prominence margin are marked as wells and barriers; and the escape pressure to each adjacent barrier is computed. Bins with too few effective samples are greyed out rather than trusted.

How to use it

Read the landscape as context. The green valley line is the active attractor — a mean-revert target. The dashed red lines are the barriers above and below. The shaded box is the expected range of a stiff well. In the dashboard, the escape pressures rise toward 100 as price nears a wall; a pin (fade-to-mean) is flagged only when price sits mid-well in a stiff, bounded valley, and an escape is flagged when price crosses a barrier after that side's pressure was already elevated. Watch the Edge row: a positive, matured Edge means escapes have led price on this instrument; near-zero means treat the map as structure only, not a trigger. It is never a standalone signal.

Universal & non-repainting

The source is an input and everything is self-scaling (vol-scaled grid, detrended coordinate), so it runs on any symbol and timeframe; defaults suit a liquid index/futures intraday chart. All statistics use closed past bars only — both the drift/diffusion accumulators and the calibration harness update solely on confirmed bars, so their numbers never inflate intrabar. The displayed landscape naturally evolves bar to bar because it is a live estimate, not a fixed level; confirmed escape and pin marks settle on the close of their bar. Edge figures are in-sample, close-to-close, with no costs — a study aid, not a backtest.

Originality

The building blocks are public physics and statistics: stochastic drift-diffusion dynamics, conditional-moment estimation of the drift and diffusion coefficients, and escape-rate theory. What's original is the application to a price series as a live, decayed, per-level energy landscape — the detrended coordinate, the exponential-memory conditional-moment accumulators, the diffusion-normalized potential integral, the prominence-gated well/barrier detection, the escape-pressure gauge, and the forward-calibration harness that scores escapes against their base rate. This is a clean-room implementation; no third-party Pine code is reused.

Concept credits


Stochastic drift-diffusion (Langevin) dynamics and the Fokker–Planck description of a probability landscape — Paul Langevin, Adriaan Fokker, Max Planck
Estimating drift and diffusion from the conditional moments of increments (Kramers–Moyal expansion) — Hendrik Kramers, José Enrique Moyal; exposition after Hannes Risken
Barrier escape / escape-rate theory — Kramers' escape-rate framework
Forward base-rate calibration discipline — standard out-of-sample evaluation practice


Disclaimer

Research and educational tool only. Not financial advice, no recommendation, no guarantee of results. It is an effective, empirical 1-D approximation of a memoryful, multi-factor market — treat "escape pressure" as a relative, normalized gauge, not a literal probability. Estimates are noisy where samples are sparse (the greyed bins). Indicators describe past behaviour; they do not predict the future. Trading carries risk of loss. Test out-of-sample and make your own decisions. The author accepts no liability.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                                   MPL-2.0
// POTENTIAL WELL MAP                                                                          v1.1
// ────────────────────────────────────────────────────────────────────────────────────────────
// OVERVIEW
//   A volume/time profile shows you WHERE price spent time (occupancy). This overlay shows the
//   FORCES acting at each level. It treats the market as a particle drifting in a 1-D energy
//   landscape and estimates that landscape directly from recent price action: the local drift
//   (average next move) and diffusion (variance of the next move) at each price level are measured,
//   then integrated into a potential curve. Its valleys are ATTRACTORS (dynamical support/
//   resistance that pulls price in); its peaks are BARRIERS (levels price is repelled from). The
//   depth of the current valley and the height of the walls on each side drive an ESCAPE-PRESSURE
//   gauge that rises as price nears a wall — a volatility-coupled breakout-pressure read. Two levels
//   with identical occupancy can be opposite in dynamics (one attractor, one barrier); this tells
//   them apart. It is a descriptive structure/risk map, not a predictive signal.
//
// WHAT MAKES IT DIFFERENT  (why these parts are ONE tool)
//   - DRIFT + DIFFUSION per level (conditional first two moments of the one-step move): the raw
//     forces, estimated with exponential memory so recent regime dominates — O(N) per bar, no
//     window rebuild, no timeout.
//   - POTENTIAL curve (integral of drift ÷ diffusion): turns the forces into a landscape whose
//     valleys/peaks are attractors/barriers — the object occupancy profiles can't produce.
//   - ESCAPE PRESSURE (from the remaining wall height to the nearest barrier): a bounded 0–100
//     breakout-pressure gauge that concentrates as price approaches a wall.
//   - CALIBRATION HARNESS: when a barrier escape is flagged, did price actually travel in that
//     direction more than the base rate? Reports Hit / Base / EDGE. Forces are a picture; the
//     harness is the honesty. Remove any one and the map either asserts structure it never tested
//     or shows a level with no dynamics behind it.
//
// HOW IT WORKS
//   Price is detrended into a coordinate x = ln(price) − ln(slow anchor) so the distribution stays
//   roughly centred as price trends. A grid of x-bins spans ± a few volatility units. For each bin,
//   exponentially-decayed accumulators track the count, sum and sum-of-squares of the next-bar move
//   that started there → drift and diffusion. Neighbour bins are sample-weighted-smoothed, the
//   force (drift ÷ diffusion) is integrated into the potential, valleys/peaks are found, and the
//   escape pressure to each adjacent barrier is computed. Bins with too few samples are greyed out.
//
// HOW TO USE
//   Read the landscape as context: the green valley line is the active attractor (mean-revert
//   target); dashed red lines are the barriers above/below; the shaded box is the expected range of
//   a stiff well. The dashboard's escape pressures rise toward 100 as price nears a wall — a pin
//   (fade-to-mean) is flagged only when price sits mid-well in a stiff, bounded valley; an escape is
//   flagged when price crosses a barrier after that side's pressure was already elevated. Watch the
//   EDGE row: a positive, matured Edge means escapes led price on this instrument; near-zero means
//   treat the map as structure only, not a trigger. Never a standalone signal.
//
// UNIVERSAL ACROSS MARKETS
//   Source is an input and everything is self-scaling (vol-scaled grid, detrended coordinate), so it
//   runs on any symbol and timeframe. Defaults suit a liquid index/futures intraday chart.
//
//
// EDGE IS NOW BOUNDED, NOT ASSERTED  (v1.1)
//   The Edge figure is a POINT ESTIMATE, and on a modest sample a +4 pt reading
//   and pure noise look identical. Every Edge now carries a WILSON 95% LOWER
//   BOUND beside it:  Edge LB = wilsonLo(hit rate) - base rate.  The panel turns
//   green ONLY when that lower bound clears zero with an adequate sample - a
//   positive point estimate alone is no longer coloured as though it were
//   evidence. Expect the bound to sit below zero far more often than the point
//   estimate does; that is the honest picture of a modest sample, not a fault in
//   the measurement.
//   Edge figures remain IN-SAMPLE and without costs - a study aid, not a backtest.
// NON-REPAINT NOTE
//   All statistics use closed past bars only — the drift/diffusion accumulators and the calibration
//   harness both update solely on barstate.isconfirmed, so their numbers never inflate intrabar.
//   The displayed landscape naturally evolves bar-to-bar (expected — it is a live estimate, not a
//   fixed level), and confirmed escape/pin marks settle on the close of the crossing bar. Edge
//   figures are in-sample, close-to-close, no costs — a study aid, not a verified backtest.
//
// EXPORTS  (Data Window — consume from other scripts via input.source())
//   EXP_WellPrice · EXP_EscBias · EXP_Pressure · EXP_Edge · EXP_Signal (+1 escape up / −1 down / 0)
//
// CONCEPT CREDIT
//   Built on standard, published techniques — stochastic drift-diffusion dynamics, conditional-
//   moment estimation of drift/diffusion, and escape-rate theory. Full author credits are in the
//   published description. This implementation, coupling and rendering are original; no third-party
//   Pine code is reused. Not affiliated with, nor endorsed by, any third party.
//
// HONESTY / LIMITATIONS
//   This is an EFFECTIVE, empirical 1-D approximation of a memoryful, multi-factor market. Treat
//   "escape pressure" as a relative, normalized gauge, not a literal probability. Estimates are
//   noisy where samples are sparse (greyed bins). Changing the bin count or grid inputs resets the
//   estimate. Nothing here predicts price.
//
// DISCLAIMER
//   Research and educational tool only. NOT financial advice, NO recommendation, NO guarantee of
//   results. Indicators describe past behaviour; they do not predict the future. Trading carries
//   risk of loss. Test out-of-sample and make your own decisions. The author accepts no liability.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Potential Well Map", "Potential Wells", overlay = true, max_lines_count = 500, max_labels_count = 100, max_boxes_count = 100)

int MAXBINS = 120   // fixed allocation ceiling so changing the bin-count input never overruns arrays

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          INPUTS
// ═════════════════════════════════════════════════════════════════════════════════════════
g0        = "01 · Source & grid"
src       = input.source(close, "Source", group = g0)
i_nBins   = input.int(48,  "Price bins (N)", minval = 16, maxval = 120, group = g0, tooltip = "Landscape resolution. More bins = finer detail but sparser per-bin samples. Changing this resets the estimate.")
i_anchor  = input.int(200, "Anchor length (detrend)", minval = 20, maxval = 1000, group = g0, tooltip = "Slow average of ln(price) used to detrend the coordinate.")
i_gridMlt = input.float(4.0, "Grid half-width (× vol)", minval = 1.0, maxval = 8.0, step = 0.5, group = g0)
i_volLen  = input.int(100, "Vol window for grid scaling", minval = 20, maxval = 500, group = g0)

g1        = "02 · Estimation & memory"
i_halfLife= input.int(750, "Memory half-life (bars)", minval = 20, maxval = 5000, group = g1, tooltip = "Effective memory of the drift/diffusion estimate. Larger = smoother, slower to adapt.")
i_minCnt  = input.float(3.0, "Min samples per bin", minval = 0.5, step = 0.5, group = g1, tooltip = "Bins below this effective count are greyed out and excluded.")
i_smoothBW= input.int(2, "Cross-bin smoothing", minval = 0, maxval = 6, group = g1, tooltip = "Half-width of the neighbour-smoothing kernel. 0 = off (noisy).")
i_diffFlr = input.float(1e-7, "Diffusion floor", minval = 1e-9, step = 1e-7, group = g1)
i_promFrac= input.float(0.05, "Extremum prominence (× range)", minval = 0.0, maxval = 0.5, step = 0.01, group = g1, tooltip = "A valley/peak must stand out from a neighbour by this fraction of the potential range to count. Higher = fewer, cleaner wells/barriers; 0 = mark every local wiggle.")

g2        = "03 · Escape / breakout pressure"
i_escSens = input.float(1.0, "Escape sensitivity", minval = 0.1, maxval = 5.0, step = 0.1, group = g2, tooltip = "Higher = pressure decays faster with wall height (concentrates right at the barrier).")
i_pressHi = input.float(65.0, "High-pressure threshold", minval = 50, maxval = 95, step = 1, group = g2)
i_rangeSig= input.float(1.5, "Expected-range width (σ)", minval = 0.5, maxval = 3.0, step = 0.5, group = g2)

g3        = "04 · Signals"
i_pinTol  = input.float(0.6, "Pin tolerance (× well width)", minval = 0.05, maxval = 2.0, step = 0.05, group = g3)
i_pinPrs  = input.float(40.0, "Pin: max escape pressure", minval = 10, maxval = 90, step = 5, group = g3)
i_stiffRt = input.float(0.35, "Stiff-well ratio threshold", minval = 0.1, maxval = 1.0, step = 0.05, group = g3, tooltip = "A well is a 'strong pin' when its width ÷ grid-half-width is below this.")
i_showPin = input.bool(true, "Show attractor-pin marks", group = g3)
i_showEsc = input.bool(true, "Show escape-confirmed marks", group = g3)

g4        = "05 · Calibration harness"
i_horizon = input.int(10, "Forward horizon (bars)", minval = 2, maxval = 100, group = g4)
i_kATR    = input.float(1.0, "Move threshold (× ATR)", minval = 0.1, maxval = 5.0, step = 0.1, group = g4)

g5        = "06 · Visuals & theme"
i_showProf = input.bool(true, "Draw potential profile", group = g5)
i_profW    = input.int(60, "Profile width (bars)", minval = 10, maxval = 200, group = g5)
i_showLvl  = input.bool(true, "Draw active well / barriers", group = g5)
i_showRng  = input.bool(true, "Shade expected range", group = g5)
i_showDash = input.bool(true, "Show dashboard", group = g5)
theme      = input.string("Auto", "Theme", options = ["Auto","Dark","Light"], group = g5)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                      PALETTE / THEME
// ═════════════════════════════════════════════════════════════════════════════════════════
GRN = #2ebd85
RED = #f6465d
YEL = #ffd600
f_luma(color c) => na(c) ? 0.0 : 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
isLight  = theme == "Light" or (theme == "Auto" and f_luma(chart.bg_color) > 140)
txtCol   = isLight ? color.new(#0b0f14, 0) : color.new(#e8edf2, 0)
mutCol   = isLight ? color.new(#5b6673, 0) : color.new(#8b95a1, 0)
rowA     = isLight ? color.new(#f2f4f7, 0) : color.new(#11161c, 0)
rowB     = isLight ? color.new(#e7ebf0, 0) : color.new(#171d24, 0)
hdrCol   = isLight ? color.new(#d9dee5, 0) : color.new(#0c1116, 0)
frameCol = isLight ? color.new(#c8cfd8, 0) : color.new(#2a323c, 0)
wellCol  = GRN
barrCol  = RED
curveCol = color.new(YEL, 20)
deadCol  = color.new(mutCol, 45)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                    COORDINATE & GRID
// ═════════════════════════════════════════════════════════════════════════════════════════
int   N     = i_nBins
float lp    = math.log(src)
float anchor= ta.ema(lp, i_anchor)              // slow trend anchor (log space)
float x     = lp - anchor                       // detrended coordinate (≈ stationary, centred on 0)
float xPrev = lp[1] - anchor[1]
float xVol  = ta.stdev(x, i_volLen)
float gHalf = math.max(xVol * i_gridMlt, i_diffFlr * 10)
float gLo   = -gHalf
float gHi   =  gHalf
float dx    = (gHi - gLo) / N
float atr   = ta.atr(14)

binOf(float _x)  => int(math.max(0, math.min(N - 1, int(math.floor((_x - gLo) / dx)))))
binX(int _k)     => gLo + (_k + 0.5) * dx
binPrice(int _k) => math.exp(anchor + binX(_k))

// ═════════════════════════════════════════════════════════════════════════════════════════
//               DECAYED CONDITIONAL-MOMENT ACCUMULATORS  (per-bin drift/diffusion)
//   For the bin of each starting level, accumulate the one-step move δ = x_t − x_{t-1}:
//     n[k] ~ effective count · s1[k] ~ Σδ → drift · s2[k] ~ Σδ² → diffusion. Decayed each bar.
// ═════════════════════════════════════════════════════════════════════════════════════════
var array<float> n_arr  = array.new<float>(MAXBINS, 0.0)
var array<float> s1_arr = array.new<float>(MAXBINS, 0.0)
var array<float> s2_arr = array.new<float>(MAXBINS, 0.0)
float lambda = math.pow(2.0, -1.0 / i_halfLife)   // decay from half-life

if barstate.isconfirmed and not na(xPrev) and bar_index > i_anchor
    for k = 0 to N - 1
        array.set(n_arr,  k, array.get(n_arr,  k) * lambda)
        array.set(s1_arr, k, array.get(s1_arr, k) * lambda)
        array.set(s2_arr, k, array.get(s2_arr, k) * lambda)
    int   kStart = binOf(xPrev)
    float delta  = x - xPrev
    array.set(n_arr,  kStart, array.get(n_arr,  kStart) + 1.0)
    array.set(s1_arr, kStart, array.get(s1_arr, kStart) + delta)
    array.set(s2_arr, kStart, array.get(s2_arr, kStart) + delta * delta)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                    DRIFT, DIFFUSION, SMOOTHING, POTENTIAL  (rebuilt each bar, O(N))
// ═════════════════════════════════════════════════════════════════════════════════════════
var array<float> d1_arr = array.new<float>(MAXBINS, 0.0)
var array<float> d2_arr = array.new<float>(MAXBINS, 0.0)
var array<bool>  ok_arr = array.new<bool>(MAXBINS, false)

for k = 0 to N - 1
    float nk = array.get(n_arr, k)
    if nk >= i_minCnt
        array.set(d1_arr, k, array.get(s1_arr, k) / nk)
        array.set(d2_arr, k, math.max(array.get(s2_arr, k) / (2.0 * nk), i_diffFlr))
        array.set(ok_arr, k, true)
    else
        array.set(d1_arr, k, 0.0)
        array.set(d2_arr, k, i_diffFlr)
        array.set(ok_arr, k, false)

// sample-weighted cross-bin smoothing
f_smooth(array<float> _src) =>
    out = array.new<float>(MAXBINS, 0.0)
    for k = 0 to N - 1
        float num = 0.0
        float den = 0.0
        for j = math.max(0, k - i_smoothBW) to math.min(N - 1, k + i_smoothBW)
            float w = array.get(n_arr, j)
            num += array.get(_src, j) * w
            den += w
        array.set(out, k, den > 0 ? num / den : array.get(_src, k))
    out

array<float> d1s = f_smooth(d1_arr)
array<float> d2s = f_smooth(d2_arr)

// integrate force (drift ÷ diffusion) into the potential, then shift min → 0
var array<float> U_arr = array.new<float>(MAXBINS, 0.0)
float acc = 0.0
array.set(U_arr, 0, 0.0)
for k = 1 to N - 1
    float f = array.get(d1s, k) / math.max(array.get(d2s, k), i_diffFlr)
    acc -= f * dx
    array.set(U_arr, k, acc)
float uMin = 1e18
for k = 0 to N - 1
    if array.get(ok_arr, k)
        uMin := math.min(uMin, array.get(U_arr, k))
if uMin > 1e17
    uMin := 0.0
for k = 0 to N - 1
    array.set(U_arr, k, array.get(U_arr, k) - uMin)
// potential range → prominence gate so flat wiggles aren't flagged as wells/barriers
float uMax = 0.0
for k = 0 to N - 1
    if array.get(ok_arr, k)
        uMax := math.max(uMax, array.get(U_arr, k))
uMax := math.max(uMax, i_diffFlr)
float prom = i_promFrac * uMax

// ═════════════════════════════════════════════════════════════════════════════════════════
//                            EXTREMA: WELLS (valleys) & BARRIERS (peaks)
//   Local min/max that also stands out from at least one neighbour by the prominence margin,
//   so a flat/noisy landscape does not mark every bin as an attractor.
// ═════════════════════════════════════════════════════════════════════════════════════════
isWell(int _k)    => _k > 0 and _k < N - 1 and array.get(ok_arr, _k) and array.get(U_arr, _k) <= array.get(U_arr, _k - 1) and array.get(U_arr, _k) <= array.get(U_arr, _k + 1) and math.max(array.get(U_arr, _k - 1) - array.get(U_arr, _k), array.get(U_arr, _k + 1) - array.get(U_arr, _k)) >= prom
isBarrier(int _k) => _k > 0 and _k < N - 1 and array.get(ok_arr, _k) and array.get(U_arr, _k) >= array.get(U_arr, _k - 1) and array.get(U_arr, _k) >= array.get(U_arr, _k + 1) and math.max(array.get(U_arr, _k) - array.get(U_arr, _k - 1), array.get(U_arr, _k) - array.get(U_arr, _k + 1)) >= prom

int kNow = binOf(x)
int activeWell = kNow
if not isWell(kNow)
    bool found = false
    for d = 1 to N - 1
        if not found and kNow - d >= 0 and isWell(kNow - d)
            activeWell := kNow - d
            found := true
        if not found and kNow + d <= N - 1 and isWell(kNow + d)
            activeWell := kNow + d
            found := true

int barrUp = -1
int barrDn = -1
for k = kNow + 1 to N - 1
    if barrUp == -1 and isBarrier(k)
        barrUp := k
for k = kNow - 1 to 0
    if barrDn == -1 and isBarrier(k)
        barrDn := k

// well curvature (stiffness) via 2nd difference of U at the valley
float Uw = array.get(U_arr, activeWell)
float stiff = 0.0
if activeWell > 0 and activeWell < N - 1
    stiff := (array.get(U_arr, activeWell + 1) - 2 * Uw + array.get(U_arr, activeWell - 1)) / (dx * dx)
stiff := math.max(stiff, 0.0)

// expected half-range from the harmonic (Gaussian) approximation of the valley: variance = 1/U''
float sigmaX     = stiff > 0 ? math.sqrt(1.0 / stiff) : gHalf
float wellWidthX = math.min(i_rangeSig * sigmaX, gHalf)
float wellWidthNorm = sigmaX / gHalf            // scale-free stiffness (small = stiff)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                              ESCAPE PRESSURE  (breakout gauge)
//   U is already diffusion-normalized, so the escape factor is exp(−ΔU) directly, measured from
//   the current bin to the nearest barrier. Bounded 0–100. An open side = unobstructed = 100.
// ═════════════════════════════════════════════════════════════════════════════════════════
float Unow = array.get(U_arr, kNow)
escPress(int _barr) =>
    _barr == -1 ? 100.0 : 100.0 * math.exp(-i_escSens * math.max(array.get(U_arr, _barr) - Unow, 0.0))
float pressUp = escPress(barrUp)
float pressDn = escPress(barrDn)
float escBias = pressUp - pressDn

// ═════════════════════════════════════════════════════════════════════════════════════════
//                              SIGNALS  (confirmation-gated, causal)
// ═════════════════════════════════════════════════════════════════════════════════════════
float wellPriceX = binX(activeWell)
float distToWell = math.abs(x - wellPriceX)
bool  isStiff    = stiff > 0 and wellWidthNorm < i_stiffRt
bool  bounded    = pressUp < i_pinPrs and pressDn < i_pinPrs
bool  pinState   = i_showPin and array.get(ok_arr, activeWell) and isStiff and bounded and distToWell <= i_pinTol * math.max(wellWidthX, dx)
bool  pinEntry   = pinState and not pinState[1]

float barrUpPrice = barrUp != -1 ? binPrice(barrUp) : na
float barrDnPrice = barrDn != -1 ? binPrice(barrDn) : na
var bool armedUp = false
var bool armedDn = false
armedUp := pressUp >= i_pressHi ? true : (close > nz(barrUpPrice, close * 2) ? false : armedUp)
armedDn := pressDn >= i_pressHi ? true : (close < nz(barrDnPrice, 0)       ? false : armedDn)
// ta.crossover / ta.crossunder are STATEFUL - they compare this bar to the last
// and must therefore be evaluated on EVERY bar. Pine's `and` short-circuits, so
// guarding them behind conditions that vary bar-to-bar (armedUp, na(barrier))
// silently skipped them and corrupted the previous-value state they rely on,
// which could miss or misfire an escape. Evaluate unconditionally, mask after.
bool xUpRaw = ta.crossover(close, barrUpPrice)
bool xDnRaw = ta.crossunder(close, barrDnPrice)
bool escUp = i_showEsc and armedUp and not na(barrUpPrice) and xUpRaw
bool escDn = i_showEsc and armedDn and not na(barrDnPrice) and xDnRaw

var int prevWell = na
bool regimeBreak = not na(prevWell) and math.abs(activeWell - prevWell) >= 2
prevWell := activeWell

plotshape(pinEntry, "Attractor Pin", shape.diamond,      location.belowbar, color.new(wellCol, 0), size = size.tiny)
plotshape(escUp,    "Escape Up",     shape.triangleup,   location.abovebar, color.new(GRN, 0),     size = size.small)
plotshape(escDn,    "Escape Down",   shape.triangledown, location.belowbar, color.new(RED, 0),     size = size.small)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                              CALIBRATION HARNESS  (escape → follow-through)
//   Accumulates ONLY on barstate.isconfirmed so the live bar never double-counts across ticks.
// ═════════════════════════════════════════════════════════════════════════════════════════
int sigDir = escUp ? 1 : escDn ? -1 : 0
var int hN = 0
var int hHit = 0
var int bT = 0
var int bU = 0
var int bD = 0
bool warm = bar_index > i_anchor + i_horizon + 20
if barstate.isconfirmed and warm and not na(close[i_horizon]) and not na(atr[i_horizon])
    float thr = i_kATR * atr[i_horizon]
    float mv  = close - close[i_horizon]
    bT += 1
    bU += mv >=  thr ? 1 : 0
    bD += -mv >= thr ? 1 : 0
    int sd = sigDir[i_horizon]
    if sd != 0
        hN += 1
        hHit += (sd > 0 and mv >= thr) or (sd < 0 and -mv >= thr) ? 1 : 0
float hitP  = hN > 0 ? hHit * 100.0 / hN : na
float baseP = bT > 0 ? (bU + bD) * 100.0 / (2.0 * bT) : na
float edge  = (not na(hitP) and not na(baseP)) ? hitP - baseP : na

// WILSON 95% LOWER BOUND on the hit rate. The Edge above is a POINT ESTIMATE:
// on a small sample a +4 pt reading and pure noise are indistinguishable. The
// lower bound answers the question that actually matters - what is the WORST
// the hit rate plausibly is, given this many observations? Edge LB = the lower
// bound minus the base rate. Only a POSITIVE lower bound is evidence; a
// positive point estimate on its own is not.
f_wilsonLo(int hits, int n) =>
    float outv = na
    if n > 0
        float ph  = hits / float(n)
        float z   = 1.96
        float ctr = ph + z * z / (2.0 * n)
        float hlf = z * math.sqrt((ph * (1.0 - ph) + z * z / (4.0 * n)) / n)
        outv := math.max(0.0, (ctr - hlf) / (1.0 + z * z / n)) * 100.0
    outv
float edgeLo   = f_wilsonLo(hHit, hN)
float edgeLB   = (not na(edgeLo) and not na(baseP)) ? edgeLo - baseP : na
bool  edgeProven = not na(edgeLB) and edgeLB > 0 and hN >= 20


alertcondition(pinEntry,    "Attractor Pin", "Potential Well Map: price pinned near a dynamical valley (fade-to-mean context).")
alertcondition(escUp,       "Escape Up",     "Potential Well Map: upside barrier escape confirmed.")
alertcondition(escDn,       "Escape Down",   "Potential Well Map: downside barrier escape confirmed.")
alertcondition(regimeBreak, "Regime Shift",  "Potential Well Map: active potential valley shifted (structural change).")

// ═════════════════════════════════════════════════════════════════════════════════════════
//                              VISUALS: POTENTIAL PROFILE (on the price axis)
//   Segments coloured by potential HEIGHT: low = attractor basin (green), high = barrier
//   zone (red), mid = neutral slope (amber), sparse = unreliable (grey).
// ═════════════════════════════════════════════════════════════════════════════════════════
var array<line> segLines = array.new<line>()
if barstate.islast
    if not i_showProf and array.size(segLines) > 0
        while array.size(segLines) > 0
            line.delete(array.pop(segLines))
    if i_showProf
        if array.size(segLines) != N - 1                       // (re)build on first draw or bin-count change
            while array.size(segLines) > 0
                line.delete(array.pop(segLines))
            for s = 0 to N - 2
                array.push(segLines, line.new(na, na, na, na, xloc = xloc.bar_index, width = 2))
        for s = 0 to N - 2
            line ln = array.get(segLines, s)
            bool ok = array.get(ok_arr, s) and array.get(ok_arr, s + 1)
            int off1 = int(math.round((array.get(U_arr, s)     / uMax) * i_profW))
            int off2 = int(math.round((array.get(U_arr, s + 1) / uMax) * i_profW))
            line.set_xy1(ln, bar_index + off1, binPrice(s))
            line.set_xy2(ln, bar_index + off2, binPrice(s + 1))
            float uN = (array.get(U_arr, s) + array.get(U_arr, s + 1)) / (2.0 * uMax)
            color col = not ok ? deadCol : uN < 0.33 ? wellCol : uN > 0.66 ? barrCol : curveCol
            line.set_color(ln, col)

// active well & barrier level lines
var line wellLine = line.new(na, na, na, na, xloc = xloc.bar_index, extend = extend.left, width = 2)
var line barrUpLn = line.new(na, na, na, na, xloc = xloc.bar_index, extend = extend.left, width = 1, style = line.style_dashed)
var line barrDnLn = line.new(na, na, na, na, xloc = xloc.bar_index, extend = extend.left, width = 1, style = line.style_dashed)
if barstate.islast
    float wp = i_showLvl ? binPrice(activeWell) : na
    line.set_xy1(wellLine, bar_index - 2, wp)
    line.set_xy2(wellLine, bar_index, wp)
    line.set_color(wellLine, wellCol)
    float bUp = i_showLvl and barrUp != -1 ? binPrice(barrUp) : na
    line.set_xy1(barrUpLn, bar_index - 2, bUp)
    line.set_xy2(barrUpLn, bar_index, bUp)
    line.set_color(barrUpLn, barrCol)
    float bDn = i_showLvl and barrDn != -1 ? binPrice(barrDn) : na
    line.set_xy1(barrDnLn, bar_index - 2, bDn)
    line.set_xy2(barrDnLn, bar_index, bDn)
    line.set_color(barrDnLn, barrCol)

// expected-range shaded box around the active well
var box rangeBox = box.new(na, na, na, na, border_color = color.new(wellCol, 70), bgcolor = color.new(wellCol, 92))
if barstate.islast
    float hiP = i_showRng ? math.exp(anchor + wellPriceX + wellWidthX) : na
    float loP = i_showRng ? math.exp(anchor + wellPriceX - wellWidthX) : na
    box.set_lefttop(rangeBox, bar_index - 30, hiP)
    box.set_rightbottom(rangeBox, bar_index, loP)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                        DASHBOARD
// ═════════════════════════════════════════════════════════════════════════════════════════
f_num(float _v) => str.tostring(_v, format.mintick)
var table dash = table.new(position.top_right, 2, 10, border_width = 1, border_color = frameCol, frame_color = frameCol, frame_width = 1)
f_row(int r, string k, string v, color vc) =>
    color bg = r % 2 == 0 ? rowA : rowB
    table.cell(dash, 0, r, k, text_size = size.small, text_color = mutCol, text_halign = text.align_left,  bgcolor = bg)
    table.cell(dash, 1, r, v, text_size = size.small, text_color = vc,     text_halign = text.align_right, bgcolor = bg)

if i_showDash and barstate.islast
    string regimeTxt = barrUp != -1 and barrDn != -1 ? "Bounded well" : barrUp == -1 and barrDn == -1 ? "Open / diffusive" : barrUp == -1 ? "Open above" : "Open below"
    color  regimeCol = barrUp != -1 and barrDn != -1 ? GRN : barrUp == -1 and barrDn == -1 ? mutCol : YEL
    string biasTxt   = math.abs(escBias) < 5 ? "Balanced" : escBias > 0 ? "▲ up-biased" : "▼ down-biased"
    color  biasCol   = math.abs(escBias) < 5 ? mutCol : escBias > 0 ? GRN : RED
    string stiffTxt  = stiff <= 0 ? "—" : wellWidthNorm < i_stiffRt ? "Stiff (strong pin)" : "Loose (weak pin)"
    color  stiffCol  = stiff <= 0 ? mutCol : wellWidthNorm < i_stiffRt ? GRN : YEL
    string prsTxt    = f_num(pressUp) + " / " + f_num(pressDn)
    color  prsCol    = (pressUp >= i_pressHi or pressDn >= i_pressHi) ? RED : txtCol
    string edgeTxt   = hN < 20 ? "warming…" : str.tostring(edge, "+0.0;-0.0") + " / LB " + str.tostring(edgeLB, "+0.0;-0.0") + " (n" + str.tostring(hN) + ")"
    color  edgeCol   = na(edge) or hN < 20 ? mutCol : edgeProven ? GRN : edgeLB < -3 ? RED : mutCol
    table.cell(dash, 0, 0, "POTENTIAL WELL MAP", text_size = size.small, text_color = txtCol, text_halign = text.align_left,  bgcolor = hdrCol)
    table.cell(dash, 1, 0, syminfo.ticker,       text_size = size.small, text_color = txtCol, text_halign = text.align_right, bgcolor = hdrCol)
    f_row(1, "Regime", regimeTxt, regimeCol)
    f_row(2, "Bias", biasTxt, biasCol)
    f_row(3, "Well price", f_num(binPrice(activeWell)), wellCol)
    f_row(4, "Well stiffness", stiffTxt, stiffCol)
    f_row(5, "Expected range", f_num(math.exp(anchor + wellPriceX - wellWidthX)) + " – " + f_num(math.exp(anchor + wellPriceX + wellWidthX)), txtCol)
    f_row(6, "Barrier ▲", barrUp != -1 ? f_num(binPrice(barrUp)) : "—", barrUp != -1 ? RED : mutCol)
    f_row(7, "Barrier ▼", barrDn != -1 ? f_num(binPrice(barrDn)) : "—", barrDn != -1 ? RED : mutCol)
    f_row(8, "Escape ▲ / ▼", prsTxt, prsCol)
    f_row(9, "Escape Edge", edgeTxt, edgeCol)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                    EXPORTS  (Data Window — consume elsewhere via input.source())
// ═════════════════════════════════════════════════════════════════════════════════════════
plot(binPrice(activeWell),        "EXP_WellPrice", color.new(color.gray, 100), display = display.data_window)
plot(escBias,                     "EXP_EscBias",   color.new(color.gray, 100), display = display.data_window)
plot(math.max(pressUp, pressDn),  "EXP_Pressure",  color.new(color.gray, 100), display = display.data_window)
plot(edge,                        "EXP_Edge",      color.new(color.gray, 100), display = display.data_window)
plot(escUp ? 1 : escDn ? -1 : 0,  "EXP_Signal",    color.new(color.gray, 100), display = display.data_window)
````
