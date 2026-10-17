# Decisive Candles [louis]

- url: https://www.tradingview.com/script/rwmpHLg6-Decisive-Candles-louis/
- type: indicator
- pine_id: PUB;8bf2dbdf603c4d1abd99cd7d7e923b37
- version: 1.0

## Description

This indicator highlights "decisive" bullish or bearish candles based on candle body strength and minimal counter-wick size.
[list]
[*]A bullish candle is marked when price closes above the open and closes near the high, showing strong upward conviction.
[*]A bearish candle is marked when price closes below the open and closes near the low, showing strong downward conviction.
[/list]
Users can adjust the allowed counter-wick percentage, minimum body size, and the highlight colors for bullish and bearish decisive candles.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © louisq69
//@version=6
indicator("Decisive Candles [louis]", overlay=true)

//────────────────────────────────────
// Inputs
//────────────────────────────────────
decisiveWickRatio = input.float(
     0.20,
     "Max Counter-Wick % of Open-to-Extreme Range",
     minval=0.0,
     maxval=1.0,
     step=0.05
)

minBodyPercent = input.float(
     0.0,
     "Minimum Body % of Full Candle Range",
     minval=0.0,
     maxval=1.0,
     step=0.05
)

bullDecisiveColor = input.color(color.lime, "Bullish Decisive Candle Color")
bearDecisiveColor = input.color(color.red, "Bearish Decisive Candle Color")

//────────────────────────────────────
// Candle structure
//────────────────────────────────────
bullishCandle = close > open
bearishCandle = close < open

fullRange = high - low
bodySize  = math.abs(close - open)

bodyPercentOk = fullRange > 0 and bodySize >= fullRange * minBodyPercent

//────────────────────────────────────
// Decisive candle logic
//────────────────────────────────────
bullOpenToHigh  = high - open
bullCounterWick = high - close

bearOpenToLow   = open - low
bearCounterWick = close - low

bullDecisive =
     bullishCandle and
     bodyPercentOk and
     bullOpenToHigh > 0 and
     bullCounterWick <= bullOpenToHigh * decisiveWickRatio

bearDecisive =
     bearishCandle and
     bodyPercentOk and
     bearOpenToLow > 0 and
     bearCounterWick <= bearOpenToLow * decisiveWickRatio

//────────────────────────────────────
// Candle coloring
//────────────────────────────────────
barcolor(
     bullDecisive ? bullDecisiveColor :
     bearDecisive ? bearDecisiveColor :
     na
)
````
