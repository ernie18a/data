# HK Percentile Interpolation One

- url: https://www.tradingview.com/script/ecRye6YY-HK-Percentile-Interpolation-One/
- type: strategy
- pine_id: PUB;8dae40c9d05b48669a76c9967a8621d6
- version: 2.0

## Description

This script is designed to execute a trading strategy based on Heikin Ashi candlesticks, moving averages, and percentile levels.

Please note that you should keep your original chart in normal candlestick mode and not switch it to Heikin Ashi mode. The script itself calculates Heikin Ashi values from regular candlesticks. If your chart is already in Heikin Ashi mode, the script would be calculating Heikin Ashi values based on Heikin Ashi values, which would produce incorrect results.

The strategy begins trading from a start date that you can specify by modifying the `startDate` parameter. The format of the date is "YYYY MM DD". So, for example, to start the strategy from January 1, 2022, you would set `startDate = timestamp("2022 01 01")`.

The script uses Heikin Ashi candlesticks, which are plotted in the chart. This approach can be useful for spotting trends and reversals more easily than with regular candlestick charts. This is particularly useful when backtesting in TradingView's "Rewind" mode, as you can see how the Heikin Ashi candles behaved at each step of the strategy.

Buy and sell signals are generated based on two factors:

1. The crossing over or under of the Heikin Ashi close price and the 75th percentile price level.
2. The Heikin Ashi close price being above certain moving averages.

You have the flexibility to adjust several parameters in the script, including:

1. The stop loss and trailing stop percentages (`stopLossPercentage` and `trailStopPercentage`). These parameters allow the strategy to exit trades if the price moves against you by a certain percentage.

2. The lookback period (`lookback`) used to calculate percentile levels. This determines the range of past bars used in the percentile calculation.

3. The lengths of the two moving averages (`yellowLine_length` and `purplLine_length`). These determine how sensitive the moving averages are to recent price changes.

4. The minimum holding period (`holdPeriod`). This sets the minimum number of bars that a trade must be kept open before it can be closed.

Please adjust these parameters according to your trading preferences and risk tolerance. Happy trading!

## Source Code

````pine
//@version=5
strategy("Percentile Interpolation One", shorttitle = "PIO", overlay=false, default_qty_type = strategy.cash, default_qty_value = 5000, calc_on_order_fills = false, calc_on_every_tick = false)

// Input parameters
stopLossPercentage = input(3, title="Stop Loss (%)")
trailStopPercentage = input(1.5, title="Trailing Stop (%)")
lookback = input.int(20, title="Lookback Period", minval=1)
yellowLine_length = input.int(10, "Yellow", minval=1)
purplLine_length = input.int(20, "Purple", minval=1)
holdPeriod = input.int(200, title="Minimum Holding Period", minval=10)
startDate = timestamp("2020 04 04")

// Calculate Moving Averages
yellowLine = ta.ema(close, yellowLine_length)
purplLine = ta.ema(close, purplLine_length)

// Calculate 25th and 75th percentiles
p25 = ta.percentile_linear_interpolation(close, lookback, 25)
p75 = ta.percentile_linear_interpolation(close, lookback, 75)

// Generate buy/sell signals
longSignal = ta.crossover(close, p75) and close > yellowLine
sellSignal = ta.crossunder(close, yellowLine)
longSignal1 = ta.crossover(close, p75) and close > purplLine
sellSignal1 = ta.crossunder(close, purplLine)

// Set start time and trade conditions
if(time >= startDate)
    if (longSignal)
        strategy.entry("Long", strategy.long)
    if (sellSignal)
        strategy.close("Long")
    if (sellSignal1)
        strategy.entry("Short", strategy.short)
    if (longSignal1)
        strategy.close("Short")

// Plot 25th and 75th percentile levels
plot(p25, title="25th Percentile", color=color.green, linewidth=1, style=plot.style_circles)
plot(p75, title="75th Percentile", color=color.red, linewidth=1, style=plot.style_circles)

// Plot Moving Averages
plot(yellowLine, color = color.rgb(254, 242, 73, 2), linewidth = 2, style = plot.style_stepline)
plot(purplLine, color = color.rgb(255, 77, 234, 2), linewidth = 2, style = plot.style_stepline)
````
