# DCA After Downtrend (by BHD_Trade_Bot)

- url: https://www.tradingview.com/script/L4ffblzk-DCA-After-Downtrend-by-BHD-Trade-Bot/
- type: strategy
- pine_id: PUB;b9b0cf72b96045179d69a849022acdd0
- version: 1.0

## Description

The purpose of the strategy is to identify [b]the end of a short-term downtrend[/b]. So that you can easily to [b]DCA[/b] certain amount of money for each month.


[b]ENTRY[/b]
The buy orders are placed on a monthly basis for assets at the end of a short-term downtrend:
- Each month condition: In 1-hour time frame, each month has 240 candles
- The end of short-term downtrend condition: use MACD for less delay


[b]CLOSE[/b]
The sell orders are placed when:
- Is last bar


The strategy use $1000 and trading fee is 0.1% for each order.

[b]Pro tip:[/b] The 1-hour time frame for TSLA has the best results on average:
- Total spent: [b]$1000 x 85 = $85,000[/b]
- Total profit: [b]$790,556[/b]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BHD_Trade_Bot

// @version=5
strategy(
 shorttitle            = 'DCA After Downtrend',
 title                 = 'DCA After Downtrend (by BHD_Trade_Bot)',
 overlay               = true,
 calc_on_every_tick    = true,
 calc_on_order_fills   = true,
 use_bar_magnifier     = true,
 pyramiding            = 100,
 initial_capital       = 0,
 default_qty_type      = strategy.cash,
 default_qty_value     = 1000,
 commission_type       = strategy.commission.percent,
 commission_value      = 0.1)



// Backtest Time Period
start_year   = input(title='Start year'   ,defval=2017)
start_month  = input(title='Start month'  ,defval=1)
start_day    = input(title='Start day'    ,defval=1)
start_time   = timestamp(start_year, start_month, start_day, 00, 00)

end_year     = input(title='end year'     ,defval=2050)
end_month    = input(title='end month'    ,defval=1)
end_day      = input(title='end day'      ,defval=1)
end_time     = timestamp(end_year, end_month, end_day, 23, 59)

window() => time >= start_time and time <= end_time ? true : false



// EMA
ema50 = ta.ema(close, 50)
ema200 = ta.ema(close, 200)

// EMA_CD
emacd = ema50 - ema200
emacd_signal = ta.ema(emacd, 20)
hist = emacd - emacd_signal

// Count n candles after x long entries
var int nPastCandles = 0
var int entryNumber = 0
nPastCandles := nPastCandles + 1



// ENTRY CONDITIONS

// 8 hours per day => 240 hours per month
entry_condition1 = nPastCandles > entryNumber * 240

// End of downtrend
entry_condition2 = ta.crossover(emacd, emacd_signal)

ENTRY_CONDITIONS = entry_condition1 and entry_condition2


if ENTRY_CONDITIONS and window()
    entryNumber := entryNumber + 1
    entryId = 'Long ' + str.tostring(entryNumber)
    strategy.entry(entryId, strategy.long)
    
    

// CLOSE CONDITIONS

// Last bar
CLOSE_CONDITIONS = barstate.islast

if CLOSE_CONDITIONS
    strategy.close_all()


    
// Draw
plot(ema50, color=color.orange, linewidth=3)
plot(ema200, color=entry_condition1 ? color.green : color.red, linewidth=3)
````
