# John Carter's Buy/Sell Scalper V2

- url: https://www.tradingview.com/script/7KM8wTpd-John-Carter-s-Buy-Sell-Scalper-V2/
- type: indicator
- pine_id: PUB;BlNNLm4ON3HVNRNgKrBVd3cMBbZ3HNT6
- version: 1.0

## Description

After a couple adjustments, double signals are now being ignore.
Here's how this script works:
Based entirely on a John Carter scalping setup, a candle will be painted purple if the next two closes are in a opposite direction of the past trend.
Green triangles indicates that the reversal is bullish, red triangles indicates that the reversal is bearish. Both are entry/exit points if you want to follow this set up.
Personally, I find this setup to work best in trending days, but it does a great job on choppy days if you use it as a confirmation.

## Source Code

````pine
//@version=3
study("John Carter's Buy/Sell Scalper V2", overlay=true)
r = close <= close[1] and close[1] <= close[2]
g = close >= close[1] and close[1] >= close[2]

rg = 0
rg := r ? 1 : g ? 2 : nz(rg[1])

plotshape(rg != rg[1], color = rg == 1 ? red : lime, style=shape.triangleup , location=location.belowbar)
barcolor(rg != rg[1] ? purple : na, offset = -2)
alertcondition(rg != rg[1], title='Market Reversal', message='Market is reversing')
````
