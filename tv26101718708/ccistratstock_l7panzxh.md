# CCI_Strat_Stock

- url: https://www.tradingview.com/script/L7pANzxH-CCI-Strat-Stock/
- type: strategy
- pine_id: PUB;AghaeFpZptLUlCOLQ1b9RWFryo5T2Ioy
- version: 1.0

## Description

CCI_Strat_Stock

## Source Code

````pine
//@version=4
strategy("CCI_Strat_Stock", overlay=true)

lookback = input(2,minval=1)

longCondition = cci(close[lookback],6) > cci(close[lookback],14) and crossover(cci(close,14),-50)
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)

shortCondition = cci(close[lookback],6) < cci(close[lookback],14) and crossunder(cci(close,14),50)
if (shortCondition)
    strategy.entry("My Short Entry Id", strategy.short)
````
