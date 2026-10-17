# High / Low Resistance Liquidity Trend

- url: https://www.tradingview.com/script/FdTWzMfJ-High-Low-Resistance-Liquidity-Trend/
- type: indicator
- pine_id: PUB;bbfb05f8564d41909e09cd69a43fe8d8
- version: 2.0

## Description

Description

This indicator is a powerful, algorithmic tool designed for HRLR methodologies. It removes the subjectivity of identifying High Resistance Liquidity Runs (HRLR) and Low Resistance Liquidity Runs (LRLR) by dynamically mapping out the structural flow of liquidity on your chart using clean, point-to-point trendlines.

🎯 Core Concepts
In this methodology, understanding whether price will face "resistance" when drawing to a liquidity pool is critical for trade management:

Low Resistance Liquidity (LRLR): Clean, engineered liquidity. When price fails to sweep a previous structural extreme, it leaves behind smooth, resting stop-losses. This acts as a frictionless magnet for price.
High Resistance Liquidity (HRLR): Swept liquidity. When price violently takes out a previous extreme and reverses, it purges the local stop-losses. Returning to this level is a "High Resistance" run because the liquidity fuel has already been burned.

⚙️ How It Works
The script evaluates price action in real-time, detecting structural Pivot Highs and Pivot Lows. It then dynamically draws trendlines connecting adjacent pivots to reveal the underlying liquidity texture:

🟢 LRLR (Green Lines) - Failed Sweeps:
Highs: Connects a Pivot High to a subsequent Lower High.
Lows: Connects a Pivot Low to a subsequent Higher Low.
Signal: Clean trendline liquidity is building. Expect a fast, low-resistance run through this level.

🔴 HRLR (Red Lines) - Liquidity Sweeps:
Highs: Connects a Pivot High to a subsequent Higher High.
Lows: Connects a Pivot Low to a subsequent Lower Low.
Signal: A Turtle Soup / Sweep has occurred. Price may struggle to break this extreme cleanly.

✨ Visual Polish
This indicator is built with extreme attention to aesthetic detail. Rather than messy labels cluttering the wicks, the text (LRLR / HRLR) is mathematically positioned at the exact midpoint of the connecting trendlines. It features a custom Label Masking engine that dynamically cuts out the line exactly where the text sits, providing a stunning, ultra-clean look. (Note: Use the 'Chart Background Color' setting to ensure the label mask matches your specific TradingView theme).

🔧 Settings
Pivot Left/Right Bars: Fully customize the structural lookback to define exactly what constitutes a valid swing high/low for your timeframe.
Visual Customization: Full control over colors and text labels.
Chart Background Mask: Allows you to swap the label cutout color between Light Mode and Dark Mode backgrounds flawlessly.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

//@version=6
indicator("High / Low Resistance Liquidity Trend", shorttitle="HR / LR Liquidity Trend", overlay=true, max_lines_count=500, max_labels_count=500)

// --- Settings ---
grp_pivots = "Pivot & Structure Settings"
pivotLeft  = input.int(5, "Pivot Left Bars", minval=1, group=grp_pivots)
pivotRight = input.int(5, "Pivot Right Bars", minval=1, group=grp_pivots)

grp_visuals = "Display & Visuals"
colLRLR            = input.color(color.new(#4CAF50, 0), "LRLR Color (Green)", group=grp_visuals)
colHRLR            = input.color(color.new(#F44336, 0), "HRLR Color (Red)", group=grp_visuals)
bgMaskColor        = input.color(color.new(#131722, 0), "Chart Background Color (For Label Masking)", group=grp_visuals, tooltip="Set this to match your chart's background color. This ensures the text has a clean cutout over the lines.")
showLabels         = input.bool(true, "Show Text Labels", group=grp_visuals)

// --- Track Historical Pivots ---
var array<float> phHistory = array.new<float>()
var array<int>   phBars    = array.new<int>()

var array<float> plHistory = array.new<float>()
var array<int>   plBars    = array.new<int>()

// --- Pivot Detection ---
float ph = ta.pivothigh(high, pivotLeft, pivotRight)
float pl = ta.pivotlow(low, pivotLeft, pivotRight)

bool newPH = not na(ph)
bool newPL = not na(pl)

// The bar index where the pivot ACTUALLY occurred
int phBar = bar_index - pivotRight
int plBar = bar_index - pivotRight

// --- Evaluate New Pivot Highs ---
if newPH
    if array.size(phHistory) > 0
        float lastPH = array.get(phHistory, array.size(phHistory) - 1)
        int lastPHBar = array.get(phBars, array.size(phBars) - 1)
        
        color  lineCol = na
        string lblTxt  = ""
        
        // A lower high (failed to sweep) = LRLR
        if ph <= lastPH
            lineCol := colLRLR
            lblTxt  := "LRLR"
        // A higher high (swept) = HRLR
        else if ph > lastPH
            lineCol := colHRLR
            lblTxt  := "HRLR"
            
        // Draw connecting trendline
        line.new(lastPHBar, lastPH, phBar, ph, color=lineCol, width=1, style=line.style_solid)
        
        // Draw masking label precisely at midpoint
        if showLabels
            int   midX = math.round(math.avg(lastPHBar, phBar))
            float midY = math.avg(lastPH, ph)
            label.new(
                 x=midX, 
                 y=midY, 
                 text=lblTxt, 
                 color=bgMaskColor, 
                 textcolor=lineCol, 
                 style=label.style_label_center, 
                 size=size.tiny
             )
            
    // Store new pivot
    array.push(phHistory, ph)
    array.push(phBars, phBar)
    if array.size(phHistory) > 500
        array.shift(phHistory)
        array.shift(phBars)

// --- Evaluate New Pivot Lows ---
if newPL
    if array.size(plHistory) > 0
        float lastPL = array.get(plHistory, array.size(plHistory) - 1)
        int lastPLBar = array.get(plBars, array.size(plBars) - 1)
        
        color  lineCol = na
        string lblTxt  = ""
        
        // A higher low (failed to sweep) = LRLR
        if pl >= lastPL
            lineCol := colLRLR
            lblTxt  := "LRLR"
        // A lower low (swept) = HRLR
        else if pl < lastPL
            lineCol := colHRLR
            lblTxt  := "HRLR"
            
        // Draw connecting trendline
        line.new(lastPLBar, lastPL, plBar, pl, color=lineCol, width=1, style=line.style_solid)
        
        // Draw masking label precisely at midpoint
        if showLabels
            int   midX = math.round(math.avg(lastPLBar, plBar))
            float midY = math.avg(lastPL, pl)
            label.new(
                 x=midX, 
                 y=midY, 
                 text=lblTxt, 
                 color=bgMaskColor, 
                 textcolor=lineCol, 
                 style=label.style_label_center, 
                 size=size.tiny
             )
            
    // Store new pivot
    array.push(plHistory, pl)
    array.push(plBars, plBar)
    if array.size(plHistory) > 500
        array.shift(plHistory)
        array.shift(plBars)
````
