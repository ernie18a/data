# HIGHER HIGH LOWER LOW STRATEGY

- url: https://www.tradingview.com/script/JWsBrWBu-HIGHER-HIGH-LOWER-LOW-STRATEGY/
- type: strategy
- pine_id: PUB;hYgCXMRdMhpXKWp16uHsUDYsnBcGy3wi
- version: 4.0

## Description

This is my favorite for Tradingview. 


Please use other indicators to find good entry and good exit. This is why this publication has so many indicators. A good indicator will find good results even on line chart. Feel free to try on "Heiken Ashi" but understand that "line" chart is much more realistic
Due to tradingview's crappy auto resize, the best way to view this script is to click on the share button and "Make it Mine".

Then you can see why my other indicators are "PRESENT"

Cheers!!!

## Source Code

````pine
//@version=4
strategy(title="HIGHER HIGH LOWER LOW STRATEGY", shorttitle="HH LL STRATEGY", overlay=true, calc_on_order_fills=true, initial_capital=100000, default_qty_type=strategy.percent_of_equity, currency="USD", default_qty_value=100)

////


//Higher High or Lower Low Entry Inputs
price = input(close)
LookBack = input(41)
Highest = highest(LookBack)
Lowest = lowest(LookBack)

long = price > Highest[1] 
short = price < Lowest[1]




//Safety Confirmation Inputs - Helps to thin out false breakouts or break downs
length = input(10)
High_Guard = highest(length)
Low_Guard = lowest(length)
length2 = input(1)

long1 = long == 1 and Highest[1] > High_Guard[length2]
short1 = short == 1 and Lowest[1] < Low_Guard[length2]


strategy.entry("Long", strategy.long, when=long1)
strategy.entry("Short", strategy.short, when=short1)
````
