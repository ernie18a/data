# BFC Session Reclaim

- url: https://www.tradingview.com/script/JOiJR1bh-BFC-Session-Reclaim/
- type: indicator
- pine_id: PUB;722ab9f46c0e440fbfd5d193475b0537
- version: 1.0

## Description

BFC Session Reclaim is a 1 Hour timeframe indicator designed to highlight key session wick levels from the 5 PM and 8 AM candles. The script automatically marks the high and low wick levels of these candles to help traders identify important liquidity zones and momentum continuation setups.

The main concept behind the indicator is simple: price will often open, pull back into liquidity, then reclaim or break back above the high wick of these key session candles before continuing bullish. The same idea can be used in reverse for bearish setups using the low wick levels.

Built for momentum and liquidity-based traders, BFC Session Reclaim keeps charts clean by using small anchored markers instead of long lines across the screen. The script also includes settings to show or hide previous session levels for cleaner chart analysis.

## Source Code

````pine
//@version=5
indicator("BFC 5PM & 8AM Wick Marks", overlay=true, max_boxes_count=500)

tz = input.string("America/Chicago", "Time Zone")

show5pm = input.bool(true, "Show 5 PM Candle")
show8am = input.bool(true, "Show 8 AM Candle")

showPrevious = input.bool(false, "Show Previous Sessions")
keepSessions = input.int(5, "Previous Sessions To Keep", minval=1, maxval=50)

highColor = input.color(color.lime, "High Wick Color")
lowColor  = input.color(color.red, "Low Wick Color")

markWidth = input.int(1, "Mark Width In Candles", minval=1, maxval=5)

hr = hour(time, tz)
mn = minute(time, tz)

isTarget = (show5pm and hr == 17 and mn == 0) or (show8am and hr == 8 and mn == 0)

var box[] boxes = array.new_box()

drawBox(_price, _color) =>
    b = box.new(left=bar_index, top=_price, right=bar_index + markWidth, bottom=_price, border_color=_color, bgcolor=color.new(_color, 0))
    array.push(boxes, b)

if isTarget
    drawBox(high, highColor)
    drawBox(low, lowColor)

    maxBoxes = showPrevious ? keepSessions * 4 : 4

    while array.size(boxes) > maxBoxes
        oldBox = array.shift(boxes)
        box.delete(oldBox)
````
