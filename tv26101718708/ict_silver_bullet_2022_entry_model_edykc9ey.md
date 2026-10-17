# ICT Silver Bullet & 2022 Entry Model

- url: https://www.tradingview.com/script/edyKC9Ey-ICT-Silver-Bullet-2022-Entry-Model/
- type: indicator
- pine_id: PUB;b49a7fe3079548bead01021baf236780
- version: 1.0

## Description

This script is a fully automated algorithmic scanner and trade visualizer for the ICT 2022 Mentorship Entry Model, specifically programmed to only look for setups during the Silver Bullet time windows.

Here is a breakdown of how the engine works from top to bottom:

1. Time & Sessions Engine
The script begins by shading your chart background for the three specific "Silver Bullet" execution hours (EST):

London: 03:00 - 04:00 (Silver)
New York AM: 10:00 - 11:00 (Orange)
New York PM: 14:00 - 15:00 (Teal) The script will strictly ignore any price action outside of these three windows.
2. The 5-Phase State Machine
Inside those sessions, the script runs a rigid 5-step sequence to validate the 2022 Model. It will cancel the setup if the sequence is broken.

Phase 1: Liquidity Raid (The Stop Run) The script tracks historical Swing Highs (Buy-Side Liquidity) and Swing Lows (Sell-Side Liquidity). If price sweeps one of these levels, it prints a "BSL Raid" or "SSL Raid" label. Crucially, it nullifies that specific liquidity level immediately after it's swept so you don't get duplicate labels on every single candle.

Phase 2: Market Structure Shift (ChoCh) Upon sweeping liquidity, the script identifies the exact minor swing point that formed just prior to the sweep. It waits for price to aggressively reverse and close past that level. When it does, it plots a line and a "ChoCh" (Change of Character / MSS) label.

Phase 3: Displacement FVG Detection The leg that breaks structure must show institutional displacement. The script scans the exact 3-5 candles that broke the ChoCh level to find a Fair Value Gap (SIBI for shorts, BISI for longs). If it finds one, it draws the gap box on your chart.

Phase 4: Trade Execution The script waits for price to retrace and tap the open boundary of the FVG. The moment price touches it, the script prints a "2022 SHORT ENTRY" or "2022 LONG ENTRY" label.

Phase 5: Trade Management & Visualizer (The code block you highlighted) Upon entry, the script transitions into a live trade manager:

Stop Loss (SL): It calculates an SL exactly 1 tick above the absolute peak of the Liquidity Raid. It draws a solid red line and a red risk box.
Take Profit (TP): By default, it targets the opposing major liquidity pool on the chart. If you toggle it off in settings, it defaults to a strict 1:2 Risk-to-Reward ratio. It draws a solid green line and a green reward box.
Live Tracking: The script physically extends these red and green boxes forward bar-by-bar until price hits either the SL line or the TP line. Once hit, it closes the trade, prints "SL HIT" or "TP HIT", and resets the engine to look for the next setup.

## Source Code

````pine
//@version=6
indicator("ICT Silver Bullet & 2022 Entry Model", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ========================================================================= //
// ========================== INPUT GROUPS ================================= //
// ========================================================================= //

grp_time = "1. Silver Bullet Sessions (EST)"
show_london = input.bool(true, "London (03:00-04:00)", group=grp_time)
show_ny_am = input.bool(true, "NY AM (10:00-11:00)", group=grp_time)
show_ny_pm = input.bool(true, "NY PM (14:00-15:00)", group=grp_time)

grp_model = "2. ICT 2022 Model Settings"
pivot_len = input.int(5, "Swing Pivot Lookback", minval=2, group=grp_model, tooltip="Number of bars left/right to define a Swing High (BSL) or Swing Low (SSL)")

grp_risk = "3. Trade Management"
use_opposing_liq = input.bool(true, "Use Opposing Liquidity for TP", group=grp_risk, tooltip="If true, TP targets the last major swing low/high. If false, uses fixed R:R.")
rr_ratio = input.float(2.0, "Fixed Risk:Reward Ratio", minval=0.5, step=0.5, group=grp_risk)

// ========================================================================= //
// ============================= TIME & SESSIONS =========================== //
// ========================================================================= //

in_session(sess_str) =>
    not na(time(timeframe.period, sess_str, "America/New_York"))

in_lon = show_london and in_session("0300-0400:23456")
in_ny_am = show_ny_am and in_session("1000-1100:23456")
in_ny_pm = show_ny_pm and in_session("1400-1500:23456")

in_sb = in_lon or in_ny_am or in_ny_pm

bgcolor(in_lon ? color.new(color.silver, 95) : na)
bgcolor(in_ny_am ? color.new(color.orange, 95) : na)
bgcolor(in_ny_pm ? color.new(color.teal, 95) : na)

// ========================================================================= //
// ========================== LIQUIDITY (SWINGS) =========================== //
// ========================================================================= //

ph = ta.pivothigh(high, pivot_len, pivot_len)
pl = ta.pivotlow(low, pivot_len, pivot_len)

var float last_ph = na
var float last_pl = na

// For TP targeting, we track the historical swings regardless of nullification
var float target_ph = na
var float target_pl = na

if not na(ph)
    last_ph := ph
    target_ph := ph
if not na(pl)
    last_pl := pl
    target_pl := pl

// ========================================================================= //
// ==================== ICT 2022 ENTRY MODEL ENGINE ======================== //
// ========================================================================= //

var int setup_state = 0
var float mss_level = na
var float fvg_top = na
var float fvg_bot = na
var box fvg_box = na
var float sweep_high = na
var float sweep_low = na

// Trade execution variables
var bool trade_active = false
var int trade_dir = 0
var float entry_price = na
var float sl_price = na
var float tp_price = na
var line sl_line = na
var line tp_line = na
var line entry_line = na
var box sl_box = na
var box tp_box = na

// Reset setup (but not active trades) on new session
is_new_session = in_sb and not in_sb[1]
if is_new_session
    setup_state := 0
    mss_level := na
    fvg_top := na
    fvg_bot := na
    fvg_box := na
    sweep_high := na
    sweep_low := na

if in_sb and not trade_active
    // -------------------------------------------------------------
    // PHASE 1: Detect Liquidity Sweep
    // -------------------------------------------------------------
    if setup_state == 0
        if not na(last_ph) and high > last_ph
            setup_state := 1 // Swept BSL
            sweep_high := high
            mss_level := last_pl 
            last_ph := na // Nullify it
            label.new(bar_index, high, "BSL Raid", style=label.style_label_down, color=color.new(color.red, 80), textcolor=color.white, size=size.small)
            
        else if not na(last_pl) and low < last_pl
            setup_state := 2 // Swept SSL
            sweep_low := low
            mss_level := last_ph
            last_pl := na // Nullify it
            label.new(bar_index, low, "SSL Raid", style=label.style_label_up, color=color.new(color.green, 80), textcolor=color.white, size=size.small)
            
    // -------------------------------------------------------------
    // PHASE 2: Detect Market Structure Shift (ChoCh)
    // -------------------------------------------------------------
    if setup_state == 1 // Bearish setup
        if high > sweep_high
            sweep_high := high
            
        if not na(mss_level) and close < mss_level
            setup_state := 3 
            line.new(bar_index - 5, mss_level, bar_index, mss_level, color=color.red, width=2)
            label.new(bar_index, mss_level, "ChoCh", style=label.style_label_up, color=color.new(color.red, 100), textcolor=color.red, size=size.tiny)

    if setup_state == 2 // Bullish setup
        if low < sweep_low
            sweep_low := low
            
        if not na(mss_level) and close > mss_level
            setup_state := 4 
            line.new(bar_index - 5, mss_level, bar_index, mss_level, color=color.green, width=2)
            label.new(bar_index, mss_level, "ChoCh", style=label.style_label_down, color=color.new(color.green, 100), textcolor=color.green, size=size.tiny)

    // -------------------------------------------------------------
    // PHASE 3: Detect Displacement FVG
    // -------------------------------------------------------------
    if setup_state == 3
        if high < low[2]
            setup_state := 5 
            fvg_top := low[2]
            fvg_bot := high
            fvg_box := box.new(bar_index[2], fvg_top, bar_index+5, fvg_bot, bgcolor=color.new(color.red, 80), border_color=na, text="SIBI", text_size=size.tiny, text_color=color.new(color.red, 0))
        else if high[1] < low[3]
            setup_state := 5
            fvg_top := low[3]
            fvg_bot := high[1]
            fvg_box := box.new(bar_index[3], fvg_top, bar_index+5, fvg_bot, bgcolor=color.new(color.red, 80), border_color=na, text="SIBI", text_size=size.tiny, text_color=color.new(color.red, 0))
        else
            setup_state := 0 // Reset if no displacement FVG

    if setup_state == 4
        if low > high[2]
            setup_state := 6 
            fvg_top := low
            fvg_bot := high[2]
            fvg_box := box.new(bar_index[2], fvg_top, bar_index+5, fvg_bot, bgcolor=color.new(color.green, 80), border_color=na, text="BISI", text_size=size.tiny, text_color=color.new(color.green, 0))
        else if low[1] > high[3]
            setup_state := 6
            fvg_top := low[1]
            fvg_bot := high[3]
            fvg_box := box.new(bar_index[3], fvg_top, bar_index+5, fvg_bot, bgcolor=color.new(color.green, 80), border_color=na, text="BISI", text_size=size.tiny, text_color=color.new(color.green, 0))
        else
            setup_state := 0 

    // -------------------------------------------------------------
    // PHASE 4: Execute Trade on Return to FVG
    // -------------------------------------------------------------
    if setup_state == 5 // Waiting for Short Entry
        if not na(fvg_box)
            box.set_right(fvg_box, bar_index)
        if high >= fvg_bot // Price retraced back up into the bottom of the SIBI
            setup_state := 7 // Trade Executed
            trade_active := true
            trade_dir := -1
            entry_price := fvg_bot
            sl_price := sweep_high + (syminfo.mintick * 1) // ICT places SL above the displacement high
            
            if use_opposing_liq and not na(target_pl)
                tp_price := target_pl
            else
                risk = sl_price - entry_price
                tp_price := entry_price - (risk * rr_ratio)
                
            entry_line := line.new(bar_index, entry_price, bar_index+5, entry_price, color=color.gray, style=line.style_dashed, width=1)
            sl_line := line.new(bar_index, sl_price, bar_index+5, sl_price, color=color.red, style=line.style_solid, width=2)
            tp_line := line.new(bar_index, tp_price, bar_index+5, tp_price, color=color.green, style=line.style_solid, width=2)
            sl_box := box.new(bar_index, sl_price, bar_index+5, entry_price, bgcolor=color.new(color.red, 85), border_color=na)
            tp_box := box.new(bar_index, entry_price, bar_index+5, tp_price, bgcolor=color.new(color.green, 85), border_color=na)
            
            label.new(bar_index, high, "2022 SHORT ENTRY", style=label.style_label_down, color=color.new(color.red, 0), textcolor=color.white, size=size.small)
            
    if setup_state == 6 // Waiting for Long Entry
        if not na(fvg_box)
            box.set_right(fvg_box, bar_index)
        if low <= fvg_top // Price retraced back down into the top of the BISI
            setup_state := 7 // Trade Executed
            trade_active := true
            trade_dir := 1
            entry_price := fvg_top
            sl_price := sweep_low - (syminfo.mintick * 1)
            
            if use_opposing_liq and not na(target_ph)
                tp_price := target_ph
            else
                risk = entry_price - sl_price
                tp_price := entry_price + (risk * rr_ratio)
                
            entry_line := line.new(bar_index, entry_price, bar_index+5, entry_price, color=color.gray, style=line.style_dashed, width=1)
            sl_line := line.new(bar_index, sl_price, bar_index+5, sl_price, color=color.red, style=line.style_solid, width=2)
            tp_line := line.new(bar_index, tp_price, bar_index+5, tp_price, color=color.green, style=line.style_solid, width=2)
            sl_box := box.new(bar_index, entry_price, bar_index+5, sl_price, bgcolor=color.new(color.red, 85), border_color=na)
            tp_box := box.new(bar_index, tp_price, bar_index+5, entry_price, bgcolor=color.new(color.green, 85), border_color=na)
            
            label.new(bar_index, low, "2022 LONG ENTRY", style=label.style_label_up, color=color.new(color.green, 0), textcolor=color.white, size=size.small)

// ========================================================================= //
// ==================== PHASE 5: TRADE MANAGEMENT ========================== //
// ========================================================================= //

if trade_active
    // Extend trade visuals forward
    if not na(entry_line)
        line.set_x2(entry_line, bar_index)
        line.set_x2(sl_line, bar_index)
        line.set_x2(tp_line, bar_index)
        box.set_right(sl_box, bar_index)
        box.set_right(tp_box, bar_index)
        
    if trade_dir == -1 // Short Trade
        if high >= sl_price
            trade_active := false
            label.new(bar_index, sl_price, "SL HIT", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)
            setup_state := 0 // Reset for next setup
        else if low <= tp_price
            trade_active := false
            label.new(bar_index, tp_price, "TP HIT", style=label.style_label_up, color=color.green, textcolor=color.white, size=size.small)
            setup_state := 0 // Reset for next setup
            
    if trade_dir == 1 // Long Trade
        if low <= sl_price
            trade_active := false
            label.new(bar_index, sl_price, "SL HIT", style=label.style_label_up, color=color.red, textcolor=color.white, size=size.small)
            setup_state := 0
        else if high >= tp_price
            trade_active := false
            label.new(bar_index, tp_price, "TP HIT", style=label.style_label_down, color=color.green, textcolor=color.white, size=size.small)
            setup_state := 0
````
