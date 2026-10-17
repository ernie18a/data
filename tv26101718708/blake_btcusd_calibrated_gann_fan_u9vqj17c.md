# BLAKE - BTC/USD Calibrated Gann Fan 

- url: https://www.tradingview.com/script/u9VQJ17c-BLAKE-BTC-USD-Calibrated-Gann-Fan/
- type: indicator
- pine_id: PUB;cd2510b62a4e4d81bbaf637df73e9073
- version: 1.0

## Description

# BTC/USD Calibrated Gann Fan

A time-anchored macro Gann geometry overlay built specifically for `INDEX:BTCUSD`.

The fan’s primary 1x1 is calibrated from BTC’s Dec. 15, 2018 low ($3,124.51) through the Nov. 21, 2022 low ($15,473.78). All rays use absolute time coordinates, so the structure remains anchored while moving through the chart or changing timeframes.

Features:

- Full labeled Gann fan: 1x8, 1x4, 1x3, 1x2, 1x1, 2x1, 3x1, 4x1, and 8x1  
- Shaded Gann zones for quick confluence reading  
- Dynamic end labels so the active angle is immediately identifiable  
- Optional macro Fibonacci levels: 0.5, 0.618, 1.0, and 1.618  
- Adjustable Fib-cycle high, line visibility, and label visibility  
- Designed to remain usable from monthly macro structure down through lower timeframes  

The 1x1 is the primary equilibrium slope. I treat reactions at a Gann angle more seriously when they coincide with a macro Fib level, prior market structure, and volume-profile confluence. This is a structural mapping tool—not an automatic buy/sell signal or a guarantee of support or resistance.

Use on `INDEX:BTCUSD` for the intended calibration.

## Source Code

````pine
//@version=6
// Fixed to TradingView's full-history Bitcoin / U.S. Dollar index.
// Absolute time-and-price anchoring keeps the fan fixed while you pan or
// switch among intraday, daily, weekly, and monthly charts.
indicator("BTC/USD Calibrated Gann Fan", shorttitle = "BTC Gann", overlay = true, max_lines_count = 13, max_labels_count = 13)

groupGann = "Gann fan calibration"

// The 1/1 ray is the calibration ray: Dec 2018 low -> Nov 2022 low.
// The other eight ratios are derived from that 1/1 slope.
showGann = input.bool(true, "Show calibrated Gann fan", group = groupGann)
showGannZones = input.bool(true, "Shade Gann zones", group = groupGann)
showGannLabels = input.bool(true, "Show ratio labels", group = groupGann)
zoneOpacity = input.int(84, "Gann zone transparency", minval = 0, maxval = 100, group = groupGann)
anchorPrice = input.float(3124.51, "Anchor low price", step = 0.01, group = groupGann)
anchorYear = input.int(2018, "Anchor year", minval = 2010, group = groupGann)
anchorMonth = input.int(12, "Anchor month", minval = 1, maxval = 12, group = groupGann)
anchorDay = input.int(15, "Anchor day", minval = 1, maxval = 31, group = groupGann)
calibrationPrice = input.float(15473.78, "Calibration low price", step = 0.01, group = groupGann)
calibrationYear = input.int(2022, "Calibration year", minval = 2010, group = groupGann)
calibrationMonth = input.int(11, "Calibration month", minval = 1, maxval = 12, group = groupGann)
calibrationDay = input.int(21, "Calibration day", minval = 1, maxval = 31, group = groupGann)

groupFib = "Macro Fibonacci"

// Keep this deliberately sparse. The 0.5 midpoint is not a Fibonacci number,
// but it is a major market-structure retracement, so it belongs in this set.
showFib = input.bool(true, "Show major Fibonacci levels", group = groupFib)
showFibLabels = input.bool(true, "Show Fibonacci labels", group = groupFib)
fibLineTransparency = input.int(38, "Fib line transparency", minval = 0, maxval = 100, group = groupFib)
fibCycleHigh = input.float(126000.00, "Cycle high price", step = 0.01, group = groupFib)

// The 1/1 slope is a fixed price-per-time rate between the two exact wick
// points. This makes the same ray land on the same date and price on every TF.
anchorTime = timestamp("UTC", anchorYear, anchorMonth, anchorDay, 0, 0)
calibrationTime = timestamp("UTC", calibrationYear, calibrationMonth, calibrationDay, 0, 0)
calibrationMs = calibrationTime - anchorTime
unitPerMs = calibrationMs > 0 ? (calibrationPrice - anchorPrice) / calibrationMs : na
isBtcUsd = ticker.standard(syminfo.tickerid) == "INDEX:BTCUSD"

gannValueAt(xTime, multiplier) =>
    isBtcUsd and xTime >= anchorTime ? anchorPrice + (xTime - anchorTime) * unitPerMs * multiplier : na

// The Fib range shares the Gann anchor low and uses the editable cycle high.
// Lines start at the 2022 calibration date to keep the early chart uncluttered.
fibRange = fibCycleHigh - anchorPrice
fib050 = anchorPrice + fibRange * 0.500
fib0618 = anchorPrice + fibRange * 0.618
fib100 = anchorPrice + fibRange
fib1618 = anchorPrice + fibRange * 1.618
fibStartTime = calibrationTime

color c18 = color.rgb(255, 152, 0)
color c14 = color.rgb(0, 150, 136)
color c13 = color.rgb(76, 175, 80)
color c12 = color.rgb(0, 150, 136)
color c11 = color.rgb(0, 188, 212)
color c21 = color.rgb(33, 150, 243)
color c31 = color.rgb(156, 39, 176)
color c41 = color.rgb(233, 30, 99)
color c81 = color.rgb(244, 67, 54)
color fib050Color = color.rgb(189, 189, 189)
color fib0618Color = color.rgb(255, 193, 7)
color fib100Color = color.rgb(255, 255, 255)
color fib1618Color = color.rgb(255, 112, 67)

// `xloc.bar_time` binds every ray to its calendar date, not a relative bar.
var line gann18 = line.new(na, na, na, na, xloc = xloc.bar_time, extend = extend.right, color = c18, width = 2)
var line gann14 = line.new(na, na, na, na, xloc = xloc.bar_time, extend = extend.right, color = c14, width = 2)
var line gann13 = line.new(na, na, na, na, xloc = xloc.bar_time, extend = extend.right, color = c13, width = 2)
var line gann12 = line.new(na, na, na, na, xloc = xloc.bar_time, extend = extend.right, color = c12, width = 2)
var line gann11 = line.new(na, na, na, na, xloc = xloc.bar_time, extend = extend.right, color = c11, width = 3)
var line gann21 = line.new(na, na, na, na, xloc = xloc.bar_time, extend = extend.right, color = c21, width = 2)
var line gann31 = line.new(na, na, na, na, xloc = xloc.bar_time, extend = extend.right, color = c31, width = 2)
var line gann41 = line.new(na, na, na, na, xloc = xloc.bar_time, extend = extend.right, color = c41, width = 2)
var line gann81 = line.new(na, na, na, na, xloc = xloc.bar_time, extend = extend.right, color = c81, width = 2)
var line fib050Line = line.new(na, na, na, na, xloc = xloc.bar_time, extend = extend.right, color = color.new(fib050Color, 38), style = line.style_dashed, width = 1)
var line fib0618Line = line.new(na, na, na, na, xloc = xloc.bar_time, extend = extend.right, color = color.new(fib0618Color, 38), style = line.style_dashed, width = 1)
var line fib100Line = line.new(na, na, na, na, xloc = xloc.bar_time, extend = extend.right, color = color.new(fib100Color, 38), style = line.style_dashed, width = 1)
var line fib1618Line = line.new(na, na, na, na, xloc = xloc.bar_time, extend = extend.right, color = color.new(fib1618Color, 38), style = line.style_dashed, width = 1)

var linefill zone18_14 = linefill.new(gann18, gann14, color.new(c18, 84))
var linefill zone14_13 = linefill.new(gann14, gann13, color.new(c14, 84))
var linefill zone13_12 = linefill.new(gann13, gann12, color.new(c13, 84))
var linefill zone12_11 = linefill.new(gann12, gann11, color.new(c12, 84))
var linefill zone11_21 = linefill.new(gann11, gann21, color.new(c21, 84))
var linefill zone21_31 = linefill.new(gann21, gann31, color.new(c31, 84))
var linefill zone31_41 = linefill.new(gann31, gann41, color.new(c41, 84))
var linefill zone41_81 = linefill.new(gann41, gann81, color.new(c81, 84))

// Text-only labels sit at the live end of each ray and update with price.
var label label18 = label.new(na, na, "1x8", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(c18, 100), textcolor = c18, size = size.large)
var label label14 = label.new(na, na, "1x4", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(c14, 100), textcolor = c14, size = size.large)
var label label13 = label.new(na, na, "1x3", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(c13, 100), textcolor = c13, size = size.large)
var label label12 = label.new(na, na, "1x2", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(c12, 100), textcolor = c12, size = size.large)
var label label11 = label.new(na, na, "1x1", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(c11, 100), textcolor = c11, size = size.large)
var label label21 = label.new(na, na, "2x1", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(c21, 100), textcolor = c21, size = size.large)
var label label31 = label.new(na, na, "3x1", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(c31, 100), textcolor = c31, size = size.large)
var label label41 = label.new(na, na, "4x1", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(c41, 100), textcolor = c41, size = size.large)
var label label81 = label.new(na, na, "8x1", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(c81, 100), textcolor = c81, size = size.large)
var label fib050Label = label.new(na, na, "Fib 0.5", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(fib050Color, 100), textcolor = fib050Color, size = size.normal)
var label fib0618Label = label.new(na, na, "Fib 0.618", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(fib0618Color, 100), textcolor = fib0618Color, size = size.normal)
var label fib100Label = label.new(na, na, "Fib 1.0", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(fib100Color, 100), textcolor = fib100Color, size = size.normal)
var label fib1618Label = label.new(na, na, "Fib 1.618", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(fib1618Color, 100), textcolor = fib1618Color, size = size.normal)

visibleGann = showGann and isBtcUsd and time >= anchorTime and not na(unitPerMs)
visibleFib = showFib and isBtcUsd and fibCycleHigh > anchorPrice
// On a live chart this is the same absolute instant on every timeframe.
// In Bar Replay, preserve the replay bar as the visual endpoint instead.
liveEndTime = barstate.isrealtime ? timenow : time
lineColor(base) =>
    visibleGann ? base : color.new(base, 100)
zoneColor(base) =>
    visibleGann and showGannZones ? color.new(base, zoneOpacity) : color.new(base, 100)
labelTextColor(base) =>
    visibleGann and showGannLabels ? base : color.new(base, 100)
fibLineColor(base) =>
    visibleFib ? color.new(base, fibLineTransparency) : color.new(base, 100)
fibLabelTextColor(base) =>
    visibleFib and showFibLabels ? base : color.new(base, 100)

if barstate.islast
    line.set_xy1(gann18, anchorTime, anchorPrice)
    line.set_xy2(gann18, liveEndTime, gannValueAt(liveEndTime, 8.0))
    line.set_xy1(gann14, anchorTime, anchorPrice)
    line.set_xy2(gann14, liveEndTime, gannValueAt(liveEndTime, 4.0))
    line.set_xy1(gann13, anchorTime, anchorPrice)
    line.set_xy2(gann13, liveEndTime, gannValueAt(liveEndTime, 3.0))
    line.set_xy1(gann12, anchorTime, anchorPrice)
    line.set_xy2(gann12, liveEndTime, gannValueAt(liveEndTime, 2.0))
    line.set_xy1(gann11, anchorTime, anchorPrice)
    line.set_xy2(gann11, liveEndTime, gannValueAt(liveEndTime, 1.0))
    line.set_xy1(gann21, anchorTime, anchorPrice)
    line.set_xy2(gann21, liveEndTime, gannValueAt(liveEndTime, 1.0 / 2.0))
    line.set_xy1(gann31, anchorTime, anchorPrice)
    line.set_xy2(gann31, liveEndTime, gannValueAt(liveEndTime, 1.0 / 3.0))
    line.set_xy1(gann41, anchorTime, anchorPrice)
    line.set_xy2(gann41, liveEndTime, gannValueAt(liveEndTime, 1.0 / 4.0))
    line.set_xy1(gann81, anchorTime, anchorPrice)
    line.set_xy2(gann81, liveEndTime, gannValueAt(liveEndTime, 1.0 / 8.0))
    label.set_xy(label18, liveEndTime, gannValueAt(liveEndTime, 8.0))
    label.set_xy(label14, liveEndTime, gannValueAt(liveEndTime, 4.0))
    label.set_xy(label13, liveEndTime, gannValueAt(liveEndTime, 3.0))
    label.set_xy(label12, liveEndTime, gannValueAt(liveEndTime, 2.0))
    label.set_xy(label11, liveEndTime, gannValueAt(liveEndTime, 1.0))
    label.set_xy(label21, liveEndTime, gannValueAt(liveEndTime, 1.0 / 2.0))
    label.set_xy(label31, liveEndTime, gannValueAt(liveEndTime, 1.0 / 3.0))
    label.set_xy(label41, liveEndTime, gannValueAt(liveEndTime, 1.0 / 4.0))
    label.set_xy(label81, liveEndTime, gannValueAt(liveEndTime, 1.0 / 8.0))
    line.set_xy1(fib050Line, fibStartTime, fib050)
    line.set_xy2(fib050Line, liveEndTime, fib050)
    line.set_xy1(fib0618Line, fibStartTime, fib0618)
    line.set_xy2(fib0618Line, liveEndTime, fib0618)
    line.set_xy1(fib100Line, fibStartTime, fib100)
    line.set_xy2(fib100Line, liveEndTime, fib100)
    line.set_xy1(fib1618Line, fibStartTime, fib1618)
    line.set_xy2(fib1618Line, liveEndTime, fib1618)
    label.set_xy(fib050Label, liveEndTime, fib050)
    label.set_xy(fib0618Label, liveEndTime, fib0618)
    label.set_xy(fib100Label, liveEndTime, fib100)
    label.set_xy(fib1618Label, liveEndTime, fib1618)

line.set_color(gann18, lineColor(c18))
line.set_color(gann14, lineColor(c14))
line.set_color(gann13, lineColor(c13))
line.set_color(gann12, lineColor(c12))
line.set_color(gann11, lineColor(c11))
line.set_color(gann21, lineColor(c21))
line.set_color(gann31, lineColor(c31))
line.set_color(gann41, lineColor(c41))
line.set_color(gann81, lineColor(c81))
line.set_color(fib050Line, fibLineColor(fib050Color))
line.set_color(fib0618Line, fibLineColor(fib0618Color))
line.set_color(fib100Line, fibLineColor(fib100Color))
line.set_color(fib1618Line, fibLineColor(fib1618Color))

label.set_textcolor(label18, labelTextColor(c18))
label.set_textcolor(label14, labelTextColor(c14))
label.set_textcolor(label13, labelTextColor(c13))
label.set_textcolor(label12, labelTextColor(c12))
label.set_textcolor(label11, labelTextColor(c11))
label.set_textcolor(label21, labelTextColor(c21))
label.set_textcolor(label31, labelTextColor(c31))
label.set_textcolor(label41, labelTextColor(c41))
label.set_textcolor(label81, labelTextColor(c81))
label.set_textcolor(fib050Label, fibLabelTextColor(fib050Color))
label.set_textcolor(fib0618Label, fibLabelTextColor(fib0618Color))
label.set_textcolor(fib100Label, fibLabelTextColor(fib100Color))
label.set_textcolor(fib1618Label, fibLabelTextColor(fib1618Color))

linefill.set_color(zone18_14, zoneColor(c18))
linefill.set_color(zone14_13, zoneColor(c14))
linefill.set_color(zone13_12, zoneColor(c13))
linefill.set_color(zone12_11, zoneColor(c12))
linefill.set_color(zone11_21, zoneColor(c21))
linefill.set_color(zone21_31, zoneColor(c31))
linefill.set_color(zone31_41, zoneColor(c41))
linefill.set_color(zone41_81, zoneColor(c81))
````
