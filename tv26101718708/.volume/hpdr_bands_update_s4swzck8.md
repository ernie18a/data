# HPDR Bands Update

- url: https://www.tradingview.com/script/s4SwzCk8-HPDR-Bands-Update/
- type: indicator
- pine_id: PUB;2f2303bc76074956add076e23147ded4
- version: 1.0

## Description

The range levels are not treated as raw percentages of one volatility unit. In standard deviation, ATR, and hybrid modes, the levels map to a calibrated probability-style multiplier curve:

- `38.2` -> inner statistical movement
- `50` -> balance zone
- `61.8` -> active extension
- `78.6` -> strong extension
- `88.3` -> exhaustion warning
- `95` -> extreme
- `97.5` -> very extreme
- `100` -> maximum outer band

For standard deviation mode, this resembles central normal-distribution coverage levels. For ATR mode, the same curve is used as a distance calibration around the median. For percentile mode, the bands are based on actual recent absolute deviations from the median, which is often more robust for non-normal markets.

## Source Code

````pine
//@version=6
indicator("HPDR Bands", overlay=true, max_labels_count=500, max_lines_count=100)

// -----------------------------------------------------------------------------
// Groups
// -----------------------------------------------------------------------------
groupMain   = "Main Properties"
groupCalc   = "Calculation Engine"
groupScale  = "Range Scale Settings"
groupPlot   = "Range Plot Settings"
groupVisual = "Visual Style"
groupLabels = "Labels"
groupAlerts = "Alerts"
groupFilter = "Experimental Filters"

// -----------------------------------------------------------------------------
// Main Properties
// -----------------------------------------------------------------------------
src              = input.source(close, "Price Source", group=groupMain)
samplingLength   = input.int(7, "Sampling Length", minval=1, group=groupMain)
maxArraySize     = input.int(100000, "Max Array Size", minval=1000, maxval=100000, group=groupMain)
projectForward   = input.bool(false, "Project Bands Forward", group=groupMain)
scaleOn          = input.bool(true, "Scale On", group=groupMain)
fillOn           = input.bool(true, "Fill On", group=groupMain)
textOn           = input.bool(true, "Text On", group=groupMain)
rangeOn          = input.bool(true, "Range On", group=groupMain)
linefillOn       = input.bool(true, "Linefill On", group=groupMain)

// -----------------------------------------------------------------------------
// Calculation Engine
// -----------------------------------------------------------------------------
calcMode       = input.string("Hybrid", "Engine Mode", options=["Standard Deviation", "ATR", "Percentile", "Hybrid"], group=groupCalc)
medianType     = input.string("EMA", "Median Type", options=["SMA", "EMA", "WMA", "RMA", "VWMA"], group=groupCalc)
volSmoothType  = input.string("RMA", "Volatility Smoothing Type", options=["SMA", "EMA", "WMA", "RMA", "VWMA"], group=groupCalc)
volSmoothLen   = input.int(3, "Volatility Smoothing Length", minval=1, group=groupCalc)
percentLookback = input.int(200, "Percentile Rolling Lookback", minval=20, maxval=10000, group=groupCalc)
stdevWeight    = input.float(0.50, "Hybrid StDev Weight", minval=0.0, maxval=1.0, step=0.05, group=groupCalc)

// -----------------------------------------------------------------------------
// Range Scale Settings
// -----------------------------------------------------------------------------
range1 = input.float(38.2, "Range 1", minval=1.0, maxval=100.0, step=0.1, group=groupScale)
range2 = input.float(50.0, "Range 2", minval=1.0, maxval=100.0, step=0.1, group=groupScale)
range3 = input.float(61.8, "Range 3", minval=1.0, maxval=100.0, step=0.1, group=groupScale)
range4 = input.float(78.6, "Range 4", minval=1.0, maxval=100.0, step=0.1, group=groupScale)
range5 = input.float(88.3, "Range 5", minval=1.0, maxval=100.0, step=0.1, group=groupScale)
range6 = input.float(95.0, "Range 6", minval=1.0, maxval=100.0, step=0.1, group=groupScale)
range7 = input.float(97.5, "Range 7", minval=1.0, maxval=100.0, step=0.1, group=groupScale)
range8 = input.float(100.0, "Range 8", minval=1.0, maxval=100.0, step=0.1, group=groupScale)

bandExpansionStrength = input.float(1.0, "Band Expansion Strength", minval=0.25, maxval=3.0, step=0.05, group=groupScale)
outerBandMultiplier   = input.float(3.0, "Maximum Outer Multiplier", minval=2.25, maxval=6.0, step=0.05, group=groupScale)

// -----------------------------------------------------------------------------
// Range Plot Settings
// -----------------------------------------------------------------------------
showMedian = input.bool(true, "Show Median Line", group=groupPlot)
showUpper  = input.bool(true, "Show Upper Bands", group=groupPlot)
showLower  = input.bool(true, "Show Lower Bands", group=groupPlot)
lineWidth  = input.int(1, "Band Line Width", minval=1, maxval=4, group=groupPlot)
medianWidth = input.int(2, "Median Line Width", minval=1, maxval=4, group=groupPlot)

// -----------------------------------------------------------------------------
// Visual Style
// -----------------------------------------------------------------------------
lineTransparency = input.int(40, "Line Transparency", minval=0, maxval=100, group=groupVisual)
fillTransparency = input.int(90, "Fill Transparency", minval=0, maxval=100, group=groupVisual)

color1 = input.color(color.blue, "Range 1 Color", group=groupVisual)
color2 = input.color(color.aqua, "Range 2 Color", group=groupVisual)
color3 = input.color(color.green, "Range 3 Color", group=groupVisual)
color4 = input.color(color.lime, "Range 4 Color", group=groupVisual)
color5 = input.color(color.yellow, "Range 5 Color", group=groupVisual)
color6 = input.color(color.orange, "Range 6 Color", group=groupVisual)
color7 = input.color(color.rgb(255, 87, 34), "Range 7 Color", group=groupVisual)
color8 = input.color(color.red, "Range 8 Color", group=groupVisual)
medianColor = input.color(color.white, "Median Color", group=groupVisual)

// -----------------------------------------------------------------------------
// Labels
// -----------------------------------------------------------------------------
showLabels = input.bool(true, "Right-Side Labels", group=groupLabels)
labelOffset = input.int(1, "Label Offset Bars", minval=1, maxval=50, group=groupLabels)
labelTextColor = input.color(color.white, "Label Text Color", group=groupLabels)

// -----------------------------------------------------------------------------
// Alerts
// -----------------------------------------------------------------------------
alertFiltersOn = input.bool(false, "Apply Experimental Filters To Price Alerts", group=groupAlerts)

// -----------------------------------------------------------------------------
// Experimental Filters
// -----------------------------------------------------------------------------
useRsiFilter = input.bool(false, "RSI Filter", group=groupFilter)
rsiLength    = input.int(14, "RSI Length", minval=2, group=groupFilter)
rsiBullMin   = input.float(50.0, "RSI Bull Minimum", minval=1.0, maxval=99.0, group=groupFilter)
rsiBearMax   = input.float(50.0, "RSI Bear Maximum", minval=1.0, maxval=99.0, group=groupFilter)

useTrendFilter = input.bool(false, "EMA Trend Filter", group=groupFilter)
trendLength    = input.int(200, "Trend EMA Length", minval=2, group=groupFilter)

useVolumeFilter = input.bool(false, "Volume Filter", group=groupFilter)
volumeLength    = input.int(20, "Volume Average Length", minval=1, group=groupFilter)
volumeFactor    = input.float(1.0, "Volume Factor", minval=0.1, step=0.1, group=groupFilter)

useCandleRejectionFilter = input.bool(false, "Candle Rejection Filter", group=groupFilter)
wickToBodyRatio = input.float(1.25, "Wick To Body Ratio", minval=0.1, step=0.05, group=groupFilter)

// -----------------------------------------------------------------------------
// Functions
// -----------------------------------------------------------------------------
f_ma(_source, _length, _type) =>
    switch _type
        "SMA"  => ta.sma(_source, _length)
        "EMA"  => ta.ema(_source, _length)
        "WMA"  => ta.wma(_source, _length)
        "RMA"  => ta.rma(_source, _length)
        "VWMA" => ta.vwma(_source, _length)

f_lerp(_x, _x0, _x1, _y0, _y1) =>
    _x1 == _x0 ? _y0 : _y0 + (_x - _x0) * (_y1 - _y0) / (_x1 - _x0)

// Converts HPDR range levels into a calibrated distance curve.
// The values approximate central normal coverage zones for volatility modes.
f_baseMultiplier(_level, _outer) =>
    _l = math.max(1.0, math.min(_level, 100.0))
    _z = _l <= 38.2 ? f_lerp(_l, 1.0, 38.2, 0.05, 0.50) :
         _l <= 50.0 ? f_lerp(_l, 38.2, 50.0, 0.50, 0.674) :
         _l <= 61.8 ? f_lerp(_l, 50.0, 61.8, 0.674, 0.873) :
         _l <= 78.6 ? f_lerp(_l, 61.8, 78.6, 0.873, 1.24) :
         _l <= 88.3 ? f_lerp(_l, 78.6, 88.3, 1.24, 1.57) :
         _l <= 95.0 ? f_lerp(_l, 88.3, 95.0, 1.57, 1.96) :
         _l <= 97.5 ? f_lerp(_l, 95.0, 97.5, 1.96, 2.24) :
         f_lerp(_l, 97.5, 100.0, 2.24, _outer)
    scaleOn ? _outer * math.pow(_z / _outer, bandExpansionStrength) : (_l / 100.0) * _outer * bandExpansionStrength

f_pctAdjust(_distance, _outerDistance) =>
    _outerDistance <= 0.0 ? _distance : scaleOn ? _outerDistance * math.pow(math.min(_distance / _outerDistance, 1.0), bandExpansionStrength) : _distance * bandExpansionStrength

f_labelText(_name, _value, _range) =>
    _name + "\n" + str.tostring(_value, format.mintick) + "\n" + str.tostring(_range, "#.0") + "%"

// -----------------------------------------------------------------------------
// Core Calculation
// -----------------------------------------------------------------------------
median = f_ma(src, samplingLength, medianType)

rawStdev = ta.stdev(src, samplingLength)
rawAtr   = ta.atr(samplingLength)
atrWeight = 1.0 - stdevWeight

baseVol =
     calcMode == "Standard Deviation" ? rawStdev :
     calcMode == "ATR" ? rawAtr :
     calcMode == "Hybrid" ? rawStdev * stdevWeight + rawAtr * atrWeight :
     na

volatility = volSmoothLen <= 1 ? baseVol : f_ma(baseVol, volSmoothLen, volSmoothType)

absDeviation = math.abs(src - median)

pctOuter = ta.highest(absDeviation, percentLookback)
pct1 = f_pctAdjust(ta.percentile_nearest_rank(absDeviation, percentLookback, range1), pctOuter)
pct2 = f_pctAdjust(ta.percentile_nearest_rank(absDeviation, percentLookback, range2), pctOuter)
pct3 = f_pctAdjust(ta.percentile_nearest_rank(absDeviation, percentLookback, range3), pctOuter)
pct4 = f_pctAdjust(ta.percentile_nearest_rank(absDeviation, percentLookback, range4), pctOuter)
pct5 = f_pctAdjust(ta.percentile_nearest_rank(absDeviation, percentLookback, range5), pctOuter)
pct6 = f_pctAdjust(ta.percentile_nearest_rank(absDeviation, percentLookback, range6), pctOuter)
pct7 = f_pctAdjust(ta.percentile_nearest_rank(absDeviation, percentLookback, range7), pctOuter)
pct8 = f_pctAdjust(pctOuter, pctOuter)

m1 = f_baseMultiplier(range1, outerBandMultiplier)
m2 = f_baseMultiplier(range2, outerBandMultiplier)
m3 = f_baseMultiplier(range3, outerBandMultiplier)
m4 = f_baseMultiplier(range4, outerBandMultiplier)
m5 = f_baseMultiplier(range5, outerBandMultiplier)
m6 = f_baseMultiplier(range6, outerBandMultiplier)
m7 = f_baseMultiplier(range7, outerBandMultiplier)
m8 = f_baseMultiplier(range8, outerBandMultiplier)

d1 = calcMode == "Percentile" ? pct1 : volatility * m1
d2 = calcMode == "Percentile" ? pct2 : volatility * m2
d3 = calcMode == "Percentile" ? pct3 : volatility * m3
d4 = calcMode == "Percentile" ? pct4 : volatility * m4
d5 = calcMode == "Percentile" ? pct5 : volatility * m5
d6 = calcMode == "Percentile" ? pct6 : volatility * m6
d7 = calcMode == "Percentile" ? pct7 : volatility * m7
d8 = calcMode == "Percentile" ? pct8 : volatility * m8

u1 = median + d1
u2 = median + d2
u3 = median + d3
u4 = median + d4
u5 = median + d5
u6 = median + d6
u7 = median + d7
u8 = median + d8

l1 = median - d1
l2 = median - d2
l3 = median - d3
l4 = median - d4
l5 = median - d5
l6 = median - d6
l7 = median - d7
l8 = median - d8

// -----------------------------------------------------------------------------
// Volatility Regime
// -----------------------------------------------------------------------------
regimeLength = input.int(50, "Volatility Regime Length", minval=5, group=groupCalc)
compressionThreshold = input.float(0.75, "Compression Threshold", minval=0.1, maxval=2.0, step=0.05, group=groupCalc)
expansionThreshold   = input.float(1.25, "Expansion Threshold", minval=0.1, maxval=5.0, step=0.05, group=groupCalc)

bandWidth = u8 - l8
bandWidthAvg = ta.sma(bandWidth, regimeLength)
compressionDetected = not na(bandWidthAvg) and bandWidth < bandWidthAvg * compressionThreshold
expansionDetected = not na(bandWidthAvg) and bandWidth > bandWidthAvg * expansionThreshold

// -----------------------------------------------------------------------------
// Filters
// -----------------------------------------------------------------------------
rsiValue = ta.rsi(src, rsiLength)
trendEma = ta.ema(src, trendLength)
volumeAvg = ta.sma(volume, volumeLength)

body = math.max(math.abs(close - open), syminfo.mintick)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

upperRejectionCandle = upperWick >= body * wickToBodyRatio and close < open
lowerRejectionCandle = lowerWick >= body * wickToBodyRatio and close > open

bullFilters =
     (not useRsiFilter or rsiValue >= rsiBullMin) and
     (not useTrendFilter or close >= trendEma) and
     (not useVolumeFilter or volume >= volumeAvg * volumeFactor)

bearFilters =
     (not useRsiFilter or rsiValue <= rsiBearMax) and
     (not useTrendFilter or close <= trendEma) and
     (not useVolumeFilter or volume >= volumeAvg * volumeFactor)

bullAlertOk = not alertFiltersOn or bullFilters
bearAlertOk = not alertFiltersOn or bearFilters

upperRejectFilterOk = not alertFiltersOn or (bearFilters and (not useCandleRejectionFilter or upperRejectionCandle))
lowerRejectFilterOk = not alertFiltersOn or (bullFilters and (not useCandleRejectionFilter or lowerRejectionCandle))

// -----------------------------------------------------------------------------
// Plots
// -----------------------------------------------------------------------------
plotOffset = projectForward ? samplingLength : 0
plotBands = rangeOn

pMedian = plot(showMedian ? median : na, "Median", color=color.new(medianColor, lineTransparency), linewidth=medianWidth, offset=plotOffset)

pU1 = plot(plotBands and showUpper ? u1 : na, "Range 1 Upper", color=color.new(color1, lineTransparency), linewidth=lineWidth, offset=plotOffset)
pU2 = plot(plotBands and showUpper ? u2 : na, "Range 2 Upper", color=color.new(color2, lineTransparency), linewidth=lineWidth, offset=plotOffset)
pU3 = plot(plotBands and showUpper ? u3 : na, "Range 3 Upper", color=color.new(color3, lineTransparency), linewidth=lineWidth, offset=plotOffset)
pU4 = plot(plotBands and showUpper ? u4 : na, "Range 4 Upper", color=color.new(color4, lineTransparency), linewidth=lineWidth, offset=plotOffset)
pU5 = plot(plotBands and showUpper ? u5 : na, "Range 5 Upper", color=color.new(color5, lineTransparency), linewidth=lineWidth, offset=plotOffset)
pU6 = plot(plotBands and showUpper ? u6 : na, "Range 6 Upper", color=color.new(color6, lineTransparency), linewidth=lineWidth, offset=plotOffset)
pU7 = plot(plotBands and showUpper ? u7 : na, "Range 7 Upper", color=color.new(color7, lineTransparency), linewidth=lineWidth, offset=plotOffset)
pU8 = plot(plotBands and showUpper ? u8 : na, "Range 8 Upper", color=color.new(color8, lineTransparency), linewidth=lineWidth, offset=plotOffset)

pL1 = plot(plotBands and showLower ? l1 : na, "Range 1 Lower", color=color.new(color1, lineTransparency), linewidth=lineWidth, offset=plotOffset)
pL2 = plot(plotBands and showLower ? l2 : na, "Range 2 Lower", color=color.new(color2, lineTransparency), linewidth=lineWidth, offset=plotOffset)
pL3 = plot(plotBands and showLower ? l3 : na, "Range 3 Lower", color=color.new(color3, lineTransparency), linewidth=lineWidth, offset=plotOffset)
pL4 = plot(plotBands and showLower ? l4 : na, "Range 4 Lower", color=color.new(color4, lineTransparency), linewidth=lineWidth, offset=plotOffset)
pL5 = plot(plotBands and showLower ? l5 : na, "Range 5 Lower", color=color.new(color5, lineTransparency), linewidth=lineWidth, offset=plotOffset)
pL6 = plot(plotBands and showLower ? l6 : na, "Range 6 Lower", color=color.new(color6, lineTransparency), linewidth=lineWidth, offset=plotOffset)
pL7 = plot(plotBands and showLower ? l7 : na, "Range 7 Lower", color=color.new(color7, lineTransparency), linewidth=lineWidth, offset=plotOffset)
pL8 = plot(plotBands and showLower ? l8 : na, "Range 8 Lower", color=color.new(color8, lineTransparency), linewidth=lineWidth, offset=plotOffset)

doFill = plotBands and (fillOn or linefillOn)

fill(pMedian, pU1, color=doFill ? color.new(color1, fillTransparency) : na)
fill(pU1, pU2, color=doFill ? color.new(color2, fillTransparency) : na)
fill(pU2, pU3, color=doFill ? color.new(color3, fillTransparency) : na)
fill(pU3, pU4, color=doFill ? color.new(color4, fillTransparency) : na)
fill(pU4, pU5, color=doFill ? color.new(color5, fillTransparency) : na)
fill(pU5, pU6, color=doFill ? color.new(color6, fillTransparency) : na)
fill(pU6, pU7, color=doFill ? color.new(color7, fillTransparency) : na)
fill(pU7, pU8, color=doFill ? color.new(color8, fillTransparency) : na)

fill(pMedian, pL1, color=doFill ? color.new(color1, fillTransparency) : na)
fill(pL1, pL2, color=doFill ? color.new(color2, fillTransparency) : na)
fill(pL2, pL3, color=doFill ? color.new(color3, fillTransparency) : na)
fill(pL3, pL4, color=doFill ? color.new(color4, fillTransparency) : na)
fill(pL4, pL5, color=doFill ? color.new(color5, fillTransparency) : na)
fill(pL5, pL6, color=doFill ? color.new(color6, fillTransparency) : na)
fill(pL6, pL7, color=doFill ? color.new(color7, fillTransparency) : na)
fill(pL7, pL8, color=doFill ? color.new(color8, fillTransparency) : na)

// -----------------------------------------------------------------------------
// Labels
// -----------------------------------------------------------------------------
var label[] hpdrLabels = array.new_label()

if barstate.islast
    if array.size(hpdrLabels) > 0
        for i = 0 to array.size(hpdrLabels) - 1
            label.delete(array.get(hpdrLabels, i))
        array.clear(hpdrLabels)

    if textOn and showLabels and rangeOn
        x = bar_index + labelOffset + (projectForward ? samplingLength : 0)

        array.push(hpdrLabels, label.new(x, u1, f_labelText("R1 Upper", u1, range1), style=label.style_label_left, textcolor=labelTextColor, color=color.new(color1, 70)))
        array.push(hpdrLabels, label.new(x, u2, f_labelText("R2 Upper", u2, range2), style=label.style_label_left, textcolor=labelTextColor, color=color.new(color2, 70)))
        array.push(hpdrLabels, label.new(x, u3, f_labelText("R3 Upper", u3, range3), style=label.style_label_left, textcolor=labelTextColor, color=color.new(color3, 70)))
        array.push(hpdrLabels, label.new(x, u4, f_labelText("R4 Upper", u4, range4), style=label.style_label_left, textcolor=labelTextColor, color=color.new(color4, 70)))
        array.push(hpdrLabels, label.new(x, u5, f_labelText("R5 Upper", u5, range5), style=label.style_label_left, textcolor=labelTextColor, color=color.new(color5, 70)))
        array.push(hpdrLabels, label.new(x, u6, f_labelText("R6 Upper", u6, range6), style=label.style_label_left, textcolor=labelTextColor, color=color.new(color6, 70)))
        array.push(hpdrLabels, label.new(x, u7, f_labelText("R7 Upper", u7, range7), style=label.style_label_left, textcolor=labelTextColor, color=color.new(color7, 70)))
        array.push(hpdrLabels, label.new(x, u8, f_labelText("R8 Upper", u8, range8), style=label.style_label_left, textcolor=labelTextColor, color=color.new(color8, 70)))

        array.push(hpdrLabels, label.new(x, l1, f_labelText("R1 Lower", l1, range1), style=label.style_label_left, textcolor=labelTextColor, color=color.new(color1, 70)))
        array.push(hpdrLabels, label.new(x, l2, f_labelText("R2 Lower", l2, range2), style=label.style_label_left, textcolor=labelTextColor, color=color.new(color2, 70)))
        array.push(hpdrLabels, label.new(x, l3, f_labelText("R3 Lower", l3, range3), style=label.style_label_left, textcolor=labelTextColor, color=color.new(color3, 70)))
        array.push(hpdrLabels, label.new(x, l4, f_labelText("R4 Lower", l4, range4), style=label.style_label_left, textcolor=labelTextColor, color=color.new(color4, 70)))
        array.push(hpdrLabels, label.new(x, l5, f_labelText("R5 Lower", l5, range5), style=label.style_label_left, textcolor=labelTextColor, color=color.new(color5, 70)))
        array.push(hpdrLabels, label.new(x, l6, f_labelText("R6 Lower", l6, range6), style=label.style_label_left, textcolor=labelTextColor, color=color.new(color6, 70)))
        array.push(hpdrLabels, label.new(x, l7, f_labelText("R7 Lower", l7, range7), style=label.style_label_left, textcolor=labelTextColor, color=color.new(color7, 70)))
        array.push(hpdrLabels, label.new(x, l8, f_labelText("R8 Lower", l8, range8), style=label.style_label_left, textcolor=labelTextColor, color=color.new(color8, 70)))

        if showMedian
            array.push(hpdrLabels, label.new(x, median, "Median\n" + str.tostring(median, format.mintick), style=label.style_label_left, textcolor=labelTextColor, color=color.new(medianColor, 70)))

// -----------------------------------------------------------------------------
// Alert Conditions
// -----------------------------------------------------------------------------
crossAboveUpperExtreme = ta.crossover(close, u8) and bullAlertOk
crossBelowLowerExtreme = ta.crossunder(close, l8) and bearAlertOk

rejectUpperExtreme = high > u8 and close < u8 and close > median and upperRejectFilterOk
rejectLowerExtreme = low < l8 and close > l8 and close < median and lowerRejectFilterOk

crossBackAboveMedian = ta.crossover(close, median) and bullAlertOk
crossBackBelowMedian = ta.crossunder(close, median) and bearAlertOk

alertcondition(crossAboveUpperExtreme, "Price Crosses Above Range 8 Upper Band", "HPDR Bands: price crossed above Range 8 upper band.")
alertcondition(crossBelowLowerExtreme, "Price Crosses Below Range 8 Lower Band", "HPDR Bands: price crossed below Range 8 lower band.")
alertcondition(rejectUpperExtreme, "Upper Extreme Rejection", "HPDR Bands: price rejected the upper extreme band and closed back inside.")
alertcondition(rejectLowerExtreme, "Lower Extreme Rejection", "HPDR Bands: price rejected the lower extreme band and closed back inside.")
alertcondition(crossBackAboveMedian, "Price Crosses Back Above Median", "HPDR Bands: price crossed back above the median.")
alertcondition(crossBackBelowMedian, "Price Crosses Back Below Median", "HPDR Bands: price crossed back below the median.")
alertcondition(compressionDetected, "Volatility Compression Detected", "HPDR Bands: volatility compression detected.")
alertcondition(expansionDetected, "Volatility Expansion Detected", "HPDR Bands: volatility expansion detected.")
````
