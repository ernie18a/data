# Volume Extra (@ulong_Mask)

- url: https://www.tradingview.com/script/ORSD69qJ-Volume-Extra-ulong-Mask/
- type: strategy
- pine_id: PUB;eOm7XGoLR57wMYA0bkoxv711QbkaEAKc
- version: 2.0

## Description

High volume illumination

You can choose which volume to highlight

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ulong_Mask

//@version=4
strategy(title='Volume Extra (@ulong_Mask)', calc_on_every_tick=true)

maxvol = input(20000, minval=1, title="MaxVol")
lw = input(3, minval=1, title="LineWidth")

f_buy() =>
    if(close >= open)
        color.green
        
f_sell() =>
    if(open > close)
        color.red
        
f_extra() =>
    if(volume > maxvol)
        color.yellow

plot(volume, title="Buy",style=plot.style_histogram,linewidth=lw,color = f_buy())
plot(volume, title="Sell",style=plot.style_histogram,linewidth=lw,color = f_sell())
plot(volume, title="Volume Extra",style=plot.style_histogram,linewidth=lw,color = f_extra())
````
