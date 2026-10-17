# Swing Fibonacci [BigBeluga]

- url: https://www.tradingview.com/script/oC9m0JpD-Swing-Fibonacci-BigBeluga/
- type: indicator
- pine_id: PUB;7ae0727bdc8840ca879006580f509f33
- version: 1.0

## Description

[b]Swing Fibonacci [BigBeluga][/b] is a high-precision geometric framework that merges traditional swing structure with parametric spiral projections. Unlike standard Fibonacci retracements that use static horizontal lines, this tool projects expanding harmonic spirals from major structural turning points to map out the "natural geometry" of the market.

By calculating the mathematical relationship between price volatility and time, the indicator identifies expansion shells where price is naturally inclined to react, stall, or reverse.

[b]🔵 CONCEPTS[/b]
[list]
[*] [b]Macro Swing Detection:[/b] The engine utilizes a high-threshold lookback window (50–100 bars) to filter out market noise. It only identifies the most significant structural pivots, ensuring the spirals are anchored to "institutional" levels rather than minor retail fluctuations.
[*] [b]Anchor Points & Structural Mapping:[/b] At every confirmed trend reversal, the script anchors a [b]⦾[/b] symbol. It then draws a solid "Swing Leg" connecting the current anchor to the previous one, providing a clear visual map of the market's structural transitions.
[image]https://www.tradingview.com/x/IwLQbb1S/[/image]
[*] [b]Parametric Fibonacci Spirals:[/b] The spirals are generated using a high-resolution 300-step parametric calculation. This ensures the curve remains perfectly smooth and mathematically accurate regardless of how many bars are on the screen.
[image]https://www.tradingview.com/x/eBwpOIl8/[/image]
[*] [b]Adaptive Price Normalization:[/b] To prevent the "squashed" look common in geometric tools, the spiral dynamically rescales itself based on the price range of the last 500 bars. This ensures the geometry stays proportional to current market volatility.
[/list]

[b]🔵 FEATURES[/b]
[list]
[*] [b]Institutional Data Dashboard:[/b] Located in the top-right corner, the dashboard provides real-time stats including the exact [b]Anchor Price[/b], the current [b]Trend Status[/b] (BULLISH ▲ or BEARISH ▼), and the [b]Swing %[/b] move from the low/high.
[image]https://www.tradingview.com/x/SAzi7VOj/[/image]
[*] [b]Real-Time Swing Tracking:[/b] A dynamic dashed line follows the current price, connecting it back to the active anchor point. This allows you to visualize the current "swing in progress" before it is finalized.
[image]https://www.tradingview.com/x/WA9dd1Gr/[/image]
[*] [b]Parametric Control Suite:[/b] 
  • [b]Radius:[/b] Adjusts the vertical "stretch" and overall size.
  • [b]Spiral Qty:[/b] Controls the number of rotations (up to 10) to project further into the future.
[image]https://www.tradingview.com/x/Lesvtvhb/[/image]
[image]https://www.tradingview.com/x/IsgeSFze/[/image]
[*] [b]Color Flow Visualization:[/b] The spirals utilize a professional gradient transition from the bearish color (inner) to the bullish color (outer), visually representing the expansion of price energy.
[/list]

[b]🔵 HOW TO USE[/b]
[list]
[*] [b]Identify Reaction Zones:[/b] Price often treats the edges of the spiral curves as dynamic support and resistance. Look for "confluence" where a spiral curve intersects with a horizontal level or a previous swing point.
[image]https://www.tradingview.com/x/wCuuwc75/[/image]
[*] [b]Forecasting Expansion:[/b]
  • [b]Bullish Spiral:[/b] Projects outward from a swing low, highlighting potential take-profit zones or areas where the trend might exhaust.
  • [b]Bearish Spiral:[/b] Projects from a swing high, identifying "expansion floors" for short positions.
[*] [b]Trend Confirmation:[/b] Use the [b]Trend Squares[/b] at the bottom of the chart for a quick pulse on the current directional bias without cluttering the main price action.
[*] [b]Harmonic Timing:[/b] The spiral's horizontal reach provides a "time" component. If price reaches a specific spiral arc at a specific time, it often marks a high-probability turning point in the cycle.
[/list]

[b]🔵 CONCLUSION[/b]
[b]Swing Fibonacci [BigBeluga][/b] transforms abstract price action into a tangible geometric forecast. By anchoring dynamic, price-normalized spirals to the market’s strongest turning points, it provides a unique lens through which to view volatility, extension, and mean reversion. 

Ideal for harmonic traders, swing analysts, and anyone looking for a deeper mathematical edge in their structural analysis.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga

//@version=6
indicator("Swing Fibonacci [BigBeluga]", overlay = true, max_lines_count = 500, max_labels_count = 500, max_bars_back = 5000)

// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

swingLength = input.int(50, "Swing Structure", minval = 50, maxval = 100, tooltip = "Determines how 'significant' a high or low must be. Higher values find major trends.")
radius      = input.float(4, "Radius", minval = 1, maxval = 8, step = 0.1, tooltip = "Controls the size and vertical stretch of the spiral.")
spirals     = input.int(6, "Spirals qty", maxval = 10, tooltip = "The number of rotations the spiral makes around the anchor point.")
color1      = input.color(color.lime, "Bullish Color", inline = "2", tooltip = "Color for bullish trends and the outer spiral.")
color2      = input.color(color.fuchsia, "Bearish Color", inline = "2", tooltip = "Color for bearish trends and the inner spiral.")

var Hi = 0
var Hv = high
var Li = 0
var Lv = low
var direction = false
var float lockedRange = na
var int lockedLen = 0
// }


// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
// Global calculations to prevent the CW10003 warning and ensure data consistency
high500 = ta.highest(high, 500)
low500  = ta.lowest(low, 500)
currentDist = high500 - low500

H = ta.highest(high, swingLength)
L = ta.lowest(low, swingLength)

if high == H
    Hi := bar_index
    Hv := high
    direction := true

if low == L
    Li := bar_index
    Lv := low
    direction := false

var swingPrice = float(na)
var swingIndex = int(na)

// Lock parameters and plot confirmed swing points
if direction != direction[1]
    lockedRange := currentDist
    lockedLen   := bar_index - (direction ? Li : Hi) + 20
    
    if direction
        swingPrice := Lv
        swingIndex := Li
        label.new(Li, Lv, "⦾", style = label.style_label_center, textcolor = color1, color = color.new(color.black, 100))
        line.new(Li, Lv, Hi[1], Hv[1], color = color2)
    else
        swingIndex := Hi
        swingPrice := Hv
        label.new(Hi, Hv, "⦾", style = label.style_label_center, textcolor = color2, color = color.new(color.black, 100))
        line.new(Li[1], Lv[1], Hi, Hv, color = color1)

// Trend direction squares at the bottom of the screen
plotshape(direction, title="Bullish Trend", style=shape.square, location=location.bottom, color=color1, size=size.tiny)
plotshape(not direction, title="Bearish Trend", style=shape.square, location=location.bottom, color=color2, size=size.tiny)

// Real-time Swing Line & Dashboard
var line rtLine = na
float activePrice = direction ? high : low
float movePct = ((activePrice - swingPrice) / swingPrice) * 100

if barstate.islast
    line.delete(rtLine)
    rtLine := line.new(swingIndex, swingPrice, bar_index, activePrice, color = color.gray, style = line.style_dashed, width = 1)

    var table dash = table.new(position.top_right, 2, 3, bgcolor = color.new(color.black, 70), border_width = 2, border_color = chart.bg_color)
    table.cell(dash, 0, 0, "Anchor Price", text_color = color.white, text_size = size.normal)
    table.cell(dash, 1, 0, str.tostring(swingPrice, format.mintick), text_color = color.white, text_size = size.normal)
    table.cell(dash, 0, 1, "Direction", text_color = color.white, text_size = size.normal)
    table.cell(dash, 1, 1, direction ? "BULLISH ▲" : "BEARISH ▼", text_color = direction ? color1 : color2, text_size = size.normal)
    table.cell(dash, 0, 2, "Swing %", text_color = color.white, text_size = size.normal)
    table.cell(dash, 1, 2, str.tostring(movePct, "0.00") + "%", text_color = color.white, text_size = size.normal)

// Spiral Generation Function
f_spiral(_anchorIndex, _anchorPrice, _spirals, _range, _len) =>
    pi = math.pi
    var lines = array.new_line()
    var labels = array.new_label()
    var yvals  = array.new_float()
    var xvals  = array.new_int()

    for l in lines
        l.delete()
    for l in labels
        l.delete()

    array.clear(yvals), array.clear(xvals), array.clear(lines), array.clear(labels)

    // SET RESOLUTION: 300 steps ensures a smooth spiral regardless of bar count
    int resolution = 300 

    for i = 0 to resolution - 1
        // t now increments based on resolution, not bars
        t = i / (resolution - 1) * _spirals * pi
        
        x_raw = t * math.cos(t) * -1 / pi * radius / _spirals * _len + _anchorIndex
        y = t * math.sin(t) * (direction ? -1 : 1) / pi
        
        array.push(yvals, y)
        array.push(xvals, int(x_raw))

    yRange = array.max(yvals) - array.min(yvals)
    float scaleFactor = (_range / yRange) * radius

    // Draw using the fixed resolution count
    for i = 1 to resolution - 1
        x1 = array.get(xvals, i - 1), x2 = array.get(xvals, i)
        y1 = _anchorPrice + array.get(yvals, i - 1) * scaleFactor
        y2 = _anchorPrice + array.get(yvals, i) * scaleFactor
        
        col = x1 - bar_index >= 500 ? color.new(color.black, 100) : color.from_gradient(i, 1, resolution - 1, color2, color1)
        lines.push(line.new(x1, y1, x2, y2, color = col, width = 2))

        if i == resolution - 1
            infoText = "Spirals: " + str.tostring(_spirals) + "\nRadius: " + str.tostring(radius)
            labels.push(label.new(x2, y2, infoText, style=label.style_label_left, color=color.new(color.black, 40), textcolor=color.white, size=size.normal))

// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
if not na(swingPrice) and barstate.islast
    f_spiral(swingIndex, swingPrice, spirals, lockedRange, lockedLen)

// }
````
