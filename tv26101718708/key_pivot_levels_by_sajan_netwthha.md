# Key Pivot Levels - By Sajan

- url: https://www.tradingview.com/script/NETWThHa-Key-Pivot-Levels-By-Sajan/
- type: indicator
- pine_id: PUB;6f9f8df457f24e07ab781daa8a4cd199
- version: 2.0

## Description

A clean, multi-timeframe key level indicator built for intraday futures/index traders working off higher-timeframe structure.

What it plots:
Daily 50 & 200 SMA — long-term trend anchors
4H 50 & 200 SMA — swing-level bias
1H 50 & 200 SMA — intraday trend filter
Overnight session high/low (Globex, default 18:00–09:30 ET)
Previous day's RTH high/low (default 09:30–16:00 ET, New York session)
Session opening price (RTH open)

All levels are drawn as full-width horizontal lines with a colored price label tagged at the current level, so you always know exactly where each level sits relative to price — no hunting through 
multiple timeframes manually.

Why it's useful:
Instead of flipping between daily/4H/1H charts to track moving averages, or manually marking overnight and prior-day highs/lows every session, this indicator pulls everything into one view on your working timeframe. Great for ORB, fib confluence, or KPL-based strategies that lean on higher-timeframe SMA + session level confluence.

Timezone note: Overnight and RTH sessions are explicitly anchored to America/New_York, so levels stay accurate to the NY session regardless of your chart's display timezone or your own location.

Fully customizable:
SMA lengths (default 50/200)
All line/label colors per timeframe
Session time windows (overnight & RTH)
Label style (left/right) and distance from the last bar
Toggle the opening price line on/off

## Source Code

````pine
//@version=6
// max_bars_back=5000 to allocate enough memory to prevent Replay crashes
indicator("Key Pivot Levels", overlay=true, max_lines_count=50, max_labels_count=50, max_bars_back=5000)

// ============================================================
// INPUTS
// ============================================================
labelStyleInput = input.string("Label Left", "Label Style", options=["Label Left", "Label Right"], group="General")
labelOffset     = input.int(15, "Label Distance From Last Bar", minval=1, group="General")

// --- Lengths ---
lenFast = 50
lenSlow = 200

// --- SMA Colors ---
dailyFastColor = input.color(color.new(#B5124A, 0), "Daily 50 SMA Color", group="SMA Colors")
dailySlowColor = input.color(color.new(#D6194F, 0), "Daily 200 SMA Color", group="SMA Colors")
h4FastColor    = input.color(color.new(#E8791A, 0), "4H 50 SMA Color", group="SMA Colors")
h4SlowColor    = input.color(color.new(#E8791A, 0), "4H 200 SMA Color", group="SMA Colors")
h1FastColor    = input.color(color.new(#F5789A, 0), "1H 50 SMA Color", group="SMA Colors")
h1SlowColor    = input.color(color.new(#F0125F, 0), "1H 200 SMA Color", group="SMA Colors")

// --- Overnight Session ---
overnightSession = "1800-0930"
overnightHighColor = input.color(color.red,   "Overnight High Color", group="Overnight Session")
overnightLowColor  = input.color(color.green, "Overnight Low Color",  group="Overnight Session")

// --- NYC / RTH Session ---
rthSession = "0930-1600"
prevDayHighColor = input.color(color.red,   "Prev Day High Color", group="NYC Session")
prevDayLowColor  = input.color(color.green, "Prev Day Low Color",  group="NYC Session")

// --- Opening Price ---
enableOpeningLine = input.bool(true, "Enable Opening Price Line", group="Opening Price")
openingLineColor  = input.color(color.new(#29B6F6, 0), "Opening Price Line Color", group="Opening Price")
openingLineWidth  = input.int(1, "Opening Price Line Width", minval=1, maxval=5, group="Opening Price")

// ============================================================
// MULTI-TIMEFRAME SMAs
// ============================================================
d_fast  = request.security(syminfo.tickerid, "D",   ta.sma(close, lenFast),  lookahead=barmerge.lookahead_off)
d_slow  = request.security(syminfo.tickerid, "D",   ta.sma(close, lenSlow),  lookahead=barmerge.lookahead_off)
h4_fast = request.security(syminfo.tickerid, "240", ta.sma(close, lenFast),  lookahead=barmerge.lookahead_off)
h4_slow = request.security(syminfo.tickerid, "240", ta.sma(close, lenSlow),  lookahead=barmerge.lookahead_off)
h1_fast = request.security(syminfo.tickerid, "60",  ta.sma(close, lenFast),  lookahead=barmerge.lookahead_off)
h1_slow = request.security(syminfo.tickerid, "60",  ta.sma(close, lenSlow),  lookahead=barmerge.lookahead_off)

// ============================================================
// SESSION TRACKING (Capturing Exact Candle Indexes)
// ============================================================
// --- Overnight Logic ---
ovnTime  = time(timeframe.period, overnightSession, "America/New_York")
newOvn   = na(ovnTime[1]) and not na(ovnTime)
endOvn   = not na(ovnTime[1]) and na(ovnTime)

var float activeOvnHigh    = na
var int   activeOvnHighIdx = na
var float activeOvnLow     = na
var int   activeOvnLowIdx  = na

var float plotOvnHigh      = na
var int   plotOvnHighIdx   = na
var float plotOvnLow       = na
var int   plotOvnLowIdx    = na

if newOvn
    activeOvnHigh    := high
    activeOvnHighIdx := bar_index
    activeOvnLow     := low
    activeOvnLowIdx  := bar_index
else if not na(ovnTime)
    if high > nz(activeOvnHigh, 0)
        activeOvnHigh    := high
        activeOvnHighIdx := bar_index
    if low < nz(activeOvnLow, 999999)
        activeOvnLow     := low
        activeOvnLowIdx  := bar_index

if endOvn
    plotOvnHigh    := activeOvnHigh
    plotOvnHighIdx := activeOvnHighIdx
    plotOvnLow     := activeOvnLow
    plotOvnLowIdx  := activeOvnLowIdx

// --- RTH Logic ---
rthTime  = time(timeframe.period, rthSession, "America/New_York")
newRth   = na(rthTime[1]) and not na(rthTime)
endRth   = not na(rthTime[1]) and na(rthTime)

var float activeRthHigh    = na
var int   activeRthHighIdx = na
var float activeRthLow     = na
var int   activeRthLowIdx  = na

var float prevRthHigh      = na
var int   prevRthHighIdx   = na
var float prevRthLow       = na
var int   prevRthLowIdx    = na

var float rthOpen          = na
var int   rthOpenBarIdx    = na
var int   rthEndBarIdx     = na 

if newRth
    activeRthHigh    := high
    activeRthHighIdx := bar_index
    activeRthLow     := low
    activeRthLowIdx  := bar_index
    rthOpen          := open
    rthOpenBarIdx    := bar_index 
else if not na(rthTime)
    if high > nz(activeRthHigh, 0)
        activeRthHigh    := high
        activeRthHighIdx := bar_index
    if low < nz(activeRthLow, 999999)
        activeRthLow     := low
        activeRthLowIdx  := bar_index

if endRth
    prevRthHigh    := activeRthHigh
    prevRthHighIdx := activeRthHighIdx
    prevRthLow     := activeRthLow
    prevRthLowIdx  := activeRthLowIdx
    rthEndBarIdx   := bar_index

// ============================================================
// DRAWING ENGINE (Array-based Garbage Collection)
// ============================================================
lblStyle = labelStyleInput == "Label Left" ? label.style_label_left : label.style_label_right

// Initialize Arrays to hold active drawings
var array<line>  active_lines  = array.new<line>()
var array<label> active_labels = array.new<label>()

// Helper Function: SMAs
draw_sma(array<line> arr_ln, array<label> arr_lb, float y, string txt, color col, string style, int offset) =>
    if not na(y)
        array.push(arr_ln, line.new(bar_index - 1, y, bar_index, y, color=col, width=1, extend=extend.both))
        array.push(arr_lb, label.new(bar_index + offset, y, txt, style=style, textcolor=color.white, color=col, size=size.normal))

// Helper Function: Session Highs & Lows
draw_session(array<line> arr_ln, array<label> arr_lb, int start_idx, float y, string txt, color col, string style, int offset) =>
    if not na(y) and not na(start_idx)
        array.push(arr_ln, line.new(start_idx, y, bar_index, y, color=col, width=1, extend=extend.right))
        array.push(arr_lb, label.new(bar_index + offset, y, txt, style=style, textcolor=color.white, color=col, size=size.normal))

if barstate.islast
    // 1. CLEAR PREVIOUS DRAWINGS FIRST
    if array.size(active_lines) > 0
        for i = 0 to array.size(active_lines) - 1
            line.delete(array.get(active_lines, i))
        array.clear(active_lines)
        
    if array.size(active_labels) > 0
        for i = 0 to array.size(active_labels) - 1
            label.delete(array.get(active_labels, i))
        array.clear(active_labels)

    // 2. DRAW SMAs
    draw_sma(active_lines, active_labels, d_fast, str.tostring(d_fast, format.mintick) + " D " + str.tostring(lenFast), dailyFastColor, lblStyle, labelOffset)
    draw_sma(active_lines, active_labels, d_slow, str.tostring(d_slow, format.mintick) + " D " + str.tostring(lenSlow), dailySlowColor, lblStyle, labelOffset)
    draw_sma(active_lines, active_labels, h4_fast, str.tostring(h4_fast, format.mintick) + " 4H " + str.tostring(lenFast), h4FastColor, lblStyle, labelOffset)
    draw_sma(active_lines, active_labels, h4_slow, str.tostring(h4_slow, format.mintick) + " 4H " + str.tostring(lenSlow), h4SlowColor, lblStyle, labelOffset)
    draw_sma(active_lines, active_labels, h1_fast, str.tostring(h1_fast, format.mintick) + " 1H " + str.tostring(lenFast), h1FastColor, lblStyle, labelOffset)
    draw_sma(active_lines, active_labels, h1_slow, str.tostring(h1_slow, format.mintick) + " 1H " + str.tostring(lenSlow), h1SlowColor, lblStyle, labelOffset)

    // 3. DRAW SESSIONS
    draw_session(active_lines, active_labels, plotOvnHighIdx, plotOvnHigh, str.tostring(plotOvnHigh, format.mintick) + " ONH", overnightHighColor, lblStyle, labelOffset)
    draw_session(active_lines, active_labels, plotOvnLowIdx, plotOvnLow, str.tostring(plotOvnLow, format.mintick) + " ONL", overnightLowColor, lblStyle, labelOffset)
    draw_session(active_lines, active_labels, prevRthHighIdx, prevRthHigh, str.tostring(prevRthHigh, format.mintick) + " PDH", prevDayHighColor, lblStyle, labelOffset)
    draw_session(active_lines, active_labels, prevRthLowIdx, prevRthLow, str.tostring(prevRthLow, format.mintick) + " PDL", prevDayLowColor, lblStyle, labelOffset)

    // 4. DRAW OPEN LINE
    if enableOpeningLine and not na(rthOpen) and not na(rthOpenBarIdx)
        int openLineEndIdx = (not na(rthEndBarIdx) and rthEndBarIdx >= rthOpenBarIdx) ? rthEndBarIdx : bar_index
        array.push(active_lines, line.new(rthOpenBarIdx, rthOpen, openLineEndIdx, rthOpen, color=openingLineColor, width=openingLineWidth, extend=extend.none))
````
