# RO Session High/Low Dynamic TTF

- url: https://www.tradingview.com/script/du8kWyBe-RO-Session-High-Low-Dynamic-TTF/
- type: indicator
- pine_id: PUB;c8512029558645ef88f18bfb63bea91e
- version: 1.0

## Description

London Session HIGH and LOW from 10.00 to 16.32, for a good LIQUIDATION or CONTINUATION Strategy

## Source Code

````pine
//@version=5
indicator("RO Session High/Low Dynamic", overlay=true)

//====================
// Setări
//====================
sessionTime = input.session("1000-1632", "Interval România")
extendBars  = input.int(200, "Extensie linii", minval=1)

lineColor = color.rgb(204, 255, 0) // galben fosforescent
lineWidth = 1

//====================
// Detectare sesiune România
//====================
inSession = not na(time(timeframe.period, sessionTime, "Europe/Bucharest"))
newSession = inSession and not inSession[1]

//====================
// Variabile High / Low
//====================
var float sessHigh = na
var float sessLow  = na

// Bar index unde s-a format high/low
var int highBar = na
var int lowBar  = na

//====================
// Reset început sesiune
//====================
if newSession
    sessHigh := high
    sessLow  := low

    highBar := bar_index
    lowBar  := bar_index

//====================
// Actualizare High
//====================
else if inSession

    if high > sessHigh
        sessHigh := high
        highBar := bar_index

    if low < sessLow
        sessLow := low
        lowBar := bar_index

//====================
// Linii
//====================
var line highLine = na
var line lowLine  = na

if inSession and not na(sessHigh) and not na(sessLow)

    // Șterge liniile vechi
    line.delete(highLine)
    line.delete(lowLine)

    // Linie HIGH
    highLine := line.new(
         x1 = highBar,
         y1 = sessHigh,
         x2 = bar_index + extendBars,
         y2 = sessHigh,
         color = lineColor,
         width = lineWidth)

    // Linie LOW
    lowLine := line.new(
         x1 = lowBar,
         y1 = sessLow,
         x2 = bar_index + extendBars,
         y2 = sessLow,
         color = lineColor,
         width = lineWidth)

//====================
// Plot invizibil pentru valori
//====================
plot(sessHigh, color=color.new(lineColor, 100))
plot(sessLow, color=color.new(lineColor, 100))
````
