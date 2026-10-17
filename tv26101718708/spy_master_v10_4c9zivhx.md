# SPY Master v1.0

- url: https://www.tradingview.com/script/4c9zIvHX-SPY-Master-v1-0/
- type: strategy
- pine_id: PUB;2308
- version: -1.0

## Description

This is a simple swing trading algorithm that uses a fast RSI-EMA to trigger buy/cover signals and a slow RSI-EMA to trigger sell/short signals for SPY, an xchange-traded fund for the S&P 500.

The idea behind this strategy follows the premise that most profitable momentum trades usually occur during periods when price is trending up or down. Periods of flat price actions are usually where most unprofitable trades occur. Because we cannot predict exactly when trending periods will occur, the algorithm basically bets money on all trade opportunities during all market conditions. Despite an accuracy rate of only 40%, the algorithm's asymmetric risk/reward profile allows the average winner to be 2x the average loser. The end result is a positive (profitable) net payout. 

[b]TRADING RULES:[/b]

Buy/Cover = EMA3(RSI2) cross> 50
Sell/Short = EMA5(RSI2) cross< 50 

[b]BACKTEST SETTINGS: [/b]

- Period = March 2011 - Present 
- Initial capital = $10,000 
- Dividends excluded
- Trading costs excluded

[b]PERFORMANCE COMPARISON:[/b]

There are 657 trades, which means 1,314 orders. Assuming each order costs $2 (what I pay for at Interactive Brokers), total trading costs should be $2,628.

-SPY (buy & hold) = 132.73 ---> 193.22 = [b]+45.57%[/b] (dividends excluded)
-SPY Master v1.0 = $12,649 - $2,628 = $10,021 = [b]+100.21% [/b]

[b]DISCLAIMER:[/b] None of my ideas and posts are investment advice. Past performance is not an indication of future results. This strategy was constructed with the benefit of hindsight and its future performance cannot be guaranteed.

## Source Code

````pine
//@version=2
strategy("SPY Master v1.0", overlay=true)

basis = rsi(ohlc4, input(2))

rsiema1 = ema(basis, input(3))
rsiema2 = ema(basis, input(5))

trigger1 = input(50)
trigger2 = input(50)

if (crossover(rsiema1, trigger1))
    strategy.entry("BUY", strategy.long, comment="BUY")

if (crossunder(rsiema2, trigger2))
    strategy.entry("SELL", strategy.short, comment="SELL")
````
