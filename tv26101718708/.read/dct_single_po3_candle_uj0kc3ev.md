# DCT Single PO3 Candle

- url: https://www.tradingview.com/script/uj0kc3ev-DCT-Single-PO3-Candle/
- type: indicator
- pine_id: PUB;dc3671a5c12b41769e74ccc51fb92444
- version: 1.0

## Description

You can see an 4h,1h, or 30 minute canlde on the the right hand side of your screen. helps to know where to price wants to go

## Source Code

````pine
//@version=6
indicator("DCT Single PO3 Candle", overlay=true, max_boxes_count=50, max_lines_count=50)

// Inputs
po3TF = input.timeframe("240", "PO3 Candle TF", options=["240", "60", "30"])
offset = input.int(15, "Right Offset", minval=5)   // ← pushed more right
width  = input.int(6, "Candle Width", minval=2)

// Colors
bullColor = color.blue
bearColor = color.black
wickColor = color.black

// HTF data
htfOpen  = request.security(syminfo.tickerid, po3TF, open)
htfHigh  = request.security(syminfo.tickerid, po3TF, high)
htfLow   = request.security(syminfo.tickerid, po3TF, low)
htfClose = request.security(syminfo.tickerid, po3TF, close)

candleColor = htfClose >= htfOpen ? bullColor : bearColor

// Position (far right)
leftX  = bar_index + offset
rightX = bar_index + offset + width
midX   = math.round((leftX + rightX) / 2)

// Objects
var box body = na
var line wick = na

// Create once
if na(body)
    body := box.new(leftX, math.max(htfOpen, htfClose), rightX, math.min(htfOpen, htfClose),
         bgcolor=candleColor, border_color=candleColor)

    wick := line.new(midX, htfHigh, midX, htfLow, color=wickColor, width=2)

// Update every bar
box.set_left(body, leftX)
box.set_right(body, rightX)
box.set_top(body, math.max(htfOpen, htfClose))
box.set_bottom(body, math.min(htfOpen, htfClose))
box.set_bgcolor(body, candleColor)
box.set_border_color(body, candleColor)

line.set_x1(wick, midX)
line.set_x2(wick, midX)
line.set_y1(wick, htfHigh)
line.set_y2(wick, htfLow)
````
