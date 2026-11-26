# Multi Time Frame SuperTrend 

- url: https://www.tradingview.com/script/HMZ4Je9C-Multi-Time-Frame-SuperTrend/
- type: indicator
- pine_id: PUB;795227d9d07d4687ba577747c00a378c
- version: 1.0

## Description

This indicator shows 1H and 4H super trend in any timeframe

## Source Code

````pine
//@version=6
indicator("MTF SuperTrend Dashboard", overlay=true)

// Inputs
atrPeriod = input.int(10, "ATR Length", minval=1)
factor = input.float(3.0, "Factor", minval=0.01, step=0.01)

// 1H SuperTrend
[st1h, dir1h] = request.security(
     syminfo.tickerid,
     "60",
     ta.supertrend(factor, atrPeriod))

// 4H SuperTrend
[st4h, dir4h] = request.security(
     syminfo.tickerid,
     "240",
     ta.supertrend(factor, atrPeriod))

// Table
var table dashboard = table.new(
     position.bottom_right,
     2,
     3,
     border_width=1)

// Update table
if barstate.islast

    // Header
    table.cell(dashboard, 0, 0, "TF",
         bgcolor=color.gray,
         text_color=color.white)

    table.cell(dashboard, 1, 0, "Trend",
         bgcolor=color.gray,
         text_color=color.white)

    // 1H Row
    table.cell(dashboard, 0, 1, "1H",
         bgcolor=color.black,
         text_color=color.white)

    table.cell(dashboard, 1, 1,
         dir1h < 0 ? "BULLISH" : "BEARISH",
         bgcolor=dir1h < 0 ? color.green : color.red,
         text_color=color.white)

    // 4H Row
    table.cell(dashboard, 0, 2, "4H",
         bgcolor=color.black,
         text_color=color.white)

    table.cell(dashboard, 1, 2,
         dir4h < 0 ? "BULLISH" : "BEARISH",
         bgcolor=dir4h < 0 ? color.green : color.red,
         text_color=color.white)
````
