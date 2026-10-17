# Bar Color Gr38612

- url: https://www.tradingview.com/script/uYVskHCx-Bar-Color-Gr38612/
- type: strategy
- pine_id: PUB;87dc90daa8db4834899b4e43136dfb91
- version: 1.0

## Description

I could not find a script to try this so I created one.

## Source Code

````pine
//@version=5
strategy("Bar Color", overlay=true, process_orders_on_close = true)
 
long_condition  = close>open
short_condition = close<open
 
plotshape(long_condition,  color = color.green)
plotshape(short_condition, color = color.red)
 
if (long_condition)
    strategy.entry("Long", strategy.long)
    strategy.close("Short")	
if (short_condition)
    strategy.entry("Short", strategy.short)
    strategy.close("Long")
````
