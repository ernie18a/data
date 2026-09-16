<!-- tradingview-pine-id: PUB;7f617103be75490c9f6edbcfcd356435 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Imbalance Concept

Source: https://www.tradingview.com/script/RZfe2IgZ-Imbalance-Concept-Achira-Meegasthanne/

## Description

Imbalance Concept

Imbalance Concept is a price-action and market-liquidity indicator designed to help traders identify and visualize Imbalance Zones, Volume Gaps, Unfilled Orders, Liquidity Absorption, and Market Structure directly on the chart.

The indicator combines multiple market-analysis concepts into a single visual framework, allowing traders to study how price interacts with inefficient price areas, liquidity, volume, and structural conditions.

🔹 KEY FEATURES

📊 Imbalance Zones

Automatically detects bullish and bearish imbalance areas and displays them as dynamic zones on the chart.

Features include:
• Primary scan timeframe
• Fill sensitivity
• Dynamic zone reduction
• Forward zone projection
• Maximum zone age
• Bullish and bearish zone visualization

Zones can dynamically shrink as price enters them and can be removed once the configured fill threshold is reached.
💧 Volume Gaps

The indicator can detect potential Volume Gaps and display them as dedicated zones.

Volume gaps can remain visible until price fully interacts with the defined area.

A separate timeframe can also be used for volume-gap scanning.
📦 Unfilled Orders

The indicator tracks pending imbalance areas and provides optional zone levels and metrics.

You can control:
• Show Metrics
• Show Zone Levels
• Maximum Pending Zones
• Up Metrics Color
• Down Metrics Color

This helps visualize areas that may remain relevant until price interacts with them.

⚡ Liquidity Absorption

The Liquidity Absorption module evaluates volume relative to candle movement and calculates absorption levels using a statistical threshold.

It provides:
• Absorption Levels
• Absorption Index
• Buy Absorption
• Sell Absorption
• Configurable Zigma Threshold
• Absorption-based candle coloring

Absorption index values from 1 to 7 can be displayed directly on the chart.
📈 Market Structure

The indicator evaluates recent price structure using a configurable swing range and provides a simple market-bias classification:

• BULLISH
• BEARISH
• NEUTRAL

The dashboard displays the current structural bias for quick reference.
🎯 Footprint Metrics

When an imbalance is detected, the indicator can display footprint-style information based on candle range, body size, and volume.

The displayed information provides an estimated relationship between buying and selling volume within the detected imbalance area.

🖥️ Dashboard

A built-in dashboard provides quick market information directly on the chart.

The dashboard can display:
• Volume Gap status
• Current market trend
• Imbalance information
• Configurable dashboard position
• Configurable dashboard text size

Dashboard location can be set to Top Right, Bottom Right, or Bottom Left.
⚙️ CUSTOMIZATION

The indicator provides multiple settings to adapt the visualization to different trading styles:

• Primary Scan Timeframe
• Fill Sensitivity
• Dynamic Zone Reduction
• Project Zones Forward
• Price Gaps
• Volume Gaps
• Maximum Zone Age
• Unfilled Order Metrics
• Liquidity Absorption
• Absorption Threshold
• Dashboard Location
• Dashboard Size
• Bullish/Bearish Colors

🧠 HOW THE CONCEPT WORKS

1. Detect Imbalance

The indicator scans price relationships to identify potential bullish and bearish imbalance areas.

2. Create Dynamic Zones

Detected areas are drawn as zones and can dynamically adjust as price interacts with them.

3. Monitor Volume Gaps

Potential volume gaps are identified and tracked until price fills or interacts with the zone.

4. Track Absorption

Volume and price movement are analyzed to identify potential absorption levels and display absorption strength.

5. Evaluate Market Structure

Recent swing behavior is used to determine the current market bias.

6. Combine the Information

The dashboard and chart visualization bring these elements together to help traders study the relationship between Imbalance → Liquidity → Volume → Absorption → Market Structure.

⚠️ IMPORTANT DISCLAIMER

This indicator is provided for educational and analytical purposes only.

The zones, imbalance signals, volume information, absorption readings, and market-structure conditions should not be considered guaranteed buy or sell signals.

Market conditions can change rapidly, and no indicator can predict future price movement with certainty.

Always perform your own analysis, use appropriate risk management, and thoroughly test the indicator before using it in live trading.

Study the market. Understand the imbalance. Manage your risk.

---

## Source Code

````pine

//@version=6
indicator(title='Imbalance Concept', overlay=true,max_boxes_count = 500,max_lines_count = 500,behind_chart = false, max_bars_back = 500)

// === INPUT GROUP ===
grpMain = "Imbalance Zone"

mainTF          = input.timeframe('', 'Primary Scan Timeframe', group=grpMain)
fillThreshold   = input.float(0.2, minval=0, maxval=1, step=0.1, title='Fill Sensitivity', group=grpMain)
autoShrink      = input.bool(true, 'Dynamic Zone Reduction', group=grpMain)
forwardExtend   = input.bool(false, 'Project Zones Forward', group=grpMain)

showPriceGaps   = input.bool(false, 'Enable Price Gaps', group=grpMain)
bearFillCol     = input.color(color.new(#0df1c6, 80), 'Bear Zone Color', group=grpMain)
bearMidCol      = input.color(color.new(#0df1c6, 0), 'Bear Midline Color', group=grpMain)

bullFillCol     = input.color(color.new(#871ee9, 80), 'Bull Zone Color', group=grpMain)
bullMidCol      = input.color(color.new(#871ee9, 0), 'Bull Midline Color', group=grpMain)

volTF           = input.timeframe('', 'Volume Scan Timeframe', group=grpMain)
enableVolZones  = input.bool(true, 'Enable Volume Gaps', group=grpMain)
volZoneColor    = input.color(color.rgb(33,149,243,85), 'Volume Zone Shade', group=grpMain)

zoneMaxLife     = input.int(500, 'Maximum Zone Age', group=grpMain)


GroupUnfilled = "Unfilled Orders"

showMetrics    = input.bool(true, "Show Metrics", group=GroupUnfilled)
showLevels     = input.bool(true, "Show Zone Levels", group=GroupUnfilled)
maxPendingBoxes= input.int(50, "Max Pending Zones", 1, group=GroupUnfilled)

bullColor = input(#0df1c6, "Up Metrics Color", group=GroupUnfilled)
bearColor = input(#871ee9, "Down Metrics Color", group=GroupUnfilled)


GroupVolumeAbs = "Liquidity Absorption"

showAbsLevels = input.bool(true, "Show Absorption Level", group=GroupVolumeAbs)
showAbsIndex  = input.bool(true, "Show Absorption Index", group=GroupVolumeAbs)
zigThreshold  = input.int(2, "Zigma Threshold", minval=2, maxval=7, group=GroupVolumeAbs)

// Dashboard
gr_dashboard = "DASHBOARD SETTINGS"
showDash  = input(true, "Dashboard", group = gr_dashboard)
dashLoc  = input.string('Bottom Right', 'Location', options = ['Top Right', 'Bottom Right', 'Bottom Left'], group = gr_dashboard)
textSize = input.string('Normal', 'Size', options = ['Tiny', 'Small', 'Normal'], group = gr_dashboard)

// === STORAGE ARRAYS ===
var box[] bearZonesArr  = array.new_box()
var box[] bullZonesArr  = array.new_box()
var line[] bearMidArr   = array.new_line()
var line[] bullMidArr   = array.new_line()
var box[] volZonesArr   = array.new_box()

// === EXTENSION MODE ===
extendMode = forwardExtend ? extend.right : extend.none

// === GAP DETECTION FUNCTION ===
detectGap(ph1, ph3, pl1, pl3) =>
    // Bearish gap
    if ph3 < pl1 and pl3 != pl3[1]
        newBear = box.new(bar_index-2, pl1, bar_index+20, ph3,
            bgcolor = showPriceGaps ? bearFillCol : color(na),
            border_color = showPriceGaps ? bearFillCol : color(na),
            extend = extendMode)
        array.push(bearZonesArr, newBear)

        midVal = (ph3 - pl1)/2 + pl1
        newLine = line.new(bar_index-2, midVal, bar_index+20, midVal,
            style=line.style_dotted, extend=extendMode,
            color = showPriceGaps ? bearMidCol : color(na))
        array.push(bearMidArr, newLine)

    // Bullish gap
    if pl3 > ph1 and ph3 != ph3[1]
        newBull = box.new(bar_index-2, ph1, bar_index+20, pl3,
            bgcolor = showPriceGaps ? bullFillCol : color(na),
            border_color = showPriceGaps ? bullFillCol : color(na),
            extend = extendMode)
        array.push(bullZonesArr, newBull)

        midVal = (ph1 - pl3)/2 + pl3
        newLine = line.new(bar_index-2, midVal, bar_index+20, midVal,
            style=line.style_dotted, extend=extendMode,
            color = showPriceGaps ? bullMidCol : color(na))
        array.push(bullMidArr, newLine)

// === DATA REQUEST ===
getHTFdata(tfInput) =>
    [a1, a3, b1, b3] = request.security(syminfo.tickerid, tfInput,
        [high[1], high[3], low[1], low[3]],
        lookahead=barmerge.lookahead_on)
    [a1, a3, b1, b3]

[hA1, hA3, lA1, lA3] = getHTFdata(mainTF)
detectGap(hA1, hA3, lA1, lA3)

// === BULL ZONE MANAGEMENT ===
if array.size(bullZonesArr) > 0
    for idx = array.size(bullZonesArr)-1 to 0
        bx  = array.get(bullZonesArr, idx)
        top = box.get_top(bx)
        bot = box.get_bottom(bx)
        limit = (top - bot) * fillThreshold

        box.set_right(bx, bar_index+20)
        ln = array.get(bullMidArr, idx)
        line.set_x2(ln, bar_index+20)

        born = box.get_left(bx)

        if bar_index - born > zoneMaxLife
            box.delete(bx)
            array.remove(bullZonesArr, idx)
            line.delete(ln)
            array.remove(bullMidArr, idx)
        else
            if autoShrink and high > bot
                box.set_bottom(bx, high)

            if high >= bot + limit
                box.delete(bx)
                array.remove(bullZonesArr, idx)
                line.delete(ln)
                array.remove(bullMidArr, idx)

// === BEAR ZONE MANAGEMENT ===
if array.size(bearZonesArr) > 0
    for idx = array.size(bearZonesArr)-1 to 0
        bx  = array.get(bearZonesArr, idx)
        top = box.get_top(bx)
        bot = box.get_bottom(bx)
        limit = (top - bot) * fillThreshold

        box.set_right(bx, bar_index+20)
        ln = array.get(bearMidArr, idx)
        line.set_x2(ln, bar_index+20)

        born = box.get_left(bx)

        if bar_index - born > zoneMaxLife
            box.delete(bx)
            array.remove(bearZonesArr, idx)
            line.delete(ln)
            array.remove(bearMidArr, idx)
        else
            if autoShrink and low < top
                box.set_top(bx, low)

            if low <= top - limit
                box.delete(bx)
                array.remove(bearZonesArr, idx)
                line.delete(ln)
                array.remove(bearMidArr, idx)

// === STRUCTURE TREND ===
structureLen = 50
highestSwing = ta.highest(high, structureLen)
lowestSwing  = ta.lowest(low, structureLen)

isBullStruct = close > highestSwing[1]
isBearStruct = close < lowestSwing[1]

var string marketBias = "NEUTRAL"
if isBullStruct
    marketBias := "BULLISH"
else if isBearStruct
    marketBias := "BEARISH"

// === VOLUME GAP SECTION ===
[vo1, vc1, vo2, vc2, timeRef] =request.security(syminfo.tickerid, '',[open[1], close[1], open[2], close[2], time[2]],lookahead=barmerge.lookahead_on)

bool volGap = false

if enableVolZones
    volGap := (vo2 < vc2) ? (vc2 < vo1 and vc2 < vc1) : (vc2 > vo1 and vc2 > vc1)
    if not volGap
        volGap := (math.min(vo2, vc2) > math.max(vo1, vc1))

    if volGap
        lower = (math.min(vo1, vc1) > math.max(vo2, vc2)) ?math.max(vo2, vc2) : math.max(vo1, vc1)
        upper = (math.min(vo1, vc1) > math.max(vo2, vc2)) ?math.min(vo1, vc1) : math.min(vo2, vc2)

        vb = box.new(timeRef, upper, timeRef + 20*60*2000, lower,
            xloc=xloc.bar_time,
            bgcolor=volZoneColor,
            border_color=color.rgb(0,0,0,100))

        array.push(volZonesArr, vb)

    if array.size(volZonesArr) > 0
        for idx = array.size(volZonesArr)-1 to 0
            vb = array.get(volZonesArr, idx)
            t  = box.get_top(vb)
            b  = box.get_bottom(vb)

            if low <= math.min(t,b) and high >= math.max(t,b)
                box.delete(vb)
                array.remove(volZonesArr, idx)
            else
                box.set_right(vb, time + 20*60*2000)
//------------------------------------------------------------------------------------------------------------------
// === Box Storage ===
var box[] pendingZoneArray = array.new_box()

// === GAP / IMBALANCE CALCULATION ===
detectImbalance() =>
    topGap     = low[2] <= open[1] and high[0] >= close[1]
    topGapSize = low[2] - high[0]
    botGap     = high[2] >= open[1] and low[0] <= close[1]
    botGapSize = low[0] - high[2]
    [topGap, topGapSize, botGap, botGapSize]

[topGap, topGapSize, botGap, botGapSize] = detectImbalance()

// === BOX MANAGEMENT FUNCTION ===
removeOldBoxes(boxArr) =>
    if array.size(boxArr) > 0
        for idx = array.size(boxArr) - 1 to 0 by 1
            currBox  = array.get(boxArr, idx)
            topZone  = box.get_top(currBox)
            botZone  = box.get_bottom(currBox)
            rightEnd = box.get_right(currBox)
            // Future logic for chopping can be added here

// === BOX COORDINATES ===
isBearZone = topGap and topGapSize > 0
zoneTop   = isBearZone ? low[2] : low[0]
zoneBot   = isBearZone ? high[0] : high[2]

// === DRAW BOXES ===
if topGap and topGapSize > 0 or botGap and botGapSize > 0
    currentBear = topGap and topGapSize > 0
    currentTop  = currentBear ? low[2] : low[0]
    currentBot  = currentBear ? high[0] : high[2]

    newBox = showLevels ? box.new(bar_index, currentTop,bar_index, currentBot,currentBear ? bearColor : bullColor,border_style = line.style_solid,bgcolor=color(na),border_width=3) : na

    if array.size(pendingZoneArray) > maxPendingBoxes
        box.delete(array.shift(pendingZoneArray))
    array.push(pendingZoneArray, newBox)

removeOldBoxes(pendingZoneArray)

// === FOOTPRINT LABELS ===
buySignal  = botGap and botGapSize > 0
sellSignal = topGap and topGapSize > 0

footprintRows = 4

topY    = zoneTop
bottomY = zoneBot
rowStep = (topY - bottomY) / footprintRows

getFootprintText(idx) =>
    rng   = high[idx] - low[idx]
    body  = math.abs(close[idx] - open[idx])
    ratio = rng > 0 ? body / rng : 0.5

    buyVol  = math.round(volume[idx] * ratio)
    sellVol = volume[idx] - buyVol
    str.tostring(sellVol) + " x " + str.tostring(buyVol)

footprintLabelText =getFootprintText(3) + "\n" +getFootprintText(2) + "\n" +getFootprintText(1) + "\n" +getFootprintText(0)

buyLabel  = buySignal ? label.new(bar_index, bottomY, "", xloc.bar_index, yloc.price, color.new(bullColor, 60), label.style_circle, color.white, size.tiny) : na
sellLabel = sellSignal ? label.new(bar_index, topY, "", xloc.bar_index, yloc.price, color.new(bearColor, 60), label.style_circle, color.white, size.tiny) : na

buyFootprint  = buySignal and showMetrics ? label.new(bar_index, bottomY, footprintLabelText, xloc.bar_index, yloc.price, color(na), label.style_label_upper_left, bullColor, size.tiny) : na
sellFootprint = sellSignal and showMetrics ? label.new(bar_index, topY, footprintLabelText, xloc.bar_index, yloc.price, color(na), label.style_label_lower_left, bearColor, size.tiny) : na

var string lastZoneType = ""
lastZoneType := topGap and topGapSize > 0 ? "Top Zone" : (botGap and botGapSize > 0 ? "Bottom Zone" : lastZoneType)
//---------------------------------------------------------------------------------------------------------------------------------------------------------------
// === ABSORPTION CALCULATION ===
calcAbsorption() =>
    sellAbs = close < open ? volume / math.abs(open - close) / close : 0.0
    buyAbs  = close > open ? volume / math.abs(open - close) / close : 0.0
    [sellAbs, buyAbs]

[sellAbs, buyAbs] = calcAbsorption()

sellStd = ta.stdev(sellAbs, 50)
buyStd  = ta.stdev(buyAbs, 50)

sellSigma = sellAbs / sellStd
buySigma  = buyAbs / buyStd

sellSeries = sellSigma >= zigThreshold ? sellSigma : na
buySeries  = buySigma  >= zigThreshold ? buySigma  : na

lowestAbs  = ta.valuewhen(sellSeries >= zigThreshold and close < open and not na(sellSeries), low, 0)
highestAbs = ta.valuewhen(buySeries  >= zigThreshold and close > open and not na(buySeries), high, 0)

// === PLOT ABSORPTION LEVELS ===
plotLow  = plot(showAbsLevels ? lowestAbs  : na, color = lowestAbs != lowestAbs[1] ? na : #0df1c6, linewidth=1, linestyle=plot.linestyle_dashed)
plotHigh = plot(showAbsLevels ? highestAbs : na, color = highestAbs != highestAbs[1] ? na : #871ee9, linewidth=1, linestyle=plot.linestyle_dashed)

// === PLOT ABSORPTION INDEX MARKERS ===
sellIndexInt = math.round(sellSeries)
buyIndexInt  = math.round(buySeries)

// Manually write plotshape for each threshold without loops
plotshape(showAbsIndex and sellIndexInt == 1, style=shape.triangleup, text="1", color=color.new(#0df1c6, 0), textcolor=color.new(#0df1c6, 0), location=location.belowbar)
plotshape(showAbsIndex and sellIndexInt == 2, style=shape.triangleup, text="2", color=color.new(#0df1c6, 0), textcolor=color.new(#0df1c6, 0), location=location.belowbar)
plotshape(showAbsIndex and sellIndexInt == 3, style=shape.triangleup, text="3", color=color.new(#0df1c6, 0), textcolor=color.new(#0df1c6, 0), location=location.belowbar)
plotshape(showAbsIndex and sellIndexInt == 4, style=shape.triangleup, text="4", color=color.new(#0df1c6, 0), textcolor=color.new(#0df1c6, 0), location=location.belowbar)
plotshape(showAbsIndex and sellIndexInt == 5, style=shape.triangleup, text="5", color=color.new(#0df1c6, 0), textcolor=color.new(#0df1c6, 0), location=location.belowbar)
plotshape(showAbsIndex and sellIndexInt == 6, style=shape.triangleup, text="6", color=color.new(#0df1c6, 0), textcolor=color.new(#0df1c6, 0), location=location.belowbar)
plotshape(showAbsIndex and sellIndexInt == 7, style=shape.triangleup, text="7", color=color.new(#0df1c6, 0), textcolor=color.new(#0df1c6, 0), location=location.belowbar)

plotshape(showAbsIndex and buyIndexInt == 1, style=shape.triangledown, text="1", color=color.new(#871ee9, 0), textcolor=color.new(#871ee9, 0), location=location.abovebar)
plotshape(showAbsIndex and buyIndexInt == 2, style=shape.triangledown, text="2", color=color.new(#871ee9, 0), textcolor=color.new(#871ee9, 0), location=location.abovebar)
plotshape(showAbsIndex and buyIndexInt == 3, style=shape.triangledown, text="3", color=color.new(#871ee9, 0), textcolor=color.new(#871ee9, 0), location=location.abovebar)
plotshape(showAbsIndex and buyIndexInt == 4, style=shape.triangledown, text="4", color=color.new(#871ee9, 0), textcolor=color.new(#871ee9, 0), location=location.abovebar)
plotshape(showAbsIndex and buyIndexInt == 5, style=shape.triangledown, text="5", color=color.new(#871ee9, 0), textcolor=color.new(#871ee9, 0), location=location.abovebar)
plotshape(showAbsIndex and buyIndexInt == 6, style=shape.triangledown, text="6", color=color.new(#871ee9, 0), textcolor=color.new(#871ee9, 0), location=location.abovebar)
plotshape(showAbsIndex and buyIndexInt == 7, style=shape.triangledown, text="7", color=color.new(#871ee9, 0), textcolor=color.new(#871ee9, 0), location=location.abovebar)

// === CANDLE CONDITIONS ===
isSellAbs = sellSeries >= zigThreshold and close < open
isBuyAbs  = buySeries  >= zigThreshold and close > open

barcolor(isSellAbs ? color.new(#0df1c6, 0) : isBuyAbs ? color.new(#871ee9, 0) : na)

// === LAST BAR LABELS ===
isFinalBar = barstate.islast

var label lastBuyLabel  = na
var label lastSellLabel = na

if isFinalBar and not na(highestAbs) and showAbsLevels
    label.delete(lastBuyLabel)
    lastBuyLabel := label.new(bar_index, highestAbs, "", style=label.style_label_left, textcolor=color.white, color=color.new(#0df1c6, 60))

if isFinalBar and not na(lowestAbs) and showAbsLevels
    label.delete(lastSellLabel)
    lastSellLabel := label.new(bar_index, lowestAbs, "", style=label.style_label_left, textcolor=color.white, color=color.new(#871ee9, 60))

// Drawing Dashboard
var table_position = dashLoc == 'Bottom Left' ? position.bottom_left 
  : dashLoc == 'Top Right' ? position.top_right 
  : position.bottom_right

var table_size = textSize == 'Tiny' ? size.tiny 
  : textSize == 'Small' ? size.small 
  : size.normal

var tb = table.new(table_position, 8, 8
  , bgcolor = #1e222d
  , border_color = #373a46
  , border_width = 1
  , frame_color = #373a46
  , frame_width = 1)


if showDash
    if barstate.isfirst
        tb.cell(0, 0, "Imbalance Concept", text_color = color.white, text_size = table_size)
        tb.merge_cells(0,0,1,0)

    if barstate.islast
        // Volume Gap Status
        tb.cell(0, 4, "⚖️ Volume Gap", text_color=color.white, text_size=table_size)
        tb.cell(1, 4, volGap ? "YES" : "NO", text_color = volGap ? #0df1c6 : color.gray, text_size=table_size)

        // Volume Gap Status
        tb.cell(0, 5, "📊 Trend", text_color=color.white, text_size=table_size)
        tb.cell(1, 5, marketBias, text_color = marketBias == "BULLISH"?#0df1c6:#871ee9, text_size=table_size)
````
