# False Breakouts

- url: https://www.tradingview.com/script/uTcKcZmL-false-breakouts/
- type: indicator
- pine_id: PUB;cbd0eea6590f43089232a934f613400a
- version: 1.0

## Description

Indicator that detects the three types of false breakouts

Here's how the script works:

1.Defining Levels: The script uses Pivot Highs for resistance levels and Pivot Lows for support levels. You can adjust the "Pivot Left Length" and "Pivot Right Length" in the settings to define how significant a level needs to be.

2.Simple False Breakout (Single Bar): A shape is plotted when the price wicks through a level (high breaks resistance or low breaks support) but manages to close back on the previous side.

3.Two-Bar False Breakout: Plotted when a candle breaks and closes past a level, but the very next candle reverses and closes back inside the previous boundary.

4.Multi-Bar False Breakout: Plotted when the price breaks and holds beyond a level for a few bars (up to a limit set by the Max Hold Bars input) before sharply reversing and closing back inside.
The script visually maps the active support and resistance levels using dashed gray lines, and false breakouts are labeled with distinct shapes and color variations to distinguish whether they are single, two-bar, or multi-bar occurrences.

 Have added RSI confirmation to the indicator's logic!

Here is what was updated:

RSI Settings: You will now see a new "RSI Confirmation" group in the indicator settings. This allows you to enable or disable the RSI check, as well as adjust the RSI Length, Overbought, and Oversold levels.
Confirmation Logic:
-If enabled, a Bearish False Breakout will only be flagged if the RSI value on the signal bar is greater than or equal to the Overbought level (default 70).
-A Bullish False Breakout will only be flagged if the RSI value is less than or equal to the Oversold level (default 30).
-If you disable the "Require RSI Confirmation" setting, it will behave exactly as it did before.

## Source Code

````pine
//@version=6
indicator("False Breakouts", overlay = true, max_labels_count = 500)

// --- Group: Pivot Settings ---
leftLen = input.int(15, "Pivot Left Length", group="Pivot Settings", tooltip="Number of bars to the left to confirm a pivot.")
rightLen = input.int(15, "Pivot Right Length", group="Pivot Settings", tooltip="Number of bars to the right to confirm a pivot.")
maxHoldBars = input.int(5, "Max Hold Bars (Multi-Bar)", minval=2, group="Breakout Settings", tooltip="Maximum number of bars the price can hold beyond a level before returning to be considered a multi-bar false breakout.")

// --- Group: RSI Confirmation Settings ---
useRsi = input.bool(true, "Require RSI Confirmation", group="RSI Confirmation", tooltip="If enabled, bearish false breakouts require RSI to be above the overbought level, and bullish false breakouts require RSI to be below the oversold level.")
rsiLen = input.int(14, "RSI Length", group="RSI Confirmation")
rsiOb  = input.int(70, "RSI Overbought", group="RSI Confirmation")
rsiOs  = input.int(30, "RSI Oversold", group="RSI Confirmation")

// Colors
colorBear1 = input.color(color.new(#f23645, 0), "Bearish Single-Bar", group="Style")
colorBear2 = input.color(color.new(#b22833, 0), "Bearish Two-Bar", group="Style")
colorBearM = input.color(color.new(#7a1b22, 0), "Bearish Multi-Bar", group="Style")

colorBull1 = input.color(color.new(#089981, 0), "Bullish Single-Bar", group="Style")
colorBull2 = input.color(color.new(#056858, 0), "Bullish Two-Bar", group="Style")
colorBullM = input.color(color.new(#033c33, 0), "Bullish Multi-Bar", group="Style")

// --- Core Logic ---
// RSI Calculation
rsiVal = ta.rsi(close, rsiLen)
bearRsiOk = not useRsi or rsiVal >= rsiOb
bullRsiOk = not useRsi or rsiVal <= rsiOs

// Pivot Highs (Resistance)
ph = ta.pivothigh(high, leftLen, rightLen)
var float resLevel = na
if not na(ph)
    resLevel := ph

// Pivot Lows (Support)
pl = ta.pivotlow(low, leftLen, rightLen)
var float supLevel = na
if not na(pl)
    supLevel := pl

// Track breakout state for resistance
var bool resBroken = false
var int resBarsAbove = 0

// Track breakout state for support
var bool supBroken = false
var int supBarsBelow = 0

// Bearish False Breakout Logic
isBearFB1 = false
isBearFB2 = false
isBearFBM = false

if not na(resLevel)
    // Type 1: Single Bar Wick (Price pierces resistance but closes below)
    if high > resLevel and close < resLevel
        // Ensure the previous close was also below the level to distinguish from a drop back
        if close[1] < resLevel and not resBroken and bearRsiOk
            isBearFB1 := true
            
    // State tracking for Type 2 and Multi-Bar
    if close > resLevel and close[1] <= resLevel
        resBroken := true
        resBarsAbove := 1
    else if resBroken and close > resLevel
        resBarsAbove += 1
    
    if resBroken and close < resLevel
        if resBarsAbove == 1 and bearRsiOk
            isBearFB2 := true
        else if resBarsAbove <= maxHoldBars and bearRsiOk
            isBearFBM := true
        
        // Reset state after returning below the level
        resBroken := false
        resBarsAbove := 0

// Bullish False Breakout Logic
isBullFB1 = false
isBullFB2 = false
isBullFBM = false

if not na(supLevel)
    // Type 1: Single Bar Wick (Price pierces support but closes above)
    if low < supLevel and close > supLevel
        if close[1] > supLevel and not supBroken and bullRsiOk
            isBullFB1 := true
            
    // State tracking for Type 2 and Multi-Bar
    if close < supLevel and close[1] >= supLevel
        supBroken := true
        supBarsBelow := 1
    else if supBroken and close < supLevel
        supBarsBelow += 1
        
    if supBroken and close > supLevel
        if supBarsBelow == 1 and bullRsiOk
            isBullFB2 := true
        else if supBarsBelow <= maxHoldBars and bullRsiOk
            isBullFBM := true
            
        // Reset state after returning above the level
        supBroken := false
        supBarsBelow := 0

// --- Visualization ---
// Plot Resistance & Support lines for visual reference
var line resLine = na
var line supLine = na

if not na(ph)
    resLine := line.new(bar_index - rightLen, ph, bar_index, ph, color=color.gray, style=line.style_dashed)
else if not na(resLine)
    line.set_x2(resLine, bar_index)

if not na(pl)
    supLine := line.new(bar_index - rightLen, pl, bar_index, pl, color=color.gray, style=line.style_dashed)
else if not na(supLine)
    line.set_x2(supLine, bar_index)

// Plot Shapes for False Breakouts
plotshape(isBearFB1, "Bearish Simple FB", shape.triangledown, location.abovebar, colorBear1, size=size.small)
plotshape(isBearFB2, "Bearish Two-Bar FB", shape.triangledown, location.abovebar, colorBear2, size=size.small)
plotshape(isBearFBM, "Bearish Multi-Bar FB", shape.triangledown, location.abovebar, colorBearM, size=size.small)

plotshape(isBullFB1, "Bullish Simple FB", shape.triangleup, location.belowbar, colorBull1, size=size.small)
plotshape(isBullFB2, "Bullish Two-Bar FB", shape.triangleup, location.belowbar, colorBull2, size=size.small)
plotshape(isBullFBM, "Bullish Multi-Bar FB", shape.triangleup, location.belowbar, colorBullM, size=size.small)
````
