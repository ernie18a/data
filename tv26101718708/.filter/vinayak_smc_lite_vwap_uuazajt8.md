# VINAYAK- SMC Lite + VWAP

- url: https://www.tradingview.com/script/UuazaJT8-VINAYAK-SMC-Lite-VWAP/
- type: indicator
- pine_id: PUB;1dd1b96bec4e4b8b9a4340d6df973677
- version: 1.0

## Description

How to use:
SMC Zones: The script will automatically plot Supply and Demand zones based on your Swing High/Low Length. Broken zones will convert into "BOS" (Break of Structure) labels.
VWAP: The standard VWAP and its 3 bands are plotted. You can adjust the "Anchor Period" (Session, Week, etc.) and Band multipliers in the settings.
Zig Zag: If you want to see the market structure lines, toggle "Show Zig Zag" in the SMC Visual Settings.

What I Added:
In the VWAP Settings group, you now have:

VWAP Color Mode: A dropdown menu with three options:
Static: Uses a single color of your choice.
Directional (Price vs VWAP): Changes color based on whether the price is above or below the VWAP (Bullish/Bearish).
Slope (Rising/Falling): Changes color based on whether the VWAP line itself is moving up or down.
Color Pickers: Dedicated inputs for the Static Color, Bullish Color, and Bearish Color so you can customize the look without touching the code.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Pmgjiv / © TradingView (VWAP)

//@version=6
indicator("FluidTrades - SMC Lite + VWAP", overlay = true, max_labels_count = 500, max_boxes_count = 500, max_lines_count = 500, max_bars_back = 1000)

// ==========================================
// --- SMC LITE SETTINGS ---
// ==========================================
swing_length = input.int(10, title = 'Swing High/Low Length', group = 'SMC Settings', minval = 1, maxval = 50)
history_of_demand_to_keep = input.int(20, title = 'History To Keep', group = 'SMC Settings', minval = 5, maxval = 50)
box_width = input.float(2.5, title = 'Supply/Demand Box Width', group = 'SMC Settings', minval = 1, maxval = 10, step = 0.5)

// SMC VISUAL SETTINGS
show_zigzag = input.bool(false, title = 'Show Zig Zag', group = 'SMC Visual Settings', inline = '1')
show_price_action_labels = input.bool(false, title = 'Show Price Action Labels', group = 'SMC Visual Settings', inline = '2')

supply_color = input.color(color.new(#EDEDED,70), title = 'Supply', group = 'SMC Visual Settings', inline = '3')
supply_outline_color = input.color(color.new(color.white,75), title = 'Outline', group = 'SMC Visual Settings', inline = '3')

demand_color = input.color(color.new(#00FFFF,70), title = 'Demand', group = 'SMC Visual Settings', inline = '4')
demand_outline_color = input.color(color.new(color.white,75), title = 'Outline', group = 'SMC Visual Settings', inline = '4')

bos_label_color = input.color(color.white, title = 'BOS Label', group = 'SMC Visual Settings', inline = '5')
poi_label_color = input.color(color.white, title = 'POI Label', group = 'SMC Visual Settings', inline = '7')

swing_type_color = input.color(color.black, title = 'Price Action Label', group = 'SMC Visual Settings', inline = '8')
zigzag_color = input.color(color.new(#000000,0), title = 'Zig Zag', group = 'SMC Visual Settings', inline = '9')

// ==========================================
// --- VWAP SETTINGS ---
// ==========================================
hideonDWM = input(false, title="Hide VWAP on 1D or Above", group="VWAP Settings")
var anchor = input.string(defval = "Session", title="Anchor Period",
 options=["Session", "Week", "Month", "Quarter", "Year", "Decade", "Century", "Earnings", "Dividends", "Splits"], group="VWAP Settings")
src = input(title = "Source", defval = hlc3, group="VWAP Settings")
offset = input.int(0, title="Offset", group="VWAP Settings")

vwap_color_mode = input.string("Static", "VWAP Color Mode", options = ["Static", "Directional (Price vs VWAP)", "Slope (Rising/Falling)"], group = "VWAP Settings")
vwap_color_static = input.color(#2962FF, "VWAP Static Color", group = "VWAP Settings")
vwap_color_up = input.color(#089981, "VWAP Bullish Color", group = "VWAP Settings")
vwap_color_dn = input.color(#f23645, "VWAP Bearish Color", group = "VWAP Settings")

BANDS_GROUP = "VWAP Bands Settings"
CALC_MODE_TOOLTIP = "Determines the units used to calculate the distance of the bands. When 'Percentage' is selected, a multiplier of 1 means 1%."
calcModeInput = input.string("Standard Deviation", "Bands Calculation Mode", options = ["Standard Deviation", "Percentage"], group = BANDS_GROUP, tooltip = CALC_MODE_TOOLTIP)
showBand_1 = input(true, title = "", group = BANDS_GROUP, inline = "band_1")
bandMult_1 = input.float(1.0, title = "Bands Multiplier #1", group = BANDS_GROUP, inline = "band_1", step = 0.5, minval=0)
showBand_2 = input(false, title = "", group = BANDS_GROUP, inline = "band_2")
bandMult_2 = input.float(2.0, title = "Bands Multiplier #2", group = BANDS_GROUP, inline = "band_2", step = 0.5, minval=0)
showBand_3 = input(false, title = "", group = BANDS_GROUP, inline = "band_3")
bandMult_3 = input.float(3.0, title = "Bands Multiplier #3", group = BANDS_GROUP, inline = "band_3", step = 0.5, minval=0)

// ==========================================
// --- SMC FUNCTIONS ---
// ==========================================

// FUNCTION TO ADD NEW AND REMOVE LAST IN ARRAY
f_array_add_pop(array, new_value_to_add) =>
    array.unshift(array, new_value_to_add)
    array.pop(array)

// FUNCTION SWING H & L LABELS
f_sh_sl_labels(array, swing_type) =>
    var string label_text = na
    if swing_type == 1
        if array.get(array, 0) >= array.get(array, 1)
            label_text := 'HH'
        else
            label_text := 'LH'
        label.new(bar_index - swing_length, array.get(array,0), text = label_text, style=label.style_label_down, textcolor = swing_type_color, color = color.new(swing_type_color, 100), size = size.tiny)
    
    else if swing_type == -1
        if array.get(array, 0) >= array.get(array, 1)
            label_text := 'HL'
        else
            label_text := 'LL'
        label.new(bar_index - swing_length, array.get(array,0), text = label_text, style=label.style_label_up, textcolor = swing_type_color, color = color.new(swing_type_color, 100), size = size.tiny)

// FUNCTION MAKE SURE SUPPLY ISNT OVERLAPPING
f_check_overlapping(new_poi, box_array, atr_val) =>
    atr_threshold = atr_val * 2
    okay_to_draw = true
    if array.size(box_array) > 0
        for i = 0 to array.size(box_array) - 1
            box_id = array.get(box_array, i)
            if not na(box_id)
                top = box.get_top(box_id)
                bottom = box.get_bottom(box_id)
                poi = (top + bottom) / 2

                upper_boundary = poi + atr_threshold
                lower_boundary = poi - atr_threshold

                if new_poi >= lower_boundary and new_poi <= upper_boundary
                    okay_to_draw := false
                    break
    okay_to_draw

// FUNCTION TO DRAW SUPPLY OR DEMAND ZONE
f_supply_demand(value_array, bn_array, box_array, label_array, box_type, atr_val) =>
    atr_buffer = atr_val * (box_width / 10)
    box_left = array.get(bn_array, 0)
    box_right = bar_index

    var float box_top = 0.00
    var float box_bottom = 0.00
    var float poi = 0.00

    if box_type == 1
        box_top := array.get(value_array, 0)
        box_bottom := box_top - atr_buffer
        poi := (box_top + box_bottom) / 2
    else if box_type == -1
        box_bottom := array.get(value_array, 0)
        box_top := box_bottom + atr_buffer
        poi := (box_top + box_bottom) / 2

    okay_to_draw = f_check_overlapping(poi, box_array, atr_val)

    if okay_to_draw
        box_to_del = array.get(box_array, array.size(box_array) - 1)
        if not na(box_to_del)
            box.delete(box_to_del)
        
        new_box = box.new(left = box_left, top = box_top, right = box_right, bottom = box_bottom, border_color = (box_type == 1 ? supply_outline_color : demand_outline_color),
             bgcolor = (box_type == 1 ? supply_color : demand_color), extend = extend.right, text = (box_type == 1 ? 'SUPPLY' : 'DEMAND'), text_halign = text.align_center, text_valign = text.align_center, text_color = poi_label_color, text_size = size.small, xloc = xloc.bar_index)
        f_array_add_pop(box_array, new_box)
        
        label_box_to_del = array.get(label_array, array.size(label_array) - 1)
        if not na(label_box_to_del)
            box.delete(label_box_to_del)
            
        new_label_box = box.new(left = box_left, top = poi, right = box_right, bottom = poi, border_color = color.new(poi_label_color, 90),
             bgcolor = color.new(poi_label_color, 90), extend = extend.right, text = 'POI', text_halign = text.align_left, text_valign = text.align_center, text_color = poi_label_color, text_size = size.small, xloc = xloc.bar_index)
        f_array_add_pop(label_array, new_label_box)

// FUNCTION TO CHANGE SUPPLY/DEMAND TO A BOS IF BROKEN
f_sd_to_bos(box_array, bos_array, label_array, zone_type) =>
    if array.size(box_array) > 0
        for i = 0 to array.size(box_array) - 1
            box_id = array.get(box_array, i)
            if not na(box_id)
                level_to_break = zone_type == 1 ? box.get_top(box_id) : box.get_bottom(box_id)
                condition = zone_type == 1 ? close >= level_to_break : close <= level_to_break
                if condition
                    copied_box = box.copy(box_id)
                    f_array_add_pop(bos_array, copied_box)
                    mid = (box.get_top(box_id) + box.get_bottom(box_id)) / 2
                    
                    target_bos = array.get(bos_array, 0)
                    box.set_top(target_bos, mid)
                    box.set_bottom(target_bos, mid)
                    box.set_extend(target_bos, extend.none)
                    box.set_right(target_bos, bar_index)
                    box.set_text(target_bos, 'BOS')
                    box.set_text_color(target_bos, bos_label_color)
                    box.set_text_size(target_bos, size.small)
                    box.set_text_halign(target_bos, text.align_center)
                    box.set_text_valign(target_bos, text.align_center)
                    
                    box.delete(box_id)
                    label_box_id = array.get(label_array, i)
                    if not na(label_box_id)
                        box.delete(label_box_id)

// FUNCTION MANAGE CURRENT BOXES BY CHANGING ENDPOINT
f_extend_box_endpoint(box_array) =>
    if array.size(box_array) > 0
        for i = 0 to array.size(box_array) - 1
            box_id = array.get(box_array, i)
            if not na(box_id)
                box.set_right(box_id, bar_index + 100)

// ==========================================
// --- SMC CORE LOGIC ---
// ==========================================

// CALCULATE ATR 
smc_atr = ta.atr(50)

// CALCULATE SWING HIGHS & SWING LOWS
swing_high = ta.pivothigh(high, swing_length, swing_length)
swing_low = ta.pivotlow(low, swing_length, swing_length)

// ARRAYS FOR SWING H/L & BN 
var swing_high_values = array.new_float(5, 0.00)
var swing_low_values = array.new_float(5, 0.00)
var swing_high_bns = array.new_int(5, 0)
var swing_low_bns = array.new_int(5, 0)

// ARRAYS FOR SUPPLY / DEMAND
var current_supply_box = array.new_box(history_of_demand_to_keep, na)
var current_demand_box = array.new_box(history_of_demand_to_keep, na)

// ARRAYS FOR SUPPLY / DEMAND POI LABELS
var current_supply_poi = array.new_box(history_of_demand_to_keep, na)
var current_demand_poi = array.new_box(history_of_demand_to_keep, na)

// ARRAYS FOR BOS
var supply_bos = array.new_box(5, na)
var demand_bos = array.new_box(5, na)

// NEW SWING HIGH
if not na(swing_high)
    f_array_add_pop(swing_high_values, swing_high)
    f_array_add_pop(swing_high_bns, bar_index[swing_length])
    if show_price_action_labels
        f_sh_sl_labels(swing_high_values, 1)
    f_supply_demand(swing_high_values, swing_high_bns, current_supply_box, current_supply_poi, 1, smc_atr)

// NEW SWING LOW
else if not na(swing_low)
    f_array_add_pop(swing_low_values, swing_low)
    f_array_add_pop(swing_low_bns, bar_index[swing_length])
    if show_price_action_labels
        f_sh_sl_labels(swing_low_values, -1)
    f_supply_demand(swing_low_values, swing_low_bns, current_demand_box, current_demand_poi, -1, smc_atr)

f_sd_to_bos(current_supply_box, supply_bos, current_supply_poi, 1)
f_sd_to_bos(current_demand_box, demand_bos, current_demand_poi, -1)

f_extend_box_endpoint(current_supply_box)
f_extend_box_endpoint(current_demand_box)

// ZIG ZAG
zz_h = ta.highest(high, swing_length * 2 + 1)
zz_l = ta.lowest(low, swing_length * 2 + 1)
f_isMin(len) => zz_l == low[len]
f_isMax(len) => zz_h == high[len]

var dirUp = false
var lastLow = high * 100
var lastHigh = 0.0
var timeLow = bar_index
var timeHigh = bar_index
var line zz_li = na

f_drawZZLine() =>
    _li_color = show_zigzag ? zigzag_color : color.new(#ffffff, 100)
    line.new(timeHigh - swing_length, lastHigh, timeLow - swing_length, lastLow, xloc.bar_index, color=_li_color, width=2)

if dirUp
    if f_isMin(swing_length) and low[swing_length] < lastLow
        lastLow := low[swing_length]
        timeLow := bar_index
        line.delete(zz_li)
        zz_li := f_drawZZLine()

    if f_isMax(swing_length) and high[swing_length] > lastLow
        lastHigh := high[swing_length]
        timeHigh := bar_index
        dirUp := false
        zz_li := f_drawZZLine()

if not dirUp
    if f_isMax(swing_length) and high[swing_length] > lastHigh
        lastHigh := high[swing_length]
        timeHigh := bar_index
        line.delete(zz_li)
        zz_li := f_drawZZLine()
    if f_isMin(swing_length) and low[swing_length] < lastHigh
        lastLow := low[swing_length]
        timeLow := bar_index
        dirUp := true
        zz_li := f_drawZZLine()
        if f_isMax(swing_length) and high[swing_length] > lastLow
            lastHigh := high[swing_length]
            timeHigh := bar_index
            dirUp := false
            zz_li := f_drawZZLine()

// ==========================================
// --- VWAP CORE LOGIC ---
// ==========================================

cumVolume = ta.cum(volume)
if barstate.islast and cumVolume == 0
    runtime.error("No volume is provided by the data vendor.")

isNewPeriod = switch anchor
	"Earnings" => 
		new_earnings_actual = request.earnings(syminfo.tickerid, earnings.actual, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
		new_earnings_standardized = request.earnings(syminfo.tickerid, earnings.standardized, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
		not na(new_earnings_actual) or not na(new_earnings_standardized)
	"Dividends" => 
		new_dividends = request.dividends(syminfo.tickerid, dividends.gross, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
		not na(new_dividends)
	"Splits"    => 
		new_split = request.splits(syminfo.tickerid, splits.denominator, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
		not na(new_split)
	"Session"   => timeframe.change("D")
	"Week"      => timeframe.change("W")
	"Month"     => timeframe.change("M")
	"Quarter"   => timeframe.change("3M")
	"Year"      => timeframe.change("12M")
	"Decade"    => timeframe.change("12M") and year % 10 == 0
	"Century"   => timeframe.change("12M") and year % 100 == 0
	=> false

isEsdAnchor = anchor == "Earnings" or anchor == "Dividends" or anchor == "Splits"
if na(src[1]) and not isEsdAnchor
	isNewPeriod := true

float vwapValue = na
float upperBandValue1 = na
float lowerBandValue1 = na
float upperBandValue2 = na
float lowerBandValue2 = na
float upperBandValue3 = na
float lowerBandValue3 = na

if not (hideonDWM and timeframe.isdwm)
    [_vwap, _stdevUpper, _] = ta.vwap(src, isNewPeriod, 1)
	vwapValue := _vwap
    stdevAbs = _stdevUpper - _vwap
	bandBasis = calcModeInput == "Standard Deviation" ? stdevAbs : _vwap * 0.01
	upperBandValue1 := _vwap + bandBasis * bandMult_1
	lowerBandValue1 := _vwap - bandBasis * bandMult_1
	upperBandValue2 := _vwap + bandBasis * bandMult_2
	lowerBandValue2 := _vwap - bandBasis * bandMult_2
	upperBandValue3 := _vwap + bandBasis * bandMult_3
	lowerBandValue3 := _vwap - bandBasis * bandMult_3

// ==========================================
// --- VWAP VISUALS ---
// ==========================================

vwap_final_color = vwap_color_mode == "Static" ? vwap_color_static : 
                   vwap_color_mode == "Directional (Price vs VWAP)" ? (close > vwapValue ? vwap_color_up : vwap_color_dn) :
                   (vwapValue > vwapValue[1] ? vwap_color_up : vwap_color_dn)

plot(vwapValue, title = "VWAP", color = vwap_final_color, offset = offset)

displayBand1 = showBand_1 ? display.all : display.none
upperBand_1 = plot(upperBandValue1, title="Upper Band #1", color = color.green, offset = offset, display = displayBand1, editable = showBand_1)
lowerBand_1 = plot(lowerBandValue1, title="Lower Band #1", color = color.green, offset = offset, display = displayBand1, editable = showBand_1)
fill(upperBand_1, lowerBand_1,      title="Bands Fill #1", color = color.new(color.green, 95),   display = displayBand1, editable = showBand_1)

displayBand2 = showBand_2 ? display.all : display.none
upperBand_2 = plot(upperBandValue2, title="Upper Band #2", color = color.olive, offset = offset, display = displayBand2, editable = showBand_2)
lowerBand_2 = plot(lowerBandValue2, title="Lower Band #2", color = color.olive, offset = offset, display = displayBand2, editable = showBand_2)
fill(upperBand_2, lowerBand_2,      title="Bands Fill #2", color = color.new(color.olive, 95),   display = displayBand2, editable = showBand_2)

displayBand3 = showBand_3 ? display.all : display.none
upperBand_3 = plot(upperBandValue3, title="Upper Band #3", color = color.teal, offset = offset, display = displayBand3, editable = showBand_3)
lowerBand_3 = plot(lowerBandValue3, title="Lower Band #3", color = color.teal, offset = offset, display = displayBand3, editable = showBand_3)
fill(upperBand_3, lowerBand_3,      title="Bands Fill #3", color = color.new(color.teal, 95),   display = displayBand3, editable = showBand_3)
````
