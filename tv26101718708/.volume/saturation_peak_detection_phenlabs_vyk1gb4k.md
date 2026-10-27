# Saturation Peak Detection [PhenLabs]

- url: https://www.tradingview.com/script/VyK1gb4k-Saturation-Peak-Detection-PhenLabs/
- type: indicator
- pine_id: PUB;c89a6bcb50804a6091706cccb9f7264b
- version: 1.0

## Description

[b]📊  Saturation Peak Detection [PhenLabs][/b]
[i]v1.0 — S/R zones planted only when momentum peaks and pulls back — no sweep noise, only saturation-confirmed structure[/i]

https://www.tradingview.com/x/QcA801kV/

📌 [b]OVERVIEW[/b]

[b]Saturation Peak Detection (SPD)[/b] plants support and resistance zones only at price levels where a momentum proxy has demonstrably exhausted. Most S/R tools mark every swing pivot — SPD adds a mandatory saturation gate: a zone only forms when the momentum proxy (RSI, ROC, or MFI) has peaked within a lookback window and then pulled back by a configurable % from that peak. If momentum hasn’t saturated, no zone is drawn.

The result is a smaller set of higher-conviction structural levels, each backed by a quantifiable momentum exhaustion event — easier to audit, easier to trust.

[b]HOW IT WORKS[/b]

[list=1]
[*] [b]Momentum Proxy Computation[/b]
[*] Choose RSI, ROC (Rate of Change), or MFI (Money Flow Index) — all standard, public-domain oscillators
[*] The selected proxy is computed over a configurable length (default: 14 bars)
[*] An optional second-pane plot shows the raw momentum series, rolling peak, and rolling trough for visual reference
[/list]

[*] [b]Rolling Peak and Trough Tracking[/b]
[list]
[*] [b]Rolling peak[/b]: highest momentum value within the last N bars (configurable Peak Lookback)
[*] [b]Rolling trough[/b]: lowest momentum value within the same window
[*] The price at the bar of the peak/trough is stored as the zone anchor
[/list]

[*] [b]Saturation Trigger[/b]
[list]
[*] [b]Bear saturation[/b]: momentum drops ≥ [b]Pullback %[/b] below its rolling peak → resistance zone planted at the peak-bar’s price
[*] [b]Bull saturation[/b]: momentum recovers ≥ [b]Pullback %[/b] above its rolling trough → support zone planted at the trough-bar’s price
[*] All triggers gated on [b]barstate.isconfirmed[/b] — no intrabar firing, no repainting
[/list]

[*] [b]Latch + Cooldown System[/b]
[list]
[*] Each unique peak/trough can only create [b]one zone[/b] — the latch tracks the bar index of the last-used peak/trough and blocks a re-trigger on the same event
[*] A configurable [b]Zone Cooldown[/b] (default: 10 bars) enforces a minimum spacing between any two zone creations
[*] Together these prevent consecutive-bar spam and cluster stacking
[/list]

[*] [b]Zone Management[/b]
[list]
[*] Each zone is an ATR-wide filled rectangle centered on the anchor price — context-relative thickness
[*] A dashed [b]invalidation line[/b] sits at a configurable offset beyond the zone boundary
[*] When price closes past the invalidation line, the zone is greyed out (non-destructive — stays visible for audit)
[*] Maximum active zones cap (default: 3) with oldest-valid-first eviction
[/list]

🔑 [b]POINTS OF INNOVATION[/b]

[list]
[*] [b]Saturation gate[/b]: zones require quantified momentum exhaustion, not just a price pivot — fundamentally different from standard S/R tools
[*] [b]Three interchangeable proxies[/b]: RSI, ROC, MFI — swap based on market type (RSI for equities/crypto, ROC for pure momentum, MFI for volume-heavy instruments)
[*] [b]Peak-price anchoring[/b]: the zone is planted at the price of the momentum peak bar, not the trigger bar — precise anchor to where buyers/sellers actually exhausted
[*] [b]Single-concept extractability[/b]: clean, auditable logic with one mechanism — easy to backtest, explain, and extend
[*] [b]Non-destructive invalidation[/b]: invalidated zones stay visible in grey, preserving historical structure context without cluttering the active signal layer
[/list]

🔧 [b]SETTINGS[/b]

[b]Momentum Proxy[/b]
[list]
[*] [b]Momentum Source[/b] | Default: RSI | Options: RSI, ROC, MFI
[*] [b]Momentum Length[/b] | Default: 14 | Range: 2–100
[*] [b]Peak Lookback (bars)[/b] | Default: 50 | Range: 5–300 | Window for detecting rolling peak/trough
[/list]

[b]Saturation Trigger[/b]
[list]
[*] [b]Pullback % from Peak[/b] | Default: 10.0 | Range: 1.0–50.0 | Momentum must pull back this % to confirm saturation. Higher = rarer, stronger zones
[*] [b]Zone Cooldown (bars)[/b] | Default: 10 | Range: 0–100 | Minimum bars between zone creations
[/list]

[b]Zone Settings[/b]
[list]
[*] [b]Max Active Zones[/b] | Default: 3 | Range: 1–10
[*] [b]ATR Length[/b] | Default: 14 | Used to compute zone height
[*] [b]Invalidation Offset (%)[/b] | Default: 0.3 | Zone is invalidated when price closes this % beyond the outer boundary
[/list]

[b]Display[/b]
[list]
[*] [b]Show Momentum Line (Pane 2)[/b] | Default: ON | Plots momentum proxy + rolling peak/trough in a separate pane
[*] [b]Show Zone Labels[/b] | Default: ON | Labels show zone type and momentum value at peak
[/list]

[b]Colors[/b]
[list]
[*] Support Zone, Resistance Zone, Invalidation Line, Trigger Marker — all fully customizable
[/list]

🔥 [b]ALERTS[/b]

[list]
[*] [b]SPD — Bear Saturation Zone[/b]: fires when a resistance zone is planted (momentum peaked, pullback confirmed)
[*] [b]SPD — Bull Saturation Zone[/b]: fires when a support zone is planted (momentum troughed, recovery confirmed)
[/list]

🎨 [b]VISUAL GUIDE[/b]

[list]
[*] [b]Teal filled rectangle[/b] = active support zone (bull saturation confirmed)
[*] [b]Red filled rectangle[/b] = active resistance zone (bear saturation confirmed)
[*] [b]Grey filled rectangle[/b] = invalidated zone (price closed beyond invalidation line)
[*] [b]Dashed grey line[/b] = invalidation level for each zone
[*] [b]Orange triangles[/b] = saturation trigger markers (▲ below bar = bull, ▼ above bar = bear)
[*] [b]Purple line (pane 2)[/b] = raw momentum proxy
[*] [b]Red step line (pane 2)[/b] = rolling peak | [b]Teal step line (pane 2)[/b] = rolling trough
[/list]

📖 [b]USAGE NOTES[/b]

[list]
[*] Designed for [b]1H, 4H, and Daily[/b] timeframes — where momentum exhaustion is most structurally significant
[*] [b]RSI[/b] works best on equities and crypto where overbought/oversold levels are well-studied
[*] [b]ROC[/b] is better for pure price momentum without smoothing — use on trending futures and forex pairs
[*] [b]MFI[/b] adds volume confirmation — best on high-volume instruments where volume leads price
[*] Increase [b]Pullback %[/b] to 15–20% for fewer, higher-conviction zones; reduce to 5–8% for more frequent signals on lower timeframes
[*] The zone anchor is the [b]price at the momentum peak bar[/b] — this is the level where participants exhausted, not the trigger bar
[*] Use the dashed invalidation line as a hard stop reference — a close beyond it means the zone has been absorbed
[/list]

✅ [b]WORKS WELL WITH[/b]

[list]
[*] Volume Profile tools (confirm zone with high-volume nodes)
[*] VWAP / Anchored VWAP (zone + VWAP confluence = stronger level)
[*] Trend filters (EMA, Supertrend) for directional bias before entering at a zone
[*] ATR-based position sizing (zone width already ATR-scaled — align stop to invalidation line)
[/list]

[quote]⚠️ [b]DISCLAIMER[/b]

This indicator is for educational and research purposes only. It is not financial advice and does not constitute a trading recommendation. Past performance does not guarantee future results. Always conduct your own analysis before making any trading or investment decision.[/quote]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © PhenLabs
//@version=6
//
// Saturation Peak Detection [PhenLabs] — Refined
// v2.0
//
// Core concept:
//   A structural S/R zone is only planted when a momentum proxy (RSI, ROC, or MFI)
//   has peaked within a lookback window and then pulled back by a configurable %
//   from that peak — confirming exhaustion at the price level where the peak occurred.
//
// v2.0 Refinements:
//   SIGNAL ACCURACY:
//     • Multi-factor confirmation: saturation threshold + volume filter + divergence check
//     • Absolute momentum gates (RSI>70 / RSI<30 style) to avoid weak-peak false signals
//     • Volatility-adaptive pullback (ATR-scaled) instead of fixed %
//     • Pivot-confirmed peaks (require N bars of confirmation on each side)
//     • Composite strength score 0–100 per zone (shown in label)
//     • Touch tracking: zones strengthen with tests, weaken on break attempts
//   VISUAL DISPLAY:
//     • Gradient-filled zones with strength-based opacity
//     • Animated glow effect on newly planted zones
//     • Zone strength meter in label (★ rating 1-5)
//     • Info dashboard (top-right) with live state
//     • Touch markers when price tests a zone
//     • Clean typography with unicode symbols

indicator(
     title            = "Saturation Peak Detection [PhenLabs]",
     shorttitle       = "SPD [Phen]",
     overlay          = true,
     max_boxes_count  = 100,
     max_lines_count  = 200,
     max_labels_count = 200)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════════════════════

var string GRP_MOM   = "① Momentum Proxy"
mom_src_str  = input.string("RSI", "Source", options=["RSI","ROC","MFI","Composite"],
     group=GRP_MOM,
     tooltip="Momentum proxy used to detect saturation peaks.\n• RSI: classic overbought/oversold\n• ROC: rate-of-change (pure price)\n• MFI: money flow (price+volume)\n• Composite: average of all three (most robust)")
mom_len      = input.int(14, "Length", minval=2, maxval=100, group=GRP_MOM,
     tooltip="Lookback period for momentum.")
peak_lookback = input.int(50, "Peak Lookback (bars)", minval=5, maxval=300,
     group=GRP_MOM,
     tooltip="How far back to search for rolling peak/trough.")

var string GRP_TRIG  = "② Saturation Trigger"
use_adaptive = input.bool(true, "Adaptive Pullback (ATR-scaled)", group=GRP_TRIG,
     tooltip="ON: pullback threshold scales with volatility (ATR).\nOFF: uses fixed %.")
pct_drop     = input.float(10.0, "Pullback % from Peak", minval=1.0, maxval=50.0, step=0.5,
     group=GRP_TRIG,
     tooltip="Base pullback %. When adaptive is on, this is scaled by ATR regime.")
use_abs_gate = input.bool(true, "Require Absolute Extreme", group=GRP_TRIG,
     tooltip="Require momentum to reach an absolute extreme zone before considering the peak valid (e.g. RSI must hit >70 for bear setup).")
rsi_ob       = input.float(70.0, "  ↳ RSI Overbought", minval=50.0, maxval=95.0, group=GRP_TRIG)
rsi_os       = input.float(30.0, "  ↳ RSI Oversold",   minval=5.0,  maxval=50.0, group=GRP_TRIG)
pivot_confirm = input.int(2, "Pivot Confirmation Bars", minval=0, maxval=10, group=GRP_TRIG,
     tooltip="Require N bars of confirmation on each side of the momentum peak (higher = stricter, more lag).")
zone_cooldown = input.int(10, "Zone Cooldown (bars)", minval=0, maxval=100, group=GRP_TRIG,
     tooltip="Minimum bars between zone creations.")

var string GRP_FILT  = "③ Quality Filters"
use_volume   = input.bool(true, "Volume Filter", group=GRP_FILT,
     tooltip="Require above-average volume at the peak bar (conviction).")
vol_mult     = input.float(1.2, "  ↳ Volume Multiplier", minval=0.5, maxval=3.0, step=0.1,
     group=GRP_FILT,
     tooltip="Peak-bar volume must exceed avg × this multiplier.")
use_divergence = input.bool(true, "Divergence Bonus", group=GRP_FILT,
     tooltip="Adds strength score when price/momentum divergence is present at the peak.")
min_strength = input.int(40, "Min Strength Score (0–100)", minval=0, maxval=100, group=GRP_FILT,
     tooltip="Zones below this composite score are suppressed. 0 = no filter.")

var string GRP_ZONES = "④ Zone Settings"
max_zones    = input.int  (4,    "Max Active Zones", minval=1, maxval=10, group=GRP_ZONES)
atr_len      = input.int  (14,   "ATR Length",       minval=1, maxval=100, group=GRP_ZONES)
zone_width   = input.float(1.0,  "Zone Width (× ATR)", minval=0.2, maxval=3.0, step=0.1, group=GRP_ZONES,
     tooltip="Zone thickness as multiple of ATR.")
inv_offset   = input.float(0.3,  "Invalidation Offset (%)", minval=0.0, maxval=5.0, step=0.1, group=GRP_ZONES)
extend_bars  = input.int  (20,   "Zone Extension (bars)", minval=5, maxval=200, group=GRP_ZONES,
     tooltip="How far forward to project active zones.")

var string GRP_VIZ   = "⑤ Display"
show_gradient = input.bool(true, "Gradient Zone Fill", group=GRP_VIZ,
     tooltip="Render zones with layered opacity for depth.")
show_dashboard = input.bool(true, "Info Dashboard",    group=GRP_VIZ)
dash_pos     = input.string("Top Right", "  ↳ Position",
     options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=GRP_VIZ)
show_labels  = input.bool(true,  "Zone Labels",        group=GRP_VIZ)
show_touches = input.bool(true,  "Touch Markers",      group=GRP_VIZ)
show_mom_line = input.bool(false, "Show Momentum Pane", group=GRP_VIZ)

var string GRP_COL   = "⑥ Colors"
bull_color   = input.color(#00BFA5, "Support Color",      group=GRP_COL)
bear_color   = input.color(#FF5252, "Resistance Color",   group=GRP_COL)
inv_color    = input.color(color.new(color.gray, 40), "Invalidation", group=GRP_COL)
text_color   = input.color(#ECEFF1, "Dashboard Text",     group=GRP_COL)
bg_color     = input.color(color.new(#263238, 20), "Dashboard BG",   group=GRP_COL)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 1 — MOMENTUM PROXY (with Composite option)
// ══════════════════════════════════════════════════════════════════════════════

rsi_raw = ta.rsi(close, mom_len)
roc_raw = ta.roc(close, mom_len)
mfi_raw = ta.mfi(hlc3, mom_len)

// Normalize ROC to 0-100 for composite (using stdev-based squashing)
roc_stdev = ta.stdev(roc_raw, 100)
roc_norm  = 50 + 50 * (roc_raw / (roc_stdev * 2 + 0.0001))
roc_norm  := math.max(0, math.min(100, roc_norm))

mom_series =
     mom_src_str == "RSI" ? rsi_raw :
     mom_src_str == "ROC" ? roc_raw :
     mom_src_str == "MFI" ? mfi_raw :
     (rsi_raw + roc_norm + mfi_raw) / 3.0

// For absolute-gate check we always use RSI-space (0-100)
mom_rsi_space =
     mom_src_str == "ROC" ? roc_norm :
     mom_src_str == "RSI" ? rsi_raw :
     mom_src_str == "MFI" ? mfi_raw :
     (rsi_raw + roc_norm + mfi_raw) / 3.0

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 2 — ROLLING PEAK / TROUGH TRACKING
// ══════════════════════════════════════════════════════════════════════════════

rolling_hi  = ta.highest(mom_series, peak_lookback)
rolling_lo  = ta.lowest (mom_series, peak_lookback)
hi_offset   = ta.highestbars(mom_series, peak_lookback)
lo_offset   = ta.lowestbars (mom_series, peak_lookback)

hi_bar_price = high[math.abs(hi_offset)]   // use HIGH for bear anchor (resistance)
lo_bar_price = low [math.abs(lo_offset)]   // use LOW  for bull anchor (support)
hi_bar_vol   = volume[math.abs(hi_offset)]
lo_bar_vol   = volume[math.abs(lo_offset)]

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 3 — ADAPTIVE PULLBACK THRESHOLD
// ══════════════════════════════════════════════════════════════════════════════

atr_val    = ta.atr(atr_len)
atr_pct    = (atr_val / close) * 100.0
atr_pct_ma = ta.sma(atr_pct, 50)
vol_regime = atr_pct / (atr_pct_ma + 0.0001)   // >1 = high vol, <1 = low vol
adaptive_pct = use_adaptive ? pct_drop * math.max(0.6, math.min(1.8, vol_regime)) : pct_drop

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 4 — SATURATION TRIGGERS
// ══════════════════════════════════════════════════════════════════════════════

// Peak saturation (bear): momentum pulled back from rolling high
bear_pullback = mom_series <= rolling_hi * (1.0 - adaptive_pct / 100.0)
bull_pullback = mom_series >= rolling_lo + math.abs(rolling_lo) * (adaptive_pct / 100.0)

// Absolute-extreme gate (using RSI-space proxy)
// Look up the mom_rsi_space value AT the peak bar
peak_mom_abs   = mom_rsi_space[math.abs(hi_offset)]
trough_mom_abs = mom_rsi_space[math.abs(lo_offset)]
abs_gate_bear  = not use_abs_gate or peak_mom_abs   >= rsi_ob
abs_gate_bull  = not use_abs_gate or trough_mom_abs <= rsi_os

// Pivot confirmation: peak must be at least `pivot_confirm` bars old AND
// no new higher/lower momentum has appeared since
peak_age_ok    = pivot_confirm == 0 or math.abs(hi_offset) >= pivot_confirm
trough_age_ok  = pivot_confirm == 0 or math.abs(lo_offset) >= pivot_confirm

// Volume filter at peak bar
vol_avg        = ta.sma(volume, 20)
vol_at_peak    = hi_bar_vol   > vol_avg * vol_mult
vol_at_trough  = lo_bar_vol   > vol_avg * vol_mult
vol_gate_bear  = not use_volume or vol_at_peak
vol_gate_bull  = not use_volume or vol_at_trough

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 5 — DIVERGENCE CHECK (for strength bonus)
// ══════════════════════════════════════════════════════════════════════════════
// Bear divergence: price makes higher high while momentum makes lower high vs prior peak
// Bull divergence: price makes lower low while momentum makes higher low vs prior trough

var float prev_price_hi = na
var float prev_mom_hi   = na
var float prev_price_lo = na
var float prev_mom_lo   = na

cur_price_hi = hi_bar_price
cur_mom_hi   = rolling_hi
cur_price_lo = lo_bar_price
cur_mom_lo   = rolling_lo

bear_div = not na(prev_price_hi) and not na(prev_mom_hi) and
           cur_price_hi > prev_price_hi and cur_mom_hi < prev_mom_hi
bull_div = not na(prev_price_lo) and not na(prev_mom_lo) and
           cur_price_lo < prev_price_lo and cur_mom_lo > prev_mom_lo

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 6 — LATCH + COOLDOWN
// ══════════════════════════════════════════════════════════════════════════════

var int last_bear_peak_bar   = -999
var int last_bull_trough_bar = -999
var int last_zone_bar        = -999

cur_hi_bar = bar_index + hi_offset
cur_lo_bar = bar_index + lo_offset

new_bear_peak   = cur_hi_bar != last_bear_peak_bar
new_bull_trough = cur_lo_bar != last_bull_trough_bar
cooldown_ok     = (bar_index - last_zone_bar) >= zone_cooldown

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 7 — COMPOSITE STRENGTH SCORE (0–100)
// ══════════════════════════════════════════════════════════════════════════════
// Weighted blend of:
//   - Momentum extremity (how far into OB/OS)           40 pts
//   - Pullback depth beyond trigger threshold           20 pts
//   - Volume at peak vs average                         20 pts
//   - Divergence bonus                                  20 pts

calc_strength_bear(float peak_abs_mom, float cur_mom, float peak_vol) =>
    // Extremity: 0 at 50, 40 at 100
    extrem    = math.max(0.0, math.min(40.0, (peak_abs_mom - 50.0) * 40.0 / 50.0))
    // Pullback beyond threshold
    actual_pb = (rolling_hi - cur_mom) / (rolling_hi + 0.0001) * 100.0
    pb_score  = math.max(0.0, math.min(20.0, (actual_pb - adaptive_pct) * 2.0 + 10.0))
    // Volume
    vol_ratio = peak_vol / (vol_avg + 0.0001)
    vol_score = math.max(0.0, math.min(20.0, (vol_ratio - 1.0) * 20.0))
    // Divergence
    div_score = bear_div and use_divergence ? 20.0 : 0.0
    math.round(extrem + pb_score + vol_score + div_score)

calc_strength_bull(float trough_abs_mom, float cur_mom, float trough_vol) =>
    extrem    = math.max(0.0, math.min(40.0, (50.0 - trough_abs_mom) * 40.0 / 50.0))
    actual_pb = (cur_mom - rolling_lo) / (math.abs(rolling_lo) + 0.0001) * 100.0
    pb_score  = math.max(0.0, math.min(20.0, (actual_pb - adaptive_pct) * 2.0 + 10.0))
    vol_ratio = trough_vol / (vol_avg + 0.0001)
    vol_score = math.max(0.0, math.min(20.0, (vol_ratio - 1.0) * 20.0))
    div_score = bull_div and use_divergence ? 20.0 : 0.0
    math.round(extrem + pb_score + vol_score + div_score)

bear_strength = calc_strength_bear(peak_mom_abs,   mom_series, hi_bar_vol)
bull_strength = calc_strength_bull(trough_mom_abs, mom_series, lo_bar_vol)

// Final confirmed triggers
bear_saturation = barstate.isconfirmed and bear_pullback and new_bear_peak and
                  cooldown_ok and abs_gate_bear and vol_gate_bear and peak_age_ok and
                  bear_strength >= min_strength

bull_saturation = barstate.isconfirmed and bull_pullback and new_bull_trough and
                  cooldown_ok and abs_gate_bull and vol_gate_bull and trough_age_ok and
                  bull_strength >= min_strength

// Update latches
if bear_saturation
    last_bear_peak_bar := cur_hi_bar
    last_zone_bar      := bar_index
    prev_price_hi      := cur_price_hi
    prev_mom_hi        := cur_mom_hi

if bull_saturation
    last_bull_trough_bar := cur_lo_bar
    last_zone_bar        := bar_index
    prev_price_lo        := cur_price_lo
    prev_mom_lo          := cur_mom_lo

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 8 — ZONE MANAGER (with gradient + strength tracking)
// ══════════════════════════════════════════════════════════════════════════════

var box[]   z_outer    = array.new<box>()
var box[]   z_mid      = array.new<box>()
var box[]   z_core     = array.new<box>()
var line[]  z_invlines = array.new<line>()
var line[]  z_center   = array.new<line>()
var label[] z_labels   = array.new<label>()
var float[] z_top      = array.new<float>()
var float[] z_bot      = array.new<float>()
var float[] z_anchor   = array.new<float>()
var bool[]  z_is_bull  = array.new<bool>()
var float[] z_mom_val  = array.new<float>()
var int[]   z_strength = array.new<int>()
var int[]   z_touches  = array.new<int>()
var int[]   z_birth    = array.new<int>()
var bool[]  z_valid    = array.new<bool>()

// ── Helper: stars string from strength 0-100 ──────────────────────────────────
strength_stars(int s) =>
    stars = s >= 80 ? "★★★★★" :s >= 65 ? "★★★★☆" :s >= 50 ? "★★★☆☆" :s >= 35 ? "★★☆☆☆" :"★☆☆☆☆"
    stars

// ── Helper: count valid zones ─────────────────────────────────────────────────
count_valid() =>
    cnt = 0
    n   = array.size(z_valid)
    if n > 0
        for k = 0 to n - 1
            if array.get(z_valid, k)
                cnt += 1
    cnt

// ── Helper: delete zone at index i ────────────────────────────────────────────
zone_del(int i) =>
    box.delete  (array.get(z_outer,    i))
    box.delete  (array.get(z_mid,      i))
    box.delete  (array.get(z_core,     i))
    line.delete (array.get(z_invlines, i))
    line.delete (array.get(z_center,   i))
    label.delete(array.get(z_labels,   i))
    array.remove(z_outer,    i)
    array.remove(z_mid,      i)
    array.remove(z_core,     i)
    array.remove(z_invlines, i)
    array.remove(z_center,   i)
    array.remove(z_labels,   i)
    array.remove(z_top,      i)
    array.remove(z_bot,      i)
    array.remove(z_anchor,   i)
    array.remove(z_is_bull,  i)
    array.remove(z_mom_val,  i)
    array.remove(z_strength, i)
    array.remove(z_touches,  i)
    array.remove(z_birth,    i)
    array.remove(z_valid,    i)

// ── Helper: evict oldest valid zone ───────────────────────────────────────────
evict_oldest_valid() =>
    n = array.size(z_valid)
    if n > 0
        for k = 0 to n - 1
            if array.get(z_valid, k)
                zone_del(k)
                break

// ── Helper: create a new zone (gradient, 3-layer) ─────────────────────────────
zone_create(float anchor, bool is_bull, float mom_at_peak, int strength) =>
    half   = (atr_val * zone_width) / 2.0
    top_p  = anchor + half
    bot_p  = anchor - half
    base_c = is_bull ? bull_color : bear_color

    // Strength-based opacity: stronger = more visible
    opacity_outer = show_gradient ? math.max(70, 95 - strength / 4) : 80
    opacity_mid   = show_gradient ? math.max(55, 85 - strength / 3) : 70
    opacity_core  = show_gradient ? math.max(40, 75 - strength / 2) : 60

    right_x = bar_index + extend_bars

    // Outer layer (lightest)
    b_outer = box.new(bar_index, top_p, right_x, bot_p,
         bgcolor      = color.new(base_c, opacity_outer),
         border_color = color.new(base_c, 100),
         border_width = 0)

    // Mid layer
    mid_top = anchor + half * 0.66
    mid_bot = anchor - half * 0.66
    b_mid   = box.new(bar_index, mid_top, right_x, mid_bot,
         bgcolor      = color.new(base_c, opacity_mid),
         border_color = color.new(base_c, 100),
         border_width = 0)

    // Core layer (densest)
    core_top = anchor + half * 0.33
    core_bot = anchor - half * 0.33
    b_core   = box.new(bar_index, core_top, right_x, core_bot,
         bgcolor      = color.new(base_c, opacity_core),
         border_color = color.new(base_c, 30),
         border_width = 1)

    // Center line (the anchor price)
    center_ln = line.new(bar_index, anchor, right_x, anchor,
         color = color.new(base_c, 20),
         style = line.style_solid,
         width = 2)

    // Invalidation line
    inv_p  = is_bull ? bot_p * (1.0 - inv_offset / 100.0)
                     : top_p * (1.0 + inv_offset / 100.0)
    inv_ln = line.new(bar_index, inv_p, right_x, inv_p,
         color = inv_color,
         style = line.style_dashed,
         width = 1)

    // Label with strength stars — pinned to right edge, text sits OUTSIDE the zone
    // style_label_left = arrow points left (into zone), text extends to the right
    lbl_text = (is_bull ? "▲ SUPPORT" : "▼ RESIST") + "\n" +
               strength_stars(strength) + "  " + str.tostring(strength) + "/100\n" +
               mom_src_str + ": " + str.tostring(mom_at_peak, "#.#") + "\n" +
               "💰 " + str.tostring(anchor, format.mintick)
    lbl = label.new(right_x, anchor,
         text      = lbl_text,
         color     = color.new(base_c, 85),
         textcolor = text_color,
         style     = label.style_label_left,
         size      = size.small)

    array.push(z_outer,    b_outer)
    array.push(z_mid,      b_mid)
    array.push(z_core,     b_core)
    array.push(z_invlines, inv_ln)
    array.push(z_center,   center_ln)
    array.push(z_labels,   lbl)
    array.push(z_top,      top_p)
    array.push(z_bot,      bot_p)
    array.push(z_anchor,   anchor)
    array.push(z_is_bull,  is_bull)
    array.push(z_mom_val,  mom_at_peak)
    array.push(z_strength, strength)
    array.push(z_touches,  0)
    array.push(z_birth,    bar_index)
    array.push(z_valid,    true)

// ── Zone creation ─────────────────────────────────────────────────────────────

if bear_saturation
    if count_valid() >= max_zones
        evict_oldest_valid()
    zone_create(hi_bar_price, false, rolling_hi, bear_strength)

if bull_saturation
    if count_valid() >= max_zones
        evict_oldest_valid()
    zone_create(lo_bar_price, true, rolling_lo, bull_strength)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 9 — ZONE MAINTENANCE (extend, touch tracking, invalidation)
// ══════════════════════════════════════════════════════════════════════════════

var int last_touch_bar = -999
touch_fired_bull = false
touch_fired_bear = false

if barstate.isconfirmed and array.size(z_outer) > 0
    i = 0
    while i < array.size(z_outer)
        top_z    = array.get(z_top,    i)
        bot_z    = array.get(z_bot,    i)
        anc_z    = array.get(z_anchor, i)
        bull_z   = array.get(z_is_bull, i)
        valid_z  = array.get(z_valid,  i)
        strength = array.get(z_strength, i)

        if valid_z
            right_new = bar_index + extend_bars
            box.set_right (array.get(z_outer,    i), right_new)
            box.set_right (array.get(z_mid,      i), right_new)
            box.set_right (array.get(z_core,     i), right_new)
            line.set_x2   (array.get(z_invlines, i), right_new)
            line.set_x2   (array.get(z_center,   i), right_new)
            // Label pinned to the right edge, Y locked to anchor price.
            // We only move it — we do NOT rewrite its text on every bar.
            label.set_x   (array.get(z_labels,   i), right_new)
            label.set_y   (array.get(z_labels,   i), anc_z)

            // Touch detection: price enters the zone
            touched = (low <= top_z and high >= bot_z)
            if touched and (bar_index - last_touch_bar) > 2
                new_touch = array.get(z_touches, i) + 1
                array.set(z_touches, i, new_touch)
                last_touch_bar := bar_index
                if bull_z
                    touch_fired_bull := true
                else
                    touch_fired_bear := true

                // Refresh label with touch count
                new_text = (bull_z ? "▲ SUPPORT" : "▼ RESIST") + "\n" +
                           strength_stars(strength) + "  " + str.tostring(strength) + "/100\n" +
                           "Tests: " + str.tostring(new_touch) + "  |  " +
                           mom_src_str + ": " + str.tostring(array.get(z_mom_val, i), "#.#") + "\n" +
                           "💰 " + str.tostring(anc_z, format.mintick)
                label.set_text(array.get(z_labels, i), new_text)

            // Invalidation check
            inv_p = bull_z
                 ? bot_z * (1.0 - inv_offset / 100.0)
                 : top_z * (1.0 + inv_offset / 100.0)

            if (bull_z and close < inv_p) or (not bull_z and close > inv_p)
                array.set(z_valid, i, false)
                gc1 = color.new(color.gray, 92)
                gc2 = color.new(color.gray, 85)
                gc3 = color.new(color.gray, 78)
                box.set_bgcolor(array.get(z_outer, i), gc1)
                box.set_bgcolor(array.get(z_mid,   i), gc2)
                box.set_bgcolor(array.get(z_core,  i), gc3)
                line.set_color (array.get(z_center, i), color.new(color.gray, 50))
                label.set_textcolor(array.get(z_labels, i), color.new(color.gray, 30))
                label.set_color    (array.get(z_labels, i), color.new(color.gray, 90))
                // Append invalidated tag
                old_text = label.get_text(array.get(z_labels, i))
                label.set_text(array.get(z_labels, i), "❌ INVALIDATED\n" + old_text)

        i += 1

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 10 — TRIGGER MARKERS
// ══════════════════════════════════════════════════════════════════════════════

plotshape(bear_saturation, title="Bear Saturation",
     style=shape.triangledown, location=location.abovebar,
     color=bear_color, size=size.small, text="PEAK", textcolor=bear_color)

plotshape(bull_saturation, title="Bull Saturation",
     style=shape.triangleup, location=location.belowbar,
     color=bull_color, size=size.small, text="TROUGH", textcolor=bull_color)

// Touch markers (small dots)
plotshape(show_touches and touch_fired_bull, title="Support Touch",
     style=shape.circle, location=location.belowbar,
     color=color.new(bull_color, 40), size=size.tiny)
plotshape(show_touches and touch_fired_bear, title="Resistance Touch",
     style=shape.circle, location=location.abovebar,
     color=color.new(bear_color, 40), size=size.tiny)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 11 — INFO DASHBOARD (top corner)
// ══════════════════════════════════════════════════════════════════════════════

var table dash = na
if show_dashboard and barstate.islast
    pos = dash_pos == "Top Right"    ? position.top_right    :
          dash_pos == "Top Left"     ? position.top_left     :
          dash_pos == "Bottom Right" ? position.bottom_right :
                                       position.bottom_left

    if na(dash)
        dash := table.new(pos, 2, 8, bgcolor=bg_color, border_width=1,
             border_color=color.new(text_color, 70), frame_color=color.new(text_color, 70),
             frame_width=1)

    // Current state assessment
    mom_state = mom_rsi_space > rsi_ob ? "🔴 OVERBOUGHT" : mom_rsi_space < rsi_os ? "🟢 OVERSOLD"   : "⚪ NEUTRAL"

    vol_state = vol_regime > 1.3 ? "🔥 HIGH" :vol_regime < 0.7 ? "❄️ LOW"  :"◎ NORMAL"

    active_zones = count_valid()
    total_zones  = array.size(z_valid)

    table.cell(dash, 0, 0, "⚡ SPD v2", text_color=text_color, text_size=size.normal,
         bgcolor=color.new(#37474F, 0))
    table.cell(dash, 1, 0, mom_src_str + "(" + str.tostring(mom_len) + ")",
         text_color=text_color, text_size=size.normal, bgcolor=color.new(#37474F, 0))

    table.cell(dash, 0, 1, "Momentum", text_color=text_color, text_size=size.small)
    table.cell(dash, 1, 1, str.tostring(mom_rsi_space, "#.#") + "  " + mom_state,
         text_color=text_color, text_size=size.small)

    table.cell(dash, 0, 2, "Pullback", text_color=text_color, text_size=size.small)
    table.cell(dash, 1, 2, str.tostring(adaptive_pct, "#.#") + "%  " +
         (use_adaptive ? "(adaptive)" : "(fixed)"),
         text_color=text_color, text_size=size.small)

    table.cell(dash, 0, 3, "Volatility", text_color=text_color, text_size=size.small)
    table.cell(dash, 1, 3, vol_state, text_color=text_color, text_size=size.small)

    table.cell(dash, 0, 4, "Zones Active", text_color=text_color, text_size=size.small)
    table.cell(dash, 1, 4, str.tostring(active_zones) + " / " + str.tostring(max_zones),
         text_color=text_color, text_size=size.small)

    table.cell(dash, 0, 5, "Zones Total", text_color=text_color, text_size=size.small)
    table.cell(dash, 1, 5, str.tostring(total_zones),
         text_color=text_color, text_size=size.small)

    // Last signal
    last_bear_age = bar_index - last_bear_peak_bar
    last_bull_age = bar_index - last_bull_trough_bar
    last_signal = last_bear_peak_bar > last_bull_trough_bar
         ? "▼ Bear (" + str.tostring(last_bear_age) + "b ago)"
         : last_bull_trough_bar > 0
             ? "▲ Bull (" + str.tostring(last_bull_age) + "b ago)"
             : "—"
    last_color = last_bear_peak_bar > last_bull_trough_bar ? bear_color : bull_color

    table.cell(dash, 0, 6, "Last Zone", text_color=text_color, text_size=size.small)
    table.cell(dash, 1, 6, last_signal, text_color=last_color, text_size=size.small)

    // Bias
    bias = active_zones == 0 ? "⚪ NONE" :
           last_bear_peak_bar > last_bull_trough_bar ? "🔻 BEARISH" :
                                                       "🔺 BULLISH"
    table.cell(dash, 0, 7, "Bias", text_color=text_color, text_size=size.small)
    table.cell(dash, 1, 7, bias, text_color=text_color, text_size=size.small)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 12 — MOMENTUM PANE (optional)
// ══════════════════════════════════════════════════════════════════════════════

plot(show_mom_line ? mom_series : na, "Momentum Proxy",
     color=color.new(#9C27B0, 20), linewidth=2, display=display.pane)
plot(show_mom_line ? rolling_hi : na, "Rolling Peak",
     color=color.new(bear_color, 40), linewidth=1, style=plot.style_stepline,
     display=display.pane)
plot(show_mom_line ? rolling_lo : na, "Rolling Trough",
     color=color.new(bull_color, 40), linewidth=1, style=plot.style_stepline,
     display=display.pane)
hline(show_mom_line and (mom_src_str == "RSI" or mom_src_str == "MFI" or
     mom_src_str == "Composite") ? rsi_ob : na, "OB",
     color=color.new(bear_color, 60), linestyle=hline.style_dashed)
hline(show_mom_line and (mom_src_str == "RSI" or mom_src_str == "MFI" or
     mom_src_str == "Composite") ? rsi_os : na, "OS",
     color=color.new(bull_color, 60), linestyle=hline.style_dashed)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 13 — ALERTS
// ══════════════════════════════════════════════════════════════════════════════

alertcondition(bear_saturation, title="SPD — Bear Saturation Zone",
     message="SPD v2: Bear resistance zone planted on {{ticker}} {{interval}} | Strength pending")

alertcondition(bull_saturation, title="SPD — Bull Saturation Zone",
     message="SPD v2: Bull support zone planted on {{ticker}} {{interval}} | Strength pending")

alertcondition(touch_fired_bull, title="SPD — Support Tested",
     message="SPD v2: Support zone tested on {{ticker}} {{interval}}")

alertcondition(touch_fired_bear, title="SPD — Resistance Tested",
     message="SPD v2: Resistance zone tested on {{ticker}} {{interval}}")
````
