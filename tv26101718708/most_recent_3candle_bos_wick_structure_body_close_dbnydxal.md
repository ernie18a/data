# Most Recent 3-Candle BOS (Wick Structure, Body Close)

- url: https://www.tradingview.com/script/DBNydXAL-Most-Recent-3-Candle-BOS-Wick-Structure-Body-Close/
- type: indicator
- pine_id: PUB;a8776c4d07274918844f55057d3c1f8e
- version: 1.0

## Description

break of structure

I built a 3-candle break of structure indicator that marks when price body-closes through the most recent confirmed 3-candle wick-based structure high or low. Bullish BOS is a close above the latest 3-candle high structure, bearish BOS is a close below the latest 3-candle low structure.

## Source Code

````pine
//@version=6
indicator("Most Recent 3-Candle BOS (Wick Structure, Body Close)", overlay=true, max_lines_count=500, max_labels_count=500)

//==================================================
// Inputs
//==================================================
showActiveLines        = input.bool(true, "Show Current High/Low Structure Lines")
extendActiveLines      = input.bool(true, "Extend Current Structure Lines")
showHistoricalBosLines = input.bool(true, "Show Historical BOS Lines")
extendBosLines         = input.bool(true, "Extend Historical BOS Lines")
showBosLabels          = input.bool(false, "Show BOS Labels")
showBreakCandleColor   = input.bool(true, "Color BOS Candle")
showPivotMarkers       = input.bool(false, "Show 3-Candle Pivot Markers")

maxBosToKeep           = input.int(5, "Historical BOS Lines To Keep", minval=1, maxval=20)

activeLineWidth        = input.int(2, "Current Structure Line Width", minval=1, maxval=5)
bosLineWidth           = input.int(2, "BOS Line Width", minval=1, maxval=5)

bullColor              = input.color(color.lime, "Bull BOS Candle")
bearColor              = input.color(color.red, "Bear BOS Candle")

highStructureColor     = input.color(color.white, "Current High Structure Line")
lowStructureColor      = input.color(color.white, "Current Low Structure Line")

bullBosColor           = input.color(color.lime, "Bull BOS Line")
bearBosColor           = input.color(color.red, "Bear BOS Line")

highMarkerColor        = input.color(color.fuchsia, "High Pivot Marker")
lowMarkerColor         = input.color(color.aqua, "Low Pivot Marker")
markerSizeInput        = input.string("Tiny", "Marker Size", options=["Tiny", "Small", "Normal"])

//==================================================
// Marker helpers
//==================================================
showHighTiny   = showPivotMarkers and markerSizeInput == "Tiny"
showHighSmall  = showPivotMarkers and markerSizeInput == "Small"
showHighNormal = showPivotMarkers and markerSizeInput == "Normal"

showLowTiny    = showPivotMarkers and markerSizeInput == "Tiny"
showLowSmall   = showPivotMarkers and markerSizeInput == "Small"
showLowNormal  = showPivotMarkers and markerSizeInput == "Normal"

//==================================================
// 3-candle pivot detection
// middle candle [1] is the pivot
// structure includes wick
//==================================================
isSwingHigh = high[1] > high[2] and high[1] > high
isSwingLow  = low[1] < low[2] and low[1] < low

pivotHigh = high[1]
pivotLow  = low[1]

//==================================================
// Most recent confirmed structures
//==================================================
var float currentHighStructure = na
var int   currentHighBar = na
var int   currentHighConfirmBar = na
var bool  currentHighBroken = false

var float currentLowStructure = na
var int   currentLowBar = na
var int   currentLowConfirmBar = na
var bool  currentLowBroken = false

//==================================================
// Historical BOS storage
//==================================================
var array<line> bosLines = array.new_line()
var array<label> bosLabels = array.new_label()

addBosLine(_x1, _y, _x2, _col, _txt, _style) =>
    if showHistoricalBosLines
        newLine = line.new(
             x1 = _x1,
             y1 = _y,
             x2 = _x2,
             y2 = _y,
             extend = extendBosLines ? extend.right : extend.none,
             color = _col,
             width = bosLineWidth,
             style = line.style_dashed
         )
        array.push(bosLines, newLine)

        if array.size(bosLines) > maxBosToKeep
            oldLine = array.shift(bosLines)
            line.delete(oldLine)

        if showBosLabels
            newLabel = label.new(
                 x = _x2,
                 y = _y,
                 text = _txt,
                 style = _style,
                 color = _col,
                 textcolor = color.white,
                 size = size.tiny
             )
            array.push(bosLabels, newLabel)

            if array.size(bosLabels) > maxBosToKeep
                oldLabel = array.shift(bosLabels)
                label.delete(oldLabel)

//==================================================
// 1) Check BOS FIRST using previous structures
// Strict:
// bullish only if body closes above most recent high wick
// bearish only if body closes below most recent low wick
//==================================================
canBreakHigh = not na(currentHighConfirmBar) and bar_index > currentHighConfirmBar
canBreakLow  = not na(currentLowConfirmBar) and bar_index > currentLowConfirmBar

bullBreak = (
    canBreakHigh and
    not currentHighBroken and
    not na(currentHighStructure) and
    close > currentHighStructure and
    close[1] <= currentHighStructure
)

bearBreak = (
    canBreakLow and
    not currentLowBroken and
    not na(currentLowStructure) and
    close < currentLowStructure and
    close[1] >= currentLowStructure
)

//==================================================
// 2) Save BOS lines
//==================================================
if bullBreak
    currentHighBroken := true
    addBosLine(currentHighBar, currentHighStructure, bar_index, bullBosColor, "Bull BOS", label.style_label_up)

if bearBreak
    currentLowBroken := true
    addBosLine(currentLowBar, currentLowStructure, bar_index, bearBosColor, "Bear BOS", label.style_label_down)

//==================================================
// 3) Color BOS candle
//==================================================
barcolor(
     showBreakCandleColor
         ? bullBreak ? bullColor : bearBreak ? bearColor : na
         : na
)

//==================================================
// 4) Show pivot markers
//==================================================
plotshape(showHighTiny and isSwingHigh,   title="High Pivot Tiny",   style=shape.triangledown, location=location.abovebar, color=highMarkerColor, size=size.tiny,   offset=-1)
plotshape(showHighSmall and isSwingHigh,  title="High Pivot Small",  style=shape.triangledown, location=location.abovebar, color=highMarkerColor, size=size.small,  offset=-1)
plotshape(showHighNormal and isSwingHigh, title="High Pivot Normal", style=shape.triangledown, location=location.abovebar, color=highMarkerColor, size=size.normal, offset=-1)

plotshape(showLowTiny and isSwingLow,   title="Low Pivot Tiny",   style=shape.triangleup, location=location.belowbar, color=lowMarkerColor, size=size.tiny,   offset=-1)
plotshape(showLowSmall and isSwingLow,  title="Low Pivot Small",  style=shape.triangleup, location=location.belowbar, color=lowMarkerColor, size=size.small,  offset=-1)
plotshape(showLowNormal and isSwingLow, title="Low Pivot Normal", style=shape.triangleup, location=location.belowbar, color=lowMarkerColor, size=size.normal, offset=-1)

//==================================================
// 5) Update structures AFTER BOS checks
// Every valid 3-candle pivot becomes the newest same-side structure
//==================================================
if isSwingHigh
    currentHighStructure := pivotHigh
    currentHighBar := bar_index[1]
    currentHighConfirmBar := bar_index
    currentHighBroken := false

if isSwingLow
    currentLowStructure := pivotLow
    currentLowBar := bar_index[1]
    currentLowConfirmBar := bar_index
    currentLowBroken := false

//==================================================
// 6) Draw current most recent high/low structure lines
//==================================================
var line currentHighLine = na
var line currentLowLine = na

if showActiveLines
    if isSwingHigh
        if not na(currentHighLine)
            line.delete(currentHighLine)

        currentHighLine := line.new(
             x1 = currentHighBar,
             y1 = currentHighStructure,
             x2 = bar_index,
             y2 = currentHighStructure,
             extend = extendActiveLines ? extend.right : extend.none,
             color = highStructureColor,
             width = activeLineWidth,
             style = line.style_solid
         )

    if isSwingLow
        if not na(currentLowLine)
            line.delete(currentLowLine)

        currentLowLine := line.new(
             x1 = currentLowBar,
             y1 = currentLowStructure,
             x2 = bar_index,
             y2 = currentLowStructure,
             extend = extendActiveLines ? extend.right : extend.none,
             color = lowStructureColor,
             width = activeLineWidth,
             style = line.style_solid
         )

//==================================================
// Alerts
//==================================================
alertcondition(bullBreak, title="Bullish BOS", message="Body closed above the most recent 3-candle high wick structure.")
alertcondition(bearBreak, title="Bearish BOS", message="Body closed below the most recent 3-candle low wick structure.")
````
