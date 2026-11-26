# Current Weekly & Monthly High/Low Close

- url: https://www.tradingview.com/script/5I5JHpPr-Current-Weekly-Monthly-High-Low-Close/
- type: indicator
- pine_id: PUB;9392320ff3fd4791be0e992592bae669
- version: 1.0

## Description

Plots the current Weekly and Monthly HIGH/LOW close.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © TradingView Community Indicator

//@version=6
indicator(title="Weekly & Monthly High/Low Close", shorttitle="W/M HL Close", overlay=true)

// ─── INPUTS ────────────────────────────────────────────────────────────────

grpWeek = "Weekly Levels"
showWeek        = input.bool(true,  "Show Weekly Levels",                          group=grpWeek)
weekHighColor   = input.color(color.new(#00BCD4, 0),  "Weekly High Close Color",   group=grpWeek)
weekLowColor    = input.color(color.new(#FF5722, 0),  "Weekly Low Close Color",    group=grpWeek)
weekLineWidth   = input.int(1, "Weekly Line Width", minval=1, maxval=4,            group=grpWeek)
weekLineStyle   = input.string("Solid", "Weekly Line Style",
     options=["Solid","Dashed","Dotted"],                                           group=grpWeek)
showWeekLabels  = input.bool(true,  "Show Weekly Labels",                           group=grpWeek)
showWeekMarkers = input.bool(true,  "Show Markers on Candles",                      group=grpWeek)

grpMonth = "Monthly Levels"
showMonth        = input.bool(true,  "Show Monthly Levels",                        group=grpMonth)
monthHighColor   = input.color(color.new(#4CAF50, 0),  "Monthly High Close Color", group=grpMonth)
monthLowColor    = input.color(color.new(#F44336, 0),  "Monthly Low Close Color",  group=grpMonth)
monthLineWidth   = input.int(2, "Monthly Line Width", minval=1, maxval=4,          group=grpMonth)
monthLineStyle   = input.string("Dashed", "Monthly Line Style",
     options=["Solid","Dashed","Dotted"],                                           group=grpMonth)
showMonthLabels  = input.bool(true,  "Show Monthly Labels",                         group=grpMonth)
showMonthMarkers = input.bool(true,  "Show Markers on Candles",                     group=grpMonth)

grpExt = "Extension"
extendLines = input.bool(true, "Extend Lines Right", group=grpExt)

// ─── HELPERS ───────────────────────────────────────────────────────────────

lineStyleMap(s) =>
    switch s
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        =>          line.style_solid

extDir() =>
    extendLines ? extend.right : extend.none

// ─── PERIOD DETECTION ──────────────────────────────────────────────────────

isNewWeek  = timeframe.change("W")
isNewMonth = timeframe.change("M")

// ─── WEEKLY STATE ──────────────────────────────────────────────────────────
// Store bar TIME (int ms) instead of bar_index — no buffer limit issues

var float wHighClose = na
var float wLowClose  = na
var int   wHighTime  = na   // time of the candle that set week high close
var int   wLowTime   = na

if isNewWeek
    wHighClose := close
    wLowClose  := close
    wHighTime  := time
    wLowTime   := time
else
    if na(wHighClose)
        wHighClose := close
        wHighTime  := time
    else if close > wHighClose
        wHighClose := close
        wHighTime  := time
    if na(wLowClose)
        wLowClose := close
        wLowTime  := time
    else if close < wLowClose
        wLowClose := close
        wLowTime  := time

// ─── MONTHLY STATE ─────────────────────────────────────────────────────────

var float mHighClose = na
var float mLowClose  = na
var int   mHighTime  = na
var int   mLowTime   = na

if isNewMonth
    mHighClose := close
    mLowClose  := close
    mHighTime  := time
    mLowTime   := time
else
    if na(mHighClose)
        mHighClose := close
        mHighTime  := time
    else if close > mHighClose
        mHighClose := close
        mHighTime  := time
    if na(mLowClose)
        mLowClose := close
        mLowTime  := time
    else if close < mLowClose
        mLowClose := close
        mLowTime  := time

// ─── LINE, LABEL & MARKER MANAGEMENT ──────────────────────────────────────

var line  lineWH = na
var line  lineWL = na
var line  lineMH = na
var line  lineML = na
var label lblWH  = na
var label lblWL  = na
var label lblMH  = na
var label lblML  = na
var label mrkWH  = na
var label mrkWL  = na
var label mrkMH  = na
var label mrkML  = na

if barstate.islast
    line.delete(lineWH),  line.delete(lineWL)
    line.delete(lineMH),  line.delete(lineML)
    label.delete(lblWH),  label.delete(lblWL)
    label.delete(lblMH),  label.delete(lblML)
    label.delete(mrkWH),  label.delete(mrkWL)
    label.delete(mrkMH),  label.delete(mrkML)

    wStyle = lineStyleMap(weekLineStyle)
    mStyle = lineStyleMap(monthLineStyle)

    // ── Weekly High Close ──
    if showWeek and not na(wHighClose)
        lineWH := line.new(
             x1     = wHighTime,  y1 = wHighClose,
             x2     = time,       y2 = wHighClose,
             xloc   = xloc.bar_time,
             color  = weekHighColor,
             width  = weekLineWidth,
             style  = wStyle,
             extend = extDir())
        if showWeekLabels
            lblWH := label.new(
                 x         = time,  y = wHighClose,
                 xloc      = xloc.bar_time,
                 text      = "W High: " + str.tostring(wHighClose, format.mintick),
                 color     = color.new(weekHighColor, 80),
                 textcolor = weekHighColor,
                 style     = label.style_label_left,
                 size      = size.small)
        if showWeekMarkers
            mrkWH := label.new(
                 x         = wHighTime,  y = wHighClose,
                 xloc      = xloc.bar_time,
                 text      = "▲",
                 color     = color.new(weekHighColor, 55),
                 textcolor = weekHighColor,
                 style     = label.style_label_down,
                 size      = size.normal,
                 tooltip   = "Week High Close: " + str.tostring(wHighClose, format.mintick))

    // ── Weekly Low Close ──
    if showWeek and not na(wLowClose)
        lineWL := line.new(
             x1     = wLowTime,  y1 = wLowClose,
             x2     = time,      y2 = wLowClose,
             xloc   = xloc.bar_time,
             color  = weekLowColor,
             width  = weekLineWidth,
             style  = wStyle,
             extend = extDir())
        if showWeekLabels
            lblWL := label.new(
                 x         = time,  y = wLowClose,
                 xloc      = xloc.bar_time,
                 text      = "W Low: " + str.tostring(wLowClose, format.mintick),
                 color     = color.new(weekLowColor, 80),
                 textcolor = weekLowColor,
                 style     = label.style_label_left,
                 size      = size.small)
        if showWeekMarkers
            mrkWL := label.new(
                 x         = wLowTime,  y = wLowClose,
                 xloc      = xloc.bar_time,
                 text      = "▼",
                 color     = color.new(weekLowColor, 55),
                 textcolor = weekLowColor,
                 style     = label.style_label_up,
                 size      = size.normal,
                 tooltip   = "Week Low Close: " + str.tostring(wLowClose, format.mintick))

    // ── Monthly High Close ──
    if showMonth and not na(mHighClose)
        lineMH := line.new(
             x1     = mHighTime,  y1 = mHighClose,
             x2     = time,       y2 = mHighClose,
             xloc   = xloc.bar_time,
             color  = monthHighColor,
             width  = monthLineWidth,
             style  = mStyle,
             extend = extDir())
        if showMonthLabels
            lblMH := label.new(
                 x         = time,  y = mHighClose,
                 xloc      = xloc.bar_time,
                 text      = "M High: " + str.tostring(mHighClose, format.mintick),
                 color     = color.new(monthHighColor, 80),
                 textcolor = monthHighColor,
                 style     = label.style_label_left,
                 size      = size.small)
        if showMonthMarkers
            mrkMH := label.new(
                 x         = mHighTime,  y = mHighClose,
                 xloc      = xloc.bar_time,
                 text      = "▲",
                 color     = color.new(monthHighColor, 55),
                 textcolor = monthHighColor,
                 style     = label.style_label_down,
                 size      = size.large,
                 tooltip   = "Month High Close: " + str.tostring(mHighClose, format.mintick))

    // ── Monthly Low Close ──
    if showMonth and not na(mLowClose)
        lineML := line.new(
             x1     = mLowTime,  y1 = mLowClose,
             x2     = time,      y2 = mLowClose,
             xloc   = xloc.bar_time,
             color  = monthLowColor,
             width  = monthLineWidth,
             style  = mStyle,
             extend = extDir())
        if showMonthLabels
            lblML := label.new(
                 x         = time,  y = mLowClose,
                 xloc      = xloc.bar_time,
                 text      = "M Low: " + str.tostring(mLowClose, format.mintick),
                 color     = color.new(monthLowColor, 80),
                 textcolor = monthLowColor,
                 style     = label.style_label_left,
                 size      = size.small)
        if showMonthMarkers
            mrkML := label.new(
                 x         = mLowTime,  y = mLowClose,
                 xloc      = xloc.bar_time,
                 text      = "▼",
                 color     = color.new(monthLowColor, 55),
                 textcolor = monthLowColor,
                 style     = label.style_label_up,
                 size      = size.large,
                 tooltip   = "Month Low Close: " + str.tostring(mLowClose, format.mintick))

// ─── PLOTS (Data Window) ────────────────────────────────────────────────────

plot(showWeek  ? wHighClose : na, "Week High Close",  color=weekHighColor,  linewidth=1, display=display.data_window)
plot(showWeek  ? wLowClose  : na, "Week Low Close",   color=weekLowColor,   linewidth=1, display=display.data_window)
plot(showMonth ? mHighClose : na, "Month High Close", color=monthHighColor, linewidth=1, display=display.data_window)
plot(showMonth ? mLowClose  : na, "Month Low Close",  color=monthLowColor,  linewidth=1, display=display.data_window)
````
