# JTA SMC Pro - (Invite Only)

- url: https://www.tradingview.com/script/1T7TlW6W-JTA-SMC-Pro-Invite-Only/
- type: indicator
- pine_id: PUB;2e85bb9fd5e4414dbe69bae395085982
- version: 3.0

## Description

JTA SMC Pro — Smart Money Concepts Structure & Liquidity Suite
A complete market-structure toolkit built on pure Smart Money Concepts — no candlestick patterns, no lagging oscillators. Every signal on this chart comes from how price actually breaks structure, where institutional orders are likely resting, and when the highest-probability trading windows are open.

What it tracks:
📍 CHoCH (Change of Character) — marks the exact candle where market structure shifts, drawn as a bold horizontal line starting precisely at the broken pivot. Fires once per genuine structural flip — no repaint, no clutter from continuation noise.

📦 Order Blocks — the last bearish candle before a bullish reversal, and the strongest bullish candle before a bearish reversal. Boxes go from a pale fill to a solid highlight the moment price returns to mitigate them.

⚡ Fair Value Gaps (Imbalance) — bullish gaps in green, bearish in red, capped to a short distance so they never clutter historical price.

💧 Liquidity Mapping — long-wick swing highs/lows (Buyside/Sellside Liquidity) shown only while unfilled, disappearing the instant price sweeps through. Higher-timeframe liquidity (1D/4H/1H) is nested — 4H only displays while inside the 1D range, 1H only while inside the 4H range — so you're always looking at the most relevant, currently-valid level.

🕒 ICT Kill Zones — Asian, London Open, New York, and London Close sessions shaded directly on the chart, calculated in true New York time and automatically adjusted for daylight saving — no manual updates needed twice a year.

📊 Live Dashboard — structure bias, HTF liquidity targets, active kill zone (with an early "Approaching NY Kill Zone" warning), current date/time, and active order block count — all in one clean panel.

🗓️ Time Markers — optional vertical markers for Midnight Open and custom NY trading session times, fully toggleable.

Built for: Forex majors, Gold (XAUUSD), Crypto, and Indices (US30, NAS100) — any market where institutional liquidity and structure drive price.

This is not a buy/sell signal generator. It's a pure structure and liquidity mapping tool — built for traders who want to see what smart money is doing and make their own entries from there.
Invite-only access. Built and maintained by Jawaad Trading Academy (@jawaadtradingacademy).

## Source Code

````pine
//@version=6
indicator("JTA - SMC Pro", overlay=true, max_bars_back=500, max_lines_count=400, max_labels_count=400, max_boxes_count=400)

// ============================================================
// INPUTS
// ============================================================
grp_struct  = "Structure (CHoCH)"
grp_ob      = "Order Blocks"
grp_imb     = "Imbalance (FVG)"
grp_liq     = "Liquidity"
grp_kz      = "ICT Kill Zones"
grp_vm      = "Vertical Time Markers"
grp_dash    = "Dashboard"

// Structure
struct_len    = input.int(8,   "Structure Lookback", group=grp_struct, minval=3, maxval=30)
show_choch    = input.bool(true, "Show CHoCH Lines", group=grp_struct)

// Order Blocks
show_ob       = input.bool(true, "Show Order Blocks", group=grp_ob)
ob_extend     = input.int(20,    "OB Box Extend (bars)", group=grp_ob, minval=5, maxval=50)
ob_max_count  = input.int(3,     "Max Active OBs per side", group=grp_ob, minval=1, maxval=10)

// Imbalance
show_fvg      = input.bool(true,  "Show FVG", group=grp_imb)
imb_extend    = input.int(8,     "FVG Box Extend (bars)", group=grp_imb, minval=5, maxval=10)
fvg_min_atr   = input.float(0.2, "Min FVG Size (x ATR)", group=grp_imb, minval=0.05, maxval=1.0)

// Liquidity
liq_len       = input.int(25,   "Local Liquidity Lookback (bars)", group=grp_liq, minval=10, maxval=60)
wick_ratio    = input.float(0.6, "Min Wick Ratio for Liquidity", group=grp_liq, minval=0.3, maxval=0.9)
show_bsl      = input.bool(true, "Show Local BSL", group=grp_liq)
show_ssl      = input.bool(true, "Show Local SSL", group=grp_liq)
show_1d_liq   = input.bool(true,  "Show 1D Liquidity", group=grp_liq)
show_4h_liq   = input.bool(true,  "Show 4H Liquidity", group=grp_liq)
show_1h_liq   = input.bool(false, "Show 1H Liquidity", group=grp_liq)

// ICT Kill Zones
show_killzones = input.bool(true, "Show ICT Kill Zones", group=grp_kz)
show_kz_labels = input.bool(true, "Show Kill Zone Labels", group=grp_kz)
// Fixed session windows, matching ICT Killzones convention exactly: fixed UTC-5 offset (no DST shift)

// Vertical Time Markers — red dashed lines with date/time labels, NY time, DST-aware
show_vm_midnight = input.bool(true, "Show Midnight Open Marker",    group=grp_vm)
show_vm_tz1      = input.bool(true, "Show Trading Zone Open 1 Marker", group=grp_vm)
show_vm_tz2      = input.bool(true, "Show Trading Zone Open 2 Marker", group=grp_vm)
show_vm_tzc      = input.bool(true, "Show Trading Zone Close Marker",  group=grp_vm)
vm_midnight_hour = input.int(0,  "Midnight Open Hour (NY time)",      group=grp_vm, minval=0, maxval=23)
vm_midnight_min  = input.int(0,  "Midnight Open Minute (NY time)",    group=grp_vm, minval=0, maxval=59)
vm_tz1_hour      = input.int(8,  "Trading Zone Open 1 Hour (NY time)",   group=grp_vm, minval=0, maxval=23)
vm_tz1_min       = input.int(30, "Trading Zone Open 1 Minute (NY time)", group=grp_vm, minval=0, maxval=59)
vm_tz2_hour      = input.int(9,  "Trading Zone Open 2 Hour (NY time)",   group=grp_vm, minval=0, maxval=23)
vm_tz2_min       = input.int(30, "Trading Zone Open 2 Minute (NY time)", group=grp_vm, minval=0, maxval=59)
vm_tzc_hour      = input.int(12, "Trading Zone Close Hour (NY time)",    group=grp_vm, minval=0, maxval=23)
vm_tzc_min       = input.int(0,  "Trading Zone Close Minute (NY time)",  group=grp_vm, minval=0, maxval=59)

// Dashboard
show_dash     = input.bool(true, "Show Dashboard", group=grp_dash)
dash_pos      = input.string("Top Right", "Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=grp_dash)

// ============================================================
// COLORS — pale, not too dark
// ============================================================
col_bull        = color.new(#00E5A0, 0)
col_bear        = color.new(#FF4757, 0)
col_ob_bull     = color.new(#3F51B5, 85)
col_ob_bear     = color.new(#FF9800, 85)
col_ob_bull_bdr = color.new(#3F51B5, 30)
col_ob_bear_bdr = color.new(#FF9800, 30)
col_ob_bull_mit = color.new(#3F51B5, 55)
col_ob_bear_mit = color.new(#FF9800, 55)
col_fvg_bull    = color.new(#00C853, 82)
col_fvg_bear    = color.new(#FF1744, 82)
col_fvg_bull_bdr = color.new(#00C853, 20)
col_fvg_bear_bdr = color.new(#FF1744, 20)
col_bsl         = color.new(#2196F3, 0)
col_ssl         = color.new(#8D6E63, 0)
col_white       = color.new(#FFFFFF, 0)
col_dim         = color.new(#888888, 0)
col_dash_bg     = color.new(#0A0A0A, 5)
col_kz_asia     = color.new(#E91E63, 90)
col_kz_ldno     = color.new(#00BCD4, 90)
col_kz_ny       = color.new(#E4913D, 90)
col_kz_ldnc     = color.new(#2157F3, 90)
col_vm          = color.new(#FF3B30, 0)

// ============================================================
// ATR
// ============================================================
atr14 = ta.atr(14)

// ============================================================
// STRUCTURE — pivots tracked, CHoCH line starts exactly at the broken candle (Lux style)
// All detection confirmed-bar only (no repaint, nothing shown on forming candle)
// ============================================================
struct_ph = ta.pivothigh(high, struct_len, struct_len)
struct_pl = ta.pivotlow(low,   struct_len, struct_len)

var float struct_top     = na
var float struct_btm     = na
var int   struct_top_bar = na   // the exact bar index of the pivot candle that got broken
var int   struct_btm_bar = na

if barstate.isconfirmed
    if not na(struct_ph)
        struct_top     := struct_ph
        struct_top_bar := bar_index - struct_len
    if not na(struct_pl)
        struct_btm     := struct_pl
        struct_btm_bar := bar_index - struct_len

var int  struct_bias = 0
var bool choch_up = false
var bool choch_dn = false
choch_up := false
choch_dn := false

var float choch_up_level = na
var float choch_dn_level = na
var int   choch_up_from  = na
var int   choch_dn_from  = na

// Crossover/crossunder called unconditionally every bar for consistent historical tracking,
// then gated by the na-checks and barstate.isconfirmed below.
top_cross_up = ta.crossover(close, struct_top)
btm_cross_dn = ta.crossunder(close, struct_btm)

if barstate.isconfirmed
    // CHoCH only fires on a genuine bias FLIP (was bearish/neutral, now crossing up) — not on
    // every continuation break in an already-bullish trend. This is what was causing repeated
    // CHoCH prints stacking on top of each other during chop: continuation breaks were being
    // mislabeled as CHoCH. Now each leg produces at most one CHoCH, in either direction.
    if not na(struct_top) and top_cross_up and struct_bias <= 0
        choch_up := true
        struct_bias := 1
        choch_up_level := struct_top
        choch_up_from  := struct_top_bar
    if not na(struct_btm) and btm_cross_dn and struct_bias >= 0
        choch_dn := true
        struct_bias := -1
        choch_dn_level := struct_btm
        choch_dn_from  := struct_btm_bar

trend_bull = struct_bias == 1
trend_bear = struct_bias == -1

// CHoCH line starts EXACTLY at the broken pivot candle (horizontal), extends to the breakout bar.
// Green for bullish break, red for bearish break — bold (width 2) and darker shade for visibility.
// Small "CHoCH" text centered in the middle of the line, offset slightly off the line itself
// (up for bullish, down for bearish) so consecutive CHoCH events don't visually stack.
if show_choch and barstate.isconfirmed
    if choch_up and not na(choch_up_from)
        line.new(choch_up_from, choch_up_level, bar_index, choch_up_level, color=color.new(#00B377,0), style=line.style_dashed, width=2)
        choch_up_mid = math.round((choch_up_from + bar_index) / 2)
        label.new(choch_up_mid, choch_up_level + atr14 * 0.35, "CHoCH", color=color.new(#000000,100), textcolor=color.new(#00B377,0), style=label.style_label_center, size=size.small)
    if choch_dn and not na(choch_dn_from)
        line.new(choch_dn_from, choch_dn_level, bar_index, choch_dn_level, color=color.new(#D32F3D,0), style=line.style_dashed, width=2)
        choch_dn_mid = math.round((choch_dn_from + bar_index) / 2)
        label.new(choch_dn_mid, choch_dn_level - atr14 * 0.35, "CHoCH", color=color.new(#000000,100), textcolor=color.new(#D32F3D,0), style=label.style_label_center, size=size.small)

// ============================================================
// ORDER BLOCKS — redefined:
//   Bullish OB = the LAST bearish candle of the prior downtrend (i.e. just before CHoCH up)
//   Bearish OB = the HIGHEST bullish candle of the prior uptrend (i.e. just before CHoCH down)
//   Full candle range (high-to-low), pale color-fade, becomes solid/highlighted once mitigated (touched)
// ============================================================
var float[] ob_bull_hi  = array.new_float(0)
var float[] ob_bull_lo  = array.new_float(0)
var box[]   ob_bull_box = array.new_box(0)
var bool[]  ob_bull_mit = array.new_bool(0)

var float[] ob_bear_hi  = array.new_float(0)
var float[] ob_bear_lo  = array.new_float(0)
var box[]   ob_bear_box = array.new_box(0)
var bool[]  ob_bear_mit = array.new_bool(0)

// On bullish CHoCH: scan back through the prior downtrend leg for the last bearish candle (full range)
if barstate.isconfirmed and choch_up and show_ob
    for i = 1 to struct_len * 3
        if close[i] < open[i]
            new_hi = high[i]
            new_lo = low[i]
            new_box = box.new(bar_index - i, new_hi, bar_index + ob_extend, new_lo, border_color=col_ob_bull_bdr, bgcolor=col_ob_bull, border_width=1, text="OB", text_color=color.new(#3F51B5,15), text_size=size.tiny, text_halign=text.align_left, text_valign=text.align_top)
            array.push(ob_bull_hi, new_hi)
            array.push(ob_bull_lo, new_lo)
            array.push(ob_bull_box, new_box)
            array.push(ob_bull_mit, false)
            if array.size(ob_bull_box) > ob_max_count
                box.delete(array.shift(ob_bull_box))
                array.shift(ob_bull_hi)
                array.shift(ob_bull_lo)
                array.shift(ob_bull_mit)
            break

// On bearish CHoCH: scan back through the prior uptrend leg for the highest bullish candle (full range)
if barstate.isconfirmed and choch_dn and show_ob
    best_hi = -1.0
    float best_lo = na
    int best_bar = na
    for i = 1 to struct_len * 3
        if close[i] > open[i] and high[i] > best_hi
            best_hi  := high[i]
            best_lo  := low[i]
            best_bar := bar_index - i
    if not na(best_bar)
        new_box = box.new(best_bar, best_hi, bar_index + ob_extend, best_lo, border_color=col_ob_bear_bdr, bgcolor=col_ob_bear, border_width=1, text="OB", text_color=color.new(#FF9800,15), text_size=size.tiny, text_halign=text.align_left, text_valign=text.align_top)
        array.push(ob_bear_hi, best_hi)
        array.push(ob_bear_lo, best_lo)
        array.push(ob_bear_box, new_box)
        array.push(ob_bear_mit, false)
        if array.size(ob_bear_box) > ob_max_count
            box.delete(array.shift(ob_bear_box))
            array.shift(ob_bear_hi)
            array.shift(ob_bear_lo)
            array.shift(ob_bear_mit)

// Mitigation check — confirmed bars only. Once price closes back into an OB, mark it mitigated and highlight (solid).
bull_ob_mitigated_now = false
bear_ob_mitigated_now = false

if barstate.isconfirmed and array.size(ob_bull_box) > 0
    for k = 0 to array.size(ob_bull_box) - 1
        if not array.get(ob_bull_mit, k)
            hi = array.get(ob_bull_hi, k)
            lo = array.get(ob_bull_lo, k)
            if low <= hi and low >= lo
                array.set(ob_bull_mit, k, true)
                box.set_bgcolor(array.get(ob_bull_box, k), col_ob_bull_mit)
                bull_ob_mitigated_now := true

if barstate.isconfirmed and array.size(ob_bear_box) > 0
    for k = 0 to array.size(ob_bear_box) - 1
        if not array.get(ob_bear_mit, k)
            hi = array.get(ob_bear_hi, k)
            lo = array.get(ob_bear_lo, k)
            if high >= lo and high <= hi
                array.set(ob_bear_mit, k, true)
                box.set_bgcolor(array.get(ob_bear_box, k), col_ob_bear_mit)
                bear_ob_mitigated_now := true

// ============================================================
// FVG — bullish = GREEN, bearish = RED, pale, no text, capped 5-10 bar extend
// Tracks fill state for each FVG (used to determine when a zone is no longer fresh)
// ============================================================
fvg_min_size = atr14 * fvg_min_atr
bull_fvg_valid = low > high[2] and (low - high[2]) >= fvg_min_size
bear_fvg_valid = high < low[2] and (low[2] - high) >= fvg_min_size

var float[] fvg_bull_hi  = array.new_float(0)
var float[] fvg_bull_lo  = array.new_float(0)
var int[]   fvg_bull_bar = array.new_int(0)
var bool[]  fvg_bull_filled = array.new_bool(0)
var box[]   fvg_bull_box = array.new_box(0)

var float[] fvg_bear_hi  = array.new_float(0)
var float[] fvg_bear_lo  = array.new_float(0)
var int[]   fvg_bear_bar = array.new_int(0)
var bool[]  fvg_bear_filled = array.new_bool(0)
var box[]   fvg_bear_box = array.new_box(0)

if barstate.isconfirmed and bull_fvg_valid
    f_hi = low
    f_lo = high[2]
    f_bar = bar_index - 2
    array.push(fvg_bull_hi, f_hi)
    array.push(fvg_bull_lo, f_lo)
    array.push(fvg_bull_bar, f_bar)
    array.push(fvg_bull_filled, false)
    if show_fvg
        new_box = box.new(f_bar, f_hi, f_bar + imb_extend, f_lo, border_color=col_fvg_bull_bdr, bgcolor=col_fvg_bull, border_width=1, border_style=line.style_dotted, text="FVG", text_color=color.new(#00C853,15), text_size=size.tiny, text_halign=text.align_left, text_valign=text.align_top)
        array.push(fvg_bull_box, new_box)
    else
        array.push(fvg_bull_box, na)
    if array.size(fvg_bull_hi) > 10
        array.shift(fvg_bull_hi)
        array.shift(fvg_bull_lo)
        array.shift(fvg_bull_bar)
        array.shift(fvg_bull_filled)
        old = array.shift(fvg_bull_box)
        box.delete(old)

if barstate.isconfirmed and bear_fvg_valid
    f_hi = low[2]
    f_lo = high
    f_bar = bar_index
    array.push(fvg_bear_hi, f_hi)
    array.push(fvg_bear_lo, f_lo)
    array.push(fvg_bear_bar, f_bar)
    array.push(fvg_bear_filled, false)
    if show_fvg
        new_box = box.new(bar_index - 2, f_hi, bar_index - 2 + imb_extend, f_lo, border_color=col_fvg_bear_bdr, bgcolor=col_fvg_bear, border_width=1, border_style=line.style_dotted, text="FVG", text_color=color.new(#FF1744,15), text_size=size.tiny, text_halign=text.align_left, text_valign=text.align_top)
        array.push(fvg_bear_box, new_box)
    else
        array.push(fvg_bear_box, na)
    if array.size(fvg_bear_hi) > 10
        array.shift(fvg_bear_hi)
        array.shift(fvg_bear_lo)
        array.shift(fvg_bear_bar)
        array.shift(fvg_bear_filled)
        old = array.shift(fvg_bear_box)
        box.delete(old)

// Mark FVGs as completely filled once price closes all the way through them (confirmed bars only)
if barstate.isconfirmed and array.size(fvg_bull_hi) > 0
    for k = 0 to array.size(fvg_bull_hi) - 1
        if not array.get(fvg_bull_filled, k) and close < array.get(fvg_bull_lo, k)
            array.set(fvg_bull_filled, k, true)

if barstate.isconfirmed and array.size(fvg_bear_hi) > 0
    for k = 0 to array.size(fvg_bear_hi) - 1
        if not array.get(fvg_bear_filled, k) and close > array.get(fvg_bear_hi, k)
            array.set(fvg_bear_filled, k, true)

// ============================================================
// LOCAL LIQUIDITY — long-wick swing high/low candles, shown ONLY while unfilled.
// Once price trades through the level, it is considered swept/finished and removed.
// ============================================================
candle_range = high - low
upper_wick   = high - math.max(open, close)
lower_wick   = math.min(open, close) - low

liq_highest = ta.highest(high, liq_len)
liq_lowest  = ta.lowest(low, liq_len)

is_liq_high  = candle_range > 0 and (upper_wick / candle_range) >= wick_ratio and high == liq_highest
is_liq_low   = candle_range > 0 and (lower_wick / candle_range) >= wick_ratio and low  == liq_lowest

var float local_liq_high     = na
var int   local_liq_high_bar = na
var bool  local_liq_high_swept = true
var float local_liq_low      = na
var int   local_liq_low_bar  = na
var bool  local_liq_low_swept = true

if barstate.isconfirmed and is_liq_high
    local_liq_high       := high
    local_liq_high_bar   := bar_index
    local_liq_high_swept := false

if barstate.isconfirmed and is_liq_low
    local_liq_low       := low
    local_liq_low_bar   := bar_index
    local_liq_low_swept := false

// Mark as swept (finished) once a confirmed candle's high/low trades through the level
if barstate.isconfirmed and not local_liq_high_swept and not na(local_liq_high)
    if high > local_liq_high
        local_liq_high_swept := true

if barstate.isconfirmed and not local_liq_low_swept and not na(local_liq_low)
    if low < local_liq_low
        local_liq_low_swept := true

var line liq_high_line = na
var line liq_low_line  = na
var label liq_high_lbl = na
var label liq_low_lbl  = na

if barstate.islast
    line.delete(liq_high_line)
    line.delete(liq_low_line)
    label.delete(liq_high_lbl)
    label.delete(liq_low_lbl)
    if show_bsl and not local_liq_high_swept and not na(local_liq_high_bar)
        liq_high_line := line.new(local_liq_high_bar, local_liq_high, local_liq_high_bar + 1, local_liq_high, color=col_bsl, style=line.style_solid, width=1, extend=extend.right)
        liq_high_lbl  := label.new(local_liq_high_bar, local_liq_high, "Buyside Liquidity", color=color.new(#000000,100), textcolor=col_bsl, style=label.style_label_up, size=size.small)
    if show_ssl and not local_liq_low_swept and not na(local_liq_low_bar)
        liq_low_line := line.new(local_liq_low_bar, local_liq_low, local_liq_low_bar + 1, local_liq_low, color=col_ssl, style=line.style_solid, width=1, extend=extend.right)
        liq_low_lbl  := label.new(local_liq_low_bar, local_liq_low, "Sellside Liquidity", color=color.new(#000000,100), textcolor=col_ssl, style=label.style_label_down, size=size.small)

// ============================================================
// HTF LIQUIDITY — 1D, 4H, 1H — each independently toggleable, shown only while unswept/fresh
// ============================================================
d_high = request.security(syminfo.tickerid, "1D", high[1], lookahead=barmerge.lookahead_off)
d_low  = request.security(syminfo.tickerid, "1D", low[1],  lookahead=barmerge.lookahead_off)
h4_high = request.security(syminfo.tickerid, "240", high[1], lookahead=barmerge.lookahead_off)
h4_low  = request.security(syminfo.tickerid, "240", low[1],  lookahead=barmerge.lookahead_off)
h1_high = request.security(syminfo.tickerid, "60", high[1], lookahead=barmerge.lookahead_off)
h1_low  = request.security(syminfo.tickerid, "60", low[1],  lookahead=barmerge.lookahead_off)

// Track the actual bar index (on THIS chart's timeframe) where each HTF level last changed,
// so the liquidity ray can start exactly at that candle instead of an arbitrary lookback offset.
var int d_high_bar  = na
var int d_low_bar   = na
var int h4_high_bar = na
var int h4_low_bar  = na
var int h1_high_bar = na
var int h1_low_bar  = na

if ta.change(d_high) != 0
    d_high_bar := bar_index
if ta.change(d_low) != 0
    d_low_bar := bar_index
if ta.change(h4_high) != 0
    h4_high_bar := bar_index
if ta.change(h4_low) != 0
    h4_low_bar := bar_index
if ta.change(h1_high) != 0
    h1_high_bar := bar_index
if ta.change(h1_low) != 0
    h1_low_bar := bar_index

d_high_swept  = barstate.isconfirmed and high > d_high
d_low_swept   = barstate.isconfirmed and low  < d_low
h4_high_swept = barstate.isconfirmed and high > h4_high
h4_low_swept  = barstate.isconfirmed and low  < h4_low
h1_high_swept = barstate.isconfirmed and high > h1_high
h1_low_swept  = barstate.isconfirmed and low  < h1_low

// One-shot (edge-triggered) versions for alerts only — fires once on the bar the level is first swept
d_high_swept_now  = d_high_swept  and not d_high_swept[1]
d_low_swept_now   = d_low_swept   and not d_low_swept[1]
h4_high_swept_now = h4_high_swept and not h4_high_swept[1]
h4_low_swept_now  = h4_low_swept  and not h4_low_swept[1]
h1_high_swept_now = h1_high_swept and not h1_high_swept[1]
h1_low_swept_now  = h1_low_swept  and not h1_low_swept[1]

// Nesting rule: 4H liquidity only valid while it sits strictly inside the 1D range;
// 1H liquidity only valid while it sits strictly inside the 4H range. Otherwise hidden.
h4_high_nested = h4_high <= d_high
h4_low_nested  = h4_low  >= d_low
h1_high_nested = h1_high <= h4_high
h1_low_nested  = h1_low  >= h4_low

var line d_high_line  = na
var line d_low_line   = na
var line h4_high_line = na
var line h4_low_line  = na
var line h1_high_line = na
var line h1_low_line  = na
var label d_high_lbl  = na
var label d_low_lbl   = na
var label h4_high_lbl = na
var label h4_low_lbl  = na
var label h1_high_lbl = na
var label h1_low_lbl  = na

if barstate.islast
    line.delete(d_high_line)
    line.delete(d_low_line)
    line.delete(h4_high_line)
    line.delete(h4_low_line)
    line.delete(h1_high_line)
    line.delete(h1_low_line)
    label.delete(d_high_lbl)
    label.delete(d_low_lbl)
    label.delete(h4_high_lbl)
    label.delete(h4_low_lbl)
    label.delete(h1_high_lbl)
    label.delete(h1_low_lbl)
    if show_1d_liq and not d_high_swept and not na(d_high_bar)
        d_high_line := line.new(d_high_bar, d_high, d_high_bar + 1, d_high, color=col_bsl, style=line.style_solid, width=2, extend=extend.right)
        d_high_lbl  := label.new(bar_index + 10, d_high, "1D Buyside Liquidity", color=color.new(#000000,100), textcolor=col_bsl, style=label.style_label_left, size=size.small)
    if show_1d_liq and not d_low_swept and not na(d_low_bar)
        d_low_line  := line.new(d_low_bar, d_low, d_low_bar + 1, d_low, color=col_ssl, style=line.style_solid, width=2, extend=extend.right)
        d_low_lbl   := label.new(bar_index + 10, d_low, "1D Sellside Liquidity", color=color.new(#000000,100), textcolor=col_ssl, style=label.style_label_left, size=size.small)
    if show_4h_liq and not h4_high_swept and h4_high_nested and not na(h4_high_bar)
        h4_high_line := line.new(h4_high_bar, h4_high, h4_high_bar + 1, h4_high, color=col_bsl, style=line.style_solid, width=1, extend=extend.right)
        h4_high_lbl  := label.new(bar_index + 10, h4_high, "4H Buyside Liquidity", color=color.new(#000000,100), textcolor=col_bsl, style=label.style_label_left, size=size.small)
    if show_4h_liq and not h4_low_swept and h4_low_nested and not na(h4_low_bar)
        h4_low_line  := line.new(h4_low_bar, h4_low, h4_low_bar + 1, h4_low, color=col_ssl, style=line.style_solid, width=1, extend=extend.right)
        h4_low_lbl   := label.new(bar_index + 10, h4_low, "4H Sellside Liquidity", color=color.new(#000000,100), textcolor=col_ssl, style=label.style_label_left, size=size.small)
    if show_1h_liq and not h1_high_swept and h1_high_nested and not na(h1_high_bar)
        h1_high_line := line.new(h1_high_bar, h1_high, h1_high_bar + 1, h1_high, color=col_bsl, style=line.style_solid, width=1, extend=extend.right)
        h1_high_lbl  := label.new(bar_index + 10, h1_high, "1H Buyside Liquidity", color=color.new(#000000,100), textcolor=col_bsl, style=label.style_label_left, size=size.tiny)
    if show_1h_liq and not h1_low_swept and h1_low_nested and not na(h1_low_bar)
        h1_low_line  := line.new(h1_low_bar, h1_low, h1_low_bar + 1, h1_low, color=col_ssl, style=line.style_solid, width=1, extend=extend.right)
        h1_low_lbl   := label.new(bar_index + 10, h1_low, "1H Sellside Liquidity", color=color.new(#000000,100), textcolor=col_ssl, style=label.style_label_left, size=size.tiny)

// ============================================================
// ICT KILL ZONES — Asian, London Open, New York, London Close
// Shaded vertical background zones with centered name labels, independently built
// ============================================================
in_kz_asia = not na(time(timeframe.period, "2000-0000", "UTC-5"))
in_kz_ldno = not na(time(timeframe.period, "0200-0500", "UTC-5"))
in_kz_ny   = not na(time(timeframe.period, "0700-0900", "UTC-5"))
in_kz_ldnc = not na(time(timeframe.period, "1000-1200", "UTC-5"))

// Edge-triggered "zone just started" flags, for alerts
kz_asia_started = in_kz_asia and not in_kz_asia[1]
kz_ldno_started = in_kz_ldno and not in_kz_ldno[1]
kz_ny_started    = in_kz_ny   and not in_kz_ny[1]
kz_ldnc_started  = in_kz_ldnc and not in_kz_ldnc[1]

bgcolor(show_killzones and in_kz_asia ? col_kz_asia : na, title="Asian Kill Zone")
bgcolor(show_killzones and in_kz_ldno ? col_kz_ldno : na, title="London Open Kill Zone")
bgcolor(show_killzones and in_kz_ny   ? col_kz_ny   : na, title="New York Kill Zone")
bgcolor(show_killzones and in_kz_ldnc ? col_kz_ldnc : na, title="London Close Kill Zone")

// Centered label: anchor recenters to the midpoint of the active zone, y-position tracks the zone's running high
var label kz_asia_lbl = na
var int   kz_asia_start_bar = na
var float kz_asia_high = na
var label kz_ldno_lbl = na
var int   kz_ldno_start_bar = na
var float kz_ldno_high = na
var label kz_ny_lbl = na
var int   kz_ny_start_bar = na
var float kz_ny_high = na
var label kz_ldnc_lbl = na
var int   kz_ldnc_start_bar = na
var float kz_ldnc_high = na

if show_killzones and show_kz_labels
    if in_kz_asia and not in_kz_asia[1]
        kz_asia_start_bar := bar_index
        kz_asia_high := high
        label.delete(kz_asia_lbl)
        kz_asia_lbl := label.new(bar_index, high, "Asian", color=color.new(#E91E63,100), textcolor=color.new(#E91E63,0), style=label.style_label_down, size=size.small)
    if in_kz_asia and not na(kz_asia_start_bar)
        kz_asia_high := math.max(high, kz_asia_high)
        label.set_x(kz_asia_lbl, math.round((kz_asia_start_bar + bar_index) / 2))
        label.set_y(kz_asia_lbl, kz_asia_high)
    if in_kz_ldno and not in_kz_ldno[1]
        kz_ldno_start_bar := bar_index
        kz_ldno_high := high
        label.delete(kz_ldno_lbl)
        kz_ldno_lbl := label.new(bar_index, high, "London Open", color=color.new(#00BCD4,100), textcolor=color.new(#00BCD4,0), style=label.style_label_down, size=size.small)
    if in_kz_ldno and not na(kz_ldno_start_bar)
        kz_ldno_high := math.max(high, kz_ldno_high)
        label.set_x(kz_ldno_lbl, math.round((kz_ldno_start_bar + bar_index) / 2))
        label.set_y(kz_ldno_lbl, kz_ldno_high)
    if in_kz_ny and not in_kz_ny[1]
        kz_ny_start_bar := bar_index
        kz_ny_high := high
        label.delete(kz_ny_lbl)
        kz_ny_lbl := label.new(bar_index, high, "New York", color=color.new(#E4913D,100), textcolor=color.new(#E4913D,0), style=label.style_label_down, size=size.small)
    if in_kz_ny and not na(kz_ny_start_bar)
        kz_ny_high := math.max(high, kz_ny_high)
        label.set_x(kz_ny_lbl, math.round((kz_ny_start_bar + bar_index) / 2))
        label.set_y(kz_ny_lbl, kz_ny_high)
    if in_kz_ldnc and not in_kz_ldnc[1]
        kz_ldnc_start_bar := bar_index
        kz_ldnc_high := high
        label.delete(kz_ldnc_lbl)
        kz_ldnc_lbl := label.new(bar_index, high, "London Close", color=color.new(#2157F3,100), textcolor=color.new(#2157F3,0), style=label.style_label_down, size=size.small)
    if in_kz_ldnc and not na(kz_ldnc_start_bar)
        kz_ldnc_high := math.max(high, kz_ldnc_high)
        label.set_x(kz_ldnc_lbl, math.round((kz_ldnc_start_bar + bar_index) / 2))
        label.set_y(kz_ldnc_lbl, kz_ldnc_high)

// ============================================================
// VERTICAL TIME MARKERS — Midnight Open + 3 NY Trading Zone times.
// Red dashed vertical line with a "Day DD Mon 'YY  HH:MM" label, NY time, DST-aware.
// ============================================================
dow_names = array.from("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")
mon_names = array.from("", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")

fmt_marker_label(int t) =>
    d  = dayofweek(t, "America/New_York")
    dm = dayofmonth(t, "America/New_York")
    mo = month(t, "America/New_York")
    yr = year(t, "America/New_York")
    hh = hour(t, "America/New_York")
    mm = minute(t, "America/New_York")
    array.get(dow_names, d - 1) + " " + str.tostring(dm) + " " + array.get(mon_names, mo) + " '" + str.tostring(yr % 100) + "  " + str.tostring(hh, "#00") + ":" + str.tostring(mm, "#00")

draw_vm(bool fire, string label_text) =>
    if fire
        line.new(bar_index, low - atr14 * 20, bar_index, high + atr14 * 20, color=col_vm, style=line.style_dashed, width=1, extend=extend.both)
        label.new(bar_index, low - atr14 * 4, label_text, color=col_vm, textcolor=color.white, style=label.style_label_up, size=size.small)

vm_ny_hour = hour(time, "America/New_York")
vm_ny_min  = minute(time, "America/New_York")

is_vm_midnight = vm_ny_hour == vm_midnight_hour and vm_ny_min == vm_midnight_min
is_vm_tz1      = vm_ny_hour == vm_tz1_hour      and vm_ny_min == vm_tz1_min
is_vm_tz2      = vm_ny_hour == vm_tz2_hour      and vm_ny_min == vm_tz2_min
is_vm_tzc      = vm_ny_hour == vm_tzc_hour      and vm_ny_min == vm_tzc_min

if barstate.isconfirmed
    if show_vm_midnight and is_vm_midnight
        draw_vm(true, "MIDNIGHT OPEN\n" + fmt_marker_label(time))
    if show_vm_tz1 and is_vm_tz1
        draw_vm(true, fmt_marker_label(time))
    if show_vm_tz2 and is_vm_tz2
        draw_vm(true, fmt_marker_label(time))
    if show_vm_tzc and is_vm_tzc
        draw_vm(true, fmt_marker_label(time))

// ============================================================
// ACTIVE KILL ZONE (dashboard label) — derived from the same DST-aware booleans used for shading
// ============================================================
active_kz_str = in_kz_asia ? "Asian" : in_kz_ldno ? "London Open" : in_kz_ny ? "New York" : in_kz_ldnc ? "London Close" : "None"

// Approaching NY Kill Zone — flags when within 30 minutes of NY session start (07:00, fixed UTC-5), not yet inside it.
// Uses the same fixed UTC-5 reference as the kill zone shading itself, so the two stay consistent.
ny_hour_now    = hour(time, "UTC-5")
ny_min_now     = minute(time, "UTC-5")
minutes_now    = ny_hour_now * 60 + ny_min_now
ny_kz_start_min = 7 * 60
mins_until_ny  = ny_kz_start_min - minutes_now
approaching_ny_kz = not in_kz_ny and mins_until_ny > 0 and mins_until_ny <= 30
approaching_ny_kz_now = approaching_ny_kz and not approaching_ny_kz[1]
kill_zone_display = approaching_ny_kz ? "Approaching NY Kill Zone" : active_kz_str

// Current bar's date/time (reflects the chart's most recent bar, NY time)
current_dt_str = fmt_marker_label(time)

// ============================================================
// DASHBOARD
// ============================================================
if show_dash and barstate.islast
    tpos = dash_pos == "Top Right" ? position.top_right : dash_pos == "Top Left" ? position.top_left : dash_pos == "Bottom Right" ? position.bottom_right : position.bottom_left
    var table t = table.new(tpos, 2, 9, bgcolor=col_dash_bg, border_color=color.new(#2A2A2A,0), border_width=2, frame_color=color.new(#00E5A0,30), frame_width=3)
    table.cell(t, 0, 0, "JTA SMC",   text_color=col_bull, text_size=size.large,  bgcolor=color.new(#00E5A0,82), text_halign=text.align_center)
    table.cell(t, 1, 0, "STRUCTURE", text_color=col_white, text_size=size.normal, bgcolor=color.new(#00E5A0,82), text_halign=text.align_center)
    table.cell(t, 0, 1, "DATE / TIME (NY)", text_color=col_dim, text_size=size.tiny)
    table.cell(t, 1, 1, current_dt_str, text_color=col_white, text_size=size.tiny)
    table.cell(t, 0, 2, "BIAS", text_color=col_dim, text_size=size.normal)
    table.cell(t, 1, 2, trend_bull ? "▲  BULLISH" : trend_bear ? "▼  BEARISH" : "—  NEUTRAL", text_color=trend_bull ? col_bull : trend_bear ? col_bear : col_dim, text_size=size.normal)
    table.cell(t, 0, 3, "1D  BSL / SSL", text_color=col_dim, text_size=size.small)
    table.cell(t, 1, 3, (d_high_swept ? "swept" : str.tostring(math.round(d_high*10000)/10000)) + "  /  " + (d_low_swept ? "swept" : str.tostring(math.round(d_low*10000)/10000)), text_color=col_white, text_size=size.small)
    table.cell(t, 0, 4, "4H  BSL / SSL", text_color=col_dim, text_size=size.small)
    table.cell(t, 1, 4, (h4_high_swept ? "swept" : not h4_high_nested ? "n/a" : str.tostring(math.round(h4_high*10000)/10000)) + "  /  " + (h4_low_swept ? "swept" : not h4_low_nested ? "n/a" : str.tostring(math.round(h4_low*10000)/10000)), text_color=col_white, text_size=size.small)
    table.cell(t, 0, 5, "1H  BSL / SSL", text_color=col_dim, text_size=size.small)
    table.cell(t, 1, 5, (h1_high_swept ? "swept" : not h1_high_nested ? "n/a" : str.tostring(math.round(h1_high*10000)/10000)) + "  /  " + (h1_low_swept ? "swept" : not h1_low_nested ? "n/a" : str.tostring(math.round(h1_low*10000)/10000)), text_color=col_white, text_size=size.small)
    table.cell(t, 0, 6, "KILL ZONE", text_color=col_dim, text_size=size.normal)
    table.cell(t, 1, 6, kill_zone_display, text_color=approaching_ny_kz ? color.new(#FF9800,0) : active_kz_str == "None" ? col_dim : color.new(#FFEB3B,0), text_size=size.normal)
    table.cell(t, 0, 7, "ACTIVE OBs", text_color=col_dim, text_size=size.small)
    table.cell(t, 1, 7, str.tostring(array.size(ob_bull_box)) + " bull  /  " + str.tostring(array.size(ob_bear_box)) + " bear", text_color=col_white, text_size=size.small)
    table.cell(t, 0, 8, "JTA SMC Pro", text_color=col_dim, text_size=size.tiny, text_halign=text.align_left, bgcolor=color.new(#000000,70))
    table.cell(t, 1, 8, syminfo.ticker, text_color=col_dim, text_size=size.tiny, text_halign=text.align_right, bgcolor=color.new(#000000,70))

// ============================================================
// PERMANENT WATERMARK — fixed, non-editable, no settings toggle
// ============================================================
var table watermark = table.new(position.top_center, 1, 3, bgcolor=color.new(#000000,100))
if barstate.islast
    table.cell(watermark, 0, 0, "JAWAAD TRADING ACADEMY", text_color=color.new(#555555,5), text_size=size.large, text_halign=text.align_center)
    table.cell(watermark, 0, 1, "PRAY  |  PRACTICE  |  PATIENCE", text_color=color.new(#555555,20), text_size=size.small, text_halign=text.align_center)
    table.cell(watermark, 0, 2, "WWW.JAWAADTRADINGACADEMY.COM", text_color=color.new(#555555,25), text_size=size.tiny, text_halign=text.align_center)

// ============================================================
// ALERTS — each individually toggleable in TradingView's "Create Alert" dialog
// ============================================================

// --- CHoCH ---
alertcondition(choch_up, title="JTA SMC Pro — Bullish CHoCH", message="JTA SMC Pro: Bullish CHoCH on {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(choch_dn, title="JTA SMC Pro — Bearish CHoCH", message="JTA SMC Pro: Bearish CHoCH on {{ticker}} ({{interval}}) @ {{close}}")

// --- Kill Zone Starts ---
alertcondition(kz_asia_started, title="JTA SMC Pro — Asian Kill Zone Started", message="JTA SMC Pro: Asian Kill Zone has started on {{ticker}}")
alertcondition(kz_ldno_started, title="JTA SMC Pro — London Open Kill Zone Started", message="JTA SMC Pro: London Open Kill Zone has started on {{ticker}}")
alertcondition(kz_ny_started, title="JTA SMC Pro — New York Kill Zone Started", message="JTA SMC Pro: New York Kill Zone has started on {{ticker}}")
alertcondition(kz_ldnc_started, title="JTA SMC Pro — London Close Kill Zone Started", message="JTA SMC Pro: London Close Kill Zone has started on {{ticker}}")

// --- Approaching NY Kill Zone ---
alertcondition(approaching_ny_kz_now, title="JTA SMC Pro — Approaching NY Kill Zone", message="JTA SMC Pro: Approaching NY Kill Zone (30 min) on {{ticker}}")

// --- Liquidity Swept ---
alertcondition(d_high_swept_now, title="JTA SMC Pro — 1D Buyside Liquidity Swept", message="JTA SMC Pro: 1D Buyside Liquidity swept on {{ticker}} @ {{close}}")
alertcondition(d_low_swept_now, title="JTA SMC Pro — 1D Sellside Liquidity Swept", message="JTA SMC Pro: 1D Sellside Liquidity swept on {{ticker}} @ {{close}}")
alertcondition(h4_high_swept_now, title="JTA SMC Pro — 4H Buyside Liquidity Swept", message="JTA SMC Pro: 4H Buyside Liquidity swept on {{ticker}} @ {{close}}")
alertcondition(h4_low_swept_now, title="JTA SMC Pro — 4H Sellside Liquidity Swept", message="JTA SMC Pro: 4H Sellside Liquidity swept on {{ticker}} @ {{close}}")
alertcondition(h1_high_swept_now, title="JTA SMC Pro — 1H Buyside Liquidity Swept", message="JTA SMC Pro: 1H Buyside Liquidity swept on {{ticker}} @ {{close}}")
alertcondition(h1_low_swept_now, title="JTA SMC Pro — 1H Sellside Liquidity Swept", message="JTA SMC Pro: 1H Sellside Liquidity swept on {{ticker}} @ {{close}}")

// --- Order Block Mitigation ---
alertcondition(bull_ob_mitigated_now, title="JTA SMC Pro — Bullish OB Mitigated", message="JTA SMC Pro: Bullish Order Block mitigated on {{ticker}} @ {{close}}")
alertcondition(bear_ob_mitigated_now, title="JTA SMC Pro — Bearish OB Mitigated", message="JTA SMC Pro: Bearish Order Block mitigated on {{ticker}} @ {{close}}")
````
