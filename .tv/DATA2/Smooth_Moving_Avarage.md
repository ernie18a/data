<!-- tradingview-pine-id: PUB;a594e8ad10c94455b87f5a362a2c870e -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Smooth Moving Avarage

Source: https://www.tradingview.com/script/8wWpFhYO-Smooth-Moving-Avarage/

## Description

Smooth Moving Average

Smooth Moving Average is a trend-following moving average designed to provide a cleaner and smoother view of market direction while reducing short-term price noise.

The indicator combines multiple EMA calculations with a multi-stage smoothing process to create a smooth and responsive moving average. It also uses ATR-normalized slope analysis to evaluate the current trend condition while adapting to changing market volatility.

The moving average automatically changes color based on its current directional state:

Up Color — Indicates an upward trend condition.

Down Color — Indicates a downward trend condition.

Flat Color — Indicates a neutral or low-momentum condition.

Main Settings

• Multi-stage EMA smoothing for a cleaner trend line
• Adjustable Period for controlling overall sensitivity
• Smooth Length and Smooth Count for additional noise reduction
• ATR-based trend analysis for volatility-adjusted trend detection
• Adjustable Trend Threshold for controlling trend sensitivity
• Fully customizable trend colors
• Clean and minimal chart visualization

How It Works

The indicator first calculates a base moving average using a combination of faster and slower EMA calculations. This creates a responsive foundation while helping reduce some of the lag normally associated with traditional moving averages.

The resulting moving average is then processed through multiple configurable smoothing stages to create a cleaner trend line. Finally, its slope is normalized using ATR to determine whether the current movement represents an upward trend, downward trend, or relatively flat condition.

Smooth Moving Average is designed as a trend analysis and visualization tool. It can be used alongside price action, market structure, and other technical analysis methods to help identify the prevailing market direction.

---

## Source Code

````pine
//@version=6
indicator("Smooth Moving Avarage", overlay = true)

groupEma = "EmaMA Settings"
groupTrend = "Trend Settings"
groupColor = "Color Settings"

period = input.int(110, "Period", minval = 1, group = groupEma)
smoothLength = input.int(15, "Smooth Length", minval = 1, group = groupEma)
smoothCount = input.int(6, "Smooth Count", minval = 1, maxval = 6, group = groupEma)

atrPeriod = input.int(14, "ATR Period", minval = 1, group = groupTrend)
trendThreshold = input.float(0.5, "Trend Threshold", minval = 0.0, step = 0.1, group = groupTrend)

upColor = input.color(#0DF1C6, "Up Color", group = groupColor)
downColor = input.color(#871EE9, "Down Color", group = groupColor)
flatColor = input.color(color.gray, "Flat Color", group = groupColor)

emaSmooth(source, length, previous) =>
    alpha = 2.0 / (length + 1.0)
    na(previous) ? source : previous + alpha * (source - previous)

halfPeriod = math.max(1, math.round(period / 2))
sqrtPeriod = math.max(1, math.round(math.sqrt(period)))

emaFast = ta.ema(close, halfPeriod)
emaSlow = ta.ema(close, period)
emaDifference = 2.0 * emaFast - emaSlow
emaBase = ta.ema(emaDifference, sqrtPeriod)

var array<float> smoothValues = array.new_float(6, na)

smooth1 = emaBase
smooth2 = emaBase
smooth3 = emaBase
smooth4 = emaBase
smooth5 = emaBase
smooth6 = emaBase

for index = 0 to smoothCount - 1
    previous = array.get(smoothValues, index)
    source = index == 0 ? emaBase : array.get(smoothValues, index - 1)
    smoothedEma = emaSmooth(source, smoothLength, previous)
    array.set(smoothValues, index, smoothedEma)

    if index == 0
        smooth1 := smoothedEma
    if index == 1
        smooth2 := smoothedEma
    if index == 2
        smooth3 := smoothedEma
    if index == 3
        smooth4 := smoothedEma
    if index == 4
        smooth5 := smoothedEma
    if index == 5
        smooth6 := smoothedEma

atr = ta.atr(atrPeriod)

normalizedSlope = atr > 0 ? (smooth1 - smooth1[1]) / (atr * 0.1) : 0.0

isUpTrend = normalizedSlope < -trendThreshold
isDownTrend = normalizedSlope > trendThreshold
isFlat = not isUpTrend and not isDownTrend

emaColor = normalizedSlope < 0 ? color.from_gradient(normalizedSlope, -trendThreshold, 0, upColor, flatColor) : color.from_gradient(normalizedSlope, 0, trendThreshold, flatColor, downColor)

p1 = plot(smooth1, "EmaMA 1", color = emaColor, linewidth = 1, editable = false)
p2 = plot(smooth2, "EmaMA 2", color = emaColor, linewidth = 1, editable = false)
p3 = plot(smooth3, "EmaMA 3", color = emaColor, linewidth = 1, editable = false)
p4 = plot(smooth4, "EmaMA 4", color = emaColor, linewidth = 1, editable = false)
p5 = plot(smooth5, "EmaMA 5", color = emaColor, linewidth = 1, editable = false)
p6 = plot(smooth6, "EmaMA 6", color = emaColor, linewidth = 1, editable = false)

fill(p1, p2, color = color.from_gradient(1, 1, 5, color.new(emaColor, 50), color.new(emaColor, 90)))
fill(p2, p3, color = color.from_gradient(2, 1, 5, color.new(emaColor, 50), color.new(emaColor, 90)))
fill(p3, p4, color = color.from_gradient(3, 1, 5, color.new(emaColor, 50), color.new(emaColor, 90)))
fill(p4, p5, color = color.from_gradient(4, 1, 5, color.new(emaColor, 50), color.new(emaColor, 90)))
fill(p5, p6, color = color.from_gradient(5, 1, 5, color.new(emaColor, 50), color.new(emaColor, 90)))
````
