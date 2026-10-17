# John Wick Doji indicator

- url: https://www.tradingview.com/script/kzg8mej0-John-Wick-Doji-indicator/
- type: indicator
- pine_id: PUB;bd4589680cd5464b9229706cf499a76a
- version: 2.0

## Description

This indicator will highlight Doji candles (Long wicks) based on the body length.

You can adjust the length threshold in the properties.

I also put in an option to show reverse wicks, meaning a doji in the opposite direction of it's color.

Has alerts..etc
Let me know if you find this indicator useful.

Thanks,
Nossgrr

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Nossgrr

//@version=6

indicator("John Wick", overlay = true)

////////////////////////////////////////////////
// John Wick Indicator
maxWick         = input.float(defval = 60, minval=0.1,step = 1, title="John Wick Max Upper Wick Size")
showJWic        = input.bool(defval = true, title = "Show John Wick Candles?")
showReverseJWic = input.bool(defval = false, title = "Show Reverse John Wick Candles?")

bool  bullishJC = false
bool  bearishJC = false

bool  jcWick    = false
bool  rjcWick   = false

float wicHighSize = na
float wicLowSize  = na
float candleBody  = na
float bodyPercent = na

// Get candle and wick dimensions
body = math.abs(close - open)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
upperWickPct = body != 0 ? (upperWick / body) * 100 : na
lowerWickPct = body != 0 ? (lowerWick / body) * 100 : na

// Check if the candle is bullish or Bearish
if open < close // Bull candle
    if lowerWick > upperWick // JC Candle is Bullish
        bullishJC := lowerWickPct > maxWick //and close// > HMA

if open > close // bear candle
    if upperWick > lowerWick // Candle is Bearish
        bearishJC := upperWickPct > maxWick //and close //< HMA

if open > close and showReverseJWic // Reverse Bull candle
    if lowerWick > upperWick // JC Candle is Bullish
        bullishJC := lowerWickPct > maxWick //and close// > HMA

if open < close and showReverseJWic//  Reverse bear candle
    if upperWick > lowerWick // Candle is Bearish
        bearishJC := upperWickPct > maxWick //and close //< HMA


barcolor((bullishJC or bearishJC) and (showJWic or showReverseJWic) ? color.rgb(0, 0, 0) : na, title = "John Wick Candles")

alertcondition((bullishJC or bearishJC), title='John Wick Candle', message='[CurrencyPair] [TimeFrame], John Wick candle')

if (bullishJC or bearishJC) and showJWic
    alert("John Wick Candle",alert.freq_once_per_bar_close)
````
