# Structured Head and Shoulder Pattern (MastersinMarkets)

- url: https://www.tradingview.com/script/xEMi8od2-Structured-Head-and-Shoulder-Pattern-MastersinMarkets/
- type: indicator
- pine_id: PUB;e9c8b79893dc4235aa01ca092f857faf
- version: 1.0

## Description

[]Overview

This proprietary indicator automates the detection of classic Head and Shoulders (H&S) and Inverse Head and Shoulders patterns using a rigorous structural approach. Designed for traders who prioritize geometric symmetry and statistical quality, it filters out "noisy" or low-probability formations that often lead to false breakouts.

[]Core Logic 

The script utilizes a multi-stage validation engine to confirm pattern integrity:

[*]Pivot Analysis: Identifies high-fidelity swing points using a configurable "Swing Strength" to ensure only significant market turns are considered.

[*][/list]Symmetry Scoring: A proprietary algorithm evaluates patterns based on price symmetry (Shoulder height similarity), time symmetry (duration between peaks), and neckline slope.

[*][/list]ATR Volatility Scaling: The "Min Pattern Size" filter ensures the pattern is large enough relative to current market volatility to be considered structurally significant.

[]Key Features

[*][/list]Dynamic Quality Score: Every detected pattern is assigned a score (0–100). Only those meeting your "Min Quality Threshold" are displayed, helping you focus on high-probability setups.

[*][/list]Flexible Necklines: Allows for both horizontal and sloping necklines with a "Max Slope" constraint to maintain structural validity.

[*][/list]Visual Structure Mapping: Automatically plots the connecting lines of the pattern and extends the neckline for clear breakout monitoring.

[*][/list]Real-time Alerts: Integrated alerts trigger the moment a validated pattern completes its Right Shoulder.

[]How It Works

[*][/list]Detection: The script looks for a sequence of five swing points (High-Low-High-Low-High for bearish setups).

[*][/list]Validation: It checks if the "Head" is higher than both "Shoulders" and if the distance between swings meets the minimum bar count.

[*][/list]Scoring: It calculates the $Price\_Symmetry$, [symbol="AMEX:TIME"]AMEX:TIME[/symbol]\_Ratio$, and $Slope\_Score$.

[*][/list]Execution: If the cumulative score exceeds the user-defined threshold (e.g., 60), the pattern is drawn on the chart.

[]Disclaimer

Trading involves significant risk. This indicator is a tool for technical analysis and does not constitute financial advice. Past performance, including high-quality symmetry scores, does not guarantee future results. Always use proper risk management and consider market context before executing trades.

## Source Code

````pine
//@version=5
indicator("Structured Head and Shoulder Pattern(MastersinMarkets)", overlay=true, max_lines_count=500, max_labels_count=500)

// --- User Inputs ---
grp_swing = "Swing Detection"
swingStrength = input.int(1, "Swing Strength", minval=1, group=grp_swing)
minSwingDist  = input.int(5, "Min Bars Between Swings", minval=1, group=grp_swing)

grp_val = "Pattern Validation"
shoulderTolerance   = input.float(0.02, "Shoulder Symmetry Tolerance", minval=0.0, step=0.01, group=grp_val)
minSizeATR          = input.float(1.5, "Min Pattern Size (ATR Multiplier)", minval=0.1, group=grp_val)
maxSlopeDeg         = input.float(30.0, "Max Neckline Slope (Degrees)", minval=0.0, group=grp_val)
allowDescendingNeck = input.bool(true, "Allow Sloping Neckline", group=grp_val)
minScoreThreshold   = input.float(60.0, "Min Quality Score (0-100)", minval=0.0, maxval=100.0, group=grp_val)

grp_vis = "Visualization"
showNeckline = input.bool(true, "Show Neckline Line", group=grp_vis)
alertNew     = input.bool(true, "Alert on New Pattern", group=grp_vis)

// --- Corrected Type Definition ---
type SwingPoint
    int index
    float price
    bool isHigh

type HSPattern
    bool isBearish
    int lsIdx
    float lsPrice
    int headIdx
    float headPrice
    int rsIdx
    float rsPrice
    int n1Idx
    float n1Price
    int n2Idx
    float n2Price
    float nSlope
    float nIntercept
    float score

// Arrays to store swings
var SwingPoint[] allSwings = array.new<SwingPoint>()
atr = ta.atr(14)

// --- Pivot Detection ---
ph = ta.pivothigh(high, swingStrength, swingStrength)
pl = ta.pivotlow(low, swingStrength, swingStrength)

if not na(ph)
    array.push(allSwings, SwingPoint.new(bar_index - swingStrength, ph, true))
if not na(pl)
    array.push(allSwings, SwingPoint.new(bar_index - swingStrength, pl, false))

if array.size(allSwings) > 50
    array.remove(allSwings, 0)

// --- Scoring Function ---
computeScore(HSPattern pat, float atrVal) =>
    float score = 0.0
    // 1. Price Symmetry
    priceDiff = math.abs(pat.lsPrice - pat.rsPrice) / pat.headPrice
    priceSym = math.max(0.0, 1.0 - priceDiff / shoulderTolerance)
    score += priceSym * 30.0
    
    // 2. Time Symmetry
    leftDist = pat.headIdx - pat.lsIdx
    rightDist = pat.rsIdx - pat.headIdx
    timeRatio = leftDist > 0 and rightDist > 0 ? math.min(leftDist, rightDist) / math.max(leftDist, rightDist) : 0
    score += timeRatio * 20.0
    
    // 3. Slope Score
    slopeDeg = math.abs(math.atan(pat.nSlope) * 180 / math.pi)
    if slopeDeg <= maxSlopeDeg
        score += 20.0 * (1.0 - slopeDeg / maxSlopeDeg)
        
    // 4. Size Score
    neckAtHead = pat.nSlope * pat.headIdx + pat.nIntercept
    height = math.abs(pat.headPrice - neckAtHead)
    sizeRatio = height / (atrVal > 0 ? atrVal : syminfo.mintick)
    sizeScore = math.min(30.0, (sizeRatio / minSizeATR) * 30.0)
    score += sizeScore
    math.min(100.0, score)

// --- Pattern Detection ---
if array.size(allSwings) >= 5 and (not na(ph) or not na(pl))
    int sz = array.size(allSwings)
    SwingPoint s0 = array.get(allSwings, sz-5)
    SwingPoint s1 = array.get(allSwings, sz-4)
    SwingPoint s2 = array.get(allSwings, sz-3)
    SwingPoint s3 = array.get(allSwings, sz-2)
    SwingPoint s4 = array.get(allSwings, sz-1)
    
    bool isBearish = false
    bool found = false
    
    // Bearish H&S: High-Low-High-Low-High
    if s0.isHigh and not s1.isHigh and s2.isHigh and not s3.isHigh and s4.isHigh
        if s2.price > s0.price and s2.price > s4.price and s4.index - s0.index >= minSwingDist
            isBearish := true
            found := true
    // Bullish Inv H&S: Low-High-Low-High-Low
    else if not s0.isHigh and s1.isHigh and not s2.isHigh and s3.isHigh and not s4.isHigh
        if s2.price < s0.price and s2.price < s4.price and s4.index - s0.index >= minSwingDist
            isBearish := false
            found := true
            
    if found
        float slope = (s3.price - s1.price) / (s3.index - s1.index)
        float intercept = s1.price - slope * s1.index
        float neckAtHead = slope * s2.index + intercept
        float patHeight = math.abs(s2.price - neckAtHead)
        
        if patHeight >= minSizeATR * atr and (allowDescendingNeck or (isBearish ? slope < 0 : slope > 0))
            HSPattern pat = HSPattern.new(isBearish, s0.index, s0.price, s2.index, s2.price, s4.index, s4.price, s1.index, s1.price, s3.index, s3.price, slope, intercept, 0.0)
            pat.score := computeScore(pat, atr)
            
            if pat.score >= minScoreThreshold
                // Draw Structure
                line.new(s0.index, s0.price, s1.index, s1.price, color=color.gray)
                line.new(s1.index, s1.price, s2.index, s2.price, color=color.gray)
                line.new(s2.index, s2.price, s3.index, s3.price, color=color.gray)
                line.new(s3.index, s3.price, s4.index, s4.price, color=color.gray)
                
                if showNeckline
                    line.new(s1.index, s1.price, s3.index, s3.price, color=color.white, width=2, extend=extend.right)
                
                label.new(s2.index, s2.price, text=(isBearish ? "H&S\n" : "Inv H&S\n") + str.tostring(pat.score, "#.##"), 
                     color=isBearish ? color.red : color.green, textcolor=color.white, style=isBearish ? label.style_label_down : label.style_label_up)
                
                if alertNew
                    alert("Pattern Found! Score: " + str.tostring(pat.score, "#.##"), alert.freq_once_per_bar)
````
