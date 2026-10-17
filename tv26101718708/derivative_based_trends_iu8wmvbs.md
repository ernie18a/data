# Derivative Based Trends

- url: https://www.tradingview.com/script/IU8WmvbS-Derivative-Based-Trends/
- type: strategy
- pine_id: PUB;1EsujRzAn6M3SNJn0D3m9DfZF42u1gvc
- version: 1.0

## Description

Uses a combination of moving averages to establish trends, and finite-difference derivative approximations to predict possible reversals. Seems to work best on 1 hour charts of less volatile currency pairs.

## Source Code

````pine
//@version=3
strategy("Big 3",overlay=true, default_qty_type=strategy.percent_of_equity)
 
// enter on Arrows
// take profit on touch with 80 SMA, gray, or at discretion
 
fast = sma(close,20)
mid = sma(close,40)
slow = sma(close,80)
 
plot(fast,linewidth=1)
plot(mid,linewidth=2)
plot(slow,linewidth=4)
 
isUptrend = close > fast and close > mid and close > slow
isDowntrend = close < fast and close < mid and close < slow
 
confirmed = (low > fast and low > mid and low > slow) or (high < fast and high < mid and high < slow)
deriv = 3 * mid[0] - 4 * mid[1] + mid[2]

stableUptrend = (fast > mid) and (mid > slow) and (deriv > 0)
stableDowntrend = (fast < mid) and (mid < slow) and (deriv < 0)
 
barcolor(isUptrend ? green : isDowntrend ? red : gray)
plotshape(not confirmed[1] and confirmed and isUptrend ? close : na,style=shape.arrowup,location=location.belowbar,color=green)
plotshape(not confirmed[1] and confirmed and isDowntrend ? close : na,style=shape.arrowdown,location=location.abovebar,color=red)

stop = na
//stop = input(1000, "Stop")


strategy.entry("long", strategy.long, when=(stableUptrend), stop=stop)
strategy.close("long", when=(deriv <= 0))

strategy.entry("short", strategy.short, when=(stableDowntrend), stop=stop)
strategy.close("short", when=(deriv >= 0))
````
