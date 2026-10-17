# Vertical Horizontal Filter Backtest

- url: https://www.tradingview.com/script/9t7qidqL-Vertical-Horizontal-Filter-Backtest/
- type: strategy
- pine_id: PUB;zH8CE9WmTR7wLrRmGjINFhdedL4tHV6A
- version: 1.0

## Description

Vertical Horizontal Filter was initiated by Adam White. It was first published 
 in a magazine called “Issues of Futures” in August, 1991. The Vertical Horizontal 
 Filter (VHF) is a very common Indicator used by traders to find out the Phase of 
 a Price Trend. Normally, a price trend can be in a Trending Phase or a Congestion 
 Phase/Choppy Movement Phase. Adam White created this particular Technical Indicator 
 to determine whether prices are trending in a particular direction or are they going 
 through a transitional period. He used it to measure the range of Futures available
 in the market.

 You can change long to short in the Input Settings
 WARNING:
  - For purpose educate only
  - This script to change bars colors.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 27/04/2018
// Vertical Horizontal Filter was initiated by Adam White. It was first published 
// in a magazine called “Issues of Futures” in August, 1991. The Vertical Horizontal 
// Filter (VHF) is a very common Indicator used by traders to find out the Phase of 
// a Price Trend. Normally, a price trend can be in a Trending Phase or a Congestion 
// Phase/Choppy Movement Phase. Adam White created this particular Technical Indicator 
// to determine whether prices are trending in a particular direction or are they going 
// through a transitional period. He used it to measure the range of Futures available
// in the market.
//
// You can change long to short in the Input Settings
// WARNING:
//  - For purpose educate only
//  - This script to change bars colors.
////////////////////////////////////////////////////////////
strategy(title="Vertical Horizontal Filter Backtest")
Length = input(28, minval=1)
Signal = input(0.4, step=0.01)
reverse = input(false, title="Trade reverse")
hline(Signal, color=blue, linestyle=line)
xHH = highest(high, Length)
xLL = lowest(low, Length)
xNumerator = abs(xHH - xLL)
xDenominator = sum(abs(close - close[1]), Length)
xVHF = xNumerator / xDenominator 
pos = iff(xVHF > Signal, 1,
       iff(xVHF < Signal, -1, nz(pos[1], 0))) 
possig = iff(reverse and pos == 1, -1,
          iff(reverse and pos == -1, 1, pos))	   
if (possig == 1) 
    strategy.entry("Long", strategy.long)
if (possig == -1)
    strategy.entry("Short", strategy.short)	   	    
barcolor(possig == -1 ? red: possig == 1 ? green : blue ) 
plot(xVHF, color=blue, title="VHF")
````
