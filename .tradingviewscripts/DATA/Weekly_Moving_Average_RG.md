<!-- tradingview-pine-id: PUB;7d67bc3a1da74907988314dd528c67f8 -->
<!-- tradingviewscripts-format: 1 -->
# Weekly Moving Average RG

Source: https://www.tradingview.com/script/7yt0O0dr-Weekly-Moving-Average-RG/

## Description

WMA with green and red line.  If green and flat followed by green vertical a green triangle appears to indicate a possible buy time.  The only time the buy signal appears is when the MA is flat then ascends.  

I sell anytime a red line appears if holding the stock or ETF.

---

## Source Code

````pine
//@version=6
indicator(title="Weekly Moving Average RG", shorttitle="Weekly MA RG", overlay=true)

len = input.int(2, "MA Length", minval=1)
src = input.source(close, "Source")

ma = request.security(syminfo.tickerid, "W", ta.sma(src, len), lookahead=barmerge.lookahead_off)

isUp   = ma > ma[1]
isFlat = ma == ma[1]
isDown = ma < ma[1]

// Single continuous line
plot(ma, "Weekly MA", color = isDown ? color.red : color.green, linewidth=3)

// Triangle ONLY when previous bar was flat and current bar turns upward
// Explicitly excludes any flat → down (red) transition
transitionUp = isUp and isFlat[1] and not isDown

plotshape(transitionUp ? ma : na, 
     title="Flat → Rising Transition", 
     style=shape.triangleup, 
     location=location.absolute, 
     color=color.green, 
     size=size.small)
````
