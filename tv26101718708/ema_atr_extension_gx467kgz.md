# EMA ATR Extension

- url: https://www.tradingview.com/script/GX467kGZ-EMA-ATR-Extension/
- type: indicator
- pine_id: PUB;6333a6ddfbe842c59ac0141eb7359d1d
- version: 2.0

## Description

Helps in understanding Exhaustion in a trend and a pull back is near by

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © vishal_saket

//@version=6

indicator('Institutional EMA ATR Extension', shorttitle = 'EMA ATR Ext', overlay = false, max_labels_count = 500)
//=============================
// INPUTS
//=============================
emaLen = input.int(10, 'EMA Length')
atrLen = input.int(14, 'ATR Length')
lookback = input.int(252, 'Percentile Lookback')
extremeATR = input.float(2.0, 'Extreme Threshold')
showLabel = input.bool(true, 'Show Current Reading')
//=============================
// CALCULATIONS
//=============================
ema = ta.ema(close, emaLen)
atr = ta.atr(atrLen)
distATR = (close - ema) / atr
emaSlope = ema - ema[1]
trendColor = emaSlope > 0 ? color.lime : emaSlope < 0 ? color.red : color.gray
//=============================
// HISTORICAL PERCENTILE
//=============================
count = 0
for i = 0 to lookback - 1 by 1
    count := count + (math.abs(distATR[i]) < math.abs(distATR) ? 1 : 0)
    count
percentile = 100 * count / lookback
//=============================
// PLOTS
//=============================
plot(distATR, color = trendColor, linewidth = 3)
hline(0)
hline(1.5, color = color.orange)
hline(2, color = color.red)
hline(2.5, color = color.maroon)
hline(-1.5, color = color.orange)
hline(-2, color = color.red)
hline(-2.5, color = color.maroon)
//=============================
// BACKGROUND
//=============================
bgcolor(math.abs(distATR) >= 2.5 ? color.new(color.red, 88) : math.abs(distATR) >= 2 ? color.new(color.orange, 90) : na)
//=============================
// LABEL
//=============================
var label lbl = na
if showLabel and barstate.islast
    label.delete(lbl)
    txt = 'ATR Distance : ' + str.tostring(distATR, '#.##') + '\nPercentile : ' + str.tostring(percentile, '#.0') + '%' + '\nEMA Trend : ' + (emaSlope > 0 ? 'UP' : emaSlope < 0 ? 'DOWN' : 'FLAT')
    lbl := label.new(bar_index, distATR, txt, style = label.style_label_left, color = trendColor, textcolor = color.white)
    lbl
    //=============================
    // RETURN TO EMA SIGNAL
    //=============================
var bool wasExtreme = false
if math.abs(distATR) > extremeATR
    wasExtreme := true
    wasExtreme
returnSignal = wasExtreme and ta.cross(close, ema)
plotshape(returnSignal, title = 'Return to EMA', style = shape.circle, location = location.absolute, color = color.aqua, size = size.small)
if returnSignal
    wasExtreme := false
    wasExtreme
    //=============================
    // ALERTS
    //=============================
alertcondition(math.abs(distATR) > 1.5, title = '1.5 ATR Extension', message = 'Price is more than 1.5 ATR from the EMA')
alertcondition(math.abs(distATR) > 2, title = '2 ATR Extension', message = 'Price is more than 2 ATR from the EMA')
alertcondition(math.abs(distATR) > 2.5, title = '2.5 ATR Extension', message = 'Price is more than 2.5 ATR from the EMA')
alertcondition(returnSignal, title = 'Return to EMA', message = 'Price has returned to the EMA after an extreme extension')
````
