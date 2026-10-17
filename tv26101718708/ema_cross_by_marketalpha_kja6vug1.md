# EMA Cross by MarketAlpha

- url: https://www.tradingview.com/script/kja6Vug1-EMA-Cross-by-MarketAlpha/
- type: strategy
- pine_id: PUB;n6KyMUadIMbmbWxHGVnuDofWEWJ9bxCI
- version: 1.0

## Description

Signals are generated when EMA(FastLength) and EMA(SlowLength) cross each other.
Below are the additional user parameters: 
1. User defined backtesting period
2. User defined Target and StopLoss percentage points

## Source Code

````pine
strategy("EMA Cross by MarketAlpha", overlay=true)
EMAfastLength = input(defval = 9, minval = 2)
EMAslowLength = input(defval = 26, minval = 2)
Targetpercentage = input(defval = 0.15, title = "Profit Target in percentage", minval = 0.05)
StopLosspercentage = input(defval = 0.20, title = "Stop Loss in percentage", minval = 0.05)
profitpoints = close*Targetpercentage
stoplosspoints = close*StopLosspercentage
price = close

FromMonth = input(defval = 1, title = "From Month", minval = 1, maxval = 12)
FromDay   = input(defval = 1, title = "From Day", minval = 1, maxval = 31)
FromYear  = input(defval = 2018, title = "From Year", minval = 2000)
ToMonth   = input(defval = 1, title = "To Month", minval = 1, maxval = 12)
ToDay     = input(defval = 1, title = "To Day", minval = 1, maxval = 31)
ToYear    = input(defval = 9999, title = "To Year", minval = 2017)

start     = timestamp(FromYear, FromMonth, FromDay, 00, 00)  // backtest start window
finish    = timestamp(ToYear, ToMonth, ToDay, 23, 59)        // backtest finish window
window()  => time >= start and time <= finish ? true : false // create function "within window of time"

emafast = ema(price, EMAfastLength)
emaslow = sma(price, EMAslowLength)
plot(emafast,color=green)
plot(emaslow,color=red)

enterLong() => crossover(emafast, emaslow)
strategy.entry(id = "MarketAlpha Long", long = true, when = window() and enterLong())
strategy.exit("Exit Long", from_entry = "MarketAlpha Long", profit = profitpoints,loss = stoplosspoints)

enterShort() => crossunder(emafast, emaslow)
strategy.entry(id = "MarketAlpha Short", long = false, when = window() and enterShort())
strategy.exit("Exit Short", from_entry = "MarketAlpha Short", profit = profitpoints,loss = stoplosspoints)
````
