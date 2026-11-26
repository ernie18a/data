# Banks Order Blocks

- url: https://www.tradingview.com/script/HYMCGMyB-Banks-Order-Blocks/
- type: indicator
- pine_id: PUB;4ffe6c08007d462680993f282d0a0257
- version: 7.0

## Description

Banks Order Blocks (BOB) with Dynamic Volume Tracking
Overview
The Banks Order Blocks (BOB) indicator is a highly advanced price action and volume analysis tool designed to identify significant supply and demand zones where institutional players (banks, market makers) are likely stepping into the market. Unlike traditional order block indicators that merely draw static boxes, BOB dynamically tracks market volume inside the order block zones bar-by-bar, giving you a real-time visualization of buying and selling pressure exactly where it matters most.

Key Features & The Core Mechanic

Dynamic Volume Bars: Whenever an order block is active or price returns to it, volume bars are drawn directly attached to the block. This allows you to visually gauge whether the market is defending the zone with high volume or abandoning it.
Smart State Management: The indicator intelligently manages "Active" and "Passive" blocks. When a new Bullish block forms, it becomes the Active one. If price action later dips back into an older, Passive block, the indicator instantly clears the old, cluttered volume data of that passive block and starts printing fresh volume bars from the exact candle that re-entered the zone. This is the core mechanic—you only see the volume that is relevant right now during a retest of conflicting zones.
Built-in Alerts: Stay informed with automated alerts for new order block formations, price re-entering a block, and high-volume directional candles forming inside a block.
Mid-line (0.5 Level) Tracking: Each block includes a dynamically drawn 50% (Equilibrium) dotted line, a critical level often defended by institutions.
How to Trade with BOB (Setup Guide)

1. The Primary Setup (Trend Continuation / Reversal)

Wait for a New Order Block to form (Green for Bullish/Demand, Red for Bearish/Supply).
Watch for the price to retrace and re-enter the active zone.
Confirmation: Look at the volume bars generating inside the block. A successful defense of a Bullish Order Block should show green volume bars heavily outweighing red ones, especially crossing above the local volume moving average (indicated by solid, non-transparent colors).
Entry: Enter on a high-volume directional candle closing inside or pushing away from the order block.
Invalidation: If a candle closes below the bottom of a Bullish block (or above a Bearish block), the thesis is invalidated, and the indicator will automatically delete the block.
2. The Clashing Zones Setup (Advanced Tactics)

Sometimes price action escapes an Active Bullish block and enters a higher, older Bearish block.
Because of BOB's Smart State Management, as soon as the price enters the opposing older block, fresh volume bars will start generating inside that specific zone.
Confirmation: You now have a real-time tug-of-war. Watch the volume bars forming in both the active and the passive block. Enter in the direction of the block that is printing aggressive, high-volume (solid color) bars, confirming institutional defense.
Customization

Pivot Length: Adjust the sensitivity of order block detection.
Optional Overlays: Easily toggle VWAP or various Moving Averages (SMA, EMA, WMA, RMA) directly from the settings to add confluence to your entries.
Disclaimer
The information and tools provided by this script are for educational and informational purposes only and do not constitute financial or investment advice. Trading in financial markets involves a high degree of risk and may not be suitable for all investors. Past performance is not indicative of future results. Always conduct your own research and consult with a certified financial advisor before making any trading decisions. The author is not responsible for any financial losses incurred while using this indicator.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ MPL-2.0
//@version=6
indicator("Banks Order Blocks", shorttitle="BOB", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// ==================== BOB INPUTS ====================
pivotLength = input.int(10, "Pivot Length", minval=5)
extendRight = input.int(1, "Extend Boxes Right (Bars)", minval=0)
breakDeleteDelay = input.int(6, "Delete Box N Bars After Break", minval=0, group="Box Break Settings", tooltip="Waits this many bars after a closing-price break before deleting the box. Price must return to the box before the deletion bar to cancel deletion. Use 0 for immediate deletion.")

// Alert Settings
alrtBullBox = input.bool(true, "Alert: Bullish BOS after Bullish Box", group="Alert Settings")
alrtBearBox = input.bool(true, "Alert: Bearish BOS after Bearish Box", group="Alert Settings")
firstBreakOnly = input.bool(false, "Show Only First Breakout per Box (First Reaction)", group="Alert Settings", tooltip="If enabled, only marks the first BOS breakout for a given active box to reduce chart clutter.")
hideOppositeBox = input.bool(true, "Delete Old Box if New Forms Inside", group="Alert Settings", tooltip="Deletes an older box if a new box forms inside it.")

// Volume Settings
showVolBars = input.bool(true, "Show Volume Bars", group="Volume Settings", tooltip="Toggle the visibility of dynamic volume bars inside the order blocks")
volMultiplier = input.float(0.7, "Volume Bar Height Multiplier", minval=0.1, step=0.5, group="Volume Settings")
volColUpHigh = input.color(color.new(#00ff20, 0), "Volume Bullish High", group="Volume Settings")
volColUpLow = input.color(color.new(#089981, 60), "Volume Bullish Low", group="Volume Settings")
volColUpOpp = input.color(color.new(#f23645, 85), "Volume Bullish Opposite (Red)", group="Volume Settings")
volColDnHigh = input.color(color.new(#ff3030, 0), "Volume Bearish High", group="Volume Settings")
volColDnLow = input.color(color.new(#f23645, 60), "Volume Bearish Low", group="Volume Settings")
volColDnOpp = input.color(color.new(#089981, 85), "Volume Bearish Opposite (Green)", group="Volume Settings")

// VWAP & MA
showVwap = input.bool(false, "Show VWAP", group="VWAP Settings")
vwapColor = input.color(color.gray, "VWAP Color", group="VWAP Settings")
vwapWidth = input.int(1, "VWAP Line Width", minval=1, maxval=5, group="VWAP Settings")

maType = input.string("None", "Moving Average Type", options=["None", "SMA", "EMA", "WMA", "RMA"], group="Moving Average Settings")
maLength = input.int(50, "MA Length", minval=1, group="Moving Average Settings")
maColor = input.color(color.orange, "MA Color", group="Moving Average Settings")
maWidth = input.int(1, "MA Line Width", minval=1, maxval=5, group="Moving Average Settings")

// ==================== BLVL INPUTS ====================
grpCore = "BLVL Core"
len = input.int(10, "Fractal Length", minval=3, maxval=51, group=grpCore)
barsToRight = input.int(10, "Bars to Right", minval=1, maxval=300, group=grpCore)
requireBody = input.bool(true, "Break = Close Beyond Level", group=grpCore)

grpPerf = "BLVL Performance"
calcLastBars = input.int(20000, "Calc Only Last N Bars (0=all)", minval=0, maxval=50000, group=grpPerf)
maxKeep = input.int(2500, "Max Stored Broken (hard cap)", minval=100, maxval=20000, group=grpPerf)
showLastN = input.int(0, "Show Last N Broken (0=all)", minval=0, maxval=5000, group=grpPerf)

grpCand = "Candidate (Pre-break)"
candColUp = input.color(color.rgb(8,153,129), "Candidate UP Color", group=grpCand)
candColDn = input.color(color.rgb(242,54,69), "Candidate DN Color", group=grpCand)
candW = input.int(2, "Candidate Width", minval=1, maxval=5, group=grpCand)
candStyleS = input.string("Dashed", "Candidate Style", options=["Solid","Dashed","Dotted"], group=grpCand)

showCandText = input.bool(true, "Show Candidate Text", group=grpCand)
candTxtUp = input.string("BOS ↑", "Candidate UP Text", group=grpCand)
candTxtDn = input.string("BOS ↓", "Candidate DN Text", group=grpCand)

grpBrk = "Broken (Post-break)"
brkUpCol = input.color(color.rgb(8,153,129), "Broken UP Color (#089981)", group=grpBrk)
brkDnCol = input.color(color.rgb(242,54,69), "Broken DN Color", group=grpBrk)
brkW = input.int(1, "Broken Width", minval=1, maxval=5, group=grpBrk)
brkStyleS = input.string("Solid", "Broken Style", options=["Solid","Dashed","Dotted"], group=grpBrk)

grpLbl = "BOS/CHoCH Labels"
lbOn = input.bool(true, "Show BOS/CHoCH Labels", group=grpLbl)
lbSzS = input.string("tiny", "Label Size", options=["tiny","small","normal"], group=grpLbl)
lbBg = input.color(color.new(color.white, 100), "Label Bg (transparent)", group=grpLbl)
lbTxtUp = input.color(color.rgb(8,153,129), "UP Label Text Color", group=grpLbl)
lbTxtDn = input.color(color.rgb(242,54,69), "DN Label Text Color", group=grpLbl)

// ==================== HELPERS ====================
f_ls(string s) => s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted
f_sz(string s) => s == "tiny" ? size.tiny : s == "small" ? size.small : size.normal

candStyle = f_ls(candStyleS)
brkStyle = f_ls(brkStyleS)
lbSize = f_sz(lbSzS)

inCalc = calcLastBars == 0 or bar_index >= last_bar_index - calcLastBars

// ==================== BOB CALCULATIONS ====================
ph = ta.pivothigh(high, pivotLength, pivotLength)
pl = ta.pivotlow(low, pivotLength, pivotLength)

vwapVal = ta.vwap(hlc3)
plot(showVwap ? vwapVal : na, "VWAP", color=vwapColor, linewidth=vwapWidth)

smaVal = ta.sma(close, maLength)
emaVal = ta.ema(close, maLength)
wmaVal = ta.wma(close, maLength)
rmaVal = ta.rma(close, maLength)
float maVal = switch maType
    "SMA" => smaVal
    "EMA" => emaVal
    "WMA" => wmaVal
    "RMA" => rmaVal
    => na
plot(maType != "None" ? maVal : na, "Moving Average", color=maColor, linewidth=maWidth)

localMaxVol = ta.highest(volume, 300)
localMaxVol := localMaxVol == 0 ? 1 : localMaxVol
volSma = ta.sma(volume, 20)

type OrderBlock
    box zone
    label txtLabel
    box[] volBars
    int lastBarIndex
    line midLine
    bool wasOutside
    bool drawVolume
    bool isFaded
    bool hasSignaled
    int breakBarIndex

var OrderBlock[] bullBlocks = array.new<OrderBlock>(0)
var OrderBlock[] bearBlocks = array.new<OrderBlock>(0)

method clearVolumeBars(OrderBlock ob) =>
    if array.size(ob.volBars) > 0
        for vb in ob.volBars
            box.delete(vb)
        array.clear(ob.volBars)

half_dur = int((time - nz(time[1], time - 60000)) * 0.4)
borderColor = color.new(color.black, 80)

// Active and Faded Colors
bullActiveBoxCol = color.new(#089981, 75)
bullFadedBoxCol = color.new(#089981, 92)
bullActiveLinCol = color.new(#089981, 0)
bullFadedLinCol = color.new(#089981, 80)

bearActiveBoxCol = color.new(#f23645, 75)
bearFadedBoxCol = color.new(#f23645, 92)
bearActiveLinCol = color.new(#f23645, 0)
bearFadedLinCol = color.new(#f23645, 80)

// --- Bullish BOB ---
if not na(pl)
    bullCount = 0
    totalVol = 0.0
    for i = 0 to 3
        idx = pivotLength - i
        if close[idx] > open[idx]
            bullCount += 1
        totalVol += volume[idx]

    if bullCount >= 3
        if array.size(bullBlocks) > 0
            for i = array.size(bullBlocks) - 1 to 0
                ob = array.get(bullBlocks, i)
                isInside = hideOppositeBox and low[pivotLength] <= box.get_top(ob.zone) and high[pivotLength] >= box.get_bottom(ob.zone)
                if isInside
                    box.delete(ob.zone)
                    if not na(ob.txtLabel)
                        label.delete(ob.txtLabel)
                    line.delete(ob.midLine)
                    ob.clearVolumeBars()
                    array.remove(bullBlocks, i)
                else
                    if not na(ob.txtLabel)
                        label.delete(ob.txtLabel)
                    ob.drawVolume := false
                    ob.clearVolumeBars()
                    ob.isFaded := true
                    box.set_bgcolor(ob.zone, bullFadedBoxCol)
                    line.set_color(ob.midLine, bullFadedLinCol)

        if hideOppositeBox and array.size(bearBlocks) > 0
            for i = array.size(bearBlocks) - 1 to 0
                ob = array.get(bearBlocks, i)
                if low[pivotLength] <= box.get_top(ob.zone) and high[pivotLength] >= box.get_bottom(ob.zone)
                    box.delete(ob.zone)
                    if not na(ob.txtLabel)
                        label.delete(ob.txtLabel)
                    line.delete(ob.midLine)
                    ob.clearVolumeBars()
                    array.remove(bearBlocks, i)

        b = box.new(left=bar_index[pivotLength], top=high[pivotLength], right=bar_index + extendRight, bottom=low[pivotLength],
          border_color=color.new(color.white, 100), bgcolor=bullActiveBoxCol)
        midY = (high[pivotLength] + low[pivotLength]) / 2
        mLine = line.new(x1=bar_index[pivotLength], y1=midY, x2=bar_index + extendRight, y2=midY, color=bullActiveLinCol, style=line.style_dotted, width=1)

        box[] vBars = array.new_box(0)
        boxHeight = high[pivotLength] - low[pivotLength]
        for i = pivotLength to 0
            vRatio = volume[i] / localMaxVol[i]
            vHeight = boxHeight * vRatio * volMultiplier
            isGreen = close[i] >= open[i]
            isHighVol = volume[i] > volSma[i]
            lineColor = isGreen ? (isHighVol ? volColUpHigh : volColUpLow) : volColUpOpp
            if showVolBars
                bBar = box.new(left=time[i] - half_dur, top=low[pivotLength] + vHeight, right=time[i] + half_dur, bottom=low[pivotLength],
                  xloc=xloc.bar_time, border_color=borderColor, border_width=1, bgcolor=lineColor)
                array.push(vBars, bBar)

        boxText = "BOB\n" + str.tostring(totalVol, format.volume)
        lbl = label.new(x=bar_index + extendRight, y=midY, text=boxText, color=color.new(color.white, 100), textcolor=color.new(#089981, 0), style=label.style_label_left, size=size.small)
        array.push(bullBlocks, OrderBlock.new(b, lbl, vBars, bar_index, mLine, false, true, false, false, int(na)))

// --- Bearish BOB ---
if not na(ph)
    bearCount = 0
    totalVol = 0.0
    for i = 0 to 4
        idx = pivotLength - i
        if close[idx] < open[idx]
            bearCount += 1
        totalVol += volume[idx]

    if bearCount >= 4
        if array.size(bearBlocks) > 0
            for i = array.size(bearBlocks) - 1 to 0
                ob = array.get(bearBlocks, i)
                isInside = hideOppositeBox and low[pivotLength] <= box.get_top(ob.zone) and high[pivotLength] >= box.get_bottom(ob.zone)
                if isInside
                    box.delete(ob.zone)
                    if not na(ob.txtLabel)
                        label.delete(ob.txtLabel)
                    line.delete(ob.midLine)
                    ob.clearVolumeBars()
                    array.remove(bearBlocks, i)
                else
                    if not na(ob.txtLabel)
                        label.delete(ob.txtLabel)
                    ob.drawVolume := false
                    ob.clearVolumeBars()
                    ob.isFaded := true
                    box.set_bgcolor(ob.zone, bearFadedBoxCol)
                    line.set_color(ob.midLine, bearFadedLinCol)

        if hideOppositeBox and array.size(bullBlocks) > 0
            for i = array.size(bullBlocks) - 1 to 0
                ob = array.get(bullBlocks, i)
                if low[pivotLength] <= box.get_top(ob.zone) and high[pivotLength] >= box.get_bottom(ob.zone)
                    box.delete(ob.zone)
                    if not na(ob.txtLabel)
                        label.delete(ob.txtLabel)
                    line.delete(ob.midLine)
                    ob.clearVolumeBars()
                    array.remove(bullBlocks, i)

        b = box.new(left=bar_index[pivotLength], top=high[pivotLength], right=bar_index + extendRight, bottom=low[pivotLength],
          border_color=color.new(color.white, 100), bgcolor=bearActiveBoxCol)
        midY = (high[pivotLength] + low[pivotLength]) / 2
        mLine = line.new(x1=bar_index[pivotLength], y1=midY, x2=bar_index + extendRight, y2=midY, color=bearActiveLinCol, style=line.style_dotted, width=1)

        box[] vBars = array.new_box(0)
        boxHeight = high[pivotLength] - low[pivotLength]
        for i = pivotLength to 0
            vRatio = volume[i] / localMaxVol[i]
            vHeight = boxHeight * vRatio * volMultiplier
            isRed = close[i] < open[i]
            isHighVol = volume[i] > volSma[i]
            lineColor = isRed ? (isHighVol ? volColDnHigh : volColDnLow) : volColDnOpp
            if showVolBars
                bBar = box.new(left=time[i] - half_dur, top=high[pivotLength], right=time[i] + half_dur, bottom=high[pivotLength] - vHeight,
                  xloc=xloc.bar_time, border_color=borderColor, border_width=1, bgcolor=lineColor)
                array.push(vBars, bBar)

        boxText = "BOB\n" + str.tostring(totalVol, format.volume)
        lbl = label.new(x=bar_index + extendRight, y=midY, text=boxText, color=color.new(color.white, 100), textcolor=color.new(#f23645, 0), style=label.style_label_left, size=size.small)
        array.push(bearBlocks, OrderBlock.new(b, lbl, vBars, bar_index, mLine, false, true, false, false, int(na)))

// Extending and Updating BOBs
bool bullVolDrawnThisBar = false
for i = math.max(0, array.size(bullBlocks) - 1) to 0
    if i >= 0 and i < array.size(bullBlocks)
        ob = array.get(bullBlocks, i)
        zoneTop = box.get_top(ob.zone)
        zoneBottom = box.get_bottom(ob.zone)
        isInside = low <= zoneTop and high >= zoneBottom
        bool deleteBlock = false

        if na(ob.breakBarIndex)
            if close < zoneBottom
                if breakDeleteDelay == 0
                    deleteBlock := true
                else
                    ob.breakBarIndex := bar_index
        else
            barsSinceBreak = bar_index - ob.breakBarIndex
            if barsSinceBreak >= breakDeleteDelay
                deleteBlock := true
            else if isInside
                ob.breakBarIndex := na

        if deleteBlock
            box.delete(ob.zone)
            if not na(ob.txtLabel)
                label.delete(ob.txtLabel)
            line.delete(ob.midLine)
            ob.clearVolumeBars()
            array.remove(bullBlocks, i)
        else
            box.set_right(ob.zone, bar_index + extendRight)
            if not na(ob.txtLabel)
                label.set_x(ob.txtLabel, bar_index + extendRight)
                label.set_y(ob.txtLabel, (zoneTop + zoneBottom) / 2)
            line.set_x2(ob.midLine, bar_index + extendRight)

            if low > zoneTop
                ob.wasOutside := true
            if ob.wasOutside and low <= zoneTop
                ob.wasOutside := false

            // Re-activate visually if price re-enters a faded box
            if isInside and ob.isFaded
                ob.isFaded := false
                box.set_bgcolor(ob.zone, bullActiveBoxCol)
                line.set_color(ob.midLine, bullActiveLinCol)

            if isInside and not ob.drawVolume
                ob.drawVolume := true

            if ob.drawVolume and showVolBars and not bullVolDrawnThisBar
                bullVolDrawnThisBar := true
                boxHeight = zoneTop - zoneBottom
                vRatio = volume / localMaxVol
                vHeight = boxHeight * vRatio * volMultiplier
                isGreen = close >= open
                isHighVol = volume > volSma
                lineColor = isGreen ? (isHighVol ? volColUpHigh : volColUpLow) : volColUpOpp

                if ob.lastBarIndex < bar_index
                    bBar = box.new(left=time - half_dur, top=zoneBottom + vHeight, right=time + half_dur, bottom=zoneBottom,
                      xloc=xloc.bar_time, border_color=borderColor, border_width=1, bgcolor=lineColor)
                    array.push(ob.volBars, bBar)
                    ob.lastBarIndex := bar_index
                    if array.size(ob.volBars) > 200
                        box.delete(array.shift(ob.volBars))
                else if array.size(ob.volBars) > 0
                    lastBox = array.get(ob.volBars, array.size(ob.volBars) - 1)
                    box.set_top(lastBox, zoneBottom + vHeight)
                    box.set_bgcolor(lastBox, lineColor)
                    box.set_left(lastBox, time - half_dur)
                    box.set_right(lastBox, time + half_dur)

bool bearVolDrawnThisBar = false
for i = math.max(0, array.size(bearBlocks) - 1) to 0
    if i >= 0 and i < array.size(bearBlocks)
        ob = array.get(bearBlocks, i)
        zoneTop = box.get_top(ob.zone)
        zoneBottom = box.get_bottom(ob.zone)
        isInside = low <= zoneTop and high >= zoneBottom
        bool deleteBlock = false

        if na(ob.breakBarIndex)
            if close > zoneTop
                if breakDeleteDelay == 0
                    deleteBlock := true
                else
                    ob.breakBarIndex := bar_index
        else
            barsSinceBreak = bar_index - ob.breakBarIndex
            if barsSinceBreak >= breakDeleteDelay
                deleteBlock := true
            else if isInside
                ob.breakBarIndex := na

        if deleteBlock
            box.delete(ob.zone)
            if not na(ob.txtLabel)
                label.delete(ob.txtLabel)
            line.delete(ob.midLine)
            ob.clearVolumeBars()
            array.remove(bearBlocks, i)
        else
            box.set_right(ob.zone, bar_index + extendRight)
            if not na(ob.txtLabel)
                label.set_x(ob.txtLabel, bar_index + extendRight)
                label.set_y(ob.txtLabel, (zoneTop + zoneBottom) / 2)
            line.set_x2(ob.midLine, bar_index + extendRight)

            if high < zoneBottom
                ob.wasOutside := true
            if ob.wasOutside and high >= zoneBottom
                ob.wasOutside := false

            // Re-activate visually if price re-enters a faded box
            if isInside and ob.isFaded
                ob.isFaded := false
                box.set_bgcolor(ob.zone, bearActiveBoxCol)
                line.set_color(ob.midLine, bearActiveLinCol)

            if isInside and not ob.drawVolume
                ob.drawVolume := true

            if ob.drawVolume and showVolBars and not bearVolDrawnThisBar
                bearVolDrawnThisBar := true
                boxHeight = zoneTop - zoneBottom
                vRatio = volume / localMaxVol
                vHeight = boxHeight * vRatio * volMultiplier
                isRed = close < open
                isHighVol = volume > volSma
                lineColor = isRed ? (isHighVol ? volColDnHigh : volColDnLow) : volColDnOpp

                if ob.lastBarIndex < bar_index
                    bBar = box.new(left=time - half_dur, top=zoneTop, right=time + half_dur, bottom=zoneTop - vHeight,
                      xloc=xloc.bar_time, border_color=borderColor, border_width=1, bgcolor=lineColor)
                    array.push(ob.volBars, bBar)
                    ob.lastBarIndex := bar_index
                    if array.size(ob.volBars) > 200
                        box.delete(array.shift(ob.volBars))
                else if array.size(ob.volBars) > 0
                    lastBox = array.get(ob.volBars, array.size(ob.volBars) - 1)
                    box.set_bottom(lastBox, zoneTop - vHeight)
                    box.set_bgcolor(lastBox, lineColor)
                    box.set_left(lastBox, time - half_dur)
                    box.set_right(lastBox, time + half_dur)

// ==================== BLVL CALCULATIONS ====================
L = (len % 2 == 0) ? (len + 1) : len
p = int(L / 2)
tfSec = timeframe.in_seconds(timeframe.period)
extMs = tfSec * 1000 * barsToRight

phVal = ta.pivothigh(high, p, p)
plVal = ta.pivotlow(low, p, p)
phHit = not na(phVal)
plHit = not na(plVal)

var float upLvl = na
var int upT = na
var bool upBroken = false
var line upLine = na
var label upCandLb = na

var float dnLvl = na
var int dnT = na
var bool dnBroken = false
var line dnLine = na
var label dnCandLb = na

var int os = 0

var line[] brkLines = array.new_line()
var label[] brkLabs = array.new_label()

f_trimBroken() =>
    if showLastN > 0
        while array.size(brkLines) > showLastN
            line oldLn = array.shift(brkLines)
            label oldLb = array.shift(brkLabs)
            if not na(oldLn)
                line.delete(oldLn)
            if not na(oldLb)
                label.delete(oldLb)

    while array.size(brkLines) > maxKeep
        line oldLn = array.shift(brkLines)
        label oldLb = array.shift(brkLabs)
        if not na(oldLn)
            line.delete(oldLn)
        if not na(oldLb)
            label.delete(oldLb)

f_pushBroken(line ln, label lb) =>
    array.push(brkLines, ln)
    array.push(brkLabs, lb)
    f_trimBroken()

if inCalc
    if phHit
        if not na(upLine) and not upBroken
            line.delete(upLine)
        if not na(upCandLb)
            label.delete(upCandLb)
        upLvl := phVal
        upT := time[p]
        upBroken := false
        upLine := line.new(upT, upLvl, time + extMs, upLvl, xloc=xloc.bar_time, extend=extend.none, color=candColUp, style=candStyle, width=candW)
        if showCandText
            upCandLb := label.new(upT, upLvl, candTxtUp, xloc=xloc.bar_time, style=label.style_label_down, textcolor=candColUp, color=lbBg, size=lbSize)
        else
            upCandLb := na

    if plHit
        if not na(dnLine) and not dnBroken
            line.delete(dnLine)
        if not na(dnCandLb)
            label.delete(dnCandLb)
        dnLvl := plVal
        dnT := time[p]
        dnBroken := false
        dnLine := line.new(dnT, dnLvl, time + extMs, dnLvl, xloc=xloc.bar_time, extend=extend.none, color=candColDn, style=candStyle, width=candW)
        if showCandText
            dnCandLb := label.new(dnT, dnLvl, candTxtDn, xloc=xloc.bar_time, style=label.style_label_up, textcolor=candColDn, color=lbBg, size=lbSize)
        else
            dnCandLb := na

if inCalc
    if not na(upLine) and not upBroken
        line.set_x2(upLine, time + extMs)
    if not na(dnLine) and not dnBroken
        line.set_x2(dnLine, time + extMs)

brkUp = false
brkDn = false

bool markBullBreak = false
bool markBearBreak = false

if inCalc
    if not na(upLvl) and not upBroken
        brkUp := requireBody ? close > upLvl : high > upLvl
        if brkUp
            for ob in bullBlocks
                if not firstBreakOnly or not ob.hasSignaled
                    markBullBreak := true
                    ob.hasSignaled := true

    if not na(dnLvl) and not dnBroken
        brkDn := requireBody ? close < dnLvl : low < dnLvl
        if brkDn
            for ob in bearBlocks
                if not firstBreakOnly or not ob.hasSignaled
                    markBearBreak := true
                    ob.hasSignaled := true

if inCalc
    if brkUp
        upBroken := true
        if not na(upLine)
            line.set_color(upLine, brkUpCol)
            line.set_style(upLine, brkStyle)
            line.set_width(upLine, brkW)
            line.set_x2(upLine, time)
        if not na(upCandLb)
            label.delete(upCandLb)
            upCandLb := na
        label lb = na
        if lbOn
            string txt = os == -1 ? "CHoCH" : "BOS"
            lb := label.new(int(math.avg(time, upT)), upLvl, txt, xloc=xloc.bar_time, style=label.style_label_down, textcolor=lbTxtUp, color=lbBg, size=lbSize)
        f_pushBroken(upLine, lb)
        upLine := na
        os := 1

    if brkDn
        dnBroken := true
        if not na(dnLine)
            line.set_color(dnLine, brkDnCol)
            line.set_style(dnLine, brkStyle)
            line.set_width(dnLine, brkW)
            line.set_x2(dnLine, time)
        if not na(dnCandLb)
            label.delete(dnCandLb)
            dnCandLb := na
        label lb = na
        if lbOn
            string txt = os == 1 ? "CHoCH" : "BOS"
            lb := label.new(int(math.avg(time, dnT)), dnLvl, txt, xloc=xloc.bar_time, style=label.style_label_up, textcolor=lbTxtDn, color=lbBg, size=lbSize)
        f_pushBroken(dnLine, lb)
        dnLine := na
        os := -1

// Breakout Markers
plotshape(markBullBreak, title="Bullish Break", style=shape.triangleup, location=location.belowbar, color=color.new(#089981, 0), size=size.tiny)
plotshape(markBearBreak, title="Bearish Break", style=shape.triangledown, location=location.abovebar, color=color.new(#f23645, 0), size=size.tiny)

// Alerts
if alrtBullBox and markBullBreak
    alert("Bullish BOS after Bullish Box", alert.freq_once_per_bar_close)

if alrtBearBox and markBearBreak
    alert("Bearish BOS after Bearish Box", alert.freq_once_per_bar_close)
````
