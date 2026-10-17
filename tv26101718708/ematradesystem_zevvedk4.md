# EMA_Trade_System

- url: https://www.tradingview.com/script/zEVVedk4-EMA-Trade-System/
- type: strategy
- pine_id: PUB;iVbLLBKVveq7ZkpSfg2q6oPuj9MMa443
- version: 2.0

## Description

EMA Crossover buying and selling. Educational

## Source Code

````pine
strategy("EMA_Trade_System", overlay=true,default_qty_type = strategy.percent_of_equity, default_qty_value = 1000)
//Collect inputs parameters
fastEmaPeriod = input(7, minval=1, title="Fast EMA Periods")
slowEmaPeriod = input(20, minval=1, title="Slow EMA Periods")
showCrosses = input(true, title="Show EMA Crosses?")

fastEma = ema(close, fastEmaPeriod)
slowEma = ema(close, slowEmaPeriod)

// === INPUT BACKTEST RANGE ===
FromMonth = input(defval = 1, title = "From Month", minval = 1, maxval = 12)
FromDay   = input(defval = 4, title = "From Day", minval = 1, maxval = 31)
FromYear  = input(defval = 2010, title = "From Year", minval = 2000)
ToMonth   = input(defval = 1, title = "To Month", minval = 1, maxval = 12)
ToDay     = input(defval = 1, title = "To Day", minval = 1, maxval = 31)
ToYear    = input(defval = 9999, title = "To Year", minval = 2000)

// === FUNCTION EXAMPLE ===
start     = timestamp(FromYear, FromMonth, FromDay, 00, 00)  // backtest start window
finish    = timestamp(ToYear, ToMonth, ToDay, 23, 59)        // backtest finish window
window()  => time >= start and time <= finish ? true : false // create function "within window of time"

plot(fastEma, title = 'Fast EMA', linewidth=1, color=green)
plot(slowEma, title = 'Slow EMA', linewidth=1, color=red)

goldenCross = crossover(fastEma, slowEma)
deathCross = crossover(slowEma, fastEma)


plotarrow(showCrosses and goldenCross ? goldenCross : na, title="Golden Cross", colorup=green, maxheight=50, minheight=50, transp=0)
plotarrow(showCrosses and deathCross*-1 ? deathCross*-1 : na, title="Death Cross", colordown=red, maxheight=50, minheight=50, transp=0)

strategy.entry("long", strategy.long, when = window() and goldenCross)  
strategy.entry("short", strategy.short, when = window() and deathCross)
````
