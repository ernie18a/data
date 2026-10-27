# ASLC Visual Dashboard - VDUAE

- url: https://www.tradingview.com/script/NKHC41ex-ASLC-Visual-Dashboard-VDUAE/
- type: indicator
- pine_id: PUB;f7fbb35e80d94d348a261f57b92d7d1c
- version: 1.0

## Description

ASLC Visual Dashboard — Asian Session XAUUSD

A visual analysis tool for reading Asian-session liquidity sweeps on Gold (XAUUSD), built around a simple but often-overlooked idea: price frequently sweeps a session's range boundary more than once before the real directional move happens.

How it works

Splits the Asian session into two phases: a range-formation window (default 00:00–03:00 UTC) where the high/low lock in, and a trade window (default 03:00–07:00 UTC) where the logic watches for reactions at those levels.
Counts every time price wicks beyond the range high or low and closes back inside it — one full round trip is a "sweep."
Once a chosen number of sweeps on the same side complete (default: 2), the setup arms — background shades lime (bullish) or fuchsia (bearish), and a stop-loss locks in based on that sweep's extreme.
Optionally waits for a brief consolidation, then looks for a break of recent structure in the armed direction to trigger a labeled entry signal with SL/TP1/TP2 printed on the chart.
Includes an optional 1H EMA trend filter so signals can be required to align with the higher-timeframe direction.

What you'll see

Blue background — range still forming
Orange background — trade window open, watching
Lime / fuchsia background — cascade armed long / short, waiting for confirmation
Green / red dots — completed sweep cycles
Triangle + label — confirmed entry with SL/TP1/TP2
Live dashboard (top-right) — current status, sweep counts, range levels, and settings at a glance

Timeframe-adaptive
Key lookbacks (ATR window, consolidation window, structure-confirmation window) are set in minutes and auto-convert to bars for whatever intraday timeframe you're on, so the same settings behave consistently across 5m, 15m, or 1H. Built for intraday charts only — a single 4H or Daily bar spans the whole session, so it won't produce anything meaningful there.

Note
This is a visual/analysis tool, not a backtested strategy — it does not simulate trades or produce performance statistics. Use it to study how price behaves around session liquidity, and validate any setup with your own testing before trading it live. Not financial advice.
#gold#xau/usd

## Source Code

````pine
//@version=6
// ============================================================================
// ASLC Visual Dashboard - Asian Session XAUUSD
// Pure visual/analysis tool (not a backtestable strategy) built to show the
// setup FORMING, not just fire after the fact:
//   - Session phases shaded (blue = range forming, orange = watching)
//   - Every completed sweep cycle marked with a dot, count tracked live
//   - Background turns lime/fuchsia the moment a cascade "arms" (qualifies)
//   - Projected SL/TP1 plotted as soon as armed - before BOS even confirms
//   - Live status dashboard explains exactly what state it's in right now
// Timeframe-adaptive: ATR window, consolidation window, and BOS pivot
// confirmation are all set in MINUTES and auto-converted to bars for
// whatever chart timeframe you're on, so the same settings behave
// consistently across 5m/15m/1H. Intraday timeframes only - a single 4H or
// Daily bar spans the whole Asian session, so this isn't meaningful there.
// ============================================================================
indicator("ASLC Visual Dashboard - Asian Session XAUUSD", overlay=true, max_labels_count=500)

// ============================ INPUTS =======================================
grp1 = "Session Windows"
i_tz              = input.string("UTC", "Timezone", group=grp1)
i_phaseAStartHour = input.int(0, "Phase A start hour", minval=0, maxval=23, group=grp1)
i_phaseAStartMin  = input.int(0, "Phase A start min", minval=0, maxval=59, group=grp1)
i_phaseBStartHour = input.int(3, "Phase B start hour (= Phase A end)", minval=0, maxval=23, group=grp1)
i_phaseBStartMin  = input.int(0, "Phase B start min", minval=0, maxval=59, group=grp1)
i_phaseBEndHour   = input.int(7, "Phase B end hour", minval=0, maxval=23, group=grp1)
i_phaseBEndMin    = input.int(0, "Phase B end min", minval=0, maxval=59, group=grp1)

grp2 = "Timeframe-Adaptive Settings (minutes, auto-converted to bars)"
i_atrMinutes           = input.int(210, "ATR window (minutes) - ~14 bars on 15m", group=grp2)
i_consolidationMinutes = input.int(45, "Consolidation window (minutes)", group=grp2)
i_pivotMinutes         = input.int(30, "BOS pivot confirmation window (minutes, each side)", group=grp2)

grp3 = "Cascade / Fade Logic"
i_minSweepsBeforeEntry = input.int(2, "Minimum completed sweeps before arming", minval=1, group=grp3)
i_requireConsolidation = input.bool(true, "Require consolidation before entry", group=grp3)
i_consolidationATR     = input.float(0.6, "Max consolidation range as x ATR", group=grp3)

grp4 = "Risk Projection"
i_slBufferATR = input.float(0.1, "SL buffer x ATR", group=grp4)
i_rr1         = input.float(2.0, "TP1 - R multiple", group=grp4)
i_rr2         = input.float(4.0, "TP2 - R multiple", group=grp4)

grp5 = "HTF Bias Filter"
i_useHTFBias = input.bool(true, "Require 1H EMA trend alignment", group=grp5)
i_ema1Len    = input.int(50, "1H EMA fast", group=grp5)
i_ema2Len    = input.int(200, "1H EMA slow", group=grp5)

grp6 = "Display"
i_showDashboard = input.bool(true, "Show live status dashboard", group=grp6)
i_showProjSLTP  = input.bool(true, "Plot projected SL/TP once armed", group=grp6)

// ============================ TF-ADAPTIVE BAR COUNTS ==========================
secPerBar  = timeframe.in_seconds(timeframe.period)
atrLenBars = math.max(5, math.round(i_atrMinutes * 60 / secPerBar))
consolBars = math.max(1, math.round(i_consolidationMinutes * 60 / secPerBar))
pivotBars  = math.max(1, math.round(i_pivotMinutes * 60 / secPerBar))

// ============================ SESSION WINDOWS =================================
curMOD = hour(time, i_tz) * 60 + minute(time, i_tz)
phaseAStartMOD = i_phaseAStartHour * 60 + i_phaseAStartMin
phaseBStartMOD = i_phaseBStartHour * 60 + i_phaseBStartMin
phaseBEndMOD   = i_phaseBEndHour * 60 + i_phaseBEndMin

inRangeWin = curMOD >= phaseAStartMOD and curMOD < phaseBStartMOD
inTradeWin = curMOD >= phaseBStartMOD and curMOD < phaseBEndMOD

// ============================ PHASE A RANGE TRACKING ===========================
var float rangeHigh   = na
var float rangeLow    = na
var bool  rangeLocked = false

newRangeDay = inRangeWin and not inRangeWin[1]
if newRangeDay
    rangeHigh := high
    rangeLow  := low
    rangeLocked := false

if inRangeWin
    rangeHigh := math.max(nz(rangeHigh, high), high)
    rangeLow  := math.min(nz(rangeLow, low), low)

rangeJustEnded = not inRangeWin and inRangeWin[1]
if rangeJustEnded
    rangeLocked := true

rangeMid = rangeLocked ? (rangeHigh + rangeLow) / 2 : na
atrChart = ta.atr(atrLenBars)

// ============================ HTF BIAS ==========================================
ema1H_fast = request.security(syminfo.tickerid, "60", ta.ema(close, i_ema1Len), lookahead=barmerge.lookahead_off)
ema1H_slow = request.security(syminfo.tickerid, "60", ta.ema(close, i_ema2Len), lookahead=barmerge.lookahead_off)
htfBullish = ema1H_fast > ema1H_slow
htfBearish = ema1H_fast < ema1H_slow

// ============================ MULTI-SWEEP CASCADE ===============================
var bool  belowLow  = false
var bool  aboveHigh = false
var float curExcursionLow  = na
var float curExcursionHigh = na
var int   sweepCountLow  = 0
var int   sweepCountHigh = 0
var float qualifyingSweepLow  = na
var float qualifyingSweepHigh = na
var bool  armedLong  = false
var bool  armedShort = false
var int   barsSinceArmLong  = 0
var int   barsSinceArmShort = 0
var bool  signaledThisDay = false

if newRangeDay
    belowLow := false
    aboveHigh := false
    curExcursionLow := na
    curExcursionHigh := na
    sweepCountLow := 0
    sweepCountHigh := 0
    qualifyingSweepLow := na
    qualifyingSweepHigh := na
    armedLong := false
    armedShort := false
    signaledThisDay := false

if inTradeWin and rangeLocked and low < rangeLow
    belowLow := true
    curExcursionLow := na(curExcursionLow) ? low : math.min(curExcursionLow, low)
if inTradeWin and rangeLocked and high > rangeHigh
    aboveHigh := true
    curExcursionHigh := na(curExcursionHigh) ? high : math.max(curExcursionHigh, high)

completedSweepLow  = belowLow  and close > rangeLow
completedSweepHigh = aboveHigh and close < rangeHigh

var float lockedSLLong  = na
var float lockedSLShort = na

if completedSweepLow
    sweepCountLow += 1
    if sweepCountLow >= i_minSweepsBeforeEntry
        qualifyingSweepLow := curExcursionLow
        lockedSLLong := qualifyingSweepLow - i_slBufferATR * atrChart
        armedLong := true
        barsSinceArmLong := 0
    belowLow := false
    curExcursionLow := na

if completedSweepHigh
    sweepCountHigh += 1
    if sweepCountHigh >= i_minSweepsBeforeEntry
        qualifyingSweepHigh := curExcursionHigh
        lockedSLShort := qualifyingSweepHigh + i_slBufferATR * atrChart
        armedShort := true
        barsSinceArmShort := 0
    aboveHigh := false
    curExcursionHigh := na

if armedLong and not completedSweepLow
    barsSinceArmLong += 1
if armedShort and not completedSweepHigh
    barsSinceArmShort += 1

// Clear armed state at the end of the trade window - an unresolved setup
// should not bleed color into the rest of the day or beyond.
if not inTradeWin and inTradeWin[1]
    armedLong := false
    armedShort := false

// ============================ CONSOLIDATION ======================================
recentRange = ta.highest(high, consolBars) - ta.lowest(low, consolBars)
isConsolidating = recentRange <= i_consolidationATR * atrChart
consolOKLong  = not i_requireConsolidation or (barsSinceArmLong  >= consolBars and isConsolidating)
consolOKShort = not i_requireConsolidation or (barsSinceArmShort >= consolBars and isConsolidating)

// ============================ BOS =================================================
pivHigh = ta.pivothigh(high, pivotBars, pivotBars)
pivLow  = ta.pivotlow(low, pivotBars, pivotBars)

var float pivHighAfterSweep = na
var float pivLowAfterSweep  = na
if completedSweepLow
    pivHighAfterSweep := na
if completedSweepHigh
    pivLowAfterSweep := na
if armedLong and not na(pivHigh)
    pivHighAfterSweep := pivHigh
if armedShort and not na(pivLow)
    pivLowAfterSweep := pivLow

bosLong  = armedLong  and consolOKLong  and not na(pivHighAfterSweep) and close > pivHighAfterSweep
bosShort = armedShort and consolOKShort and not na(pivLowAfterSweep)  and close < pivLowAfterSweep

canSignal   = inTradeWin and not signaledThisDay
longSignal  = canSignal and bosLong  and (not i_useHTFBias or htfBullish)
shortSignal = canSignal and bosShort and (not i_useHTFBias or htfBearish)

if longSignal or shortSignal
    signaledThisDay := true
if longSignal
    armedLong := false
if shortSignal
    armedShort := false

// ============================ PROJECTED SL/TP (live, even pre-entry) ============
projSLLong    = qualifyingSweepLow  - i_slBufferATR * atrChart
projSLShort   = qualifyingSweepHigh + i_slBufferATR * atrChart
projRiskLong  = close - projSLLong
projRiskShort = projSLShort - close
projTP1Long   = close + i_rr1 * projRiskLong
projTP2Long   = close + i_rr2 * projRiskLong
projTP1Short  = close - i_rr1 * projRiskShort
projTP2Short  = close - i_rr2 * projRiskShort

// ============================ VISUALS ============================================
bgcolor(inRangeWin ? color.new(color.blue, 90) : na, title="Phase A - Range Forming")
bgcolor(inTradeWin and not armedLong and not armedShort ? color.new(color.orange, 90) : na, title="Phase B - Watching")
bgcolor(inTradeWin and armedLong  ? color.new(color.lime, 82)    : na, title="Armed Long - Watching for BOS")
bgcolor(inTradeWin and armedShort ? color.new(color.fuchsia, 82) : na, title="Armed Short - Watching for BOS")

plot(rangeLocked ? rangeHigh : na, "Range High", color=color.red,   style=plot.style_linebr, linewidth=1)
plot(rangeLocked ? rangeLow  : na, "Range Low",  color=color.green, style=plot.style_linebr, linewidth=1)
plot(rangeLocked ? rangeMid  : na, "Range Mid",  color=color.gray,  style=plot.style_linebr, linewidth=1)

plotshape(completedSweepLow,  title="Sweep Low",  style=shape.circle, location=location.belowbar, color=color.new(color.green, 20), size=size.tiny)
plotshape(completedSweepHigh, title="Sweep High", style=shape.circle, location=location.abovebar, color=color.new(color.red, 20),   size=size.tiny)

// Only the SL is genuinely fixed once armed (it's set by the qualifying
// sweep's extreme). TP depends on the eventual entry price, which isn't
// known yet - showing it pre-entry would just trail current price
// meaninglessly, so it's only shown in the entry label once real.
plot(i_showProjSLTP and armedLong  and not longSignal  ? lockedSLLong  : na, "Locked SL (Long)",  color=color.new(color.red, 30), style=plot.style_linebr, linewidth=1)
plot(i_showProjSLTP and armedShort and not shortSignal ? lockedSLShort : na, "Locked SL (Short)", color=color.new(color.red, 30), style=plot.style_linebr, linewidth=1)

plotshape(longSignal,  title="LONG ENTRY",  style=shape.triangleup,   location=location.belowbar, color=color.lime,    size=size.normal, text="LONG")
plotshape(shortSignal, title="SHORT ENTRY", style=shape.triangledown, location=location.abovebar, color=color.fuchsia, size=size.normal, text="SHORT")

if longSignal
    label.new(bar_index, low, "LONG\nSL " + str.tostring(projSLLong, format.mintick) + "\nTP1 " + str.tostring(projTP1Long, format.mintick) + "\nTP2 " + str.tostring(projTP2Long, format.mintick),
         style=label.style_label_up, color=color.new(color.lime, 20), textcolor=color.black, size=size.small)
if shortSignal
    label.new(bar_index, high, "SHORT\nSL " + str.tostring(projSLShort, format.mintick) + "\nTP1 " + str.tostring(projTP1Short, format.mintick) + "\nTP2 " + str.tostring(projTP2Short, format.mintick),
         style=label.style_label_down, color=color.new(color.fuchsia, 20), textcolor=color.white, size=size.small)

// ============================ LIVE STATUS DASHBOARD ================================
var int cntRangeDaysSeen = 0
var int cntTotalSweeps   = 0
if rangeJustEnded
    cntRangeDaysSeen += 1
if completedSweepLow or completedSweepHigh
    cntTotalSweeps += 1

statusText = inRangeWin ? "Forming Asian range..." :
     not inTradeWin ? "Outside session" :
     longSignal      ? "LONG ENTRY NOW" :
     shortSignal      ? "SHORT ENTRY NOW" :
     signaledThisDay  ? "Trade taken - done for today" :
     armedLong        ? "Armed LONG - waiting BOS (consol " + str.tostring(math.min(barsSinceArmLong, consolBars)) + "/" + str.tostring(consolBars) + ")" :
     armedShort       ? "Armed SHORT - waiting BOS (consol " + str.tostring(math.min(barsSinceArmShort, consolBars)) + "/" + str.tostring(consolBars) + ")" :
     "Watching for sweep #" + str.tostring(i_minSweepsBeforeEntry)

if i_showDashboard and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 15), border_width=1, border_color=color.gray)
    table.cell(dash, 0, 0, "Status", text_color=color.white, text_halign=text.align_left)
    table.cell(dash, 1, 0, statusText, text_color=color.yellow)
    table.cell(dash, 0, 1, "Sweeps today (low/high)", text_color=color.white, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(sweepCountLow) + " / " + str.tostring(sweepCountHigh), text_color=color.white)
    table.cell(dash, 0, 2, "Range high / low", text_color=color.white, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(rangeHigh, format.mintick) + " / " + str.tostring(rangeLow, format.mintick), text_color=color.white)
    table.cell(dash, 0, 3, "TF bars: ATR/Consol/Pivot", text_color=color.white, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(atrLenBars) + " / " + str.tostring(consolBars) + " / " + str.tostring(pivotBars), text_color=color.white)
    table.cell(dash, 0, 4, "HTF filter", text_color=color.white, text_halign=text.align_left)
    table.cell(dash, 1, 4, i_useHTFBias ? "ON" : "OFF", text_color=color.white)
    table.cell(dash, 0, 5, "Chart TF", text_color=color.white, text_halign=text.align_left)
    table.cell(dash, 1, 5, timeframe.period, text_color=color.white)
    table.cell(dash, 0, 6, "Range days seen (loaded)", text_color=color.white, text_halign=text.align_left)
    table.cell(dash, 1, 6, str.tostring(cntRangeDaysSeen), text_color=color.white)
    table.cell(dash, 0, 7, "Total sweeps seen (loaded)", text_color=color.white, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(cntTotalSweeps), text_color=color.white)

// ============================ ALERTS ================================================
alertcondition(armedLong  and not armedLong[1],  title="ASLC Armed Long",  message="ASLC: cascade qualified, watching for LONG BOS")
alertcondition(armedShort and not armedShort[1], title="ASLC Armed Short", message="ASLC: cascade qualified, watching for SHORT BOS")
alertcondition(longSignal,  title="ASLC Entry Long",  message="ASLC: LONG entry confirmed")
alertcondition(shortSignal, title="ASLC Entry Short", message="ASLC: SHORT entry confirmed")

// ============================ NOTES ==================================================
// - Lime background = cascade armed long, watching for the structure break;
//   fuchsia = armed short. This is the "setup is building" signal - the
//   projected SL/TP lines (dotted) appear as soon as this triggers, before
//   the actual entry triangle prints.
// - Intraday timeframes only (this was built and tested on 15m). On very
//   low timeframes (1m) the pivot/consolidation windows may need shorter
//   minute settings since 30-45 min of 1m bars is a lot of lag.
// - For actual backtesting/equity curves, keep using the ASLC v4 strategy
//   script - this dashboard is for reading price action live, not testing.
````
