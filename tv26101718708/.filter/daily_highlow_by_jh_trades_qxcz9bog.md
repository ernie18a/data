# Daily High/Low (by JH trades)

- url: https://www.tradingview.com/script/Qxcz9BOG-Daily-High-Low-by-JH-trades/
- type: indicator
- pine_id: PUB;e1219bcf44d44d6eb33d9fdaa2dd67eb
- version: 1.0

## Description

Look at daily trend easily with this daily high and low indicator

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © JHW-trade

//@version=6
indicator("Daily High/Low (by JH trades)", overlay=true)

// ───── Inputs ─────
showHigh = input.bool(true, "Show Daily High")
showLow  = input.bool(true, "Show Daily Low")

highColor = input.color(color.red, "High Line Color")
lowColor  = input.color(color.green, "Low Line Color")

lineWidth = input.int(2, "Line Width", minval=1, maxval=5)

lineStyleInput = input.string(
     "Solid",
     "Line Style",
     options = ["Solid", "Dashed", "Dotted"]
)

// ───── Line Style Converter ─────
lineStyle = switch lineStyleInput
    "Solid"  => line.style_solid
    "Dashed" => line.style_dashed
    => line.style_dotted

// ───── Variables ─────
var line highLine = na
var line lowLine  = na

var float dayHigh = na
var float dayLow  = na

// Nieuwe dag detecteren
newDay = ta.change(time("D")) != 0

// ───── Start nieuwe dag ─────
if newDay
    // Vorige lijnen stoppen op laatste candle van vorige dag
    if not na(highLine)
        line.set_x2(highLine, bar_index - 1)

    if not na(lowLine)
        line.set_x2(lowLine, bar_index - 1)

    // Nieuwe dagwaarden starten
    dayHigh := high
    dayLow  := low

    // Nieuwe High lijn
    if showHigh
        highLine := line.new(
             x1 = bar_index,
             y1 = dayHigh,
             x2 = bar_index,
             y2 = dayHigh,
             extend = extend.none,
             color = highColor,
             width = lineWidth,
             style = lineStyle
         )

    // Nieuwe Low lijn
    if showLow
        lowLine := line.new(
             x1 = bar_index,
             y1 = dayLow,
             x2 = bar_index,
             y2 = dayLow,
             extend = extend.none,
             color = lowColor,
             width = lineWidth,
             style = lineStyle
         )

// ───── Tijdens huidige dag ─────
else
    // Update High
    if high > dayHigh
        dayHigh := high

        if showHigh
            line.set_y1(highLine, dayHigh)
            line.set_y2(highLine, dayHigh)

    // Update Low
    if low < dayLow
        dayLow := low

        if showLow
            line.set_y1(lowLine, dayLow)
            line.set_y2(lowLine, dayLow)

    // Lijnen horizontaal verlengen binnen dezelfde dag
    if showHigh and not na(highLine)
        line.set_x2(highLine, bar_index)

    if showLow and not na(lowLine)
        line.set_x2(lowLine, bar_index)
````
