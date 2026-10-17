# Dual Timeframe Williams Percent Range

- url: https://www.tradingview.com/script/4qdV8UKu-Dual-Timeframe-Williams-Percent-Range/
- type: indicator
- pine_id: PUB;5a6c9a07bc174637a9d6a2dc46b5d606
- version: 1.0

## Description

This is a dual timeframe Williams Percent Range indicator. 

Function:

The idea behind this indicator is for trader to see what the Williams %r is doing on higher timeframes without the need to change the chart. I added the "Smoothing" function to take the jagged lines out of the higher timeframe. It has a better flow this way. 

If we choose the 4H and the Daily timeframes for example. In this bullish situation I wait for the Daily WPR to cross above the -50 mid line. Then the faster 4H WPR will eventually hit the bottom and begin to rise again back into the trend. 

This is the "Reset" of the 4H WPR and when the 4H WPR crosses up above the -50 mid line again it means price should begin to rise on the chart. I added the option to change the colour when the signal lines cross the -50. It is good to use a fast time frame so you can see the WPR hitting the bottom in an uptrend, but not too fast. 

The Heiken Ashi candle sticks are a very good addition to this system. You can also use a colour changing 200 EMA if you run the "1H/Daily" in the WPR. Or the 50 EMA if you run the Daily 4H. 

This system could be used on lower timeframes too but I have not tested it there.
The Dual WPR indicator, the colour changing 50 EMA and Heiken Ashi have been optimised for the 4H/Daily. 

If you want to set alerts the the faster WPR line crossing the -50 is good, on candle close. 
This way you will only need one alert per chart. 
If you get an alert on the EURUSD 4H that the 4H WPR has crossed up then look to see what what the Daily WPR is doing. If it is also above the -50 mid line then EURUSD is probably trending up. 

Thank you to TradingView for supplying the Williams %r template. 
I hope this helps some other traders out there. 
I combined the Supertrend and the Coloured EMA in the main screen into one indicator.
This is my first indicator published  :-)
Have fun out there and good luck.
Eddie T.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CryptoManiacICO
// This code used the code from the stock Willimas%r provided bt TradingView. 
// Acknowlegment to TradingView  

//@version=5
indicator("Dual Timeframe Williams Percent Range", shorttitle="Dual %R", format=format.price, precision=2)

// Input for first Williams %R line
length1 = input.int(14, title="Length 1")
src1 = input(close, title="Source 1")
timeframe1 = input.timeframe("", title="Timeframe 1")
smoothing1 = input.int(1, title="Smoothing Factor 1", minval=1, maxval=10)
colorAbove1 = input.color(color.green, title="Color Above -50 Line 1")
colorBelow1 = input.color(color.red, title="Color Below -50 Line 1")
lineWidth1 = input.int(2, title="Line Width 1", minval=1)

// Input for second Williams %R line
length2 = input.int(14, title="Length 2")
src2 = input(close, title="Source 2")
timeframe2 = input.timeframe("", title="Timeframe 2")
smoothing2 = input.int(1, title="Smoothing Factor 2", minval=1, maxval=10)
colorAbove2 = input.color(color.blue, title="Color Above -50 Line 2")
colorBelow2 = input.color(color.orange, title="Color Below -50 Line 2")
lineWidth2 = input.int(2, title="Line Width 2", minval=1)

// Function to calculate Williams %R
_pr(src, length, smoothFactor) =>
    max = ta.highest(src, length)
    min = ta.lowest(src, length)
    100 * (src - max) / (max - min)

// Calculate Williams %R for both timeframes with smoothing
percentR1 = ta.sma(request.security(syminfo.tickerid, timeframe1, _pr(src1, length1, smoothing1)), smoothing1)
percentR2 = ta.sma(request.security(syminfo.tickerid, timeframe2, _pr(src2, length2, smoothing2)), smoothing2)

// Determine the color based on crossing the -50 line
colorR1 = percentR1 > -50 ? colorAbove1 : colorBelow1
colorR2 = percentR2 > -50 ? colorAbove2 : colorBelow2

// Draw the Williams %R lines
plot(percentR1, title="%R 1", color=colorR1, linewidth=lineWidth1)
plot(percentR2, title="%R 2", color=colorR2, linewidth=lineWidth2)

// Draw the static lines for overbought/oversold and middle
hline(-20, title="Upper Band", color=#787B86)
hline(-50, title="Middle Level", linestyle=hline.style_dotted, color=#787B86)
hline(-80, title="Lower Band", color=#787B86)
````
