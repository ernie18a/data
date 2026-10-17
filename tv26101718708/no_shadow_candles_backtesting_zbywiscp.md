# No Shadow Candles - Backtesting

- url: https://www.tradingview.com/script/ZbyWiSCp-No-Shadow-Candles-Backtesting/
- type: strategy
- pine_id: PUB;7zeOg097G721f6O5u4RB646nFQSzkNWk
- version: 1.0

## Description

Testing this strange strategy :)

scripted on request

## Source Code

````pine
//@version=3
strategy("No Shadow Candles", overlay=true)

//set inputs
bars_until_close_trade = input(1,"Bars Until Close", minval = 1)
backtest_option = input(true,"Backtest on Twice alert?", bool)

//set conditions
up = close > close[1] and low >= open and high <= close
down = close < close[1] and low >= close and high <= open

up2 = (close > close[1] and low >= open and high <= close) and (close[1] > close[2] and low[1] >= open[1] and high[1] <= close[1])
down2 = (close < close[1] and low >= close and high <= open) and (close[1] < close[2] and low[1] >= close[1] and high[1] <= open[1])

close_trade = barssince(up or down) == bars_until_close_trade
close_trade2 = barssince(up2 or down2) == bars_until_close_trade

//plot indicators
plotshape(up,"Up Marker", shape.triangleup, location.belowbar, color = olive, size = size.tiny, transp = 50)
plotshape(down,"Down Marker", shape.triangledown, location.abovebar, color = orange, size = size.tiny, transp = 50)
plotshape(up2,"Up Twice Marker", shape.triangleup, location.belowbar, color = white, size = size.small)
plotshape(down2,"Down Twice Marker", shape.triangledown, location.abovebar, color = white, size = size.small)
plotshape(close_trade,"Close Trigger", shape.circle, location.belowbar, color = fuchsia, size = size.tiny, transp = 50)
plotshape(close_trade2,"Close Trigger2 (After Twice Alert)", shape.circle, location.belowbar, color = red, size = size.small)

//Strategy Testing


// Component Code Start
// Example usage:
// if testPeriod()
//   strategy.entry("LE", strategy.long)
testStartYear = input(2017, "Backtest Start Year")
testStartMonth = input(01, "Backtest Start Month")
testStartDay = input(2, "Backtest Start Day")
testPeriodStart = timestamp(testStartYear,testStartMonth,testStartDay,0,0)

testStopYear = input(2019, "Backtest Stop Year")
testStopMonth = input(7, "Backtest Stop Month")
testStopDay = input(30, "Backtest Stop Day")
testPeriodStop = timestamp(testStopYear,testStopMonth,testStopDay,0,0)

// A switch to control background coloring of the test period
testPeriodBackground = input(title="Color Background?", type=bool, defval=true)
testPeriodBackgroundColor = testPeriodBackground and (time >= testPeriodStart) and (time <= testPeriodStop) ? #00FF00 : na
bgcolor(testPeriodBackgroundColor, transp=97)

testPeriod() =>
    time >= testPeriodStart and time <= testPeriodStop ? true : false
// Component Code Stop

//Entry and Close settings
if testPeriod() and backtest_option == true
    strategy.entry("up2", true, 1000, when = up2, limit = close)
    strategy.close("up2", when = close_trade)

if testPeriod() and backtest_option == false
    strategy.entry("up", true, 1000, when = up, limit = close)
    strategy.close("up", when = close_trade)
````
