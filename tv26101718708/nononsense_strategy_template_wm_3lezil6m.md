# No-Nonsense Strategy Template [WM]

- url: https://www.tradingview.com/script/3lEzil6m-No-Nonsense-Strategy-Template-WM/
- type: strategy
- pine_id: PUB;QcSdA0ky87dZlZPYlOwBkRvdvQI5CiTq
- version: 1.0

## Description

there you go

## Source Code

````pine
//@version=3
strategy(title="No-Nonsense Strategy Template [WM]", overlay = true)

price = close

//
// ATR stuff
//

atrLength = input(14, "ATR Length")
slMultiplier = input(1.5, "SL")
tpMultiplier = input(1, "TP1")

atr = atr(atrLength)

//
// Strategy under test. MA crossover
// 

fastInput = input(21)
slowInput = input(55)

fast = ema(price, fastInput)
slow = ema(price, slowInput)

plot(fast, color = red)
plot(slow, color = blue)

goLong = crossover(fast, slow)
goShort = crossunder(fast, slow)

if (goLong)
    sl = price - atr * slMultiplier
    tp = price + atr * tpMultiplier
    strategy.entry("Long", strategy.long)
    strategy.exit("Long Exit", "Long", stop = sl, limit = tp)
    
if (goShort)
    sl = price + atr * slMultiplier
    tp = price - atr * tpMultiplier
    strategy.entry("Short", strategy.short)	 
    strategy.exit("Short Exit", "Short", stop = sl, limit = tp)
````
