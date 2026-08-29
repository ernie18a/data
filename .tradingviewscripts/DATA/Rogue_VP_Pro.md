<!-- tradingview-pine-id: PUB;fa5dec1bd4d74758abfa4aaed5ec56fc -->
<!-- tradingviewscripts-format: 1 -->
# Rogue VP Pro

Source: https://www.tradingview.com/script/SmriYXFD-Rogue-VP-Pro/

## Description

Rogue VP Pro is an advanced Previous Day Volume Profile indicator built for traders who rely on volume-based market structure to identify high-probability trading opportunities.
The indicator generates a detailed volume profile from the previous trading session and projects the most important price levels onto the current session, providing a clear framework for identifying support, resistance, acceptance, rejection, and potential liquidity areas.
Designed for intraday traders, Rogue VP Pro offers extensive customization while remaining lightweight and easy to read.
Features:
Previous Day Volume Profile
High-resolution volume profile with configurable calculation and rendering density.
Displays the previous session's volume distribution directly on the current trading day.

Supports:
Regular Trading Hours (RTH)
Previous Overnight Session
All Sessions

Automatically calculates and plots:
• Point of Control (POC)
• Value Area High (VAH)
• Value Area Low (VAL)
Optional labels display the exact price of each level.
Value Area Deviations
Project customizable deviation levels above and below the Value Area, allowing traders to identify potential extension targets and exhaustion zones.
Default deviation levels include:
• ±0.25 VA
• ±1.0 VA
• ±2.0 VA
Volume Nodes
Automatically identifies:
• High Volume Nodes (HVNs) – areas of heavy participation
• Low Volume Nodes (LVNs) – potential rejection or low-liquidity zones
Detection sensitivity and filtering thresholds are fully customizable.
Volume Surge Highlights
Identify unusually high-volume bars during Regular Trading Hours.
Bars exceeding a user-defined multiple of average volume are highlighted, making it easy to spot institutional participation and momentum events.
EMA Overlay
Includes an optional Exponential Moving Average for additional trend confirmation and trade confluence.
Customizable Appearance
Customize nearly every aspect of the indicator, including:
• Profile colors
• Value Area colors
• Node colors
• Deviation colors
• Line widths
• Label visibility
• Profile placement (left or right)
• Profile width and rendering resolution
Alerts
Create TradingView alerts whenever price touches one of the key Previous Day Volume Profile levels:
• POC
• VAH
• VAL
Alerts are limited to Regular Trading Hours for more relevant intraday notifications.
Ideal For
• Futures traders
• Index traders
• Options traders
• Scalpers
• Day traders
• Volume Profile enthusiasts
• Price Action traders
How It Can Be Used
Many traders use previous session volume information to:
• Identify high-probability support and resistance
• Monitor acceptance versus rejection around key value areas
• Locate potential breakout and reversal zones
• Trade rotations back toward the Point of Control
• Find confluence with other technical tools and market structure
Rogue VP Pro provides these important reference levels in a clean, highly configurable format, allowing traders to integrate volume profile analysis into virtually any trading strategy.
Disclaimer: This indicator is intended as a market analysis tool and should be used alongside sound risk management and your own trading plan.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RogueLLC33

//@version=6
indicator("Rogue VP Pro", overlay=true, max_boxes_count=5000, max_lines_count=500, max_labels_count=500)

max_bars_back(time, 5000)
//--------------------------------------------------------------------------------------------------
// Inputs
//--------------------------------------------------------------------------------------------------
groupProfile = "Previous Day Volume Profile"
sessionMode = input.string("RTH Only", "Session Mode", options=["All Sessions", "RTH Only", "Overnight"], group=groupProfile)
rthSession  = input.session("0830-1500", "RTH Session", group=groupProfile)
ovnSession  = input.session("1700-0829", "Overnight Session", group=groupProfile)
calcRows            = input.int(1000, "Profile Rows (Calc)", minval=20, maxval=1000, group=groupProfile)
maxRenderRows       = input.int(450, "Max Rendered Rows", minval=20, maxval=1000, group=groupProfile)
valueAreaPercent    = input.float(70, "Value Area %", minval=1, maxval=100, group=groupProfile) / 100.0
profileWidthBars    = input.int(300, "Profile Width (bars)", minval=1, maxval=1000, group=groupProfile)
horizontalOffset    = input.int(0, "Horizontal Offset", minval=0, maxval=100, group=groupProfile)
profilePlacement    = input.string("Left", "Profile Placement", options=["Left", "Right"], group=groupProfile)
POClineWidth        = input.int(2, "POC Line Width", minval=1, maxval=4, group = groupProfile)
VAlineWidth         = input.int(1, "Volume Area Line Width", minval=1, maxval=4, group = groupProfile)
showProfile         = input.bool(true, "Show Profile", group=groupProfile)
showPOC             = input.bool(true, "Show POC", group=groupProfile)
showVAH             = input.bool(true, "Show VAH", group=groupProfile)
showVAL             = input.bool(true, "Show VAL", group=groupProfile)
showLabels          = input.bool(true, "Show Labels", group=groupProfile)

groupColors = "Colors"
valueAreaColor    = input.color(color.new(color.blue, 35), "Value area", group=groupColors)
outsideProfileColor      = input.color(color.new(color.gray, 35), "Outside Value Area", group=groupColors)
pocColor            = input.color(#fbc02d, "POC", group=groupColors)
vahColor            = input.color(#2962ff, "VAH", group=groupColors)
valColor            = input.color(#2962ff, "VAL", group=groupColors)

groupNodes = "Volume Nodes"
showPeaks          = input.bool(true, "Show Peak Nodes", group=groupNodes)
showTroughs        = input.bool(true, "Show Trough Nodes", group=groupNodes)
nodePercentPeaks   = input.int(7, "Peak Detection Percent", minval=1, maxval=50, group=groupNodes, tooltip = "Controls how many rows are checked to confirm a peak node. Higher = fewer but stronger peaks.") / 100.0
nodePercentTroughs = input.int(5, "Trough Detection Percent", minval=1, maxval=50, group=groupNodes, tooltip = "Controls how many rows are checked to confirm a trough node. Higher = fewer but stronger troughs.") / 100.0
nodeThreshold      = input.int(2, "Node Threshold %", minval=0, maxval=100, group=groupNodes, tooltip = "Minimum volume required for a node relative to the profile's max volume. Higher = filters out weaker nodes.") / 100.0
peakColor          = input.color(color.new(color.green, 0), "Peak Color", group=groupNodes)
troughColor        = input.color(color.new(color.aqua, 0), "Trough Color", group=groupNodes)

groupDev = "VA Deviations"
showDeviations   = input.bool(true, "Show VA Deviations", group=groupDev)
devMultiplier1   = input.float(0.25, "Deviation 1", minval=0.1, step=0.1, group=groupDev)
devMultiplier2   = input.float(1.0, "Deviation 2", minval=0.1, step=0.1, group=groupDev)
devMultiplier3   = input.float(2.0, "Deviation 3", minval=0.1, step=0.1, group=groupDev)
devColorAbove    = input.color(color.new(color.green, 0), "Upper Dev Color", group=groupDev)
devColorBelow    = input.color(color.new(color.green, 0), "Lower Dev Color", group=groupDev)
devLineWidth     = input.int(1, "Deviation Line Width", minval=1, maxval=4, group=groupDev)
showDevLabels    = input.bool(true, "Show Deviation Labels", group=groupDev)
showDevPrices    = input.bool(true, "Show Deviation Prices In Labels", group=groupDev)

groupEMA = "EMA"
showEMA   = input.bool(true, "Show EMA", group=groupEMA)
emaLength = input.int(5, "EMA Length", minval=1, group=groupEMA)
emaSource = input.source(close, "EMA Source", group=groupEMA)
emaColor  = input.color(color.white, "EMA Color", group=groupEMA)
emaWidth  = input.int(1, "EMA Width", minval=1, maxval=5, group=groupEMA)

groupVolSurge = "Volume Surge Highlights"
showVolSurgeHighlights = input.bool(true, "Show Volume Surge Highlights", group=groupVolSurge)
volSurgeLength = input.int(30, "Average Volume Length", minval=1, group=groupVolSurge)
volSurgeMult = input.float(2.0, "Surge Multiplier Threshold", step=0.1, group=groupVolSurge)
volSurgeUpColor = input.color(color.new(color.green, 85), "Up Surge Highlight", group=groupVolSurge)
volSurgeDownColor = input.color(color.new(color.red, 85), "Down Surge Highlight", group=groupVolSurge)

groupVWAP = "VWAP Standard Deviation Bands"

showVWAP = input.bool(true, "Show VWAP", group=groupVWAP)
vwapAnchorMode = input.string(
     "RTH",
     "VWAP Anchor",
     options=["RTH", "Overnight", "Daily"],
     group=groupVWAP
)

vwapSource = input.source(hlc3, "VWAP Source", group=groupVWAP)

showVWAPBand1 = input.bool(true, "Show ±1 Standard Deviation", group=groupVWAP)
showVWAPBand2 = input.bool(false, "Show ±2 Standard Deviations", group=groupVWAP)
showVWAPBand3 = input.bool(false, "Show ±3 Standard Deviations", group=groupVWAP)

vwapBand1Mult = input.float(1.0, "Band 1 Multiplier", minval=0.0, step=0.25, group=groupVWAP)
vwapBand2Mult = input.float(2.0, "Band 2 Multiplier", minval=0.0, step=0.25, group=groupVWAP)
vwapBand3Mult = input.float(3.0, "Band 3 Multiplier", minval=0.0, step=0.25, group=groupVWAP)

vwapColor = input.color(color.white, "VWAP Color", group=groupVWAP)
vwapBand1Color = input.color(color.blue, "Band 1 Color", group=groupVWAP)
vwapBand2Color = input.color(color.purple, "Band 2 Color", group=groupVWAP)
vwapBand3Color = input.color(color.gray, "Band 3 Color", group=groupVWAP)

vwapLineWidth = input.int(2, "VWAP Line Width", minval=1, maxval=5, group=groupVWAP)
vwapBandWidth = input.int(1, "Band Line Width", minval=1, maxval=5, group=groupVWAP)

//--------------------------------------------------------------------------------------------------
// Type
//--------------------------------------------------------------------------------------------------
type BarRec
    float h
    float l
    float v
    int   idx

//--------------------------------------------------------------------------------------------------
// Persistent storage
//--------------------------------------------------------------------------------------------------
var array<BarRec> currentDayBars = array.new<BarRec>()
var array<BarRec> prevDayBars    = array.new<BarRec>()
var array<box> profileBoxes      = array.new<box>()

var line pocLine = na
var line vahLine = na
var line valLine = na

var label pocLabel = na
var label vahLabel = na
var label valLabel = na

var int currentDayStartIndex = na

var float pdPocPrice = na
var float pdVahPrice = na
var float pdValPrice = na

var line dev1AboveLine = na
var line dev2AboveLine = na
var line dev1BelowLine = na
var line dev2BelowLine = na
var line dev3AboveLine = na 
var line dev3BelowLine = na 

var label dev1AboveLabel = na
var label dev2AboveLabel = na
var label dev1BelowLabel = na
var label dev2BelowLabel = na
var label dev3AboveLabel = na 
var label dev3BelowLabel = na 

//--------------------------------------------------------------------------------------------------
// Helpers
//--------------------------------------------------------------------------------------------------
inRTH = not na(time(timeframe.period, rthSession))
inOVN = not na(time(timeframe.period, ovnSession))
isOvernight = sessionMode == "Overnight"
inSelectedSession = sessionMode == "All Sessions" ? true : sessionMode == "RTH Only" ? inRTH : inOVN
isLeft = profilePlacement == "Left"

newRTH = inRTH and not inRTH[1]
newOVN = inOVN and not inOVN[1]
newALL = timeframe.change("D")

isNewProfilePeriod = sessionMode == "All Sessions" ? newALL : sessionMode == "RTH Only" ? newRTH : newOVN
f_delete_drawings() =>
    boxesSize = array.size(profileBoxes)
    if boxesSize > 0
        for i = 0 to boxesSize - 1
            box.delete(array.get(profileBoxes, i))
    array.clear(profileBoxes)

    if not na(pocLine)
        line.delete(pocLine)
    if not na(vahLine)
        line.delete(vahLine)
    if not na(valLine)
        line.delete(valLine)

    if not na(pocLabel)
        label.delete(pocLabel)
    if not na(vahLabel)
        label.delete(vahLabel)
    if not na(valLabel)
        label.delete(valLabel)

    if not na(dev1AboveLine)
        line.delete(dev1AboveLine)
    if not na(dev2AboveLine)
        line.delete(dev2AboveLine)
    if not na(dev1BelowLine)
        line.delete(dev1BelowLine)
    if not na(dev2BelowLine)
        line.delete(dev2BelowLine)
    if not na(dev3AboveLine)
        line.delete(dev3AboveLine)
    if not na(dev3BelowLine)
        line.delete(dev3BelowLine)

    if not na(dev1AboveLabel)
        label.delete(dev1AboveLabel)
    if not na(dev2AboveLabel)
        label.delete(dev2AboveLabel)
    if not na(dev1BelowLabel)
        label.delete(dev1BelowLabel)
    if not na(dev2BelowLabel)
        label.delete(dev2BelowLabel)
    if not na(dev3AboveLabel)
        label.delete(dev3AboveLabel)
    if not na(dev3BelowLabel)
        label.delete(dev3BelowLabel)

//--------------------------------------------------------------------------------------------------
// Detect day change
//--------------------------------------------------------------------------------------------------
if barstate.isfirst
    currentDayStartIndex := na

if barstate.isconfirmed
    if isNewProfilePeriod
        array.clear(prevDayBars)
        currentSize = array.size(currentDayBars)
        if currentSize > 0
            for i = 0 to currentSize - 1
                array.push(prevDayBars, array.get(currentDayBars, i))

        array.clear(currentDayBars)
        currentDayStartIndex := na
    
    if inSelectedSession
        if na(currentDayStartIndex)
            currentDayStartIndex := bar_index
        array.push(currentDayBars, BarRec.new(high, low, volume, bar_index))

//--------------------------------------------------------------------------------------------------
// Main
//--------------------------------------------------------------------------------------------------
if barstate.islast
    f_delete_drawings()

    pocLine := na
    vahLine := na
    valLine := na
    pocLabel := na
    vahLabel := na
    valLabel := na
    pdPocPrice := na
    pdVahPrice := na
    pdValPrice := na

    dev1AboveLine := na
    dev2AboveLine := na
    dev1BelowLine := na
    dev2BelowLine := na
    dev3AboveLine := na 
    dev3BelowLine := na 

    dev1AboveLabel := na
    dev2AboveLabel := na
    dev1BelowLabel := na
    dev2BelowLabel := na
    dev3AboveLabel := na 
    dev3BelowLabel := na 

    array<BarRec> profileSourceBars = isOvernight ? currentDayBars : prevDayBars
    profileCount = array.size(profileSourceBars)

    if timeframe.isintraday and profileCount > 0 and not na(currentDayStartIndex)
        float dayHigh = na
        float dayLow = na

        for i = 0 to profileCount - 1
            b = array.get(profileSourceBars, i)
            dayHigh := na(dayHigh) ? b.h : math.max(dayHigh, b.h)
            dayLow := na(dayLow) ? b.l : math.min(dayLow, b.l)

        validRange = not na(dayHigh) and not na(dayLow) and dayHigh > dayLow
        calcStep = validRange ? (dayHigh - dayLow) / calcRows : na

        if validRange and not na(calcStep) and calcStep > 0
            totalVolCalc   = array.new_float(calcRows, 0.0)

            // Build previous-day profile
            for i = 0 to profileCount - 1
                b = array.get(profileSourceBars, i)

                barRange = math.max(b.h - b.l, syminfo.mintick)
                startSlot = math.max(int(math.floor((b.l - dayLow) / calcStep)), 0)
                endSlot   = math.min(int(math.floor((b.h - dayLow) / calcStep)), calcRows - 1)

                if startSlot <= endSlot
                    for row = startSlot to endSlot
                        priceLevel = dayLow + row * calcStep

                        volProp = switch
                            b.l >= priceLevel and b.h > priceLevel + calcStep => (priceLevel + calcStep - b.l) / barRange
                            b.h <= priceLevel + calcStep and b.l < priceLevel => (b.h - priceLevel) / barRange
                            b.l >= priceLevel and b.h <= priceLevel + calcStep => 1.0
                            => calcStep / barRange

                        array.set(totalVolCalc, row, array.get(totalVolCalc, row) + b.v * volProp)

                        
            maxVolCalc = array.max(totalVolCalc)
            pocRowCalc = array.indexof(totalVolCalc, maxVolCalc)

            if maxVolCalc > 0 and pocRowCalc >= 0
                // Value area
                targetVA = array.sum(totalVolCalc) * valueAreaPercent
                vaVol = array.get(totalVolCalc, pocRowCalc)
                vahRowCalc = pocRowCalc
                valRowCalc = pocRowCalc

                while vaVol < targetVA
                    if valRowCalc == 0 and vahRowCalc == calcRows - 1
                        break

                    volAbove = vahRowCalc < calcRows - 1 ? array.get(totalVolCalc, vahRowCalc + 1) : 0.0
                    volBelow = valRowCalc > 0 ? array.get(totalVolCalc, valRowCalc - 1) : 0.0

                    if volAbove == 0 and volBelow == 0
                        break

                    if volAbove >= volBelow
                        vaVol += volAbove
                        vahRowCalc += 1
                    else
                        vaVol += volBelow
                        valRowCalc -= 1

                pocPrice = dayLow + (pocRowCalc + 0.5) * calcStep
                vahPrice = dayLow + (vahRowCalc + 1.0) * calcStep
                valPrice = dayLow + valRowCalc * calcStep
                pdPocPrice := pocPrice
                pdVahPrice := vahPrice
                pdValPrice := valPrice
                vaRange = vahPrice - valPrice

                dev1Above = vahPrice + vaRange * devMultiplier1
                dev2Above = vahPrice + vaRange * devMultiplier2
                dev1Below = valPrice - vaRange * devMultiplier1
                dev2Below = valPrice - vaRange * devMultiplier2
                dev3Above = vahPrice + vaRange * devMultiplier3
                dev3Below = valPrice - vaRange * devMultiplier3

                // Compress rows for rendering
                compression = int(math.ceil(calcRows / maxRenderRows))
                drawRows = int(math.ceil(calcRows / compression))
                drawStep = calcStep * compression

                totalVolDraw = array.new_float(drawRows, 0.0)
                rowLeftArr     = array.new_int(drawRows, 0)
                rowRightArr    = array.new_int(drawRows, 0)

                for src = 0 to calcRows - 1
                    dst = int(math.floor(src / compression))
                    if dst >= 0 and dst < drawRows
                        array.set(totalVolDraw, dst, array.get(totalVolDraw, dst) + array.get(totalVolCalc, src))

                maxVolDraw = array.max(totalVolDraw)

                // Anchor to current day
                barsIntoCurrentDay = math.max(bar_index - currentDayStartIndex + 1, 1)
                effectiveWidth = math.min(profileWidthBars, barsIntoCurrentDay)

                profileLeft  = isLeft ? currentDayStartIndex + horizontalOffset : currentDayStartIndex + math.max(barsIntoCurrentDay - effectiveWidth - horizontalOffset, 0)
                profileRight = isLeft ? profileLeft + effectiveWidth : profileLeft + effectiveWidth
                levelLineRight = isOvernight ? bar_index + 10 : profileRight

                // Draw combined total-volume profile
                if showProfile and maxVolDraw > 0
                    for row = 0 to drawRows - 1
                        rowVolume = array.get(totalVolDraw, row)

                        rowWidth = int(math.round((rowVolume / maxVolDraw) * effectiveWidth))

                        y1 = dayLow + row * drawStep + 0.10 * drawStep
                        y2 = dayLow + row * drawStep + 0.90 * drawStep

                        rowCenterPrice = dayLow + (row + 0.5) * drawStep
                        inVA = rowCenterPrice >= valPrice and rowCenterPrice <= vahPrice

                        rowColor = inVA ? valueAreaColor : outsideProfileColor

                        if isLeft
                            xLeft  = profileLeft
                            xRight = xLeft + rowWidth

                            profileBox = box.new(
                                 xLeft,
                                 y1,
                                 xRight,
                                 y2,
                                 border_color=color.new(color.white, 100),
                                 bgcolor=rowColor
                             )

                            array.push(profileBoxes, profileBox)
                            array.set(rowLeftArr, row, xLeft)
                            array.set(rowRightArr, row, xRight)

                        else
                            xRight = profileRight
                            xLeft  = xRight - rowWidth

                            profileBox = box.new(
                                 xLeft,
                                 y1,
                                 xRight,
                                 y2,
                                 border_color=color.new(color.white, 100),
                                 bgcolor=rowColor
                             )

                            array.push(profileBoxes, profileBox)
                            array.set(rowLeftArr, row, xLeft)
                            array.set(rowRightArr, row, xRight)

                // Node detection
                if maxVolDraw > 0
                    if showPeaks
                        peakN = math.max(1, int(drawRows * nodePercentPeaks))
                        tempPeak = array.copy(totalVolDraw)

                        for _ = 1 to peakN
                            array.unshift(tempPeak, 0.0)
                            array.push(tempPeak, 0.0)

                        tempPeakSize = array.size(tempPeak)

                        for row = 0 to drawRows - 1
                            center = row + peakN
                            bool upperOk = true
                            bool lowerOk = true

                            if center - peakN >= 0 and center + peakN < tempPeakSize
                                for j = center - peakN to center - 1
                                    if array.get(tempPeak, center) <= array.get(tempPeak, j)
                                        upperOk := false
                                        break

                                for j = center + 1 to center + peakN
                                    if array.get(tempPeak, center) <= array.get(tempPeak, j)
                                        lowerOk := false
                                        break

                                isPeak = upperOk and lowerOk and (array.get(totalVolDraw, row) / maxVolDraw > nodeThreshold)
                                if isPeak
                                    xLeftNode = array.get(rowLeftArr, row)
                                    xRightNode = array.get(rowRightArr, row)
                                    y1 = dayLow + row * drawStep + 0.15 * drawStep
                                    y2 = dayLow + row * drawStep + 0.85 * drawStep
                                    peakBox = box.new(xLeftNode, y1, xRightNode, y2, border_color=color.new(color.white, 100), bgcolor=peakColor)
                                    array.push(profileBoxes, peakBox)

                    if showTroughs
                        troughN = math.max(1, int(drawRows * nodePercentTroughs))
                        tempTrough = array.copy(totalVolDraw)

                        for _ = 1 to troughN
                            array.unshift(tempTrough, maxVolDraw)
                            array.push(tempTrough, maxVolDraw)

                        tempTroughSize = array.size(tempTrough)

                        for row = 0 to drawRows - 1
                            center = row + troughN
                            bool upperOk = true
                            bool lowerOk = true

                            if center - troughN >= 0 and center + troughN < tempTroughSize
                                for j = center - troughN to center - 1
                                    if array.get(tempTrough, center) >= array.get(tempTrough, j)
                                        upperOk := false
                                        break

                                for j = center + 1 to center + troughN
                                    if array.get(tempTrough, center) >= array.get(tempTrough, j)
                                        lowerOk := false
                                        break

                                isTrough = upperOk and lowerOk and (array.get(totalVolDraw, row) / maxVolDraw > nodeThreshold)
                                if isTrough
                                    xLeftNode = array.get(rowLeftArr, row)
                                    xRightNode = array.get(rowRightArr, row)
                                    y1 = dayLow + row * drawStep + 0.15 * drawStep
                                    y2 = dayLow + row * drawStep + 0.85 * drawStep
                                    troughBox = box.new(xLeftNode, y1, xRightNode, y2, border_color=color.new(color.aqua, 0), bgcolor=troughColor)
                                    array.push(profileBoxes, troughBox)
    
                // Lines
                if showPOC
                    pocLine := line.new(profileLeft, pocPrice, levelLineRight, pocPrice, xloc=xloc.bar_index, extend=extend.none, color=pocColor, width=POClineWidth)

                if showVAH
                    vahLine := line.new(profileLeft, vahPrice, levelLineRight, vahPrice, xloc=xloc.bar_index, extend=extend.none, color=vahColor, width=VAlineWidth)

                if showVAL
                    valLine := line.new(profileLeft, valPrice, levelLineRight, valPrice, xloc=xloc.bar_index, extend=extend.none, color=valColor, width=VAlineWidth)

                // Labels
                profileLabelPrefix = isOvernight ? "ON" : "PD"

                if showLabels
                    labelX = isOvernight ? levelLineRight : isLeft ? profileRight : profileLeft
                    labelStyle = isLeft ? label.style_label_left : label.style_label_right

                    if showPOC
                        pocLabel := label.new(labelX, pocPrice, profileLabelPrefix + " POC " + str.tostring(pocPrice, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, style=labelStyle, color=color.new(pocColor, 85), textcolor=pocColor, size=size.small)

                    if showVAH
                        vahLabel := label.new(labelX, vahPrice, profileLabelPrefix + " VAH " + str.tostring(vahPrice, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, style=labelStyle, color=color.new(vahColor, 85), textcolor=vahColor, size=size.small)

                    if showVAL
                        valLabel := label.new(labelX, valPrice, profileLabelPrefix + " VAL " + str.tostring(valPrice, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, style=labelStyle, color=color.new(valColor, 85), textcolor=valColor, size=size.small)
                // Deviations
                    if showDeviations and showDevLabels and vaRange > 0
                        dev1AboveLine := line.new(profileLeft, dev1Above, levelLineRight, dev1Above, xloc=xloc.bar_index, extend=extend.none, color=devColorAbove, width=devLineWidth)
                        dev2AboveLine := line.new(profileLeft, dev2Above, levelLineRight, dev2Above, xloc=xloc.bar_index, extend=extend.none, color=devColorAbove, width=devLineWidth)
                        dev3AboveLine := line.new(profileLeft, dev3Above, levelLineRight, dev3Above, xloc=xloc.bar_index, extend=extend.none, color=devColorAbove, width=devLineWidth)
                        dev1BelowLine := line.new(profileLeft, dev1Below, levelLineRight, dev1Below, xloc=xloc.bar_index, extend=extend.none, color=devColorBelow, width=devLineWidth)
                        dev2BelowLine := line.new(profileLeft, dev2Below, levelLineRight, dev2Below, xloc=xloc.bar_index, extend=extend.none, color=devColorBelow, width=devLineWidth)
                        dev3BelowLine := line.new(profileLeft, dev3Below, levelLineRight, dev3Below, xloc=xloc.bar_index, extend=extend.none, color=devColorBelow, width=devLineWidth)

                    if showDevLabels and showDeviations and vaRange > 0
                        string dev1AboveText = showDevPrices ? "VA + " + str.tostring(devMultiplier1, "#.00") + " " + str.tostring(dev1Above, format.mintick) : "VA +" + str.tostring(devMultiplier1, "#.00")
                        string dev2AboveText = showDevPrices ? "VA + " + str.tostring(devMultiplier2, "#.00") + " " + str.tostring(dev2Above, format.mintick) : "VA +" + str.tostring(devMultiplier2, "#.00")
                        string dev3AboveText = showDevPrices ? "VA + " + str.tostring(devMultiplier3, "#.00") + " " + str.tostring(dev3Above, format.mintick) : "VA +" + str.tostring(devMultiplier3, "#.00")

                        string dev1BelowText = showDevPrices ? "VA - " + str.tostring(devMultiplier1, "#.00") + " " + str.tostring(dev1Below, format.mintick) : "VA -" + str.tostring(devMultiplier1, "#.00")
                        string dev2BelowText = showDevPrices ? "VA - " + str.tostring(devMultiplier2, "#.00") + " " + str.tostring(dev2Below, format.mintick) : "VA -" + str.tostring(devMultiplier2, "#.00")
                        string dev3BelowText = showDevPrices ? "VA - " + str.tostring(devMultiplier3, "#.00") + " " + str.tostring(dev3Below, format.mintick) : "VA -" + str.tostring(devMultiplier3, "#.00")

                        dev1AboveLabel := label.new(labelX, dev1Above, dev1AboveText, xloc=xloc.bar_index, yloc=yloc.price, style=labelStyle, color=color.new(devColorAbove, 85), textcolor=devColorAbove, size=size.small)
                        dev2AboveLabel := label.new(labelX, dev2Above, dev2AboveText, xloc=xloc.bar_index, yloc=yloc.price, style=labelStyle, color=color.new(devColorAbove, 85), textcolor=devColorAbove, size=size.small)
                        dev3AboveLabel := label.new(labelX, dev3Above, dev3AboveText, xloc=xloc.bar_index, yloc=yloc.price, style=labelStyle, color=color.new(devColorAbove, 85), textcolor=devColorAbove, size=size.small)

                        dev1BelowLabel := label.new(labelX, dev1Below, dev1BelowText, xloc=xloc.bar_index, yloc=yloc.price, style=labelStyle, color=color.new(devColorBelow, 85), textcolor=devColorBelow, size=size.small)
                        dev2BelowLabel := label.new(labelX, dev2Below, dev2BelowText, xloc=xloc.bar_index, yloc=yloc.price, style=labelStyle, color=color.new(devColorBelow, 85), textcolor=devColorBelow, size=size.small)
                        dev3BelowLabel := label.new(labelX, dev3Below, dev3BelowText, xloc=xloc.bar_index, yloc=yloc.price, style=labelStyle, color=color.new(devColorBelow, 85), textcolor=devColorBelow, size=size.small)

// EMA 
emaValue = ta.ema(emaSource, emaLength)

plot(showEMA ? emaValue : na, title="EMA", color=emaColor, linewidth=emaWidth)

//--------------------------------------------------------------------------------------------------
// Session VWAP with standard-deviation bands
//--------------------------------------------------------------------------------------------------
newVWAPPeriod =
     vwapAnchorMode == "RTH" ?
         newRTH :
     vwapAnchorMode == "Overnight" ?
         newOVN :
         timeframe.change("D")

vwapSessionActive =
     vwapAnchorMode == "RTH" ?
         inRTH :
     vwapAnchorMode == "Overnight" ?
         inOVN :
         true

var float cumulativeVWAPVolume = 0.0
var float cumulativeVWAPPriceVolume = 0.0
var float cumulativeVWAPSquaredPriceVolume = 0.0
var bool vwapPeriodStarted = false

if newVWAPPeriod
    cumulativeVWAPVolume := 0.0
    cumulativeVWAPPriceVolume := 0.0
    cumulativeVWAPSquaredPriceVolume := 0.0
    vwapPeriodStarted := true

if vwapPeriodStarted and vwapSessionActive
    cumulativeVWAPVolume += volume
    cumulativeVWAPPriceVolume += vwapSource * volume
    cumulativeVWAPSquaredPriceVolume += vwapSource * vwapSource * volume

sessionVWAP =
     cumulativeVWAPVolume > 0 ?
         cumulativeVWAPPriceVolume / cumulativeVWAPVolume :
         na

vwapVariance =
     cumulativeVWAPVolume > 0 ?
         math.max(
             cumulativeVWAPSquaredPriceVolume / cumulativeVWAPVolume -
             sessionVWAP * sessionVWAP,
             0.0
         ) :
         na

vwapStandardDeviation = not na(vwapVariance) ? math.sqrt(vwapVariance) : na

vwapUpperBand1 = sessionVWAP + vwapStandardDeviation * vwapBand1Mult
vwapLowerBand1 = sessionVWAP - vwapStandardDeviation * vwapBand1Mult

vwapUpperBand2 = sessionVWAP + vwapStandardDeviation * vwapBand2Mult
vwapLowerBand2 = sessionVWAP - vwapStandardDeviation * vwapBand2Mult

vwapUpperBand3 = sessionVWAP + vwapStandardDeviation * vwapBand3Mult
vwapLowerBand3 = sessionVWAP - vwapStandardDeviation * vwapBand3Mult

plot(
     showVWAP ? sessionVWAP : na,
     title="Session VWAP",
     color=vwapColor,
     linewidth=vwapLineWidth
)

vwapUpper1Plot = plot(
     showVWAP and showVWAPBand1 ? vwapUpperBand1 : na,
     title="VWAP Upper Band 1",
     color=vwapBand1Color,
     linewidth=vwapBandWidth
)

vwapLower1Plot = plot(
     showVWAP and showVWAPBand1 ? vwapLowerBand1 : na,
     title="VWAP Lower Band 1",
     color=vwapBand1Color,
     linewidth=vwapBandWidth
)

vwapUpper2Plot = plot(
     showVWAP and showVWAPBand2 ? vwapUpperBand2 : na,
     title="VWAP Upper Band 2",
     color=vwapBand2Color,
     linewidth=vwapBandWidth
)

vwapLower2Plot = plot(
     showVWAP and showVWAPBand2 ? vwapLowerBand2 : na,
     title="VWAP Lower Band 2",
     color=vwapBand2Color,
     linewidth=vwapBandWidth
)

vwapUpper3Plot = plot(
     showVWAP and showVWAPBand3 ? vwapUpperBand3 : na,
     title="VWAP Upper Band 3",
     color=vwapBand3Color,
     linewidth=vwapBandWidth
)

vwapLower3Plot = plot(
     showVWAP and showVWAPBand3 ? vwapLowerBand3 : na,
     title="VWAP Lower Band 3",
     color=vwapBand3Color,
     linewidth=vwapBandWidth
)

//--------------------------------------------------------------------------------------------------
// Volume Surge Highlights
//--------------------------------------------------------------------------------------------------
avgVolumeSurge = ta.sma(volume, volSurgeLength)
volMultipleSurge = avgVolumeSurge > 0 ? volume / avgVolumeSurge : na

isVolumeSurge = showVolSurgeHighlights and inRTH and not na(volMultipleSurge) and volMultipleSurge > volSurgeMult
isUpVolumeBar = close >= close[1]

volumeSurgeColor = isVolumeSurge ? isUpVolumeBar ? volSurgeUpColor : volSurgeDownColor : na

bgcolor(volumeSurgeColor, title="Volume Surge Highlight")

// Alerts for price touching VP levels
touchPOC = not na(pdPocPrice) and low <= pdPocPrice and high >= pdPocPrice
touchVAH = not na(pdVahPrice) and low <= pdVahPrice and high >= pdVahPrice
touchVAL = not na(pdValPrice) and low <= pdValPrice and high >= pdValPrice

touchAnyProfileLevel = touchPOC or touchVAH or touchVAL
touchAnyProfileLevelRTH = inRTH and touchAnyProfileLevel

alertcondition(touchAnyProfileLevelRTH, title="Price touched VP level", message="Price touched POC, VAH, or VAL")
````
