# Golden Long Testing

- url: https://www.tradingview.com/script/YVPXOhMn-Golden-Long-Testing/
- type: strategy
- pine_id: PUB;u20hXdCJfZajIG7rXXrdTvpSCcEYTqT5
- version: 5.0

## Description

These scripts is based on the golden number theory and is for long entries. It has two parameters:

1. Number of pips of the body of candles to put an entry
2. Number of contracts to put on 3 orders executed at the same time

## Source Code

````pine
//@version=3
strategy("Golden Long Testing 1.1", "GLTesting 1.1", overlay=false, pyramiding=1, default_qty_type=strategy.fixed, default_qty_value=10000, currency="USD", initial_capital=5000)

//Inputs
name = input("Profit#", title="Profit#", type=string)
step = input(0.0, title="Step", type=float, minval=0.0)
candle_body = input(5, title="Body", type=integer, minval=1)
p1 = input(true, title="Profit 1", type=bool)
p2 = input(true, title="Profit 2", type=bool)
p3 = input(true, title="Profit 3", type=bool)

//Variables
entry = 0.0
golden = 1.618
stoploss = 0
profit1 = 0
profit2 = 0
profit3 = 0

//Entry evaluation value to compare with body
longs = round((close-open)/step)

if(longs==candle_body)
    strategy.cancel("long1", true)
    strategy.cancel("long2", true)
    strategy.cancel("long3", true)
    
    // Longitude of body
    body = longs*step
    entry := ((open+close)/2)+abs((close-open)*1.118)
    // Stop Loss & Profits in ticks
    stoploss := round(body*golden/syminfo.mintick)
    profit1 := round(body/syminfo.mintick)
    profit2 := round(body*2.612/syminfo.mintick)
    profit3 := round(body*5.232/syminfo.mintick)
    
if(entry>0.0)
    strategy.entry("long1", strategy.long, stop=entry, when=p1)
    strategy.entry("long2", strategy.long, stop=entry, when=p2)
    strategy.entry("long3", strategy.long, stop=entry, when=p3)

if(entry>0.0)
    strategy.exit("exit1", "long1", loss=stoploss, profit=profit1, when=p1)
    strategy.exit("exit2", "long2", loss=stoploss, profit=profit2, when=p2)
    strategy.exit("exit3", "long3", loss=stoploss, profit=profit3, when=p3)
    
winrate = strategy.wintrades*100/strategy.closedtrades

plot(winrate, title="Profit W/R", style=columns)
plot(0, title="Base", editable=false)
plot(100, title="Top", editable=false)
````
