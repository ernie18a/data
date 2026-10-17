# EMA Cloud Intraday Strategy

- url: https://www.tradingview.com/script/bRU5AT0T-EMA-Cloud-Intraday-Strategy/
- type: strategy
- pine_id: PUB;55174c220eb24ac08f21588f10f4c06d
- version: 2.0

## Description

********NOT TRADING ADVICE - USE AT YOUR OWN RISK - TRADING IS RISKY - DO NOT BLINDLY FOLLOW THE SIGNALS FROM THIS STRATEGY********

This strategy utilizes the 9 and 20 period exponential moving averages to create a colored cloud between similar to what is seen on the Ichimoku Cloud. The strategy closes all trades by the end of the trading day. Entry is when the price closes above a Green (9 EMA above 20 EMA) cloud or below a Red (9 EMA below 20 EMA) cloud. Exit is when price closes against the 9 EMA or at the end of the trading day. Running the strategy tester on different intraday time frames will show the best time frame for a given Symbol. For example, I have found that the best results are returned by this strategy for SPY on the 30 minute time frame.

********NOT TRADING ADVICE - USE AT YOUR OWN RISK - TRADING IS RISKY - DO NOT BLINDLY FOLLOW THE SIGNALS FROM THIS STRATEGY********

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © rwestbrookjr

//@version=5
strategy("EMA Cloud Intraday Strategy", overlay=true, margin_long=100, margin_short=100, process_orders_on_close=true)

i_trdQty = input.int(100, "Trade Quantity", minval = 1)
pbTrig = input.float(1.00, "Pull Back Trigger", minval = 0.01)

session = time(timeframe.period, "0930-1555:23456")
validSession=(na(session) ? 0 : 1)


fastLen = input(title = "Fast EMA Length", defval = 9)
slowLen = input(title = "Slow EMA Length", defval = 20)

fastEMA = ta.ema(close, fastLen)
slowEMA = ta.ema(close, slowLen)

fema = plot(fastEMA, title = "FastEMA", color = color.green, linewidth = 1, style = plot.style_line)
sema = plot(slowEMA, title = "SlowEMA", color = color.red, linewidth = 1, style = plot.style_line)

Bull = fastEMA > slowEMA
Bear = fastEMA < slowEMA

fill(fema, sema, color = fastEMA > slowEMA ? color.new(#417505, 50) : color.new(#890101, 50), title = "Cloud")

longCondition = close > fastEMA and close[1] > fastEMA and validSession == 1
if (longCondition)
    strategy.entry("Long_Entry", strategy.long, qty=i_trdQty)
longExit = (close < fastEMA and close[1] < fastEMA) or close < (close[1] - pbTrig) or validSession == 0
if (longExit)
    strategy.close("Long_Entry")
    //strategy.exit("exit", "My Long Entry Id", trail_points=1.5, trail_offset=0)

shortCondition = close < fastEMA and close[1] < fastEMA and validSession == 1
if (shortCondition)
    strategy.entry("Short_Entry", strategy.short, qty=i_trdQty)
shortExit = (close > fastEMA and close[1] > fastEMA) or close > (close[1] + pbTrig) or validSession == 0
if (shortExit)
    strategy.close("Short_Entry")
    //strategy.exit("exit", "My Short Entry Id", trail_points=1.5, trail_offset=0)
    
// Close all trades at end of trading day
barOpenTime = time 

tt=timestamp(year(time), month(time), dayofmonth(time), hour(time), 2)
    
if ( hour(time) == 15 and minute(time) > 50  )  
    strategy.close("Short_Entry", comment="SCM")
    
if ( hour(time) == 15 and minute(time) > 50 )   
    strategy.close("Long_Entry", comment="SCM")


if validSession == 0// and strategy.opentrades != 0
    //if strategy.opentrades > 0
    strategy.close_all(comment="SC")
    //if strategy.opentrades < 0
        //strategy.close("Short_Entry", comment="SC")
````
