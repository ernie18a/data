# Nifty Power -> Nifty 50 chart + EMA of RSI + avg volume strategy

- url: https://www.tradingview.com/script/MbbgmZp5-Nifty-Power-Nifty-50-chart-EMA-of-RSI-avg-volume-strategy/
- type: strategy
- pine_id: PUB;23b0de95d79745b0a40cd5c10aa6089f
- version: 1.0

## Description

This strategy works in 1 hour candle in Nifty 50 chart. In this strategy, upward trade takes place when there is a crossover of RSI 15 on EMA50 of RSI 15 and volume is greater than volume based EMA21. On the other hand, lower trade takes place when RSI 15 is less than EMA50 of RSI 15. Please note that there is no stop loss given and also that the trade will reverse as per the trend. Sometimes on somedays, there will be no trades. Also please note that this is an Intraday strategy. The trade if taken closes on 15:15 in Nifty 50. This strategy can be used for swing trading. Some pine script code such as supertrend and ema21 of close is redundant. Try not to get confused as only EMA50 of RSI 15 is used and EMA21 of volume is used. I am using built-in pinescript indicators and there is no special calculation done in the pine script code. I have taken numbars variable to count number of candles. For example, if you have 30 minuite chart then numbars variable will count the intraday candles accordingly and the same for 1 hour candles.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Archer_Trade

//@version=6
strategy("Nifty Teaching")

numBars=1

t = time('D')

if t == t[1]
    numBars := nz(numBars[1]) + 1
else
    numBars := 1

RSI = ta.rsi(close,15)
EMA21 = ta.ema(RSI,50)
ema21 = ta.ema(close,21)
emavol = ta.sma(volume,50)
[supertrend, direction] = ta.supertrend(3, 10)
highestHigh = ta.highest(high, 50)
lowestLow = ta.lowest(low, 50)

up = ta.crossover(RSI,EMA21) and volume>emavol?true:false
down = RSI<EMA21?true:false

if up and numBars!=6
    if strategy.position_size==0
        strategy.entry("BUY",strategy.long)
    else if strategy.position_size<0
        strategy.close_all()
        strategy.entry("BUY",strategy.long)

if down and numBars!=6
    if strategy.position_size==0
        strategy.entry("SELL",strategy.short)
    else if strategy.position_size>0
        strategy.close_all()
        strategy.entry("SELL",strategy.short)

if numBars==6 and strategy.position_size!=0
    strategy.close_all()
````
