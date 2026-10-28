# D_Three Ten Osc Strategy

- url: https://www.tradingview.com/script/H00cTHXb-D-Three-Ten-Osc-Strategy/
- type: indicator
- pine_id: PUB;NqwHGYXg5Ooqgo8rgS8x9rKZbxzWmCAM
- version: 1.0

## Description

This indicator allows the  user to plot a daily 3-10 Oscillator on a Tick Bar 
 Chart or any intraday interval.
 Walter Bressert's 3-10 Oscillator is a detrending oscillator derived 
 from subtracting a 10 day moving average from a 3 day moving average. 
 The second plot is an 16 day simple moving average of the 3-10 Oscillator. 
 The 16 period moving average is the slow line and the 3/10 oscillator is 
 the fast line.
 For more information on the 3-10 Oscillator see Walter Bressert's book 
 "The Power of Oscillator/Cycle Combinations"

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 24/03/2017
// TradeStation does not allow the user to make a Multi Data Chart with 
// a Tick Bar Chart and any other type a chart. This indicator allows the 
// user to plot a daily 3-10 Oscillator on a Tick Bar Chart or any intraday interval.
// Walter Bressert's 3-10 Oscillator is a detrending oscillator derived 
// from subtracting a 10 day moving average from a 3 day moving average. 
// The second plot is an 16 day simple moving average of the 3-10 Oscillator. 
// The 16 period moving average is the slow line and the 3/10 oscillator is 
// the fast line.
// For more information on the 3-10 Oscillator see Walter Bressert's book 
// "The Power of Oscillator/Cycle Combinations" 
////////////////////////////////////////////////////////////
study(title="D_Three Ten Osc", shorttitle="D_Three Ten Osc")
Length1 = input(3, minval=1)
Length2 = input(10, minval=1)
Length3 = input(16, minval=1)
hline(0, color=green, linestyle=line)
xPrice =  security(tickerid,"D", hl2)
xfastMA = ema(xPrice, Length1)
xslowMA = ema(xPrice, Length2)
xMACD = xfastMA - xslowMA
xSignal = sma(xMACD, Length3)
pos = iff(xSignal > xMACD, -1,
	     iff(xSignal < xMACD, 1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(security(tickerid, "D", xMACD), color=blue, title="D_Three Ten Osc")
plot(security(tickerid, "D", xSignal), color=red, title="D_Three Ave")
````
