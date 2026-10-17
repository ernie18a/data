# SimpleCrossOver_Bot

- url: https://www.tradingview.com/script/dfAHq3ex-SimpleCrossOver-Bot/
- type: strategy
- pine_id: PUB;Z6JrDUJHAdbbCJKNzm4dCHMLuKxKKWbI
- version: 1.0

## Description

This is a simple example of how you can compile your own strategy

This script contains the code for alerts and for backtesting.

In order to use the backtester, comment out the sections to be used for signals, and comment in the sections to be used on the back tester, and visa versa for using the script for alerts in order to automate your own bot.

## Source Code

````pine
//@author Jacques Grobler
//
//                  SIMPLE CROSS OVER BOT
//                  =====================
//
// This is a simple example of how to set up a strategy to go long or short
// If you make any modifications or have any suggestions, let me know
// When using this script, every section marked back testing should be 
// uncommented in order to use for back testing, same goes for using the script portion

///////////////////////////////////////////////////////////////////////////////////////
//// INTRO
//// -----
// BACKTESTING
strategy(title="SimpleCrossOver_Bot_V1_Backtester", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=100, pyramiding=0, commission_type=strategy.commission.percent, commission_value=0.1)

// SIGNALS
//study(title="SimpleCrossOver_Bot_V1_Signals", overlay = true)

///////////////////////////////////////////////////////////////////////////////////////
//// INPUTS
//// ------
// BACKTESTING
dateSart_Year = input(2018, title="Start Year", minval=2000)
dateSart_Month = input(1, title="Start Month", minval=1, maxval=12)
dateSart_Day = input(1, title="Start Day", minval=1, maxval=31)
dateEnd_Year = input(2019, title="End Year", minval=2000)
dateEnd_Month = input(1, title="End Month", minval=1, maxval=12)
dateEnd_Day = input(1, title="End Day", minval=1, maxval=31)

// BACKTESTING AND SIGNALS
fast_SMA_input = input(7, title="SMA Fast")
slow_SMA_input = input(25, title="SMA Slow")

///////////////////////////////////////////////////////////////////////////////////////
//// INDICATORS
//// ----------
fast_SMA = sma(close, fast_SMA_input)
slow_SMA = sma(close, slow_SMA_input)

///////////////////////////////////////////////////////////////////////////////////////
//// STRATEGY
//// --------
LONG = cross(fast_SMA, slow_SMA) and fast_SMA > slow_SMA
stratLONG() => crossover(fast_SMA, slow_SMA)
SHORT = cross(fast_SMA, slow_SMA) and fast_SMA < slow_SMA
stratSHORT() => crossunder(fast_SMA, slow_SMA)

///////////////////////////////////////////////////////////////////////////////////////
//// TRIGGERS
//// --------
// BACKTESTING
testPeriodStart = timestamp(dateSart_Year, dateSart_Month, dateSart_Day, 0, 0)
testPeriodStop = timestamp(dateEnd_Year, dateEnd_Month, dateEnd_Day, 0, 0)
timecondition = time >= testPeriodStart and time <= testPeriodStop

strategy.entry(id="LONG", long = true, when=timecondition and stratLONG())
strategy.entry(id="SHORT", long = false, when=timecondition and stratSHORT())

// SIGNALS
//alertcondition(LONG, title="LONG")
//alertcondition(SHORT, title="SHORT")

///////////////////////////////////////////////////////////////////////////////////////
//// PLOTS
//// -----
// BACKTESTING AND SIGNALS
plot(fast_SMA, color=green, linewidth=1)
plot(slow_SMA, color=yellow, linewidth=1)
plotshape(LONG, title="LONG", style=shape.triangleup, text="LONG", location=location.belowbar, size=size.small, color=green)
plotshape(SHORT, title="SHORT", style=shape.triangledown, text="SHORT", location=location.abovebar, size=size.small, color=red)
````
