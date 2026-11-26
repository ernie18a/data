# Markov Regime Oscillator PRO

- url: https://www.tradingview.com/script/UG17A6RD-Markov-Regime-Oscillator-PRO/
- type: indicator
- pine_id: PUB;4cfabcef79cf485fa19a11342363b919
- version: 1.0

## Description

🟦 [b]Markov Regime Oscillator PRO[/b] is a quantitative regime-classification and forward-probability forecasting engine rendered as a centred oscillator panel.  Every bar is classified into one of three regimes — Bull, Bear, Sideways — using a drift-adjusted, volatility-normalised k·σ·√N threshold.  The regime sequence feeds two parallel semi-Markov transition matrices (Young / Mature) with exponentially-decayed counts, producing live N-bar forward probabilities and 95 % Bayesian credible intervals on the next-bar probability vector.

The indicator integrates nine analytical layers — drift-adjusted classification, adaptive k·σ·√N threshold, EWMA-decayed transition matrix, semi-Markov duration conditioning, N-bar forecast cone via matrix iteration, Bayesian credible intervals, stationary distribution, velocity precursor with optional momentum filter, and multi-timeframe confluence — each rendered on a single oscillator panel through reference levels, a regime ribbon, gradient fill, three-layer neon glow signals, and an in-panel forecast polyline.  A 30-row PRO status dashboard rendered on the main price chart (not the oscillator panel) reports every readout in real time.

Built with mathematical honesty.  Every +1 forward probability carries a 95 % Dirichlet-posterior credible interval, the EWMA half-life is user-set so the model can adapt as market character evolves (2020 ≠ 2024), the semi-Markov split splits the chain on regime age so mature trends are not treated like young ones, and the documentation is explicit about what the model can and cannot predict.


[b]🟦 HOW THE CORE ENGINE WORKS[/b]

[b]Regime Classification[/b]

Each bar, the engine measures the rolling N-bar log return — optionally adjusted for the long-term drift of the asset:

logRet_raw = log(close / close[N])
meanDrift  = SMA(log(close / close[1]), driftWin)
logRet     = logRet_raw − N × meanDrift     (when Drift Adjustment is ON)

The bar is labelled by comparing this return against the configured boundary:

- `logRet > +threshold` → BULL
- `logRet < −threshold` → BEAR
- otherwise → SIDEWAYS

The classification runs every bar with no look-ahead.  When the optional Momentum Filter is enabled, the Bull / Bear labels additionally require the oscillator velocity to agree with the direction — killing late entries on exhausted moves.

[b]Adaptive Threshold (k · σ · √N)[/b]

Traditional Markov regime indicators use a fixed percentage cut — e.g. "±5 % over 20 bars".  This collapses on real markets: the same 5 % is trivial in a 2017 mania and never reached in 2023 chop.  The fix is to scale the boundary with realised volatility:

threshold_adaptive = k × σ × √N

where σ is the per-bar log-return standard deviation over a configurable window (default 100 bars).  Under a random walk, k = 1.0 cuts at the 16th / 84th percentiles; k = 2.0 at the 2.5th / 97.5th percentiles.  The default k = 1.5 reproduces classic ±1.5-sigma thresholds.

Fixed-percentage mode is still available for users who want to lock the threshold deliberately.

[b]Drift Adjustment (Alpha-Adjusted Classification)[/b]

Strong-trending markets (long BTC bull runs, persistently uptrending equity indices) carry a non-zero baseline drift.  Without adjustment, the rolling log return systematically exceeds zero in such markets — producing excessive Bull-regime flips that reflect baseline drift rather than incremental kinetic energy.

The fix is to subtract the long-term mean drift before threshold comparison:
logRet_excess = log(close / close[N]) − N × mean(log returns, driftWin)


Log returns become EXCESS returns over the asset's own long-run drift — what quant desks call "alpha-adjusted" classification.  The default 250-bar drift window approximates one trading year on the daily timeframe.

[b]Oscillator Value[/b]

The classified log return is normalised by the active threshold and scaled to ±100 = boundary, clipped at ±300:

oscVal = clip( logRet / threshold × 100, ±300 )

The oscillator value is the central panel signal.  Reference levels at ±100 (solid) mark the official regime boundaries, ±70 (dashed) mark the pending early-warning zone, and 0 (dashed) is the neutral midline.

[b]Regime Confidence[/b]

Once classified, the move's strength is normalised relative to the active boundary:

confidence = |logRet| / threshold

| Confidence | Tier | Visual |
|---|---|---|
| < 1.0× | weak | ▱▱▱ |
| 1.0× – 2.0× | moderate | ▰▱▱ |
| 2.0× – 3.0× | strong | ▰▰▱ |
| ≥ 3.0× | stretched | ▰▰▰ |

The confidence value feeds the High Confidence alert (≥ 2.5× trigger) and is reported in the Status dashboard.


[b]🟦 EWMA DECAY ON TRANSITION COUNTS[/b]

[b]The Ancient-History Problem[/b]

A classic Markov chain counts every historical transition with equal weight — a Bull→Bear flip from five years ago contributes the same as one from yesterday.  This breaks when market character changes: the 2020 COVID crash regime dynamics are not the same as 2024 retail mania, but a vanilla counter weighs them identically.

[b]The Refinement (EWMA / RiskMetrics-style decay)[/b]

Markov Regime Oscillator PRO applies exponential decay to the transition counts every confirmed bar BEFORE incrementing for the new transition:

decayFactor = 0.5 ^ (1 / halfLife)
counts[k]   = counts[k] × decayFactor     (all 9 cells, every bar)
counts[idx] = counts[idx] + 1.0           (new transition)

After `halfLife` bars, an old count weighs HALF its original.  This is the same math RiskMetrics uses for EWMA volatility — adapted here to regime transition memory.

| Half-life | Behaviour |
|---|---|
| 50 – 200 | highly reactive — adapts fast, probabilities noisy |
| 300 – 700 | balanced (default 500) |
| 1000+ | stable — slow adaptation, smooth probabilities |

The decay is applied to all three matrices in lockstep (full, young, mature) so the semi-Markov split below stays internally consistent.


[b]🟦 SEMI-MARKOV DURATION CONDITIONING[/b]

[b]The Memoryless Problem[/b]

A standard Markov chain says: "Given I'm in Bull, the probability of staying Bull tomorrow is X — regardless of whether Bull started yesterday or 200 bars ago."  This is the memoryless property, and on real markets it's wrong.  A 200-bar-old Bull regime carries different mean-reversion risk than a 5-bar-old one.

[b]The Refinement[/b]

Markov Regime Oscillator PRO additionally builds two CONDITIONAL transition matrices:

- `P_young` — transitions counted when the source regime's age was below the Age Median input
- `P_mature` — transitions counted when the source regime's age was at or above the Age Median

Both matrices are constructed in parallel with the unconditional matrix, using the same per-bar bucketing logic, the same EWMA decay, and the same Dirichlet smoothing.

The active forecast then uses the matrix matching the CURRENT regime's tier — Young or Mature.  A 5-bar-old Bull is statistically more likely to continue than a 50-bar-old one; semi-Markov captures this empirically without leaking into the unconditional chain.

The active matrix tier is reported live in the Status dashboard's "Matrix" cell.


[b]🟦 N-BAR FORECAST CONE[/b]

[b]Matrix Iteration[/b]

The 3×3 transition matrix P encodes one-bar-ahead probabilities.  To project further out, the state vector is iterated through P:

s_0     = [P(Side), P(Bull), P(Bear)] = unit vector on current regime
s_{k+1} = s_k · P                      (matrix multiplication)

For each step k = 1 … forecastSteps, the iteration produces the probability of each regime at that future bar.

[b]Expected Oscillator Value[/b]

At each forecast step, the expected oscillator value is computed as:

E[osc | k] = 100 · ( P(Bull | k) − P(Bear | k) )

This number is +100 when the model expects pure Bull, −100 when pure Bear, and ~0 when Side.

[b]In-Panel Polyline[/b]

The cone is rendered as a colored polyline extending PAST the last confirmed bar into the future, drawn via `line.new()` so segments are pixel-stable on any chart zoom.  Each segment is colored by the dominant regime at that step (Bull / Bear / Side).

[b]Honest Limitation[/b]

The cone is reliable up to ~5 bars; beyond that the iteration converges toward the stationary distribution and the forecast loses information.  The default Forecast Horizon is 5 bars — covers the meaningful window without illusion.

The forecast is matrix-implied, not a momentum extrapolation.  If the oscillator is currently at +250 (strong Bull) but the matrix says P(Bull → Side) is high, the cone will regress to the matrix-implied expected value — showing a visual "cliff" at step 1.  This is mathematically honest, not a bug.

The dashboard's "HORIZON +N" cell reports the dominant regime at the terminal forecast step plus its probability — for a single-glance read of where the chain expects to be at horizon end.


[b]🟦 BAYESIAN CREDIBLE INTERVALS[/b]

[b]Why Ranges, Not Point Estimates[/b]

A forecast like "P(Bull) +1 = 75 %" carries hidden uncertainty.  With only 30 historical Bull-source transitions, the true probability could plausibly be anywhere between 55 % and 90 %.  With 2000 historical Bull-source transitions, the same 75 % is tightly bracketed at, say, 73 – 77 %.

Reporting a single number hides the difference.  Hedge-fund and academic forecasts always carry uncertainty bands; this oscillator does the same.

[b]The Derivation (Dirichlet Posterior, Gaussian Approximation)[/b]

The transition matrix posterior is Dirichlet(α + counts) with Laplace (α = 1) prior.  Each marginal is Beta with parameters (α_i, Σα − α_i).  The Gaussian approximation to that Beta gives:

mean    = α_i / Σα
var     = α_i · (Σα − α_i) / ( Σα² · (Σα + 1) )
95 % CI ≈ mean ± 1.96 · √var

The CI is computed for the +1 row (the most actionable forecast) and clipped to [0, 1].

[b]Reading the Dashboard[/b]

P(Bull) +1     75 % [68 – 82]

| CI Width | Interpretation |
|---|---|
| Narrow (e.g. 73 – 77) | large sample, robust estimate, trust the call |
| Wide (e.g. 50 – 95) | small sample, fragile estimate, don't bet the desk |

This is the difference between a quantitative estimate and an indicator guess.


[b]🟦 STATIONARY DISTRIBUTION π[/b]

Power-iterating the matrix to convergence yields the stationary distribution — the long-run probability of being in each regime, independent of the current state.  With 50 iterations on a well-behaved stochastic matrix, the distribution is essentially converged.

π(Side) + π(Bull) + π(Bear) = 1.0

The dashboard's "STATIONARY π" section reports each component.  Reading π reveals the asset's structural bias regardless of the current regime — e.g., π(Bull) = 55 % on BTC daily tells you the market spends a majority of its time in Bull regimes over the long run, which is fundamentally different from a sideways-grinding instrument with π(Side) = 60 %.

The stationary distribution also serves as the asymptote of the forecast cone: as k → ∞, the cone collapses to π.


[b]🟦 VELOCITY PRECURSOR & MOMENTUM FILTER[/b]

[b]Velocity Definition[/b]

The oscillator velocity is the N-bar rate-of-change of the oscillator value:

velocity = oscVal − oscVal[velocityWin]
velocityThr = VELOCITY_BASE · √(velocityWin / 5)

The threshold auto-scales with the window so the accel / decel / flat labels stay meaningful at any setting.

[b]Early-Warning Cue[/b]

Velocity flips direction BEFORE the official ±100 boundary is crossed — it is a leading indicator of regime change.  The Status dashboard's "Velocity" cell displays:

- ↑ accelerating (velocity > +threshold) — colored bull
- ↓ decelerating (velocity < −threshold) — colored bear
- ═ flat — neutral

This partially mitigates the inherent lookback lag of threshold-based regime detection.

[b]Optional Momentum Filter[/b]

When the Momentum Filter is enabled, regime classification additionally requires velocity sign agreement:

Bull → logRet > +threshold AND velocity > 0
Bear → logRet < −threshold AND velocity < 0

This kills late-entry signals where price has extended past the threshold but momentum is already exhausted — a classic source of false signals at trend tops/bottoms.  Reduces signal count, raises signal quality.  Recommended for swing trading, optional for scalping.


[b]🟦 PENDING-REGIME EARLY WARNING[/b]

Because the regime is classified from `log(close / close[N])`, the official regime label inherently lags.  This is structural, not a bug, but can be partially mitigated.

Inside Sideways, when the log return reaches 70 % of either boundary, the dashboard fires an early-warning cue:

distance_fraction = max(|logRet| / threshold, ...)
isPending = (regime == SIDE) AND (distance_fraction ≥ 0.70)

The Status panel's "Pending" cell displays the direction the return is leaning toward and the current fraction:

⚠ ▲ BULL  87 %

Color matches the leaning regime.  The Pending Regime alert (default OFF, opt-in) fires on the first bar a pending state is entered.

This is not a regime change signal — it's a "watch this" cue, triggered roughly 30 % before the official threshold is crossed.  Used alongside the official regime change, it gives the user advance notice without compromising the threshold's strictness.


[b]🟦 SELECTABLE SIGNAL SMOOTHING[/b]

A second smoothed signal line overlays the main oscillator.  Crossovers between the main and signal lines mark momentum-of-regime shifts — these often precede actual regime changes by 1-3 bars.

Four smoothing algorithms are available:

| Method | Character |
|---|---|
| EMA (default) | Exponential — classic lag/smoothness |
| HMA | Hull — near-zero lag for short windows |
| ALMA | Arnaud Legoux (0.85, 6.0) — Gaussian-weighted, smoothest |
| SMA | Simple — most stable, most lag |

The Signal Cross alert can be optionally filtered by HTF alignment — when enabled, the alert fires only when LTF and HTF regimes match.  Filter is auto-bypassed when HTF Confluence is globally OFF (silent-kill protection).


[b]🟦 MULTI-TIMEFRAME CONFLUENCE[/b]

The same regime logic runs on a user-configured higher timeframe via `request.security` with `lookahead = barmerge.lookahead_off` and `gaps = barmerge.gaps_off` (anti-repaint mandatory).  The result is reported in the Status dashboard's HTF block:

| State | Display | Color |
|---|---|---|
| HTF regime matches LTF regime | ✓ ALIGNED | bull |
| HTF regime differs from LTF | ⚠ DIVERGENT | bear |
| Insufficient HTF data | — | foreground |

Divergent regimes are common at trend turns — the LTF flips before the HTF catches up.  Aligned regimes carry higher conviction.  A separate alert ("MTF Confluence") fires on regime entries only when the HTF agrees.

Recommended pairings:

| Chart | HTF |
|---|---|
| 15m | 1H |
| 1H | D |
| 4H | W |
| D | W |
| W | M |

Use at least 3× your chart timeframe — anything closer and the two regimes track each other with no information gain.


[b]🟦 OSCILLATOR PANEL VISUAL LAYER[/b]

[b]Main Oscillator Line[/b]

The oscillator value plotted as a continuous line with five color tiers reflecting regime strength:

| Range | Color |
|---|---|
| ≥ +100 | full Bull |
| +70 to +100 | dim Bull (pending up) |
| −70 to +70 | neutral Side |
| −100 to −70 | dim Bear (pending down) |
| ≤ −100 | full Bear |

Line width is configurable 1 – 5 pixels.

[b]Signal Line[/b]

A smoothed overlay of the main oscillator, faded foreground color, single-pixel width.  Drives the Signal Cross alert and the dashboard Signal cell.

[b]Reference Levels[/b]

Three horizontal levels per panel side:

- ±100 — official regime boundaries (solid plot line)
- ±70  — pending early-warning zones (dashed `line.new`)
- 0    — neutral midline (dashed `line.new`)

The dashed lines use `line.new()` rather than `plot.style_circles` so they remain pixel-stable at any chart zoom — they will NOT rescale or fragment.

[b]Regime Ribbon[/b]

The oscillator panel background is tinted to the current regime color at 20 % opacity.  Provides instant regime context at a glance — Bull / Bear / Side periods are visually separated even when zoomed out on long history.  Toggleable.

[b]Gradient Fill[/b]

The area between the oscillator line and zero is filled in the regime color, with intensity scaling adaptively by distance from zero — stronger color = higher conviction.  Empty at zero.

[b]Three-Layer Neon Glow Signals[/b]

On every confirmed regime transition (after the Min Hold filter passes), the indicator drops a three-layer halo on the oscillator line:

| Layer | Size | Transparency | Purpose |
|---|---|---|---|
| Outer | size.large | 80 % | Soft halo |
| Middle | size.normal | 50 % | Mid-glow |
| Core | size.small | 0 % | Bright center |

Bull entries (▲ triangle up), Bear entries (▼ triangle down), and Side entries (◆ diamond).  The Min Hold input (default 4 bars) requires a new regime to persist before its flip is drawn — kills label spam in choppy zones without affecting the underlying transition counts.

[b]Forecast Cone Polyline[/b]

On the last confirmed bar, a colored polyline extends into the future for N bars, plotting the expected oscillator value at each step.  Color reflects the dominant regime at that step.  Drawn with `line.new()` so segments are pixel-stable; recomputed on every chart refresh.


[b]🟦 PRO STATUS DASHBOARD[/b]

A single dashboard rendered on the MAIN PRICE CHART (not the oscillator panel) via `force_overlay = true`.  This keeps the oscillator panel uncluttered so the oscillator line, signal line, gradient fill, and forecast cone get the full pane height.

The dashboard is structured in seven sections, all theme-aware:

| Section | Cells |
|---|---|
| REGIME | Regime, Age + tier, Confidence, Pending, Velocity |
| FORECAST +1 | P(Bull), P(Bear), P(Side) — each with 95 % CI |
| HORIZON +N | Dominant regime at terminal forecast step + probability |
| STATIONARY π | π(Bull), π(Bear), π(Side) — long-run equilibrium |
| OSCILLATOR | Value, Signal direction, Threshold, Drift basis points |
| HTF | Regime + Aligned / Divergent status |
| DATA | Mode, Decay half-life, Matrix tier, Sample N |

Position is configurable across 9 chart corners.  Text size: Tiny / Small / Normal / Large.  Default Tiny so the full 30-row layout fits on any chart without scrolling.  Background and text colors flip between Dark and Light display modes.


[b]🟦 COLOR THEMES[/b]

Ten cohesive palettes tuned to the Apex design system, each defining three regime axes (Bull, Bear, Sideways):

| Theme | Character | Bull | Bear | Sideways |
|---|---|---|---|---|
| Focus (default) | Modern | Cyan | Deep orange | Cool blue-grey |
| Prism | Classic | Forest green | Crimson | Slate grey |
| Solar | Warm | Amber | Indigo red | Lavender grey |
| Frost | Cool | Sky blue | Soft lavender | Pale steel |
| Laser | Neon | Lime green | Hot crimson | Charcoal grey |
| Aurora | Bright | Gold | Scarlet | Warm beige |
| Plasma | Electric | Aqua | Magenta | Slate teal |
| Bloom | Soft | Mint | Hot pink | Blue-grey |
| Eclipse | Deep | Navy | Dark crimson | Steel grey |
| Carbon | Minimal | Near-white | Mid-grey | Dark grey |

One theme selection drives every visual component: oscillator line, signal line, reference levels, ribbon, fill, glow signals, forecast cone, and all dashboard cells.

[b]Dark / Light Display Mode[/b]

Dashboard chrome (background, foreground, borders, section dividers) flips between dark-on-bright and bright-on-dark.  The regime axis colors remain consistent across modes — only the panel chrome changes.


[b]🟦 ALERT SYSTEM[/b]

Seven alert conditions, each independently togglable:

| Alert | Condition |
|---|---|
| Bull Regime Entry | Regime flipped to BULL (after Min Hold confirmation) |
| Bear Regime Entry | Regime flipped to BEAR (after Min Hold confirmation) |
| Sideways Regime Entry | Regime flipped to SIDEWAYS (default OFF) |
| High Confidence | confidence ≥ 2.5× threshold, first bar of crossing |
| Pending Regime | Inside Sideways, log return ≥ 70 % of either boundary (default OFF) |
| MTF Confluence | Bull / Bear entry + HTF agrees |
| Signal Cross | Main oscillator crosses signal line (default OFF) |

All alerts fire on confirmed bar close.  Entry alerts respect the Min Hold filter — a new regime must persist Min Hold bars before its entry alert fires, matching the on-chart glow markers.

The Signal Cross alert can be optionally filtered by HTF alignment (Multi-Timeframe → Filter Signal Cross by HTF).  The filter is automatically bypassed when HTF Confluence is globally OFF, so enabling the filter without HTF doesn't silently kill the alert.


[b]🟦 SETTINGS REFERENCE[/b]

[b]Theme[/b]
- Theme — One of 10 Apex palettes.  Default: Focus
- Display Mode — Dark / Light.  Default: Dark

[b]Regime Logic[/b]
- Threshold Mode — Adaptive (k·σ·√N) / Fixed (%).  Default: Adaptive
- Lookback Window — Bars for the rolling log return.  Default: 20
- Adaptive k — Sigma multiplier.  Default: 1.5
- Fixed Bull Threshold — Used only in Fixed mode.  Default: 5.0 %
- Fixed Bear Threshold — Used only in Fixed mode.  Default: 5.0 %
- Volatility Window — Bars for the per-bar stdev.  Default: 100
- Min Hold — Bars a new regime must persist for entry alerts and glow markers.  Default: 4
- Drift-Adjusted Log Returns — Toggle the drift adjustment.  Default: ON
- Drift Window — Bars for the long-term mean drift estimate.  Default: 250
- Require Momentum Agreement — Velocity sign filter on regime classification.  Default: OFF

[b]Bayesian Math[/b]
- EWMA Transition Counts (Decay) — Toggle exponential decay.  Default: ON
- Decay Half-Life — Bars after which an old count weighs half.  Default: 500
- Semi-Markov Duration Conditioning — Toggle the Young / Mature split.  Default: ON
- Age Median — Boundary between Young and Mature regimes.  Default: 10
- Bayesian Credible Intervals (95 %) — Toggle CI display in the dashboard.  Default: ON

[b]Forecast[/b]
- Forecast Cone Horizon — Number of bars projected by matrix iteration.  Default: 5
- Show Forecast Cone — Toggle the in-panel cone polyline.  Default: ON

[b]Oscillator[/b]
- Show Signal Line — Toggle the smoothed signal overlay.  Default: ON
- Signal Smoothing Method — EMA / HMA / ALMA / SMA.  Default: EMA
- Signal Smoothing Length — Window length.  Default: 5
- Velocity Window — Bars for the rate-of-change measurement.  Default: 5
- Oscillator Line Width — Pixels.  Default: 2

[b]Display[/b]
- Show Regime Ribbon — Toggle the panel background tint.  Default: ON
- Show Gradient Fill — Toggle the oscillator-vs-zero fill.  Default: ON
- Show Reference Levels — Toggle the ±100 / ±70 / 0 horizontal lines.  Default: ON
- Show Regime Change Glow — Toggle the three-layer halo markers.  Default: ON

[b]Multi-Timeframe[/b]
- Enable HTF Confluence — Toggle.  Default: ON
- HTF Resolution — Higher timeframe.  Default: D
- Filter Signal Cross by HTF Alignment — Conditional filter on cross alert.  Default: OFF

[b]Dashboard[/b]
- Show Status Dashboard — Toggle.  Default: ON
- Position — Nine chart corners.  Default: Top Right
- Size — Tiny / Small / Normal / Large.  Default: Tiny

[b]Alerts[/b]
- Bull / Bear / Sideways Regime Entry — Independent toggles
- High Confidence (≥ 2.5×) — Default: ON
- Pending Regime — Default: OFF
- MTF Confluence — Default: ON
- Signal Cross — Default: OFF


[b]🟦 COMPATIBILITY[/b]

Works on all asset classes and all timeframes in TradingView Pine Script v6.

- Crypto: Spot, futures, perpetual contracts
- Forex: All pairs
- Equities: Stocks, ETFs, indices
- Commodities: Metals, energy, agriculture
- Timeframes: 1m through Monthly

The adaptive threshold normalises by per-bar realised volatility, and the drift adjustment normalises by the asset's long-run mean drift — together making the regime classification volatility-and-drift-agnostic across assets without manual recalibration.  The same default settings work on BTCUSDT daily, SPY weekly, and EURUSD 4H — only the HTF resolution input should be adjusted to match the chart timeframe.


[b]🟦 TECHNICAL NOTES[/b]

- Pine Script v6
- `max_labels_count = 500`, `max_lines_count = 500`, `max_bars_back = 5000`
- No repainting — all regime classifications are computed on confirmed bar close.  The HTF request uses `lookahead = barmerge.lookahead_off` and `gaps = barmerge.gaps_off`
- Transition counting uses `barstate.isconfirmed` to avoid double-counting the live bar
- Regime change debouncing uses `ta.barssince` to avoid runtime-indexed history reads (which can trip "cannot determine max_bars_back" in Pine v6)
- Heavy computation (P matrix construction, N-step iteration, Bayesian CI math, stationary distribution power iteration, dashboard rendering) is gated on `barstate.islast` to run once per chart render
- Matrix multiplication is implemented as unrolled single-line expressions over a flat 9-cell array for portability and speed
- EWMA decay multiplies all 9 cells of all 3 matrices (counts, countsYoung, countsMature) once per confirmed bar — O(27) per bar overhead
- Dirichlet smoothing prevents NaN propagation when a regime has not appeared in visible history — empty rows fall back to uniform 1/3
- Duration buckets classify by the SOURCE regime's age at the moment of transition (`regAge[1]`), so the bucketing reflects the regime that was about to transition rather than the destination
- `ta.crossover` / `ta.crossunder` are computed at global scope every bar to satisfy Pine's stateful-series rule (the gated cross events read from the cached values)
- Dashboard is rendered with `force_overlay = true` on the main price chart — keeps the oscillator panel free of UI clutter
- Reference-level dashed lines use `line.new()` with `style = line.style_dashed` and `extend = extend.both` for pixel-stable rendering at any zoom


[b]🟦 LIMITATIONS — READ THIS[/b]

This indicator is statistically honest about what it can and cannot do.  Four known limitations:

1.  [b]The Markov assumption is partially violated.[/b]  Markets are not memoryless.  The semi-Markov Young / Mature split mitigates this but does not eliminate it.  EWMA decay further mitigates by down-weighting ancient transitions, but a truly path-dependent process (one where the SEQUENCE of recent regimes matters, not just the last one) is not captured.

2.  [b]Forward probabilities are not predictions.[/b]  They are conditional probabilities under the chain assumption with the credible intervals quantifying the SAMPLING uncertainty around them.  A "Bull 58 % at +5 bars" reading does not mean "58 % chance the next 5 bars are bullish" — it means "given a long-run sample of similar starting states and the active EWMA-decayed transition matrix, 58 % were in Bull at +5 bars".  Use the cone as ONE input alongside other analysis.

3.  [b]The regime label lags by N bars.[/b]  This is structural — the rolling log return necessarily looks back.  The Pending early warning and the optional Momentum Filter partially mitigate this but cannot eliminate the lag.  Treat the official regime change as a confirmation, not a leading signal.

4.  [b]Forecast cone reliability decays with horizon.[/b]  By +5 bars the cone is at the edge of usefulness; by +20 bars it collapses toward the stationary distribution and carries no additional information beyond π.  The default horizon is 5 bars for this reason.  Do not over-interpret the right side of the cone.


[b]🟦 DISCLAIMER[/b]

This indicator is provided for educational and informational purposes only.  It does not constitute financial advice.  Past performance does not guarantee future results.  The forward probabilities are conditional estimates derived from historical transition counts under a (semi-)Markov model assumption — they are NOT guarantees about future market behaviour.  Always conduct your own analysis and apply proper risk management.

## Source Code

````pine
//@version=6

// ═══════════════════════════════════════════════════════════════════════════════
//
//  Markov Regime Oscillator PRO — Hedge Fund Edition
//
//  Author      : a_jabbaroff
//  License     : Mozilla Public License 2.0
//  Version     : 3.0.0
//  PineScript  : v6
//
// ─── Abstract ────────────────────────────────────────────────────────────────
//
//  Markov Regime Oscillator PRO — Hedge Fund Edition is a quantitative regime-
//  classification and forward-probability forecasting engine rendered as a
//  centred oscillator panel.  Every bar is classified into one of three
//  regimes — Bull, Bear, Sideways — using a drift-adjusted, volatility-
//  normalised k·σ·√N threshold.  The regime sequence feeds two parallel
//  semi-Markov transition matrices (Young / Mature) with exponentially-
//  decayed counts, producing live N-bar forward probabilities and 95 %
//  Bayesian credible intervals for each forecast.
//
//  Nine analytical layers integrated on a single oscillator panel:
//
//    1. DRIFT-ADJUSTED REGIME CLASSIFICATION — log returns less the long-term
//       mean drift before threshold comparison.  Eliminates the systematic
//       bias where strong-trending markets generate excessive regime flips.
//
//    2. ADAPTIVE k·σ·√N THRESHOLD — boundary scales with realised volatility.
//       ±100 = official boundary, ±70 = pending early-warning zone.
//
//    3. EWMA TRANSITION MATRIX — exponentially-decayed Markov counts.  Recent
//       transitions weigh more than ancient ones (half-life user-set).  The
//       model adapts as market character evolves (2020 ≠ 2024).  Same math
//       RiskMetrics uses for EWMA volatility — applied to regime memory.
//
//    4. SEMI-MARKOV DURATION CONDITIONING — two transition matrices conditional
//       on regime age (Young vs. Mature).  Forecasts use the matrix matching
//       the current regime's duration tier — captures the empirical fact that
//       mature trends transition differently than young ones.
//
//    5. N-BAR FORECAST CONE — full forward-probability cone via matrix
//       iteration P, P², P³ … P^N rendered as an in-panel trajectory of
//       expected oscillator value extending into the future.
//
//    6. BAYESIAN CREDIBLE INTERVALS — 95 % Dirichlet-posterior CI around each
//       +1 forward probability.  Wide CI = limited data, narrow CI = robust
//       estimate.  The trader knows mathematically how much to trust the call.
//
//    7. STATIONARY DISTRIBUTION — long-run equilibrium regime probabilities
//       via power iteration on the transition matrix.  Reveals the asset's
//       structural bias regardless of current regime.
//
//    8. VELOCITY PRECURSOR & MOMENTUM FILTER — N-bar rate-of-change of the
//       oscillator value flags acceleration BEFORE the ±100 boundary is
//       crossed.  Optional Momentum Filter requires velocity sign agreement
//       at classification — kills late entries on exhausted moves.
//
//    9. MULTI-TIMEFRAME CONFLUENCE — same regime logic on a higher timeframe
//       via request.security with anti-repaint flags.  Optional signal-cross
//       filter requires HTF alignment to fire.
//
//  Hedge-fund-grade PRO status dashboard reports regime, age + duration tier,
//  confidence, pending direction, velocity, drift basis points, +1 / +N bar
//  forward probabilities with 95 % credible intervals, stationary
//  distribution, oscillator readings, HTF alignment, decay half-life, matrix
//  tier, and sample-size reliability — all theme-aware (10 Apex palettes,
//  Dark / Light display mode).  Selectable signal smoothing (EMA / HMA /
//  ALMA / SMA) and seven alert conditions cover regime entries, high-
//  confidence triggers, pending warnings, HTF confluence, and signal-line
//  crossovers.
//
//  Designed for systematic traders and hedge-fund desks who require:
//
//    · Mathematical honesty — every forecast carries a credible interval.
//    · Anti-repaint guarantees — barstate.isconfirmed gating, lookahead_off.
//    · Adaptive memory — EWMA decay so recent market behaviour dominates.
//    · Duration awareness — semi-Markov split for "young vs. mature" regimes.
//    · Multi-horizon view — +1 and +N bar forecasts on a single panel.
//
// ═══════════════════════════════════════════════════════════════════════════════

indicator("Markov Regime Oscillator PRO", "MK Regime Osc PRO",
     overlay = false, max_bars_back = 5000, max_labels_count = 500, max_lines_count = 500)


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 0   —   CONSTANTS & GROUP NAMES
// ═══════════════════════════════════════════════════════════════════════════════

const string GRP_THEME    = "Theme 🔹"
const string GRP_LOGIC    = "Regime Logic 🔹"
const string GRP_BAYES    = "Bayesian Math 🔹"
const string GRP_FCST     = "Forecast 🔹"
const string GRP_OSC      = "Oscillator 🔹"
const string GRP_DISPLAY  = "Display 🔹"
const string GRP_MTF      = "Multi-Timeframe 🔹"
const string GRP_DASH     = "Dashboard 🔹"
const string GRP_ALERT    = "Alerts 🔹"

const string MODE_ADAPT = "Adaptive (k·σ·√N)"
const string MODE_FIXED = "Fixed (%)"

const string SMTH_EMA  = "EMA"
const string SMTH_HMA  = "HMA"
const string SMTH_ALMA = "ALMA"
const string SMTH_SMA  = "SMA"

// Regime codes — values are stable: they index counts[r*3+c] and P[r*3+c].
const int R_SIDE = 0
const int R_BULL = 1
const int R_BEAR = 2

const float PENDING_FRAC  = 0.7
const float OSC_CLIP      = 300.0
const float OSC_BOUNDARY  = 100.0
const float OSC_PENDING   = 70.0

// Velocity threshold base (oscillator units, scales by sqrt(velocityWin/5)).
const float VELOCITY_BASE = 5.0

// Bayesian Dirichlet prior — alpha = 1 is the Laplace ("add-one") prior:
// equivalent to pretending we observed one transition of every type before
// the data arrived.  Standard regularisation for sparse count matrices.
const float DIRICHLET_ALPHA = 1.0

// 95 % credible-interval Z-score (Gaussian approximation to Beta posterior).
const float CI_Z95 = 1.96

// Power-iteration steps used to compute the stationary distribution.
const int STATIONARY_ITER = 50


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 1   —   INPUTS
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Theme & Display Mode ────────────────────────────────────────────────────
themeChoice = input.string("Focus", "Theme",
     options = ["Prism", "Focus", "Solar", "Frost", "Laser", "Aurora", "Plasma", "Bloom", "Eclipse", "Carbon"],
     group = GRP_THEME,
     tooltip = "Ten cohesive color palettes tuned to the Apex design system.  All five color roles (Bull / Bear / Side / accent / dim) change in lockstep — no per-color manual tuning needed.\n\nDARK-MODE THEMES:\nFocus (default) — cyan / orange — modern, balanced\nPrism  — green / red — classic trading colors\nLaser  — neon green / red — high contrast\nFrost  — sky blue / soft purple — cool, calm\nAurora — yellow / coral — warm, organic\nPlasma — cyan / magenta — neon, futuristic\nBloom  — mint green / pink — soft, floral\nEclipse — navy / scarlet — pro trader\nSolar  — orange / red — warm gold\n\nLIGHT-MODE THEMES:\nCarbon — gray / dark gray — minimalist\n\nDrives the oscillator line, fills, reference levels, glow signals, forecast cone, dashboard text, and ribbon tint.")

displayMode = input.string("Dark", "Display Mode",
     options = ["Dark", "Light"], group = GRP_THEME,
     tooltip = "Background and text color of the dashboard chrome.\n\nDark (default) — black background, light foreground.  Pairs with dark chart themes (TradingView Dark mode).\nLight — white background, dark foreground.  Pairs with light chart themes.\n\nDOES NOT affect the oscillator line, fill, or glow colors — those follow the active Theme palette and are designed to read well on both chart modes.")


// ─── Regime Logic ────────────────────────────────────────────────────────────
thrMode = input.string(MODE_ADAPT, "Threshold Mode",
     options = [MODE_ADAPT, MODE_FIXED], group = GRP_LOGIC,
     tooltip = "Adaptive — boundary = k × σ × √N, scales with realised volatility (RECOMMENDED).\n\nFixed (%) — classic ±X % cut on the N-bar log return.")

lookbackN = input.int(20, "Lookback Window (bars)", minval = 5, maxval = 250, group = GRP_LOGIC,
     tooltip = "Bars used for the rolling log return (the core regime classification window).\n\nRange: 5 – 250 bars.\n\n5 – 10 — fast, reactive, picks up minor moves but more regime flips.\n20 (default) — balanced for swing trading on daily / 4H charts.\n50 – 100 — slow, macro view, smooth regime sequence with fewer signals.\n\nFor intraday trading use 10 – 15.  For weekly setups use 50+.  Also determines the minimum bars before the indicator produces values.")

kSigma = input.float(1.5, "Adaptive k  (boundary = k · σ · √N)",
     minval = 0.25, maxval = 5.0, step = 0.25, group = GRP_LOGIC,
     tooltip = "Sigma multiplier for the adaptive threshold.  Larger k = wider boundary = fewer but higher-conviction regime flips.\n\nRange: 0.25 – 5.0 (step 0.25).\n\nFormula:  threshold = k · σ · √N\n\n0.5 – 1.0 — very sensitive, frequent regime flips, scalping-friendly\n1.5 (default) — classic ±1.5σ cut, balanced for swing trading\n2.0 – 3.0 — selective, only structurally strong moves trigger\n3.0+ — extreme moves only, position-trading view")

bullThrPct = input.float(5.0, "Fixed Bull Threshold (%)",
     minval = 0.1, maxval = 50.0, step = 0.1, group = GRP_LOGIC,
     tooltip = "Bull regime threshold as a percentage of the N-bar log return.\n\nUsed ONLY when Threshold Mode = Fixed (%).\n\nRange: 0.1 % – 50 % (step 0.1 %).\n\nTYPICAL VALUES BY MARKET:\n• Crypto (BTC daily):  5 – 10 %\n• Forex   (EURUSD D):  1 – 2 %\n• Equity  (SPX daily):  3 – 5 %\n• Commodities (Gold D): 2 – 4 %\n\nAdaptive mode (default) auto-scales by realised volatility and is strongly preferred — Fixed mode requires manual retuning across volatility regimes.")

bearThrPct = input.float(5.0, "Fixed Bear Threshold (%)",
     minval = 0.1, maxval = 50.0, step = 0.1, group = GRP_LOGIC,
     tooltip = "Bear regime threshold as a percentage of the N-bar log return.\n\nUsed ONLY when Threshold Mode = Fixed (%).\n\nRange: 0.1 % – 50 % (step 0.1 %).\n\nFor SYMMETRIC markets (most crypto, forex), set equal to Bull Threshold.\n\nFor ASYMMETRIC markets (equity indices, where crashes are sharper than rallies), set Bear lower than Bull to balance signal frequency — e.g., Bull 5 %, Bear 3 %.")

sigmaWin = input.int(100, "Volatility Window (bars)",
     minval = 20, maxval = 500, group = GRP_LOGIC,
     tooltip = "Lookback for the per-bar log-return standard deviation (σ).  Used ONLY in Adaptive mode.\n\nRange: 20 – 500 bars.\n\n20 – 50 — fast-adapting σ, picks up volatility regime changes quickly but noisier threshold\n100 (default) — balanced (~5 trading months on daily)\n200 – 500 — slow-adapting, structural volatility view\n\nThe σ estimate drives threshold = k · σ · √N — choose so the threshold tracks YOUR market's volatility cycle, not a single recent event.")

minHold = input.int(4, "Min Hold (bars)", minval = 1, maxval = 50, group = GRP_LOGIC,
     tooltip = "Bars a new regime must persist before glow markers and entry alerts fire.  Acts as a DEBOUNCING filter against rapid regime flickers.\n\nRange: 1 – 50 bars.\n\n1 — no debounce, every flip fires (noisy)\n2 – 3 — light filter, blocks single-bar flickers\n4 (default) — balanced, blocks most noise\n8+ — heavy filter, only structurally confirmed regimes pass\n\nHIGHER = fewer but higher-quality signals.  Affects both the visual glow markers AND the alert system.")

useDrift = input.bool(true, "Drift-Adjusted Log Returns", group = GRP_LOGIC,
     tooltip = "Subtract the long-term mean drift from log returns before classification.\n\nELIMINATES the systematic bias where strong-trending markets (e.g., long BTC bull runs, persistently uptrending indices) produce excessive Bull-regime flips simply due to baseline drift rather than incremental kinetic energy.\n\nLog returns become EXCESS returns over the asset's own long-run drift — what quant desks call 'alpha-adjusted' classification.")

driftWin = input.int(250, "Drift Window (bars)", minval = 50, maxval = 2000, group = GRP_LOGIC,
     tooltip = "Lookback for the long-term mean log return estimate (used for drift adjustment).\n\nRange: 50 – 2000 bars.\n\n100 — ~5 months on daily, recent-bias drift estimate\n250 (default) — ~1 year on daily, ~10 days on H1 — classic 'annualised drift' window\n500 – 1000 — multi-year structural drift\n2000 — maximum stability, deep structural drift\n\nLONGER = more stable drift estimate, less sensitive to recent moves.  Used only when Drift-Adjusted Log Returns is ON.")

filterMomentum = input.bool(false, "Require Momentum Agreement", group = GRP_LOGIC,
     tooltip = "When ON, regime classification additionally requires:\n\n  Bull → oscillator velocity > 0\n  Bear → oscillator velocity < 0\n\nKills late-entry signals where price has extended past the threshold but momentum is already exhausted (a classic source of false signals at trend tops/bottoms).\n\nReduces signal count, raises signal quality.  Recommended for swing trading, optional for scalping.")


// ─── Bayesian Math ───────────────────────────────────────────────────────────
useDecay = input.bool(true, "EWMA Transition Counts (Decay)", group = GRP_BAYES,
     tooltip = "Apply EXPONENTIAL DECAY to the transition matrix.  Each bar, every count is multiplied by a decay factor before the new transition is recorded.\n\nRESULT: recent transitions dominate the forward probabilities; ancient ones fade.\n\nThis is the same mechanism RiskMetrics uses for EWMA volatility — adapted here for regime transition memory.")

decayHalfLife = input.int(500, "Decay Half-Life (bars)", minval = 50, maxval = 5000, step = 50, group = GRP_BAYES,
     tooltip = "Number of bars after which an old transition contributes HALF its original weight.\n\n   50 –  200 — highly reactive (regime model adapts fast, noisy probabilities)\n  300 –  700 — balanced (recommended)\n  1000+      — stable (slow adaptation, smooth probabilities)\n\nFormula: decayFactor = 0.5 ^ (1 / halfLife).  Same math as nuclear half-life.")

useSemiMarkov = input.bool(true, "Semi-Markov Duration Conditioning", group = GRP_BAYES,
     tooltip = "Build TWO transition matrices conditional on regime AGE:\n\n  YOUNG matrix  — transitions observed when prior regime age < median\n  MATURE matrix — transitions observed when prior regime age ≥ median\n\nForecasts then use the matrix matching the CURRENT regime's age tier.\n\nWHY: empirically, young trends and mature trends decay differently.  A 5-bar Bull is statistically more likely to continue than a 50-bar Bull.  Pure Markov ignores this; semi-Markov captures it.")

ageMedian = input.int(10, "Age Median (Young / Mature split)", minval = 3, maxval = 100, group = GRP_BAYES,
     tooltip = "Boundary between Young and Mature regimes (in bars).  Regimes shorter than this use the Young transition matrix; ≥ this use the Mature matrix.\n\nRange: 3 – 100 bars.\n\nDefault 10 — empirically, the median Bull / Bear run on most assets falls between 5 and 15 bars on the chart timeframe.\n\nSet the value near the MEDIAN run-length of regimes on YOUR timeframe.  Too low — almost everything counts as 'Mature'.  Too high — almost everything counts as 'Young'.\n\nUsed only when Semi-Markov Duration Conditioning is ON.")

showCI = input.bool(true, "Bayesian Credible Intervals (95 %)", group = GRP_BAYES,
     tooltip = "Display 95 % Bayesian credible intervals around the +1 forward probabilities in the dashboard.\n\nFormat: P(Bull) +1 = 75 % [68–82]\n\nDerivation: Dirichlet(α + counts) posterior, Beta marginal, Gaussian approximation.\n\nINTERPRETATION:\n  Narrow CI (e.g., 73–77) — large sample, robust estimate, high trust\n  Wide   CI (e.g., 50–95) — small sample, fragile estimate, low trust\n\nThis is the difference between a hedge-fund estimate and an indicator guess.")


// ─── Forecast ────────────────────────────────────────────────────────────────
forecastSteps = input.int(5, "Forecast Cone Horizon (bars)", minval = 2, maxval = 20, group = GRP_FCST,
     tooltip = "Number of bars ahead to forecast via matrix iteration P, P², P³ … P^N.\n\nThe cone plots the EXPECTED oscillator value at each future bar:\n  E[osc | k] = 100 · (P(Bull|k) − P(Bear|k))\n\nReliable up to ~5 bars; beyond that Markov decays toward the stationary distribution.\n\nDefault 5 — covers the meaningful horizon without illusion.")

showCone = input.bool(true, "Show Forecast Cone", group = GRP_FCST,
     tooltip = "Plot the N-bar forecast trajectory as a colored polyline extending PAST the last confirmed bar.\n\nEach segment plots the EXPECTED oscillator value at step k:\n  E[osc | k] = 100 · (P(Bull | k) − P(Bear | k))\n\nColor reflects the dominant regime at that step (Bull / Bear / Side).\n\nDrawn with line.new() so segments are pixel-stable on any chart zoom — they will NOT fragment or rescale.\n\nNote: the forecast is matrix-implied, not a momentum extrapolation.  If the oscillator is at +250 (strong Bull) but the matrix suggests regression to +80, the cone will show that 'cliff' — it is mathematically honest, not a bug.")


// ─── Oscillator ──────────────────────────────────────────────────────────────
showSignal = input.bool(true, "Show Signal Line", group = GRP_OSC,
     tooltip = "Plot a smoothed signal line over the main oscillator.\n\nCrossovers between the MAIN and SIGNAL lines mark MOMENTUM-OF-REGIME shifts — these often precede actual regime changes by 1-3 bars (lookback-lag mitigation).\n\nDisable to remove the signal line — also disables Signal Cross alerts and the dashboard Signal cell.")

signalType = input.string(SMTH_EMA, "Signal Smoothing Method",
     options = [SMTH_EMA, SMTH_HMA, SMTH_ALMA, SMTH_SMA], group = GRP_OSC,
     tooltip = "Smoothing algorithm applied to the oscillator value:\n\nEMA — Exponential (default, classic lag/smoothness)\nHMA — Hull (less lag, near-zero lag for short windows)\nALMA — Arnaud Legoux (Gaussian-weighted, smoothest)\nSMA — Simple (most stable, most lag)\n\nFor low-lag crossover trading, HMA is recommended; for clean structural smoothing, ALMA.")

signalLen = input.int(5, "Signal Smoothing Length", minval = 1, maxval = 50, group = GRP_OSC,
     tooltip = "Window length for the chosen smoothing algorithm.\n\nRange: 1 – 50 bars.\n\n3 – 5 (default 5) — reactive, low lag, frequent crossovers — best for scalping with HMA / EMA\n7 – 10 — balanced lag / smoothness\n14+ — smooth, slow, structural signal — best for swing trading\n\nFor low-lag crossover trading, keep ≤ 7.  For structural confirmation, 14+.  Crossovers between the main oscillator and this signal line drive momentum-of-regime alerts.")

velocityWin = input.int(5, "Velocity Window (bars)", minval = 2, maxval = 30, group = GRP_OSC,
     tooltip = "Bars over which oscillator velocity is measured (rate of change).  Drives the Velocity cell in the dashboard AND the Momentum Filter (if enabled).\n\nRange: 2 – 30 bars.\n\nServes as an EARLY warning before the ±100 boundary is crossed — velocity flips direction BEFORE the regime does.\n\n3 – 5 (default 5) — reactive, picks up short-term momentum changes\n5 – 10 — balanced\n15+ — smoother, slower, structural velocity view\n\nVelocity threshold auto-scales as VELOCITY_BASE · √(N / 5), so labels stay meaningful at any window size.")

lineWidth = input.int(2, "Oscillator Line Width", minval = 1, maxval = 5, group = GRP_OSC,
     tooltip = "Main oscillator line thickness in pixels.\n\nRange: 1 – 5 pixels.\n\n1 — thin, minimal visual footprint, blends with other indicators\n2 (default) — clear, balanced thickness\n3 — bold\n4 – 5 — very bold (good for screen-sharing, recorded sessions, or low-resolution displays)")


// ─── Display ─────────────────────────────────────────────────────────────────
showRibbon = input.bool(true, "Show Regime Ribbon", group = GRP_DISPLAY,
     tooltip = "Subtle background tint matching the current regime color across the oscillator panel.\n\nProvides INSTANT regime context at a glance — Bull / Bear / Side periods are visually separated even when zoomed out on long history.\n\nTransparency 80 → 20 % opacity, so it doesn't overpower the oscillator line or the gradient fill.\n\nDisable for a minimal panel.")

showFill = input.bool(true, "Show Gradient Fill", group = GRP_DISPLAY,
     tooltip = "Fill the area between the oscillator line and zero — regime-tinted, intensity scales with distance from zero.\n\nReinforces directional bias visually: STRONGER color = HIGHER conviction.  Empty when the oscillator is at zero.\n\nAdaptive transparency: blends with the regime ribbon, never produces visual clipping at extreme oscillator values.")

showRefLevels = input.bool(true, "Show Reference Levels", group = GRP_DISPLAY,
     tooltip = "Plot horizontal reference levels on the oscillator panel:\n\n±100 — official regime boundaries (solid line)\n±70  — pending early-warning zones (dashed line)\n0    — neutral midline (dashed line)\n\nThe dashed lines use line.new() so they remain pixel-stable at any chart zoom — they will NOT rescale or fragment.\n\nDisable when you want a minimal panel with only the oscillator + signal.")

showGlow = input.bool(true, "Show Regime Change Glow", group = GRP_DISPLAY,
     tooltip = "Three-layer neon halo plotted on every confirmed regime transition (after the Min Hold filter passes).\n\n▲ — Bull entry (cyan halo)\n▼ — Bear entry (orange halo)\n◆ — Sideways entry (gray halo)\n\nAnti-repaint: the glow appears on the bar where Min Hold confirmed, NOT retroactively repainted to the original flip bar.  Use Min Hold = 1 to plot glow on the exact flip bar (no debounce).\n\nDisable for a clean panel without entry markers.")


// ─── Multi-Timeframe ─────────────────────────────────────────────────────────
useMTF = input.bool(true, "Enable HTF Confluence", group = GRP_MTF,
     tooltip = "Run the same regime logic on a HIGHER TIMEFRAME and report alignment in the dashboard.\n\nUSE FOR: confluence-based trading — only take signals where the chart timeframe AND higher timeframe agree on regime direction.\n\nDASHBOARD STATUS:\n✓ ALIGNED — HTF regime matches LTF regime (green)\n⚠ DIVERGENT — HTF regime differs from LTF (red)\n\nUses request.security with lookahead_off + gaps_off — anti-repaint guaranteed.  Disable to save one security request per bar.")

htfRes = input.timeframe("D", "HTF Resolution", group = GRP_MTF,
     tooltip = "Higher timeframe for the confluence check.\n\nUse at least 3× your chart timeframe — closer ratios provide little additional information.\n\nCLASSIC PAIRS:\n• 15m chart → 1H HTF\n• 1H  chart → 4H or D HTF\n• 4H  chart → W HTF\n• D   chart → W HTF\n• W   chart → M HTF\n\nFor systematic strategies, pick a ratio that aligns with your typical holding period — short-term swing on 4H → check D, position trading on D → check W.")

crossFilterMTF = input.bool(false, "Filter Signal Cross by HTF Alignment", group = GRP_MTF,
     tooltip = "When ON, the Signal Cross alert fires ONLY when the LTF and HTF regimes match.\n\nFILTERS OUT: crossovers that happen during regime divergence (LTF says Bull, HTF says Bear — kills the 'trade against the macro' setup).\n\nTurns a common indicator pattern into a HIGHER-CONVICTION confluence signal.  Reduces signal count by ~40-60 % depending on market.\n\nRequires Enable HTF Confluence (above) to be ON.  If HTF is OFF, this filter is auto-bypassed (silent-kill protection).")


// ─── Dashboard ───────────────────────────────────────────────────────────────
// Dashboard always renders on the MAIN PRICE CHART (force_overlay = true).
// This keeps the oscillator panel uncluttered so the oscillator line, signal
// line, and forecast cone get the full pane height.
showDash = input.bool(true, "Show Status Dashboard", group = GRP_DASH,
     tooltip = "PRO status panel with 7 sections — Regime · Forecast +1 · Horizon +N · Stationary π · Oscillator · HTF · Data.\n\nThe dashboard is rendered on the MAIN PRICE CHART (not in the oscillator panel) so the panel stays clean for the oscillator line and forecast cone.")

dashPos = input.string("Top Right", "Position",
     options = ["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"],
     group = GRP_DASH,
     tooltip = "Where the dashboard floats on the MAIN PRICE CHART.\n\nNine corners total: Top / Middle / Bottom × Left / Center / Right.\n\nTop Right (default) — classic, doesn't overlap most strategy tools or price scales.\nTop Left — useful when the right side has price labels or VWAP fills.\nMiddle — useful when both top and bottom of the chart are busy.\nBottom — useful when the chart top is occupied by trade markers.")

dashSize = input.string("Tiny", "Size",
     options = ["Tiny", "Small", "Normal", "Large"], group = GRP_DASH,
     tooltip = "Text size of the dashboard cells.\n\nTiny (default) — most compact, the full 22-row layout fits on any chart without scrolling.\nSmall — slightly larger, easier on the eye, still compact.\nNormal — large, easy to read at a glance from a distance.\nLarge — very large, takes significant chart space (good for screen-sharing or recorded sessions).\n\nPick the SMALLEST size that's still readable on your screen.")


// ─── Alerts ──────────────────────────────────────────────────────────────────
alertBullEntry = input.bool(true,  "Bull Regime Entry",      group = GRP_ALERT,
     tooltip = "Fires when the regime flips to BULL after the Min Hold filter passes.\n\nUSE FOR: long-entry triggers, trend-following bots, momentum confirmation.\n\nAnti-repaint — fires only on confirmed bar close.  Filtered by Min Hold — a new Bull must persist at least N confirmed bars before the alert fires (default N = 4).")

alertBearEntry = input.bool(true,  "Bear Regime Entry",      group = GRP_ALERT,
     tooltip = "Fires when the regime flips to BEAR after the Min Hold filter passes.\n\nUSE FOR: short-entry triggers, long-exit signals, risk-off automation.\n\nAnti-repaint — fires only on confirmed bar close.  Filtered by Min Hold — a new Bear must persist at least N confirmed bars before the alert fires (default N = 4).")

alertSideEntry = input.bool(false, "Sideways Regime Entry",  group = GRP_ALERT,
     tooltip = "Fires when the regime flips to SIDEWAYS after the Min Hold filter passes.\n\nUSE FOR: trend-exhaustion detection, position-flat signals, regime-aware risk reduction.\n\nDefault OFF — Sideways is statistically the most common regime, so enabling this fires often.  Turn ON when you specifically need to know about trend ends.")

alertHighConf  = input.bool(true,  "High Confidence (≥ 2.5×)", group = GRP_ALERT,
     tooltip = "Fires when regime confidence first crosses ≥ 2.5× the threshold.\n\nConfidence = |logReturn| / threshold.  At 2.5× the move is structurally unusual — roughly the 95-99 % tail in a Gaussian framework.\n\nUSE FOR: explosive-move detection, blow-off-top warnings, momentum-shock entries.\n\nFires ONCE per crossing (state-based, not bar-by-bar spam).")

alertPending   = input.bool(false, "Pending Regime (boundary approach)", group = GRP_ALERT,
     tooltip = "Fires when the oscillator first enters the Pending zone — ≥ 70 % of the boundary distance — while the regime is still Sideways.\n\nUSE FOR: EARLY-WARNING signals BEFORE the official regime flips.  Lets you pre-position before the Bull / Bear entry alert fires.\n\nDefault OFF — produces more frequent signals than Bull / Bear entry alerts.  Enable when you trade boundary-approach setups.")

alertHTFConf   = input.bool(true,  "MTF Confluence (HTF Aligned)", group = GRP_ALERT,
     tooltip = "Fires on a Bull or Bear regime entry ONLY when the HTF regime agrees with the new regime.\n\nUSE FOR: high-conviction confluence trades — only signals where the chart timeframe AND higher timeframe agree on direction.\n\nRequires Enable HTF Confluence (Multi-Timeframe group) to be ON.\n\nFilters out regime flips that conflict with the HTF trend — kills the classic 'trade against the macro' mistake.")

alertCross     = input.bool(false, "Signal Cross",           group = GRP_ALERT,
     tooltip = "Fires when the main oscillator crosses the signal line.\n\nUSE FOR: momentum-of-regime shifts, mean-reversion entries, scalping setups.\n\nFiltered by HTF alignment when 'Filter Signal Cross by HTF' (Multi-Timeframe group) is enabled.\n\nDefault OFF — crossovers fire frequently and may not align with the broader regime.  Enable only when you have a specific cross-based strategy.")


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 2   —   THEME RESOLVER   (ten themes from the Apex design system)
// ═══════════════════════════════════════════════════════════════════════════════

color thBull = switch themeChoice
    "Prism"   => #51B155
    "Focus"   => #00BCD4
    "Solar"   => #FF9800
    "Frost"   => #4FC3F7
    "Laser"   => #00E676
    "Aurora"  => #FFD600
    "Plasma"  => #00E5FF
    "Bloom"   => #69F0AE
    "Eclipse" => #1565C0
    "Carbon"  => #BDBDBD
    =>           #00BCD4

color thBear = switch themeChoice
    "Prism"   => #F23645
    "Focus"   => #FF6D00
    "Solar"   => #E53935
    "Frost"   => #9575CD
    "Laser"   => #FF1744
    "Aurora"  => #EF5350
    "Plasma"  => #E040FB
    "Bloom"   => #FF4081
    "Eclipse" => #C62828
    "Carbon"  => #757575
    =>           #FF6D00

color thSide = switch themeChoice
    "Prism"   => #80828D
    "Focus"   => #607D8B
    "Solar"   => #7986CB
    "Frost"   => #B0BEC5
    "Laser"   => #9E9E9E
    "Aurora"  => #BCAAA4
    "Plasma"  => #546E7A
    "Bloom"   => #90A4AE
    "Eclipse" => #455A64
    "Carbon"  => #424242
    =>           #607D8B

// Dashboard chrome
color dashBg      = displayMode == "Dark" ? #0A0A0A : #FFFFFF
color dashBgAlt   = displayMode == "Dark" ? #141414 : #F5F5F5
color dashFg      = displayMode == "Dark" ? #E0E0E0 : #1A1A1A
color dashFgDim   = displayMode == "Dark" ? color.new(#E0E0E0, 40) : color.new(#1A1A1A, 40)
color dashBorder  = displayMode == "Dark" ? #2A2A2A : #DCDCDC
color dashSection = displayMode == "Dark" ? #1A1A1A : #EEEEEE
color dashHeader  = thBull

color cAligned   = thBull
color cDivergent = thBear


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 3   —   REGIME COMPUTATION   (drift-adjusted, optional momentum)
// ═══════════════════════════════════════════════════════════════════════════════
// 1. bar1Ret  — one-bar log return
// 2. sigma1   — per-bar log-return stdev (for adaptive threshold)
// 3. meanDrift — long-term mean log return (for drift adjustment)
// 4. logRet   — N-bar log return MINUS lookbackN × meanDrift  (excess return)
// 5. thrBull / thrBear — adaptive (k·σ·√N) or fixed (% / 100)
// 6. oscVal   — normalised oscillator value (clip ±300)
// 7. velocity — oscVal − oscVal[velocityWin]; threshold = base·√(N/5)
// 8. regime   — Bull / Bear / Side, optionally gated by momentum agreement

float bar1Ret   = math.log(close / close[1])
float sigma1    = ta.stdev(bar1Ret, sigmaWin)
float meanDrift = ta.sma(bar1Ret, driftWin)

float logRetRaw = math.log(close / close[lookbackN])
float driftAdj  = useDrift and not na(meanDrift) ? lookbackN * meanDrift : 0.0
float logRet    = logRetRaw - driftAdj

float adaptCut = kSigma * sigma1 * math.sqrt(lookbackN)
float thrBull  = thrMode == MODE_ADAPT ? adaptCut : bullThrPct / 100.0
float thrBear  = thrMode == MODE_ADAPT ? adaptCut : bearThrPct / 100.0

float boundary = logRet >= 0 ? thrBull : thrBear
float rawOsc   = boundary > 0 and not na(logRet) ? (logRet / boundary) * OSC_BOUNDARY : 0.0
float oscVal   = math.max(-OSC_CLIP, math.min(OSC_CLIP, rawOsc))

float velocity    = not na(oscVal) and not na(oscVal[velocityWin]) ? oscVal - oscVal[velocityWin] : 0.0
float velocityThr = VELOCITY_BASE * math.sqrt(velocityWin / 5.0)

// Optional Momentum Filter — regime requires velocity sign agreement.
bool momentumBullOK = not filterMomentum or velocity > 0
bool momentumBearOK = not filterMomentum or velocity < 0

int regime = na(logRet) or (thrMode == MODE_ADAPT and na(sigma1)) ? int(na) :
     logRet >  thrBull and momentumBullOK ? R_BULL :
     logRet < -thrBear and momentumBearOK ? R_BEAR : R_SIDE

float refThr = regime == R_BULL ? thrBull : regime == R_BEAR ? thrBear : math.max(thrBull, thrBear)
float confidence = refThr > 0 ? math.abs(logRet) / refThr : 0.0

// Pending early-warning
float distFracBull = thrBull > 0 and not na(logRet) ?  logRet / thrBull  : 0.0
float distFracBear = thrBear > 0 and not na(logRet) ? -logRet / thrBear  : 0.0
float distFrac     = math.max(distFracBull, distFracBear)
int   pendingDir   = logRet > 0 ? R_BULL : R_BEAR
bool  isPending    = not na(regime) and regime == R_SIDE and distFrac >= PENDING_FRAC

// Regime age — bars in the current run
var int regAge = 1
regAge := not na(regime) and not na(regime[1]) and regime == regime[1] ? regAge + 1 : 1

bool isMatureRegime = regAge >= ageMedian


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 4   —   REGIME CHANGE DEBOUNCING   (anti-flicker glow gate)
// ═══════════════════════════════════════════════════════════════════════════════
// Uses ta.barssince to avoid runtime-indexed history reads.

var int lastSigRegime = int(na)

int  barsSinceFlip = ta.barssince(na(regime) or regime != regime[1])
bool held          = not na(regime) and barsSinceFlip >= minHold - 1

bool regimeChange = barstate.isconfirmed and not na(regime) and held and regime != lastSigRegime
bool firstHold    = na(lastSigRegime)

bool bullEntryEvent = regimeChange and regime == R_BULL and not firstHold
bool bearEntryEvent = regimeChange and regime == R_BEAR and not firstHold
bool sideEntryEvent = regimeChange and regime == R_SIDE and not firstHold

if regimeChange
    lastSigRegime := regime

int flipOff = minHold - 1


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 5   —   EWMA TRANSITION COUNTS + SEMI-MARKOV DURATION SPLIT
// ═══════════════════════════════════════════════════════════════════════════════
// Three transition matrices kept in parallel (all 3×3, flattened to length 9):
//
//   counts        — full (unconditional) — used when semi-Markov is OFF
//   countsYoung   — transitions observed when prior regime age < ageMedian
//   countsMature  — transitions observed when prior regime age ≥ ageMedian
//
// Each is multiplied by the EWMA decay factor every confirmed bar BEFORE the
// new transition is recorded:
//
//   decayFactor = 0.5 ^ (1 / halfLife)
//                 → after `halfLife` bars, an old count weighs half its
//                   original.  Same math as RiskMetrics EWMA volatility.
//
// When useDecay is OFF the factor is 1.0 (counts behave as classic integers).

float decayFactor = useDecay ? math.pow(0.5, 1.0 / decayHalfLife) : 1.0

var float[] counts       = array.new_float(9, 0.0)
var float[] countsYoung  = array.new_float(9, 0.0)
var float[] countsMature = array.new_float(9, 0.0)

int prevReg = regime[1]
if barstate.isconfirmed and not na(prevReg) and not na(regime)
    if useDecay
        for i = 0 to 8
            array.set(counts,       i, array.get(counts,       i) * decayFactor)
            array.set(countsYoung,  i, array.get(countsYoung,  i) * decayFactor)
            array.set(countsMature, i, array.get(countsMature, i) * decayFactor)

    // Duration tier of the PRIOR regime at the moment of transition.
    int idx     = prevReg * 3 + regime
    int prevAge = nz(regAge[1], 1)
    array.set(counts, idx, array.get(counts, idx) + 1.0)
    if prevAge < ageMedian
        array.set(countsYoung,  idx, array.get(countsYoung,  idx) + 1.0)
    else
        array.set(countsMature, idx, array.get(countsMature, idx) + 1.0)


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 6   —   SIGNAL SMOOTHING   (oscillator + velocity defined in §3)
// ═══════════════════════════════════════════════════════════════════════════════
// Compute all variants (Pine ta.* state requires every-bar invocation),
// then pick the active one via switch.

float ema_sig  = ta.ema(oscVal,  signalLen)
float hma_sig  = ta.hma(oscVal,  signalLen)
float alma_sig = ta.alma(oscVal, signalLen, 0.85, 6.0)
float sma_sig  = ta.sma(oscVal,  signalLen)
float signalVal = showSignal ?
     (signalType == SMTH_EMA  ? ema_sig  :
      signalType == SMTH_HMA  ? hma_sig  :
      signalType == SMTH_ALMA ? alma_sig :
                                sma_sig) : na


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 7   —   HTF CONFLUENCE   (request.security, anti-repaint)
// ═══════════════════════════════════════════════════════════════════════════════

int htfRegime  = request.security(syminfo.tickerid, htfRes, regime,
     lookahead = barmerge.lookahead_off, gaps = barmerge.gaps_off)
bool htfAligned = useMTF and not na(htfRegime) and not na(regime) and htfRegime == regime


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 8   —   VISUAL LAYER   (ribbon · reference levels · plots · glow)
// ═══════════════════════════════════════════════════════════════════════════════

regimeColor(int r) =>
    r == R_BULL ? thBull : r == R_BEAR ? thBear : thSide

regimeName(int r) =>
    r == R_BULL ? "BULL" : r == R_BEAR ? "BEAR" : "SIDE"

regimeArrow(int r) =>
    r == R_BULL ? "▲" : r == R_BEAR ? "▼" : "◆"


// ─── Background ribbon ───────────────────────────────────────────────────────
// Transparency 80 = 20 % opacity → noticeable regime tint without overpowering
// the oscillator line or gradient fill.
color ribbonCol = na(regime) ? na : color.new(regimeColor(regime), 80)
bgcolor(showRibbon ? ribbonCol : na, title = "Regime Ribbon")


// ─── Reference levels ────────────────────────────────────────────────────────
// Solid ±100 boundaries via plot().  Dashed ±70 pending zones and zero line
// via line.new() — pixel-stable dashes that do NOT rescale with chart zoom.
plot(showRefLevels ?  OSC_BOUNDARY : na, "Bull Boundary",
     color = color.new(thBull, 30), linewidth = 1)
plot(showRefLevels ? -OSC_BOUNDARY : na, "Bear Boundary",
     color = color.new(thBear, 30), linewidth = 1)

var line lnPendingBull = na
var line lnPendingBear = na
var line lnNeutral     = na

if barstate.islast and showRefLevels
    line.delete(lnPendingBull)
    line.delete(lnPendingBear)
    line.delete(lnNeutral)
    lnPendingBull := line.new(bar_index - 1,  OSC_PENDING, bar_index,  OSC_PENDING,
         color = color.new(thBull, 60),    width = 1, style = line.style_dashed, extend = extend.both)
    lnPendingBear := line.new(bar_index - 1, -OSC_PENDING, bar_index, -OSC_PENDING,
         color = color.new(thBear, 60),    width = 1, style = line.style_dashed, extend = extend.both)
    lnNeutral     := line.new(bar_index - 1,  0.0,         bar_index,  0.0,
         color = color.new(dashFgDim, 30), width = 1, style = line.style_dashed, extend = extend.both)


// ─── Oscillator color tier ───────────────────────────────────────────────────
color oscColor =
     oscVal >=  OSC_BOUNDARY ? thBull :
     oscVal >=  OSC_PENDING  ? color.new(thBull, 35) :
     oscVal >= -OSC_PENDING  ? thSide :
     oscVal >= -OSC_BOUNDARY ? color.new(thBear, 35) :
                               thBear


// ─── Main oscillator + signal line ───────────────────────────────────────────
plot_osc  = plot(oscVal, "Markov Oscillator", color = oscColor, linewidth = lineWidth)
plot_sig  = plot(showSignal ? signalVal : na, "Signal", color = color.new(dashFg, 50), linewidth = 1)
plot_zero = plot(0, "Zero", color = na, display = display.none, editable = false)


// ─── Gradient fill (oscillator vs zero) ──────────────────────────────────────
int   fillTransp = int(math.max(60.0, math.min(92.0, 92.0 - math.abs(oscVal) / 6.0)))
color fillCol    = oscVal >= 0 ? color.new(thBull, fillTransp) : color.new(thBear, fillTransp)
fill(plot_osc, plot_zero, color = showFill ? fillCol : na, title = "Osc Fill")


// ─── Three-layer neon glow signals at regime transitions ─────────────────────
plotshape(showGlow and bullEntryEvent ? oscVal : na, "Bull Glow Outer",
     style = shape.triangleup, location = location.absolute, offset = -flipOff,
     color = color.new(thBull, 80), size = size.large)
plotshape(showGlow and bullEntryEvent ? oscVal : na, "Bull Glow Middle",
     style = shape.triangleup, location = location.absolute, offset = -flipOff,
     color = color.new(thBull, 50), size = size.normal)
plotshape(showGlow and bullEntryEvent ? oscVal : na, "Bull Core",
     style = shape.triangleup, location = location.absolute, offset = -flipOff,
     color = thBull, size = size.small)

plotshape(showGlow and bearEntryEvent ? oscVal : na, "Bear Glow Outer",
     style = shape.triangledown, location = location.absolute, offset = -flipOff,
     color = color.new(thBear, 80), size = size.large)
plotshape(showGlow and bearEntryEvent ? oscVal : na, "Bear Glow Middle",
     style = shape.triangledown, location = location.absolute, offset = -flipOff,
     color = color.new(thBear, 50), size = size.normal)
plotshape(showGlow and bearEntryEvent ? oscVal : na, "Bear Core",
     style = shape.triangledown, location = location.absolute, offset = -flipOff,
     color = thBear, size = size.small)

plotshape(showGlow and sideEntryEvent ? oscVal : na, "Side Glow Outer",
     style = shape.diamond, location = location.absolute, offset = -flipOff,
     color = color.new(thSide, 80), size = size.large)
plotshape(showGlow and sideEntryEvent ? oscVal : na, "Side Glow Middle",
     style = shape.diamond, location = location.absolute, offset = -flipOff,
     color = color.new(thSide, 50), size = size.normal)
plotshape(showGlow and sideEntryEvent ? oscVal : na, "Side Core",
     style = shape.diamond, location = location.absolute, offset = -flipOff,
     color = thSide, size = size.small)


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 9   —   LAST-BAR MATH
//                   (P matrix · N-step iteration · Bayesian CI · stationary π)
// ═══════════════════════════════════════════════════════════════════════════════
// On the last bar:
//   1. Choose active counts array (semi-Markov → tier-matched, else full).
//   2. Build P matrix with Dirichlet α prior smoothing.
//   3. Iterate s_{k+1} = s_k · P to get N-step forward state vectors.
//   4. Compute 95 % Bayesian credible intervals around each +1 probability.
//   5. Iterate to convergence to approximate the stationary distribution π.

var float[] P            = array.new_float(9, 1.0 / 3.0)
var float[] coneSide     = array.new_float(20, na)
var float[] coneBull     = array.new_float(20, na)
var float[] coneBear     = array.new_float(20, na)
var float[] activeCounts = array.new_float(9, 0.0)
var int     totalN       = 0
var int     activeN      = 0
var string  matrixTier   = "Full"

var float ciBullLo = na
var float ciBullHi = na
var float ciBearLo = na
var float ciBearHi = na
var float ciSideLo = na
var float ciSideHi = na

var float piBull = na
var float piBear = na
var float piSide = na

if barstate.islast
    // ─── 1. Choose active counts ───
    if useSemiMarkov
        matrixTier := isMatureRegime ? "Mature" : "Young"
        for i = 0 to 8
            array.set(activeCounts, i, isMatureRegime ? array.get(countsMature, i) : array.get(countsYoung, i))
    else
        matrixTier := "Full"
        for i = 0 to 8
            array.set(activeCounts, i, array.get(counts, i))

    // ─── 2. Build P matrix and accumulate sample sizes ───
    activeN := 0
    totalN  := 0
    for r = 0 to 2
        float rs = array.get(activeCounts, r * 3) + array.get(activeCounts, r * 3 + 1) + array.get(activeCounts, r * 3 + 2)
        activeN += int(math.round(rs))
        float rsFull = array.get(counts, r * 3) + array.get(counts, r * 3 + 1) + array.get(counts, r * 3 + 2)
        totalN  += int(math.round(rsFull))
        float sumWithPrior = rs + 3.0 * DIRICHLET_ALPHA
        for c = 0 to 2
            int idx2 = r * 3 + c
            float cell = (array.get(activeCounts, idx2) + DIRICHLET_ALPHA) / sumWithPrior
            array.set(P, idx2, cell)

    // ─── 3. N-step forecast cone via state-vector iteration ───
    int curForR = na(regime) ? R_SIDE : regime
    float sSide = curForR == R_SIDE ? 1.0 : 0.0
    float sBull = curForR == R_BULL ? 1.0 : 0.0
    float sBear = curForR == R_BEAR ? 1.0 : 0.0
    for k = 0 to forecastSteps - 1
        float nS  = sSide * array.get(P, R_SIDE * 3 + R_SIDE) + sBull * array.get(P, R_BULL * 3 + R_SIDE) + sBear * array.get(P, R_BEAR * 3 + R_SIDE)
        float nB  = sSide * array.get(P, R_SIDE * 3 + R_BULL) + sBull * array.get(P, R_BULL * 3 + R_BULL) + sBear * array.get(P, R_BEAR * 3 + R_BULL)
        float nBr = sSide * array.get(P, R_SIDE * 3 + R_BEAR) + sBull * array.get(P, R_BULL * 3 + R_BEAR) + sBear * array.get(P, R_BEAR * 3 + R_BEAR)
        sSide := nS
        sBull := nB
        sBear := nBr
        array.set(coneSide, k, sSide)
        array.set(coneBull, k, sBull)
        array.set(coneBear, k, sBear)

    // ─── 4. Bayesian 95 % credible intervals for the +1 row ───
    // Dirichlet(α + counts) posterior.  Each marginal is Beta(α_i, Σα − α_i).
    // Gaussian approximation:
    //   mean = α_i / Σα,  var = α_i·(Σα − α_i) / (Σα²·(Σα + 1))
    //   95 % CI ≈ mean ± 1.96 · √var
    float rowSum = array.get(activeCounts, curForR * 3) + array.get(activeCounts, curForR * 3 + 1) + array.get(activeCounts, curForR * 3 + 2)
    float aSide  = array.get(activeCounts, curForR * 3 + R_SIDE) + DIRICHLET_ALPHA
    float aBull  = array.get(activeCounts, curForR * 3 + R_BULL) + DIRICHLET_ALPHA
    float aBear  = array.get(activeCounts, curForR * 3 + R_BEAR) + DIRICHLET_ALPHA
    float sumA   = rowSum + 3.0 * DIRICHLET_ALPHA

    float mSide  = aSide / sumA
    float mBull  = aBull / sumA
    float mBear  = aBear / sumA
    float denom  = sumA * sumA * (sumA + 1.0)
    float seSide = math.sqrt(aSide * (sumA - aSide) / denom)
    float seBull = math.sqrt(aBull * (sumA - aBull) / denom)
    float seBear = math.sqrt(aBear * (sumA - aBear) / denom)

    ciSideLo := math.max(0.0, mSide - CI_Z95 * seSide)
    ciSideHi := math.min(1.0, mSide + CI_Z95 * seSide)
    ciBullLo := math.max(0.0, mBull - CI_Z95 * seBull)
    ciBullHi := math.min(1.0, mBull + CI_Z95 * seBull)
    ciBearLo := math.max(0.0, mBear - CI_Z95 * seBear)
    ciBearHi := math.min(1.0, mBear + CI_Z95 * seBear)

    // ─── 5. Stationary distribution via power iteration ───
    float piS  = 1.0 / 3.0
    float piB  = 1.0 / 3.0
    float piBr = 1.0 / 3.0
    for j = 1 to STATIONARY_ITER
        float nS  = piS * array.get(P, R_SIDE * 3 + R_SIDE) + piB * array.get(P, R_BULL * 3 + R_SIDE) + piBr * array.get(P, R_BEAR * 3 + R_SIDE)
        float nB  = piS * array.get(P, R_SIDE * 3 + R_BULL) + piB * array.get(P, R_BULL * 3 + R_BULL) + piBr * array.get(P, R_BEAR * 3 + R_BULL)
        float nBr = piS * array.get(P, R_SIDE * 3 + R_BEAR) + piB * array.get(P, R_BULL * 3 + R_BEAR) + piBr * array.get(P, R_BEAR * 3 + R_BEAR)
        piS  := nS
        piB  := nB
        piBr := nBr
    piSide := piS
    piBull := piB
    piBear := piBr

// Forward probabilities for the CURRENT regime — read live every bar from P.
int   curR      = na(regime) ? R_SIDE : regime
float pBullNext = array.get(P, curR * 3 + R_BULL)
float pBearNext = array.get(P, curR * 3 + R_BEAR)
float pSideNext = array.get(P, curR * 3 + R_SIDE)


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 10   —   FORECAST CONE VISUALIZATION   (last-bar polyline)
// ═══════════════════════════════════════════════════════════════════════════════
// Render the +1…+N forecast as a colored polyline extending past the last
// confirmed bar.  Each segment plots the EXPECTED oscillator value at step k:
//
//   E[osc | k] = 100 · (P(Bull | k) − P(Bear | k))
//
// Color reflects the dominant regime at that step.  line.new() is used (not
// plot) so segments are pixel-stable on any chart zoom level.

var line[] coneLines = array.new_line()

if barstate.islast and showCone
    for ln in coneLines
        line.delete(ln)
    array.clear(coneLines)

    int   prevX = bar_index
    float prevY = oscVal
    for k = 0 to forecastSteps - 1
        float pB  = array.get(coneBull, k)
        float pBr = array.get(coneBear, k)
        float pS  = array.get(coneSide, k)
        float expOsc = 100.0 * pB - 100.0 * pBr
        int   dom = pB >= pBr and pB >= pS ? R_BULL : pBr >= pS ? R_BEAR : R_SIDE
        color segCol = color.new(regimeColor(dom), 30)
        int   nx = bar_index + k + 1
        line  ln = line.new(prevX, prevY, nx, expOsc,
             color = segCol, width = 2, style = line.style_solid)
        array.push(coneLines, ln)
        prevX := nx
        prevY := expOsc


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 11   —   PRO STATUS DASHBOARD   (7 sections, theme-aware)
// ═══════════════════════════════════════════════════════════════════════════════

f_pos(string s) =>
    switch s
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        =>                 position.top_right

f_size(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        =>          size.small

f_compact(int n) =>
    string s = str.tostring(n)
    if n >= 1000000
        s := str.tostring(n / 1000000.0, "0.0") + "M"
    else if n >= 10000
        s := str.tostring(int(n / 1000.0)) + "k"
    else if n >= 1000
        s := str.tostring(n / 1000.0, "0.0") + "k"
    s

f_pct(float p) =>
    na(p) ? "—" : str.tostring(math.round(p * 100)) + "%"

f_pctCI(float p, float lo, float hi) =>
    na(p) ? "—" : str.tostring(math.round(p * 100)) + "% [" + str.tostring(math.round(lo * 100)) + "–" + str.tostring(math.round(hi * 100)) + "]"

string confBar = na(confidence) ? "—" :
     confidence < 1.0 ? "▱▱▱" :
     confidence < 2.0 ? "▰▱▱" :
     confidence < 3.0 ? "▰▰▱" : "▰▰▰"
string confLbl = na(confidence) ? "—" :
     confidence < 1.0 ? "weak" :
     confidence < 2.0 ? "moderate" :
     confidence < 3.0 ? "strong" : "stretched"

var table tDash = na

if barstate.islast and showDash
    tDash := table.new(f_pos(dashPos), 2, 32,
         bgcolor = dashBg, border_color = dashBorder, border_width = 1,
         frame_color = dashBorder, frame_width = 2, force_overlay = true)

    int r0 = 0

    // ─── HEADER ───
    table.cell(tDash, 0, r0, "MARKOV REGIME OSC",
         text_color = dashHeader, bgcolor = dashSection,
         text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tDash, 1, r0, "v3.0 Hedge",
         text_color = dashFgDim, bgcolor = dashSection,
         text_size = f_size(dashSize), text_halign = text.align_right)
    r0 += 1

    // ─── REGIME section ───
    table.cell(tDash, 0, r0, "REGIME",
         text_color = dashHeader, bgcolor = dashSection,
         text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tDash, 1, r0, "",
         bgcolor = dashSection, text_size = f_size(dashSize))
    r0 += 1

    string regText = na(regime) ? "—" : regimeArrow(regime) + "  " + regimeName(regime)
    color  regCol  = na(regime) ? dashFg : regimeColor(regime)
    table.cell(tDash, 0, r0, "Regime",
         text_color = dashFg, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tDash, 1, r0, regText,
         text_color = regCol, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_right)
    r0 += 1

    string ageText = str.tostring(regAge) + "b · " + (isMatureRegime ? "Mature" : "Young")
    table.cell(tDash, 0, r0, "Age",
         text_color = dashFg, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tDash, 1, r0, ageText,
         text_color = dashFg, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_right)
    r0 += 1

    string confText = confBar + "  " + str.tostring(confidence, "0.0") + "×  " + confLbl
    color  confCol  = na(regime) ? dashFgDim : regimeColor(regime)
    table.cell(tDash, 0, r0, "Confidence",
         text_color = dashFg, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tDash, 1, r0, confText,
         text_color = confCol, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_right)
    r0 += 1

    string pendingText = "—"
    color  pendingCol  = dashFgDim
    if isPending and not na(pendingDir)
        pendingText := "⚠ " + regimeArrow(pendingDir) + " " + regimeName(pendingDir) + "  " + str.tostring(math.round(distFrac * 100)) + "%"
        pendingCol  := regimeColor(pendingDir)
    table.cell(tDash, 0, r0, "Pending",
         text_color = dashFg, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tDash, 1, r0, pendingText,
         text_color = pendingCol, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_right)
    r0 += 1

    string velText = "—"
    color  velCol  = dashFgDim
    if not na(velocity)
        string vArrow = "═"
        color  vCol   = dashFg
        if velocity > velocityThr
            vArrow := "↑"
            vCol   := thBull
        else if velocity < -velocityThr
            vArrow := "↓"
            vCol   := thBear
        velText := vArrow + " " + (velocity >= 0 ? "+" : "") + str.tostring(velocity, "0.0")
        velCol  := vCol
    table.cell(tDash, 0, r0, "Velocity",
         text_color = dashFg, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tDash, 1, r0, velText,
         text_color = velCol, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_right)
    r0 += 1

    // ─── FORECAST +1 section (with Bayesian CI) ───
    table.cell(tDash, 0, r0, "FORECAST +1",
         text_color = dashHeader, bgcolor = dashSection,
         text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tDash, 1, r0, showCI ? "95% CI" : "",
         text_color = dashFgDim, bgcolor = dashSection,
         text_size = f_size(dashSize), text_halign = text.align_right)
    r0 += 1

    table.cell(tDash, 0, r0, "P(Bull)",
         text_color = dashFg, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tDash, 1, r0, showCI ? f_pctCI(pBullNext, ciBullLo, ciBullHi) : f_pct(pBullNext),
         text_color = thBull, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_right)
    r0 += 1

    table.cell(tDash, 0, r0, "P(Bear)",
         text_color = dashFg, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tDash, 1, r0, showCI ? f_pctCI(pBearNext, ciBearLo, ciBearHi) : f_pct(pBearNext),
         text_color = thBear, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_right)
    r0 += 1

    table.cell(tDash, 0, r0, "P(Side)",
         text_color = dashFg, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tDash, 1, r0, showCI ? f_pctCI(pSideNext, ciSideLo, ciSideHi) : f_pct(pSideNext),
         text_color = thSide, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_right)
    r0 += 1

    // ─── HORIZON section — terminal-step forecast ───
    table.cell(tDash, 0, r0, "HORIZON +" + str.tostring(forecastSteps),
         text_color = dashHeader, bgcolor = dashSection,
         text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tDash, 1, r0, "",
         bgcolor = dashSection, text_size = f_size(dashSize))
    r0 += 1

    float pBT  = array.get(coneBull, forecastSteps - 1)
    float pBrT = array.get(coneBear, forecastSteps - 1)
    float pST  = array.get(coneSide, forecastSteps - 1)
    int   domT = pBT >= pBrT and pBT >= pST ? R_BULL : pBrT >= pST ? R_BEAR : R_SIDE
    float domP = math.max(pBT, math.max(pBrT, pST))
    string hText = regimeArrow(domT) + " " + regimeName(domT) + "  " + f_pct(domP)
    color  hCol  = regimeColor(domT)
    table.cell(tDash, 0, r0, "Dominant",
         text_color = dashFg, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tDash, 1, r0, hText,
         text_color = hCol, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_right)
    r0 += 1

    // ─── STATIONARY section ───
    table.cell(tDash, 0, r0, "STATIONARY π",
         text_color = dashHeader, bgcolor = dashSection,
         text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tDash, 1, r0, "",
         bgcolor = dashSection, text_size = f_size(dashSize))
    r0 += 1

    table.cell(tDash, 0, r0, "π(Bull)",
         text_color = dashFg, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tDash, 1, r0, f_pct(piBull),
         text_color = thBull, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_right)
    r0 += 1

    table.cell(tDash, 0, r0, "π(Bear)",
         text_color = dashFg, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tDash, 1, r0, f_pct(piBear),
         text_color = thBear, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_right)
    r0 += 1

    table.cell(tDash, 0, r0, "π(Side)",
         text_color = dashFg, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tDash, 1, r0, f_pct(piSide),
         text_color = thSide, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_right)
    r0 += 1

    // ─── OSCILLATOR section ───
    table.cell(tDash, 0, r0, "OSCILLATOR",
         text_color = dashHeader, bgcolor = dashSection,
         text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tDash, 1, r0, "",
         bgcolor = dashSection, text_size = f_size(dashSize))
    r0 += 1

    string valText = na(oscVal) ? "—" :
         (oscVal >= 0 ? "+" : "") + str.tostring(oscVal, "0.0")
    color  valCol  =
         oscVal >=  OSC_BOUNDARY ? thBull :
         oscVal >=  OSC_PENDING  ? color.new(thBull, 35) :
         oscVal >= -OSC_PENDING  ? dashFg :
         oscVal >= -OSC_BOUNDARY ? color.new(thBear, 35) :
                                   thBear
    table.cell(tDash, 0, r0, "Value",
         text_color = dashFg, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tDash, 1, r0, valText,
         text_color = valCol, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_right)
    r0 += 1

    string sigText = "—"
    color  sigCol  = dashFgDim
    if showSignal and not na(signalVal) and not na(oscVal)
        if oscVal > signalVal
            sigText := "↑ above"
            sigCol  := thBull
        else if oscVal < signalVal
            sigText := "↓ below"
            sigCol  := thBear
        else
            sigText := "═ equal"
            sigCol  := dashFg
    table.cell(tDash, 0, r0, "Signal",
         text_color = dashFg, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tDash, 1, r0, sigText,
         text_color = sigCol, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_right)
    r0 += 1

    string thrText = na(thrBull) ? "—" :
         "±" + str.tostring(thrBull * 100.0, "0.0") + "%"
    table.cell(tDash, 0, r0, "Threshold",
         text_color = dashFg, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tDash, 1, r0, thrText,
         text_color = dashFg, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_right)
    r0 += 1

    // Drift basis points over the lookback window — exact via exp().
    string drText = "—"
    color  drCol  = dashFgDim
    if useDrift and not na(meanDrift)
        float drBp = (math.exp(meanDrift * lookbackN) - 1.0) * 10000.0
        drText := (drBp >= 0 ? "+" : "") + str.tostring(drBp, "0.0") + " bp"
        drCol  := drBp > 0 ? thBull : drBp < 0 ? thBear : dashFg
    else if not useDrift
        drText := "off"
    table.cell(tDash, 0, r0, "Drift",
         text_color = dashFg, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tDash, 1, r0, drText,
         text_color = drCol, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_right)
    r0 += 1

    // ─── HTF section (only if MTF enabled) ───
    if useMTF
        table.cell(tDash, 0, r0, "HTF (" + htfRes + ")",
             text_color = dashHeader, bgcolor = dashSection,
             text_size = f_size(dashSize), text_halign = text.align_left)
        table.cell(tDash, 1, r0, "",
             bgcolor = dashSection, text_size = f_size(dashSize))
        r0 += 1

        string htfRegText = na(htfRegime) ? "—" : regimeArrow(htfRegime) + "  " + regimeName(htfRegime)
        color  htfRegCol  = na(htfRegime) ? dashFg : regimeColor(htfRegime)
        table.cell(tDash, 0, r0, "Regime",
             text_color = dashFg, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_left)
        table.cell(tDash, 1, r0, htfRegText,
             text_color = htfRegCol, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_right)
        r0 += 1

        string alignText = "—"
        color  alignCol  = dashFg
        if not na(htfRegime) and not na(regime)
            alignText := htfAligned ? "✓ ALIGNED" : "⚠ DIVERGENT"
            alignCol  := htfAligned ? cAligned   : cDivergent
        table.cell(tDash, 0, r0, "Status",
             text_color = dashFg, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_left)
        table.cell(tDash, 1, r0, alignText,
             text_color = alignCol, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_right)
        r0 += 1

    // ─── DATA section ───
    table.cell(tDash, 0, r0, "DATA",
         text_color = dashHeader, bgcolor = dashSection,
         text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tDash, 1, r0, "",
         bgcolor = dashSection, text_size = f_size(dashSize))
    r0 += 1

    string modeText = thrMode == MODE_ADAPT ?
         "Adaptive " + str.tostring(kSigma, "0.0") + "σ" :
         "Fixed ±" + str.tostring(bullThrPct, "0.0") + "%"
    table.cell(tDash, 0, r0, "Mode",
         text_color = dashFg, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tDash, 1, r0, modeText,
         text_color = dashFg, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_right)
    r0 += 1

    string decText = useDecay ? "λ½ = " + str.tostring(decayHalfLife) + "b" : "off"
    table.cell(tDash, 0, r0, "Decay",
         text_color = dashFg, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tDash, 1, r0, decText,
         text_color = dashFg, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_right)
    r0 += 1

    string mTier = useSemiMarkov ? matrixTier : "Full"
    color  mCol  = useSemiMarkov ? (isMatureRegime ? thBear : thBull) : dashFg
    table.cell(tDash, 0, r0, "Matrix",
         text_color = dashFg, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tDash, 1, r0, mTier,
         text_color = mCol, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_right)
    r0 += 1

    int sampleForReport = useSemiMarkov ? activeN : totalN
    color  sampleCol = sampleForReport >= 200 ? thBull : sampleForReport >= 50 ? dashFg : cDivergent
    string sampleLbl = sampleForReport >= 200 ? "high" : sampleForReport >= 50 ? "moderate" : "low"
    table.cell(tDash, 0, r0, "Sample N",
         text_color = dashFg, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tDash, 1, r0, f_compact(sampleForReport) + "  (" + sampleLbl + ")",
         text_color = sampleCol, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_right)


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 12   —   ALERTS
// ═══════════════════════════════════════════════════════════════════════════════

alertcondition(alertBullEntry and bullEntryEvent,
     title   = "Markov Regime Osc — Bull Entry",
     message = "Markov Regime Osc: regime flipped to BULL on {{ticker}} {{interval}}.")

alertcondition(alertBearEntry and bearEntryEvent,
     title   = "Markov Regime Osc — Bear Entry",
     message = "Markov Regime Osc: regime flipped to BEAR on {{ticker}} {{interval}}.")

alertcondition(alertSideEntry and sideEntryEvent,
     title   = "Markov Regime Osc — Sideways Entry",
     message = "Markov Regime Osc: regime flipped to SIDEWAYS on {{ticker}} {{interval}}.")

bool highConfEvent = barstate.isconfirmed and not na(confidence) and confidence >= 2.5 and (na(confidence[1]) or confidence[1] < 2.5)
alertcondition(alertHighConf and highConfEvent,
     title   = "Markov Regime Osc — High Confidence",
     message = "Markov Regime Osc: confidence ≥ 2.5× threshold — unusually strong move on {{ticker}} {{interval}}.")

bool pendingEnteredEvent = barstate.isconfirmed and isPending and not isPending[1]
alertcondition(alertPending and pendingEnteredEvent,
     title   = "Markov Regime Osc — Pending Regime",
     message = "Markov Regime Osc: approaching regime boundary (≥ 70% of threshold) on {{ticker}} {{interval}}.")

bool mtfConfEvent = barstate.isconfirmed and (bullEntryEvent or bearEntryEvent) and htfAligned
alertcondition(alertHTFConf and mtfConfEvent,
     title   = "Markov Regime Osc — MTF Confluence",
     message = "Markov Regime Osc: regime change with HTF agreement on {{ticker}} {{interval}}.")

// Signal cross — optionally filtered by HTF alignment.  The filter is bypassed
// when MTF is globally disabled (silent-kill protection).
// ta.* must be called every bar at global scope (Pine v6 stateful series rule),
// hence the raw values are computed first then gated.
bool crossOverRaw   = ta.crossover(oscVal,  signalVal)
bool crossUnderRaw  = ta.crossunder(oscVal, signalVal)
bool crossUpEvent   = showSignal and barstate.isconfirmed and crossOverRaw
bool crossDownEvent = showSignal and barstate.isconfirmed and crossUnderRaw
bool crossUpFire    = crossUpEvent   and (not crossFilterMTF or not useMTF or htfAligned)
bool crossDownFire  = crossDownEvent and (not crossFilterMTF or not useMTF or htfAligned)
alertcondition(alertCross and (crossUpFire or crossDownFire),
     title   = "Markov Regime Osc — Signal Cross",
     message = "Markov Regime Osc: oscillator crossed signal line on {{ticker}} {{interval}}.")


// ═══════════════════════════════════════════════════════════════════════════════
//   END CODE
// ═══════════════════════════════════════════════════════════════════════════════
````
