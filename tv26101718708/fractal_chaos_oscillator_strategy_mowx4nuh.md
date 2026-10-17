# Fractal Chaos Oscillator Strategy

- url: https://www.tradingview.com/script/MOwx4nuh-Fractal-Chaos-Oscillator-Strategy/
- type: indicator
- pine_id: PUB;NTeUv9CX6h5TlLBBKD80el3OrWsbmaDs
- version: 1.0

## Description

The value of Fractal Chaos Oscillator is calculated as the difference between 
 the most subtle movements of the market. In general, its value moves between 
 -1.000 and 1.000. The higher the value of the Fractal Chaos Oscillator, the 
 more one can say that it follows a certain trend – an increase in prices trend, 
 or a decrease in prices trend.

   Being an indicator expressed in a numeric value, traders say that this is an 
 indicator that puts a value on the trendiness of the markets. When the FCO reaches 
 a high value, they initiate the “buy” operation, contrarily when the FCO reaches a 
 low value, they signal the “sell” action. This is an excellent indicator to use in 
 intra-day trading.

 WARNING:
 - This script to change bars colors.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 21/02/2018
//   The value of Fractal Chaos Oscillator is calculated as the difference between 
// the most subtle movements of the market. In general, its value moves between 
// -1.000 and 1.000. The higher the value of the Fractal Chaos Oscillator, the 
// more one can say that it follows a certain trend – an increase in prices trend, 
// or a decrease in prices trend.
//
//   Being an indicator expressed in a numeric value, traders say that this is an 
// indicator that puts a value on the trendiness of the markets. When the FCO reaches 
// a high value, they initiate the “buy” operation, contrarily when the FCO reaches a 
// low value, they signal the “sell” action. This is an excellent indicator to use in 
// intra-day trading.
//
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
fractalUp(pattern) =>
    p = high[pattern+1]
    okl = 1
    okr = 1
	for i = pattern to 1
		okl := iff(high[i] < high[i+1] and okl == 1 , 1, 0)
	for i = pattern+2 to pattern*2+1
		okr := iff(high[i] < high[i-1] and okr == 1, 1, 0)
	res = iff(okl == 1 and okr == 1, p, res[1])
    res

fractalDn(pattern) =>
    p = low[pattern+1]
    okl = 1
    okr = 1
	for i = pattern to 1
		okl := iff(low[i] > low[i+1] and okl == 1 , 1, 0)
	for i = pattern+2 to pattern*2+1
		okr := iff(low[i] > low[i-1] and okr == 1, 1, 0)
	res = iff(okl == 1 and okr == 1, p, res[1])
    res

study(title="Fractal Chaos Oscillator", overlay = false)
Pattern = input(1, minval=1)
xUpper = fractalUp(Pattern)
xLower = fractalDn(Pattern)
xRes = iff(xUpper != xUpper[1], 1, 
         iff(xLower != xLower[1], -1, 0))
pos = iff(xRes == 1, 1,
       iff(xRes == -1, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )          
plot(xRes, color=blue, title="FCO")
````
