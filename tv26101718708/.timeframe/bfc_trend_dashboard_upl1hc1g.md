# BFC Trend Dashboard

- url: https://www.tradingview.com/script/Upl1HC1G-BFC-Trend-Dashboard/
- type: indicator
- pine_id: PUB;6051e84b88654e6388a44d1b3474ed7b
- version: 1.0

## Description

BFC is a clean multi timeframe trend dashboard built for momentum traders. It quickly shows whether the Daily, 4 Hour, 1 Hour, and 5 Minute trends are bullish or bearish based on price position relative to the 9 EMA.

Designed to stay small and out of the way, BFC helps traders align with higher timeframe momentum without cluttering the chart. Perfect for scalpers, day traders, and momentum traders who want fast trend confirmation across key timeframes.

## Source Code

````pine
//@version=5
indicator("BFC Trend Dashboard", overlay=true)

trend(tf) =>
    c = request.security(syminfo.tickerid, tf, close)
    ema = request.security(syminfo.tickerid, tf, ta.ema(close, 9))
    c > ema ? "Bullish" : "Bearish"

trendColor(txt) =>
    txt == "Bullish" ? color.green : color.red

daily = trend("D")
h4    = trend("240")
h1    = trend("60")
m5    = trend("5")

var table box = table.new(position.bottom_right, 2, 5, border_width=1)

if barstate.islast
    table.cell(box, 0, 0, "BFC", text_color=color.white, bgcolor=color.black, text_size=size.normal)
    table.cell(box, 1, 0, "Trend", text_color=color.white, bgcolor=color.black, text_size=size.normal)

    table.cell(box, 0, 1, "Daily", text_color=color.white, text_size=size.small)
    table.cell(box, 1, 1, daily, text_color=color.white, bgcolor=trendColor(daily), text_size=size.small)

    table.cell(box, 0, 2, "4H", text_color=color.white, text_size=size.small)
    table.cell(box, 1, 2, h4, text_color=color.white, bgcolor=trendColor(h4), text_size=size.small)

    table.cell(box, 0, 3, "1H", text_color=color.white, text_size=size.small)
    table.cell(box, 1, 3, h1, text_color=color.white, bgcolor=trendColor(h1), text_size=size.small)

    table.cell(box, 0, 4, "5M", text_color=color.white, text_size=size.small)
    table.cell(box, 1, 4, m5, text_color=color.white, bgcolor=trendColor(m5), text_size=size.small)
````
