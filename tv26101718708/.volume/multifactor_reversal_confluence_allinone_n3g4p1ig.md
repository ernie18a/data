# Multi-Factor Reversal Confluence  All-in-One

- url: https://www.tradingview.com/script/N3G4P1ig-Multi-Factor-Reversal-Confluence-All-in-One/
- type: indicator
- pine_id: PUB;1cc66dbdc0a343369ccdfd2e0bba89c2
- version: 3.0

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

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                                    MPL-2.0
// MULTI-FACTOR REVERSAL CONFLUENCE — ALL-IN-ONE (CALIBRATED)                                  v3.9
// ────────────────────────────────────────────────────────────────────────────────────────────
// CHANGELOG
//   v3.9 — LIBRARY CONSOLIDATION (cumulative over v3.8). Three pieces of inlined math are now sourced
//          from the shared suite libraries so this engine's definitions match the rest of the suite —
//          with NO numerical change (each replacement was verified formula-identical before swapping):
//     • Efficiency ratio → cal.efficiencyRatio (ml_calib). Identical to the old f_er (ta.change(s) ≡
//       s−s[1], same path sum); drives the exhaustion detector bit-for-bit as before.
//     • LTF signed order flow → flow.signedVolLTF (ml_flow). Identical buy/sell classification (c>o buy,
//       c<o sell) and nz handling; the inline sub-bar loop is removed.
//     • Weighted Wilson lower bound → cal.wilsonLo (ml_calib) at the two call sites. Same Wilson formula;
//       the library clamps a negative bound to 0 (correct for a proportion) and returns percent, so the
//       call sites ÷100. The PROVEN badge is bit-identical (a negative bound never beats the base rate).
//     • KEPT INLINE (no exact library equivalent, so left untouched to avoid any drift): the BVC normal-
//       CDF split and the time-of-day volume EMA baseline. Imports: ml_session/2 · ml_rs/1 · ml_flow/2 ·
//       ml_calib/2 (ml_flow/ml_calib add NO security calls). Behaviour, defaults and the Compact dashboard
//       are unchanged; this pass only shares definitions and removes the now-duplicated inline math.
//   v3.8 — FOCUSED ADDITIVE upgrade (three opt-in reads; every default reproduces v3.7 on NIFTY). The
//          engine now shares three published suite libraries — ml_session/2, ml_rs/1 — without touching
//          the five detectors, the two gates, the lifecycle or the honesty/calibration stack.
//     • INITIAL-BALANCE LOCATION (ml_session) — the opening auction's high/low (NIFTY 09:15 default) is a
//       first-class intraday liquidity level. A reversal that fires AT the IB edge on the correct side
//       (a bottom near IB-low = support, a top near IB-high = resistance) gets a bounded conviction boost,
//       exactly like the absorption-shelf location boost — then still calibrated. Optional IB lines; a
//       SESSION/IB readout in the Pro dashboard. No new security calls (ml_session is wall-clock local).
//     • TRIANGULAR BUY/SELL SPLIT (ledger L1) — the climax order-flow read can use a bar-geometry CDF
//       (where open & close sit in the bar's range) instead of BVC's standardized-return CDF. Opt-in;
//       BVC stays the default so the climax detector is byte-for-byte v3.7 unless you switch it.
//     • INTERMARKET via RELATIVE STRENGTH (ml_rs) — the benchmark confirmation can use the chart symbol's
//       Mansfield RS SLOPE vs the benchmark (is it turning the reversal's way in RELATIVE terms) instead
//       of the benchmark's raw momentum. Reuses the existing benchmark security call — no new call. Default
//       stays "Momentum diff" (unchanged). Both are still calibrated like every other conviction input.
//     • Compact dashboard unchanged and still the default; the new reads surface in Pro. STILL DEFERRED:
//       a full library rewire of the inlined BVC / Wilson / efficiency-ratio math (a larger, separate pass).
//   v3.7 — The options expected-move bar can now be POINTS (NIFTY default 15) or an ATR MULTIPLE that
//          auto-scales to any instrument's price — set via "Expected-move unit". With v3.6's Volume
//          source, the whole tool is now multi-asset from Settings while every DEFAULT stays NIFTY.
//   v3.6 — MULTI-ASSET volume. New "Volume source" (Data group): Chart (default — NIFTY1! / stocks /
//          crypto, unchanged) or External (futures), which borrows volume AND its sub-bar flow from a
//          chosen futures symbol so the climax / exhaustion / order-flow detectors still work on a
//          volume-LESS SPOT chart (a cash index / spot FX); chart price is never replaced. The options
//          layer stays NIFTY-shaped (session / expiry / expected-move in points — adjust per market).
//   v3.5 — PUBLICATION POLISH. (1) TWO-SYSTEM VISUAL LANGUAGE: REVERSAL now draws as diamonds (confirmed)
//          + circles (forming); CONTINUATION draws as triangles (ride) — shape = signal TYPE, colour =
//          DIRECTION, so the two engines never read alike. Legend regrouped to match. (2) PERFORMANCE:
//          the changepoint (BOCPD) step now reuses preallocated buffers (array.fill + copy) instead of
//          allocating three arrays per bar — with the earlier Wasserstein fix, the engine now holds ZERO
//          per-bar array allocation in steady state. No change to any detector's math or the honesty stack.
//   v3.4 — Ride entry timing gains "On the cross" — fire the ride the MOMENT the trigger's direction flips
//          (no pullback wait), alongside EMA re-cross and Early. And "trend present" is now CONSISTENT
//          across all three triggers (each uses only its own detector — DEMA order / Alligator fan /
//          100-DEMA cross); the Custom-DEMA-only mean-reversion gate and its "Trend-regime threshold"
//          input are removed, so the three are a fair A/B. Entry / grade / levels / honest hit% unchanged.
//   v3.3 — "100 DEMA" trigger is now a CROSS, not a full stack: direction = the chart 100-DEMA crossing
//          the NEAREST higher-TF 100-DEMA (1m above 2m = up), with "higher-TFs to cross" (mdConfirm,
//          default 1) requiring more higher rungs for stronger/fewer signals. Both the chart DEMA and the
//          nearest-higher-TF DEMA plot so the cross is visible. More responsive than the old stacked rule.
//   v3.2 — "Only show signals when options-favorable" now defaults ON, so the chart / alerts surface only
//          option-tradeable setups (cheap-ish & rising vol, move big enough, not late-day / expiry). The
//          calibration still measures every fire; turn it off to also see caution / avoid signals.
//   v3.1 — NAMING. The ride method selector is now "Ride trigger" with options Williams Alligator /
//          Custom DEMA / 100 DEMA (what GENERATES the ride). The old EMA-re-cross / Early setting is
//          renamed "Ride entry timing" (how soon you enter once triggered) — no behaviour change, just
//          clearer labels. Default trigger = Custom DEMA (the measured winner).
//   v3.0 — THIRD RIDE BASIS: MTF 100-DEMA. The chart 100-DEMA must be stacked in order against the
//          ladder's LOWER + HIGHER-TF 100-DEMAs (above all higher, below all lower in an uptrend; mirror
//          for down) with price on its side — the current-TF-DEMA-crosses-other-TF-DEMAs idea. Cleanest
//          but laggiest of the three; A/B it against DEMA stack (the measured winner so far) via Ride
//          hit%. Adds 7 top-level security calls (18 of 40 total). Default stays DEMA stack.
//   v2.9 — SELECTABLE RIDE TREND BASIS. New "Ride trend basis": DEMA stack (default, = v2.8) or Williams
//          Alligator (13/8/5). On the Alligator basis the ride takes its DIRECTION from the jaw-teeth-lips
//          order and only treats a trend as present when the lines FAN OUT (awake) — so rides are skipped
//          while the alligator sleeps (range). Logic uses the NON-displaced lines (non-repaint); the drawn
//          lines carry the classic forward offset. Entry / grade / levels / honest Ride hit% are shared, so
//          you can A/B the two bases per timeframe. (MTF 100-DEMA align is the next basis to add.)
//   v2.8 — PHASE 3 (entry precision). Drawn Entry / Stop / TP levels now appear on RIDE signals too (not
//          just reversals), so a ride is a complete, risk-defined trade on the chart. New "Ride trigger"
//          option: EMA re-cross (default) or Early (momentum turn) — Early enters 1–2 bars sooner off the
//          pullback for better option timing (more false starts; the Ride hit% · LB decides). The ride
//          signal label is folded into the shared trade-level block (one object set; regime-exclusive).
//   v2.7 — Trend MA DEFAULT → DEMA (lower lag for option-entry timing). PERFORMANCE FIX: the Wasserstein
//          instability block now reuses two PREALLOCATED arrays (fill-by-index) instead of allocating and
//          growing them every bar — resolves the intermittent "Loop takes too long to execute (>500 ms)"
//          runtime error. The instability value is identical; only the per-bar allocation is removed.
//   v2.6 — Ride MA selectable (EMA / DEMA) + the signal cooldown now also spaces RIDE entries. DEMA cuts
//          the pullback-resume lag for earlier option entries (whipsaw trade-off — the Ride hit% decides);
//          default stays EMA. Ride markers remain tiny triangles. No detector / calibration change.
//   v2.5 — OPTIONS CONTEXT, LIVE (phase 2). All data used is live on a NIFTY futures chart; India VIX is
//          NOT used (its TradingView feed is end-of-day) — volatility is read LIVE from the chart's OHLC.
//     • LIVE REALIZED VOL — a range-based Rogers-Satchell estimator (drift-independent), as a self-
//       calibrating percentile (0–100 vol regime) + slope (expanding / contracting). Premium cheap vs
//       expensive, and the vega tailwind / drag, with nothing delayed.
//     • EXPECTED MOVE vs COST — a 1σ expected move over the trade horizon (price × realized-vol × √bars),
//       compared to a minimum, so a signal is "favorable" only when the move can actually pay for premium.
//     • OPTIONS VERDICT + ⚡ flag on every signal (favorable / caution / avoid), a "Vol regime" and
//       "Options" dashboard row, theta caution late-day and on NIFTY weekly expiry (Tuesday), and an
//       optional hard filter to show only options-favorable signals. Calibration still measures all fires.
//     • Intermarket benchmark default → Bank Nifty FUTURES (NSE:BANKNIFTY1!) so an enabled cross-check
//       uses a live, same-class feed. Everything additive; off/neutral reproduces v2.4.
//   v2.4 — REGIME-ADAPTIVE (phase 1 of the intraday-options upgrade). The engine is no longer mute in a
//          trend: when the tape is TRENDING (the mean-reversion gate's opposite) it RIDES pullbacks WITH
//          the trend instead of standing aside; when the tape is REVERTING it fades, exactly as before.
//     • CONTINUATION (trend-ride) module — a with-trend entry fires when, in a trend regime, price has
//       pulled back ≥ (depth × ATR) from the recent extreme and then RESUMES (closes back through the
//       fast trend EMA) with LTF flow in the trend direction. New group "14 · Continuation (trend-ride)".
//     • Shown as tiny ▲/▼ triangles + a RIDE label + its own alert() (entry/stop/TP), forward-tested on
//       the SAME horizon/target as reversals — a separate, honest "Ride hit% · LB" read on the dashboard.
//     • New "Mode" row: RIDE (trend) / reversal (fade) / neutral, so the current stance is explicit.
//     • Default ON; turn "Ride the trend…" off for the pure reversal engine (≡ v2.3). Reversal detectors,
//       gates, lifecycle and calibration are unchanged. (Phases 2–3 next: India-VIX / options-aware
//       target, then a faster entry tier.)
//   v2.3 — PRESET COMPLETED (the responsiveness dial now spans the full cluster; Balanced = v2.0).
//     • The "Responsiveness preset" now also sets Drift lookback, the mean-reversion block floor and
//       the turbulence veto level — so Fast = more / earlier signals with looser gates, Precise =
//       fewer, cleaner signals with stricter gates, and Balanced is byte-for-byte the v2.0 values.
//       Custom leaves every manual input exactly as set. No detector math changed.
//   v2.2 — OUTPUT CORRECTIONS (from live paste-tests on NIFTY1! 2m/5m/15m).
//     • CHANGEPOINT no longer silently dormant — on strongly trending symbols the accel guard zeroed
//       the trigger's direction almost whenever it fired (Peak 2 ≈ 0). New OPT-IN toggle "Changepoint
//       also fires on a stalling trend" relaxes the guard so detector 2 contributes; DEFAULT OFF =
//       v2.1 behaviour exactly. (Turning it on changes the measured stats — re-validate before trusting.)
//     • LOCATION row no longer reads "no shelf <price>" when a shelf WAS found and drawn — it now reads
//       "shelf·far <price>", consistent with the drawn Shelf line.
//     • DASHBOARD STOP now shows a provisional stop for the live candidate when not yet CONFIRMED, so an
//       ARMED bottom no longer displays a stale stop left over from a prior opposite-side trade.
//   v2.1 — ACCURACY & RESPONSIVENESS PASS (the five detectors' math and the honesty stack are
//          unchanged; this pass removes a hidden coupling, adds display-side controls, and gives one
//          responsiveness dial — with Balanced = the exact v2.0 values, so nothing changes by default).
//     • DECOUPLED volatility scale — the climax BVC order-flow split and the turbulence shock test now
//       use their OWN return-vol window (`sigLen`) instead of silently borrowing the instability
//       window. Tuning "Instability window" no longer re-tunes climax / turbulence.
//     • Exhaustion relative-volume baseline now uses `volLkb` (was a hardcoded 20) — one consistent
//       "normal volume" across the whole engine.
//     • SIGNAL FILTER + COOLDOWN — optionally show/alert only B-or-better (or A-only) grades, and an
//       optional minimum-bars cooldown between visible signals. These gate ONLY the displayed / alerted
//       signal; the calibration still measures EVERY engine fire, so the honest stats are unchanged.
//     • RESPONSIVENESS PRESET (Fast / Balanced / Precise / Custom) — one dropdown sets the latency /
//       selectivity cluster (swing length, min agreeing signals, correlation window). Balanced = v2.0.
//     • Steadier conformal quantile (confLR 1.0 → 0.5); default MTF scope Chart + 2 (house standard).
//       Turbulence relabelled honestly as a Fano-based BURST PROXY (not an estimated Hawkes branching
//       ratio). Isotonic note: it refines the LIVE conviction; painted history shows the beta warm-start.
//   v2.0 — DAILY-TRADING LAYER (additive; the five detectors, two gates, lifecycle, fusion and the
//          calibration/honesty stack are byte-for-byte v1.0 in behaviour — this layer only adds
//          context, risk and management around the proven engine).
//     • MTF ALIGNMENT (Path-engine style, SELECTABLE scope + ROLE) — the reversal is graded against a
//       multi-TF trend stack: your CHART TF plus the N nearest-higher rungs of a 1/2/3/5/15/30/60
//       ladder, selectable (chart + 2 / 3 / 4 / 5 higher, or whole ladder). The HTF ROLE is also
//       selectable: REVERSAL (default) rewards turning AGAINST the HTF trend — catching the actual
//       top/bottom, so HTF is treated OPPOSITE to the LTF — while CONTINUATION rewards joining it
//       (pullback entries). On-thesis across the stack = A, mixed = B, off-thesis = C (optionally blocked).
//     • LTF FLOW CONFIRMATION — a LOWER-timeframe signed order-flow read (sub-bars) confirms the turn
//       (buyers stepping in at a bottom / sellers at a top), boosting conviction on agreement and
//       trimming it on conflict, with an optional hard gate. Conviction is boosted THEN still
//       calibrated, so a boost that doesn't help is mapped back out. The "catchable turn vs knife" core.
//     • SESSION FILTER — optionally restrict signals to a trading session (exchange time).
//     • BET-SIZING — turns the calibrated P(success) and alignment into an A/B/C grade and a suggested
//       risk size (Kelly-capped), shown at the signal and on the dashboard.
//     • RICH ALERT PAYLOAD — a single alert() carries direction, grade, conviction, MTF/LTF alignment,
//       entry, stop, TP1, TP2 and size, for journaling / automation (set the alert to any alert()).
//     • INTERMARKET CONFIRMATION (opt-in, default off) — a correlated benchmark (default Bank Nifty)
//       turning the same way as the reversal boosts conviction, diverging trims it; one security call,
//       no library dependency, then still calibrated. Shows as IM✓ / IM⚠.
//     • Momentum-divergence conviction boost; input groups tidied; trade-level labels decluttered
//       (tiny). Static Entry/Stop/TP levels kept; the live trade-manager was removed. Nothing changes
//       which reversals the engine detects.
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
// with no equilibrium — and a TURBULENCE gate (a Fano-based self-excitation BURST PROXY) that vetoes
// fading an active, intensifying cascade (the falling-knife defense). Both scale and can block a fire.
// Lifecycle: WATCH → ARMED (agreement within a window) → EXTREME (climax)
// → CONFIRMED (structure break; the default actionable tier). Fusion down-weights correlated signals
// (Kish); conviction is calibrated to resolved outcomes — beta warm-start → non-parametric ISOTONIC
// (PAV) — shrunk toward 50% until enough samples resolve, and the "proven" badge uses a
// uniqueness-weighted, out-of-sample, multiple-testing-deflated Wilson lower bound vs a matched base
// rate. Non-repainting. Needs volume (run on futures e.g. NSE:NIFTY1!, or set Volume source = External for a volume-less spot). Study only — NOT financial
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
import Market_Logic_India/ml_session/2 as sess
import Market_Logic_India/ml_rs/1      as rsx
import Market_Logic_India/ml_flow/2    as flow
import Market_Logic_India/ml_calib/2   as cal
indicator("Multi-Factor Reversal Confluence — All-in-One", "Reversal", overlay = true, max_bars_back = 600, max_lines_count = 60, max_labels_count = 60)

// ───────────────────────────── INPUTS ─────────────────────────────
gData = "0 · Data / asset class"
volSrc    = input.string("Chart", "Volume source", options = ["Chart", "External (futures)"], group = gData, tooltip = "Chart (default): use THIS chart's own volume — correct for NIFTY1! futures, stocks, crypto and anything with real volume. External (futures): borrow volume from the symbol below — use when charting a volume-LESS spot (a cash index, or spot FX) so the climax / exhaustion / order-flow detectors still work. Price always stays from your chart; only volume (and its sub-bar flow) is sourced externally.")
volExtSym = input.symbol("NSE:NIFTY1!", "External volume symbol", group = gData, tooltip = "The real-volume instrument to borrow volume from when Volume source = External — typically the FUTURES of the index / pair you are charting (e.g. NSE:NIFTY1! for the Nifty cash index).")
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
cpStall = input.bool(false, "Changepoint also fires on a stalling trend", group = gc2, tooltip = "By default the changepoint trigger stands aside whenever the move is accelerating, which on strongly trending instruments can leave it dormant (dashboard Peak 2 ≈ 0 — it never contributes). Turn ON to also fire when the trend merely STALLS (fast drift ≤ 1.5× the slow drift), so detector 2 pulls its weight. Still validated by the calibration; OFF = v2.1 behaviour exactly. Note: turning it on changes the measured hit-rates, so re-check the honest stats after.")

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
climSplit = input.string("BVC (standardized return)", "Climax buy/sell split", options = ["BVC (standardized return)", "Triangular (bar-geometry)"], group = gc4, tooltip = "How the climax order-flow delta splits each bar's volume into buy vs sell (only when 'BVC order-flow delta' above is on). BVC (default, unchanged): the normal CDF of the standardized return (Easley/López de Prado/O'Hara). Triangular (v3.8): a bar-geometry CDF from where open & close sit in the bar's range — no return-stdev, often a cleaner within-bar read on gappy / thin instruments. A/B via the honest hit-rates.")
useConf = input.bool(true, "Conformal 'extreme' rarity", group = gc4, tooltip = "Require the climax composite to exceed its own online (1−α) quantile, so 'extreme' means a calibrated ~α-rare event on THIS symbol rather than a fixed level — consistent across instruments and volatility regimes.")
confAlpha = input.float(0.10, "Extreme rarity α", minval = 0.02, maxval = 0.4, step = 0.01, group = gc4)
confLR  = input.float(0.5, "Conformal adaptation rate", minval = 0.05, step = 0.05, group = gc4, tooltip = "Learning rate of the adaptive-conformal quantile. Lower = steadier quantile, fewer regime whipsaws. v2.1 default 0.5 (was 1.0).")
sigLen  = input.int(100, "Return-vol window (flow & turbulence)", minval = 20, maxval = 300, group = gc4, tooltip = "Dedicated return-volatility scale for the BVC order-flow split AND the turbulence shock test (v2.1). Previously these silently borrowed the Instability window, so tuning instability re-tuned climax / turbulence; they are now independent.")

// P5
swLen    = input.int(8, "Swing length", minval = 2, group = gc5)
dispMin  = input.float(1.0, "Break displacement (× ATR)", minval = 0.1, step = 0.1, group = gc5)
swpWin   = input.int(15, "Sweep→break window", minval = 2, group = gc5)

// Fusion & lifecycle
preset   = input.string("Balanced", "Responsiveness preset", options = ["Fast", "Balanced", "Precise", "Custom"], group = gF, tooltip = "One dial for the responsiveness / selectivity cluster (swing · min-signals · corr · drift · mean-reversion floor · turbulence level). Fast = earlier, more signals with looser gates (6 / 2 / 120 / 12 / 0.15 / 0.65). Balanced (default) = the v2.0 values (8 / 2 / 200 / 20 / 0.20 / 0.60) — nothing changes unless you move it. Precise = fewer, cleaner signals with stricter gates (8 / 3 / 200 / 20 / 0.35 / 0.50). Custom = use every manual input exactly as set. Note: in a strong trend a looser/faster setting adds lower-quality fades — let the gate keep standing aside until the tape turns mean-reverting.")
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
divOn    = input.bool(true, "Momentum-divergence conviction boost", group = gF, tooltip = "An RSI/price divergence aligned with the candidate (price lower-low but momentum higher-low at a bottom, and the mirror at a top) multiplies conviction by the bonus below, then the result is still calibrated — so if the boost doesn't help, the calibration maps it back. Does not change which reversals fire.")
divBonus = input.float(1.10, "Divergence boost ×", minval = 1.0, maxval = 1.5, step = 0.05, group = gF)

// Calibration
calHz   = input.int(15, "Resolve after (bars)", minval = 2, maxval = 120, group = gK)
calMove = input.float(1.0, "Target move (× ATR)", minval = 0.1, step = 0.1, group = gK)
calMinN = input.int(10, "Min sample for a verdict", minval = 1, group = gK)
calLR   = input.float(0.02, "Beta-calibration rate", minval = 0.001, maxval = 0.5, step = 0.001, group = gK)
useIso  = input.bool(true, "Isotonic recalibration (non-parametric)", group = gK, tooltip = "Once the sample clears the minimum, map raw conviction through a monotone Pool-Adjacent-Violators fit of predicted→realized, so a shown 70% resolves ~70% on THIS symbol. Beta calibration is the warm-start until then. Note: the isotonic map refines the LIVE conviction readout; painted history shows the beta warm-start (the full-sample fit is not applied to past bars, to avoid lookahead).")
warmN   = input.int(30, "Warm-up shrink samples", minval = 1, group = gK, tooltip = "Conviction is pulled toward 50% until this many outcomes have resolved, so the engine can't show a confident probability it hasn't earned.")
oosFrac = input.float(0.60, "In-sample fraction (rest = OOS)", minval = 0.3, maxval = 0.9, step = 0.05, group = gK, tooltip = "The first fraction of resolved fires is in-sample; only the out-of-sample tail is trusted for the PROVEN badge.")
zProven = input.float(2.50, "Proven z (deflated for multiple tests)", minval = 1.64, maxval = 3.5, step = 0.1, group = gK, tooltip = "Wilson lower-bound z used for the PROVEN badge, raised above 1.96 (Bonferroni-style) because several signals × two sides are tested — so a lucky edge isn't starred.")
calCost = input.float(0.05, "Round-trip cost (R)", minval = 0.0, step = 0.01, group = gK, tooltip = "Cost per trade in R, subtracted from the 1:1 expectancy so Net-R reflects a tradeable edge, not a gross one.")

// Context, session, trade management & bet-sizing (v2.0 — the daily-trading layer)
gH = "8 · Multi-timeframe alignment, LTF & sizing"
alignOn    = input.bool(true, "Grade by multi-timeframe alignment", group = gH, tooltip = "Grades every reversal by how many timeframes it turns INTO — your CHART TF plus the N nearest-higher rungs of the ladder below (like the Path engine). All agreeing = A, mixed = B, fighting the stack = C.")
alignScope = input.string("Chart + 2 higher", "Alignment scope", options = ["Chart + 2 higher", "Chart + 3 higher", "Chart + 4 higher", "Chart + 5 higher", "All (whole ladder)"], group = gH, tooltip = "Which timeframes vote on the reversal's trend alignment: your chart timeframe plus the N nearest-higher rungs of the 1/2/3/5/15/30/60 ladder below. Fewer = more responsive / chart-relative; more = broader confirmation.")
alignMode  = input.string("Reversal (fade the HTF trend)", "HTF alignment role", options = ["Reversal (fade the HTF trend)", "Continuation (join the HTF trend)", "Off"], group = gH, tooltip = "What the higher-TF relationship MEANS for a reversal. Reversal (default): reward turns AGAINST the HTF trend — you're catching the actual top/bottom, so the HTF is treated OPPOSITE to the LTF (which confirms the NEW direction). Continuation: reward turns INTO the HTF trend — pullback / dip entries. Off: don't grade by HTF. Whichever you choose is still validated by the calibration.")
htfLen     = input.int(50, "Trend EMA (per timeframe)", minval = 5, maxval = 400, group = gH)
alignBlock = input.bool(false, "Block fires AGAINST the aligned trend", group = gH, tooltip = "When on, a C-grade reversal (against the multi-TF trend) is suppressed rather than just down-graded. Default off (grade only).")
ltfOn    = input.bool(true, "Lower-timeframe flow confirmation", group = gH, tooltip = "Confirm the turn with lower-timeframe signed order flow (sub-bars): at a bottom the LTF delta should be turning UP (buyers stepping in), at a top turning DOWN. Boosts conviction when it agrees, trims it on conflict; optional hard gate below.")
ltfRes   = input.timeframe("1", "LTF for flow confirmation", group = gH)
ltfGate  = input.bool(false, "Require LTF confirmation to fire", group = gH, tooltip = "Hard gate: only fire when the lower-timeframe flow agrees with the reversal direction. Default off (boost only).")
sessOn   = input.bool(false, "Restrict signals to a session", group = gH, tooltip = "Only fire inside the session window below (exchange time). Default off.")
sessStr  = input.session("0915-1530", "Session (exchange time)", group = gH)
sizeOn   = input.bool(true, "Bet-sizing (grade + suggested risk)", group = gH, tooltip = "Turns the calibrated P(success) into a suggested risk size (Kelly fraction for ~1:1 payoff, net of cost), capped below. Guidance only.")
sizeMax  = input.float(1.0, "Max risk units (cap)", minval = 0.1, maxval = 3.0, step = 0.1, group = gH)

// Alignment timeframe ladder — the chart TF + the nearest-higher rungs are selected by the scope above
gLad = "8b · Alignment timeframe ladder"
tfa1 = input.timeframe("1",  "TF 1", group = gLad)
tfa2 = input.timeframe("2",  "TF 2", group = gLad)
tfa3 = input.timeframe("3",  "TF 3", group = gLad)
tfa4 = input.timeframe("5",  "TF 4", group = gLad)
tfa5 = input.timeframe("15", "TF 5", group = gLad)
tfa6 = input.timeframe("30", "TF 6", group = gLad)
tfa7 = input.timeframe("60", "TF 7", group = gLad)

// Intermarket confirmation (v2.0) — a correlated benchmark's own turn confirms the reversal. One
// security call, NO library dependency. Default off.
gIM = "8c · Intermarket confirmation"
imOn  = input.bool(false, "Confirm against a correlated benchmark", group = gIM, tooltip = "When a correlated instrument (default Bank Nifty) is turning the SAME way as the reversal, boost conviction; when it diverges, trim. Then still calibrated. One security call, no dependency. Default off.")
imSym = input.symbol("NSE:BANKNIFTY1!", "Benchmark symbol", group = gIM, tooltip = "Correlated benchmark whose own turn confirms the reversal. Default Bank Nifty FUTURES (live, same feed class as your chart). Index spot also works but can lag on some feeds. Opt-in; off by default.")
imLkb = input.int(3, "Benchmark momentum lookback (bars)", minval = 1, maxval = 50, group = gIM)
imMethod = input.string("Momentum diff", "Benchmark confirm method", options = ["Momentum diff", "RS leadership (ml_rs)"], group = gIM, tooltip = "How the benchmark confirms a reversal. Momentum diff (default, unchanged): the benchmark's own price change over the lookback must point the reversal's way. RS leadership (ml_rs, v3.8): the chart symbol's Mansfield RS SLOPE vs the benchmark must be turning the reversal's way — a RELATIVE-strength read (is the chart starting to out/under-perform the index into the turn). Reuses the same benchmark data; no extra security call. Either way the boost is still calibrated.")
imRsLen  = input.int(50, "RS length (leadership method)", minval = 5, maxval = 300, group = gIM, tooltip = "Mansfield RS lookback used only when Benchmark confirm method = RS leadership.")

// Initial-Balance location (v3.8) — the opening auction's range is a first-class NIFTY intraday level
gIB = "8d · Initial-Balance location (v3.8)"
ibOn     = input.bool(true, "Boost reversals at the Initial-Balance edge", group = gIB, tooltip = "A reversal that fires AT the opening-auction range on the correct side — a bottom near the IB low (support), a top near the IB high (resistance) — gets a bounded conviction boost (then still calibrated), exactly like the absorption-shelf location boost. Uses ml_session; no extra security call.")
ibStartH = input.int(9,  "IB start hour (exchange time)", minval = 0, maxval = 23, group = gIB, tooltip = "Opening-window start hour in the symbol's exchange time. NIFTY = 9.")
ibStartM = input.int(15, "IB start minute", minval = 0, maxval = 59, group = gIB, tooltip = "Opening-window start minute. NIFTY = 15 (09:15 open).")
ibWinMin = input.int(60, "IB window (minutes)", minval = 5, maxval = 240, group = gIB, tooltip = "Length of the opening auction that defines the Initial Balance. NIFTY default 60 = 09:15–10:15.")
ibTol    = input.float(0.5, "Near-IB tolerance (× ATR)", minval = 0.05, maxval = 3.0, step = 0.05, group = gIB, tooltip = "How close to the IB edge counts as 'at' it, in ATR.")
ibBonus  = input.float(1.15, "Conviction × at the IB edge", minval = 1.0, maxval = 2.0, step = 0.05, group = gIB)
showIBln = input.bool(false, "Draw IB high/low lines", group = gIB)

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
turbOn   = input.bool(true, "Veto fades during a volatility cascade", group = gT, tooltip = "Large moves treated as a point process; the Fano factor (variance/mean of the shock count) gives a self-excitation BURST PROXY 0..1 — a heuristic, not an estimated Hawkes branching ratio. When it is high AND still rising the tape is self-feeding (a falling knife), so conviction is scaled down and fires can be blocked — the classic 'don't catch it' defense.")
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
sigShow    = input.string("All", "Show / alert signals", options = ["All", "B and better", "A only"], group = gV, tooltip = "Gate the DISPLAYED and alerted signal by grade. 'B and better' / 'A only' hide the weaker fires on the chart and in alerts. The calibration still measures EVERY engine fire, so the honest stats and base rates are unchanged — this only filters what you see / are alerted on.")
coolBars   = input.int(0, "Signal cooldown (bars, 0 = off)", minval = 0, maxval = 200, group = gV, tooltip = "Minimum bars between visible / alerted signals, to declutter clustered re-fires on one turn. Display / alert only — does not affect the measured calibration.")
gradeMk    = input.bool(true, "Grade marker brightness by conviction", group = gV, tooltip = "The Confirmed diamond fades when conviction is low / still learning and brightens as it rises, so strength reads at a glance.")
showGateCue= input.bool(true, "Tint faintly when standing aside (gated)", group = gV, tooltip = "A very faint grey wash when the engine is deliberately holding back (trend/random regime or an active cascade) and no candidate is live — so 'no signal' reads as working, not broken.")
showKey    = input.bool(true, "On-chart legend key", group = gV)
keyPos     = input.string("Bottom Left", "Legend position", options = ["Bottom Left", "Bottom Right", "Top Left", "Middle Left"], group = gV)
showShelf  = input.bool(true, "Draw linked absorption shelf", group = gV, tooltip = "When the location link is wired, draw the naked shelf level(s) the conviction boost comes from.")

// Continuation (trend-ride) — the regime-adaptive layer (v2.4). Active only when the tape is TRENDING.
gRide = "14 · Continuation (trend-ride)"
contOn       = input.bool(true, "Ride the trend when NOT mean-reverting", group = gRide, tooltip = "Regime-adaptive stance. In a REVERTING regime the engine fades (reversal signals, unchanged). In a TRENDING regime it instead RIDES pullbacks in the trend direction rather than standing aside — so you get a signal in the market you're actually trading. Both stances are forward-tested. Turn OFF for the pure reversal engine (≡ v2.3).")
contEmaF     = input.int(9,  "Fast trend EMA", minval = 3, maxval = 100, group = gRide)
contEmaS     = input.int(21, "Slow trend EMA", minval = 5, maxval = 200, group = gRide)
contMaType   = input.string("DEMA", "Trend MA type", options = ["EMA", "DEMA"], group = gRide, tooltip = "DEMA (default) = double EMA (2·EMA − EMA(EMA)), lower lag so the pullback-resume crossover triggers EARLIER — better option-entry timing — at the cost of a little more whipsaw in chop. EMA = the smoother, higher-lag alternative. The Ride hit% · LB tells you which wins on your symbol / timeframe.")
contPbAtr    = input.float(0.5, "Min pullback depth (× ATR)", minval = 0.1, maxval = 5.0, step = 0.1, group = gRide, tooltip = "A with-trend entry needs a real pullback first: price must have dipped at least this many ATR from the recent extreme before it resumes, so you buy the dip — not the extension.")
contFlowReq  = input.bool(true, "Require LTF flow with the trend", group = gRide, tooltip = "Only ride when the lower-timeframe signed order flow agrees with the trend (net buyers on a long, net sellers on a short).")
rideBasis    = input.string("Custom DEMA", "Ride trigger", options = ["Williams Alligator", "Custom DEMA", "100 DEMA"], group = gRide, tooltip = "What GENERATES the ride — its trend DIRECTION and whether a trend is present. Williams Alligator: the 13/8/5 jaw-teeth-lips, direction from their order, trend 'present' only when the lines FAN OUT (awake). Custom DEMA (default, the measured winner): the fast/slow trend MA order (your Fast/Slow + Trend MA type below) + the statistical mean-reversion gate. 100 DEMA: the chart 100-DEMA CROSSING the higher-TF 100-DEMAs — e.g. the 1m 100-DEMA crossing the 2m / 3m 100-DEMA (set how many higher TFs to cross below). Entry / grade / levels are shared; the Ride hit% tells you which wins.")
contTrig     = input.string("EMA re-cross", "Ride entry timing", options = ["EMA re-cross", "Early (momentum turn)", "On the cross"], group = gRide, tooltip = "Once the Ride trigger above sets a trend direction, WHEN you enter. EMA re-cross (default): wait for a pullback, then price closes back through the fast trend MA — best entry quality. Early (momentum turn): the first strong close off the dip — 1–2 bars sooner. On the cross: fire the ride the MOMENT the trigger crosses (no pullback wait) — earliest, most signals, but you enter at the extension (more theta risk for options). The Ride hit% · LB decides which wins.")
alliFan      = input.float(0.15, "Alligator · awake fan (× ATR)", minval = 0.0, maxval = 2.0, step = 0.05, group = gRide, tooltip = "Williams Alligator basis only: the jaw↔lips spread must exceed this many ATR for the lines to count as 'awake' (fanned out = a real trend). Below it the alligator is sleeping (range) and rides are skipped.")
mdLen        = input.int(100, "100 DEMA · length", minval = 20, maxval = 400, group = gRide, tooltip = "'100 DEMA' trigger only: the DEMA length computed on the chart and on each ladder timeframe. Direction comes from the chart 100-DEMA crossing the HIGHER-TF 100-DEMAs (e.g. 1m 100-DEMA above the 2m / 3m 100-DEMA = up).")
mdConfirm    = input.int(1, "100 DEMA · higher-TFs to cross", minval = 1, maxval = 7, group = gRide, tooltip = "'100 DEMA' trigger only: how many higher-TF 100-DEMAs the chart 100-DEMA must be above (up) / below (down), always including the nearest. 1 = just the nearest higher TF (1m crossing 2m) — most responsive. Higher = cross more TFs for confirmation → fewer, stronger signals.")

// Options context (live realized volatility) — v2.5. India VIX on TV is EOD/delayed, so the vol read is
// built LIVE from the chart's own OHLC (range-based Rogers-Satchell). Futures chart only (needs volume).
gOpt = "15 · Options context (live volatility)"
optOn        = input.bool(true, "Options context layer (live realized vol)", group = gOpt, tooltip = "Adds a LIVE volatility read from the chart's own OHLC (range-based Rogers-Satchell realized vol) — no India VIX (its TV feed is end-of-day). Gives the premium regime (cheap / expensive), the vega direction (expanding / contracting) and a 1σ expected move vs cost, summarised as an Options verdict and a ⚡ flag on each signal.")
volWin       = input.int(14, "Realized-vol window (bars)", minval = 5, maxval = 100, group = gOpt)
volPctLkb    = input.int(200, "Vol-regime percentile lookback", minval = 50, maxval = 1000, group = gOpt)
volSlopeLkb  = input.int(5, "Vol slope lookback (bars)", minval = 1, maxval = 50, group = gOpt)
volHighPct   = input.float(75.0, "Premium-expensive percentile ≥", minval = 50.0, maxval = 99.0, step = 5.0, group = gOpt, tooltip = "Vol at/above this percentile of its own history = premium expensive (vega risk for buyers).")
optMoveUnit  = input.string("Points (fixed)", "Expected-move unit", options = ["Points (fixed)", "ATR multiple"], group = gOpt, tooltip = "How the 'big enough move' bar is measured. Points (fixed) — NIFTY default: an absolute index-point threshold (set below). ATR multiple — set the bar as a fraction of ATR so it AUTO-SCALES to any instrument / price; use this for non-NIFTY assets.")
optMinMove   = input.float(15.0, "Min 1σ move — Points (fixed)", minval = 1.0, step = 1.0, group = gOpt, tooltip = "Used when Expected-move unit = Points (NIFTY default 15): the 1σ expected move over the trade horizon must beat this many index points for the verdict to read 'favorable'; below ~60% of it reads 'avoid' (too small to pay for premium).")
optMinMoveAtr= input.float(0.5, "Min 1σ move — ATR multiple", minval = 0.1, maxval = 5.0, step = 0.1, group = gOpt, tooltip = "Used when Expected-move unit = ATR multiple: the 1σ expected move must beat this × ATR — auto-scales to any instrument. 0.5 × ATR is a reasonable all-asset default.")
optGateShow  = input.bool(true, "Only show signals when options-favorable", group = gOpt, tooltip = "Hard filter: show / alert only signals whose options verdict is favorable (cheap-ish & rising vol, expected move big enough, not late-day / expiry). Default ON. The honest calibration still measures EVERY fire, so the stats are unchanged — turn OFF to also see caution / avoid signals.")
expiryCaution= input.bool(true, "Theta caution late-day & on expiry (Tue)", group = gOpt, tooltip = "Flag long-premium caution in the last minutes before close and on NIFTY weekly expiry day (Tuesday), where theta / gamma dominate.")
sessEnd      = input.int(1530, "Session close (HHMM)", minval = 0, maxval = 2359, group = gOpt)
lateDayMin   = input.int(45, "Late-day caution (mins to close ≤)", minval = 0, maxval = 240, group = gOpt)

// Style
theme    = input.string("Dark", "Theme", options = ["Dark", "Light"], group = gS)
colBull = input.color(#26a69a, "Bottom", inline = "c", group = gS)
colBear = input.color(#ef5350, "Top", inline = "c", group = gS)
showTint= input.bool(true, "Tint background by state", group = gS)
showMk  = input.bool(true, "Signal markers", group = gS)
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
// Triangular bar-geometry CDF → buy fraction in [0,1] (v3.8 optional climax split). Pure OHLC, no stdev.
f_triFrac(float o, float h, float l, float c) =>
    float rng = h - l
    float cdf = na
    if rng == 0
        cdf := c > o ? 0.0 : (c < o ? 1.0 : 0.5)
    else
        float op = math.max(math.min(o, h), l)
        float md = math.max(math.min(c, h), l)
        if md == l
            cdf := op <= l ? 0.0 : 1.0 - math.pow((h - op) / rng, 2)
        else if md == h
            cdf := op >= h ? 1.0 : math.pow((op - l) / rng, 2)
        else
            float lw = md - l
            float rw = h - md
            if op <= l
                cdf := 0.0
            else if op <= md
                cdf := math.pow(op - l, 2) / (rng * lw)
            else if op < h
                cdf := 1.0 - math.pow(h - op, 2) / (rng * rw)
            else
                cdf := 1.0
    1.0 - cdf
f_z(series float s, simple int len) =>
    m = ta.sma(s, len)
    sd = ta.stdev(s, len)
    sd <= 0.0 ? 0.0 : (s - m) / sd
// efficiency ratio is now cal.efficiencyRatio (v3.9) — identical formula, one shared suite definition
float atr = ta.atr(14)
float ret = (close > 0 and close[1] > 0) ? math.log(close / close[1]) : 0.0

// Responsiveness preset (v2.1) — one dial resolves the latency / selectivity cluster. "Custom" uses the
// manual Swing length / min agreeing signals / Correlation window inputs; "Balanced" = the v2.0 values.
int   swLenEff    = preset == "Fast" ? 6    : preset == "Precise" ? 8    : preset == "Balanced" ? 8    : swLen
int   minSigEff   = preset == "Fast" ? 2    : preset == "Precise" ? 3    : preset == "Balanced" ? 2    : minSig
int   corrLenEff  = preset == "Fast" ? 120  : preset == "Precise" ? 200  : preset == "Balanced" ? 200  : corrLen
int   driftLenEff = preset == "Fast" ? 12   : preset == "Precise" ? 20   : preset == "Balanced" ? 20   : driftLen
float mrFloorEff  = preset == "Fast" ? 0.15 : preset == "Precise" ? 0.35 : preset == "Balanced" ? 0.20 : mrFloor
float turbThrEff  = preset == "Fast" ? 0.65 : preset == "Precise" ? 0.50 : preset == "Balanced" ? 0.60 : turbThr

// Per-timeframe trend bias (v2.0) — one EMA-trend read per ladder rung, for the MTF alignment grade
f_htfBias(simple int len) =>
    float e = ta.ema(close, len)
    close > e and e > e[1] ? 1 : close < e and e < e[1] ? -1 : 0
f_tfDir(simple string tf) => request.security(syminfo.tickerid, tf, f_htfBias(htfLen), lookahead = barmerge.lookahead_off)
int d1 = f_tfDir(tfa1)
int d2 = f_tfDir(tfa2)
int d3 = f_tfDir(tfa3)
int d4 = f_tfDir(tfa4)
int d5 = f_tfDir(tfa5)
int d6 = f_tfDir(tfa6)
int d7 = f_tfDir(tfa7)
// nested inclusion — chart TF + the (keepN−1) nearest-higher rungs (≥ chart seconds, smallest keepN);
// falls back to the keepN highest if fewer than keepN qualify. Mirrors the Path engine.
f_sec(simple string tf) => math.max(timeframe.in_seconds(tf), 1)
f_nestInc(float si, float cs, float s1, float s2, float s3, float s4, float s5, float s6, float s7, int keepN, bool hiN) =>
    int above     = (s1 > si ? 1 : 0) + (s2 > si ? 1 : 0) + (s3 > si ? 1 : 0) + (s4 > si ? 1 : 0) + (s5 > si ? 1 : 0) + (s6 > si ? 1 : 0) + (s7 > si ? 1 : 0)
    int eligBelow = ((s1 >= cs and s1 < si) ? 1 : 0) + ((s2 >= cs and s2 < si) ? 1 : 0) + ((s3 >= cs and s3 < si) ? 1 : 0) + ((s4 >= cs and s4 < si) ? 1 : 0) + ((s5 >= cs and s5 < si) ? 1 : 0) + ((s6 >= cs and s6 < si) ? 1 : 0) + ((s7 >= cs and s7 < si) ? 1 : 0)
    hiN ? (above < keepN) : (si >= cs and eligBelow < keepN)
float sa1 = f_sec(tfa1)
float sa2 = f_sec(tfa2)
float sa3 = f_sec(tfa3)
float sa4 = f_sec(tfa4)
float sa5 = f_sec(tfa5)
float sa6 = f_sec(tfa6)
float sa7 = f_sec(tfa7)
float csecA = math.max(timeframe.in_seconds(timeframe.period), 1)
int   keepN = alignScope == "Chart + 2 higher" ? 3 : alignScope == "Chart + 3 higher" ? 4 : alignScope == "Chart + 4 higher" ? 5 : alignScope == "Chart + 5 higher" ? 6 : 7
int   nEligA = (sa1>=csecA?1:0)+(sa2>=csecA?1:0)+(sa3>=csecA?1:0)+(sa4>=csecA?1:0)+(sa5>=csecA?1:0)+(sa6>=csecA?1:0)+(sa7>=csecA?1:0)
bool  hiNA = nEligA < keepN
bool  ia1 = not alignOn ? false : alignScope == "All (whole ladder)" ? true : f_nestInc(sa1, csecA, sa1,sa2,sa3,sa4,sa5,sa6,sa7, keepN, hiNA)
bool  ia2 = not alignOn ? false : alignScope == "All (whole ladder)" ? true : f_nestInc(sa2, csecA, sa1,sa2,sa3,sa4,sa5,sa6,sa7, keepN, hiNA)
bool  ia3 = not alignOn ? false : alignScope == "All (whole ladder)" ? true : f_nestInc(sa3, csecA, sa1,sa2,sa3,sa4,sa5,sa6,sa7, keepN, hiNA)
bool  ia4 = not alignOn ? false : alignScope == "All (whole ladder)" ? true : f_nestInc(sa4, csecA, sa1,sa2,sa3,sa4,sa5,sa6,sa7, keepN, hiNA)
bool  ia5 = not alignOn ? false : alignScope == "All (whole ladder)" ? true : f_nestInc(sa5, csecA, sa1,sa2,sa3,sa4,sa5,sa6,sa7, keepN, hiNA)
bool  ia6 = not alignOn ? false : alignScope == "All (whole ladder)" ? true : f_nestInc(sa6, csecA, sa1,sa2,sa3,sa4,sa5,sa6,sa7, keepN, hiNA)
bool  ia7 = not alignOn ? false : alignScope == "All (whole ladder)" ? true : f_nestInc(sa7, csecA, sa1,sa2,sa3,sa4,sa5,sa6,sa7, keepN, hiNA)
int   nIncl = (ia1?1:0)+(ia2?1:0)+(ia3?1:0)+(ia4?1:0)+(ia5?1:0)+(ia6?1:0)+(ia7?1:0)

// MTF 100-DEMA basis (v3.0) — chart 100-DEMA stacked vs the ladder's lower + higher-TF 100-DEMAs. Used
// only when Ride trigger = "100 DEMA". Security calls are top-level (always on; 7 of the 40 budget).
f_dema(simple int len) =>
    float e1 = ta.ema(close, len)
    float e2 = ta.ema(e1, len)
    2.0 * e1 - e2
f_md(simple string tf) => request.security(syminfo.tickerid, tf, f_dema(mdLen), lookahead = barmerge.lookahead_off)
float mdChart = f_dema(mdLen)
float md1 = f_md(tfa1)
float md2 = f_md(tfa2)
float md3 = f_md(tfa3)
float md4 = f_md(tfa4)
float md5 = f_md(tfa5)
float md6 = f_md(tfa6)
float md7 = f_md(tfa7)
// CROSS semantics (v3.3): the chart (current-TF) 100-DEMA crossing the HIGHER-TF 100-DEMAs — e.g. the 1m
// 100-DEMA crossing the 2m / 3m / 5m … 100-DEMA. Direction = which side of the NEAREST higher-TF 100-DEMA
// the chart DEMA sits (the primary cross), and `mdConfirm` higher-TF DEMAs must be crossed in total.
int mdHiUp = (sa1>csecA and mdChart>md1?1:0)+(sa2>csecA and mdChart>md2?1:0)+(sa3>csecA and mdChart>md3?1:0)+(sa4>csecA and mdChart>md4?1:0)+(sa5>csecA and mdChart>md5?1:0)+(sa6>csecA and mdChart>md6?1:0)+(sa7>csecA and mdChart>md7?1:0)
int mdHiDn = (sa1>csecA and mdChart<md1?1:0)+(sa2>csecA and mdChart<md2?1:0)+(sa3>csecA and mdChart<md3?1:0)+(sa4>csecA and mdChart<md4?1:0)+(sa5>csecA and mdChart<md5?1:0)+(sa6>csecA and mdChart<md6?1:0)+(sa7>csecA and mdChart<md7?1:0)
// nearest higher-TF 100-DEMA = the smallest ladder rung above the chart TF
float _nhSec   = 1e20
float mdNearHi = na
if sa1 > csecA and sa1 < _nhSec
    _nhSec := sa1
    mdNearHi := md1
if sa2 > csecA and sa2 < _nhSec
    _nhSec := sa2
    mdNearHi := md2
if sa3 > csecA and sa3 < _nhSec
    _nhSec := sa3
    mdNearHi := md3
if sa4 > csecA and sa4 < _nhSec
    _nhSec := sa4
    mdNearHi := md4
if sa5 > csecA and sa5 < _nhSec
    _nhSec := sa5
    mdNearHi := md5
if sa6 > csecA and sa6 < _nhSec
    _nhSec := sa6
    mdNearHi := md6
if sa7 > csecA and sa7 < _nhSec
    _nhSec := sa7
    mdNearHi := md7
bool mdUp  = not na(mdNearHi) and mdChart > mdNearHi and mdHiUp >= mdConfirm
bool mdDn  = not na(mdNearHi) and mdChart < mdNearHi and mdHiDn >= mdConfirm
int  mdDir = mdUp ? 1 : mdDn ? -1 : 0

int  _sessT = time(timeframe.period, sessStr)                       // hoisted
bool inSess = not sessOn or not na(_sessT)

// Volume source resolution (v3.6) — Chart by default; External borrows volume from a futures symbol for
// volume-less spot charts. One top-level security call; chart price is never replaced.
bool   _extVol = volSrc == "External (futures)"
float  _vExt   = request.security(volExtSym, timeframe.period, volume, lookahead = barmerge.lookahead_off)
float  vSrc    = _extVol ? nz(_vExt) : volume
string _volTF  = _extVol ? volExtSym : syminfo.tickerid

// Lower-timeframe signed order-flow delta (sub-bars) — now flow.signedVolLTF (v3.9), identical buy/sell
// classification (c>o buy, c<o sell), one shared suite definition.
array<float> _lc = request.security_lower_tf(_volTF, ltfRes, close)
array<float> _lo = request.security_lower_tf(_volTF, ltfRes, open)
array<float> _lv = request.security_lower_tf(_volTF, ltfRes, volume)
[_lbuy, _lsell, _lnet] = flow.signedVolLTF(_lv, _lc, _lo)
float ltfDelta = (ltfOn and (_lbuy + _lsell) > 0.0) ? (_lbuy - _lsell) / (_lbuy + _lsell) : na

// Intermarket benchmark momentum (top-level security; sign vs the reversal confirms/diverges)
float _imClose = request.security(imSym, timeframe.period, close, lookahead = barmerge.lookahead_off)
float imMom = (imOn and not na(_imClose) and not na(_imClose[imLkb])) ? _imClose - _imClose[imLkb] : na

// Momentum divergence (v2.0) — RSI vs price, aligned with the candidate → a bounded conviction boost
float _rsiD = ta.rsi(close, 14)
bool  bullDivR = close < close[10] and _rsiD > _rsiD[10]            // price lower, momentum higher = bullish
bool  bearDivR = close > close[10] and _rsiD < _rsiD[10]            // price higher, momentum lower = bearish

// Intermarket RELATIVE-STRENGTH slope (v3.8, ml_rs) — chart symbol vs the benchmark. Reuses _imClose
// (no new security call). Used only when Benchmark confirm method = RS leadership.
float imRsSlope = (imOn and imMethod == "RS leadership (ml_rs)") ? rsx.rsSlope(close, _imClose, imLkb) : na
// Benchmark confirm signal — raw momentum (default) or the RS slope (v3.8); same sign convention.
float imSignal = imMethod == "RS leadership (ml_rs)" ? imRsSlope : imMom

// Initial-Balance location (v3.8, ml_session) — opening-auction range. sess calls are UNCONDITIONAL
// (they carry var state); ibOn gates only the conviction boost / display. IB uses CHART price (high/low).
bool _ibNewDay = sess.isNewDay()
bool _ibInWin  = sess.inOpeningWindow(ibStartH, ibStartM, ibWinMin)
[ibHigh, ibLow] = sess.initialBalance(_ibNewDay, _ibInWin, high, low)
int  ibBrk = sess.ibBreak(close, ibHigh, ibLow)

// ══════════════════════════════ 1 · INSTABILITY (PRIOR) ══════════════════════════════
// Wasserstein-1 (earth-mover) distributional-shift: sort the last ewsW returns and the ewsW before
// them, average the matched order-statistic gaps, volatility-normalize, and rank that distance as a
// percentile of its own history. Rising shift = the return distribution is changing shape (variance /
// skew / tail) = a reversal PRIOR. Sorting two ewsW windows on confirmed bars only is cheaper than
// the old 3× Kendall triple-loop AND captures tail/shape change the moment-trend missed.
float retSD = ta.stdev(ret, ewsW)                              // called unconditionally (v6-safe) — INSTABILITY's own scale
float sigRet = ta.stdev(ret, sigLen)                           // dedicated vol scale for BVC flow + turbulence shock (v2.1)
var array<float> retBuf = array.new_float(0)
var array<float> aRec = array.new_float(ewsW)                  // PERF (v2.7): preallocate ONCE and fill by index
var array<float> aPri = array.new_float(ewsW)                  // — allocating + growing these every bar tripped the
var float w1n = na                                             //   intermittent "Loop takes too long (>500ms)" guard
if barstate.isconfirmed
    array.push(retBuf, ret)
    if array.size(retBuf) > 2 * ewsW
        array.shift(retBuf)
    if array.size(retBuf) >= 2 * ewsW
        for i = 0 to ewsW - 1
            array.set(aPri, i, array.get(retBuf, i))          // the older window  (set, not push → no realloc)
            array.set(aRec, i, array.get(retBuf, i + ewsW))   // the recent window
        array.sort(aRec, order.ascending)
        array.sort(aPri, order.ascending)
        float w1 = 0.0
        for i = 0 to ewsW - 1
            w1 += math.abs(array.get(aRec, i) - array.get(aPri, i))
        w1n := (w1 / ewsW) / math.max(retSD, 1e-9)
float p1risk = nz(ta.percentrank(nz(w1n), 200))               // 0..100, self-calibrating rarity of the shift
float p1drift = ta.ema(ret, driftLenEff)
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
var array<float> newRL = array.new_float(Rmax + 1, 0.0)        // PERF: reusable scratch, preallocated once and
var array<float> newSs = array.new_float(Rmax + 1, 0.0)        // reset each bar (no per-bar array allocation →
var array<float> newNn = array.new_float(Rmax + 1, 0.0)        // zero GC pressure in steady state)
var bool inited = false
if not inited
    array.set(RL, 0, 1.0)
    inited := true
float pChange = 0.0
if bar_index > 1
    array.fill(newRL, 0.0)
    array.fill(newSs, 0.0)
    array.fill(newNn, 0.0)
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
    for r = 0 to Rmax                                          // copy scratch → persistent state (no realloc)
        array.set(RL, r, array.get(newRL, r))
        array.set(Ss, r, array.get(newSs, r))
        array.set(Nn, r, array.get(newNn, r))
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
bool  accel = (postDrift * priorDrift > 0.0) and (math.abs(postDrift) > (cpStall ? 1.5 : 1.0) * math.abs(priorDrift))
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
float erFast = cal.efficiencyRatio(close, erFastLen)
float erSlow = cal.efficiencyRatio(close, erSlowLen)
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
float volSma3 = ta.sma(nz(vSrc), volLkb)
bool  hasVol3 = ta.cum(nz(vSrc)) > 0
float rvol3   = hasVol3 ? nz(vSrc) / math.max(volSma3, 1e-9) : na
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
bool  hasVol = ta.cum(nz(vSrc)) > 0
float vol0 = nz(vSrc, 0.0)
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
float oiBVC = (climSplit == "Triangular (bar-geometry)") ? (2.0 * f_triFrac(open, high, low, close) - 1.0) : (2.0 * f_ncdf(ret / math.max(sigRet, 1e-9)) - 1.0)
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
float ph5 = ta.pivothigh(swLenEff, swLenEff)
float pl5 = ta.pivotlow(swLenEff, swLenEff)
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
float revScore = 0.5 * trustScore + 0.5 * regimeRev           // raw reversion 0..1 (independent of the gate on/off)
float mrGate = mrGateOn ? revScore * (dfOK ? 1.0 : 0.0) : 1.0

// TURBULENCE — self-excitation BURST PROXY (Fano factor of the shock count → a heuristic 0..1 score,
// NOT an estimated Hawkes branching ratio). When it is high AND still rising, the move self-feeds — scale the
// conviction down and, below a floor, block the fire. Cheap: one shock flag, one sma, one variance.
float shock  = math.abs(ret) > hawkK * math.max(sigRet, 1e-9) ? 1.0 : 0.0
float subCnt = math.sum(shock, hawkSub)
float fMean  = ta.sma(subCnt, hawkWin)
float fVar   = ta.variance(subCnt, hawkWin)
float fano   = fMean > 0.0 ? fVar / fMean : na
float branch = na(fano) ? 0.0 : math.max(0.0, math.min(1.0, 1.0 - 1.0 / math.sqrt(math.max(fano, 1.0))))
bool  cascade = branch >= turbThrEff and branch >= nz(branch[1], 0.0)        // active AND intensifying
float turbGate = (turbOn and cascade) ? math.max(0.0, 1.0 - turbStr * (branch - turbThrEff) / math.max(1.0 - turbThrEff, 1e-9)) : 1.0
float guardGate = mrGate * turbGate                                       // combined trend-defense + falling-knife veto

// ══════════════════════════════ CONTINUATION (TREND-RIDE) — v2.4 ══════════════════════════════
// Regime-adaptive layer: when the tape is TRENDING (not reverting) the fade engine stands aside, so here
// a pullback that RESUMES in the trend direction becomes a with-trend entry. Detector-independent; gated
// to the trend regime and vetoed in a cascade. Forward-tested on the same horizon/target as reversals.
// trend MAs — EMA, or DEMA (lower lag) when selected. Both ta.ema calls run every bar (v6-safe); the
// DEMA (2·EMA − EMA(EMA)) and the EMA↔DEMA choice are plain float selects, never ta.* inside a ternary.
float _emaF   = ta.ema(close, contEmaF)
float _emaS   = ta.ema(close, contEmaS)
float _demaF  = 2.0 * _emaF - ta.ema(_emaF, contEmaF)
float _demaS  = 2.0 * _emaS - ta.ema(_emaS, contEmaS)
bool  _useDema = contMaType == "DEMA"
float cEmaF = _useDema ? _demaF : _emaF
float cEmaS = _useDema ? _demaS : _emaS
// Williams Alligator (13/8/5 SMMA of the median) — logic uses NON-displaced values (non-repaint); the
// plotted lines below carry the classic forward offset. Direction from the jaw-teeth-lips order; a trend
// is 'present' only when the lines fan out (awake), so the ride skips the sleeping (range) alligator.
float aJaw   = ta.rma(hl2, 13)
float aTeeth = ta.rma(hl2, 8)
float aLips  = ta.rma(hl2, 5)
bool  aAwake = math.abs(aLips - aJaw) >= alliFan * atr
bool  aUp    = aLips > aTeeth and aTeeth > aJaw and aLips >= aLips[1]
bool  aDn    = aLips < aTeeth and aTeeth < aJaw and aLips <= aLips[1]
int   aDir   = (aUp and aAwake) ? 1 : (aDn and aAwake) ? -1 : 0
// ride trend basis — DEMA stack (default) or Williams Alligator
bool  _alliBasis = rideBasis == "Williams Alligator"
bool  _mtfBasis  = rideBasis == "100 DEMA"
int   _trDirDema = (cEmaF > cEmaS and cEmaS >= cEmaS[1]) ? 1 : (cEmaF < cEmaS and cEmaS <= cEmaS[1]) ? -1 : 0
int   trDir = _alliBasis ? aDir : _mtfBasis ? mdDir : _trDirDema
// trend present = the selected trigger has a direction (consistent across all three bases, v3.4)
bool  trendRegime = contOn and trDir != 0
float cHi10 = ta.highest(high, 10)
float cLo10 = ta.lowest(low, 10)
// resume trigger — EMA re-cross (confirmed) or Early momentum turn (1–2 bars sooner). Both ta.crossover
// calls run every bar (v6-safe); the EMA↔Early choice is a plain bool select, never ta.* in a ternary.
bool  _xUp = ta.crossover(close, cEmaF)
bool  _xDn = ta.crossunder(close, cEmaF)
bool  _eUp = close > high[1] and close > open
bool  _eDn = close < low[1] and close < open
bool  _earlyTrig = contTrig == "Early (momentum turn)"
bool  _onCross   = contTrig == "On the cross"
// "On the cross" = fire on the bar the trigger's direction flips (no pullback). Else pullback-resume.
bool  _xcUp = trDir == 1 and nz(trDir[1]) != 1
bool  _xcDn = trDir == -1 and nz(trDir[1]) != -1
bool  cResumeUp = _onCross ? _xcUp : _earlyTrig ? _eUp : _xUp
bool  cResumeDn = _onCross ? _xcDn : _earlyTrig ? _eDn : _xDn
bool  cDipUp = (cHi10 - low) >= contPbAtr * atr
bool  cDipDn = (high - cLo10) >= contPbAtr * atr
bool  _dipOkUp = _onCross or cDipUp                                 // the cross entry needs no prior pullback
bool  _dipOkDn = _onCross or cDipDn
bool  cFlowUp = not contFlowReq or (not na(ltfDelta) and ltfDelta > 0.0)
bool  cFlowDn = not contFlowReq or (not na(ltfDelta) and ltfDelta < 0.0)
int   contDir = (trendRegime and trDir == 1 and _dipOkUp and cResumeUp and cFlowUp) ? 1 : (trendRegime and trDir == -1 and _dipOkDn and cResumeDn and cFlowDn) ? -1 : 0
// conviction: trend quality (slow efficiency ratio) + MTF agreement WITH the trend (join) + LTF flow
float cTrendQual = math.min(nz(erSlow) / 0.6, 1.0)
int   cJoin = contDir == 0 ? 0 : ((ia1 and d1 == contDir ? 1 : 0) + (ia2 and d2 == contDir ? 1 : 0) + (ia3 and d3 == contDir ? 1 : 0) + (ia4 and d4 == contDir ? 1 : 0) + (ia5 and d5 == contDir ? 1 : 0) + (ia6 and d6 == contDir ? 1 : 0) + (ia7 and d7 == contDir ? 1 : 0))
float cFlowMag = not na(ltfDelta) ? math.min(math.abs(ltfDelta), 1.0) : 0.0
float contConv = contDir == 0 ? 0.0 : math.min(40.0 + 30.0 * cTrendQual + 20.0 * (nIncl > 0 ? cJoin / float(nIncl) : 0.0) + 10.0 * cFlowMag, 100.0)
bool  contFire = contDir != 0 and (not turbOn or turbGate >= turbFloor)
string contGrade = contDir == 0 ? "—" : contConv >= 65.0 ? "A" : contConv >= 50.0 ? "B" : "C"
int   cSide = contFire ? contDir : 0
var int nRideBull = 0
var int hitRideBull = 0
var int nRideBear = 0
var int hitRideBear = 0

// ══════════════════════════════ OPTIONS CONTEXT — LIVE REALIZED VOL (v2.5) ══════════════════════════
// India VIX on TradingView is EOD/delayed, so the volatility read is built LIVE from the chart's OWN OHLC:
// a range-based Rogers-Satchell realized vol (drift-independent), as a self-calibrating percentile + slope.
// It gives the premium regime (cheap vs expensive), the vega direction (expanding vs contracting) and a 1σ
// expected move over the trade horizon to weigh against option cost. No external / delayed feed is used.
float _rsBar    = (high > 0.0 and low > 0.0 and open > 0.0 and close > 0.0) ? (math.log(high / close) * math.log(high / open) + math.log(low / close) * math.log(low / open)) : 0.0
float rvVar     = math.sum(_rsBar, volWin) / math.max(volWin, 1)
float rVol      = math.sqrt(math.max(rvVar, 0.0))                    // per-bar realized vol (log), LIVE
float rVolPct   = nz(ta.percentrank(rVol, volPctLkb))               // 0..100 vol regime (self-calibrating)
float rVolSlope = rVol - nz(rVol[volSlopeLkb], rVol)
bool  volRising = rVolSlope > 0.0
bool  volHigh   = rVolPct >= volHighPct
float expMovePts = close * rVol * math.sqrt(math.max(calHz, 1))      // ≈ 1σ move over the resolve horizon (pts)
int   _endMin   = int(sessEnd / 100) * 60 + sessEnd % 100
int   _nowMin   = hour * 60 + minute
int   minsToClose = _endMin - _nowMin
bool  lateDay   = minsToClose <= lateDayMin and minsToClose >= 0
bool  isExpiry  = dayofweek == dayofweek.tuesday                     // NIFTY weekly expiry = Tuesday (2026)
bool  thetaCaution = expiryCaution and (lateDay or isExpiry)
float optMinMoveEff = optMoveUnit == "ATR multiple" ? optMinMoveAtr * atr : optMinMove   // NIFTY points, or ATR-scaled for any asset
int   optScore  = (not volHigh ? 1 : 0) + (volRising ? 1 : 0) + (expMovePts >= optMinMoveEff ? 1 : 0) + (not thetaCaution ? 1 : 0)
string optState = not optOn ? "off" : (expMovePts < optMinMoveEff * 0.6) ? "avoid" : (optScore >= 3 and expMovePts >= optMinMoveEff) ? "favorable" : "caution"
bool  optFav    = optState == "favorable"
bool  optPass   = not optGateShow or not optOn or optFav
string optTag   = not optOn ? "" : optFav ? " ⚡" : optState == "avoid" ? " ⚡✕" : " ⚡?"
color optCol    = not optOn ? C_MUTED : optFav ? colBull : optState == "avoid" ? colBear : C_MUTED

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
int confDir = nUp >= minSigEff and nUp >= nDn ? 1 : nDn >= minSigEff and nDn > nUp ? -1 : 0

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
float p12corr = ta.correlation(sig1, sig2, corrLenEff)
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
bool  divAlign   = divOn and ((candDir == 1 and bullDivR) or (candDir == -1 and bearDivR))
float divMult    = divAlign ? divBonus : 1.0
// ── MTF & LTF ALIGNMENT (v2.0) — chart TF + nearest-higher rungs vote on trend; LTF flow confirms ──
int   _mAgree   = candDir == 0 ? 0 : ((ia1 and d1 == candDir ? 1 : 0) + (ia2 and d2 == candDir ? 1 : 0) + (ia3 and d3 == candDir ? 1 : 0) + (ia4 and d4 == candDir ? 1 : 0) + (ia5 and d5 == candDir ? 1 : 0) + (ia6 and d6 == candDir ? 1 : 0) + (ia7 and d7 == candDir ? 1 : 0))
int   _mAgainst = candDir == 0 ? 0 : ((ia1 and d1 == -candDir ? 1 : 0) + (ia2 and d2 == -candDir ? 1 : 0) + (ia3 and d3 == -candDir ? 1 : 0) + (ia4 and d4 == -candDir ? 1 : 0) + (ia5 and d5 == -candDir ? 1 : 0) + (ia6 and d6 == -candDir ? 1 : 0) + (ia7 and d7 == -candDir ? 1 : 0))
int   _nTF      = nIncl
float mtfScore  = (_nTF > 0 and candDir != 0) ? (_mAgree - _mAgainst) / float(_nTF) : 0.0   // -1..1 (+1 = fully WITH the HTF trend)
// Role: Reversal rewards turning AGAINST the HTF (−mtfScore); Continuation rewards joining it (+mtfScore).
bool  _contMode = alignMode == "Continuation (join the HTF trend)"
float _alignRaw = (not alignOn or alignMode == "Off") ? 0.0 : _contMode ? mtfScore : -mtfScore   // +1 = on-thesis
int   hAlign    = _alignRaw > 0.15 ? 1 : _alignRaw < -0.15 ? -1 : 0
bool  againstHTF = alignOn and alignMode != "Off" and hAlign == -1
float mtfMult   = 1.0 + 0.15 * _alignRaw                                                     // 0.85 .. 1.15
bool  ltfConfirm  = ltfOn and not na(ltfDelta) and ((candDir == 1 and ltfDelta > 0.05) or (candDir == -1 and ltfDelta < -0.05))
bool  ltfConflict = ltfOn and not na(ltfDelta) and ((candDir == 1 and ltfDelta < -0.05) or (candDir == -1 and ltfDelta > 0.05))
float ltfMult   = ltfConfirm ? 1.10 : ltfConflict ? 0.92 : 1.0
bool  imConfirm  = imOn and candDir != 0 and not na(imSignal) and ((candDir == 1 and imSignal > 0.0) or (candDir == -1 and imSignal < 0.0))
bool  imConflict = imOn and candDir != 0 and not na(imSignal) and ((candDir == 1 and imSignal < 0.0) or (candDir == -1 and imSignal > 0.0))
float imMult    = imConfirm ? 1.08 : imConflict ? 0.94 : 1.0
// Initial-Balance location boost (v3.8) — a bottom near the IB low (support) or a top near the IB high
// (resistance) is a confirmed liquidity location; bounded ×, then still calibrated.
float _ibLvl   = candDir == 1 ? ibLow : candDir == -1 ? ibHigh : na
bool  ibNear   = ibOn and candDir != 0 and not na(_ibLvl) and math.abs(close - _ibLvl) <= ibTol * atr
float ibMult   = ibNear ? ibBonus : 1.0
convRaw := math.min(convRaw * locMult * divMult * mtfMult * ltfMult * imMult * ibMult, 100.0) * guardGate  // location + divergence + MTF/LTF + intermarket + IB, then trend-defense × turbulence

// actionable fire (blocked when a gate is below its floor, outside the session, against the MTF trend when set, or LTF-unconfirmed when gated)
bool actFire = switch actTier
    "Armed"   => state == 2 and state[1] < 2
    "Extreme" => state == 3 and state[1] != 3
    => state == 4 and state[1] != 4
actFire := actFire and (not mrGateOn or mrGate >= mrFloorEff) and (not turbOn or turbGate >= turbFloor) and inSess and not (alignBlock and againstHTF) and (not ltfGate or ltfConfirm)
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
// weighted Wilson LOWER bound is now cal.wilsonLo at the call sites (v3.9) — identical formula, one shared
// suite definition. The library returns a percent and clamps a negative bound to 0 (correct for a
// proportion); call sites ÷100 to keep the 0..1 scale. The PROVEN comparison is bit-identical.
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
    // continuation (ride) outcome — same horizon/target, direction-split; honest Wilson LB vs same base
    int cThen = cSide[calHz]
    if cThen != 0 and not na(atrE)
        float cTgt = calMove * atrE
        float cMoved = close - entry
        bool  cHit = cThen == 1 ? (cMoved >= cTgt) : (cMoved <= -cTgt)
        if cThen == 1
            nRideBull += 1
            hitRideBull += cHit ? 1 : 0
        else
            nRideBear += 1
            hitRideBear += cHit ? 1 : 0
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
    oosLB  := cal.wilsonLo(owh, ow, zProven) / 100.0
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

// ══════════════════════════════ GRADE · BET-SIZE (v2.0) ══════════════════════════════
// Grade A/B/C from calibrated conviction + MTF alignment + proven; a Kelly-capped suggested risk size.
float _gScore = nz(convCal, 50.0) / 100.0
_gScore := hAlign == 1 ? math.min(1.0, _gScore + 0.10) : hAlign == -1 ? math.max(0.0, _gScore - 0.15) : _gScore
_gScore := proven ? math.min(1.0, _gScore + 0.05) : _gScore
bool   _gradeable = candDir != 0 and state >= 2   // only grade a real lifecycle candidate (ARMED+), not a bare WATCH
string grade = not _gradeable ? "—" : _gScore >= 0.70 ? "A" : _gScore >= 0.55 ? "B" : "C"
float _pWin = math.min(math.max(nz(convCal, 50.0) / 100.0, 0.0), 1.0)
float _kelly = math.max(0.0, 2.0 * _pWin - 1.0 - calCost)           // ~1:1 payoff Kelly fraction, floored
float sizeR = sizeOn ? math.min(sizeMax, _kelly) : na               // suggested risk units (guidance)
int    _mThesis = _contMode ? _mAgree : _mAgainst                                            // TFs supporting the chosen role
string _mWord   = (not alignOn or alignMode == "Off") ? "off" : _contMode ? "join" : "fade"
string hAlignTxt = (candDir == 0 ? "—" : "MTF " + str.tostring(_mThesis) + "/" + str.tostring(_nTF) + " " + _mWord + (hAlign == 1 ? "✓" : hAlign == -1 ? "⚠" : "")) + (ltfConfirm ? " · LTF✓" : ltfConflict ? " · LTF⚠" : "") + (imOn ? (imConfirm ? " · IM✓" : imConflict ? " · IM⚠" : " · IM·") : "")

// Displayed / alerted signal = the engine fire, FILTERED by grade and a cooldown (v2.1). The CALIBRATION
// still reads actFire (every fire) below, so the honest stats never change — only what you see / are
// alerted on is gated. With Show = All and cooldown 0, actSignal == actFire (v2.0 behaviour exactly).
bool _gradePass = sigShow == "All" or (sigShow == "A only" and grade == "A") or (sigShow == "B and better" and (grade == "A" or grade == "B"))
var int _lastSigBar = na
bool _coolOK = coolBars <= 0 or na(_lastSigBar) or (bar_index - _lastSigBar) >= coolBars
bool actSignal = actFire and _gradePass and _coolOK and optPass
if actSignal and barstate.isconfirmed
    _lastSigBar := bar_index

// Rich alert payload (fires on any alert() — set the alert to "Any alert() function call")
if actSignal and barstate.isconfirmed
    float _stp = not na(stopLvl) ? stopLvl : close - candDir * calMove * atr
    float _rk  = math.max(math.abs(close - _stp), atr * 0.1)
    string _msg = (candDir == 1 ? "BOTTOM" : "TOP") + " | grade " + grade + " | conv " + str.tostring(convCal, "#") + "% | " + hAlignTxt + " | entry " + str.tostring(close, format.mintick) + " | stop " + str.tostring(_stp, format.mintick) + " | TP1 " + str.tostring(close + candDir * rr1 * _rk, format.mintick) + " | TP2 " + str.tostring(close + candDir * rr2 * _rk, format.mintick) + (na(sizeR) ? "" : " | size " + str.tostring(sizeR, "0.0") + "x") + (optOn ? " | opt " + optState + " (move " + str.tostring(expMovePts, "#") + "p)" : "")
    alert(_msg, alert.freq_once_per_bar_close)

// Continuation (ride) signal — displayed / alerted; measured above. Regime-exclusive with a reversal
// fire, but if both coincide the reversal takes precedence on the chart.
var int _lastRideBar = na
bool _coolOKr = coolBars <= 0 or na(_lastRideBar) or (bar_index - _lastRideBar) >= coolBars
bool rideSignal = contFire and not actSignal and optPass and _coolOKr
if rideSignal and barstate.isconfirmed
    _lastRideBar := bar_index
if rideSignal and barstate.isconfirmed
    float _rstp = contDir == 1 ? math.min(cLo10, close - calMove * atr) : math.max(cHi10, close + calMove * atr)
    float _rrk  = math.max(math.abs(close - _rstp), atr * 0.1)
    string _rmsg = "RIDE " + (contDir == 1 ? "LONG" : "SHORT") + " | grade " + contGrade + " | conv " + str.tostring(contConv, "#") + "% | trend EMA " + str.tostring(contEmaF) + "/" + str.tostring(contEmaS) + " | entry " + str.tostring(close, format.mintick) + " | stop " + str.tostring(_rstp, format.mintick) + " | TP1 " + str.tostring(close + contDir * rr1 * _rrk, format.mintick) + " | TP2 " + str.tostring(close + contDir * rr2 * _rrk, format.mintick) + (optOn ? " | opt " + optState + " (move " + str.tostring(expMovePts, "#") + "p)" : "")
    alert(_rmsg, alert.freq_once_per_bar_close)

// ══════════════════════════════ OUTPUT (bare) ══════════════════════════════
string stateTxt = state == 4 ? "CONFIRMED" : state == 3 ? "EXTREME" : state == 2 ? "ARMED" : state == 1 ? "WATCH" : "—"
string dirTxt = candDir == 1 ? "BOTTOM ▲" : candDir == -1 ? "TOP ▼" : "—"
// dashboard stop: the live trade stop when CONFIRMED, else a provisional stop for the current candidate
// (so an ARMED candidate never shows a stale stop left over from a prior opposite-side trade)
float dashStop = (state == 4 and not na(stopLvl)) ? stopLvl : (candDir != 0 ? close - candDir * calMove * atr : stopLvl)
// engine mode (v2.4): which stance the regime puts the engine in right now
string modeTxt = not contOn ? "reversal only" : trendRegime ? "RIDE (trend)" : revScore >= 0.5 ? "reversal (fade)" : "neutral"
color  modeCol = trendRegime ? (contDir == 1 ? colBull : contDir == -1 ? colBear : C_TEXT) : revScore >= 0.5 ? C_TEXT : C_MUTED
color  dirCol = candDir == 1 ? colBull : candDir == -1 ? colBear : color.gray

// conviction-graded marker colour — brighter = higher calibrated conviction (dim while learning)
int   mkT = gradeMk ? math.max(0, math.min(75, int(math.round(75.0 - 0.75 * nz(convCal, 40.0))))) : 0
color mkBull = color.new(colBull, mkT)
color mkBear = color.new(colBear, mkT)
// gate the EXTREME triangles with the same floor as the fire, so they don't show while standing aside
bool gateOK = (not mrGateOn or mrGate >= mrFloorEff) and (not turbOn or turbGate >= turbFloor)
// ── TWO-SYSTEM VISUAL LANGUAGE ──  REVERSAL = diamonds (confirmed) + circles (forming);  CONTINUATION =
// triangles (ride).  Shape = signal TYPE, colour = DIRECTION — so the two engines never read alike.
plotshape(showMk and gateOK and state == 3 and state[1] != 3 and candDir == 1,  "Reversal forming (bottom)", shape.circle,  location.belowbar, color.new(colBull, 35), size = size.tiny)
plotshape(showMk and gateOK and state == 3 and state[1] != 3 and candDir == -1, "Reversal forming (top)",    shape.circle,  location.abovebar, color.new(colBear, 35), size = size.tiny)
plotshape(showMk and actSignal and candDir == 1,  "Reversal confirmed (bottom)", shape.diamond, location.belowbar, mkBull, size = size.small)
plotshape(showMk and actSignal and candDir == -1, "Reversal confirmed (top)",    shape.diamond, location.abovebar, mkBear, size = size.small)
// continuation (ride) markers — tiny solid triangles (distinct from the faint small extreme triangles,
// which are gated off in a trend regime anyway, and from the reversal diamonds)
plotshape(showMk and rideSignal and contDir == 1, "Ride long", shape.triangleup, location.belowbar, color.new(colBull, 0), size = size.tiny)
plotshape(showMk and rideSignal and contDir == -1, "Ride short", shape.triangledown, location.abovebar, color.new(colBear, 0), size = size.tiny)
// stop cross is shown only when the full trade-levels overlay is OFF (else the labelled Stop line covers it)
plot(showLevels ? na : (state >= 3 and not na(stopLvl) ? stopLvl : na), "Stop", color = color.new(color.gray, 0), style = plot.style_cross, linewidth = 2)
// Williams Alligator lines (shown only on that basis) — classic forward offset for the familiar look
plot(_alliBasis ? aJaw   : na, "Alligator jaw",   color = color.new(#2962ff, 0), offset = 8, linewidth = 1)
plot(_alliBasis ? aTeeth : na, "Alligator teeth", color = color.new(#ef5350, 0), offset = 5, linewidth = 1)
plot(_alliBasis ? aLips  : na, "Alligator lips",  color = color.new(#26a69a, 0), offset = 3, linewidth = 1)
// 100-DEMA cross — chart 100-DEMA (orange) vs the nearest higher-TF 100-DEMA (blue); shown on that trigger
plot(_mtfBasis ? mdChart  : na, "100-DEMA · chart TF",        color = color.new(#ff9800, 0), linewidth = 2)
plot(_mtfBasis ? mdNearHi : na, "100-DEMA · nearest higher TF", color = color.new(#2962ff, 0), linewidth = 2)
// Initial-Balance high/low (v3.8, optional) — the opening-auction range as stepped lines
plot(showIBln and ibOn and not na(ibHigh) ? ibHigh : na, "IB high", color = color.new(colBear, 0), style = plot.style_stepline, linewidth = 1)
plot(showIBln and ibOn and not na(ibLow)  ? ibLow  : na, "IB low",  color = color.new(colBull, 0), style = plot.style_stepline, linewidth = 1)
// background: lifecycle wash (state≥2) OR a faint stand-aside tint when gated with no live candidate
bool  gatedOff = (mrGateOn or turbOn) and state < 2 and (guardGate < mrFloorEff or cascade)
color washCol = (showTint and state >= 2) ? color.new(candDir == 1 ? colBull : colBear, state == 4 ? 82 : state == 3 ? 88 : 93) : (showGateCue and gatedOff and not trendRegime) ? color.new(color.gray, 94) : na
bgcolor(washCol)

alertcondition(actSignal and candDir == 1, "Reversal — bottom", "Reversal confluence: potential bottom")
alertcondition(actSignal and candDir == -1, "Reversal — top", "Reversal confluence: potential top")

// percent helper — float division (an integer h / n would floor every rate to 0%). The Wilson LOWER
// bound used for the PROVEN badge is cal.wilsonLo (ml_calib) at the call sites above (weighted,
// deflated-z); the dashboard shows raw hit% "vs base", so no second Wilson helper is needed here.
f_pct(int h, int n) => n == 0 ? na : 100.0 * h / n
var table dash = table.new(position.top_right, 2, dashMode == "Pro" ? 20 : 8, border_width = 1, frame_width = 1, frame_color = C_GRID)
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
    table.cell(dash, 1, 4, na(dashStop) ? "—" : str.tostring(dashStop, format.mintick), text_color = C_TEXT, text_size = size.small, bgcolor = C_BG)
    if not proDash
        // Compact-only: one combined Grade · size · HTF · trade-status row (v2.0)
        string _gTxt = candDir == 0 ? "—" : grade + (na(sizeR) ? "" : " · " + str.tostring(sizeR, "0.0") + "x") + " · " + _mWord + (hAlign == 1 ? "✓" : hAlign == -1 ? "⚠" : "·") + (ltfConfirm ? " L✓" : ltfConflict ? " L⚠" : "")
        table.cell(dash, 0, 5, "Grade · align", text_color = C_MUTED, text_size = size.small, bgcolor = C_BG)
        table.cell(dash, 1, 5, _gTxt, text_color = dirCol, text_size = size.small, bgcolor = C_BG)
        table.cell(dash, 0, 6, "Mode", text_color = C_MUTED, text_size = size.small, bgcolor = C_BG)
        table.cell(dash, 1, 6, modeTxt + (contDir != 0 ? "  " + (contDir == 1 ? "▲" : "▼") + contGrade : ""), text_color = modeCol, text_size = size.small, bgcolor = C_BG)
        table.cell(dash, 0, 7, "Options", text_color = C_MUTED, text_size = size.small, bgcolor = C_BG)
        table.cell(dash, 1, 7, not optOn ? "off" : optState + " · " + str.tostring(rVolPct, "#") + "%v" + (volRising ? "↑" : "↓") + (thetaCaution ? " θ!" : ""), text_color = optCol, text_size = size.small, bgcolor = C_BG)
    if proDash
        // ── Pro: support, raw conviction, forward-tested hit-rates, OOS edge (deflated LB) + Net-R ──
        float bUp = f_pct(baseUpHit, baseUpN)
        float bDn = f_pct(baseDnHit, baseDnN)
        float baseAll = f_pct(baseUpHit + baseDnHit, baseUpN + baseDnN)
        string sup = (r1 > 0 ? "1✓ " : "1· ") + (r2 > 0 ? "2✓ " : "2· ") + (g3 > 0 ? "3✓ " : "3· ") + (x4 > 0 ? "4✓ " : "4· ") + (c5 > 0 ? "5✓" : "5·") + (divAlign ? " · D✓" : "")
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
        string locTxt = not locOn ? "off" : (not locLinked ? (extLink ? "unwired" : "warming") : locConfirm ? "at shelf ✓" : locNear ? "near shelf" : "shelf·far")
        table.cell(dash, 0, 13, "Location (" + locSrcTxt + ")", text_color = C_MUTED, text_size = size.small, bgcolor = C_BG)
        table.cell(dash, 1, 13, locTxt + (not na(locLvl) ? "  " + str.tostring(locLvl, format.mintick) : ""), text_color = locConfirm ? dirCol : C_MUTED, text_size = size.small, bgcolor = C_BG)
        table.cell(dash, 0, 14, "Grade · size · align", text_color = C_MUTED, text_size = size.small, bgcolor = C_BG)
        table.cell(dash, 1, 14, candDir == 0 ? "—" : grade + (na(sizeR) ? "" : " · " + str.tostring(sizeR, "0.0") + "x") + " · " + hAlignTxt, text_color = dirCol, text_size = size.small, bgcolor = C_BG)
        table.cell(dash, 0, 15, "Mode", text_color = C_MUTED, text_size = size.small, bgcolor = C_BG)
        table.cell(dash, 1, 15, modeTxt + (contDir != 0 ? "  " + (contDir == 1 ? "▲ RIDE " : "▼ RIDE ") + contGrade + " · " + str.tostring(contConv, "#") + "%" : ""), text_color = modeCol, text_size = size.small, bgcolor = C_BG)
        int   nRide   = nRideBull + nRideBear
        int   hitRide = hitRideBull + hitRideBear
        float rideLB  = cal.wilsonLo(hitRide, nRide, 1.96) / 100.0
        table.cell(dash, 0, 16, "Ride hit% (n)", text_color = C_MUTED, text_size = size.small, bgcolor = C_BG)
        table.cell(dash, 1, 16, nRide < calMinN ? "learning (" + str.tostring(nRide) + ")" : str.tostring(f_pct(hitRide, nRide), "#.#") + "% (" + str.tostring(nRide) + ") · LB " + (na(rideLB) ? "—" : str.tostring(rideLB * 100.0, "#")), text_color = C_TEXT, text_size = size.small, bgcolor = C_BG)
        table.cell(dash, 0, 17, "Vol regime", text_color = C_MUTED, text_size = size.small, bgcolor = C_BG)
        table.cell(dash, 1, 17, not optOn ? "off" : str.tostring(rVolPct, "#") + "% " + (volRising ? "↑ rising" : "↓ falling") + (volHigh ? " · hi" : ""), text_color = volHigh ? colBear : volRising ? colBull : C_MUTED, text_size = size.small, bgcolor = C_BG)
        table.cell(dash, 0, 18, "Options (move)", text_color = C_MUTED, text_size = size.small, bgcolor = C_BG)
        table.cell(dash, 1, 18, not optOn ? "off" : optState + " · " + str.tostring(expMovePts, "#") + "p" + (thetaCaution ? " · θ!" : ""), text_color = optCol, text_size = size.small, bgcolor = C_BG)
        string _ibTxt = not ibOn ? "off" : (na(ibHigh) or na(ibLow)) ? "forming" : (ibBrk == 1 ? "▲ broke high" : ibBrk == -1 ? "▼ broke low" : "inside") + (ibNear ? " · at edge ✓" : "")
        table.cell(dash, 0, 19, "Initial Balance", text_color = C_MUTED, text_size = size.small, bgcolor = C_BG)
        table.cell(dash, 1, 19, _ibTxt + ((not na(ibHigh) and not na(ibLow)) ? "  " + str.tostring(ibLow, format.mintick) + "–" + str.tostring(ibHigh, format.mintick) : ""), text_color = ibNear ? dirCol : C_MUTED, text_size = size.small, bgcolor = C_BG)

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
// Unified trade levels — drawn for the actionable signal, whether a REVERSAL fire or a RIDE entry (they
// are regime-exclusive, so one object set serves both). Entry / Stop / TP1 / TP2 + the signal label.
bool _lvlFire = actSignal or rideSignal
int  _lvlDir  = actSignal ? candDir : contDir
if _lvlFire and barstate.isconfirmed and (showLevels or showSigLbl)
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
    float stp   = actSignal ? (not na(stopLvl) ? stopLvl : entry - candDir * calMove * atr) : (contDir == 1 ? math.min(cLo10, entry - calMove * atr) : math.max(cHi10, entry + calMove * atr))
    float risk  = math.max(math.abs(entry - stp), atr * 0.1)
    float t1    = entry + _lvlDir * rr1 * risk
    float t2    = entry + _lvlDir * rr2 * risk
    int   xR    = bar_index + levLen
    if showLevels
        lnE  := line.new(bar_index, entry, xR, entry, xloc = xloc.bar_index, color = color.new(color.gray, 0), style = line.style_solid,  width = 1)
        lnS  := line.new(bar_index, stp,   xR, stp,   xloc = xloc.bar_index, color = color.new(colBear, 0),    style = line.style_dashed, width = 1)
        lnT1 := line.new(bar_index, t1,    xR, t1,    xloc = xloc.bar_index, color = color.new(colBull, 0),    style = line.style_dashed, width = 1)
        lnT2 := line.new(bar_index, t2,    xR, t2,    xloc = xloc.bar_index, color = color.new(colBull, 25),   style = line.style_dotted, width = 1)
        lbE  := label.new(xR, entry, "Entry " + str.tostring(entry, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = C_BG, textcolor = C_TEXT,  size = size.tiny)
        lbS  := label.new(xR, stp,   "Stop "  + str.tostring(stp,   format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = C_BG, textcolor = colBear, size = size.tiny)
        lbT1 := label.new(xR, t1,    "TP1 "   + str.tostring(t1,    format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = C_BG, textcolor = colBull, size = size.tiny)
        lbT2 := label.new(xR, t2,    "TP2 "   + str.tostring(t2,    format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = C_BG, textcolor = colBull, size = size.tiny)
    if showSigLbl
        string _sHead = actSignal ? ((candDir == 1 ? "▲ BOTTOM " : "▼ TOP ") + grade + " · " + str.tostring(convCal, "#") + "%" + (na(sizeR) ? "" : " · " + str.tostring(sizeR, "0.0") + "x")) : ((contDir == 1 ? "▲ RIDE " : "▼ RIDE ") + contGrade + " · " + str.tostring(contConv, "#") + "%")
        lbSig := label.new(bar_index, na, _sHead + optTag, xloc = xloc.bar_index, yloc = _lvlDir == 1 ? yloc.belowbar : yloc.abovebar, style = _lvlDir == 1 ? label.style_label_up : label.style_label_down, color = _lvlDir == 1 ? colBull : colBear, textcolor = color.white, size = actSignal ? size.small : size.tiny)

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
var table keyT = table.new(keyPos == "Bottom Right" ? position.bottom_right : keyPos == "Top Left" ? position.top_left : keyPos == "Middle Left" ? position.middle_left : position.bottom_left, 2, 7, frame_width = 1, frame_color = C_GRID, border_width = 1)
if showKey and barstate.islast
    table.cell(keyT, 0, 0, "KEY", text_color = color.white, bgcolor = C_HEADER, text_size = size.tiny)
    table.cell(keyT, 1, 0, "Two signal systems", text_color = color.white, bgcolor = C_HEADER, text_size = size.tiny)
    table.cell(keyT, 0, 1, "◆", text_color = colBull, bgcolor = C_BG, text_size = size.tiny)
    table.cell(keyT, 1, 1, "REVERSAL — confirmed turn (bright = conviction)", text_color = C_TEXT, bgcolor = C_BG, text_size = size.tiny)
    table.cell(keyT, 0, 2, "○", text_color = C_MUTED, bgcolor = C_BG, text_size = size.tiny)
    table.cell(keyT, 1, 2, "REVERSAL — forming (early warning)", text_color = C_MUTED, bgcolor = C_BG, text_size = size.tiny)
    table.cell(keyT, 0, 3, "▲▼", text_color = colBull, bgcolor = C_BG, text_size = size.tiny)
    table.cell(keyT, 1, 3, "CONTINUATION — with-trend ride", text_color = C_TEXT, bgcolor = C_BG, text_size = size.tiny)
    table.cell(keyT, 0, 4, "▬", text_color = colBear, bgcolor = C_BG, text_size = size.tiny)
    table.cell(keyT, 1, 4, "Entry / Stop / TP levels", text_color = C_MUTED, bgcolor = C_BG, text_size = size.tiny)
    table.cell(keyT, 0, 5, "⚡", text_color = colBull, bgcolor = C_BG, text_size = size.tiny)
    table.cell(keyT, 1, 5, "Options: ⚡ favorable · ⚡? caution · ⚡✕ avoid", text_color = C_MUTED, bgcolor = C_BG, text_size = size.tiny)
    table.cell(keyT, 0, 6, "░", text_color = C_MUTED, bgcolor = C_BG, text_size = size.tiny)
    table.cell(keyT, 1, 6, "Grey wash = engine standing aside", text_color = C_MUTED, bgcolor = C_BG, text_size = size.tiny)
````
