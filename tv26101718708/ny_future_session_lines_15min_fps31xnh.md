# NY Future Session Lines 15min

- url: https://www.tradingview.com/script/fpS31XnH/
- type: indicator
- pine_id: PUB;bf42ec5cd5344d59986976944c80b82a
- version: 1.0

## Description

It shows you when the next 15min candle will open with a vertical line

## Source Code

````pine
//@version=5
indicator("NY Future Session Lines", overlay=true, max_lines_count=500)

// Farbe: hellgrau mit 50% Transparenz
lineColor = color.new(color.rgb(200, 200, 200), 50)

// Funktion zum Zeichnen vertikaler Linien
drawLine(_time) =>
    line.new(
         x1 = _time,
         y1 = low - 5000,
         x2 = _time,
         y2 = high + 5000,
         xloc = xloc.bar_time,
         extend = extend.both,
         color = lineColor,
         width = 1,
         style = line.style_dotted)

// New York Zeit
nyYear  = year(time, "America/New_York")
nyMonth = month(time, "America/New_York")
nyDay   = dayofmonth(time, "America/New_York")

// Nur einmal pro Tag erstellen
newDay = ta.change(dayofmonth(time, "America/New_York"))

if newDay or barstate.isfirst

    // 10:00 Session
    drawLine(timestamp("America/New_York", nyYear, nyMonth, nyDay, 10, 00))
    drawLine(timestamp("America/New_York", nyYear, nyMonth, nyDay, 10, 15))
    drawLine(timestamp("America/New_York", nyYear, nyMonth, nyDay, 10, 30))
    drawLine(timestamp("America/New_York", nyYear, nyMonth, nyDay, 10, 45))
    drawLine(timestamp("America/New_York", nyYear, nyMonth, nyDay, 11, 00))

    // 14:00 Session
    drawLine(timestamp("America/New_York", nyYear, nyMonth, nyDay, 14, 00))
    drawLine(timestamp("America/New_York", nyYear, nyMonth, nyDay, 14, 15))
    drawLine(timestamp("America/New_York", nyYear, nyMonth, nyDay, 14, 30))
    drawLine(timestamp("America/New_York", nyYear, nyMonth, nyDay, 14, 45))
    drawLine(timestamp("America/New_York", nyYear, nyMonth, nyDay, 15, 00))
````
