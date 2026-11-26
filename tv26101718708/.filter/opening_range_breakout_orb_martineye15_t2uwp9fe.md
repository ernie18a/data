# Opening Range Breakout (ORB) [martineye15]

- url: https://www.tradingview.com/script/t2Uwp9FE-Opening-Range-Breakout-ORB-martineye15/
- type: indicator
- pine_id: PUB;ddf44d7225774186a642d8934fa567f5
- version: 1.0

## Description

Opening Range Breakout (ORB) — a configurable, non-repainting opening-range breakout tool. It records the high and low of an opening-range window you define, locks that range at session close, then signals breakouts above or below it and projects a stop-loss and up to three take-profit targets for each one. It is market-agnostic: session, timezone, active days, confirmation style, risk model, filters, visuals and alerts are all inputs, so the same tool adapts to indices, futures, forex, crypto or stocks on any intraday timeframe.

THE OPENING RANGE
- Define the range by session time and timezone (e.g. 0930-0945 New York for the first 15 minutes of the US cash open), with presets for the major world market zones.
- Choose which weekdays are active (Mon to Sun).
- The range builds live during the window, then locks at session close. Optionally extend the locked levels across the rest of the day.

BREAKOUT DETECTION
- Confirmation: require a bar to close beyond the level, or count any wick / touch.
- Signal mode: the first breakout of the day only, or every breakout.
- Optional retest: after the initial break, wait for price to return to the broken level and resume in the breakout direction before signalling.

RISK MODEL
- Stop-loss: opposite OR boundary, OR midpoint, ATR, fixed ticks, or percent.
- Take-profit: risk multiple (R), OR-range multiple, ATR, fixed ticks, or percent, with up to three targets.
- Levels are computed from the entry, drawn with labels, and their hits are tracked bar by bar.

FILTERS
- OR size filter: skip days whose range is too small or too large (in ticks or percent) to avoid low-quality sessions.
- One trade per day.
- Volume confirmation: require the breakout bar's volume to exceed its moving average.

VISUALS & INFO
- Opening-range box and high/low lines, breakout labels, and SL/TP lines, all with configurable colours, width and style.
- Optional session background, and an on-chart info table showing the OR high/low, range size, current state (forming / waiting / filtered / active / closed) and the latest result.

ALERTS
- Opening range formed, bullish breakout, bearish breakout, take-profit hit, and stop-loss hit, with messages that include the symbol, timeframe and levels.

HOW TO USE
Apply it to an intraday chart and set the OR session and timezone to match your instrument — the US cash open, a forex session open, or any window you trade. Tune the stop and target model to your risk approach, add the size, volume or one-trade-per-day filters if you want stricter conditions, and set alerts on the events you care about. Every module toggles independently, so you can keep the chart minimal or fully detailed.

WHAT MAKES IT DIFFERENT
Rather than a fixed opening-range window with a single stop and target rule, everything is parameterised: five stop methods, five target methods with up to three targets, an optional retest condition, size and volume filters, and full timezone / session / weekday control — so one tool fits very different instruments and playbooks while staying non-repainting.

REPAINTING & LIMITATIONS
Breakout signals and stop/target hits are evaluated only on confirmed (closed) bars, so historical and realtime behaviour match — the tool does not repaint. The opening-range box and lines update live while the range is still forming, which is expected. It runs on intraday timeframes only; on daily or higher it displays a notice instead of drawing.

This is a visual, decision-support tool. It is not a strategy, it places no orders and reports no performance statistics, and it is not financial advice.

## Source Code

````pine
//@version=6
// ============================================================================
// Opening Range Breakout (ORB)
// ----------------------------------------------------------------------------
// Market-agnostic, non-repainting opening-range breakout tool.
//   1. Records the high/low of a user-defined opening-range session window.
//   2. Locks the range at session close, then signals breakouts above/below it.
//   3. Projects a stop-loss and up to three take-profit targets per breakout.
//   4. Resets all per-day state when the next day's opening range begins.
//
// Non-repaint: breakout signals and hit-tracking are evaluated only on
// confirmed bars (barstate.isconfirmed), so historical and realtime behaviour
// match. Everything (session, timezone, active days, risk model, visuals,
// alerts) is driven by inputs — nothing is hardcoded. Intraday timeframes only.
//
// Usage: apply to an intraday chart, set the OR Session + Timezone for your
// instrument (see notes below), then tune the risk model and filters.
// ============================================================================
indicator("Opening Range Breakout (ORB)", "ORB", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ============================================================================
// INPUTS
// ============================================================================

// --- Group: Opening Range ---------------------------------------------------
grpOR      = "Opening Range"
tz         = input.string("America/New_York", "Timezone", options = ["America/New_York", "America/Chicago", "America/Denver", "America/Los_Angeles", "America/Sao_Paulo", "UTC", "Europe/London", "Europe/Berlin", "Europe/Zurich", "Europe/Moscow", "Asia/Dubai", "Asia/Kolkata", "Asia/Singapore", "Asia/Hong_Kong", "Asia/Shanghai", "Asia/Tokyo", "Australia/Sydney"], tooltip = "How the opening-range session window is interpreted. Use the exchange timezone of your instrument, UTC, or a major market zone.", group = grpOR)
orSession  = input.session("0930-0945", "OR Session", tooltip = "Start–end of the opening range (e.g. 0930-0945 = first 15 minutes of the US cash session).", group = grpOR)
useMon     = input.bool(true,  "Mon", inline = "days1", group = grpOR)
useTue     = input.bool(true,  "Tue", inline = "days1", group = grpOR)
useWed     = input.bool(true,  "Wed", inline = "days1", group = grpOR)
useThu     = input.bool(true,  "Thu", inline = "days1", group = grpOR)
useFri     = input.bool(true,  "Fri", inline = "days1", group = grpOR)
useSat     = input.bool(false, "Sat", inline = "days2", group = grpOR)
useSun     = input.bool(false, "Sun", inline = "days2", group = grpOR)
extendEOD  = input.bool(true,  "Extend levels to end of day", group = grpOR)

// --- Group: Breakout --------------------------------------------------------
grpBrk        = "Breakout"
confirmType   = input.string("Close", "Confirmation", options = ["Close", "Wick (touch)"], tooltip = "Close: the bar must close beyond the level. Wick (touch): any penetration of the level counts.", group = grpBrk)
signalMode    = input.string("First breakout only", "Signal mode", options = ["First breakout only", "All breakouts"], group = grpBrk)
requireRetest = input.bool(false, "Require retest", tooltip = "After the initial break, wait for price to return to the broken level and then continue in the breakout direction before signalling.", group = grpBrk)

// --- Group: Risk Management -------------------------------------------------
grpRisk    = "Risk Management"
slMethod   = input.string("Opposite OR boundary", "Stop Loss method", options = ["Opposite OR boundary", "OR midpoint", "ATR", "Fixed (ticks)", "Percent"], group = grpRisk)
atrLen     = input.int(14, "ATR length", minval = 1, tooltip = "Used when Stop Loss or Take Profit method is ATR.", group = grpRisk)
atrMult    = input.float(1.5, "ATR multiple", minval = 0.0, step = 0.1, tooltip = "One ATR risk unit = ATR × this multiple. Used when SL or TP method is ATR.", group = grpRisk)
fixedTicks = input.float(100, "Fixed SL (ticks)", minval = 0.0, tooltip = "Stop distance in ticks when Stop Loss method is Fixed (ticks).", group = grpRisk)
slPercent  = input.float(0.5, "Percent", minval = 0.0, step = 0.1, tooltip = "Stop distance in percent when Stop Loss method is Percent.", group = grpRisk)
tpMethod   = input.string("Risk multiple (R)", "Take Profit method", options = ["Risk multiple (R)", "OR range multiple", "ATR", "Fixed (ticks)", "Percent"], group = grpRisk)
numTargets = input.int(2, "Number of targets", minval = 1, maxval = 3, group = grpRisk)
tp1Val     = input.float(1.0, "TP1 value", step = 0.1, tooltip = "Interpreted per Take Profit method: R multiple, OR-range multiple, ATR units, ticks, or percent.", group = grpRisk)
tp2Val     = input.float(2.0, "TP2 value", step = 0.1, group = grpRisk)
tp3Val     = input.float(3.0, "TP3 value", step = 0.1, group = grpRisk)

// --- Group: Filters ---------------------------------------------------------
grpFilt        = "Filters"
sizeUnit       = input.string("Ticks", "OR size filter unit", options = ["Ticks", "Percent"], tooltip = "Unit for the Min/Max OR size filters below.", group = grpFilt)
minSize        = input.float(0.0, "Min OR size", minval = 0.0, tooltip = "Skip days whose opening range is smaller than this (in the unit above). 0 = off.", group = grpFilt)
maxSize        = input.float(0.0, "Max OR size", minval = 0.0, tooltip = "Skip days whose opening range is larger than this (in the unit above). 0 = off.", group = grpFilt)
oneTradePerDay = input.bool(true, "One trade per day", group = grpFilt)
useVol         = input.bool(false, "Volume confirmation", tooltip = "Require the breakout bar's volume to exceed its moving average.", group = grpFilt)
volLen         = input.int(20, "Volume MA length", minval = 1, group = grpFilt)

// --- Group: Visuals ---------------------------------------------------------
grpVis        = "Visuals"
showBox       = input.bool(true,  "Show OR box", group = grpVis)
showLines     = input.bool(true,  "Show OR lines", group = grpVis)
showLabels    = input.bool(true,  "Show breakout labels", group = grpVis)
showRisk      = input.bool(true,  "Show SL/TP lines", group = grpVis)
showSessionBg = input.bool(false, "Show session background", group = grpVis)
bullColor     = input.color(color.new(#26a69a, 0), "Bull",   inline = "c1", group = grpVis)
bearColor     = input.color(color.new(#ef5350, 0), "Bear",   inline = "c1", group = grpVis)
boxColor      = input.color(color.new(#2962ff, 0), "OR box", inline = "c2", group = grpVis)
boxTransp     = input.int(85, "Transp", minval = 0, maxval = 100, inline = "c2", group = grpVis)
slColor       = input.color(color.new(#ef5350, 0), "SL",     inline = "c3", group = grpVis)
tpColor       = input.color(color.new(#26a69a, 0), "TP",     inline = "c3", group = grpVis)
lineWidth     = input.int(2, "Line width", minval = 1, maxval = 5, group = grpVis)
lineStyleStr  = input.string("Solid", "Line style", options = ["Solid", "Dashed", "Dotted"], group = grpVis)
showTable     = input.bool(true, "Show info table", inline = "tbl", group = grpVis)
tablePosStr   = input.string("Top right", "", options = ["Top right", "Top left", "Bottom right", "Bottom left", "Middle right"], inline = "tbl", group = grpVis)

// --- Group: Alerts ----------------------------------------------------------
grpAlert   = "Alerts"
alORFormed = input.bool(true, "Alert: OR formed", group = grpAlert)
alBull     = input.bool(true, "Alert: Bull breakout", group = grpAlert)
alBear     = input.bool(true, "Alert: Bear breakout", group = grpAlert)
alTP       = input.bool(true, "Alert: TP hit", group = grpAlert)
alSL       = input.bool(true, "Alert: SL hit", group = grpAlert)

// ============================================================================
// TIMEZONE / SESSION / DERIVED
// ============================================================================
isIntraday = not timeframe.isdwm

// Session membership — never compares hour/minute manually.
inOR       = not na(time(timeframe.period, orSession, tz))
newSession = inOR and not inOR[1]
orClosed   = not inOR and inOR[1]

// Map string inputs to Pine constants.
lineStyle = lineStyleStr == "Dashed" ? line.style_dashed : lineStyleStr == "Dotted" ? line.style_dotted : line.style_solid
tablePos  = tablePosStr == "Top left" ? position.top_left : tablePosStr == "Bottom right" ? position.bottom_right : tablePosStr == "Bottom left" ? position.bottom_left : tablePosStr == "Middle right" ? position.middle_right : position.top_right

// Indicators evaluated every bar (kept out of conditionals for stable history).
atrVal = ta.atr(atrLen)
volMa  = ta.sma(volume, volLen)

// ============================================================================
// PER-DAY STATE (persisted with var)
// ============================================================================
var int   orStartBar    = na
var float orHigh        = na
var float orLow         = na
var float orRange       = na
var int   orDow         = na
var bool  orLocked      = false
var bool  tradable      = false
var bool  longDone      = false
var bool  shortDone     = false
var bool  tradeTaken    = false
var int   tradeDir      = 0        // 1 = long, -1 = short, 0 = flat
var int   lastDir       = 0
var float tEntry        = na
var float tSL           = na
var float tTP1          = na
var float tTP2          = na
var float tTP3          = na
var bool  tp1Hit        = false
var bool  tp2Hit        = false
var bool  tp3Hit        = false
var bool  slHit         = false
var bool  longBroke     = false
var bool  shortBroke    = false
var bool  longRetested  = false
var bool  shortRetested = false

// Drawing handles for the current day.
var box   orBox   = na
var line  hiLine  = na
var line  loLine  = na
var line  slLine  = na
var line  tp1Line = na
var line  tp2Line = na
var line  tp3Line = na
var label slLbl   = na
var label tp1Lbl  = na
var label tp2Lbl  = na
var label tp3Lbl  = na

// ============================================================================
// RISK-LEVEL HELPERS
// ============================================================================
slPrice(float ent, float atrUnit, bool isLong) =>
    float p = na
    if slMethod == "Opposite OR boundary"
        p := isLong ? orLow : orHigh
    else if slMethod == "OR midpoint"
        p := (orHigh + orLow) / 2
    else if slMethod == "ATR"
        p := isLong ? ent - atrUnit : ent + atrUnit
    else if slMethod == "Fixed (ticks)"
        p := isLong ? ent - fixedTicks * syminfo.mintick : ent + fixedTicks * syminfo.mintick
    else
        p := isLong ? ent * (1 - slPercent / 100) : ent * (1 + slPercent / 100)
    p

tpPrice(float ent, float riskDist, float atrUnit, float tpv, bool isLong) =>
    float p = na
    if tpMethod == "Percent"
        p := isLong ? ent * (1 + tpv / 100) : ent * (1 - tpv / 100)
    else
        float dist = tpMethod == "Risk multiple (R)" ? riskDist * tpv : tpMethod == "OR range multiple" ? orRange * tpv : tpMethod == "ATR" ? atrUnit * tpv : tpv * syminfo.mintick
        p := isLong ? ent + dist : ent - dist
    p

// ============================================================================
// EVENT FLAGS (recomputed each bar; consumed by alerts below)
// ============================================================================
bool evtORFormed = false
bool evtBull     = false
bool evtBear     = false
bool evtTP       = false
bool evtSL       = false

// ============================================================================
// MAIN LOGIC (intraday only)
// ============================================================================
if isIntraday
    // ---- New session: reset every per-day flag and start a fresh range ----
    if newSession
        orStartBar    := bar_index
        orHigh        := high
        orLow         := low
        orDow         := dayofweek(time, tz)
        orLocked      := false
        tradable      := false
        longDone      := false
        shortDone     := false
        tradeTaken    := false
        tradeDir      := 0
        lastDir       := 0
        tEntry        := na
        tSL           := na
        tTP1          := na
        tTP2          := na
        tTP3          := na
        tp1Hit        := false
        tp2Hit        := false
        tp3Hit        := false
        slHit         := false
        longBroke     := false
        shortBroke    := false
        longRetested  := false
        shortRetested := false
        // Detach previous day's trade drawings (left frozen on chart).
        slLine  := na
        tp1Line := na
        tp2Line := na
        tp3Line := na
        slLbl   := na
        tp1Lbl  := na
        tp2Lbl  := na
        tp3Lbl  := na
        if showBox
            orBox := box.new(orStartBar, orHigh, orStartBar, orLow, border_color = boxColor, border_width = 1, bgcolor = color.new(boxColor, boxTransp))
        if showLines
            hiLine := line.new(orStartBar, orHigh, orStartBar, orHigh, color = boxColor, width = lineWidth, style = lineStyle)
            loLine := line.new(orStartBar, orLow,  orStartBar, orLow,  color = boxColor, width = lineWidth, style = lineStyle)
    else if inOR
        orHigh := math.max(orHigh, high)
        orLow  := math.min(orLow, low)

    // ---- While forming: grow the box & lines with the range ----
    if inOR
        if not na(orBox)
            box.set_top(orBox, orHigh)
            box.set_bottom(orBox, orLow)
            box.set_right(orBox, bar_index)
        if not na(hiLine)
            line.set_xy1(hiLine, orStartBar, orHigh)
            line.set_xy2(hiLine, bar_index, orHigh)
        if not na(loLine)
            line.set_xy1(loLine, orStartBar, orLow)
            line.set_xy2(loLine, bar_index, orLow)

    // ---- Lock at session close: evaluate active-day + size filters ----
    if orClosed
        orLocked := true
        orRange  := orHigh - orLow
        dayOk = (orDow == dayofweek.monday and useMon) or (orDow == dayofweek.tuesday and useTue) or (orDow == dayofweek.wednesday and useWed) or (orDow == dayofweek.thursday and useThu) or (orDow == dayofweek.friday and useFri) or (orDow == dayofweek.saturday and useSat) or (orDow == dayofweek.sunday and useSun)
        mid = (orHigh + orLow) / 2
        sizeMeasure = sizeUnit == "Percent" ? (mid != 0 ? orRange / mid * 100 : 0.0) : orRange / syminfo.mintick
        sizeOk = (minSize <= 0 or sizeMeasure >= minSize) and (maxSize <= 0 or sizeMeasure <= maxSize)
        tradable := dayOk and sizeOk and orRange > 0
        evtORFormed := true

    // ---- After lock: optionally extend the levels to the end of the day ----
    if orLocked and not inOR and extendEOD
        if not na(orBox)
            box.set_right(orBox, bar_index)
        if not na(hiLine)
            line.set_xy2(hiLine, bar_index, orHigh)
        if not na(loLine)
            line.set_xy2(loLine, bar_index, orLow)

    // ---- Breakout detection (confirmed bars only → no repaint) ----
    canTrade    = orLocked and tradable and barstate.isconfirmed and not inOR
    longRaw     = confirmType == "Close" ? close > orHigh : high > orHigh
    shortRaw    = confirmType == "Close" ? close < orLow  : low  < orLow
    longInside  = confirmType == "Close" ? close <= orHigh : high <= orHigh
    shortInside = confirmType == "Close" ? close >= orLow  : low  >= orLow

    bool longSignal  = false
    bool shortSignal = false
    if canTrade
        // ----- Long -----
        if not requireRetest
            if longRaw and not longBroke
                longBroke := true
                if signalMode == "All breakouts" or not longDone
                    longSignal := true
            if signalMode == "All breakouts" and longBroke and longInside
                longBroke := false
        else
            justBrokeL = longRaw and not longBroke
            if justBrokeL
                longBroke := true
            else if longBroke and not longRetested and low <= orHigh
                longRetested := true
            else if longBroke and longRetested and longRaw
                if signalMode == "All breakouts" or not longDone
                    longSignal := true
                if signalMode == "All breakouts"
                    longBroke    := false
                    longRetested := false
        // ----- Short -----
        if not requireRetest
            if shortRaw and not shortBroke
                shortBroke := true
                if signalMode == "All breakouts" or not shortDone
                    shortSignal := true
            if signalMode == "All breakouts" and shortBroke and shortInside
                shortBroke := false
        else
            justBrokeS = shortRaw and not shortBroke
            if justBrokeS
                shortBroke := true
            else if shortBroke and not shortRetested and high >= orLow
                shortRetested := true
            else if shortBroke and shortRetested and shortRaw
                if signalMode == "All breakouts" or not shortDone
                    shortSignal := true
                if signalMode == "All breakouts"
                    shortBroke    := false
                    shortRetested := false

    // Breakout-bar gates: volume confirmation + one-trade-per-day + flat.
    volOk   = not useVol or (not na(volMa) and volume > volMa)
    canOpen = tradeDir == 0 and (not oneTradePerDay or not tradeTaken)
    takeLong  = longSignal  and volOk and canOpen
    takeShort = shortSignal and volOk and canOpen and not takeLong

    // ---- Open a LONG: compute levels, draw, flag alert ----
    if takeLong
        longDone   := true
        tradeTaken := true
        tradeDir   := 1
        lastDir    := 1
        tEntry     := confirmType == "Close" ? close : orHigh
        float atrUnit  = atrVal * atrMult
        tSL := slPrice(tEntry, atrUnit, true)
        float riskDist = math.abs(tEntry - tSL)
        tTP1 := numTargets >= 1 ? tpPrice(tEntry, riskDist, atrUnit, tp1Val, true) : na
        tTP2 := numTargets >= 2 ? tpPrice(tEntry, riskDist, atrUnit, tp2Val, true) : na
        tTP3 := numTargets >= 3 ? tpPrice(tEntry, riskDist, atrUnit, tp3Val, true) : na
        tp1Hit := false
        tp2Hit := false
        tp3Hit := false
        slHit  := false
        evtBull := true
        if showLabels
            label.new(bar_index, low, "▲ " + str.tostring(tEntry, format.mintick), style = label.style_label_up, color = bullColor, textcolor = color.white, size = size.small)
        if showRisk
            slLine := line.new(bar_index, tSL, bar_index, tSL, color = slColor, width = lineWidth, style = lineStyle)
            slLbl  := label.new(bar_index, tSL, "SL " + str.tostring(tSL, format.mintick), style = label.style_label_left, color = color.new(slColor, 20), textcolor = color.white, size = size.small)
            if not na(tTP1)
                tp1Line := line.new(bar_index, tTP1, bar_index, tTP1, color = tpColor, width = lineWidth, style = lineStyle)
                tp1Lbl  := label.new(bar_index, tTP1, "TP1 " + str.tostring(tTP1, format.mintick), style = label.style_label_left, color = color.new(tpColor, 20), textcolor = color.white, size = size.small)
            if not na(tTP2)
                tp2Line := line.new(bar_index, tTP2, bar_index, tTP2, color = tpColor, width = lineWidth, style = lineStyle)
                tp2Lbl  := label.new(bar_index, tTP2, "TP2 " + str.tostring(tTP2, format.mintick), style = label.style_label_left, color = color.new(tpColor, 20), textcolor = color.white, size = size.small)
            if not na(tTP3)
                tp3Line := line.new(bar_index, tTP3, bar_index, tTP3, color = tpColor, width = lineWidth, style = lineStyle)
                tp3Lbl  := label.new(bar_index, tTP3, "TP3 " + str.tostring(tTP3, format.mintick), style = label.style_label_left, color = color.new(tpColor, 20), textcolor = color.white, size = size.small)

    // ---- Open a SHORT: compute levels, draw, flag alert ----
    if takeShort
        shortDone  := true
        tradeTaken := true
        tradeDir   := -1
        lastDir    := -1
        tEntry     := confirmType == "Close" ? close : orLow
        float atrUnit  = atrVal * atrMult
        tSL := slPrice(tEntry, atrUnit, false)
        float riskDist = math.abs(tEntry - tSL)
        tTP1 := numTargets >= 1 ? tpPrice(tEntry, riskDist, atrUnit, tp1Val, false) : na
        tTP2 := numTargets >= 2 ? tpPrice(tEntry, riskDist, atrUnit, tp2Val, false) : na
        tTP3 := numTargets >= 3 ? tpPrice(tEntry, riskDist, atrUnit, tp3Val, false) : na
        tp1Hit := false
        tp2Hit := false
        tp3Hit := false
        slHit  := false
        evtBear := true
        if showLabels
            label.new(bar_index, high, "▼ " + str.tostring(tEntry, format.mintick), style = label.style_label_down, color = bearColor, textcolor = color.white, size = size.small)
        if showRisk
            slLine := line.new(bar_index, tSL, bar_index, tSL, color = slColor, width = lineWidth, style = lineStyle)
            slLbl  := label.new(bar_index, tSL, "SL " + str.tostring(tSL, format.mintick), style = label.style_label_left, color = color.new(slColor, 20), textcolor = color.white, size = size.small)
            if not na(tTP1)
                tp1Line := line.new(bar_index, tTP1, bar_index, tTP1, color = tpColor, width = lineWidth, style = lineStyle)
                tp1Lbl  := label.new(bar_index, tTP1, "TP1 " + str.tostring(tTP1, format.mintick), style = label.style_label_left, color = color.new(tpColor, 20), textcolor = color.white, size = size.small)
            if not na(tTP2)
                tp2Line := line.new(bar_index, tTP2, bar_index, tTP2, color = tpColor, width = lineWidth, style = lineStyle)
                tp2Lbl  := label.new(bar_index, tTP2, "TP2 " + str.tostring(tTP2, format.mintick), style = label.style_label_left, color = color.new(tpColor, 20), textcolor = color.white, size = size.small)
            if not na(tTP3)
                tp3Line := line.new(bar_index, tTP3, bar_index, tTP3, color = tpColor, width = lineWidth, style = lineStyle)
                tp3Lbl  := label.new(bar_index, tTP3, "TP3 " + str.tostring(tTP3, format.mintick), style = label.style_label_left, color = color.new(tpColor, 20), textcolor = color.white, size = size.small)

    // ---- Keep active-trade lines & labels tracking the current bar ----
    if tradeDir != 0
        if not na(slLine)
            line.set_xy2(slLine, bar_index, tSL)
            label.set_x(slLbl, bar_index)
        if not na(tp1Line)
            line.set_xy2(tp1Line, bar_index, tTP1)
            label.set_x(tp1Lbl, bar_index)
        if not na(tp2Line)
            line.set_xy2(tp2Line, bar_index, tTP2)
            label.set_x(tp2Lbl, bar_index)
        if not na(tp3Line)
            line.set_xy2(tp3Line, bar_index, tTP3)
            label.set_x(tp3Lbl, bar_index)

    // ---- Track SL / TP hits on confirmed bars ----
    if tradeDir != 0 and barstate.isconfirmed
        if tradeDir == 1
            if not slHit and low <= tSL
                slHit := true
                evtSL := true
            if not na(tTP1) and not tp1Hit and high >= tTP1
                tp1Hit := true
                evtTP  := true
            if not na(tTP2) and not tp2Hit and high >= tTP2
                tp2Hit := true
                evtTP  := true
            if not na(tTP3) and not tp3Hit and high >= tTP3
                tp3Hit := true
                evtTP  := true
        else
            if not slHit and high >= tSL
                slHit := true
                evtSL := true
            if not na(tTP1) and not tp1Hit and low <= tTP1
                tp1Hit := true
                evtTP  := true
            if not na(tTP2) and not tp2Hit and low <= tTP2
                tp2Hit := true
                evtTP  := true
            if not na(tTP3) and not tp3Hit and low <= tTP3
                tp3Hit := true
                evtTP  := true
        finalTpHit = (numTargets == 1 and tp1Hit) or (numTargets == 2 and tp2Hit) or (numTargets == 3 and tp3Hit)
        if slHit or finalTpHit
            tradeDir := 0

// ============================================================================
// SESSION BACKGROUND
// ============================================================================
bgcolor(isIntraday and showSessionBg and inOR ? color.new(boxColor, 90) : na)

// ============================================================================
// NON-INTRADAY WARNING (never breaks the chart)
// ============================================================================
var label warnLbl = na
if timeframe.isdwm and barstate.islast
    if na(warnLbl)
        warnLbl := label.new(bar_index, high, "Opening Range Breakout works on intraday timeframes only.\nSwitch to an intraday chart (e.g. 1–15 min).", style = label.style_label_down, color = color.new(color.orange, 0), textcolor = color.white, size = size.normal)
    else
        label.set_xy(warnLbl, bar_index, high)

// ============================================================================
// INFO TABLE
// ============================================================================
var table infoTbl = na
if showTable and isIntraday
    if na(infoTbl)
        infoTbl := table.new(tablePos, 2, 6, border_width = 1)
    if barstate.islast
        liveRange = na(orHigh) or na(orLow) ? na : orHigh - orLow
        rngTxt = na(liveRange) ? "—" : sizeUnit == "Percent" ? str.tostring(liveRange / ((orHigh + orLow) / 2) * 100, "#.##") + " %" : str.tostring(liveRange / syminfo.mintick, "#.#") + " tk"
        stateStr = inOR ? "Forming" : not orLocked ? "Waiting" : not tradable ? "Filtered" : tradeDir == 1 ? "Long active" : tradeDir == -1 ? "Short active" : tradeTaken ? "Closed" : "Locked"
        dirTxt  = lastDir == 1 ? "Long" : lastDir == -1 ? "Short" : ""
        outcome = slHit ? "SL hit" : tp3Hit ? "TP3" : tp2Hit ? "TP2" : tp1Hit ? "TP1" : (tradeDir != 0 ? "open" : "—")
        resStr  = lastDir == 0 ? "—" : dirTxt + " · " + outcome
        cHdr = color.new(boxColor, 0)
        table.cell(infoTbl, 0, 0, "ORB", text_color = color.white, bgcolor = cHdr, text_size = size.small)
        table.cell(infoTbl, 1, 0, syminfo.ticker + " · " + timeframe.period, text_color = color.white, bgcolor = cHdr, text_size = size.small)
        table.cell(infoTbl, 0, 1, "OR High", text_color = color.gray, text_size = size.small)
        table.cell(infoTbl, 1, 1, na(orHigh) ? "—" : str.tostring(orHigh, format.mintick), text_color = color.white, text_size = size.small)
        table.cell(infoTbl, 0, 2, "OR Low", text_color = color.gray, text_size = size.small)
        table.cell(infoTbl, 1, 2, na(orLow) ? "—" : str.tostring(orLow, format.mintick), text_color = color.white, text_size = size.small)
        table.cell(infoTbl, 0, 3, "Range", text_color = color.gray, text_size = size.small)
        table.cell(infoTbl, 1, 3, rngTxt, text_color = color.white, text_size = size.small)
        table.cell(infoTbl, 0, 4, "State", text_color = color.gray, text_size = size.small)
        table.cell(infoTbl, 1, 4, stateStr, text_color = color.white, text_size = size.small)
        table.cell(infoTbl, 0, 5, "Result", text_color = color.gray, text_size = size.small)
        table.cell(infoTbl, 1, 5, resStr, text_color = color.white, text_size = size.small)

// ============================================================================
// ALERTS
// ============================================================================
alertcondition(evtORFormed, "OR formed",     "Opening range formed")
alertcondition(evtBull,     "Bull breakout", "Bullish ORB breakout")
alertcondition(evtBear,     "Bear breakout", "Bearish ORB breakout")
alertcondition(evtTP,       "TP hit",        "ORB take-profit hit")
alertcondition(evtSL,       "SL hit",        "ORB stop-loss hit")

if alORFormed and evtORFormed
    alert("ORB | " + syminfo.ticker + " " + timeframe.period + " | Opening range formed — High " + str.tostring(orHigh, format.mintick) + " / Low " + str.tostring(orLow, format.mintick), alert.freq_once_per_bar)
if alBull and evtBull
    alert("ORB | " + syminfo.ticker + " " + timeframe.period + " | BULL breakout — Entry " + str.tostring(tEntry, format.mintick) + " | SL " + str.tostring(tSL, format.mintick), alert.freq_once_per_bar)
if alBear and evtBear
    alert("ORB | " + syminfo.ticker + " " + timeframe.period + " | BEAR breakout — Entry " + str.tostring(tEntry, format.mintick) + " | SL " + str.tostring(tSL, format.mintick), alert.freq_once_per_bar)
if alTP and evtTP
    alert("ORB | " + syminfo.ticker + " " + timeframe.period + " | Take-profit hit at " + str.tostring(close, format.mintick), alert.freq_once_per_bar)
if alSL and evtSL
    alert("ORB | " + syminfo.ticker + " " + timeframe.period + " | Stop-loss hit at " + str.tostring(close, format.mintick), alert.freq_once_per_bar)
````
