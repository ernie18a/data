# MTF RSI

- url: https://www.tradingview.com/script/IREXzfAw-MTF-RSI/
- type: indicator
- pine_id: PUB;4d1dde92e21c47d9b254c83138a660d3
- version: 1.0

## Description

MTF RSI Momentum Dashboard

Logic:

RSI > 60 → Green
RSI < 40 → Red
RSI 40–60 → White
STATUS:
CROSS UP = RSI just crossed above RSI MA(14 SMA)
CROSS DOWN = RSI just crossed below RSI MA(14 SMA)
ABOVE = RSI above MA
BELOW = RSI below MA

## Source Code

````pine
//@version=6
indicator("MTF RSI Momentum Dashboard", overlay=true)

// Settings
rsiLen = 14
maLen  = 14

// Function to get RSI & Status
getData(tf) =>
    rsi = request.security(syminfo.tickerid, tf, ta.rsi(close, rsiLen))
    rsiMA = request.security(syminfo.tickerid, tf, ta.sma(ta.rsi(close, rsiLen), maLen))

    crossUp = request.security(
         syminfo.tickerid,
         tf,
         ta.crossover(
             ta.rsi(close, rsiLen),
             ta.sma(ta.rsi(close, rsiLen), maLen)
         )
     )

    crossDown = request.security(
         syminfo.tickerid,
         tf,
         ta.crossunder(
             ta.rsi(close, rsiLen),
             ta.sma(ta.rsi(close, rsiLen), maLen)
         )
     )

    status = crossUp ? "CROSS UP" :
             crossDown ? "CROSS DOWN" :
             rsi > rsiMA ? "ABOVE" :
             "BELOW"

    [rsi, status]

// Get Data
[rsi5, status5]   = getData("5")
[rsi15, status15] = getData("15")
[rsi1h, status1h] = getData("60")
[rsi1d, status1d] = getData("D")
[rsi1w, status1w] = getData("W")

// RSI Color Logic
rsiColor(val) =>
    val > 60 ? color.lime :
     val < 40 ? color.red :
     color.white

// Dark Theme Colors
tableBg  = color.rgb(28, 28, 28)
headerBg = color.rgb(45, 45, 45)

// Table
var table dashboard = table.new(position.top_right, 3, 6, border_width=1)

if barstate.islast

    // Header
    table.cell(dashboard, 0, 0, "TF", bgcolor=headerBg, text_color=color.white)
    table.cell(dashboard, 1, 0, "RSI", bgcolor=headerBg, text_color=color.white)
    table.cell(dashboard, 2, 0, "STATUS", bgcolor=headerBg, text_color=color.white)

    // 5m
    table.cell(dashboard, 0, 1, "5m", bgcolor=tableBg, text_color=color.white)
    table.cell(dashboard, 1, 1, str.tostring(math.round(rsi5)), bgcolor=tableBg, text_color=rsiColor(rsi5))
    table.cell(dashboard, 2, 1, status5, bgcolor=tableBg, text_color=color.white)

    // 15m
    table.cell(dashboard, 0, 2, "15m", bgcolor=tableBg, text_color=color.white)
    table.cell(dashboard, 1, 2, str.tostring(math.round(rsi15)), bgcolor=tableBg, text_color=rsiColor(rsi15))
    table.cell(dashboard, 2, 2, status15, bgcolor=tableBg, text_color=color.white)

    // 1H
    table.cell(dashboard, 0, 3, "1H", bgcolor=tableBg, text_color=color.white)
    table.cell(dashboard, 1, 3, str.tostring(math.round(rsi1h)), bgcolor=tableBg, text_color=rsiColor(rsi1h))
    table.cell(dashboard, 2, 3, status1h, bgcolor=tableBg, text_color=color.white)

    // 1D
    table.cell(dashboard, 0, 4, "1D", bgcolor=tableBg, text_color=color.white)
    table.cell(dashboard, 1, 4, str.tostring(math.round(rsi1d)), bgcolor=tableBg, text_color=rsiColor(rsi1d))
    table.cell(dashboard, 2, 4, status1d, bgcolor=tableBg, text_color=color.white)

    // 1W
    table.cell(dashboard, 0, 5, "1W", bgcolor=tableBg, text_color=color.white)
    table.cell(dashboard, 1, 5, str.tostring(math.round(rsi1w)), bgcolor=tableBg, text_color=rsiColor(rsi1w))
    table.cell(dashboard, 2, 5, status1w, bgcolor=tableBg, text_color=color.white)
````
