# Precision Boundary Breakout

- url: https://www.tradingview.com/script/uflEa3ub-Precision-Boundary-Breakout/
- type: indicator
- pine_id: PUB;30fe959b94b84dff905fbf61822846be
- version: 1.0

## Description

Precision Boundary Breakout is a momentum-based trend-following indicator designed to capture explosive price movements when the market breaks out of an established trading range.

## Source Code

````pine
//@version=6
indicator(title="Precision Boundary Breakout", shorttitle="DC", overlay=true, timeframe="", timeframe_gaps=true)
length = input.int(20, minval = 1)
offset = input.int(0, "Offset")
lower =  ta.lowest(close, length)
upper =  ta.highest(close, length)
basis =  math.avg(upper, lower)
plot(basis, "Basis", color = #FF6D00, offset = offset)
u = plot(upper, "Upper", color = #2962FF, offset = offset)
l = plot(lower, "Lower", color = #2962FF, offset = offset)
fill(u, l, color = color.rgb(33, 150, 243, 95), title = "Background")

// Buy and Sell Signals
buySignal  = ta.crossover(close, upper[1])
sellSignal = ta.crossunder(close, lower[1])

plotshape(buySignal,  title = "Buy",  location = location.belowbar, color = color.green, style = shape.labelup,   text = "BUY",  textcolor = color.white, size = size.small)
plotshape(sellSignal, title = "Sell", location = location.abovebar, color = color.red,   style = shape.labeldown, text = "SELL", textcolor = color.white, size = size.small)

alertcondition(buySignal,  title = "Buy Signal",  message = "Donchian Channel Buy - Price breached Upper Band")
alertcondition(sellSignal, title = "Sell Signal", message = "Donchian Channel Sell - Price breached Lower Band")
````
