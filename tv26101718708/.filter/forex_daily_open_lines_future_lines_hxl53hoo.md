# Forex Daily Open Lines + Future Lines

- url: https://www.tradingview.com/script/hxL53hOo-Forex-Daily-Open-Lines-Future-Lines/
- type: indicator
- pine_id: PUB;b26804fb55f44076b4fb947a46891e01
- version: 1.0

## Description

MARK Vertical Lines Forex Market Opening To Closing

## Source Code

````pine
//@version=6
indicator("Forex Daily Open Lines + Future Lines", overlay=true, max_lines_count=500)

// Inputs
lineColor = input.color(color.gray, "Line Color")
lineWidth = input.int(1, "Line Width", minval=1, maxval=3)
futureDays = input.int(20, "Future Days Lines", minval=1, maxval=100)

// New daily candle detect
newDay = ta.change(time("D")) != 0

// Past / current daily open lines
if newDay
    line.new(
         x1=bar_index,
         y1=low,
         x2=bar_index,
         y2=high,
         extend=extend.both,
         color=lineColor,
         style=line.style_dotted,
         width=lineWidth
     )

// Future lines only on last bar
if barstate.islast
    oneDayMs = 24 * 60 * 60 * 1000
    currentDailyTime = time("D")

    for i = 1 to futureDays
        futureTime = currentDailyTime + oneDayMs * i

        line.new(
             x1=futureTime,
             y1=low,
             x2=futureTime,
             y2=high,
             xloc=xloc.bar_time,
             extend=extend.both,
             color=lineColor,
             style=line.style_dotted,
             width=lineWidth
         )
````
