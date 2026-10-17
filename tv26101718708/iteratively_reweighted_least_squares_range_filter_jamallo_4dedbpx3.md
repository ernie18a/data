# Iteratively Reweighted Least Squares Range Filter [Jamallo]

- url: https://www.tradingview.com/script/4dEDbPX3-Iteratively-Reweighted-Least-Squares-Range-Filter-Jamallo/
- type: indicator
- pine_id: PUB;2055a687cb6843a4a8fc3d5c3cce06a3
- version: 1.0

## Description

[b]Intro[/b]

[i]Iteratively Reweighted Least Squares Range Filter
[/i]

Most filters treat every bar equally. This one doesn't. The IRLS Range Filter uses a robust statistical engine to continuously evaluate how much each bar in the lookback window should be trusted — down-weighting noisy data and rejecting outliers entirely — before computing a consensus price level. The result is a smoother, more honest trend line that is far less susceptible to wicks, gaps, and volatile noise than conventional moving averages.

[b]How It Works[/b]

The indicator runs in three stages:

[b]Stage 1 — IRLS Consensus Engine[/b]. Every bar in the rolling window is assigned one of three trust states based on how far its price deviates from the current consensus, measured in adaptive sigma units. High Trust bars (within Lo-Trust Band σ) receive full weight. Lo Trust bars receive half weight. Rejected bars receive none. A Schmitt-trigger hysteresis mechanism prevents bars from flickering between states on minor fluctuations. The weighted average of all contributing bars becomes the consensus price. This residual-based weighting scheme is adapted from the IRLS framework described in Li & Deng (2026), arXiv:2603.08158.

[b]Stage 2 — Deadband Quantizer[/b]. The continuous consensus is passed through a step filter. The output only moves when the consensus has shifted by more than one deadband unit (Step Size × σ). This eliminates micro-jitter and produces a clean staircase line with fewer false trend flips.

[b]Stage 2.5 — Sample-and-Hold Bands.[/b] The volatility channel is only updated when the filter takes a new step, so band width reflects conditions at the last decisive move rather than real-time noise. An EMA-style smoother (Band Smooth) prevents abrupt band jumps between steps.

[b]Reference[/b]

[i]Li, J., & Deng, F. (2026). Outlier-robust Autocovariance Least Square Estimation via Iteratively Reweighted Least Square. arXiv preprint arXiv:2603.08158v1.[/i]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
// © Jamallo

//@version=5
indicator("Iteratively Reweighted Least Squares Range Filter [Jamallo]", shorttitle="IRLS-RF [Jamallo]", overlay=true, max_bars_back=500)

// ─────────────────────────────────────────────────────────────────────────────
// INPUT GROUPS
// ─────────────────────────────────────────────────────────────────────────────
var string GRP_IRLS = "IRLS Parameters"
var string GRP_VIS  = "Appearance"
var string GRP_SIG  = "Signals"

// ── IRLS Parameters ──
src       = input.source(close,  "Source",              group=GRP_IRLS)
irls_N    = input.int(10,        "Window Size (N)",      group=GRP_IRLS, minval=5, maxval=500,   tooltip="Number of bars in the rolling window used for consensus and sigma estimation. Larger = smoother and slower to react.")
lo_band   = input.float(1.0,     "Lo-Trust Band (σ)",   group=GRP_IRLS, minval=0.1, maxval=5.0,  step=0.1, tooltip="Residual threshold (in sigma units) at which a bar transitions from full weight to half weight. Lower values = stricter trust requirements.")
hi_band   = input.float(2.0,     "Reject Band (σ)",     group=GRP_IRLS, minval=0.5, maxval=10.0, step=0.1, tooltip="Residual threshold at which a bar is excluded from the consensus entirely. Controls how aggressively outliers are rejected.")
hyst      = input.float(1.0,     "Hysteresis (σ)",      group=GRP_IRLS, minval=0.0, maxval=2.0,  step=0.05, tooltip="Deadzone added around each state threshold to prevent bars from flickering between trust states. Increase on choppy or volatile instruments.")
iters     = input.int(1,         "Iterations",          group=GRP_IRLS, minval=1, maxval=5,      tooltip="Number of IRLS refinement passes per bar. 1 is sufficient for most use cases. Higher values refine the consensus further but add computation.")
step_mult = input.float(1.0,     "Step Size (σ mult)",  group=GRP_IRLS, minval=0.1, maxval=5.0,  step=0.1, tooltip="How far the consensus must move (as a multiple of sigma) before the filter line snaps to a new level. Higher = fewer steps, less noise.")
band_mult = input.float(2.0,     "Band Multiplier",     group=GRP_IRLS, minval=0.1, maxval=10.0, step=0.1, tooltip="Width of the upper and lower channel, expressed as a multiple of the held volatility at the last step.")
av_n      = input.int(2,         "Band Smooth (Steps)", group=GRP_IRLS, minval=1,   maxval=20,   tooltip="EMA smoothing applied to band width across steps. Higher values prevent abrupt channel jumps when volatility changes between steps.")

// ── Appearance ──
bullCol = input.color(color.teal,   "Bullish Color", group=GRP_VIS)
bearCol = input.color(color.maroon, "Bearish Color", group=GRP_VIS)
flatCol = input.color(color.gray,   "Flat Color",    group=GRP_VIS)

// ── Signals ──
show_signals = input.bool(true, "Show Signals", group=GRP_SIG)

// ─────────────────────────────────────────────────────────────────────────────
// SAFETY CHECK — Prevent inverted bands
// ─────────────────────────────────────────────────────────────────────────────
float safe_lo = math.min(lo_band, hi_band)
float safe_hi = math.max(lo_band, hi_band)
if safe_lo == safe_hi
    safe_hi += 0.5

// ─────────────────────────────────────────────────────────────────────────────
// ROLLING WINDOW
// ─────────────────────────────────────────────────────────────────────────────
var float[] y          = array.new_float(0)
var int[]   prev_state = array.new_int(0)

array.unshift(y, src)
array.unshift(prev_state, 1)

if array.size(y) > irls_N
    array.pop(y)
    array.pop(prev_state)

int win = array.size(y)

// ─────────────────────────────────────────────────────────────────────────────
// SIGMA ESTIMATION
// ─────────────────────────────────────────────────────────────────────────────
float raw_r = math.abs(src - nz(src[1], src))
float sigma = math.sqrt(ta.sma(raw_r * raw_r, irls_N))
float sig   = math.max(sigma, src * 1e-5)

// =============================================================================
// STAGE 1 — CONTINUOUS CONSENSUS (IRLS Engine)
//
// Iteratively Reweighted Least Squares (IRLS) computes a robust consensus
// price by down-weighting or rejecting bars whose residual exceeds adaptive
// sigma thresholds. A Schmitt-trigger (hysteresis) state machine per bar
// prevents state chatter near the band boundaries.
//
//   State 1 → High Trust  : full weight (w = 1.0)
//   State 2 → Lo Trust    : half weight (w = 0.5)
//   State 3 → Rejected    : zero weight (w = 0.0)
// =============================================================================
var float consensus = na
if na(consensus)
    consensus := src

for _iter = 1 to iters
    float num = 0.0
    float den = 0.0

    for j = 0 to win - 1
        float yj  = array.get(y, j)
        float res = math.abs(yj - consensus) / sig
        int   pst = array.get(prev_state, j)

        // Schmitt-trigger state transitions
        int new_state = pst
        if pst == 1
            if res > safe_lo + hyst
                new_state := 2
        else if pst == 2
            if res < safe_lo - hyst
                new_state := 1
            else if res > safe_hi + hyst
                new_state := 3
        else if pst == 3
            if res < safe_hi - hyst
                new_state := 2
        else
            new_state := 1

        // Persist state on final iteration only
        if _iter == iters
            array.set(prev_state, j, new_state)

        // Map state to weight
        float w = 0.0
        if new_state == 1
            w := 1.0
        else if new_state == 2
            w := 0.5

        num += w * yj
        den += w

    if den > 0
        consensus := num / den

// =============================================================================
// STAGE 2 — DEADBAND QUANTIZER (Staircase / Step Filter)
//
// Suppresses micro-jitter by requiring the consensus to move more than one
// deadband unit before the output snaps to a new level. This produces a
// clean, step-wise filter line with fewer false trend flips.
// =============================================================================
var float stepped = na
if na(stepped)
    stepped := consensus

float deadband = sig * step_mult

if math.abs(consensus - stepped) > deadband
    stepped := consensus

// ─────────────────────────────────────────────────────────────────────────────
// STAGE 2.5 — SAMPLE-AND-HOLD BANDS
//
// Volatility (σ) is only captured when the filter takes a new step, so the
// channel width reflects conditions at the last decisive move rather than
// real-time noise. An EMA-style conditional smoother avoids abrupt band jumps.
// ─────────────────────────────────────────────────────────────────────────────
bool has_stepped = stepped != nz(stepped[1], stepped)

var float held_sig = na
if na(held_sig) or has_stepped
    if na(held_sig)
        held_sig := sig
    else
        held_sig := (sig - held_sig) * (2.0 / (av_n + 1)) + held_sig

float upper = stepped + held_sig * band_mult
float lower = stepped - held_sig * band_mult

// ─────────────────────────────────────────────────────────────────────────────
// TREND DIRECTION & COLOR
// ─────────────────────────────────────────────────────────────────────────────
var int trend = 0

int prev_trend = nz(trend[1], 0)

if stepped > nz(stepped[1], stepped)
    trend := 1
else if stepped < nz(stepped[1], stepped)
    trend := -1

color lineCol = trend == 1 ? bullCol : trend == -1 ? bearCol : flatCol

// ─────────────────────────────────────────────────────────────────────────────
// SIGNALS — Fire on trend direction change
// ─────────────────────────────────────────────────────────────────────────────
bool bull_signal = show_signals and trend == 1  and prev_trend != 1
bool bear_signal = show_signals and trend == -1 and prev_trend != -1

plotshape(bull_signal, title="Bull Signal", location=location.belowbar,
     style=shape.labelup, color=bullCol, textcolor=color.white,
     text="▲", size=size.small)

plotshape(bear_signal, title="Bear Signal", location=location.abovebar,
     style=shape.labeldown, color=bearCol, textcolor=color.white,
     text="▼", size=size.small)

alertcondition(bull_signal, title="IRLS RF — Bullish Turn", message="IRLS Range Filter turned bullish")
alertcondition(bear_signal, title="IRLS RF — Bearish Turn", message="IRLS Range Filter turned bearish")

// ─────────────────────────────────────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────────────────────────────────────
p_mid = plot(stepped, "IRLS Filter", color=lineCol,                linewidth=1, style=plot.style_line)
p_top = plot(upper,   "Upper Band",  color=color.new(bullCol, 60), linewidth=1, style=plot.style_line)
p_btm = plot(lower,   "Lower Band",  color=color.new(bearCol, 60), linewidth=1, style=plot.style_line)

fill(p_top, p_mid, color.new(bullCol, 90), "Upper Channel Fill")
fill(p_btm, p_mid, color.new(bearCol, 90), "Lower Channel Fill")
````
