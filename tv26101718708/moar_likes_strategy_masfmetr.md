# Moar Likes Strategy

- url: https://www.tradingview.com/script/MaSfmETr-moar-likes-strategy/
- type: strategy
- pine_id: PUB;1980
- version: -1.0

## Description

Logic from top ANN strategy. Base is future day close price.
//only for fun

## Source Code

````pine
//@version=2
//like ANN strategy without tan
strategy("Not Strategy", overlay=true)

x0=security(tickerid, 'D', close[1])
x1=security(tickerid, 'D', close)

z=x0 < x1

bgcolor(z ? green : red, transp=90)

if (z)
    strategy.entry("Long", strategy.long)

if (not(z))
    strategy.entry("Short", strategy.short)
````
