# Nifty SMA Trend

- url: https://www.tradingview.com/script/Hfdkcwnt-Nifty-SMA-Trend/
- type: strategy
- pine_id: PUB;MjN4TWSKZjjcahGFkxHcSZKOQN1fNbBx
- version: 4.0

## Description

Nifty Buy and sell based on 2 simple moving average

## Source Code

````pine
//@version=3
strategy("Nifty SMA Trend",  pyramiding=0, initial_capital=100000, default_qty_type=strategy.percent_of_equity, default_qty_value=100, overlay=true)
s1 = input(50, title="SMA 1")
s2 = input(200, title="SMA 2")
y = input(2004, title="Year")
sma1= sma(close, s1)
plot(sma1, color=black, linewidth=1)
sma2= sma(close, s2)
plot(sma2, color=red, linewidth=1)
if year >= y
    if (close > sma1 and sma1 > sma2)
        strategy.entry("Long", strategy.long)
    if(close < sma1 and sma1 < sma2)
        strategy.close("Long")
````
