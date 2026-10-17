# Extended Price Line rohit

- url: https://www.tradingview.com/script/0TYZIBr5-Extended-Price-Line-rohit/
- type: indicator
- pine_id: PUB;01130638ce6649aa91812afb6f0d78cb
- version: 1.0

## Description

horizontal line..created for horizonta use.Why this works better
Appears properly in indicator list
Works with alerts
Shows line on right-hand price scale
Extends visually across chart
Easier to use in TradingView alerts

## Source Code

````pine
//@version=5
indicator("Extended Price Line", overlay=true)

// Input
priceLevel = input.float(100.0, title="Price Level")

// Plot line across full chart
plot(priceLevel,
     title="Price Line",
     color=color.red,
     linewidth=2,
     trackprice=true)
````
