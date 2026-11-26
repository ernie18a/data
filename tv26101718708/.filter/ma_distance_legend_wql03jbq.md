# MA Distance Legend

- url: https://www.tradingview.com/script/WQl03jbQ-MA-Distance-Legend/
- type: indicator
- pine_id: PUB;eaae8b9d055845d3b223ea97bd53f9d4
- version: 2.0

## Description

Places a legend in the top right corner of your chart showing current distance from MAs in both price and %. Current version has static MAs being monitored: 5sma, 21ema, 50sma, 100sma, 200sma (on daily time frame).

## Source Code

````pine
//@version=5
indicator("MA Distance Legend (Daily)", overlay=true)

// === Get DAILY data regardless of chart timeframe ===
d_close = request.security(syminfo.tickerid, "D", close)

ma5   = request.security(syminfo.tickerid, "D", ta.sma(close, 5))
ema21 = request.security(syminfo.tickerid, "D", ta.ema(close, 21))
ma50  = request.security(syminfo.tickerid, "D", ta.sma(close, 50))
ma100 = request.security(syminfo.tickerid, "D", ta.sma(close, 100))
ma200 = request.security(syminfo.tickerid, "D", ta.sma(close, 200))

// === Distance Calculations (based on daily close) ===
dist5   = d_close - ma5
dist21  = d_close - ema21
dist50  = d_close - ma50
dist100 = d_close - ma100
dist200 = d_close - ma200

// Percent distance
pct5   = (dist5 / ma5) * 100
pct21  = (dist21 / ema21) * 100
pct50  = (dist50 / ma50) * 100
pct100 = (dist100 / ma100) * 100
pct200 = (dist200 / ma200) * 100

// === Table (Legend) ===
var table legend = table.new(position.top_right, 3, 6, border_width=1)

// Header
if barstate.islast
    table.cell(legend, 0, 0, "MA", text_color=color.white, bgcolor=color.black)
    table.cell(legend, 1, 0, "Distance", text_color=color.white, bgcolor=color.black)
    table.cell(legend, 2, 0, "%", text_color=color.white, bgcolor=color.black)

// Update table
if barstate.islast
    table.cell(legend, 0, 1, "5 SMA")
    table.cell(legend, 1, 1, str.tostring(dist5, format.mintick))
    table.cell(legend, 2, 1, str.tostring(pct5, "#.##") + "%")

    table.cell(legend, 0, 2, "21 EMA")
    table.cell(legend, 1, 2, str.tostring(dist21, format.mintick))
    table.cell(legend, 2, 2, str.tostring(pct21, "#.##") + "%")

    table.cell(legend, 0, 3, "50 SMA")
    table.cell(legend, 1, 3, str.tostring(dist50, format.mintick))
    table.cell(legend, 2, 3, str.tostring(pct50, "#.##") + "%")

    table.cell(legend, 0, 4, "100 SMA")
    table.cell(legend, 1, 4, str.tostring(dist100, format.mintick))
    table.cell(legend, 2, 4, str.tostring(pct100, "#.##") + "%")

    table.cell(legend, 0, 5, "200 SMA")
    table.cell(legend, 1, 5, str.tostring(dist200, format.mintick))
    table.cell(legend, 2, 5, str.tostring(pct200, "#.##") + "%")
````
