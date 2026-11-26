# Weekly 10/20/30/40 SMA Overlay

- url: https://www.tradingview.com/script/4e33golT-Weekly-10-20-30-40-SMA-Overlay/
- type: indicator
- pine_id: PUB;e4b398845e054ae9a8926a09d3b302e3
- version: 1.0

## Description

This indicator plots the 10, 20, 30, and 40-week Simple Moving Averages (SMAs) on any chart timeframe.

The purpose is to provide a higher-timeframe trend framework that can help traders and investors determine the overall market environment.

How to Use

Bullish Trend:

Price above all four SMAs.
10-week above the 20-week.
20-week above the 30-week.
30-week above the 40-week.

This suggests institutional participation may be supporting higher prices.

Bearish Trend:

Price below all four SMAs.
10-week below the 20-week.
20-week below the 30-week.
30-week below the 40-week.

This suggests the longer-term trend may be weakening or trending lower.

Transition / Consolidation:

The moving averages flatten or become intertwined.

This often indicates a market that is:

consolidating,
changing trend,
or lacking clear directional conviction.

Notes
This indicator is not intended as a standalone buy or sell signal.
It is designed to help traders and investors align themselves with the broader market trend.
Many trend-following approaches use higher-timeframe moving averages as a filter for position management and directional bias.

## Source Code

````pine
//@version=6
indicator("Weekly 10/20/30/40 SMA Overlay", overlay=true)

// Weekly SMA lengths
sma10Len = input.int(10, "10 Week SMA", minval=1)
sma20Len = input.int(20, "20 Week SMA", minval=1)
sma30Len = input.int(30, "30 Week SMA", minval=1)
sma40Len = input.int(40, "40 Week SMA", minval=1)

// Calculate weekly SMAs and display them on any timeframe
wSma10 = request.security(syminfo.tickerid, "W", ta.sma(close, sma10Len))
wSma20 = request.security(syminfo.tickerid, "W", ta.sma(close, sma20Len))
wSma30 = request.security(syminfo.tickerid, "W", ta.sma(close, sma30Len))
wSma40 = request.security(syminfo.tickerid, "W", ta.sma(close, sma40Len))

// Plot weekly SMAs
plot(wSma10, title="10 Week SMA", color=color.yellow, linewidth=2)
plot(wSma20, title="20 Week SMA", color=color.orange, linewidth=2)
plot(wSma30, title="30 Week SMA", color=color.blue, linewidth=2)
plot(wSma40, title="40 Week SMA", color=color.purple, linewidth=2)
````
