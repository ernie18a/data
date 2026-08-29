<!-- tradingview-pine-id: PUB;25a1d681ce8e4a57957c7be394c83de9 -->
<!-- tradingviewscripts-format: 1 -->
# SMT Lite - Market Structure Data

Source: https://www.tradingview.com/script/m8bJxDJV-SMT-Lite-Market-Structure-Data/

## Description

SMT Lite is a single-symbol market-structure indicator that identifies confirmed swing structure, supply and demand zones, and breaks of structure on the current chart and timeframe.

It is not a cross-symbol SMT divergence indicator.

Features

[*]HH, LH, HL, and LL swing labels
[*]ATR-scaled supply and demand zones
[*]Point-of-interest midpoint for each zone
[*]Bullish and bearish break-of-structure markers
[*]Optional zigzag
[*]JSON alerts for newly confirmed swing classifications
[*]Status-line data for pivots, volatility, structure, and active zones

Calculations

Swing highs and lows require the selected Swing High/Low Length on both sides of a pivot. Labels appear on the original pivot bar only after the required future bars confirm it.

Zone thickness is calculated using the 50-period ATR:

50 ATR × (Box Width ÷ 10)

Supply zones extend downward from confirmed swing highs. Demand zones extend upward from confirmed swing lows. Nearby overlapping zones are filtered to reduce clutter.

A bullish BOS occurs when price closes at or above an active supply-zone ceiling. A bearish BOS occurs when price closes at or below an active demand-zone floor.

Status-Line Data

The indicator exposes:

[*]Bullish or bearish structural state
[*]Last confirmed pivot high and low
[*]50-period ATR
[*]Closest active supply and demand boundaries
[*]Zone midpoint and age in bars
[*]Current-bar BOS breach price

These values are hidden from the chart scale and available through the indicator status line.

Alerts

Alerts are generated for confirmed HH, LH, HL, and LL events using JSON containing the ticker, structure type, pivot price, and detection time.

Create an alert using “Any alert() function call.”

Important

This indicator does not measure actual order flow or resting liquidity. Zones are derived from confirmed pivots and ATR.

Pivot signals are delayed by design. The active zigzag segment and developing-bar signals may change before the bar closes.

This is an analytical indicator, not a trading strategy or standalone entry signal.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

//@version=6
indicator('SMT Lite - Market Structure Data', overlay = true, max_labels_count = 500, max_boxes_count = 500, max_lines_count = 500, max_bars_back = 1000)

//
//SETTINGS
//
swing_length = input.int(5, title = 'Swing High/Low Length', group = 'Settings', minval = 1, maxval = 50)
history_of_demand_to_keep = input.int(20, title = 'History To Keep', minval = 5, maxval = 50)
box_width = input.float(2.5, title = 'Supply/Demand Box Width', group = 'Settings', minval = 1, maxval = 10, step = 0.5)

show_zigzag = input.bool(false, title = 'Show Zig Zag', group = 'Visual Settings', inline = '1')
show_price_action_labels = input.bool(true, title = 'Show Price Action Labels', group = 'Visual Settings', inline = '2')

supply_color = input.color(color.new(#EDEDED, 70), title = 'Supply Zone', group = 'Visual Settings', inline = '3')
supply_outline_color = input.color(color.new(color.white, 75), title = 'Outline', group = 'Visual Settings', inline = '3')

demand_color = input.color(color.new(#00FFFF, 70), title = 'Demand Zone', group = 'Visual Settings', inline = '4')
demand_outline_color = input.color(color.new(color.white, 75), title = 'Outline', group = 'Visual Settings', inline = '4')

bos_label_color = input.color(color.white, title = 'BOS Label', group = 'Visual Settings', inline = '5')
poi_label_color = input.color(color.white, title = 'POI Label', group = 'Visual Settings', inline = '7')

swing_type_color = input.color(color.black, title = 'Price Action Label', group = 'Visual Settings', inline = '8')
zigzag_color = input.color(color.new(#000000, 0), title = 'Zig Zag', group = 'Visual Settings', inline = '9')

//
//FUNCTIONS
//
f_array_add_pop(array, new_value_to_add) =>
    array.unshift(array, new_value_to_add)
    array.pop(array)

f_sh_sl_labels(array, swing_type) =>
    var string label_text = na
    float pivot_price = array.get(array, 0)

    if swing_type == 1
        label_text := pivot_price >= array.get(array, 1) ? 'HH' : 'LH'
        if show_price_action_labels
            label.new(bar_index - swing_length, pivot_price, text = label_text, style = label.style_label_down, textcolor = swing_type_color, color = color.new(swing_type_color, 100), size = size.tiny)
    else if swing_type == -1
        label_text := pivot_price >= array.get(array, 1) ? 'HL' : 'LL'
        if show_price_action_labels
            label.new(bar_index - swing_length, pivot_price, text = label_text, style = label.style_label_up, textcolor = swing_type_color, color = color.new(swing_type_color, 100), size = size.tiny)

    if not na(label_text)
        alert_json = '{"ticker": "' + syminfo.ticker + '", "type": "' + label_text + '", "price": ' + str.tostring(pivot_price) + ', "time": ' + str.tostring(time) + '}'
        alert(alert_json, alert.freq_once_per_bar)

f_check_overlapping(new_poi, box_array, atr) =>
    atr_threshold = atr * 2
    okay_to_draw = true
    if array.size(box_array) > 0
        for i = 0 to array.size(box_array) - 1 by 1
            box_id = array.get(box_array, i)
            if not na(box_id)
                top = box.get_top(box_id)
                bottom = box.get_bottom(box_id)
                poi = (top + bottom) / 2
                if new_poi >= poi - atr_threshold and new_poi <= poi + atr_threshold
                    okay_to_draw := false
                    break
    okay_to_draw

f_supply_demand(value_array, bn_array, box_array, label_array, box_type, atr) =>
    atr_buffer = atr * (box_width / 10)
    box_left = array.get(bn_array, 0)
    box_right = bar_index
    var float box_top = 0.00
    var float box_bottom = 0.00
    var float poi = 0.00

    if box_type == 1
        box_top := array.get(value_array, 0)
        box_bottom := box_top - atr_buffer
        poi := (box_top + box_bottom) / 2
        poi
    else if box_type == -1
        box_bottom := array.get(value_array, 0)
        box_top := box_bottom + atr_buffer
        poi := (box_top + box_bottom) / 2
        poi

    okay_to_draw = f_check_overlapping(poi, box_array, atr)

    if okay_to_draw
        box.delete(array.get(box_array, array.size(box_array) - 1))
        f_array_add_pop(box_array, box.new(left = box_left, top = box_top, right = box_right, bottom = box_bottom, border_color = box_type == 1 ? supply_outline_color : demand_outline_color, bgcolor = box_type == 1 ? supply_color : demand_color, extend = extend.right, text = box_type == 1 ? 'SUPPLY' : 'DEMAND', text_halign = text.align_center, text_valign = text.align_center, text_color = poi_label_color, text_size = size.small, xloc = xloc.bar_index))

        box.delete(array.get(label_array, array.size(label_array) - 1))
        f_array_add_pop(label_array, box.new(left = box_left, top = poi, right = box_right, bottom = poi, border_color = color.new(poi_label_color, 90), bgcolor = color.new(poi_label_color, 90), extend = extend.right, text = 'POI', text_halign = text.align_left, text_valign = text.align_center, text_color = poi_label_color, text_size = size.small, xloc = xloc.bar_index))

f_sd_to_bos(box_array, bos_array, label_array, zone_type) =>
    float broken_level = na
    if array.size(box_array) > 0
        for i = 0 to array.size(box_array) - 1 by 1
            box_id = array.get(box_array, i)
            if not na(box_id)
                level_to_break = zone_type == 1 ? box.get_top(box_id) : box.get_bottom(box_id)
                if zone_type == 1 and close >= level_to_break or zone_type == -1 and close <= level_to_break
                    broken_level := level_to_break
                    copied_box = box.copy(box_id)
                    f_array_add_pop(bos_array, copied_box)
                    mid = (box.get_top(box_id) + box.get_bottom(box_id)) / 2
                    box.set_top(array.get(bos_array, 0), mid)
                    box.set_bottom(array.get(bos_array, 0), mid)
                    box.set_extend(array.get(bos_array, 0), extend.none)
                    box.set_right(array.get(bos_array, 0), bar_index)
                    box.set_text(array.get(bos_array, 0), 'BOS')
                    box.set_text_color(array.get(bos_array, 0), bos_label_color)
                    box.set_text_size(array.get(bos_array, 0), size.small)
                    box.set_text_halign(array.get(bos_array, 0), text.align_center)
                    box.set_text_valign(array.get(bos_array, 0), text.align_center)
                    box.delete(box_id)
                    box.delete(array.get(label_array, i))
    broken_level

f_extend_box_endpoint(box_array) =>
    for i = 0 to array.size(box_array) - 1 by 1
        box_id = array.get(box_array, i)
        if not na(box_id)
            box.set_right(box_id, bar_index + 100)

//
//CALCULATIONS
//
atr = ta.atr(50)
swing_high = ta.pivothigh(high, swing_length, swing_length)
swing_low = ta.pivotlow(low, swing_length, swing_length)

var swing_high_values = array.new_float(5, 0.00)
var swing_low_values = array.new_float(5, 0.00)
var swing_high_bns = array.new_int(5, 0)
var swing_low_bns = array.new_int(5, 0)

var current_supply_box = array.new_box(history_of_demand_to_keep, na)
var current_demand_box = array.new_box(history_of_demand_to_keep, na)
var current_supply_poi = array.new_box(history_of_demand_to_keep, na)
var current_demand_poi = array.new_box(history_of_demand_to_keep, na)

var supply_bos = array.new_box(5, na)
var demand_bos = array.new_box(5, na)

// Global Scraper Control Metrics
var float last_swing_high_val = na
var float last_swing_low_val = na
var float market_structure_trend_is_bullish = 0.0

if not na(swing_high)
    f_array_add_pop(swing_high_values, swing_high)
    f_array_add_pop(swing_high_bns, bar_index[swing_length])
    f_sh_sl_labels(swing_high_values, 1)
    f_supply_demand(swing_high_values, swing_high_bns, current_supply_box, current_supply_poi, 1, atr)
    last_swing_high_val := swing_high
    market_structure_trend_is_bullish := swing_high >= array.get(swing_high_values, 1) ? 1.0 : 0.0
    market_structure_trend_is_bullish

else if not na(swing_low)
    f_array_add_pop(swing_low_values, swing_low)
    f_array_add_pop(swing_low_bns, bar_index[swing_length])
    f_sh_sl_labels(swing_low_values, -1)
    f_supply_demand(swing_low_values, swing_low_bns, current_demand_box, current_demand_poi, -1, atr)
    last_swing_low_val := swing_low
    market_structure_trend_is_bullish := swing_low >= array.get(swing_low_values, 1) ? 1.0 : 0.0
    market_structure_trend_is_bullish

supply_bos_level = f_sd_to_bos(current_supply_box, supply_bos, current_supply_poi, 1)
demand_bos_level = f_sd_to_bos(current_demand_box, demand_bos, current_demand_poi, -1)

if not na(supply_bos_level)
    market_structure_trend_is_bullish := 1.0
    market_structure_trend_is_bullish
if not na(demand_bos_level)
    market_structure_trend_is_bullish := 0.0
    market_structure_trend_is_bullish

f_extend_box_endpoint(current_supply_box)
f_extend_box_endpoint(current_demand_box)

// ZIG ZAG (Retained background logic execution)
h = ta.highest(high, swing_length * 2 + 1)
l = ta.lowest(low, swing_length * 2 + 1)
f_isMin(len) =>
    l == low[len]
f_isMax(len) =>
    h == high[len]

var dirUp = false
var lastLow = high * 100
var lastHigh = 0.0
var timeLow = bar_index
var timeHigh = bar_index
var line li = na

f_drawLine() =>
    _li_color = show_zigzag ? zigzag_color : color.new(#ffffff, 100)
    line.new(timeHigh - swing_length, lastHigh, timeLow - swing_length, lastLow, xloc.bar_index, color = _li_color, width = 2)

if dirUp
    if f_isMin(swing_length) and low[swing_length] < lastLow
        lastLow := low[swing_length]
        timeLow := bar_index
        line.delete(li)
        li := f_drawLine()
        li
    if f_isMax(swing_length) and high[swing_length] > lastLow
        lastHigh := high[swing_length]
        timeHigh := bar_index
        dirUp := false
        li := f_drawLine()
        li
else
    if f_isMax(swing_length) and high[swing_length] > lastHigh
        lastHigh := high[swing_length]
        timeHigh := bar_index
        line.delete(li)
        li := f_drawLine()
        li
    if f_isMin(swing_length) and low[swing_length] < lastHigh
        lastLow := low[swing_length]
        timeLow := bar_index
        dirUp := true
        li := f_drawLine()
        li


// =========================================================================
// REAL-TIME SPATIAL EXTRACTION ENGINE
// =========================================================================
float s1_top = na
float s1_bottom = na
float s1_poi = na
float s1_age = na
float min_supply_top = na
int closest_supply_idx = na

if array.size(current_supply_box) > 0
    for i = 0 to array.size(current_supply_box) - 1 by 1
        box_id = array.get(current_supply_box, i)
        if not na(box_id)
            t = box.get_top(box_id)
            if na(min_supply_top) or t < min_supply_top
                min_supply_top := t
                closest_supply_idx := i
                closest_supply_idx

if not na(closest_supply_idx)
    box_id = array.get(current_supply_box, closest_supply_idx)
    s1_top := box.get_top(box_id)
    s1_bottom := box.get_bottom(box_id)
    s1_poi := (s1_top + s1_bottom) / 2
    s1_age := bar_index - box.get_left(box_id)
    s1_age

float d1_top = na
float d1_bottom = na
float d1_poi = na
float d1_age = na
float max_demand_bottom = na
int closest_demand_idx = na

if array.size(current_demand_box) > 0
    for i = 0 to array.size(current_demand_box) - 1 by 1
        box_id = array.get(current_demand_box, i)
        if not na(box_id)
            b = box.get_bottom(box_id)
            if na(max_demand_bottom) or b > max_demand_bottom
                max_demand_bottom := b
                closest_demand_idx := i
                closest_demand_idx

if not na(closest_demand_idx)
    box_id = array.get(current_demand_box, closest_demand_idx)
    d1_bottom := box.get_bottom(box_id)
    d1_top := box.get_top(box_id)
    d1_poi := (d1_top + d1_bottom) / 2
    d1_age := bar_index - box.get_left(box_id)
    d1_age


// =========================================================================
// SAFE STATUS LINE ONLY DATA STREAM (Color Coded & Non-Scaling Distorting)
// =========================================================================

// Global System Architecture Anchor Metrics (Blue/White)
plot(market_structure_trend_is_bullish, title = 'Market_Structure_Trend_Is_Bullish', color = color.new(color.blue, 100), display = display.status_line)
plot(close, title = 'Current_Bar_Close_Price', color = color.new(color.white, 100), display = display.status_line)

// Historical Pivot Coordinates & Baseline Volatility (Orange)
plot(last_swing_high_val, title = 'Last_Confirmed_Pivot_High_Price', color = color.new(color.orange, 100), display = display.status_line)
plot(last_swing_low_val, title = 'Last_Confirmed_Pivot_Low_Price', color = color.new(color.orange, 100), display = display.status_line)
plot(atr, title = 'Market_Volatility_ATR', color = color.new(color.orange, 100), display = display.status_line)

// Proximity Supply Zone Boundaries & Lifespan Age (Red Shades)
plot(s1_top, title = 'Closest_Active_Supply_Zone_Ceiling_High', color = color.new(#d32f2f, 100), display = display.status_line)
plot(s1_bottom, title = 'Closest_Active_Supply_Zone_Base_Low', color = color.new(#f44336, 100), display = display.status_line)
plot(s1_poi, title = 'Closest_Active_Supply_Zone_POI_Midpoint', color = color.new(#ef9a9a, 100), display = display.status_line)
plot(s1_age, title = 'Closest_Active_Supply_Zone_Age_In_Bars', color = color.new(#b71c1c, 100), display = display.status_line)

// Proximity Demand Zone Boundaries & Lifespan Age (Green Shades)
plot(d1_top, title = 'Closest_Active_Demand_Zone_Base_High', color = color.new(#4caf50, 100), display = display.status_line)
plot(d1_bottom, title = 'Closest_Active_Demand_Zone_Floor_Low', color = color.new(#388e3c, 100), display = display.status_line)
plot(d1_poi, title = 'Closest_Active_Demand_Zone_POI_Midpoint', color = color.new(#a5d6a7, 100), display = display.status_line)
plot(d1_age, title = 'Closest_Active_Demand_Zone_Age_In_Bars', color = color.new(#1b5e20, 100), display = display.status_line)

// Structural Real-Time Breakout Signals (Teal/Maroon Event Flares)
plot(supply_bos_level, title = 'Current_Bar_Bullish_BOS_Breach_Price', color = color.new(color.teal, 100), display = display.status_line)
plot(demand_bos_level, title = 'Current_Bar_Bearish_BOS_Breach_Price', color = color.new(color.maroon, 100), display = display.status_line)
````
