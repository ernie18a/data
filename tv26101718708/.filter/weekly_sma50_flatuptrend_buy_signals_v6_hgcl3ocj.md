# Weekly SMA50 Flat/Uptrend Buy Signals v6

- url: https://www.tradingview.com/script/hGCl3OcJ-Weekly-SMA50-Flat-Uptrend-Buy-Signals-v6/
- type: indicator
- pine_id: PUB;6145e686982e4ff394787b99ddfa4d07
- version: 1.0

## Description

Trying to build a buy signal so I don't jump on a stock for FOMO reasons. Do your own due diligence.  Based on start of uptrend, and above 50SMA weekly.  Works for stocks with earnings even though the market may be slow to see it

## Source Code

````pine
//@version=6
indicator("Weekly SMA50 Flat/Uptrend Buy Signals v6", overlay=true)

// Calculate the SMA50 on the current chart context first
sma50 = ta.sma(close, 50)

// Fetch weekly values cleanly using a flat tuple
// [1] refers to the previous week's bar value
[weeklyClose, weeklyOpen, prevWeeklyClose, prevWeeklyOpen, weeklySMA50, prevWeeklySMA50] = request.security(
     syminfo.tickerid, 
     "W", 
     [close, open, close[1], open[1], sma50, sma50[1]]
 )

// Detect the bar where a weekly candle closes/opens
isWeekClose = timeframe.change("W")

// Filter 1: Is the Weekly SMA50 flat or moving uptrend?
smaIsUptrend = weeklySMA50 >= prevWeeklySMA50

// Filter 2: Is this week's close higher than last week's close AND last week's open?
higherThanLastWeek = weeklyClose > prevWeeklyClose and weeklyClose > prevWeeklyOpen

// Define Buy Signal conditions (including all filters)
buyCondition = weeklyClose > weeklyOpen and weeklyClose > weeklySMA50 and smaIsUptrend and higherThanLastWeek and isWeekClose

// Plot a tiny plain green 'B' above the bar
// plotshape(buyCondition, title="Buy Signal", text="B", style=shape.none, 
//           location=location.abovebar, textcolor=color.green, size=size.tiny)

// Plot a plain green 'B' above the bar
plotchar(buyCondition, title="Buy Signal", char="B", 
         location=location.abovebar, color=color.green, size=size.tiny)
````
