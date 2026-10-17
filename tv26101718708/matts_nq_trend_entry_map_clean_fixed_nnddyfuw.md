#  MATT,S NQ Trend Entry Map (Clean + Fixed)

- url: https://www.tradingview.com/script/NNDDYFUW-MATT-S-NQ-Trend-Entry-Map-Clean-Fixed/
- type: indicator
- pine_id: PUB;0fd75e81289241bea2dcd34a7100d366
- version: 2.0

## Description

easy and simple easy trend finding try it befor i charge for it

## Source Code

````pine
//@version=6
indicator("Face Signals v6", overlay=true)

// --- Basic signal logic (edit if you want) ---
fastLen = input.int(9,  "Fast EMA")
slowLen = input.int(21, "Slow EMA")

fast = ta.ema(close, fastLen)
slow = ta.ema(close, slowLen)

buySignal  = ta.crossover(fast, slow)
sellSignal = ta.crossunder(fast, slow)

// --- Plot faces ---
plotchar(
     buySignal,
     title     = "Buy Face",
     char      = "😃",
     location  = location.belowbar,
     color     = color.lime,
     size      = size.large
)

plotchar(
     sellSignal,
     title     = "Sell Face",
     char      = "😡",
     location  = location.abovebar,
     color     = color.red,
     size      = size.large
)
````
