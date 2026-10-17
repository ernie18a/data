# DCA After Downtrend v2 (by BHD_Trade_Bot)

- url: https://www.tradingview.com/script/XB3FuiXT-DCA-After-Downtrend-v2-by-BHD-Trade-Bot/
- type: strategy
- pine_id: PUB;cbbe425797aa4ec995cee860acbfb080
- version: 1.0

## Description

The purpose of the strategy is to identify [b]the end of a short-term downtrend[/b]. So that you can easily to [b]DCA[/b] certain amount of money for each month.


[b]ENTRY[/b]
The buy orders are placed on a monthly basis for assets at the end of a short-term downtrend:
- Each month condition: In 1-hour time frame, each month has 24 * 30 candles
- The end of short-term downtrend condition: use MACD for less delay


[b]CLOSE[/b]
The sell orders are placed when:
- Is last bar


The strategy use $1000 and trading fee is 1.1% for each order.

Pro tip: The 1-hour time frame has the best results on average:
- Total spent: $1000 x 33 = $33,000
- Total profit: $65,578

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BHD_Trade_Bot

// @version=5
strategy(
 shorttitle            = 'DCA After Downtrend v2',
 title                 = 'DCA After Downtrend v2 (by BHD_Trade_Bot)',
 overlay               = true,
 calc_on_every_tick    = false,
 calc_on_order_fills   = false,
 use_bar_magnifier     = false,
 pyramiding            = 1000,
 initial_capital       = 0,
 default_qty_type      = strategy.cash,
 default_qty_value     = 1000,
 commission_type       = strategy.commission.percent,
 commission_value      = 1.1)



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
h1_last_bar = (math.min(end_time, timenow) - time)/1000/60/60 < 2



// EMA
ema50 = ta.ema(close, 50)
ema200 = ta.ema(close, 200)

// EMA_CD
emacd = ema50 - ema200
emacd_signal = ta.ema(emacd, 20)
hist = emacd - emacd_signal

// BHD Unit
bhd_unit = ta.rma(high - low, 200) * 2
bhd_upper = ema200 + bhd_unit
bhd_upper2 = ema200 + bhd_unit * 2
bhd_upper3 = ema200 + bhd_unit * 3
bhd_upper4 = ema200 + bhd_unit * 4
bhd_upper5 = ema200 + bhd_unit * 5

bhd_lower = ema200 - bhd_unit
bhd_lower2 = ema200 - bhd_unit * 2
bhd_lower3 = ema200 - bhd_unit * 3
bhd_lower4 = ema200 - bhd_unit * 4
bhd_lower5 = ema200 - bhd_unit * 5

// Count n candles after x long entries
var int nPastCandles = 0
var int entryNumber = 0
if window()
    nPastCandles := nPastCandles + 1



// ENTRY CONDITIONS

// 24 * 30 per month
entry_condition1 = nPastCandles > entryNumber * 24 * 30

// End of downtrend
entry_condition2 = emacd < 0 and hist < 0 and hist > hist[2]

ENTRY_CONDITIONS = entry_condition1 and entry_condition2


if ENTRY_CONDITIONS
    entryNumber := entryNumber + 1
    entryId = 'Long ' + str.tostring(entryNumber)
    strategy.entry(entryId, strategy.long)
    
    

// CLOSE CONDITIONS

// Last bar
CLOSE_CONDITIONS = barstate.islast or h1_last_bar

if CLOSE_CONDITIONS
    strategy.close_all()



// Draw
colorRange(src) =>
    if src > bhd_upper5
        color.rgb(255,0,0)
    else if src > bhd_upper4
        color.rgb(255,150,0)
    else if src > bhd_upper3
        color.rgb(255,200,0)
    else if src > bhd_upper2
        color.rgb(100,255,0)
    else if src > bhd_upper
        color.rgb(0,255,100)
    else if src > ema200
        color.rgb(0,255,150)
    else if src > bhd_lower
        color.rgb(0,200,255)
    else if src > bhd_lower2
        color.rgb(0,150,255)
    else if src > bhd_lower3
        color.rgb(0,100,255)
    else if src > bhd_lower4
        color.rgb(0,50,255)
    else
        color.rgb(0,0,255)
        
bhd_upper_line = plot(bhd_upper, color=color.new(color.teal, 90))
bhd_upper_line2 = plot(bhd_upper2, color=color.new(color.teal, 90))
bhd_upper_line3 = plot(bhd_upper3, color=color.new(color.teal, 90))
bhd_upper_line4 = plot(bhd_upper4, color=color.new(color.teal, 90))
bhd_upper_line5 = plot(bhd_upper5, color=color.new(color.teal, 90))

bhd_lower_line = plot(bhd_lower, color=color.new(color.teal, 90))
bhd_lower_line2 = plot(bhd_lower2, color=color.new(color.teal, 90))
bhd_lower_line3 = plot(bhd_lower3, color=color.new(color.teal, 90))
bhd_lower_line4 = plot(bhd_lower4, color=color.new(color.teal, 90))
bhd_lower_line5 = plot(bhd_lower5, color=color.new(color.teal, 90))
// fill(bhd_upper_line5, bhd_lower_line5, color=color.new(color.teal, 95))

plot(ema50, color=color.orange, linewidth=3)
plot(ema200, color=color.teal, linewidth=3)
plot(close, color=color.teal, linewidth=1)
plot(close, color=colorRange(close), linewidth=3, style=plot.style_circles)
````
