# jakes4 Nairobi Time Blocks

- url: https://www.tradingview.com/script/tpADG9B6-jakes4-Nairobi-Time-Blocks/
- type: indicator
- pine_id: PUB;250704286a7547869d31702e070b7ef5
- version: 1.0

## Description

This script blocks specific trading times based on your preferences.

## Source Code

````pine
//@version=5
indicator("Nairobi Time Blocks", overlay=true)

// Function to check if current bar is inside a session
inSession(sess) =>
    not na(time(timeframe.period, sess, "Africa/Nairobi"))

// Your time blocks (UTC+3 Nairobi)
sess1 = "0300-0500"
sess2 = "0800-1000"
sess3 = "1600-1900"

// Background shading
bgcolor(inSession(sess1) ? color.new(color.blue, 85) : na)
bgcolor(inSession(sess2) ? color.new(color.yellow, 85) : na)
bgcolor(inSession(sess3) ? color.new(color.purple, 85) : na)
````
