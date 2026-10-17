# MACD_SAR

- url: https://www.tradingview.com/script/8V7fRfnB-MACD-SAR/
- type: strategy
- pine_id: PUB;pwgU4RdviaDnWdK4ATvqGsKC17PnmeeL
- version: 1.0

## Description

ParSar and MACD strategy depends on the crosses of PARSAR indicator above/below the closing price and is filtered by the MACD indicator. it yields good profits on stocks. however, it doesn't work very well for Forex if you want to use it on forex please apply it to higher time frame starting from 4H.

## Source Code

````pine
//@version=3
strategy(title="MACD_SAR",overlay=true,scale=scale.left)
Slow=input(type=integer,defval=26,minval=1)
Fast=input(type=integer,defval=12,minval=1)
slowing=input(type=integer,defval=9,minval=1)

[main,signal,histo]=macd(close,Fast,Slow,slowing)
parsar=sar(0.02,0.02,0.2)

buy_entry=main>signal and crossover(close,parsar) ?true:na
sell_entry=main<signal and crossunder(close,parsar)?true:na

strategy.entry("Buy",true , when=buy_entry)
strategy.close("Buy",when=crossunder(close,parsar))
strategy.entry("Sell",false,when=sell_entry)
strategy.exit("Sell", when=crossover(close,parsar))
````
