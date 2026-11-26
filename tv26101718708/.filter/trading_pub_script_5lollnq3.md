# Trading Pub Script

- url: https://www.tradingview.com/script/5LOLLnQ3-Trading-Pub-Script/
- type: strategy
- pine_id: PUB;Ae5PzCL1AOOZ76xTPCIGltYjos9s45O2
- version: 1.0

## Description

Crazy curve fitting, but I'm just trying to practice writing strategies.  If only it were actually this easy!

## Source Code

````pine
//@version=3
strategy(title="Trading Pub", shorttitle="T Pub Strat")

USE_TRADESESSION = input(title='Use Trading Session?', type=bool, defval=true)
USE_TRAILINGSTOP = input(title='Use Trailing Stop?', type=bool, defval=true)
trade_session = input(title='Trade Session:', type=string, defval='0900-1430', confirm=false)
istradingsession = not USE_TRADESESSION ? false : not na(time('1', trade_session))
bgcolor(istradingsession?gray:na)

A=input(200, title="Short Lookback")
HH=((100-highestbars(A)/100)*100)
LL=((100-lowestbars(A)/100)*100)
plot(HH, color=green)
plot(LL, color=red)

B=input(200, title="Long Lookback")
HH2=((100-highestbars(B)/100)*100)
LL2=((100-lowestbars(B)/100)*100)
plot(HH2, color=blue)
plot(LL2, color=orange)

VV = vwap
plot(VV, color=fuchsia)

EMA1 = ema(close, 10) 

long = HH > LL and HH2 > LL2  and EMA1 > VV and (USE_TRADESESSION ? istradingsession : true)
short = HH < LL and HH2 < LL2 and EMA1 < VV and (USE_TRADESESSION ? istradingsession : true)

strategy.entry("long", strategy.long, when=long)
strategy.entry("short", strategy.short, when=short)
````
