# AK_ TREND ID AS A STRATEGY : FOR EDUCATIONAL PURPOSES ONLY

- url: https://www.tradingview.com/script/ztKUkLYL-AK-TREND-ID-AS-A-STRATEGY-FOR-EDUCATIONAL-PURPOSES-ONLY/
- type: strategy
- pine_id: PUB;1873
- version: -1.0

## Description

Just converted the AK_ TREND ID into a strategy , to show the efficiency of this simple indicator. I used SPX in this example, to display that the indicator has been accurate for a long time.

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
