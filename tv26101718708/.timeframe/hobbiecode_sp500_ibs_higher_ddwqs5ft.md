# Hobbiecode - SP500 IBS + Higher

- url: https://www.tradingview.com/script/DDWqs5FT/
- type: strategy
- pine_id: PUB;d15c74bab18d4b04a103d4bf53f719a1
- version: 3.0

## Description

This is a simple strategy that is working well on SPY but also well performing on Mini Futures SP500. The strategy is composed by the followin rules:

1. Today is Monday.
2. The close must be lower than the close on Friday.
3. The IBS must be below 0.5.
4. If 1-3 are true, then enter at the close.
5. Sell 5 trading days later (at the close).

If you backtest it on Mini Futures SP500 you will be able to track data from 1993. It is important to select D1 as timeframe.

Please share any comment or idea below.

Have a good trading,
Ramón.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © hobbiecode


// Today is Monday.
// The close must be lower than the close on Friday.
// The IBS must be below 0.5.
// If 1-3 are true, then enter at the close.
// Sell 5 trading days later (at the close).

//@version=5
strategy("Hobbiecode - SP500 IBS + Higher", overlay=true)

// Check if it's Monday
isMonday = dayofweek(time) == dayofweek.monday

// Calculate the IBS (Intraday Breadth Strength) indicator
ibs = (close - low) / (high - low)

// Calculate the close on the previous Friday
prevFridayClose = request.security(syminfo.tickerid, "W", close)

// Entry conditions
enterCondition = isMonday and close < prevFridayClose and ibs < 0.5 and strategy.position_size < 1 

// Exit conditions
exitCondition = (close > high[1] or ta.barssince(enterCondition) == 4) and strategy.position_size > 0 

// Entry signal
if enterCondition
    strategy.entry("Buy", strategy.long)

// Exit signal
if exitCondition
    strategy.close("Buy")

// Plotting the close, previous Friday's close, and entry/exit points on the chart
plot(close, title="Close", color=color.blue)
plot(prevFridayClose, title="Previous Friday Close", color=color.orange)
plotshape(enterCondition, title="Enter", location=location.belowbar, color=color.green, style=shape.labelup, text="Enter")
plotshape(exitCondition, title="Exit", location=location.abovebar, color=color.red, style=shape.labeldown, text="Exit")
````
