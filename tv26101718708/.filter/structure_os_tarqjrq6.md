# Structure OS

- url: https://www.tradingview.com/script/tArQJrQ6-Structure-OS/
- type: indicator
- pine_id: PUB;ef25976e684f4f64a2d240ba44be3796
- version: 1.0

## Description

Make an indicator that OVERVIEW
Structure OS is a price action structure indicator that maps swing highs, swing lows, and structural breaks using a candle pullback confirmation system no lagging indicators, no arbitrary lookback periods.

The indicator runs two independent structure detection engines simultaneously (swing and internal), both using the same confirmation logic but at different structural scopes. A multi-timeframe dashboard provides directional bias and structure state across higher timeframes.

HOW THIS DIFFERS FROM EXISTING OPEN-SOURCE STRUCTURE SCRIPTS
Most publicly available market structure indicators identify swing points using ta.pivothigh() and ta.pivotlow() - fixed-period lookback functions that define a swing high as "the highest point over N bars." This approach produces a flat list of pivot points with no validation that a genuine reversal attempt occurred at those levels.

Structure OS uses a fundamentally different detection method: Instead of a lookback window, the indicator tracks price in real time and requires a sequence of three consecutive opposing candles
each closing beyond the previous one's body - before confirming a swing point. If price exceeds the tracking extreme before three candles complete, the count resets to zero and restarts.

This distinction matters because the same raw price data produces different structural maps depending on which method is used. A fixed-lookback pivot may confirm a swing high that the pullback confirmation method rejects (because the pullback lacked three consecutive candles), and vice versa. Different swing points mean different BOS and CHOCH events, which means entirely different trade signals.

SWING STRUCTURE ENGINE

When price makes a move, the indicator begins tracking a candidate swing point.

Confirmation requires:

Three consecutive opposing candles (bearish candles to confirm a high, bullish to confirm a low) Each candle in the sequence must close beyond the previous one's low (for bearish) or high (for bullish) If price makes a new extreme before three candles complete, the candidate resets and the count starts over

Once two swing points are confirmed, a trading range is established between the swing high and swing low. A candle close beyond the range boundary triggers:
BOS (Break of Structure) - close beyond the swing level in the direction of the current trend. CHOCH (Change of Character) close beyond the swing level against the prevailing trend. Signals reversal.

Confirms continuation.

Wicks through a level do not qualify. Only a candle close beyond the structural level triggers a break event.

Unconfirmed candidate levels are shown as dotted lines so traders can see where a potential swing point is forming before the three-candle count completes.

INTERNAL STRUCTURE ENGINE

Internal structure uses the same

three-candle confirmation logic but is scoped exclusively within the current confirmed swing high and swing low.

It activates only after a new swing point is established. It resets completely when a new swing BOS or CHOCH occurs. It cannot detect or plot structure outside the active swing boundaries.

This separation ensures that pullbacks within a swing range are tracked independently from swing-level reversals. Internal BOS and CHOCH events are labeled as IBOS and iCHOCH respectively, drawn with dashed lines to visually distinguish them from swing structure.

MULTI-TIMEFRAME
DASHBOARD

The on-chart dashboard has two sections:

Directional Bias - Compares the previous candle's close against prior period highs and lows on Weekly and Daily timeframes. Classifies bias as Bullish, Bearish, or neutral based on whether close exceeded the previous period's high or low, or whether a sweep occurred (high/low broken but close returned inside).

Market Structure - Runs the same swing detection engine on H4, 15M, and 1M via request.security(). Reports current bias direction and structure stage (Shift, Confirmed Shift, Expansion, or Continuation) for each timeframe. Only displays timeframes that are higher than thecurrent chart.

SESSION MAPPING

Configurable session highlighting for Asia, London, and New York.

Each session draws a box from session open to close, tracking the high and low in real time. A "Current Week Only" toggle keeps the chart clean by removing older session boxes. All session times, colours, and toggles are independently configurable.

FEATURES

Swing Structure - BOS and CHOCH detection with HH/HL/LH/LL swing labels

Internal Structure - Same 3-candle

logic running inside the current swing range, with independent display settings

Current Range Display - Horizontal lines marking the active swing high and swing low. Solid when confirmed, dotted while tracking Close-Only Break Validation Wicks do not trigger breaks at swing or internal level

Pullback Confirmation - Three

consecutive opposing candles

required. Count resets if price

makes a new extreme

Multi-Timeframe Dashboard

Directional bias (Weekly/Daily) and

market structure state

(H4/15M/1M)

Optional H4 Swing Level Overlay Plots H4 swing high/low as horizontal lines on lower timeframe chartsDirectional bias (Weekly/Daily) and market structure state

(H4/15M/1M)

Optional H4 Swing Level Overlay Plots H4 swing high/low as horizontal lines on lower timeframe charts

Session Mapping - Asia, London, New York with tracked highs/lows Bar Colouring - Optional candle colouring by current swing bias Full Customisation - Independent colour, label size, and BOS/CHOCH toggle settings for both swing and internal structure.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("Structure OS", "Structure OS", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// --- Groups ---
group_swing    = "Swing Structure"
group_internal = "Internal Structure"
group_dash     = "Dashboard"
group_sessions = "Sessions"
group_style    = "Visuals"

// --- Inputs ---
showSwing      = input.bool(true, "Show Swing Structure", group = group_swing)
swingBullColor = input.color(#089981, "Swing Bullish Color", group = group_swing)
swingBearColor = input.color(#f23645, "Swing Bearish Color", group = group_swing)
showH4Overlay  = input.bool(false, "Overlay H4 Swing Levels", group = group_swing)

showInternal      = input.bool(true, "Show Internal Structure", group = group_internal)
internalBullColor = input.color(color.new(#089981, 50), "Internal Bullish Color", group = group_internal)
internalBearColor = input.color(color.new(#f23645, 50), "Internal Bearish Color", group = group_internal)

showDash = input.bool(true, "Show Dashboard", group = group_dash)
dashPos  = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group = group_dash)

showSessions = input.bool(true, "Show Sessions", group = group_sessions)
thisWeekOnly = input.bool(true, "Current Week Only", group = group_sessions)
asiaTime     = input.session("0000-0900", "Asia Session", group = group_sessions)
londonTime   = input.session("0800-1700", "London Session", group = group_sessions)
nyTime       = input.session("1300-2200", "New York Session", group = group_sessions)

asiaColor    = input.color(color.new(#5b9cf6, 90), "Asia Color", group = group_sessions)
londonColor  = input.color(color.new(#e2aa05, 90), "London Color", group = group_sessions)
nyColor      = input.color(color.new(#ff5d00, 90), "NY Color", group = group_sessions)

colorBars = input.bool(false, "Color Bars by Bias", group = group_style)

// --- Types ---
type HTFData
    float h
    float l
    float pc
    float c

// --- Core Logic ---
// Swing Tracker Variables
var float eH = 0.0
var int eHX = 0
var int cH = 0
var float eL = 10e10
var int eLX = 0
var int cL = 0

var float swH = na
var int swHX = 0
var float swL = na
var int swLX = 0
var bool swBull = true

// Internal Tracker Variables
var float iH = na
var int iHX = 0
var float iL = na
var int iLX = 0
var int ciH = 0
var float eiH = 0.0
var int eiHX = 0
var int ciL = 0
var float eiL = 10e10
var int eiLX = 0

// Tracking Lines
var line trackH = line.new(na, na, na, na, style = line.style_dotted)
var line trackL = line.new(na, na, na, na, style = line.style_dotted)

// 3-Candle Confirmation
// High Tracking
if high >= eH or na(eH)
    eH := high
    eHX := bar_index
    cH := 0
else if close < open and close < low[1]
    cH += 1

if cH == 3
    if eH != swH
        swH := eH
        swHX := eHX
        if showSwing
            label.new(eHX, eH, "HH", color = #00000000, textcolor = swingBullColor, style = label.style_label_down, size = size.small)
    cH := 0
    eH := 0.0

// Low Tracking
if low <= eL or na(eL)
    eL := low
    eLX := bar_index
    cL := 0
else if close > open and close > high[1]
    cL += 1

if cL == 3
    if eL != swL
        swL := eL
        swLX := eLX
        if showSwing
            label.new(eLX, eL, "LL", color = #00000000, textcolor = swingBearColor, style = label.style_label_up, size = size.small)
    cL := 0
    eL := 10e10

// Break Detection
bool swBreak = false
if not na(swH) and close > swH
    swBreak := true
    string lbl = swBull ? "BOS" : "CHOCH"
    if showSwing
        line.new(swHX, swH, bar_index, swH, color = swingBullColor)
        label.new(bar_index, swH, lbl, color = #00000000, textcolor = swingBullColor, style = label.style_label_down, size = size.tiny)
    alert("Structure OS: " + syminfo.ticker + " Swing Bullish " + lbl, alert.freq_once_per_bar)
    swH := na
    swBull := true
else if not na(swL) and close < swL
    swBreak := true
    string lbl = not swBull ? "BOS" : "CHOCH"
    if showSwing
        line.new(swLX, swL, bar_index, swL, color = swingBearColor)
        label.new(bar_index, swL, lbl, color = #00000000, textcolor = swingBearColor, style = label.style_label_up, size = size.tiny)
    alert("Structure OS: " + syminfo.ticker + " Swing Bearish " + lbl, alert.freq_once_per_bar)
    swL := na
    swBull := false

// Tracking Visuals
if not na(eH) and eH > 0 and showSwing
    line.set_xy1(trackH, bar_index - 2, eH)
    line.set_xy2(trackH, bar_index, eH)
    line.set_color(trackH, color.new(swingBullColor, 50))
else
    line.set_xy1(trackH, na, na)

if not na(eL) and eL < 10e10 and showSwing
    line.set_xy1(trackL, bar_index - 2, eL)
    line.set_xy2(trackL, bar_index, eL)
    line.set_color(trackL, color.new(swingBearColor, 50))
else
    line.set_xy1(trackL, na, na)

// --- Internal Engine ---
if swBreak
    iH := na
    iL := na
    ciH := 0
    eiH := 0.0
    ciL := 0
    eiL := 10e10

if showInternal and not na(swH) and not na(swL)
    // Internal High
    if high >= eiH or na(eiH)
        eiH := high
        eiHX := bar_index
        ciH := 0
    else if close < open and close < low[1]
        ciH += 1
    
    if ciH == 3 and eiH < swH and eiH > swL
        iH := eiH
        iHX := eiHX
        label.new(eiHX, eiH, "iH", color = #00000000, textcolor = internalBullColor, style = label.style_label_down, size = size.tiny)
        ciH := 0
        eiH := 0.0
        
    // Internal Low
    if low <= eiL or na(eiL)
        eiL := low
        eiLX := bar_index
        ciL := 0
    else if close > open and close > high[1]
        ciL += 1
        
    // Internal Breaks
    if not na(iH) and close > iH
        line.new(iHX, iH, bar_index, iH, color = internalBullColor, style = line.style_dashed)
        label.new(bar_index, iH, "iBOS", color = #00000000, textcolor = internalBullColor, style = label.style_label_down, size = size.tiny)
        alert("Structure OS: " + syminfo.ticker + " Internal Bullish BOS", alert.freq_once_per_bar)
        iH := na
    else if not na(iL) and close < iL
        line.new(iLX, iL, bar_index, iL, color = internalBearColor, style = line.style_dashed)
        label.new(bar_index, iL, "iBOS", color = #00000000, textcolor = internalBearColor, style = label.style_label_up, size = size.tiny)
        alert("Structure OS: " + syminfo.ticker + " Internal Bearish BOS", alert.freq_once_per_bar)
        iL := na

// --- Sessions ---
update_session(sess, col) =>
    var box b = na
    var float h = 0.0
    var float l = 0.0
    inSess = not na(time(timeframe.period, sess, "UTC"))
    isNew = inSess and not inSess[1]
    
    if isNew
        h := high
        l := low
        b := box.new(bar_index, h, bar_index, l, bgcolor = col, border_color = col)
        float(na)
    else if inSess
        h := math.max(h, high)
        l := math.min(l, low)
        box.set_top(b, h)
        box.set_bottom(b, l)
        box.set_right(b, bar_index)
        float(na)
    else
        float(na)

if showSessions
    update_session(asiaTime, asiaColor)
    update_session(londonTime, londonColor)
    update_session(nyTime, nyColor)

// --- Dashboard Logic ---
get_htf_data(res) =>
    request.security(syminfo.tickerid, res, HTFData.new(high[1], low[1], close[1], close))

wData = get_htf_data("W")
dData = get_htf_data("D")
h4Data = get_htf_data("240")
m15Data = get_htf_data("15")
m1Data = get_htf_data("1")

calc_bias(data) =>
    if data.c > data.h
        ["Bullish", swingBullColor]
    else if data.c < data.l
        ["Bearish", swingBearColor]
    else if high > data.h and data.c < data.h
        ["B-Sweep", swingBearColor]
    else if low < data.l and data.c > data.l
        ["S-Sweep", swingBullColor]
    else
        ["Neutral", chart.fg_color]

get_state(data) =>
    bull = data.c > data.pc
    state = data.c > data.h ? "Expansion" : data.c < data.l ? "Shift" : "Continuation"
    [state, bull ? swingBullColor : swingBearColor]

[wBias, wCol] = calc_bias(wData)
[dBias, dCol] = calc_bias(dData)
[h4State, h4Col] = get_state(h4Data)
[m15State, m15Col] = get_state(m15Data)
[m1State, m1Col] = get_state(m1Data)

var table dash = table.new(dashPos == "Top Right" ? position.top_right : dashPos == "Bottom Right" ? position.bottom_right : dashPos == "Top Left" ? position.top_left : position.bottom_left, 2, 8, border_width = 1, frame_color = chart.fg_color)

if showDash and barstate.islast
    table.cell(dash, 0, 0, "Timeframe", bgcolor = chart.fg_color, text_color = chart.bg_color)
    table.cell(dash, 1, 0, "Bias/State", bgcolor = chart.fg_color, text_color = chart.bg_color)
    
    int row = 1
    if timeframe.isintraday
        table.cell(dash, 0, row, "Weekly"), table.cell(dash, 1, row, wBias, text_color = wCol), row += 1
        table.cell(dash, 0, row, "Daily"), table.cell(dash, 1, row, dBias, text_color = dCol), row += 1
        
        if timeframe.in_seconds() < timeframe.in_seconds("240")
            table.cell(dash, 0, row, "H4"), table.cell(dash, 1, row, h4State, text_color = h4Col), row += 1
        
        if timeframe.in_seconds() < timeframe.in_seconds("15")
            table.cell(dash, 0, row, "15M"), table.cell(dash, 1, row, m15State, text_color = m15Col), row += 1
            
        if timeframe.in_seconds() < timeframe.in_seconds("1")
            table.cell(dash, 0, row, "1M"), table.cell(dash, 1, row, m1State, text_color = m1Col), row += 1

// --- H4 Overlay ---
h4_h = request.security(syminfo.tickerid, "240", high)
h4_l = request.security(syminfo.tickerid, "240", low)
plot(showH4Overlay ? h4_h : na, "H4 High", color = color.new(swingBullColor, 70), style = plot.style_linebr)
plot(showH4Overlay ? h4_l : na, "H4 Low", color = color.new(swingBearColor, 70), style = plot.style_linebr)

// --- Visuals ---
plot(swH, "Swing High Range", color = swingBullColor, style = plot.style_linebr, linewidth = 2)
plot(swL, "Swing Low Range", color = swingBearColor, style = plot.style_linebr, linewidth = 2)

barcolor(colorBars ? (swBull ? swingBullColor : swingBearColor) : na)
````
