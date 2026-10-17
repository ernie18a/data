# Fractal Chaos Bands Strategy

- url: https://www.tradingview.com/script/vN8vXkuh-Fractal-Chaos-Bands-Strategy/
- type: indicator
- pine_id: PUB;ky9GdKU3phhycmxhzfVbqXKYd9VX2f6a
- version: 1.0

## Description

Stock market moves in a highly chaotic way, but at a larger scale, the movements 
 follow a certain pattern that can be applied to shorter or longer periods of time 
 and we can use Fractal Chaos Bands Indicator to identify those patterns. Basically, 
 the Fractal Chaos Bands Indicator helps us to identify whether the stock market is 
 trending or not. When a market is trending, the bands will have a slope and if market 
 is not trending the bands will flatten out. As the slope of the bands decreases, it 
 signifies that the market is choppy, insecure and variable. As the graph becomes more 
 and more abrupt, be it going up or down, the significance is that the market becomes 
 trendy, or stable. Fractal Chaos Bands Indicator is used similarly to other bands-indicator 
 (Bollinger bands for instance), offering trading opportunities when price moves above or 
 under the fractal lines.

 The FCB indicator looks back in time depending on the number of time periods trader selected 
 to plot the indicator. The upper fractal line is made by plotting stock price highs and the 
 lower fractal line is made by plotting stock price lows. Essentially, the Fractal Chaos Bands 
 show an overall panorama of the price movement, as they filter out the insignificant fluctuations 
 of the stock price.

 WARNING:
 - This script to change bars colors.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 16/02/2018
//  Stock market moves in a highly chaotic way, but at a larger scale, the movements 
// follow a certain pattern that can be applied to shorter or longer periods of time 
// and we can use Fractal Chaos Bands Indicator to identify those patterns. Basically, 
// the Fractal Chaos Bands Indicator helps us to identify whether the stock market is 
// trending or not. When a market is trending, the bands will have a slope and if market 
// is not trending the bands will flatten out. As the slope of the bands decreases, it 
// signifies that the market is choppy, insecure and variable. As the graph becomes more 
// and more abrupt, be it going up or down, the significance is that the market becomes 
// trendy, or stable. Fractal Chaos Bands Indicator is used similarly to other bands-indicator 
// (Bollinger bands for instance), offering trading opportunities when price moves above or 
// under the fractal lines.
//
// The FCB indicator looks back in time depending on the number of time periods trader selected 
// to plot the indicator. The upper fractal line is made by plotting stock price highs and the 
// lower fractal line is made by plotting stock price lows. Essentially, the Fractal Chaos Bands 
// show an overall panorama of the price movement, as they filter out the insignificant fluctuations 
// of the stock price.
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

study(title="Fractal Chaos Bands", overlay = true)
Pattern = input(1, minval=1)
xUpper = fractalUp(Pattern)
xLower = fractalDn(Pattern)
pos = iff(close > xUpper, 1,
       iff(close < xLower, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue ) 
plot(xUpper, color=red, title="FCBUp")
plot(xLower, color=green, title="FCBDn")
````
