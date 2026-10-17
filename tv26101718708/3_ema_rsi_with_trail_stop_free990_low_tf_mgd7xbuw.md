# 3 EMA + RSI with Trail Stop [Free990] (LOW TF)

- url: https://www.tradingview.com/script/mgD7xBuw-3-EMA-RSI-with-Trail-Stop-Free990-LOW-TF/
- type: strategy
- pine_id: PUB;372f9d31cf8e48289c7b4119be991b1d
- version: 3.0

## Description

This trading strategy combines three Exponential Moving Averages (EMAs) to identify trend direction, uses RSI to signal exit conditions, and applies both a fixed percentage stop-loss and a trailing stop for risk management. It aims to capture momentum when the faster EMAs cross the slower EMA, then uses RSI thresholds, time-based exits, and stops to close trades.

Short Explanation of the Logic

Trend Detection: When the 10 EMA crosses above the 20 EMA and both are above the 100 EMA (and the current price bar closes higher), it triggers a long entry signal. The reverse happens for a short (the 10 EMA crosses below the 20 EMA and both are below the 100 EMA).
RSI Exit: RSI crossing above a set threshold closes long trades; crossing below another threshold closes short trades.
Time-Based Exit: If a trade is in profit after a set number of bars, the strategy closes it.
Stop-Loss & Trailing Stop: A fixed stop-loss based on a percentage from the entry price guards against large drawdowns. A trailing stop dynamically tightens as the trade moves in favor, locking in potential gains.

Detailed Explanation of the Strategy Logic

Exponential Moving Average (EMA) Setup

Short EMA (out_a, length=10)
Medium EMA (out_b, length=20)
Long EMA (out_c, length=100)
The code calculates three separate EMAs to gauge short-term, medium-term, and longer-term trend behavior. By comparing their relative positions, the strategy infers whether the market is bullish (EMAs stacked positively) or bearish (EMAs stacked negatively).

Entry Conditions

Long Entry (entryLong): Occurs when:

The short EMA (10) crosses above the medium EMA (20).
Both EMAs (short and medium) are above the long EMA (100).
The current bar closes higher than it opened (close > open).
This suggests that momentum is shifting to the upside (short-term EMAs crossing up and price action turning bullish). If there’s an existing short position, it’s closed first before opening a new long.

Short Entry (entryShort): Occurs when:

The short EMA (10) crosses below the medium EMA (20).
Both EMAs (short and medium) are below the long EMA (100).
The current bar closes lower than it opened (close < open).
This indicates a potential shift to the downside. If there’s an existing long position, that gets closed first before opening a new short.

Exit Signals

RSI-Based Exits:

For long trades: When RSI exceeds a specified threshold (e.g., 70 by default), it triggers a long exit. RSI > short_rsi generally means overbought conditions, so the strategy exits to lock in profits or avoid a pullback.
For short trades: When RSI dips below a specified threshold (e.g., 30 by default), it triggers a short exit. RSI < long_rsi indicates oversold conditions, so the strategy closes the short to avoid a bounce.
Time-Based Exit:
If the trade has been open for xBars bars (configurable, e.g., 24 bars) and the trade is in profit (current price above entry for a long, or current price below entry for a short), the strategy closes the position. This helps lock in gains if the move takes too long or momentum stalls.

Stop-Loss Management

Fixed Stop-Loss (% Based): Each trade has a fixed stop-loss calculated as a percentage from the average entry price.

For long positions, the stop-loss is set below the entry price by a user-defined percentage (fixStopLossPerc).
For short positions, the stop-loss is set above the entry price by the same percentage.
This mechanism prevents catastrophic losses if the market moves strongly against the position.

Trailing Stop:

The strategy also sets a trail stop using trail_points (the distance in price points) and trail_offset (how quickly the stop “catches up” to price).
As the market moves in favor of the trade, the trailing stop gradually tightens, allowing profits to run while still capping potential drawdowns if the price reverses.
Order Execution Flow

When the conditions for a new position (long or short) are triggered, the strategy first checks if there’s an opposite position open. If there is, it closes that position before opening the new one (prevents going “both long and short” simultaneously).
RSI-based and time-based exits are checked on each bar. If triggered, the position is closed.
If the position remains open, the fixed stop-loss and trailing stop remain in effect until the position is exited.
Why This Combination Works

Multiple EMA Cross: Combining 10, 20, and 100 EMAs balances short-term momentum detection with a longer-term trend filter. This reduces false signals that can occur if you only look at a single crossover without considering the broader trend.
RSI Exits: RSI provides a momentum oscillator view—helpful for detecting overbought/oversold conditions, acting as an extra confirmation to exit.
Time-Based Exit: Prevents “lingering trades.” If the position is in profit but failing to advance further, it takes profit rather than risking a trend reversal.
Fixed & Trailing Stop-Loss: The fixed stop-loss is your safety net to cap worst-case losses. The trailing stop allows the strategy to lock in gains by following the trade as it moves favorably, thus maximizing profit potential while keeping risk in check.
Overall, this approach tries to capture momentum from EMA crossovers, protect profits with trailing stops, and limit risk through both a fixed percentage stop-loss and exit signals from RSI/time-based logic.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@Free990

//@version=5
strategy(title='v.5 - 3 EMA + RSI with Trail Stop', shorttitle='v.5 - 3 EMA + RSI + Trail Stop', overlay=true, pyramiding=0, currency=currency.USD, default_qty_type=strategy.percent_of_equity, initial_capital=1000, default_qty_value=20, commission_type=strategy.commission.percent, commission_value=0.05)

// Bollinger Bands
len = input.int(14, minval=1, title='Length', group='RSI')
src = input.source(close, 'Source', group='RSI')
rsi = ta.rsi(src, len)
long_rsi = input.int(30, minval=1, title='Exit Short RSI', group='RSI')
short_rsi  = input.int(70, minval=1, title='Exit Long RSI', group='RSI')
 
// Moving Averages
len_a = input.int(10, minval=1, title='EMA A Length', group='Moving Averages')
out_a = ta.ema(close, len_a)
plot(out_a, title='EMA A', color=color.purple)

len_b = input.int(20, minval=1, title='EMA B Length', group='Moving Averages')
out_b = ta.ema(close, len_b)
plot(out_b, title='EMA B', color=color.orange)

len_c = input.int(100, minval=1, title='EMA C Length', group='Moving Averages')
out_c = ta.ema(close, len_c)
plot(out_c, title='EMA B', color=color.green)

// Trailing Stop Parameters
trail_point  = input.float(50, title='Trail Points',  group='Trailing Stop')
trail_offset = input.float(10, title='Trail Offset',  group='Trailing Stop')

// NEW: Fixed Stop-Loss (%)
fixStopLossPerc = input.float(5.0, title='Fixed Stop Loss (%)', group='Stop Loss')


// Strategy Conditions
stratGroup = 'Strategy'
showLong = input.bool(true, title='Long entries', group=stratGroup)
showShort = input.bool(false, title='Short entries', group=stratGroup)
closeAfterXBars = input.bool(true, title='Close after X # bars', tooltip='If trade is in profit', group=stratGroup)
xBars = input.int(24, title='# bars')

entryLong = ta.crossover(out_a, out_b) and out_a > out_c and close > open
exitLong = rsi > short_rsi

entryShort = ta.crossunder(out_a, out_b) and out_a < out_c and close < open
exitShort = rsi < long_rsi 

bought = strategy.opentrades[0] == 1 and strategy.position_size[0] > strategy.position_size[1]
entry_price = ta.valuewhen(bought, open, 0)
var int nPastBars = 0
if strategy.position_size > 0
    nPastBars := nPastBars + 1
    nPastBars
if strategy.position_size == 0
    nPastBars := 0
    nPastBars
if closeAfterXBars
    exitLong := nPastBars >= xBars and close > entry_price ? true : exitLong
    exitLong
    exitShort := nPastBars >= xBars and close < entry_price ? true : exitShort
    exitShort

// ────────────────────────────────────────────────────────────────────────────────
// Orders
// ────────────────────────────────────────────────────────────────────────────────
//
// Instead of calling 'strategy.entry' + 'strategy.close' unconditionally,
// we can incorporate logic to close an opposite position first if a new signal arises.
//

// 1) If we get a long signal while not already in a long, close the short first (if any).
if entryLong and showLong
    // If there's an open short position, close it first
    if strategy.position_size < 0
        strategy.close('Short', comment='Close Short → New Long')

    // Now open the new Long position
    strategy.entry('Long', strategy.long)

// 2) If we get a short signal while not already in a short, close the long first (if any).
if entryShort and showShort
    // If there's an open long position, close it first
    if strategy.position_size > 0
        strategy.close('Long', comment='Close Long → New Short')

    // Now open the new Short position
    strategy.entry('Short', strategy.short)

// Use strategy.close for “normal” RSI-based exit conditions only if the position is still open
if strategy.position_size > 0
    // If RSI exit condition is met for a long, close it
    if exitLong
        strategy.close('Long', comment='RSI Exit Long')

if strategy.position_size < 0
    // If RSI exit condition is met for a short, close it
    if exitShort
        strategy.close('Short', comment='RSI Exit Short')



// For a long position: stop-loss below avg price by fixStopLossPerc%
if strategy.position_size > 0
    // Fixed stop loss for a LONG is (AvgPrice * (1 - X/100))
    float longStopPrice = strategy.position_avg_price * (1 - fixStopLossPerc / 100.0)
    strategy.exit('Trail Stop Long', from_entry='Long', stop = longStopPrice, trail_points=trail_point, trail_offset=trail_offset)

// For a short position: stop-loss above avg price by fixStopLossPerc%
if strategy.position_size < 0
    // Fixed stop loss for a SHORT is (AvgPrice * (1 + X/100))
    float shortStopPrice = strategy.position_avg_price * (1 + fixStopLossPerc / 100.0)
    strategy.exit('Trail Stop Short', from_entry='Short',stop = shortStopPrice, trail_points=trail_point, trail_offset=trail_offset)


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
month_time := ta.valuewhen(newest_month, time, 0) - 2419200000 


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
    table.cell(table_id = testTable, column = curr_m_number, row = nz(row_month_time) <= 0 ? 1 : row_month_time + 1, text = str.tostring(curr_m_pnl, "##.##") + '\n' + '(' + str.tostring(curr_m_pnl*100/initial_balance, "##.##") + ' %)', bgcolor = curr_m_pnl > 0 ? color.green : curr_m_pnl < 0 ? color.red : color.gray, text_color = tab_month_c, text_size=table_text_size_mp)
    table.cell(table_id = testTable, column = 0, row =nz(row_month_time) <= 0 ? 1 : row_month_time + 1, text = str.tostring(year(time), "##.##"), text_color = text_head_color, text_size=table_text_size_mp)


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

//============================================================================================================================================================================
//Initialize variables for tracking consecutive wins and losses
var int currConsecWins = 0
var int currConsecLosses = 0
var int maxConsecWins = 0
var int maxConsecLosses = 0
var int prev_closed_trades = 0
var float prev_netprofit = 0.0

// Update consecutive win/loss counters when a trade is closed
if strategy.closedtrades > prev_closed_trades
    trade_profit = strategy.netprofit - prev_netprofit
    if trade_profit > 0
        currConsecWins := currConsecWins + 1
        currConsecLosses := 0
        maxConsecWins := math.max(maxConsecWins, currConsecWins)
    else if trade_profit < 0
        currConsecLosses := currConsecLosses + 1
        currConsecWins := 0
        maxConsecLosses := math.max(maxConsecLosses, currConsecLosses)
    else
        // Break-even trade
        currConsecWins := 0
        currConsecLosses := 0
    prev_netprofit := strategy.netprofit
    prev_closed_trades := strategy.closedtrades


// DATA WINDOW
var T_dataWindow = table.new(position.top_right, 2, 14, color.rgb(255, 255, 255, 55), border_width = 1)
if barstate.islast or barstate.islastconfirmedhistory
    // Header row
    table.cell(T_dataWindow, 0, 0, 'Info', text_size = size.auto, text_color = color.white, bgcolor = color.gray, text_halign = text.align_left)
    table.cell(T_dataWindow, 0, 1, 'Initial Capital', text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 0, 2, 'Equity', text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 0, 3, 'Net Profit', text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 0, 4, 'Open Profit', text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 0, 5, 'Gross Profit', text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 0, 6, 'Gross Loss', text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 0, 7, 'Open Trades', text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 0, 8, 'Closed Trades', text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 0, 9, 'Winning Trades', text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 0, 10, 'Losing Trades', text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 0, 11, 'Break Even Trades', text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 0, 12, 'Max Consecutive Wins', text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 0, 13, 'Max Consecutive Losses', text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)

    // Value row
    table.cell(T_dataWindow, 1, 0, 'Value', text_size = size.auto, text_color = color.white, bgcolor = color.gray, text_halign = text.align_left)
    table.cell(T_dataWindow, 1, 1, str.tostring(strategy.initial_capital, '#.##'), text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 1, 2, str.tostring(strategy.equity, '#.##'), text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 1, 3, str.tostring(strategy.netprofit, '#.##'), text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 1, 4, str.tostring(strategy.openprofit, '#.##'), text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 1, 5, str.tostring(strategy.grossprofit, '#.##'), text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 1, 6, str.tostring(strategy.grossloss, '#.##'), text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 1, 7, str.tostring(strategy.opentrades), text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 1, 8, str.tostring(strategy.closedtrades), text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 1, 9, str.tostring(strategy.wintrades), text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 1, 10, str.tostring(strategy.losstrades), text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 1, 11, str.tostring(strategy.eventrades), text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 1, 12, str.tostring(maxConsecWins), text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
    table.cell(T_dataWindow, 1, 13, str.tostring(maxConsecLosses), text_size = size.auto, text_color = color.white, bgcolor = color.black, text_halign = text.align_left)
````
