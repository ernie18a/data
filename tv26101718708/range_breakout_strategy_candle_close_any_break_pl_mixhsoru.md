# Range Breakout Strategy (Candle Close/ Any Break) + P&L

- url: https://www.tradingview.com/script/MiXhsOru-Range-Breakout-Strategy-Candle-Close-Any-Break-P-L/
- type: indicator
- pine_id: PUB;f05dfdd47afd40c8a04875f386072411
- version: 1.0

## Description

This script defines your chosen range (in candles) based on a candle close or any range break. This can be changed in the settings. The default is candle close - please change it to any range break if you want. As of now, candle close setting on NQ seems more profitable, but this of course will depend on the underlying and also the range of your choosing.

The yellow line shows your entry point. You can of course edit line colors etc. in the settings. The dashed lines show your stop loss (red) and profit target (green). 

Then, the script calculates the P&L for your strategy. You can play with the settings and dates to calculate the P&L and see it change in real time in the stats table as you do so. 

I took care to calculate partial wins and losses as well, which is all indicated on the chart.

I hope you find this useful.

Happy trading,

~ Ava ~

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Yulaye

//@version=6
indicator("Range Break Strategy", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

// ════════════════════════════════════════════════════════════════════════════════
// INPUT SETTINGS
// ════════════════════════════════════════════════════════════════════════════════

sessionReference = input.string("RTH Open (9:30 EST)", "Session Reference",
     options=["RTH Open (9:30 EST)", "Futures Open (18:00 EST)"])

rangeStartCandle = input.int(1, "Range Start Candle", minval=1, maxval=200)
rangeEndCandle   = input.int(8, "Range End Candle",   minval=1, maxval=200)

// ── Box display ──────────────────────────────────────────────────────────────
showRangeBox     = input.bool(true,  "Show Range Box")
rangeBoxColor    = input.color(color.new(color.blue, 80), "Range Box Color")
rangeBoxBorder   = input.color(color.blue, "Range Box Border")
showRangeLabel   = input.bool(true,  "Show Range Size Label")
rangeDisplayUnit = input.string("Points", "Display Range In", options=["Points", "Ticks"])

// ── Range midpoint / fib line ────────────────────────────────────────────────
showMidLine  = input.bool(false, "Show Range Level Line",
     tooltip="Draws a horizontal line inside the range at the specified fraction. 0.5 = midpoint, 0.382 / 0.618 = fib levels, etc.")
midLineFrac  = input.float(0.5, "Level Fraction (0.0 - 1.0)", minval=0.0, maxval=1.0, step=0.001,
     tooltip="0.5 = midpoint. 0.382, 0.618, 0.236, 0.786 for fib levels. Measured from range low upward.")
midLineColor = input.color(color.new(color.orange, 0), "Level Line Color")
midLineWidth = input.int(1, "Level Line Width", minval=1, maxval=4)

// ── Extension control ────────────────────────────────────────────────────────
extendMode = input.string("RTH Close", "Extend Levels Until",
     options=["RTH Close", "Win or Loss", "Custom Bars"],
     tooltip="RTH Close = extend to 16:00 EST.\nWin or Loss = extend lines live until target or stop is hit, even past RTH.\nCustom Bars = fixed bar count.")
customExtendBars = input.int(15, "Custom Extend Bars", minval=5, maxval=500,
     tooltip="Only used when Extend Mode = Custom Bars")

// ── Break detection ──────────────────────────────────────────────────────────
breakMode = input.string("Bar Close (Current TF)", "Break Detection Mode",
     options=["Intrabar (Any Touch)", "Bar Close (Current TF)", "Bar Close (Other TF)"],
     tooltip="Intrabar = triggers the moment price crosses.\nBar Close = waits for candle to close outside.\nOther TF = uses a different timeframe's close.")
breakTimeframe = input.timeframe("", "Confirmation Timeframe",
     tooltip="Only used when Break Detection Mode = Bar Close (Other TF). Leave blank to match chart timeframe.")

// ── Trade levels ─────────────────────────────────────────────────────────────
riskRewardRatio  = input.float(1.0, "Risk/Reward Ratio",  minval=0.1, maxval=10, step=0.1)
stopLossMultiple = input.float(1.0, "Stop Loss Multiple", minval=0.1, maxval=5,  step=0.1)
showTradeLevels  = input.bool(true, "Show Entry/Target/Stop Lines")
entryLineColor   = input.color(color.yellow,                "Entry Line Color")
targetLineColor  = input.color(color.green,                 "Target Line Color")
stopLineColor    = input.color(color.red,                   "Stop Loss Line Color")
targetFillColor  = input.color(color.new(color.green, 85), "Target Zone Fill")
stopFillColor    = input.color(color.new(color.red,   85), "Stop Zone Fill")

enableAlerts = input.bool(true, "Enable Break Alerts")

// ── P&L Summary ──────────────────────────────────────────────────────────────
showPnL      = input.bool(true, "Show P&L Summary Panel")
pnlStartDate = input.time(timestamp("2025-01-01 00:00"), "P&L Start Date")
pnlEndDate   = input.time(timestamp("2099-12-31 23:59"), "P&L End Date")
pnlPosition  = input.string("Top Right", "Panel Position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])

// ════════════════════════════════════════════════════════════════════════════════
// RTH TRACKING
// ════════════════════════════════════════════════════════════════════════════════

f_inRTH() =>
    not na(time(timeframe.period, "0930-1600:23456", "America/New_York"))

var int lastRTHBar = na
if f_inRTH()
    lastRTHBar := bar_index

rthNow     = f_inRTH()
rthPrev    = f_inRTH()[1]
isRTHClose = not rthNow and rthPrev

// ════════════════════════════════════════════════════════════════════════════════
// SESSION DETECTION
// ════════════════════════════════════════════════════════════════════════════════

bool isNewSession = false

if sessionReference == "RTH Open (9:30 EST)"
    sessionTime  = time(timeframe.period, "0930-1600:23456", "America/New_York")
    inSess       = not na(sessionTime)
    isNewSession := inSess and na(sessionTime[1])
else
    estHour      = hour(time,    "America/New_York")
    prevEstHour  = hour(time[1], "America/New_York")
    isNewSession := estHour == 18 and prevEstHour != 18

// ════════════════════════════════════════════════════════════════════════════════
// CANDLE COUNTER
// ════════════════════════════════════════════════════════════════════════════════

var int candleNumber = 0
if isNewSession
    candleNumber := 1
else
    candleNumber := candleNumber + 1

// ════════════════════════════════════════════════════════════════════════════════
// RANGE TRACKING
// ════════════════════════════════════════════════════════════════════════════════

var float sessionRangeHigh     = na
var float sessionRangeLow      = na
var int   sessionRangeStartBar = na
var int   sessionRangeEndBar   = na
var bool  sessionRangeComplete = false

if isNewSession
    sessionRangeHigh     := na
    sessionRangeLow      := na
    sessionRangeStartBar := na
    sessionRangeEndBar   := na
    sessionRangeComplete := false

if candleNumber >= rangeStartCandle and candleNumber <= rangeEndCandle
    if candleNumber == rangeStartCandle
        sessionRangeHigh     := high
        sessionRangeLow      := low
        sessionRangeStartBar := bar_index - 1
    else
        sessionRangeHigh := math.max(sessionRangeHigh, high)
        sessionRangeLow  := math.min(sessionRangeLow,  low)
    if candleNumber == rangeEndCandle
        sessionRangeEndBar   := bar_index + 1
        sessionRangeComplete := true

// ════════════════════════════════════════════════════════════════════════════════
// TRADE STATE
// ════════════════════════════════════════════════════════════════════════════════

var float  sessionEntryPrice     = na
var float  sessionTargetPrice    = na
var float  sessionStopPrice      = na
var float  sessionEffectiveRange = na
var bool   sessionTradeTriggered = false
var int    sessionEntryBar       = na
var string sessionDir            = na
var bool   sessionTradeResolved  = false
var int    sessionResolvedBar    = na
var line   tradEntryLine         = na
var line   tradTargetLine        = na
var line   tradStopLine          = na

if isNewSession
    sessionTradeTriggered := false
    sessionTradeResolved  := false
    sessionResolvedBar    := na
    sessionDir            := na
    sessionEntryPrice     := na
    sessionTargetPrice    := na
    sessionStopPrice      := na
    sessionEffectiveRange := na
    sessionEntryBar       := na
    tradEntryLine         := na
    tradTargetLine        := na
    tradStopLine          := na

// ════════════════════════════════════════════════════════════════════════════════
// MULTI-TIMEFRAME CLOSE
// ════════════════════════════════════════════════════════════════════════════════

otherTFClose = request.security(syminfo.tickerid, breakTimeframe, close, lookahead=barmerge.lookahead_off)

// ════════════════════════════════════════════════════════════════════════════════
// BREAKOUT DETECTION
// ════════════════════════════════════════════════════════════════════════════════

bool longBreak  = false
bool shortBreak = false

if sessionRangeComplete and candleNumber > rangeEndCandle and not sessionTradeTriggered
    testPrice  = switch breakMode
        "Intrabar (Any Touch)"   => close
        "Bar Close (Current TF)" => close
        "Bar Close (Other TF)"   => otherTFClose
        => close

    aboveRange = breakMode == "Intrabar (Any Touch)" ? high > sessionRangeHigh : testPrice > sessionRangeHigh
    belowRange = breakMode == "Intrabar (Any Touch)" ? low  < sessionRangeLow  : testPrice < sessionRangeLow
    baseRange  = sessionRangeHigh - sessionRangeLow

    if aboveRange
        longBreak  := true
        sessionDir := "LONG"
        if breakMode == "Intrabar (Any Touch)"
            sessionEntryPrice     := sessionRangeHigh
            sessionEffectiveRange := baseRange
        else
            entryClose            = breakMode == "Bar Close (Other TF)" ? otherTFClose : close
            sessionEntryPrice     := entryClose
            sessionEffectiveRange := entryClose - sessionRangeLow
        sessionTargetPrice    := sessionEntryPrice + sessionEffectiveRange * riskRewardRatio
        sessionStopPrice      := sessionEntryPrice - sessionEffectiveRange * stopLossMultiple
        sessionTradeTriggered := true
        sessionEntryBar       := bar_index

    else if belowRange
        shortBreak := true
        sessionDir := "SHORT"
        if breakMode == "Intrabar (Any Touch)"
            sessionEntryPrice     := sessionRangeLow
            sessionEffectiveRange := baseRange
        else
            entryClose            = breakMode == "Bar Close (Other TF)" ? otherTFClose : close
            sessionEntryPrice     := entryClose
            sessionEffectiveRange := sessionRangeHigh - entryClose
        sessionTargetPrice    := sessionEntryPrice - sessionEffectiveRange * riskRewardRatio
        sessionStopPrice      := sessionEntryPrice + sessionEffectiveRange * stopLossMultiple
        sessionTradeTriggered := true
        sessionEntryBar       := bar_index

// ════════════════════════════════════════════════════════════════════════════════
// RESOLVE TRADE
// ════════════════════════════════════════════════════════════════════════════════

bool justResolved = false

if sessionTradeTriggered and not sessionTradeResolved and not na(sessionEntryPrice)
    targetHit = sessionDir == "LONG" ? high >= sessionTargetPrice : low  <= sessionTargetPrice
    stopHit   = sessionDir == "LONG" ? low  <= sessionStopPrice   : high >= sessionStopPrice
    if targetHit or stopHit
        sessionTradeResolved := true
        sessionResolvedBar   := bar_index
        justResolved         := true

// ════════════════════════════════════════════════════════════════════════════════
// OUTCOME CALCULATION
// ════════════════════════════════════════════════════════════════════════════════

f_calcOutcome(dir, entryPx, targetPx, stopPx, hi, lo, cls, unit) =>
    ptsMult = unit == "Points" ? 1.0 : 1.0 / syminfo.mintick
    outcome = ""
    pts     = 0.0
    if dir == "LONG"
        if hi >= targetPx
            outcome := "✔ WIN"
            pts     := (targetPx - entryPx) * ptsMult
        else if lo <= stopPx
            outcome := "✘ LOSS"
            pts     := (stopPx - entryPx) * ptsMult
        else
            pts := (cls - entryPx) * ptsMult
            if cls > entryPx
                outcome := str.format("◑ PARTIAL WIN  +{0,number,#.##} pts", pts)
            else
                outcome := str.format("◑ PARTIAL LOSS  {0,number,#.##} pts", pts)
    else if dir == "SHORT"
        if lo <= targetPx
            outcome := "✔ WIN"
            pts     := (entryPx - targetPx) * ptsMult
        else if hi >= stopPx
            outcome := "✘ LOSS"
            pts     := (entryPx - stopPx) * ptsMult
        else
            pts := (entryPx - cls) * ptsMult
            if cls < entryPx
                outcome := str.format("◑ PARTIAL WIN  +{0,number,#.##} pts", pts)
            else
                outcome := str.format("◑ PARTIAL LOSS  {0,number,#.##} pts", pts)
    [outcome, pts]

// ════════════════════════════════════════════════════════════════════════════════
// OUTCOME COLOR HELPER
// ════════════════════════════════════════════════════════════════════════════════

f_outcomeColor(outcome) =>
    col = color.red
    if str.contains(outcome, "PARTIAL WIN")
        col := color.teal
    else if str.contains(outcome, "✔ WIN")
        col := color.green
    else if str.contains(outcome, "PARTIAL LOSS")
        col := color.orange
    col

// ════════════════════════════════════════════════════════════════════════════════
// TABLE ROW HELPER
// ════════════════════════════════════════════════════════════════════════════════

f_row(tbl, row, lbl, val, valColor) =>
    table.cell(tbl, 0, row, lbl,
         text_color=color.new(color.white, 20),
         text_size=size.small,
         bgcolor=color.new(color.black, 30))
    table.cell(tbl, 1, row, val,
         text_color=valColor,
         text_size=size.small,
         bgcolor=color.new(color.black, 30))

// ════════════════════════════════════════════════════════════════════════════════
// STATIC RIGHT EDGE
// ════════════════════════════════════════════════════════════════════════════════

f_staticRightEdge(startBar) =>
    if extendMode == "RTH Close"
        if not na(lastRTHBar) and lastRTHBar > startBar
            lastRTHBar
        else
            startBar + customExtendBars
    else
        startBar + customExtendBars

// ════════════════════════════════════════════════════════════════════════════════
// RANGE BOX
// ════════════════════════════════════════════════════════════════════════════════

if candleNumber == rangeEndCandle and not na(sessionRangeHigh)
    rightEdge = f_staticRightEdge(sessionRangeEndBar)
    if showRangeBox
        box.new(
             left         = sessionRangeStartBar,
             top          = sessionRangeHigh,
             right        = rightEdge,
             bottom       = sessionRangeLow,
             border_color = rangeBoxBorder,
             bgcolor      = rangeBoxColor,
             border_width = 2)
    if showRangeLabel
        rangeSize    = sessionRangeHigh - sessionRangeLow
        displayValue = rangeDisplayUnit == "Points" ? rangeSize : rangeSize / syminfo.mintick
        label.new(
             x         = sessionRangeEndBar,
             y         = sessionRangeHigh,
             text      = str.format("Range: {0,number,#.##} {1}", displayValue, rangeDisplayUnit),
             style     = label.style_label_down,
             color     = rangeBoxBorder,
             textcolor = color.white,
             size      = size.normal)

// ════════════════════════════════════════════════════════════════════════════════
// RANGE LEVEL LINE (midpoint / fib)
// ════════════════════════════════════════════════════════════════════════════════

if candleNumber == rangeEndCandle and not na(sessionRangeHigh) and showMidLine
    midPrice  = sessionRangeLow + (sessionRangeHigh - sessionRangeLow) * midLineFrac
    rightEdge = f_staticRightEdge(sessionRangeEndBar)
    line.new(
         x1    = sessionRangeStartBar,
         y1    = midPrice,
         x2    = rightEdge,
         y2    = midPrice,
         color = midLineColor,
         width = midLineWidth,
         style = line.style_dashed)

// ════════════════════════════════════════════════════════════════════════════════
// DRAW TRADE LEVELS
// ════════════════════════════════════════════════════════════════════════════════

if (longBreak or shortBreak) and showTradeLevels and not na(sessionEntryPrice)
    if extendMode == "Win or Loss"
        tradEntryLine  := line.new(sessionEntryBar, sessionEntryPrice,  bar_index, sessionEntryPrice,
             color=entryLineColor,  width=2, style=line.style_solid)
        tradTargetLine := line.new(sessionEntryBar, sessionTargetPrice, bar_index, sessionTargetPrice,
             color=targetLineColor, width=2, style=line.style_dashed)
        tradStopLine   := line.new(sessionEntryBar, sessionStopPrice,   bar_index, sessionStopPrice,
             color=stopLineColor,   width=2, style=line.style_dashed)
        linefill.new(tradEntryLine, tradTargetLine, targetFillColor)
        linefill.new(tradEntryLine, tradStopLine,   stopFillColor)
    else
        rightEdge = f_staticRightEdge(sessionEntryBar)
        el = line.new(sessionEntryBar, sessionEntryPrice,  rightEdge, sessionEntryPrice,
             color=entryLineColor,  width=2, style=line.style_solid)
        tl = line.new(sessionEntryBar, sessionTargetPrice, rightEdge, sessionTargetPrice,
             color=targetLineColor, width=2, style=line.style_dashed)
        sl = line.new(sessionEntryBar, sessionStopPrice,   rightEdge, sessionStopPrice,
             color=stopLineColor,   width=2, style=line.style_dashed)
        linefill.new(el, tl, targetFillColor)
        linefill.new(el, sl, stopFillColor)

// ── Update "Win or Loss" lines every bar ─────────────────────────────────────
if extendMode == "Win or Loss" and sessionTradeTriggered and not na(tradEntryLine)
    if sessionTradeResolved
        line.set_x2(tradEntryLine,  sessionResolvedBar)
        line.set_x2(tradTargetLine, sessionResolvedBar)
        line.set_x2(tradStopLine,   sessionResolvedBar)
    else
        line.set_x2(tradEntryLine,  bar_index)
        line.set_x2(tradTargetLine, bar_index)
        line.set_x2(tradStopLine,   bar_index)

// ════════════════════════════════════════════════════════════════════════════════
// WIN / LOSS / PARTIAL LABELS
// ════════════════════════════════════════════════════════════════════════════════

bool doEvaluate = false
if extendMode == "Win or Loss"
    doEvaluate := justResolved
else
    doEvaluate := isRTHClose and sessionTradeTriggered and not na(sessionEntryPrice)

if doEvaluate
    [outcome, _pts] = f_calcOutcome(sessionDir, sessionEntryPrice, sessionTargetPrice,
         sessionStopPrice, high, low, close, rangeDisplayUnit)
    outcomeColor = f_outcomeColor(outcome)
    isPartial    = str.contains(outcome, "PARTIAL")

    label.new(
         x         = bar_index,
         y         = sessionDir == "LONG" ? sessionTargetPrice : sessionStopPrice,
         text      = outcome,
         style     = label.style_label_left,
         color     = outcomeColor,
         textcolor = color.white,
         size      = size.normal)

    if isPartial
        label.new(
             x         = bar_index,
             y         = sessionEntryPrice,
             text      = outcome,
             style     = label.style_label_left,
             color     = outcomeColor,
             textcolor = color.white,
             size      = size.small)

// ════════════════════════════════════════════════════════════════════════════════
// P&L ACCUMULATOR
// ════════════════════════════════════════════════════════════════════════════════

var float pnlTotal       = 0.0
var float pnlWinPts      = 0.0
var float pnlLossPts     = 0.0
var float pnlPartWinPts  = 0.0
var float pnlPartLossPts = 0.0
var int   pnlWins        = 0
var int   pnlLosses      = 0
var int   pnlPartialWins = 0
var int   pnlPartialLoss = 0
var int   pnlNoTrade     = 0
var int   pnlSessions    = 0

bool inDateRange = time >= pnlStartDate and time <= pnlEndDate

if doEvaluate and inDateRange
    [_outcome, pts] = f_calcOutcome(sessionDir, sessionEntryPrice, sessionTargetPrice,
         sessionStopPrice, high, low, close, rangeDisplayUnit)
    pnlSessions := pnlSessions + 1
    pnlTotal    := pnlTotal + pts
    if str.contains(_outcome, "✔ WIN")
        pnlWins   := pnlWins + 1
        pnlWinPts := pnlWinPts + pts
    else if str.contains(_outcome, "✘ LOSS")
        pnlLosses  := pnlLosses + 1
        pnlLossPts := pnlLossPts + pts
    else if str.contains(_outcome, "PARTIAL WIN")
        pnlPartialWins := pnlPartialWins + 1
        pnlPartWinPts  := pnlPartWinPts + pts
    else
        pnlPartialLoss := pnlPartialLoss + 1
        pnlPartLossPts := pnlPartLossPts + pts

if isRTHClose and sessionRangeComplete and not sessionTradeTriggered and inDateRange
    pnlNoTrade  := pnlNoTrade + 1
    pnlSessions := pnlSessions + 1

// ════════════════════════════════════════════════════════════════════════════════
// P&L TABLE
// ════════════════════════════════════════════════════════════════════════════════

var table pnlTable = na

if showPnL and barstate.islast
    tPos = switch pnlPosition
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

    if not na(pnlTable)
        table.delete(pnlTable)

    pnlTable := table.new(tPos, columns=2, rows=10,
         bgcolor=color.new(color.black, 20),
         border_color=color.new(color.white, 50),
         border_width=1,
         frame_color=color.new(color.white, 30),
         frame_width=2)

    table.cell(pnlTable, 0, 0, "P&L SUMMARY",
         text_color=color.white,
         text_size=size.normal,
         bgcolor=color.new(color.blue, 30))
    table.cell(pnlTable, 1, 0, rangeDisplayUnit,
         text_color=color.new(color.white, 30),
         text_size=size.normal,
         bgcolor=color.new(color.blue, 30))

    totalColor = pnlTotal >= 0 ? color.new(color.green, 0) : color.new(color.red, 0)
    totalStr   = (pnlTotal >= 0 ? "+" : "") + str.tostring(math.round(pnlTotal, 2))
    f_row(pnlTable, 1, "Total P&L",     totalStr,                     totalColor)
    f_row(pnlTable, 2, "Sessions",      str.tostring(pnlSessions),    color.white)
    f_row(pnlTable, 3, "✔ Wins",        str.tostring(pnlWins),        color.green)
    f_row(pnlTable, 4, "✘ Losses",      str.tostring(pnlLosses),      color.red)
    f_row(pnlTable, 5, "◑ Part. Wins",  str.tostring(pnlPartialWins), color.teal)
    f_row(pnlTable, 6, "◑ Part. Loss",  str.tostring(pnlPartialLoss), color.orange)
    f_row(pnlTable, 7, "— No Trade",    str.tostring(pnlNoTrade),     color.gray)

    avgWin     = pnlWins   > 0 ? math.round(pnlWinPts  / pnlWins,   2) : 0.0
    avgLoss    = pnlLosses > 0 ? math.round(pnlLossPts / pnlLosses, 2) : 0.0
    avgWinStr  = pnlWins   > 0 ? "+" + str.tostring(avgWin)  : "n/a"
    avgLossStr = pnlLosses > 0 ? str.tostring(avgLoss)        : "n/a"
    f_row(pnlTable, 8, "Avg Win",  avgWinStr,  color.green)
    f_row(pnlTable, 9, "Avg Loss", avgLossStr, color.red)

// ════════════════════════════════════════════════════════════════════════════════
// SIGNALS & ALERTS
// ════════════════════════════════════════════════════════════════════════════════

plotshape(longBreak,  "Long Entry",  shape.triangleup,   location.belowbar, color.new(color.green, 0), size=size.normal)
plotshape(shortBreak, "Short Entry", shape.triangledown, location.abovebar, color.new(color.red,   0), size=size.normal)

if longBreak and enableAlerts
    alert("LONG BREAKOUT\nEntry: "  + str.tostring(sessionEntryPrice) +
          "\nTarget: " + str.tostring(sessionTargetPrice) +
          "\nStop: "   + str.tostring(sessionStopPrice) +
          "\nRange: "  + str.tostring(math.round(sessionEffectiveRange, 2)), alert.freq_once_per_bar)

if shortBreak and enableAlerts
    alert("SHORT BREAKOUT\nEntry: " + str.tostring(sessionEntryPrice) +
          "\nTarget: " + str.tostring(sessionTargetPrice) +
          "\nStop: "   + str.tostring(sessionStopPrice) +
          "\nRange: "  + str.tostring(math.round(sessionEffectiveRange, 2)), alert.freq_once_per_bar)

// ════════════════════════════════════════════════════════════════════════════════
// DEBUG
// ════════════════════════════════════════════════════════════════════════════════

plot(candleNumber,          "Candle #",        display=display.data_window)
plot(sessionRangeHigh,      "Range High",      display=display.data_window, color=color.green)
plot(sessionRangeLow,       "Range Low",       display=display.data_window, color=color.red)
plot(sessionEffectiveRange, "Effective Range", display=display.data_window, color=color.yellow)
````
