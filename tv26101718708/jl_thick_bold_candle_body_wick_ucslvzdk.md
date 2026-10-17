# JL - Thick Bold Candle Body & Wick

- url: https://www.tradingview.com/script/UcSlvzDk-JL-Thick-Bold-Candle-Body-Wick/
- type: indicator
- pine_id: PUB;3f1024fb848e46c381a7a1cecf16b335
- version: 1.0

## Description

This indicator draws a thick line for the candle body and a thinner line for the candle wick, with adjustable inputs for thickness and colors, so we can create bigger candles than what is currently available on trading view.  To me, the candles are not easy to see, I wish the thickness was adjustable but it isn't, so this indicator takes care of that issue.

Unfortunately, there is a 500 line limit for trading view and therefor this indicator can only draw the past 250 candles.   

Currently, there is no other way to adjust the thickness of candles on trading view and this is a good work around until there is a feature.

## Source Code

````pine
//@version=6
indicator("JL - Thick Bold Candle Body & Wick", overlay=true, max_lines_count=500)

// Inputs
BodyThickness = input.int(9, "Body Thickness", minval=1, maxval=20)
WickThickness = input.int(3, "Wick Thickness", minval=1, maxval=10)

BullBodyColor = input.color(color.rgb(0, 204, 8), "Bull Bar Body Color")
BearBodyColor = input.color(color.rgb(242, 54, 69), "Bear Bar Body Color")

BullWickColor = input.color(color.rgb(0, 204, 8), "Bull Bar Wick Color")
BearWickColor = input.color(color.rgb(242, 54, 69), "Bear Bar Wick Color")

DojiColor = input.color(color.rgb(0, 0, 0), "Doji Color")

// Bar type
BullBar = close > open
BearBar = close < open
DojiBar = close == open

BodyColor = BullBar ? BullBodyColor : BearBar ? BearBodyColor : DojiColor
WickColor = BullBar ? BullWickColor : BearBar ? BearWickColor : DojiColor

// Body values
BodyTop =
     DojiBar ? close + syminfo.mintick / 2 :
     BullBar ? close :
     open + syminfo.mintick

BodyBottom =
     DojiBar ? close - syminfo.mintick / 2 :
     BullBar ? open - syminfo.mintick :
     close - syminfo.mintick

// Draw wick first
line.new(
     x1=bar_index,
     y1=high,
     x2=bar_index,
     y2=low,
     xloc=xloc.bar_index,
     color=WickColor,
     width=WickThickness)

// Draw body on top of wick
line.new(
     x1=bar_index,
     y1=BodyBottom,
     x2=bar_index,
     y2=BodyTop,
     xloc=xloc.bar_index,
     color=BodyColor,
     width=BodyThickness)
````
