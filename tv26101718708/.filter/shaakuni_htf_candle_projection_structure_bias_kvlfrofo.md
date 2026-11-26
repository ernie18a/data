# Shaakuni HTF Candle Projection & Structure Bias

- url: https://www.tradingview.com/script/kVlFRofo-Shaakuni-HTF-Candle-Projection-Structure-Bias/
- type: indicator
- pine_id: PUB;91db85756fa241e786a5a3c2db5cfd5a
- version: 1.0

## Description

Overview

Shaakuni HTF Candle Projection & Structure Bias lets you keep an eye on a higher-timeframe (HTF) candle while you work on a lower-timeframe chart. It builds the currently forming HTF candle from your chart's own bars and shows a copy of it to the right of price, so you can see its open, high, low, close and range at a glance. It also draws session high/low boxes (Asian, London, New York, London Close) and can show an optional table with a simple structure reading for 1H, 4H and 1D. It does not give buy or sell signals, it does not forecast where the HTF candle will close, and it does not detect Power of 3 phases.

Why these parts are in one script

A higher-timeframe candle shows where the larger-scale open, high and low are. Session boxes show how smaller intraday ranges formed inside that candle. The optional structure table adds a quick top-down reading of 1H, 4H and 1D. Together they give a top-down view on one chart without switching timeframes. Each part can be switched off in the settings.

Key concept

Power of 3 (PO3) is a framework in which a candle is read as three stages: accumulation, manipulation and distribution. A common way to study it is to watch a higher-timeframe candle's open and see how price moves relative to it during the trading sessions. This script does not label those stages. It supplies the pieces (the live HTF candle with its open, and the session ranges) so you can observe them yourself.

How the projected candle works

On every bar the script checks whether a new HTF candle has started, using the symbol's own HTF time boundaries. When one starts, it stores that bar's open, and then updates the high and low with every chart bar; the close is the latest price. On the last bar the script draws a candle to the right of price, shifted by "Right Offset" bars, with a body width set by "Projected Candle Width". Dashed lines connect the HTF open, high and low from the bar where the candle began to the projected candle, and labels show O, H, L, C and the range. The candle is green when close is at or above open and red otherwise. This is a live copy of the current HTF candle and not a prediction. It is drawn in the empty area to the right only to keep it out of the way of price.

Structure table

The table is optional and off by default ("Show Context Table"). For each of 1H, 4H and 1D, the script finds confirmed pivot highs and pivot lows using "Swing Pivot Length" (default 5 bars on each side) and compares the last two highs and the last two lows. If both are rising it shows BULLISH, if both are falling it shows BEARISH, and otherwise NEUTRAL. A pivot is only confirmed after that many bars have passed, so this reading lags by design. The data is requested without look-ahead. It is a simple higher-high / lower-low reading, not a full break-of-structure model. The table also shows the session that is currently active.

Session boxes

For each enabled session the script draws a box from the start of the session, expanding to the highest high and lowest low reached, with a label. Boxes are kept for the last N days ("Show Sessions For"). Default times are in New York time: Asian 20:00-00:00, London 02:00-05:00, New York 07:00-10:00, London Close 10:00-12:00. Times, colours and the timezone can be changed. Session boxes need an intraday chart.

How to use it

For example, on a 5 or 15 minute chart with the Daily as the higher timeframe, the projected candle shows where the daily open is relative to current price and how large the day's range is so far. The session boxes show whether, for example, London or New York traded above or below the Asian range. Many traders use references like these as context for their own analysis; the script does not tell you when to enter or exit.

Why it is built this way

HTF candle displays and session boxes are common ideas and this script does not claim to have invented them. What it combines is a live HTF candle with an adjustable offset and mapping lines back to its open, editable session ranges, and an optional pivot-based structure reading for three timeframes, in one script with open source code that you can read and change.

Limitations

The HTF must be higher than the chart timeframe; otherwise nothing is projected and the table shows a message. HTF candle boundaries follow the symbol's own session, so the daily open can differ from other data providers. If the chart has little history loaded, the first HTF candle can be partial. The 1H, 4H and 1D readings can change until those bars close, and pivots confirm late by design. Session boxes need an intraday chart. This is a visual aid and not financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Shaakuni

//@version=6
// =============================================================================
//  Shaakuni HTF Candle Projection & Structure Bias
//  Version 2.0.0
//
//  WHAT THIS SCRIPT DOES
//   1) Projects the currently forming Higher-Timeframe (HTF) candle (O/H/L/C) to the right of the chart,
//      built from the chart's own bars, so you can see the HTF candle while trading a lower timeframe.
//   2) Shows a simple structure reading for 1H / 4H / 1D in a small table:
//        BULLISH = last two confirmed pivot highs AND last two pivot lows are both rising
//        BEARISH = last two confirmed pivot highs AND last two pivot lows are both falling
//        NEUTRAL = anything else
//   3) Draws session High/Low boxes (Asian, London, New York, London Close) for the last N days.
//
//  WHAT IT DOES NOT DO
//   It does not detect the Power-of-3 phases (accumulation / manipulation / distribution) and it does not
//   give buy/sell signals. "PO3" is only the context the HTF candle is meant to help you read.
//
//  LIMITATIONS
//   - Pivots need `Swing Pivot Length` bars to confirm, so the structure reading lags by design.
//   - The projected candle is built from loaded chart bars; with little history the first HTF candle may be partial.
//   - The HTF must be higher than the chart timeframe. Session boxes need an intraday chart.
// =============================================================================
indicator(
     "Shaakuni HTF Candle Projection & Structure Bias",
     shorttitle       = "Shaakuni HTF Context",
     overlay          = true,
     max_boxes_count  = 500,
     max_lines_count  = 500,
     max_labels_count = 500
     )

// =============================================================================
// INPUTS
// =============================================================================
grpHTF   = "Higher Timeframe"
grpStyle = "Style"
grpBias  = "Structure Bias"
grpTbl   = "Table"
gSess    = "Session Boxes"

// ---- HTF projection ----
htfInput    = input.timeframe("D", "Higher Timeframe", group = grpHTF, tooltip = "Must be higher than the chart timeframe.")
offsetInput = input.int(15, "Right Offset (bars)", minval = 5, maxval = 300, group = grpHTF)
widthInput  = input.int(10, "Projected Candle Width (bars)", minval = 2, maxval = 100, group = grpHTF)

// ---- Style ----
bullColor  = input.color(#26A69A, "Bullish Color", group = grpStyle)
bearColor  = input.color(#EF5350, "Bearish Color", group = grpStyle)
mapColor   = input.color(color.new(color.gray, 40), "Mapping Line Color", group = grpStyle)
showLabels = input.bool(true, "Show O/H/L/C Labels", group = grpStyle)
showRange  = input.bool(true, "Show Range Label", group = grpStyle)

// ---- Structure bias ----
swingLenStruct = input.int(5, "Swing Pivot Length", minval = 1, maxval = 50, group = grpBias, tooltip = "Bars on each side used to confirm a pivot high/low on the 1H, 4H and 1D timeframes.")

// ---- Table ----
showTable   = input.bool(false, "Show Context Table (1H/4H/1D structure + session)", group = grpTbl)
tblPosInput = input.string("Top Right", "Table Position", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Middle Left", "Middle Right"], group = grpTbl)

// ---- Sessions ----
showSession     = input.bool(true, "Show Session High / Low Boxes", group = gSess)

sessAsiaEnable  = input.bool(true, "Asian Session", group = gSess)
sessAsiaTime    = input.session("2000-0000", "Asian Time", group = gSess)
asiaColor       = input.color(color.new(color.blue, 90), "Asian Box Color", group = gSess)

sessLdnEnable   = input.bool(true, "London Session", group = gSess)
sessLdnTime     = input.session("0200-0500", "London Time", group = gSess)
ldnColor        = input.color(color.new(color.teal, 90), "London Box Color", group = gSess)

sessNyEnable    = input.bool(true, "New York Session", group = gSess)
sessNyTime      = input.session("0700-1000", "New York Time", group = gSess)
nyColor         = input.color(color.new(color.orange, 90), "New York Box Color", group = gSess)

sessLdnClsEnable = input.bool(true, "London Close Session", group = gSess)
sessLdnClsTime   = input.session("1000-1200", "London Close Time", group = gSess)
ldnClsColor      = input.color(color.new(color.purple, 90), "London Close Box Color", group = gSess)

sessDays = input.int(2, "Show Sessions For (Days)", minval = 1, maxval = 10, group = gSess)
sessTZ   = input.string("America/New_York", "Session Timezone", options = ["America/New_York", "UTC", "Europe/London", "Asia/Kolkata", "Asia/Dubai", "Asia/Tokyo", "Australia/Sydney"], group = gSess, tooltip = "Session times above are interpreted in this timezone. Default times are New York time.")

sessLabelTextColor = input.color(color.white, "Session Label Text Color", group = gSess)
sessLabelBgColor   = input.color(color.new(color.black, 20), "Session Label Background Color", group = gSess)
sessLabelSizeInput = input.string("Small", "Session Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = gSess)

lblSize = sessLabelSizeInput == "Tiny" ? size.tiny : sessLabelSizeInput == "Small" ? size.small : sessLabelSizeInput == "Normal" ? size.normal : size.large

// =============================================================================
// HTF VALIDATION
// =============================================================================
htfValid = timeframe.in_seconds(htfInput) > timeframe.in_seconds(timeframe.period)

// =============================================================================
// TRACK THE CURRENT (FORMING) HTF CANDLE USING CHART BARS
// =============================================================================
var float htfOpen = na
var float htfHigh = na
var float htfLow  = na
var int   htfOIdx = na

htfTimeChange = ta.change(time(htfInput))
isNewHtfBar   = htfValid and htfTimeChange != 0

if isNewHtfBar
    htfOpen := open
    htfHigh := high
    htfLow  := low
    htfOIdx := bar_index
else if not na(htfOIdx)
    htfHigh := math.max(htfHigh, high)
    htfLow  := math.min(htfLow, low)

htfClose = close

// =============================================================================
// TIMEFRAME LABEL TEXT
// =============================================================================
f_tfText(string tf) =>
    float secs = timeframe.in_seconds(tf)
    string txt = ""
    if secs >= 2419200
        txt := "M"
    else if secs >= 604800
        txt := "W"
    else if secs >= 86400
        txt := str.tostring(math.round(secs / 86400)) + "D"
    else if secs >= 3600
        txt := str.tostring(math.round(secs / 3600)) + "H"
    else if secs >= 60
        txt := str.tostring(math.round(secs / 60)) + "m"
    else
        txt := str.tostring(math.round(secs)) + "s"
    txt

htfLabelText = f_tfText(htfInput)

// =============================================================================
// STRUCTURE BIAS (1H / 4H / 1D) — last two confirmed pivots
// =============================================================================
f_structureBias(int len) =>
    float ph  = ta.pivothigh(high, len, len)
    float pl  = ta.pivotlow(low, len, len)
    float ph1 = ta.valuewhen(not na(ph), ph, 0)
    float ph2 = ta.valuewhen(not na(ph), ph, 1)
    float pl1 = ta.valuewhen(not na(pl), pl, 0)
    float pl2 = ta.valuewhen(not na(pl), pl, 1)

    bool hasAll     = not na(ph1) and not na(ph2) and not na(pl1) and not na(pl2)
    bool bullStruct = hasAll and ph1 > ph2 and pl1 > pl2
    bool bearStruct = hasAll and ph1 < ph2 and pl1 < pl2

    string result = bullStruct ? "BULLISH" : bearStruct ? "BEARISH" : "NEUTRAL"
    result

bias1H = request.security(syminfo.tickerid, "60",  f_structureBias(swingLenStruct), lookahead = barmerge.lookahead_off)
bias4H = request.security(syminfo.tickerid, "240", f_structureBias(swingLenStruct), lookahead = barmerge.lookahead_off)
bias1D = request.security(syminfo.tickerid, "D",   f_structureBias(swingLenStruct), lookahead = barmerge.lookahead_off)

// =============================================================================
// SESSION BOXES (multi-day)
// =============================================================================
f_drawSessionBox(bool sessEnable, string sessTime, string sessName, color boxColor) =>
    var array<box>   boxes      = array.new<box>()
    var array<label> labels     = array.new<label>()
    var array<int>   startTimes = array.new<int>()

    var box   curBox   = na
    var label curLabel = na
    var float sHigh    = na
    var float sLow     = na

    int msLimit = sessDays * 86400000
    bool isWithinDays = (timenow - time) <= msLimit

    bool inSess = sessEnable and showSession and isWithinDays and not na(time(timeframe.period, sessTime, sessTZ))

    if inSess and not inSess[1]
        sHigh := high
        sLow  := low
        curBox := box.new(left = bar_index, top = sHigh, right = bar_index, bottom = sLow,
             border_color = color.new(boxColor, 0), border_style = line.style_dashed,
             bgcolor = boxColor)
        curLabel := label.new(bar_index, sHigh, text = " " + sessName + " ", style = label.style_label_down,
             color = sessLabelBgColor, textcolor = sessLabelTextColor, size = lblSize)
        array.push(boxes, curBox)
        array.push(labels, curLabel)
        array.push(startTimes, time)
    else if inSess and not na(curBox)
        sHigh := math.max(sHigh, high)
        sLow  := math.min(sLow, low)
        box.set_top(curBox, sHigh)
        box.set_bottom(curBox, sLow)
        box.set_right(curBox, bar_index)
        label.set_xy(curLabel, box.get_left(curBox), sHigh)

    // Delete session boxes older than N days
    if array.size(boxes) > 0
        for i = array.size(boxes) - 1 to 0
            int sTime = array.get(startTimes, i)
            if (timenow - sTime) > msLimit
                box.delete(array.get(boxes, i))
                label.delete(array.get(labels, i))
                array.remove(boxes, i)
                array.remove(labels, i)
                array.remove(startTimes, i)
    true

f_drawSessionBox(sessAsiaEnable, sessAsiaTime, "Asian", asiaColor)
f_drawSessionBox(sessLdnEnable, sessLdnTime, "London", ldnColor)
f_drawSessionBox(sessNyEnable, sessNyTime, "New York", nyColor)
f_drawSessionBox(sessLdnClsEnable, sessLdnClsTime, "London Close", ldnClsColor)

// Session active on the latest bar (shown in the table)
isCurrentDay = year(time) == year(timenow) and month(time) == month(timenow) and dayofmonth(time) == dayofmonth(timenow)

inAsia   = sessAsiaEnable and showSession and isCurrentDay and not na(time(timeframe.period, sessAsiaTime, sessTZ))
inLdn    = sessLdnEnable and showSession and isCurrentDay and not na(time(timeframe.period, sessLdnTime, sessTZ))
inNy     = sessNyEnable and showSession and isCurrentDay and not na(time(timeframe.period, sessNyTime, sessTZ))
inLdnCls = sessLdnClsEnable and showSession and isCurrentDay and not na(time(timeframe.period, sessLdnClsTime, sessTZ))

string currentSessName  = "No Session"
color  currentSessColor = color.gray

if inAsia
    currentSessName  := "Asian"
    currentSessColor := color.blue
else if inLdn
    currentSessName  := "London"
    currentSessColor := color.teal
else if inNy
    currentSessName  := "New York"
    currentSessColor := color.orange
else if inLdnCls
    currentSessName  := "London Close"
    currentSessColor := color.purple

// =============================================================================
// CONTEXT TABLE
// =============================================================================
f_tblPos(string p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        "Middle Left"  => position.middle_left
        => position.middle_right

f_biasColor(string b) =>
    b == "BULLISH" ? bullColor : b == "BEARISH" ? bearColor : color.gray

var table ctxTbl = table.new(f_tblPos(tblPosInput), 2, 5, bgcolor = color.new(#141414, 5), border_color = color.new(#2a2a2a, 0), border_width = 1, frame_color = color.new(#2a2a2a, 0), frame_width = 1)

if barstate.islast and showTable
    table.cell(ctxTbl, 0, 0, "Shaakuni HTF Context", text_color = color.rgb(255, 200, 80), text_size = size.small, text_halign = text.align_left, bgcolor = color.new(#1f1f1f, 0))
    table.cell(ctxTbl, 1, 0, syminfo.ticker + " / " + timeframe.period, text_color = color.gray, text_size = size.small, text_halign = text.align_right, bgcolor = color.new(#1f1f1f, 0))

    table.cell(ctxTbl, 0, 1, "1H Structure", text_color = color.silver, text_size = size.small, text_halign = text.align_left)
    table.cell(ctxTbl, 1, 1, na(bias1H) ? "-" : bias1H, text_color = f_biasColor(bias1H), text_size = size.small, text_halign = text.align_right)

    table.cell(ctxTbl, 0, 2, "4H Structure", text_color = color.silver, text_size = size.small, text_halign = text.align_left)
    table.cell(ctxTbl, 1, 2, na(bias4H) ? "-" : bias4H, text_color = f_biasColor(bias4H), text_size = size.small, text_halign = text.align_right)

    table.cell(ctxTbl, 0, 3, "1D Structure", text_color = color.silver, text_size = size.small, text_halign = text.align_left)
    table.cell(ctxTbl, 1, 3, na(bias1D) ? "-" : bias1D, text_color = f_biasColor(bias1D), text_size = size.small, text_halign = text.align_right)

    table.cell(ctxTbl, 0, 4, "Session", text_color = color.silver, text_size = size.small, text_halign = text.align_left)
    table.cell(ctxTbl, 1, 4, htfValid ? currentSessName : "HTF must be > chart TF", text_color = htfValid ? currentSessColor : color.orange, text_size = size.small, text_halign = text.align_right)

// =============================================================================
// DRAW — HTF PROJECTION
// =============================================================================
var box   projBox  = na
var line  projWick = na
var line  mapOpen  = na
var line  mapHigh  = na
var line  mapLow   = na
var label lblOpen  = na
var label lblHigh  = na
var label lblLow   = na
var label lblClose = na
var label lblRange = na

if barstate.islast
    box.delete(projBox)
    line.delete(projWick)
    line.delete(mapOpen)
    line.delete(mapHigh)
    line.delete(mapLow)
    label.delete(lblOpen)
    label.delete(lblHigh)
    label.delete(lblLow)
    label.delete(lblClose)
    label.delete(lblRange)

    if htfValid and not na(htfOIdx)
        int startIdx = last_bar_index + offsetInput
        int endIdx   = startIdx + widthInput
        int midIdx   = math.round((startIdx + endIdx) / 2)

        bool  isBull      = htfClose >= htfOpen
        color candleColor = isBull ? bullColor : bearColor

        // Wick first, body on top
        projWick := line.new(midIdx, htfHigh, midIdx, htfLow, color = candleColor, width = 2)
        projBox  := box.new(startIdx, math.max(htfOpen, htfClose), endIdx, math.min(htfOpen, htfClose),
             border_color = candleColor, bgcolor = color.new(candleColor, 0), border_width = 1)

        // Dashed mapping lines from the HTF candle's open bar
        mapOpen := line.new(htfOIdx, htfOpen, startIdx, htfOpen, color = mapColor, style = line.style_dashed)
        mapHigh := line.new(htfOIdx, htfHigh, startIdx, htfHigh, color = mapColor, style = line.style_dashed)
        mapLow  := line.new(htfOIdx, htfLow,  startIdx, htfLow,  color = mapColor, style = line.style_dashed)

        if showLabels
            lblOpen  := label.new(endIdx + 1, htfOpen,  "O: " + str.tostring(htfOpen,  format.mintick), style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.gray,  size = size.small)
            lblHigh  := label.new(endIdx + 1, htfHigh,  "H: " + str.tostring(htfHigh,  format.mintick), style = label.style_label_left, color = color.new(color.black, 100), textcolor = bullColor, size = size.small)
            lblLow   := label.new(endIdx + 1, htfLow,   "L: " + str.tostring(htfLow,   format.mintick), style = label.style_label_left, color = color.new(color.black, 100), textcolor = bearColor, size = size.small)
            lblClose := label.new(endIdx + 1, htfClose, "C: " + str.tostring(htfClose, format.mintick), style = label.style_label_left, color = color.new(color.black, 100), textcolor = candleColor, size = size.small)

        if showRange
            float rangeVal = htfHigh - htfLow
            lblRange := label.new(midIdx, htfHigh + rangeVal * 0.15,
                 htfLabelText + " Candle · Range: " + str.tostring(rangeVal, format.mintick),
                 style = label.style_label_down, color = color.new(color.black, 80), textcolor = color.white, size = size.normal)
````
