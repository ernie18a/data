# UK 1900 2100 Highlight

- url: https://www.tradingview.com/script/yJU1pHCT-UK-1900-2100-Highlight/
- type: indicator
- pine_id: PUB;f39244c2fad6432ea92bbad2074589da
- version: 1.0

## Description

Highlights end of New York Session UK time, mainly used for people who want to back test an edge in the New York session close due to having to work all day in the UK.

## Source Code

````pine
//@version=5
indicator("UK 19:00–21:00 Highlight", overlay=true)

// === Settings ===
sessionColor = input.color(color.new(color.blue, 85), "Highlight Color")

// === UK Session (handles BST/GMT automatically) ===
ukSession = not na(time(timeframe.period, "1900-2100", "Europe/London"))

// === Highlight ===
bgcolor(ukSession ? sessionColor : na)
````
