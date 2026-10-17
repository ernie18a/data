# ECO Strategy

- url: https://www.tradingview.com/script/8srmqiZM-ECO-Strategy/
- type: indicator
- pine_id: PUB;360
- version: -1.0

## Description

We call this one the ECO for short, but it will be listed on the indicator list 
    at W. Blau’s Ergodic Candlestick Oscillator. The ECO is a momentum indicator. 
    It is based on candlestick bars, and takes into account the size and direction 
    of the candlestick "body". We have found it to be a very good momentum indicator, 
    and especially smooth, because it is unaffected by gaps in price, unlike many other 
    momentum indicators.
    We like to use this indicator as an additional trend confirmation tool, or as an 
    alternate trend definition tool, in place of a weekly indicator. The simplest way 
    of using the indicator is simply to define the trend based on which side of the "0" 
    line the indicator is located on. If the indicator is above "0", then the trend is up. 
    If the indicator is below "0" then the trend is down. You can add an additional 
    qualifier by noting the "slope" of the indicator, and the crossing points of the slow 
    and fast lines. Some like to use the slope alone to define trend direction. If the 
    lines are sloping upward, the trend is up. Alternately, if the lines are sloping 
    downward, the trend is down. In this view, the point where the lines "cross" is the 
    point where the trend changes.
    When the ECO is below the "0" line, the trend is down, and we are qualified only to 
    sell on new short signals from the Hi-Lo Activator. In other words, when the ECO is 
    above 0, we are not allowed to take short signals, and when the ECO is below 0, we 
    are not allowed to take long signals.

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 05/08/2014
// We call this one the ECO for short, but it will be listed on the indicator list 
// at W. Blau’s Ergodic Candlestick Oscillator. The ECO is a momentum indicator. 
// It is based on candlestick bars, and takes into account the size and direction 
// of the candlestick "body". We have found it to be a very good momentum indicator, 
// and especially smooth, because it is unaffected by gaps in price, unlike many other 
// momentum indicators.
// We like to use this indicator as an additional trend confirmation tool, or as an 
// alternate trend definition tool, in place of a weekly indicator. The simplest way 
// of using the indicator is simply to define the trend based on which side of the "0" 
// line the indicator is located on. If the indicator is above "0", then the trend is up. 
// If the indicator is below "0" then the trend is down. You can add an additional 
// qualifier by noting the "slope" of the indicator, and the crossing points of the slow 
// and fast lines. Some like to use the slope alone to define trend direction. If the 
// lines are sloping upward, the trend is up. Alternately, if the lines are sloping 
// downward, the trend is down. In this view, the point where the lines "cross" is the 
// point where the trend changes.
// When the ECO is below the "0" line, the trend is down, and we are qualified only to 
// sell on new short signals from the Hi-Lo Activator. In other words, when the ECO is 
// above 0, we are not allowed to take short signals, and when the ECO is below 0, we 
// are not allowed to take long signals. 
////////////////////////////////////////////////////////////
study(title="ECO Strategy", shorttitle="ECO")
r = input(32, minval=1)
s = input(12, minval=1)
hline(0, color=purple, linestyle=dashed)
xCO = close - open
xHL = high - low
xEMA = ema(ema(xCO, r), s)
xvEMA = ema(ema(xHL, r), s)
nRes = 100 * (xEMA / xvEMA)
pos =	iff(nRes > 0, 1,
	    iff(nRes <= 0, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(nRes, color=blue, title="ECO")
````
