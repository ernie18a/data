# JROD Live 10m & 15m Candle Builder

- url: https://www.tradingview.com/script/wfNpGM7O-JROD-Live-10m-15m-Candle-Builder/
- type: indicator
- pine_id: PUB;42b7a213e5414bb2bff6e7c99cf713d1
- version: 1.0

## Description

10 min and 15 min candles live formation with their timer.

## Source Code

````pine
//@version=6
indicator("Live 10m & 15m Candle Builder", overlay = true, max_boxes_count = 50, max_lines_count = 50)

// Inputs
show10m = input.bool(true, "Show 10 Minute Candle")
show15m = input.bool(true, "Show 15 Minute Candle")

bullColor10 = input.color(color.new(color.lime, 75), "10m Bull Color")
bearColor10 = input.color(color.new(color.red, 75), "10m Bear Color")

bullColor15 = input.color(color.new(color.blue, 75), "15m Bull Color")
bearColor15 = input.color(color.new(color.orange, 75), "15m Bear Color")

wickColor = input.color(color.gray, "Wick Color")

offset10 = input.int(2, "10m Candle Offset", minval = 1)
offset15 = input.int(5, "15m Candle Offset", minval = 2)

labelYOffset = input.float(1.0, "Label Lower Offset", minval = 0.0, step = 0.1)

// Countdown formatter
formatTimeLeft(tf) =>
    tfCloseTime = request.security(syminfo.tickerid, tf, time_close, barmerge.gaps_off, barmerge.lookahead_on)
    msLeft = math.max(tfCloseTime - timenow, 0)

    totalSeconds = math.floor(msLeft / 1000)
    minutes = math.floor(totalSeconds / 60)
    seconds = totalSeconds % 60

    str.tostring(minutes, "00") + ":" + str.tostring(seconds, "00")

// Draw live HTF candle
drawLiveCandle(tf, enabled, offsetBars, bullColor, bearColor, labelText) =>
    htfOpen  = request.security(syminfo.tickerid, tf, open,  barmerge.gaps_off, barmerge.lookahead_on)
    htfHigh  = request.security(syminfo.tickerid, tf, high,  barmerge.gaps_off, barmerge.lookahead_on)
    htfLow   = request.security(syminfo.tickerid, tf, low,   barmerge.gaps_off, barmerge.lookahead_on)
    htfClose = request.security(syminfo.tickerid, tf, close, barmerge.gaps_off, barmerge.lookahead_on)

    timeLeft = formatTimeLeft(tf)

    var box body = na
    var line wick = na
    var label lbl = na

    if enabled and barstate.islast
        candleColor = htfClose >= htfOpen ? bullColor : bearColor

        left  = bar_index + offsetBars
        right = bar_index + offsetBars + 2

        bodyTop = math.max(htfOpen, htfClose)
        bodyBot = math.min(htfOpen, htfClose)
        midX = math.round((left + right) / 2)

        labelY = htfLow - labelYOffset * syminfo.mintick * 100

        labelFullText = labelText + "\n" + timeLeft

        if na(body)
            body := box.new(left, bodyTop, right, bodyBot, bgcolor = candleColor, border_color = color.new(color.white, 0))
            wick := line.new(midX, htfHigh, midX, htfLow, color = wickColor, width = 2)
            lbl := label.new(midX, labelY, labelFullText, style = label.style_label_up, textcolor = color.white, color = color.new(color.black, 0))
        else
            box.set_left(body, left)
            box.set_right(body, right)
            box.set_top(body, bodyTop)
            box.set_bottom(body, bodyBot)
            box.set_bgcolor(body, candleColor)

            line.set_x1(wick, midX)
            line.set_x2(wick, midX)
            line.set_y1(wick, htfHigh)
            line.set_y2(wick, htfLow)

            label.set_x(lbl, midX)
            label.set_y(lbl, labelY)
            label.set_text(lbl, labelFullText)

    [htfOpen, htfHigh, htfLow, htfClose]

// Draw candles
[o10, h10, l10, c10] = drawLiveCandle("10", show10m, offset10, bullColor10, bearColor10, "10m")
[o15, h15, l15, c15] = drawLiveCandle("15", show15m, offset15, bullColor15, bearColor15, "15m")
````
