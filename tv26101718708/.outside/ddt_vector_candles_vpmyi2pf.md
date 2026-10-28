# DDT Vector Candles

- url: https://www.tradingview.com/script/vpMYI2Pf-DDT-Vector-Candles/
- type: indicator
- pine_id: PUB;d3f185912ff841c2b29ad598ef992ea9
- version: 1.0

## Description

DDT Vector Candles

The DDT Vector Candles indicator is designed to highlight moments of abnormal market participation.

Markets spend most of their time moving with average volume and average effort. The moves that matter most often occur when participation suddenly expands and aggressive buyers or sellers enter the market.

DDT Vector Candles help identify those moments.

Rather than focusing on every candle, the indicator filters for candles that display significantly higher activity than normal, allowing traders to quickly spot areas where meaningful buying or selling pressure entered the market.

Key Features

▪️ Highlights candles with abnormal volume and participation.

▪️ Helps identify areas of aggressive buying and selling.

▪️ Useful for spotting potential accumulation, distribution, absorption, and continuation.

▪️ Works across all markets and timeframes.

▪️ Designed to complement market structure, liquidity, and Wyckoff analysis.

How It Is Used

DDT Vector Candles are not buy or sell signals.

A vector candle simply tells you that something important happened.

The next step is understanding the context around it.

For example:

▪️ A bullish vector candle into demand may signal strong buying interest.

▪️ A bearish vector candle into supply may signal aggressive selling pressure.

▪️ A vector candle after a liquidity sweep may indicate absorption or a shift in participation.

▪️ A vector candle during a trend may confirm continuation strength.

The candle itself is not the edge.

The edge comes from combining it with context.

Best Practices

▪️ Use vector candles alongside market structure analysis.

▪️ Pay close attention to vector candles forming at key liquidity levels.

▪️ Watch for reactions around supply and demand zones.

▪️ Focus on where the candle forms, not just the candle itself.

▪️ Combine with trend, liquidity, and confirmation before executing trades.

The DDT Philosophy

Most traders focus on predicting what will happen next.

DDT Vector Candles focus on understanding what is happening right now.

The indicator is designed to help traders identify moments where participation becomes abnormal, allowing them to build a more complete picture of market intent before making a decision.

Process over outcome.

## Source Code

````pine
//@version=6
indicator(title="DDT Vector Candles", shorttitle="DDT Vector", overlay=true)

// DDT Colors
color ddtBullStrong = color.rgb(26, 90, 255)   // #1A5AFF
color ddtBearStrong = color.red

// PVSRA Override
bool overrideSym = input.bool(defval=false, title="Override chart symbol?", group="PVSRA Override", inline="pvsra")
string pvsraSym = input.string(defval="INDEX:BTCUSD", title="", group="PVSRA Override", inline="pvsra")

// Data
getPvsraData(bool overrideSymbolX, string pvsraSymbolX, string tickerIdX) =>
    request.security(
         overrideSymbolX ? pvsraSymbolX : tickerIdX,
         timeframe.period,
         [volume, high, low, close, open],
         barmerge.gaps_off,
         barmerge.lookahead_off
     )

[pvsraVol, pvsraHigh, pvsraLow, pvsraClose, pvsraOpen] = getPvsraData(overrideSym, pvsraSym, syminfo.tickerid)

// Vector Logic
averageVolume = ta.sma(pvsraVol[1], 10)
volumeSpread = pvsraVol * (pvsraHigh - pvsraLow)
highestVolumeSpread = ta.highest(volumeSpread[1], 10)

// Strong vectors only
isStrongVector = pvsraVol >= 2 * averageVolume or volumeSpread >= highestVolumeSpread

// Direction
isBullVector = pvsraClose > pvsraOpen
isBearVector = pvsraClose <= pvsraOpen

// Color logic
color vectorColor = isStrongVector and isBullVector ? ddtBullStrong : isStrongVector and isBearVector ? ddtBearStrong : na

// Color candles
barcolor(vectorColor)

// Alerts
alertcondition(isStrongVector, title="DDT Strong Vector Candle", message="{{ticker}} DDT Strong Vector Candle on the {{interval}}")
alertcondition(isStrongVector and isBullVector, title="DDT Strong Bull Vector", message="{{ticker}} DDT Strong Bull Vector on the {{interval}}")
alertcondition(isStrongVector and isBearVector, title="DDT Strong Bear Vector", message="{{ticker}} DDT Strong Bear Vector on the {{interval}}")
````
