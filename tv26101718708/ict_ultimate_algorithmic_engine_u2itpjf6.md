# ICT Ultimate Algorithmic Engine

- url: https://www.tradingview.com/script/u2ItPJf6-ICT-Ultimate-Algorithmic-Engine/
- type: indicator
- pine_id: PUB;d4384fb107fe467b9adef41210ef3854
- version: 1.0

## Description

This script, the ICT Ultimate Algorithmic Engine, is a comprehensive, all-in-one suite designed to automatically track and display the most critical time-based and price-based concepts taught by ICT (Inner Circle Trader) directly on your TradingView chart.

Since ICT emphasizes Time and Price (with Time coming first), the script is heavily structured around specific New York (EST) time windows and algorithmic delivery cycles.

Here is a breakdown of the 7 core engines running inside this script:

1. Killzones & Sessions Engine
The script paints custom background colors to highlight the major algorithmic trading windows throughout the day:

Asian Session (20:00 - 00:00 EST): Purple background.
London Killzone (02:00 - 05:00 EST): Blue background.
New York AM Killzone (07:00 - 10:00 EST): Orange background.
London Close (11:00 - 13:00 EST): Red background.
2. Algorithmic Macros
ICT teaches that specific 20-minute to 40-minute "macro" windows exist where the algorithm aggressively hunts liquidity or seeks fair value. The script explicitly highlights these macros (e.g., 08:30-09:00, 09:50-10:10, 10:50-11:10) with distinct background shading so you know exactly when volatility injections are scheduled.

3. True Opens (Midnight & 08:30 EST)
The algorithm uses daily true opens as its equilibrium to determine Premium and Discount.

It automatically plots a dashed Midnight Open line and an 08:30 AM Open line every single day. If price is above these lines, you are in a premium (favorable for sells); if below, a discount (favorable for buys).
4. Silver Bullet Tracker
This is a fully automated structural scanner for the ICT Silver Bullet setups.

It tracks the highest high and lowest low preceding the 3 Silver Bullet hours (London 03:00-04:00, NY AM 10:00-11:00, NY PM 14:00-15:00).
It draws red and green target lines representing the Buy-Side Liquidity (BSL) and Sell-Side Liquidity (SSL) targets for that specific hour.
Once the price touches one of these targets during the Silver Bullet hour, it actively labels it as BSL/SSL Swept.
5. Judas Swing & Market Structure Shift (MSS)
Judas Swing: The script tracks the high and low established during the Opening Ranges (00:00-01:00 for London, 08:30-09:30 for NY). If price manipulates above or below these boundaries and violently rejects, it prints a "Judas Swing" label, catching the classic algorithmic trap.
MSS with Displacement: It identifies Market Structure Shifts (MSS) but strictly filters them. It will only label an MSS if the candle breaks a recent swing high/low with displacement (the candle body size must be larger than 1.5x the ATR) AND leaves behind a Fair Value Gap.
6. Dynamic PD Arrays (Smart Money Concepts)
The script continuously scans for and draws institutional reference points:

Fair Value Gaps (FVGs): Draws bullish (BISI) and bearish (SIBI) gaps.
Inversion Feature: If a candle closes completely through an active FVG, the script automatically changes its color and converts it into an Inversion FVG (IFVG).
Order Blocks & Breakers: Draws standard +OB and -OBs.
Breaker Feature: If an Order Block was responsible for sweeping liquidity and is subsequently broken by price, it converts the Order Block into a Mitigation Block (MB) or a Breaker Block (BRK).
Volume Imbalances (VI): Highlights gaps between candle bodies (where only wicks overlap) in purple, automatically fading them out once they are mitigated.
Rejection Blocks: Identifies and highlights massive wicks (longer than 2x the body) acting as liquidity sponges.
7. Performance Cleanup (Garbage Collector)
Because TradingView limits users to 500 boxes and lines, the script has a built-in memory management system (the DYNAMIC DRAWING CLEANUP section at the bottom). It restricts the arrays to only hold the 100 most recent FVGs, Order Blocks, and Volume Imbalances, gracefully deleting the oldest ones to ensure the script never crashes or lags your chart.

## Source Code

````pine
//@version=6
indicator("ICT Ultimate Algorithmic Engine", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ========================================================================= //
// ========================== INPUT GROUPS ================================= //
// ========================================================================= //

grp_sessions = "1. Killzones & Sessions"
show_asia = input.bool(true, "Show Asian Session (20:00 - 00:00 EST)", group=grp_sessions)
show_london = input.bool(true, "Show London Killzone (02:00 - 05:00 EST)", group=grp_sessions)
show_ny_am = input.bool(true, "Show NY AM Killzone (07:00 - 10:00 EST)", group=grp_sessions)
show_london_close = input.bool(true, "Show London Close (11:00 - 13:00 EST)", group=grp_sessions)

grp_macros = "2. Algorithmic Macros"
show_macros = input.bool(true, "Show Macro Windows", group=grp_macros)
macro_color = input.color(color.new(color.blue, 92), "Macro Highlight Color", group=grp_macros)

grp_opens = "3. Midnight & 08:30 True Opens"
show_opens = input.bool(true, "Show True Opens (Midnight & 08:30)", group=grp_opens)
col_midnight = input.color(color.blue, "Midnight Open Color", group=grp_opens)
col_ny_open = input.color(color.orange, "08:30 Open Color", group=grp_opens)

grp_sb = "4. Silver Bullet Tracker"
show_sb = input.bool(true, "Show Silver Bullet Sessions", group=grp_sb)
col_sb_london = input.color(color.new(color.silver, 85), "London SB (03:00-04:00)", group=grp_sb)
col_sb_ny_am = input.color(color.new(#FFD700, 85), "NY AM SB (10:00-11:00)", group=grp_sb)
col_sb_ny_pm = input.color(color.new(color.teal, 85), "NY PM SB (14:00-15:00)", group=grp_sb)

grp_dr = "5. Dealing Range & PD Arrays"
show_dr = input.bool(true, "Show Dealing Range Equilibrium", group=grp_dr)
dr_pivot = input.int(20, "Dealing Range Swing Lookback", minval=5, group=grp_dr)
show_ob = input.bool(true, "Show Order Blocks (+OB/-OB)", group=grp_dr)
show_breaker = input.bool(true, "Show Breaker Blocks (+BRK/-BRK)", group=grp_dr)
show_fvg = input.bool(true, "Show FVGs (BISI/SIBI)", group=grp_dr)
show_vi = input.bool(true, "Show Volume Imbalances (VI)", group=grp_dr)
show_rej = input.bool(true, "Show Rejection Blocks", group=grp_dr)

grp_judas = "6. Judas Swing & MSS"
show_judas = input.bool(true, "Show Judas Swing Labels", group=grp_judas)
show_mss = input.bool(true, "Show MSS with Displacement", group=grp_judas)
disp_mult = input.float(1.5, "Displacement ATR Multiplier", minval=0.5, step=0.1, group=grp_judas)

// Colors for PD Arrays
col_bisi = color.new(color.green, 85)
col_sibi = color.new(color.red, 85)
col_ob_bull = color.new(color.blue, 80)
col_ob_bear = color.new(color.fuchsia, 80)
col_brk_bull = color.new(color.teal, 70)
col_brk_bear = color.new(color.maroon, 70)
col_vi = color.new(color.purple, 75)
col_rej = color.new(color.gray, 80)

// ========================================================================= //
// ============================= TYPES & ARRAYS ============================ //
// ========================================================================= //

type FVG_Data
    box b
    line ce
    bool is_bull
    bool is_inv
    float top
    float bot

type OB_Data
    box b
    bool is_bull
    bool is_breaker
    float top
    float bot
    bool swept_liq

type VI_Data
    box b
    bool is_bull
    float top
    float bot
    bool mitigated

type SBSession
    box bg_box
    line target_high
    line target_low
    bool high_swept
    bool low_swept
    int start_bar

var fvgs = array.new<FVG_Data>()
var obs  = array.new<OB_Data>()
var vis  = array.new<VI_Data>()
var SBSession active_sb = na

// ========================================================================= //
// ============================= TIME & SESSIONS =========================== //
// ========================================================================= //

ny_hour = hour(time, "America/New_York")
ny_minute = minute(time, "America/New_York")

in_session(sess_str) =>
    not na(time(timeframe.period, sess_str, "America/New_York"))

// Background session shading
col_asia_bg = color.new(color.purple, 97)
col_london_bg = color.new(color.blue, 97)
col_ny_am_bg = color.new(color.orange, 97)
col_london_close_bg = color.new(color.red, 97)

// Macro Checking Logic
in_macro_range(h1, m1, h2, m2) =>
    t_curr = ny_hour * 60 + ny_minute
    t_start = h1 * 60 + m1
    t_end = h2 * 60 + m2
    t_curr >= t_start and t_curr < t_end

is_macro = show_macros and (
  in_macro_range(2, 33, 3, 0) or
  in_macro_range(4, 3, 4, 30) or
  in_macro_range(8, 30, 9, 0) or
  in_macro_range(9, 50, 10, 10) or
  in_macro_range(10, 50, 11, 10) or
  in_macro_range(11, 50, 12, 10) or
  in_macro_range(13, 30, 14, 0) or
  in_macro_range(15, 15, 15, 45)
  )

// Calculate background colors globally
asia_bg = (show_asia and in_session("2000-0000:23456")) ? col_asia_bg : na
london_bg = (show_london and in_session("0200-0500:23456")) ? col_london_bg : na
ny_am_bg = (show_ny_am and in_session("0700-1000:23456")) ? col_ny_am_bg : na
london_close_bg = (show_london_close and in_session("1100-1300:23456")) ? col_london_close_bg : na
macro_bg = is_macro ? macro_color : na

resolved_bg = not na(london_close_bg) ? london_close_bg : 
              not na(ny_am_bg) ? ny_am_bg : 
              not na(london_bg) ? london_bg : 
              not na(asia_bg) ? asia_bg : 
              macro_bg

bgcolor(resolved_bg)

// ========================================================================= //
// ============================= TRUE OPENS ================================ //
// ========================================================================= //

is_midnight = (ny_hour == 0 and ny_minute == 0)
is_0830 = (ny_hour == 8 and ny_minute == 30)

var int last_midnight_bar = na
var int last_0830_bar = na

is_new_midnight = is_midnight and (na(last_midnight_bar) or bar_index != last_midnight_bar)
if is_new_midnight
    last_midnight_bar := bar_index

is_new_0830 = is_0830 and (na(last_0830_bar) or bar_index != last_0830_bar)
if is_new_0830
    last_0830_bar := bar_index

var line l_midnight = na
var line l_0830 = na

if show_opens
    if is_new_midnight
        l_midnight := line.new(bar_index, open, bar_index, open, color=col_midnight, width=1, style=line.style_dashed)
        label.new(bar_index, open, "Midnight Open", color=color.new(color.white, 100), textcolor=col_midnight, style=label.style_label_left, size=size.small)
    if not na(l_midnight)
        line.set_x2(l_midnight, bar_index)
        
    if is_new_0830
        l_0830 := line.new(bar_index, open, bar_index, open, color=col_ny_open, width=1, style=line.style_dashed)
        label.new(bar_index, open, "08:30 Open", color=color.new(color.white, 100), textcolor=col_ny_open, style=label.style_label_left, size=size.small)
    if not na(l_0830)
        line.set_x2(l_0830, bar_index)

// ========================================================================= //
// ============================= SILVER BULLET ============================= //
// ========================================================================= //

var int last_sb_lon_bar = na
var int last_sb_ny_am_bar = na
var int last_sb_ny_pm_bar = na

is_sb_london_start = (ny_hour == 3 and ny_minute == 0) and (na(last_sb_lon_bar) or bar_index != last_sb_lon_bar)
if is_sb_london_start
    last_sb_lon_bar := bar_index

is_sb_ny_am_start  = (ny_hour == 10 and ny_minute == 0) and (na(last_sb_ny_am_bar) or bar_index != last_sb_ny_am_bar)
if is_sb_ny_am_start
    last_sb_ny_am_bar := bar_index

is_sb_ny_pm_start  = (ny_hour == 14 and ny_minute == 0) and (na(last_sb_ny_pm_bar) or bar_index != last_sb_ny_pm_bar)
if is_sb_ny_pm_start
    last_sb_ny_pm_bar := bar_index

// Take high/low of prior 30 bars for Silver Bullet targets
lookback_sb = 30
highest_high_before = ta.highest(high, lookback_sb)[1]
lowest_low_before   = ta.lowest(low, lookback_sb)[1]

create_sb_session(col_bg) =>
    h = highest_high_before
    l = lowest_low_before
    bg = box.new(bar_index, h, bar_index + 12, l, bgcolor=col_bg, border_color=na)
    t_h = line.new(bar_index, h, bar_index + 12, h, color=color.red, width=1, style=line.style_dashed)
    t_l = line.new(bar_index, l, bar_index + 12, l, color=color.green, width=1, style=line.style_dashed)
    SBSession.new(bg, t_h, t_l, false, false, bar_index)

if show_sb
    if is_sb_london_start
        active_sb := create_sb_session(col_sb_london)
    if is_sb_ny_am_start
        active_sb := create_sb_session(col_sb_ny_am)
    if is_sb_ny_pm_start
        active_sb := create_sb_session(col_sb_ny_pm)
        
    // Update active SB session bounds
    if not na(active_sb)
        in_sb = in_session("0300-0400:23456") or in_session("1000-1100:23456") or in_session("1400-1500:23456")
        if in_sb
            box.set_right(active_sb.bg_box, bar_index)
            line.set_x2(active_sb.target_high, bar_index)
            line.set_x2(active_sb.target_low, bar_index)
            
            // Check for sweep of targets during the session
            h_val = line.get_y1(active_sb.target_high)
            l_val = line.get_y1(active_sb.target_low)
            if not active_sb.high_swept and high > h_val
                active_sb.high_swept := true
                line.set_color(active_sb.target_high, color.new(color.red, 70))
                label.new(bar_index, high, "BSL Swept", color=color.new(color.white, 100), textcolor=color.red, style=label.style_label_down, size=size.small)
            if not active_sb.low_swept and low < l_val
                active_sb.low_swept := true
                line.set_color(active_sb.target_low, color.new(color.green, 70))
                label.new(bar_index, low, "SSL Swept", color=color.new(color.white, 100), textcolor=color.green, style=label.style_label_up, size=size.small)

// ========================================================================= //
// ============================= DEALING RANGE ============================= //
// ========================================================================= //

dr_ph = ta.pivothigh(high, dr_pivot, dr_pivot)
dr_pl = ta.pivotlow(low, dr_pivot, dr_pivot)
var float dr_high = na
var float dr_low = na
var line dr_eq_line = na

if not na(dr_ph)
    dr_high := dr_ph
if not na(dr_pl)
    dr_low := dr_pl
      
if show_dr and not na(dr_high) and not na(dr_low)
    eq = (dr_high + dr_low) / 2
    if not na(dr_eq_line)
        line.delete(dr_eq_line)
    dr_eq_line := line.new(bar_index - 50, eq, bar_index, eq, color=color.gray, width=1, style=line.style_solid)

// ========================================================================= //
// ====================== JUDAS SWING & OPENING RANGE ====================== //
// ========================================================================= //

var float midnight_or_high = na
var float midnight_or_low = na
var float ny_or_high = na
var float ny_or_low = na

// Track high/low of Midnight range (00:00 - 01:00 EST)
in_midnight_or = in_session("0000-0100:23456")
midnight_or_start = in_midnight_or and not in_midnight_or[1]
if in_midnight_or
    if midnight_or_start or na(midnight_or_high)
        midnight_or_high := high
        midnight_or_low := low
    else
        midnight_or_high := math.max(midnight_or_high, high)
        midnight_or_low := math.min(midnight_or_low, low)
          
// Track high/low of NY range (08:30 - 09-30 EST)
in_ny_or = in_session("0830-0930:23456")
ny_or_start = in_ny_or and not in_ny_or[1]
if in_ny_or
    if ny_or_start or na(ny_or_high)
        ny_or_high := high
        ny_or_low := low
    else
        ny_or_high := math.max(ny_or_high, high)
        ny_or_low := math.min(ny_or_low, low)

var bool midnight_high_swept = false
var bool midnight_low_swept = false
var bool ny_high_swept = false
var bool ny_low_swept = false

if is_new_midnight
    midnight_high_swept := false
    midnight_low_swept := false
if is_new_0830
    ny_high_swept := false
    ny_low_swept := false
      
is_midnight_high_sweep = not in_midnight_or and in_session("0100-0500:23456") and not na(midnight_or_high) and (high > midnight_or_high and close < midnight_or_high)
is_midnight_low_sweep  = not in_midnight_or and in_session("0100-0500:23456") and not na(midnight_or_low) and (low < midnight_or_low and close > midnight_or_low)

is_ny_high_sweep = not in_ny_or and in_session("0930-1200:23456") and not na(ny_or_high) and (high > ny_or_high and close < ny_or_high)
is_ny_low_sweep  = not in_ny_or and in_session("0930-1200:23456") and not na(ny_or_low) and (low < ny_or_low and close > ny_or_low)

if show_judas
    if is_midnight_high_sweep and not midnight_high_swept
        midnight_high_swept := true
        label.new(bar_index, high, "Judas Swing (High Sweep)", color=color.new(color.red, 90), textcolor=color.red, style=label.style_label_down, size=size.small)
    if is_midnight_low_sweep and not midnight_low_swept
        midnight_low_swept := true
        label.new(bar_index, low, "Judas Swing (Low Sweep)", color=color.new(color.green, 90), textcolor=color.green, style=label.style_label_up, size=size.small)
          
    if is_ny_high_sweep and not ny_high_swept
        ny_high_swept := true
        label.new(bar_index, high, "Judas Swing (High Sweep)", color=color.new(color.red, 90), textcolor=color.red, style=label.style_label_down, size=size.small)
    if is_ny_low_sweep and not ny_low_swept
        ny_low_swept := true
        label.new(bar_index, low, "Judas Swing (Low Sweep)", color=color.new(color.green, 90), textcolor=color.green, style=label.style_label_up, size=size.small)

// ========================================================================= //
// ==================== MSS & DISPLACEMENT VALIDATION ====================== //
// ========================================================================= //

pl = ta.pivotlow(low, 5, 5)
ph = ta.pivothigh(high, 5, 5)
var float last_pl = na
var float last_ph = na
if not na(pl)
    last_pl := pl
if not na(ph)
    last_ph := ph

body_size = math.abs(close - open)
atr_14 = ta.atr(14)
has_displacement = body_size > (disp_mult * atr_14)

is_bull_fvg = low > high[2]
is_bear_fvg = high < low[2]

bull_mss = show_mss and not na(last_ph) and close > last_ph and close[1] <= last_ph and has_displacement and is_bull_fvg
bear_mss = show_mss and not na(last_pl) and close < last_pl and close[1] >= last_pl and has_displacement and is_bear_fvg

if bull_mss
    label.new(bar_index, low, "MSS (Displacement Bull)", color=color.new(color.green, 80), textcolor=color.green, style=label.style_label_up, size=size.small)
if bear_mss
    label.new(bar_index, high, "MSS (Displacement Bear)", color=color.new(color.red, 80), textcolor=color.red, style=label.style_label_down, size=size.small)

// ========================================================================= //
// ====================== VOLUME IMBALANCE (VI) ============================ //
// ========================================================================= //

if show_vi
    body_max = math.max(open, close)
    body_min = math.min(open, close)
    prev_max = math.max(open[1], close[1])
    prev_min = math.min(open[1], close[1])

    if body_min > prev_max and low < high[1] // Bullish VI
        b = box.new(bar_index[1], body_min, bar_index, prev_max, bgcolor=col_vi, border_color=na, text="VI", text_size=size.tiny, text_color=color.new(col_vi, 0))
        array.push(vis, VI_Data.new(b, true, body_min, prev_max, false))
    if body_max < prev_min and high > low[1] // Bearish VI
        b = box.new(bar_index[1], prev_min, bar_index, body_max, bgcolor=col_vi, border_color=na, text="VI", text_size=size.tiny, text_color=color.new(col_vi, 0))
        array.push(vis, VI_Data.new(b, false, prev_min, body_max, false))

// Update Volume Imbalances
if array.size(vis) > 0
    for i = array.size(vis) - 1 to 0
        v = array.get(vis, i)
        if not v.mitigated
            box.set_right(v.b, bar_index)
            if v.is_bull and low < v.bot
                v.mitigated := true
                box.set_bgcolor(v.b, color.new(col_vi, 96))
            else if not v.is_bull and high > v.top
                v.mitigated := true
                box.set_bgcolor(v.b, color.new(col_vi, 96))

// ========================================================================= //
// ======================= REJECTION BLOCKS ================================ //
// ========================================================================= //

if show_rej
    body_max = math.max(open, close)
    body_min = math.min(open, close)
    body = body_max - body_min
    wick_up = high - body_max
    wick_dn = body_min - low
    
    if wick_dn > body * 2 and wick_dn > atr_14 * 0.5
        box.new(bar_index, body_min, bar_index+5, low, bgcolor=col_rej, border_color=na, text="Rej", text_size=size.tiny)
    if wick_up > body * 2 and wick_up > atr_14 * 0.5
        box.new(bar_index, high, bar_index+5, body_max, bgcolor=col_rej, border_color=na, text="Rej", text_size=size.tiny)

// ========================================================================= //
// ================= FVGS, BPRS, AND ORDER BLOCKS ========================== //
// ========================================================================= //

if is_bull_fvg and show_fvg
    float top = low
    float bot = high[2]
    b = box.new(bar_index[2], top, bar_index, bot, bgcolor=col_bisi, border_color=na, text="BISI", text_color=color.new(col_bisi, 0), text_size=size.tiny, text_halign=text.align_right)
    l = line.new(bar_index[2], (top+bot)/2, bar_index, (top+bot)/2, color=color.new(col_bisi, 20), style=line.style_dotted)
    array.push(fvgs, FVG_Data.new(b, l, true, false, top, bot))
        
    if show_ob
        ob_idx = int(na)
        for j = 2 to 10
            if close[j] < open[j]
                ob_idx := j
                break
        if not na(ob_idx)
            swept = not na(last_pl) and low[ob_idx] <= last_pl
            b2 = box.new(bar_index[ob_idx], high[ob_idx], bar_index, low[ob_idx], bgcolor=col_ob_bull, border_color=na, text="+OB", text_color=color.new(col_ob_bull, 0), text_size=size.tiny, text_halign=text.align_right)
            array.push(obs, OB_Data.new(b2, true, false, high[ob_idx], low[ob_idx], swept))

if is_bear_fvg and show_fvg
    float top = low[2]
    float bot = high
    b = box.new(bar_index[2], top, bar_index, bot, bgcolor=col_sibi, border_color=na, text="SIBI", text_color=color.new(col_sibi, 0), text_size=size.tiny, text_halign=text.align_right)
    l = line.new(bar_index[2], (top+bot)/2, bar_index, (top+bot)/2, color=color.new(col_sibi, 20), style=line.style_dotted)
    array.push(fvgs, FVG_Data.new(b, l, false, false, top, bot))
        
    if show_ob
        ob_idx = int(na)
        for j = 2 to 10
            if close[j] > open[j]
                ob_idx := j
                break
        if not na(ob_idx)
            swept = not na(last_ph) and high[ob_idx] >= last_ph
            b2 = box.new(bar_index[ob_idx], high[ob_idx], bar_index, low[ob_idx], bgcolor=col_ob_bear, border_color=na, text="-OB", text_color=color.new(col_ob_bear, 0), text_size=size.tiny, text_halign=text.align_right)
            array.push(obs, OB_Data.new(b2, false, false, high[ob_idx], low[ob_idx], swept))

// Update FVGs & OBs
if barstate.isconfirmed
    if array.size(fvgs) > 0
        for i = array.size(fvgs) - 1 to 0
            f = array.get(fvgs, i)
            box.set_right(f.b, bar_index)
            if not na(f.ce)
                line.set_x2(f.ce, bar_index)
                
            if not f.is_inv
                if f.is_bull
                    if close < f.bot
                        f.is_inv := true
                        box.set_bgcolor(f.b, color.new(color.red, 70))
                        box.set_text(f.b, "IFVG")
                    else if low < f.top
                        box.set_bgcolor(f.b, color.new(col_bisi, 95))
                else
                    if close > f.top
                        f.is_inv := true
                        box.set_bgcolor(f.b, color.new(color.green, 70))
                        box.set_text(f.b, "IFVG")
                    else if high > f.bot
                        box.set_bgcolor(f.b, color.new(col_sibi, 95))

    if array.size(obs) > 0
        for i = array.size(obs) - 1 to 0
            o = array.get(obs, i)
            box.set_right(o.b, bar_index)
            
            if not o.is_breaker
                if o.is_bull
                    if close < o.bot
                        if show_breaker
                            o.is_breaker := true
                            txt = o.swept_liq ? "-BRK" : "-MB"
                            box.set_bgcolor(o.b, col_brk_bear)
                            box.set_text(o.b, txt)
                        else
                            box.delete(o.b)
                            array.remove(obs, i)
                else
                    if close > o.top
                        if show_breaker
                            o.is_breaker := true
                            txt = o.swept_liq ? "+BRK" : "+MB"
                            box.set_bgcolor(o.b, col_brk_bull)
                            box.set_text(o.b, txt)
                        else
                            box.delete(o.b)
                            array.remove(obs, i)

// ========================================================================= //
// ==================== DYNAMIC DRAWING CLEANUP ============================ //
// ========================================================================= //

if array.size(fvgs) > 100
    f = array.shift(fvgs)
    box.delete(f.b)
    if not na(f.ce)
        line.delete(f.ce)
        
if array.size(obs) > 100
    o = array.shift(obs)
    box.delete(o.b)

if array.size(vis) > 100
    v = array.shift(vis)
    box.delete(v.b)
````
