<!-- tradingview-pine-id: PUB;075e9e3932f14bfb84a6bac637195c07 -->
<!-- tradingviewscripts-format: 1 -->
# Traling.SL.Target

Source: https://www.tradingview.com/script/4jxYYaGU-Traling-SL-Target/

## Description

Trailing SL and Target

I have seen few requests in PineScripters telegram group asking questions about implementation of trailing stop-loss (SL) and targets. This script is one of the way to implement the same.

This script is developed based on dark color theme and is best viewed using dark color theme.

How and where can this script be used:
The script is built to demonstrate how one can implement the trailing SL and target, so by referring the script one can mimic the approach and add trailing SL and target implementation in their own strategy.

How it works:
To demonstrate the SL and target implementation, i have considered simple EMA crossover strategy.

Key Input Parameters
Method to use for SL/Target trailing:
1. % Based Target and SL - Used to calculate trailing based on parameters defined under group '% Based Target SL'
2. Fixed point Based Target and SL - Used to calculate trailing based on parameters defined under group 'Fixed point Based Target and SL'

% Based Target and SL:
Initial profit % - This is used to calculate target when trade is initiated
Initial SL % - This is used to calculate SL when trade is initiated
Initiate trailing % - This parameter determines, when to start trailing SL and target. 
Trail profit by % - Target would be trailed by % specified as this parameter
Trail SL by % - SL would be trailed by % specified as this parameter
e.g. 
Trade type: - Long
Trade price: 10000
initial profit %: 1
Initial SL %: 1
Initiate trailing %: 0.5
Trail profit by %: 0.3
Trail SL by %: 0.4
Calculations based on above:
initial profit %: 10100 (trade price + 1%)
Initial SL %: 9900 (trade price - 1%)
Initiate trailing %: 10049.5 (initial profit - 0.5%)
Trail profit by %: 10130 (initial profit + 0.3%)
Trail SL by %: 9939.6 (initial SL + 0.4%)

For next iteration of Trailing SL and target above calculated values will be taken as a base and next set of values will be calculated. these calculations will continue till the trade is exited either on price reaching profit or SL point.

Fixed point Based Target and SL:
Initial profit target points - To derive initial target, parameter value is added to trade price in case of long trade.
Initial SL points - To derive SL point, parameter value is subtracted from trade price
Initiate trailing points - To derive start of trailing logic, parameter value is subtracted from initial profit point. 
Trail profit by points - In case of long trade, parameter value is added to the profit target to derive new trailed profit target.
Trail SL by % - In case of long trade, parameter value is added to the SL initial point to derive new trailed SL.

Calculation of Trailing SL and target will continue till the trade is exited either on price reaching profit or SL point.

Plots displayed on the chart:
Apart from default trade markings i have added 3 shapes on the chart to describe working of Trailing SL and targets.
Diamond shape marks - These are added on the chart when trade is initiated. These shapes gives additional trade information by way of 'tooltip'. This information can be viewed by placing mouse pointer on the shape.
Circle shape marks  - These are added on the chart whenever Trailing SL and targets are calculated. These shapes gives additional trade information by way of 'tooltip'. This information can be viewed by placing mouse pointer on the shape. You will also notice a number displayed just above or below circle denoting Trailing iteration. 
Labels up and label down shapes - These are dynamically placed on the chart whenever trade is in progress. These labels will display ongoing trades, Target and SL points.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Sharad_Gaikwad
//@version=5

strategy("Traling.SL.Target", overlay=true, process_orders_on_close = true, max_labels_count = 500)
// << Parameters section {
_1 = input.bool(title = "━━━━━━━ ↓ Pivot parameters for trade ↓ ━━━━━━━", defval = false)
fast_len = input.int(title = 'Fast len', defval = 20)
slow_len = input.int(title = 'Slow len', defval = 50)
label_bg_color = input.color(title = 'BG color for ongoing trade SL/Target label', defval=color.white)
sl_target_method = input.string(title = 'Method to be used for SL/Target trailing', defval='% Based Target and SL', options = ['% Based Target and SL','Fix point Based Target and SL'])
_2 = input.bool(title = "━━━━━━━ ↓ % Based Target and SL ↓ ━━━━━━━", defval = true)
initial_profit_percent = input.float(title = 'Inital profit %', defval = 1) / 100
initial_sl_percent = input.float(title = 'Inital SL %', defval = 1) / 100
initiate_trailing_percent = input.float(title = 'Initiate trailing %', defval = 0.5, tooltip = 'Initiate trailing of target and SL after change in price in % after taking trade') / 100
trail_profit_percent = input.float(title = 'Trail profit by %', defval = 0.3) / 100
trail_sl_percent = input.float(title = 'Trail SL by %', defval = 0.3) / 100

_3 = input.bool(title = "━━━━━━━ ↓ Fix point Based Target and SL ↓ ━━━━━━━", defval = false)
initial_profit_points = input.float(title = 'Inital profit target points', defval = 100)
initial_sl_points = input.float(title = 'Inital SL points', defval = 50)
initiate_trailing_points = input.float(title = 'Initiate trailing points', defval = 60, tooltip = 'Initiate trailing of target and SL after change in price in points after taking trade')
trail_profit_points = input.float(title = 'Trail profit by points', defval = 25)
trail_sl_points = input.float(title = 'Trail SL by %', defval = 30)
// } Parameters section >>


// } << Common function {
tab = table.new(position=position.bottom_right, columns=7, rows=200,frame_color = color.yellow, frame_width = 1)
msg(int row, int col, string msg_str, clr=color.blue) =>
    table.cell(table_id=tab, column=col, row=row, text=msg_str, text_color=clr)

getVal(val) =>
    ret_val = na(val) ? 0 : val

t(val) => str.tostring(val, "0.00")

timeToString(int _t) =>
         str.tostring(dayofmonth(_t), '00') + '/' + 
         str.tostring(month(_t), '00') + '/' + 
         str.tostring(year(_t), '0000') + ' ' + 
         str.tostring(hour(_t), '00') + ':' + 
         str.tostring(minute(_t), '00') + ':' + 
         str.tostring(second(_t), '00')
    
// } Common functions>>


// Variable declarations {
percent_based = sl_target_method  == '% Based Target and SL' ? true : false
var initial_long_entry_price = float(na)
var initial_short_entry_price = float(na)
var long_target = float(na)
var long_sl = float(na)
var short_target = float(na)
var short_sl = float(na)
var long_entry_price = float(na)
var short_entry_price = float(na)
var initial_long_percent_target = float(na)
var initial_long_percent_sl = float(na)
var initial_long_point_target = float(na)
var initial_long_point_sl = float(na)
var initial_short_percent_target = float(na)
var initial_short_percent_sl = float(na)
var initial_short_point_target = float(na)
var initial_short_point_sl = float(na)
var is_long = bool(na)
var is_short = bool(na)
var trail_long_iteration = int(na)
var trail_short_iteration = int(na)

// }

// derive important variable values



// Strategy logic
fast_ema = ta.ema(close, fast_len)
slow_ema = ta.ema(close, slow_len)
plot(fast_ema, color = color.red)
plot(slow_ema, color = color.green)
go_long = ta.crossover(fast_ema, slow_ema) and strategy.position_size == 0
go_short = ta.crossunder(fast_ema, slow_ema) and strategy.position_size == 0

// barcolor(ph ? color.purple : na, offset = -lb)
// barcolor(pl ? color.yellow : na, offset = -lb)


// barcolor(ph ? color.white : na)
// barcolor(pl ? color.blue : na)

// //trailing logic for long
long_trailing_point = percent_based ? (close >= long_entry_price + (long_entry_price * initiate_trailing_percent)) :
     (close >= long_entry_price + initiate_trailing_points)

short_trailing_point = percent_based ? (close <= short_entry_price - (short_entry_price * initiate_trailing_percent)) :
     (close >= short_entry_price - initiate_trailing_points)

if(is_long and long_trailing_point)
    // initial_long_percent_target = initial_long_percent_target + (initial_long_percent_target * trail_profit_percent)
    // initial_long_percent_sl = initial_long_percent_sl - (initial_long_percent_sl * trail_sl_percent)

    // initial_long_point_target = initial_long_point_target + trail_profit_points
    // initial_long_point_sl = initial_long_point_sl - trail_sl_points
    trail_long_iteration :=  trail_long_iteration + 1
    long_target := percent_based ? (long_target + (long_target * trail_profit_percent)) : 
         (long_target + trail_profit_points)
         
    long_sl := percent_based ? (long_sl + (long_sl * trail_sl_percent)) :
         (long_sl + trail_sl_points)
    
    long_entry_price := percent_based ? (long_entry_price + (long_entry_price * initiate_trailing_percent)) :
         (long_entry_price + initiate_trailing_points)

if(is_short and short_trailing_point)
    // initial_short_percent_target = initial_short_percent_target - (initial_short_percent_target * trail_profit_percent)
    // initial_short_percent_sl = initial_short_percent_sl + (initial_short_percent_sl * trail_sl_percent)

    // initial_short_point_target = initial_short_point_target - trail_profit_points
    // initial_short_point_sl = initial_short_point_sl + trail_sl_points
    trail_short_iteration :=  trail_short_iteration + 1
    short_target := percent_based ? (short_target - (short_target * trail_profit_percent)) : 
         (short_target - trail_profit_points)
         
    short_sl := percent_based ? (short_sl - (short_sl * trail_sl_percent)) :
         (short_sl - trail_sl_points)
    
    short_entry_price := percent_based ? (short_entry_price - (short_entry_price * initiate_trailing_percent)) :
         (short_entry_price - initiate_trailing_points)
    
if(go_long)
    is_long := true
    is_short := false
    trail_long_iteration := 0
    trail_short_iteration := 0
    initial_long_entry_price := close
    long_entry_price := close
    
    initial_long_percent_target := close + (close * initial_profit_percent)
    initial_long_percent_sl := close - (close * initial_sl_percent)

    initial_long_point_target := close + initial_profit_points
    initial_long_point_sl := close - initial_sl_points
    
    long_target := percent_based ? initial_long_percent_target : initial_long_point_target
    long_sl := percent_based ? initial_long_percent_sl : initial_long_point_sl 
    
    strategy.entry(id = 'Long', direction = strategy.long)

if(go_short)
    is_long := false
    is_short := true
    trail_long_iteration := 0
    trail_short_iteration := 0
    initial_short_entry_price := close
    short_entry_price := close

    initial_short_percent_target := close - (close * initial_profit_percent)
    initial_short_percent_sl := close + (close * initial_sl_percent)

    initial_short_point_target := close - initial_profit_points
    initial_short_point_sl := close + initial_sl_points

    short_target := percent_based ? initial_short_percent_target : initial_short_point_target
    short_sl := percent_based ? initial_short_percent_sl : initial_short_point_sl 
    
    strategy.entry(id = 'Short', direction = strategy.short)

method = percent_based ? '% Based' : 'Fixed Points'
long_tooltip = 'Long @ ' + timeToString(time) + '\n' +
     'Method             : ' + method + '\n' +
     'Initial Trade Price: ' + t(initial_long_entry_price) + '\n' +
     'Inital Target      : ' + t(long_target) + '\n' + 
     'Inital SL          : ' + t(long_sl) 

short_tooltip = 'Short @ ' + timeToString(time) + '\n' +
     'Method             : ' + method + '\n' +
     'Initial Trade Price: ' + t(initial_short_entry_price) + '\n' +
     'Inital Target      : ' + t(short_target) + '\n' + 
     'Inital SL          : ' + t(short_sl)
     
     
label.new(go_long ? bar_index : na, go_long ? bar_index : na,
     style = label.style_diamond, yloc = yloc.belowbar, color = color.green, size=size.tiny, tooltip = long_tooltip)
     
label.new(go_short ? bar_index : na, go_short ? bar_index : na,
     style = label.style_diamond, yloc = yloc.abovebar, color = color.red, size=size.tiny, tooltip = short_tooltip)
 
trail_long_tooltip = 'Trail @ ' + timeToString(time) + '\n' +
     'Iteration no : ' + t(trail_long_iteration) + '\n' +
     'New Target   : ' + t(long_target) + '\n' +
     'New SL       : ' + t(long_sl)

trail_short_tooltip = 'Trail @ ' + timeToString(time) + '\n' +
     'Iteration no : ' + t(trail_short_iteration) + '\n' +
     'New Target   : ' + t(short_target) + '\n' +
     'New SL       : ' + t(short_sl) 

label.new(is_long and long_trailing_point and strategy.position_size > 0 ? bar_index : na, is_long and long_trailing_point and strategy.position_size > 0 ? bar_index : na,
      text = str.tostring(trail_long_iteration), style = label.style_circle, textcolor = color.white, yloc = yloc.belowbar, color = color.green, size=size.tiny, tooltip = trail_long_tooltip)
     
label.new(is_short and short_trailing_point and strategy.position_size < 0 ? bar_index : na, is_short and short_trailing_point and strategy.position_size < 0 ? bar_index : na,
     text = str.tostring(trail_short_iteration), style = label.style_circle, textcolor = color.white,  yloc = yloc.abovebar, color = color.red, size=size.tiny, tooltip = trail_short_tooltip)
     
strategy.close(id = 'Long', when = close <= long_sl, comment = 'SL')
strategy.close(id = 'Short', when = close >= short_sl, comment = 'SL')

strategy.close(id = 'Long', when = close >= long_target, comment = 'Target')
strategy.close(id = 'Short', when = close <= short_target, comment = 'Target')

no_of_labels = 1
label_q(_array, _val) =>
    array.push(_array, _val)
    _return = array.shift(_array)

var target_label = float(na)
var sl_label = float(na)
if(strategy.position_size > 0)
    target_label := long_target
    sl_label := long_sl
else if(strategy.position_size < 0)
    target_label := short_target
    sl_label := short_sl
else
    target_label := float(na)
    sl_label := float(na)

var label[] target_array = array.new_label(no_of_labels)
label.delete(label_q(target_array, label.new(bar_index, target_label, "Target:"+t(target_label), style = label.style_label_down, color = label_bg_color, size=size.small, textcolor = color.green)))

var label[] sl_array = array.new_label(no_of_labels)
label.delete(label_q(sl_array, label.new(bar_index, sl_label, "SL:"+t(sl_label), style = label.style_label_up, color = label_bg_color, size=size.small, textcolor = color.red)))
````
