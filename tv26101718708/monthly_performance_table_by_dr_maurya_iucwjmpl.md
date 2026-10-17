# Monthly Performance Table  by Dr. Maurya

- url: https://www.tradingview.com/script/IucWjmpl-Monthly-Performance-Table-by-Dr-Maurya/
- type: strategy
- pine_id: PUB;a1f92b91393b4328ba02e863e3035bbd
- version: 6.0

## Description

What is this ?
This Strategy script is not aim to produce strategy results but It aim to produce monthly PnL performance Calendar table which is useful for TradingView community to generate a monthly performance table for Own strategy.

So make sure to read the disclaimer below.

Why it is required to publish?:
I am not satisfied with the monthly performance available on TV community script. Sometimes it is very lengthy in code and sometimes it showing the wrong PNL for current month.
So I have decided to develop new Monthly performance or return in value as well as in percentage with highly flexible to adjust row automatically.

Features :
Accuracy increased for current month PnL.
There are 14 columns and automatically adjusted rows according to available trade years/month.
First Column reflect the YEAR, from second column to 13 column reflect the month and 14 column reflect the yearly PnL.
In tabulated data reflects the monthly PnL (value and (%)) in month column and Yearly PnL (value and (%)) in Yearly column.
Various color input also added to change the table look like background color, text color, heading text color, border color.
In tabulated data, background color turn green for profit and red for loss.

Copy from line 54 to last line as it is in your strategy script.

Credit: This code is modified and top up of the open-source code originally written by QuantNomad. Thanks for their contribution towards to give base and lead to other developers. I have changed the way of determining past PnL to array form and keep separated current month and year PnL from array. Which avoid the false pnl in current month.

Strategy description:
As in first line I said This strategy is aim to provide monthly performance table not focused on the strategy. But it is necessary to explain strategy which I have used here. Strategy is simply based on ADX available on TV community script. Long entry is based on when the difference between DIPlus and ADX is reached on certain value (Set value in Long difference in Input Tab) while Short entry is based on when the difference between DIMinus and ADX is reached on certain value (Set value in Short difference in Input Tab).


Default Strategy Properties used on chart(Important)

This script backtest is done on 1 hour timeframe of NSE:Reliance Inds Future cahrt, using the following backtesting properties:

Balance (default): 500 000 (default base currency)
Order Size: 1 contract
Comission: 20 INR per Order
Slippage: 5 tick


Default setting in Input tab 

Len (ADX length) : 14
Th (ADX Threshhold): 20
Long Difference (DIPlus - ADX) = 5
Short Difference (DIMinus - ADX) = 5

We use these properties to ensure a realistic preview of the backtesting system, do note that default properties can be different for various reasons described below:

Order Size: 1 contract by default, this is to allow the strategy to run properly on most instruments such as futures.
Comission: Comission can vary depending on the market and instrument, there is no default value that might return realistic results.
We strongly recommend all users to ensure they adjust the Properties within the script settings to be in line with their accounts & trading platforms of choice to ensure results from the strategies built are realistic.


Disclaimer:
This script not provide indicative of any future results.
This script don’t provide any financial advice.
This strategy is only for the readymade snippet code for monthly PnL performance calender table for any own strategy.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MAURYA_ALGO_TRADER
// last best version 45.0
//@version=5
strategy("Monthly Performance by Dr. Maurya", overlay=true, default_qty_value = 15, commission_type = strategy.commission.percent, commission_value = 0.1)


len = input(14)
th = input(20)

TrueRange = math.max(math.max(high - low, math.abs(high - nz(close[1]))), math.abs(low - nz(close[1])))
DirectionalMovementPlus = high - nz(high[1]) > nz(low[1]) - low ? math.max(high - nz(high[1]), 0) : 0
DirectionalMovementMinus = nz(low[1]) - low > high - nz(high[1]) ? math.max(nz(low[1]) - low, 0) : 0

SmoothedTrueRange = 0.0
SmoothedTrueRange := nz(SmoothedTrueRange[1]) - nz(SmoothedTrueRange[1]) / len + TrueRange

SmoothedDirectionalMovementPlus = 0.0
SmoothedDirectionalMovementPlus := nz(SmoothedDirectionalMovementPlus[1]) - nz(SmoothedDirectionalMovementPlus[1]) / len + DirectionalMovementPlus

SmoothedDirectionalMovementMinus = 0.0
SmoothedDirectionalMovementMinus := nz(SmoothedDirectionalMovementMinus[1]) - nz(SmoothedDirectionalMovementMinus[1]) / len + DirectionalMovementMinus

DIPlus = SmoothedDirectionalMovementPlus / SmoothedTrueRange * 100
DIMinus = SmoothedDirectionalMovementMinus / SmoothedTrueRange * 100
DX = math.abs(DIPlus - DIMinus) / (DIPlus + DIMinus) * 100
ADX = ta.sma(DX, len)


//diff_1 = math.abs(DIPlus - DIMinus)
diff_2 = math.abs(DIPlus-ADX)
diff_3 = math.abs(DIMinus - ADX)

long_diff = input(10, "Long Difference")
short_diff = input(10, "Short Difference")

buy_condition = diff_2 >=long_diff and diff_3 >=long_diff and (ADX < DIPlus and ADX > DIMinus)
sell_condition = diff_2 >=short_diff and diff_3 >=short_diff and (ADX > DIPlus and ADX < DIMinus)


if buy_condition
    strategy.entry("Long Entry", strategy.long, comment = "Long")
if sell_condition
    strategy.entry("Short Entry", strategy.short, comment = "Short")



// Copy below code to end of the desired strategy script
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                 monthly pnl performance  by Dr. Maurya @MAURYA_ALGO_TRADER                        //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
show_performance = input.bool(true, 'Show Monthly Monthly Performance ?', group='Monthly Performance')

dash_loc_mp = input.session("Bottom Right","Location"  ,options=["Top Right","Bottom Right","Top Left","Bottom Left", "Middle Right","Bottom Center"]  ,group='Monthly Performance', inline = "performance")

text_size_mp = input.session('Small',"Size"  ,options=["Tiny","Small","Normal","Large"]  ,group='Monthly Performance', inline = "performance")

bg_c = input.color( color.rgb(7, 226, 242, 38), "Background Color", group='Monthly Performance')

text_head_color = input.color( color.rgb(0,0,0), "Month/Year Heading Color", group='Monthly Performance')

tab_month_c = input.color( color.white, "Month PnL Data Color", group='Monthly Performance')

tab_year_c = input.color( color.rgb(0,0,0), "Year PnL Data Color", group='Monthly Performance')

border_c = input.color( color.white, "Table Border Color", group='Monthly Performance')



var table_position_mp = dash_loc_mp == 'Top Left' ? position.top_left :
  dash_loc_mp == 'Bottom Left' ? position.bottom_left :
  dash_loc_mp == 'Middle Right' ? position.middle_right :
  dash_loc_mp == 'Bottom Center' ? position.bottom_center :
  dash_loc_mp == 'Top Right' ? position.top_right : position.bottom_right
  
var table_text_size_mp = text_size_mp == 'Tiny' ? size.tiny :
  text_size_mp == 'Small' ? size.small :
  text_size_mp == 'Normal' ? size.normal : size.large

/////////////////


/////////////////////////////////////////////

// var bool new_month = na
new_month = ta.change(month) //> 0 ? true : false
newest_month = new_month and strategy.closedtrades >= 1

// profit
only_profit = strategy.netprofit
initial_balance = strategy.initial_capital

// month number
var int month_number = na
month_number := (ta.valuewhen(newest_month, month(time), 0)) //and month(time) > 1 ? (ta.valuewhen(newest_month, month(time), 0) - 1) :  12 //1 to 12

//month_year
var int month_time = na
month_time :=  ta.valuewhen(newest_month, time, 0) - 2419200000 


var int m_counter = 0
if newest_month
    m_counter += 1



// current month values
var bool new_year = na
new_year := ta.change(year) ? true : false
curr_m_pnl = only_profit - nz(ta.valuewhen(newest_month, only_profit, 0), 0)
curr_m_number = newest_month ? ta.valuewhen(newest_month, month(time), 0) : month(time)
curr_y_pnl = (only_profit - nz(ta.valuewhen(new_year, only_profit, 0),0)) 



var float [] net_profit_array = array.new_float()
var int [] month_array = array.new_int()
var int [] month_time_array = array.new_int()


if newest_month
    array.push(net_profit_array, only_profit)
    array.push(month_array, month_number)
    array.push(month_time_array, month_time)



var float [] y_pnl_array = array.new_float()
var int [] y_number_array = array.new_int()
var int [] y_time_array = array.new_int()

newest_year = new_year and strategy.closedtrades >= 1
get_yearly_pnl = nz(ta.valuewhen(newest_year, strategy.netprofit, 0) - nz(ta.valuewhen(newest_year, strategy.netprofit, 1), 0), 0)
get_m_year = ta.valuewhen(newest_year, year(time), 2)
get_y_time = ta.valuewhen(newest_year, time, 0)

if newest_year
    array.push(y_pnl_array, get_yearly_pnl)
    array.push(y_number_array, get_m_year)
    array.push(y_time_array, get_y_time)
var float monthly_profit = na
var int column_month_number = na
var int row_month_time = na
var int row_y = na

//% profitable
total_trades = strategy.closedtrades
wintrades = strategy.wintrades
perc_profitable = (wintrades/total_trades) * 100
gross_profit = strategy.grossprofit
gross_loss = strategy.grossloss
profit_factor = gross_profit/gross_loss

 


var testTable = table.new(position = table_position_mp, columns = 20, rows = 40, bgcolor = bg_c, border_color = border_c, border_width = 1)
if barstate.islastconfirmedhistory and show_performance
    table.cell(table_id = testTable, column = 0, row = 0, text = "YEAR", text_color = text_head_color, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 1, row = 0, text = "JAN", text_color = text_head_color, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 2, row = 0, text = "FEB", text_color = text_head_color, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 3, row = 0, text = "MAR", text_color = text_head_color, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 4, row = 0, text = "APR", text_color = text_head_color, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 5, row = 0, text = "MAY", text_color = text_head_color, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 6, row = 0, text = "JUN", text_color = text_head_color, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 7, row = 0, text = "JUL", text_color = text_head_color, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 8, row = 0, text = "AUG", text_color = text_head_color, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 9, row = 0, text = "SEP", text_color = text_head_color, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 10, row = 0, text = "OCT", text_color = text_head_color, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 11, row = 0, text = "NOV", text_color = text_head_color, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 12, row = 0, text = "DEC", text_color =text_head_color, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 13, row = 0, text = "YEAR P/L", text_color = text_head_color, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 14, row = 0, text = "% Profitable     =>", text_color = text_head_color, text_size=table_text_size_mp, bgcolor = color.orange, text_halign = text.align_left)
    table.cell(table_id = testTable, column = 14, row = 1, text = "Profit Factor    =>", text_color = text_head_color, text_size=table_text_size_mp, bgcolor = color.orange, text_halign = text.align_left)
    table.cell(table_id = testTable, column = 14, row = 2, text = "Total Trades     =>", text_color = text_head_color, text_size=table_text_size_mp, bgcolor = color.orange, text_halign = text.align_left)
    table.cell(table_id = testTable, column = 14, row = 3, text = "Max Drawdown =>", text_color = text_head_color, text_size=table_text_size_mp, bgcolor = color.orange, text_halign = text.align_left)
    table.cell(table_id = testTable, column = 14, row = 4, text = "Max Run-Up   =>", text_color = text_head_color, text_size=table_text_size_mp, bgcolor = color.orange, text_halign = text.align_left)
    table.cell(table_id = testTable, column = 14, row = 5, text = "Initial Capital  =>", text_color = text_head_color, text_size=table_text_size_mp, bgcolor = color.orange, text_halign = text.align_left)
    

    for i = 0 to (array.size(y_number_array) == 0 ? na : array.size(y_number_array) - 1)
        row_y := year(array.get(y_time_array, i)) - year(array.get(y_time_array, 0)) + 1
        table.cell(table_id = testTable, column = 13, row = row_y, text = str.tostring(array.get(y_pnl_array , i), "##.##") + '\n' + '(' + str.tostring(array.get(y_pnl_array , i)*100/initial_balance, "##.##") + ' %)', bgcolor = array.get(y_pnl_array , i) > 0 ? color.green : array.get(y_pnl_array , i) < 0 ? color.red : color.gray, text_color = tab_year_c, text_size=table_text_size_mp)
    curr_row_y = array.size(month_time_array) == 0 ? 1 : (year(array.get(month_time_array, array.size(month_time_array) - 1))) - (year(array.get(month_time_array, 0))) + 1
    table.cell(table_id = testTable, column = 13, row = row_y >= 0 ? row_y + 1 : 1, text = str.tostring(curr_y_pnl, "##.##") + '\n' + '(' + str.tostring(curr_y_pnl*100/initial_balance, "##.##") + ' %)', bgcolor = curr_y_pnl > 0 ? color.green : curr_y_pnl < 0 ? color.red : color.gray, text_color = tab_year_c, text_size=table_text_size_mp)
    

    for i = 0 to (array.size(net_profit_array) == 0 ? na : array.size(net_profit_array) - 1)
        monthly_profit := i > 0 ? ( array.get(net_profit_array, i) - array.get(net_profit_array, i - 1) ) : array.get(net_profit_array, i) 
        column_month_number := month(array.get(month_time_array, i)) 
        row_month_time :=((year(array.get(month_time_array, i))) - year(array.get(month_time_array, 0)) ) + 1 
        table.cell(table_id = testTable, column = column_month_number, row = row_month_time, text = str.tostring(monthly_profit, "##.##") + '\n' + '(' + str.tostring(monthly_profit*100/initial_balance, "##.##") + ' %)', bgcolor = monthly_profit > 0 ? color.green : monthly_profit < 0 ? color.red : color.gray, text_color = tab_month_c, text_size=table_text_size_mp)
        table.cell(table_id = testTable, column = 0, row =row_month_time, text = str.tostring(year(array.get(month_time_array, i)), "##.##"), text_color = text_head_color, text_size=table_text_size_mp)
       
    // curr_row_m = array.size(month_time_array) == 0 ? 1 : (year(array.get(month_time_array, array.size(month_time_array) - 1))) - (year(array.get(month_time_array, 0))) + 1
    table.cell(table_id = testTable, column = curr_m_number, row = nz(row_month_time) <= 0 ? 1 : row_month_time + (month== 1 ? 1 : 0), text = str.tostring(curr_m_pnl, "##.##") + '\n' + '(' + str.tostring(curr_m_pnl*100/initial_balance, "##.##") + ' %)', bgcolor = curr_m_pnl > 0 ? color.green : curr_m_pnl < 0 ? color.red : color.gray, text_color = tab_month_c, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 0, row =nz(row_month_time) <= 0 ? 1 : row_month_time + (month== 1 ? 1 : 0), text = str.tostring(year(time), "##.##"), text_color = text_head_color, text_size=table_text_size_mp)


    // //% Profitable
    // table.cell(table_id = testTable, column = 14, row = 1, text = str.tostring(perc_profitable, "##.##") + " %", text_color = text_head_color, text_size=table_text_size_mp)
    // table.cell(table_id = testTable, column = 15, row = 1, text = str.tostring(profit_factor, "##.##"), text_color = text_head_color, text_size=table_text_size_mp, bgcolor = profit_factor >=1 ? color.green : color.red)
    // table.cell(table_id = testTable, column = 16, row = 1, text = str.tostring(total_trades, "##") + '\n' + "(" + str.tostring(wintrades, "##") +"W + "+ str.tostring(total_trades - wintrades, "##") +"L" + ")", text_color = text_head_color, text_size=table_text_size_mp)
    // table.cell(table_id = testTable, column = 17, row = 1, text = str.tostring(strategy.max_drawdown, "##.##")  + '\n' + '(' + str.tostring(strategy.max_drawdown_percent, "##.##") + " %" + ")", text_color = text_head_color, text_size=table_text_size_mp)

    // //NET Profit
    // table.cell(table_id = testTable, column = 13, row = row_y >= 0 ? row_y + 2 : 2, text = str.tostring(strategy.netprofit, "##.##") + '\n' + '(' + str.tostring(strategy.netprofit_percent, "##.##") + ' %)', bgcolor = strategy.netprofit > 0 ? color.green : strategy.netprofit < 0 ? color.red : color.gray, text_color = tab_month_c, text_size=table_text_size_mp)
    // table.cell(table_id = testTable, column = 12, row = row_y >= 0 ? row_y + 2 : 2, text = "Net Profit", text_color = text_head_color, text_size=table_text_size_mp)

    
    //% Profitable
    table.cell(table_id = testTable, column = 15, row = 0, text = str.tostring(perc_profitable, "##.##") + " %", text_color = text_head_color, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 15, row = 1, text = str.tostring(profit_factor, "##.##"), text_color = text_head_color, text_size=table_text_size_mp, bgcolor = profit_factor >=1 ? color.green : color.red)
    table.cell(table_id = testTable, column = 15, row = 2, text = str.tostring(total_trades, "##") + '\n' + "(" + str.tostring(wintrades, "##") +"W + "+ str.tostring(total_trades - wintrades, "##") +"L" + ")", text_color = text_head_color, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 15, row = 3, text = str.tostring(strategy.max_drawdown, "##.##")  + '\n' + '(' + str.tostring(strategy.max_drawdown_percent, "##.##") + " %" + ")", text_color = text_head_color, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 15, row = 4, text = str.tostring(strategy.max_runup, "##.##")  + '\n' + '(' + str.tostring(strategy.max_runup_percent, "##.##") + " %" + ")", text_color = text_head_color, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 15, row = 5, text = str.tostring(strategy.initial_capital, "##.##") + " "+ str.tostring(strategy.account_currency), text_color = text_head_color, text_size=table_text_size_mp)

    //NET Profit
    table.cell(table_id = testTable, column = 12, row = row_y >= 0 ? row_y + 2 : 2, text = "Net Profit =>", text_color = text_head_color, text_size=table_text_size_mp, bgcolor = color.yellow)
    table.cell(table_id = testTable, column = 13, row = row_y >= 0 ? row_y + 2 : 2, text = str.tostring(strategy.netprofit, "##.##") + '\n' + '(' + str.tostring(strategy.netprofit_percent, "##.##") + ' %)', bgcolor = strategy.netprofit > 0 ? color.green : strategy.netprofit < 0 ? color.red : color.gray, text_color = tab_month_c, text_size=table_text_size_mp)
    
//============================================================================================================================================================================
````
