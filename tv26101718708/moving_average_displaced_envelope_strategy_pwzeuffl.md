# Moving Average Displaced Envelope Strategy

- url: https://www.tradingview.com/script/PwzEUFfL-Moving-Average-Displaced-Envelope-Strategy/
- type: indicator
- pine_id: PUB;a2NHtAZxCIkzNAeTPFmfBpHuhpDRyYE1
- version: 1.0

## Description

Moving Average Displaced Envelope. These envelopes are calculated 
 by multiplying percentage factors with their displaced expotential 
 moving average (EMA) core.
 How To Trade Using:
 Adjust the envelopes percentage factors to control the quantity and 
 quality of the signals. If a previous high goes above the envelope 
 a sell signal is generated. Conversely, if the previous low goes below 
 the envelope a buy signal is given.

 WARNING:
 - For purpose educate only
 - This script to change bars colors.

## Source Code

````pine
//@version=4
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 11/08/2020
// Moving Average Displaced Envelope. These envelopes are calculated 
// by multiplying percentage factors with their displaced expotential 
// moving average (EMA) core.
// How To Trade Using:
// Adjust the envelopes percentage factors to control the quantity and 
// quality of the signals. If a previous high goes above the envelope 
// a sell signal is generated. Conversely, if the previous low goes below 
// the envelope a buy signal is given.
//
// WARNING:
// - For purpose educate only
// - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Moving Average Displaced Envelope Strategy", shorttitle="MA DE", overlay = true)
Price = input(title="Source", type=input.source, defval=close)
Period =input(defval=9, minval=1)
perAb = input(title = "Percent above", defval=.5, minval=0.01)
perBl = input(title = "Percent below", defval=.5, minval=0.01)
disp = input(title = "Displacement", defval=13, minval=1) 
pos = 0
sEMA = ema(Price, Period)
top = sEMA[disp] * ((100 + perAb)/100)
bott = sEMA[disp]* ((100 - perBl)/100)
pos := iff(close < bott , 1,
	     iff(close > top, -1, pos[1])) 
barcolor(pos == -1 ? #b50404: pos == 1 ? #079605 : #0536b3 )
plot(top, title='top', color=#b50404, linewidth=2, style=plot.style_line)
plot(bott, title='bott', color=#079605, linewidth=2, style=plot.style_line)
````
