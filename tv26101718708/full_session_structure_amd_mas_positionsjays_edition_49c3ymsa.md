# Full Session Structure: AMD, MAs & Positions(jays edition)

- url: https://www.tradingview.com/script/49c3ymSa-Full-Session-Structure-AMD-MAs-Positions-jays-edition/
- type: indicator
- pine_id: PUB;3dd6535244104241a91638e71f002b28
- version: 1.0

## Description

combonation of all signals with strong direction of where markets moving

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Full Session Structure: AMD, MAs & Positions", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

// --- Colors ---
color BULL_COLOR = #089981
color BEAR_COLOR = #f23645
color ACCUM_COLOR = #5b9cf6
color NEUTRAL_COLOR = #5d606b

// --- Inputs ---
// Session & AMD Settings
string sessionInput = input.session("0800-1700", "Session Time", tooltip = "Full trading session range.")
string accumEndTime = input.string("1000", "Accumulation End Time", tooltip = "Time when the Accumulation phase ends (e.g., 10:00 for a session starting at 08:00).")
color  sessionBoxColor = input.color(color.new(color.gray, 92), "Session Box Color", group = "Session Style")
bool   showSessLines = input.bool(true, "Show Session High/Low Lines", group = "Session Style")

// Moving Average Settings
bool   useMtf = input.bool(false, "Use Multi-Timeframe for MAs", group = "Moving Averages")
string maTf   = input.timeframe("D", "MA Timeframe", group = "Moving Averages")

bool showEmas = input.bool(true, "Show EMAs", group = "Moving Averages")
int  e1L = input.int(20, "EMA 1", group = "Moving Averages", inline = "e1"), e2L = input.int(50, "EMA 2", group = "Moving Averages", inline = "e1")
int  e3L = input.int(100, "EMA 3", group = "Moving Averages", inline = "e2"), e4L = input.int(200, "EMA 4", group = "Moving Averages", inline = "e2")

bool showSmas = input.bool(true, "Show SMAs", group = "Moving Averages")
int  s1L = input.int(20, "SMA 1", group = "Moving Averages", inline = "s1"), s2L = input.int(50, "SMA 2", group = "Moving Averages", inline = "s1")
int  s3L = input.int(100, "SMA 3", group = "Moving Averages", inline = "s2"), s4L = input.int(200, "SMA 4", group = "Moving Averages", inline = "s2")

// Position Settings
float rrRatio = input.float(2.0, "Risk/Reward Ratio", group = "Positions")
int   boxLen  = input.int(10, "Target Box Length", group = "Positions")
bool  showPriceLabels = input.bool(true, "Show Entry/SL/TP Labels", group = "Positions")

// --- MA Calculations ---
type MAs
    float e1
    float e2
    float e3
    float e4
    float s1
    float s2
    float s3
    float s4

calcMAs() =>
    MAs.new(
     ta.ema(close, e1L), ta.ema(close, e2L), ta.ema(close, e3L), ta.ema(close, e4L),
     ta.sma(close, s1L), ta.sma(close, s2L), ta.sma(close, s3L), ta.sma(close, s4L)
     )

maData = useMtf ? request.security(syminfo.tickerid, maTf, calcMAs()) : calcMAs()

// --- AMD & Session Logic ---
bool inSession = not na(time(timeframe.period, sessionInput, "UTC-5"))
bool isNewSession = inSession and not inSession[1]

// Dynamic Accumulation Range detection
string startTimeStr = str.substring(sessionInput, 0, 4)
string accumRange = startTimeStr + "-" + accumEndTime
bool inAccumulation = not na(time(timeframe.period, accumRange, "UTC-5")) and inSession

var float sessHigh = na
var float sessLow  = na
var float accumHigh = na
var float accumLow  = na
var box   sessBox   = na
var box   accumBox  = na
var line  highLine  = na
var line  lowLine   = na

if isNewSession
    sessHigh := high
    sessLow  := low
    accumHigh := high
    accumLow  := low
    
    sessBox := box.new(bar_index, sessHigh, bar_index, sessLow, bgcolor = sessionBoxColor, border_color = color.new(chart.fg_color, 85), border_style = line.style_dotted)
    accumBox := box.new(bar_index, accumHigh, bar_index, accumLow, bgcolor = color.new(ACCUM_COLOR, 85), border_color = ACCUM_COLOR, text = "A", text_size = size.small, text_color = ACCUM_COLOR)
    
    if showSessLines
        highLine := line.new(bar_index, sessHigh, bar_index, sessHigh, color = color.new(BULL_COLOR, 50), width = 1)
        lowLine  := line.new(bar_index, sessLow, bar_index, sessLow, color = color.new(BEAR_COLOR, 50), width = 1)
else if inSession
    sessHigh := math.max(high, sessHigh)
    sessLow  := math.min(low, sessLow)
    box.set_top(sessBox, sessHigh)
    box.set_bottom(sessBox, sessLow)
    box.set_right(sessBox, bar_index)
    
    if inAccumulation
        accumHigh := math.max(high, accumHigh)
        accumLow  := math.min(low, accumLow)
        box.set_top(accumBox, accumHigh)
        box.set_bottom(accumBox, accumLow)
        box.set_right(accumBox, bar_index)
    
    if showSessLines
        line.set_xy1(highLine, line.get_x1(highLine), sessHigh)
        line.set_xy2(highLine, bar_index, sessHigh)
        line.set_xy1(lowLine, line.get_x1(lowLine), sessLow)
        line.set_xy2(lowLine, bar_index, sessLow)

// Manipulation Label Logic
var bool manipulationTagged = false
if isNewSession
    manipulationTagged := false

bool isManipulation = inSession and not inAccumulation and not manipulationTagged and (high > accumHigh or low < accumLow)
if isManipulation
    label.new(bar_index, high > accumHigh ? high : low, "M", color = #00000000, textcolor = color.orange, style = high > accumHigh ? label.style_label_down : label.style_label_up, size = size.small)
    manipulationTagged := true

// --- Signals & Positions ---
var bool hiBroken = false
var bool loBroken = false
if isNewSession
    hiBroken := false
    loBroken := false

bool longSignal  = inSession and not inAccumulation and not hiBroken and close > sessHigh[1] and not na(sessHigh[1])
bool shortSignal = inSession and not loBroken and not loBroken and close < sessLow[1] and not na(sessLow[1])

if longSignal
    hiBroken := true
    label.new(bar_index, high, "LONG / D", color = BULL_COLOR, textcolor = color.white, style = label.style_label_down, size = size.small)
    float entry = close
    float stop  = sessLow
    float risk  = entry - stop
    if risk > 0
        float tp = entry + (risk * rrRatio)
        box.new(bar_index, tp, bar_index + boxLen, entry, bgcolor = color.new(BULL_COLOR, 85), border_color = BULL_COLOR)
        box.new(bar_index, entry, bar_index + boxLen, stop, bgcolor = color.new(BEAR_COLOR, 85), border_color = BEAR_COLOR)
        line.new(bar_index, tp, bar_index + boxLen, tp, color = BULL_COLOR, style = line.style_dashed)
        if showPriceLabels
            label.new(bar_index + boxLen, tp, "TP: " + str.tostring(tp, format.mintick), style = label.style_label_left, textcolor = BULL_COLOR, color = #00000000)
            label.new(bar_index + boxLen, entry, "Entry: " + str.tostring(entry, format.mintick), style = label.style_label_left, textcolor = chart.fg_color, color = #00000000)
            label.new(bar_index + boxLen, stop, "SL: " + str.tostring(stop, format.mintick), style = label.style_label_left, textcolor = BEAR_COLOR, color = #00000000)

if shortSignal
    loBroken := true
    label.new(bar_index, low, "SHORT / D", color = BEAR_COLOR, textcolor = color.white, style = label.style_label_up, size = size.small)
    float entry = close
    float stop  = sessHigh
    float risk  = stop - entry
    if risk > 0
        float tp = entry - (risk * rrRatio)
        box.new(bar_index, entry, bar_index + boxLen, tp, bgcolor = color.new(BEAR_COLOR, 85), border_color = BEAR_COLOR)
        box.new(bar_index, stop, bar_index + boxLen, entry, bgcolor = color.new(BULL_COLOR, 85), border_color = BULL_COLOR)
        line.new(bar_index, tp, bar_index + boxLen, tp, color = BEAR_COLOR, style = line.style_dashed)
        if showPriceLabels
            label.new(bar_index + boxLen, tp, "TP: " + str.tostring(tp, format.mintick), style = label.style_label_left, textcolor = BEAR_COLOR, color = #00000000)
            label.new(bar_index + boxLen, entry, "Entry: " + str.tostring(entry, format.mintick), style = label.style_label_left, textcolor = chart.fg_color, color = #00000000)
            label.new(bar_index + boxLen, stop, "SL: " + str.tostring(stop, format.mintick), style = label.style_label_left, textcolor = BULL_COLOR, color = #00000000)

// --- Plotting MAs ---
plot(showEmas ? maData.e1 : na, "EMA 1", color.new(#2962ff, 25))
plot(showEmas ? maData.e2 : na, "EMA 2", color.new(#00bcd4, 25))
plot(showEmas ? maData.e3 : na, "EMA 3", color.new(#4caf50, 25))
plot(showEmas ? maData.e4 : na, "EMA 4", color.new(#8bc34a, 25))

plot(showSmas ? maData.s1 : na, "SMA 1", color.new(#ff9800, 35), style = plot.style_linebr)
plot(showSmas ? maData.s2 : na, "SMA 2", color.new(#ff5722, 35), style = plot.style_linebr)
plot(showSmas ? maData.s3 : na, "SMA 3", color.new(#f44336, 35), style = plot.style_linebr)
plot(showSmas ? maData.s4 : na, "SMA 4", color.new(#9c27b0, 35), style = plot.style_linebr)
````
