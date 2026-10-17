# Hexatap

- url: https://www.tradingview.com/script/8f041qcZ-Hexatap/
- type: indicator
- pine_id: PUB;82a7c911b18e46d1b0a7a4487710b489
- version: 2.0

## Description

[b]Hexatap — 6-Point Reversal Pattern Detector[/b]
Hexatap automatically detects a specific 6-point price structure that forms during strong trending moves, identifying high-probability reversal entry zones where price is likely to retrace before continuing in the dominant direction.
[b]How it works[/b]
The indicator scans for a sequence of swing points that confirm trending market structure — three ascending highs in a bullish market or three descending lows in a bearish market. Between these structural points, it identifies key intermediary extremes and validates whether a liquidity sweep has occurred into a critical supply/demand zone. When the full 6-point structure completes, the indicator draws the zone and highlights the golden ratio entry area where price is statistically likely to reverse and continue the trend.
[b]The 6-point structure[/b]
Point 1–2 form the initial range and define the supply/demand zone. Point 3 confirms the trend direction by breaking structure. Point 4 sweeps back into the zone, tapping liquidity. Point 5 breaks structure again, confirming momentum. Point 6 is the entry signal — price retraces into the zone one final time, reaching the 0.382–0.618 fibonacci sweet spot before reversing.
[b]Features[/b]

[list]
[*]Auto-detection of bullish and bearish 6-point reversal structures
[*]Manual directional bias selector (Bullish / Bearish / Both)
[*]Configurable swing detection with ATR-based noise filtering
[*]Supply/demand zone drawing with adjustable extension
[*]Golden ratio levels (0.382, 0.500, 0.618, 0.786) — each individually toggleable with custom colors, styles, and line widths
[*]Golden pocket fill (0.618–0.786) with adjustable color
[*]A+ / A- setup quality grading based on zone sweep depth
[*]Smart entry detection using wick penetration into the fibonacci sweet spot
[*]Four configurable alerts: structure complete, price approaching zone, entry signal, and low quality sweep warning
[/list]

[b]Recommended timeframes[/b]
Works on any timeframe. Lower swing lookback values (2–3) work well for lower timeframes. Higher values (4–6) suit higher timeframes. The ATR filter helps eliminate noise without missing valid patterns.
[b]How to use[/b]

Set your directional bias based on your higher timeframe analysis
Wait for the indicator to detect a valid 6-point structure (TAP 1–5)
Watch for price to retrace back to the zone after the structure completes
The A+ entry signal fires when price reaches the 0.382–0.618 area — your entry zone
Place your stop below the zone (bullish) or above the zone (bearish)
Target the previous structure high/low for a minimum 1:1 risk-reward

[b]Settings guide[/b]

Swing Lookback: Controls how many bars are needed to confirm a swing point. Lower = more sensitive, higher = fewer but stronger swings
Min Swing Size (ATR): Filters out insignificant swings. Set to 0 to disable
Zone Sweep Threshold: How deep the sweep into the zone can be before the setup is downgraded from A+ to A-
Zone Extend: How many bars the zone box extends to the right after detection

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © FreddyTheFresh - Hexatap Pattern Detector

//@version=6
indicator("Hexatap", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ─── INPUTS ───────────────────────────────────────────────────────────────────

grp_bias = "Market Bias"
marketBias = input.string("Both", "Directional Bias", options=["Bullish", "Bearish", "Both"], group=grp_bias, tooltip="Bullish = look for bullish Hexatap to buy retracement. Bearish = look for bearish Hexatap to sell retracement.")

grp_swing = "Swing Detection"
swingLen = input.int(3, "Swing Lookback (bars L/R)", minval=1, maxval=10, group=grp_swing)
minSwingATR = input.float(0.3, "Min Swing Size (ATR multiple)", minval=0.0, maxval=3.0, step=0.1, group=grp_swing)

grp_pattern = "Pattern Settings"
maxPatternBars = input.int(120, "Max Pattern Width (bars)", minval=20, maxval=500, group=grp_pattern)
sweepThreshold = input.float(50.0, "Zone Sweep Threshold (%)", minval=10.0, maxval=90.0, step=5.0, group=grp_pattern)

grp_visual = "Visual Settings"
showZoneBox = input.bool(true, "Draw TAP 1-2 Zone", group=grp_visual)
showGannBox = input.bool(true, "Draw Golden Ratio / Gann Box", group=grp_visual)
showLabels = input.bool(true, "Show TAP Labels (1-6)", group=grp_visual)
showSequencePath = input.bool(true, "Show Sequence Path (1→5)", group=grp_visual)
colorSequencePath = input.color(color.new(#378ADD, 30), "Sequence Path Color", group=grp_visual)
widthSequencePath = input.int(1, "Sequence Path Width", minval=1, maxval=4, group=grp_visual)
showOpenSetups = input.bool(true, "Show Open Setups", group=grp_visual)
showHistorical = input.bool(false, "Show Historical Setups", group=grp_visual)
zoneExtendBars = input.int(50, "Zone Extend (bars)", minval=10, maxval=200, group=grp_visual)
colorBullZone = input.color(color.new(#1D9E75, 85), "Bullish Zone Color", group=grp_visual)
colorBearZone = input.color(color.new(#E24B4A, 85), "Bearish Zone Color", group=grp_visual)
colorLowQuality = input.color(color.new(#BA7517, 85), "Low Quality Zone Color", group=grp_visual)

grp_gann = "Golden Ratio Levels"
showFib786 = input.bool(true, "Show 0.786 Level", group=grp_gann)
colorFib786 = input.color(color.new(#378ADD, 30), "0.786 Color", group=grp_gann)
styleFib786 = input.string("Dashed", "0.786 Style", options=["Solid", "Dashed", "Dotted"], group=grp_gann)
widthFib786 = input.int(1, "0.786 Width", minval=1, maxval=4, group=grp_gann)

showFib618 = input.bool(true, "Show 0.618 Level", group=grp_gann)
colorFib618 = input.color(color.new(#1D9E75, 20), "0.618 Color", group=grp_gann)
styleFib618 = input.string("Dashed", "0.618 Style", options=["Solid", "Dashed", "Dotted"], group=grp_gann)
widthFib618 = input.int(1, "0.618 Width", minval=1, maxval=4, group=grp_gann)

showFib500 = input.bool(true, "Show 0.500 Level", group=grp_gann)
colorFib500 = input.color(color.new(color.gray, 40), "0.500 Color", group=grp_gann)
styleFib500 = input.string("Dotted", "0.500 Style", options=["Solid", "Dashed", "Dotted"], group=grp_gann)
widthFib500 = input.int(1, "0.500 Width", minval=1, maxval=4, group=grp_gann)

showFib382 = input.bool(true, "Show 0.382 Level", group=grp_gann)
colorFib382 = input.color(color.new(#BA7517, 40), "0.382 Color", group=grp_gann)
styleFib382 = input.string("Dotted", "0.382 Style", options=["Solid", "Dashed", "Dotted"], group=grp_gann)
widthFib382 = input.int(1, "0.382 Width", minval=1, maxval=4, group=grp_gann)

showGoldenPocket = input.bool(true, "Fill Golden Pocket (0.618–0.786)", group=grp_gann)
colorGoldenPocket = input.color(color.new(#378ADD, 88), "Golden Pocket Fill", group=grp_gann)

showFibLabels = input.bool(true, "Show Fib Labels", group=grp_gann)

grp_alerts = "Alerts"
alertOnTap5 = input.bool(true, "Alert on TAP 5 (BOS / structure complete)", group=grp_alerts)
alertOnTap6 = input.bool(true, "Alert on TAP 6 (price enters entry zone — 0.382-0.618)", group=grp_alerts)
alertOnApproach = input.bool(true, "Alert on price approaching zone", group=grp_alerts)
approachPct = input.float(0.3, "Approach Distance (%)", minval=0.05, maxval=2.0, step=0.05, group=grp_alerts)
alertOnLowQuality = input.bool(true, "Alert on Low Quality Sweep (>threshold)", group=grp_alerts)

// ─── ATR ──────────────────────────────────────────────────────────────────────

atrVal = ta.atr(14)

// ─── LINE STYLE HELPER ───────────────────────────────────────────────────────

getLineStyle(string s) =>
    s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted

// ─── SWING DETECTION ─────────────────────────────────────────────────────────

swingHigh = ta.pivothigh(high, swingLen, swingLen)
swingLow  = ta.pivotlow(low, swingLen, swingLen)

var float[] shPrices = array.new_float(0)
var int[]   shBars   = array.new_int(0)
var float[] slPrices = array.new_float(0)
var int[]   slBars   = array.new_int(0)

maxStore = 30

if not na(swingHigh)
    bool add = true
    if minSwingATR > 0 and array.size(shPrices) > 0
        float lastSH = array.get(shPrices, array.size(shPrices) - 1)
        if math.abs(swingHigh - lastSH) < atrVal * minSwingATR
            if swingHigh > lastSH
                array.set(shPrices, array.size(shPrices) - 1, swingHigh)
                array.set(shBars, array.size(shBars) - 1, bar_index - swingLen)
            add := false
    if add
        array.push(shPrices, swingHigh)
        array.push(shBars, bar_index - swingLen)
        if array.size(shPrices) > maxStore
            array.shift(shPrices)
            array.shift(shBars)

if not na(swingLow)
    bool add = true
    if minSwingATR > 0 and array.size(slPrices) > 0
        float lastSL = array.get(slPrices, array.size(slPrices) - 1)
        if math.abs(swingLow - lastSL) < atrVal * minSwingATR
            if swingLow < lastSL
                array.set(slPrices, array.size(slPrices) - 1, swingLow)
                array.set(slBars, array.size(slBars) - 1, bar_index - swingLen)
            add := false
    if add
        array.push(slPrices, swingLow)
        array.push(slBars, bar_index - swingLen)
        if array.size(slPrices) > maxStore
            array.shift(slPrices)
            array.shift(slBars)

// ─── HELPERS ─────────────────────────────────────────────────────────────────

findLowestBetween(int barLeft, int barRight) =>
    float lowestPrice = na
    int   lowestBar   = na
    int   lookback    = bar_index - barLeft
    int   lookfwd     = bar_index - barRight
    if lookback >= 0 and lookfwd >= 0
        lowestPrice := low[lookback]
        lowestBar   := barLeft
        for i = lookback to lookfwd
            if low[i] < lowestPrice
                lowestPrice := low[i]
                lowestBar   := bar_index - i
    [lowestPrice, lowestBar]

findHighestBetween(int barLeft, int barRight) =>
    float highestPrice = na
    int   highestBar   = na
    int   lookback     = bar_index - barLeft
    int   lookfwd      = bar_index - barRight
    if lookback >= 0 and lookfwd >= 0
        highestPrice := high[lookback]
        highestBar   := barLeft
        for i = lookback to lookfwd
            if high[i] > highestPrice
                highestPrice := high[i]
                highestBar   := bar_index - i
    [highestPrice, highestBar]

// ─── DRAWING ARRAYS (for cleanup) ────────────────────────────────────────────
// Store all drawing IDs in arrays so we can bulk-delete when needed

var box[]   bullDrawBoxes   = array.new<box>()
var line[]  bullDrawLines   = array.new<line>()
var label[] bullDrawLabels  = array.new<label>()

var box[]   bearDrawBoxes   = array.new<box>()
var line[]  bearDrawLines   = array.new<line>()
var label[] bearDrawLabels  = array.new<label>()

cleanupBull() =>
    while array.size(bullDrawBoxes) > 0
        box.delete(array.pop(bullDrawBoxes))
    while array.size(bullDrawLines) > 0
        line.delete(array.pop(bullDrawLines))
    while array.size(bullDrawLabels) > 0
        label.delete(array.pop(bullDrawLabels))

cleanupBear() =>
    while array.size(bearDrawBoxes) > 0
        box.delete(array.pop(bearDrawBoxes))
    while array.size(bearDrawLines) > 0
        line.delete(array.pop(bearDrawLines))
    while array.size(bearDrawLabels) > 0
        label.delete(array.pop(bearDrawLabels))

// ─── GANN BOX DRAWING ────────────────────────────────────────────────────────

drawGannBox(int gannLeft, int gannRight, float zoneTop, float zoneBot, box[] drawBoxes, line[] drawLines, label[] drawLabels) =>
    float zoneHeight = zoneTop - zoneBot
    float fib382val = zoneTop - zoneHeight * 0.382
    float fib500val = zoneTop - zoneHeight * 0.500
    float fib618val = zoneTop - zoneHeight * 0.618
    float fib786val = zoneTop - zoneHeight * 0.786
    
    if showGoldenPocket
        array.push(drawBoxes, box.new(gannLeft, fib618val, gannRight, fib786val, border_color=color.new(colorGoldenPocket, 60), bgcolor=colorGoldenPocket, border_width=0))
    
    if showFib382
        array.push(drawLines, line.new(gannLeft, fib382val, gannRight, fib382val, color=colorFib382, style=getLineStyle(styleFib382), width=widthFib382))
        if showFibLabels
            array.push(drawLabels, label.new(gannRight, fib382val, "0.382", style=label.style_label_left, color=color.new(color.white, 100), textcolor=colorFib382, size=size.tiny))
    
    if showFib500
        array.push(drawLines, line.new(gannLeft, fib500val, gannRight, fib500val, color=colorFib500, style=getLineStyle(styleFib500), width=widthFib500))
        if showFibLabels
            array.push(drawLabels, label.new(gannRight, fib500val, "0.500", style=label.style_label_left, color=color.new(color.white, 100), textcolor=colorFib500, size=size.tiny))
    
    if showFib618
        array.push(drawLines, line.new(gannLeft, fib618val, gannRight, fib618val, color=colorFib618, style=getLineStyle(styleFib618), width=widthFib618))
        if showFibLabels
            array.push(drawLabels, label.new(gannRight, fib618val, "0.618", style=label.style_label_left, color=color.new(color.white, 100), textcolor=colorFib618, size=size.tiny))
    
    if showFib786
        array.push(drawLines, line.new(gannLeft, fib786val, gannRight, fib786val, color=colorFib786, style=getLineStyle(styleFib786), width=widthFib786))
        if showFibLabels
            array.push(drawLabels, label.new(gannRight, fib786val, "0.786", style=label.style_label_left, color=color.new(color.white, 100), textcolor=colorFib786, size=size.tiny))

// ─── PATTERN STATE ────────────────────────────────────────────────────────────

var int   lastBullTap5Bar  = -1
var int   lastBearTap5Bar  = -1

var bool  activeBull       = false
var float bullZoneHigh     = na
var float bullZoneLow      = na
var float bullFib382       = na
var float bullFib618       = na
var float bullSweepDepth   = na
var bool  bullTap6Fired    = false

var bool  activeBear       = false
var float bearZoneHigh     = na
var float bearZoneLow      = na
var float bearFib382       = na
var float bearFib618       = na
var float bearSweepDepth   = na
var bool  bearTap6Fired    = false

var bool tap5Alert       = false
var bool tap6Alert       = false
var bool approachAlert   = false
var bool lowQualityAlert = false

tap5Alert       := false
tap6Alert       := false
approachAlert   := false
lowQualityAlert := false

// ─── BULLISH HEXATAP DETECTION ────────────────────────────────────────────────

if (marketBias == "Bullish" or marketBias == "Both") and array.size(shPrices) >= 3
    int sz = array.size(shPrices)
    
    float sh1 = array.get(shPrices, sz - 3)
    float sh2 = array.get(shPrices, sz - 2)
    float sh3 = array.get(shPrices, sz - 1)
    int   bh1 = array.get(shBars, sz - 3)
    int   bh2 = array.get(shBars, sz - 2)
    int   bh3 = array.get(shBars, sz - 1)
    
    bool isValid = true
    isValid := isValid and sh2 > sh1
    isValid := isValid and sh3 > sh2
    isValid := isValid and (bh3 - bh1) <= maxPatternBars
    isValid := isValid and bh3 != lastBullTap5Bar
    
    if isValid
        [p2, b2] = findLowestBetween(bh1, bh2)
        [p4, b4] = findLowestBetween(bh2, bh3)
        
        if not na(p2) and not na(p4)
            bool tap4Valid = p4 < sh1 and p4 > p2
            
            if tap4Valid
                float zoneHeight = sh1 - p2
                float sweepDepth = (sh1 - p4) / zoneHeight * 100.0
                
                // Clean up previous uncompleted bull setup
                if activeBull and not bullTap6Fired and not showHistorical
                    cleanupBull()
                
                lastBullTap5Bar := bh3
                
                activeBull     := true
                bullZoneHigh   := sh1
                bullZoneLow    := p2
                bullFib382     := sh1 - zoneHeight * 0.382
                bullFib618     := sh1 - zoneHeight * 0.618
                bullSweepDepth := sweepDepth
                bullTap6Fired  := false
                
                color zoneCol = sweepDepth < sweepThreshold ? colorBullZone : colorLowQuality
                
                // TAP labels
                if showLabels
                    array.push(bullDrawLabels, label.new(bh1, sh1, "1", style=label.style_label_down, color=color.new(color.white, 100), textcolor=#1D9E75, size=size.small))
                    array.push(bullDrawLabels, label.new(b2, p2, "2", style=label.style_label_up, color=color.new(color.white, 100), textcolor=#1D9E75, size=size.small))
                    array.push(bullDrawLabels, label.new(bh2, sh2, "3", style=label.style_label_down, color=color.new(color.white, 100), textcolor=#1D9E75, size=size.small))
                    array.push(bullDrawLabels, label.new(b4, p4, "4", style=label.style_label_up, color=color.new(color.white, 100), textcolor=#BA7517, size=size.small))
                    array.push(bullDrawLabels, label.new(bh3, sh3, "5", style=label.style_label_down, color=color.new(color.white, 100), textcolor=#1D9E75, size=size.small))
                
                // Sequence path
                if showSequencePath
                    array.push(bullDrawLines, line.new(bh1, sh1, b2, p2, color=colorSequencePath, width=widthSequencePath))
                    array.push(bullDrawLines, line.new(b2, p2, bh2, sh2, color=colorSequencePath, width=widthSequencePath))
                    array.push(bullDrawLines, line.new(bh2, sh2, b4, p4, color=colorSequencePath, width=widthSequencePath))
                    array.push(bullDrawLines, line.new(b4, p4, bh3, sh3, color=colorSequencePath, width=widthSequencePath))
                
                // Zone box
                if showZoneBox
                    array.push(bullDrawBoxes, box.new(bh1, sh1, bh3 + zoneExtendBars, p2, border_color=color.new(zoneCol, 50), bgcolor=zoneCol, border_width=1, border_style=line.style_dashed))
                
                // Gann box
                if showGannBox
                    drawGannBox(bh3, bh3 + zoneExtendBars, sh1, p2, bullDrawBoxes, bullDrawLines, bullDrawLabels)
                
                if alertOnTap5
                    tap5Alert := true


// ─── BEARISH HEXATAP DETECTION ────────────────────────────────────────────────

if (marketBias == "Bearish" or marketBias == "Both") and array.size(slPrices) >= 3
    int sz = array.size(slPrices)
    
    float sl1 = array.get(slPrices, sz - 3)
    float sl2 = array.get(slPrices, sz - 2)
    float sl3 = array.get(slPrices, sz - 1)
    int   bl1 = array.get(slBars, sz - 3)
    int   bl2 = array.get(slBars, sz - 2)
    int   bl3 = array.get(slBars, sz - 1)
    
    bool isValid = true
    isValid := isValid and sl2 < sl1
    isValid := isValid and sl3 < sl2
    isValid := isValid and (bl3 - bl1) <= maxPatternBars
    isValid := isValid and bl3 != lastBearTap5Bar
    
    if isValid
        [p2, b2] = findHighestBetween(bl1, bl2)
        [p4, b4] = findHighestBetween(bl2, bl3)
        
        if not na(p2) and not na(p4)
            bool tap4Valid = p4 > sl1 and p4 < p2
            
            if tap4Valid
                float zoneHeight = p2 - sl1
                float sweepDepth = (p4 - sl1) / zoneHeight * 100.0
                
                if activeBear and not bearTap6Fired and not showHistorical
                    cleanupBear()
                
                lastBearTap5Bar := bl3
                
                activeBear     := true
                bearZoneHigh   := p2
                bearZoneLow    := sl1
                bearFib382     := sl1 + zoneHeight * 0.382
                bearFib618     := sl1 + zoneHeight * 0.618
                bearSweepDepth := sweepDepth
                bearTap6Fired  := false
                
                color zoneCol = sweepDepth < sweepThreshold ? colorBearZone : colorLowQuality
                
                if showLabels
                    array.push(bearDrawLabels, label.new(bl1, sl1, "1", style=label.style_label_up, color=color.new(color.white, 100), textcolor=#E24B4A, size=size.small))
                    array.push(bearDrawLabels, label.new(b2, p2, "2", style=label.style_label_down, color=color.new(color.white, 100), textcolor=#E24B4A, size=size.small))
                    array.push(bearDrawLabels, label.new(bl2, sl2, "3", style=label.style_label_up, color=color.new(color.white, 100), textcolor=#E24B4A, size=size.small))
                    array.push(bearDrawLabels, label.new(b4, p4, "4", style=label.style_label_down, color=color.new(color.white, 100), textcolor=#BA7517, size=size.small))
                    array.push(bearDrawLabels, label.new(bl3, sl3, "5", style=label.style_label_up, color=color.new(color.white, 100), textcolor=#E24B4A, size=size.small))
                
                if showSequencePath
                    array.push(bearDrawLines, line.new(bl1, sl1, b2, p2, color=colorSequencePath, width=widthSequencePath))
                    array.push(bearDrawLines, line.new(b2, p2, bl2, sl2, color=colorSequencePath, width=widthSequencePath))
                    array.push(bearDrawLines, line.new(bl2, sl2, b4, p4, color=colorSequencePath, width=widthSequencePath))
                    array.push(bearDrawLines, line.new(b4, p4, bl3, sl3, color=colorSequencePath, width=widthSequencePath))
                
                if showZoneBox
                    array.push(bearDrawBoxes, box.new(bl1, p2, bl3 + zoneExtendBars, sl1, border_color=color.new(zoneCol, 50), bgcolor=zoneCol, border_width=1, border_style=line.style_dashed))
                
                if showGannBox
                    drawGannBox(bl3, bl3 + zoneExtendBars, p2, sl1, bearDrawBoxes, bearDrawLines, bearDrawLabels)
                
                if alertOnTap5
                    tap5Alert := true


// ─── TAP 6 DETECTION ─────────────────────────────────────────────────────────

if activeBull and not bullTap6Fired
    if low <= bullFib382 and low >= bullFib618
        bullTap6Fired := true
        bool isHQ = bullSweepDepth < sweepThreshold
        
        string qualLabel = isHQ ? "A+ ▲" : "A- ▲"
        color qualColor = isHQ ? #1D9E75 : #BA7517
        label.new(bar_index, low, qualLabel, style=label.style_label_up, color=qualColor, textcolor=color.white, size=size.normal)
        
        if showLabels
            label.new(bar_index, low, "6", style=label.style_label_up, color=color.new(color.white, 100), textcolor=#378ADD, size=size.small, yloc=yloc.belowbar)
        
        if alertOnTap6
            tap6Alert := true
        if not isHQ and alertOnLowQuality
            lowQualityAlert := true
    
    // Invalidate if price breaks below zone
    if close < bullZoneLow
        activeBull := false
        if not showHistorical
            cleanupBull()

if activeBear and not bearTap6Fired
    if high >= bearFib382 and high <= bearFib618
        bearTap6Fired := true
        bool isHQ = bearSweepDepth < sweepThreshold
        
        string qualLabel = isHQ ? "A+ ▼" : "A- ▼"
        color qualColor = isHQ ? #E24B4A : #BA7517
        label.new(bar_index, high, qualLabel, style=label.style_label_down, color=qualColor, textcolor=color.white, size=size.normal)
        
        if showLabels
            label.new(bar_index, high, "6", style=label.style_label_down, color=color.new(color.white, 100), textcolor=#378ADD, size=size.small, yloc=yloc.abovebar)
        
        if alertOnTap6
            tap6Alert := true
        if not isHQ and alertOnLowQuality
            lowQualityAlert := true
    
    if close > bearZoneHigh
        activeBear := false
        if not showHistorical
            cleanupBear()


// ─── APPROACH ALERTS ──────────────────────────────────────────────────────────

if activeBull and not bullTap6Fired and alertOnApproach
    float zoneH = bullZoneHigh - bullZoneLow
    float dist = zoneH * (approachPct / 100.0)
    if close <= (bullZoneHigh + dist) and close > bullZoneHigh
        approachAlert := true

if activeBear and not bearTap6Fired and alertOnApproach
    float zoneH = bearZoneHigh - bearZoneLow
    float dist = zoneH * (approachPct / 100.0)
    if close >= (bearZoneLow - dist) and close < bearZoneLow
        approachAlert := true


// ─── ALERT CONDITIONS ─────────────────────────────────────────────────────────

alertcondition(tap5Alert, title="TAP 5 — Structure Complete", message="Hexatap: TAP 5 BOS detected. Structure complete — watching for retracement.")
alertcondition(tap6Alert, title="TAP 6 — Entry Signal", message="Hexatap: TAP 6 — wick reached the 0.382–0.618 entry zone!")
alertcondition(approachAlert, title="Price Approaching Zone", message="Hexatap: Price approaching the zone. Get ready.")
alertcondition(lowQualityAlert, title="Low Quality Sweep", message="Hexatap: TAP 4 sweep exceeded threshold — A- setup.")


// ─── INFO TABLE ───────────────────────────────────────────────────────────────

var table infoTable = table.new(position.top_right, 2, 7, bgcolor=color.new(#1a1a2e, 10), border_width=1, border_color=color.new(color.gray, 80), frame_width=1, frame_color=color.new(color.gray, 70))

if barstate.islast
    table.cell(infoTable, 0, 0, "Hexatap", text_color=#378ADD, text_size=size.small, text_halign=text.align_left)
    table.cell(infoTable, 1, 0, "v1.9", text_color=color.gray, text_size=size.tiny, text_halign=text.align_right)
    
    table.cell(infoTable, 0, 1, "Bias", text_color=color.gray, text_size=size.tiny, text_halign=text.align_left)
    color biasCol = marketBias == "Bullish" ? #1D9E75 : marketBias == "Bearish" ? #E24B4A : #378ADD
    table.cell(infoTable, 1, 1, marketBias, text_color=biasCol, text_size=size.tiny, text_halign=text.align_right)
    
    table.cell(infoTable, 0, 2, "Swing / ATR", text_color=color.gray, text_size=size.tiny, text_halign=text.align_left)
    table.cell(infoTable, 1, 2, str.tostring(swingLen) + " / " + str.tostring(minSwingATR, "#.#") + "x", text_color=color.white, text_size=size.tiny, text_halign=text.align_right)
    
    table.cell(infoTable, 0, 3, "Sweep Threshold", text_color=color.gray, text_size=size.tiny, text_halign=text.align_left)
    table.cell(infoTable, 1, 3, str.tostring(sweepThreshold, "#.0") + "%", text_color=color.white, text_size=size.tiny, text_halign=text.align_right)
    
    table.cell(infoTable, 0, 4, "Bull Pattern", text_color=color.gray, text_size=size.tiny, text_halign=text.align_left)
    string bullStatus = activeBull ? (bullTap6Fired ? "TAP6 ✓" : "WAIT T6") : "—"
    color bullCol = activeBull ? (bullTap6Fired ? #1D9E75 : #BA7517) : color.gray
    table.cell(infoTable, 1, 4, bullStatus, text_color=bullCol, text_size=size.tiny, text_halign=text.align_right)
    
    table.cell(infoTable, 0, 5, "Bear Pattern", text_color=color.gray, text_size=size.tiny, text_halign=text.align_left)
    string bearStatus = activeBear ? (bearTap6Fired ? "TAP6 ✓" : "WAIT T6") : "—"
    color bearCol = activeBear ? (bearTap6Fired ? #E24B4A : #BA7517) : color.gray
    table.cell(infoTable, 1, 5, bearStatus, text_color=bearCol, text_size=size.tiny, text_halign=text.align_right)
    
    table.cell(infoTable, 0, 6, "Zone | Gann", text_color=color.gray, text_size=size.tiny, text_halign=text.align_left)
    string toggles = (showZoneBox ? "ON" : "OFF") + " | " + (showGannBox ? "ON" : "OFF")
    table.cell(infoTable, 1, 6, toggles, text_color=color.white, text_size=size.tiny, text_halign=text.align_right)
````
