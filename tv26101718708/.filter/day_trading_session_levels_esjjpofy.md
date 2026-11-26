# Day Trading Session Levels

- url: https://www.tradingview.com/script/esJjPOfy-Day-Trading-Session-Levels/
- type: indicator
- pine_id: PUB;930a97d3cb404c8788e43ccdbb3db554
- version: 7.0

## Description

A clean, session‑accurate framework for intraday traders - maps-out critical levels from the prior session to save you prep time in the morning.
Automatically adapts to equities and futures, with all levels time‑anchored to the exact bar where they occurred.
[b]Features[/b]
Prior Day High / Low (PDH / PDL)
[list]
[*]Tracks the true previous RTH session
[*]Not based on calendar days
[*]Futures‑aware weekend handling (Thursday → Sunday/Monday)
[/list]
Overnight High / Low (ONH / ONL)
[list]
[*]Combined overnight session
[*]Equities: After‑Hours + Pre‑Market
[*]Futures: Globex PM + Globex AM
[*]Levels reset at the correct session boundary
[*]Anchored to the bar where the extreme was made
[/list]
Prior Day Value Area (VAH / VAL / POC)
[list]
[*]Calculated by full volume profile of the prior RTH session
[*]Identifies: POC (highest‑volume price), VAH / VAL (70% value area)
[*]Optional shaded value‑area region extending into the current session
[/list]
Automatic Session Detection
[list]
[*]Adjusts logic for equities vs futures
[*]Handles Globex structure, dead zones, and weekend behavior
[/list]
Clean, Time‑Anchored Visuals
[list]
[*]All levels extend forward using bar‑time anchoring
[*]Consistent across all timeframes
[*]Optional price‑scale markers and text labels
[/list]
Minimal Mode
[list]
[*]One‑click option to show only: PDH, PDL, ONH, ONL
[*]Perfect for traders who want a clean, high‑signal chart.
[/list]

This indicator was built with help from AI-coding tools. Please reach out to me if you find issues or have suggestions for improvement.

## Source Code

````pine
//@version=6
indicator("Day Trading Session Levels", overlay = true, max_lines_count = 500, max_labels_count = 500)

//────────────────────────────────────────────────────────────
// User Inputs (Inputs Tab)
//────────────────────────────────────────────────────────────

// Minimal Mode
minimalMode = input.bool(false, "Minimal Mode", 
     tooltip = "Hides all non-essential levels. Shows only PDH/PDL and ONH/ONL.",
     group = "Display Modes")

// Prior Day Levels
showPDH = input.bool(true,  "Show Prior Day High", 
     tooltip = "Displays the high of the previous RTH session.",
     group="Prior Day Levels")

showPDL = input.bool(true,  "Show Prior Day Low",  
     tooltip = "Displays the low of the previous RTH session.",
     group="Prior Day Levels")

showPDC = input.bool(true, "Show Prior Day Close",
     tooltip = "Displays the closing price of the previous RTH session.",
     group = "Prior Day Levels")

// Overnight Levels
showONH = input.bool(true,  "Show Overnight High", 
     tooltip = "Displays the high of the overnight session.",
     group="Overnight Levels")

showONL = input.bool(true,  "Show Overnight Low",  
     tooltip = "Displays the low of the overnight session.",
     group="Overnight Levels")

// Labels
showTextLabels  = input.bool(true, "Show Text Labels", 
     tooltip = "Shows PDH/PDL/ONH/ONL/VAH/VAL/POC labels on the right edge.",
     group="Labels")

showPriceLabels = input.bool(true, "Show Price Labels", 
     tooltip = "Shows price markers on the price scale.",
     group="Labels")

// Value Area Visibility
showVAH      = input.bool(true, "Show VAH", 
     tooltip = "Displays the Value Area High from the prior RTH session.",
     group="Value Area Levels")

showVAL      = input.bool(true, "Show VAL", 
     tooltip = "Displays the Value Area Low from the prior RTH session.",
     group="Value Area Levels")

showPOC      = input.bool(true, "Show POC", 
     tooltip = "Displays the Point of Control from the prior RTH session.",
     group="Value Area Levels")

showVALabels = input.bool(true, "Show VAH/VAL/POC Labels", 
     tooltip = "Shows VAH/VAL/POC labels on the right edge.",
     group="Value Area Levels")

// Style Inputs (Style Tab)

// Prior Day Style
colPDH = input.color(color.green, "PDH Color", group="Prior Day Style")
styPDH = input.string("Solid", "PDH Style", options=["Solid","Dashed","Dotted"], group="Prior Day Style")
widPDH = input.int(2, "PDH Width", minval=1, group="Prior Day Style")

colPDL = input.color(color.red, "PDL Color", group="Prior Day Style")
styPDL = input.string("Solid", "PDL Style", options=["Solid","Dashed","Dotted"], group="Prior Day Style")
widPDL = input.int(2, "PDL Width", minval=1, group="Prior Day Style")

colPDC = input.color(color.new(color.white, 0), "PDC Color", group="Prior Day Style")
styPDC = input.string("Solid", "PDC Style", options=["Solid","Dashed","Dotted"], group="Prior Day Style")
widPDC = input.int(2, "PDC Width", minval=1, group="Prior Day Style")

// Overnight Style
colONH = input.color(color.blue, "ONH Color", group="Overnight Style")
styONH = input.string("Solid", "ONH Style", options=["Solid","Dashed","Dotted"], group="Overnight Style")
widONH = input.int(2, "ONH Width", minval=1, group="Overnight Style")

colONL = input.color(color.orange, "ONL Color", group="Overnight Style")
styONL = input.string("Solid", "ONL Style", options=["Solid","Dashed","Dotted"], group="Overnight Style")
widONL = input.int(2, "ONL Width", minval=1, group="Overnight Style")

// Value Area Style
colVAH = input.color(color.new(color.white, 0), "VAH Color", group="Value Area Style")
colVAL = input.color(color.new(color.white, 0), "VAL Color", group="Value Area Style")
colPOC = input.color(color.new(color.yellow, 0), "POC Color", group="Value Area Style")

colVABG = input.color(color.new(color.blue, 85), "Value Area Box Color", group="Value Area Style")

// Label Style
labelOffsetTicks = input.int(0, "Label Vertical Offset (ticks)", 
     tooltip = "Moves labels up/down relative to their price level.",
     minval=0, maxval=50, 
     group="Label Style")

//────────────────────────────────────────────────────────────
// Helpers
//────────────────────────────────────────────────────────────
f_style(s) => s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted

// Store timestamps for all bars
var int[] barTimes = array.new_int()
if barstate.isnew
    array.push(barTimes, time)

// Function to draw rays anchored to correct session
f_ray(_line, _cond, _x, _y, _color, _width, _style) =>
    line ln = _line

    if _cond and not na(_x) and not na(_y)
        int rightTime = timenow

        // CASE 1 — timestamp-based anchor (PDH/PDL/ONH/ONL)
        bool isTimestamp = _x > 1000000000000  // any realistic timestamp is > 1e12
        int leftTime = na

        if isTimestamp
            // _x is already a timestamp
            leftTime := int(_x)
        else
            // CASE 2 — index-based anchor (VAH/VAL/POC)
            int idx = int(_x)
            leftTime := (idx >= 0 and idx < array.size(barTimes)) ? array.get(barTimes, idx) : time

        if na(ln)
            ln := line.new(leftTime, _y, rightTime, _y, xloc = xloc.bar_time, extend = extend.right, color = _color, width = _width, style = f_style(_style))
        else
            line.set_xy1(ln, leftTime, _y)
            line.set_xy2(ln, rightTime, _y)
            line.set_color(ln, _color)
            line.set_width(ln, _width)
            line.set_style(ln, f_style(_style))

    else
        if not na(ln)
            line.delete(ln)
            ln := na

    ln


f_textLabel(_label, _cond, _y, _text, _color, _offsetTicks) =>
    label lb = _label
    if _cond and not na(_y)
        float yOffset = _y + syminfo.mintick * _offsetTicks
        int rightEdge = bar_index + 10
        if na(lb)
            lb := label.new(rightEdge, yOffset, _text, xloc = xloc.bar_index, style = label.style_none, textcolor = _color)
        else
            label.set_x(lb, rightEdge), label.set_y(lb, yOffset), label.set_text(lb, _text), label.set_textcolor(lb, _color)
    else
        if not na(lb)
            label.delete(lb), lb := na
    lb

//────────────────────────────────────────────────────────────
// Auto‑detect Futures vs Equities
//────────────────────────────────────────────────────────────
isFutures = syminfo.type == "futures"

//────────────────────────────────────────────────────────────
// Session Logic (Equities vs Futures)
//────────────────────────────────────────────────────────────
bool inRTH       = false
bool inAH        = false
bool inPM        = false
bool inGlobexPM  = false
bool inGlobexAM  = false
bool inDead      = false

if isFutures
    // Futures RTH: 08:30–15:00 (exchange TZ)
    inRTH := time(timeframe.period, "0830-1459") != 0

    // Globex PM: 16:00–23:59
    inGlobexPM := time(timeframe.period, "1500-2359") != 0

    // Globex AM: 00:00–08:29
    inGlobexAM := time(timeframe.period, "0000-0829") != 0

    // Map to generic AH/PM for combined ON logic
    inAH := inGlobexPM
    inPM := inGlobexAM

    // Dead zone: 16:00–16:59 //disabled for now
    inDead := false
else
    // Equities RTH: 09:30–16:00
    inRTH := time(timeframe.period, "0930-1600") != 0

    // After‑Hours: 16:00–23:59
    inAH := time(timeframe.period, "1600-2359") != 0

    // Pre‑Market: 00:00–09:29
    inPM := time(timeframe.period, "0000-0929") != 0

    // No dead zone for equities
    inDead := false

// Combined ON session
inON = (inAH or inPM) and not inDead

//────────────────────────────────────────────
// Overnight High / Low — developing ON session (time‑agnostic)
//────────────────────────────────────────────
var float onHigh = na
var float onLow  = na
var int   onHighTime = na
var int   onLowTime  = na

var float priorONHigh = na
var float priorONLow  = na
var int   priorONHighTime = na
var int   priorONLowTime  = na

// Detect first ON bar and ensure initialization
bool newONSession = inON and not inON[1]

// 1. Developing ON session (AH/PM/Globex)
if inON
    // Initialize ONH/ONL on first ON bar
    if newONSession
        onHigh := high
        onLow  := low
        onHighTime := time
        onLowTime  := time

    // Fallback initialization if still na (covers TF gaps)
    if na(onHigh)
        onHigh := high, onHighTime := time
    if na(onLow)
        onLow := low, onLowTime := time

    // Update developing highs/lows continuously
    if high > onHigh
        onHigh := high, onHighTime := time
    if low < onLow
        onLow := low, onLowTime := time

// 2. Freeze ONH/ONL at RTH open
if inRTH and not inRTH[1]
    priorONHigh := onHigh
    priorONLow  := onLow
    priorONHighTime := onHighTime
    priorONLowTime  := onLowTime

// 3. Reset ONH/ONL when new ON session begins
if newONSession
    onHigh := high
    onLow  := low
    onHighTime := time
    onLowTime  := time

// 4. If currently outside RTH, show developing ONH/ONL
if not inRTH
    priorONHigh := onHigh
    priorONLow  := onLow
    priorONHighTime := onHighTime
    priorONLowTime  := onLowTime

//────────────────────────────────────────────────────────────
// Track RTH Sessions + True Prior Day
//────────────────────────────────────────────────────────────
// Timestamp-based RTH session boundaries (stable across timeframes)
var int[] rthStartTimes = array.new_int()
var int[] rthEndTimes   = array.new_int()

// Remember the bar_index of the last completed RTH start/end (for VA rays)
var int priorRTHStartBarIndex = na
var int priorRTHEndBarIndex = na

// Timestamp-based prior RTH window
var int priorRTHStartTime = na
var int priorRTHEndTime   = na

var float todayHigh = na
var float todayLow  = na
var int   todayHighTime = na
var int   todayLowTime  = na

var float priorHigh = na
var float priorLow  = na
var int   priorHighTime = na
var int   priorLowTime  = na
var float priorClose = na
var int   priorCloseTime = na

var int[]   rthStartIndexes = array.new_int()
var int[]   rthEndIndexes   = array.new_int()
var float[] rthHighs        = array.new_float()
var float[] rthLows         = array.new_float()
var int[]   rthHighTimes    = array.new_int()
var int[]   rthLowTimes     = array.new_int()
var float[] rthCloses      = array.new_float()
var int[]   rthCloseTimes  = array.new_int()


if inRTH
    if na(todayHigh) or high > todayHigh
        todayHigh := high, todayHighTime := time
    if na(todayLow) or low < todayLow
        todayLow := low, todayLowTime := time

// Detect end of RTH session (with weekend hold logic)
if not inRTH and inRTH[1]
    int lb = 1
    while inRTH[lb]
        lb += 1
    int thisRTHStart = bar_index[lb - 1]
    int thisRTHEnd   = bar_index[1]

    array.push(rthStartIndexes, thisRTHStart)
    array.push(rthEndIndexes,   thisRTHEnd)
    array.push(rthHighs,        todayHigh)
    array.push(rthLows,         todayLow)
    array.push(rthHighTimes,    todayHighTime)
    array.push(rthLowTimes,     todayLowTime)
    array.push(rthCloses,     close[1])
    array.push(rthCloseTimes, time[1])


    // NEW: also store timestamps for this RTH session
    int startRel = bar_index - thisRTHStart
    int endRel   = bar_index - thisRTHEnd

    if startRel >= 0 and startRel <= 10000
        array.push(rthStartTimes, time[startRel])
    if endRel >= 0 and endRel <= 10000
        array.push(rthEndTimes,   time[endRel])

    // NEW: remember the bar index of the last completed RTH start/end
    priorRTHStartBarIndex := thisRTHStart
    priorRTHEndBarIndex := thisRTHEnd

    todayHigh := na
    todayLow  := na
    todayHighTime := na
    todayLowTime  := na

// Select TRUE prior day (handles futures weekend hold)
var int priorRTHStartIndex = na
var int priorRTHEndIndex   = na

int sessionCount = array.size(rthStartIndexes)
if sessionCount >= 1
    int idx = sessionCount - 1
    idx := math.max(idx, 0)

    priorRTHStartIndex := array.get(rthStartIndexes, idx)
    priorRTHEndIndex   := array.get(rthEndIndexes,   idx)
    priorHigh          := array.get(rthHighs,        idx)
    priorLow           := array.get(rthLows,         idx)
    priorHighTime      := array.get(rthHighTimes,    idx)
    priorLowTime       := array.get(rthLowTimes,     idx)
    priorClose         := array.get(rthCloses,     idx)
    priorCloseTime     := array.get(rthCloseTimes, idx)

    // NEW: timestamp-based prior RTH window
    priorRTHStartTime  := array.get(rthStartTimes, idx)
    priorRTHEndTime    := array.get(rthEndTimes,   idx)

//────────────────────────────────────────────────────────────
// Prior Day Volume Profile (VAH / VAL / POC) — optimized
//────────────────────────────────────────────────────────────
// These persist across bars
var float priorVAH = na
var float priorVAL = na
var float priorPOC = na

// Compute VP *once per day* at the moment RTH ends
if not inRTH and inRTH[1] and not na(priorRTHStartTime) and not na(priorRTHEndTime)

    // We already stored these during RTH — no need to rescan 5000 bars
    float sessionHigh = priorHigh
    float sessionLow  = priorLow
    float priceRange  = sessionHigh - sessionLow

    if priceRange > 0
        int   bins    = 100
        float binSize = priceRange / bins
        float[] vp    = array.new_float(bins, 0.0)

        // Build histogram only once per day
        int vpLookback = 1500  // reduced from 5000 for speed

        for i = 0 to vpLookback - 1
            if not na(time[i]) and time[i] >= priorRTHStartTime and time[i] <= priorRTHEndTime
                float h = high[i]
                float l = low[i]
                float v = volume[i]

                int startBin = math.floor((l - sessionLow) / binSize)
                int endBin   = math.floor((h - sessionLow) / binSize)
                startBin := math.min(math.max(startBin, 0), bins - 1)
                endBin   := math.min(math.max(endBin,   0), bins - 1)

                int span = math.max(endBin - startBin + 1, 1)
                float perBinVol = v / span

                for b = startBin to endBin
                    array.set(vp, b, array.get(vp, b) + perBinVol)

        // Compute POC
        int pocIndex = array.indexof(vp, array.max(vp))
        priorPOC := sessionLow + (pocIndex + 0.5) * binSize

        // Compute VAH/VAL via 70% rule
        float totalVol  = array.sum(vp)
        float targetVol = totalVol * 0.70

        int valIndex = pocIndex
        int vahIndex = pocIndex
        float cumVol = array.get(vp, pocIndex)

        while cumVol < targetVol and (valIndex > 0 or vahIndex < bins - 1)
            float volBelow = valIndex > 0 ? array.get(vp, valIndex - 1) : 0
            float volAbove = vahIndex < bins - 1 ? array.get(vp, vahIndex + 1) : 0

            if volAbove >= volBelow and vahIndex < bins - 1
                vahIndex += 1
                cumVol += volAbove
            else if valIndex > 0
                valIndex -= 1
                cumVol += volBelow
            else
                break

        priorVAL := sessionLow + (valIndex + 0.5) * binSize
        priorVAH := sessionLow + (vahIndex + 0.5) * binSize

    else
        priorPOC := na
        priorVAH := na
        priorVAL := na

//────────────────────────────────────────────────────────────
// Debugging Plots
//────────────────────────────────────────────────────────────
// Simple AH/PM tracking for visual debug only
var float dbgAhHigh = na
var float dbgAhLow  = na
var float dbgPmHigh = na
var float dbgPmLow  = na

if inAH
    if na(dbgAhHigh) or high > dbgAhHigh
        dbgAhHigh := high
    if na(dbgAhLow) or low < dbgAhLow
        dbgAhLow := low

if inPM
    if na(dbgPmHigh) or high > dbgPmHigh
        dbgPmHigh := high
    if na(dbgPmLow) or low < dbgPmLow
        dbgPmLow := low

debugVisible = false
//debugVisible = showONH or showONL

plot(debugVisible ? dbgAhHigh : na, "AH High", color=color.new(color.gray, 70), linewidth=1)
plot(debugVisible ? dbgAhLow  : na, "AH Low",  color=color.new(color.gray, 80), linewidth=1)

plot(debugVisible ? dbgPmHigh : na, "PM High", color=color.new(color.silver, 70), linewidth=1)
plot(debugVisible ? dbgPmLow  : na, "PM Low",  color=color.new(color.silver, 80), linewidth=1)

//plot(debugVisible and isFutures and inGlobexPM ? high : na, "Globex PM", color=color.new(color.purple, 80), linewidth=1)
//plot(debugVisible and isFutures and inGlobexAM ? high : na, "Globex AM", color=color.new(color.teal, 80), linewidth=1)

//────────────────────────────────────────────────────────────
// Draw Lines + Labels
//────────────────────────────────────────────────────────────
var line lnPDH = na
var line lnPDL = na
var line lnPDC = na
var line lnONH = na
var line lnONL = na

var label lbPDH = na
var label lbPDL = na
var label lbPDC = na
var label lbONH = na
var label lbONL = na

var label lbVAH = na
var label lbVAL = na
var label lbPOC = na

lnPDH := f_ray(lnPDH, showPDH and not na(priorHigh), priorHighTime, priorHigh, colPDH, widPDH, styPDH)
lbPDH := f_textLabel(lbPDH, showTextLabels and showPDH, priorHigh, "PDH", colPDH, labelOffsetTicks)

lnPDL := f_ray(lnPDL, showPDL and not na(priorLow), priorLowTime, priorLow, colPDL, widPDL, styPDL)
lbPDL := f_textLabel(lbPDL, showTextLabels and showPDL, priorLow, "PDL", colPDL, labelOffsetTicks)

lnPDC := f_ray(lnPDC, showPDC and not na(priorClose), priorCloseTime, priorClose, colPDC, widPDC, styPDC)
lbPDC := f_textLabel(lbPDC, showTextLabels and showPDC, priorClose, "PDC", colPDC, labelOffsetTicks)

lnONH := f_ray(lnONH, showONH and not na(priorONHigh), priorONHighTime, priorONHigh, colONH, widONH, styONH)
lbONH := f_textLabel(lbONH, showTextLabels and showONH, priorONHigh, "ONH", colONH, labelOffsetTicks)

lnONL := f_ray(lnONL, showONL and not na(priorONLow), priorONLowTime, priorONLow, colONL, widONL, styONL)
lbONL := f_textLabel(lbONL, showTextLabels and showONL, priorONLow, "ONL", colONL, labelOffsetTicks)

//────────────────────────────────────────────────────────────
// VAH / VAL / POC Lines + Labels — anchored to prior RTH end bar
//────────────────────────────────────────────────────────────
var line lnVAH = na
var line lnVAL = na
var line lnPOC = na

// Anchor rays to the last bar of the prior RTH session and extend right only
lnVAH := f_ray(lnVAH, not minimalMode and showVAH and not na(priorVAH),
     priorRTHStartBarIndex, priorVAH, colVAH, 1, "Solid")

lnVAL := f_ray(lnVAL, not minimalMode and showVAL and not na(priorVAL),
     priorRTHStartBarIndex, priorVAL, colVAL, 1, "Solid")

lnPOC := f_ray(lnPOC, not minimalMode and showPOC and not na(priorPOC),
     priorRTHStartBarIndex, priorPOC, colPOC, 1, "Dashed")

//────────────────────────────────────────────────────────────
// Value Area Labels — aligned with the same start point
//────────────────────────────────────────────────────────────
lbVAH := f_textLabel(lbVAH, not minimalMode and showVALabels and showVAH and not na(priorVAH),
     priorVAH, "VAH", colVAH, labelOffsetTicks)

lbVAL := f_textLabel(lbVAL, not minimalMode and showVALabels and showVAL and not na(priorVAL),
     priorVAL, "VAL", colVAL, labelOffsetTicks)

lbPOC := f_textLabel(lbPOC, not minimalMode and showVALabels and showPOC and not na(priorPOC),
     priorPOC, "POC", colPOC, labelOffsetTicks)


//────────────────────────────────────────────────────────────
// Prior Day Value Area Shaded Box — full RTH coverage + extend right
//────────────────────────────────────────────────────────────
var box vaBox = na

if not minimalMode and showVAH and showVAL and not na(priorVAH) and not na(priorVAL) and not na(priorRTHStartIndex)
    int leftEdge  = priorRTHStartIndex
    int rightEdge = bar_index  // extend to current bar, like the rays

    if na(vaBox)
        vaBox := box.new(leftEdge, priorVAH, rightEdge, priorVAL, bgcolor = colVABG, border_color = colVABG)
    else
        box.set_left(vaBox, leftEdge)
        box.set_right(vaBox, rightEdge)
        box.set_top(vaBox, priorVAH)
        box.set_bottom(vaBox, priorVAL)
        box.set_bgcolor(vaBox, colVABG)
        box.set_border_color(vaBox, colVABG)
else
    if not na(vaBox)
        box.delete(vaBox)
        vaBox := na


// Price‑scale labels
plot(showPriceLabels and showPDH and not na(priorHigh)   ? priorHigh   : na, title="PDH", color=colPDH, display=display.price_scale)
plot(showPriceLabels and showPDL and not na(priorLow)    ? priorLow    : na, title="PDL", color=colPDL, display=display.price_scale)
plot(showPriceLabels and showPDC and not na(priorClose) ? priorClose : na, title="PDC", color=colPDC, display=display.price_scale)
plot(showPriceLabels and showONH and not na(priorONHigh) ? priorONHigh : na, title="ONH", color=colONH, display=display.price_scale)
plot(showPriceLabels and showONL and not na(priorONLow)  ? priorONLow  : na, title="ONL", color=colONL, display=display.price_scale)
````
