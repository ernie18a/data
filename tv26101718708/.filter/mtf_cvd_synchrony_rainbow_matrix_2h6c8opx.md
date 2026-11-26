# MTF CVD Synchrony | Rainbow Matrix

- url: https://www.tradingview.com/script/2h6C8opx-MTF-CVD-Synchrony-Rainbow-Matrix/
- type: indicator
- pine_id: PUB;092b614eb1b4472680774a148e9fab6e
- version: 1.0

## Description

GENERAL OVERVIEW
MTF CVD Synchrony is a multi-timeframe directional flow oscillator that condenses five independent CVD (Cumulative Volume Delta) readings — one per Fibonacci-spaced timeframe — into a single weighted Master Line on a zero-centered 0-100 scale, surrounded by per-TF "ghost lines" that fade visually as they diverge from the consensus. The defining feature: 50 is true neutral. Above 50 means buyers are dominating; below 50 means sellers are dominating. The further from 50, the stronger the directional pressure. When the five timeframes align, the rainbow becomes a solid band; when they diverge, the disagreement becomes a visible density property of the indicator itself.
A background histogram visualizes the Master score's deviation from the neutral 50 line — green columns extend up when buyers dominate, red columns extend down when sellers dominate. A compact 7×9 MTF Legend Table surfaces every dimension simultaneously: per-TF resolutions, score values, trend direction, divergence flags, raw flow magnitude, and named directional State — with an antenna marker flagging the row whose timeframe matches your chart's native resolution.
Designed as the directional member of a three-indicator family. Apply all three side-by-side for a complete read: MTF RSI Synchrony shows where price sits in its momentum range; MTF Volume Delta Bar Synchrony shows whether the move has volume magnitude behind it; MTF CVD Synchrony shows who is actually winning — buyers or sellers. Same visual signature, same canonical Fibonacci ratios, same Legend Table layout — instant cross-indicator readability.

WHAT IS THE THEORY BEHIND THIS INDICATOR

Cumulative Volume Delta attempts to answer a question that price and volume alone cannot: in any given bar, were buyers or sellers more aggressive? Traditional volume tells you HOW MUCH traded, but not the DIRECTION of the pressure. A high-volume bar that closes flat tells a very different story from a high-volume bar that closes at its highs — yet raw volume scores them identically.
CVD approximates directional pressure by weighting each bar's volume by where price closed within its range. This indicator uses the Close Location Value (CLV) for that weighting:

clv = ((close − low) − (high − close)) / (high − low)

CLV ranges from +1 (close exactly at the high — maximum buying pressure) to −1 (close exactly at the low — maximum selling pressure), with 0 at the midpoint. Multiplying CLV by volume produces a signed directional contribution per bar: delta_raw = clv × volume. This is more nuanced than the binary tick rule (close > open = buy) used by most "delta" indicators — CLV captures HOW DECISIVELY price closed in its range, not just the sign.
The per-bar delta is then smoothed by EMA and normalized into a bounded 0-100 zero-centered score:

cvd_smooth = EMA(delta_raw, smoothing_length)
max_abs    = highest(|cvd_smooth|, normalization_window)
score      = 50 + (cvd_smooth / max_abs) × 50    [clamped 0-100]

The genius of the zero-centered approach: 50 always means balance, regardless of the asset's structural bias. A score of 75 means buyers are exerting 50% of the maximum recent pressure to the upside; a score of 25 means sellers are exerting 50% of maximum recent pressure to the downside. This is fundamentally different from a percentile rank (which would anchor 50 at the historical median, skewing with structural trends).
Five such scores — one per timeframe (default 5 / 15 / 60 / 240 / D) — are fused via canonical Fibonacci weights (0.15 / 0.20 / 0.25 / 0.25 / 0.15, peak weight on the macro TF3/TF4 where institutional positioning consolidates) into the weighted Master Line.

FEATURES

🔹 Multi-Timeframe CVD Fusion Engine (zero-centered directional scale)
🔹 CVD Histogram (deviation from neutral 50 — green buy / red sell)
🔹 Adaptive Fibonacci Channel (Z-Breathing → Z-Alert → Z-Exhaustion → Black Swan)
🔹 Hybrid Black Swan Zones (static or dynamic — default dynamic)
🔹 Classic Price↔CVD Divergence Detection (per-TF + Master)
🔹 MTF Legend Table (7 columns × 9 rows, with Raw Flow + State, multilingual)
🔹 Multilingual Interface (EN / PT / ES / RU / ZH)

🔹 Multi-Timeframe CVD Fusion Engine
What It Does
Runs five independent CVD scores on Fibonacci-spaced timeframes and fuses them into a single weighted Master Line, with each per-TF reading plotted as a ghost line that fades by distance to the consensus.
Method
On each timeframe, f_cvd_full() computes CLV × volume per bar, smooths it via EMA, and normalizes against a rolling-max window to produce the zero-centered score. The five scores fuse via Fibonacci weights (0.15 / 0.20 / 0.25 / 0.25 / 0.15). Both smoothing length and normalization window are independently configurable per timeframe.
Per-TF smoothing defaults (Wilder-anchored on TF3+TF4):

◇ TF1 (5m): 7 — scalping
◇ TF2 (15m): 10 — day-trading
◇ TF3 (60m): 14 — Wilder canonical
◇ TF4 (240m): 14 — Wilder canonical
◇ TF5 (D): 21 — swing/position
Per-TF normalization windows (each TF's natural horizon):
◇ TF1: 30 (≈2.5h on 5m)
◇ TF2: 50 (≈12.5h on 15m)
◇ TF3: 80 (≈3.3 days on 1h)
◇ TF4: 100 (≈16 days on 4h)
◇ TF5: 150 (≈5 months on Daily)

All request.security calls use lookahead=barmerge.lookahead_off for anti-repaint integrity.

Why It Matters
A 5-minute buy surge means little if the 4-hour and daily flows are decisively selling. The fusion engine reveals whether directional pressure is aligned across timescales (high conviction) or contradictory (a counter-trend bounce inside a larger trend). The ghost-line rainbow makes that alignment visible at a glance.

🔹 Adaptive Fibonacci Channel
What It Does
Six color-coded bands around the Master Line that adapt to its own recent volatility, using the brand's canonical Fibonacci ratios.
Method
Highest/lowest of the Master over a configurable lookback (default 50) are smoothed by EMA (default 10) to form the channel envelope. Bands sit at canonical Fibonacci proportions: Z-Breathing (1.50/1.85), Z-Alert (1.85σ anchor), Z-Exhaustion (2.75/1.85), Black Swan (3.85/1.85). All six band values are mathematically clamped to [0,100] before rendering, keeping the rainbow inside the visible pane.

Why It Matters
Static thresholds can't adapt to regime changes. The Fibonacci channel calibrates the warning zones to the asset's current directional-flow volatility, so a "climax" on a calm pair and a "climax" on a volatile one both trigger at appropriate statistical extremes.

🔹 Hybrid Black Swan Zones
What It Does
Flags directional flow climax extremes — either at static 85/15 thresholds (BUY CLIMAX / SELL CLIMAX boundaries) or at the dynamic Fibonacci 3.85σ band.
Method
Dynamic Black Swan Mode is ON by default (Fibonacci 3.85σ proportion of the Master channel). Toggle OFF for static 85/15. Each zone renders as a glow line that brightens as the Master approaches. The static reference lines (15/50/85) are shown by default to anchor the zero-centered scale: 85 = purple (buy climax boundary), 50 = yellow (neutral), 15 = aqua (sell climax boundary).

Why It Matters
Directional flow climaxes mark exhaustion points — a BUY CLIMAX (score ≥ 85) means buyers have pushed to a recent extreme, often preceding a pause or reversal; a SELL CLIMAX (≤ 15) marks capitulation. The dynamic mode self-calibrates per asset and regime.

🔹 Classic Price↔CVD Divergence Detection
What It Does
Detects regular bear divergences (price higher high while CVD makes lower high — rally on weakening buy pressure) and bull divergences (price lower low while CVD makes higher low — selling exhausting). Runs on each timeframe AND on the Master line.
Method
Per-TF divergence runs inside request.security via pivot detection on the per-TF CVD score. Master divergence runs on the chart-TF directly, rendering a connecting line + label between pivots (red bear / green bull) on the pane. Per-TF results surface in the Legend Table's "Div" column.

Why It Matters
Price↔flow divergence is one of the most powerful applications of CVD. When price makes a new high but directional flow doesn't confirm, the rally is running on fading conviction — a classic distribution warning. Detecting this per-TF AND on the Master gives both early granular warnings and high-conviction confirmations.

🔹 MTF Legend Table
What It Does
A compact 7×9 table surfacing every dimension of the analysis at a glance.
Method
Rendered via table.new(force_overlay=false) on the pane. Layout:
◇ Row 0: title (spans all columns)
◇ Row 1: column headers — Indicator / Timeframe / Value / Trend / Div / Raw / State
◇ Rows 2-6: per-TF data
◇ Row 7: Master row ("🌈 Master (~XhYm)" with effective TF)
◇ Row 8: MTF Divergence status row
Per-TF cells show: ● TF label (+ antenna 📡 if chart-native), TF resolution, zero-centered score (zone-colored), trend arrow (±0.5 deadzone), divergence (🔺/🔻/—), Raw Flow (compact K/M/B signed magnitude, green if positive / red if negative), and State (directional name, zone-colored).

Why It Matters
The Raw Flow column complements the Value column: Value answers "how strong is the directional pressure?" (the normalized score), while Raw answers "how much actual volume is behind it?" (the absolute flow). A score of 75 with a small raw magnitude is weaker conviction than 75 with a huge raw magnitude. Together with State, the table tells a complete directional story per timeframe.

🔹 Multilingual Interface
What It Does
Translates all HUD labels, status messages, alert text, Legend Table headers, and directional State names to 5 languages: English, Português, Español, Русский, 中文.
Method
A single language dropdown selects the active language via Pine v6's ternary-chain pattern. Code, comments, and configuration tooltips remain in English by convention.

Why It Matters
The Rainbow Matrix family is built for traders worldwide. Multilingual UI removes friction for non-English-native users.

HOW TO USE

Reading the Pane
◇ Master near 50 with ghost lines tight: balanced flow, no directional edge (absorption / equilibrium).
◇ Master rising above 50: buyers gaining control. Above 62 = BUY PRESSURE; above 71 = STRONG BUY.
◇ Master falling below 50: sellers gaining control. Below 38 = SELL PRESSURE; below 29 = STRONG SELL.
◇ Master touches Black Swan High (≥85, purple glow): BUY CLIMAX — buyers at a recent extreme, watch for exhaustion.
◇ Master touches Black Swan Low (≤15, aqua glow): SELL CLIMAX — capitulation, watch for reversal.
◇ Histogram green/red columns: immediate bar-by-bar directional read around the 50 centerline.
Reading the Legend Table
The antenna marker (📡) flags your chart's native timeframe — start there, then scan up/down to see whether faster/slower TFs confirm or contradict the directional bias. Compare Value (pressure strength), Raw (actual flow magnitude), and State (named classification) for each row. The status row summarizes MTF alignment between TF1 and TF5.
Reading Divergences
Master bear divergence (price up + CVD down) = rally on fading buy conviction, distribution warning. Master bull divergence (price down + CVD up) = selling exhausting, potential bottom. Per-TF divergences in the Div column give early granular warnings.
Tactical Combinations
◇ Master BUY CLIMAX + bear divergence + multiple TFs diverging = strongest reversal-from-high signal.
◇ Master SELL CLIMAX + bull divergence = strongest reversal-from-low signal.
◇ Master near 50 + all TFs near 50 + tight ghosts = absorption / coiling, often precedes a directional break.
◇ Triple confluence (the full family): RSI overbought + Volume EXTREME magnitude + CVD STRONG SELL = distribution at the top. RSI oversold + Volume EXTREME + CVD STRONG BUY = accumulation at the bottom. These three indicators answering momentum + magnitude + direction simultaneously is the strongest read the Rainbow Matrix family offers.

INPUTS EXPLAINED

GLOBAL SETTINGS — System Language (EN/PT/ES/RU/ZH), table/label font sizes.
MULTI-TIMEFRAME — AI Auto-Sync TFs; TF1-TF5 manual resolutions (default 5/15/60/240/D); per-TF CVD Smoothing Length (7/10/14/14/21); per-TF CVD Normalization Window (30/50/80/100/150).
ENGINE — Dynamic Black Swan Mode (default ON); Dynamic Channel Lookback (50) and Smoothing (10); Divergence Pivot Lookback (5).
VISUALIZATION — TF1-TF5 colors + show toggles (all ghost lines OFF by default — only Master visible on install); Ghost Fade Sensitivity (3.5); Show Master Line / Rainbow Fills / Black Swan / Dynamic Channel; Show CVD Histogram; Show MTF Legend Table; Show Divergence Column; Show Raw Flow Column; Show State Column; Show Master Divergence Chart Line; Legend position; Show Divergence Event Markers; Show Static Reference Lines (15/50/85, ON by default).
ALERTS — Black Swan crossings (high/low); Strong MTF Divergence; Z-Exhaustion zone entries; Master Classic Divergence.

IMPORTANT NOTES

🔸 Pine Script v6 — uses request.security with lookahead=barmerge.lookahead_off. 16 total security calls (5 CVD score + 5 per-TF divergence + supporting channel calculations). Chart load may take a moment longer than a single-TF indicator.
🔸 CLV approximation, not order-flow tick data — Directional pressure is approximated via the Close Location Value (where price closed within each bar's range), NOT real bid/ask order flow. Pine Script v6 has no tick-by-tick data access in indicator scripts. CLV is a more nuanced approximation than the binary tick rule used by most free-tier "delta" indicators, but it remains an approximation. For true order-flow delta, use dedicated footprint/order-flow tools.
🔸 Zero-centered scale — Unlike the percentile-rank siblings (RSI, Volume Delta Bar), this indicator's 50 is a TRUE neutral (zero net directional flow), not a historical median. This is intentional — direction is inherently signed, so a fixed zero-point is more meaningful than a regime-relative median.
🔸 Normalization warmup — During the first normalization_window bars on each TF, the rolling-max anchor (max_abs) is built from a small sample, so early bars may show exaggerated swings until the window fills. Normal warmup behavior for any rolling-window indicator.
🔸 Repaint behavior — Historical bars use confirmed close data; the current real-time bar updates as ticks arrive. Pivot-based divergence requires confirmation bars before triggering (standard pivot divergence behavior).
🔸 Fibonacci ratios are canonical — The channel proportions (1.50/1.85/2.75/3.85) and fusion weights (0.15/0.20/0.25/0.25/0.15) match the Rainbow Matrix brand standard across all sibling indicators, preserving cross-indicator visual consistency.
🔸 License: MPL 2.0 — open source. Free to fork, modify, and republish under the same license terms.

UNIQUENESS

Three pillars differentiate this from other CVD indicators on TradingView:
1. Multi-timeframe CVD fusion with synchrony as a visual property. Most CVD tools run on a single timeframe. This indicator runs five, fuses them via Fibonacci weights, and expresses directional alignment as a rainbow density — solid when timeframes agree on direction, spread when they disagree. The cross-TF directional consensus becomes immediately readable.
2. True zero-centered scale with CLV weighting. The 50 midpoint is a mathematically meaningful neutral (zero net flow), not a regime-skewed median. And the directional weighting uses Close Location Value — capturing how decisively price closed within each bar's range — rather than the cruder binary tick rule. This combination produces a directional read that stays honest across structural trends.
3. Three complementary readings in one Legend Table, designed as a family. Value (pressure strength), Raw Flow (actual magnitude), and State (named classification) disambiguate a single timeframe's directional picture. And as the directional member of the Rainbow Matrix trio (alongside RSI for momentum and Volume Delta Bar for magnitude), it completes a three-dimensional read of any market: where price is, how big the move is, and who's winning.

Rainbow Matrix AI | Multi-timeframe institutional analysis tools for traders.
🌐 rainbowmatrix.ai
✉️ Contact: contact@rainbowmatrix.ai

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © rainbowmatrix
//

// ════════════════════════════════════════════════════════════════════════════════
// MTF CVD SYNCHRONY
//
// A multi-timeframe Cumulative Volume Delta fusion oscillator that aggregates
// five independent CVD readings — one per Fibonacci-spaced timeframe — into a
// single weighted Master Line. Unlike the percentile-rank-based RSI and Volume
// sibling indicators (which measure magnitude/momentum), CVD measures DIRECTION:
// who is dominating — buyers or sellers?
//
// CORE DIFFERENTIATOR — ZERO-CENTERED SCALE:
//   The CVD score uses a zero-centered scale instead of percentile rank:
//     score = 50 + (cvd_smooth / max_abs) × 50    [clamped 0-100]
//     50 = TRUE NEUTRAL (zero CVD = perfect buy/sell balance)
//    100 = peak BUY pressure in normalization window
//      0 = peak SELL pressure in normalization window
//   50 is a mathematically meaningful midpoint (absorption / equilibrium),
//   not a historical median.
//
// FAMILY POSITIONING:
//   MTF RSI Synchrony        → MOMENTUM   ("where in range?")
//   MTF Volume Delta Bar     → MAGNITUDE  ("how big historically?")
//   MTF CVD Synchrony [THIS] → DIRECTION  ("who is dominating?")
//   Apply all three for full institutional read: RSI confirms momentum,
//   Volume confirms size, CVD confirms who's behind the move.
//
// METHOD:
//   1. For each of 5 user-configured timeframes (default 5/15/60/240/D), the
//      script computes CVD via f_cvd_full() called inside request.security():
//        a. clv (Close Location Value) = ((close-low)-(high-close))/(high-low)
//           +1 = close at high (max bullish), -1 = close at low (max bearish),
//            0 = close at midrange. Edge case high==low: clv=0.
//        b. delta_raw  = clv × volume = signed directional volume contribution
//        c. cvd_smooth = EMA(delta_raw, per-TF smoothing length)
//        d. max_abs    = highest(|cvd_smooth|, per-TF normalization window)
//        e. score      = 50 + (cvd_smooth / max_abs) × 50, clamped to [0, 100]
//      Per-TF inputs allow fast/slow tuning per timeframe (defaults:
//      smoothing 7/10/14/14/21, normalization 30/50/80/100/150).
//   2. The five per-TF scores are aggregated via canonical Fibonacci weights
//      (0.15 / 0.20 / 0.25 / 0.25 / 0.15 — peak weight on macro TF3/TF4 where
//      institutional flow consolidates) into the weighted Master Line.
//   3. Each per-TF score is plotted as a ghost line with transparency inversely
//      proportional to its absolute distance from the Master. Synchrony itself
//      becomes a visible density property of the rainbow.
//   4. CVD HISTOGRAM (background visual): plots Master score as columns
//      extending from the 50 (neutral) centerline. Green above 50 = buy
//      dominant; red below 50 = sell dominant. High-transparency background
//      element that complements the Master line.
//   5. Master plotted against an adaptive Fibonacci channel (Z-Breathing 1.50σ
//      / Z-Alert 1.85σ / Z-Exhaustion 2.75σ / Black Swan 3.85σ).
//   6. Black Swan zones hybrid: static 85/15 by default (top/bottom 15% score
//      extremes — BUY CLIMAX / SELL CLIMAX zones), or dynamic adapt-to-
//      volatility via the Fibonacci 3.85σ proportion when toggled.
//   7. Classic price↔CVD divergence engine runs per-TF (via request.security)
//      and on the Master line directly. Detects:
//        • Bear divergence (top): price HH while CVD pivot makes LH (buyers
//          losing conviction even as price extends — distribution footprint).
//        • Bull divergence (bottom): price LL while CVD pivot makes HL (sellers
//          exhausting even as price extends — accumulation footprint).
//   8. The MTF Legend Table (7 cols × 9 rows) displays per-timeframe data:
//      Indicator | Timeframe | Value (0-100 score) | Trend (▲▼▬) |
//      Div (🔺/🔻/—) | Raw (signed K/M/B flow) | State (directional 7-tier).
//      Master row, status row (TF1-vs-TF5 alignment), and 📡 antenna marker
//      flagging the chart's native TF row.
//
// ORIGINALITY:
//   Three uniqueness pillars vs other CVD indicators on TradingView:
//   1. True zero-centered directional flow — not percentile rank. 50 is
//      mathematically meaningful (absorption / equilibrium), enabling
//      direction-change reading that magnitude-relative metrics miss.
//   2. CLV-weighted volume delta — beyond binary tick rule. Considers WHERE
//      in the bar's range the close occurred. A close near the high after a
//      wide-range bar contributes more directional weight than a close
//      marginally above open in a narrow bar.
//   3. Per-TF customizable smoothing AND normalization. Each timeframe has
//      its own EMA length and rolling-max window inputs, letting scalpers
//      tune fast TFs aggressively while keeping slow TFs anchored. Other
//      CVD indicators expose one global setting that compromises on all TFs.
//
// HOW TO USE:
//   - Master around 50: balanced flow / absorption — wait for a directional break.
//   - Master sustained > 62 (BUY PRESSURE zone): bulls dominating.
//   - Master sustained < 38 (SELL PRESSURE zone): bears dominating.
//   - Master ≥ 85 (BUY CLIMAX): extreme buy pressure — potential exhaustion top.
//   - Master ≤ 15 (SELL CLIMAX): extreme sell pressure — potential capitulation bottom.
//   - Histogram color matches score zone — quick visual scan of dominant side.
//   - Classic divergence line on Master:
//      Bear = price HH + CVD LH (rally without flow support — distribution).
//      Bull = price LL + CVD HL (selling drying up — accumulation).
//   - Legend Table 'Raw' column: per-TF signed flow magnitude (K/M/B notation,
//     green if positive / red if negative). Multiple TFs all positive = aligned
//     buy flow. Sign disagreement across TFs = absorption / mixed flow.
//   - Legend Table 'State' column: named directional tier (BUY CLIMAX...
//     SELL CLIMAX). Multiple TFs in the same tier = high-conviction direction.
//   - Antenna marker (📡) on Legend Table = the chart's native TF row —
//     start your read there, then scan up/down for cross-TF confirmation.
//   - Best practice: pair with MTF RSI Synchrony + MTF Volume Delta Bar
//     Synchrony for the complete momentum + magnitude + direction picture.
//
// IMPORTANT — CLV approximation disclosure:
//   The CLV-weighted delta is an APPROXIMATION of order flow direction.
//   Pine v6 has no tick-data access in indicator scripts. The CLV formula
//   considers where price closed within the bar's range, which is more
//   nuanced than the binary tick rule (close > open = buy) used by most
//   "delta" indicators on TradingView free tier — but it remains an
//   OHLC-based approximation, not true order-book delta.
//
// MULTILINGUAL UI:
//   HUD labels and alert messages are translated to 5 languages (English,
//   Português, Español, Русский, 中文) via the System Language input.
//   Configuration tooltips, variable names and code comments remain in
//   English by convention.
//
// ════════════════════════════════════════════════════════════════════════════════
//@version=6
indicator("MTF CVD Synchrony | Rainbow Matrix",
     overlay         = false,
     max_bars_back   = 1440,
     max_lines_count = 500,
     max_labels_count = 500,
     max_boxes_count = 500)

// ========================================================================================================
// COLOR PALETTE (Rainbow Matrix canonical — do NOT change)
// ========================================================================================================
c_up_4 = color.purple     // Black Swan High (extreme overbought)
c_up_3 = color.red        // Z-Exhaustion High
c_up_2 = color.orange     // Z-Alert High
c_up_1 = color.yellow     // Z-Breathing High
c_dn_1 = color.green      // Z-Breathing Low
c_dn_2 = color.teal       // Z-Alert Low
c_dn_3 = color.blue       // Z-Exhaustion Low
c_dn_4 = color.aqua       // Black Swan Low (extreme oversold)
c_neutral = color.gray
c_black   = color.black

// ========================================================================================================
// GLOBAL SETTINGS
// ========================================================================================================
g_global = "GLOBAL SETTINGS"
language = input.string("English", "System Language",
     options = ["English", "Português", "Español", "Русский", "中文 (Chinese)"],
     group   = g_global,
     tooltip = "Language for HUD labels and alert messages. Affects only the on-chart UI text; code, comments, and configuration tooltips remain in English.")

string _l = language == "Português" ? "PT" : language == "Español" ? "ES" : language == "Русский" ? "RU" : language == "中文 (Chinese)" ? "ZH" : "EN"

font_size_table  = input.string("Small", "Table Font Size",  options = ["Tiny", "Small", "Normal", "Large"], group = g_global, tooltip = "Font size for the per-timeframe and Master data rows of the MTF Legend Table (RSI values and trend arrows).")
font_size_labels = input.string("Small", "Labels Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = g_global, tooltip = "Font size for the header and status rows of the MTF Legend Table.")

f_size(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

sz_tbl = f_size(font_size_table)
sz_lbl = f_size(font_size_labels)

// ========================================================================================================
// MULTI-TIMEFRAME
// ========================================================================================================
g_tf = "MULTI-TIMEFRAME"
auto_tf    = input.bool(false, "AI Auto-Sync TFs", group = g_tf, tooltip = "When ON, the engine auto-adjusts the five timeframes based on your current chart resolution to keep the Fibonacci spacing meaningful. When OFF, your manual values below are used.")
m_tf1      = input.string("5",   "TF 1 — Trigger (Minutes, D, W)",    group = g_tf, tooltip = "Fastest timeframe (innermost ghost line). Default 5m. Weight 0.15 in the Master Volume fusion.")
m_tf2      = input.string("15",  "TF 2 — Intraday (Minutes, D, W)",   group = g_tf, tooltip = "Intraday timeframe. Default 15m. Weight 0.20.")
m_tf3      = input.string("60",  "TF 3 — Macro 1 (Minutes, D, W)",    group = g_tf, tooltip = "First macro reference. Default 60m (1h). Weight 0.25 (peak).")
m_tf4      = input.string("240", "TF 4 — Macro 2 (Minutes, D, W)",    group = g_tf, tooltip = "Second macro reference. Default 240m (4h). Weight 0.25 (peak).")
m_tf5      = input.string("D",   "TF 5 — Base/Daily (Minutes, D, W)", group = g_tf, tooltip = "Slowest anchor (outermost context). Default Daily. Weight 0.15.")
cvd_smooth_len_tf1 = input.int(7,   "TF1 CVD Smoothing Length",   minval = 1, group = g_tf, tooltip = "EMA length used to smooth the per-bar signed delta on TF1. Lower = more responsive, more noise. Default 7 is tuned for scalping on the Trigger TF.")
cvd_smooth_len_tf2 = input.int(10,  "TF2 CVD Smoothing Length",   minval = 1, group = g_tf, tooltip = "EMA length used to smooth the per-bar signed delta on TF2. Default 10 is tuned for day-trading on the Intraday Fast TF.")
cvd_smooth_len_tf3 = input.int(14,  "TF3 CVD Smoothing Length",   minval = 1, group = g_tf, tooltip = "EMA length used to smooth the per-bar signed delta on TF3. Default 14 is Wilder canonical — preserved on TF3 to anchor the RSI sibling parity.")
cvd_smooth_len_tf4 = input.int(14,  "TF4 CVD Smoothing Length",   minval = 1, group = g_tf, tooltip = "EMA length used to smooth the per-bar signed delta on TF4. Default 14 is Wilder canonical — preserved on TF4 to anchor the RSI sibling parity.")
cvd_smooth_len_tf5 = input.int(21,  "TF5 CVD Smoothing Length",   minval = 1, group = g_tf, tooltip = "EMA length used to smooth the per-bar signed delta on TF5. Default 21 is tuned for swing / position trading on the slowest TF.")
cvd_norm_win_tf1   = input.int(30,  "TF1 CVD Normalization Window", minval = 1, group = g_tf, tooltip = "Rolling-max window used to normalize the smoothed CVD into the 0-100 zero-centered score on TF1. Default 30 ≈ 2.5h on a 5m chart. Larger windows = stabler max_abs anchor = less score swing.")
cvd_norm_win_tf2   = input.int(50,  "TF2 CVD Normalization Window", minval = 1, group = g_tf, tooltip = "Rolling-max window for TF2 score normalization. Default 50 ≈ 12.5h on a 15m chart.")
cvd_norm_win_tf3   = input.int(80,  "TF3 CVD Normalization Window", minval = 1, group = g_tf, tooltip = "Rolling-max window for TF3 score normalization. Default 80 ≈ 3.3 days on a 60m chart.")
cvd_norm_win_tf4   = input.int(100, "TF4 CVD Normalization Window", minval = 1, group = g_tf, tooltip = "Rolling-max window for TF4 score normalization. Default 100 ≈ 16 days on a 240m chart.")
cvd_norm_win_tf5   = input.int(150, "TF5 CVD Normalization Window", minval = 1, group = g_tf, tooltip = "Rolling-max window for TF5 score normalization. Default 150 ≈ 5 months on a Daily chart.")

string tf_1 = ""
string tf_2 = ""
string tf_3 = ""
string tf_4 = ""
string tf_5 = ""

if auto_tf
    if timeframe.isseconds or (timeframe.isintraday and timeframe.multiplier <= 5)
        tf_1 := "5",   tf_2 := "15",  tf_3 := "60",  tf_4 := "240", tf_5 := "D"
    else if timeframe.isintraday and timeframe.multiplier <= 15
        tf_1 := "15",  tf_2 := "60",  tf_3 := "240", tf_4 := "D",   tf_5 := "W"
    else if timeframe.isintraday and timeframe.multiplier <= 60
        tf_1 := "60",  tf_2 := "240", tf_3 := "D",   tf_4 := "W",   tf_5 := "M"
    else
        tf_1 := "240", tf_2 := "D",   tf_3 := "W",   tf_4 := "M",   tf_5 := "M"
else
    tf_1 := m_tf1, tf_2 := m_tf2, tf_3 := m_tf3, tf_4 := m_tf4, tf_5 := m_tf5

// ========================================================================================================
// ENGINE
// ========================================================================================================
g_engine = "ENGINE"
dynamic_extremes = input.bool(true, "Dynamic Black Swan Mode",
     group = g_engine,
     tooltip = "OFF (default): Black Swan zones at fixed 80/20 (top 20% / bottom 20% volume extremes). ON: Black Swan zones adapt dynamically to the Master Line's volatility using the canonical Fibonacci 3.85σ proportion.")
lookback_dyn = input.int(50, "Dynamic Channel Lookback",  minval = 10, group = g_engine, tooltip = "Lookback window for highest/lowest of the Master Line. Larger = smoother channel envelope.")
smooth_dyn   = input.int(10, "Dynamic Channel Smoothing", minval = 1,  group = g_engine, tooltip = "EMA smoothing applied to the dynamic channel envelope. Larger = slower response.")
div_lookback = input.int(5,  "Divergence Pivot Lookback", minval = 3, maxval = 20, group = g_engine, tooltip = "Pivot lookback (bars before/after) for classic price↔CVD divergence detection. Lower = more sensitive (smaller pivots), higher = more confirmed (larger pivots). Default 5 matches most community divergence indicators.")

// ========================================================================================================
// VISUALIZATION
// ========================================================================================================
g_visual = "VISUALIZATION"
color_tf1 = input.color(c_up_1, "TF 1 Color (Trigger)",  group = g_visual, inline = "tf12", tooltip = "Color of the TF1 (fastest) CVD directional flow ghost line.")
color_tf2 = input.color(c_up_2, "TF 2 Color (Intraday)", group = g_visual, inline = "tf12", tooltip = "Color of the TF2 CVD directional flow ghost line.")
color_tf3 = input.color(c_up_3, "TF 3 Color (Macro 1)",  group = g_visual, inline = "tf34", tooltip = "Color of the TF3 CVD directional flow ghost line.")
color_tf4 = input.color(c_dn_3, "TF 4 Color (Macro 2)",  group = g_visual, inline = "tf34", tooltip = "Color of the TF4 CVD directional flow ghost line.")
color_tf5 = input.color(c_dn_2, "TF 5 Color (Base)",     group = g_visual, tooltip = "Color of the TF5 CVD directional flow ghost line.")

show_tf1 = input.bool(false, "Show TF1 Ghost Line (Trigger)",  group = g_visual, tooltip = "Hide/show the TF1 CVD directional flow ghost line. The TF still contributes to the Master fusion regardless of this toggle — this is purely visual.")
show_tf2 = input.bool(false, "Show TF2 Ghost Line (Intraday)", group = g_visual, tooltip = "Hide/show the TF2 CVD directional flow ghost line. TF data still feeds the Master.")
show_tf3 = input.bool(false, "Show TF3 Ghost Line (Macro 1)",  group = g_visual, tooltip = "Hide/show the TF3 CVD directional flow ghost line. TF data still feeds the Master.")
show_tf4 = input.bool(false, "Show TF4 Ghost Line (Macro 2)",  group = g_visual, tooltip = "Hide/show the TF4 CVD directional flow ghost line. TF data still feeds the Master.")
show_tf5 = input.bool(false, "Show TF5 Ghost Line (Base)",     group = g_visual, tooltip = "Hide/show the TF5 CVD directional flow ghost line. TF data still feeds the Master.")
ghost_sensitivity = input.float(3.5, "Ghost Fade Sensitivity", minval = 0.5, maxval = 10.0, step = 0.5, group = g_visual, tooltip = "Higher = ghost lines fade more aggressively as they diverge from the Master. Lower = lines stay solid longer. Default 3.5 (dist=20 percentile points → invisible).")

show_master_line    = input.bool(true, "Show Master Line (Rainbow)",             group = g_visual, tooltip = "Plot the weighted Master CVD line, colored by zone using the canonical Rainbow Palette. Oscillates around 50 (neutral); values toward 100 indicate buy pressure, toward 0 indicate sell pressure.")
show_histogram      = input.bool(true, "Show CVD Histogram (background)",          group = g_visual, tooltip = "Plot the Master CVD score as a column histogram extending from the 50 (neutral) centerline. Green columns above 50 = buy-dominant; red columns below 50 = sell-dominant. Sits behind the Master line as a background visualization. Toggle OFF for cleaner pane.")
hist_transp         = input.int(70, "Histogram Transparency", minval = 0, maxval = 100, group = g_visual, tooltip = "Transparency of the CVD histogram (0 = solid, 100 = invisible). Default 70 keeps it as a subtle background element without competing with the Master line.")
show_fills          = input.bool(true, "Show Rainbow Fills",                     group = g_visual, tooltip = "Color the 6 Fibonacci bands around the dynamic channel (Breathing / Alert / Exhaustion, both sides).")
show_blackswan      = input.bool(true, "Show Black Swan Lines + Glow",           group = g_visual, tooltip = "Plot the Black Swan High/Low lines with proximity-based glow. No fill underneath (line + glow only).")
show_dyn_channel    = input.bool(true, "Show Dynamic Channel Envelope",          group = g_visual, tooltip = "Plot the dashed dynamic channel (Up / Mid / Down) that adapts to the Master's recent volatility.")
show_legend_table = input.bool(true, "Show MTF Legend Table",         group = g_visual, tooltip = "Show the MTF Legend Table on the indicator pane. Displays all 5 timeframes with RSI value, trend arrow and zone color, plus the weighted Master row and a divergence summary row. An antenna marker (📡) flags the row whose timeframe matches the chart's native resolution.")
show_div_column   = input.bool(true, "Show Divergence Column",        group = g_visual, tooltip = "Show the 'Div' column in the MTF Legend Table. Displays per-timeframe classic divergence detection: 🔺 = bull (price made lower low + RSI made higher low), 🔻 = bear (price made higher high + RSI made lower high), — = no active divergence. When OFF, divergence cells render empty (column space preserved).")
show_div_chart_line = input.bool(true, "Show Master Divergence Chart Line", group = g_visual, tooltip = "Draw a connecting line between the two pivots that form each Master divergence event, plus a label at the second pivot (🔺 bull / 🔻 bear). Master divergence integrates the weighted view across all 5 timeframes — see the 'Div' column for per-TF breakdown.")
legend_pos        = input.string("Bottom Right", "Legend Table Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = g_visual, tooltip = "Position of the MTF Legend Table on the indicator pane. Four corners available.")
show_div_markers  = input.bool(false, "Show Divergence Event Markers", group = g_visual, tooltip = "Plot directional triangle markers when a Strong or Moderate MTF Divergence is detected. ▼ at the top (Top divergences = potential reversal from highs); ▲ at the bottom (Bottom divergences = potential reversal from lows). Strong = saturated colors (red / green); Moderate = transitional colors (orange / teal). Markers persist while the divergence condition holds. Independent of the Strong Divergence alert toggle in the ALERTS group.")
div_markers_pos   = input.string("Indicator Pane", "Divergence Markers Position", options = ["Indicator Pane", "Chart Overlay"], group = g_visual, tooltip = "Where to render the divergence markers. \"Indicator Pane\" = top/bottom edges of the oscillator pane (next to the Master line); \"Chart Overlay\" = above/below the price bars on the main chart.")
show_static_levels  = input.bool(true, "Show Static Reference Lines (15 / 50 / 85)", group = g_visual, tooltip = "Plot CVD-native directional reference levels at 15, 50 and 85 as subtle dotted guides. 85 = BUY CLIMAX boundary (extreme buy pressure). 50 = neutral (zero directional flow — buyers and sellers balanced). 15 = SELL CLIMAX boundary (extreme sell pressure). Shown by default to anchor the zero-centered scale.")

// ========================================================================================================
// ALERTS
// ========================================================================================================
g_alerts = "ALERTS"
alert_blackswan_high = input.bool(true,  "Alert on Master crossing Black Swan High", group = g_alerts, tooltip = "Fires once per bar when the Master CVD score crosses ABOVE the Black Swan High (85 or dynamic).")
alert_blackswan_low  = input.bool(true,  "Alert on Master crossing Black Swan Low",  group = g_alerts, tooltip = "Fires once per bar when the Master CVD score crosses BELOW the Black Swan Low (15 or dynamic).")
alert_divergence     = input.bool(true,  "Alert on STRONG MTF Divergence",           group = g_alerts, tooltip = "Fires when TF1 and TF5 reach opposite CVD score extremes (TF1 ≥ 70 vs TF5 ≤ 30, or mirrored).")
alert_master_extreme = input.bool(false, "Alert on Master entering Z-Exhaustion zone", group = g_alerts, tooltip = "Fires when the Master CVD score enters a STRONG BUY (red) or STRONG SELL (blue) zone.")
alert_divergence_native = input.bool(true, "Alert on Master Classic Divergence",      group = g_alerts, tooltip = "Fires when classic divergence is detected on the Master line (price↔CVD on the chart timeframe). Master integrates the weighted MTF view, so this alert captures the most synthesized divergence signal. For per-TF breakdown, see the 'Div' column in the Legend Table.")

// ========================================================================================================
// HELPER FUNCTIONS
// ========================================================================================================

// Canonical weighted MTF average (Fibonacci-proportioned weights, peak on macro TF3/TF4)
// Weights: 0.15 / 0.20 / 0.25 / 0.25 / 0.15 — peak weight on macro (TF3 / TF4)
f_avg5_weighted(v1, v2, v3, v4, v5) =>
    w1 = 0.15
    w2 = 0.20
    w3 = 0.25
    w4 = 0.25
    w5 = 0.15
    w_total = (na(v1) ? 0.0 : w1) + (na(v2) ? 0.0 : w2) + (na(v3) ? 0.0 : w3) + (na(v4) ? 0.0 : w4) + (na(v5) ? 0.0 : w5)
    w_total > 0 ? (nz(v1) * w1 + nz(v2) * w2 + nz(v3) * w3 + nz(v4) * w4 + nz(v5) * w5) / w_total : na

// ========================================================================================================
// CVD SCORE ENGINE
//   Returns [score, raw_cvd] tuple. Designed to run inside request.security so the entire
//   calculation happens on the TARGET timeframe's bars.
//
//   clv (Close Location Value): where did price close within the bar's range?
//     +1 = close at high (max bullish), -1 = close at low (max bearish), 0 = mid.
//   delta_raw  = clv × volume = signed directional volume contribution
//   cvd_smooth = EMA(delta_raw, smooth_len) = smoothed directional flow
//   max_abs    = highest(|cvd_smooth|, norm_win) = rolling normalization anchor
//   score      = 50 + (cvd_smooth / max_abs) × 50 = zero-centered 0-100
//
//   Edge cases:
//     high == low (no range): clv = 0 (no directional info)
//     max_abs == 0 (warmup / flat): score = 50 (neutral)
// ========================================================================================================
f_cvd_full(simple int smooth_len, simple int norm_win) =>
    float clv = (high == low) ? 0.0 : ((close - low) - (high - close)) / (high - low)
    float delta_raw = clv * volume
    float cvd_smooth = ta.ema(delta_raw, smooth_len)
    float max_abs = ta.highest(math.abs(cvd_smooth), norm_win)
    float score = max_abs > 0 ? 50.0 + (cvd_smooth / max_abs) * 50.0 : 50.0
    float score_clamped = math.min(100.0, math.max(0.0, score))
    [score_clamped, cvd_smooth]

// Generic fade-by-distance glow (transparency increases with distance from reference)
// Returns transparency: 20 = solid (current at reference) → 95 = invisible (current ≥ range_unit away)
f_calc_glow(float current_value, float reference_value, float range_unit) =>
    int(95 - (math.max(0.0, math.min(1.0, 1.0 - (math.abs(current_value - reference_value) / math.max(range_unit, 0.000001)))) * 75))

// Volume-percentile thermal matrix — maps a 0-100 percentile value to a Rainbow Palette color
// Thresholds use the brand's canonical percentile row classification (62 / 71 / 85 and 38 / 29 / 15, midpoint 50)
f_termal_matrix_cvd(float val) =>
    color c = c_neutral
    if not na(val)
        if val >= 85
            c := c_up_4
        else if val >= 71
            c := c_up_3
        else if val >= 62
            c := c_up_2
        else if val >= 50
            c := c_up_1
        else if val > 38
            c := c_dn_1
        else if val > 29
            c := c_dn_2
        else if val > 15
            c := c_dn_3
        else
            c := c_dn_4
    c

f_position(s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

// Classic price-volume divergence detection (regular only — bear top + bull bottom).
// Returns [bearDiv, bullDiv] booleans. Used inside request.security per-TF
// and directly on the Master series. Uses ta.valuewhen to capture pivot values
// at pivot bars (lookback shift) and compare current vs previous pivots.
f_classic_divergence_cvd(simple int smooth_len, simple int lookback) =>
    // Compute smoothed CVD on the target TF (pivots care about RELATIVE highs/lows,
    // not the 0-100 score; raw cvd_smooth is sufficient and avoids norm-window dependency).
    float clv = (high == low) ? 0.0 : ((close - low) - (high - close)) / (high - low)
    float delta_raw = clv * volume
    float cvd_local = ta.ema(delta_raw, smooth_len)
    bool phFound = not na(ta.pivothigh(cvd_local, lookback, lookback))
    bool plFound = not na(ta.pivotlow(cvd_local, lookback, lookback))

    float cvd_ph_curr   = ta.valuewhen(phFound, cvd_local[lookback], 0)
    float cvd_ph_prev   = ta.valuewhen(phFound, cvd_local[lookback], 1)
    float price_ph_curr = ta.valuewhen(phFound, high[lookback], 0)
    float price_ph_prev = ta.valuewhen(phFound, high[lookback], 1)

    float cvd_pl_curr   = ta.valuewhen(plFound, cvd_local[lookback], 0)
    float cvd_pl_prev   = ta.valuewhen(plFound, cvd_local[lookback], 1)
    float price_pl_curr = ta.valuewhen(plFound, low[lookback], 0)
    float price_pl_prev = ta.valuewhen(plFound, low[lookback], 1)

    bool bearDiv = phFound and not na(cvd_ph_prev) and not na(price_ph_prev) and price_ph_curr > price_ph_prev and cvd_ph_curr < cvd_ph_prev
    bool bullDiv = plFound and not na(cvd_pl_prev) and not na(price_pl_prev) and price_pl_curr < price_pl_prev and cvd_pl_curr > cvd_pl_prev
    [bearDiv, bullDiv]

// Manual TF-string-to-minutes lookup (Pine v6 safe — avoids series/simple type ambiguity of timeframe.in_seconds).
// Returns 0 for unknown TF strings — caller must guard.
f_tf_str_to_minutes(string tf) =>
    int mins = switch tf
        "1"   => 1
        "2"   => 2
        "3"   => 3
        "5"   => 5
        "10"  => 10
        "15"  => 15
        "30"  => 30
        "45"  => 45
        "60"  => 60
        "120" => 120
        "180" => 180
        "240" => 240
        "D"   => 1440
        "1D"  => 1440
        "W"   => 10080
        "1W"  => 10080
        "M"   => 43200
        "1M"  => 43200
        => 0
    mins

// Geometric weighted mean of the 5 TF resolutions, in minutes.
// Same weights as Master fusion (0.15/0.20/0.25/0.25/0.15). Returns na if any TF unknown.
f_master_effective_tf(string t1, string t2, string t3, string t4, string t5) =>
    int m1 = f_tf_str_to_minutes(t1)
    int m2 = f_tf_str_to_minutes(t2)
    int m3 = f_tf_str_to_minutes(t3)
    int m4 = f_tf_str_to_minutes(t4)
    int m5 = f_tf_str_to_minutes(t5)
    float result = na
    if m1 > 0 and m2 > 0 and m3 > 0 and m4 > 0 and m5 > 0
        float log_sum = 0.15 * math.log(m1) + 0.20 * math.log(m2) + 0.25 * math.log(m3) + 0.25 * math.log(m4) + 0.15 * math.log(m5)
        result := math.exp(log_sum)
    result

// Formats minutes (float) → human label. Returns "?" for na input.
//   5  → "5m"   |  60 → "1h"  |  71.5 → "1h11m"  |  1440 → "1d"
f_format_minutes_to_label(float mins) =>
    string result = "?"
    if not na(mins)
        if mins < 1
            result := "<1m"
        else if mins < 60
            result := str.tostring(int(mins)) + "m"
        else if mins < 1440
            int hours = int(mins / 60)
            int rem = int(mins) % 60
            result := rem > 0 ? str.tostring(hours) + "h" + str.tostring(rem) + "m" : str.tostring(hours) + "h"
        else
            float days = mins / 1440.0
            result := str.tostring(math.round(days, 1)) + "d"
    result

// Compact number formatter for the Raw CVD column.
// Returns "+1.2M", "-450K", "+2.3B", "0" etc. Sign indicates buy(+) / sell(-).
// Handles na input by returning "—".
f_format_compact(float val) =>
    string result = "—"
    if not na(val)
        float abs_val = math.abs(val)
        string sign = val >= 0 ? "+" : "-"
        if abs_val >= 1e9
            result := sign + str.tostring(abs_val / 1e9, "#.0") + "B"
        else if abs_val >= 1e6
            result := sign + str.tostring(abs_val / 1e6, "#.0") + "M"
        else if abs_val >= 1e3
            result := sign + str.tostring(abs_val / 1e3, "#.0") + "K"
        else
            result := sign + str.tostring(abs_val, "#")
    result

// ========================================================================================================
// LOCALIZED STRINGS (Multilingual pattern — EN/PT/ES/RU/ZH coverage)
// ========================================================================================================

// --- HUD: title (merged full-width header) ---
var string s_hud_title        = _l=="PT"?"📊 Sincronia MTF CVD"                   :_l=="ES"?"📊 Sincronía MTF CVD"                   :_l=="RU"?"📊 MTF CVD Синхрония"              :_l=="ZH"?"📊 MTF CVD 同步"                      :"📊 MTF CVD Synchrony"

// --- HUD: status row ---
var string s_aligned          = _l=="PT"?"✅ Alinhado"                            :_l=="ES"?"✅ Alineado"                            :_l=="RU"?"✅ Согласовано"                  :_l=="ZH"?"✅ 一致"                              :"✅ Aligned"
var string s_div_strong_top   = _l=="PT"?"🔀 DIVERGÊNCIA FORTE (Topo)"            :_l=="ES"?"🔀 DIVERGENCIA FUERTE (Cima)"           :_l=="RU"?"🔀 СИЛЬНАЯ ДИВЕРГЕНЦИЯ (Верх)"  :_l=="ZH"?"🔀 强背离（顶部）"                       :"🔀 STRONG DIVERGENCE (Top)"
var string s_div_strong_bot   = _l=="PT"?"🔀 DIVERGÊNCIA FORTE (Fundo)"           :_l=="ES"?"🔀 DIVERGENCIA FUERTE (Bajo)"           :_l=="RU"?"🔀 СИЛЬНАЯ ДИВЕРГЕНЦИЯ (Низ)"   :_l=="ZH"?"🔀 强背离（底部）"                       :"🔀 STRONG DIVERGENCE (Bottom)"
var string s_div_mod_top      = _l=="PT"?"⚡ Divergência Moderada (Topo)"         :_l=="ES"?"⚡ Divergencia Moderada (Cima)"          :_l=="RU"?"⚡ Умеренная дивергенция (Верх)" :_l=="ZH"?"⚡ 中度背离（顶部）"                      :"⚡ Moderate Divergence (Top)"
var string s_div_mod_bot      = _l=="PT"?"⚡ Divergência Moderada (Fundo)"        :_l=="ES"?"⚡ Divergencia Moderada (Bajo)"          :_l=="RU"?"⚡ Умеренная дивергенция (Низ)"  :_l=="ZH"?"⚡ 中度背离（底部）"                      :"⚡ Moderate Divergence (Bottom)"


// --- Alert prefixes (Black Swan crossings) ---
var string s_al_bs_high_pre   = _l=="PT"?"🌈 MTF CVD — Master cruzou ACIMA do Black Swan Alto ("      :_l=="ES"?"🌈 MTF CVD — Master cruzó ARRIBA del Black Swan Alto ("       :_l=="RU"?"🌈 MTF CVD — Master пересёк ВВЕРХ Black Swan High ("        :_l=="ZH"?"🌈 MTF CVD — Master 向上突破 Black Swan 高位 ("                 :"🌈 MTF CVD — Master crossed ABOVE Black Swan High ("
var string s_al_bs_low_pre    = _l=="PT"?"🌈 MTF CVD — Master cruzou ABAIXO do Black Swan Baixo ("    :_l=="ES"?"🌈 MTF CVD — Master cruzó ABAJO del Black Swan Bajo ("       :_l=="RU"?"🌈 MTF CVD — Master пересёк ВНИЗ Black Swan Low ("          :_l=="ZH"?"🌈 MTF CVD — Master 向下突破 Black Swan 低位 ("                 :"🌈 MTF CVD — Master crossed BELOW Black Swan Low ("
var string s_al_bs_mid        = _l=="PT"?"). Master CVD: "                                             :_l=="ES"?"). Master CVD: "                                               :_l=="RU"?"). Master CVD: "                                               :_l=="ZH"?"）。Master CVD："                                               :"). Master CVD: "

// --- Alert prefixes (Strong MTF Divergence) ---
var string s_al_div_pre       = _l=="PT"?"🔀 MTF CVD — Divergência MTF FORTE ("                       :_l=="ES"?"🔀 MTF CVD — Divergencia MTF FUERTE ("                         :_l=="RU"?"🔀 MTF CVD — СИЛЬНАЯ MTF дивергенция ("                       :_l=="ZH"?"🔀 MTF CVD — 强 MTF 背离("                                     :"🔀 MTF CVD — STRONG MTF Divergence ("
var string s_al_div_top       = _l=="PT"?"Topo"                                                     :_l=="ES"?"Cima"                                                       :_l=="RU"?"Верх"                                                       :_l=="ZH"?"顶部"                                                       :"Top"
var string s_al_div_bottom    = _l=="PT"?"Fundo"                                                    :_l=="ES"?"Bajo"                                                       :_l=="RU"?"Низ"                                                        :_l=="ZH"?"底部"                                                       :"Bottom"
var string s_al_div_tf1       = _l=="PT"?"). TF1: "                                                 :_l=="ES"?"). TF1: "                                                   :_l=="RU"?"). TF1: "                                                   :_l=="ZH"?"）。TF1："                                                    :"). TF1: "
var string s_al_div_tf5       = _l=="PT"?" | TF5: "                                                 :_l=="ES"?" | TF5: "                                                   :_l=="RU"?" | TF5: "                                                   :_l=="ZH"?" | TF5："                                                     :" | TF5: "

// --- Alert prefixes (Z-Exhaustion zone entries) ---
var string s_al_red_pre       = _l=="PT"?"💥 MTF CVD — Master entrou na zona STRONG BUY ("            :_l=="ES"?"💥 MTF CVD — Master entró en la zona STRONG BUY ("              :_l=="RU"?"💥 MTF CVD — Master вошёл в зону STRONG BUY ("                :_l=="ZH"?"💥 MTF CVD — Master 进入 STRONG BUY 区 ("                          :"💥 MTF CVD — Master entered STRONG BUY zone ("
var string s_al_blue_pre      = _l=="PT"?"🧊 MTF CVD — Master entrou na zona STRONG SELL ("           :_l=="ES"?"🧊 MTF CVD — Master entró en la zona STRONG SELL ("             :_l=="RU"?"🧊 MTF CVD — Master вошёл в зону STRONG SELL ("               :_l=="ZH"?"🧊 MTF CVD — Master 进入 STRONG SELL 区 ("                         :"🧊 MTF CVD — Master entered STRONG SELL zone ("
var string s_al_zone_close    = _l=="PT"?")"                                                        :_l=="ES"?")"                                                          :_l=="RU"?")"                                                          :_l=="ZH"?"）"                                                          :")"

// --- Alert prefixes (Master Classic Divergence — price ↔ volume) ---
var string s_al_div_master_bear_pre = _l=="PT"?"🔻 MTF CVD — Divergência CLÁSSICA Bear no Master (preço↑ + CVD↓). Master CVD: "          :_l=="ES"?"🔻 MTF CVD — Divergencia CLÁSICA Bear en Master (precio↑ + CVD↓). Master CVD: "          :_l=="RU"?"🔻 MTF CVD — КЛАССИЧЕСКАЯ медвежья дивергенция Master (цена↑ + CVD↓). Master CVD: "          :_l=="ZH"?"🔻 MTF CVD — Master 经典看跌背离（价格↑ + CVD↓）。Master CVD："                                       :"🔻 MTF CVD — CLASSIC Bear Divergence on Master (price↑ + CVD↓). Master CVD: "
var string s_al_div_master_bull_pre = _l=="PT"?"🔺 MTF CVD — Divergência CLÁSSICA Bull no Master (preço↓ + CVD↑). Master CVD: "          :_l=="ES"?"🔺 MTF CVD — Divergencia CLÁSICA Bull en Master (precio↓ + CVD↑). Master CVD: "          :_l=="RU"?"🔺 MTF CVD — КЛАССИЧЕСКАЯ бычья дивергенция Master (цена↓ + CVD↑). Master CVD: "           :_l=="ZH"?"🔺 MTF CVD — Master 经典看涨背离（价格↓ + CVD↑）。Master CVD："                                       :"🔺 MTF CVD — CLASSIC Bull Divergence on Master (price↓ + CVD↑). Master CVD: "
var string s_div_chart_label_master = _l=="PT"?" Master"                                            :_l=="ES"?" Master"                                            :_l=="RU"?" Master"                                            :_l=="ZH"?" Master"                                            :" Master"

// --- Legend Table column headers (added v1.3) ---
var string s_hdr_timeframe = _l=="PT"?"Tempo Gráfico"              :_l=="ES"?"Marco Temporal"             :_l=="RU"?"Тайм-фрейм"                :_l=="ZH"?"时间框架"                          :"Timeframe"
var string s_hdr_value     = _l=="PT"?"Valor"                      :_l=="ES"?"Valor"                      :_l=="RU"?"Значение"                  :_l=="ZH"?"数值"                              :"Value"
var string s_hdr_trend     = _l=="PT"?"Tendência"                  :_l=="ES"?"Tendencia"                  :_l=="RU"?"Тренд"                     :_l=="ZH"?"趋势"                              :"Trend"
var string s_hdr_div       = _l=="PT"?"Div"                        :_l=="ES"?"Div"                        :_l=="RU"?"Див"                       :_l=="ZH"?"背离"                              :"Div"
var string s_hdr_raw       = _l=="PT"?"Fluxo"                      :_l=="ES"?"Flujo"                      :_l=="RU"?"Поток"                     :_l=="ZH"?"流量"                              :"Raw Flow"
var string s_hdr_state     = _l=="PT"?"Estado"                     :_l=="ES"?"Estado"                     :_l=="RU"?"Состояние"                 :_l=="ZH"?"状态"                              :"State"

// --- CVD directional state names (used by f_state_name_cvd + State column in Legend Table) ---
var string s_state_buy_climax    = _l=="PT"?"CLÍMAX C."               :_l=="ES"?"CLÍMAX C."                 :_l=="RU"?"ПИК ПОК."                  :_l=="ZH"?"买盘高潮"                          :"BUY CLIMAX"
var string s_state_strong_buy    = _l=="PT"?"COMPRA F."               :_l=="ES"?"COMPRA F."                 :_l=="RU"?"СИЛ. ПОК."                 :_l=="ZH"?"强买"                              :"STRONG BUY"
var string s_state_buy_pressure  = _l=="PT"?"PRESSÃO C."              :_l=="ES"?"PRESIÓN C."                :_l=="RU"?"ДАВЛ. ПОК."                :_l=="ZH"?"买压"                              :"BUY PRESS."
var string s_state_balanced      = _l=="PT"?"EQUILÍBRIO"              :_l=="ES"?"EQUILIBRIO"                :_l=="RU"?"БАЛАНС"                    :_l=="ZH"?"平衡"                              :"BALANCED"
var string s_state_sell_pressure = _l=="PT"?"PRESSÃO V."              :_l=="ES"?"PRESIÓN V."                :_l=="RU"?"ДАВЛ. ПРОД."               :_l=="ZH"?"卖压"                              :"SELL PRESS."
var string s_state_strong_sell   = _l=="PT"?"VENDA F."                :_l=="ES"?"VENTA F."                  :_l=="RU"?"СИЛ. ПРОД."                :_l=="ZH"?"强卖"                              :"STRONG SELL"
var string s_state_sell_climax   = _l=="PT"?"CLÍMAX V."               :_l=="ES"?"CLÍMAX V."                 :_l=="RU"?"ПИК ПРОД."                 :_l=="ZH"?"卖盘高潮"                          :"SELL CLIMAX"

// ========================================================================================================
// State name resolver — maps zero-centered CVD score to directional state name string.
// Declared AFTER the multilang block (references s_state_* — Pine v6 top-down parsing).
// CVD-native vocabulary (directional, not effort/drought like Volume sibling):
//   >= 85  -> BUY CLIMAX      29-38 -> SELL PRESSURE
//   71-85  -> STRONG BUY      15-29 -> STRONG SELL
//   62-71  -> BUY PRESSURE    <= 15 -> SELL CLIMAX
//   38-62  -> BALANCED        na    -> "—"
f_state_name_cvd(float val) =>
    string result = "—"
    if not na(val)
        if val >= 85
            result := s_state_buy_climax
        else if val >= 71
            result := s_state_strong_buy
        else if val >= 62
            result := s_state_buy_pressure
        else if val > 38
            result := s_state_balanced
        else if val > 29
            result := s_state_sell_pressure
        else if val > 15
            result := s_state_strong_sell
        else
            result := s_state_sell_climax
    result

// ========================================================================================================
// MTF CVD FETCH (5 independent timeframes — lookahead_off, anti-repaint)
//   Per-TF length resolution: if vol_len_tfN is 0, inherit from vol_length_default;
//   otherwise use the override. Computed once per bar.
// ========================================================================================================

[cvd_tf1, raw_tf1] = request.security(syminfo.tickerid, tf_1, f_cvd_full(cvd_smooth_len_tf1, cvd_norm_win_tf1), lookahead = barmerge.lookahead_off)
[cvd_tf2, raw_tf2] = request.security(syminfo.tickerid, tf_2, f_cvd_full(cvd_smooth_len_tf2, cvd_norm_win_tf2), lookahead = barmerge.lookahead_off)
[cvd_tf3, raw_tf3] = request.security(syminfo.tickerid, tf_3, f_cvd_full(cvd_smooth_len_tf3, cvd_norm_win_tf3), lookahead = barmerge.lookahead_off)
[cvd_tf4, raw_tf4] = request.security(syminfo.tickerid, tf_4, f_cvd_full(cvd_smooth_len_tf4, cvd_norm_win_tf4), lookahead = barmerge.lookahead_off)
[cvd_tf5, raw_tf5] = request.security(syminfo.tickerid, tf_5, f_cvd_full(cvd_smooth_len_tf5, cvd_norm_win_tf5), lookahead = barmerge.lookahead_off)


// ========================================================================================================
// CLASSIC DIVERGENCE DETECTION (per-TF — price vs CVD on the SAME timeframe)
//   Different from existing MTF Divergence (TF1-vs-TF5 CVD score alignment).
//   Each TF runs its own pivot detection via request.security; returned booleans
//   indicate bear (top) or bull (bottom) regular divergence currently active on that TF.
// ========================================================================================================
[bear_div_tf1, bull_div_tf1] = request.security(syminfo.tickerid, tf_1, f_classic_divergence_cvd(cvd_smooth_len_tf1, div_lookback), lookahead = barmerge.lookahead_off)
[bear_div_tf2, bull_div_tf2] = request.security(syminfo.tickerid, tf_2, f_classic_divergence_cvd(cvd_smooth_len_tf2, div_lookback), lookahead = barmerge.lookahead_off)
[bear_div_tf3, bull_div_tf3] = request.security(syminfo.tickerid, tf_3, f_classic_divergence_cvd(cvd_smooth_len_tf3, div_lookback), lookahead = barmerge.lookahead_off)
[bear_div_tf4, bull_div_tf4] = request.security(syminfo.tickerid, tf_4, f_classic_divergence_cvd(cvd_smooth_len_tf4, div_lookback), lookahead = barmerge.lookahead_off)
[bear_div_tf5, bull_div_tf5] = request.security(syminfo.tickerid, tf_5, f_classic_divergence_cvd(cvd_smooth_len_tf5, div_lookback), lookahead = barmerge.lookahead_off)

// ========================================================================================================
// MASTER LINE (weighted CVD score fusion — clamped to 0–100)
// ========================================================================================================
float cvd_master = math.max(math.min(nz(f_avg5_weighted(cvd_tf1, cvd_tf2, cvd_tf3, cvd_tf4, cvd_tf5), 50.0), 100.0), 0.0)
float raw_master = nz(f_avg5_weighted(raw_tf1, raw_tf2, raw_tf3, raw_tf4, raw_tf5), 0.0)

// Master classic divergence detection (no request.security — uses chart-TF price + Master Volume series directly).
//   Detected on the current chart resolution. Used as fallback when chart TF doesn't match any of the 5 user-selected TFs.
bool ph_master_found = not na(ta.pivothigh(cvd_master, div_lookback, div_lookback))
bool pl_master_found = not na(ta.pivotlow(cvd_master,  div_lookback, div_lookback))

float vol_master_ph_curr   = ta.valuewhen(ph_master_found, cvd_master[div_lookback], 0)
float vol_master_ph_prev   = ta.valuewhen(ph_master_found, cvd_master[div_lookback], 1)
float price_master_ph_curr = ta.valuewhen(ph_master_found, high[div_lookback], 0)
float price_master_ph_prev = ta.valuewhen(ph_master_found, high[div_lookback], 1)

float vol_master_pl_curr   = ta.valuewhen(pl_master_found, cvd_master[div_lookback], 0)
float vol_master_pl_prev   = ta.valuewhen(pl_master_found, cvd_master[div_lookback], 1)
float price_master_pl_curr = ta.valuewhen(pl_master_found, low[div_lookback], 0)
float price_master_pl_prev = ta.valuewhen(pl_master_found, low[div_lookback], 1)

bool bear_div_master = ph_master_found and not na(vol_master_ph_prev) and not na(price_master_ph_prev) and price_master_ph_curr > price_master_ph_prev and vol_master_ph_curr < vol_master_ph_prev
bool bull_div_master = pl_master_found and not na(vol_master_pl_prev) and not na(price_master_pl_prev) and price_master_pl_curr < price_master_pl_prev and vol_master_pl_curr > vol_master_pl_prev

// Bar indices of Master pivots (needed for line.new chart visual — current + previous pivot bars).
int master_bar_ph_curr = ta.valuewhen(ph_master_found, bar_index[div_lookback], 0)
int master_bar_ph_prev = ta.valuewhen(ph_master_found, bar_index[div_lookback], 1)
int master_bar_pl_curr = ta.valuewhen(pl_master_found, bar_index[div_lookback], 0)
int master_bar_pl_prev = ta.valuewhen(pl_master_found, bar_index[div_lookback], 1)

// Master effective TF (geometric weighted mean of the 5 TFs) — shown in the Master row label.
float master_eff_mins  = f_master_effective_tf(tf_1, tf_2, tf_3, tf_4, tf_5)
string master_eff_label = f_format_minutes_to_label(master_eff_mins)

// ========================================================================================================
// CHART VISUAL — Master Volume Divergence (line + label)
//   Drawn on the indicator pane only. Master is the integrated MTF view, so its divergence captures the
//   "average" cross-TF signal. For per-TF breakdown, the Legend Table 'Div' column shows each TF separately.
//   Anti-spam: a divergence triggers ONE line + label on the bar it's confirmed.
//   History: bounded by indicator() max_lines_count / max_labels_count (500 each — ample for ~50 events).
// ========================================================================================================
if show_div_chart_line and bear_div_master and not na(master_bar_ph_prev)
    line.new(x1 = master_bar_ph_prev, y1 = vol_master_ph_prev, x2 = master_bar_ph_curr, y2 = vol_master_ph_curr, color = color.new(c_up_3, 30), width = 2, style = line.style_solid)
    label.new(x = master_bar_ph_curr, y = vol_master_ph_curr, text = "🔻 Bear Div" + s_div_chart_label_master, color = color.new(c_up_3, 20), textcolor = color.white, style = label.style_label_down, size = size.small)

if show_div_chart_line and bull_div_master and not na(master_bar_pl_prev)
    line.new(x1 = master_bar_pl_prev, y1 = vol_master_pl_prev, x2 = master_bar_pl_curr, y2 = vol_master_pl_curr, color = color.new(c_dn_1, 30), width = 2, style = line.style_solid)
    label.new(x = master_bar_pl_curr, y = vol_master_pl_curr, text = "🔺 Bull Div" + s_div_chart_label_master, color = color.new(c_dn_1, 20), textcolor = color.white, style = label.style_label_up, size = size.small)

// ========================================================================================================
// DYNAMIC CHANNEL (Master CVD volatility envelope)
// ========================================================================================================
float dyn_up  = ta.ema(ta.highest(cvd_master, lookback_dyn), smooth_dyn)
float dyn_dn  = ta.ema(ta.lowest(cvd_master,  lookback_dyn), smooth_dyn)
float dyn_mid = (dyn_up + dyn_dn) / 2.0
float dist_up = math.max(dyn_up - dyn_mid, 1e-10)
float dist_dn = math.max(dyn_mid - dyn_dn, 1e-10)

// ========================================================================================================
// RAINBOW FIBONACCI ZONES (canonical ratios 1.50/1.85/2.75/3.85 — NEVER change; all lines clamped to [0,100] for pane containment)
// ========================================================================================================
fib_breath    = 1.50 / 1.85   // ≈ 0.811
fib_exhaust   = 2.75 / 1.85   // ≈ 1.486
fib_blackswan = 3.85 / 1.85   // ≈ 2.081

float osc_up1 = math.min(100.0, math.max(0.0, dyn_mid + (dist_up * fib_breath)))     // Z-Breathing High (clamped to [0,100])
float osc_up2 = math.min(100.0, math.max(0.0, dyn_up))                                // Z-Alert High (anchor at 1.85σ, clamped to [0,100])
float osc_up3 = math.min(100.0, math.max(0.0, dyn_mid + (dist_up * fib_exhaust)))    // Z-Exhaustion High (clamped to [0,100])
float osc_up4 = math.min(100.0, math.max(0.0, dyn_mid + (dist_up * fib_blackswan)))  // Black Swan High dynamic (clamped to [0,100])

float osc_dn1 = math.min(100.0, math.max(0.0, dyn_mid - (dist_dn * fib_breath)))
float osc_dn2 = math.min(100.0, math.max(0.0, dyn_dn))
float osc_dn3 = math.min(100.0, math.max(0.0, dyn_mid - (dist_dn * fib_exhaust)))
float osc_dn4 = math.min(100.0, math.max(0.0, dyn_mid - (dist_dn * fib_blackswan)))

// ========================================================================================================
// BLACK SWAN — HYBRID MODE (static 80/20 by default, dynamic Fibonacci when toggled)
// ========================================================================================================
float black_swan_high = math.min(100.0, math.max(0.0, dynamic_extremes ? osc_up4 : 80.0))
float black_swan_low  = math.min(100.0, math.max(0.0, dynamic_extremes ? osc_dn4 : 20.0))

// ========================================================================================================
// DIVERGENCE DETECTION (TF1 vs TF5)
// ========================================================================================================
bool div_strong_top      = barstate.isconfirmed and cvd_tf1 >= 70 and cvd_tf5 <= 30
bool div_strong_bottom   = barstate.isconfirmed and cvd_tf1 <= 30 and cvd_tf5 >= 70
bool div_strong          = div_strong_top or div_strong_bottom
bool div_moderate_top    = barstate.isconfirmed and not div_strong and cvd_tf1 >= 65 and cvd_tf5 <= 40
bool div_moderate_bottom = barstate.isconfirmed and not div_strong and cvd_tf1 <= 35 and cvd_tf5 >= 60
bool div_moderate        = div_moderate_top or div_moderate_bottom

// ========================================================================================================
// VISUAL — INVISIBLE REFERENCE PLOTS (for rainbow fills)
// ========================================================================================================
p_mid = plot(dyn_mid, "Dyn Mid (ref)",        display = display.none, editable = false)
p_up1 = plot(osc_up1, "Z-Breathing High Ref", display = display.none, editable = false)
p_up2 = plot(osc_up2, "Z-Alert High Ref",     display = display.none, editable = false)
p_up3 = plot(osc_up3, "Z-Exhaustion High Ref",display = display.none, editable = false)
p_dn1 = plot(osc_dn1, "Z-Breathing Low Ref",  display = display.none, editable = false)
p_dn2 = plot(osc_dn2, "Z-Alert Low Ref",      display = display.none, editable = false)
p_dn3 = plot(osc_dn3, "Z-Exhaustion Low Ref", display = display.none, editable = false)

// ========================================================================================================
// VISUAL — RAINBOW FIBONACCI FILLS (6 bands — NO fill in Black Swan zone, hard rule #6)
// ========================================================================================================
fill(p_mid, p_up1, color = show_fills ? color.new(c_up_1, 92) : na, title = "Z-Breathing High")
fill(p_up1, p_up2, color = show_fills ? color.new(c_up_2, 90) : na, title = "Z-Alert High")
fill(p_up2, p_up3, color = show_fills ? color.new(c_up_3, 88) : na, title = "Z-Exhaustion High")

fill(p_mid, p_dn1, color = show_fills ? color.new(c_dn_1, 92) : na, title = "Z-Breathing Low")
fill(p_dn1, p_dn2, color = show_fills ? color.new(c_dn_2, 90) : na, title = "Z-Alert Low")
fill(p_dn2, p_dn3, color = show_fills ? color.new(c_dn_3, 88) : na, title = "Z-Exhaustion Low")

// ========================================================================================================
// VISUAL — STATIC REFERENCE LEVELS (15 / 50 / 85 — CVD-native directional guides)
// Pine v6 note: hline() requires a const color (no series ternary). We use plot() with a
// const color + dynamic `display` toggle so the user input can show/hide cleanly.
// Color semantics for the zero-centered CVD scale (matches thermal matrix extremes):
//   85 = purple (c_up_4) — BUY CLIMAX boundary (extreme buy pressure)
//   50 = yellow (c_up_1) — neutral (zero directional flow — buyers/sellers balanced)
//   15 = aqua (c_dn_4) — SELL CLIMAX boundary (extreme sell pressure)
// ========================================================================================================
plot(85, "Level 85", color = color.new(c_up_4, 50), linewidth = 1, linestyle = plot.linestyle_dotted, display = show_static_levels ? display.pane + display.price_scale : display.none, editable = false)
plot(50, "Level 50", color = color.new(c_up_1, 50), linewidth = 1, linestyle = plot.linestyle_dotted, display = show_static_levels ? display.pane + display.price_scale : display.none, editable = false)
plot(15, "Level 15", color = color.new(c_dn_4, 50), linewidth = 1, linestyle = plot.linestyle_dotted, display = show_static_levels ? display.pane + display.price_scale : display.none, editable = false)

// Extended-right portion: persistent line objects redrawn at the chart's right edge.
// On the last bar, we set the line's endpoint into the future (bar_index + 500) so it
// projects beyond the price action. Hidden when show_static_levels is OFF.
var line ln_85 = na
var line ln_50 = na
var line ln_15 = na
if barstate.islast
    if not na(ln_85)
        line.delete(ln_85)
    if not na(ln_50)
        line.delete(ln_50)
    if not na(ln_15)
        line.delete(ln_15)
    if show_static_levels
        ln_85 := line.new(bar_index, 85, bar_index + 500, 85, color = color.new(c_up_4, 30), width = 1, style = line.style_dotted, extend = extend.right)
        ln_50 := line.new(bar_index, 50, bar_index + 500, 50, color = color.new(c_up_1, 30), width = 1, style = line.style_dotted, extend = extend.right)
        ln_15 := line.new(bar_index, 15, bar_index + 500, 15, color = color.new(c_dn_4, 30), width = 1, style = line.style_dotted, extend = extend.right)

// ========================================================================================================
// VISUAL — BLACK SWAN HIGH (line + glow, fade by distance to Master, NO fill)
// ========================================================================================================
float glow_range_high = math.max(dist_up, 5.0)
float glow_range_low  = math.max(dist_dn, 5.0)
int   transp_bs_high  = f_calc_glow(cvd_master, black_swan_high, glow_range_high)
int   transp_bs_low   = f_calc_glow(cvd_master, black_swan_low,  glow_range_low)

plot(show_blackswan ? black_swan_high : na, "Black Swan High Glow", color = color.new(c_up_4, transp_bs_high), linewidth = 5, display = display.pane)
plot(show_blackswan ? black_swan_high : na, "Black Swan High Main", color = color.new(c_up_4, math.max(20, transp_bs_high - 20)), linewidth = 1)

// ========================================================================================================
// VISUAL — DYNAMIC CHANNEL (dashed envelope, adapts to Master volatility)
// ========================================================================================================
plot(dyn_up,  "Dyn Channel Up",  color = color.new(c_up_2,    55), linewidth = 1, linestyle = plot.linestyle_dashed, display = show_dyn_channel ? display.pane + display.price_scale : display.none)
plot(dyn_mid, "Dyn Channel Mid", color = color.new(c_neutral, 55), linewidth = 1, linestyle = plot.linestyle_dashed, display = show_dyn_channel ? display.pane + display.price_scale : display.none)
plot(dyn_dn,  "Dyn Channel Dn",  color = color.new(c_dn_2,    55), linewidth = 1, linestyle = plot.linestyle_dashed, display = show_dyn_channel ? display.pane + display.price_scale : display.none)

// ========================================================================================================
// VISUAL — GHOST LINES (5 individual CVD scores, transparency = f(distance to Master))
// Formula:  transp = clamp(20 + dist × ghost_sensitivity, 20, 90)
//   - At dist=0 (perfect alignment): transp=20 (solid).
//   - At dist=(70/ghost_sensitivity) RSI points: transp=90 (invisible).
//   - Default ghost_sensitivity=3.5 ⇒ invisible at ~20 RSI points apart.
// ========================================================================================================
float dist_tf1 = math.abs(cvd_tf1 - cvd_master)
float dist_tf2 = math.abs(cvd_tf2 - cvd_master)
float dist_tf3 = math.abs(cvd_tf3 - cvd_master)
float dist_tf4 = math.abs(cvd_tf4 - cvd_master)
float dist_tf5 = math.abs(cvd_tf5 - cvd_master)

int transp_tf1 = int(math.min(90.0, math.max(20.0, 20.0 + dist_tf1 * ghost_sensitivity)))
int transp_tf2 = int(math.min(90.0, math.max(20.0, 20.0 + dist_tf2 * ghost_sensitivity)))
int transp_tf3 = int(math.min(90.0, math.max(20.0, 20.0 + dist_tf3 * ghost_sensitivity)))
int transp_tf4 = int(math.min(90.0, math.max(20.0, 20.0 + dist_tf4 * ghost_sensitivity)))
int transp_tf5 = int(math.min(90.0, math.max(20.0, 20.0 + dist_tf5 * ghost_sensitivity)))

plot(show_tf1 ? cvd_tf1 : na, "CVD TF 1 (Trigger)",  color = color.new(color_tf1, transp_tf1), linewidth = 1)
plot(show_tf2 ? cvd_tf2 : na, "CVD TF 2 (Intraday)", color = color.new(color_tf2, transp_tf2), linewidth = 1)
plot(show_tf3 ? cvd_tf3 : na, "CVD TF 3 (Macro 1)",  color = color.new(color_tf3, transp_tf3), linewidth = 1)
plot(show_tf4 ? cvd_tf4 : na, "CVD TF 4 (Macro 2)",  color = color.new(color_tf4, transp_tf4), linewidth = 1)
plot(show_tf5 ? cvd_tf5 : na, "CVD TF 5 (Base)",     color = color.new(color_tf5, transp_tf5), linewidth = 1)

// ========================================================================================================
// VISUAL — BLACK SWAN LOW (line + glow, before Master so Master always sits on top)
// ========================================================================================================
plot(show_blackswan ? black_swan_low : na, "Black Swan Low Glow", color = color.new(c_dn_4, transp_bs_low), linewidth = 5, display = display.pane)
plot(show_blackswan ? black_swan_low : na, "Black Swan Low Main", color = color.new(c_dn_4, math.max(20, transp_bs_low - 20)), linewidth = 1)

// ========================================================================================================
// VISUAL — MASTER LINE (rainbow color by zone, plotted LAST so it always sits on top)
// ========================================================================================================
color c_master = f_termal_matrix_cvd(cvd_master)
// ========================================================================================================
// VISUAL — CVD HISTOGRAM (Master score deviation from neutral 50)
//   plot.style_columns with histbase=50 makes columns extend FROM the 50 centerline:
//   UP (green c_dn_1) when buy-dominant, DOWN (red c_up_3) when sell-dominant.
//   High transparency (default 70) keeps it as a background element behind the Master line.
// ========================================================================================================
color hist_color = cvd_master >= 50 ? color.new(c_dn_1, hist_transp) : color.new(c_up_3, hist_transp)
plot(show_histogram ? cvd_master : na, "CVD Histogram", color = hist_color, style = plot.style_columns, histbase = 50, display = display.pane, editable = false)

plot(show_master_line ? cvd_master : na, "CVD Master 🌈", color = c_master, linewidth = 3)

// ========================================================================================================
// DIVERGENCE EVENT MARKERS (Strong + Moderate, dual-position via div_markers_pos input)
// 4 events × 2 positions = 8 plotshapes declared; only the 4 matching the chosen position are active.
// Pine v6 requires location and force_overlay as const literals — dual declaration is the canonical pattern.
//
// Color hierarchy mirrors the Legend Table status row palette:
//   - Strong   top    → c_up_3 (red, saturated)     | Strong   bottom → c_dn_1 (green, saturated)
//   - Moderate top    → c_up_2 (orange, transitional)| Moderate bottom → c_dn_2 (teal, transitional)
//
// Triangle direction signals expected reversal: ▼ = Top (reversal from highs); ▲ = Bottom (reversal from lows).
// Markers persist while the divergence condition holds (mutually exclusive: Strong and Moderate never
// co-fire on the same bar — Moderate has "and not div_strong" guard from v1.0 detection logic).
// ========================================================================================================
bool mk_pane    = div_markers_pos == "Indicator Pane"
bool mk_overlay = div_markers_pos == "Chart Overlay"

// --- Indicator pane variant (location.top / location.bottom) ---
plotshape(show_div_markers and mk_pane and div_strong_top,      title = "Strong Top Divergence (pane)",      location = location.top,    style = shape.triangledown, color = color.new(c_up_3, 20), size = size.small)
plotshape(show_div_markers and mk_pane and div_strong_bottom,   title = "Strong Bottom Divergence (pane)",   location = location.bottom, style = shape.triangleup,   color = color.new(c_dn_1, 20), size = size.small)
plotshape(show_div_markers and mk_pane and div_moderate_top,    title = "Moderate Top Divergence (pane)",    location = location.top,    style = shape.triangledown, color = color.new(c_up_2, 30), size = size.small)
plotshape(show_div_markers and mk_pane and div_moderate_bottom, title = "Moderate Bottom Divergence (pane)", location = location.bottom, style = shape.triangleup,   color = color.new(c_dn_2, 30), size = size.small)

// --- Chart overlay variant (location.abovebar / location.belowbar, force_overlay=true) ---
plotshape(show_div_markers and mk_overlay and div_strong_top,      title = "Strong Top Divergence (chart)",      location = location.abovebar, style = shape.triangledown, color = color.new(c_up_3, 20), size = size.small, force_overlay = true)
plotshape(show_div_markers and mk_overlay and div_strong_bottom,   title = "Strong Bottom Divergence (chart)",   location = location.belowbar, style = shape.triangleup,   color = color.new(c_dn_1, 20), size = size.small, force_overlay = true)
plotshape(show_div_markers and mk_overlay and div_moderate_top,    title = "Moderate Top Divergence (chart)",    location = location.abovebar, style = shape.triangledown, color = color.new(c_up_2, 30), size = size.small, force_overlay = true)
plotshape(show_div_markers and mk_overlay and div_moderate_bottom, title = "Moderate Bottom Divergence (chart)", location = location.belowbar, style = shape.triangleup,   color = color.new(c_dn_2, 30), size = size.small, force_overlay = true)

// ========================================================================================================
// MTF CVD LEGEND TABLE (mini-table inside the indicator pane — force_overlay=false for mobile readability)
// Layout (7 cols × 9 rows):
//   Row 0: merged full-width title (multilingual s_hud_title)
//   Row 1: column headers — [Timeframe (merged 0-1)] | Value | Trend | Div | Pulse | State
//   Row 2-6: per-TF rows — [● TFn + 📡 if chart-native] | TF resolution | CVD score (0-100) | trend arrow ▲/▼/▬ | Div 🔺/🔻/— | Raw flow | State (BUY CLIMAX/.../SELL CLIMAX)
//   Row 7: Master row (cols 0-1 merged: "🌈 Master") | Master CVD score | Master trend arrow | Master Div | Master Raw | Master State
//   Row 8: merged status row (divergence summary, reused from MTF Divergence detection)
//
// Color scheme:
//   - Row 1 (headers): dim text on dim background (subtle hierarchy)
//   - Col 0 (● TFn label): color_tfN (user-configured, matches ghost line)
//   - Col 1 (TF resolution): c_neutral
//   - Col 2 (CVD score 0-100): zone color via f_termal_matrix_cvd(cvd_tfN)
//   - Col 3 (trend arrow): same zone color (visual coupling)
//   - Col 4 (divergence): c_up_3 (red) for bear, c_dn_1 (green) for bull, c_neutral for none
//   - Col 5 (raw flow magnitude): sign-based color (green if buy +, red if sell -)
//   - Col 6 (state name): zone color via f_termal_matrix_cvd(cvd_tfN) — coupled with Value
//   - Master row: entire row in Master zone color
//   - Antenna marker (📡): suffix of col 0 only on the row whose TF == timeframe.period
// ========================================================================================================
var table legend = table.new(f_position(legend_pos), 7, 9, border_width = 1, border_color = color.new(c_neutral, 80), frame_width = 2, frame_color = color.new(c_black, 20), force_overlay = false)

if barstate.islast and show_legend_table
    // --- Zone colors (used for RSI value + trend cell text) ---
    color c_tf1_dot    = f_termal_matrix_cvd(cvd_tf1)
    color c_tf2_dot    = f_termal_matrix_cvd(cvd_tf2)
    color c_tf3_dot    = f_termal_matrix_cvd(cvd_tf3)
    color c_tf4_dot    = f_termal_matrix_cvd(cvd_tf4)
    color c_tf5_dot    = f_termal_matrix_cvd(cvd_tf5)
    color c_master_dot = f_termal_matrix_cvd(cvd_master)

    // --- Antenna marker (📡 if this TF == chart's native resolution) ---
    string current_tf = timeframe.period
    string ant1 = tf_1 == current_tf ? " 📡" : ""
    string ant2 = tf_2 == current_tf ? " 📡" : ""
    string ant3 = tf_3 == current_tf ? " 📡" : ""
    string ant4 = tf_4 == current_tf ? " 📡" : ""
    string ant5 = tf_5 == current_tf ? " 📡" : ""

    // --- Trend arrows (±0.5 deadzone vs previous bar — flicker-resistant) ---
    string trend_tf1    = cvd_tf1    > nz(cvd_tf1[1],    cvd_tf1)    + 0.5 ? "▲" : cvd_tf1    < nz(cvd_tf1[1],    cvd_tf1)    - 0.5 ? "▼" : "▬"
    string trend_tf2    = cvd_tf2    > nz(cvd_tf2[1],    cvd_tf2)    + 0.5 ? "▲" : cvd_tf2    < nz(cvd_tf2[1],    cvd_tf2)    - 0.5 ? "▼" : "▬"
    string trend_tf3    = cvd_tf3    > nz(cvd_tf3[1],    cvd_tf3)    + 0.5 ? "▲" : cvd_tf3    < nz(cvd_tf3[1],    cvd_tf3)    - 0.5 ? "▼" : "▬"
    string trend_tf4    = cvd_tf4    > nz(cvd_tf4[1],    cvd_tf4)    + 0.5 ? "▲" : cvd_tf4    < nz(cvd_tf4[1],    cvd_tf4)    - 0.5 ? "▼" : "▬"
    string trend_tf5    = cvd_tf5    > nz(cvd_tf5[1],    cvd_tf5)    + 0.5 ? "▲" : cvd_tf5    < nz(cvd_tf5[1],    cvd_tf5)    - 0.5 ? "▼" : "▬"
    string trend_master = cvd_master > nz(cvd_master[1], cvd_master) + 0.5 ? "▲" : cvd_master < nz(cvd_master[1], cvd_master) - 0.5 ? "▼" : "▬"

    // --- Divergence summary (reused from v1.5 logic) ---
    string status_txt = s_aligned
    color  status_bg  = color.new(c_neutral, 80)
    color  status_fg  = color.white
    if div_strong_top
        status_txt := s_div_strong_top
        status_bg  := color.new(c_up_3, 50)
    else if div_strong_bottom
        status_txt := s_div_strong_bot
        status_bg  := color.new(c_dn_1, 50)
    else if div_moderate_top
        status_txt := s_div_mod_top
        status_bg  := color.new(c_up_2, 60)
    else if div_moderate_bottom
        status_txt := s_div_mod_bot
        status_bg  := color.new(c_dn_2, 60)

    // === Row 0 — Header (merged 4 cols) ===
    table.merge_cells(legend, 0, 0, 6, 0)

    // Row 1: Column headers (added v1.3)
    table.cell(legend, 0, 1, s_hdr_timeframe, text_color = color.new(c_neutral, 30), text_size = sz_tbl, bgcolor = color.new(c_black, 75), text_halign = text.align_center)
    table.merge_cells(legend, 0, 1, 1, 1)
    table.cell(legend, 2, 1, s_hdr_value,     text_color = color.new(c_neutral, 30), text_size = sz_tbl, bgcolor = color.new(c_black, 75), text_halign = text.align_center)
    table.cell(legend, 3, 1, s_hdr_trend,     text_color = color.new(c_neutral, 30), text_size = sz_tbl, bgcolor = color.new(c_black, 75), text_halign = text.align_center)
    table.cell(legend, 4, 1, s_hdr_div,       text_color = color.new(c_neutral, 30), text_size = sz_tbl, bgcolor = color.new(c_black, 75), text_halign = text.align_center)
    table.cell(legend, 5, 1, s_hdr_raw,     text_color = color.new(c_neutral, 30), text_size = sz_tbl, bgcolor = color.new(c_black, 75), text_halign = text.align_center)
    table.cell(legend, 6, 1, s_hdr_state,     text_color = color.new(c_neutral, 30), text_size = sz_tbl, bgcolor = color.new(c_black, 75), text_halign = text.align_center)
    table.cell(legend, 0, 0, s_hud_title,
         text_color = color.new(c_dn_4, 0), text_size = sz_lbl,
         bgcolor = color.new(c_black, 10), text_halign = text.align_center)

    // === Row 1 — TF1 ===
    table.cell(legend, 0, 2, "● TF1" + ant1,         text_color = color_tf1,                text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_left)
    table.cell(legend, 1, 2, tf_1,                    text_color = color.new(c_neutral, 20), text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)
    table.cell(legend, 2, 2, str.tostring(cvd_tf1, "#.0"), text_color = c_tf1_dot,           text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_right)
    table.cell(legend, 3, 2, trend_tf1,               text_color = c_tf1_dot,                text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)
    table.cell(legend, 4, 2, show_div_column ? (bear_div_tf1 ? "🔻" : bull_div_tf1 ? "🔺" : "—") : "",  text_color = bear_div_tf1 ? c_up_3 : bull_div_tf1 ? c_dn_1 : c_neutral,  text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)
    table.cell(legend, 5, 2, f_format_compact(raw_tf1), text_color = raw_tf1 >= 0 ? c_dn_1 : c_up_3, text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_right)
    table.cell(legend, 6, 2, f_state_name_cvd(cvd_tf1), text_color = f_termal_matrix_cvd(cvd_tf1), text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)

    // === Row 2 — TF2 ===
    table.cell(legend, 0, 3, "● TF2" + ant2,         text_color = color_tf2,                text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_left)
    table.cell(legend, 1, 3, tf_2,                    text_color = color.new(c_neutral, 20), text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_center)
    table.cell(legend, 2, 3, str.tostring(cvd_tf2, "#.0"), text_color = c_tf2_dot,           text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_right)
    table.cell(legend, 3, 3, trend_tf2,               text_color = c_tf2_dot,                text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_center)
    table.cell(legend, 4, 3, show_div_column ? (bear_div_tf2 ? "🔻" : bull_div_tf2 ? "🔺" : "—") : "",  text_color = bear_div_tf2 ? c_up_3 : bull_div_tf2 ? c_dn_1 : c_neutral,  text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_center)
    table.cell(legend, 5, 3, f_format_compact(raw_tf2), text_color = raw_tf2 >= 0 ? c_dn_1 : c_up_3, text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_right)
    table.cell(legend, 6, 3, f_state_name_cvd(cvd_tf2), text_color = f_termal_matrix_cvd(cvd_tf2), text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_center)

    // === Row 3 — TF3 ===
    table.cell(legend, 0, 4, "● TF3" + ant3,         text_color = color_tf3,                text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_left)
    table.cell(legend, 1, 4, tf_3,                    text_color = color.new(c_neutral, 20), text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)
    table.cell(legend, 2, 4, str.tostring(cvd_tf3, "#.0"), text_color = c_tf3_dot,           text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_right)
    table.cell(legend, 3, 4, trend_tf3,               text_color = c_tf3_dot,                text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)
    table.cell(legend, 4, 4, show_div_column ? (bear_div_tf3 ? "🔻" : bull_div_tf3 ? "🔺" : "—") : "",  text_color = bear_div_tf3 ? c_up_3 : bull_div_tf3 ? c_dn_1 : c_neutral,  text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)
    table.cell(legend, 5, 4, f_format_compact(raw_tf3), text_color = raw_tf3 >= 0 ? c_dn_1 : c_up_3, text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_right)
    table.cell(legend, 6, 4, f_state_name_cvd(cvd_tf3), text_color = f_termal_matrix_cvd(cvd_tf3), text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)

    // === Row 4 — TF4 ===
    table.cell(legend, 0, 5, "● TF4" + ant4,         text_color = color_tf4,                text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_left)
    table.cell(legend, 1, 5, tf_4,                    text_color = color.new(c_neutral, 20), text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_center)
    table.cell(legend, 2, 5, str.tostring(cvd_tf4, "#.0"), text_color = c_tf4_dot,           text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_right)
    table.cell(legend, 3, 5, trend_tf4,               text_color = c_tf4_dot,                text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_center)
    table.cell(legend, 4, 5, show_div_column ? (bear_div_tf4 ? "🔻" : bull_div_tf4 ? "🔺" : "—") : "",  text_color = bear_div_tf4 ? c_up_3 : bull_div_tf4 ? c_dn_1 : c_neutral,  text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_center)
    table.cell(legend, 5, 5, f_format_compact(raw_tf4), text_color = raw_tf4 >= 0 ? c_dn_1 : c_up_3, text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_right)
    table.cell(legend, 6, 5, f_state_name_cvd(cvd_tf4), text_color = f_termal_matrix_cvd(cvd_tf4), text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_center)

    // === Row 5 — TF5 ===
    table.cell(legend, 0, 6, "● TF5" + ant5,         text_color = color_tf5,                text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_left)
    table.cell(legend, 1, 6, tf_5,                    text_color = color.new(c_neutral, 20), text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)
    table.cell(legend, 2, 6, str.tostring(cvd_tf5, "#.0"), text_color = c_tf5_dot,           text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_right)
    table.cell(legend, 3, 6, trend_tf5,               text_color = c_tf5_dot,                text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)
    table.cell(legend, 4, 6, show_div_column ? (bear_div_tf5 ? "🔻" : bull_div_tf5 ? "🔺" : "—") : "",  text_color = bear_div_tf5 ? c_up_3 : bull_div_tf5 ? c_dn_1 : c_neutral,  text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)
    table.cell(legend, 5, 6, f_format_compact(raw_tf5), text_color = raw_tf5 >= 0 ? c_dn_1 : c_up_3, text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_right)
    table.cell(legend, 6, 6, f_state_name_cvd(cvd_tf5), text_color = f_termal_matrix_cvd(cvd_tf5), text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)

    // === Row 6 — Master (cols 0-1 merged) ===
    table.merge_cells(legend, 0, 7, 1, 7)
    table.cell(legend, 0, 7, "🌈 Master (~" + master_eff_label + ")", text_color = c_master_dot, text_size = sz_tbl, bgcolor = color.new(c_black, 60), text_halign = text.align_left)
    table.cell(legend, 2, 7, str.tostring(cvd_master, "#.0"), text_color = c_master_dot, text_size = sz_tbl, bgcolor = color.new(c_black, 60), text_halign = text.align_right)
    table.cell(legend, 3, 7, trend_master,            text_color = c_master_dot, text_size = sz_tbl, bgcolor = color.new(c_black, 60), text_halign = text.align_center)
    table.cell(legend, 4, 7, show_div_column ? (bear_div_master ? "🔻" : bull_div_master ? "🔺" : "—") : "",  text_color = bear_div_master ? c_up_3 : bull_div_master ? c_dn_1 : c_master_dot,  text_size = sz_tbl, bgcolor = color.new(c_black, 60), text_halign = text.align_center)
    table.cell(legend, 5, 7, f_format_compact(raw_master), text_color = raw_master >= 0 ? c_dn_1 : c_up_3, text_size = sz_tbl, bgcolor = color.new(c_black, 60), text_halign = text.align_right)
    table.cell(legend, 6, 7, f_state_name_cvd(cvd_master), text_color = f_termal_matrix_cvd(cvd_master), text_size = sz_tbl, bgcolor = color.new(c_black, 60), text_halign = text.align_center)

    // === Row 7 — Divergence summary (merged 4 cols) ===
    table.merge_cells(legend, 0, 8, 6, 8)
    table.cell(legend, 0, 8, status_txt,
         text_color = status_fg, text_size = sz_lbl,
         bgcolor = status_bg, text_halign = text.align_center)

// ========================================================================================================
// ALERTS (all gated by barstate.isconfirmed — anti-flicker, see hard rule #7)
// ========================================================================================================
bool cross_up_bs    = ta.crossover(cvd_master, black_swan_high) and barstate.isconfirmed
bool cross_dn_bs    = ta.crossunder(cvd_master, black_swan_low) and barstate.isconfirmed
bool entered_red    = ta.crossover(cvd_master, osc_up3)  and barstate.isconfirmed
bool entered_blue   = ta.crossunder(cvd_master, osc_dn3) and barstate.isconfirmed
bool new_div_strong = div_strong and not div_strong[1]

if cross_up_bs and alert_blackswan_high
    alert(s_al_bs_high_pre + str.tostring(black_swan_high, "#.0") + s_al_bs_mid + str.tostring(cvd_master, "#.0"), alert.freq_once_per_bar)

if cross_dn_bs and alert_blackswan_low
    alert(s_al_bs_low_pre + str.tostring(black_swan_low, "#.0") + s_al_bs_mid + str.tostring(cvd_master, "#.0"), alert.freq_once_per_bar)

if new_div_strong and alert_divergence
    string dir_txt = div_strong_top ? s_al_div_top : s_al_div_bottom
    alert(s_al_div_pre + dir_txt + s_al_div_tf1 + str.tostring(cvd_tf1, "#.0") + s_al_div_tf5 + str.tostring(cvd_tf5, "#.0"), alert.freq_once_per_bar)

if entered_red and alert_master_extreme
    alert(s_al_red_pre + str.tostring(cvd_master, "#.0") + s_al_zone_close, alert.freq_once_per_bar)

if entered_blue and alert_master_extreme
    alert(s_al_blue_pre + str.tostring(cvd_master, "#.0") + s_al_zone_close, alert.freq_once_per_bar)

if bear_div_master and alert_divergence_native
    alert(s_al_div_master_bear_pre + str.tostring(cvd_master, "#.0"), alert.freq_once_per_bar)

if bull_div_master and alert_divergence_native
    alert(s_al_div_master_bull_pre + str.tostring(cvd_master, "#.0"), alert.freq_once_per_bar)

// Billboard alertcondition (UX hint — instructs users on alert setup workflow)
alertcondition(false, title = "HOW TO SETUP ALERTS (READ)", message = "Please select 'Any alert() function call' in the condition menu. You can filter which alerts you receive inside the Indicator Settings (Gear Icon).")
````
