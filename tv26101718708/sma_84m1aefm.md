# SMA

- url: https://www.tradingview.com/script/84m1aEFM-SMA/
- type: strategy
- pine_id: PUB;Tw8oTfixISZiq9dao4jBYRipIVYBT4XI
- version: 1.0

## Description

A simple script wih SMA 10 20 50 100 200 and High 10 & Low 200

## Source Code

````pine
//SMA 10 20 50 100 200 for scalping by ML1
//@version=3
strategy("SMA",overlay=true)

plot(sma(high,10),color = black,linewidth=4, title = '10 High')
plot(sma(close,10),color = orange,linewidth=3, title = '10')
plot(sma(close,20),color = gray, linewidth=3, title = '20')

plot(sma(close,50),color = blue, linewidth=3, title = '50')
plot(sma(close,100),color = green, linewidth=3, title = '100')

plot(sma(close,200),color = purple, linewidth=3, title = '200')

plot(sma(low,200),color = black,linewidth=4, title = '200 Low')
````
