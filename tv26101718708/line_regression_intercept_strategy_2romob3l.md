# Line Regression Intercept Strategy

- url: https://www.tradingview.com/script/2roMOB3L-Line-Regression-Intercept-Strategy/
- type: indicator
- pine_id: PUB;LPilxCPR8iNR0V7ZDdK00iVAltOX5zsv
- version: 2.0

## Description

Linear Regression Intercept is one of the indicators calculated by using the 
 Linear Regression technique. Linear regression indicates the value of the Y 
 (generally the price) when the value of X (the time series) is 0. Linear 
 Regression Intercept is used along with the Linear Regression Slope to create 
 the Linear Regression Line. The Linear Regression Intercept along with the Slope 
 creates the Regression line.

 WARNING:
 - This script to change bars colors.

## Source Code

````pine
//@version=4
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.1 30/05/2020
// Linear Regression Intercept is one of the indicators calculated by using the 
// Linear Regression technique. Linear regression indicates the value of the Y 
// (generally the price) when the value of X (the time series) is 0. Linear 
// Regression Intercept is used along with the Linear Regression Slope to create 
// the Linear Regression Line. The Linear Regression Intercept along with the Slope 
// creates the Regression line.
//
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Line Regression Intercept Strategy", overlay = true)
Length = input(14, minval=1)
xSeria = input(title="Source", type=input.source, defval=close)
xX = Length * (Length - 1) * 0.5
xDivisor = xX * xX - Length * Length * (Length - 1) * (2 * Length - 1) / 6
xXY = 0.0
pos = 0
for i = 0 to Length-1
	xXY := xXY + (i * xSeria[i])
xSlope = (Length * xXY - xX * sum(xSeria, Length)) / xDivisor
xLRI = (sum(xSeria, Length) - xSlope * xX) / Length
pos := iff(close > xLRI, 1,
         iff(close < xLRI, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? color.red: pos == 1 ? color.green : color.blue )
plot(xLRI, color=color.blue, title="LRI")
````
