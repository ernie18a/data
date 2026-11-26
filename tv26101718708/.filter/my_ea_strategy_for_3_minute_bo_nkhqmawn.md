# My EA Strategy for 3 minute BO

- url: https://www.tradingview.com/script/nkHQMAwn-My-EA-Strategy-for-3-minute-BO/
- type: strategy
- pine_id: PUB;2241
- version: -1.0

## Description

I made an EA for my long term project on Binary Option trading.
TimeFram = 1 minute
Signals are:
Green Spike = Buy (for 3 minutes expiration)
Red Spike    = Sell  (for 3 minutes expiration)

Strategy:
VMWA (50&200) = Trend Indicators
RSI (30)               = pull back entry signal on a strong trend
BackTest = 80% Winning Rate

Improvements Needed:
>> Better Entry Star Signals
>> How to be automatically connected to a certain broker for HFT

## Source Code

````pine
//Based on Larry Connors RSI-2 Strategy - Lower RSI
strategy(title="_CM_RSI_2_Strat_Low", shorttitle="_CM_RSI_2_Strategy_Lower", overlay=false)
src = close, 

//RSI CODE
up = rma(max(change(src), 0), 30)
down = rma(-min(change(src), 0), 30)
rsi = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))
//Criteria for Moving Avg rules
ma50= vwma(close,30)
ma200= vwma(close,200)

//Rule for RSI Color
col = ma50 > ma200 and rsi <=53?lime: ma50 < ma200  and rsi >= 60?red : silver
long = ma50 > ma200 and rsi <= 53
short = ma50 < ma200  and rsi >= 60
//plot(rsi, title="RSI", style=line, linewidth=1,color=col)
//plot(100, title="Upper Line 100",style=line, linewidth=3, color=aqua)
//plot(0, title="Lower Line 0",style=line, linewidth=3, color=aqua)

//band1 = plot(60, title="Upper Line 60",style=line, linewidth=1, color=aqua)
//band0 = plot(44, title="Lower Line 40",style=line, linewidth=1, color=aqua)
//fill(band1, band0, color=silver, transp=90)
strategy.entry ("buy", strategy.long, when=long)
strategy.entry ("sell", strategy.short, when=short)
plot(long,"long",color=green,linewidth=1)
plot(short,"short",color=red,linewidth=1)
````
