# thiru2547@

- url: https://www.tradingview.com/script/ZlgFQEi7-thiru2547/
- type: indicator
- pine_id: PUB;41c2d5b73e9c43de8d5d5d9d4a76051d
- version: 1.0

## Description

### Overview
The Elliott Wave Fibonacci Targets indicator is designed to streamline your Elliott Wave analysis by automatically identifying key price pivot highs and lows on your chart. Based on these detected pivots, the script calculates and displays potential target price levels for Waves 2, 3, 4, and 5 using standard Fibonacci retracement and extension ratios.

### Key Features
1. Customizable Pivot Detection: Easily adjust the "Pivot Left Bars" and "Pivot Right Bars" inputs to fine-tune pivot sensitivity for different timeframes and market conditions.
2. Automated Fibonacci Target Calculations:
   - Wave 2: Standard 61.8% and 78.6% retracements of Wave 1.
   - Wave 3: 161.8% Fibonacci extension based on Wave 1 height.
   - Wave 4: 38.2% retracement level of Wave 3.
   - Wave 5: 61.8% extension calculated relative to Wave 3.
3. Clean On-Chart Summary: Displays all active targets in a clean, easily readable label on the most recent chart bar, keeping your chart uncluttered.

### How to Use
- Add the indicator to your desired chart and timeframe.
- Use the target output label to quickly evaluate potential support, resistance, or profit-target levels according to your Elliott Wave structure analysis.
- Adjust the input parameters in the settings panel to match short-term swing trading or long-term trend analysis.

Disclaimer: This script is intended for informational and educational purposes only and should not be considered financial advice. Always combine technical indicators with your own risk management strategy.

## Source Code

````pine
//@version=6
indicator("Elliott Wave Full Impulse (0 to 5)", overlay=true, max_labels_count=500, max_lines_count=500)

// --- Inputs ---
leftBars     = input.int(5, title="Pivot Left Bars")
rightBars    = input.int(5, title="Pivot Right Bars")
showWaveLines= input.bool(true, title="Show Wave Structure Lines (0-1-2-3-4-5)")
showLabels   = input.bool(true, title="Show Wave Labels (0 to 5)")

// --- Pivot Detection ---
pHi = ta.pivothigh(high, leftBars, rightBars)
pLo = ta.pivotlow(low, leftBars, rightBars)

// Wave points tracking: 0, 1, 2, 3, 4, 5
var float p0_price = na
var int   p0_bar   = na
var float p1_price = na
var int   p1_bar   = na
var float p2_price = na
var int   p2_bar   = na
var float p3_price = na
var int   p3_bar   = na
var float p4_price = na
var int   p4_bar   = na
var float p5_price = na
var int   p5_bar   = na

// Strict Alternating Pivot State Machine for Impulse Wave (0-1-2-3-4-5)
if not na(pLo)
    float lPrice = low[rightBars]
    int lBar     = bar_index - rightBars
    if na(p0_price) or (not na(p1_price) and not na(p2_price) and not na(p3_price) and not na(p4_price) and not na(p5_price))
        p0_price := lPrice
        p0_bar   := lBar
        p1_price := na
        p2_price := na
        p3_price := na
        p4_price := na
        p5_price := na
    else if not na(p1_price) and na(p2_price)
        p2_price := lPrice
        p2_bar   := lBar
    else if not na(p3_price) and na(p4_price)
        p4_price := lPrice
        p4_bar   := lBar

if not na(pHi)
    float hPrice = high[rightBars]
    int hBar     = bar_index - rightBars
    if not na(p0_price) and na(p1_price)
        p1_price := hPrice
        p1_bar   := hBar
    else if not na(p2_price) and na(p3_price)
        p3_price := hPrice
        p3_bar   := hBar
    else if not na(p4_price) and na(p5_price)
        p5_price := hPrice
        p5_bar   := hBar

// --- Plotting Wave Structure Lines & Labels ---
var line l_01 = na
var line l_12 = na
var line l_23 = na
var line l_34 = na
var line l_45 = na

var label lbl_0 = na
var label lbl_1 = na
var label lbl_2 = na
var label lbl_3 = na
var label lbl_4 = na
var label lbl_5 = na

if barstate.islast
    if not na(l_01) 
        line.delete(l_01)
    if not na(l_12) 
        line.delete(l_12)
    if not na(l_23) 
        line.delete(l_23)
    if not na(l_34) 
        line.delete(l_34)
    if not na(l_45) 
        line.delete(l_45)
    
    if not na(lbl_0) 
        label.delete(lbl_0)
    if not na(lbl_1) 
        label.delete(lbl_1)
    if not na(lbl_2) 
        label.delete(lbl_2)
    if not na(lbl_3) 
        label.delete(lbl_3)
    if not na(lbl_4) 
        label.delete(lbl_4)
    if not na(lbl_5) 
        label.delete(lbl_5)

    if showWaveLines
        if not na(p0_bar) and not na(p1_bar)
            l_01 := line.new(p0_bar, p0_price, p1_bar, p1_price, color=color.green, width=2)
        if not na(p1_bar) and not na(p2_bar)
            l_12 := line.new(p1_bar, p1_price, p2_bar, p2_price, color=color.red, width=2)
        if not na(p2_bar) and not na(p3_bar)
            l_23 := line.new(p2_bar, p2_price, p3_bar, p3_price, color=color.green, width=2)
        if not na(p3_bar) and not na(p4_bar)
            l_34 := line.new(p3_bar, p3_price, p4_bar, p4_price, color=color.red, width=2)
        if not na(p4_bar) and not na(p5_bar)
            l_45 := line.new(p4_bar, p4_price, p5_bar, p5_price, color=color.green, width=2)

    if showLabels
        if not na(p0_bar)
            lbl_0 := label.new(p0_bar, p0_price, text="0", style=label.style_label_up, color=color.gray, textcolor=color.white)
        if not na(p1_bar)
            lbl_1 := label.new(p1_bar, p1_price, text="1", style=label.style_label_down, color=color.green, textcolor=color.white)
        if not na(p2_bar)
            lbl_2 := label.new(p2_bar, p2_price, text="2", style=label.style_label_up, color=color.red, textcolor=color.white)
        if not na(p3_bar)
            lbl_3 := label.new(p3_bar, p3_price, text="3", style=label.style_label_down, color=color.green, textcolor=color.white)
        if not na(p4_bar)
            lbl_4 := label.new(p4_bar, p4_price, text="4", style=label.style_label_up, color=color.red, textcolor=color.white)
        if not na(p5_bar)
            lbl_5 := label.new(p5_bar, p5_price, text="5", style=label.style_label_down, color=color.green, textcolor=color.white)
````
