# Alex Days HiLo Rajib

- url: https://www.tradingview.com/script/tke82Sib-Alex-Days-HiLo-Rajib/
- type: strategy
- pine_id: PUB;IPa9Yy854adNOQreB14vFvirswysFkbz
- version: 1.0

## Description

20 Days High Low Breakout , can be as Contrarian Way or in Trending Way

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © 14rajib

//@version=4

strategy(title="Alex Days HiLo Rajib", overlay = true)
length = input(20)

hh = highest(high, length)
ll = lowest(low, length)

plot(hh[1], color=color.green, title="HH")
plot(ll[1], color=color.red, title="LL")
//bgColour = (high > hh) ? color.blue :
    // (low < ll) ? color.yellow :
    // na

//bgcolor(color=bgColour, transp=90)

plotshape(high>hh[1] ? hh + 5:na, color=#FF0000,location=location.absolute, style=shape.arrowdown)
plotshape(low< ll[1] ? ll-5: na, color=#00FF00, location=location.absolute, style=shape.arrowup)
````
