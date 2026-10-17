# Moving Average Cross Strategy

- url: https://www.tradingview.com/script/oI8loEZ8-Moving-Average-Cross-Strategy/
- type: strategy
- pine_id: PUB;7THFcSzrfhR5dDbDTYAsFYh7wrVmArTf
- version: 3.0

## Description

Simply choose your moving averages and backtest shorting and longing the crossing of these MA's. Meant for dialing in MA crosses as part of a trading setup and not reason enough to take the trade. First script, work in progress.

## Source Code

````pine
//@version=3
strategy(title="Moving Average Cross w/Date Range", overlay=true, initial_capital=10000, currency='USD')

// Credit goes to this developer for the "Date Range Code"
// https://www.tradingview.com/script/62hUcP6O-How-To-Set-Backtest-Date-Range/


// === GENERAL INPUTS ===
// short ma
maFastSource   = input(defval = close, title = "Fast MA Source")
maFastLength   = input(defval = 9, title = "Fast MA Period", minval = 1)
// long ma
maSlowSource   = input(defval = close, title = "Slow MA Source")
maSlowLength   = input(defval = 18, title = "Slow MA Period", minval = 1)


// === SERIES SETUP ===
/// a couple of ma's..
maFast = ema(maFastSource, maFastLength)
maSlow = ema(maSlowSource, maSlowLength)



// === PLOTTING ===
fast = plot(maFast, title = "Fast MA", color = red, linewidth = 2, style = line, transp = 30)
slow = plot(maSlow, title = "Slow MA", color = green, linewidth = 2, style = line, transp = 30)

// === INPUT BACKTEST RANGE ===
FromMonth = input(defval = 9, title = "From Month", minval = 1, maxval = 12)
FromDay   = input(defval = 1, title = "From Day", minval = 1, maxval = 31)
FromYear  = input(defval = 2018, title = "From Year", minval = 2017)
ToMonth   = input(defval = 1, title = "To Month", minval = 1, maxval = 12)
ToDay     = input(defval = 1, title = "To Day", minval = 1, maxval = 31)
ToYear    = input(defval = 9999, title = "To Year", minval = 2017)

// === FUNCTION EXAMPLE ===
start     = timestamp(FromYear, FromMonth, FromDay, 00, 00)  // backtest start window
finish    = timestamp(ToYear, ToMonth, ToDay, 23, 59)        // backtest finish window
window()  => time >= start and time <= finish ? true : false // create function "within window of time"


// === LOGIC ===
enterLong = crossover(maFast, maSlow)
exitLong = crossover(maSlow, maFast)



// Entry //
strategy.entry(id="Long Entry", long=true, when=window() and enterLong)
strategy.entry(id="Short Entry", long=false, when=window() and exitLong)


// === FILL ====

fill(fast, slow, color = maFast > maSlow ? green : red)
````
