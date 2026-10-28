# MTF EMA Overlay

- url: https://www.tradingview.com/script/38hKF5Mp-MTF-EMA-Overlay/
- type: indicator
- pine_id: PUB;2f2608f2dbb24641abb341ca1ce51c2b
- version: 2.0

## Description

Multi-Timeframe EMA Overlay brings higher-timeframe EMA structure onto your current chart in a clean and efficient way. It plots the same EMA period across multiple timeframes, helping you spot trend alignment, confluence, and key dynamic levels without switching charts.

Default setup: EMA 233 on 5m, 15m, 1h, 4h, and 1D.

Built for traders who want a minimal, high-signal multi-timeframe view.

Alternative even shorter version:

Multi-Timeframe EMA Overlay plots the same EMA across multiple timeframes on a single chart. Designed for clean multi-timeframe analysis, it helps traders identify trend alignment and important dynamic levels at a glance.

## Source Code

````pine
//@version=6
indicator("MTF EMA Overlay", shorttitle="MTF EMA", overlay=true)

//----------------------------------------------------
// Inputs
//----------------------------------------------------
emaLength = input.int(233, "EMA Period", minval=1)
src       = input.source(close, "Source")

tf1 = input.timeframe("5",   "Timeframe 1")
tf2 = input.timeframe("15",  "Timeframe 2")
tf3 = input.timeframe("60",  "Timeframe 3")
tf4 = input.timeframe("240", "Timeframe 4")
tf5 = input.timeframe("D",   "Timeframe 5")

showLabels   = input.bool(true, "Show TF Labels")
xOffsetBars  = input.int(100, "Label X Offset Back Bars", minval=1)
yOffsetTicks = input.int(0, "Label Y Offset Ticks", minval=0)
labelStyle   = input.string("Text Only", "Label Style", options=["Text Only", "Box"])
labelSizeInp = input.string("Normal", "Label Size", options=["Tiny", "Small", "Normal"])

//----------------------------------------------------
// Helpers
//----------------------------------------------------
getEma(tf) =>
    request.security(syminfo.tickerid, tf, ta.ema(src, emaLength), barmerge.gaps_off, barmerge.lookahead_off)

formatTf(tf) =>
    string out = tf
    if tf == "D"
        out := "1D"
    else if tf == "W"
        out := "1W"
    else if tf == "M"
        out := "1M"
    else
        tfNum = str.tonumber(tf)
        if not na(tfNum)
            if tfNum < 60
                out := str.tostring(int(tfNum)) + "m"
            else if tfNum % 60 == 0
                out := str.tostring(int(tfNum / 60)) + "h"
            else
                out := str.tostring(int(tfNum)) + "m"
    out

getLabelStyle(styleName) =>
    styleName == "Box" ? label.style_label_down : label.style_none

getLabelSize(sizeName) =>
    sizeName == "Tiny" ? size.tiny : sizeName == "Normal" ? size.normal : size.small

updateLabel(lbl, x, y, txt, txtColor, bgColor, styleValue, sizeValue) =>
    label result = lbl
    if na(result)
        result := label.new(x, y, txt, xloc=xloc.bar_index, yloc=yloc.price, style=styleValue, textcolor=txtColor, color=bgColor, size=sizeValue)
    else
        label.set_xy(result, x, y)
        label.set_text(result, txt)
        label.set_textcolor(result, txtColor)
        label.set_color(result, bgColor)
        label.set_style(result, styleValue)
        label.set_size(result, sizeValue)
    result

//----------------------------------------------------
// EMA values
//----------------------------------------------------
ema1 = getEma(tf1)
ema2 = getEma(tf2)
ema3 = getEma(tf3)
ema4 = getEma(tf4)
ema5 = getEma(tf5)

//----------------------------------------------------
// Colors
//----------------------------------------------------
color1 = color.aqua
color2 = color.lime
color3 = color.yellow
color4 = color.orange
color5 = color.fuchsia

//----------------------------------------------------
// Plots
//----------------------------------------------------
plot(ema1, title="EMA TF1", color=color1, linewidth=2)
plot(ema2, title="EMA TF2", color=color2, linewidth=2)
plot(ema3, title="EMA TF3", color=color3, linewidth=2)
plot(ema4, title="EMA TF4", color=color4, linewidth=2)
plot(ema5, title="EMA TF5", color=color5, linewidth=2)

//----------------------------------------------------
// Labels
//----------------------------------------------------
var label lbl1 = na
var label lbl2 = na
var label lbl3 = na
var label lbl4 = na
var label lbl5 = na

if barstate.islast
    styleValue = getLabelStyle(labelStyle)
    sizeValue  = getLabelSize(labelSizeInp)
    xPos       = math.max(bar_index - xOffsetBars, 0)
    yStep      = syminfo.mintick * yOffsetTicks

    ema1AtPos = xOffsetBars <= bar_index ? ema1[xOffsetBars] : na
    ema2AtPos = xOffsetBars <= bar_index ? ema2[xOffsetBars] : na
    ema3AtPos = xOffsetBars <= bar_index ? ema3[xOffsetBars] : na
    ema4AtPos = xOffsetBars <= bar_index ? ema4[xOffsetBars] : na
    ema5AtPos = xOffsetBars <= bar_index ? ema5[xOffsetBars] : na

    if showLabels
        bg1 = color.new(color1, labelStyle == "Text Only" ? 100 : 0)
        bg2 = color.new(color2, labelStyle == "Text Only" ? 100 : 0)
        bg3 = color.new(color3, labelStyle == "Text Only" ? 100 : 0)
        bg4 = color.new(color4, labelStyle == "Text Only" ? 100 : 0)
        bg5 = color.new(color5, labelStyle == "Text Only" ? 100 : 0)

        if not na(ema1AtPos)
            lbl1 := updateLabel(lbl1, xPos, ema1AtPos + yStep * 0, formatTf(tf1), color1, bg1, styleValue, sizeValue)
        if not na(ema2AtPos)
            lbl2 := updateLabel(lbl2, xPos, ema2AtPos + yStep * 1, formatTf(tf2), color2, bg2, styleValue, sizeValue)
        if not na(ema3AtPos)
            lbl3 := updateLabel(lbl3, xPos, ema3AtPos + yStep * 2, formatTf(tf3), color3, bg3, styleValue, sizeValue)
        if not na(ema4AtPos)
            lbl4 := updateLabel(lbl4, xPos, ema4AtPos + yStep * 3, formatTf(tf4), color4, bg4, styleValue, sizeValue)
        if not na(ema5AtPos)
            lbl5 := updateLabel(lbl5, xPos, ema5AtPos + yStep * 4, formatTf(tf5), color5, bg5, styleValue, sizeValue)
    else
        if not na(lbl1)
            label.delete(lbl1)
            lbl1 := na
        if not na(lbl2)
            label.delete(lbl2)
            lbl2 := na
        if not na(lbl3)
            label.delete(lbl3)
            lbl3 := na
        if not na(lbl4)
            label.delete(lbl4)
            lbl4 := na
        if not na(lbl5)
            label.delete(lbl5)
            lbl5 := na
````
