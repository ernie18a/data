# Long Short Position Size + Leverage

- url: https://www.tradingview.com/script/8It1vWQW-Long-Short-Position-Size-Leverage/
- type: indicator
- pine_id: PUB;4e4e342f6f69453e9d14d9b7e2bd01b7
- version: 1.0

## Description

This indicator shows the position size and leverage need to entering to a trade with given risk(input) at the high and low of last closed candle

## Source Code

````pine
//@version=5
indicator("Long Short Position Size + Leverage", overlay=true)

// Inputs
capital = input.float(100, "Trading Capital", minval=1)
riskPercent = input.float(4, "Risk %", minval=0.1, step=0.1)

// Last closed candle values
lastHigh = high[1]
lastLow = low[1]

riskAmount = capital * riskPercent / 100
candleRange = lastHigh - lastLow

// Long setup
longEntry = lastHigh
longSize = candleRange > 0 ? riskAmount / candleRange : na
longPositionValue = longSize * longEntry
longLeverage = longPositionValue / capital

// Short setup
shortEntry = lastLow
shortSize = candleRange > 0 ? riskAmount / candleRange : na
shortPositionValue = shortSize * shortEntry
shortLeverage = shortPositionValue / capital

// Create fixed table on left side
var table infoTable = table.new(position.bottom_right, 2, 6, border_width=1)

if barstate.islast
    table.cell(infoTable, 0, 0, "LONG", text_color=color.white, bgcolor=color.green)
    table.cell(infoTable, 1, 0, "", bgcolor=color.green)

    table.cell(infoTable, 0, 1, "Size", text_color=color.white, bgcolor=color.black)
    table.cell(infoTable, 1, 1, str.tostring(longSize, "#.##"), text_color=color.white, bgcolor=color.black)

    table.cell(infoTable, 0, 2, "Lev", text_color=color.white, bgcolor=color.black)
    table.cell(infoTable, 1, 2, str.tostring(longLeverage, "#") + "X", text_color=color.white, bgcolor=color.black)

    table.cell(infoTable, 0, 3, "SHORT", text_color=color.white, bgcolor=color.red)
    table.cell(infoTable, 1, 3, "", bgcolor=color.red)

    table.cell(infoTable, 0, 4, "Size", text_color=color.white, bgcolor=color.black)
    table.cell(infoTable, 1, 4, str.tostring(shortSize, "#.##"), text_color=color.white, bgcolor=color.black)

    table.cell(infoTable, 0, 5, "Lev", text_color=color.white, bgcolor=color.black)
    table.cell(infoTable, 1, 5, str.tostring(shortLeverage, "#") + "X", text_color=color.white, bgcolor=color.black)
````
