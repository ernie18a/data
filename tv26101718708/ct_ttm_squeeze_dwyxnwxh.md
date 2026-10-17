# CT TTM Squeeze

- url: https://www.tradingview.com/script/dwyXnWxh-CT-TTM-Squeeze/
- type: strategy
- pine_id: PUB;BjqvXKwsVrEGs19gaGLv5IfaSwLg05DO
- version: 1.0

## Description

yeet

## Source Code

````pine
//@version=2
strategy("CT TTM Squeeze") 
length = input(title="Length", type=integer, defval=20, minval=0) 
bband(length, mult) =>
	sma(close, length) + mult * stdev(close, length)
keltner(length, mult) =>
	ema(close, length) + mult * ema(tr, length)
	
	
// Variables
e1 = (highest(high, length) + lowest(low, length)) / 2 + sma(close, length)
osc = linreg(close - e1 / 2, length, 0)
diff = bband(length, 2) - keltner(length, 1)
osc_color = osc[1] < osc[0] ? osc[0] >= 0 ? #00ffff : #cc00cc : osc[0] >= 0 ? #009b9b : #ff9bff
mid_color = diff >= 0 ? green : red

// Strategy

long = osc > 0
short = osc < 0

if long
    strategy.entry("Long", strategy.long)

if short
    strategy.entry("Short", strategy.short) 


plot(osc, color=osc_color, style=histogram, linewidth=2)
plot(0, color=mid_color, style=circles, linewidth=3)
````
