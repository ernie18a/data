# Base Pivots

- url: https://www.tradingview.com/script/QUssAVao-Base-Pivots/
- type: indicator
- pine_id: PUB;8dcbe09347834a7e89f590846fe047a1
- version: 4.0

## Description

OverviewThis indicator identifies major structural support and resistance levels based on pivot highs and lows, drawing clean, contained horizontal levels that step forward dynamically with price. Instead of running into infinite space, lines map directly to price action and freeze the exact moment a breakout threshold is breached.

To help filter out market noise and minor price fluctuations, it integrates a multi-layered verification system, ensuring only significant market turning points are displayed on your chart.

Key FeaturesPre-Pivot Trend Filter: Validates structural turning points by requiring price to make a meaningful percentage move over a chosen lookback window before a pivot line can form.

Contained Real-Time Extensions: Unbroken lines trail cleanly up to the current bar. The exact moment a breakout occurs, the line freezes and terminates strictly at that breach bar.

Dual-Mode Breakout Thresholds: Choose between a fixed Percentage breakout or a volatility-adjusted ADR/ATR Multiple to determine precisely when a support or resistance level is considered broken.

Clean Chart Proximity Merging: Automatically prevents cluttered charts by filtering out and merging new lines that form too close to already active levels.

Independent State Visibility: Includes fully flexible visibility toggles to selectively display active support, active resistance, broken support, or broken resistance lines.

Dynamic Information Labels: Displays the precise price level, how many chart bars the level has survived, and the maximum adverse excursion (depth percentage) reached during the line's lifespan

How It Works (Under the Hood)

Detection: The script scans historical price data using a user-defined left/right strength lookback window to isolate pivot wicks.

Pre-Trend Check: It assesses the trend run-up or run-down leading to the pivot. If the move is less than the user-configured percentage, the pivot is completely ignored.

Tracking & Breakdown Loops: Validated lines are stored in real-time array structures. On each bar, it computes volatility metrics. If a candle closes past the boundary (plus your ATR or percentage cushion), the level converts into a historical broken state instantly.


User Inputs Guide

Lookback: Distance needed to confirm a high or low peak.

Pre-Pivot Change Threshold (%): Minimum percentage run required prior to validation.

Max Active Lines: Limits the total number of unbreached lines drawn on your screen.

Style Toggles: Fully customize line styles (Solid/Dotted/Dashed), font sizing, visual offsets, and visibility blocks for broken versus active states.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org
// © starshiptrade

//@version=6
indicator("Base Pivots", overlay=true, max_lines_count=500, max_labels_count=500)

// ==========================================
// --- INPUT PARAMETERS GROUP (SETTINGS) ---
// ==========================================
lookbackLen    = input.int(15, title="Lookback", minval=1, group="SETTINGS")
breakType      = input.string("ADR/ATR Multiple", title="Breakout Threshold", options=["Percent", "ADR/ATR Multiple"], group="SETTINGS")
mergePct       = input.float(5.5, title="Merge Within %", minval=0.0, group="SETTINGS")
breakPct       = input.float(5.0, title="Breakout %", minval=0.0, group="SETTINGS")
adrLookback    = input.int(20, title="ADR/ATR Lookback", minval=1, group="SETTINGS")
adrMultiplier  = input.float(2.0, title="ADR/ATR Multiplier", minval=0.0, group="SETTINGS")

// Restored: Pre-Pivot trend validation criteria inputs
pctThreshold   = input.float(30.0, title="Pre-Pivot Change Threshold (%)", minval=0.0, group="SETTINGS", tooltip="Price must move by this % before the pivot to validate it")
preTrendBars   = input.int(30, title="Pre-Trend Lookback Window (Bars)", minval=5, group="SETTINGS", tooltip="How far back to look for the preceding high/low trend to calculate the % change")

// Enforces structural clean lines across the chart
maxHighLines   = input.int(5, title="Max Active Resistance Lines", minval=1, group="SETTINGS")
maxLowLines    = input.int(3, title="Max Active Support Lines", minval=1, group="SETTINGS")

// ==========================================
// --- STYLE INPUTS GROUP (WITH TOGGLES) ---
// ==========================================
showActiveRes  = input.bool(true, title="Show Active Resistance Lines", group="STYLE")
showBrokenRes  = input.bool(true, title="Show Broken Resistance Lines", group="STYLE")
showActiveSup  = input.bool(true, title="Show Active Support Lines", group="STYLE")
showBrokenSup  = input.bool(true, title="Show Broken Support Lines", group="STYLE")

colorHigh      = input.color(color.new(#E67E22, 0), title="Resistance Line Color (Orange)", group="STYLE")
colorLow       = input.color(color.new(#3498DB, 0), title="Support Line Color (Blue)", group="STYLE")
lineWidth      = input.int(2, title="Line Width", minval=1, group="STYLE")
lineStyleInput = input.string("Solid", title="Line Style", options=["Solid", "Dotted", "Dashed"], group="STYLE")

showBaseStats  = input.bool(true, title="Show Base Stats", group="STYLE")
showPriceLevel = input.bool(true, title="Show Price Level", group="STYLE")
labelPosInput  = input.string("Auto (Visual Split)", title="Label Position", options=["Auto (Visual Split)", "Above", "Below"], group="STYLE")
labelSizeInput = input.string("Normal", title="Label Font Size", options=["Small", "Normal", "Large"], group="STYLE")
textColor      = input.color(color.black, title="Label Font Color", group="STYLE")

// --- Parse User Input Selections to Pine Built-ins ---
getLineStyle(strStyle) =>
    strStyle == "Solid" ? line.style_solid : strStyle == "Dotted" ? line.style_dotted : line.style_dashed

getLabelStyle(strPos, isHigh) =>
    if strPos == "Auto (Visual Split)"
        isHigh ? label.style_label_lower_left : label.style_label_upper_left
    else if strPos == "Above"
        label.style_label_lower_left
    else
        label.style_label_upper_left

getFontSize(strSize) =>
    strSize == "Small" ? size.small : strSize == "Large" ? size.large : size.normal

// --- Volatility Calculations ---
atrValue       = ta.atr(adrLookback)
breakDistance  = breakType == "Percent" ? 0.0 : (atrValue * adrMultiplier)

// --- Detect Raw Pivot Points ---
rawPivotH = ta.pivothigh(high, lookbackLen, lookbackLen)
rawPivotL = ta.pivotlow(low, lookbackLen, lookbackLen)

// --- Custom Tracking Object ---
type PivotLine
    line   ln
    label  lbl
    float  price
    int    startBar
    float  maxDepthPrice

// Persistent storage arrays across execution bars
var PivotLine[] activeHighs = array.new<PivotLine>()
var PivotLine[] activeLows  = array.new<PivotLine>()
var PivotLine[] brokenHighs = array.new<PivotLine>()
var PivotLine[] brokenLows  = array.new<PivotLine>()

// --- Formatter Helper Function for Labels ---
getLabelText(float price, int startBar, int currentBar, float depthPrice) =>
    int barDiff   = currentBar - startBar
    float pctDev  = math.abs((price - depthPrice) / price) * 100
    
    strPrice      = showPriceLevel ? str.tostring(price, "#.00") : ""
    strStats      = showBaseStats ? str.tostring(barDiff) + " Bars  ·  " + str.tostring(pctDev, "#") + "%" : ""
    
    if showPriceLevel and showBaseStats
        strPrice + "  ·  " + strStats
    else if showPriceLevel
        strPrice
    else if showBaseStats
        strStats
    else
        ""

// --- Helper to Check Merging Nearness ---
isTooClose(float newPrice, PivotLine[] activeArray) =>
    bool closeFound = false
    if array.size(activeArray) > 0
        for i = 0 to array.size(activeArray) - 1
            PivotLine pl = array.get(activeArray, i)
            float diff   = math.abs((newPrice - pl.price) / pl.price) * 100
            if diff <= mergePct
                closeFound := true
                break
    closeFound

// --- Handle New High Pivots ---
if not na(rawPivotH) and not isTooClose(rawPivotH, activeHighs)
    int actualPivotBar = bar_index - lookbackLen
    
    // Validate trend on the left side before creation: Find the lowest low preceding the peak
    float lowestPreceding = ta.lowest(low, preTrendBars)[lookbackLen + 1]
    float preTrendMovePct = ((rawPivotH - lowestPreceding) / lowestPreceding) * 100
    
    if preTrendMovePct >= pctThreshold
        // Clear out active array space according to user parameters
        if array.size(activeHighs) >= maxHighLines
            while array.size(activeHighs) >= maxHighLines
                PivotLine oldest = array.shift(activeHighs)
                line.delete(oldest.ln)
                label.delete(oldest.lbl)
                
        // Determine visibility color state
        color currentLineColor  = showActiveRes ? colorHigh : color.new(colorHigh, 100)
        color currentTextColor  = showActiveRes ? textColor : color.new(textColor, 100)
                
        newLine = line.new(x1=actualPivotBar, y1=rawPivotH, x2=bar_index, y2=rawPivotH, color=currentLineColor, width=lineWidth, style=getLineStyle(lineStyleInput), extend=extend.none)
        labelText = getLabelText(rawPivotH, actualPivotBar, bar_index, low)
        newLabel = label.new(x=actualPivotBar, y=rawPivotH, text=labelText, color=color.new(color.white, 100), textcolor=currentTextColor, style=getLabelStyle(labelPosInput, true), size=getFontSize(labelSizeInput))
        
        if not showPriceLevel and not showBaseStats
            label.delete(newLabel)
            
        array.push(activeHighs, PivotLine.new(newLine, newLabel, rawPivotH, actualPivotBar, low))

// --- Handle New Low Pivots ---
if not na(rawPivotL) and not isTooClose(rawPivotL, activeLows)
    int actualPivotBar = bar_index - lookbackLen
    
    // Validate trend on the left side before creation: Find the highest high preceding the trough
    float highestPreceding = ta.highest(high, preTrendBars)[lookbackLen + 1]
    float preTrendMovePct = ((highestPreceding - rawPivotL) / highestPreceding) * 100
    
    if preTrendMovePct >= pctThreshold
        if array.size(activeLows) >= maxLowLines
            while array.size(activeLows) >= maxLowLines
                PivotLine oldest = array.shift(activeLows)
                line.delete(oldest.ln)
                label.delete(oldest.lbl)
                
        // Determine visibility color state
        color currentLineColor  = showActiveSup ? colorLow : color.new(colorLow, 100)
        color currentTextColor  = showActiveSup ? textColor : color.new(textColor, 100)
                
        newLine = line.new(x1=actualPivotBar, y1=rawPivotL, x2=bar_index, y2=rawPivotL, color=currentLineColor, width=lineWidth, style=getLineStyle(lineStyleInput), extend=extend.none)
        labelText = getLabelText(rawPivotL, actualPivotBar, bar_index, high)
        newLabel = label.new(x=actualPivotBar, y=rawPivotL, text=labelText, color=color.new(color.white, 100), textcolor=currentTextColor, style=getLabelStyle(labelPosInput, false), size=getFontSize(labelSizeInput))
        
        if not showPriceLevel and not showBaseStats
            label.delete(newLabel)
            
        array.push(activeLows, PivotLine.new(newLine, newLabel, rawPivotL, actualPivotBar, high))

// =======================================================
// --- REAL-TIME MAINTENANCE & PRECISE BREAKOUT LOOPS ---
// =======================================================

// Process Active Resistance Array
if array.size(activeHighs) > 0
    for i = array.size(activeHighs) - 1 to 0
        PivotLine pl = array.get(activeHighs, i)
        
        bool isBreached = breakType == "Percent" ? close > pl.price * (1 + (breakPct / 100)) : close > (pl.price + breakDistance)
        
        if isBreached and bar_index > pl.startBar + lookbackLen
            line.set_x2(pl.ln, bar_index)
            
            // Adjust broken colors using transparency injection natively supported in V6
            color targetLineColor = showBrokenRes ? colorHigh : color.new(colorHigh, 100)
            color targetTextColor = showBrokenRes ? textColor : color.new(textColor, 100)
            
            line.set_color(pl.ln, targetLineColor)
            label.set_textcolor(pl.lbl, targetTextColor)
                
            array.push(brokenHighs, pl)
            array.remove(activeHighs, i)
        else
            line.set_x2(pl.ln, bar_index)
            if low < pl.maxDepthPrice
                pl.maxDepthPrice := low
             
            if showPriceLevel or showBaseStats
                label.set_text(pl.lbl, getLabelText(pl.price, pl.startBar, bar_index, pl.maxDepthPrice))

// Process Active Support Array
if array.size(activeLows) > 0
    for i = array.size(activeLows) - 1 to 0
        PivotLine pl = array.get(activeLows, i)
        bool isBreached = breakType == "Percent" ? close < pl.price * (1 - (breakPct / 100)) : close < (pl.price - breakDistance)
        
        if isBreached and bar_index > pl.startBar + lookbackLen
            line.set_x2(pl.ln, bar_index)
            
            // Adjust broken colors using transparency injection natively supported in V6
            color targetLineColor = showBrokenSup ? colorLow : color.new(colorLow, 100)
            color targetTextColor = showBrokenSup ? textColor : color.new(textColor, 100)
            
            line.set_color(pl.ln, targetLineColor)
            label.set_textcolor(pl.lbl, targetTextColor)
            
            array.push(brokenLows, pl)
            array.remove(activeLows, i)
        else
            line.set_x2(pl.ln, bar_index)
            if high > pl.maxDepthPrice
                pl.maxDepthPrice := high
            if showPriceLevel or showBaseStats
                label.set_text(pl.lbl, getLabelText(pl.price, pl.startBar, bar_index, pl.maxDepthPrice))

// ==========================================
// --- ALERT ENGINE EXTENSION  ---
// ==========================================

// Check for newly created pivots on the historical bar where they just validated
if not na(rawPivotH) and not isTooClose(rawPivotH, activeHighs)
    float lowestPreceding = ta.lowest(low, preTrendBars)[lookbackLen + 1]
    if ((rawPivotH - lowestPreceding) / lowestPreceding) * 100 >= pctThreshold
        alert("New Resistance Formed on " + syminfo.ticker + " at Price: " + str.tostring(rawPivotH, "#.00"), alert.freq_once_per_bar)

if not na(rawPivotL) and not isTooClose(rawPivotL, activeLows)
    float highestPreceding = ta.highest(high, preTrendBars)[lookbackLen + 1]
    if ((highestPreceding - rawPivotL) / highestPreceding) * 100 >= pctThreshold
        alert("New Support Formed on " + syminfo.ticker + " at Price: " + str.tostring(rawPivotL, "#.00"), alert.freq_once_per_bar)

// Re-evaluate the arrays to catch breakout alerts exactly when they occur in real-time
if array.size(activeHighs) > 0
    for i = 0 to array.size(activeHighs) - 1
        PivotLine pl = array.get(activeHighs, i)
        bool isBreached = breakType == "Percent" ? close > pl.price * (1 + (breakPct / 100)) : close > (pl.price + breakDistance)
        // Check if breach happened exactly on the current real-time candle bar
        if isBreached and bar_index > pl.startBar + lookbackLen and ta.crossover(close, pl.price)
            alert("ALERT: Resistance Level Broken on " + syminfo.ticker + "! Price: " + str.tostring(close, "#.00") + " crossed above " + str.tostring(pl.price, "#.00"), alert.freq_once_per_bar)

if array.size(activeLows) > 0
    for i = 0 to array.size(activeLows) - 1
        PivotLine pl = array.get(activeLows, i)
        bool isBreached = breakType == "Percent" ? close < pl.price * (1 - (breakPct / 100)) : close < (pl.price - breakDistance)
        // Check if breach happened exactly on the current real-time candle bar
        if isBreached and bar_index > pl.startBar + lookbackLen and ta.crossunder(close, pl.price)
            alert("ALERT: Support Level Broken on " + syminfo.ticker + "! Price: " + str.tostring(close, "#.00") + " crossed below " + str.tostring(pl.price, "#.00"), alert.freq_once_per_bar)
````
