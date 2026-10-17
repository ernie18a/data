# 8:30 Candle High & Low Berlin

- url: https://www.tradingview.com/script/Mu4OvLVf/
- type: indicator
- pine_id: PUB;7e97615496304017ad961071ace3fa3b
- version: 1.0

## Description

8:30 Candle High & Low Berlin 8:30 Candle High & Low Berlin 8:30 Candle High & Low Berlin 8:30 Candle High & Low Berlin 8:30 Candle High & Low Berlin 8:30 Candle High & Low Berlin 8:30 Candle High & Low Berlin 8:30 Candle High & Low Berlin 8:30 Candle High & Low Berlin 8:30 Candle High & Low Berlin 8:30 Candle High & Low Berlin 8:30 Candle High & Low Berlin 8:30 Candle High & Low Berlin v v v

## Source Code

````pine
//@version=6
indicator("8:30 Candle High & Low Berlin", overlay=true, max_lines_count=500, max_labels_count=500)

tz          = input.string("Europe/Berlin", "Timezone")
targetHour  = input.int(8, "Hour", minval=0, maxval=23)
targetMin   = input.int(30, "Minute", minval=0, maxval=59)
extendBars  = input.int(100, "Extend lines for X bars", minval=1)
showLabels  = input.bool(true, "Show labels")

isTargetCandle = hour(time, tz) == targetHour and minute(time, tz) == targetMin

if isTargetCandle and barstate.isconfirmed
    // High der 8:30 Candle
    line.new(
         bar_index, high,
         bar_index + extendBars, high,
         xloc=xloc.bar_index,
         color=color.new(color.green, 0),
         width=2
     )

    // Low der 8:30 Candle
    line.new(
         bar_index, low,
         bar_index + extendBars, low,
         xloc=xloc.bar_index,
         color=color.new(color.red, 0),
         width=2
     )

    if showLabels
        label.new(
             bar_index + extendBars, high,
             "8:30 High",
             style=label.style_label_left,
             textcolor=color.white,
             color=color.new(color.green, 0)
         )

        label.new(
             bar_index + extendBars, low,
             "8:30 Low",
             style=label.style_label_left,
             textcolor=color.white,
             color=color.new(color.red, 0)
         )
````
