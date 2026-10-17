# apo-heikin

- url: https://www.tradingview.com/script/T0hrkQqU-apo-heikin/
- type: strategy
- pine_id: PUB;HGeixTL2jhwDuN5yw66oTdU55cfXgfUy
- version: 1.0

## Description

just education

## Source Code

````pine
//@version=3
strategy(title="apo-heikin", shorttitle="apo-heikin", overlay=true)
// Script created by JoinFree
// BollingerBands added for reference
// Buy Long when you see a Green colour bar 
// Sell Short when you see a Red colour bar

//heikin ashi ye göre kapanıs fiyatlar cevrılır
//HA_Close = (Open + High + Low + Close) / 4 formul bu sekıldedir.
mysignal = ema(close, 7) - ema(close, 26)// 12 gunluk EMA kapanıs fıyatı 26 günlük EMA  kapanıs fiyaından cıkarılır
plot(ema(close, 7))
plot(ema(close, 26))
barcolor(mysignal[0] > mysignal[1] ? green : red)// o anki kapanan mum bir öncki mumdan buyukse al sinyalidir.
// değilse sat sinyalidir.
if (mysignal[0] > mysignal[1]) 
    strategy.entry("Long", strategy.long,when=(time > timestamp(2019, 02, 22, 00, 00) and time < timestamp(2019, 02, 31, 00, 00)))
if (mysignal[0] < mysignal[1])
    strategy.entry("Short", strategy.short,when=(time > timestamp(2019, 02, 22, 00, 00) and time < timestamp(2019, 02, 31, 00, 00)))	   	    

sourced = close
length = input(20, minval=1), mult = input(2.0, minval=0.001, maxval=50)
basis = sma(sourced, length)
dev = mult * stdev(sourced, length)
upper = basis + dev
lower = basis - dev
plot(basis, color=red)
p1 = plot(upper, color=blue)
p2 = plot(lower, color=blue)
fill(p1, p2)
````
