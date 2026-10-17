# ADR Compact with Expansion

- url: https://www.tradingview.com/script/xdPfllMt-ADR-Compact-with-Expansion/
- type: indicator
- pine_id: PUB;98f2a53751474829901f83a23720c3bb
- version: 4.0

## Description

ADR Compact with Expansion

A clean, lightweight Average Daily Range (ADR) dashboard designed for momentum and swing traders.

Displays:
ADR % — Average Daily Range as a percentage of price.
ADR $ — Average Daily Range in dollars.
ADR Expansion — Current day's range divided by the stock's ADR.

Color Coding:
Gray: Low volatility
Green: Moderate volatility
Yellow: High volatility
Red: Extreme volatility

ADR Expansion helps identify whether a stock has already made its typical daily move or still has room to run. Values near 1.0 ADR indicate a normal trading day, while higher values highlight unusually strong price expansion.

Designed to provide key volatility and range information at a glance without cluttering the chart.

You could also add a shorter "why I built this" note:

Built to quickly evaluate stock volatility and daily extension while reviewing large numbers of charts. Particularly useful for momentum, breakout, and growth-stock traders who want to assess opportunity and potential overextension in seconds.

## Source Code

````pine
//@version=6
indicator("ADR Compact with Expansion", overlay=true)

// Inputs
adrLength = input.int(20, "ADR Length", minval=1)

tablePos = input.string(
     "Middle Right",
     "Table Position",
     options=[
     "Top Left",
     "Top Right",
     "Middle Left",
     "Middle Right",
     "Bottom Left",
     "Bottom Right"])

// Convert position string
getPosition(pos) =>
    switch pos
        "Top Left" => position.top_left
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        => position.bottom_right

// ADR Calculations
dailyRangePct = high / low - 1.0
adrPercent = 100.0 * ta.sma(dailyRangePct, adrLength)
adrDollar = ta.sma(high - low, adrLength)

// Today's Range Compared to ADR
todayRange = high - low
adrExpansion = todayRange / adrDollar

// ADR Color Logic
adrColor =
     adrPercent < 4  ? color.gray :
     adrPercent < 10 ? color.green :
     adrPercent < 15 ? color.yellow :
                       color.red

// Historical values for Data Window
plot(adrPercent, title="Historical ADR %", display=display.data_window)
plot(adrDollar, title="Historical ADR $", display=display.data_window)

// Rebuild table if position changes
var table adrTable = na
var string lastPos = ""

if na(adrTable) or tablePos != lastPos
    if not na(adrTable)
        table.delete(adrTable)

    adrTable := table.new(getPosition(tablePos), 2, 4, border_width=1)
    lastPos := tablePos

// Update table
if barstate.islast
    table.cell(adrTable, 0, 0, "ADR", bgcolor=color.black, text_color=color.white)
    table.cell(adrTable, 1, 0, "Key", bgcolor=color.black, text_color=color.white)

    table.cell(
         adrTable, 0, 1,
         str.tostring(adrPercent, "#.##") + "%",
         bgcolor=adrColor,
         text_color=color.black)

    table.cell(
         adrTable, 1, 1,
         "4-10%",
         bgcolor=color.green,
         text_color=color.black)

    table.cell(
         adrTable, 0, 2,
         "$" + str.tostring(adrDollar, "#.##"),
         bgcolor=adrColor,
         text_color=color.black)

    table.cell(
         adrTable, 1, 2,
         "10-15%",
         bgcolor=color.yellow,
         text_color=color.black)

    table.cell(
         adrTable, 0, 3,
         str.tostring(adrExpansion, "#.##") + " ADR",
         bgcolor=color.black,
         text_color=color.white)

    table.cell(
         adrTable, 1, 3,
         "15%+",
         bgcolor=color.red,
         text_color=color.white)
````
