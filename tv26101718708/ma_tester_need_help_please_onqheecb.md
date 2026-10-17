# MA Tester Need Help please ;)

- url: https://www.tradingview.com/script/ONqhEecB-MA-Tester-Need-Help-please/
- type: strategy
- pine_id: PUB;pjdKxawQp4VQIZGAi0ZSMpwObITrW6KF
- version: 1.0

## Description

Hello,

I'm new in scripts.

I build this one based on the MACD Strategy one but it look like mine don't plot buy and sell arrows on my chart, why?

thanks for help

## Source Code

````pine
//@version=3
strategy("MA Tester", overlay=true)
//set score to 0
score = input(0)
//Add avlue for MA
superfast = input(7)
fastLength = input(21)
slowlength = input(77)
trendLength = input(231)
// prepare delta for Short med and long
Buyshort = sma(close, superfast) - sma(close, fastLength)
Buymed = sma(close, superfast) - sma(close, slowlength)
Buylong = sma(close, fastLength) - sma(close, slowlength)
//just to see if good trend or bad
trendindicator = sma(close, slowlength) - sma(close, trendLength)

// increment score for decision
if (Buyshort > 0)
    score = score + 1
    
if (Buymed > 0)
    score = score + 1
    
if (Buylong > 0)
    score = score + 1

//print strategy buy and sell :)
if ((crossover(fastLength, slowlength)))
    strategy.entry("Buy", strategy.long, comment="Buy")
    
if ((crossunder(superfast, fastLength)))
    strategy.entry("Sell", strategy.short, comment="Sell")
````
