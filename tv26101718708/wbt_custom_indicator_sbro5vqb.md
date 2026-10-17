# WBT Custom Indicator

- url: https://www.tradingview.com/script/sBro5VqB-WBT-Custom-Indicator/
- type: indicator
- pine_id: PUB;90240a21be9445c88df1e0cb68762fc9
- version: 1.0

## Description

EMA based system - fast and easy to use 

A combination of slow and fast moving averages, made into one simple line to keep your chart clutter free. 

Also has buy/sell signals as an option 

Does not work below 1hr

## Source Code

````pine
//@version=6
indicator("WBT Clean EMA System", overlay=true)

ema21 = ta.ema(close, 21)
ema55 = ta.ema(close, 55)
ema200 = ta.ema(close, 200)

showTrend = timeframe.period == "60" or timeframe.period == "240"
show200 = timeframe.isdaily or timeframe.isweekly

ema55Color = ema55 > ema55[1] ? color.lime : color.red

plot(ema21, title="21 EMA", color=color.gray, linewidth=1, display=display.none)

plot(showTrend ? ema55 : na, title="55 EMA", color=ema55Color, linewidth=1)

plot(show200 ? ema200 : na, title="200 EMA", color=color.purple, linewidth=4)

bullCross = ta.crossover(ema21, ema55)
bearCross = ta.crossunder(ema21, ema55)

plotshape(showTrend and bullCross, title="BUY", style=shape.circle, location=location.belowbar, color=color.lime, size=size.small)

plotshape(showTrend and bearCross, title="SELL", style=shape.circle, location=location.abovebar, color=color.red, size=size.small)

alertcondition(showTrend and bullCross, title="Bullish EMA Cross", message="BUY: 21 EMA crossed ABOVE 55 EMA")

alertcondition(showTrend and bearCross, title="Bearish EMA Cross", message="SELL: 21 EMA crossed BELOW 55 EMA")
````
