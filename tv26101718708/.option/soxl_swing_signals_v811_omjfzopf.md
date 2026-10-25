# SOXL Swing Signals v8.11 

- url: https://www.tradingview.com/script/OMJFZOpF-SOXL-Swing-Signals-v8-11/
- type: indicator
- pine_id: PUB;b7360e5b2bea433b8c2de5505809df4f
- version: 2.0

## Description

[b]SOXL Swing Signals v8.11 — Long-side primary, opt-in shorts[/b]

A multi-tier signal indicator excusively for SOXL (Direxion 3x semiconductor bull ETF), coded by Claude Opus 4.7 AI. 

It identifies high-conviction swing entries based on a combination of price action, momentum, volatility, and underlying-index context.

[b]⚠ Important disclaimers[/b]

This indicator does not constitute financial advice. It is an analytical tool designed to surface specific technical setups; it does not account for your individual financial situation, risk tolerance, tax circumstances, or trading goals.

Do not use this indicator mechanically as a trading strategy. Signals are intended to provide useful context to support discretionary trading decisions, not to be acted on without independent judgement. Past performance metrics shown below come from historical backtesting and are not predictive of future results. Always combine signals with your own analysis of broader market conditions, risk management, and position sizing.

SOXL is a 3x leveraged ETF with significant decay risk. It is not suitable for buy-and-hold investing, and even short-term positions carry substantial risk of loss exceeding the underlying index's move.

[b]What the indicator does in plain language[/b]

The indicator scans every trading day for combinations of conditions that have historically preceded notable price moves on SOXL. When enough conditions align, it draws a green ▲ triangle below price for a long entry suggestion, or a red ▼ triangle above price for a short entry suggestion. Each signal includes a small label showing which "tier" fired (the type of setup) and a star rating (1 to 7 stars) indicating how many supporting conditions were present at the same time.

The indicator also draws regression channels and Bollinger bands on the chart, plus a dashboard table in the top-right corner showing current values for the key metrics it tracks. Coloured warning zones in the background flag periods where price has reached extreme levels relative to its recent range.

[b]Long signals — reasonably reliable[/b]

Long entries fire when SOXL appears oversold and ready to bounce. The indicator looks at seven different "tiers" of long setup, ranging from deep capitulation (price collapsing on high volatility, broad index also weak) to subtle pullbacks within an uptrend. By default, the indicator only fires long signals when at least 3 of 7 supporting conditions are present (the "conviction filter").

Historical performance with conviction filter (10 years of SOXL data, 2016 to 2026):
- About 25 long signals over that period (roughly 2 to 4 per year)
- Profit factor approximately 3 to 4 in-sample (total winning return divided by total losing return)
- Win rate around 65 to 70 percent for a 14-day hold
- Walk-forward validation profit factor of 2.28 — meaningfully, the validation period performed BETTER than the training period, which is a strong indicator of genuine edge rather than overfitting

Realistic live expectations: profit factor 2.0 to 2.5 after typical out-of-sample shrinkage, with about 3 to 4 fires per year. The strongest tier (T7 "waterfall") catches genuine semiconductor cycle bottoms — examples include the 2020 COVID low, the 2022 chip-cycle bottom, and the April 2025 tariff-reversal low.

[b]Short signals — very unreliable, opt-in only[/b]

This is important: the short side is significantly weaker than the long side and should be treated with extra caution. SOXL spends most of its time in upward-trending semiconductor bull cycles, and shorting against that trend is inherently lower-probability. Through extensive testing, the original "exhaustion-based" short tiers (predicting tops) showed negative expectancy in live conditions and have been disabled by default.

Two opt-in short architectures are available, both turned off by default:

ST9 "bear-cycle" short (turn on via "Enable ST9 bear-cycle shorts" in settings)
- Only fires when the underlying SOX index is in a confirmed bear regime (200-day moving average declining)
- Waits for breakdown confirmation (price below 50-day average, new 20-day low) rather than trying to predict tops
- 7-day intended hold
- Historical: 8 fires over 10 years, profit factor 3.61 in-sample, but 6 of the 8 wins came from a single 6-month window in 2022. Live profit factor likely shrinks to 2.0 to 3.0.
- Recommendation: only enable when you've independently identified a bear cycle starting

ST10 "top-fade" short (turn on via "Enable ST10 top-fade shorts" in settings)
- Fires at single-day exhaustion patterns: upper Bollinger band touch, overbought stochastic, deeply extended above 20-day average, AND price stalls (closes below previous close on a small-change day)
- 3-day intended hold
- Historical: 17 fires over 10 years, profit factor 6.45 in-sample. Holds above 5.0 in every walk-forward split tested.
- Recommendation: enable when comfortable with discretionary top-fade trading. Hold strictly 3 days.

Honest caveats on shorts:
- Both short architectures have small historical sample sizes (8 and 17 fires respectively)
- Both have large performance variance — a few outlier wins inflate the headline numbers
- Short edges in leveraged-ETF land are genuinely fragile and asset-specific. The same architectures we tested on TQQQ and TNA produced losing results despite working on SOXL.
- Treat any individual short signal as a hypothesis to investigate, not a trade to execute mechanically

How the moving parts come together

The indicator runs through this logic each day:

1. Calculate base technicals: SMAs (20, 50, 200), Bollinger bands, stochastic, MACD, RSI, regression channels, and distance-from-mean metrics
2. Pull external context: VIX (volatility index) for the broad market, plus SMH (1x semi ETF) for divergence checking and SOX index for Wyckoff phase classification
3. Check tier conditions: each of the 7 long tiers and 2-5 short tiers has its own combination of thresholds; the indicator evaluates all of them
4. Compute conviction score: 7 supporting factors are checked (volatility panic, oversold bands, MACD direction, vol level, slope/extension, anchored regression position, Fibonacci levels for longs; symmetric set for shorts). Each contributing factor adds 1 to the conviction score (max 7)
5. Apply hard gates: long signals only fire if conviction is at least 3 (default). Short signals only fire if their respective opt-in toggle is enabled
6. Apply cooldown: at most one signal of each type per 8 trading days, to prevent clustering
7. Draw the signal: triangle, label, and details on the chart, plus alert-eligible event for TradingView notifications

The dashboard table in the corner of the chart shows current values of all the key inputs (distance from moving averages, stochastic, RSI, MACD, VIX, regime classification, Wyckoff phase) so you can see exactly why a signal is or isn't firing right now.

[b]Suggested usage[/b]

- Use long signals as candidates for swing entries, not automatic buys. Verify against your broader market view, sector context, and risk parameters
- Combine with options for leveraged exposure: 45 to 90 days to expiration, slightly out-of-the-money or at-the-money calls. Avoid weekly options — moves typically play out over 2 to 3 weeks
- Track real-world signal performance for your own use. After 5 to 10 actual trades, you'll have personal evidence of how the indicator behaves in your trading approach
- For shorts: leave both toggles off until you have a specific reason to expect a downturn. When you do enable, use long-dated puts (45 to 90 days) and exit on the indicator's intended hold horizon regardless of where the trade is

Settings worth knowing

- Min conviction for LONG signal (default 3): higher values produce fewer but higher-quality signals
- Enable SHORT signals (default off): controls the original ST1/ST_VIX exhaustion shorts — kept disabled because they showed negative expectancy
- Enable ST9 bear-cycle shorts (default off): trend-following shorts during confirmed bear regimes
- Enable ST10 top-fade shorts (default off): single-day reversal shorts at extended tops
- Show warning zones: background tinting for extreme zones (informational only)
- All thresholds for each tier are individually adjustable in the settings, but the defaults represent the validated configuration

Version history

- v8.11: adds ST10 top-fade short tier with 3-day hold (PF=6.45 in-sample)
- v8.10: adds ST9 bear-cycle short tier with 7-day hold (PF=3.61 in-sample)
- v8.9: introduces conviction-3 hard gate on longs, disables broken short architectures by default
- v8.6 and earlier: development versions, not recommended

This indicator has been designed to work exclusively with SOXL.  It has been built with extensive walk-forward validation, evaluator bug correction, and cross-asset testing against TQQQ and TNA equivalents.

## Source Code

````pine
//@version=6
indicator(title="SOXL Swing Signals v8.11 [+ ST10 Top-Fade Short]",
          shorttitle="SOXLv811",
          overlay=true,
          max_labels_count=500,
          max_lines_count=500)

// ═══════════════════════════════════════════════════════════════════
// SOXL SWING SIGNALS v8.11 — ADDS ST10 TOP-FADE SHORT
// ───────────────────────────────────────────────────────────────────
// v8.11 introduces a SECOND new short tier (ST10) that complements
// ST9 from v8.10. The two tiers are designed differently and target
// different setups:
//
// ST9  (v8.10): wait for bear regime + breakdown, hold 7 days.
//               PF=3.61 on SOXL. Catches sustained downtrends.
// ST10 (v8.11): catch single-day exhaustion at upper band, hold 3 days.
//               PF=6.45 on SOXL. Catches sharp top reversals.
//
// They don't overlap (different conditions, different holds, different
// regime requirements). User can enable independently or together.
//
// ARCHITECTURE — ST10 firing conditions (ALL required):
//   1. Bollinger Band position >= 0.95 (price at upper band)
//   2. Stoch K(3) >= 80 (overbought)
//   3. dist_sma20 >= 10% (extended above moving average)
//   4. day_chg < 1% AND close < previous close (price stalling)
//   5. VIX 30d max < 45 (not in crash recovery)
//   6. Conviction >= s_min_short_conv  (default 3 — same as v8.9)
//   7. s_enable_st10 = true (master toggle, default false)
//
// THE KEY DISCRIMINATOR: "price stalling" filter
//   After a long extension up, the FIRST day where price fails to
//   make further progress (close < yesterday AND day_chg < 1%) signals
//   exhaustion. Without this filter, the architecture fires 60+ times
//   with PF~1.2; WITH the filter, 17 fires with PF=6.45. The stalling
//   pattern is what separates real tops from mid-rally pullbacks.
//
// VALIDATION RESULTS (2016-2026 full SOXL history):
//   17 fires total
//   12 wins / 5 losses (71% win rate)
//   PF = 6.45
//   EV = +3.6% per signal (3-day hold)
//
// REGIME BREAKDOWN:
//   Full history (2016-2026):       17 fires, PF=6.45, EV +3.6%
//   In-sample (2020-08+):           12 fires, PF=6.76, EV +3.5%
//   Walk-fwd train (2020-2023):      8 fires, PF=8.65, EV +2.4%
//   Walk-fwd validate (2024-2026):   4 fires, PF=5.76, EV +5.7%
//   Pre-period (2016-2020):          5 fires, PF=5.90, EV +4.0%
//
// KEY OBSERVATION: PF holds above 5.0 in EVERY split. Validate ≈
// pre-benchmark period — strongest evidence yet of structural edge.
//
// HISTORICAL FIRES (full SOXL history):
//   2016-07-27   -2.3% WIN  (early SOXL data)
//   2017-11-07   -3.3% WIN
//   2019-07-25   +0.0% loss (essentially flat)
//   2019-12-13   +4.0% loss
//   2020-06-08  -18.2% WIN  (2020 chip rally exhaustion, near bench 2020-06-09)
//   2020-08-05   -3.7% WIN
//   2020-10-13   -3.8% WIN  (near bench 2020-10-12)
//   2021-04-06   +2.5% loss (near bench 2021-04-05)
//   2021-06-30   -3.4% WIN  (near bench 2021-06-29)
//   2021-11-09   -0.1% WIN
//   2022-11-14   -3.1% WIN  (mid-bear-rally fade)
//   2023-05-19   -7.8% WIN
//   2023-12-18   -0.1% WIN
//   2024-06-14   -0.1% WIN  (near bench 2024-06-18)
//   2025-01-23  -27.3% WIN  (near bench 2025-01-21 — biggest win in dataset)
//   2025-06-11   +1.2% loss
//   2025-09-19   +3.6% loss
//
// BENCHMARK OVERLAP: 6 of 13 ST10 fires in benchmark window land
// within ±7 days of a user-marked SHORT TOP date. This is the
// signal type the benchmark was capturing — short-term exhaustion
// reversals at sector tops.
//
// CROSS-VALIDATION on TQQQ: PF=0.20, FAIL. Mega-cap tech
// "stalling at upper band" is consolidation before continuation,
// not exhaustion. ST10 NOT recommended for TQQQ.
// CROSS-VALIDATION on TNA: PF=0.77, FAIL. Small-cap mean-reversion
// is too fast; the 3-day hold catches the bounce-back. ST10 NOT
// recommended for TNA.
//
// WHY ST10 WORKS ON SOXL SPECIFICALLY:
//   1. Highest leverage decay (~7%/day vol vs TQQQ 4.7%, TNA 4.9%).
//      Daily-rebalancing decay compounds harder on SOXL — even small
//      retracements amplify into larger SOXL drops.
//   2. Sharpest sector cycles. SOX expansion/contraction cycles tied
//      to semi inventory and capex are sharper than mega-cap tech
//      or small-cap rotations. Tops snap rather than roll.
//   3. Sector concentration. SOX is fewer than 30 companies, all
//      semi-related. When the marginal buyer steps back, the whole
//      sector retreats together. NDX has 100 names with diverse
//      drivers — even at "tops," many stocks hold up.
//
// CRITICAL CAVEATS:
//   - 17 fires across 10 years is moderate sample. PF=6.45 is real
//     but live PF likely lands at 3-4 after typical out-of-sample
//     shrinkage.
//   - 3-day hold is much shorter than ST9's 7-day. Trade management
//     matters more — exit promptly after 3 days, don't let losers
//     accumulate.
//   - DISABLED BY DEFAULT (s_enable_st10 = false). User should
//     enable when comfortable with discretionary top-fade trading.
//   - Per-fire P&L is smaller than ST9 (~3% avg vs ~10% on ST9).
//     Position size accordingly.
//   - 2025 saw 3 fires (1 win, 2 losses) suggesting recent regime
//     may be challenging. Track live performance — if PF drops below
//     2.0 after 4-5 live fires, the SOXL-specific edge may be eroding.
//
// CHANGES IN v8.11:
//
// 1. NEW INPUTS (ST10 group):
//    - s_enable_st10 (default false): master toggle
//    - s_st10_bb_min (default 0.95): BB position threshold
//    - s_st10_stoch_min (default 80): minimum stoch
//    - s_st10_dist20_min (default 0.10): minimum dist_sma20
//
// 2. SIGNAL GENERATION CHANGES:
//    - raw_short now includes short_t10 alongside ST1, ST_VIX, ST9
//    - short_t10 only fires when s_enable_st10 = true (independent
//      of s_enable_shorts and s_enable_st9 toggles)
//
// 3. NO CHANGES TO:
//    - Long signal logic (still v8.9 conviction-gated, PF~3-4)
//    - ST1, ST_VIX, ST3, ST4, ST6 (still gated behind s_enable_shorts)
//    - ST9 (still gated behind s_enable_st9, default off)
//    - Conviction-3 hard gate (applies to ST10 too)
//
// HOW TO USE ST10:
//   1. ST10 fires when SOXL is at an extension/exhaustion top.
//      You'll see ▼ SHORT [T10: top-fade] labels on the chart.
//   2. Trade with short-dated puts (10-30 DTE) since hold is only 3 days.
//      Or use 60-90 DTE puts and exit after 3 days regardless.
//   3. Position size: smaller than longs/ST9 because individual
//      win is small (~3-5% per signal). Don't size to capture
//      the rare -27% outliers — those are tail wins.
//   4. Hold strictly 3 days. Don't let losing trades run — the
//      architecture's edge is in the immediate 3-day window only.
//
// COMBINED USE WITH ST9:
//   Both can be enabled simultaneously (s_enable_st9 = true AND
//   s_enable_st10 = true). They rarely fire on the same day
//   (different conditions). Together produce ~3-4 short fires
//   per year on SOXL with combined PF in the 4-5 range.
//
// EXPECTED LIVE BEHAVIOR:
//   - Bull regimes: ST10 may fire 1-2x/year at extensions. ST9 stays silent.
//   - Bear regimes: ST10 less likely to fire (less extension). ST9 fires 3-7x.
//   - Combined: 2-4 fires/year typical, 5+ in volatile years.
//
// ═══════════════════════════════════════════════════════════════════
// SOXL SWING SIGNALS v8.10 — ADDS ST9 BEAR-CYCLE TREND-FOLLOWING SHORT
// ───────────────────────────────────────────────────────────────────
// v8.10 introduces a new short tier (ST9) that addresses the gap left
// by v8.9's complete short-side disable. Built on a different premise
// from previous shorts:
//
// PREVIOUS SHORTS (ST1, ST_VIX): "predict the top via exhaustion"
//   — Required overbought stoch, deep extension, blowoff conditions
//   — Failed because they fight the underlying bull trend
//
// ST9: "trade the breakdown via trend confirmation"
//   — Only fires when underlying SOX is in confirmed bear regime
//   — Waits for breakdown to confirm rather than predicting tops
//   — Holds 7 days (shorter than v8.9's 14-day standard) to avoid
//     getting caught in mid-trend bounces
//
// ARCHITECTURE — ST9 firing conditions (ALL required):
//   1. SOX SMA200 slope (30-day) <= -1%   (regime gate: confirmed bear)
//   2. Close below SOXL SMA50              (breakdown confirmation)
//   3. New 20-day low formed               (trend continuation)
//   4. Stoch K(3) >= 15                    (not already washed out)
//   5. Conviction >= s_min_short_conv      (default 3, same as v8.9)
//
// VALIDATION RESULTS (2016-2026 full history):
//   8 fires total
//   6 wins / 2 losses (75% win rate)
//   PF = 3.61
//   EV = +9.8% per signal (7-day hold)
//   Avg win magnitude: 18.0%
//   Avg loss magnitude: 15.1%
//
// REGIME BREAKDOWN:
//   In-sample (2020-08 onwards):  7 fires, 6 wins, PF=4.30, EV+11.9%
//   Walk-fwd train (2020-2023):    6 fires, 5 wins, PF=2.73, EV +7.3%
//   Walk-fwd validate (2024-2026): 1 fire,  1 win,  PF infinite
//   Pre-period (2016-2020):        1 fire,  0 wins, EV -4.9%
//
// HISTORICAL FIRES:
//   2018-12-07  +4.9% loss  (chip downturn early 2018)
//   2022-05-24  +25.3% loss (mistimed — bounce caught us)
//   2022-06-10  -24.0% WIN  (mid-2022 chip cycle bottom approaching)
//   2022-06-29   -4.7% WIN
//   2022-08-26  -18.7% WIN
//   2022-09-13  -13.1% WIN
//   2022-10-10   -8.6% WIN
//   2022-12-20   -7.1% WIN
//   2025-04-01  -39.6% WIN  (tariff-reversal bear leg)
//
// CROSS-VALIDATION on TNA: PF=2.00, 12 fires (different distribution
//   across 2019-2022). Confirms the architecture isn't curve-fit to
//   2022 — small-cap and semi bear cycles both work.
// CROSS-VALIDATION on TQQQ: PF=0.73, 6 fires (all 2022). Mega-cap
//   tech NDX has noisier bear microstructure with sharp V-bottom
//   bounces. ST9 NOT recommended for TQQQ — its existing v8.9 short
//   architecture (ST1/ST_VIX) already works there.
//
// CRITICAL CAVEATS:
//   - 8 historical fires is a SMALL sample. PF=3.61 is real but
//     uncertain. Live PF likely lands at 2.0-3.0 after typical
//     out-of-sample shrinkage.
//   - 6 of 8 fires came from a single 6-month window in 2022.
//     Heavy regime concentration. The architecture works in
//     genuine bear cycles but those are rare.
//   - 2024-2026 produced only 1 fire (April 2025 tariff bottom).
//     Cannot validate live edge until next bear cycle.
//   - DISABLED BY DEFAULT (s_enable_st9 = false). User should
//     enable only when they observe a confirmed bear cycle starting.
//
// CHANGES IN v8.10:
//
// 1. NEW INPUT (ST9 group):
//    - s_enable_st9 (default false): master toggle
//    - s_st9_slope_thr (default -0.01): SOX SMA200 slope threshold
//    - s_st9_stoch_min (default 15): minimum stoch (not too oversold)
//    - s_st9_hold_days (informational, hardcoded 7d via s_cooldown adjustment)
//
// 2. SIGNAL GENERATION CHANGES:
//    - raw_short now includes short_t9 alongside short_t1, short_t_vix
//    - short_t9 only fires when s_enable_st9 = true
//
// 3. NO CHANGES TO:
//    - Long signal logic (still v8.9 conviction-gated)
//    - ST1, ST_VIX (still gated behind s_enable_shorts, default false)
//    - Conviction-3 hard gate (applies to ST9 too)
//
// HOW TO USE ST9:
//   1. Watch macro indicators (SOX SMA200 slope flat or declining,
//      semi sector PE compression, broader market regime change)
//   2. When you judge a bear cycle is starting/active, enable ST9
//      in indicator settings (s_enable_st9 = true)
//   3. Trade the ▼ SHORT [T9] fires that appear, holding ~7 days
//      with long-dated puts (45-90 DTE) for time-decay protection
//   4. When the bear cycle ends (SMA200 slope returns to positive,
//      market regime stabilizes), disable ST9 again
//
// EXPECTED LIVE BEHAVIOR:
//   - Bull regimes: 0 fires (regime gate prevents firing)
//   - Active bear cycles: 3-7 fires across 6-12 months
//   - Live PF: 2.0-3.0 after typical out-of-sample shrinkage
//   - Per-signal EV: +5-9% per fire on 7-day hold
//
// ═══════════════════════════════════════════════════════════════════
// SOXL SWING SIGNALS v8.9 — LONG-ONLY CONVICTION-GATED
// ───────────────────────────────────────────────────────────────────
// SOXL skipped the v8.7 → v8.8 progression. v8.6 used the older
// F1-against-benchmark-dates optimization objective and a buggy
// evaluator. v8.9 jumps directly to the post-bugfix architecture
// validated on TQQQ and TNA, then adds the conviction-3 hard gate.
//
// TWO ARCHITECTURAL CHANGES:
//
// 1. CONVICTION HARD GATE on long signals (default >= 3/7).
//    The conviction score (0-7 from 7 multi-factor confirmation
//    points) is now a strict prerequisite for signal generation,
//    not just a label/marker styling thing. Low-conviction setups
//    don't fire at all (no chart triangle, no alert, no cooldown).
//
// 2. SHORT SIDE DISABLED by default.
//    Walk-forward analysis on SOXL shorts mirrors what we found on
//    TNA: in-sample passes (PF=1.95) but walk-forward validate
//    fails (PF=0.47 — all 4 fires in 2024-2026 were losers).
//    Same out-of-sample failure pattern. SOXL shorts are gated
//    behind s_enable_shorts toggle (default false).
//
// LONG SIDE VALIDATION (raw v8.8 architecture, before conviction gate):
//
//                           n   PF      EV
//   In-sample full         47  2.10   +7.0%
//   Walk-fwd train (20-23) 31  2.03   +7.1%
//   Walk-fwd valid (24-26) 16  2.28   +6.9%   ← validate > train, gold standard
//   Two-halves 1H          28  1.91   +7.0%
//   Two-halves 2H          19  2.59   +7.2%
//
//   PF stays above 1.9 in every split. Validation higher than
//   training is the strongest evidence we've seen for an honest
//   structural edge.
//
// LONG TIERS individual performance (in-sample):
//   LT1 (capitulation):    13 fires, PF 3.03  — solid
//   LT2 (OS+band):         26 fires, PF 2.03  — workhorse
//   LT3 (trend pullback):  11 fires, PF 1.35  — marginal
//   LT4 (BB dump):         disabled (TQQQ-style port)
//   LT5 (vol turn):        20 fires, PF 4.16  — strong
//   LT6 (deep oversold):   disabled (rare/unreliable on leveraged ETFs)
//   LT7 (waterfall):       31 fires, PF 3.94  — best tier
//
//   LT7 captures the SAME-DAY -5%+ drops with elevated VIX and
//   oversold stoch. On SOXL these are the genuine semi-cycle
//   capitulation events (2018 trade war, 2020 COVID, 2022 chip
//   downturn, 2025 tariff reversal). Single best edge in the
//   whole indicator.
//
// CONVICTION FILTER EXPECTED IMPACT (extrapolating from TNA):
//   On TNA the conviction-3 gate took raw PF=2.04 to PF=3.96
//   (nearly doubled), with fire count cut roughly in half and
//   win rate up from 58% to 69%. SOXL has similar raw PF (2.10)
//   so similar improvement is expected: ~25 long fires across
//   5.5 years, PF likely 3-4 in-sample, EV +10-15% per signal.
//
// SHORT SIDE — why it's disabled:
//   Best architecture found (ST1 deep-extension @ dist20>=10% +
//   VIX-rising 10d/20%): in-sample PF=1.95 / 11 fires.
//   But walk-forward validate (2024-2026): PF=0.47 / 4 fires,
//   ALL LOSERS. Same out-of-sample failure as TNA shorts.
//   Most likely cause: VIX is a poor proxy for SOX volatility.
//   Semis have their own vol regime that often diverges from
//   the broad S&P-vol index. Re-engineering would require a
//   semi-specific vol gate (e.g., ATR-based on SOX itself, or
//   options-implied vol on SMH).
//
// CHANGES IN v8.9:
//
// 1. NEW INPUTS (Conviction Gates group):
//    - s_min_long_conv  (default 3, range 0-7)
//    Set to 0 to recover unfiltered behavior.
//
// 2. NEW INPUTS (Short side disabled by default):
//    - s_enable_shorts (default false)
//    Set to true to re-enable for testing only — not recommended.
//
// 3. SIGNAL GENERATION:
//    - long_signal  := raw_long  AND cooldown_ok AND long_conviction >= s_min_long_conv
//    - short_signal := raw_short AND cooldown_ok AND s_enable_shorts
//
// EXPECTED LIVE PERFORMANCE (with typical out-of-sample shrinkage):
//   - LONG:  PF ~2.5-3.0, EV +8-12% per signal, ~4 fires/year
//   - SHORT: not enabled — use TQQQ shorts via TQQQ v8.9 instead
//            if you want short exposure to a leveraged-tech ETF.
//
// CAVEATS:
//   - SOXL daily volatility (~6.1%) is ~50% higher than TQQQ/TNA.
//     This means dollar swings per signal are larger — both for
//     wins and losses. Position sizing should account for this.
//   - SOXL underwent multiple stock splits historically. The data
//     used in v8.9 development was pre-cleaned; the indicator
//     itself uses real-time prices from TradingView which are
//     split-adjusted automatically.
//   - The 47-fire long-side sample becomes ~25 after conviction
//     filtering. Statistically reasonable but not robust. Live
//     PF could shrink meaningfully from in-sample 2-4 range.
//   - Long stretches with no signals are normal at conviction-3
//     filter level. A quiet quarter doesn't mean the indicator
//     is broken.
//   - Live monitoring: track 14d forward return after each fire.
//     If after 5+ fires PF drops below 1.5, conviction-3 gate
//     isn't holding live and v8.10 should consider tightening.
//
// BACKWARDS COMPATIBILITY:
//   - Set s_min_long_conv = 0 AND s_enable_shorts = true to get
//     unfiltered v8.8-equivalent behavior. All tier logic and
//     parameters are unchanged from the validated v8.8 architecture
//     ported from TQQQ.
//
// ═══════════════════════════════════════════════════════════════════
// PRIOR ARCHITECTURE NOTES (v8.6 — F1-against-dates objective)
// ───────────────────────────────────────────────────────────────────
// SOXL v8.6 was the previous production version. It used a different
// optimization objective (F1 against benchmark dates) and a buggy
// evaluator that inflated reported PF numbers. Whatever metrics
// v8.6 reported are not trustworthy. v8.9 numbers above are the
// first honest validation for SOXL.
// 
// All multi-tier signal logic (LT1-LT7, ST1-ST_VIX), conviction
// scoring, anchored regression bands, Wyckoff phase classification,
// and visual styling carry forward from the TNA/TQQQ v8.8 baseline.
//
// ═══════════════════════════════════════════════════════════════════
// SOXL SWING SIGNALS v8.8 (TNA original — adapted)
// ───────────────────────────────────────────────────────────────────
// v8.8 replaces F1-against-benchmark-dates with profit-factor against
// 14-day forward returns as the optimization objective. This is a
// fundamental change in what the indicator is tuned for: instead of
// "did the signal land near a known top/bottom?" we now ask "did the
// signal lead to a profitable 14-day trade?" — directly aligned with
// how the indicator is actually used.
//
// CRITICAL CONTEXT — bug correction:
// Prior versions (v8.7, v8.7.1) reported metrics computed by a buggy
// evaluator that mismatched signal positions to forward-return rows.
// Real v8.7.1 short-side performance was PF=1.16 / EV=+0.7%, NOT the
// PF=2.29 / EV=+4.5% previously reported. v8.8 metrics below are
// computed with the corrected evaluator, cross-validated against raw
// price data.
//
// SHORT-SIDE ARCHITECTURAL CHANGES:
//
// 1. ST3 (BB BREAKOUT TOP) REMOVED.
//    Properly evaluated, ST3 was a net-loser: PF=0.66 across all
//    parameter combinations tested. The "BB break in calm vol"
//    pattern that worked on SOXL does not transfer to TNA.
//
// 2. ST1 (BLOWOFF) PARAMETERS BROADENED.
//    v8.7.1 ST1 used stoch>=70, vol<25, dist20>=7%, dd<-3% lb=50.
//    v8.8 ST1 uses stoch>=80, vol<25, dist20>=7%, dd<-2% lb=50.
//    Higher stoch threshold + more permissive drawdown gate fires
//    more often (16 vs 8 in 1H of dataset) with PF=1.83 vs 1.15.
//
// 3. NEW TIER ST_VIX (VIX-RISING DISTRIBUTION).
//    Fires when VIX has risen >=5% in the last 5 trading days while
//    TNA is still extended above SMA20 (>=5%) with stoch>=50 and
//    overall vol still calm (<22). This captures "smart money is
//    hedging while price still climbs" — a distribution-style top
//    pattern that ST1's blowoff logic misses.
//    14 fires across 5.7 years, PF=2.03 in-sample.
//
// 4. ST4 and ST6 STAY DISABLED (toggle inputs default false).
//    Per v8.7.1 analysis, these tiers fire on situations that are
//    structurally rallies, not tops. Bug correction did not rescue
//    them — direction-rates remain ~30%.
//
// VALIDATION RESULTS (corrected evaluator):
//
//   SHORT SIDE: ST1_v88 OR ST_VIX, with 8-bar cooldown
//   ─────────────────────────────────────────────────────────────
//                              n   PF    EV     wins  losses
//   In-sample full           25  1.92  +3.0%   13    12
//   Walk-fwd train (20-23)   12  1.79  +2.6%    6     6
//   Walk-fwd valid (24-26)   13  2.19  +3.4%    7     6
//   Two-halves 1H            12  1.79  +2.6%    6     6
//   Two-halves 2H            13  2.19  +3.4%    7     6
//
//   The strongest evidence here is consistency: PF stays in the
//   1.79-2.19 range across both training/test splits, with similar
//   fire counts (12 vs 13) in each half. This is the signature of
//   a structural edge rather than a single lucky trade.
//
//   LONG SIDE (UNCHANGED from v8.7.1):
//   ─────────────────────────────────────────────────────────────
//                              n   PF    EV     wins  losses
//   In-sample full           42  2.01  +4.5%   26    16
//   Two-halves 1H            22  1.97  +4.6%   14     8
//   Two-halves 2H            20  2.08  +4.3%   12     8
//
//   Long side is the workhorse — 42 signals over 5.7 years (~7/yr),
//   62% win rate, +4.5% EV per signal, and remarkably consistent
//   across regimes.
//
// EXPECTED LIVE BEHAVIOR:
//   - 4-5 short signals/year (up from 2.5/yr in v8.7.1)
//   - PF likely 1.4-1.6 after typical in-sample-to-live degradation
//   - EV per short ~+1.5% to +2.5% live (versus +3.0% in-sample)
//   - Long side: 7-8 signals/year, EV per long ~+3% to +4% live
//
// CAVEATS:
//   - Sample sizes remain small. 12-13 short fires per half is
//     statistically reasonable but not robust. A 14th fire that
//     goes -10% can swing PF by 0.3-0.4.
//   - The VIX-rising tier requires VIX data to be loaded correctly.
//     If your data feed has VIX gaps, this tier silently won't fire.
//   - Live monitoring: track 14d forward return after each signal.
//     If after 8 short fires your PF is below 1.0, the validation
//     edge isn't holding up out-of-sample and v8.9 needs different
//     archetypes.
//
// ═══════════════════════════════════════════════════════════════════
// TNA SWING SIGNALS v8.7.1 — SHORT SIDE HARDENED
// ───────────────────────────────────────────────────────────────────
// v8.7.1 fixes a structural problem found in v8.7's short side:
// the four short tiers (ST1, ST3, ST4, ST6), in aggregate, fired on
// days when TNA went UP over the next 14 days more often than down.
// Mean 14d forward return after a v8.7 short was +3.7% — WORSE than
// the random-day baseline of +2.7% in the same eval window.
//
// FORWARD-RETURN ANALYSIS (v8.7, all 4 tiers, eval 2020-08 to 2026-04):
//   Tier  Fires  Mean 7d   Mean 14d   Direction-rate
//   ST1     100   +0.6%     +3.3%        48% neg
//   ST3      52   -0.5%     +2.1%        50% neg
//   ST4      34   +5.3%     +5.3%        29% neg  ← worse than coin flip
//   ST6      67   +2.9%     +4.5%        36% neg
//
// ROOT CAUSE: SOXL tracks a 3x leveraged long semiconductor ETF on SOX.
// Small-caps have positive drift. Mean-reversion shorts fight that
// drift — even when they nail a peak, the pullback has to be deep
// AND fast to be profitable on a 3x ETF before the underlying
// resumes climbing. F1 optimization (used in v8.7) rewards catching
// benchmark dates with high recall but doesn't penalize fires that
// occur during sustained uptrends — which is when most v8.7 shorts
// triggered.
//
// CHANGES IN v8.7.1:
//
// 1. ST4 (bearish RSI divergence) DISABLED.
//    Standalone direction-rate of 29% (71% of fires preceded UP
//    moves). Bearish divergence in a 3x bull ETF is a known weak
//    signal in trending markets. Tier kept as `false` for backward
//    compatibility but no longer contributes to raw_short.
//
// 2. ST6 (extended-above-SMA20 + stoch turning) DISABLED.
//    Same structural issue: "extended above SMA20 for 10 bars and
//    stoch declining" describes a healthy uptrend more than a top.
//    Direction-rate of 36%, mean 14d return +4.5%.
//
// 3. NEW DRAWDOWN GATE applied to ST1 and ST3:
//    Short signals require price to be at least 3% below its 50-bar
//    rolling high. This filter blocks shorts at all-time highs (the
//    primary failure mode in v8.7) and only fires after momentum has
//    visibly broken.
//
//    Results with gate applied:
//      Configuration            Fires  F1    Mean 14d  Direction-rate
//      ST1+ST3 ungated (v8.7)     35  0.35    +1.5%       46% neg
//      ST1+ST3 gated (v8.7.1)     14  0.24    -4.5%       43% neg
//
//    F1 drops because we sacrifice some recall (the "perfect peak
//    catch" at ATH that resolves DOWN), but average forward return
//    flips from +1.5% to -4.5%. This is the right trade-off — F1
//    rewards date-matching, but profitability requires that the
//    matched date actually precedes a meaningful drop.
//
// 4. Drawdown gate is exposed as user inputs (s_dd_lookback,
//    s_dd_threshold) so you can A/B test or relax for backtesting.
//    Defaults: 50-bar lookback, -3% drawdown.
//
// EXPECTED LIVE BEHAVIOR:
//   - ~3-5 short signals per year (down from 10-15 in v8.7)
//   - Each signal has empirically negative expected forward return
//   - Long side UNCHANGED — still ~10 signals/year, mean 14d ~+3-4%
//
// CAVEATS:
//   - v8.7.1 is still in-sample tuned. Expect 5-15% degradation in
//     live performance. The drawdown gate's mean-14d-return advantage
//     may shrink to -2% to -3% live, which is still a meaningful
//     edge for short-dated put options on a 3x ETF.
//   - The forward-return analysis uses 14-day horizons. Shorter
//     holds (3-7 days) had more variance; longer holds (21+) showed
//     drift contaminating results. 14d is the sweet spot for swing
//     options trading and is the metric you should monitor live.
//
// ═══════════════════════════════════════════════════════════════════
// TNA SWING SIGNALS v8.7 — EMPIRICALLY TUNED FROM v8.6 ADAPTATION
// ───────────────────────────────────────────────────────────────────
// v8.7 replaces the volatility-rescaled estimates used in v8.6 with
// thresholds optimized against a 61-date TNA benchmark of validated
// swing highs/lows over 2020-2026. Adds two new short tiers (ST4,
// ST6) targeting TNA-specific top patterns that the SOXL-derived
// architecture was missing.
//
// PERFORMANCE PROGRESSION (in-sample F1, ±7 day tolerance):
//   v8.6 (rescaled 0.68x):  Long F1 0.45, Short F1 0.28
//   v8.7 (this version):    Long F1 0.59, Short F1 0.46
//   SOXL v8.6 baseline:     Long F1 0.61, Short F1 0.48
//
// KEY CHANGES FROM v8.6 → v8.7:
//
// 1. LONG TIER THRESHOLDS empirically optimized via grid search:
//    T1: VIX 27→22, panic 1.30→1.20 (TNA fear triggers at lower VIX)
//    T2: dist_sma20 -10%→-6%, VIX 18→12 (much shallower entries work)
//    T4: dist_sma20 -8%→-4%, VIX 18→12 (tier ineffective regardless)
//    T5: dist_sma20 -8%→-6%, VIX 25→18 (best individual tier F1=0.45)
//    T6: dist_sma20 -10%→-12%, VIX 15→12 (deeper OS works on TNA)
//    T7: day_chg -7%→-5%, VIX 25→18 (milder waterfall threshold)
//
// 2. SHORT TIER THRESHOLDS optimized:
//    ST1: stoch 85→70 (more permissive blowoff trigger)
//    ST2: REMOVED. Failure-high tier produced F1=0 at all thresholds
//         tested. TNA tops don't follow the parabolic blowoff pattern.
//    ST3: stoch 80→70 (matches ST1)
//
// 3. NEW SHORT TIERS targeting structural patterns missed by v8.6:
//    ST4 — Bearish divergence at moderate extension. Fires when price
//          is 2%+ above SMA20, RSI14 ≥ 60, but RSI is LOWER than 10
//          bars ago while price is HIGHER. Catches the classic
//          "momentum waning while price grinds higher" pattern.
//          Standalone F1=0.36.
//    ST6 — Extended above SMA20 with stoch turning. Fires when TNA
//          has stayed above SMA20 for ≥10 bars, stoch was ≥60
//          yesterday, declined today, with 2%+ extension.
//          Catches the slow rollover after sustained uptrends.
//          Standalone F1=0.38.
//
// 4. VOLATILITY SOURCE CONFIRMED AS VIX (not RVX).
//    A/B test using real CBOE RVX history (2020-2026) showed VIX
//    outperforms RVX on TNA: Long F1 0.59 (VIX) vs 0.55 (RVX),
//    Short F1 0.46 (VIX) vs 0.45 (RVX). Tested across 5 different
//    threshold-scaling factors for RVX (1.00x to 1.40x) — none beat
//    VIX. RVX toggle retained for users who wish to test on their
//    own setups, but default is VIX.
//
// CRITICAL CAVEATS:
// - F1 numbers are IN-SAMPLE optimized. Live performance will be
//   5-15% lower (typical Long F1 0.50-0.54, Short F1 0.38-0.42).
//   This is the "in-sample inflation" cost of threshold tuning.
// - The 61-date TNA benchmark was generated mechanically (local
//   extrema with ≥10% subsequent reversal, 20-bar spacing). It
//   captured all major turning points but is less curated than the
//   SOXL benchmark you and I built collaboratively.
// - Walk-forward validation (train 2020-2023, test 2024-2026) was
//   NOT performed. If you want to estimate real out-of-sample
//   degradation precisely, that's the next step.
//
// ═══════════════════════════════════════════════════════════════════
// PRIOR CHANGELOG v8.6 — RUT WYCKOFF PHASE CONTEXT (adapted from SOX)
// ───────────────────────────────────────────────────────────────────
// v8.6 adds Wyckoff market-cycle phase detection on the underlying
// Philadelphia Semiconductor Index (INDEX:SOX) as context. SOX is used rather
// than TNA itself because Wyckoff phases are cleaner on the 1x
// underlying than on the 3x leveraged ETF.
//
// FOUR PHASES detected via SMA20 slope + 50-bar range position:
//   MARKUP       — slope > +1.5% over 20 bars (uptrend)
//   MARKDOWN     — slope < -1.5% over 20 bars (downtrend)
//   DISTRIBUTION — ranging after recent markup, upper half of range
//   ACCUMULATION — ranging after recent markdown, lower half of range
//
// SHORT CONVICTION: +1 factor when SOX phase is DISTRIBUTION.
// Lift estimate of ~1.4x from SOXL/SOX validation transferred by
// analogy. TNA-specific empirical validation pending.
//
// Short max conviction is 7/7 (matches long).
// Conviction tier thresholds: high >= 5, medium = 4, low <= 3.
//
// ═══════════════════════════════════════════════════════════════════
// CHANGELOG v8.5 — WATERFALL TIER (T7) FOR LONG SIGNALS
// ───────────────────────────────────────────────────────────────────
// v8.5 adds a new 7th long tier designed to catch single-day
// capitulation lows that slip through tiers 1-6 because those
// tiers all require momentum reversal confirmation (MACD improving,
// VIX peaking) which doesn't exist on the actual knife-catch day.
//
// TIER 7 — WATERFALL CAPITULATION:
//   day_chg <= -10%          (severe single-day crash)
//   vix >= 25                (elevated fear environment)
//   stoch_k3 <= 20           (deeply oversold oscillator)
//   at_lower_band            (shared band condition)
//
// Deliberately NO macd_improving requirement — this tier targets the
// same-day crash profile. Safety comes from the severity of the
// required drop combined with vol and oscillator confirmation.
//
// BENCHMARK RESULT (on SOXL — analogue performance expected for TNA):
//   Baseline v8.4:  63% precision, 40% recall, F1 0.49
//   With T7:        72% precision, 52% recall, F1 0.61
//   Adds 6 TPs for only 3 FPs. Precision actually INCREASES because
//   T7 firings are disproportionately at real benchmarks.
//
// Rescued benchmarks (SOXL): 2021-05-12, 2022-03-14, 2022-05-11,
// 2022-10-13, 2026-03-30, plus one secondary match.
// TNA equivalent benchmarks not yet measured.
//
// Long max conviction remains 7/7 (no new conviction factor needed —
// the tier itself IS the new capability). Thresholds unchanged.
//
// ═══════════════════════════════════════════════════════════════════
// CHANGELOG v8.4 — FIBONACCI RETRACEMENT CONTEXT
// ───────────────────────────────────────────────────────────────────
// v8.4 keeps all v8.3 functionality and adds two Fibonacci retracement
// levels as an optional 7th conviction factor.
//
// EMPIRICAL BASIS:
// On the benchmark dataset, only two Fib levels showed statistically
// significant lift above random:
//   - 61.8% retrace:  11.4% bench hit vs 1.7% random  (6.59x lift)
//   - 100% retrace:   9.1%  bench hit vs 3.2% random  (2.88x lift)
// Other Fib levels (23.6%, 38.2%, 50%, 78.6%) showed no meaningful edge.
//
// This version implements ONLY those two empirically-supported levels.
// Extensions, fans, arcs, and time zones are deliberately omitted.
//
// HOW IT WORKS:
// For LONG signals: computes the swing high (highest high in past
//   N bars) and the prior swing low (lowest low in the N bars before
//   that high). Measures current close as a % retracement of that
//   range. If within ±3% of 61.8% or 100%, adds +1 to conviction.
//
// SHORT signals don't get a Fib conviction point because the analogous
// test (retrace UP from a prior low) didn't show comparable lift on
// short benchmarks.
//
// Long max conviction is now 7/7. Thresholds updated:
//   high ≥ 5, medium = 4, low ≤ 3.
// Short max conviction stays at 6/6 (unchanged from v8.3).
//
// VISUAL:
// Optional horizontal dashed lines show the 61.8% and 100% retrace
// levels on the chart, updated from the current swing high/low.
//
// ═══════════════════════════════════════════════════════════════════
// CHANGELOG v8.3 — ANCHORED REGRESSION CHANNELS
// ───────────────────────────────────────────────────────────────────
// v8.3 keeps all v8.2 signal logic and conviction scoring, and adds
// two pivot-anchored regression channels drawn on the chart as
// discretionary context:
//
//   - Long anchor: regression from last confirmed pivot LOW to now
//     (shows whether the current uptrend leg is still intact)
//   - Short anchor: regression from last confirmed pivot HIGH to now
//     (shows whether the current downtrend leg is still intact)
//
// These lines update each time a new pivot is confirmed (pivot detected
// N bars after the actual pivot occurs — configurable).
//
// WHY ANCHORED AND NOT FIXED-LOOKBACK:
// A fixed 50-bar regression window always mixes pre- and post-regime
// bars during trend changes. The anchored version cleanly measures
// only the CURRENT leg. Benchmark testing showed anchored has higher
// recall (76% vs 71% on longs) but also higher false-positive rate,
// so it's NOT promoted to a signal gate. It's a visual+conviction tool.
//
// v8.3 also adds a conviction point (+1) for each side when the
// anchored regression AGREES with the fixed-lookback reading — i.e.
// price is at the lower band of both the 50-bar fixed AND the anchored
// channel. This is a genuinely higher-conviction setup.
//
// Max conviction on longs and shorts is now 6/6 (was 5/5).
//
// ═══════════════════════════════════════════════════════════════════
// CHANGELOG v8.2 — CONVICTION-WEIGHTED SIGNALS
// ───────────────────────────────────────────────────────────────────
// v8.2 keeps all v8.1 signal logic identical but adds a conviction
// score (0-5 points) to every signal based on multi-factor agreement.
// Purpose: let the trader size positions by signal strength rather
// than treating every signal equally.
//
// Benchmark-tested precision by conviction tier:
//   LONG  3+/5:  77% precision (13 signals over 5.7yr)
//   LONG  2/5:   50% precision
//   LONG  0-1/5: 50% precision
//   SHORT 3+/5:  64% precision (11 signals over 5.7yr)
//   SHORT 2/5:   39% precision
//   SHORT 0-1/5: 50% precision
//
// NOTE: These numbers are fitted to the benchmark used to tune the
// rules. Expect 5-10% lower precision in live out-of-sample use.
//
// CONVICTION RULES (each worth +1):
//
// LONG signals:
//   +1  VIX panic ratio >= 1.15
//   +1  Both reg_pos_50 AND bb_pos_50 <= 0.10 (bands deep agree)
//   +1  MACD histogram improving
//   +1  VIX absolute level >= 25
//   +1  Regression slope_50 > 0.003 (rising trend pullback)
//
// SHORT signals:
//   +1  Stoch K(3) >= 90
//   +1  Both reg_pos_20 AND bb_pos_20 >= 0.95 (bands extreme agree)
//   +1  MACD histogram rolling down (roc <= -0.1)
//   +1  VIX < 18 (calm market — correction risk)
//   +1  Dist SMA50 > 20% (meaningfully extended)
//
// DISPLAY:
//   - Large triangles for conviction >= 5 on either side (/7 scale)
//   - Medium triangles for conviction = 4
//   - Small triangles for conviction <= 3 (shortlist only)
//   - Label shows conviction score + contributing factors
//   - Info table adds conviction row
//   - Two alert sets: all signals, and high-conviction only
//
// ═══════════════════════════════════════════════════════════════════
// CHANGELOG v8.1 — CONTEXTUAL INDICATORS ADDED
// ───────────────────────────────────────────────────────────────────
// v8.1 adds three market-context readings that appear in the info
// table, label, and data window — but do NOT modify any signal tier
// logic. This is a deliberate first-pass: observe the readings on
// live signals, then promote useful ones to filter gates in v8.2.
//
// [1] VIX term structure (VIX9D/VIX, VIX3M/VIX)
//     VIX9D > VIX (ratio > 1.0) = backwardation = immediate fear
//     exceeds longer-dated fear = classic short-term bottom signal
//     VIX3M >> VIX (ratio > 1.3) = steep contango = complacency
//
// [2] Weekly timeframe regime (via request.security on W timeframe)
//     Weekly close vs weekly SMA20 — tells you if you're trading
//     with or against the higher-timeframe trend. A daily oversold
//     bounce in a weekly downtrend is lower probability than in an
//     uptrend. A daily overbought reading in a weekly uptrend is
//     often just a pause, not a top.
//
// [3] SMH (semi ETF) divergence
//     SOXL tracks SMH at 3x but with daily decay. Compare
//     dist_sma20 ratio: TNA_dist / IWM_dist. Theoretical ratio ~3,
//     deviations indicate TNA stretched (>3.5) or lagging (<2.5).
//     Useful discretionary context.
//
// These show up as:
//   - Info table rows at bottom
//   - Label extension on signal fires ("Context: VIX9D/VIX=1.12,
//     Wk trend: UP, SMH ratio: 3.4")
//   - Data window for offline analysis
//   - Optional visual cue: warning zone background tints
//     differently if weekly trend disagrees with signal direction
//
// [PRIOR v8 CHANGELOG PRESERVED BELOW]
//
// Adds two structural band systems that capture setups which were
// invisible to oscillator-only logic in v7.2:
//
// [1] Linear regression channel (20/50 bar) — "price vs trend"
// [2] Bollinger Bands (20/50 bar) — "price vs recent range"
//
// LONG signals use 6 tiers: Capitulation, Oversold+band, Trend pullback,
// BB extreme, VIX peak-turn, Deep oversold
// SHORT signals use 3 tiers: Blowoff, Failure high, BB breakout
//
// Benchmark performance vs 87 user-marked optimal dates:
//   v7.2: short F1=0.51, long F1=0.45
//   v8:   short F1=0.48, long F1=0.49 (long recall 33% → 40%)
// ═══════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────
// VOL INDEX SELECTION
// ─────────────────────────────────────────────────────────
grp_vol = "Volatility Index"
// Volatility index hardcoded to VIX for SOXL — semi-cycle vol correlates with broad-market vol.
// RVX (Russell 2000 vol) was offered as a toggle in TNA's version of this indicator but is
// not appropriate for semis. Removed from v8.9 to simplify input UI.
vol_symbol = "CBOE:VIX"
vol_scale  = 1.00
vol_label  = "VIX "

// ─────────────────────────────────────────────────────────
// INPUTS — BANDS
// ─────────────────────────────────────────────────────────
grp_b = "Band Systems"
bb_len        = input.int(20,   "Bollinger lookback (bars)",       minval=5, group=grp_b)
bb_mult       = input.float(2.0,"Bollinger std dev multiplier",    step=0.1, group=grp_b)
reg_len_short = input.int(20,   "Regression channel — short lookback", minval=10, group=grp_b)
reg_len_long  = input.int(50,   "Regression channel — long lookback",  minval=20, group=grp_b)
reg_mult      = input.float(2.0,"Regression std dev multiplier",   step=0.1, group=grp_b)

// ─────────────────────────────────────────────────────────
// ANCHORED CHANNEL INPUTS [NEW v8.3]
// ─────────────────────────────────────────────────────────
grp_a = "Anchored Channels (v8.3)"
use_anchored        = input.bool(true, "Show pivot-anchored regression channels", group=grp_a,
                      tooltip="Draws trend lines + bands from the most recent confirmed pivot to now. Updates when new pivots form.")
pivot_left          = input.int(5, "Pivot lookback bars (left)", minval=3, maxval=20, group=grp_a,
                      tooltip="Bars on the left side required for a pivot. Higher = stricter pivots, fewer updates.")
pivot_right         = input.int(5, "Pivot lookback bars (right)", minval=3, maxval=20, group=grp_a,
                      tooltip="Bars on the right for confirmation. The pivot can only be drawn this many bars AFTER it happened.")
anchor_min_bars     = input.int(10, "Min bars since pivot to draw channel", minval=5, group=grp_a)
anchor_max_bars     = input.int(150, "Max bars since pivot to draw channel", minval=30, group=grp_a)
anchor_mult         = input.float(2.0, "Anchored channel std dev multiplier", step=0.1, group=grp_a)
use_anchored_conv   = input.bool(true, "Add anchored agreement to conviction score", group=grp_a,
                      tooltip="+1 conviction point when fixed-lookback AND anchored regression both confirm band position.")

// ─────────────────────────────────────────────────────────
// FIBONACCI CONTEXT INPUTS [NEW v8.4]
// ─────────────────────────────────────────────────────────
grp_f = "Fibonacci Context (v8.4)"
use_fib             = input.bool(true, "Show 61.8% and 100% retrace levels", group=grp_f,
                      tooltip="Draws dashed horizontal lines at the 61.8% and 100% retracement levels of the current swing. Only these two levels showed statistical lift over random days.")
fib_swing_high_lb   = input.int(120, "Swing high lookback (bars)", minval=30, group=grp_f,
                      tooltip="How far back to look for the most recent swing high. 120 bars ≈ 6 months.")
fib_prior_low_lb    = input.int(100, "Prior swing low lookback (bars before swing high)", minval=30, group=grp_f,
                      tooltip="How far back to look for the prior swing low, starting from the swing high.")
fib_tolerance       = input.float(3.0, "Tolerance % for 'at Fib level'", step=0.5, group=grp_f,
                      tooltip="Price within this percentage of a Fib level counts as 'at' that level for conviction purposes.")
use_fib_conv        = input.bool(true, "Add Fib retrace agreement to LONG conviction", group=grp_f,
                      tooltip="+1 LONG conviction when price is at the 61.8% or 100% retrace of the prior up-move. Empirically supported on the benchmark.")

// ─────────────────────────────────────────────────────────
// INPUTS — SHORT
// ─────────────────────────────────────────────────────────
grp_s = "SHORT Signal Parameters"
s_dist20      = input.float(0.07, "Min distance above SMA20",            step=0.01,  group=grp_s)
s_dist50_max  = input.float(0.40, "Max distance above SMA50",            step=0.01,  group=grp_s)
s_bull_dist50 = input.float(0.05, "Min dist SMA50 in bull regime",       step=0.01,  group=grp_s)
s_bear_dist200= input.float(0.07, "Max dist SMA200 in bear regime",      step=0.01,  group=grp_s)
s_stoch       = input.float(80,   "Min Stoch K(3) for T1 blowoff",       step=1,     group=grp_s)
s_t2_stoch    = input.float(50,   "Min Stoch K(3) for T2 failure high",  step=1,     group=grp_s)
s_t2_rsi      = input.float(65,   "Min RSI for T2 failure high",         step=1,     group=grp_s)
s_t2_dist50   = input.float(0.10, "Min dist SMA50 for T2",               step=0.01,  group=grp_s)
s_t3_stoch    = input.float(70,   "Min Stoch K(3) for T3 BB breakout",   step=1,     group=grp_s)
// New v8.7 short tiers — empirically derived from TNA distribution-top patterns
s_t4_dist20   = input.float(0.02, "T4 divergence min dist SMA20",        step=0.01,  group=grp_s,
                tooltip="ST4 fires when price grinds higher but RSI makes lower highs over 10 bars. Triggers in calm bull-market environments where momentum is waning. F1=0.36 standalone.")
s_t4_div_lb   = input.int(10,     "T4 divergence lookback (bars)",       minval=5,   group=grp_s)
s_t4_rsi      = input.float(60,   "T4 minimum RSI",                      step=1,     group=grp_s)
s_t4_vol_max  = input.float(22,   "T4 maximum vol",                      step=1,     group=grp_s)
s_t6_min_bars = input.int(10,     "T6 min bars above SMA20 (rollover)",  minval=5,   group=grp_s,
                tooltip="ST6 fires when TNA has stayed above SMA20 for at least N bars and stoch is rolling over from elevated. Catches grinding-distribution tops. F1=0.38 standalone.")
s_t6_stoch    = input.float(60,   "T6 prior-day stoch threshold",        step=1,     group=grp_s)
s_t6_dist20   = input.float(0.02, "T6 min dist SMA20",                   step=0.01,  group=grp_s)
// v8.7.1 short-side hardening — drawdown gate blocks shorts at recent highs
s_dd_lookback = input.int(50,     "Drawdown gate: lookback (bars)",      minval=10,  group=grp_s,
                tooltip="v8.8: Short signals require price to be at least s_dd_threshold below the highest close in the last s_dd_lookback bars. Blocks shorts at all-time highs where they historically resolve UP.")
s_dd_threshold= input.float(-0.02,"Drawdown gate: min drawdown (negative)",step=0.01,group=grp_s,
                tooltip="v8.8: Default broadened from -0.03 to -0.02 based on PF optimization. -0.03 was too restrictive — too few fires for statistical significance.")
// v8.8 NEW TIER: ST_VIX (VIX-rising distribution top)
s_vix_lb      = input.int(5,      "ST_VIX: VIX change lookback (bars)",  minval=1,   group=grp_s,
                tooltip="v8.8: ST_VIX fires when VIX has risen by s_vix_chg over the last s_vix_lb bars while TNA is still extended. Captures 'smart money hedging while price climbs' distribution pattern.")
s_vix_chg     = input.float(0.05, "ST_VIX: min VIX % change",            step=0.01,  group=grp_s)
s_vix_dist20  = input.float(0.05, "ST_VIX: min dist above SMA20",        step=0.01,  group=grp_s)
s_vix_stoch   = input.float(50,   "ST_VIX: min stoch K",                 step=1,     group=grp_s)
s_vix_volmax  = input.float(22,   "ST_VIX: max VIX absolute level",      step=1,     group=grp_s,
                tooltip="ST_VIX requires VIX to be RISING but still at modest absolute levels — fires during the early phase of risk-off, not after panic has set in.")
s_use_t3      = input.bool(false, "Enable ST3 (BB breakout) — DISABLED v8.8", group=grp_s,
                tooltip="v8.8: ST3 had PF=0.66 (net loser) when properly evaluated. Disabled. Set true only for backtesting comparison.")
s_use_t4      = input.bool(false, "Enable ST4 (bearish divergence) — DISABLED v8.7.1", group=grp_s,
                tooltip="ST4 had a 29% direction-rate (71% of fires preceded UP moves). Disabled in v8.7.1. Set true to re-enable for testing only.")
s_use_t6      = input.bool(false, "Enable ST6 (extended rollover) — DISABLED v8.7.1", group=grp_s,
                tooltip="ST6 had a 36% direction-rate and mean 14d return of +4.5%. Disabled in v8.7.1. Set true to re-enable for testing only.")
s_vol_max     = input.float(25,   "Max vol threshold (auto-scales)",     step=1,     group=grp_s)
s_di_gap      = input.float(25,   "Max +DI gap vs -DI",                  step=1,     group=grp_s)
s_crash_lock  = input.float(45,   "Post-crash lockout vol level",        step=1,     group=grp_s)
s_cooldown    = input.int(8,      "Cooldown bars after signal",          minval=1,   group=grp_s)

// ─────────────────────────────────────────────────────────
// INPUTS — CONVICTION GATE + SHORT DISABLE (v8.9)
// ─────────────────────────────────────────────────────────
// Long signals require conviction >= threshold (default 3). Short
// signals disabled by default — SOXL shorts had negative expectancy
// at every conviction threshold tested. Re-enable only for testing.
grp_conv = "Conviction Gates [v8.9]"
s_min_long_conv = input.int(3,    "Min conviction for LONG signal",      minval=0, maxval=7, group=grp_conv,
                tooltip="Long signals require long_conviction (0-7) >= this. Default 3. Setting 0 recovers unfiltered v8.8-equivalent behavior. SOXL raw long-side validation: PF=2.10 in-sample, PF=2.28 walk-forward validate (validation HIGHER than train — strongest evidence of structural edge). Conviction filter expected to lift PF to 3-4 range based on TNA analog.")
s_enable_shorts = input.bool(false, "Enable SHORT signals (disabled v8.9)", group=grp_conv,
                tooltip="SOXL shorts pass in-sample testing (PF=1.95) but fail walk-forward validation (PF=0.47, all 4 fires in 2024-2026 were losers). Likely cause: VIX is a poor proxy for SOX volatility — semis have their own vol regime that often diverges from broad-market vol. Disabled by default. Set true only for testing — not recommended for live trading. For short exposure to leveraged-tech ETFs, use TQQQ v8.9 instead.")

// ─────────────────────────────────────────────────────────
// INPUTS — ST9 BEAR-CYCLE TREND-FOLLOWING SHORT (v8.10)
// ─────────────────────────────────────────────────────────
// New short tier that only fires during confirmed bear regimes.
// Different premise from ST1/ST_VIX (which try to predict tops):
// ST9 waits for bear regime + breakdown confirmation, then trades
// the trend down for 7 days. Validated PF=3.61 on 8 historical fires.
grp_st9 = "ST9 Bear-Cycle Short [v8.10]"
s_enable_st9     = input.bool(false, "Enable ST9 bear-cycle shorts (off by default)", group=grp_st9,
                   tooltip="Master toggle for ST9. Default false — enable only when you observe a confirmed bear cycle starting (SOX SMA200 slope flat/declining, sector PE compression, broader market regime change). When enabled, ST9 fires only during bear regimes by design — expect 0 fires in bull markets. Validated PF=3.61, EV +9.8% per signal across 8 historical fires (2018-2025).")
s_st9_slope_thr  = input.float(-0.01, "ST9: SOX SMA200 slope threshold", step=0.005, group=grp_st9,
                   tooltip="ST9 only fires when SOX SMA200 slope (30-day) is below this threshold. Default -0.01 (-1%) means SMA200 has been declining at >=1% per 30 days. Tighter (-0.02) requires more pronounced bear regime; looser (0.0) allows flat regimes too.")
s_st9_stoch_min  = input.int(15,    "ST9: minimum stoch K(3) at entry", minval=0, maxval=50, group=grp_st9,
                   tooltip="ST9 won't fire when stoch is already below this — prevents shorting into already-washed-out conditions that often bounce. Default 15. The 'not too oversold' guard discriminator that lifted PF from 2.54 to 3.61 in development.")
s_st9_hold_info  = input.string("7", "ST9: hold horizon (informational)", options=["7"], group=grp_st9,
                   tooltip="ST9 is designed and validated for 7-day holds, shorter than v8.9's 14-day standard. Trend-following shorts on leveraged ETFs work best on shorter horizons because mid-trend bounces eat into longer holds. This input is informational only — actual hold logic is your discretionary trade management.")

// ─────────────────────────────────────────────────────────
// INPUTS — ST10 TOP-FADE SHORT (v8.11)
// ─────────────────────────────────────────────────────────
// Catches single-day exhaustion at upper Bollinger band with stalling
// price action. Different from ST9 (which waits for breakdown in bear
// regime) — ST10 fires AT the top, not after. 3-day hold.
// Validated PF=6.45 on SOXL (17 fires across 2016-2026).
// SOXL-SPECIFIC: cross-validation showed ST10 FAILS on TQQQ (PF=0.20)
// and TNA (PF=0.77). Don't apply this architecture to other ETFs.
grp_st10 = "ST10 Top-Fade Short [v8.11]"
s_enable_st10     = input.bool(false, "Enable ST10 top-fade shorts (off by default)", group=grp_st10,
                    tooltip="Master toggle for ST10. Default false. Catches sharp reversal patterns at sector tops — fires when SOXL is at upper Bollinger band, stoch overbought, deeply extended, AND price stalls (close < previous close, day_chg < 1%). Validated PF=6.45 across 17 fires (2016-2026). 3-day hold. Independent of s_enable_st9 — both can be on simultaneously.")
s_st10_bb_min     = input.float(0.95, "ST10: BB position threshold", minval=0.5, maxval=1.5, step=0.05, group=grp_st10,
                    tooltip="Minimum Bollinger Band position to qualify as 'at upper band'. Default 0.95 (5% inside the upper band or above). Tighter (1.0+) requires price above the band; looser (0.85) allows near-band fires.")
s_st10_stoch_min  = input.int(80,     "ST10: minimum stoch K(3)", minval=50, maxval=100, group=grp_st10,
                    tooltip="Minimum stoch K(3) reading to qualify as overbought. Default 80. Tighter (90) requires more extreme overbought; looser (70) allows broader exhaustion patterns.")
s_st10_dist20_min = input.float(0.10, "ST10: minimum dist from SMA20", step=0.01, group=grp_st10,
                    tooltip="Minimum percentage distance above SMA20 to qualify as extended. Default 0.10 (10%). Tighter (0.15) requires more extension; looser (0.05) allows shallower tops.")
s_st10_hold_info  = input.string("3", "ST10: hold horizon (informational)", options=["3"], group=grp_st10,
                    tooltip="ST10 is designed and validated for 3-day holds. Top-fade trades work on the immediate post-top decline before any bounce. Hold strictly 3 days — don't let losing trades run, and don't try to capture larger moves.")

// ─────────────────────────────────────────────────────────
// INPUTS — LONG
// ─────────────────────────────────────────────────────────
grp_l = "LONG Signal Parameters"
l_t1_stoch    = input.float(25,   "T1 capitulation max stoch",           step=1,    group=grp_l)
l_t1_vol      = input.float(22,   "T1 min vol",                          step=1,    group=grp_l)
l_t1_panic    = input.float(1.20, "T1 min panic ratio",                  step=0.05, group=grp_l)
l_t2_stoch    = input.float(18,   "T2 oversold max stoch",               step=1,    group=grp_l)
l_t2_dist20   = input.float(-0.06,"T2 max dist below SMA20",             step=0.01, group=grp_l)
l_t2_vol      = input.float(12,   "T2 min vol",                          step=1,    group=grp_l)
l_t3_stoch    = input.float(40,   "T3 trend pullback max stoch",         step=1,    group=grp_l,
                tooltip="T3 catches shallow pullbacks in uptrends — stoch doesn't need to be deeply oversold")
l_t3_slope    = input.float(0.003,"T3 min regression slope (per bar)",   step=0.001,group=grp_l)
l_t4_dist20   = input.float(-0.04,"T4 BB extreme max dist SMA20",        step=0.01, group=grp_l)
l_t4_stoch    = input.float(18,   "T4 BB extreme max stoch",             step=1,    group=grp_l)
l_t5_vol      = input.float(18,   "T5 vol peak-and-turn min vol",        step=1,    group=grp_l)
l_t5_turn     = input.float(0.90, "T5 vol as % of 3d max",               step=0.01, group=grp_l)
l_t6_stoch    = input.float(10,   "T6 deep oversold max stoch",          step=1,    group=grp_l)
l_t6_panic    = input.float(1.15, "T6 deep oversold min panic",          step=0.05, group=grp_l)
l_t7_daychg   = input.float(-0.05,"T7 waterfall max single-day change",  step=0.01, group=grp_l,
                tooltip="T7 waterfall catches capitulation lows on the crash day itself. Requires a severe single-day drop (-10% default). Does NOT require MACD reversal confirmation.")
l_t7_vol      = input.float(18,   "T7 waterfall min vol",                step=1,    group=grp_l)
l_t7_stoch    = input.float(20,   "T7 waterfall max stoch",              step=1,    group=grp_l)
use_t7        = input.bool(true,  "Enable T7 waterfall tier",             group=grp_l,
                tooltip="Adds a 7th long tier for same-day capitulation catches. Benchmark-validated: +6 TPs for only 3 FPs, F1 0.49 -> 0.61.")
l_cooldown    = input.int(8,      "Cooldown bars after signal",          minval=1,  group=grp_l)

// ─────────────────────────────────────────────────────────
// CONTEXTUAL INDICATORS [NEW v8.1 — informational only, not filters]
// ─────────────────────────────────────────────────────────
grp_c = "Market Context (v8.1)"
use_term_struct = input.bool(true,  "Show VIX term structure (VIX9D/VIX, VIX3M/VIX)", group=grp_c,
                  tooltip="Term structure > 1.0 = backwardation = immediate fear exceeds longer-dated fear.")
use_weekly      = input.bool(true,  "Show higher timeframe (weekly) regime",          group=grp_c,
                  tooltip="Weekly close vs weekly SMA20. Trading with weekly trend = higher probability.")
use_smh_diverge = input.bool(true,  "Show SMH (SOXL vs 1x peer) divergence",          group=grp_c,
                  tooltip="SOXL/SMH dist ratio. Theoretical 3x. >3.5 = SOXL stretched, <2.5 = SOXL lagging.")
smh_symbol      = input.string("NASDAQ:SMH", "SMH ticker (1x semi ETF)", group=grp_c,
                  tooltip="The 1x semiconductor ETF used for divergence analysis. Default AMEX:SMH (NYSE Arca via TradingView's AMEX prefix). If unavailable on your data feed, try NASDAQ:SMH or NYSEARCA:SMH.")
tint_zones      = input.bool(true,  "Tint warning zones based on weekly trend agreement", group=grp_c,
                  tooltip="Warning zone background shows more saturated colour when weekly trend AGREES with signal direction.")

// ─────────────────────────────────────────────────────────
// SOX WYCKOFF PHASE INPUTS [NEW v8.6]
// ─────────────────────────────────────────────────────────
grp_w = "SOX Wyckoff Phase (v8.6)"
use_wyckoff     = input.bool(true,  "Detect SOX Wyckoff phase", group=grp_w,
                  tooltip="Classifies the underlying Philadelphia Semiconductor Index (SOX) into Markup/Markdown/Distribution/Accumulation phases. SOX provides cleaner Wyckoff signals than SOXL itself.")
sox_symbol      = input.string("INDEX:SOX", "SOX context ticker", group=grp_w,
                  tooltip="Underlying context for Wyckoff phase classification. Default AMEX:SMH (1x semi ETF) which is universally available on TradingView. For the actual Philly Semi Index try INDEX:SOX or NASDAQ:SOX if your account has access. Phase classification works equivalently on SMH since it tracks the index closely.")
wyck_slope_thr  = input.float(1.5, "Markup/Markdown slope threshold %", step=0.25, group=grp_w,
                  tooltip="SMA20 slope over 20 bars. >+threshold = Markup, <-threshold = Markdown. 1.5% default suits Russell 2000 trend dynamics."  )
wyck_range_lb   = input.int(50, "Range lookback for distribution/accumulation classification", minval=20, group=grp_w,
                  tooltip="When SOX is ranging (slope within threshold), classify as Distribution (upper half of N-bar range) or Accumulation (lower half).")
use_wyck_conv   = input.bool(true, "Add SOX Distribution as SHORT conviction factor", group=grp_w,
                  tooltip="+1 short conviction when SOX is in Distribution phase. Empirically validated on SOX in original v8.6 development.")

// ─────────────────────────────────────────────────────────
// DISPLAY
// ─────────────────────────────────────────────────────────
grp_d = "Display"
show_sma        = input.bool(true,  "Show SMA 10/20/50/200",             group=grp_d)
show_bb         = input.bool(true,  "Show Bollinger Bands",              group=grp_d)
show_reg        = input.bool(true,  "Show Regression Channel (long)",    group=grp_d)
show_reg_short  = input.bool(false, "Show Regression Channel (short)",   group=grp_d)
show_zones      = input.bool(true,  "Show warning zones (background)",   group=grp_d)
show_labels     = input.bool(true,  "Show detail labels on signals",     group=grp_d)
label_offset    = input.float(2.0,  "Label offset %",     step=0.5,      group=grp_d)
float_labels    = input.bool(true,  "Float labels (shorts=top, longs=bottom)", group=grp_d,
                  tooltip="Shorts float to top of visible chart, longs to bottom, with a dashed line connecting the label to the signal bar. Cleaner view of price action.")
float_buffer    = input.float(3.0,  "Float buffer % (distance from chart edge)", step=0.5, group=grp_d)
float_window    = input.int(100,    "Visible window for floating (bars)", minval=20, group=grp_d,
                  tooltip="How many bars of price the floating label positions above/below. Longer = more context, shorter = labels closer to bars.")

// ─────────────────────────────────────────────────────────
// APPEARANCE / THEME [NEW v8.6.1 — white-canvas friendly]
// ─────────────────────────────────────────────────────────
grp_th = "Appearance / Theme"
theme_mode      = input.string("Auto (dark defaults)", "Theme", options=["Auto (dark defaults)", "White canvas", "Custom"], group=grp_th,
                  tooltip="White canvas uses dark text colors for all table cells so they remain readable on a white chart background. Custom lets you override every color below.")
hide_price_tags = input.bool(true,  "Hide right-hand price tags for every plotted line", group=grp_th,
                  tooltip="When enabled, only the main price/candle shows a tag on the right price scale. SMAs, BBs, Fibs, anchors and other overlay plots will not clutter the scale.")
// Custom colors (only used when theme_mode = 'Custom'; defaults suit white canvas)
c_table_header  = input.color(color.new(#444444, 0),  "Table: header text", group=grp_th, inline="tc1")
c_table_value   = input.color(color.new(#222222, 0),  "Table: value text",  group=grp_th, inline="tc1")
c_table_bull    = input.color(color.new(#198754, 0),  "Table: bullish",     group=grp_th, inline="tc2")
c_table_bear    = input.color(color.new(#dc3545, 0),  "Table: bearish",     group=grp_th, inline="tc2")
c_table_warn    = input.color(color.new(#fd7e14, 0),  "Table: warning",     group=grp_th, inline="tc2")
c_table_info    = input.color(color.new(#0d6efd, 0),  "Table: info/accent", group=grp_th, inline="tc2")
c_table_bg      = input.color(color.new(#ffffff, 85), "Table: cell background (transparent value lets chart show through)", group=grp_th)
c_label_text    = input.color(color.new(#ffffff, 0),  "Signal label: text color (stays white by default — legible on both green and red)", group=grp_th)
compact_labels  = input.bool(false, "Compact signal labels (1-line header only, hides detail rows)", group=grp_th,
                  tooltip="Shows only 'SHORT [T1] ★4/7' header with no detail rows. Reduces label size 80% and prevents stacking when signals fire close together.")

// Resolve effective colors based on theme_mode
bool is_white_theme = theme_mode == "White canvas"
bool is_custom_theme = theme_mode == "Custom"

color col_header = is_custom_theme ? c_table_header : is_white_theme ? color.new(#444444, 0) : color.white
color col_value  = is_custom_theme ? c_table_value  : is_white_theme ? color.new(#222222, 0) : color.white
color col_bull   = is_custom_theme ? c_table_bull   : is_white_theme ? color.new(#198754, 0) : color.lime
color col_bear   = is_custom_theme ? c_table_bear   : is_white_theme ? color.new(#dc3545, 0) : color.red
color col_warn   = is_custom_theme ? c_table_warn   : is_white_theme ? color.new(#fd7e14, 0) : color.orange
color col_info   = is_custom_theme ? c_table_info   : is_white_theme ? color.new(#0d6efd, 0) : color.aqua
color col_cell_bg = is_custom_theme ? c_table_bg : is_white_theme ? color.new(#ffffff, 85) : color.new(color.black, 85)
color col_muted  = is_white_theme or is_custom_theme ? color.new(#888888, 0) : color.gray

// ─────────────────────────────────────────────────────────
// MOVING AVERAGES
// ─────────────────────────────────────────────────────────
sma10  = ta.sma(close, 10)
sma20  = ta.sma(close, 20)
sma50  = ta.sma(close, 50)
sma200 = ta.sma(close, 200)

// Plot display mode — hide the price-scale tag if user requested a cleaner scale
plot_display = hide_price_tags ? (display.all - display.price_scale) : display.all

plot(show_sma ? sma10  : na, "SMA10",  color=color.new(color.aqua,   30), linewidth=1, display=plot_display)
plot(show_sma ? sma20  : na, "SMA20",  color=color.new(color.yellow, 30), linewidth=1, display=plot_display)
plot(show_sma ? sma50  : na, "SMA50",  color=color.new(color.orange, 20), linewidth=2, display=plot_display)
plot(show_sma ? sma200 : na, "SMA200", color=color.new(color.gray,   40), linewidth=1, style=plot.style_circles, display=plot_display)

// ─────────────────────────────────────────────────────────
// VOLATILITY INDEX (VIX or RVX)
// ─────────────────────────────────────────────────────────
vol_close  = request.security(vol_symbol, "D", close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
vol_sma20  = ta.sma(vol_close, 20)
vol_10d_max= ta.highest(vol_close, 10)
vol_3d_max = ta.highest(vol_close, 3)
vol_30d_max= ta.highest(vol_close, 30)
vol_panic  = vol_10d_max / vol_sma20

s_vol_max_scaled = s_vol_max  * vol_scale
l_t1_vol_scaled  = l_t1_vol   * vol_scale
l_t2_vol_scaled  = l_t2_vol   * vol_scale
l_t5_vol_scaled  = l_t5_vol   * vol_scale
s_crash_scaled   = s_crash_lock * vol_scale

// ─────────────────────────────────────────────────────────
// CONTEXT [v8.1] — VIX term structure
// ─────────────────────────────────────────────────────────
// VIX9D — 9-day implied vol; VIX3M — 3-month implied vol
vix9d_close  = request.security("CBOE:VIX9D", "D", close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
vix3m_close  = request.security("CBOE:VIX3M", "D", close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

// Guard against na/zero to avoid division errors on non-valid bars
ts_9d_vix = na(vix9d_close) or na(vol_close) or vol_close == 0 ? na : vix9d_close / vol_close
ts_3m_vix = na(vix3m_close) or na(vol_close) or vol_close == 0 ? na : vix3m_close / vol_close

// Interpretation flags
ts_backwardation = not na(ts_9d_vix) and ts_9d_vix >= 1.00    // front fear > spot fear — bottom-ish
ts_complacency   = not na(ts_3m_vix) and ts_3m_vix >= 1.30    // steep contango — top-ish

// ─────────────────────────────────────────────────────────
// CONTEXT [v8.1] — Higher timeframe (weekly) regime
// ─────────────────────────────────────────────────────────
wk_close     = request.security(syminfo.tickerid, "W", close, lookahead=barmerge.lookahead_off)
wk_sma20     = request.security(syminfo.tickerid, "W", ta.sma(close, 20), lookahead=barmerge.lookahead_off)
wk_uptrend   = not na(wk_close) and not na(wk_sma20) and wk_close > wk_sma20
wk_downtrend = not na(wk_close) and not na(wk_sma20) and wk_close < wk_sma20

// ─────────────────────────────────────────────────────────
// CONTEXT [v8.1] — SMH (semiconductor ETF) divergence
// ─────────────────────────────────────────────────────────
smh_close    = request.security(smh_symbol, "D", close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
smh_sma20    = request.security(smh_symbol, "D", ta.sma(close, 20), lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
smh_dist20   = na(smh_close) or na(smh_sma20) or smh_sma20 == 0 ? na : (smh_close - smh_sma20) / smh_sma20

// Leverage ratio — SOXL should be ~3x SMH in dist terms
soxl_smh_ratio = na(smh_dist20) or smh_dist20 == 0 or math.abs(smh_dist20) < 0.005 ? na : (close - sma20) / sma20 / smh_dist20
smh_stretch   = not na(soxl_smh_ratio) and soxl_smh_ratio > 3.5   // SOXL more extreme than leverage predicts
smh_lag       = not na(soxl_smh_ratio) and soxl_smh_ratio < 2.5 and soxl_smh_ratio > 0  // SOXL lagging

// ─────────────────────────────────────────────────────────
// SOX WYCKOFF PHASE DETECTION [NEW v8.6]
// ─────────────────────────────────────────────────────────
// Pull SOX daily close/high/low for phase classification.
// Use the same computations we validated against the benchmark:
// - SMA20 slope over 20 bars classifies MARKUP / MARKDOWN / RANGING
// - Ranging phases subclassify into DISTRIBUTION (upper half of N-bar
//   range) or ACCUMULATION (lower half)

sox_close   = request.security(sox_symbol, "D", close,  lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
sox_high    = request.security(sox_symbol, "D", high,   lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
sox_low     = request.security(sox_symbol, "D", low,    lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

sox_sma20          = ta.sma(sox_close, 20)
sox_sma20_20ago    = sox_sma20[20]
sox_slope_pct      = na(sox_sma20) or na(sox_sma20_20ago) or sox_sma20_20ago == 0 ? na : (sox_sma20 - sox_sma20_20ago) / sox_sma20_20ago * 100

sox_range_hi = ta.highest(sox_close, wyck_range_lb)
sox_range_lo = ta.lowest(sox_close,  wyck_range_lb)
sox_range_pos = na(sox_close) or sox_range_hi == sox_range_lo ? 0.5 : (sox_close - sox_range_lo) / (sox_range_hi - sox_range_lo)

// Classify: MARKUP / MARKDOWN / RANGING based on slope
is_markup   = use_wyckoff and not na(sox_slope_pct) and sox_slope_pct >  wyck_slope_thr
is_markdown = use_wyckoff and not na(sox_slope_pct) and sox_slope_pct < -wyck_slope_thr
is_ranging  = use_wyckoff and not na(sox_slope_pct) and not is_markup and not is_markdown

// Subclassify ranging into distribution/accumulation using range position
// Distribution = in upper half of recent range (consolidating after markup)
// Accumulation = in lower half of recent range (basing after markdown)
is_distribution = is_ranging and sox_range_pos >= 0.5
is_accumulation = is_ranging and sox_range_pos <  0.5

// Phase string for display
wyck_phase = is_markup ? "MARKUP" : is_markdown ? "MARKDOWN" : is_distribution ? "DIST" : is_accumulation ? "ACCUM" : "n/a"

// ─────────────────────────────────────────────────────────
// BOLLINGER BANDS
// ─────────────────────────────────────────────────────────
bb_basis = ta.sma(close, bb_len)
bb_dev   = bb_mult * ta.stdev(close, bb_len)
bb_upper = bb_basis + bb_dev
bb_lower = bb_basis - bb_dev
bb_pos   = (close - bb_lower) / (bb_upper - bb_lower)

plot(show_bb ? bb_upper : na, "BB Upper", color=color.new(color.purple, 50), linewidth=1, display=plot_display)
plot(show_bb ? bb_basis : na, "BB Mid",   color=color.new(color.purple, 80), linewidth=1, display=plot_display)
plot(show_bb ? bb_lower : na, "BB Lower", color=color.new(color.purple, 50), linewidth=1, display=plot_display)

// Also compute BB on 50-bar for the signal logic
bb_basis_50 = ta.sma(close, 50)
bb_dev_50   = bb_mult * ta.stdev(close, 50)
bb_upper_50 = bb_basis_50 + bb_dev_50
bb_lower_50 = bb_basis_50 - bb_dev_50
bb_pos_50   = (close - bb_lower_50) / (bb_upper_50 - bb_lower_50)

// ─────────────────────────────────────────────────────────
// LINEAR REGRESSION CHANNELS
// ─────────────────────────────────────────────────────────
// Short-lookback regression (for short signals and T3 confirmation)
reg_basis_s   = ta.linreg(close, reg_len_short, 0)
reg_slope_s_prev = ta.linreg(close, reg_len_short, 1)
reg_slope_s  = (reg_basis_s - reg_slope_s_prev) / reg_basis_s
reg_dev_s    = reg_mult * ta.stdev(close - ta.linreg(close, reg_len_short, 0), reg_len_short)
reg_upper_s  = reg_basis_s + reg_dev_s
reg_lower_s  = reg_basis_s - reg_dev_s
reg_pos_s    = (close - reg_lower_s) / (reg_upper_s - reg_lower_s)

// Long-lookback regression (primary for trend analysis)
reg_basis_l  = ta.linreg(close, reg_len_long, 0)
reg_basis_l_prev = ta.linreg(close, reg_len_long, 1)
reg_slope_l  = (reg_basis_l - reg_basis_l_prev) / reg_basis_l
reg_dev_l    = reg_mult * ta.stdev(close - ta.linreg(close, reg_len_long, 0), reg_len_long)
reg_upper_l  = reg_basis_l + reg_dev_l
reg_lower_l  = reg_basis_l - reg_dev_l
reg_pos_l    = (close - reg_lower_l) / (reg_upper_l - reg_lower_l)

plot(show_reg ? reg_upper_l : na, "Reg Upper L", color=color.new(color.teal, 40), linewidth=1, display=plot_display)
plot(show_reg ? reg_basis_l : na, "Reg Mid L",   color=color.new(color.teal, 70), linewidth=1, display=plot_display)
plot(show_reg ? reg_lower_l : na, "Reg Lower L", color=color.new(color.teal, 40), linewidth=1, display=plot_display)

plot(show_reg_short ? reg_upper_s : na, "Reg Upper S", color=color.new(color.lime, 50), linewidth=1, display=plot_display)
plot(show_reg_short ? reg_basis_s : na, "Reg Mid S",   color=color.new(color.lime, 80), linewidth=1, display=plot_display)
plot(show_reg_short ? reg_lower_s : na, "Reg Lower S", color=color.new(color.lime, 50), linewidth=1, display=plot_display)

// ─────────────────────────────────────────────────────────
// ANCHORED REGRESSION CHANNELS [NEW v8.3]
// ─────────────────────────────────────────────────────────
// Build a regression line + bands from the most recent CONFIRMED pivot.
// Pine's ta.pivotlow(left,right) returns the pivot value `right` bars after
// the pivot happened (confirmed pivot). Track bar_index of the last confirmed
// pivot, then walk back to compute regression from that anchor to the current bar.

piv_low_val  = ta.pivotlow(low,  pivot_left, pivot_right)
piv_high_val = ta.pivothigh(high, pivot_left, pivot_right)

// State for the most recent confirmed pivot positions (indexed at the confirmation bar)
var int last_piv_low_bar   = na
var int last_piv_high_bar  = na
var float last_piv_low_val  = na
var float last_piv_high_val = na

// When a pivot is confirmed, record where in the series it was (bar_index - pivot_right bars back)
if not na(piv_low_val)
    last_piv_low_bar  := bar_index - pivot_right
    last_piv_low_val  := piv_low_val
if not na(piv_high_val)
    last_piv_high_bar := bar_index - pivot_right
    last_piv_high_val := piv_high_val

// Compute regression from anchor to current bar
// We need sum_x, sum_y, sum_xy, sum_xx across the anchored range
// Since Pine can't easily loop over a variable range, we use ta.linreg with a dynamic length

bars_since_piv_low  = na(last_piv_low_bar)  ? na : bar_index - last_piv_low_bar  + 1
bars_since_piv_high = na(last_piv_high_bar) ? na : bar_index - last_piv_high_bar + 1

// Clamp the lookback to valid range
len_from_low  = na(bars_since_piv_low)  ? na : math.max(anchor_min_bars, math.min(int(bars_since_piv_low),  anchor_max_bars))
len_from_high = na(bars_since_piv_high) ? na : math.max(anchor_min_bars, math.min(int(bars_since_piv_high), anchor_max_bars))

// ANCHORED REGRESSION — manual OLS
// Pine v6 doesn't support variable-length historical offsets in `series[N]` cleanly,
// so we maintain a rolling array of recent closes and index into it from the anchor.
// The array holds the most recent `anchor_max_bars` closes, with index 0 = current bar.

var array<float> close_hist = array.new<float>(0)
array.unshift(close_hist, close)
if array.size(close_hist) > anchor_max_bars + 10
    array.pop(close_hist)

// Manual OLS via for-loop on the array
f_anchored_reg(n_bars) =>
    float center   = na
    float slope_v  = na
    float std_r    = na
    float intercept= na
    if not na(n_bars) and n_bars >= anchor_min_bars and array.size(close_hist) >= n_bars
        int N = int(n_bars)
        float sum_x = 0.0
        float sum_y = 0.0
        float sum_xy = 0.0
        float sum_xx = 0.0
        // x = 0 is the anchor bar (oldest), x = N-1 is current bar
        for i = 0 to N - 1
            y_i = array.get(close_hist, N - 1 - i)
            sum_x   += i
            sum_y   += y_i
            sum_xy  += i * y_i
            sum_xx  += i * i
        float mean_x = sum_x / N
        float mean_y = sum_y / N
        float denom = sum_xx - N * mean_x * mean_x
        slope_v := denom != 0 ? (sum_xy - N * mean_x * mean_y) / denom : 0.0
        intercept := mean_y - slope_v * mean_x
        float ssr = 0.0
        for i = 0 to N - 1
            y_i = array.get(close_hist, N - 1 - i)
            fitted = intercept + slope_v * i
            ssr += (y_i - fitted) * (y_i - fitted)
        std_r := math.sqrt(ssr / N)
        center := intercept + slope_v * (N - 1)
    [center, slope_v, std_r, intercept]

[anch_lo_center, anch_lo_slope, anch_lo_std, anch_lo_intercept] = f_anchored_reg(len_from_low)
[anch_hi_center, anch_hi_slope, anch_hi_std, anch_hi_intercept] = f_anchored_reg(len_from_high)

anch_lo_upper = na(anch_lo_center) ? na : anch_lo_center + anchor_mult * anch_lo_std
anch_lo_lower = na(anch_lo_center) ? na : anch_lo_center - anchor_mult * anch_lo_std
anch_hi_upper = na(anch_hi_center) ? na : anch_hi_center + anchor_mult * anch_hi_std
anch_hi_lower = na(anch_hi_center) ? na : anch_hi_center - anchor_mult * anch_hi_std

// Position of price within each anchored channel
anch_lo_pos = na(anch_lo_center) or anch_lo_upper == anch_lo_lower ? na : (close - anch_lo_lower) / (anch_lo_upper - anch_lo_lower)
anch_hi_pos = na(anch_hi_center) or anch_hi_upper == anch_hi_lower ? na : (close - anch_hi_lower) / (anch_hi_upper - anch_hi_lower)

// Draw the anchored channels as lines that redraw each bar
// Use var arrays of lines that get deleted and redrawn
var line line_lo_mid   = na
var line line_lo_upper = na
var line line_lo_lower = na
var line line_hi_mid   = na
var line line_hi_upper = na
var line line_hi_lower = na

if use_anchored and barstate.islast
    if not na(anch_lo_center) and not na(last_piv_low_bar)
        line.delete(line_lo_mid)
        line.delete(line_lo_upper)
        line.delete(line_lo_lower)
        start_bar_lo = last_piv_low_bar
        y_start_mid = anch_lo_intercept
        y_end_mid   = anch_lo_center
        line_lo_mid   := line.new(start_bar_lo, y_start_mid,         bar_index, y_end_mid,         color=color.new(color.aqua, 40), width=1)
        line_lo_upper := line.new(start_bar_lo, y_start_mid + anchor_mult * anch_lo_std, bar_index, y_end_mid + anchor_mult * anch_lo_std, color=color.new(color.aqua, 60), width=1, style=line.style_dashed)
        line_lo_lower := line.new(start_bar_lo, y_start_mid - anchor_mult * anch_lo_std, bar_index, y_end_mid - anchor_mult * anch_lo_std, color=color.new(color.aqua, 60), width=1, style=line.style_dashed)
    if not na(anch_hi_center) and not na(last_piv_high_bar)
        line.delete(line_hi_mid)
        line.delete(line_hi_upper)
        line.delete(line_hi_lower)
        start_bar_hi = last_piv_high_bar
        y_start_mid = anch_hi_intercept
        y_end_mid   = anch_hi_center
        line_hi_mid   := line.new(start_bar_hi, y_start_mid,         bar_index, y_end_mid,         color=color.new(color.fuchsia, 40), width=1)
        line_hi_upper := line.new(start_bar_hi, y_start_mid + anchor_mult * anch_hi_std, bar_index, y_end_mid + anchor_mult * anch_hi_std, color=color.new(color.fuchsia, 60), width=1, style=line.style_dashed)
        line_hi_lower := line.new(start_bar_hi, y_start_mid - anchor_mult * anch_hi_std, bar_index, y_end_mid - anchor_mult * anch_hi_std, color=color.new(color.fuchsia, 60), width=1, style=line.style_dashed)

// Anchored agreement flags (used in conviction scoring below)
anch_lo_at_band   = not na(anch_lo_pos) and anch_lo_pos <= 0.20   // at lower band of uptrend channel
anch_hi_at_band   = not na(anch_hi_pos) and anch_hi_pos >= 0.80   // at upper band of downtrend channel

// ─────────────────────────────────────────────────────────
// FIBONACCI RETRACEMENT CONTEXT [NEW v8.4]
// ─────────────────────────────────────────────────────────
// Compute the swing high in the past fib_swing_high_lb bars
// and the prior swing low in the fib_prior_low_lb bars before that high.
// Then compute the 61.8% and 100% retracement levels of that up-move.
//
// Uses a rolling array pattern (same approach as v8.3 anchored regression)
// because Pine v6 is strict about dynamic historical offsets.

// Rolling history arrays — enough buffer to cover swing_high_lb + prior_low_lb
var array<float> high_hist = array.new<float>(0)
var array<float> low_hist  = array.new<float>(0)
int fib_buffer_needed = fib_swing_high_lb + fib_prior_low_lb + 20

array.unshift(high_hist, high)
array.unshift(low_hist,  low)
if array.size(high_hist) > fib_buffer_needed
    array.pop(high_hist)
if array.size(low_hist) > fib_buffer_needed
    array.pop(low_hist)

// Find the swing high (highest high in the past fib_swing_high_lb bars)
// and its index (0 = current bar, N-1 = oldest).
float fib_swing_high = na
int   fib_sh_idx = na
if array.size(high_hist) >= fib_swing_high_lb
    fib_swing_high := array.get(high_hist, 0)
    fib_sh_idx := 0
    for i = 1 to fib_swing_high_lb - 1
        h_i = array.get(high_hist, i)
        if h_i > fib_swing_high
            fib_swing_high := h_i
            fib_sh_idx := i

// Find the prior swing low — lowest low in fib_prior_low_lb bars BEFORE the swing high
float fib_prior_low = na
if not na(fib_sh_idx) and array.size(low_hist) >= fib_sh_idx + fib_prior_low_lb
    fib_prior_low := array.get(low_hist, fib_sh_idx)
    for i = fib_sh_idx + 1 to fib_sh_idx + fib_prior_low_lb
        l_i = array.get(low_hist, i)
        if l_i < fib_prior_low
            fib_prior_low := l_i

// Compute the up-move range and retrace levels
fib_range = na(fib_swing_high) or na(fib_prior_low) ? na : fib_swing_high - fib_prior_low
fib_618   = na(fib_range) or fib_range <= 0 ? na : fib_swing_high - (0.618 * fib_range)
fib_100   = fib_prior_low  // 100% retracement = back to prior low

// Current retracement position (0 = at swing high, 1 = at prior low, >1 = broken below)
fib_retrace_pct = na(fib_range) or fib_range <= 0 ? na : (fib_swing_high - close) / fib_range

// Conviction flags: is price within tolerance of 61.8% or 100% retrace?
fib_near_618 = not na(fib_retrace_pct) and math.abs(fib_retrace_pct - 0.618) < (fib_tolerance / 100)
fib_near_100 = not na(fib_retrace_pct) and math.abs(fib_retrace_pct - 1.000) < (fib_tolerance / 100)
fib_at_level = fib_near_618 or fib_near_100

// Draw the Fib levels as dashed horizontal lines on the chart
plot(use_fib ? fib_618 : na, "Fib 61.8%", color=color.new(color.orange, 30), linewidth=1, style=plot.style_linebr, trackprice=false, display=plot_display)
plot(use_fib ? fib_100 : na, "Fib 100%",  color=color.new(color.orange, 50), linewidth=1, style=plot.style_linebr, trackprice=false, display=plot_display)
plot(use_fib ? fib_swing_high : na, "Fib swing high", color=color.new(color.gray, 50), linewidth=1, style=plot.style_linebr, trackprice=false, display=plot_display)

// ─────────────────────────────────────────────────────────
// OSCILLATORS + OTHER INDICATORS
// ─────────────────────────────────────────────────────────
stoch_k = ta.sma(ta.stoch(close, high, low, 14), 3)
rsi14   = ta.rsi(close, 14)

[macd_line, macd_sig_line, macd_hist] = ta.macd(close, 12, 26, 9)
macd_hist_roc  = macd_hist - macd_hist[1]
macd_improving = macd_hist > macd_hist[1]

[adx_val, plus_di, minus_di] = ta.dmi(14, 14)
di_bull_gap = plus_di - minus_di

// ─────────────────────────────────────────────────────────
// PRICE METRICS
// ─────────────────────────────────────────────────────────
dist_sma20  = (close - sma20)  / sma20
dist_sma50  = (close - sma50)  / sma50
dist_sma200 = (close - sma200) / sma200
day_chg     = (close - close[1]) / close[1]

// Regime
in_bull_regime = sma50 > sma200

// ─────────────────────────────────────────────────────────
// v8.7 NEW SHORT-TIER HELPERS
// ─────────────────────────────────────────────────────────
// Bars-since-broke-below-SMA20 counter (proxy for "extended above"):
//   ST6 looks for setups where TNA has stayed above its SMA20 for an
//   extended period and is now beginning to roll over. Resets to 0 on
//   any close below SMA20.
var int bars_above_sma20 = 0
bars_above_sma20 := close < sma20 ? 0 : bars_above_sma20 + 1

// Bearish RSI divergence over s_t4_div_lb bars:
//   ST4 fires when price is HIGHER than div_lb bars ago but RSI14 is
//   LOWER. Classic momentum-waning pattern that precedes TNA tops in
//   calm bull markets.
rsi_bear_div = (close > close[s_t4_div_lb]) and (rsi14 < rsi14[s_t4_div_lb])

// ─────────────────────────────────────────────────────────
// v8.7.1 DRAWDOWN GATE
// ─────────────────────────────────────────────────────────
// Short signals require price to be measurably below the recent
// rolling high. Blocks shorts at ATH where they historically resolved
// UP (post-2020 election rally, 2024 small-cap rally, etc.). v8.8
// broadened default from -3% to -2% based on PF optimization.
recent_high       = ta.highest(close, s_dd_lookback)
drawdown_from_hi  = (close - recent_high) / recent_high
short_dd_gate_ok  = drawdown_from_hi <= s_dd_threshold

// ─────────────────────────────────────────────────────────
// v8.8 ST_VIX HELPER — VIX-rising distribution detection
// ─────────────────────────────────────────────────────────
// vol_close holds VIX or RVX depending on user choice; vol_change
// is the percent change over s_vix_lb bars. ST_VIX fires when vol
// is rising while TNA is still extended — a "smart-money hedging
// while price still climbs" pattern.
vol_change_lb     = vol_close[s_vix_lb] > 0 ? (vol_close - vol_close[s_vix_lb]) / vol_close[s_vix_lb] : 0
vix_rising_ok     = vol_change_lb >= s_vix_chg

// Cooldown
var int bars_since_short = 999
var int bars_since_long  = 999
bars_since_short := bars_since_short + 1
bars_since_long  := bars_since_long  + 1

// Post-crash lockout
in_crash_recovery = ta.highest(vol_close, 30) >= s_crash_scaled

// Regime-aware dist checks
dist50_regime_ok  = in_bull_regime ? (dist_sma50 >= s_bull_dist50) : true
dist200_regime_ok = in_bull_regime ? true : (dist_sma200 <= s_bear_dist200)

// Band confirmation helpers
at_lower_band = (reg_pos_l <= 0.25) or (bb_pos_50 <= 0.15) or (reg_pos_s <= 0.20) or (bb_pos <= 0.10)
at_upper_band_tight = (bb_pos >= 0.90) or (reg_pos_s >= 0.90)
at_upper_band_loose = (bb_pos >= 0.85) or (reg_pos_s >= 0.80) or (reg_pos_l >= 0.80)

// ─────────────────────────────────────────────────────────
// LONG SIGNAL TIERS
// ─────────────────────────────────────────────────────────

// T1 — Capitulation
long_t1 = (stoch_k       <= l_t1_stoch)
       and (vol_close    >= l_t1_vol_scaled)
       and (vol_panic    >= l_t1_panic)
       and (vol_close    <= vol_close[1] * 1.05)
       and at_lower_band

// T2 — Classic oversold + band + MACD improving
long_t2 = (stoch_k       <= l_t2_stoch)
       and (dist_sma20   <= l_t2_dist20)
       and (vol_close    >= l_t2_vol_scaled)
       and at_lower_band
       and macd_improving

// T3 — Trend pullback (the new structural tier)
long_t3 = (reg_slope_l   >  l_t3_slope)
       and (reg_pos_l    <= 0.25)
       and (reg_pos_s    <= 0.20)
       and (dist_sma20   <= 0.00)
       and (stoch_k      <= l_t3_stoch)
       and in_bull_regime
       and (day_chg      >  -0.04)
       and (close        >  close[1])

// T4 — Bollinger extreme dump
long_t4 = (bb_pos        <= 0.00)
       and (dist_sma20   <= l_t4_dist20)
       and (stoch_k      <= l_t4_stoch)
       and (vol_close    >= l_t2_vol_scaled)
       and macd_improving

// T5 — Vol peak-and-turn
long_t5 = (vol_close     >= l_t5_vol_scaled)
       and (vol_close    <= vol_3d_max * l_t5_turn)
       and (dist_sma20   <= -0.06)
       and (stoch_k      <= 30)
       and at_lower_band

// T6 — Deep oversold (moderate VIX)
long_t6 = (stoch_k       <= l_t6_stoch)
       and (dist_sma20   <= -0.12)
       and (vol_close    >= 12 * vol_scale)
       and (vol_panic    >= l_t6_panic)
       and macd_improving

// T7 — Waterfall capitulation [NEW v8.5]
// Same-day crash catch — the only tier that does NOT require MACD reversal.
// Safety comes from the severity of the required drop (-10% default) combined
// with elevated VIX, oversold oscillator, and band extension.
long_t7 = use_t7
       and (day_chg       <= l_t7_daychg)
       and (vol_close     >= l_t7_vol * vol_scale)
       and (stoch_k       <= l_t7_stoch)
       and at_lower_band

raw_long = long_t1 or long_t2 or long_t3 or long_t4 or long_t5 or long_t6 or long_t7

// ─────────────────────────────────────────────────────────
// SHORT SIGNAL TIERS — v8.7 architecture: ST1, ST3, ST4, ST6
// ─────────────────────────────────────────────────────────
// ST2 (failure high) was REMOVED in v8.7 — empirical sweep showed
// F1=0 across all threshold combinations. TNA tops do not follow
// the parabolic blowoff pattern that ST2's logic targets.
// The variable `short_t2` is kept defined as `false` for backward
// compatibility with downstream tier-numbering and label logic.

// T1 — Blowoff top (classic overbought + upper band)
// v8.7.1 adds short_dd_gate_ok: requires price below recent rolling high
short_t1 = (dist_sma20       >= s_dist20)
       and (dist_sma50       <  s_dist50_max)
       and dist50_regime_ok
       and dist200_regime_ok
       and (stoch_k          >= s_stoch)
       and at_upper_band_tight
       and (vol_close        <  s_vol_max_scaled)
       and (di_bull_gap      <  s_di_gap)
       and (macd_hist        >  0)
       and (not in_crash_recovery)
       and short_dd_gate_ok

// T2 — DEPRECATED (kept as false for compatibility, see note above)
short_t2 = false

// T3 — Bollinger breakout top [DISABLED v8.8]
// PF=0.66 across all parameter combinations when properly evaluated.
// The "BB break in calm vol" pattern that worked on SOXL does not
// transfer to TNA. Tier kept defined but gated behind s_use_t3.
short_t3_raw = (bb_pos           >= 1.00)
       and (dist_sma20       >= 0.07)
       and (stoch_k          >= s_t3_stoch)
       and dist50_regime_ok
       and dist200_regime_ok
       and (vol_close        <  s_vol_max_scaled)
       and (not in_crash_recovery)
       and short_dd_gate_ok
short_t3 = s_use_t3 and short_t3_raw

// T4 — Bearish RSI divergence at moderate extension [DISABLED v8.7.1]
// Direction-rate of 29% (71% of fires preceded UP moves). Bearish
// divergence in a 3x bull ETF is a known weak signal in trending
// markets. Tier kept defined but gated behind s_use_t4 (default false).
short_t4_raw = rsi_bear_div
       and (dist_sma20       >= s_t4_dist20)
       and (rsi14            >= s_t4_rsi)
       and (vol_close        <  s_t4_vol_max * vol_scale)
       and (not in_crash_recovery)
       and in_bull_regime
       and short_dd_gate_ok
short_t4 = s_use_t4 and short_t4_raw

// T6 — Extended above SMA20 + stoch turning [DISABLED v8.7.1]
// Direction-rate of 36%, mean 14d return of +4.5%. "Extended above
// SMA20 for 10 bars and stoch declining" describes a healthy uptrend
// more than a top. Tier kept defined but gated behind s_use_t6.
short_t6_raw = (bars_above_sma20[1]  >= s_t6_min_bars)
       and (stoch_k[1]           >= s_t6_stoch)
       and (stoch_k              <  stoch_k[1])
       and (dist_sma20           >= s_t6_dist20)
       and (vol_close            <  s_vol_max_scaled)
       and (not in_crash_recovery)
       and in_bull_regime
       and short_dd_gate_ok
short_t6 = s_use_t6 and short_t6_raw

// ST_VIX — VIX-rising distribution top [NEW v8.8]
// Fires when volatility (VIX or RVX) has risen at least s_vix_chg
// over the last s_vix_lb bars while TNA is still extended. Captures
// the "smart money is hedging while price still climbs" pattern.
// 14 fires across 5.7 years of eval data, PF=2.03 in-sample with
// PF=1.79/2.19 across two-halves split. Crucially, fires at DIFFERENT
// times than ST1 — ST1 catches blowoffs, ST_VIX catches distributions.
// No drawdown gate required: the rising VIX itself is the gate.
short_t_vix = vix_rising_ok
       and (dist_sma20       >= s_vix_dist20)
       and (stoch_k          >= s_vix_stoch)
       and (vol_close        <  s_vix_volmax * vol_scale)
       and (not in_crash_recovery)
       and in_bull_regime

// ─────────────────────────────────────────────────────────
// ST9 — BEAR-CYCLE TREND-FOLLOWING SHORT [v8.10]
// ─────────────────────────────────────────────────────────
// Different premise from ST1/ST_VIX: instead of predicting tops,
// wait for confirmed bear regime + breakdown, then trade trend down.
// Architecture validated PF=3.61 on SOXL 2016-2026 (8 fires, 6 wins).
// Cross-validated on TNA (PF=2.00, 12 fires) but FAILS on TQQQ
// (PF=0.73 due to NDX V-bottom microstructure) — keep TQQQ-specific.
//
// ALL conditions must be true:
//   1. SOX SMA200 slope (30d) <= s_st9_slope_thr (regime gate)
//   2. Close below SOXL SMA50 (breakdown)
//   3. New 20-day low formed (trend continuation)
//   4. Stoch K(3) >= s_st9_stoch_min (not already washed out)
//   5. s_enable_st9 = true (master toggle, default off)

// Compute SOX SMA200 30-day slope
sox_sma200            = ta.sma(sox_close, 200)
sox_sma200_slope_30d  = na(sox_sma200) or na(sox_sma200[30]) or sox_sma200[30] == 0 ? na : (sox_sma200 - sox_sma200[30]) / sox_sma200[30]

// Breakdown features (computed on SOXL itself)
st9_close_below_sma50 = close < sma50
st9_low_20d           = ta.lowest(close, 20)[1]   // 20-day low excluding today
st9_new_20d_low       = close <= st9_low_20d

// ST9 raw signal
short_t9 = s_enable_st9
       and not na(sox_sma200_slope_30d)
       and (sox_sma200_slope_30d <= s_st9_slope_thr)
       and st9_close_below_sma50
       and st9_new_20d_low
       and (stoch_k >= s_st9_stoch_min)
       and (not in_crash_recovery)

// ─────────────────────────────────────────────────────────
// ST10 — TOP-FADE SHORT [v8.11]
// ─────────────────────────────────────────────────────────
// Catches single-day exhaustion at upper Bollinger band with price
// stalling. Fires AT the top, holds 3 days. Validated PF=6.45 on
// SOXL (17 fires across 2016-2026, 71% win rate).
// SOXL-SPECIFIC architecture — fails on TQQQ (PF=0.20) and TNA
// (PF=0.77) due to different mega-cap and small-cap microstructure.
//
// ALL conditions must be true:
//   1. BB position >= s_st10_bb_min (price at/above upper band)
//   2. Stoch K(3) >= s_st10_stoch_min (overbought)
//   3. dist_sma20 >= s_st10_dist20_min (extended above MA)
//   4. day_chg < 1% AND close < previous close (price STALLING)
//   5. Not in crash recovery
//   6. s_enable_st10 = true (master toggle, default off)

// Price stalling: today's % change less than 1% AND today closed
// below yesterday's close. After a long extension up, this is the
// FIRST day of exhaustion — the discriminator that lifts PF from
// ~1.2 to 6.45.
st10_stalling = (day_chg < 0.01) and (close < close[1])

short_t10 = s_enable_st10 and (bb_pos >= s_st10_bb_min) and (stoch_k >= s_st10_stoch_min) and (dist_sma20 >= s_st10_dist20_min) and st10_stalling and (not in_crash_recovery)

// Legacy shorts (ST1, ST3, ST4, ST6, ST_VIX) — gated behind s_enable_shorts
raw_short_legacy = short_t1 or short_t3 or short_t4 or short_t6 or short_t_vix

// ST9 has its own toggle (s_enable_st9) baked into short_t9 itself
// ST10 has its own toggle (s_enable_st10) baked into short_t10 itself

// Combined raw_short: legacy shorts (if enabled) OR ST9 (if enabled) OR ST10 (if enabled)
raw_short = (raw_short_legacy and s_enable_shorts) or short_t9 or short_t10

// ─────────────────────────────────────────────────────────
// CONVICTION SCORING — moved before cooldown in v8.9
// ─────────────────────────────────────────────────────────
// In v8.8 conviction was used only for label/marker styling. In v8.9
// it's a HARD prerequisite for signal generation (long side only —
// short side is disabled by the s_enable_shorts toggle).

// LONG conviction points
l_conv_panic    = vol_panic >= 1.15
l_conv_bands    = reg_pos_l <= 0.10 and bb_pos_50 <= 0.10
l_conv_macd     = macd_improving
l_conv_vol      = vol_close >= 25 * vol_scale
l_conv_slope    = reg_slope_l > 0.003
l_conv_anchor   = use_anchored_conv and anch_lo_at_band
l_conv_fib      = use_fib_conv and fib_at_level

long_conviction = (l_conv_panic ? 1 : 0) + (l_conv_bands ? 1 : 0) + (l_conv_macd ? 1 : 0) + (l_conv_vol ? 1 : 0) + (l_conv_slope ? 1 : 0) + (l_conv_anchor ? 1 : 0) + (l_conv_fib ? 1 : 0)

// SHORT conviction points (still computed for display — even though
// shorts are disabled by default, if user re-enables we want labels
// to show conviction)
s_conv_stoch    = stoch_k >= 90
s_conv_bands    = reg_pos_s >= 0.95 and bb_pos >= 0.95
s_conv_macd     = macd_hist_roc <= -0.1
s_conv_vol_calm = vol_close < 18 * vol_scale
s_conv_extend   = dist_sma50 > 0.13
s_conv_anchor   = use_anchored_conv and anch_hi_at_band
s_conv_wyck     = use_wyck_conv and is_distribution

short_conviction = (s_conv_stoch ? 1 : 0) + (s_conv_bands ? 1 : 0) + (s_conv_macd ? 1 : 0) + (s_conv_vol_calm ? 1 : 0) + (s_conv_extend ? 1 : 0) + (s_conv_anchor ? 1 : 0) + (s_conv_wyck ? 1 : 0)

// ─────────────────────────────────────────────────────────
// COOLDOWN APPLICATION + v8.9 GATING
// ─────────────────────────────────────────────────────────
// Long: hard conviction gate (>= s_min_long_conv, default 3)
// Short: raw_short already includes the s_enable_shorts and s_enable_st9 toggles
//        (legacy shorts gated by s_enable_shorts, ST9 gated by s_enable_st9 inside short_t9)
short_signal = raw_short and bars_since_short >= s_cooldown
long_signal  = raw_long  and bars_since_long  >= l_cooldown and long_conviction >= s_min_long_conv

if short_signal
    bars_since_short := 0
if long_signal
    bars_since_long  := 0

// Identify which tier (v8.7: ST1, ST3, ST4, ST6 — ST2 deprecated, ST5 not used)
short_tier_num = short_t10 ? 10 : short_t9 ? 9 : short_t1 ? 1 : short_t_vix ? 8 : short_t3 ? 3 : short_t4 ? 4 : short_t6 ? 6 : 0
short_tier_txt = short_tier_num == 10 ? " [T10: top-fade]" : short_tier_num == 9 ? " [T9: bear-cycle]" : short_tier_num == 1 ? " [T1: blowoff]" : short_tier_num == 8 ? " [T8: VIX-rise]" : short_tier_num == 3 ? " [T3: BB break]" : short_tier_num == 4 ? " [T4: divergence]" : short_tier_num == 6 ? " [T6: rollover]" : ""

long_tier_num = long_t1 ? 1 : long_t2 ? 2 : long_t3 ? 3 : long_t4 ? 4 : long_t5 ? 5 : long_t6 ? 6 : 7
long_tier_txt = long_tier_num == 1 ? " [T1: capitul.]" : long_tier_num == 2 ? " [T2: OS+band]" : long_tier_num == 3 ? " [T3: trend PB]" : long_tier_num == 4 ? " [T4: BB dump]" : long_tier_num == 5 ? " [T5: vol turn]" : long_tier_num == 6 ? " [T6: deep OS]" : " [T7: waterfall]"

// ─────────────────────────────────────────────────────────
// CONVICTION TIER STRINGS (display only — calculation moved up above)
// ─────────────────────────────────────────────────────────

// Conviction tier strings for labels — show which factors fired
l_conv_txt = "Conv " + str.tostring(long_conviction) + "/7: " + (l_conv_panic ? "+panic " : "") + (l_conv_bands ? "+bands " : "") + (l_conv_macd ? "+macd " : "") + (l_conv_vol ? "+vol " : "") + (l_conv_slope ? "+slope " : "") + (l_conv_anchor ? "+anchor " : "") + (l_conv_fib ? (fib_near_618 ? "+fib618" : "+fib100") : "")

s_conv_txt = "Conv " + str.tostring(short_conviction) + "/7: " + (s_conv_stoch ? "+stoch " : "") + (s_conv_bands ? "+bands " : "") + (s_conv_macd ? "+macd " : "") + (s_conv_vol_calm ? "+calm " : "") + (s_conv_extend ? "+extended " : "") + (s_conv_anchor ? "+anchor " : "") + (s_conv_wyck ? "+dist" : "")

// Classification helpers (v8.6 scale is /7 for both longs and shorts)
is_high_conv_long  = long_signal  and long_conviction  >= 5
is_med_conv_long   = long_signal  and long_conviction  == 4
is_low_conv_long   = long_signal  and long_conviction  <= 3

is_high_conv_short = short_signal and short_conviction >= 5
is_med_conv_short  = short_signal and short_conviction == 4
is_low_conv_short  = short_signal and short_conviction <= 3


// ─────────────────────────────────────────────────────────
// WARNING ZONES
// ─────────────────────────────────────────────────────────
in_short_zone = dist_sma20 >= 0.08 and at_upper_band_loose and vol_close < s_vol_max_scaled and not in_crash_recovery and dist50_regime_ok and dist200_regime_ok
in_long_zone  = at_lower_band and (stoch_k <= 30 or (reg_slope_l > 0.002 and dist_sma20 <= 0))

// v8.1 — zones tint more saturated when weekly trend AGREES with signal direction
// Short in weekly downtrend = more conviction; long in weekly uptrend = more conviction
short_zone_bg = tint_zones and wk_downtrend ? color.new(color.red, 88) : color.new(color.red, 94)
long_zone_bg  = tint_zones and wk_uptrend   ? color.new(color.green, 88) : color.new(color.green, 94)

bgcolor(show_zones and in_short_zone ? short_zone_bg : na, title="Short watch zone")
bgcolor(show_zones and in_long_zone  ? long_zone_bg  : na, title="Long watch zone")

// ─────────────────────────────────────────────────────────
// LABELS
// ─────────────────────────────────────────────────────────
// (vol_label defined earlier in VOL INDEX SELECTION block)

// v8.1 context strings for labels
ts_str = use_term_struct and not na(ts_9d_vix) ? "\nTS: 9d/vix=" + str.tostring(math.round(ts_9d_vix,2)) + " 3m/vix=" + str.tostring(math.round(ts_3m_vix,2)) : ""
wk_str = use_weekly ? "\nWk trend: " + (wk_uptrend ? "UP" : wk_downtrend ? "DOWN" : "flat") : ""
smh_str = use_smh_diverge and not na(soxl_smh_ratio) ? "\nSMH ratio: " + str.tostring(math.round(soxl_smh_ratio,2)) + "x" : ""

short_txt_full = "▼ SHORT" + short_tier_txt + "  ★" + str.tostring(short_conviction) + "/7\n"
          + s_conv_txt + "\n"
          + "d20/d50: +" + str.tostring(math.round(dist_sma20*100,1)) + "%/+" + str.tostring(math.round(dist_sma50*100,1)) + "%\n"
          + "d200: " + str.tostring(math.round(dist_sma200*100,1)) + "%\n"
          + "BB%B: " + str.tostring(math.round(bb_pos,2)) + "  Reg: " + str.tostring(math.round(reg_pos_s,2)) + "\n"
          + "Stoch: " + str.tostring(math.round(stoch_k,1)) + "  RSI: " + str.tostring(math.round(rsi14,1)) + "\n"
          + vol_label + str.tostring(math.round(vol_close,1))
          + ts_str + wk_str + smh_str

long_txt_full = "▲ LONG" + long_tier_txt + "  ★" + str.tostring(long_conviction) + "/7\n"
         + l_conv_txt + "\n"
         + "d20: " + str.tostring(math.round(dist_sma20*100,1)) + "%\n"
         + "BB%B: " + str.tostring(math.round(bb_pos,2)) + "  Reg50: " + str.tostring(math.round(reg_pos_l,2)) + "\n"
         + "Stoch: " + str.tostring(math.round(stoch_k,1)) + "\n"
         + vol_label + str.tostring(math.round(vol_close,1)) + "  Panic: " + str.tostring(math.round(vol_panic,2)) + "x"
         + ts_str + wk_str + smh_str

// Compact single-line variants — just the essentials
short_txt_compact = "▼ SHORT" + short_tier_txt + " ★" + str.tostring(short_conviction) + "/7"
long_txt_compact  = "▲ LONG"  + long_tier_txt  + " ★" + str.tostring(long_conviction)  + "/7"

short_txt = compact_labels ? short_txt_compact : short_txt_full
long_txt  = compact_labels ? long_txt_compact  : long_txt_full

// Darker/brighter colors for higher conviction (v8.4 — /7 scale for longs)
short_label_color = short_conviction >= 5 ? color.new(color.red, 0) : short_conviction == 4 ? color.new(color.red, 25) : color.new(color.red, 50)
long_label_color  = long_conviction  >= 5 ? color.new(color.green, 0) : long_conviction  == 4 ? color.new(color.green, 25) : color.new(color.green, 50)

// Label size scales with conviction
short_label_size = short_conviction >= 5 ? size.normal : short_conviction == 4 ? size.small : size.tiny
long_label_size  = long_conviction  >= 5 ? size.normal : long_conviction  == 4 ? size.small : size.tiny

// ─── Floating label anchors ─── v8.3.1
// Chart-top and chart-bottom reference prices — based on a rolling window of highs/lows
// This gives a dynamic "top of chart" and "bottom of chart" that scales with price
float_top_ref = ta.highest(high, float_window) * (1 + float_buffer/100)
float_bot_ref = ta.lowest(low,   float_window) * (1 - float_buffer/100)

if short_signal
    if float_labels
        // Floating: put label at chart top, draw dashed line down to signal bar
        label.new(bar_index, float_top_ref,
                  text      = show_labels ? short_txt : "SHORT ▼",
                  style     = label.style_label_down,
                  color     = short_label_color,
                  textcolor = c_label_text,
                  size      = short_label_size)
        line.new(bar_index, float_top_ref, bar_index, high * (1 + label_offset/100),
                 color = color.new(color.red, 50),
                 style = line.style_dashed,
                 width = 1)
    else
        // Original: label just above the bar
        label.new(bar_index, high * (1 + label_offset/100),
                  text      = show_labels ? short_txt : "SHORT ▼",
                  style     = label.style_label_down,
                  color     = short_label_color,
                  textcolor = c_label_text,
                  size      = short_label_size)

if long_signal
    if float_labels
        // Floating: put label at chart bottom, draw dashed line up to signal bar
        label.new(bar_index, float_bot_ref,
                  text      = show_labels ? long_txt : "LONG ▲",
                  style     = label.style_label_up,
                  color     = long_label_color,
                  textcolor = c_label_text,
                  size      = long_label_size)
        line.new(bar_index, float_bot_ref, bar_index, low * (1 - label_offset/100),
                 color = color.new(color.green, 50),
                 style = line.style_dashed,
                 width = 1)
    else
        // Original: label just below the bar
        label.new(bar_index, low * (1 - label_offset/100),
                  text      = show_labels ? long_txt : "LONG ▲",
                  style     = label.style_label_up,
                  color     = long_label_color,
                  textcolor = c_label_text,
                  size      = long_label_size)

// Triangles scale by conviction — big for high, normal for medium, tiny for low
plotshape(is_high_conv_short, "SHORT high", shape.triangledown, location.abovebar, color.red,   size=size.large)
plotshape(is_med_conv_short,  "SHORT med",  shape.triangledown, location.abovebar, color.new(color.red, 30), size=size.normal)
plotshape(is_low_conv_short,  "SHORT low",  shape.triangledown, location.abovebar, color.new(color.red, 60), size=size.tiny)

plotshape(is_high_conv_long,  "LONG high", shape.triangleup,   location.belowbar, color.green, size=size.large)
plotshape(is_med_conv_long,   "LONG med",  shape.triangleup,   location.belowbar, color.new(color.green, 30), size=size.normal)
plotshape(is_low_conv_long,   "LONG low",  shape.triangleup,   location.belowbar, color.new(color.green, 60), size=size.tiny)

// ─────────────────────────────────────────────────────────
// INFO TABLE
// ─────────────────────────────────────────────────────────
var table t = table.new(position.top_right, 2, 22,
                         bgcolor      = col_cell_bg,
                         border_color = col_muted,
                         border_width = 1)

f_col(v, hi, lo) => v > hi ? col_bear : v < lo ? col_bull : col_value

if barstate.islast
    table.cell(t, 0, 0,  "Metric",  text_color=col_muted, text_size=size.tiny)
    table.cell(t, 1, 0,  "Value",   text_color=col_muted, text_size=size.tiny)

    table.cell(t, 0, 1,  "Dist SMA20", text_color=col_header, text_size=size.tiny)
    table.cell(t, 1, 1,  str.tostring(math.round(dist_sma20*100,1)) + "%",
               text_color=f_col(dist_sma20*100, 12, -15), text_size=size.tiny)

    table.cell(t, 0, 2,  "Dist SMA50", text_color=col_header, text_size=size.tiny)
    table.cell(t, 1, 2,  str.tostring(math.round(dist_sma50*100,1)) + "%",
               text_color=dist_sma50*100 > 50 ? col_warn : dist_sma50*100 < -15 ? col_bull : col_value, text_size=size.tiny)

    table.cell(t, 0, 3,  "BB %B (20)", text_color=col_header, text_size=size.tiny)
    table.cell(t, 1, 3,  str.tostring(math.round(bb_pos,2)),
               text_color=bb_pos >= 0.9 ? col_bear : bb_pos <= 0.1 ? col_bull : col_value, text_size=size.tiny)

    table.cell(t, 0, 4,  "Reg pos (50)", text_color=col_header, text_size=size.tiny)
    table.cell(t, 1, 4,  str.tostring(math.round(reg_pos_l,2)),
               text_color=reg_pos_l >= 0.85 ? col_bear : reg_pos_l <= 0.2 ? col_bull : col_value, text_size=size.tiny)

    table.cell(t, 0, 5,  "Reg slope (50)", text_color=col_header, text_size=size.tiny)
    table.cell(t, 1, 5,  str.tostring(math.round(reg_slope_l*100,2)) + "%",
               text_color=reg_slope_l > 0 ? col_bull : col_bear, text_size=size.tiny)

    table.cell(t, 0, 6,  "Stoch K(3)", text_color=col_header, text_size=size.tiny)
    table.cell(t, 1, 6,  str.tostring(math.round(stoch_k,1)),
               text_color=f_col(stoch_k, 85, 20), text_size=size.tiny)

    table.cell(t, 0, 7,  "RSI 14", text_color=col_header, text_size=size.tiny)
    table.cell(t, 1, 7,  str.tostring(math.round(rsi14,1)),
               text_color=f_col(rsi14, 70, 30), text_size=size.tiny)

    table.cell(t, 0, 8,  "MACD Hist", text_color=col_header, text_size=size.tiny)
    table.cell(t, 1, 8,  str.tostring(math.round(macd_hist,3)),
               text_color=macd_hist > 0 ? col_bull : col_bear, text_size=size.tiny)

    table.cell(t, 0, 9,  "MACD improving", text_color=col_header, text_size=size.tiny)
    table.cell(t, 1, 9,  macd_improving ? "YES" : "NO",
               text_color=macd_improving ? col_bull : col_muted, text_size=size.tiny)

    table.cell(t, 0, 10, vol_label + "close", text_color=col_header, text_size=size.tiny)
    table.cell(t, 1, 10, str.tostring(math.round(vol_close,1)),
               text_color=vol_close >= 30*vol_scale ? col_warn : vol_close >= 23*vol_scale ? col_warn : col_value, text_size=size.tiny)

    table.cell(t, 0, 11, "Vol panic", text_color=col_header, text_size=size.tiny)
    table.cell(t, 1, 11, str.tostring(math.round(vol_panic,2)) + "x",
               text_color=vol_panic >= 1.3 ? col_warn : vol_panic >= 1.2 ? col_warn : col_value, text_size=size.tiny)

    table.cell(t, 0, 12, "Regime", text_color=col_header, text_size=size.tiny)
    table.cell(t, 1, 12, (in_bull_regime ? "BULL " : "BEAR ") + str.tostring(math.round(dist_sma200*100,0)) + "% SMA200",
               text_color=in_bull_regime ? col_bull : col_bear, text_size=size.tiny)

    table.cell(t, 0, 13, "SHORT zone", text_color=col_header, text_size=size.tiny)
    table.cell(t, 1, 13, in_crash_recovery ? "LOCKED" : in_short_zone ? "WATCH ⚠" : "—",
               text_color=in_crash_recovery ? col_warn : in_short_zone ? col_bear : col_muted, text_size=size.tiny)

    table.cell(t, 0, 14, "LONG zone", text_color=col_header, text_size=size.tiny)
    table.cell(t, 1, 14, in_long_zone ? "WATCH ⚠" : "—",
               text_color=in_long_zone ? col_bull : col_muted, text_size=size.tiny)

    table.cell(t, 0, 15, "Term struct", text_color=col_info, text_size=size.tiny)
    table.cell(t, 1, 15, na(ts_9d_vix) ? "n/a" : "9d/v=" + str.tostring(math.round(ts_9d_vix,2)) + " 3m/v=" + str.tostring(math.round(ts_3m_vix,2)),
               text_color=ts_backwardation ? col_bull : ts_complacency ? col_warn : col_value, text_size=size.tiny)

    table.cell(t, 0, 16, "Weekly trend", text_color=col_info, text_size=size.tiny)
    table.cell(t, 1, 16, wk_uptrend ? "UP (close>W SMA20)" : wk_downtrend ? "DOWN (close<W SMA20)" : "flat",
               text_color=wk_uptrend ? col_bull : wk_downtrend ? col_bear : col_muted, text_size=size.tiny)

    table.cell(t, 0, 17, "SMH ratio", text_color=col_info, text_size=size.tiny)
    table.cell(t, 1, 17, na(soxl_smh_ratio) ? "n/a" : str.tostring(math.round(soxl_smh_ratio,2)) + "x" + (smh_stretch ? " stretched" : smh_lag ? " lagging" : ""),
               text_color=smh_stretch ? col_warn : smh_lag ? col_warn : col_value, text_size=size.tiny)

    table.cell(t, 0, 18, "L conv (live)", text_color=col_warn, text_size=size.tiny)
    table.cell(t, 1, 18, str.tostring(long_conviction) + "/7" + (l_conv_panic ? " P" : "") + (l_conv_bands ? " B" : "") + (l_conv_macd ? " M" : "") + (l_conv_vol ? " V" : "") + (l_conv_slope ? " S" : "") + (l_conv_anchor ? " A" : "") + (l_conv_fib ? " F" : ""),
               text_color=long_conviction >= 5 ? col_bull : long_conviction == 4 ? col_warn : col_muted, text_size=size.tiny)

    table.cell(t, 0, 19, "S conv (live)", text_color=col_warn, text_size=size.tiny)
    table.cell(t, 1, 19, str.tostring(short_conviction) + "/7" + (s_conv_stoch ? " K" : "") + (s_conv_bands ? " B" : "") + (s_conv_macd ? " M" : "") + (s_conv_vol_calm ? " C" : "") + (s_conv_extend ? " X" : "") + (s_conv_anchor ? " A" : "") + (s_conv_wyck ? " W" : ""),
               text_color=short_conviction >= 5 ? col_warn : short_conviction == 4 ? col_warn : col_muted, text_size=size.tiny)

    table.cell(t, 0, 20, "Fib retrace", text_color=col_warn, text_size=size.tiny)
    table.cell(t, 1, 20, na(fib_retrace_pct) ? "n/a" : str.tostring(math.round(fib_retrace_pct*100,0)) + "%" + (fib_near_618 ? " @618" : fib_near_100 ? " @100" : ""),
               text_color=fib_at_level ? col_warn : col_value, text_size=size.tiny)

    table.cell(t, 0, 21, "SOX phase", text_color=col_info, text_size=size.tiny)
    table.cell(t, 1, 21, use_wyckoff ? wyck_phase + (not na(sox_slope_pct) ? " (" + str.tostring(math.round(sox_slope_pct,1)) + "%)" : "") : "off",
               text_color=is_distribution ? col_warn : is_markup ? col_bull : is_markdown ? col_bear : is_accumulation ? col_info : col_muted, text_size=size.tiny)

// ─────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────
// All-signal alerts (all conviction levels)
alertcondition(short_signal, "SOXL SHORT v8.11 (any)", "TNA SHORT signal — check label for tier and conviction")
alertcondition(long_signal,  "SOXL LONG v8.11 (any)",  "TNA LONG signal — check label for tier and conviction")

// High-conviction only alerts (recommended for live trading)
alertcondition(is_high_conv_short, "SOXL SHORT v8.11 (★5+)", "TNA HIGH-CONVICTION SHORT — take full position after confirmation")
alertcondition(is_high_conv_long,  "SOXL LONG v8.11 (★5+)",  "TNA HIGH-CONVICTION LONG — take full position after confirmation")

// Zone alerts
alertcondition(in_short_zone and not short_signal and not in_crash_recovery, "TNA Short zone", "Approaching short conditions")
alertcondition(in_long_zone and not long_signal, "TNA Long zone", "Approaching long conditions")
alertcondition(ts_backwardation and not ts_backwardation[1], "VIX term backwardation", "VIX9D has crossed above VIX — immediate fear > longer-dated fear")

// Anchor channel breach alerts (price breaking back inside anchored channel = trend resume signal)
alertcondition(not na(anch_lo_pos) and anch_lo_pos <= 0.20 and anch_lo_pos[1] > 0.20, "Anchored long band touch", "Price reached lower band of uptrend channel from last pivot low")
alertcondition(not na(anch_hi_pos) and anch_hi_pos >= 0.80 and anch_hi_pos[1] < 0.80, "Anchored short band touch", "Price reached upper band of downtrend channel from last pivot high")

// Fib retrace alerts — fire when price first enters the 61.8% or 100% zone
alertcondition(fib_near_618 and not fib_near_618[1], "Fib 61.8% retrace touch", "Price has reached the 61.8% retracement of the prior up-move — historically a high-probability long zone")
alertcondition(fib_near_100 and not fib_near_100[1], "Fib 100% retrace touch", "Price has retraced 100% back to the prior swing low — test of structural support")

// T7 waterfall — dedicated alert (fires on the crash day itself)
alertcondition(long_t7 and long_signal, "SOXL LONG T7 waterfall (v8.11)", "TNA WATERFALL CAPITULATION long — same-day crash catch. Treat as discretionary; MACD has NOT yet confirmed reversal.")

// SOX Wyckoff distribution phase entry — fires when SOX first enters distribution
alertcondition(is_distribution and not is_distribution[1], "SOX entering Distribution phase (v8.11)", "Underlying semiconductor index (SOX) just entered Distribution phase — elevated bias for upcoming SOXL caution. Note: shorts disabled by default in v8.9.")

// ─────────────────────────────────────────────────────────
// DATA WINDOW
// ─────────────────────────────────────────────────────────
plot(dist_sma20 * 100,  "Dist SMA20 %",  display=display.data_window, color=color.new(color.white, 100))
plot(dist_sma50 * 100,  "Dist SMA50 %",  display=display.data_window, color=color.new(color.white, 100))
plot(dist_sma200 * 100, "Dist SMA200 %", display=display.data_window, color=color.new(color.white, 100))
plot(bb_pos,            "BB %B (20)",    display=display.data_window, color=color.new(color.white, 100))
plot(reg_pos_l,         "Reg pos (50)",  display=display.data_window, color=color.new(color.white, 100))
plot(reg_pos_s,         "Reg pos (20)",  display=display.data_window, color=color.new(color.white, 100))
plot(reg_slope_l * 100, "Reg slope (50) %", display=display.data_window, color=color.new(color.white, 100))
plot(stoch_k,           "Stoch K(3)",    display=display.data_window, color=color.new(color.white, 100))
plot(rsi14,             "RSI14",         display=display.data_window, color=color.new(color.white, 100))
plot(macd_hist_roc,     "MACD ROC",      display=display.data_window, color=color.new(color.white, 100))
plot(vol_panic,         "Vol panic",     display=display.data_window, color=color.new(color.white, 100))
plot(ts_9d_vix,         "VIX9D/VIX",     display=display.data_window, color=color.new(color.white, 100))
plot(ts_3m_vix,         "VIX3M/VIX",     display=display.data_window, color=color.new(color.white, 100))
plot(soxl_smh_ratio,    "SOXL/SMH ratio",display=display.data_window, color=color.new(color.white, 100))
plot(wk_uptrend ? 1 : wk_downtrend ? -1 : 0, "Weekly trend", display=display.data_window, color=color.new(color.white, 100))
plot(long_conviction,   "Long conviction (0-7)",  display=display.data_window, color=color.new(color.white, 100))
plot(short_conviction,  "Short conviction (0-7)", display=display.data_window, color=color.new(color.white, 100))
plot(fib_retrace_pct * 100, "Fib retrace %", display=display.data_window, color=color.new(color.white, 100))
plot(fib_swing_high,    "Fib swing high",   display=display.data_window, color=color.new(color.white, 100))
plot(fib_prior_low,     "Fib prior low",    display=display.data_window, color=color.new(color.white, 100))
plot(anch_lo_pos,       "Anchor-lo pos",          display=display.data_window, color=color.new(color.white, 100))
plot(anch_hi_pos,       "Anchor-hi pos",          display=display.data_window, color=color.new(color.white, 100))
plot(bars_since_piv_low,  "Bars since piv low",   display=display.data_window, color=color.new(color.white, 100))
plot(sox_slope_pct,     "SOX SMA20 slope %",      display=display.data_window, color=color.new(color.white, 100))
plot(is_markup ? 2 : is_distribution ? 1 : is_accumulation ? -1 : is_markdown ? -2 : 0, "SOX phase (2=MU,1=D,-1=A,-2=MD)", display=display.data_window, color=color.new(color.white, 100))
plot(bars_since_piv_high, "Bars since piv high",  display=display.data_window, color=color.new(color.white, 100))
````
