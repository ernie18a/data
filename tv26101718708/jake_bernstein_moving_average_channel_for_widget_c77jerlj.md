# Jake Bernstein - Moving Average Channel for widget

- url: https://www.tradingview.com/script/c77jerlj-Jake-Bernstein-Moving-Average-Channel-for-widget/
- type: indicator
- pine_id: PUB;0c9ea0a7248d4179a5aa3dee54092e6f
- version: 1.0

## Description

We all know that moving averages, in particular, moving averages of closing prices tend to be highly inaccurate indicators and frequently miss major tops and bottoms. In backtesting, they tend to be accurate some 30 to 40% of the time which is to my way of thinking unacceptable. On the contrary moving averages of opens versus closes for highs versus lows, when used properly avoid the drawbacks of closing moving averages, particularly when combined with a trigger. Shown above is my moving average channel method which uses the 57 SMA of Williams accumulation distribution as a setup or trigger. As shown by the arrows two consecutive price bars completely below the MA channel low and triggered by Williams below SMA constitutes a sell signal. Conversely, two consecutive price bars or more above the moving average channel high accompanied by Williams above its moving average constitutes a sell trigger. The moving average channel high, the red line is a 10 period Moving average of highs. The Moving average channel low, the green line is an 8 period Moving average of the low. There are at least a dozen applications of this methodology including its ability to spot trend changes, support, resistance, swing trades, market strength, market weakness, and more. I will post some of these additional uses of the moving average channel as they present themselves. Do note that in this chart there were two instances above the moving average channel high but these were not triggered by Williams AD and therefore the trend remains down for the duration of this chart. The methodology associated with my MAC is completely rules-based and works in any timeframe. Thank you my friend Larry Williams for developing your excellent version of accumulation-distribution

## Source Code

````pine
//@version=6
indicator(title="Jake Bernstein - Moving Average Channel", shorttitle="MAC", overlay=true, precision=2)

jbRed = #D00000
jbGreen = #39A742
jbOrange = #FF9505
jbPurple = #5F56B3
jbGray = #888888

low8 = ta.sma(source=low, length=8)
high10 = ta.sma(source=high, length=10)

lowSeries = barstate.isconfirmed ? low8 : na
highSeries = barstate.isconfirmed ? high10 : na

barAbove = high10 < low
barBelow = high < low8

barsAbove = ta.barssince(not barAbove)
barsBelow = ta.barssince(not barBelow)

above2() => barstate.isconfirmed and barsAbove == 2
above5() => barstate.isconfirmed and barsAbove == 5

below2() => barstate.isconfirmed and barsBelow == 2
below5() => barstate.isconfirmed and barsBelow == 5
    
color3 = if (above5())
    jbPurple
else if (above2())
    jbGreen
else if (below5())
    jbOrange
else if (below2())
    jbRed
else
    na

color2 = if (above5())
    jbPurple
else if (below5())
    jbOrange
else
    na

color1 = if (above5())
    jbGreen
else if (below5())
    jbRed
else
    na

low8Plot = plot(series=lowSeries, title="8 Low", linewidth=4, color=jbGreen)
high10Plot = plot(series=highSeries, title="10 High", linewidth=4, color=jbRed)

fill(plot1=low8Plot, plot2=high10Plot, color=color.new(color=jbGray, transp=85), title="Fill")

barcolor(color=color1, offset=-4)
barcolor(color=color1, offset=-3)
barcolor(color=color2, offset=-2)
barcolor(color=color3, offset=-1)
barcolor(color=color3, offset=0)
````
