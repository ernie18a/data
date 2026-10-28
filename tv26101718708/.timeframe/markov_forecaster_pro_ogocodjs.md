# Markov Forecaster PRO

- url: https://www.tradingview.com/script/OgOCoDjs-Markov-Forecaster-PRO/
- type: indicator
- pine_id: PUB;aa3132c5af8e4b48a148f6f52b246774
- version: 1.0

## Description

🟦 [b]Markov Forecaster PRO[/b] is a regime-classification and probability-forecasting engine built on a discrete-time Markov chain over three states — Bull, Bear, Sideways. Every bar is labelled from its rolling N-bar log return; the labels feed a 3×3 transition matrix that is power-iterated for the stationary distribution and exponentiated for forward-probability cones (P¹, P³, P⁵, P^horizon). Unlike the dozens of textbook Markov indicators on TradingView, this one layers four original refinements on top of the standard chain construction — each addressing a well-known weakness of the memoryless Markov assumption.

The indicator integrates seven analytical layers — adaptive regime classification, semi-Markov duration tracking, sample-size disclosure, pending-regime early warning, forward-probability forecasting, look-ahead-free backtesting with fees and slippage, and multi-timeframe confluence — each rendered on a single overlay chart through a regime ribbon, three-layer neon glow signals, and four theme-aware dashboard panels.

Built with statistical honesty in mind. The backtest charges configurable commission and slippage on every entry and exit, the transition matrix flags rows with insufficient data, the duration-conditional probabilities are shown alongside the unconditional ones, and the documentation is explicit about what the model can and cannot predict.


[b]🟦 HOW THE CORE ENGINE WORKS[/b]

**Regime Classification**

Each bar, the engine measures the rolling N-bar log return:

logRet = log(close / close[N])


The bar is labelled by comparing this return against the configured boundary:

- `logRet > +threshold` → BULL
- `logRet < −threshold` → BEAR
- otherwise → SIDEWAYS

The classification runs every bar with no look-ahead. The choice of threshold determines how reactive the regime label is, and this is where the first refinement enters.

**Adaptive Threshold (k · σ · √N)**

Traditional Markov regime indicators use a fixed percentage cut — e.g. "±5 % over 20 bars". This collapses on real markets: the same 5 % is trivial in a 2017 mania and never reached in 2023 chop. The fix is to scale the boundary with realised volatility:

threshold_adaptive = k × σ × √N

where σ is the per-bar log-return standard deviation over a configurable window (default 100 bars). Under a random walk, k = 1.0 cuts at the 16th / 84th percentiles; k = 2.0 at the 2.5th / 97.5th percentiles. The default k = 1.5 reproduces classic ±1.5-sigma thresholds.

Fixed-percentage mode is still available for users who want to lock the threshold deliberately.

**Regime Confidence**

Once classified, the move's strength is normalised relative to the active boundary:

confidence = |logRet| / threshold

| Confidence | Tier | Visual |
|---|---|---|
| < 1.0× | weak | ▱▱▱ |
| 1.0× – 2.0× | moderate | ▰▱▱ |
| 2.0× – 3.0× | strong | ▰▰▱ |
| ≥ 3.0× | stretched | ▰▰▰ |

The confidence value drives the ribbon transparency (in Adaptive Intensity mode), feeds the High Confidence alert (≥ 2.5× trigger), and is reported in the Status dashboard.


[b]🟦 SEMI-MARKOV DURATION BUCKETS[/b]

**The Memoryless Problem**

A standard Markov chain says: "Given I'm in Bull, the probability of staying Bull tomorrow is X — regardless of whether Bull started yesterday or 200 bars ago." This is the memoryless property, and on real markets it's wrong. A 200-day-old Bull regime carries different mean-reversion risk than a 5-day-old one.

**The Refinement**

Markov Forecaster PRO additionally builds two CONDITIONAL transition matrices:

- `P_young` — transitions counted when the source regime's age was below its empirical average duration
- `P_mature` — transitions counted when the source regime's age was at or above the average

Both matrices are constructed in parallel with the main P, using the same per-bar bucketing logic and updated continuously. The self-transition probabilities for the current regime are then surfaced in the Status dashboard:

P[stay] young / mature    91% / 64%

The user reads this as: "When this regime was young (under its avg duration), it continued 91 % of the time. When mature, only 64 %." On a long-running regime this is the canonical signal that mean-reversion risk is rising — without the rest of the chain math being polluted.

A minimum of 10 samples per bucket is required before a value is shown; below that the cell reports "—" rather than display an unreliable probability.


[b]🟦 FORWARD PROBABILITY CONE[/b]

**Matrix Exponentiation**

The 3×3 transition matrix P encodes one-bar-ahead probabilities. To project further out, the matrix is multiplied by itself:

P¹ = P                  — next bar
P³ = P × P × P          — 3 bars out
P⁵ = P × P × P × P × P  — 5 bars out
P^h = repeated h times  — user-configured horizon

The Forecast Cone panel renders all four horizons for each of the three destination regimes, conditioned on the current regime. A trader reading the row "BULL" sees the probability the market will be in Bull at each horizon, given the current regime.

**Stationary Distribution**

Power-iterating the matrix to convergence yields the stationary distribution — the long-run probability of being in each regime, independent of starting state. With 50 iterations (default), any well-behaved 3×3 stochastic matrix is essentially converged.

stat[Bull] + stat[Bear] + stat[Side] = 1.0

This is rendered as the "long-run" row in the Forecast panel and the "Long-run share" cell in the Status panel.

**Honest Limitation**

The cone uses the UNCONDITIONAL matrix (averaged over all regime ages). For duration-conditional probabilities, the Status panel's P[stay] cell is the relevant readout. This split is explicit in both the cone footer label and the Forecast input tooltip.


[b]🟦 SAMPLE-SIZE DISCLOSURE[/b]

A probability is only as reliable as the data behind it. Markov Forecaster PRO surfaces sample size in three places:

**Per-row sample count in the Transition Matrix**

A fifth column "n" in the matrix panel reports the number of transitions from each source regime. The cell is colored by reliability tier:

| Sample N | Tier | Color |
|---|---|---|
| ≥ 100 | high | foreground |
| 30 – 99 | moderate | dim |
| < 30 | low | divergent (warning) |

A row with fewer than 30 transitions is flagged because three-decimal probabilities derived from sparse data are noise, not signal.

**Total Sample N in the Status panel**

The Status dashboard's "Sample N" cell sums all transition counts and reports a global reliability tier:

| Total N | Tier |
|---|---|
| ≥ 200 | high (full color) |
| 50 – 199 | moderate (foreground) |
| < 50 | low (divergent warning) |

**Matrix footer**

The matrix panel's footer also shows the total N in compact notation (e.g. "N = 1.8k") for at-a-glance check.

The goal of this layer is honesty: a freshly-loaded chart with 30 bars of history should NOT display the same matrix as a 10-year chart, and the reliability tier makes the difference obvious without the user having to inspect counts manually.


[b]🟦 PENDING-REGIME EARLY WARNING[/b]

**The Lookback Lag**

Because the regime is classified from log(close / close[N]), the official regime label inherently lags — by the time the threshold is crossed, the move is already N bars old. This is a structural feature of the model, not a bug, but it can be partially mitigated.

**Pending Logic**

Inside Sideways, when the log return reaches 70 % of either boundary, the dashboard fires an early-warning cue:

distance_fraction = max(|logRet| / threshold, ...)
isPending = (regime == SIDE) AND (distance_fraction ≥ 0.70)

The Status panel's "Pending" cell displays the direction the return is leaning toward and the current fraction:

⚠ ▲ BULL  87%

Color matches the leaning regime. The Pending Regime alert (default OFF, opt-in) fires on the first bar a pending state is entered.

This is not a regime change signal — it's a "watch this" cue, triggered roughly 30 % before the official threshold is crossed. Used alongside the official regime change, it gives the user advance notice without compromising the threshold's strictness.


[b]🟦 LOOK-AHEAD-FREE BACKTEST[/b]

**The Look-Ahead Trap**

`regime` is derived from `log(close / close[N])`, which contains today's close. Allocating today's return to today's regime is look-ahead bias — the strategy would "know" today's regime before today's close, which is impossible in real-time trading. Most published Markov backtests have this bug.

**The Fix**

Markov Forecaster PRO allocates positions on the PRIOR bar's confirmed regime:

regForAlloc = regime[1]   // yesterday's confirmed regime

If yesterday's regime was Bull, we are long today. The strategy is realisable in real time because the previous bar's regime is known when the current bar opens.

This means the strategy is delayed by one bar relative to the regime label — and that's the correct, honest treatment. If a Bull→Bear flip happens on bar t, the strategy takes bar t's loss (still long from regime[t-1]=Bull) and exits at bar t+1.

**Fees and Slippage**

Every Bull entry and exit pays the configured per-fill cost:

costFrac    = feesPct/100 + slippageBps/10000
costPerFill = log(1 − costFrac)   // negative log-space cost

The cumulative cost is debited from the Bull log-return total:

Bull gross   = exp(bullLogR) − 1
Bull net     = exp(bullLogR + bullCostLogR) − 1

A round-trip pays the fee + slippage twice. With defaults (0.10 % fee, 5 bps slippage), each round-trip costs roughly 0.30 % of equity in log space.

**Display**

The Backtest panel renders:

| Field | Value |
|---|---|
| Per-regime rows | GROSS cumulative log return (no fees) |
| Strategy row | NET cumulative (fees applied) vs Buy-and-Hold |
| Methodology footer | trade count · fee % · slippage bps |

The headline strategy result is the NET number — the realistic outcome a trader would have experienced. The gross numbers are kept for diagnostic comparison.

**What This Is Not**

This is a diagnostic backtest, not a tradable strategy. There is no position sizing, no risk management, no overnight financing, no shorting. It tells you whether "long when prior bar was Bull, flat otherwise" would have beaten buy-and-hold after fees — nothing more.


[b]🟦 MULTI-TIMEFRAME CONFLUENCE[/b]

The same regime logic runs on a user-configured higher timeframe via `request.security` with `lookahead = barmerge.lookahead_off` and `gaps = barmerge.gaps_off` (anti-repaint mandatory). The result is reported in the Status dashboard's HTF block:

| State | Display | Color |
|---|---|---|
| HTF regime matches LTF regime | ✓ ALIGNED | bull |
| HTF regime differs from LTF | ⚠ DIVERGENT | bear |
| Insufficient HTF data | — | foreground |

Divergent regimes are common at trend turns — the LTF flips before the HTF catches up. Aligned regimes carry higher conviction. A separate alert ("MTF Confluence") fires on regime entries only when the HTF agrees.

Recommended pairings:

| Chart | HTF |
|---|---|
| 1H | D |
| 4H | W |
| D | W |

Use at least 3× your chart timeframe — anything closer and the two regimes track each other with no information gain.


[b]🟦 VISUAL LAYER[/b]

**Regime Ribbon**

The chart background is tinted to the current regime color with three style options:

| Style | Behaviour |
|---|---|
| Subtle | Fixed 92 % transparency (price stays hero) |
| Bold | Fixed 75 % transparency (easy to scan from far) |
| Adaptive Intensity | Transparency scales with confidence (60 % – 95 %) |

In Adaptive Intensity mode, a strong directional move (confidence ≥ 3×) renders the ribbon at full intensity; a weak move stays faint. The ribbon doubles as a visual confidence meter.

**Three-Layer Neon Glow Signals**

On every confirmed regime change (after the Min Hold filter), the indicator drops a three-layer halo on the chart:

| Layer | Size | Transparency | Purpose |
|---|---|---|---|
| Outer | size.large | 80 % | Soft halo |
| Middle | size.normal | 50 % | Mid-glow |
| Core | size.small | 0 % | Bright center |

Bull markers (▲) render below the bar; Bear (▼) and Sideways (◆) render above. The Min Hold input (default 4 bars) requires a new regime to persist before its flip is drawn — kills label spam in choppy zones without affecting the underlying transition counts.

**Confidence Tags (optional)**

An off-by-default toggle adds the confidence multiplier to each signal arrow ("BULL 2.3×"), useful for screen captures and analysis.


[b]🟦 DASHBOARDS[/b]

Four theme-aware panels, each independently togglable and positionable:

**Status Panel** (default: Bottom Left)

Compact live readout — current regime, age, confidence, pending direction, average duration, young/mature bucket, P[stay] young vs mature, expected remaining bars, long-run share, sample size, and HTF alignment. 16 rows base, 19 with HTF block enabled.

**Transition Matrix Panel** (default: Top Right)

3×3 next-bar P matrix with diagonal-highlighted self-transition cells. The fifth column reports per-row sample size with reliability tier coloring. Matrix footer shows total N.

**Forecast Cone Panel** (default: Middle Right)

Forward probability for each destination regime at horizons +1, +3, +5, and +configured. Steady-state row shows the long-run distribution. Current regime is reported at the bottom for context.

**Backtest Panel** (default: Bottom Right)

Per-regime gross cumulative return, average per-bar, and the bar count. Strategy row shows NET return vs buy-and-hold. Methodology footer lists trade count, fee, and slippage.

All four panels share the same theme palette and adapt to Dark / Light display mode. Text size is independently configurable (Tiny / Small / Normal / Large).


[b]🟦 COLOR THEMES[/b]

Ten cohesive palettes tuned to the Apex design system, each defining three regime axes (Bull, Bear, Sideways):

| Theme | Character | Bull | Bear | Sideways |
|---|---|---|---|---|
| Prism | Classic | Forest green | Crimson | Slate grey |
| Focus | Default | Cyan steel | Deep orange | Cool blue-grey |
| Solar | Warm | Amber | Indigo red | Lavender grey |
| Frost | Cool | Sky blue | Soft lavender | Pale steel |
| Laser | Neon | Lime green | Hot crimson | Charcoal grey |
| Aurora | Bright | Gold | Scarlet | Warm beige |
| Plasma | Electric | Aqua | Magenta | Slate teal |
| Bloom | Soft | Mint | Hot pink | Blue-grey |
| Eclipse | Deep | Navy | Dark crimson | Steel grey |
| Carbon | Minimal | Near-white | Mid-grey | Dark grey |

One theme selection drives every visual component: ribbon, glow signals, all four dashboard headers, regime-colored cells, diagonal matrix highlights, and HTF alignment color.

**Dark / Light Display Mode**

Dashboard chrome (background, foreground, borders, section dividers) flips between dark-on-bright and bright-on-dark. The regime axis colors remain consistent across modes — only the panel chrome changes.


[b]🟦 ALERT SYSTEM[/b]

Six alert conditions, each independently togglable:

| Alert | Condition |
|---|---|
| Bull Regime Entry | Regime flipped to BULL (after Min Hold confirmation) |
| Bear Regime Entry | Regime flipped to BEAR |
| Sideways Regime Entry | Regime flipped to SIDEWAYS (default OFF) |
| High Confidence | confidence ≥ 2.5× threshold, first bar of crossing |
| MTF Confluence | Regime change + HTF agrees |
| Pending Regime | Inside Sideways, log return ≥ 70 % of either boundary (default OFF) |

All alerts fire on confirmed bar close and use the standard `alertcondition` mechanism. The Min Hold filter applies to entry alerts — a new regime must persist Min Hold bars before its entry alert fires, matching the on-chart glow markers.

The Sideways and Pending alerts are default-off because they can fire more frequently than the other types — opt-in by design.


[b]🟦 SETTINGS REFERENCE[/b]

**Theme**
- Theme — One of 10 Apex palettes. Default: Focus
- Display Mode — Dark / Light. Default: Dark

**Regime Logic**
- Threshold Mode — Adaptive (k·σ·√N) / Fixed (%). Default: Adaptive
- Lookback Window — Bars for the rolling log return. Default: 20
- Adaptive k — Sigma multiplier. Default: 1.5
- Fixed Bull Threshold — Used only in Fixed mode. Default: 5.0 %
- Fixed Bear Threshold — Used only in Fixed mode. Default: 5.0 %
- Volatility Window — Bars for the per-bar stdev. Default: 100
- Min Hold — Bars a new regime must persist for label drawing. Default: 4

**Forecast**
- Forecast Horizon — Bars projected by the right-most cone column. Default: 10
- Stationary Power — Power-iteration count. Default: 50

**Regime Ribbon**
- Show Regime Ribbon — Toggle. Default: ON
- Ribbon Style — Subtle / Bold / Adaptive Intensity. Default: Adaptive Intensity

**Signal Labels**
- Show Regime Change Signals — Toggle. Default: ON
- Glow Effect — Three-layer halo toggle. Default: ON
- Show Confidence on Signal — Adds multiplier tag (e.g. "BULL 2.3×"). Default: OFF

**Multi-Timeframe**
- Enable HTF Confluence — Toggle. Default: ON
- HTF Resolution — Higher timeframe. Default: D

**Backtest**
- Trading Fee (% per fill) — Per-side commission. Default: 0.10 %
- Slippage (bps per fill) — Per-side slippage in basis points. Default: 5

**Dashboards**
- Show Status / Matrix / Forecast / Backtest — Independent toggles. Default: all ON
- Dashboard Size — Tiny / Small / Normal / Large. Default: Small

**Panel Positions**
- Status Panel — 9-position grid. Default: Bottom Left
- Matrix Panel — Default: Top Right
- Forecast Panel — Default: Middle Right
- Backtest Panel — Default: Bottom Right

**Alerts**
- Bull / Bear / Sideways Regime Entry — Independent toggles
- High Confidence — Default: ON
- MTF Confluence — Default: ON
- Pending Regime — Default: OFF


[b]🟦 COMPATIBILITY[/b]

Works on all asset classes and all timeframes in TradingView Pine Script v6.

- Crypto: Spot, futures, perpetual contracts
- Forex: All pairs
- Equities: Stocks, ETFs, indices
- Commodities: Metals, energy, agriculture
- Timeframes: 1m through Monthly

The adaptive threshold normalises by per-bar realised volatility, making the regime classification volatility-agnostic across assets without manual recalibration. The same default settings work on BTCUSDT daily, SPY weekly, and EURUSD 4H — only the HTF resolution input should be adjusted to match the chart timeframe.


[b]🟦 TECHNICAL NOTES[/b]

- Pine Script v6
- `max_labels_count = 500`, `max_lines_count = 100`, `max_bars_back = 5000`
- No repainting — all regime classifications are computed on confirmed bar close. The HTF request uses `lookahead = barmerge.lookahead_off` and `gaps = barmerge.gaps_off`
- Regime change debouncing uses `ta.barssince` to avoid runtime-indexed history reads (which can trip "cannot determine max_bars_back" in Pine v6)
- Heavy computation (matrix exponentiation, stationary distribution, dashboard rendering) is gated on `barstate.islast` to run once per chart render
- Transition counting uses `barstate.isconfirmed` to avoid double-counting the live bar
- Backtest accumulators charge fees at trade boundaries — entries and exits detected by `regForAlloc != regForAlloc[1]`
- Duration buckets use the SOURCE regime's age at the time of transition for classification; the threshold is the empirical average duration of that regime, computed continuously
- Matrix multiplication is implemented as an unrolled 3×3 flat-array routine for portability and speed
- Empty-row fallback to uniform 1/3 in the transition matrix prevents NaN propagation when a regime has not appeared in visible history


[b]🟦 LIMITATIONS — READ THIS[/b]

This indicator is statistically honest about what it can and cannot do. Three known limitations:

1. **The Markov assumption is partially violated.** Markets are not memoryless. The duration buckets (Section: Semi-Markov Duration Buckets) mitigate this but do not eliminate it.

2. **Forward probabilities are not predictions.** They are conditional probabilities under the chain assumption. A "Bull 58 % at +10 bars" reading does not mean "58 % chance the next 10 bars are bullish" — it means "given a long-run sample of similar starting states, 58 % were in Bull at +10 bars". Use the cone as ONE input alongside other analysis.

3. **The regime label lags by N bars.** This is structural — the rolling log return necessarily looks back. The Pending early warning partially mitigates this but cannot eliminate the lag. Treat the official regime change as a confirmation, not a leading signal.


[b]🟦 DISCLAIMER[/b]

This indicator is provided for educational and informational purposes only. It does not constitute financial advice. Past performance does not guarantee future results. The hypothetical backtest is a diagnostic tool — there is no position sizing, no risk management, and no consideration of overnight financing, dividends, or other real-world frictions beyond the configured fee and slippage. Always conduct your own analysis and apply proper risk management.

## Source Code

````pine
//@version=6

// ═══════════════════════════════════════════════════════════════════════════════
//
//  Markov Forecaster PRO — Adaptive Regime Engine
//
//  Author      : a_jabbaroff
//  License     : Mozilla Public License 2.0
//  Version     : 1.0.0
//  PineScript  : v6
//
// ─── Abstract ────────────────────────────────────────────────────────────────
//
//  Markov Forecaster PRO classifies every bar into one of three regimes — Bull, Bear,
//  Sideways — and feeds the labels into a 3×3 discrete-time Markov chain.
//  The chain is power-iterated for the stationary distribution and
//  exponentiated for forward-probability cones (P¹, P³, P⁵, P^horizon).
//
//  The underlying chain construction is the standard textbook form.  Four
//  refinements are layered on top to address its well-known weaknesses:
//
//    1. ADAPTIVE THRESHOLD — instead of a fixed ±X % cut, the regime
//       boundary scales with realised volatility:  k · σ · √N  where σ is
//       the per-bar log-return stdev.  The same setting works across the
//       2017 mania, the 2023 chop, and any future regime without retuning.
//
//    2. SEMI-MARKOV DURATION BUCKETS — the chain math is memoryless on
//       regime age.  Markov Forecaster PRO additionally builds two conditional
//       transition matrices — Young (age < empirical avg) and Mature
//       (age ≥ avg) — and surfaces the self-transition probability under
//       each bucket so the user can see "Bull stays Bull 91 % when young
//       but only 64 % when mature".
//
//    3. SAMPLE-SIZE DISCLOSURE — every transition matrix row reports its
//       raw sample count, and rows with fewer than 30 observations are
//       marked unreliable.  The Status panel reports total sample N so the
//       user can judge whether the chain is data-rich or data-starved
//       before trusting any probability.
//
//    4. PENDING-REGIME EARLY WARNING — while inside Sideways, when the
//       rolling log return reaches 70 % of either boundary, the dashboard
//       flags the imminent direction and (optionally) fires an alert.
//       Partial mitigation of the inherent lookback lag.
//
//  The visual layer adapts confidence into ribbon intensity, glows on
//  regime transitions with a three-layer halo (Apex design language), and
//  prints four theme-aware dashboard cards: status, transition matrix,
//  forward-probability cone, and a hypothetical Bull-only-long backtest
//  versus buy-and-hold.
//
//  The backtest allocates positions on the PRIOR bar's confirmed regime
//  (no look-ahead) AND charges configurable per-trade fees and slippage,
//  so the displayed Net result is realistic, not a hypothetical best case.
//
//  Multi-timeframe confluence reads the same regime logic on a higher
//  timeframe via request.security and flags HTF alignment.  Six alert
//  conditions cover regime entries, high-confidence triggers, HTF
//  confluence, and pending-regime warnings.
//
// ═══════════════════════════════════════════════════════════════════════════════

indicator("Markov Forecaster PRO", "MK Fcst PRO", overlay = true,
     max_labels_count = 500, max_lines_count = 100, max_bars_back = 5000)


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 0   —   CONSTANTS & GROUP NAMES
// ═══════════════════════════════════════════════════════════════════════════════

const string GRP_THEME    = "Theme 🔹"
const string GRP_LOGIC    = "Regime Logic 🔹"
const string GRP_FCST     = "Forecast 🔹"
const string GRP_RIBBON   = "Regime Ribbon 🔹"
const string GRP_SIG      = "Signal Labels 🔹"
const string GRP_MTF      = "Multi-Timeframe 🔹"
const string GRP_BACKTEST = "Backtest 🔹"
const string GRP_DASH     = "Dashboards 🔹"
const string GRP_POS      = "Panel Positions 🔹"
const string GRP_ALERT    = "Alerts 🔹"

const string MODE_ADAPT = "Adaptive (k·σ·√N)"
const string MODE_FIXED = "Fixed (%)"

const string RBN_SUBTLE = "Subtle"
const string RBN_BOLD   = "Bold"
const string RBN_ADAPT  = "Adaptive Intensity"

// Regime codes — values are stable: they index counts[r*3+c] and stat[r].
const int R_SIDE = 0
const int R_BULL = 1
const int R_BEAR = 2

// Pending early-warning threshold (fraction of regime boundary).
const float PENDING_FRAC = 0.7

// Minimum samples for the duration-conditioned cells to be trustworthy.
const int   MIN_BUCKET_N = 10

// Minimum row count below which a matrix row is flagged unreliable.
const int   MIN_ROW_N    = 30


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 1   —   INPUTS
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Theme & Display Mode ────────────────────────────────────────────────────
themeChoice = input.string("Focus", "Theme",
     options = ["Prism", "Focus", "Solar", "Frost", "Laser", "Aurora", "Plasma", "Bloom", "Eclipse", "Carbon"],
     group = GRP_THEME,
     tooltip = "Ten cohesive color palettes tuned to the Apex design system.\n\nPrism — Forest green + crimson red (classic)\nFocus — Cyan steel + deep orange (default)\nSolar — Warm amber + indigo red\nFrost — Sky blue + soft lavender\nLaser — Neon lime + hot crimson\nAurora — Bright gold + scarlet\nPlasma — Electric aqua + magenta\nBloom — Mint green + hot pink\nEclipse — Deep navy + dark crimson\nCarbon — Near-black + silver grey")

displayMode = input.string("Dark", "Display Mode",
     options = ["Dark", "Light"], group = GRP_THEME,
     tooltip = "Dark — black panels, bright accents (default for dark charts).\nLight — white panels, darker accents (use on light charts).")


// ─── Regime Logic ────────────────────────────────────────────────────────────
thrMode = input.string(MODE_ADAPT, "Threshold Mode",
     options = [MODE_ADAPT, MODE_FIXED], group = GRP_LOGIC,
     tooltip = "How Bull / Bear cut-offs are calculated.\n\nAdaptive — boundary = k × σ × √N where σ is the per-bar log-return stdev. Scales automatically across volatility regimes; the same setting works on 2017 mania and 2023 chop. RECOMMENDED.\n\nFixed (%) — classic ±X % cut on the N-bar log return. Predictable but you must retune per market and era.")

lookbackN = input.int(20, "Lookback Window (bars)", minval = 5, maxval = 250, group = GRP_LOGIC,
     tooltip = "Number of bars used for the rolling log-return classification.\n\nShorter (10–20) — reactive, more flips, daytrading.\nMedium (20–40) — balanced classic swing regimes.\nLonger (60–100) — macro regimes, fewer flips, position-trader timeframe.\n\nThe adaptive threshold rescales automatically with this — no retuning needed.")

kSigma = input.float(1.5, "Adaptive k  (boundary = k · σ · √N)",
     minval = 0.25, maxval = 5.0, step = 0.25, group = GRP_LOGIC,
     tooltip = "Sensitivity multiplier for the adaptive threshold.\n\nLower k (0.5–1.0) — more bars get labelled Bull / Bear (sensitive).\nDefault k = 1.5 — classic ±1.5 sigma.\nHigher k (2.0–3.0) — only strong moves register as a regime change (conservative).\n\nUnder a random walk, k = 1.0 cuts at the 16 / 84 percentiles; k = 2.0 at the 2.5 / 97.5 percentiles.")

bullThrPct = input.float(5.0, "Fixed Bull Threshold (%)",
     minval = 0.1, maxval = 50.0, step = 0.1, group = GRP_LOGIC,
     tooltip = "Used only when Threshold Mode = Fixed.\n\nN-bar log return above this (in percent) labels the bar Bull.\n\nTypical values:\nCrypto daily — 5–10\nFX daily — 1–2\nEquity daily — 2–4\nStablecoin / rates — 0.1–0.5")

bearThrPct = input.float(5.0, "Fixed Bear Threshold (%)",
     minval = 0.1, maxval = 50.0, step = 0.1, group = GRP_LOGIC,
     tooltip = "Used only when Threshold Mode = Fixed.\n\nN-bar log return below the negative of this (in percent) labels the bar Bear.\n\nKeep symmetric with the Bull threshold unless you specifically want asymmetric labelling.")

sigmaWin = input.int(100, "Volatility Window (bars)",
     minval = 20, maxval = 500, group = GRP_LOGIC,
     tooltip = "Lookback for the per-bar log-return stdev used by the adaptive threshold.\n\n100 — default, balanced\n50 — more reactive, threshold breathes with recent volatility\n250 — slower, anchored to long-run vol\n\nUsed only when Threshold Mode = Adaptive.")

minHold = input.int(4, "Min Hold (bars)", minval = 1, maxval = 50, group = GRP_LOGIC,
     tooltip = "A new regime must persist this many confirmed bars before it counts as a label-worthy transition.\n\nFilters label-spam in choppy zones.  Affects ONLY the on-chart glow markers and alert events — the transition COUNTS and matrix still use every raw bar (no precision loss).\n\nHigher = fewer, cleaner markers; lower = more noise but earlier signal.")


// ─── Forecast ─────────────────────────────────────────────────────────────────
fcstBars = input.int(10, "Forecast Horizon (bars)", minval = 1, maxval = 50, group = GRP_FCST,
     tooltip = "How far ahead the forward-probability cone projects.\n\nThe matrix is exponentiated: P¹ = next-bar P, P^k = k-bars-out P.  The forecast table shows P¹, P³, P⁵, P^horizon — this input only changes the right-most cone column.\n\nNOTE: the cone uses the UNCONDITIONAL transition matrix (averaged over all regime ages).  For duration-conditional self-transition probabilities — \"Bull stays Bull X % when young vs Y % when mature\" — see the Status panel's P[stay] cell.")

stationaryIters = input.int(50, "Stationary Power (iterations)",
     minval = 10, maxval = 200, group = GRP_FCST,
     tooltip = "How many times the matrix is multiplied for the stationary distribution.\n\n50 — essentially converged for any well-behaved 3×3 stochastic matrix (default).\n100 — extra-safe convergence margin.\n\nReduce only if performance lags on slow machines; raise if your matrix is near-decomposable (very sticky regimes).")


// ─── Regime Ribbon ───────────────────────────────────────────────────────────
showRibbon = input.bool(true, "Show Regime Ribbon", group = GRP_RIBBON,
     tooltip = "Tints the chart background to the current regime color (Bull / Bear / Sideways).  Disable for a clean chart — dashboards continue to update.")

ribbonStyle = input.string(RBN_ADAPT, "Ribbon Style",
     options = [RBN_SUBTLE, RBN_BOLD, RBN_ADAPT], group = GRP_RIBBON,
     tooltip = "Subtle — fixed high-transparency tint (price stays hero).\n\nBold — denser tint, easy to scan from far.\n\nAdaptive Intensity — transparency scales with regime confidence (|log_ret| ÷ threshold). Strong moves paint bright, marginal moves stay faint. RECOMMENDED.")


// ─── Signal Labels ───────────────────────────────────────────────────────────
showSignals = input.bool(true, "Show Regime Change Signals", group = GRP_SIG,
     tooltip = "Drops ▲ / ▼ / ◆ arrows on every confirmed regime change (after the Min Hold filter).\n\n▲ BULL — green, below bar\n▼ BEAR — red, above bar\n◆ SIDE — grey, above bar")

showSigGlow = input.bool(true, "Glow Effect", group = GRP_SIG,
     tooltip = "Three-layer neon halo wrapped around each signal arrow.\n\nOuter layer (size.large)  — 80 % transparent, soft halo\nMiddle layer (size.normal) — 50 % transparent, mid-glow\nCore (size.small)          — opaque, bright center\n\nClean luminous glow on dark charts.")

showConfTag = input.bool(false, "Show Confidence on Signal", group = GRP_SIG,
     tooltip = "Adds the regime-confidence multiplier (e.g. \"BULL 2.3×\") to the signal arrow.\n\nConfidence = |log_return| ÷ threshold.  1.0× = at threshold, 2.0×+ = strong move, 3.0×+ = stretched (mean-reversion watch).\n\nDefault OFF — keeps signals minimal.")


// ─── Multi-Timeframe ─────────────────────────────────────────────────────────
useMTF = input.bool(true, "Enable HTF Confluence", group = GRP_MTF,
     tooltip = "Runs the same regime logic on a higher timeframe via request.security and reports alignment in the status dashboard.\n\nAligned (HTF agrees) — green ✓ ALIGNED\nDivergent (HTF disagrees) — yellow ⚠ DIVERGENT\n\nDivergent regimes are common at trend turns — useful as an early caution flag.")

htfRes = input.timeframe("D", "HTF Resolution", group = GRP_MTF,
     tooltip = "Higher timeframe for the confluence check.  Use at least 3× your chart timeframe — too close and the two regimes track each other (no new information).\n\nClassic pairs:\n1H chart → D HTF\n4H chart → W HTF\nD  chart → W HTF")


// ─── Backtest ────────────────────────────────────────────────────────────────
feesPct = input.float(0.10, "Trading Fee (% per fill)",
     minval = 0.0, maxval = 1.0, step = 0.01, group = GRP_BACKTEST,
     tooltip = "Per-side commission deducted in the backtest.\n\n0.10 % — TradingView default (typical retail crypto)\n0.05 % — discount broker / professional crypto\n0.025 % — institutional\n0.00 % — zero-fee, fee-modeling disabled\n\nApplied on both entry and exit, so a round-trip pays the fee twice.")

slippageBps = input.int(5, "Slippage (bps per fill)",
     minval = 0, maxval = 100, group = GRP_BACKTEST,
     tooltip = "Per-side slippage in basis points (1 bps = 0.01 %).  Models the gap between expected fill price and actual fill price.\n\n5 bps — liquid markets (BTC, SPY)\n10 bps — mid-cap, lower liquidity\n25 bps — small-cap / thin markets\n0 bps — perfect-fill assumption\n\nAdded to the per-fill cost so a round-trip pays slippage twice.")


// ─── Dashboards ──────────────────────────────────────────────────────────────
showStatus   = input.bool(true,  "Show Status Dashboard",   group = GRP_DASH,
     tooltip = "Main panel — current regime, age, confidence, pending, duration buckets, sample size, HTF alignment.")
showMatrix   = input.bool(true,  "Show Transition Matrix",  group = GRP_DASH,
     tooltip = "The 3×3 next-bar P matrix with per-row sample size and reliability flagging.")
showForecast = input.bool(true,  "Show Forecast Cone",      group = GRP_DASH,
     tooltip = "Forward-probability cone — P¹, P³, P⁵, P^horizon — for each of the three regimes.")
showBacktest = input.bool(true,  "Show Backtest Card",      group = GRP_DASH,
     tooltip = "Hypothetical \"long when prior bar's regime is Bull\" strategy vs buy-and-hold (cumulative log return).  Uses the PRIOR bar's confirmed regime (no look-ahead) and charges the configured fee + slippage on every entry and exit.")

dashSize     = input.string("Tiny", "Dashboard Size",
     options = ["Tiny", "Small", "Normal", "Large"], group = GRP_DASH,
     tooltip = "Text size for all four panels.\n\nTiny — minimal footprint (4K monitors)\nSmall — clean and readable (default)\nNormal — easier at-a-glance\nLarge — maximum readability")


// ─── Panel Positions ─────────────────────────────────────────────────────────
posStatus   = input.string("Bottom Left",  "Status Panel",   options = ["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group = GRP_POS)
posMatrix   = input.string("Top Right",    "Matrix Panel",   options = ["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group = GRP_POS)
posForecast = input.string("Middle Right", "Forecast Panel", options = ["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group = GRP_POS)
posBacktest = input.string("Bottom Right", "Backtest Panel", options = ["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group = GRP_POS)


// ─── Alerts ──────────────────────────────────────────────────────────────────
alertBullEntry = input.bool(true,  "Bull Regime Entry",      group = GRP_ALERT)
alertBearEntry = input.bool(true,  "Bear Regime Entry",      group = GRP_ALERT)
alertSideEntry = input.bool(false, "Sideways Regime Entry",  group = GRP_ALERT)
alertHighConf  = input.bool(true,  "High Confidence (≥ 2.5×)", group = GRP_ALERT,
     tooltip = "Fires when |log_return| ≥ 2.5 × threshold — an unusually strong directional move.")
alertHTFConf   = input.bool(true,  "MTF Confluence (HTF Aligned)", group = GRP_ALERT,
     tooltip = "Fires on a regime entry only when the HTF regime agrees with the new regime.")
alertPending   = input.bool(false, "Pending Regime (boundary approach)", group = GRP_ALERT,
     tooltip = "Fires when, while inside Sideways, the rolling log return reaches 70 % of either boundary — early-warning cue before the official regime change.\n\nDefault OFF.  Can re-fire if the return oscillates around the 70 % threshold within one Sideways stretch.")


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 2   —   THEME RESOLVER   (ten themes from the Apex design system)
// ═══════════════════════════════════════════════════════════════════════════════
// Each theme contributes three regime axes — Bull, Bear, Sideways.  The
// Sideways color is chosen to feel adjacent to (not compete with) the
// theme's bull / bear axes — typically a desaturated neutral grey.

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
//   SECTION 3   —   REGIME COMPUTATION
// ═══════════════════════════════════════════════════════════════════════════════
// Confidence semantics — used by the ribbon intensity and the dashboard tier:
//   1.0× = at the boundary · 2.0× = twice the cut · 3.0×+ = stretched

float bar1Ret = math.log(close / close[1])
float sigma1  = ta.stdev(bar1Ret, sigmaWin)
float logRet  = math.log(close / close[lookbackN])

float adaptCut = kSigma * sigma1 * math.sqrt(lookbackN)
float thrBull  = thrMode == MODE_ADAPT ? adaptCut : bullThrPct / 100.0
float thrBear  = thrMode == MODE_ADAPT ? adaptCut : bearThrPct / 100.0

// sigma1 is only consumed by the adaptive branch — in Fixed mode we keep regime
// alive even when the volatility window has not warmed up yet.
int regime = na(logRet) or (thrMode == MODE_ADAPT and na(sigma1)) ? int(na) :
     logRet >  thrBull ? R_BULL :
     logRet < -thrBear ? R_BEAR : R_SIDE

float refThr = regime == R_BULL ? thrBull : regime == R_BEAR ? thrBear : math.max(thrBull, thrBear)
float confidence = refThr > 0 ? math.abs(logRet) / refThr : 0.0


// ─── Pending early-warning ────────────────────────────────────────────────────
// Inside Sideways, when the log return reaches PENDING_FRAC of either boundary,
// we flag the direction it's leaning toward.  This is the partial mitigation of
// the inherent lookback lag — by the time the official regime label flips, the
// move is already N bars old; the pending cue triggers ~30 % earlier.

float distFracBull = thrBull > 0 and not na(logRet) ?  logRet / thrBull  : 0.0
float distFracBear = thrBear > 0 and not na(logRet) ? -logRet / thrBear  : 0.0
float distFrac     = math.max(distFracBull, distFracBear)
int   pendingDir   = logRet > 0 ? R_BULL : R_BEAR
bool  isPending    = not na(regime) and regime == R_SIDE and distFrac >= PENDING_FRAC


// ─── Regime age + completed-run statistics ─────────────────────────────────────
// Powers the semi-Markov refinement: the empirical "expected remaining" cell
// reads completed-run averages instead of the memoryless 1/(1−p) approximation.

var int regAge = 1
regAge := not na(regime) and not na(regime[1]) and regime == regime[1] ? regAge + 1 : 1

var float[] runTotal = array.new_float(3, 0.0)
var int[]   runCount = array.new_int(3, 0)

if barstate.isconfirmed and not na(regime) and not na(regime[1]) and regime != regime[1]
    int prevR = regime[1]
    array.set(runTotal, prevR, array.get(runTotal, prevR) + regAge[1])
    array.set(runCount, prevR, array.get(runCount, prevR) + 1)


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 4   —   TRANSITION COUNTS & BACKTEST ACCUMULATORS
// ═══════════════════════════════════════════════════════════════════════════════
// counts[r*3 + c]        — confirmed transitions from regime r to c (row-major).
// countsYoung / Mature — same, bucketed by the age of the source regime at the
// time of the transition (young = age < empirical avg duration, mature = ≥ avg).
// Bucketing is what gives the duration-conditional self-transition probability
// shown in the Status panel — the semi-Markov refinement.

var int[] counts       = array.new_int(9, 0)
var int[] countsYoung  = array.new_int(9, 0)
var int[] countsMature = array.new_int(9, 0)

int prevReg = regime[1]
if barstate.isconfirmed and not na(prevReg) and not na(regime)
    int idx = prevReg * 3 + regime
    array.set(counts, idx, array.get(counts, idx) + 1)

    // Bucket by the SOURCE regime's age at the previous bar.  Fallback to
    // lookbackN when no completed runs yet — keeps bucketing alive early on.
    int   prevAge      = nz(regAge[1], 1)
    int   prevRC       = array.get(runCount, prevReg)
    float prevAvgDur   = prevRC > 0 ? array.get(runTotal, prevReg) / prevRC : float(lookbackN)
    bool  isPrevYoung  = prevAge < prevAvgDur
    if isPrevYoung
        array.set(countsYoung,  idx, array.get(countsYoung,  idx) + 1)
    else
        array.set(countsMature, idx, array.get(countsMature, idx) + 1)


// ─── Backtest accumulators  (look-ahead-free, fees + slippage modelled) ──────
// `regime` is derived from log(close/close[N]) — it contains today's close,
// so allocating today's return by today's regime is look-ahead.  We allocate
// by regime[1] (yesterday's confirmed regime) instead, which is realisable
// in real time.  Each Bull entry and exit pays the configured fee + slippage,
// applied in log space so it compounds correctly.

float costFrac     = feesPct / 100.0 + slippageBps / 10000.0
float costPerFill  = costFrac > 0.0 ? math.log(1.0 - costFrac) : 0.0   // negative

var float bullLogR     = 0.0
var float bearLogR     = 0.0
var float sideLogR     = 0.0
var float bhLogR       = 0.0
var float bullCostLogR = 0.0   // cumulative fee + slippage debit
var int   bullBars     = 0
var int   bearBars     = 0
var int   sideBars     = 0
var int   bullTrades   = 0     // number of Bull entries (= round-trips, modulo open position)

int regForAlloc = regime[1]

if barstate.isconfirmed and not na(bar1Ret) and not na(regForAlloc)
    bhLogR += bar1Ret
    if regForAlloc == R_BULL
        bullLogR += bar1Ret
        bullBars += 1
    else if regForAlloc == R_BEAR
        bearLogR += bar1Ret
        bearBars += 1
    else
        sideLogR += bar1Ret
        sideBars += 1

bool justEnteredBull = barstate.isconfirmed and regForAlloc == R_BULL and not na(regForAlloc[1]) and regForAlloc[1] != R_BULL
bool justExitedBull  = barstate.isconfirmed and regForAlloc != R_BULL and regForAlloc[1] == R_BULL
if justEnteredBull
    bullTrades   += 1
    bullCostLogR += costPerFill
if justExitedBull
    bullCostLogR += costPerFill


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 5   —   HTF CONFLUENCE   (request.security)
// ═══════════════════════════════════════════════════════════════════════════════
// Always called — Pine ternary is eager, so gating the request inside one
// would still execute it.  useMTF toggles only the dashboard display.
// lookahead_off + gaps_off prevents repaint.

int htfRegime  = request.security(syminfo.tickerid, htfRes, regime,
     lookahead = barmerge.lookahead_off, gaps = barmerge.gaps_off)
bool htfAligned = useMTF and not na(htfRegime) and not na(regime) and htfRegime == regime


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 6   —   VISUAL LAYER   (ribbon + glow signals)
// ═══════════════════════════════════════════════════════════════════════════════

regimeColor(int r) =>
    r == R_BULL ? thBull : r == R_BEAR ? thBear : thSide

regimeName(int r) =>
    r == R_BULL ? "BULL" : r == R_BEAR ? "BEAR" : "SIDE"

regimeArrow(int r) =>
    r == R_BULL ? "▲" : r == R_BEAR ? "▼" : "◆"


// ─── Ribbon transparency by style ────────────────────────────────────────────
float ribbonTransp = switch ribbonStyle
    RBN_SUBTLE => 92.0
    RBN_BOLD   => 75.0
    RBN_ADAPT  => math.max(60.0, math.min(95.0, 92.0 - 20.0 * math.min(nz(confidence), 3.0)))
    =>            85.0

color ribbonCol = na(regime) ? na : color.new(regimeColor(regime), int(ribbonTransp))
bgcolor(showRibbon ? ribbonCol : na, title = "Regime Ribbon")


// ─── Regime change debouncing ────────────────────────────────────────────────
// A new regime must persist `minHold` confirmed bars before its flip is drawn.
// Uses ta.barssince to avoid runtime-indexed history (`regime[series_k]`)
// which can trip "cannot determine max_bars_back" in Pine v6.

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


// ─── 3-layer neon glow signal shapes ─────────────────────────────────────────
plotshape(showSignals and showSigGlow and bullEntryEvent, "Bull Glow Outer",
     style = shape.triangleup, location = location.belowbar, offset = -flipOff,
     color = color.new(thBull, 80), size = size.large)
plotshape(showSignals and showSigGlow and bullEntryEvent, "Bull Glow Middle",
     style = shape.triangleup, location = location.belowbar, offset = -flipOff,
     color = color.new(thBull, 50), size = size.normal)
plotshape(showSignals and bullEntryEvent, "Bull Core",
     style = shape.triangleup, location = location.belowbar, offset = -flipOff,
     color = color.new(thBull, 0), size = size.small)

plotshape(showSignals and showSigGlow and bearEntryEvent, "Bear Glow Outer",
     style = shape.triangledown, location = location.abovebar, offset = -flipOff,
     color = color.new(thBear, 80), size = size.large)
plotshape(showSignals and showSigGlow and bearEntryEvent, "Bear Glow Middle",
     style = shape.triangledown, location = location.abovebar, offset = -flipOff,
     color = color.new(thBear, 50), size = size.normal)
plotshape(showSignals and bearEntryEvent, "Bear Core",
     style = shape.triangledown, location = location.abovebar, offset = -flipOff,
     color = color.new(thBear, 0), size = size.small)

plotshape(showSignals and showSigGlow and sideEntryEvent, "Side Glow Outer",
     style = shape.diamond, location = location.abovebar, offset = -flipOff,
     color = color.new(thSide, 80), size = size.large)
plotshape(showSignals and showSigGlow and sideEntryEvent, "Side Glow Middle",
     style = shape.diamond, location = location.abovebar, offset = -flipOff,
     color = color.new(thSide, 50), size = size.normal)
plotshape(showSignals and sideEntryEvent, "Side Core",
     style = shape.diamond, location = location.abovebar, offset = -flipOff,
     color = color.new(thSide, 0), size = size.small)


// ─── Confidence tag (optional label on the flip bar) ─────────────────────────
if showConfTag and (bullEntryEvent or bearEntryEvent or sideEntryEvent)
    string tag = regimeName(regime) + "  " + str.tostring(confidence, "0.0") + "×"
    color tagCol = regimeColor(regime)
    label.new(bar_index - flipOff,
         regime == R_BULL ? low[flipOff] : high[flipOff],
         text = tag,
         yloc  = regime == R_BULL ? yloc.belowbar : yloc.abovebar,
         style = regime == R_BULL ? label.style_label_up : label.style_label_down,
         color = color.new(tagCol, 75), textcolor = tagCol,
         size = size.small)


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 7   —   3×3 MATRIX MULTIPLY  (portable, unrolled)
// ═══════════════════════════════════════════════════════════════════════════════
// Pine v6 has matrix.* but the unrolled flat-array form is faster for the 3×3
// case and works everywhere.  Row-major:  M[r,c] = arr[r*3 + c].

matmul3(float[] A, float[] B) =>
    float a00 = array.get(A, 0)
    float a01 = array.get(A, 1)
    float a02 = array.get(A, 2)
    float a10 = array.get(A, 3)
    float a11 = array.get(A, 4)
    float a12 = array.get(A, 5)
    float a20 = array.get(A, 6)
    float a21 = array.get(A, 7)
    float a22 = array.get(A, 8)

    float b00 = array.get(B, 0)
    float b01 = array.get(B, 1)
    float b02 = array.get(B, 2)
    float b10 = array.get(B, 3)
    float b11 = array.get(B, 4)
    float b12 = array.get(B, 5)
    float b20 = array.get(B, 6)
    float b21 = array.get(B, 7)
    float b22 = array.get(B, 8)

    float[] C = array.new_float(9, 0.0)
    array.set(C, 0, a00 * b00 + a01 * b10 + a02 * b20)
    array.set(C, 1, a00 * b01 + a01 * b11 + a02 * b21)
    array.set(C, 2, a00 * b02 + a01 * b12 + a02 * b22)
    array.set(C, 3, a10 * b00 + a11 * b10 + a12 * b20)
    array.set(C, 4, a10 * b01 + a11 * b11 + a12 * b21)
    array.set(C, 5, a10 * b02 + a11 * b12 + a12 * b22)
    array.set(C, 6, a20 * b00 + a21 * b10 + a22 * b20)
    array.set(C, 7, a20 * b01 + a21 * b11 + a22 * b21)
    array.set(C, 8, a20 * b02 + a21 * b12 + a22 * b22)
    C


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 8   —   DASHBOARD HELPERS  (top-level — Pine requires it)
// ═══════════════════════════════════════════════════════════════════════════════

f_pct(float p) =>
    na(p) ? "—" : str.tostring(math.round(p * 100)) + "%"

f_signedPct(float p) =>
    na(p) ? "—" : (p >= 0 ? "+" : "") + str.tostring(p * 100, "0.0") + "%"

f_compact(int n) =>
    string s = str.tostring(n)
    if n >= 1000000
        s := str.tostring(n / 1000000.0, "0.0") + "M"
    else if n >= 10000
        s := str.tostring(int(n / 1000.0)) + "k"
    else if n >= 1000
        s := str.tostring(n / 1000.0, "0.0") + "k"
    s

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


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 9   —   LAST-BAR MATH   (P, P_young, P_mature, P^k cones, stationary)
// ═══════════════════════════════════════════════════════════════════════════════
// All heavy work runs once per chart render under barstate.islast.

var float[] P        = array.new_float(9, 1.0 / 3.0)
var float[] PYoung   = array.new_float(9, 1.0 / 3.0)
var float[] PMature  = array.new_float(9, 1.0 / 3.0)
var float[] P3       = array.new_float(9, 1.0 / 3.0)
var float[] P5       = array.new_float(9, 1.0 / 3.0)
var float[] PH       = array.new_float(9, 1.0 / 3.0)
var float[] stat     = array.new_float(3, 1.0 / 3.0)
var int[]   rowSums  = array.new_int(3, 0)
var int[]   rowSumsY = array.new_int(3, 0)
var int[]   rowSumsM = array.new_int(3, 0)
var int     totalN   = 0

if barstate.islast
    // ── Build P (unconditional) + P_young + P_mature ──────────────────────
    // Empty rows fall back to uniform 1/3 to keep matmul numerically safe.
    totalN := 0
    for r = 0 to 2
        int rs  = array.get(counts,       r * 3) + array.get(counts,       r * 3 + 1) + array.get(counts,       r * 3 + 2)
        int rsy = array.get(countsYoung,  r * 3) + array.get(countsYoung,  r * 3 + 1) + array.get(countsYoung,  r * 3 + 2)
        int rsm = array.get(countsMature, r * 3) + array.get(countsMature, r * 3 + 1) + array.get(countsMature, r * 3 + 2)
        array.set(rowSums,  r, rs)
        array.set(rowSumsY, r, rsy)
        array.set(rowSumsM, r, rsm)
        totalN += rs
        for c = 0 to 2
            int idx2 = r * 3 + c
            float cell  = rs  > 0 ? array.get(counts,       idx2) / float(rs)  : 1.0 / 3.0
            float cellY = rsy > 0 ? array.get(countsYoung,  idx2) / float(rsy) : 1.0 / 3.0
            float cellM = rsm > 0 ? array.get(countsMature, idx2) / float(rsm) : 1.0 / 3.0
            array.set(P,       idx2, cell)
            array.set(PYoung,  idx2, cellY)
            array.set(PMature, idx2, cellM)

    // ── Stationary distribution via power iteration ───────────────────────
    float[] Mst = array.copy(P)
    for _ii = 1 to stationaryIters - 1
        Mst := matmul3(Mst, P)
    // Any row of converged M is the stationary 3-vector; take row 0.
    array.set(stat, R_SIDE, array.get(Mst, 0))
    array.set(stat, R_BULL, array.get(Mst, 1))
    array.set(stat, R_BEAR, array.get(Mst, 2))

    // ── Forecast cone: P¹, P³, P⁵ from a single power loop ────────────────
    // P¹ = P (already populated above).
    float[] Pk = array.copy(P)
    Pk := matmul3(Pk, P)   // k = 2
    Pk := matmul3(Pk, P)   // k = 3
    for i = 0 to 8
        array.set(P3, i, array.get(Pk, i))
    Pk := matmul3(Pk, P)   // k = 4
    Pk := matmul3(Pk, P)   // k = 5
    for i = 0 to 8
        array.set(P5, i, array.get(Pk, i))

    // P^horizon — re-start so we handle fcstBars < 5 correctly
    float[] Phh = array.copy(P)
    for _ih = 1 to fcstBars - 1
        Phh := matmul3(Phh, P)
    for i = 0 to 8
        array.set(PH, i, array.get(Phh, i))


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 10   —   PRO DASHBOARDS   (theme-aware, Dark / Light)
// ═══════════════════════════════════════════════════════════════════════════════

// Confidence visual — three-block bar + tier label
string confBar = na(confidence) ? "—" :
     confidence < 1.0 ? "▱▱▱" :
     confidence < 2.0 ? "▰▱▱" :
     confidence < 3.0 ? "▰▰▱" : "▰▰▰"
string confLbl = na(confidence) ? "—" :
     confidence < 1.0 ? "weak" :
     confidence < 2.0 ? "moderate" :
     confidence < 3.0 ? "strong" : "stretched"
color confCol = na(regime) ? dashFgDim : regimeColor(regime)

var table tStatus   = na
var table tMatrix   = na
var table tForecast = na
var table tBacktest = na


// ─── STATUS PANEL ────────────────────────────────────────────────────────────
if barstate.islast and showStatus
    int statusRows = useMTF ? 19 : 16
    tStatus := table.new(f_pos(posStatus), 2, statusRows,
         bgcolor = dashBg, border_color = dashBorder, border_width = 1,
         frame_color = dashBorder, frame_width = 2)

    // Row 0 — header
    table.cell(tStatus, 0, 0, "MARKOV FORECASTER PRO",
         text_color = dashHeader, bgcolor = dashSection,
         text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tStatus, 1, 0, "v1.1",
         text_color = dashFgDim, bgcolor = dashSection,
         text_size = f_size(dashSize), text_halign = text.align_right)

    // Row 1 — Mode
    string modeText = thrMode == MODE_ADAPT ?
         "Adaptive " + str.tostring(kSigma, "0.0") + "σ" :
         "Fixed ±" + str.tostring(bullThrPct, "0.0") + "%"
    table.cell(tStatus, 0, 1, "Mode",
         text_color = dashFg, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tStatus, 1, 1, modeText,
         text_color = dashFg, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_right)

    // Row 2 — Lookback
    table.cell(tStatus, 0, 2, "Lookback",
         text_color = dashFg, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tStatus, 1, 2, str.tostring(lookbackN) + " bars",
         text_color = dashFg, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_right)

    // Row 3 — REGIME divider
    table.cell(tStatus, 0, 3, "REGIME",
         text_color = dashHeader, bgcolor = dashSection, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tStatus, 1, 3, "",
         bgcolor = dashSection, text_size = f_size(dashSize))

    // Row 4 — Now
    string regText = na(regime) ? "—" : regimeArrow(regime) + "  " + regimeName(regime)
    color  regCol  = na(regime) ? dashFg : regimeColor(regime)
    table.cell(tStatus, 0, 4, "Now",
         text_color = dashFg, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tStatus, 1, 4, regText,
         text_color = regCol, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_right)

    // Row 5 — Age
    table.cell(tStatus, 0, 5, "Age",
         text_color = dashFg, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tStatus, 1, 5, str.tostring(regAge) + " bars",
         text_color = dashFg, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_right)

    // Row 6 — Confidence
    string confText = confBar + "  " + str.tostring(confidence, "0.0") + "×  " + confLbl
    table.cell(tStatus, 0, 6, "Confidence",
         text_color = dashFg, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tStatus, 1, 6, confText,
         text_color = confCol, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_right)

    // Row 7 — Pending (early-warning)
    string pendingText = "—"
    color  pendingCol  = dashFgDim
    if isPending and not na(pendingDir)
        pendingText := "⚠ " + regimeArrow(pendingDir) + " " + regimeName(pendingDir) + "  " + str.tostring(math.round(distFrac * 100)) + "%"
        pendingCol  := regimeColor(pendingDir)
    table.cell(tStatus, 0, 7, "Pending",
         text_color = dashFg, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tStatus, 1, 7, pendingText,
         text_color = pendingCol, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_right)

    // Row 8 — DURATION divider
    table.cell(tStatus, 0, 8, "DURATION",
         text_color = dashHeader, bgcolor = dashSection, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tStatus, 1, 8, "",
         bgcolor = dashSection, text_size = f_size(dashSize))

    // Row 9 — Avg duration
    int    rcCur     = na(regime) ? 0 : array.get(runCount, regime)
    float  rtCur     = na(regime) ? 0.0 : array.get(runTotal, regime)
    float  avgDurCur = rcCur > 0 ? rtCur / rcCur : na
    string avgText   = rcCur > 0 ? str.tostring(math.round(rtCur / rcCur)) + " bars" : "—"
    table.cell(tStatus, 0, 9, "Avg duration",
         text_color = dashFg, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tStatus, 1, 9, avgText,
         text_color = dashFg, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_right)

    // Row 10 — Bucket (where the current age stands)
    string bucketText = "—"
    color  bucketCol  = dashFgDim
    if not na(regime) and rcCur >= 3
        bool isMature = regAge >= avgDurCur
        bucketText := isMature ? "Mature" : "Young"
        bucketCol  := isMature ? cDivergent : regimeColor(regime)
    table.cell(tStatus, 0, 10, "Bucket",
         text_color = dashFg, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tStatus, 1, 10, bucketText,
         text_color = bucketCol, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_right)

    // Row 11 — Expected remaining (empirical, semi-Markov)
    string remText = "—"
    color  remCol  = dashFg
    if not na(regime) and rcCur >= 3
        int remBars = math.max(0, int(math.round(avgDurCur - regAge)))
        remText := "~" + str.tostring(remBars) + " bars"
        remCol  := remBars < 5 ? cDivergent : dashFg
    table.cell(tStatus, 0, 11, "Expected remaining",
         text_color = dashFg, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tStatus, 1, 11, remText,
         text_color = remCol, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_right)

    // Row 12 — P[stay] young / mature  (duration-conditional self-trans prob)
    string pStayText = "—"
    color  pStayCol  = dashFgDim
    if not na(regime)
        int   rsy   = array.get(rowSumsY, regime)
        int   rsm   = array.get(rowSumsM, regime)
        float pY    = rsy >= MIN_BUCKET_N ? array.get(PYoung,  regime * 3 + regime) : na
        float pM    = rsm >= MIN_BUCKET_N ? array.get(PMature, regime * 3 + regime) : na
        pStayText := f_pct(pY) + " / " + f_pct(pM)
        pStayCol  := regimeColor(regime)
    table.cell(tStatus, 0, 12, "P[stay] young / mature",
         text_color = dashFg, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tStatus, 1, 12, pStayText,
         text_color = pStayCol, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_right)

    // Row 13 — DATA divider
    table.cell(tStatus, 0, 13, "DATA",
         text_color = dashHeader, bgcolor = dashSection, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tStatus, 1, 13, "",
         bgcolor = dashSection, text_size = f_size(dashSize))

    // Row 14 — Long-run share (stationary)
    float statCur = na(regime) ? na : array.get(stat, regime)
    table.cell(tStatus, 0, 14, "Long-run share",
         text_color = dashFg, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tStatus, 1, 14, f_pct(statCur),
         text_color = dashFg, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_right)

    // Row 15 — Sample N (reliability tier)
    color  sampleCol = totalN >= 200 ? thBull : totalN >= 50 ? dashFg : cDivergent
    string sampleLbl = totalN >= 200 ? "high" : totalN >= 50 ? "moderate" : "low"
    table.cell(tStatus, 0, 15, "Sample N",
         text_color = dashFg, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tStatus, 1, 15, f_compact(totalN) + "  (" + sampleLbl + ")",
         text_color = sampleCol, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_right)

    // ─── HTF block ───
    if useMTF
        table.cell(tStatus, 0, 16, "HTF (" + htfRes + ")",
             text_color = dashHeader, bgcolor = dashSection, text_size = f_size(dashSize), text_halign = text.align_left)
        table.cell(tStatus, 1, 16, "",
             bgcolor = dashSection, text_size = f_size(dashSize))

        string htfRegText = na(htfRegime) ? "—" : regimeArrow(htfRegime) + "  " + regimeName(htfRegime)
        color  htfRegCol  = na(htfRegime) ? dashFg : regimeColor(htfRegime)
        table.cell(tStatus, 0, 17, "Regime",
             text_color = dashFg, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_left)
        table.cell(tStatus, 1, 17, htfRegText,
             text_color = htfRegCol, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_right)

        string alignText = na(htfRegime) or na(regime) ? "—" :
             htfAligned ? "✓ ALIGNED" : "⚠ DIVERGENT"
        color  alignCol  = na(htfRegime) or na(regime) ? dashFg :
             htfAligned ? cAligned : cDivergent
        table.cell(tStatus, 0, 18, "Status",
             text_color = dashFg, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_left)
        table.cell(tStatus, 1, 18, alignText,
             text_color = alignCol, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_right)


// ─── TRANSITION MATRIX PANEL ─────────────────────────────────────────────────
// 5 cols × 6 rows.  Col 4 ("n") shows per-row sample count — when rowN < 30,
// the cell is painted in the divergent color to flag unreliable conditional
// probabilities for that source regime.

if barstate.islast and showMatrix
    tMatrix := table.new(f_pos(posMatrix), 5, 6,
         bgcolor = dashBg, border_color = dashBorder, border_width = 1,
         frame_color = dashBorder, frame_width = 2)

    // Row 0 — title
    table.cell(tMatrix, 0, 0, "TRANSITION MATRIX",
         text_color = dashHeader, bgcolor = dashSection, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tMatrix, 1, 0, "", bgcolor = dashSection, text_size = f_size(dashSize))
    table.cell(tMatrix, 2, 0, "", bgcolor = dashSection, text_size = f_size(dashSize))
    table.cell(tMatrix, 3, 0, "", bgcolor = dashSection, text_size = f_size(dashSize))
    table.cell(tMatrix, 4, 0, "3×3",
         text_color = dashFgDim, bgcolor = dashSection, text_size = f_size(dashSize), text_halign = text.align_right)

    // Row 1 — column header
    table.cell(tMatrix, 0, 1, "from \\ to",
         text_color = dashFgDim, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tMatrix, 1, 1, "BULL",
         text_color = thBull, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_center)
    table.cell(tMatrix, 2, 1, "BEAR",
         text_color = thBear, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_center)
    table.cell(tMatrix, 3, 1, "SIDE",
         text_color = thSide, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_center)
    table.cell(tMatrix, 4, 1, "n",
         text_color = dashFgDim, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_right)

    // Rows 2–4 — one per source regime (display order: BULL, BEAR, SIDE)
    int[] dispToInt = array.from(R_BULL, R_BEAR, R_SIDE)

    for r = 0 to 2
        int    ir      = array.get(dispToInt, r)
        color  rowCol  = regimeColor(ir)
        string rowName = regimeName(ir)
        color  rowBg   = r % 2 == 0 ? dashBg : dashBgAlt
        int    rowN    = array.get(rowSums, ir)
        bool   lowRow  = rowN < MIN_ROW_N

        table.cell(tMatrix, 0, r + 2, rowName,
             text_color = rowCol, bgcolor = rowBg, text_size = f_size(dashSize), text_halign = text.align_left)
        for c = 0 to 2
            int   ic     = array.get(dispToInt, c)
            float p      = array.get(P, ir * 3 + ic)
            bool  diag   = r == c
            color cellBg = diag ? color.new(rowCol, 80) : rowBg
            color cellTx = diag ? rowCol : dashFgDim
            table.cell(tMatrix, c + 1, r + 2, f_pct(p),
                 text_color = cellTx, bgcolor = cellBg,
                 text_size = f_size(dashSize),
                 text_halign = text.align_center, text_valign = text.align_center)

        // Sample-count cell — colored by reliability tier
        color nCol = lowRow ? cDivergent : (rowN >= 100 ? dashFg : dashFgDim)
        table.cell(tMatrix, 4, r + 2, f_compact(rowN),
             text_color = nCol, bgcolor = rowBg, text_size = f_size(dashSize),
             text_halign = text.align_right, text_valign = text.align_center)

    // Row 5 — footer
    table.cell(tMatrix, 0, 5, "next-bar  P",
         text_color = dashFgDim, bgcolor = dashSection, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tMatrix, 1, 5, "", bgcolor = dashSection, text_size = f_size(dashSize))
    table.cell(tMatrix, 2, 5, "", bgcolor = dashSection, text_size = f_size(dashSize))
    table.cell(tMatrix, 3, 5, "N = " + f_compact(totalN),
         text_color = dashFgDim, bgcolor = dashSection, text_size = f_size(dashSize), text_halign = text.align_right)
    table.cell(tMatrix, 4, 5, "live",
         text_color = thBull, bgcolor = dashSection, text_size = f_size(dashSize), text_halign = text.align_right)


// ─── FORECAST CONE PANEL ─────────────────────────────────────────────────────
if barstate.islast and showForecast
    tForecast := table.new(f_pos(posForecast), 5, 7,
         bgcolor = dashBg, border_color = dashBorder, border_width = 1,
         frame_color = dashBorder, frame_width = 2)

    table.cell(tForecast, 0, 0, "FORWARD PROBABILITY",
         text_color = dashHeader, bgcolor = dashSection, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tForecast, 1, 0, "", bgcolor = dashSection, text_size = f_size(dashSize))
    table.cell(tForecast, 2, 0, "", bgcolor = dashSection, text_size = f_size(dashSize))
    table.cell(tForecast, 3, 0, "", bgcolor = dashSection, text_size = f_size(dashSize))
    table.cell(tForecast, 4, 0, "cone",
         text_color = dashFgDim, bgcolor = dashSection, text_size = f_size(dashSize), text_halign = text.align_right)

    table.cell(tForecast, 0, 1, "given now",
         text_color = dashFgDim, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tForecast, 1, 1, "+1",
         text_color = dashFgDim, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_center)
    table.cell(tForecast, 2, 1, "+3",
         text_color = dashFgDim, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_center)
    table.cell(tForecast, 3, 1, "+5",
         text_color = dashFgDim, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_center)
    table.cell(tForecast, 4, 1, "+" + str.tostring(fcstBars),
         text_color = dashFgDim, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_center)

    int curR = na(regime) ? R_SIDE : regime
    int[] order = array.from(R_BULL, R_BEAR, R_SIDE)
    for r = 0 to 2
        int    ir    = array.get(order, r)
        color  col   = regimeColor(ir)
        color  rowBg = r % 2 == 0 ? dashBg : dashBgAlt
        table.cell(tForecast, 0, r + 2, regimeName(ir),
             text_color = col, bgcolor = rowBg, text_size = f_size(dashSize), text_halign = text.align_left)

        float p1 = array.get(P,  curR * 3 + ir)
        float p3 = array.get(P3, curR * 3 + ir)
        float p5 = array.get(P5, curR * 3 + ir)
        float ph = array.get(PH, curR * 3 + ir)

        table.cell(tForecast, 1, r + 2, f_pct(p1),
             text_color = col, bgcolor = rowBg, text_size = f_size(dashSize), text_halign = text.align_center)
        table.cell(tForecast, 2, r + 2, f_pct(p3),
             text_color = col, bgcolor = rowBg, text_size = f_size(dashSize), text_halign = text.align_center)
        table.cell(tForecast, 3, r + 2, f_pct(p5),
             text_color = col, bgcolor = rowBg, text_size = f_size(dashSize), text_halign = text.align_center)
        table.cell(tForecast, 4, r + 2, f_pct(ph),
             text_color = col, bgcolor = rowBg, text_size = f_size(dashSize), text_halign = text.align_center)

    table.cell(tForecast, 0, 5, "steady state",
         text_color = dashFgDim, bgcolor = dashSection, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tForecast, 1, 5, f_pct(array.get(stat, R_BULL)),
         text_color = thBull, bgcolor = dashSection, text_size = f_size(dashSize), text_halign = text.align_center)
    table.cell(tForecast, 2, 5, f_pct(array.get(stat, R_BEAR)),
         text_color = thBear, bgcolor = dashSection, text_size = f_size(dashSize), text_halign = text.align_center)
    table.cell(tForecast, 3, 5, f_pct(array.get(stat, R_SIDE)),
         text_color = thSide, bgcolor = dashSection, text_size = f_size(dashSize), text_halign = text.align_center)
    table.cell(tForecast, 4, 5, "long-run",
         text_color = dashFgDim, bgcolor = dashSection, text_size = f_size(dashSize), text_halign = text.align_right)

    color  curCol  = na(regime) ? dashFg : regimeColor(regime)
    string curText = na(regime) ? "currently —" : "currently " + regimeName(regime)
    table.cell(tForecast, 0, 6, curText,
         text_color = curCol, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tForecast, 1, 6, "", bgcolor = dashBg)
    table.cell(tForecast, 2, 6, "", bgcolor = dashBg)
    table.cell(tForecast, 3, 6, "", bgcolor = dashBg)
    table.cell(tForecast, 4, 6, "unconditional",
         text_color = dashFgDim, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_right)


// ─── BACKTEST PANEL ──────────────────────────────────────────────────────────
// Strategy: long when prior bar's regime is Bull, flat otherwise.  The per-
// regime rows show GROSS cumulative log return; the Strategy row shows the
// NET result after the configured fee + slippage on each entry and exit.

if barstate.islast and showBacktest
    tBacktest := table.new(f_pos(posBacktest), 4, 7,
         bgcolor = dashBg, border_color = dashBorder, border_width = 1,
         frame_color = dashBorder, frame_width = 2)

    table.cell(tBacktest, 0, 0, "BACKTEST",
         text_color = dashHeader, bgcolor = dashSection, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tBacktest, 1, 0, "", bgcolor = dashSection)
    table.cell(tBacktest, 2, 0, "", bgcolor = dashSection)
    table.cell(tBacktest, 3, 0, "Bull-only long",
         text_color = dashFgDim, bgcolor = dashSection, text_size = f_size(dashSize), text_halign = text.align_right)

    table.cell(tBacktest, 0, 1, "regime",
         text_color = dashFgDim, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tBacktest, 1, 1, "bars",
         text_color = dashFgDim, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_center)
    table.cell(tBacktest, 2, 1, "cum (gross)",
         text_color = dashFgDim, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_center)
    table.cell(tBacktest, 3, 1, "avg/bar",
         text_color = dashFgDim, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_right)

    float bullCum    = math.exp(bullLogR) - 1.0
    float bullNetCum = math.exp(bullLogR + bullCostLogR) - 1.0
    float bearCum    = math.exp(bearLogR) - 1.0
    float sideCum    = math.exp(sideLogR) - 1.0
    float bhCum      = math.exp(bhLogR)   - 1.0
    float bullAvg    = bullBars > 0 ? bullLogR / bullBars : na
    float bearAvg    = bearBars > 0 ? bearLogR / bearBars : na
    float sideAvg    = sideBars > 0 ? sideLogR / sideBars : na

    // Bull row
    table.cell(tBacktest, 0, 2, "BULL",
         text_color = thBull, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tBacktest, 1, 2, str.tostring(bullBars),
         text_color = dashFg, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_center)
    table.cell(tBacktest, 2, 2, f_signedPct(bullCum),
         text_color = bullCum >= 0 ? thBull : thBear, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_center)
    table.cell(tBacktest, 3, 2, f_signedPct(bullAvg),
         text_color = nz(bullAvg) >= 0 ? thBull : thBear, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_right)

    // Bear row
    table.cell(tBacktest, 0, 3, "BEAR",
         text_color = thBear, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tBacktest, 1, 3, str.tostring(bearBars),
         text_color = dashFg, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_center)
    table.cell(tBacktest, 2, 3, f_signedPct(bearCum),
         text_color = bearCum >= 0 ? thBull : thBear, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_center)
    table.cell(tBacktest, 3, 3, f_signedPct(bearAvg),
         text_color = nz(bearAvg) >= 0 ? thBull : thBear, bgcolor = dashBgAlt, text_size = f_size(dashSize), text_halign = text.align_right)

    // Side row
    table.cell(tBacktest, 0, 4, "SIDE",
         text_color = thSide, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tBacktest, 1, 4, str.tostring(sideBars),
         text_color = dashFg, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_center)
    table.cell(tBacktest, 2, 4, f_signedPct(sideCum),
         text_color = sideCum >= 0 ? thBull : thBear, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_center)
    table.cell(tBacktest, 3, 4, f_signedPct(sideAvg),
         text_color = nz(sideAvg) >= 0 ? thBull : thBear, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_right)

    // Strategy summary — NET vs B&H (the headline number)
    string strategyText = "net " + f_signedPct(bullNetCum) + "  vs B&H " + f_signedPct(bhCum)
    color  strategyCol  = bullNetCum > bhCum ? thBull : thBear
    table.cell(tBacktest, 0, 5, "Strategy",
         text_color = dashHeader, bgcolor = dashSection, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tBacktest, 1, 5, "", bgcolor = dashSection)
    table.cell(tBacktest, 2, 5, "", bgcolor = dashSection)
    table.cell(tBacktest, 3, 5, strategyText,
         text_color = strategyCol, bgcolor = dashSection, text_size = f_size(dashSize), text_halign = text.align_right)

    // Methodology footer
    string methodLeft = str.tostring(bullTrades) + " trades · " +
         str.tostring(feesPct, "0.00") + "% fee · " +
         str.tostring(slippageBps) + " bps slip"
    table.cell(tBacktest, 0, 6, methodLeft,
         text_color = dashFgDim, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_left)
    table.cell(tBacktest, 1, 6, "", bgcolor = dashBg)
    table.cell(tBacktest, 2, 6, "", bgcolor = dashBg)
    table.cell(tBacktest, 3, 6, "prior-bar alloc",
         text_color = dashFgDim, bgcolor = dashBg, text_size = f_size(dashSize), text_halign = text.align_right)


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 11   —   ALERTS
// ═══════════════════════════════════════════════════════════════════════════════

alertcondition(alertBullEntry and bullEntryEvent,
     title   = "Markov Forecaster PRO — Bull Entry",
     message = "Markov Forecaster PRO: regime flipped to BULL on {{ticker}} {{interval}}.")

alertcondition(alertBearEntry and bearEntryEvent,
     title   = "Markov Forecaster PRO — Bear Entry",
     message = "Markov Forecaster PRO: regime flipped to BEAR on {{ticker}} {{interval}}.")

alertcondition(alertSideEntry and sideEntryEvent,
     title   = "Markov Forecaster PRO — Sideways Entry",
     message = "Markov Forecaster PRO: regime flipped to SIDEWAYS on {{ticker}} {{interval}}.")

bool highConfEvent = barstate.isconfirmed and not na(confidence) and confidence >= 2.5 and (na(confidence[1]) or confidence[1] < 2.5)
alertcondition(alertHighConf and highConfEvent,
     title   = "Markov Forecaster PRO — High Confidence",
     message = "Markov Forecaster PRO: confidence ≥ 2.5× threshold — unusually strong move on {{ticker}} {{interval}}.")

bool mtfConfEvent = barstate.isconfirmed and (bullEntryEvent or bearEntryEvent) and htfAligned
alertcondition(alertHTFConf and mtfConfEvent,
     title   = "Markov Forecaster PRO — MTF Confluence",
     message = "Markov Forecaster PRO: regime change with HTF agreement on {{ticker}} {{interval}}.")

bool pendingEnteredEvent = barstate.isconfirmed and isPending and not isPending[1]
alertcondition(alertPending and pendingEnteredEvent,
     title   = "Markov Forecaster PRO — Pending Regime",
     message = "Markov Forecaster PRO: approaching regime boundary (≥ 70% of threshold) on {{ticker}} {{interval}}.")


// ═══════════════════════════════════════════════════════════════════════════════
//   END CODE
// ═══════════════════════════════════════════════════════════════════════════════
````
