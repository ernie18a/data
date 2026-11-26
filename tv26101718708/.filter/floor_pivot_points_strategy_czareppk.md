# Floor Pivot Points Strategy

- url: https://www.tradingview.com/script/czarepPK-Floor-Pivot-Points-Strategy/
- type: indicator
- pine_id: PUB;LtpKkr5AD1rvHnxLstTv0z53EQn3bqBT
- version: 1.0

## Description

The name ‘Floor-Trader Pivot,’ came from the fact that Pivot points can 
 be calculated quickly, on the fly using price data from the previous day 
 as an input. Although time-frames of less than a day can be used, Pivots are 
 commonly plotted on the Daily Chart; using price data from the previous day’s 
 trading activity. 

 WARNING:
  - This script to change bars colors.

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 26/06/2018
// The name ‘Floor-Trader Pivot,’ came from the fact that Pivot points can 
// be calculated quickly, on the fly using price data from the previous day 
// as an input. Although time-frames of less than a day can be used, Pivots are 
// commonly plotted on the Daily Chart; using price data from the previous day’s 
// trading activity. 
//
// WARNING:
//  - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Floor Pivot Points Strategy", shorttitle="FPP", overlay = true)
width = input(2, minval=1)
xHigh  = security(tickerid,"D", high[1])
xLow   = security(tickerid,"D", low[1])
xClose = security(tickerid,"D", close[1])
vPP = (xHigh+xLow+xClose) / 3
vR1 = (vPP * 2) - xLow
vS1 = (vPP * 2) - xHigh
pos = iff(close > vR1, 1,
       iff(close < vS1, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
````
