# Double Supertrend

- url: https://www.tradingview.com/script/RyY2VKLD-Double-Supertrend/
- type: strategy
- pine_id: PUB;c9424ba09f7e4a5bab9bf2f86e9ad0c8
- version: 2.0

## Description

This strategy is based on a custom indicator that was created based on the Supertrend indicator. At its core, there are always 2 super trend indicators with different factors to reduce market noise (false signals). 

The strategy/indicator has some parameters to improve the signals and filters. 

[b]TECHNICAL ANALYSIS[/b]

☑ Show Indicators
This option will enable/disable the Supertrend indicators on the chart.

☑ Length
The length will be used on the Supertrend Indicator to calculate its values.

☑ Dev Fast
The fast deviation or factor from one of the super trend indicators. This will be the leading indicator for entry signals, as well as for the exit signals.

☑ Dev Slow
The slow deviation or factor from one of the super trend indicators. This will be the confirmation indicator for entry and exit signals.

☑ Exit Type
It's possible to select from 4 options for the exit signals. Exit signals always take profit target.
[i]☑ ⥹ Reversals[/i]
This option will make the strategy/indicator calculate the exit signals based on the difference between the given period's highest and lowest candle value (see Period on this list). It's displayed on the chart with the cross. As it's possible to verify in the image below, there are multiple exit spots for every entry.
[image]https://www.tradingview.com/x/6NA0WKng/[/image]
[i]☑ ⥹ ATR[/i]
Using ATR as a base indicator for exit signals will make the strategy/indicator place limit/stop orders. Candle High + ATR for longs, Candle Low - ATR for shorts. The strategy will show the ATR level for take profit and stick with it until the next signal. This way, the take profit value remains based on the candle of the entry signal.
[image]https://www.tradingview.com/x/1JFWI3wY/[/image]
[i]☑ ⥹ Fast Supertrend[/i][i][/i]
With this option selected, the exit signals will be based on the Fast Supertsignal value, mirrored to make a profit.
[image]https://www.tradingview.com/x/phipuWYb/[/image]
[i]☑ ⥹ Slow Supertrend[/i]
With this option selected, the exit signals will be based on the Slow Supertsignal value, which is mirrored to take profit.
[image]https://www.tradingview.com/x/vgYMY8OE/[/image]

☑ Period
This will represent the number of candles used on the exit signals when Reversals is selected as Exit Type. It's also used to calculate the gradient used on the Fills and Supertrend signals.

☑ Multiplier
It's used on the take profit when the ATR option is selected on the Exit Type.

[b]STRATEGY[/b]

☑ Use The Strategy
This will enable/disable the strategy to show the trades calculations.

☑ Show Use Long/Short Entries
Option to make the strategy show/use Long or Short signals. Available only if Use The Strategy is enabled

☑ Show Use Exit Long/Short
Option to make the strategy show/use Exit Long or Short signals (valid when Reversals option is selected on the Exit Type). Available only if Use The Strategy is enabled

☑ Show Use Add Long/Short
Option to make the strategy show/use Add Long or Short signals. With this option enabled, the strategy will place multiple trades in the same direction, almost the same concept as a pyramiding parameter. It's based on the Fast Supersignal when the candle fails to cross and reverses. Available only if Use The Strategy is enabled

☑ Trades Date Start/End
The date range that the strategy will check the market data and make the trades

[b]HOW TO USE[/b]
It's very straightforward. A long signal will appear as a green arrow with a text Long below it. A short signal will appear as a red arrow with a text Short above it. It's ideal to wait for the candle to finish to validate the signal.
The exit signals are optional but give a good idea of the configuration used when backtesting. Each market and timeframe will have its own configuration for the best results. On average, sticking to ATR as an exit signal will have less risk than the other options.

☑ Entry Signals
Follow the arrows with Long/Short texts on them. Wait for the signal candle to close to validate the entry.

☑ Exit Signals
Use them to close your position or to trail stop your orders and maximize profits. Select the exit type suitable for each timeframe and market

☑ Add Entries
It's possible to increase the position following the add margin/contracts based on the Add signals. Not mandatory, but may work as reentries or late entries using the same signal.

☑ What about Stop Loss?
The stop-loss levels were not included as a separated signal because it's already in the chart. There are some possible ideas for the stop loss:
☑⥹ Candle High/Low (2nd recommend option)
When it's a Long signal from the entry signal candle, the stop loss can be the Low value of the same candle. Very tight stop loss in some cases, depending on the candle range
☑⥹ Local Top/Bottom
Selecting the local top/bottom as stop loss will give the strategy more room for false breakouts or reversals, keeping the trade open and minimizing noises. Increases the risk
☑⥹ Fast Supertrend (1st recommend option)
The fast supertrend can be used as stop-loss as well. making it a moving level and working close to trail stop management
☑⥹ Fixed Percentage
It's possible to use a fixed risk percentage for the trades, making the risk easier to control and project. Since the market volatility is not fixed, this may affect the accuracy of the trades
☑⥹ Based on the ATR (3rd recommend option)
When the exit type option ATR is selected, it will display the take profit level for that entry. Just mirror that value and put it as stop-loss, or multiply that amount by 1.5 to have more room for market noise.

[b]EXAMPLE CONFIGURATIONS[/b]
Here are some configuration ideas for some markets (all of them are from crypto, especially futures markets)
BTCUSDT 15min - Default configuration
BTCUSDT 1h - Length 10 | Dev Fast 3 | Dev Slow 4 | Exit Type ATR | Period 50 | Multiplier 1
BTCUSDT 4h - Length 10 | Dev Fast 2 | Dev Slow 4 | Exit Type ATR | Period 50 | Multiplier 1
ETHUSDT 15min - Length 20 | Dev Fast 1 | Dev Slow 3 | Exit Type Fast Supertrend | Period 50 | Multiplier 1
IOTAUSDT 15min - Length 10 | Dev Fast 1 | Dev Slow 2 | Exit Type Slow Supertrend | Period 50 | Multiplier 1
OMGUSDT 15min - Length 10 | Dev Fast 1 | Dev Slow 4 | Exit Type Slow Supertrend | Period 50 | Multiplier 1
VETUSDT 15min - Length 10 | Dev Fast 3 | Dev Slow 4 | Exit Type Slow Supertrend | Period 50 | Multiplier 1

[b]HOW TO FIND OTHER CONFIGURATIONS[/b]
Here are some steps to find suitable configurations 
[list]
[*] select a market and time frame
[*] enable the Use This Strategy option on the strategy
[*] open the strategy tester panel and select the performance summary
[*] open the strategy configuration and go to properties
[*] change the balance to the same price of the symbol (example: BTCUSDT 60.000, use 60.000 as balance)
[*] go back to the inputs tab and keep changing the parameters until you see the net profit be positive and bigger than the absolute value of the drawdown
[*] in case you can't find a suitable configuration, try other timeframes
[/list]

Since the tester reflects what happened in the past candles, it's not guaranteed to give the same results. However, this indicator/Strategy can be used with other indicators as a leading signal or confirmation signal.

## Source Code

````pine
//@version=5
strategy("Double Supertrend", overlay=true, currency="USD", default_qty_value=1, process_orders_on_close=true, pyramiding=10)
//*
//* Inputs
//*
showIndicators = input.bool(true, "Show Indicators", group="Technical Analysis")
atrPeriod = input(14, "Length", group="Technical Analysis", inline="ATR")
factor1 = input.float(1.0, "Dev Fast", step = 0.01, group="Technical Analysis", inline="ATR")
factor2 = input.float(4.0, "Dev Slow", step = 0.01, group="Technical Analysis", inline="ATR")
exitType = input.string("ATR", "Exit Type", ["Reversals", "ATR", "Fast Supertrend", "Slow Supertrend"], group="Technical Analysis", inline="Exit Type")
exitLength = input.int(60, "Period", group="Technical Analysis", inline="Exit Type")
exitMultiplier = input.int(2, "Multiplier", group="Technical Analysis", inline="Exit Type")
useStrategy = input.bool(true, "Use The Strategy", group="Strategy")
showLongs = input.bool(true, "Show/Use Long Entries", group="Strategy", inline="Entries")
showShorts = input.bool(true, "Show/Use Short Entries", group="Strategy", inline="Entries")
entryAlerts = input.bool(true, "Enable Entry Alerts", group="Strategy", inline="Entries")
showExitLongs = input.bool(true, "Show/Use Exit Longs", group="Strategy", inline="Exits")
showExitShorts = input.bool(true, "Show/Use Exit Shorts", group="Strategy", inline="Exits")
exitAlerts = input.bool(true, "Enable Exit Alerts", group="Strategy", inline="Exits")
showAddLongs = input.bool(true, "Show/Use Add Longs", group="Strategy", inline="Adds")
showAddShorts = input.bool(true, "Show/Use Add Shorts", group="Strategy", inline="Adds")
addAlerts = input.bool(true, "Enable Add Alerts", group="Strategy", inline="Adds")
dateStart = input.time(timestamp("2021-12-01T10:00:00-03:00"), "Trades Date Start", group="Strategy")
dateEnd = input.time(timestamp("2022-02-01T10:00:00-03:00"), "Trades Date End", group="Strategy")

//*
//* Variables
//*
var bool buy = true
var bool sell = true
isInsideDateRange = time > dateStart and time < dateEnd
bodyMiddleValue = (open + close) / 2
rangeMiddleValue = (high + low) / 2

//*
//* TA
//*
[supertrend1, direction1] = ta.supertrend(factor1, atrPeriod)
[supertrend2, direction2] = ta.supertrend(factor2, atrPeriod)
diffFromTop = ta.highest(exitLength) - (ta.highest(exitLength) - ta.lowest(exitLength/4)) / 2
diffFromBottom = ta.lowest(exitLength) + (ta.highest(exitLength/4) - ta.lowest(exitLength)) / 2
condLong = direction1 < 0 and direction2 < 0 and (direction1[1] > 0 or direction2[1] > 0)
condShort = direction1 > 0 and direction2 > 0 and (direction1[1] < 0 or direction2[1] < 0)
atr = ta.atr(atrPeriod)

//*
//* Functions
//*
getATRPrice(type) => close + atr * exitMultiplier * (type == "long" ? 1 : -1)

//*
//* Take Profit Calculations
//*
var longTakeProfit = getATRPrice("long")
var shortTakeProfit = getATRPrice("Short")
if condLong and buy
    longTakeProfit := getATRPrice("long")
if condShort and sell
    shortTakeProfit := getATRPrice("Short")

//*
//* Color Gradient
//*
colorSignal1 = color.from_gradient(ohlc4, ta.lowest(exitLength/4), ta.highest(exitLength), color.green, color.aqua)
colorSignal2 = color.from_gradient(ohlc4, ta.lowest(exitLength), ta.highest(exitLength/4), color.red, color.orange)

//*
//* Entry Signals
//*
plotshape(condLong and buy, "Trend Up", shape.triangleup, location.belowbar, color.lime, 0, "Long", color.lime, false, size.small)
plotshape(condShort and sell, "Trend Down", shape.triangledown, location.abovebar, color.red, 0, "Short", color.red, false, size.small)
if useStrategy and isInsideDateRange
    if condLong and buy and showLongs
        strategy.entry("Long", strategy.long)
        if entryAlerts
            alert("Entry Long", alert.freq_once_per_bar)
    if condShort and sell and showShorts
        strategy.entry("Short", strategy.short)
        if entryAlerts
            alert("Entry Short", alert.freq_once_per_bar)

//*
//* Exit Signals
//*
plotshape(ohlc4 <= diffFromTop and ohlc4[1] > diffFromTop[1] and sell and not condShort and showExitLongs, "Exit Trend Up", shape.xcross, location.abovebar, color.aqua, 0, "Exit", color.aqua, false, size.tiny)
plotshape(ohlc4 >= diffFromBottom and ohlc4[1] < diffFromBottom[1] and buy and not condLong and showExitShorts, "Exit Trend Down", shape.xcross, location.belowbar, color.orange, 0, "Exit", color.orange, false, size.tiny)
if sell and not condShort and showExitLongs and isInsideDateRange
    if ohlc4 <= diffFromTop and ohlc4[1] > diffFromTop[1] and exitType == "Reversals"
        strategy.exit("Exit Long", "Long", stop=low, qty_percent=100)
        strategy.exit("Exit Add Long", "Add Long", stop=low, qty_percent=100)
        if exitAlerts
            alert("Exit Long", alert.freq_once_per_bar)
    if condLong[1] and exitType == "ATR"
        strategy.exit("Exit Long", "Long", limit=longTakeProfit, qty_percent=100)
        strategy.exit("Exit Add Long", "Add Long", limit=longTakeProfit, qty_percent=100)
        if exitAlerts
            alert("Exit Long", alert.freq_once_per_bar)
    if condLong[1] and (exitType == "Fast Supertrend" or exitType == "Slow Supertrend")
        strategy.exit("Exit Long", "Long", limit=rangeMiddleValue + (rangeMiddleValue - (exitType == "Fast Supertrend" ? supertrend1 : supertrend2)), qty_percent=100)
        strategy.exit("Exit Add Long", "Add Long", limit=rangeMiddleValue + (rangeMiddleValue - (exitType == "Fast Supertrend" ? supertrend1 : supertrend2)), qty_percent=100)
        if exitAlerts
            alert("Exit Long", alert.freq_once_per_bar)
if buy and not condLong and showExitShorts and isInsideDateRange
    if ohlc4 >= diffFromBottom and ohlc4[1] < diffFromBottom[1] and exitType == "Reversals"
        strategy.exit("Exit Short", "Short", stop=high, qty_percent=100)
        strategy.exit("Exit Add Short", "Add Short", stop=high, qty_percent=100)
        if exitAlerts
            alert("Exit Short", alert.freq_once_per_bar)
    if condShort[1] and exitType == "ATR"
        strategy.exit("Exit Short", "Short", limit=shortTakeProfit, qty_percent=100)
        strategy.exit("Exit Add Short", "Add Short", limit=shortTakeProfit, qty_percent=100)
        if exitAlerts
            alert("Exit Short", alert.freq_once_per_bar)
    if condShort[1] and (exitType == "Fast Supertrend" or exitType == "Slow Supertrend")
        strategy.exit("Exit Short", "Short", limit=rangeMiddleValue - ((exitType == "Fast Supertrend" ? supertrend1 : supertrend2) - rangeMiddleValue), qty_percent=100)
        strategy.exit("Exit Add Short", "Add Short", limit=rangeMiddleValue - ((exitType == "Fast Supertrend" ? supertrend1 : supertrend2) - rangeMiddleValue), qty_percent=100)
        if exitAlerts
            alert("Exit Short", alert.freq_once_per_bar)
            
//*
//* Plots
//*
bodyMiddle = plot(bodyMiddleValue, display=display.none)
upTrend1 = plot(direction1 < 0 ? supertrend1 : na, "Up Trend", color = showIndicators ? colorSignal1 : na, style=plot.style_linebr)
plot(direction1 < 0 and direction2 < 0 and longTakeProfit > high ? longTakeProfit : na, "Take Profit Up Trend", color = showIndicators ? color.olive : na, style=plot.style_linebr, linewidth=3)
plot(rangeMiddleValue + (rangeMiddleValue - (exitType == "Fast Supertrend" ? supertrend1 : supertrend2)), "Supertrend Long Take Profit", (exitType == "Fast Supertrend" or exitType == "Slow Supertrend") and direction1 < 0 and direction2 < 0 ? color.new(color.olive, 30) : na, style=plot.style_linebr)
downTrend1 = plot(direction1 < 0 ? na : supertrend1, "Down Trend", color = showIndicators ? colorSignal2 : na, style=plot.style_linebr)
upTrend2 = plot(direction2 < 0 ? supertrend2 : na, "Up Trend", color = showIndicators ? colorSignal1 : na, style=plot.style_linebr)
plot(direction1 >= 0 and direction2 >= 0 and shortTakeProfit < low ? shortTakeProfit : na, "Take Profit Down Trend", color = showIndicators ? color.maroon : na, style=plot.style_linebr, linewidth=3)
plot(rangeMiddleValue - ((exitType == "Fast Supertrend" ? supertrend1 : supertrend2) - rangeMiddleValue), "Supertrend Short Take Profit", (exitType == "Fast Supertrend" or exitType == "Slow Supertrend") and direction1 >= 0 and direction2 >= 0 ? color.new(color.maroon, 30) : na, style=plot.style_linebr)
downTrend2 = plot(direction2 < 0 ? na : supertrend2, "Down Trend", color = showIndicators ? colorSignal2 : na, style=plot.style_linebr)

//*
//* Fills
//*
fill(bodyMiddle, upTrend1, showIndicators ? color.new(colorSignal1, 95) : na, fillgaps=false)
fill(bodyMiddle, downTrend1, showIndicators ? color.new(colorSignal2, 90) : na, fillgaps=false)
fill(bodyMiddle, upTrend2, showIndicators ? color.new(colorSignal1, 95) : na, fillgaps=false)
fill(bodyMiddle, downTrend2, showIndicators ? color.new(colorSignal2, 90) : na, fillgaps=false)

//*
//* Reentry
//*
plotshape(low < supertrend1 and close > supertrend1 and sell and not (ohlc4 <= diffFromTop and ohlc4[1] > diffFromTop[1]) and showAddLongs, "Add Long", shape.cross, location.belowbar, color.new(color.green, 20), 0, "L", color.new(color.green, 20), false, size.tiny)
plotshape(high > supertrend1 and close < supertrend1 and buy and not (ohlc4 >= diffFromBottom and ohlc4[1] < diffFromBottom[1]) and showAddShorts, "Add Short", shape.cross, location.abovebar, color.new(color.red, 20), 0, "S", color.new(color.red, 20), false, size.tiny)
if useStrategy and isInsideDateRange
    if low < supertrend1 and close > supertrend1 and sell and not (ohlc4 <= diffFromTop and ohlc4[1] > diffFromTop[1]) and showAddLongs
        strategy.entry("Add Long", strategy.long)
        if addAlerts
            alert("Add Long", alert.freq_once_per_bar)
            
    if high > supertrend1 and close < supertrend1 and buy and not (ohlc4 >= diffFromBottom and ohlc4[1] < diffFromBottom[1]) and showAddShorts
        strategy.entry("Add Short", strategy.short)
        if addAlerts
            alert("Add Short", alert.freq_once_per_bar)

//*
//* One Signal
//*
if condLong and buy
    buy := false
    sell := true
    strategy.cancel("Exit Short")
    strategy.cancel("Exit Add Short")
if condShort and sell
    sell := false
    buy := true
    strategy.cancel("Exit Long")
    strategy.cancel("Exit Add Long")
````
