# 30/50/180 SMAs

- url: https://www.tradingview.com/script/Ez67VPsE-30-50-180-SMAs/
- type: indicator
- pine_id: PUB;a4cf4cf37b154159a5ea38056af538a2
- version: 1.0

## Description

30-Day SMA — Short/Intermediate Term

The 30-day SMA reacts relatively quickly to changes in price.

Rising → short/intermediate trend is strengthening
Falling → trend is weakening
Price above SMA → generally positive short-term structure
Price below SMA → generally negative short-term structure

Best for: identifying recent trend direction and pullbacks.

50-Day SMA — Intermediate Term

The 50-day SMA is one of the most commonly watched moving averages. It is slower and more stable than the 30-day SMA.

Rising 50 SMA → intermediate trend is generally positive
Falling 50 SMA → intermediate trend is generally negative
Price crossing the 50 SMA → potentially important change in intermediate momentum

Best for: confirming whether a short-term move is consistent with the broader intermediate trend.

180-Day SMA — Long Term

The 180-day SMA is much slower and filters out considerably more short-term market noise.

It represents roughly 9 months of trading history.

Rising → long-term trend is generally positive
Falling → long-term trend is generally negative
Price testing the 180 SMA → potentially important long-term trend level

Best for: determining whether the stock's overall long-term trend is still intact.

## Source Code

````pine
//@version=6
indicator("Daily SMAs", overlay=true)

// SMA lengths
length30  = input.int(30, "30-Day SMA", minval=1)
length50  = input.int(50, "50-Day SMA", minval=1)
length180 = input.int(180, "180-Day SMA", minval=1)

// Calculate on DAILY timeframe
sma30 = request.security(
     syminfo.tickerid,
     "D",
     ta.sma(close, length30),
     lookahead=barmerge.lookahead_off)

sma50 = request.security(
     syminfo.tickerid,
     "D",
     ta.sma(close, length50),
     lookahead=barmerge.lookahead_off)

sma180 = request.security(
     syminfo.tickerid,
     "D",
     ta.sma(close, length180),
     lookahead=barmerge.lookahead_off)

// Plot
plot(sma30, title="30-Day SMA", color=color.red, linewidth=2)
plot(sma50, title="50-Day SMA", color=color.blue, linewidth=2)
plot(sma180, title="180-Day SMA", color=color.green, linewidth=2)
````
