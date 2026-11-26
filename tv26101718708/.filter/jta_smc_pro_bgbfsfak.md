# JTA - SMC Pro

- url: https://www.tradingview.com/script/BGbFSfAk-JTA-SMC-Pro/
- type: indicator
- pine_id: PUB;66566b8425ef4ca9a37127396e7cda33
- version: 8.0

## Description

JTA SMC Pro — Free Smart Money Concepts Structure & Liquidity Suite
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
100% free. No invite required.

Built and maintained by Jawaad Trading Academy (@jawaadtradingacademy).

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
grp_sweep   = "Liquidity Sweeps"
grp_kz      = "Kill Zones"
grp_vm      = "Vertical Time Markers"
grp_dash    = "Dashboard"
grp_rates   = "Interest Rates"
grp_trend   = "Retail Trendline"
grp_pattern = "Chart Patterns"

// Structure
struct_len    = input.int(8,   "Structure Lookback", group=grp_struct, minval=3, maxval=30)
show_choch    = input.bool(true, "Show CHoCH Lines", group=grp_struct)

// Order Blocks
show_ob       = input.bool(true, "Show Order Blocks", group=grp_ob)
ob_extend     = input.int(20,    "OB Box Extend (bars)", group=grp_ob, minval=5, maxval=50)
ob_max_count  = input.int(2,     "Max Active OBs per side", group=grp_ob, minval=1, maxval=5)

// Imbalance
show_fvg      = input.bool(true,  "Show FVG", group=grp_imb)
imb_extend    = input.int(8,     "FVG Box Extend (bars)", group=grp_imb, minval=5, maxval=10)
fvg_min_atr   = input.float(0.2, "Min FVG Size (x ATR)", group=grp_imb, minval=0.05, maxval=1.0)

// Liquidity
liq_len       = input.int(25,   "Local Liquidity Lookback (bars)", group=grp_liq, minval=10, maxval=60)
wick_ratio    = input.float(0.6, "Min Wick Ratio for Liquidity", group=grp_liq, minval=0.3, maxval=0.9)
show_bsl      = input.bool(true, "Show Local BSL", group=grp_liq)
show_ssl      = input.bool(true, "Show Local SSL", group=grp_liq)

// Liquidity Sweeps
show_sweeps     = input.bool(true, "Show Significant Sweeps", group=grp_sweep)
sweep_swing_len = input.int(8, "Sweep Swing Lookback", group=grp_sweep, minval=3, maxval=20)
sweep_min_atr   = input.float(0.6, "Min Sweep Size (x ATR)", group=grp_sweep, minval=0.1, maxval=2.0, tooltip="Filters out tiny insignificant wicks — only larger, more meaningful sweeps are shown")
sweep_once_per_leg = input.bool(true, "Only First Sweep Per Trend Leg", group=grp_sweep, tooltip="Hides repeated sweeps within the same trend leg, only showing the first one after each bias change")

// Retail Trendline
show_retail_trend = input.bool(true, "Show Retail Trendline", group=grp_trend, tooltip="Auto-drawn diagonal trendline connecting recent swing highs or lows — shows the single most current trend retail traders are watching")
trend_swing_len   = input.int(10, "Trendline Swing Lookback", group=grp_trend, minval=3, maxval=30)

// Chart Patterns
show_patterns     = input.bool(true, "Show Double Top/Bottom", group=grp_pattern)
pattern_tolerance = input.float(0.15, "Double Top/Bottom Tolerance (x ATR)", group=grp_pattern, minval=0.05, maxval=0.5, tooltip="How close two swing highs/lows must be to count as a double top/bottom")
show_wedge         = input.bool(true, "Show Triangle/Wedge", group=grp_pattern)

// Kill Zones
show_killzones = input.bool(true, "Show Kill Zones", group=grp_kz, tooltip="Master toggle — turns all kill zones off at once regardless of the individual toggles below")
show_kz_asia   = input.bool(true, "Show Asian Kill Zone", group=grp_kz)
show_kz_ldno   = input.bool(true, "Show London Open Kill Zone", group=grp_kz)
show_kz_ny     = input.bool(true, "Show New York Kill Zone", group=grp_kz)
show_kz_ldnc   = input.bool(true, "Show London Close Kill Zone", group=grp_kz)
show_kz_labels = input.bool(true, "Show Kill Zone Labels", group=grp_kz)
show_kz_hilo   = input.bool(true, "Show Kill Zone High/Low Lines", group=grp_kz, tooltip="Marks the exact high and low of each kill zone session, spanning only that session's width — no extension afterward")
// Fixed session windows, matching Kill Zone convention exactly: fixed UTC-5 offset (no DST shift)

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

show_rates    = input.bool(false, "Show IPDA Direction", group=grp_rates, tooltip="Calculates base currency rate \u00f7 quote currency rate for the current chart symbol, using official central bank policy rates via TradingView's ECONOMICS: ticker feed. Rates update only when a central bank actually changes policy — not a daily-ticking number. Disabled by default since it adds 8 data requests.")
rates_pos     = input.string("Bottom Right", "Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=grp_rates)

// Colors — fully customizable
grp_colors    = "Colors"
in_col_bull    = input.color(#10D9A0, "Bullish", group=grp_colors, inline="bb")
in_col_bear    = input.color(#FF5C7A, "Bearish", group=grp_colors, inline="bb")
in_col_ob_bull = input.color(#5B7FFF, "OB Bullish", group=grp_colors, inline="ob")
in_col_ob_bear = input.color(#FFA655, "OB Bearish", group=grp_colors, inline="ob")
in_col_fvg_bull = input.color(#10D9A0, "FVG Bullish", group=grp_colors, inline="fvg")
in_col_fvg_bear = input.color(#FF5C7A, "FVG Bearish", group=grp_colors, inline="fvg")
in_col_dash_accent = input.color(#5B7FFF, "Dashboard Accent", group=grp_colors)
in_col_trendline = input.color(#4A5260, "Retail Trendline", group=grp_colors)

// ============================================================
// COLORS — derived from user-selected base colors above, refined jewel-tone defaults
// ============================================================
col_bull        = color.new(in_col_bull, 0)
col_bear        = color.new(in_col_bear, 0)
col_ob_bull     = color.new(in_col_ob_bull, 85)
col_ob_bear     = color.new(in_col_ob_bear, 85)
col_ob_bull_bdr = color.new(in_col_ob_bull, 30)
col_ob_bear_bdr = color.new(in_col_ob_bear, 30)
col_fvg_bull    = color.new(in_col_fvg_bull, 75)
col_fvg_bear    = color.new(in_col_fvg_bear, 75)
col_fvg_bull_bdr = color.new(in_col_fvg_bull, 10)
col_fvg_bear_bdr = color.new(in_col_fvg_bear, 10)
col_bsl         = color.new(#22D3EE, 0)
col_ssl         = color.new(#C9A66B, 0)
col_white       = color.new(#E6EDF3, 0)
col_dim         = color.new(#B0BEC5, 0)
col_dash_bg     = color.new(#0D1117, 8)
col_dash_border = color.new(in_col_dash_accent, 60)
col_trendline   = color.new(in_col_trendline, 10)
col_kz_asia     = color.new(#E91E63, 90)
col_kz_ldno     = color.new(#00BCD4, 90)
col_kz_ny       = color.new(#E4913D, 90)
col_kz_ldnc     = color.new(#2157F3, 90)
col_vm          = color.new(#FF3B30, 0)
col_liq_zone    = color.new(#A78BFA, 88)
col_liq_zone_bdr = color.new(#A78BFA, 45)
col_sweep_glow  = color.new(#FFD23F, 0)

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
        label.new(choch_up_mid, choch_up_level + atr14 * 0.3, "▲ CHoCH", color=color.new(#00B377,85), textcolor=color.new(#00B377,0), style=label.style_label_center, size=size.normal)
    if choch_dn and not na(choch_dn_from)
        line.new(choch_dn_from, choch_dn_level, bar_index, choch_dn_level, color=color.new(#D32F3D,0), style=line.style_dashed, width=2)
        choch_dn_mid = math.round((choch_dn_from + bar_index) / 2)
        label.new(choch_dn_mid, choch_dn_level - atr14 * 0.3, "▼ CHoCH", color=color.new(#D32F3D,85), textcolor=color.new(#D32F3D,0), style=label.style_label_center, size=size.normal)

// ============================================================
// ORDER BLOCKS — volumetric style. Split weighted by buy/sell volume proxy.
// No border, soft pastel fills, dashed extension line, volume label right of line.
// ============================================================
var float[] ob_bull_hi   = array.new_float(0)
var float[] ob_bull_lo   = array.new_float(0)
var float[] ob_bull_mid  = array.new_float(0)
var box[]   ob_bull_top  = array.new_box(0)
var box[]   ob_bull_bot  = array.new_box(0)
var line[]  ob_bull_line = array.new_line(0)
var label[] ob_bull_lbl  = array.new_label(0)
var bool[]  ob_bull_mit  = array.new_bool(0)

var float[] ob_bear_hi   = array.new_float(0)
var float[] ob_bear_lo   = array.new_float(0)
var float[] ob_bear_mid  = array.new_float(0)
var box[]   ob_bear_top  = array.new_box(0)
var box[]   ob_bear_bot  = array.new_box(0)
var line[]  ob_bear_line = array.new_line(0)
var label[] ob_bear_lbl  = array.new_label(0)
var bool[]  ob_bear_mit  = array.new_bool(0)

// Volume label format: "22.477K (63%)" — real candle volume in thousands + dominant %
ob_vol_fmt(int dom_pct, string side) =>
    other_pct = 100 - dom_pct
    side == "bull" ? str.tostring(dom_pct) + "% Buy  |  " + str.tostring(other_pct) + "% Sell" : str.tostring(dom_pct) + "% Sell  |  " + str.tostring(other_pct) + "% Buy"

// Weighted split: the dividing line is at buy% of the total range from lo
ob_split_price(float h, float l, int buy_pct) =>
    l + (h - l) * buy_pct / 100

// Soft pastel colors matching screenshot
col_ob_green  = color.new(#00695C, 65)   // deep teal-green for buy pressure zones
col_ob_red    = color.new(#B71C1C, 68)   // deep red for sell pressure zones
col_vol_line_bull = color.new(#00695C, 0)
col_vol_line_bear = color.new(#B71C1C, 0)

// On bullish CHoCH: last bearish candle before the move
if barstate.isconfirmed and choch_up and show_ob
    for i = 1 to struct_len * 3
        if close[i] < open[i]
            new_hi   = high[i]
            new_lo   = low[i]
            candle_vol = volume[i]
            buy_pct  = math.round((close[i] - new_lo) / (new_hi - new_lo > 0 ? new_hi - new_lo : 1) * 100)
            sell_pct = 100 - buy_pct
            split_px = ob_split_price(new_hi, new_lo, buy_pct)
            lbl_txt  = ob_vol_fmt(buy_pct, "bull")
            top_box  = box.new(bar_index - i, new_hi, bar_index + ob_extend, split_px, bgcolor=col_ob_red, border_width=0)
            bot_box  = box.new(bar_index - i, split_px, bar_index + ob_extend, new_lo, bgcolor=col_ob_green, border_width=0)
            ext_line = line.new(bar_index + ob_extend, new_hi, bar_index + ob_extend + 20, new_hi, color=col_vol_line_bull, style=line.style_dashed, width=1)
            vol_lbl  = label.new(bar_index + ob_extend + 21, new_hi, lbl_txt, color=color.new(#000000,100), textcolor=buy_pct >= 50 ? col_vol_line_bull : col_vol_line_bear, style=label.style_label_left, size=size.small)
            array.push(ob_bull_hi, new_hi)
            array.push(ob_bull_lo, new_lo)
            array.push(ob_bull_mid, split_px)
            array.push(ob_bull_top, top_box)
            array.push(ob_bull_bot, bot_box)
            array.push(ob_bull_line, ext_line)
            array.push(ob_bull_lbl, vol_lbl)
            array.push(ob_bull_mit, false)
            if array.size(ob_bull_top) > ob_max_count
                box.delete(array.shift(ob_bull_top))
                box.delete(array.shift(ob_bull_bot))
                line.delete(array.shift(ob_bull_line))
                label.delete(array.shift(ob_bull_lbl))
                array.shift(ob_bull_hi)
                array.shift(ob_bull_lo)
                array.shift(ob_bull_mid)
                array.shift(ob_bull_mit)
            break

// On bearish CHoCH: last bullish candle before the move
if barstate.isconfirmed and choch_dn and show_ob
    for i = 1 to struct_len * 3
        if close[i] > open[i]
            best_hi   = high[i]
            best_lo   = low[i]
            candle_vol2 = volume[i]
            sell_pct2 = math.round((best_hi - close[i]) / (best_hi - best_lo > 0 ? best_hi - best_lo : 1) * 100)
            buy_pct2  = 100 - sell_pct2
            // split_px2: sell zone dominates from top, split is at buy_pct2% from bottom
            split_px2 = ob_split_price(best_hi, best_lo, buy_pct2)
            lbl_txt2  = ob_vol_fmt(sell_pct2, "bear")
            top_box2  = box.new(bar_index - i, best_hi, bar_index + ob_extend, split_px2, bgcolor=col_ob_red, border_width=0)
            bot_box2  = box.new(bar_index - i, split_px2, bar_index + ob_extend, best_lo, bgcolor=col_ob_green, border_width=0)
            ext_line2 = line.new(bar_index + ob_extend, best_lo, bar_index + ob_extend + 20, best_lo, color=col_vol_line_bear, style=line.style_dashed, width=1)
            vol_lbl2  = label.new(bar_index + ob_extend + 21, best_lo, lbl_txt2, color=color.new(#000000,100), textcolor=sell_pct2 >= 50 ? col_vol_line_bear : col_vol_line_bull, style=label.style_label_left, size=size.small)
            array.push(ob_bear_hi, best_hi)
            array.push(ob_bear_lo, best_lo)
            array.push(ob_bear_mid, split_px2)
            array.push(ob_bear_top, top_box2)
            array.push(ob_bear_bot, bot_box2)
            array.push(ob_bear_line, ext_line2)
            array.push(ob_bear_lbl, vol_lbl2)
            array.push(ob_bear_mit, false)
            if array.size(ob_bear_top) > ob_max_count
                box.delete(array.shift(ob_bear_top))
                box.delete(array.shift(ob_bear_bot))
                line.delete(array.shift(ob_bear_line))
                label.delete(array.shift(ob_bear_lbl))
                array.shift(ob_bear_hi)
                array.shift(ob_bear_lo)
                array.shift(ob_bear_mid)
                array.shift(ob_bear_mit)
            break

// Extend boxes and dashed line every bar; flash mitigated on touch
bull_ob_mitigated_now = false
bear_ob_mitigated_now = false

if barstate.isconfirmed and array.size(ob_bull_top) > 0
    for k = array.size(ob_bull_top) - 1 to 0
        box.set_right(array.get(ob_bull_top, k), bar_index + ob_extend)
        box.set_right(array.get(ob_bull_bot, k), bar_index + ob_extend)
        line.set_x1(array.get(ob_bull_line, k), bar_index + ob_extend)
        line.set_x2(array.get(ob_bull_line, k), bar_index + ob_extend + 20)
        label.set_x(array.get(ob_bull_lbl, k), bar_index + ob_extend + 21)
        hi = array.get(ob_bull_hi, k)
        lo = array.get(ob_bull_lo, k)
        if low <= hi and low >= lo
            box.delete(array.get(ob_bull_top, k))
            box.delete(array.get(ob_bull_bot, k))
            line.delete(array.get(ob_bull_line, k))
            label.delete(array.get(ob_bull_lbl, k))
            array.remove(ob_bull_top, k)
            array.remove(ob_bull_bot, k)
            array.remove(ob_bull_line, k)
            array.remove(ob_bull_lbl, k)
            array.remove(ob_bull_hi, k)
            array.remove(ob_bull_lo, k)
            array.remove(ob_bull_mid, k)
            array.remove(ob_bull_mit, k)
            bull_ob_mitigated_now := true

if barstate.isconfirmed and array.size(ob_bear_top) > 0
    for k = array.size(ob_bear_top) - 1 to 0
        box.set_right(array.get(ob_bear_top, k), bar_index + ob_extend)
        box.set_right(array.get(ob_bear_bot, k), bar_index + ob_extend)
        line.set_x1(array.get(ob_bear_line, k), bar_index + ob_extend)
        line.set_x2(array.get(ob_bear_line, k), bar_index + ob_extend + 20)
        label.set_x(array.get(ob_bear_lbl, k), bar_index + ob_extend + 21)
        hi = array.get(ob_bear_hi, k)
        lo = array.get(ob_bear_lo, k)
        if high >= lo and high <= hi
            box.delete(array.get(ob_bear_top, k))
            box.delete(array.get(ob_bear_bot, k))
            line.delete(array.get(ob_bear_line, k))
            label.delete(array.get(ob_bear_lbl, k))
            array.remove(ob_bear_top, k)
            array.remove(ob_bear_bot, k)
            array.remove(ob_bear_line, k)
            array.remove(ob_bear_lbl, k)
            array.remove(ob_bear_hi, k)
            array.remove(ob_bear_lo, k)
            array.remove(ob_bear_mid, k)
            array.remove(ob_bear_mit, k)
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
        new_box = box.new(f_bar, f_hi, f_bar + imb_extend, f_lo, border_color=col_fvg_bull_bdr, bgcolor=col_fvg_bull, border_width=1, border_style=line.style_dotted, text="FVG", text_color=color.new(in_col_fvg_bull,10), text_size=size.tiny, text_halign=text.align_left, text_valign=text.align_top)
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
        new_box = box.new(bar_index - 2, f_hi, bar_index - 2 + imb_extend, f_lo, border_color=col_fvg_bear_bdr, bgcolor=col_fvg_bear, border_width=1, border_style=line.style_dotted, text="FVG", text_color=color.new(in_col_fvg_bear,10), text_size=size.tiny, text_halign=text.align_left, text_valign=text.align_top)
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
// LIQUIDITY SWEEPS — pre-sweep zone marks where resting liquidity sits at the
// most recent swing high/low; the moment it gets swept, a gold fish-hook
// highlight replaces it right at the exact wick. Only significant sweeps show:
// filtered by minimum size (vs tiny noise) and optionally to one per trend leg.
// ============================================================
sweep_ph = ta.pivothigh(high, sweep_swing_len, sweep_swing_len)
sweep_pl = ta.pivotlow(low, sweep_swing_len, sweep_swing_len)

var float sweep_top = na
var float sweep_btm = na
var int sweep_top_bar = na
var int sweep_btm_bar = na
var box liq_zone_top_box = na
var box liq_zone_btm_box = na

if show_sweeps and not na(sweep_ph)
    sweep_top := sweep_ph
    sweep_top_bar := bar_index - sweep_swing_len
    box.delete(liq_zone_top_box)
    liq_zone_top_box := box.new(sweep_top_bar, sweep_top + atr14 * 0.15, bar_index + 10, sweep_top - atr14 * 0.05, border_color=col_liq_zone_bdr, bgcolor=col_liq_zone, border_width=1, border_style=line.style_dashed, text="Liquidity", text_size=size.tiny, text_color=color.new(#A78BFA,20))

if show_sweeps and not na(sweep_pl)
    sweep_btm := sweep_pl
    sweep_btm_bar := bar_index - sweep_swing_len
    box.delete(liq_zone_btm_box)
    liq_zone_btm_box := box.new(sweep_btm_bar, sweep_btm + atr14 * 0.05, bar_index + 10, sweep_btm - atr14 * 0.15, border_color=col_liq_zone_bdr, bgcolor=col_liq_zone, border_width=1, border_style=line.style_dashed, text="Liquidity", text_size=size.tiny, text_color=color.new(#A78BFA,20))

if show_sweeps and barstate.isconfirmed and not na(liq_zone_top_box)
    box.set_right(liq_zone_top_box, bar_index + 10)
if show_sweeps and barstate.isconfirmed and not na(liq_zone_btm_box)
    box.set_right(liq_zone_btm_box, bar_index + 10)

sweep_min_size = atr14 * sweep_min_atr

// Wick-quality check — a clean sweep needs a real rejection: the wick piercing
// beyond the level should dominate the candle's range, and the body should close
// well back inside (not just barely), so a sloppy half-hearted poke doesn't count.
sweep_candle_range = high - low
sweep_up_wick_ratio = sweep_candle_range > 0 ? (high - math.max(open, close)) / sweep_candle_range : 0
sweep_dn_wick_ratio = sweep_candle_range > 0 ? (math.min(open, close) - low) / sweep_candle_range : 0
sweep_min_wick_ratio = 0.45

raw_swept_up   = show_sweeps and barstate.isconfirmed and not na(sweep_top) and high > sweep_top and (high - sweep_top) >= sweep_min_size and close <= sweep_top and sweep_up_wick_ratio >= sweep_min_wick_ratio
raw_swept_down = show_sweeps and barstate.isconfirmed and not na(sweep_btm) and low < sweep_btm and (sweep_btm - low) >= sweep_min_size and close >= sweep_btm and sweep_dn_wick_ratio >= sweep_min_wick_ratio

var int bias_at_last_sweep = -99
swept_up   = raw_swept_up and (not sweep_once_per_leg or struct_bias != bias_at_last_sweep)
swept_down = raw_swept_down and (not sweep_once_per_leg or struct_bias != bias_at_last_sweep)

if swept_up or swept_down
    bias_at_last_sweep := struct_bias

// Confirmation window — a sweep is only confirmed VALID once price does NOT
// close back inside the prior range within 2 bars. If it closes back inside
// within that window, it's marked INVALID and recolored gray instead of gold.
sweep_confirm_bars = 2
var label[] pending_sweep_lbl   = array.new_label(0)
var float[] pending_sweep_level = array.new_float(0)
var string[] pending_sweep_dir  = array.new_string(0)
var int[]   pending_sweep_bar   = array.new_int(0)

// Persistent last-sweep status, for the dashboard
var string last_sweep_status = "—"
var float  last_sweep_level  = na
var string last_sweep_dir2   = "—"

if swept_up
    box.delete(liq_zone_top_box)
    new_sweep_lbl  = label.new(bar_index, high, "🪝 SWEEP", color=color.new(#FFD23F,75), textcolor=col_sweep_glow, style=label.style_label_down, size=size.small)
    array.push(pending_sweep_lbl, new_sweep_lbl)
    array.push(pending_sweep_level, sweep_top)
    array.push(pending_sweep_dir, "UP")
    array.push(pending_sweep_bar, bar_index)
    last_sweep_status := "Pending"
    last_sweep_level := sweep_top
    last_sweep_dir2 := "UP"

if swept_down
    box.delete(liq_zone_btm_box)
    new_sweep_lbl  = label.new(bar_index, low, "🪝 SWEEP", color=color.new(#FFD23F,75), textcolor=col_sweep_glow, style=label.style_label_up, size=size.small)
    array.push(pending_sweep_lbl, new_sweep_lbl)
    array.push(pending_sweep_level, sweep_btm)
    array.push(pending_sweep_dir, "DOWN")
    array.push(pending_sweep_bar, bar_index)
    last_sweep_status := "Pending"
    last_sweep_level := sweep_btm
    last_sweep_dir2 := "DOWN"

// Resolve pending sweeps: within sweep_confirm_bars after the sweep, if a confirmed
// candle CLOSES back inside the prior range, mark INVALID (recolor gray). Once the
// confirmation window passes without that happening, it's left as VALID (gold).
col_sweep_invalid = color.new(#7D8590, 40)

if barstate.isconfirmed and array.size(pending_sweep_bar) > 0
    for k = array.size(pending_sweep_bar) - 1 to 0
        p_bar = array.get(pending_sweep_bar, k)
        p_dir = array.get(pending_sweep_dir, k)
        p_level = array.get(pending_sweep_level, k)
        bars_since = bar_index - p_bar
        if bars_since >= 1 and bars_since <= sweep_confirm_bars
            failed = p_dir == "UP" ? close > p_level : close < p_level
            if failed
                label.set_textcolor(array.get(pending_sweep_lbl, k), col_sweep_invalid)
                label.set_color(array.get(pending_sweep_lbl, k), color.new(#7D8590,80))
                label.set_text(array.get(pending_sweep_lbl, k), "🪝 SWEEP (invalid)")
                if p_level == last_sweep_level
                    last_sweep_status := "Invalid"
                array.remove(pending_sweep_lbl, k)
                array.remove(pending_sweep_level, k)
                array.remove(pending_sweep_dir, k)
                array.remove(pending_sweep_bar, k)
            else if bars_since == sweep_confirm_bars
                // Survived the full confirmation window without failing — stays valid (gold), stop tracking
                if p_level == last_sweep_level
                    last_sweep_status := "Valid"
                array.remove(pending_sweep_lbl, k)
                array.remove(pending_sweep_level, k)
                array.remove(pending_sweep_dir, k)
                array.remove(pending_sweep_bar, k)

// Highlight the exact sweeping candle itself with a gold background tint
bgcolor(show_sweeps and (swept_up or swept_down) ? color.new(#FFD23F, 80) : na, title="Sweep Candle Highlight")

// ============================================================
// RETAIL TRENDLINE — auto-drawn diagonal trendline connecting the two most
// recent swing highs (descending) or two most recent swing lows (ascending).
// Only ONE line is shown at a time — whichever pivot pair completed most
// recently is treated as the current trend retail traders are watching.
// Light dotted style, single persistent line (old one replaced by the new).
// ============================================================
trend_ph = ta.pivothigh(high, trend_swing_len, trend_swing_len)
trend_pl = ta.pivotlow(low, trend_swing_len, trend_swing_len)

var float trend_ph2 = na
var float trend_ph1 = na
var int   trend_ph2_bar = na
var int   trend_ph1_bar = na
var float trend_pl2 = na
var float trend_pl1 = na
var int   trend_pl2_bar = na
var int   trend_pl1_bar = na
var line  retail_trend_line = na
var string retail_trend_dir = "—"

if not na(trend_ph)
    trend_ph2 := trend_ph1
    trend_ph2_bar := trend_ph1_bar
    trend_ph1 := trend_ph
    trend_ph1_bar := bar_index - trend_swing_len
    if show_retail_trend and not na(trend_ph2) and trend_ph1 < trend_ph2
        line.delete(retail_trend_line)
        retail_trend_line := line.new(trend_ph2_bar, trend_ph2, trend_ph1_bar, trend_ph1, color=col_trendline, style=line.style_dotted, width=1, extend=extend.right)
        retail_trend_dir := "DOWN"

if not na(trend_pl)
    trend_pl2 := trend_pl1
    trend_pl2_bar := trend_pl1_bar
    trend_pl1 := trend_pl
    trend_pl1_bar := bar_index - trend_swing_len
    if show_retail_trend and not na(trend_pl2) and trend_pl1 > trend_pl2
        line.delete(retail_trend_line)
        retail_trend_line := line.new(trend_pl2_bar, trend_pl2, trend_pl1_bar, trend_pl1, color=col_trendline, style=line.style_dotted, width=1, extend=extend.right)
        retail_trend_dir := "UP"

// ============================================================
// CHART PATTERNS — Double Top/Bottom (two swing highs/lows within tolerance,
// with a clear move between them) and Triangle/Wedge (converging trendlines:
// descending highs + ascending lows narrowing toward each other).
// ============================================================
var string last_pattern = "—"
var box pattern_box = na
var line pattern_line_a = na
var line pattern_line_b = na

// Double Top — two recent swing highs at nearly the same level, with a real dip between them
if show_patterns and not na(trend_ph) and not na(trend_ph2) and not na(trend_ph1)
    htol = atr14 * pattern_tolerance
    if math.abs(trend_ph1 - trend_ph2) <= htol and not na(trend_pl1) and trend_pl1 < math.min(trend_ph1, trend_ph2) - htol
        last_pattern := "Double Top"
        box.delete(pattern_box)
        pattern_box := box.new(trend_ph2_bar, math.max(trend_ph1, trend_ph2) + atr14*0.1, bar_index, math.min(trend_ph1, trend_ph2), border_color=color.new(in_col_bear,40), bgcolor=color.new(in_col_bear,90), border_width=1, border_style=line.style_dashed, text="Double Top", text_size=size.tiny, text_color=color.new(in_col_bear,15))

// Double Bottom — two recent swing lows at nearly the same level, with a real rally between them
if show_patterns and not na(trend_pl) and not na(trend_pl2) and not na(trend_pl1)
    ltol = atr14 * pattern_tolerance
    if math.abs(trend_pl1 - trend_pl2) <= ltol and not na(trend_ph1) and trend_ph1 > math.max(trend_pl1, trend_pl2) + ltol
        last_pattern := "Double Bottom"
        box.delete(pattern_box)
        pattern_box := box.new(trend_pl2_bar, math.max(trend_pl1, trend_pl2), bar_index, math.min(trend_pl1, trend_pl2) - atr14*0.1, border_color=color.new(in_col_bull,40), bgcolor=color.new(in_col_bull,90), border_width=1, border_style=line.style_dashed, text="Double Bottom", text_size=size.tiny, text_color=color.new(in_col_bull,15))

// Triangle/Wedge — descending highs AND ascending lows converging toward each other
// (using the same two most recent pivots on each side as the trendline above)
if show_wedge and not na(trend_ph1) and not na(trend_ph2) and not na(trend_pl1) and not na(trend_pl2)
    highs_falling = trend_ph1 < trend_ph2
    lows_rising = trend_pl1 > trend_pl2
    if highs_falling and lows_rising
        last_pattern := "Triangle/Wedge"
        line.delete(pattern_line_a)
        line.delete(pattern_line_b)
        pattern_line_a := line.new(trend_ph2_bar, trend_ph2, trend_ph1_bar, trend_ph1, color=color.new(in_col_dash_accent,20), style=line.style_solid, width=2, extend=extend.right)
        pattern_line_b := line.new(trend_pl2_bar, trend_pl2, trend_pl1_bar, trend_pl1, color=color.new(in_col_dash_accent,20), style=line.style_solid, width=2, extend=extend.right)

pattern_display = last_pattern == "—" ? "—  None yet" : last_pattern
pattern_color = last_pattern == "Double Top" ? col_bear : last_pattern == "Double Bottom" ? col_bull : last_pattern == "Triangle/Wedge" ? color.new(in_col_dash_accent,0) : col_dim

// ============================================================
// KILL ZONES — Asian, London Open, New York, London Close
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

bgcolor(show_killzones and show_kz_asia and in_kz_asia ? col_kz_asia : na, title="Asian Kill Zone")
bgcolor(show_killzones and show_kz_ldno and in_kz_ldno ? col_kz_ldno : na, title="London Open Kill Zone")
bgcolor(show_killzones and show_kz_ny   and in_kz_ny   ? col_kz_ny   : na, title="New York Kill Zone")
bgcolor(show_killzones and show_kz_ldnc and in_kz_ldnc ? col_kz_ldnc : na, title="London Close Kill Zone")

// Centered label: anchor recenters to the midpoint of the active zone, y-position tracks the zone's running high
var label kz_asia_lbl = na
var int   kz_asia_start_bar = na
var float kz_asia_high = na
var float kz_asia_low = na
var line  kz_asia_hi_line = na
var line  kz_asia_lo_line = na
var label kz_ldno_lbl = na
var int   kz_ldno_start_bar = na
var float kz_ldno_high = na
var float kz_ldno_low = na
var line  kz_ldno_hi_line = na
var line  kz_ldno_lo_line = na
var label kz_ny_lbl = na
var int   kz_ny_start_bar = na
var float kz_ny_high = na
var float kz_ny_low = na
var line  kz_ny_hi_line = na
var line  kz_ny_lo_line = na
var label kz_ldnc_lbl = na
var int   kz_ldnc_start_bar = na
var float kz_ldnc_high = na
var float kz_ldnc_low = na
var line  kz_ldnc_hi_line = na
var line  kz_ldnc_lo_line = na

// High/low/start-bar tracking always runs (needed by labels, hi/lo lines, and
// sweep alerts regardless of which individual visual toggles are on). Only the
// LABEL drawing itself is gated by show_kz_labels + the per-zone toggle.
if in_kz_asia and not in_kz_asia[1]
    kz_asia_start_bar := bar_index
    kz_asia_high := high
    if show_killzones and show_kz_asia and show_kz_labels
        label.delete(kz_asia_lbl)
        kz_asia_lbl := label.new(bar_index, high, "Asian", color=color.new(#E91E63,100), textcolor=color.new(#E91E63,0), style=label.style_label_down, size=size.small)
if in_kz_asia and not na(kz_asia_start_bar)
    kz_asia_high := math.max(high, kz_asia_high)
    if show_killzones and show_kz_asia and show_kz_labels
        label.set_x(kz_asia_lbl, math.round((kz_asia_start_bar + bar_index) / 2))
        label.set_y(kz_asia_lbl, kz_asia_high)
if in_kz_ldno and not in_kz_ldno[1]
    kz_ldno_start_bar := bar_index
    kz_ldno_high := high
    if show_killzones and show_kz_ldno and show_kz_labels
        label.delete(kz_ldno_lbl)
        kz_ldno_lbl := label.new(bar_index, high, "London Open", color=color.new(#00BCD4,100), textcolor=color.new(#00BCD4,0), style=label.style_label_down, size=size.small)
if in_kz_ldno and not na(kz_ldno_start_bar)
    kz_ldno_high := math.max(high, kz_ldno_high)
    if show_killzones and show_kz_ldno and show_kz_labels
        label.set_x(kz_ldno_lbl, math.round((kz_ldno_start_bar + bar_index) / 2))
        label.set_y(kz_ldno_lbl, kz_ldno_high)
if in_kz_ny and not in_kz_ny[1]
    kz_ny_start_bar := bar_index
    kz_ny_high := high
    if show_killzones and show_kz_ny and show_kz_labels
        label.delete(kz_ny_lbl)
        kz_ny_lbl := label.new(bar_index, high, "New York", color=color.new(#E4913D,100), textcolor=color.new(#E4913D,0), style=label.style_label_down, size=size.small)
if in_kz_ny and not na(kz_ny_start_bar)
    kz_ny_high := math.max(high, kz_ny_high)
    if show_killzones and show_kz_ny and show_kz_labels
        label.set_x(kz_ny_lbl, math.round((kz_ny_start_bar + bar_index) / 2))
        label.set_y(kz_ny_lbl, kz_ny_high)
if in_kz_ldnc and not in_kz_ldnc[1]
    kz_ldnc_start_bar := bar_index
    kz_ldnc_high := high
    if show_killzones and show_kz_ldnc and show_kz_labels
        label.delete(kz_ldnc_lbl)
        kz_ldnc_lbl := label.new(bar_index, high, "London Close", color=color.new(#2157F3,100), textcolor=color.new(#2157F3,0), style=label.style_label_down, size=size.small)
if in_kz_ldnc and not na(kz_ldnc_start_bar)
    kz_ldnc_high := math.max(high, kz_ldnc_high)
    if show_killzones and show_kz_ldnc and show_kz_labels
        label.set_x(kz_ldnc_lbl, math.round((kz_ldnc_start_bar + bar_index) / 2))
        label.set_y(kz_ldnc_lbl, kz_ldnc_high)

// Kill zone high/low lines — span EXACTLY the session's width, start bar to end
// bar, no extension before or after. Drawn/updated live while the session is
// active, finalized the instant the session ends.
// Low tracking always runs (needed for sweep alerts regardless of visual toggle).
// Only the actual LINE drawing is gated by show_kz_hilo + the per-zone toggle.
if in_kz_asia and not in_kz_asia[1]
    kz_asia_low := low
if in_kz_asia
    kz_asia_low := math.min(low, kz_asia_low)
    if show_killzones and show_kz_asia and show_kz_hilo
        line.delete(kz_asia_hi_line)
        line.delete(kz_asia_lo_line)
        kz_asia_hi_line := line.new(kz_asia_start_bar, kz_asia_high, bar_index, kz_asia_high, color=color.new(#000000,0), width=1)
        kz_asia_lo_line := line.new(kz_asia_start_bar, kz_asia_low, bar_index, kz_asia_low, color=color.new(#000000,0), width=1)
if in_kz_ldno and not in_kz_ldno[1]
    kz_ldno_low := low
if in_kz_ldno
    kz_ldno_low := math.min(low, kz_ldno_low)
    if show_killzones and show_kz_ldno and show_kz_hilo
        line.delete(kz_ldno_hi_line)
        line.delete(kz_ldno_lo_line)
        kz_ldno_hi_line := line.new(kz_ldno_start_bar, kz_ldno_high, bar_index, kz_ldno_high, color=color.new(#000000,0), width=1)
        kz_ldno_lo_line := line.new(kz_ldno_start_bar, kz_ldno_low, bar_index, kz_ldno_low, color=color.new(#000000,0), width=1)
if in_kz_ny and not in_kz_ny[1]
    kz_ny_low := low
if in_kz_ny
    kz_ny_low := math.min(low, kz_ny_low)
    if show_killzones and show_kz_ny and show_kz_hilo
        line.delete(kz_ny_hi_line)
        line.delete(kz_ny_lo_line)
        kz_ny_hi_line := line.new(kz_ny_start_bar, kz_ny_high, bar_index, kz_ny_high, color=color.new(#000000,0), width=1)
        kz_ny_lo_line := line.new(kz_ny_start_bar, kz_ny_low, bar_index, kz_ny_low, color=color.new(#000000,0), width=1)
if in_kz_ldnc and not in_kz_ldnc[1]
    kz_ldnc_low := low
if in_kz_ldnc
    kz_ldnc_low := math.min(low, kz_ldnc_low)
    if show_killzones and show_kz_ldnc and show_kz_hilo
        line.delete(kz_ldnc_hi_line)
        line.delete(kz_ldnc_lo_line)
        kz_ldnc_hi_line := line.new(kz_ldnc_start_bar, kz_ldnc_high, bar_index, kz_ldnc_high, color=color.new(#000000,0), width=1)
        kz_ldnc_lo_line := line.new(kz_ldnc_start_bar, kz_ldnc_low, bar_index, kz_ldnc_low, color=color.new(#000000,0), width=1)

// Kill zone high/low SWEEP alerts — fires once, the instant price trades through
// the FINAL recorded high or low of a session, after that session has ended.
// Each level can only trigger its alert once (reset only when a new session of
// that same zone begins), so it doesn't re-fire on every bar beyond the level.
var bool kz_asia_hi_swept = false
var bool kz_asia_lo_swept = false
var bool kz_ldno_hi_swept = false
var bool kz_ldno_lo_swept = false
var bool kz_ny_hi_swept = false
var bool kz_ny_lo_swept = false
var bool kz_ldnc_hi_swept = false
var bool kz_ldnc_lo_swept = false

if in_kz_asia and not in_kz_asia[1]
    kz_asia_hi_swept := false
    kz_asia_lo_swept := false
if in_kz_ldno and not in_kz_ldno[1]
    kz_ldno_hi_swept := false
    kz_ldno_lo_swept := false
if in_kz_ny and not in_kz_ny[1]
    kz_ny_hi_swept := false
    kz_ny_lo_swept := false
if in_kz_ldnc and not in_kz_ldnc[1]
    kz_ldnc_hi_swept := false
    kz_ldnc_lo_swept := false

kz_asia_hi_swept_now = not in_kz_asia and not na(kz_asia_high) and not kz_asia_hi_swept and high > kz_asia_high
kz_asia_lo_swept_now = not in_kz_asia and not na(kz_asia_low) and not kz_asia_lo_swept and low < kz_asia_low
kz_ldno_hi_swept_now = not in_kz_ldno and not na(kz_ldno_high) and not kz_ldno_hi_swept and high > kz_ldno_high
kz_ldno_lo_swept_now = not in_kz_ldno and not na(kz_ldno_low) and not kz_ldno_lo_swept and low < kz_ldno_low
kz_ny_hi_swept_now = not in_kz_ny and not na(kz_ny_high) and not kz_ny_hi_swept and high > kz_ny_high
kz_ny_lo_swept_now = not in_kz_ny and not na(kz_ny_low) and not kz_ny_lo_swept and low < kz_ny_low
kz_ldnc_hi_swept_now = not in_kz_ldnc and not na(kz_ldnc_high) and not kz_ldnc_hi_swept and high > kz_ldnc_high
kz_ldnc_lo_swept_now = not in_kz_ldnc and not na(kz_ldnc_low) and not kz_ldnc_lo_swept and low < kz_ldnc_low

if kz_asia_hi_swept_now
    kz_asia_hi_swept := true
if kz_asia_lo_swept_now
    kz_asia_lo_swept := true
if kz_ldno_hi_swept_now
    kz_ldno_hi_swept := true
if kz_ldno_lo_swept_now
    kz_ldno_lo_swept := true
if kz_ny_hi_swept_now
    kz_ny_hi_swept := true
if kz_ny_lo_swept_now
    kz_ny_lo_swept := true
if kz_ldnc_hi_swept_now
    kz_ldnc_hi_swept := true
if kz_ldnc_lo_swept_now
    kz_ldnc_lo_swept := true

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
// NEAREST OB / FVG — for the dashboard. Scans all currently active (unmitigated/
// unfilled) zones on both sides and finds whichever single zone sits closest
// to current price, regardless of bull/bear side.
// ============================================================
var float nearest_ob_dist = na
var float nearest_ob_hi = na
var float nearest_ob_lo = na
var float nearest_ob_mid = na
var string nearest_ob_side = "—"
nearest_ob_dist := na
nearest_ob_hi := na
nearest_ob_lo := na
nearest_ob_mid := na
nearest_ob_side := "—"

if array.size(ob_bull_hi) > 0
    for k = 0 to array.size(ob_bull_hi) - 1
        o_hi = array.get(ob_bull_hi, k)
        o_lo = array.get(ob_bull_lo, k)
        d = close >= o_lo and close <= o_hi ? 0.0 : math.min(math.abs(close - o_hi), math.abs(close - o_lo))
        if na(nearest_ob_dist) or d < nearest_ob_dist
            nearest_ob_dist := d
            nearest_ob_hi := o_hi
            nearest_ob_lo := o_lo
            nearest_ob_mid := array.get(ob_bull_mid, k)
            nearest_ob_side := "Bull"

if array.size(ob_bear_hi) > 0
    for k = 0 to array.size(ob_bear_hi) - 1
        o_hi2 = array.get(ob_bear_hi, k)
        o_lo2 = array.get(ob_bear_lo, k)
        d2 = close >= o_lo2 and close <= o_hi2 ? 0.0 : math.min(math.abs(close - o_hi2), math.abs(close - o_lo2))
        if na(nearest_ob_dist) or d2 < nearest_ob_dist
            nearest_ob_dist := d2
            nearest_ob_hi := o_hi2
            nearest_ob_lo := o_lo2
            nearest_ob_mid := array.get(ob_bear_mid, k)
            nearest_ob_side := "Bear"

// Derive buy/sell pressure % from the stored split level
nearest_ob_raw_pct  = na(nearest_ob_hi) or na(nearest_ob_lo) or nearest_ob_hi == nearest_ob_lo ? 50 : math.round((nearest_ob_mid - nearest_ob_lo) / (nearest_ob_hi - nearest_ob_lo) * 100)
nearest_ob_buy_pct  = nearest_ob_side == "Bear" ? nearest_ob_raw_pct : nearest_ob_raw_pct
nearest_ob_sell_pct = 100 - nearest_ob_raw_pct
nearest_ob_pressure = na(nearest_ob_side) or nearest_ob_side == "—" ? "—  None active" : nearest_ob_side == "Bull" ? str.tostring(nearest_ob_raw_pct) + "% Buy  |  " + str.tostring(nearest_ob_sell_pct) + "% Sell" : str.tostring(nearest_ob_sell_pct) + "% Sell  |  " + str.tostring(nearest_ob_raw_pct) + "% Buy"
nearest_ob_pressure_col = nearest_ob_side == "Bull" ? (nearest_ob_raw_pct >= 50 ? col_bull : col_bear) : (nearest_ob_sell_pct >= 50 ? col_bear : col_bull)

var float nearest_fvg_dist = na
var float nearest_fvg_hi = na
var float nearest_fvg_lo = na
var string nearest_fvg_side = "—"
nearest_fvg_dist := na
nearest_fvg_hi := na
nearest_fvg_lo := na
nearest_fvg_side := "—"

if array.size(fvg_bull_hi) > 0
    for k = 0 to array.size(fvg_bull_hi) - 1
        if not array.get(fvg_bull_filled, k)
            f_hi3 = array.get(fvg_bull_hi, k)
            f_lo3 = array.get(fvg_bull_lo, k)
            d3 = close >= f_lo3 and close <= f_hi3 ? 0.0 : math.min(math.abs(close - f_hi3), math.abs(close - f_lo3))
            if na(nearest_fvg_dist) or d3 < nearest_fvg_dist
                nearest_fvg_dist := d3
                nearest_fvg_hi := f_hi3
                nearest_fvg_lo := f_lo3
                nearest_fvg_side := "Bull"

if array.size(fvg_bear_hi) > 0
    for k = 0 to array.size(fvg_bear_hi) - 1
        if not array.get(fvg_bear_filled, k)
            f_hi4 = array.get(fvg_bear_hi, k)
            f_lo4 = array.get(fvg_bear_lo, k)
            d4 = close >= f_lo4 and close <= f_hi4 ? 0.0 : math.min(math.abs(close - f_hi4), math.abs(close - f_lo4))
            if na(nearest_fvg_dist) or d4 < nearest_fvg_dist
                nearest_fvg_dist := d4
                nearest_fvg_hi := f_hi4
                nearest_fvg_lo := f_lo4
                nearest_fvg_side := "Bear"

// ============================================================
// TRENDLINE DISTANCE — how far current price sits from the retail trendline,
// in both price and percentage terms.
// ============================================================
trendline_dist = na(retail_trend_line) ? na : math.abs(close - line.get_price(retail_trend_line, bar_index))
trendline_dist_pct = na(trendline_dist) ? na : math.round(trendline_dist / close * 10000) / 100

// ============================================================
// INTEREST RATES — official central bank policy rates via TradingView's
// ECONOMICS: ticker feed. Each rate only updates when that central bank
// actually changes policy at a meeting — this is NOT a daily-ticking number,
// it reflects the current official rate and when it last moved.
// Direction = comparing today's rate to its value 30 days ago (one full
// monthly bar back), since meetings are infrequent and daily comparison
// would show "Hold" almost always between meetings anyway.
// ============================================================
// Each rate persists its last known good value if a fetch ever genuinely
// returns na (a real data gap/outage) — this does NOT override a real
// reported rate of 0%, since 0% is a valid value, not a gap. It only
// protects against the feed temporarily failing to return anything at all.
var float rate_usd_last = na
var float rate_eur_last = na
var float rate_gbp_last = na
var float rate_jpy_last = na
var float rate_aud_last = na
var float rate_nzd_last = na
var float rate_cad_last = na
var float rate_chf_last = na

rate_usd_raw = show_rates ? request.security("ECONOMICS:USINTR", "D", close, lookahead=barmerge.lookahead_off) : na
rate_eur_raw = show_rates ? request.security("ECONOMICS:EUINTR", "D", close, lookahead=barmerge.lookahead_off) : na
rate_gbp_raw = show_rates ? request.security("ECONOMICS:GBINTR", "D", close, lookahead=barmerge.lookahead_off) : na
rate_jpy_raw = show_rates ? request.security("ECONOMICS:JPINTR", "D", close, lookahead=barmerge.lookahead_off) : na
rate_aud_raw = show_rates ? request.security("ECONOMICS:AUINTR", "D", close, lookahead=barmerge.lookahead_off) : na
rate_nzd_raw = show_rates ? request.security("ECONOMICS:NZINTR", "D", close, lookahead=barmerge.lookahead_off) : na
rate_cad_raw = show_rates ? request.security("ECONOMICS:CAINTR", "D", close, lookahead=barmerge.lookahead_off) : na
rate_chf_raw = show_rates ? request.security("ECONOMICS:CHINTR", "D", close, lookahead=barmerge.lookahead_off) : na

if not na(rate_usd_raw)
    rate_usd_last := rate_usd_raw
if not na(rate_eur_raw)
    rate_eur_last := rate_eur_raw
if not na(rate_gbp_raw)
    rate_gbp_last := rate_gbp_raw
if not na(rate_jpy_raw)
    rate_jpy_last := rate_jpy_raw
if not na(rate_aud_raw)
    rate_aud_last := rate_aud_raw
if not na(rate_nzd_raw)
    rate_nzd_last := rate_nzd_raw
if not na(rate_cad_raw)
    rate_cad_last := rate_cad_raw
if not na(rate_chf_raw)
    rate_chf_last := rate_chf_raw

rate_usd = rate_usd_last
rate_eur = rate_eur_last
rate_gbp = rate_gbp_last
rate_jpy = rate_jpy_last
rate_aud = rate_aud_last
rate_nzd = rate_nzd_last
rate_cad = rate_cad_last
rate_chf = rate_chf_last

// ============================================================
// IPDA DIRECTION — base currency rate / quote currency rate, auto-detected
// from the chart's symbol (syminfo.basecurrency / syminfo.currency).
// Ratio > 1 = Bullish, < 1 = Bearish, exactly 1 = Neutral.
// ============================================================
get_rate_by_code(string code) =>
    code == "USD" ? rate_usd : code == "EUR" ? rate_eur : code == "GBP" ? rate_gbp : code == "JPY" ? rate_jpy : code == "AUD" ? rate_aud : code == "NZD" ? rate_nzd : code == "CAD" ? rate_cad : code == "CHF" ? rate_chf : na

ipda_base_code = syminfo.basecurrency
ipda_quote_code = syminfo.currency
ipda_base_rate = get_rate_by_code(ipda_base_code)
ipda_quote_rate = get_rate_by_code(ipda_quote_code)
ipda_ratio = (na(ipda_base_rate) or na(ipda_quote_rate) or ipda_quote_rate == 0) ? na : ipda_base_rate / ipda_quote_rate
ipda_bias = na(ipda_ratio) ? "—" : ipda_ratio > 1 ? "Bullish" : ipda_ratio < 1 ? "Bearish" : "Neutral"
ipda_color = ipda_bias == "Bullish" ? col_bull : ipda_bias == "Bearish" ? col_bear : col_dim

// ============================================================
// MULTI-TIMEFRAME BIAS — same CHoCH-based struct_bias logic, pulled via
// request.security() at each timeframe. Shows Bullish/Bearish/Neutral
// for 1D, 4H, 1H, 15M, and 1M in the dashboard.
// ============================================================
bias_1d  = request.security(syminfo.tickerid, "D",  struct_bias, lookahead=barmerge.lookahead_off)
bias_4h  = request.security(syminfo.tickerid, "240", struct_bias, lookahead=barmerge.lookahead_off)
bias_1h  = request.security(syminfo.tickerid, "60",  struct_bias, lookahead=barmerge.lookahead_off)
bias_15m = request.security(syminfo.tickerid, "15",  struct_bias, lookahead=barmerge.lookahead_off)
bias_1m  = request.security(syminfo.tickerid, "1",   struct_bias, lookahead=barmerge.lookahead_off)

mtf_bias_str(int b) =>
    b == 1 ? "▲ Bullish" : b == -1 ? "▼ Bearish" : "— Neutral"

mtf_bias_col(int b) =>
    b == 1 ? col_bull : b == -1 ? col_bear : col_dim


if show_dash and barstate.islast
    tpos = dash_pos == "Top Right" ? position.top_right : dash_pos == "Top Left" ? position.top_left : dash_pos == "Bottom Right" ? position.bottom_right : position.bottom_left
    var table t = table.new(tpos, 2, 12, bgcolor=col_dash_bg, border_color=col_dash_border, border_width=2, frame_color=col_dash_border, frame_width=3)
    row_shade = color.new(#FFFFFF, 97)
    table.cell(t, 0, 0, "JTA",   text_color=col_sweep_glow, text_size=size.large,  bgcolor=color.new(in_col_dash_accent,75), text_halign=text.align_center)
    table.cell(t, 1, 0, "SMC PRO", text_color=col_white, text_size=size.normal, bgcolor=color.new(in_col_dash_accent,75), text_halign=text.align_center)
    table.cell(t, 0, 1, "📅  DATE / TIME (NY)", text_color=col_dim, text_size=size.tiny, bgcolor=row_shade)
    table.cell(t, 1, 1, current_dt_str, text_color=col_white, text_size=size.tiny, bgcolor=row_shade)
    table.cell(t, 0, 2, "🕒  KILL ZONE", text_color=col_dim, text_size=size.normal)
    table.cell(t, 1, 2, kill_zone_display, text_color=approaching_ny_kz ? color.new(#FF9800,0) : active_kz_str == "None" ? col_dim : color.new(#FFEB3B,0), text_size=size.normal)
    table.cell(t, 0, 3, "ACTIVE OBs", text_color=col_dim, text_size=size.small, bgcolor=row_shade)
    table.cell(t, 1, 3, "🔵 " + str.tostring(array.size(ob_bull_top)) + "   🟠 " + str.tostring(array.size(ob_bear_top)), text_color=col_white, text_size=size.small, bgcolor=row_shade)
    table.cell(t, 0, 4, "OB STRENGTH", text_color=col_dim, text_size=size.small)
    table.cell(t, 1, 4, nearest_ob_pressure, text_color=nearest_ob_pressure_col, text_size=size.small)
    table.cell(t, 0, 5, "MTF BIAS", text_color=col_white, text_size=size.small, bgcolor=color.new(in_col_dash_accent,85), text_halign=text.align_center)
    table.cell(t, 1, 5, "──────────", text_color=col_dim, text_size=size.small, bgcolor=color.new(in_col_dash_accent,85), text_halign=text.align_center)
    table.cell(t, 0, 6, "1D", text_color=col_dim, text_size=size.small)
    table.cell(t, 1, 6, mtf_bias_str(bias_1d), text_color=mtf_bias_col(bias_1d), text_size=size.small)
    table.cell(t, 0, 7, "4H", text_color=col_dim, text_size=size.small, bgcolor=row_shade)
    table.cell(t, 1, 7, mtf_bias_str(bias_4h), text_color=mtf_bias_col(bias_4h), text_size=size.small, bgcolor=row_shade)
    table.cell(t, 0, 8, "1H", text_color=col_dim, text_size=size.small)
    table.cell(t, 1, 8, mtf_bias_str(bias_1h), text_color=mtf_bias_col(bias_1h), text_size=size.small)
    table.cell(t, 0, 9, "15M", text_color=col_dim, text_size=size.small, bgcolor=row_shade)
    table.cell(t, 1, 9, mtf_bias_str(bias_15m), text_color=mtf_bias_col(bias_15m), text_size=size.small, bgcolor=row_shade)
    table.cell(t, 0, 10, "1M", text_color=col_dim, text_size=size.small)
    table.cell(t, 1, 10, mtf_bias_str(bias_1m), text_color=mtf_bias_col(bias_1m), text_size=size.small)
    table.cell(t, 0, 11, "JTA SMC Pro", text_color=col_dim, text_size=size.tiny, text_halign=text.align_left, bgcolor=color.new(in_col_dash_accent,85))
    table.cell(t, 1, 11, syminfo.ticker, text_color=col_dim, text_size=size.tiny, text_halign=text.align_right, bgcolor=color.new(in_col_dash_accent,85))

// ============================================================
// IPDA DIRECTION PANEL — currency rates fetched silently in the background
// (used internally for the IPDA calculation), only the IPDA result itself
// is shown on chart, highlighted with a bias-colored background.
// ============================================================
if show_rates and barstate.islast
    rtpos = rates_pos == "Top Right" ? position.top_right : rates_pos == "Top Left" ? position.top_left : rates_pos == "Bottom Right" ? position.bottom_right : position.bottom_left
    var table rt = table.new(rtpos, 2, 2, bgcolor=col_dash_bg, border_color=col_dash_border, border_width=2, frame_color=col_dash_border, frame_width=3)
    table.cell(rt, 0, 0, "IPDA DIRECTION", text_color=col_white, text_size=size.normal, bgcolor=color.new(in_col_dash_accent,75), text_halign=text.align_center)
    table.cell(rt, 1, 0, "(Automatically Calculated)", text_color=col_white, text_size=size.tiny, bgcolor=color.new(in_col_dash_accent,75), text_halign=text.align_center)
    ipda_bg = ipda_bias == "Bullish" ? color.new(in_col_bull, 80) : ipda_bias == "Bearish" ? color.new(in_col_bear, 80) : color.new(#7D8590, 85)
    table.cell(rt, 0, 1, ipda_base_code + "/" + ipda_quote_code, text_color=col_white, text_size=size.normal, bgcolor=ipda_bg)
    table.cell(rt, 1, 1, ipda_bias, text_color=ipda_color, text_size=size.large, bgcolor=ipda_bg)

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

// --- Order Block Mitigation ---
alertcondition(bull_ob_mitigated_now, title="JTA SMC Pro — Bullish OB Mitigated", message="JTA SMC Pro: Bullish Order Block mitigated on {{ticker}} @ {{close}}")
alertcondition(bear_ob_mitigated_now, title="JTA SMC Pro — Bearish OB Mitigated", message="JTA SMC Pro: Bearish Order Block mitigated on {{ticker}} @ {{close}}")

// --- Fair Value Gap Formation ---
alertcondition(bull_fvg_valid, title="JTA SMC Pro — Bullish FVG Formed", message="JTA SMC Pro: Bullish FVG formed on {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(bear_fvg_valid, title="JTA SMC Pro — Bearish FVG Formed", message="JTA SMC Pro: Bearish FVG formed on {{ticker}} ({{interval}}) @ {{close}}")

// --- Liquidity Sweeps ---
alertcondition(swept_up, title="JTA SMC Pro — Buyside Liquidity Swept", message="JTA SMC Pro: Buyside liquidity swept on {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(swept_down, title="JTA SMC Pro — Sellside Liquidity Swept", message="JTA SMC Pro: Sellside liquidity swept on {{ticker}} ({{interval}}) @ {{close}}")

// --- Kill Zone High/Low Swept ---
alertcondition(kz_asia_hi_swept_now, title="JTA SMC Pro — Asian KZ High Swept", message="JTA SMC Pro: Asian Kill Zone high swept on {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(kz_asia_lo_swept_now, title="JTA SMC Pro — Asian KZ Low Swept", message="JTA SMC Pro: Asian Kill Zone low swept on {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(kz_ldno_hi_swept_now, title="JTA SMC Pro — London Open KZ High Swept", message="JTA SMC Pro: London Open Kill Zone high swept on {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(kz_ldno_lo_swept_now, title="JTA SMC Pro — London Open KZ Low Swept", message="JTA SMC Pro: London Open Kill Zone low swept on {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(kz_ny_hi_swept_now, title="JTA SMC Pro — New York KZ High Swept", message="JTA SMC Pro: New York Kill Zone high swept on {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(kz_ny_lo_swept_now, title="JTA SMC Pro — New York KZ Low Swept", message="JTA SMC Pro: New York Kill Zone low swept on {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(kz_ldnc_hi_swept_now, title="JTA SMC Pro — London Close KZ High Swept", message="JTA SMC Pro: London Close Kill Zone high swept on {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(kz_ldnc_lo_swept_now, title="JTA SMC Pro — London Close KZ Low Swept", message="JTA SMC Pro: London Close Kill Zone low swept on {{ticker}} ({{interval}}) @ {{close}}")
````
