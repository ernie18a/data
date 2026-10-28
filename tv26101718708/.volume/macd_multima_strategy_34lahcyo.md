# MACD Multi-MA Strategy

- url: https://www.tradingview.com/script/34lAHcyo-MACD-Multi-MA-Strategy/
- type: strategy
- pine_id: PUB;RHX6IvtSbsVR0eTfFqc766cwi5dAaZ1Y
- version: 3.0

## Description

This script applies the average of each major MA (SMA, RMA, EMA, WVMA, WMA) to the MACD formula.

The logic is simple. When all 5 MA's are in agreement in direction, then then script will notify users of change.
I posted this as a strategy to help show how logic does in back test. If you use my simple yet effective solution to find take profit locations, you can blow this back testing out of the water!!!


To set alerts simply turn script into study



//@version=2
study(title="MACD Multi-MA Study", overlay=false)

src = close 
len1 = input(8, "FAST LOOKBACK") 
len2 = input(144, "SLOW LOOKBACK")

/////////////////////////////////////////////
length = len2-len1
ma = vwma(src, length)
plot(ma, title="VWMA", color=lime)


length1 = len2-len1
ma1 = rma(src, length1)
plot(ma1, title="RMA", color=purple)

length2 = len2-len1
ma2 = sma(src, length2)
plot(ma2, title="SMA", color=red)


length3 = len2-len1
ma3 = wma(src, length3)
plot(ma3, title="WMA", color=orange)

length4 = len2-len1
ma4 = ema(src, length4)
plot(ma4, title="EMA", color=yellow)


long = ma > ma[1] and ma1 > ma1[1] and ma2 > ma2[1] and ma3 > ma3[1] and ma4 > ma4[1]
short = ma < ma[1] and ma1 < ma1[1] and ma2 < ma2[1] and ma3 < ma3[1] and ma4 < ma4[1]

alertcondition(long == true, title='MACD LONG SIGNAL', message='MACD LONG!')
alertcondition(short == true, title='MACD SHORT SIGNAL', message='MACD SHORT!')

## Source Code

````pine
//@version=4
/// Updated from my previous error from miscalculating MACD formula

strategy(title="Multi-MA Strategy", overlay=true, calc_on_order_fills=true, initial_capital=100000, default_qty_type=strategy.percent_of_equity, currency="USD", default_qty_value=100)

src = close 
len = input(66, "LOOKBACK") 


/////////////////////////////////////////////

ma = vwma(src, len)
plot(ma, title="VWMA", color=color.lime)

ma1 = rma(src, len)
plot(ma1, title="RMA", color=color.purple)


ma2 = sma(src, len)
plot(ma2, title="SMA", color=color.red)


ma3 = wma(src, len)
plot(ma3, title="WMA", color=color.orange)


ma4 = ema(src, len)
plot(ma4, title="EMA", color=color.yellow)


long = ma > ma[1] and ma1 > ma1[1] and ma2 > ma2[1] and ma3 > ma3[1] and ma4 > ma4[1]
short = ma < ma[1] and ma1 < ma1[1] and ma2 < ma2[1] and ma3 < ma3[1] and ma4 < ma4[1]


strategy.entry("Long", strategy.long, when=long)
strategy.entry("Short", strategy.short, when=short)
````
