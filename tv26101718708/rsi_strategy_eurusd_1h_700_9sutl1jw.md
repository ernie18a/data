# RSI Strategy EUR/USD 1H 700%

- url: https://www.tradingview.com/script/9SutL1Jw-RSI-Strategy-EUR-USD-1H-700/
- type: strategy
- pine_id: PUB;2638
- version: -1.0

## Description

A rsi strategy that has potential to do over 700% annually on the EURUSD 1h

## Source Code

````pine
//@version=2
strategy("RSI Strategy", overlay=true)
length = input( 14 )
overSold = input( 27 )
overBought = input( 73 )
price = close

vrsi = rsi(price, length)

if (not na(vrsi))
    if (crossover(vrsi, overSold))
        strategy.entry("RsiLE", strategy.long, qty=10000, comment="RsiLE")
      
    if (crossunder(vrsi, overBought))
        strategy.entry("RsiSE", strategy.short, qty=10000, comment="RsiSE")
````
