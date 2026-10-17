# Custom EMA Crossover Arrow Heads

- url: https://www.tradingview.com/script/XuQtZqbI-Custom-EMA-Crossover-Arrow-Heads/
- type: indicator
- pine_id: PUB;5f6004983abc414ab2d57e46dc5a93c4
- version: 1.0

## Description

The Custom EMA Crossover Arrow Heads indicator is a simple trend-following tool designed to highlight short-term momentum shifts using two Exponential Moving Averages. By default, it plots a 3 EMA and an 8 EMA directly on the price chart, while allowing users to customise both EMA lengths and colours.

When the faster EMA crosses above the slower EMA, the indicator displays a green bullish triangle above the candle, signalling potential upward momentum. When the slower EMA crosses above the faster EMA, a red bearish triangle appears above the candle, signalling potential downward momentum.

This indicator is useful for quickly identifying EMA crossover points, trend changes, and possible trade entry or exit areas. It also includes built-in alert conditions so traders can be notified when bullish or bearish EMA crosses occur.

## Source Code

````pine
//@version=6
indicator("Custom EMA Crossover Arrow Heads", overlay=true)

// === Inputs ===
fastEmaLength = input.int(3, title="Fast EMA Length", minval=1)
slowEmaLength = input.int(8, title="Slow EMA Length", minval=1)

fastEmaColor = input.color(color.green, title="Fast EMA Colour")
slowEmaColor = input.color(color.red, title="Slow EMA Colour")

bullArrowColor = input.color(color.green, title="Bullish Arrow Colour")
bearArrowColor = input.color(color.red, title="Bearish Arrow Colour")

// === EMA Calculations ===
fastEma = ta.ema(close, fastEmaLength)
slowEma = ta.ema(close, slowEmaLength)

// === Plot EMAs ===
plot(fastEma, title="Fast EMA", color=fastEmaColor, linewidth=2)
plot(slowEma, title="Slow EMA", color=slowEmaColor, linewidth=2)

// === Crossover Conditions ===
bullishCross = ta.crossover(fastEma, slowEma)
bearishCross = ta.crossover(slowEma, fastEma)

// === Plot Arrow Heads Only ===
plotshape(
     bullishCross,
     title="Bullish Cross Arrow Head",
     style=shape.triangleup,
     location=location.abovebar,
     color=bullArrowColor,
     size=size.small
)

plotshape(
     bearishCross,
     title="Bearish Cross Arrow Head",
     style=shape.triangledown,
     location=location.abovebar,
     color=bearArrowColor,
     size=size.small
)

// === Alerts ===
alertcondition(bullishCross, title="Bullish EMA Cross", message="Bullish EMA Cross: Fast EMA crossed above Slow EMA")
alertcondition(bearishCross, title="Bearish EMA Cross", message="Bearish EMA Cross: Slow EMA crossed above Fast EMA")
````
