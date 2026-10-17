# Accumu Trend Counter

- url: https://www.tradingview.com/script/mgXzQsVz-Accumu-Trend-Counter/
- type: indicator
- pine_id: PUB;b3c279510ed14a9eb0ceca55b171cc59
- version: 1.0

## Description

Trend Counter folllowing known Sequence principles

## Source Code

````pine
//@version=5
indicator("Accumu Trend Counter", overlay=true, max_labels_count=500, max_lines_count=500)

// ============================================================================
// UI & Color Inputs
// ============================================================================
colBuySetup  = input.color(color.new(color.green, 0), "Buy Setup")
colSellSetup = input.color(color.new(color.red, 0), "Sell Setup")
colBuyCD     = input.color(color.new(color.blue, 0), "Buy Countdown")
colSellCD    = input.color(color.new(color.orange, 0), "Sell Countdown")
colTdstRes   = input.color(color.new(color.red, 40), "TDST Resistance")
colTdstSup   = input.color(color.new(color.green, 40), "TDST Support")
colRisk      = input.color(color.new(color.yellow, 20), "Risk Level / 12X")
colRecycle   = input.color(color.new(color.gray, 0), "R/S Markers")

// ============================================================================
// Core Math & True Range
// ============================================================================
trueHigh = math.max(high, nz(close[1], high))
trueLow  = math.min(low, nz(close[1], low))
trValue  = trueHigh - trueLow

// ============================================================================
// State Management Variables
// ============================================================================
// Phase 1: Lockouts
var bool buyAwaitingFlip  = true
var bool sellAwaitingFlip = true

// Phase 2: Setup Tracking
var int buySetup  = 0
var int sellSetup = 0

// Phase 3: TDST Lines
var float tdstRes = na
var float tdstSup = na
var line tdstResLine = na
var line tdstSupLine = na

// Phase 4: Recycling Memory
var float lastBuySetupTR = na
var float lastBuySetupTL = na
var float lastBuySetupTH = na
var float lastSellSetupTR = na
var float lastSellSetupTL = na
var float lastSellSetupTH = na

// Phase 5: Countdown Tracking & Deferrals
var bool cdBuyActive = false
var int  cdBuyCount = 0
var float cdBuyBar5Close = na
var float cdBuyBar8Close = na
var float cdBuyLowestTL = na
var float cdBuyTRAtMin = na

var bool cdSellActive = false
var int  cdSellCount = 0
var float cdSellBar5Close = na
var float cdSellBar8Close = na
var float cdSellHighestTH = na
var float cdSellTRAtMax = na

// ============================================================================
// Core Concept: Price Flip Lockouts
// ============================================================================
if bar_index >= 5
    bearFlip = close < close[4] and close[1] >= close[5]
    bullFlip = close > close[4] and close[1] <= close[5]
    
    if bearFlip
        buyAwaitingFlip := false
        buySetup := 0 
    if bullFlip
        sellAwaitingFlip := false
        sellSetup := 0

// ============================================================================
// Phase 1: Setup Count & 'R' Recycling
// ============================================================================
if not buyAwaitingFlip and bar_index >= 4
    if close < close[4]
        buySetup += 1
        // 'R' Marker for Trend Continuation (22 Bars)
        if buySetup == 22
            label.new(bar_index, low, text="R", style=label.style_label_up, color=colRecycle, textcolor=color.white, size=size.small)
    else
        buySetup := 0
        buyAwaitingFlip := true

if not sellAwaitingFlip and bar_index >= 4
    if close > close[4]
        sellSetup += 1
        // 'R' Marker for Trend Continuation (22 Bars)
        if sellSetup == 22
            label.new(bar_index, high, text="R", style=label.style_label_down, color=colRecycle, textcolor=color.white, size=size.small)
    else
        sellSetup := 0
        sellAwaitingFlip := true

// ============================================================================
// Phase 2, 3 & 4: Setup Completion, Perfection & 'S' Recycling
// ============================================================================

// --- BUY SETUP 9 COMPLETION ---
if buySetup >= 1 and buySetup <= 9
    bool buyPerfected = false
        
    if buySetup == 9
        // Perfection Rule
        buyPerfected := (trueLow <= math.min(trueLow[2], trueLow[3])) or (trueLow[1] <= math.min(trueLow[2], trueLow[3]))
        
        // Extract 9-bar Metrics
        float minTL = trueLow
        float maxTH = trueHigh
        float minC = close
        float maxC = close
        float trAtMin = trValue
        for i = 0 to 8
            if trueLow[i] < minTL
                minTL := trueLow[i]
                trAtMin := trValue[i]
            maxTH := math.max(maxTH, trueHigh[i])
            minC := math.min(minC, close[i])
            maxC := math.max(maxC, close[i])
            
        float currentSetupTR = maxTH - minTL
        
        // Structure Support Validation Level
        tdstRes := maxTH
        if not na(tdstResLine)
            line.set_extend(tdstResLine, extend.none)
            line.set_x2(tdstResLine, bar_index)
        tdstResLine := line.new(bar_index - 8, tdstRes, bar_index, tdstRes, color=colTdstRes, style=line.style_dashed, extend=extend.right)
        
        cdSellActive := false // Cancellation
        
        // 'S' Recycling Logic
        bool recycleS = false
        if cdBuyActive and not na(lastBuySetupTR)
            float ratio = currentSetupTR / lastBuySetupTR
            bool engulfed = minC >= lastBuySetupTL and maxC <= lastBuySetupTH
            if not engulfed and ratio >= 1.0 and ratio <= 2.0 // Up to 200% of previous setup
                recycleS := true
                label.new(bar_index, low, text="S", style=label.style_label_up, color=colRecycle, textcolor=color.white, size=size.small)
                
        if not cdBuyActive or recycleS
            cdBuyActive := true
            cdBuyCount := 0
            cdBuyLowestTL := minTL
            cdBuyTRAtMin := trAtMin
            
        lastBuySetupTR := currentSetupTR
        lastBuySetupTL := minTL
        lastBuySetupTH := maxTH

    string txt = str.tostring(buySetup) + (buyPerfected and buySetup == 9 ? "✓" : "")
    size = buySetup == 9 ? size.normal : size.small
    label.new(bar_index, low, text=txt, style=label.style_label_up, textcolor=colBuySetup, color=color.new(color.white, 100), size=size)


// --- SELL SETUP 9 COMPLETION ---
if sellSetup >= 1 and sellSetup <= 9
    bool sellPerfected = false
        
    if sellSetup == 9
        // Perfection Rule
        sellPerfected := (trueHigh >= math.max(trueHigh[2], trueHigh[3])) or (trueHigh[1] >= math.max(trueHigh[2], trueHigh[3]))
        
        // Extract 9-bar Metrics
        float minTL = trueLow
        float maxTH = trueHigh
        float minC = close
        float maxC = close
        float trAtMax = trValue
        for i = 0 to 8
            if trueHigh[i] > maxTH
                maxTH := trueHigh[i]
                trAtMax := trValue[i]
            minTL := math.min(minTL, trueLow[i])
            minC := math.min(minC, close[i])
            maxC := math.max(maxC, close[i])
            
        float currentSetupTR = maxTH - minTL
        
        // Structure Resistance Validation Level
        tdstSup := minTL
        if not na(tdstSupLine)
            line.set_extend(tdstSupLine, extend.none)
            line.set_x2(tdstSupLine, bar_index)
        tdstSupLine := line.new(bar_index - 8, tdstSup, bar_index, tdstSup, color=colTdstSup, style=line.style_dashed, extend=extend.right)
        
        cdBuyActive := false // Cancellation
        
        // 'S' Recycling Logic
        bool recycleS = false
        if cdSellActive and not na(lastSellSetupTR)
            float ratio = currentSetupTR / lastSellSetupTR
            bool engulfed = minC >= lastSellSetupTL and maxC <= lastSellSetupTH
            if not engulfed and ratio >= 1.0 and ratio <= 2.0 // Up to 200% of previous setup
                recycleS := true
                label.new(bar_index, high, text="S", style=label.style_label_down, color=colRecycle, textcolor=color.white, size=size.small)
                
        if not cdSellActive or recycleS
            cdSellActive := true
            cdSellCount := 0
            cdSellHighestTH := maxTH
            cdSellTRAtMax := trAtMax
            
        lastSellSetupTR := currentSetupTR
        lastSellSetupTL := minTL
        lastSellSetupTH := maxTH

    string txt = str.tostring(sellSetup) + (sellPerfected and sellSetup == 9 ? "✓" : "")
    size = sellSetup == 9 ? size.normal : size.small
    label.new(bar_index, high, text=txt, style=label.style_label_down, textcolor=colSellSetup, color=color.new(color.white, 100), size=size)

// ============================================================================
// Phase 3: Structural Validation Cancellation
// ============================================================================
if not na(tdstRes) and close > tdstRes
    if not na(tdstResLine)
        line.set_extend(tdstResLine, extend.none)
        line.set_x2(tdstResLine, bar_index)
    tdstRes := na
    cdBuyActive := false 

if not na(tdstSup) and close < tdstSup
    if not na(tdstSupLine)
        line.set_extend(tdstSupLine, extend.none)
        line.set_x2(tdstSupLine, bar_index)
    tdstSup := na
    cdSellActive := false

// ============================================================================
// Phase 5: The TD Countdown (13-Count) & Deferrals
// ============================================================================

// --- BUY COUNTDOWN ---
if cdBuyActive
    if trueLow < cdBuyLowestTL
        cdBuyLowestTL := trueLow
        cdBuyTRAtMin := trValue

    if bar_index >= 2 and close <= low[2]
        bool advanceCount = false
        
        if cdBuyCount == 7
            if low <= cdBuyBar5Close // 8 vs 5 Deferral
                advanceCount := true
        else if cdBuyCount == 12
            if low <= cdBuyBar8Close // 13 vs 8 Deferral
                advanceCount := true
        else
            advanceCount := true
            
        if advanceCount
            cdBuyCount += 1
            
            if cdBuyCount == 5
                cdBuyBar5Close := close
            if cdBuyCount == 8
                cdBuyBar8Close := close
                
            if cdBuyCount == 13
                cdBuyActive := false 
                label.new(bar_index, low, text="\n13", style=label.style_label_up, textcolor=colBuyCD, color=color.new(color.white,100), size=size.normal)
                
                // Risk Line & 12X Tracker
                float riskLevel = cdBuyLowestTL - cdBuyTRAtMin
                line.new(bar_index, riskLevel, bar_index + 12, riskLevel, color=colRisk, style=line.style_dotted, width=2)
            else
                label.new(bar_index, low, text="\n" + str.tostring(cdBuyCount), style=label.style_label_up, textcolor=colBuyCD, color=color.new(color.white,100), size=size.small)
        else
            if cdBuyCount == 12
                label.new(bar_index, low, text="\n+", style=label.style_label_up, textcolor=colBuyCD, color=color.new(color.white,100), size=size.small)


// --- SELL COUNTDOWN ---
if cdSellActive
    if trueHigh > cdSellHighestTH
        cdSellHighestTH := trueHigh
        cdSellTRAtMax := trValue

    if bar_index >= 2 and close >= high[2]
        bool advanceCount = false
        
        if cdSellCount == 7
            if high >= cdSellBar5Close // 8 vs 5 Deferral
                advanceCount := true
        else if cdSellCount == 12
            if high >= cdSellBar8Close // 13 vs 8 Deferral
                advanceCount := true
        else
            advanceCount := true
            
        if advanceCount
            cdSellCount += 1
            
            if cdSellCount == 5
                cdSellBar5Close := close
            if cdSellCount == 8
                cdSellBar8Close := close
                
            if cdSellCount == 13
                cdSellActive := false 
                label.new(bar_index, high, text="13\n", style=label.style_label_down, textcolor=colSellCD, color=color.new(color.white,100), size=size.normal)
                
                // Risk Line & 12X Tracker
                float riskLevel = cdSellHighestTH + cdSellTRAtMax
                line.new(bar_index, riskLevel, bar_index + 12, riskLevel, color=colRisk, style=line.style_dotted, width=2)
            else
                label.new(bar_index, high, text=str.tostring(cdSellCount) + "\n", style=label.style_label_down, textcolor=colSellCD, color=color.new(color.white,100), size=size.small)
        else
            if cdSellCount == 12
                label.new(bar_index, high, text="+\n", style=label.style_label_down, textcolor=colSellCD, color=color.new(color.white,100), size=size.small)
````
