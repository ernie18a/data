# Daily Open, Previous Open & Close Markers

- url: https://www.tradingview.com/script/TgVw4OTu/
- type: indicator
- pine_id: PUB;f7be80d838ce4131b87e2173f988b8e3
- version: 1.0

## Description

DAILY RANGE DE ORO 

marcas en 15 minutos highs  lows y en la linea blanca poner el ENTRY en la morada el SL y en la azul el TP

## Source Code

````pine
//@version=5
indicator("Daily Open, Previous Open & Close Markers", overlay = true)

tz = input.string("UTC+5", "Daily timezone")
lineColor = color.rgb(255, 255, 255)

// Daily session timestamp for today and yesterday
dailyTime     = time("D", tz)
prevDailyTime = time("D", tz)[1]

isNewDay  = ta.change(dailyTime) != 0
showLines = timeframe.isintraday and timeframe.multiplier <= 240

var line openLine     = na
var line closeLine    = na
var line prevOpenLine = na

if not showLines
    if not na(openLine)
        line.delete(openLine)
    if not na(closeLine)
        line.delete(closeLine)
    if not na(prevOpenLine)
        line.delete(prevOpenLine)
    openLine     := na
    closeLine    := na
    prevOpenLine := na

if showLines and isNewDay
    if not na(openLine)
        line.delete(openLine)
    if not na(closeLine)
        line.delete(closeLine)
    if not na(prevOpenLine)
        line.delete(prevOpenLine)

    dayMs = 24 * 60 * 60 * 1000
    openTs     = dailyTime
    closeTs    = dailyTime + dayMs
    prevOpenTs = prevDailyTime   // ALWAYS last trading day (incl. Friday → Monday)

    // 80% transparent (0 = opaque, 100 = invisible)
    transpColor = color.new(lineColor, 80)

    openLine     := line.new(openTs,     low, openTs,     high, xloc=xloc.bar_time, extend=extend.both, color=transpColor, width=2)
    closeLine    := line.new(closeTs,    low, closeTs,    high, xloc=xloc.bar_time, extend=extend.both, color=transpColor, width=2)
    prevOpenLine := line.new(prevOpenTs, low, prevOpenTs, high, xloc=xloc.bar_time, extend=extend.both, color=transpColor, width=2)
````
