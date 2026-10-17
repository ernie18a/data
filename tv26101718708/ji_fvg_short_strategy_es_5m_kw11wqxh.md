# JI FVG Short Strategy (ES 5m)

- url: https://www.tradingview.com/script/Kw11wQxH-JI-FVG-Short-Strategy-ES-5m/
- type: strategy
- pine_id: PUB;2318c66ee40b41a3bba60733cbb10b5d
- version: 1.0

## Description

here is the strategy for short only  : The market is ES the timeframe is the five minute chart. The entry condition is a bullish fair value gap must be formed and the third candle that complete the fair value gap must be red. Enter short only - no code is required The target is equal to the ATR Rounded down to the nearest .5 EG. ATR of 3.4 will Round down to 3 The stop loss is 1.5 times the target For example, if the target is 2 the stop loss is 3 If the target is 4 the stop loss is 6 If ATR is lower than 2 no trade is allowed to be taken.

## Source Code

````pine
//@version=5
strategy("FVG Short Strategy (ES 5m)",
     overlay=true,
     initial_capital=100000,
     default_qty_type=strategy.fixed,
     default_qty_value=4)

// === ATR ===
atr = ta.atr(14)

// === Round down to nearest 0.5 ===
roundDownToHalf(x) =>
    math.floor(x / 0.5) * 0.5

target = roundDownToHalf(atr)
stop   = target * 1.5

// === FVG condition (strict bullish gap) ===
// high of candle 1 < low of candle 3
fvg_bull = high[2] < low

// === 3rd candle must be red ===
third_red = close < open

// === Trade filter ===
valid_atr = atr >= 2

// === Entry condition ===
enter_short = fvg_bull and third_red and valid_atr

// === Only one trade at a time ===
no_position = strategy.position_size == 0

if (enter_short and no_position)
    strategy.entry("Short", strategy.short)

// === Exit logic ===
if (strategy.position_size < 0)
    entry_price = strategy.position_avg_price
    tp = entry_price - target
    sl = entry_price + stop

    strategy.exit("TP/SL", "Short", stop=sl, limit=tp)

// === Plotting for sanity ===
plotshape(enter_short, title="Short Signal", location=location.abovebar, color=color.red, style=shape.triangledown)
````
