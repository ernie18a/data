# Binary Options Strategy Testing Script

- url: https://www.tradingview.com/script/2Yd3yq9z-Binary-Options-Strategy-Testing-Script/
- type: indicator
- pine_id: PUB;2152
- version: -1.0

## Description

This is a script for testing binary options trading strategies.  To test a strategy, modify the 'go_down' or 'go_up' booleans. These SHOULD NOT access any current values (for example, 'ohlc4' or 'close[0]'), or the backtesting will not be an accurate representation of the forward values.

Modify the fraction_return input to be the return rate of the option on success.  This is assumed to be a true 100 or 0 option- i.e. if the choice is not correct, there is a 100% loss.

The strategy in place is merely an example, and as you can see, has a very negative rate of return when implemented as a strategy.

Please comment in your code if you use this in any future posts. Thanks!

## Source Code

````pine
//@version=2
study("Binary Options Tester", overlay=false)

sma_12_min = sma(hl2,12)
sma_60_min = sma(hl2,60)

go_down = (open[1] > close[1]) and (open[2] > close[2]) and (sma_12_min[1] < sma_60_min[1])
go_up = (open[1] < close[1]) and (open[2] < close[2]) and (sma_12_min[1] > sma_60_min[1])

//win/lose testing. leave these lines for tester
val_win = go_down ? ((open[0] > close[0]) ? (val_win[1] + 1) : (val_win[1])) : (go_up ? ((open[0] < close[0]) ? (val_win[1] + 1) : (val_win[1])) : (nz(val_win[1]) + 0))
val_lose = go_down ? ((open[0] > close[0]) ? (val_lose[1]) : (val_lose[1] + 1)) : (go_up ? ((open[0] < close[0]) ? (val_lose[1]) : (val_lose[1] + 1)) : (nz(val_lose[1]) + 0))
//

fraction_return = input(.88, title='fraction_return')

return = (val_win * fraction_return)  - val_lose

plot(return)
//plot(val_win,color=green)
//plot(val_lose,color=red)
//plot(sma_12_min, color=blue)
//plot(sma_60_min, color=orange)
````
