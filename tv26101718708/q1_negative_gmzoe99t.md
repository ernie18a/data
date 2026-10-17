# Q1 Negative

- url: https://www.tradingview.com/script/GMzOe99T-Q1-Negative/
- type: indicator
- pine_id: PUB;a5bf723062e5472b89c1230b342b805f
- version: 1.0

## Description

This will show all the times when Q1 was negative relative to the previous Quarter close.

## Source Code

````pine
//@version=5
indicator("Q1 Negative", overlay=true)

isQ1 = month(time) == 1
prevClose = close[1]

plotshape(isQ1 and close < prevClose, title="Q1 Down vs Q4", style=shape.arrowdown, location=location.abovebar, color=color.red, size=size.large, text="Q1 < Q4")
````
