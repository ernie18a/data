# EMA Cloud with 5m Close Alert

- url: https://www.tradingview.com/script/VNuJSX1h-EMA-Cloud-with-5m-Close-Alert/
- type: indicator
- pine_id: PUB;5d2adb5822214e05808ec9f74141413c
- version: 1.0

## Description

EMA Trend Cloud
A clean EMA cloud indicator using the 9 EMA, 15 EMA, and 21 EMA to visualise short-term trend direction.
The cloud is drawn between the 9 EMA and 21 EMA:


Green cloud = bullish trend


Red cloud = bearish trend


The indicator also includes alert conditions for when a candle closes outside the EMA cloud, either above or below. This helps highlight moments of potential momentum or trend continuation, especially on the 5-minute chart.
Best used alongside price action, market structure, key levels, and proper risk management.

## Source Code

````pine
//@version=6
indicator("EMA Trend with 5m Close Alert", overlay = true)

fastLen = input.int(9, title = "Fast")
mediumLen = input.int(15, title = "Medium")
slowLen = input.int(21, title = "Slow")

ema9 = ta.ema(close, fastLen)
ema15 = ta.ema(close, mediumLen)
ema21 = ta.ema(close, slowLen)

a = plot(ema9, display = display.none)
b = plot(ema15, display = display.none)
c = plot(ema21, display = display.none)

up = ema9 > ema21
down = ema9 < ema21

cloudColor = up ? color.new(color.green, 70) : down ? color.new(color.red, 70) : na

fill(a, c, color = cloudColor)

// Cloud boundaries
upperCloud = math.max(ema9, ema21)
lowerCloud = math.min(ema9, ema21)

// Candle closes outside EMA cloud
bullCloseOutside = close > upperCloud and barstate.isconfirmed
bearCloseOutside = close < lowerCloud and barstate.isconfirmed

closeOutsideCloud = bullCloseOutside or bearCloseOutside

// Alert conditions
alertcondition(
     bullCloseOutside,
     title = "Bullish Close Outside EMA Cloud",
     message = "Candle closed ABOVE the EMA cloud"
)

alertcondition(
     bearCloseOutside,
     title = "Bearish Close Outside EMA Cloud",
     message = "Candle closed BELOW the EMA cloud"
)

alertcondition(
     closeOutsideCloud,
     title = "Close Outside EMA Cloud",
     message = "Candle closed outside the EMA cloud"
)
````
