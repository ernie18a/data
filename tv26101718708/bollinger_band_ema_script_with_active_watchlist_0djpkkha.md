# Bollinger Band EMA script with active watchlist 

- url: https://www.tradingview.com/script/0DJPkKha-Bollinger-Band-EMA-script-with-active-watchlist/
- type: indicator
- pine_id: PUB;b419be07007347f28ac474bb7a056f85
- version: 1.0

## Description

Bollinger Band Stop-Hunt Screener

This indicator is a custom Bollinger Band screener designed to identify potential swing trading setups based on the Bollinger Band + 9 EMA stop-hunt concept.

The logic is inspired by a strategy that looks for trend continuation after price pulls back toward the opposite Bollinger Band. The idea is to find stocks that are in an active trend but temporarily stretched toward a reversal zone, creating a possible swing entry opportunity.

How it works

The screener checks a custom list of symbols and classifies each one as:

BUY CALL
Price is in an uptrend, touches or rejects the lower Bollinger Band, and forms a bullish candle.

CALL WATCH
Price is in an uptrend and trading near the lower Bollinger Band, but confirmation has not happened yet.

BUY PUT
Price is in a downtrend, touches or rejects the upper Bollinger Band, and forms a bearish candle.

PUT WATCH
Price is in a downtrend and trading near the upper Bollinger Band, but confirmation has not happened yet.

NEUTRAL
No valid setup is currently detected.

Main components
Bollinger Bands: 20-period, 2 standard deviations
9 EMA trend filter
Near Band % filter for early watchlist signals
Optional gap filter
Chart-timeframe based scanning
Clean table display for multiple symbols
Optional Bollinger Band and EMA chart plotting
Alerts for BUY CALL, BUY PUT, CALL WATCH, and PUT WATCH conditions
Best use

This screener is designed for traders looking for pullback-based swing entries, especially on the 4H or Daily timeframe. It can also be used on shorter timeframes, but lower timeframes may produce more noise.

For longer-dated options swing trading, the Daily chart is generally preferred.

Important note

This script is not financial advice and does not guarantee profitable trades. It should be used as a watchlist and confirmation tool, not as a standalone buy/sell system. Always combine signals with your own analysis, support/resistance, volume, market trend, and risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Pinewarrior

//@version=6
indicator("My script")
plot(close)
````
