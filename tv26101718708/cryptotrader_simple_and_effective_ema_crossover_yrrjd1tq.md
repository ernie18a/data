# CryptoTrader - Simple and effective Ema Crossover

- url: https://www.tradingview.com/script/yrRjD1Tq-CryptoTrader-Simple-and-effective-Ema-Crossover/
- type: strategy
- pine_id: PUB;zcJTIcT1eXQSa3Xjhz6pSG3Ie5WdLNs0
- version: 1.0

## Description

Works well on 4h charts, ETHUSD,BTCUSD,and XRPUSD but can be tested also on other crypto's.
On those pairs no need of sofisticate scripts to trade.
Can add a trailing stop, but as you see works perfect as it is.
KISS (Keep It Simple Stupid).

## Source Code

````pine
//@version=3
strategy("CryptoTrader", overlay=true)

longCondition = crossover(sma(close, 50), sma(close, 200))
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)

shortCondition = crossunder(sma(close, 50), sma(close, 200))
if (shortCondition)
    strategy.entry("My Short Entry Id", strategy.short)
````
