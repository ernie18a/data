# RSI based on ROC Strategy

- url: https://www.tradingview.com/script/00ad9wy9-RSI-based-on-ROC-Strategy/
- type: indicator
- pine_id: PUB;qVJWhKPPHOwphpnl8kqd1MirZ0k2DWQp
- version: 1.0

## Description

This is the new-age indicator which is version of RSI calculated upon 
 the Rate-of-change indicator.
 The name "Relative Strength Index" is slightly misleading as the RSI 
 does not compare the relative strength of two securities, but rather 
 the internal strength of a single security. A more appropriate name 
 might be "Internal Strength Index." Relative strength charts that compare 
 two market indices, which are often referred to as Comparative Relative Strength.
 And in its turn, the Rate-of-Change ("ROC") indicator displays the difference 
 between the current price and the price x-time periods ago. The difference can 
 be displayed in either points or as a percentage. The Momentum indicator displays 
 the same information, but expresses it as a ratio.

 WARNING:
 - This script to change bars colors.

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 27/10/2017
// This is the new-age indicator which is version of RSI calculated upon 
// the Rate-of-change indicator.
// The name "Relative Strength Index" is slightly misleading as the RSI 
// does not compare the relative strength of two securities, but rather 
// the internal strength of a single security. A more appropriate name 
// might be "Internal Strength Index." Relative strength charts that compare 
// two market indices, which are often referred to as Comparative Relative Strength.
// And in its turn, the Rate-of-Change ("ROC") indicator displays the difference 
// between the current price and the price x-time periods ago. The difference can 
// be displayed in either points or as a percentage. The Momentum indicator displays 
// the same information, but expresses it as a ratio.
//
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="RSI based on ROC", shorttitle="RSI/ROC")
RSILength = input(20, minval=1)
ROCLength = input(20, minval=1)
BuyZone = input(30, minval=1)
SellZone = input(70, minval=1)
xPrice = close
hline(SellZone, color=red, linestyle=line, title = "Upper")
hline(BuyZone, color=green, linestyle=line, title = "Lower")
nRes = rsi(roc(xPrice,ROCLength),RSILength)
pos = iff(nRes < BuyZone, -1,
	    iff(nRes > SellZone, 1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(nRes, color=blue, title="RSI/ROC")
````
