# Jakes4 XAU Time Block

- url: https://www.tradingview.com/script/RHTUd2Ys-Jakes4-XAU-Time-Block/
- type: indicator
- pine_id: PUB;fa4fa09535ae41e39a98b6dbc3a84ada
- version: 1.0

## Description

This script blocks specific trading times based on your preferences.

## Source Code

````pine
//@version=5
indicator("Custom Time Blocks (UTC+3 Nairobi)", overlay=true)

// === User Inputs (editable in settings) ===
session1 = input.session("0300-0500", "Block 1")
session2 = input.session("0800-1000", "Block 2")
session3 = input.session("1600-2000", "Block 3")

col1 = input.color(color.new(color.blue, 85), "Color 1")
col2 = input.color(color.new(color.yellow, 85), "Color 2")
col3 = input.color(color.new(color.purple, 85), "Color 3")

// === Timezone (fixed to Nairobi UTC+3) ===
tz = "Africa/Nairobi"

inSession(sess) =>
    not na(time(timeframe.period, sess, tz))

bgcolor(inSession(session1) ? col1 : na)
bgcolor(inSession(session2) ? col2 : na)
bgcolor(inSession(session3) ? col3 : na)
````
