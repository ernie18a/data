# HXRO Bot Backtest Time Highlight

- url: https://www.tradingview.com/script/LSQ36sGU/
- type: indicator
- pine_id: PUB;u7FSCqUardHF2L9iCLS9f5QJrb7s0bh1
- version: 1.0

## Description

This script allows you to highlight the HXROBot backtest interval with the possibility of fragmenting the view to better identify the key areas of your strategy

## Source Code

````pine
//@version=4
study(shorttitle="HXRO Bot Backtest Time", title="HXRO Bot Backtest Time Highlight", overlay=true)
div  = input(4, minval=1, maxval=6, title="Backtest Time Division")

startStopColor = color.red
divColor = color.gray

offset = (24 / div) * 60 * 60 * 1000

t1 = time(timeframe.period)
t2 = t1 - offset
t3 = t2 - offset
t4 = t3 - offset
t5 = t4 - offset
t6 = t5 - offset
t7 = t6 - offset


var line line1 = na
line.delete(line1)

var line line2 = na
line.delete(line2)

var line line3 = na
line.delete(line3)

var line line4 = na
line.delete(line4)

var line line5 = na
line.delete(line5)

var line line6 = na
line.delete(line6)

var line line7 = na
line.delete(line7)

line1 := line.new(x1 = t1, y1 = close, x2 = t1, y2 = close + 10, xloc = xloc.bar_time, extend = extend.both, color = startStopColor, style = line.style_solid, width = 1)

if div >= 1
	thisColor = div == 1 ? startStopColor : divColor
	line2 := line.new(x1 = t2, y1 = close, x2 = t2, y2 = close + 10, xloc = xloc.bar_time, extend = extend.both, color = thisColor, style = line.style_solid, width = 1)

if div >= 2
	thisColor = div == 2 ? startStopColor : divColor
	line3 := line.new(x1 = t3, y1 = close, x2 = t3, y2 = close + 10, xloc = xloc.bar_time, extend = extend.both, color = thisColor, style = line.style_solid, width = 1)

if div >= 3
	thisColor = div == 3 ? startStopColor : divColor
	line4 := line.new(x1 = t4, y1 = close, x2 = t4, y2 = close + 10, xloc = xloc.bar_time, extend = extend.both, color = thisColor, style = line.style_solid, width = 1)

if div >= 4
	thisColor = div == 4 ? startStopColor : divColor
	line5 := line.new(x1 = t5, y1 = close, x2 = t5, y2 = close + 10, xloc = xloc.bar_time, extend = extend.both, color = thisColor, style = line.style_solid, width = 1)

if div >= 5
	thisColor = div == 5 ? startStopColor : divColor
	line6 := line.new(x1 = t6, y1 = close, x2 = t6, y2 = close + 10, xloc = xloc.bar_time, extend = extend.both, color = thisColor, style = line.style_solid, width = 1)

if div == 6
	line7 := line.new(x1 = t7, y1 = close, x2 = t7, y2 = close + 10, xloc = xloc.bar_time, extend = extend.both, color = startStopColor, style = line.style_solid, width = 1)
````
