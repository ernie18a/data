# Trendline Break Detector [TBD]

- url: https://www.tradingview.com/script/nJxhPCKE-Trendline-Break-Detector-TBD/
- type: indicator
- pine_id: PUB;c247bb95d7e24684940084bf22633ee6
- version: 1.0

## Description

# Trendline Break Detector [TBD]

A structural analysis indicator that identifies pivot trendline breaks across three independent pivot tiers (Fast / Medium / Slow) and rates every break with a single 0–12 Break Strength score. The score summarises both the quality of the break itself and the broader trend context surrounding it.

This is a structural analysis tool, not a signal generator. It marks where pivot structures break and how cleanly. It does not place trades or suggest entries, exits, targets, stops, or position sizes. The arrows are descriptive annotations of market structure.

────────────────────────────────────
WHAT THE INDICATOR DRAWS
────────────────────────────────────

• Swing trendlines built from pivot points, at three configurable timescales (Fast / Medium / Slow tiers, default lengths 8 / 21 / 34) drawn simultaneously

• Direction arrow labels at the exact bar where each pivot trendline is broken, showing:
  - The tier's pivot length (e.g. 21)
  - The direction arrow (▲ upward break / ▼ downward break)
  - The Break Strength score (e.g. ·9) in the range 0–12

• Confluence S/R zones (optional) — coloured boxes showing where multiple support/resistance sources cluster together, scored 0–10

• Status Panel — a compact 5-row overlay summarising active tiers, the most recent break, its score, current trend context (VWAP, ER, HTF), and how many filter gates are active

────────────────────────────────────
WHY FIBONACCI PIVOT LENGTHS (8 / 21 / 34)?
────────────────────────────────────

The three default tier lengths are not arbitrary — they are consecutive terms from the Fibonacci sequence (1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144 ...). Three properties of the Fibonacci sequence make it especially well suited to a multi-tier pivot indicator:

1. The ratio between consecutive terms approaches the golden ratio (φ ≈ 1.618).

8 → 21 is roughly 2.6× (skipping a term gives the φ² ratio of ~2.618), and 21 → 34 is roughly 1.62× (φ itself). This means each tier is meaningfully separated from the next on a logarithmic scale, so the three tiers detect genuinely different timescales of structure rather than near-duplicates. If you used 8 / 10 / 12 instead, all three tiers would fire on essentially the same pivots.

2. Fibonacci-spaced lookbacks produce naturally diverse signals.

A pivot of length N requires N bars on each side without a higher high (or lower low). Fibonacci spacing ensures that the bar requirement at each tier grows non-linearly: the Fast tier (8) reacts to short-term swings, the Medium tier (21) to swings roughly half an hour to a few hours apart on intraday charts, and the Slow tier (34) to the major intraday or multi-session structure.

3. Fibonacci numbers and ratios are deeply established in technical analysis literature.

Pivot lengths drawn from Fibonacci values are widely used because they produce repeatable, recognisable swing structures across many instruments. The 8 / 21 / 34 choice is a balanced midpoint of the sequence — small enough to catch intraday structure, large enough to filter out tick-level noise.

You can override the defaults. All three tier lengths are exposed as inputs (Pivot Lengths group). If you prefer Wilder's classic 14, a tighter set like 5 / 13 / 21, or a slower set like 13 / 34 / 89, simply change them.

────────────────────────────────────
MULTI-INSTANCE TECHNIQUE FOR HIGHER-TIMEFRAME CONTEXT
(RECOMMENDED FOR LOW TIMEFRAMES)
────────────────────────────────────

The indicator's three tiers cover roughly one decade of timescale separation (8 → 34 is ~4×). On very low timeframes — 1m, 3m, 5m — that single decade often is not enough to see the whole structural picture. The Fast tier (length 8 on 1m = ~8 minutes) and the Slow tier (length 34 on 1m = ~34 minutes) both live inside what a 15m or 1H trader would consider a single bar.

The cleanest way to get true multi-timeframe context without changing chart is to apply the indicator multiple times to the same chart with different pivot length sets, like this:

| Instance | Fast | Medium | Slow | What it captures (on a 1-minute chart) |
|---|---|---|---|---|
| 1 — Local | 8 | 21 | 34 | Sub-minute to ~30-minute structure |
| 2 — Intermediate | 21 | 34 | 55 | ~20-minute to ~1-hour structure |
| 3 — Context | 34 | 89 | 144 | ~30-minute to ~2.5-hour structure |

All three instances run on the same 1-minute chart, but each one sees a different timescale of structure. The lengths share consecutive Fibonacci values across instances (34 appears in all three; 21 in two; 55 in two), so the tiers chain together coherently rather than fighting each other.

How to read the stacked instances:
• When a high-score break fires on Instance 3 (slowest), you are seeing a major structural event on a higher timeframe — the kind of break that typically initiates trends.
• When a high-score break on Instance 1 (fastest) lines up with the direction of recent Instance 2 / Instance 3 breaks, the smaller break is occurring with-trend on the higher timeframe.
• When Instance 1 breaks against the established Instance 3 direction, treat it as a counter-trend or mean-reversion event.

Practical setup tips:
• Disable the Status Panel on two of the three instances (Settings → Status Panel → Show Status Panel) to avoid stacked panels. Keep it visible only on the most-watched instance.
• Use the Style settings to give each instance a slightly different colour so the labels remain distinguishable on the chart.
• Disable trendline drawing on the faster instances if the chart gets cluttered (Trendlines → Show Trendlines off) — you can still see the break arrows.

This stacking technique gives you genuine higher-timeframe structural context without ever switching timeframes, which is particularly useful for scalpers and intraday traders who want to read the higher-TF tape while watching execution-grade bars.

────────────────────────────────────
HOW TO INTERPRET THE BREAK STRENGTH SCORE (0–12)
────────────────────────────────────

The score is a descriptive summary of structural properties, not a probability of profit or a recommendation. Higher scores indicate that the break occurred with more of the supporting structural conditions in place (and earlier in the broader trend). They do not guarantee the move continues.

A useful way to read the score band by band:

| Score | Band | What it means structurally |
|---|---|---|
| 0–3 | Very Low | The break occurred without most supporting conditions — small magnitude, low volume, weak pivot, or strong intrabar rejection. Often these are wicks, false breaks, or last-leg moves in already-extended trends. Treat with caution. |
| 4–6 | Low | Some quality conditions met but several are missing. The break is real but unremarkable. Common in chop or transitional regimes. |
| 7–8 | Medium | The break meets most of the structural quality criteria — meaningful magnitude, decent participation, reasonable pivot height. The trend context is mixed (not strongly established yet, not absent). These are the bread-and-butter breaks. |
| 9–10 | High | Most Break Quality criteria are met AND the break occurs ahead of (or at) a structural inflection rather than late in an established trend. These tend to be the cleanest setups the indicator flags. |
| 11–12 | Very High | All-or-near-all Break Quality criteria fire AND the broader trend is not yet established in the break direction — i.e., the break itself is the structural turn. Rare. |

Important nuances about the score:

1. The score is path-dependent on which filter gates you have active.
If you turn off every filter, you will see every break the engine detects regardless of score. If you turn on stringent filters (Adaptive Trail Strict, VWAP Require-strong-aligned, Confluence Zone gate), you will only see breaks that already pass those gates, and the displayed scores will tend to skew higher. Pick a filter configuration and stick with it so the scores remain comparable across your charts.

2. Higher score ≠ better trade.
A high score means the break occurred with strong structural properties. Whether that creates a tradeable opportunity depends entirely on your strategy, risk management, position sizing, and the current market regime. A score of 10 in a choppy range is still a break in a choppy range.

3. The (5 − Trend Context) inversion deliberately penalises late breaks.
A perfectly clean break in an already-established trend will score lower than the same clean break at a fresh turning point. This is intentional: the indicator's design thesis is that quality breaks occur AT structural inflection points, not after them. If you prefer with-trend breakouts to count fully, disable the Trend Context component in the inputs and the score will become Break Quality alone (range 0–7).

4. The score is computed on bar close.
Mid-bar values shown intrabar may revise before close. Treat the displayed score as final only after the bar closes.

5. Compare scores within the same symbol and timeframe.
Because ATR and volume have different magnitudes across symbols and timeframes, comparing a score of 8 on EURUSD-1m to a score of 8 on BTCUSD-1h is not strictly apples-to-apples. The score is most informative as a relative measure within a single chart context.

6. Combine score with tier.
A score of 8 on the Slow tier represents a higher-significance structural event than a score of 8 on the Fast tier, because the Slow-tier trendline took longer to build and represents broader structure. When reading the chart, weight Slow-tier breaks more heavily than Fast-tier breaks at the same score.

7. Use the multi-instance technique to validate scores.
When using three stacked instances (as described above), the most informative situations are those where a high score on the slower instance (e.g. Context 34/89/144) lines up directionally with a high score on the faster instance (e.g. Local 8/21/34). Alignment across instances is a stronger signal than any single instance's score in isolation.

────────────────────────────────────
WHY THIS IS A MASHUP, AND WHY THE COMPONENTS BELONG TOGETHER
────────────────────────────────────

A trendline break, on its own, is a low-information event. The same break can be either a high-quality structural rupture from a long compressed base, or a meaningless poke through a noise-level pivot inside chop. To tell those apart in a reproducible way, you need to measure several independent properties of the break event AND the trend context surrounding it.

This script combines the components below for that single purpose. Each one answers a question the others cannot answer alone. Every one of them feeds into the final 0–12 Break Strength score.

1. Multi-tier swing pivot engine (three parallel tiers)
The core. Builds and tracks pivot-based trendlines at three configurable timescales simultaneously and detects when each is broken. Each tier runs an independent state machine. Three tiers exist because breaks of micro-structure, intermediate structure, and major structure carry very different meaning.

2. ATR (Average True Range)
The volatility yardstick. Used to normalise break magnitude, pivot height, and range expansion across symbols and timeframes. ATR shows up in four of the seven Break Quality components.

3. Kaufman Efficiency Ratio (ER)
Computed as:
|close − close[N]| / sum(|close − close[1]|, N)

Detects pre-break compression: low ER (chop) followed by rising ER (release) = coiled-spring break setup. Answers a question no other component answers — what was the market doing in the bars leading up to this break?

4. Volume vs 20-bar SMA
Confirms participation at the break. A break with above-average volume is structurally different from a break on dead volume.

5. Session VWAP gradient
Standard session-anchored VWAP, plus the slope of VWAP normalised to ATR units. A pivot break aligned with a strongly trending VWAP is occurring within an established VWAP-axis trend; one against it is counter-trend.

6. Adaptive trailing stop, multi-timeframe composite bias
An adaptive trailing stop whose ATR length is dynamically set using Kaufman's Efficiency Ratio (the same adaptation mechanism used in KAMA). The stop is computed on chart, 3×, 5×, and 15× timeframes; each contributes a weighted ±1 to a composite directional score in the range −10 to +10. One number summarises whether four timeframes agree.

7. Chandelier-style trailing stop, multi-timeframe convergence
A second, independent multi-timeframe trend check. Standard Chandelier stops on chart / 3× / 5× / 15× are computed; the standard deviation of those four stop prices is measured and normalised to ATR. Low dispersion = all timeframes agree. The adaptive composite (#6) and the Chandelier convergence (#7) cross-check the same question via two different mechanisms.

8. Higher-timeframe pivot structure (HH+HL / LH+LL on 3×, 5×, 15×)
Direct HTF market-structure read using ta.pivothigh / ta.pivotlow on the HTF series. Independent of any moving-average / stop / VWAP framework — purely pivot-sequence based.

9. Chart-timeframe pivot structure
The same pivot-sequence test on the chart timeframe itself, using its own configurable pivot length, independent of the trendline engine.

10. Confluence-based support/resistance zone engine
A zone builder that combines volume profile (POC, VAH, VAL), high-activity bars (top-percentile volume and range), native swing pivots, and multi-HTF pivots into clustered, scored zones. Available as a visual layer and as an optional filter gate.

────────────────────────────────────
HOW THEY COMPOSE INTO ONE NUMBER
────────────────────────────────────

Break Strength = Break Quality (0–7) + (5 − Trend Context) (0–5)
Range: 0–12

Break Quality (0–7) is the sum of seven independent properties of the break event itself:

| # | Component | What it measures |
|---|---|---|
| 1 | ER compression-then-release | Coiled-spring pre-break setup |
| 2 | Break magnitude ≥ N × ATR | Decisiveness of the break |
| 3 | Volume ≥ N × 20-bar SMA | Participation at the break |
| 4 | ≥ N bars since prior same-dir pivot | Trendline duration / base length |
| 5 | Pivot height ≥ N × ATR | Quality of the trendline being broken |
| 6 | Range expansion (TR > N×ATR, ATR rising) | Range-based expansion at break |
| 7 | Anti-Wick check | Close in favourable 30% of bar |

Trend Context (0–5) measures whether the broader trend is already established:

| # | Component | What it measures |
|---|---|---|
| 1 | Recent same-dir Slow tier signal | Slowest tier already confirmed direction |
| 2 | Adaptive Trail aligned | Multi-TF adaptive-stop framework agrees |
| 3 | VWAP gradient strongly aligned | Session VWAP slope agrees |
| 4 | Chandelier stop convergence high | All TFs agree on trend state |
| 5 | Chart-TF HH+HL aligned | Chart pivot sequence agrees |

Why Trend Context is INVERTED:
When the broader trend is already firmly established, the break is occurring late in the move and receives a lower bonus. When the context is mixed or transitioning, the bonus is higher. The thesis: quality breaks occur AT structural inflection points, not after them. If you prefer with-trend breakouts to count fully, disable Trend Context in inputs (the composite then becomes Break Quality alone, range 0–7).

────────────────────────────────────
HOW TO USE IT (PRACTICAL WORKFLOW)
────────────────────────────────────

1. Apply to any chart and timeframe.
All defaults are sensible.

2. Read the on-bar arrow labels:
Tier length + direction + Break Strength score. The Status Panel summarises the most recent break.

3. Start with default filters:
VWAP Gradient Filter ON, Adaptive / HTF / LTF / Volume / Confluence gates OFF. Add gates one at a time to suit your trading style.

4. Higher score = stronger structural break,
read alongside the score-band guide above. Do not treat any score as a buy/sell signal on its own.

5. For lower timeframes,
consider the multi-instance stacking technique described above (8/21/34, 21/34/55, 34/89/144) to add higher-TF context without leaving your execution chart.

6. Use the Confluence S/R zones (if enabled)
to see where breaks line up with major confluence levels. Breaks at strong zones behave differently from breaks in empty space.

────────────────────────────────────
FILTER GATE QUICK REFERENCE
────────────────────────────────────

| Gate | When to enable |
|---|---|
| VWAP Gradient Filter | Default ON. Suppresses breaks against a strongly trending session VWAP. |
| Adaptive Trail Bias Gate | Enable if you want to see only breaks aligned with multi-TF directional consensus. |
| HTF Anchor (HH+HL / LH+LL) | Enable to require recent pivot sequence confirmation. |
| LTF Pivot Break | Enable to require the close to clear the opposing pivot. |
| Volume Surge | Enable to require top-percentile volume on the break bar. |
| Confluence Zone Gate | Enable to require the break to occur near a strong S/R zone. |

Each filter, when enabled, suppresses arrow labels for breaks that do not meet that criterion. Filters compose multiplicatively — turning on three filters at once will significantly reduce the number of breaks displayed.

────────────────────────────────────
WHAT IS ORIGINAL ABOUT THIS INDICATOR
────────────────────────────────────

• The inverted-context composite score — Break Quality summed with (5 − Trend Context) — is the novel contribution. Most multi-component scorers reward aligned context as a bonus; this one penalises it on the explicit thesis that early breaks score higher than late breaks.

• The seven Break Quality components are designed to be independent — no component overlaps with another on the same surface, and none measures established trend (that is the job of the inverted Trend Context score).

• Three pivot tiers run in parallel with independent state machines, rather than the more common single-tier approach.

• Two independent multi-timeframe trend reads (adaptive-stop composite + Chandelier convergence) cross-check rather than relying on a single MTF mechanism.

• The confluence S/R engine combines volume profile, percentile-and-consensus-based high-activity bar detection, native pivots, and up to three HTF pivot streams into a single 0–10 zone-strength score.

────────────────────────────────────
TECHNICAL NOTES
────────────────────────────────────

• Pine Script v6
• Non-repainting: structural break events confirm at bar close
• No lookahead: barmerge.lookahead_off on all request.security calls
• HTF reads are one-way: chart-TF computations never depend on HTF state in a way that would change historical bars
• Max line / label / box counts set high to handle dense trendline tiers
• Compatible with TradingView's House Rules and Pine publishing standards

────────────────────────────────────
IMPORTANT RISK DISCLOSURE
────────────────────────────────────

This indicator is provided for educational and informational purposes only. It is not financial advice, investment advice, a trading system, or a recommendation to buy, sell, or hold any financial instrument.

Trading and investing involve substantial risk of loss, including the possible loss of all invested capital. The structural break events highlighted by this indicator are observations of market behaviour, not predictions of future price movement. The Break Strength score is a descriptive summary of structural properties, not an indication of profitability, win rate, expected return, or risk-adjusted performance.

No backtested or hypothetical performance is claimed or implied by any element of this indicator or its description. Past structural break events identified by the indicator are not indicative of future results. The arrows, scores, and zones are analytical annotations, not trade signals.

You are solely responsible for any trading decisions you make. Always conduct your own research, use appropriate risk management, size positions according to your own risk tolerance, and consider consulting a licensed financial advisor before making investment decisions. Do not trade with money you cannot afford to lose.

By using this indicator you acknowledge that the author bears no responsibility for any losses, missed gains, or other consequences arising from its use.

## Source Code

````pine
// © 2026 Trendline Break Detector — All Rights Reserved
//
// ═══════════════════════════════════════════════════════════════════════════════
//   TRENDLINE BREAK DETECTOR [TBD]
//   Multi-Tier Pivot Structure Analysis with Break Strength Scoring
// ═══════════════════════════════════════════════════════════════════════════════
//
// OVERVIEW
// ────────────────────────────────────────────────────────────────────────────────
// Trendline Break Detector is an analytical indicator that identifies and rates
// pivot structure breaks in real time across three independent pivot tiers
// (Fast / Medium / Slow, default lengths 8 / 21 / 34, user-configurable).
// For each detected break,
// the indicator computes a "Break Strength" score (0–12) that summarises the
// quality of the break and the broader trend context around it.
//
// This is a STRUCTURAL ANALYSIS TOOL. It marks where trendline structures are
// breaking and how cleanly those breaks are forming. It does not place orders,
// suggest entries or exits, target prices, stop levels, or position sizes. The
// arrows displayed on the chart are descriptive structural annotations — they
// help you locate inflection points, not direct your trading.
//
// WHAT THE INDICATOR DRAWS
// ────────────────────────────────────────────────────────────────────────────────
//   • Pivot points and the swing trendlines they form, across three tiers
//   • Small direction-arrow labels at the bar where a pivot break occurs:
//        - Tier label (the pivot length, e.g. "21")
//        - Direction arrow (▲ for upward breaks, ▼ for downward breaks)
//        - Break Strength score (·N where N is 0–12)
//   • A compact Status Panel summarising the most recent break event and the
//     current state of trend-context indicators (VWAP, ER, HTF)
//
// HOW THE BREAK STRENGTH SCORE WORKS (0–12)
// ────────────────────────────────────────────────────────────────────────────────
// The Break Strength score is the sum of two independent components:
//
//   BREAK QUALITY (0–7) — properties of the structural break event itself:
//     • Pre-break compression then release (coiled-spring formation)
//     • Break magnitude relative to ATR (decisiveness)
//     • Volume vs recent average (participation)
//     • Bars elapsed since the last same-direction break (trendline duration)
//     • Pivot height relative to ATR (structural significance)
//     • Range expansion at the break
//     • Close position within bar range (anti-wick rejection check)
//
//   TREND CONTEXT (0–5, applied INVERSELY) — context the break occurs WITHIN:
//     • Recent slow-tier break in same direction
//     • Adaptive trailing stop bias alignment (multi-timeframe composite)
//     • VWAP gradient alignment
//     • Multi-timeframe Chandelier-stop convergence
//     • Chart-timeframe pivot sequence agreement (HH+HL / LH+LL)
//
//   The Trend Context contribution is INVERTED in the composite: when the
//   broader trend is already firmly established, the break is occurring later
//   in the move and receives a lower bonus. When the context is mixed or
//   transitioning, the bonus is higher. The reasoning is that quality breaks
//   tend to occur AT structural inflection points, not after them.
//
// HOW TO USE
// ────────────────────────────────────────────────────────────────────────────────
//   1. Apply the indicator to any chart and timeframe.
//   2. Optional context filters are available in the inputs (VWAP, Wicks, HTF
//      Anchor, LTF Break, Volume Surge, Adaptive Trail, Confluence S/R). Each
//      filter, when enabled, suppresses arrow labels for breaks that do not
//      meet that structural criterion. Start with defaults and adjust to taste.
//   3. The Status Panel shows: active tiers, the last detected break (tier,
//      direction, age in bars, Break Strength), current trend context, and
//      how many filters are active.
//   4. Use the arrows and scores as a context layer alongside your own analytical
//      framework. Higher scores indicate breaks with stronger structural
//      properties, but do not constitute trade recommendations.
//
// IMPORTANT RISK DISCLOSURE
// ────────────────────────────────────────────────────────────────────────────────
// This indicator is provided for EDUCATIONAL AND INFORMATIONAL PURPOSES ONLY.
// It is NOT financial advice, investment advice, a trading system, or a
// recommendation to buy, sell, or hold any financial instrument.
//
// Trading and investing involve substantial risk of loss. The structural break
// events highlighted by this indicator are observations of market behaviour,
// not predictions of future price movement. The Break Strength score is a
// descriptive summary of structural properties, not an indication of
// profitability.
//
// You are solely responsible for any trading decisions you make. Always conduct
// your own research, use appropriate risk management, and consider consulting a
// licensed financial advisor. Do not trade with money you cannot afford to lose.
//
// TECHNICAL NOTES
// ────────────────────────────────────────────────────────────────────────────────
//   • Pine Script v6
//   • Non-repainting: structural break events confirm at bar close
//   • No lookahead: all historical state is computed in-context
//   • Multi-timeframe data accessed via request.security with
//     barmerge.lookahead_off
//   • Compatible with TradingView's House Rules and Pine publishing standards
//
// ═══════════════════════════════════════════════════════════════════════════════

//@version=6
indicator('Trendline Break Detector [TBD]', shorttitle='TBD',
     max_lines_count=500, max_labels_count=500, max_boxes_count=500, max_bars_back=5000, overlay=true)


//---------------------------------------------------------------------------------------------------------------------
// TF detection
//---------------------------------------------------------------------------------------------------------------------
tfSec = timeframe.in_seconds(timeframe.period)
tfMin = tfSec / 60
isIntradayBand = tfMin <= 15

//---------------------------------------------------------------------------------------------------------------------
// Pivot lengths — user-configurable per tier
// Defaults follow the Fibonacci sequence (8 / 21 / 34) which gives a natural
// fast / medium / slow timescale separation. Adjust if you prefer different
// pivot lengths for your trading style or timeframe.
//---------------------------------------------------------------------------------------------------------------------
GRP_PIV = 'Pivot Lengths'
swing_fast   = input.int(8,  'Fast tier pivot length',   minval=2, maxval=100, group=GRP_PIV,
     tooltip='Length used by the Fast tier for pivot detection. Default 8 (Fibonacci). Lower = more sensitive to micro-structure; higher = fewer, more significant breaks.')
swing_medium = input.int(21, 'Medium tier pivot length', minval=2, maxval=200, group=GRP_PIV,
     tooltip='Length used by the Medium tier for pivot detection. Default 21 (Fibonacci). The Medium tier is the canonical reference used for on-bar score display.')
swing_slow   = input.int(34, 'Slow tier pivot length',   minval=2, maxval=300, group=GRP_PIV,
     tooltip='Length used by the Slow tier for pivot detection. Default 34 (Fibonacci). Slow tier breaks represent the largest structural events.')

// Internal pivot lengths used for ancillary pivot-array tracking (not user-facing).
// Kept as constants because they don't drive any displayed signal — they're
// reserved for finer- and coarser-grained context the engine may use internally.
swing_finest  = 3
swing_slowest = 55

//---------------------------------------------------------------------------------------------------------------------
// Display options — Wick / Body source for pivot detection
//---------------------------------------------------------------------------------------------------------------------
GRP_TL    = 'Trendlines'
wickMode  = input.string('Auto (ON for 15m/30m, OFF elsewhere)', 'Wick / Body Mode',
     options=['Auto (ON for 15m/30m, OFF elsewhere)', 'Force Wicks', 'Force Bodies'],
     group=GRP_TL,
     tooltip='Auto enables wicks on 15m and 30m charts and bodies elsewhere. Pivot detection on wick highs/lows behaves differently from body highs/lows; the default is chosen to suit intraday timeframes.')

// Resolve wick mode
autoWicksOn = (tfMin == 15) or (tfMin == 30)
useWicks    = wickMode == 'Force Wicks' ? true : wickMode == 'Force Bodies' ? false : autoWicksOn

showLines = input.bool(true, 'Show Trendlines', group=GRP_TL)

//---------------------------------------------------------------------------------------------------------------------
// Active Pivot Tiers — which tier(s) generate structural break detections
//---------------------------------------------------------------------------------------------------------------------
GRP_SETUP = 'Active Pivot Tiers'
setupMode = input.string('All three', 'Active Tiers',
     options=['Fast only',
              'Medium only',
              'Slow only',
              'Fast + Medium',
              'Medium + Slow',
              'All three'],
     group=GRP_SETUP,
     tooltip='Default: All three — Fast, Medium, and Slow tiers each detect pivot breaks independently using the pivot lengths configured in the Pivot Lengths group. The other options narrow detection to a specific subset of tier(s).')

resolvedSetup = setupMode

//---------------------------------------------------------------------------------------------------------------------
// Volatility reference — ATR length (used by Break Quality scoring and dashboard)
//---------------------------------------------------------------------------------------------------------------------
GRP_VOL = 'Volatility Reference'
atrLen = input.int(14, 'ATR Length', minval=2, group=GRP_VOL,
     tooltip='Length used for the ATR (Average True Range). ATR is referenced by Break Magnitude, Clean Pivot, Range Expansion, and Anti-Wick checks in the Break Quality score.')

//---------------------------------------------------------------------------------------------------------------------
// Settings — VWAP Gradient Filter
//---------------------------------------------------------------------------------------------------------------------
GRP_VWAP = 'VWAP Gradient Filter'
useVwapGrad  = input.bool(true, 'Enable VWAP Gradient Filter', group=GRP_VWAP,
     tooltip='When ON, breaks may be filtered by the slope of session VWAP normalised to ATR units. Disable to turn off VWAP filtering entirely.')
gradLookback = input.int(10, 'Gradient Lookback (bars)', minval=3, maxval=50, group=GRP_VWAP)
gradThresh   = input.float(0.05, 'Strength Threshold (ATR units)', minval=0, step=0.01, group=GRP_VWAP)
gradMode = input.string('Require strong aligned', 'Filter Mode',
     options=['Block opposite only', 'Require strong aligned', 'Off'],
     group=GRP_VWAP,
     tooltip='Block opposite only: blocks breaks against a strongly trending VWAP. Require strong aligned: requires VWAP slope to be strongly in the break direction. Off: disables the filter.')

//---------------------------------------------------------------------------------------------------------------------
// Settings — Adaptive Trailing Stop Bias Gate (multi-timeframe composite)
// Uses an Efficiency-Ratio-adaptive ATR length to drive a volatility trailing
// stop on chart / 3× / 5× / 15× timeframes; each contributes a weighted ±1 to
// a composite directional score (range −10 to +10).
//---------------------------------------------------------------------------------------------------------------------
GRP_AT = 'Adaptive Trail Bias Gate (MTF)'
useAdaptiveGate = input.bool(false, 'Enable Adaptive Trail Bias Gate', group=GRP_AT)
atMinScore = input.int(4, 'Min |Score| for Full Alignment', minval=1, maxval=10, group=GRP_AT)
atStrictMode = input.string('Auto (by timeframe)', 'Filter Mode',
     options=['Auto (by timeframe)', 'Strict (require aligned)', 'Loose (block opposite only)', 'Off'],
     group=GRP_AT)
atFastLen = input.int(8,  'Adaptive Fast ATR Bound',  minval=2, maxval=20,  group=GRP_AT)
atSlowLen = input.int(30, 'Adaptive Slow ATR Bound',  minval=10, maxval=100, group=GRP_AT)

autoAtMode = isIntradayBand ? 'Strict (require aligned)' : 'Loose (block opposite only)'
atMode = atStrictMode == 'Auto (by timeframe)' ? autoAtMode : atStrictMode

//---------------------------------------------------------------------------------------------------------------------
// Settings — Structural Gates
//---------------------------------------------------------------------------------------------------------------------
GRP_GATES = 'Structural Gates'
useHtfAnchor   = input.bool(false, 'Gate: HTF Anchor (HH+HL long / LH+LL short)', group=GRP_GATES)
useLtfBreak    = input.bool(false, 'Gate: LTF Pivot Break (close beyond opposing pivot)', group=GRP_GATES)
useVolumeGate  = input.bool(false, 'Gate: Volume Surge Confirmation', group=GRP_GATES)
volPctThreshold = input.float(75.0, 'Volume percentile threshold', minval=50.0, maxval=95.0, step=5.0, group=GRP_GATES)
volLookback     = input.int(50, 'Volume lookback (bars)', minval=10, maxval=200, group=GRP_GATES)
requireRisingVol = input.bool(false, 'Also require rising volume', group=GRP_GATES)

volPctile = useVolumeGate ? ta.percentile_linear_interpolation(volume, volLookback, volPctThreshold) : 0.0
volQualifies = useVolumeGate ? (volume >= volPctile and (not requireRisingVol or volume > volume[1])) : true

//---------------------------------------------------------------------------------------------------------------------
// Settings — Confluence Support/Resistance Engine
// Combines volume profile, high-activity bars, native swing pivots, and
// multi-HTF pivots into clustered, scored zones.
//---------------------------------------------------------------------------------------------------------------------
GRP_SR = 'Confluence S/R Engine'
useSrGate = input.bool(false, 'Enable Confluence Zone Gate', group=GRP_SR)
srMinZoneScore = input.float(6.0, 'Min Zone Score for Break Gate', minval=4.0, maxval=10.0, step=0.5, group=GRP_SR)
srMaxDistATR = input.float(1.5, 'Max Entry-to-Zone Distance (× ATR)', minval=0.5, step=0.1, group=GRP_SR)

GRP_SR_ANCHOR = 'High-Activity Bar Detection'
srDetectMode = input.string('Percentile + Consensus', 'Detection Mode',
     options=['Legacy (volume × avg)', 'Percentile + Consensus'], group=GRP_SR_ANCHOR)
volPctThresh   = input.float(90.0, 'Volume percentile', minval=50.0, maxval=99.0, step=1.0, group=GRP_SR_ANCHOR)
rangePctThresh = input.float(80.0, 'Range percentile',  minval=50.0, maxval=99.0, step=1.0, group=GRP_SR_ANCHOR)
maxAnchors     = input.int(3, 'Max active high-activity bars', minval=1, maxval=5, group=GRP_SR_ANCHOR)

GRP_SR_VP = 'Volume Profile'
useVP       = input.bool(true, 'Enable Volume Profile', group=GRP_SR_VP)
vpLevels    = input.int(25, 'Profile rows', minval=10, maxval=50, group=GRP_SR_VP)
vpValueArea = input.float(70.0, 'Value Area %', minval=50.0, maxval=90.0, step=1.0, group=GRP_SR_VP) / 100.0

GRP_SR_MTF = 'Multi-Timeframe Sources'
useHTF1     = input.bool(true,  'Use HTF 1',           group=GRP_SR_MTF, inline='htf1')
htf1Auto    = input.bool(true,  'Auto',                group=GRP_SR_MTF, inline='htf1')
htf1Manual  = input.timeframe('60',  '', group=GRP_SR_MTF, inline='htf1')
useHTF2     = input.bool(true,  'Use HTF 2',           group=GRP_SR_MTF, inline='htf2')
htf2Auto    = input.bool(true,  'Auto',                group=GRP_SR_MTF, inline='htf2')
htf2Manual  = input.timeframe('240', '', group=GRP_SR_MTF, inline='htf2')
useHTF3     = input.bool(false, 'Use HTF 3',           group=GRP_SR_MTF, inline='htf3')
htf3Auto    = input.bool(true,  'Auto',                group=GRP_SR_MTF, inline='htf3')
htf3Manual  = input.timeframe('D',   '', group=GRP_SR_MTF, inline='htf3')

GRP_SR_ZONE = 'Zone Display'
zoneWidthATR    = input.float(0.5, 'Zone width (× ATR)',         minval=0.1, step=0.1, group=GRP_SR_ZONE)
clusterATR      = input.float(0.7, 'Cluster merge dist (× ATR)', minval=0.1, step=0.1, group=GRP_SR_ZONE)
minStrengthShow = input.float(4.0, 'Min strength to display',    minval=0.0, maxval=10.0, step=0.5, group=GRP_SR_ZONE)
premiumLevel    = input.float(8.0, 'Premium-tier threshold',     minval=6.0, maxval=10.0, step=0.5, group=GRP_SR_ZONE)
maxZonesDisplay = input.int(8, 'Max zones shown', minval=3, maxval=15, group=GRP_SR_ZONE)
showSrZones     = input.bool(true, 'Show confluence zone boxes', group=GRP_SR_ZONE)
zoneExtend      = input.int(30, 'Zone right-extension (bars)', minval=10, group=GRP_SR_ZONE)

//---------------------------------------------------------------------------------------------------------------------
// Settings — Display & Stats
//---------------------------------------------------------------------------------------------------------------------
GRP_STYLE = 'Style'
cBull = input.color(#089981, 'Bull TL', inline='c', group=GRP_STYLE)
cBear = input.color(#f23645, 'Bear TL', inline='c', group=GRP_STYLE)

GRP_STAT = 'Status Panel'
showStats = input.bool(true, 'Show Status Panel', group=GRP_STAT)
tblPos = input.string('Top Right', 'Panel Position',
     options=['Top Left','Top Right','Middle Right','Bottom Left','Bottom Right'], group=GRP_STAT)
tblSize = input.string('Tiny', 'Size',
     options=['Tiny','Small','Normal','Large'], group=GRP_STAT,
     tooltip='Default Tiny for unobtrusive overlay. Increase if hard to read.')

GRP_CONV = 'Break Strength — Quality Components'
useStrengthTag = input.bool(true, 'Compute & Display Break Strength Score', group=GRP_CONV,
     tooltip='Master toggle for the Break Strength score. When ON, scores are computed and shown next to break arrows. When OFF, only direction arrows are shown.')
convHtfLookback = input.int(10, 'HTF Alignment Lookback (bars)', minval=3, maxval=50, group=GRP_CONV,
     tooltip='Look-back window for the recent-Slow-tier signal check in the Trend Context score. Smaller = stricter (only very recent signals count).')

// Break Quality Score — 7 independent properties of the break or trendline.
// Range 0-7. Each component measures a distinct property:
//   BQ-1. ER compression-then-release    → pre-break setup (coiled spring)
//   BQ-2. Break magnitude ≥ N×ATR        → decisiveness of the break itself
//   BQ-3. Volume ≥ N× recent average     → participation at the break
//   BQ-4. ≥ N bars since prior pivot     → trendline duration (base length)
//   BQ-5. Clean pivot ≥ N×ATR height     → quality of the trendline being broken
//   BQ-6. Range Expansion: TR > N×ATR    → range expansion at the break
//   BQ-7. Anti-Wick rejection            → break bar closes in favorable 30% of range

useConvErCompRel = input.bool(true, 'BQ-1: +1 if ER compression-then-release',
     group=GRP_CONV,
     tooltip='Sustained low ER (chop) followed by rising ER (release) = coiled-spring break. Measures the pre-break setup pattern.')
erShortLen = input.int(10, '  ER short lookback', minval=5, maxval=20, group=GRP_CONV)
erLongLen  = input.int(30, '  ER long lookback (compression window)', minval=15, maxval=50, group=GRP_CONV)
erCompThresh = input.float(0.30, '  ER "was low" threshold (≤)', step=0.05, minval=0.10, maxval=0.50, group=GRP_CONV)

useConvBreakMag = input.bool(true, 'BQ-2: +1 if break magnitude ≥ N×ATR',
     group=GRP_CONV,
     tooltip='Close cleared the broken pivot by at least N×ATR. Decisive breaks continue; marginal breaks fade.')
breakMagAtrMult = input.float(0.30, '  Break magnitude ATR multiplier', step=0.05, minval=0.10, maxval=1.00, group=GRP_CONV)

useConvVolConfirm = input.bool(true, 'BQ-3: +1 if volume ≥ N× recent average',
     group=GRP_CONV,
     tooltip='Volume on break bar vs 20-bar avg. Softer than Vol Surge gate (top-percentile binary). Measures participation at the break.')
volConfirmMult = input.float(1.30, '  Volume confirmation multiplier', step=0.05, minval=1.00, maxval=3.00, group=GRP_CONV)

useConvTimeSincePivot = input.bool(true, 'BQ-4: +1 if ≥ N bars since prior same-dir Med signal',
     group=GRP_CONV,
     tooltip='Long break with N+ bars since last long Med signal = break from a base, not chop. Approximates trendline duration.')
timeSincePivotMin = input.int(15, '  Min bars since prior same-direction Med signal', minval=3, maxval=100, group=GRP_CONV)

useConvCleanPivot = input.bool(true, 'BQ-5: +1 if broken pivot is clean (≥ N×ATR height)',
     group=GRP_CONV,
     tooltip='Pivot height vs ATR. Filters out marks on micro-noise pivots. Real trendline breaks require meaningful swing height.')
cleanPivotAtrMult = input.float(0.50, '  Min pivot height in ATR', step=0.05, minval=0.20, maxval=2.00, group=GRP_CONV)

useConvRangeExp = input.bool(true, 'BQ-6: +1 if TR > N×ATR & ATR rising (range expansion)',
     group=GRP_CONV,
     tooltip='True Range > N×ATR with ATR rising. Range-based expansion measure — complements BQ-3 (volume-based).')
rangeExpMultConv = input.float(1.50, '  Range Expansion TR/ATR multiplier', step=0.10, minval=1.00, maxval=3.00, group=GRP_CONV)

useConvAntiWick = input.bool(true, 'BQ-7: +1 if break bar closes in favorable 30% of range',
     group=GRP_CONV,
     tooltip='Anti-rejection check. Long break: close in top 30% of bar (no upper wick rejection). Short break: close in bottom 30%. Long wicks indicate intrabar rejection of the break — weak break that may fade.')
antiWickThresh = input.float(0.70, '  Close position threshold (0-1)', step=0.05, minval=0.50, maxval=0.95, group=GRP_CONV,
     tooltip='How far into the favorable side of the bar the close must be. 0.70 = top 30% for long, bottom 30% for short. Higher = stricter.')

// ════════════════════════════════════════════════════════════════════════════
// Trend Context Score — 5 inputs, range 0-5.
// Independent axis from Break Quality. Each input measures whether the broader
// trend is ALREADY established. In the Composite score, Trend Context
// contributes INVERSELY:
//   Composite Base = Break Quality + (5 − Trend Context)
// → Breaks where trend is NOT yet established score higher (early-phase bonus).
// → Breaks where trend is fully established score lower (late-phase penalty).
//
// The 5 inputs are designed to be independent of the 7 Break Quality inputs
// (no overlap on the same surface).
// ════════════════════════════════════════════════════════════════════════════
GRP_TC = 'Break Strength — Trend Context (Inverted)'
useTcScore = input.bool(true, 'Compute Trend Context component', group=GRP_TC,
     tooltip='When ON, Trend Context is computed and (5 − TC) is added to Break Quality for the Composite Break Strength score. When OFF, Composite = Break Quality only (range 0-7).')

useTcSlowSignal = input.bool(true, 'TC-1: +1 if recent same-dir Slow tier signal',
     group=GRP_TC,
     tooltip='The slowest tier just confirmed a same-direction break within the lookback window. Indicates trend established on longest timeframe.')
tcSlowLookback = input.int(10, '  Slow signal lookback (bars)', minval=3, maxval=50, group=GRP_TC)

useTcAdaptive = input.bool(true, 'TC-2: +1 if Adaptive Trail bias aligned with direction',
     group=GRP_TC,
     tooltip='Adaptive trailing stop composite score is positive for long / negative for short. Indicates multi-TF positioning agrees with direction.')

useTcVwapGrad = input.bool(true, 'TC-3: +1 if VWAP gradient strongly aligned',
     group=GRP_TC,
     tooltip='Session VWAP slope is strongly up for long / strongly down for short. Indicates VWAP-axis trend already established.')

useTcStopConv = input.bool(true, 'TC-4: +1 if multi-TF Chandelier stop convergence high',
     group=GRP_TC,
     tooltip='Chandelier-style trailing stops on chart/3×/5×/15× are tightly clustered. High convergence = TFs all agree.')
tcStopConvThresh = input.float(0.60, '  Stop convergence threshold (0-1)', step=0.05, minval=0.30, maxval=0.95, group=GRP_TC,
     tooltip='1.0 = stops in perfect agreement. 0.60 = moderate convergence.')

useTcChartStruct = input.bool(true, 'TC-5: +1 if chart-TF HH+HL structure aligned',
     group=GRP_TC,
     tooltip='Chart-TF pivot structure shows HH+HL for long (LH+LL for short). Indicates established structural trend on the trading TF.')
tcChartSwingLen = input.int(10, '  Chart-TF pivot length for HH+HL check', minval=3, maxval=30, group=GRP_TC)

GRP_HTF = 'HTF Alignment Scoring'
useHtfWeight = input.bool(true, 'Enable HTF Alignment Scoring', group=GRP_HTF)
htf3xWeight = input.int(2, '3× HTF Weight (+/-)', minval=0, maxval=5, group=GRP_HTF)
htf5xWeight = input.int(2, '5× HTF Weight (+/-)', minval=0, maxval=5, group=GRP_HTF)
htf15xWeight = input.int(2, '15× HTF Weight (+/-)', minval=0, maxval=5, group=GRP_HTF)
htfSwingLen = input.int(20, 'HTF Pivot Length', minval=5, maxval=50, group=GRP_HTF)

//---------------------------------------------------------------------------------------------------------------------
// Common globals
//---------------------------------------------------------------------------------------------------------------------
n = bar_index
INV = color(na)
atrVal = ta.atr(atrLen)
volAvg = ta.sma(volume, 20)

phSrc = useWicks ? high : (close > open ? close : open)
plSrc = useWicks ? low  : (close > open ? open  : close)

//---------------------------------------------------------------------------------------------------------------------
// VWAP Gradient Filter
//---------------------------------------------------------------------------------------------------------------------
vwapVal = ta.vwap(hlc3)
vwapGrad = (vwapVal - vwapVal[gradLookback]) / gradLookback
vwapGradNorm = atrVal > 0 ? vwapGrad / atrVal : 0.0
vwapStrongUp = vwapGradNorm > gradThresh
vwapStrongDown = vwapGradNorm < -gradThresh

allowVwapLong() =>
    if not useVwapGrad
        true
    else
        switch gradMode
            'Block opposite only'    => not vwapStrongDown
            'Require strong aligned' => vwapStrongUp
            'Off'                    => true
            =>                          true

allowVwapShort() =>
    if not useVwapGrad
        true
    else
        switch gradMode
            'Block opposite only'    => not vwapStrongUp
            'Require strong aligned' => vwapStrongDown
            'Off'                    => true
            =>                          true

//---------------------------------------------------------------------------------------------------------------------
// Adaptive Trailing Stop — multi-timeframe directional composite
// Uses Kaufman's Efficiency Ratio (ER) to drive an adaptive ATR length,
// which in turn drives a volatility trailing stop. The stop's directional
// state (+1 / -1) is read on chart, 3×, 5×, and 15× timeframes; each
// contributes a weighted vote to a composite score in range -10..+10.
//---------------------------------------------------------------------------------------------------------------------
f_rma(float src, float length) =>
    a = 1.0 / math.max(length, 1.0)
    var float r = na
    r := na(r[1]) ? src : r[1] + a * (src - r[1])
    r

adaptive_direction(float src, int f_len, int s_len) =>
    erLen = 30
    netMove = math.abs(src - src[erLen])
    pathSum = math.sum(math.abs(src - src[1]), erLen)
    erRaw = pathSum != 0.0 ? netMove / pathSum : 0.0
    erSm = ta.ema(erRaw, 5)
    fa = 2.0 / (f_len + 1)
    sa = 2.0 / (s_len + 1)
    kamaAlpha = math.pow(erSm * (fa - sa) + sa, 2)
    lenMin = math.max(2, f_len - 2)
    lenMax = s_len + 10
    effLen = math.max(float(lenMin), math.min(float(lenMax), 1.0 / math.max(kamaAlpha, 1e-10)))
    mult = 1.6 + (2.6 - 1.6) * (1.0 - erSm)
    trVal = ta.tr(true)
    atrDyn = f_rma(trVal, effLen)
    atrDist = mult * atrDyn
    var float vstop = na
    var bool uptrend = true
    if uptrend
        vstop := math.max(nz(vstop, src - atrDist), src - atrDist)
    else
        vstop := math.min(nz(vstop, src + atrDist), src + atrDist)
    if uptrend and src < vstop
        uptrend := false
        vstop := src + atrDist
    else if not uptrend and src > vstop
        uptrend := true
        vstop := src - atrDist
    uptrend ? 1 : -1

get_tf_str(float tfMins) =>
    tfMins < 2 ? '1' : tfMins < 3 ? '2' : tfMins < 5 ? '3' : tfMins < 10 ? '5' : tfMins < 15 ? '10' : tfMins < 30 ? '15' : tfMins < 45 ? '30' : tfMins < 60 ? '45' : tfMins < 120 ? '60' : tfMins < 180 ? '120' : tfMins < 240 ? '180' : tfMins < 360 ? '240' : tfMins < 720 ? '360' : tfMins < 1440 ? '720' : tfMins < 4320 ? '1D' : tfMins < 10080 ? '3D' : tfMins < 43200 ? '1W' : '1M'

tf3xStr  = get_tf_str(tfSec * 3.0 / 60.0)
tf5xStr  = get_tf_str(tfSec * 5.0 / 60.0)
tf15xStr = get_tf_str(tfSec * 15.0 / 60.0)

htf1Auto3xStr  = tf3xStr
htf2Auto5xStr  = tf5xStr
htf3Auto15xStr = tf15xStr
htf1 = htf1Auto ? htf1Auto3xStr  : htf1Manual
htf2 = htf2Auto ? htf2Auto5xStr  : htf2Manual
htf3 = htf3Auto ? htf3Auto15xStr : htf3Manual

atDir1 = adaptive_direction(close, atFastLen, atSlowLen)
atDir2 = request.security(syminfo.tickerid, tf3xStr,  adaptive_direction(close, atFastLen, atSlowLen), lookahead=barmerge.lookahead_off)
atDir3 = request.security(syminfo.tickerid, tf5xStr,  adaptive_direction(close, atFastLen, atSlowLen), lookahead=barmerge.lookahead_off)
atDir4 = request.security(syminfo.tickerid, tf15xStr, adaptive_direction(close, atFastLen, atSlowLen), lookahead=barmerge.lookahead_off)

atScore = atDir1 + (atDir2 * 2) + (atDir3 * 3) + (atDir4 * 4)
atStrongTrend = math.abs(atScore) >= 8
atTrending = math.abs(atScore) >= atMinScore
atChoppy = math.abs(atScore) <= 2

atRegimeText = atStrongTrend and atScore > 0 ? 'STRONG ▲' : atStrongTrend and atScore < 0 ? 'STRONG ▼' : atTrending and atScore > 0 ? 'BULL' : atTrending and atScore < 0 ? 'BEAR' : atChoppy ? 'CHOPPY' : 'TRANSIT'

allowAdaptiveLong() =>
    if not useAdaptiveGate
        true
    else
        switch atMode
            'Strict (require aligned)'    => atScore >= atMinScore
            'Loose (block opposite only)' => atScore > -atMinScore
            'Off'                          => true
            =>                                true

allowAdaptiveShort() =>
    if not useAdaptiveGate
        true
    else
        switch atMode
            'Strict (require aligned)'    => atScore <= -atMinScore
            'Loose (block opposite only)' => atScore < atMinScore
            'Off'                          => true
            =>                                true

//---------------------------------------------------------------------------------------------------------------------
// HTF Trend Detection — pivot-sequence based (HH+HL / LH+LL)
//---------------------------------------------------------------------------------------------------------------------
htf_trend_state(int swingLen) =>
    ph = ta.pivothigh(high, swingLen, swingLen)
    pl = ta.pivotlow(low, swingLen, swingLen)
    var float lastPh = na
    var float prevPh = na
    var float lastPl = na
    var float prevPl = na
    if not na(ph)
        prevPh := lastPh
        lastPh := ph
    if not na(pl)
        prevPl := lastPl
        lastPl := pl
    int dir = 0
    if not na(lastPh) and not na(prevPh) and not na(lastPl) and not na(prevPl)
        bool hh = lastPh > prevPh
        bool hl = lastPl > prevPl
        bool lh = lastPh < prevPh
        bool ll = lastPl < prevPl
        if hh and hl
            dir := 1
        else if lh and ll
            dir := -1
        else
            dir := 0
    dir

htf3xDir  = useHtfWeight ? request.security(syminfo.tickerid, tf3xStr,  htf_trend_state(htfSwingLen), lookahead=barmerge.lookahead_off) : 0
htf5xDir  = useHtfWeight ? request.security(syminfo.tickerid, tf5xStr,  htf_trend_state(htfSwingLen), lookahead=barmerge.lookahead_off) : 0
htf15xDir = useHtfWeight ? request.security(syminfo.tickerid, tf15xStr, htf_trend_state(htfSwingLen), lookahead=barmerge.lookahead_off) : 0

//---------------------------------------------------------------------------------------------------------------------
// Break Quality — state computations
// Each measures a property of the BREAK or the TRENDLINE BEING BROKEN.
// All computed on every bar at chart TF, no future data.
//---------------------------------------------------------------------------------------------------------------------

// ─── BQ-1: ER compression-then-release ──────────────────────────────
// Kaufman Efficiency Ratio. ER was LOW (chop) → now RISING (release).
// Coiled-spring break setup: trendline held during quiet, ruptures at expansion.
erNetMoveShort_bq = math.abs(close - close[erShortLen])
erPathShort_bq    = math.sum(math.abs(close - close[1]), erShortLen)
erShort_bq        = erPathShort_bq > 0 ? erNetMoveShort_bq / erPathShort_bq : 0.0

erNetMoveLong_bq  = math.abs(close - close[erLongLen])
erPathLong_bq     = math.sum(math.abs(close - close[1]), erLongLen)
erLong_bq         = erPathLong_bq > 0 ? erNetMoveLong_bq / erPathLong_bq : 0.0

// "Was low" — ER N bars ago (during compression) was below threshold
erWasLow_bq       = erLong_bq[5] <= erCompThresh
// "Now rising" — short-window ER is higher than 3 bars ago
erNowRising_bq    = erShort_bq > erShort_bq[3]
erCompRelease_bq  = erWasLow_bq and erNowRising_bq

// ─── BQ-2: Break magnitude ─────────────────────────────────────────────
// Computed inside computeBQ() with the broken pivot price as parameter.

// ─── BQ-3: Volume confirmation ────────────────────────────────────────
// Softer than Vol Surge gate (top-percentile binary) — measures participation.
volAvg20_bq        = ta.sma(volume, 20)
volConfirmFires_bq = not na(volume) and volAvg20_bq > 0 and volume >= volConfirmMult * volAvg20_bq

// ─── BQ-4: Time since prior same-direction Med signal ─────────────────
// Computed inside computeBQ() using lastMedLongBar[1] / lastMedShortBar[1].

// ─── BQ-5: Clean pivot height ─────────────────────────────────────────
// Computed inside computeBQ() with broken pivot + swing reference.

// ─── BQ-6: Range Expansion at break ───────────────────────────────────
// TR > N×ATR with ATR rising. Range-based expansion measure.
rxTR_bq            = ta.tr(true)
rxATR_bq           = ta.atr(14)
rangeExp_bq        = rxTR_bq > rangeExpMultConv * rxATR_bq and rxATR_bq > rxATR_bq[1]

// ─── BQ-7: Anti-Wick rejection ────────────────────────────────────────
// Direction-dependent — computed inside computeBQ() with isLong.
// Long break: close should be in top (1 - antiWickThresh) of bar range
// Short break: close should be in bottom (1 - antiWickThresh) of bar range
// Long upper wick on long break = intrabar rejection = no point.
barRangeForWick_bq = high - low
closePosLong_bq    = barRangeForWick_bq > 0 ? (close - low) / barRangeForWick_bq : 0.5
closePosShort_bq   = barRangeForWick_bq > 0 ? (high - close) / barRangeForWick_bq : 0.5

//---------------------------------------------------------------------------------------------------------------------
// Trend Context — state computations
// 5 inputs, each measuring whether the broader trend is already established.
//---------------------------------------------------------------------------------------------------------------------

// ─── TC-1: Recent Slow tier signal ────────────────────────────────────
// Uses existing lastSlowLongBar / lastSlowShortBar (from engine block).

// ─── TC-2: Adaptive Trail aligned ─────────────────────────────────────
// Uses existing atScore.

// ─── TC-3: VWAP gradient strongly aligned ─────────────────────────────
// Uses existing vwapStrongUp / vwapStrongDown.

// ─── TC-4: Multi-TF Chandelier stop convergence ───────────────────────
chandStop_tc(int len, float mult) =>
    atrLocal = ta.atr(len)
    longStop  = ta.highest(high, len) - atrLocal * mult
    shortStop = ta.lowest(low, len)   + atrLocal * mult
    var int dir = 1
    var float stopLev = na
    if na(stopLev)
        stopLev := longStop
    if dir == 1
        if close < stopLev
            dir := -1
            stopLev := shortStop
        else
            stopLev := math.max(stopLev, longStop)
    else
        if close > stopLev
            dir := 1
            stopLev := longStop
        else
            stopLev := math.min(stopLev, shortStop)
    stopLev

stopChart_tc = chandStop_tc(20, 2.0)
stop3x_tc  = request.security(syminfo.tickerid, tf3xStr,  chandStop_tc(20, 2.0), lookahead=barmerge.lookahead_off)
stop5x_tc  = request.security(syminfo.tickerid, tf5xStr,  chandStop_tc(20, 2.0), lookahead=barmerge.lookahead_off)
stop15x_tc = request.security(syminfo.tickerid, tf15xStr, chandStop_tc(20, 2.0), lookahead=barmerge.lookahead_off)

stopMean_tc = (stopChart_tc + stop3x_tc + stop5x_tc + stop15x_tc) / 4.0
stopVar_tc  = (math.pow(stopChart_tc - stopMean_tc, 2) +
                math.pow(stop3x_tc    - stopMean_tc, 2) +
                math.pow(stop5x_tc    - stopMean_tc, 2) +
                math.pow(stop15x_tc   - stopMean_tc, 2)) / 4.0
stopStd_tc  = math.sqrt(stopVar_tc)
refAtr_tc   = math.max(atrVal, 1e-10)
stopConvergence_tc = math.max(0.0, 1.0 - stopStd_tc / refAtr_tc)
stopConvHigh_tc    = stopConvergence_tc >= tcStopConvThresh

// ─── TC-5: Chart-TF HH+HL structure ──────────────────────────────────
chartStructDir_tc = htf_trend_state(tcChartSwingLen)

//---------------------------------------------------------------------------------------------------------------------
// Confluence S/R Engine — High-Activity Bar Detection
//---------------------------------------------------------------------------------------------------------------------
shortWin = 20
midWin = 50
longWin = 100

vPctShort = ta.percentile_linear_interpolation(volume, shortWin, volPctThresh)
vPctMid = ta.percentile_linear_interpolation(volume, midWin, volPctThresh)
vPctLong = ta.percentile_linear_interpolation(volume, longWin, volPctThresh)
barRange = high - low
rPctShort = ta.percentile_linear_interpolation(barRange, shortWin, rangePctThresh)
rPctMid = ta.percentile_linear_interpolation(barRange, midWin, rangePctThresh)
rPctLong = ta.percentile_linear_interpolation(barRange, longWin, rangePctThresh)

volWindowHits = (volume >= vPctShort ? 1 : 0) + (volume >= vPctMid ? 1 : 0) + (volume >= vPctLong ? 1 : 0)
rangeWindowHits = (barRange >= rPctShort ? 1 : 0) + (barRange >= rPctMid ? 1 : 0) + (barRange >= rPctLong ? 1 : 0)

isHighActLegacy = volume >= 2.5 * volAvg and barRange >= 1.5 * atrVal
isHighActModern = volWindowHits >= 2 and rangeWindowHits >= 2
isHighActBar = srDetectMode == 'Legacy (volume × avg)' ? isHighActLegacy : isHighActModern

var array<int>   anchorBars = array.new<int>()
var array<float> anchorHigh = array.new<float>()
var array<float> anchorLow  = array.new<float>()

if isHighActBar and barstate.isconfirmed
    array.unshift(anchorBars, bar_index)
    array.unshift(anchorHigh, high)
    array.unshift(anchorLow, low)
    if array.size(anchorBars) > maxAnchors
        array.pop(anchorBars)
        array.pop(anchorHigh)
        array.pop(anchorLow)

//---------------------------------------------------------------------------------------------------------------------
// Confluence S/R — Volume Profile from latest high-activity bar
//---------------------------------------------------------------------------------------------------------------------
var float pocPrice = na
var float vahPrice = na
var float valPrice = na
var bool vpBuilt = false

if useVP and barstate.islast and array.size(anchorBars) > 0
    int ab = array.get(anchorBars, 0)
    int profileLen = bar_index - ab
    if profileLen > 2 and profileLen < 4900
        float profHigh = high[profileLen]
        float profLow = low[profileLen]
        for k = 0 to profileLen - 1
            profHigh := math.max(profHigh, high[k])
            profLow := math.min(profLow, low[k])
        float priceStep = (profHigh - profLow) / vpLevels
        if priceStep > 0
            array<float> volBuckets = array.new<float>(vpLevels, 0.0)
            for k = 0 to profileLen - 1
                float bH = high[k]
                float bL = low[k]
                float bV = nz(volume[k])
                float bR = bH - bL
                int lvl = 0
                float lvlPrice = profLow
                while lvl < vpLevels and lvlPrice < profHigh
                    if bH >= lvlPrice and bL < lvlPrice + priceStep
                        float contrib = bR == 0 ? bV : bV * priceStep / bR
                        array.set(volBuckets, lvl, array.get(volBuckets, lvl) + contrib)
                    lvl += 1
                    lvlPrice += priceStep
            int pocLvl = array.indexof(volBuckets, array.max(volBuckets))
            pocPrice := profLow + (pocLvl + 0.5) * priceStep
            float totalVA = array.sum(volBuckets) * vpValueArea
            float vaSum = array.get(volBuckets, pocLvl)
            int upperLvl = pocLvl
            int lowerLvl = pocLvl
            while vaSum < totalVA
                if upperLvl >= vpLevels - 1 and lowerLvl <= 0
                    break
                float volAbove = upperLvl < vpLevels - 1 ? array.get(volBuckets, upperLvl + 1) : 0.0
                float volBelow = lowerLvl > 0 ? array.get(volBuckets, lowerLvl - 1) : 0.0
                if volAbove == 0 and volBelow == 0
                    break
                if volAbove >= volBelow
                    vaSum += volAbove
                    upperLvl += 1
                else
                    vaSum += volBelow
                    lowerLvl -= 1
            vahPrice := profLow + (upperLvl + 1) * priceStep
            valPrice := profLow + lowerLvl * priceStep
            vpBuilt := true

//---------------------------------------------------------------------------------------------------------------------
// Confluence S/R — HTF pivots
//---------------------------------------------------------------------------------------------------------------------
f_htfPivotHigh(string tf) => request.security(syminfo.tickerid, tf, ta.pivothigh(high, 5, 5), lookahead=barmerge.lookahead_off)
f_htfPivotLow(string tf)  => request.security(syminfo.tickerid, tf, ta.pivotlow(low, 5, 5), lookahead=barmerge.lookahead_off)

h1ph_raw = f_htfPivotHigh(htf1)
h1pl_raw = f_htfPivotLow(htf1)
h2ph_raw = f_htfPivotHigh(htf2)
h2pl_raw = f_htfPivotLow(htf2)
h3ph_raw = f_htfPivotHigh(htf3)
h3pl_raw = f_htfPivotLow(htf3)

h1ph = useHTF1 ? h1ph_raw : na
h1pl = useHTF1 ? h1pl_raw : na
h2ph = useHTF2 ? h2ph_raw : na
h2pl = useHTF2 ? h2pl_raw : na
h3ph = useHTF3 ? h3ph_raw : na
h3pl = useHTF3 ? h3pl_raw : na

var float h1ph_last = na
var float h1pl_last = na
var float h2ph_last = na
var float h2pl_last = na
var float h3ph_last = na
var float h3pl_last = na

if not na(h1ph)
    h1ph_last := h1ph
if not na(h1pl)
    h1pl_last := h1pl
if not na(h2ph)
    h2ph_last := h2ph
if not na(h2pl)
    h2pl_last := h2pl
if not na(h3ph)
    h3ph_last := h3ph
if not na(h3pl)
    h3pl_last := h3pl

//---------------------------------------------------------------------------------------------------------------------
// Confluence S/R — Native swing pivots
//---------------------------------------------------------------------------------------------------------------------
srPivotLen = 10
srPh = ta.pivothigh(high, srPivotLen, srPivotLen)
srPl = ta.pivotlow(low, srPivotLen, srPivotLen)

var array<float> srSwingHighs = array.new<float>()
var array<float> srSwingLows = array.new<float>()
if not na(srPh)
    array.unshift(srSwingHighs, srPh)
    if array.size(srSwingHighs) > 10
        array.pop(srSwingHighs)
if not na(srPl)
    array.unshift(srSwingLows, srPl)
    if array.size(srSwingLows) > 10
        array.pop(srSwingLows)

//---------------------------------------------------------------------------------------------------------------------
// Confluence S/R — Zone state
//---------------------------------------------------------------------------------------------------------------------
var float srTopZonePrice = na
var float srTopZoneScore = na
var bool srTopZoneIsSupport = true

var float srNearestSupportPx = na
var float srNearestSupportSc = na
var float srNearestResistancePx = na
var float srNearestResistanceSc = na

var array<box> srZoneBoxes = array.new<box>()
var array<label> srZoneLabels = array.new<label>()

if barstate.islast
    if array.size(srZoneBoxes) > 0
        for i = 0 to array.size(srZoneBoxes) - 1
            box.delete(array.get(srZoneBoxes, i))
    array.clear(srZoneBoxes)
    if array.size(srZoneLabels) > 0
        for i = 0 to array.size(srZoneLabels) - 1
            label.delete(array.get(srZoneLabels, i))
    array.clear(srZoneLabels)

    srTopZonePrice := na
    srTopZoneScore := na
    srTopZoneIsSupport := true
    srNearestSupportPx := na
    srNearestSupportSc := na
    srNearestResistancePx := na
    srNearestResistanceSc := na

    array<float> mPrices = array.new<float>()
    array<float> mWeights = array.new<float>()
    array<int> mTiers = array.new<int>()

    if useVP and vpBuilt
        array.push(mPrices, pocPrice)
        array.push(mWeights, 2.5)
        array.push(mTiers, 5)
    if array.size(anchorHigh) > 0
        array.push(mPrices, array.get(anchorHigh, 0))
        array.push(mWeights, 2.5)
        array.push(mTiers, 5)
        array.push(mPrices, array.get(anchorLow, 0))
        array.push(mWeights, 2.5)
        array.push(mTiers, 5)

    if useVP and vpBuilt
        array.push(mPrices, vahPrice)
        array.push(mWeights, 2.0)
        array.push(mTiers, 4)
        array.push(mPrices, valPrice)
        array.push(mWeights, 2.0)
        array.push(mTiers, 4)
    if array.size(srSwingHighs) > 0
        array.push(mPrices, array.get(srSwingHighs, 0))
        array.push(mWeights, 2.0)
        array.push(mTiers, 4)
    if array.size(srSwingLows) > 0
        array.push(mPrices, array.get(srSwingLows, 0))
        array.push(mWeights, 2.0)
        array.push(mTiers, 4)

    if useHTF1 and not na(h1ph_last)
        array.push(mPrices, h1ph_last)
        array.push(mWeights, 1.5)
        array.push(mTiers, 3)
    if useHTF1 and not na(h1pl_last)
        array.push(mPrices, h1pl_last)
        array.push(mWeights, 1.5)
        array.push(mTiers, 3)
    if useHTF2 and not na(h2ph_last)
        array.push(mPrices, h2ph_last)
        array.push(mWeights, 2.25)
        array.push(mTiers, 3)
    if useHTF2 and not na(h2pl_last)
        array.push(mPrices, h2pl_last)
        array.push(mWeights, 2.25)
        array.push(mTiers, 3)
    if useHTF3 and not na(h3ph_last)
        array.push(mPrices, h3ph_last)
        array.push(mWeights, 3.0)
        array.push(mTiers, 3)
    if useHTF3 and not na(h3pl_last)
        array.push(mPrices, h3pl_last)
        array.push(mWeights, 3.0)
        array.push(mTiers, 3)

    if array.size(srSwingHighs) > 1
        array.push(mPrices, array.get(srSwingHighs, 1))
        array.push(mWeights, 1.0)
        array.push(mTiers, 2)
    if array.size(srSwingLows) > 1
        array.push(mPrices, array.get(srSwingLows, 1))
        array.push(mWeights, 1.0)
        array.push(mTiers, 2)

    int nM = array.size(mPrices)
    if nM > 1
        for i = 1 to nM - 1
            float kp = array.get(mPrices, i)
            float kw = array.get(mWeights, i)
            int kt = array.get(mTiers, i)
            int j = i - 1
            while j >= 0 and array.get(mPrices, j) > kp
                array.set(mPrices, j + 1, array.get(mPrices, j))
                array.set(mWeights, j + 1, array.get(mWeights, j))
                array.set(mTiers, j + 1, array.get(mTiers, j))
                j -= 1
            array.set(mPrices, j + 1, kp)
            array.set(mWeights, j + 1, kw)
            array.set(mTiers, j + 1, kt)

    float mergeDist = clusterATR * atrVal
    float halfWidth = (zoneWidthATR * atrVal) / 2.0

    array<float> clCenters = array.new<float>()
    array<float> clWeights = array.new<float>()
    array<int>   clCounts  = array.new<int>()
    array<int>   clMaxTier = array.new<int>()
    array<float> clMins    = array.new<float>()
    array<float> clMaxs    = array.new<float>()

    if nM > 0
        float curC = array.get(mPrices, 0)
        float curW = array.get(mWeights, 0)
        int curN = 1
        int curT = array.get(mTiers, 0)
        float curMin = curC
        float curMax = curC
        float curSum = curC * curW
        float curWSum = curW
        if nM > 1
            for i = 1 to nM - 1
                float p = array.get(mPrices, i)
                float w = array.get(mWeights, i)
                int t = array.get(mTiers, i)
                if math.abs(p - curC) <= mergeDist
                    curSum += p * w
                    curWSum += w
                    curW += w
                    curN += 1
                    curMin := math.min(curMin, p)
                    curMax := math.max(curMax, p)
                    curC := curSum / curWSum
                    curT := math.max(curT, t)
                else
                    array.push(clCenters, curC)
                    array.push(clWeights, curW)
                    array.push(clCounts, curN)
                    array.push(clMaxTier, curT)
                    array.push(clMins, curMin)
                    array.push(clMaxs, curMax)
                    curC := p
                    curW := w
                    curN := 1
                    curT := t
                    curMin := p
                    curMax := p
                    curSum := p * w
                    curWSum := w
        array.push(clCenters, curC)
        array.push(clWeights, curW)
        array.push(clCounts, curN)
        array.push(clMaxTier, curT)
        array.push(clMins, curMin)
        array.push(clMaxs, curMax)

    array<float> clScores = array.new<float>()
    int nC = array.size(clCenters)
    if nC > 0
        for ci = 0 to nC - 1
            int tierMax = array.get(clMaxTier, ci)
            float lvlScore = tierMax == 5 ? 3.0 : tierMax == 4 ? 2.25 : tierMax == 3 ? 1.5 : tierMax == 2 ? 0.75 : 0.25
            int cnt = array.get(clCounts, ci)
            float divScore = cnt >= 5 ? 2.5 : cnt == 4 ? 2.0 : cnt == 3 ? 1.5 : cnt == 2 ? 1.0 : 0.5
            float tfScore = 1.5
            float recScore = 1.0
            float zMin = array.get(clMins, ci)
            float zMax = array.get(clMaxs, ci)
            float wAtr = atrVal > 0 ? (zMax - zMin) / atrVal : 0.0
            float tightScore = wAtr <= 0.0 ? 1.0 : wAtr <= 0.15 ? 0.85 : wAtr <= 0.30 ? 0.5 : wAtr <= 0.50 ? 0.25 : 0.0
            float compositeScore = lvlScore + divScore + tfScore + recScore + tightScore
            array.push(clScores, math.min(10.0, compositeScore))

    if nC > 1
        for i = 1 to nC - 1
            float ks = array.get(clScores, i)
            float kC = array.get(clCenters, i)
            float kW = array.get(clWeights, i)
            int kN = array.get(clCounts, i)
            int kMT = array.get(clMaxTier, i)
            float kMin = array.get(clMins, i)
            float kMax = array.get(clMaxs, i)
            int j = i - 1
            while j >= 0 and array.get(clScores, j) < ks
                array.set(clScores, j + 1, array.get(clScores, j))
                array.set(clCenters, j + 1, array.get(clCenters, j))
                array.set(clWeights, j + 1, array.get(clWeights, j))
                array.set(clCounts, j + 1, array.get(clCounts, j))
                array.set(clMaxTier, j + 1, array.get(clMaxTier, j))
                array.set(clMins, j + 1, array.get(clMins, j))
                array.set(clMaxs, j + 1, array.get(clMaxs, j))
                j -= 1
            array.set(clScores, j + 1, ks)
            array.set(clCenters, j + 1, kC)
            array.set(clWeights, j + 1, kW)
            array.set(clCounts, j + 1, kN)
            array.set(clMaxTier, j + 1, kMT)
            array.set(clMins, j + 1, kMin)
            array.set(clMaxs, j + 1, kMax)

    int renderCount = math.min(array.size(clCenters), maxZonesDisplay)
    if renderCount > 0
        for i = 0 to renderCount - 1
            float center = array.get(clCenters, i)
            float score = array.get(clScores, i)
            int cnt = array.get(clCounts, i)
            float zMin = array.get(clMins, i)
            float zMax = array.get(clMaxs, i)

            if score >= minStrengthShow
                float upper = math.max(zMax, center + halfWidth)
                float lower = math.min(zMin, center - halfWidth)
                bool isSupport = center < close
                bool isPremium = score >= premiumLevel

                color baseCol = isSupport ? (isPremium ? color.new(#b4ff64, 60) : color.new(#089981, 70)) : (isPremium ? color.new(#ffb43c, 60) : color.new(#f23645, 70))
                color borderCol = color.new(baseCol, 30)

                if showSrZones
                    box bx = box.new(bar_index, upper, bar_index + zoneExtend, lower,
                         border_color=borderCol,
                         border_width=score >= 7 ? 2 : 1,
                         bgcolor=baseCol)
                    array.push(srZoneBoxes, bx)
                    string lblTxt = (isSupport ? '▲ S ' : '▼ R ') + str.tostring(score, '#.#')
                    if isPremium
                        lblTxt := '★ ' + lblTxt
                    label lb = label.new(bar_index + zoneExtend, (upper + lower) / 2, lblTxt,
                         style=label.style_label_left,
                         color=color.new(baseCol, 15),
                         textcolor=color.white,
                         size=size.small)
                    array.push(srZoneLabels, lb)

                if i == 0
                    srTopZonePrice := center
                    srTopZoneScore := score
                    srTopZoneIsSupport := isSupport

                if isSupport and center <= close
                    if na(srNearestSupportPx) or center > srNearestSupportPx
                        srNearestSupportPx := center
                        srNearestSupportSc := score
                if not isSupport and center >= close
                    if na(srNearestResistancePx) or center < srNearestResistancePx
                        srNearestResistancePx := center
                        srNearestResistanceSc := score

//---------------------------------------------------------------------------------------------------------------------
// Confluence S/R Gate functions
//---------------------------------------------------------------------------------------------------------------------
allowSrLong() =>
    if not useSrGate
        true
    else if na(srNearestSupportPx) or na(srNearestSupportSc)
        false
    else if srNearestSupportSc < srMinZoneScore
        false
    else if atrVal <= 0
        true
    else
        float distAtr = math.abs(close - srNearestSupportPx) / atrVal
        distAtr <= srMaxDistATR

allowSrShort() =>
    if not useSrGate
        true
    else if na(srNearestResistancePx) or na(srNearestResistanceSc)
        false
    else if srNearestResistanceSc < srMinZoneScore
        false
    else if atrVal <= 0
        true
    else
        float distAtr = math.abs(srNearestResistancePx - close) / atrVal
        distAtr <= srMaxDistATR

allowLong()  => allowVwapLong()  and allowAdaptiveLong()
allowShort() => allowVwapShort() and allowAdaptiveShort()

// ─────────────────────────────────────────────────────────────────────────────────────────────────
// Pivot arrays
// ─────────────────────────────────────────────────────────────────────────────────────────────────
var array<float> pivFinestH_p  = array.new<float>(0)
var array<float> pivFinestL_p  = array.new<float>(0)
var array<float> pivFastH_p    = array.new<float>(0)
var array<float> pivFastL_p    = array.new<float>(0)
var array<float> pivMediumH_p  = array.new<float>(0)
var array<float> pivMediumL_p  = array.new<float>(0)
var array<float> pivSlowH_p    = array.new<float>(0)
var array<float> pivSlowL_p    = array.new<float>(0)
var array<float> pivSlowestH_p = array.new<float>(0)
var array<float> pivSlowestL_p = array.new<float>(0)

// ─────────────────────────────────────────────────────────────────────────────────────────────────
// Structural Gate Functions
// ─────────────────────────────────────────────────────────────────────────────────────────────────
htfAnchorPass(array<float> highArr, array<float> lowArr, bool isLong) =>
    bool ok = false
    if array.size(highArr) >= 2 and array.size(lowArr) >= 2
        float lastPh = array.get(highArr, 0)
        float prevPh = array.get(highArr, 1)
        float lastPl = array.get(lowArr, 0)
        float prevPl = array.get(lowArr, 1)
        if isLong
            ok := lastPh > prevPh and lastPl > prevPl
        else
            ok := lastPh < prevPh and lastPl < prevPl
    ok

ltfBreakPass(array<float> highArr, array<float> lowArr, bool isLong) =>
    bool ok = false
    if isLong and array.size(highArr) >= 1
        ok := close > array.get(highArr, 0)
    else if not isLong and array.size(lowArr) >= 1
        ok := close < array.get(lowArr, 0)
    ok

passStructuralGatesTier(int tier, bool isLong) =>
    array<float> hi = tier == 0 ? pivFastH_p : tier == 1 ? pivMediumH_p : pivSlowH_p
    array<float> lo = tier == 0 ? pivFastL_p : tier == 1 ? pivMediumL_p : pivSlowL_p
    bool htfOk = not useHtfAnchor or htfAnchorPass(hi, lo, isLong)
    bool ltfOk = not useLtfBreak  or ltfBreakPass(hi, lo, isLong)
    bool volOk = not useVolumeGate or volQualifies
    htfOk and ltfOk and volOk

//---------------------------------------------------------------------------------------------------------------------
// Trendline Engine Types
//---------------------------------------------------------------------------------------------------------------------
type bin
    line lin
    float slope
    bool active
    chart.point cp

type engine
    int trend
    chart.point prevPh
    chart.point prevPl
    bin bn
    bool sigLong
    bool sigShort

newEngine() =>
    engine.new(0,
         chart.point.from_index(na, na),
         chart.point.from_index(na, na),
         bin.new(line(na), 0.0, false, chart.point.from_index(na, na)),
         false, false)

//---------------------------------------------------------------------------------------------------------------------
// Engine state (one engine per pivot tier)
//---------------------------------------------------------------------------------------------------------------------
var engine engFinest  = newEngine()
var engine engFast    = newEngine()
var engine engMedium  = newEngine()
var engine engSlow    = newEngine()
var engine engSlowest = newEngine()

//---------------------------------------------------------------------------------------------------------------------
// Trendline Engine — pivot-based trendline construction and break detection
//---------------------------------------------------------------------------------------------------------------------
processEngine(engine e, int swingLen, color colBull, color colBear,
              string lineStyle, int lineWidth, bool drawLines) =>

    ph_ = ta.pivothigh(phSrc, swingLen, swingLen)
    pl_ = ta.pivotlow(plSrc, swingLen, swingLen)
    cH = ta.change(fixnan(ph_))
    cL = ta.change(fixnan(pl_))
    chH = cH != 0 and cL == 0
    chL = cL != 0 and cH == 0

    e.sigLong := false
    e.sigShort := false

    if e.bn.active
        if e.bn.lin.get_x2() - e.bn.lin.get_x1() > 5000
            e.bn.active := false
            e.bn.lin.delete()
        else
            e.bn.lin.set_xy2(n, e.bn.lin.get_y2() + e.bn.slope)

    if chH
        v = ph_
        idx = swingLen
        x = n - idx
        c = close[idx]
        if e.trend < 1
            if v > nz(e.prevPh.price, -1e10) and x - nz(e.prevPh.index, 0) > 5 and n - nz(e.prevPl.index, n) < 5000
                e.trend := 1
                newLn = drawLines ?
                     line.new(e.prevPl.index, e.prevPl.price, n, e.prevPl.price,
                          color=colBull, style=lineStyle, width=lineWidth) :
                     line.new(na, na, na, na)
                e.bn := bin.new(newLn, 0.0, true,
                     chart.point.from_index(e.prevPl.index, e.prevPl.price))
            else
                if e.bn.active
                    slope = (v - e.bn.cp.price) / (x - e.bn.cp.index)
                    if v < e.bn.lin.get_y1() + slope and (v > e.bn.lin.get_y2() + slope or e.bn.slope == 0)
                        priceLin = e.bn.lin.get_price(n - idx)
                        if c < priceLin
                            e.bn.lin.set_xy2(n, v + slope * idx)
                            if e.bn.slope == 0
                                stop = false
                                while not stop
                                    arr = array.new<float>()
                                    for i = 0 to math.min(n - e.bn.lin.get_x1(), 500)
                                        arr.push(close[i] - e.bn.lin.get_price(n - i))
                                    hi = arr.max()
                                    if hi > 0
                                        ix = arr.indexof(hi)
                                        x1 = n - ix
                                        y1 = high[ix]
                                        e.bn.cp.index := x1
                                        e.bn.cp.price := y1
                                        slope := (v - y1) / (x - x1)
                                        e.bn.lin.set_xy2(n, v + slope * idx)
                                        e.bn.lin.set_xy1(x1, y1)
                                        e.bn.slope := slope
                                    else
                                        e.bn.lin.set_xy2(n, v + slope * idx)
                                        e.bn.slope := slope
                                        stop := true
                            else
                                e.bn.slope := slope
                        else
                            e.bn.active := false
                            if e.trend < 1
                                e.sigLong := true
        e.prevPh.index := x
        e.prevPh.price := v
    else
        if e.trend < 1 and e.bn.active
            if close > e.bn.lin.get_y2()
                e.bn.active := false
                e.sigLong := true

    if chL
        v = pl_
        idx = swingLen
        x = n - idx
        c = close[idx]
        if e.trend > -1
            if v < nz(e.prevPl.price, 1e10) and x - nz(e.prevPl.index, 0) > 5 and n - nz(e.prevPh.index, n) < 5000
                e.trend := -1
                newLn = drawLines ?
                     line.new(e.prevPh.index, e.prevPh.price, n, e.prevPh.price,
                          color=colBear, style=lineStyle, width=lineWidth) :
                     line.new(na, na, na, na)
                e.bn := bin.new(newLn, 0.0, true,
                     chart.point.from_index(e.prevPh.index, e.prevPh.price))
            else
                if e.bn.active
                    slope = (v - e.bn.cp.price) / (x - e.bn.cp.index)
                    if v > e.bn.lin.get_y1() + slope and (v < e.bn.lin.get_y2() + slope or e.bn.slope == 0)
                        priceLin = e.bn.lin.get_price(n - idx)
                        if c > priceLin
                            e.bn.lin.set_xy2(n, v + slope * idx)
                            if e.bn.slope == 0
                                stop = false
                                while not stop
                                    arr = array.new<float>()
                                    for i = 0 to math.min(n - e.bn.lin.get_x1(), 500)
                                        arr.push(e.bn.lin.get_price(n - i) - close[i])
                                    dp = arr.max()
                                    if dp > 0
                                        ix = arr.indexof(dp)
                                        x1 = n - ix
                                        y1 = low[ix]
                                        e.bn.cp.index := x1
                                        e.bn.cp.price := y1
                                        slope := (v - y1) / (x - x1)
                                        e.bn.lin.set_xy2(n, v + slope * idx)
                                        e.bn.lin.set_xy1(x1, y1)
                                        e.bn.slope := slope
                                    else
                                        e.bn.lin.set_xy2(n, v + slope * idx)
                                        e.bn.slope := slope
                                        stop := true
                            else
                                e.bn.slope := slope
                        else
                            e.bn.active := false
                            if e.trend > -1
                                e.sigShort := true
        e.prevPl.index := x
        e.prevPl.price := v
    else
        if e.trend > -1 and e.bn.active
            if close < e.bn.lin.get_y2()
                e.bn.active := false
                e.sigShort := true

    e.trend

processEngine(engFinest,  swing_finest,  cBull, cBear, line.style_solid,  1, false)
processEngine(engFast,    swing_fast,    cBull, cBear, line.style_dotted, 2, showLines)
processEngine(engMedium,  swing_medium,  cBull, cBear, line.style_dashed, 2, showLines)
processEngine(engSlow,    swing_slow,    cBull, cBear, line.style_solid,  3, showLines)
processEngine(engSlowest, swing_slowest, cBull, cBear, line.style_solid,  1, false)

//---------------------------------------------------------------------------------------------------------------------
// Tier signal age trackers
//---------------------------------------------------------------------------------------------------------------------
var int lastMedLongBar  = -1
var int lastMedShortBar = -1
var int lastSlowLongBar  = -1
var int lastSlowShortBar = -1

if engMedium.sigLong
    lastMedLongBar := n
if engMedium.sigShort
    lastMedShortBar := n
if engSlow.sigLong
    lastSlowLongBar := n
if engSlow.sigShort
    lastSlowShortBar := n

//---------------------------------------------------------------------------------------------------------------------
// Pivot arrays — populate
//---------------------------------------------------------------------------------------------------------------------
maxStore = 50
pushPivot(array<float> arr, float val) =>
    if not na(val)
        array.unshift(arr, val)
        while array.size(arr) > maxStore
            array.pop(arr)

phFinest  = ta.pivothigh(phSrc, swing_finest,  swing_finest)
plFinest  = ta.pivotlow(plSrc,  swing_finest,  swing_finest)
phFast    = ta.pivothigh(phSrc, swing_fast,    swing_fast)
plFast    = ta.pivotlow(plSrc,  swing_fast,    swing_fast)
phMedium  = ta.pivothigh(phSrc, swing_medium,  swing_medium)
plMedium  = ta.pivotlow(plSrc,  swing_medium,  swing_medium)
phSlow    = ta.pivothigh(phSrc, swing_slow,    swing_slow)
plSlow    = ta.pivotlow(plSrc,  swing_slow,    swing_slow)
phSlowest = ta.pivothigh(phSrc, swing_slowest, swing_slowest)
plSlowest = ta.pivotlow(plSrc,  swing_slowest, swing_slowest)

pushPivot(pivFinestH_p,  phFinest)
pushPivot(pivFinestL_p,  plFinest)
pushPivot(pivFastH_p,    phFast)
pushPivot(pivFastL_p,    plFast)
pushPivot(pivMediumH_p,  phMedium)
pushPivot(pivMediumL_p,  plMedium)
pushPivot(pivSlowH_p,    phSlow)
pushPivot(pivSlowL_p,    plSlow)
pushPivot(pivSlowestH_p, phSlowest)
pushPivot(pivSlowestL_p, plSlowest)


//---------------------------------------------------------------------------------------------------------------------
// Break Strength Composite Scoring
//
// Two scores combined into one:
//   Break Quality (0-7)  : measures the break itself
//   Trend Context (0-5)  : measures established trend
//
// Composite = Break Quality + (5 − Trend Context)     range 0-12
//
// → Higher Composite = clean break AND trend not yet established
// → Lower  Composite = poor break AND/OR fully established trend
//
// The 7 Break Quality components (each measures a distinct property):
//   BQ-1. ER compression-then-release    → pre-break setup (coiled spring)
//   BQ-2. Break magnitude ≥ N×ATR        → decisiveness of the break itself
//   BQ-3. Volume ≥ N× recent average     → participation at the break
//   BQ-4. ≥ N bars since prior pivot     → trendline duration (base length)
//   BQ-5. Clean pivot ≥ N×ATR height     → quality of the trendline being broken
//   BQ-6. Range Expansion: TR > N×ATR    → range expansion at the break
//   BQ-7. Anti-Wick rejection            → break bar closes in favorable 30% of range
//
// The 5 Trend Context components (each measures a distinct axis):
//   TC-1. Recent same-dir Slow signal    → slowest tier just confirmed direction
//   TC-2. Adaptive Trail aligned         → multi-TF adaptive stop bias agrees
//   TC-3. VWAP gradient strongly aligned → session VWAP slope agrees
//   TC-4. Stop convergence high          → multi-TF Chandelier stops clustered
//   TC-5. Chart-TF HH+HL aligned         → chart pivot sequence agrees
//---------------------------------------------------------------------------------------------------------------------

// ─── Break Quality Score (0-7) ───────────────────────────────────────────
computeBQ(bool isLong, float brokenPivot, float swingReference) =>
    int score = 0

    if useStrengthTag
        // BQ-1: ER compression-then-release
        if useConvErCompRel and erCompRelease_bq
            score += 1

        // BQ-2: Break magnitude ≥ N×ATR
        if useConvBreakMag and not na(brokenPivot) and atrVal > 0
            float magATR = isLong ? (close - brokenPivot) / atrVal : (brokenPivot - close) / atrVal
            if magATR >= breakMagAtrMult
                score += 1

        // BQ-3: Volume confirmation
        if useConvVolConfirm and volConfirmFires_bq
            score += 1

        // BQ-4: Time since prior same-direction Med signal
        if useConvTimeSincePivot
            int priorPriorBar = isLong ? lastMedLongBar[1] : lastMedShortBar[1]
            if priorPriorBar >= 0 and (n - priorPriorBar) >= timeSincePivotMin
                score += 1
            else if priorPriorBar < 0
                // No prior same-direction Med signal at all — score as fresh
                score += 1

        // BQ-5: Clean pivot height ≥ N×ATR
        if useConvCleanPivot and not na(brokenPivot) and not na(swingReference) and atrVal > 0
            float pivotHeight = math.abs(brokenPivot - swingReference)
            if pivotHeight / atrVal >= cleanPivotAtrMult
                score += 1

        // BQ-6: Range Expansion at break
        if useConvRangeExp and rangeExp_bq
            bool moveAligned = isLong ? close > close[1] : close < close[1]
            if moveAligned
                score += 1

        // BQ-7: Anti-Wick rejection
        if useConvAntiWick
            float closePos = isLong ? closePosLong_bq : closePosShort_bq
            if closePos >= antiWickThresh
                score += 1
    math.max(0, math.min(7, score))

// ─── Trend Context Score (0-5) ────────────────────────────────────────────
computeTC(bool isLong) =>
    int score = 0

    if useTcScore
        // TC-1: Recent same-direction Slow tier signal
        if useTcSlowSignal
            int slowRefBar = isLong ? lastSlowLongBar : lastSlowShortBar
            if slowRefBar >= 0 and (n - slowRefBar) <= tcSlowLookback
                score += 1

        // TC-2: Adaptive Trail aligned with direction
        if useTcAdaptive
            bool atAligned = isLong ? atScore > 0 : atScore < 0
            if atAligned
                score += 1

        // TC-3: VWAP gradient strongly aligned
        if useTcVwapGrad
            if isLong and vwapStrongUp
                score += 1
            else if not isLong and vwapStrongDown
                score += 1

        // TC-4: Multi-TF Chandelier stop convergence high
        if useTcStopConv and stopConvHigh_tc
            score += 1

        // TC-5: Chart-TF HH+HL structure aligned
        if useTcChartStruct
            if isLong and chartStructDir_tc == 1
                score += 1
            else if not isLong and chartStructDir_tc == -1
                score += 1
    math.max(0, math.min(5, score))

// ─── Composite Break Strength: Break Quality + (5 − Trend Context), range 0-12 ───
// This is the score that gets passed to break events and displayed in the dashboard.
// The (5 − Trend Context) "anti-establishment bonus" rewards early breaks (trend
// not yet established) and penalizes late breaks (trend fully obvious).
//
// If useTcScore is OFF: Composite = Break Quality only (0-7 range), bonus is 0.
computeBreakStrength(bool isLong, float brokenPivot, float swingReference) =>
    int bq = computeBQ(isLong, brokenPivot, swingReference)
    int tc = computeTC(isLong)
    int antiTcBonus = useTcScore ? (5 - tc) : 0
    math.max(0, math.min(12, bq + antiTcBonus))

//---------------------------------------------------------------------------------------------------------------------
// Tier enablement — which pivot tiers are active for break detection.
// (No trade execution — this indicator displays structural breaks for analysis only.)
//---------------------------------------------------------------------------------------------------------------------
enableFast   = resolvedSetup == 'All three' or resolvedSetup == 'Fast only' or resolvedSetup == 'Fast + Medium'
enableMedium = resolvedSetup == 'All three' or resolvedSetup == 'Medium only' or resolvedSetup == 'Fast + Medium' or resolvedSetup == 'Medium + Slow'
enableSlow   = resolvedSetup == 'All three' or resolvedSetup == 'Slow only' or resolvedSetup == 'Medium + Slow'

//---------------------------------------------------------------------------------------------------------------------
// Signal markers — visual labels at structural break points
//
// When a pivot break event is detected on an active tier AND passes the user's
// optional filter gates, a small arrow label is drawn at the bar with:
//   • The tier's pivot length (e.g. "21" for Medium)
//   • Direction arrow (▲ up break or ▼ down break)
//   • The Break Strength score (·N) showing how cleanly the break formed
//
// These markers are DESCRIPTIVE annotations of market structure, not buy/sell
// recommendations. Use them in conjunction with your own trading framework.
//---------------------------------------------------------------------------------------------------------------------
fastLbl   = str.tostring(swing_fast)
mediumLbl = str.tostring(swing_medium)
slowLbl   = str.tostring(swing_slow)

// For on-bar display labels, use Med tier pivots as canonical reference for scoring
float bqDispPivotL = array.size(pivMediumH_p) > 0 ? array.get(pivMediumH_p, 0) : na
float bqDispSwingL = array.size(pivMediumL_p) > 0 ? array.get(pivMediumL_p, 0) : na
float bqDispPivotS = array.size(pivMediumL_p) > 0 ? array.get(pivMediumL_p, 0) : na
float bqDispSwingS = array.size(pivMediumH_p) > 0 ? array.get(pivMediumH_p, 0) : na
int strLongNow  = math.max(0, math.min(12, computeBreakStrength(true,  bqDispPivotL, bqDispSwingL)))
int strShortNow = math.max(0, math.min(12, computeBreakStrength(false, bqDispPivotS, bqDispSwingS)))
bool showSigStrength = useStrengthTag
string strL = showSigStrength ? '·' + str.tostring(strLongNow)  : ''
string strS = showSigStrength ? '·' + str.tostring(strShortNow) : ''

// Each label fires only when the tier's signal passes the user's selected filter gates.
// Visual design: colored backgrounds matching break direction (bull/bear),
// per-tier transparency hierarchy (Fast more subtle, Slow more prominent).

// Fast tier — smallest, most transparent (least visually dominant)
if enableFast and engFast.sigLong and passStructuralGatesTier(0, true)
    label.new(n, low, text=fastLbl + '▲' + strL,
         color=color.new(cBull, 45), style=label.style_label_up,
         textcolor=color.white, size=size.small, yloc=yloc.belowbar)
if enableFast and engFast.sigShort and passStructuralGatesTier(0, false)
    label.new(n, high, text=fastLbl + '▼' + strS,
         color=color.new(cBear, 45), style=label.style_label_down,
         textcolor=color.white, size=size.small, yloc=yloc.abovebar)

// Medium tier — small size, mid transparency (balanced emphasis)
if enableMedium and engMedium.sigLong and passStructuralGatesTier(1, true)
    label.new(n, low, text=mediumLbl + '▲' + strL,
         color=color.new(cBull, 20), style=label.style_label_up,
         textcolor=color.white, size=size.small, yloc=yloc.belowbar)
if enableMedium and engMedium.sigShort and passStructuralGatesTier(1, false)
    label.new(n, high, text=mediumLbl + '▼' + strS,
         color=color.new(cBear, 20), style=label.style_label_down,
         textcolor=color.white, size=size.small, yloc=yloc.abovebar)

// Slow tier — normal size, fully opaque (most prominent — biggest structural events)
if enableSlow and engSlow.sigLong and passStructuralGatesTier(2, true)
    label.new(n, low, text=slowLbl + '▲' + strL,
         color=color.new(cBull, 0), style=label.style_label_up,
         textcolor=color.white, size=size.normal, yloc=yloc.belowbar)
if enableSlow and engSlow.sigShort and passStructuralGatesTier(2, false)
    label.new(n, high, text=slowLbl + '▼' + strS,
         color=color.new(cBear, 0), style=label.style_label_down,
         textcolor=color.white, size=size.normal, yloc=yloc.abovebar)

//---------------------------------------------------------------------------------------------------------------------
// Status Panel — Informational Display Only
//
// A compact 5-row panel showing current chart state. Pure status display, no
// trade outcomes, no performance metrics. Just describes what the analytical
// engine is observing right now: which tiers are active, where the most recent
// structural break occurred, how the break was scored, what the broader
// context looks like, and which filters are confirming the structure.
//---------------------------------------------------------------------------------------------------------------------
posMap(string p) =>
    switch p
        'Top Left'     => position.top_left
        'Top Right'    => position.top_right
        'Middle Right' => position.middle_right
        'Middle Left'  => position.middle_left
        'Bottom Left'  => position.bottom_left
        'Bottom Right' => position.bottom_right
        =>                position.top_right

sizeMap(string s) =>
    switch s
        'Tiny'   => size.tiny
        'Small'  => size.small
        'Normal' => size.normal
        'Large'  => size.large
        =>          size.normal

// ─── Theme: Modern minimal palette ─────────────────────────────────────
bgPanel  = color.new(#0d1117, 8)
bgHead   = color.new(#1c2230, 0)
bgRow    = color.new(#13171f, 18)
bgAlt    = color.new(#171c26, 18)
txtMain  = color.new(#e6edf3, 0)
txtMuted = color.new(#7d8590, 0)
txtAccent= color.new(#79c0ff, 0)
txtUp    = #3fb950
txtDown  = #f85149
txtFlat  = color.new(#d29922, 0)

// ─── Persistent state for "last break" tracking ────────────────────────
var int    lastBreakBar    = na
var string lastBreakTier   = '—'
var string lastBreakDir    = '—'
var color  lastBreakColor  = txtMuted
var int    lastBreakScore  = 0
var string lastBreakRating = '—'

scoreRating(int s) =>
    s <= 3 ? 'VLow' : s <= 6 ? 'Low' : s <= 8 ? 'Mid' : 'High'
scoreColor(int s) =>
    s <= 3 ? txtDown : s <= 6 ? txtFlat : s <= 8 ? txtFlat : txtUp

// Capture the most recent structural break event for display.
if enableSlow and engSlow.sigLong and passStructuralGatesTier(2, true)
    lastBreakBar    := bar_index
    lastBreakTier   := 'Slow'
    lastBreakDir    := '▲'
    lastBreakColor  := txtUp
    lastBreakScore  := strLongNow
    lastBreakRating := scoreRating(strLongNow)
else if enableSlow and engSlow.sigShort and passStructuralGatesTier(2, false)
    lastBreakBar    := bar_index
    lastBreakTier   := 'Slow'
    lastBreakDir    := '▼'
    lastBreakColor  := txtDown
    lastBreakScore  := strShortNow
    lastBreakRating := scoreRating(strShortNow)
else if enableMedium and engMedium.sigLong and passStructuralGatesTier(1, true)
    lastBreakBar    := bar_index
    lastBreakTier   := 'Med'
    lastBreakDir    := '▲'
    lastBreakColor  := txtUp
    lastBreakScore  := strLongNow
    lastBreakRating := scoreRating(strLongNow)
else if enableMedium and engMedium.sigShort and passStructuralGatesTier(1, false)
    lastBreakBar    := bar_index
    lastBreakTier   := 'Med'
    lastBreakDir    := '▼'
    lastBreakColor  := txtDown
    lastBreakScore  := strShortNow
    lastBreakRating := scoreRating(strShortNow)
else if enableFast and engFast.sigLong and passStructuralGatesTier(0, true)
    lastBreakBar    := bar_index
    lastBreakTier   := 'Fast'
    lastBreakDir    := '▲'
    lastBreakColor  := txtUp
    lastBreakScore  := strLongNow
    lastBreakRating := scoreRating(strLongNow)
else if enableFast and engFast.sigShort and passStructuralGatesTier(0, false)
    lastBreakBar    := bar_index
    lastBreakTier   := 'Fast'
    lastBreakDir    := '▼'
    lastBreakColor  := txtDown
    lastBreakScore  := strShortNow
    lastBreakRating := scoreRating(strShortNow)

// ─── Render status panel on last bar only ──────────────────────────────
var table panel = na

if showStats and barstate.islast
    if not na(panel)
        table.delete(panel)
    panel := table.new(posMap(tblPos), 2, 7, bgcolor=bgPanel, border_width=0, frame_width=0)
    sz = sizeMap(tblSize)

    // Active tier summary
    string tierSummary = (enableFast?'F':'') + (enableMedium?(enableFast?' M':'M'):'') + (enableSlow?((enableFast or enableMedium)?' S':'S'):'')

    // Last break age in bars
    int barsAgo = na(lastBreakBar) ? na : bar_index - lastBreakBar
    string breakAgeStr = na(barsAgo) ? 'none' : barsAgo == 0 ? 'now' : str.tostring(barsAgo) + 'b'

    // Trend context — VWAP gradient state
    string vwapStateStr = not useVwapGrad ? 'VWAPoff' : vwapStrongUp ? 'VWAP▲' : vwapStrongDown ? 'VWAP▼' : 'VWAP→'
    color  vwapStateCol = not useVwapGrad ? txtMuted : vwapStrongUp ? txtUp : vwapStrongDown ? txtDown : txtFlat

    // ER state — compact
    string erStr = 'ER' + str.tostring(erShort_bq, '#.##')

    // HTF alignment quick read
    string htfStr = htf5xDir == 1 ? 'HTF▲' : htf5xDir == -1 ? 'HTF▼' : 'HTF→'

    string contextStr = vwapStateStr + ' ' + erStr + ' ' + htfStr

    // Active filter count (informational)
    int filtersOn = (useVwapGrad ? 1 : 0) + (useWicks ? 1 : 0) + (useAdaptiveGate ? 1 : 0) + (useHtfAnchor ? 1 : 0) + (useLtfBreak ? 1 : 0) + (useVolumeGate ? 1 : 0) + (useSrGate ? 1 : 0)
    string filterStr = str.tostring(filtersOn) + '/7'

    // ─── Row 0: Title ───
    table.cell(panel, 0, 0, '◆ Break Detector', bgcolor=bgHead, text_color=txtAccent, text_size=sz, text_halign=text.align_left)
    table.cell(panel, 1, 0, timeframe.period, bgcolor=bgHead, text_color=txtMuted, text_size=sz, text_halign=text.align_right)

    // ─── Row 1: Active tiers ───
    table.cell(panel, 0, 1, 'Tiers', bgcolor=bgRow, text_color=txtMuted, text_size=sz, text_halign=text.align_left)
    table.cell(panel, 1, 1, tierSummary, bgcolor=bgRow, text_color=txtMain, text_size=sz, text_halign=text.align_right)

    // ─── Row 2: Most recent break ───
    table.cell(panel, 0, 2, 'Break', bgcolor=bgAlt, text_color=txtMuted, text_size=sz, text_halign=text.align_left)
    table.cell(panel, 1, 2, lastBreakTier + ' ' + lastBreakDir + ' (' + breakAgeStr + ')', bgcolor=bgAlt, text_color=lastBreakColor, text_size=sz, text_halign=text.align_right)

    // ─── Row 3: Score ───
    table.cell(panel, 0, 3, 'Score', bgcolor=bgRow, text_color=txtMuted, text_size=sz, text_halign=text.align_left)
    string strengthStr = na(lastBreakBar) ? '—' : str.tostring(lastBreakScore) + '/12 ' + lastBreakRating
    table.cell(panel, 1, 3, strengthStr, bgcolor=bgRow, text_color=na(lastBreakBar) ? txtMuted : scoreColor(lastBreakScore), text_size=sz, text_halign=text.align_right)

    // ─── Row 4: Trend context ───
    table.cell(panel, 0, 4, 'Context', bgcolor=bgAlt, text_color=txtMuted, text_size=sz, text_halign=text.align_left)
    table.cell(panel, 1, 4, contextStr, bgcolor=bgAlt, text_color=txtMain, text_size=sz, text_halign=text.align_right)

    // ─── Row 5: Filters ───
    table.cell(panel, 0, 5, 'Filters', bgcolor=bgRow, text_color=txtMuted, text_size=sz, text_halign=text.align_left)
    table.cell(panel, 1, 5, filterStr, bgcolor=bgRow, text_color=filtersOn >= 3 ? txtAccent : txtMain, text_size=sz, text_halign=text.align_right)

    // ─── Row 6: Footer ───
    table.cell(panel, 0, 6, 'BQ + Context⁻¹', bgcolor=bgHead, text_color=txtMuted, text_size=sz, text_halign=text.align_left)
    table.cell(panel, 1, 6, '0-12', bgcolor=bgHead, text_color=txtMuted, text_size=sz, text_halign=text.align_right)

// Alerts — Structural Break Events
//
// These alerts notify when a pivot structure on a given tier is broken in
// either direction. They are descriptive notifications about market structure,
// not trading instructions. Users should interpret them in the context of
// their own analysis and risk management framework.
//---------------------------------------------------------------------------------------------------------------------
alertcondition(enableFast   and engFast.sigLong,    title='Fast tier — Up break',     message='Trendline Break Detector: Fast tier pivot structure broken upward')
alertcondition(enableFast   and engFast.sigShort,   title='Fast tier — Down break',   message='Trendline Break Detector: Fast tier pivot structure broken downward')
alertcondition(enableMedium and engMedium.sigLong,  title='Medium tier — Up break',   message='Trendline Break Detector: Medium tier pivot structure broken upward')
alertcondition(enableMedium and engMedium.sigShort, title='Medium tier — Down break', message='Trendline Break Detector: Medium tier pivot structure broken downward')
alertcondition(enableSlow   and engSlow.sigLong,    title='Slow tier — Up break',     message='Trendline Break Detector: Slow tier pivot structure broken upward')
alertcondition(enableSlow   and engSlow.sigShort,   title='Slow tier — Down break',   message='Trendline Break Detector: Slow tier pivot structure broken downward')
````
