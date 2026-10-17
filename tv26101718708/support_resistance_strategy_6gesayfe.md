# Support Resistance Strategy

- url: https://www.tradingview.com/script/6GeSAYfE/
- type: strategy
- pine_id: PUB;oaIAYarEU8H6NCVIXN8ZVGxRPVpzxtbV
- version: 2.0

## Description

Support Resistance Strategy

## Source Code

````pine
//@version=4
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ceyhun

strategy("Support Resistance Strategy", overlay=true)

LB = input(10, title="length")
Barcolor=input(true,title="Barcolor")
Bgcolor=input(true,title="Bgcolor")

R = valuewhen(cross(sma(close, LB), close), highest(high, LB), 1)
S = valuewhen(cross(close, sma(close, LB)), lowest(low, LB), 1)

plot(R,title="Resistance", color=#008000)
plot(S,title="Support", color=#FF0000)

colors=iff(close>R,#008000,iff(S<close,#FFFF00,#FF0000))
barcolor(Barcolor ? colors:na)
bgcolor(Bgcolor ? colors:na)

if crossover(close, R)
    strategy.entry("Long", strategy.long, comment="Long")

if crossunder(close, S)
    strategy.entry("Short", strategy.short, comment="Short")
````
