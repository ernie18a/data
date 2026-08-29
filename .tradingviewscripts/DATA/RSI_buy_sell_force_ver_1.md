<!-- tradingview-pine-id: PUB;jAarxd7972oLro2b70KOoRUqCjafc2km -->
<!-- tradingviewscripts-format: 1 -->
# RSI buy sell force ver 1 

Source: https://www.tradingview.com/script/15KB0KGb-RSI-buy-sell-force-ver-1/

## Description

Very simple script with no security MTF that show RSI buy and sell force 
blue above red =bullish period 
red above blue =bearish period
or you can try above 0 or bellow 0 as signal 
if you want i will add signal after to this one

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RafaelZioni

//@version=4
study(title = "RSI buy sell force ver 1 ", overlay = false)
length=14
HTF = input("W", type=input.resolution)
ti = change( time(HTF) ) != 0
p = fixnan( ti ? close : na )

len =14
//
vrsi = rsi(p, length)
pp=ema(vrsi,len)

//

d=(vrsi-pp)*5
bb=(vrsi-d+pp)/2
cc=(vrsi+d+pp)/2
//
avg=(cc+bb)/2
plot(cc,linewidth=2)
plot(bb,color=color.red,linewidth=2)
plot(avg,color=color.gray,linewidth=1)
plot(0)
````
