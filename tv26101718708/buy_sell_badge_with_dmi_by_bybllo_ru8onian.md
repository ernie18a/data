# Buy Sell Badge with DMI by Bybllo

- url: https://www.tradingview.com/script/RU8oNIaN/
- type: indicator
- pine_id: PUB;b6c50871e0794e74b83fe1969e88daaa
- version: 4.0

## Description

Buy Sell Badge with DMI by Bybllo
At its core, this indicator combines two independent Buy/Sell signal sources into one badge system: (1) a basic Fast/Slow EMA crossover ("BSB"), and (2) a DMI-based signal built from the golden cross (DI+ crossing above DI-) and dead cross (DI- crossing above DI+) of the Directional Movement Index, filtered by a minimum ADX threshold.
The EMA crossover generates the base Buy/Sell signal, then automatically manages an ATR-based stop loss and a risk:reward-based take profit for each signal, showing the resulting entry/stop/target levels directly on the chart along with a live status table. The DMI golden-cross / dead-cross engine can be enabled as a confirmation filter on top of that: when turned on, a badge is only shown if a matching DMI cross (with ADX above a configurable threshold) occurs within a set number of bars of the EMA signal. In practice, this acts as a noise-reduction filter — choppy, low-conviction EMA crossovers with no matching directional strength behind them are suppressed, so only badges backed by both a trend-following signal and a directional-strength signal are actually displayed.
Key Features

Fast/Slow EMA crossover generates the base Buy/Sell signal, with an optional candle-confirmation requirement (close beyond open in the signal direction).
Automatic ATR-based stop loss and configurable Risk:Reward take profit are calculated for every new signal, with intermediate take-profit levels plotted when Risk:Reward is greater than 1.
Optional "BSB + DMI" confirmation filter: a badge is only shown when a DMI golden cross or dead cross, confirmed by ADX above your threshold, occurs within a configurable bar window of the EMA signal, in either order. This suppresses noisy, low-conviction EMA crossovers and leaves only the badges that are backed by both signals.
On-chart entry / stop-loss / take-profit lines and an SL distance (in points) label, both toggleable and only shown while a badge has actually been displayed for the active position.
Take-profit, stop-loss, and "invalidated" (opposite signal fired before target/stop was hit) markers are plotted separately so you can see exactly how each trade idea played out.
A live status table (top-right) shows the current position, entry, stop loss, take profit, and realized Risk:Reward.
Real-price calculation via request.security() keeps signals consistent regardless of chart type (Heikin Ashi, Renko, etc.).
A full set of alertcondition() calls for BSB-only signals, BSB+DMI confirmed signals, take-profit hits, stop-loss hits, and invalidated entries.

How to Use

Leave "BSB + DMI" unchecked to use the EMA crossover badges on their own (fastest signals, no directional-strength filter).
Check "BSB + DMI" to require that a DMI golden cross (for Buy) or dead cross (for Sell), confirmed by ADX, also occurs near the EMA signal — this filters out noise and typically reduces the number of badges, but favors signals that also have directional strength behind them.
Watch the on-chart entry/SL/TP lines and the status table to track an open idea's risk and progress in real time.
Set up alerts on the "BSB+DMI Buy/Sell", "Buy/Sell Signal", "Take Profit Hit", "Stop Loss Hit", or "Entry Invalidated" conditions depending on which events you want to be notified about.

Notes

The "EMA Badge Spacing" and "DMI Badge Spacing" inputs each apply their own cooldown to prevent duplicate signals firing on consecutive bars; keep the DMI spacing aligned with the badge spacing you use on other DMI-based indicators if you compare them side by side.
Stop-loss and alert-sensitivity offsets are point-based and will need adjusting per instrument (see the tooltips on those inputs).
This indicator does not place real orders; it is a visual / alerting tool for tracking a rules-based EMA + DMI golden-cross/dead-cross trade idea.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Bybllo

//@version=6
// ══════════════════════════════════════════════════════════════════
// Buy Sell Badge with DMI by Bybllo
// ══════════════════════════════════════════════════════════════════
// OVERVIEW
// At its core, this indicator combines two independent Buy/Sell
// signal sources into one badge system: (1) a basic Fast/Slow EMA
// crossover ("BSB"), and (2) a DMI-based signal built from the
// golden cross (DI+ crossing above DI-) and dead cross (DI- crossing
// above DI+) of the Directional Movement Index, filtered by a
// minimum ADX threshold - and, optionally, only while ADX itself is
// actively rising. The EMA crossover generates the base Buy/Sell
// signal, then automatically manages an ATR-based stop loss and a
// risk:reward-based take profit for each signal, showing the
// resulting entry/stop/target levels directly on the chart along
// with a live status table. The DMI golden-cross / dead-cross engine
// can be enabled as a confirmation filter on top of that: when turned
// on, a badge is only shown if a matching DMI cross (with ADX above a
// configurable threshold) occurs within a set number of bars of the
// EMA signal, which helps filter out weaker EMA-only crossovers that
// lack directional strength behind them.
//
// ADX RISING CONFIRMATION
// The DMI condition has its own "ADX Rising" toggle (checked by
// default). When checked, a DMI cross is only recognized when ADX is
// at/above the threshold AND ADX is higher than on the previous bar -
// i.e. not just "directionally confirmed," but "confirmed while
// strength is still building," which filters out crosses that occur
// right as ADX is already peaking and starting to roll over.
//
// This toggle was carefully implemented so that checking it can only
// ever reduce the number of badges shown, never add new ones in
// places they wouldn't otherwise appear. Internally, the DMI signal's
// own cooldown timer ("DMI Badge Spacing") is always driven by the
// threshold-only condition, completely independent of whether "ADX
// Rising" is checked - the rising requirement is applied only as an
// extra filter on top of that, after the cooldown timing has already
// been fixed. This avoids a subtle trap common to this kind of
// filter: if the cooldown timer were driven by the filtered signal
// instead, suppressing an earlier DMI cross (because ADX wasn't
// rising) would leave the cooldown "unconsumed," which could then
// let a later, otherwise-blocked crossover slip through - producing
// a badge that wouldn't exist with the filter off. With the cooldown
// timing decoupled from the rising filter, that cannot happen here:
// turning "ADX Rising" on is guaranteed to be a strict narrowing of
// the badges you'd see with it off.
//
// KEY FEATURES
// - Fast/Slow EMA crossover generates the base Buy/Sell signal, with
//   an optional candle-confirmation requirement (close beyond open in
//   the signal direction).
// - Automatic ATR-based stop loss and configurable Risk:Reward take
//   profit are calculated for every new signal, with intermediate
//   take-profit levels plotted when Risk:Reward is greater than 1.
// - Optional "BSB + DMI" confirmation filter: a badge is only shown
//   when a DMI golden cross or dead cross, confirmed by ADX above
//   your threshold, occurs within a configurable bar window of the
//   EMA signal, in either order. This suppresses noisy, low-conviction
//   EMA crossovers and leaves only the badges that are backed by both
//   signals.
// - Independent "ADX Rising" toggle for the DMI condition, letting
//   you additionally require that ADX is actively increasing at the
//   moment of the DMI cross, not merely past the threshold -
//   implemented so it can only reduce badge count, never increase it
//   (see above).
// - On-chart entry / stop-loss / take-profit lines and an SL distance
//   (in points) label, both toggleable and only shown while a badge
//   has actually been displayed for the active position.
// - Take-profit, stop-loss, and "invalidated" (opposite signal fired
//   before target/stop was hit) markers are plotted separately so you
//   can see exactly how each trade idea played out.
// - A live status table (top-right) shows the current position,
//   entry, stop loss, take profit, and realized Risk:Reward.
// - Real-price calculation: prices and ATR are pulled via
//   request.security() against the plain ticker, so signals stay
//   consistent whether your chart is displaying candlesticks, Heikin
//   Ashi, Renko, or any other non-standard chart type.
// - A full set of alertcondition() calls for BSB-only signals,
//   BSB+DMI confirmed signals, take-profit hits, stop-loss hits, and
//   invalidated entries.
//
// BADGE COLOR GUIDE (US convention: green = buy, red = sell)
// - Plain BSB (filter unchecked): green "L" / orange "S"
// - BSB + DMI confirmed (filter checked): lime "BUY" / red "SELL"
// - Take Profit hit: green circle "TP"
// - Stop Loss hit: red cross "SL"
// - Invalidated entry: yellow diamond "INV BUY" / "INV SELL"
//
// HOW TO USE
// - Leave "BSB + DMI" unchecked to use the EMA crossover badges on
//   their own (fastest signals, no directional-strength filter).
// - Check "BSB + DMI" to require that a DMI golden cross (for Buy) or
//   dead cross (for Sell), confirmed by ADX, also occurs near the EMA
//   signal — this typically reduces the number of badges but favors
//   signals that also have directional strength behind them.
// - Leave "ADX Rising" checked (the default) if you also want to
//   require that ADX is currently increasing at the DMI cross, not
//   just past the threshold; uncheck it if you want any ADX value
//   past the threshold to count, regardless of whether it's rising or
//   falling.
// - Watch the on-chart entry/SL/TP lines and the status table to
//   track an open idea's risk and progress in real time.
// - Set up alerts on the "BSB+DMI Buy/Sell", "Buy/Sell Signal", "Take
//   Profit Hit", "Stop Loss Hit", or "Entry Invalidated" conditions
//   depending on which events you want to be notified about.
//
// NOTES
// - The "EMA Badge Spacing" and "DMI Badge Spacing" inputs each apply
//   their own cooldown to prevent duplicate signals firing on
//   consecutive bars; keep the DMI spacing aligned with the badge
//   spacing you use on other DMI-based indicators if you compare them
//   side by side.
// - Stop-loss and alert-sensitivity offsets are point-based and will
//   need adjusting per instrument (see the tooltips on those inputs).
// - This indicator does not place real orders; it is a visual /
//   alerting tool for tracking a rules-based EMA (optionally
//   DMI-confirmed) trade idea.
//
// DISCLAIMER
// For educational and informational purposes only. This is not
// financial advice. Past performance and simulated signals do not
// guarantee future results. Always backtest and forward-test before
// using with real capital.
// ══════════════════════════════════════════════════════════════════
indicator('Buy Sell Badge with DMI by Bybllo', overlay=true)
// ============================================
// CONFIGURABLE PARAMETERS
// ============================================
emaFastLen    = input.int(3,    'Fast EMA',              minval=1)
emaSlowLen    = input.int(9,    'Slow EMA',              minval=1)
atrLen        = input.int(10,   'ATR Period',            minval=1)
atrMultSL     = input.float(1.0,'SL Multiplier (ATR)',   minval=0.1, step=0.1)
riskReward    = input.float(2.0,'Risk:Reward (R:R)',     minval=1.0, step=0.5)
confirmCandle = input.bool(true,'Require candle confirmation')
minBars       = input.int(1,   'EMA Badge Spacing (bars)', minval=1, step=1,
     tooltip='Prevents consecutive duplicate signals: a new signal is only allowed after at least N bars have passed since the last signal')
showLines     = input.bool(true,'Show Entry/SL/TP Lines',
     tooltip='Whether to display the entry / stop-loss / take-profit lines while a position is active')
showRiskLabel = input.bool(true,'Show SL Distance (points)',
     tooltip='Displays the distance between entry price and stop-loss price (in points) above the stop-loss line')
slLabelOffset = input.float(0.8, 'SL Distance Label Offset', minval=0.1, step=0.1,
     tooltip='Gap between the SL line and the points label - adjust per instrument (KOSPI200 \u2248 0.8, Nasdaq \u2248 5.0)')
alertMinPoints = input.float(4.0, 'Alert Sensitivity (points)', minval=0.1, step=0.5,
     tooltip='Alerts only fire when the entry-to-stop-loss distance is at least this value (adjust separately for Nasdaq / KOSPI200 / mini contracts)')
// DMI Settings
dmiLen       = input.int(14,  'DMI Length',           minval=1, step=1, group='DMI')
dmiMinBars   = input.int(5,   'DMI Badge Spacing (bars)',       minval=1, step=1, group='DMI',
     tooltip='Minimum number of bars between DMI signals - keep this aligned with the badge spacing of the DMI Badge indicator')
barGap       = input.int(3,   'BSB-DMI Badge Match Window (bars)', minval=0, step=1, group='DMI',
     tooltip='If a BSB signal and a DMI signal occur within this many bars of each other, they are treated as a match')
adxTh        = input.int(7,  'ADX Threshold (minimum)', minval=1, step=1, group='DMI',
     tooltip='A DMI signal is only recognized when ADX is at or above this value')
reqRisingDMI = input.bool(false, 'ADX Rising', group='DMI',
     tooltip='Checked: a DMI signal is only recognized when ADX is at or above the threshold AND ADX is higher than on the previous bar. Unchecked: any ADX value at or above the threshold is recognized, regardless of whether it is rising.')
useDmiFilter = input.bool(true, 'BSB + DMI',
     tooltip='Checked: shows a badge only when BSB and DMI signals occur within the bar-gap window of each other. Unchecked: behaves as standalone BSB only',
     group='DMI')
// EMA Settings
showEmaFastLabel = input.bool(true,          'Show Fast EMA',  group='EMAs')
emaFastColor     = input.color(#d61af7,  'Fast EMA Color', group='EMAs')
showEmaSlowLabel = input.bool(true,           'Show Slow EMA',  group='EMAs')
emaSlowColor     = input.color(#0016f8, 'Slow EMA Color', group='EMAs')
// ============================================
// Force real market prices regardless of chart type (Heikin Ashi,
// Renko, etc.) via request.security (open/high/low/close and ATR
// are all pulled this way)
// ============================================
t = ticker.new(syminfo.prefix, syminfo.ticker)
[ro, rh, rl, rc, ratr] = request.security(t, timeframe.period, [open, high, low, close, ta.atr(atrLen)])
// ============================================
// EMA AND ATR CALCULATIONS
// ============================================
emaFast = ta.ema(rc, emaFastLen)
emaSlow = ta.ema(rc, emaSlowLen)
// ============================================
// DMI / ADX CALCULATION
// ============================================
TrueRange = math.max(math.max(rh - rl, math.abs(rh - nz(rc[1]))), math.abs(rl - nz(rc[1])))
DirectionalMovementPlus  = rh - nz(rh[1]) > nz(rl[1]) - rl ? math.max(rh - nz(rh[1]), 0) : 0
DirectionalMovementMinus = nz(rl[1]) - rl > rh - nz(rh[1]) ? math.max(nz(rl[1]) - rl, 0) : 0
SmoothedTrueRange = 0.0
SmoothedTrueRange := nz(SmoothedTrueRange[1]) - nz(SmoothedTrueRange[1]) / dmiLen + TrueRange
SmoothedDirectionalMovementPlus = 0.0
SmoothedDirectionalMovementPlus := nz(SmoothedDirectionalMovementPlus[1]) - nz(SmoothedDirectionalMovementPlus[1]) / dmiLen + DirectionalMovementPlus
SmoothedDirectionalMovementMinus = 0.0
SmoothedDirectionalMovementMinus := nz(SmoothedDirectionalMovementMinus[1]) - nz(SmoothedDirectionalMovementMinus[1]) / dmiLen + DirectionalMovementMinus
DIPlus  = SmoothedDirectionalMovementPlus  / SmoothedTrueRange * 100
DIMinus = SmoothedDirectionalMovementMinus / SmoothedTrueRange * 100
DX      = math.abs(DIPlus - DIMinus) / (DIPlus + DIMinus) * 100
ADX     = ta.sma(DX, dmiLen)
adxRising = ADX > ADX[1]
adxThOk   = ADX >= adxTh
var int lastDMISignalBar = -9999
dmiCooldownOk = (bar_index - lastDMISignalBar) >= dmiMinBars
// The cooldown timer always advances on the threshold-only condition
// (independent of the ADX Rising toggle), so checking/unchecking
// "ADX Rising" never shifts the cooldown timing - it can only ever
// remove badges, never add new ones elsewhere.
dmiLongBase  = ta.crossover(DIPlus,  DIMinus) and adxThOk and dmiCooldownOk
dmiShortBase = ta.crossover(DIMinus, DIPlus)  and adxThOk and dmiCooldownOk
if dmiLongBase or dmiShortBase
    lastDMISignalBar := bar_index
// "ADX Rising" is applied only as an extra filter on top of the base
// signal, after the cooldown timing has already been fixed above.
dmiLong  = dmiLongBase  and (reqRisingDMI ? adxRising : true)
dmiShort = dmiShortBase and (reqRisingDMI ? adxRising : true)
// ============================================
// TREND LOGIC
// ============================================
bullTrend   = emaFast > emaSlow
bearTrend   = emaFast < emaSlow
trendChange = bullTrend != bullTrend[1]
// ============================================
// ENTRY SIGNALS
// ============================================
buyCondition1  = bullTrend and trendChange and rc > ro
sellCondition1 = bearTrend and trendChange and rc < ro
buyCondition2  = bullTrend and trendChange
buySignal  = confirmCandle ? buyCondition1 : buyCondition2
sellSignal = confirmCandle ? sellCondition1 : (bearTrend and trendChange)
// ============================================
// POSITION MANAGEMENT
// ============================================
var float  entryPrice      = na
var float  stopLoss        = na
var float  takeProfitFinal = na
var bool   inPosition      = false
var string positionType    = ''
var int    lastSignalBar   = 0
var bool   alertRiskOk     = false
var bool   positionBadgeShown = false
var float[] tpLevels   = array.new_float(0)
var bool[]  tpHitFlags = array.new_bool(0)
// Track the bar index of BSB/DMI signals (initialized to -9999 to prevent false matches)
var int lastBSBBuyBar   = -9999
var int lastBSBSellBar  = -9999
var int lastDMILongBar  = -9999
var int lastDMIShortBar = -9999
// Update DMI signal bar - reset the opposite-direction record to prevent false matches
if dmiLong
    lastDMILongBar  := bar_index
    lastDMIShortBar := -9999  // reset opposite direction
if dmiShort
    lastDMIShortBar := bar_index
    lastDMILongBar  := -9999  // reset opposite direction
// ============================================
// CLOSING POSITIONS
// ============================================
tpFinalHit  = false
slHit       = false
invalidated = false
if inPosition and positionType == 'LONG'
    if rh >= takeProfitFinal
        tpFinalHit         := true
        inPosition         := false
        positionType       := ''
        positionBadgeShown := false
    else if rl <= stopLoss
        slHit              := true
        inPosition         := false
        positionType       := ''
        positionBadgeShown := false
if inPosition and positionType == 'SHORT'
    if rl <= takeProfitFinal
        tpFinalHit         := true
        inPosition         := false
        positionType       := ''
        positionBadgeShown := false
    else if rh >= stopLoss
        slHit              := true
        inPosition         := false
        positionType       := ''
        positionBadgeShown := false
if inPosition and array.size(tpLevels) > 0
    for i = 0 to array.size(tpLevels) - 1
        if not array.get(tpHitFlags, i)
            if positionType == 'LONG' and rh >= array.get(tpLevels, i)
                array.set(tpHitFlags, i, true)
            else if positionType == 'SHORT' and rl <= array.get(tpLevels, i)
                array.set(tpHitFlags, i, true)
// ============================================
// INVALIDATION AND NEW ENTRIES (always based on BSB)
// ============================================
showBuySignal  = false
showSellSignal = false
var string invalidatedType = ''
cooldownOk = (bar_index - lastSignalBar) >= minBars
if buySignal and barstate.isconfirmed and cooldownOk
    if not inPosition or positionType != 'LONG'
        if inPosition and positionType == 'SHORT'
            invalidated        := true
            invalidatedType    := 'SELL'
            inPosition         := false
            positionBadgeShown := false
        entryPrice      := rc
        stopLoss        := rl - ratr * atrMultSL
        risk             = math.abs(entryPrice - stopLoss)
        takeProfitFinal := entryPrice + risk * riskReward
        array.clear(tpLevels)
        array.clear(tpHitFlags)
        numTPs = math.floor(riskReward)
        for i = 1 to numTPs - 1
            array.push(tpLevels,   entryPrice + risk * i)
            array.push(tpHitFlags, false)
        inPosition         := true
        positionType       := 'LONG'
        showBuySignal      := true
        lastSignalBar      := bar_index
        lastBSBBuyBar      := bar_index
        lastBSBSellBar     := -9999  // reset opposite direction
        lastDMIShortBar    := -9999  // reset opposite-direction DMI too
        alertRiskOk        := risk >= alertMinPoints
        positionBadgeShown := not useDmiFilter
if sellSignal and barstate.isconfirmed and cooldownOk
    if not inPosition or positionType != 'SHORT'
        if inPosition and positionType == 'LONG'
            invalidated        := true
            invalidatedType    := 'BUY'
            inPosition         := false
            positionBadgeShown := false
        entryPrice      := rc
        stopLoss        := rh + ratr * atrMultSL
        risk             = math.abs(stopLoss - entryPrice)
        takeProfitFinal := entryPrice - risk * riskReward
        array.clear(tpLevels)
        array.clear(tpHitFlags)
        numTPs = math.floor(riskReward)
        for i = 1 to numTPs - 1
            array.push(tpLevels,   entryPrice - risk * i)
            array.push(tpHitFlags, false)
        inPosition         := true
        positionType       := 'SHORT'
        showSellSignal     := true
        lastSignalBar      := bar_index
        lastBSBSellBar     := bar_index
        lastBSBBuyBar      := -9999  // reset opposite direction
        lastDMILongBar     := -9999  // reset opposite-direction DMI too
        alertRiskOk        := risk >= alertMinPoints
        positionBadgeShown := not useDmiFilter
// ============================================
// BSB + DMI badge filter
// Case 1: BSB first -> DMI later -> badge is placed at the DMI bar
// Case 2: DMI first -> BSB later -> badge is placed at the BSB bar
// ============================================
// Case 2: at the BSB bar (when DMI happened first)
combinedBuyFromBSB  = showBuySignal  and lastDMILongBar  >= 0 and (bar_index - lastDMILongBar)  <= barGap
combinedSellFromBSB = showSellSignal and lastDMIShortBar >= 0 and (bar_index - lastDMIShortBar) <= barGap
// Case 1: at the DMI bar (when BSB happened first)
combinedBuyFromDMI  = dmiLong  and not showBuySignal  and inPosition and positionType == 'LONG'  and lastBSBBuyBar  >= 0 and (bar_index - lastBSBBuyBar)  <= barGap
combinedSellFromDMI = dmiShort and not showSellSignal and inPosition and positionType == 'SHORT' and lastBSBSellBar >= 0 and (bar_index - lastBSBSellBar) <= barGap
showCombinedBuy  = combinedBuyFromBSB  or combinedBuyFromDMI
showCombinedSell = combinedSellFromBSB or combinedSellFromDMI
// Determine whether to display the badge
finalBuyBadge  = useDmiFilter ? showCombinedBuy  : showBuySignal
finalSellBadge = useDmiFilter ? showCombinedSell : showSellSignal
// Enable positionBadgeShown whenever a badge is displayed
if (useDmiFilter and (showCombinedBuy or showCombinedSell)) or (not useDmiFilter and (showBuySignal or showSellSignal))
    positionBadgeShown := true
// ============================================
// VISUALIZATION
// ============================================
plot(emaFast, title='Fast EMA', color=color.new(emaFastColor, 0), linewidth=1,
     display=showEmaFastLabel ? display.all : display.none)
plot(emaSlow, title='Slow EMA', color=color.new(emaSlowColor, 0), linewidth=1,
     display=showEmaSlowLabel ? display.all : display.none)
showBSBOnlyBuy  = showBuySignal  and not useDmiFilter
showBSBOnlySell = showSellSignal and not useDmiFilter
showDMICombBuy  = finalBuyBadge  and useDmiFilter
showDMICombSell = finalSellBadge and useDmiFilter
// BSB standalone (filter unchecked) - buy/sell colors swapped to US convention
plotshape(showBSBOnlyBuy,  'BUY Signal',      shape.labelup,   location.belowbar,
     color.new(color.rgb(27,94,32), 0), text=' L ', textcolor=color.white, size=size.auto)
plotshape(showBSBOnlySell, 'SELL Signal',     shape.labeldown, location.abovebar,
     color.new(color.orange, 15), text=' S ', textcolor=color.white, size=size.auto)
// BSB+DMI (filter checked) - distinct badge, buy/sell colors swapped to US convention (green=buy, red=sell)
plotshape(showDMICombBuy,  'BUY+DMI Signal',  shape.labelup,   location.belowbar,
     color.new(color.lime, 0), text='BUY', textcolor=color.white, size=size.auto)
plotshape(showDMICombSell, 'SELL+DMI Signal', shape.labeldown, location.abovebar,
     color.new(color.red,  0), text='SELL', textcolor=color.white, size=size.auto)
plotshape(tpFinalHit, 'FINAL TAKE PROFIT', shape.circle, location.abovebar,
     color.new(#00ff00, 0), text='TP', textcolor=#00ff00, size=size.tiny)
plotshape(slHit, 'STOP LOSS', shape.xcross, location.belowbar,
     color.new(#ff0000, 0), text='SL', textcolor=color.white, size=size.tiny)
plotshape(invalidated and invalidatedType == 'BUY',  'INVALIDATED BUY',  shape.diamond, location.abovebar,
     color.new(color.yellow, 0), text='INV BUY',  textcolor=color.rgb(97, 100, 107), size=size.tiny)
plotshape(invalidated and invalidatedType == 'SELL', 'INVALIDATED SELL', shape.diamond, location.abovebar,
     color.new(color.yellow, 0), text='INV SELL', textcolor=color.rgb(97, 100, 107), size=size.tiny)
// ============================================
// RISK MANAGEMENT LINES (only for positions where a badge has been shown)
// ============================================
var line   entryLine           = na
var line   slLine              = na
var line   tpLineFinal         = na
var line[] tpIntermediateLines = array.new_line(0)
if inPosition and positionType != '' and showLines and positionBadgeShown
    if na(entryLine)
        entryLine := line.new(bar_index - 10, entryPrice, bar_index + 10, entryPrice,
             color=color.new(color.white, 30), width=2, style=line.style_dotted)
    else
        line.set_xy1(entryLine, bar_index - 10, entryPrice)
        line.set_xy2(entryLine, bar_index + 10, entryPrice)
    if na(slLine)
        slLine := line.new(bar_index, stopLoss, bar_index + 10, stopLoss,
             color=color.new(color.red, 0), width=3)
    else
        line.set_xy1(slLine, bar_index, stopLoss)
        line.set_xy2(slLine, bar_index + 10, stopLoss)
    if na(tpLineFinal)
        tpLineFinal := line.new(bar_index, takeProfitFinal, bar_index + 10, takeProfitFinal,
             color=color.new(color.green, 0), width=3)
    else
        line.set_xy1(tpLineFinal, bar_index, takeProfitFinal)
        line.set_xy2(tpLineFinal, bar_index + 10, takeProfitFinal)
    if array.size(tpIntermediateLines) == 0 and array.size(tpLevels) > 0
        for i = 0 to array.size(tpLevels) - 1
            tpLine = line.new(bar_index, array.get(tpLevels, i), bar_index + 10,
                 array.get(tpLevels, i), color=color.new(#00E676, 30),
                 width=1, style=line.style_dotted)
            array.push(tpIntermediateLines, tpLine)
    else if array.size(tpIntermediateLines) > 0
        for i = 0 to array.size(tpIntermediateLines) - 1
            line.set_xy1(array.get(tpIntermediateLines, i), bar_index, array.get(tpLevels, i))
            line.set_xy2(array.get(tpIntermediateLines, i), bar_index + 10, array.get(tpLevels, i))
else
    if not na(entryLine)
        line.delete(entryLine)
        entryLine := na
    if not na(slLine)
        line.delete(slLine)
        slLine := na
    if not na(tpLineFinal)
        line.delete(tpLineFinal)
        tpLineFinal := na
    if array.size(tpIntermediateLines) > 0
        for i = 0 to array.size(tpIntermediateLines) - 1
            line.delete(array.get(tpIntermediateLines, i))
        array.clear(tpIntermediateLines)
// ============================================
// SL POINTS LABEL
// ============================================
var label slRiskLabel = na
if inPosition and positionType != '' and showLines and showRiskLabel and positionBadgeShown
    riskDisplay = math.abs(entryPrice - stopLoss)
    riskText    = str.tostring(riskDisplay, '#.0') + 'P'
    slLabelY    = stopLoss + slLabelOffset
    slLabelX    = bar_index + 5
    if na(slRiskLabel)
        slRiskLabel := label.new(slLabelX, slLabelY, riskText,
             color     = color(na),
             textcolor = color.new(color.white, 10),
             style     = label.style_label_center,
             size      = size.normal)
    else
        label.set_xy(  slRiskLabel, slLabelX, slLabelY)
        label.set_text(slRiskLabel, riskText)
else
    if not na(slRiskLabel)
        label.delete(slRiskLabel)
        slRiskLabel := na
// ============================================
// INFO TABLE
// ============================================
var table infoTable = table.new(position.top_right, 2, 5,
     bgcolor=color.new(color.black, 85), border_width=1)
if barstate.islast
    table.cell(infoTable, 0, 0, 'Status:', text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 0, inPosition ? positionType : 'No Position',
          text_color=inPosition ? color.yellow : color.gray, text_size=size.small)
    if inPosition
        table.cell(infoTable, 0, 1, 'Entry:', text_color=color.white, text_size=size.small)
        table.cell(infoTable, 1, 1, str.tostring(entryPrice, '#.##'),
             text_color=color.white, text_size=size.small)
        table.cell(infoTable, 0, 2, 'Stop Loss:', text_color=color.white, text_size=size.small)
        table.cell(infoTable, 1, 2, str.tostring(stopLoss, '#.##'),
             text_color=color.red, text_size=size.small)
        table.cell(infoTable, 0, 3, 'Take Profit:', text_color=color.white, text_size=size.small)
        table.cell(infoTable, 1, 3, str.tostring(takeProfitFinal, '#.##'),
             text_color=color.green, text_size=size.small)
        riskVal   = math.abs(entryPrice - stopLoss)
        rewardVal = math.abs(takeProfitFinal - entryPrice)
        currentRR = rewardVal / riskVal
        table.cell(infoTable, 0, 4, 'R:R:', text_color=color.white, text_size=size.small)
        table.cell(infoTable, 1, 4, str.tostring(currentRR, '#.##') + ':1',
             text_color=color.orange, text_size=size.small)
// ============================================
// ALERTS
// ============================================
alertcondition(showDMICombBuy  and alertRiskOk, 'BSB+DMI Buy',  'BSB+DMI Buy - Buy Sell Badge with DMI [Bybllo]')
alertcondition(showDMICombSell and alertRiskOk, 'BSB+DMI Sell', 'BSB+DMI Sell - Buy Sell Badge with DMI [Bybllo]')
alertcondition(showBuySignal  and alertRiskOk, 'Buy Signal',   'Buy Signal - Buy Sell Badge [Bybllo]')
alertcondition(showSellSignal and alertRiskOk, 'Sell Signal',  'Sell Signal - Buy Sell Badge [Bybllo]')
alertcondition((showBuySignal or showSellSignal) and alertRiskOk, 'Entry Signal', 'Entry Signal - Buy Sell Badge [Bybllo]')
alertcondition(tpFinalHit     and alertRiskOk, 'Final Take Profit Hit', 'Take Profit Hit - Buy Sell Badge [Bybllo]')
alertcondition(slHit          and alertRiskOk, 'Stop Loss Hit',         'Stop Loss Hit - Buy Sell Badge [Bybllo]')
alertcondition(invalidated    and alertRiskOk, 'Entry Invalidated',    'Entry Invalidated - Buy Sell Badge [Bybllo]')
//==============================================
````
