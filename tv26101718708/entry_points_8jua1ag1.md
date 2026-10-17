# Entry points

- url: https://www.tradingview.com/script/8jUa1ag1-Entry-points/
- type: indicator
- pine_id: PUB;1034
- version: -1.0

## Description

This great and simple indicator based on EMA generates information about entry points at close of the candle. First signal is the best entry point but you can re-enter at the next. IMPORTANT: this script does not generate exit signals and those shoud be find using money management rules or else. Perfectly catches long runs in trends at all underlayings (forex, stocks, indexes, commodities) at all timeframes. Period=100 works best independently on timeframe but I encourage you to try other. Lower period gives more incorrect signals and shorter runs, higher period gives you late entry and less. Ofcourse it gives false signals from time to time but fortunately it makes a correction very fast. Try it! Good luck and good traiding!

## Source Code

````pine
study("Entry points", overlay=true)
r=input(100, title="Period", type=integer, minval=1)
b=ema(close,r)
buy=close>b and low<=b and open>b or open<b and close>b
sell=close<b and high>=b and open<b or open>b and close<b
plotshape(buy, color=green, location=location.belowbar, style=shape.arrowup, transp=10, text="Buy")
plotshape(sell, color=red, location=location.abovebar, style=shape.arrowdown, transp=10, text="Sell")
````
