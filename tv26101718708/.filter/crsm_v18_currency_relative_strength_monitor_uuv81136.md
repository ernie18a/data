# CRSM v1.8 - Currency Relative Strength Monitor

- url: https://www.tradingview.com/script/UUV81136-CRSM-v1-8-Currency-Relative-Strength-Monitor/
- type: indicator
- pine_id: PUB;42879b3fa08447ad88e944d2c1c84e3c
- version: 1.0

## Description

CRSM ranks all 28 major FX pairs by activity in real time and surfaces the top 10, so you can focus on the 2–3 worth watching closely. It works by measuring each currency's strength against the trade-weighted basket of eight majors — turning a 28-chart problem into a one-glance dashboard.

This is a dashboard, not a signal generator. It narrows your attention; the decisions to enter, where to place stops, and where to target stay your call, made on the actual pair chart with whatever method you trust.

## How It Works

Every bar, CRSM does three things.

**Measures returns.** For each of the eight currencies, it computes the log return against USD over a lookback window. Log returns are additive across cross rates — log(EUR/JPY) move equals log(EUR/USD) move plus log(USD/JPY) move — so seven USD-anchored prices fully describe all 28 pair returns.

**Centres against the basket.** The eight return values are averaged using BIS turnover-share weighting (USD heaviest, EUR second, NZD lightest). Each currency's return is centred against that average. This puts USD on equal footing — when USD is rallying broadly, USD shows up as strong rather than being the implicit baseline.

**Standardises.** Three sub-measurements — raw momentum, volatility-adjusted momentum, and rolling z-score — are rescaled to a common range and averaged. The result is on a z-score-like scale: ±1 is notable, ±2 is extreme.

Everything else in the indicator is presentation of those numbers.

## Auto-Tuned Per Timeframe

CRSM applies different calibration values depending on the chart's timeframe. Six buckets are defined (1m, 5m, 15m, 1H, 4H, Daily); each picks appropriate values for lookback, smoothing, velocity window, and ranking weights. The dashboard header shows the active bucket (e.g. "TF: 1H") so you always know which profile is in effect. You can drop CRSM onto a 1H chart or a 5m chart and get behaviour appropriate to that TF without retuning.

## What You See

**Chart panel:** eight coloured lines (one per currency), a basket compression line (low = bunched, pre-breakout), a basket mean, ±1σ threshold bands, and a currency-colour legend at the bottom-centre.

**Dashboard (top-right by default):** a compact panel with two sections.

The top section shows basket-level state:

- **Regime** — TRENDING / COMPRESSED / CHOPPY / CRISIS
- **Haven** — RISK-ON / RISK-OFF / neutral (described below)
- **Dominant** — flags when one currency appears in many of the top pairs
- **Compress** — basket dispersion magnitude
- **PC1 / PC2** — macro decomposition (PC1 = USD vs basket, PC2 = commodity bloc vs safe-haven bloc)
- **Basket Vel** — rate of change of average strength

The bottom section is the pair table — 10 rows showing the most active pairs, oriented with the stronger currency on the left. Each row gives both currencies, their individual strengths and velocities, the spread between them, whether the spread is widening or narrowing, and an Activity Score used to rank the rows.

## The Confluent Haven Extreme Detector

The single empirically-validated signal in CRSM, identified via cross-symbol backtest analysis on 8 historical datasets. When two or more of JPY/CHF (the safe-haven bloc) cross beyond ±1.5 strength simultaneously, the indicator flags the risk regime:

- **RISK-ON** — both havens below −1.5. Backtest: non-JPY pairs (GBP/USD, EUR/USD) rallied with 70–88% win rate over the next 20 bars across the test set.
- **RISK-OFF** — both havens above +1.5. Backtest: JPY-quote pairs (AUD/JPY especially) fell with 64% win rate over the next 20 bars across the test set.

When the cell flips, that's a regime context worth reading. The directional bias is set; what to do with it on a specific pair is still your decision on the pair chart. Past backtest results do not guarantee future behaviour.

## The Dominance Flag

When the top 10 pairs are dominated by one currency, the dashboard says so (e.g., "Dominant: USD ×5" means USD appears in 5 of the 10 pairs). This warns that the top list isn't 10 independent trade ideas — it's one underlying theme expressed in multiple correlated ways. The flag shows blue at count 4–5 and red at ≥ 6. Below 4 it stays blank.

## Practical Workflow

A simple 1H swing-trading workflow:

1. **Check the regime first.** COMPRESSED → wait. TRENDING → proceed. CHOPPY → mean-reversion only. CRISIS → reduce size.
2. **Check the Haven cell.** RISK-ON / RISK-OFF sets your bias.
3. **Check the Dominance flag.** If a single currency dominates the top 10, recognise the underlying theme.
4. **Scan the top of the pair table.** High Score plus "widening" Spread Vel marks an active developing setup.
5. **Confirm with PC1 / PC2** if the macro axes align with your read.
6. **Open the actual pair chart and apply your own analysis.** CRSM gets you to which pair. The entry, stop, and target are decisions you make on the pair chart.
7. **Use alerts as awareness, not as entry triggers.**

## Multiple Timeframes

A useful pattern is to run two instances of CRSM on the same chart — a slower one (e.g. 1H) and a faster one (e.g. 5m or 15m). The 1H gives macro context. The 5m/15m shows tactical setups. When the two views agree, the read is high-conviction. When they disagree, the shorter timeframe is usually showing something the longer hasn't absorbed yet.

## Settings

The Settings panel is intentionally compact — TF-dependent parameters are auto-tuned, so most controls are display preferences.

- **Currencies** — turn individual currencies on or off in the basket.
- **Multi-Horizon Strength** — enable a longer-horizon comparison strength used in the analysis.
- **Decomposition Outputs** — toggle PC1 / PC2 plot lines and opacity.
- **Compression & Velocity** — plot toggles (threshold and window are auto).
- **Haven Extreme Detector** — enable, set strength threshold (default 1.5), optional chart-panel tint during haven extreme regimes.
- **Data Source** — OANDA / FOREXCOM / FX_IDC / Futures.
- **Display** — show or hide dashboard elements, dashboard position.
- **Pair Ranking** — number of pairs to display, sort key (Score / Spread Vel / Spread), dashboard text size.
- **Appearance** — colour theme and dark mode.

## Alerts

All alerts fire once on the transition bar, not every bar after:

- **Currency Crossed Upper σ** — any visible currency crossed +1σ
- **Currency Crossed Lower σ** — any visible currency crossed −1σ
- **Compression Release** — basket dispersion just expanded out of compression
- **High-Potential Pair** — top-pair spread exceeded 2× basket dispersion
- **Regime → Compressed / Trending / Crisis** — regime transitions
- **Haven → Risk-On / Risk-Off** — the two haven transitions

## Honest Limitations

**Algebraic completeness ≠ behavioural equivalence.** The 7 USD-anchored prices fully describe all 28 cross-pair returns mathematically. But actual cross-pair behaviour is also affected by pair-specific liquidity, session flow, dealer positioning, and pair-specific volatility clustering. CRSM captures the algebraic structure of FX, not every behavioural nuance. Differences concentrate around news, session opens, and order-flow events.

**Not a timing system.** Strength dynamics give you context, regime read, and pair selection. They don't tell you when to enter or exit a specific trade. Use CRSM alongside your normal chart analysis (structural levels, market structure, indicators you trust) — not in place of it.

**Timeframe behaviour varies.** Even with auto-tune, faster timeframes are inherently noisier and slower timeframes are quieter. The auto-tune calibrates parameters appropriately but cannot change the noise profile of any given TF. The 1m, 4H, and Daily buckets are calibrated from the same scaling logic that backed the 5m / 15m / 1H buckets but have not been independently backtested at the same depth.

**Pair concentration.** When one currency dominates the basket — which is most of the time — the top N pairs cluster around that currency. The Dominance flag warns when this is happening so you don't over-diversify into correlated bets.

---

*Educational tool. Past performance is not indicative of future results. Always combine with independent analysis and your own risk management.*

## Source Code

````pine
//@version=6
indicator("CRSM v1.8 - Currency Relative Strength Monitor", shorttitle="CRSM",
     overlay=false, max_lines_count=100, max_labels_count=200, max_bars_back=1000)

// ---------------------------------------------------------------------------
// CURRENCY RELATIVE STRENGTH MONITOR v1.8
//
// CHANGES vs v1.7:
//  • Added "Align" column to the dashboard pair table. Each pair row now
//    shows whether each currency's chart-TF strength sign matches its
//    longer-horizon strength sign (Y/Y = both aligned with HTF, N/N =
//    both contradicted, mixed = one each). The longer-horizon strengths
//    were already being computed via the Multi-Horizon Strength input;
//    v1.3–v1.7 never displayed them. The "horizon_enable" tooltip is
//    updated accordingly. Column is colour-coded: green when both
//    aligned, red when both misaligned, neutral when mixed.
//  • Renamed the default "EdgeTools" colour theme to "CosmicTools"
//    throughout (theme name only — colour palette unchanged).
//
// CHANGES vs v1.6:
//  • Added "Sort pairs by" input in the Pair Ranking group. The dashboard
//    pair table can now be ordered by Activity Score (default, as in v1.6),
//    by Spread Velocity magnitude (largest movement regardless of widening
//    or narrowing direction), or by Spread magnitude (largest strength
//    differential). The Dominance flag follows the active sort, so it
//    reflects concentration in whatever the top N is showing.
//
// CHANGES vs v1.5 (Settings simplification):
//  • TF-dependent parameters are now applied automatically based on the
//    chart timeframe. Return Lookback, EMA Smoothing, Z-Score Window,
//    Velocity bars, Horizon multiplier, Activity-Score velocity weight (k),
//    Compression threshold, and Arrow threshold no longer appear in
//    Settings. Six TF buckets are defined (1m, 5m, 15m, 1H, 4H, Daily)
//    with parameters in a single editable block near the top of this file.
//    User no longer needs to re-tune when applying the indicator to a
//    different timeframe.
//  • Methodology inputs hidden from Settings: Strength Method,
//    trade-weighted basket, and sum-to-zero normalization were design
//    decisions, not per-chart preferences. Hardcoded to validated defaults
//    (Composite + BIS trade weights + zero-sum). Editable as code
//    constants for dev work.
//  • Dashboard header method cell replaced with a "TF: <bucket>" indicator
//    so the active profile is always visible.
//  • The User Guide reference table for TF defaults now documents what
//    the indicator applies automatically rather than what the user must
//    set; 1m, 4H, and Daily buckets added.
//
// CHANGES vs v1.4 (cleanup pass addressing external review):
//  • Activity Score velocity weight (k) min lowered from 1.0 to 0.0.
//    Setting k=0 gives pure |spread| ranking, surfacing fully-formed
//    setups without velocity noise. Addresses the reviewer point that
//    "large k may accidentally prioritize chaotic expansion".
//  • Momentum strength method tooltip clarified — it's the simplest
//    available method (smoothed centered log return, no composite or
//    z-score chain). Reviewer-friendly for those who suspect the
//    composite is over-engineered.
//  • Added "Dominant" cell in dashboard header. When a single currency
//    appears in = 4 of the top N pairs, the dashboard flags it (e.g.,
//    "Dominant: USD ×6"). Helps the trader recognize when the top-pair
//    list represents one underlying theme rather than independent
//    opportunities.
//
// CHANGES vs v1.3:
//  • Added Confluent Haven Extreme detector. Flags when JPY and CHF both
//    reach extreme strength simultaneously — the safe-haven bloc state.
//    Backtest on 8 datasets (GBPUSD, EURUSD, USDJPY, AUDJPY at 15m/1H)
//    showed 70-88% win rates when =2 of JPY/CHF drop below -1.5 (risk-on
//    signal for non-JPY pairs) or rise above +1.5 (risk-off for JPY-quote
//    pairs).
//  • Dashboard row 1 now includes a "Haven" cell showing the current
//    state: RISK-ON / RISK-OFF / —
//  • Optional soft background tint on the chart panel during haven extreme
//    periods (green=risk-on, red=risk-off), off by default.
//  • Two new alerts: Haven ? Risk-On and Haven ? Risk-Off (fire on the
//    transition into state, not every bar).
//
// CHANGES vs v1.2:
//  • Redesigned dashboard around pair-level information. Per-currency rows
//    replaced with a top-N pairs table (default top 10 of 28 possible).
//  • Each pair row shows: Cur1, strength, velocity | Cur2, strength,
//    velocity | spread | spread velocity (with directional arrow).
//  • Pairs ranked by an "Activity Score" = |spread| + k × |spread velocity|.
//    This combines current strength differential with rate of change so
//    both fully-formed setups and emerging ones surface.
//  • Pair orientation always shows the stronger currency on the left, so
//    spread reads as positive and the spread-velocity arrow ? = widening,
//    ? = narrowing, • = stable.
//
// CHANGES vs v1.1:
//  • Removed Hook and Divergence signals. Cross-symbol validation showed
//    these did not produce reliable directional edge across multiple pairs.
//    CRSM is now positioned as a strength dashboard, not a signal generator.
//  • Added user-controllable opacity for PC1 and PC2 lines.
//
// CHANGES vs the original ACSM:
//
//  1. LOG-RETURN BASIS
//     All returns are computed in log space (log(p / p[n])). Log returns
//     are additive across cross rates: log(EUR/JPY) return == log(EUR/USD)
//     return + log(USD/JPY) return. This means the seven USD-anchored
//     prices fully determine all 28 bilateral pair returns in the basket,
//     so we get N-1 pair coverage per currency for free.
//
//  2. SUM-TO-ZERO BASKET CENTERING
//     Each currency's return is centered against the weighted basket mean.
//     USD is now a normal participant whose strength emerges from the same
//     calculation as every other currency. This eliminates the circular
//     "USD = -mean(others)" definition in v1.
//
//  3. TRADE-WEIGHTED BASKET AGGREGATION
//     Basket mean uses BIS turnover-share approximations (USD 88, EUR 31,
//     JPY 17, GBP 13, AUD 7, CAD 6, CHF 5, NZD 2). EUR/USD moves now
//     dominate the basket the way they dominate real FX volume.
//
//  4. PROPER COMPOSITE SCORING
//     v1's composite multiplied a z-score by |momentum|, which destroyed
//     the z-score's meaning. v2 standardizes each sub-signal on its own
//     rolling z-score before averaging — all three components land on the
//     same scale.
//
//  5. DECOMPOSITION OUTPUTS
//     PC1 proxy: basket-mean USD return (the risk-on/off axis).
//     PC2 proxy: commodity bloc (AUD+NZD+CAD)/3 minus safe-haven
//                (JPY+CHF)/2 — captures risk appetite.
//     Plot these as optional secondary lines.
//
//  6. MULTI-HORIZON STRENGTH (HTF proxy)
//     A second strength series at longer lookback gives a slower
//     comparison line for each currency — equivalent in spirit to a higher
//     timeframe view but costs zero extra request.security calls.
//
//  7. REGIME CLASSIFICATION
//     Basket dispersion + basket velocity yields four regimes: Trending,
//     Compressed, Choppy, Crisis. Display in the dashboard.
//
//  8. PRECURSOR PATTERN OUTPUTS
//     • Strength velocity: rate of change of each currency's strength
//     • Basket compression: stdev across all 8 strengths (low = pre-break)
//
//  9. CLEANUPS
//     All color schemes now appear in the dropdown (Behavioral and Quant
//     were unreachable in v1). Alerts fire only on transitions. Inverse
//     pair handling negates returns instead of inverting prices. max_bars_back
//     bumped to 1000 to accommodate combined lookback chains.
// ---------------------------------------------------------------------------


// --- TIMEFRAME AUTO-TUNE PROFILES (v1.6) -----------------------------------
//
// In v1.5 and earlier, parameters that depend on chart timeframe were
// exposed as user inputs and had to be re-tuned manually whenever an
// instance was applied to a different TF. v1.6 hides them from Settings
// and applies them automatically based on the chart's TF.
//
// The chart TF is mapped to one of six buckets — 1m, 5m, 15m, 1H, 4H,
// Daily — and the constants below define the parameters for each.
// Backtested defaults (5m / 15m / 1H) match the values published in the
// v1.5 User Guide reference table. 1m, 4H, and Daily extend the same
// scaling logic.
//
// Bucket boundaries (chart TF in minutes):
//   =2 ? 1m   |   3–10 ? 5m   |   11–22 ? 15m
//   23–150 ? 1H   |   151–480 ? 4H   |   >480 ? Daily
//
//                                 1m     5m    15m     1H     4H      D
//                                ----------------------------------------
//   Return Lookback       (bars)  60     48     32     21     14     10
//   EMA Smoothing         (bars)  30     24     21     14     10      7
//   Z-Score Window        (bars) 180    144     96     63     50     40
//   Velocity bars                  8      6      4      3      3      2
//   Horizon multiplier            15     12      4      4      6      5
//   Velocity weight (k)          3.0    4.0    5.0    7.0    8.0    8.0
//   Compression threshold        0.6    0.5    0.5    0.4   0.35   0.30
//   Arrow threshold            0.005  0.010  0.015  0.020  0.025  0.030
//
// To retune a bucket, edit the corresponding cell in the ternary chains
// below. Variable names match those used throughout the rest of the
// script, so no downstream changes are needed.

tf_min = timeframe.in_seconds() / 60.0

// Note on indentation: Pine v6 multi-line ternaries require continuation
// lines to be indented by a number of spaces that is NOT a multiple of 4
// (otherwise the parser reads them as a new block, producing CE10156).
// All chains below use a 5-space continuation indent.

tf_bucket = tf_min <= 2   ? "1m"  :
     tf_min <= 10  ? "5m"  :
     tf_min <= 22  ? "15m" :
     tf_min <= 150 ? "1H"  :
     tf_min <= 480 ? "4H"  :
     "Daily"

strength_period = tf_bucket == "1m"  ?  60 :
     tf_bucket == "5m"  ?  48 :
     tf_bucket == "15m" ?  32 :
     tf_bucket == "1H"  ?  21 :
     tf_bucket == "4H"  ?  14 :
     10

smoothing_period = tf_bucket == "1m"  ?  30 :
     tf_bucket == "5m"  ?  24 :
     tf_bucket == "15m" ?  21 :
     tf_bucket == "1H"  ?  14 :
     tf_bucket == "4H"  ?  10 :
     7

zscore_period = tf_bucket == "1m"  ? 180 :
     tf_bucket == "5m"  ? 144 :
     tf_bucket == "15m" ?  96 :
     tf_bucket == "1H"  ?  63 :
     tf_bucket == "4H"  ?  50 :
     40

velocity_period = tf_bucket == "1m"  ? 8 :
     tf_bucket == "5m"  ? 6 :
     tf_bucket == "15m" ? 4 :
     tf_bucket == "1H"  ? 3 :
     tf_bucket == "4H"  ? 3 :
     2

horizon_mult = tf_bucket == "1m"  ? 15 :
     tf_bucket == "5m"  ? 12 :
     tf_bucket == "15m" ?  4 :
     tf_bucket == "1H"  ?  4 :
     tf_bucket == "4H"  ?  6 :
     5

score_vel_weight = tf_bucket == "1m"  ? 3.0 :
     tf_bucket == "5m"  ? 4.0 :
     tf_bucket == "15m" ? 5.0 :
     tf_bucket == "1H"  ? 7.0 :
     tf_bucket == "4H"  ? 8.0 :
     8.0

compression_thresh = tf_bucket == "1m"  ? 0.6  :
     tf_bucket == "5m"  ? 0.5  :
     tf_bucket == "15m" ? 0.5  :
     tf_bucket == "1H"  ? 0.4  :
     tf_bucket == "4H"  ? 0.35 :
     0.30

arrow_threshold = tf_bucket == "1m"  ? 0.005 :
     tf_bucket == "5m"  ? 0.010 :
     tf_bucket == "15m" ? 0.015 :
     tf_bucket == "1H"  ? 0.020 :
     tf_bucket == "4H"  ? 0.025 :
     0.030


// --- METHODOLOGY (DEV CONSTANTS, v1.6) -------------------------------------
// These were user-facing inputs in v1.5. They're foundational design
// decisions, not per-chart preferences, so v1.6 hides them from Settings.
// Edit here for dev work — note the comments below before changing
// calc_method, since the validated Haven Extreme win rates were measured
// with "Composite".
//
//   calc_method:
//     "Composite"           — validated default (recommended).
//                             Standardized blend of momentum +
//                             vol-adjusted momentum + z-score.
//     "Momentum"            — simplest. Smoothed centered log return,
//                             no z-score/composite chain.
//     "Z-Score"             — pure rolling z-score normalization.
//     "Volatility-Adjusted" — momentum scaled by recent volatility.
//   use_trade_weights:
//     true  — BIS turnover-share basket aggregation (recommended).
//     false — equal-weight basket (exposes USD bias).
//   enforce_zero_sum:
//     true  — subtract basket mean so currencies sum to zero (recommended;
//             keeps USD as a normal participant).
//     false — raw centered returns.

calc_method       = "Composite"
use_trade_weights = true
enforce_zero_sum  = true


// --- INPUTS ----------------------------------------------------------------

g_curr = "Currencies"
show_eur = input.bool(true, "EUR", group=g_curr, inline="r1")
show_gbp = input.bool(true, "GBP", group=g_curr, inline="r1")
show_jpy = input.bool(true, "JPY", group=g_curr, inline="r1")
show_chf = input.bool(true, "CHF", group=g_curr, inline="r1")
show_aud = input.bool(true, "AUD", group=g_curr, inline="r2")
show_cad = input.bool(true, "CAD", group=g_curr, inline="r2")
show_nzd = input.bool(true, "NZD", group=g_curr, inline="r2")
show_usd = input.bool(true, "USD", group=g_curr, inline="r2")

g_horizon = "Multi-Horizon Strength"
horizon_enable = input.bool(true, "Enable longer-horizon comparison strength", group=g_horizon,
     tooltip="When on, each pair row in the dashboard gains an Align column (v1.8) showing whether each currency's chart-TF strength sign matches its longer-horizon strength sign. Y/Y = both aligned with HTF (strongest confirmation), N/N = both contradicted, mixed = partial. The horizon multiplier itself is auto-tuned by chart TF (v1.6) — edit the TF profile block at the top of the script to change it.")

g_decomp = "Decomposition Outputs"
show_basket_mean = input.bool(false, "Plot basket-mean USD return (PC1 proxy)",
     group=g_decomp, tooltip="Single line summarizing USD vs the entire basket.")
show_commodity_spread = input.bool(false, "Plot commodity - safe-haven spread (PC2 proxy)",
     group=g_decomp, tooltip="(AUD+NZD+CAD)/3 minus (JPY+CHF)/2 — risk appetite indicator.")
pc_opacity = input.int(70, "PC1 / PC2 line opacity",
     minval=10, maxval=100, step=5, group=g_decomp,
     tooltip="10 = barely visible, 100 = fully opaque. Default 70 = clearly visible but not dominating.")

g_outputs = "Compression & Velocity"
show_velocity    = input.bool(false, "Plot strength velocity (histogram of basket)", group=g_outputs)
show_compression = input.bool(true, "Plot basket compression line", group=g_outputs,
     tooltip="Stdev of all 8 strengths. Low values precede breakouts. Velocity bars and compression alert threshold are auto-tuned by chart TF (v1.6).")

g_haven = "Haven Extreme Detector"
show_haven      = input.bool(true, "Detect confluent haven extremes", group=g_haven,
     tooltip="Flags risk-on / risk-off regime when JPY and CHF both reach extreme strength simultaneously. Backtest showed 70-88% win rate for the implied direction.")
haven_threshold = input.float(1.5, "Haven extreme threshold (strength)", minval=0.5, maxval=3.0, step=0.1, group=g_haven,
     tooltip="Strength level at which JPY/CHF are considered 'extreme'. ±1.5 is what the backtest validated as the sweet spot.")
show_haven_bg   = input.bool(false, "Tint chart panel during haven extremes", group=g_haven,
     tooltip="Soft green when risk-on (haven weak), soft red when risk-off (haven strong). Off by default — informative but can be visually busy.")

g_data = "Data Source"
data_source = input.string("OANDA", "Provider",
     options=["OANDA","FOREXCOM","FX_IDC","Futures"], group=g_data,
     tooltip="OANDA: 15-20min retail delay. FOREXCOM/FX_IDC may be real-time. Futures (6E/6B/6J etc) are real-time but require futures data.")

g_disp = "Display"
show_dashboard  = input.bool(true, "Show dashboard", group=g_disp)
show_thresholds = input.bool(true, "Show ±1s threshold bands", group=g_disp)
show_histogram  = input.bool(false, "Show per-currency histogram", group=g_disp)
dash_position   = input.string("top_right", "Dashboard position",
     options=["top_right","top_left","middle_right","middle_left","bottom_right","bottom_left"], group=g_disp)

g_pairs = "Pair Ranking"
top_n_pairs       = input.int(10, "Number of pairs to display", minval=3, maxval=20, group=g_pairs,
     tooltip="How many of the 28 possible pairs to show in the dashboard. Activity Score velocity weight (k) and the widening/narrowing stability threshold are auto-tuned by chart TF (v1.6).")
sort_key          = input.string("Score", "Sort pairs by", options=["Score","Spread Vel","Spread"], group=g_pairs,
     tooltip="Score (default): Activity Score = |spread| + k × |spread velocity|, descending. Spread Vel: rate of change of spread by magnitude (largest movement regardless of widening or narrowing direction). Spread: strength differential by magnitude. The Dominance flag follows whichever sort is active.")
dash_text_size_in = input.string("normal", "Dashboard text size", options=["small","normal","large"], group=g_pairs,
     tooltip="Larger = more readable but takes more screen space.")

g_app = "Appearance"
color_scheme  = input.string("CosmicTools", "Color theme",
     options=["CosmicTools","Gold","Ocean","Fire","Matrix","Arctic","Behavioral","Quant"], group=g_app)
use_dark_mode = input.bool(true, "Dark mode", group=g_app)


// --- COLOR SCHEME ----------------------------------------------------------

var color primary_color  = #2196F3
var color bullish_color  = #4CAF50
var color bearish_color  = #FF5252
var color neutral_color  = #808080
var color text_color     = color.white
var color bg_color       = #000000
var color table_bg_color = #1E1E1E
var color header_bg_color= #2D2D2D

switch color_scheme
    "Gold" =>
        primary_color  := use_dark_mode ? #FFD700 : #DAA520
        bullish_color  := use_dark_mode ? #FFA500 : #FF8C00
        bearish_color  := use_dark_mode ? #FF5252 : #D32F2F
        neutral_color  := use_dark_mode ? #C0C0C0 : #808080
        text_color     := use_dark_mode ? color.white : color.black
        bg_color       := use_dark_mode ? #000000 : #FFFFFF
        table_bg_color := use_dark_mode ? #1A1A00 : #FFFEF0
        header_bg_color:= use_dark_mode ? #2D2600 : #F5F5DC
    "CosmicTools" =>
        primary_color  := use_dark_mode ? #4682B4 : #1E90FF
        bullish_color  := use_dark_mode ? #4CAF50 : #388E3C
        bearish_color  := use_dark_mode ? #FF5252 : #D32F2F
        neutral_color  := use_dark_mode ? #708090 : #696969
        text_color     := use_dark_mode ? color.white : color.black
        bg_color       := use_dark_mode ? #000000 : #FFFFFF
        table_bg_color := use_dark_mode ? #0F1419 : #F0F8FF
        header_bg_color:= use_dark_mode ? #1E2A3A : #E6F3FF
    "Behavioral" =>
        primary_color  := #808080
        bullish_color  := #00FF00
        bearish_color  := #8B0000
        neutral_color  := #FFBF00
        text_color     := use_dark_mode ? color.white : color.black
        bg_color       := use_dark_mode ? #000000 : #FFFFFF
        table_bg_color := use_dark_mode ? #1A1A1A : #F8F8F8
        header_bg_color:= use_dark_mode ? #2D2D2D : #E8E8E8
    "Quant" =>
        primary_color  := #808080
        bullish_color  := #FFA500
        bearish_color  := #8B0000
        neutral_color  := #4682B4
        text_color     := use_dark_mode ? color.white : color.black
        bg_color       := use_dark_mode ? #000000 : #FFFFFF
        table_bg_color := use_dark_mode ? #0D0D0D : #FAFAFA
        header_bg_color:= use_dark_mode ? #1A1A1A : #F0F0F0
    "Ocean" =>
        primary_color  := use_dark_mode ? #20B2AA : #008B8B
        bullish_color  := use_dark_mode ? #00CED1 : #4682B4
        bearish_color  := use_dark_mode ? #FF4500 : #B22222
        neutral_color  := use_dark_mode ? #87CEEB : #2F4F4F
        text_color     := use_dark_mode ? #F0F8FF : #191970
        bg_color       := use_dark_mode ? #001F3F : #F0F8FF
        table_bg_color := use_dark_mode ? #001A2E : #E6F7FF
        header_bg_color:= use_dark_mode ? #002A47 : #CCF2FF
    "Fire" =>
        primary_color  := use_dark_mode ? #FF6347 : #DC143C
        bullish_color  := use_dark_mode ? #FFD700 : #FF8C00
        bearish_color  := use_dark_mode ? #8B0000 : #800000
        neutral_color  := use_dark_mode ? #FFA500 : #CD853F
        text_color     := use_dark_mode ? #FFFAF0 : #2F1B14
        bg_color       := use_dark_mode ? #2F1B14 : #FFFAF0
        table_bg_color := use_dark_mode ? #261611 : #FFF8F0
        header_bg_color:= use_dark_mode ? #3D241A : #FFE4CC
    "Matrix" =>
        primary_color  := use_dark_mode ? #00FF41 : #006400
        bullish_color  := use_dark_mode ? #39FF14 : #228B22
        bearish_color  := use_dark_mode ? #FF073A : #8B0000
        neutral_color  := use_dark_mode ? #00FFFF : #008B8B
        text_color     := use_dark_mode ? #C0FF8C : #003300
        bg_color       := use_dark_mode ? #0D1B0D : #F0FFF0
        table_bg_color := use_dark_mode ? #0A1A0A : #E8FFF0
        header_bg_color:= use_dark_mode ? #112B11 : #CCFFCC
    "Arctic" =>
        primary_color  := use_dark_mode ? #87CEFA : #4169E1
        bullish_color  := use_dark_mode ? #00BFFF : #0000CD
        bearish_color  := use_dark_mode ? #FF1493 : #8B008B
        neutral_color  := use_dark_mode ? #B0E0E6 : #483D8B
        text_color     := use_dark_mode ? #F8F8FF : #191970
        bg_color       := use_dark_mode ? #191970 : #F8F8FF
        table_bg_color := use_dark_mode ? #141B47 : #F0F8FF
        header_bg_color:= use_dark_mode ? #1E2A5C : #E0F0FF

// Per-currency colors (theme-aware)
get_eur_color() => switch color_scheme
    "Gold" => #FFD700
    "CosmicTools" => #2196F3
    "Ocean" => #0077BE
    "Fire" => #FF6347
    "Matrix" => #00FF41
    "Arctic" => #87CEFA
    "Behavioral" => #808080
    "Quant" => #4682B4
    => #2196F3

get_gbp_color() => switch color_scheme
    "Gold" => #FF8C00
    "CosmicTools" => #FF9800
    "Ocean" => #FF7F00
    "Fire" => #FFD700
    "Matrix" => #39FF14
    "Arctic" => #00BFFF
    "Behavioral" => #00FF00
    "Quant" => #FFA500
    => #FF9800

get_jpy_color() => switch color_scheme
    "Gold" => #DC143C
    "CosmicTools" => #FF5722
    "Ocean" => #C41E3A
    "Fire" => #8B0000
    "Matrix" => #FF073A
    "Arctic" => #FF1493
    "Behavioral" => #8B0000
    "Quant" => #8B0000
    => #FF5722

get_chf_color() => switch color_scheme
    "Gold" => #8B4513
    "CosmicTools" => #9C27B0
    "Ocean" => #6A4C93
    "Fire" => #CD853F
    "Matrix" => #00FFFF
    "Arctic" => #B0E0E6
    "Behavioral" => #FFBF00
    "Quant" => #9C27B0
    => #9C27B0

get_aud_color() => switch color_scheme
    "Gold" => #32CD32
    "CosmicTools" => #4CAF50
    "Ocean" => #2E8B57
    "Fire" => #228B22
    "Matrix" => #228B22
    "Arctic" => #0000CD
    "Behavioral" => #00FF00
    "Quant" => #4CAF50
    => #4CAF50

get_cad_color() => switch color_scheme
    "Gold" => #20B2AA
    "CosmicTools" => #00BCD4
    "Ocean" => #00CED1
    "Fire" => #4682B4
    "Matrix" => #008B8B
    "Arctic" => #483D8B
    "Behavioral" => #808080
    "Quant" => #00BCD4
    => #00BCD4

get_nzd_color() => switch color_scheme
    "Gold" => #FF6347
    "CosmicTools" => #FFEB3B
    "Ocean" => #FFD700
    "Fire" => #DAA520
    "Matrix" => #C0FF8C
    "Arctic" => #F8F8FF
    "Behavioral" => #FFBF00
    "Quant" => #FFEB3B
    => #FFEB3B

get_usd_color() => switch color_scheme
    "Gold" => #696969
    "CosmicTools" => #B0B0B0
    "Ocean" => #708090
    "Fire" => #A9A9A9
    "Matrix" => #003300
    "Arctic" => #191970
    "Behavioral" => #808080
    "Quant" => #808080
    => #B0B0B0

// Colors are always assigned (simple/const-typed). When a currency is
// hidden via show_X, its strength series is already na, so the plot
// won't render — no need to also gate the color (which would make it
// series<color> and double the plot count in TV's RE10140 accounting).
eur_color = get_eur_color()
gbp_color = get_gbp_color()
jpy_color = get_jpy_color()
chf_color = get_chf_color()
aud_color = get_aud_color()
cad_color = get_cad_color()
nzd_color = get_nzd_color()
usd_color = get_usd_color()


// --- DATA ACQUISITION ------------------------------------------------------

fx_symbol(base, futures_sym) =>
    switch data_source
        "OANDA"    => "OANDA:"    + base
        "FOREXCOM" => "FOREXCOM:" + base
        "FX_IDC"   => "FX_IDC:"   + base
        "Futures"  => futures_sym
        => "OANDA:" + base

f_get(sym) =>
    rate = request.security(sym, timeframe.period, close,
         lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off, ignore_invalid_symbol=true)
    na(rate) or rate <= 0 ? na : rate

sym_eu  = fx_symbol("EURUSD", "CME_MINI:6E1!")
sym_gu  = fx_symbol("GBPUSD", "CME_MINI:6B1!")
sym_uj  = fx_symbol("USDJPY", "CME_MINI:6J1!")
sym_uc  = fx_symbol("USDCHF", "CME_MINI:6S1!")
sym_au  = fx_symbol("AUDUSD", "CME_MINI:6A1!")
sym_uca = fx_symbol("USDCAD", "CME_MINI:6C1!")
sym_nu  = fx_symbol("NZDUSD", "OANDA:NZDUSD")

eur_usd = f_get(sym_eu)
gbp_usd = f_get(sym_gu)
usd_jpy = f_get(sym_uj)
usd_chf = f_get(sym_uc)
aud_usd = f_get(sym_au)
usd_cad = f_get(sym_uca)
nzd_usd = f_get(sym_nu)


// --- LOG RETURNS vs USD ----------------------------------------------------
// Sign convention: positive r_X means X is appreciating against USD.

safe_lr(p, n) =>
    pn = nz(p[n], na)
    na(p) or na(pn) or pn <= 0 or p <= 0 ? 0.0 : math.log(p / pn)

r_eur_raw = safe_lr(eur_usd, strength_period)
r_gbp_raw = safe_lr(gbp_usd, strength_period)
r_jpy_raw = -safe_lr(usd_jpy, strength_period)     // negate: USD is base
r_chf_raw = -safe_lr(usd_chf, strength_period)
r_aud_raw = safe_lr(aud_usd, strength_period)
r_cad_raw = -safe_lr(usd_cad, strength_period)
r_nzd_raw = safe_lr(nzd_usd, strength_period)
r_usd_raw = 0.0                                     // USD vs itself = 0

// Longer-horizon returns for HTF proxy
hor_p = strength_period * horizon_mult
r_eur_h = safe_lr(eur_usd, hor_p)
r_gbp_h = safe_lr(gbp_usd, hor_p)
r_jpy_h = -safe_lr(usd_jpy, hor_p)
r_chf_h = -safe_lr(usd_chf, hor_p)
r_aud_h = safe_lr(aud_usd, hor_p)
r_cad_h = -safe_lr(usd_cad, hor_p)
r_nzd_h = safe_lr(nzd_usd, hor_p)
r_usd_h = 0.0


// --- TRADE WEIGHTS (BIS 2022 Triennial turnover share approximations) -----

w_eur_v = 31.0
w_gbp_v = 13.0
w_jpy_v = 17.0
w_chf_v = 5.0
w_aud_v = 7.0
w_cad_v = 6.0
w_nzd_v = 2.0
w_usd_v = 88.0

w_eur = use_trade_weights ? w_eur_v : 1.0
w_gbp = use_trade_weights ? w_gbp_v : 1.0
w_jpy = use_trade_weights ? w_jpy_v : 1.0
w_chf = use_trade_weights ? w_chf_v : 1.0
w_aud = use_trade_weights ? w_aud_v : 1.0
w_cad = use_trade_weights ? w_cad_v : 1.0
w_nzd = use_trade_weights ? w_nzd_v : 1.0
w_usd = use_trade_weights ? w_usd_v : 1.0
w_sum = w_eur + w_gbp + w_jpy + w_chf + w_aud + w_cad + w_nzd + w_usd

basket_mean_return =
     (w_eur*r_eur_raw + w_gbp*r_gbp_raw + w_jpy*r_jpy_raw + w_chf*r_chf_raw +
      w_aud*r_aud_raw + w_cad*r_cad_raw + w_nzd*r_nzd_raw + w_usd*r_usd_raw) / w_sum

basket_mean_return_h =
     (w_eur*r_eur_h + w_gbp*r_gbp_h + w_jpy*r_jpy_h + w_chf*r_chf_h +
      w_aud*r_aud_h + w_cad*r_cad_h + w_nzd*r_nzd_h + w_usd*r_usd_h) / w_sum


// --- BASKET-CENTERED RETURNS -----------------------------------------------
// Subtracting the weighted basket mean enforces sum-to-zero (approximately
// for weighted version) and makes USD a first-class participant.

r_eur_c = enforce_zero_sum ? (r_eur_raw - basket_mean_return) : r_eur_raw
r_gbp_c = enforce_zero_sum ? (r_gbp_raw - basket_mean_return) : r_gbp_raw
r_jpy_c = enforce_zero_sum ? (r_jpy_raw - basket_mean_return) : r_jpy_raw
r_chf_c = enforce_zero_sum ? (r_chf_raw - basket_mean_return) : r_chf_raw
r_aud_c = enforce_zero_sum ? (r_aud_raw - basket_mean_return) : r_aud_raw
r_cad_c = enforce_zero_sum ? (r_cad_raw - basket_mean_return) : r_cad_raw
r_nzd_c = enforce_zero_sum ? (r_nzd_raw - basket_mean_return) : r_nzd_raw
r_usd_c = enforce_zero_sum ? (0.0 - basket_mean_return) : -basket_mean_return

r_eur_ch = enforce_zero_sum ? (r_eur_h - basket_mean_return_h) : r_eur_h
r_gbp_ch = enforce_zero_sum ? (r_gbp_h - basket_mean_return_h) : r_gbp_h
r_jpy_ch = enforce_zero_sum ? (r_jpy_h - basket_mean_return_h) : r_jpy_h
r_chf_ch = enforce_zero_sum ? (r_chf_h - basket_mean_return_h) : r_chf_h
r_aud_ch = enforce_zero_sum ? (r_aud_h - basket_mean_return_h) : r_aud_h
r_cad_ch = enforce_zero_sum ? (r_cad_h - basket_mean_return_h) : r_cad_h
r_nzd_ch = enforce_zero_sum ? (r_nzd_h - basket_mean_return_h) : r_nzd_h
r_usd_ch = enforce_zero_sum ? (0.0 - basket_mean_return_h) : -basket_mean_return_h


// --- COMPOSITE STRENGTH FUNCTION -------------------------------------------
// Three sub-signals — momentum, vol-adjusted momentum, z-score — each
// standardized on its own rolling z-score so they share a common scale
// before being averaged.

calc_strength(r_c) =>
    // Momentum: smoothed centered log return (scaled to make % units)
    m_raw = ta.sma(r_c, smoothing_period) * 100.0
    // Pair-level volatility from the return series itself
    sd    = ta.stdev(r_c, zscore_period)
    // Volatility-adjusted momentum
    v_raw = sd > 0 ? m_raw / (sd * 100.0) : 0.0
    // Pure z-score of current centered return
    mu    = ta.sma(r_c, zscore_period)
    z_raw = sd > 0 ? (r_c - mu) / sd : 0.0

    // Standardize each sub-signal on its own rolling z-score
    std_m = ta.stdev(m_raw, zscore_period)
    std_v = ta.stdev(v_raw, zscore_period)
    std_z = ta.stdev(z_raw, zscore_period)
    mu_m  = ta.sma(m_raw, zscore_period)
    mu_v  = ta.sma(v_raw, zscore_period)
    mu_z  = ta.sma(z_raw, zscore_period)
    m_n = std_m > 0 ? (m_raw - mu_m) / std_m : 0.0
    v_n = std_v > 0 ? (v_raw - mu_v) / std_v : 0.0
    z_n = std_z > 0 ? (z_raw - mu_z) / std_z : 0.0

    raw_strength = switch calc_method
        "Momentum"            => m_raw
        "Z-Score"             => z_raw
        "Volatility-Adjusted" => v_raw
        "Composite"           => (m_n + v_n + z_n) / 3.0
        => m_raw

    ta.ema(raw_strength, smoothing_period)


// --- PER-CURRENCY STRENGTH -------------------------------------------------

eur_str = show_eur ? calc_strength(r_eur_c) : na
gbp_str = show_gbp ? calc_strength(r_gbp_c) : na
jpy_str = show_jpy ? calc_strength(r_jpy_c) : na
chf_str = show_chf ? calc_strength(r_chf_c) : na
aud_str = show_aud ? calc_strength(r_aud_c) : na
cad_str = show_cad ? calc_strength(r_cad_c) : na
nzd_str = show_nzd ? calc_strength(r_nzd_c) : na
usd_str = show_usd ? calc_strength(r_usd_c) : na

// Longer-horizon strength
eur_str_h = horizon_enable and show_eur ? calc_strength(r_eur_ch) : na
gbp_str_h = horizon_enable and show_gbp ? calc_strength(r_gbp_ch) : na
jpy_str_h = horizon_enable and show_jpy ? calc_strength(r_jpy_ch) : na
chf_str_h = horizon_enable and show_chf ? calc_strength(r_chf_ch) : na
aud_str_h = horizon_enable and show_aud ? calc_strength(r_aud_ch) : na
cad_str_h = horizon_enable and show_cad ? calc_strength(r_cad_ch) : na
nzd_str_h = horizon_enable and show_nzd ? calc_strength(r_nzd_ch) : na
usd_str_h = horizon_enable and show_usd ? calc_strength(r_usd_ch) : na


// --- BASKET STATISTICS (for thresholds and compression) --------------------

all_strengths = array.new<float>()
if not na(eur_str)
    array.push(all_strengths, eur_str)
if not na(gbp_str)
    array.push(all_strengths, gbp_str)
if not na(jpy_str)
    array.push(all_strengths, jpy_str)
if not na(chf_str)
    array.push(all_strengths, chf_str)
if not na(aud_str)
    array.push(all_strengths, aud_str)
if not na(cad_str)
    array.push(all_strengths, cad_str)
if not na(nzd_str)
    array.push(all_strengths, nzd_str)
if not na(usd_str)
    array.push(all_strengths, usd_str)

avg_strength    = array.size(all_strengths) > 0 ? array.avg(all_strengths)    : 0.0
basket_disp     = array.size(all_strengths) > 1 ? array.stdev(all_strengths)  : 1.0  // dispersion
upper_threshold = avg_strength + basket_disp
lower_threshold = avg_strength - basket_disp


// --- DECOMPOSITION OUTPUTS -------------------------------------------------

// PC1 proxy: USD vs basket
pc1_proxy = -basket_mean_return * 100.0   // when basket up vs USD, USD is weak
pc1_smooth = ta.ema(pc1_proxy, smoothing_period)

// PC2 proxy: commodity bloc minus safe-haven bloc
commodity_bloc = (nz(aud_str) + nz(nzd_str) + nz(cad_str)) / 3.0
haven_bloc     = (nz(jpy_str) + nz(chf_str)) / 2.0
pc2_proxy      = commodity_bloc - haven_bloc


// --- CONFLUENT HAVEN EXTREMES ----------------------------------------------
// Backtest finding (v1.4): when =2 of JPY/CHF reach extreme strength
// simultaneously, the implied risk regime predicts non-JPY pair direction
// with 70-88% win rate over the next 20 bars.
//
//   Haven RISK-ON  = both JPY and CHF below -threshold  ? non-JPY pairs UP
//   Haven RISK-OFF = both JPY and CHF above +threshold  ? JPY-quote pairs DOWN

haven_count_high = (nz(jpy_str) >  haven_threshold ? 1 : 0) +
                   (nz(chf_str) >  haven_threshold ? 1 : 0)
haven_count_low  = (nz(jpy_str) < -haven_threshold ? 1 : 0) +
                   (nz(chf_str) < -haven_threshold ? 1 : 0)

haven_risk_off = show_haven and haven_count_high >= 2  // both havens strong
haven_risk_on  = show_haven and haven_count_low  >= 2  // both havens weak

haven_state = haven_risk_on  ? "RISK-ON"  :
              haven_risk_off ? "RISK-OFF" :
              "—"


// --- REGIME CLASSIFICATION -------------------------------------------------
// Use basket dispersion and basket velocity to classify:
//   Compressed: low dispersion (everyone neutral, breakout pending)
//   Trending:   moderate-to-high dispersion, sustained direction
//   Choppy:     moderate dispersion, frequent direction changes
//   Crisis:     extreme dispersion (>2s of normal range)

basket_disp_avg = ta.sma(basket_disp, zscore_period)
basket_disp_std = ta.stdev(basket_disp, zscore_period)
basket_disp_z   = basket_disp_std > 0 ? (basket_disp - basket_disp_avg) / basket_disp_std : 0.0

// Basket velocity = how much the average strength moved
basket_velocity     = ta.change(avg_strength, velocity_period) / velocity_period
basket_velocity_abs = math.abs(basket_velocity)
basket_vel_avg      = ta.sma(basket_velocity_abs, zscore_period)
basket_vel_std      = ta.stdev(basket_velocity_abs, zscore_period)
basket_vel_z        = basket_vel_std > 0 ? (basket_velocity_abs - basket_vel_avg) / basket_vel_std : 0.0

regime_label = basket_disp_z > 1.5 ? "CRISIS" :
     basket_disp_z < -0.7 ? "COMPRESSED" :
     basket_vel_z > 0.5 ? "TRENDING" :
     "CHOPPY"

regime_color = regime_label == "TRENDING"   ? bullish_color :
     regime_label == "COMPRESSED" ? primary_color :
     regime_label == "CRISIS"     ? bearish_color :
     neutral_color


// --- VELOCITY (per currency) -----------------------------------------------

vel_eur = show_eur ? ta.change(eur_str, velocity_period) / velocity_period : na
vel_gbp = show_gbp ? ta.change(gbp_str, velocity_period) / velocity_period : na
vel_jpy = show_jpy ? ta.change(jpy_str, velocity_period) / velocity_period : na
vel_chf = show_chf ? ta.change(chf_str, velocity_period) / velocity_period : na
vel_aud = show_aud ? ta.change(aud_str, velocity_period) / velocity_period : na
vel_cad = show_cad ? ta.change(cad_str, velocity_period) / velocity_period : na
vel_nzd = show_nzd ? ta.change(nzd_str, velocity_period) / velocity_period : na
vel_usd = show_usd ? ta.change(usd_str, velocity_period) / velocity_period : na


// --- CHART-PAIR SPREAD (informational dashboard row) -----------------------

get_strength_for_code(code) =>
    switch code
        "EUR" => eur_str
        "GBP" => gbp_str
        "JPY" => jpy_str
        "CHF" => chf_str
        "AUD" => aud_str
        "CAD" => cad_str
        "NZD" => nzd_str
        "USD" => usd_str
        => na

chart_base   = syminfo.basecurrency
chart_quote  = syminfo.currency
chart_b_str  = get_strength_for_code(chart_base)
chart_q_str  = get_strength_for_code(chart_quote)
chart_spread = (not na(chart_b_str) and not na(chart_q_str)) ? chart_b_str - chart_q_str : na


// --- BEST PAIRS & RANKINGS -------------------------------------------------

var string strongest_curr = ""
var string weakest_curr   = ""
strongest_val = -1e10
weakest_val   =  1e10

if not na(eur_str) and eur_str > strongest_val
    strongest_val := eur_str
    strongest_curr := "EUR"
if not na(gbp_str) and gbp_str > strongest_val
    strongest_val := gbp_str
    strongest_curr := "GBP"
if not na(jpy_str) and jpy_str > strongest_val
    strongest_val := jpy_str
    strongest_curr := "JPY"
if not na(chf_str) and chf_str > strongest_val
    strongest_val := chf_str
    strongest_curr := "CHF"
if not na(aud_str) and aud_str > strongest_val
    strongest_val := aud_str
    strongest_curr := "AUD"
if not na(cad_str) and cad_str > strongest_val
    strongest_val := cad_str
    strongest_curr := "CAD"
if not na(nzd_str) and nzd_str > strongest_val
    strongest_val := nzd_str
    strongest_curr := "NZD"
if not na(usd_str) and usd_str > strongest_val
    strongest_val := usd_str
    strongest_curr := "USD"

if not na(eur_str) and eur_str < weakest_val
    weakest_val := eur_str
    weakest_curr := "EUR"
if not na(gbp_str) and gbp_str < weakest_val
    weakest_val := gbp_str
    weakest_curr := "GBP"
if not na(jpy_str) and jpy_str < weakest_val
    weakest_val := jpy_str
    weakest_curr := "JPY"
if not na(chf_str) and chf_str < weakest_val
    weakest_val := chf_str
    weakest_curr := "CHF"
if not na(aud_str) and aud_str < weakest_val
    weakest_val := aud_str
    weakest_curr := "AUD"
if not na(cad_str) and cad_str < weakest_val
    weakest_val := cad_str
    weakest_curr := "CAD"
if not na(nzd_str) and nzd_str < weakest_val
    weakest_val := nzd_str
    weakest_curr := "NZD"
if not na(usd_str) and usd_str < weakest_val
    weakest_val := usd_str
    weakest_curr := "USD"

best_pair      = strongest_curr + "/" + weakest_curr
pair_potential = strongest_val - weakest_val

// 2nd-best pair: the next-strongest currency (excluding strongest1) paired
// with the next-weakest currency (excluding weakest1). Gives the trader a
// secondary setup that doesn't overlap with the top pair.
var string strongest2_curr = ""
var string weakest2_curr   = ""
strongest2_val = -1e10
weakest2_val   =  1e10

if not na(eur_str) and strongest_curr != "EUR" and eur_str > strongest2_val
    strongest2_val := eur_str
    strongest2_curr := "EUR"
if not na(gbp_str) and strongest_curr != "GBP" and gbp_str > strongest2_val
    strongest2_val := gbp_str
    strongest2_curr := "GBP"
if not na(jpy_str) and strongest_curr != "JPY" and jpy_str > strongest2_val
    strongest2_val := jpy_str
    strongest2_curr := "JPY"
if not na(chf_str) and strongest_curr != "CHF" and chf_str > strongest2_val
    strongest2_val := chf_str
    strongest2_curr := "CHF"
if not na(aud_str) and strongest_curr != "AUD" and aud_str > strongest2_val
    strongest2_val := aud_str
    strongest2_curr := "AUD"
if not na(cad_str) and strongest_curr != "CAD" and cad_str > strongest2_val
    strongest2_val := cad_str
    strongest2_curr := "CAD"
if not na(nzd_str) and strongest_curr != "NZD" and nzd_str > strongest2_val
    strongest2_val := nzd_str
    strongest2_curr := "NZD"
if not na(usd_str) and strongest_curr != "USD" and usd_str > strongest2_val
    strongest2_val := usd_str
    strongest2_curr := "USD"

if not na(eur_str) and weakest_curr != "EUR" and eur_str < weakest2_val
    weakest2_val := eur_str
    weakest2_curr := "EUR"
if not na(gbp_str) and weakest_curr != "GBP" and gbp_str < weakest2_val
    weakest2_val := gbp_str
    weakest2_curr := "GBP"
if not na(jpy_str) and weakest_curr != "JPY" and jpy_str < weakest2_val
    weakest2_val := jpy_str
    weakest2_curr := "JPY"
if not na(chf_str) and weakest_curr != "CHF" and chf_str < weakest2_val
    weakest2_val := chf_str
    weakest2_curr := "CHF"
if not na(aud_str) and weakest_curr != "AUD" and aud_str < weakest2_val
    weakest2_val := aud_str
    weakest2_curr := "AUD"
if not na(cad_str) and weakest_curr != "CAD" and cad_str < weakest2_val
    weakest2_val := cad_str
    weakest2_curr := "CAD"
if not na(nzd_str) and weakest_curr != "NZD" and nzd_str < weakest2_val
    weakest2_val := nzd_str
    weakest2_curr := "NZD"
if not na(usd_str) and weakest_curr != "USD" and usd_str < weakest2_val
    weakest2_val := usd_str
    weakest2_curr := "USD"

best_pair_2      = strongest2_curr + "/" + weakest2_curr
pair_potential_2 = strongest2_val - weakest2_val


// --- 28-PAIR SCORE COMPUTATION ---------------------------------------------
// For each of the 28 unique currency pairs, compute the spread (signed
// difference of strengths), spread velocity (difference of currency
// velocities), and an Activity Score = |spread| + k × |spread velocity|.
// Pairs are oriented so the stronger currency is always on the LEFT,
// which means spread is always reported positive.

// Pack currency data into parallel arrays for iteration. Indexed by
// position: 0=EUR, 1=GBP, 2=JPY, 3=CHF, 4=AUD, 5=CAD, 6=NZD, 7=USD.
// (Distinct from `all_strengths` earlier in the script, which is a list
// of only the enabled-and-non-na currencies used for basket dispersion.)
curr_strengths  = array.from(eur_str, gbp_str, jpy_str, chf_str, aud_str, cad_str, nzd_str, usd_str)
curr_velocities = array.from(vel_eur, vel_gbp, vel_jpy, vel_chf, vel_aud, vel_cad, vel_nzd, vel_usd)
curr_names      = array.from("EUR", "GBP", "JPY", "CHF", "AUD", "CAD", "NZD", "USD")
// curr_aligns array is declared below, after the align_* booleans are defined.

// Output arrays (one entry per pair, max 28)
pair_scores    = array.new<float>()
pair_spreads   = array.new<float>()
pair_vels      = array.new<float>()    // signed: +ve = widening, -ve = narrowing
pair_vels_abs  = array.new<float>()    // |pair_vels|, used when sorting by Spread Vel
pair_first_idx = array.new<int>()
pair_second_idx= array.new<int>()

for i = 0 to 6
    for j = i + 1 to 7
        s_i = array.get(curr_strengths,  i)
        s_j = array.get(curr_strengths,  j)
        v_i = array.get(curr_velocities, i)
        v_j = array.get(curr_velocities, j)
        if not na(s_i) and not na(s_j)
            // Orient: stronger currency on left.
            first       = s_i >= s_j ? i : j
            second      = s_i >= s_j ? j : i
            s_first     = array.get(curr_strengths,  first)
            s_second    = array.get(curr_strengths,  second)
            v_first     = array.get(curr_velocities, first)
            v_second    = array.get(curr_velocities, second)
            spread      = s_first - s_second                  // always = 0
            spread_vel  = nz(v_first) - nz(v_second)          // signed: +ve = widening
            score       = math.abs(spread) + score_vel_weight * math.abs(spread_vel)
            array.push(pair_scores,     score)
            array.push(pair_spreads,    spread)
            array.push(pair_vels,       spread_vel)
            array.push(pair_vels_abs,   math.abs(spread_vel))
            array.push(pair_first_idx,  first)
            array.push(pair_second_idx, second)

// Sort all pairs by the user-selected key, descending. Sort target is
// always a magnitude (Score and Spread are already = 0 by construction;
// Spread Vel uses the parallel |pair_vels_abs| array so widening and
// narrowing are ranked equally by movement magnitude).
sort_target = sort_key == "Spread Vel" ? pair_vels_abs :
     sort_key == "Spread"     ? pair_spreads :
     pair_scores
sorted_pair_idx = array.size(sort_target) > 0 ? array.sort_indices(sort_target, order.descending) : array.new<int>()


// --- CURRENCY DOMINANCE IN TOP-N PAIRS (v1.5) ------------------------------
// Count how many of the top-N pairs each currency appears in. If one
// currency appears in = 4 of the top N, the dashboard flags this so the
// trader knows the top pairs are mostly variations on the same theme,
// not independent opportunities.
dom_counts = array.from(0, 0, 0, 0, 0, 0, 0, 0)   // one per currency idx 0..7
top_n_count = math.min(top_n_pairs, array.size(sorted_pair_idx))
if top_n_count > 0
    for k = 0 to top_n_count - 1
        sidx = array.get(sorted_pair_idx, k)
        fi   = array.get(pair_first_idx,  sidx)
        si   = array.get(pair_second_idx, sidx)
        array.set(dom_counts, fi, array.get(dom_counts, fi) + 1)
        array.set(dom_counts, si, array.get(dom_counts, si) + 1)

dom_max_idx   = array.size(dom_counts) > 0 ? array.indexof(dom_counts, array.max(dom_counts)) : -1
dom_max_count = array.size(dom_counts) > 0 ? array.max(dom_counts) : 0
dominant_curr = dom_max_count >= 4 and dom_max_idx >= 0 ? array.get(curr_names, dom_max_idx) : ""
dominant_text = dom_max_count >= 4 ? "Dominant: " + dominant_curr + " ×" + str.tostring(dom_max_count) : ""


// --- MTF/HTF ALIGNMENT (chart TF strength vs longer-horizon strength) ------

align_eur = horizon_enable and not na(eur_str) and not na(eur_str_h) and (math.sign(eur_str) == math.sign(eur_str_h))
align_gbp = horizon_enable and not na(gbp_str) and not na(gbp_str_h) and (math.sign(gbp_str) == math.sign(gbp_str_h))
align_jpy = horizon_enable and not na(jpy_str) and not na(jpy_str_h) and (math.sign(jpy_str) == math.sign(jpy_str_h))
align_chf = horizon_enable and not na(chf_str) and not na(chf_str_h) and (math.sign(chf_str) == math.sign(chf_str_h))
align_aud = horizon_enable and not na(aud_str) and not na(aud_str_h) and (math.sign(aud_str) == math.sign(aud_str_h))
align_cad = horizon_enable and not na(cad_str) and not na(cad_str_h) and (math.sign(cad_str) == math.sign(cad_str_h))
align_nzd = horizon_enable and not na(nzd_str) and not na(nzd_str_h) and (math.sign(nzd_str) == math.sign(nzd_str_h))
align_usd = horizon_enable and not na(usd_str) and not na(usd_str_h) and (math.sign(usd_str) == math.sign(usd_str_h))

// Parallel array used by the dashboard's Align column (v1.8). Index matches
// curr_strengths / curr_names: 0=EUR, 1=GBP, 2=JPY, 3=CHF, 4=AUD, 5=CAD, 6=NZD, 7=USD.
curr_aligns = array.from(align_eur, align_gbp, align_jpy, align_chf, align_aud, align_cad, align_nzd, align_usd)


// --- PLOTS -----------------------------------------------------------------

plot(eur_str, title="EUR", color=eur_color, linewidth=2)
plot(gbp_str, title="GBP", color=gbp_color, linewidth=2)
plot(jpy_str, title="JPY", color=jpy_color, linewidth=2)
plot(chf_str, title="CHF", color=chf_color, linewidth=2)
plot(aud_str, title="AUD", color=aud_color, linewidth=2)
plot(cad_str, title="CAD", color=cad_color, linewidth=2)
plot(nzd_str, title="NZD", color=nzd_color, linewidth=2)
plot(usd_str, title="USD", color=usd_color, linewidth=2)

// Note: HTF strength comparison and per-currency histograms were removed
// from the plot output to stay under TradingView's 64-plot limit. The HTF
// info is still computed and displayed in the dashboard's "HTF" and
// "Align" columns, which is where it's most useful anyway.

// Decomposition lines — opacity user-controlled via pc_opacity input.
// Pine's color.new takes transparency where 0=opaque, 100=invisible.
// We expose opacity to the user (where 100=opaque, 0=invisible) and convert.
pc_transparency = 100 - pc_opacity
plot(show_basket_mean ? pc1_smooth : na, title="PC1 (USD vs basket)",
     color=color.new(primary_color, pc_transparency), linewidth=2, style=plot.style_line)
plot(show_commodity_spread ? pc2_proxy : na, title="PC2 (Commodity - Safe-haven)",
     color=color.new(#FFA500, pc_transparency), linewidth=2, style=plot.style_line)

// Compression and velocity overlays
plot(show_compression ? basket_disp : na, title="Basket Compression",
     color=color.new(#FFFFFF, 60), linewidth=1, style=plot.style_line)
plot(show_velocity ? basket_velocity : na, title="Basket Velocity",
     color=color.new(primary_color, 50), style=plot.style_histogram)

// Thresholds
plot(show_thresholds ? upper_threshold : na, title="Upper s",     color=color.new(bullish_color, 70))
plot(show_thresholds ? lower_threshold : na, title="Lower s",     color=color.new(bearish_color, 70))
plot(show_thresholds ? avg_strength    : na, title="Basket Mean", color=color.new(color.gray, 50))
// ±2s extreme threshold lines are intentionally not plotted — the ±1s
// bands above are sufficient for visual reference, and dropping the
// extreme plots keeps total output count well under TradingView's limit.

hline(0, "Zero", color=color.new(color.gray, 70), linestyle=hline.style_dotted)

// Hook and divergence markers were removed in v1.2 following cross-symbol
// validation that showed they did not produce reliable directional edge.
// CRSM is positioned as a strength dashboard, not a signal generator.

// Optional soft background tint during confluent haven extremes (v1.4).
// Green during risk-on (haven weak), red during risk-off (haven strong).
bgcolor(show_haven_bg and haven_risk_on  ? color.new(bullish_color, 92) : na, title="Haven Risk-On bg")
bgcolor(show_haven_bg and haven_risk_off ? color.new(bearish_color, 92) : na, title="Haven Risk-Off bg")


// --- DASHBOARD -------------------------------------------------------------

dash_pos_val = switch dash_position
    "top_right"     => position.top_right
    "top_left"      => position.top_left
    "middle_right"  => position.middle_right
    "middle_left"   => position.middle_left
    "bottom_right"  => position.bottom_right
    "bottom_left"   => position.bottom_left
    => position.top_right

fmt_align(b) => b ? "Y" : "N"
fmt_val(v)   => na(v) ? "—" : str.tostring(v, "#.##")

// Background-shading helpers: cell intensity scales with magnitude.
// Output transparency 100 (invisible) at magnitude 0, down to 50 (clear)
// at magnitude == max_v. Pine: transparency 0=opaque, 100=transparent.
shade_signed(v, max_v) =>
    if na(v) or max_v <= 0
        color.new(color.gray, 100)
    else
        mag   = math.min(math.abs(v) / max_v, 1.0)
        trans = math.round(100 - mag * 50)
        base  = v > 0 ? color.new(#00C853, 0) : color.new(#D32F2F, 0)
        color.new(base, trans)

shade_unsigned(v, max_v) =>
    if na(v) or max_v <= 0
        color.new(color.gray, 100)
    else
        mag   = math.min(math.abs(v) / max_v, 1.0)
        trans = math.round(100 - mag * 50)
        color.new(#4A6FA5, trans)

// Typical magnitude scales for shading (Composite-method z-score units)
SCALE_STR    = 2.0    // currency strength: ±2 = extreme
SCALE_VEL    = 0.15   // per-currency velocity
SCALE_SPREAD = 3.0    // pair spread (oriented, always positive)
SCALE_SPDVEL = 0.3    // pair spread velocity
SCALE_SCORE  = 6.0    // Activity Score

// Map text-size input to Pine size enum
dash_text_size = dash_text_size_in == "small"  ? size.small  :
                 dash_text_size_in == "large"  ? size.large  : size.normal
dash_title_size = dash_text_size_in == "small" ? size.normal :
                  dash_text_size_in == "large" ? size.huge   : size.large

// Helper: look up a currency's theme color by its index in curr_strengths/curr_names.
get_curr_color(idx) =>
    switch idx
        0 => get_eur_color()
        1 => get_gbp_color()
        2 => get_jpy_color()
        3 => get_chf_color()
        4 => get_aud_color()
        5 => get_cad_color()
        6 => get_nzd_color()
        7 => get_usd_color()
        => color.gray

if show_dashboard and barstate.islast
    var table dash = table.new(dash_pos_val, 10, 22, border_width=1,
         bgcolor=color.new(table_bg_color, 15))

    table.clear(dash, 0, 0, 9, 21)

    header_bg  = color.new(header_bg_color, 10)
    section_bg = color.new(neutral_color, 70)
    row_bg     = color.new(table_bg_color, 20)

    // ---- Row 0: Header — basket-level summary ----
    table.cell(dash, 0, 0, "CRSM",                text_color=text_color, bgcolor=header_bg, text_size=dash_title_size)
    table.cell(dash, 1, 0, "TF: " + tf_bucket,    text_color=text_color, bgcolor=header_bg, text_size=dash_text_size)
    table.cell(dash, 2, 0, regime_label,          text_color=regime_color, bgcolor=header_bg, text_size=dash_text_size)
    // Cells 3-5: Dominance flag (only populated when a currency appears
    // in =4 of the top N pairs — warns trader the list is one theme,
    // not independent opportunities).
    dom_color = dom_max_count >= 6 ? bearish_color : dom_max_count >= 4 ? primary_color : text_color
    table.cell(dash, 3, 0, "",              text_color=text_color, bgcolor=header_bg, text_size=dash_text_size)
    table.cell(dash, 4, 0, dominant_text,   text_color=dom_color, bgcolor=header_bg, text_size=dash_text_size)
    table.cell(dash, 5, 0, "",              text_color=text_color, bgcolor=header_bg, text_size=dash_text_size)
    table.cell(dash, 6, 0, "",              text_color=text_color, bgcolor=header_bg, text_size=dash_text_size)
    table.cell(dash, 7, 0, "Compress",      text_color=text_color, bgcolor=header_bg, text_size=dash_text_size)
    table.cell(dash, 8, 0, fmt_val(basket_disp), text_color=basket_disp < compression_thresh ? bullish_color : text_color, bgcolor=header_bg, text_size=dash_text_size)

    // ---- Row 1: PC1 / PC2 / Basket Velocity / Haven state ----
    haven_state_color = haven_risk_on ? bullish_color : (haven_risk_off ? bearish_color : neutral_color)
    table.cell(dash, 0, 1, "PC1",           text_color=text_color, bgcolor=section_bg, text_size=dash_text_size)
    table.cell(dash, 1, 1, fmt_val(pc1_smooth), text_color=pc1_smooth > 0 ? bullish_color : bearish_color, bgcolor=section_bg, text_size=dash_text_size)
    table.cell(dash, 2, 1, "PC2",           text_color=text_color, bgcolor=section_bg, text_size=dash_text_size)
    table.cell(dash, 3, 1, fmt_val(pc2_proxy), text_color=pc2_proxy > 0 ? bullish_color : bearish_color, bgcolor=section_bg, text_size=dash_text_size)
    table.cell(dash, 4, 1, "Basket Vel",    text_color=text_color, bgcolor=section_bg, text_size=dash_text_size)
    table.cell(dash, 5, 1, fmt_val(basket_velocity), text_color=basket_velocity > 0 ? bullish_color : bearish_color, bgcolor=section_bg, text_size=dash_text_size)
    table.cell(dash, 6, 1, "",              text_color=text_color, bgcolor=section_bg, text_size=dash_text_size)
    table.cell(dash, 7, 1, "Haven",         text_color=text_color, bgcolor=section_bg, text_size=dash_text_size)
    table.cell(dash, 8, 1, haven_state,     text_color=haven_state_color, bgcolor=section_bg, text_size=dash_text_size)

    // ---- Row 2: Pair table header ----
    pair_header_row = 2
    table.cell(dash, 0, pair_header_row, "Cur",        text_color=text_color, bgcolor=section_bg, text_size=dash_text_size)
    table.cell(dash, 1, pair_header_row, "Now",        text_color=text_color, bgcolor=section_bg, text_size=dash_text_size)
    table.cell(dash, 2, pair_header_row, "Vel",        text_color=text_color, bgcolor=section_bg, text_size=dash_text_size)
    table.cell(dash, 3, pair_header_row, "Cur",        text_color=text_color, bgcolor=section_bg, text_size=dash_text_size)
    table.cell(dash, 4, pair_header_row, "Now",        text_color=text_color, bgcolor=section_bg, text_size=dash_text_size)
    table.cell(dash, 5, pair_header_row, "Vel",        text_color=text_color, bgcolor=section_bg, text_size=dash_text_size)
    table.cell(dash, 6, pair_header_row, "Spread",     text_color=text_color, bgcolor=section_bg, text_size=dash_text_size)
    table.cell(dash, 7, pair_header_row, "Spread Vel", text_color=text_color, bgcolor=section_bg, text_size=dash_text_size)
    table.cell(dash, 8, pair_header_row, "Score",      text_color=text_color, bgcolor=section_bg, text_size=dash_text_size)
    table.cell(dash, 9, pair_header_row, "Align",      text_color=text_color, bgcolor=section_bg, text_size=dash_text_size)

    // ---- Rows 3+: Top-N pair rows, ordered by Activity Score ----
    n_to_show = math.min(top_n_pairs, array.size(sorted_pair_idx))
    if n_to_show > 0
        for k = 0 to n_to_show - 1
            idx       = array.get(sorted_pair_idx,  k)
            first_i   = array.get(pair_first_idx,   idx)
            second_i  = array.get(pair_second_idx,  idx)
            spread    = array.get(pair_spreads,     idx)
            spread_v  = array.get(pair_vels,        idx)
            score     = array.get(pair_scores,      idx)

            name1 = array.get(curr_names,      first_i)
            name2 = array.get(curr_names,      second_i)
            s1    = array.get(curr_strengths,  first_i)
            s2    = array.get(curr_strengths,  second_i)
            v1    = array.get(curr_velocities, first_i)
            v2    = array.get(curr_velocities, second_i)
            a1    = array.get(curr_aligns,     first_i)
            a2    = array.get(curr_aligns,     second_i)
            c1    = get_curr_color(first_i)
            c2    = get_curr_color(second_i)

            // Align column (v1.8): both currencies' chart-TF strength signs vs
            // their longer-horizon counterparts. Y/Y = both aligned with HTF,
            // N/N = both contradicted by HTF, mixed = partial confirmation.
            align_txt =
                 (horizon_enable ? (fmt_align(a1) + " / " + fmt_align(a2)) : "—")
            align_color =
                 not horizon_enable     ? neutral_color :
                 a1 and a2              ? bullish_color :
                 (not a1) and (not a2)  ? bearish_color :
                 neutral_color

            // Directional WORDS for spread velocity (Pine font safe).
            spread_dir_word =
                 spread_v >  arrow_threshold ? "widening" :
                 spread_v < -arrow_threshold ? "narrowing" : "stable"
            dir_color =
                 spread_v >  arrow_threshold ? bullish_color :
                 spread_v < -arrow_threshold ? bearish_color : neutral_color

            row_y = pair_header_row + 1 + k

            // Cell text content
            txt_s1     = fmt_val(s1)
            txt_v1     = fmt_val(v1)
            txt_s2     = fmt_val(s2)
            txt_v2     = fmt_val(v2)
            txt_spd    = fmt_val(spread)
            txt_spdvel = spread_dir_word + " " + fmt_val(math.abs(spread_v))
            txt_score  = fmt_val(score)

            // Render each cell with text color + magnitude-shaded background
            table.cell(dash, 0, row_y, name1, text_color=c1, bgcolor=row_bg, text_size=dash_text_size)
            table.cell(dash, 1, row_y, txt_s1,     text_color=s1 > 0 ? bullish_color : bearish_color, bgcolor=shade_signed(s1, SCALE_STR),     text_size=dash_text_size)
            table.cell(dash, 2, row_y, txt_v1,     text_color=v1 > 0 ? bullish_color : bearish_color, bgcolor=shade_signed(v1, SCALE_VEL),     text_size=dash_text_size)
            table.cell(dash, 3, row_y, name2, text_color=c2, bgcolor=row_bg, text_size=dash_text_size)
            table.cell(dash, 4, row_y, txt_s2,     text_color=s2 > 0 ? bullish_color : bearish_color, bgcolor=shade_signed(s2, SCALE_STR),     text_size=dash_text_size)
            table.cell(dash, 5, row_y, txt_v2,     text_color=v2 > 0 ? bullish_color : bearish_color, bgcolor=shade_signed(v2, SCALE_VEL),     text_size=dash_text_size)
            table.cell(dash, 6, row_y, txt_spd,    text_color=text_color,                              bgcolor=shade_unsigned(spread, SCALE_SPREAD), text_size=dash_text_size)
            table.cell(dash, 7, row_y, txt_spdvel, text_color=dir_color,                               bgcolor=shade_signed(spread_v, SCALE_SPDVEL), text_size=dash_text_size)
            table.cell(dash, 8, row_y, txt_score,  text_color=text_color,                              bgcolor=shade_unsigned(score, SCALE_SCORE),   text_size=dash_text_size)
            table.cell(dash, 9, row_y, align_txt,  text_color=align_color,                             bgcolor=row_bg,                              text_size=dash_text_size)

// ---- Currency / colour legend at bottom-center of chart panel ----
if show_dashboard and barstate.islast
    var table legend = table.new(position.bottom_center, 8, 1, border_width=0,
         bgcolor=color.new(table_bg_color, 30))
    table.cell(legend, 0, 0, " EUR ", text_color=get_eur_color(), bgcolor=color.new(table_bg_color, 30), text_size=dash_text_size)
    table.cell(legend, 1, 0, " GBP ", text_color=get_gbp_color(), bgcolor=color.new(table_bg_color, 30), text_size=dash_text_size)
    table.cell(legend, 2, 0, " JPY ", text_color=get_jpy_color(), bgcolor=color.new(table_bg_color, 30), text_size=dash_text_size)
    table.cell(legend, 3, 0, " CHF ", text_color=get_chf_color(), bgcolor=color.new(table_bg_color, 30), text_size=dash_text_size)
    table.cell(legend, 4, 0, " AUD ", text_color=get_aud_color(), bgcolor=color.new(table_bg_color, 30), text_size=dash_text_size)
    table.cell(legend, 5, 0, " CAD ", text_color=get_cad_color(), bgcolor=color.new(table_bg_color, 30), text_size=dash_text_size)
    table.cell(legend, 6, 0, " NZD ", text_color=get_nzd_color(), bgcolor=color.new(table_bg_color, 30), text_size=dash_text_size)
    table.cell(legend, 7, 0, " USD ", text_color=get_usd_color(), bgcolor=color.new(table_bg_color, 30), text_size=dash_text_size)


// --- ALERTS ----------------------------------------------------------------

// Strong / weak transitions (only fire on the bar of the cross, not every bar after)
strong_cross_eur = show_eur and ta.crossover(eur_str, upper_threshold)
strong_cross_gbp = show_gbp and ta.crossover(gbp_str, upper_threshold)
strong_cross_jpy = show_jpy and ta.crossover(jpy_str, upper_threshold)
strong_cross_chf = show_chf and ta.crossover(chf_str, upper_threshold)
strong_cross_aud = show_aud and ta.crossover(aud_str, upper_threshold)
strong_cross_cad = show_cad and ta.crossover(cad_str, upper_threshold)
strong_cross_nzd = show_nzd and ta.crossover(nzd_str, upper_threshold)
strong_cross_usd = show_usd and ta.crossover(usd_str, upper_threshold)
any_strong_cross = strong_cross_eur or strong_cross_gbp or strong_cross_jpy or strong_cross_chf or strong_cross_aud or strong_cross_cad or strong_cross_nzd or strong_cross_usd

weak_cross_eur = show_eur and ta.crossunder(eur_str, lower_threshold)
weak_cross_gbp = show_gbp and ta.crossunder(gbp_str, lower_threshold)
weak_cross_jpy = show_jpy and ta.crossunder(jpy_str, lower_threshold)
weak_cross_chf = show_chf and ta.crossunder(chf_str, lower_threshold)
weak_cross_aud = show_aud and ta.crossunder(aud_str, lower_threshold)
weak_cross_cad = show_cad and ta.crossunder(cad_str, lower_threshold)
weak_cross_nzd = show_nzd and ta.crossunder(nzd_str, lower_threshold)
weak_cross_usd = show_usd and ta.crossunder(usd_str, lower_threshold)
any_weak_cross = weak_cross_eur or weak_cross_gbp or weak_cross_jpy or weak_cross_chf or weak_cross_aud or weak_cross_cad or weak_cross_nzd or weak_cross_usd

// Compression release: compression was below threshold, now expanding
compression_release = ta.crossover(basket_disp, compression_thresh)

// Best-pair opportunity: pair potential > 2s of basket dispersion
big_opportunity = pair_potential > 2 * basket_disp and pair_potential > basket_disp[1] * 2

alertcondition(any_strong_cross,    title="Currency Crossed Upper s",  message="A currency crossed above the upper s threshold")
alertcondition(any_weak_cross,      title="Currency Crossed Lower s",  message="A currency crossed below the lower s threshold")
alertcondition(compression_release, title="Compression Release",       message="Basket compression released — directional move likely")
alertcondition(big_opportunity,     title="High-Potential Pair",       message="Strongest/weakest spread > 2s — high-conviction setup")
alertcondition(regime_label == "COMPRESSED" and regime_label[1] != "COMPRESSED", title="Regime ? Compressed", message="Market entered compression regime")
alertcondition(regime_label == "TRENDING"   and regime_label[1] != "TRENDING",   title="Regime ? Trending",   message="Market entered trending regime")
alertcondition(regime_label == "CRISIS"     and regime_label[1] != "CRISIS",     title="Regime ? Crisis",     message="Market entered crisis regime")
// Hook and divergence alerts removed in v1.2.



// Haven Extreme detector (v1.4) — fire on transition into state
haven_risk_on_start  = haven_risk_on  and not haven_risk_on[1]
haven_risk_off_start = haven_risk_off and not haven_risk_off[1]
alertcondition(haven_risk_on_start,  title="Haven ? Risk-On",  message="=2 of JPY/CHF dropped below threshold — risk-on regime active. Non-JPY pairs tend to rally.")
alertcondition(haven_risk_off_start, title="Haven ? Risk-Off", message="=2 of JPY/CHF rose above threshold — risk-off regime active. JPY-quote pairs tend to fall.")

// ---------------------------------------------------------------------------
// DISCLAIMER
// This indicator is educational. Past performance does not predict future
// results. Always combine with independent analysis and risk management.
// ---------------------------------------------------------------------------
````
