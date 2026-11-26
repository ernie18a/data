# Looks_Cool_BUT_MEH_V1

- url: https://www.tradingview.com/script/Z1kuOKGw-Looks-Cool-BUT-MEH-V1/
- type: strategy
- pine_id: PUB;7NadCDaUFNw9XrVVa5zraL7H7uXn7iqq
- version: 1.0

## Description

Simple

Multitimefram anaylsis, and emas

## Source Code

````pine
//@version=4
strategy("Looks_Cool_BUT_MEH_V1", overlay=true)


From_Year  = input(defval = 2019, title = "From Year")
From_Month = input(defval = 8, title = "From Month", minval = 1, maxval = 12)
From_Day   = input(defval = 1, title = "From Day", minval = 1, maxval = 31)
To_Year    = input(defval = 2019, title = "To Year")
To_Month   = input(defval = 10, title = "To Month", minval = 1, maxval = 12)
To_Day     = input(defval = 1, title = "To Day", minval = 1, maxval = 31)
Start  = timestamp(From_Year, From_Month, From_Day, 00, 00)  // backtest start window
Finish = timestamp(To_Year, To_Month, To_Day, 23, 59)        // backtest finish window
Window = time >= Start and time <= Finish


One = security(syminfo.ticker,'60',close)
Four = security(syminfo.ticker,'240',close)

longCondition = ema(close,14) > ema(One,14) and ema(One,14) > ema(Four,5) and Window
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)
    strategy.exit("My Long Entry Id", profit=1000,loss=100,trail_points=50)

shortCondition = ema(close,14) > ema(One,14) and ema(One,14) < ema(Four,5) and Window
if (shortCondition)
    strategy.entry("My Short Entry Id", strategy.short)
    strategy.exit("My Short Entry Id", profit=1000,loss=100,trail_points=50)
````
