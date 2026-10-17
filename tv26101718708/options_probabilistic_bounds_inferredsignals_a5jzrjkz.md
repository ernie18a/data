# Options Probabilistic Bounds [InferredSignals]

- url: https://www.tradingview.com/script/A5JZrjKz-Options-Probabilistic-Bounds-InferredSignals/
- type: indicator
- pine_id: PUB;3abb4c03bdd94010a5206dd6ef612165
- version: 2.0

## Description

[b]█ OVERVIEW[/b]

Options Probabilistic Bounds (OPB) draws a forward price corridor on the daily chart — an upper and a lower band projected over a horizon you choose (1 to 20 trading days) at a confidence level you choose (default 95%).

In plain words: given how this stock has actually been moving, where could the CLOSING price realistically land over the next few days? The corridor is calibrated so that, at each horizon, roughly your chosen percentage of closes finish inside it.

It is built for option sellers — short puts in particular. The lower band is a statistically calibrated reference for where to place a strike. And because the corridor takes no view on direction, OPB adds something most volatility tools don't: a drift readout that tells you which side currently has the wind at its back, so you can see whether puts or calls are the safer leg to sell right now.

No option-chain data is used anywhere — no implied volatility, no greeks, no implied-vol skew. "Options" describes who the tool is for, not what it reads. OPB is a pure statistical model of the underlying's own price history.

[b]█ WHAT MAKES IT ORIGINAL[/b]

[b]• Per-symbol MAP-style calibration, entirely in Pine. [/b]
Parameters are fitted to each ticker by minimizing a penalized negative log-posterior — Student-t likelihood, Bayesian-style priors, and residual-moment penalties combined in one objective — searched multi-start and coarse-to-fine, with the winner chosen on residual quality, not likelihood alone. The result: less in-sample curve-fitting and a steadier calibration than a plain best-fit vol model.

[b]• Two-component, leverage-aware GJR-GARCH variance. [/b]
A slow long-run level plus a faster mean-reverting short-run component, so a volatility shock decays over a few days instead of holding the corridor wide for weeks. Negative-return days get a specific leverage response — downside risk is modeled, not averaged away.

[b]• Filtered historical tails with EVT extension. [/b]
The residual body is empirical (Filtered Historical Simulation); each tail is extended with a Generalized Pareto fit whose shape and scale are estimated in closed form by Probability-Weighted Moments (Hosking-Wallis) — more stable than method-of-moments or MLE on the small tail samples you actually get. The shape is floored at zero so equity tails are never assumed bounded, and with too few exceedances it falls back to empirical quantiles rather than overfitting noisy extremes.

[b]• Data-driven downside asymmetry. [/b]
The downside leverage increment is routed fully to the lower band; the upper band receives only a data-driven semivariance fraction. The corridor widens below only as far as the symbol's own history justifies.

[b]█ THE DRIFT READOUT — WHICH SIDE TO SELL[/b]

The bands are DRIFT-NEUTRAL by design: centered on today's close, never tilted up or down. Over 1–20 days, direction is effectively unestimable from price history — and a wrong directional bet would quietly under-reserve the downside, the worst place to be short a put. So the whole band width is spent on dispersion, none of it gambled on a direction the data can't support.

OPB still measures the recent drift and reports it as a small number next to σ, in [−1, +1]:
• ↑ : favors puts — the stock has been drifting up, so the put leg has had a cushion.
• ↓ : favors calls — drifting down, the call leg has had the cushion.
• flat — no meaningful drift.

Practical read: it is usually safer to sell the leg the drift is moving AWAY from — sell puts into an uptrend, calls into a downtrend. The wind at your back.

In the backtest this shows up cleanly: on a strongly trending stock the drift-neutral bands breach the TREND side more often than the nominal rate, while the opposite side stays close to it. This is expected, not miscalibration — the corridor is honestly direction-agnostic, so the band width itself stays unbiased and the extra breaches on the trend side are pure drift. The takeaway matches the readout: the side you should be selling — the one the trend is moving away from — is the side that stays calibrated. One caveat: the drift readout is the RECENT past, never a forecast — a strong reading is often exactly where mean-reversion becomes most likely. The fat-tailed band remains the real safety net.

 [image]https://www.tradingview.com/x/nf0gaZ6g/[/image]

[i]MU · daily · walk-forward, monthly recals. On this uptrend the trend side (Brch+) runs well above nominal while the put-sell side (Brch−) holds at/below its 2.5% target — the drift asymmetry described above, in numbers.[/i]

[b]█ HOW TO USE IT[/b]

• Set a horizon (e.g. 5 days) and a confidence level (e.g. 95%).
• Read the upper/lower band at your horizon as a strike-placement reference.
• Glance at the drift readout to pick the safer leg — puts vs calls.
• Turn on the walk-forward backtest and check: Close-in ≈ your confidence level; Brch+ / Brch− near the per-side rate and reasonably balanced; NT dn = how often a lower-band strike was never touched over the whole path — the number that matters for assignment.
• Optional PIT diagnostic: D ≈ 1 well-sized, D < 1 too wide, D > 1 too narrow. Read h = 1 first (least affected by overlapping windows).
• Anchor mode D-1…D-5 freezes the corridor as it looked N days ago, calibrated only on data known then — handy to inspect how past corridors held.

[b]█ SETTINGS[/b]

Defaults are robust and research-oriented: Horizon 5d · Confidence 95% · Calibration window 252d · Two-component variance ON · Leverage-asymmetric bands ON · Earnings-gap neutralization ON.

"Long-run half-life" sets how steady the long-run volatility baseline is — a higher value keeps it stiffer after a shock, which (with the two-component model on) reduces post-shock over-widening.

Every input ships with a plain-language tooltip. Daily timeframe only. Calibration runs on the last bar for performance; walk-forward recalibration is monthly, a Pine execution-time constraint.

[b]█ WHAT IT IS NOT[/b]

• Not a directional forecast — the corridor is drift-neutral, centered on the anchor close.
• Not a joint path bound — confidence targets the close at each horizon separately; the chance of touching a band along the path is the separate No-Touch figure (see backtest).
• Not an option-pricing model — no implied volatility, greeks, or option-chain data.
• Not a guarantee — the backtest and PIT diagnostics are historical calibration evidence, not a promise of future coverage.

Full methodology, equations, and references are documented section by section in the source code. This is a research and educational tool, not investment advice.

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════════════════════
//  I N F E R R E D   S I G N A L S
//  The future isn't predicted. It's inferred.
// ───────────────────────────────────────────────────────────────────
//  Indicator ... Options Probabilistic Bounds (OPB)
//  Timeframe ... Daily
//  Version ..... 2.94-2
//  Author ...... InferredSignals
//  License ..... This source code is subject to the terms of the Mozilla Public License 2.0
//                at https://mozilla.org/MPL/2.0/
//                Please credit InferredSignals if you reuse or modify this work.
//  Updated ..... 2026-06
// ══════════════════════════════════════════════════════════════════════════════════════
// © 2026 InferredSignals — Options Probabilistic Bounds (OPB) — Pine Script v6
// ══════════════════════════════════════════════════════════════════════════════════════
// ┌──────────────────────────────────────────────────────────────────────┐
// │ 1.  WHAT IT IS  /  WHAT IT IS FOR                                    │
// └──────────────────────────────────────────────────────────────────────┘
//
//
// OPB draws a forward PRICE CORRIDOR on a daily chart: an upper and a lower
// band projected over a horizon you choose (1–20 trading days) at a confidence
// level you choose (e.g. 95%). In one sentence:
//
//     "Given how this stock has actually been moving, where is the CLOSING
//      price likely to land at each horizon day 1…N — such that, at any single
//      horizon, about C% of closes fall inside the corridor?"
//
// It is built for OPTION SELLERS — short puts in particular. The lower band at
// horizon h is the model's estimate of how far the CLOSE could realistically
// fall by day J+h: the close finishes below it roughly (100−C)/2 % of the time
// (an ENDPOINT, per-side probability). The chance the strike is TOUCHED anywhere
// along J+1…J+h is HIGHER, and is the path-wise "No-Touch down" figure in §5b —
// that is the number a put seller worried about assignment should actually read.
//
// THREE THINGS OPB IS NOT — stated up front:
//
//   • NOT a joint path bound. These are MARGINAL intervals — one interval PER
//     horizon h for the CLOSE at day J+h. C targets ENDPOINT close coverage at
//     each horizon separately, NOT the probability that the whole path J+1…J+N
//     stays inside (that one is always lower: N chances to poke out, not one).
//
//   • NOT a touch model. The bands are calibrated on the CLOSE. Whether the
//     intraday high/low ever TOUCHED a band along the path is a stricter,
//     separate question — answered by the No-Touch figures (§5b), not by C.
//
//   • NOT a directional forecast. OPB assumes ZERO DRIFT: the corridor is
//     centred on today's close, never tilted up or down. It is a RANGE model —
//     it tells you HOW FAR, never WHICH WAY. (A purely DESCRIPTIVE drift gauge
//     is shown next to σ — see THE DRIFT READOUT below and §5a/§7.12 — but it
//     never touches the bands; the corridor stays drift-neutral.)
//
// WHY DRIFT-NEUTRAL (deliberate, not a shortcut):
//   • Drift is effectively unestimable at these horizons. The expected return μ
//     carries a standard error ~ σ/√T — the mean is the single hardest moment to
//     pin down from price history, while volatility is estimable from a small
//     fraction of the same sample. Over 1–20 days the drift contribution μ·h is
//     dwarfed by the band half-width ~ σ·√h, so fitting μ injects far more noise
//     than signal and just makes the corridor wobble for no gain.
//   • A mis-estimated drift tilts the corridor UP and UNDER-reserves the
//     downside — precisely the dangerous direction for a short-put seller. Zero
//     drift is the conservative, honest centring: the entire band width is spent
//     on dispersion, none of it gambled on a direction the data can't support.
//
// THE DRIFT READOUT (next to σ — a reading, NEVER part of the bands):
//   The bands assume ZERO drift, so they are symmetric: each side is supposed
//   to be breached only (100−C)/2 % of the time — e.g. ~2.5% each at 95%. But a
//   stock that has been drifting UP will, in the backtest, breach the UPPER
//   band MORE than that 2.5% and the LOWER band LESS: the symmetric bands don't
//   know about the trend. The little DRIFT number next to σ (in [−1,+1]) just
//   measures that recent drift — so it warns you, a bit in advance, which side
//   is likely to breach more: the side the drift is heading toward. Practical
//   read for a seller: it is usually safer to sell the OPPOSITE side — sell
//   PUTS when the drift is up ("↑ : favors puts"), CALLS when it is down
//   ("↓ : favors calls"). The drift never moves the bands; it only tells you
//   which side has the wind at your back.
//   IMPORTANT: this is the RECENT drift, NOT a forecast. A strong reading is
//   often exactly where mean-reversion becomes most likely — so read it as
//   "which side has had the wind lately", NEVER as "which side is safe". The
//   fat-tailed band stays the real safety net.
//
// HONEST DISCLAIMER (please read):
//   • NO option-chain data is used anywhere — no implied volatility, no greeks,
//     no open interest, no skew. OPB is a pure statistical model of the
//     UNDERLYING's own price history. The word "Options" in the name describes
//     WHO the tool is for, not what it consumes.
//   • This is a research / educational tool. It is NOT investment advice and
//     gives NO guarantee of future coverage. Use at your own risk.
//
//
// ┌──────────────────────────────────────────────────────────────────────┐
// │ 2.  HOW TO READ THE CHART                                            │
// └──────────────────────────────────────────────────────────────────────┘
//
//   • Upper band (sage-teal)  — top of the corridor at your confidence.
//   • Lower band (dusty rose)  — bottom of the corridor; the level that
//     matters most for a short put.
//   • Midline (dashed)         — the anchor close, held flat. OPB assumes
//     ZERO drift, so the corridor is centred on today's price, not tilted up
//     or down (it is a RANGE model, not a directional forecast — see §6/§7).
//   • Fill                     — the corridor between the two bands.
//   • Per-day dots / values    — the band level at each day 1…h, so you can
//     read the corridor for any sub-horizon, not just the final day.
//   • σ label inside the zone  — the annualised forward 1-day vol that drives
//     the LOWER band (top line of the box); with leverage-asymmetry ON it is
//     the downside σ_dn (marked "σ↓"), σ_up being shown in the diagnostic box.
//     A normalised number, handy for comparing how "hot" two symbols are.
//   • drift line (under σ)     — second line of the same box: a DESCRIPTIVE
//     trend read in [−1,+1] (a recent-drift t-statistic, §7.12). "↑ : favors
//     puts" / "↓ : favors calls" flag which short leg the recent drift has
//     lately been a tailwind for ("• flat" when small). It does NOT move the
//     bands — see THE DRIFT READOUT in §1.
//
//   Anchor mode (LIVE vs D-1…D-5): LIVE anchors the corridor to today. D-N
//   FREEZES the bands as they would have looked N days ago, calibrated on
//   data available only up to that day (strict no look-ahead). Use it to
//   eyeball how past corridors actually contained the price.
//
//
// ┌──────────────────────────────────────────────────────────────────────┐
// │ 3.  THE MODEL IN ONE BREATH  (full detail + references in §7)        │
// └──────────────────────────────────────────────────────────────────────┘
//
// A two-component, leverage-aware GJR-GARCH variance model: a slow realised
// long-run level (EWMA of Yang–Zhang range variance) plus a fast,
// mean-reverting short-run component, so a volatility shock decays over a few
// days instead of being extrapolated forever. Parameters are fitted PER
// TICKER by a MAP-style objective (Student-t likelihood + Bayesian priors +
// residual-moment penalties), searched with a multi-start coarse-to-fine
// grid. The tail is a Filtered-Historical-Simulation body spliced with a
// Generalized-Pareto (EVT / peaks-over-threshold) tail estimated by
// Probability-Weighted Moments. Multi-day scaling uses a Lo–MacKinlay
// variance ratio; the up/down band asymmetry is set by a realised-semivariance
// ratio ψ. Earnings are neutralised, dividends corrected, and the variance
// recursion is made robust by Huber-type (bounded-influence) winsorisation.
//
// If those words mean nothing to you yet, ignore them: pick a horizon and a
// confidence and read the bands. The full machinery is documented in §7.
//
//
// ┌──────────────────────────────────────────────────────────────────────┐
// │ 4.  INPUTS  (defaults are robust research-oriented)                  │
// └──────────────────────────────────────────────────────────────────────┘
//
// DISPLAY MODE
//   Anchor mode .............. LIVE (default) or D-1…D-5. See §2.
//   Ignore Earnings Gap ...... ON (default). The earnings bar AND the next
//                              bar are NEUTRALISED in the variance recursion
//                              (return→0, range-RV→long-run variance) and
//                              dropped from the likelihood and residual pool —
//                              NOT deleted from the series. Stops a single
//                              earnings jump from poisoning the vol estimate.
//
// MAIN
//   Horizon (days) ........... 5 (1–20). Projection length.
//   Confidence level (%) ..... 95.0 (50–99.5). Coverage target of the bands.
//
// ADVANCED
//   Calibration window (days)  252 (126–756). History used to fit the model
//                              and to build the residual / tail pool.
//   RV coupling γ = γ_ratio·α  0.4 (0–2.0). Weight on the realised-variance
//                              term in the recursion, expressed as a multiple
//                              of α.
//   Shrunk Lo-MacKinlay acorr  ON. Scales multi-day variance for return
//                              autocorrelation (shrunk toward zero so noise
//                              does not inflate the bands).
//   Leverage-asymmetric bands  ON. The downside-specific GJR leverage
//                              increment is routed FULLY to the lower band and
//                              only a data-driven fraction ψ∈[0,1] to the
//                              upper band. OFF ⇒ ψ≡1 (symmetric). Toggle
//                              OFF→ON as a clean A/B control.
//   Two-component variance (V2) ON. GJR runs on DEVIATIONS from the slow
//                              long-run level τ, so a shock lives in the
//                              fast-reverting short-run component. OFF ⇒
//                              single-component legacy behaviour (A/B / fallback).
//   Long-run half-life (days)  42 (10–120). Half-life of the long-run level τ.
//                              Higher = more stationary τ = stronger
//                              post-shock tightening at long horizons. This is
//                              the MAIN dial for post-shock band width.
//   Diagnostic display ....... None (default) or Detailed. See §5a.
//   Trend gauge window (days)  63 (10–252). Lookback for the Trend (drift)
//                              gauge shown in the diagnostic box (§5a). It is a
//                              t-statistic of the recent drift squashed to
//                              [-1,+1]. PURELY a readout — it does NOT enter the
//                              bands, which stay strictly drift-neutral (§1/§6).
//                              Lower = more reactive.
//
// BACKTEST (Walk-Forward)
//   Enable backtest mode ..... OFF (default). See §5b. Heavy — runs once on
//                              the last bar.
//   Backtest window (days) ... 252 (1–252). Number of historical days tested.
//   Backtest horizon (days) .. 5 (1–20). How many forward days the walk-
//                              forward panel reports. This option extends the
//                              backtest beyond the default 5; the per-day band
//                              formula is unchanged — the panel simply reports
//                              more horizons. The PIT panel stays capped at 5.
//   Tolerance (bp) ........... 0 (0–200). A breach counts only if price
//                              exceeds the band by this buffer (1 bp = 0.01%).
//
// PIT CONDITIONAL DIAGNOSTIC (needs Backtest ON)
//   Show PIT regime-split .... OFF (default). See §5c.
//   Shock threshold (σ) ...... 2.0 (0.5–5.0). A day is "post-shock" when its
//                              standardised return is below −k (e.g. a 2σ down
//                              day), letting PIT split shock vs normal regimes.
//
// STYLE / MARKERS
//   InferredSignals palette (band colours, midline, fill), line width, show
//   midline / fill / per-day markers / per-day values / in-zone σ label.
//
//
// ┌──────────────────────────────────────────────────────────────────────┐
// │ 5.  THE THREE PANELS  (what they are, how to read the numbers)       │
// └──────────────────────────────────────────────────────────────────────┘
//
// ── 5a.  DIAGNOSTIC BOX  (set "Diagnostic display" = Detailed) ───────────
//
// A live readout of the fitted model on the anchor bar. Lines, top to bottom:
//
//   Upper / Lower .......... final band levels and % from the anchor close.
//   Variance ............... 2-comp (τ = EWMA-RV long-run / GJR short-run) or
//                            1-comp legacy.
//   Calibrated params ......
//     α, β ................. GARCH ARCH / persistence weights.
//     δ .................... GJR leverage increment (extra weight on down moves).
//     γ .................... realised-variance coupling (= γ_ratio·α).
//     ν .................... Student-t degrees of freedom ("∞ (Gauss)" if ≥30).
//     ψ_s short-run ........ short-run persistence = α + δ/2 + β + γ. Low here
//                            by design (≈0.6): shocks must decay fast.
//     t½(SR) / t½(LR) ...... half-lives of the short- and long-run components.
//     Long-run σ_LR ........ annualised long-run volatility level.
//     Leverage share ....... fraction of the ARCH response driven by δ.
//     −logPost ............. value of the MAP objective at the optimum (lower
//                            = better fit, not comparable across symbols).
//     ResQual .............. |skew| + |exkurt − 6/(ν−4)|/max(1,·) + 2·|var−1| of
//                            the standardised residuals (excess-kurtosis judged
//                            against the t-implied target, NOT against 0). Near
//                            0 ⇒ residuals match the fitted shape (GOOD). Same
//                            criterion the multi-start uses to pick the winner.
//     "N constrained" ...... N fitted parameters sit on a grid bound. A few is
//                            normal; many ⇒ read the fit with caution.
//   Robust (Huber) ......... winsorisation threshold c (in σ) and how many
//                            observations were winsorised over the window.
//   Volatility .............
//     σ_t (pre-shock) ...... 1-day vol BEFORE today's move is absorbed.
//     σ_t+1 ↓ (lower band) . downside 1-day vol σ_dn that sets the lower-band width; 
//                            σ_up is the Lev-asym line below.
//     Trend (drift) ........ a DESCRIPTIVE direction read: a t-statistic of the
//                            recent drift over "Trend gauge window" days,
//                            squashed by tanh to [-1,+1]. +ve ⇒ the recent
//                            drift has been UP, so the PUT leg has lately sold
//                            WITH a cushion; −ve ⇒ DOWN, the CALL leg had the
//                            cushion; ~0 ⇒ flat. It is NOT added to the bands
//                            (the corridor stays drift-neutral) and it is NOT a
//                            forecast — a strong reading is the recent past, not
//                            a promise of safety (mean-reversion is often most
//                            likely exactly then). See §6/§7.12.
//     Lev-asym ψ ........... the up/down split ratio and the post-red sample
//                            size it was estimated on.
//     σ_up / σ_dn .......... the two one-sided 1-day vols. σ_dn ≥ σ_up always:
//                            the GJR down-day increment goes in full to σ_dn,
//                            only ψ∈[0,1] of its POSITIVE part to σ_up.
//     σ_unc (Nd) ........... unconditional reference vol over the calibration window.
//     σ_h (Nd) ............. horizon vol; "[CAPPED]" means it hit the
//                            3·√(σ²·h) sanity ceiling.
//   Quantiles (standardised, 1-day)
//     Tail [FHS+GPD] ....... the z_lo / z_hi the bands are actually built on.
//     GPD ξ ................ tail-shape per side ("body" if that side did not
//                            reach the GPD region); n_exc = exceedance counts.
//     FHS body ............. empirical body quantiles.
//     t (fallback) ......... parametric Student-t quantiles (used only if the
//                            residual pool is too small).
//   Residuals .............. FHS skew / excess-kurtosis, shrunk ρ₁, VR/h.
//   Corporate actions ...... dividend events seen; earnings events and how
//                            many bars were neutralised.
//
// ── 5b.  WALK-FORWARD BACKTEST  (Enable backtest mode) ───────────────────
//
// An honest out-of-sample replay. The model is recalibrated MONTHLY; for each
// historical day J the bands are built using ONLY information available at J
// (F_t-aligned, strict no look-ahead), with a fixed-length rolling residual
// window of the same span as the live path. Then the realised path J+1…J+h is
// scored. Per horizon h = 1…(backtest horizon):
//
// NB : The forward corridor can be projected up to 20 days. The walk-forward
//      panel reports horizons 1…Backtest-horizon (set in §4). The PIT panel is
//      capped at horizon 5: beyond that, overlapping windows make the PIT
//      statistics heavily autocorrelated and uninformative (h=1 is the
//      overlap-free, most reliable row), so extending PIT further would add
//      cost without diagnostic value.
//
//   Close in % ... realised close lands INSIDE the band at J+h.
//                  Target ≈ your confidence level.
//   Brch+ / Brch− close at J+h sits ABOVE upper / BELOW lower band.
//                  Target ≈ (100 − confidence)/2 per side.
//   NT up / NT dn  No-Touch: the band was NEVER touched intraday over the
//                  whole path J+1…J+h (a stricter, path-wise test).
//   NT both ...... neither band touched over the path.
//
//   NT dn ≈ the empirical probability that a short-put strike at the lower
//   band would have HELD (never been hit) over the horizon — the figure a put
//   seller cares about most.
//
//   How to judge calibration: "Close in" near the confidence level, "Brch"
//   close to theory AND balanced between the two sides. If Brch− ≫ Brch+, the
//   downside is under-reserved (widen it / check ψ). The box also reports the
//   mean ψ across recal segments when leverage-asymmetry is ON.
//
//   WHY MONTHLY (full honesty): the recalibration cadence is Monthly because a
//   finer cadence runs more full grid-fits inside one execution and exceeds
//   Pine Script's per-loop time budget. The engine deliberately UNROLLS up to
//   13 sequential calibrations to stay within that budget. This is a PLATFORM
//   constraint, not a modelling preference — daily/weekly recal would be
//   statistically nicer but is not feasible on TradingView. The backtest is
//   computationally heavy and is computed once, on the last bar.
//
// ── 5c.  PIT CONDITIONAL DIAGNOSTIC  (Show PIT, needs Backtest ON) ───────
//
// A strong calibration diagnostic. Every realised outcome is mapped to its
// position u = F(realised) inside the MODEL'S OWN predictive CDF (the same
// FHS body + GPD tail, side-aware). If the model is correctly calibrated, u is
// Uniform(0,1) — so mean(u) ≈ 0.50 and D = Var(u)·12 ≈ 1. Outcomes are split
// into POST-SHOCK days (standardised return < −k) vs NORMAL days, which the
// plain breach counts of §5b cannot reveal. Per horizon h = 1…5 (PIT is capped
// at 5; see §5b NB):
//
//   n ...... outcomes in that regime/horizon.
//   mean ... mean PIT. Theory 0.50.
//   D ...... Var(PIT)·12. D ≈ 1 = well-sized; D < 1 = bands too WIDE
//            (over-conservative); D > 1 = bands too NARROW.
//   Lo% / Up% realised tail-breach % per side. Theory (100 − confidence)/2.
//
// Read h = 1 first (overlap-free, most statistical power). If post-shock D
// ≪ normal D, the corridor is over-wide specifically AFTER a shock — which
// is the type of behaviour the two-component variance model is designed to
// reduce. This panel lets you check whether post-shock calibration improved.
// With a small shock sample, trust D over Lo%/Up% (the latter are binary and
// low-power).
//
//
//
// ┌──────────────────────────────────────────────────────────────────────┐
// │ 6.  HONEST LIMITATIONS  &  PINE CONSTRAINTS                          │
// └──────────────────────────────────────────────────────────────────────┘
//
//   • Underlying-only. No option data of any kind is consumed.
//   • Daily timeframe only (enforced).
//   • ZERO drift. Bands are centred on the current close; OPB models RANGE /
//     volatility, not direction. Deliberate — estimating drift from price
//     adds far more noise than signal at these horizons.
//   • The Trend (drift) gauge in the diagnostic box is a DESCRIPTOR of the
//     RECENT drift regime, not a forecast. A strong reading means that side has
//     lately had a drift tailwind — it does NOT mean that side is "safe":
//     mean-reversion is often most likely exactly when the score is large. The
//     fat-tailed band stays the actual risk control; the gauge never widens,
//     narrows, or tilts the corridor (μ remains 0 in the bands).
//   • Calibration runs on the LAST bar only, for performance. Bands recompute
//     when a new daily bar closes, not bar-by-bar through history.
//   • Backtest recalibration is MONTHLY and capped at ≤13 unrolled fits — a
//     Pine execution-time limit, not a modelling choice (see §5b).
//   • LIVE vs BACKTEST asymmetries (deliberate, Pine-budget driven): in the
//     backtest ψ and the autocorrelations ρ₁–ρ₄ are FROZEN at each MONTHLY
//     recal point, whereas LIVE recomputes them at the anchor bar; and the
//     backtest's rolling residual window may span several recal vintages while
//     the LIVE window uses a single one. Accepted performance tradeoffs, not
//     modelling choices.
//   • History is bounded by max_bars_back = 1200.
//   • Backtest mode consumes roughly calibration window + burn-in + backtest
//     window + backtest-horizon bars of history. On recently listed symbols
//     the oldest test days fall back to long-run defaults — graceful
//     degradation, but those early rows are less informative.
//   • The GPD tail is noisy when exceedances are few: ξ is clamped to
//     [0.00, 0.50], the estimator falls back to the empirical quantile below
//     10 exceedances, and ξ is FLOORED at 0 (never negative) so the downside
//     band can never thin below an exponential tail — deliberate
//     over-reservation in favour of the short-put seller.
//   • Open source ⇒ every parameter value is visible. The durable edge is the
//     calibration JUDGEMENT (which knobs to move under which regime), not the
//     file.
//   • Backtest and PIT describe the PAST. They are calibration evidence, not a
//     promise of future coverage. The bands are model probabilities, not
//     guarantees. Not investment advice.
//
//
// ┌──────────────────────────────────────────────────────────────────────┐
// │ 7.  THE MODEL IN DETAIL                                              │
// └──────────────────────────────────────────────────────────────────────┘
//
// 7.1  RETURNS & CORPORATE ACTIONS
//   Log returns are dividend-corrected. Splits are handled by the data feed.
//   A NON-FINITE log return — the bar-0 +inf from nz(close[1])=0, or an na
//   close on a halted / illiquid day — is information-free and is neutralised
//   to 0 BEFORE any moment estimator sees it, so it can never poison the
//   variance, the Lo-MacKinlay autocovariance, the likelihood or the residual
//   pool. On a neutralised earnings bar the return is set to 0 and the
//   range-RV to the long-run variance, so the jump never enters the variance
//   recursion, the likelihood, or the residual pool.
//
// 7.2  REALISED-VARIANCE PROXY
//   A single-bar Yang–Zhang-style range estimator combines a Rogers–Satchell
//   intrabar term with the overnight and open-to-close terms. This RV feed
//   drives both the long-run level τ and the GARCH realised-variance coupling.
//   Weighting note: the open-to-close term enters at 0.34·CO² ON TOP of the full
//   Rogers–Satchell term, so E[RV] slightly OVER-counts the continuous intraday
//   variance vs a canonical YZ split (k·CO + (1−k)·RS). Because FHS standardises
//   returns by this same σ̂, the band SCALE z·σ̂ stays essentially unbiased — the
//   residual effect is a 2nd-order shift in the γ-coupling dynamics only. Kept
//   as-is for continuity; a canonical YZ split is a candidate refinement.
//   [Rogers & Satchell 1991; Yang & Zhang 2000]
//
// 7.3  TWO-COMPONENT, LEVERAGE-AWARE VARIANCE
//   The conditional variance is a component GARCH: a slow long-run level τ
//   (EWMA of the YZ-RV, half-life = "Long-run half-life") plus a short-run
//   GJR-GARCH that runs on DEVIATIONS from τ. τ uses lagged RV only, keeping
//   σ²_t measurable at t−1 (no look-ahead). The GJR term adds extra weight δ
//   to negative-return days (the leverage effect). After a shock the spike
//   sits in the fast short-run component and mean-reverts in a few days, while
//   τ stays roughly flat — designed to reduce the post-shock band over-width of
//   a single-component model. (Strict no-look-ahead holds for the DEFAULT
//   two-component path. In the single-component fallback τ = the rolling
//   unconditional variance, which at bar t still includes r_t — a one-bar
//   in-sample leakage confined to legacy mode, kept for A/B continuity.)
//   [Glosten, Jagannathan & Runkle 1993;
//   Engle & Lee 1999; Bollerslev 1986/1987]
//
// 7.4  ROBUST WINSORISATION (bounded influence)
//   Before entering the recursion, a squared return larger than (c·σ)² is
//   Huber-winsorised, where c is the 0.25%-tail Student-t quantile. This caps
//   the influence of any single extreme day (bounded innovation propagation),
//   so one outlier cannot dominate the variance path. [Huber 1964;
//   Muler & Yohai 2008]
//
// 7.5  PER-TICKER CALIBRATION  (MAP-style objective)
//   Parameters (α, β, δ, ν) are fitted by minimising a penalised negative
//   log-posterior: a Student-t log-likelihood, Gaussian priors on the
//   parameters and on the short-run persistence, a log-centred prior on ν, and
//   moment penalties pulling the standardised residuals toward unit variance,
//   zero skew and the t-implied kurtosis. The search is multi-start
//   (calm / high-vol / lit regions) and coarse-to-fine: a 5×5×4×8 grid then a
//   refined local grid, with the winner chosen by residual quality, not
//   likelihood alone — robust to local optima. [maximum-a-posteriori /
//   quasi-likelihood estimation; Student-t innovations: Bollerslev 1987]
//
// 7.6  TAIL ENGINE  (FHS body + GPD tail via PWM)
//   The standardised residual distribution is built by Filtered Historical
//   Simulation: the inner 80% uses the empirical residual quantiles, and each
//   outer 10% tail is modelled by a Generalized Pareto distribution
//   (peaks-over-threshold). The GPD shape ξ and scale β are estimated in
//   closed form by Probability-Weighted Moments (one pass, rank-weighted),
//   with ξ floored at 0 and capped at 0.5. This spliced law supplies both the
//   band quantiles and the PIT CDF — the GPD tails are exact inverses of each
//   other, and the empirical body matches the interpolated band quantile to
//   within 1/n. [Barone-Adesi, Giannopoulos & Vosper 1999; Pickands 1975;
//   Balkema & de Haan 1974; McNeil & Frey 2000; Hosking & Wallis 1987]
//
// 7.7  LEVERAGE-ASYMMETRY ψ  (realised semivariance)
//   ψ is the ratio of realised UPSIDE to DOWNSIDE semivariance, measured on
//   the days that follow a red day (unconditional if too few red days). The
//   downside leverage increment is applied in full to the lower band and only
//   ψ∈[0,1] of it to the upper band, so the corridor is wider below than above
//   exactly to the degree the data justify. [Barndorff-Nielsen, Kinnebrock &
//   Shephard 2010]
//
// 7.8  MULTI-STEP VARIANCE & AUTOCORRELATION SCALING
//   The h-day cumulative variance reverts toward the long-run level τ (not the
//   unconditional variance) at the short-run persistence rate, then is scaled
//   by a Lo–MacKinlay variance ratio built from shrunk autocorrelations
//   (lags 1–4). A 3·√(σ²·h) ceiling caps pathological widths. [Lo & MacKinlay
//   1988]
//
// 7.9  QUANTILE INVERSION
//   The Student-t fallback quantiles use a rational approximation of the
//   inverse normal CDF followed by a Cornish–Fisher-type expansion into the
//   Student-t quantile, rescaled to unit variance. [Acklam 2003;
//   Cornish & Fisher 1938]
//
// 7.10  BAND CONSTRUCTION
//   For each day k = 1…h: upper = close · exp(z_hi · σ_up,k),
//   lower = close · exp(z_lo · σ_dn,k), with z from the FHS+GPD law and σ from
//   §7.8. No drift term. The midline is the flat anchor close. Shape invariance:
//   the standardised quantiles z are 1-day and reused at all horizons via σ_k;
//   aggregational Gaussianity makes true h-day tails slightly thinner, so the
//   corridor is mildly conservative at long h — the safe side for a put seller.
//
// 7.11  WALK-FORWARD BACKTEST & PIT
//   The backtest replays the full pipeline out-of-sample with monthly recal
//   and a rolling fixed-length residual window (§5b). The PIT diagnostic
//   evaluates conditional calibration via the probability integral transform,
//   regime-split shock vs normal (§5c). [PIT: Rosenblatt 1952;
//   Diebold, Gunther & Tay 1998]
//
// 7.12  TREND / DRIFT GAUGE  (diagnostic only — never in the bands)
//   The mean daily (earnings-clean) log return μ̂ over a user window is turned
//   into a drift t-statistic t = μ̂·√n / s, then squashed by tanh(t/2) into
//   [-1,+1]. Reporting the SIGN and STRENGTH of the drift needs only a t-stat
//   (a near sign-test, robust), whereas PUTTING μ into the band would need its
//   MAGNITUDE (SE ~ σ/√T, far too noisy at 1–20 days — the very reason drift is
//   excluded from the bands, §1). So the gauge reads direction without
//   re-introducing band noise: drift-zero on the bands, t-stat on the gauge —
//   no contradiction. It is DESCRIPTIVE of the recent drift regime, never a
//   forecast (§6). tanh is not a Pine v6 built-in and is expanded in closed
//   form (f_tanh, with an overflow clamp).
//
//
// ── REFERENCES ───────────────────────────────────────────────────────────
//   Bollerslev (1986/1987) · Glosten, Jagannathan & Runkle (1993) ·
//   Engle & Lee (1999) · Rogers & Satchell (1991) · Yang & Zhang (2000) ·
//   Barone-Adesi, Giannopoulos & Vosper (1999) · Pickands (1975) ·
//   Balkema & de Haan (1974) · McNeil & Frey (2000) ·
//   Hosking & Wallis (1987) · Barndorff-Nielsen, Kinnebrock & Shephard (2010) ·
//   Lo & MacKinlay (1988) · Huber (1964) · Muler & Yohai (2008) ·
//   Acklam (2003) · Cornish & Fisher (1938) · Rosenblatt (1952) ·
//   Diebold, Gunther & Tay (1998).
//
// © 2026 InferredSignals · MPL 2.0 · credit InferredSignals if you reuse.
// ══════════════════════════════════════════════════════════════════════════
//
//
//@version=6
indicator("Options Probabilistic Bounds [InferredSignals]", overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=1200)

// ───────────── DISPLAY MODE ─────────────
grp_display = "Display mode"
display_mode = input.string("LIVE", "Anchor mode", options=["LIVE", "D-1", "D-2", "D-3", "D-4", "D-5"], group=grp_display, tooltip="Where the projected corridor starts. LIVE = anchored to today's close. D-1…D-5 = freeze the corridor as it looked N days ago, calibrated only on the data known back then (strict no look-ahead) — handy to check how past corridors actually held.")
display_offset = display_mode == "LIVE" ? 0 : display_mode == "D-1" ? 1 : display_mode == "D-2" ? 2 : display_mode == "D-3" ? 3 : display_mode == "D-4" ? 4 : 5

ignore_earnings = input.bool(true, "Ignore Earnings Gap", group=grp_display, tooltip="ON (recommended): on an earnings day and the day after, the price jump is set aside so a single earnings surprise can't distort the volatility estimate. Those bars stay on the chart — they are only skipped when measuring the stock's normal volatility.")

// ───────────── INPUTS ─────────────
grp_main   = "Main"
horizon    = input.int(5,    "Horizon (days)",            minval=1, maxval=20, group=grp_main , display=display.none, tooltip="How many trading days ahead the corridor is projected (1–20).")
conf_pct   = input.float(95.0, "Confidence level (%)",    minval=50.0, maxval=99.5, step=0.5, group=grp_main, tooltip="How much of the likely price action the corridor tries to contain. 95% = the CLOSING price at each horizon day is expected to finish inside about 95% of the time (≈2.5% chance of closing past each side). Endpoint coverage per horizon — not the chance the whole path stays inside (read the No-Touch figures for that).")

grp_adv    = "Advanced (defaults are robust research-oriented)"
lookback   = input.int(252,   "Calibration window (days)", minval=126, maxval=756, group=grp_adv, display=display.none, tooltip="How much history the model learns from. 252 ≈ one trading year. Longer = steadier but slower to adapt; shorter = more reactive but noisier.")
gamma_ratio= input.float(0.4, "RV coupling γ = γ_ratio·α",       minval=0.0, maxval=2.0, step=0.1, group=grp_adv , display=display.none, tooltip="How much the day's high-low range (not just the close) feeds the volatility estimate, as a multiple of the main reaction speed α. Higher = the corridor reacts more to wide-range days. 0 = use closes only.")
use_acorr  = input.bool(true, "Use shrunk Lo-MacKinlay autocorr", group=grp_adv , display=display.none, tooltip="ON (recommended): adjusts the multi-day width for any tendency of daily moves to trend or mean-revert (autocorrelation), shrunk toward zero so noise does not inflate the corridor.")
lev_asym   = input.bool(true, "Leverage-asymmetric bands", group=grp_adv, tooltip="ON (recommended): stocks tend to drop faster than they climb, so the corridor is widened more on the DOWNSIDE than the upside, by a data-driven amount (the semivariance ratio ψ). OFF = same width on both sides. A/B tip: run OFF then ON and check the backtest only widens the side that needs it.")
use_component = input.bool(true, "Two-component variance (V2)", group=grp_adv, tooltip="ON (recommended): volatility is modelled as a slow normal level plus a fast shock component, so after a big move the corridor calms down over a few days instead of staying wide for weeks. OFF = single-speed volatility (simpler; kept for comparison and as a safe fallback).")
lr_halflife = input.int(42, "Long-run half-life (days)", minval=10, maxval=120, group=grp_adv, tooltip="How slowly the normal volatility level drifts. Higher = a stickier normal level, so the corridor tightens back FASTER after a shock. This is the MAIN dial for post-shock corridor width. Only used when Two-component variance is ON. ~42d ≈ one quarter.", display=display.none)
diag_mode  = input.string("None", "Diagnostic display", options=["None", "Detailed"], group=grp_adv , display=display.none)
trend_win  = input.int(63, "Trend gauge window (days)", minval=10, maxval=252, group=grp_adv, display=display.none, tooltip="Lookback for the Trend (drift) gauge shown in the diagnostic box. It is a t-statistic of the recent drift, squashed to [-1,+1] — a DESCRIPTIVE read of which side has lately had a drift tailwind (a cushion). It does NOT touch the bands: the corridor stays strictly drift-neutral (μ=0). It is NOT a forecast — see the box note. Lower = more reactive.")

lambda_lr = math.pow(0.5, 1.0 / float(lr_halflife))   // EWMA decay for the long-run component τ

// ───────────── MAP grid search (per-ticker calibration) — FIXED AS CONSTANTS ─────────────
alpha_n    = 5
beta_n     = 5
delta_n    = 4
nu_grid_in = "3.5,4,5,6,7,10,15,30"

// ───────────── Bayesian priors (regularization) — FIXED AS CONSTANTS ─────────────
// In component mode the short-run runs on DEVIATIONS from τ, so its persistence ψ_s is
// targeted LOW and β much smaller than standard GARCH. β_prior 0.45 and p_target 0.60 are
// mutually consistent: ψ_s_prior = α(0.08)+δ/2(0.05)+β(0.45)+γ(~0.03) ≈ 0.61.
alpha_prior     = 0.08
beta_prior      = use_component ? 0.45 : 0.88
delta_prior     = 0.10
nu_prior        = 6.0
p_target        = use_component ? 0.60 : 0.96
p_cap           = 0.985
prior_strength  = 60.0   // λ_param
moment_strength = 80.0   // λ_mom

// ───────────── BACKTEST MODE (Monthly recalibration) ─────────────
grp_bt = "Backtest (Walk-Forward)"
backtest_on = input.bool(false, "Enable backtest mode", group=grp_bt, tooltip="Replays the model day by day through history and reports, in an added panel, how often the corridor actually contained the price. Every test day uses only the data available that day (no look-ahead). The model is re-fitted MONTHLY — a TradingView execution-speed limit, not a modelling choice. It is heavy and runs once, on the latest bar.")
recal_freq = "Monthly"
backtest_window = input.int(252, "Backtest window (days)", minval=1, maxval=252, group=grp_bt,  display=display.none, tooltip="How many past days the backtest checks. For each one it compares the predicted corridor with what the price actually did over the next backtest-horizon days.")
backtest_horizon = input.int(5, "Backtest horizon (days)", minval=1, maxval=20, group=grp_bt, display=display.none, tooltip="How many forward days the walk-forward panel reports (1–20). Extends the backtest beyond the default 5; the per-day band is computed by the same formula, the panel just reports more horizons. The PIT panel stays capped at 5 (overlap makes longer PIT horizons uninformative). Longer horizons are heavier and may approach TradingView's per-run time limit.")
tolerance_bp = input.float(0, "Tolerance (bp)", minval=0.0, maxval=200.0, step=5.0, group=grp_bt,  display=display.none, tooltip="A small buffer before a touch counts as a breach (1 bp = 0.01%), to ignore tiny insignificant pokes just past a band. 0 = count every breach.")

// ───────────── PIT CONDITIONAL DIAGNOSTIC (regime-split) ─────────────
grp_pit = "PIT Conditional Diagnostic (needs Backtest ON)"
show_pit    = input.bool(false, "Show PIT regime-split diagnostic", group=grp_pit, tooltip="Adds the sharpest calibration check (the PIT panel): is the corridor the RIGHT width — not too wide, not too narrow? Results are split between calm days and days right after a shock, so you can see whether the corridor gets over-cautious after big moves. Requires Backtest mode ON. Capped at horizon 5.")
pit_shock_k = input.float(2.0, "Shock threshold (σ, post-red)", minval=0.5, maxval=5.0, step=0.5, group=grp_pit, display=display.none, tooltip="What counts as a shock day in the PIT split: a down day larger than k times its own typical daily move (so it is comparable across stocks). k=2 ≈ a 2-sigma down day.")

// ───────────── STYLE (InferredSignals palette) ─────────────
grp_style    = "Style (InferredSignals palette)"
upper_color  = input.color(#4f7d75, "Upper band color",   group=grp_style)
lower_color  = input.color(#9b6a78, "Lower band color",   group=grp_style)
mid_color    = input.color(#8c8a8c, "Midline color",      group=grp_style)
line_width   = input.int(2,  "Line width",                     minval=1, maxval=8, group=grp_style,  display=display.none)
show_mid     = input.bool(true, "Show midline",                group=grp_style)
fill_on      = input.bool(true, "Fill between bands",          group=grp_style)
fill_color   = input.color(color.new(#8faea8, 60), "Fill color", group=grp_style)
label_bg_color   = input.color(color.new(#605a53, 0), "Diagnostic box background", group=grp_style)
label_text_color = input.color(#f2eee6, "Diagnostic box text color",   group=grp_style)
bt_bg_color      = input.color(color.new(#605a53, 0), "Backtest box background", group=grp_style)
bt_text_color    = input.color(#f2eee6, "Backtest box text color",    group=grp_style)
pit_bg_color     = input.color(color.new(#3f4a56, 0), "PIT box background", group=grp_style)
pit_text_color   = input.color(#f2eee6, "PIT box text color", group=grp_style)

grp_marks    = "Daily markers"
show_marks   = input.bool(true, "Show per-day markers",        group=grp_marks)
show_values  = input.bool(true, "Show per-day band values",    group=grp_marks)
mark_match_band = input.bool(true, "Markers use band colors",  group=grp_marks)
mark_color_up   = input.color(#4f7d75, "Upper marker color (when not matching)", group=grp_marks)
mark_color_dn   = input.color(#9b6a78, "Lower marker color (when not matching)", group=grp_marks)
show_vol_label  = input.bool(true, "Show annualized vol in zone", group=grp_marks, tooltip="Shows the annualised volatility (%) in the middle of the corridor — the forward 1-day volatility that drives its width. A normalised figure, handy to compare how hot two stocks are at a glance.")

// ───────────── PRECONDITION ─────────────
if timeframe.in_seconds() != timeframe.in_seconds("D")
    runtime.error("Use on Daily timeframe.")

// ───────────── DIVIDEND CORRECTION (always on) ─────────────
div_today = nz(request.dividends(syminfo.tickerid, dividends.gross, barmerge.gaps_on, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)

// Dividend events within the CALIBRATION WINDOW the model actually uses (anchored at the
// display bar), NOT the whole symbol history.
div_event_i      = div_today > 0 ? 1 : 0
n_div_win_series = math.sum(div_event_i, lookback)
n_div_total      = int(math.round(nz(n_div_win_series[display_offset], 0.0)))

// ───────────── EARNINGS GAP DETECTION ─────────────
eps_actual = request.earnings(syminfo.tickerid, earnings.actual, barmerge.gaps_on, barmerge.lookahead_off, ignore_invalid_symbol=true)
is_earnings_event = not na(eps_actual)

is_earnings_event_i = is_earnings_event ? 1 : 0
prev_is_event = nz(is_earnings_event_i[1], 0) == 1
is_gap_bar = ignore_earnings and (is_earnings_event or prev_is_event)

is_gap_bar_i = is_gap_bar ? 1 : 0

// Earnings events / neutralized bars within the CALIBRATION WINDOW the model actually uses
// (anchored at the display bar), NOT the whole symbol history.
n_earn_win_series = math.sum(is_earnings_event_i, lookback)
n_gap_win_series  = math.sum(is_gap_bar_i, lookback)
n_earnings_total  = int(math.round(nz(n_earn_win_series[display_offset], 0.0)))
n_gap_bars_total  = int(math.round(nz(n_gap_win_series[display_offset],  0.0)))

// Parse nu grid
parse_nu_grid(string s) =>
    arr = array.new<float>()
    parts = str.split(s, ",")
    n = array.size(parts)
    if n > 0
        for i = 0 to n - 1
            tok = str.trim(array.get(parts, i))
            v = str.tonumber(tok)
            if not na(v) and v >= 3.0
                array.push(arr, v)
    if array.size(arr) == 0
        array.push(arr, 7.0)
    arr

var float[] nu_grid_arr = parse_nu_grid(nu_grid_in)

// Recalibration interval (bars between recals) — Monthly forced
recal_interval = 21

// ───────────── 1. RETURNS (div-corrected, non-finite-sanitized) ─────────────
// A non-finite daily log return is information-free and must never reach a
// moment estimator: bar 0 gives nz(close[1])=0 ⇒ log(·/0)=+inf, and a halted /
// illiquid day can leave an na close. Both are neutralised to 0 here — the same
// treatment as a gap bar — which protects σ²_LT, the GARCH recursion, the
// residual pool AND the Lo-MacKinlay autocovariance in one place. (|r|>20 in
// log space is ~e²⁰≈5×10⁸×: never a real daily move, always a data artefact.)
ret_cc_raw = math.log((close + div_today) / nz(close[1]))
ret_cc = (na(ret_cc_raw) or math.abs(ret_cc_raw) > 20.0) ? 0.0 : ret_cc_raw
ret_recursion = is_gap_bar ? 0.0 : ret_cc

// ───────────── 1b. TREND / DRIFT GAUGE (live, [-1..+1], descriptive — NOT in the bands) ─────────────
// A squashed t-statistic of the recent drift. μ is NEVER added to the corridor (the bands stay
// drift-neutral by construction — §1/§6). This is a READOUT only: it reports which side has
// lately had a drift tailwind (a cushion), so a put/call seller can see which leg currently sits
// with the trend — WITHOUT re-injecting the noisy μ estimate into the band scale. Squashed via
// tanh because only the SIGN+STRENGTH of the drift t-stat is wanted, not a calibrated magnitude.
// ret_recursion is earnings-clean. tanh is NOT a Pine v6 built-in, so it is expanded in closed
// form (clamped to avoid math.exp overflow; tanh saturates well before |x|=20).
f_tanh(float x) =>
    float xc = math.max(-20.0, math.min(20.0, x))
    float e2 = math.exp(2.0 * xc)
    (e2 - 1.0) / (e2 + 1.0)

mu_hat_trend = ta.sma(ret_recursion, trend_win)
sd_ret_trend = math.max(ta.stdev(ret_recursion, trend_win), 1e-9)
t_drift      = mu_hat_trend * math.sqrt(trend_win) / sd_ret_trend   // drift t-statistic (≈ sign-test)
trend_score  = f_tanh(t_drift / 2.0)                               // squash → [-1, +1]; /2 sets sensitivity
trend_disp   = nz(trend_score[display_offset], nz(trend_score, 0.0))   // align with LIVE / D-1…D-5

// ───────────── 2. REALIZED VARIANCE PROXY (single-bar YZ-style feed) ─────────────
ln_oc1 = math.log((open + div_today) / nz(close[1]))
ln_co  = math.log(close / open)
ln_hc  = math.log(high / close)
ln_ho  = math.log(high / open)
ln_lc  = math.log(low  / close)
ln_lo  = math.log(low  / open)
rs_t   = ln_hc * ln_ho + ln_lc * ln_lo

rv_today = math.max(rs_t + ln_oc1*ln_oc1 + ln_co*ln_co * 0.34, 1e-12)

// ───────────── 3. UNCONDITIONAL VARIANCE TARGET (cleaned + shifted) ─────────────
sigma2_lt_full = math.max(ta.variance(ret_recursion, lookback), 1e-12)
sigma2_lt      = math.max(nz(sigma2_lt_full[display_offset], sigma2_lt_full), 1e-12)

rv_recursion = is_gap_bar ? sigma2_lt : rv_today

// ───────────── 3b. REALIZED LONG-RUN VARIANCE COMPONENT τ (EWMA of YZ-RV) ─────────────
// τ_t uses RV_{t-1} only → σ²_t stays F_{t-1}-measurable (no look-ahead). Earnings are
// neutralized for τ as well (rv_recursion = σ²_LT on gap bars). With use_component OFF, τ
// falls back to the rolling unconditional variance (single-component behaviour).
var float tau_ewma = na
tau_ewma := na(tau_ewma[1]) ? math.max(nz(rv_recursion, 1e-12), 1e-12) : math.max(lambda_lr * tau_ewma[1] + (1.0 - lambda_lr) * nz(rv_recursion[1], tau_ewma[1]), 1e-14)
tau = use_component ? tau_ewma : sigma2_lt_full
// Forward anchor τ_{anchor+1} (one EWMA step fwd from the display anchor bar), held flat over horizon.
tau_J_anchor = math.max(nz(tau[display_offset], sigma2_lt), 1e-14)
rv_J_anchor  = nz(rv_recursion[display_offset], sigma2_lt)
tau_anchor   = use_component ? math.max(lambda_lr * tau_J_anchor + (1.0 - lambda_lr) * rv_J_anchor, 1e-14) : tau_J_anchor

// ───────────── 4. STUDENT-T LOG-DENSITY HELPER ─────────────
f_lgamma(float z) =>
    float zz = z
    float shift = 0.0
    if zz < 1.0
        shift := -math.log(zz)
        zz := zz + 1.0
    half_log_2pi = 0.5 * math.log(2.0 * 3.14159265358979)
    res = (zz - 0.5) * math.log(zz) - zz + half_log_2pi + 1.0/(12.0*zz) - 1.0/(360.0*zz*zz*zz)
    res + shift

// ───────────── 4b. INVERSE QUANTILES + ROBUST WINSORISATION ─────────────
inv_norm(float p) =>
    a1 = -3.969683028665376e+01
    a2 =  2.209460984245205e+02
    a3 = -2.759285104469687e+02
    a4 =  1.383577518672690e+02
    a5 = -3.066479806614716e+01
    a6 =  2.506628277459239e+00
    b1 = -5.447609879822406e+01
    b2 =  1.615858368580409e+02
    b3 = -1.556989798598866e+02
    b4 =  6.680131188771972e+01
    b5 = -1.328068155288572e+01
    c1 = -7.784894002430293e-03
    c2 = -3.223964580411365e-01
    c3 = -2.400758277161838e+00
    c4 = -2.549732539343734e+00
    c5 =  4.374664141464968e+00
    c6 =  2.938163982698783e+00
    d1 =  7.784695709041462e-03
    d2 =  3.224671290700398e-01
    d3 =  2.445134137142996e+00
    d4 =  3.754408661907416e+00
    plow  = 0.02425
    phigh = 1.0 - plow
    float q = 0.0
    float r = 0.0
    float z = 0.0
    if p < plow
        q := math.sqrt(-2.0 * math.log(p))
        z := (((((c1*q+c2)*q+c3)*q+c4)*q+c5)*q+c6) / ((((d1*q+d2)*q+d3)*q+d4)*q+1.0)
    else if p <= phigh
        q := p - 0.5
        r := q * q
        z := (((((a1*r+a2)*r+a3)*r+a4)*r+a5)*r+a6)*q / (((((b1*r+b2)*r+b3)*r+b4)*r+b5)*r+1.0)
    else
        q := math.sqrt(-2.0 * math.log(1.0 - p))
        z := -(((((c1*q+c2)*q+c3)*q+c4)*q+c5)*q+c6) / ((((d1*q+d2)*q+d3)*q+d4)*q+1.0)
    z

inv_t_standardized(float p, float nu) =>
    z = inv_norm(p)
    if nu >= 100.0
        z
    else
        z2 = z * z
        z3 = z * z2
        z5 = z3 * z2
        t_q = z + (z3 + z) / (4.0 * nu) + (5.0*z5 + 16.0*z3 + 3.0*z) / (96.0 * nu * nu) + (3.0*z*z*z5 + 19.0*z5 + 17.0*z3 - 15.0*z) / (384.0 * nu*nu*nu)
        nu_safe = math.max(nu, 2.5)
        t_q * math.sqrt((nu_safe - 2.0) / nu_safe)

WINSOR_TAIL_P = 0.0025
f_winsor_c(float nu) =>
    inv_t_standardized(1.0 - WINSOR_TAIL_P, nu)

f_winsor_r2(float r_prev, float s2_prev, float c_nu) =>
    r2 = r_prev * r_prev
    s2_safe = math.max(s2_prev, 1e-14)
    thr_var = c_nu * c_nu * s2_safe
    float out = r2
    if r2 > thr_var
        az = math.abs(r_prev) / math.sqrt(s2_safe)
        out := (c_nu*c_nu + 2.0*c_nu*(az - c_nu)) * s2_prev
    out

// ───────────── 5. "LIVE" RECURSION (cleaned, deviation form) ─────────────
alpha_default = 0.08
beta_default  = use_component ? 0.45 : 0.88
delta_default = 0.10
gamma_default = gamma_ratio * alpha_default

var float sigma2_live = 0.0
seed_var = ta.variance(ret_recursion, 30)
c_nu_default = f_winsor_c(nu_prior)
if bar_index < 30
    sigma2_live := seed_var
else
    r_prev1   = nz(ret_recursion[1])
    rv_prev1  = nz(rv_recursion[1], seed_var)
    leverage1 = r_prev1 < 0 ? 1.0 : 0.0
    s2_prev_live = nz(sigma2_live[1], seed_var)
    tau_prev1 = nz(tau[1], seed_var)
    tau_now1  = nz(tau, seed_var)
    r2_eff_live  = f_winsor_r2(r_prev1, s2_prev_live, c_nu_default)
    sigma2_live := tau_now1 + (alpha_default + delta_default * leverage1) * (r2_eff_live - tau_prev1) + beta_default * (s2_prev_live - tau_prev1) + gamma_default * (rv_prev1 - tau_prev1)
    sigma2_live := math.max(sigma2_live, 1e-12)

// ───────────── 6. MAP OBJECTIVE (earnings-aware, offset-parameterized, deviation form) ─────────────
f_objective(float a, float b, float d, float nu, simple int N, float[] pc_rprev, float[] pc_rvprev, float[] pc_tauprev, float[] pc_taunow, float[] pc_levprev, float[] pc_rnow, bool[] pc_gap) =>
    g = gamma_ratio * a
    p = a + 0.5*d + b + g
    float nlp_out = na
    float rq_out  = 1e10
    if p >= p_cap or p < 0.0 or a < 0.0 or b < 0.0 or d < 0.0 or nu < 3.0
        nlp_out := 1e10
        rq_out  := 1e10
    else
        float s2 = array.get(pc_tauprev, N - 1)
        float ll = 0.0
        float sum_z   = 0.0
        float sum_z2  = 0.0
        float sum_z3  = 0.0
        float sum_z4  = 0.0
        int   n_eff   = 0
        BURN_IN = 30
        c_nu_obj = f_winsor_c(nu)
        nu_safe_o  = math.max(nu, 2.5)
        half_nu1_o = (nu_safe_o + 1.0) / 2.0
        t_norm_o   = f_lgamma(half_nu1_o) - f_lgamma(nu_safe_o / 2.0) - 0.5 * math.log(3.14159265358979 * (nu_safe_o - 2.0))
        inv_num2_o = 1.0 / (nu_safe_o - 2.0)
        for i = N - 1 to 0
            r_prev   = array.get(pc_rprev, i)
            rv_prev  = array.get(pc_rvprev, i)
            tau_prev = array.get(pc_tauprev, i)
            tau_now  = array.get(pc_taunow, i)
            lev_prev = array.get(pc_levprev, i)
            r2_eff = f_winsor_r2(r_prev, s2, c_nu_obj)
            s2 := tau_now + (a + d * lev_prev) * (r2_eff - tau_prev) + b * (s2 - tau_prev) + g * (rv_prev - tau_prev)
            s2 := math.max(s2, 1e-14)

            is_gap_now = array.get(pc_gap, i)
            if not is_gap_now
                r_now = array.get(pc_rnow, i)
                z_std = r_now / math.sqrt(s2)
                if i <= N - 1 - BURN_IN
                    z2 = z_std * z_std
                    ll := ll + (t_norm_o - half_nu1_o * math.log(1.0 + z2 * inv_num2_o)) - 0.5 * math.log(s2)
                    sum_z  += z_std
                    sum_z2 += z2
                    sum_z3 += z2 * z_std
                    sum_z4 += z2 * z2
                    n_eff  += 1

        float mean_z = n_eff > 0 ? sum_z / n_eff : 0.0
        float var_z  = n_eff > 0 ? sum_z2 / n_eff - mean_z*mean_z : 1.0
        float sd_z   = math.sqrt(math.max(var_z, 1e-9))
        float m3 = n_eff > 0 ? sum_z3 / n_eff - 3*mean_z*var_z - mean_z*mean_z*mean_z : 0.0
        float m4 = n_eff > 0 ? sum_z4 / n_eff - 4*mean_z*(sum_z3/n_eff) + 6*mean_z*mean_z*(sum_z2/n_eff) - 3*mean_z*mean_z*mean_z*mean_z : 0.0
        float skew_z = sd_z > 0 ? m3 / (sd_z*sd_z*sd_z) : 0.0
        float kurt_z = sd_z > 0 ? m4 / (sd_z*sd_z*sd_z*sd_z) - 3.0 : 0.0

        float kurt_target = nu > 4.5 ? 6.0 / (nu - 4.0) : 15.0

        prior_a  = prior_strength * math.pow(a - alpha_prior, 2)
        prior_b  = prior_strength * math.pow(b - beta_prior,  2)
        prior_d  = prior_strength * math.pow(d - delta_prior, 2)
        prior_p  = prior_strength * 2.0 * math.pow(p - p_target, 2)
        log_nu_centered = math.log(math.max(nu - 2.0, 0.1)) - math.log(math.max(nu_prior - 2.0, 0.1))
        prior_nu = prior_strength * 0.6 * log_nu_centered * log_nu_centered

        pen_var  = moment_strength * math.pow(var_z - 1.0, 2)
        pen_skew = moment_strength * skew_z * skew_z
        pen_kurt = moment_strength * math.pow((kurt_z - kurt_target) / math.max(1.0, kurt_target), 2)

        log_prior_full = prior_a + prior_b + prior_d + prior_p + prior_nu + pen_var + pen_skew + pen_kurt
        nlp_out := -ll + log_prior_full

        rq_out := math.abs(skew_z) + math.abs(kurt_z - kurt_target) / math.max(1.0, kurt_target) + 2.0 * math.abs(var_z - 1.0)
    [nlp_out, rq_out]

// ───────────── 7. FULL CALIBRATION ROUTINE (reusable for live + backtest) ─────────────
// β grid is widened DOWN in component mode so the short-run can mean-revert fast (ψ_s low).
f_full_calibration(int offset_K, float sigma2_lt_K) =>
    A_LO_L = 0.02
    A_HI_L = 0.15
    B_LO_L = use_component ? 0.30 : 0.75
    B_HI_L = use_component ? 0.90 : 0.93
    D_LO_L = 0.00
    D_HI_L = 0.30

    float ba = alpha_default
    float bb = beta_default
    float bd = delta_default
    float bn = 7.0
    float bnlp = 1e10
    float brq  = 1e10
    int   bst  = 0

    nu_n = array.size(nu_grid_arr)

    // Precompute the parameter-INDEPENDENT per-bar series reads ONCE per offset; f_objective
    // replays them via array.get (bit-identical floats, no recomputation). Loop bound is the
    // simple-int `lookback` — a fixed iteration count, no dynamic series-int bound.
    float[] pc_rprev   = array.new<float>()
    float[] pc_rvprev  = array.new<float>()
    float[] pc_tauprev = array.new<float>()
    float[] pc_taunow  = array.new<float>()
    float[] pc_levprev = array.new<float>()
    float[] pc_rnow    = array.new<float>()
    bool[]  pc_gap     = array.new<bool>()
    for ii = 0 to lookback - 1
        float rprev_ii = nz(ret_recursion[ii + 1 + offset_K])
        array.push(pc_rprev,   rprev_ii)
        array.push(pc_rvprev,  nz(rv_recursion[ii + 1 + offset_K], sigma2_lt_K))
        array.push(pc_tauprev, nz(tau[ii + 1 + offset_K], sigma2_lt_K))
        array.push(pc_taunow,  nz(tau[ii + offset_K], sigma2_lt_K))
        array.push(pc_levprev, rprev_ii < 0 ? 1.0 : 0.0)
        array.push(pc_rnow,    nz(ret_cc[ii + offset_K]))
        array.push(pc_gap,     nz(is_gap_bar_i[ii + offset_K], 0) == 1)

    for start_idx = 1 to 3
        float cnlp = 1e10
        float ca = alpha_default
        float cb = beta_default
        float cd = delta_default
        float cn = 7.0

        float as_lo = 0.0
        float as_hi = 0.0
        float bs_lo = 0.0
        float bs_hi = 0.0
        float ds_lo = 0.0
        float ds_hi = 0.0
        if start_idx == 1
            as_lo := 0.03
            as_hi := 0.12
            bs_lo := use_component ? 0.30 : 0.82
            bs_hi := use_component ? 0.55 : 0.92
            ds_lo := 0.02
            ds_hi := 0.16
        else if start_idx == 2
            as_lo := 0.06
            as_hi := 0.15
            bs_lo := use_component ? 0.50 : 0.75
            bs_hi := use_component ? 0.72 : 0.88
            ds_lo := 0.06
            ds_hi := 0.30
        else
            as_lo := 0.02
            as_hi := 0.08
            bs_lo := use_component ? 0.68 : 0.86
            bs_hi := use_component ? 0.90 : 0.94
            ds_lo := 0.00
            ds_hi := 0.10

        a_step_c = (as_hi - as_lo) / (alpha_n - 1)
        b_step_c = (bs_hi - bs_lo) / (beta_n  - 1)
        d_step_c = (ds_hi - ds_lo) / (delta_n - 1)

        for ia = 0 to alpha_n - 1
            for ib = 0 to beta_n - 1
                for id = 0 to delta_n - 1
                    for inu = 0 to nu_n - 1
                        a_try = as_lo + ia * a_step_c
                        b_try = bs_lo + ib * b_step_c
                        d_try = ds_lo + id * d_step_c
                        nu_try = array.get(nu_grid_arr, inu)
                        [nlp, _rq] = f_objective(a_try, b_try, d_try, nu_try, lookback, pc_rprev, pc_rvprev, pc_tauprev, pc_taunow, pc_levprev, pc_rnow, pc_gap)
                        if nlp < cnlp
                            cnlp := nlp
                            ca := a_try
                            cb := b_try
                            cd := d_try
                            cn := nu_try

        a_lo_f = math.max(A_LO_L, ca - a_step_c)
        a_hi_f = math.min(A_HI_L, ca + a_step_c)
        b_lo_f = math.max(B_LO_L, cb - b_step_c)
        b_hi_f = math.min(B_HI_L, cb + b_step_c)
        d_lo_f = math.max(D_LO_L, cd - d_step_c)
        d_hi_f = math.min(D_HI_L, cd + d_step_c)

        a_step_f = (a_hi_f - a_lo_f) / 4.0
        b_step_f = (b_hi_f - b_lo_f) / 4.0
        d_step_f = (d_hi_f - d_lo_f) / 2.0

        for ia = 0 to 4
            for ib = 0 to 4
                for id = 0 to 2
                    a_try = a_lo_f + ia * a_step_f
                    b_try = b_lo_f + ib * b_step_f
                    d_try = d_lo_f + id * d_step_f
                    [nlp, _rq] = f_objective(a_try, b_try, d_try, cn, lookback, pc_rprev, pc_rvprev, pc_tauprev, pc_taunow, pc_levprev, pc_rnow, pc_gap)
                    if nlp < cnlp
                        cnlp := nlp
                        ca := a_try
                        cb := b_try
                        cd := d_try

        [_nlp_final, rq_final] = f_objective(ca, cb, cd, cn, lookback, pc_rprev, pc_rvprev, pc_tauprev, pc_taunow, pc_levprev, pc_rnow, pc_gap)

        if rq_final < brq
            brq    := rq_final
            bnlp   := cnlp
            ba := ca
            bb := cb
            bd := cd
            bn := cn
            bst := start_idx

    [ba, bb, bd, bn, bnlp, brq, bst]

// ───────────── 7a-bis. BISECT-RIGHT HELPER ─────────────
// Returns #{elements ≤ v} in an ascending-sorted array = the insertion index just AFTER any
// elements equal to v (classic bisect_right). Used to count ≤ z in f_pot_cdf's body branch in
// O(log n), to keep sorted_resid ordered by binary-search insertion, and to locate the
// rightmost instance of an aged-out residual for removal from the rolling window.
f_bisect_right(float[] arr, float v) =>
    int lo = 0
    int hi = array.size(arr)
    while lo < hi
        int mid = int((lo + hi) / 2)
        if array.get(arr, mid) <= v
            lo := mid + 1
        else
            hi := mid
    lo

// ───────────── 7b. EVT / POT TAIL QUANTILE (Generalized Pareto, Probability-Weighted Moments) ─────────────
GPD_THRESH_P = 0.10    // outer 10% of each tail is GPD-modeled (fixed POT threshold used here)
XI_FLOOR     = 0.00    // floor ξ ≥ 0 on BOTH tails: equity residuals are fat-tailed, never bounded; ξ=0 degrades gracefully to the exponential tail, so the downside band can never thin below it (deliberate over-reservation for the short-put seller).
XI_CEIL      = 0.50    // ceil ξ (equity-residual range; PWM at ~25 exceedances is noisy, cap the extrapolation)

f_pot_quantile(float[] sorted_asc, float p) =>
    int n = array.size(sorted_asc)
    float q_out  = na
    float xi_out = na
    int   ne_out = 0
    if n >= 50
        if p >= GPD_THRESH_P and p <= 1.0 - GPD_THRESH_P
            pos = p * (n - 1)
            i0  = math.floor(pos)
            i1  = math.min(i0 + 1, n - 1)
            w   = pos - i0
            q_out := array.get(sorted_asc, i0) * (1.0 - w) + array.get(sorted_asc, i1) * w
        else
            bool lower_tail = p < 0.5
            u_prob = lower_tail ? GPD_THRESH_P : 1.0 - GPD_THRESH_P
            pos_u  = u_prob * (n - 1)
            iu0    = math.floor(pos_u)
            iu1    = math.min(iu0 + 1, n - 1)
            wu     = pos_u - iu0
            u      = array.get(sorted_asc, iu0) * (1.0 - wu) + array.get(sorted_asc, iu1) * wu
            // PWM (Hosking-Wallis) accumulators. Exceedances are visited in DESCENDING magnitude
            // (sorted_asc is sorted, so the excesses are monotone), hence at each step `ne`
            // already equals the rank weight of the current excess ⇒ s_rank = Σ rank·y is built
            // in ONE pass with no extra sort. `sy` doubles as a0 = mean excess.
            float sy     = 0.0
            float s_rank = 0.0
            int   ne     = 0
            if lower_tail
                for k = 0 to n - 1
                    xk = array.get(sorted_asc, k)
                    if xk >= u
                        break
                    y = u - xk
                    sy     += y
                    s_rank += ne * y
                    ne     += 1
            else
                for k = n - 1 to 0
                    xk = array.get(sorted_asc, k)
                    if xk <= u
                        break
                    y = xk - u
                    sy     += y
                    s_rank += ne * y
                    ne     += 1
            ne_out := ne
            if ne < 10
                pos = p * (n - 1)
                i0  = math.floor(pos)
                i1  = math.min(i0 + 1, n - 1)
                w   = pos - i0
                q_out := array.get(sorted_asc, i0) * (1.0 - w) + array.get(sorted_asc, i1) * w
            else
                // PWM closed form (Hosking-Wallis 1987), ξ in the SAME convention as the GPD
                // survival law used in f_pot_cdf: a0 = mean excess, a1 = rank-weighted PWM,
                //   ξ̂ = 2 − a0/(a0 − 2·a1),   β̂ = 2·a0·a1/(a0 − 2·a1).
                // denom = a0 − 2·a1 > 0 for any valid GPD (ξ<1); the guard falls back to the
                // ξ=0 exponential (β̂ = a0) on a degenerate sample.
                m  = sy / ne
                a1 = s_rank / (ne * (ne - 1))
                float denom = m - 2.0 * a1
                float xi = denom > 1e-12 ? 2.0 - m / denom : 0.0
                xi := math.max(XI_FLOOR, math.min(XI_CEIL, xi))
                float beta = denom > 1e-12 ? math.max(2.0 * m * a1 / denom, 1e-8) : math.max(m, 1e-8)
                p_tail = lower_tail ? p : 1.0 - p
                ratio  = (float(n) / ne) * p_tail
                float y_q = math.abs(xi) > 1e-6 ? (beta / xi) * (math.pow(ratio, -xi) - 1.0) : -beta * math.log(ratio)
                q_out  := lower_tail ? u - y_q : u + y_q
                xi_out := xi
    [q_out, xi_out, ne_out]

// ───────────── 7b-bis. EVT / POT CDF (inverse of f_pot_quantile under the same law) ─────────────
// Returns P(Z ≤ z) under the SAME spliced law that draws the bands: empirical (FHS) in the
// inner body, GPD (POT, PWM) in the outer GPD_THRESH_P tails. The PWM estimator is bit-for-bit
// the one in f_pot_quantile — the GPD tails are exact inverses of the band quantiles; the
// empirical body matches the interpolated quantile to within 1/n. Used only by the PIT
// diagnostic.
f_pot_cdf(float[] sorted_asc, float z) =>
    int n = array.size(sorted_asc)
    float p_out = na
    if n >= 50
        pos_ul = GPD_THRESH_P * (n - 1)
        iul0   = math.floor(pos_ul)
        iul1   = math.min(iul0 + 1, n - 1)
        wul    = pos_ul - iul0
        u_lo   = array.get(sorted_asc, iul0) * (1.0 - wul) + array.get(sorted_asc, iul1) * wul
        pos_uh = (1.0 - GPD_THRESH_P) * (n - 1)
        iuh0   = math.floor(pos_uh)
        iuh1   = math.min(iuh0 + 1, n - 1)
        wuh    = pos_uh - iuh0
        u_hi   = array.get(sorted_asc, iuh0) * (1.0 - wuh) + array.get(sorted_asc, iuh1) * wuh
        if z >= u_lo and z <= u_hi
            int cnt_le = f_bisect_right(sorted_asc, z)
            p_out := cnt_le / float(n)
        else if z < u_lo
            // PWM — identical estimator to f_pot_quantile (one pass, rank-weighted).
            float sy     = 0.0
            float s_rank = 0.0
            int   ne     = 0
            for k = 0 to n - 1
                xk = array.get(sorted_asc, k)
                if xk >= u_lo
                    break
                yk      = u_lo - xk
                sy     += yk
                s_rank += ne * yk
                ne     += 1
            if ne < 10
                int cntf = 0
                for k = 0 to n - 1
                    if array.get(sorted_asc, k) <= z
                        cntf += 1
                p_out := cntf / float(n)
            else
                m  = sy / ne
                a1 = s_rank / (ne * (ne - 1))
                float denom = m - 2.0 * a1
                float xi = denom > 1e-12 ? 2.0 - m / denom : 0.0
                xi := math.max(XI_FLOOR, math.min(XI_CEIL, xi))
                float beta = denom > 1e-12 ? math.max(2.0 * m * a1 / denom, 1e-8) : math.max(m, 1e-8)
                yq   = u_lo - z
                surv = math.abs(xi) > 1e-6 ? math.pow(math.max(1.0 + xi * yq / beta, 1e-9), -1.0 / xi) : math.exp(-yq / beta)
                p_out := (float(ne) / n) * surv
        else
            // PWM — same estimator as the lower branch / f_pot_quantile.
            float sy     = 0.0
            float s_rank = 0.0
            int   ne     = 0
            for k = n - 1 to 0
                xk = array.get(sorted_asc, k)
                if xk <= u_hi
                    break
                yk      = xk - u_hi
                sy     += yk
                s_rank += ne * yk
                ne     += 1
            if ne < 10
                int cntf = 0
                for k = 0 to n - 1
                    if array.get(sorted_asc, k) <= z
                        cntf += 1
                p_out := cntf / float(n)
            else
                m  = sy / ne
                a1 = s_rank / (ne * (ne - 1))
                float denom = m - 2.0 * a1
                float xi = denom > 1e-12 ? 2.0 - m / denom : 0.0
                xi := math.max(XI_FLOOR, math.min(XI_CEIL, xi))
                float beta = denom > 1e-12 ? math.max(2.0 * m * a1 / denom, 1e-8) : math.max(m, 1e-8)
                yq   = z - u_hi
                surv = math.abs(xi) > 1e-6 ? math.pow(math.max(1.0 + xi * yq / beta, 1e-9), -1.0 / xi) : math.exp(-yq / beta)
                p_out := 1.0 - (float(ne) / n) * surv
    math.max(1e-6, math.min(1.0 - 1e-6, nz(p_out, 0.5)))

// ── PIT row formatter (global; Pine forbids nested function defs) ──
f_pit_row(int[] n_, float[] su_, float[] su2_, int[] lo_, int[] hi_, int h) =>
    nh = array.get(n_, h - 1)
    string row = ""
    if nh < 1
        row := "  " + str.tostring(h) + " │  —  │   —  │   —  │   —  │   —"
    else
        meanp = array.get(su_,  h - 1) / nh
        varp  = array.get(su2_, h - 1) / nh - meanp * meanp
        Dp    = varp * 12.0
        lop   = 100.0 * array.get(lo_, h - 1) / nh
        hip   = 100.0 * array.get(hi_, h - 1) / nh
        npad  = nh < 10 ? "  " : nh < 100 ? " " : ""
        lpad  = lop < 10.0 ? " " : ""
        upad  = hip < 10.0 ? " " : ""
        row := "  " + str.tostring(h) + " │ " + npad + str.tostring(nh) + " │ " + str.tostring(meanp, "0.00") + " │ " + str.tostring(Dp, "0.00") + " │ " + lpad + str.tostring(lop, "0.0") + " │ " + upad + str.tostring(hip, "0.0")
    row

// ───────────── 7c. LEVERAGE-ASYMMETRY ψ (realized semivariance ratio) ─────────────
PSI_MIN_RED   = 30
prev_red_psi  = nz(ret_recursion[1]) < 0
sv_up_postred = (prev_red_psi and ret_recursion > 0) ? ret_recursion * ret_recursion : 0.0
sv_dn_postred = (prev_red_psi and ret_recursion < 0) ? ret_recursion * ret_recursion : 0.0
red_day_psi_i = prev_red_psi ? 1.0 : 0.0
sv_up_uncond  = ret_recursion > 0 ? ret_recursion * ret_recursion : 0.0
sv_dn_uncond  = ret_recursion < 0 ? ret_recursion * ret_recursion : 0.0

sum_sv_up_pr = ta.sma(sv_up_postred, lookback)
sum_sv_dn_pr = ta.sma(sv_dn_postred, lookback)
n_red_win    = ta.sma(red_day_psi_i, lookback) * lookback
sum_sv_up_un = ta.sma(sv_up_uncond, lookback)
sum_sv_dn_un = ta.sma(sv_dn_uncond, lookback)

psi_cond   = sum_sv_dn_pr > 1e-12 ? sum_sv_up_pr / sum_sv_dn_pr : 1.0
psi_uncond = sum_sv_dn_un > 1e-12 ? sum_sv_up_un / sum_sv_dn_un : 1.0
psi_raw    = n_red_win >= PSI_MIN_RED ? psi_cond : psi_uncond
psi_full   = math.max(0.0, math.min(1.0, nz(psi_raw, 1.0)))
n_red_full = n_red_win

// ───────────── 8. MULTI-START CALIBRATION (LIVE at display_offset) ─────────────
var float best_alpha = alpha_default
var float best_beta  = beta_default
var float best_delta = delta_default
var float best_nu    = 7.0
var float best_nlp   = 1e10
var float best_rq    = 1e10
var int   best_start = 0
var float sigma2_t_calibrated   = na
var float sigma2_tp1_calibrated = na
var float sigma2_up_tp1_calibrated = na
var float psi_live          = na
var float n_red_live        = na
var int   n_winsor_live = 0
var float c_nu_active   = na

var float fhs_q_lo  = na
var float fhs_q_hi  = na
var float fhs_skew  = na
var float fhs_kurt  = na
var int   fhs_n     = 0
var float fhs_var   = na

// ── POT / GPD tail quantiles (live) — primary decision object ──
var float pot_q_lo    = na
var float pot_q_hi    = na
var float gpd_xi_lo   = na
var float gpd_xi_hi   = na
var int   gpd_nexc_lo = 0
var int   gpd_nexc_hi = 0

// ═══ BACKTEST STATE ═══
var int   bt_n_J            = 0
var int[] bt_close_in       = array.new<int>(20, 0)
var int[] bt_notouch_up     = array.new<int>(20, 0)
var int[] bt_notouch_dn     = array.new<int>(20, 0)
var int[] bt_notouch_both   = array.new<int>(20, 0)
var int[] bt_breach_up      = array.new<int>(20, 0)
var int[] bt_breach_dn      = array.new<int>(20, 0)
var int   bt_n_recals       = 0
var float bt_psi_mean       = na   // mean ψ across recal segments (for the backtest box)

// ═══ PIT CONDITIONAL DIAGNOSTIC STATE (regime-split: shock vs normal, per h=1..5) ═══
var int[]   pit_n_sh   = array.from(0, 0, 0, 0, 0)
var float[] pit_su_sh  = array.from(0.0, 0.0, 0.0, 0.0, 0.0)
var float[] pit_su2_sh = array.from(0.0, 0.0, 0.0, 0.0, 0.0)
var int[]   pit_lo_sh  = array.from(0, 0, 0, 0, 0)
var int[]   pit_hi_sh  = array.from(0, 0, 0, 0, 0)
var int[]   pit_n_no   = array.from(0, 0, 0, 0, 0)
var float[] pit_su_no  = array.from(0.0, 0.0, 0.0, 0.0, 0.0)
var float[] pit_su2_no = array.from(0.0, 0.0, 0.0, 0.0, 0.0)
var int[]   pit_lo_no  = array.from(0, 0, 0, 0, 0)
var int[]   pit_hi_no  = array.from(0, 0, 0, 0, 0)

if barstate.islast and bar_index > lookback + 30 + display_offset
    [ba, bb, bd, bn, bnlp, brq, bst] = f_full_calibration(display_offset, sigma2_lt)
    best_alpha := ba
    best_beta  := bb
    best_delta := bd
    best_nu    := bn
    best_nlp   := bnlp
    best_rq    := brq
    best_start := bst

    // ═══ Reconstruct σ²_t with calibrated params + FHS residuals (live, deviation form) ═══
    g_cal     = gamma_ratio * best_alpha
    c_nu_cal  = f_winsor_c(best_nu)
    c_nu_active := c_nu_cal
    n_winsor_live := 0
    BURN_IN_FHS = 30
    // LIVE FHS/GPD window == backtest span. The recursion is seeded BURN_IN_FHS bars deeper
    // (at tau[lookback+BURN_IN_FHS]) and walks lookback+BURN_IN_FHS steps, but residuals are
    // collected ONLY for i <= lookback-1 — the most recent `lookback` bars, the SAME span as the
    // backtest's rolling [J .. J-lookback+1] window. The first BURN_IN_FHS steps are pure
    // σ²-convergence burn-in. The winsor counter is gated to the same i <= lookback-1 window so
    // "obs winsor." describes exactly the bars that drive the residuals.
    s2_walk = math.max(nz(tau[lookback + BURN_IN_FHS + display_offset], sigma2_lt), 1e-14)
    z_residuals = array.new<float>()
    for i = lookback + BURN_IN_FHS - 1 to 0
        r_prev  = nz(ret_recursion[i + 1 + display_offset])
        rv_prev = nz(rv_recursion[i + 1 + display_offset], sigma2_lt)
        tau_prev = nz(tau[i + 1 + display_offset], sigma2_lt)
        tau_now  = nz(tau[i + display_offset], sigma2_lt)
        lev_prev = r_prev < 0 ? 1.0 : 0.0
        r2_eff = f_winsor_r2(r_prev, s2_walk, c_nu_cal)
        if i <= lookback - 1 and r_prev*r_prev > c_nu_cal*c_nu_cal*s2_walk
            n_winsor_live := n_winsor_live + 1
        s2_walk := tau_now + (best_alpha + best_delta * lev_prev) * (r2_eff - tau_prev) + best_beta * (s2_walk - tau_prev) + g_cal * (rv_prev - tau_prev)
        s2_walk := math.max(s2_walk, 1e-14)

        is_gap_now = nz(is_gap_bar_i[i + display_offset], 0) == 1
        if not is_gap_now and i <= lookback - 1
            r_now = nz(ret_cc[i + display_offset])
            z_i = r_now / math.sqrt(s2_walk)
            array.push(z_residuals, z_i)
    sigma2_t_calibrated := s2_walk

    r_J_live   = nz(ret_recursion[display_offset])
    rv_J_live  = nz(rv_recursion[display_offset], sigma2_lt)
    lev_J_live = r_J_live < 0 ? 1.0 : 0.0
    r2_eff_J   = f_winsor_r2(r_J_live, s2_walk, c_nu_cal)
    dev_r2_J   = r2_eff_J - tau_J_anchor
    s2_base_next = tau_anchor + best_alpha * dev_r2_J + best_beta * (s2_walk - tau_J_anchor) + g_cal * (rv_J_live - tau_J_anchor)
    lev_incr_next = best_delta * lev_J_live * dev_r2_J
    psi_use_live = lev_asym ? math.max(0.0, math.min(1.0, nz(psi_full[display_offset], 1.0))) : 1.0
    // psi routes only the POSITIVE GJR increment to the upper band. On a calm red
    // day the increment is negative; routing it asymmetrically would make
    // sigma_up > sigma_dn (inverted). Guarding by sign keeps sigma_dn >= sigma_up always.
    lev_route_next = lev_incr_next > 0 ? psi_use_live * lev_incr_next : lev_incr_next
    psi_live      := psi_use_live
    n_red_live    := nz(n_red_full[display_offset], n_red_full)
    sigma2_tp1_calibrated    := math.max(s2_base_next + lev_incr_next, 1e-14)
    sigma2_up_tp1_calibrated := math.max(s2_base_next + lev_route_next, 1e-14)

    n_resid = array.size(z_residuals)
    fhs_n := n_resid
    if n_resid >= 50
        sorted_z = array.copy(z_residuals)
        array.sort(sorted_z, order.ascending)

        alpha_lvl_fhs = 1.0 - conf_pct / 100.0
        p_lo = alpha_lvl_fhs / 2.0
        p_hi = 1.0 - alpha_lvl_fhs / 2.0

        pos_lo = p_lo * (n_resid - 1)
        pos_hi = p_hi * (n_resid - 1)
        i_lo_lo = math.floor(pos_lo)
        i_lo_hi = math.min(i_lo_lo + 1, n_resid - 1)
        w_lo    = pos_lo - i_lo_lo
        i_hi_lo = math.floor(pos_hi)
        i_hi_hi = math.min(i_hi_lo + 1, n_resid - 1)
        w_hi    = pos_hi - i_hi_lo

        fhs_q_lo := array.get(sorted_z, i_lo_lo) * (1.0 - w_lo) + array.get(sorted_z, i_lo_hi) * w_lo
        fhs_q_hi := array.get(sorted_z, i_hi_lo) * (1.0 - w_hi) + array.get(sorted_z, i_hi_hi) * w_hi

        [ql, xlo, nlo] = f_pot_quantile(sorted_z, p_lo)
        [qh, xhi, nhi] = f_pot_quantile(sorted_z, p_hi)
        pot_q_lo    := ql
        pot_q_hi    := qh
        gpd_xi_lo   := xlo
        gpd_xi_hi   := xhi
        gpd_nexc_lo := nlo
        gpd_nexc_hi := nhi

        sum_z  = 0.0
        sum_z2 = 0.0
        sum_z3 = 0.0
        sum_z4 = 0.0
        for k = 0 to n_resid - 1
            zk = array.get(z_residuals, k)
            sum_z  += zk
            sum_z2 += zk * zk
            sum_z3 += zk * zk * zk
            sum_z4 += zk * zk * zk * zk
        m1 = sum_z  / n_resid
        m2 = sum_z2 / n_resid - m1 * m1
        sd = math.sqrt(math.max(m2, 1e-9))
        cm3 = sum_z3 / n_resid - 3*m1*(sum_z2/n_resid) + 2*m1*m1*m1
        cm4 = sum_z4 / n_resid - 4*m1*(sum_z3/n_resid) + 6*m1*m1*(sum_z2/n_resid) - 3*m1*m1*m1*m1
        fhs_var  := m2
        fhs_skew := sd > 0 ? cm3 / (sd*sd*sd) : 0.0
        fhs_kurt := sd > 0 ? cm4 / (sd*sd*sd*sd) - 3.0 : 0.0
        kurt_target_disp = best_nu > 4.5 ? 6.0 / (best_nu - 4.0) : 15.0
        best_rq := math.abs(fhs_skew) + math.abs(fhs_kurt - kurt_target_disp) / math.max(1.0, kurt_target_disp) + 2.0 * math.abs(fhs_var - 1.0)

sigma2_t_use   = barstate.islast and not na(sigma2_t_calibrated)   ? sigma2_t_calibrated   : sigma2_live
sigma2_tp1_use = barstate.islast and not na(sigma2_tp1_calibrated) ? sigma2_tp1_calibrated : sigma2_live
sigma2_up_tp1_use = barstate.islast and not na(sigma2_up_tp1_calibrated) ? sigma2_up_tp1_calibrated : sigma2_live
sigma_t_use    = math.sqrt(math.max(sigma2_t_use, 1e-12))
sigma_tp1_use  = math.sqrt(math.max(sigma2_tp1_use, 1e-12))
sigma_up_tp1_use = math.sqrt(math.max(sigma2_up_tp1_use, 1e-12))

// ───────────── 9. CLOSED-FORM MULTI-STEP FORECAST (reverts to τ, not σ²_LT) ─────────────
g_use      = gamma_ratio * best_alpha
p_use      = best_alpha + 0.5*best_delta + best_beta + g_use   // = ψ_s (short-run persistence)
p_use_safe = math.min(p_use, 0.985)

// cum_var_h: H·LT + (s2_start − LT)·(1 − p^H)/(1 − p). In component mode the caller passes
// LT = tau_anchor and p = ψ_s, so the spike decays fast while τ stays flat.
cum_var_h(int h, float s2_start, float s2_lt_local, float p_local) =>
    p_local_safe = math.min(p_local, 0.985)
    diff = s2_start - s2_lt_local
    geom = (1.0 - math.pow(p_local_safe, h)) / math.max(1.0 - p_local_safe, 1e-9)
    math.max(h * s2_lt_local + diff * geom, 1e-12)

// ───────────── 10. LO-MACKINLAY AUTOCORRELATION (cleaned + shrunk) ─────────────
acorr(series float _x, simple int _lag, simple int _len) =>
    m  = ta.sma(_x, _len)
    v  = ta.variance(_x, _len)
    cv = ta.sma((_x - m) * (nz(_x[_lag]) - m), _len)
    // Degrade to 0 (⇒ VR=1, plain √h scaling — identical to use_acorr=OFF) if the
    // covariance or variance is na/degenerate, rather than propagating na downstream.
    // A single non-finite return in the window makes the cov ta.sma na while the plain
    // variance survives, so without this guard the autocorr arm alone would NaN the bands.
    (not na(v) and v > 0 and not na(cv)) ? cv / v : 0.0

rho1_raw = acorr(ret_recursion, 1, lookback)
rho2_raw = acorr(ret_recursion, 2, lookback)
rho3_raw = acorr(ret_recursion, 3, lookback)
rho4_raw = acorr(ret_recursion, 4, lookback)

shrink_rho(float r, simple int N) =>
    float out = 0.0
    if not na(r)
        t2 = r * r * N
        s = t2 > 1.0 ? 1.0 - 1.0 / t2 : 0.0
        out := r * math.max(0.0, s)
    out

r1_full = use_acorr ? shrink_rho(rho1_raw, lookback) : 0.0
r2_full = use_acorr ? shrink_rho(rho2_raw, lookback) : 0.0
r3_full = use_acorr ? shrink_rho(rho3_raw, lookback) : 0.0
r4_full = use_acorr ? shrink_rho(rho4_raw, lookback) : 0.0

// Outer nz to 0.0: in LIVE the fallback (r*_full) IS the same series value, so the inner nz
// alone cannot catch an na anchor reading — the outer one guarantees a finite VR input.
r1 = nz(nz(r1_full[display_offset], r1_full), 0.0)
r2 = nz(nz(r2_full[display_offset], r2_full), 0.0)
r3 = nz(nz(r3_full[display_offset], r3_full), 0.0)
r4 = nz(nz(r4_full[display_offset], r4_full), 0.0)

f_vr_ratio(int h, float _r1, float _r2, float _r3, float _r4) =>
    v = float(h)
    if h >= 2
        v := v + 2.0 * (h - 1) * _r1
    if h >= 3
        v := v + 2.0 * (h - 2) * _r2
    if h >= 4
        v := v + 2.0 * (h - 3) * _r3
    if h >= 5
        v := v + 2.0 * (h - 4) * _r4
    v_safe = math.max(nz(v, float(h)), h * 0.5)
    v_safe / h

vr_ratio_h = f_vr_ratio(horizon, r1, r2, r3, r4)

sigma_h_ceiling    = 3.0 * math.sqrt(math.max(sigma2_lt, sigma2_tp1_use) * horizon)
sigma_h_ceiling_up = 3.0 * math.sqrt(math.max(sigma2_lt, sigma2_up_tp1_use) * horizon)

// ───────────── 11. STUDENT-T QUANTILES (parametric fallback) ─────────────
alpha_lvl = 1.0 - conf_pct / 100.0
z_lo  = inv_t_standardized(alpha_lvl / 2.0,       best_nu)
z_hi  = inv_t_standardized(1.0 - alpha_lvl / 2.0, best_nu)

// ───────────── 12. HYBRID FHS + GPD QUANTILES (primary; raw-t fallback) ─────────────
pot_available = not na(pot_q_lo) and not na(pot_q_hi) and fhs_n >= 50
fhs_available = not na(fhs_q_lo) and not na(fhs_q_hi) and fhs_n >= 50
z_lo_primary = pot_available ? pot_q_lo : z_lo
z_hi_primary = pot_available ? pot_q_hi : z_hi

// ═══════════════════════════════════════════════════════════════════════════
// ───────────── WALK-FORWARD BACKTEST ENGINE (Monthly recalibration, F_t-aligned) ─────────────
// ═══════════════════════════════════════════════════════════════════════════

if barstate.islast and backtest_on and bar_index > lookback + 30 + display_offset + backtest_window + backtest_horizon

    // ─── Step 1: Pre-compute recalibration points ───
    recal_offsets = array.new<int>()
    K_max = backtest_window + backtest_horizon
    max_recals = K_max / recal_interval + 2
    for ri_build = 1 to max_recals
        K_curr = ri_build * recal_interval
        if K_curr <= K_max
            array.push(recal_offsets, K_curr)
    if array.size(recal_offsets) == 0 or array.get(recal_offsets, array.size(recal_offsets) - 1) < K_max
        array.push(recal_offsets, K_max)

    n_recals = array.size(recal_offsets)
    bt_n_recals := n_recals

    // ─── Step 2: Calibrate at each recal point (UNROLLED) ───
    // The ≤13 sequential grid calibrations are deliberately UNROLLED: inside one `for ri` loop
    // their combined time would be a single contiguous loop execution and exceed Pine's
    // per-loop time budget, while each f_full_calibration on its own is comfortably under it.
    // Call order = ascending recal index. n_recals max = 13: recal_interval = 21 (const),
    // K_max = backtest_window(<=252) + backtest_horizon(<=20) <= 272.
    recal_alpha = array.new<float>()
    recal_beta  = array.new<float>()
    recal_delta = array.new<float>()
    recal_nu    = array.new<float>()
    recal_s2lt  = array.new<float>()
    recal_r1    = array.new<float>()
    recal_r2    = array.new<float>()
    recal_r3    = array.new<float>()
    recal_r4    = array.new<float>()
    recal_zlot  = array.new<float>()
    recal_zhit  = array.new<float>()
    recal_psi   = array.new<float>()

    if 0 < n_recals
        K_off_0 = array.get(recal_offsets, 0)
        s2lt_0 = math.max(nz(sigma2_lt_full[K_off_0], sigma2_lt), 1e-12)
        [a_0, b_0, d_0, n_0, _nlp_0, _rq_0, _bst_0] = f_full_calibration(K_off_0, s2lt_0)
        array.push(recal_alpha, a_0)
        array.push(recal_beta,  b_0)
        array.push(recal_delta, d_0)
        array.push(recal_nu,    n_0)
        array.push(recal_s2lt,  s2lt_0)
        array.push(recal_r1, nz(r1_full[K_off_0], 0.0))
        array.push(recal_r2, nz(r2_full[K_off_0], 0.0))
        array.push(recal_r3, nz(r3_full[K_off_0], 0.0))
        array.push(recal_r4, nz(r4_full[K_off_0], 0.0))
        z_lo_0_raw = inv_t_standardized(alpha_lvl / 2.0,       n_0)
        z_hi_0_raw = inv_t_standardized(1.0 - alpha_lvl / 2.0, n_0)
        array.push(recal_zlot, z_lo_0_raw)
        array.push(recal_zhit, z_hi_0_raw)
        psi_0 = lev_asym ? math.max(0.0, math.min(1.0, nz(psi_full[K_off_0], 1.0))) : 1.0
        array.push(recal_psi, psi_0)
    if 1 < n_recals
        K_off_1 = array.get(recal_offsets, 1)
        s2lt_1 = math.max(nz(sigma2_lt_full[K_off_1], sigma2_lt), 1e-12)
        [a_1, b_1, d_1, n_1, _nlp_1, _rq_1, _bst_1] = f_full_calibration(K_off_1, s2lt_1)
        array.push(recal_alpha, a_1)
        array.push(recal_beta,  b_1)
        array.push(recal_delta, d_1)
        array.push(recal_nu,    n_1)
        array.push(recal_s2lt,  s2lt_1)
        array.push(recal_r1, nz(r1_full[K_off_1], 0.0))
        array.push(recal_r2, nz(r2_full[K_off_1], 0.0))
        array.push(recal_r3, nz(r3_full[K_off_1], 0.0))
        array.push(recal_r4, nz(r4_full[K_off_1], 0.0))
        z_lo_1_raw = inv_t_standardized(alpha_lvl / 2.0,       n_1)
        z_hi_1_raw = inv_t_standardized(1.0 - alpha_lvl / 2.0, n_1)
        array.push(recal_zlot, z_lo_1_raw)
        array.push(recal_zhit, z_hi_1_raw)
        psi_1 = lev_asym ? math.max(0.0, math.min(1.0, nz(psi_full[K_off_1], 1.0))) : 1.0
        array.push(recal_psi, psi_1)
    if 2 < n_recals
        K_off_2 = array.get(recal_offsets, 2)
        s2lt_2 = math.max(nz(sigma2_lt_full[K_off_2], sigma2_lt), 1e-12)
        [a_2, b_2, d_2, n_2, _nlp_2, _rq_2, _bst_2] = f_full_calibration(K_off_2, s2lt_2)
        array.push(recal_alpha, a_2)
        array.push(recal_beta,  b_2)
        array.push(recal_delta, d_2)
        array.push(recal_nu,    n_2)
        array.push(recal_s2lt,  s2lt_2)
        array.push(recal_r1, nz(r1_full[K_off_2], 0.0))
        array.push(recal_r2, nz(r2_full[K_off_2], 0.0))
        array.push(recal_r3, nz(r3_full[K_off_2], 0.0))
        array.push(recal_r4, nz(r4_full[K_off_2], 0.0))
        z_lo_2_raw = inv_t_standardized(alpha_lvl / 2.0,       n_2)
        z_hi_2_raw = inv_t_standardized(1.0 - alpha_lvl / 2.0, n_2)
        array.push(recal_zlot, z_lo_2_raw)
        array.push(recal_zhit, z_hi_2_raw)
        psi_2 = lev_asym ? math.max(0.0, math.min(1.0, nz(psi_full[K_off_2], 1.0))) : 1.0
        array.push(recal_psi, psi_2)
    if 3 < n_recals
        K_off_3 = array.get(recal_offsets, 3)
        s2lt_3 = math.max(nz(sigma2_lt_full[K_off_3], sigma2_lt), 1e-12)
        [a_3, b_3, d_3, n_3, _nlp_3, _rq_3, _bst_3] = f_full_calibration(K_off_3, s2lt_3)
        array.push(recal_alpha, a_3)
        array.push(recal_beta,  b_3)
        array.push(recal_delta, d_3)
        array.push(recal_nu,    n_3)
        array.push(recal_s2lt,  s2lt_3)
        array.push(recal_r1, nz(r1_full[K_off_3], 0.0))
        array.push(recal_r2, nz(r2_full[K_off_3], 0.0))
        array.push(recal_r3, nz(r3_full[K_off_3], 0.0))
        array.push(recal_r4, nz(r4_full[K_off_3], 0.0))
        z_lo_3_raw = inv_t_standardized(alpha_lvl / 2.0,       n_3)
        z_hi_3_raw = inv_t_standardized(1.0 - alpha_lvl / 2.0, n_3)
        array.push(recal_zlot, z_lo_3_raw)
        array.push(recal_zhit, z_hi_3_raw)
        psi_3 = lev_asym ? math.max(0.0, math.min(1.0, nz(psi_full[K_off_3], 1.0))) : 1.0
        array.push(recal_psi, psi_3)
    if 4 < n_recals
        K_off_4 = array.get(recal_offsets, 4)
        s2lt_4 = math.max(nz(sigma2_lt_full[K_off_4], sigma2_lt), 1e-12)
        [a_4, b_4, d_4, n_4, _nlp_4, _rq_4, _bst_4] = f_full_calibration(K_off_4, s2lt_4)
        array.push(recal_alpha, a_4)
        array.push(recal_beta,  b_4)
        array.push(recal_delta, d_4)
        array.push(recal_nu,    n_4)
        array.push(recal_s2lt,  s2lt_4)
        array.push(recal_r1, nz(r1_full[K_off_4], 0.0))
        array.push(recal_r2, nz(r2_full[K_off_4], 0.0))
        array.push(recal_r3, nz(r3_full[K_off_4], 0.0))
        array.push(recal_r4, nz(r4_full[K_off_4], 0.0))
        z_lo_4_raw = inv_t_standardized(alpha_lvl / 2.0,       n_4)
        z_hi_4_raw = inv_t_standardized(1.0 - alpha_lvl / 2.0, n_4)
        array.push(recal_zlot, z_lo_4_raw)
        array.push(recal_zhit, z_hi_4_raw)
        psi_4 = lev_asym ? math.max(0.0, math.min(1.0, nz(psi_full[K_off_4], 1.0))) : 1.0
        array.push(recal_psi, psi_4)
    if 5 < n_recals
        K_off_5 = array.get(recal_offsets, 5)
        s2lt_5 = math.max(nz(sigma2_lt_full[K_off_5], sigma2_lt), 1e-12)
        [a_5, b_5, d_5, n_5, _nlp_5, _rq_5, _bst_5] = f_full_calibration(K_off_5, s2lt_5)
        array.push(recal_alpha, a_5)
        array.push(recal_beta,  b_5)
        array.push(recal_delta, d_5)
        array.push(recal_nu,    n_5)
        array.push(recal_s2lt,  s2lt_5)
        array.push(recal_r1, nz(r1_full[K_off_5], 0.0))
        array.push(recal_r2, nz(r2_full[K_off_5], 0.0))
        array.push(recal_r3, nz(r3_full[K_off_5], 0.0))
        array.push(recal_r4, nz(r4_full[K_off_5], 0.0))
        z_lo_5_raw = inv_t_standardized(alpha_lvl / 2.0,       n_5)
        z_hi_5_raw = inv_t_standardized(1.0 - alpha_lvl / 2.0, n_5)
        array.push(recal_zlot, z_lo_5_raw)
        array.push(recal_zhit, z_hi_5_raw)
        psi_5 = lev_asym ? math.max(0.0, math.min(1.0, nz(psi_full[K_off_5], 1.0))) : 1.0
        array.push(recal_psi, psi_5)
    if 6 < n_recals
        K_off_6 = array.get(recal_offsets, 6)
        s2lt_6 = math.max(nz(sigma2_lt_full[K_off_6], sigma2_lt), 1e-12)
        [a_6, b_6, d_6, n_6, _nlp_6, _rq_6, _bst_6] = f_full_calibration(K_off_6, s2lt_6)
        array.push(recal_alpha, a_6)
        array.push(recal_beta,  b_6)
        array.push(recal_delta, d_6)
        array.push(recal_nu,    n_6)
        array.push(recal_s2lt,  s2lt_6)
        array.push(recal_r1, nz(r1_full[K_off_6], 0.0))
        array.push(recal_r2, nz(r2_full[K_off_6], 0.0))
        array.push(recal_r3, nz(r3_full[K_off_6], 0.0))
        array.push(recal_r4, nz(r4_full[K_off_6], 0.0))
        z_lo_6_raw = inv_t_standardized(alpha_lvl / 2.0,       n_6)
        z_hi_6_raw = inv_t_standardized(1.0 - alpha_lvl / 2.0, n_6)
        array.push(recal_zlot, z_lo_6_raw)
        array.push(recal_zhit, z_hi_6_raw)
        psi_6 = lev_asym ? math.max(0.0, math.min(1.0, nz(psi_full[K_off_6], 1.0))) : 1.0
        array.push(recal_psi, psi_6)
    if 7 < n_recals
        K_off_7 = array.get(recal_offsets, 7)
        s2lt_7 = math.max(nz(sigma2_lt_full[K_off_7], sigma2_lt), 1e-12)
        [a_7, b_7, d_7, n_7, _nlp_7, _rq_7, _bst_7] = f_full_calibration(K_off_7, s2lt_7)
        array.push(recal_alpha, a_7)
        array.push(recal_beta,  b_7)
        array.push(recal_delta, d_7)
        array.push(recal_nu,    n_7)
        array.push(recal_s2lt,  s2lt_7)
        array.push(recal_r1, nz(r1_full[K_off_7], 0.0))
        array.push(recal_r2, nz(r2_full[K_off_7], 0.0))
        array.push(recal_r3, nz(r3_full[K_off_7], 0.0))
        array.push(recal_r4, nz(r4_full[K_off_7], 0.0))
        z_lo_7_raw = inv_t_standardized(alpha_lvl / 2.0,       n_7)
        z_hi_7_raw = inv_t_standardized(1.0 - alpha_lvl / 2.0, n_7)
        array.push(recal_zlot, z_lo_7_raw)
        array.push(recal_zhit, z_hi_7_raw)
        psi_7 = lev_asym ? math.max(0.0, math.min(1.0, nz(psi_full[K_off_7], 1.0))) : 1.0
        array.push(recal_psi, psi_7)
    if 8 < n_recals
        K_off_8 = array.get(recal_offsets, 8)
        s2lt_8 = math.max(nz(sigma2_lt_full[K_off_8], sigma2_lt), 1e-12)
        [a_8, b_8, d_8, n_8, _nlp_8, _rq_8, _bst_8] = f_full_calibration(K_off_8, s2lt_8)
        array.push(recal_alpha, a_8)
        array.push(recal_beta,  b_8)
        array.push(recal_delta, d_8)
        array.push(recal_nu,    n_8)
        array.push(recal_s2lt,  s2lt_8)
        array.push(recal_r1, nz(r1_full[K_off_8], 0.0))
        array.push(recal_r2, nz(r2_full[K_off_8], 0.0))
        array.push(recal_r3, nz(r3_full[K_off_8], 0.0))
        array.push(recal_r4, nz(r4_full[K_off_8], 0.0))
        z_lo_8_raw = inv_t_standardized(alpha_lvl / 2.0,       n_8)
        z_hi_8_raw = inv_t_standardized(1.0 - alpha_lvl / 2.0, n_8)
        array.push(recal_zlot, z_lo_8_raw)
        array.push(recal_zhit, z_hi_8_raw)
        psi_8 = lev_asym ? math.max(0.0, math.min(1.0, nz(psi_full[K_off_8], 1.0))) : 1.0
        array.push(recal_psi, psi_8)
    if 9 < n_recals
        K_off_9 = array.get(recal_offsets, 9)
        s2lt_9 = math.max(nz(sigma2_lt_full[K_off_9], sigma2_lt), 1e-12)
        [a_9, b_9, d_9, n_9, _nlp_9, _rq_9, _bst_9] = f_full_calibration(K_off_9, s2lt_9)
        array.push(recal_alpha, a_9)
        array.push(recal_beta,  b_9)
        array.push(recal_delta, d_9)
        array.push(recal_nu,    n_9)
        array.push(recal_s2lt,  s2lt_9)
        array.push(recal_r1, nz(r1_full[K_off_9], 0.0))
        array.push(recal_r2, nz(r2_full[K_off_9], 0.0))
        array.push(recal_r3, nz(r3_full[K_off_9], 0.0))
        array.push(recal_r4, nz(r4_full[K_off_9], 0.0))
        z_lo_9_raw = inv_t_standardized(alpha_lvl / 2.0,       n_9)
        z_hi_9_raw = inv_t_standardized(1.0 - alpha_lvl / 2.0, n_9)
        array.push(recal_zlot, z_lo_9_raw)
        array.push(recal_zhit, z_hi_9_raw)
        psi_9 = lev_asym ? math.max(0.0, math.min(1.0, nz(psi_full[K_off_9], 1.0))) : 1.0
        array.push(recal_psi, psi_9)
    if 10 < n_recals
        K_off_10 = array.get(recal_offsets, 10)
        s2lt_10 = math.max(nz(sigma2_lt_full[K_off_10], sigma2_lt), 1e-12)
        [a_10, b_10, d_10, n_10, _nlp_10, _rq_10, _bst_10] = f_full_calibration(K_off_10, s2lt_10)
        array.push(recal_alpha, a_10)
        array.push(recal_beta,  b_10)
        array.push(recal_delta, d_10)
        array.push(recal_nu,    n_10)
        array.push(recal_s2lt,  s2lt_10)
        array.push(recal_r1, nz(r1_full[K_off_10], 0.0))
        array.push(recal_r2, nz(r2_full[K_off_10], 0.0))
        array.push(recal_r3, nz(r3_full[K_off_10], 0.0))
        array.push(recal_r4, nz(r4_full[K_off_10], 0.0))
        z_lo_10_raw = inv_t_standardized(alpha_lvl / 2.0,       n_10)
        z_hi_10_raw = inv_t_standardized(1.0 - alpha_lvl / 2.0, n_10)
        array.push(recal_zlot, z_lo_10_raw)
        array.push(recal_zhit, z_hi_10_raw)
        psi_10 = lev_asym ? math.max(0.0, math.min(1.0, nz(psi_full[K_off_10], 1.0))) : 1.0
        array.push(recal_psi, psi_10)
    if 11 < n_recals
        K_off_11 = array.get(recal_offsets, 11)
        s2lt_11 = math.max(nz(sigma2_lt_full[K_off_11], sigma2_lt), 1e-12)
        [a_11, b_11, d_11, n_11, _nlp_11, _rq_11, _bst_11] = f_full_calibration(K_off_11, s2lt_11)
        array.push(recal_alpha, a_11)
        array.push(recal_beta,  b_11)
        array.push(recal_delta, d_11)
        array.push(recal_nu,    n_11)
        array.push(recal_s2lt,  s2lt_11)
        array.push(recal_r1, nz(r1_full[K_off_11], 0.0))
        array.push(recal_r2, nz(r2_full[K_off_11], 0.0))
        array.push(recal_r3, nz(r3_full[K_off_11], 0.0))
        array.push(recal_r4, nz(r4_full[K_off_11], 0.0))
        z_lo_11_raw = inv_t_standardized(alpha_lvl / 2.0,       n_11)
        z_hi_11_raw = inv_t_standardized(1.0 - alpha_lvl / 2.0, n_11)
        array.push(recal_zlot, z_lo_11_raw)
        array.push(recal_zhit, z_hi_11_raw)
        psi_11 = lev_asym ? math.max(0.0, math.min(1.0, nz(psi_full[K_off_11], 1.0))) : 1.0
        array.push(recal_psi, psi_11)
    if 12 < n_recals
        K_off_12 = array.get(recal_offsets, 12)
        s2lt_12 = math.max(nz(sigma2_lt_full[K_off_12], sigma2_lt), 1e-12)
        [a_12, b_12, d_12, n_12, _nlp_12, _rq_12, _bst_12] = f_full_calibration(K_off_12, s2lt_12)
        array.push(recal_alpha, a_12)
        array.push(recal_beta,  b_12)
        array.push(recal_delta, d_12)
        array.push(recal_nu,    n_12)
        array.push(recal_s2lt,  s2lt_12)
        array.push(recal_r1, nz(r1_full[K_off_12], 0.0))
        array.push(recal_r2, nz(r2_full[K_off_12], 0.0))
        array.push(recal_r3, nz(r3_full[K_off_12], 0.0))
        array.push(recal_r4, nz(r4_full[K_off_12], 0.0))
        z_lo_12_raw = inv_t_standardized(alpha_lvl / 2.0,       n_12)
        z_hi_12_raw = inv_t_standardized(1.0 - alpha_lvl / 2.0, n_12)
        array.push(recal_zlot, z_lo_12_raw)
        array.push(recal_zhit, z_hi_12_raw)
        psi_12 = lev_asym ? math.max(0.0, math.min(1.0, nz(psi_full[K_off_12], 1.0))) : 1.0
        array.push(recal_psi, psi_12)

    float psi_sum_bt = 0.0
    for ri = 0 to n_recals - 1
        psi_sum_bt += array.get(recal_psi, ri)
    bt_psi_mean := n_recals > 0 ? psi_sum_bt / n_recals : na

    // ─── Step 3: Reset BT counters ───
    tol = tolerance_bp / 10000.0
    alpha_lvl_bt = 1.0 - conf_pct / 100.0
    p_lo_bt = alpha_lvl_bt / 2.0
    p_hi_bt = 1.0 - alpha_lvl_bt / 2.0

    bt_n_J := 0
    for h_idx = 0 to 19
        array.set(bt_close_in,     h_idx, 0)
        array.set(bt_notouch_up,   h_idx, 0)
        array.set(bt_notouch_dn,   h_idx, 0)
        array.set(bt_notouch_both, h_idx, 0)
        array.set(bt_breach_up,    h_idx, 0)
        array.set(bt_breach_dn,    h_idx, 0)
    for h_idx = 0 to 4
        array.set(pit_n_sh,   h_idx, 0)
        array.set(pit_su_sh,  h_idx, 0.0)
        array.set(pit_su2_sh, h_idx, 0.0)
        array.set(pit_lo_sh,  h_idx, 0)
        array.set(pit_hi_sh,  h_idx, 0)
        array.set(pit_n_no,   h_idx, 0)
        array.set(pit_su_no,  h_idx, 0.0)
        array.set(pit_su2_no, h_idx, 0.0)
        array.set(pit_lo_no,  h_idx, 0)
        array.set(pit_hi_no,  h_idx, 0)

    // ─── Step 4: Walk forward over backtest window (deviation form) ───
    earliest_J_offset = backtest_window + backtest_horizon - 1
    latest_J_offset = backtest_horizon

    BURN_IN_BT = 50
    RESID_PREFILL_BT = lookback   // The residual pool reaches a FULL `lookback` bars behind the
                                  // EARLIEST tested J, so even the first J gets a complete
                                  // rolling window. The extra walk depth lands inside the σ²
                                  // burn-in (no residual is collected there).
    walk_start_offset = earliest_J_offset + RESID_PREFILL_BT + BURN_IN_BT

    s2_by_offset = array.new<float>()
    offset_index = array.new<int>()
    z_resid_bt = array.new<float>()
    z_resid_offset = array.new<int>()

    seed_K_idx = -1
    seed_found = false
    for ri = 0 to n_recals - 1
        if not seed_found
            K_off_seed = array.get(recal_offsets, ri)
            if K_off_seed >= walk_start_offset
                seed_K_idx := ri
                seed_found := true
    if seed_K_idx < 0
        seed_K_idx := n_recals - 1
    s2_w = math.max(nz(tau[walk_start_offset], array.get(recal_s2lt, seed_K_idx)), 1e-14)

    for k = walk_start_offset to latest_J_offset
        K_idx_k = -1
        found_k = false
        for ri = 0 to n_recals - 1
            if not found_k
                K_off_check = array.get(recal_offsets, ri)
                if K_off_check >= k
                    K_idx_k := ri
                    found_k := true
        if K_idx_k < 0
            K_idx_k := n_recals - 1
        a_k = array.get(recal_alpha, K_idx_k)
        b_k = array.get(recal_beta,  K_idx_k)
        d_k = array.get(recal_delta, K_idx_k)
        nu_k = array.get(recal_nu,   K_idx_k)
        s2lt_k = array.get(recal_s2lt, K_idx_k)
        g_k = gamma_ratio * a_k
        c_nu_k = f_winsor_c(nu_k)

        tau_prev_k = nz(tau[k + 1], s2lt_k)
        tau_now_k  = nz(tau[k],     s2lt_k)
        r_prev_k  = nz(ret_recursion[k + 1])
        rv_prev_k = nz(rv_recursion[k + 1], s2lt_k)
        lev_prev_k = r_prev_k < 0 ? 1.0 : 0.0
        r2_eff_k = f_winsor_r2(r_prev_k, s2_w, c_nu_k)
        s2_w := tau_now_k + (a_k + d_k * lev_prev_k) * (r2_eff_k - tau_prev_k) + b_k * (s2_w - tau_prev_k) + g_k * (rv_prev_k - tau_prev_k)
        s2_w := math.max(s2_w, 1e-14)

        array.push(s2_by_offset, s2_w)
        array.push(offset_index, k)

        is_gap_k = nz(is_gap_bar_i[k], 0) == 1
        if not is_gap_k and k <= walk_start_offset - BURN_IN_BT
            r_now_k = nz(ret_cc[k])
            z_k = r_now_k / math.sqrt(s2_w)
            array.push(z_resid_bt, z_k)
            array.push(z_resid_offset, k)

    n_s2 = array.size(s2_by_offset)

    // ─── Step 5: For each J, build bands and test outcomes ───
    // Fixed-length ROLLING FHS/GPD window. z_resid_offset is strictly DECREASING (pushed as k
    // decreased in Step 4); ONE ascending-sorted array is maintained via two pointers:
    //   ins_ptr   adds residuals at offset >= J_off (origin-day residual INCLUDED, as LIVE does),
    //   evict_ptr removes residuals at offset >= J_off + lookback (aged out).
    // Retained span = offsets in [J_off, J_off + lookback - 1] — the SAME span as the LIVE FHS
    // window — so each J reproduces the LIVE quantile methodology. Binary-search insert/remove
    // keeps the array sorted with no per-J filter+full-sort; zv_old is the exact float stored,
    // so f_bisect_right locates its rightmost instance for removal. Strictly no look-ahead:
    // no retained residual is newer than J.
    float[] sorted_resid     = array.new<float>()
    int     n_resid_total_bt = array.size(z_resid_bt)
    int     ins_ptr          = 0
    int     evict_ptr        = 0
    for J_off = earliest_J_offset to latest_J_offset
        while ins_ptr < n_resid_total_bt and array.get(z_resid_offset, ins_ptr) >= J_off
            float zv      = array.get(z_resid_bt, ins_ptr)
            int   pos_ins = f_bisect_right(sorted_resid, zv)
            if pos_ins >= array.size(sorted_resid)
                array.push(sorted_resid, zv)
            else
                array.insert(sorted_resid, pos_ins, zv)
            ins_ptr := ins_ptr + 1
        while evict_ptr < ins_ptr and array.get(z_resid_offset, evict_ptr) >= J_off + lookback
            float zv_old  = array.get(z_resid_bt, evict_ptr)
            int   pos_old = f_bisect_right(sorted_resid, zv_old) - 1
            if pos_old >= 0 and pos_old < array.size(sorted_resid)
                array.remove(sorted_resid, pos_old)
            evict_ptr := evict_ptr + 1
        idx_J = walk_start_offset - J_off
        if idx_J >= 0 and idx_J < n_s2
            s2_t_J = array.get(s2_by_offset, idx_J)

            K_idx_J = -1
            found_J = false
            for ri = 0 to n_recals - 1
                if not found_J
                    K_off_check_J = array.get(recal_offsets, ri)
                    if K_off_check_J >= J_off
                        K_idx_J := ri
                        found_J := true
            if K_idx_J < 0
                K_idx_J := n_recals - 1

            a_J = array.get(recal_alpha, K_idx_J)
            b_J = array.get(recal_beta,  K_idx_J)
            d_J = array.get(recal_delta, K_idx_J)
            nu_J = array.get(recal_nu,   K_idx_J)
            s2lt_J = array.get(recal_s2lt, K_idx_J)
            g_J = gamma_ratio * a_J
            p_J = a_J + 0.5*d_J + b_J + g_J
            r1_J = array.get(recal_r1, K_idx_J)
            r2_J = array.get(recal_r2, K_idx_J)
            r3_J = array.get(recal_r3, K_idx_J)
            r4_J = array.get(recal_r4, K_idx_J)
            psi_J = array.get(recal_psi, K_idx_J)

            c_nu_J   = f_winsor_c(nu_J)
            tau_J_bt = math.max(nz(tau[J_off], s2lt_J), 1e-14)
            rv_Jbt   = nz(rv_recursion[J_off], s2lt_J)
            tau_Jnext_bt = use_component ? math.max(lambda_lr * tau_J_bt + (1.0 - lambda_lr) * rv_Jbt, 1e-14) : tau_J_bt
            r_Jbt    = nz(ret_recursion[J_off])
            lev_Jbt  = r_Jbt < 0 ? 1.0 : 0.0
            r2_eff_Jbt = f_winsor_r2(r_Jbt, s2_t_J, c_nu_J)
            dev_r2_Jbt = r2_eff_Jbt - tau_J_bt
            s2_base_J  = tau_Jnext_bt + a_J*dev_r2_Jbt + b_J*(s2_t_J - tau_J_bt) + g_J*(rv_Jbt - tau_J_bt)
            lev_incr_J = d_J * lev_Jbt * dev_r2_Jbt
            lev_route_J = lev_incr_J > 0 ? psi_J * lev_incr_J : lev_incr_J   // mirror LIVE: route only the POSITIVE increment by psi
            s2_tp1_J    = math.max(s2_base_J + lev_incr_J, 1e-14)
            s2_up_tp1_J = math.max(s2_base_J + lev_route_J, 1e-14)

            z_lo_bt = 0.0
            z_hi_bt = 0.0

            n_sub = array.size(sorted_resid)
            if n_sub >= 50
                [ql_bt, _xlo_bt, _nlo_bt] = f_pot_quantile(sorted_resid, p_lo_bt)
                [qh_bt, _xhi_bt, _nhi_bt] = f_pot_quantile(sorted_resid, p_hi_bt)
                z_lo_bt := na(ql_bt) ? array.get(recal_zlot, K_idx_J) : ql_bt
                z_hi_bt := na(qh_bt) ? array.get(recal_zhit, K_idx_J) : qh_bt
            else
                z_lo_bt := array.get(recal_zlot, K_idx_J)
                z_hi_bt := array.get(recal_zhit, K_idx_J)

            bt_n_J := bt_n_J + 1
            max_h = backtest_horizon

            close_J = close[J_off]

            // ── PIT regime classification for day J (vol-relative red shock) ──
            z_J_innov  = nz(ret_recursion[J_off]) / math.sqrt(math.max(s2_t_J, 1e-14))
            is_shock_J = z_J_innov < -pit_shock_k

            for h = 1 to max_h
                vr_h_J = f_vr_ratio(h, r1_J, r2_J, r3_J, r4_J)
                var_h_dn_J = cum_var_h(h, s2_tp1_J,    tau_Jnext_bt, p_J) * vr_h_J
                var_h_up_J = cum_var_h(h, s2_up_tp1_J, tau_Jnext_bt, p_J) * vr_h_J
                sigma_h_dn_J_raw = math.sqrt(math.max(var_h_dn_J, 1e-12))
                sigma_h_up_J_raw = math.sqrt(math.max(var_h_up_J, 1e-12))
                sigma_h_dn_J_ceil = 3.0 * math.sqrt(math.max(s2lt_J, s2_tp1_J)    * h)
                sigma_h_up_J_ceil = 3.0 * math.sqrt(math.max(s2lt_J, s2_up_tp1_J) * h)
                sigma_h_dn_J = math.min(sigma_h_dn_J_raw, sigma_h_dn_J_ceil)
                sigma_h_up_J = math.min(sigma_h_up_J_raw, sigma_h_up_J_ceil)

                upper_J_h = close_J * math.exp( z_hi_bt * sigma_h_up_J)
                lower_J_h = close_J * math.exp( z_lo_bt * sigma_h_dn_J)

                upper_tol = upper_J_h * (1.0 + tol)
                lower_tol = lower_J_h * (1.0 - tol)

                target_off = J_off - h
                if target_off >= 0
                    close_target = close[target_off]
                    if close_target <= upper_tol and close_target >= lower_tol
                        array.set(bt_close_in, h-1, array.get(bt_close_in, h-1) + 1)
                    if close_target > upper_tol
                        array.set(bt_breach_up, h-1, array.get(bt_breach_up, h-1) + 1)
                    if close_target < lower_tol
                        array.set(bt_breach_dn, h-1, array.get(bt_breach_dn, h-1) + 1)

                    touched_up = false
                    touched_dn = false
                    for hh = 1 to h
                        scan_off = J_off - hh
                        if scan_off >= 0
                            h_scan = high[scan_off]
                            l_scan = low[scan_off]
                            if h_scan > upper_tol
                                touched_up := true
                            if l_scan < lower_tol
                                touched_dn := true
                    if not touched_up
                        array.set(bt_notouch_up, h-1, array.get(bt_notouch_up, h-1) + 1)
                    if not touched_dn
                        array.set(bt_notouch_dn, h-1, array.get(bt_notouch_dn, h-1) + 1)
                    if not touched_up and not touched_dn
                        array.set(bt_notouch_both, h-1, array.get(bt_notouch_both, h-1) + 1)

                    // ── PIT (endpoint) of the realized close at J+h via the model's own CDF ──
                    // Gated behind show_pit: skipping it leaves every band and every walk-forward
                    // count identical, and avoids the f_pot_cdf scan for each (J, h).
                    if show_pit and h <= 5 and n_sub >= 50
                        r_real_pit = math.log(close_target / close_J)
                        sig_side   = r_real_pit < 0 ? sigma_h_dn_J : sigma_h_up_J
                        z_real_pit = r_real_pit / math.max(sig_side, 1e-9)
                        u_pit      = f_pot_cdf(sorted_resid, z_real_pit)
                        if is_shock_J
                            array.set(pit_n_sh,   h-1, array.get(pit_n_sh,   h-1) + 1)
                            array.set(pit_su_sh,  h-1, array.get(pit_su_sh,  h-1) + u_pit)
                            array.set(pit_su2_sh, h-1, array.get(pit_su2_sh, h-1) + u_pit * u_pit)
                            if u_pit < p_lo_bt
                                array.set(pit_lo_sh, h-1, array.get(pit_lo_sh, h-1) + 1)
                            if u_pit > p_hi_bt
                                array.set(pit_hi_sh, h-1, array.get(pit_hi_sh, h-1) + 1)
                        else
                            array.set(pit_n_no,   h-1, array.get(pit_n_no,   h-1) + 1)
                            array.set(pit_su_no,  h-1, array.get(pit_su_no,  h-1) + u_pit)
                            array.set(pit_su2_no, h-1, array.get(pit_su2_no, h-1) + u_pit * u_pit)
                            if u_pit < p_lo_bt
                                array.set(pit_lo_no, h-1, array.get(pit_lo_no, h-1) + 1)
                            if u_pit > p_hi_bt
                                array.set(pit_hi_no, h-1, array.get(pit_hi_no, h-1) + 1)

// ───────────── 13. CONSTRAINED-PARAMETER DIAGNOSTIC ─────────────
A_LO = 0.02
A_HI = 0.15
B_LO = use_component ? 0.30 : 0.75
B_HI = use_component ? 0.90 : 0.93
D_LO = 0.00
D_HI = 0.30

alpha_at_bound = math.min(math.abs(best_alpha - A_LO), math.abs(best_alpha - A_HI)) < 0.008
beta_at_bound  = math.min(math.abs(best_beta  - B_LO), math.abs(best_beta  - B_HI)) < 0.008
delta_at_bound = math.abs(best_delta - D_HI) < 0.008
nu_min_in_grid = array.size(nu_grid_arr) > 0 ? array.get(nu_grid_arr, 0) : 4.0
nu_max_in_grid = array.size(nu_grid_arr) > 0 ? array.get(nu_grid_arr, array.size(nu_grid_arr) - 1) : 30.0
nu_at_bound    = best_nu <= nu_min_in_grid + 0.05 or best_nu >= nu_max_in_grid - 0.05
n_at_bound = (alpha_at_bound ? 1 : 0) + (beta_at_bound ? 1 : 0) + (delta_at_bound ? 1 : 0) + (nu_at_bound ? 1 : 0)

// ───────────── 14. DRAW ─────────────
var label info   = na
var label bt_label = na
var label vol_label = na
var label pit_label = na
var line[]     up_segments  = array.new<line>()
var line[]     dn_segments  = array.new<line>()
var line[]     mid_segments = array.new<line>()
var linefill[] band_fills   = array.new<linefill>()
var label[] values_up  = array.new<label>()
var label[] values_dn  = array.new<label>()

clear_lines(line[] arr) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            line.delete(array.get(arr, i))
        array.clear(arr)

clear_labels(label[] arr) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            label.delete(array.get(arr, i))
        array.clear(arr)

clear_linefills(linefill[] arr) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            linefill.delete(array.get(arr, i))
        array.clear(arr)

if barstate.islast
    label.delete(info)
    label.delete(bt_label)
    label.delete(vol_label)
    label.delete(pit_label)
    clear_linefills(band_fills)
    clear_lines(up_segments)
    clear_lines(dn_segments)
    clear_lines(mid_segments)
    clear_labels(values_up)
    clear_labels(values_dn)

    anchor_x     = bar_index - display_offset
    anchor_close = close[display_offset]
    x1 = anchor_x
    x2 = anchor_x + horizon + 1

    var_cum_final_dn = cum_var_h(horizon, sigma2_tp1_use, tau_anchor, p_use) * vr_ratio_h
    var_cum_final_up = cum_var_h(horizon, sigma2_up_tp1_use, tau_anchor, p_use) * vr_ratio_h
    sigma_final_dn_raw = math.sqrt(math.max(var_cum_final_dn, 1e-12))
    sigma_final_up_raw = math.sqrt(math.max(var_cum_final_up, 1e-12))
    sigma_final_dn = math.min(sigma_final_dn_raw, sigma_h_ceiling)
    sigma_final_up = math.min(sigma_final_up_raw, sigma_h_ceiling_up)
    sigma_final_raw = sigma_final_dn_raw
    sigma_final = sigma_final_dn
    final_up  = anchor_close * math.exp(z_hi_primary * sigma_final_up)
    final_dn  = anchor_close * math.exp(z_lo_primary * sigma_final_dn)
    final_mid = anchor_close

    resolved_mark_up = mark_match_band ? upper_color : mark_color_up
    resolved_mark_dn = mark_match_band ? lower_color : mark_color_dn

    float prev_up  = anchor_close
    float prev_dn  = anchor_close
    float prev_mid = anchor_close

    for k = 1 to horizon
        vr_k = f_vr_ratio(k, r1, r2, r3, r4)
        var_k_dn = cum_var_h(k, sigma2_tp1_use, tau_anchor, p_use) * vr_k
        var_k_up = cum_var_h(k, sigma2_up_tp1_use, tau_anchor, p_use) * vr_k
        sigma_k_dn_raw = math.sqrt(math.max(var_k_dn, 1e-12))
        sigma_k_up_raw = math.sqrt(math.max(var_k_up, 1e-12))
        sigma_k_ceiling_dn = 3.0 * math.sqrt(math.max(sigma2_lt, sigma2_tp1_use) * k)
        sigma_k_ceiling_up = 3.0 * math.sqrt(math.max(sigma2_lt, sigma2_up_tp1_use) * k)
        sigma_k_dn = math.min(sigma_k_dn_raw, sigma_k_ceiling_dn)
        sigma_k_up = math.min(sigma_k_up_raw, sigma_k_ceiling_up)

        up_k  = anchor_close * math.exp(z_hi_primary * sigma_k_up)
        dn_k  = anchor_close * math.exp(z_lo_primary * sigma_k_dn)
        mid_k = anchor_close

        x_k    = x1 + k
        x_prev = x1 + k - 1

        seg_up = line.new(x_prev, prev_up, x_k, up_k, xloc=xloc.bar_index, color=upper_color, width=line_width, extend=extend.none)
        seg_dn = line.new(x_prev, prev_dn, x_k, dn_k, xloc=xloc.bar_index, color=lower_color, width=line_width, extend=extend.none)
        array.push(up_segments, seg_up)
        array.push(dn_segments, seg_dn)

        if show_mid
            seg_mid = line.new(x_prev, prev_mid, x_k, mid_k, xloc=xloc.bar_index, color=mid_color, width=math.max(1, line_width - 1), style=line.style_dashed, extend=extend.none)
            array.push(mid_segments, seg_mid)

        if fill_on
            lf = linefill.new(seg_up, seg_dn, fill_color)
            array.push(band_fills, lf)

        prev_up  := up_k
        prev_dn  := dn_k
        prev_mid := mid_k

        if show_marks
            lab_up = label.new(x_k, up_k, "●", xloc=xloc.bar_index, style=label.style_label_center, color=color.new(color.black, 100), textcolor=resolved_mark_up, size=size.small, yloc=yloc.price)
            lab_dn = label.new(x_k, dn_k, "●", xloc=xloc.bar_index, style=label.style_label_center, color=color.new(color.black, 100), textcolor=resolved_mark_dn, size=size.small, yloc=yloc.price)
            array.push(values_up, lab_up)
            array.push(values_dn, lab_dn)

        if show_values
            v_up = label.new(x_k, up_k, str.tostring(up_k, format.mintick), xloc=xloc.bar_index, style=label.style_label_down, color=color.new(color.black, 100), textcolor=upper_color, size=size.tiny, yloc=yloc.price)
            v_dn = label.new(x_k, dn_k, str.tostring(dn_k, format.mintick), xloc=xloc.bar_index, style=label.style_label_up,   color=color.new(color.black, 100), textcolor=lower_color, size=size.tiny, yloc=yloc.price)
            array.push(values_up, v_up)
            array.push(values_dn, v_dn)

    box_y = final_mid
    sigma_t_annual   = sigma_t_use   * math.sqrt(252) * 100
    sigma_tp1_annual = sigma_tp1_use * math.sqrt(252) * 100
    sigma_h_pct      = sigma_final * 100

    // ═══ VOL LABEL INSIDE THE ZONE (σ_{t+1}) ═══
    if show_vol_label
        vol_x_off = math.max(1, int(math.round(horizon / 2.0)))        
        vol_x = anchor_x + 3
        vol_y = anchor_close      
        trend_arrow = trend_disp > 0.15 ? "↑ : favors puts" : trend_disp < -0.15 ? "↓ : favors calls" : "• flat"
        sig_lbl = lev_asym ? "σ↓ " : "σ " //xxx
        vol_txt = "σ " + str.tostring(sigma_tp1_annual, "#.#") + "%\n" + "drift " + (trend_disp >= 0 ? "+" : "") + str.tostring(trend_disp, "0.00") + "  " + trend_arrow
        vol_label := label.new(vol_x, vol_y, vol_txt, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(#2a2a2e, 35), textcolor=#f2eee6, size=size.normal)

    half_life_days = p_use_safe < 0.9999 and p_use_safe > 0 ? math.log(0.5) / math.log(p_use_safe) : na
    ceiling_active = sigma_final_raw > sigma_h_ceiling
    ceiling_str = ceiling_active ? "  [CAPPED]" : ""
    nu_str = best_nu >= 30.0 ? "∞ (Gauss)" : str.tostring(best_nu, "#.#")
    leverage_asym = best_delta > 0 ? best_delta / (2.0 * best_alpha + best_delta + 1e-9) : 0.0
    start_str = best_start == 1 ? "lit" : best_start == 2 ? "high-vol" : "calm"
    bound_str = n_at_bound > 0 ? "  ⓘ " + str.tostring(n_at_bound) + " constrained" : ""

    mode_str = "FHS+GPD"
    var_str  = use_component ? "2-comp (τ=EWMA-RV LR / GJR SR)" : "1-comp (legacy)"
    fhs_status_str = fhs_available ? "✓ (n=" + str.tostring(fhs_n) + ")" : "n/a (fallback t)"
    fhs_q_str = fhs_available ? str.tostring(fhs_q_lo, "#.##") + " / " + str.tostring(fhs_q_hi, "#.##") : "—"
    fhs_moments_str = fhs_available ? "skew=" + str.tostring(fhs_skew, "#.##") + " exkurt=" + str.tostring(fhs_kurt, "#.##") : "—"
    gpd_xi_str = (na(gpd_xi_lo) ? "body" : str.tostring(gpd_xi_lo, "#.##")) + " / " + (na(gpd_xi_hi) ? "body" : str.tostring(gpd_xi_hi, "#.##"))

    psi_str = lev_asym ? "ψ=" + str.tostring(nz(psi_live, 1.0), "#.##") + " (n=" + str.tostring(nz(n_red_live, 0), "#.") + " post-red)" : "off (ψ≡1, symmetric)"
    sigma_updn_str = "σ_up " + str.tostring(sigma_up_tp1_use*100, "#.##") + "%  /  σ_dn " + str.tostring(sigma_tp1_use*100, "#.##") + "%"

    earn_str = ignore_earnings ? str.tostring(n_earnings_total) + " events  · neutralized: " + str.tostring(n_gap_bars_total) + " bars  (" + str.tostring(lookback) + "d win)" : str.tostring(n_earnings_total) + " events  · NOT filtered  (" + str.tostring(lookback) + "d win)"

    // Trend (drift) gauge readout — descriptive direction, never in the bands (§5a/§7.12).
    trend_sgn = trend_disp >= 0 ? "+" : ""
    trend_tag = trend_disp > 0.15 ? "↑ puts cushioned" : trend_disp < -0.15 ? "↓ calls cushioned" : "flat"
    trend_str = "Trend (drift " + str.tostring(trend_win) + "d): " + trend_sgn + str.tostring(trend_disp, "0.00") + "  " + trend_tag

    if diag_mode == "Detailed"
        header_line = "Upper:  " + str.tostring(final_up, format.mintick) + "  (+" + str.tostring((final_up/anchor_close - 1)*100, "#.##") + "%)\n" +
                      "Lower:  " + str.tostring(final_dn, format.mintick) + "  ("  + str.tostring((final_dn/anchor_close - 1)*100, "#.##") + "%)\n"

        earn_flag = ignore_earnings ? "earn-clean ON" : "earn-clean OFF"
        txt = "OPB [" + display_mode + "] (" + mode_str + " · div-adj · " + earn_flag + ")  ·  conf " + str.tostring(conf_pct, "#.#") + "%\n" +
              header_line +
              "Variance: " + var_str + "\n" +
              "── Calibrated (MAP-style + moments, start: " + start_str + ") ──\n" +
              "α=" + str.tostring(best_alpha, "#.###") + "  β=" + str.tostring(best_beta, "#.###") + "\n" +
              "δ=" + str.tostring(best_delta, "#.###") + "  γ=" + str.tostring(g_use, "#.###") + "  ν=" + nu_str + "\n" +
              "ψ_s short-run=" + str.tostring(p_use, "#.###") + (na(half_life_days) ? "" : "   t½(SR)=" + str.tostring(half_life_days, "#.#") + "d") + "\n" +
              "Long-run σ_LR=" + str.tostring(math.sqrt(tau_anchor)*100, "#.##") + "%  (t½(LR)=" + str.tostring(lr_halflife) + "d)\n" +
              "Leverage share: " + str.tostring(leverage_asym*100, "#.") + "%\n" +
              "-logPost = " + str.tostring(best_nlp, "#.") + "   ResQual = " + str.tostring(best_rq, "#.##") + bound_str + "\n" +
              "Robust (Huber): c=" + str.tostring(c_nu_active, "#.##") + "σ  ·  " + str.tostring(n_winsor_live) + " obs winsor.\n" +
              "── Volatility ──\n" +
              "σ_t (1d, pre-shock):     " + str.tostring(sigma_t_use*100, "#.##") + "%   (ann " + str.tostring(sigma_t_annual, "#.#") + "%)\n" +
              "σ_t+1 ↓ (1d, drives lower band): " + str.tostring(sigma_tp1_use*100, "#.##") + "%   (ann " + str.tostring(sigma_tp1_annual, "#.#") + "%)\n" +
              trend_str + "\n" +
              "Lev-asym: " + psi_str + "\n" +
              "  " + sigma_updn_str + "\n" +
              "σ_unc (" + str.tostring(lookback) + "d ref): " + str.tostring(math.sqrt(sigma2_lt)*100, "#.##") + "%\n" +
              "σ_h (" + str.tostring(horizon) + "d): " + str.tostring(sigma_h_pct, "#.##") + "%" + ceiling_str + "\n" +
              "── Quantiles (1-day, standardized) ──\n" +
              "Tail [FHS+GPD]: " + str.tostring(z_lo_primary, "#.##") + " / " + str.tostring(z_hi_primary, "#.##") + "\n" +
              "GPD ξ: " + gpd_xi_str + "   n_exc: " + str.tostring(gpd_nexc_lo) + "/" + str.tostring(gpd_nexc_hi) + "\n" +
              "FHS body: " + fhs_q_str + "   " + fhs_status_str + "\n" +
              "t (fallback): " + str.tostring(z_lo, "#.##") + " / " + str.tostring(z_hi, "#.##") + "\n" +
              "── Residuals ──\n" +
              "FHS moments (calibrated): " + fhs_moments_str + "\n" +
              "ρ₁ shrunk: " + str.tostring(r1, "#.###") + "   VR/h: " + str.tostring(vr_ratio_h, "#.##") + "\n" +
              "── Corporate actions ──\n" +
              "Div events (" + str.tostring(lookback) + "d win): " + str.tostring(n_div_total) + "   (splits auto-handled by feed)\n" +
              "Earnings: " + earn_str
        info := label.new(x2, box_y, txt, xloc=xloc.bar_index, style=label.style_label_left, color=label_bg_color, textcolor=label_text_color, size=size.small)


// ═══ BACKTEST BOX ═══
    if backtest_on and bt_n_J > 0
        bt_quantile_str = "FHS+GPD"
        theo_close_pct = conf_pct
        theo_tail_pct = (100.0 - conf_pct) / 2.0
        bt_asym_str = lev_asym ? "lev-asym ON · mean ψ=" + str.tostring(nz(bt_psi_mean, 1.0), "#.##") : "lev-asym OFF (symmetric)"

        bt_txt = "── WALK-FWD BACKTEST [" + bt_quantile_str + " · " + var_str + "] ──\n" +
                 "Win: " + str.tostring(bt_n_J) + "d · Recals: " + str.tostring(bt_n_recals) + " (" + recal_freq + ")\n" +
                 "tol: " + str.tostring(tolerance_bp, "#.") + " bp · F_t-aligned · rolling FHS win\n" +
                 bt_asym_str + "\n" +
                 "Theo: Close-in " + str.tostring(theo_close_pct, "#.#") + "% · Brch " + str.tostring(theo_tail_pct, "#.##") + "%/side\n" +
                 "\n" +
                 "h │ Close in │ Brch+  │ Brch-  │ NT up │ NT dn │ NT both\n" +
                 "──┼──────────┼────────┼────────┼───────┼───────┼────────\n"

        for h = 1 to backtest_horizon
            c_in   = array.get(bt_close_in,     h-1)
            b_up   = array.get(bt_breach_up,    h-1)
            b_dn   = array.get(bt_breach_dn,    h-1)
            nt_up  = array.get(bt_notouch_up,   h-1)
            nt_dn  = array.get(bt_notouch_dn,   h-1)
            nt_bo  = array.get(bt_notouch_both, h-1)
            n_eff_h = bt_n_J
            pct_in   = 100.0 * c_in  / math.max(n_eff_h, 1)
            pct_bup  = 100.0 * b_up  / math.max(n_eff_h, 1)
            pct_bdn  = 100.0 * b_dn  / math.max(n_eff_h, 1)
            pct_ntu  = 100.0 * nt_up / math.max(n_eff_h, 1)
            pct_ntd  = 100.0 * nt_dn / math.max(n_eff_h, 1)
            pct_ntb  = 100.0 * nt_bo / math.max(n_eff_h, 1)
            s_in  = pct_in  < 10.0 ? " " + str.tostring(pct_in,  "#0.0") : str.tostring(pct_in,  "#0.0")
            s_bup = pct_bup < 10.0 ? " " + str.tostring(pct_bup, "#0.0") : str.tostring(pct_bup, "#0.0")
            s_bdn = pct_bdn < 10.0 ? " " + str.tostring(pct_bdn, "#0.0") : str.tostring(pct_bdn, "#0.0")
            s_ntu = pct_ntu < 10.0 ? " " + str.tostring(pct_ntu, "#0.0") : str.tostring(pct_ntu, "#0.0")
            s_ntd = pct_ntd < 10.0 ? " " + str.tostring(pct_ntd, "#0.0") : str.tostring(pct_ntd, "#0.0")
            s_ntb = pct_ntb < 10.0 ? " " + str.tostring(pct_ntb, "#0.0") : str.tostring(pct_ntb, "#0.0")
            bt_txt := bt_txt + str.tostring(h) + " │  " + s_in + "%   │ " + s_bup + "%  │ " + s_bdn + "%  │ " + s_ntu + "% │ " + s_ntd + "% │ " + s_ntb + "%\n"

        bt_txt := bt_txt + "\nNT = No-Touch [J+1..J+h]\n" +
                 "NT dn ≈ prob. strike held (short put)\n" +
                 "Walk-fwd: recal " + recal_freq + ", no look-ahead, F_t-aligned"

        bt_x = diag_mode == "Detailed" ? x2 + horizon + 2 : x2
        bt_y = math.avg(final_up, final_dn)
        bt_label := label.new(bt_x, bt_y, bt_txt, xloc=xloc.bar_index, style=label.style_label_left, color=bt_bg_color, textcolor=bt_text_color, size=size.small)

    // ═══ PIT CONDITIONAL DIAGNOSTIC BOX ═══
    if show_pit and backtest_on and bt_n_J > 0
        theo_tl = (1.0 - conf_pct / 100.0) / 2.0 * 100.0
        pit_txt = "── PIT CONDITIONAL DIAGNOSTIC ──\n" +
                  "Realized close → u = F(r) in the model's own CDF.\n" +
                  "Calibrated ⇒ u ~ Uniform per regime.   D = Var(PIT)·12\n" +
                  "D≈1 ok · D<1 too WIDE (over-conservative) · D>1 too narrow\n" +
                  "mean theo 0.50 · Lo/Up = realized tail-breach % (theo " + str.tostring(theo_tl, "0.0") + "%)\n" +
                  "Shock = z_J < −" + str.tostring(pit_shock_k, "0.0") + "σ · h=1 overlap-free (most reliable)\n" +
                  "\n" +
                  "  h │  n  │ mean │  D   │  Lo% │ Up%\n" +
                  "── POST-SHOCK ──────────────────────\n"
        for h = 1 to math.min(backtest_horizon, 5)
            pit_txt := pit_txt + f_pit_row(pit_n_sh, pit_su_sh, pit_su2_sh, pit_lo_sh, pit_hi_sh, h) + "\n"
        pit_txt := pit_txt + "── NORMAL ──────────────────────────\n"
        for h = 1 to math.min(backtest_horizon, 5)
            pit_txt := pit_txt + f_pit_row(pit_n_no, pit_su_no, pit_su2_no, pit_lo_no, pit_hi_no, h) + "\n"
        pit_txt := pit_txt + "\nRead h=1: SHOCK D ≪ NORMAL D ⇒ bands\nover-wide post-shock (hypothesis confirmed).\nSmall shock-n ⇒ judge D, not Lo% (binary, low power)."
        pit_base_x = diag_mode == "Detailed" ? x2 + horizon + 2 : x2
        pit_x = pit_base_x + horizon + 2
        pit_y = math.avg(final_up, final_dn)
        pit_label := label.new(pit_x, pit_y, pit_txt, xloc=xloc.bar_index, style=label.style_label_left, color=pit_bg_color, textcolor=pit_text_color, size=size.small)
````
