# MovROC (KST indicator)

- url: https://www.tradingview.com/script/UTAghK9h-MovROC-KST-indicator/
- type: indicator
- pine_id: PUB;gez2cBPz1ojfr2JSm7Rasu0vaUxzZgg4
- version: 1.0

## Description

This indicator really is the KST indicator presented by Martin Pring. 
 the KST indicator is a weighted summed rate of change oscillator that 
 is designed to identify meaningful turns. Various smoothed rate of change 
 indicators can be combined to form different measurements of cycles.

 WARNING:
  This script to change bars colors.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 19/09/2017
// This indicator really is the KST indicator presented by Martin Pring. 
// the KST indicator is a weighted summed rate of change oscillator that 
// is designed to identify meaningful turns. Various smoothed rate of change 
// indicators can be combined to form different measurements of cycles.
//
// WARNING:
//  This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="MovROC (KST indicator)", shorttitle="MovROC (KST indicator)")
hline(0, color=purple, linestyle=line)
xROC6 = sma(roc(close, 6), 10)
xROC10 = sma(roc(close, 10), 10)
xROC15 = sma(roc(close, 15), 9)
xROC20 = sma(roc(close, 20), 15)
nRes = xROC6 + (2 * xROC10) + (3 * xROC15) + (4 * xROC20)
pos = iff(nRes > 0, 1,
	   iff(nRes < 0, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue)
plot(nRes, color=blue, title="MovROC (KST indicator)")
````
