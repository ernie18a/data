# BB+RSI+OBV

- url: https://www.tradingview.com/script/zqWwm7TT-BB-RSI-OBV/
- type: strategy
- pine_id: PUB;9DFHUUUMK7LI6lnNJZBXLzYXTGjWquJC
- version: 1.0

## Description

I use Bolinger Band and RSI and OBV

when Bolinger band midline cross and rsi is bigger than 50 and obv is going up i wrote this strategy to test this strategy

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © atakhadivi

//@version=4
strategy("BB+RSI+OBV", overlay=true)

src = close
obv = cum(sign(change(src)) * volume)
// plot(obv, color=#3A6CA8, title="OnBalanceVolume")

source = close
length = input(20, minval=1)
mult = input(2.0, minval=0.001, maxval=50)
basis = sma(source, length)
dev = mult * stdev(source, length)
upper = basis + dev
lower = basis - dev
buyEntry = source > basis and rsi(close, 14) > 50 and obv[1] < obv 
buyExit = source < lower
sellEntry = source < basis and rsi(close, 14) < 50 and obv[1] > obv
sellExit = source > upper
strategy.entry("BBandLE", strategy.long, stop=lower, oca_name="BollingerBands", oca_type=strategy.oca.cancel, comment="BBandLE", when=buyEntry)
strategy.exit(id='BBandLE', when=buyExit)
strategy.entry("BBandSE", strategy.short, stop=upper, oca_name="BollingerBands", oca_type=strategy.oca.cancel, comment="BBandSE", when=sellEntry)
strategy.exit(id='BBandSE', when=sellExit)
````
