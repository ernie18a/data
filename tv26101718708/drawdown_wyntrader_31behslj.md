# Drawdown [WynTrader]

- url: https://www.tradingview.com/script/31BehslJ-Drawdown-WynTrader/
- type: indicator
- pine_id: PUB;ade51a97356a4250987e01325a9558fe
- version: 1.0

## Description

Drawdown [WynTrader]

Hello my friend

Before trading an unfamiliar asset, it's worth seeing how it survived its toughest moments — including major market crashes. This indicator reveals every significant decline a security has experienced: how far it dropped, and how long it took. Seeing a past drawdown of -54% over 13 months makes the next correction far less intimidating.

Use it to measure real risk, set realistic expectations, and trade with more confidence.

█ CONCEPTS

A drawdown is the decline from a price peak to the lowest point that follows. The indicator automatically detects every peak and trough, filtering out noise to keep only declines at or above your chosen threshold (default: 20%).

█ FEATURES

[i][b]Threshold[/b][i] — Set the minimum decline to display, so only meaningful crashes appear.

[i][b]Boxes & Labels [/b][/i]— Each drawdown is highlighted on the chart from peak to trough, labeled with its duration and amplitude (e.g., 13M -54%).

[i][b]History Table[/b][/i] — Lists every recorded drawdown with start/end dates, span, and decline %. Sortable and adjustable in size.

█ CONCLUSION

Before investing, check an asset's drawdown history: how deep, how long, did it recover? These questions reveal its true volatility and resilience. A chart without this history tells only half the story.

█ WYNTRADER

I'm not a Pine Script programmer — just a trader building tools for my own analysis. A few rough edges may remain. Enjoy!
WynTrader

## Source Code

````pine
//@version=6
indicator("Drawdown [WynTrader]", shorttitle="Drawdown_wt", overlay = true)

// This Drawdown indicator helps assess a security's historical volatility by measuring past drawdowns.

// ───────────────────────────────────────────INPUTS──────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────
threshold = input.float(20.0, "Show Drawdowns ≥ Threshold %", minval=0.1, maxval=1000) / 100.0

showBoxes  = input.bool(true, "Boxes",  inline="bb")
boxFill    = input.color(color.new(color.orange, 80), "Fill",   inline="bb")
showLabels = input.bool(true, "Labels", inline="bb")
boxBorder  = input.color(color.new(color.orange, 85), "Border", inline="bb")

labelColor = input.color(color.white, "Label Text", inline="co")
labelSize  = input.string("normal", "Size", options=["tiny","small","normal","large","huge"], inline="co")

tableFill      = input.color(color.new(#000000, 0), "Table Fill", inline="tb")
tableTextColor = input.color(color.white,           "Text",       inline="tb")
tableTextSize  = input.string("normal", "Size", options=["tiny","small","normal","large","huge"], inline="tb")
posV     = input.string("bottom", "Table Position Vert.", options=["top","middle","bottom"], inline="Po")
posH     = input.string("right",  "Horiz.",               options=["left","center","right"],  inline="Po")
maxLines = input.int(10, "Table Maximum Rows", minval=1, maxval=200,
  tooltip="Maximum number of drawdown rows shown in the table (default 10, max 200).")
sortDesc = input.bool(true, "Sort: Recent First",
  tooltip="When enabled, the table shows the most recent drawdowns at the top. Otherwise, the oldest one appears first.")

// ─────────────────────────────────────────────────────────────
// SIZE
// ─────────────────────────────────────────────────────────────
labelSizeFinal     = labelSize     == "small" ? size.tiny : labelSize     == "small" ? size.small : labelSize     == "normal" ? size.normal : labelSize     == "large" ? size.large : size.huge
tableTextSizeFinal = tableTextSize == "small" ? size.tiny : tableTextSize == "small" ? size.small : tableTextSize == "normal" ? size.normal : tableTextSize == "large" ? size.large : size.huge

// ─────────────────────────────────────────────────────────────
// TIMEFRAME
// ─────────────────────────────────────────────────────────────
isM = timeframe.ismonthly
isW = timeframe.isweekly
isD = timeframe.isdaily

// ─────────────────────────────────────────────────────────────
// TABLE POSITION
// ─────────────────────────────────────────────────────────────
f_pos() =>
    if posV == "top"
        posH == "left" ? position.top_left : posH == "center" ? position.top_center : position.top_right
    else if posV == "middle"
        posH == "left" ? position.middle_left : posH == "center" ? position.middle_center : position.middle_right
    else
        posH == "left" ? position.bottom_left : posH == "center" ? position.bottom_center : position.bottom_right

// ─────────────────────────────────────────────────────────────
// SPAN
// ─────────────────────────────────────────────────────────────
spanFormat(startBar, endBar) =>
    bars = endBar - startBar
    if isM
        str.tostring(math.round(bars)) + " M"
    else if isW
        str.tostring(math.round(bars)) + " W"
    else if isD
        str.tostring(math.round(bars)) + " D"
    else
        str.tostring(math.round(bars)) + " B"

// ─────────────────────────────────────────────────────────────
// CYCLE SPLIT DURATION — bars since DD start
// ─────────────────────────────────────────────────────────────
splitBars = isM ? 24 : isW ? 104 : 500

// ─────────────────────────────────────────────────────────────
// DRAWDOWN STATE
// ─────────────────────────────────────────────────────────────
var bool  inDD         = false
var float ddPeak       = na
var int   ddPeakBar    = na
var int   ddPeakTime   = na
var float ddTrough     = na
var int   ddTroughBar  = na
var int   ddTroughTime = na
var float ddIntHigh    = na
var int   ddIntHighBar = na
var int   ddIntHighTime= na

// ─────────────────────────────────────────────────────────────
// ROLLING HIGH — bar-by-bar outside DD
// ─────────────────────────────────────────────────────────────
var float rollingHigh     = na
var int   rollingHighBar  = na
var int   rollingHighTime = na

if not inDD
    if na(rollingHigh) or high > rollingHigh
        rollingHigh     := high
        rollingHighBar  := bar_index
        rollingHighTime := time

// ─────────────────────────────────────────────────────────────
// STORAGE
// ─────────────────────────────────────────────────────────────
var float[]  ddArr = array.new_float()
var string[] sArr  = array.new_string()
var string[] eArr  = array.new_string()
var string[] spArr = array.new_string()

var table t = na
if barstate.isfirst
    t := table.new(f_pos(), 4, 202, border_width=1, border_color=color.new(#000000, 0))

// ─────────────────────────────────────────────────────────────
// RECORD DD
// ─────────────────────────────────────────────────────────────
recordCurrentDD() =>
    if not na(ddPeak) and not na(ddTrough)
        amp = (ddTrough - ddPeak) / ddPeak
        if math.round(math.abs(amp) * 100) >= math.round(threshold * 100) and ddTroughBar > ddPeakBar
            spanTxt = spanFormat(ddPeakBar, ddTroughBar)
            if showBoxes
                box.new(ddPeakBar, ddPeak, ddTroughBar, ddTrough,
                  bgcolor=boxFill, border_color=boxBorder, xloc=xloc.bar_index)
            if showLabels
                midBar = int(ddPeakBar + (ddTroughBar - ddPeakBar) / 2)
                label.new(midBar, ddTrough,
                  text      = spanTxt + " -" + str.tostring(math.round(math.abs(amp) * 100)) + "%",
                  style     = label.style_label_up,
                  textcolor = labelColor,
                  color     = na,
                  size      = labelSizeFinal,
                  xloc      = xloc.bar_index)
            array.push(ddArr, math.abs(amp))
            array.push(sArr,  str.format("{0,date,yyyy-MM-dd}", ddPeakTime))
            array.push(eArr,  str.format("{0,date,yyyy-MM-dd}", ddTroughTime))
            array.push(spArr, spanTxt)

// ─────────────────────────────────────────────────────────────
// DRAWDOWN DETECTION — rollingHigh direct
// ─────────────────────────────────────────────────────────────
if not inDD and not na(rollingHigh)
    if (rollingHigh - low) / rollingHigh >= threshold
        inDD          := true
        ddPeak        := rollingHigh
        ddPeakBar     := rollingHighBar
        ddPeakTime    := rollingHighTime
        ddTrough      := low
        ddTroughBar   := bar_index
        ddTroughTime  := time
        ddIntHigh     := high
        ddIntHighBar  := bar_index
        ddIntHighTime := time

// ─────────────────────────────────────────────────────────────
// DURING DD
// ─────────────────────────────────────────────────────────────
if inDD
    // Update trough
    if low < ddTrough
        ddTrough      := low
        ddTroughBar   := bar_index
        ddTroughTime  := time
        ddIntHigh     := high
        ddIntHighBar  := bar_index
        ddIntHighTime := time
    else if high > ddIntHigh
        ddIntHigh     := high
        ddIntHighBar  := bar_index
        ddIntHighTime := time

    // Normal close: high recovers above original peak
    if high >= ddPeak
        recordCurrentDD()
        inDD            := false
        ddPeak          := na
        ddTrough        := na
        ddIntHigh       := na
        rollingHigh     := high
        rollingHighBar  := bar_index
        rollingHighTime := time

    // Cycle split: long DD + significant rebound + new drop >= threshold
    else if not na(ddIntHigh) and not na(ddTrough)
        ddAge = bar_index - ddPeakBar
        if ddAge > splitBars and ddIntHigh > ddTrough * 1.50 and (ddIntHigh - low) / ddIntHigh >= threshold
            recordCurrentDD()
            ddPeak        := ddIntHigh
            ddPeakBar     := ddIntHighBar
            ddPeakTime    := ddIntHighTime
            ddTrough      := low
            ddTroughBar   := bar_index
            ddTroughTime  := time
            ddIntHigh     := high
            ddIntHighBar  := bar_index
            ddIntHighTime := time

// ─────────────────────────────────────────────────────────────
// DD EN COURS : affichage à la dernière barre
// ─────────────────────────────────────────────────────────────
if barstate.islast and inDD and not na(ddPeak) and not na(ddTrough)
    amp = (ddTrough - ddPeak) / ddPeak
    if math.round(math.abs(amp) * 100) >= math.round(threshold * 100) and ddTroughBar > ddPeakBar
        spanTxt = spanFormat(ddPeakBar, bar_index)
        if showBoxes
            box.new(ddPeakBar, ddPeak, bar_index, ddTrough,
              bgcolor=boxFill, border_color=boxBorder, xloc=xloc.bar_index)
        if showLabels
            midBar = int(ddPeakBar + (bar_index - ddPeakBar) / 2)
            label.new(midBar, ddTrough,
              text      = spanTxt + " -" + str.tostring(math.round(math.abs(amp) * 100)) + "%",
              style     = label.style_label_up,
              textcolor = labelColor,
              color     = na,
              size      = labelSizeFinal,
              xloc      = xloc.bar_index)
        array.push(ddArr, math.abs(amp))
        array.push(sArr,  str.format("{0,date,yyyy-MM-dd}", ddPeakTime))
        array.push(eArr,  str.format("{0,date,yyyy-MM-dd}", ddTroughTime))
        array.push(spArr, spanTxt)

// ─────────────────────────────────────────────────────────────
// TABLE UPDATE
// ─────────────────────────────────────────────────────────────
if barstate.islast
    table.cell(t, 0, 0, "Start", bgcolor=tableFill, text_color=tableTextColor, text_size=tableTextSizeFinal)
    table.cell(t, 1, 0, "End",   bgcolor=tableFill, text_color=tableTextColor, text_size=tableTextSizeFinal)
    table.cell(t, 2, 0, "Span",  bgcolor=tableFill, text_color=tableTextColor, text_size=tableTextSizeFinal)
    table.cell(t, 3, 0, "DD%",   bgcolor=tableFill, text_color=tableTextColor, text_size=tableTextSizeFinal)
    sz = array.size(ddArr)
    if sz > 0
        rows = math.min(sz, maxLines) - 1
        for i = 0 to rows
            idx = sortDesc ? sz - 1 - i : i
            table.cell(t, 0, i + 1, array.get(sArr,  idx), bgcolor=tableFill, text_color=tableTextColor, text_size=tableTextSizeFinal)
            table.cell(t, 1, i + 1, array.get(eArr,  idx), bgcolor=tableFill, text_color=tableTextColor, text_size=tableTextSizeFinal)
            table.cell(t, 2, i + 1, array.get(spArr, idx), bgcolor=tableFill, text_color=tableTextColor, text_size=tableTextSizeFinal)
            table.cell(t, 3, i + 1, "-" + str.tostring(math.round(array.get(ddArr, idx) * 100)) + "%",
              bgcolor=tableFill, text_color=tableTextColor, text_size=tableTextSizeFinal)
        table.cell(t, 0, math.min(sz, maxLines) + 1, "", bgcolor=color.new(#000000, 100))
        table.cell(t, 1, math.min(sz, maxLines) + 1, "", bgcolor=color.new(#000000, 100))
        table.cell(t, 2, math.min(sz, maxLines) + 1, "", bgcolor=color.new(#000000, 100))
        table.cell(t, 3, math.min(sz, maxLines) + 1, "", bgcolor=color.new(#000000, 100))
````
