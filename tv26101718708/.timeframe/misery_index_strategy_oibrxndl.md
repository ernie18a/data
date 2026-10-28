# Misery index strategy

- url: https://www.tradingview.com/script/oIBrxndl-Misery-index-strategy/
- type: strategy
- pine_id: PUB;3287f5b6472d44e3bf95daf985753146
- version: 1.0

## Description

Hi all,

It's bear market so let's have a look at the misery index. 
Misery index = inflation(%) + unemployment (%)

It's only possible to use this chart on the monthly (as misery index is updated monthly), but just for fun I added a strategy to it. If misery index increases you short and you go long when MI decreases.
Enjoy

p.s. the band is pretty cool too

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © DynamicSignalLab
//@version=5
strategy("Misery index", overlay=false)
unemployment = request.security("FRED:UNRATE","M",close) 
inflation = request.security("ECONOMICS:USIRYY","M",close)
misery = unemployment+inflation
plot(misery)
longCondition = misery<misery[1]
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)

shortCondition = misery>misery[1]
if (shortCondition)
    strategy.entry("My Short Entry Id", strategy.short)
````
