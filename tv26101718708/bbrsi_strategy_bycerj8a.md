# BB+RSI strategy

- url: https://www.tradingview.com/script/bYcerj8a-BB-RSI-strategy/
- type: strategy
- pine_id: PUB;Z1DvuRgsBc5sBmip9JdpxuPDpYmVk7JA
- version: 1.0

## Description

BB and RSI

## Source Code

````pine
// @version=2
strategy(title="BB+RSI strategy")

sdev20 = stdev(close, 20)
sma20 = sma(close, 20)

upBB20 = sma20 + (sdev20 * 2)
lwBB20 = sma20 - (sdev20 * 2)

middleBB20 = sma20

rsi10 = rsi(close, 10)


strategy.entry("Position", true, 0.3, when = close < lwBB20 and rsi10 < 25)
strategy.close("Position", when = strategy.openprofit > 0.008) // and close[1] < close)

plot(strategy.position_size)

//strategy.entry("SHORT", false, 1, when = close > upBB20 and rsi10 > 55)
//strategy.close("SHORT", when = strategy.openprofit > 0.01 or strategy.openprofit < -0.01)
````
