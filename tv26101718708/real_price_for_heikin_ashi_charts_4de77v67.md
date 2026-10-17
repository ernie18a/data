# Real Price for Heikin Ashi Charts

- url: https://www.tradingview.com/script/4dE77v67-Real-Price-for-Heikin-Ashi-Charts/
- type: indicator
- pine_id: PUB;6VDSmllTQkPsLOVjxobjBMUruoXMwWGW
- version: 1.0

## Description

[b]The indicator is in the top left of the screen! That's all there is, by design.[/b]

This is a super simple indicator that allows you to see what the real price of a candle was when using Heikin Ashi charts, while not cluttering up your screen.

HA charts are a great way to help those who can be spooked by the chaos of the markets (I'm one!), but they have a big drawback in that the price you see on a HA candle is often significantly different from the real price that you would trade on. This brings issues of unrealistic expectations of profits/losses, and also makes back testing a strategy very difficult. I still wouldn't recommend ever using TradingView's "strategy" tool when using HA charts, but using this indicator you can do accurate manual back tests.

There's nothing plotted on the screen given that there's no real point in it, but you can make the lines appear if you wish - just go into settings and change the transparency. 

The order of the numbers on the indicator match the OHLC (Open, High, Low, Close) format.

There's also settings to turn off one or more of the OHLC values, simply open the settings and go to Inputs. This could be useful for some people, as the High and Low values of HA candles are the same as regular candles. Only the Open and Close are different.

Any queries let me know.

DreamsDefined

## Source Code

````pine
//@version=3

study("Real Price", overlay=true, precision=5)

so = input(true, "Show Open Price")
sh = input(true, "Show High Price")
sl = input(true, "Show Low Price")
sc = input(true, "Show Close Price")

op = so ? security(tickerid(syminfo.prefix, ticker), period, open) :  na
hi = sh ? security(tickerid(syminfo.prefix, ticker), period, high) : na
lo = sl ? security(tickerid(syminfo.prefix, ticker), period, low) : na
cl = sc ? security(tickerid(syminfo.prefix, ticker), period, close) : na

plot(op, linewidth=4, transp=100) 
plot(hi, linewidth=4, transp=100) 
plot(lo, linewidth=4, transp=100) 
plot(cl, linewidth=4, transp=100)
````
