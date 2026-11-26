# Adaptive Volatility Stop MTF

- url: https://www.tradingview.com/script/w3ie5uHs-Adaptive-Volatility-Stop-MTF/
- type: indicator
- pine_id: PUB;a6442f494c2942c5bd0c72d32ab401b0
- version: 3.0

## Description

# Adaptive Volatility Stop MTF (AVS MTF) — v1.2

**Open-source • Pine Script® v6 • Mozilla Public License 2.0**

---

## What this indicator does

AVS MTF is a multi-timeframe volatility-stop indicator. It runs four independent volatility-stop engines — one on the chart timeframe and one each on synthetically derived 3×, 5×, and 15× higher timeframes — and combines their directional states into a weighted bias score from −10 to +10.

Every stop adapts its ATR period and ATR multiplier in real time using the **Kaufman Efficiency Ratio (ER)**, so stops tighten in trending markets and widen in choppy ones.

Three additional integrated subsystems sit on top of the base engine:

- A **Hawkes self-exciting point process** that detects volatility clustering and proportionally raises the firing threshold during vol cascades
- A **data-integrity layer** that auto-detects asset class and flags degraded data (HEALTH = OK / Degraded / Critical)
- An **optional calibration tracker** that reports the engine's measured past hit rate per signal tier with Wilson 95% confidence intervals

The indicator does not predict future prices. It is a structured visualization tool for reading multi-timeframe trend agreement and volatility regime.

---

## Why this is a "mashup" — and why each component is necessary

This script combines four documented techniques:

1. **Volatility Stop** (Chande)
2. **Kaufman Efficiency Ratio**
3. **Multi-Timeframe Aggregation**
4. **Hawkes Self-Exciting Process**

Each component addresses a specific failure mode of the previous one. The integration is what makes the indicator useful:

**1. Volatility Stop (base layer)** — A trailing stop that ratchets in the trend direction by `ATR × multiplier`. By itself this is a classic indicator. Its weakness is well known: in choppy markets it flips constantly because ATR alone cannot tell whether price movement is directional or noise.

**2. Kaufman Efficiency Ratio (adaptation layer)** — ER = (net move) / (total path traveled), bounded in [0, 1]. High ER = trending; low ER = ranging. We use ER to adapt the volatility stop's ATR period (shorter in trends) AND ATR multiplier (tighter in trends). This addresses the choppy-flip problem of the bare volatility stop.

**3. Multi-Timeframe Aggregation (context layer)** — Adapting a single-TF stop is not enough. A "buy" signal on the chart TF means little if the dominant 15× TF is firmly bearish. We run the same adaptive engine on 4 timeframe tiers (Chart, 3×, 5×, 15×) and compute a weighted bias score where higher TFs carry more weight (1, 2, 3, 4). The score gates which signal tiers may fire.

**4. Hawkes Volatility-Cluster Detector (suppression layer)** — Even an adaptive, multi-TF stop fires false signals inside volatility cascades (news events, gap-and-go opens). A Hawkes process tracks an "intensity" that rises with each shock and decays each bar. When intensity / its own baseline exceeds a configurable multiple, the engine raises the bias-score floor required to fire new signals. The lift is proportional — at mild excess only marginal signals are held back; at severe excess only Major-tier flips can fire. A "vol+ / vol++ / vol+++" badge in the dashboard shows the current suppression level.

The combination is what's original here. None of these four components on its own solves the problems the other three address. AVS MTF chains them in a specific order so each layer compensates for the prior layer's weakness.

---

## How to use it

**Setup is minimal.** Add to chart, default settings work on intraday timeframes (5m, 15m, 1H) on liquid instruments (futures, large-cap equities, major crypto pairs).

**Read the dashboard top-down:**

- **SCORE** (−10 to +10): weighted MTF agreement. ≥ +4 = bullish bias, ≤ −4 = bearish.
- **BIAS**: text translation of the score (STRONG BULLISH / BULLISH BIAS / NEUTRAL / etc.).
- **REGIME**: TRENDING / DIRECTIONAL / CHOPPY / TRANSITION.
- **CONVERG**: how tightly the four stops cluster — HIGH = strong cross-TF agreement.
- **HEALTH**: OK / DGR / CRIT. Tooltip shows per-source detail. **Important: if HEALTH shows CRIT, the indicator is unreliable on this instrument.**

**Read the HTF Alignment Ribbon (top of chart):** four colored cells — Chart, 3×, 5×, 15× — showing each timeframe's directional state. When all four match color, you have full HTF alignment.

**Signal hierarchy (visual priority):**

- ▲ / ▼ **Filled label** (Major flip on 15× TF) — highest conviction
- ▲ / ▼ **Small triangle** (Trend flip on 5× TF) — strong
- ▲ / ▼ **Tiny triangle** (Scalp flip on 3× TF) — short-horizon
- ● **Circle** (pullback / band re-touch entry, opt-in display) — momentum continuation
- ✚ **Gold cross** (all higher TFs aligned simultaneously, opt-in display) — rare alignment event

**The Hawkes badge is your filter cue.** When you see `DGR vol++` in the regime row, the indicator is suppressing weak signals. You will see fewer Scalp/Trend signals during these periods. This is intentional — those are the periods where false flips cluster.

**The Calibration Panel (optional, off by default)** reports the engine's measured hit rate on past Trend and Major signals with Wilson 95% confidence intervals. The evaluation rule: a signal is counted as "hit" if price moves at least 0.5 × ATR in the signal direction within N bars (default 10). This is past-only descriptive data — **not a backtest, not a forward prediction, and it does not account for transaction costs, slippage, or execution.**

---

## What's in v1.2 (this version)

- **Flip Persistence Filter** — three modes (Off / Strict / Adaptive). Strict requires a 2-bar close hold beyond the new stop; Adaptive requires the flip-bar close to clear the prior stop by ≥ N × ATR (default 0.5×). Reduces wick-flip whiplash at HTF transitions. Default = Off (preserves v1.1 behavior).
- **Session-Opening Signal Filter** — suppresses Trend and Major flips during the first N bars of each intraday session (default 3 bars). Overnight gap bars contaminate ATR and produce spurious flips at the open. Affects intraday TFs only; ignored on daily/weekly. Default = Off.
- **Conviction-Strength Labels** — optional small label next to Trend and Major signals showing the bias score at firing time. Four modes (Auto / Minimal / Verbose / Off). Auto mode adapts size to chart TF and hides on ≤2-min charts where signals cluster densely. Drawing objects only — no plot-slot cost.
- **HTF Alignment Ribbon** — compact 4-cell horizontal strip showing the bull/bear state of every timeframe. Auto-places opposite the dashboard. Drawing object — no plot-slot cost.
- **Alert system reorganized** — the alert dialog now exposes the 10 most actionable conditions. All other event notifications fire automatically via `alert()` blocks. Set up an alert with condition **"Any alert() function call"** on this script to receive every event.

---

## Originality / what makes this different from existing public scripts

There are many volatility-stop indicators on TradingView, and several multi-timeframe wrappers. AVS MTF differs in three specific ways:

1. **Independent ER adaptation per timeframe.** Most MTF wrappers compute a single ER on the chart TF and apply the same multiplier across timeframes. AVS MTF runs a separate ER calculation on each tier so adaptation is mathematically correct at every timeframe — the 15× TF doesn't get the chart TF's noise-window applied to it.
2. **Proportional Hawkes suppression integrated with the bias-score gate.** The Hawkes lift is added directly to the score-floor used by the signal-firing logic. This is not a binary "block signals during high volatility" filter — the suppression scales smoothly with measured volatility-cluster intensity.
3. **Asset-class-aware data integrity.** Auto-detects Equity / Futures / Index / FX / Crypto and adjusts which validation checks apply (e.g., the volume filter is auto-disabled on volumeless instruments like spot indices, where it would silently mis-fire).

---

## Settings worth knowing

- **Adaptive Mode** = "Both" (default): adapts both ATR period AND multiplier from ER. Set to "Off" for fixed-parameter behavior comparable to a classic volatility stop.
- **Fast/Slow ATR Bounds**: the range across which ER adaptation moves the ATR period. Wider = more dramatic adaptation.
- **Hawkes Max Score Lift**: how aggressive the volatility-cluster suppression is. Default 2.0 = at peak intensity, a signal needing |score| > 2 will need |score| > 4. Set to 0 to disable suppression while keeping the badge descriptive.
- **Flip Persistence Filter** (v1.2): Off / Strict / Adaptive. Use Strict on slow trending markets, Adaptive on faster-moving instruments.
- **Session-Opening Filter** (v1.2): Off by default. Turn on for markets with strong open-bar volatility (NSE, NYSE, etc.).
- **Conviction Labels** (v1.2): Auto by default. Adapts to chart TF automatically.
- **Calibration Panel**: OFF by default. Turn on to see past hit rates with Wilson 95% CIs.

---

## Important disclaimer

This indicator is provided for **educational and informational purposes only**. It does NOT constitute financial, investment, trading, or any other form of advice.

- Past performance of any signal does not guarantee future results.
- The calibration panel reports descriptive past-only outcomes using a fixed evaluation rule. It is NOT a backtest, NOT a forward prediction, and does NOT account for transaction costs, slippage, or execution.
- All trading involves substantial risk of loss.
- Use proper risk management including position sizing and stop-loss orders.
- The author is not a licensed financial advisor. Consult a qualified professional before making any financial decisions.

---

## License

Released under the Mozilla Public License 2.0 (TradingView default open-source license).

---

## References

- Perry Kaufman — *Trading Systems and Methods* (Efficiency Ratio + KAMA framework)
- Alan Hawkes (1971) — *Spectra of some self-exciting and mutually exciting point processes*
- Edwin B. Wilson (1927) — *Probable inference, the law of succession, and statistical inference* (Wilson score interval)

Open-source — feedback, forks, and improvement suggestions welcome via the script comments.

## Source Code

````pine
// @version=6
// ════════════════════════════════════════════════════════════════════════════
//
//                    Adaptive Volatility Stop MTF
//                            (AVS MTF) v1.4
//
// ════════════════════════════════════════════════════════════════════════════
//  Name        : Adaptive Volatility Stop MTF
//  Short name  : AVS MTF
//  Version     : 1.4
//  Platform    : TradingView  •  Pine Script® v6
//  License     : Mozilla Public License 2.0
//  Author      : Market_Logic_India
//
//  ──────────────────────────── OVERVIEW ─────────────────────────────────
//  AVS MTF is a multi-timeframe volatility-stop indicator. It runs four
//  independent volatility-stop engines — one on the chart timeframe and one
//  each on synthetically derived 3×, 5×, and 15× higher timeframes — and
//  combines their directional states into a weighted bias score. Every stop
//  adapts its ATR period and ATR multiplier in real time using the
//  Efficiency Ratio (ER), so stops tighten in trending markets and widen in
//  choppy ones. A self-exciting volatility-cluster detector raises the
//  firing threshold during high-volatility regimes, a data-integrity layer
//  flags degraded data, and an optional calibration tracker reports the
//  engine's measured past hit rate by signal tier with 95% confidence bands.
//
//  ─────────────────── WHY THIS IS A "MASHUP" ───────────────────────────
//    1. Trailing volatility stop — ATR-multiple trailing exit (the base)
//    2. Efficiency Ratio (ER)   — adapts ATR period + multiplier to trend quality
//    3. Multi-Timeframe Aggregation — weighted bias score from 4 TF tiers
//    4. Self-exciting cluster filter — proportional signal suppression in bursts
//    5. Path-dependent volatility scaler — a lightweight, optional
//       reading of the recent return PATH (activity clustering + leverage +
//       upside convexity) pre-scales each tier's stop distance, so bands
//       expand BEFORE volatility arrives rather than after. Fully optional;
//       OFF reproduces v1.3 stop distances exactly.
//
//  ─────────────── HOW THE PARTS WORK TOGETHER (one chain) ───────────────
//  These are not five separate tools stacked on a chart — each feeds the
//  next. (1) The trailing volatility stop needs a distance; (2) the
//  Efficiency Ratio sets that distance's ATR period + multiplier from how
//  cleanly price is trending; (5) the path-dependent scaler then nudges the
//  same distance up or down from the recent return path; (3) the resulting
//  stop is computed on four timeframe tiers and aggregated into one bias
//  score; and (4) the cluster filter raises the score a signal must clear
//  before it may fire, so the same volatility burst that widens the stop
//  also makes the engine more selective. Remove any one piece and the rest
//  degrade: no ER → fixed stops; no MTF → a single-timeframe stop; no
//  cluster filter → signals in chaos; no path scaler → reactive, not
//  anticipatory. The integration is the product.
//
//  ────────────────────── BIAS SCORE (−10 to +10) ───────────────────────
//  Higher timeframes carry more weight (×4, ×3, ×2, ×1). The score drives
//  the dashboard readout, the signal color gradient, and the score-floor
//  gates that decide which signal tier may fire.
//
//  ─────────────────────── REFERENCES / SOURCES ──────────────────────────
//  All components are standard, widely documented technical concepts —
//  no third-party script code is reused:
//  • Efficiency Ratio   — net directional move ÷ total path length
//  • Trailing volatility stop — Average True Range (ATR) multiple trailing exit
//  • Self-exciting cluster process — shock intensity that rises then decays
//  • Score-method confidence interval — small-sample proportion bounds
//  • Path-dependent volatility — near-term vol read from the recent return path
//
//  ───────────────── CHANGELOG / UPGRADE NOTES (v1.3 → v1.4) ──────────────
//  v1.4 adds an OPTIONAL Path-Dependent Volatility (PDV) scaler to the stop
//  engine. This is the FIRST signal-affecting change since v1.1 — when it is
//  enabled, stop distances (and therefore flip timing) can differ from v1.3.
//  • Each tier's base stop distance is multiplied by a path-dependent factor
//    derived inside the same adaptive engine, from the recent return path:
//      – activity clustering  (fast vs slow EWMA of squared returns),
//      – leverage / fear      (recent net DOWN drift widens the stop),
//      – upside convexity     (recent net UP drift widens it a touch).
//    The factor is clamped to a user band and blended by a weight, so the
//    stop pre-expands going into volatility and re-tightens as it calms.
//  • Turn it OFF (🌊 Path-Dependent Vol → Enable = off) and every stop, band,
//    signal, alert and export is BIT-IDENTICAL to v1.3 — the scaler collapses
//    to ×1.00. A new "VOL FCST" dashboard detail row and an
//    EXP_PDV_Multiplier data-window export surface the live factor.
//  • The volatility-cluster filter, bias score, calibration tracker (its own
//    independent ATR(14) yardstick) and the entire v1.3 UI are unchanged.
//
//  ───────────────── CHANGELOG / UPGRADE NOTES (v1.2 → v1.3) ──────────────
//  v1.3 is a VISUAL / USABILITY upgrade only. The signal engine, the bias
//  score, the volatility-cluster filter, the data-integrity layer, the calibration
//  tracker, all alerts and all data-window exports are UNCHANGED from v1.2 —
//  signals fire on exactly the same conditions, so existing alerts keep
//  working as-is. What changed on screen:
//   • ADAPTIVE PANEL THEME — the dashboard and calibration panel read the
//     chart background (chart.bg_color) and recolor for maximum contrast on
//     any background (dark / light / sepia / custom). A manual "Panel Theme"
//     override (Auto / Force Dark / Force Light) handles gradient or image
//     backgrounds. Score, regime, momentum, convergence and health colors
//     switch to dark-saturated variants on light charts so nothing washes out.
//   • SINGLE UNIFIED VERTICAL DASHBOARD — the former separate Dashboard, HTF
//     Ribbon and Legend tables are folded into ONE vertical table with zebra
//     striping, a colored 4-tier timeframe block (the built-in alignment
//     ribbon), the full stats stack, the health row, and an optional in-panel
//     legend. Sections still toggle via the existing show_* inputs.
//   • TIERED GREEN / RED BANDS — band fills now encode DIRECTION by hue
//     (green = bull, red = bear) and TIMEFRAME TIER by depth (Chart = lightest
//     → 5×/15× = deepest), replacing the old per-tier multi-hue scheme. Fills
//     are a touch richer by default (band transparency 82 → 67) and adapt to a
//     light background. The vstop lines and edge labels follow the same hues.
//   • DEFAULTS — pullback markers and the all-HTF-aligned markers now display
//     by default; background bias shading is now OFF by default for a cleaner
//     chart. All remain user-toggleable.
//
//  ─────────────────────────── DISCLAIMER ─────────────────────────────────
//  This indicator is provided for EDUCATIONAL and INFORMATIONAL purposes
//  only. It does NOT constitute financial, investment, trading, or any
//  other form of advice. Past performance does not guarantee future results.
//  The calibration panel reports descriptive past-only outcomes — NOT a
//  backtest, NOT a forward prediction. All trading involves substantial risk
//  of loss. Use proper risk management. The author is not a licensed
//  financial advisor; consult a qualified professional before any financial
//  decision.
//  ────────────────────────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════
indicator("Adaptive Volatility Stop MTF",
     shorttitle="AVS MTF",
     overlay=true,
     max_labels_count=500,
     max_lines_count=500)

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 1 — USER INPUTS
// ════════════════════════════════════════════════════════════════════════════

// ── Group: Adaptive Engine ────────────────────────────────────────────────
adaptive_mode = input.string(
     "Both",
     title       = "Adaptive Mode",
     options     = ["Off", "Length Only", "Multiplier Only", "Both"],
     tooltip     = "Selects which ATR parameters the Efficiency Ratio engine adjusts.\n• Both = full adaptation (recommended)\n• Off = fixed ATR period and multiplier for all timeframes.",
     group       = "⚙ Adaptive Engine")

fast_len = input.int(
     8,
     title   = "Fast ATR Bound (Trending)",
     tooltip = "Lower bound for the adaptive ATR period. Applied when the Efficiency Ratio is high (trending market).",
     group   = "⚙ Adaptive Engine",
     minval  = 2,
     maxval  = 20)

slow_len = input.int(
     30,
     title   = "Slow ATR Bound (Choppy)",
     tooltip = "Upper bound for the adaptive ATR period. Applied when the Efficiency Ratio is low (ranging/choppy market).",
     group   = "⚙ Adaptive Engine",
     minval  = 10,
     maxval  = 100)

er_band_offset = input.float(
     0.20,
     title   = "ER Threshold Offset (±)",
     tooltip = "Half-width of the neutral ER zone. A wider value reduces the frequency of regime switches between trending and choppy states.",
     group   = "⚙ Adaptive Engine",
     step    = 0.01,
     minval  = 0.01,
     maxval  = 0.49)

tf_scale_er = input.bool(
     true,
     title   = "Auto-Scale ER Lookbacks to Timeframe",
     tooltip = "Scales the ER lookback and normalization window so that each higher timeframe represents an equivalent real-world time window. Recommended: ON.",
     group   = "⚙ Adaptive Engine")

// ── Group: Base Settings ──────────────────────────────────────────────────
src_price = input.source(
     close,
     title   = "Price Source",
     tooltip = "The series the volatility-stop engine is built from, on every timeframe tier. Default = close. Pick hl2 / hlc3 / ohlc4 for smoother stops, or the output of any other indicator to drive the engine off a custom series. Works on any symbol in any market — stocks, futures, FX, crypto, indices. (True Range for the ATR is always taken from OHLC, so this stays robust on gappy instruments.)",
     group   = "📐 Base Settings")

atr_len = input.int(
     20,
     title  = "ATR Period (Adaptive Mode Off)",
     group  = "📐 Base Settings",
     minval = 2)

atr_mult = input.float(
     2.0,
     title  = "ATR Multiplier (Adaptive Mode Off)",
     group  = "📐 Base Settings",
     step   = 0.1,
     minval = 0.5)

early_breach = input.bool(
     true,
     title   = "Early Breach Detection",
     tooltip = "Highlights bars where price closes through the volatility stop before the stop itself flips direction. An early-breach bar is an unconfirmed signal — it warns that a flip may be imminent without committing to it.",
     group   = "📐 Base Settings")

limbo_tf = input.string(
     "Signal TF (3×)",
     title   = "Early Breach Reference TF",
     options = ["Chart TF", "Signal TF (3×)"],
     group   = "📐 Base Settings")

// ── Group: Volatility-Cluster Detection ──────────────────────────────────
vcl_enable = input.bool(
     true,
     title   = "Enable Volatility-Cluster Detection",
     tooltip = "Self-exciting point process. Each large-return bar raises an 'intensity' that decays each bar. When intensity rises above the warning multiple of its own baseline, the engine proportionally raises the signal-firing threshold. Max suppression caps at the Major-flip score. Existing flips already on the chart are NOT removed; only NEW flips are gated.",
     group   = "⚡ Volatility-Cluster Filter")

vcl_alpha = input.float(
     0.50,
     title   = "Excitation (alpha)",
     tooltip = "How much each shock amplifies intensity. Must be less than 1.0 for the process to remain stable. Higher = more sensitive to single shocks.",
     group   = "⚡ Volatility-Cluster Filter",
     minval  = 0.10,
     maxval  = 0.90,
     step    = 0.05)

vcl_beta = input.float(
     0.20,
     title   = "Decay (beta)",
     tooltip = "How fast intensity decays each bar. Smaller value = longer memory of past shocks.",
     group   = "⚡ Volatility-Cluster Filter",
     minval  = 0.05,
     maxval  = 0.50,
     step    = 0.05)

vcl_shock_sig = input.float(
     2.0,
     title   = "Shock Threshold (× sigma)",
     tooltip = "Returns exceeding this many standard deviations count as 'shocks' that excite the process.",
     group   = "⚡ Volatility-Cluster Filter",
     minval  = 1.5,
     maxval  = 4.0,
     step    = 0.1)

vcl_warn_mult = input.float(
     3.0,
     title   = "Warning Threshold (× baseline)",
     tooltip = "Below this multiple of baseline, the engine treats volatility as normal. Above it, the threshold lift starts to scale. Higher value = less sensitive (rare warnings); lower = more sensitive.",
     group   = "⚡ Volatility-Cluster Filter",
     minval  = 1.5,
     maxval  = 5.0,
     step    = 0.1)

vcl_max_lift = input.float(
     2.0,
     title   = "Max Score Lift (points)",
     tooltip = "Maximum bias-score requirement added during the most severe volatility cluster. At peak intensity, a signal needing score ≥ 1 would need score ≥ (1 + lift) to fire. Set to 0 to disable suppression while keeping the badge descriptive.",
     group   = "⚡ Volatility-Cluster Filter",
     minval  = 0.0,
     maxval  = 4.0,
     step    = 0.5)

vcl_lift_span = input.float(
     2.0,
     title   = "Lift-Scaling Span (× baseline)",
     tooltip = "How much further above the warn threshold corresponds to the maximum lift. Default 2.0 means lift saturates at warn + 2× baseline (e.g. warn=3.0 + span=2.0 → saturates at 5× baseline).",
     group   = "⚡ Volatility-Cluster Filter",
     minval  = 0.5,
     maxval  = 5.0,
     step    = 0.5)

// ── Group: Path-Dependent Volatility (v1.4) ───────────────────────────────
pdv_on = input.bool(
     true,
     title   = "Enable Path-Dependent Stop Scaling",
     tooltip = "Scales each tier's stop DISTANCE by a path-dependent volatility factor read from the recent return path — activity clustering, leverage/fear, and upside convexity — pre-widens the stop before volatility arrives and re-tightens it as the market calms. OFF = bit-identical to v1.3 (factor collapses to ×1.00). This is the only signal-affecting toggle added in v1.4.",
     group   = "🌊 Path-Dependent Vol")

pdv_w = input.float(
     0.5,
     title   = "Influence Weight (0 = off … 1 = full)",
     tooltip = "How strongly the path factor moves the stop. The applied multiplier is (1 − weight) + weight × clamped_factor, so 0 reproduces v1.3 even with the module enabled, and 1 applies the full clamped factor.",
     group   = "🌊 Path-Dependent Vol",
     minval  = 0.0,
     maxval  = 1.0,
     step    = 0.05)

pdv_fast = input.int(
     10,
     title   = "Fast Path Window (activity / drift)",
     tooltip = "Short EWMA window over squared returns (recent activity) and signed returns (recent drift). Lower = more reactive.",
     group   = "🌊 Path-Dependent Vol",
     minval  = 2,
     maxval  = 50)

pdv_slow = input.int(
     60,
     title   = "Slow Path Window (baseline activity)",
     tooltip = "Long EWMA window over squared returns — the baseline the recent activity is measured against. The activity ratio = sqrt(fast / slow).",
     group   = "🌊 Path-Dependent Vol",
     minval  = 10,
     maxval  = 250)

pdv_lev = input.float(
     0.30,
     title   = "Leverage Sensitivity (down-move → wider)",
     tooltip = "Leverage term. Recent NET DOWN drift (normalised by ATR) widens the stop by up to this much. Set 0 to disable the asymmetry.",
     group   = "🌊 Path-Dependent Vol",
     minval  = 0.0,
     maxval  = 1.0,
     step    = 0.05)

pdv_cvx = input.float(
     0.15,
     title   = "Upside Convexity (up-move → wider)",
     tooltip = "Recent NET UP drift (normalised by ATR) widens the stop by up to this much — captures volatile rallies. Usually smaller than leverage. Set 0 to disable.",
     group   = "🌊 Path-Dependent Vol",
     minval  = 0.0,
     maxval  = 1.0,
     step    = 0.05)

pdv_lo = input.float(
     0.70,
     title   = "Min Multiplier (floor)",
     tooltip = "Lower clamp on the path factor before weighting — prevents the stop from collapsing too tight in ultra-quiet conditions.",
     group   = "🌊 Path-Dependent Vol",
     minval  = 0.40,
     maxval  = 1.00,
     step    = 0.05)

pdv_hi = input.float(
     1.80,
     title   = "Max Multiplier (cap)",
     tooltip = "Upper clamp on the path factor before weighting — caps how far the stop can pre-expand during a volatility burst.",
     group   = "🌊 Path-Dependent Vol",
     minval  = 1.00,
     maxval  = 3.00,
     step    = 0.10)

// ── Group: Data Integrity ─────────────────────────────────────────────────
show_health_row = input.bool(
     true,
     title   = "Show Data-Health Row in Dashboard",
     tooltip = "Surfaces volume validity, HTF feed health, and asset class detection. Recommended ON — it tells you when AVS MTF is operating on degraded data.",
     group   = "🩺 Data Integrity")

// ── Group: Calibration Tracker (opt-in panel) ─────────────────────────────
cal_enable = input.bool(
     true,
     title   = "Enable Calibration Logging",
     tooltip = "Logs every Trend and Major flip at firing time. After the evaluation horizon, the engine checks whether price moved at least the minimum-move threshold in the signal direction. Required for the calibration panel. Logging cost is negligible.",
     group   = "📊 Calibration Tracker")

cal_show_panel = input.bool(
     false,
     title   = "Show Calibration Panel",
     tooltip = "OFF by default to keep the chart uncluttered. Turn on to display the engine's measured hit rate by signal tier (Trend / Major / All) with 95% confidence intervals. Past-only descriptive data — NOT a backtest, NOT a forward prediction.",
     group   = "📊 Calibration Tracker")

cal_panel_pos = input.string(
     "Bottom Left",
     title   = "Calibration Panel Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"],
     group   = "📊 Calibration Tracker")

cal_horizon = input.int(
     10,
     title   = "Evaluation Horizon (bars)",
     tooltip = "How many bars after a signal fires before the outcome is evaluated. Default 10. Longer = harder to satisfy but more meaningful.",
     group   = "📊 Calibration Tracker",
     minval  = 3,
     maxval  = 50)

cal_move_atr = input.float(
     0.5,
     title   = "Minimum Move (× ATR) for Hit",
     tooltip = "How much price must move (in ATR units) in the signal direction within the horizon to count as a 'hit'. Default 0.5 × ATR.",
     group   = "📊 Calibration Tracker",
     minval  = 0.1,
     maxval  = 2.0,
     step    = 0.1)

// ── Group: Bands ──────────────────────────────────────────────────────────
show_b1 = input.bool(true, "Show Chart / 3× Band",  group = "🎨 Bands")
show_b2 = input.bool(true, "Show 3× / 5× Band",     group = "🎨 Bands")
show_b3 = input.bool(true, "Show 5× / 15× Band",    group = "🎨 Bands")

t1 = input.int(67, "Chart/3× Transparency",  group = "🎨 Bands", minval = 50, maxval = 95)
t2 = input.int(67, "3×/5× Transparency",     group = "🎨 Bands", minval = 50, maxval = 95)
t3 = input.int(67, "5×/15× Transparency",    group = "🎨 Bands", minval = 50, maxval = 95)

show_v1_line   = input.bool(true,  "Show Chart Volatility Stop Line",   group = "🎨 Bands")
show_v2_line   = input.bool(true,  "Show 3× Volatility Stop Line",      group = "🎨 Bands")
show_edge_lbl  = input.bool(true,  "Right-Edge Price Labels",            group = "🎨 Bands")
show_bg        = input.bool(false, "Background Bias Shading",            group = "🎨 Bands")
show_stop_dist = input.bool(true,  "Stop Distance Label (3× TF)",
     tooltip = "Displays the live stop distance in price units and percent next to the 3× volatility stop line.",
     group   = "🎨 Bands")

// ── Group: Signals ────────────────────────────────────────────────────────
show_signals = input.bool(true, "Show Signals", group = "📡 Signals")

filter_choppy = input.bool(
     true,
     title   = "Filter Signals in Choppy Market",
     tooltip = "Suppresses all signals when the bias score magnitude is ≤ 2. Reduces false signals during sideways price action.",
     group   = "📡 Signals")

htf_bias_lock = input.bool(
     true,
     title   = "Higher Timeframe Bias Lock (15× Macro Filter)",
     tooltip = "When the 15× volatility stop is bearish, suppresses all bullish signals below the Trend tier (and vice versa). Prevents counter-trend scalp signals against the dominant timeframe direction.",
     group   = "📡 Signals")

pb_confirm = input.bool(
     true,
     title   = "2-Bar Pullback Confirmation",
     tooltip = "Requires the prior bar to have also closed beyond the band boundary before firing a pullback signal. Eliminates wick-triggered entries.",
     group   = "📡 Signals")

signal_priority = input.bool(
     true,
     title   = "Signal Priority Hierarchy",
     tooltip = "When enabled: Major signals suppress Trend + Scalp + Pullback on the same bar. Trend signals suppress Scalp + Pullback. Prevents visual stacking of overlapping signals.",
     group   = "📡 Signals")

vol_gate = input.bool(
     false,
     title   = "Volume Filter on Pullbacks",
     tooltip = "Only fires pullback signals when volume exceeds its moving average. Filters low-volume band touches that may lack conviction. Auto-disabled on volumeless instruments.",
     group   = "📡 Signals")

vol_len = input.int(20, "Volume MA Period", group = "📡 Signals", minval = 5)

show_limbo = input.bool(true, "Color Bars on Early-Breach Events", group = "📡 Signals")

show_pullback_signals = input.bool(
     true,
     title   = "Display Pullback Signals (Scalp/Trend/Major)",
     tooltip = "Renders the 6 pullback dot signals on chart. ON by default. Alerts fire regardless of display state.",
     group   = "📡 Signals")

show_all_htf_cross = input.bool(
     true,
     title   = "Display All-HTF-Aligned Cross Markers",
     tooltip = "Renders yellow ✚ markers when all four timeframes are bull or bear aligned. ON by default. Alerts fire regardless of display state.",
     group   = "📡 Signals")

show_conviction_labels = input.string(
     "Auto (adapts to TF)",
     title   = "Conviction Labels on Trend/Major Signals",
     options = ["Off", "Auto (adapts to TF)", "Minimal (no text)", "Verbose (always show score)"],
     tooltip = "Auto: small labels on higher TFs, hidden on ≤2-min charts where they overlap. Minimal: just a small marker without text. Verbose: always show the score even when saturated at ±10 and even on low TFs. Off: no labels at all. All modes use drawing objects only — never consume plot slots.",
     group   = "📡 Signals")

conviction_label_cooldown = input.int(
     5,
     title   = "  Label cooldown (bars between same-direction labels)",
     minval  = 0, maxval = 30,
     tooltip = "Prevents label spaghetti when many same-direction Major or Trend signals fire close together. After a label renders, subsequent same-direction labels are skipped for this many bars. Signal arrows still show — only the text label is suppressed. Set to 0 for no cooldown.",
     group   = "📡 Signals")

// ── Flip Persistence Filter ───────────────────────────────────────────────
flip_persist_mode = input.string(
     "Off (v1.1 behavior)",
     title   = "Flip Persistence Filter",
     options = ["Off (v1.1 behavior)", "Strict (2-bar hold)", "Adaptive (close beyond ½ ATR)"],
     tooltip = "Reduces wick-flip whiplash on Trend/Major signals. Off = legacy. Strict = require close to hold beyond the new stop for 2 consecutive bars. Adaptive = require the flip bar's close to clear the prior stop by at least ½ ATR.",
     group   = "📡 Signals")

flip_persist_atr_mult = input.float(
     0.5,
     title   = "  Adaptive flip threshold (× ATR)",
     minval  = 0.1, maxval = 2.0, step = 0.1,
     tooltip = "Only used in Adaptive mode. Higher = stricter. 0.5×ATR is the recommended default.",
     group   = "📡 Signals")

// ── Session-Opening Signal Filter ─────────────────────────────────────────
session_filter_on = input.bool(
     false,
     title   = "Session-Opening Signal Filter (intraday)",
     tooltip = "When enabled, suppresses Trend and Major flip signals during the first N bars of each trading session. Affects intraday TFs only (≤ 4h); ignored on daily/weekly. No effect on Scalp tier.",
     group   = "📡 Signals")

session_filter_bars = input.int(
     3,
     title   = "  Bars to suppress after session open",
     minval  = 1, maxval = 12,
     tooltip = "3 bars on a 15m chart = first 45 minutes. NSE: covers pre-open print noise (9:15-10:00 IST).",
     group   = "📡 Signals")

// ── Group: Dashboard ──────────────────────────────────────────────────────
show_dash    = input.bool(true, "Show Dashboard",            group = "📊 Dashboard")
compact_dash = input.bool(false, "Compact Mode (hide detail rows)",
     tooltip = "Hides the Stop Δ and ER/Len/Mult rows for a shorter panel.",
     group   = "📊 Dashboard")
show_htf_rows = input.bool(true, "Show 4-Tier Timeframe Block",
     tooltip = "The colored Chart / 3× / 5× / 15× rows act as a built-in alignment ribbon — all green = full bull alignment, all red = full bear alignment.",
     group   = "📊 Dashboard")
show_legend  = input.bool(true, "Show Signal Legend (in-panel)",  group = "📊 Dashboard")

dash_pos = input.string(
     "Top Right",
     title   = "Dashboard Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"],
     group   = "📊 Dashboard")

panel_theme = input.string(
     "Auto (match chart)",
     title   = "Panel Theme",
     options = ["Auto (match chart)", "Force Dark", "Force Light"],
     tooltip = "Auto reads the chart background color (chart.bg_color) and adapts panel colors for maximum contrast. Use Force Dark / Force Light if your chart uses a gradient or image background that confuses auto-detection.",
     group   = "📊 Dashboard")

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 2 — UTILITY FUNCTIONS + ADAPTIVE THEME
// ════════════════════════════════════════════════════════════════════════════

// ── Adaptive theme detection (v1.3) ───────────────────────────────────────
// Relative luminance of the chart background. chart.bg_color reflects the
// user's Appearance→Background setting and re-triggers the script when changed.
f_luminance(c) =>
    0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)

is_light_chart = panel_theme == "Force Light" ? true :
                 panel_theme == "Force Dark"  ? false :
                 f_luminance(chart.bg_color) > 140.0

// Theme-aware semantic colors (used by scores, regime, momentum, health…)
C_GREEN   = is_light_chart ? #1ba94c : #00e676
C_GREEN2  = is_light_chart ? #2e9e54 : #69f0ae
C_RED     = is_light_chart ? #d32f2f : #ff1744
C_AMBER   = is_light_chart ? #c77700 : #ff9800
C_NEUTRAL = is_light_chart ? #546170 : #78909c
C_ACCENT  = is_light_chart ? #1565c0 : #58a6ff

// Adaptive panel surfaces — recomputed from theme so panels stay legible on
// any background (dark, light, sepia, custom).
THEME_PANEL_BG  = is_light_chart ? color.new(#ffffff, 6)  : color.new(#0b0f17, 6)
THEME_ROW_BG    = is_light_chart ? color.new(#eef2f7, 0)  : color.new(#161b22, 22)
THEME_ROW_ALT   = is_light_chart ? color.new(#e1e7ef, 0)  : color.new(#0f141c, 22)
THEME_SEP_BG    = is_light_chart ? color.new(#cbd3dd, 0)  : color.new(#0a0f18, 28)
THEME_BORDER    = is_light_chart ? color.new(#aeb8c4, 25) : color.new(#2a3340, 45)
THEME_FRAME     = is_light_chart ? color.new(#1565c0, 20) : color.new(#2979ff, 35)
THEME_HEADER_BG = is_light_chart ? color.new(#1565c0, 0)  : color.new(#0d1b2a, 15)
THEME_HEADER_TX = is_light_chart ? color.white : #58a6ff
THEME_LABEL_TX  = is_light_chart ? #33424f : #9aa5b1
THEME_DIM_TX    = is_light_chart ? #5a6776 : #6e7a89
THEME_VALUE_TX  = chart.fg_color
THEME_BULL_BG   = is_light_chart ? color.new(#1ba94c, 10) : color.new(#00e676, 20)
THEME_BEAR_BG   = is_light_chart ? color.new(#d32f2f, 10) : color.new(#ff1744, 20)

// Zebra-stripe helper for the unified dashboard
f_rowbg(i) =>
    i % 2 == 0 ? THEME_ROW_BG : THEME_ROW_ALT

// ── Timeframe String Resolver ─────────────────────────────────────────────
get_tf_str(tf_mins) =>
    result =
         tf_mins < 2     ? "1"   :
         tf_mins < 3     ? "2"   :
         tf_mins < 5     ? "3"   :
         tf_mins < 10    ? "5"   :
         tf_mins < 15    ? "10"  :
         tf_mins < 30    ? "15"  :
         tf_mins < 45    ? "30"  :
         tf_mins < 60    ? "45"  :
         tf_mins < 120   ? "60"  :
         tf_mins < 180   ? "120" :
         tf_mins < 240   ? "180" :
         tf_mins < 360   ? "240" :
         tf_mins < 720   ? "360" :
         tf_mins < 1440  ? "720" :
         tf_mins < 4320  ? "1D"  :
         tf_mins < 10080 ? "3D"  :
         tf_mins < 43200 ? "1W"  : "1M"
    result

// ── Derive Higher Timeframe Strings ──────────────────────────────────────
tf_secs = timeframe.in_seconds()
tf2_str = get_tf_str(tf_secs * 3  / 60)   // 3× chart TF  → Scalp tier
tf3_str = get_tf_str(tf_secs * 5  / 60)   // 5× chart TF  → Trend tier
tf4_str = get_tf_str(tf_secs * 15 / 60)   // 15× chart TF → Major tier

// ── ER Lookback Auto-Scaling ──────────────────────────────────────────────
base_secs      = 900.0
er_len_scaled  = tf_scale_er ? math.max(5,  math.round(30  * base_secs / tf_secs)) : 30
er_dyn_scaled  = tf_scale_er ? math.max(20, math.round(100 * base_secs / tf_secs)) : 100
mom_len_scaled = tf_scale_er ? math.max(2,  math.round(3   * base_secs / tf_secs)) : 3

// ── Custom RMA accepting float length ────────────────────────────────────
f_rma(src, length) =>
    a    = 1.0 / math.max(length, 1.0)
    var float r = na
    r   := na(r[1]) ? src : r[1] + a * (src - r[1])
    r

// ── Score → Gradient Color (theme-aware) ───────────────────────────────────
score_color(s) =>
    color result = C_NEUTRAL
    if is_light_chart
        if s >= 8
            result := #0a8f3c
        else if s >= 4
            result := #1ba94c
        else if s >= 1
            result := #2e9e54
        else if s == 0
            result := #546170
        else if s >= -3
            result := #d05a5a
        else if s >= -7
            result := #d32f2f
        else
            result := #c1121f
    else
        if s >= 8
            result := #00e676
        else if s >= 4
            result := #69f0ae
        else if s >= 1
            result := #b9f6ca
        else if s == 0
            result := #78909c
        else if s >= -3
            result := #ffcdd2
        else if s >= -7
            result := #ef9a9a
        else
            result := #ff1744
    result

// ── Score → Text Label ────────────────────────────────────────────────────
score_label(s) =>
    string result = "NEUTRAL"
    if s >= 8
        result := "STRONG BULLISH"
    else if s >= 4
        result := "BULLISH BIAS"
    else if s >= 1
        result := "SCALP LONG"
    else if s == 0
        result := "NEUTRAL"
    else if s >= -3
        result := "SCALP SHORT"
    else if s >= -7
        result := "BEARISH BIAS"
    else
        result := "STRONG BEARISH"
    result

// ── Score → Suggested Action Text (informational only) ───────────────────
score_action(s) =>
    string result = "STAY OUT   —"
    if s >= 8
        result := "FULL TRADE ▲"
    else if s >= 4
        result := "TREND / PB ▲"
    else if s >= 1
        result := "SCALP ONLY △"
    else if s == 0
        result := "STAY OUT   —"
    else if s >= -3
        result := "SCALP ONLY ▽"
    else if s >= -7
        result := "TREND / PB ▼"
    else
        result := "FULL TRADE ▼"
    result

// ── Table Position Helper ─────────────────────────────────────────────────
tbl_pos(s) =>
    string result = position.bottom_left
    if s == "Top Right"
        result := position.top_right
    else if s == "Top Left"
        result := position.top_left
    else if s == "Bottom Right"
        result := position.bottom_right
    result

// ── 95% score-method confidence interval for a proportion ────────────────
f_score_ci(int hits, int total) =>
    float lo = na
    float hi = na
    if total >= 5
        float p   = hits / float(total)
        float z   = 1.96
        float den = 1.0 + z * z / total
        float c   = (p + z * z / (2.0 * total)) / den
        float h   = z * math.sqrt(p * (1.0 - p) / total + z * z / (4.0 * total * total)) / den
        lo := math.max(0.0, c - h)
        hi := math.min(1.0, c + h)
    [lo, hi]

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 2b — DATA INTEGRITY LAYER
// ════════════════════════════════════════════════════════════════════════════

string symType = syminfo.type
bool isEquity  = symType == "stock"  or symType == "fund" or symType == "dr"
bool isFutures = symType == "futures"
bool isIndex   = symType == "index"  or symType == "economic"
bool isFx      = symType == "forex"  or symType == "cfd"
bool isCrypto  = symType == "crypto"

assetClassTxt = isEquity  ? "Equity"  :
               isFutures ? "Futures" :
               isIndex   ? "Index"   :
               isFx      ? "FX/CFD"  :
               isCrypto  ? "Crypto"  : "Generic"

int assetClassCode = isEquity ? 1 : isFutures ? 2 : isIndex ? 3 : isFx ? 4 : isCrypto ? 5 : 0

bool volExists       = not na(volume) and volume > 0
var int volPresentCnt = 0
var int volTotalCnt   = 0
if barstate.isconfirmed
    volTotalCnt   += 1
    volPresentCnt += volExists ? 1 : 0
float volAvailRatio = volTotalCnt > 0 ? volPresentCnt / float(volTotalCnt) : 0.0
bool  volReliable   = volAvailRatio >= 0.80

bool barRangeValid = high > low and not na(high) and not na(low)
bool effVolGate = vol_gate and volReliable

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 3 — CORE ADAPTIVE VOLATILITY STOP ENGINE
// ════════════════════════════════════════════════════════════════════════════

adaptive_vstop(src, f_len, s_len, er_len, er_dyn_len, er_offset,
               base_atr_len, base_mult, mode) =>

    net_move = math.abs(src - src[er_len])
    path     = math.sum(math.abs(src - src[1]), er_len)
    er_raw   = path != 0.0 ? net_move / path : 0.0
    er_sm    = ta.ema(er_raw, 5)

    fa        = 2.0 / (f_len + 1)
    sa        = 2.0 / (s_len + 1)
    adapt_alpha = math.pow(er_sm * (fa - sa) + sa, 2)

    er_lo  = ta.lowest(er_sm,  er_dyn_len)
    er_hi  = ta.highest(er_sm, er_dyn_len)
    er_rng = math.max(er_hi - er_lo, 1e-10)
    warmed = bar_index >= er_dyn_len
    er_norm = warmed ? (er_sm - er_lo) / er_rng : 0.5

    er_mid     = ta.sma(er_norm, er_dyn_len)
    er_std     = ta.stdev(er_norm, er_dyn_len)
    eff_offset = math.max(er_offset, er_std * 0.5)
    th_hi      = math.min(er_mid + eff_offset, 1.0)
    th_lo      = math.max(er_mid - eff_offset, 0.0)

    len_min  = math.max(2, f_len - 2)
    len_max  = s_len + 10
    eff_len_r = 1.0 / math.max(adapt_alpha, 1e-10)
    eff_len_f = math.max(float(len_min), math.min(float(len_max), eff_len_r))

    m_hi       = 1.6
    m_mid      = 2.0
    m_lo       = 2.6
    interp_hi  = m_hi  + (m_mid - m_hi)  * (th_hi - er_norm) / math.max(th_hi  - er_mid, 1e-10)
    interp_lo  = m_mid + (m_lo  - m_mid) * (er_mid - er_norm) / math.max(er_mid - th_lo,  1e-10)
    atr_mult_a = er_norm >= th_hi ? m_hi :
                 er_norm <= th_lo ? m_lo :
                 er_norm > er_mid ? interp_hi : interp_lo

    use_len  = (mode == "Length Only"     or mode == "Both") ? eff_len_f        : float(base_atr_len)
    use_mult = (mode == "Multiplier Only" or mode == "Both") ? atr_mult_a       : base_mult
    use_len  := math.max(float(len_min), use_len)
    use_mult := math.max(1.0, use_mult)

    tr_val   = ta.tr(true)
    atr_dyn  = f_rma(tr_val, use_len)

    // ── Path-Dependent Volatility scaler (v1.4) ──────────────────────────
    // Lightweight path-dependent reading of the recent return PATH (return-path vol).
    // Reads only inputs + built-ins, so it is safe inside request.security.
    // Three path features, combined into one multiplier on the stop distance:
    //   • activity   = sqrt(fast / slow EWMA of squared returns)  (clustering)
    //   • leverage   = recent net DOWN drift (ATR-normalised) widens the stop
    //   • convexity  = recent net   UP drift (ATR-normalised) widens it a touch
    ret_pd   = src - src[1]
    r2_pd    = ret_pd * ret_pd
    pv_fast  = ta.ema(r2_pd, pdv_fast)
    pv_slow  = ta.ema(r2_pd, pdv_slow)
    pv_activ = pv_slow > 0.0 ? math.sqrt(pv_fast / pv_slow) : 1.0
    pv_drift = ta.ema(ret_pd, pdv_fast)
    pv_dn    = atr_dyn > 0.0 ? pv_drift / atr_dyn : 0.0
    pv_lever = pv_dn < 0.0 ? -pv_dn * pdv_lev : 0.0
    pv_convx = pv_dn > 0.0 ?  pv_dn * pdv_cvx : 0.0
    pv_raw   = pv_activ + pv_lever + pv_convx
    pv_clamp = math.max(pdv_lo, math.min(pdv_hi, pv_raw))
    pdvAdj   = pdv_on ? (1.0 - pdv_w) + pdv_w * pv_clamp : 1.0

    atr_dist = use_mult * atr_dyn * pdvAdj

    var float vstop   = na
    var bool  uptrend = true

    if uptrend
        vstop := math.max(nz(vstop, src - atr_dist), src - atr_dist)
    else
        vstop := math.min(nz(vstop, src + atr_dist), src + atr_dist)

    if uptrend and src < vstop
        uptrend := false
        vstop   := src + atr_dist
    else if not uptrend and src > vstop
        uptrend := true
        vstop   := src - atr_dist

    [vstop, uptrend, atr_dist, er_norm, use_len, use_mult, pdvAdj]

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 4 — MULTI-TIMEFRAME CALCULATION
// ════════════════════════════════════════════════════════════════════════════

[vstop1, is_up1, adist1, er1, elen1, emul1, pdv1] =
     adaptive_vstop(src_price, fast_len, slow_len,
          er_len_scaled, er_dyn_scaled, er_band_offset,
          atr_len, atr_mult, adaptive_mode)

[vstop2, is_up2, adist2, er2, elen2, emul2, pdv2] =
     request.security(syminfo.tickerid, tf2_str,
          adaptive_vstop(src_price, fast_len, slow_len,
               er_len_scaled, er_dyn_scaled, er_band_offset,
               atr_len, atr_mult, adaptive_mode),
          lookahead = barmerge.lookahead_off)

[vstop3, is_up3, adist3, er3, elen3, emul3, pdv3] =
     request.security(syminfo.tickerid, tf3_str,
          adaptive_vstop(src_price, fast_len, slow_len,
               er_len_scaled, er_dyn_scaled, er_band_offset,
               atr_len, atr_mult, adaptive_mode),
          lookahead = barmerge.lookahead_off)

[vstop4, is_up4, adist4, er4, elen4, emul4, pdv4] =
     request.security(syminfo.tickerid, tf4_str,
          adaptive_vstop(src_price, fast_len, slow_len,
               er_len_scaled, er_dyn_scaled, er_band_offset,
               atr_len, atr_mult, adaptive_mode),
          lookahead = barmerge.lookahead_off)

// ── HTF feed health check ────────────────────────────────────────────────
bool htf2Healthy = not na(vstop2)
bool htf3Healthy = not na(vstop3)
bool htf4Healthy = not na(vstop4)
bool htfAllHealthy = htf2Healthy and htf3Healthy and htf4Healthy

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 5 — BIAS SCORE, REGIME, CONVERGENCE
// ════════════════════════════════════════════════════════════════════════════

score = (is_up1 ? 1 : -1) + (is_up2 ? 2 : -2) + (is_up3 ? 3 : -3) + (is_up4 ? 4 : -4)

prev_score = ((is_up1[mom_len_scaled] ? 1 : -1) +
              (is_up2[mom_len_scaled] ? 2 : -2) +
              (is_up3[mom_len_scaled] ? 3 : -3) +
              (is_up4[mom_len_scaled] ? 4 : -4))
momentum   = score - prev_score

is_strong_trend = math.abs(score) >= 7
is_trending     = math.abs(score) >= 4
is_choppy       = math.abs(score) <= 2

vstop_mean  = (vstop1 + vstop2 + vstop3 + vstop4) / 4.0
vstop_std   = math.sqrt(
     ((vstop1 - vstop_mean) * (vstop1 - vstop_mean) +
      (vstop2 - vstop_mean) * (vstop2 - vstop_mean) +
      (vstop3 - vstop_mean) * (vstop3 - vstop_mean) +
      (vstop4 - vstop_mean) * (vstop4 - vstop_mean)) / 4.0)

ref_atr     = math.max(adist1, 1e-10)
convergence = math.max(0.0, 1.0 - vstop_std / ref_atr)

conv_txt = convergence >= 0.75 ? "HIGH ●●●" : convergence >= 0.45 ? "MED ●●○" : "LOW ●○○"
conv_col = convergence >= 0.75 ? color.new(C_GREEN, 0) :
           convergence >= 0.45 ? color.new(C_AMBER, 0) :
                                  color.new(is_light_chart ? #d35400 : #ff7043, 0)

sc = score_color(score)

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 5b — VOLATILITY-CLUSTER DETECTOR
// ════════════════════════════════════════════════════════════════════════════

vcl_ret_safe = math.log(close / math.max(nz(close[1], close), 0.0001))
vcl_rv_short = ta.stdev(vcl_ret_safe, 20)
vcl_shock_now = not na(vcl_rv_short) and vcl_rv_short > 0 and math.abs(vcl_ret_safe) > vcl_shock_sig * vcl_rv_short

vcl_baseline = ta.sma(vcl_shock_now ? 1.0 : 0.0, 100)

var float vcl_lambda = 0.0
if barstate.isconfirmed
    vcl_lambda := vcl_lambda * math.exp(-vcl_beta) + (vcl_shock_now ? vcl_alpha : 0.0)

float vcl_ratio = vcl_baseline > 0 ? vcl_lambda / vcl_baseline : 0.0
bool  vcl_warning = vcl_enable and vcl_ratio > vcl_warn_mult

float vcl_lift = 0.0
if vcl_enable and vcl_warning and vcl_lift_span > 0
    float excess = vcl_ratio - vcl_warn_mult
    float frac   = math.min(1.0, excess / vcl_lift_span)
    vcl_lift  := vcl_max_lift * frac

int vcl_severity = 0
float vcl_lift_frac = 0.0
if vcl_warning and vcl_max_lift > 0
    vcl_lift_frac := vcl_lift / vcl_max_lift
else if vcl_warning and vcl_max_lift == 0
    vcl_lift_frac := math.min(1.0, (vcl_ratio - vcl_warn_mult) / math.max(vcl_lift_span, 0.5))
if vcl_warning
    if vcl_lift_frac >= 0.66
        vcl_severity := 3
    else if vcl_lift_frac >= 0.33
        vcl_severity := 2
    else
        vcl_severity := 1

vcl_badge = vcl_severity == 0 ? "" :
               vcl_severity == 1 ? "vol+" :
               vcl_severity == 2 ? "vol++" : "vol+++"

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 5c — DATA HEALTH AGGREGATE
// ════════════════════════════════════════════════════════════════════════════

bool expectVolume = isEquity or isFutures or isCrypto
int healthCode = 0
if expectVolume and not volReliable
    healthCode := 2
else if not htfAllHealthy or vcl_warning or not barRangeValid
    healthCode := 1

healthShort = healthCode == 0 ? "OK" : healthCode == 1 ? (vcl_warning ? ("DGR " + vcl_badge) : "DGR") : "CRIT"

healthCol = healthCode == 0 ? color.new(C_GREEN, 0) : healthCode == 1 ? color.new(C_AMBER, 0) : color.new(C_RED, 0)

healthDetail = (volReliable ? "Vol ok " : "Vol off ") + (htf2Healthy ? "3× ok " : "3× stale ") + (htf3Healthy ? "5× ok " : "5× stale ") + (htf4Healthy ? "15× ok " : "15× stale ") + (vcl_enable ? (vcl_warning ? ("Cluster " + vcl_badge + " (lift " + str.tostring(vcl_lift, "#.#") + ") ") : "Cluster ok ") : "Cluster off ") + "[" + assetClassTxt + "]"

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 6 — BAND GEOMETRY AND FILL COLORS
// ════════════════════════════════════════════════════════════════════════════

b1_top = math.max(vstop1, vstop2)
b1_bot = math.min(vstop1, vstop2)
b2_top = math.max(vstop2, vstop3)
b2_bot = math.min(vstop2, vstop3)
b3_top = math.max(vstop3, vstop4)
b3_bot = math.min(vstop3, vstop4)

b1_bull = is_up1 and  is_up2
b1_bear = not is_up1 and not is_up2
b2_bull = is_up2 and  is_up3
b2_bear = not is_up2 and not is_up3
b3_bull = is_up3 and  is_up4
b3_bear = not is_up3 and not is_up4

// ── Tiered green/red band palette (v1.3.1) ──────────────────────────────────
// Hue encodes DIRECTION (green = bull, red = bear); depth encodes the TIMEFRAME
// TIER (Chart = lightest, 5×/15× = deepest) so all three nested bands stay
// distinguishable when stacked. Theme-aware so every tier remains visible on a
// dark OR light background.
BULL_T1 = is_light_chart ? #43a047 : #69f0ae   // Chart / 3×  (lightest)
BULL_T2 = is_light_chart ? #2e8b48 : #00e676   // 3× / 5×     (mid)
BULL_T3 = is_light_chart ? #1b5e20 : #00a152   // 5× / 15×    (deepest)
BEAR_T1 = is_light_chart ? #e53935 : #ff8a80   // Chart / 3×  (lightest)
BEAR_T2 = is_light_chart ? #c62828 : #ff1744   // 3× / 5×     (mid)
BEAR_T3 = is_light_chart ? #8e1515 : #d50000   // 5× / 15×    (deepest)
NEUT_BD = is_light_chart ? #90a4ae : #607d8b   // mixed band (stops disagree)

// Translucent fills wash out on light backgrounds, so make them more opaque
// there (lower transparency) and leave them lighter on dark backgrounds.
theme_tp = is_light_chart ? 8 : 0
mix_pen = 12
t1e = math.max(0, (b1_bull or b1_bear ? t1 : math.min(t1 + mix_pen, 95)) - theme_tp)
t2e = math.max(0, (b2_bull or b2_bear ? t2 : math.min(t2 + mix_pen, 95)) - theme_tp)
t3e = math.max(0, (b3_bull or b3_bear ? t3 : math.min(t3 + mix_pen, 95)) - theme_tp)

f1 = b1_bull ? color.new(BULL_T1, t1e) : b1_bear ? color.new(BEAR_T1, t1e) : color.new(NEUT_BD, t1e)
f2 = b2_bull ? color.new(BULL_T2, t2e) : b2_bear ? color.new(BEAR_T2, t2e) : color.new(NEUT_BD, t2e)
f3 = b3_bull ? color.new(BULL_T3, t3e) : b3_bear ? color.new(BEAR_T3, t3e) : color.new(NEUT_BD, t3e)

br1 = b1_bull ? color.new(BULL_T1, math.max(t1e - 35, 0)) :
      b1_bear ? color.new(BEAR_T1, math.max(t1e - 35, 0)) :
               color.new(NEUT_BD, math.max(t1e - 35, 0))
br2 = b2_bull ? color.new(BULL_T2, math.max(t2e - 35, 0)) :
      b2_bear ? color.new(BEAR_T2, math.max(t2e - 35, 0)) :
               color.new(NEUT_BD, math.max(t2e - 35, 0))
br3 = b3_bull ? color.new(BULL_T3, math.max(t3e - 35, 0)) :
      b3_bear ? color.new(BEAR_T3, math.max(t3e - 35, 0)) :
               color.new(NEUT_BD, math.max(t3e - 35, 0))

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 7 — VISUAL PLOTS
// ════════════════════════════════════════════════════════════════════════════

p1t = plot(show_b1 ? b1_top : na, "Band1 Top", color = br1, linewidth = 1)
p1b = plot(show_b1 ? b1_bot : na, "Band1 Bot", color = br1, linewidth = 1)
fill(p1t, p1b, color = show_b1 ? f1 : na, title = "Chart/3× Fill")

p2t = plot(show_b2 ? b2_top : na, "Band2 Top", color = br2, linewidth = 1)
p2b = plot(show_b2 ? b2_bot : na, "Band2 Bot", color = br2, linewidth = 1)
fill(p2t, p2b, color = show_b2 ? f2 : na, title = "3×/5× Fill")

p3t = plot(show_b3 ? b3_top : na, "Band3 Top", color = br3, linewidth = 1)
p3b = plot(show_b3 ? b3_bot : na, "Band3 Bot", color = br3, linewidth = 1)
fill(p3t, p3b, color = show_b3 ? f3 : na, title = "5×/15× Fill")

c1 = is_up1 ? color.new(BULL_T1, 45) : color.new(BEAR_T1, 45)
c2 = is_up2 ? color.new(BULL_T2, 25) : color.new(BEAR_T2, 25)
plot(show_v1_line ? vstop1 : na, "Chart VStop",  color = c1, linewidth = 1, style = plot.style_circles)
plot(show_v2_line ? vstop2 : na, "3× VStop",     color = c2, linewidth = 1, style = plot.style_stepline)

c4 = is_up4 ? color.new(BULL_T3, 0)  : color.new(BEAR_T3, 0)
plot(vstop4, "15× VStop", color = c4, linewidth = 4)

// Background bias shading — transparency adapts so the tint stays visible on
// both dark and light chart backgrounds.
bg_tp_strong = is_light_chart ? 90 : 96
bg_tp_chop   = is_light_chart ? 92 : 98
bg_color =
     show_bg and is_strong_trend and score > 0 ? color.new(C_GREEN,   bg_tp_strong) :
     show_bg and is_strong_trend and score < 0 ? color.new(C_RED,     bg_tp_strong) :
     show_bg and is_choppy                     ? color.new(C_NEUTRAL, bg_tp_chop)   : na
bgcolor(bg_color, title = "Bias Background")

if show_edge_lbl and barstate.islast
    lbl4c = is_up4 ? BULL_T3 : BEAR_T3
    label.new(bar_index + 1, vstop4,
         (is_up4 ? "▲ 15×  " : "▼ 15×  ") + str.tostring(math.round(vstop4, 2)),
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         color     = color.new(lbl4c, 10),
         textcolor = color.white,
         size      = size.small,
         style     = label.style_label_left)

    lbl2c = is_up2 ? BULL_T2 : BEAR_T2
    label.new(bar_index + 1, vstop2,
         (is_up2 ? "▲ 3×  " : "▼ 3×  ") + str.tostring(math.round(vstop2, 2)),
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         color     = color.new(lbl2c, 20),
         textcolor = color.black,
         size      = size.tiny,
         style     = label.style_label_left)

if show_stop_dist and barstate.islast
    dist_pts = math.abs(close - vstop2)
    dist_pct = dist_pts / close * 100
    dist_txt = "Stop: " + str.tostring(math.round(dist_pts, 2)) +
               "  (" + str.tostring(math.round(dist_pct, 2)) + "%)"
    dist_y   = is_up2 ? vstop2 - adist2 * 0.4 : vstop2 + adist2 * 0.4
    label.new(bar_index, dist_y, dist_txt,
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         color     = color.new(#0d1b2a, 70),
         textcolor = #c9d1d9,
         size      = size.tiny,
         style     = label.style_label_left)

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 8 — EARLY BREACH DETECTION
// ════════════════════════════════════════════════════════════════════════════

breach_up1 = early_breach and     is_up1 and close < vstop1
breach_dn1 = early_breach and not is_up1 and close > vstop1
breach_up2 = early_breach and     is_up2 and close < vstop2
breach_dn2 = early_breach and not is_up2 and close > vstop2

var bool limbo1 = false
var bool limbo2 = false

if breach_up1 or breach_dn1
    limbo1 := true
if (is_up1 and close > vstop1) or (not is_up1 and close < vstop1)
    limbo1 := false

if breach_up2 or breach_dn2
    limbo2 := true
if (is_up2 and close > vstop2) or (not is_up2 and close < vstop2)
    limbo2 := false

active_limbo = limbo_tf == "Signal TF (3×)" ? limbo2 : limbo1
barcolor(show_limbo and active_limbo ? color.new(#ff9800, 60) : na, title = "Early Breach Bar")

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 9 — SIGNAL CONDITIONS
// ════════════════════════════════════════════════════════════════════════════

vol_sma   = ta.sma(volume, vol_len)

choppy_floor = filter_choppy ? 2.0 : 0.0
eff_floor    = math.min(4.0, choppy_floor + vcl_lift)
trade_ok     = math.abs(score) > eff_floor

vol_ok    = not effVolGate or (not na(volume) and volume > vol_sma)

htf_bull_lock = htf_bias_lock and not is_up4
htf_bear_lock = htf_bias_lock and is_up4

f_atr14 = ta.atr(14)
flip_strict      = flip_persist_mode == "Strict (2-bar hold)"
flip_adaptive    = flip_persist_mode == "Adaptive (close beyond ½ ATR)"
flip_persist_on  = flip_strict or flip_adaptive

daily_anchor_change = ta.change(time("D"))
chart_is_intraday   = tf_secs < 86400
new_session_started = chart_is_intraday and daily_anchor_change != 0
var int bars_into_session = 99
bars_into_session := new_session_started ? 1 : bars_into_session + 1
session_block = session_filter_on and chart_is_intraday and bars_into_session <= session_filter_bars

buy_raw  = show_signals and trade_ok and     is_up2 and not is_up2[1]
sell_raw = show_signals and trade_ok and not is_up2 and     is_up2[1]
buy_sig  = buy_raw  and not htf_bull_lock
sell_sig = sell_raw and not htf_bear_lock

tbuy_raw_now   = show_signals and trade_ok and     is_up3 and not is_up3[1]
tsell_raw_now  = show_signals and trade_ok and not is_up3 and     is_up3[1]

tbuy_strict  = flip_strict  and is_up3 and is_up3[1] and not is_up3[2] and trade_ok
tsell_strict = flip_strict  and not is_up3 and not is_up3[1] and is_up3[2] and trade_ok
tbuy_adapt   = flip_adaptive and tbuy_raw_now  and close > vstop3[1] + flip_persist_atr_mult * f_atr14
tsell_adapt  = flip_adaptive and tsell_raw_now and close < vstop3[1] - flip_persist_atr_mult * f_atr14

trend_buy  = (flip_persist_on ? (tbuy_strict  or tbuy_adapt)  : tbuy_raw_now)  and not session_block
trend_sell = (flip_persist_on ? (tsell_strict or tsell_adapt) : tsell_raw_now) and not session_block
tbuy_raw   = trend_buy
tsell_raw  = trend_sell

mbuy_raw_now  = show_signals and     is_up4 and not is_up4[1]
msell_raw_now = show_signals and not is_up4 and     is_up4[1]

mbuy_strict  = flip_strict  and is_up4 and is_up4[1] and not is_up4[2]
msell_strict = flip_strict  and not is_up4 and not is_up4[1] and is_up4[2]
mbuy_adapt   = flip_adaptive and mbuy_raw_now  and close > vstop4[1] + flip_persist_atr_mult * f_atr14
msell_adapt  = flip_adaptive and msell_raw_now and close < vstop4[1] - flip_persist_atr_mult * f_atr14

major_buy  = (flip_persist_on ? (mbuy_strict  or mbuy_adapt)  : mbuy_raw_now)  and not session_block
major_sell = (flip_persist_on ? (msell_strict or msell_adapt) : msell_raw_now) and not session_block

pb_buy_raw  = show_signals and trade_ok and vol_ok and b1_bull and close > b1_bot and
              (pb_confirm ? close[1] > b1_bot[1] : true) and
              not (close[2] > b1_bot[2]) and not buy_sig
pb_sell_raw = show_signals and trade_ok and vol_ok and b1_bear and close < b1_top and
              (pb_confirm ? close[1] < b1_top[1] : true) and
              not (close[2] < b1_top[2]) and not sell_sig
pb_buy      = pb_buy_raw  and not htf_bull_lock
pb_sell     = pb_sell_raw and not htf_bear_lock

tpb_buy_raw  = show_signals and trade_ok and vol_ok and b2_bull and close > b2_bot and
               (pb_confirm ? close[1] > b2_bot[1] : true) and
               not (close[2] > b2_bot[2]) and not trend_buy
tpb_sell_raw = show_signals and trade_ok and vol_ok and b2_bear and close < b2_top and
               (pb_confirm ? close[1] < b2_top[1] : true) and
               not (close[2] < b2_top[2]) and not trend_sell
tpb_buy      = tpb_buy_raw
tpb_sell     = tpb_sell_raw

mpb_buy_raw  = show_signals and trade_ok and b3_bull and close > b3_bot and
               (pb_confirm ? close[1] > b3_bot[1] : true) and
               not (close[2] > b3_bot[2]) and not major_buy
mpb_sell_raw = show_signals and trade_ok and b3_bear and close < b3_top and
               (pb_confirm ? close[1] < b3_top[1] : true) and
               not (close[2] < b3_top[2]) and not major_sell
mpb_buy      = mpb_buy_raw
mpb_sell     = mpb_sell_raw

all_bull = show_signals and trade_ok and
           is_up2 and is_up3 and is_up4 and
           not (is_up2[1] and is_up3[1] and is_up4[1])

all_bear = show_signals and trade_ok and
           not is_up2 and not is_up3 and not is_up4 and
           (is_up2[1] or is_up3[1] or is_up4[1])

has_major   = major_buy   or major_sell
has_trend   = trend_buy   or trend_sell
has_primary = buy_sig     or sell_sig

pb_buy_f   = signal_priority ? pb_buy   and not has_major and not has_trend and not has_primary : pb_buy
pb_sell_f  = signal_priority ? pb_sell  and not has_major and not has_trend and not has_primary : pb_sell
tpb_buy_f  = signal_priority ? tpb_buy  and not has_major and not has_trend : tpb_buy
tpb_sell_f = signal_priority ? tpb_sell and not has_major and not has_trend : tpb_sell
mpb_buy_f  = signal_priority ? mpb_buy  and not has_major : mpb_buy
mpb_sell_f = signal_priority ? mpb_sell and not has_major : mpb_sell
buy_f      = signal_priority ? buy_sig  and not has_major and not has_trend : buy_sig
sell_f     = signal_priority ? sell_sig and not has_major and not has_trend : sell_sig

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 10 — SIGNAL PLOTS
// ════════════════════════════════════════════════════════════════════════════

sc_bull    = color.new(sc, 0)
sc_bear    = color.new(sc, 0)
sc_bull_pb = color.new(sc, 35)
sc_bear_pb = color.new(sc, 35)

plotshape(major_buy,  "Major Buy",  shape.labelup,   location.belowbar, sc_bull, size = size.small)
plotshape(major_sell, "Major Sell", shape.labeldown,  location.abovebar, sc_bear, size = size.small)

plotshape(trend_buy,  "Trend Buy",  shape.triangleup,   location.belowbar, sc_bull, size = size.tiny)
plotshape(trend_sell, "Trend Sell", shape.triangledown,  location.abovebar, sc_bear, size = size.tiny)

plotshape(buy_f,  "Scalp Buy",  shape.triangleup,   location.belowbar, sc_bull, size = size.auto)
plotshape(sell_f, "Scalp Sell", shape.triangledown,  location.abovebar, sc_bear, size = size.auto)

plotshape(show_pullback_signals and pb_buy_f,   "PB Buy Scalp",   shape.circle, location.belowbar, color.new(BULL_T1, 40), size = size.auto)
plotshape(show_pullback_signals and pb_sell_f,  "PB Sell Scalp",  shape.circle, location.abovebar, color.new(BEAR_T1, 40), size = size.auto)
plotshape(show_pullback_signals and tpb_buy_f,  "PB Buy Trend",   shape.circle, location.belowbar, color.new(BULL_T2, 40), size = size.auto)
plotshape(show_pullback_signals and tpb_sell_f, "PB Sell Trend",  shape.circle, location.abovebar, color.new(BEAR_T2, 40), size = size.auto)
plotshape(show_pullback_signals and mpb_buy_f,  "PB Buy Major",   shape.circle, location.belowbar, color.new(BULL_T3, 40), size = size.auto)
plotshape(show_pullback_signals and mpb_sell_f, "PB Sell Major",  shape.circle, location.abovebar, color.new(BEAR_T3, 40), size = size.auto)

plotshape(show_all_htf_cross and all_bull, "All HTF Bull", shape.cross, location.belowbar, color.new(#ffd600, 0), size = size.small)
plotshape(show_all_htf_cross and all_bear, "All HTF Bear", shape.cross, location.abovebar, color.new(#ffd600, 0), size = size.small)

// ── Conviction-strength labels on Trend/Major signals (drawing objects) ───
labels_off       = show_conviction_labels == "Off"
labels_minimal   = show_conviction_labels == "Minimal (no text)"
labels_verbose   = show_conviction_labels == "Verbose (always show score)"
labels_auto      = show_conviction_labels == "Auto (adapts to TF)"

labels_hidden_tf = labels_auto and tf_secs > 0 and tf_secs <= 120
lbl_size_major   = labels_auto and tf_secs <= 300 ? size.tiny : size.small
lbl_size_trend   = labels_auto and tf_secs <= 300 ? size.tiny : size.tiny
score_is_max     = math.abs(score) >= 10
score_str_compact = (score > 0 ? "+" : "") + str.tostring(score)

var int last_mbuy_lbl_bar  = -9999
var int last_msell_lbl_bar = -9999
var int last_tbuy_lbl_bar  = -9999
var int last_tsell_lbl_bar = -9999

mbuy_cool_ok  = bar_index - last_mbuy_lbl_bar  > conviction_label_cooldown
msell_cool_ok = bar_index - last_msell_lbl_bar > conviction_label_cooldown
tbuy_cool_ok  = bar_index - last_tbuy_lbl_bar  > conviction_label_cooldown
tsell_cool_ok = bar_index - last_tsell_lbl_bar > conviction_label_cooldown

major_fire = (major_buy or major_sell) and not labels_off and not labels_hidden_tf
trend_fire = (trend_buy or trend_sell) and not labels_off and not labels_hidden_tf and not labels_minimal

if major_fire and ((major_buy and mbuy_cool_ok) or (major_sell and msell_cool_ok))
    mlbl_y     = major_buy ? low  - adist2 * 1.2 : high + adist2 * 1.2
    mlbl_color = major_buy ? color.new(BULL_T3, 0) : color.new(BEAR_T3, 0)
    mlbl_score_part = (labels_verbose or not score_is_max) ? "  " + score_str_compact : ""
    mlbl_txt   = labels_minimal ? (major_buy ? "▲" : "▼") :
                 ((major_buy ? "▲ MAJOR" : "▼ MAJOR") + mlbl_score_part)
    label.new(bar_index, mlbl_y, mlbl_txt,
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         color     = mlbl_color,
         textcolor = color.white,
         style     = major_buy ? label.style_label_up : label.style_label_down,
         size      = lbl_size_major)
    if major_buy
        last_mbuy_lbl_bar := bar_index
    if major_sell
        last_msell_lbl_bar := bar_index

if trend_fire and ((trend_buy and tbuy_cool_ok) or (trend_sell and tsell_cool_ok))
    tlbl_y     = trend_buy ? low  - adist2 * 0.6 : high + adist2 * 0.6
    tlbl_color = trend_buy ? color.new(#00a152, 0) : color.new(#d32f2f, 0)
    tlbl_score_part = (labels_verbose or not score_is_max) ? " " + score_str_compact : ""
    tlbl_txt   = (trend_buy ? "▲" : "▼") + tlbl_score_part
    label.new(bar_index, tlbl_y, tlbl_txt,
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         color     = tlbl_color,
         textcolor = color.white,
         style     = trend_buy ? label.style_label_up : label.style_label_down,
         size      = lbl_size_trend)
    if trend_buy
        last_tbuy_lbl_bar := bar_index
    if trend_sell
        last_tsell_lbl_bar := bar_index

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 10b — CALIBRATION TRACKER
// ════════════════════════════════════════════════════════════════════════════

var int[]   cal_total   = array.new_int(2, 0)
var int[]   cal_hits    = array.new_int(2, 0)
var int[]   pend_bar    = array.new_int(0)
var float[] pend_price  = array.new_float(0)
var float[] pend_atr    = array.new_float(0)
var int[]   pend_dir    = array.new_int(0)
var int[]   pend_bin    = array.new_int(0)

cal_atr_ref = ta.atr(14)

if cal_enable and barstate.isconfirmed
    if trend_buy
        array.push(pend_bar,   bar_index)
        array.push(pend_price, close)
        array.push(pend_atr,   cal_atr_ref)
        array.push(pend_dir,   1)
        array.push(pend_bin,   0)
    if trend_sell
        array.push(pend_bar,   bar_index)
        array.push(pend_price, close)
        array.push(pend_atr,   cal_atr_ref)
        array.push(pend_dir,   -1)
        array.push(pend_bin,   0)
    if major_buy
        array.push(pend_bar,   bar_index)
        array.push(pend_price, close)
        array.push(pend_atr,   cal_atr_ref)
        array.push(pend_dir,   1)
        array.push(pend_bin,   1)
    if major_sell
        array.push(pend_bar,   bar_index)
        array.push(pend_price, close)
        array.push(pend_atr,   cal_atr_ref)
        array.push(pend_dir,   -1)
        array.push(pend_bin,   1)

    if array.size(pend_bar) > 0
        int idx = 0
        while idx < array.size(pend_bar)
            int pb = array.get(pend_bar, idx)
            if bar_index - pb >= cal_horizon
                float p0 = array.get(pend_price, idx)
                float a0 = array.get(pend_atr,   idx)
                int   dr = array.get(pend_dir,   idx)
                int   bn = array.get(pend_bin,   idx)
                float move = close - p0
                bool hit = dr == 1 ? move >= cal_move_atr * a0 : move <= -cal_move_atr * a0
                array.set(cal_total, bn, array.get(cal_total, bn) + 1)
                if hit
                    array.set(cal_hits, bn, array.get(cal_hits, bn) + 1)
                array.remove(pend_bar,   idx)
                array.remove(pend_price, idx)
                array.remove(pend_atr,   idx)
                array.remove(pend_dir,   idx)
                array.remove(pend_bin,   idx)
            else
                idx := idx + 1

    while array.size(pend_bar) > 200
        array.shift(pend_bar)
        array.shift(pend_price)
        array.shift(pend_atr)
        array.shift(pend_dir)
        array.shift(pend_bin)

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 11 — UNIFIED VERTICAL DASHBOARD (redesigned v1.3)
//
//  One adaptive vertical table replaces the former Dashboard + HTF Ribbon +
//  Legend. Sections toggle via show_htf_rows / show_health_row / show_legend
//  and compact_dash. All colors come from the theme block in Section 2 so the
//  panel stays legible on any chart background.
// ════════════════════════════════════════════════════════════════════════════

dec_col   = score_color(score)
dec_txt   = score_label(score)
act_txt   = score_action(score)
score_str = (score > 0 ? "+" : "") + str.tostring(score) + " / ±10"

mom_txt = momentum > 2  ? "↑↑ Surging"   :
          momentum > 0  ? "↑ Building"   :
          momentum < -2 ? "↓↓ Collapsing" :
          momentum < 0  ? "↓ Fading"      : "→ Stable"
mom_col = momentum > 0 ? color.new(C_GREEN, 0) :
          momentum < 0 ? color.new(C_RED, 0)   :
                          color.new(C_NEUTRAL, 0)

regime_txt = is_strong_trend and score > 0 ? "TRENDING ▲"  :
             is_strong_trend and score < 0 ? "TRENDING ▼"  :
             is_trending                   ? "DIRECTIONAL" :
             is_choppy                     ? "CHOPPY ⚠"    : "TRANSITION"
regime_col = is_strong_trend and score > 0 ? color.new(C_GREEN, 0)   :
             is_strong_trend and score < 0 ? color.new(C_RED, 0)     :
             is_trending                   ? color.new(C_GREEN2, 0)  :
             is_choppy                     ? color.new(C_AMBER, 0)   :
                                              color.new(C_NEUTRAL, 0)

er1_pct   = str.tostring(math.round(er1 * 100)) + "%"
elen1_str = str.tostring(int(elen1))
emul1_str = "×" + str.tostring(math.round(emul1, 2))

dist_pts2 = math.abs(close - vstop2)
dist_pct2 = math.round(dist_pts2 / close * 100, 2)
dist_str  = str.tostring(math.round(dist_pts2, 2)) + "  (" + str.tostring(dist_pct2) + "%)"

// Path-Dependent Vol readout (chart tier factor, self-interpreting)
pdv_state = not pdv_on ? "off" : pdv1 >= 1.08 ? "expanding" : pdv1 <= 0.94 ? "calming" : "neutral"
pdv_str   = not pdv_on ? "off (=v1.3)" : "×" + str.tostring(pdv1, "#.00") + "  " + pdv_state
pdv_col   = not pdv_on ? C_NEUTRAL : pdv1 >= 1.08 ? C_AMBER : pdv1 <= 0.94 ? C_ACCENT : C_NEUTRAL

if show_dash and barstate.islast
    bool sec_tf     = show_htf_rows
    bool sec_health = show_health_row
    bool sec_legend = show_legend
    int  detail_n   = compact_dash ? 0 : 3
    int  nrows = 1 + (sec_tf ? 5 : 0) + 5 + detail_n + (sec_health ? 1 : 0) + (sec_legend ? 7 : 0)

    var table d = table.new(
         tbl_pos(dash_pos), 2, nrows,
         bgcolor      = THEME_PANEL_BG,
         border_color = THEME_BORDER,
         border_width = 1,
         frame_color  = THEME_FRAME,
         frame_width  = 1)

    int r = 0

    // ── Header ──
    table.cell(d, 0, r, "AVS MTF", text_color = THEME_HEADER_TX, text_size = size.small,
         bgcolor = THEME_HEADER_BG, text_halign = text.align_left)
    table.cell(d, 1, r, score_str, text_color = dec_col, text_size = size.small,
         bgcolor = THEME_HEADER_BG, text_halign = text.align_right)
    r += 1

    // ── 4-tier timeframe block (acts as the alignment ribbon) ──
    if sec_tf
        table.cell(d, 0, r, "Chart", text_color = THEME_LABEL_TX, text_size = size.tiny,
             bgcolor = f_rowbg(r), text_halign = text.align_left)
        table.cell(d, 1, r, is_up1 ? "▲ BULL" : "▼ BEAR", text_color = color.white,
             text_size = size.tiny, bgcolor = is_up1 ? THEME_BULL_BG : THEME_BEAR_BG, text_halign = text.align_center)
        r += 1
        table.cell(d, 0, r, "3×  Scalp", text_color = THEME_LABEL_TX, text_size = size.tiny,
             bgcolor = f_rowbg(r), text_halign = text.align_left)
        table.cell(d, 1, r, is_up2 ? "▲ BULL" : "▼ BEAR", text_color = color.white,
             text_size = size.tiny, bgcolor = is_up2 ? THEME_BULL_BG : THEME_BEAR_BG, text_halign = text.align_center)
        r += 1
        table.cell(d, 0, r, "5×  Trend", text_color = THEME_LABEL_TX, text_size = size.tiny,
             bgcolor = f_rowbg(r), text_halign = text.align_left)
        table.cell(d, 1, r, is_up3 ? "▲ BULL" : "▼ BEAR", text_color = color.white,
             text_size = size.tiny, bgcolor = is_up3 ? THEME_BULL_BG : THEME_BEAR_BG, text_halign = text.align_center)
        r += 1
        table.cell(d, 0, r, "15× Major", text_color = THEME_LABEL_TX, text_size = size.tiny,
             bgcolor = f_rowbg(r), text_halign = text.align_left)
        table.cell(d, 1, r, is_up4 ? "▲ BULL" : "▼ BEAR", text_color = color.white,
             text_size = size.tiny, bgcolor = is_up4 ? THEME_BULL_BG : THEME_BEAR_BG, text_halign = text.align_center)
        r += 1
        table.cell(d, 0, r, "", bgcolor = THEME_SEP_BG, text_size = size.tiny)
        table.cell(d, 1, r, "", bgcolor = THEME_SEP_BG, text_size = size.tiny)
        table.merge_cells(d, 0, r, 1, r)
        r += 1

    // ── Core stats ──
    table.cell(d, 0, r, "BIAS", text_color = THEME_LABEL_TX, text_size = size.tiny, bgcolor = f_rowbg(r), text_halign = text.align_left)
    table.cell(d, 1, r, dec_txt, text_color = dec_col, text_size = size.tiny, bgcolor = f_rowbg(r), text_halign = text.align_center)
    r += 1
    table.cell(d, 0, r, "ACTION", text_color = THEME_LABEL_TX, text_size = size.tiny, bgcolor = f_rowbg(r), text_halign = text.align_left)
    table.cell(d, 1, r, act_txt, text_color = dec_col, text_size = size.tiny, bgcolor = f_rowbg(r), text_halign = text.align_center)
    r += 1
    table.cell(d, 0, r, "REGIME", text_color = THEME_LABEL_TX, text_size = size.tiny, bgcolor = f_rowbg(r), text_halign = text.align_left)
    table.cell(d, 1, r, regime_txt, text_color = regime_col, text_size = size.tiny, bgcolor = f_rowbg(r), text_halign = text.align_center)
    r += 1
    table.cell(d, 0, r, "MOMENTUM", text_color = THEME_LABEL_TX, text_size = size.tiny, bgcolor = f_rowbg(r), text_halign = text.align_left)
    table.cell(d, 1, r, mom_txt, text_color = mom_col, text_size = size.tiny, bgcolor = f_rowbg(r), text_halign = text.align_center)
    r += 1
    table.cell(d, 0, r, "CONVERGE", text_color = THEME_LABEL_TX, text_size = size.tiny, bgcolor = f_rowbg(r), text_halign = text.align_left)
    table.cell(d, 1, r, conv_txt, text_color = conv_col, text_size = size.tiny, bgcolor = f_rowbg(r), text_halign = text.align_center)
    r += 1

    // ── Optional detail rows (hidden in compact mode) ──
    if not compact_dash
        table.cell(d, 0, r, "STOP Δ", text_color = THEME_LABEL_TX, text_size = size.tiny, bgcolor = f_rowbg(r), text_halign = text.align_left)
        table.cell(d, 1, r, dist_str, text_color = THEME_VALUE_TX, text_size = size.tiny, bgcolor = f_rowbg(r), text_halign = text.align_center)
        r += 1
        table.cell(d, 0, r, "ER / L / M", text_color = THEME_LABEL_TX, text_size = size.tiny, bgcolor = f_rowbg(r), text_halign = text.align_left)
        table.cell(d, 1, r, er1_pct + "  " + elen1_str + "  " + emul1_str, text_color = THEME_VALUE_TX, text_size = size.tiny, bgcolor = f_rowbg(r), text_halign = text.align_center)
        r += 1
        table.cell(d, 0, r, "VOL FCST", text_color = THEME_LABEL_TX, text_size = size.tiny, bgcolor = f_rowbg(r), text_halign = text.align_left, tooltip = "Path-Dependent Volatility multiplier on the stop distance (chart tier). >1 = path implies expanding vol, stop pre-widens; <1 = calming, stop tightens. 'off' = module disabled (v1.3 distances).")
        table.cell(d, 1, r, pdv_str, text_color = color.new(pdv_col, 0), text_size = size.tiny, bgcolor = f_rowbg(r), text_halign = text.align_center, tooltip = "Path-Dependent Volatility multiplier on the stop distance (chart tier). >1 = path implies expanding vol, stop pre-widens; <1 = calming, stop tightens. 'off' = module disabled (v1.3 distances).")
        r += 1

    // ── Health row ──
    if sec_health
        table.cell(d, 0, r, "HEALTH", text_color = THEME_LABEL_TX, text_size = size.tiny, bgcolor = f_rowbg(r), text_halign = text.align_left, tooltip = healthDetail)
        table.cell(d, 1, r, healthShort, text_color = healthCol, text_size = size.tiny, bgcolor = f_rowbg(r), text_halign = text.align_center, tooltip = healthDetail)
        r += 1

    // ── In-panel legend ──
    if sec_legend
        table.cell(d, 0, r, "SIGNAL LEGEND", text_color = C_ACCENT, text_size = size.tiny, bgcolor = THEME_SEP_BG, text_halign = text.align_center)
        table.cell(d, 1, r, "", bgcolor = THEME_SEP_BG, text_size = size.tiny)
        table.merge_cells(d, 0, r, 1, r)
        r += 1
        table.cell(d, 0, r, "▲▼ Major", text_color = THEME_LABEL_TX, text_size = size.tiny, bgcolor = f_rowbg(r), text_halign = text.align_left)
        table.cell(d, 1, r, "15× stop flip", text_color = THEME_DIM_TX, text_size = size.tiny, bgcolor = f_rowbg(r), text_halign = text.align_right)
        r += 1
        table.cell(d, 0, r, "▲▼ Trend", text_color = THEME_LABEL_TX, text_size = size.tiny, bgcolor = f_rowbg(r), text_halign = text.align_left)
        table.cell(d, 1, r, "5× stop flip", text_color = THEME_DIM_TX, text_size = size.tiny, bgcolor = f_rowbg(r), text_halign = text.align_right)
        r += 1
        table.cell(d, 0, r, "▲▼ Scalp", text_color = THEME_LABEL_TX, text_size = size.tiny, bgcolor = f_rowbg(r), text_halign = text.align_left)
        table.cell(d, 1, r, "3× stop flip", text_color = THEME_DIM_TX, text_size = size.tiny, bgcolor = f_rowbg(r), text_halign = text.align_right)
        r += 1
        table.cell(d, 0, r, "● Pullback", text_color = THEME_LABEL_TX, text_size = size.tiny, bgcolor = f_rowbg(r), text_halign = text.align_left)
        table.cell(d, 1, r, "band re-touch", text_color = THEME_DIM_TX, text_size = size.tiny, bgcolor = f_rowbg(r), text_halign = text.align_right)
        r += 1
        table.cell(d, 0, r, "✚ Aligned", text_color = THEME_LABEL_TX, text_size = size.tiny, bgcolor = f_rowbg(r), text_halign = text.align_left)
        table.cell(d, 1, r, "all HTF agree", text_color = THEME_DIM_TX, text_size = size.tiny, bgcolor = f_rowbg(r), text_halign = text.align_right)
        r += 1
        table.cell(d, 0, r, "Vivid hue", text_color = score_color(score), text_size = size.tiny, bgcolor = f_rowbg(r), text_halign = text.align_left)
        table.cell(d, 1, r, "= stronger bias", text_color = THEME_DIM_TX, text_size = size.tiny, bgcolor = f_rowbg(r), text_halign = text.align_right)
        r += 1

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 12 — OPTIONAL CALIBRATION PANEL (off by default, theme-aware)
// ════════════════════════════════════════════════════════════════════════════

if cal_enable and cal_show_panel and barstate.islast
    var table cp = table.new(
         tbl_pos(cal_panel_pos), 4, 5,
         bgcolor      = THEME_PANEL_BG,
         border_color = THEME_BORDER,
         border_width = 1,
         frame_color  = is_light_chart ? color.new(#6a1b9a, 30) : color.new(#9c27b0, 55),
         frame_width  = 1)

    color hdrBg = THEME_HEADER_BG
    color rowBg = THEME_ROW_BG
    color hdrTx = is_light_chart ? #6a1b9a : #ce93d8
    color labTx = THEME_LABEL_TX
    color dimTx = THEME_DIM_TX

    string disclaimerTooltip = "Past-only descriptive data. NOT a backtest, NOT a forward prediction, NOT a trade signal. Each signal is logged at firing time; after " + str.tostring(cal_horizon) + " bars the engine checks whether price moved ≥ " + str.tostring(cal_move_atr) + " × ATR in the signal direction. 95% confidence interval shown for samples N≥5; smaller samples show 'warming up'."

    table.cell(cp, 0, 0, "Calibration (past)", text_color = hdrTx, bgcolor = hdrBg,
         text_size = size.tiny, text_halign = text.align_left, tooltip = disclaimerTooltip)
    table.cell(cp, 1, 0, "N",        text_color = hdrTx, bgcolor = hdrBg, text_size = size.tiny, text_halign = text.align_center)
    table.cell(cp, 2, 0, "Hit rate", text_color = hdrTx, bgcolor = hdrBg, text_size = size.tiny, text_halign = text.align_center)
    table.cell(cp, 3, 0, "95% CI",   text_color = hdrTx, bgcolor = hdrBg, text_size = size.tiny, text_halign = text.align_right)

    int totT  = array.get(cal_total, 0)
    int hitT  = array.get(cal_hits,  0)
    int totM  = array.get(cal_total, 1)
    int hitM  = array.get(cal_hits,  1)
    int totAll = totT + totM
    int hitAll = hitT + hitM

    string[] labelsArr = array.from("Trend", "Major", "All signals")
    int[]    totArr    = array.from(totT, totM, totAll)
    int[]    hitArr    = array.from(hitT, hitM, hitAll)

    for rr = 0 to 2
        int    rT = array.get(totArr, rr)
        int    rH = array.get(hitArr, rr)
        string rL = array.get(labelsArr, rr)
        float  rate_pct = rT > 0 ? rH * 100.0 / rT : na
        [lo, hi] = f_score_ci(rH, rT)
        string rateTxt = rT == 0 ? "—" : rT < 5 ? "warming up" : str.tostring(rate_pct, "#.#") + "%"
        string ciTxt   = na(lo) ? "—" : str.tostring(math.round(lo * 100)) + "–" + str.tostring(math.round(hi * 100)) + "%"
        color  rateCol = dimTx
        if rT >= 5
            if rate_pct >= 60.0
                rateCol := color.new(C_GREEN, 0)
            else if rate_pct >= 50.0
                rateCol := color.new(C_AMBER, 0)
            else
                rateCol := color.new(C_RED, 0)
        table.cell(cp, 0, rr + 1, rL,               text_color = labTx, bgcolor = rowBg, text_size = size.tiny, text_halign = text.align_left)
        table.cell(cp, 1, rr + 1, str.tostring(rT), text_color = labTx, bgcolor = rowBg, text_size = size.tiny, text_halign = text.align_center)
        table.cell(cp, 2, rr + 1, rateTxt,          text_color = rateCol, bgcolor = rowBg, text_size = size.tiny, text_halign = text.align_center)
        table.cell(cp, 3, rr + 1, ciTxt,            text_color = labTx, bgcolor = rowBg, text_size = size.tiny, text_halign = text.align_right)

    int pendN = array.size(pend_bar)
    int oldestAge = 0
    if pendN > 0
        oldestAge := bar_index - array.get(pend_bar, 0)
    string trackerTxt = pendN > 0 ?
         (str.tostring(pendN) + " pending – oldest " + str.tostring(oldestAge) + "b ago") :
         "Past-only data – no forward guarantee"
    table.cell(cp, 0, 4, trackerTxt, text_color = dimTx, bgcolor = hdrBg,
         text_size = size.tiny, text_halign = text.align_left)
    table.cell(cp, 1, 4, "", bgcolor = hdrBg)
    table.cell(cp, 2, 4, "", bgcolor = hdrBg)
    table.cell(cp, 3, 4, "", bgcolor = hdrBg)
    table.merge_cells(cp, 0, 4, 3, 4)

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 13 — ALERTS
// ════════════════════════════════════════════════════════════════════════════

if buy_sig
    alert("AVS MTF BUY  |  " + syminfo.ticker +
          "  |  " + syminfo.type +
          "  |  Price: "  + str.tostring(math.round(close,   2)) +
          "  |  Score: "  + score_str +
          "  |  ER: "     + er1_pct +
          "  |  Stop: "   + str.tostring(math.round(vstop2,  2)),
          alert.freq_once_per_bar)

if sell_sig
    alert("AVS MTF SELL  |  " + syminfo.ticker +
          "  |  " + syminfo.type +
          "  |  Price: "  + str.tostring(math.round(close,   2)) +
          "  |  Score: "  + score_str +
          "  |  ER: "     + er1_pct +
          "  |  Stop: "   + str.tostring(math.round(vstop2,  2)),
          alert.freq_once_per_bar)

if trend_buy
    alert("AVS MTF TREND BUY  |  " + syminfo.ticker +
          "  |  Price: "  + str.tostring(math.round(close, 2)) +
          "  |  Score: "  + score_str,
          alert.freq_once_per_bar)

if trend_sell
    alert("AVS MTF TREND SELL  |  " + syminfo.ticker +
          "  |  Price: "  + str.tostring(math.round(close, 2)) +
          "  |  Score: "  + score_str,
          alert.freq_once_per_bar)

if major_buy
    alert("AVS MTF MAJOR BUY  |  " + syminfo.ticker +
          "  |  Price: "       + str.tostring(math.round(close, 2)) +
          "  |  Score: "       + score_str +
          "  |  Convergence: " + conv_txt,
          alert.freq_once_per_bar)

if major_sell
    alert("AVS MTF MAJOR SELL  |  " + syminfo.ticker +
          "  |  Price: "       + str.tostring(math.round(close, 2)) +
          "  |  Score: "       + score_str +
          "  |  Convergence: " + conv_txt,
          alert.freq_once_per_bar)

if all_bull
    alert("AVS MTF ALL HTF BULLISH  |  " + syminfo.ticker +
          "  |  Price: "  + str.tostring(math.round(close, 2)) +
          "  |  Score: "  + score_str +
          "  |  Regime: " + regime_txt,
          alert.freq_once_per_bar)

if all_bear
    alert("AVS MTF ALL HTF BEARISH  |  " + syminfo.ticker +
          "  |  Price: "  + str.tostring(math.round(close, 2)) +
          "  |  Score: "  + score_str +
          "  |  Regime: " + regime_txt,
          alert.freq_once_per_bar)

if is_choppy and not is_choppy[1]
    alert("AVS MTF CHOPPY MARKET  |  " + syminfo.ticker +
          "  |  Score: " + score_str +
          "  — Consider reducing position size.",
          alert.freq_once_per_bar)

if score >= 8 and score[1] < 8
    alert("AVS MTF STRONG BULLISH ZONE  |  " + syminfo.ticker +
          "  |  Score: " + score_str,
          alert.freq_once_per_bar)

if score <= -8 and score[1] > -8
    alert("AVS MTF STRONG BEARISH ZONE  |  " + syminfo.ticker +
          "  |  Score: " + score_str,
          alert.freq_once_per_bar)

if active_limbo and not active_limbo[1]
    alert("AVS MTF EARLY BREACH  |  " + syminfo.ticker +
          "  |  Price: " + str.tostring(math.round(close,  2)) +
          "  |  Stop: "  + str.tostring(math.round(vstop2, 2)),
          alert.freq_once_per_bar)

if convergence >= 0.75 and convergence[1] < 0.75
    alert("AVS MTF HIGH CONVERGENCE  |  " + syminfo.ticker +
          "  |  All timeframe stops clustering — elevated conviction.",
          alert.freq_once_per_bar)

if vcl_warning and not vcl_warning[1]
    alert("AVS MTF VOLATILITY CLUSTER  |  " + syminfo.ticker +
          "  |  Severity: " + vcl_badge +
          "  |  Score floor raised by " + str.tostring(vcl_lift, "#.#"),
          alert.freq_once_per_bar)

if not vcl_warning and vcl_warning[1]
    alert("AVS MTF VOLATILITY NORMALIZED  |  " + syminfo.ticker +
          "  |  Cluster ended; suppression released.",
          alert.freq_once_per_bar)

if healthCode > 0 and healthCode[1] == 0
    alert("AVS MTF DATA HEALTH DEGRADED  |  " + syminfo.ticker +
          "  |  " + healthDetail,
          alert.freq_once_per_bar)

if healthCode == 0 and healthCode[1] > 0
    alert("AVS MTF DATA HEALTH RESTORED  |  " + syminfo.ticker,
          alert.freq_once_per_bar)

if pb_buy_f
    alert("AVS MTF PULLBACK BUY (Scalp)  |  " + syminfo.ticker +
          "  |  Price: " + str.tostring(math.round(close, 2)),
          alert.freq_once_per_bar)
if pb_sell_f
    alert("AVS MTF PULLBACK SELL (Scalp)  |  " + syminfo.ticker +
          "  |  Price: " + str.tostring(math.round(close, 2)),
          alert.freq_once_per_bar)
if tpb_buy_f
    alert("AVS MTF PULLBACK BUY (Trend)  |  " + syminfo.ticker +
          "  |  Price: " + str.tostring(math.round(close, 2)),
          alert.freq_once_per_bar)
if tpb_sell_f
    alert("AVS MTF PULLBACK SELL (Trend)  |  " + syminfo.ticker +
          "  |  Price: " + str.tostring(math.round(close, 2)),
          alert.freq_once_per_bar)
if mpb_buy_f
    alert("AVS MTF PULLBACK BUY (Major)  |  " + syminfo.ticker +
          "  |  Price: " + str.tostring(math.round(close, 2)),
          alert.freq_once_per_bar)
if mpb_sell_f
    alert("AVS MTF PULLBACK SELL (Major)  |  " + syminfo.ticker +
          "  |  Price: " + str.tostring(math.round(close, 2)),
          alert.freq_once_per_bar)

alertcondition(trend_buy,  "① Trend Buy",        "AVS MTF: TREND BUY — 5× stop flipped bullish")
alertcondition(trend_sell, "① Trend Sell",       "AVS MTF: TREND SELL — 5× stop flipped bearish")
alertcondition(major_buy,  "② Major Buy",        "AVS MTF: MAJOR BUY — 15× stop flipped bullish")
alertcondition(major_sell, "② Major Sell",       "AVS MTF: MAJOR SELL — 15× stop flipped bearish")
alertcondition(all_bull,   "◆ All HTF Bullish",  "AVS MTF: ALL timeframes ALIGNED BULLISH")
alertcondition(all_bear,   "◆ All HTF Bearish",  "AVS MTF: ALL timeframes ALIGNED BEARISH")
alertcondition(score >= 8 and score[1] < 8,
               "★ Strong Bullish Zone", "AVS MTF: Score crossed into ≥ +8 STRONG BULLISH zone")
alertcondition(score <= -8 and score[1] > -8,
               "★ Strong Bearish Zone", "AVS MTF: Score crossed into ≤ −8 STRONG BEARISH zone")
alertcondition(vcl_warning and not vcl_warning[1],
               "⚡ Vol Cluster Started",
               "AVS MTF: Volatility cluster detected — score floor raised")
alertcondition(healthCode > 0 and healthCode[1] == 0,
               "⚠ Data Health Degraded",
               "AVS MTF: Data integrity degraded — see HEALTH row tooltip")

// ════════════════════════════════════════════════════════════════════════════
//  SECTION 14 — DATA-WINDOW EXPORTS (hidden plots)
// ════════════════════════════════════════════════════════════════════════════

plot(score,             "EXP_BiasScore",      display = display.data_window)
plot(vstop4,            "EXP_15x_VStop",      display = display.data_window)
plot(convergence,       "EXP_Convergence",    display = display.data_window)
plot(pdv1,              "EXP_PDV_Multiplier", display = display.data_window)

// ════════════════════════════════════════════════════════════════════════════
//  END OF SCRIPT — AVS MTF v1.4
//
//  REMINDER: For informational and educational purposes only. Not financial,
//  investment, or trading advice. Past signal performance does not guarantee
//  future results. The calibration panel is descriptive past-only data, not a
//  prediction. Trade responsibly. Manage your risk.
// ════════════════════════════════════════════════════════════════════════════
````
