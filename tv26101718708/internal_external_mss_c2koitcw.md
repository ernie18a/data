# Internal & External MSS

- url: https://www.tradingview.com/script/C2koITcw-Internal-External-MSS/
- type: indicator
- pine_id: PUB;e3baf0dad3a54e319177cfcc9be8f187
- version: 1.0

## Description

Here is a quick breakdown of what it does and its key features:

Dual Tracking (Internal vs. External): It calculates two different sets of market swings simultaneously. It tracks smaller, short-term price movements (Internal MSS) and larger, structural price movements (External MSS).

Overlap Prevention: To keep your chart clean, if a short-term Internal shift and a long-term External shift occur at the exact same price level, the script is programmed to only draw the more significant External level.

Wick vs. Body Calculation: You can toggle the settings to define market structure using either the extreme highs/lows of the candle wicks, or the real bodies (open/close) of the candles.

Smart Label Placement: Breakout lines are drawn horizontally from the broken swing point, and text labels (like "E-MSS" or "i-MSS") automatically float above or below the lines so they don't collide with the drawings.

Fully Customizable Visuals: Through the settings menu, you can easily change the line colors, thickness, dashed/solid styles, and the exact text used for the labels without needing to edit the code again.

## Source Code

````pine
//@version=6
indicator("Internal & External MSS", overlay=true, max_lines_count=500, max_labels_count=500)

// ========================================================================= //
// 1. INPUTS & SETTINGS
// ========================================================================= //
grp_calc = "Calculation Source"
calcSource = input.string("Wick", title="Calculate using", options=["Wick", "Body"], group=grp_calc)

// Internal (Short) Settings
grp_int = "Internal MSS (Short-Term)"
intLeft   = input.int(3, title="Swing Left Bars", minval=1, group=grp_int)
intRight  = input.int(3, title="Swing Right Bars", minval=1, group=grp_int)
intStyle  = input.string("Dashed", title="Line Style", options=["Solid", "Dashed", "Dotted"], group=grp_int)
intWidth  = input.int(1, title="Line Width", minval=1, maxval=4, group=grp_int)
intLabelText = input.string("i-MSS", title="Internal Label Text", group=grp_int)

// External (Large) Settings
grp_ext = "External MSS (Long-Term)"
extLeft   = input.int(10, title="Swing Left Bars", minval=1, group=grp_ext)
extRight  = input.int(10, title="Swing Right Bars", minval=1, group=grp_ext)
extStyle  = input.string("Solid", title="Line Style", options=["Solid", "Dashed", "Dotted"], group=grp_ext)
extWidth  = input.int(2, title="Line Width", minval=1, maxval=4, group=grp_ext)
extLabelText = input.string("E-MSS", title="External Label Text", group=grp_ext)

// Visuals
grp_vis = "Global Visuals"
lineBull  = input.color(color.green, title="Bullish Break Color", group=grp_vis)
lineBear  = input.color(color.red, title="Bearish Break Color", group=grp_vis)
showLabel = input.bool(true, title="Show Labels", group=grp_vis)

// Helper function for line styles
getLineStyle(str) =>
    switch str
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

myIntStyle = getLineStyle(intStyle)
myExtStyle = getLineStyle(extStyle)

// Determine wick vs body
highSource = calcSource == "Wick" ? high : math.max(close, open)
lowSource  = calcSource == "Wick" ? low  : math.min(close, open)

// ========================================================================= //
// 2. PIVOT DETECTION & STATE UPDATES
// ========================================================================= //
// Calculate all pivots simultaneously to ensure state is accurate before drawing
swh_int = ta.pivothigh(highSource, intLeft, intRight)
swl_int = ta.pivotlow(lowSource, intLeft, intRight)
swh_ext = ta.pivothigh(highSource, extLeft, extRight)
swl_ext = ta.pivotlow(lowSource, extLeft, extRight)

var float lastSwhInt = na
var int   lastSwhBarInt = na
var float lastSwlInt = na
var int   lastSwlBarInt = na
var bool  swh_int_broken = true
var bool  swl_int_broken = true

var float lastSwhExt = na
var int   lastSwhBarExt = na
var float lastSwlExt = na
var int   lastSwlBarExt = na
var bool  swh_ext_broken = true
var bool  swl_ext_broken = true

// Update Internal State
if not na(swh_int)
    lastSwhInt := swh_int
    lastSwhBarInt := bar_index[intRight]
    swh_int_broken := false

if not na(swl_int)
    lastSwlInt := swl_int
    lastSwlBarInt := bar_index[intRight]
    swl_int_broken := false

// Update External State
if not na(swh_ext)
    lastSwhExt := swh_ext
    lastSwhBarExt := bar_index[extRight]
    swh_ext_broken := false

if not na(swl_ext)
    lastSwlExt := swl_ext
    lastSwlBarExt := bar_index[extRight]
    swl_ext_broken := false

// ========================================================================= //
// 3. MARKET STRUCTURE SHIFT LOGIC (Drawing)
// ========================================================================= //

// --- Internal Breakouts ---
if close > lastSwhInt and not swh_int_broken
    swh_int_broken := true
    // Overlap Prevention: Only draw if it's NOT the exact same level as the External swing
    if lastSwhInt != lastSwhExt
        line.new(lastSwhBarInt, lastSwhInt, bar_index, lastSwhInt, color=lineBull, style=myIntStyle, width=intWidth)
        if showLabel
            label.new(int((lastSwhBarInt + bar_index)/2), lastSwhInt, text=intLabelText, color=color.new(color.white, 100), style=label.style_label_down, textcolor=lineBull, size=size.small)

if close < lastSwlInt and not swl_int_broken
    swl_int_broken := true
    // Overlap Prevention: Only draw if it's NOT the exact same level as the External swing
    if lastSwlInt != lastSwlExt
        line.new(lastSwlBarInt, lastSwlInt, bar_index, lastSwlInt, color=lineBear, style=myIntStyle, width=intWidth)
        if showLabel
            label.new(int((lastSwlBarInt + bar_index)/2), lastSwlInt, text=intLabelText, color=color.new(color.white, 100), style=label.style_label_up, textcolor=lineBear, size=size.small)

// --- External Breakouts ---
if close > lastSwhExt and not swh_ext_broken
    swh_ext_broken := true
    line.new(lastSwhBarExt, lastSwhExt, bar_index, lastSwhExt, color=lineBull, style=myExtStyle, width=extWidth)
    if showLabel
        label.new(int((lastSwhBarExt + bar_index)/2), lastSwhExt, text=extLabelText, color=color.new(color.white, 100), style=label.style_label_down, textcolor=lineBull, size=size.normal)

if close < lastSwlExt and not swl_ext_broken
    swl_ext_broken := true
    line.new(lastSwlBarExt, lastSwlExt, bar_index, lastSwlExt, color=lineBear, style=myExtStyle, width=extWidth)
    if showLabel
        label.new(int((lastSwlBarExt + bar_index)/2), lastSwlExt, text=extLabelText, color=color.new(color.white, 100), style=label.style_label_up, textcolor=lineBear, size=size.normal)
````
