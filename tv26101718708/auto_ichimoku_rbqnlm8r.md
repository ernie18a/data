# Auto Ichimoku

- url: https://www.tradingview.com/script/RBQNLm8R-Auto-Ichimoku/
- type: strategy
- pine_id: PUB;SyQwEqM4K4ccoVk0BJLq4LQS3Vq7Hj1W
- version: 1.0

## Description

A strategy where entries are calculated for you using the Ichimoku Cloud. The IC isn't plotted though, just a heads up.

## Source Code

````pine
//@version=4
strategy(title="Auto Ichimoku", shorttitle="Ichimoku", overlay=true)

conversionPeriods = input(9, minval=1, title="Conversion Line Periods"),
basePeriods = input(26, minval=1, title="Base Line Periods")
laggingSpan2Periods = input(52, minval=1, title="Lagging Span 2 Periods"),
displacement = input(26, minval=1, title="Displacement")

donchian(len) => avg(lowest(len), highest(len))

conversionLine = donchian(conversionPeriods)
baseLine = donchian(basePeriods)
leadLine1 = avg(conversionLine, baseLine)
leadLine2 = donchian(laggingSpan2Periods)
lagging_span = close

//conditions 4 Longs
cloud_condition_long = close >= leadLine1 or close >= leadLine2
cloud_condition_2_long = leadLine1 >= leadLine2
conversion_condition_long = crossover(conversionLine,baseLine)
lagging_condition_long = lagging_span > leadLine1[displacement] or lagging_span > leadLine2[displacement]

//conditions for Shorts
cloud_condition_short = close <= leadLine1 or close <= leadLine2
cloud_condition_2_short = leadLine1 <= leadLine2
conversion_condition_short = crossunder(conversionLine,baseLine+1)
lagging_condition_short = lagging_span < leadLine1[displacement] or lagging_span < leadLine2[displacement]
//entries
longentry = conversion_condition_long and cloud_condition_long and cloud_condition_2_long and lagging_condition_long
shortentry = conversion_condition_short and cloud_condition_short and cloud_condition_2_short and lagging_condition_short
//entry plots
plotshape(longentry, color = color.green, text = "Long", style = shape.labelup, location = location.belowbar)
plotshape(shortentry, color = color.red, text = "Short", style = shape.labeldown, location = location.abovebar)
````
