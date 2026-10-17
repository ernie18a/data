# CCI strategy on OIL1H

- url: https://www.tradingview.com/script/RpcKWz8V-CCI-strategy-on-OIL1H/
- type: strategy
- pine_id: PUB;0SgZTJuugBAQK9aBC2JFWr6VN7rgEJ6P
- version: 1.0

## Description

This indicator is based on Commodity Channel Index. 

It buys when CCI on period 200 is under -130 and it´s rising last 12 bars. It closes the position by hitting Take Profit, Stop Loss or opening short position.

It sells when CCI on period 200 is over 130 and it´s falling last 12 bars. It closes the position by hitting Take Profit, Stop Loss or opening short position.

This strategy seems to working just on [symbol="TVC:USOIL"]USOIL[/symbol] on 1 hour chart. This can predict that it´s just luck and not proper strategy or indicator I would use for trading.

This script is just for educational purposes and that´s why the script is open. I will be happy if you will leave comment and try to come up with some ideas how to improve this strategy, so it can be used also on other commodities/forex pairs.

## Source Code

````pine
//@version=4
strategy("My Strategy", overlay=true)

shortCondition = falling(cci(close,200),12) and cci(close,200)>130
if (shortCondition)
    strategy.entry("Short Entry", strategy.short)
    strategy.exit("exitL", "Short Entry", profit = open/0.34, loss = open/0.81)

longCondition = rising(cci(close,200),12) and cci(close,200)<-130
if (longCondition)
    strategy.entry("Long Entry", strategy.long)
    strategy.exit("exitS", "Long Entry", profit = open/0.34, loss = open/0.81)
````
