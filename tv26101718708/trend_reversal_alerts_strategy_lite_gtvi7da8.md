# Trend Reversal Alerts Strategy [lite]

- url: https://www.tradingview.com/script/gTVi7dA8-Trend-Reversal-Alerts-Strategy-lite/
- type: strategy
- pine_id: PUB;7fGqxqCxlHFBD6S13PgsAs1JryafW9BO
- version: 2.0

## Description

This strategy was created as experimental and after playing around with it, I was able to realize what is a good way to base your strategy on and what is not.

This one is most primitive way and you should not expect gains from it(it's best on the weekly btw).

Anyway, all my attempts to advance this strategy in the end gave me around 1%<x>2% +Net Profit on the hourly timeframe and drastically reduced the Net Profit by 50% on the weekly, so I think it is a waste of my time, but if you feel like you have ideas to share with me, please feel free to comments below!

## Source Code

````pine
//@version=6
strategy(title = 'Trend-Reversal.Alerts.Strategy[lite]', shorttitle = 'T-RAS lite', overlay = false)
if close[1] > close[2] and close < close[1]
    strategy.entry('buy', strategy.long)
if close[1] < close[2] and close > close[1]
    strategy.close('buy')
plot(strategy.position_size)
````
