<!-- tradingview-pine-id: PUB;5a2dc33e201a46ef976d6d700538f0a7 -->
<!-- tradingviewscripts-format: 1 -->
# First Two Candle Momentum Scanner

Source: https://www.tradingview.com/script/3qMwkOgI-First-Two-Candle-Momentum-Scanner/

## Description

First Two Candle Momentum Scanner
1. Minimum bullish candle percentage (default 1.0%)
2. Session start time (default 09:15 exchange time)
3. Enable/Disable alerts
4. Show labels on chart (Yes/No)

---

## Source Code

````pine
//@version=6
indicator("First Two Candle Momentum Scanner", overlay=true, max_labels_count=500)

// =====================================================================================
// FIRST TWO CANDLE MOMENTUM SCANNER
// Apply on a 5-minute chart. Designed to run across a watchlist via TradingView alerts.
// Evaluates the first two 5-min candles of the session; fires an alert once per day
// if both candles are sufficiently bullish (plus any optional filters you enable).
// Non-repainting: all evaluation happens only on barstate.isconfirmed.
// =====================================================================================

// ------------------------------- Inputs --------------------------------------------
grpGeneral = "General Settings"
minBullPctFirst  = input.float(1.0, "Minimum 1st Candle %", minval=0.0, step=0.1, group=grpGeneral,
     tooltip="Minimum required ((Close-Open)/Open)*100 for the FIRST candle, or range % if selected below.")
minBullPctSecond = input.float(1.0, "Minimum 2nd Candle %", minval=0.0, step=0.1, group=grpGeneral,
     tooltip="Minimum required ((Close-Open)/Open)*100 for the SECOND candle, or range % if selected below.")
sessionStartHour   = input.int(9, "Session Start Hour (Exchange Time)", minval=0, maxval=23, group=grpGeneral)
sessionStartMinute = input.int(15, "Session Start Minute (Exchange Time)", minval=0, maxval=59, group=grpGeneral)
enableAlerts       = input.bool(true, "Enable Alerts", group=grpGeneral)
showLabels         = input.bool(true, "Show Labels on Chart", group=grpGeneral)
calcMode           = input.string("Body %", "Percentage Calculation Mode", options=["Body %", "Range %"], group=grpGeneral,
     tooltip="Body % = (Close-Open)/Open*100. Range % = (High-Low)/Open*100.")

grpFilters = "Optional Filters"
useVolumeFilter = input.bool(false, "Require 2nd Candle Volume > 1st Candle Volume", group=grpFilters)
useGapUpFilter  = input.bool(false, "Require Gap-Up (1st Candle Open > Prev Day Close)", group=grpFilters)
useEmaFilter    = input.bool(false, "Require 2nd Candle Close Above EMA", group=grpFilters)
emaLength       = input.int(20, "EMA Length", minval=1, group=grpFilters)

grpDisplay = "Display"
showTable = input.bool(true, "Show Status Table", group=grpDisplay)

// ------------------------------- Chart sanity check ---------------------------------
if barstate.islast and timeframe.in_seconds() != 300
    label.new(bar_index, high, "Apply this indicator to a 5-minute chart", color=color.new(color.red, 0),
         style=label.style_label_down, textcolor=color.white, size=size.small)

// ------------------------------- Session / day tracking ------------------------------
newDay = ta.change(time("D")) != 0
sessionStartTS = timestamp(year, month, dayofmonth, sessionStartHour, sessionStartMinute)
inSession = time >= sessionStartTS   // excludes pre-market bars automatically

var int sessionBarIndex = -1
if newDay
    sessionBarIndex := -1
if inSession
    sessionBarIndex := sessionBarIndex + 1

isFirstCandle  = sessionBarIndex == 0
isSecondCandle = sessionBarIndex == 1

// ------------------------------- Per-day persistent state ----------------------------
var float firstOpen       = na
var float firstClose      = na
var float firstVolume     = na
var float firstPct        = na
var bool  firstQualified  = false

var float secondPct       = na
var bool  secondQualified = false
var bool  bothQualified   = false
var bool  alertFiredToday = false

if newDay
    firstOpen       := na
    firstClose      := na
    firstVolume     := na
    firstPct        := na
    firstQualified  := false
    secondPct       := na
    secondQualified := false
    bothQualified   := false
    alertFiredToday := false

// ------------------------------- Supporting series ------------------------------------
ema20 = ta.ema(close, emaLength)
prevDayClose = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_off)

// ------------------------------- First candle evaluation (confirmed only) -------------
if isFirstCandle and barstate.isconfirmed
    firstOpen   := open
    firstClose  := close
    firstVolume := volume

    bodyPct1  = ((close - open) / open) * 100
    rangePct1 = ((high - low) / open) * 100
    firstPct  := calcMode == "Body %" ? bodyPct1 : rangePct1

    gapOk = not useGapUpFilter or (not na(prevDayClose) and open > prevDayClose)
    firstQualified := close > open and firstPct >= minBullPctFirst and gapOk

// ------------------------------- Second candle evaluation (confirmed only) ------------
if isSecondCandle and barstate.isconfirmed
    bodyPct2  = ((close - open) / open) * 100
    rangePct2 = ((high - low) / open) * 100
    secondPct := calcMode == "Body %" ? bodyPct2 : rangePct2

    volOk = not useVolumeFilter or (not na(firstVolume) and volume > firstVolume)
    emaOk = not useEmaFilter or (close > ema20)

    secondQualified := close > open and secondPct >= minBullPctSecond and volOk and emaOk
    bothQualified   := firstQualified and secondQualified

    if bothQualified and not alertFiredToday
        alertFiredToday := true

// ------------------------------- Visual signal (only on the qualifying bar) -----------
qualifyBar = bothQualified and isSecondCandle and barstate.isconfirmed

bgcolor(qualifyBar ? color.new(color.green, 85) : na)

if showLabels and qualifyBar
    label.new(bar_index, na, "\u2713", yloc=yloc.abovebar, style=label.style_label_down,
         color=color.new(color.green, 0), textcolor=color.white, size=size.small)

// ------------------------------- Alerts -------------------------------------------------
// Static-message version (usable directly from the "Create Alert" dialog):
alertcondition(qualifyBar, title="Momentum Qualify",
     message="{{ticker}} qualifies - First two 5-minute candles bullish")

// Dynamic-message version with the actual threshold value baked in.
// Requires "Any alert() function call" to be selected when creating the alert.
if enableAlerts and qualifyBar
    alert(str.format("{0} qualifies - 1st candle >= {1}% and 2nd candle >= {2}%", syminfo.ticker, minBullPctFirst, minBullPctSecond),
         alert.freq_once_per_bar_close)

// ------------------------------- Status table -------------------------------------------
var table statusTable = table.new(position.top_right, 2, 3, border_width=1)

if showTable and barstate.islast
    table.cell(statusTable, 0, 0, "1st Candle %", bgcolor=color.gray, text_color=color.white)
    table.cell(statusTable, 1, 0, na(firstPct) ? "-" : str.tostring(firstPct, "#.##") + "%",
         bgcolor=color.new(color.gray, 60), text_color=color.white)

    table.cell(statusTable, 0, 1, "2nd Candle %", bgcolor=color.gray, text_color=color.white)
    table.cell(statusTable, 1, 1, na(secondPct) ? "-" : str.tostring(secondPct, "#.##") + "%",
         bgcolor=color.new(color.gray, 60), text_color=color.white)

    statusText  = bothQualified ? "PASS" : (not na(secondPct) ? "FAIL" : "Pending")
    statusColor = bothQualified ? color.green : (not na(secondPct) ? color.red : color.gray)
    table.cell(statusTable, 0, 2, "Status", bgcolor=color.gray, text_color=color.white)
    table.cell(statusTable, 1, 2, statusText, bgcolor=color.new(statusColor, 60), text_color=color.white)
````
