# Fake Breakout Reversal High/Low PRO [JPT]

- url: https://www.tradingview.com/script/4GVV3LRM-Fake-Breakout-Reversal-High-Low-PRO-JPT/
- type: indicator
- pine_id: PUB;cdb6ed78f3b94845a0c463327460386a
- version: 3.0

## Description

🔹 [b]OVERVIEW[/b]

[b]Fake Breakout Reversal High/Low PRO [JPT][/b] is an educational technical analysis indicator designed to identify potential fake breakout areas around confirmed swing highs and swing lows.

The script highlights price movements that briefly trade beyond a recent swing level before returning back within the prior range. It also plots dynamic swing levels and provides a visual framework for studying potential reversal scenarios.

This indicator is intended to help traders observe price structure and market behavior. It does not predict future price movement or guarantee trading outcomes.

━━━━━━━━━━━━━━━━━━

🔹 [b]FEATURES[/b]

• Automatic Swing High & Swing Low detection
• Fake breakout identification
• Dynamic High & Low reference levels
• Breakout range visualization
• Bullish and bearish reversal zones
• Clean chart layout
• Configurable swing sensitivity
• Alert conditions for detected events

━━━━━━━━━━━━━━━━━━

🔹 [b]HOW IT WORKS[/b]

• Detects confirmed swing highs and swing lows.
• Monitors whether price temporarily breaks beyond a swing level.
• Highlights potential fake breakout areas when price returns back within the previous structure.
• Updates reference levels as new confirmed swings form.

━━━━━━━━━━━━━━━━━━

🔹 [b]INPUTS[/b]

• Swing Length
• Confirmation Settings
• Display Options
• Color Customization
• Alert Controls

━━━━━━━━━━━━━━━━━━

🔹 [b]NOTES[/b]

• Designed for educational and technical analysis purposes.
• Uses confirmed price action and does not rely on future bars.
• Signals should be evaluated together with overall market structure and personal risk management.
• No technical indicator can guarantee future market performance.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator("Fake Breakout Reversal High/Low PRO [JPT] - Module 1 Core Engine",
     overlay = true,
     max_lines_count = 300,
     max_labels_count = 200)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pivotLen      = input.int(5, "Pivot Strength", minval = 2)
extendLevels  = input.bool(false, "Extend Swing Levels")
showLabels    = input.bool(true, "Show Swing Labels")
showLevels    = input.bool(true, "Show Swing Levels")
maxLevels     = input.int(20, "Maximum Stored Levels", minval = 5, maxval = 100)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PIVOTS (Confirmed - Non Repainting)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow  = ta.pivotlow(low, pivotLen, pivotLen)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STORAGE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var float lastSwingHigh = na
var float lastSwingLow  = na

var int lastHighBar = na
var int lastLowBar  = na

// Arrays for lines
var line[] highLines = array.new_line()
var line[] lowLines  = array.new_line()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SWING HIGH
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if not na(pivotHigh)

    lastSwingHigh := pivotHigh
    lastHighBar := bar_index - pivotLen

    if showLevels
        l = line.new(
             lastHighBar,
             lastSwingHigh,
             bar_index,
             lastSwingHigh,
             color=color.red,
             width=2,
             extend=extendLevels ? extend.right : extend.none)

        array.push(highLines, l)

        if array.size(highLines) > maxLevels
            old = array.shift(highLines)
            line.delete(old)

    if showLabels
        label.new(
             lastHighBar,
             lastSwingHigh,
             "Swing High",
             style=label.style_label_down,
             color=color.red,
             textcolor=color.white,
             size=size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SWING LOW
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if not na(pivotLow)

    lastSwingLow := pivotLow
    lastLowBar := bar_index - pivotLen

    if showLevels
        l = line.new(
             lastLowBar,
             lastSwingLow,
             bar_index,
             lastSwingLow,
             color=color.lime,
             width=2,
             extend=extendLevels ? extend.right : extend.none)

        array.push(lowLines, l)

        if array.size(lowLines) > maxLevels
            old = array.shift(lowLines)
            line.delete(old)

    if showLabels
        label.new(
             lastLowBar,
             lastSwingLow,
             "Swing Low",
             style=label.style_label_up,
             color=color.green,
             textcolor=color.white,
             size=size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CURRENT SWING PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(lastSwingHigh, title="Current Swing High", color=color.red, linewidth=2, style=plot.style_linebr)
plot(lastSwingLow, title="Current Swing Low", color=color.lime, linewidth=2, style=plot.style_linebr)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OUTPUT VARIABLES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

isAboveSwingHigh = not na(lastSwingHigh) and high > lastSwingHigh
isBelowSwingLow  = not na(lastSwingLow) and low < lastSwingLow

plotshape(isAboveSwingHigh,
     title="High Broken",
     style=shape.circle,
     location=location.abovebar,
     color=color.red,
     size=size.tiny)

plotshape(isBelowSwingLow,
     title="Low Broken",
     style=shape.circle,
     location=location.belowbar,
     color=color.green,
     size=size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MODULE 2 — STRONG / WEAK SWING DETECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Inputs
atrLen      = input.int(14, "ATR Length", group="Swing Strength")
atrFactor   = input.float(1.0, "ATR Strength", step=0.1, group="Swing Strength")
wickFactor  = input.float(0.40, "Min Wick %", step=0.05, group="Swing Strength")
bodyFactor  = input.float(0.50, "Min Body %", step=0.05, group="Swing Strength")

atr = ta.atr(atrLen)

// Candle calculations
bodySize  = math.abs(close - open)
rangeSize = high - low

upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

bodyPercent  = rangeSize > 0 ? bodySize / rangeSize : 0
upperPercent = rangeSize > 0 ? upperWick / rangeSize : 0
lowerPercent = rangeSize > 0 ? lowerWick / rangeSize : 0

// Previous swings
var float prevSwingHigh = na
var float prevSwingLow  = na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SWING HIGH STRENGTH
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if not na(pivotHigh)

    distance = na(prevSwingHigh) ? atr : math.abs(pivotHigh - prevSwingHigh)

    score = 0

    if distance > atr * atrFactor
        score += 1

    if upperPercent > wickFactor
        score += 1

    if bodyPercent > bodyFactor
        score += 1

    string txt = score == 3 ? "Strong High" :
                 score == 2 ? "Normal High" :
                              "Weak High"

    color lblColor = score == 3 ? color.red :
                     score == 2 ? color.orange :
                                  color.gray

    label.new(
         bar_index - pivotLen,
         pivotHigh,
         txt,
         style=label.style_label_down,
         color=lblColor,
         textcolor=color.white,
         size=size.tiny)

    prevSwingHigh := pivotHigh

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SWING LOW STRENGTH
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if not na(pivotLow)

    distance = na(prevSwingLow) ? atr : math.abs(pivotLow - prevSwingLow)

    score = 0

    if distance > atr * atrFactor
        score += 1

    if lowerPercent > wickFactor
        score += 1

    if bodyPercent > bodyFactor
        score += 1

    string txt = score == 3 ? "Strong Low" :
                 score == 2 ? "Normal Low" :
                              "Weak Low"

    color lblColor = score == 3 ? color.lime :
                     score == 2 ? color.yellow :
                                  color.gray

    label.new(
         bar_index - pivotLen,
         pivotLow,
         txt,
         style=label.style_label_up,
         color=lblColor,
         textcolor=color.black,
         size=size.tiny)

    prevSwingLow := pivotLow
````
