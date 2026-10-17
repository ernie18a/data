# Gaussian Distribution

- url: https://www.tradingview.com/script/vn9UeHhc-Gaussian-Distribution/
- type: indicator
- pine_id: PUB;8fac492c5a75438eb601d44d962df0aa
- version: 1.0

## Description

[b]Gaussian Distribution[/b]

A TradingView indicator that draws a Gaussian (normal) distribution, or "bell curve," of price over a lookback period on the right-hand side of the chart, along with the mean (μ) and ±1σ, ±2σ, and ±3σ reference lines.

[b]What it does[/b]

This indicator plots the statistical distribution of price over a configurable lookback window. The shape and width of the bell curve show how tightly price has clustered around its average, and the sigma lines mark ranges that contain roughly 68%, 95%, and 99.7% of a normal distribution.

[b]Practical tips[/b]

- Use the sigma lines as a quick read on how "normal" the current move is. A move beyond ±2σ is uncommon; beyond ±3σ is rare and often marks a volatility spike or a potential reversal zone.
- Switch Mean Type between [i]SMA[/i] and [i]Median[/i] to see how much outliers are distorting the picture.
- Lower the [i]Lookback Length[/i] for a faster, more responsive distribution on shorter timeframes; raise it for a calmer, longer-term view.
- Keep [i]Curve Steps[/i] around 100 to 120 for a good balance of smoothness and performance. Increase only if the curve looks visibly jagged.
- This is a statistical tool, not a standalone buy/sell signal. Combine it with your usual price action, volume, and trend analysis.

[b]Notes[/b]

- The curve and reference lines are recalculated and redrawn on the last bar only, so they represent the current lookback window at the right edge of the chart.
- The percentages described assume price roughly follows a normal distribution, which real markets do only approximately. Treat them as guidelines, not guarantees.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © cem_troy

//@version=6
indicator("Gaussian Distribution", overlay=true, max_lines_count=500)

length      = input.int(200, "Lookback Length", minval=2)
src         = input.source(close, "Price Source")
meanMode    = input.string("SMA", "Mean Type", options=["SMA", "Median"])
stdevMode   = input.string("Auto", "Std Dev", options=["Auto", "Manual"])
manualStdev = input.float(1.0, "Manual Std Dev", minval=0.000001)

steps       = input.int(120, "Curve Steps", minval=10, maxval=200)
rightOffset = input.int(5, "Right Offset (bars)", minval=0)
curveWidth  = input.int(40, "Curve Width (bars)", minval=5)
showFill    = input.bool(true, "Fill Curve")
lineColor   = input.color(color.new(color.blue, 0), "Line Color")
fillColor   = input.color(color.new(color.blue, 70), "Fill Color")

showRef     = input.bool(true, "Show μ / σ Reference Lines")
refSpan     = input.int(50, "Reference Span (bars)", minval=0)
meanColor   = input.color(color.orange, "Mean Line Color")
sigmaColor  = input.color(color.gray, "Sigma Line Color")

mu = meanMode == "SMA" ? ta.sma(src, length) : na

var float[] medianArr = array.new_float(0)
if meanMode == "Median"
    array.push(medianArr, src)
    if array.size(medianArr) > length
        array.shift(medianArr)
    mu := array.size(medianArr) == length ? array.median(medianArr) : na

sd = stdevMode == "Auto" ? ta.stdev(src, length) : manualStdev

hiPx = ta.highest(src, length)
loPx = ta.lowest(src, length)

pdf(price, m, s) =>
    z = (price - m) / s
    math.exp(-0.5 * z * z) / (s * math.sqrt(2 * math.pi))

var line[] drawn = array.new_line()
var label[] lbls = array.new_label()

if barstate.islast
    for l in drawn
        line.delete(l)
    array.clear(drawn)
    for lb in lbls
        label.delete(lb)
    array.clear(lbls)

    s = math.max(sd, 0.000001)
    if not na(mu) and hiPx > loPx
        peak = pdf(mu, mu, s)
        baseX = bar_index + rightOffset
        prevX = int(na)
        prevY = float(na)
        for i = 0 to steps
            price = loPx + (hiPx - loPx) * i / steps
            density = pdf(price, mu, s) / peak
            x = int(baseX + density * curveWidth)
            if not na(prevX)
                array.push(drawn, line.new(prevX, prevY, x, price, color=lineColor))
                if showFill
                    array.push(drawn, line.new(baseX, price, x, price, color=fillColor))
            prevX := x
            prevY := price

    if showRef and not na(mu)
        leftX = bar_index - refSpan
        rightX = bar_index + rightOffset
        array.push(drawn, line.new(leftX, mu, rightX, mu, color=meanColor, width=2))
        array.push(lbls, label.new(rightX, mu, "μ", style=label.style_label_left, color=color.new(meanColor, 80), textcolor=meanColor, size=size.small))
        for k = 1 to 3
            up = mu + k * s
            dn = mu - k * s
            array.push(drawn, line.new(leftX, up, rightX, up, color=sigmaColor, style=k == 1 ? line.style_dashed : line.style_dotted))
            array.push(drawn, line.new(leftX, dn, rightX, dn, color=sigmaColor, style=k == 1 ? line.style_dashed : line.style_dotted))
            array.push(lbls, label.new(rightX, up, "+" + str.tostring(k) + "σ", style=label.style_label_left, color=color.new(sigmaColor, 80), textcolor=sigmaColor, size=size.small))
            array.push(lbls, label.new(rightX, dn, "−" + str.tostring(k) + "σ", style=label.style_label_left, color=color.new(sigmaColor, 80), textcolor=sigmaColor, size=size.small))
````
