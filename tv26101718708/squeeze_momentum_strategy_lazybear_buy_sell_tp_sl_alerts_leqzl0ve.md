# Squeeze Momentum Strategy [LazyBear] Buy Sell TP SL Alerts

- url: https://www.tradingview.com/script/lEQZl0vE-Squeeze-Momentum-Strategy-LazyBear-Buy-Sell-TP-SL-Alerts/
- type: strategy
- pine_id: PUB;acff5b861054426985cffaffd16c6eb7
- version: 2.0

## Description

-Modified version of Squeeze Momentum Indicator by @LazyBear. 
-Converted to version 5, 
-Taken inspiration from @KivancOzbilgic for its buy sell calculations,
-Used @Bunghole strategy template with Take Profit, Stop Loss and Enable/Disable Toggles
-Added Custom Date Backtesting Module
------------------------------------------------------------------------------------------------------------------------
All credit goes to above

[i][b]Problem with original version:[/b][/i]
The original Squeeze Momentum Strategy did not have buy sell signals and there was alot of confusion as to when to enter and exit. 
There was no proper strategy that would allow backtesting on which further analysis could be carried out.


There are 3 aspects this strategy:
1[b]) Strategy Logic [/b][i](easily toggleable from the dropdown menu from strategy settings)[/i]
    - LazyBear (I have made this simple by using Kivanc technique of Momentums Moving Average Crossover, BUY when MA cross above signal line, SELL when crossdown signal line)
    - Zero Crossover Line (BUY signal when crossover zero line, and SELL crossdown zero line)
[b]2) Long Short TP and SL[/b]
    - In strategies there is usually only 1 SL and 1 TP, and it is assumed that if a 2% SL giving a good profit %, then it would be best for both long and short. However this is not the case for many. Many markets/pairs, go down with much more speed then they go up with. Hence once we have a profitable backtesting setting, then we should start optimizing Long and Short SL's seperately. Once that is done, we should start optimizing for Long and Short TP's separately, starting with Longs first in both cases. 
[b]3) Enable and Disable Toggles of Long and Short Trades[/b]
     - Many markets dont allow short trades, or are not suitable for short trades. In this case it would be much more feasible to disable "Short" Trading and see results of Long Only as a built in graphic view of backtestor provides a more easy to understand data feed as compared to the performance summary in which you have to review long and short profitability separately.  
[b]4) Custom Data Backtesting [/b]
     - One of most crucial aspects while optimizing for backtesting is to check a strategies performance on uptrends, downtrend and sideways markets seperately as to understand the weak points of strategy.
     - Once you enable custom date backtesting, you will see lines on the chart which can be dragged left right based on where you want to start and end the backtesting from and to.

[b]Note:[/b]
- Not a financial advise
- Open to feedback, questions, improvements, errors etc.
- More info on how the squeeze momentum works visit LazyBear indicator link: https://www.tradingview.com/v/nqQ1DT5a/

Happy Trading!
Cheers

[b]M Tahreem Alam[/b] @mtahreemalam

## Source Code

````pine
//@version=5
//@mtahreemalam
strategy(title = 'Squeeze Momentum Strategy with TP & SL, v2',
         shorttitle = 'SQM Strategy, v2',
         overlay = true,
         pyramiding = 0,
         default_qty_type = strategy.percent_of_equity,
         default_qty_value = 100,
         initial_capital = 100000,
         commission_type=strategy.commission.percent, 
         commission_value=0.0,
         process_orders_on_close=false,
         use_bar_magnifier=false)

import jason5480/time_filters/5 as tif

gp0 = "Backtesting Settings"
gp1 = "Squeeze Momentum Settings"
gp2 = "Strategy Settings"

type1 = "Buy@ Mom Up/ Sell@ Mom Dn"
type2 = "Buy@ Mom Up & below 0/ Sell@ Mom Dn & above 0"
type3 = "Longs Only below 0/ Shorts Only above 0"
type4 = "Long@ Mom above 0/ Short@ Mom below 0"

usefromDate = input.bool(defval = true, title = 'From', inline = 'From Date', group = gp0)
fromDate = input.time(defval = timestamp('1 Jan 2023 00:00'), title = '', inline = 'From Date', group = gp0)
usetoDate = input.bool(defval = false, title = 'To ', inline = 'To Date', group = gp0)
toDate = input.time(defval = timestamp('31 Jul 2024 00:00'), title = '', inline = 'To Date', group = gp0)
bool dateFilterApproval = tif.is_in_date_range(usefromDate, fromDate, usetoDate, toDate)

strategy_logic = input.string(type2, "Switch Strategy Logic Type", options = [type1, type2, type3, type4], group = gp2)
longDealsEnabled = input.bool(defval = true, title = 'Enable Longs', inline = 'Long/Short Deals', group = gp2)
shortDealsEnabled = input.bool(defval = false, title = 'Enable Shorts', inline = 'Long/Short Deals', group = gp2)

long_stoploss_value = input.float(defval=0.5, title='  Long SL %', minval=0.01, step=0.01,group=gp2, inline='2')//100
long_takeprofit_value = input.float(defval=1, title='  Long TP %', minval=0.01, step=0.01,group=gp2, inline='2')//100

short_stoploss_value = input.float(defval=0.5, title='  Short SL %', minval=0.01, step=0.01,group=gp2, inline='3')//100
short_takeprofit_value = input.float(defval=1, title='  Short TP %', minval=0.01,step=0.01, group=gp2, inline='3')//100

exit_tp_sl = input.bool(defval = false, title = 'Exit only when TP/SL hit', group=gp2)
allowEntry = exit_tp_sl  ? strategy.position_size==0 : true

long_stoploss_percentage = close * (long_stoploss_value / 100) / syminfo.mintick
long_takeprofit_percentage = close * (long_takeprofit_value / 100) / syminfo.mintick

short_stoploss_percentage = close * (short_stoploss_value / 100) / syminfo.mintick
short_takeprofit_percentage = close * (short_takeprofit_value / 100) / syminfo.mintick


length = input(20, title='BB Length', group = gp1)
mult = input(2.0, title='BB MultFactor', group = gp1)
lengthKC = input(20, title='KC Length', group = gp1)
mult_kc = input(1.5, title='KC MultFactor', group = gp1)
squeeze_filter = input.bool(true, "Take Entry only when Squeeze On", group = gp1)

// Calculate BB
src = ohlc4
ma_1 = ta.sma(src, length)
ma_2 = ta.sma(src, lengthKC)
range_ma = ta.sma(high - low, lengthKC)

dev = mult * ta.stdev(src, length)

upper_bb = ma_1 + dev
lower_bb = ma_1 - dev

upper_kc = ma_2 + range_ma * mult_kc
lower_kc = ma_2 - range_ma * mult_kc

sqz_on = lower_bb > lower_kc and upper_bb < upper_kc
sqz_off = lower_bb < lower_kc and upper_bb > upper_kc
no_sqz = sqz_on == false and sqz_off == false
sqz_filter = squeeze_filter ? sqz_off : true
val = ta.linreg(src - math.avg(math.avg(ta.highest(hl2, lengthKC), ta.lowest(low, lengthKC)), ta.sma(hl2, lengthKC)), lengthKC, 0)

iff_1 = val > nz(val[1]) ? color.lime : color.green
iff_2 = val < nz(val[1]) ? color.red : color.maroon
bcolor = val > 0 ? iff_1 : iff_2
scolor = no_sqz ? color.blue : sqz_on ? color.black : color.aqua

long_default = ta.crossover(val,nz(val[1]))
short_default = ta.crossunder(val,nz(val[1]))

longCondition = switch strategy_logic
    type1 => ta.crossover(val,nz(val[1])) and sqz_filter
    type2 => ta.crossover(val,nz(val[1])) and val<0 and sqz_filter
    type3 => ta.crossover(val,nz(val[1])) and val<0 and sqz_filter
    type4 => ta.crossover(val,0) and sqz_filter

shortCondition = switch strategy_logic
    type1 => ta.crossunder(val,nz(val[1])) and sqz_filter
    type2 => ta.crossunder(val,nz(val[1])) and val>0 and sqz_filter
    type3 => ta.crossunder(val,nz(val[1])) and val>0 and sqz_filter
    type4 => ta.crossunder(val,0) and sqz_filter

longExit = switch strategy_logic
    type1 => ta.crossunder(val,nz(val[1]))
    type2 => ta.crossunder(val,nz(val[1])) and val>0
    type3 => ta.crossunder(val,nz(val[1])) and val<0
    type4 => ta.crossunder(val,0)

shortExit = switch strategy_logic
    type1 => ta.crossover(val,nz(val[1]))
    type2 => ta.crossover(val,nz(val[1])) and val<0
    type3 => ta.crossover(val,nz(val[1])) and val>0
    type4 => ta.crossover(val,0)

//STRATEGY
if longExit and (not exit_tp_sl) 
    strategy.close('Long', comment = 'L.Close')
if shortExit and (not exit_tp_sl)
    strategy.close('Short', comment = 'S.Close')

if longCondition and longDealsEnabled and dateFilterApproval and allowEntry
    strategy.entry('Long', strategy.long)
    strategy.exit('Long Exit', from_entry='Long', loss=long_stoploss_percentage, profit=long_takeprofit_percentage, comment_loss="Long SL", comment_profit="Long TP")

if shortCondition and shortDealsEnabled and dateFilterApproval and allowEntry
    strategy.entry('Short', strategy.short)
    strategy.exit('Short Exit', from_entry='Short', loss=short_stoploss_percentage, profit=short_takeprofit_percentage, comment_loss="Short SL", comment_profit="Short TP")



// Plot Stoploss & Take Profit Levels
long_stoploss_price = strategy.position_avg_price * (1 - long_stoploss_value / 100)
long_takeprofit_price = strategy.position_avg_price * (1 + long_takeprofit_value / 100)
short_stoploss_price = strategy.position_avg_price * (1 + short_stoploss_value / 100)
short_takeprofit_price = strategy.position_avg_price * (1 - short_takeprofit_value / 100)

// Entries
plot(strategy.position_size>0 ? long_stoploss_price : na, color=color.new(#ff0000, 0), style=plot.style_linebr, linewidth=1, title='Long SL Level')
plot(strategy.position_size>0 ? long_takeprofit_price : na, color=color.new(#008000, 0), style=plot.style_linebr, linewidth=1, title='Long TP Level')
plot(strategy.position_size<0 ? short_stoploss_price : na, color=color.new(#ff0000, 0), style=plot.style_linebr, linewidth=1, title='Short SL Level')
plot(strategy.position_size<0 ? short_takeprofit_price : na, color=color.new(#008000, 0), style=plot.style_linebr, linewidth=1, title='Short TP Level')
barcolor(close>=open? color.new(color.green,80):color.new(color.red,80))
````
