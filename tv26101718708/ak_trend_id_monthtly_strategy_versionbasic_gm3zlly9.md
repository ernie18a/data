# AK_ TREND ID Monthtly Strategy Version:Basic

- url: https://www.tradingview.com/script/gM3ZllY9-AK-TREND-ID-Monthtly-Strategy-Version-Basic/
- type: strategy
- pine_id: PUB;gzFsTfrS7H21WyIY0fl5CGfktEYC2Ojx
- version: 1.0

## Description

ak trends

## Source Code

````pine
//@version=2
// by algokid , 10/2015
strategy("AK_ TREND ID Monthtly Strategy Version:Basic", overlay=true)

// inputs
input1 = 3, input2 = 8 , 

fastmaa = ema(close,input1)
fastmab = ema(close,input2)

bspread = (fastmaa-fastmab)*1.001

// exeution

longCondition = bspread > 0 
if (longCondition)
    strategy.entry("Risk on", strategy.long)
strategy.close_all(when = bspread < 0 )
````
