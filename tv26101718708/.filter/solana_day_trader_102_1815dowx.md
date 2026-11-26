# Solana Day Trader 1.02

- url: https://www.tradingview.com/script/1815DOWX-Solana-Day-Trader-1-02/
- type: indicator
- pine_id: PUB;80465fd961124698820121a9385bb72c
- version: 7.0

## Description

SOLANA DAY TRADER 1.01
Multi-timeframe capitulation entry system for SOL perpetual futures

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

WHAT IT DOES

Solana Day Trader identifies high-probability long entries during washout conditions — the sharp, wick-heavy drops where weak hands are flushed out before a mean-reversion recovery. It monitors the 15m, 30m, and 1h timeframes simultaneously and grades each potential entry from BASE through SCALE to FULL based on how much confirming evidence lines up.

The result is a live multi-timeframe dashboard that shows exactly where each timeframe stands — gate status, entry tier, confluence score, regime quality, liquidity levels, and active exit signals — all in one panel.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HOW IT WORKS

The system runs three filters in sequence. All three must pass for a FULL-tier entry; failing the third downgrades to SCALE or BASE.

1 — CAPITULATION GATES (must both pass)
The Williams VIX Fix (WVF Filtered) fires when the current low relative to recent highs reaches an extreme — the volatility-squeeze signature of a washout wick. A Fair Value Gap (FVG) must also be present: a 3-bar price imbalance that confirms institutional order flow was present at the move. Together these two gates filter out ordinary pullbacks and focus attention on structural lows.

2 — CONFLUENCE SCORE (determines BASE vs SCALE)
Once the gates pass, four factors add to a score: EMA 9>21 alignment, a VIDYA adaptive moving average in bull posture, OBV slope pointing upward (contrarian — rising buy-side pressure into the low), and a signed-volume DELTA measure. The score floor for BASE is 1; SCALE requires 2 or higher. Each weight is adjustable, and any factor can be zeroed out to simplify the model.

3 — REGIME GATE (SCALE → FULL escalation)
FULL tier requires the market to be in a ranging, low-momentum state: ADX below the configured threshold (default 25). High-ADX trending markets favor momentum strategies; low-ADX ranging markets are where mean-reversion setups have the clearest edge. Optionally, a BTC bull requirement can be added as an additional gate for FULL.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

THE DASHBOARD

The panel (default: middle-right, toggleable) displays a 3-column layout — one column per timeframe (15m / 30m / 1h) — with the active chart timeframe highlighted.

Row by row:

TIER — BASE / SCALE / FULL (or blank if no signal)
SIGNAL — current trade status (GET IN / IN TRADE / EXIT FULL / RE-ENTRY / etc.)
WVF — armed (✓) or not
FVG — armed (✓) or not
TQI gate — gating status when TQI gate is enabled
TQI — Trend Quality Index value (0–1), used for the optional gate and char-flip exit
Score — current confluence score
ADX < — ADX value vs. the FULL-tier threshold
REGIME — GREEN / YELLOW / RED composite regime
HTF / EMA — higher-timeframe EMA bias
ATF / BTC — adaptive trend fit classification + BTC lead direction
VWAP / OBV — swing VWAP position + OBV state
LEVELS — structural stop and ATR-based stop levels
Liq ↑ — nearest auto-detected sell-side liquidity above (resistance pool)
Liq ↓ — nearest auto-detected buy-side liquidity below (support pool)
OBSERVABLES — MBI, CVI, BBAWE, Bull Pressure composite line
Sweep — per-TF liquidity sweep detection
GATES — WVF / FVG gate arm state

GREEN regime = trending higher with measured momentum, favorable for recovery.
YELLOW regime = intermediate / mixed — entries here carry more risk.
RED regime = downtrend or high-volatility chop — approach with caution.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EXIT SIGNALS

Four exit conditions are available (each independently toggleable):

• BB Break — closes below the Bollinger lower band; thesis invalidated
• WVF Top — volatility-spike exhaustion reading; momentum likely stalling
• CVI Top — CVI exhaustion signal at extended levels
• Char-Flip (default OFF) — TQI collapse: trend quality deteriorates sharply after entry

The dashboard SIGNAL row tracks trade state and flags when any exit fires. A re-entry signal also activates after a full exit if the entry conditions re-arm within the configured watch window.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

MANUAL TRADE PROJECTION

When you enter a trade, toggle "I am currently in a trade" ON and type your entry price into "My entry price." The indicator draws TP and SL lines on the chart so you can see your risk/reward at a glance. Toggle OFF when you exit.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ALERTS

Three alert conditions are available — one per tier — so you can be notified on BASE, SCALE, and/or FULL fires independently. Configure in the Alert Filtering settings group.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

RECOMMENDED SETUP

Chart: SOL/USDT or SOLUSDT perpetual, any supported exchange.
Timeframe: 15m is the primary display TF. The indicator reads 15m, 30m, and 1h internally regardless of which TF the chart is set to, but the dashboard highlights whichever matches your chart.
Defaults: WVF gate ON, FVG gate ON, ADX threshold 25, all three timeframes enabled. These are sensible starting points — the system is designed to be used as-is.

The most conservative approach is to trade FULL-tier signals only during GREEN regime. BASE and SCALE signals in YELLOW regime are valid setups but carry wider outcome distributions.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SETTINGS GROUPS

Display — panel location/size, chart overlays (BB bands, WVF markers, EMA/SMA lines), trade projection toggle and entry price.
Entry Engine — timing windows (core arm, active trade, exit escalation, cooldown, re-entry).
Gate Stack — toggle WVF, FVG, TQI gates and the BB anti-signal individually.
Tier Escalators — ADX threshold for FULL tier.
Exit Signals — toggle each exit condition independently.
Cores — toggle EMA and VIDYA cores.
Confluence Score — individual weights for EMA, VIDYA, OBV, DELTA; score floor for BASE and SCALE/FULL.
Regime Escalator — BTC — optional BTC bull requirement for FULL-tier entries.
Alert Filtering — enable/disable alerts per tier.
Regime Context — HTF bias timeframe, EMA lengths, ADX length, ATF settings, BTC symbol.
Timeframes — enable/disable 15m, 30m, 1h independently; per-TF entry offset bars.
GATE — WVF Filtered — WVF period, Bollinger parameters, range lookback, arm window.
GATE — FVG — minimum gap height as % of price.
GATE — TQI — Trend Quality Index lengths and thresholds (informational unless TQI gate is enabled).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ATTRIBUTION

Williams VIX Fix methodology originally by LazyBear.
VIDYA adaptive moving average component from BigBeluga's Volumatic VIDYA.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This indicator is built for SOL perpetual futures. It is a decision-support tool, not a signal service. All entries and exits are your own decision. Past entry conditions do not guarantee future results.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════
// 1.18.1 (DISPLAY ONLY — TINY FONT STEP. Adds a "Tiny" option below
// "Small" on both tables, for phone screens where Small was still too big.
//
// ⚠ NOTHING IN THE ENGINE MOVES. Font sizing only. No score, gate, weight,
//   tracker tuple or alert is touched, and no security call is added. Every
//   DATA row must read byte-identical to 1.18.0.
//
// THE LADDER. Each dashboard size names three sizes — body, head, hero —
// each one step up from the last. Tiny simply extends the bottom:
//     Tiny    body tiny   / head small  / hero normal   ← NEW
//     Small   body small  / head normal / hero large
//     Normal  body normal / head large  / hero huge
//   Pine's smallest is size.tiny, so Tiny is the floor. Nothing smaller
//   exists to add later.
//
// TREND PANEL GETS ITS OWN SIZE INPUT (trendSize), defaulting to "Small",
// which reproduces 1.18.0's appearance exactly (header small, arrows
// normal). Set it to Tiny for header tiny / arrows small. It is separate
// from dashSize on purpose — the panel is six glyphs and stays readable
// much smaller than the main dashboard does.
//
// ON-PASTE CHECK:
//  1. Title reads 1.18.1. Dashboard text size dropdown now leads with Tiny.
//  2. Leave both size inputs alone and the chart must look EXACTLY like
//     1.18.0. Defaults are unchanged (dashSize Small, trendSize Small).
//  3. Set both to Tiny and both tables shrink one step.
// ROLLBACK: SOLdt 1.18.0.
//
// 1.18.0 (DISPLAY ONLY — MTF TREND PANEL. Ports the bottom-right "Predict"
// row from GainzAlgo's Smart Money Structure v3.0, sourced from the script
// Todd supplied. Six timeframes (5M/15M/30M/1H/4H/1D), three states.
//
// ⚠ NOTHING IN THE ENGINE MOVES. No score term, no gate, no weight, no
//   tracker tuple, no alert. Entry population, timing, price and R are
//   untouched, so EVERY DATA ROW MUST READ BYTE-IDENTICAL to 1.17.0 on the
//   same chart and window. This matters more than usual right now: 1.17.0
//   is accumulating the forward data that will adjudicate the VOL HI
//   promotion, and that accumulation must not be disturbed.
//
// WHAT THE PANEL ACTUALLY COMPUTES. Faithful to the source, including its
// quirks. Per timeframe:
//     trend = +1 if chart close is above BOTH the HTF EMA20 and HTF VWAP
//             -1 if below both, 0 otherwise
//     mom   = +0.5 / -0.5 / 0 on the sign of (close - close[3]) on that TF
//     vol   = +0.5 if that TF's ATR(14) is above its own SMA(ATR,20), else 0
//     score = trend + mom + vol
//     arrow = ▲ if score > 0.5, ▼ if score < -0.5, ━ otherwise
//
// ⚠ TWO PROPERTIES OF THE SOURCE, PRESERVED DELIBERATELY.
//   1. IT IS NOT A PREDICTION. Every input is present-tense: position vs
//      EMA20 and VWAP, a 3-bar momentum difference, ATR against its own
//      average. Nothing looks forward. It is a multi-timeframe AGREEMENT
//      panel carrying a forecasting label. Read it as "where does each TF
//      stand right now", never as "where is it going".
//   2. THE VOL TERM IS ONE-DIRECTIONAL. It contributes +0.5 or 0, never
//      -0.5. Down arrows therefore come entirely from trend and momentum;
//      the vol term never helps produce one. Its two real effects:
//        CREATES up arrows  — trend 0 with positive momentum goes +0.5 to
//                             +1.0 (━ becomes ▲); same for trend +1 with
//                             negative momentum.
//        SUPPRESSES one down arrow — trend -1 with flat momentum is -1.0
//                             without vol (▼) but -0.5 with it (━).
//      Net: a bullish tilt in high-volatility conditions. NOT an inability
//      to print red — down arrows appear normally.
//      This is almost certainly a bug in the source, kept so this panel
//      AGREES with the GainzAlgo indicator on the same chart and stays
//      usable as a cross-check. trendVolSym makes the term symmetric
//      (+0.5/-0.5) if you want to see it without the tilt. Leave it OFF
//      for cross-checking; turn it ON to judge the panel on its own.
//   ⚠ Relevant to what was just promoted: VOL HI in this indicator IS the
//     high-ATR entry band. This panel is tilted bullish in exactly those
//     conditions. Do not let it corroborate a VOL HI entry — it is not
//     independent evidence there.
//
// CHART-TF DEPENDENT, like the 1h tracker rows. The trend test compares the
// CHART's close against each HTF's EMA and VWAP, so the panel reads
// differently from a 15m chart than from a 1h chart. Same known behaviour
// as the DATA table's 1h rows. Not a defect, but note the chart TF when
// comparing two readings.
//
// SIX SECURITY CALLS, NOT 25. The source issues 25 (7 ema/vwap pairs plus
// 6 each of momentum, volatility and volatility average). One tuple per
// timeframe carries all five values, so this costs 6. Total for the file
// goes 14 -> 20, well inside Pine's limit of 40.
//
// DATA TABLE NOW DEFAULTS OFF (showTrk true -> false). Only RENDERING is
// skipped — f_trackDt still runs, the security calls still fire and the
// accumulators still fill, so NO TRACKED DATA IS LOST while it is hidden.
// Switch it back on in Validation Tracker whenever you want to read it.
//
// ON-PASTE CHECK:
//  1. Title reads 1.18.0, no ⚗LAB (the panel inputs are display-only and
//     are deliberately NOT in the _labMode baseline).
//  2. TREND panel appears bottom-centre with six arrows.
//  3. DATA table is GONE by default. Re-enable it and every row must read
//     byte-identical to 1.17.0. If any row moved, this build is wrong.
//  4. Put GainzAlgo's indicator on the same chart with trendVolSym OFF —
//     the six arrows must match theirs exactly. That is the port's test.
// ROLLBACK: SOLdt 1.17.0.
//
// 1.17.0 (PROMOTION — THE SCORE MOVES. VOL HI becomes a live confluence
// term at weight 1.0. This is the first weight change since wDELTA at
// 1.13.0. Everything downstream of the score moves with it: tiers, entry
// timing, entry POPULATION, every alert, and EVERY TRACKER ROW.
//
// ⚠ ALL PRE-1.17.0 TRACKER READINGS ARE NOW HISTORICAL. They measured a
//   different entry population. Do not compare any row in this build to a
//   number from 1.16.0 or earlier. The clean pre-promotion baseline was
//   captured 2026-08-27 (Full + both auto-halves, 1h chart, plus a 15m
//   chart control) and that capture is the only surviving record of it.
//
// WHAT WAS PROMOTED, AND WHY IT WAS THE HI SIDE. 1.15.0 tagged every entry
// LO/MID/HI by ATR percentile at the entry bar. Both outer bands came back
// sign-coherent across two non-overlapping auto-halves with every cell past
// n>=25:  VOL LO -.14 n41 / -.16 n32,  VOL HI +.22 n58 / +.14 n59.
// On R alone either side qualified. 1.16.0's EXIT MIX rows broke the tie:
//     LO exits  half A  29/61/10   half B  16/50/34   (t/s/o)
//     HI exits  half A  41/47/12   half B  36/46/19
//   LO dies by STOP in one window and by TIMEOUT in the other. Those are
//   two different failure mechanisms wanting opposite remedies, so LO's
//   coherent R rests on no stable mechanism. HI's exit profile is the same
//   in both windows. HI replicates on BOTH axes; LO replicates on one.
//   The pooled Full read (LO 23/56/21) looked decisively stop-heavy and was
//   an ARTIFACT of pooling A's stops with B's timeouts — the same pooling
//   trap that faked the monotonic VOL ladder in 1.15.0. Halves before
//   conclusions, always.
//
// ⚠ THE ENTRY POPULATION GROWS, KNOWINGLY. At stock weights every reachable
//   score is an integer 0-5 and the floors sit at 1.0/2.0, so +1.0 on HI
//   moves exactly two of six reachable scores:
//       score 1 -> 2 : BASE promoted to SCALE. Ordinary re-ranking.
//       score 0 -> 1 : A WVF-armed bar with ZERO other confluence now
//                      clears the BASE floor on volatility alone. THESE
//                      ENTRIES DID NOT EXIST BEFORE.
//   The size of that second group could not be measured in advance — those
//   bars scored 0, so they never entered, so they were never in the pool.
//   A diagnostic version to size it first was offered and DECLINED in
//   favour of promoting now. The accepted cost: tier BASE is henceforth a
//   BLEND of the old BASE population and this new zero-confluence group,
//   and the tracker cannot separate them. If BASE degrades from here, that
//   is the first thing to suspect and it will not be provable after the
//   fact. Rollback to 1.16.0 is the only clean way back.
//   Note +0.5 was tested first and is NUMERICALLY INERT at stock settings:
//   integer scores plus 0.5 land between integer floors and cross nothing.
//   0 of 6 reachable scores change tier. That is why this is 1.0, not 0.5.
//
// SHARED HELPER, SO SCORE AND AUDIT CANNOT DIVERGE. The VOL percentile was
// computed inline inside f_trackDt at 1.15.0. It is now f_volPct(), called
// by BOTH f_eval (which scores it) and f_trackDt (which reports it). One
// definition, so the VOL HI row can never drift from the VOL HI the score
// actually paid for. Zero new security calls — f_volPct() runs inside
// whatever context already called f_eval.
//
// wVOL_LO SHIPS AT 0.0. The input exists, documented, one step away. It is
// NOT promoted: LO's mechanism did not replicate (above). Do not raise it
// without a fresh two-halves read on THIS population.
//
// ON-PASTE CHECK:
//  1. Title reads 1.17.0 and shows NO ⚗LAB — the detector baselines have
//     been updated for the two new weights (wVOL_HI 1.0, wVOL_LO 0.0).
//  2. Tracker pool total MUST BE LARGER than 251. If it still reads 251 the
//     weight is not reaching the score and this build is wrong.
//  3. tier BASE and tier SCALE counts both move. SCALE gains the score-1
//     entries; BASE loses those and gains the new score-0 group.
//  4. VOL HI n grows; VOL LO and VOL MID n should be UNCHANGED at 73 and
//     61. Only HI entries got score, so only HI can gain population. If LO
//     or MID moved, the term is leaking into the wrong band.
//  5. EXIT MIX rows still sum to 100 and still match the VOL win% above.
// ROLLBACK: SOLdt 1.16.0.
//
// 1.16.0 (NEW OBSERVE-ONLY ROWS: EXIT MIX per VOL band. Tracker tuple
// 57 -> 60; all three unpack sites extended in lockstep. DATA table row
// alloc 46 -> 52, four rows appended at the bottom.
//
// ⚠ THE SCORE DOES NOT MOVE. No weight, gate, tier, veto or alert. Engine
//   byte-identical. Entry population, timing, price and R unchanged, so
//   EVERY PRE-EXISTING DATA ROW MUST READ BYTE-IDENTICAL to 1.15.0 on the
//   same chart and window — including all six VOL rows.
//
// THE QUESTION THIS EXISTS TO SETTLE. 1.15.0 found VOL LO coherently
// NEGATIVE across two non-overlapping auto-halves (-.14 n41 / -.16 n32) and
// VOL HI coherently POSITIVE (+.22 n58 / +.14 n59), all four cells above the
// n>=25 power bar. That MEETS the promotion bar. It is not being promoted,
// because two different situations produce the same negative LO number and
// they call for OPPOSITE remedies:
//   STOP-HEAVY LO  -> quiet-vol entries genuinely fail more. A negative
//                     score term on LO is the correct response.
//   TIMEOUT-HEAVY LO -> the entries are not failing, they are not
//                     TRAVELLING. A 1.5% target inside 12h is the wrong
//                     instrument for that band, and a score penalty would
//                     be penalising entries for the measuring stick.
// Half B's LO cell backs into roughly 16% target / 40% stop / 44% timeout,
// which is high on BOTH, which is exactly why the marginal cannot settle it.
//
// ⚠ EXIT MIX IS DESCRIPTIVE, NOT ADJUDICATION CURRENCY. It explains WHY a
//   band's R reads as it does. It promotes nothing by itself and must never
//   be quoted as a finding — same standing as the Cockpit's pop@3, which is
//   an alert-quality glance and explicitly not currency. The adjudication
//   currency in this file remains R on non-overlapping windows.
//
// MECHANISM, AND WHY IT IS ONLY THREE NEW COUNTERS. The bracket block
// ALREADY distinguishes all three exits — stop, target, timeout — it just
// discards which one happened after adding to _R. Target counts already
// exist as the _g* accumulators. So only the STOP count is new: _s0 for the
// pool, _sVlo and _sVhi for the two stored bands. Timeout is DERIVED as
// total - target - stop, and MID is derived from pool minus the other two,
// same convention as the VOL rows themselves. No new detection, no new
// security calls, no new state — bookkeeping on values that already exist.
//   Note the existing precedence is preserved untouched: a bar that touches
//   both barriers resolves to STOP (conservative), so _isStp is set in the
//   same branch that was already winning that tie.
//
// NEW RENDERER. f_mixDt() prints three PERCENTAGES (target / stop / timeout)
// instead of f_rowDt's R / win% / n, reusing the same four columns. Green is
// target, red is stop, yellow is timeout. The n is deliberately not repeated
// — it is already on the VOL rows immediately above.
//
// ON-PASTE CHECK:
//  1. Title and brand cell read 1.16.0; no ⚗LAB on stock settings.
//  2. DATA table has a cyan "EXIT MIX  t/s/o" header at the bottom with
//     three rows under it, showing PERCENTAGES not R values.
//  3. EVERY row above that header byte-identical to 1.15.0, VOL rows
//     included. If any moved, this build is wrong — do not read it.
//  4. Each EXIT MIX row's three percentages must sum to 100 (+/-1 for
//     rounding). If a row sums to anything else the derivation is broken.
//  5. The target% on each EXIT MIX row must equal the win% on the matching
//     VOL row above it. They are the same quantity by construction — if
//     they disagree, this build is wrong.
// ROLLBACK: SOLdt 1.15.0.
//
// 1.15.0 (NEW OBSERVE-ONLY TERM: VOL @entry — ATR percentile tercile at the
// entry bar. Tracker tuple 48 -> 57; all three unpack sites extended in
// lockstep. DATA table row alloc 39 -> 46, six rows appended at the bottom.
//
// ⚠ VERSION NUMBER: this is 1.15.0, NOT 1.14.0. A build numbered 1.14.0 was
//   cut earlier the same day carrying a STRUCTURE / BOS-CHoCH term, found
//   STARVATION-DOA (BOS armed n=2/251 = 0.8% against the ~15% conditional-
//   share floor; CHoCH armed n=0 in every window) and rolled back. This file
//   is built on a clean 1.13.3 and contains NO part of that term. The number
//   is skipped so two different files can never both be called 1.14.0.
//
// ⚠ THE SCORE DOES NOT MOVE. No weight input, no score term, no gate, no
//   tier interaction, no veto, no alert. Engine byte-identical. Entry
//   population, timing, price and R all unchanged, so EVERY PRE-EXISTING
//   DATA ROW MUST READ BYTE-IDENTICAL to 1.13.3 on the same chart and
//   window. Verify on paste before trusting anything.
//
// WHAT IT MEASURES, AND WHY IT IS A PARTITION. ta.percentrank(ATR(10), 100)
// at the entry bar, cut into terciles at 33.3 / 66.7. Every entry receives
// exactly one of LO / MID / HI, so the conditional share is ~33% by
// construction and CANNOT starve. That is the deliberate lesson from the
// withdrawn 1.14.0: an EVENT tag has to co-occur with an entry and gets
// whatever share the market gives it (BOS: 0.8%), while a PARTITION labels
// every entry. Every populated row in this file — FVG, DELTA, GREEN/YELLOW/
// RED, tier — is a partition. The one starved row was an event.
//
// BORROWED FROM, BUT NOT A COPY OF, AlgoAlpha's "Machine Learning Adaptive
// SuperTrend": ATR(10) over a rolling 100-bar window, cut into three
// volatility bands. That script solves the cut points with k-means seeded at
// the 25/50/75 percentiles of the window's ATR range and iterated to
// convergence. On ONE-DIMENSIONAL data with fixed percentile seeds that is
// an expensive route to breakpoints a percentile rank approximates for free,
// so the loop is deliberately not ported: no iteration cap, no convergence
// epsilon, fully deterministic. If this term shows nothing, adaptive
// breakpoints will not rescue it. If it shows something, THEN it is worth
// asking whether data-adaptive cuts beat fixed terciles.
//   NOTE the k-means version is NOT the failure mode that killed the neural
//   net engine reviewed 2026-07-23. That one accumulated online-learned
//   weights and was path-dependent on where TV history began. This is a
//   rolling window re-solved every bar — reload-stable either way.
//
// THE SECOND QUESTION IT ANSWERS. Whether the fixed +1.5/-1.0 bracket is
// mis-sized in the HI band. AlgoAlpha's "Breakout Targets" scales SL by ATR
// and sets TPs off that distance. DO NOT PORT THAT. The bracket's fixity is
// the only reason R is comparable across every row, split and version back
// to 1.09 — ATR-scaling it redefines R and silently invalidates the whole
// history. This term asks the same question without touching the bracket.
//
// VOL HI x GREEN IS A REDUNDANCY CHECK, NOT A FINDING. REGIME is ADX+ER
// (trendiness); this is bar magnitude. They SHOULD be near-orthogonal. If
// VOL HI turns out to be RED @entry wearing a different label, that cell is
// where it shows, and a differential in the marginals alone could not tell
// you. Marginals cannot reveal overlap.
//
// ON-PASTE CHECK:
//  1. Title and brand cell read 1.15.0; no ⚗LAB on stock settings.
//  2. DATA table has a cyan "VOL @entry" header at the bottom, five rows
//     under it.
//  3. EVERY row above that header byte-identical to 1.13.3 on the same chart
//     and window. If any moved, this build is wrong — do not read it.
//  4. VOL LO n + VOL MID n + VOL HI n must equal pool n exactly.
//     VOL HI x GREEN n must be <= both VOL HI n and GREEN @entry n.
//     VOL HI x GRN n + VOL HI x not-GRN n must equal VOL HI n.
//  5. Expect the three bands near a third of pool each. A badly lopsided
//     split means percentrank is warming up on too little history, not that
//     SOL has one volatility state — check the earliest-bar footer.
// ROLLBACK: SOLdt 1.13.3.
//
// 1.13.3 (DASHBOARD DISPLAY-ONLY. REGIME cell -> icon + word, REGIME variable
// REALIGNED to the adjudicated definition, and one inherited doc/code
// mismatch corrected. TRACKER CONTINUOUS. No gate, score, weight, tier,
// bracket, exit or accumulator logic changes. NO DATA ROW MOVES.)
//
// (A) THE DEFECT. The dashboard REGIME chip and this file's own DATA table
//     have always reported DIFFERENT VARIABLES under the same three words:
//       dashboard (old): ATF Pearson direction + adx_val < regime_adx_cap(30)
//       DATA rows:       _adxT < fullAdxMax(25) AND _erT < 0.35
//     Different inputs, different thresholds, and no ER at all on the
//     dashboard side. The chip's "GREEN" and the DATA table's "GREEN @entry"
//     row were unrelated measurements wearing the same label — you have been
//     reading one and adjudicating the other. Third instance of this defect
//     class in this suite, after the two sweep detectors closed at 1.13.2.
//     FIXED: regime_mode is now byte-for-byte the tracker's formula, on
//     chart-TF values. The chip finally agrees with the GREEN/YELLOW/RED
//     @entry rows underneath it.
//     WHY IT HAD TO BE FIXED IN THIS BUILD AND NOT LATER: the new cell
//     prints "❄️ RANGING" on GREEN. The old ATF GREEN meant a strong
//     DIRECTIONAL TREND. The label would have been flatly false.
//     SCOPE: regime_mode feeds the chip, regime_size_note, and _regimeBonus
//     -> the hero power bar. It has never fed the gate, the score, the tier,
//     the alerts or the tracker.
//     ⚠ EXPECT THE HERO POWER BAR TO READ DIFFERENTLY than the prior build
//     on the same chart, because _regimeBonus now keys off a different
//     boolean. That is the intended consequence, not a regression — the bar
//     was being bonused by a regime the tracker never measured.
//     ATF direction is NOT lost: it still renders in the ATF/BTC row.
//     regime_r_strong and regime_adx_cap are retained as inputs for rollback.
//
// (B) THE CELL. "R=.94 ADX=37 → 1.5× SCALE / 1× BASE" becomes:
//       ❄️ RANGING  · 2× SCALE      GREEN
//       🌊 LOOSE    · 1.5× SCALE    YELLOW
//       🔥 TRENDING · 1× only       RED
//     Physical-state ladder — solid, liquid, fire — readable from the glyph
//     alone. The sizing note is guidance and is kept. The raw Pearson and
//     ADX numbers are dropped: ATF/BTC already carries Pearson, and the chip
//     now carries the ADX+ER verdict.
//     ⚠ NO PERMISSION VERB, deliberately. The Swing Cockpit's version of
//     this row appends OPEN/SHUT because useRedGate genuinely blocks its
//     signal. In THIS file regime gates NOTHING — 1.11.0 tested it against
//     two auto-halves and closed it ("RED @entry is FLAT both halves ...
//     Confirmed on halves, closed"). Printing SHUT here would misdescribe
//     the engine to its own operator.
//
// (C) DOC/CODE MISMATCH CORRECTED (comment only). The inherited 1.11.0 note
//     claimed that flipping useFVGScore FALSE "restores FVG as a hard gate".
//     It does not: the gate is `_gatesPass = _wvfPass` and FVG appears
//     nowhere in it. Unticking the box only drops the wFVG score term, and
//     with wFVG = 0.0 that is numerically inert — while still raising ⚗LAB,
//     which is how an inert setting can light the badge and send you hunting.
//     Historical text left intact; a correction is appended beneath it.
//
// DELIBERATELY NOT BUNDLED (behavioural — display and behaviour never ship
// together): nothing outstanding on this file.
//
// ON-PASTE CHECK:
//  1. Title and brand cell read 1.13.3; no ⚗LAB on stock settings.
//  2. The REGIME strip shows an emoji + word + sizing note, no raw numbers.
//  3. The regime CHIP may now read a different colour than the prior build
//     on the same bar — that is (A) working. Cross-check it against the
//     ADX row: GREEN requires ADX < fullAdxMax (25) AND ER < 0.35.
//  4. EVERY DATA TABLE NUMBER is identical to the prior build on the same
//     chart and window. The tracker never read regime_mode; if any tracked
//     number moved, this build is wrong — do not read it, say so.
// ROLLBACK: SOLdt 1.13.2.
//
// 1.13.2 (SWEEP ROW REWIRED + MOVED. DISPLAY-ONLY, plus a tuple extension
// and a SECURITY-CALL REDUCTION. TRACKER CONTINUOUS. No gate, score, weight,
// tier, bracket, exit or accumulator logic changes. No entry is created,
// removed, retimed or re-priced; R is computed identically. EVERY DATA ROW
// MUST READ BYTE-IDENTICAL to 1.13.1 on the same chart and window. Verify
// that on paste before trusting anything. Ported from SOLsc 1.0.1/1.0.2.)
//
// ⚠ THE 1.13.0 PROMOTIONS ARE UNTOUCHED AND MUST STAY THAT WAY: wDELTA is
//   still 1.0, primary15mOnly is still TRUE and still wired into
//   entryTier_*/rawNewTier_*, the three live f_eval calls are still
//   lookahead_off, and _labMode still baselines wDELTA against 1.0.
//
// (A) A SILENT TWO-DETECTOR SPLIT, NOW CLOSED. This file has carried TWO
//     sweep-and-reclaim implementations since 1.09.0, side by side, never
//     the same mechanism:
//       • dashboard "Sweep" row  = f_sweepObs(): session hi/lo + BB bands,
//         long AND short, wick >= 0.3 ATR, volume >= 1.3x SMA(20).
//       • DATA SWEEP / SWP+Q rows = the SWP block inside f_trackDt:
//         pivotlow(8,8) levels, <= trkSwpMaxDist bars old, LONG ONLY,
//         scored 0-100 by wick/reclaim/close-position.
//     You were eyeballing one detector and adjudicating on the other. The
//     row now reads the SAME block the DATA rows measure, and shows the
//     LEVEL rather than an arrow.
//     LOSS, NAMED: short sweeps no longer appear on the dashboard. The
//     tracked block is long-only, which matches a long-only instrument.
//     LAG, NAMED: a pivot is only KNOWN 8 bars after it forms — 2h on 15m,
//     4h on 30m, 8h on 1h. The level is real and it existed; you learn about
//     it late. That is the price of structural confirmation, and it is
//     exactly why this uses pivotlow(8,8) and not a running ta.lowest(low,N):
//     a running minimum resets every few bars in a downtrend and is not a
//     level anyone is defending. Confidence ~80%.
//
// (B) DISTANCE FROM PRICE, added to every cell. THIS IS THE POINT, not the
//     colour. trkSwpMaxDist = 80 bars means a 1h pivot can be THREE AND A
//     HALF DAYS old and still display. Against a +1.5% target / -1.0% stop,
//     a level 6% away is not something to watch — it is noise occupying a
//     cell. A brighter, bigger cell would have given a useless number the
//     same visual weight as a useful one, i.e. the opposite of the intent.
//     Each cell now shows price on line 1 and a signed % on line 2.
//
// (C) COLOUR FOLLOWS DISTANCE, not merely fired/not-fired:
//       ● green   swept in arm window, quality >= trkSwpMinScore  (SWP+Q)
//       ● amber   swept in arm window, quality <  trkSwpMinScore  (SWP loQ)
//       ○ magenta pending, within swpNearPct      — IN PLAY, bg-tinted
//       ○ cyan    pending, within swpRelevantPct  — worth knowing
//       ○ slate   pending, beyond that            — too far to matter
//       —         no live level (aged out, or price closed below it)
//     Magenta matches the WVF bar/marker colour on purpose: the two hot
//     states share one visual language. The hot-cell background tint is the
//     same idiom the TIER pills already use — nothing new is invented.
//     Two new inputs: swpNearPct (0.5) and swpRelevantPct (2.0). The 2.0
//     default is deliberately just above the 1.5% bracket target — a level
//     further away than your TARGET cannot matter to the trade in front of
//     you. Raise it only if you are reading it as swing context.
//
// (D) MOVED to dashboard row 11, directly under TREND 21/200 and above the
//     REGIME band. Rows 11..21 shift +1; row 22 is vacated by the move
//     itself, so this is a CLOSED ROTATION and no row is added. GATES (23)
//     and ADR (24) do not move; the table stays 4x25. Structurally this is
//     where the row belonged: rows 5-11 are now the contiguous three-column
//     per-TF grid and everything from REGIME down is merged-cell blocks.
//     OBSERVABLES is left holding only the Obs row — thin, harmless.
//     VERIFIED MECHANICALLY: applying the row map to every 1.13.1 dash line
//     reproduces the 1.13.2 dash lines exactly, with only the four row-11
//     sweep cells differing. 84 dash lines in, 84 out, zero content loss.
//
// (E) BIGGER: the three value cells move f_sizeBody -> f_sizeHead, matching
//     the TIER pills. No new size input; still scales with dashSize.
//
// (F) CHART STEPLINE (showSwpLine, default ON). A table cell is a poor place
//     to watch a price level. This plots the pending level for whichever
//     engine slot matches the chart resolution, where price actually is.
//     ZERO new security calls — k15/k30/k60swPend are already unpacked from
//     the tracker contexts. ONE line only, deliberately. Its thresholds are
//     the SAME 15.5 / 35.0 used by _activeTFcol, so the line and the
//     highlighted dashboard column can never disagree.
//     ⚠ NOTE THE DIFFERENCE FROM SOLsc, which uses 7.5 / 12.5 because its
//     slots are 5m/10m/15m. Do not copy thresholds between the two files.
//
// (G) SECURITY BUDGET 17 -> 14. The three f_sweepObs() calls are removed:
//     their only consumer was the old dashboard row, and the pend30/60/15_swp
//     vars they also fed are WRITTEN AND NEVER READ anywhere in this file
//     (verified by grep, not assumed). f_sweepObs() itself is retained but
//     uncalled, so the code path is one line from returning if wanted.
//     THIS MATTERS MORE HERE THAN ANYWHERE ELSE IN THE SUITE. 1.12.2 was cut
//     specifically because this file threw "Runtime error: Memory limits
//     exceeded" on every chart above 1h, and named 17 security calls as the
//     cause; max_bars_back 2000 -> 500 was the mitigation. Three fewer
//     CONTEXTS is a second, independent reduction against the same failure.
//     ⚠ WORTH ONE GLANCE ON PASTE: try loading a 4h chart. If it now runs,
//     re-read "earliest 15m" in the footer. Per the 1.12.2 note, if that
//     date is still ~25-06-01 the per-request bar ceiling is real and 1h
//     stays the canonical adjudication chart; if it is materially older, the
//     ceiling was memory all along and BOTH halves should be re-read from 4h.
//     That question has been open since 1.12.2 and this build may answer it.
//
// MECHANISM: three new `var`s inside f_trackDt latch the swept level and its
// quality at the fire bar, because _swL1/_swL2 are set to na the INSTANT a
// sweep fires — a naive read would blank at exactly the moment you want the
// number. They are read-only consumers of values that already exist.
// f_trackDt tuple 44 -> 48; all three unpack sites extended in lockstep.
// On the 1.09.1 precedent (tuple 33 -> 34 purely to render a footer line,
// shipped x.y.z, tracker continuous) and the 1.12.2 precedent (pure infra,
// shipped x.y.z) this stays a z-level patch.
//
// ON-PASTE CHECK:
//  1. Title and DATA header read 1.13.2; brand cell reads
//     "◆ Solana Day Trader 1.13.2" and shows NO ⚗LAB on stock settings.
//  2. Dashboard row 10 is TREND 21/200, row 11 is "SWEEP lvl", row 12 is the
//     REGIME band. GATES and ADR are still the last two rows.
//  3. The SWEEP row is LARGER than the rows around it and each cell shows a
//     price on line 1 and a signed distance on line 2. Nothing is grey unless
//     there is genuinely no level.
//  4. A magenta stepline is drawn at the pending level for the chart-matching
//     TF. Turn it off with showSwpLine.
//  5. EVERY DATA NUMBER IS IDENTICAL to a 1.13.1 instance on the same chart
//     and window, and the "earliest" footer has not moved. If any number
//     changed, the sweep latch leaked into the trade logic and this build is
//     wrong — do not read it, say so.
//  6. Optional, and the interesting one: load a 4h chart. See (G).
// ROLLBACK: SOLdt 1.13.1.
//
// 1.13.1 (DISPLAY-ONLY. Version literals + VER constant. Not one line of
//   engine, tracker, gate, score, weight or render LOGIC changes. No tuple,
//   no security-call change. TRACKER: CONTINUOUS.
//   FIX: two display sites carried stale hand-typed versions -- the dashboard
//   brand cell read 1.11.0 and the DATA header read 1.12.4, while indicator()
//   correctly read 1.13.0. Three sites, three different values, drifting
//   independently across at least three builds because each is only visible
//   in a different place.
//   IMPACT: any DATA screenshot taken under 1.13.0 was stamped "1.12.4" --
//   i.e. labelled with a configuration in which wDELTA = 0.0. Since 1.13.0
//   promoted DELTA 0.0 -> 1.0 as an explicit single-variable test, that is
//   the one dataset that most needed a correct label.
//   ⚠ BEFORE READING DATA: confirm the tracker actually reset at 1.13.0.
//   1.13.0 was behavioral (DELTA promotion, 15m primary, lookahead_off), so
//   n should be fresh. If the table is carrying pre-1.13.0 entries, the DELTA
//   test is contaminated from the start and needs a manual reset.
//   HARDENING: VER declared once after indicator(); all three display sites
//   concatenate it. A version-literal assertion is now part of the standard
//   check script -- this is the second occurrence of this bug class (SOLue
//   1.2.0-1.2.2 shipped three times on a broken version line).
//   ALSO: the input group name read "Validation Tracker (1.13.0 ...)", which
//   is a PROVENANCE reference (when it was added) but reads in the Inputs
//   panel as if it were the running version. Reworded to "added 1.13.0".
//   Deliberately NOT converted to VER -- that would make it drift by design
//   every release. Historical references stay historical; they just have to
//   say so.
//   Rollback: 1.13.0 file.
// ═══════════════════════════════════════════════════════════
// 1.13.0 (RESEARCH BUILD — 15m execution focus + DELTA promotion + confirmed MTF engine).
//   Behavioral changes are deliberately limited to three testable items:
//   (A) DELTA weight defaults to 1.0 because it cleared the two-half promotion bar;
//   (B) 15m is the default PRIMARY ENTRY timeframe; 30m/1h remain visible context and
//       continue to supply exit signals, but do not create new entries by default;
//   (C) live MTF engine calls use lookahead_off so historical signals are based on
//       confirmed native-TF closes rather than developing HTF values. The observe-only
//       DATA tracker was already lookahead_off and remains the adjudication source.
//   Trend 21/200 remains OBSERVE-ONLY: no direction gate is added in this release.
// ═══════════════════════════════════════════════════════════
// 1.13.0 CHANGE LOG
//   • DELTA promoted from weight 0.0 -> 1.0 as a controlled single-variable test.
//   • 15m becomes primary execution TF by default; 30m/1h remain context + exit layers.
//   • Live MTF entry engine changed from lookahead_on -> lookahead_off for confirmed HTF closes.
//   • 21/200 direction remains observe-only; no direction gate added yet.
//
// 1.12.4 (DISPLAY-ONLY REORDER #2. TREND 21/200 moves from row 12 to row 10
//   — now directly under ADX<25, ahead of the REGIME band entirely, on the
//   logic that direction reads naturally alongside ADX/trend-strength rather
//   than nested inside REGIME's own sub-rows. REGIME band (10->11) and its
//   mode-pill (11->12) both shift down one to make room; HTF is UNCHANGED at
//   row 13 — a closed 3-row rotation, nothing below row 13 moves. DATA table
//   order untouched. Tracker continuous.)
// ═══════════════════════════════════════════════════════════
// 1.12.3 (DISPLAY-ONLY REORDER. TREND 21/200 moved from dashboard row 13 to
//   row 12, swapping with HTF/EMA. Nothing else changes — same two rows,
//   same cell content, only which row index each targets. TREND is now the
//   first row of the REGIME grouping's directional pair. DATA table row
//   order is untouched; only the live dashboard moved. Tracker continuous.)
// ═══════════════════════════════════════════════════════════
// 1.12.2 (INFRASTRUCTURE ONLY. max_bars_back 2000 -> 500. Not one line of
//   engine, tracker, gate, score or render logic changes. Tracker CONTINUOUS.
//   Every DATA row must read IDENTICALLY to 1.12.1 on the same chart+window.)
//
//   CAUSE: "Runtime error: Memory limits exceeded" on every chart above 1h.
//   max_bars_back allocates a historical buffer of that depth for EVERY
//   series in EVERY context. This script runs 17 security calls, each
//   evaluating a full stateful function with dozens of series. At 2000 that
//   is ~4x more buffer than anything here can use: an audit found NO literal
//   [N] reference deeper than 10 bars, and the deepest series length at
//   DEFAULTS is dirSlowLen=200 (the 1.12.0 direction MA). 500 leaves 2.5x
//   headroom over that and cuts the allocation 4x.
//
//   SAFETY: this cannot silently corrupt a number. If any series needs more
//   than 500 bars Pine throws a visible "bar index out of bounds" error
//   rather than returning a wrong value. So the outcome is binary: identical
//   results, or a loud error. If you ever raise SWP max level age above 500
//   or dirSlowLen above ~450, raise this back to 1000.
//
//   ⚠ THIS MAY FIX THE CRASH WITHOUT BUYING MORE 15m HISTORY. On the 1h
//   chart the footers read: earliest 15m 25-06-01 (~14 months, ~40,900 bars)
//   but earliest 1h 25-01-01 (~19 months, ~13,850 bars). The 1h context
//   reached FURTHER BACK IN TIME than the 15m context on the SAME chart —
//   so the 15m series hit a per-request bar ceiling the 1h series did not.
//   If that ceiling is real, a 4h chart will run but the 15m context will
//   still stop ~14 months back, and 1h remains the canonical adjudication
//   chart. 30m and 1h contexts would gain history; 15m would not.
//
//   THE TEST IS ONE GLANCE: load 4h and read "earliest 15m" in the footer.
//     • still 25-06-01  -> ceiling is real. 1h is canonical. Stop here.
//     • materially older -> ceiling was memory. Re-read both halves from 4h.
// ═══════════════════════════════════════════════════════════
// 1.12.1 (DISPLAY-ONLY BUGFIX. f_trackDt is byte-identical to 1.12.0 —
//   tuple, accumulators, tags and every stored number are unchanged. Only
//   render-side arithmetic on FOUR rows changes. Tracker CONTINUOUS.)
//
//   BUG: the four DIR x REGIME rows pooled k15+k30+k60, but every existing
//   pooled variable in this table (_px/_pg/_pr, _pxG/_pgG/_prG, _pxY) pools
//   k15+k30 ONLY — 1h is deliberately excluded, per "SOLdt's edge lives at
//   15m; 30m and 1h are net drags", and the header row is literally labelled
//   "pool 15m+30m". So DN x GREEN evaluated as
//       GREEN(15m+30m) MINUS UPxGREEN(15m+30m+1h)
//   i.e. a 2-TF pool minus a 3-TF pool. The 1h trades were subtracted from a
//   total that never contained them.
//
//   HOW IT SURFACED: a screenshot showed DN x GREEN with n=3 and a NEGATIVE
//   win rate. That is mathematically impossible — UPxGREEN is a strict subset
//   of GREEN, so GREEN.wins - UPxGREEN.wins cannot go below zero. The
//   impossible cell was the tell; the pooling mismatch was the cause.
//
//   NOT AFFECTED, and safe to read from 1.12.0 screenshots: every per-TF row
//   (UP/DN 15m, 30m, 1h) — those use k15/k30/k60 individually and never
//   touch the pool. Also unaffected: every pre-1.12.0 row.
//
//   ON-PASTE CHECK: DATA header reads 1.12.1; the band reads "DIR x REGIME
//   15m+30m"; UPxGREEN + UPxRED + DNxGREEN + DNxRED + the two YELLOW
//   remainders now reconcile to the "pool 15m+30m" n; no cell shows a
//   negative win rate.
// ═══════════════════════════════════════════════════════════
// 1.12.0 — TREND DIRECTION @ ENTRY. Adds ONE observe-only tracked variable
//   plus its dashboard row. NOTHING ELSE CHANGES: gate, score, weights,
//   tiers, brackets, exits and every pre-existing DATA row are untouched,
//   and all 17 security calls are unchanged — the new MAs compute inside the
//   EXISTING f_trackDt context, so zero new calls.
//
//   THE GAP THIS FILLS. SOLdt measures trend STRENGTH and has never measured
//   trend DIRECTION. The regime classifier is ADX + ER, both UNSIGNED: it
//   reports choppy vs trending and cannot report up vs down. The instrument
//   has therefore been structurally unable to separate:
//       • a WVF flush inside an UPTREND   = buying a dip
//       • a WVF flush inside a DOWNTREND  = catching a knife in markdown
//   Plausibly very different trades. This is also the only way to put the
//   standing "baseline collapse" principle — long-only mean reversion fails
//   in markdown regimes — to an actual split. It has been a stated learning
//   for months and has never been measured on this instrument.
//
//   THE VARIABLE: ta.ema(close, dirFastLen) > ta.ema(close, dirSlowLen),
//   default 21 vs 200, evaluated in the eval-TF context, frozen at the entry
//   bar. Binary, so no cell can starve.
//
//   INDEPENDENCE — CHECKED AGAINST THIS FILE, NOT ASSUMED:
//     • wEMA (live, weight 1.0) is ta.ema(close,9) > ta.ema(close,21): a
//       SHORT-term relationship. 21-vs-200 is structural. Different variable.
//     • htf_bull is ta.ema(close,9) > ta.ema(close,21) on 4h — also short
//       term, and DISPLAY ONLY: never in the gate, never in the score, never
//       tracked, never adjudicated.
//     • No 200-period MA existed anywhere in this file before 1.12.0.
//   Separate inputs (dirFastLen/dirSlowLen) are used rather than reusing
//   emaFast/emaSlow, so retuning the wEMA term cannot silently move this.
//
//   WHY ONE VARIABLE AND NOT A PORTED COMPOSITE. The original proposal was
//   to condense SOLtr's seven-term trend score into a confluence line and
//   import it here. Rejected on this file's own rule: "Treat cross-tool
//   transfer as a HYPOTHESIS TO TEST, never as an import." SOLtr is four
//   days old with three pre-registered predictions ALL UNRESOLVED, and its
//   P3 prior is 75% that the retail trend stack returns flat-to-negative.
//   Importing a composite that has never cleared n>=25 in any cell, into the
//   instrument most likely to invert against it (two inversions already on
//   record — FVG and SWP+Q), is precisely what that rule exists to prevent.
//   A composite is also uninterpretable: if it moved you would not know
//   which of seven terms moved it. One clean boolean is adjudicable. SOLtr
//   keeps running standalone and untouched so P1/P2/P3 can resolve.
//
//   POWER — RESOLVES ON FIRST PASTE, NOT IN THREE MONTHS. Halves carry
//   roughly 450 and 380 resolved trades. Even at a lopsided 70/30 direction
//   split (likely, since WVF fires in downmoves) the minority cell lands
//   near 135 and 115 — clearing n>=25 fivefold in BOTH windows. The
//   DIR x REGIME cross-tab is pooled across TFs for the same reason.
//
//   TRACKER CONTINUITY: minor bump (x.y) because the f_trackDt tuple arity
//   changes 34 -> 44. It is NOT a behavioural change: no entry is created,
//   removed, retimed or re-priced, and R is computed identically. Every
//   pre-existing DATA row must read IDENTICALLY to 1.11.0 on the same chart
//   and window. Verify that on paste before trusting the new rows.
//
//   ⚠ DO NOT GATE ON THIS. If the split shows a large differential the
//   temptation will be to filter entries by direction. Gating would cut the
//   population 30-50% on an instrument that took eighteen months to reach
//   ~500 samples. Measure now; decide about gating on a SECOND read from
//   fresh halves — never on the read that discovered it.
//
//   FIX (pre-release, same version — the first 1.12.0 build never compiled
//   so no data exists under it): the two new band rows called f_rowDt with
//   bare `na` for _x/_g. f_rowDt's params are untyped and the only prior
//   _hdr=true call passes real values, so Pine had nothing to infer from —
//   CE10189. Now 0.0/0/0, which is display-identical because _r=0 already
//   renders "—". No other line changed.
//
//   ON-PASTE CHECK: title and DATA header read 1.12.0; dashboard row 13 is
//   "TREND 21/200" with three TF cells; DATA gains a "TREND DIR @ENTRY" band
//   with UP/DN per TF plus a pooled "DIR x REGIME" band; every pre-1.12.0
//   DATA row unchanged.
// ═══════════════════════════════════════════════════════════
// 1.11.0 (TWO DEMOTIONS, BOTH FROM DEEPER AUTO-HALVES. No new code paths,
//   no new series, no new security calls, no tuple change — this version
//   moves exactly two input DEFAULTS and updates the LAB-mode baseline to
//   match. Every line of engine, tracker, alert and banner logic is
//   byte-for-byte identical to 1.10.0.)
//
//   EVIDENCE BASE: 1h chart, Window mode = 1st half (auto) / 2nd half
//   (auto), per-TF midpoint, 2026-07-24. Both halves non-overlapping.
//
//   (A) useScaleVeto DEMOTED: default ON -> OFF.
//   1.10.0 promoted this gate on tier SCALE -.01R/34%/n=59 (1st half) and
//   -.26R/25%/n=63 (2nd), n=122 pooled — at the time the only cell meeting
//   n>=25/half + sign coherence. With the deeper halves now available the
//   same cell reads +.05R/40%/n=101 (1st half) and -.15R/27%/n=99 (2nd).
//   THE SIGN FLIPPED. Both cells sit near n=100, so this is not starvation
//   — it is a cell that was never coherent, measured earlier on less data.
//   tier FULL flips the same way (-.11R/35%/n=80 vs +.21R/45%/n=73); only
//   tier BASE holds (+.05R/40%/n=273 and +.05R/36%/n=214).
//   A live gate does not stay running on evidence that no longer clears
//   the promotion bar. The input is retained (not deleted) so 1.10.0
//   behaviour is one click away, and the tracker's tier-SCALE row remains
//   the standing audit. Same discipline the Cockpit applied to D-TREND at
//   v29.35.0 — a finding that dissolves on deeper data was never there.
//   BEHAVIOURAL EFFECT: SCALE-tier entries, alerts, banner pulses and tier
//   pills all return. Expect MORE signals than 1.10.0, at unknown sign.
//
//   (B) wFVG DEMOTED: 1.5 -> 0.0. FVG was the HEAVIEST weight in the stack.
//   Auto-halves: FVG armed -.06R/37%/n=89 vs FVG absent +.04R/39%/n=365
//   (1st half); armed -.04R/37%/n=67 vs absent +.04R/35%/n=319 (2nd).
//   SIGN-COHERENT NEGATIVE across both non-overlapping windows, differential
//   -.08R to -.10R, every cell past n>=25. This clears the promotion bar in
//   the negative direction, and it is roughly twice the magnitude of the
//   best positive cell in the table.
//   NOTE ON DIRECTION OF TRANSFER: in the Swing Cockpit FVG-armed is
//   strongly POSITIVE and carries 2.5. It inverts here. That is the second
//   confirmed inversion between the two tools (SWP+Q is the first — Cockpit
//   vetoed-live -.50R to -1.02R, SOLdt SWP+Q +.29R to +.47R). Treat
//   cross-tool transfer as a HYPOTHESIS TO TEST, never as an import.
//   FVG remains fully computed, armed, displayed and TRACKED — the FVG
//   armed/absent rows stay the standing audit. It simply no longer buys
//   score. useFVGScore is deliberately left TRUE: flipping it FALSE carries
//   the separate documented meaning of restoring FVG as a hard gate, which
//   is NOT what the evidence supports. Zeroing the weight is the precise
//   change; the boolean is the wrong lever.
//   ⚠ CORRECTION APPENDED (this build) - the inherited claim two lines
//   above is WRONG ABOUT THIS FILE. Flipping useFVGScore FALSE does NOT
//   restore FVG as a hard gate. The gate is `bool _gatesPass = _wvfPass`
//   and FVG appears nowhere in it; the only consumer is the score term
//   `(_fvgArmed and useFVGScore ? wFVG : 0.0)`. Unticking the box merely
//   drops that term, and with wFVG = 0.0 it is NUMERICALLY INERT - the
//   expression evaluates to 0.0 on both branches. It DOES still raise
//   ⚗LAB, because _labMode tests `useFVGScore != true`, which is how an
//   inert setting can light the badge and send you hunting. Historical
//   text left intact above; only this correction is added.
//   BEHAVIOURAL EFFECT: FVG-armed entries (~20% of the tracked population)
//   lose 1.5 score. Some demote a tier, some drop below scoreBaseMin=1.0
//   and stop firing entirely. This is directionally intended — those are
//   the negative-expectancy entries — but it is a REAL reduction in signal
//   count, not a cosmetic reweight. Expect fewer FVG-armed signals.
//
//   COMBINED: (A) adds signals back, (B) removes some. Net signal count is
//   not predictable from the rows alone; read it off the chart.
//
//   LAB-MODE BASELINE UPDATED: the _labMode detector compared wFVG against
//   1.5. Left unchanged it would flag ⚗LAB permanently on stock settings.
//   Now compares against 0.0. useScaleVeto is not and never was part of the
//   LAB set, so no change there.
//
//   DELIBERATELY NOT DONE THIS VERSION:
//   • wDELTA stays 0.0 despite DELTA CLEARING THE BAR (armed +.06R/40%/
//     n=204 vs absent -.01R/38%/n=250 in the 1st half; armed +.06R/36%/
//     n=174 vs absent +.01R/35%/n=212 in the 2nd — sign-coherent, identical
//     armed expectancy both halves, all cells n>>25). Promoting it would add
//     1.0 to roughly 45% of entries, reshuffling tier assignment against
//     floors of 1.0/2.0 and feeding straight into the SCALE veto this
//     version just demoted. Do not stack a score change on top of an
//     unresolved tier gate. DELTA is the next promotion, AFTER (A) has been
//     re-read on fresh halves.
//   • wTQI stays 1.0. TQI is incoherent, not coherently negative:
//     >=thr +.04R (1st half) vs -.01R (2nd), <thr -.01R vs +.11R, dead-zone
//     +.10R vs .00R — everything flips. Weaker case than FVG. Parked.
//   • NO RED gate. RED @entry is FLAT both halves (.00R/38%/n=248 and
//     +.01R/35%/n=224) against GREEN +.05R/40%/n=196 and +.06R/37%/n=154.
//     The Cockpit's RED gate does NOT transfer: there RED runs -.16R to
//     -.36R and is worth gating; here it is nothing, and it is over half
//     the population. Confirmed on halves, closed.
//   • NO SWP+Q veto. Positive both halves here (+.47R/n=20, +.29R/n=16) —
//     the exact inverse of the Cockpit — but both cells FAIL n>=25. Keep
//     accruing; do not act in either direction yet.
//
//   STANDING OBSERVATION, NOT A CODE CHANGE: per-TF is sign-coherent across
//   both halves and is the largest expectancy lever in the tool. 15m +.06R
//   then +.09R (positive both halves); 30m -.03R then -.05R; 1h -.02R then
//   -.12R (both negative both halves, well-powered). SOLdt's edge lives at
//   15m; 30m and 1h are net drags. That is a ROLE decision, not a weight —
//   deliberately left to the operator rather than hardcoded here.
//
//   ON-PASTE CHECK: title and brand row read 1.11.0; brand row does NOT
//   show ⚗LAB on stock settings; tracker header reads DATA · 1.11.0; SCALE
//   tier pills and alerts reappear; the idle banner no longer appends
//   "⛔ SCALE vetoed"; every tracker row is IDENTICAL to 1.10.0 on the same
//   chart and window (the tracker always measured the raw engine, so the
//   demotions do not move it).
//   ROLLBACK: restore SOLdt 1.10.0, or simply set useScaleVeto ON and
//   wFVG 1.5 — the two are equivalent.
// ═══════════════════════════════════════════════════════════
// 1.10.0 (SCALE-TIER SUPPRESSION — first BEHAVIORAL change since the engine
//   froze at 1.08; minor-version bump per convention. One promotion only.)
//   useScaleVeto (NEW, default ON): when the final tier resolves to SCALE
//   (score >= scoreScaleMin but ADX >= fullAdxMax — high conviction into an
//   already-running trend), the tier is zeroed at the source in f_eval, so
//   entries, alerts, banner pulses, and tier pills ALL inherit. BASE and
//   FULL untouched.
//   EVIDENCE (1.09.1 tracker, auto-halves): tier SCALE -.01R/34%/n=59 in the
//   1st half, -.26R/25%/n=63 in the 2nd, n=122 pooled — the only cell that
//   fully met the promotion bar (n>=25 per half + sign coherence). Same
//   mechanism as the Cockpit's RED gate wearing SOLdt's tier semantics.
//   Role decision codified: SOLdt is the tight-bracket BURST tool (quick
//   daily pops); wide stops / laddered exits (2/4/8, 5% invalidation) belong
//   to the Swing Cockpit. Ladder mode deliberately NOT added here.
//   WIRING: f_eval gains a _scaleVetoOn param — the six frozen engine calls
//   and f_evalDisp pass TRUE (suppression live), f_trackDt passes FALSE so
//   the tracker keeps measuring the RAW engine and the tier-SCALE row stays
//   the standing audit of this gate. Suppression applied AFTER the BB-anti
//   demotion, matching the exact tier definition the tracker adjudicated.
//   f_eval tuple 30 -> 31 (_scaleVetoed appended): live unpacks extended;
//   f_evalDisp destructures 31, returns 28 unchanged. Idle banner appends
//   "⛔ SCALE vetoed" while a suppression is active so a quiet chart is
//   explainable. Set useScaleVeto OFF to reproduce 1.09.1 exactly.
// ═══════════════════════════════════════════════════════════
// 1.09.1 (TRACKER WINDOW AUTOMATION — tracker-only patch; engine, gates,
//   alerts, banner all byte-for-byte identical to 1.09.0):
//   PROBLEM: the two-halves coherence test required typing manual dates, but
//   intraday backfill depth is opaque (a 2023 window returned zero trades —
//   TradingView's bar cap means 15m/30m history reaches months, not years).
//   1. AUTO-HALVES mode — "Window mode" dropdown: Full / 1st half (auto) /
//      2nd half (auto). Each TF context captures its own first replay bar
//      (_t0, known from bar 1) and splits ITS OWN history at the constant
//      midpoint (_t0 + timenow)/2. No dates to type; halves are exact,
//      non-overlapping, and adapt to whatever depth TradingView serves.
//      NOTE: 15m and 30m have different depths, so each splits at its own
//      midpoint — pooled halves are per-TF-fair rather than calendar-aligned.
//      Manual start/end inputs still apply on top (AND) for custom windows.
//   2. EARLIEST footer — second footer row prints the true earliest tracked
//      bar per TF (15m · 30m · 1h) so backfill depth is never a mystery
//      again, plus the active mode. Ports the Cockpit's "earliest" line.
//   BOOKKEEPING: f_trackDt tuple 33 -> 34 (_t0 appended); all three unpacks
//   extended. Table rows 26 -> 27. Zero new security calls.
// ═══════════════════════════════════════════════════════════
// 1.09.0 (VALIDATION TRACKER — pure measurement release; the six frozen
//   lookahead_on engine calls are byte-for-byte UNTOUCHED. No gates, no
//   vetoes, no score changes. The data decides whether SOLdt earns its place.)
//   ADDED — f_trackDt(): Cockpit-pattern observe-only tracker, called via
//   THREE NEW lookahead_off security calls (15m/30m/1h) so adjudication runs
//   on clean, non-repainting history while the display engine stays frozen
//   (the 1.08.11 audit note's repaint caveat therefore does NOT contaminate
//   the tracker).
//   • ENTRY = tier leaves 0 (_tier>0 and _tier[1]==0): fresh engine entries
//     only. Deliberately narrower than the banner's _pulseN, which re-pulses
//     on tier UPGRADES (1->2 etc.) and would double-count.
//   • BRACKETS (day-trade scale, ~half the Cockpit's swing bracket): target
//     +1.5% / stop -1.0% (R = 1.5 on target, -1.0 on stop), first-touch,
//     single position (entries while in-trade are skipped, Cockpit
//     convention). Same-bar target+stop resolves to STOP (conservative).
//     Timeout at trkMaxHours (default 12h, bar count derived per TF):
//     R = signed % move / stop%. WIN column counts TARGET hits only
//     (timeout-positive adds to R but not win%, Cockpit semantics).
//   • SPLITS (pooled 15m+30m unless noted): per-TF 15m/30m/1h + pool ·
//     TQI >= tqiScoreThreshold at entry (finally puts real n behind the
//     observe-only TQI question) · TQI dead-zone band at entry (tests the
//     useTqiDeadZone hypothesis WITHOUT turning the gate on; TF-specific
//     bounds honored for 1h) · FVG armed · DELTA armed · regime at entry
//     (GREEN/YELLOW stored, RED derived; formula mirrors the Cockpit's
//     _reg exactly with fullAdxMax as the ADX threshold + ER<0.35) · tier
//     at entry (BASE/SCALE stored, FULL derived) · SWEEP / SWP+Q (verbatim
//     v28.9.4 Mirage block — the Cockpit's SWP+Q inversion may behave
//     differently at Mirage's native intraday scale; worth knowing before
//     assuming the veto transfers).
//   • WINDOW: v28.8.2-style bounded start/end time inputs for the
//     two-halves sign-coherence test. Footer prints the active window.
//   • BOOKKEEPING: tracker tuple 33 elements x 3 TFs. Engine calls, alerts,
//     banner, dashboard: UNTOUCHED. Promote-to-anything bar unchanged:
//     n>=25 per cell + sign coherence across non-overlapping windows.
// ═══════════════════════════════════════════════════════════
// 1.08.11 (DISPLAY-ONLY — engine/tracker byte-for-byte identical to 1.08.1):
//   • Row-0 banner entry string ("@ <price> (<tf>) · <P/L%>") promoted from
//     f_sizeBody to f_sizeHero — now matches the "◉ IN TRADE" cell size.
//   • Brand-row label fixed: hardcoded "1.08.1" -> "1.08.11" (same class of
//     fix 1.08.10 made; this build folds it in since its base was 1.08.09).
//   • indicator() title 1.08.09 -> 1.08.11. No other changes — zero engine,
//     gate, alert, or level logic touched. AUDIT NOTE (no code change): the
//     six lookahead_on calls on f_eval()/f_evalDisp() behave identically to
//     lookahead_off in REALTIME (live use unaffected) but repaint HISTORICAL
//     intrabar rendering when the chart TF is below the signal TF. Frozen
//     engine — documented, deliberately not altered.
// ═══════════════════════════════════════════════════════════
// 1.08.09 (DISPLAY-ONLY — engine/tracker byte-for-byte identical to 1.08.1):
//   • Action banner FULLY AUTOMATIC: ◉ IN TRADE @ <price> · <P/L%> / NO TRADE. No manual toggle.
//     Entry trigger uses a chart-resolution-INDEPENDENT native pulse (f_eval()'s own internal [1],
//     not chart-bar history) so the banner reads the same trade regardless of which chart TF is
//     loaded. Clears after autoMaxMinutes of real wall-clock time (not bar count). Liq-sweep auto-
//     clear removed (it was chart-pivot-dependent and could not be made resolution-independent
//     cheaply). KNOWN: 60m can light up to ~1 native bar earlier than the engine's official
//     confirmed entry, because offsetBars_60m defaults to 1 and this pulse does not replicate that
//     delay. 15m/30m have zero offset by default — exact parity with the engine there.
//   • All exit & management banner text removed (CLOSE/REDUCE/RE-ENTRY/MANAGING LOSS/
//     TIGHTEN STOP/MOVE STOP UP/HOLD/HOLD AND RIDE). Chart exit labels (showExitLbl) unchanged.
//   • Entry price auto-captured at the engine entry bar (close); reload-safe; persists for the
//     whole modeled trade until auto-clear. Manual entry-price and in/out toggle both removed.
//   • New input: autoMaxMinutes (banner backstop, wall-clock). SL stays in Row 16 only. Engine/tracker untouched.
//   * STATELESS banner trade-state (no var memory): f_eval() returns the time & native close of
//     each TF's most-recent entry pulse via ta.valuewhen, computed inside the existing security
//     calls -- zero net new security calls (the 3 refClose probes were removed). Chart scope is
//     'in trade' iff the most-recent pulse on any enabled TF is within autoMaxMinutes of now, so
//     the banner reads identically on every chart resolution. 60m may lead the engine's offset-
//     confirmed entry by ~1 native bar; dead-zone exclusion (off by default) is not applied here.
// ═══════════════════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════
// 1.08.1 (DISPLAY-ONLY patch — engine byte-for-byte identical to 1.08):
//   • Row 0 is now the ACTION BANNER (hero): the instruction (NO TRADE / GET IN /
//     HOLD / CLOSE …) is the single largest element. Brand + power bar demoted to Row 3.
//   • Single source of truth: _actionColor (GREEN/AMBER/RED) resolved from the action
//     state drives BOTH the banner band AND the power-bar color/bg. Bar length still = score,
//     so the bar can no longer disagree with the instruction by construction.
//   • Traffic-light buckets — GREEN: GET IN, RE-ENTRY, HOLD, HOLD AND RIDE, MOVE STOP UP,
//     IN TRADE · AMBER: idle (NO TRADE / stand by) · RED: CLOSE, REDUCE, MANAGING LOSS, TIGHTEN STOP.
//   • Idle recolored dim-grey → amber; idle verb "— no action —" → "NO TRADE".
//   • No engine/behavioral change. No new collection window. UI testbed for the swing-side port.
// ═══════════════════════════════════════════════════════════
// Solana Day Trader 1.08  (1.07 + system-wide power bar, ADX/regime score bonuses, Confluence row, best-TF star)
// 1.08: Power bar now driven by max effective score across all enabled TFs.
//   ADX < fullAdxMax adds +1 to score. Regime GREEN adds +1 to score.
//   Score row replaced with Confluence row (armed-count N/6 over EMA,VIDYA,OBV,DELTA,FVG,TQI).
//   Best-scoring TF gets star in header. ADX shows FULL/SCALE status.
//   Hero background tinted by system-wide score. Action row shows trigger TF.
//   Regime remains observational — does not feed Confluence row.
indicator("Solana Day Trader 1.13.3", shorttitle="SOLdt1.13", overlay=true,
 max_bars_back=500,
 max_lines_count=50, max_labels_count=100, max_boxes_count=60)
// ── VER: single source of truth for every version shown on screen ─────────
// 1.13.0 carried THREE hand-typed literals that had drifted independently:
//   indicator() title .... 1.13.0  (correct)
//   dashboard brand cell . 1.11.0  (stale by two behavioral versions)
//   DATA table header .... 1.12.4  (stale by one, and differently)
// The DATA header is the one that matters: that string appears in every
// screenshot used for adjudication, so the table was labelling 1.13.0 data
// -- wDELTA 0.0 -> 1.0, 15m primary, live MTF lookahead_on -> off -- as
// 1.12.4. Reading that screenshot later would attribute the numbers to a
// configuration in which DELTA contributed nothing to score.
// Declared once here; concatenated at all three sites. Drift is now
// structurally impossible rather than merely detectable.
// Historical version references inside comments and input tooltips are
// CORRECT and intentional ("DEMOTED at 1.11.0", "Set to 1.5 to reproduce
// 1.10.0") and are deliberately left alone.
string VER = "1.18.1"

// ═══════════════════════════════════════════════════════════
// VAR DECLARATIONS
// ═══════════════════════════════════════════════════════════
var float lastPivPrice = na
var int lastPivBar = na
var bool lastPivIsHigh = bool(na)
var int anchorBar = na
var float pvSum = 0.0
var float vSum = 0.0
var float pv2Sum = 0.0
var float atf_pearson = 0.0
var float atf_slope = 0.0
var float atf_intrcpt = 0.0
var float atf_stddev = 0.0
var int atf_period = 0
var float atf_upper_now = na
var float atf_lower_now = na
var line atf_upperLine = na
var line atf_lowerLine = na
var int v22_wvf_bars_since_chart = 9999
var int v22_bblo_bars_since_chart = 9999
var bool v22_bblo_latch = false
var bool v22_bbup_latch = false
var bool prev_exitBB = false
var bool prev_exitWvf = false
var bool prev_exitCvi = false
var array<int> active_entry_bars = array.new_int()
var int exitWatchCount = 0
var int exitWatchBar = na
var bool exitWatchActive = false
var bool exitWatchHadBB = false
var bool exitWatchHadWvf = false
var bool exitWatchHadCvi = false
var int lastRecordedTier_30m = 0
var int lastRecordedTier_60m = 0
var int lastRecordedTier_15m = 0
var bool reEntryWatchOn = false
var int reEntryWatchBar = na
var table dash = na

// ═══════════════════════════════════════════════════════════
// DISPLAY
// ═══════════════════════════════════════════════════════════
grpDisp = "═══ Display ═══"
showBgTint = input.bool(true, "Background tint when entry tier active", group=grpDisp)
showTriggerLbl = input.bool(true, "Tier trigger label on chart", group=grpDisp)
showExitLbl = input.bool(true, "Exit labels on chart", group=grpDisp, tooltip="Toggle OFF to hide EXIT HALF / EXIT FULL / RE-ENTRY labels on the chart. Entry tier labels are controlled separately by 'Tier trigger label on chart'.")
showBB = input.bool(true, "Show BB bands on chart", group=grpDisp)
showWvfMark = input.bool(true, "Show WVF triangle markers", group=grpDisp)
showWvfBarColor = input.bool(true, "Pink bar color on WVF fire", group=grpDisp)
showBbBreakMark = input.bool(true, "Show BB Break ▼ markers", group=grpDisp)
showWvfTopMark = input.bool(true, "Show WVF Top X markers", group=grpDisp)
showCviTopMark = input.bool(true, "Show CVI Top star markers", group=grpDisp)
showCharFlipMark= input.bool(true, "Show Char-Flip ⚡ markers", group=grpDisp)
showBbReject = input.bool(true, "Show BB Reject markers", group=grpDisp)
showSwingVwap = input.bool(true, "Show Swing VWAP line on chart", group=grpDisp)
showEma50 = input.bool(true, "Show EMA 50 (pale blue)", group=grpDisp)
ema50Len = input.int(50, "EMA 50 length", minval=2, maxval=400, group=grpDisp)
showSma50 = input.bool(true, "Show SMA 50 (bright yellow)", group=grpDisp)
showLiqZones = input.bool(true, "Show liquidity zones on chart", group=grpDisp, tooltip="Draws the auto-detected buy-side (below) and sell-side (above) liquidity levels for the focus timeframe as shaded zones.")
sma50Len = input.int(50, "SMA 50 length", minval=2, maxval=400, group=grpDisp)
showDashboard = input.bool(true, "Show MTF dashboard", group=grpDisp)
dashLoc = input.string("Bottom Right", "Dashboard location", options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group=grpDisp)
dashSize = input.string("Small", "Dashboard text size", options=["Tiny","Small","Normal","Large","Huge"], group=grpDisp, tooltip="1.18.1 added Tiny, one step below Small, for phone screens. Tiny is Pine's floor — there is nothing smaller.")
autoMaxMinutes = input.int(1440, "Banner auto-clear backstop (minutes)", minval=15, maxval=20160, group=grpDisp, tooltip="Wall-clock failsafe (not bar count, so it means the same real duration on every chart resolution): the IN TRADE banner clears this many minutes after entry regardless of price action. Default 1440 = 24h. Display-only - does not affect the engine or tracker.")

// ═══════════════════════════════════════════════════════════
// ENTRY ENGINE
// ═══════════════════════════════════════════════════════════
grpEng = "═══ Entry Engine ═══"
coreWindow = input.int(2, "Core arm window (bars from WVF)", minval=0, maxval=5, group=grpEng)
antiWindow = input.int(2, "BB Anti-signal window (bars from WVF)", minval=0, maxval=5, group=grpEng)
stopWindow = input.int(12, "Active trade window (bars after entry)", minval=1, maxval=48, group=grpEng, tooltip="How many bars after entry the trade is treated as active.")
exitCountWindow = input.int(3, "Exit escalation window (bars)", minval=1, maxval=10, group=grpEng)
exitCooldownBars= input.int(6, "Exit cooldown after entry (bars)", minval=0, maxval=15, group=grpEng)
statusBarWindow = input.int(2, "GET IN status window (bars)", minval=1, maxval=5, group=grpEng)
reEntryWindow = input.int(8, "Re-Entry watch window (bars after EXIT FULL)", minval=2, maxval=20, group=grpEng)

// ═══════════════════════════════════════════════════════════
// GATE STACK
// ═══════════════════════════════════════════════════════════
grpGates = "═══ Gate Stack ═══"
useScaleVeto = input.bool(false, "SCALE-tier suppression (1.11.0 · default OFF — evidence withdrawn)", group=grpGates, tooltip="DEMOTED at 1.11.0. Promoted at 1.10.0 on -.01R/n=59 and -.26R/n=63 across auto-halves (n=122). Deeper auto-halves 2026-07-24 flipped the sign: tier SCALE +.05R/40%/n=101 in the 1st half vs -.15R/27%/n=99 in the 2nd — both cells well past n>=25, so this is incoherence, not starvation. A live gate is not left running on evidence that no longer clears the bar. Left as an input so the 1.10.0 behaviour is one click away; the tracker tier-SCALE row remains the standing audit. Turn ON to reproduce 1.10.0 exactly.")
useWVFGate = input.bool(true, "WVF Filtered hard gate (recommended ON)", group=grpGates, tooltip="Mean-reversion capitulation trigger. This is the ONLY hard gate in this version.")
useTqiDeadZone = input.bool(false, "TQI dead-zone exclusion", group=grpGates, tooltip="Optional: blocks entries when TQI sits inside the configured dead-zone band. Off by default.")
tqiDeadZoneLow = input.float(0.40, "TQI dead-zone LOW bound (30m/15m)", minval=0.0, maxval=1.0, step=0.01, group=grpGates, tooltip="Lower edge of the TQI exclusion band for 30m and 15m. Default 0.40.")
tqiDeadZoneHigh = input.float(0.45, "TQI dead-zone HIGH bound (30m/15m)", minval=0.0, maxval=1.0, step=0.01, group=grpGates, tooltip="Upper edge of the TQI exclusion band for 30m and 15m. Default 0.45. Entries blocked when LOW <= TQI < HIGH.")
tqiDeadZoneLow_60m = input.float(0.35, "TQI dead-zone LOW bound (1h)", minval=0.0, maxval=1.0, step=0.01, group=grpGates, tooltip="1h-specific lower edge of the TQI exclusion band. Default 0.35.")
tqiDeadZoneHigh_60m = input.float(0.50, "TQI dead-zone HIGH bound (1h)", minval=0.0, maxval=1.0, step=0.01, group=grpGates, tooltip="1h-specific upper edge of the TQI exclusion band. Default 0.50.")
useBBAnti = input.bool(true, "BB Break anti-signal (pre-entry cap)", group=grpGates)

// ═══════════════════════════════════════════════════════════
// TIER ESCALATORS
// ═══════════════════════════════════════════════════════════
grpEsc = "═══ Tier Escalators ═══"
fullAdxMax = input.float(25.0, "FULL tier: ADX must be below", minval=10.0, maxval=50.0, step=1.0, group=grpEsc, tooltip="Low ADX = ranging market = mean-reversion conditions. FULL tier requires ADX below this. Default 25.")

// ═══════════════════════════════════════════════════════════
// EXIT SIGNALS
// ═══════════════════════════════════════════════════════════
grpExit = "═══ Exit Signals ═══"
useBBStop = input.bool(true, "EXIT: BB Break (close ≤ lower band)", group=grpExit)
useExitWvfTop = input.bool(true, "EXIT: WVF Top", group=grpExit)
useExitCviTop = input.bool(true, "EXIT: CVI Top", group=grpExit)
useExitCharFlip = input.bool(false, "EXIT: Char-Flip (TQI collapse)", group=grpExit)

// ═══════════════════════════════════════════════════════════
// CORES
// ═══════════════════════════════════════════════════════════
grpCores = "═══ Cores ═══"
useEMACore = input.bool(true, "Core: EMA 9>21", group=grpCores)
useVidyaCore = input.bool(true, "Core: VIDYA (BigBeluga)", group=grpCores)

// ═══════════════════════════════════════════════════════════
// CONFLUENCE SCORE
// ═══════════════════════════════════════════════════════════
grpConf = "═══ Confluence Score ═══"
wEMA = input.float(1.0, "Weight: EMA 9>21", minval=0.0, maxval=5.0, step=0.5, group=grpConf, tooltip="Confluence weight for EMA core. Default 1.")
wVIDYA = input.float(1.0, "Weight: VIDYA bull", minval=0.0, maxval=5.0, step=0.5, group=grpConf, tooltip="Confluence weight for VIDYA core. Default 1.")
wOBV = input.float(1.0, "Weight: OBV slope bull", minval=0.0, maxval=5.0, step=0.5, group=grpConf, tooltip="Confluence weight for OBV slope. Set 0 to disable. Default 1.")
wDELTA = input.float(1.0, "Weight: DELTA bull", minval=0.0, maxval=5.0, step=0.5, group=grpConf, tooltip="Confluence weight for signed-volume DELTA. PROMOTED to 1.0 in 1.13.0. Two non-overlapping auto-halves were +.06R/.06R for DELTA-armed vs +/-.01R absent; promotion is intentionally a single-variable test.")
useFVGScore = input.bool(true, "FVG contributes to score", group=grpConf, tooltip="When ON, FVG adds wFVG to confluence score instead of acting as a hard gate.")
wFVG = input.float(0.0, "Weight: FVG armed", minval=0.0, maxval=5.0, step=0.5, group=grpConf, tooltip="Confluence weight for FVG. DEMOTED to 0.0 at 1.11.0 (was 1.5, the heaviest term in the stack). Auto-halves 2026-07-24: FVG armed -.06R/37%/n=89 vs absent +.04R/39%/n=365 in the 1st half, armed -.04R/37%/n=67 vs absent +.04R/35%/n=319 in the 2nd — sign-coherent NEGATIVE across two non-overlapping windows with adequate n. FVG is still computed, still armed, still tracked; it just no longer buys score. Set to 1.5 to reproduce 1.10.0.")
useTqiScore = input.bool(true, "TQI contributes to score", group=grpConf, tooltip="When ON, TQI adds wTQI to score when >= tqiScoreThreshold. No longer a hard gate.")
wVOL_HI = input.float(1.0, "Weight: VOL HI @entry", minval=0.0, maxval=5.0, step=0.5, group=grpConf, tooltip="1.17.0 PROMOTED. Entry-bar ATR at or above the HI percentile cut adds this to the confluence score. Promoted on sign-coherent R across two non-overlapping auto-halves (+.22 n58 / +.14 n59) BACKED BY a stable exit profile in both windows (41/47/12 and 36/46/19 target/stop/timeout) — the LO band matched on R but not on mechanism, so HI was promoted and LO was not. NOTE 0.5 is numerically inert here: stock scores are integers and the tier floors are integers, so a half-point crosses nothing. Set to 0.0 to reproduce 1.16.0 exactly.")
wVOL_LO = input.float(0.0, "Weight: VOL LO @entry (PENALTY, subtracted)", minval=0.0, maxval=5.0, step=0.5, group=grpConf, tooltip="1.17.0, NOT PROMOTED — ships at 0.0 and is inert. Enter a POSITIVE magnitude; it is SUBTRACTED from the score. VOL LO was sign-coherent negative on R (-.14 n41 / -.16 n32) but its EXIT MIX did not replicate: stop-heavy in one half (29/61/10), timeout-heavy in the other (16/50/34). Those want opposite fixes, so the coherent R rests on no stable mechanism. ⚠ A NEGATIVE term can push entries BELOW the BASE floor, which DELETES entries rather than re-ranking them — deleted entries leave no trace in the tracker and cannot be audited after the fact. Do not raise this without a fresh two-halves read on the current population.")
wTQI = input.float(1.0, "Weight: TQI >= threshold", minval=0.0, maxval=5.0, step=0.5, group=grpConf, tooltip="Confluence weight for TQI. Default 1. Only adds when TQI >= tqiScoreThreshold.")
tqiScoreThreshold = input.float(0.35, "TQI score threshold", minval=0.0, maxval=1.0, step=0.05, group=grpConf, tooltip="TQI must be >= this to contribute to confluence score. Default 0.35.")
scoreBaseMin = input.float(1.0, "Score floor for BASE", minval=0.5, maxval=5.0, step=0.5, group=grpConf, tooltip="Minimum confluence score for BASE. At default weights (1.0 each), 1.0 = WVF + one confirmation. This is your main throttle — lower for more entries, raise to demand more confluence.")
scoreScaleMin = input.float(2.0, "Score floor for SCALE/FULL", minval=1.0, maxval=6.0, step=0.5, group=grpConf, tooltip="Minimum for SCALE. At default weights, 2.0 = WVF + two confirmations. FULL = this plus ADX below the FULL threshold.")
deltaArmWin = input.int(2, "DELTA arm window (bars from WVF)", minval=0, maxval=5, group=grpConf, tooltip="DELTA counts toward score if its bull state arms within this many bars of the WVF fire (mirrors core windowing).")
deltaLen = input.int(14, "DELTA Volume EMA length", minval=1, maxval=50, group=grpConf, tooltip="Signed-volume EMA length for the DELTA condition.")

// ═══════════════════════════════════════════════════════════
// REGIME ESCALATOR — BTC
// ═══════════════════════════════════════════════════════════
grpBtcEsc = "═══ Regime Escalator — BTC ═══"
useBtcFullGate = input.bool(false, "BTC bull REQUIRED for FULL (live escalator)", group=grpBtcEsc, tooltip="When ON, FULL tier additionally requires BTC to be bullish. Off by default.")

// ═══════════════════════════════════════════════════════════
// ALERT FILTERING
// ═══════════════════════════════════════════════════════════
grpAlerts = "═══ Alert Filtering ═══"
useBaseAlerts = input.bool(true, "Alert on BASE tier", group=grpAlerts)
useScaleAlerts = input.bool(true, "Alert on SCALE tier", group=grpAlerts)
useFullAlerts = input.bool(true, "Alert on FULL tier", group=grpAlerts)

// ═══════════════════════════════════════════════════════════
// REGIME CONTEXT
// ═══════════════════════════════════════════════════════════
grpRegime = "═══ Regime Context ═══"
showRegimePanel = input.bool(true, "Show Regime Context rows on dashboard", group=grpRegime)
htfBiasTF = input.timeframe("240", "HTF Bias timeframe", group=grpRegime, tooltip="Higher-timeframe bias reference. Default 4h.")
htfFastLen = input.int(9, "HTF EMA fast length", minval=2, maxval=50, group=grpRegime)
htfSlowLen = input.int(21, "HTF EMA slow length", minval=5, maxval=100, group=grpRegime)
dirFastLen = input.int(21,  "Trend direction: fast MA length", minval=2, maxval=100, group=grpRegime, tooltip="1.12.0 OBSERVE-ONLY. Fast leg of the trend-direction split. Deliberately a SEPARATE input from emaFast/emaSlow so retuning the wEMA confluence term cannot silently move this variable.")
dirSlowLen = input.int(200, "Trend direction: slow MA length", minval=20, maxval=400, group=grpRegime, tooltip="1.12.0 OBSERVE-ONLY. Slow leg. UP = fast > slow, frozen at the entry bar. Tracked as a split only — this NEVER gates, scores or filters anything.")
adxLen = input.int(14, "ADX length", minval=5, maxval=50, group=grpRegime)
adxTrendThr = input.int(25, "ADX trend threshold", minval=15, maxval=40, group=grpRegime)
btcSym = input.symbol("BINANCE:BTCUSDT", "BTC Lead symbol", group=grpRegime)
btcEmaLen = input.int(9, "BTC EMA length", minval=2, maxval=50, group=grpRegime)
use_atf = input.bool(true, "ATF: enable engine + dashboard", group=grpRegime)
show_atf_channel= input.bool(true, "ATF: draw regression channel", group=grpRegime)
atf_long_term = input.bool(false, "ATF: long-term mode", group=grpRegime)
atf_dev_mult = input.float(2.0, "ATF: channel deviation multiplier", minval=0.5, maxval=4.0, step=0.1, group=grpRegime)
atf_strength_min= input.float(0.6, "ATF: min Pearson R to classify", minval=0.0, maxval=1.0, step=0.05, group=grpRegime)
regime_r_strong = input.float(0.75, "Regime: Pearson R GREEN threshold", minval=0.5, maxval=1.0, step=0.05, group=grpRegime)
regime_adx_cap = input.int(30, "Regime: ADX cap for GREEN", minval=15, maxval=50, group=grpRegime)

// ═══════════════════════════════════════════════════════════
// TIMEFRAMES
// ═══════════════════════════════════════════════════════════
grpTF = "═══ Timeframes (15m primary execution) ═══"
primary15mOnly = input.bool(true, "PRIMARY ENTRY: 15m only", group=grpTF, tooltip="1.13.0 research mode. When ON, only fresh 15m tiers can create entries/re-entries. 30m and 1h remain visible context and continue to drive exits. Turn OFF to restore multi-TF entry behavior.")
useTF1 = input.bool(true, "Enable 30m", group=grpTF)
useTF2 = input.bool(true, "Enable 1h", group=grpTF)
useTF3 = input.bool(true, "Enable 15m", group=grpTF, tooltip="Enable the 15m timeframe as a primary entry TF, with its own per-TF stop.")
offsetBars_30m = input.int(0, "Entry offset bars — 30m", minval=0, maxval=6, group=grpTF, tooltip="Bars to delay 30m entry registration after gate fire. Default 0.")
offsetBars_60m = input.int(1, "Entry offset bars — 1h", minval=0, maxval=6, group=grpTF, tooltip="Bars to delay 1h entry registration after gate fire. Default 1.")
offsetBars_15m = input.int(0, "Entry offset bars — 15m", minval=0, maxval=6, group=grpTF, tooltip="Bars to delay 15m entry registration after gate fire. Default 0.")

// ═══════════════════════════════════════════════════════════
// GATE — WVF Filtered
// ═══════════════════════════════════════════════════════════
grpWVF = "═══ GATE — WVF Filtered ═══"
wvf_pd = input.int(18, "WVF Period", minval=5, maxval=50, group=grpWVF)
wvf_bbl = input.int(16, "WVF BB Length", minval=5, maxval=50, group=grpWVF)
wvf_mult = input.float(2.0,"WVF BB Multiplier", minval=0.5,maxval=5.0, step=0.1, group=grpWVF)
wvf_lb = input.int(40, "WVF Range Lookback", minval=10, maxval=100, group=grpWVF)
wvf_ph = input.float(0.85,"WVF Range %", minval=0.5,maxval=1.0, step=0.05,group=grpWVF)
wvf_ltLB = input.int(30, "WVF Long-Term Lookback",minval=10, maxval=60, group=grpWVF)
wvf_mtLB = input.int(12, "WVF Mid-Term Lookback", minval=5, maxval=30, group=grpWVF)
wvf_str = input.int(2, "WVF Strength Lookback", minval=1, maxval=10, group=grpWVF)
wvf_window = input.int(3, "WVF Arm Window (bars on eval TF)", minval=0, maxval=10, group=grpWVF, tooltip="WVF arm window in bars on the evaluation TF. A 3-bar window = 90 min on 30m, 180 min on 1h.")

// ═══════════════════════════════════════════════════════════
// GATE — FVG
// ═══════════════════════════════════════════════════════════
grpFVG = "═══ FVG (Fair Value Gap) ═══"
fvg_minPct = input.float(0.1, "FVG: min gap height (% of price)", minval=0.0, maxval=2.0, step=0.05, group=grpFVG, tooltip="Minimum 3-bar imbalance height as % of close.")

// ═══════════════════════════════════════════════════════════
// TQI
// ═══════════════════════════════════════════════════════════
grpTQI = "═══ TQI (confluence contributor) ═══"
tqi_erLen = input.int(20, "TQI: Efficiency Ratio length", minval=5, maxval=50, group=grpTQI)
tqi_volLen = input.int(20, "TQI: Volatility regime length",minval=5, maxval=50, group=grpTQI)
tqi_strLen = input.int(50, "TQI: Structure alignment length",minval=10,maxval=200,group=grpTQI)
tqi_momLen = input.int(14, "TQI: Momentum length", minval=5, maxval=50, group=grpTQI)
tqiGateLow = input.float(0.40,"TQI low threshold (char-flip boundary)", minval=0.0, maxval=1.0, step=0.05, group=grpTQI, tooltip="TQI collapsing below this from above tqiCharHigh triggers char-flip exit. No longer used as entry gate.")
tqiCharHigh = input.float(0.55,"TQI char-flip high threshold", minval=0.0,maxval=1.0, step=0.05, group=grpTQI)
tqiCharAge = input.int(5, "Char-flip min trend age (bars)", minval=1, maxval=30, group=grpTQI)

// ═══ 1.09.0: VALIDATION TRACKER (observe-only · lookahead_off · frozen engine untouched) ═══
grpTrk = "═══ Validation Tracker (added 1.13.0 · observe-only) ═══"
showTrk = input.bool(false, "Show DATA table", group=grpTrk, tooltip="1.09.0 observe-only tracker. Measures the frozen engine's fresh entries (tier 0 -> >0) against fixed day-trade brackets on lookahead_off data. Feeds NOTHING — no gates, no score, no alerts.")
trkPos = input.string("Bottom Left", "DATA table position", options=["Top Left","Top Right","Bottom Left","Bottom Right","Middle Left"], group=grpTrk)
trkTgtPct = input.float(1.5, "Bracket: target %", minval=0.2, maxval=10.0, step=0.1, group=grpTrk, tooltip="First-touch target. R on hit = target% / stop%.")
trkStopPct = input.float(1.0, "Bracket: stop %", minval=0.2, maxval=10.0, step=0.1, group=grpTrk, tooltip="First-touch stop = -1R. Same-bar target+stop resolves to STOP (conservative).")
trkMaxHours = input.float(12.0, "Bracket: timeout (hours)", minval=1.0, maxval=96.0, step=1.0, group=grpTrk, tooltip="Neither side touched within this window -> trade closes at market: R = signed % move / stop%. Timeout-positive adds to R but NOT to win% (win = target hit only).")
trkStart = input.time(timestamp("2023-01-01T00:00:00"), "Tracker window start", group=grpTrk, tooltip="v28.8.2-style bounded window for the two-halves sign-coherence test. Entries outside the window are ignored.")
trkEnd = input.time(timestamp("2030-01-01T00:00:00"), "Tracker window end", group=grpTrk)
trkMode = input.string("Full", "Window mode (auto-halves)", options=["Full","1st half (auto)","2nd half (auto)"], group=grpTrk, tooltip="1.09.1. Auto two-halves coherence test with NO dates to type. Each TF splits its own available history at the midpoint between its earliest replay bar and now. Manual start/end above still apply on top. Footer prints earliest bar per TF + active mode.")
trkSwpPivLen = input.int(8, "SWP pivot len", minval=2, maxval=30, group=grpTrk, tooltip="Mirage sweep tags (verbatim Cockpit v28.9.4 block). Observe-only rows.")
trkSwpMaxDist = input.int(80, "SWP max level age (bars)", minval=5, maxval=500, group=grpTrk)
trkSwpMinScore = input.float(50, "SWP quality threshold (0-100)", step=5, minval=0, maxval=100, group=grpTrk)
swpNearPct     = input.float(0.5, "Sweep display: IN-PLAY distance (%)", minval=0.05, maxval=5.0, step=0.05, group=grpTrk, tooltip="1.13.2 DISPLAY ONLY. A pending sweep level closer than this to current price renders MAGENTA with a background tint — it is in play. Feeds nothing: no gate, no score, no tracker row.")
swpRelevantPct = input.float(2.0, "Sweep display: RELEVANT distance (%)", minval=0.1, maxval=20.0, step=0.1, group=grpTrk, tooltip="1.13.2 DISPLAY ONLY. A pending level closer than this renders CYAN; further out renders dim slate. Default 2.0 is deliberately just above the 1.5% bracket target: a level further away than your TARGET cannot matter to the trade in front of you. Raise it only if you are using it as swing context rather than as a scalp level.")
volAtrLen      = input.int(10, "VOL: ATR length", minval=2, maxval=100, group=grpTrk, tooltip="1.15.0. ATR length for the VOL @entry tercile. Default 10 matches the AlgoAlpha ML Adaptive SuperTrend this is borrowed from. Observe-only — feeds no gate, score, tier or alert.")
volRankLen     = input.int(100, "VOL: percentile window (bars)", minval=20, maxval=500, group=grpTrk, tooltip="1.15.0. Rolling window the entry-bar ATR is ranked against. Default 100 matches the borrowed script's training period. This is a RELATIVE measure: HI means loud FOR THIS SYMBOL RECENTLY, not loud in absolute terms. Longer = more stable bands, slower to acknowledge a regime shift.")
volLoPct       = input.float(33.3, "VOL: LO/MID cut (percentile)", minval=5.0, maxval=95.0, step=0.1, group=grpTrk, tooltip="1.15.0. Below this percentile the entry is tagged VOL LO. Default 33.3 gives even terciles, which is what keeps this a partition that cannot starve. Move the cuts apart and you buy cell size in one band by starving another — check the shares before reading any R.")
volHiPct       = input.float(66.7, "VOL: MID/HI cut (percentile)", minval=5.0, maxval=95.0, step=0.1, group=grpTrk, tooltip="1.15.0. At or above this percentile the entry is tagged VOL HI. Must be greater than the LO/MID cut; if it is not, MID collapses to zero and the LO/MID/HI rows will not sum to pool — on-paste check 4 catches that.")
showSwpLine    = input.bool(true, "Plot sweep level on chart (chart-matching TF)", group=grpTrk, tooltip="1.13.2. Draws the pending swept-pivot level for whichever engine slot matches the chart resolution (15m chart -> 15m slot, 30m -> 30m, 1h -> 1h) as a magenta stepline. Zero new security calls — the value is already unpacked from the tracker context. ONE line only: three would clutter the chart, and the chart-matching slot is the one you are trading.")

// ═══════════════════════════════════════════════════════════
// CORE 1 — EMA 9>21
// ═══════════════════════════════════════════════════════════
grpTrend = "═══ MTF Trend Panel (1.18.0 · display only) ═══"
showTrendPanel = input.bool(true, "Show MTF trend panel", group=grpTrend, tooltip="1.18.0. Port of the 'Predict' row from GainzAlgo Smart Money Structure v3.0. Display only — feeds nothing. NOT A PREDICTION: every input is present-tense (position vs HTF EMA20 and VWAP, 3-bar momentum, ATR vs its own average). It is a multi-timeframe agreement panel, not a forecast.")
trendPos = input.string("Bottom Center", "Trend panel position", options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group=grpTrend)
trendVolSym = input.bool(false, "Symmetric volatility term", group=grpTrend, tooltip="OFF (default) = faithful to the source: the volatility term adds +0.5 when ATR is above its average and 0 otherwise, NEVER -0.5. That one-directional term creates up arrows (trend 0 with positive momentum flips from ━ to ▲) and suppresses one down arrow (trend -1 with flat momentum reads ━ instead of ▼), giving a bullish tilt in high-volatility conditions. Kept OFF so this panel AGREES with the GainzAlgo indicator on the same chart. ON makes the term +0.5/-0.5. ⚠ The tilt lands in exactly the conditions VOL HI selects for, so do not treat this panel as independent corroboration of a VOL HI entry.")
trendSize = input.string("Small", "Trend panel text size", options=["Tiny","Small","Normal"], group=grpTrend, tooltip="1.18.1. Small (default) reproduces 1.18.0 exactly: header small, arrows normal. Tiny gives header tiny, arrows small — for phone screens. Separate from the main Dashboard text size because six glyphs stay readable much smaller than the full dashboard does.")
trendEmaLen = input.int(20, "Trend panel EMA length", minval=2, maxval=200, group=grpTrend)

grpEMA = "═══ CORE 1 — EMA 9>21 ═══"
emaFast = input.int(9, "EMA Fast", minval=1, group=grpEMA)
emaSlow = input.int(21, "EMA Slow", minval=1, group=grpEMA)

// ═══════════════════════════════════════════════════════════
// CORE 2 — VIDYA
// ═══════════════════════════════════════════════════════════
grpVidya = "═══ CORE 2 — VIDYA (BigBeluga) ═══"
vidya_length = input.int(10, "VIDYA Length", minval=2, maxval=50, group=grpVidya)
vidya_momentum = input.int(20, "VIDYA Momentum (CMO length)", minval=2, maxval=50, group=grpVidya)
vidya_armWin = input.int(2, "VIDYA arm window (bars from WVF)", minval=0, maxval=5, group=grpVidya)

// ═══════════════════════════════════════════════════════════
// SWING VWAP
// ═══════════════════════════════════════════════════════════
grpVwap = "═══ Swing VWAP (observable) ═══"
vwap_pivLen = input.int(10, "Swing VWAP: pivot lookback", minval=2, maxval=50, group=grpVwap)
vwap_atrLen = input.int(14, "Swing VWAP: ATR length", minval=2, maxval=50, group=grpVwap)
vwap_atrMlt = input.float(1.5,"Swing VWAP: pivot ATR mult", minval=0.1, maxval=10.0, step=0.1, group=grpVwap)
vwap_devLen = input.int(20, "Swing VWAP: deviation length", minval=5, maxval=100, group=grpVwap)
vwap_devMlt = input.float(2.0,"Swing VWAP: band multiplier", minval=0.5, maxval=5.0, step=0.1, group=grpVwap)

// ═══════════════════════════════════════════════════════════
// ANTI-SIGNAL / STOP — BB Break
// ═══════════════════════════════════════════════════════════
grpBB = "═══ ANTI-SIGNAL / STOP — BB Break ═══"
bb_length = input.int(20, "BB Length", minval=5, maxval=50, group=grpBB)
bb_mult = input.float(2.0,"BB Multiplier", minval=0.5, maxval=5.0, step=0.1, group=grpBB)

// ═══════════════════════════════════════════════════════════
// OBSERVABLE — OBV
// ═══════════════════════════════════════════════════════════
grpObs = "═══ OBSERVABLE (display only) ═══"
obv_len = input.int(8, "OBV Slope Lookback (bars)", minval=2, maxval=20, group=grpObs)

// ═══════════════════════════════════════════════════════════
// SWEEP-LITE
// ═══════════════════════════════════════════════════════════
grpSwp = "═══ Sweep-lite Observable ═══"
sweepReclaimBars = input.int(2, "Sweep: max bars for reclaim", minval=1, maxval=10, group=grpSwp)
sweepAtrMult = input.float(0.3,"Sweep: min wick size (× ATR)", minval=0.05, maxval=2.0, step=0.05, group=grpSwp)
sweepVolMult = input.float(1.3,"Sweep: volume spike (× 20-bar avg)",minval=1.0, maxval=3.0, step=0.1, group=grpSwp)

// ═══════════════════════════════════════════════════════════
// LIQUIDITY LEVELS
// ═══════════════════════════════════════════════════════════
grpLiq = "═══ Liquidity Levels (BSL / SSL) ═══"
liq_pivLen = input.int(10, "Pivot lookback (bars each side)", minval=3, maxval=30, group=grpLiq)
liq_tolerance = input.float(0.3,"Cluster tolerance (× ATR)", minval=0.05, maxval=1.0, step=0.05, group=grpLiq)
liq_lookback = input.int(50, "Pool match age (bars)", minval=10, maxval=200, group=grpLiq)
bsl_near_atr = input.float(1.5,"BSL 'close' display threshold (× ATR)", minval=0.3, maxval=5.0, step=0.1, group=grpLiq)
ssl_warn_atr = input.float(2.0,"SSL warning threshold (× ATR)", minval=0.3, maxval=5.0, step=0.1, group=grpLiq)
maxLiqPools = input.int(20, "Max liquidity pools tracked", minval=4, maxval=60, group=grpLiq)

// ═══════════════════════════════════════════════════════════
// STRUCTURE SL
// ═══════════════════════════════════════════════════════════
grpSL = "═══ Structure SL (advisory) ═══"
sl_pivLookback = input.int(20, "Structure SL: pivot lookback (bars)", minval=5, maxval=100, group=grpSL)
sl_pivSide = input.int(3, "Structure SL: pivot detection bars each side", minval=1, maxval=10, group=grpSL)
sl_bufMult = input.float(0.1, "Structure SL: ATR buffer below pivot", minval=0.0, maxval=1.0, step=0.05, group=grpSL)
sl_atrFallback = input.float(1.5, "Structure SL: ATR fallback multiplier (if no pivot)", minval=0.5, maxval=3.0, step=0.1, group=grpSL)

// ═══════════════════════════════════════════════════════════
// EXIT — CVI Top
// ═══════════════════════════════════════════════════════════
grpCvi = "═══ EXIT — CVI Top ═══"
cvi_len = input.int(3, "CVI length", minval=2, maxval=20, group=grpCvi)
cvi_bear_thresh = input.float(0.43,"CVI overbought threshold",minval=0.1, maxval=2.0, step=0.01, group=grpCvi)

// ═══════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════
f_safeDiv(_n, _d, _f) =>
    _d != 0 and not na(_n) and not na(_d) ? _n / _d : _f
f_clamp(_v, _lo, _hi) =>
    math.max(_lo, math.min(_hi, _v))

// ═══════════════════════════════════════════════════════════
// CHART-TF CALCULATIONS
// ═══════════════════════════════════════════════════════════
wvf_val = ((ta.highest(close, wvf_pd) - low) / ta.highest(close, wvf_pd)) * 100
wvf_sDev = wvf_mult * ta.stdev(wvf_val, wvf_bbl)
wvf_midLine = ta.sma(wvf_val, wvf_bbl)
wvf_upperBand = wvf_midLine + wvf_sDev
wvf_rangeHigh = ta.highest(wvf_val, wvf_lb) * wvf_ph
wvf_was_high = wvf_val[1] >= wvf_upperBand[1] or wvf_val[1] >= wvf_rangeHigh[1]
wvf_now_low = wvf_val < wvf_upperBand and wvf_val < wvf_rangeHigh
wvf_filtered_raw = wvf_was_high and wvf_now_low
wvf_upRange = low > low[1] and close > high[1]
wvf_downtrend = close < close[wvf_ltLB] or close < close[wvf_mtLB]
wvf_strength = close > close[wvf_str]
wvf_filtered = wvf_upRange and wvf_strength and wvf_downtrend and wvf_filtered_raw
bb_basis = ta.sma(close, bb_length)
bb_dev = ta.stdev(close, bb_length)
bb_upper = bb_basis + bb_mult * bb_dev
bb_lower = bb_basis - bb_mult * bb_dev
bb_lo_touch = low <= bb_lower
bb_break = close <= bb_lower
bb_reject = bb_lo_touch and close > bb_lower
wvfTop_val = ((ta.lowest(close, wvf_pd) - high) / ta.lowest(close, wvf_pd)) * 100
wvfTop_sDev = wvf_mult * ta.stdev(wvfTop_val, wvf_bbl)
wvfTop_mid = ta.sma(wvfTop_val, wvf_bbl)
wvfTop_lowerBand = wvfTop_mid - wvfTop_sDev
wvfTop_rangeLow = ta.lowest(wvfTop_val, wvf_lb) * wvf_ph
wvfTop_wasLow = wvfTop_val[1] <= wvfTop_lowerBand[1] or wvfTop_val[1] <= wvfTop_rangeLow[1]
wvfTop_nowHigh = wvfTop_val > wvfTop_lowerBand and wvfTop_val > wvfTop_rangeLow
wvfTop_signal = wvfTop_wasLow and wvfTop_nowHigh
cvi_hh = ta.highest(high, cvi_len)
cvi_ll = ta.lowest(low, cvi_len)
cvi_range = cvi_hh - cvi_ll
cvi_val = cvi_range > 0 ? (close - cvi_ll) / cvi_range : 0.5
cvi_top_signal = cvi_val[1] >= cvi_bear_thresh and cvi_val < cvi_bear_thresh
cvi_bot_thresh = 1.0 - cvi_bear_thresh
cvi_bot_signal = cvi_val[1] <= cvi_bot_thresh and cvi_val > cvi_bot_thresh

// ── MBI ──
mbi_mom_len_o = 10
mbi_bias_len_o = 5
mbi_smooth_len_o = 10
mbi_bound_len_o = 30
mbi_stddev_o = 3.0
mbi_mom_raw = close - close[mbi_mom_len_o]
mbi_hl_ema = ta.ema(high - low, mbi_mom_len_o)
mbi_norm = mbi_hl_ema > 0 ? mbi_mom_raw / mbi_hl_ema * 100 : 0.0
mbi_up_raw = math.max(mbi_norm, 0.0)
mbi_dn_raw = math.min(mbi_norm, 0.0)
mbi_up_bias = math.max(ta.hma(math.sum(mbi_up_raw, mbi_bias_len_o), mbi_smooth_len_o), 0.0)
mbi_dn_bias = math.max(ta.hma(-math.sum(mbi_dn_raw, mbi_bias_len_o), mbi_smooth_len_o), 0.0)
mbi_avg = math.avg(mbi_dn_bias, mbi_up_bias)
mbi_bound = ta.ema(mbi_avg, mbi_bound_len_o) + ta.stdev(mbi_avg, mbi_bound_len_o) * mbi_stddev_o
mbi_bull_sig = ta.crossunder(mbi_dn_bias, mbi_dn_bias[1]) and mbi_dn_bias > mbi_bound and mbi_dn_bias > mbi_up_bias
mbi_bear_sig = ta.crossunder(mbi_up_bias, mbi_up_bias[1]) and mbi_up_bias > mbi_bound and mbi_up_bias > mbi_dn_bias
mbi_bias_bull_state = mbi_up_bias > mbi_dn_bias

// ── BBAWE ──
bbawe_fast_len_o = 3
bbawe_ao_fast_o = 5
bbawe_ao_slow_o = 34
bbawe_fast_ma = ta.ema(close, bbawe_fast_len_o)
bbawe_ao_val = ta.sma(hl2, bbawe_ao_fast_o) - ta.sma(hl2, bbawe_ao_slow_o)
bbawe_ao_rising = bbawe_ao_val >= 0 and bbawe_ao_val > bbawe_ao_val[1]
bbawe_ao_falling = bbawe_ao_val < 0 and bbawe_ao_val < bbawe_ao_val[1]
bbawe_long_sig = ta.crossover(bbawe_fast_ma, bb_basis) and close > bb_basis and bbawe_ao_rising
bbawe_short_sig = ta.crossunder(bbawe_fast_ma, bb_basis) and close < bb_basis and bbawe_ao_falling

// ── BP ──
bp_obs_len = 20
bp_obs_green = math.sum(close >= open ? 1.0 : 0.0, bp_obs_len)
bp_obs_pct = bp_obs_len > 0 ? (bp_obs_green / bp_obs_len) * 100.0 : 50.0
bp_obs_bull = bp_obs_pct > 55.0
bp_obs_bear = bp_obs_pct < 45.0

// Swing VWAP
chart_atr_vwap = ta.atr(vwap_atrLen)
piv_high = ta.pivothigh(high, vwap_pivLen, vwap_pivLen)
piv_low = ta.pivotlow(low, vwap_pivLen, vwap_pivLen)
newPivot = false
if not na(piv_high)
    pivPx = high[vwap_pivLen]
    pivBar = bar_index - vwap_pivLen
    if na(lastPivPrice) or math.abs(pivPx - lastPivPrice) > chart_atr_vwap * vwap_atrMlt
        lastPivPrice := pivPx
        lastPivBar := pivBar
        lastPivIsHigh := true
        newPivot := true
if not na(piv_low)
    pivPx = low[vwap_pivLen]
    pivBar = bar_index - vwap_pivLen
    if na(lastPivPrice) or math.abs(pivPx - lastPivPrice) > chart_atr_vwap * vwap_atrMlt
        lastPivPrice := pivPx
        lastPivBar := pivBar
        lastPivIsHigh := false
        newPivot := true
if newPivot
    anchorBar := lastPivBar
    pvSum := 0.0
    vSum := 0.0
    pv2Sum := 0.0
if not na(anchorBar) and bar_index >= anchorBar
    src = hlc3
    pvSum := pvSum + src * volume
    vSum := vSum + volume
    pv2Sum := pv2Sum + src * src * volume
swingVwap = vSum > 0 ? pvSum / vSum : na
vwap_var = vSum > 0 ? math.max(pv2Sum / vSum - math.pow(swingVwap, 2), 0.0) : 0.0
vwap_sd = math.sqrt(vwap_var)
vwap_upper = swingVwap + vwap_devMlt * vwap_sd
vwap_lower = swingVwap - vwap_devMlt * vwap_sd
vwap_above = not na(swingVwap) and close > swingVwap

// HTF / BTC / ADX
htf_emaFast = request.security(syminfo.tickerid, htfBiasTF, ta.ema(close, htfFastLen), lookahead=barmerge.lookahead_off)
htf_emaSlow = request.security(syminfo.tickerid, htfBiasTF, ta.ema(close, htfSlowLen), lookahead=barmerge.lookahead_off)
htf_bull = htf_emaFast > htf_emaSlow
htf_bear = htf_emaFast < htf_emaSlow
[adx_diPlus, adx_diMinus, adx_val] = ta.dmi(adxLen, adxLen)
adx_trending = adx_val >= adxTrendThr
btc_close = request.security(btcSym, timeframe.period, close, lookahead=barmerge.lookahead_off)
btc_ema = request.security(btcSym, timeframe.period, ta.ema(close, btcEmaLen), lookahead=barmerge.lookahead_off)
btc_bull = btc_close > btc_ema

// EMA 9/21 chart-level
v22_ema9 = ta.ema(close, 9)
v22_ema21 = ta.ema(close, 21)
v22_ema_bull = v22_ema9 > v22_ema21
v22_ema_slope_up = v22_ema9 > v22_ema9[5]
v22_ema_slope_down = v22_ema9 < v22_ema9[5]
v22_ema_long_cond = v22_ema_bull and v22_ema_slope_up
v22_ema_short_cond = not v22_ema_bull and v22_ema_slope_down

// Bars-since latches
if wvf_filtered
    v22_wvf_bars_since_chart := 0
else
    v22_wvf_bars_since_chart := v22_wvf_bars_since_chart + 1
if bb_lo_touch
    v22_bblo_bars_since_chart := 0
else
    v22_bblo_bars_since_chart := v22_bblo_bars_since_chart + 1
if barstate.isnew
    v22_bblo_latch := false
    v22_bbup_latch := false
if bb_lo_touch
    v22_bblo_latch := true
if high >= bb_upper
    v22_bbup_latch := true

// ═══════════════════════════════════════════════════════════
// STRUCTURE SL
// ═══════════════════════════════════════════════════════════
f_structureSL() =>
    _atr14 = ta.atr(14)
    _pivSrc = ta.pivotlow(low, sl_pivSide, sl_pivSide)
    float _sl1 = na
    for _i = sl_pivSide to sl_pivLookback
        if na(_sl1) and not na(_pivSrc[_i - sl_pivSide])
            float _candidate = low[_i]
            if _candidate < close
                _sl1 := _candidate - _atr14 * sl_bufMult
    _sl2 = close - _atr14 * sl_atrFallback
    [_sl1, _sl2]

// ═══════════════════════════════════════════════════════════
// PER-TF FUNCTIONS
// ═══════════════════════════════════════════════════════════
f_wvfFiltered() =>
    _val = ((ta.highest(close, wvf_pd) - low) / ta.highest(close, wvf_pd)) * 100
    _sDev = wvf_mult * ta.stdev(_val, wvf_bbl)
    _mid = ta.sma(_val, wvf_bbl)
    _upperBand = _mid + _sDev
    _rangeHigh = ta.highest(_val, wvf_lb) * wvf_ph
    _wasHigh = _val[1] >= _upperBand[1] or _val[1] >= _rangeHigh[1]
    _nowLow = _val < _upperBand and _val < _rangeHigh
    _filteredRaw = _wasHigh and _nowLow
    _upRange = low > low[1] and close > high[1]
    _downtrend = close < close[wvf_ltLB] or close < close[wvf_mtLB]
    _strength = close > close[wvf_str]
    _upRange and _strength and _downtrend and _filteredRaw

f_bbBreak() =>
    _basis = ta.sma(close, bb_length)
    _dev = ta.stdev(close, bb_length)
    _lower = _basis - bb_mult * _dev
    close <= _lower

f_bbReject() =>
    _basis = ta.sma(close, bb_length)
    _dev = ta.stdev(close, bb_length)
    _lower = _basis - bb_mult * _dev
    low <= _lower and close > _lower

f_bbLoDist() =>
    _basis = ta.sma(close, bb_length)
    _dev = ta.stdev(close, bb_length)
    _lower = _basis - bb_mult * _dev
    (close - _lower) / _lower * 100

f_emaBull() => ta.ema(close, emaFast) > ta.ema(close, emaSlow)

f_emaSpread() =>
    _f = ta.ema(close, emaFast)
    _s = ta.ema(close, emaSlow)
    (_f - _s) / _s * 100

f_vidya() =>
    _momm = ta.change(close)
    _m1 = _momm >= 0.0 ? _momm : 0.0
    _m2 = _momm >= 0.0 ? 0.0 : -_momm
    _sm1 = math.sum(_m1, vidya_momentum)
    _sm2 = math.sum(_m2, vidya_momentum)
    _denom = _sm1 + _sm2
    _chandeMO = _denom != 0 ? (100 * (_sm1 - _sm2) / _denom) : 0.0
    _k = math.abs(_chandeMO) / 100.0
    _alpha = 2.0 / (vidya_length + 1)
    var float _vidya = na
    _vidya := na(_vidya[1]) ? close : (_alpha * _k * close + (1.0 - _alpha * _k) * _vidya[1])
    close > _vidya

f_vidyaValue() =>
    _momm = ta.change(close)
    _m1 = _momm >= 0.0 ? _momm : 0.0
    _m2 = _momm >= 0.0 ? 0.0 : -_momm
    _sm1 = math.sum(_m1, vidya_momentum)
    _sm2 = math.sum(_m2, vidya_momentum)
    _denom = _sm1 + _sm2
    _chandeMO = _denom != 0 ? (100 * (_sm1 - _sm2) / _denom) : 0.0
    _k = math.abs(_chandeMO) / 100.0
    _alpha = 2.0 / (vidya_length + 1)
    var float _vidya = na
    _vidya := na(_vidya[1]) ? close : (_alpha * _k * close + (1.0 - _alpha * _k) * _vidya[1])
    _vidya

f_obvSlope() =>
    _obv = ta.cum(close >= open ? volume : -volume)
    _obv > _obv[obv_len] ? 1 : (_obv < _obv[obv_len] ? -1 : 0)

f_deltaBull() =>
    _signed = (close >= open ? volume : -volume)
    ta.ema(_signed, deltaLen) > 0

f_wvfTopRaw() =>
    _val = ((ta.lowest(close, wvf_pd) - high) / ta.lowest(close, wvf_pd)) * 100
    _sDev = wvf_mult * ta.stdev(_val, wvf_bbl)
    _mid = ta.sma(_val, wvf_bbl)
    _lowerBand = _mid - _sDev
    _rangeLow = ta.lowest(_val, wvf_lb) * wvf_ph
    _wasLow = _val[1] <= _lowerBand[1] or _val[1] <= _rangeLow[1]
    _nowHigh = _val > _lowerBand and _val > _rangeLow
    _wasLow and _nowHigh

f_cvi() =>
    _hh = ta.highest(high, cvi_len)
    _ll = ta.lowest(low, cvi_len)
    _range = _hh - _ll
    _range > 0 ? (close - _ll) / _range : 0.5

f_cviTopSignal() =>
    _v = f_cvi()
    _v[1] >= cvi_bear_thresh and _v < cvi_bear_thresh

f_er(_len) =>
    _change = math.abs(close - close[_len])
    _volSum = math.sum(math.abs(close - close[1]), _len)
    _volSum > 0 ? math.min(_change / _volSum, 1.0) : 0.0

f_tqi() =>
    _er = f_er(tqi_erLen)
    _atrFast = ta.atr(tqi_volLen)
    _atrSlow = ta.sma(_atrFast, tqi_volLen * 2)
    _volRatio= _atrSlow > 0 ? _atrFast / _atrSlow : 1.0
    _volQ = math.min(math.max((_volRatio - 0.5) / 1.0, 0.0), 1.0)
    _smaStr = ta.sma(close, tqi_strLen)
    _strDist = _atrFast > 0 ? (close - _smaStr) / _atrFast : 0.0
    _strQ = math.min(math.max((_strDist + 2.0) / 4.0, 0.0), 1.0)
    _roc = close[tqi_momLen] > 0 ? (close - close[tqi_momLen]) / close[tqi_momLen] * 100 : 0.0
    _momQ = math.min(math.max((_roc + 5.0) / 10.0, 0.0), 1.0)
    (_er + _volQ + _strQ + _momQ) / 4.0

f_fvgBull() =>
    _gap = low - high[2]
    _hasGap = _gap > 0
    _bigEnuf = _hasGap and (_gap / close * 100.0) >= fvg_minPct
    _bigEnuf

f_sweepObs() =>
    _atr = ta.atr(14)
    _basis = ta.sma(close, bb_length)
    _dev = ta.stdev(close, bb_length)
    _bbUp = _basis + bb_mult * _dev
    _bbLo = _basis - bb_mult * _dev
    _volAvg20 = ta.sma(volume, 20)
    _volSpike = volume >= _volAvg20 * sweepVolMult
    _volSpikePrev = volume[1] >= ta.sma(volume, 20)[1] * sweepVolMult
    var float _sesHi = na
    var float _sesLo = na
    bool _newDay = ta.change(time("D")) != 0
    if _newDay
        _sesHi := high
        _sesLo := low
    else
        _sesHi := math.max(nz(_sesHi, high), high)
        _sesLo := math.min(nz(_sesLo, low), low)
    float _support = na
    if not na(_sesLo) and _sesLo < close
        _support := _sesLo
    if not na(_bbLo) and _bbLo < close
        if na(_support) or (close - _bbLo) < (close - _support)
            _support := _bbLo
    float _resist = na
    if not na(_sesHi) and _sesHi > close
        _resist := _sesHi
    if not na(_bbUp) and _bbUp > close
        if na(_resist) or (_bbUp - close) < (_resist - close)
            _resist := _bbUp
    bool _swLongRaw = false
    if not na(_support)
        bool _wickValid = (_support - low) >= _atr * sweepAtrMult
        bool _bodyAbove = open > _support or close > _support
        _swLongRaw := _wickValid and _bodyAbove
    bool _swShortRaw = false
    if not na(_resist)
        bool _wickValid = (high - _resist) >= _atr * sweepAtrMult
        bool _bodyBelow = open < _resist or close < _resist
        _swShortRaw := _wickValid and _bodyBelow
    var bool _longArmed = false
    var float _longLevel = na
    var int _longBar = na
    var bool _shortArmed = false
    var float _shortLevel = na
    var int _shortBar = na
    if _swLongRaw and not _longArmed
        _longArmed := true
        _longLevel := _support
        _longBar := bar_index
    if _swShortRaw and not _shortArmed
        _shortArmed := true
        _shortLevel := _resist
        _shortBar := bar_index
    if _longArmed and not na(_longBar) and (bar_index - _longBar) > sweepReclaimBars
        _longArmed := false
    if _shortArmed and not na(_shortBar) and (bar_index - _shortBar) > sweepReclaimBars
        _shortArmed := false
    bool _volOk = _volSpike or _volSpikePrev
    bool _longFired = _longArmed and close > _longLevel and close > open and _volOk
    bool _shortFired = _shortArmed and close < _shortLevel and close < open and _volOk
    if _longFired
        _longArmed := false
    if _shortFired
        _shortArmed := false
    int _sweepSig = _longFired ? 1 : _shortFired ? -1 : 0
    _sweepSig

// 1.13.2: replaces f_sweepCell(). The old cell reported f_sweepObs() —
// session hi/lo + BB bands, long AND short — while the DATA SWEEP / SWP+Q
// rows have ALWAYS measured the tracker's pivotlow(8,8) block. Two different
// detectors, one dashboard: you were eyeballing one and adjudicating on the
// other. This cell now reads the SAME block the DATA rows measure, shows the
// LEVEL, and shows its DISTANCE FROM PRICE.
// WHY DISTANCE IS THE POINT, not colour: trkSwpMaxDist = 80 bars means a 1h
// pivot can be THREE AND A HALF DAYS old and still display. Against a 1.5%
// target / 1.0% stop, a level 6% away is not something to watch — it is
// noise occupying a cell. Colour therefore follows DISTANCE:
//   ● green   swept in the arm window, quality >= trkSwpMinScore  (SWP+Q)
//   ● amber   swept in the arm window, quality <  trkSwpMinScore  (SWP loQ)
//   ○ magenta pending, within swpNearPct       — IN PLAY, bg-tinted
//   ○ cyan    pending, within swpRelevantPct   — worth knowing
//   ○ slate   pending, further out             — too far to matter
//   —         no live level (aged out, or price closed below it)
// Magenta deliberately matches the WVF bar/marker colour: the two hot states
// share one visual language. The _hot flag lets the call site apply the same
// background tint the TIER pills already use, so nothing new is invented.
// LOSS, NAMED: short sweeps no longer appear. The tracked block is long-only,
// which matches a long-only capitulation instrument.
// LAG, NAMED: a pivot is only KNOWN 8 bars after it forms (2h on 15m, 8h on
// 1h). The level is real and it existed; you learn about it late. That is the
// price of structural confirmation, not a defect — and it is why this uses
// pivotlow(8,8) rather than a running ta.lowest(low,N), which is not a
// defended level at all.
f_swpCell(_use, _pend, _lvl, _q, _age) =>
    bool  _fired = _age <= wvf_window and not na(_lvl)
    float _shown = _fired ? _lvl : _pend
    float _dist  = na(_shown) or close <= 0 ? na : (_shown - close) / close * 100.0
    float _absd  = na(_dist) ? na : math.abs(_dist)
    string _dtxt = na(_dist) ? "" : "\n" + (_dist >= 0 ? "+" : "−") + str.tostring(_absd, "#.0") + "%"
    string _txt  = not _use ? "·" : na(_shown) ? "—" : (_fired ? "● " : "○ ") + str.tostring(_shown, format.mintick) + _dtxt
    bool  _near  = not na(_absd) and _absd <= swpNearPct
    color _col   = not _use ? color.new(color.gray, 70) : na(_shown) ? color.new(color.gray, 45) : _fired ? (_q >= trkSwpMinScore ? color.new(#2FD082, 0) : color.new(#FFB454, 0)) : _near ? color.new(#DA70D6, 0) : (_absd <= swpRelevantPct ? color.new(#4FD8E8, 0) : color.new(#5A6580, 0))
    bool  _hot   = _use and not na(_shown) and (_fired or _near)
    [_txt, _col, _hot]

// ═══════════════════════════════════════════════════════════
// ENTRY EVALUATOR (per-TF)
// ═══════════════════════════════════════════════════════════
// 1.17.0: single source of truth for the VOL percentile. Called by f_eval
// (which SCORES it, since 1.17.0) and by f_trackDt (which REPORTS it). One
// definition means the VOL HI tracker row can never measure a different
// band from the one the score paid for. Runs in whatever context called it,
// so it costs zero new security calls.
f_volPct() =>
    ta.percentrank(ta.atr(volAtrLen), volRankLen)

f_eval(_scaleVetoOn) =>
    _wvfNow = f_wvfFiltered()
    _emaNow = f_emaBull()
    _vidyaNow = f_vidya()
    _bbBreakNow = f_bbBreak()
    _bbRejectNow = f_bbReject()
    _obvNow = f_obvSlope()
    _wvfTopNow = f_wvfTopRaw()
    _cviTopNow = f_cviTopSignal()
    _tqiNow = f_tqi()
    [_pDiscard, _mDiscard, _adxV] = ta.dmi(adxLen, adxLen)
    _prevTqi = _tqiNow[1]
    _trendAge = 0
    _charFlip = not na(_prevTqi) and _prevTqi > tqiCharHigh and _tqiNow < tqiGateLow and _trendAge >= tqiCharAge
    _wvfAge = -1
    for _i = 0 to wvf_window
        if _wvfAge == -1 and _wvfNow[_i]
            _wvfAge := _i
    _wvfArmed = _wvfAge >= 0
    _searchMax = wvf_window + coreWindow
    _emaAge = -1
    for _i = 0 to _searchMax
        if _emaAge == -1 and _emaNow[_i]
            _emaAge := _i
    _emaArmed = _wvfArmed and _emaAge >= 0 and _emaAge <= (_wvfAge + coreWindow)
    _vidyaAge = -1
    for _i = 0 to _searchMax
        if _vidyaAge == -1 and _vidyaNow[_i]
            _vidyaAge := _i
    _vidyaArmed = _wvfArmed and _vidyaAge >= 0 and _vidyaAge <= (_wvfAge + coreWindow)
    bool _obvBull = _obvNow == 1
    _deltaNow = f_deltaBull()
    _deltaSearch = wvf_window + deltaArmWin
    _deltaAge = -1
    for _i = 0 to _deltaSearch
        if _deltaAge == -1 and _deltaNow[_i]
            _deltaAge := _i
    _deltaArmed = _wvfArmed and _deltaAge >= 0 and _deltaAge <= (_wvfAge + deltaArmWin)
    _bbAntiSearch = wvf_window + antiWindow
    _bbAntiAge = -1
    for _i = 0 to _bbAntiSearch
        if _bbAntiAge == -1 and _bbBreakNow[_i]
            _bbAntiAge := _i
    _bbAnti = _wvfArmed and _bbAntiAge >= 0 and _bbAntiAge <= (_wvfAge + antiWindow)
    _fvgRaw = f_fvgBull()
    bool _fvgArmed = false
    for _i = 0 to wvf_window
        if _fvgRaw[_i]
            _fvgArmed := true
    _coreCount = ((_emaArmed and useEMACore) ? 1 : 0) + ((_vidyaArmed and useVidyaCore) ? 1 : 0)
    bool _wvfPass = (not useWVFGate) or _wvfArmed
    bool _gatesPass = _wvfPass
    bool _tqiContrib = useTqiScore and (_tqiNow >= tqiScoreThreshold)
    // 1.17.0: VOL bands, same definition the tracker reports. HI adds,
    // LO subtracts. wVOL_LO ships at 0.0 so the LO leg is inert by default.
    float _volPrE = f_volPct()
    bool  _volHiE = not na(_volPrE) and _volPrE >= volHiPct
    bool  _volLoE = not na(_volPrE) and _volPrE <  volLoPct
    float _score = ((_emaArmed and useEMACore) ? wEMA : 0.0) +
         ((_vidyaArmed and useVidyaCore) ? wVIDYA : 0.0) +
         (_obvBull ? wOBV : 0.0) +
         (_deltaArmed ? wDELTA : 0.0) +
         (_fvgArmed and useFVGScore ? wFVG : 0.0) +
         (_tqiContrib ? wTQI : 0.0) +
         (_volHiE ? wVOL_HI : 0.0) -
         (_volLoE ? wVOL_LO : 0.0)
    int _tier = 0
    if _gatesPass and _score >= scoreBaseMin
        if _score >= scoreScaleMin and _adxV < fullAdxMax
            _tier := 3
        else if _score >= scoreScaleMin
            _tier := 2
        else
            _tier := 1
    if useBBAnti and _bbAnti and _tier > 1
        _tier := _tier - 1
    // 1.10.0: SCALE-tier suppression — applied to the FINAL tier (post BB-anti),
    // matching the exact definition the tracker adjudicated. _scaleVetoOn=false
    // in the tracker path so measurement stays raw.
    bool _scaleVetoed = _scaleVetoOn and useScaleVeto and _tier == 2
    if _scaleVetoed
        _tier := 0
    _bbDist = f_bbLoDist()
    _emaSpr = f_emaSpread()
    _vidyaVal = f_vidyaValue()
    _pulseN = _tier > 0 and _tier != _tier[1]
    _lastPulseTimeN = ta.valuewhen(_pulseN, float(time), 0)
    _lastPulsePxN   = ta.valuewhen(_pulseN, close, 0)
    [_tier, _wvfArmed, _emaArmed, _vidyaArmed, _fvgArmed, _bbAnti, _bbBreakNow,
     _obvNow, _wvfTopNow, _cviTopNow, _charFlip,
     _wvfAge, _emaAge, _vidyaAge,
     _bbDist, _emaSpr, _vidyaVal, _bbRejectNow,
     _emaNow, _vidyaNow,
     _tqiNow, _adxV, _coreCount, _gatesPass,
     _score, _obvBull, _deltaArmed, _tqiContrib, _lastPulseTimeN, _lastPulsePxN, _scaleVetoed]

// ═══════════════════════════════════════════════════════════
// DASHBOARD-STABLE WRAPPER
// Returns f_eval's fields offset by one bar so the dashboard reads the last
// CLOSED bar of each requested timeframe. The [1] is applied per-field after
// the tuple is unpacked (offsetting a tuple directly is not allowed in Pine).
// ═══════════════════════════════════════════════════════════
f_evalDisp() =>
    [e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11, e12, e13, e14, e15, e16, e17, e18, e19, e20, e21, e22, e23, e24, e25, e26, e27, e28, e29, e30, e31] = f_eval(true)
    [e1[1], e2[1], e3[1], e4[1], e5[1], e6[1], e7[1], e8[1], e9[1], e10[1], e11[1], e12[1], e13[1], e14[1], e15[1], e16[1], e17[1], e18[1], e19[1], e20[1], e21[1], e22[1], e23[1], e24[1], e25[1], e26[1], e27[1], e28[1]]

// ═══════════════════════════════════════════════════════════
// 1.09.0: VALIDATION TRACKER (observe-only) — runs f_eval() inside its OWN
// lookahead_off security context per TF, so adjudication never touches the
// six frozen lookahead_on display calls. Single-position, first-touch
// brackets, fixed % target/stop, timeout close. WIN = target hit only.
// ═══════════════════════════════════════════════════════════
f_trackDt(_tfMin) =>
    [e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11, e12, e13, e14, e15, e16, e17, e18, e19, e20, e21, e22, e23, e24, e25, e26, e27, e28, e29, e30, e31] = f_eval(false)
    int _tierT = e1
    bool _fvgT = e5
    float _tqiT = e21
    float _adxT = e22
    bool _deltaT = e27
    bool _tqiCT = e28
    // regime at entry — mirrors Cockpit _reg exactly; ADX threshold = fullAdxMax
    float _erT = f_er(20)
    int _regT = _adxT < fullAdxMax and _erT < 0.35 ? 0 : _adxT < fullAdxMax ? 1 : 2
    // ── 1.12.0 TREND DIRECTION (observe-only). Computed in THIS context, so
    //    historically exact and repaint-free. Costs ZERO new security calls.
    float _dirF  = ta.ema(close, dirFastLen)
    float _dirS  = ta.ema(close, dirSlowLen)
    bool  _dirUp = _dirF > _dirS
    // TQI dead-zone band (TF-specific bounds for 1h, matching the gate inputs)
    float _dzLo = _tfMin == 60 ? tqiDeadZoneLow_60m : tqiDeadZoneLow
    float _dzHi = _tfMin == 60 ? tqiDeadZoneHigh_60m : tqiDeadZoneHigh
    bool _dzT = _tqiT >= _dzLo and _tqiT < _dzHi
    // ── SWEEP tags: VERBATIM Cockpit v28.9.4 f_track block (Mirage LSP port) ──
    float _swAtr = ta.atr(14)
    float _swPl = ta.pivotlow(trkSwpPivLen, trkSwpPivLen)
    var float _swL1 = na
    var int _swB1 = na
    var float _swL2 = na
    var int _swB2 = na
    if not na(_swPl)
        _swL2 := _swL1
        _swB2 := _swB1
        _swL1 := _swPl
        _swB1 := bar_index - trkSwpPivLen
    if not na(_swL1) and (bar_index - _swB1) > trkSwpMaxDist
        _swL1 := na
    if not na(_swL2) and (bar_index - _swB2) > trkSwpMaxDist
        _swL2 := na
    float _swRng = high - low
    bool _swpBarB = false
    float _swpQBar = 0.0
    float _swHitLvl = na
    if not na(_swL1) and low < _swL1 and close > _swL1
        _swpBarB := true
        _swHitLvl := _swL1
        _swL1 := na
    else if not na(_swL2) and low < _swL2 and close > _swL2
        _swpBarB := true
        _swHitLvl := _swL2
        _swL2 := na
    if _swpBarB and _swRng > 0 and _swAtr > 0
        float _swWick = math.min(open, close) - low
        float _swRcl = close - _swHitLvl
        float _swCp = (close - low) / _swRng
        float _swWickC = math.min(math.max(_swWick, 0.0) / _swAtr, 1.0)
        float _swRclC = math.min(math.max(_swRcl, 0.0) / _swAtr, 1.0)
        _swpQBar := (_swWickC * 0.40 + _swRclC * 0.333 + _swCp * 0.267) * 100.0
    if not na(_swL1) and close < _swL1
        _swL1 := na
    if not na(_swL2) and close < _swL2
        _swL2 := na
    bool _swpWin = false
    bool _swqWin = false
    for _k3 = 0 to wvf_window
        if _swpBarB[_k3]
            _swpWin := true
            if _swpQBar[_k3] >= trkSwpMinScore
                _swqWin := true
    // ── 1.13.2 DISPLAY-ONLY LATCH. The dashboard Sweep row needs to show WHAT
    //    was swept, but _swL1/_swL2 are set to na the instant a sweep fires,
    //    so a naive read blanks at exactly the moment you want the number.
    //    These three vars snapshot the level and its quality at the fire bar.
    //    They are READ-ONLY consumers of values that already exist: no entry
    //    is created, retimed or re-priced, no accumulator moves, and nothing
    //    below reads them. Every DATA row must be byte-identical to 1.13.1.
    var float _swpLastLvl = na
    var float _swpLastQ   = 0.0
    var int   _swpLastBar = na
    if _swpBarB
        _swpLastLvl := _swHitLvl
        _swpLastQ   := _swpQBar
        _swpLastBar := bar_index
    int   _swpAge  = na(_swpLastBar) ? 9999 : bar_index - _swpLastBar
    float _swpPend = not na(_swL1) ? _swL1 : _swL2
    // ── 1.15.0 VOL @ENTRY — OBSERVE-ONLY, ZERO NEW SECURITY CALLS ─────────
    //   Entry-bar ATR ranked against its own rolling window, cut into
    //   terciles. A PARTITION: every entry gets exactly one band, so share
    //   is ~33% by construction and cannot starve. Causal — percentrank
    //   reads only closed prior bars. No lookahead, no iteration, no state.
    float _volPr  = f_volPct()
    bool  _volLoT = not na(_volPr) and _volPr <  volLoPct
    bool  _volHiT = not na(_volPr) and _volPr >= volHiPct
    // ── 1.09.1: first replay bar of THIS context (constant from bar 1) + auto-halves ──
    var int _t0 = na
    if na(_t0)
        _t0 := time
    float _bnd = (_t0 + timenow) / 2.0
    bool _modeOk = trkMode == "Full" or (trkMode == "1st half (auto)" ? time < _bnd : time >= _bnd)
    // ── entry: FRESH tier only (tier[1]==0); banner _pulseN re-pulses on upgrades ──
    bool _fire = _tierT > 0 and _tierT[1] == 0 and time >= trkStart and time <= trkEnd and _modeOk
    int _hBars = math.max(1, math.round(trkMaxHours * 60.0 / _tfMin))
    float _tgtF = 1.0 + trkTgtPct / 100.0
    float _stpF = 1.0 - trkStopPct / 100.0
    // trade state + entry-tag capture
    var bool _inT = false
    var float _e = na
    var int _eb = na
    var bool _tTq = false
    var bool _tDz = false
    var bool _tFv = false
    var bool _tDl = false
    var bool _tG = false
    var bool _tY = false
    var bool _tT1 = false
    var bool _tT2 = false
    var bool _tSw = false
    var bool _tSq = false
    var bool _tUp = false
    var bool _tUpG = false
    var bool _tUpY = false
    var bool _tVlo = false
    var bool _tVhi = false
    var bool _tVhg = false
    // accumulators: base + 10 tag trios (res / tgt-hits / sum R)
    var int _r0 = 0
    var int _g0 = 0
    var float _x0 = 0.0
    var int _rTq = 0
    var int _gTq = 0
    var float _xTq = 0.0
    var int _rDz = 0
    var int _gDz = 0
    var float _xDz = 0.0
    var int _rFv = 0
    var int _gFv = 0
    var float _xFv = 0.0
    var int _rDl = 0
    var int _gDl = 0
    var float _xDl = 0.0
    var int _rG = 0
    var int _gG = 0
    var float _xG = 0.0
    var int _rY = 0
    var int _gY = 0
    var float _xY = 0.0
    var int _rT1 = 0
    var int _gT1 = 0
    var float _xT1 = 0.0
    var int _rT2 = 0
    var int _gT2 = 0
    var float _xT2 = 0.0
    var int _rSw = 0
    var int _gSw = 0
    var float _xSw = 0.0
    var int _rSq = 0
    var int _gSq = 0
    var float _xSq = 0.0
    var int _rUp = 0
    var int _gUp = 0
    var float _xUp = 0.0
    var int _rUpG = 0
    var int _gUpG = 0
    var float _xUpG = 0.0
    var int _rUpY = 0
    var int _gUpY = 0
    var float _xUpY = 0.0
    var int _rVlo = 0
    var int _gVlo = 0
    var float _xVlo = 0.0
    var int _rVhi = 0
    var int _gVhi = 0
    var float _xVhi = 0.0
    var int _rVhg = 0
    var int _gVhg = 0
    var float _xVhg = 0.0
    var int _s0 = 0
    var int _sVlo = 0
    var int _sVhi = 0
    float _R = na
    bool _closed = false
    bool _isTgt = false
    // 1.16.0: exit-reason flag. Set in the SAME branch that already won the
    // same-bar tie, so bracket precedence is unchanged. Timeout is derived
    // as _closed and not _isTgt and not _isStp — never stored.
    bool _isStp = false
    if _inT and bar_index > _eb
        bool _hitS = low <= _e * _stpF
        bool _hitT = high >= _e * _tgtF
        if _hitS
            _R := -1.0
            _isStp := true
            _closed := true
        else if _hitT
            _R := trkTgtPct / trkStopPct
            _isTgt := true
            _closed := true
        else if bar_index - _eb >= _hBars
            _R := (close - _e) / _e * 100.0 / trkStopPct
            _closed := true
    if _closed
        _r0 += 1
        _x0 += _R
        if _isTgt
            _g0 += 1
        if _isStp
            _s0 += 1
        if _tTq
            _rTq += 1
            _xTq += _R
            if _isTgt
                _gTq += 1
        if _tDz
            _rDz += 1
            _xDz += _R
            if _isTgt
                _gDz += 1
        if _tFv
            _rFv += 1
            _xFv += _R
            if _isTgt
                _gFv += 1
        if _tDl
            _rDl += 1
            _xDl += _R
            if _isTgt
                _gDl += 1
        if _tG
            _rG += 1
            _xG += _R
            if _isTgt
                _gG += 1
        if _tY
            _rY += 1
            _xY += _R
            if _isTgt
                _gY += 1
        if _tT1
            _rT1 += 1
            _xT1 += _R
            if _isTgt
                _gT1 += 1
        if _tT2
            _rT2 += 1
            _xT2 += _R
            if _isTgt
                _gT2 += 1
        if _tSw
            _rSw += 1
            _xSw += _R
            if _isTgt
                _gSw += 1
        if _tSq
            _rSq += 1
            _xSq += _R
            if _isTgt
                _gSq += 1
        if _tUp
            _rUp += 1
            _xUp += _R
            if _isTgt
                _gUp += 1
        if _tUpG
            _rUpG += 1
            _xUpG += _R
            if _isTgt
                _gUpG += 1
        if _tUpY
            _rUpY += 1
            _xUpY += _R
            if _isTgt
                _gUpY += 1
        if _tVlo
            _rVlo += 1
            _xVlo += _R
            if _isTgt
                _gVlo += 1
            if _isStp
                _sVlo += 1
        if _tVhi
            _rVhi += 1
            _xVhi += _R
            if _isTgt
                _gVhi += 1
            if _isStp
                _sVhi += 1
        if _tVhg
            _rVhg += 1
            _xVhg += _R
            if _isTgt
                _gVhg += 1
        _inT := false
        _e := na
        _eb := na
    if _fire and not _inT
        _inT := true
        _e := close
        _eb := bar_index
        _tTq := _tqiCT
        _tDz := _dzT
        _tFv := _fvgT
        _tDl := _deltaT
        _tG := _regT == 0
        _tY := _regT == 1
        _tT1 := _tierT == 1
        _tT2 := _tierT == 2
        _tSw := _swpWin
        _tSq := _swqWin
        _tUp := _dirUp
        _tUpG := _dirUp and _regT == 0
        _tUpY := _dirUp and _regT == 1
        _tVlo := _volLoT
        _tVhi := _volHiT
        _tVhg := _volHiT and _regT == 0
    [_r0, _g0, _x0, _rTq, _gTq, _xTq, _rDz, _gDz, _xDz, _rFv, _gFv, _xFv, _rDl, _gDl, _xDl, _rG, _gG, _xG, _rY, _gY, _xY, _rT1, _gT1, _xT1, _rT2, _gT2, _xT2, _rSw, _gSw, _xSw, _rSq, _gSq, _xSq, _rUp, _gUp, _xUp, _rUpG, _gUpG, _xUpG, _rUpY, _gUpY, _xUpY, _dirUp, _t0, _swpPend, _swpLastLvl, _swpLastQ, _swpAge, _rVlo, _gVlo, _xVlo, _rVhi, _gVhi, _xVhi, _rVhg, _gVhg, _xVhg, _s0, _sVlo, _sVhi]

// ═══════════════════════════════════════════════════════════
// MTF EVALUATOR — 15m + 30m + 1h
// ═══════════════════════════════════════════════════════════
[tier_30m, wvfA_30m, emaA_30m, vidyaA_30m, fvgA_30m, bbAnti_30m, bbBreakN_30m,
 obvN_30m, wvfTopN_30m, cviTopN_30m, charFlip_30m,
 wvfAge_30m, emaAge_30m, vidyaAge_30m,
 bbDist_30m, emaSpr_30m, vidyaVal_30m, bbReject_30m,
 emaRaw_30m, vidyaRaw_30m,
 tqi_30m, adx_30m, coreCount_30m, gatesPass_30m,
 score_30m, obvBull_30m, deltaArmed_30m, tqiContrib_30m, lastPulseTime_30m, lastPulsePx_30m, scVeto_30m] = request.security(syminfo.tickerid, "30", f_eval(true), lookahead=barmerge.lookahead_off)

[tier_60m, wvfA_60m, emaA_60m, vidyaA_60m, fvgA_60m, bbAnti_60m, bbBreakN_60m,
 obvN_60m, wvfTopN_60m, cviTopN_60m, charFlip_60m,
 wvfAge_60m, emaAge_60m, vidyaAge_60m,
 bbDist_60m, emaSpr_60m, vidyaVal_60m, bbReject_60m,
 emaRaw_60m, vidyaRaw_60m,
 tqi_60m, adx_60m, coreCount_60m, gatesPass_60m,
 score_60m, obvBull_60m, deltaArmed_60m, tqiContrib_60m, lastPulseTime_60m, lastPulsePx_60m, scVeto_60m] = request.security(syminfo.tickerid, "60", f_eval(true), lookahead=barmerge.lookahead_off)

[tier_15m, wvfA_15m, emaA_15m, vidyaA_15m, fvgA_15m, bbAnti_15m, bbBreakN_15m,
 obvN_15m, wvfTopN_15m, cviTopN_15m, charFlip_15m,
 wvfAge_15m, emaAge_15m, vidyaAge_15m,
 bbDist_15m, emaSpr_15m, vidyaVal_15m, bbReject_15m,
 emaRaw_15m, vidyaRaw_15m,
 tqi_15m, adx_15m, coreCount_15m, gatesPass_15m,
 score_15m, obvBull_15m, deltaArmed_15m, tqiContrib_15m, lastPulseTime_15m, lastPulsePx_15m, scVeto_15m] = request.security(syminfo.tickerid, "15", f_eval(true), lookahead=barmerge.lookahead_off)

// 1.09.0: tracker calls — lookahead_OFF, separate from the frozen engine calls
[k15r0, k15g0, k15x0, k15rTq, k15gTq, k15xTq, k15rDz, k15gDz, k15xDz, k15rFv, k15gFv, k15xFv, k15rDl, k15gDl, k15xDl, k15rG, k15gG, k15xG, k15rY, k15gY, k15xY, k15rT1, k15gT1, k15xT1, k15rT2, k15gT2, k15xT2, k15rSw, k15gSw, k15xSw, k15rSq, k15gSq, k15xSq, k15rUp, k15gUp, k15xUp, k15rUpG, k15gUpG, k15xUpG, k15rUpY, k15gUpY, k15xUpY, k15dirUp, k15t0, k15swPend, k15swLvl, k15swQ, k15swAge, k15rVlo, k15gVlo, k15xVlo, k15rVhi, k15gVhi, k15xVhi, k15rVhg, k15gVhg, k15xVhg, k15s0, k15sVlo, k15sVhi] = request.security(syminfo.tickerid, "15", f_trackDt(15), lookahead=barmerge.lookahead_off)
[k30r0, k30g0, k30x0, k30rTq, k30gTq, k30xTq, k30rDz, k30gDz, k30xDz, k30rFv, k30gFv, k30xFv, k30rDl, k30gDl, k30xDl, k30rG, k30gG, k30xG, k30rY, k30gY, k30xY, k30rT1, k30gT1, k30xT1, k30rT2, k30gT2, k30xT2, k30rSw, k30gSw, k30xSw, k30rSq, k30gSq, k30xSq, k30rUp, k30gUp, k30xUp, k30rUpG, k30gUpG, k30xUpG, k30rUpY, k30gUpY, k30xUpY, k30dirUp, k30t0, k30swPend, k30swLvl, k30swQ, k30swAge, k30rVlo, k30gVlo, k30xVlo, k30rVhi, k30gVhi, k30xVhi, k30rVhg, k30gVhg, k30xVhg, k30s0, k30sVlo, k30sVhi] = request.security(syminfo.tickerid, "30", f_trackDt(30), lookahead=barmerge.lookahead_off)
[k60r0, k60g0, k60x0, k60rTq, k60gTq, k60xTq, k60rDz, k60gDz, k60xDz, k60rFv, k60gFv, k60xFv, k60rDl, k60gDl, k60xDl, k60rG, k60gG, k60xG, k60rY, k60gY, k60xY, k60rT1, k60gT1, k60xT1, k60rT2, k60gT2, k60xT2, k60rSw, k60gSw, k60xSw, k60rSq, k60gSq, k60xSq, k60rUp, k60gUp, k60xUp, k60rUpG, k60gUpG, k60xUpG, k60rUpY, k60gUpY, k60xUpY, k60dirUp, k60t0, k60swPend, k60swLvl, k60swQ, k60swAge, k60rVlo, k60gVlo, k60xVlo, k60rVhi, k60gVhi, k60xVhi, k60rVhg, k60gVhg, k60xVhg, k60s0, k60sVlo, k60sVhi] = request.security(syminfo.tickerid, "60", f_trackDt(60), lookahead=barmerge.lookahead_off)

// 1.13.2: the three f_sweepObs() security calls are REMOVED. Their only
// consumer was the dashboard Sweep row, which now reads the tracker's
// pivotlow(8,8) block — the same detector the DATA SWEEP / SWP+Q rows
// adjudicate. The pend30/60/15_swp vars they also fed are written and
// NEVER READ anywhere in this file (verified by grep, not assumed).
// SECURITY BUDGET 17 -> 14. This matters more here than anywhere else in
// the suite: 1.12.2 was cut specifically because this file threw "Memory
// limits exceeded" on every chart above 1h across 17 contexts. Three
// fewer contexts is direct headroom against that failure. No tracked
// number can move.

deadZone_30m = useTqiDeadZone and tqi_30m >= tqiDeadZoneLow and tqi_30m < tqiDeadZoneHigh
deadZone_60m = useTqiDeadZone and tqi_60m >= tqiDeadZoneLow_60m and tqi_60m < tqiDeadZoneHigh_60m
deadZone_15m = useTqiDeadZone and tqi_15m >= tqiDeadZoneLow and tqi_15m < tqiDeadZoneHigh
tier_30m_e = (useTF1 and not deadZone_30m) ? tier_30m : 0
tier_60m_e = (useTF2 and not deadZone_60m) ? tier_60m : 0
tier_15m_e = (useTF3 and not deadZone_15m) ? tier_15m : 0

btcBlocksFull = useBtcFullGate and not btc_bull
tier_30m_e := (btcBlocksFull and tier_30m_e == 3) ? 2 : tier_30m_e
tier_60m_e := (btcBlocksFull and tier_60m_e == 3) ? 2 : tier_60m_e
tier_15m_e := (btcBlocksFull and tier_15m_e == 3) ? 2 : tier_15m_e

// 1.13.0: ROLE SEPARATION. The tracker showed the edge is strongest on 15m
// (+.06R -> +.09R across halves), while 30m and 1h were net drags. We therefore
// make 15m the execution TF without deleting higher-TF context or exits.
entryTier_30m = primary15mOnly ? 0 : tier_30m_e
entryTier_60m = primary15mOnly ? 0 : tier_60m_e
entryTier_15m = tier_15m_e
maxTier = math.max(math.max(entryTier_30m, entryTier_60m), entryTier_15m)
anyEntry = maxTier > 0

// ═══════════════════════════════════════════════════════════
// MTF EVALUATOR — DASHBOARD-STABLE COPY (closed bars only)
// Mirrors the live evaluator above exactly, but reads f_evalDisp() so the
// dashboard never shows an intrabar/forming-bar value. Entries, exits, and
// alerts above are untouched — they still use the live tier_Xm/score_Xm.
// ═══════════════════════════════════════════════════════════
[tier_30m_d, wvfA_30m_d, emaA_30m_d, vidyaA_30m_d, fvgA_30m_d, bbAnti_30m_d, bbBreakN_30m_d,
 obvN_30m_d, wvfTopN_30m_d, cviTopN_30m_d, charFlip_30m_d,
 wvfAge_30m_d, emaAge_30m_d, vidyaAge_30m_d,
 bbDist_30m_d, emaSpr_30m_d, vidyaVal_30m_d, bbReject_30m_d,
 emaRaw_30m_d, vidyaRaw_30m_d,
 tqi_30m_d, adx_30m_d, coreCount_30m_d, gatesPass_30m_d,
 score_30m_d, obvBull_30m_d, deltaArmed_30m_d, tqiContrib_30m_d] = request.security(syminfo.tickerid, "30", f_evalDisp(), lookahead=barmerge.lookahead_on)

[tier_60m_d, wvfA_60m_d, emaA_60m_d, vidyaA_60m_d, fvgA_60m_d, bbAnti_60m_d, bbBreakN_60m_d,
 obvN_60m_d, wvfTopN_60m_d, cviTopN_60m_d, charFlip_60m_d,
 wvfAge_60m_d, emaAge_60m_d, vidyaAge_60m_d,
 bbDist_60m_d, emaSpr_60m_d, vidyaVal_60m_d, bbReject_60m_d,
 emaRaw_60m_d, vidyaRaw_60m_d,
 tqi_60m_d, adx_60m_d, coreCount_60m_d, gatesPass_60m_d,
 score_60m_d, obvBull_60m_d, deltaArmed_60m_d, tqiContrib_60m_d] = request.security(syminfo.tickerid, "60", f_evalDisp(), lookahead=barmerge.lookahead_on)

[tier_15m_d, wvfA_15m_d, emaA_15m_d, vidyaA_15m_d, fvgA_15m_d, bbAnti_15m_d, bbBreakN_15m_d,
 obvN_15m_d, wvfTopN_15m_d, cviTopN_15m_d, charFlip_15m_d,
 wvfAge_15m_d, emaAge_15m_d, vidyaAge_15m_d,
 bbDist_15m_d, emaSpr_15m_d, vidyaVal_15m_d, bbReject_15m_d,
 emaRaw_15m_d, vidyaRaw_15m_d,
 tqi_15m_d, adx_15m_d, coreCount_15m_d, gatesPass_15m_d,
 score_15m_d, obvBull_15m_d, deltaArmed_15m_d, tqiContrib_15m_d] = request.security(syminfo.tickerid, "15", f_evalDisp(), lookahead=barmerge.lookahead_on)

deadZone_30m_d = useTqiDeadZone and tqi_30m_d >= tqiDeadZoneLow and tqi_30m_d < tqiDeadZoneHigh
deadZone_60m_d = useTqiDeadZone and tqi_60m_d >= tqiDeadZoneLow_60m and tqi_60m_d < tqiDeadZoneHigh_60m
deadZone_15m_d = useTqiDeadZone and tqi_15m_d >= tqiDeadZoneLow and tqi_15m_d < tqiDeadZoneHigh
tier_30m_e_d = (useTF1 and not deadZone_30m_d) ? tier_30m_d : 0
tier_60m_e_d = (useTF2 and not deadZone_60m_d) ? tier_60m_d : 0
tier_15m_e_d = (useTF3 and not deadZone_15m_d) ? tier_15m_d : 0

tier_30m_e_d := (btcBlocksFull and tier_30m_e_d == 3) ? 2 : tier_30m_e_d
tier_60m_e_d := (btcBlocksFull and tier_60m_e_d == 3) ? 2 : tier_60m_e_d
tier_15m_e_d := (btcBlocksFull and tier_15m_e_d == 3) ? 2 : tier_15m_e_d

// ═══════════════════════════════════════════════════════════
// ADR EXHAUSTION
// ═══════════════════════════════════════════════════════════
grpADR = "═══ ADR Exhaustion (observe) ═══"
adr_atrLen = input.int(14, "ADR: daily ATR length (typical-move baseline)", minval=2, maxval=50, group=grpADR)
adr_cautionPct = input.float(80.0,  "ADR: caution % (flag only)",   minval=10, maxval=200, step=5, group=grpADR)
adr_exhaustPct = input.float(100.0, "ADR: exhaustion % (flag only)", minval=10, maxval=250, step=5, group=grpADR)
adrGateMode = input.string("Off (observe only)", "ADR: gate mode", options=["Off (observe only)", "Block when spent (momentum logic)", "Confirm/boost when stretched (mean-rev logic)"], group=grpADR, tooltip="Leave OFF to collect data. The two live modes are scaffolding for later testing and are NOT wired into the tier ladder yet.")

adr_dailyAtr = request.security(syminfo.tickerid, "D", ta.atr(adr_atrLen)[1], lookahead=barmerge.lookahead_off)
var float adr_dayHi = na
var float adr_dayLo = na
if ta.change(time("D")) != 0
    adr_dayHi := high
    adr_dayLo := low
else
    adr_dayHi := math.max(nz(adr_dayHi, high), high)
    adr_dayLo := math.min(nz(adr_dayLo, low),  low)
adr_rangeUsed  = adr_dayHi - adr_dayLo
adr_pctUsed    = adr_dailyAtr > 0 ? (adr_rangeUsed / adr_dailyAtr) * 100 : 0.0
adr_posInRange = adr_rangeUsed > 0 ? (close - adr_dayLo) / adr_rangeUsed * 100 : na
adr_caution    = adr_pctUsed >= adr_cautionPct and adr_pctUsed < adr_exhaustPct
adr_exhausted  = adr_pctUsed >= adr_exhaustPct

adr_fire = maxTier > 0 and (na(maxTier[1]) or maxTier[1] == 0 or maxTier > maxTier[1])
adr_modeCode = adrGateMode == "Off (observe only)" ? 0 : adrGateMode == "Block when spent (momentum logic)" ? 1 : 2

plot(adr_pctUsed, "ADR % used", display=display.data_window)
plot(adr_posInRange, "ADR pos-in-range", display=display.data_window)
plot(adr_fire ? adr_pctUsed : na, "ADR % @ fire", display=display.data_window)
plot(adr_fire ? adr_posInRange : na, "ADR pos @ fire", display=display.data_window)
plot(adr_modeCode, "ADR mode (0=off)", display=display.data_window)

// ═══════════════════════════════════════════════════════════
// LIQUIDITY POOL ENGINE
// ═══════════════════════════════════════════════════════════
type LiqPool
    float level
    float top
    float bot
    int touches
    int lastTouchBar
    int firstTime
    bool isHigh
    bool swept
    box zbox
    label zlbl
var array<LiqPool> liqPools = array.new<LiqPool>()
float liqAtr = ta.atr(14)
float liqTol = liqAtr * liq_tolerance
float _liqPH = ta.pivothigh(high, liq_pivLen, liq_pivLen)
float _liqPL = ta.pivotlow(low, liq_pivLen, liq_pivLen)

f_liqMatch(float _px, bool _isHigh, float _tol) =>
    int _found = -1
    if liqPools.size() > 0
        for _i = 0 to liqPools.size() - 1
            LiqPool _p = liqPools.get(_i)
            if _found == -1 and not _p.swept and _p.isHigh == _isHigh and math.abs(_px - _p.level) <= _tol and (bar_index - _p.lastTouchBar) <= liq_lookback
                _found := _i
    _found

if not na(_liqPH) and bar_index > liq_pivLen + 5
    float _lvl = high[liq_pivLen]
    int _mi = f_liqMatch(_lvl, true, liqTol)
    if _mi >= 0
        LiqPool _p = liqPools.get(_mi)
        _p.level := (_p.level * _p.touches + _lvl) / (_p.touches + 1)
        _p.top := _p.level + liqTol / 2.0
        _p.bot := _p.level - liqTol / 2.0
        _p.touches := _p.touches + 1
        _p.lastTouchBar := bar_index
    else
        box _nb = box.new(time[liq_pivLen], _lvl + liqTol / 2.0, time, _lvl - liqTol / 2.0, border_color=color.new(#ff6f43, 0), bgcolor=color.new(#ff6f43, 88), border_width=1, xloc=xloc.bar_time)
        label _nl = label.new(time, _lvl, "", color=color.new(color.black, 100), textcolor=color.new(#ff6f43, 0), style=label.style_label_left, size=size.tiny, xloc=xloc.bar_time)
        liqPools.push(LiqPool.new(_lvl, _lvl + liqTol / 2.0, _lvl - liqTol / 2.0, 1, bar_index, time[liq_pivLen], true, false, _nb, _nl))

if not na(_liqPL) and bar_index > liq_pivLen + 5
    float _lvl = low[liq_pivLen]
    int _mi = f_liqMatch(_lvl, false, liqTol)
    if _mi >= 0
        LiqPool _p = liqPools.get(_mi)
        _p.level := (_p.level * _p.touches + _lvl) / (_p.touches + 1)
        _p.top := _p.level + liqTol / 2.0
        _p.bot := _p.level - liqTol / 2.0
        _p.touches := _p.touches + 1
        _p.lastTouchBar := bar_index
    else
        box _nb = box.new(time[liq_pivLen], _lvl + liqTol / 2.0, time, _lvl - liqTol / 2.0, border_color=color.new(#22bac5, 0), bgcolor=color.new(#22bac5, 88), border_width=1, xloc=xloc.bar_time)
        label _nl = label.new(time, _lvl, "", color=color.new(color.black, 100), textcolor=color.new(#22bac5, 0), style=label.style_label_left, size=size.tiny, xloc=xloc.bar_time)
        liqPools.push(LiqPool.new(_lvl, _lvl + liqTol / 2.0, _lvl - liqTol / 2.0, 1, bar_index, time[liq_pivLen], false, false, _nb, _nl))

if liqPools.size() > 0 and barstate.isconfirmed
    for _i = 0 to liqPools.size() - 1
        LiqPool _p = liqPools.get(_i)
        if not _p.swept and ((_p.isHigh and close > _p.top) or (not _p.isHigh and close < _p.bot))
            _p.swept := true

if liqPools.size() > maxLiqPools
    int _vic = -1
    for _i = 0 to liqPools.size() - 1
        if _vic == -1 and liqPools.get(_i).swept
            _vic := _i
    if _vic == -1
        _vic := 0
    LiqPool _pv = liqPools.get(_vic)
    box.delete(_pv.zbox)
    label.delete(_pv.zlbl)
    liqPools.remove(_vic)

float liqNearSSL = na
int liqNearSSLt = 0
float liqNearBSL = na
int liqNearBSLt = 0
float _dNearSSL = 1e9
float _dNearBSL = 1e9
if liqPools.size() > 0
    for _i = 0 to liqPools.size() - 1
        LiqPool _p = liqPools.get(_i)
        if not _p.swept
            if _p.isHigh and _p.level > close and (_p.level - close) < _dNearSSL
                _dNearSSL := _p.level - close
                liqNearSSL := _p.level
                liqNearSSLt := _p.touches
            if not _p.isHigh and _p.level < close and (close - _p.level) < _dNearBSL
                _dNearBSL := close - _p.level
                liqNearBSL := _p.level
                liqNearBSLt := _p.touches

sslDist = na(liqNearSSL) ? na : (liqNearSSL - close) / math.max(liqAtr, 0.0001)
bslDist = na(liqNearBSL) ? na : (close - liqNearBSL) / math.max(liqAtr, 0.0001)
anySslNear = not na(sslDist) and sslDist <= ssl_warn_atr
anyBslNear = not na(bslDist) and bslDist <= bsl_near_atr
chart_tqi = f_tqi()
chart_charFlip = not na(chart_tqi[1]) and chart_tqi[1] > tqiCharHigh and chart_tqi < tqiGateLow

// ═══════════════════════════════════════════════════════════
// STRUCTURE SL (chart-TF)
// ═══════════════════════════════════════════════════════════
[sl1_price, sl2_price] = f_structureSL()

// ═══════════════════════════════════════════════════════════
// EXIT LOGIC
// ═══════════════════════════════════════════════════════════
rawNewTier_30m = not primary15mOnly and tier_30m_e > 0 and tier_30m_e[1] != tier_30m_e
rawNewTier_60m = not primary15mOnly and tier_60m_e > 0 and tier_60m_e[1] != tier_60m_e
rawNewTier_15m = tier_15m_e > 0 and tier_15m_e[1] != tier_15m_e


var int pend30_ctr = -1
var int pend30_tier = 0
var int pend60_ctr = -1
var int pend60_tier = 0
var int pend15_ctr = -1
var int pend15_tier = 0
var int pend30_fvg = 0
var int pend60_fvg = 0
var int pend15_fvg = 0

if rawNewTier_30m
    pend30_ctr := offsetBars_30m
    pend30_tier := tier_30m
    pend30_fvg := fvgA_30m ? 1 : 0
bool offNewTier_30m = false
int offTier_30m = 0
if pend30_ctr == 0
    offNewTier_30m := true
    offTier_30m := pend30_tier
if pend30_ctr >= 0
    pend30_ctr := pend30_ctr - 1

if rawNewTier_60m
    pend60_ctr := offsetBars_60m
    pend60_tier := tier_60m
    pend60_fvg := fvgA_60m ? 1 : 0
bool offNewTier_60m = false
int offTier_60m = 0
if pend60_ctr == 0
    offNewTier_60m := true
    offTier_60m := pend60_tier
if pend60_ctr >= 0
    pend60_ctr := pend60_ctr - 1

if rawNewTier_15m
    pend15_ctr := offsetBars_15m
    pend15_tier := tier_15m
    pend15_fvg := fvgA_15m ? 1 : 0
bool offNewTier_15m = false
int offTier_15m = 0
if pend15_ctr == 0
    offNewTier_15m := true
    offTier_15m := pend15_tier
if pend15_ctr >= 0
    pend15_ctr := pend15_ctr - 1

newTier_30m = offNewTier_30m
newTier_60m = offNewTier_60m
newTier_15m = offNewTier_15m
newAnyEntry = newTier_30m or newTier_60m or newTier_15m
recentEntry = newAnyEntry or (newAnyEntry[1] and bar_index - 1 < statusBarWindow * 10)

if newAnyEntry
    array.push(active_entry_bars, bar_index)
if array.size(active_entry_bars) > 0
    for _i = array.size(active_entry_bars) - 1 to 0
        if bar_index - array.get(active_entry_bars, _i) > stopWindow
            array.remove(active_entry_bars, _i)
hasActiveEntry = array.size(active_entry_bars) > 0

// Stateless auto-trade (BANNER ONLY). In-trade iff the most-recent NATIVE entry pulse on any
// enabled TF is within autoMaxMinutes of now; entry price/TF come from that pulse (ta.valuewhen
// inside f_eval) -- no var memory, so the banner reads identically on every chart resolution.
// Time-window is the only clear (no price-based exit). Parallel to engine; touches no tracker state.
float _nowMs = float(timenow)
float _winMs = autoMaxMinutes * 60000.0
float _pt15 = (useTF3 and not na(lastPulseTime_15m) and (_nowMs - lastPulseTime_15m) < _winMs) ? lastPulseTime_15m : na
float _pt30 = (useTF1 and not na(lastPulseTime_30m) and (_nowMs - lastPulseTime_30m) < _winMs) ? lastPulseTime_30m : na
float _pt60 = (useTF2 and not na(lastPulseTime_60m) and (_nowMs - lastPulseTime_60m) < _winMs) ? lastPulseTime_60m : na
float _ptMax = math.max(math.max(nz(_pt15, 0.0), nz(_pt30, 0.0)), nz(_pt60, 0.0))
bool   autoInTrade  = _ptMax > 0
float  entryFlashPx = na
string entryFlashTF = ""
if autoInTrade
    if not na(_pt60) and _pt60 == _ptMax
        entryFlashPx := lastPulsePx_60m
        entryFlashTF := "1h"
    else if not na(_pt30) and _pt30 == _ptMax
        entryFlashPx := lastPulsePx_30m
        entryFlashTF := "30m"
    else
        entryFlashPx := lastPulsePx_15m
        entryFlashTF := "15m"

bbBreak_30m = useBBStop ? bbBreakN_30m : false
bbBreak_60m = useBBStop ? bbBreakN_60m : false
bbBreak_15m = useBBStop ? bbBreakN_15m : false
wvfTop_30m = useExitWvfTop ? wvfTopN_30m : false
wvfTop_60m = useExitWvfTop ? wvfTopN_60m : false
wvfTop_15m = useExitWvfTop ? wvfTopN_15m : false
cviTop_30m = useExitCviTop ? cviTopN_30m : false
cviTop_60m = useExitCviTop ? cviTopN_60m : false
cviTop_15m = useExitCviTop ? cviTopN_15m : false

charFlipFired = useExitCharFlip and (charFlip_30m or charFlip_60m or charFlip_15m or chart_charFlip)
int _lastEntryBar = hasActiveEntry ? array.get(active_entry_bars, array.size(active_entry_bars) - 1) : 0
inExitCooldown = hasActiveEntry and (bar_index - _lastEntryBar < exitCooldownBars)

bool exitBB_any = bbBreak_30m or bbBreak_60m or bbBreak_15m
bool exitWvf_any = wvfTop_30m or wvfTop_60m or wvfTop_15m
bool exitCvi_any = cviTop_30m or cviTop_60m or cviTop_15m
bool newExitBB_pulse = exitBB_any and not prev_exitBB
bool newExitWvf_pulse = exitWvf_any and not prev_exitWvf
bool newExitCvi_pulse = exitCvi_any and not prev_exitCvi

if not hasActiveEntry or inExitCooldown
    newExitBB_pulse := false
    newExitWvf_pulse := false
    newExitCvi_pulse := false
prev_exitBB := exitBB_any
prev_exitWvf := exitWvf_any
prev_exitCvi := exitCvi_any

bool anyNewExit = newExitBB_pulse or newExitWvf_pulse or newExitCvi_pulse
if anyNewExit
    if not exitWatchActive
        exitWatchActive := true
        exitWatchBar := bar_index
        exitWatchCount := 0
        exitWatchHadBB := false
        exitWatchHadWvf := false
        exitWatchHadCvi := false
    if newExitBB_pulse and not exitWatchHadBB
        exitWatchHadBB := true
        exitWatchCount := exitWatchCount + 1
    if newExitWvf_pulse and not exitWatchHadWvf
        exitWatchHadWvf := true
        exitWatchCount := exitWatchCount + 1
    if newExitCvi_pulse and not exitWatchHadCvi
        exitWatchHadCvi := true
        exitWatchCount := exitWatchCount + 1

if exitWatchActive and (bar_index - exitWatchBar > exitCountWindow)
    exitWatchActive := false
    exitWatchCount := 0
    exitWatchHadBB := false
    exitWatchHadWvf := false
    exitWatchHadCvi := false

if not hasActiveEntry
    exitWatchActive := false
    exitWatchCount := 0
    exitWatchHadBB := false
    exitWatchHadWvf := false
    exitWatchHadCvi := false

bool sslEscalate = anySslNear and hasActiveEntry
newExitHalf = anyNewExit and exitWatchCount == 1 and not charFlipFired and not sslEscalate
newExitFull = (anyNewExit and exitWatchCount >= 2) or (charFlipFired and hasActiveEntry) or (anyNewExit and sslEscalate)

if charFlipFired and hasActiveEntry
    exitWatchActive := false
    exitWatchCount := 0
    exitWatchHadBB := false
    exitWatchHadWvf := false
    exitWatchHadCvi := false

// ═══════════════════════════════════════════════════════════
// RE-ENTRY WATCH LOGIC
// ═══════════════════════════════════════════════════════════
if newExitFull
    reEntryWatchOn := true
    reEntryWatchBar := bar_index
if reEntryWatchOn and not na(reEntryWatchBar) and (bar_index - reEntryWatchBar > reEntryWindow)
    reEntryWatchOn := false
    reEntryWatchBar := na
if newAnyEntry
    reEntryWatchOn := false
    reEntryWatchBar := na

bool reEntrySignal = reEntryWatchOn and newAnyEntry == false and
     (wvfA_30m or wvfA_60m or wvfA_15m) and
     (entryTier_30m >= 1 or entryTier_60m >= 1 or entryTier_15m >= 1) and
     not newAnyEntry

if reEntrySignal
    reEntryWatchOn := false
    reEntryWatchBar := na

trk_tf_min = timeframe.in_seconds(timeframe.period) / 60.0

// ═══════════════════════════════════════════════════════════
// ATF (Adaptive Trend Finder)
// ═══════════════════════════════════════════════════════════
f_calcDev(int length) =>
    float sumX = 0.0
    float sumXX = 0.0
    float sumYX = 0.0
    float sumY = 0.0
    for i = 1 to length
        float lSrc = math.log(nz(close[i - 1]))
        sumX += i
        sumXX += i * i
        sumYX += i * lSrc
        sumY += lSrc
    float slope_v = nz((length * sumYX - sumX * sumY) / (length * sumXX - sumX * sumX))
    float average = sumY / length
    float intercept_v = average - slope_v * sumX / length + slope_v
    float sumDev = 0.0
    float sumDxx = 0.0
    float sumDyy = 0.0
    float sumDyx = 0.0
    float regres = intercept_v + slope_v * (length - 1) * 0.5
    float sumSlp = intercept_v
    for i = 0 to length - 1
        float lSrc = math.log(nz(close[i]))
        float dxt = lSrc - average
        float dyt = sumSlp - regres
        lSrc := lSrc - sumSlp
        sumSlp += slope_v
        sumDxx += dxt * dxt
        sumDyy += dyt * dyt
        sumDyx += dxt * dyt
        sumDev += lSrc * lSrc
    float unStdDev = math.sqrt(sumDev / (length - 1))
    float divisor = sumDxx * sumDyy
    float pearsonR_v = divisor > 0 ? nz(sumDyx / math.sqrt(divisor)) : 0.0
    [unStdDev, pearsonR_v, slope_v, intercept_v]

if use_atf and barstate.islast
    int p1 = atf_long_term ? 300 : 20
    int p2 = atf_long_term ? 350 : 30
    int p3 = atf_long_term ? 400 : 40
    int p4 = atf_long_term ? 450 : 50
    int p5 = atf_long_term ? 500 : 60
    int p6 = atf_long_term ? 550 : 70
    int p7 = atf_long_term ? 600 : 80
    int p8 = atf_long_term ? 650 : 90
    int p9 = atf_long_term ? 700 : 100
    int p10 = atf_long_term ? 750 : 110
    int p11 = atf_long_term ? 800 : 120
    int p12 = atf_long_term ? 850 : 130
    int p13 = atf_long_term ? 900 : 140
    int p14 = atf_long_term ? 950 : 150
    int p15 = atf_long_term ? 1000 : 160
    int p16 = atf_long_term ? 1050 : 170
    int p17 = atf_long_term ? 1100 : 180
    int p18 = atf_long_term ? 1150 : 190
    int p19 = atf_long_term ? 1200 : 200
    [sd1, pr1, sl1, ic1] = f_calcDev(p1)
    [sd2, pr2, sl2, ic2] = f_calcDev(p2)
    [sd3, pr3, sl3, ic3] = f_calcDev(p3)
    [sd4, pr4, sl4, ic4] = f_calcDev(p4)
    [sd5, pr5, sl5, ic5] = f_calcDev(p5)
    [sd6, pr6, sl6, ic6] = f_calcDev(p6)
    [sd7, pr7, sl7, ic7] = f_calcDev(p7)
    [sd8, pr8, sl8, ic8] = f_calcDev(p8)
    [sd9, pr9, sl9, ic9] = f_calcDev(p9)
    [sd10, pr10, sl10, ic10] = f_calcDev(p10)
    [sd11, pr11, sl11, ic11] = f_calcDev(p11)
    [sd12, pr12, sl12, ic12] = f_calcDev(p12)
    [sd13, pr13, sl13, ic13] = f_calcDev(p13)
    [sd14, pr14, sl14, ic14] = f_calcDev(p14)
    [sd15, pr15, sl15, ic15] = f_calcDev(p15)
    [sd16, pr16, sl16, ic16] = f_calcDev(p16)
    [sd17, pr17, sl17, ic17] = f_calcDev(p17)
    [sd18, pr18, sl18, ic18] = f_calcDev(p18)
    [sd19, pr19, sl19, ic19] = f_calcDev(p19)
    float highest = math.max(pr1, pr2, pr3, pr4, pr5, pr6, pr7, pr8, pr9, pr10, pr11, pr12, pr13, pr14, pr15, pr16, pr17, pr18, pr19)
    atf_pearson := highest
    if highest == pr1
        atf_period := p1, atf_slope := sl1, atf_intrcpt := ic1, atf_stddev := sd1
    else if highest == pr2
        atf_period := p2, atf_slope := sl2, atf_intrcpt := ic2, atf_stddev := sd2
    else if highest == pr3
        atf_period := p3, atf_slope := sl3, atf_intrcpt := ic3, atf_stddev := sd3
    else if highest == pr4
        atf_period := p4, atf_slope := sl4, atf_intrcpt := ic4, atf_stddev := sd4
    else if highest == pr5
        atf_period := p5, atf_slope := sl5, atf_intrcpt := ic5, atf_stddev := sd5
    else if highest == pr6
        atf_period := p6, atf_slope := sl6, atf_intrcpt := ic6, atf_stddev := sd6
    else if highest == pr7
        atf_period := p7, atf_slope := sl7, atf_intrcpt := ic7, atf_stddev := sd7
    else if highest == pr8
        atf_period := p8, atf_slope := sl8, atf_intrcpt := ic8, atf_stddev := sd8
    else if highest == pr9
        atf_period := p9, atf_slope := sl9, atf_intrcpt := ic9, atf_stddev := sd9
    else if highest == pr10
        atf_period := p10, atf_slope := sl10, atf_intrcpt := ic10, atf_stddev := sd10
    else if highest == pr11
        atf_period := p11, atf_slope := sl11, atf_intrcpt := ic11, atf_stddev := sd11
    else if highest == pr12
        atf_period := p12, atf_slope := sl12, atf_intrcpt := ic12, atf_stddev := sd12
    else if highest == pr13
        atf_period := p13, atf_slope := sl13, atf_intrcpt := ic13, atf_stddev := sd13
    else if highest == pr14
        atf_period := p14, atf_slope := sl14, atf_intrcpt := ic14, atf_stddev := sd14
    else if highest == pr15
        atf_period := p15, atf_slope := sl15, atf_intrcpt := ic15, atf_stddev := sd15
    else if highest == pr16
        atf_period := p16, atf_slope := sl16, atf_intrcpt := ic16, atf_stddev := sd16
    else if highest == pr17
        atf_period := p17, atf_slope := sl17, atf_intrcpt := ic17, atf_stddev := sd17
    else if highest == pr18
        atf_period := p18, atf_slope := sl18, atf_intrcpt := ic18, atf_stddev := sd18
    else
        atf_period := p19, atf_slope := sl19, atf_intrcpt := ic19, atf_stddev := sd19
    if atf_period > 0
        float endPrice_now = math.exp(atf_intrcpt)
        atf_upper_now := endPrice_now * math.exp(atf_dev_mult * atf_stddev)
        atf_lower_now := endPrice_now / math.exp(atf_dev_mult * atf_stddev)

if show_atf_channel and atf_period > 0
    float startPrice = math.exp(atf_intrcpt + atf_slope * (atf_period - 1))
    float endPrice = math.exp(atf_intrcpt)
    int startBar = bar_index - atf_period + 1
    float upStart = startPrice * math.exp(atf_dev_mult * atf_stddev)
    float upEnd = endPrice * math.exp(atf_dev_mult * atf_stddev)
    float loStart = startPrice / math.exp(atf_dev_mult * atf_stddev)
    float loEnd = endPrice / math.exp(atf_dev_mult * atf_stddev)
    line.delete(atf_upperLine)
    line.delete(atf_lowerLine)
    atf_line_col = not use_atf or atf_pearson < atf_strength_min ? color.new(color.gray, 40) : atf_slope < 0 ? color.new(#00ff9d, 20) : color.new(#ff4560, 20)
    atf_upperLine := line.new(startBar, upStart, bar_index, upEnd, color=atf_line_col, width=2, extend=extend.right)
    atf_lowerLine := line.new(startBar, loStart, bar_index, loEnd, color=atf_line_col, width=2, extend=extend.right)

atf_direction = (not use_atf or atf_pearson < atf_strength_min) ? "FLAT" : (atf_slope < 0 ? "UP" : "DOWN")
atf_strength_label = atf_pearson < 0.5 ? "WEAK" : atf_pearson < 0.7 ? "MOD" : atf_pearson < 0.85 ? "STRONG" : "VSTRONG"

// ═══════════════════════════════════════════════════════════
// REGIME SIZING LAYER
// ═══════════════════════════════════════════════════════════
// ── 1.13.3: REGIME REALIGNED TO THE ADJUDICATED DEFINITION ──────────────
// DEFECT FIXED: the dashboard REGIME chip and this file's own DATA table
// have always reported DIFFERENT VARIABLES under the same three words.
//   dashboard (old): ATF Pearson direction + adx_val < regime_adx_cap (30)
//   DATA rows:       _adxT < fullAdxMax (25) AND _erT < 0.35
// Different inputs, different thresholds, and no ER at all on the dashboard
// side. So the chip's "GREEN" and the DATA table's "GREEN @entry" row were
// unrelated measurements wearing the same label — you read one and
// adjudicated the other. Third instance of this defect class in this suite
// (after the two sweep detectors), and the reason it had to be fixed HERE:
// the new icon row prints "❄️ RANGING" on GREEN, and the old ATF GREEN meant
// a strong directional TREND. The label would have been flatly false.
// Now byte-for-byte the tracker's formula, on chart-TF values. The chip
// finally agrees with the GREEN @entry / YELLOW @entry / RED @entry rows.
// DISPLAY-ONLY: regime_mode feeds the chip, regime_size_note, and
// _regimeBonus -> the hero power bar. It has never fed the gate, the score,
// the tier, the alerts or the tracker. NO DATA ROW MOVES.
// ⚠ The hero POWER BAR will read differently than the prior build on the same chart,
// because _regimeBonus now keys off a different boolean. That is the
// intended consequence, not a regression — the bar was being bonused by a
// regime the tracker never measured.
// ATF direction is NOT lost: it still renders in the ATF/BTC row.
// regime_r_strong and regime_adx_cap are retained as inputs for rollback.
float chart_er = f_er(20)
string regime_mode = adx_val < fullAdxMax and chart_er < 0.35 ? "GREEN" : adx_val < fullAdxMax ? "YELLOW" : "RED"
string regime_size_note = regime_mode == "GREEN" ? "2× SCALE / 1× BASE" : regime_mode == "YELLOW" ? "1.5× SCALE / 1× BASE" : "1× (RED regime)"
color regime_color = regime_mode == "GREEN" ? color.new(#00ff9d, 0) : regime_mode == "YELLOW" ? color.new(color.yellow, 0) : color.new(#ff4560, 0)

// ═══════════════════════════════════════════════════════════
// STATUS BAR STATE
// ═══════════════════════════════════════════════════════════
string statusState = "WAIT"
if newExitFull
    statusState := "EXIT FULL"
else if exitWatchActive
    statusState := "WARNING"
else if reEntrySignal
    statusState := "RE-ENTRY"
else if hasActiveEntry
    statusState := "STAY IN"
else if recentEntry
    statusState := "GET IN"

color statusColor = switch statusState
    "EXIT FULL" => color.new(color.red, 0)
    "WARNING" => color.new(color.orange, 0)
    "RE-ENTRY" => color.new(#ff9d00, 0)
    "STAY IN" => color.new(color.aqua, 0)
    "GET IN" => color.new(#00ff9d, 0)
    => color.new(color.gray, 30)

f_tierName(int t) =>
    t == 3 ? "FULL" : t == 2 ? "SCALE" : t == 1 ? "BASE" : "—"

string statusDetail = ""
if statusState == "EXIT FULL"
    statusDetail := charFlipFired ? "⚡ char-flip · close remainder" : "▼▼ close remainder"
else if statusState == "WARNING"
    statusDetail := "⚠ EXIT HALF · " + str.tostring(exitWatchCount) + "/2"
else if statusState == "RE-ENTRY"
    int _reTier = math.max(math.max(entryTier_30m, entryTier_60m), entryTier_15m)
    statusDetail := "↺ " + f_tierName(_reTier) + " · watch fired"
else if statusState == "STAY IN"
    string _cdNote = inExitCooldown ? " · cooldown" : ""
    string _sslNote = anySslNear ? " · ⚠SSL" : ""
    statusDetail := "holding · " + str.tostring(array.size(active_entry_bars)) + " active" + _cdNote + _sslNote
else if statusState == "GET IN"
    int _shownTier = math.max(math.max(entryTier_30m, entryTier_60m), entryTier_15m)
    string _tfStr = newTier_60m ? "1h" : newTier_30m ? "30m" : newTier_15m ? "15m" : (recentEntry ? "recent" : "")
    statusDetail := f_tierName(_shownTier) + " " + _tfStr + (primary15mOnly ? " · 15m primary" : "")
else
    statusDetail := "—"

// ═══════════════════════════════════════════════════════════
// PLOTS
// ═══════════════════════════════════════════════════════════
plot(showBB ? bb_lower : na, "BB Lower", color=color.new(#4488ff, 0), linewidth=2)
plot(showBB ? bb_basis : na, "BB Basis", color=color.new(#4488ff, 0), linewidth=2)
plot(showBB ? bb_upper : na, "BB Upper", color=color.new(#4488ff, 0), linewidth=2)
plot(showSwingVwap ? swingVwap : na, "Swing VWAP", color=color.new(#E8A020, 0), linewidth=2)
plot(showSwingVwap ? vwap_upper : na, "Swing VWAP Upper", color=color.new(#E8A020, 70), linewidth=1, display=display.none)
plot(showSwingVwap ? vwap_lower : na, "Swing VWAP Lower", color=color.new(#E8A020, 70), linewidth=1, display=display.none)
plot(showEma50 ? ta.ema(close, ema50Len) : na, "EMA 50", color=color.new(#7FBFFF, 0), linewidth=2)
plot(showSma50 ? ta.sma(close, sma50Len) : na, "SMA 50", color=color.new(color.yellow, 0), linewidth=2)
// 1.13.2: pending swept-pivot level for whichever engine slot matches the
// chart resolution. A table cell is a poor place to watch a price level;
// this puts it where price is. Thresholds are the SAME 15.5 / 35.0 used by
// _activeTFcol, so the line and the highlighted dashboard column can never
// disagree. ZERO new security calls — k15/k30/k60swPend are already
// unpacked from the tracker contexts.
float swpChartLvl = trk_tf_min <= 15.5 ? k15swPend : trk_tf_min <= 35.0 ? k30swPend : k60swPend
plot(showSwpLine ? swpChartLvl : na, "Sweep level (chart TF)", color=color.new(#DA70D6, 30), style=plot.style_stepline, linewidth=1)
plotshape(showWvfMark and wvf_filtered, title="WVF Filtered", style=shape.triangleup, location=location.belowbar, color=color.new(#DA70D6, 0), size=size.small)
plotshape(showBbBreakMark and bb_break, title="BB Break", style=shape.triangledown, location=location.abovebar, color=color.new(color.red, 0), size=size.tiny)
plotshape(showWvfTopMark and wvfTop_signal, title="WVF Top", style=shape.xcross, location=location.abovebar, color=color.new(color.red, 0), size=size.tiny)
plotshape(showCviTopMark and cvi_top_signal, title="CVI Top", style=shape.diamond, location=location.abovebar, color=color.new(color.red, 0), size=size.tiny, text="*", textcolor=color.new(color.red, 0))
plotshape(showCharFlipMark and chart_charFlip, title="Char-Flip", style=shape.diamond, location=location.abovebar, color=color.new(color.red, 0), size=size.small, text="⚡", textcolor=color.new(color.yellow, 0))
plotshape(showBbReject and bb_reject, title="BB Reject", style=shape.circle, location=location.belowbar, color=color.new(color.aqua, 0), size=size.tiny)
bgColor = showBgTint and anyEntry ? (maxTier == 3 ? color.new(color.aqua, 85) : maxTier == 2 ? color.new(color.lime, 85) : color.new(color.yellow, 88)) : na
bgcolor(bgColor, title="Entry Tier Tint")
barcolor(showWvfBarColor and wvf_filtered ? color.new(#DA70D6, 0) : na, title="WVF Bar Color")

// ═══════════════════════════════════════════════════════════
// LIQUIDITY ZONES
// ═══════════════════════════════════════════════════════════
if barstate.islast and liqPools.size() > 0
    int _nSSLi = -1
    int _nBSLi = -1
    float _bSSLd = 1e9
    float _bBSLd = 1e9
    for _i = 0 to liqPools.size() - 1
        LiqPool _p = liqPools.get(_i)
        if not _p.swept
            if _p.isHigh and _p.level > close and (_p.level - close) < _bSSLd
                _bSSLd := _p.level - close
                _nSSLi := _i
            if not _p.isHigh and _p.level < close and (close - _p.level) < _bBSLd
                _bBSLd := close - _p.level
                _nBSLi := _i
    int _liqRT = time + 3 * (time - time[1])
    for _i = 0 to liqPools.size() - 1
        LiqPool _p = liqPools.get(_i)
        if not showLiqZones
            box.set_left(_p.zbox, time)
            box.set_right(_p.zbox, time)
            label.set_text(_p.zlbl, "")
        else if _p.swept
            box.set_left(_p.zbox, _p.firstTime)
            box.set_right(_p.zbox, _liqRT)
            box.set_top(_p.zbox, _p.top)
            box.set_bottom(_p.zbox, _p.bot)
            box.set_border_color(_p.zbox, color.new(color.gray, 65))
            box.set_bgcolor(_p.zbox, color.new(color.gray, 92))
            label.set_text(_p.zlbl, "")
        else if _i == _nSSLi or _i == _nBSLi
            color _zc = _p.isHigh ? #ff6f43 : #22bac5
            box.set_left(_p.zbox, _p.firstTime)
            box.set_right(_p.zbox, _liqRT)
            box.set_top(_p.zbox, _p.top)
            box.set_bottom(_p.zbox, _p.bot)
            box.set_border_color(_p.zbox, color.new(_zc, 0))
            box.set_bgcolor(_p.zbox, color.new(_zc, 86))
            label.set_x(_p.zlbl, _liqRT)
            label.set_y(_p.zlbl, _p.level)
            label.set_text(_p.zlbl, (_p.isHigh ? "SSL ×" : "BSL ×") + str.tostring(_p.touches))
            label.set_textcolor(_p.zlbl, color.new(_zc, 0))
        else
            box.set_left(_p.zbox, time)
            box.set_right(_p.zbox, time)
            label.set_text(_p.zlbl, "")

// ═══════════════════════════════════════════════════════════
// LABELS
// ═══════════════════════════════════════════════════════════
if showTriggerLbl and newAnyEntry
    int _t = newTier_60m ? offTier_60m : newTier_30m ? offTier_30m : newTier_15m ? offTier_15m : 0
    color _col = _t == 3 ? color.new(color.aqua, 0) : _t == 2 ? color.new(color.lime, 0) : color.new(color.yellow, 0)
    bool _isRepeat = hasActiveEntry[1]
    if _isRepeat
        label.new(bar_index, low, "▲", style=label.style_label_up, color=_col, textcolor=color.black, size=size.tiny, yloc=yloc.belowbar)
    else
        string _lbl = "▲ " + f_tierName(_t)
        label.new(bar_index, low, _lbl, style=label.style_label_up, color=_col, textcolor=color.black, size=size.small, yloc=yloc.belowbar)

if showExitLbl and newExitHalf
    string _sig = newExitBB_pulse ? "BB" : newExitWvf_pulse ? "WVF" : "CVI"
    label.new(bar_index, high, "▼ EXIT HALF (" + _sig + ")", style=label.style_label_down, color=color.new(color.orange, 0), textcolor=color.white, size=size.small, yloc=yloc.abovebar)

if showExitLbl and newExitFull
    string _sig2 = charFlipFired ? "CHAR" : newExitBB_pulse ? "BB" : newExitWvf_pulse ? "WVF" : "CVI"
    string _lbl3 = charFlipFired ? "▼▼ EXIT FULL (⚡ CHAR-FLIP)" : "▼▼ EXIT FULL (" + _sig2 + " · " + str.tostring(exitWatchCount) + "/2)"
    label.new(bar_index, high, _lbl3, style=label.style_label_down, color=color.new(color.red, 0), textcolor=color.white, size=size.small, yloc=yloc.abovebar)

if showExitLbl and reEntrySignal
    int _ret = math.max(math.max(entryTier_30m, entryTier_60m), entryTier_15m)
    label.new(bar_index, low, "↺ RE-ENTRY · " + f_tierName(_ret), style=label.style_label_up, color=color.new(#ff9d00, 0), textcolor=color.black, size=size.small, yloc=yloc.belowbar)

// ═══════════════════════════════════════════════════════════
// DASHBOARD HELPERS
// ═══════════════════════════════════════════════════════════
f_loc(_s) =>
    switch _s
        "Top Right" => position.top_right
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        "Middle Right" => position.middle_right
        => position.bottom_right

f_sizeBody(_s) =>
    switch _s
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        "Huge" => size.huge
        => size.large

f_sizeHead(_s) =>
    switch _s
        "Tiny" => size.small
        "Small" => size.normal
        "Normal" => size.large
        "Large" => size.large
        "Huge" => size.huge
        => size.large

f_sizeHero(_s) =>
    switch _s
        "Tiny" => size.normal
        "Small" => size.large
        "Normal" => size.huge
        "Large" => size.huge
        "Huge" => size.huge
        => size.huge

f_barLit(_sc) => math.min(8, math.ceil(math.max(0.0, _sc)))
f_barTxt(_sc) =>
    _lit = f_barLit(_sc)
    _s = ""
    for _i = 1 to 8
        _s := _s + (_i <= _lit ? "█" : "░")
    _s

f_barCol(_sc) =>
    _sc >= scoreScaleMin ? color.new(#2FD082, 0) : _sc >= scoreBaseMin ? color.new(#FFB454, 0) : color.new(#FF5C6C, 0)

f_ageTxt(_tfOn, _age) =>
    not _tfOn ? "·" : (_age == 0 ? "FIRE" : (_age > 0 ? "B-" + str.tostring(_age) : "—"))

f_tierCellTxt(_t) =>
    _t == 3 ? "FULL" : _t == 2 ? "SCALE" : _t == 1 ? "BASE" : "—"

f_tierCellCol(_tfOn, _t) => not _tfOn ? color.new(color.gray, 70) : _t == 3 ? color.new(#4FD8E8, 0) : _t == 2 ? color.new(#2FD082, 0) : _t == 1 ? color.new(#FFB454, 0) : color.new(color.gray, 30)

f_tqiCol(_tfOn, _v) => not _tfOn ? color.new(color.gray, 70) : (_v >= tqiCharHigh ? color.new(color.lime, 0) : (_v >= tqiScoreThreshold ? color.new(color.yellow, 0) : color.new(color.red, 20)))

f_confTxt(_use, _ema, _vid, _obv, _del, _fvg, _tqi) =>
    not _use ? "·" : str.tostring((_ema?1:0) + (_vid?1:0) + (_obv?1:0) + (_del?1:0) + (_fvg?1:0) + (_tqi?1:0)) + "/6"

f_confCol(_use, _ema, _vid, _obv, _del, _fvg, _tqi) =>
    not _use ? color.new(#46506A, 0) : ((_ema or _vid or _obv or _del or _fvg or _tqi) ? color.new(#E8EDF4, 0) : color.new(#5a6580, 0))

f_wrTxt(_wins, _n) => _n > 0 ? str.tostring(math.round(_wins / _n * 100)) + "%" : "—"
f_wrCol(_wins, _n) => _n < 5 ? color.new(color.gray, 30) : (_wins / _n >= 0.55 ? color.lime : (_wins / _n >= 0.45 ? color.yellow : color.new(color.red, 20)))
f_retTxt(_sum, _n) => _n > 0 ? (_sum / _n >= 0 ? "+" : "") + str.tostring(_sum / _n, "#.00") + "%" : "—"
f_stopCol(_stops, _n) => _n < 5 ? color.new(color.gray, 30) : (_stops / _n < 0.35 ? color.lime : color.new(color.red, 20))

atf_direction_lbl = (not use_atf or atf_pearson < atf_strength_min) ? "FLAT" : (atf_slope < 0 ? "UP" : "DOWN")
atf_strength_lbl = atf_pearson < 0.5 ? "WEAK" : atf_pearson < 0.7 ? "MOD" : atf_pearson < 0.85 ? "STRONG" : "VSTNG"

// ═══════════════════════════════════════════════════════════
// DASHBOARD — 15m-emphasized · 3-column TF · v1.08.1
// ═══════════════════════════════════════════════════════════
if barstate.islast and showDashboard
    if not na(dash)
        table.delete(dash)
    dash := table.new(f_loc(dashLoc), 4, 25, bgcolor=color.new(#0B0E16, 0), frame_color=color.new(#4FD8E8, 55), frame_width=1, border_color=color.new(#1B2333, 55), border_width=1)
    
    // ── modern palette ──
    color _cBrand = color.new(#161D2C, 0)
    color _cBand = color.new(#10151F, 0)
    color _cHL = color.new(#0E1A26, 0)
    color _cLbl = color.new(#7E8AA0, 0)
    color _cHead = color.new(#A9B6CC, 0)
    color _c15Hd = color.new(#5FD3E6, 0)
    color _cDim = color.new(#46506A, 0)
    color _cTxt = color.new(#E8EDF4, 0)
    color _cNoFill = color.new(#0E121B, 0)
    
    // ── data prep ──
    bool _labMode = not useEMACore or not useVidyaCore or useTqiDeadZone or not useBBAnti or not useBBStop or not useWVFGate or useFVGScore != true or useTqiScore != true or wEMA != 1.0 or wVIDYA != 1.0 or wOBV != 1.0 or wDELTA != 1.0 or wFVG != 0.0 or wTQI != 1.0 or wVOL_HI != 1.0 or wVOL_LO != 0.0 or scoreScaleMin != 2.0 or scoreBaseMin != 1.0 or useBtcFullGate or tqiScoreThreshold != 0.35
    int _activeTFcol = trk_tf_min <= 15.5 ? 1 : trk_tf_min <= 35.0 ? 2 : 3
    
    // ── ADX bonus flags (stable: closed-bar copy) ──
    bool _adxBonus15 = useTF3 and adx_15m_d < fullAdxMax
    bool _adxBonus30 = useTF1 and adx_30m_d < fullAdxMax
    bool _adxBonus60 = useTF2 and adx_60m_d < fullAdxMax
    
    // ── Regime bonus flag ──
    bool _regimeBonus = regime_mode == "GREEN"
    
    // ── Effective scores with bonuses (stable: closed-bar copy) ──
    float _effScore15 = useTF3 ? score_15m_d + (_adxBonus15 ? 1.0 : 0.0) + (_regimeBonus ? 1.0 : 0.0) : 0.0
    float _effScore30 = useTF1 ? score_30m_d + (_adxBonus30 ? 1.0 : 0.0) + (_regimeBonus ? 1.0 : 0.0) : 0.0
    float _effScore60 = useTF2 ? score_60m_d + (_adxBonus60 ? 1.0 : 0.0) + (_regimeBonus ? 1.0 : 0.0) : 0.0
    
    // ── System-wide hero score ──
    float _heroScore = math.max(_effScore15, _effScore30, _effScore60)
    
    // ── Best TF star ──
    float _bestScore = math.max(useTF3 ? _effScore15 : -1, useTF1 ? _effScore30 : -1, useTF2 ? _effScore60 : -1)
    string _best15 = useTF3 and _effScore15 == _bestScore and _effScore15 > 0 ? "15m ★" : "15m"
    string _best30 = useTF1 and _effScore30 == _bestScore and _effScore30 > 0 ? "30m ★" : "30m"
    string _best60 = useTF2 and _effScore60 == _bestScore and _effScore60 > 0 ? "1h ★" : "1h"
    
    string _f15 = not useTF3 ? "·" : fvgA_15m_d ? "ARMED" : "—"
    string _f30 = not useTF1 ? "·" : fvgA_30m_d ? "ARMED" : "—"
    string _f60 = not useTF2 ? "·" : fvgA_60m_d ? "ARMED" : "—"
    color _f15c = not useTF3 ? _cDim : fvgA_15m_d ? color.new(#2FD082, 0) : color.new(#FF5C6C, 45)
    color _f30c = not useTF1 ? _cDim : fvgA_30m_d ? color.new(#2FD082, 0) : color.new(#FF5C6C, 45)
    color _f60c = not useTF2 ? _cDim : fvgA_60m_d ? color.new(#2FD082, 0) : color.new(#FF5C6C, 45)
    
    string _tqi15 = not useTF3 ? "·" : str.tostring(tqi_15m_d, "#.00")
    string _tqi30 = not useTF1 ? "·" : str.tostring(tqi_30m_d, "#.00")
    string _tqi60 = not useTF2 ? "·" : str.tostring(tqi_60m_d, "#.00")
    
    // ── ADX with FULL/SCALE label ──
    string _adx15 = not useTF3 ? "·" : str.tostring(math.round(adx_15m_d, 0)) + (adx_15m_d < fullAdxMax ? " ✓ FULL" : " ✗ SCALE")
    string _adx30 = not useTF1 ? "·" : str.tostring(math.round(adx_30m_d, 0)) + (adx_30m_d < fullAdxMax ? " ✓ FULL" : " ✗ SCALE")
    string _adx60 = not useTF2 ? "·" : str.tostring(math.round(adx_60m_d, 0)) + (adx_60m_d < fullAdxMax ? " ✓ FULL" : " ✗ SCALE")
    color _adx15col = not useTF3 ? _cDim : (adx_15m_d < fullAdxMax ? color.new(#2FD082, 0) : color.new(#FFB454, 0))
    color _adx30col = not useTF1 ? _cDim : (adx_30m_d < fullAdxMax ? color.new(#2FD082, 0) : color.new(#FFB454, 0))
    color _adx60col = not useTF2 ? _cDim : (adx_60m_d < fullAdxMax ? color.new(#2FD082, 0) : color.new(#FFB454, 0))
    
    // ── action row prep (1.08.09 — auto entry price; all exit/management banner text removed) ──
    float _sl1_pct = not na(sl1_price) and sl1_price > 0 ? (close - sl1_price) / close * 100 : na
    float _sl2_pct = not na(sl2_price) and sl2_price > 0 ? (close - sl2_price) / close * 100 : na
    bool   _ar_active = autoInTrade
    bool   _haveEntry = not na(entryFlashPx)
    float  _ar_pnlPct = _haveEntry ? (close - entryFlashPx) / entryFlashPx * 100 : na
    color _AC_GREEN = color.new(#2FD082, 0)
    color _AC_AMBER = color.new(#FFB454, 0)
    color _AC_RED   = color.new(#FF5C6C, 0)
    color _actionColor = _AC_AMBER
    string _ar_left  = ""
    string _ar_right = ""
    string _pxStr = _haveEntry ? "@ " + str.tostring(entryFlashPx, format.mintick) + " (" + entryFlashTF + ")" + (na(_ar_pnlPct) ? "" : " · " + (_ar_pnlPct >= 0 ? "+" : "") + str.tostring(_ar_pnlPct, "#.1") + "%") : "@ " + str.tostring(close, format.mintick) + " live"
    if _ar_active
        _ar_left  := "◉ IN TRADE"
        _ar_right := _pxStr
        _actionColor := _AC_GREEN
    else
        _ar_left  := "NO TRADE"
        // 1.10.0: a quiet chart is explainable — flag active SCALE suppression
        bool _anyScVeto = scVeto_15m or scVeto_30m or scVeto_60m
        _ar_right := _anyScVeto ? "idle · ⛔ SCALE vetoed" : "system idle · awaiting signal"
        _actionColor := _AC_AMBER
    color _arRightCol = (_ar_active and _haveEntry) ? (_ar_pnlPct >= 0 ? _AC_GREEN : _AC_RED) : color.new(#E8EDF4, 0)

    string _rModeStr = regime_mode
    // ── icon + word, replacing "R=.94 ADX=37 → 1.5× SCALE / 1× BASE" ──
    // Physical-state ladder (solid -> liquid -> fire), readable from the
    // glyph alone. NO permission verb: unlike the Swing Cockpit, regime
    // gates NOTHING in this file — the RED gate was tested against two
    // auto-halves at SOLdt 1.11.0 and closed ("RED @entry is FLAT both
    // halves ... Confirmed on halves, closed"). Printing OPEN/SHUT here
    // would misdescribe the engine to its own operator. The sizing note is
    // guidance and is kept; the raw ADX and Pearson numbers are dropped
    // because the ATF/BTC row already carries Pearson and the chip now
    // carries the ADX+ER verdict.
    string _regIcon = regime_mode == "GREEN" ? "❄️" : regime_mode == "YELLOW" ? "🌊" : "🔥"
    string _regWord = regime_mode == "GREEN" ? "RANGING" : regime_mode == "YELLOW" ? "LOOSE" : "TRENDING"
    string _rDetailStr = _regIcon + "  " + _regWord + " · " + regime_size_note
    string _htfTxt = htf_bull ? "BULL" : htf_bear ? "BEAR" : "FLAT"
    color _htfCol = htf_bull ? color.new(#2FD082, 0) : htf_bear ? color.new(#FF5C6C, 0) : color.new(#7d8aa8, 0)
    string _emaTxt = v22_ema_long_cond ? "BULL+" : v22_ema_short_cond ? "BEAR" : "FLAT"
    color _emaCol = v22_ema_long_cond ? color.new(#2FD082, 0) : v22_ema_short_cond ? color.new(#FF5C6C, 0) : color.new(#7d8aa8, 0)
    string _atfFullTxt = use_atf ? (atf_direction_lbl + " · " + atf_strength_lbl) : "OFF"
    color _atfCol = not use_atf ? color.new(#7d8aa8, 0) : atf_direction_lbl == "UP" ? color.new(#2FD082, 0) : atf_direction_lbl == "DOWN" ? color.new(#FF5C6C, 0) : color.new(#FFB454, 0)
    string _btcTxt = btc_bull ? "BULL" : "BEAR"
    color _btcCol = btc_bull ? color.new(#2FD082, 0) : color.new(#FF5C6C, 0)
    string _vwapTxt = na(swingVwap) ? "—" : (vwap_above ? "ABOVE" : "BELOW")
    color _vwapCol = na(swingVwap) ? color.new(#7d8aa8, 0) : (vwap_above ? color.new(#2FD082, 0) : color.new(#FF5C6C, 0))
    int _obvNow = f_obvSlope()
    string _obvTxt = _obvNow > 0 ? "UP" : _obvNow < 0 ? "DOWN" : "FLAT"
    color _obvCol = _obvNow > 0 ? color.new(#2FD082, 0) : _obvNow < 0 ? color.new(#FF5C6C, 0) : color.new(#7d8aa8, 0)
    string _sl1DashTxt = not na(sl1_price) ? str.tostring(sl1_price, format.mintick) + (not na(_sl1_pct) ? " (" + str.tostring(_sl1_pct, "#.1") + "%)" : "") : "no pivot"
    string _sl2DashTxt = not na(sl2_price) ? str.tostring(sl2_price, format.mintick) + (not na(_sl2_pct) ? " (" + str.tostring(_sl2_pct, "#.1") + "%)" : "") : "—"
    string _mbiTxt = mbi_bull_sig ? "BULL FIRE" : mbi_bear_sig ? "BEAR FIRE" : mbi_bias_bull_state ? "bull" : "bear"
    string _cviTxt = cvi_top_signal ? "TOP" : cvi_bot_signal ? "BOT" : cvi_val > 0.5 ? "bull" : "bear"
    string _bbaweTxt = bbawe_long_sig ? "LONG X" : bbawe_short_sig ? "SHORT X" : "—"
    string _bpTxt = str.tostring(math.round(bp_obs_pct, 0)) + "% " + (bp_obs_bull ? "bull" : bp_obs_bear ? "bear" : "flat")
    string _obsCombined = "MBI " + _mbiTxt + " · CVI " + _cviTxt + " · BBAWE " + _bbaweTxt + " · BP " + _bpTxt
    color _obsCombinedCol = (mbi_bull_sig or cvi_bot_signal or bbawe_long_sig) ? color.new(#2FD082, 0) : (mbi_bear_sig or cvi_top_signal or bbawe_short_sig) ? color.new(#FF5C6C, 0) : color.new(color.white, 20)
    [_sw15txt, _sw15col, _sw15hot] = f_swpCell(useTF3, k15swPend, k15swLvl, k15swQ, k15swAge)
    [_sw30txt, _sw30col, _sw30hot] = f_swpCell(useTF1, k30swPend, k30swLvl, k30swQ, k30swAge)
    [_sw60txt, _sw60col, _sw60hot] = f_swpCell(useTF2, k60swPend, k60swLvl, k60swQ, k60swAge)
    string _gateStr = (useWVFGate ? "WVF " : "") + (useTqiDeadZone ? "+ DZ " : "") + "| FVG" + (useFVGScore ? "→Score " : "· ") + "TQI" + (useTqiScore ? "→Score" : "·")
    
    // ── Action-tinted banner band (single source: _actionColor) ──
    color _heroBg = color.new(_actionColor, 80)
    
    // ═══════════ ROW 0 — ACTION BANNER (hero) ═══════════
    table.cell(dash, 0, 0, _ar_left, text_color=_actionColor, text_size=f_sizeHero(dashSize), text_halign=text.align_left, bgcolor=_heroBg)
    table.cell(dash, 1, 0, _ar_right, text_color=_arRightCol, text_size=f_sizeHero(dashSize), text_halign=text.align_right, bgcolor=_heroBg)  // 1.08.11: body -> hero
    table.merge_cells(dash, 1, 0, 3, 0)
    
    // ═══════════ ROW 1 — TF HEADERS ═══════════
    table.cell(dash, 0, 1, "", text_color=_cLbl, text_size=f_sizeBody(dashSize), bgcolor=_cBand)
    table.cell(dash, 1, 1, useTF3 ? (_activeTFcol == 1 ? _best15 + " ◀" : _best15) : "15m off", text_color=useTF3 ? (_activeTFcol == 1 ? _c15Hd : _cHead) : _cDim, text_size=_activeTFcol == 1 ? f_sizeHead(dashSize) : f_sizeBody(dashSize), text_halign=text.align_center, bgcolor=_activeTFcol == 1 ? _cHL : _cBand)
    table.cell(dash, 2, 1, useTF1 ? (_activeTFcol == 2 ? _best30 + " ◀" : _best30) : "30m off", text_color=useTF1 ? (_activeTFcol == 2 ? _c15Hd : _cHead) : _cDim, text_size=_activeTFcol == 2 ? f_sizeHead(dashSize) : f_sizeBody(dashSize), text_halign=text.align_center, bgcolor=_activeTFcol == 2 ? _cHL : _cBand)
    table.cell(dash, 3, 1, useTF2 ? (_activeTFcol == 3 ? _best60 + " ◀" : _best60) : "1h off", text_color=useTF2 ? (_activeTFcol == 3 ? _c15Hd : _cHead) : _cDim, text_size=_activeTFcol == 3 ? f_sizeHead(dashSize) : f_sizeBody(dashSize), text_halign=text.align_center, bgcolor=_activeTFcol == 3 ? _cHL : _cBand)
    
    // ═══════════ ROW 2 — TIER pills ═══════════
    color _t15c = not useTF3 ? _cDim : f_tierCellCol(true, tier_15m_e_d)
    color _t30c = not useTF1 ? _cDim : f_tierCellCol(true, tier_30m_e_d)
    color _t60c = not useTF2 ? _cDim : f_tierCellCol(true, tier_60m_e_d)
    table.cell(dash, 0, 2, "TIER", text_color=_cLbl, text_size=f_sizeBody(dashSize), text_halign=text.align_left)
    table.cell(dash, 1, 2, f_tierCellTxt(tier_15m_e_d), text_color=(useTF3 and tier_15m_e_d > 0) ? _t15c : _cDim, text_size=f_sizeHead(dashSize), text_halign=text.align_center, bgcolor=(useTF3 and tier_15m_e_d > 0) ? color.new(_t15c, 62) : (_activeTFcol == 1 ? _cHL : _cNoFill))
    table.cell(dash, 2, 2, f_tierCellTxt(tier_30m_e_d), text_color=(useTF1 and tier_30m_e_d > 0) ? _t30c : _cDim, text_size=f_sizeBody(dashSize), text_halign=text.align_center, bgcolor=(useTF1 and tier_30m_e_d > 0) ? color.new(_t30c, 80) : (_activeTFcol == 2 ? _cHL : _cNoFill))
    table.cell(dash, 3, 2, f_tierCellTxt(tier_60m_e_d), text_color=(useTF2 and tier_60m_e_d > 0) ? _t60c : _cDim, text_size=f_sizeBody(dashSize), text_halign=text.align_center, bgcolor=(useTF2 and tier_60m_e_d > 0) ? color.new(_t60c, 80) : (_activeTFcol == 3 ? _cHL : _cNoFill))
    
    // ═══════════ ROW 3 — BRAND + SCORE (demoted) ═══════════
    table.cell(dash, 0, 3, _labMode ? "◆ Solana Day Trader " + VER + " ⚗LAB" : "◆ Solana Day Trader " + VER, text_color=_cHead, text_size=f_sizeBody(dashSize), text_halign=text.align_left, bgcolor=_cBrand)
    table.cell(dash, 1, 3, f_barTxt(_heroScore) + "  " + str.tostring(_heroScore, "#.#"), text_color=_actionColor, text_size=f_sizeBody(dashSize), text_halign=text.align_right, bgcolor=color.new(_actionColor, 88))
    table.merge_cells(dash, 1, 3, 3, 3)
    
    // ═══════════ ROW 4 — SIGNAL band ═══════════
    table.cell(dash, 0, 4, "SIGNAL", text_color=_cLbl, text_size=f_sizeBody(dashSize), text_halign=text.align_left, bgcolor=_cBand)
    table.merge_cells(dash, 0, 4, 3, 4)
    
    // ROW 5 — WVF
    table.cell(dash, 0, 5, "WVF", text_color=_cLbl, text_size=f_sizeBody(dashSize), text_halign=text.align_left)
    table.cell(dash, 1, 5, f_ageTxt(useTF3, wvfAge_15m_d), text_color=not useTF3 ? _cDim : (wvfA_15m_d ? color.new(#DA70D6, 0) : color.new(color.gray, 40)), text_size=f_sizeBody(dashSize), text_halign=text.align_center, bgcolor=_activeTFcol == 1 ? _cHL : _cNoFill)
    table.cell(dash, 2, 5, f_ageTxt(useTF1, wvfAge_30m_d), text_color=not useTF1 ? _cDim : (wvfA_30m_d ? color.new(#DA70D6, 0) : color.new(color.gray, 40)), text_size=f_sizeBody(dashSize), text_halign=text.align_center, bgcolor=_activeTFcol == 2 ? _cHL : _cNoFill)
    table.cell(dash, 3, 5, f_ageTxt(useTF2, wvfAge_60m_d), text_color=not useTF2 ? _cDim : (wvfA_60m_d ? color.new(#DA70D6, 0) : color.new(color.gray, 40)), text_size=f_sizeBody(dashSize), text_halign=text.align_center, bgcolor=_activeTFcol == 3 ? _cHL : _cNoFill)
    
    // ROW 6 — FVG
    table.cell(dash, 0, 6, "FVG", text_color=_cLbl, text_size=f_sizeBody(dashSize), text_halign=text.align_left)
    table.cell(dash, 1, 6, _f15, text_color=_f15c, text_size=f_sizeBody(dashSize), text_halign=text.align_center, bgcolor=_activeTFcol == 1 ? _cHL : _cNoFill)
    table.cell(dash, 2, 6, _f30, text_color=_f30c, text_size=f_sizeBody(dashSize), text_halign=text.align_center, bgcolor=_activeTFcol == 2 ? _cHL : _cNoFill)
    table.cell(dash, 3, 6, _f60, text_color=_f60c, text_size=f_sizeBody(dashSize), text_halign=text.align_center, bgcolor=_activeTFcol == 3 ? _cHL : _cNoFill)
    
    // ROW 7 — TQI → Score
    table.cell(dash, 0, 7, "TQI", text_color=_cLbl, text_size=f_sizeBody(dashSize), text_halign=text.align_left)
    table.cell(dash, 1, 7, _tqi15, text_color=f_tqiCol(useTF3, tqi_15m_d), text_size=f_sizeBody(dashSize), text_halign=text.align_center, bgcolor=_activeTFcol == 1 ? _cHL : _cNoFill)
    table.cell(dash, 2, 7, _tqi30, text_color=f_tqiCol(useTF1, tqi_30m_d), text_size=f_sizeBody(dashSize), text_halign=text.align_center, bgcolor=_activeTFcol == 2 ? _cHL : _cNoFill)
    table.cell(dash, 3, 7, _tqi60, text_color=f_tqiCol(useTF2, tqi_60m_d), text_size=f_sizeBody(dashSize), text_halign=text.align_center, bgcolor=_activeTFcol == 3 ? _cHL : _cNoFill)
    
    // ROW 8 — Confluence (replaces Score)
    string _c15 = f_confTxt(useTF3, emaA_15m_d, vidyaA_15m_d, obvBull_15m_d, deltaArmed_15m_d, fvgA_15m_d, tqiContrib_15m_d)
    string _c30 = f_confTxt(useTF1, emaA_30m_d, vidyaA_30m_d, obvBull_30m_d, deltaArmed_30m_d, fvgA_30m_d, tqiContrib_30m_d)
    string _c60 = f_confTxt(useTF2, emaA_60m_d, vidyaA_60m_d, obvBull_60m_d, deltaArmed_60m_d, fvgA_60m_d, tqiContrib_60m_d)
    table.cell(dash, 0, 8, "Confluence", text_color=_cLbl, text_size=f_sizeBody(dashSize), text_halign=text.align_left)
    table.cell(dash, 1, 8, _c15, text_color=f_confCol(useTF3, emaA_15m_d, vidyaA_15m_d, obvBull_15m_d, deltaArmed_15m_d, fvgA_15m_d, tqiContrib_15m_d), text_size=f_sizeBody(dashSize), text_halign=text.align_center, bgcolor=_activeTFcol == 1 ? _cHL : _cNoFill)
    table.cell(dash, 2, 8, _c30, text_color=f_confCol(useTF1, emaA_30m_d, vidyaA_30m_d, obvBull_30m_d, deltaArmed_30m_d, fvgA_30m_d, tqiContrib_30m_d), text_size=f_sizeBody(dashSize), text_halign=text.align_center, bgcolor=_activeTFcol == 2 ? _cHL : _cNoFill)
    table.cell(dash, 3, 8, _c60, text_color=f_confCol(useTF2, emaA_60m_d, vidyaA_60m_d, obvBull_60m_d, deltaArmed_60m_d, fvgA_60m_d, tqiContrib_60m_d), text_size=f_sizeBody(dashSize), text_halign=text.align_center, bgcolor=_activeTFcol == 3 ? _cHL : _cNoFill)
    
    // ROW 9 — ADX
    table.cell(dash, 0, 9, "ADX <" + str.tostring(fullAdxMax, "#"), text_color=_cLbl, text_size=f_sizeBody(dashSize), text_halign=text.align_left)
    table.cell(dash, 1, 9, _adx15, text_color=_adx15col, text_size=f_sizeBody(dashSize), text_halign=text.align_center, bgcolor=_activeTFcol == 1 ? _cHL : _cNoFill)
    table.cell(dash, 2, 9, _adx30, text_color=_adx30col, text_size=f_sizeBody(dashSize), text_halign=text.align_center, bgcolor=_activeTFcol == 2 ? _cHL : _cNoFill)
    table.cell(dash, 3, 9, _adx60, text_color=_adx60col, text_size=f_sizeBody(dashSize), text_halign=text.align_center, bgcolor=_activeTFcol == 3 ? _cHL : _cNoFill)
    
    // ── 1.12.4: TREND moved again, now directly under ADX<25 (row 9) —
    //    reads as the last SIGNAL-adjacent line before the REGIME band, on
    //    the logic that trend direction belongs with the ADX/regime-strength
    //    read rather than buried inside the REGIME band's own sub-rows.
    //    REGIME band and its mode-pill both shift down one slot (10->11,
    //    11->12) to make room. HTF is UNCHANGED at row 13 — the three-row
    //    block (REGIME band / mode-pill / TREND) is a closed rotation, so
    //    nothing below row 13 moves.
    table.cell(dash, 0, 10, "TREND " + str.tostring(dirFastLen) + "/" + str.tostring(dirSlowLen), text_color=_cLbl, text_size=f_sizeBody(dashSize), text_halign=text.align_left)
    table.cell(dash, 1, 10, k15dirUp ? "▲ UP" : "▼ DN", text_color=k15dirUp ? color.new(#2FD082, 0) : color.new(#FF5C6C, 0), text_size=f_sizeBody(dashSize), text_halign=text.align_center)
    table.cell(dash, 2, 10, k30dirUp ? "▲ UP" : "▼ DN", text_color=k30dirUp ? color.new(#2FD082, 0) : color.new(#FF5C6C, 0), text_size=f_sizeBody(dashSize), text_halign=text.align_center)
    table.cell(dash, 3, 10, k60dirUp ? "▲ UP" : "▼ DN", text_color=k60dirUp ? color.new(#2FD082, 0) : color.new(#FF5C6C, 0), text_size=f_sizeBody(dashSize), text_halign=text.align_center)
    // ═══════════ ROW 11 — REGIME band ═══════════
    table.cell(dash, 0, 12, "REGIME", text_color=_cLbl, text_size=f_sizeBody(dashSize), text_halign=text.align_left, bgcolor=_cBand)
    table.merge_cells(dash, 0, 12, 3, 12)
    
    // ROW 12 — regime pill + detail
    table.cell(dash, 0, 13, _rModeStr, text_color=color.new(#0B0E16, 0), text_size=f_sizeBody(dashSize), text_halign=text.align_center, bgcolor=color.new(regime_color, 20))
    table.cell(dash, 1, 13, _rDetailStr, text_color=_cTxt, text_size=f_sizeBody(dashSize), text_halign=text.align_right, bgcolor=color.new(#0a1428, 30))
    table.merge_cells(dash, 1, 13, 3, 13)
    // ROW 13 — HTF / EMA
    table.cell(dash, 0, 14, "HTF " + htfBiasTF + " / EMA", text_color=_cLbl, text_size=f_sizeBody(dashSize), text_halign=text.align_left)
    table.cell(dash, 1, 14, showRegimePanel ? _htfTxt : "·", text_color=showRegimePanel ? _htfCol : _cDim, text_size=f_sizeBody(dashSize), text_halign=text.align_center)
    table.cell(dash, 2, 14, _emaTxt, text_color=_emaCol, text_size=f_sizeBody(dashSize), text_halign=text.align_center)
    table.merge_cells(dash, 2, 14, 3, 14)
    
    // ROW 13 — ATF / BTC
    table.cell(dash, 0, 15, "ATF / BTC", text_color=_cLbl, text_size=f_sizeBody(dashSize), text_halign=text.align_left)
    table.cell(dash, 1, 15, _atfFullTxt, text_color=_atfCol, text_size=f_sizeBody(dashSize), text_halign=text.align_center)
    table.cell(dash, 2, 15, showRegimePanel ? _btcTxt : "·", text_color=showRegimePanel ? _btcCol : _cDim, text_size=f_sizeBody(dashSize), text_halign=text.align_center)
    table.merge_cells(dash, 2, 15, 3, 15)
    
    // ROW 14 — VWAP / OBV
    table.cell(dash, 0, 16, "VWAP / OBV", text_color=_cLbl, text_size=f_sizeBody(dashSize), text_halign=text.align_left)
    table.cell(dash, 1, 16, _vwapTxt, text_color=_vwapCol, text_size=f_sizeBody(dashSize), text_halign=text.align_center)
    table.cell(dash, 2, 16, _obvTxt, text_color=_obvCol, text_size=f_sizeBody(dashSize), text_halign=text.align_center)
    table.merge_cells(dash, 2, 16, 3, 16)
    
    // ═══════════ ROW 15 — LEVELS band ═══════════
    table.cell(dash, 0, 17, "LEVELS", text_color=_cLbl, text_size=f_sizeBody(dashSize), text_halign=text.align_left, bgcolor=_cBand)
    table.merge_cells(dash, 0, 17, 3, 17)
    
    // ROW 16 — Structure SL
    table.cell(dash, 0, 18, "SL struct/ATR", text_color=_cLbl, text_size=f_sizeBody(dashSize), text_halign=text.align_left)
    table.cell(dash, 1, 18, _sl1DashTxt, text_color=color.new(#ff8c42, 0), text_size=f_sizeBody(dashSize), text_halign=text.align_center)
    table.cell(dash, 2, 18, _sl2DashTxt, text_color=color.new(#ffcc00, 0), text_size=f_sizeBody(dashSize), text_halign=text.align_center)
    table.merge_cells(dash, 2, 18, 3, 18)
    
    // ROW 17 — nearest sell-side liquidity (above)
    string _liqUp = na(liqNearSSL) ? "—" : str.tostring(liqNearSSL, format.mintick) + (liqNearSSLt > 1 ? " ×" + str.tostring(liqNearSSLt) : "")
    table.cell(dash, 0, 19, "Liq ↑", text_color=color.new(#ff6f43, 0), text_size=f_sizeBody(dashSize), text_halign=text.align_left)
    table.cell(dash, 1, 19, _liqUp, text_color=anySslNear ? color.new(#ff6f43, 0) : _cTxt, text_size=f_sizeBody(dashSize), text_halign=text.align_center)
    table.merge_cells(dash, 1, 19, 3, 19)
    
    // ROW 18 — nearest buy-side liquidity (below)
    string _liqDn = na(liqNearBSL) ? "—" : str.tostring(liqNearBSL, format.mintick) + (liqNearBSLt > 1 ? " ×" + str.tostring(liqNearBSLt) : "")
    table.cell(dash, 0, 20, "Liq ↓", text_color=color.new(#22bac5, 0), text_size=f_sizeBody(dashSize), text_halign=text.align_left)
    table.cell(dash, 1, 20, _liqDn, text_color=anyBslNear ? color.new(#22bac5, 0) : _cTxt, text_size=f_sizeBody(dashSize), text_halign=text.align_center)
    table.merge_cells(dash, 1, 20, 3, 20)
    
    // ═══════════ ROW 19 — OBSERVABLES band ═══════════
    table.cell(dash, 0, 21, "OBSERVABLES", text_color=_cLbl, text_size=f_sizeBody(dashSize), text_halign=text.align_left, bgcolor=_cBand)
    table.merge_cells(dash, 0, 21, 3, 21)
    
    // ROW 20 — chart-TF observables (MBI/CVI/BBAWE/BP)
    table.cell(dash, 0, 22, "Obs", text_color=_cLbl, text_size=f_sizeBody(dashSize), text_halign=text.align_left)
    table.cell(dash, 1, 22, _obsCombined, text_color=_obsCombinedCol, text_size=f_sizeBody(dashSize), text_halign=text.align_center)
    table.merge_cells(dash, 1, 22, 3, 22)
    
    // ROW 21 — Sweep-lite per TF
    table.cell(dash, 0, 11, "SWEEP lvl", text_color=color.new(#DA70D6, 0), text_size=f_sizeBody(dashSize), text_halign=text.align_left)
    table.cell(dash, 1, 11, _sw15txt, text_color=_sw15col, text_size=f_sizeHead(dashSize), text_halign=text.align_center, bgcolor=_sw15hot ? color.new(_sw15col, 62) : (_activeTFcol == 1 ? _cHL : _cNoFill))
    table.cell(dash, 2, 11, _sw30txt, text_color=_sw30col, text_size=f_sizeHead(dashSize), text_halign=text.align_center, bgcolor=_sw30hot ? color.new(_sw30col, 62) : (_activeTFcol == 2 ? _cHL : _cNoFill))
    table.cell(dash, 3, 11, _sw60txt, text_color=_sw60col, text_size=f_sizeHead(dashSize), text_halign=text.align_center, bgcolor=_sw60hot ? color.new(_sw60col, 62) : (_activeTFcol == 3 ? _cHL : _cNoFill))
    
    // ROW 22 — Gates footer
    table.cell(dash, 0, 23, "GATES", text_color=_cLbl, text_size=f_sizeBody(dashSize), text_halign=text.align_left, bgcolor=color.new(#0a2818, 25))
    table.cell(dash, 1, 23, _gateStr, text_color=color.new(#2FD082, 0), text_size=f_sizeBody(dashSize), text_halign=text.align_center, bgcolor=color.new(#0a2818, 25))
    table.merge_cells(dash, 1, 23, 3, 23)
    
    // ═══════════ ROW 23 — ADR (observe only; gate off) ═══════════
    string _adrTxt = (adr_exhausted ? "SPENT " : adr_caution ? "CAUTION " : "") + str.tostring(adr_pctUsed, "#") + "% used"
    string _adrPos = na(adr_posInRange) ? "" : "  @ " + str.tostring(adr_posInRange, "#") + "% rng"
    color  _adrCol = adr_exhausted ? color.new(#ff5252, 0) : adr_caution ? color.new(#ffcc00, 0) : color.new(#2FD082, 0)
    table.cell(dash, 0, 24, "ADR", text_color=_cLbl, text_size=f_sizeBody(dashSize), text_halign=text.align_left, bgcolor=color.new(#0a2818, 25))
    table.cell(dash, 1, 24, _adrTxt + _adrPos, text_color=_adrCol, text_size=f_sizeBody(dashSize), text_halign=text.align_center, bgcolor=color.new(#0a2818, 25))
    table.merge_cells(dash, 1, 24, 3, 24)

// ═══════════════════════════════════════════════════════════
// ALERTS — per-tier (15m / 30m / 1h)
// ═══════════════════════════════════════════════════════════
if (useBaseAlerts and ((newTier_30m and offTier_30m == 1) or (newTier_60m and offTier_60m == 1) or (newTier_15m and offTier_15m == 1)))
    alert("Solana Day Trader · BASE tier fired", freq=alert.freq_once_per_bar_close)
if (useScaleAlerts and ((newTier_30m and offTier_30m == 2) or (newTier_60m and offTier_60m == 2) or (newTier_15m and offTier_15m == 2)))
    alert("Solana Day Trader · SCALE tier fired", freq=alert.freq_once_per_bar_close)
if (useFullAlerts and ((newTier_30m and offTier_30m == 3) or (newTier_60m and offTier_60m == 3) or (newTier_15m and offTier_15m == 3)))
    alert("Solana Day Trader · FULL tier fired", freq=alert.freq_once_per_bar_close)


// ═══════════════════════════════════════════════════════════
// 1.09.0: DATA TABLE (observe-only render · pooled splits = 15m+30m)
// ═══════════════════════════════════════════════════════════
f_trkPos() =>
    trkPos == "Top Left" ? position.top_left : trkPos == "Top Right" ? position.top_right : trkPos == "Bottom Right" ? position.bottom_right : trkPos == "Middle Left" ? position.middle_left : position.bottom_left

f_rowDt(_t, _row, _name, _x, _g, _r, _hdr) =>
    float _avg = _r > 0 ? _x / _r : na
    float _wr = _r > 0 ? 100.0 * _g / _r : na
    color _rc = na(_avg) ? color.new(color.gray, 40) : _avg > 0.02 ? color.new(#00ff9d, 0) : _avg < -0.02 ? color.new(#ff4560, 0) : color.new(color.yellow, 0)
    color _nc = _hdr ? color.new(#00ddff, 0) : color.new(#c9d1d9, 0)
    table.cell(_t, 0, _row, _name, text_color=_nc, text_size=size.tiny, text_halign=text.align_left)
    table.cell(_t, 1, _row, na(_avg) ? "—" : (_avg >= 0 ? "." : "-.") + str.tostring(math.abs(_avg), "#.##"), text_color=_rc, text_size=size.tiny, text_halign=text.align_right)
    table.cell(_t, 2, _row, na(_wr) ? "—" : str.tostring(_wr, "#") + "%", text_color=color.new(#c9d1d9, 0), text_size=size.tiny, text_halign=text.align_right)
    table.cell(_t, 3, _row, _r > 0 ? str.tostring(_r) : "—", text_color=color.new(#8b949e, 0), text_size=size.tiny, text_halign=text.align_right)

// 1.16.0: EXIT MIX renderer. Same four columns as f_rowDt, different
// meaning: target% / stop% / timeout% instead of R / win% / n. Timeout is
// derived from the other two so the three always sum to 100.
f_mixDt(_t, _row, _name, _tgt, _stp, _tot) =>
    float _pt = _tot > 0 ? 100.0 * _tgt / _tot : na
    float _ps = _tot > 0 ? 100.0 * _stp / _tot : na
    float _pm = _tot > 0 ? 100.0 * (_tot - _tgt - _stp) / _tot : na
    table.cell(_t, 0, _row, _name, text_color=color.new(#c9d1d9, 0), text_size=size.tiny, text_halign=text.align_left)
    table.cell(_t, 1, _row, na(_pt) ? "—" : str.tostring(_pt, "#") + "%", text_color=color.new(#00ff9d, 0), text_size=size.tiny, text_halign=text.align_right)
    table.cell(_t, 2, _row, na(_ps) ? "—" : str.tostring(_ps, "#") + "%", text_color=color.new(#ff4560, 0), text_size=size.tiny, text_halign=text.align_right)
    table.cell(_t, 3, _row, na(_pm) ? "—" : str.tostring(_pm, "#") + "%", text_color=color.new(color.yellow, 0), text_size=size.tiny, text_halign=text.align_right)

// ════════════════════════════════════════════════════════════
// 1.18.0 · MTF TREND PANEL — DISPLAY ONLY, FEEDS NOTHING
// Faithful port of GainzAlgo Smart Money Structure v3.0's "Predict" row.
// See the header for the two source quirks preserved on purpose.
// ════════════════════════════════════════════════════════════
f_trendPos() =>
    trendPos == "Top Left" ? position.top_left : trendPos == "Top Center" ? position.top_center : trendPos == "Top Right" ? position.top_right : trendPos == "Middle Left" ? position.middle_left : trendPos == "Middle Center" ? position.middle_center : trendPos == "Middle Right" ? position.middle_right : trendPos == "Bottom Left" ? position.bottom_left : trendPos == "Bottom Right" ? position.bottom_right : position.bottom_center

// Chart close vs that TF's EMA and VWAP. Both must agree or the state is 0.
f_trendState(_ema, _vwap) =>
    close > _ema and close > _vwap ? 1 : close < _ema and close < _vwap ? -1 : 0

// trend + momentum + volatility. The volatility leg is one-directional by
// default (see header) — trendVolSym makes it symmetric.
f_predScore(_tr, _mom, _vol, _volAvg) =>
    float _m = _mom > 0 ? 0.5 : _mom < 0 ? -0.5 : 0.0
    float _v = _vol > _volAvg ? 0.5 : (trendVolSym ? -0.5 : 0.0)
    _tr + _m + _v

f_predArrow(_s) =>
    _s > 0.5 ? "▲" : _s < -0.5 ? "▼" : "━"

f_trendSizeLbl() =>
    trendSize == "Tiny" ? size.tiny : trendSize == "Normal" ? size.small : size.tiny

f_trendSizeHdr() =>
    trendSize == "Tiny" ? size.tiny : trendSize == "Normal" ? size.normal : size.small

f_trendSizeArw() =>
    trendSize == "Tiny" ? size.small : trendSize == "Normal" ? size.large : size.normal

f_predCol(_a) =>
    _a == "▲" ? color.new(#00E676, 0) : _a == "▼" ? color.new(#FF1744, 0) : color.new(#FFB627, 40)

// One tuple per timeframe: EMA, VWAP, 3-bar momentum, ATR, ATR average.
// Six calls total where the source uses 25.
[tpE5, tpV5, tpM5, tpA5, tpAA5]       = request.security(syminfo.tickerid, "5",   [ta.ema(close, trendEmaLen), ta.vwap(hlc3), close - close[3], ta.atr(14), ta.sma(ta.atr(14), 20)], lookahead=barmerge.lookahead_off)
[tpE15, tpV15, tpM15, tpA15, tpAA15]  = request.security(syminfo.tickerid, "15",  [ta.ema(close, trendEmaLen), ta.vwap(hlc3), close - close[3], ta.atr(14), ta.sma(ta.atr(14), 20)], lookahead=barmerge.lookahead_off)
[tpE30, tpV30, tpM30, tpA30, tpAA30]  = request.security(syminfo.tickerid, "30",  [ta.ema(close, trendEmaLen), ta.vwap(hlc3), close - close[3], ta.atr(14), ta.sma(ta.atr(14), 20)], lookahead=barmerge.lookahead_off)
[tpE60, tpV60, tpM60, tpA60, tpAA60]  = request.security(syminfo.tickerid, "60",  [ta.ema(close, trendEmaLen), ta.vwap(hlc3), close - close[3], ta.atr(14), ta.sma(ta.atr(14), 20)], lookahead=barmerge.lookahead_off)
[tpE240, tpV240, tpM240, tpA240, tpAA240] = request.security(syminfo.tickerid, "240", [ta.ema(close, trendEmaLen), ta.vwap(hlc3), close - close[3], ta.atr(14), ta.sma(ta.atr(14), 20)], lookahead=barmerge.lookahead_off)
[tpED, tpVD, tpMD, tpAD, tpAAD]       = request.security(syminfo.tickerid, "D",   [ta.ema(close, trendEmaLen), ta.vwap(hlc3), close - close[3], ta.atr(14), ta.sma(ta.atr(14), 20)], lookahead=barmerge.lookahead_off)

string _pr5   = f_predArrow(f_predScore(f_trendState(tpE5, tpV5),       tpM5,   tpA5,   tpAA5))
string _pr15  = f_predArrow(f_predScore(f_trendState(tpE15, tpV15),     tpM15,  tpA15,  tpAA15))
string _pr30  = f_predArrow(f_predScore(f_trendState(tpE30, tpV30),     tpM30,  tpA30,  tpAA30))
string _pr60  = f_predArrow(f_predScore(f_trendState(tpE60, tpV60),     tpM60,  tpA60,  tpAA60))
string _pr240 = f_predArrow(f_predScore(f_trendState(tpE240, tpV240),   tpM240, tpA240, tpAA240))
string _prD   = f_predArrow(f_predScore(f_trendState(tpED, tpVD),       tpMD,   tpAD,   tpAAD))

var table trendT = na
if showTrendPanel and barstate.islast
    if not na(trendT)
        table.delete(trendT)
    trendT := table.new(f_trendPos(), 7, 2, bgcolor=color.new(#0A0E27, 15), border_width=1, border_color=color.new(#E040FB, 50))
    table.cell(trendT, 0, 0, "🔮 TREND", text_color=color.new(#E040FB, 0), text_size=f_trendSizeHdr(), bgcolor=color.new(#1A1F3A, 30))
    table.cell(trendT, 0, 1, "Predict", text_color=color.new(#C77DFF, 20), text_size=f_trendSizeLbl(), bgcolor=color.new(#0F1629, 40))
    string[] _tfLbl = array.from("5M", "15M", "30M", "1H", "4H", "1D")
    string[] _tfArw = array.from(_pr5, _pr15, _pr30, _pr60, _pr240, _prD)
    for _i = 0 to 5
        string _a = array.get(_tfArw, _i)
        table.cell(trendT, _i + 1, 0, array.get(_tfLbl, _i), text_color=color.new(#FFFFFF, 30), text_size=f_trendSizeLbl(), bgcolor=color.new(#1A1F3A, 30))
        table.cell(trendT, _i + 1, 1, _a, text_color=f_predCol(_a), text_size=f_trendSizeArw(), bgcolor=color.new(#0F1629, 40))

var table trkT = na
if showTrk and barstate.islast
    if not na(trkT)
        table.delete(trkT)
    trkT := table.new(f_trkPos(), 4, 52, bgcolor=color.new(#0d1117, 8), border_color=color.new(#21262d, 0), border_width=1, frame_color=color.new(#21262d, 0), frame_width=1)
    int _q = 0
    table.cell(trkT, 0, _q, "DATA · " + VER + " · +" + str.tostring(trkTgtPct, "#.#") + "/-" + str.tostring(trkStopPct, "#.#") + "% · " + str.tostring(trkMaxHours, "#") + "h", text_color=color.new(#ffffff, 0), text_size=size.tiny, text_halign=text.align_left, bgcolor=color.new(#1f6feb, 0))
    table.merge_cells(trkT, 0, _q, 3, _q)
    _q += 1
    f_rowDt(trkT, _q, "15m", k15x0, k15g0, k15r0, false)
    _q += 1
    f_rowDt(trkT, _q, "30m", k30x0, k30g0, k30r0, false)
    _q += 1
    f_rowDt(trkT, _q, "1h", k60x0, k60g0, k60r0, false)
    _q += 1
    // pooled base (15m+30m) — all splits below read this pool
    int _pr = k15r0 + k30r0
    int _pg = k15g0 + k30g0
    float _px = k15x0 + k30x0
    f_rowDt(trkT, _q, "pool 15m+30m", _px, _pg, _pr, true)
    _q += 1
    int _prTq = k15rTq + k30rTq
    int _pgTq = k15gTq + k30gTq
    float _pxTq = k15xTq + k30xTq
    f_rowDt(trkT, _q, "TQI ≥ thr", _pxTq, _pgTq, _prTq, false)
    _q += 1
    f_rowDt(trkT, _q, "TQI < thr", _px - _pxTq, _pg - _pgTq, _pr - _prTq, false)
    _q += 1
    int _prDz = k15rDz + k30rDz
    int _pgDz = k15gDz + k30gDz
    float _pxDz = k15xDz + k30xDz
    f_rowDt(trkT, _q, "TQI dead-zone", _pxDz, _pgDz, _prDz, false)
    _q += 1
    f_rowDt(trkT, _q, "DZ outside", _px - _pxDz, _pg - _pgDz, _pr - _prDz, false)
    _q += 1
    int _prFv = k15rFv + k30rFv
    int _pgFv = k15gFv + k30gFv
    float _pxFv = k15xFv + k30xFv
    f_rowDt(trkT, _q, "FVG armed", _pxFv, _pgFv, _prFv, false)
    _q += 1
    f_rowDt(trkT, _q, "FVG absent", _px - _pxFv, _pg - _pgFv, _pr - _prFv, false)
    _q += 1
    int _prDl = k15rDl + k30rDl
    int _pgDl = k15gDl + k30gDl
    float _pxDl = k15xDl + k30xDl
    f_rowDt(trkT, _q, "DELTA armed", _pxDl, _pgDl, _prDl, false)
    _q += 1
    f_rowDt(trkT, _q, "DELTA absent", _px - _pxDl, _pg - _pgDl, _pr - _prDl, false)
    _q += 1
    int _prG = k15rG + k30rG
    int _pgG = k15gG + k30gG
    float _pxG = k15xG + k30xG
    int _prY = k15rY + k30rY
    int _pgY = k15gY + k30gY
    float _pxY = k15xY + k30xY
    f_rowDt(trkT, _q, "GREEN @entry", _pxG, _pgG, _prG, false)
    _q += 1
    f_rowDt(trkT, _q, "YELLOW @entry", _pxY, _pgY, _prY, false)
    _q += 1
    f_rowDt(trkT, _q, "RED @entry", _px - _pxG - _pxY, _pg - _pgG - _pgY, _pr - _prG - _prY, false)
    _q += 1
    int _prT1 = k15rT1 + k30rT1
    int _pgT1 = k15gT1 + k30gT1
    float _pxT1 = k15xT1 + k30xT1
    int _prT2 = k15rT2 + k30rT2
    int _pgT2 = k15gT2 + k30gT2
    float _pxT2 = k15xT2 + k30xT2
    f_rowDt(trkT, _q, "tier BASE", _pxT1, _pgT1, _prT1, false)
    _q += 1
    f_rowDt(trkT, _q, "tier SCALE", _pxT2, _pgT2, _prT2, false)
    _q += 1
    f_rowDt(trkT, _q, "tier FULL", _px - _pxT1 - _pxT2, _pg - _pgT1 - _pgT2, _pr - _prT1 - _prT2, false)
    _q += 1
    int _prSw = k15rSw + k30rSw
    int _pgSw = k15gSw + k30gSw
    float _pxSw = k15xSw + k30xSw
    int _prSq = k15rSq + k30rSq
    int _pgSq = k15gSq + k30gSq
    float _pxSq = k15xSq + k30xSq
    f_rowDt(trkT, _q, "SWEEP", _pxSw, _pgSw, _prSw, false)
    _q += 1
    f_rowDt(trkT, _q, "no-SWEEP", _px - _pxSw, _pg - _pgSw, _pr - _prSw, false)
    _q += 1
    f_rowDt(trkT, _q, "SWP+Q", _pxSq, _pgSq, _prSq, false)
    _q += 1
    f_rowDt(trkT, _q, "SWP loQ", _pxSw - _pxSq, _pgSw - _pgSq, _prSw - _prSq, false)
    _q += 1
    string _winTxt = trkMode == "Full" ? "window " + str.format_time(trkStart, "yyyy-MM-dd") + " → " + str.format_time(trkEnd, "yyyy-MM-dd") : "mode: " + trkMode + " (per-TF midpoint)"
    // ── 1.12.0 TREND DIRECTION @ ENTRY (observe-only) ──
    // 1.12.1 — MUST pool 15m+30m ONLY, matching _px/_pg/_pr and _pxG/_pgG/_prG.
    // 1h is deliberately excluded from the house pool. Including k60 here made
    // DN x GREEN = GREEN(15m+30m) - UPxGREEN(15m+30m+1h): a 2-TF pool minus a
    // 3-TF pool. That produced impossible cells (win counts below zero).
    float _pxUp = k15xUp + k30xUp
    int   _pgUp = k15gUp + k30gUp
    int   _prUp = k15rUp + k30rUp
    float _pxUpG = k15xUpG + k30xUpG
    int   _pgUpG = k15gUpG + k30gUpG
    int   _prUpG = k15rUpG + k30rUpG
    float _pxUpY = k15xUpY + k30xUpY
    int   _pgUpY = k15gUpY + k30gUpY
    int   _prUpY = k15rUpY + k30rUpY
    f_rowDt(trkT, _q, "TREND DIR @entry", 0.0, 0, 0, true)
    _q += 1
    f_rowDt(trkT, _q, "UP 15m", k15xUp, k15gUp, k15rUp, false)
    _q += 1
    f_rowDt(trkT, _q, "UP 30m", k30xUp, k30gUp, k30rUp, false)
    _q += 1
    f_rowDt(trkT, _q, "UP 1h", k60xUp, k60gUp, k60rUp, false)
    _q += 1
    f_rowDt(trkT, _q, "DN 15m", k15x0 - k15xUp, k15g0 - k15gUp, k15r0 - k15rUp, false)
    _q += 1
    f_rowDt(trkT, _q, "DN 30m", k30x0 - k30xUp, k30g0 - k30gUp, k30r0 - k30rUp, false)
    _q += 1
    f_rowDt(trkT, _q, "DN 1h", k60x0 - k60xUp, k60g0 - k60gUp, k60r0 - k60rUp, false)
    _q += 1
    f_rowDt(trkT, _q, "DIR x REGIME 15m+30m", 0.0, 0, 0, true)
    _q += 1
    f_rowDt(trkT, _q, "UP x GREEN", _pxUpG, _pgUpG, _prUpG, false)
    _q += 1
    f_rowDt(trkT, _q, "UP x RED", _pxUp - _pxUpG - _pxUpY, _pgUp - _pgUpG - _pgUpY, _prUp - _prUpG - _prUpY, false)
    _q += 1
    f_rowDt(trkT, _q, "DN x GREEN", _pxG - _pxUpG, _pgG - _pgUpG, _prG - _prUpG, false)
    _q += 1
    f_rowDt(trkT, _q, "DN x RED", (_px - _pxG - _pxY) - (_pxUp - _pxUpG - _pxUpY), (_pg - _pgG - _pgY) - (_pgUp - _pgUpG - _pgUpY), (_pr - _prG - _prY) - (_prUp - _prUpG - _prUpY), false)
    _q += 1
    // ── 1.15.0 VOL @ ENTRY (observe-only) ──
    //   Pooled 15m+30m, matching _px/_pg/_pr. 1h stays out of the house pool
    //   — mixing pool widths produced impossible cells at 1.12.1.
    //   MID is DERIVED (pool - LO - HI), same convention as RED @entry and
    //   tier FULL, so it needs no accumulator. VOL HI x GREEN does need its
    //   own: a cross-tab cannot be recovered from two marginals.
    int   _prVlo = k15rVlo + k30rVlo
    int   _pgVlo = k15gVlo + k30gVlo
    float _pxVlo = k15xVlo + k30xVlo
    int   _prVhi = k15rVhi + k30rVhi
    int   _pgVhi = k15gVhi + k30gVhi
    float _pxVhi = k15xVhi + k30xVhi
    int   _prVhg = k15rVhg + k30rVhg
    int   _pgVhg = k15gVhg + k30gVhg
    float _pxVhg = k15xVhg + k30xVhg
    f_rowDt(trkT, _q, "VOL @entry", 0.0, 0, 0, true)
    _q += 1
    f_rowDt(trkT, _q, "VOL LO", _pxVlo, _pgVlo, _prVlo, false)
    _q += 1
    f_rowDt(trkT, _q, "VOL MID", _px - _pxVlo - _pxVhi, _pg - _pgVlo - _pgVhi, _pr - _prVlo - _prVhi, false)
    _q += 1
    f_rowDt(trkT, _q, "VOL HI", _pxVhi, _pgVhi, _prVhi, false)
    _q += 1
    f_rowDt(trkT, _q, "VOL HI x GRN", _pxVhg, _pgVhg, _prVhg, false)
    _q += 1
    f_rowDt(trkT, _q, "VOL HI x not-GRN", _pxVhi - _pxVhg, _pgVhi - _pgVhg, _prVhi - _prVhg, false)
    _q += 1
    // ── 1.16.0 EXIT MIX per VOL band (observe-only, DESCRIPTIVE ONLY) ──
    //   Pooled 15m+30m, same pool as the VOL rows above. Stop counts are
    //   stored for LO and HI; MID stop is derived from the pool, and every
    //   timeout is derived inside f_mixDt. Target counts reuse the _pg*
    //   values already computed above — the target% here MUST equal the
    //   win% on the matching VOL row, by construction.
    int _ps0   = k15s0 + k30s0
    int _psVlo = k15sVlo + k30sVlo
    int _psVhi = k15sVhi + k30sVhi
    f_rowDt(trkT, _q, "EXIT MIX  t/s/o", 0.0, 0, 0, true)
    _q += 1
    f_mixDt(trkT, _q, "LO  exits", _pgVlo, _psVlo, _prVlo)
    _q += 1
    f_mixDt(trkT, _q, "MID exits", _pg - _pgVlo - _pgVhi, _ps0 - _psVlo - _psVhi, _pr - _prVlo - _prVhi)
    _q += 1
    f_mixDt(trkT, _q, "HI  exits", _pgVhi, _psVhi, _prVhi)
    _q += 1
    table.cell(trkT, 0, _q, _winTxt, text_color=color.new(#8b949e, 0), text_size=size.tiny, text_halign=text.align_left)
    table.merge_cells(trkT, 0, _q, 3, _q)
    _q += 1
    table.cell(trkT, 0, _q, "earliest 15m " + str.format_time(k15t0, "yy-MM-dd") + " · 30m " + str.format_time(k30t0, "yy-MM-dd") + " · 1h " + str.format_time(k60t0, "yy-MM-dd"), text_color=color.new(#8b949e, 0), text_size=size.tiny, text_halign=text.align_left)
    table.merge_cells(trkT, 0, _q, 3, _q)
````
