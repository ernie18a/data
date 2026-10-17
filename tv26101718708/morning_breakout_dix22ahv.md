# Morning Breakout

- url: https://www.tradingview.com/script/DiX22aHV-Morning-Breakout/
- type: strategy
- pine_id: PUB;AxHlK54kCivNhZRqg6D19ogXougvEo5O
- version: 1.0

## Description

So, what's wrong with this piece of programming!?

## Source Code

````pine
//@version=3
strategy("Morning Breakout", overlay=true)

// Use on 1h chart
// Determine opening range (=1h bar 09:00-10:00)
// Buy stop at high, sell stop at low
// Both orders stay in effect until EOD

if hour(time) == 9
    strategy.entry("long", strategy.long, stop=high+1, qty=1)
    strategy.exit("exit_long", "long", profit = 40, loss = 25)
    
    strategy.entry("short", strategy.short, stop=low-1, qty=1)
    strategy.exit("exit_short", "short", profit = 40, loss = 25)
    
if not na(time(period, "2130-2200") )
    strategy.cancel_all()
    strategy.close_all()
````
