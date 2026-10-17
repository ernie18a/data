# Absolute Price Oscillator (APO)

- url: https://www.tradingview.com/script/UA8txqpp-Absolute-Price-Oscillator-APO/
- type: indicator
- pine_id: PUB;zJMqsrm8HxpO9kvQsxTXeRRrLKRBcyeV
- version: 1.0

## Description

The Absolute Price Oscillator displays the difference between two exponential 
 moving averages of a security's price and is expressed as an absolute value.
 How this indicator works
    APO crossing above zero is considered bullish, while crossing below zero is bearish.
    A positive indicator value indicates an upward movement, while negative readings 
      signal a downward trend.
    Divergences form when a new high or low in price is not confirmed by the Absolute Price 
      Oscillator (APO). A bullish divergence forms when price make a lower low, but the APO 
      forms a higher low. This indicates less downward momentum that could foreshadow a bullish 
      reversal. A bearish divergence forms when price makes a higher high, but the APO forms a 
      lower high. This shows less upward momentum that could foreshadow a bearish reversal.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 04/05/2017
// The Absolute Price Oscillator displays the difference between two exponential 
// moving averages of a security's price and is expressed as an absolute value.
// How this indicator works
//    APO crossing above zero is considered bullish, while crossing below zero is bearish.
//    A positive indicator value indicates an upward movement, while negative readings 
//      signal a downward trend.
//    Divergences form when a new high or low in price is not confirmed by the Absolute Price 
//      Oscillator (APO). A bullish divergence forms when price make a lower low, but the APO 
//      forms a higher low. This indicates less downward momentum that could foreshadow a bullish 
//      reversal. A bearish divergence forms when price makes a higher high, but the APO forms a 
//      lower high. This shows less upward momentum that could foreshadow a bearish reversal.
////////////////////////////////////////////////////////////
study(title="Absolute Price Oscillator (APO)", shorttitle="APO")
LengthShortEMA = input(10, minval=1)
LengthLongEMA = input(20, minval=1)
hline(0, color=gray, linestyle=line)
xPrice = close
xShortEMA = ema(xPrice, LengthShortEMA)
xLongEMA = ema(xPrice, LengthLongEMA)
xAPO = xShortEMA - xLongEMA
pos = iff(xAPO > 0, 1,
       iff(xAPO < 0, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(xAPO, color=blue, title="APO")
````
