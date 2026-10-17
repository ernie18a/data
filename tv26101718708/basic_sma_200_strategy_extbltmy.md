# Basic SMA 200 Strategy

- url: https://www.tradingview.com/script/EXtBltMY-Basic-SMA-200-Strategy/
- type: strategy
- pine_id: PUB;h3tsFsUveBKngOfKEGhA4r4CWKnhmLeO
- version: 1.0

## Description

The SMA 200 basic strategy will be more than familiar to most traders. 
This strategy is to stay with the programming language so to say the "Hello World" of trading. 

The SMA 200 basic strategy is also one of the simplest strategies in trading. All that is required is the price and a 200 period moving average. Usually the strategy is used in the daily chart. 

The rules are as follows: 

Entry: A position is opened when the price crosses the moving average 200 from the bottom to the top. 

Exit: The position is closed when the price crosses the moving average from top to bottom.

This is a trend following system and was originally used for trading stocks. 

In my opinion, trading with the strategy is recommended to every beginner. There are strategies with better performance, but they are much more complicated to implement. And that's where the big advantage of the strategy can be seen. 
Beginners are more than overwhelmed at the beginning of their trading career. Often beginners trade in the 5 min chart with 6 different indicators some signals that they have seen in a Youtube video. 
Comparable to a beginner driver who immediately gets into a Porsche as his first car. 

Beginners should follow simple rules and avoid intraday charts. Above all, you should do the actual work of a trader.A trader does not just press the mouse twenty times a day and then has easily earned 2000 $.  A trader tests systems down to the smallest detail, optimizes and tests again, until he has found an almost " waterproof " trading system. The 200 SMA basic strategy is excellent for gaining experience, learning to follow the rules of a system and not to burn your money right away. 

With this script you can test how successful the "simplest strategy in the world" would have been in the past. 

Small tip: Do not trade Forex with it it will never work. The strategy is made for long trends and you can find them for example in the stock market.

Have fun with it! About a positive feedback I would be very happy of course.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Ichimoku-Trading by TradersEldorado

//@version=4
strategy("simple MA 200 cross", overlay=true)

//Inputs
MA_Len = input(title="Moving Average Length", type=input.integer, defval=200)

//Moving Average
MA = sma(close, MA_Len)

//Entry 
longCondition = crossover(close, MA)
if (longCondition)
    strategy.entry("Long", strategy.long)
    
//Exit
exitCondition = crossunder(close, MA)
if (exitCondition)
    strategy.close("Long")
    
//Plot
plot(MA, title="Moving Average")
plotshape(longCondition, style=shape.arrowup, color=color.green, location=location.belowbar, size=size.normal, title="Entry", text="Entry")
plotshape(exitCondition, style=shape.arrowdown, color=color.red, location=location.abovebar, size=size.normal, title="Exit", text="Exit")
````
