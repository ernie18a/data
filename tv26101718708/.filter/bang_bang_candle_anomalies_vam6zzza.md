# Bang! Bang! - Candle Anomalies

- url: https://www.tradingview.com/script/VAM6zZzA-Bang-Bang-Candle-Anomalies/
- type: indicator
- pine_id: PUB;52dd874cfd8b451c9a0922a0f8830384
- version: 1.0

## Description

[b]Bang! Bang! — Candle Anomalies[/b]

[i][b]Overview[/b][/i]

Bang! Bang! is a volume-anomaly detector. It flags bars where volume looks unusual against its recent neighbors and tags each anomaly with a direction (buy or sell), a tier (Bang! for notable, Bang! Bang! for extreme), and a placement on the chart that reflects where the activity actually concentrated.

Two independent detection pipelines can run side by side. Each one decides for itself when to fire, picks its own engine (bar-level or sub-bar level), and uses its own statistical threshold method. You can run both pipelines together for confluence, or just one for a cleaner chart. The indicator works on any chart type — time-based, Renko, Range, Point & Figure, Kagi, and Line Break — with intelligent fallback when a particular engine isn't available for the chart you're on.

[i][b]Features[/b][/i]

Two detection engines (picked per baseline mode):

- [i]Intensity Engine[/i] (default) — bar-level volume analysis. Works on any chart type. A Volume Basis input lets you pick plain `volume` or `volume / bar duration` (a volume rate that respects how urgently a bar formed). The plain-volume basis turns this into a pure volume-anomaly detector; the rate basis is what makes the engine meaningful on non-time-based charts where bar duration varies.
- [i]Delta Engine[/i] — sub-bar decomposition via lower-timeframe candles. Splits the chart bar's volume into buy-side and sell-side based on sub-bar direction, and places the dot at the highest-volume sub-bar's hl2 (so the mark lands where the activity actually concentrated within the bar). Time-based charts only; on Renko, Range, P&F, Kagi, and Line Break it silently falls back to Intensity.

  *Note on the Lower Timeframe input:* the default is 1 minute, which works on every TradingView plan. If you have a Premium account, dropping the Lower Timeframe to a seconds-based value like 5S gives much finer sub-bar resolution and noticeably sharper direction and placement attribution from the Delta Engine.

[i][b]Three threshold methods (picked per baseline mode):[/b][/i]

- [i]Sigma [/i](default) — mean + N × stdev. The classical mean + standard deviation model.
- [i]MAD [/i]— median + N × MAD × 1.4826. Robust to outliers, since the events being detected don't contaminate the baseline.
- [i]Percentile [/i]— top X% of the rolling window. Distribution-agnostic and well-suited to heavy-tailed volume data.

[i][b]Two independent baseline modes (both enabled by default):[/b]
[/i]
- [i]Unified Baseline[/i] — one rolling baseline on the full magnitude signal, with direction tagged separately. Best when you want a single, robust "this bar is unusual" call.
-[i] Parallel Baseline[/i] — two rolling baselines, one for buy-side magnitude and one for sell-side. The side whose magnitude jumps gets the dot. Surfaces cases where one side of the flow becomes unusual independently of the other.

Each mode has its own Engine, Threshold Method, and Volume Basis, so you can configure them differently in the same chart (e.g., Unified on Sigma + Intensity for a stable baseline, Parallel on Percentile + Delta for sub-bar attribution).

[i]Shooting Blanks overlay[/i] (Delta Engine only) — a small yellow dot when a Bang! or Bang! Bang! Delta dot fires AND the bar closes against its sub-bar flow direction. A "where did all that flow go?" tell that highlights bars where the heavy side of the sub-bar flow didn't carry the close — useful for spotting absorption-like patterns, late-bar reversals, and liquidity events.

[i]Per-mode color customization[/i] — 14 user-configurable color slots across four groups (Unified Intensity, Unified Delta, Parallel Intensity, Parallel Delta), so each mode/engine combination can be styled independently. The Delta gradient is a five-step scale (Heavy Buyers → Light Buyers → Balanced → Light Sellers → Heavy Sellers) so dot color encodes conviction.

[i]18 alert conditions[/i] — 9 per baseline mode, suffixed `(Unified)` or `(Parallel)` so per-mode firings stay unambiguous: `Bang!`, `Bang! Bang!`, `Bang! Buy`, `Bang! Sell`, `Bang! Bang! Buy`, `Bang! Bang! Sell`, `Bang! Bang! Balanced`, `Shooting Blanks (Buyers Failed)`, `Shooting Blanks (Sellers Failed)`.

[i]Sensible, conservative defaults[/i] — Sensitivity = 6.0 and Tier Spacing = 2.0 by default, so Bang! fires at 6σ and Bang! Bang! at 8σ above the rolling mean. Tuned for the strongest anomalies only; turn them down for more frequent signals.

[i][b]Visuals[/b][/i]

The indicator plots up to three types of marks per bar:

[i]Triangles — Unified Baseline[/i]

- **Triangle Up** appears below the bar when the magnitude jumped on a buy-direction bar.
- **Triangle Down** appears above the bar when the magnitude jumped on a sell-direction bar.
- **Size** encodes the tier — small triangle for Bang!, slightly larger triangle for Bang! Bang!.
- **Color** comes from the Unified color inputs (default 80% opacity so the smaller triangles read clearly).

[i]Circles — Parallel Baseline[/i]

- A circle is placed at the bar's hl2 (Intensity Engine) or at the highest-volume sub-bar's hl2 (Delta Engine).
- **Size** encodes the tier — normal circle for Bang!, large circle for Bang! Bang!.
- **Color** comes from the Parallel color inputs (default 50% opacity).

When the **Delta Engine** is active in either mode, dot color also encodes sub-bar flow direction via a five-step gradient:

- **Heavy Buyers** — strongly buy-dominated sub-bar flow
- **Light Buyers** — moderately buy-leaning
- **Balanced** — roughly balanced buy/sell sub-bars (the neutral-grey middle of the gradient)
- **Light Sellers** — moderately sell-leaning
- **Heavy Sellers** — strongly sell-dominated

[i]Shooting Blanks yellow dot[/i]

- A small yellow circle at the highest-volume sub-bar's hl2 when the Delta engine fires AND the close direction contradicts the sub-bar flow direction.
- Renders on top of any main dot sharing the same location, so the divergence reads at a glance.
- One shared dot per qualifying bar regardless of how many baseline modes detected the anomaly.

When both baseline modes fire on the same bar — Unified detecting a magnitude jump and Parallel detecting a side-specific jump — you'll see both marks together: a triangle outside the bar plus a circle inside it. Two independent confirmations from two different baseline approaches.

---

*Inspired by @colacorn's "Big Trades Whale Detector" — full credit for the core concept of statistical volume-anomaly detection on candle bars.*

## Source Code

````pine
//@version=6
// ============================================================================
// Bang! Bang! — Candle Anomalies
// ============================================================================
//
// What it does
// ------------
// Flags bars where volume looks unusual against its recent neighbors. Two
// independent detection pipelines can run side by side; each one decides for
// itself when to fire.
//
//   Unified Baseline  →  triangles outside the bar
//     One rolling baseline on the full magnitude signal. Triangle Up below
//     the bar for buy direction, Triangle Down above for sell. Sizes one tier
//     smaller than the Parallel circles (Bang! = tiny, Bang! Bang! = small).
//
//   Parallel Baseline  →  circles inside the bar
//     Two baselines, one for buy-side magnitude, one for sell-side. The side
//     whose magnitude jumps gets the dot, placed at hl2 (Intensity) or at the
//     highest-volume sub-bar's hl2 (Delta). Bang! = normal, Bang! Bang! = large.
//
// Two engines feed the magnitude signal:
//
//   Intensity Engine (default)
//     Bar-level volume. Works on any chart type. The Volume Basis input picks
//     plain `volume` (Raw Volume — matches the original Big Trades Detector)
//     or `volume / bar_duration_sec` (Magnitude — a volume rate that respects
//     how urgently a bar formed).
//
//   Delta Engine
//     Sub-bar decomposition via request.security_lower_tf(). Splits volume
//     into buy-side and sell-side by sub-bar direction, and places the dot at
//     the highest-volume sub-bar's hl2. Time-based charts only; on Renko,
//     Range, P&F, Kagi, and Line Break charts it silently falls back to
//     Intensity.
//
// Three threshold methods decide what counts as "unusual":
//
//   Sigma (default)  →  mean + N × stdev. Familiar; assumes normal distribution.
//   MAD              →  median + N × MAD × 1.4826. Robust to outliers.
//   Percentile       →  top-X% of the rolling window. Distribution-agnostic.
//
// Each baseline mode picks its own Engine, Threshold Method, and Volume Basis.
// Lookback, Lower Timeframe, and the Sigma/MAD and Percentile parameters are
// universal — one set of dials feeds whichever pipeline(s) you have enabled.
//
// Shooting Blanks overlay (Delta Engine only)
// -------------------------------------------
// A small yellow dot at the highest-volume sub-bar's hl2 when a Bang! or
// Bang! Bang! Delta dot fires AND the bar's close direction contradicts its
// sub-bar flow direction — a "where did all that flow go?" tell. One shared
// dot per qualifying bar regardless of how many baseline modes are enabled.
//
// Shout out to @colacorn and their "Big Trades Whale Detector" for inspiring this project.
// ============================================================================

indicator(title = "Bang! Bang! - Candle Anomalies", shorttitle = "Bang! Bang!", overlay = true)

// === 1. CONSTANTS ===

const float  DURATION_FLOOR_SEC      = 0.1
const float  GRAY_THRESHOLD          = 0.15
const float  LIGHT_THRESHOLD         = 0.5
const float  MAD_NORMAL_CONSISTENCY  = 1.4826   // MAD × this ≈ stdev under a normal distribution
const string ENGINE_INTENSITY        = "Intensity"
const string ENGINE_DELTA            = "Delta"
const string METHOD_PERCENTILE       = "Percentile"
const string METHOD_MAD              = "MAD"
const string METHOD_SIGMA            = "Sigma"
const string BASIS_RAW               = "Raw Volume"
const string BASIS_MAGNITUDE         = "Magnitude"

// === 2. INPUTS ===
// Universal inputs first, then per-baseline-mode settings, then colors. Each
// mode's Engine / Threshold Method / Volume Basis is independent so Unified
// and Parallel can be configured differently in the same chart.

// --- Detection (universal) ---
int input_lookback                = input.int(20, "Lookback", minval = 2, step = 1, group = "Detection", tooltip = "Number of bars used for rolling baseline. Current bar excluded. Applies to both baseline modes.")
input_lower_timeframe             = input.timeframe("1", "Lower Timeframe", group = "Detection", tooltip = "Lower timeframe for sub-bar decomposition in the Delta Engine. Must be smaller than chart timeframe. Default is 1 minute because seconds-based timeframes require a TradingView Premium account. If you have Premium, dropping this to a smaller value like 5S (or even 1S on the highest tiers) gives much finer sub-bar resolution and noticeably sharper direction and placement attribution. Used by whichever baseline mode has Engine = Delta.")

// --- Sigma / MAD Parameters (universal) ---
float input_sensitivity           = input.float(6.0, "Sensitivity", minval = 1.0, step = 0.1, group = "Sigma / MAD Parameters", tooltip = "Threshold multiplier for the Bang! tier. Under Sigma, Bang! fires at mean + Sensitivity × stdev. Under MAD, Bang! fires at median + Sensitivity × MAD × 1.4826. Higher = fewer, more extreme signals. Applies to any mode whose Threshold Method = Sigma or MAD.")
float input_tier_spacing          = input.float(2.0, "Tier Spacing", minval = 0.5, step = 0.1, group = "Sigma / MAD Parameters", tooltip = "Additional units beyond Sensitivity where Bang! Bang! fires. Default 2.0 means Bang! Bang! fires at Sensitivity + 2 = 8 units. Applies to any mode whose Threshold Method = Sigma or MAD.")

// --- Percentile Parameters (universal) ---
float input_bang_percentile       = input.float(95.0, "Bang! Percentile", minval = 80.0, maxval = 99.5, step = 0.5, group = "Percentile Parameters", tooltip = "Percentile rank above which Bang! fires. Applies to any mode whose Threshold Method = Percentile.")
float input_bang_bang_percentile  = input.float(99.0, "Bang! Bang! Percentile", minval = 90.0, maxval = 99.9, step = 0.1, group = "Percentile Parameters", tooltip = "Percentile rank above which Bang! Bang! fires. Must be greater than Bang! Percentile. Applies to any mode whose Threshold Method = Percentile.")

// --- Unified Baseline ---
input_unified_enabled             = input.bool(true, "Enable Unified Baseline", group = "Unified Baseline", tooltip = "When enabled, the Unified Baseline pipeline plots triangles for anomalous bars. Triangle Up below the bar for Buy, Triangle Down above the bar for Sell. Sizes one tier smaller than the Parallel circles.")
input_unified_engine              = input.string(ENGINE_INTENSITY, "Engine", options = [ENGINE_DELTA, ENGINE_INTENSITY], group = "Unified Baseline", tooltip = "Engine used by the Unified Baseline pipeline. Delta uses sub-bar decomposition and falls back to Intensity on non-time-based charts. Intensity uses bar volume per the Volume Basis selection.")
input_unified_threshold_method    = input.string(METHOD_SIGMA, "Threshold Method", options = [METHOD_SIGMA, METHOD_PERCENTILE, METHOD_MAD], group = "Unified Baseline", tooltip = "Threshold computation method for the Unified Baseline pipeline. Sigma (default) is the classical mean + N × stdev model. Percentile is distribution-agnostic. MAD is robust to outliers.")
input_unified_volume_basis        = input.string(BASIS_RAW, "Volume Basis", options = [BASIS_RAW, BASIS_MAGNITUDE], group = "Unified Baseline", tooltip = "Volume basis used when the Unified pipeline's engine resolves to Intensity (selected or fallback). Raw Volume = plain bar volume; Magnitude = volume per second of bar formation. No effect under Delta.")

// --- Parallel Baseline ---
input_parallel_enabled            = input.bool(true, "Enable Parallel Baseline", group = "Parallel Baseline", tooltip = "When enabled, the Parallel Baseline pipeline plots circles for anomalous bars. Tracks two baselines (buy and sell) via proportional split of each bar's magnitude.")
input_parallel_engine             = input.string(ENGINE_INTENSITY, "Engine", options = [ENGINE_DELTA, ENGINE_INTENSITY], group = "Parallel Baseline", tooltip = "Engine used by the Parallel Baseline pipeline. Delta uses sub-bar decomposition and falls back to Intensity on non-time-based charts. Intensity uses bar volume per the Volume Basis selection. On non-time-based charts Parallel behaves as a reversal detector because the close-position split collapses.")
input_parallel_threshold_method   = input.string(METHOD_SIGMA, "Threshold Method", options = [METHOD_SIGMA, METHOD_PERCENTILE, METHOD_MAD], group = "Parallel Baseline", tooltip = "Threshold computation method for the Parallel Baseline pipeline. Sigma (default) is the classical mean + N × stdev model. Percentile is distribution-agnostic. MAD is robust to outliers.")
input_parallel_volume_basis       = input.string(BASIS_RAW, "Volume Basis", options = [BASIS_RAW, BASIS_MAGNITUDE], group = "Parallel Baseline", tooltip = "Volume basis used when the Parallel pipeline's engine resolves to Intensity (selected or fallback). Raw Volume = plain bar volume; Magnitude = volume per second of bar formation. No effect under Delta.")

// --- Unified Intensity Engine Colors ---
input_unified_intensity_buy  = input.color(color.new(#5b9cf6, 20), "Buy",  group = "Unified Intensity Engine Colors", tooltip = "Color for buy events on the Unified Intensity triangles.")
input_unified_intensity_sell = input.color(color.new(#f23645, 20), "Sell", group = "Unified Intensity Engine Colors", tooltip = "Color for sell events on the Unified Intensity triangles.")

// --- Unified Delta Engine Colors ---
input_unified_delta_heavy_buyers  = input.color(color.new(#5b9cf6, 20), "Heavy Buyers",  group = "Unified Delta Engine Colors", tooltip = "Color for dominant buy-side sub-bar flow (delta ratio ≥ 0.5) on Unified triangles.")
input_unified_delta_light_buyers  = input.color(color.new(#a2c8f5, 20), "Light Buyers",  group = "Unified Delta Engine Colors", tooltip = "Color for moderate buy-side sub-bar flow on Unified triangles.")
input_unified_delta_balanced      = input.color(color.new(#8f8e8e, 20), "Balanced",      group = "Unified Delta Engine Colors", tooltip = "Color for balanced sub-bar flow on Unified triangles.")
input_unified_delta_light_sellers = input.color(color.new(#f77c80, 20), "Light Sellers", group = "Unified Delta Engine Colors", tooltip = "Color for moderate sell-side sub-bar flow on Unified triangles.")
input_unified_delta_heavy_sellers = input.color(color.new(#f23645, 20), "Heavy Sellers", group = "Unified Delta Engine Colors", tooltip = "Color for dominant sell-side sub-bar flow on Unified triangles.")

// --- Parallel Intensity Engine Colors ---
input_parallel_intensity_buy  = input.color(color.new(#5b9cf6, 50), "Buy",  group = "Parallel Intensity Engine Colors", tooltip = "Color for buy events on the Parallel Intensity circles.")
input_parallel_intensity_sell = input.color(color.new(#f23645, 50), "Sell", group = "Parallel Intensity Engine Colors", tooltip = "Color for sell events on the Parallel Intensity circles.")

// --- Parallel Delta Engine Colors ---
input_parallel_delta_heavy_buyers  = input.color(color.new(#5b9cf6, 50), "Heavy Buyers",  group = "Parallel Delta Engine Colors", tooltip = "Color for dominant buy-side sub-bar flow (delta ratio ≥ 0.5) on Parallel circles.")
input_parallel_delta_light_buyers  = input.color(color.new(#a2c8f5, 50), "Light Buyers",  group = "Parallel Delta Engine Colors", tooltip = "Color for moderate buy-side sub-bar flow on Parallel circles.")
input_parallel_delta_balanced      = input.color(color.new(#8f8e8e, 50), "Balanced",      group = "Parallel Delta Engine Colors", tooltip = "Color for balanced sub-bar flow on Parallel circles.")
input_parallel_delta_light_sellers = input.color(color.new(#f77c80, 50), "Light Sellers", group = "Parallel Delta Engine Colors", tooltip = "Color for moderate sell-side sub-bar flow on Parallel circles.")
input_parallel_delta_heavy_sellers = input.color(color.new(#f23645, 50), "Heavy Sellers", group = "Parallel Delta Engine Colors", tooltip = "Color for dominant sell-side sub-bar flow on Parallel circles.")

// --- Shooting Blanks ---
input_enable_shooting_blanks = input.bool(true, "Enable Shooting Blanks", group = "Shooting Blanks", tooltip = "Enables the Shooting Blanks overlay — a small yellow dot at the highest-volume sub-bar's hl2 when a Bang! or Bang! Bang! Delta-engine dot fires and the bar's close direction contradicts its sub-bar flow direction. One shared dot per qualifying bar regardless of how many baseline modes are enabled.")
input_shooting_blanks_color  = input.color(color.new(color.yellow, 20), "Shooting Blanks Color", group = "Shooting Blanks", tooltip = "Color for Shooting Blanks overlay dots.")

// === 3. ENGINE RESOLUTION ===
// Pick each mode's active engine, then validate any inputs that the active
// engine(s) need. Validation is gated so users on Intensity-only configs
// don't see Delta-specific errors.

// Renko/Range/P&F/Kagi/Line Break don't provide sub-bar data, so a Delta
// selection silently runs Intensity on those instead. The settings dialog
// still shows "Delta" — the fallback is quiet by design.
is_non_time_based = chart.is_renko or chart.is_range or chart.is_pnf or chart.is_kagi or chart.is_linebreak

unified_active_engine  = (input_unified_engine  == ENGINE_DELTA and is_non_time_based) ? ENGINE_INTENSITY : input_unified_engine
parallel_active_engine = (input_parallel_engine == ENGINE_DELTA and is_non_time_based) ? ENGINE_INTENSITY : input_parallel_engine

// Lower Timeframe must be smaller than the chart TF — only check when at
// least one enabled mode is actually using the Delta engine.
unified_needs_ltf  = input_unified_enabled  and unified_active_engine  == ENGINE_DELTA
parallel_needs_ltf = input_parallel_enabled and parallel_active_engine == ENGINE_DELTA
if unified_needs_ltf or parallel_needs_ltf
    ltf_seconds   = timeframe.in_seconds(input_lower_timeframe)
    chart_seconds = timeframe.in_seconds(timeframe.period)
    if ltf_seconds >= chart_seconds
        runtime.error("Lower Timeframe (" + input_lower_timeframe + ", " + str.tostring(ltf_seconds) + "s) must be smaller than the chart timeframe (" + timeframe.period + ", " + str.tostring(chart_seconds) + "s). Adjust the Lower Timeframe input in the Detection group.")

// Bang! Bang! Percentile must exceed Bang! Percentile or the tiers would
// invert — only check when at least one enabled mode is on Percentile.
unified_uses_percentile  = input_unified_enabled  and input_unified_threshold_method  == METHOD_PERCENTILE
parallel_uses_percentile = input_parallel_enabled and input_parallel_threshold_method == METHOD_PERCENTILE
if (unified_uses_percentile or parallel_uses_percentile) and input_bang_bang_percentile <= input_bang_percentile
    runtime.error("Bang! Bang! Percentile (" + str.tostring(input_bang_bang_percentile) + ") must be greater than Bang! Percentile (" + str.tostring(input_bang_percentile) + "). Adjust the percentile inputs in the Percentile Parameters group.")

// === 4. STATISTICAL DETECTION CORE ===
//
// Each method returns [bang_threshold, bang_bang_threshold] for a magnitude
// series. resolve_thresholds() picks the right method per mode; compute_excess()
// normalizes how far above its threshold a magnitude sits for the Parallel
// tie-breaker. All other downstream logic (tier exclusivity, warmup, color)
// is method-agnostic.

// Sigma: mean + multiplier × stdev.
compute_sigma_thresholds(rolling_mean, rolling_stdev, simple float sensitivity, simple float tier_spacing) =>
    [rolling_mean + rolling_stdev * sensitivity, rolling_mean + rolling_stdev * (sensitivity + tier_spacing)]

// Percentile: the threshold IS the lookback's percentile rank.
compute_percentile_thresholds(simple int lookback, simple float bang_pct, simple float bang_bang_pct, magnitude_series) =>
    bang_th      = ta.percentile_linear_interpolation(magnitude_series, lookback, bang_pct)[1]
    bang_bang_th = ta.percentile_linear_interpolation(magnitude_series, lookback, bang_bang_pct)[1]
    [bang_th, bang_bang_th]

// MAD: median + multiplier × MAD × 1.4826. The 1.4826 makes MAD numerically
// comparable to stdev on normal-like data, so the same Sensitivity value gives
// similar threshold severity under either Sigma or MAD on normal-shaped data.
compute_mad_thresholds(median_baseline, mad_value, simple float sensitivity, simple float tier_spacing) =>
    bang_th      = median_baseline + sensitivity * mad_value * MAD_NORMAL_CONSISTENCY
    bang_bang_th = median_baseline + (sensitivity + tier_spacing) * mad_value * MAD_NORMAL_CONSISTENCY
    [bang_th, bang_bang_th]

// Dispatch helper — picks the right threshold method for a given magnitude
// series. Pre-computed stats (mean/stdev for Sigma, median/MAD for MAD) are
// passed in so the call sites can share them across Sigma/MAD without
// recomputing.
resolve_thresholds(simple string method, magnitude, rolling_mean, rolling_stdev, median_baseline, mad_value) =>
    if method == METHOD_PERCENTILE
        compute_percentile_thresholds(input_lookback, input_bang_percentile, input_bang_bang_percentile, magnitude)
    else if method == METHOD_MAD
        compute_mad_thresholds(median_baseline, mad_value, input_sensitivity, input_tier_spacing)
    else
        compute_sigma_thresholds(rolling_mean, rolling_stdev, input_sensitivity, input_tier_spacing)

// How far above its active threshold the magnitude sits, normalized per method
// so the Parallel tie-breaker (Section 8) can compare buy-side excess vs
// sell-side excess fairly:
//   Sigma      → in stdev units
//   MAD        → in MAD units (the 1.4826 cancels between sides)
//   Percentile → fractional excess relative to the threshold itself
compute_excess(simple string method, magnitude, active_thresh, rolling_stdev, mad_value) =>
    if method == METHOD_SIGMA
        (magnitude - active_thresh) / rolling_stdev
    else if method == METHOD_MAD
        (magnitude - active_thresh) / mad_value
    else
        (magnitude - active_thresh) / active_thresh

// === 5. INTENSITY ENGINE ===

// Returns the bar's magnitude signal under the selected Volume Basis.
// Raw Volume = plain `volume`; Magnitude = `volume / bar_duration_sec` (the
// floor keeps instant-print bars from blowing up the division). Direction is
// computed once in Section 7 since it doesn't depend on Volume Basis.
intensity_magnitude(simple string volume_basis) =>
    if volume_basis == BASIS_RAW
        volume
    else
        bar_duration_sec = math.max((time_close - time) / 1000.0, DURATION_FLOOR_SEC)
        volume / bar_duration_sec

// === 6. DELTA ENGINE ===

// Pulls sub-bar candles inside the chart bar via request.security_lower_tf()
// and returns:
//   total        — total sub-bar volume (magnitude signal)
//   sub_buy      — sum of volume on bullish sub-bars (close > open)
//   sub_sell     — sum of volume on bearish sub-bars (close < open)
//   placement    — hl2 of the highest-volume sub-bar (where the dot will plot)
// Flat-close sub-bars (close == open) contribute to total but neither side.
compute_delta_engine(simple string symbol, simple string ltf) =>
    sub_volumes = request.security_lower_tf(symbol, ltf, volume)
    sub_opens   = request.security_lower_tf(symbol, ltf, open)
    sub_closes  = request.security_lower_tf(symbol, ltf, close)
    sub_highs   = request.security_lower_tf(symbol, ltf, high)
    sub_lows    = request.security_lower_tf(symbol, ltf, low)

    n             = array.size(sub_volumes)
    total         = 0.0
    sub_buy       = 0.0
    sub_sell      = 0.0
    float placement = na

    if n > 0
        total := array.sum(sub_volumes)
        for i = 0 to n - 1
            v = array.get(sub_volumes, i)
            o = array.get(sub_opens, i)
            c = array.get(sub_closes, i)
            if c > o
                sub_buy := sub_buy + v
            else if c < o
                sub_sell := sub_sell + v

        // Place the dot at the hl2 of the busiest sub-bar — where the volume
        // actually concentrated within this chart bar.
        max_idx = array.indexof(sub_volumes, array.max(sub_volumes))
        if max_idx >= 0
            placement := (array.get(sub_highs, max_idx) + array.get(sub_lows, max_idx)) / 2

    [total, sub_buy, sub_sell, placement]

// === 7. PER-ENGINE OUTPUTS AND MAGNITUDES ===
// Compute the per-mode magnitude signals here so the tier-determination block
// below can stay focused on threshold math.

// --- Intensity Engine outputs ---
// One magnitude call per mode (each mode picks its own Volume Basis). Direction
// and placement are bar-level and don't depend on Volume Basis, so they're
// computed once.
unified_volume_intensity  = intensity_magnitude(input_unified_volume_basis)
parallel_volume_intensity = intensity_magnitude(input_parallel_volume_basis)
intensity_direction       = close > open ? 1 : close < open ? -1 : 0   // 1 = buy, -1 = sell, 0 = doji
intensity_placement       = (high + low) / 2

// --- Delta Engine outputs ---
// Single call shared by both modes when their Engine = Delta. Delta-engine
// quantities (net_delta, delta_ratio) are also mode-agnostic.
[total_volume, sub_buy_vol, sub_sell_vol, delta_placement] = compute_delta_engine(syminfo.tickerid, input_lower_timeframe)
net_delta   = sub_buy_vol - sub_sell_vol
delta_ratio = total_volume > 0 ? net_delta / total_volume : 0.0

// --- Per-mode active-engine flags ---
is_unified_intensity_active  = unified_active_engine  == ENGINE_INTENSITY
is_unified_delta_active      = unified_active_engine  == ENGINE_DELTA
is_parallel_intensity_active = parallel_active_engine == ENGINE_INTENSITY
is_parallel_delta_active     = parallel_active_engine == ENGINE_DELTA

// --- Unified-mode magnitude --- one signal per bar from the Unified engine.
unified_magnitude = is_unified_intensity_active ? unified_volume_intensity : total_volume

// --- Parallel-mode magnitudes (one per side) ---
// Intensity splits the bar's volume by close-position within the range (where
// did the bar close — high side or low side?). Zero-range dojis split 50/50 so
// both baselines stay fed. Delta uses the actual sub-bar attribution directly.
intensity_range          = high - low
intensity_buy_fraction   = intensity_range == 0 ? 0.5 : (close - low)  / intensity_range
intensity_sell_fraction  = intensity_range == 0 ? 0.5 : (high - close) / intensity_range
par_intensity_buy_mag    = parallel_volume_intensity * intensity_buy_fraction
par_intensity_sell_mag   = parallel_volume_intensity * intensity_sell_fraction

par_buy_magnitude  = is_parallel_intensity_active ? par_intensity_buy_mag  : sub_buy_vol
par_sell_magnitude = is_parallel_intensity_active ? par_intensity_sell_mag : sub_sell_vol

// === 8. TIER DETERMINATION ===
// Per mode, derive [bang, bang_bang] thresholds from the magnitude's recent
// baseline and check the current bar against them. Sigma stats and MAD stats
// are computed unconditionally — per-bar cost is small, and keeping every
// variable defined simplifies the 3-way method dispatch.

// --- Unified path ---
unified_rolling_mean  = ta.sma(unified_magnitude,   input_lookback)[1]
unified_rolling_stdev = ta.stdev(unified_magnitude, input_lookback)[1]
unified_median        = ta.median(unified_magnitude, input_lookback)[1]
unified_abs_dev       = math.abs(unified_magnitude - unified_median)
unified_mad           = ta.median(unified_abs_dev, input_lookback)[1]

[unified_bang_threshold, unified_bang_bang_threshold] = resolve_thresholds(input_unified_threshold_method, unified_magnitude, unified_rolling_mean, unified_rolling_stdev, unified_median, unified_mad)

// Bang! Bang! suppresses Bang! on the same bar (tier exclusivity).
unified_is_bang_bang = unified_magnitude > unified_bang_bang_threshold
unified_is_bang      = unified_magnitude > unified_bang_threshold and not unified_is_bang_bang

// --- Parallel path: per-side stats ---
par_buy_mean     = ta.sma(par_buy_magnitude,    input_lookback)[1]
par_buy_stdev    = ta.stdev(par_buy_magnitude,  input_lookback)[1]
par_sell_mean    = ta.sma(par_sell_magnitude,   input_lookback)[1]
par_sell_stdev   = ta.stdev(par_sell_magnitude, input_lookback)[1]
par_buy_median   = ta.median(par_buy_magnitude,  input_lookback)[1]
par_sell_median  = ta.median(par_sell_magnitude, input_lookback)[1]
par_buy_abs_dev  = math.abs(par_buy_magnitude  - par_buy_median)
par_sell_abs_dev = math.abs(par_sell_magnitude - par_sell_median)
par_buy_mad      = ta.median(par_buy_abs_dev,  input_lookback)[1]
par_sell_mad     = ta.median(par_sell_abs_dev, input_lookback)[1]

[par_bang_buy_threshold,  par_bang_bang_buy_threshold]  = resolve_thresholds(input_parallel_threshold_method, par_buy_magnitude,  par_buy_mean,  par_buy_stdev,  par_buy_median,  par_buy_mad)
[par_bang_sell_threshold, par_bang_bang_sell_threshold] = resolve_thresholds(input_parallel_threshold_method, par_sell_magnitude, par_sell_mean, par_sell_stdev, par_sell_median, par_sell_mad)

// Per-side tier exclusivity (same rule as Unified, applied independently per side).
par_bb_buy_pre  = par_buy_magnitude  > par_bang_bang_buy_threshold
par_b_buy_pre   = par_buy_magnitude  > par_bang_buy_threshold       and not par_bb_buy_pre
par_bb_sell_pre = par_sell_magnitude > par_bang_bang_sell_threshold
par_b_sell_pre  = par_sell_magnitude > par_bang_sell_threshold      and not par_bb_sell_pre

// Tie-breaker — when both buy and sell sides cross their thresholds on the
// same bar, the side with the larger normalized excess wins. Buy wins on
// exact equality (rare).
buy_side_fires  = par_b_buy_pre  or par_bb_buy_pre
sell_side_fires = par_b_sell_pre or par_bb_sell_pre

buy_active_thresh  = par_bb_buy_pre  ? par_bang_bang_buy_threshold  : par_bang_buy_threshold
sell_active_thresh = par_bb_sell_pre ? par_bang_bang_sell_threshold : par_bang_sell_threshold

buy_excess  = compute_excess(input_parallel_threshold_method, par_buy_magnitude,  buy_active_thresh,  par_buy_stdev,  par_buy_mad)
sell_excess = compute_excess(input_parallel_threshold_method, par_sell_magnitude, sell_active_thresh, par_sell_stdev, par_sell_mad)

buy_wins  = buy_side_fires  and (not sell_side_fires or buy_excess  >= sell_excess)
sell_wins = sell_side_fires and (not buy_side_fires  or sell_excess >  buy_excess)

par_b_buy   = par_b_buy_pre   and buy_wins
par_bb_buy  = par_bb_buy_pre  and buy_wins
par_b_sell  = par_b_sell_pre  and sell_wins
par_bb_sell = par_bb_sell_pre and sell_wins

// === 9. COLOR / DIRECTION RESOLUTION ===
// Turn the per-mode tier flags into per-mode buy/sell firing flags, pick the
// Delta gradient color, and evaluate the Shooting Blanks divergence events.

// Doji gate: Intensity bars with close == open carry no direction. Unified
// firing flags below check direction == ±1 directly, so they exclude dojis
// implicitly. Parallel uses the gate below since its direction comes from
// which side won the tie-breaker, not from close vs. open.
intensity_doji_gate = intensity_direction != 0

// --- Unified firing flags (each gated by enable + the mode's active engine) ---
intensity_unified_b_buy   = input_unified_enabled and is_unified_intensity_active and unified_is_bang      and intensity_direction == 1
intensity_unified_b_sell  = input_unified_enabled and is_unified_intensity_active and unified_is_bang      and intensity_direction == -1
intensity_unified_bb_buy  = input_unified_enabled and is_unified_intensity_active and unified_is_bang_bang and intensity_direction == 1
intensity_unified_bb_sell = input_unified_enabled and is_unified_intensity_active and unified_is_bang_bang and intensity_direction == -1

delta_unified_b_buy   = input_unified_enabled and is_unified_delta_active and unified_is_bang      and net_delta >= 0
delta_unified_b_sell  = input_unified_enabled and is_unified_delta_active and unified_is_bang      and net_delta < 0
delta_unified_bb_buy  = input_unified_enabled and is_unified_delta_active and unified_is_bang_bang and net_delta >= 0
delta_unified_bb_sell = input_unified_enabled and is_unified_delta_active and unified_is_bang_bang and net_delta < 0

// --- Parallel firing flags (same gating; direction came from the tie-breaker) ---
intensity_parallel_b_buy   = input_parallel_enabled and is_parallel_intensity_active and par_b_buy   and intensity_doji_gate
intensity_parallel_b_sell  = input_parallel_enabled and is_parallel_intensity_active and par_b_sell  and intensity_doji_gate
intensity_parallel_bb_buy  = input_parallel_enabled and is_parallel_intensity_active and par_bb_buy  and intensity_doji_gate
intensity_parallel_bb_sell = input_parallel_enabled and is_parallel_intensity_active and par_bb_sell and intensity_doji_gate

delta_parallel_b_buy   = input_parallel_enabled and is_parallel_delta_active and par_b_buy
delta_parallel_b_sell  = input_parallel_enabled and is_parallel_delta_active and par_b_sell
delta_parallel_bb_buy  = input_parallel_enabled and is_parallel_delta_active and par_bb_buy
delta_parallel_bb_sell = input_parallel_enabled and is_parallel_delta_active and par_bb_sell

// --- Delta gradient color ---
// 5-step gradient from delta_ratio. Computed per mode so each baseline can be
// styled independently. The function returns one of the five colors passed in.
delta_gradient(ratio, c_heavy_buyers, c_light_buyers, c_balanced, c_light_sellers, c_heavy_sellers) =>
    if ratio >= LIGHT_THRESHOLD
        c_heavy_buyers
    else if ratio >= GRAY_THRESHOLD
        c_light_buyers
    else if ratio > -GRAY_THRESHOLD
        c_balanced
    else if ratio > -LIGHT_THRESHOLD
        c_light_sellers
    else
        c_heavy_sellers

unified_delta_color  = delta_gradient(delta_ratio, input_unified_delta_heavy_buyers,  input_unified_delta_light_buyers,  input_unified_delta_balanced,  input_unified_delta_light_sellers,  input_unified_delta_heavy_sellers)
parallel_delta_color = delta_gradient(delta_ratio, input_parallel_delta_heavy_buyers, input_parallel_delta_light_buyers, input_parallel_delta_balanced, input_parallel_delta_light_sellers, input_parallel_delta_heavy_sellers)

// "Grey" = Delta flow is near-balanced (the dot's visual color is mid-grey).
// Used to keep balanced-flow dots out of the directional alerts and to drive
// the dedicated "Bang! Bang! Balanced" alert per mode.
is_grey_unified  = is_unified_delta_active  and math.abs(delta_ratio) < GRAY_THRESHOLD
is_grey_parallel = is_parallel_delta_active and math.abs(delta_ratio) < GRAY_THRESHOLD

// --- Shooting Blanks (Delta Engine only) ---
// Detect bars where the close lands on the wrong side of the bar's range
// relative to the sub-bar flow direction. Two pieces:
//   close_position ∈ [-1, +1]: -1 = closed at the low, +1 = closed at the high
//   is_divergence: meaningful sub-bar flow exists AND close went the other way
close_position = high > low ? 2 * (close - low) / (high - low) - 1 : 0.0
is_divergence  = math.abs(delta_ratio) >= GRAY_THRESHOLD and math.sign(close_position) != math.sign(delta_ratio)

unified_delta_main_fires  = delta_unified_b_buy  or delta_unified_b_sell  or delta_unified_bb_buy  or delta_unified_bb_sell
parallel_delta_main_fires = delta_parallel_b_buy or delta_parallel_b_sell or delta_parallel_bb_buy or delta_parallel_bb_sell

// SB only fires when a Delta main dot already fired in that mode AND the
// bar diverged. Per-mode flags drive the per-mode alerts.
shooting_blanks_unified_active  = is_unified_delta_active  and input_enable_shooting_blanks and unified_delta_main_fires  and is_divergence
shooting_blanks_parallel_active = is_parallel_delta_active and input_enable_shooting_blanks and parallel_delta_main_fires and is_divergence

// Buyers Failed = aggressive buy flow (delta_ratio > 0) but the bar closed in
// its lower half (close_position < 0). Sellers Failed is the mirror image.
shooting_blanks_unified_buyers_failed   = shooting_blanks_unified_active  and close_position < 0 and delta_ratio > 0
shooting_blanks_unified_sellers_failed  = shooting_blanks_unified_active  and close_position > 0 and delta_ratio < 0
shooting_blanks_parallel_buyers_failed  = shooting_blanks_parallel_active and close_position < 0 and delta_ratio > 0
shooting_blanks_parallel_sellers_failed = shooting_blanks_parallel_active and close_position > 0 and delta_ratio < 0

// One shared yellow dot per qualifying bar, regardless of how many baseline
// modes fired. The visual reads as a per-bar event; per-mode granularity is
// preserved in the alerts.
shooting_blanks_buyers_failed_any  = shooting_blanks_unified_buyers_failed  or shooting_blanks_parallel_buyers_failed
shooting_blanks_sellers_failed_any = shooting_blanks_unified_sellers_failed or shooting_blanks_parallel_sellers_failed

// === 10. PLOTTING ===
// 18 plotshape calls in this order:
//   1. 8 Unified triangles (above/below the bar)
//   2. 8 Parallel circles  (at hl2 inside the bar)
//   3. 2 Shooting Blanks   (yellow overlay)
// Unified first so the Style tab row order matches the Inputs tab group order.
// Shooting Blanks last so its yellow dot renders on top of any Parallel circle
// sharing the same sub-bar hl2.

// --- Unified triangles ---
// Color and opacity come straight from the Unified color inputs (defaults
// ship at 80% opacity so the smaller triangles read clearly).
plotshape(intensity_unified_b_buy,   title = "Unified Intensity Bang! Buy",        style = shape.triangleup,   location = location.belowbar, color = input_unified_intensity_buy,  size = size.tiny)
plotshape(intensity_unified_bb_buy,  title = "Unified Intensity Bang! Bang! Buy",  style = shape.triangleup,   location = location.belowbar, color = input_unified_intensity_buy,  size = size.small)
plotshape(intensity_unified_b_sell,  title = "Unified Intensity Bang! Sell",       style = shape.triangledown, location = location.abovebar, color = input_unified_intensity_sell, size = size.tiny)
plotshape(intensity_unified_bb_sell, title = "Unified Intensity Bang! Bang! Sell", style = shape.triangledown, location = location.abovebar, color = input_unified_intensity_sell, size = size.small)

plotshape(delta_unified_b_buy,       title = "Unified Delta Bang! Buy",        style = shape.triangleup,   location = location.belowbar, color = unified_delta_color, size = size.tiny)
plotshape(delta_unified_bb_buy,      title = "Unified Delta Bang! Bang! Buy",  style = shape.triangleup,   location = location.belowbar, color = unified_delta_color, size = size.small)
plotshape(delta_unified_b_sell,      title = "Unified Delta Bang! Sell",       style = shape.triangledown, location = location.abovebar, color = unified_delta_color, size = size.tiny)
plotshape(delta_unified_bb_sell,     title = "Unified Delta Bang! Bang! Sell", style = shape.triangledown, location = location.abovebar, color = unified_delta_color, size = size.small)

// --- Parallel circles ---
// Placed at the bar's hl2 (Intensity) or the highest-volume sub-bar's hl2 (Delta).
plotshape(intensity_parallel_b_buy   ? intensity_placement : na, title = "Parallel Intensity Bang! Buy",        style = shape.circle, location = location.absolute, color = input_parallel_intensity_buy,  size = size.normal)
plotshape(intensity_parallel_bb_buy  ? intensity_placement : na, title = "Parallel Intensity Bang! Bang! Buy",  style = shape.circle, location = location.absolute, color = input_parallel_intensity_buy,  size = size.large)
plotshape(intensity_parallel_b_sell  ? intensity_placement : na, title = "Parallel Intensity Bang! Sell",       style = shape.circle, location = location.absolute, color = input_parallel_intensity_sell, size = size.normal)
plotshape(intensity_parallel_bb_sell ? intensity_placement : na, title = "Parallel Intensity Bang! Bang! Sell", style = shape.circle, location = location.absolute, color = input_parallel_intensity_sell, size = size.large)

plotshape(delta_parallel_b_buy   ? delta_placement : na, title = "Parallel Delta Bang! Buy",        style = shape.circle, location = location.absolute, color = parallel_delta_color, size = size.normal)
plotshape(delta_parallel_bb_buy  ? delta_placement : na, title = "Parallel Delta Bang! Bang! Buy",  style = shape.circle, location = location.absolute, color = parallel_delta_color, size = size.large)
plotshape(delta_parallel_b_sell  ? delta_placement : na, title = "Parallel Delta Bang! Sell",       style = shape.circle, location = location.absolute, color = parallel_delta_color, size = size.normal)
plotshape(delta_parallel_bb_sell ? delta_placement : na, title = "Parallel Delta Bang! Bang! Sell", style = shape.circle, location = location.absolute, color = parallel_delta_color, size = size.large)

// --- Shooting Blanks overlay ---
// Single shared yellow dot at the busiest sub-bar's hl2 when divergence fires.
plotshape(shooting_blanks_buyers_failed_any  ? delta_placement : na, title = "Shooting Blanks (Buyers Failed)",  style = shape.circle, location = location.absolute, color = input_shooting_blanks_color, size = size.tiny)
plotshape(shooting_blanks_sellers_failed_any ? delta_placement : na, title = "Shooting Blanks (Sellers Failed)", style = shape.circle, location = location.absolute, color = input_shooting_blanks_color, size = size.tiny)

// === 11. ALERTS ===
// 9 alert conditions per baseline mode × 2 modes = 18 selectable alerts.
// Each is suffixed (Unified) / (Parallel) so per-mode firings stay distinct.

// --- Per-mode "any fired" rollups ---
unified_any_bang  = intensity_unified_b_buy  or intensity_unified_b_sell  or delta_unified_b_buy  or delta_unified_b_sell
unified_any_bb    = intensity_unified_bb_buy or intensity_unified_bb_sell or delta_unified_bb_buy or delta_unified_bb_sell
parallel_any_bang = intensity_parallel_b_buy  or intensity_parallel_b_sell  or delta_parallel_b_buy  or delta_parallel_b_sell
parallel_any_bb   = intensity_parallel_bb_buy or intensity_parallel_bb_sell or delta_parallel_bb_buy or delta_parallel_bb_sell

// --- Directional rollups ---
// Grey Delta dots indicate roughly balanced sub-bar flow with no clear
// direction, so they're excluded here and routed to the dedicated
// "Bang! Bang! Balanced" alert per mode.
unified_buy_dir   = (intensity_unified_b_buy   or intensity_unified_bb_buy)   or ((delta_unified_b_buy   or delta_unified_bb_buy)   and not is_grey_unified)
unified_sell_dir  = (intensity_unified_b_sell  or intensity_unified_bb_sell)  or ((delta_unified_b_sell  or delta_unified_bb_sell)  and not is_grey_unified)
parallel_buy_dir  = (intensity_parallel_b_buy  or intensity_parallel_bb_buy)  or ((delta_parallel_b_buy  or delta_parallel_bb_buy)  and not is_grey_parallel)
parallel_sell_dir = (intensity_parallel_b_sell or intensity_parallel_bb_sell) or ((delta_parallel_b_sell or delta_parallel_bb_sell) and not is_grey_parallel)

// --- Unified-mode alert conditions ---
alertcondition(unified_any_bang,                       title = "Bang! (Unified)",                              message = "Bang! (Unified) on {{ticker}} at {{close}}")
alertcondition(unified_any_bb,                         title = "Bang! Bang! (Unified)",                         message = "Bang! Bang! (Unified) on {{ticker}} at {{close}}")
alertcondition(unified_any_bang and unified_buy_dir,   title = "Bang! Buy (Unified)",                          message = "Bang! Buy (Unified) on {{ticker}} at {{close}}")
alertcondition(unified_any_bang and unified_sell_dir,  title = "Bang! Sell (Unified)",                         message = "Bang! Sell (Unified) on {{ticker}} at {{close}}")
alertcondition(unified_any_bb   and unified_buy_dir,   title = "Bang! Bang! Buy (Unified)",                     message = "Bang! Bang! Buy (Unified) on {{ticker}} at {{close}}")
alertcondition(unified_any_bb   and unified_sell_dir,  title = "Bang! Bang! Sell (Unified)",                    message = "Bang! Bang! Sell (Unified) on {{ticker}} at {{close}}")
alertcondition(unified_any_bb   and is_grey_unified,   title = "Bang! Bang! Balanced (Unified)",                message = "Bang! Bang! Balanced (Unified) on {{ticker}} at {{close}}")
alertcondition(shooting_blanks_unified_buyers_failed,  title = "Shooting Blanks (Buyers Failed) (Unified)",   message = "Shooting Blanks (Buyers Failed) (Unified) on {{ticker}} at {{close}}")
alertcondition(shooting_blanks_unified_sellers_failed, title = "Shooting Blanks (Sellers Failed) (Unified)",  message = "Shooting Blanks (Sellers Failed) (Unified) on {{ticker}} at {{close}}")

// --- Parallel-mode alert conditions ---
alertcondition(parallel_any_bang,                       title = "Bang! (Parallel)",                              message = "Bang! (Parallel) on {{ticker}} at {{close}}")
alertcondition(parallel_any_bb,                         title = "Bang! Bang! (Parallel)",                         message = "Bang! Bang! (Parallel) on {{ticker}} at {{close}}")
alertcondition(parallel_any_bang and parallel_buy_dir,  title = "Bang! Buy (Parallel)",                          message = "Bang! Buy (Parallel) on {{ticker}} at {{close}}")
alertcondition(parallel_any_bang and parallel_sell_dir, title = "Bang! Sell (Parallel)",                         message = "Bang! Sell (Parallel) on {{ticker}} at {{close}}")
alertcondition(parallel_any_bb   and parallel_buy_dir,  title = "Bang! Bang! Buy (Parallel)",                     message = "Bang! Bang! Buy (Parallel) on {{ticker}} at {{close}}")
alertcondition(parallel_any_bb   and parallel_sell_dir, title = "Bang! Bang! Sell (Parallel)",                    message = "Bang! Bang! Sell (Parallel) on {{ticker}} at {{close}}")
alertcondition(parallel_any_bb   and is_grey_parallel,  title = "Bang! Bang! Balanced (Parallel)",                message = "Bang! Bang! Balanced (Parallel) on {{ticker}} at {{close}}")
alertcondition(shooting_blanks_parallel_buyers_failed,  title = "Shooting Blanks (Buyers Failed) (Parallel)",   message = "Shooting Blanks (Buyers Failed) (Parallel) on {{ticker}} at {{close}}")
alertcondition(shooting_blanks_parallel_sellers_failed, title = "Shooting Blanks (Sellers Failed) (Parallel)",  message = "Shooting Blanks (Sellers Failed) (Parallel) on {{ticker}} at {{close}}")
````
