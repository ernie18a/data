# LinearRegressionChannelBreakout

- url: https://www.tradingview.com/script/diTCC7a5-LinearRegressionChannelBreakout/
- type: strategy
- pine_id: PUB;cDLS6b7RLxw3V0EFHUg3XXCky2ddKuHL
- version: 1.0

## Description

My first idea about the linear regression channel... It is free and available for everybody.

## Source Code

````pine
//@version=2
strategy("LinearRegressionChannelBreakout", overlay=true, max_bars_back=5000, default_qty_type=strategy.fixed, default_qty_value=10000, currency="EUR")

length = input( 100 )
hprice = high
lprice = low
cprice = close

strategy.close("Short", crossover(cprice, linreg(low, length, 0)))
strategy.close("Long",  crossunder(cprice, linreg(high, length,0)))
strategy.entry("Long",  strategy.long, comment="Long", when = (strategy.position_size==0 and crossover(cprice, linreg(high, length,0))))
strategy.entry("Short", strategy.short, comment="Short", when = (strategy.position_size==0 and crossunder(cprice, linreg(low, length,0))))
````
