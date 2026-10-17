# BTC Sentiment analysis RSI 2xEMA

- url: https://www.tradingview.com/script/kGVzpniP-BTC-Sentiment-analysis-RSI-2xEMA/
- type: strategy
- pine_id: PUB;a2483bdc4eb34f648db245a8cb50e9e2
- version: 1.0

## Description

This is a CRYPTO correlation strategy, which is using BTC sentiment with BITFINEX long and short ratios.
WIth them we are making from one side 2 RSI, one for long and another for short. And from another side, we are going to make multiple EMA's, using the ratios for long and short.

Rules for entry
For this scenario I created a long only strategy.
The long entry condition is : we have a crossover of the rsi long ratio with rsi short ratio and long ratio from BITFINEX is above the long EMA and short ratio from BITFINEX is below short EMA.

We exit when we get the opposite condition, in this case  we have a crossunder of the rsi long ratio with rsi short ratio and long ratio from BITFINEX is below the long EMA and short ratio from BITFINEX is above short EMA.


If you have any questions, let me know !

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © exlux99

//@version=4

strategy("BTC Sentiment analysis RSI",initial_capital = 1000, default_qty_type=strategy.percent_of_equity, default_qty_value=100, commission_type=strategy.commission.percent, commission_value=0.03, pyramiding=1  )

longs = change(security("BITFINEX:BTCUSDLONGS", timeframe.period, close))
shorts = change(security("BITFINEX:BTCUSDSHORTS", timeframe.period, close))
l = input(48, title="RSI length")
rsilong = rsi(security("BITFINEX:BTCUSDLONGS", timeframe.period, close), l)
rsishort = rsi(security("BITFINEX:BTCUSDSHORTS", timeframe.period, close), l)
plot(rsilong, color=color.green, style=plot.style_line)
plot(rsishort, color=color.red, style=plot.style_line)

ema_input=input(10)

ema_1 = ema(longs, ema_input)
ema_2 = ema(shorts, ema_input)
ema_3 = ema(longs, ema_input)
ema_4 = ema(shorts, ema_input)
bcolor = longs > ema(longs, ema_input) and shorts > ema(shorts, ema_input) ? color.yellow : 
   longs > ema_1 and shorts < ema_2 ? color.lime : 
   longs < ema_3 and shorts > ema_4 ? color.red : color.gray
plot(0, color=bcolor, style=plot.style_cross, linewidth=3)
hline(0)

fromDay = input(defval = 1, title = "From Day", minval = 1, maxval = 31)
fromMonth = input(defval = 1, title = "From Month", minval = 1, maxval = 12)
fromYear = input(defval = 2000, title = "From Year", minval = 1970)
 //monday and session 
// To Date Inputs
toDay = input(defval = 31, title = "To Day", minval = 1, maxval = 31)
toMonth = input(defval = 12, title = "To Month", minval = 1, maxval = 12)
toYear = input(defval = 2021, title = "To Year", minval = 1970)

startDate = timestamp(fromYear, fromMonth, fromDay, 00, 00)
finishDate = timestamp(toYear, toMonth, toDay, 00, 00)
time_cond = time >= startDate and time <= finishDate 

if(time_cond)
    strategy.entry("long",1,when=crossover(rsilong,rsishort)  and (longs > ema_1 and shorts < ema_2))
    strategy.close('long',when=crossunder(rsilong,rsishort) and (longs < ema_3 and shorts > ema_4))
    //strategy.entry('short',0,when=crossunder(rsilong,rsishort) and  longs < ema_3 and shorts > ema_4)
````
