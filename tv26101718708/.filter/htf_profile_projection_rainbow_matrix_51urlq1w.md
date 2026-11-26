# HTF Profile Projection | Rainbow Matrix

- url: https://www.tradingview.com/script/51urLQ1W-HTF-Profile-Projection-Rainbow-Matrix/
- type: indicator
- pine_id: PUB;590488e1fad546d4aea3897abfe8980d
- version: 1.0

## Description

GENERAL OVERVIEW
HTF Profile Projection is a live higher-timeframe X-ray. It takes the current, still-forming candle of a higher timeframe (for example the 4H or Daily candle) and projects it to the right of live price, then fills it with a horizontal profile that shows what is happening INSIDE that candle: where volume is concentrating, where buyers or sellers are dominating each price zone, and where price moved through empty space.

The goal is to let a trader read the internal structure of the higher-timeframe candle without leaving the current chart. Instead of seeing the 4H candle as a single block, you see its anatomy — the price levels that hold the most activity, the zones controlled by buyers versus sellers, and the thin gaps the candle ran through quickly. Every bar in the profile is built from real chart-bar data accumulated since the higher-timeframe candle opened, not drawn manually.

WHAT IS THE THEORY BEHIND THIS INDICATOR?
A higher-timeframe candle is a summary. A single 4H or Daily candle compresses hours of two-sided auction into one open, high, low, and close — and in doing so it hides where the volume actually traded and which side was in control at each price. Two candles with an identical body and identical range can have completely different internal structures: one built on heavy buying absorbed near the lows, the other on distribution near the highs. The standard candle cannot show that difference.

Most tools that try to surface this are built around the wrong constraint. Single-timeframe volume profiles describe the visible range, not the live higher-timeframe candle. Intrabar dissection tools that read true sub-candle data depend on functions that require additional data subscriptions and will not load on standard plans.

HTF Profile Projection takes a different route: it accumulates the chart's own bars since the higher-timeframe candle opened, and distributes each bar's activity across the price range it actually traversed. This reconstructs the internal volume and directional balance of the forming higher-timeframe candle using only standard data feeds — and projects it forward as a single, readable object.

The practical value: when price returns to a higher-timeframe candle later, the levels that mattered inside it — the high-volume node, the buyer- or seller-dominated zones, the empty imbalance gaps — are common revisit and reaction areas. Seeing them while the candle is still forming gives structural context that the candle body alone cannot.

HTF PROFILE PROJECTION FEATURES
The indicator includes these main components: a projected higher-timeframe candle, a range-spread movement profile, automatic resolution, a buy/sell dominance read, imbalance zones, a Point of Control marker, and a live info panel. Multilingual interface and full visual customization.

PROJECTED HTF CANDLE
🔹 What It Does
Reads the live, still-forming higher-timeframe candle and draws it (body + wicks) to the right of live price, color-coded by its direction. The horizontal profile attaches inside its price range.

🔹 Method
The higher-timeframe OHLCV is read via request.security() with lookahead=barmerge.lookahead_off, so no future information is used. The candle and its profile update in real time as the higher-timeframe bar forms — the intended live behavior — and reset cleanly when a new higher-timeframe period opens. If the chart timeframe is at or above the selected higher timeframe, the profile is hidden and a guard note is shown, because one chart bar covering the whole period cannot produce a meaningful internal read.

RANGE-SPREAD MOVEMENT PROFILE
🔹 What It Does
Splits the higher-timeframe candle's range into horizontal price buckets and fills each with the activity that occurred there.

🔹 Method
Since the higher-timeframe candle opened, each chart bar's volume and signed direction are accumulated, then distributed across every bucket the bar's low–high range spans — not dumped at a single midpoint. This range-spread approach makes both the per-zone volume and the per-zone buy/sell balance reflect where price actually traded inside the candle, rather than collapsing onto one level.

AUTOMATIC RESOLUTION
🔹 What It Does
The number of price buckets is chosen automatically from volatility. The higher-timeframe range is divided by the average chart-candle size (ATR), so each fraction of the profile corresponds to roughly one typical move of the chart timeframe.

🔹 Why It Matters
Calmer markets produce a finer profile; volatile markets produce a coarser one. The resolution matches the instrument and timeframe automatically, bounded between 4 and 50 buckets to keep the chart readable.

BUY/SELL DOMINANCE (DELTA MODE)
🔹 What It Does
In Delta mode (the default), each zone is colored by which side dominated: green for net buyers, red for net sellers, and gray for balanced zones where heavy two-way trade produced no clear winner. Bar length shows the magnitude of the imbalance.

🔹 Method
Each chart bar is classified by the sign of close versus open and contributes its volume as signed activity (+ for an up bar, − for a down bar). The net per zone is a direction-based proxy for buy/sell pressure, computed locally on standard data feeds — it is not exchange order-flow data, which Pine cannot access without additional subscriptions.

🔹 Volume Mode
Switching Source Metric to Volume colors the profile by a cold-to-hot intensity gradient instead, showing how much traded at each price regardless of direction.

IMBALANCE ZONES
🔹 What It Does
Price zones with little or no activity render distinctly. A contiguous run of empty buckets marks an imbalance — a price range the higher-timeframe candle moved through quickly with little participation.

🔹 Why It Matters
These gaps are not drawn as separate boxes; they emerge from the ABSENCE of activity in the profile. They are common revisit targets, since price often returns to fill ranges it previously skipped.

POINT OF CONTROL MARKER
🔹 What It Does
A horizontal marker tags the dominant bucket — the price level with the most activity (Volume mode) or the strongest net dominance (Delta mode). A label reports that level's share of the period's total.

LIVE INFO PANEL
🔹 What It Shows
A compact corner panel reports the higher timeframe in use, the percentage of the period elapsed, the Point of Control price, the number of imbalance zones, and the total higher-timeframe volume. When the chart-timeframe guard is active, the panel collapses to a single notice so the user always gets feedback.

🔹 Customization
The panel can be placed in any of the four chart corners and rendered in several font sizes. The display language is controlled by the System Language input.

[snapshot]

HOW TO USE
This indicator is not a signal generator. It is a structural X-ray: it shows the internal anatomy of the forming higher-timeframe candle.

🔹 Setup
Set the Higher Timeframe input above your current chart timeframe (for example chart 15m, HTF 4H). The forward candle appears to the right of live price. If the chart timeframe is at or above the HTF, the profile hides and the guard note appears.

🔹 Reading Delta Mode (default)
Green zones mark prices where buyers dominated, red where sellers dominated, gray where the auction was balanced. The Point of Control marks the most decisive level inside the candle.

🔹 Reading Volume Mode
The rainbow profile shows where the most volume traded. Long bars are high-activity nodes; gaps are low-volume imbalance zones.

🔹 Tactical Reading
◇ A high-activity node is a price the higher timeframe has accepted — a common reaction level on revisit.
◇ A buyer- or seller-dominated zone shows which side controlled that price during the period.
◇ An imbalance gap is a range price ran through quickly — a frequent magnet for later revisits.

INPUTS EXPLAINED
🔹 System Language
Display language for the panel and labels. Options: English (default), Português, Español, Русский, 中文 (Chinese).

🔹 Higher Timeframe
The higher timeframe to project. Must be above the chart timeframe.

🔹 Show Forward HTF Candle
Toggle for the projected candle body and wicks.

🔹 Auto-Resolution ATR Length
Lookback for the average chart-candle size used to pick the bucket count.

🔹 Source Metric
Volume (intensity gradient) or Delta (buy/sell dominance, default).

🔹 Projection Offset / Profile Width
Position and maximum horizontal length of the profile to the right of price.

🔹 Spike Threshold / Imbalance Threshold
Controls for what counts as a high-activity node and what counts as an empty/imbalance zone.

🔹 Palette Mode
Intensity (cold-to-hot) or Bull-Bear (dominance coloring, default).

🔹 Profile Transparency / Show POC Marker
Visual styling for the profile and the Point of Control line.

🔹 Info Panel / Position / Font Size
Toggle, corner, and size for the live panel.

IMPORTANT NOTES
HTF Profile Projection works on any chart timeframe below the selected higher timeframe. It is built for liquid instruments with reliable volume data: crypto perpetual contracts, large-cap equities, futures, major forex pairs. On low-volume instruments the profile becomes less reliable.

This is a real-time tool. The forming higher-timeframe candle and its profile update intra-period by design; the profile resets when a new higher-timeframe period opens. It uses only request.security() and chart-bar accumulation, so it runs on standard data feeds without footprint() or request.security_lower_tf().

Pine Script v6. Open-source under Mozilla Public License 2.0.

UNIQUENESS
HTF Profile Projection is unique in how it unifies three reads into one object. Most higher-timeframe context tools stack separate features: a candle outline, fair-value-gap rectangles, and volume-spike markers. This indicator merges them — the forward higher-timeframe candle and its volume-by-price profile are a single object. High-activity zones appear as the profile's longest bars; imbalance zones are not drawn at all, they emerge from the absence of activity in the profile. The buy/sell dominance read is reconstructed from chart-bar direction and distributed across each bar's true price range, so it reflects where the auction was actually contested — and it does this on standard data feeds, without the order-flow subscriptions that comparable intrabar tools require. The combination of a live forward-projected candle, automatic volatility-matched resolution, range-spread accumulation, and dominance-versus-balance coloring produces a structural read that behaves differently from single-timeframe volume profiles and from static fair-value-gap tools.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © rainbowmatrix
//
// ════════════════════════════════════════════════════════════════════════════════
// HTF PROFILE PROJECTION — LIVE HIGHER-TIMEFRAME X-RAY
//
// Projects the current, still-forming higher-timeframe candle to the right of
// live price, and fills it with a horizontal rainbow profile that shows where
// volume is concentrating (spikes) and where price moved through empty space
// (imbalances) — without the trader switching charts.
//
// METHOD:
//   1. Reads the live, still-forming HTF candle (e.g. 4H) via request.security()
//      with lookahead_off — no future peeking. The values update in real time
//      as the HTF bar forms; that is the intended live behavior, not repaint.
//   2. Since the HTF candle opened, each chart bar's [low, high, volume] and a
//      signed up/down delta are accumulated into running arrays that reset on
//      every HTF rollover.
//   3. RESOLUTION IS AUTOMATIC: the HTF range is divided by the average child-
//      candle size (ATR) to pick the bucket count, so each price fraction ≈ one
//      typical move of the chart timeframe. Calmer markets get a finer profile,
//      volatile ones get a coarser one (bounded 4–50 buckets).
//   4. RANGE-SPREAD: each chart bar distributes its volume (and signed delta)
//      across every bucket its low–high range spans, not just its midpoint — so
//      both the per-zone volume and the per-zone buy/sell balance reflect where
//      price actually traded inside the candle.
//   5. The forward candle is drawn to the right of live price (body + wicks),
//      with the horizontal profile attached: one box per bucket.
//        - Source = Volume  → length and a cold→hot gradient show how much
//          traded at each price.
//        - Source = Delta   → length shows magnitude and color shows dominance:
//          green = net buyers, red = net sellers, gray = balanced (heavy two-way
//          trade with no clear winner). Delta is a direction-based proxy for
//          buy/sell pressure (sign of close vs. open), computed locally.
//   6. The POC marker tags the dominant bucket; a label reports its share of the
//      period's volume (or its dominance share in Delta mode).
//
// ORIGINALITY:
//   Most "HTF context" tools stack three separate features: an HTF candle
//   outline, FVG rectangles, and volume-spike markers. HTF Profile Projection
//   unifies them into one object — the forward HTF candle and its volume-by-price
//   profile. High-activity zones emerge as the profile's longest bars; imbalance
//   zones emerge from the ABSENCE of volume (no separate FVG box is drawn). The
//   buy/sell dominance read works on standard data feeds, without footprint() or
//   request.security_lower_tf().
//
// HOW TO USE:
//   - Set the HTF input above the current chart timeframe (e.g. chart 15m, HTF
//     4H). The forward candle appears to the right of live price. If the chart TF
//     is at or above the HTF, the profile hides and a guard note is shown.
//   - In Delta mode (default): green zones = buyers dominated that price, red =
//     sellers dominated, gray = balanced. The POC line marks the most decisive
//     level.
//   - In Volume mode: the rainbow profile shows where the most volume traded;
//     long bars are high-activity nodes, gaps are low-volume imbalance zones.
//   - This is a live x-ray, not a historical signal. It updates as the HTF
//     candle forms and resets cleanly on rollover.
//
// INPUTS EXPLAINED:
//   - System Language: HUD label language (EN/PT/ES/RU/ZH).
//   - Higher Timeframe: the HTF to project (Auto, or explicit TF).
//   - Movement Profile: bucket count, source metric (Volume/Delta),
//     projection offset, profile width.
//   - Volume Spikes: spike threshold multiplier, optional spike label.
//   - Imbalance: imbalance threshold fraction, visibility toggle.
//   - Rainbow Style: palette mode (Intensity / Bull-Bear), transparency,
//     POC marker.
//   - Info Panel: HUD visibility and corner anchor.
// ════════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("HTF Profile Projection | Rainbow Matrix", overlay=true,
     max_bars_back=500, max_boxes_count=500, max_lines_count=100, max_labels_count=100)

// ========================================================================================================
// SYSTEM LANGUAGE
// ========================================================================================================
g_lang = "GLOBAL SETTINGS"
language = input.string("English", "System Language",
     options=["English", "Português", "Español", "Русский", "中文 (Chinese)"],
     group=g_lang,
     tooltip="Select the display language for all on-screen labels and the info panel.")
string _l = language == "Português" ? "PT" : language == "Español" ? "ES" : language == "Русский" ? "RU" : language == "中文 (Chinese)" ? "ZH" : "EN"

// ── Multilingual strings (per §3.11) ──
var string s_htf       = _l=="PT"?"TF SUPERIOR" :_l=="ES"?"TF SUPERIOR" :_l=="RU"?"СТАРШИЙ ТФ" :_l=="ZH"?"高时段" :"HTF"
var string s_elapsed   = _l=="PT"?"DECORRIDO"   :_l=="ES"?"TRANSCURRIDO":_l=="RU"?"ПРОШЛО"     :_l=="ZH"?"已用"   :"ELAPSED"
var string s_poc       = _l=="PT"?"POC"         :_l=="ES"?"POC"          :_l=="RU"?"POC"        :_l=="ZH"?"POC"   :"POC"
var string s_imbz      = _l=="PT"?"ZONAS DESEQ.":_l=="ES"?"ZONAS DESEQ." :_l=="RU"?"ЗОНЫ ДИСБ." :_l=="ZH"?"失衡区"  :"IMB. ZONES"
var string s_total_vol = _l=="PT"?"VOL. TOTAL"  :_l=="ES"?"VOL. TOTAL"   :_l=="RU"?"ОБЩИЙ ОБЪЁМ":_l=="ZH"?"总成交量" :"TOTAL VOL"
var string s_guard_msg = _l=="PT"?"⚠️ TF do gráfico ≥ HTF — defina o gráfico abaixo do HTF" :_l=="ES"?"⚠️ TF del gráfico ≥ HTF — usa un gráfico por debajo del HTF" :_l=="RU"?"⚠️ ТФ графика ≥ HTF — установите график ниже HTF" :_l=="ZH"?"⚠️ 图表周期 ≥ HTF — 请将图表周期设置在 HTF 以下" :"⚠️ chart TF ≥ HTF — set chart below HTF"
var string s_spike_pct = _l=="PT"?" do volume" :_l=="ES"?" del volumen":_l=="RU"?" объёма"   :_l=="ZH"?"成交量%"  :" of volume"
var string s_dominance = _l=="PT"?" de dominância" :_l=="ES"?" de dominancia":_l=="RU"?" доминирования":_l=="ZH"?"主导"  :" dominance"

// ========================================================================================================
// INPUTS
// ========================================================================================================
g_htf = "HIGHER TIMEFRAME"
htf = input.timeframe("240", "Higher Timeframe",
     group=g_htf,
     tooltip="The higher timeframe to project. Default 240 (4H). For a 1m–15m chart try 60/240; for a 1H chart try D; for a 4H+ chart try W. The chart timeframe must be lower than this HTF — otherwise the profile is hidden and a guard note is shown.")
show_forward_candle = input.bool(true, "Show Forward HTF Candle",
     group=g_htf,
     tooltip="Render the projected HTF candle (body + wicks) to the right of live price. The profile attaches inside it. Turn off to see the profile alone.")

g_profile = "MOVEMENT PROFILE"
// v1.1 — buckets are auto-derived from child-candle size (ATR). The manual
// count was removed: resolution now auto-matches the timeframe's typical
// candle, so each fraction ≈ one "move" of the child TF.
atr_len = input.int(14, "Auto-Resolution ATR Length",
     minval=2, maxval=100, step=1,
     group=g_profile,
     tooltip="Bucket count auto-adjusts to volatility: the HTF range is divided by the average child-candle size (ATR of this period). Calmer market = finer profile; volatile = coarser. Capped between 4 and 50 buckets.")
// Effective bucket count — recomputed each frame in the rebin engine (§4.2 v1.1).
// Seeded here so every downstream reference (render, HUD) has a valid value.
var int n_buckets = 24
profile_metric = input.string("Delta", "Source Metric",
     options=["Volume", "Delta"],
     group=g_profile,
     tooltip="Volume = total traded volume per price zone. Delta = NET buy/sell balance per zone (each child bar counts as +volume when it closes up, −volume when it closes down). This is a direction-based proxy for buy/sell pressure, not real order-flow data. Pair with Palette Mode = Bull-Bear to color zones by dominance.")
proj_offset = input.int(12, "Projection Offset (bars)",
     minval=2, maxval=60, step=1,
     group=g_profile,
     tooltip="How many bars to the right of live price the forward candle is drawn. Default 12 keeps it visible without overlapping live action.")
profile_width = input.int(20, "Profile Width (bars)",
     minval=4, maxval=60, step=1,
     group=g_profile,
     tooltip="Maximum horizontal length of the longest bucket (in bar widths). The other buckets scale proportionally.")

g_spike = "VOLUME SPIKES"
spike_mult = input.float(2.0, "Spike Threshold (× mean)",
     minval=1.2, maxval=10.0, step=0.1,
     group=g_spike,
     tooltip="A bucket whose activity exceeds this multiple of the mean bucket activity is rendered as a hot spike node. Lower = more spikes flagged; higher = only extreme nodes.")
show_spike_label = input.bool(true, "Show Spike Volume Label",
     group=g_spike,
     tooltip="Label the hottest bucket with its share of the HTF candle's total volume.")

g_imbalance = "IMBALANCE"
imbalance_frac = input.float(0.15, "Imbalance Threshold (× mean)",
     minval=0.0, maxval=0.5, step=0.01,
     group=g_imbalance,
     tooltip="A bucket whose activity is at or below this fraction of the mean is treated as an empty fraction (imbalance). Contiguous empty buckets form an imbalance zone — a price range the HTF candle moved through quickly with little volume.")
show_imbalance = input.bool(true, "Show Imbalance Zones",
     group=g_imbalance,
     tooltip="Render empty/cold buckets distinctly from active buckets. Turn off for a flat-gradient profile.")

g_style = "RAINBOW STYLE"
palette_mode = input.string("Bull-Bear", "Palette Mode",
     options=["Intensity", "Bull-Bear"],
     group=g_style,
     tooltip="Intensity = single gradient keyed to how much traded in each zone (cold → hot). Bull-Bear = zones colored by dominance: green = net buyers, red = net sellers, gray = balanced (heavy two-way trade, no winner). Bull-Bear works best with Source Metric = Delta.")
base_transparency = input.int(20, "Profile Transparency",
     minval=0, maxval=90, step=5,
     group=g_style,
     tooltip="Base transparency of profile bars. 0 = solid, 90 = nearly invisible. The hottest buckets render at this transparency; cold buckets fade further.")
show_poc = input.bool(true, "Show POC Marker",
     group=g_style,
     tooltip="Mark the highest-activity bucket (Point of Control) with a horizontal accent line at its price level.")

g_hud = "INFO PANEL"
show_panel = input.bool(true, "Show Info Panel",
     group=g_hud,
     tooltip="Floating panel summarizing the live HTF profile: timeframe in use, % of HTF period elapsed, POC price, imbalance-zone count, total HTF volume.")
panel_pos = input.string("Top Right", "Panel Position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"],
     group=g_hud,
     tooltip="Anchor corner for the info panel — renders fixed regardless of zoom or scroll.")
i_text_size = input.string("Small", "Font Size",
     options=["Tiny", "Small", "Normal", "Large"],
     group=g_hud,
     tooltip="Font size for the info panel and any on-chart labels.")
font_size = i_text_size == "Tiny" ? size.tiny : i_text_size == "Small" ? size.small : i_text_size == "Normal" ? size.normal : size.large

// ========================================================================================================
// HTF PIPELINE — OHLCV + ROLLOVER DETECTION + CHART-TF GUARD
// ========================================================================================================
// §10-5 guard: the chart TF must be strictly lower than HTF. If equal or higher,
// the profile is hidden (single-bucket-by-hl2 cannot produce a meaningful x-ray
// when one chart bar covers the whole HTF period) and the info panel surfaces
// s_guard_msg. Comparison via timeframe.in_seconds() handles all TF formats
// uniformly (seconds, minutes, "D", "W", "M", etc.).
int chart_tf_sec = timeframe.in_seconds(timeframe.period)
int htf_sec      = timeframe.in_seconds(htf)
bool tf_guard    = chart_tf_sec >= htf_sec  // true → hide profile, show guard note

// Live forming HTF candle (OHLCV + open time). lookahead_off → no future peeking;
// the values update in real time as the HTF bar forms, which is the intended
// live x-ray behavior, not lookahead bias.
[htf_open, htf_high, htf_low, htf_close, htf_vol, htf_time] = request.security(
     syminfo.tickerid, htf,
     [open, high, low, close, volume, time],
     lookahead = barmerge.lookahead_off)

// HTF rollover: fires on the first chart bar of a new HTF period. Drives the
// accumulator reset (Phase 3) and the bucket-grid rebuild.
bool htf_rollover = timeframe.change(htf)

// ========================================================================================================
// ACCUMULATOR + RE-BIN ENGINE  (§4.2 — chart-bar accumulation, MVP single-bucket-by-hl2)
// ========================================================================================================
// Per-chart-bar arrays (hl2, volume, signed delta) since the HTF candle opened.
// Length is bounded by HTF ÷ chartTF (e.g. 4H/15m → 16, 1D/15m → 96) and resets
// on every HTF rollover. Each chart bar appends one entry; the bucket grid is
// re-aggregated at the realtime edge by Phase 5 for rendering (§7 lifecycle).
var array<float> acc_high  = array.new<float>()
var array<float> acc_low   = array.new<float>()
var array<float> acc_vol   = array.new<float>()
var array<float> acc_delta = array.new<float>()

// Reset on HTF rollover. The first chart bar of the new HTF period will repopulate.
if htf_rollover
    array.clear(acc_high)
    array.clear(acc_low)
    array.clear(acc_vol)
    array.clear(acc_delta)

// v1.1 — signed up/down volume per child bar: the bar is treated as net
// buying when it closes above its open (+volume), net selling when it closes
// below (−volume), flat otherwise. This is a direction-based proxy for
// buy/sell pressure (not real order-flow data — Pine cannot read that
// directly). The bucket stores the NET balance per zone.
float bar_delta = close > open ? volume : close < open ? -volume : 0.0

// Accumulate every chart bar when the guard is clear. Under guard we skip
// accumulation rather than collect data that would never be rendered.
if not tf_guard and not na(htf_time)
    array.push(acc_high,  high)
    array.push(acc_low,   low)
    array.push(acc_vol,   volume)
    array.push(acc_delta, bar_delta)

// ── Bucket grid (re-binned on demand by Phase 5 at the realtime edge) ──────
// Walks the bounded accumulator once and places each entry's chosen metric
// (volume or signed delta) into the bucket containing its hl2. Bucket
// boundaries come from the running HTF high/low — they shift as the HTF
// candle's range expands, which is why the full array is re-aggregated each
// frame (incremental patching is incorrect when grid boundaries move).
// Child-candle size proxy (stable, per operator decision: ATR of the chart TF).
// Used to auto-derive bucket resolution so each fraction ≈ one child "move".
float child_atr = ta.atr(atr_len)

// Allocated at the 50 cap; only the first n_buckets slots are used each frame.
var array<float> buckets   = array.new<float>(50, 0.0)

// v1.1 rebin engine:
//   (1) AUTO-RESOLUTION — buckets = clamp(round(HTF_range / child_ATR), 4, 50),
//       so each bucket ≈ one average child-candle move. Calmer TF → finer.
//   (2) RANGE-SPREAD — each child bar distributes its metric across every bucket
//       its [low, high] spans (split evenly), not dumped at hl2. This makes the
//       per-zone volume AND the per-zone net delta faithful to where the child
//       actually traded — essential for the buy/sell dominance read.
// Returns the effective bucket count; mutates buckets[] (passed by reference,
// which Pine allows — only scalar globals can't be reassigned in a function).
f_rebin() =>
    float lo   = htf_low
    float hi   = htf_high
    float span = hi - lo

    // (1) auto bucket count from child-candle size
    int nb = not na(child_atr) and child_atr > 0 and span > 0
         ? math.max(4, math.min(50, math.round(span / child_atr)))
         : 4

    // clear only the active range
    for i = 0 to nb - 1
        array.set(buckets, i, 0.0)

    // (2) range-spread accumulation
    if span > 0
        int n = array.size(acc_vol)
        for i = 0 to n - 1
            float m  = profile_metric == "Delta" ? array.get(acc_delta, i) : array.get(acc_vol, i)
            float bl = array.get(acc_low,  i)
            float bt = array.get(acc_high, i)
            int idx_lo = math.max(0, math.min(nb - 1, math.floor((bl - lo) / span * nb)))
            int idx_hi = math.max(0, math.min(nb - 1, math.floor((bt - lo) / span * nb)))
            int spanN  = idx_hi - idx_lo + 1
            float share = m / spanN
            for j = idx_lo to idx_hi
                array.set(buckets,  j, array.get(buckets,  j) + share)
    nb

// ========================================================================================================
// FORWARD HTF CANDLE — body + wicks under barstate.islast  (§7 delete+recreate)
// ========================================================================================================
// One body box (open→close) and two wick lines (high→body-top, low→body-bottom)
// drawn proj_offset bars to the right of the live bar. Refreshed every realtime
// tick by deleting and recreating — re-binning shifts price coords anyway, so
// handle preservation buys nothing (per §7). Colors follow MGI Walls precedent:
// TV-native green/red for direction signaling (canonical, no palette deviation).
var box  fwd_body    = na
var line fwd_wick_hi = na
var line fwd_wick_lo = na

color c_bull_candle = color.green   // §3.4 c_dn_1 — bull direction
color c_bear_candle = color.red     // §3.4 c_up_3 — bear direction

if barstate.islast and show_forward_candle and not tf_guard and not na(htf_time)
    box.delete(fwd_body)
    line.delete(fwd_wick_hi)
    line.delete(fwd_wick_lo)
    bool  bull   = htf_close >= htf_open
    color c_cand = bull ? c_bull_candle : c_bear_candle
    int   x_mid  = bar_index + proj_offset
    int   x_l    = x_mid - 1
    int   x_r    = x_mid + 1
    float body_t = math.max(htf_open, htf_close)
    float body_b = math.min(htf_open, htf_close)
    fwd_body    := box.new(left=x_l, top=body_t, right=x_r, bottom=body_b,
                           border_color=c_cand, bgcolor=color.new(c_cand, 70), border_width=1)
    fwd_wick_hi := line.new(x1=x_mid, y1=body_t, x2=x_mid, y2=htf_high,
                            color=c_cand, width=1)
    fwd_wick_lo := line.new(x1=x_mid, y1=body_b, x2=x_mid, y2=htf_low,
                            color=c_cand, width=1)

// ========================================================================================================
// PROFILE RENDER — horizontal canonical-palette boxes + POC marker  (§3 / §5)
// ========================================================================================================
// Walks the bucket grid at the realtime edge: one horizontal box per bucket,
// length ∝ activity, colored per §3.4 canonical palette.
//
// PRECEDENCE:
//   Bull-Bear mode → color is set by sign(v); spike/imbalance only affect
//                    transparency (spike = bright, imbalance = faded) and
//                    length (imbalance = 1). The directional signal stays
//                    readable at the most informative buckets.
//   Intensity mode → spike (§4.3, > spike_mult × mean) overrides to c_up_4
//                    (purple = Black Swan slot, "extreme concentration"),
//                    imbalance (§4.4, ≤ imbalance_frac × mean) overrides to
//                    c_dn_4 (aqua, heavily transparent); otherwise the bucket
//                    rides the 3-stop gradient aqua → yellow → red.
//
// POC LINE uses c_up_4 (purple) deliberately — when the dominant bucket is also
// a spike (the common case), the POC line visually fuses with the spike bucket
// into a single "this is THE level" signal.
var array<box> profile_boxes = array.new<box>()
var line       poc_line      = na

// §3.4 canonical palette (NEVER change without explicit operator override).
color c_up_4   = color.purple   // Black Swan High / spike override / POC line
color c_up_3   = color.red      // Z-Exhaustion High / bear bucket / gradient hot
color c_up_2   = color.orange   // Z-Alert High (reserved for future use)
color c_up_1   = color.yellow   // Z-Breathing High / gradient mid
color c_dn_1   = color.green    // Z-Breathing Low / bull bucket
color c_dn_2   = color.teal     // Z-Alert Low (reserved)
color c_dn_3   = color.blue     // Z-Exhaustion Low (reserved)
color c_dn_4   = color.aqua     // Black Swan Low / imbalance override / gradient cold
color c_neutral = color.gray    // reserved for HUD chrome
color c_black   = color.black   // §3.4 c_black — HUD background

// 3-stop intensity gradient parametrized on normalized activity v ∈ [0,1].
f_grad(float v) =>
    v < 0.5 ? color.from_gradient(v, 0.0, 0.5, c_dn_4, c_up_1) : color.from_gradient(v, 0.5, 1.0, c_up_1, c_up_3)

// State exposed to Phase 6 (spike % label, contiguous-imbalance zone count) and Phase 7 (HUD):
var int   last_poc_idx   = 0
var float last_thr_imb   = 0.0
var float last_thr_spike = 0.0
var float last_max_abs   = 0.0

if barstate.islast and not tf_guard and not na(htf_time)
    // 1) wipe previous frame's profile boxes + POC line
    if array.size(profile_boxes) > 0
        for i = 0 to array.size(profile_boxes) - 1
            box.delete(array.get(profile_boxes, i))
        array.clear(profile_boxes)
    line.delete(poc_line)

    // 2) refresh bucket grid from accumulator (returns the auto bucket count)
    n_buckets := f_rebin()

    // 3) statistics for normalization + thresholds
    float max_abs = 0.0
    float sum_abs = 0.0
    for i = 0 to n_buckets - 1
        float av = math.abs(array.get(buckets, i))
        max_abs := math.max(max_abs, av)
        sum_abs += av
// In Volume mode: spike = high-volume node, imbalance = near-empty fraction.
    // In Delta mode (v1.1): the same thresholds read as DOMINANCE vs BALANCE —
    //   spike  = |net delta| >> mean  → strong one-sided (buyer/seller) dominance
    //   imbal. = |net delta| <= frac  → balanced zone (heavy two-way trade, no winner)
    // The math is identical; only the interpretation (and tooltips/HUD) differ.
    float mean_abs  = sum_abs / n_buckets
    float thr_spike = mean_abs * spike_mult
    float thr_imb   = mean_abs * imbalance_frac

    if max_abs > 0 and htf_high > htf_low
        // 4) geometry + per-bucket render
        float bucket_h = (htf_high - htf_low) / n_buckets
        int   x_start  = bar_index + proj_offset + 2          // just right of forward body (x_r = +1, gap)
        int   poc_idx  = 0
        float poc_val  = 0.0

        for i = 0 to n_buckets - 1
            float v        = array.get(buckets, i)
            float av       = math.abs(v)
            float norm     = max_abs > 0 ? math.sqrt(av / max_abs) : 0.0
            bool  is_imb   = show_imbalance and av <= thr_imb
            bool  is_spike = av >= thr_spike and not is_imb
            int   len      = is_imb ? 1 : math.max(1, math.round(norm * profile_width))
            float y_bot    = htf_low + bucket_h * i
            float y_top    = y_bot + bucket_h
            int   x_right  = x_start + len

            // Color decision:
            //   Bull-Bear (delta) → balanced zone (is_imb) reads NEUTRAL gray, not
            //     weak-green; otherwise green = net buyers, red = net sellers.
            //     This separates "two-way fight, no winner" from "slight buy".
            //   Intensity (volume) → spike=purple, imbalance=aqua, else gradient.
            color c_raw = palette_mode == "Bull-Bear"
                 ? (is_imb ? c_neutral : v >= 0 ? c_dn_1 : c_up_3)
                 : (is_spike ? c_up_4 : is_imb ? c_dn_4 : f_grad(norm))

            // Transparency: spike = base; imbalance = +50; gradient = fade with (1-norm).
            int t_eff = is_imb ? math.min(95, base_transparency + 50) : is_spike ? base_transparency : math.min(95, base_transparency + math.round((1.0 - norm) * 50))

            color c_eff = color.new(c_raw, t_eff)
            box b = box.new(left=x_start, top=y_top, right=x_right, bottom=y_bot,
                            border_color=color.new(c_raw, math.min(95, t_eff + 10)),
                            bgcolor=c_eff, border_width=1)
            array.push(profile_boxes, b)
            if av > poc_val
                poc_val := av
                poc_idx := i

        // 5) POC marker — dotted line at dominant-bucket midpoint, c_up_4 to fuse with spike
        if show_poc
            float poc_y = htf_low + bucket_h * (poc_idx + 0.5)
            poc_line := line.new(x1=bar_index + proj_offset - 1, y1=poc_y,
                                 x2=x_start + profile_width + 1, y2=poc_y,
                                 color=color.new(c_up_4, 0), width=2, style=line.style_dotted)

        // export state for Phase 6 / Phase 7
        last_poc_idx   := poc_idx
        last_thr_imb   := thr_imb
        last_thr_spike := thr_spike
        last_max_abs   := max_abs

// ========================================================================================================
// PHASE 6 — SPIKE % LABEL + CONTIGUOUS IMBALANCE ZONE COUNTER  (§4.3 / §4.4 follow-up)
// ========================================================================================================
// (a) Walks the bucket grid to count contiguous runs of imbalance buckets —
//     each run is one "imbalance zone" exposed to the HUD via last_imb_zones.
// (b) When show_spike_label is on AND the POC bucket exceeds spike_mult × mean,
//     draws a label at the POC bucket's price level reporting its share of
//     the period's total |metric|. The label only appears when there's a real
//     spike (POC ≥ thr_spike) — flat distributions don't get a phantom label.
var label spike_label    = na
var int   last_imb_zones = 0
var float last_sum_abs   = 0.0

if barstate.islast and not tf_guard and not na(htf_time) and last_max_abs > 0 and htf_high > htf_low
    label.delete(spike_label)

    // (a) zone counter + sum_abs (cheap, ≤50 ops total)
    float sum_abs = 0.0
    int   zones   = 0
    bool  in_zone = false
    for i = 0 to n_buckets - 1
        float av     = math.abs(array.get(buckets, i))
        sum_abs += av
        bool  is_imb = show_imbalance and av <= last_thr_imb
        if is_imb and not in_zone
            zones   += 1
            in_zone := true
        if not is_imb and in_zone
            in_zone := false
    last_imb_zones := zones
    last_sum_abs   := sum_abs

    // (b) POC % label — always shown for the dominant bucket (v1.1: decoupled
    //     from the spike gate, so the label is consistent across Volume/Delta).
    float poc_val_abs = math.abs(array.get(buckets, last_poc_idx))
    if show_spike_label and poc_val_abs > 0
        float bucket_h = (htf_high - htf_low) / n_buckets
        float poc_y    = htf_low + bucket_h * (last_poc_idx + 0.5)
        float pct      = sum_abs > 0 ? poc_val_abs / sum_abs * 100 : 0.0
        string lbl_txt = profile_metric == "Delta" ? str.tostring(pct, "#.0") + "% " + s_dominance : str.tostring(pct, "#.0") + "% " + s_spike_pct
        spike_label := label.new(x=bar_index + proj_offset + 2 + profile_width + 2, y=poc_y,
                                 text=lbl_txt, color=color.new(c_up_4, 30), textcolor=color.white,
                                 style=label.style_label_left, size=font_size)

// ========================================================================================================
// PHASE 7 — INFO PANEL (HUD)
// ========================================================================================================
// Floating table summarizing the live HTF profile: HTF in use, % of period
// elapsed, POC price, imbalance-zone count, total HTF candle volume. When the
// chart-TF ≥ HTF guard is active, the panel collapses to a single warning row
// (s_guard_msg) so users always get feedback, even when the profile is hidden.
var table hud = na

// Compact volume formatter — K / M / B suffix, 2-dp. Keeps the HUD column narrow.
f_vol_short(float v) =>
    float av = math.abs(v)
    av >= 1e9 ? str.tostring(v / 1e9, "#.##") + "B" : av >= 1e6 ? str.tostring(v / 1e6, "#.##") + "M" : av >= 1e3 ? str.tostring(v / 1e3, "#.##") + "K" : str.tostring(v, "#.##")

if barstate.islast and show_panel
    if na(hud)
        hud := table.new(
             panel_pos == "Top Left"      ? position.top_left :
             panel_pos == "Bottom Right"  ? position.bottom_right :
             panel_pos == "Bottom Left"   ? position.bottom_left :
                                            position.top_right,
             columns=2, rows=6, border_width=1, frame_color=color.new(c_neutral, 50), frame_width=1)
    table.clear(hud, 0, 0, 1, 5)

    color c_row_bg = color.new(c_black, 70)
    color c_hdr_bg = color.new(c_up_4, 30)

    if tf_guard
        table.cell(hud, 0, 0, s_guard_msg, text_color=color.new(c_up_3, 0), bgcolor=color.new(c_neutral, 85), text_size=font_size)
        table.merge_cells(hud, 0, 0, 1, 0)
    else
        // Header (merged across both columns)
        table.cell(hud, 0, 0, "HTF PROFILE", text_color=color.white, bgcolor=c_hdr_bg, text_size=font_size)
        table.cell(hud, 1, 0, "",            bgcolor=c_hdr_bg)
        table.merge_cells(hud, 0, 0, 1, 0)

        // HTF in use
        table.cell(hud, 0, 1, s_htf, text_color=color.white, bgcolor=c_row_bg, text_size=font_size)
        table.cell(hud, 1, 1, htf,   text_color=color.white, bgcolor=c_row_bg, text_size=font_size)

        // % elapsed (clamped 0..100; time is in ms, htf_sec in s)
        float elapsed_pct = htf_sec > 0 ? math.min(100.0, math.max(0.0, (time - htf_time) / (htf_sec * 1000.0) * 100.0)) : 0.0
        table.cell(hud, 0, 2, s_elapsed,                              text_color=color.white, bgcolor=c_row_bg, text_size=font_size)
        table.cell(hud, 1, 2, str.tostring(elapsed_pct, "#.0") + "%", text_color=color.white, bgcolor=c_row_bg, text_size=font_size)

        // POC price (last_poc_idx midpoint)
        float bucket_h = (htf_high - htf_low) / n_buckets
        float poc_y    = htf_low + bucket_h * (last_poc_idx + 0.5)
        table.cell(hud, 0, 3, s_poc,                               text_color=color.white,           bgcolor=c_row_bg, text_size=font_size)
        table.cell(hud, 1, 3, str.tostring(poc_y, format.mintick), text_color=color.new(c_up_4, 0),  bgcolor=c_row_bg, text_size=font_size)

        // Imbalance zones
        table.cell(hud, 0, 4, s_imbz,                              text_color=color.white,           bgcolor=c_row_bg, text_size=font_size)
        table.cell(hud, 1, 4, str.tostring(last_imb_zones),        text_color=color.new(c_dn_4, 0),  bgcolor=c_row_bg, text_size=font_size)

        // Total HTF volume
        table.cell(hud, 0, 5, s_total_vol,           text_color=color.white, bgcolor=c_row_bg, text_size=font_size)
        table.cell(hud, 1, 5, f_vol_short(htf_vol),  text_color=color.white, bgcolor=c_row_bg, text_size=font_size)
````
