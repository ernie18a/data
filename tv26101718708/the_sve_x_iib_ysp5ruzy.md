# THE SVE X (IIB)

- url: https://www.tradingview.com/script/YsP5rUzY-THE-SVE-X-IIB/
- type: indicator
- pine_id: PUB;891fc220791849bc8e877d51c2cb03cf
- version: 1.0

## Description

The code is to mark out the last bearish candle before a 3 candle bullish move, and vice versa.

## Source Code

````pine
//@version=5
indicator("THE SVE X (IIB)", overlay=true)

// Candle definitions
bullish = close > open
bearish = close < open

// Three bullish candles in a row
threeBullish =
     bullish and
     bullish[1] and
     bullish[2]

// Three bearish candles in a row
threeBearish =
     bearish and
     bearish[1] and
     bearish[2]

// =========================
// DISPLACEMENT CONDITIONS
// =========================

// Bullish run: 3 bullish closes must break above bearish setup high
bullishCloseHigh = math.max(close, math.max(close[1], close[2]))
bearishSetupHigh = high[3]

validBullishMove =
     threeBullish and
     bearish[3] and
     bullishCloseHigh > bearishSetupHigh

// Bearish run: 3 bearish closes must break below bullish setup low
bearishCloseLow = math.min(close, math.min(close[1], close[2]))
bullishSetupLow = low[3]

validBearishMove =
     threeBearish and
     bullish[3] and
     bearishCloseLow < bullishSetupLow

// =========================
// Color the setup candle
// =========================
barcolor(validBullishMove ? color.red : na, offset = -3)
barcolor(validBearishMove ? color.green : na, offset = -3)
````
