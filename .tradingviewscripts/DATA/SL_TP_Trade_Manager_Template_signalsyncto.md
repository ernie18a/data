<!-- tradingview-pine-id: PUB;07f16230c84d4b99a8d9f6df1d9f3e68 -->
<!-- tradingviewscripts-format: 1 -->
# SL TP Trade Manager Template [signalsync-to]

Source: https://www.tradingview.com/script/uDCGwNaL-SL-TP-Trade-Manager-Template-for-SignalSync-to/

## Description

Automated Trade Execution & Copy Trading

A modular, signal-agnostic trade management engine built to work with SignalSync.to.

This template does not generate trade entries itself. Instead, it takes a Long/Short trigger from any compatible TradingView indicator and handles everything downstream — initial stop-loss placement, ATR-based trailing, TP1/TP2 tracking, trade timeouts, and webhook-ready JSON alerts for automated execution.

It is designed as a reusable management layer: connect the same tested trade-management logic to different signal-generating indicators without duplicating the underlying code.

HOW IT WORKS

* Connect any signal source
  Point the Long Trigger and Short Trigger inputs to the corresponding alert conditions from your signal indicator.

* Controlled entry timing
  By default, the template applies a one-bar offset: a signal confirmed on bar N triggers the entry on the open of bar N+1. This follows standard non-repainting execution. The offset can be disabled when the connected indicator generates its trigger after bar close.

* Flexible initial stop-loss
  Set the initial SL using an ATR multiple, or pull it from an external structural level such as a swing high/low or FVG edge. An optional opposite-level input can widen the stop to a structural floor/ceiling, but will never tighten it.

* Two trailing modes
  Choose between:

  * Continuous: re-evaluates the trailing stop on every eligible bar after the configured delay.
  * Stepped: updates only at fixed bar intervals, useful for reducing SL-update noise in choppy markets.

* Independent TP1 / TP2 tracking
  TP1 and TP2 are calculated using ATR multiples and tracked independently from the trailing stop. Each target has its own alert condition.

* Automatic timeout
  Optionally force-close trades that remain open for more than a configured number of bars without reaching their SL or trailing exit.

VISUALS

* Entry Zone
  Displays the initial SL/TP1 range at the moment of entry. The zone remains frozen even when the trailing stop subsequently moves.

* Live trade status
  Entry zones are color-coded:

  * Gray — trade still open or closed BE
  * Green — TP1 reached
  * Red — initial SL breached

* Zone Stats Table
  Tracks the results of the most recent entry zones, including TP, SL and neutral/BE outcomes, together with the hit rate. This provides a quick view of how the connected signal is performing without relying on the Strategy Tester.

* Live management levels
  Separate trailing SL, TP1 and TP2 lines are plotted on the chart, with pip-distance labels for both the entry zone and current trailing stop.

ALERTS & AUTOMATION

The template provides six alert conditions:

1. Long Entry
2. Short Entry
3. Stop Loss Hit
4. TP1 Hit
5. TP2 Hit
6. Timeout Exit

Each alert includes a pre-built JSON payload with TradingView placeholders, capturing the relevant values at the exact moment the alert fires.

The payload is designed as a starting point for integration with SignalSync.to. Fields such as `traderIdKey`, `tradeSide`, `relativeTakeProfit`, and `relativeStopLoss` can be adapted to your SignalSync configuration and credentials.

This allows the trade-management layer to send automated execution instructions directly through your TradingView → SignalSync → cTrader workflow.

NON-REPAINTING DESIGN

All internal trade-management logic uses confirmed-bar data and proper offsetting.

There is no lookahead in the entry/exit logic, and the alert payload captures values when the event actually occurs rather than relying on values that may change later as the chart updates.

IMPORTANT

This is a trade-management layer, not a signal generator.

It will not produce entries or plot trade-management levels until it is connected to a compatible indicator source through `input.source()`.

For educational and informational purposes only. This template is not financial advice. Test thoroughly in TradingView and on a demo account before connecting it to any live automated execution system.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © signalsync-to

//@version=6
indicator("SL TP Trade Manager Template [signalsync-to]", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// ============================ SIGNAL SOURCE ============================
grpSig = "Trigger Source (from external indicator)"
longTriggerSrc  = input.source(close, "Long Trigger Plot", group=grpSig,
     tooltip="Point at a plot() from another indicator that outputs a value > 0 on the bar a long signal fires (e.g. plot(longSignal ? 1 : na, display=display.data_window)). <= 0 or na = no signal.")
shortTriggerSrc = input.source(close, "Short Trigger Plot", group=grpSig,
     tooltip="Same as above, for short signals.")
signalConfirmedAlready = input.bool(false, "Trigger Already Offset/Confirmed (skip internal [1] shift)", group=grpSig,
     tooltip="OFF (default): this template applies its own [1] shift to the incoming trigger — 'signal closes bar N, enter at bar N+1 open', matching the rest of the JM suite.\nON: use the incoming value exactly as received. Use this only if the source indicator already outputs its trigger pre-shifted.")

rawLongTrig  = longTriggerSrc  > 0
rawShortTrig = shortTriggerSrc > 0

longSignal  = signalConfirmedAlready ? rawLongTrig  : rawLongTrig[1]
shortSignal = signalConfirmedAlready ? rawShortTrig : rawShortTrig[1]

if longSignal and shortSignal
    longSignal  := false
    shortSignal := false

// ============================ VOLATILITY STOP ============================
grpS = "Volatility Stop"
atrLen       = input.int(14, "ATR Length", group=grpS)
atrInitMult  = input.float(1.5, "Initial Stop ATR Multiplier", step=0.1, group=grpS)
slMode       = input.string("ATR Multiple", "Initial SL Mode", options=["ATR Multiple", "External Source"], group=grpS,
     tooltip="ATR Multiple: stop = entry -/+ ATR * multiplier.\nExternal Source: pulls the stop PRICE directly from another indicator's plot (e.g. a structural level). Falls back to the ATR stop on any bar the source is na.")
slExternalSrc = input.source(close, "External SL Price Source", group=grpS,
     tooltip="Only used when Initial SL Mode = External Source. Point at a plot() of the raw stop price, not a distance.")
useOppBufferFloor = input.bool(false, "Widen Initial SL to External Opposite Level (if tighter)", group=grpS,
     tooltip="Optional. If an upstream indicator plots an opposite-side structural level (far side of a range/FVG/compression zone), this widens the stop to that level when it's further away than the computed stop. Never tightens the stop.")
oppLevelSrc  = input.source(close, "External Opposite Level Source", group=grpS)
atrTrailMult = input.float(1.5, "Trailing Stop ATR Multiplier", step=0.1, group=grpS)
useTrail     = input.bool(true, "Enable Volatility Trailing Stop", group=grpS)
trailMode    = input.string("Stepped (every X bars)", "Trail Update Mode", options=["Continuous (after X bars)", "Stepped (every X bars)"], group=grpS,
     tooltip="Continuous: waits X bars, then re-evaluates the trail on every bar.\nStepped: re-evaluates only on bars X, 2X, 3X... The stop holds flat between steps.")
trailBars    = input.int(4, "Trail Bars (delay / step interval)", minval=0, group=grpS)

// ============================ TARGETS ============================
grpT = "Targets"
useTP1  = input.bool(true, "Track / Alert TP1", group=grpT)
tp1R    = input.float(1.0, "TP1 - ATR Multiple (partial)", step=0.1, group=grpT)
useTP2  = input.bool(false, "Alert at TP2 (otherwise reference only)", group=grpT)
tp2R    = input.float(3.0, "TP2 - ATR Multiple (runner)", step=0.1, group=grpT)

// ============================ EXIT DETECTION ============================
grpE = "Exit Detection"
exitBasis = input.string("Wick (intrabar)", "SL / TP Detection", options=["Wick (intrabar)", "Close (confirmed)"], group=grpE,
     tooltip="Wick = fires the moment price touches the level (use 'Once Per Bar' alerts).\nClose = only evaluates on bar close (use 'Once Per Bar Close').")

// ============================ SAFETY / INVALIDATION ============================
grpSafe = "Safety / Invalidation"
enableTradeTimeout = input.bool(false, "Auto-Flatten Stale Trade", group=grpSafe,
     tooltip="If a trade never hits its stop or trailing stop within N bars, force-close it at the current close and alert.")
tradeTimeoutBars = input.int(100, "Trade Timeout (bars)", minval=1, group=grpSafe)

// ============================ ENTRY ZONE (initial SL / TP1) ============================
grpZ = "Entry Zone (initial SL / TP1)"
showLevels    = input.bool(true, "Show Entry Zone", group=grpZ,
     tooltip="Draws the SL / TP1 / midline zone using the INITIAL levels frozen at entry. The trailing stop is plotted separately and is unaffected by this.")
showPipLabels = input.bool(true, "Show Pip Labels", group=grpZ)
pipFactor     = input.float(10, "Points per Pip", minval=0.0001, step=1, group=grpZ,
     tooltip="pipSize = syminfo.mintick * this.\n10 = 5-digit FX, and NAS100 CFD at 0.1 tick.\n4 = NQ futures at 0.25 tick.\n1 = raw ticks.")
zoneColor      = input.color(color.new(#787b86, 85), "Zone Fill",  group=grpZ, inline="ZF",
     tooltip="In process (still open), or trade closed before TP1 at breakeven/better vs. entry (neutral / BE).")
zoneTpColor    = input.color(color.new(#00e676, 85), "→ TP",       group=grpZ, inline="ZF",
     tooltip="TP1 price level was touched.")
slBreachColor  = input.color(color.new(#f23645, 85), "→ SL",       group=grpZ, inline="ZF",
     tooltip="Trade closed (trailing stop, initial SL, or timeout) at a real loss vs. entry, before touching TP1.")
zSlColor       = input.color(#f23645, "SL Line",  group=grpZ, inline="ZL")
zTpColor       = input.color(#00e676, "TP1 Line", group=grpZ, inline="ZL")
zMidColor      = input.color(#787b86, "Mid Line", group=grpZ, inline="ZL")

// ============================ ZONE STATS TABLE ============================
grpST = "Zone Stats Table"
showZoneTable = input.bool(true, "Show Zone Stats Table", group=grpST,
     tooltip="Tallies the outcome of each entry zone by REAL trade P&L: TP1 touched, closed at a loss before TP1 (SL), or closed flat/breakeven-or-better before TP1 (BE). Requires 'Show Entry Zone' enabled above to populate.")
zoneTablePos  = input.string(position.top_right, "Table Position", group=grpST,
     options=[position.top_right, position.top_left, position.bottom_right, position.bottom_left])
zoneStatsN    = input.int(100, "Zones to Track", minval=1, maxval=500, group=grpST)

// ============================ VISUALS ============================
grpV = "Visuals"
showLabels    = input.bool(true, "Show Entry / Exit Labels", group=grpV)
showLines     = input.bool(true, "Show Trailing SL / TP Plots", group=grpV)

// ============================ CORE CALCS ============================
atrVal  = ta.atr(atrLen)
pipSize = syminfo.mintick * pipFactor

// ============================ STATE ============================
var int   tradeDir    = 0
var float entryPrice  = na
var float stopPrice   = na
var float tp1Price    = na
var float tp2Price    = na
var float exitPrice   = na
var bool  tp1Hit      = false
var bool  tp2Hit      = false
var int   barsInTrade = 0

var float initSL        = na
var float initTP1       = na
var float zoneMid       = na
var float initSlPips    = na
var float initTpPips    = na
var float zoneEntryPrice = na   // entry price captured for the zone, survives the entryPrice reset on close
var bool  zoneIsLong    = false
var bool  zoneFrozen    = true
var bool  zTpHit        = false
var bool  zSlBreach     = false

var box   tradeBox     = na
var line  zSlLine      = na
var line  zTpLine      = na
var line  tradeMidLine = na
var label zSlLabel     = na
var label zTpLabel     = na
var label tslLabel     = na

// -- Zone outcome tracking (TP / SL / BE) for the last `zoneStatsN` zones --
var array<string> zoneOutcomes = array.new<string>()
var table zoneTable = table.new(zoneTablePos, 2, 5, border_width=1)

logZoneOutcome(outcome) =>
    array.push(zoneOutcomes, outcome)
    if array.size(zoneOutcomes) > zoneStatsN
        array.shift(zoneOutcomes)

// ============================ ENTRIES ============================
// Requires atrVal[1] to be valid — an entry firing before ATR warms up would
// compute an na stopPrice, leaving the trade permanently unable to exit.
// Requires tradeDir == 0 — external triggers don't know about our trade state,
// so signals mid-trade are simply dropped rather than overwriting the open trade.
canEnter  = tradeDir == 0 and not na(atrVal[1])
takeLong  = longSignal  and canEnter
takeShort = shortSignal and canEnter

if takeLong and takeShort
    takeLong  := false
    takeShort := false

if takeLong
    entryPrice   := open
    atrStopLong  = open - atrVal[1] * atrInitMult
    extStopLong  = slMode == "External Source" ? slExternalSrc[1] : na
    baseStopLong = slMode == "External Source" and not na(extStopLong) ? extStopLong : atrStopLong
    oppLvlLong   = useOppBufferFloor ? oppLevelSrc[1] : na
    stopPrice    := useOppBufferFloor and not na(oppLvlLong) ? math.min(baseStopLong, oppLvlLong) : baseStopLong
    tp1Price     := open + atrVal[1] * tp1R
    tp2Price     := open + atrVal[1] * tp2R
    tradeDir     := 1
    tp1Hit       := false
    tp2Hit       := false
    barsInTrade  := 0

if takeShort
    entryPrice    := open
    atrStopShort  = open + atrVal[1] * atrInitMult
    extStopShort  = slMode == "External Source" ? slExternalSrc[1] : na
    baseStopShort = slMode == "External Source" and not na(extStopShort) ? extStopShort : atrStopShort
    oppLvlShort   = useOppBufferFloor ? oppLevelSrc[1] : na
    stopPrice     := useOppBufferFloor and not na(oppLvlShort) ? math.max(baseStopShort, oppLvlShort) : baseStopShort
    tp1Price      := open - atrVal[1] * tp1R
    tp2Price      := open - atrVal[1] * tp2R
    tradeDir      := -1
    tp1Hit        := false
    tp2Hit        := false
    barsInTrade   := 0

newEntry = takeLong or takeShort

// capture the initial levels before the trail can move them, and before
// entryPrice gets reset to na on close — this is the zone's own memory
if newEntry
    initSL         := stopPrice
    initTP1        := tp1Price
    zoneMid        := math.avg(initSL, initTP1)
    zoneIsLong     := takeLong
    zoneEntryPrice := entryPrice
    initSlPips     := math.ceil(math.abs(entryPrice - initSL)  / pipSize)
    initTpPips     := math.ceil(math.abs(initTP1 - entryPrice) / pipSize)

// ============================ TRADE MANAGEMENT ============================
exitOnWick = exitBasis == "Wick (intrabar)"
evalNow    = exitOnWick or barstate.isconfirmed

isStepped = trailMode == "Stepped (every X bars)"
stepN     = math.max(1, trailBars)

stopHitAlert     = false
tp1HitAlert      = false
tp2HitAlert      = false
timeoutExitAlert = false
exitDir          = 0

if tradeDir != 0
    if barstate.isconfirmed
        barsInTrade += 1

    canTrail = useTrail and (isStepped
         ? (barstate.isconfirmed and barsInTrade >= stepN and barsInTrade % stepN == 0)
         : barsInTrade >= trailBars)

    hiTest = exitOnWick ? high : close
    loTest = exitOnWick ? low  : close

    if evalNow
        if tradeDir == 1
            if canTrail
                stopPrice := math.max(stopPrice, close - atrVal * atrTrailMult)
            if useTP1 and not tp1Hit and hiTest >= tp1Price
                tp1Hit := true
                tp1HitAlert := true
            if useTP2 and not tp2Hit and hiTest >= tp2Price
                tp2Hit := true
                tp2HitAlert := true
            if loTest <= stopPrice
                exitDir      := 1
                exitPrice    := stopPrice
                stopHitAlert := true
        else
            if canTrail
                stopPrice := math.min(stopPrice, close + atrVal * atrTrailMult)
            if useTP1 and not tp1Hit and loTest <= tp1Price
                tp1Hit := true
                tp1HitAlert := true
            if useTP2 and not tp2Hit and loTest <= tp2Price
                tp2Hit := true
                tp2HitAlert := true
            if hiTest >= stopPrice
                exitDir      := -1
                exitPrice    := stopPrice
                stopHitAlert := true

    if enableTradeTimeout and barstate.isconfirmed and not stopHitAlert and barsInTrade >= tradeTimeoutBars
        exitDir          := tradeDir
        exitPrice        := close
        timeoutExitAlert := true

if stopHitAlert or timeoutExitAlert
    tradeDir   := 0
    entryPrice := na
    stopPrice  := na
    tp1Price   := na
    tp2Price   := na

// ============================ TRAILING STOP LABEL ============================
if showLines and tradeDir != 0
    tslPips = math.ceil(math.abs(entryPrice - stopPrice) / pipSize)
    tslTxt  = 'SL  ' + str.tostring(tslPips, '#.#')
    if na(tslLabel)
        tslLabel := label.new(bar_index, stopPrice, tslTxt,
             style=label.style_label_left, color=color(na), textcolor=color.red, size=size.small)
    else
        tslLabel.set_xy(bar_index, stopPrice)
        tslLabel.set_text(tslTxt)
else if not na(tslLabel)
    label.delete(tslLabel)
    tslLabel := na

// ============================ ENTRY ZONE DRAWING ============================
// Uses the INITIAL levels only. Freezes on: TP1 touch (green), or the
// managed trade closing (via trailing stop / initial SL / timeout) —
// red if that close was a real loss vs. entry, gray/BE otherwise.
if showLevels
    if newEntry
        zoneFrozen := false
        zTpHit     := false
        zSlBreach  := false

        tradeBox := box.new(bar_index, math.max(initSL, initTP1), bar_index, math.min(initSL, initTP1),
             bgcolor=zoneColor, border_color=color(na))

        zSlLine      := line.new(bar_index, initSL,  bar_index, initSL,  color=zSlColor,  width=1, style=line.style_dashed)
        zTpLine      := line.new(bar_index, initTP1, bar_index, initTP1, color=zTpColor,  width=1, style=line.style_dashed)
        tradeMidLine := line.new(bar_index, zoneMid, bar_index, zoneMid, color=zMidColor, width=1, style=line.style_dotted)

        if showPipLabels
            zSlLabel := label.new(bar_index, initSL,  text='SL  '  + str.tostring(initSlPips, '#.#'),
                 style=label.style_label_left, color=color.new(#ddb06e, 80), textcolor=color.new(zSlColor, 0), size=size.small)
            zTpLabel := label.new(bar_index, initTP1, text='TP1  ' + str.tostring(initTpPips, '#.#'),
                 style=label.style_label_left, color=color.new(#ddb06e, 80), textcolor=color.new(zTpColor, 0), size=size.small)

    else if not zoneFrozen and not na(zSlLine)
        zSlLine.set_x2(bar_index)
        zTpLine.set_x2(bar_index)
        tradeMidLine.set_x2(bar_index)
        tradeBox.set_right(bar_index)
        if showPipLabels and not na(zSlLabel)
            zSlLabel.set_x(bar_index)
            zTpLabel.set_x(bar_index)

// Outcome resolution — driven by REAL trade P&L, not a literal initSL touch.
if showLevels and not zoneFrozen and not na(initSL)
    tpTouched = zoneIsLong ? high >= initTP1 : low <= initTP1

    if tpTouched
        zTpHit     := true
        zoneFrozen := true
        tradeBox.set_bgcolor(zoneTpColor)
        logZoneOutcome("TP")
    else if stopHitAlert or timeoutExitAlert
        zoneFrozen := true
        isLoss = zoneIsLong ? exitPrice < zoneEntryPrice : exitPrice > zoneEntryPrice
        if isLoss
            zSlBreach := true
            tradeBox.set_bgcolor(slBreachColor)
            logZoneOutcome("SL")
        else
            tradeBox.set_bgcolor(zoneColor)
            logZoneOutcome("BE")

// ============================ ZONE STATS TABLE RENDER ============================
if showZoneTable and barstate.islast
    n = array.size(zoneOutcomes)
    tpCount = 0
    slCount = 0
    beCount = 0
    if n > 0
        for i = 0 to n - 1
            o = array.get(zoneOutcomes, i)
            if o == "TP"
                tpCount += 1
            else if o == "SL"
                slCount += 1
            else
                beCount += 1

    tpPct   = n > 0 ? 100.0 * tpCount / n : 0.0
    slPct   = n > 0 ? 100.0 * slCount / n : 0.0
    bePct   = n > 0 ? 100.0 * beCount / n : 0.0
    hitRate = (tpCount + slCount) > 0 ? 100.0 * tpCount / (tpCount + slCount) : na

    table.cell(zoneTable, 0, 0, "Zones (" + str.tostring(n) + "/" + str.tostring(zoneStatsN) + ")",
         text_color=color.white, bgcolor=color.new(color.black, 15), text_size=size.small, text_halign=text.align_left)
    table.cell(zoneTable, 1, 0, "", bgcolor=color.new(color.black, 15))

    table.cell(zoneTable, 0, 1, "TP", text_color=color.white, bgcolor=color.new(zoneTpColor, 40), text_size=size.small, text_halign=text.align_left)
    table.cell(zoneTable, 1, 1, str.tostring(tpCount) + "  (" + str.tostring(tpPct, "#.0") + "%)",
         text_color=color.white, bgcolor=color.new(zoneTpColor, 65), text_size=size.small)

    table.cell(zoneTable, 0, 2, "SL", text_color=color.white, bgcolor=color.new(slBreachColor, 40), text_size=size.small, text_halign=text.align_left)
    table.cell(zoneTable, 1, 2, str.tostring(slCount) + "  (" + str.tostring(slPct, "#.0") + "%)",
         text_color=color.white, bgcolor=color.new(slBreachColor, 65), text_size=size.small)

    table.cell(zoneTable, 0, 3, "BE", text_color=color.white, bgcolor=color.new(zoneColor, 40), text_size=size.small, text_halign=text.align_left)
    table.cell(zoneTable, 1, 3, str.tostring(beCount) + "  (" + str.tostring(bePct, "#.0") + "%)",
         text_color=color.white, bgcolor=color.new(zoneColor, 65), text_size=size.small)

    table.cell(zoneTable, 0, 4, "TP Rate*", text_color=color.white, bgcolor=color.new(color.black, 15), text_size=size.small, text_halign=text.align_left)
    table.cell(zoneTable, 1, 4, na(hitRate) ? "—" : str.tostring(hitRate, "#.0") + "%",
         text_color=color.white, bgcolor=color.new(color.black, 15), text_size=size.small)

// ============================ AUDIT PLOTS ============================
plot(entryPrice,     "Entry",       display=display.data_window)
plot(stopPrice,      "StopLoss",    display=display.data_window)
plot(tp1Price,       "TP1",         display=display.data_window)
plot(tp2Price,       "TP2",         display=display.data_window)
plot(exitPrice,      "ExitPrice",   display=display.data_window)
plot(initSL,         "InitSL",      display=display.data_window)
plot(initTP1,        "InitTP1",     display=display.data_window)
plot(initSlPips,     "InitSLPips",  display=display.data_window)
plot(initTpPips,     "InitTPPips",  display=display.data_window)
plot(tradeDir,       "TradeDir",    display=display.data_window)
plot(barsInTrade,    "BarsInTrade", display=display.data_window)

// ============================ VISUALS ============================
plot(showLines and tradeDir != 0 ? stopPrice : na, "SL Line",  color=color.new(color.red, 0),   style=plot.style_linebr, linewidth=2)
plot(showLines and tradeDir != 0 and not tp1Hit ? tp1Price : na, "TP1 Line", color=color.new(color.green, 0), style=plot.style_linebr, linewidth=1)
plot(showLines and tradeDir != 0 and not tp2Hit ? tp2Price : na, "TP2 Line", color=color.new(color.lime, 0),  style=plot.style_linebr, linewidth=1)

if showLabels and takeLong
    label.new(bar_index, low - atrVal * 0.5, "BUY", style=label.style_label_up, color=color.green, textcolor=color.white, size=size.small)

if showLabels and takeShort
    label.new(bar_index, high + atrVal * 0.5, "SELL", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)

if showLabels and stopHitAlert
    label.new(bar_index, exitDir == 1 ? low : high, "SL",
         style = exitDir == 1 ? label.style_label_up : label.style_label_down,
         color=color.new(color.red, 20), textcolor=color.white, size=size.tiny)

if showLabels and timeoutExitAlert
    label.new(bar_index, exitDir == 1 ? low : high, "TIME",
         style = exitDir == 1 ? label.style_label_up : label.style_label_down,
         color=color.new(#787b86, 20), textcolor=color.white, size=size.tiny)

if showLabels and tp1HitAlert
    label.new(bar_index, tradeDir == 1 ? high : low, "TP1",
         style = tradeDir == 1 ? label.style_label_down : label.style_label_up,
         color=color.new(#00e676, 20), textcolor=color.black, size=size.tiny)

if showLabels and tp2HitAlert
    label.new(bar_index, tradeDir == 1 ? high : low, "TP2",
         style = tradeDir == 1 ? label.style_label_down : label.style_label_up,
         color=color.new(#00e676, 20), textcolor=color.black, size=size.tiny)

// ============================ ALERTS ============================
alertcondition(takeLong, title="Template Long Entry",
     message='{\n  "traderIdKey": "replace with your key",\n  "tradeSide": "buy",\n  "symbol": "{{ticker}}",\n  "volumeType": "fixed",\n  "volume": 1,\n  "relativeTakeProfit": {{plot("InitTPPips")}},\n  "relativeStopLoss": {{plot("InitSLPips")}},\n  "trailingStopLoss": false,\n  "closeExisting": false,\n  "strategyId": "replace with your strategy-name (slug)"\n}')

alertcondition(takeShort, title="Template Short Entry",
     message='{\n  "traderIdKey": "replace with your key",\n  "tradeSide": "sell",\n  "symbol": "{{ticker}}",\n  "volumeType": "fixed",\n  "volume": 1,\n  "relativeTakeProfit": {{plot("InitTPPips")}},\n  "relativeStopLoss": {{plot("InitSLPips")}},\n  "trailingStopLoss": false,\n  "closeExisting": false,\n  "strategyId": "replace with your strategy-name (slug)"\n}')

alertcondition(stopHitAlert, title="Template Stop Loss Hit",
     message='{"ticker":"{{ticker}}","action":"exit_sl","exit":{{plot("ExitPrice")}}}')

alertcondition(timeoutExitAlert, title="Template Trade Timeout Exit",
     message='{"ticker":"{{ticker}}","action":"exit_timeout","exit":{{plot("ExitPrice")}}}')

alertcondition(tp1HitAlert, title="Template TP1 Hit",
     message='{"ticker":"{{ticker}}","action":"partial_tp1","level":{{plot("TP1")}}}')

alertcondition(tp2HitAlert, title="Template TP2 Hit",
     message='{"ticker":"{{ticker}}","action":"partial_tp2","level":{{plot("TP2")}}}')
````
