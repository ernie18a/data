# AVE AGENT INDICATOR

- url: https://www.tradingview.com/script/xzm0ob1A/
- type: indicator
- pine_id: PUB;6d4b07fe49d2412ea75584b12a061cc7
- version: 2.0

## Description

📊AVE AGENT INDICATOR

Precise Doji detection combined with clearly defined intraday session zones (NY Session).

🔍 What does this indicator do?

The Doji Zone Sniper automatically detects high-quality Doji candles during the New York opening range and builds a reaction-based price zone from them.

This zone is then extended to the right, helping you clearly identify liquidity, rejections, and potential trading areas.

⚙️ Features

✔ Smart Doji Detection

Detects only small, relevant Doji candles
Filters out large bodies and extreme wicks
Optimized for fast markets (e.g. US500 / NASDAQ on 1m)

✔ Automatic Zone (Box)

Creates a zone based on the detected Doji
Extends dynamically to the right
Helps visualize key reaction areas

✔ Midline Integration

Displays the midpoint of the zone
Useful for understanding price balance

✔ Session Visualization

🔵 11:00 – 11:01 (key momentum window)
🔴 12:30 – 12:31 (reaction / volatility window)
⚪ Subtle background outside the main session for better focus
⏰ Time Settings (UTC-4)
Doji Detection: 09:30 – 11:00
Zone Extension: until 12:30
Session Visuals: up to 12:30 / 12:31
🎯 Who is this for?

This indicator is ideal for:

Scalpers (1m / 5m)
Intraday traders
SMC / ICT-style traders
Traders focusing on liquidity and rejection zones
💡 How to use
Wait for a Doji zone during the opening session
Observe how price reacts around the zone
Use it as a:
Potential entry area
Reversal zone
Liquidity context
⚠️ Disclaimer

This indicator does not provide direct buy/sell signals.
It is a visual analysis tool and should be used alongside your trading strategy.

🚀 Summary

A clean and powerful tool for traders who understand:

👉 Price reacts where liquidity exists.

## Source Code

````pine
//@version=6
indicator("AVE AGENT INDICATOR", overlay=true)

// === INPUT ===
emaLength = input.int(50)

// === DOJI ZONE COLOR SETTINGS ===
dojiZoneBorderColor = input.color(color.black, "Doji Zone Border Color")
dojiZoneBackgroundColor = input.color(color.new(color.gray, 60), "Doji Zone Background Color")
dojiZoneMidlineColor = input.color(color.gray, "Doji Zone Midline Color")

// === CALC ===
body = math.abs(close - open)
rng = high - low
rngSma = ta.sma(rng, 20)

// 🔥 FIXED DOJI FILTER
noBody = body <= 0.1

upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

totalWicks = upperWick + lowerWick
wickOK = totalWicks <= 2.5

isDoji = noBody and wickOK

validDoji = isDoji

// === SESSION (UTC-4) ===
startTime  = timestamp("GMT-4", year, month, dayofmonth, 9, 30)
endTime    = timestamp("GMT-4", year, month, dayofmonth, 11, 00)
extendTime = timestamp("GMT-4", year, month, dayofmonth, 12, 30)

// === LOGIC ===
if time >= startTime and time <= endTime
    if validDoji
        float top = high
        float bottom = low
        float mid = (top + bottom) / 2

        barsToExtend = int((extendTime - time) / (timeframe.in_seconds(timeframe.period) * 1000))
        rightIndex = bar_index + barsToExtend

        box.new(bar_index, top, rightIndex, bottom,
            xloc = xloc.bar_index,
            border_color = dojiZoneBorderColor,
            bgcolor = dojiZoneBackgroundColor)

        line.new(bar_index, mid, rightIndex, mid,
            xloc = xloc.bar_index,
            color = dojiZoneMidlineColor,
            style = line.style_dashed)

// ======================================================
// 🔥 SESSION VISUAL
// ======================================================

sessionStart = timestamp("GMT-4", year, month, dayofmonth, 9, 30)
sessionEnd   = timestamp("GMT-4", year, month, dayofmonth, 12, 30)

blueStart = timestamp("GMT-4", year, month, dayofmonth, 11, 0)
blueEnd   = timestamp("GMT-4", year, month, dayofmonth, 11, 1)

redStart  = timestamp("GMT-4", year, month, dayofmonth, 12, 30)
redEnd    = timestamp("GMT-4", year, month, dayofmonth, 12, 31)

// ⚫ Outside Session Background — Black with 30% opacity
bgcolor(
     time < sessionStart or time >= sessionEnd ? color.new(color.black, 70) : na,
     title = "Outside Session Background Color")

// 🔵 11:00 AM Marker — Blue with 60% opacity
bgcolor(
     time >= blueStart and time < blueEnd ? color.new(color.blue, 40) : na,
     title = "11:00 AM Marker Color")

// 🔴 12:30 Marker — Red with 30% opacity
bgcolor(
     time >= redStart and time < redEnd ? color.new(color.red, 70) : na,
     title = "12:30 Marker Color")
````
