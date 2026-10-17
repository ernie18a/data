# Practice RSI, HA, Positions- DONTUSE

- url: https://www.tradingview.com/script/gUmGBC8F-Practice-RSI-HA-Positions-DONTUSE/
- type: strategy
- pine_id: PUB;9AqdJFqaSG2e3vDFZ7bS8MPOyDoVjk4m
- version: 2.0

## Description

Just practicing adding multiple indicators conditions and position size conditions to a strategy with signals.

## Source Code

````pine
//@version=3
strategy("DONTUSE", overlay = true)
LC1P = close > .0001
plotshape(LC1P, style = shape.xcross,color = red, size = size.large)
````
