# Liquidity Acceptance Map [PhenLabs]

- url: https://www.tradingview.com/script/6gZ7tZmZ-Liquidity-Acceptance-Map-PhenLabs/
- type: indicator
- pine_id: PUB;332e6c0f6cb94b72a75a7d066c2da10b
- version: 1.0

## Description

[b]📊 Liquidity Acceptance Map [PhenLabs][/b]
[i]v1.0 — Equal high/low sweeps graded by a volume + ATR acceptance score — only the highest-conviction zones plotted[/i]

https://www.tradingview.com/x/NKhmBrs5/

📌 [b]OVERVIEW[/b]

[b]Liquidity Acceptance Map (LAM)[/b] identifies high-probability liquidity zones by combining three layers of confirmation: equal high/low detection (liquidity pool location), sweep event confirmation (price takes out the level), and a graded [b]Acceptance Score (0–100)[/b] that measures how convincingly the market accepted the new price range using volume and ATR expansion.

Zones that don’t clear the score threshold are never plotted — only the highest-conviction sweeps make it to the chart. A real-time dashboard shows all active zones, their type, and live scores. An optional HTF EMA bias filter ensures you only see zones aligned with the higher-timeframe trend.


[b]HOW IT WORKS[/b]

[*] [b]Equal High/Low Detection[/b]
[list]
[*] Swing pivots are identified using a balanced left/right lookback window
[*] Two consecutive pivots within the configurable [b]Equal Level Tolerance %[/b] form a liquidity pool
[*] The pool level is the average of the two pivots — reducing precision noise
[/list]

[*] [b]Sweep Confirmation[/b]
[list]
[*] A sweep fires when price exceeds the pool level by [b]Sweep Margin %[/b]
[*] Optional: require the [b]close[/b] to be beyond the level (prevents wick-only traps)
[*] Sweep detection is gated on [b]barstate.isconfirmed[/b] — no repainting
[/list]

[*] [b]Acceptance Score (0–100)[/b]
[list]
[*] Calculated on the sweep bar using two components:
[*] [b]Volume Component[/b]: how far current volume exceeds the N-bar average, normalized against the configured multiplier
[*] [b]ATR Component[/b]: how far current ATR exceeds the ATR average, normalized against the configured multiplier
[*] Weighted combination: [b]Score = Vol Score × Vol Weight% + ATR Score × (100 - Vol Weight%)[/b]
[*] Score of 100 = full volume AND full ATR expansion at or above both multiplier thresholds
[*] Zones with Score below [b]Minimum Acceptance Score[/b] are silently discarded
[/list]

[*] [b]Zone Management[/b]
[list]
[*] Accepted zones plotted as semi-transparent filled rectangles with a label: type, score, and entry price
[*] Each zone includes a [b]dashed invalidation line[/b] at a configurable offset beyond the zone boundary
[*] When price closes beyond the invalidation level, the zone is greyed out — never deleted, always auditable
[*] Maximum active zones is configurable (default: 2) — oldest zone removed when limit is hit
[/list]

[*] [b]HTF Bias Filter (Optional)[/b]
[list]
[*] Pulls an EMA from a user-selected higher timeframe using [b]lookahead_off[/b] — no lookahead repaint
[*] Bullish zones (swept lows) only plot when HTF EMA is rising
[*] Bearish zones (swept highs) only plot when HTF EMA is falling
[*] Disabled by default — works as a standalone tool without it
[/list]

🔑 [b]POINTS OF INNOVATION[/b]

[list]
[*] [b]Graded Acceptance Score[/b] — most liquidity tools are binary (sweep or no sweep); LAM adds a 0–100 confidence layer so you know how much conviction backed the sweep
[*] [b]Dual-component scoring[/b] — volume expansion alone can mislead during low-ATR consolidation; combining both components produces a more robust regime signal
[*] [b]Zone cap per session[/b] — prevents chart clutter; only the 1–2 most relevant zones stay active at any time
[*] [b]Non-destructive invalidation[/b] — invalidated zones are greyed out, not deleted — preserving historical context without cluttering the active signal layer
[*] [b]HTF bias integration[/b] — directional conviction from a higher timeframe filters out counter-trend sweeps that statistically resolve against you
[*] [b]Dashboard table[/b] — real-time view of all active zones, types, and scores without needing to hover over boxes
[/list]

🔧 [b]SETTINGS[/b]

[b]Equal High/Low Detection[/b]
[list]
[*] [b]Swing Lookback[/b] | Default: 20 | Range: 5–100 | Bars used to identify swing pivots
[*] [b]Equal Level Tolerance (%)[/b] | Default: 0.1 | Range: 0.0–2.0 | Max % difference for two pivots to be considered “equal”
[/list]

[b]Sweep Confirmation[/b]
[list]
[*] [b]Sweep Margin (%)[/b] | Default: 0.1 | Range: 0.0–2.0 | Price must exceed the pool level by this % to confirm a sweep
[*] [b]Require Close Beyond Sweep[/b] | Default: ON | Sweep requires a confirmed bar close beyond the level
[/list]

[b]Acceptance Score[/b]
[list]
[*] [b]Volume Expansion Multiplier[/b] | Default: 1.5 | Range: 1.0–5.0 | Volume ratio needed for full volume score
[*] [b]ATR Expansion Multiplier[/b] | Default: 1.2 | Range: 1.0–5.0 | ATR ratio needed for full ATR score
[*] [b]Volume Weight in Score (%)[/b] | Default: 60 | Range: 0–100 | Split between volume and ATR in the composite score
[*] [b]Minimum Acceptance Score[/b] | Default: 60 | Range: 0–100 | Zones below this score are discarded
[*] [b]Score MA Lookback[/b] | Default: 20 | Range: 5–100 | Lookback for volume and ATR moving averages
[/list]

[b]Zone Management[/b]
[list]
[*] [b]Max Active Zones[/b] | Default: 2 | Range: 1–5 | Cap on simultaneously visible zones
[*] [b]Invalidation Offset (%)[/b] | Default: 0.2 | Range: 0.0–2.0 | Close beyond this % negates the zone
[*] [b]Show Dashboard[/b] | Default: ON | Top-right table of active zones + scores
[/list]

[b]HTF Bias Filter[/b]
[list]
[*] [b]Enable HTF Bias Filter[/b] | Default: OFF
[*] [b]HTF Timeframe[/b] | Default: 240 (4H) | Higher timeframe for EMA
[*] [b]HTF EMA Period[/b] | Default: 50 | EMA period on the HTF
[/list]

[b]Colors[/b]
[list]
[*] Bullish Zone, Bearish Zone, Sweep Marker, Invalidation Line — all fully customizable
[/list]

🔥 [b]ALERTS[/b]

[list]
[*] [b]LAM — Bullish Sweep Accepted[/b]: fires when a bullish sweep passes the acceptance score threshold
[*] [b]LAM — Bearish Sweep Accepted[/b]: fires when a bearish sweep passes the acceptance score threshold
[/list]

🎨 [b]VISUAL GUIDE[/b]

[list]
[*] [b]Teal filled rectangle[/b] = active bullish zone (swept low, price expected to hold as support)
[*] [b]Red filled rectangle[/b] = active bearish zone (swept high, price expected to hold as resistance)
[*] [b]Grey filled rectangle[/b] = invalidated zone (price closed beyond the invalidation line)
[*] [b]Dashed grey line[/b] = invalidation level for each zone
[*] [b]Orange triangle markers[/b] = sweep confirmation events (bull = below bar, bear = above bar)
[*] [b]Top-right table[/b] = dashboard: price level, zone type, acceptance score
[/list]

📖 [b]USAGE NOTES[/b]

[list]
[*] Designed for [b]1H, 4H, and Daily[/b] timeframes — where equal high/low clusters carry the most institutional significance
[*] On [b]lower timeframes (15m)[/b], increase [b]Equal Level Tolerance[/b] to 0.15–0.2% to account for spread noise
[*] On [b]volatile assets (crypto)[/b], increase [b]Sweep Margin[/b] to 0.2–0.3% to avoid false sweep triggers
[*] [b]Scores above 75[/b] indicate very high-conviction sweeps — consider these primary entries
[*] [b]Scores 60–75[/b] are valid but lower confidence — useful for confirmation, not standalone entry
[*] Enable [b]HTF Bias Filter[/b] to avoid counter-trend fades in strongly trending markets
[*] The [b]zone height is one ATR[/b] centered on the swept level — giving each zone contextual thickness relative to the instrument’s volatility
[/list]

✅ [b]WORKS WELL WITH[/b]

[list]
[*] Volume profile tools (to confirm zone with high-volume nodes)
[*] Session-based VWAP (anchored from sweep bar)
[*] Trend filters (EMA, Supertrend) to qualify zone direction
[*] Risk management tools (ATR-based stops, aligning with invalidation levels)
[/list]

[quote]⚠️ [b]DISCLAIMER[/b]

This indicator is for educational and research purposes only. It does not constitute financial advice or a trading recommendation. Past performance does not guarantee future results. Always conduct your own analysis before making any trading or investment decision.[/quote]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © PhenLabs
//@version=6
//
// Liquidity Acceptance Map [PhenLabs]
// v1.0
//
// Core concept:
//   1. Detect equal swing highs / lows (liquidity pools)
//   2. Confirm a sweep event (price breaks the level by a configurable margin)
//   3. Score the sweep with an Acceptance Score (0–100) from volume + ATR expansion
//   4. Only plot zones that pass the minimum score threshold
//   5. Optional: filter by HTF EMA directional bias
//   6. Manage a capped number of active zones per session; invalidate on close-through
//
// Anti-repaint: all zone creation and invalidation gated on barstate.isconfirmed.
// HTF EMA uses request.security with lookahead_off.

indicator(
     title          = "Liquidity Acceptance Map [PhenLabs]",
     shorttitle     = "LAM",
     overlay        = true,
     max_boxes_count  = 50,
     max_labels_count = 100,
     max_lines_count  = 100)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════════════════════

var string GRP_DETECT  = "Equal High/Low Detection"
lookback        = input.int  (20,    "Swing Lookback",               minval=5,  maxval=100,  group=GRP_DETECT,
     tooltip="Number of bars to look back when searching for swing pivots used as liquidity pool candidates.")
eq_tolerance    = input.float(0.1,   "Equal Level Tolerance (%)",   minval=0.0, maxval=2.0, step=0.05, group=GRP_DETECT,
     tooltip="Two swing highs/lows are considered 'equal' if they are within this % of each other. Handles instrument precision differences.")

var string GRP_SWEEP   = "Sweep Confirmation"
sweep_margin    = input.float(0.1,   "Sweep Margin (%)",             minval=0.0, maxval=2.0, step=0.05, group=GRP_SWEEP,
     tooltip="Price must exceed the liquidity level by at least this % to confirm a sweep event.")
require_close   = input.bool (true,  "Require Close Beyond Sweep",   group=GRP_SWEEP,
     tooltip="ON = sweep only confirmed when price closes beyond the level + margin. OFF = intrabar wick sufficient.")

var string GRP_ACCEPT  = "Acceptance Score"
vol_mult        = input.float(1.5,   "Volume Expansion Multiplier",  minval=1.0, maxval=5.0, step=0.1,  group=GRP_ACCEPT,
     tooltip="Volume expansion ratio (current / MA) required to score full volume points. Bars at or above this get 100% of the volume weight.")
atr_mult        = input.float(1.2,   "ATR Expansion Multiplier",     minval=1.0, maxval=5.0, step=0.1,  group=GRP_ACCEPT,
     tooltip="ATR expansion ratio (current ATR / ATR MA) required to score full ATR points. Bars at or above this get 100% of the ATR weight.")
vol_weight      = input.float(60.0,  "Volume Weight in Score (%)",   minval=0.0, maxval=100.0, step=5.0, group=GRP_ACCEPT,
     tooltip="Percentage of the Acceptance Score derived from volume expansion. Remainder goes to ATR expansion.")
min_score       = input.float(60.0,  "Minimum Acceptance Score",     minval=0.0, maxval=100.0, step=5.0, group=GRP_ACCEPT,
     tooltip="Zones with Acceptance Score below this threshold are not plotted.")
score_lookback  = input.int  (20,    "Score MA Lookback",            minval=5,  maxval=100,  group=GRP_ACCEPT,
     tooltip="Lookback period for the volume and ATR moving averages used in acceptance scoring.")

var string GRP_ZONES   = "Zone Management"
max_zones       = input.int  (2,     "Max Active Zones",             minval=1,  maxval=5,    group=GRP_ZONES,
     tooltip="Maximum number of simultaneously active zones. Oldest zone is removed when this limit is exceeded.")
inv_offset      = input.float(0.2,   "Invalidation Offset (%)",      minval=0.0, maxval=2.0, step=0.05, group=GRP_ZONES,
     tooltip="A zone is invalidated when price closes this % beyond the zone boundary on the opposite side.")
show_dashboard  = input.bool (true,  "Show Dashboard",               group=GRP_ZONES,
     tooltip="Display a top-right table showing all active zones, their type, and acceptance score.")

var string GRP_HTF     = "HTF Bias Filter (Optional)"
htf_enabled     = input.bool (false, "Enable HTF Bias Filter",       group=GRP_HTF,
     tooltip="When enabled, only plot bullish zones when the HTF EMA is rising; only bearish zones when falling.")
htf_tf          = input.timeframe("240", "HTF Timeframe",            group=GRP_HTF,
     tooltip="Higher timeframe to pull the EMA from for directional bias.")
htf_ema_len     = input.int  (50,    "HTF EMA Period",               minval=5,  maxval=500,  group=GRP_HTF,
     tooltip="EMA period on the higher timeframe used to determine bullish/bearish directional bias.")

var string GRP_COLORS  = "Colors"
bull_color      = input.color(color.new(color.teal, 70),  "Bullish Zone",        group=GRP_COLORS)
bear_color      = input.color(color.new(color.red,  70),  "Bearish Zone",        group=GRP_COLORS)
sweep_color     = input.color(color.new(color.orange, 0), "Sweep Marker",        group=GRP_COLORS)
inv_color       = input.color(color.new(color.gray, 50),  "Invalidation Line",   group=GRP_COLORS)

// ══════════════════════════════════════════════════════════════════════════════
// UTILITY: percentage-based price helpers
// ══════════════════════════════════════════════════════════════════════════════

pct_above(base, pct) => base * (1.0 + pct / 100.0)
pct_below(base, pct) => base * (1.0 - pct / 100.0)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 1 — HTF EMA BIAS
// ══════════════════════════════════════════════════════════════════════════════
// Pulled once per bar with lookahead_off; no repaint risk.

htf_ema_raw = request.security(syminfo.tickerid, htf_tf,
     ta.ema(close, htf_ema_len), lookahead=barmerge.lookahead_off)

// Bias: +1 bullish (EMA rising), -1 bearish (EMA falling), 0 flat/disabled
htf_bias = htf_enabled
     ? (htf_ema_raw > htf_ema_raw[1] ? 1 : htf_ema_raw < htf_ema_raw[1] ? -1 : 0)
     : 0  // 0 = filter disabled → accept all zones

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 2 — EQUAL HIGH / LOW DETECTION
// ══════════════════════════════════════════════════════════════════════════════
// Identify swing pivots and tag them as liquidity pool candidates when two
// recent pivots are within the tolerance band of each other.

// Swing pivot detection using ta.pivothigh / ta.pivotlow
// left/right = lookback // 2 bars each side for a balanced pivot
pivot_left  = math.max(lookback / 2, 2)
pivot_right = math.max(lookback / 2, 2)

ph = ta.pivothigh(high, pivot_left, pivot_right)
pl = ta.pivotlow (low,  pivot_left, pivot_right)

// Track the last two confirmed swing highs and lows
var float prev_ph  = na
var float last_ph  = na
var float prev_pl  = na
var float last_pl  = na

if not na(ph)
    prev_ph := last_ph
    last_ph := ph

if not na(pl)
    prev_pl := last_pl
    last_pl := pl

// Equal level test: two pivots within tolerance %
eq_high_active = not na(prev_ph) and not na(last_ph) and
     math.abs(last_ph - prev_ph) / prev_ph * 100.0 <= eq_tolerance

eq_low_active  = not na(prev_pl) and not na(last_pl) and
     math.abs(last_pl - prev_pl) / prev_pl * 100.0 <= eq_tolerance

// Reference price for each detected liquidity pool (average of the two pivots)
eq_high_level = eq_high_active ? (last_ph + prev_ph) / 2.0 : na
eq_low_level  = eq_low_active  ? (last_pl + prev_pl) / 2.0 : na

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 3 — ACCEPTANCE SCORE COMPUTATION
// ══════════════════════════════════════════════════════════════════════════════
// Score = vol_component * vol_weight% + atr_component * (100 - vol_weight%)
// Each component is clamped 0–100 based on how far the expansion ratio
// exceeds the baseline (ratio of 1.0) vs the full multiplier threshold.

atr_val     = ta.atr(score_lookback)
atr_ma      = ta.sma(atr_val, score_lookback)
vol_ma      = ta.sma(volume,  score_lookback)

// Expansion ratios (clamped ≥ 0)
vol_ratio   = vol_ma  > 0 ? volume  / vol_ma  : 1.0
atr_ratio   = atr_ma  > 0 ? atr_val / atr_ma  : 1.0

// Linear interpolation: ratio 1.0 → 0 pts; ratio >= multiplier → 100 pts
f_score(ratio, multiplier) =>
    math.min(math.max((ratio - 1.0) / math.max(multiplier - 1.0, 0.001) * 100.0, 0.0), 100.0)

vol_score   = f_score(vol_ratio, vol_mult)
atr_score   = f_score(atr_ratio, atr_mult)

atr_wt      = 100.0 - vol_weight
accept_score = vol_score * (vol_weight / 100.0) + atr_score * (atr_wt / 100.0)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 4 — SWEEP DETECTION
// ══════════════════════════════════════════════════════════════════════════════
// A sweep fires when price exceeds the liquidity level by sweep_margin%.
// When require_close is on, we check the close; otherwise the wick suffices.
// All sweep → zone creation logic is gated on barstate.isconfirmed.

price_hi_ref = require_close ? close : high
price_lo_ref = require_close ? close : low

// Bullish sweep: price sweeps below equal low, then the zone becomes a support
swept_low  = eq_low_active  and price_lo_ref <= pct_below(eq_low_level,  sweep_margin)
// Bearish sweep: price sweeps above equal high, zone becomes resistance
swept_high = eq_high_active and price_hi_ref >= pct_above(eq_high_level, sweep_margin)

// HTF bias filter — pass only zones aligned with HTF direction
// htf_bias = 0 (disabled): accept both
// htf_bias = 1 (bullish): only plot bullish zones (swept_low → support)
// htf_bias = -1 (bearish): only plot bearish zones (swept_high → resistance)
htf_pass_bull = not htf_enabled or htf_bias >= 0
htf_pass_bear = not htf_enabled or htf_bias <= 0

sweep_bull_confirmed = barstate.isconfirmed and swept_low  and accept_score >= min_score and htf_pass_bull
sweep_bear_confirmed = barstate.isconfirmed and swept_high and accept_score >= min_score and htf_pass_bear

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 5 — ZONE MANAGER
// ══════════════════════════════════════════════════════════════════════════════
// Each zone is stored as a box + label + invalidation line.
// Arrays track zone metadata for invalidation checking and dashboard display.

var box[]   zone_boxes   = array.new<box>()
var line[]  zone_invlines= array.new<line>()
var label[] zone_labels  = array.new<label>()
var float[] zone_top     = array.new<float>()
var float[] zone_bot     = array.new<float>()
var bool[]  zone_is_bull = array.new<bool>()
var float[] zone_scores  = array.new<float>()
var bool[]  zone_valid   = array.new<bool>()

// Helper: remove a zone at index i from all arrays
zone_delete(int i) =>
    box.delete  (array.get(zone_boxes,    i))
    line.delete (array.get(zone_invlines, i))
    label.delete(array.get(zone_labels,  i))
    array.remove(zone_boxes,    i)
    array.remove(zone_invlines, i)
    array.remove(zone_labels,   i)
    array.remove(zone_top,      i)
    array.remove(zone_bot,      i)
    array.remove(zone_is_bull,  i)
    array.remove(zone_scores,   i)
    array.remove(zone_valid,    i)

// Helper: create a new zone and append to arrays
zone_create(float top_price, float bot_price, bool is_bull, float score) =>
    zc = is_bull ? bull_color : bear_color
    // Zone box — extends right dynamically (right = bar_index + 50 initially)
    b = box.new(
         left       = bar_index,
         top        = top_price,
         right      = bar_index + 50,
         bottom     = bot_price,
         bgcolor    = zc,
         border_color = color.new(zc, 30),
         border_width = 1)
    // Invalidation line
    inv_price  = is_bull
         ? pct_below(bot_price, inv_offset)   // bull zone: inv below bottom
         : pct_above(top_price, inv_offset)   // bear zone: inv above top
    inv_ln = line.new(
         x1    = bar_index,
         y1    = inv_price,
         x2    = bar_index + 50,
         y2    = inv_price,
         color = inv_color,
         style = line.style_dashed,
         width = 1)
    // Label inside the box
    lbl_y = (top_price + bot_price) / 2.0
    lbl_txt = (is_bull ? "▲ BULL" : "▼ BEAR") + "\nScore: " + str.tostring(math.round(score)) + "\nEntry: " + str.tostring(is_bull ? top_price : bot_price, format.mintick)
    lbl = label.new(
         x         = bar_index + 2,
         y         = lbl_y,
         text      = lbl_txt,
         color     = color.new(color.black, 100),
         textcolor = color.new(zc, 0),
         style     = label.style_none,
         size      = size.small)
    array.push(zone_boxes,    b)
    array.push(zone_invlines, inv_ln)
    array.push(zone_labels,   lbl)
    array.push(zone_top,      top_price)
    array.push(zone_bot,      bot_price)
    array.push(zone_is_bull,  is_bull)
    array.push(zone_scores,   score)
    array.push(zone_valid,    true)

// ── Sweep latch: fire only ONCE per unique sweep event ────────────────────────
// Track the pool level that last triggered each direction so consecutive bars
// in the same sweep cluster don't each create a new zone / marker.
var float last_bull_sweep_level = na
var float last_bear_sweep_level = na

// A sweep is "new" only if the pool level has changed since the last fired sweep
is_new_bull_sweep = sweep_bull_confirmed and
     (na(last_bull_sweep_level) or math.abs(eq_low_level - last_bull_sweep_level) / last_bull_sweep_level * 100.0 > eq_tolerance)

is_new_bear_sweep = sweep_bear_confirmed and
     (na(last_bear_sweep_level) or math.abs(eq_high_level - last_bear_sweep_level) / last_bear_sweep_level * 100.0 > eq_tolerance)

if is_new_bull_sweep
    last_bull_sweep_level := eq_low_level

if is_new_bear_sweep
    last_bear_sweep_level := eq_high_level

// ── Count only VALID (non-invalidated) zones toward the cap ───────────────────
count_valid_zones() =>
    count = 0
    n = array.size(zone_valid)
    if n > 0
        for k = 0 to n - 1
            if array.get(zone_valid, k)
                count += 1
    count

// ── Zone creation on confirmed NEW sweep ──────────────────────────────────────

// Zone height = current ATR (gives context-relevant thickness)
zone_half = atr_val / 2.0

if is_new_bull_sweep
    if count_valid_zones() >= max_zones
        n = array.size(zone_valid)
        if n > 0
            for k = 0 to n - 1
                if array.get(zone_valid, k)
                    zone_delete(k)
                    break
    top_p = eq_low_level  + zone_half
    bot_p = eq_low_level  - zone_half
    zone_create(top_p, bot_p, true, accept_score)

if is_new_bear_sweep
    if count_valid_zones() >= max_zones
        n = array.size(zone_valid)
        if n > 0
            for k = 0 to n - 1
                if array.get(zone_valid, k)
                    zone_delete(k)
                    break
    top_p = eq_high_level + zone_half
    bot_p = eq_high_level - zone_half
    zone_create(top_p, bot_p, false, accept_score)

// ── Extend active zone boxes rightward every bar ───────────────────────────────
// Also check for invalidation on each confirmed bar.

if barstate.isconfirmed and array.size(zone_boxes) > 0
    i = 0
    while i < array.size(zone_boxes)
        is_bull_z = array.get(zone_is_bull, i)
        top_z     = array.get(zone_top,     i)
        bot_z     = array.get(zone_bot,     i)
        valid_z   = array.get(zone_valid,   i)

        if valid_z
            // Extend box and invalidation line to current bar
            box.set_right (array.get(zone_boxes,    i), bar_index + 10)
            line.set_x2   (array.get(zone_invlines, i), bar_index + 10)
            label.set_x   (array.get(zone_labels,   i), math.max(bar_index - 20, box.get_left(array.get(zone_boxes, i)) + 2))

            // Invalidation check: close crosses the invalidation offset on wrong side
            inv_p = is_bull_z
                 ? pct_below(bot_z, inv_offset)
                 : pct_above(top_z, inv_offset)

            if (is_bull_z and close < inv_p) or (not is_bull_z and close > inv_p)
                // Mark invalid — grey out the box, delete invalidation line visually
                array.set(zone_valid, i, false)
                box.set_bgcolor(array.get(zone_boxes, i), color.new(color.gray, 85))
                box.set_border_color(array.get(zone_boxes, i), color.new(color.gray, 60))
                label.set_textcolor(array.get(zone_labels, i), color.new(color.gray, 30))
        i += 1

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 6 — SWEEP MARKERS
// ══════════════════════════════════════════════════════════════════════════════
// Global-scope plotshape — condition pre-computed as boolean series.

// Markers fire only on new unique sweeps — not on every bar of the same event
plotshape(is_new_bull_sweep, title="Bullish Sweep",
     style=shape.triangleup, location=location.belowbar,
     color=sweep_color, size=size.small)

plotshape(is_new_bear_sweep, title="Bearish Sweep",
     style=shape.triangledown, location=location.abovebar,
     color=sweep_color, size=size.small)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 7 — DASHBOARD TABLE
// ══════════════════════════════════════════════════════════════════════════════

var table dash = table.new(position.top_right, 3, 6,
     bgcolor=color.new(color.black, 80), border_color=color.new(color.gray, 60), border_width=1)

if show_dashboard and barstate.islast
    table.cell(dash, 0, 0, "LAM Active Zones",    text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 60))
    table.cell(dash, 1, 0, "Type",                text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 60))
    table.cell(dash, 2, 0, "Score",               text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 60))

    n = array.size(zone_boxes)
    row = 1
    idx = n - 1  // show most recent first
    while idx >= 0 and row <= 5
        valid_z  = array.get(zone_valid,   idx)
        bull_z   = array.get(zone_is_bull, idx)
        score_z  = array.get(zone_scores,  idx)
        top_z    = array.get(zone_top,     idx)
        bot_z    = array.get(zone_bot,     idx)
        mid_z    = (top_z + bot_z) / 2.0

        rc = valid_z ? (bull_z ? color.new(color.teal, 70) : color.new(color.red, 70)) : color.new(color.gray, 70)
        status   = valid_z ? (bull_z ? "▲ BULL" : "▼ BEAR") : "✕ INVLD"
        lv_str   = str.tostring(mid_z, format.mintick)

        table.cell(dash, 0, row, lv_str,                          text_color=color.white, text_size=size.tiny, bgcolor=rc)
        table.cell(dash, 1, row, status,                          text_color=color.white, text_size=size.tiny, bgcolor=rc)
        table.cell(dash, 2, row, str.tostring(math.round(score_z)), text_color=color.white, text_size=size.tiny, bgcolor=rc)
        row  += 1
        idx  -= 1

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 8 — ALERTS
// ══════════════════════════════════════════════════════════════════════════════

alertcondition(is_new_bull_sweep,
     title   = "LAM — Bullish Sweep Accepted",
     message = "LAM: Bullish liquidity sweep accepted on {{ticker}} {{interval}}")

alertcondition(is_new_bear_sweep,
     title   = "LAM — Bearish Sweep Accepted",
     message = "LAM: Bearish liquidity sweep accepted on {{ticker}} {{interval}}")
````
