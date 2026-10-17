# Trailing Fibonacci + Golden Zone

- url: https://www.tradingview.com/script/f1MIMrLW/
- type: indicator
- pine_id: PUB;3a8b49380c2f474a830780a09bbef1f0
- version: 6.0

## Description

█ OVERVIEW
Trailing Fibonacci + Golden Zone is a dynamic Fibonacci-based indicator designed for automated analysis of market structure, trend direction, and corrective zones using trailing swing highs and lows combined with pivot-based market structure logic.

Unlike classic Fibonacci tools drawn manually between two selected points, this indicator continuously updates the active market range as new price extremes appear.

As a result, Fibonacci levels automatically adapt to current market structure, enabling real-time analysis of corrections, impulses, and dominant directional movement.

The indicator combines three main components:
• trailing Fibonacci structure
• adaptive Golden Zone model
• breakout and retest/exit signal system

Additionally, the indicator can be used as a standalone trend tool, visualizing market direction through range expansion and price reactions within the Golden Zone.

█ CONCEPTS
Trailing Range Logic
The indicator builds its active range using:
• trailing highs and trailing lows (dynamic mode)
• pivot-based structure (alternative measurement mode)

The side that is not currently in trailing mode updates its structure using pivot points. The minimum pivot length for a valid structure is 10, which helps filter market noise and stabilize swing structure.

Increasing pivot length results in:
• a wider, more macro-level structure
• analysis focused on larger impulses
• more trend-oriented behavior

Decreasing pivot length results in:
• more localized structure
• faster reaction to price changes
This allows users to adapt market scale to their trading style.

Dynamic Fibonacci Structure
• new highs extend the bullish range
• new lows extend the bearish range
• Fibonacci levels automatically adapt to structure changes
• the entire framework behaves like a living swing structure

Dynamic Zero Level Orientation
The zero level is always assigned to the most recent range anchor (latest extreme).
Each new high or low can shift the base of the measurement range, dynamically repositioning the entire Fibonacci structure.

Golden Zone Model
The Golden Zone represents the key corrective area between 0.618 and 0.786, acting as a dynamic price reaction zone.
• serves as a market reaction area
• acts as dynamic support/resistance
• changes color depending on market structure
• adapts to the current range

Trend Logic (Golden Zone)
• trend shifts when price breaks the Golden Zone
• breakout defines a change in market dominance
• price staying inside the zone represents consolidation
• return to the zone may indicate structural retest

Signal System
Breakout Signals
• triggered when price breaks the Golden Zone
• indicate structural change in the market
• mark the start of a new impulse phase
Retest / Exit Signals
• appear after price returns and exits the zone
• confirm continuation of the move

█ FEATURES
INPUTS / SETTINGS
Main Settings
• Pivot Length
→ defines swing structure size
→ minimum value: 10
→ lower values = more local structure
→ higher values = broader, trend-based structure
• Show Fib Labels
→ toggles Fibonacci level labels
• Fib Right Offset
→ shifts Fibonacci levels to the right
• Fib Labels Y Offset (%)
→ vertical label positioning adjustment
• Fib Line Width
→ controls Fibonacci line thickness

Golden Zone Settings
• Enable Golden Zone
→ enables/disables the zone
• Upper Ratio (0.618)
• Lower Ratio (0.786)

Signal Settings
• Signal Type (Breakout / Retest / Both)
→ selects signal type
• Signal Size (Tiny / Small / Normal)
→ visual signal size

Color Settings
• Fib Lines Color
• Fib Labels Text Color
• Golden Zone Bullish Color
• Golden Zone Bearish Color

Fibonacci Levels
• enable/disable individual levels
• ratio customization
• full Fibonacci grid configuration

█ APPLICATIONS
1. Market Structure Mapping
The indicator automatically visualizes market structure without manual swing drawing.
It allows users to observe:
• market expansion phases
• corrections and retracements
• key price reaction zones
The Golden Zone range can also be adjusted to individual preferences, allowing multi-layered market analysis across different scales.

2. Confluence-Based Trading (Corrections & Continuations)
Signals should always be evaluated together with additional context:
• momentum strength (does the move have power)
• resistance above LONG signals
• alignment with higher timeframe trend
• volume confirmation (activity at signal zone)
• overlap of Golden Zone with high-volume areas
The strongest setups occur when multiple confluence factors align in the same direction.

3. Trend Mode Usage (Trend Filter)
The indicator can be used as a trend filter by:
• increasing Pivot Length
• filtering signals according to overall market direction
• ignoring lower-timeframe noise and corrections
In this mode, it functions as a directional bias tool for other trading systems.

█ NOTES
The indicator should be used only as a supportive tool for confirmation alongside other indicators or trading methods.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Uncle_the_shooter

//@version=6
indicator("Trailing Fibonacci + Golden Zone", overlay = true, max_lines_count = 500, max_labels_count = 500)

mainGroup = "Main Settings"
pivotLen       = input.int(20, "Pivot Length", minval = 10, group = mainGroup)
showLabels     = input.bool(true, "Show Fib Labels", group = mainGroup)
fiboOffset     = input.int(3, "Fib Right Offset", minval = 0, group = mainGroup)
labelYOffset   = input.float(2.5, "Fib Labels Y Offset (%)", step = 0.1, group = mainGroup)
lineWidth      = input.int(1, "Fib Line Width", minval = 1, group = mainGroup)

signalGroup = "Golden Zone Signals"
signalTypeGZ  = input.string('Breakout', "Signal Type", options = ['Breakout', 'Retest/Exit', 'Both'], group = signalGroup)
signalSizeStr = input.string("Small", "Signal Size", options = ["Tiny", "Small", "Normal"], group = signalGroup)

filterPivotSignals = input.bool(true,  "Filter Pivot-Triggered Signals", group = signalGroup,
     tooltip = "Blocks signals generated directly by crossing the pivot level.\nYou can also set an additional delay below.")
filterPivotDelay   = input.int(0, "Pivot Filter Delay (bars)", minval = 0, maxval = 20, group = signalGroup,
     tooltip = "Number of bars after the pivot during which signals are still blocked.\n0 = block only on the pivot bar.\nIncrease if the zone needs time to 'settle'.")

showBreakSignalsGZ = signalTypeGZ == 'Breakout' or signalTypeGZ == 'Both'
showExitSignalsGZ  = signalTypeGZ == 'Retest/Exit' or signalTypeGZ == 'Both'

rangeFilterGroup = "Minimum Range Filter"
filterMinRange     = input.bool(false, "Filter Signals in Low-Volatility Range", group = rangeFilterGroup,
     tooltip = "Blocks Golden Zone signals when the trailing Fib range (High-Low) is too small relative to ATR,\nhelping to avoid false signals in flat/choppy conditions. Scales automatically across assets and market regimes.")
atrLenRange        = input.int(14, "ATR Length", minval = 1, group = rangeFilterGroup)
atrMultiplierRange = input.float(1.0, "Minimum Range (x ATR)", minval = 0.0, step = 0.1, group = rangeFilterGroup)
showRangeFilterBg  = input.bool(false, "Highlight Bars Where Range Filter Blocks Signals", group = rangeFilterGroup)
rangeFilterBgColor = input.color(color.new(#787b86, 85), "Range Filter Background Color", group = rangeFilterGroup)

gzGroup = "Golden Zone"
showGZ          = input.bool(true, "Enable Golden Zone", group = gzGroup)
upperRatio      = input.float(0.618, "Upper Ratio", step = 0.001, group = gzGroup)
lowerRatio      = input.float(0.786, "Lower Ratio", step = 0.001, group = gzGroup)

colorGroup = "Colors"
lineColor       = input.color(color.new(#a2a2a2, 10), "Fib Lines Color", group = colorGroup)
labelTextColor  = input.color(color.new(#a2a2a2, 10), "Fib Labels Text Color", group = colorGroup)
gzBullColor     = input.color(color.new(#01f726, 75), "Golden Zone - Bullish", group = colorGroup)
gzBearColor     = input.color(color.new(#f70202, 75), "Golden Zone - Bearish", group = colorGroup)
showCandleColor = input.bool(true, "Color Candles by Golden Zone Trend", group = colorGroup)

fibGroup = "Fibonacci Levels"

showFib0 = input.bool(true, "Show", group = fibGroup, inline = "fib0")
val0     = input.float(0.000, "Ratio", step = 0.001, group = fibGroup, inline = "fib0")

showFib1 = input.bool(true, "Show", group = fibGroup, inline = "fib1")
val1     = input.float(0.236, "Ratio", step = 0.001, group = fibGroup, inline = "fib1")

showFib2 = input.bool(true, "Show", group = fibGroup, inline = "fib2")
val2     = input.float(0.382, "Ratio", step = 0.001, group = fibGroup, inline = "fib2")

showFib3 = input.bool(true, "Show", group = fibGroup, inline = "fib3")
val3     = input.float(0.500, "Ratio", step = 0.001, group = fibGroup, inline = "fib3")

showFib4 = input.bool(true, "Show", group = fibGroup, inline = "fib4")
val4     = input.float(0.618, "Ratio", step = 0.001, group = fibGroup, inline = "fib4")

showFib5 = input.bool(true, "Show", group = fibGroup, inline = "fib5")
val5     = input.float(0.786, "Ratio", step = 0.001, group = fibGroup, inline = "fib5")

showFib6 = input.bool(true, "Show", group = fibGroup, inline = "fib6")
val6     = input.float(1.000, "Ratio", step = 0.001, group = fibGroup, inline = "fib6")

var float trailingHigh = na
var float trailingLow  = na
var bool  zeroOnHigh   = true

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low,  pivotLen, pivotLen)

if not na(ph)
    trailingHigh := ph
if not na(pl)
    trailingLow  := pl

trailingHigh := math.max(nz(trailingHigh, high), high)
trailingLow  := math.min(nz(trailingLow, low), low)

if high > nz(trailingHigh[1])
    zeroOnHigh := true
if low < nz(trailingLow[1])
    zeroOnHigh := false

rangeHigh = nz(trailingHigh, high)
rangeLow  = nz(trailingLow, low)
diff      = math.abs(rangeHigh - rangeLow)

float zeroLevel = zeroOnHigh ? rangeHigh : rangeLow

var int barsSincePivot = 999

if not na(ph) or not na(pl)
    barsSincePivot := 0
else
    barsSincePivot := barsSincePivot + 1

bool pivotFilterOK = not filterPivotSignals or (barsSincePivot > filterPivotDelay)

// --- Minimum Range Filter ---
atrValueRange       = ta.atr(atrLenRange)
minDiffRequired     = atrValueRange * atrMultiplierRange
bool rangeFilterOK  = not filterMinRange or diff >= minDiffRequired

bool signalFilterOK = pivotFilterOK and rangeFilterOK

bgcolor(showRangeFilterBg and filterMinRange and not rangeFilterOK ? rangeFilterBgColor : na, title = "Low-Volatility Range Filter Highlight")

var float gzUpper = na
var float gzLower = na
var bool  gzBullMode = true

if diff > 0 and showGZ
    gzUpper  := zeroOnHigh ? zeroLevel - diff * upperRatio : zeroLevel + diff * upperRatio
    gzLower  := zeroOnHigh ? zeroLevel - diff * lowerRatio : zeroLevel + diff * lowerRatio

if not na(gzUpper) and not na(gzLower) and not na(zeroLevel) and diff > 0
    float bullConfirmPrice = zeroOnHigh ? zeroLevel - diff * upperRatio : zeroLevel + diff * lowerRatio
    float bearConfirmPrice = zeroOnHigh ? zeroLevel - diff * lowerRatio : zeroLevel + diff * upperRatio

    if close >= bullConfirmPrice
        gzBullMode := true
    else if close <= bearConfirmPrice
        gzBullMode := false

var bool prev_gzBullMode = false
var bool gz_was_inside   = false

bool gz_buySignal      = false
bool gz_sellSignal     = false
bool gz_exitBuySignal  = false
bool gz_exitSellSignal = false

if showGZ and not na(gzUpper) and not na(gzLower) and diff > 0
    float gzTop = math.max(gzUpper, gzLower)
    float gzBot = math.min(gzUpper, gzLower)

    bool is_inside = close >= gzBot and close <= gzTop

    bool changedToBull = gzBullMode and not prev_gzBullMode
    bool changedToBear = not gzBullMode and prev_gzBullMode

    if changedToBull and signalFilterOK
        gz_buySignal := true
    if changedToBear and signalFilterOK
        gz_sellSignal := true

    if not changedToBull and not changedToBear
        if gzBullMode
            if gz_was_inside and not is_inside and close > gzTop and signalFilterOK
                gz_exitBuySignal := true
        else
            if gz_was_inside and not is_inside and close < gzBot and signalFilterOK
                gz_exitSellSignal := true

    gz_was_inside   := is_inside
    prev_gzBullMode := gzBullMode

gzFillColor = showGZ and not na(gzUpper) and not na(gzLower) ? (gzBullMode ? gzBullColor : gzBearColor) : na

pUpper = plot(showGZ ? gzUpper : na, "Golden Zone Upper", color = na)
pLower = plot(showGZ ? gzLower : na, "Golden Zone Lower", color = na)
fill(pUpper, pLower, color = gzFillColor, title = "Golden Zone Fill")

getActiveRatios() =>
    arr = array.new<float>()
    if showFib0
        array.push(arr, val0)
    if showFib1
        array.push(arr, val1)
    if showFib2
        array.push(arr, val2)
    if showFib3
        array.push(arr, val3)
    if showFib4
        array.push(arr, val4)
    if showFib5
        array.push(arr, val5)
    if showFib6
        array.push(arr, val6)
    arr

var array<line>  fibLines  = array.new<line>()
var array<label> fibLabels = array.new<label>()

activeRatios = getActiveRatios()

if barstate.islast
    if array.size(fibLines) > 0
        for i = 0 to array.size(fibLines) - 1
            line.delete(array.get(fibLines, i))
    if array.size(fibLabels) > 0
        for i = 0 to array.size(fibLabels) - 1
            label.delete(array.get(fibLabels, i))
    array.clear(fibLines)
    array.clear(fibLabels)

    for i = 0 to 15
        array.push(fibLines,  line.new(na, na, na, na, color = lineColor, width = lineWidth, style = line.style_dashed, extend = extend.right))
        array.push(fibLabels, label.new(na, na, "", style = label.style_label_left, size = size.small, color = na, textcolor = labelTextColor))

    if diff > 0 and array.size(activeRatios) > 0
        for i = 0 to math.min(array.size(activeRatios) - 1, 15)
            ratio = array.get(activeRatios, i)
            price = zeroOnHigh ? zeroLevel - diff * ratio : zeroLevel + diff * ratio

            l  = array.get(fibLines, i)
            lb = array.get(fibLabels, i)
            x  = bar_index + fiboOffset

            line.set_color(l, lineColor)
            line.set_width(l, lineWidth)
            line.set_xy1(l, x, price)
            line.set_xy2(l, x + 40, price)

            if showLabels
                yOffset = diff * (labelYOffset / 100)
                label.set_textcolor(lb, labelTextColor)
                label.set_xy(lb, x + 1, price + yOffset)
                label.set_text(lb, str.tostring(ratio * 100, "#.###") + "%")

plotshape(showBreakSignalsGZ and gz_buySignal and signalSizeStr == "Tiny",   title = 'GZ Breakout Up',   location = location.belowbar, style = shape.triangleup,   color = color.new(gzBullColor, 0), size = size.tiny)
plotshape(showBreakSignalsGZ and gz_buySignal and signalSizeStr == "Small",  title = 'GZ Breakout Up',   location = location.belowbar, style = shape.triangleup,   color = color.new(gzBullColor, 0), size = size.small)
plotshape(showBreakSignalsGZ and gz_buySignal and signalSizeStr == "Normal", title = 'GZ Breakout Up',   location = location.belowbar, style = shape.triangleup,   color = color.new(gzBullColor, 0), size = size.normal)

plotshape(showBreakSignalsGZ and gz_sellSignal and signalSizeStr == "Tiny",   title = 'GZ Breakout Down',  location = location.abovebar, style = shape.triangledown, color = color.new(gzBearColor, 0), size = size.tiny)
plotshape(showBreakSignalsGZ and gz_sellSignal and signalSizeStr == "Small",  title = 'GZ Breakout Down',  location = location.abovebar, style = shape.triangledown, color = color.new(gzBearColor, 0), size = size.small)
plotshape(showBreakSignalsGZ and gz_sellSignal and signalSizeStr == "Normal", title = 'GZ Breakout Down',  location = location.abovebar, style = shape.triangledown, color = color.new(gzBearColor, 0), size = size.normal)

plotshape(showExitSignalsGZ  and gz_exitBuySignal and signalSizeStr == "Tiny",   title = 'GZ Retest/Exit Up',    location = location.belowbar, style = shape.circle, color = color.new(gzBullColor, 0), size = size.tiny)
plotshape(showExitSignalsGZ  and gz_exitBuySignal and signalSizeStr == "Small",  title = 'GZ Retest/Exit Up',    location = location.belowbar, style = shape.circle, color = color.new(gzBullColor, 0), size = size.small)
plotshape(showExitSignalsGZ  and gz_exitBuySignal and signalSizeStr == "Normal", title = 'GZ Retest/Exit Up',    location = location.belowbar, style = shape.circle, color = color.new(gzBullColor, 0), size = size.normal)

plotshape(showExitSignalsGZ  and gz_exitSellSignal and signalSizeStr == "Tiny",   title = 'GZ Retest/Exit Down',  location = location.abovebar, style = shape.circle, color = color.new(gzBearColor, 0), size = size.tiny)
plotshape(showExitSignalsGZ  and gz_exitSellSignal and signalSizeStr == "Small",  title = 'GZ Retest/Exit Down',  location = location.abovebar, style = shape.circle, color = color.new(gzBearColor, 0), size = size.small)
plotshape(showExitSignalsGZ  and gz_exitSellSignal and signalSizeStr == "Normal", title = 'GZ Retest/Exit Down',  location = location.abovebar, style = shape.circle, color = color.new(gzBearColor, 0), size = size.normal)

barcolor(showCandleColor and showGZ ? (gzBullMode ? color.new(gzBullColor, 0) : color.new(gzBearColor, 0)) : na, title = "Candles Colored by Golden Zone Trend")

alertcondition(showBreakSignalsGZ and gz_buySignal,      title = "GZ Breakout Up",   message = "Golden Zone - Breakout Up")
alertcondition(showBreakSignalsGZ and gz_sellSignal,     title = "GZ Breakout Down",  message = "Golden Zone - Breakout Down")
alertcondition(showExitSignalsGZ  and gz_exitBuySignal,  title = "GZ Retest/Exit Up",    message = "Golden Zone - Retest/Exit Up")
alertcondition(showExitSignalsGZ  and gz_exitSellSignal, title = "GZ Retest/Exit Down",  message = "Golden Zone - Retest/Exit Down")
````
