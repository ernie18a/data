# Pivot Points H/L by Himansu

- url: https://www.tradingview.com/script/2F0c1psm-Pivot-Points-H-L-by-Himansu/
- type: strategy
- pine_id: PUB;KdLN85xwQeZuLJBprHNYKze49b9jFMMs
- version: 1.0

## Description

Im not able to figure out why the strategy.exit only stays for one candle. I was trying to let the trade open till it hits Target or StopLoss.
Will really appreciate some help here.

## Source Code

````pine

strategy("Pivot Points H/L by Himansu", overlay=true, pyramiding = 0, default_qty_type = strategy.fixed, default_qty_value = 75, currency = currency.GBP)

len = input(5, minval=1, title="Length")
    //The length defines how many periods a high or low must hold to be a "relevant pivot"
profitpoints = 1000
stoplosspoints = 1000
trailstoploss = 100

// === INPUT BACKTEST RANGE ===
FromMonth = input(defval = 4, title = "From Month", minval = 1, maxval = 12)
FromDay   = input(defval = 1, title = "From Day", minval = 1, maxval = 31)
FromYear  = input(defval = 2018, title = "From Year", minval = 2000)
ToMonth   = input(defval = 1, title = "To Month", minval = 1, maxval = 12)
ToDay     = input(defval = 1, title = "To Day", minval = 1, maxval = 31)
ToYear    = input(defval = 9999, title = "To Year", minval = 2017)

// === FUNCTION EXAMPLE ===
start     = timestamp(FromYear, FromMonth, FromDay, 00, 00)  // backtest start window
finish    = timestamp(ToYear, ToMonth, ToDay, 23, 59)        // backtest finish window
window()  => time >= start and time <= finish ? true : false // create function "within window of time"


h = highest(len)
    //The highest high over the length
h1 = dev(h, len) ? na : h
    //h1 is a pivot of h if it holds for the full length
hpivot = fixnan(h1)
    //creates a series which is equal to the last pivot

l = lowest(len)
l1 = dev(l, len) ? na : l
lpivot = fixnan(l1)
    //repeated for lows

p1 = plot(hpivot, color=blue, linewidth=2, offset= -len+1)
p2 = plot(lpivot, color=purple, linewidth=2, offset= -len+1)
//plot(h1, color=black, style=circles, linewidth=4, offset= -len+1)
//plot(l1, color=black, style=circles, linewidth=4, offset= -len+1)
HLong = crossover(close,hpivot) ? true : false
LShort = crossunder(close,lpivot) ? true : false

enterlong() => HLong
strategy.entry(id = "Long",long = true, when = window () and enterlong())
strategy.exit("Exit Long", from_entry = "Long", profit = profitpoints,loss = stoplosspoints, trail_points = trailstoploss)
entershort() => LShort
strategy.entry(id = "Short",long = false, when = window () and entershort())
strategy.exit("Exit Short", from_entry = "Short", profit = profitpoints,loss = stoplosspoints, trail_points = trailstoploss)
````
