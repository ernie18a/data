<!-- tradingview-pine-id: PUB;03172ad35cae468ab688578d6bdd8bdb -->
<!-- tradingviewscripts-format: 1 -->
# Alea Magna Traders - CHoCH and BoS

Source: https://www.tradingview.com/script/eXxK4NAm-Alea-Magna-Traders-choch-bos/

## Description

This script is a lightweight, custom-built Smart Money Concepts (SMC) Market Structure Indicator written in Pine Script v6 for TradingView.

It tracks real-time market structure shifts on your chart by identifying and plotting two core price action events: CHoCH (Change of Character) and BoS (Break of Structure).

Core Mechanics & Features
Dual-Timeframe/Sensitivity Structure Tracking:

Internal Structure (Micro): Tracks fast, short-term structural breaks using a smaller pivot sensitivity (default: 5). Ideal for finding lower-timeframe entries.

External Structure (Macro): Tracks major, high-timeframe structural pivots using a higher sensitivity (default: 25). Ideal for determining overall trend direction.

Market Structure Mapping:

CHoCH (Change of Character): Detects when price breaks the previous structure in the opposite direction of the current trend, signaling a potential trend reversal.

BoS (Break of Structure): Detects when price breaks structure in the same direction as the current trend, signaling trend continuation.

Clean Visual Overlay:

Draws horizontal dashed lines connecting the original pivot level to the breakout point.

Places color-coded labels (Bullish / Bearish) directly above or below the breakout candle.

Advanced Data Management:

Uses Pine Script v6 map.new() data structures to dynamically track swing high/low coordinates (upaxis, dnaxis, direction states) without lagging the chart.

Employs custom array slicing to calculate swing highs and lows independently.

Customizability & Filtering:

Allows traders to toggle Internal and External structures on or off independently.

Includes pattern filters to show All, BoS-only, or CHoCH-only markers.

Full control over Bullish and Bearish colors.

---

## Source Code

````pine
//@version=6
//==============================================================================
// ALEA MAGNA TRADERS – Smart Money Concept Engine
//==============================================================================
// © Alea Magna Traders | Structure Engine (CHoCH & BoS Only)
//------------------------------------------------------------------------------
indicator("Alea Magna Traders - CHoCH and BoS", shorttitle="AMT SMC", overlay=true, max_labels_count=500, max_lines_count=500, max_bars_back=500)

// ============================================
// INPUTS - SMART MONEY CONCEPTS
// ============================================
bullC    = input.color(defval = #14D990, title = "Bullish Color", group = "Structure Colors", inline = "1")
bearC    = input.color(defval = #F24968, title = "Bearish Color", group = "Structure Colors", inline = "1")

showInt  = input.bool(defval = true, title = "Show Internal Structure", group = "Internal Structure")
intSens  = input.int(5, "Internal Sensitivity", options = [3, 5, 8], group = "Internal Structure", inline = "2")
intStru  = input.string(defval = "All", title = "Internal Pattern Filter", options = ["All", "BoS", "CHoCH"], inline = "2", group = "Internal Structure")

showExt  = input.bool(defval = true, title = "Show External Structure", group = "External Structure")
extSens  = input.int(25, "External Sensitivity", options = [10, 25, 50], group = "External Structure", inline = "3")
extStru  = input.string(defval = "All", title = "External Pattern Filter", options = ["All", "BoS", "CHoCH"], inline = "3", group = "External Structure")

// ============================================
// DATA STORAGE & ARRAYS
// ============================================
var bigData = map.new<string, float>()
var intData = map.new<string, float>()

if bigData.size() == 0
    bigData.put("moving", 0)
    bigData.put("upaxis", 0.0) 
    bigData.put("upaxis2", 0)
    bigData.put("dnaxis", 0.0) 
    bigData.put("dnaxis2", 0)
    bigData.put("upside", 1)
    bigData.put("downside", 1)

if intData.size() == 0
    intData.put("moving", 0)
    intData.put("upaxis", 0.0) 
    intData.put("upaxis2", 0)
    intData.put("dnaxis", 0.0) 
    intData.put("dnaxis2", 0)
    intData.put("upside", 1)
    intData.put("downside", 1)

var highArr = array.new_float()
var lowArr  = array.new_float()

highArr.unshift(high)
lowArr.unshift(low)

// ============================================
// FUNCTIONS & LOGIC
// ============================================
calculatePivots(lengthCalc) =>
    var int intraCalc = 0
    topSwing = 0.0
    botSwing = 0.0

    if bar_index > lengthCalc + 1
        up  = highArr.slice(0, lengthCalc).max()
        dn  = lowArr.slice(0, lengthCalc).min() 
        
        cHi = highArr.get(lengthCalc)
        cLo = lowArr.get(lengthCalc)

        intraCalc := cHi > up ? 0 : cLo < dn ? 1 : intraCalc[1]

        topSwing := (intraCalc == 0 and intraCalc[1] != 0) ? cHi : 0.0
        botSwing := (intraCalc == 1 and intraCalc[1] != 1) ? cLo : 0.0

    [topSwing, botSwing]

drawChar(x, y, str, col, down) =>
    if str != ""
        style = down ? label.style_label_down : label.style_label_up
        line.new(int(x), y, bar_index, y, color = col, style = line.style_dashed)
        label.new(math.round(math.avg(x, bar_index)), y, str, color = #00000000, textcolor = col, style = style, size = size.small)

[bigUpper, bigLower]     = calculatePivots(extSens)
[smallUpper, smallLower] = calculatePivots(intSens)

// --------------------------------------------
// EXTERNAL STRUCTURE (CHoCH / BoS)
// --------------------------------------------
if bigUpper != 0
    bigData.put("upside", 1)
    x1 = bar_index - extSens
    bigData.put("upaxis", bigUpper)
    bigData.put("upaxis2", x1)

if bigLower != 0
    bigData.put("downside", 1)
    x1 = bar_index - extSens
    bigData.put("dnaxis", bigLower)
    bigData.put("dnaxis2", x1)

if showExt
    if ta.crossover(close, bigData.get("upaxis"))
        if bigData.get("upside") != 0
            str = bigData.get("moving") < 0 ? (extStru != "BoS" ? "CHoCH" : "") : (extStru != "CHoCH" ? "BoS" : "")
            if (extStru == "All" or str == extStru) and str != ""
                drawChar(bigData.get("upaxis2"), bigData.get("upaxis"), str, bullC, true)
            bigData.put("upside", 0)
            bigData.put("moving", 1)

    if ta.crossunder(close, bigData.get("dnaxis"))
        if bigData.get("downside") != 0
            str = bigData.get("moving") > 0 ? (extStru != "BoS" ? "CHoCH" : "") : (extStru != "CHoCH" ? "BoS" : "")
            if (extStru == "All" or str == extStru) and str != ""
                drawChar(bigData.get("dnaxis2"), bigData.get("dnaxis"), str, bearC, false)
            bigData.put("downside", 0)
            bigData.put("moving", -1)

// --------------------------------------------
// INTERNAL STRUCTURE (CHoCH / BoS)
// --------------------------------------------
if smallUpper != 0
    intData.put("upside", 1)
    x1 = bar_index - intSens
    intData.put("upaxis", smallUpper)
    intData.put("upaxis2", x1)

if smallLower != 0
    intData.put("downside", 1)
    x1 = bar_index - intSens
    intData.put("dnaxis", smallLower)
    intData.put("dnaxis2", x1)

if showInt
    if ta.crossover(close, intData.get("upaxis"))
        if intData.get("upside") != 0
            str = intData.get("moving") < 0 ? (intStru != "BoS" ? "CHoCH" : "") : (intStru != "CHoCH" ? "BoS" : "")
            if (intStru == "All" or str == intStru) and str != ""
                drawChar(intData.get("upaxis2"), intData.get("upaxis"), str, bullC, true)
            intData.put("upside", 0)
            intData.put("moving", 1)

    if ta.crossunder(close, intData.get("dnaxis"))
        if intData.get("downside") != 0
            str = intData.get("moving") > 0 ? (intStru != "BoS" ? "CHoCH" : "") : (intStru != "CHoCH" ? "BoS" : "")
            if (intStru == "All" or str == intStru) and str != ""
                drawChar(intData.get("dnaxis2"), intData.get("dnaxis"), str, bearC, false)
            intData.put("downside", 0)
            intData.put("moving", -1)
````
