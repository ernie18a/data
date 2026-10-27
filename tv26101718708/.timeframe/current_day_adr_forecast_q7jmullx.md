# Current Day ADR Forecast

- url: https://www.tradingview.com/script/q7JMuLLx-Current-Day-ADR-Forecast/
- type: indicator
- pine_id: PUB;077614e2566849ae823591d8735df3d3
- version: 1.0

## Description

This script tells you the expected ADR move higher / lower for only the current day and is meant to be used only on the daily time frame.

## Source Code

````pine
//@version=6
indicator("Current Day ADR Forecast", overlay=true)

// === Inputs ===
adrLength = input.int(20, "ADR Length", minval=1)
lineWidth = input.int(2, "Line Width", minval=1)

// === ADR Calculation ===
adr = request.security(
     syminfo.tickerid,
     "D",
     ta.sma(high - low, adrLength)[1]
)

// === Current Day High/Low ===
dayHigh = request.security(syminfo.tickerid, "D", high)
dayLow  = request.security(syminfo.tickerid, "D", low)

// === Forecast Levels ===
bullishForecast = dayLow + adr
bearishForecast = dayHigh - adr

// === Detect New Day ===
newDay = ta.change(time("D")) != 0

// === Persistent Objects ===
var line bullLine = na
var line bearLine = na
var label bullLabel = na
var label bearLabel = na

// === Create Current Day Lines / Labels ===
if newDay or na(bullLine)
    line.delete(bullLine)
    line.delete(bearLine)
    label.delete(bullLabel)
    label.delete(bearLabel)

    bullLine := line.new(bar_index, bullishForecast, bar_index + 1, bullishForecast, extend=extend.right, color=color.green, width=lineWidth)
    bearLine := line.new(bar_index, bearishForecast, bar_index + 1, bearishForecast, extend=extend.right, color=color.red, width=lineWidth)

    bullLabel := label.new(bar_index, bullishForecast, "", style=label.style_label_left, color=color.green, textcolor=color.white)
    bearLabel := label.new(bar_index, bearishForecast, "", style=label.style_label_left, color=color.red, textcolor=color.white)

// === Update Lines ===
line.set_y1(bullLine, bullishForecast)
line.set_y2(bullLine, bullishForecast)

line.set_y1(bearLine, bearishForecast)
line.set_y2(bearLine, bearishForecast)

// === Update Labels With ADR Forecast Values ===
label.set_x(bullLabel, bar_index)
label.set_y(bullLabel, bullishForecast)
label.set_text(bullLabel, "Bull ADR: " + str.tostring(bullishForecast, format.mintick))

label.set_x(bearLabel, bar_index)
label.set_y(bearLabel, bearishForecast)
label.set_text(bearLabel, "Bear ADR: " + str.tostring(bearishForecast, format.mintick))
````
