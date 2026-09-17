<!-- tradingview-pine-id: PUB;1cc66dbdc0a343369ccdfd2e0bba89c2 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Multi-Factor Reversal Confluence — All-in-One

Source: https://www.tradingview.com/script/N3G4P1ig-Multi-Factor-Reversal-Confluence-All-in-One/

## Description

█ OVERVIEW

Multi-Factor Reversal Confluence is a single decision object that looks for exhaustion-and-turn REVERSALS by making five orthogonal detectors agree through one staged lifecycle — WATCH → ARMED → EXTREME → CONFIRMED — filtering every call through two gates, and then grading its own conviction against how those calls have actually resolved on THIS chart. Two things its category usually skips: gating (a trend-defense that will not fade a series with no equilibrium to revert to, and a turbulence veto that will not fade an active, intensifying volatility cascade — the two dominant ways reversal tools get run over), and honest self-calibration (conviction is mapped to a probability by a non-parametric isotonic fit of predicted→realized, and the "proven" badge uses an out-of-sample, uniqueness-weighted, multiple-testing-deflated Wilson lower bound versus a matched base rate — so a thin or edgeless sample says so plainly). Everything is computed internally from price and volume; there is no input.source wiring, no external symbol, and no request.security.

█ HOW IT WORKS

Five independent signals, each on a 0–100 signed scale (+ = bottom / − = top), each naming its method:

1. INSTABILITY (prior) — a Wasserstein-1 (earth-mover) distance between the most recent window of returns and the window before it (matched sorted order-statistics), volatility-normalized and ranked as a percentile of its own history. A rising distance = the return distribution is changing shape — variance, skew OR tail — i.e. a system losing stability and a reversal PRIOR. Shape-complete (it catches a fattening tail that a moment-by-moment read misses) and direction is set opposite the prevailing drift.
2. CHANGEPOINT (trigger) — a Student-t Bayesian Online Changepoint Detector (run-length posterior with a hazard prior) plus a CUSUM mean/variance break, resolved into a drift-turn direction. This is the TRIGGER that a regime actually broke.
3. EXHAUSTION (gate) — a real trend (efficiency ratio above a floor over the slow horizon) whose fast efficiency is now COLLAPSING while price is stretched (displacement percentile), optionally boosted by absorption (high volume, little progress) and a panic-range read. The GATE that the move is spent.
4. CLIMAX (extreme) — a volume-z (time-of-day-normalized on intraday), an expansion-range-z, a close-rejection wick and an order-flow delta from Bulk-Volume Classification (buy fraction = the normal CDF of the standardized return — a principled signed delta, not a close-location proxy). The composite must clear its own conformal online (1−α) quantile, so "extreme" means a calibrated ~α-rare event on this symbol; a secondary-test state machine then only confirms once a lower-volume retest holds the extreme.
5. STRUCTURE (confirm) — a liquidity sweep of a confirmed swing pivot followed by a displacement break back through it (≥ a × ATR), which also sets the stop. The CONFIRM.

Mean-reversion / regime gate (the trend-defense) — every fire is filtered by how mean-reverting the tape is right now, on a 0–1 scale from two orthogonal reads: the reversion-trust correlation (the rolling correlation of prior deviation-from-mean with the NEXT return — strongly negative means price is actively reverting) and a Lo-MacKinlay variance ratio (VR(q) < 1 = mean-reverting, ≈ 1 = random walk, > 1 = trending). An optional Dickey-Fuller unit-root test adds a formal stationarity requirement. The gate scales conviction and, below a floor, blocks the fire outright — so the engine does not fade a trend, the single largest source of false tops and bottoms.

Turbulence gate (the falling-knife defense) — large moves are treated as a point process and their Fano factor (variance/mean of the shock count) gives a self-exciting Hawkes branching ratio on a 0–1 scale. When that ratio is high AND still rising, the move is self-feeding — so conviction is scaled down and, below a floor, the fire is blocked. It stops the engine from fading an accelerating cascade, and it releases as the cascade rolls over. The two gates multiply into one combined guard shown on the dashboard.

Lifecycle & fusion — the engine ARMs only when at least N of the five agree on a direction, each above its own threshold, within an expiry window; climax promotes it to EXTREME, a structure break to CONFIRMED (the default actionable tier). Conviction fuses the supporting signals correlation-aware: the instability and changepoint pair is down-weighted by their measured rolling correlation (a Kish-style redundancy discount) so two views of the same thing don't double-count, then scaled by the mean-reversion gate.

Location (absorption shelf) — the five signals answer "is a turn forming?" but not "where?". A built-in occupation-time (dwell) profile answers that internally, with nothing to wire: a fixed-tick price grid accumulates how long price has dwelt at each level (a reversible ring buffer that adds the entering bar and subtracts the bar leaving the window), and the nearest bin whose dwell is a high fraction of the busiest bin — below and above price — is the support / resistance shelf. A reversal that fires AT a shelf on the correct side earns a bounded conviction boost. It is self-contained (no request.security). Optionally, set Location to "External link" instead and wire the four source inputs to a published Absorption Shelf's EXP_ outputs to use that fuller engine.

Calibration — every actionable fire is resolved a fixed horizon later against a ± target (× ATR): did price reach the target in the signalled direction? Raw conviction is mapped to a probability by a beta warm-start that hands over to a non-parametric ISOTONIC (Pool-Adjacent-Violators) fit of predicted→realized once enough outcomes resolve, and is shrunk toward 50% until the sample is sufficient — so a shown 70% actually resolves ~70% on this symbol. Bottom and top hit-rates are tracked separately, each with a Wilson lower bound, versus a direction-matched unconditional base rate. The "proven" badge is deliberately strict: it uses an out-of-sample slice, weights overlapping fires by their uniqueness (effective-N, not raw n), and raises the Wilson z (Bonferroni-style) for the several signals and two sides being tested; a Net-R after cost is shown so the edge reflects something tradeable, not gross.

█ HOW TO USE

Read the dashboard top-down: the STATE (WATCH / ARMED / EXTREME / CONFIRMED) and the direction, then the calibrated conviction (a ✓ means the edge is proven out-of-sample), then the combined gate, then the stop. The gate row (regime·turbulence) is the defense layer: "reverting" means fades are in-context, "trend/random" or "cascade!" means the engine is holding back. Pro adds a Flow · turbulence row (signed BVC order-flow delta and the branching ratio) and a Location row (shelf status). Choose your actionable tier (Armed / Extreme / Confirmed) in the inputs — the default is Confirmed, which fires only after the structure break for the fewest, highest-precision signals; Extreme and Armed are earlier and noisier. A diamond marks a confirmed fire (it brightens with conviction and dims while the sample is still learning); a small triangle marks the earlier EXTREME stage. On a confirmed fire the tool draws the Entry, Stop and two targets (TP1/TP2 at R-multiples of the stop) as labelled lines, and a tag at the arrow showing direction and calibrated conviction. A faint grey wash means the engine is standing aside (a trend/random regime or an active cascade) — that is the gates working, not a fault. A small on-chart legend explains the marks; all of these visuals are toggle-able in the Chart-visuals inputs. The calibration is the honest layer: until the sample clears the minimum it reads "learning", and it shows each side's Wilson-bounded hit-rate against its base rate rather than a bare number — a low or below-base read is information, not a malfunction. The structure signal confirms a swing-length number of bars AFTER the pivot by design, so treat it as confirmation, not a pivot-bar entry. Switch Dashboard detail to Pro for the raw conviction, the per-side hit-rate table, the out-of-sample edge with Net-R and effective-N, and the per-engine peak-strength diagnostic. Needs volume — run it on a volume-bearing symbol (index futures work well). Horizon and sizing are yours; it places no orders.

█ INPUTS

1 · Instability — returns window for the Wasserstein distributional-shift, drift lookback.
2 · Changepoint — observation window, z winsorise, hazard, Student-t d.o.f., prior pseudo-count, P(change) fire threshold, emerging-drift lookback.
3 · Exhaustion — ER fast / slow, trend floor, displacement lookback, stretch percentile, absorption + panic boost.
4 · Climax — volume/range baseline, volume-z and range-z thresholds, time-of-day normalization + rate, close-rejection threshold, CVD window, secondary-test window and retest-volume fraction, BVC order-flow delta toggle, conformal "extreme" rarity (α and adaptation rate).
5 · Structure — swing length, break displacement (× ATR), sweep→break window.
6 · Fusion & lifecycle — per-stage thresholds, minimum agreeing signals to ARM, expiry window, actionable tier (default Confirmed), the P1↔P2 redundancy factor and data-driven decorrelation window.
7 · Calibration — resolve horizon, target move (× ATR), minimum sample, beta rate, isotonic recalibration, warm-up shrink samples, in-sample fraction, proven-z (deflated), round-trip cost.
9 · Mean-reversion gate — require a mean-reverting regime, reversion-trust window, variance-ratio window and q, block-fire floor, optional Dickey-Fuller stationarity with its window and critical t.
10 · Turbulence gate — veto fades during a volatility cascade, shock threshold (× σ), shock sub-window, Fano window, cascade level to start vetoing, veto strength, block-fire floor.
11 · Location (absorption shelf) — enable; shelf source (Internal built-in dwell profile, default / External link); internal dwell lookback, bin size (× ATR) and hot-shelf fraction; the four external sources (used only in External mode); near-shelf tolerance (× ATR), absorbing-strength threshold, conviction multiplier at a confirmed shelf.
12 · Chart visuals — trade-level overlay (TP1/TP2 R-multiples, level length), signal label, conviction-graded markers, stand-aside tint, on-chart legend and position, draw linked shelf.
13 · Style — theme (Dark / Light), Bottom / Top colours, background tint, markers, dashboard show and detail (Compact default / Pro).

█ HONESTY & LIMITATIONS

This is a study, not a strategy. The conviction and hit-rates are descriptive statistics on visible history with no execution costs — not a backtest and not a probability your next trade works; the out-of-sample slice and Net-R make the "proven" badge stricter but it remains an in-sample-history read. Volume-derived signals (climax, CVD, absorption) need real volume and abstain or weaken on symbols without it. Non-repaint by construction: all five signals resolve on confirmed values, the structure signal uses swing pivots that confirm several bars late (a deliberate lag, not a repaint), the mean-reversion gate, the turbulence gate, the conformal quantile, the state machine and the calibration read only committed bars, and the isotonic map / out-of-sample statistics are built once per bar for display and never feed the fire — set alerts to "Once Per Bar Close". The optional Dickey-Fuller gate runs a windowed regression loop; leave it off (default) if you want the lightest compute. When the sample is small the calibration shrinks toward 50% and reads "learning", and a hit-rate below its base rate is shown honestly rather than hidden. No edge shown = honest, not broken.

█ ORIGINALITY

One coherent reversal object, not five indicators stacked. The original contribution is the staged lifecycle in which five DIFFERENT statistical lenses (Wasserstein distributional-shift, Bayesian changepoint, efficiency exhaustion, a conformal-rare volume/BVC climax, and liquidity-sweep structure) must agree in sequence, all filtered by two orthogonal gates — a mean-reversion regime gate so the engine refuses to fade a trend, and a Hawkes self-excitation gate so it refuses to fade an accelerating cascade — fused with an explicit redundancy discount so correlated views don't double-count, and — the part most reversal tools omit — a conviction that is isotonically calibrated to the chart's own resolved outcomes and gated by an out-of-sample, uniqueness-weighted, multiple-testing-deflated Wilson lower bound against a matched base rate. Each detector exists only to feed that single verdict and its stop; none is presented as a standalone signal. It carries a compact built-in occupation-time shelf for price-location confirmation (or can consume an external Absorption-Shelf's exports), keeping it one self-contained tool. Every block was written from scratch.

█ CREDITS

Bayesian Online Changepoint Detection — Adams & MacKay (2007); Student-t predictive. CUSUM — Page (1954). Wasserstein-1 / optimal transport (earth-mover distance) — Kantorovich. Variance ratio — Lo & MacKinlay (1988). Unit-root test — Dickey & Fuller (1979); Ornstein-Uhlenbeck. Efficiency ratio — Kaufman. Bulk-Volume Classification / VPIN order-flow — Easley, López de Prado & O'Hara. Self-exciting branching processes (Fano factor) — Hawkes (1971). Conformal / adaptive online quantiles — Vovk; Angelopoulos, Candès & Tibshirani. Cumulative Volume Delta / effort-vs-result absorption — order-flow literature. Liquidity sweep & displacement — order-flow / market-structure practice. Beta / logistic calibration — Platt (1999); Kull, Silva Filho & Flach. Isotonic regression / Pool-Adjacent-Violators — Ayer et al. (1955). Uniqueness weighting & two-barrier forward test — López de Prado. Design-effect / effective sample — Kish (1965). Wilson score interval — Wilson (1927). Code written from scratch; no external script reused.

This script is for analysis and education. It is not financial advice.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                                    MPL-2.0
// MULTI-FACTOR REVERSAL CONFLUENCE — ALL-IN-ONE (CALIBRATED)                                  v1.0
// ────────────────────────────────────────────────────────────────────────────────────────────
// One self-contained engine. It computes five independent reversal signals INTERNALLY (no
// input.source wiring), runs a staged lifecycle, fuses the signals correlation-aware, and calibrates
// the result online. Bare visuals only: reversal markers, a stop line, and a compact dashboard.
//   1 INSTABILITY  Wasserstein-1 distributional-shift (earth-mover), ranked → PRIOR
//   2 CHANGEPOINT  Student-t BOCPD + CUSUM, drift-turn direction          → TRIGGER
//   3 EXHAUSTION   efficiency collapse in a real trend + absorption       → GATE
//   4 CLIMAX       volume-z + range + rejection + BVC order-flow delta, conformal-rare → EXTREME
//   5 STRUCTURE    liquidity sweep → displacement break (+ stop)          → CONFIRM
// Two GATES filter every fire: a MEAN-REVERSION gate (reversion-trust correlation + Lo-MacKinlay
// variance ratio, optional Dickey-Fuller) — the trend-defense that stops the engine fading a series
// with no equilibrium — and a TURBULENCE gate (Hawkes self-excitation branching ratio) that vetoes
// fading an active, intensifying cascade (the falling-knife defense). Both scale and can block a fire.
// Lifecycle: WATCH → ARMED (agreement within a window) → EXTREME (climax)
// → CONFIRMED (structure break; the default actionable tier). Fusion down-weights correlated signals
// (Kish); conviction is calibrated to resolved outcomes — beta warm-start → non-parametric ISOTONIC
// (PAV) — shrunk toward 50% until enough samples resolve, and the "proven" badge uses a
// uniqueness-weighted, out-of-sample, multiple-testing-deflated Wilson lower bound vs a matched base
// rate. Non-repainting. Needs volume (run on futures, e.g. NSE:NIFTY1!). Study only — NOT financial
// advice, NOT a signal service.
//
//  DISCLOSURE / HONESTY
//    This is a study/indicator for analysis and education. It is NOT a strategy, NOT a signal
//    service, and NOT financial advice. Any performance or "edge" figure shown is in-sample,
//    descriptive statistics on visible history with no execution costs — it is not a backtest and
//    not a promise about the future. Each reversal's forward outcome is scored only after its
//    horizon has fully elapsed; the hit-rate is shown with its sample size, a Wilson 95% lower
//    bound and a matched unconditional base rate, so a small sample visibly discounts the claim.
//    When a measured edge is absent, the dashboard shows that plainly rather than hiding it.
//
//  NON-REPAINT  All five signals resolve on confirmed values; the structure signal uses swing
//    pivots that confirm `Swing length` bars AFTER the pivot (a deliberate lag, not a repaint), and
//    the calibration reads only committed bars. The live bar is provisional until close — set any
//    alert to "Once Per Bar Close".
//
//  ORIGINALITY  One coherent reversal object: five orthogonal detectors feed ONE staged lifecycle
//    and a single correlation-aware conviction that is calibrated to this chart's own resolved
//    outcomes — not five indicators stacked. Concept credits are in the description.
//
//  DISCLAIMER  Research and education only. NOT financial advice, NOT a signal service.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Multi-Factor Reversal Confluence — All-in-One", "Reversal", overlay = true, max_bars_back = 600, max_lines_count = 60, max_labels_count = 60)

// ───────────────────────────── INPUTS ─────────────────────────────
gc1 = "1 · Instability (prior)"
gc2 = "2 · Changepoint (trigger)"
gc3 = "3 · Exhaustion (gate)"
gc4 = "4 · Climax (extreme)"
gc5 = "5 · Structure (confirm)"
gF = "6 · Fusion & lifecycle"
gK = "7 · Calibration"
gS = "13 · Style"

// P1
ewsW    = input.int(50, "Instability window (returns)", minval = 10, maxval = 250, group = gc1, tooltip = "Window for the Wasserstein-1 (earth-mover) distributional-shift measure: the most recent `window` returns are compared, in sorted order-statistics, to the `window` before them (so it references up to 2×window bars back). A rising, volatility-normalized distance = the return distribution is changing shape (variance / skew / tail) = a reversal PRIOR. Replaces the old Kendall triple-loop — cheaper and more shape-complete.")
driftLen= input.int(20, "Drift lookback", minval = 2, maxval = 300, group = gc1)

// P2
obsW    = input.int(50, "Changepoint obs window", minval = 10, maxval = 500, group = gc2)
zClip   = input.float(5.0, "Winsorise z at ±", minval = 2.0, step = 0.5, group = gc2)
hazard  = input.float(0.02, "Hazard (1/expected run)", minval = 0.001, maxval = 0.5, step = 0.001, group = gc2)
nuDof   = input.float(4.0, "Student-t d.o.f.", minval = 2.1, maxval = 60.0, step = 0.5, group = gc2)
priorK  = input.float(1.0, "Prior pseudo-count", minval = 0.1, step = 0.1, group = gc2)
pThr    = input.float(0.15, "P(change) fire ≥", minval = 0.05, maxval = 0.9, step = 0.05, group = gc2)
postLen = input.int(5, "Emerging-drift lookback", minval = 2, group = gc2)

// P3
erFastLen = input.int(10, "ER fast", minval = 3, group = gc3)
erSlowLen = input.int(30, "ER slow", minval = 10, group = gc3)
slowFloor = input.float(0.30, "Trend floor (slow ER ≥)", minval = 0.05, maxval = 0.9, step = 0.05, group = gc3)
dispLen   = input.int(10, "Displacement lookback", minval = 3, group = gc3)
dispHi    = input.float(70.0, "Stretch percentile ≥", minval = 40.0, maxval = 99.0, group = gc3)
useAbsorb = input.bool(true, "Absorption + panic boost", group = gc3)

// P4
volLkb  = input.int(50, "Volume/range baseline", minval = 5, group = gc4)
volZthr = input.float(2.0, "Volume z ≥", minval = 0.5, step = 0.1, group = gc4)
useTOD  = input.bool(true, "Time-of-day volume normalization", group = gc4)
todRate = input.float(0.10, "TOD adaptation rate", minval = 0.01, maxval = 1.0, step = 0.01, group = gc4)
rngZthr = input.float(1.5, "Range z ≥", minval = 0.5, step = 0.1, group = gc4)
rejThr  = input.float(0.35, "Close rejection ≥", minval = 0.0, maxval = 1.0, step = 0.05, group = gc4)
cvdLen  = input.int(5, "CVD window", minval = 2, group = gc4)
stWin   = input.int(12, "Secondary-test window", minval = 1, group = gc4)
stVolFr = input.float(0.6, "Retest vol ≤ climax ×", minval = 0.1, maxval = 1.0, step = 0.05, group = gc4)
useBVC  = input.bool(true, "BVC order-flow delta (vs close-location)", group = gc4, tooltip = "Split each bar's volume buy/sell with Bulk-Volume Classification — the normal CDF of the standardized return (Easley, López de Prado & O'Hara) — instead of the crude close-location proxy. A principled signed order-flow delta for the climax read; costs one normal-CDF call per bar.")
useConf = input.bool(true, "Conformal 'extreme' rarity", group = gc4, tooltip = "Require the climax composite to exceed its own online (1−α) quantile, so 'extreme' means a calibrated ~α-rare event on THIS symbol rather than a fixed level — consistent across instruments and volatility regimes.")
confAlpha = input.float(0.10, "Extreme rarity α", minval = 0.02, maxval = 0.4, step = 0.01, group = gc4)
confLR  = input.float(1.0, "Conformal adaptation rate", minval = 0.05, step = 0.05, group = gc4)

// P5
swLen    = input.int(8, "Swing length", minval = 2, group = gc5)
dispMin  = input.float(1.0, "Break displacement (× ATR)", minval = 0.1, step = 0.1, group = gc5)
swpWin   = input.int(15, "Sweep→break window", minval = 2, group = gc5)

// Fusion & lifecycle
watchThr = input.float(15.0, "WATCH — instability ≥", minval = 0, maxval = 100, group = gF)
trigThr  = input.float(15.0, "ARM — changepoint ≥", minval = 0, maxval = 100, group = gF)
gateThr  = input.float(12.0, "ARM — exhaustion ≥", minval = 0, maxval = 100, group = gF)
extThr   = input.float(20.0, "EXTREME — climax ≥", minval = 0, maxval = 100, group = gF)
confThr  = input.float(18.0, "CONFIRM — structure ≥", minval = 0, maxval = 100, group = gF)
minSig   = input.int(2, "ARM — min agreeing signals", minval = 1, maxval = 5, group = gF, tooltip = "The engine ARMs when at least this many of the five signals (instability / changepoint / exhaustion / climax / structure) agree on a direction, each above its own threshold. 2 is permissive; 3+ is stricter/higher-conviction.")
armWin   = input.int(25, "Expiry window (bars)", minval = 2, group = gF)
actTier  = input.string("Confirmed", "Actionable tier", options = ["Armed", "Extreme", "Confirmed"], group = gF, tooltip = "Which lifecycle stage emits an actionable signal/alert. Default Confirmed = fewest, highest-precision signals (fires only after the structure break). Extreme is earlier; Armed is earliest and noisiest.")
kish     = input.float(0.40, "P1↔P2 redundancy factor", minval = 0.0, maxval = 1.0, step = 0.05, group = gF)
useDecorr= input.bool(true, "Data-driven decorrelation", group = gF)
corrLen  = input.int(200, "Correlation window", minval = 20, maxval = 500, group = gF)

// Calibration
calHz   = input.int(15, "Resolve after (bars)", minval = 2, maxval = 120, group = gK)
calMove = input.float(1.0, "Target move (× ATR)", minval = 0.1, step = 0.1, group = gK)
calMinN = input.int(10, "Min sample for a verdict", minval = 1, group = gK)
calLR   = input.float(0.02, "Beta-calibration rate", minval = 0.001, maxval = 0.5, step = 0.001, group = gK)
useIso  = input.bool(true, "Isotonic recalibration (non-parametric)", group = gK, tooltip = "Once the sample clears the minimum, map raw conviction through a monotone Pool-Adjacent-Violators fit of predicted→realized, so a shown 70% resolves ~70% on THIS symbol. Beta calibration is the warm-start until then.")
warmN   = input.int(30, "Warm-up shrink samples", minval = 1, group = gK, tooltip = "Conviction is pulled toward 50% until this many outcomes have resolved, so the engine can't show a confident probability it hasn't earned.")
oosFrac = input.float(0.60, "In-sample fraction (rest = OOS)", minval = 0.3, maxval = 0.9, step = 0.05, group = gK, tooltip = "The first fraction of resolved fires is in-sample; only the out-of-sample tail is trusted for the PROVEN badge.")
zProven = input.float(2.50, "Proven z (deflated for multiple tests)", minval = 1.64, maxval = 3.5, step = 0.1, group = gK, tooltip = "Wilson lower-bound z used for the PROVEN badge, raised above 1.96 (Bonferroni-style) because several signals × two sides are tested — so a lucky edge isn't starred.")
calCost = input.float(0.05, "Round-trip cost (R)", minval = 0.0, step = 0.01, group = gK, tooltip = "Cost per trade in R, subtracted from the 1:1 expectancy so Net-R reflects a tradeable edge, not a gross one.")

// Mean-reversion / regime gate — the trend-defense: only fade a series that actually reverts
gMR = "9 · Mean-reversion gate"
mrGateOn = input.bool(true, "Require a mean-reverting regime", group = gMR, tooltip = "The dominant false-reversal mode is fading a trend. This gate scales (and can block) conviction by how mean-reverting the tape is right now: the correlation of prior deviation-from-mean with the next return, plus a Lo-MacKinlay variance ratio. Turn OFF to fire regardless of regime.")
trustLen = input.int(30, "Reversion-trust window", minval = 10, maxval = 400, group = gMR, tooltip = "Rolling correlation of prior deviation-from-mean with the next return; strongly negative = price is actively reverting.")
vrLen    = input.int(100, "Variance-ratio window", minval = 20, maxval = 500, group = gMR)
vrQ      = input.int(4, "Variance-ratio q (aggregation)", minval = 2, maxval = 20, group = gMR, tooltip = "Lo-MacKinlay VR(q) = Var(q-bar return)/(q·Var(1-bar return)). VR<1 = mean-reverting, ≈1 = random walk, >1 = trending.")
mrFloor  = input.float(0.20, "Block a fire below gate", minval = 0.0, maxval = 1.0, step = 0.05, group = gMR, tooltip = "Gate is 0..1 (1 = strongly mean-reverting). A fire is suppressed when the gate is below this floor; conviction is scaled by the gate either way.")
useDF    = input.bool(false, "Dickey-Fuller stationarity (heavier)", group = gMR, tooltip = "Opt-in: also require a first-order Dickey-Fuller unit-root rejection (the series has a statistical equilibrium) over the DF window. Default OFF to keep the compute budget low.")
dfLen    = input.int(100, "Dickey-Fuller window", minval = 30, maxval = 400, group = gMR)
dfCrit   = input.float(-2.86, "DF critical t (reject ≤)", maxval = 0.0, step = 0.1, group = gMR)

// Turbulence gate — self-excitation (Hawkes branching ratio via Fano): don't fade an active cascade
gT = "10 · Turbulence gate (falling-knife veto)"
turbOn   = input.bool(true, "Veto fades during a volatility cascade", group = gT, tooltip = "Large moves treated as a point process; the Fano factor (variance/mean of the shock count) gives a self-excitation branching ratio 0..1. When it is high AND still rising the tape is self-feeding (a falling knife), so conviction is scaled down and fires can be blocked — the classic 'don't catch it' defense.")
hawkK    = input.float(2.0, "Shock threshold (× σ)", minval = 1.0, step = 0.1, group = gT)
hawkSub  = input.int(5, "Shock sub-window", minval = 1, group = gT)
hawkWin  = input.int(50, "Fano window", minval = 10, group = gT)
turbThr  = input.float(0.60, "Cascade level to start vetoing", minval = 0.0, maxval = 1.0, step = 0.05, group = gT)
turbStr  = input.float(0.70, "Veto strength", minval = 0.0, maxval = 1.0, step = 0.05, group = gT)
turbFloor= input.float(0.35, "Block a fire below turb-gate", minval = 0.0, maxval = 1.0, step = 0.05, group = gT)

// Location — confirm a reversal AT an absorption shelf. Built-in occupation-time detector (no wiring,
// no request.security) OR, optionally, consume a published Absorption Shelf's EXP_ outputs.
gLoc = "11 · Location (absorption shelf)"
locOn      = input.bool(true, "Confirm reversals at an absorption shelf", group = gLoc, tooltip = "A reversal that fires AT a high-occupation shelf on the correct side (support below for a bottom, resistance above for a top) gets a bounded conviction boost — a measured price LOCATION the five signals otherwise lack.")
locMode    = input.string("Internal", "Shelf source", options = ["Internal", "External link"], group = gLoc, tooltip = "Internal (default): a built-in occupation-time (dwell) profile finds the nearest hot shelf above/below — self-contained, nothing to wire. External link: instead consume a published Absorption Shelf on the same chart via the four sources below (wire them to its EXP_ data-window plots).")
shelfWin   = input.int(200, "Internal · dwell lookback (bars)", minval = 30, maxval = 500, group = gLoc)
shelfBinAtr= input.float(0.25, "Internal · shelf bin size (× ATR)", minval = 0.05, step = 0.05, group = gLoc, tooltip = "Price-grid resolution for the dwell map. Smaller = finer shelves but more bins. 0.25 ATR keeps a typical bar to a handful of bins (cheap).")
shelfHot   = input.float(0.60, "Internal · hot-shelf fraction (× peak dwell)", minval = 0.2, maxval = 0.95, step = 0.05, group = gLoc, tooltip = "A price bin counts as a shelf when its occupation time is at least this fraction of the busiest bin in the window.")
locBelowSrc= input.source(close, "External · shelf below (EXP_NakedShelfBelow)", group = gLoc)
locAboveSrc= input.source(close, "External · shelf above (EXP_NakedShelfAbove)", group = gLoc)
locPabsSrc = input.source(close, "External · absorption (EXP_ShelfPabs)", group = gLoc)
locRejSrc  = input.source(close, "External · reject-edge (EXP_RejectEdge)", group = gLoc)
locTol     = input.float(0.5, "Near-shelf tolerance (× ATR)", minval = 0.05, step = 0.05, group = gLoc)
locPabsThr = input.float(0.5, "Absorbing strength ≥ (0..1)", minval = 0.0, maxval = 1.0, step = 0.05, group = gLoc)
locBonus   = input.float(1.20, "Conviction × at a confirmed shelf", minval = 1.0, maxval = 2.0, step = 0.05, group = gLoc)

// Chart visuals — interpretation aids (all drawing objects; none count against the 64-plot budget)
gV = "12 · Chart visuals"
showLevels = input.bool(true, "Draw trade levels (Entry / Stop / TP1 / TP2)", group = gV, tooltip = "On a Confirmed fire, draw the entry, the structure stop, and two targets at R-multiples of the stop distance — with right-edge price tags. Uses lines/labels, not plots.")
rr1        = input.float(1.0, "TP1 (× risk)", minval = 0.1, step = 0.1, group = gV)
rr2        = input.float(2.0, "TP2 (× risk)", minval = 0.1, step = 0.1, group = gV)
levLen     = input.int(40, "Level length (bars)", minval = 5, maxval = 400, group = gV)
showSigLbl = input.bool(true, "Signal label (direction + conviction)", group = gV, tooltip = "A compact tag at the arrow, e.g. '▲ BOTTOM · 72%', so conviction reads without opening the panel.")
gradeMk    = input.bool(true, "Grade marker brightness by conviction", group = gV, tooltip = "The Confirmed diamond fades when conviction is low / still learning and brightens as it rises, so strength reads at a glance.")
showGateCue= input.bool(true, "Tint faintly when standing aside (gated)", group = gV, tooltip = "A very faint grey wash when the engine is deliberately holding back (trend/random regime or an active cascade) and no candidate is live — so 'no signal' reads as working, not broken.")
showKey    = input.bool(true, "On-chart legend key", group = gV)
keyPos     = input.string("Bottom Left", "Legend position", options = ["Bottom Left", "Bottom Right", "Top Left", "Middle Left"], group = gV)
showShelf  = input.bool(true, "Draw linked absorption shelf", group = gV, tooltip = "When the location link is wired, draw the naked shelf level(s) the conviction boost comes from.")

// Style
theme    = input.string("Dark", "Theme", options = ["Dark", "Light"], group = gS)
colBull = input.color(#26a69a, "Bottom", inline = "c", group = gS)
colBear = input.color(#ef5350, "Top", inline = "c", group = gS)
showTint= input.bool(true, "Tint background by state", group = gS)
showMk  = input.bool(true, "Reversal markers", group = gS)
showDash= input.bool(true, "Dashboard", group = gS)
dashMode = input.string("Compact", "Dashboard detail", options = ["Compact", "Pro"], group = gS, tooltip = "Compact (default): state, direction, calibrated conviction, which signals support, and the stop. Pro adds the raw conviction, the forward-tested bottom/top hit-rates with Wilson lower bounds vs a matched base rate, and the per-engine peak-strength diagnostic.")

// House palette — theme-aware surfaces / text (directional colours stay the user's Bottom/Top above)
bool  isLight = theme == "Light"
color C_TEXT   = isLight ? color.new(#111318, 0) : color.new(#e8eaed, 0)
color C_MUTED  = isLight ? color.new(#5f6368, 0) : color.new(#9aa0a6, 0)
color C_BG     = isLight ? color.new(#ffffff, 8) : color.new(#0e1116, 10)
color C_HEADER = color.new(#2962ff, 0)
color C_GRID   = color.new(color.gray, 55)

// ───────────────────────────── HELPERS ─────────────────────────────
f_sgn(float x) => x > 0 ? 1 : x < 0 ? -1 : 0
f_sig(float x) => 1.0 / (1.0 + math.exp(-math.max(-30.0, math.min(30.0, x))))
// standard-normal CDF (Zelen & Severo rational approximation) — for BVC order-flow classification
f_npdf(float x) => 0.3989422804014327 * math.exp(-x * x / 2.0)
f_ncdf(float x) =>
    float t = 1.0 / (1.0 + 0.2316419 * math.abs(x))
    float poly = t * (0.319381530 + t * (-0.356563782 + t * (1.781477937 + t * (-1.821255978 + t * 1.330274429))))
    float p = f_npdf(x) * poly
    x >= 0 ? 1.0 - p : p
f_z(series float s, simple int len) =>
    m = ta.sma(s, len)
    sd = ta.stdev(s, len)
    sd <= 0.0 ? 0.0 : (s - m) / sd
f_er(series float s, simple int len) =>
    ch = math.abs(s - s[len])
    vs = math.sum(math.abs(ta.change(s)), len)
    vs != 0.0 ? ch / vs : 0.0
float atr = ta.atr(14)
float ret = (close > 0 and close[1] > 0) ? math.log(close / close[1]) : 0.0

// ══════════════════════════════ 1 · INSTABILITY (PRIOR) ══════════════════════════════
// Wasserstein-1 (earth-mover) distributional-shift: sort the last ewsW returns and the ewsW before
// them, average the matched order-statistic gaps, volatility-normalize, and rank that distance as a
// percentile of its own history. Rising shift = the return distribution is changing shape (variance /
// skew / tail) = a reversal PRIOR. Sorting two ewsW windows on confirmed bars only is cheaper than
// the old 3× Kendall triple-loop AND captures tail/shape change the moment-trend missed.
float retSD = ta.stdev(ret, ewsW)                              // called unconditionally (v6-safe)
var array<float> retBuf = array.new_float(0)
var float w1n = na
if barstate.isconfirmed
    array.push(retBuf, ret)
    if array.size(retBuf) > 2 * ewsW
        array.shift(retBuf)
    if array.size(retBuf) >= 2 * ewsW
        array<float> aRec = array.new_float(0)
        array<float> aPri = array.new_float(0)
        for i = 0 to ewsW - 1
            array.push(aPri, array.get(retBuf, i))            // the older window
            array.push(aRec, array.get(retBuf, i + ewsW))     // the recent window
        array.sort(aRec, order.ascending)
        array.sort(aPri, order.ascending)
        float w1 = 0.0
        for i = 0 to ewsW - 1
            w1 += math.abs(array.get(aRec, i) - array.get(aPri, i))
        w1n := (w1 / ewsW) / math.max(retSD, 1e-9)
float p1risk = nz(ta.percentrank(nz(w1n), 200))               // 0..100, self-calibrating rarity of the shift
float p1drift = ta.ema(ret, driftLen)
int   p1dir = p1drift > 0 ? -1 : p1drift < 0 ? 1 : 0          // fade the prevailing drift
float sig1 = p1dir * p1risk

// ══════════════════════════════ 2 · CHANGEPOINT (TRIGGER) ══════════════════════════════
int Rmax = 40
float p2mu = ta.sma(ret, obsW)
float p2sd = ta.stdev(ret, obsW)
float z = math.max(-zClip, math.min(zClip, (ret - p2mu) / math.max(p2sd, 1e-9)))
float H = hazard
var array<float> RL = array.new_float(Rmax + 1, 0.0)
var array<float> Ss = array.new_float(Rmax + 1, 0.0)
var array<float> Nn = array.new_float(Rmax + 1, 0.0)
var bool inited = false
if not inited
    array.set(RL, 0, 1.0)
    inited := true
float pChange = 0.0
if bar_index > 1
    array<float> newRL = array.new_float(Rmax + 1, 0.0)
    array<float> newSs = array.new_float(Rmax + 1, 0.0)
    array<float> newNn = array.new_float(Rmax + 1, 0.0)
    float cp = 0.0
    int aMax = math.min(bar_index, Rmax - 1)
    for r = 0 to aMax
        float w = array.get(RL, r)
        if w > 0.0
            float nr = array.get(Nn, r)
            float sr = array.get(Ss, r)
            float mu = sr / (priorK + nr)
            float pv = 1.0 + 1.0 / (priorK + nr)
            float t2 = (z - mu) * (z - mu) / pv
            float pi = math.pow(1.0 + t2 / nuDof, -(nuDof + 1.0) / 2.0) / math.sqrt(pv)
            cp += w * pi * H
            array.set(newRL, r + 1, array.get(newRL, r + 1) + w * pi * (1.0 - H))
            array.set(newSs, r + 1, sr + z)
            array.set(newNn, r + 1, nr + 1.0)
    array.set(newRL, 0, cp)
    float tot = 0.0
    for r = 0 to Rmax
        tot += array.get(newRL, r)
    if tot > 0.0
        for r = 0 to Rmax
            array.set(newRL, r, array.get(newRL, r) / tot)
    RL := newRL
    Ss := newSs
    Nn := newNn
    pChange := array.get(RL, 0)
// CUSUM
var float gP = 0.0
var float gN = 0.0
var float vP = 0.0
gP := math.max(0.0, gP + z - 0.5)
gN := math.min(0.0, gN + z + 0.5)
vP := math.max(0.0, vP + (z * z - 1.0) - 0.5)
bool meanBreak = gP > 3.0 or gN < -3.0
bool varBreak  = vP > 4.0
if meanBreak
    gP := 0.0
    gN := 0.0
if varBreak
    vP := 0.0
bool changeFire = (pChange >= pThr and (na(pChange[1]) or pChange[1] < pThr)) or meanBreak or varBreak
float priorDrift = p1drift                              // identical to the instability drift EMA — reuse
float postDrift  = ta.ema(ret, postLen)
bool  accel = (postDrift * priorDrift > 0.0) and (math.abs(postDrift) > math.abs(priorDrift))
int   fireDir = accel ? 0 : priorDrift > 0 ? -1 : priorDrift < 0 ? 1 : 0
float sP = math.min(pChange / pThr, 2.0) / 2.0
float sZ = math.min(math.abs(z) / 4.0, 1.0)
float sC = math.min(math.max(gP, -gN) / 5.0, 1.0)
float p2strength = math.min((0.5 * sP + 0.25 * sZ + 0.25 * sC) * 100.0, 100.0)
var int   rev2Dir = 0
var float rev2Str = 0.0
var int   rev2Age = na
if changeFire and fireDir != 0
    rev2Dir := fireDir
    rev2Str := math.max(p2strength, 20.0)
    rev2Age := 0
else if not na(rev2Age)
    rev2Age := rev2Age + 1
    rev2Str := rev2Str * 0.75
    if rev2Age > 5
        rev2Dir := 0
        rev2Str := 0.0
        rev2Age := na
float sig2 = rev2Dir * rev2Str

// ══════════════════════════════ 3 · EXHAUSTION (GATE) ══════════════════════════════
float erFast = f_er(close, erFastLen)
float erSlow = f_er(close, erSlowLen)
float disp3 = math.abs(close - close[dispLen]) / math.max(atr, 1e-9)
float dispPct = ta.percentrank(disp3, 100)
bool  upLeg = close > close[erSlowLen] and erSlow >= slowFloor
bool  dnLeg = close < close[erSlowLen] and erSlow >= slowFloor
bool  effFade = erFast < erFast[3]
bool  stretched = dispPct >= dispHi
bool  topExh = upLeg and effFade and stretched
bool  botExh = dnLeg and effFade and stretched
int   evtDir = botExh ? 1 : topExh ? -1 : 0
bool  exhFire = evtDir != 0
// absorption + panic
float volSma3 = ta.sma(nz(volume), 20)
bool  hasVol3 = ta.cum(nz(volume)) > 0
float rvol3   = hasVol3 ? nz(volume) / math.max(volSma3, 1e-9) : na
float prog3   = math.abs(close - close[3]) / math.max(atr, 1e-9)
float absorb3 = hasVol3 ? math.min(nz(rvol3) / math.max(prog3, 0.25), 3.0) / 3.0 : 0.0
float atrPk3  = ta.percentrank(atr, 100) / 100.0
float run6    = math.abs(close - close[6]) / math.max(atr, 1e-9)
bool  panic3  = atrPk3 >= 0.80 and run6 >= 2.5
float boost3  = useAbsorb ? 1.0 + 0.40 * absorb3 + (panic3 ? 0.15 : 0.0) : 1.0
var int   rev3Dir = 0
var float rev3Str = 0.0
var int   rev3Age = na
if exhFire
    rev3Dir := evtDir
    rev3Str := math.min((40.0 + 0.6 * nz(dispPct)) * boost3, 100.0)
    rev3Age := 0
else if not na(rev3Age)
    rev3Age := rev3Age + 1
    rev3Str := rev3Str * 0.80
    if rev3Age > 5
        rev3Dir := 0
        rev3Str := 0.0
        rev3Age := na
float sig3 = rev3Dir * rev3Str

// ══════════════════════════════ 4 · CLIMAX (EXTREME) ══════════════════════════════
bool  hasVol = ta.cum(nz(volume)) > 0
float vol0 = nz(volume, 0.0)
float volPlain = f_z(vol0, volLkb)
bool  intrabar = timeframe.isintraday
int   todSlot = intrabar ? hour * 60 + minute : 0
var array<float> todM = array.new_float(1440, na)
var array<float> todV = array.new_float(1440, na)
float todZ = 0.0
if intrabar and hasVol
    float pm = array.get(todM, todSlot)
    float pv = array.get(todV, todSlot)
    todZ := (not na(pm) and pv > 0.0) ? (vol0 - pm) / math.sqrt(pv) : 0.0
    float pm2 = na(pm) ? vol0 : pm
    float dz = vol0 - pm2
    float nm = pm2 + todRate * dz
    float pv2 = na(pv) ? 0.0 : pv
    float nv = (1.0 - todRate) * (pv2 + todRate * dz * dz)
    array.set(todM, todSlot, nm)
    array.set(todV, todSlot, nv)
float volZ = hasVol ? ((useTOD and intrabar) ? todZ : volPlain) : 0.0
float rngZ = f_z(high - low, volLkb)
float den4 = math.max(high - low, 1e-10)
float clv = ((close - low) - (high - close)) / den4
// BVC signed order-flow delta (Easley / López de Prado / O'Hara): buy fraction = Φ(standardized
// return); the signed imbalance 2Φ−1 ∈ (−1,1) is a principled per-bar delta that replaces the crude
// close-location proxy for the climax's flow read. One normal-CDF call per bar.
float oiBVC = 2.0 * f_ncdf(ret / math.max(retSD, 1e-9)) - 1.0
// hoisted rolling sums (stateful — must run every bar, not inside a ternary/conditional)
float bvcSum = math.sum(vol0 * oiBVC, cvdLen)
float clvSum = math.sum(vol0 * clv, cvdLen)
float volSumC = math.sum(vol0, cvdLen)
float cvd = useBVC ? bvcSum : clvSum
float volScale4 = ta.sma(vol0, volLkb)
f_int4(float vz, float rz, float cl) =>
    float a = math.max(math.min((vz - volZthr) / 2.0, 1.0), 0.0)
    float b = math.max(math.min((rz - rngZthr) / 2.0, 1.0), 0.0)
    float c = math.max(math.min((math.abs(cl) - rejThr) / math.max(1.0 - rejThr, 1e-10), 1.0), 0.0)
    30.0 + (a + b + c) / 3.0 * 60.0
// Conformal online (1−α) quantile of the climax composite → a calibrated, symbol-invariant "extreme":
// a breach is a provably ~α-rare event here, so the EXTREME stage fires equally often across symbols.
float climComp = hasVol ? f_int4(volZ, rngZ, clv) : 0.0
var float qConf = 45.0
if barstate.isconfirmed and useConf and hasVol
    qConf := qConf + confLR * ((climComp > qConf ? 1.0 : 0.0) - confAlpha)
bool extRare = not useConf or climComp >= qConf
bool  sigBot4 = hasVol and volZ >= volZthr and rngZ >= rngZthr and clv >= rejThr and extRare
bool  sigTop4 = hasVol and volZ >= volZthr and rngZ >= rngZthr and clv <= -rejThr and extRare
// secondary-test state machine
var int   st4 = 0
var float cxExt = na
var float cxVol = na
var int   cxAge = na
var float cxInt = na
var bool  cxConf = false
if st4 != 0 and not na(cxAge)
    cxAge := cxAge + 1
if sigBot4 or sigTop4
    st4 := sigBot4 ? 1 : -1
    cxExt := sigBot4 ? low : high
    cxVol := vol0
    cxAge := 0
    float cvdN = hasVol ? cvd / math.max(volScale4 * cvdLen, 1e-9) : 0.0
    float cvdAbs = math.min(math.max(sigBot4 ? cvdN : -cvdN, 0.0), 1.0)
    cxInt := math.min(f_int4(volZ, rngZ, clv) * (1.0 + 0.20 * cvdAbs), 100.0)
    cxConf := false
if st4 != 0 and cxAge > 0
    bool inval = st4 == 1 ? (low < cxExt - 0.25 * atr) : (high > cxExt + 0.25 * atr)
    bool near = st4 == 1 ? (low <= cxExt + 0.5 * atr and low >= cxExt - 0.25 * atr) : (high >= cxExt - 0.5 * atr and high <= cxExt + 0.25 * atr)
    bool lowerVol = vol0 <= cxVol * stVolFr
    if inval or cxAge > stWin
        st4 := 0
        cxAge := na
        cxConf := false
    else if (not cxConf) and near and lowerVol
        cxConf := true
        cxInt := math.min(nz(cxInt) * 1.25, 100.0)   // a held lower-volume retest strengthens the climax
int   clx4Dir = st4 == 1 ? 1 : st4 == -1 ? -1 : 0
float sig4 = (st4 != 0 and not na(cxInt)) ? clx4Dir * cxInt : 0.0

// ══════════════════════════════ 5 · STRUCTURE (CONFIRM) ══════════════════════════════
float ph5 = ta.pivothigh(swLen, swLen)
float pl5 = ta.pivotlow(swLen, swLen)
var float lastPH = na
var float lastPL = na
if not na(ph5)
    lastPH := ph5
if not na(pl5)
    lastPL := pl5
bool sweepHi = not na(lastPH) and high > lastPH and close < lastPH   // buy-side taken, closed back → bearish
bool sweepLo = not na(lastPL) and low < lastPL and close > lastPL    // sell-side taken → bullish
float disp5 = math.abs(close - close[1]) / math.max(atr, 1e-9)
bool breakUp = not na(lastPH) and close > lastPH and disp5 >= dispMin
bool breakDn = not na(lastPL) and close < lastPL and disp5 >= dispMin
var int   swpDir = 0
var int   swpAge = na
var float swpStop = na
if sweepLo
    swpDir := 1
    swpAge := 0
    swpStop := low
else if sweepHi
    swpDir := -1
    swpAge := 0
    swpStop := high
else if not na(swpAge)
    swpAge := swpAge + 1
    if swpAge > swpWin
        swpDir := 0
        swpAge := na
bool p5fire = (swpDir == 1 and breakUp) or (swpDir == -1 and breakDn)
var int   rev5Dir = 0
var float rev5Str = 0.0
var int   rev5Age = na
var float rev5Stop = na
if p5fire
    rev5Dir := swpDir
    rev5Str := math.min(40.0 + 30.0 * math.min(disp5 / 2.0, 1.0) + 30.0, 100.0)
    rev5Stop := swpStop
    rev5Age := 0
else if not na(rev5Age)
    rev5Age := rev5Age + 1
    if rev5Age > 8
        rev5Dir := 0
        rev5Str := 0.0
        rev5Age := na
float sig5 = rev5Dir * rev5Str

// ══════════════════════════════ MEAN-REVERSION / REGIME GATE ══════════════════════════════
// Trend-defense — the dominant false-reversal mode is fading a series with no equilibrium. This gate
// (0..1, 1 = strongly mean-reverting) scales, and can block, the fused conviction.
//  • reversion-trust : correlation of prior deviation-from-mean with the NEXT return; negative = reverting
//  • variance-ratio  : Lo-MacKinlay VR(q) < 1 = mean-reverting, ≈1 = random walk, > 1 = trending
//  • Dickey-Fuller   : (opt-in) unit-root rejection → the series has a statistical equilibrium
float mrMean     = ta.sma(close, trustLen)
float mrDev      = close - mrMean
float trustCorr  = ta.correlation(mrDev[1], ret, trustLen)
float trustScore = na(trustCorr) ? 0.0 : math.max(0.0, -trustCorr)                 // 0..1
float qSum = math.sum(ret, vrQ)
float vVarq = ta.variance(qSum, vrLen)
float vVar1 = ta.variance(ret, vrLen)
float vr = vVar1 > 0.0 ? vVarq / (vrQ * vVar1) : na
float regimeRev = na(vr) ? 0.5 : vr < 1.0 ? math.min((1.0 - vr) / 0.5, 1.0) : 0.0  // 1 = reverting, 0 = trend/random
// Dickey-Fuller unit-root t-stat (opt-in): regress Δx on x[1] over dfLen (no ta.* inside — v6-safe)
float dfStat = na
if useDF
    float sx = 0.0
    float sy = 0.0
    float nn = 0.0
    for i = 0 to dfLen - 1
        sx += close[i + 1]
        sy += close[i] - close[i + 1]
        nn += 1.0
    float mx = sx / nn
    float my = sy / nn
    float sxx = 0.0
    float sxy = 0.0
    for i = 0 to dfLen - 1
        float dx = close[i + 1] - mx
        sxx += dx * dx
        sxy += dx * ((close[i] - close[i + 1]) - my)
    float dfBeta = sxx > 0.0 ? sxy / sxx : na
    if not na(dfBeta)
        float sse = 0.0
        for i = 0 to dfLen - 1
            float resid = (close[i] - close[i + 1]) - (my + dfBeta * (close[i + 1] - mx))
            sse += resid * resid
        float se = (nn > 2.0 and sxx > 0.0) ? math.sqrt(sse / (nn - 2.0) / sxx) : na
        dfStat := (not na(se) and se > 0.0) ? dfBeta / se : na
bool  dfOK   = not useDF or (not na(dfStat) and dfStat <= dfCrit)
float mrGate = mrGateOn ? (0.5 * trustScore + 0.5 * regimeRev) * (dfOK ? 1.0 : 0.0) : 1.0

// TURBULENCE — self-excitation (Hawkes branching ratio via Fano factor of the shock count). When the
// branching ratio is high AND still rising, the move is self-feeding (a falling knife) — scale the
// conviction down and, below a floor, block the fire. Cheap: one shock flag, one sma, one variance.
float shock  = math.abs(ret) > hawkK * math.max(retSD, 1e-9) ? 1.0 : 0.0
float subCnt = math.sum(shock, hawkSub)
float fMean  = ta.sma(subCnt, hawkWin)
float fVar   = ta.variance(subCnt, hawkWin)
float fano   = fMean > 0.0 ? fVar / fMean : na
float branch = na(fano) ? 0.0 : math.max(0.0, math.min(1.0, 1.0 - 1.0 / math.sqrt(math.max(fano, 1.0))))
bool  cascade = branch >= turbThr and branch >= nz(branch[1], 0.0)        // active AND intensifying
float turbGate = (turbOn and cascade) ? math.max(0.0, 1.0 - turbStr * (branch - turbThr) / math.max(1.0 - turbThr, 1e-9)) : 1.0
float guardGate = mrGate * turbGate                                       // combined trend-defense + falling-knife veto

// ══════════════════════════════ INTERNAL ABSORPTION SHELF (occupation-time, self-contained) ═══════
// A built-in dwell profile: a fixed-tick price grid accumulates occupation time (a reversible ring
// buffer — add the entering bar's levels, subtract the bar leaving the window). The nearest bin whose
// dwell is a high fraction of the peak, below and above price, is the support / resistance shelf. No
// request.security; O(bar-bins) to maintain + O(active-bins) to scan. Used only when Location = Internal.
float atrRef = ta.atr(50)
var float binSz = na
if na(binSz) and not na(atrRef) and atrRef > 0.0
    binSz := shelfBinAtr * atrRef
bool  shelfInt = locOn and locMode == "Internal" and not na(binSz) and binSz > 0.0
int   loB = na(binSz) or binSz <= 0.0 ? na : int(math.floor(low / binSz))
int   hiB = na(binSz) or binSz <= 0.0 ? na : int(math.floor(high / binSz))
var map<int, float> occ = map.new<int, float>()
// ADD the entering bar (same span<500 guard as the subtract, so a bar added is later subtracted symmetrically)
if shelfInt and barstate.isconfirmed and not na(loB) and hiB >= loB and (hiB - loB) < 500
    for b = loB to hiB
        occ.put(b, nz(occ.get(b)) + 1.0)
// SUBTRACT the leaving bar in its OWN block (not nested under the current bar's size) so a normal
// leaving bar is always retired even on a day the current bar is unusually large.
if shelfInt and barstate.isconfirmed
    int loOld = loB[shelfWin]
    int hiOld = hiB[shelfWin]
    if not na(loOld) and hiOld >= loOld and (hiOld - loOld) < 500
        for b = loOld to hiOld
            float v = nz(occ.get(b)) - 1.0
            if v <= 0.0
                occ.remove(b)
            else
                occ.put(b, v)

// ══════════════════════════════ FUSION · LIFECYCLE ══════════════════════════════
var int   state = 0
var int   candDir = 0
var int   clock = na
var float stopLvl = na
if state >= 2 and not na(clock)
    clock := clock + 1
if state >= 2 and state < 4 and not na(clock) and clock > armWin
    state := 0
    candDir := 0
    clock := na

// count agreeing signals per direction (each signal above its own threshold)
int nUp = (sig1 >= watchThr ? 1 : 0) + (sig2 >= trigThr ? 1 : 0) + (sig3 >= gateThr ? 1 : 0) + (sig4 >= extThr ? 1 : 0) + (sig5 >= confThr ? 1 : 0)
int nDn = (sig1 <= -watchThr ? 1 : 0) + (sig2 <= -trigThr ? 1 : 0) + (sig3 <= -gateThr ? 1 : 0) + (sig4 <= -extThr ? 1 : 0) + (sig5 <= -confThr ? 1 : 0)
int confDir = nUp >= minSig and nUp >= nDn ? 1 : nDn >= minSig and nDn > nUp ? -1 : 0

if state <= 1
    if confDir != 0
        state := 2
        candDir := confDir
        clock := 0
        // keep stopLvl from the previous confirmed trade until a new CONFIRM overwrites it, so the
        // dashboard "Stop" always matches the last drawn Stop line rather than blanking to "—" on ARM
    else
        int wd = math.abs(sig1) >= watchThr ? f_sgn(sig1) : 0
        state := wd != 0 ? 1 : 0
        candDir := wd
if state == 2 and math.abs(sig4) >= extThr and f_sgn(sig4) == candDir
    state := 3
if (state == 2 or state == 3) and math.abs(sig5) >= confThr and f_sgn(sig5) == candDir
    state := 4
    // structure sweep stop if available, else an ATR fallback — so a confirmed fire ALWAYS has a stop
    // (matches the drawn Stop line and never leaves the dashboard showing "—" after a real signal)
    stopLvl := not na(rev5Stop) ? rev5Stop : close - candDir * calMove * atr

// correlation-aware fusion toward candDir
float p12corr = ta.correlation(sig1, sig2, corrLen)
float kishEff = (useDecorr and not na(p12corr)) ? math.min(math.abs(p12corr), 1.0) : kish
f_supp(float s, int d, float thr) => (f_sgn(s) == d and math.abs(s) >= thr) ? math.min(math.abs(s), 100.0) : 0.0
float r1 = f_supp(sig1, candDir, watchThr)
float r2 = f_supp(sig2, candDir, trigThr)
float g3 = f_supp(sig3, candDir, gateThr)
float x4 = f_supp(sig4, candDir, extThr)
float c5 = f_supp(sig5, candDir, confThr)
float regB = math.max(r1, r2) + kishEff * math.min(r1, r2)
float num = 1.0 * regB + 0.8 * g3 + 1.2 * x4 + 1.2 * c5
float den = 100.0 * (1.0 + kishEff) + 0.8 * 100.0 + 1.2 * 100.0 + 1.2 * 100.0
float convRaw = (candDir != 0 and den > 0.0) ? num / den * 100.0 : 0.0
// INTERNAL SHELF SCAN — nearest hot support/resistance bin from the occupation map. Gated to run only
// when a candidate is live (candDir != 0, for the conviction boost) or on the last bar (for drawing),
// so the map.keys scan is skipped on ~99% of bars. candDir is final here, so the Armed-tier boost is
// unaffected (the arm bar has candDir != 0).
float intBelow = na
float intAbove = na
float intBelowP = na
float intAboveP = na
if shelfInt and (candDir != 0 or barstate.islast)
    array<int> ks = map.keys(occ)
    int nk = array.size(ks)
    if nk > 0
        float occMax = 0.0
        for i = 0 to nk - 1
            occMax := math.max(occMax, nz(occ.get(array.get(ks, i))))
        if occMax > 0.0
            float thr = occMax * shelfHot
            float distB = 1e20
            float distA = 1e20
            for i = 0 to nk - 1
                int k = array.get(ks, i)
                float v = nz(occ.get(k))
                if v >= thr
                    float px = (k + 0.5) * binSz
                    if px < close and (close - px) < distB
                        distB := close - px
                        intBelow := px
                        intBelowP := v / occMax
                    if px > close and (px - close) < distA
                        distA := px - close
                        intAbove := px
                        intAboveP := v / occMax
// LOCATION LINK — a fire at a naked absorbing shelf (internal detector or linked Absorption Shelf) on
// the correct side is location-confirmed → a bounded conviction boost.
bool  extLink   = locMode == "External link"
float shBelowV  = extLink ? (locBelowSrc != close ? locBelowSrc : na) : intBelow
float shAboveV  = extLink ? (locAboveSrc != close ? locAboveSrc : na) : intAbove
float shPabsV   = candDir == 1 ? (extLink ? (locPabsSrc != close ? nz(locPabsSrc) : na) : intBelowP) : candDir == -1 ? (extLink ? (locPabsSrc != close ? nz(locPabsSrc) : na) : intAboveP) : na
float shRejV    = extLink ? (locRejSrc != close ? nz(locRejSrc) : na) : na
bool  locLinked  = locOn and (not na(shBelowV) or not na(shAboveV))
float locLvl     = candDir == 1 ? shBelowV : candDir == -1 ? shAboveV : na
bool  locNear    = locOn and not na(locLvl) and math.abs(close - locLvl) <= locTol * atr
bool  locConfirm = locNear and ((not na(shRejV) and shRejV > 0.0) or (not na(shPabsV) and shPabsV >= locPabsThr))
float locMult    = locConfirm ? locBonus : 1.0
convRaw := math.min(convRaw * locMult, 100.0) * guardGate  // location boost, then trend-defense × turbulence

// actionable fire (blocked when the mean-reversion gate or the turbulence gate is below its floor)
bool actFire = switch actTier
    "Armed"   => state == 2 and state[1] < 2
    "Extreme" => state == 3 and state[1] != 3
    => state == 4 and state[1] != 4
actFire := actFire and (not mrGateOn or mrGate >= mrFloor) and (not turbOn or turbGate >= turbFloor)
if state == 4 and state[1] == 4
    state := 0
    candDir := 0
    clock := na

// ══════════════════════════════ CALIBRATION (beta warm-start → isotonic; honesty discipline) ══════
int B = 10                                                    // reliability bins for the isotonic fit
var array<float> beta = array.new_float(3, 0.0)
var bool betaInit = false
if not betaInit
    array.set(beta, 0, 0.0)
    array.set(beta, 1, 1.0)
    array.set(beta, 2, -1.0)
    betaInit := true
var array<float> binN    = array.new_float(10, 0.0)           // uniqueness-weighted count per conviction bin
var array<float> binHit  = array.new_float(10, 0.0)           // uniqueness-weighted wins per bin
var array<float> poolRate = array.new_float(10, na)           // PAV-pooled realized rate per bin (built on last bar)
var array<float> winSeq  = array.new_float(0)                 // resolved outcome sequence (0/1), for the OOS split
var array<float> wSeq    = array.new_float(0)                 // matching uniqueness weights
f_betacal(float raw) =>
    float pp = math.min(math.max(raw / 100.0, 1e-4), 1.0 - 1e-4)
    f_sig(array.get(beta, 0) + array.get(beta, 1) * math.log(pp) + array.get(beta, 2) * math.log(1.0 - pp)) * 100.0
f_isoMap(float raw) =>
    int bIdx = math.max(0, math.min(B - 1, int(math.floor(raw / 100.0 * B))))
    float pr = array.get(poolRate, bIdx)
    na(pr) ? na : pr * 100.0
// weighted Wilson LOWER bound (proportion) — z is deflated (zProven) for the multiple-testing badge
f_wlbf(float h, float n, float zc) =>
    float lb = na
    if n > 0.0
        float p = h / n
        float z2 = zc * zc
        float denom = 1.0 + z2 / n
        float center = (p + z2 / (2.0 * n)) / denom
        float half = (zc * math.sqrt(p * (1.0 - p) / n + z2 / (4.0 * n * n))) / denom
        lb := center - half
    lb
var int nBull = 0
var int hitBull = 0
var int nBear = 0
var int hitBear = 0
// matched, DIRECTION-SPLIT base rates: the unconditional chance an up (or down) move of the same
// ±target size occurred over the same horizon — so Bottom hit% is compared to base-UP% and Top hit%
// to base-DOWN%, an apples-to-apples "vs base" rather than a pooled two-sided frequency.
var int baseUpN = 0
var int baseUpHit = 0
var int baseDnN = 0
var int baseDnHit = 0
int   fSide = actFire ? candDir : 0
float fConv = actFire ? convRaw : na
// uniqueness weight: overlapping forward windows aren't independent (López de Prado). Weight each
// resolved fire by 1/(concurrent fires in its calHz window) so clustered fires don't over-count.
float fireF    = actFire ? 1.0 : 0.0
float concurNow = math.sum(fireF, calHz)
if bar_index > calHz
    int sThen = fSide[calHz]
    float atrE = atr[calHz]
    float entry = close[calHz]
    if sThen != 0 and not na(atrE)
        float conv = fConv[calHz]
        float tgt = calMove * atrE
        float moved = close - entry
        bool hit = sThen == 1 ? (moved >= tgt) : (moved <= -tgt)
        float w = 1.0 / math.max(1.0, nz(concurNow[calHz], 1.0))
        if sThen == 1
            nBull += 1
            hitBull += hit ? 1 : 0
        else
            nBear += 1
            hitBear += hit ? 1 : 0
        // isotonic bins + OOS sequence (uniqueness-weighted)
        int bIdx = math.max(0, math.min(B - 1, int(math.floor(nz(conv, 50.0) / 100.0 * B))))
        array.set(binN, bIdx, array.get(binN, bIdx) + w)
        array.set(binHit, bIdx, array.get(binHit, bIdx) + w * (hit ? 1.0 : 0.0))
        array.push(winSeq, hit ? 1.0 : 0.0)
        array.push(wSeq, w)
        // beta warm-start update (online logistic in log-odds)
        float pp = math.min(math.max(conv / 100.0, 1e-4), 1.0 - 1e-4)
        float lp = math.log(pp)
        float l1p = math.log(1.0 - pp)
        float ph = f_sig(array.get(beta, 0) + array.get(beta, 1) * lp + array.get(beta, 2) * l1p)
        float ge = ph - (hit ? 1.0 : 0.0)
        array.set(beta, 0, array.get(beta, 0) - calLR * ge)
        array.set(beta, 1, array.get(beta, 1) - calLR * (ge * lp))
        array.set(beta, 2, array.get(beta, 2) - calLR * (ge * l1p))
    if not na(atrE)
        float tgtB = calMove * atrE
        float movedB = close - entry
        baseUpN += 1
        baseUpHit += movedB >= tgtB ? 1 : 0
        baseDnN += 1
        baseDnHit += movedB <= -tgtB ? 1 : 0
int totRes = nBull + nBear
// honesty roll-up (built once, on the last bar, where the dashboard reads it)
var float effN   = 0.0
var float oosHit = na
var float oosLB  = na
var float netR   = na
var bool  proven = false
if barstate.islast
    // isotonic Pool-Adjacent-Violators fit predicted→realized over the filled bins
    array<float> bv = array.new_float(0)
    array<float> bw = array.new_float(0)
    array<int>   bi = array.new_int(0)
    array<int>   bj = array.new_int(0)
    for k = 0 to B - 1
        float wk = array.get(binN, k)
        if wk > 0.0
            array.push(bv, array.get(binHit, k) / wk)
            array.push(bw, wk)
            array.push(bi, k)
            array.push(bj, k)
    bool merged = true
    while merged and array.size(bv) >= 2
        merged := false
        for k = 0 to array.size(bv) - 2
            if array.size(bv) > k + 1 and array.get(bv, k) > array.get(bv, k + 1)
                float w1 = array.get(bw, k)
                float w2 = array.get(bw, k + 1)
                array.set(bv, k, (array.get(bv, k) * w1 + array.get(bv, k + 1) * w2) / (w1 + w2))
                array.set(bw, k, w1 + w2)
                array.set(bj, k, array.get(bj, k + 1))
                array.remove(bv, k + 1)
                array.remove(bw, k + 1)
                array.remove(bi, k + 1)
                array.remove(bj, k + 1)
                merged := true
                break
    for k = 0 to B - 1
        array.set(poolRate, k, na)
    if array.size(bv) > 0
        for b = 0 to array.size(bv) - 1
            for kk = array.get(bi, b) to array.get(bj, b)
                array.set(poolRate, kk, array.get(bv, b))
    // effective-N + out-of-sample edge + Net-R
    int sz = array.size(winSeq)
    float wsum = 0.0
    float whsum = 0.0
    if sz > 0
        for i = 0 to sz - 1
            wsum += array.get(wSeq, i)
            whsum += array.get(wSeq, i) * array.get(winSeq, i)
    effN := wsum
    int cut = int(math.floor(sz * oosFrac))
    float ow = 0.0
    float owh = 0.0
    if sz > 0 and cut <= sz - 1
        for i = cut to sz - 1
            ow += array.get(wSeq, i)
            owh += array.get(wSeq, i) * array.get(winSeq, i)
    oosHit := ow > 0.0 ? owh / ow * 100.0 : na
    oosLB  := f_wlbf(owh, ow, zProven)
    float baseP = (baseUpN + baseDnN) > 0 ? float(baseUpHit + baseDnHit) / float(baseUpN + baseDnN) : na
    proven := not na(oosLB) and not na(baseP) and ow >= calMinN and oosLB > baseP
    netR   := wsum > 0.0 ? 2.0 * (whsum / wsum) - 1.0 - calCost : na
// conviction: isotonic once the sample is sufficient, else the beta warm-start; then shrink toward
// 50% until warmN outcomes have resolved so it can't show a confidence it hasn't earned.
float convBeta = f_betacal(convRaw)
float convIso  = (useIso and totRes >= calMinN) ? f_isoMap(convRaw) : na
float convBase = not na(convIso) ? convIso : convBeta
float shrinkF  = warmN > 0 ? math.min(1.0, totRes / float(warmN)) : 1.0
float convCal  = 50.0 + (convBase - 50.0) * shrinkF

// diagnostic: peak strength each engine has produced recently (reveals which signals are alive)
float pk1 = ta.highest(math.abs(sig1), 500)
float pk2 = ta.highest(math.abs(sig2), 500)
float pk3 = ta.highest(math.abs(sig3), 500)
float pk4 = ta.highest(math.abs(sig4), 500)
float pk5 = ta.highest(math.abs(sig5), 500)

// ══════════════════════════════ OUTPUT (bare) ══════════════════════════════
string stateTxt = state == 4 ? "CONFIRMED" : state == 3 ? "EXTREME" : state == 2 ? "ARMED" : state == 1 ? "WATCH" : "—"
string dirTxt = candDir == 1 ? "BOTTOM ▲" : candDir == -1 ? "TOP ▼" : "—"
color  dirCol = candDir == 1 ? colBull : candDir == -1 ? colBear : color.gray

// conviction-graded marker colour — brighter = higher calibrated conviction (dim while learning)
int   mkT = gradeMk ? math.max(0, math.min(75, int(math.round(75.0 - 0.75 * nz(convCal, 40.0))))) : 0
color mkBull = color.new(colBull, mkT)
color mkBear = color.new(colBear, mkT)
// gate the EXTREME triangles with the same floor as the fire, so they don't show while standing aside
bool gateOK = (not mrGateOn or mrGate >= mrFloor) and (not turbOn or turbGate >= turbFloor)
plotshape(showMk and gateOK and state == 3 and state[1] != 3 and candDir == 1, "Extreme bottom", shape.triangleup, location.belowbar, color.new(colBull, 45), size = size.small)
plotshape(showMk and gateOK and state == 3 and state[1] != 3 and candDir == -1, "Extreme top", shape.triangledown, location.abovebar, color.new(colBear, 45), size = size.small)
plotshape(showMk and actFire and candDir == 1, "Confirmed bottom", shape.diamond, location.belowbar, mkBull, size = size.small)
plotshape(showMk and actFire and candDir == -1, "Confirmed top", shape.diamond, location.abovebar, mkBear, size = size.small)
// stop cross is shown only when the full trade-levels overlay is OFF (else the labelled Stop line covers it)
plot(showLevels ? na : (state >= 3 and not na(stopLvl) ? stopLvl : na), "Stop", color = color.new(color.gray, 0), style = plot.style_cross, linewidth = 2)
// background: lifecycle wash (state≥2) OR a faint stand-aside tint when gated with no live candidate
bool  gatedOff = (mrGateOn or turbOn) and state < 2 and (guardGate < mrFloor or cascade)
color washCol = (showTint and state >= 2) ? color.new(candDir == 1 ? colBull : colBear, state == 4 ? 82 : state == 3 ? 88 : 93) : (showGateCue and gatedOff) ? color.new(color.gray, 94) : na
bgcolor(washCol)

alertcondition(actFire and candDir == 1, "Reversal — bottom", "Reversal confluence: potential bottom")
alertcondition(actFire and candDir == -1, "Reversal — top", "Reversal confluence: potential top")

// FIX: force float division (was integer h/n → every rate floored to 0%). 100.0 * h / n is float.
f_pct(int h, int n) => n == 0 ? na : 100.0 * h / n
// Wilson score interval LOWER bound (proportion, %) — a conservative floor on a hit-rate given its
// sample size, so small n visibly discounts the claim (house-standard honesty requirement).
f_wlb(int h, int n) =>
    float lb = na
    if n > 0
        float p = h / float(n)
        float z2 = 1.96 * 1.96
        float denom = 1.0 + z2 / n
        float center = (p + z2 / (2.0 * n)) / denom
        float half = (1.96 * math.sqrt(p * (1.0 - p) / n + z2 / (4.0 * n * n))) / denom
        lb := (center - half) * 100.0
    lb
var table dash = table.new(position.top_right, 2, dashMode == "Pro" ? 14 : 5, border_width = 1, frame_width = 1, frame_color = C_GRID)
bool proDash = dashMode == "Pro"
bool gatesOff = not mrGateOn and not turbOn
string gateWord = gatesOff ? "off" : cascade ? "cascade!" : guardGate >= 0.6 ? "reverting" : guardGate >= 0.3 ? "mixed" : "trend/random"
color  gateCol  = gatesOff ? C_MUTED : (cascade or guardGate < 0.3) ? colBear : guardGate >= 0.6 ? colBull : C_MUTED
if showDash and barstate.islast
    // ── Compact (default): state, direction, calibrated conviction (✓ = proven), regime gate, stop ──
    table.cell(dash, 0, 0, "REVERSAL", text_color = color.white, bgcolor = C_HEADER)
    table.cell(dash, 1, 0, stateTxt, text_color = color.white, bgcolor = C_HEADER)
    table.cell(dash, 0, 1, "Direction", text_color = C_MUTED, text_size = size.small, bgcolor = C_BG)
    table.cell(dash, 1, 1, dirTxt, text_color = dirCol, text_size = size.small, bgcolor = C_BG)
    table.cell(dash, 0, 2, "Conviction (cal)", text_color = C_MUTED, text_size = size.small, bgcolor = C_BG)
    table.cell(dash, 1, 2, totRes >= calMinN ? str.tostring(convCal, "#") + "%" + (proven ? " ✓" : "") : "learning (" + str.tostring(totRes) + ")", text_color = totRes >= calMinN ? dirCol : C_MUTED, text_size = size.small, bgcolor = C_BG)
    table.cell(dash, 0, 3, "Gate (regime·turb)", text_color = C_MUTED, text_size = size.small, bgcolor = C_BG)
    table.cell(dash, 1, 3, gatesOff ? "off" : str.tostring(guardGate * 100.0, "#") + "% · " + gateWord, text_color = gateCol, text_size = size.small, bgcolor = C_BG)
    table.cell(dash, 0, 4, "Stop", text_color = C_MUTED, text_size = size.small, bgcolor = C_BG)
    table.cell(dash, 1, 4, na(stopLvl) ? "—" : str.tostring(stopLvl, format.mintick), text_color = C_TEXT, text_size = size.small, bgcolor = C_BG)
    if proDash
        // ── Pro: support, raw conviction, forward-tested hit-rates, OOS edge (deflated LB) + Net-R ──
        float bUp = f_pct(baseUpHit, baseUpN)
        float bDn = f_pct(baseDnHit, baseDnN)
        float baseAll = f_pct(baseUpHit + baseDnHit, baseUpN + baseDnN)
        string sup = (r1 > 0 ? "1✓ " : "1· ") + (r2 > 0 ? "2✓ " : "2· ") + (g3 > 0 ? "3✓ " : "3· ") + (x4 > 0 ? "4✓ " : "4· ") + (c5 > 0 ? "5✓" : "5·")
        table.cell(dash, 0, 5, "Support", text_color = C_MUTED, text_size = size.small, bgcolor = C_BG)
        table.cell(dash, 1, 5, sup, text_color = C_TEXT, text_size = size.small, bgcolor = C_BG)
        table.cell(dash, 0, 6, "Conviction (raw)", text_color = C_MUTED, text_size = size.small, bgcolor = C_BG)
        table.cell(dash, 1, 6, str.tostring(convRaw, "#") + "%", text_color = C_TEXT, text_size = size.small, bgcolor = C_BG)
        table.cell(dash, 0, 7, "Bottom hit% (n)", text_color = colBull, text_size = size.small, bgcolor = C_BG)
        table.cell(dash, 1, 7, nBull < calMinN ? "n/a (" + str.tostring(nBull) + ")" : str.tostring(f_pct(hitBull, nBull), "#.#") + "% (" + str.tostring(nBull) + ") vs " + (na(bUp) ? "—" : str.tostring(bUp, "#") + "%"), text_color = colBull, text_size = size.small, bgcolor = C_BG)
        table.cell(dash, 0, 8, "Top hit% (n)", text_color = colBear, text_size = size.small, bgcolor = C_BG)
        table.cell(dash, 1, 8, nBear < calMinN ? "n/a (" + str.tostring(nBear) + ")" : str.tostring(f_pct(hitBear, nBear), "#.#") + "% (" + str.tostring(nBear) + ") vs " + (na(bDn) ? "—" : str.tostring(bDn, "#") + "%"), text_color = colBear, text_size = size.small, bgcolor = C_BG)
        table.cell(dash, 0, 9, "OOS edge (LB vs base)", text_color = C_MUTED, text_size = size.small, bgcolor = C_BG)
        table.cell(dash, 1, 9, na(oosHit) ? "learning" : str.tostring(oosHit, "#.#") + "% · LB " + (na(oosLB) ? "—" : str.tostring(oosLB * 100.0, "#.#")) + " vs " + (na(baseAll) ? "—" : str.tostring(baseAll, "#")) + "%" + (proven ? " ✓" : ""), text_color = proven ? dirCol : C_MUTED, text_size = size.small, bgcolor = C_BG)
        table.cell(dash, 0, 10, "Net-R · Nₑff", text_color = C_MUTED, text_size = size.small, bgcolor = C_BG)
        table.cell(dash, 1, 10, (na(netR) ? "—" : str.tostring(netR, "+0.00;-0.00") + " R") + " · " + str.tostring(effN, "#"), text_color = (not na(netR) and netR > 0) ? colBull : C_MUTED, text_size = size.small, bgcolor = C_BG)
        table.cell(dash, 0, 11, "Peak 1/2/3/4/5", text_color = C_MUTED, text_size = size.small, bgcolor = C_BG)
        table.cell(dash, 1, 11, str.tostring(pk1, "#") + "/" + str.tostring(pk2, "#") + "/" + str.tostring(pk3, "#") + "/" + str.tostring(pk4, "#") + "/" + str.tostring(pk5, "#"), text_color = C_TEXT, text_size = size.small, bgcolor = C_BG)
        float toxDisp = volSumC > 0.0 ? nz(cvd) / math.max(volScale4 * cvdLen, 1e-9) : na
        table.cell(dash, 0, 12, "Flow · turb", text_color = C_MUTED, text_size = size.small, bgcolor = C_BG)
        table.cell(dash, 1, 12, (na(toxDisp) ? "n/a" : (toxDisp >= 0 ? "+" : "") + str.tostring(toxDisp, "0.00")) + " · " + str.tostring(branch * 100.0, "#") + "%" + (cascade ? " ▲" : ""), text_color = cascade ? colBear : (na(toxDisp) ? C_MUTED : toxDisp > 0 ? colBull : colBear), text_size = size.small, bgcolor = C_BG)
        string locSrcTxt = not locOn ? "off" : extLink ? "ext" : "int"
        string locTxt = not locOn ? "off" : (not locLinked ? (extLink ? "unwired" : "warming") : locConfirm ? "at shelf ✓" : locNear ? "near shelf" : "no shelf")
        table.cell(dash, 0, 13, "Location (" + locSrcTxt + ")", text_color = C_MUTED, text_size = size.small, bgcolor = C_BG)
        table.cell(dash, 1, 13, locTxt + (not na(locLvl) ? "  " + str.tostring(locLvl, format.mintick) : ""), text_color = locConfirm ? dirCol : C_MUTED, text_size = size.small, bgcolor = C_BG)

// ══════════════════════════════ CHART VISUALS  (drawing objects — no plot budget) ══════════════════
// Trade levels + signal label are drawn on the CONFIRMED fire and kept as the latest trade only
// (deleted and redrawn on the next fire). Non-repainting: created on confirmed bars.
var line  lnE   = na
var line  lnS   = na
var line  lnT1  = na
var line  lnT2  = na
var label lbE   = na
var label lbS   = na
var label lbT1  = na
var label lbT2  = na
var label lbSig = na
if actFire and barstate.isconfirmed and (showLevels or showSigLbl)
    line.delete(lnE)
    line.delete(lnS)
    line.delete(lnT1)
    line.delete(lnT2)
    label.delete(lbE)
    label.delete(lbS)
    label.delete(lbT1)
    label.delete(lbT2)
    label.delete(lbSig)
    float entry = close
    float stp   = not na(stopLvl) ? stopLvl : entry - candDir * calMove * atr
    float risk  = math.max(math.abs(entry - stp), atr * 0.1)
    float t1    = entry + candDir * rr1 * risk
    float t2    = entry + candDir * rr2 * risk
    int   xR    = bar_index + levLen
    if showLevels
        lnE  := line.new(bar_index, entry, xR, entry, xloc = xloc.bar_index, color = color.new(color.gray, 0), style = line.style_solid,  width = 1)
        lnS  := line.new(bar_index, stp,   xR, stp,   xloc = xloc.bar_index, color = color.new(colBear, 0),    style = line.style_dashed, width = 1)
        lnT1 := line.new(bar_index, t1,    xR, t1,    xloc = xloc.bar_index, color = color.new(colBull, 0),    style = line.style_dashed, width = 1)
        lnT2 := line.new(bar_index, t2,    xR, t2,    xloc = xloc.bar_index, color = color.new(colBull, 25),   style = line.style_dotted, width = 1)
        lbE  := label.new(xR, entry, "Entry " + str.tostring(entry, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = C_BG, textcolor = C_TEXT,  size = size.small)
        lbS  := label.new(xR, stp,   "Stop "  + str.tostring(stp,   format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = C_BG, textcolor = colBear, size = size.small)
        lbT1 := label.new(xR, t1,    "TP1 "   + str.tostring(t1,    format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = C_BG, textcolor = colBull, size = size.small)
        lbT2 := label.new(xR, t2,    "TP2 "   + str.tostring(t2,    format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = C_BG, textcolor = colBull, size = size.small)
    if showSigLbl
        string sTxt = (candDir == 1 ? "▲ BOTTOM" : "▼ TOP") + " · " + str.tostring(convCal, "#") + "%"
        lbSig := label.new(bar_index, na, sTxt, xloc = xloc.bar_index, yloc = candDir == 1 ? yloc.belowbar : yloc.abovebar, style = candDir == 1 ? label.style_label_up : label.style_label_down, color = dirCol, textcolor = color.white, size = size.small)

// Linked absorption-shelf level(s) — drawn / refreshed on the last bar only
var line  shBe = na
var line  shAb = na
var label shBl = na
var label shAl = na
if barstate.islast and showShelf and locLinked
    line.delete(shBe)
    line.delete(shAb)
    label.delete(shBl)
    label.delete(shAl)
    int shX1 = math.max(0, bar_index - levLen)
    if not na(shBelowV)
        shBe := line.new(shX1, shBelowV, bar_index + 5, shBelowV, xloc = xloc.bar_index, color = color.new(colBull, 20), style = line.style_dotted, width = 2)
        shBl := label.new(bar_index + 5, shBelowV, "Shelf ▲ support", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(colBull, 20), textcolor = color.white, size = size.small)
    if not na(shAboveV)
        shAb := line.new(shX1, shAboveV, bar_index + 5, shAboveV, xloc = xloc.bar_index, color = color.new(colBear, 20), style = line.style_dotted, width = 2)
        shAl := label.new(bar_index + 5, shAboveV, "Shelf ▼ resistance", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(colBear, 20), textcolor = color.white, size = size.small)

// On-chart legend key
var table keyT = table.new(keyPos == "Bottom Right" ? position.bottom_right : keyPos == "Top Left" ? position.top_left : keyPos == "Middle Left" ? position.middle_left : position.bottom_left, 2, 5, frame_width = 1, frame_color = C_GRID, border_width = 1)
if showKey and barstate.islast
    table.cell(keyT, 0, 0, "KEY", text_color = color.white, bgcolor = C_HEADER, text_size = size.tiny)
    table.cell(keyT, 1, 0, "Reversal", text_color = color.white, bgcolor = C_HEADER, text_size = size.tiny)
    table.cell(keyT, 0, 1, "◆", text_color = colBull, bgcolor = C_BG, text_size = size.tiny)
    table.cell(keyT, 1, 1, "Confirmed (bright = high conviction)", text_color = C_MUTED, bgcolor = C_BG, text_size = size.tiny)
    table.cell(keyT, 0, 2, "▲▼", text_color = colBull, bgcolor = C_BG, text_size = size.tiny)
    table.cell(keyT, 1, 2, "Extreme stage (early)", text_color = C_MUTED, bgcolor = C_BG, text_size = size.tiny)
    table.cell(keyT, 0, 3, "▬", text_color = colBear, bgcolor = C_BG, text_size = size.tiny)
    table.cell(keyT, 1, 3, "Stop / TP levels", text_color = C_MUTED, bgcolor = C_BG, text_size = size.tiny)
    table.cell(keyT, 0, 4, "░", text_color = C_MUTED, bgcolor = C_BG, text_size = size.tiny)
    table.cell(keyT, 1, 4, "Grey wash = standing aside", text_color = C_MUTED, bgcolor = C_BG, text_size = size.tiny)
````
