# Dikshant Liquidity Voids & Market Imbalances

- url: https://www.tradingview.com/script/ekc312O3-Dikshant-Liquidity-Voids-Market-Imbalances/
- type: indicator
- pine_id: PUB;57230f67be3e4151b617bc614aa5eaf1
- version: 2.0

## Description

[image]https://www.tradingview.com/x/O24i5XsN/[/image][b]Overview[/b]
In modern market micro-structure, price moves through alternating phases of balance and imbalance. This open-source script is a highly optimized, dual-engine technical tool designed to identify, map, and track institutional liquidity anomalies in real time.

By calculating structural inefficiencies like Fair Value Gaps (FVG) and Value Gaps (2-bar closing anomalies), this indicator highlights hidden support and resistance zones where institutional algorithms are likely to re-engage with the market.

Whether you trade ICT, SMC, or pure price action, this script acts as a lens for viewing market inefficiency and order flow mitigation.

[b]Core Features[/b]
🚀 Dual Architecture Detection: Simultaneously tracks 3-bar Fair Value Gaps (FVGs) and 2-bar Closing Value Gaps across historical data.

📊 Live Terminal Dashboard: An elegant, real-time analytics grid summarizing structural metrics, total count of imbalances, and the statistical percentage of zone mitigation.

🔄 Adaptive Volatility Filter: Toggle on adaptive sizing to calculate a dynamic threshold based on cumulative historical volatility, filtering out market noise during low-liquidity sessions.

💡 Fluid Profiling vs. Static Boundaries: Choose between static historical zones (drawn via boxes) or fluid, real-time price profiles that shift dynamically as price tests the imbalance boundaries.

🎯 Breach Tracking Engine: Automatically drops a secondary dashed level precisely at the coordinate where an imbalance zone was invalidated or mitigated.

How It Works (The Logic)
The indicator breaks down market imbalances into two major structures:

1. Structural Imbalances (Fair Value Gaps)
Occurs across a 3-bar sequence where a rapid expansion leaves a market vacuum.

Bullish Imbalance: The low of Bar 3 is entirely higher than the high of Bar 1.

Bearish Imbalance: The high of Bar 3 is entirely lower than the low of Bar 1.

2. Structural Value Gaps
Occurs when a gap opens up between the close of the previous candle and the extremum of the current candle, independent of a 3-bar sequence.

Bullish Value Gap: The current bar's low is completely above the prior bar's close.

Bearish Value Gap: The current bar's high is completely below the prior bar's close.

User Inputs & Adjustments
Spread Threshold %: Set a minimum percentage size relative to price for a gap to be drawn. Perfect for filtering out tiny, insignificant gaps.

Analysis Horizon (Timeframe): Allows you to anchor multi-timeframe analysis (MTF) onto your current chart seamlessly.

Max Active Lines Shown: Limits the structural display to only show the most recent N unmitigated levels, keeping your charts exceptionally clean.

Trading Applications & Practical Examples
Example 1: Institutional Re-entry (Order Block / FVG Confluence)
Scenario: Price aggressively breaks market structure to the upside, leaving behind a thick Long Sentiment Zone (Bullish FVG).

Execution: Instead of chasing the breakout, wait for a mean-reversion pullback. Place a limit order near the upper boundary of the highlighted box. Use the lower boundary of the zone as an invalidation reference for structural risk management (stop loss).

Example 2: Trapped Liquidity & Zone Breach
Scenario: A Short Sentiment Zone (Bearish FVG) forms during a markdown phase. However, price returns and completely aggressively closes above the upper boundary.

Execution: The dashboard will log this as a "Mitigated" event, and if enabled, a dashed Breach Line will be drawn. This acts as a clear signal that order flow has shifted from bearish to bullish, turning a failed resistance into a fresh propulsion zone.

Example 3: Scalping with Multi-Timeframe Horizons
Scenario: You are executing intraday scalps on a 1-Minute chart.

Execution: Change the Analysis Horizon input to 5m or 15m. The script will project higher-timeframe algorithmic imbalances right onto your execution chart, keeping you aligned with macro institutional flow.

[b]Disclaimer[/b]
Imbalances represent areas where price moved too quickly for the market to facilitate balanced trade. While they are highly reliable magnets for price action, they should always be coupled with volume profiling, trend structures, or mechanical confirmations. Always practice proper risk mitigation.

## Source Code

````pine
//@version=5
indicator("Liquidity Voids & Market Imbalances", "Voids & Imbalances", overlay = true, max_lines_count = 500, max_boxes_count = 500)

//-----------------------------------------------------------------------------
// Configurations & User Interface
//-----------------------------------------------------------------------------
var string G_FILTER  = "Detection Filters"
var string G_VISUALS = "Visual Styling"
var string G_METRICS = "Metrics Dashboard"

minSpreadPct = input.float(0.0, "Spread Threshold %", minval = 0.0, maxval = 100.0, step = 0.1, inline = 'thresh', group = G_FILTER)
useAdaptive  = input.bool(false, "Adaptive Sizing", inline = 'thresh', group = G_FILTER)

displayLimit  = input.int(0, 'Max Active Lines Shown', minval = 0, group = G_FILTER)
trackBreaches = input.bool(false, 'Render Breach Coordinates', group = G_FILTER)

chartPeriod   = input.timeframe('', "Analysis Horizon", group = G_FILTER)

// Mode Visibility Toggles
plotLongFvg  = input.bool(true, "Track Long FVGs", group = G_FILTER)
plotLongGap  = input.bool(true, "Track Long Value Gaps", group = G_FILTER)
plotShortFvg = input.bool(true, "Track Short FVGs", group = G_FILTER)
plotShortGap = input.bool(true, "Track Short Value Gaps", group = G_FILTER)

// Architectural Rendering Options
projectionWidth = input.int(20, 'Box Expansion Length', minval = 0, inline = 'render', group = G_VISUALS)
isFluid         = input.bool(false, 'Fluid Profiles', inline = 'render', group = G_VISUALS)

// Distinct Color Assignments
c_fvgLong = input.color(color.new(#00e676, 75), "FVG Long Color", group = G_VISUALS)
c_gapLong = input.color(color.new(#00b0ff, 75), "Gap Long Color", group = G_VISUALS)
c_fvgShort = input.color(color.new(#ff5252, 75), "FVG Short Color", group = G_VISUALS)
c_gapShort = input.color(color.new(#e040fb, 75), "Gap Short Color", group = G_VISUALS)

// Metrics Terminal Settings
renderTerminal   = input.bool(false, 'Display Metrics Terminal', group = G_METRICS)
terminalPosition = input.string('Top Right', 'Screen Alignment', options = ['Top Right', 'Bottom Right', 'Bottom Left'], group = G_METRICS)
terminalScale    = input.string('Small', 'Interface Scale', options = ['Tiny', 'Small', 'Normal'], group = G_METRICS)

//-----------------------------------------------------------------------------
// Objects & Data Blueprints
//-----------------------------------------------------------------------------
type VoidStructure
    float upperBoundary
    float lowerBoundary
    bool  isBullish
    int   structureType // 1 = FVG, 2 = Gap
    int   creationTime = time
    int   displacementBars 

//-----------------------------------------------------------------------------
// Computational Kernel Functions
//-----------------------------------------------------------------------------
currentBarIndex = bar_index

method extractPureColor(color targetColor) => 
    color.rgb(color.r(targetColor), color.g(targetColor), color.b(targetColor))

evaluateMarketAnomaly(bool allowLongFvg, bool allowLongGap, bool allowShortFvg, bool allowShortGap) =>
    var VoidStructure dataPacket = VoidStructure.new(na, na, na, na, na, na)
    dynamicThreshold = useAdaptive ? ta.cum((high - low) / low) / bar_index : minSpreadPct / 100.0

    // Core Discrepancy Formulations
    longImbalance  = allowLongFvg and (low > high[2] and close[1] > high[2] and (low - high[2]) / high[2] > dynamicThreshold)
    shortImbalance = allowShortFvg and (high < low[2] and close[1] < low[2] and (low[2] - high) / high > dynamicThreshold)
    
    longGapState   = allowLongGap and (low > close[1] and (low - close[1]) / close[1] > dynamicThreshold and not (low > high[2] and close[1] > high[2]))
    shortGapState  = allowShortGap and (high < close[1] and (close[1] - high) / close[1] > dynamicThreshold and not (high < low[2] and close[1] < low[2]))
    
    isValidLong  = longImbalance or longGapState
    isValidShort = shortImbalance or shortGapState

    if isValidLong
        float ceilValue  = low
        float floorValue = longImbalance ? high[2] : close[1]
        int offsetBars   = longImbalance ? 2 : 1
        int sType        = longImbalance ? 1 : 2
        dataPacket      := VoidStructure.new(ceilValue, floorValue, true, sType, time, offsetBars)
    else if isValidShort
        float ceilValue  = shortImbalance ? low[2] : close[1]
        float floorValue = high
        int offsetBars   = shortImbalance ? 2 : 1
        int sType        = shortImbalance ? 1 : 2
        dataPacket      := VoidStructure.new(ceilValue, floorValue, false, sType, time, offsetBars)

    [isValidLong, isValidShort, dataPacket]

//-----------------------------------------------------------------------------
// Main Sequence Execution & Array Architecture
//-----------------------------------------------------------------------------
var float activeLongCeil = na, var float activeLongFloor = na, var totalLongCount = 0, var mitigatedLongCount = 0
var float activeShortCeil = na, var float activeShortFloor = na, var totalShortCount = 0, var mitigatedShortCount = 0
var lastProcessedTime = 0
var color activeLongColor = na
var color activeShortColor = na

var historicalRecords = array.new<VoidStructure>(0)
var visualZoneBoxes   = array.new<box>(0)

[longTriggered, shortTriggered, rawPacket] = request.security(syminfo.tickerid, chartPeriod, evaluateMarketAnomaly(plotLongFvg, plotLongGap, plotShortFvg, plotShortGap))

// Long Position Anomalies Processing
if longTriggered and rawPacket.creationTime != lastProcessedTime
    activeLongColor := rawPacket.structureType == 1 ? c_fvgLong : c_gapLong
    if isFluid
        activeLongCeil  := rawPacket.upperBoundary
        activeLongFloor := rawPacket.lowerBoundary
    
    if not isFluid
        visualZoneBoxes.unshift(box.new(currentBarIndex - rawPacket.displacementBars, rawPacket.upperBoundary, currentBarIndex + projectionWidth, rawPacket.lowerBoundary, na, bgcolor = activeLongColor))
    historicalRecords.unshift(rawPacket)

    totalLongCount    += 1
    lastProcessedTime := rawPacket.creationTime
else if isFluid
    activeLongCeil := math.max(math.min(close, activeLongCeil), activeLongFloor)

// Short Position Anomalies Processing
if shortTriggered and rawPacket.creationTime != lastProcessedTime
    activeShortColor := rawPacket.structureType == 1 ? c_fvgShort : c_gapShort
    if isFluid
        activeShortCeil  := rawPacket.upperBoundary
        activeShortFloor := rawPacket.lowerBoundary
    
    if not isFluid
        visualZoneBoxes.unshift(box.new(currentBarIndex - rawPacket.displacementBars, rawPacket.upperBoundary, currentBarIndex + projectionWidth, rawPacket.lowerBoundary, na, bgcolor = activeShortColor))
    historicalRecords.unshift(rawPacket)

    totalShortCount   += 1
    lastProcessedTime := rawPacket.creationTime
else if isFluid
    activeShortFloor := math.min(math.max(close, activeShortFloor), activeShortCeil) 

//-----------------------------------------------------------------------------
// Mitigation Realization & Processing Engines
//-----------------------------------------------------------------------------
if historicalRecords.size() > 0
    for pointer = historicalRecords.size() - 1 to 0
        node = historicalRecords.get(pointer)
        color renderColor = node.isBullish ? (node.structureType == 1 ? c_fvgLong : c_gapLong) : (node.structureType == 1 ? c_fvgShort : c_gapShort)

        if node.isBullish
            if close < node.lowerBoundary
                if trackBreaches
                    line.new(node.creationTime, node.lowerBoundary, time, node.lowerBoundary, xloc.bar_time, color = renderColor, style = line.style_dashed)

                if not isFluid
                    boxItem = visualZoneBoxes.remove(pointer)
                    boxItem.delete()

                historicalRecords.remove(pointer)
                mitigatedLongCount += 1
        else
            if close > node.upperBoundary
                if trackBreaches
                    line.new(node.creationTime, node.upperBoundary, time, node.upperBoundary, xloc.bar_time, color = renderColor, style = line.style_dashed)

                if not isFluid
                    boxItem = visualZoneBoxes.remove(pointer)
                    boxItem.delete()
                
                historicalRecords.remove(pointer)
                mitigatedShortCount += 1

// Terminal Projections Calculations
var terminalProjections = array.new<line>(0)

if barstate.islast and displayLimit > 0 and historicalRecords.size() > 0
    if terminalProjections.size() > 0 
        for entity in terminalProjections
            entity.delete()
        terminalProjections.clear()

    for idx = 0 to math.min(displayLimit - 1, historicalRecords.size() - 1)
        targetNode = historicalRecords.get(idx)
        boundaryCoordinate = targetNode.isBullish ? targetNode.lowerBoundary : targetNode.upperBoundary
        color lineColor = targetNode.isBullish ? (targetNode.structureType == 1 ? c_fvgLong : c_gapLong) : (targetNode.structureType == 1 ? c_fvgShort : c_gapShort)

        terminalProjections.push(line.new(targetNode.creationTime, boundaryCoordinate, time, boundaryCoordinate, xloc.bar_time, color = lineColor))

//-----------------------------------------------------------------------------
// Terminal Dashboard Grid Construction
//-----------------------------------------------------------------------------
gridAlignment = terminalPosition == 'Bottom Left' ? position.bottom_left : terminalPosition == 'Top Right' ? position.top_right : position.bottom_right
gridScale     = terminalScale == 'Tiny' ? size.tiny : terminalScale == 'Small' ? size.small : size.normal

var table dataTerminal = table.new(gridAlignment, 3, 3, bgcolor = #11141c, border_color = #2a2e39, border_width = 1, frame_color = #2a2e39, frame_width = 1)

if renderTerminal
    if barstate.isfirst
        dataTerminal.cell(1, 0, 'Long Side', text_color = c_fvgLong.extractPureColor(), text_size = gridScale)
        dataTerminal.cell(2, 0, 'Short Side', text_color = c_fvgShort.extractPureColor(), text_size = gridScale)
    
        dataTerminal.cell(0, 1, 'Total Base', text_size = gridScale, text_color = color.white)
        dataTerminal.cell(0, 2, 'Mitigated', text_size = gridScale, text_color = color.white)
    
    if barstate.islast
        dataTerminal.cell(1, 1, str.tostring(totalLongCount), text_color = c_fvgLong.extractPureColor(), text_size = gridScale)
        dataTerminal.cell(2, 1, str.tostring(totalShortCount), text_color = c_fvgShort.extractPureColor(), text_size = gridScale)
        
        longMitigationRate  = totalLongCount > 0 ? str.tostring(mitigatedLongCount / totalLongCount * 100, format.percent) : "0%"
        shortMitigationRate = totalShortCount > 0 ? str.tostring(mitigatedShortCount / totalShortCount * 100, format.percent) : "0%"
        
        dataTerminal.cell(1, 2, longMitigationRate, text_color = c_fvgLong.extractPureColor(), text_size = gridScale)
        dataTerminal.cell(2, 2, shortMitigationRate, text_color = c_fvgShort.extractPureColor(), text_size = gridScale)

//-----------------------------------------------------------------------------
// Visual Rendering Projections (Fluid Mode)
//-----------------------------------------------------------------------------
upperLongPlot = plot(activeLongCeil, color = na)
lowerLongPlot = plot(activeLongFloor, color = na)
fill(upperLongPlot, lowerLongPlot, color = activeLongColor)

upperShortPlot = plot(activeShortCeil, color = na)
lowerShortPlot = plot(activeShortFloor, color = na) 
fill(upperShortPlot, lowerShortPlot, color = activeShortColor)
````
