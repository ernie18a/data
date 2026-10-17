# 2-Click Pip Calculator

- url: https://www.tradingview.com/script/f0AxjSjX-2-Click-Pip-Calculator/
- type: indicator
- pine_id: PUB;b0fe83a54fe6484c81df0968bf8c9f7f
- version: 1.0

## Description

Title Idea: 2-Click Interactive Pip Ruler (Clean & Fast)

Description:
This script acts as a fast, interactive vertical caliper. It strips out the time-axis requirements completely, dropping the tool down to just two clicks (Y-Axis only).

How to Use It:

Add the indicator to your chart.

The prompt will ask you to select two points.

Click 1: Click anywhere on the horizontal plane of your start price (e.g., a swing high).

Click 2: Click anywhere on the horizontal plane of your target price (e.g., a swing low).

The script instantly drops a clean, vertical measurement line at the hard right edge of your chart, displaying the exact pip distance between those two levels.

Key Features:

Zero Chart Clutter: No diagonal anchor lines or historical time markers dragging across your screen.

Forex Auto-Scaling: Automatically detects if you are on a Forex pair and multiplies the tick size by 10 to give you standard Pips. If you are on an index or crypto, it defaults to standard ticks/points.

Instant HUD: The pip label is locked cleanly to the right side of the measurement line with a semi-transparent background so it never gets lost in your candles.

## Source Code

````pine
//@version=5
indicator("2-Click Pip Calculator", overlay=true)

// --- INTERACTIVE INPUTS (PRICE ONLY) ---
// The script now ONLY asks for the Y-Axis (Price) levels
p1 = input.price(0, "First Price", confirm=true)
p2 = input.price(0, "Second Price", confirm=true)

// --- PIP CALCULATION LOGIC ---
pipMultiplier = syminfo.type == "forex" ? 10 : 1
pipSize = syminfo.mintick * pipMultiplier
pipDistance = math.abs(p1 - p2) / pipSize

// --- DRAWING LOGIC ---
if barstate.islast
    // Shift drawing slightly to the right of the current candle for a clean look
    int offset = 5
    
    // Draw the vertical measuring line
    line.new(bar_index + offset, p1, bar_index + offset, p2, color=color.new(color.white, 50), width=2, style=line.style_dashed)
    
    // Draw horizontal caps to clearly mark the exact price levels (like a ruler)
    line.new(bar_index + offset - 1, p1, bar_index + offset + 1, p1, color=color.white, width=2)
    line.new(bar_index + offset - 1, p2, bar_index + offset + 1, p2, color=color.white, width=2)
    
    // Calculate the midpoint for the label
    float midPrice = (p1 + p2) / 2
    labelText = str.tostring(pipDistance, "#.1") + " Pips"
    
    // Draw the label locked to the right side of the vertical line
    label.new(bar_index + offset, midPrice, text=labelText, style=label.style_label_left, color=color.new(color.black, 40), textcolor=color.white, size=size.normal)
````
