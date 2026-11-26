# ICT Po3 - AMD & IFVG Distribution

- url: https://www.tradingview.com/script/kHRFXdhL-ICT-Po3-AMD-IFVG-Distribution/
- type: indicator
- pine_id: PUB;7ab848237c9a43089c5bcb9e41c1383d
- version: 1.0

## Description

ICT Po3/AMD strategy will find IFVG's and signal a distribution breakout.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("ICT Po3 - AMD & IFVG Distribution", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// --- Constants ---
color BULL_COLOR = #089981
color BEAR_COLOR = #f23645
color NEUTRAL_COLOR = #5b9cf6

// --- Inputs ---
string timeframeResInput = input.timeframe("240", "Base Timeframe", tooltip = "The timeframe to base the Po3 logic on (default 4H).")
int accumulationTimeInput = input.int(60, "Accumulation Duration (min)", minval = 1, maxval = 120)
float rrInput = input.float(2.0, "Risk/Reward for TP", minval = 0.5, step = 0.1)
int tpLineLengthInput = input.int(30, "TP Line Extension", minval = 1, maxval = 499)

// --- UDTs ---
type FVG
    float top
    float bottom
    bool  isBullish
    bool  isMitigated = false
    box   boxId

// --- Variables ---
var float h4Open = na
var int h4StartTime = 0
var float accumHigh = na
var float accumLow = na
var int phase = 0 // 1: Accum, 2: Manip, 3: Dist
var FVG[] fvgArray = array.new<FVG>()
var float manipExtreme = na
var bool ifvgConfirmedLong = false
var bool ifvgConfirmedShort = false

bool isNewH4 = timeframe.change(timeframeResInput)

if isNewH4
    h4Open := open
    h4StartTime := time
    accumHigh := high
    accumLow := low
    manipExtreme := na
    ifvgConfirmedLong := false
    ifvgConfirmedShort := false
    phase := 1
    if fvgArray.size() > 50
        array.shift(fvgArray)

if phase == 1
    accumHigh := math.max(accumHigh, high)
    accumLow := math.min(accumLow, low)
    if time - h4StartTime > accumulationTimeInput * 60 * 1000
        phase := 2

// Manipulation extreme tracking
if phase == 2
    if low < accumLow
        manipExtreme := na(manipExtreme) ? low : math.min(manipExtreme, low)
    if high > accumHigh
        manipExtreme := na(manipExtreme) ? high : math.max(manipExtreme, high)

// --- FVG Logic ---
bool isBullishFVG = low > high[2] and close[1] > high[2]
bool isBearishFVG = high < low[2] and close[1] < low[2]

if isBullishFVG
    fvgArray.push(FVG.new(low, high[2], true, false, 
         box.new(time[2], low, time, high[2], xloc = xloc.bar_time, border_color = color.new(BULL_COLOR, 50), bgcolor = color.new(BULL_COLOR, 95))))

if isBearishFVG
    fvgArray.push(FVG.new(low[2], high, false, false, 
         box.new(time[2], low[2], time, high, xloc = xloc.bar_time, border_color = color.new(BEAR_COLOR, 50), bgcolor = color.new(BEAR_COLOR, 95))))

// --- IFVG and Signal Logic ---
bool entrySignalLong = false
bool entrySignalShort = false

if fvgArray.size() > 0
    for i = fvgArray.size() - 1 to 0
        fvg = fvgArray.get(i)
        if not fvg.isMitigated
            // Check for IFVG
            if not fvg.isBullish and ta.crossover(close, fvg.top) and phase == 2
                fvg.isMitigated := true
                ifvgConfirmedLong := true
                entrySignalLong := true
                box.set_bgcolor(fvg.boxId, color.new(BULL_COLOR, 60))
                box.set_text(fvg.boxId, "IFVG")
            
            else if fvg.isBullish and ta.crossunder(close, fvg.bottom) and phase == 2
                fvg.isMitigated := true
                ifvgConfirmedShort := true
                entrySignalShort := true
                box.set_bgcolor(fvg.boxId, color.new(BEAR_COLOR, 60))
                box.set_text(fvg.boxId, "IFVG")

            else if (fvg.isBullish and low < fvg.bottom) or (not fvg.isBullish and high > fvg.top)
                fvg.isMitigated := true

        if not fvg.isMitigated
            box.set_right(fvg.boxId, time)

// Distribution Breakout Point
// A "clear breakout" after IFVG, usually crossing back over the accumulation boundary
bool distBreakoutLong = ifvgConfirmedLong and ta.crossover(close, accumHigh) and phase == 2
bool distBreakoutShort = ifvgConfirmedShort and ta.crossunder(close, accumLow) and phase == 2

if (distBreakoutLong or distBreakoutShort) and phase == 2
    phase := 3

// --- Visuals ---
var box accumBox = na
if isNewH4
    accumBox := box.new(h4StartTime, na, h4StartTime + accumulationTimeInput * 60 * 1000, na, xloc = xloc.bar_time, 
         border_color = NEUTRAL_COLOR, bgcolor = color.new(NEUTRAL_COLOR, 90), text = "Consolidation", text_size = size.tiny, text_color = NEUTRAL_COLOR)

if not na(accumBox) and phase == 1
    box.set_top(accumBox, accumHigh)
    box.set_bottom(accumBox, accumLow)

// Entry and TP Visuals
if entrySignalLong
    float tp = close + (math.abs(close - manipExtreme) * rrInput)
    label.new(bar_index, low, "ENTRY POINT\nTP: " + str.tostring(tp, format.mintick), color = BULL_COLOR, textcolor = color.white, style = label.style_label_up, size = size.small)
    line.new(bar_index, tp, bar_index + tpLineLengthInput, tp, color = BULL_COLOR, width = 2, style = line.style_dashed)

if entrySignalShort
    float tp = close - (math.abs(close - manipExtreme) * rrInput)
    label.new(bar_index, high, "ENTRY POINT\nTP: " + str.tostring(tp, format.mintick), color = BEAR_COLOR, textcolor = color.white, style = label.style_label_down, size = size.small)
    line.new(bar_index, tp, bar_index + tpLineLengthInput, tp, color = BEAR_COLOR, width = 2, style = line.style_dashed)

// Distribution Point
plotshape(distBreakoutLong, "Distribution Point", shape.triangleup, location.belowbar, BULL_COLOR, size = size.normal, text = "DISTRIBUTION\nBREAKOUT", textcolor = BULL_COLOR)
plotshape(distBreakoutShort, "Distribution Point", shape.triangledown, location.abovebar, BEAR_COLOR, size = size.normal, text = "DISTRIBUTION\nBREAKOUT", textcolor = BEAR_COLOR)

plot(h4Open, "4H Open", color.new(chart.fg_color, 50), 1, plot.style_linebr)
````
