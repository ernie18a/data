# SPX Structural Pivots Pro

- url: https://www.tradingview.com/script/zEdkZFu7-SPX-Structural-Pivots-Pro/
- type: indicator
- pine_id: PUB;4ae2ea10900b428bb7e4eba2730ceeb0
- version: 1.0

## Description

Long short SPX trades based on Structural Pivot method , firstly used as fractal by victor. Currently it's in beta mode. enhancement coming to script. use at your own risk. this is just for testing purpose.

## Source Code

````pine
//@version=6
indicator("SPX Structural Pivots Pro", "SPX SP Pro", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=100)

// ============================================================================
// SPX STRUCTURAL PIVOTS METHOD - PROFESSIONAL EDITION
// Optimized specifically for SPX/SPY/ES trading
// Supports: 3min, 10min, 30min, 1hr, 4hr, 1day, 1week, 1month
// ============================================================================

// ===== INPUT GROUPS =====
grp_general = "═══ General Settings ═══"
grp_display = "═══ Display Settings ═══"
grp_signals = "═══ Trading Signals ═══"
grp_risk = "═══ Risk Management ═══"
grp_alerts = "═══ Alerts ═══"
grp_colors = "═══ Colors ═══"

// ===== INPUTS =====
// General Settings
i_show_temp_pivots = input.bool(false, "Show Temporary Pivots", group=grp_general, tooltip="Show pivots that haven't been confirmed yet")
i_min_bars = input.int(5, "Minimum Bars Between Pivots", minval=2, maxval=20, group=grp_general)
i_lookback = input.int(500, "Lookback Period", minval=100, maxval=5000, group=grp_general)

// Display Settings
i_show_sph = input.bool(true, "Show SPH (Small Pivot High)", group=grp_display)
i_show_spl = input.bool(true, "Show SPL (Small Pivot Low)", group=grp_display)
i_show_lph = input.bool(true, "Show LPH (Large Pivot High)", group=grp_display)
i_show_lpl = input.bool(true, "Show LPL (Large Pivot Low)", group=grp_display)
i_show_lines = input.bool(true, "Show Pivot Lines", group=grp_display)
i_show_zones = input.bool(true, "Show Trading Zones", group=grp_display)
i_show_table = input.bool(true, "Show Info Table", group=grp_display)
i_show_trend_bg = input.bool(true, "Show Trend Background", group=grp_display)

// Trading Signals
i_show_long_signals = input.bool(true, "Show Long Entry Signals", group=grp_signals)
i_show_short_signals = input.bool(true, "Show Short Entry Signals", group=grp_signals)
i_signal_mode = input.string("Aggressive", "Signal Mode", options=["Conservative", "Aggressive"], group=grp_signals, tooltip="Conservative: Only LPH/LPL breaks. Aggressive: Includes SPH/SPL breaks")

// Risk Management (SPX-specific)
i_risk_pct = input.float(2.0, "Risk Per Trade (%)", minval=0.1, maxval=10.0, step=0.1, group=grp_risk)
i_account_size = input.float(100000, "Account Size ($)", minval=1000, group=grp_risk)
i_default_sl_pct = input.float(0.3, "Default SL % (if no SPL/SPH)", minval=0.1, maxval=2.0, step=0.05, group=grp_risk, tooltip="As percentage of SPX price")
i_rr_target = input.float(2.0, "Risk:Reward Target", minval=1.0, maxval=5.0, step=0.5, group=grp_risk)

// Alerts
i_alert_lph = input.bool(true, "Alert on LPH Formation", group=grp_alerts)
i_alert_lpl = input.bool(true, "Alert on LPL Formation", group=grp_alerts)
i_alert_long = input.bool(true, "Alert on Long Entry", group=grp_alerts)
i_alert_short = input.bool(true, "Alert on Short Entry", group=grp_alerts)
i_alert_trend_change = input.bool(true, "Alert on Trend Change", group=grp_alerts)

// Colors
c_sph = input.color(color.new(#ef5350, 0), "SPH Color", group=grp_colors)
c_spl = input.color(color.new(#26a69a, 0), "SPL Color", group=grp_colors)
c_lph = input.color(color.new(#b71c1c, 0), "LPH Color", group=grp_colors)
c_lpl = input.color(color.new(#004d40, 0), "LPL Color", group=grp_colors)
c_long_signal = input.color(color.new(#00c853, 0), "Long Signal", group=grp_colors)
c_short_signal = input.color(color.new(#d50000, 0), "Short Signal", group=grp_colors)
c_uptrend_bg = input.color(color.new(#26a69a, 95), "Uptrend Background", group=grp_colors)
c_downtrend_bg = input.color(color.new(#ef5350, 95), "Downtrend Background", group=grp_colors)

// ===== ARRAYS FOR PIVOT STORAGE =====
var array<float> sph_prices = array.new<float>()
var array<int> sph_bars = array.new<int>()
var array<bool> sph_confirmed = array.new<bool>()

var array<float> spl_prices = array.new<float>()
var array<int> spl_bars = array.new<int>()
var array<bool> spl_confirmed = array.new<bool>()

var array<float> lph_prices = array.new<float>()
var array<int> lph_bars = array.new<int>()

var array<float> lpl_prices = array.new<float>()
var array<int> lpl_bars = array.new<int>()

// ===== STATE VARIABLES =====
var int anchor_bar_idx = 0
var string last_pivot_type = "INIT"
var string current_trend = "UNCLEAR"
var string previous_trend = "UNCLEAR"

// ===== HELPER FUNCTIONS =====

// Get the size of an array safely
get_array_size(arr) =>
    array.size(arr)

// Get last value from float array
get_last_float(arr) =>
    float result = na
    if array.size(arr) > 0
        result := array.get(arr, array.size(arr) - 1)
    result

// Get last value from int array
get_last_int(arr) =>
    int result = na
    if array.size(arr) > 0
        result := array.get(arr, array.size(arr) - 1)
    result

// Check SPH conditions: 2 lower lows AND 2 lower closes vs anchor
check_sph_formation(anchor_idx) =>
    bool result = false
    if anchor_idx > 0 and anchor_idx < bar_index
        anchor_low_val = low[bar_index - anchor_idx]
        anchor_close_val = close[bar_index - anchor_idx]
        
        int qualifying_count = 0
        for i = anchor_idx + 1 to bar_index
            bar_low_val = low[bar_index - i]
            bar_close_val = close[bar_index - i]
            if bar_low_val < anchor_low_val and bar_close_val < anchor_close_val
                qualifying_count := qualifying_count + 1
        
        if qualifying_count >= 2
            result := true
    result

// Check SPL conditions: 2 higher highs AND 2 higher closes vs anchor
check_spl_formation(anchor_idx) =>
    bool result = false
    if anchor_idx > 0 and anchor_idx < bar_index
        anchor_high_val = high[bar_index - anchor_idx]
        anchor_close_val = close[bar_index - anchor_idx]
        
        int qualifying_count = 0
        for i = anchor_idx + 1 to bar_index
            bar_high_val = high[bar_index - i]
            bar_close_val = close[bar_index - i]
            if bar_high_val > anchor_high_val and bar_close_val > anchor_close_val
                qualifying_count := qualifying_count + 1
        
        if qualifying_count >= 2
            result := true
    result

// ===== PIVOT DETECTION =====
// Calculate conditions BEFORE conditional usage (Pine Script consistency rule)
bars_since_anchor = bar_index - anchor_bar_idx
bool sph_conditions = check_sph_formation(anchor_bar_idx)
bool spl_conditions = check_spl_formation(anchor_bar_idx)

// Track new pivots
var bool new_sph_marked = false
var bool new_spl_marked = false
var bool new_lph_marked = false
var bool new_lpl_marked = false

new_sph_marked := false
new_spl_marked := false
new_lph_marked := false
new_lpl_marked := false

// ===== SMALL PIVOT DETECTION =====
if barstate.isconfirmed and bars_since_anchor >= i_min_bars
    // Looking for SPH (after SPL or initial state)
    if (last_pivot_type == "SPL" or last_pivot_type == "INIT") and sph_conditions
        anchor_high_price = high[bars_since_anchor]
        
        // Add SPH
        array.push(sph_prices, anchor_high_price)
        array.push(sph_bars, bar_index - bars_since_anchor)
        array.push(sph_confirmed, false)
        
        // Confirm previous SPL
        if array.size(spl_confirmed) > 0
            array.set(spl_confirmed, array.size(spl_confirmed) - 1, true)
        
        last_pivot_type := "SPH"
        new_sph_marked := true
        
        // Update anchor bar to second confirmation bar
        int new_anchor = anchor_bar_idx
        int qual_count = 0
        for i = anchor_bar_idx + 1 to bar_index
            if low[bar_index - i] < high[bars_since_anchor] and close[bar_index - i] < close[bars_since_anchor]
                qual_count := qual_count + 1
                if qual_count == 2
                    new_anchor := i
                    break
        anchor_bar_idx := new_anchor
    
    // Looking for SPL (after SPH)
    else if last_pivot_type == "SPH" and spl_conditions
        anchor_low_price = low[bars_since_anchor]
        
        // Add SPL
        array.push(spl_prices, anchor_low_price)
        array.push(spl_bars, bar_index - bars_since_anchor)
        array.push(spl_confirmed, false)
        
        // Confirm previous SPH
        if array.size(sph_confirmed) > 0
            array.set(sph_confirmed, array.size(sph_confirmed) - 1, true)
        
        last_pivot_type := "SPL"
        new_spl_marked := true
        
        // Update anchor bar
        int new_anchor = anchor_bar_idx
        int qual_count = 0
        for i = anchor_bar_idx + 1 to bar_index
            if high[bar_index - i] > low[bars_since_anchor] and close[bar_index - i] > close[bars_since_anchor]
                qual_count := qual_count + 1
                if qual_count == 2
                    new_anchor := i
                    break
        anchor_bar_idx := new_anchor

// Initialize anchor on first bar
if barstate.isconfirmed and last_pivot_type == "INIT" and bar_index > i_min_bars
    anchor_bar_idx := bar_index - i_min_bars

// ===== LARGE PIVOT DETECTION =====
// Get current pivot values
last_sph_price = get_last_float(sph_prices)
last_sph_bar = get_last_int(sph_bars)
last_spl_price = get_last_float(spl_prices)
last_spl_bar = get_last_int(spl_bars)
last_lph_price = get_last_float(lph_prices)
last_lph_bar = get_last_int(lph_bars)
last_lpl_price = get_last_float(lpl_prices)
last_lpl_bar = get_last_int(lpl_bars)

// Check for LPH formation (when SPL is broken)
bool spl_broken = not na(last_spl_price) ? low < last_spl_price : false
bool can_form_lph = not na(last_spl_bar) and (na(last_lph_bar) or last_spl_bar > last_lph_bar)

if barstate.isconfirmed and spl_broken and can_form_lph
    // Find highest SPH since last LPL
    int start_search_bar = na(last_lpl_bar) ? 0 : last_lpl_bar
    float highest_sph = 0.0
    int highest_sph_bar_idx = 0
    bool found = false
    
    for i = 0 to array.size(sph_bars) - 1
        sph_bar_val = array.get(sph_bars, i)
        if sph_bar_val > start_search_bar
            sph_price_val = array.get(sph_prices, i)
            if sph_price_val > highest_sph
                highest_sph := sph_price_val
                highest_sph_bar_idx := sph_bar_val
                found := true
    
    if found
        array.push(lph_prices, highest_sph)
        array.push(lph_bars, highest_sph_bar_idx)
        new_lph_marked := true

// Check for LPL formation (when SPH is broken)
bool sph_broken = not na(last_sph_price) ? high > last_sph_price : false
bool can_form_lpl = not na(last_sph_bar) and (na(last_lpl_bar) or last_sph_bar > last_lpl_bar)

if barstate.isconfirmed and sph_broken and can_form_lpl
    // Find lowest SPL since last LPH
    int start_search_bar = na(last_lph_bar) ? 0 : last_lph_bar
    float lowest_spl = 999999.0
    int lowest_spl_bar_idx = 0
    bool found = false
    
    for i = 0 to array.size(spl_bars) - 1
        spl_bar_val = array.get(spl_bars, i)
        if spl_bar_val > start_search_bar
            spl_price_val = array.get(spl_prices, i)
            if spl_price_val < lowest_spl
                lowest_spl := spl_price_val
                lowest_spl_bar_idx := spl_bar_val
                found := true
    
    if found and lowest_spl < 999999
        array.push(lpl_prices, lowest_spl)
        array.push(lpl_bars, lowest_spl_bar_idx)
        new_lpl_marked := true

// ===== TREND DETECTION =====
previous_trend := current_trend

// Determine trend based on Large Pivots first
if array.size(lph_prices) >= 2 and array.size(lpl_prices) >= 2
    lph_recent = array.get(lph_prices, array.size(lph_prices) - 1)
    lph_prev = array.get(lph_prices, array.size(lph_prices) - 2)
    lpl_recent = array.get(lpl_prices, array.size(lpl_prices) - 1)
    lpl_prev = array.get(lpl_prices, array.size(lpl_prices) - 2)
    
    if lph_recent > lph_prev and lpl_recent > lpl_prev
        current_trend := "LUT"
    else if lph_recent < lph_prev and lpl_recent < lpl_prev
        current_trend := "LDT"
    else
        current_trend := "UNCLEAR"

// If Large trend is unclear, check Small Pivots
if current_trend == "UNCLEAR" and array.size(sph_prices) >= 2 and array.size(spl_prices) >= 2
    sph_recent = array.get(sph_prices, array.size(sph_prices) - 1)
    sph_prev = array.get(sph_prices, array.size(sph_prices) - 2)
    spl_recent = array.get(spl_prices, array.size(spl_prices) - 1)
    spl_prev = array.get(spl_prices, array.size(spl_prices) - 2)
    
    if sph_recent > sph_prev and spl_recent > spl_prev
        current_trend := "SUT"
    else if sph_recent < sph_prev and spl_recent < spl_prev
        current_trend := "SDT"

// Trend change alert
bool trend_changed = current_trend != previous_trend and previous_trend != "UNCLEAR" and current_trend != "UNCLEAR"

// ===== ENTRY SIGNAL DETECTION =====
var bool long_entry = false
var bool short_entry = false
var float entry_level = na
var float stop_loss_level = na
var float target_level = na

long_entry := false
short_entry := false

bool is_uptrend = current_trend == "LUT" or current_trend == "SUT"
bool is_downtrend = current_trend == "LDT" or current_trend == "SDT"

if barstate.isconfirmed
    // ===== LONG ENTRY SIGNALS =====
    if is_uptrend and i_show_long_signals
        // Signal 1: Break above LPH (Conservative & Aggressive)
        bool lph_break = not na(last_lph_price) and close > last_lph_price and close[1] <= last_lph_price
        
        if lph_break
            long_entry := true
            entry_level := close
            stop_loss_level := not na(last_spl_price) ? last_spl_price : low * (1 - i_default_sl_pct/100)
            target_level := entry_level + (entry_level - stop_loss_level) * i_rr_target
        
        // Signal 2: Break above SPH (Aggressive only)
        if i_signal_mode == "Aggressive" and not long_entry
            bool sph_above_lph = not na(last_sph_price) and not na(last_lph_price) and not na(last_sph_bar) and not na(last_lph_bar) and last_sph_bar > last_lph_bar and last_sph_price > last_lph_price
            bool sph_break = sph_above_lph and close > last_sph_price and close[1] <= last_sph_price
            
            if sph_break
                long_entry := true
                entry_level := close
                stop_loss_level := not na(last_spl_price) ? last_spl_price : low * (1 - i_default_sl_pct/100)
                target_level := entry_level + (entry_level - stop_loss_level) * i_rr_target
    
    // ===== SHORT ENTRY SIGNALS =====
    if is_downtrend and i_show_short_signals
        // Signal 1: Break below LPL (Conservative & Aggressive)
        bool lpl_break = not na(last_lpl_price) and close < last_lpl_price and close[1] >= last_lpl_price
        
        if lpl_break
            short_entry := true
            entry_level := close
            stop_loss_level := not na(last_sph_price) ? last_sph_price : high * (1 + i_default_sl_pct/100)
            target_level := entry_level - (stop_loss_level - entry_level) * i_rr_target
        
        // Signal 2: Break below SPL (Aggressive only)
        if i_signal_mode == "Aggressive" and not short_entry
            bool spl_below_lpl = not na(last_spl_price) and not na(last_lpl_price) and not na(last_spl_bar) and not na(last_lpl_bar) and last_spl_bar > last_lpl_bar and last_spl_price < last_lpl_price
            bool spl_break = spl_below_lpl and close < last_spl_price and close[1] >= last_spl_price
            
            if spl_break
                short_entry := true
                entry_level := close
                stop_loss_level := not na(last_sph_price) ? last_sph_price : high * (1 + i_default_sl_pct/100)
                target_level := entry_level - (stop_loss_level - entry_level) * i_rr_target

// ===== POSITION SIZING CALCULATION =====
calculate_position_size(entry, stop) =>
    float result = 0.0
    if not na(entry) and not na(stop) and entry != stop
        risk_amount = i_account_size * (i_risk_pct / 100)
        risk_per_unit = math.abs(entry - stop)
        result := risk_amount / risk_per_unit
    result

position_size = calculate_position_size(entry_level, stop_loss_level)

// ===== PLOTTING - PIVOTS =====

// Plot SPH labels
if i_show_sph and new_sph_marked
    sph_bar_idx = array.get(sph_bars, array.size(sph_bars) - 1)
    sph_price_val = array.get(sph_prices, array.size(sph_prices) - 1)
    label.new(
         x=sph_bar_idx,
         y=sph_price_val,
         text="sph\n" + str.tostring(sph_price_val, "#.##"),
         style=label.style_label_down,
         color=c_sph,
         textcolor=color.white,
         size=size.small,
         tooltip="Small Pivot High at " + str.tostring(sph_price_val))

// Plot SPL labels
if i_show_spl and new_spl_marked
    spl_bar_idx = array.get(spl_bars, array.size(spl_bars) - 1)
    spl_price_val = array.get(spl_prices, array.size(spl_prices) - 1)
    label.new(
         x=spl_bar_idx,
         y=spl_price_val,
         text="spl\n" + str.tostring(spl_price_val, "#.##"),
         style=label.style_label_up,
         color=c_spl,
         textcolor=color.white,
         size=size.small,
         tooltip="Small Pivot Low at " + str.tostring(spl_price_val))

// Plot LPH labels
if i_show_lph and new_lph_marked
    lph_bar_idx = array.get(lph_bars, array.size(lph_bars) - 1)
    lph_price_val = array.get(lph_prices, array.size(lph_prices) - 1)
    label.new(
         x=lph_bar_idx,
         y=lph_price_val,
         text="LPH\n" + str.tostring(lph_price_val, "#.##"),
         style=label.style_label_down,
         color=c_lph,
         textcolor=color.white,
         size=size.large,
         tooltip="LARGE PIVOT HIGH at " + str.tostring(lph_price_val) + " - Major Resistance")

// Plot LPL labels
if i_show_lpl and new_lpl_marked
    lpl_bar_idx = array.get(lpl_bars, array.size(lpl_bars) - 1)
    lpl_price_val = array.get(lpl_prices, array.size(lpl_prices) - 1)
    label.new(
         x=lpl_bar_idx,
         y=lpl_price_val,
         text="LPL\n" + str.tostring(lpl_price_val, "#.##"),
         style=label.style_label_up,
         color=c_lpl,
         textcolor=color.white,
         size=size.large,
         tooltip="LARGE PIVOT LOW at " + str.tostring(lpl_price_val) + " - Major Support")

// ===== PLOTTING - PIVOT LINES =====
var line lph_line = na
var line lpl_line = na
var line last_sph_line = na
var line last_spl_line = na

if i_show_lines and barstate.islast
    // Delete old lines
    line.delete(lph_line)
    line.delete(lpl_line)
    line.delete(last_sph_line)
    line.delete(last_spl_line)
    
    // Draw current LPH line (key resistance)
    if not na(last_lph_price) and not na(last_lph_bar)
        lph_line := line.new(
             x1=last_lph_bar,
             y1=last_lph_price,
             x2=bar_index + 20,
             y2=last_lph_price,
             color=c_lph,
             width=2,
             style=line.style_solid,
             extend=extend.right)
    
    // Draw current LPL line (key support)
    if not na(last_lpl_price) and not na(last_lpl_bar)
        lpl_line := line.new(
             x1=last_lpl_bar,
             y1=last_lpl_price,
             x2=bar_index + 20,
             y2=last_lpl_price,
             color=c_lpl,
             width=2,
             style=line.style_solid,
             extend=extend.right)
    
    // Draw current SPH line (minor resistance)
    if not na(last_sph_price) and not na(last_sph_bar)
        last_sph_line := line.new(
             x1=last_sph_bar,
             y1=last_sph_price,
             x2=bar_index + 10,
             y2=last_sph_price,
             color=color.new(c_sph, 50),
             width=1,
             style=line.style_dashed)
    
    // Draw current SPL line (minor support)
    if not na(last_spl_price) and not na(last_spl_bar)
        last_spl_line := line.new(
             x1=last_spl_bar,
             y1=last_spl_price,
             x2=bar_index + 10,
             y2=last_spl_price,
             color=color.new(c_spl, 50),
             width=1,
             style=line.style_dashed)

// ===== PLOTTING - TRADING ZONES =====
var box trading_zone = na

if i_show_zones and barstate.islast
    box.delete(trading_zone)
    
    if is_uptrend and not na(last_lph_price) and not na(last_lpl_price)
        trading_zone := box.new(
             left=bar_index - 50,
             top=last_lph_price,
             right=bar_index + 20,
             bottom=last_lpl_price,
             bgcolor=color.new(c_uptrend_bg, 90),
             border_color=color.new(c_long_signal, 70),
             border_width=1,
             extend=extend.right)
    else if is_downtrend and not na(last_lph_price) and not na(last_lpl_price)
        trading_zone := box.new(
             left=bar_index - 50,
             top=last_lph_price,
             right=bar_index + 20,
             bottom=last_lpl_price,
             bgcolor=color.new(c_downtrend_bg, 90),
             border_color=color.new(c_short_signal, 70),
             border_width=1,
             extend=extend.right)

// ===== PLOTTING - ENTRY SIGNALS =====
plotshape(long_entry, title="Long Entry", style=shape.triangleup, location=location.belowbar, color=c_long_signal, size=size.normal, text="LONG")
plotshape(short_entry, title="Short Entry", style=shape.triangledown, location=location.abovebar, color=c_short_signal, size=size.normal, text="SHORT")

// Display entry/SL/target labels for new signals
if long_entry
    label.new(
         x=bar_index,
         y=low,
         text="🟢 LONG\nEntry: " + str.tostring(entry_level, "#.##") + 
              "\nSL: " + str.tostring(stop_loss_level, "#.##") + 
              "\nTarget: " + str.tostring(target_level, "#.##") +
              "\nSize: " + str.tostring(position_size, "#") + " units" +
              "\nRisk: $" + str.tostring(i_account_size * i_risk_pct / 100, "#.##"),
         style=label.style_label_up,
         color=color.new(c_long_signal, 20),
         textcolor=color.white,
         size=size.normal,
         yloc=yloc.belowbar)

if short_entry
    label.new(
         x=bar_index,
         y=high,
         text="🔴 SHORT\nEntry: " + str.tostring(entry_level, "#.##") + 
              "\nSL: " + str.tostring(stop_loss_level, "#.##") + 
              "\nTarget: " + str.tostring(target_level, "#.##") +
              "\nSize: " + str.tostring(position_size, "#") + " units" +
              "\nRisk: $" + str.tostring(i_account_size * i_risk_pct / 100, "#.##"),
         style=label.style_label_down,
         color=color.new(c_short_signal, 20),
         textcolor=color.white,
         size=size.normal,
         yloc=yloc.abovebar)

// ===== TREND BACKGROUND =====
trend_bg_color = color.new(color.gray, 100)
if i_show_trend_bg
    if current_trend == "LUT" or current_trend == "SUT"
        trend_bg_color := c_uptrend_bg
    else if current_trend == "LDT" or current_trend == "SDT"
        trend_bg_color := c_downtrend_bg

bgcolor(trend_bg_color, title="Trend Background")

// ===== INFO TABLE =====
var table info_table = table.new(position.top_right, 2, 12, frame_color=color.gray, frame_width=1, border_color=color.gray, border_width=1)

if i_show_table and barstate.islast
    // Header
    table.cell(info_table, 0, 0, "📊 SPX SPM PRO", text_color=color.white, bgcolor=color.new(#1565c0, 0), text_size=size.normal)
    table.cell(info_table, 1, 0, syminfo.ticker, text_color=color.white, bgcolor=color.new(#1565c0, 0), text_size=size.normal)
    
    // Timeframe
    table.cell(info_table, 0, 1, "Timeframe", text_color=color.white, bgcolor=color.new(#37474f, 0))
    table.cell(info_table, 1, 1, timeframe.period, text_color=color.white, bgcolor=color.new(#37474f, 0))
    
    // Current Price
    table.cell(info_table, 0, 2, "Price", text_color=color.white, bgcolor=color.new(#37474f, 0))
    table.cell(info_table, 1, 2, str.tostring(close, "#.##"), text_color=color.yellow, bgcolor=color.new(#37474f, 0))
    
    // Trend
    trend_color = current_trend == "LUT" or current_trend == "SUT" ? color.new(#00c853, 0) : current_trend == "LDT" or current_trend == "SDT" ? color.new(#d50000, 0) : color.new(#ff9800, 0)
    table.cell(info_table, 0, 3, "Trend", text_color=color.white, bgcolor=color.new(#37474f, 0))
    table.cell(info_table, 1, 3, current_trend, text_color=color.white, bgcolor=trend_color)
    
    // LPH
    table.cell(info_table, 0, 4, "🔴 LPH", text_color=color.white, bgcolor=color.new(c_lph, 50))
    lph_text = na(last_lph_price) ? "—" : str.tostring(last_lph_price, "#.##")
    table.cell(info_table, 1, 4, lph_text, text_color=color.white, bgcolor=color.new(c_lph, 50))
    
    // LPL
    table.cell(info_table, 0, 5, "🟢 LPL", text_color=color.white, bgcolor=color.new(c_lpl, 50))
    lpl_text = na(last_lpl_price) ? "—" : str.tostring(last_lpl_price, "#.##")
    table.cell(info_table, 1, 5, lpl_text, text_color=color.white, bgcolor=color.new(c_lpl, 50))
    
    // SPH
    table.cell(info_table, 0, 6, "↗ SPH", text_color=color.white, bgcolor=color.new(#37474f, 0))
    sph_text = na(last_sph_price) ? "—" : str.tostring(last_sph_price, "#.##")
    table.cell(info_table, 1, 6, sph_text, text_color=color.new(c_sph, 0), bgcolor=color.new(#37474f, 0))
    
    // SPL
    table.cell(info_table, 0, 7, "↘ SPL", text_color=color.white, bgcolor=color.new(#37474f, 0))
    spl_text = na(last_spl_price) ? "—" : str.tostring(last_spl_price, "#.##")
    table.cell(info_table, 1, 7, spl_text, text_color=color.new(c_spl, 0), bgcolor=color.new(#37474f, 0))
    
    // Distance to LPH
    table.cell(info_table, 0, 8, "Δ to LPH", text_color=color.white, bgcolor=color.new(#37474f, 0))
    lph_dist = na(last_lph_price) ? "—" : str.tostring((last_lph_price - close) / close * 100, "#.##") + "%"
    table.cell(info_table, 1, 8, lph_dist, text_color=color.white, bgcolor=color.new(#37474f, 0))
    
    // Distance to LPL
    table.cell(info_table, 0, 9, "Δ to LPL", text_color=color.white, bgcolor=color.new(#37474f, 0))
    lpl_dist = na(last_lpl_price) ? "—" : str.tostring((close - last_lpl_price) / close * 100, "#.##") + "%"
    table.cell(info_table, 1, 9, lpl_dist, text_color=color.white, bgcolor=color.new(#37474f, 0))
    
    // Signal Status
    signal_text = long_entry ? "🟢 LONG" : short_entry ? "🔴 SHORT" : is_uptrend ? "⏳ Wait Long" : is_downtrend ? "⏳ Wait Short" : "⚠ No Trade"
    signal_color = long_entry ? color.new(#00c853, 0) : short_entry ? color.new(#d50000, 0) : color.new(#ff9800, 0)
    table.cell(info_table, 0, 10, "Signal", text_color=color.white, bgcolor=color.new(#1565c0, 0))
    table.cell(info_table, 1, 10, signal_text, text_color=color.white, bgcolor=signal_color)
    
    // Position Size (if signal active)
    if long_entry or short_entry
        table.cell(info_table, 0, 11, "Size", text_color=color.white, bgcolor=color.new(#37474f, 0))
        table.cell(info_table, 1, 11, str.tostring(position_size, "#") + " units", text_color=color.yellow, bgcolor=color.new(#37474f, 0))
    else
        table.cell(info_table, 0, 11, "Risk/Trade", text_color=color.white, bgcolor=color.new(#37474f, 0))
        table.cell(info_table, 1, 11, "$" + str.tostring(i_account_size * i_risk_pct / 100, "#.##"), text_color=color.yellow, bgcolor=color.new(#37474f, 0))

// ===== ALERT CONDITIONS =====
alertcondition(new_lph_marked and i_alert_lph, title="LPH Formed", message="🔴 LPH formed on {{ticker}} {{interval}} at price {{close}}")
alertcondition(new_lpl_marked and i_alert_lpl, title="LPL Formed", message="🟢 LPL formed on {{ticker}} {{interval}} at price {{close}}")
alertcondition(long_entry and i_alert_long, title="Long Entry Signal", message="🟢 LONG ENTRY on {{ticker}} {{interval}} - Price: {{close}}")
alertcondition(short_entry and i_alert_short, title="Short Entry Signal", message="🔴 SHORT ENTRY on {{ticker}} {{interval}} - Price: {{close}}")
alertcondition(trend_changed and i_alert_trend_change, title="Trend Change", message="⚠ Trend changed on {{ticker}} {{interval}}")

// ===== CUSTOM ALERTS WITH FULL TRADE DETAILS =====
if long_entry and i_alert_long
    string alert_msg_long = "🟢 SPX LONG ENTRY\nSymbol: " + syminfo.ticker + "\nTimeframe: " + timeframe.period + "\nEntry: " + str.tostring(entry_level, "#.##") + "\nStop Loss: " + str.tostring(stop_loss_level, "#.##") + "\nTarget: " + str.tostring(target_level, "#.##") + "\nPosition Size: " + str.tostring(position_size, "#") + " units\nRisk: $" + str.tostring(i_account_size * i_risk_pct / 100, "#.##") + "\nR:R = 1:" + str.tostring(i_rr_target, "#.#")
    alert(alert_msg_long, alert.freq_once_per_bar)

if short_entry and i_alert_short
    string alert_msg_short = "🔴 SPX SHORT ENTRY\nSymbol: " + syminfo.ticker + "\nTimeframe: " + timeframe.period + "\nEntry: " + str.tostring(entry_level, "#.##") + "\nStop Loss: " + str.tostring(stop_loss_level, "#.##") + "\nTarget: " + str.tostring(target_level, "#.##") + "\nPosition Size: " + str.tostring(position_size, "#") + " units\nRisk: $" + str.tostring(i_account_size * i_risk_pct / 100, "#.##") + "\nR:R = 1:" + str.tostring(i_rr_target, "#.#")
    alert(alert_msg_short, alert.freq_once_per_bar)
````
