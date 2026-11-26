# Volume Weighted Median Oscillator [AlgoAlpha]

- url: https://www.tradingview.com/script/HOMrw9sY-Volume-Weighted-Median-Oscillator-AlgoAlpha/
- type: indicator
- pine_id: PUB;8aaf19365a5a4e0d8351e2b3eda74fc7
- version: 1.0

## Description

🟠 OVERVIEW

This script measures price movement relative to a volume-weighted median instead of a simple average. It builds an oscillator that reflects where price is positioned compared to the level where most trading activity is concentrated. This helps reduce the effect of outliers and highlights more balanced price zones.

The output combines a momentum histogram and a smoothed oscillator line, both normalized by recent price range. It also includes a signal line and visual zones to show when price is stretched relative to its volume-based center.

🟠 CONCEPTS

[list]

[*] Volume-Weighted Median — The price level where half of the traded volume occurred above and half below within the lookback window.

[*] Normalized Momentum — The difference between current price and the weighted median, divided by an average price range to keep values comparable across markets.

[*] Median Trend Deviation — The distance between the median and its longer-term EMA, used to define the main oscillator direction.

[*] Volume Normalization — Current volume divided by its moving average to highlight periods of higher activity.

[*] Signal Line — An EMA of the oscillator used to track short-term direction changes.

[/list]

🟠 FEATURES

[list]
[*] Dual Output Structure — Combines histogram and oscillator line.
  • Histogram shows short-term momentum shifts.
  • Oscillator line reflects broader deviation from median trend.
[image]https://www.tradingview.com/x/jd3SCzCo/[/image]

[*] Optional Smoothing — Applies WMA smoothing to reduce noise in both outputs.
[image]https://www.tradingview.com/x/uFz8eMSu/[/image]

[*] Dynamic Ribbon — Visual fill between oscillator and signal line.
  • Changes color based on direction.
  • Intensity reflects strength of separation.
[image]https://www.tradingview.com/x/Wm3VivOI/[/image]
[image]https://www.tradingview.com/x/Zjeo6mo0/[/image]

[*] Overbought and Oversold Zones — Gradient fills beyond defined thresholds.
  • Expands visually as extremes increase.
  • Helps identify stretched conditions.
[image]https://www.tradingview.com/x/3K12BQwg/[/image]

[*] Volume-Aware Zero Line — Brightness increases when current volume exceeds its average.
[image]https://www.tradingview.com/x/mfaWqkhx/[/image]

[*] Volume-Weighted Median Core — Uses sorted price and volume arrays to compute a true weighted median.
  • Reduces sensitivity to spikes compared to mean-based indicators.
  • Anchors calculations to where trading activity is concentrated.

[*] Built-in Alerts — Includes conditions for crosses, zone entries, and ribbon flips.

[/list]

🟠 HOW TO USE

[list]

[*] Watch the histogram crossing above or below zero — shows short-term momentum shifts relative to the median.

[*] Use the main oscillator crossing zero — indicates broader directional bias change.

[*] Track crosses between the oscillator and its signal line — helps identify early trend shifts.

[*] Observe entries into extreme zones — signals that price is stretched relative to its volume center.

[*] Pay attention to ribbon color changes — confirms alignment between momentum and trend.

[*] Check zero line brightness — higher brightness suggests stronger participation behind moves.

[/list]

🟠 CONCLUSION

Volume Weighted Median Oscillator combines a volume-based median, normalized momentum, and trend deviation into one view. It focuses on where trading activity is concentrated instead of simple averages. This gives a clearer read on price imbalance and helps traders judge when moves are supported or stretched.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AlgoAlpha

//@version=6
indicator("Volume Weighted Median Oscillator [AlgoAlpha]", "AlgoAlpha - Volume Weighted Median Osc", explicit_plot_zorder = true)

main_group = "main settings"
appearance_group = "appearance"

len = input.int(21, "Length", minval = 1, group = main_group, tooltip = "Oscillator lookback. Increasing this value reduces noise, while decreasing it makes signals faster.")
extremeLevel = input.float(3.0, "Extreme Level", minval = 0.1, step = 0.25, group = main_group, tooltip = "Threshold used for the overbought and oversold gradient fills.")
smooth = input.bool(true, "Smooth Outputs", group = main_group, tooltip = "When enabled, applies a 7-period WMA to both the histogram columns and the main oscillator line.")
ribbon = input.bool(true, "Ribbon", group = main_group, tooltip = "When enabled, fills the area between the main oscillator line and its EMA signal line using a dynamic gradient.")
volNormLookback = input.int(21, "Volume Normalization Length", minval = 1, group = main_group, tooltip = "Lookback used to normalize volume. The zero line becomes brighter as current volume rises above its normalized average.")

green = input.color(#00ffbb, "Bullish Colour", group = appearance_group, tooltip = "Bullish color used for positive histogram columns, oversold fills, and bullish ribbon states.")
red = input.color(#ff1100, "Bearish Colour", group = appearance_group, tooltip = "Bearish color used for negative histogram columns, overbought fills, and bearish ribbon states.")

var prices = array.new_float()
var volumes = array.new_float()

prices.unshift(close)
volumes.unshift(volume)

while prices.size() > len
    prices.pop()

while volumes.size() > len
    volumes.pop()

totalVolume = volumes.sum()
w_midpoint = totalVolume / 2.0
a = prices.sort_indices(order.ascending)
count = 0.0
float w_median = na

if totalVolume > 0
    for i = 0 to prices.size() - 1
        idx = a.get(i)
        count += volumes.get(idx)
        if count >= w_midpoint
            w_median := prices.get(idx)
            break

rangeBase = math.max(ta.ema(high - low, 14), syminfo.mintick)
mom = close - w_median
rawHist = mom / rangeBase
rawMain = (w_median - ta.ema(w_median, len * 3)) / rangeBase
hist = smooth ? ta.wma(rawHist, 7) : rawHist
mainLine = smooth ? ta.wma(rawMain, 7) : rawMain
mainSignal = ta.ema(mainLine, len)

normalizedVolume = volume / math.max(ta.sma(volume, volNormLookback), 1.0)
zeroLineColor = color.from_gradient(normalizedVolume, 1.0, 2.0, color.new(chart.fg_color, 90), color.new(chart.fg_color, 0))

zeroPlot = plot(0, "Zero Line", color = zeroLineColor, linewidth = 3)
hline(extremeLevel, "Overbought Line", color = color.new(red, 70), linestyle = hline.style_dashed)
hline(-extremeLevel, "Oversold Line", color = color.new(green, 70), linestyle = hline.style_dashed)

ribbonState = mainLine >= mainSignal ? 1 : -1
ribbonStrength = math.min(math.abs(mainLine - mainSignal) / math.max(extremeLevel, syminfo.mintick), 1.0)
ribbonColor = ribbonState == 1 ? color.from_gradient(ribbonStrength, 0.0, 1.0, color.new(green, 0), color.new(green, 80)) : color.from_gradient(ribbonStrength, 0.0, 1.0, color.new(red, 0), color.new(red, 80))

upperNoOverlap = ribbon and mainLine > 0 ? math.min(mainLine, mainSignal) : mainLine
lowerNoOverlap = ribbon and mainLine < 0 ? math.max(mainLine, mainSignal) : mainLine
upperFillValue = upperNoOverlap > extremeLevel ? upperNoOverlap : extremeLevel
lowerFillValue = lowerNoOverlap < -extremeLevel ? lowerNoOverlap : -extremeLevel

upperBasePlot = plot(extremeLevel, "Overbought Fill Base", display = display.none)
upperSignalPlot = plot(upperFillValue, "Overbought Fill Top", display = display.none)
lowerBasePlot = plot(-extremeLevel, "Oversold Fill Base", display = display.none)
lowerSignalPlot = plot(lowerFillValue, "Oversold Fill Bottom", display = display.none)

upperTopColor = upperFillValue > extremeLevel ? color.from_gradient(upperFillValue, extremeLevel, extremeLevel * 2.0, color.new(red, 100), color.new(red, 0)) : color.new(red, 100)
lowerBottomColor = lowerFillValue < -extremeLevel ? color.from_gradient(lowerFillValue, -extremeLevel * 2.0, -extremeLevel, color.new(green, 0), color.new(green, 100)) : color.new(green, 100)

fill(upperBasePlot, upperSignalPlot, upperFillValue, extremeLevel, upperTopColor, color.new(red, 100), title = "Overbought Gradient Fill")
fill(lowerBasePlot, lowerSignalPlot, -extremeLevel, lowerFillValue, color.new(green, 100), lowerBottomColor, title = "Oversold Gradient Fill")

histAbs = math.abs(hist)
histAbsPrev = nz(math.abs(hist[1]), histAbs)
histMovingTowardZero = histAbs < histAbsPrev
histTransparency = histMovingTowardZero ? 75 : 35
histColor = hist >= 0 ? color.new(green, histTransparency) : color.new(red, histTransparency)

plot(hist, "Momentum Columns", color = histColor, style = plot.style_columns, linewidth = 4)

pMain = plot(mainLine, "Median Oscillator", color = color.new(chart.fg_color, 90), linewidth = 2)
pMainSignal = plot(ribbon ? mainSignal : na, "Median Oscillator EMA Signal", color = color.new(color.white, 100))

fill(pMain, pMainSignal, ribbon ? ribbonColor : na, title = "Median Oscillator Ribbon")

histBullCross = ta.crossover(hist, 0)
histBearCross = ta.crossunder(hist, 0)
mainBullCross = ta.crossover(mainLine, 0)
mainBearCross = ta.crossunder(mainLine, 0)
mainSignalBullCross = ta.crossover(mainLine, mainSignal)
mainSignalBearCross = ta.crossunder(mainLine, mainSignal)
overboughtEntry = ta.crossover(mainLine, extremeLevel)
overboughtExit = ta.crossunder(mainLine, extremeLevel)
oversoldEntry = ta.crossunder(mainLine, -extremeLevel)
oversoldExit = ta.crossover(mainLine, -extremeLevel)
ribbonBullFlip = ribbonState == 1 and ribbonState[1] == -1
ribbonBearFlip = ribbonState == -1 and ribbonState[1] == 1

alertcondition(histBullCross, "Histogram Bullish Cross")
alertcondition(histBearCross, "Histogram Bearish Cross")
alertcondition(mainBullCross, "Median Oscillator Bullish Zero Cross")
alertcondition(mainBearCross, "Median Oscillator Bearish Zero Cross")
alertcondition(mainSignalBullCross, "Median Oscillator Crossed Above EMA Signal")
alertcondition(mainSignalBearCross, "Median Oscillator Crossed Below EMA Signal")
alertcondition(overboughtEntry, "Median Oscillator Entered Overbought Zone")
alertcondition(overboughtExit, "Median Oscillator Exited Overbought Zone")
alertcondition(oversoldEntry, "Median Oscillator Entered Oversold Zone")
alertcondition(oversoldExit, "Median Oscillator Exited Oversold Zone")
alertcondition(ribbonBullFlip, "Ribbon Turned Bullish")
alertcondition(ribbonBearFlip, "Ribbon Turned Bearish")
````
