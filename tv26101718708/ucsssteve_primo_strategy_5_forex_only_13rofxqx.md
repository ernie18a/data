# UCS_S_Steve Primo - Strategy #5 (FOREX Only)

- url: https://www.tradingview.com/script/13ROfXqx-UCS-S-Steve-Primo-Strategy-5-FOREX-Only/
- type: indicator
- pine_id: PUB;1052
- version: -1.0

## Description

Here we have another Steve Primo Strategy ( #5)

This is a short term, trend continuation strategy, Recommend using this on 30 Mins + time frames. 

I have added few things. 
1. PET-D filter, to identify the trend along with the SMA 50.  ----> Setup in line with PET-D (EMA,15) trend confirmation. 
2. Option for Harami Candle identification (may not be Steve Primo Setup), There is no evidence on any of the videos listed below for Harami or other candlesticks pattern. 

Future - Planned to add other candle patterns. 

Videos from Youtube
1. https://www.youtube.com/watch?v=C4o2OyqV8es - 
2. https://www.youtube.com/watch?v=3ZzOcVOcZL4  - Hints disclosed on this video. 
3. https://www.youtube.com/watch?v=pId1mTnogPg - Claims this is his GO TO strategy for FOREX.
4. https://www.youtube.com/watch?v=NlwG0xpcpIs - Complete Free Lesson. 

Note - I did not buy this Strategy, I do not own in any way shape or form of this strategy as presented in the videos, The Strategy I am posting is my interpretation based on Steve Primo's videos listed above and few more on youtube. 

Good Luck folks.

## Source Code

````pine
// Created By UCSgears
// Here is another Steve Primo Strategy. He calls it Strategy #5, and only use it on FOREX. Not in Stocks or Futures. 

study("Steve Primo - Strategy # 5", overlay = true)

// Trend SMA
scolor = input(true, title = "Show Bar Colors")
sh = input(false, title = "Show Harami Candle Setup")
se = input(true, title = "Show Engulfing Candle Setup")
//sp = input(false, title = "Show Pinbar Candle Setup")

trend = sma(close,50)
trendup = close > trend ? 1 : 0
trenddn = close < trend ? 1 : 0

// PET-D
petd = ema(close,15)
petdup = close > petd ? 1 : 0 
petddn = close < petd ? 1 : 0

// Bullish Engulfing
BuE = trendup == 1  and petdup == 1 ? (close > open) and (close[1] <= open[1]) and (close >= open[1]) and (open <= close[1]) and (abs(close - open) > abs(open[1] - close[1])) : na
BuEC = scolor == 1 and BuE == 1 ? green : na
barcolor(BuEC)

// Bearish Engulfing
BrE = trenddn == 1  and petddn == 1 ? (close < open) and (close[1] >= open[1]) and (close <= open[1]) and (open >= close[1]) and (abs(close - open) > abs(open[1] - close[1])) : na
BrEC = scolor == 1 and BrE == 1 ? red : na
barcolor(BrEC)

// Harami Candle addition is not part of his strategy

// Bullish Harami
BuH =  trendup == 1  and petdup == 1 ? (close > open) and (close[1] <= open[1]) and (close <= open[1]) and (open >= close[1]) and (abs(close - open) < abs(open[1] - close[1])) : na
BuHC = scolor == 1 and BuH == 1 ? lime : na
barcolor(BuHC)

// Bearish Harami
BrH =  trenddn == 1  and petddn == 1 ? (close < open) and (close[1] >= open[1]) and (close >= open[1]) and (open <= close[1]) and (abs(close - open) < abs(open[1] - close[1])) : na
BrHC = scolor == 1 and BrH == 1 ? orange : na
barcolor(BrHC)

// ALL PLOTS

plotchar(sh ? BuH : na, title="Long Setup Bar", char='⇑', location=location.belowbar, color=green, transp=0, text="S #5 Harami Long")
plotchar(sh ? BrH : na, title="Short Setup Bar", char='⇓', location=location.abovebar, color=red, transp=0, text="S #5 Harami Short")

plotchar(se ? BuE : na, title="Long Setup Bar", char='⇑', location=location.belowbar, color=green, transp=0, text="S #5 Engulf Long")
plotchar(se ? BrE : na, title="Short Setup Bar", char='⇓', location=location.abovebar, color=red, transp=0, text="S #5 Engulf Short")
````
