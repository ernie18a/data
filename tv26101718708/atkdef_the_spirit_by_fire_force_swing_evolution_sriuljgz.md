# ATK/DEF The Spirit by Fire Force Swing Evolution

- url: https://www.tradingview.com/script/sRiULjGZ/
- type: indicator
- pine_id: PUB;ddd3afd3b68241f3afc42437764a77a1
- version: 1.0

## Description

ATK/DEF The Spirit by Fire Force Swing Evolution

## Overview

ATK/DEF The Spirit by Fire Force Swing Evolution combines three market observation components: Swing Structure, Parabolic SAR, and FVG Fire Cycle.

The framework presents structural classification, SAR behavior, and FVG lifecycle development as separate but complementary views of evolving market conditions.

## 1. Swing Structure — HH / HL / LH / LL

Swing points are classified as Higher High (HH), Higher Low (HL), Lower High (LH), or Lower Low (LL), according to their relationship with previous reference points.

[image]https://www.tradingview.com/x/81pw6vXW/[/image]

## 2. SAR Indicator

The Parabolic SAR component displays SAR points and tracks price interaction through a behavior sequence:

`RESET → TRACK → TOUCH → SWEEP → REJECT / ACCEPT`

The Structure Table displays recent retained swing classifications alongside the current SAR value, direction, and behavior state.

[image]https://www.tradingview.com/x/pnM8SEVv/[/image]

## 3. FVG Fire Cycle

Bullish and bearish Fair Value Gaps are identified from three-bar price gaps. Each gap is tracked through a 13-stage state framework:

`RESET → REKINDLE → EMBER → COOL → DESTROY → OUTBURST → BURN → SPREAD → IGNITE → CONTROL → WEAKEN → CLEAR → EXTINGUISH`

Stage transitions depend on price interaction with the gap boundaries and defined ATR-based thresholds. The cycle can revisit earlier states under specific conditions, and not every gap necessarily progresses through every stage.

[image]https://www.tradingview.com/x/pVdjiCBU/[/image]

## Output Results

- **Swing Structure:** HH, HL, LH, and LL labels.
- **SAR Indicator:** SAR dots, directional colors, and behavior labels.
- **FVG Fire Cycle:** Bullish and bearish FVG zones with evolving stage labels.
- **Structure Table:** Recent retained swing points, prices, current SAR value, direction, and behavior.

## Next Task / Action Framework

- **WATCH** — Observe the sequence of confirmed swing structures.
- **TRACK** — Monitor changes in SAR behavior.
- **RECHECK** — Observe price interaction with existing FVG zones.
- **CONFIRM** — Track subsequent state transitions as their conditions are met.

## Scope

This indicator is designed for market observation and structural analysis. It does not provide trading signals or predict future price behavior.

Swing points require right-side bars for confirmation. The active same-direction swing label may be replaced when a more extreme point appears. FVG state labels reflect programmed price conditions and do not guarantee a complete progression through all stages.

## Source Code

````pine
/// This Pine Script code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("ATK/DEF The Spirit by Fire Force Swing Evolution", shorttitle="ATK/DEF Fire Element Higher High & Lower Low ", overlay=true, max_labels_count=500, max_boxes_count=500)

// ═══════════════════════════ INPUTS ═══════════════════════════
swingLen  = input.int(5, "Swing Lookback", minval=1)
bullColor = input.color(color.new(color.teal, 0), "Bull (HH/HL) Color")
bearColor = input.color(color.new(color.red, 0), "Bear (LH/LL) Color")
labelSize = input.string("small", "Label Size", options=["tiny", "small", "normal", "large"])

// ===== FVG =====
showFVG       = input.bool(true, "Show FVG")
fvgBullColor  = input.color(color.new(color.green, 80), "Bullish FVG Color")
fvgBearColor  = input.color(color.new(color.red, 80), "Bearish FVG Color")
fvgBorder     = input.bool(true, "FVG Border")
fvgBoxWidth   = input.int(10, "FVG Right Extension (bars)", minval=1, maxval=50)
fvgMinSizeATR = input.float(0.0, "FVG Min Size (ATR mult)", minval=0.0, step=0.1)
fvgLabelSize  = input.string("tiny", "FVG Label Size", options=["tiny", "small", "normal", "large"])
atrLen        = input.int(14, "ATR Length", minval=1)
maxKeep       = input.int(50, "FVG Max Keep", minval=1, maxval=500)
fvgAcceptBars   = input.int(3, "COOL Confirm Bars", minval=1)
fvgConflictBars = input.int(2, "DESTROY Confirm Bars", minval=1)

// ===== SAR (Independent + Flow) =====
grpSAR        = "SAR (Independent + Flow)"
showSAR       = input.bool(true, "Show SAR", group=grpSAR)
sarStart      = input.float(0.02, "SAR Start", minval=0.001, step=0.001, group=grpSAR)
sarInc        = input.float(0.02, "SAR Increment", minval=0.001, step=0.001, group=grpSAR)
sarMax        = input.float(0.2,  "SAR Max", minval=0.01, step=0.01, group=grpSAR)
sarBullColor  = input.color(color.new(color.lime, 0), "SAR Bull Color", group=grpSAR)
sarBearColor  = input.color(color.new(color.red, 0),  "SAR Bear Color", group=grpSAR)
sarDotWidth   = input.int(2, "SAR Dot Size", minval=1, maxval=10, group=grpSAR)
sarFlipSize   = input.string("large", "SAR Label Size", options=["tiny","small","normal","large"], group=grpSAR)
sarFlipOffsetATR = input.float(0.5, "SAR Label Offset (ATR mult)", minval=0.0, step=0.1, group=grpSAR)
sarFlowTolATR = input.float(0.3, "SAR Flow Tolerance (ATR mult)", minval=0.0, step=0.1, group=grpSAR)

// ===== Structure Table =====
grpTbl     = "Structure Table"
showTable  = input.bool(true, "Show Structure Table", group=grpTbl)
tableRows  = input.int(5, "Structure Points Kept", minval=1, maxval=10, group=grpTbl)
tablePos   = input.string("top_right", "Position", options=["top_right","top_left","bottom_right","bottom_left","middle_right"], group=grpTbl)
tableSize  = input.string("small", "Text Size", options=["tiny","small","normal","large"], group=grpTbl)

f_size(string s) =>
    string result = s
    switch result
        "tiny" => size.tiny
        "small" => size.small
        "normal" => size.normal
        => size.large

t_size(string s) =>
    switch s
        "tiny" => size.tiny
        "small" => size.small
        "normal" => size.normal
        => size.large

t_pos(string s) =>
    switch s
        "top_right"    => position.top_right
        "top_left"     => position.top_left
        "bottom_right" => position.bottom_right
        "bottom_left"  => position.bottom_left
        => position.middle_right

// ═══════════════════════════ ATR ═══════════════════════════
atrVal     = ta.atr(atrLen)
fvgMinSize = atrVal * fvgMinSizeATR
sarFlowTol = atrVal * sarFlowTolATR

// ═══════════════════════════ CLASSIFIERS ═══════════════════════════
f_classify(string typ, float price, float ref) =>
    string result = na
    if na(ref)
        result := typ == "H" ? "H" : "L"
    else if typ == "H"
        result := price > ref ? "HH" : "LH"
    else
        result := price < ref ? "LL" : "HL"
    result

f_color(string cls) =>
    color result = color.gray
    if cls == "HH" or cls == "HL"
        result := bullColor
    else if cls == "LH" or cls == "LL"
        result := bearColor
    result

// ═══════════════════════════ FVG STAGE CONSTANTS ═══════════════════════════
const int S_RESET      = 1
const int S_REKINDLE   = 2
const int S_EMBER      = 3
const int S_COOL       = 4
const int S_DESTROY    = 5
const int S_OUTBURST   = 6
const int S_BURN       = 7
const int S_SPREAD     = 8
const int S_IGNITE     = 9
const int S_CONTROL    = 10
const int S_WEAKEN     = 11
const int S_CLEAR      = 12
const int S_EXTINGUISH = 13

fvgTxt(int st, bool bull) =>
    string arrow = bull ? "↑" : "↓"
    switch st
        S_RESET      => "FVG " + arrow + " RESET"
        S_REKINDLE   => "FVG " + arrow + " REKINDLE"
        S_EMBER      => "FVG " + arrow + " EMBER"
        S_COOL       => "FVG " + arrow + " COOL"
        S_DESTROY    => "FVG " + arrow + " DESTROY"
        S_OUTBURST   => "FVG " + arrow + " OUTBURST"
        S_BURN       => "FVG " + arrow + " BURN"
        S_SPREAD     => "FVG " + arrow + " SPREAD"
        S_IGNITE     => "FVG " + arrow + " IGNITE"
        S_CONTROL    => "FVG " + arrow + " CONTROL"
        S_WEAKEN     => "FVG " + arrow + " WEAKEN"
        S_CLEAR      => "FVG " + arrow + " CLEAR"
        =>              "FVG " + arrow + " EXTINGUISH"

// ═══════════════════════════ SAR FLOW STAGE CONSTANTS ═══════════════════════════
const int SR_RESET  = 1
const int SR_TRACK  = 2
const int SR_TOUCH  = 3
const int SR_SWEEP  = 4
const int SR_REJECT = 5
const int SR_ACCEPT = 6

sarFlowTxt(int st, bool bull) =>
    string arrow = bull ? "↑" : "↓"
    switch st
        SR_RESET  => "SAR " + arrow + " RESET"
        SR_TRACK  => "SAR " + arrow + " TRACK"
        SR_TOUCH  => "SAR " + arrow + " TOUCH"
        SR_SWEEP  => "SAR " + arrow + " SWEEP"
        SR_REJECT => "SAR " + arrow + " REJECT"
        =>           "SAR " + arrow + " ACCEPT"

sarFlowName(int st) =>
    switch st
        SR_RESET  => "RESET"
        SR_TRACK  => "TRACK"
        SR_TOUCH  => "TOUCH"
        SR_SWEEP  => "SWEEP"
        SR_REJECT => "REJECT"
        =>           "ACCEPT"

// ═══════════════════════════ SWING DETECTION ═══════════════════════════
swingHighPt = ta.pivothigh(high, swingLen, swingLen)
swingLowPt  = ta.pivotlow(low, swingLen, swingLen)

var float chainPrice = na
var int   chainBar   = na
var string chainType = na
var float refHigh = na
var float refLow  = na
var label curLabel = na

// ═══════════════════════════ STRUCTURE HISTORY ARRAYS ═══════════════════════════
var array<float>  structPrices = array.new<float>()
var array<string> structTypes  = array.new<string>()

// ═══════════════════════════ PROCESS NEW SWING HIGH ═══════════════════════════
if not na(swingHighPt)
    float pPrice = swingHighPt
    int   pBar   = bar_index - swingLen

    if na(chainType)
        chainType  := "H"
        chainPrice := pPrice
        chainBar   := pBar

    else if chainType == "H"
        if pPrice > chainPrice
            if not na(curLabel)
                label.delete(curLabel)
            chainPrice := pPrice
            chainBar   := pBar
            string cls = f_classify("H", pPrice, refHigh)
            color  col = f_color(cls)
            curLabel := label.new(pBar, pPrice, cls,
                 style     = label.style_label_left,
                 size      = f_size(labelSize),
                 color     = color.new(col, 15),
                 textcolor = color.white,
                 xloc      = xloc.bar_index)
            array.push(structPrices, pPrice)
            array.push(structTypes,  cls)

    else
        refLow := chainPrice
        string cls = f_classify("H", pPrice, refHigh)
        color  col = f_color(cls)
        curLabel := label.new(pBar, pPrice, cls,
             style     = label.style_label_left,
             size      = f_size(labelSize),
             color     = color.new(col, 15),
             textcolor = color.white,
             xloc      = xloc.bar_index)
        array.push(structPrices, pPrice)
        array.push(structTypes,  cls)
        chainType  := "H"
        chainPrice := pPrice
        chainBar   := pBar

// ═══════════════════════════ PROCESS NEW SWING LOW ═══════════════════════════
if not na(swingLowPt)
    float pPrice = swingLowPt
    int   pBar   = bar_index - swingLen

    if na(chainType)
        chainType  := "L"
        chainPrice := pPrice
        chainBar   := pBar

    else if chainType == "L"
        if pPrice < chainPrice
            if not na(curLabel)
                label.delete(curLabel)
            chainPrice := pPrice
            chainBar   := pBar
            string cls = f_classify("L", pPrice, refLow)
            color  col = f_color(cls)
            curLabel := label.new(pBar, pPrice, cls,
                 style     = label.style_label_left,
                 size      = f_size(labelSize),
                 color     = color.new(col, 15),
                 textcolor = color.white,
                 xloc      = xloc.bar_index)
            array.push(structPrices, pPrice)
            array.push(structTypes,  cls)

    else
        refHigh := chainPrice
        string cls = f_classify("L", pPrice, refLow)
        color  col = f_color(cls)
        curLabel := label.new(pBar, pPrice, cls,
             style     = label.style_label_left,
             size      = f_size(labelSize),
             color     = color.new(col, 15),
             textcolor = color.white,
             xloc      = xloc.bar_index)
        array.push(structPrices, pPrice)
        array.push(structTypes,  cls)
        chainType  := "L"
        chainPrice := pPrice
        chainBar   := pBar

// ═══════════════════════════ STRUCTURE ARRAY FIFO ═══════════════════════════
while array.size(structPrices) > tableRows
    array.shift(structPrices)
    array.shift(structTypes)

// ═══════════════════════════════════════════════════════════════
//   SAR MODULE (Independent + Index-Locked + Flow State Machine)
// ═══════════════════════════════════════════════════════════════
sarVal = ta.sar(sarStart, sarInc, sarMax)

sarIsBull    = close > sarVal
sarPlotColor = sarIsBull ? sarBullColor : sarBearColor

plot(showSAR ? sarVal : na, "SAR", color=sarPlotColor, style=plot.style_circles, linewidth=sarDotWidth)

var bool sarPrevBull    = false
var bool sarInitialized = false

sarFlipUp   = showSAR and sarInitialized and sarIsBull and not sarPrevBull
sarFlipDown = showSAR and sarInitialized and not sarIsBull and sarPrevBull

var int   sarStage  = 0
var bool  sarIsBullState = true
var label sarLabel  = na
var float sarRefPrice = na

sarOff = atrVal * sarFlipOffsetATR

if sarFlipUp
    if not na(sarLabel)
        label.delete(sarLabel)
    sarStage     := SR_RESET
    sarIsBullState := true
    sarRefPrice  := sarVal
    sarLabel := label.new(bar_index, sarVal - sarOff, sarFlowTxt(SR_RESET, true),
                   style     = label.style_none,
                   color     = na,
                   textcolor = sarBullColor,
                   size      = f_size(sarFlipSize),
                   xloc      = xloc.bar_index)

if sarFlipDown
    if not na(sarLabel)
        label.delete(sarLabel)
    sarStage     := SR_RESET
    sarIsBullState := false
    sarRefPrice  := sarVal
    sarLabel := label.new(bar_index, sarVal + sarOff, sarFlowTxt(SR_RESET, false),
                   style     = label.style_none,
                   color     = na,
                   textcolor = sarBearColor,
                   size      = f_size(sarFlipSize),
                   xloc      = xloc.bar_index)

if showSAR and sarStage > 0 and not na(sarLabel)
    if sarIsBullState
        if sarStage == SR_RESET
            if close > sarVal + sarFlowTol
                label.set_text(sarLabel, sarFlowTxt(SR_TRACK, true))
                sarStage := SR_TRACK
        else if sarStage == SR_TRACK
            if low <= sarVal + sarFlowTol and low > sarVal
                label.set_text(sarLabel, sarFlowTxt(SR_TOUCH, true))
                sarStage := SR_TOUCH
            else if close < sarVal
                label.set_text(sarLabel, sarFlowTxt(SR_ACCEPT, true))
                sarStage := SR_ACCEPT
        else if sarStage == SR_TOUCH
            if low < sarVal and close > sarVal
                label.set_text(sarLabel, sarFlowTxt(SR_SWEEP, true))
                sarStage := SR_SWEEP
            else if close > sarVal + sarFlowTol
                label.set_text(sarLabel, sarFlowTxt(SR_TRACK, true))
                sarStage := SR_TRACK
            else if close < sarVal
                label.set_text(sarLabel, sarFlowTxt(SR_ACCEPT, true))
                sarStage := SR_ACCEPT
        else if sarStage == SR_SWEEP
            if close > sarVal + sarFlowTol
                label.set_text(sarLabel, sarFlowTxt(SR_REJECT, true))
                sarStage := SR_REJECT
            else if close < sarVal
                label.set_text(sarLabel, sarFlowTxt(SR_ACCEPT, true))
                sarStage := SR_ACCEPT
        else if sarStage == SR_REJECT
            if close > sarVal + sarFlowTol
                label.set_text(sarLabel, sarFlowTxt(SR_TRACK, true))
                sarStage := SR_TRACK
        else if sarStage == SR_ACCEPT
            if close > sarVal
                label.set_text(sarLabel, sarFlowTxt(SR_TRACK, true))
                sarStage := SR_TRACK
    else
        if sarStage == SR_RESET
            if close < sarVal - sarFlowTol
                label.set_text(sarLabel, sarFlowTxt(SR_TRACK, false))
                sarStage := SR_TRACK
        else if sarStage == SR_TRACK
            if high >= sarVal - sarFlowTol and high < sarVal
                label.set_text(sarLabel, sarFlowTxt(SR_TOUCH, false))
                sarStage := SR_TOUCH
            else if close > sarVal
                label.set_text(sarLabel, sarFlowTxt(SR_ACCEPT, false))
                sarStage := SR_ACCEPT
        else if sarStage == SR_TOUCH
            if high > sarVal and close < sarVal
                label.set_text(sarLabel, sarFlowTxt(SR_SWEEP, false))
                sarStage := SR_SWEEP
            else if close < sarVal - sarFlowTol
                label.set_text(sarLabel, sarFlowTxt(SR_TRACK, false))
                sarStage := SR_TRACK
            else if close > sarVal
                label.set_text(sarLabel, sarFlowTxt(SR_ACCEPT, false))
                sarStage := SR_ACCEPT
        else if sarStage == SR_SWEEP
            if close < sarVal - sarFlowTol
                label.set_text(sarLabel, sarFlowTxt(SR_REJECT, false))
                sarStage := SR_REJECT
            else if close > sarVal
                label.set_text(sarLabel, sarFlowTxt(SR_ACCEPT, false))
                sarStage := SR_ACCEPT
        else if sarStage == SR_REJECT
            if close < sarVal - sarFlowTol
                label.set_text(sarLabel, sarFlowTxt(SR_TRACK, false))
                sarStage := SR_TRACK
        else if sarStage == SR_ACCEPT
            if close < sarVal
                label.set_text(sarLabel, sarFlowTxt(SR_TRACK, false))
                sarStage := SR_TRACK

sarPrevBull    := sarIsBull
sarInitialized := true

// ═══════════════════════════════════════════════════════════════
//   FVG MODULE (13-Stage Flow + Index-Locked)
// ═══════════════════════════════════════════════════════════════
var array<box>   bullFvgBoxes  = array.new<box>()
var array<label> bullFvgLabels = array.new<label>()
var array<int>   bullFvgStage  = array.new<int>()
var array<float> bullFvgTop    = array.new<float>()
var array<float> bullFvgBot    = array.new<float>()
var array<int>   bullFvgBar    = array.new<int>()
var array<int>   bullFvgCnt    = array.new<int>()

var array<box>   bearFvgBoxes  = array.new<box>()
var array<label> bearFvgLabels = array.new<label>()
var array<int>   bearFvgStage  = array.new<int>()
var array<float> bearFvgTop    = array.new<float>()
var array<float> bearFvgBot    = array.new<float>()
var array<int>   bearFvgBar    = array.new<int>()
var array<int>   bearFvgCnt    = array.new<int>()

if showFVG and low > high[2]
    float gapTop = low
    float gapBot = high[2]
    if gapTop - gapBot >= fvgMinSize
        int leftX  = bar_index - 2
        int rightX = bar_index + fvgBoxWidth
        box b = box.new(leftX, gapTop, rightX, gapBot,
                        border_color = fvgBorder ? color.new(color.green, 50) : na,
                        border_width = fvgBorder ? 1 : 0,
                        bgcolor = fvgBullColor,
                        xloc = xloc.bar_index)
        array.push(bullFvgBoxes, b)

        int midX = bar_index - 2 + math.round((fvgBoxWidth + 2) / 2)
        float midY = (gapTop + gapBot) / 2
        lbl = label.new(midX, midY, fvgTxt(S_RESET, true),
                        style     = label.style_none,
                        textcolor = color.new(color.green, 0),
                        size      = f_size(fvgLabelSize),
                        xloc      = xloc.bar_index)
        array.push(bullFvgLabels, lbl)
        array.push(bullFvgStage, S_RESET)
        array.push(bullFvgTop, gapTop)
        array.push(bullFvgBot, gapBot)
        array.push(bullFvgBar, bar_index)
        array.push(bullFvgCnt, 0)

if showFVG and high < low[2]
    float gapTop = low[2]
    float gapBot = high
    if gapTop - gapBot >= fvgMinSize
        int leftX  = bar_index - 2
        int rightX = bar_index + fvgBoxWidth
        box b = box.new(leftX, gapTop, rightX, gapBot,
                        border_color = fvgBorder ? color.new(color.red, 50) : na,
                        border_width = fvgBorder ? 1 : 0,
                        bgcolor = fvgBearColor,
                        xloc = xloc.bar_index)
        array.push(bearFvgBoxes, b)

        int midX = bar_index - 2 + math.round((fvgBoxWidth + 2) / 2)
        float midY = (gapTop + gapBot) / 2
        lbl = label.new(midX, midY, fvgTxt(S_RESET, false),
                        style     = label.style_none,
                        textcolor = color.new(color.red, 0),
                        size      = f_size(fvgLabelSize),
                        xloc      = xloc.bar_index)
        array.push(bearFvgLabels, lbl)
        array.push(bearFvgStage, S_RESET)
        array.push(bearFvgTop, gapTop)
        array.push(bearFvgBot, gapBot)
        array.push(bearFvgBar, bar_index)
        array.push(bearFvgCnt, 0)

// Bullish FVG flow
if showFVG and array.size(bullFvgStage) > 0
    int i = 0
    while i < array.size(bullFvgStage)
        int   st   = array.get(bullFvgStage, i)
        float gTop = array.get(bullFvgTop, i)
        float gBot = array.get(bullFvgBot, i)
        int   gBar = array.get(bullFvgBar, i)
        int   cnt  = array.get(bullFvgCnt, i)
        label lb   = array.get(bullFvgLabels, i)

        if bar_index > gBar
            if st == S_RESET
                if low <= gTop
                    label.set_text(lb, fvgTxt(S_REKINDLE, true))
                    array.set(bullFvgStage, i, S_REKINDLE)
                    array.set(bullFvgCnt, i, 0)
            else if st == S_REKINDLE
                if close >= gBot and close <= gTop
                    label.set_text(lb, fvgTxt(S_EMBER, true))
                    array.set(bullFvgStage, i, S_EMBER)
                    array.set(bullFvgCnt, i, 0)
            else if st == S_EMBER
                if low <= gBot
                    cnt += 1
                    array.set(bullFvgCnt, i, cnt)
                    if cnt >= fvgConflictBars
                        label.set_text(lb, fvgTxt(S_DESTROY, true))
                        array.set(bullFvgStage, i, S_DESTROY)
                        array.set(bullFvgCnt, i, 0)
                else if close >= gBot and close <= gTop
                    cnt += 1
                    array.set(bullFvgCnt, i, cnt)
                    if cnt >= fvgAcceptBars
                        label.set_text(lb, fvgTxt(S_COOL, true))
                        array.set(bullFvgStage, i, S_COOL)
                        array.set(bullFvgCnt, i, 0)
                else
                    array.set(bullFvgCnt, i, 0)
            else if st == S_COOL
                if low <= gBot
                    cnt += 1
                    array.set(bullFvgCnt, i, cnt)
                    if cnt >= fvgConflictBars
                        label.set_text(lb, fvgTxt(S_DESTROY, true))
                        array.set(bullFvgStage, i, S_DESTROY)
                        array.set(bullFvgCnt, i, 0)
                else if close > gTop
                    label.set_text(lb, fvgTxt(S_OUTBURST, true))
                    array.set(bullFvgStage, i, S_OUTBURST)
                    array.set(bullFvgCnt, i, 0)
                else
                    array.set(bullFvgCnt, i, 0)
            else if st == S_DESTROY
                if close > gBot and close <= gTop
                    label.set_text(lb, fvgTxt(S_EMBER, true))
                    array.set(bullFvgStage, i, S_EMBER)
                    array.set(bullFvgCnt, i, 0)
            else if st == S_OUTBURST
                if close > gBot + atrVal * 0.3
                    label.set_text(lb, fvgTxt(S_BURN, true))
                    array.set(bullFvgStage, i, S_BURN)
                    array.set(bullFvgCnt, i, 0)
            else if st == S_BURN
                if close > gBot + atrVal * 0.6
                    label.set_text(lb, fvgTxt(S_SPREAD, true))
                    array.set(bullFvgStage, i, S_SPREAD)
                    array.set(bullFvgCnt, i, 0)
            else if st == S_SPREAD
                if close > gTop
                    label.set_text(lb, fvgTxt(S_IGNITE, true))
                    array.set(bullFvgStage, i, S_IGNITE)
                    array.set(bullFvgCnt, i, 0)
            else if st == S_IGNITE
                if close > gTop + atrVal * 0.5
                    label.set_text(lb, fvgTxt(S_CONTROL, true))
                    array.set(bullFvgStage, i, S_CONTROL)
                    array.set(bullFvgCnt, i, 0)
            else if st == S_CONTROL
                if close > gTop + atrVal * 1.0
                    label.set_text(lb, fvgTxt(S_WEAKEN, true))
                    array.set(bullFvgStage, i, S_WEAKEN)
                    array.set(bullFvgCnt, i, 0)
            else if st == S_WEAKEN
                if close > gTop + atrVal * 2.0
                    label.set_text(lb, fvgTxt(S_CLEAR, true))
                    array.set(bullFvgStage, i, S_CLEAR)
                    array.set(bullFvgCnt, i, 0)
            else if st == S_CLEAR
                if close > gTop + atrVal * 3.0
                    label.set_text(lb, fvgTxt(S_EXTINGUISH, true))
                    array.set(bullFvgStage, i, S_EXTINGUISH)
                    array.set(bullFvgCnt, i, 0)
            else if st == S_EXTINGUISH
                if low <= gTop
                    label.set_text(lb, fvgTxt(S_RESET, true))
                    array.set(bullFvgStage, i, S_RESET)
                    array.set(bullFvgCnt, i, 0)
        i += 1

// Bearish FVG flow
if showFVG and array.size(bearFvgStage) > 0
    int i = 0
    while i < array.size(bearFvgStage)
        int   st   = array.get(bearFvgStage, i)
        float gTop = array.get(bearFvgTop, i)
        float gBot = array.get(bearFvgBot, i)
        int   gBar = array.get(bearFvgBar, i)
        int   cnt  = array.get(bearFvgCnt, i)
        label lb   = array.get(bearFvgLabels, i)

        if bar_index > gBar
            if st == S_RESET
                if high >= gBot
                    label.set_text(lb, fvgTxt(S_REKINDLE, false))
                    array.set(bearFvgStage, i, S_REKINDLE)
                    array.set(bearFvgCnt, i, 0)
            else if st == S_REKINDLE
                if close >= gBot and close <= gTop
                    label.set_text(lb, fvgTxt(S_EMBER, false))
                    array.set(bearFvgStage, i, S_EMBER)
                    array.set(bearFvgCnt, i, 0)
            else if st == S_EMBER
                if high >= gTop
                    cnt += 1
                    array.set(bearFvgCnt, i, cnt)
                    if cnt >= fvgConflictBars
                        label.set_text(lb, fvgTxt(S_DESTROY, false))
                        array.set(bearFvgStage, i, S_DESTROY)
                        array.set(bearFvgCnt, i, 0)
                else if close >= gBot and close <= gTop
                    cnt += 1
                    array.set(bearFvgCnt, i, cnt)
                    if cnt >= fvgAcceptBars
                        label.set_text(lb, fvgTxt(S_COOL, false))
                        array.set(bearFvgStage, i, S_COOL)
                        array.set(bearFvgCnt, i, 0)
                else
                    array.set(bearFvgCnt, i, 0)
            else if st == S_COOL
                if high >= gTop
                    cnt += 1
                    array.set(bearFvgCnt, i, cnt)
                    if cnt >= fvgConflictBars
                        label.set_text(lb, fvgTxt(S_DESTROY, false))
                        array.set(bearFvgStage, i, S_DESTROY)
                        array.set(bearFvgCnt, i, 0)
                else if close < gBot
                    label.set_text(lb, fvgTxt(S_OUTBURST, false))
                    array.set(bearFvgStage, i, S_OUTBURST)
                    array.set(bearFvgCnt, i, 0)
                else
                    array.set(bearFvgCnt, i, 0)
            else if st == S_DESTROY
                if close >= gBot and close <= gTop
                    label.set_text(lb, fvgTxt(S_EMBER, false))
                    array.set(bearFvgStage, i, S_EMBER)
                    array.set(bearFvgCnt, i, 0)
            else if st == S_OUTBURST
                if close < gTop - atrVal * 0.3
                    label.set_text(lb, fvgTxt(S_BURN, false))
                    array.set(bearFvgStage, i, S_BURN)
                    array.set(bearFvgCnt, i, 0)
            else if st == S_BURN
                if close < gTop - atrVal * 0.6
                    label.set_text(lb, fvgTxt(S_SPREAD, false))
                    array.set(bearFvgStage, i, S_SPREAD)
                    array.set(bearFvgCnt, i, 0)
            else if st == S_SPREAD
                if close < gBot
                    label.set_text(lb, fvgTxt(S_IGNITE, false))
                    array.set(bearFvgStage, i, S_IGNITE)
                    array.set(bearFvgCnt, i, 0)
            else if st == S_IGNITE
                if close < gBot - atrVal * 0.5
                    label.set_text(lb, fvgTxt(S_CONTROL, false))
                    array.set(bearFvgStage, i, S_CONTROL)
                    array.set(bearFvgCnt, i, 0)
            else if st == S_CONTROL
                if close < gBot - atrVal * 1.0
                    label.set_text(lb, fvgTxt(S_WEAKEN, false))
                    array.set(bearFvgStage, i, S_WEAKEN)
                    array.set(bearFvgCnt, i, 0)
            else if st == S_WEAKEN
                if close < gBot - atrVal * 2.0
                    label.set_text(lb, fvgTxt(S_CLEAR, false))
                    array.set(bearFvgStage, i, S_CLEAR)
                    array.set(bearFvgCnt, i, 0)
            else if st == S_CLEAR
                if close < gBot - atrVal * 3.0
                    label.set_text(lb, fvgTxt(S_EXTINGUISH, false))
                    array.set(bearFvgStage, i, S_EXTINGUISH)
                    array.set(bearFvgCnt, i, 0)
            else if st == S_EXTINGUISH
                if high >= gBot
                    label.set_text(lb, fvgTxt(S_RESET, false))
                    array.set(bearFvgStage, i, S_RESET)
                    array.set(bearFvgCnt, i, 0)
        i += 1

// FVG fill removal
if showFVG
    if array.size(bullFvgBoxes) > 0
        int i = 0
        while i < array.size(bullFvgBoxes)
            box b = array.get(bullFvgBoxes, i)
            if not na(b) and close < box.get_bottom(b)
                box.delete(b)
                array.remove(bullFvgBoxes, i)
                if i < array.size(bullFvgLabels)
                    label.delete(array.get(bullFvgLabels, i))
                    array.remove(bullFvgLabels, i)
                    array.remove(bullFvgStage, i)
                    array.remove(bullFvgTop, i)
                    array.remove(bullFvgBot, i)
                    array.remove(bullFvgBar, i)
                    array.remove(bullFvgCnt, i)
            else
                i += 1

    if array.size(bearFvgBoxes) > 0
        int i = 0
        while i < array.size(bearFvgBoxes)
            box b = array.get(bearFvgBoxes, i)
            if not na(b) and close > box.get_top(b)
                box.delete(b)
                array.remove(bearFvgBoxes, i)
                if i < array.size(bearFvgLabels)
                    label.delete(array.get(bearFvgLabels, i))
                    array.remove(bearFvgLabels, i)
                    array.remove(bearFvgStage, i)
                    array.remove(bearFvgTop, i)
                    array.remove(bearFvgBot, i)
                    array.remove(bearFvgBar, i)
                    array.remove(bearFvgCnt, i)
            else
                i += 1

// FVG FIFO
while array.size(bullFvgBoxes) > maxKeep
    box.delete(array.shift(bullFvgBoxes))
    if array.size(bullFvgLabels) > 0
        label.delete(array.shift(bullFvgLabels))
        array.shift(bullFvgStage)
        array.shift(bullFvgTop)
        array.shift(bullFvgBot)
        array.shift(bullFvgBar)
        array.shift(bullFvgCnt)

while array.size(bearFvgBoxes) > maxKeep
    box.delete(array.shift(bearFvgBoxes))
    if array.size(bearFvgLabels) > 0
        label.delete(array.shift(bearFvgLabels))
        array.shift(bearFvgStage)
        array.shift(bearFvgTop)
        array.shift(bearFvgBot)
        array.shift(bearFvgBar)
        array.shift(bearFvgCnt)

// ═══════════════════════════════════════════════════════════════
//   STRUCTURE TABLE
// ═══════════════════════════════════════════════════════════════
var table structTable = table.new(t_pos(tablePos), 5, 1 + tableRows, border_width=1)

if showTable and barstate.islast
    color hdrBg = color.new(color.blue, 20)

    table.cell(structTable, 0, 0, "Structure", text_color=color.white, bgcolor=hdrBg, text_size=t_size(tableSize))
    table.cell(structTable, 1, 0, "Price",     text_color=color.white, bgcolor=hdrBg, text_size=t_size(tableSize))
    table.cell(structTable, 2, 0, "SAR",       text_color=color.white, bgcolor=hdrBg, text_size=t_size(tableSize))
    table.cell(structTable, 3, 0, "Direction", text_color=color.white, bgcolor=hdrBg, text_size=t_size(tableSize))
    table.cell(structTable, 4, 0, "Behavior",  text_color=color.white, bgcolor=hdrBg, text_size=t_size(tableSize))

    // SAR global state
    string sarTxt = showSAR ? str.tostring(sarVal, format.mintick) : "—"
    string dirTxt = sarIsBull ? "↑" : "↓"
    string behTxt = sarStage > 0 ? sarFlowName(sarStage) : "—"

    int rows = array.size(structPrices)
    if rows > 0
        int r = 0
        while r < rows
            string typ = array.get(structTypes, r)
            float  px  = array.get(structPrices, r)
            color  bg  = f_color(typ)
            table.cell(structTable, 0, 1 + r, typ, text_color=color.white, bgcolor=color.new(bg, 40), text_size=t_size(tableSize))
            table.cell(structTable, 1, 1 + r, str.tostring(px, format.mintick), text_color=color.white, bgcolor=color.new(bg, 40), text_size=t_size(tableSize))
            table.cell(structTable, 2, 1 + r, sarTxt, text_color=color.white, bgcolor=color.new(bg, 60), text_size=t_size(tableSize))
            table.cell(structTable, 3, 1 + r, dirTxt, text_color=color.white, bgcolor=color.new(bg, 60), text_size=t_size(tableSize))
            table.cell(structTable, 4, 1 + r, behTxt, text_color=color.white, bgcolor=color.new(bg, 60), text_size=t_size(tableSize))
            r += 1
````
