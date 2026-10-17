# proof quant model v1

- url: https://www.tradingview.com/script/gXB2cndL-proof-quant-model-v1/
- type: strategy
- pine_id: PUB;2d0ca26ebaa1439e8b5524b1ecaf2280
- version: 1.0

## Description

team, this is the model for our class. It is public but yeah its not like there will be specific ip or stuff like that. Get to work

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ribidiskizz

//@version=6
strategy("Test Strategy – MA Crossover", overlay=true)

// === INPUTS ===
fastLength = input.int(10, title="Fast MA Length")
slowLength = input.int(30, title="Slow MA Length")

// === CALCULATIONS ===
fastMA = ta.sma(close, fastLength)
slowMA = ta.sma(close, slowLength)

// === PLOTS ===
plot(fastMA, title="Fast MA", linewidth=2)
plot(slowMA, title="Slow MA", linewidth=2)

// === TRADING LOGIC ===
if ta.crossover(fastMA, slowMA)
    strategy.entry("Long", strategy.long)

if ta.crossunder(fastMA, slowMA)
    strategy.close("Long")
````
