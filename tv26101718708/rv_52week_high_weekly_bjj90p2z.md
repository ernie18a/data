# RV 52-Week High (Weekly)

- url: https://www.tradingview.com/script/bJj90P2Z-RV-52-Week-High-Weekly/
- type: indicator
- pine_id: PUB;ad280d6109134ebbb49494ac217f59e9
- version: 1.0

## Description

RV 52-Week High – Enjoy spotting every new weekly 52-week high with clear parrot‑green arrows

## Source Code

````pine
//@version=5
indicator("52-Week High Arrow (Weekly)", overlay = true)

// 52 weeks = 52 weekly bars
period52 = 52

// Highest high of last 52 bars excluding current bar
highestPrev = ta.highest(high[1], period52)

// Condition: current weekly high is above all previous 52 weeks
new52WeekHigh = high > highestPrev

// Plot an up arrow above the candle when a new 52-week high forms
plotshape(
     new52WeekHigh,
     title = "New 52W High (Weekly)",
     style = shape.arrowup,
     location = location.abovebar,
     color = color.new(color.rgb(0, 255, 127), 0),  // parrot green
     size = size.small,
     text = "52W H")
````
