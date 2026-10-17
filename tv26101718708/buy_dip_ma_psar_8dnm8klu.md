# Buy Dip MA & PSAR

- url: https://www.tradingview.com/script/8dNM8kLu-Buy-Dip-MA-PSAR/
- type: strategy
- pine_id: PUB;F8pDFPuLTlQyA2no5tSzKuz4zSwWT0aG
- version: 1.0

## Description

This is my first script. Please don't use because I was just testing.

## Source Code

````pine
//@version=3
strategy("Buy Dip MA & PSAR", overlay=true)

PSAR_start = input(0.02)
PSAR_increment = input(0.02)
PSAR_maximum = input(0.2)

EMA_fast = input(20)
EMA_slow = input(40)
SMA_fast = input(100)
SMA_slow = input(200)

emafast = ema(close, EMA_fast)
emaslow = ema(close, EMA_slow)
smafast = sma(close, SMA_fast)
smaslow = sma(close, SMA_slow)

psar = sar(PSAR_start, PSAR_increment, PSAR_maximum)
uptrend = emafast > emaslow and smafast > smaslow
breakdown = not uptrend

if (psar >= high and uptrend)
    strategy.entry("Buy", strategy.long, stop=psar, comment="Buy")
else
    strategy.cancel("Buy")

if (psar <= low)
    strategy.exit("Close", "Buy", stop=psar, comment="Close")
else
    strategy.cancel("Close")

if (breakdown)
    strategy.close("Buy")


plot(emafast, color=blue)
plot(emaslow, color=red)
````
