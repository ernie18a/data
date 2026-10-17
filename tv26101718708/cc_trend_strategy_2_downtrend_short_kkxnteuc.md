# CC Trend strategy 2- Downtrend Short

- url: https://www.tradingview.com/script/kKxnTEuC-CC-Trend-strategy-2-Downtrend-Short/
- type: strategy
- pine_id: PUB;163772071bf54189be2cbda9fccf94d8
- version: 1.0

## Description

Trend Strategy #2

Indicators:
1. EMA(s)
2. Fibonacci retracement with a mutable lookback period 

Strategy:
1. Short Only
2. No preset Stop Loss/Take Profit
3. 0.01% commission
4. When in a profit and a closure above the 200ema, the position takes a profit.
5. The position is stopped When a closure over the (0.764) Fibonacci ratio occurs.
* NO IMMEDIATE RE-ENTRIES EVER!*

How to use it and what makes it unique:
This strategy will enter often and stop quickly. The goal with this strategy is to take losses often but catch the big move to the downside when it occurs through the Silvercross/Fibonacci combination. This is a unique strategy because it uses a programmed Fibonacci ratio that can be used within the strategy and on any program. You can manipulate the stats by changing the lookback period of the Fibonacci retracement and looking at different assets/timeframes. 

This description tells the indicators combined to create a new strategy, with commissions and take profit/stop loss conditions included, and the process of strategy execution with a description of how to use it. If you have any questions feel free to PM me and boost if you found it helpful. Thank you, pineUSERS!


[b][/b]CHEATCODE1[i][/i]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CheatCode1

//@version=5
strategy("CC-Trend strategy 2", overlay=true, initial_capital = 10000, commission_type = strategy.commission.percent, commission_value = 0.01, default_qty_type =  strategy.percent_of_equity, default_qty_value = 100 )
ema9 = ta.ema(close, 9)
ema21 = ta.ema(close, 21)
ema55 = ta.ema(close, 55)
ema200 = ta.ema(close, 200)


plot(ema200, '22', color.blue, 2)

FibL = input.int(100, 'Fibonacci Length', 1, 500, group = 'Automatic Fibonacci Retracement')
len1 = input.int(1, 'Show Last', 0, 1000, group = 'Automatic Fibonacci Retracement')
len2 = input.int(5, 'Offset Length', 0, 1000, group = 'Automatic Fibonacci Retracement')

highF = ta.highest(ema55 >= ema9 ? ema55:ema9, FibL)
lowF = ta.lowest(ema55 >= ema9 ? ema9:ema55, FibL)
AvgFib = highF - lowF

//Fibonacci Executions
LL2 = highF + .618 * AvgFib
LL1 = highF + .272 * AvgFib
L1 = highF
L236 = highF - 0.236 * AvgFib
L382 = highF - 0.382 * AvgFib
Mid =  highF - 0.50 * AvgFib
S382 = lowF + 0.382 * AvgFib
S236 = lowF + 0.236 * AvgFib
S1 = lowF
SS1 = lowF - .272 * AvgFib
SS2 = lowF - .618 * AvgFib
//Fibonacci Plot's


high2FP = plot(LL2, 'Highe2', color.red,offset = len2, show_last = len1, trackprice = true)
high1FP = plot(LL1, 'Highe1', color.red,offset = len2, show_last = len1, trackprice = true)
highFP = plot(highF, 'High', color.red,offset = len2, show_last = len1, trackprice = true)
L236P = plot(L236, "0.764", #ED381C, offset = len2, show_last = len1, trackprice = true )
L382P = plot(L382, "0.618", color.white,offset = len2, show_last = len1, trackprice = true )
MidP = plot(Mid, "0.5", color.orange,offset = len2, show_last = len1, trackprice = true )
S382P = plot(S382, "0.382", color.yellow ,offset = len2, show_last = len1, trackprice = true)
S236P = plot(S236, "0.236", color.lime ,offset = len2, show_last = len1, trackprice = true)
lowFP = plot(lowF, 'Low', color.green,offset = len2, show_last = len1, trackprice = true)
low1FP = plot(SS1, 'Lowe1', color.green,offset = len2, show_last = len1, trackprice = true)
low2FP = plot(SS2, 'Lowe2', color.green,offset = len2, show_last = len1, trackprice = true)

plot(ema9, '22', color.yellow, 2)

plot(ema55, '55', color.aqua, 2)

plot(ema200, '200', color.maroon, 2)



shortCondition = close[1] < highF and ema21 < ema55
if (shortCondition)
    strategy.entry("Short", strategy.short)

shorttp = ta.crossover(close, ema200) and strategy.openprofit >= 0
if (shorttp)
    strategy.close('Short', 'Short TP', qty_percent = 100)

shortclose2 = close[1] > L236 and not (shortCondition) 
if(shortclose2)
    strategy.close('Short', 'Short RM', qty_percent = 100)
````
