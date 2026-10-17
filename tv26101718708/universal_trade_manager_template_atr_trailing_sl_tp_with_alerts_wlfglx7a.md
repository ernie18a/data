# Universal Trade Manager Template ATR Trailing SL TP with Alerts

- url: https://www.tradingview.com/script/wLfgLX7a-Universal-Trade-Manager-Template-ATR-Trailing-SL-TP-with-Alerts/
- type: indicator
- pine_id: PUB;0931c2700eab4b7b98a173ff073c5d76
- version: 2.0

## Description

A modular, signal-agnostic trade management engine. This template does not generate trade entries itself. Instead,[b] it takes a Long/Short trigger from any compatible TradingView indicator and handles everything downstream[/b] — initial stop-loss placement, ATR-based trailing, TP1/TP2 tracking, trade timeouts, and webhook-ready JSON alerts for automated execution.

It is designed as a reusable management layer: connect the same tested trade-management logic to different signal-generating indicators without duplicating the underlying code.

[b]HOW IT WORKS[/b]

Connect any signal source Point the Long Trigger and Short Trigger inputs to the corresponding alert conditions from your signal indicator.
Controlled entry timing By default, the template applies a one-bar offset: a signal confirmed on bar N triggers the entry on the open of bar N+1. This follows standard non-repainting execution. The offset can be disabled when the connected indicator generates its trigger after bar close.
Flexible initial stop-loss Set the initial SL using an ATR multiple, or pull it from an external structural level such as a swing high/low or FVG edge. An optional opposite-level input can widen the stop to a structural floor/ceiling, but will never tighten it.

A third Initial SL Mode, Last Pivot High/Low, is also available: instead of only ATR-based or external-source stops, the stop can be set to the highest high (shorts) / lowest low (longs) over a lookback window. At 1x multiplier it sits exactly on that level, with the multiplier available to tighten or widen from there. Falls back to the ATR stop if the lookback window isn't fully available yet.

Two trailing modes Choose between:
Continuous: re-evaluates the trailing stop on every eligible bar after the configured delay.
Stepped: updates only at fixed bar intervals, useful for reducing SL-update noise in choppy markets. Stepped trailing now has its own configurable alert, with a message ready to use with platforms that can consume webhook signals to execute orders on your broker or prop account.

[b]VISUALS[/b]

Entry Zone Displays the initial SL/TP1 range at the moment of entry. The zone remains frozen even when the trailing stop subsequently moves.
Live trade status Entry zones are color-coded:
[list]
[*]Gray — trade still open or closed BE
[*]Green — TP1 reached
[*]Red — initial SL breached
[/list]
Zone Stats Table Tracks the results of the most recent entry zones, including TP, SL and neutral/BE outcomes, together with the hit rate. This provides a quick view of how the connected signal is performing without relying on the Strategy Tester.
Live management levels Separate trailing SL, TP1 and TP2 lines are plotted on the chart, with pip-distance labels for both the entry zone and current trailing stop, plus a display label for the trailing stop itself.

[b]ALERTS & AUTOMATION[/b]

The template provides seven alert conditions:

[list=1]
[*]Long Entry
[*]Short Entry
[*]Stop Loss Update
[*]Stop Loss Hit
[*]TP1 Hit
[*]TP2 Hit
[*]Timeout Exit
[/list]
Each alert includes a pre-built JSON payload with TradingView placeholders, capturing the relevant values at the exact moment the alert fires.

The payload is designed as a starting point for integration with platforms which can consume webhook signals to execute orders on your broker or prop account. Fields such as traderIdKey, tradeSide, relativeTakeProfit, and relativeStopLoss can be adapted to match the configuration and credentials required by your chosen platform.

This allows the trade-management layer to send automated execution instructions directly from TradingView to your broker or prop firm account, without any manual order entry.

[b]NON-REPAINTING DESIGN[/b]

All internal trade-management logic uses confirmed-bar data and proper offsetting.

There is no lookahead in the entry/exit logic, and the alert payload captures values when the event actually occurs rather than relying on values that may change later as the chart updates.

[b]IMPORTANT[/b]

This is a trade-management layer, not a signal generator.

It will not produce entries or plot trade-management levels until it is connected to a compatible indicator source through input.source().

For educational and informational purposes only. This template is not financial advice. Test thoroughly in TradingView and on a demo account before connecting it to any live automated execution system.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © signalsync-to

//@version=6
indicator("SL TP Trade Manager Template [signalsync-to]", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// ============================ SIGNAL SOURCE ============================
grpSig = "Trigger Source (from external indicator)"
longTriggerSrc  = input.source(close, "Long Trigger Source", group=grpSig,
     tooltip="Point at an alert from another indicator for buy or long trigger")
shortTriggerSrc = input.source(close, "Short Trigger Source", group=grpSig,
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

// ============================ PYRAMIDING ============================
grpP = "Pyramiding"
allowPyramid   = input.bool(false, "Allow Pyramiding (extra entries while in a trade)", group=grpP,
     tooltip="OFF (default): identical to non-pyramiding behavior — one trade at a time, additional same-direction triggers while in a trade are ignored.\nON: additional same-direction triggers, up to the max below, are treated as pyramid adds. The Initial SL stays anchored to the FIRST entry (never re-widened/tightened by an add) and keeps trailing normally from there. TP1/TP2 are recomputed fresh from EACH add's own entry price — the most recent add's target replaces the prior one, it does not stack on top of it. Opposite-direction triggers while in a trade are still ignored either way.")
maxPyramidAdds = input.int(2, "Max Pyramid Adds (beyond the first entry)", minval=1, maxval=10, group=grpP,
     tooltip="How many ADDITIONAL entries are allowed on top of the first. Default 2 = up to 3 total entries (1 initial + 2 adds).")

// ============================ VOLATILITY STOP ============================
grpS = "Volatility Stop"
atrLen       = input.int(14, "ATR Length", group=grpS)
slMode       = input.string("ATR Multiple", "Initial SL Mode", options=["ATR Multiple", "Last Pivot High/Low", "External Source"], group=grpS,
     tooltip="ATR Multiple: stop = entry -/+ ATR * multiplier.\nExternal Source: pulls the stop PRICE directly from another indicator's plot (e.g. a structural level). Falls back to the ATR stop on any bar the source is na.\nLast Pivot High/Low: stop sits at the highest high (shorts) / lowest low (longs) over the last N bars ending at the signal bar, scaled by the Pivot SL Multiplier — 1.0 = sits exactly at that level. Falls back to the ATR stop during chart warmup if the lookback window isn't full yet.")
atrInitMult  = input.float(1.5, "Initial Stop ATR Multiplier", step=0.1, group=grpS,
     tooltip="Only used when Initial SL Mode = ATR Multiple")
pivotLookback = input.int(10, "Pivot Lookback (bars)", minval=1, group=grpS,
     tooltip="Only used when Initial SL Mode = Last Pivot High/Low. Window of N bars ending at the signal bar (same [1]-offset convention as the ATR stop) searched for the highest high (shorts) / lowest low (longs).")
pivotMult = input.float(1.0, "Pivot SL Multiplier", step=0.1, minval=0.0, group=grpS,
     tooltip="Only used when Initial SL Mode = Last Pivot High/Low. Scales the raw distance from entry to the lookback high/low. 1.0 = stop sits exactly at that level. <1.0 pulls the stop in closer to entry; >1.0 pushes it further beyond the level.")
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

// ============================ FLATTEN ON TARGET ============================
grpF = "Flatten on Target (Full Close)"
flattenAtTP1 = input.bool(false, "Flatten Trade at TP1", group=grpF,
     tooltip="OFF (default): reaching TP1 only sets the tracking flag / fires the partial TP1 alert (if 'Track / Alert TP1' above is on) — the trade stays OPEN and the trailing stop keeps running toward TP2, timeout, or SL.\nON: the instant price touches TP1, the trade is fully closed at the TP1 price — same reset as a stop-loss exit (state cleared, TSL tag handled the same way as any other exit). Fires its own 'Template Flatten at TP1' alert. Works independently of 'Track / Alert TP1' — that toggle only controls the partial notification, not this full close.")
flattenAtTP2 = input.bool(false, "Flatten Trade at TP2", group=grpF,
     tooltip="OFF (default): TP2 only does whatever 'Alert at TP2' above is set to (tracked/alerted, or reference-only) — it never by itself closes the trade.\nON: the instant price touches TP2, the trade is fully closed at the TP2 price. Fires its own 'Template Flatten at TP2' alert. Works even if 'Alert at TP2' above is OFF — TP2 is always computed at entry regardless of that toggle, so this check runs every bar either way.\nPriority if both flatten toggles are on and a single bar blows through both levels: TP1 flatten wins (closes at the nearer target first).")

// ============================ EXIT DETECTION ============================
grpE = "Exit Detection"
exitBasis = input.string("Wick (intrabar)", "SL / TP Detection", options=["Wick (intrabar)", "Close (confirmed)"], group=grpE,
     tooltip="Wick = fires the moment price touches the level (use 'Once Per Bar' alerts).\nClose = only evaluates on bar close (use 'Once Per Bar Close').")

// ============================ SAFETY / INVALIDATION ============================
grpSafe = "Safety / Invalidation"
enableTradeTimeout = input.bool(false, "Auto-Flatten Stale Trade", group=grpSafe,
     tooltip="If a trade never hits its stop or trailing stop within N bars, force-close it at the current close and alert.")
tradeTimeoutBars = input.int(20, "Trade Timeout (bars)", minval=1, group=grpSafe)

// ============================ ENTRY ZONE (initial SL / TP1) ============================
grpZ = "Entry Zone (initial SL / TP1)"
showLevels    = input.bool(true, "Show Entry Zone", group=grpZ,
     tooltip="Draws a zone box for EVERY entry (the first, and each pyramid add). Each add's zone spans from the current governing stop to that add's own freshly-computed TP1, and freezes once superseded by the next add. The trailing stop is plotted separately and is unaffected by this.")
showPipLabels = input.bool(true, "Show Pip Labels", group=grpZ)
pipFactor     = input.float(10, "Points per Pip", minval=0.0001, step=1, group=grpZ,
     tooltip="pipSize = syminfo.mintick * this.\n10 = 5-digit FX, and NAS100 CFD at 0.1 tick.\n4 = NQ futures at 0.25 tick.\n1 = raw ticks.")
zoneColor      = input.color(color.new(#787b86, 85), "Zone Fill",  group=grpZ, inline="ZF",
     tooltip="In process (still open), superseded by a later pyramid add, or trade closed before TP1 at breakeven/better vs. entry (neutral / BE).")
zoneTpColor    = input.color(color.new(#00e676, 85), "→ TP",       group=grpZ, inline="ZF",
     tooltip="TP1 price level was touched on the CURRENT (latest) zone.")
slBreachColor  = input.color(color.new(#f23645, 85), "→ SL",       group=grpZ, inline="ZF",
     tooltip="Trade closed (trailing stop, initial SL, or timeout) at a real loss vs. entry, before touching TP1.")
zSlColor       = input.color(#f23645, "SL Line",  group=grpZ, inline="ZL")
zTpColor       = input.color(#00e676, "TP1 Line", group=grpZ, inline="ZL")
zMidColor      = input.color(#787b86, "Mid Line", group=grpZ, inline="ZL")
maxZonesDrawn  = input.int(50, "Max Zones to Draw (visual objects)", minval=5, maxval=120, group=grpZ,
     tooltip="Bounds the box/line/label objects kept on chart for past zones — oldest removed first — so drawings stay under Pine's 500-object caps. With pyramiding on, each aggregate trade can draw up to (1 + Max Pyramid Adds) zones, so this budget covers fewer aggregate trades than in non-pyramiding use. Independent of 'Zones to Track' below, which only tallies TP/SL/BE stats as text and has no drawing-object cost.")

// ============================ ZONE STATS TABLE ============================
grpST = "Zone Stats Table"
showZoneTable = input.bool(true, "Show Zone Stats Table", group=grpST,
     tooltip="Tallies the outcome of each AGGREGATE trade (not each pyramid leg) by REAL trade P&L: TP1 touched, closed at a loss before TP1 (SL), or closed flat/breakeven-or-better before TP1 (BE). Requires 'Show Entry Zone' enabled above to populate.")
zoneTablePos  = input.string(position.top_right, "Table Position", group=grpST,
     options=[position.top_right, position.top_left, position.bottom_right, position.bottom_left])
zoneStatsN    = input.int(100, "Zones to Track", minval=1, maxval=500, group=grpST)

// ============================ VISUALS ============================
grpV = "Visuals"
showLabels    = input.bool(true, "Show Entry / Exit Labels", group=grpV)
showLines     = input.bool(true, "Show Trailing SL / TP Plots", group=grpV)
maxSignalLabels = input.int(150, "Max Signal Labels to Keep", minval=10, maxval=300, group=grpV,
     tooltip="Bounds BUY/SELL/ADD+/SL/TP1/TP2/TIME markers kept on chart — oldest removed first. Shares the same 500-label budget as the Entry Zone pip labels and the trailing stop label, so keeping this bounded protects those from being silently evicted.")
keepTslHistory  = input.bool(true, "Keep Historical TSL Labels", group=grpV,
     tooltip="When a trade closes, freezes the trailing-stop tag at its final position instead of deleting it, so you can see where each past trade's trail ended up. Turn off to delete the tag on close (original behavior).")
maxTslLabels    = input.int(50, "Max TSL History Labels", minval=5, maxval=200, group=grpV,
     tooltip="Bounds how many frozen trailing-stop tags are kept on chart — oldest removed first. Only applies when 'Keep Historical TSL Labels' is on.")

// ============================ CORE CALCS ============================
atrVal  = ta.atr(atrLen)
pipSize = syminfo.mintick * pipFactor

// Rolling highest high / lowest low over the lookback window — feeds the
// "Last Pivot High/Low" SL mode below. Computed every bar like atrVal;
// consumed at entry via [1], mirroring atrVal[1] (window ends at the signal bar).
lookbackHighVal = ta.highest(high, pivotLookback)
lookbackLowVal  = ta.lowest(low, pivotLookback)

// Signed pip distance of a trailing stop from entry.
// Positive = stop still on the RISK side of entry (a loss if hit).
// Negative = stop has trailed PAST entry onto the profit-lock side (a gain if hit).
// Long:  risk side = stop below entry.  Short: risk side = stop above entry.
// Magnitude is still rounded UP via math.ceil() (never understate the distance),
// the sign is applied on top of that.
signedPips(isLong, entry, stopP) =>
    mag = math.ceil(math.abs(entry - stopP) / pipSize)
    isLong ? (stopP < entry ? mag : -mag) : (stopP > entry ? mag : -mag)

// Builds one entry-zone's drawing objects (box + SL/TP/mid lines + optional pip labels)
// starting at bar zBar. Used for the very first entry AND for every pyramid add — each
// call produces an independent set of objects, tracked/pruned via the same bounded arrays.
drawZone(zBar, slP, tpP, slPips, tpPips, tag) =>
    top = math.max(slP, tpP)
    bot = math.min(slP, tpP)
    mid = math.avg(slP, tpP)
    b    = box.new(zBar, top, zBar, bot, bgcolor=zoneColor, border_color=color(na))
    lSl  = line.new(zBar, slP, zBar, slP, color=zSlColor,  width=1, style=line.style_dashed)
    lTp  = line.new(zBar, tpP, zBar, tpP, color=zTpColor,  width=1, style=line.style_dashed)
    lMid = line.new(zBar, mid, zBar, mid, color=zMidColor, width=1, style=line.style_dotted)
    label lblSl = na
    label lblTp = na
    if showPipLabels
        lblSl := label.new(zBar, slP, text='SL' + tag + '  '  + str.tostring(slPips, '#.#'),
             style=label.style_label_left, color=color.new(#ddb06e, 80), textcolor=color.new(zSlColor, 0), size=size.small)
        lblTp := label.new(zBar, tpP, text='TP1' + tag + '  ' + str.tostring(tpPips, '#.#'),
             style=label.style_label_left, color=color.new(#ddb06e, 80), textcolor=color.new(zTpColor, 0), size=size.small)
    [b, lSl, lTp, lMid, lblSl, lblTp]

// ============================ STATE ============================
var int   tradeDir     = 0
var float entryPrice   = na
var float stopPrice    = na
var float tp1Price     = na
var float tp2Price     = na
var float exitPrice    = na
var bool  tp1Hit       = false
var bool  tp2Hit       = false
var int   barsInTrade  = 0
var int   pyramidCount = 0     // number of pyramid ADDS taken on the current trade (0 after a fresh entry)
var float trailStopPips = na   // signed pips distance of the trail stop at the moment it last moved — feeds the trail-update alert. Positive = risk side, negative = past entry (profit locked).

var float initSL        = na   // SL edge of the CURRENT (latest) zone
var float initTP1       = na   // TP edge of the CURRENT (latest) zone
var float zoneMid       = na
var float initSlPips    = na
var float initTpPips    = na
var float zoneEntryPrice = na   // trade-1's entry, survives the entryPrice reset on close — reference point for the aggregate trade's win/loss
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

// -- Zone outcome tracking (TP / SL / BE) for the last `zoneStatsN` AGGREGATE trades --
var array<string> zoneOutcomes = array.new<string>()
var table zoneTable = table.new(zoneTablePos, 2, 5, border_width=1)

// -- Bounded visual-object tracking so drawings stay under Pine's 500-object caps --
var array<box>   zoneBoxArr     = array.new<box>()
var array<line>  zoneSlLineArr  = array.new<line>()
var array<line>  zoneTpLineArr  = array.new<line>()
var array<line>  zoneMidLineArr = array.new<line>()
var array<label> zoneSlLblArr   = array.new<label>()
var array<label> zoneTpLblArr   = array.new<label>()
var array<label> signalLblArr   = array.new<label>()
var array<label> tslHistoryArr  = array.new<label>()   // frozen trailing-stop tags from closed trades

logZoneOutcome(outcome) =>
    array.push(zoneOutcomes, outcome)
    if array.size(zoneOutcomes) > zoneStatsN
        array.shift(zoneOutcomes)

pruneZoneDrawings() =>
    if array.size(zoneBoxArr) > maxZonesDrawn
        box.delete(array.shift(zoneBoxArr))
        line.delete(array.shift(zoneSlLineArr))
        line.delete(array.shift(zoneTpLineArr))
        line.delete(array.shift(zoneMidLineArr))
        oldSl = array.shift(zoneSlLblArr)
        oldTp = array.shift(zoneTpLblArr)
        if not na(oldSl)
            label.delete(oldSl)
        if not na(oldTp)
            label.delete(oldTp)

addSignalLabel(lbl) =>
    array.push(signalLblArr, lbl)
    if array.size(signalLblArr) > maxSignalLabels
        label.delete(array.shift(signalLblArr))

pruneTslHistory() =>
    if array.size(tslHistoryArr) > maxTslLabels
        label.delete(array.shift(tslHistoryArr))

// ============================ ENTRIES ============================
// A trade can be entered fresh (tradeDir == 0), or — if pyramiding is on and the
// direction matches the open trade and we're under the add cap — added to.
canLongEntry  = not na(atrVal[1]) and (tradeDir == 0 or (allowPyramid and tradeDir == 1  and pyramidCount < maxPyramidAdds))
canShortEntry = not na(atrVal[1]) and (tradeDir == 0 or (allowPyramid and tradeDir == -1 and pyramidCount < maxPyramidAdds))

takeLong  = longSignal  and canLongEntry
takeShort = shortSignal and canShortEntry

if takeLong and takeShort
    takeLong  := false
    takeShort := false

isFreshLong  = takeLong  and tradeDir == 0
isFreshShort = takeShort and tradeDir == 0
isAddLong    = takeLong  and tradeDir == 1
isAddShort   = takeShort and tradeDir == -1

// Pip fields for a pyramid ADD's own alert payload AND its own drawn zone —
// distance from THIS add's own entry price to the (shared, trade-1-anchored) SL,
// and to this add's own freshly-computed TP. Plain (non-var) floats so they read
// na on every bar except the one they fire on.
float addEntryPrice = na
float addSlPips     = na
float addTpPips     = na

if takeLong
    if isFreshLong
        entryPrice   := open
        atrStopLong       = open - atrVal[1] * atrInitMult
        extStopLong       = slMode == "External Source" ? slExternalSrc[1] : na
        pivotStopLong     = slMode == "Last Pivot High/Low" ? open - math.abs(open - lookbackLowVal[1]) * pivotMult : na
        baseStopLong = switch slMode
            "External Source"     => not na(extStopLong)   ? extStopLong   : atrStopLong
            "Last Pivot High/Low" => not na(pivotStopLong)  ? pivotStopLong : atrStopLong
            => atrStopLong
        oppLvlLong   = useOppBufferFloor ? oppLevelSrc[1] : na
        stopPrice    := useOppBufferFloor and not na(oppLvlLong) ? math.min(baseStopLong, oppLvlLong) : baseStopLong
        tp1Price     := open + atrVal[1] * tp1R
        tp2Price     := open + atrVal[1] * tp2R
        tradeDir     := 1
        tp1Hit       := false
        tp2Hit       := false
        barsInTrade  := 0
        pyramidCount := 0
    else if isAddLong
        // TP is recomputed fresh from THIS add's own entry — it replaces the
        // previous target, it does not stack on top of it. SL is untouched.
        tp1Price      := open + atrVal[1] * tp1R
        tp2Price      := open + atrVal[1] * tp2R
        pyramidCount  += 1
        addEntryPrice := open
        addSlPips     := math.ceil(math.abs(open - stopPrice) / pipSize)
        addTpPips     := math.ceil(math.abs(tp1Price - open) / pipSize)

if takeShort
    if isFreshShort
        entryPrice    := open
        atrStopShort      = open + atrVal[1] * atrInitMult
        extStopShort      = slMode == "External Source" ? slExternalSrc[1] : na
        pivotStopShort    = slMode == "Last Pivot High/Low" ? open + math.abs(lookbackHighVal[1] - open) * pivotMult : na
        baseStopShort = switch slMode
            "External Source"     => not na(extStopShort)  ? extStopShort   : atrStopShort
            "Last Pivot High/Low" => not na(pivotStopShort) ? pivotStopShort : atrStopShort
            => atrStopShort
        oppLvlShort   = useOppBufferFloor ? oppLevelSrc[1] : na
        stopPrice     := useOppBufferFloor and not na(oppLvlShort) ? math.max(baseStopShort, oppLvlShort) : baseStopShort
        tp1Price      := open - atrVal[1] * tp1R
        tp2Price      := open - atrVal[1] * tp2R
        tradeDir      := -1
        tp1Hit        := false
        tp2Hit        := false
        barsInTrade   := 0
        pyramidCount  := 0
    else if isAddShort
        tp1Price      := open - atrVal[1] * tp1R
        tp2Price      := open - atrVal[1] * tp2R
        pyramidCount  += 1
        addEntryPrice := open
        addSlPips     := math.ceil(math.abs(stopPrice - open) / pipSize)
        addTpPips     := math.ceil(math.abs(open - tp1Price) / pipSize)

newEntry   = isFreshLong or isFreshShort
isAddEntry = isAddLong or isAddShort

if newEntry
    initSL         := stopPrice
    initTP1        := tp1Price
    zoneMid        := math.avg(initSL, initTP1)
    zoneIsLong     := takeLong
    zoneEntryPrice := entryPrice
    initSlPips     := math.ceil(math.abs(entryPrice - initSL)  / pipSize)
    initTpPips     := math.ceil(math.abs(initTP1 - entryPrice) / pipSize)
else if isAddEntry
    initSL      := stopPrice   // current governing stop (unchanged by adds unless already trailed)
    initTP1     := tp1Price    // this add's fresh target
    zoneMid     := math.avg(initSL, initTP1)
    initSlPips  := addSlPips
    initTpPips  := addTpPips

// ============================ TRADE MANAGEMENT ============================
exitOnWick = exitBasis == "Wick (intrabar)"
evalNow    = exitOnWick or barstate.isconfirmed

isStepped = trailMode == "Stepped (every X bars)"
stepN     = math.max(1, trailBars)

stopHitAlert      = false
tp1HitAlert       = false
tp2HitAlert       = false
timeoutExitAlert  = false
trailUpdatedAlert = false
tp1FlattenAlert   = false
tp2FlattenAlert   = false
exitDir           = 0

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
                newTrailStop = math.max(stopPrice, close - atrVal * atrTrailMult)
                if newTrailStop > stopPrice
                    trailUpdatedAlert := true
                    trailStopPips     := signedPips(true, entryPrice, newTrailStop)
                stopPrice := newTrailStop
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
            else if flattenAtTP1 and hiTest >= tp1Price
                exitDir         := 1
                exitPrice       := tp1Price
                tp1FlattenAlert := true
            else if flattenAtTP2 and hiTest >= tp2Price
                exitDir         := 1
                exitPrice       := tp2Price
                tp2FlattenAlert := true
        else
            if canTrail
                newTrailStop = math.min(stopPrice, close + atrVal * atrTrailMult)
                if newTrailStop < stopPrice
                    trailUpdatedAlert := true
                    trailStopPips     := signedPips(false, entryPrice, newTrailStop)
                stopPrice := newTrailStop
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
            else if flattenAtTP1 and loTest <= tp1Price
                exitDir         := -1
                exitPrice       := tp1Price
                tp1FlattenAlert := true
            else if flattenAtTP2 and loTest <= tp2Price
                exitDir         := -1
                exitPrice       := tp2Price
                tp2FlattenAlert := true

    if enableTradeTimeout and barstate.isconfirmed and not stopHitAlert and not tp1FlattenAlert and not tp2FlattenAlert and barsInTrade >= tradeTimeoutBars
        exitDir          := tradeDir
        exitPrice        := close
        timeoutExitAlert := true

if stopHitAlert or timeoutExitAlert or tp1FlattenAlert or tp2FlattenAlert
    // Freeze the trailing stop tag at its final position instead of deleting it,
    // so completed trades leave a historical marker of where their trail ended.
    if not na(tslLabel)
        if keepTslHistory
            finalTslPips = signedPips(tradeDir == 1, entryPrice, stopPrice)
            tslLabel.set_xy(bar_index, stopPrice)
            tslLabel.set_text('TSL ' + str.tostring(finalTslPips, '#.#'))
            array.push(tslHistoryArr, tslLabel)
            pruneTslHistory()
        else
            label.delete(tslLabel)
        tslLabel := na
    tradeDir     := 0
    entryPrice   := na
    stopPrice    := na
    tp1Price     := na
    tp2Price     := na
    barsInTrade  := 0
    pyramidCount := 0

// ============================ TRAILING STOP LABEL ============================
if showLines and tradeDir != 0
    tslPips = signedPips(tradeDir == 1, entryPrice, stopPrice)
    tslTxt  = 'TSL ' + str.tostring(tslPips, '#.#')
    if na(tslLabel)
        tslLabel := label.new(bar_index, stopPrice, tslTxt,
             style=label.style_label_left, color=color(na), textcolor=color.red, size=size.small)
    else
        tslLabel.set_xy(bar_index, stopPrice)
        tslLabel.set_text(tslTxt)
else if not showLines and not na(tslLabel)
    label.delete(tslLabel)
    tslLabel := na

// ============================ ENTRY ZONE DRAWING ============================
if showLevels
    if newEntry
        [b, lSl, lTp, lMid, lblSl, lblTp] = drawZone(bar_index, initSL, initTP1, initSlPips, initTpPips, "")
        tradeBox     := b
        zSlLine      := lSl
        zTpLine      := lTp
        tradeMidLine := lMid
        zSlLabel     := lblSl
        zTpLabel     := lblTp
        zoneFrozen   := false
        zTpHit       := false
        zSlBreach    := false

        array.push(zoneBoxArr, tradeBox)
        array.push(zoneSlLineArr, zSlLine)
        array.push(zoneTpLineArr, zTpLine)
        array.push(zoneMidLineArr, tradeMidLine)
        array.push(zoneSlLblArr, zSlLabel)
        array.push(zoneTpLblArr, zTpLabel)
        pruneZoneDrawings()

    else if isAddEntry
        // Freeze the previous zone right where it stands — it was never hit or
        // breached, it was simply superseded by this add's own new zone.
        if not na(zSlLine)
            zSlLine.set_x2(bar_index)
            zTpLine.set_x2(bar_index)
            tradeMidLine.set_x2(bar_index)
            tradeBox.set_right(bar_index)
            if showPipLabels and not na(zSlLabel)
                zSlLabel.set_x(bar_index)
                zTpLabel.set_x(bar_index)

        entryTag = " #" + str.tostring(pyramidCount + 1)
        [b, lSl, lTp, lMid, lblSl, lblTp] = drawZone(bar_index, initSL, initTP1, initSlPips, initTpPips, entryTag)
        tradeBox     := b
        zSlLine      := lSl
        zTpLine      := lTp
        tradeMidLine := lMid
        zSlLabel     := lblSl
        zTpLabel     := lblTp
        zTpHit       := false
        zSlBreach    := false
        // zoneFrozen stays false — this new zone is now the live, tracked one

        array.push(zoneBoxArr, tradeBox)
        array.push(zoneSlLineArr, zSlLine)
        array.push(zoneTpLineArr, zTpLine)
        array.push(zoneMidLineArr, tradeMidLine)
        array.push(zoneSlLblArr, zSlLabel)
        array.push(zoneTpLblArr, zTpLabel)
        pruneZoneDrawings()

    else if not zoneFrozen and not na(zSlLine)
        zSlLine.set_x2(bar_index)
        zTpLine.set_x2(bar_index)
        tradeMidLine.set_x2(bar_index)
        tradeBox.set_right(bar_index)
        if showPipLabels and not na(zSlLabel)
            zSlLabel.set_x(bar_index)
            zTpLabel.set_x(bar_index)

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
plot(trailStopPips,  "TrailStopPips", display=display.data_window)
plot(tradeDir,       "TradeDir",    display=display.data_window)
plot(barsInTrade,    "BarsInTrade", display=display.data_window)
plot(pyramidCount,   "PyramidCount",  display=display.data_window)
plot(addEntryPrice,  "AddEntryPrice", display=display.data_window)
plot(addSlPips,      "AddSLPips",     display=display.data_window)
plot(addTpPips,      "AddTPPips",     display=display.data_window)

// ============================ VISUALS ============================
plot(showLines and tradeDir != 0 ? stopPrice : na, "SL Line",  color=color.new(color.red, 0),   style=plot.style_linebr, linewidth=2)
plot(showLines and tradeDir != 0 and not tp2Hit ? tp2Price : na, "TP2 Line", color=color.new(color.lime, 0),  style=plot.style_linebr, linewidth=1)
// Note: TP1 line intentionally not plotted here — tp1Price never trails after entry
// (only pyramid adds move it), so it's identical to initTP1, already drawn as the
// dashed zTpLine of the current live zone in the Entry Zone section below.

if showLabels and isFreshLong
    addSignalLabel(label.new(bar_index, low - atrVal * 0.5, "BUY", style=label.style_label_up, color=color.green, textcolor=color.white, size=size.small))

if showLabels and isFreshShort
    addSignalLabel(label.new(bar_index, high + atrVal * 0.5, "SELL", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small))

if showLabels and isAddLong
    addSignalLabel(label.new(bar_index, low - atrVal * 0.5, "ADD+", style=label.style_label_up, color=color.new(color.green, 45), textcolor=color.white, size=size.small))

if showLabels and isAddShort
    addSignalLabel(label.new(bar_index, high + atrVal * 0.5, "ADD+", style=label.style_label_down, color=color.new(color.red, 45), textcolor=color.white, size=size.small))

if showLabels and stopHitAlert
    addSignalLabel(label.new(bar_index, exitDir == 1 ? low : high, "SL",
         style = exitDir == 1 ? label.style_label_up : label.style_label_down,
         color=color.new(color.red, 20), textcolor=color.white, size=size.tiny))

if showLabels and timeoutExitAlert
    addSignalLabel(label.new(bar_index, exitDir == 1 ? low : high, "TIME",
         style = exitDir == 1 ? label.style_label_up : label.style_label_down,
         color=color.new(#787b86, 20), textcolor=color.white, size=size.tiny))

if showLabels and tp1HitAlert
    addSignalLabel(label.new(bar_index, tradeDir == 1 ? high : low, "TP1",
         style = tradeDir == 1 ? label.style_label_down : label.style_label_up,
         color=color.new(#00e676, 20), textcolor=color.black, size=size.tiny))

if showLabels and tp2HitAlert
    addSignalLabel(label.new(bar_index, tradeDir == 1 ? high : low, "TP2",
         style = tradeDir == 1 ? label.style_label_down : label.style_label_up,
         color=color.new(#00e676, 20), textcolor=color.black, size=size.tiny))

if showLabels and tp1FlattenAlert
    addSignalLabel(label.new(bar_index, exitDir == 1 ? high : low, "TP1 FLAT",
         style = exitDir == 1 ? label.style_label_down : label.style_label_up,
         color=color.new(#2962ff, 15), textcolor=color.white, size=size.tiny))

if showLabels and tp2FlattenAlert
    addSignalLabel(label.new(bar_index, exitDir == 1 ? high : low, "TP2 FLAT",
         style = exitDir == 1 ? label.style_label_down : label.style_label_up,
         color=color.new(#2962ff, 15), textcolor=color.white, size=size.tiny))

// ============================ ALERTS ============================
alertcondition(isFreshLong, title="Template Long Entry",
     message='{\n  "traderIdKey": "replace with your key",\n  "tradeSide": "buy",\n  "symbol": "{{ticker}}",\n  "volumeType": "fixed",\n  "volume": 1,\n  "relativeTakeProfit": {{plot("InitTPPips")}},\n  "relativeStopLoss": {{plot("InitSLPips")}},\n  "trailingStopLoss": false,\n  "closeExisting": false,\n  "strategyId": "replace with your strategy-name (slug)"\n}')

alertcondition(isFreshShort, title="Template Short Entry",
     message='{\n  "traderIdKey": "replace with your key",\n  "tradeSide": "sell",\n  "symbol": "{{ticker}}",\n  "volumeType": "fixed",\n  "volume": 1,\n  "relativeTakeProfit": {{plot("InitTPPips")}},\n  "relativeStopLoss": {{plot("InitSLPips")}},\n  "trailingStopLoss": false,\n  "closeExisting": false,\n  "strategyId": "replace with your strategy-name (slug)"\n}')

alertcondition(isAddLong, title="Template Long Pyramid Add",
     message='{\n  "traderIdKey": "replace with your key",\n  "tradeSide": "buy",\n  "symbol": "{{ticker}}",\n  "volumeType": "fixed",\n  "volume": 1,\n  "relativeTakeProfit": {{plot("AddTPPips")}},\n  "relativeStopLoss": {{plot("AddSLPips")}},\n  "trailingStopLoss": false,\n  "closeExisting": false,\n  "strategyId": "replace with your strategy-name (slug)"\n}')

alertcondition(isAddShort, title="Template Short Pyramid Add",
     message='{\n  "traderIdKey": "replace with your key",\n  "tradeSide": "sell",\n  "symbol": "{{ticker}}",\n  "volumeType": "fixed",\n  "volume": 1,\n  "relativeTakeProfit": {{plot("AddTPPips")}},\n  "relativeStopLoss": {{plot("AddSLPips")}},\n  "trailingStopLoss": false,\n  "closeExisting": false,\n  "strategyId": "replace with your strategy-name (slug)"\n}')

alertcondition(stopHitAlert, title="Template Stop Loss Hit",
     message='{"ticker":"{{ticker}}","action":"exit_sl","exit":{{plot("ExitPrice")}}}')

alertcondition(timeoutExitAlert, title="Template Trade Timeout Exit",
     message='{"ticker":"{{ticker}}","action":"exit_timeout","exit":{{plot("ExitPrice")}}}')

alertcondition(tp1HitAlert, title="Template TP1 Hit",
     message='{"ticker":"{{ticker}}","action":"partial_tp1","level":{{plot("TP1")}}}')

alertcondition(tp2HitAlert, title="Template TP2 Hit",
     message='{"ticker":"{{ticker}}","action":"partial_tp2","level":{{plot("TP2")}}}')

alertcondition(tp1FlattenAlert, title="Template Flatten at TP1",
     message='{"ticker":"{{ticker}}","action":"exit_tp1_flatten","exit":{{plot("ExitPrice")}}}')

alertcondition(tp2FlattenAlert, title="Template Flatten at TP2",
     message='{"ticker":"{{ticker}}","action":"exit_tp2_flatten","exit":{{plot("ExitPrice")}}}')

alertcondition(trailUpdatedAlert, title="Template Trailing Stop Update",
     message='{\n  "traderIdKey": "replace with your key",\n  "modifyPosition": true,\n  "strategyId": "replace with your strategy-name (slug)",\n  "stopLossPips": {{plot("TrailStopPips")}},\n  "trailingStopLoss": false\n}')
````
