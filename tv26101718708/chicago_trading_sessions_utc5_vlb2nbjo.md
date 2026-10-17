# Chicago Trading Sessions UTC-5

- url: https://www.tradingview.com/script/VlB2NBJO-chicago-trading-sessions-utc-5/
- type: indicator
- pine_id: PUB;fb2021ce36d1426e803e474d0d533178
- version: 1.0

## Description

Chicago Trading Sessions UTC-5 is a simple session visualization indicator designed to clearly highlight the major trading sessions directly on the chart.

The indicator uses a fixed UTC-5 time zone and displays:

🔵 Asia Session: 19:00–04:00
🟢 London Session: 02:00–11:00
🟠 New York Session: 07:00–16:00

Each trading session is highlighted with a different background color across the entire chart, making it easy to identify session timing and overlaps without adding unnecessary levels or signals.

The indicator is designed to keep the chart clean and simple.

Time zone: Fixed UTC-5.

## Source Code

````pine
//@version=6
indicator("Chicago Trading Sessions UTC-5", overlay=true)

string TZ = "UTC-5"

// Sessions
bool asia    = not na(time(timeframe.period, "1900-0400", TZ))
bool london  = not na(time(timeframe.period, "0200-1100", TZ))
bool newYork = not na(time(timeframe.period, "0700-1600", TZ))

// Background colors
color asiaColor    = color.new(color.blue, 90)
color londonColor  = color.new(color.green, 90)
color newYorkColor = color.new(color.orange, 90)

// Color the entire chart background
bgcolor(asia ? asiaColor : na, title="Asia")
bgcolor(london ? londonColor : na, title="London")
bgcolor(newYork ? newYorkColor : na, title="New York")
````
