# Swing Guide

- url: https://www.tradingview.com/script/zZcRSJo6-Swing-Guide/
- type: indicator
- pine_id: PUB;e7b79a559aab4feeb39ef4fb31b3047d
- version: 1.0

## Description

Swing Guide

Swing Guide is a clean and beginner-friendly market structure tool designed to help traders read swings, trend shifts and pullback zones directly on the chart.

The script connects important swing highs and swing lows with a simple visual line, then labels each structure point in a clear and intuitive way.

STRUCTURE LABELS

High+ = Higher High
Price made a new high above the previous swing high.

Low+ = Higher Low
A pullback held above the previous swing low.

High- = Lower High
A bounce failed below the previous swing high.

Low- = Lower Low
Price broke below the previous swing low.

These labels help traders quickly understand whether the market is building bullish structure, bearish structure, a possible shift, or a temporary pullback.

WHAT THE INDICATOR SHOWS

• Swing line connecting key market structure points
• Compact High+ / Low+ / High- / Low- structure labels
• Current market condition in the dashboard
• Bullish or bearish structure context
• Last important structure point
• Preferred directional bias
• Current structure-based risk state

DASHBOARD

The dashboard summarizes the current market structure in simple words.

Now
Shows the current market condition, such as Uptrend, Downtrend, Healthy Pullback, Weak Bounce or Possible Reversal.

Structure
Summarizes the broader structure context: Bullish, Bearish, Bullish Shift or Bearish Shift.

Last Point
Shows the latest structure point: New High, Higher Low, Lower High or New Low.

Bias
Gives a simple context reading: Long Preferred, Short Preferred or Wait.

Risk
Highlights the current structure risk, such as Trend Extension, Pullback Zone, Weak Recovery or Breakdown.

MAIN SETTINGS

Swing Sensitivity
Controls how many swing points are detected.

Lower values show more swings and more detail.
Higher values filter out smaller moves and keep the chart cleaner.

Repaint Forming Leg
When enabled, the latest swing leg updates live as price develops. This gives the classic real-time swing guide look, but the last leg can move until the structure is confirmed.

When disabled, the script draws only confirmed swing legs. This reduces movement after printing, but the latest swing may appear with a delay.

Structure Label Transparency
Adjusts how soft or visible the High+ / Low+ / High- / Low- labels appear on the chart.

HOW TO USE

Swing Guide is designed as a visual map of market structure.

It can help traders understand where the market is making higher highs, higher lows, lower highs or lower lows.

A bullish structure is usually built with High+ and Low+ points.

A bearish structure is usually built with High- and Low- points.

A possible structure shift may appear when the market starts breaking the previous sequence of highs and lows.

The dashboard is intended to simplify this reading and provide a quick summary of the current structure.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarketStructureLab
// Swing Guide — developed by MarketStructureLab.
// May your trades be green and your stops never hit. Good luck out there.

//@version=6
indicator("Swing Guide", shorttitle="SwingGuide", overlay=true, max_lines_count=500, max_labels_count=500)

//====================================================================
// INPUTS
//====================================================================

groupCalc   = "Swing"
groupVisual = "Appearance"
groupTable  = "Dashboard"

sensitivity = input.int(12, "Swing Sensitivity", minval=1, step=1, group=groupCalc,
     tooltip="How big a move must be to count as a new swing leg. Lower values catch smaller swings, so you get more lines and more detail (and more noise). Higher values keep only the larger swings, so the chart stays cleaner. This is the single control that replaces the old Depth / Deviation / Backstep trio.")

repaint = input.bool(true, "Repaint Forming Leg", group=groupCalc,
     tooltip="On: the last (still forming) swing leg updates live on every bar, the classic look. It can move until the swing is confirmed. Off: a leg is drawn only once the swing is confirmed, so nothing moves after it prints, but the latest leg appears a few bars late.")

bullColor = input.color(#00C896, "Bullish Structure", inline="col", group=groupVisual,
     tooltip="Color for up legs and bullish structure points: High+ / Low+.")

bearColor = input.color(#E04B52, "Bearish Structure", inline="col", group=groupVisual,
     tooltip="Color for down legs and bearish structure points: High- / Low-.")

labelTransparency = input.int(35, "Structure Label Transparency", minval=0, maxval=90, group=groupVisual,
     tooltip="Transparency of High+ / Low+ / High- / Low- labels. Higher value = softer labels.")

showSwing = input.bool(true, "Show Swing Line", group=groupVisual,
     tooltip="Draw the swing line that connects the confirmed swing highs and lows.")

showStructLabels = input.bool(true, "Show Structure Labels", group=groupVisual,
     tooltip="Print the compact High+ / Low+ / High- / Low- tags on each swing point. High+ = higher high, Low+ = higher low, High- = lower high, Low- = lower low.")

showTable = input.bool(true, "Show Dashboard", group=groupTable,
     tooltip="Show the small guide table that summarizes the current market structure in plain words.")

dashPos = input.string("Top Right", "Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupTable,
     tooltip="Where to place the dashboard on the chart.")

//====================================================================
// COLORS
//====================================================================

warnColor = #E0A800
neutColor = #6B7280
textColor = color.white

tableBg     = color.new(#0F131A, 5)
headerBg    = color.new(#1A1F2B, 0)
leftColBg   = color.new(#11161D, 0)
borderColor = color.new(color.white, 65)
frameColor  = color.new(color.white, 55)

//====================================================================
// HELPERS
//====================================================================

f_lab(string p) =>
    p == "HH" ? "High+" : p == "HL" ? "Low+" : p == "LH" ? "High-" : "Low-"

f_pos(string s) =>
    s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : position.top_right

f_now(int t, string p) =>
    r = "Waiting"
    if t == 1 and p == "HH"
        r := "Uptrend"
    else if t == 1 and p == "HL"
        r := "Healthy Pullback"
    else if t == 1 and p == "LH"
        r := "Possible Reversal Down"
    else if t == -1 and p == "LL"
        r := "Downtrend"
    else if t == -1 and p == "LH"
        r := "Weak Bounce"
    else if t == -1 and p == "HL"
        r := "Possible Reversal Up"
    r

f_structure(int t, string p) =>
    r = "Waiting"
    if t == 1 and (p == "HH" or p == "HL")
        r := "Bullish"
    else if t == -1 and (p == "LL" or p == "LH")
        r := "Bearish"
    else if t == 1 and p == "LH"
        r := "Bearish Shift"
    else if t == -1 and p == "HL"
        r := "Bullish Shift"
    r

f_lastpoint(string p) =>
    r = "Waiting"
    if p == "HH"
        r := "New High"
    else if p == "HL"
        r := "Higher Low"
    else if p == "LH"
        r := "Lower High"
    else if p == "LL"
        r := "New Low"
    r

f_bias(int t, string p) =>
    r = "Wait"
    if t == 1 and p != "LH"
        r := "Long Preferred"
    else if t == -1 and p != "HL"
        r := "Short Preferred"
    r

f_risk(int t, string p) =>
    r = "No Clear Structure"
    if t == 1 and p == "HH"
        r := "Trend Extension"
    else if t == 1 and p == "HL"
        r := "Pullback Zone"
    else if t == -1 and p == "LL"
        r := "Breakdown"
    else if t == -1 and p == "LH"
        r := "Weak Recovery"
    r

f_cellColor(string s) =>
    c = color.new(neutColor, 25)
    if s == "Uptrend" or s == "Healthy Pullback" or s == "Bullish" or s == "New High" or s == "Higher Low" or s == "Long Preferred" or s == "Pullback Zone"
        c := color.new(bullColor, 15)
    else if s == "Downtrend" or s == "Weak Bounce" or s == "Bearish" or s == "New Low" or s == "Lower High" or s == "Short Preferred" or s == "Breakdown" or s == "Weak Recovery"
        c := color.new(bearColor, 15)
    else if s == "Possible Reversal Up" or s == "Possible Reversal Down" or s == "Bullish Shift" or s == "Bearish Shift" or s == "Trend Extension"
        c := color.new(warnColor, 15)
    c

//====================================================================
// CALCULATIONS
//====================================================================

deviation = 5
backstep  = 2

highRun  = ta.barssince(not (ta.highest(high, sensitivity) - high > deviation * syminfo.mintick)[1])
lowRun   = ta.barssince(not (low - ta.lowest(low, sensitivity) > deviation * syminfo.mintick)[1])
swingDir = ta.barssince(not (highRun > lowRun)) >= backstep ? -1 : 1
flip = ta.change(swingDir) != 0

var float extremePrice = low
var int   extremeBar   = bar_index
var float pivotPrice   = low
var int   pivotBar     = bar_index
var float tipPrice     = high
var int   tipBar       = bar_index

var float  prevHigh      = na
var float  prevLow       = na
var string lastPivotType = na
var int    trendState    = 0

if flip
    pivotPrice := tipPrice
    pivotBar   := tipBar
    tipPrice   := extremePrice
    tipBar     := extremeBar

    if swingDir > 0
        lowType = na(prevLow) or pivotPrice < prevLow ? "LL" : "HL"
        lastPivotType := lowType
        prevLow := pivotPrice
        if lowType == "LL"
            trendState := -1
    else
        highType = na(prevHigh) or pivotPrice > prevHigh ? "HH" : "LH"
        lastPivotType := highType
        prevHigh := pivotPrice
        if highType == "HH"
            trendState := 1

if swingDir > 0
    if high > tipPrice
        tipPrice     := high
        tipBar       := bar_index
        extremePrice := low
        extremeBar   := bar_index

    if low < extremePrice
        extremePrice := low
        extremeBar   := bar_index
else
    if low < tipPrice
        tipPrice     := low
        tipBar       := bar_index
        extremePrice := high
        extremeBar   := bar_index

    if high > extremePrice
        extremePrice := high
        extremeBar   := bar_index

//====================================================================
// SIGNAL ENGINE
//====================================================================

tipType = swingDir > 0 ? (tipPrice > prevHigh ? "HH" : "LH") : (tipPrice < prevLow ? "LL" : "HL")

bullFlip = trendState == 1 and trendState[1] != 1
bearFlip = trendState == -1 and trendState[1] != -1

//====================================================================
// VISUAL STATE
//====================================================================

isBullTip  = tipType == "HH" or tipType == "HL"
legColor   = color.new(swingDir > 0 ? bullColor : bearColor, 0)
labelBg    = color.new(isBullTip ? bullColor : bearColor, labelTransparency)
labelStyle = swingDir > 0 ? label.style_label_down : label.style_label_up

//====================================================================
// PLOTS
//====================================================================

line  swingLine  = na
label swingLabel = na

if showSwing and repaint
    swingLine := line.new(pivotBar, pivotPrice, tipBar, tipPrice, xloc.bar_index, color=legColor, width=2)

    if showStructLabels
        swingLabel := label.new(tipBar, tipPrice, f_lab(tipType), xloc.bar_index, yloc.price, color=labelBg, style=labelStyle, textcolor=textColor, size=size.small)

    if not flip
        line.delete(swingLine[1])
        label.delete(swingLabel[1])

if showSwing and not repaint
    if flip
        isBullTipPrev  = tipType[1] == "HH" or tipType[1] == "HL"
        legColorPrev   = color.new(swingDir[1] > 0 ? bullColor : bearColor, 0)
        labelBgPrev    = color.new(isBullTipPrev ? bullColor : bearColor, labelTransparency)
        labelStylePrev = swingDir[1] > 0 ? label.style_label_down : label.style_label_up

        swingLine := line.new(pivotBar[1], pivotPrice[1], tipBar[1], tipPrice[1], xloc.bar_index, color=legColorPrev, width=2)

        if showStructLabels
            swingLabel := label.new(tipBar[1], tipPrice[1], f_lab(tipType[1]), xloc.bar_index, yloc.price, color=labelBgPrev, style=labelStylePrev, textcolor=textColor, size=size.small)

//====================================================================
// ALERTS
//====================================================================

tipMoved = tipPrice != tipPrice[1]

alertcondition(tipType == "HH" and tipMoved, "New Higher High", "Swing Guide {{ticker}}: Higher High (High+) at {{time}}")
alertcondition(tipType == "LH" and tipMoved, "New Lower High",  "Swing Guide {{ticker}}: Lower High (High-) at {{time}}")
alertcondition(tipType == "HL" and tipMoved, "New Higher Low",  "Swing Guide {{ticker}}: Higher Low (Low+) at {{time}}")
alertcondition(tipType == "LL" and tipMoved, "New Lower Low",   "Swing Guide {{ticker}}: Lower Low (Low-) at {{time}}")
alertcondition(flip,     "Direction Changed",  "Swing Guide {{ticker}}: swing direction changed at {{time}}")
alertcondition(bullFlip, "Bullish Structure",  "Swing Guide {{ticker}}: Bullish structure (Higher High) at {{time}}")
alertcondition(bearFlip, "Bearish Structure",  "Swing Guide {{ticker}}: Bearish structure (Lower Low) at {{time}}")

if bullFlip
    alert("Swing Guide: Bullish structure (Higher High)", alert.freq_once_per_bar_close)

if bearFlip
    alert("Swing Guide: Bearish structure (Lower Low)", alert.freq_once_per_bar_close)

//====================================================================
// TABLE
//====================================================================

if showTable and barstate.islast
    nowText    = f_now(trendState, lastPivotType)
    structText = f_structure(trendState, lastPivotType)
    pointText  = f_lastpoint(lastPivotType)
    biasText   = f_bias(trendState, lastPivotType)
    riskText   = f_risk(trendState, lastPivotType)

    var table proTable = table.new(f_pos(dashPos), 2, 6, bgcolor=tableBg, border_width=1, border_color=borderColor, frame_color=frameColor, frame_width=1)

    table.cell(proTable, 0, 0, "Swing Guide", text_color=textColor, bgcolor=headerBg, text_halign=text.align_left, text_size=size.small)
    table.cell(proTable, 1, 0, "Status", text_color=textColor, bgcolor=headerBg, text_halign=text.align_center, text_size=size.small)

    table.cell(proTable, 0, 1, "Now", text_color=textColor, bgcolor=leftColBg, text_halign=text.align_left, text_size=size.small)
    table.cell(proTable, 1, 1, nowText, text_color=textColor, bgcolor=f_cellColor(nowText), text_halign=text.align_center, text_size=size.small)

    table.cell(proTable, 0, 2, "Structure", text_color=textColor, bgcolor=leftColBg, text_halign=text.align_left, text_size=size.small)
    table.cell(proTable, 1, 2, structText, text_color=textColor, bgcolor=f_cellColor(structText), text_halign=text.align_center, text_size=size.small)

    table.cell(proTable, 0, 3, "Last Point", text_color=textColor, bgcolor=leftColBg, text_halign=text.align_left, text_size=size.small)
    table.cell(proTable, 1, 3, pointText, text_color=textColor, bgcolor=f_cellColor(pointText), text_halign=text.align_center, text_size=size.small)

    table.cell(proTable, 0, 4, "Bias", text_color=textColor, bgcolor=leftColBg, text_halign=text.align_left, text_size=size.small)
    table.cell(proTable, 1, 4, biasText, text_color=textColor, bgcolor=f_cellColor(biasText), text_halign=text.align_center, text_size=size.small)

    table.cell(proTable, 0, 5, "Risk", text_color=textColor, bgcolor=leftColBg, text_halign=text.align_left, text_size=size.small)
    table.cell(proTable, 1, 5, riskText, text_color=textColor, bgcolor=f_cellColor(riskText), text_halign=text.align_center, text_size=size.small)

//====================================================================
// USAGE GUIDE
//====================================================================
//
// Swing Guide. What it does:
//   A clean, beginner-friendly map of market structure. It draws a swing
//   line over the confirmed swing highs and lows, tags each swing in plain
//   form (High+, Low+, High-, Low-), and sums up the picture in a small
//   dashboard. It is a visual guide, not a buy or sell system. It does not
//   promise an entry, a target or a profit.
//
// Swing tags:
//   High+ = higher high   (price made a new high above the last high)
//   Low+  = higher low    (pullback held above the last low)
//   High- = lower high    (bounce failed below the last high)
//   Low-  = lower low     (price broke below the last low)
//
// Dashboard logic:
//   Now        Current market condition.
//   Structure  Bullish, Bearish, Bullish Shift, Bearish Shift.
//   Last Point New High, Higher Low, Lower High, New Low.
//   Bias       Long Preferred, Short Preferred, or Wait.
//   Risk       Trend Extension, Pullback Zone, Weak Recovery, Breakdown.
//
// Settings:
//   - Swing Sensitivity: lower = more swings, higher = cleaner structure.
//   - Repaint Forming Leg: on = live classic look, off = confirmed-only legs.
//   - Structure Label Transparency: makes High+ / Low+ / High- / Low- labels softer.
//
// Risk note:
//   Market structure can change at any time and the last leg can repaint.
//   Use this as context for your own plan and risk management, not as a
//   guaranteed signal.
````
