# Friction Heatmap & Vacuum Zones [ZOM]

- url: https://www.tradingview.com/script/FWHpaWwv-Friction-Heatmap-Vacuum-Zones-ZOM/
- type: indicator
- pine_id: PUB;ac080c36adbd4778be1998cc26943efc
- version: 1.0

## Description

Markets do not move through price evenly.

Some areas act like very dense with heavy resistance, while others like low-friction vacuum zones where price can accelerate rapidly.

This indicator models those regions using [b]time-weighted volume interaction density[/b] to [i]estimate[/i] market friction and visualize traversable paths.

[b]Features:[/b]
• Time-decay weighted friction calculations
• Volume-adjusted heatmap
• Vacuum zone detection
• Friction-adjusted risk/reward engine
• ATR-based targeting
• Dynamic path efficiency dashboard
• Multiple heatmap visualization modes

[b]It is simple:[/b]

[b]High-friction zones[/b] [i]may[/i] slow or reject price.
[b]Low-friction zones[/b] [i]may[/i] allow price to move quickly.

The script attempts to visualize those areas using historical interaction density and volume distribution. TradingView does not provide true order book or full market depth data to Pine scripts. So, because of this, the friction modeling is estimated using [b]historical price interaction[/b] and [b]volume distribution[/b] rather than direct liquidity data. Therefore, this tool [b]should be viewed as a contextual framework rather than a predictive system! [/b]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ZOM
//-------------------------------------------------------------------------------------------------
// Friction Heatmap & Vacuum Zones [ZOM]
// © ZenOutMan
//
// Concept:
// Models market "friction" using volume distribution and time-weighted interaction density.
// Highlights high-friction barriers and low-friction vacuum zones where price may accelerate.
//
// Features:
// • Time-decay weighted friction modeling
// • Volume-adjusted heatmap visualization
// • Vacuum zone detection
// • Friction-adjusted R:R calculations
// • ATR or manual trade targeting
//
// Educational tool only. Not financial advice.
//-------------------------------------------------------------------------------------------------
//@version=6
indicator("Friction Heatmap & Vacuum Zones [ZOM]", shorttitle = "Friction R:R ", overlay = true, max_boxes_count = 100, max_lines_count = 100)

string T_GENERAL = "Friction V2: Now featuring Time-Decay and Vacuum Detection.\n\nFriction is now weighted by time (fresher volume matters more) and the heatmap identifies 'Vacuum Zones' where price is likely to accelerate."
string T_DECAY   = "TIME DECAY:\n\nWhen enabled, volume from recent bars has a higher impact on friction than volume from the start of the lookback period. This reflects current market relevance."
string T_VACUUM  = "VACUUM ZONES:\n\nZones with exceptionally low volume/friction are highlighted. Price often 'slips' through these areas quickly, making them ideal 'traversable' paths for your target."
string T_AUTO    = "AUTO-PLACEMENT:\n\nAutomatically sets your target and stop based on ATR, then adjusts them to the nearest High Friction nodes to optimize your R:R."

color BULL_COLOR      = #089981
color BEAR_COLOR      = #f23645
color NEUTRAL_COLOR   = #5b9cf6
color VACUUM_COLOR    = color.new(#fbc02d, 50) // Golden yellow for gaps
color FRICTION_COLOR  = color.new(chart.fg_color, 70)

string G_CALC         = "Core Calculation"
bool useVolume        = input.bool(true, "Use Volume Weighting", group = G_CALC)
bool useTimeDecay     = input.bool(true, "Apply Time Decay", group = G_CALC, tooltip = T_DECAY)
int lookback          = input.int(200, "Lookback Period", minval = 50, group = G_CALC)
int zoneCount         = input.int(50, "Heatmap Granularity", minval = 10, maxval = 100, group = G_CALC)

string G_TRADE        = "Trade Setup"
string tradeMode      = input.string("Manual Ticks", "Target/Stop Mode", options = ["Manual Ticks", "ATR Based"], group = G_TRADE)
float targetMult      = input.float(2.0, "Target Multiplier (ATR/Ticks)", minval = 0.1, group = G_TRADE)
float stopMult        = input.float(1.0, "Stop Multiplier (ATR/Ticks)", minval = 0.1, group = G_TRADE)
string tradeType      = input.string("Long", "Trade Direction", options = ["Long", "Short"], group = G_TRADE)

string G_VIS          = "Refined Visuals"
string heatmapStyle   = input.string("Blocks", "Heatmap Format", options = ["Blocks", "Dynamic Width", "Minimalist"], group = G_VIS)
bool showVacuums      = input.bool(true, "Highlight Vacuum Zones", group = G_VIS, tooltip = T_VACUUM)
int heatmapOffset     = input.int(15, "Heatmap Offset (Bars)", minval = 5, group = G_VIS)
int heatmapWidth      = input.int(20, "Heatmap Width (Bars)", minval = 5, group = G_VIS)

float atr = ta.atr(14)

float sessionHigh = ta.highest(lookback)
float sessionLow  = ta.lowest(lookback)
float priceRange  = sessionHigh - sessionLow
float zoneSize    = priceRange / zoneCount

float[] frictionValues = array.new_float(zoneCount, 0.0)

if barstate.islast
    if useVolume
        for i = 0 to lookback - 1
            float bH = high[i]
            float bL = low[i]
            float bV = nz(volume[i])
            
            float decayFactor = useTimeDecay ? (1.0 - (float(i) / lookback) * 0.9) : 1.0
            float weightedVol = bV * decayFactor
            
            int startZone = int(math.max(0, math.min(zoneCount - 1, math.floor((bL - sessionLow) / zoneSize))))
            int endZone   = int(math.max(0, math.min(zoneCount - 1, math.floor((bH - sessionLow) / zoneSize))))
            int span      = math.max(1, endZone - startZone + 1)
            float volPerZone = weightedVol / span
            
            for j = startZone to endZone
                array.set(frictionValues, j, array.get(frictionValues, j) + volPerZone)
    else
        for i = 0 to lookback - 1
            float bH = high[i]
            float bL = low[i]
            float decayFactor = useTimeDecay ? (1.0 - (float(i) / lookback) * 0.9) : 1.0
            int startZone = int(math.max(0, math.min(zoneCount - 1, math.floor((bL - sessionLow) / zoneSize))))
            int endZone   = int(math.max(0, math.min(zoneCount - 1, math.floor((bH - sessionLow) / zoneSize))))
            for j = startZone to endZone
                array.set(frictionValues, j, array.get(frictionValues, j) + decayFactor)

float currentPrice = close
float tDist = tradeMode == "ATR Based" ? atr * targetMult : targetMult * syminfo.mintick
float sDist = tradeMode == "ATR Based" ? atr * stopMult : stopMult * syminfo.mintick

float targetPrice  = tradeType == "Long" ? currentPrice + tDist : currentPrice - tDist
float stopPrice    = tradeType == "Long" ? currentPrice - sDist : currentPrice + sDist

float rewardFriction = 0.0
float riskFriction   = 0.0
float uB = math.max(currentPrice, targetPrice)
float lB = math.min(currentPrice, targetPrice)
float sU = math.max(currentPrice, stopPrice)
float sL = math.min(currentPrice, stopPrice)

if barstate.islast
    for i = 0 to zoneCount - 1
        float zMid = sessionLow + (i * zoneSize) + (zoneSize / 2)
        float fVal = array.get(frictionValues, i)
        if zMid >= lB and zMid <= uB
            rewardFriction += fVal
        if zMid >= sL and zMid <= sU
            riskFriction += fVal

float avgFriction = array.size(frictionValues) > 0 ? array.avg(frictionValues) : 1.0
float rwSens = rewardFriction / math.max(avgFriction * (tDist/zoneSize), 1.0)
float rkSens = riskFriction / math.max(avgFriction * (sDist/zoneSize), 1.0)

float frictionWeight = 0.15
float adjReward = tDist / (1 + (rwSens * frictionWeight))
float adjRisk   = sDist / (1 + (rkSens * frictionWeight))
float adjRR     = adjReward / math.max(adjRisk, 0.1)
float rawRR     = tDist / sDist

var boxes = array.new_box(0)
if barstate.islast
    if array.size(boxes) > 0
        for b in boxes
            box.delete(b)
        array.clear(boxes)

    float maxFriction = array.max(frictionValues)
    float minFriction = array.min(frictionValues)
    float threshold   = array.avg(frictionValues) * 0.2 // Threshold for "Vacuum"

    for i = 0 to zoneCount - 1
        float val = array.get(frictionValues, i)
        float zB  = sessionLow + (i * zoneSize)
        float zT  = zB + zoneSize
        
        bool isVacuum = showVacuums and val < threshold and val > 0
        
        if val > 0
            float intensity = val / math.max(maxFriction, 1e-9)
            int alpha       = 100 - int(intensity * 85)
            color zColor    = isVacuum ? VACUUM_COLOR : color.new(FRICTION_COLOR, alpha)
            
            int leftPos  = bar_index + heatmapOffset
            int rightPos = bar_index + heatmapOffset + heatmapWidth
            
            if heatmapStyle == "Dynamic Width"
                rightPos := bar_index + heatmapOffset + int(heatmapWidth * intensity)
            else if heatmapStyle == "Minimalist"
                zB := (zB + zT) / 2 - (zoneSize * 0.1)
                zT := zB + (zoneSize * 0.2)
            
            array.push(boxes, box.new(leftPos, zT, rightPos, zB, border_color = color.new(chart.fg_color, 100), bgcolor = zColor))

var table display = table.new(position.top_right, 2, 5, border_width = 1, frame_color = chart.fg_color, border_color = chart.fg_color)
if barstate.islast
    table.cell(display, 0, 0, "Friction Dashboard", bgcolor = color.new(chart.fg_color, 85), text_color = chart.fg_color)
    table.cell(display, 1, 0, useTimeDecay ? "Decay: ON" : "Decay: OFF", bgcolor = color.new(chart.fg_color, 85), text_color = chart.fg_color)
    
    table.cell(display, 0, 1, "Raw R:R", text_color = chart.fg_color)
    table.cell(display, 1, 1, str.tostring(rawRR, "#.##"), text_color = chart.fg_color)
    
    color rrColor = adjRR > rawRR ? BULL_COLOR : BEAR_COLOR
    table.cell(display, 0, 2, "Adj R:R", text_color = rrColor)
    table.cell(display, 1, 2, str.tostring(adjRR, "#.##"), bgcolor = color.new(rrColor, 90), text_color = rrColor)
    
    float pathEfficiency = (adjRR / rawRR) * 100
    table.cell(display, 0, 3, "Efficiency", text_color = chart.fg_color)
    table.cell(display, 1, 3, str.tostring(pathEfficiency, "#") + "%", text_color = chart.fg_color)

    table.cell(display, 0, 4, "Status", text_color = rrColor)
    table.cell(display, 1, 4, adjRR > rawRR ? "Optimal Path" : "Obstacles Detected", text_color = rrColor)

var line targetLine = line.new(na, na, na, na, color = BULL_COLOR, width = 1, style = line.style_dashed)
var line stopLine   = line.new(na, na, na, na, color = BEAR_COLOR, width = 1, style = line.style_dashed)
var label targetLbl = label.new(na, na, "", color = #00000000, textcolor = BULL_COLOR, style = label.style_label_left, size = size.small)
var label stopLbl   = label.new(na, na, "", color = #00000000, textcolor = BEAR_COLOR, style = label.style_label_left, size = size.small)

if barstate.islast
    line.set_xy1(targetLine, bar_index, targetPrice)
    line.set_xy2(targetLine, bar_index + heatmapOffset + heatmapWidth, targetPrice)
    line.set_xy1(stopLine, bar_index, stopPrice)
    line.set_xy2(stopLine, bar_index + heatmapOffset + heatmapWidth, stopPrice)
    
    label.set_xy(targetLbl, bar_index + heatmapOffset + heatmapWidth, targetPrice)
    label.set_text(targetLbl, "Target (Adj: " + str.tostring(adjReward/syminfo.mintick, "#") + " ticks)")
    label.set_xy(stopLbl, bar_index + heatmapOffset + heatmapWidth, stopPrice)
    label.set_text(stopLbl, "Stop (Adj: " + str.tostring(adjRisk/syminfo.mintick, "#") + " ticks)")

bool xUp = adjRR > rawRR and adjRR[1] <= rawRR[1]
alertcondition(xUp, "Path Efficiency High", "Your friction-adjusted R:R has become favorable!")
````
