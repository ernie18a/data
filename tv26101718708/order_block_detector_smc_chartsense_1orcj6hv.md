# Order Block Detector [SMC ChartSense]

- url: https://www.tradingview.com/script/1ORCJ6hv-Order-Block-Detector-SMC-ChartSense/
- type: indicator
- pine_id: PUB;896ebe1b02e14345a2d4ae321ad371f0
- version: 2.0

## Description

# SMC ChartSense — Order Block Detector

**Order block detection with mandatory FVG (Fair Value Gap) confirmation.** Each zone marked must have a 3-bar FVG at the anchor candle — institutional displacement that left a literal gap in price. Most basic OB scripts flag every breakout candle as an order block; this script filters to only the zones that came with displacement footprint, producing a cleaner chart with fewer but more meaningful zones.

## How it works

The script tracks swing pivots at a configurable length and waits for a confirmed break — a candle that closes beyond the prior swing high or low. When a break occurs, it searches back through the recent bars to identify the deepest counter-direction candle (lowest low for a bullish OB, highest high for a bearish OB). This becomes the OB anchor.

The anchor is then validated against the FVG requirement: there must be a 3-bar gap at the anchor index (bar A high below bar C low for bullish, bar A low above bar C high for bearish). No FVG, no OB. This is the central quality filter.

Validated zones extend forward from the anchor and remain active until invalidated — either when price closes through the zone or when the wick touches the far side, depending on user preference.

## Features

- FVG validation gate at the anchor candle (3-bar gap requirement)
- Configurable swing pivot length for structural sensitivity
- User-tunable OB anchor lookback (5–100 bars)
- Wick-based or body-based zone definition
- Configurable mitigation trigger: Close-through or Wick-touch
- Auto-pruning of oldest OBs when active count exceeds limit
- Optional faded display of mitigated zones for historical study
- Built on Pine v6 with clean, maintainable architecture

## Inputs

**Structure Detection**
- *Swing Pivot Length* — Higher values produce fewer, more significant pivots. Lower values produce more frequent pivots of smaller structural significance. Default: 5.

**Quality Filters**
- *OB Anchor Lookback Bars* — How far back from a confirmed pivot break to search for the OB anchor candle. Default 30 covers most timeframes; reduce for scalping, increase for higher TFs.
- *Anchor OB to Wick (vs Body)* — Wick mode uses the full candle range. Body mode uses open/close only (tighter zones).
- *Mitigation Trigger* — Close mode invalidates when a candle closes through the zone. Wick mode invalidates on first wick touch.

**Visualization**
- Bull/Bear OB colors (customizable)
- Max OBs Per Side (caps active display, oldest auto-pruned)
- Show OB Labels (off by default — boxes alone are usually sufficient)
- Show Midline (50% level inside each OB, dotted)
- Keep Mitigated OBs Visible (faded gray boxes remain for historical reference)

## Built-in alerts

- New Bull OB formed
- New Bear OB formed
- Bull OB touched (price entered zone)
- Bear OB touched (price entered zone)

## Suggested use

Best on liquid intraday markets — major forex pairs, crypto perps, index futures, large-cap equities — at timeframes from 5m to 4h. Default settings are tuned for 15m–1h ranges; adjust Swing Pivot Length down to 3 for scalping or up to 8–10 for higher-TF trend trading.

Use this as a context tool. The zones identify where institutional displacement occurred — actual entries should incorporate your own analysis: HTF bias, structural alignment with current market regime, risk-reward planning, and confirmation from other tools.

## Part of the SMC ChartSense suite

One of several focused SMC tools. Designed to work alongside other SMC ChartSense scripts for a coherent analytical workflow across the SMC vocabulary.

## Disclaimer

This is a technical analysis tool. It does not provide investment advice or trade recommendations. The author is not a SEBI-registered Research Analyst. Use at your own risk; do your own due diligence.

## Source Code

````pine
//@version=6
// =============================================================================
// SMC ChartSense — Order Block Detector
// =============================================================================
//
// FVG-validated order block detection. Marks bullish demand zones and bearish
// supply zones only when displacement (3-bar FVG) confirms the breakout
// structure — filtering out the noise produced by indicators that flag every
// breakout candle as an OB.
//
// Most public OB indicators mark every pivot break as an OB, producing dozens
// of low-quality zones cluttering charts. This script requires FVG confirmation
// at the anchor candle, filtering to only OBs that formed with institutional
// displacement footprint.
//
// Features:
//   - FVG-validated detection (only zones with displacement)
//   - Configurable anchor lookback (tune for timeframe)
//   - Wick or body-based zone definition
//   - Choice of mitigation trigger (Close vs Wick)
//   - Optional historical visibility for invalidated zones
//   - Max zone limit to prevent chart clutter
//   - Configurable OB box transparency for visual preference
//   - Built-in alerts for OB formation and touch events
//
// DISCLAIMER: This is a technical analysis tool. It does not provide
// investment advice or trade recommendations. The author is not a SEBI-
// registered Research Analyst. Use at your own risk; do your own due
// diligence.
// =============================================================================

indicator("SMC ChartSense — Order Block Detector", overlay=true,
     max_boxes_count  = 500,
     max_lines_count  = 500,
     max_labels_count = 500)

// =============================================================================
// 1. INPUTS
// =============================================================================

grp_struc = "Structure Detection"
sw_len    = input.int(5, "Swing Pivot Length", minval=1, maxval=50, group=grp_struc,
     tooltip="Higher = more significant pivots, fewer OBs. Lower = more frequent OBs of smaller structural significance.")

grp_quality = "Quality Filters"
ob_lookback = input.int(30, "OB Anchor Lookback Bars", minval=5, maxval=100, group=grp_quality,
     tooltip="How far back from a confirmed pivot break to search for the OB anchor candle.")
use_wick    = input.bool(true, "Anchor OB to Wick (vs Body)?", group=grp_quality)
mit_mode    = input.string("Close", "Mitigation Trigger", options=["Close", "Wick"], group=grp_quality,
     tooltip="Close = OB invalidated when candle closes through it. Wick = invalidated when wick touches the far side.")

grp_visual = "Visualization"
bull_color = input.color(color.green, "Bull OB Color", group=grp_visual)
bear_color = input.color(color.red,   "Bear OB Color", group=grp_visual)
ob_opacity = input.int(80, "OB Box Transparency", minval=50, maxval=95, group=grp_visual,
     tooltip="Higher = more transparent. Default 80. Try 60-70 for stronger visual presence.")
max_obs    = input.int(10, "Max OBs Per Side", minval=1, maxval=50, group=grp_visual,
     tooltip="Caps active OBs displayed. Oldest are pruned automatically.")
show_label = input.bool(false, "Show OB Labels?",                     group=grp_visual)
show_mid   = input.bool(true,  "Show Midline?",                        group=grp_visual)
show_mit   = input.bool(false, "Keep Mitigated OBs Visible (Faded)?",  group=grp_visual)

// =============================================================================
// 2. ORDER BLOCK TYPE
// =============================================================================

type ob_obj
    float top
    float bot
    float mid
    int   idx
    bool  active
    bool  touched
    box   d
    line  l
    label lbl

var array<ob_obj> bull_obs = array.new<ob_obj>()
var array<ob_obj> bear_obs = array.new<ob_obj>()

// =============================================================================
// 3. DETECTION LOGIC
// =============================================================================

detect_ob(float _ph, float _pl, int _len, bool _is_bull) =>
    if _is_bull
        var float s_high = na
        if not na(_ph)
            s_high := high[_len]

        if not na(s_high) and close > s_high and close[1] <= s_high
            float low_pt  = low
            int   low_idx = bar_index
            int   arr_idx = 0
            for i = 1 to ob_lookback
                if low[i] < low_pt
                    low_pt  := low[i]
                    low_idx := bar_index[i]
                    arr_idx := i

            bool  has_fvg  = false
            float zone_top = high[arr_idx]
            if arr_idx >= 2
                if low[arr_idx - 2] > high[arr_idx]
                    has_fvg := true
                    if not use_wick
                        zone_top := math.max(open[arr_idx], close[arr_idx])

            if has_fvg
                float mid_price = (zone_top + low_pt) / 2

                box ob_box = box.new(low_idx, zone_top, bar_index + 10, low_pt,
                     border_color = bull_color,
                     bgcolor      = color.new(bull_color, ob_opacity),
                     extend       = extend.right)

                line ob_line = na
                if show_mid
                    ob_line := line.new(low_idx, mid_price, bar_index + 10, mid_price,
                         color  = color.new(bull_color, 50),
                         style  = line.style_dotted,
                         extend = extend.right)

                label ob_label = na
                if show_label
                    ob_label := label.new(low_idx, zone_top, "Bull OB",
                         style     = label.style_label_down,
                         color     = color.new(bull_color, 30),
                         textcolor = color.white,
                         size      = size.small)

                ob_obj new_ob = ob_obj.new(zone_top, low_pt, mid_price, low_idx, true, false, ob_box, ob_line, ob_label)
                array.unshift(bull_obs, new_ob)
    else
        var float s_low = na
        if not na(_pl)
            s_low := low[_len]

        if not na(s_low) and close < s_low and close[1] >= s_low
            float high_pt  = high
            int   high_idx = bar_index
            int   arr_idx  = 0
            for i = 1 to ob_lookback
                if high[i] > high_pt
                    high_pt  := high[i]
                    high_idx := bar_index[i]
                    arr_idx  := i

            bool  has_fvg  = false
            float zone_bot = low[arr_idx]
            if arr_idx >= 2
                if high[arr_idx - 2] < low[arr_idx]
                    has_fvg := true
                    if not use_wick
                        zone_bot := math.min(open[arr_idx], close[arr_idx])

            if has_fvg
                float mid_price = (high_pt + zone_bot) / 2

                box ob_box = box.new(high_idx, high_pt, bar_index + 10, zone_bot,
                     border_color = bear_color,
                     bgcolor      = color.new(bear_color, ob_opacity),
                     extend       = extend.right)

                line ob_line = na
                if show_mid
                    ob_line := line.new(high_idx, mid_price, bar_index + 10, mid_price,
                         color  = color.new(bear_color, 50),
                         style  = line.style_dotted,
                         extend = extend.right)

                label ob_label = na
                if show_label
                    ob_label := label.new(high_idx, zone_bot, "Bear OB",
                         style     = label.style_label_up,
                         color     = color.new(bear_color, 30),
                         textcolor = color.white,
                         size      = size.small)

                ob_obj new_ob = ob_obj.new(high_pt, zone_bot, mid_price, high_idx, true, false, ob_box, ob_line, ob_label)
                array.unshift(bear_obs, new_ob)

// =============================================================================
// 4. EXECUTE DETECTION
// =============================================================================

int bull_count_before = array.size(bull_obs)
int bear_count_before = array.size(bear_obs)

ph_sw = ta.pivothigh(high, sw_len, sw_len)
pl_sw = ta.pivotlow(low,  sw_len, sw_len)
detect_ob(ph_sw, pl_sw, sw_len, true)
detect_ob(ph_sw, pl_sw, sw_len, false)

bool new_bull_ob = array.size(bull_obs) > bull_count_before
bool new_bear_ob = array.size(bear_obs) > bear_count_before

// =============================================================================
// 5. TRIM TO MAX OB COUNT (oldest first)
// =============================================================================

while array.size(bull_obs) > max_obs
    ob_obj old = array.pop(bull_obs)
    box.delete(old.d)
    if not na(old.l)
        line.delete(old.l)
    if not na(old.lbl)
        label.delete(old.lbl)

while array.size(bear_obs) > max_obs
    ob_obj old = array.pop(bear_obs)
    box.delete(old.d)
    if not na(old.l)
        line.delete(old.l)
    if not na(old.lbl)
        label.delete(old.lbl)

// =============================================================================
// 6. TOUCH DETECTION + INVALIDATION CLEANUP
// =============================================================================

bool fresh_bull_touch = false
bool fresh_bear_touch = false

if array.size(bull_obs) > 0
    for i = array.size(bull_obs) - 1 to 0
        ob_obj o = array.get(bull_obs, i)

        bool overlap_now = low <= o.top and high >= o.bot
        if overlap_now and o.active and bar_index > o.idx and not o.touched
            o.touched        := true
            fresh_bull_touch := true

        bool invalidated = mit_mode == "Close" ? close < o.bot : low < o.bot
        if invalidated
            if show_mit
                box.set_bgcolor(o.d,      color.new(bull_color, 95))
                box.set_border_color(o.d, color.new(bull_color, 70))
                box.set_extend(o.d,       extend.none)
            else
                box.delete(o.d)
            if not na(o.l)
                line.delete(o.l)
            if not na(o.lbl)
                label.delete(o.lbl)
            o.active := false
            array.remove(bull_obs, i)

if array.size(bear_obs) > 0
    for i = array.size(bear_obs) - 1 to 0
        ob_obj o = array.get(bear_obs, i)

        bool overlap_now = high >= o.bot and low <= o.top
        if overlap_now and o.active and bar_index > o.idx and not o.touched
            o.touched        := true
            fresh_bear_touch := true

        bool invalidated = mit_mode == "Close" ? close > o.top : high > o.top
        if invalidated
            if show_mit
                box.set_bgcolor(o.d,      color.new(bear_color, 95))
                box.set_border_color(o.d, color.new(bear_color, 70))
                box.set_extend(o.d,       extend.none)
            else
                box.delete(o.d)
            if not na(o.l)
                line.delete(o.l)
            if not na(o.lbl)
                label.delete(o.lbl)
            o.active := false
            array.remove(bear_obs, i)

// =============================================================================
// 7. ALERTS
// =============================================================================

alertcondition(new_bull_ob,      "New Bull OB",     "New bullish order block on {{ticker}} {{interval}}")
alertcondition(new_bear_ob,      "New Bear OB",     "New bearish order block on {{ticker}} {{interval}}")
alertcondition(fresh_bull_touch, "Bull OB Touched", "Price entered a bullish order block on {{ticker}} {{interval}}")
alertcondition(fresh_bear_touch, "Bear OB Touched", "Price entered a bearish order block on {{ticker}} {{interval}}")
````
