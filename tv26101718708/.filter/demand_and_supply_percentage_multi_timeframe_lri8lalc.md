# Demand and Supply percentage Multi Timeframe

- url: https://www.tradingview.com/script/lRI8LaLC-Demand-and-Supply-percentage-Multi-Timeframe/
- type: indicator
- pine_id: PUB;8edc3ae2a0524dbab736843dc2fadd4e
- version: 1.0

## Description

Multi Timeframe Demand Supply Dashboard is a clean visual tool that shows estimated Demand and Supply strength across multiple timeframes in one compact movable panel.

The script calculates demand vs supply pressure using candle position inside each timeframe range, then displays the values together for faster decision making.

Included Timeframes:

1D Daily
4H Four Hour
1H One Hour
15M Fifteen Minute
5M Five Minute

Features:

• Multi timeframe market bias in one view
• Demand and Supply percentages for each timeframe
• Bias labels such as Strong Bull, Bull, Neutral, Bear, Strong Bear
• Color coded rows for instant reading
• Adjustable dashboard position with anchor and offset controls
• Selectable text size
• Optional Bias column on or off
• Overlay mode works directly on chart

How To Use:

When higher timeframes show stronger demand and lower timeframes align, trend continuation probability may improve.

Example:

1D Bullish
4H Bullish
1H Turning Bullish

This may indicate a stronger upside structure.

If higher timeframes are bullish but lower timeframes are bearish, it may indicate pullback or retracement conditions.

Best Use Cases:

• Swing trading confirmation
• Intraday bias filtering
• Scalping with higher timeframe direction
• Trend alignment checks
• Quick market strength dashboard

Note:

This tool estimates pressure using candle range formulas, not true exchange order flow data.

Use with price action, volume, structure, and risk management for best results.

## Source Code

````pine
//@version=6
indicator("MTF Demand Supply Dashboard Movable", overlay=true)

// Inputs
anchor = input.string("Top Right", "Anchor Position", options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"])
txtSize = input.string("Normal", "Text Size", options=["Small","Normal","Large"])
showBias = input.bool(true, "Show Bias Column")
xOff = input.int(0, "Horizontal Offset", minval=-4, maxval=4)
yOff = input.int(0, "Vertical Offset", minval=-4, maxval=4)

// Position
pos = position.top_right
if anchor == "Top Left"
    pos := position.top_left
else if anchor == "Top Center"
    pos := position.top_center
else if anchor == "Middle Left"
    pos := position.middle_left
else if anchor == "Middle Center"
    pos := position.middle_center
else if anchor == "Middle Right"
    pos := position.middle_right
else if anchor == "Bottom Left"
    pos := position.bottom_left
else if anchor == "Bottom Center"
    pos := position.bottom_center
else if anchor == "Bottom Right"
    pos := position.bottom_right

// Text Size
sizeVar = size.normal
if txtSize == "Small"
    sizeVar := size.small
else if txtSize == "Large"
    sizeVar := size.large

// Function
calc(tf) =>
    c = request.security(syminfo.tickerid, tf, close)
    h = request.security(syminfo.tickerid, tf, high)
    l = request.security(syminfo.tickerid, tf, low)
    rng = h - l
    d = rng != 0 ? ((c - l) / rng) * 100 : 50
    s = 100 - d
    [d, s]

// Bias text
biasText(d, s) =>
    txt = "Neutral"
    if d > 70
        txt := "Strong Bull"
    else if d > 55
        txt := "Bull"
    else if s > 70
        txt := "Strong Bear"
    else if s > 55
        txt := "Bear"
    txt

// Row color
rowColor(d, s) =>
    clr = color.new(color.gray, 75)
    if d > 70
        clr := color.new(color.green, 0)
    else if d > 55
        clr := color.new(color.green, 70)
    else if s > 70
        clr := color.new(color.red, 0)
    else if s > 55
        clr := color.new(color.red, 70)
    clr

// Data
[dD, sD] = calc("D")
[d4, s4] = calc("240")
[d1, s1] = calc("60")
[d15, s15] = calc("15")
[d5, s5] = calc("5")

// Table
var table t = table.new(pos, 8, 12, bgcolor=color.new(color.black, 100), border_width=1)

if barstate.islast
    table.clear(t, 0, 0, 7, 11)

    sc = 1 + xOff
    sr = 1 + yOff

    // Header
    table.cell(t, sc, sr, "TF", bgcolor=color.rgb(20,20,60), text_color=color.white, text_size=sizeVar)
    table.cell(t, sc + 1, sr, "Demand", bgcolor=color.rgb(20,20,60), text_color=color.white, text_size=sizeVar)
    table.cell(t, sc + 2, sr, "Supply", bgcolor=color.rgb(20,20,60), text_color=color.white, text_size=sizeVar)
    if showBias
        table.cell(t, sc + 3, sr, "Bias", bgcolor=color.rgb(20,20,60), text_color=color.white, text_size=sizeVar)

    // 1D
    clr1 = rowColor(dD, sD)
    table.cell(t, sc, sr + 1, "1D", bgcolor=clr1, text_color=color.white, text_size=sizeVar)
    table.cell(t, sc + 1, sr + 1, str.tostring(dD, "#.##") + "%", bgcolor=clr1, text_color=color.white, text_size=sizeVar)
    table.cell(t, sc + 2, sr + 1, str.tostring(sD, "#.##") + "%", bgcolor=clr1, text_color=color.white, text_size=sizeVar)
    if showBias
        table.cell(t, sc + 3, sr + 1, biasText(dD, sD), bgcolor=clr1, text_color=color.white, text_size=sizeVar)

    // 4H
    clr2 = rowColor(d4, s4)
    table.cell(t, sc, sr + 2, "4H", bgcolor=clr2, text_color=color.white, text_size=sizeVar)
    table.cell(t, sc + 1, sr + 2, str.tostring(d4, "#.##") + "%", bgcolor=clr2, text_color=color.white, text_size=sizeVar)
    table.cell(t, sc + 2, sr + 2, str.tostring(s4, "#.##") + "%", bgcolor=clr2, text_color=color.white, text_size=sizeVar)
    if showBias
        table.cell(t, sc + 3, sr + 2, biasText(d4, s4), bgcolor=clr2, text_color=color.white, text_size=sizeVar)

    // 1H
    clr3 = rowColor(d1, s1)
    table.cell(t, sc, sr + 3, "1H", bgcolor=clr3, text_color=color.white, text_size=sizeVar)
    table.cell(t, sc + 1, sr + 3, str.tostring(d1, "#.##") + "%", bgcolor=clr3, text_color=color.white, text_size=sizeVar)
    table.cell(t, sc + 2, sr + 3, str.tostring(s1, "#.##") + "%", bgcolor=clr3, text_color=color.white, text_size=sizeVar)
    if showBias
        table.cell(t, sc + 3, sr + 3, biasText(d1, s1), bgcolor=clr3, text_color=color.white, text_size=sizeVar)

    // 15M
    clr4 = rowColor(d15, s15)
    table.cell(t, sc, sr + 4, "15M", bgcolor=clr4, text_color=color.white, text_size=sizeVar)
    table.cell(t, sc + 1, sr + 4, str.tostring(d15, "#.##") + "%", bgcolor=clr4, text_color=color.white, text_size=sizeVar)
    table.cell(t, sc + 2, sr + 4, str.tostring(s15, "#.##") + "%", bgcolor=clr4, text_color=color.white, text_size=sizeVar)
    if showBias
        table.cell(t, sc + 3, sr + 4, biasText(d15, s15), bgcolor=clr4, text_color=color.white, text_size=sizeVar)

    // 5M
    clr5 = rowColor(d5, s5)
    table.cell(t, sc, sr + 5, "5M", bgcolor=clr5, text_color=color.white, text_size=sizeVar)
    table.cell(t, sc + 1, sr + 5, str.tostring(d5, "#.##") + "%", bgcolor=clr5, text_color=color.white, text_size=sizeVar)
    table.cell(t, sc + 2, sr + 5, str.tostring(s5, "#.##") + "%", bgcolor=clr5, text_color=color.white, text_size=sizeVar)
    if showBias
        table.cell(t, sc + 3, sr + 5, biasText(d5, s5), bgcolor=clr5, text_color=color.white, text_size=sizeVar)
````
