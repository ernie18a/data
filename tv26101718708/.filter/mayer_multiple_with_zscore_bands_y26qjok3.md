# Mayer Multiple with Z-Score Bands

- url: https://www.tradingview.com/script/Y26qJOk3-Mayer-Multiple-with-Z-Score-Bands/
- type: indicator
- pine_id: PUB;bc917997ef66447bb88e74422b268c97
- version: 1.0

## Description

Meyer Multiple but also with added Z-score bands overlay.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MacroSimple

//@version=6
indicator("Mayer Z-Score", shorttitle="Mayer Z-Score", overlay=false)

//────────────────────────────────────────────
// Inputs
//────────────────────────────────────────────
maLength = input.int(200, "Mayer MA Length", minval=1)
src = input.source(close, "Source")

zMode = input.string(
     "Rolling",
     "Z-Score Mode",
     options=["Rolling", "Total Dataset"]
)

rollingLength = input.int(1000, "Rolling Z-Score Length", minval=30)

showZBands = input.bool(true, "Show Z-Score Bands")
showMean = input.bool(true, "Show Mean")
showClassicLevels = input.bool(false, "Show Classic Mayer Levels")

displayMode = input.string(
     "Auto",
     "Display Mode",
     options=["Auto", "Mayer Multiple", "Percent vs MA"]
)

// Z-score band inputs
z1 = input.float(1.0, "Z Band 1")
z2 = input.float(2.0, "Z Band 2")
z3 = input.float(3.0, "Z Band 3")

upperExtreme = input.float(2.4, "Classic Upper Extreme Level")
lowerValue = input.float(0.8, "Classic Lower Value Level")
fairValue = input.float(1.0, "Classic Fair Value Level")

//────────────────────────────────────────────
// Daily Mayer Multiple
//────────────────────────────────────────────
dailyClose = request.security(syminfo.tickerid, "D", src)
dailyMA = request.security(syminfo.tickerid, "D", ta.sma(src, maLength))

mayerMultiple = dailyClose / dailyMA

//────────────────────────────────────────────
// Rolling Z-Score
//────────────────────────────────────────────
rollingMean = ta.sma(mayerMultiple, rollingLength)
rollingStd = ta.stdev(mayerMultiple, rollingLength)

rollingZ = rollingStd != 0 ? (mayerMultiple - rollingMean) / rollingStd : na

//────────────────────────────────────────────
// Total Dataset Z-Score
//────────────────────────────────────────────
var float sum = 0.0
var float sumSq = 0.0
var int count = 0

if not na(mayerMultiple)
    sum += mayerMultiple
    sumSq += mayerMultiple * mayerMultiple
    count += 1

totalMean = count > 1 ? sum / count : na
totalVariance = count > 1 ? (sumSq / count) - (totalMean * totalMean) : na
totalStd = totalVariance > 0 ? math.sqrt(totalVariance) : na

totalZ = totalStd != 0 ? (mayerMultiple - totalMean) / totalStd : na

//────────────────────────────────────────────
// Selected Z Mode
//────────────────────────────────────────────
selectedMean = zMode == "Rolling" ? rollingMean : totalMean
selectedStd = zMode == "Rolling" ? rollingStd : totalStd
selectedZ = zMode == "Rolling" ? rollingZ : totalZ

//────────────────────────────────────────────
// Z Bands Converted Back to Mayer Multiple
//────────────────────────────────────────────
plus1 = selectedMean + selectedStd * z1
plus2 = selectedMean + selectedStd * z2
plus3 = selectedMean + selectedStd * z3

minus1 = selectedMean - selectedStd * z1
minus2 = selectedMean - selectedStd * z2
minus3 = selectedMean - selectedStd * z3

//────────────────────────────────────────────
// Display Logic
// Auto mode:
// - If Z bands are ON, show raw Mayer Multiple.
// - If Z bands are OFF, show percentage above/below MA.
//────────────────────────────────────────────
usePercent =
     displayMode == "Percent vs MA" or
     displayMode == "Auto" and not showZBands

toDisplay(x) =>
    usePercent ? (x - 1.0) * 100.0 : x

mainValue = toDisplay(mayerMultiple)
meanValue = toDisplay(selectedMean)

plus1Display = toDisplay(plus1)
plus2Display = toDisplay(plus2)
plus3Display = toDisplay(plus3)

minus1Display = toDisplay(minus1)
minus2Display = toDisplay(minus2)
minus3Display = toDisplay(minus3)

fairValueDisplay = toDisplay(fairValue)
upperExtremeDisplay = toDisplay(upperExtreme)
lowerValueDisplay = toDisplay(lowerValue)

//────────────────────────────────────────────
// Styling
// Matches your second screenshot better:
// +1 / -1 yellow
// +2 / -2 green
// +3 / -3 blue
// Mayer Multiple white
// Mean white broken line
//────────────────────────────────────────────
mayerColor = color.white
meanColor = color.white

z1Color = color.yellow
z2Color = color.lime
z3Color = color.rgb(41, 98, 255)

//────────────────────────────────────────────
// Main Mayer Plot
//────────────────────────────────────────────
plot(
     mainValue,
     title="Mayer Multiple",
     color=mayerColor,
     linewidth=2
)

// Mean line
plot(
     showMean ? meanValue : na,
     title="Mean",
     color=meanColor,
     linewidth=1,
     style=plot.style_linebr
)

//────────────────────────────────────────────
// Z-Score Bands
//────────────────────────────────────────────
plot(
     showZBands ? plus1Display : na,
     title="+1σ Mayer Band",
     color=z1Color,
     linewidth=1,
     style=plot.style_line
)

plot(
     showZBands ? plus2Display : na,
     title="+2σ Mayer Band",
     color=z2Color,
     linewidth=1,
     style=plot.style_line
)

plot(
     showZBands ? plus3Display : na,
     title="+3σ Mayer Band",
     color=z3Color,
     linewidth=1,
     style=plot.style_line
)

plot(
     showZBands ? minus1Display : na,
     title="-1σ Mayer Band",
     color=z1Color,
     linewidth=1,
     style=plot.style_line
)

plot(
     showZBands ? minus2Display : na,
     title="-2σ Mayer Band",
     color=z2Color,
     linewidth=1,
     style=plot.style_line
)

plot(
     showZBands ? minus3Display : na,
     title="-3σ Mayer Band",
     color=z3Color,
     linewidth=1,
     style=plot.style_line
)

//────────────────────────────────────────────
// Optional Classic Mayer Levels
//────────────────────────────────────────────
plot(
     showClassicLevels ? upperExtremeDisplay : na,
     title="Classic Upper Extreme",
     color=color.red,
     linewidth=1,
     style=plot.style_linebr
)

plot(
     showClassicLevels ? fairValueDisplay : na,
     title="Classic Fair Value",
     color=color.gray,
     linewidth=1,
     style=plot.style_linebr
)

plot(
     showClassicLevels ? lowerValueDisplay : na,
     title="Classic Lower Value",
     color=color.green,
     linewidth=1,
     style=plot.style_linebr
)

//────────────────────────────────────────────
// Background Risk Zones
//────────────────────────────────────────────
bgcolor(selectedZ >= 2 ? color.new(color.red, 88) : na)
bgcolor(selectedZ <= -2 ? color.new(color.green, 88) : na)

//────────────────────────────────────────────
// Labels / Signals
//────────────────────────────────────────────
````
