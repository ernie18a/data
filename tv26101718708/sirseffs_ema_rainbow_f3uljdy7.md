# SirSeff's EMA Rainbow

- url: https://www.tradingview.com/script/F3uljDY7-SirSeff-s-EMA-Rainbow/
- type: strategy
- pine_id: PUB;9ef3d1def7e34cc9aa533d658f9f24fe
- version: 2.0

## Description

This strategy uses divergences between three exponential moving averages and their slope directions as well as crosses between the price and these moving averages to switch between a long or short position. The strategy is non-stop in the market and always either long or short.\

This trend trading strategy uses exponential moving averages of 10, 20, 50, 100, 150, 200 to gauge the price action cycle if it is on Stage 2 aka Mark up famously coined by Dr.Wykcoff.
It opens a position when the closing price crosses above the 10ema and all the exponential moving averages are stacked up together. Stacked-up Moving averages are used by Mark Minervini and Oliver Kell.
I close a position at an 8% trailing stop from the opened position which makes the succeeding buy orders as scaling up or averaging up from an established bullish trend.

All trading involves high risk; past performance is not necessarily indicative of future results. Hypothetical or simulated performance results have certain inherent limitations. Unlike an actual performance record, simulated results do not represent actual trading. Also, since the trades have not actually been executed, the results may have under-or over-compensated for the impact, if any, of certain market factors, such as lack of liquidity. Simulated trading programs in general are also subject to the fact that they are designed with the benefit of hindsight. No representation is being made that any account will or is likely to achieve profits or losses similar to those shown.

## Source Code

````pine
//@version=5
strategy('SirSeff\'s EMA Rainbow', overlay=true, pyramiding=999, initial_capital=10000, default_qty_type=strategy.percent_of_equity, default_qty_value=5, slippage=1)
// Testing Start dates
testStartYear = input(2000, 'Backtest Start Year')
testStartMonth = input(1, 'Backtest Start Month')
testStartDay = input(1, 'Backtest Start Day')
testPeriodStart = timestamp(testStartYear, testStartMonth, testStartDay, 0, 0)
//Stop date if you want to use a specific range of dates
testStopYear = input(2100, 'Backtest Stop Year')
testStopMonth = input(12, 'Backtest Stop Month')
testStopDay = input(30, 'Backtest Stop Day')
testPeriodStop = timestamp(testStopYear, testStopMonth, testStopDay, 0, 0)

testPeriod() =>
    time >= testPeriodStart and time <= testPeriodStop ? true : false
// Component Code Stop

//TSP
trailStop = input.float(title='Long Trailing Stop (%)', minval=0.0, step=0.1, defval=8) * 0.01

longStopPrice = 0.0
longStopPrice := if strategy.position_size > 0
    stopValue = close * (1 - trailStop)
    math.max(stopValue, longStopPrice[1])
else
    0

//PLOTS
plot(series=strategy.position_size > 0 ? longStopPrice : na, color=color.new(color.red, 0), style=plot.style_linebr, linewidth=1, title='Long Trail Stop', offset=1, title='Long Trail Stop')
plot(ta.ema(close, 10))
plot(ta.ema(close, 20))
plot(ta.ema(close, 50))
plot(ta.ema(close, 100))
plot(ta.ema(close, 150))
plot(ta.ema(close, 200))

//OPEN
longCondition =  ta.ema(close, 10) > ta.ema(close, 20) and ta.ema(close, 20) > ta.ema(close, 50) and ta.ema(close, 100) > ta.ema(close, 150) and ta.ema(close, 150) > ta.ema(close, 200)
if longCondition and ta.crossover(close,ta.ema(close,10)) and testPeriod()
    strategy.entry("Buy", strategy.long)
    
if longCondition and ta.crossunder(close,ta.ema(close,5)) and testPeriod()
    strategy.entry("Dips'", strategy.long)

//CLOSE @ TSL
if strategy.position_size > 0 and testPeriod()
    strategy.exit(id='TSP', stop=longStopPrice)
````
