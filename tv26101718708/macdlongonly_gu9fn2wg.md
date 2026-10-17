# MACD_Long_Only

- url: https://www.tradingview.com/script/Gu9Fn2Wg-MACD-Long-Only/
- type: strategy
- pine_id: PUB;tUVK5ZWdzH2fsCgOzVCk6COc2VUD3uqK
- version: 1.0

## Description

I created this indicator to calculate the gains that can be made purely by going long on the market. For exchanges without the ability to short, the standard MACD strategy is unable to accurately calculate the profit/loss from entering and exiting a position, as it includes profit/loss from actively shorting the market, which may either not be possible, or be undesirable for a specific asset.

## Source Code

````pine
//@version=3
strategy(title="MACD_Long_Only",overlay=true,scale=scale.left)
Slow=input(type=integer,defval=26,minval=1)
Fast=input(type=integer,defval=12,minval=1)
slowing=input(type=integer,defval=9,minval=1)

fastLength = input(12)
slowlength = input(26)
MACDLength = input(9)

MACD = ema(close, fastLength) - ema(close, slowlength)
aMACD = ema(MACD, MACDLength)
delta = MACD - aMACD


[main,signal,histo]=macd(close,Fast,Slow,slowing)

buy_entry= crossover(delta,0)
//sell_entry=main<signal and crossunder(close,parsar)?true:na

strategy.entry("Buy",true , when=buy_entry)
strategy.close("Buy",when=crossunder(delta,0))
````
