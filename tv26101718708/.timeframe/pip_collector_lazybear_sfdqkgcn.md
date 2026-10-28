# Pip collector [LazyBear]

- url: https://www.tradingview.com/script/sfdQKGCn-Pip-collector-LazyBear/
- type: indicator
- pine_id: PUB;1235
- version: -1.0

## Description

A simple but effective Forex strategy requested by user @pipcollector. 

Suggested chart timeframe is 5mins. 

Indicator marks potential long/short entries based on the following conditions:

LONG
------
[list]
[*] Price above pip median ema on daily, 4 hour and 1 hour timeframe. These 3 timeframes and median EMA lengths are configurable. 
[*] Background color is set to GREEN (if option is enabled). 
[*] As soon as price touches or crosses the median ema, a GREEN arrow is shown to mark potential long. 
[/list]

SHORT
------
[list]
[*] Price below pip median ema on daily, 4 hour and 1 hour timeframe. These 3 timeframes and median EMA lengths are configurable. 
[*] Background color is set to RED (if option is enabled). 
[*] As soon as price touches or crosses the median ema, a RED arrow is shown to mark potential short. 
[/list]

NO SETUP
-----------
[list]
[*] Moving averages do not align on the 3 timeframes.
[*] Background color is set to GRAY (if option is enabled)
[/list]

I have noticed that this works well on other instruments too (anything trending), also on higher time frames. Feel free to leave any questions/comments on this below. 

List of my public indicators: http://bit.ly/1LQaPK8 
List of my app-store indicators: http://blog.tradingview.com/?p=970

## Source Code

````pine
//
// @author LazyBear 
// 
// List of my public indicators: http://bit.ly/1LQaPK8 
// List of my app-store indicators: http://blog.tradingview.com/?p=970 
//
study("Pip collector [LazyBear]", shorttitle="PIPCOLL_LB", overlay=true, precision=6)
src=input(close, title="Source")
tf1=input("D", title="Timeframe 1"), tf2=input("240", title="Timeframe 2"), tf3=input("60", title="Timeframe 3")
lengthCenter=input(50, title="Center EMA Length")
lengthLower=input(20, title="Distance of lower line from center (pips)")
lengthUpper=input(20, title="Distance of upper line from center (pips)")
showBGColor=input(false, title="Background color on all EMA synch?")
pip=syminfo.mintick 
ltfsrc=ema(src, lengthCenter) < src
stfsrc=ema(src, lengthCenter) > src
ltf1=security(tickerid, tf1, ltfsrc), stf1=security(tickerid, tf1, stfsrc)
ltf2=security(tickerid, tf2, ltfsrc), stf2=security(tickerid, tf2, stfsrc)
ltf3=security(tickerid, tf3, ltfsrc), stf3=security(tickerid, tf3, stfsrc)
ctfsrc=ema(src,lengthCenter), ctfsrcl=ctfsrc-lengthLower*pip, ctfsrcu=ctfsrc+lengthLower*pip
long=ltf1 and ltf2 and ltf3 
short=stf1 and stf2 and stf3 
plot(ctfsrc, color=blue, linewidth=2, title="Center EMA")
plot(ctfsrcl, color=red, linewidth=2, title="Lower")
plot(ctfsrcu, color=green, linewidth=2, title="Upper")
inrange(x)=>(x>=low and x<=high)
plotarrow(long and ((src==ctfsrc) or cross(src, ctfsrc) or (inrange(ctfsrc)))?low:na, maxheight=30, title="Buy Arrow",  colorup=lime)
plotarrow(short and ((src==ctfsrc) or cross(src, ctfsrc) or (inrange(ctfsrc)))?-high:na, maxheight=30, title="Buy Arrow",  colordown=red)
bgcolor(showBGColor?(ltf1 and ltf2 and ltf3)?green:(stf1 and stf2 and stf3)?red:black:na, transp=85)
````
