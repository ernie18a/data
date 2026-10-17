# VWAP Push Strategy

- url: https://www.tradingview.com/script/MB6TmiPd/
- type: strategy
- pine_id: PUB;06e474121bbe422894d362e2e2be4c89
- version: 3.0

## Description

This strategy is unfortunately not finished yet.

A pretty simple strategy. If price broke through VWAP and had three consecutive candles following the breakthroughs trend, the high of the third candle will be drawn. If this happened after a crossover of the vwap and price breaks through the high of the third candle, strategy will go long. Short will be the same after crossing under the vwap. A long or short will be closed after crossing the vwap in the opposite direction, so the vwap is kind of a trailing stop.

Unfortunately, I could not manage to stop the script from entering multiple times into one drawn high or low. Of course, if a high was crossed the script should wait for a new formed high before entering a new long. [b]If someone would find a solution to this, it would be great, because I think it is a nice strategy[/b].

Should work great scalping 5min charts (when scripting, I used the SPX for reference).

## Source Code

````pine
//@version=5
strategy(title="VWAP Push", initial_capital = 100000, default_qty_type = strategy.percent_of_equity, default_qty_value = 100, pyramiding = 0, currency = 'USD', overlay=true)

//VWAP
vwap = ta.vwap(close)
plot(vwap, color=color.black, title="vwap")

//Last 5 Closes
closeBarPrevious5 = close[5]
closeBarPrevious4 = close[4]
closeBarPrevious3 = close[3]
closeBarPrevious2 = close[2]
closeBarPrevious1 = close[1]
closeBarCurrent = close

// Push up or down

is_push_up = (closeBarCurrent > closeBarPrevious1) and (closeBarPrevious1 > closeBarPrevious2) and (closeBarPrevious2 > closeBarPrevious3) and (closeBarPrevious4 < vwap) and (closeBarPrevious3 > vwap)  
is_push_down = (closeBarCurrent < closeBarPrevious1) and (closeBarPrevious1 < closeBarPrevious2) and (closeBarPrevious2 < closeBarPrevious3) and (closeBarPrevious4 > vwap) and (closeBarPrevious3 < vwap)  

var float hi = na
var float lo = na

hi := is_push_up ? high : hi
lo := is_push_down and (close < vwap) ? low : lo

plot(hi, "High", color.green, 1, plot.style_circles)
plot(lo, "Low", color.red, 1, plot.style_circles)

// Conditions

longCondition = ta.crossover(close,hi) and (close > vwap)
exitLong = ta.crossunder(close,vwap)

shortCondition = ta.crossunder(close,lo) and (close < vwap)
exitShort = ta.crossover(close,vwap)

// Entries Exits

if (longCondition)
    strategy.entry("Long", strategy.long)
if (exitLong)
    strategy.close("Long")
 
if (shortCondition)
    strategy.entry("Sell", strategy.short)
if (exitShort)
    strategy.close("Sell")
````
