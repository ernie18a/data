# Amplitude State Simple

- url: https://www.tradingview.com/script/mbySULjE-Amplitude-State-Simple/
- type: indicator
- pine_id: PUB;f76553c03cf34e3cb7fc69172ba9735c
- version: 1.0

## Description

Amplitude State Simple

Amplitude State Simple is a market behavior indicator designed to identify whether price movement is currently expanding, contracting, or remaining relatively stable by analyzing changes in swing amplitude over time.

Rather than measuring trend direction alone, this indicator focuses on the magnitude of movement and compares recent swing behavior against a historical baseline to determine whether market activity is increasing, decreasing, or remaining balanced.

The goal is to provide a simplified view of changing market conditions and help identify shifts in price behavior beneath the surface.

Features:

• Automatic swing amplitude detection
• Multiple amplitude calculation methods:

• Points
• Percent
• ATR Multiple

• Compares recent swing behavior against historical averages
• Automatic market state classification:

• ▲ Expanding
• ■ Stable
• ▼ Contracting

• Historical state ribbon visualization
• Optional background state highlighting
• State transition markers
• Current-state icon display
• Dynamic text labels
• One-line summary table

Potential use cases:

• Identify increasing market activity
• Detect contracting or slowing environments
• Filter trades based on market conditions
• Monitor transitions between regimes
• Add confluence to existing systems
• Study changing market behavior over time

Interpretation:

▲ Expanding

Recent price swings are becoming larger relative to historical behavior and market activity may be increasing.

■ Stable

Recent swing behavior remains relatively balanced and consistent with historical movement.

▼ Contracting

Recent price swings are becoming smaller relative to historical behavior and market activity may be compressing.

Transition Markers

Highlight when market conditions shift from one state to another.

Historical State Ribbon

🟢 Green → Expanding
🟡 Yellow → Stable
🔴 Red → Contracting

The purpose of this indicator is not to predict future price direction, but to provide insight into how market movement itself is changing and whether current behavior is becoming more active or more compressed.

Settings Guide

Pivot Left Bars
Controls how many bars to the left are used to confirm swing highs and lows.

Pivot Right Bars
Controls how many bars to the right are used to confirm swing highs and lows.

Amplitude Mode

• Points → Uses raw price movement values
• Percent → Measures swings as percentage movement
• ATR Multiple → Measures swings relative to current volatility

ATR Length
ATR period used when ATR Multiple mode is selected.

Recent Swings
Number of recent swings used to represent current market behavior.

Baseline Swings
Historical swing sample used for comparison.

Stable Threshold %
Defines the range where movement is considered stable rather than expanding or contracting.

Show Historical State Ribbon
Displays historical expanding/contracting states.

Show Historical Background
Applies background coloring to historical market states.

Show Transition Markers
Displays markers when state changes occur.

About TrendGenY Indicators

[i]TrendGenY indicators are built from market experience, creative concepts, and a constant pursuit of unique perspectives. Rather than following conventional ideas, the focus is on uncovering alternative insights and viewing market behavior through different angles to reveal information that traditional tools may overlook and help traders build a more meaningful edge in the market.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TrendGenY

//@version=5
indicator("Amplitude State Simple", overlay=true, max_labels_count=200)

//====================================================
// Inputs
//====================================================
pivotLeft       = input.int(3, "Pivot Left Bars", minval=1)
pivotRight      = input.int(3, "Pivot Right Bars", minval=1)
ampMode         = input.string("Percent", "Amplitude Mode", options=["Points", "Percent", "ATR Multiple"])
atrLen          = input.int(14, "ATR Length", minval=1)

recentSwings    = input.int(5, "Recent Swings", minval=2, maxval=50)
baselineSwings  = input.int(20, "Baseline Swings", minval=5, maxval=100)
stablePct       = input.float(10.0, "Stable Threshold %", minval=1.0, maxval=50.0, step=0.5)

showIcon        = input.bool(true, "Show Simple Icon")
showTable       = input.bool(true, "Show One-Line Table")
showLabel       = input.bool(true, "Show Text Label")
tablePosition   = input.string("Top Right", "Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])

expandingText   = input.string("▲ Expanding", "Expanding Text")
contractingText = input.string("▼ Contracting", "Contracting Text")
stableText      = input.string("■ Stable", "Stable Text")

// --- Historical Visuals
gHist               = "Historical State Visuals"
showStateRibbon     = input.bool(true, "Show Historical State Ribbon", group=gHist)
showStateBg         = input.bool(false, "Show Historical Background", group=gHist)
showTransitionMarks = input.bool(true, "Show Transition Markers", group=gHist)
ribbonTransparency  = input.int(10, "Ribbon Transparency", minval=0, maxval=100, group=gHist)
bgTransparency      = input.int(88, "Background Transparency", minval=0, maxval=100, group=gHist)

//====================================================
// Helpers
//====================================================
f_tablePos(_pos) =>
    switch _pos
        "Top Right" => position.top_right
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        => position.bottom_left

f_amp(_p1, _p2, _atr, _mode) =>
    raw = math.abs(_p2 - _p1)
    _mode == "Points" ? raw :
     _mode == "Percent" ? (_p1 != 0 ? raw / _p1 * 100.0 : na) :
     (_atr != 0 ? raw / _atr : na)

f_avg_last(_arr, _count) =>
    sz = array.size(_arr)
    if sz < _count
        na
    else
        sum = 0.0
        for i = sz - _count to sz - 1
            sum += array.get(_arr, i)
        sum / _count

//====================================================
// Core series
//====================================================
atr = ta.atr(atrLen)

ph = ta.pivothigh(high, pivotLeft, pivotRight)
pl = ta.pivotlow(low, pivotLeft, pivotRight)

phBar = bar_index - pivotRight
plBar = bar_index - pivotRight

//====================================================
// Pivot state
//====================================================
var int   lastPivotBar   = na
var float lastPivotPrice = na
var int   lastPivotType  = 0

var swingAmpArr = array.new_float()

//====================================================
// Register pivot
//====================================================
if not na(ph)
    if na(lastPivotBar)
        lastPivotBar := phBar
        lastPivotPrice := ph
        lastPivotType := 1
    else
        if lastPivotType == 1
            if ph > lastPivotPrice
                lastPivotBar := phBar
                lastPivotPrice := ph
                lastPivotType := 1
        else
            amp = f_amp(lastPivotPrice, ph, atr[pivotRight], ampMode)
            if not na(amp)
                array.push(swingAmpArr, amp)
                while array.size(swingAmpArr) > baselineSwings
                    array.shift(swingAmpArr)
            lastPivotBar := phBar
            lastPivotPrice := ph
            lastPivotType := 1

if not na(pl)
    if na(lastPivotBar)
        lastPivotBar := plBar
        lastPivotPrice := pl
        lastPivotType := -1
    else
        if lastPivotType == -1
            if pl < lastPivotPrice
                lastPivotBar := plBar
                lastPivotPrice := pl
                lastPivotType := -1
        else
            amp = f_amp(lastPivotPrice, pl, atr[pivotRight], ampMode)
            if not na(amp)
                array.push(swingAmpArr, amp)
                while array.size(swingAmpArr) > baselineSwings
                    array.shift(swingAmpArr)
            lastPivotBar := plBar
            lastPivotPrice := pl
            lastPivotType := -1

//====================================================
// State logic
//====================================================
recentAvg   = f_avg_last(swingAmpArr, recentSwings)
baselineAvg = f_avg_last(swingAmpArr, baselineSwings)

float pctDiff = na
string ampState = "Not Enough Data"
string ampText = "..."
color stateColor = color.gray
int stateValue = 0   // 1 = expanding, 0 = stable, -1 = contracting

if not na(recentAvg) and not na(baselineAvg) and baselineAvg != 0
    pctDiff := (recentAvg - baselineAvg) / baselineAvg * 100.0

    if pctDiff > stablePct
        ampState := "Expanding"
        ampText := expandingText
        stateColor := color.lime
        stateValue := 1
    else if pctDiff < -stablePct
        ampState := "Contracting"
        ampText := contractingText
        stateColor := color.red
        stateValue := -1
    else
        ampState := "Stable"
        ampText := stableText
        stateColor := color.yellow
        stateValue := 0

//====================================================
// Historical visual representation
//====================================================
ribbonColor =
     stateValue == 1 ? color.new(color.lime, ribbonTransparency) :
     stateValue == -1 ? color.new(color.red, ribbonTransparency) :
     stateValue == 0 ? color.new(color.yellow, ribbonTransparency) :
     color.new(color.gray, ribbonTransparency)

bgColorSeries =
     stateValue == 1 ? color.new(color.lime, bgTransparency) :
     stateValue == -1 ? color.new(color.red, bgTransparency) :
     stateValue == 0 ? color.new(color.yellow, bgTransparency) :
     na

plot(showStateRibbon ? stateValue : na, title="Amplitude State Ribbon", style=plot.style_columns, linewidth=3, color=ribbonColor)
hline(1, "Expanding", color=color.new(color.lime, 70))
hline(0, "Stable", color=color.new(color.yellow, 70))
hline(-1, "Contracting", color=color.new(color.red, 70))

bgcolor(showStateBg ? bgColorSeries : na)

stateChanged = not na(stateValue[1]) and stateValue != stateValue[1]

plotshape(showTransitionMarks and stateChanged and stateValue == 1, title="Transition to Expanding", style=shape.triangleup, location=location.bottom, color=color.lime, size=size.tiny, text="Exp")
plotshape(showTransitionMarks and stateChanged and stateValue == 0, title="Transition to Stable", style=shape.circle, location=location.bottom, color=color.yellow, size=size.tiny, text="Stb")
plotshape(showTransitionMarks and stateChanged and stateValue == -1, title="Transition to Contracting", style=shape.triangledown, location=location.bottom, color=color.red, size=size.tiny, text="Con")

//====================================================
// Icon
//====================================================
plotshape(showIcon and barstate.islast, title="Amplitude State Icon", style=shape.circle, location=location.abovebar, color=stateColor, size=size.small)

//====================================================
// Text label
//====================================================
var label stateLabel = na

if barstate.islast and showLabel
    if not na(stateLabel)
        label.delete(stateLabel)
    stateLabel := label.new(bar_index, high, ampText, xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, color=stateColor, textcolor=color.black, size=size.small)

//====================================================
// One-line table
//====================================================
var table t = table.new(f_tablePos(tablePosition), 1, 1, border_width=1)

if barstate.islast and showTable
    table.cell(t, 0, 0, "Amplitude: " + ampState + (na(pctDiff) ? "" : " (" + str.tostring(pctDiff, "#.##") + "%)"), text_color=color.black, bgcolor=stateColor, text_size=size.small)
````
