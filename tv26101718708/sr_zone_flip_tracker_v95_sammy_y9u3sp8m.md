# S/R Zone Flip Tracker v9.5 - SAMMY

- url: https://www.tradingview.com/script/y9u3sP8M-S-R-Zone-Flip-Tracker-v9-5-SAMMY/
- type: indicator
- pine_id: PUB;4233f1818ab44704965243618a7bfe7f
- version: 4.0

## Description

S/R Zone Flip Tracker

WHAT IT DOES

This indicator detects support and resistance zones from confirmed price pivots, then tracks when price breaks through a zone and "flips" its role - broken resistance becomes support, broken support becomes resistance. Flipped zones are recolored and highlighted for a configurable number of bars, and flip events fire markers and alerts. A ladder table lists the nearest zones above and below current price, sorted by distance, so you can read the immediate S/R structure at a glance without scanning the chart.

HOW IT WORKS

1. Zone creation: Swing highs and lows are detected with ta.pivothigh / ta.pivotlow. Each confirmed pivot creates a zone centered on the pivot price. Zone half-width is either a multiple of ATR (adaptive to volatility) or a fixed dollar amount, selectable in settings.

2. Zone maintenance: Nearby zones are merged when their midpoints fall within an ATR-based merge threshold. New pivots that land inside an existing zone's dedup radius are discarded instead of stacking duplicates. Zones farther from price than a distance cap (the larger of an ATR window and a percent-of-price window) are pruned, and if more zones remain than the per-mode maximum, the farthest ones are evicted. This keeps only the structurally relevant levels on the chart.

3. Flip detection: On each confirmed bar close, every zone is tested against the break method you select. "Close" requires the candle to close beyond the zone edge plus an ATR-based confirmation buffer. "Wick" allows the high/low to trigger the break. When a zone is broken upward it is reclassified as support; broken downward it becomes resistance. The flip bar is recorded so recently flipped zones render in a stronger highlight color and are tagged "S Flipped" / "R Flipped" until the highlight age expires.

4. Flip throttling: A minimum-bars-between-flips setting suppresses repeated flip signals on the same side within a short window, reducing noise in choppy conditions.

5. Trading modes: Scalping, Intraday, Swing, and Position modes each carry their own independent parameter set (pivot length, zone width, confirmation buffer, flip throttle, zone count, distance caps). "Auto" selects the mode from the chart timeframe. "Manual" exposes a fully custom set. This lets one script behave sensibly from 1-minute charts to weekly charts without retuning on every timeframe change.

6. EMA cloud: An optional 9/21 EMA cloud (lengths configurable) provides directional context behind the zones. Green fill when fast is above slow, red when below.

NON-REPAINTING DESIGN

All flip state changes are gated on barstate.isconfirmed, so flips, markers, and alerts only occur on closed bars and do not change after the fact. The optional higher-timeframe confirmation uses request.security with a confirmed-bar offset so the higher-timeframe value never previews an unclosed HTF bar: on closed chart bars it reads the current HTF value, and on the developing bar it reads the last closed HTF value. Pivots by nature confirm only after the right-side lookback completes, so zones appear a fixed number of bars after the actual swing point - this is inherent to pivot detection, not repainting.

HOW TO USE IT

- Leave Trading Mode on Auto to let the script pick parameters from your chart timeframe, or select a mode explicitly to tune it.
- Watch the ladder table for the three nearest resistance zones above price and three nearest support zones below, with price and percent distance for each. An asterisk marks recently flipped zones.
- "Flip Up" markers print when resistance is confirmed broken and reclassified as support; "Flip Dn" marks the opposite. These are commonly read as breakout-and-retest context: a fresh flip zone is a candidate area for price to retest from the other side.
- Enable MTF Close Confirmation to require the break to hold on a higher timeframe before a flip registers, which filters out breaks that only exist on the chart timeframe.
- Three alerts are available: flip to support, flip to resistance, and any flip.

SETTINGS SUMMARY

- Per-mode: pivot left/right length, zone width ATR multiple, confirmation buffer, minimum bars between flips, max zones shown, distance caps (ATR multiple and percent).
- General: ATR length, break method (Close or Wick), dedup and merge thresholds, zone width mode (ATR or Fixed $), flip highlight age.
- Visual: zone colors for support, resistance, and recently flipped states; EMA cloud toggle and lengths; ladder table position and font size.

LIMITATIONS

- Zones confirm pivot-right bars after the swing point (inherent lag of pivot detection).
- Flip markers older than the Flip Label Lookback are not redrawn on chart reload; live alerts are unaffected.
- Requires roughly pivot length plus ATR length bars of history before the first zones appear.
- This is an analysis tool, not a trading system. It does not predict price and generates no buy/sell recommendations.

## Source Code

````pine
//@version=6
// S/R Zone Flip Tracker v9.11 - persistent-pool S/R flip tracker; v9.11 fixes the MTF lookahead repaint (fixed [1] offset, last completed HTF bar), decouples flip-throttle state from the marker lookback window so signal history is load-time deterministic, blocks same-bar flips on freshly created zones, adds an outside-bar close-direction tiebreak in Wick mode, makes ladder rows per side configurable, renders the visible set once per bar, and enforces display.none on all inputs / display.pane on all shape plots
indicator(title="S/R Zone Flip Tracker v9.11", shorttitle="SRFlip9.11", overlay=true, max_boxes_count=100)

// === MODE PICKER ===
trade_mode = input.string("Auto (by timeframe)", "Trading Mode", options=["Auto (by timeframe)", "Scalping (1-5 min)", "Intraday (5-60 min)", "Swing (1H-1D)", "Position (1W-1M)", "Manual"], group="Mode", display=display.none)

// === PER-MODE GROUPS ===
gSc = "Scalping Settings (1-5 min)"
sc_pl   = input.int(5, "Pivot Left/Right", minval=1, maxval=50, group=gSc, display=display.none)
sc_zw   = input.float(0.12, "Zone Width ATR Mult", minval=0.01, step=0.01, group=gSc, display=display.none)
sc_cb   = input.float(0.04, "Confirm ATR Buffer", minval=0.0, step=0.01, group=gSc, display=display.none)
sc_mb   = input.int(10, "Min Bars Between Flips", minval=1, maxval=50, group=gSc, display=display.none)
sc_mz   = input.int(5, "Max Zones Shown", minval=1, maxval=30, group=gSc, display=display.none)
sc_da   = input.float(10.0, "Max Zone Distance ATR Mult", minval=1.0, step=0.5, group=gSc, display=display.none)
sc_dp   = input.float(8.0, "Max Zone Distance %", minval=0.5, step=0.5, group=gSc, display=display.none)

gIn = "Intraday Settings (5-60 min)"
in_pl   = input.int(8, "Pivot Left/Right", minval=1, maxval=50, group=gIn, display=display.none)
in_zw   = input.float(0.20, "Zone Width ATR Mult", minval=0.01, step=0.01, group=gIn, display=display.none)
in_cb   = input.float(0.06, "Confirm ATR Buffer", minval=0.0, step=0.01, group=gIn, display=display.none)
in_mb   = input.int(6, "Min Bars Between Flips", minval=1, maxval=50, group=gIn, display=display.none)
in_mz   = input.int(5, "Max Zones Shown", minval=1, maxval=30, group=gIn, display=display.none)
in_da   = input.float(14.0, "Max Zone Distance ATR Mult", minval=1.0, step=0.5, group=gIn, display=display.none)
in_dp   = input.float(15.0, "Max Zone Distance %", minval=0.5, step=0.5, group=gIn, display=display.none)

gSw = "Swing Settings (1H-1D)"
sw_pl   = input.int(9, "Pivot Left/Right", minval=1, maxval=50, group=gSw, display=display.none)
sw_zw   = input.float(0.25, "Zone Width ATR Mult", minval=0.01, step=0.01, group=gSw, display=display.none)
sw_cb   = input.float(0.07, "Confirm ATR Buffer", minval=0.0, step=0.01, group=gSw, display=display.none)
sw_mb   = input.int(5, "Min Bars Between Flips", minval=1, maxval=50, group=gSw, display=display.none)
sw_mz   = input.int(6, "Max Zones Shown", minval=1, maxval=30, group=gSw, display=display.none)
sw_da   = input.float(18.0, "Max Zone Distance ATR Mult", minval=1.0, step=0.5, group=gSw, display=display.none)
sw_dp   = input.float(25.0, "Max Zone Distance %", minval=0.5, step=0.5, group=gSw, display=display.none)

gPo = "Position Settings (1W-1M)"
po_pl   = input.int(11, "Pivot Left/Right", minval=1, maxval=50, group=gPo, display=display.none)
po_zw   = input.float(0.22, "Zone Width ATR Mult", minval=0.01, step=0.01, group=gPo, display=display.none)
po_cb   = input.float(0.05, "Confirm ATR Buffer", minval=0.0, step=0.01, group=gPo, display=display.none)
po_mb   = input.int(4, "Min Bars Between Flips", minval=1, maxval=50, group=gPo, display=display.none)
po_mz   = input.int(8, "Max Zones Shown", minval=1, maxval=30, group=gPo, display=display.none)
po_da   = input.float(22.0, "Max Zone Distance ATR Mult", minval=1.0, step=0.5, group=gPo, display=display.none)
po_dp   = input.float(35.0, "Max Zone Distance %", minval=0.5, step=0.5, group=gPo, display=display.none)

gMan = "Manual Settings"
man_pl  = input.int(8, "Pivot Left/Right", minval=1, maxval=50, group=gMan, display=display.none)
man_zw  = input.float(0.15, "Zone Width ATR Mult", minval=0.01, step=0.01, group=gMan, display=display.none)
man_cb  = input.float(0.05, "Confirm ATR Buffer", minval=0.0, step=0.01, group=gMan, display=display.none)
man_mb  = input.int(6, "Min Bars Between Flips", minval=1, maxval=50, group=gMan, display=display.none)
man_mz  = input.int(6, "Max Zones Shown", minval=1, maxval=30, group=gMan, display=display.none)
man_da  = input.float(16.0, "Max Zone Distance ATR Mult", minval=1.0, step=0.5, group=gMan, display=display.none)
man_dp  = input.float(25.0, "Max Zone Distance %", minval=0.5, step=0.5, group=gMan, display=display.none)

// === GENERAL INPUTS ===
atr_len          = input.int(14, "ATR Length", minval=1, group="General", display=display.none)
flip_label_bars  = input.int(80, "Flip Label Lookback", minval=1, maxval=500, group="General", tooltip="Cosmetic only: markers older than this are not drawn. Flip state and the min-bars-between throttle are evaluated identically on every bar regardless of this window.", display=display.none)
flipped_age_bars = input.int(50, "Flipped Highlight Age", minval=1, maxval=500, group="General", display=display.none)

break_mode = input.string("Close", "Zone Break Method", options=["Close", "Wick"],
     tooltip="Close = confirmed candle close beyond zone. Wick = high/low break beyond zone. In Wick mode an outside bar that clears both sides is resolved by the close relative to the zone midpoint.", group="General", display=display.none)

dedup_mult = input.float(2.5, "Dedup Multiplier (x zone half-width)", minval=1.0, maxval=10.0, step=0.5,
     tooltip="A new pivot is discarded if it lands within this many half-widths of an existing SAME-TYPE zone's midpoint. Uses the existing zone's stored width, not live ATR.", group="General", display=display.none)
merge_mult = input.float(1.0, "Merge Threshold (x combined half-widths)", minval=0.1, maxval=5.0, step=0.1,
     tooltip="Two SAME-TYPE zones merge when the gap between midpoints is less than (half_i + half_j) * this value. 1.0 = merge when zones overlap or touch.", group="General", display=display.none)

width_mode = input.string("ATR", "Zone Width Mode", options=["ATR", "Fixed $"], group="General", display=display.none)
fixed_width_dollars = input.float(0.10, "[Fixed $] Zone Half-Width", minval=0.001, step=0.01, group="General", display=display.none)

col_support     = input.color(color.new(color.green, 60), "Support Zone", group="Colors", display=display.none)
col_resistance  = input.color(color.new(color.red, 60), "Resistance Zone", group="Colors", display=display.none)
col_flipped_sup = input.color(color.new(color.green, 25), "Recently Flipped to Support", group="Colors", display=display.none)
col_flipped_res = input.color(color.new(color.red, 25), "Recently Flipped to Resistance", group="Colors", display=display.none)

ema_cloud_on = input.bool(true, "Show EMA Cloud", group="EMA Cloud", display=display.none)
ema_fast_len = input.int(9, "EMA Fast Length", minval=1, group="EMA Cloud", display=display.none)
ema_slow_len = input.int(21, "EMA Slow Length", minval=1, group="EMA Cloud", display=display.none)

mtf_enabled = input.bool(false, "Enable MTF Close Confirmation", group="MTF", display=display.none)
mtf_tf = input.timeframe("", "MTF Timeframe", tooltip="Must be equal to or higher than the chart timeframe. A lower timeframe is ignored and the gate auto-bypasses. Confirmation uses the LAST COMPLETED bar of this timeframe (non-repainting), so the gate lags by up to one MTF bar by design.", group="MTF", display=display.none)

show_ladder = input.bool(true, "Show S/R Ladder Table", group="Ladder", display=display.none)
ladder_pos = input.string("Bottom Right", "Ladder Table Position", options=["Bottom Right", "Bottom Left", "Top Right", "Top Left", "Middle Right", "Middle Left"], group="Ladder", display=display.none)
ladder_font = input.string("Small", "Ladder Font Size", options=["Tiny", "Small", "Normal", "Large"], group="Ladder", display=display.none)
ladder_rows = input.int(3, "Ladder Rows Per Side", minval=1, maxval=10, group="Ladder", tooltip="How many resistance rows above NOW and support rows below NOW. Raise this in Position mode if you show more zones than fit.", display=display.none)

// === RESOLVE EFFECTIVE MODE ===
// Auto bucket boundaries (chart timeframe in minutes):
//   tf <= 5      -> Scalping
//   tf <= 60     -> Intraday
//   tf <= 1440   -> Swing (Daily INCLUSIVE lands here)
//   tf >  1440   -> Position (Weekly AND Monthly land here)
// Seconds charts convert to fractional minutes so they land in Scalping.
float tf_mins = timeframe.ismonthly ? 43200 : timeframe.isweekly ? 10080 : timeframe.isdaily ? 1440 : timeframe.isseconds ? timeframe.multiplier / 60.0 : timeframe.isintraday ? timeframe.multiplier : 60

string eff_mode = trade_mode
if trade_mode == "Auto (by timeframe)"
    if tf_mins <= 5
        eff_mode := "Scalping (1-5 min)"
    else if tf_mins <= 60
        eff_mode := "Intraday (5-60 min)"
    else if tf_mins <= 1440
        eff_mode := "Swing (1H-1D)"
    else
        eff_mode := "Position (1W-1M)"

// === RESOLVE ACTIVE SETTINGS FROM EFFECTIVE MODE ===
pivot_left = man_pl
pivot_right = man_pl
zone_atr_mult = man_zw
confirm_atr_mult = man_cb
min_bars_between = man_mb
active_max_zones = man_mz
dist_atr_mult = man_da
dist_pct = man_dp

if eff_mode == "Scalping (1-5 min)"
    pivot_left := sc_pl
    pivot_right := sc_pl
    zone_atr_mult := sc_zw
    confirm_atr_mult := sc_cb
    min_bars_between := sc_mb
    active_max_zones := sc_mz
    dist_atr_mult := sc_da
    dist_pct := sc_dp
else if eff_mode == "Intraday (5-60 min)"
    pivot_left := in_pl
    pivot_right := in_pl
    zone_atr_mult := in_zw
    confirm_atr_mult := in_cb
    min_bars_between := in_mb
    active_max_zones := in_mz
    dist_atr_mult := in_da
    dist_pct := in_dp
else if eff_mode == "Swing (1H-1D)"
    pivot_left := sw_pl
    pivot_right := sw_pl
    zone_atr_mult := sw_zw
    confirm_atr_mult := sw_cb
    min_bars_between := sw_mb
    active_max_zones := sw_mz
    dist_atr_mult := sw_da
    dist_pct := sw_dp
else if eff_mode == "Position (1W-1M)"
    pivot_left := po_pl
    pivot_right := po_pl
    zone_atr_mult := po_zw
    confirm_atr_mult := po_cb
    min_bars_between := po_mb
    active_max_zones := po_mz
    dist_atr_mult := po_da
    dist_pct := po_dp

// Persistent pool cap: keep several screens' worth of zones alive so pullbacks can
// re-reveal old levels. Only when the pool exceeds this cap is the farthest zone dropped.
int pool_cap = math.min(60, math.max(15, active_max_zones * 5))

// === CORE ===
atr_safe = nz(ta.atr(atr_len), 0.001)
zone_half = width_mode == "Fixed $" ? fixed_width_dollars : atr_safe * zone_atr_mult
confirm_buffer = atr_safe * confirm_atr_mult

// Visibility window: a zone is SHOWN only if it falls within BOTH the ATR window AND
// the percent window (math.min - tighter window binds). This is a render-time filter
// only; zones outside the window stay in the pool and reappear when price returns.
dist_by_atr = atr_safe * dist_atr_mult
dist_by_pct = close * dist_pct / 100.0
max_dist = math.min(dist_by_atr, dist_by_pct)

ph = ta.pivothigh(high, pivot_left, pivot_right)
pl = ta.pivotlow(low, pivot_left, pivot_right)

const int SUPPORT = 1
const int RESISTANCE = 2

// === ARRAYS ===
var float[] zone_mid = array.new_float()
var float[] zone_top = array.new_float()
var float[] zone_bot = array.new_float()
var int[] zone_type = array.new_int()
var int[] zone_bar = array.new_int()
var int[] zone_flip_bar = array.new_int()
var box[] zone_boxes = array.new_box()

var int last_flip_sup = na
var int last_flip_res = na

// === FUNCTIONS ===
fmt_price(float p) =>
    p < 10 ? str.tostring(p, "#.####") : p < 100 ? str.tostring(p, "#.###") : str.tostring(p, "#.##")

fmt_dist(float p) =>
    pct = (p - close) / close * 100
    (pct >= 0 ? "+" : "") + str.tostring(pct, "#.##") + "%"

ladder_position() =>
    ladder_pos == "Bottom Left" ? position.bottom_left : ladder_pos == "Top Right" ? position.top_right : ladder_pos == "Top Left" ? position.top_left : ladder_pos == "Middle Right" ? position.middle_right : ladder_pos == "Middle Left" ? position.middle_left : position.bottom_right

ladder_text_size() =>
    ladder_font == "Tiny" ? size.tiny : ladder_font == "Normal" ? size.normal : ladder_font == "Large" ? size.large : size.small

is_recent_flip(int b) =>
    not na(b) and bar_index - b <= flipped_age_bars

// Per-zone stored half-width: derived from the zone's own top/bot, NOT live ATR.
zone_half_at(int i) =>
    (array.get(zone_top, i) - array.get(zone_bot, i)) / 2.0

// Dedup is TYPE-AWARE (v9.10): a new pivot only counts as a duplicate of an existing
// zone of the SAME type, so a support pivot printing inside a resistance zone (the
// classic retest of a broken level) is never discarded.
is_duplicate(float price, int ztype) =>
    bool dup = false
    if array.size(zone_mid) > 0
        for i = 0 to array.size(zone_mid) - 1
            if array.get(zone_type, i) == ztype and math.abs(price - array.get(zone_mid, i)) < zone_half_at(i) * dedup_mult
                dup := true
                break
    dup

// Returns true when a zone was actually added, so merge/evict can run event-driven.
add_zone(float price, int ztype) =>
    bool added = false
    if not is_duplicate(price, ztype)
        array.push(zone_mid, price)
        array.push(zone_top, price + zone_half)
        array.push(zone_bot, price - zone_half)
        array.push(zone_type, ztype)
        array.push(zone_bar, bar_index - pivot_right)
        array.push(zone_flip_bar, int(na))
        added := true
    added

remove_zone(int idx) =>
    array.remove(zone_mid, idx)
    array.remove(zone_top, idx)
    array.remove(zone_bot, idx)
    array.remove(zone_type, idx)
    array.remove(zone_bar, idx)
    array.remove(zone_flip_bar, idx)

// Type-aware, width-based merge on STORED zone geometry (never live ATR):
// same-type zones merge when the midpoint gap is under (half_i + half_j) * merge_mult;
// merged geometry is the union span; the most recent flip bar is kept.
merge_zones() =>
    bool merged = true
    while merged
        merged := false
        if array.size(zone_mid) >= 2
            for i = 0 to array.size(zone_mid) - 2
                for j = i + 1 to array.size(zone_mid) - 1
                    if array.get(zone_type, i) == array.get(zone_type, j)
                        gap = math.abs(array.get(zone_mid, i) - array.get(zone_mid, j))
                        if gap < (zone_half_at(i) + zone_half_at(j)) * merge_mult
                            new_top = math.max(array.get(zone_top, i), array.get(zone_top, j))
                            new_bot = math.min(array.get(zone_bot, i), array.get(zone_bot, j))
                            new_mid = (new_top + new_bot) / 2.0
                            old_bar = math.min(array.get(zone_bar, i), array.get(zone_bar, j))
                            fb_i = array.get(zone_flip_bar, i)
                            fb_j = array.get(zone_flip_bar, j)
                            new_fb = na(fb_i) ? fb_j : na(fb_j) ? fb_i : math.max(fb_i, fb_j)
                            array.set(zone_mid, i, new_mid)
                            array.set(zone_top, i, new_top)
                            array.set(zone_bot, i, new_bot)
                            array.set(zone_bar, i, old_bar)
                            array.set(zone_flip_bar, i, new_fb)
                            remove_zone(j)
                            merged := true
                            break
                if merged
                    break

// Cap the persistent POOL (not the display count). Evicts the farthest zone only when
// the pool itself overflows, so ordinary trending never empties zone memory.
evict_pool_overflow() =>
    while array.size(zone_mid) > pool_cap
        int idx = 0
        float dist = -1
        for i = 0 to array.size(zone_mid) - 1
            d = math.abs(close - array.get(zone_mid, i))
            if d > dist
                dist := d
                idx := i
        remove_zone(idx)

// Build the render-time visible set: indices of pool zones within max_dist, sorted
// nearest-first, capped at active_max_zones. Non-destructive - the pool is untouched.
select_visible() =>
    int[] cand_idx = array.new_int()
    float[] cand_dist = array.new_float()
    if array.size(zone_mid) > 0
        for i = 0 to array.size(zone_mid) - 1
            d = math.abs(close - array.get(zone_mid, i))
            if d <= max_dist
                array.push(cand_idx, i)
                array.push(cand_dist, d)
    n = array.size(cand_idx)
    if n > 1
        for a = 0 to n - 2
            int min_i = a
            for b = a + 1 to n - 1
                if array.get(cand_dist, b) < array.get(cand_dist, min_i)
                    min_i := b
            if min_i != a
                da = array.get(cand_dist, a)
                ia = array.get(cand_idx, a)
                array.set(cand_dist, a, array.get(cand_dist, min_i))
                array.set(cand_idx, a, array.get(cand_idx, min_i))
                array.set(cand_dist, min_i, da)
                array.set(cand_idx, min_i, ia)
    while array.size(cand_idx) > active_max_zones
        array.pop(cand_idx)
    cand_idx

// Sort a side's parallel arrays by price DESCENDING (selection sort; n is tiny).
sort_side_desc(float[] prices, color[] cols, string[] lbls) =>
    n = array.size(prices)
    if n > 1
        for a = 0 to n - 2
            int max_idx = a
            for b = a + 1 to n - 1
                if array.get(prices, b) > array.get(prices, max_idx)
                    max_idx := b
            if max_idx != a
                pa = array.get(prices, a)
                ca = array.get(cols, a)
                la = array.get(lbls, a)
                array.set(prices, a, array.get(prices, max_idx))
                array.set(cols, a, array.get(cols, max_idx))
                array.set(lbls, a, array.get(lbls, max_idx))
                array.set(prices, max_idx, pa)
                array.set(cols, max_idx, ca)
                array.set(lbls, max_idx, la)

// === REGISTER PIVOTS ===
// Merge and eviction are EVENT-DRIVEN - they run only when a new zone was actually
// added, never on ordinary bars, so ATR spikes cannot decay the persistent pool.
bool added_res = false
bool added_sup = false

if not na(ph)
    added_res := add_zone(ph, RESISTANCE)

if not na(pl)
    added_sup := add_zone(pl, SUPPORT)

if added_res or added_sup
    merge_zones()
    evict_pool_overflow()

// === MTF (NON-REPAINTING) ===
// v9.11 FIX: the previous barstate.isconfirmed-keyed offset combined with lookahead_on
// let historical bars read the FINAL value of their own still-forming HTF bar - a
// lookahead repaint that made replay/backtest flips differ from live. The gate now
// always reads the LAST COMPLETED HTF bar ([1] offset + lookahead_on), which is the
// same value historically and live. The cost is up to one MTF bar of confirmation lag,
// which is the honest price of a deterministic gate.
// v9.10 rule retained: the gate is only active when the selected MTF is equal to or
// HIGHER than the chart timeframe; a lower MTF auto-bypasses.
string mtf_res = mtf_tf == "" ? timeframe.period : mtf_tf
bool mtf_valid = timeframe.in_seconds(mtf_res) >= timeframe.in_seconds(timeframe.period)
bool mtf_active = mtf_enabled and mtf_valid
mtf_close = request.security(syminfo.tickerid, mtf_res, close[1], lookahead=barmerge.lookahead_on)
mtf_high = request.security(syminfo.tickerid, mtf_res, high[1], lookahead=barmerge.lookahead_on)
mtf_low = request.security(syminfo.tickerid, mtf_res, low[1], lookahead=barmerge.lookahead_on)

// MTF is a CONFIRMATION GATE, not a replacement break price. The chart-TF confirmed
// break is the primary trigger, and the last completed HTF bar must agree in the SAME
// direction for the flip to commit. Stale HTF data can delay a flip but never
// wrong-direction it.
chart_break_above = break_mode == "Wick" ? high : close
chart_break_below = break_mode == "Wick" ? low : close
mtf_break_above = break_mode == "Wick" ? mtf_high : mtf_close
mtf_break_below = break_mode == "Wick" ? mtf_low : mtf_close

// === DYNAMIC FLIP STATE ===
// Runs on the FULL pool: a zone hidden while price was far away must still flip the
// moment price breaks through it (a break implies price is at the zone anyway).
// v9.11 FIXES in this block:
//   (a) Fresh-zone guard - a zone cannot flip on the bar it was created (the pivot
//       confirms pivot_right bars late, so price may already sit beyond the new zone;
//       flipping instantly announced a level that was never tested as its own type).
//   (b) Outside-bar tiebreak - in Wick mode a wide bar can clear BOTH sides; the flip
//       direction now resolves by the close relative to the zone midpoint instead of
//       silently defaulting to support.
//   (c) Throttle determinism - last_flip_sup/res update whenever the throttle passes,
//       independent of the marker lookback window. recent_window now gates ONLY the
//       cosmetic marker, so flip/throttle history no longer depends on when the chart
//       was loaded (last_bar_index moves; signal state must not follow it).
bool flip_to_support = false
bool flip_to_resistance = false
bool any_flip_committed = false
recent_window = bar_index >= last_bar_index - flip_label_bars

if barstate.isconfirmed and array.size(zone_mid) > 0
    for i = 0 to array.size(zone_mid) - 1
        ztop = array.get(zone_top, i)
        zbot = array.get(zone_bot, i)
        zmid = array.get(zone_mid, i)
        old_type = array.get(zone_type, i)
        bool zone_mature = bar_index - array.get(zone_bar, i) > pivot_right

        bool chart_sup = chart_break_above > ztop + confirm_buffer
        bool chart_res = chart_break_below < zbot - confirm_buffer
        bool mtf_conf_sup = not mtf_active or (not na(mtf_break_above) and mtf_break_above > ztop + confirm_buffer)
        bool mtf_conf_res = not mtf_active or (not na(mtf_break_below) and mtf_break_below < zbot - confirm_buffer)

        should_be_support = zone_mature and chart_sup and mtf_conf_sup
        should_be_resistance = zone_mature and chart_res and mtf_conf_res

        if should_be_support and should_be_resistance
            should_be_support := close >= zmid
            should_be_resistance := close < zmid

        if should_be_support and old_type != SUPPORT
            array.set(zone_type, i, SUPPORT)
            array.set(zone_flip_bar, i, bar_index)
            any_flip_committed := true

            if na(last_flip_sup) or bar_index - last_flip_sup >= min_bars_between
                last_flip_sup := bar_index
                if recent_window
                    flip_to_support := true

        else if should_be_resistance and old_type != RESISTANCE
            array.set(zone_type, i, RESISTANCE)
            array.set(zone_flip_bar, i, bar_index)
            any_flip_committed := true

            if na(last_flip_res) or bar_index - last_flip_res >= min_bars_between
                last_flip_res := bar_index
                if recent_window
                    flip_to_resistance := true

// Post-flip consolidation (v9.10): with type-aware dedup, an S and an R zone can
// legitimately coexist at the same price; when a break flips both to the same type they
// would otherwise sit overlapped forever. A flip is a discrete event, so running merge
// here stays within the pool-mutation standard. Runs AFTER the flip loop so array
// indices are never disturbed mid-iteration.
if any_flip_committed
    merge_zones()
    evict_pool_overflow()

// === EMA CLOUD ===
ema_fast = ta.ema(close, ema_fast_len)
ema_slow = ta.ema(close, ema_slow_len)

p1 = plot(ema_cloud_on ? ema_fast : na, title="EMA Fast (cloud edge)", display=display.none)
p2 = plot(ema_cloud_on ? ema_slow : na, title="EMA Slow (cloud edge)", display=display.none)
fill(p1, p2, color=ema_fast > ema_slow ? color.new(color.green, 60) : color.new(color.red, 60))

// === SHARED VISIBLE SET (computed once per last bar, used by boxes AND ladder) ===
int[] vis_render = array.new_int()
if barstate.islast
    vis_render := select_visible()

// === BOXES ===
// Drawn only on the last bar from the visible set: identical render behavior, but the
// underlying pool persists so zones reappear on pullbacks. Left edge clamped to stay
// inside TradingView's bar_index drawing range for long-lived zones.
if barstate.islast
    if array.size(zone_boxes) > 0
        for i = 0 to array.size(zone_boxes) - 1
            box.delete(array.get(zone_boxes, i))
    array.clear(zone_boxes)

    if array.size(vis_render) > 0
        for v = 0 to array.size(vis_render) - 1
            i = array.get(vis_render, v)
            ztype = array.get(zone_type, i)
            recent_flip = is_recent_flip(array.get(zone_flip_bar, i))

            zone_col = ztype == SUPPORT ? recent_flip ? col_flipped_sup : col_support : recent_flip ? col_flipped_res : col_resistance
            zone_txt = ztype == SUPPORT ? recent_flip ? "S Flipped" : "S" : recent_flip ? "R Flipped" : "R"

            left_clamped = math.max(array.get(zone_bar, i), bar_index - 9000)

            b = box.new(
                 left=left_clamped,
                 top=array.get(zone_top, i),
                 right=bar_index + 8,
                 bottom=array.get(zone_bot, i),
                 border_color=zone_col,
                 bgcolor=zone_col,
                 text=zone_txt,
                 text_color=color.white,
                 text_size=size.small,
                 text_halign=text.align_left,
                 text_valign=text.align_center)

            array.push(zone_boxes, b)

// === MARKERS ===
plotshape(flip_to_support, title="Flip to Support", location=location.belowbar, style=shape.triangleup, size=size.small, color=color.lime, text="Flip Up", textcolor=color.lime, display=display.pane)
plotshape(flip_to_resistance, title="Flip to Resistance", location=location.abovebar, style=shape.triangledown, size=size.small, color=color.orange, text="Flip Dn", textcolor=color.orange, display=display.pane)

// === LADDER TABLE ===
// v9.11: rows per side configurable; the table is recreated when position OR row count
// changes. Layout: header row 0, resistances rows 1..R (nearest at the bottom), NOW at
// row R+1, supports rows R+2..2R+1 (nearest at the top).
var table ladder = na
var string old_pos = ""
var int old_rows = -1

if show_ladder and barstate.islast
    if na(ladder) or old_pos != ladder_pos or old_rows != ladder_rows
        if not na(ladder)
            table.delete(ladder)
        ladder := table.new(ladder_position(), 3, ladder_rows * 2 + 2, border_width=1, border_color=color.new(color.gray, 60), frame_width=1, frame_color=color.new(color.gray, 50))
        old_pos := ladder_pos
        old_rows := ladder_rows

    txt = ladder_text_size()

    res_prices = array.new_float()
    res_cols = array.new_color()
    res_lbls = array.new_string()
    sup_prices = array.new_float()
    sup_cols = array.new_color()
    sup_lbls = array.new_string()

    if array.size(vis_render) > 0
        for v = 0 to array.size(vis_render) - 1
            i = array.get(vis_render, v)
            mid = array.get(zone_mid, i)
            typ = array.get(zone_type, i)
            recent = is_recent_flip(array.get(zone_flip_bar, i))

            c = typ == RESISTANCE ? recent ? color.new(color.red, 35) : color.new(color.red, 50) : recent ? color.new(color.green, 35) : color.new(color.green, 50)
            l = typ == RESISTANCE ? recent ? "R*" : "R" : recent ? "S*" : "S"

            if mid > close
                array.push(res_prices, mid)
                array.push(res_cols, c)
                array.push(res_lbls, l)
            else
                array.push(sup_prices, mid)
                array.push(sup_cols, c)
                array.push(sup_lbls, l)

    sort_side_desc(res_prices, res_cols, res_lbls)
    sort_side_desc(sup_prices, sup_cols, sup_lbls)

    table.cell(ladder, 0, 0, "Zone", text_color=color.white, bgcolor=color.new(color.gray, 20), text_size=txt)
    table.cell(ladder, 1, 0, "Price", text_color=color.white, bgcolor=color.new(color.gray, 20), text_size=txt)
    table.cell(ladder, 2, 0, "Dist", text_color=color.white, bgcolor=color.new(color.gray, 20), text_size=txt)

    rN = array.size(res_prices)
    for r = 0 to ladder_rows - 1
        row = r + 1
        src = rN - ladder_rows + r
        if src >= 0 and src < rN
            p = array.get(res_prices, src)
            c = array.get(res_cols, src)
            l = array.get(res_lbls, src)
            table.cell(ladder, 0, row, l, bgcolor=c, text_color=color.white, text_size=txt)
            table.cell(ladder, 1, row, fmt_price(p), bgcolor=c, text_color=color.white, text_size=txt)
            table.cell(ladder, 2, row, fmt_dist(p), bgcolor=c, text_color=color.white, text_size=txt)
        else
            table.cell(ladder, 0, row, "--", bgcolor=color.new(color.gray, 75), text_size=txt)
            table.cell(ladder, 1, row, "--", bgcolor=color.new(color.gray, 75), text_size=txt)
            table.cell(ladder, 2, row, "--", bgcolor=color.new(color.gray, 75), text_size=txt)

    int now_row = ladder_rows + 1
    table.cell(ladder, 0, now_row, "NOW", bgcolor=color.new(color.gray, 10), text_color=color.yellow, text_size=txt)
    table.cell(ladder, 1, now_row, fmt_price(close), bgcolor=color.new(color.gray, 10), text_color=color.yellow, text_size=txt)
    table.cell(ladder, 2, now_row, "--", bgcolor=color.new(color.gray, 10), text_color=color.yellow, text_size=txt)

    for s = 0 to ladder_rows - 1
        row = s + now_row + 1
        if s < array.size(sup_prices)
            p = array.get(sup_prices, s)
            c = array.get(sup_cols, s)
            l = array.get(sup_lbls, s)
            table.cell(ladder, 0, row, l, bgcolor=c, text_color=color.white, text_size=txt)
            table.cell(ladder, 1, row, fmt_price(p), bgcolor=c, text_color=color.white, text_size=txt)
            table.cell(ladder, 2, row, fmt_dist(p), bgcolor=c, text_color=color.white, text_size=txt)
        else
            table.cell(ladder, 0, row, "--", bgcolor=color.new(color.gray, 75), text_size=txt)
            table.cell(ladder, 1, row, "--", bgcolor=color.new(color.gray, 75), text_size=txt)
            table.cell(ladder, 2, row, "--", bgcolor=color.new(color.gray, 75), text_size=txt)

if not show_ladder and not na(ladder)
    table.delete(ladder)
    ladder := na
    old_pos := ""
    old_rows := -1

// === ALERTS ===
alertcondition(flip_to_support, "Zone Flipped to Support", "[SR Flip v9.11] Zone flipped to Support.")
alertcondition(flip_to_resistance, "Zone Flipped to Resistance", "[SR Flip v9.11] Zone flipped to Resistance.")
alertcondition(flip_to_support or flip_to_resistance, "Any Zone Flip", "[SR Flip v9.11] Zone flip occurred.")
````
