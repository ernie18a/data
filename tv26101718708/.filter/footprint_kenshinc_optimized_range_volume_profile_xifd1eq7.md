# Footprint (KenshinC) - Optimized + Range Volume Profile

- url: https://www.tradingview.com/script/Xifd1EQ7-Footprint-KenshinC-Optimized-Range-Volume-Profile/
- type: indicator
- pine_id: PUB;d664d2f3ce6c4b5f940bd045a091b0b8
- version: 1.0

## Description

[b]Footprint (KenshinC) [/b]
Professional Order Flow Footprint + Range Volume ProfileTake your order flow analysis to the next level.Footprint (KenshinC) is a powerful, clean, and highly optimized Footprint Chart designed specifically for serious crypto traders who want to see real market intent — not just price action.
[b]Key Features:[/b]
Precise Footprint Visualization — View buy and sell volume distribution at every price level with clear imbalance detection
Smart Imbalance Detection — Configurable imbalance ratio + stacked imbalance lines to spot aggressive buying/selling pressure
Value Area (VAH, VAL, POC) — Automatically calculates and displays the Value Area with customizable POC highlighting
Range Volume Profile — Cumulative horizontal volume profile across your selected time range — perfect for identifying high-volume nodes, support & resistance zones
Auto & Manual Ticks Per Row — Flexible row sizing with intelligent auto-calculation
Native Footprint Support (v6) — Option to use TradingView’s native footprint engine for maximum accuracy (Premium+)
Clean Alerts System — Get notified on new imbalances, imbalance lines, and breaks

Whether you're scalping on low timeframes or analyzing institutional footprints on higher timeframes, this indicator gives you X-ray vision into the order book flow.Built with performance in mind — optimized request handling, minimal lag, and clean visuals even on volatile crypto pairs like BTC, ETH, SOL, or altcoins.Perfect for:Order Flow Traders
Smart Money Concept (SMC) traders
Volume Profile enthusiasts
ICT & Wyckoff method users

Stop guessing where the real liquidity is.
See it. Trade it.

## Source Code

````pine
//@version=6
indicator("Footprint (KenshinC) - Optimized + Range Volume Profile", shorttitle = "Footprint (KenshinC)", overlay = true, 
     max_labels_count = 500, max_boxes_count = 1000, max_lines_count = 500, dynamic_requests = true)

// ==================== Imports ====================
import dboichenko/footprint_type/2 as footprint_type
import dboichenko/footprint_logic/6 as footprint_logic
import dboichenko/footpint_droving/9 as footpint_droving

// ==================== Inputs ====================
start = input.time(0, confirm = true, title = "Start range", group = "Coordinates")
end   = input.time(0, confirm = true, title = "End range", group = "Coordinates")
extend_right = input.bool(false, "Extend Right", group = "Coordinates")

if start > end
    temp = start
    start := end
    end := temp

if extend_right
    end := timenow

show_cond_test = time >= start and time <= end

// Row size
tick_per_row      = input.int(40, "Ticks Per Row", minval = 0, inline = "2", group = "Row size")
auto_tick_per_row = input.bool(true, "Auto", inline = "2", group = "Row size")
max_label_in_row  = input.int(7, "Max rows", inline = "2", minval = 1, maxval = 100, group = "Row size")

// Imbalance
inbalance_percent = input.int(300, "Imbalance Percent", minval = 0, inline = "3", group = "Imbalance")
stacked_input     = input.int(4, "Stacked levels", minval = 1, inline = "3", group = "Imbalance")

// Value Area & Profile
show_summary_footprint = input.bool(true, "Show footprint info", group = "Display")
procent_volume_area    = input.int(70, "Value Area (%)", group = "Value area", minval = 0, maxval = 100)
show_poc  = input.bool(true,  "POC", group = "Value area", inline = "6")
show_vah  = input.bool(false, "VAH", group = "Value area", inline = "5")
show_val  = input.bool(false, "VAL", group = "Value area", inline = "4")
color_val = input.color(color.new(#2962ff, 0), inline = "4", group = "Value area", title = "")
color_vah = input.color(color.new(#2962ff, 0), inline = "5", group = "Value area", title = "")
color_poc = input.color(color.new(#f44336, 0), inline = "6", group = "Value area", title = "")

show_volume_profile = input.bool(false, "Show Volume Profile per bar", group = "Value area")
show_range_profile  = input.bool(true,  "Show Range Volume Profile (Cumulative)", group = "Value area")
range_profile_width = input.int(35, "Range Profile Width (%)", minval = 10, maxval = 80, group = "Value area")

// Alert
new_imbalance_cond         = input.bool(false, "Alert on new imbalance", group = "Alert")
new_imbalance_line_cond    = input.bool(false, "Alert on new imbalance line", group = "Alert")
stop_past_imbalance_line_cond = input.bool(false, "Alert on stop past imbalance line", group = "Alert")

// Advanced
use_manual_tf        = input.bool(false, "Use manual timeframe instead of auto", group = "Row size")
detail_tf_input      = input.timeframe("1S", "Manual Calculation Timeframe", group = "Row size")
use_native_footprint = input.bool(false, "Use Native Footprint (v6 - Premium+)", group = "Advanced")

// ==================== Constants & Variables ====================
imbalance_high_char = "🟢"
imbalance_low_char  = "🔴"
color_title_sell = color.new(#f23645, 0)
color_title_buy  = color.new(#089981, 0)
var color_line_sell = color.new(#f23645, 50)
var color_line_buy  = color.new(#089981, 50)
color_title_none = color.new(#2a2e39, 100)
row_line_color = close - close[1] >= 0 ? color.new(#089981, 80) : color.new(#f23645, 80)

// Persistent variables
var string  chosen_tf   = na
var float   row_size    = na
var bool    isBuyVolume = true

var footprint_type.Footprint_info_var_object var_info = footprint_type.Footprint_info_var_object.new(
     cum_info = table.new(position.bottom_right, 3, 5, border_width = 1, frame_width = 1, 
     border_color = chart.fg_color, frame_color = chart.fg_color))

var footprint_type.Imbalance_line_var_object var_imba_line = footprint_type.Imbalance_line_var_object.new(
     array.new<line>(), array.new<line>())

// Range Volume Profile
var map<float, float> range_total_volume = map.new<float, float>()
var float range_poc_price = na
var float range_max_volume = 0.0
var array<box> range_profile_boxes = array.new<box>()

// ==================== Support Functions ====================
get_auto_tick_per_row() =>
    temp_tick_per_row = 1
    temp_row_size = temp_tick_per_row * syminfo.mintick
    while low + max_label_in_row * temp_row_size <= high
        temp_tick_per_row += 1
        temp_row_size := temp_tick_per_row * syminfo.mintick
    temp_row_size

get_detail_data_lower() =>
    tf_to_use = use_manual_tf ? detail_tf_input : (na(chosen_tf) ? timeframe.period : chosen_tf)
    [d_open, d_high, d_low, d_close, d_vol, d_prev_close] = 
         request.security_lower_tf("", tf_to_use, [open, high, low, close, volume, close[1]], calc_bars_count = 10000)
    [d_open, d_high, d_low, d_close, d_vol, d_prev_close, tf_to_use]

// Detect chosen_tf (Global Scope)
if na(chosen_tf) and not use_manual_tf
    tf_array = array.from("1S","5S","10S","15S","30S","45S","1","5","15","30","60","120","240","1D")
    for tf in tf_array
        test_tf = timeframe.in_seconds(timeframe.period) < timeframe.in_seconds(tf) ? timeframe.period : tf
        test_data = request.security_lower_tf("", test_tf, close, calc_bars_count = 10000)
        if array.size(test_data) > 0 or barstate.islast
            chosen_tf := test_tf
            break

// ==================== Main Logic ====================
if show_cond_test
    if na(row_size)
        row_size := auto_tick_per_row and time == start ? get_auto_tick_per_row() : tick_per_row * syminfo.mintick

    array<float> detail_open          = array.new<float>()
    array<float> detail_high          = array.new<float>()
    array<float> detail_low           = array.new<float>()
    array<float> detail_close         = array.new<float>()
    array<float> detail_vol           = array.new<float>()
    array<float> previos_detail_close = array.new<float>()
    string       calc_tf              = ""

    if use_native_footprint
        calc_tf := "Native v6"
        detail_open          := array.from(open)
        detail_high          := array.from(high)
        detail_low           := array.from(low)
        detail_close         := array.from(close)
        detail_vol           := array.from(volume)
        previos_detail_close := array.from(close[1])
    else
        [d_open, d_high, d_low, d_close, d_vol, d_prev_close, tf_used] = get_detail_data_lower()
        detail_open          := d_open
        detail_high          := d_high
        detail_low           := d_low
        detail_close         := d_close
        detail_vol           := d_vol
        previos_detail_close := d_prev_close
        calc_tf              := tf_used

    bool bar_index_show_condition = array.size(previos_detail_close) > 0 and array.size(detail_close) > 0

    // Footprint from library
    sup = footprint_type.Support_objects.new(
         consts = footprint_type.Constants.new(
             imbalance_high_char, imbalance_low_char, color_title_sell, color_title_buy, 
             color_line_sell, color_line_buy, color_title_none),
         inp = footprint_type.Inputs.new(
             inbalance_percent, stacked_input, show_summary_footprint, procent_volume_area,
             show_vah, show_poc, show_val, color_vah, color_poc, color_val, show_volume_profile,
             new_imbalance_cond, new_imbalance_line_cond, stop_past_imbalance_line_cond),
         bar_index_show_condition = bar_index_show_condition,
         row_line_color = row_line_color,
         dop_info = str.format("\n\nCalc TF = {0}\nRow size = {1}\nTicks per Row = {2}", 
              calc_tf, row_size, math.round(row_size / syminfo.mintick)),
         show_table_cond = (end == time) or barstate.islast
    )

    foot_bar = footprint_type.Footprint_bar.new(
         foot_rows = array.new<footprint_type.Footprint_row>(),
         val_area  = footprint_type.Value_area.new(),
         imba_line = footprint_type.Imbalance_line.new(array.new<float>(), array.new<float>(), var_imba_line),
         info = footprint_type.Footprint_info.new(var_info),
         row_size = row_size,
         calc_data = footprint_type.Calculation_data.new(
             detail_open, detail_high, detail_low, detail_close, detail_vol, previos_detail_close, isBuyVolume),
         foot_max_price_vol = map.new<float, float>()
    )

    if bar_index_show_condition
        foot_bar.fill_footprint_object(sup)
        foot_bar.print_droving(sup)

    // === Accumulate Range Volume Profile ===
    if show_range_profile and bar_index_show_condition and volume > 0
        float price_level = math.round(close / row_size) * row_size
        
        if map.contains(range_total_volume, price_level)
            map.put(range_total_volume, price_level, map.get(range_total_volume, price_level) + volume)
        else
            map.put(range_total_volume, price_level, volume)

        float this_vol = map.get(range_total_volume, price_level)
        if this_vol > range_max_volume
            range_max_volume := this_vol
            range_poc_price := price_level

// ==================== Draw Range Volume Profile on last bar ====================
if show_range_profile and barstate.islast and map.size(range_total_volume) > 0
    // Xóa profile cũ
    for b in range_profile_boxes
        box.delete(b)
    array.clear(range_profile_boxes)

    float max_vol = range_max_volume > 0 ? range_max_volume : 1
    int   left_pos = bar_index + 3

    // Vẽ histogram
    for [price_level, vol] in range_total_volume
        if vol > 0
            float width_factor = vol / max_vol
            int   bar_width = math.round(width_factor * (range_profile_width / 100) * 40)
            
            color box_color = (price_level == range_poc_price) ? color.new(#f44336, 10) : color.new(#089981, 60)
            
            box b = box.new(
                 left   = left_pos,
                 top    = price_level + row_size / 2,
                 right  = left_pos + bar_width,
                 bottom = price_level - row_size / 2,
                 bgcolor = box_color,
                 border_color = na,
                 extend = extend.none
            )
            array.push(range_profile_boxes, b)

    // Label POC
    if not na(range_poc_price)
        label.new(bar_index + (range_profile_width / 8) + 8, range_poc_price, " POC ", 
             color = color.new(#f44336, 0), style = label.style_label_left, size = size.small, textcolor = color.white)
````
