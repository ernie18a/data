# TACA_RSI

- url: https://www.tradingview.com/script/24ocuOhG/
- type: strategy
- pine_id: PUB;lbJyJejtXnurYjPmqKaWS2GDqts1dVGX
- version: 1.0

## Description

ベーシックな押し目買いストラテジーです。
汎用性は高いのですが、銘柄別に最適化すれば更なるパフォーマンスが期待できます。

## Source Code

````pine
//@version=3
strategy("TACA_RSI",overlay=true)
MA=sma(close,90)
RSI10=rsi(close,10)
if( RSI10<30 and MA < close )
    strategy.entry("TACA RSI LONG" ,strategy.long )
if(RSI10>70 and MA>close)
    strategy.entry("TACA RSI SHORT",strategy.short)
strategy.exit("Exit Long" ,"TACA RSI LONG" ,when = RSI10>70 )
strategy.exit("Exit Short","TACA RSI SHORT",when = RSI10<30)
````
