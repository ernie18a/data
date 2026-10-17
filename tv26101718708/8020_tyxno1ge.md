# 80-20

- url: https://www.tradingview.com/script/Tyxno1gE-80-20/
- type: strategy
- pine_id: PUB;3ce6e1e12c2c4b6ea15c23895d4ba1d4
- version: 1.0

## Description

Indicator which shows candles which have open or close in top or bottom 20% of the range.

## Source Code

````pine
//@version=5
//FxLowe - NR4 & NR7.

strategy(title = "80-20", overlay = true)
twenty = 0.2 * ( high - low)
triggerGreen = ((close >= high-twenty)) and ((open <= low+twenty))
triggerRed = (open >= high-twenty) and (close <= low+twenty)

//barcolor( trigger ? blue : na, offset = 0, editable = true, title = "trigger")
plotshape(triggerGreen, title= "triggerGreen", location=location.abovebar, color=color.blue, style=shape.arrowdown, text="")
plotshape(triggerRed, title= "triggerRed", location=location.abovebar, color=color.red, style=shape.arrowdown, text="")
````
