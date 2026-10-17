# EMA 9/50/200 - Hailstone Analytics

- url: https://www.tradingview.com/script/1p3KFs0w-EMA-9-50-200-Hailstone-Analytics/
- type: indicator
- pine_id: PUB;96b8073a1bec42a499e6d987a19fbeac
- version: 1.0

## Description

Slope aware color coding. - Green for upsloping, red for downsloping

## Source Code

````pine
//@version=6
indicator("Hailstone EMA 9/50/200", shorttitle = "HA EMA 9/50/200", overlay = true)

groupCalc = "Calculation"
groupStyle = "Style"
groupEma = "EMA Lines"

srcInput = input.source(close, "Source", group = groupCalc)
slopeLookback = input.int(5, "Slope lookback", minval = 1, group = groupCalc)
useSlopeColors = input.bool(true, "Use Hailstone slope colors", group = groupStyle)

upColor = input.color(color.rgb(0, 191, 0), "Up-slope color", group = groupStyle)
downColor = input.color(color.rgb(240, 48, 0), "Down-slope color", group = groupStyle)

showEma9 = input.bool(true, "EMA9", inline = "ema9", group = groupEma)
ema9Width = input.int(1, "Width", minval = 1, maxval = 5, inline = "ema9", group = groupEma)
ema9StaticColor = input.color(color.rgb(0, 191, 0), "Static", inline = "ema9", group = groupEma)

showEma50 = input.bool(true, "EMA50", inline = "ema50", group = groupEma)
ema50Width = input.int(2, "Width", minval = 1, maxval = 5, inline = "ema50", group = groupEma)
ema50StaticColor = input.color(color.rgb(255, 184, 0), "Static", inline = "ema50", group = groupEma)

showEma200 = input.bool(true, "EMA200", inline = "ema200", group = groupEma)
ema200Width = input.int(3, "Width", minval = 1, maxval = 5, inline = "ema200", group = groupEma)
ema200StaticColor = input.color(color.rgb(0, 165, 255), "Static", inline = "ema200", group = groupEma)

hailstoneEma(series float source, simple int length) =>
    float alpha = 2.0 / (length + 1.0)
    float seed = ta.sma(source, length)
    float ema = na
    ema := na(ema[1]) ? seed : source * alpha + ema[1] * (1.0 - alpha)
    ema

hailstoneSlopeColor(series float value, color fallbackColor) =>
    if not useSlopeColors
        fallbackColor
    else if na(value[slopeLookback])
        upColor
    else
        value >= value[slopeLookback] ? upColor : downColor

ema9 = hailstoneEma(srcInput, 9)
ema50 = hailstoneEma(srcInput, 50)
ema200 = hailstoneEma(srcInput, 200)

plot(showEma9 ? ema9 : na, "EMA 9", color = hailstoneSlopeColor(ema9, ema9StaticColor), linewidth = ema9Width)
plot(showEma50 ? ema50 : na, "EMA 50", color = hailstoneSlopeColor(ema50, ema50StaticColor), linewidth = ema50Width)
plot(showEma200 ? ema200 : na, "EMA 200", color = hailstoneSlopeColor(ema200, ema200StaticColor), linewidth = ema200Width)
````
