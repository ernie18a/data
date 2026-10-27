# NET LIQUIDITY

- url: https://www.tradingview.com/script/qpz0g9fI/
- type: indicator
- pine_id: PUB;69e539a4cdb043b5b70f87bf9d42ab20
- version: 1.0

## Description

This indicator, titled "NET LIQUIDITY" by Mohamed Abdelhaleem, is a powerful volume-analysis tool. Instead of looking at volume on a candle-by-candle basis, it groups price action into "Cycles" to show you which side (Buyers or Sellers) is truly in control of a specific price range.

Here is the functional breakdown of the indicator in English:

1. Core Logic: Volume Cycles
The script doesn't just show total volume; it categorizes it based on price movement.

Period Length: It groups a specific number of bars (e.g., 7 bars) into one "Cycle."

Buy vs. Sell Volume: Inside each cycle, it adds up the volume of all green candles (Buy Vol) and compares it to the volume of all red candles (Sell Vol).

Net Dominance: If Buy Volume > Sell Volume, the entire cycle is considered Bullish. If Sell Volume > Buy Volume, it is Bearish.

2. Visual Components
A. Pivot Boxes (The Range)

The indicator draws a box that encapsulates the High and Low reached during that specific cycle.

Green Box: Indicates a period where buyers provided more liquidity/effort.

Red Box: Indicates a period where sellers provided more liquidity/effort.

B. Data Labels & Connection Lines

Each box is accompanied by a label showing the exact breakdown of B (Buy Volume) and S (Sell Volume).

A dotted line connects the box to its label, placed strategically above or below the price action to avoid cluttering your candles.

C. The Live Dashboard
On the right side of your chart, a fixed dashboard provides a "Master Summary":

Aggregated Totals: It sums up the total Buy and Sell volume across all visible boxes (the history).

Cycle Progress: It shows a real-time counter (e.g., Bar 4 of 7) so you know exactly when the next box will be drawn.

Current Dominance: The dashboard changes color to match the current cycle's leading side.

3. Strategic Use for Traders
Support & Resistance: These boxes represent areas of "Heavy Participation." Often, the top or bottom of a high-volume box acts as a strong support or resistance level in the future.

Identifying Exhaustion: If the price is rising but the "Net Liquidity" boxes start showing more Sell Volume (Red) or shrinking Buy Volume, it may signal that the trend is losing steam.

Trend Confirmation: When price breaks out of a "Bullish Box" and stays above it, it confirms that the buyers who created that liquidity are successfully defending their positions.

4. Key Settings to Adjust
Pivot Cycle Length: Increase this (e.g., 20) for long-term trend analysis, or decrease it (e.g., 3-5) for scalping.

Max History: Controls how many old boxes remain on the chart to prevent it from becoming too "busy."

Label Offset: Helps you adjust the distance of the text from the candles based on the asset's volatility.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MOHAMED ABDELHALEEM

//@version=6
indicator('NET LIQUIDITY', 'NET LIQUIDITY', overlay = true, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500)

// ———————————————————— INPUTS ———————————————————— {
group_logic = "Cycle & History Settings"
period_length = input.int(7, "Pivot Cycle Length (Bars)", minval = 1, maxval = 500, group = group_logic)
max_history   = input.int(5, "Max Boxes (Total Measure Range)", minval = 1, maxval = 50, group = group_logic)

group_visual = "Visual Customization"
up_color = input.color(#17dfad, 'Bullish Color', group = group_visual)
down_color = input.color(#dd326b, 'Bearish Color', group = group_visual)
box_transp = input.int(85, "Box Transparency", minval = 0, maxval = 100, group = group_visual)
text_size = input.string(size.normal, 'Font Size', options = [size.tiny, size.small, size.normal, size.large, size.huge], group = group_visual)

group_offset = "Strict Positioning"
label_offset_mult = input.float(2.0, "Label Offset Multiplier", minval = 0.5, step = 0.1, group = group_offset)
// }

// ———————————————————— CALCULATIONS ———————————————————— {
var label[] pivot_labels_array = array.new<label>(0)
var box[]   pivot_boxes_array  = array.new<box>(0)
var line[]  pivot_lines_array  = array.new<line>(0)
var float[] buy_history_array  = array.new<float>(0)
var float[] sell_history_array = array.new<float>(0)

var float period_buy_vol  = 0.0
var float period_sell_vol = 0.0
var int   bar_counter     = 0
var float period_high     = na
var float period_low      = na
var int   start_bar_index = 0

if bar_counter == 0
    start_bar_index := bar_index
    period_high     := high
    period_low      := low
else
    period_high     := math.max(period_high, high)
    period_low      := math.min(period_low, low)

period_buy_vol  := period_buy_vol  + (close > open ? volume : 0)
period_sell_vol := period_sell_vol + (close < open ? volume : 0)
bar_counter     := bar_counter + 1

if bar_counter >= period_length
    bool is_bullish = period_buy_vol >= period_sell_vol
    color main_color = is_bullish ? up_color : down_color
    
    new_box = box.new(left = start_bar_index, top = period_high, right = bar_index, bottom = period_low, 
         border_color = main_color, 
         bgcolor = color.new(main_color, box_transp), 
         border_width = 2)
    
    float safety_gap = ta.atr(14) * label_offset_mult
    float label_y = is_bullish ? period_low - safety_gap : period_high + safety_gap
    int mid_x = math.round(math.avg(start_bar_index, bar_index))
    
    new_line = line.new(x1 = mid_x, y1 = is_bullish ? period_low : period_high, x2 = mid_x, y2 = label_y, color = main_color, width = 1, style = line.style_dotted)
    array.push(pivot_lines_array, new_line)

    pivot_text = "PIVOT (" + str.tostring(period_length) + "B)\nB: " + str.tostring(period_buy_vol, format.volume) + "\nS: " + str.tostring(period_sell_vol, format.volume)
    new_pivot = label.new(x = mid_x, y = label_y, text = pivot_text, color = color.new(main_color, 5), textcolor = color.white, style = is_bullish ? label.style_label_up : label.style_label_down, size = size.small)
    
    array.push(pivot_boxes_array, new_box)
    array.push(pivot_labels_array, new_pivot)
    array.push(buy_history_array, period_buy_vol)
    array.push(sell_history_array, period_sell_vol)
    
    while array.size(pivot_boxes_array) > max_history
        box.delete(array.shift(pivot_boxes_array))
        label.delete(array.shift(pivot_labels_array))
        line.delete(array.shift(pivot_lines_array))
        array.shift(buy_history_array)
        array.shift(sell_history_array)
    
    period_buy_vol  := 0.0
    period_sell_vol := 0.0
    bar_counter     := 0
    period_high     := na
    period_low      := na

// ———————————————————— FIXED DASHBOARD ———————————————————— {
// إنشاء الداش بورد مرة واحدة فقط باستخدام var
var label dash = label.new(na, na, "", style = label.style_label_left, size = text_size, textcolor = color.white)

if barstate.islast
    float total_history_buy = 0.0
    float total_history_sell = 0.0
    if array.size(buy_history_array) > 0
        for i = 0 to array.size(buy_history_array) - 1
            total_history_buy  := total_history_buy  + array.get(buy_history_array, i)
            total_history_sell := total_history_sell + array.get(sell_history_array, i)

    current_dom = (period_buy_vol >= period_sell_vol) ? up_color : down_color
    
    dash_text = "MOHAMED ABDELHALEEM\n" + 
                 "DYNAMIC MEASURE V28\n" + 
                 "————————————————\n" + 
                 "TOTAL OF (" + str.tostring(array.size(buy_history_array)) + ") BOXES:\n" +
                 "AGG. BUY: " + str.tostring(total_history_buy, format.volume) + "\n" +
                 "AGG. SELL: " + str.tostring(total_history_sell, format.volume) + "\n" +
                 "————————————————\n" +
                 "CURRENT CYCLE PROGRESS:\n" +
                 "Bars: " + str.tostring(bar_counter) + "/" + str.tostring(period_length) + "\n" +
                 "B: " + str.tostring(period_buy_vol, format.volume) + " | S: " + str.tostring(period_sell_vol, format.volume)

    // تحديث البيانات والموقع بدلاً من الحذف والإنشاء
    label.set_xy(dash, bar_index + 10, hl2)
    label.set_text(dash, dash_text)
    label.set_color(dash, color.new(current_dom, 15))
    label.set_size(dash, text_size)
// }
````
