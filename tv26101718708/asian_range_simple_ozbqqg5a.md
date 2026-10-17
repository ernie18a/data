# Asian Range Simple

- url: https://www.tradingview.com/script/OZBQqg5a-Asian-Range-Simple/
- type: indicator
- pine_id: PUB;ce0d7357c0dc4f7d83c93490ba72ca5a
- version: 1.0

## Description

Automatically draws the HIGH and LOW of the Asian trading session   directly on your TradingView chart. No manual line drawing needed

## Source Code

````pine
//@version=6
indicator("Asian Range Simple", overlay=true)

// Manually enter your Asian session times in CET
asianStart = 0    // 00:00 CET (7pm ET previous day)
asianEnd   = 6    // 06:00 CET (1am ET)

isAsian = hour(time) >= asianStart and hour(time) < asianEnd

var float asianHigh = na
var float asianLow = na

if isAsian
    asianHigh := na(asianHigh) ? high : math.max(asianHigh, high)
    asianLow := na(asianLow) ? low : math.min(asianLow, low)
else
    if not na(asianHigh)
        line.new(bar_index[1], asianHigh, bar_index, asianHigh, color=color.green, width=2)
        line.new(bar_index[1], asianLow, bar_index, asianLow, color=color.red, width=2)
    asianHigh := na
    asianLow := na
````
