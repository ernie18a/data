# 1H Strong Engulfing Manual Companion

- url: https://www.tradingview.com/script/3M1PkO90/
- type: indicator
- pine_id: PUB;0412421b78e6416fb6fdbec1a7308df7
- version: 1.0

## Description

The 1H Strong Engulfing Manual Companion is a price action indicator designed to detect high-probability engulfing setups on the 1H timeframe and assist with structured, discretionary trade execution.

⚠️ Work in Progress: This script is still under active development. Features, logic, and visuals may change over time.

⸻

Overview

This indicator identifies bullish and bearish engulfing patterns on the 1H chart and combines them with multiple optional filters to improve signal quality.

It can also be used on lower timeframes while relying on confirmed 1H signals, helping you align entries with higher timeframe structure.

⸻

Key Features

• Advanced Engulfing Detection
	•	Strict or loose engulfing logic
	•	Optional wick sweep (liquidity grab)
	•	ATR-based candle size filter
	•	Relative body size filter

• Multi-Layer Filtering System
	•	1H EMA trend filter
	•	Optional Daily EMA bias
	•	EMA slope (trend strength)
	•	Max distance to EMA
	•	VWAP filter + distance control
	•	Session and weekday filters

• Multi-Timeframe Support
	•	Uses confirmed 1H data on lower timeframes
	•	Designed to avoid repainting

• Trend Phase Control
	•	Optional: limit to one setup per trend phase
	•	Reset on trend shift or opposite signal
→ Helps reduce overtrading

⸻

Trade Planning Support (Manual)

This is not an auto-trading strategy, but a companion tool for manual execution:
	•	Breakout or Pullback entry modes
	•	Automatic calculation of:
	•	Entry
	•	Stop Loss (candle-based or ATR-based)
	•	Take Profit (R:R based)
	•	Break-even trigger
	•	Visualization of pending and active trade levels

⸻

Visuals & Alerts
	•	Clear bullish/bearish signal markers
	•	Optional display of:
	•	Entry / SL / TP / BE levels
	•	Trend EMAs and VWAP
	•	Alerts for:
	•	Signal detection
	•	Entry trigger events

⸻

Purpose

The goal of this indicator is to help traders:
	•	Focus on high-quality engulfing setups
	•	Trade in alignment with trend and structure
	•	Execute trades with clear, predefined levels

⸻

Status

This script is still evolving. Planned improvements may include:
	•	Further refinement of filters
	•	Additional entry/management logic
	•	Enhanced visualization and usability

## Source Code

````pine
//@version=6
indicator("1H Strong Engulfing Manual Companion", overlay=true, max_labels_count=200, max_lines_count=200)

//--------------------------------------------------
// Inputs
//--------------------------------------------------
groupPattern = "Pattern"
strictBodyEngulf = input.bool(true, "Strict body engulf", group=groupPattern)
useStrongEngulf  = input.bool(true, "Require wick sweep", group=groupPattern)

groupFilters = "Filters"
useATRFilter      = input.bool(true, "Use ATR filter", group=groupFilters)
atrLen            = input.int(14, "ATR length", minval=1, group=groupFilters)
atrMultiplier     = input.float(0.8, "Min body size in ATR", minval=0.1, step=0.1, group=groupFilters)

useBodyFactor     = input.bool(true, "Use body-vs-previous filter", group=groupFilters)
bodyFactor        = input.float(1.2, "Current body >= previous body *", minval=0.1, step=0.1, group=groupFilters)

use1HTrendFilter   = input.bool(true, "Use 1H EMA filter", group=groupFilters)
ema1HLen           = input.int(50, "1H EMA length", minval=1, group=groupFilters)

useDailyBiasFilter = input.bool(false, "Use Daily EMA bias filter", group=groupFilters)
emaDailyLen        = input.int(200, "Daily EMA length", minval=1, group=groupFilters)

useEMASlopeFilter    = input.bool(true, "Use 1H EMA slope filter", group=groupFilters)
emaSlopeLookback     = input.int(3, "EMA slope lookback bars", minval=1, group=groupFilters)

useMaxDistanceFilter = input.bool(true, "Use max distance to 1H EMA filter", group=groupFilters)
maxDistancePct       = input.float(1.5, "Max distance to 1H EMA (%)", minval=0.1, step=0.1, group=groupFilters)

useVWAPFilter         = input.bool(false, "Use VWAP filter", group=groupFilters)
vwapMode              = input.string("1H Session VWAP", "VWAP mode", options=["1H Session VWAP", "Current TF Session VWAP"], group=groupFilters)
useVWAPDistanceFilter = input.bool(false, "Use max distance to VWAP filter", group=groupFilters)
maxVWAPPct            = input.float(1.5, "Max distance to VWAP (%)", minval=0.1, step=0.1, group=groupFilters)

groupExecution = "Execution"
allowOn1HChart   = input.bool(true, "Allow signals on 1H chart", group=groupExecution)
allowOnLowerTF   = input.bool(true, "Allow signals below 1H", group=groupExecution)
longEnabled      = input.bool(true, "Enable longs", group=groupExecution)
shortEnabled     = input.bool(true, "Enable shorts", group=groupExecution)
cancelOpposite   = input.bool(true, "Cancel opposite pending setup", group=groupExecution)
expireAfterBars  = input.int(12, "Pending setup expires after bars", minval=1, group=groupExecution)
resetActiveLevels = input.bool(false, "Reset active levels", group=groupExecution)

useSessionFilter = input.bool(false, "Use session filter", group=groupExecution)
sessionInput     = input.session("0800-2200", "Allowed session", group=groupExecution)

useWeekdayFilter = input.bool(false, "Use weekday filter", group=groupExecution)
allowMon = input.bool(true, "Mon", group=groupExecution, inline="wd1")
allowTue = input.bool(true, "Tue", group=groupExecution, inline="wd1")
allowWed = input.bool(true, "Wed", group=groupExecution, inline="wd1")
allowThu = input.bool(true, "Thu", group=groupExecution, inline="wd1")
allowFri = input.bool(true, "Fri", group=groupExecution, inline="wd1")
allowSat = input.bool(true, "Sat", group=groupExecution, inline="wd2")
allowSun = input.bool(true, "Sun", group=groupExecution, inline="wd2")

useTrendPhaseFilter      = input.bool(true, "Use one setup per trend phase", group=groupExecution)
resetPhaseOnOppositeSignal = input.bool(true, "Reset phase lock on opposite signal", group=groupExecution)

entryMode = input.string("Breakout", "Entry mode", options=["Breakout", "Pullback"], group=groupExecution)
pullbackPct = input.float(50.0, "Pullback entry (%)", minval=1.0, maxval=99.0, step=1.0, group=groupExecution)

groupRisk = "Manual Trade Levels"
slMode          = input.string("Engulfing Candle", "Stop Loss Mode", options=["Engulfing Candle", "ATR"], group=groupRisk)
slBufferPercent = input.float(0.05, "SL buffer %", minval=0.0, step=0.01, group=groupRisk)
atrStopMult     = input.float(1.0, "ATR stop multiplier", minval=0.1, step=0.1, group=groupRisk)
rr              = input.float(2.0, "Risk / Reward", minval=0.1, step=0.1, group=groupRisk)

showBreakEven   = input.bool(true, "Show break-even trigger", group=groupRisk)
breakEvenRR     = input.float(1.0, "Break-even trigger in R", minval=0.1, step=0.1, group=groupRisk)

groupDisplay = "Display"
showBullish       = input.bool(true, "Show bullish markers", group=groupDisplay)
showBearish       = input.bool(true, "Show bearish markers", group=groupDisplay)
showLabels        = input.bool(true, "Show labels", group=groupDisplay)
showFilterLines   = input.bool(true, "Show filter EMAs", group=groupDisplay)
showPendingLevels = input.bool(true, "Show pending entry/stop/TP", group=groupDisplay)
showActiveLevels  = input.bool(true, "Show active entry/stop/TP", group=groupDisplay)
showTriggeredInfo = input.bool(true, "Show triggered labels", group=groupDisplay)
colorBars         = input.bool(false, "Color signal bars", group=groupDisplay)
bgHighlight       = input.bool(false, "Highlight signal bars", group=groupDisplay)
levelLengthBars   = input.int(20, "Level length (bars)", minval=1, group=groupDisplay)
showVWAPLine = input.bool(false, "Show VWAP line", group=groupDisplay)

groupColors = "Colors"
bullColor   = input.color(color.lime, "Bullish color", group=groupColors)
bearColor   = input.color(color.red, "Bearish color", group=groupColors)
ema1HColor  = input.color(color.orange, "1H EMA color", group=groupColors)
emaDColor   = input.color(color.blue, "Daily EMA color", group=groupColors)
entryColor  = input.color(color.blue, "Entry line color", group=groupColors)
stopColor   = input.color(color.red, "Stop line color", group=groupColors)
tpColor     = input.color(color.green, "Take profit line color", group=groupColors)
beColor     = input.color(color.yellow, "Break-even trigger color", group=groupColors)

//--------------------------------------------------
// Timeframe guard
//--------------------------------------------------
chartSec = timeframe.in_seconds()
tf1hSec = timeframe.in_seconds("60")

is1H = not na(chartSec) and chartSec == tf1hSec
isLowerThan1H = not na(chartSec) and chartSec < tf1hSec

allowSignals = false
if allowOn1HChart and is1H
    allowSignals := true
else if allowOnLowerTF and isLowerThan1H
    allowSignals := true

//--------------------------------------------------
// Session / weekday filter
//--------------------------------------------------
inSession = not na(time(timeframe.period, sessionInput))

weekdayAllowed = false
if dayofweek == dayofweek.monday
    weekdayAllowed := allowMon
else if dayofweek == dayofweek.tuesday
    weekdayAllowed := allowTue
else if dayofweek == dayofweek.wednesday
    weekdayAllowed := allowWed
else if dayofweek == dayofweek.thursday
    weekdayAllowed := allowThu
else if dayofweek == dayofweek.friday
    weekdayAllowed := allowFri
else if dayofweek == dayofweek.saturday
    weekdayAllowed := allowSat
else if dayofweek == dayofweek.sunday
    weekdayAllowed := allowSun

sessionOk = not useSessionFilter or inSession
weekdayOk = not useWeekdayFilter or weekdayAllowed

allowSignals := allowSignals and sessionOk and weekdayOk

//--------------------------------------------------
// Pattern helpers
//--------------------------------------------------
f_bull_engulf(_strict, _strong, _useAtr, _atrLen, _atrMult, _useBodyFactor, _bodyFactor) =>
    prevBear = close[1] < open[1]
    currBull = close > open

    body = math.abs(close - open)
    prevBody = math.abs(close[1] - open[1])

    strictOk = open <= close[1] and close >= open[1]
    looseOk  = close >= open[1] and close > close[1]
    bodyEngulf = _strict ? strictOk : looseOk

    sweepOk = low < low[1]

    atrVal = ta.atr(_atrLen)
    atrOk = not _useAtr or (body >= atrVal * _atrMult)

    prevBodyOk = not _useBodyFactor or (body >= prevBody * _bodyFactor)

    baseCond = prevBear and currBull and bodyEngulf and atrOk and prevBodyOk
    _strong ? (baseCond and sweepOk) : baseCond

f_bear_engulf(_strict, _strong, _useAtr, _atrLen, _atrMult, _useBodyFactor, _bodyFactor) =>
    prevBull = close[1] > open[1]
    currBear = close < open

    body = math.abs(close - open)
    prevBody = math.abs(close[1] - open[1])

    strictOk = open >= close[1] and close <= open[1]
    looseOk  = close <= open[1] and close < close[1]
    bodyEngulf = _strict ? strictOk : looseOk

    sweepOk = high > high[1]

    atrVal = ta.atr(_atrLen)
    atrOk = not _useAtr or (body >= atrVal * _atrMult)

    prevBodyOk = not _useBodyFactor or (body >= prevBody * _bodyFactor)

    baseCond = prevBull and currBear and bodyEngulf and atrOk and prevBodyOk
    _strong ? (baseCond and sweepOk) : baseCond

//--------------------------------------------------
// HTF confirmed values for lower TF charts
//--------------------------------------------------
bull1H_confirmed = request.security(
    syminfo.tickerid, "60",
    f_bull_engulf(strictBodyEngulf, useStrongEngulf, useATRFilter, atrLen, atrMultiplier, useBodyFactor, bodyFactor)[1],
    lookahead=barmerge.lookahead_on
)

bear1H_confirmed = request.security(
    syminfo.tickerid, "60",
    f_bear_engulf(strictBodyEngulf, useStrongEngulf, useATRFilter, atrLen, atrMultiplier, useBodyFactor, bodyFactor)[1],
    lookahead=barmerge.lookahead_on
)

ema1H_confirmed = request.security(
    syminfo.tickerid, "60",
    ta.ema(close, ema1HLen)[1],
    lookahead=barmerge.lookahead_on
)

ema1H_past_confirmed = request.security(
    syminfo.tickerid, "60",
    ta.ema(close, ema1HLen)[1 + emaSlopeLookback],
    lookahead=barmerge.lookahead_on
)

emaDaily_confirmed = request.security(
    syminfo.tickerid, "D",
    ta.ema(close, emaDailyLen)[1],
    lookahead=barmerge.lookahead_on
)

h1CloseConfirmed = request.security(
    syminfo.tickerid, "60",
    close[1],
    lookahead=barmerge.lookahead_on
)

h1LowConfirmed = request.security(
    syminfo.tickerid, "60",
    low[1],
    lookahead=barmerge.lookahead_on
)

h1HighConfirmed = request.security(
    syminfo.tickerid, "60",
    high[1],
    lookahead=barmerge.lookahead_on
)

h1AtrConfirmed = request.security(
    syminfo.tickerid, "60",
    ta.atr(atrLen)[1],
    lookahead=barmerge.lookahead_on
)

h1TimeConfirmed = request.security(
    syminfo.tickerid, "60",
    time[1],
    lookahead=barmerge.lookahead_on
)

newConfirmedH1 = ta.change(h1TimeConfirmed) != 0

//--------------------------------------------------
// Local 1H values
//--------------------------------------------------
bull1H_local_raw = f_bull_engulf(strictBodyEngulf, useStrongEngulf, useATRFilter, atrLen, atrMultiplier, useBodyFactor, bodyFactor)
bear1H_local_raw = f_bear_engulf(strictBodyEngulf, useStrongEngulf, useATRFilter, atrLen, atrMultiplier, useBodyFactor, bodyFactor)

bull1H_local = bull1H_local_raw and barstate.isconfirmed
bear1H_local = bear1H_local_raw and barstate.isconfirmed

ema1H_local = ta.ema(close, ema1HLen)
ema1H_past_local = ta.ema(close, ema1HLen)[emaSlopeLookback]
atr1H_local = ta.atr(atrLen)

dailyBiasLine = emaDaily_confirmed

//--------------------------------------------------
// VWAP values
//--------------------------------------------------
vwapCurrentTF = ta.vwap(hlc3)

vwap1H_confirmed = request.security(
    syminfo.tickerid,
    "60",
    ta.vwap(hlc3)[1],
    lookahead=barmerge.lookahead_on
)

float vwapForFilter = na
float priceForVWAP = na

if is1H
    priceForVWAP := close
    vwapForFilter := ta.vwap(hlc3)
else
    if vwapMode == "Current TF Session VWAP"
        priceForVWAP := close
        vwapForFilter := vwapCurrentTF
    else
        priceForVWAP := h1CloseConfirmed
        vwapForFilter := vwap1H_confirmed

//--------------------------------------------------
// Filters
//--------------------------------------------------
bullTrendOk = false
bearTrendOk = false

bullSlopeOk = false
bearSlopeOk = false
bullDistanceOk = false
bearDistanceOk = false

bullVWAPOk = false
bearVWAPOk = false
bullVWAPDistanceOk = false
bearVWAPDistanceOk = false

if is1H
    bullTrendOk := (not use1HTrendFilter or close > ema1H_local) and (not useDailyBiasFilter or close > dailyBiasLine)
    bearTrendOk := (not use1HTrendFilter or close < ema1H_local) and (not useDailyBiasFilter or close < dailyBiasLine)

    bullSlopeOk := not useEMASlopeFilter or (ema1H_local > ema1H_past_local)
    bearSlopeOk := not useEMASlopeFilter or (ema1H_local < ema1H_past_local)

    bullDistanceOk := not useMaxDistanceFilter or (ema1H_local != 0 and math.abs(close - ema1H_local) / ema1H_local * 100 <= maxDistancePct)
    bearDistanceOk := not useMaxDistanceFilter or (ema1H_local != 0 and math.abs(close - ema1H_local) / ema1H_local * 100 <= maxDistancePct)
else
    bullTrendOk := (not use1HTrendFilter or h1CloseConfirmed > ema1H_confirmed) and (not useDailyBiasFilter or h1CloseConfirmed > dailyBiasLine)
    bearTrendOk := (not use1HTrendFilter or h1CloseConfirmed < ema1H_confirmed) and (not useDailyBiasFilter or h1CloseConfirmed < dailyBiasLine)

    bullSlopeOk := not useEMASlopeFilter or (ema1H_confirmed > ema1H_past_confirmed)
    bearSlopeOk := not useEMASlopeFilter or (ema1H_confirmed < ema1H_past_confirmed)

    bullDistanceOk := not useMaxDistanceFilter or (ema1H_confirmed != 0 and math.abs(h1CloseConfirmed - ema1H_confirmed) / ema1H_confirmed * 100 <= maxDistancePct)
    bearDistanceOk := not useMaxDistanceFilter or (ema1H_confirmed != 0 and math.abs(h1CloseConfirmed - ema1H_confirmed) / ema1H_confirmed * 100 <= maxDistancePct)

bullVWAPOk := not useVWAPFilter or (not na(vwapForFilter) and priceForVWAP > vwapForFilter)
bearVWAPOk := not useVWAPFilter or (not na(vwapForFilter) and priceForVWAP < vwapForFilter)

bullVWAPDistanceOk := not useVWAPDistanceFilter or (not na(vwapForFilter) and vwapForFilter != 0 and math.abs(priceForVWAP - vwapForFilter) / vwapForFilter * 100 <= maxVWAPPct)
bearVWAPDistanceOk := not useVWAPDistanceFilter or (not na(vwapForFilter) and vwapForFilter != 0 and math.abs(priceForVWAP - vwapForFilter) / vwapForFilter * 100 <= maxVWAPPct)

bullTrendOk := bullTrendOk and bullSlopeOk and bullDistanceOk and bullVWAPOk and bullVWAPDistanceOk
bearTrendOk := bearTrendOk and bearSlopeOk and bearDistanceOk and bearVWAPOk and bearVWAPDistanceOk

//--------------------------------------------------
// Trend phase logic
//--------------------------------------------------
bullPhase = false
bearPhase = false

if is1H
    bullPhase := close > ema1H_local and ema1H_local > ema1H_past_local
    bearPhase := close < ema1H_local and ema1H_local < ema1H_past_local
else
    bullPhase := h1CloseConfirmed > ema1H_confirmed and ema1H_confirmed > ema1H_past_confirmed
    bearPhase := h1CloseConfirmed < ema1H_confirmed and ema1H_confirmed < ema1H_past_confirmed

var bool bullPhaseTriggered = false
var bool bearPhaseTriggered = false
var int phaseState = 0   // 1 = bull, -1 = bear, 0 = neutral

currentPhase = 0
if bullPhase
    currentPhase := 1
else if bearPhase
    currentPhase := -1
else
    currentPhase := 0

phaseChanged = currentPhase != phaseState

if phaseChanged
    phaseState := currentPhase
    bullPhaseTriggered := false
    bearPhaseTriggered := false

//--------------------------------------------------
// Final signals
//--------------------------------------------------
bullSignal = false
bearSignal = false

if is1H
    bullSignal := allowSignals and bullTrendOk and bull1H_local and longEnabled
    bearSignal := allowSignals and bearTrendOk and bear1H_local and shortEnabled
else
    bullSignal := allowSignals and bullTrendOk and newConfirmedH1 and bull1H_confirmed and longEnabled
    bearSignal := allowSignals and bearTrendOk and newConfirmedH1 and bear1H_confirmed and shortEnabled

if useTrendPhaseFilter
    bullSignal := bullSignal and not bullPhaseTriggered
    bearSignal := bearSignal and not bearPhaseTriggered

if bullSignal and useTrendPhaseFilter
    bullPhaseTriggered := true
    if resetPhaseOnOppositeSignal
        bearPhaseTriggered := false

if bearSignal and useTrendPhaseFilter
    bearPhaseTriggered := true
    if resetPhaseOnOppositeSignal
        bullPhaseTriggered := false

//--------------------------------------------------
// Visual signal markers
//--------------------------------------------------
plotshape(showBullish and bullSignal, title="Bullish Signal", style=shape.labelup, location=location.belowbar, color=bullColor, text="Bull", textcolor=color.white, size=size.small)
plotshape(showBearish and bearSignal, title="Bearish Signal", style=shape.labeldown, location=location.abovebar, color=bearColor, text="Bear", textcolor=color.white, size=size.small)

if showLabels and bullSignal
    label.new(bar_index, low, is1H ? "1H Bull Engulf" : "1H Bull Engulf (confirmed)", style=label.style_label_up, color=bullColor, textcolor=color.white, size=size.small)

if showLabels and bearSignal
    label.new(bar_index, high, is1H ? "1H Bear Engulf" : "1H Bear Engulf (confirmed)", style=label.style_label_down, color=bearColor, textcolor=color.white, size=size.small)

barcolor(colorBars ? (bullSignal ? bullColor : bearSignal ? bearColor : na) : na)
bgcolor(bgHighlight ? (bullSignal ? color.new(bullColor, 85) : bearSignal ? color.new(bearColor, 85) : na) : na)

plot(showFilterLines and use1HTrendFilter ? (is1H ? ema1H_local : ema1H_confirmed) : na, title="1H EMA", color=ema1HColor, linewidth=2)
plot(showFilterLines and useDailyBiasFilter ? dailyBiasLine : na, title="Daily EMA", color=emaDColor, linewidth=2)

plot(showVWAPLine ? vwapForFilter : na, title="VWAP Filter", color=color.aqua, linewidth=2)
//--------------------------------------------------
// Pending / active setup storage
//--------------------------------------------------
var bool pendingLong = false
var bool pendingShort = false
var bool activeLong = false
var bool activeShort = false

var float longEntryPrice = na
var float shortEntryPrice = na
var float longStopPrice = na
var float shortStopPrice = na
var float longTakeProfit = na
var float shortTakeProfit = na
var float longBreakEvenTrigger = na
var float shortBreakEvenTrigger = na

var float activeLongEntry = na
var float activeShortEntry = na
var float activeLongStop = na
var float activeShortStop = na
var float activeLongTP = na
var float activeShortTP = na
var float activeLongBE = na
var float activeShortBE = na

var int longSignalBar = na
var int shortSignalBar = na

// line objects
var line pendingLongEntryLine = na
var line pendingLongStopLine = na
var line pendingLongTPLine = na
var line pendingLongBELine = na

var line pendingShortEntryLine = na
var line pendingShortStopLine = na
var line pendingShortTPLine = na
var line pendingShortBELine = na

var line activeLongEntryLine = na
var line activeLongStopLine = na
var line activeLongTPLine = na
var line activeLongBELine = na

var line activeShortEntryLine = na
var line activeShortStopLine = na
var line activeShortTPLine = na
var line activeShortBELine = na

//--------------------------------------------------
// Helpers for fixed-length level lines
//--------------------------------------------------
f_draw_level(_existingLine, _price, _bars, _col, _width) =>
    line result = _existingLine

    if not na(result)
        line.delete(result)

    result := line.new(
         x1=bar_index,
         y1=_price,
         x2=bar_index + _bars,
         y2=_price,
         xloc=xloc.bar_index,
         extend=extend.none,
         color=_col,
         width=_width
     )

    result

f_delete_level(_existingLine) =>
    line result = na

    if not na(_existingLine)
        line.delete(_existingLine)

    result

//--------------------------------------------------
// Manual reset of active levels
//--------------------------------------------------
if resetActiveLevels
    activeLong := false
    activeShort := false
    activeLongEntry := na
    activeShortEntry := na
    activeLongStop := na
    activeShortStop := na
    activeLongTP := na
    activeShortTP := na
    activeLongBE := na
    activeShortBE := na

    activeLongEntryLine := f_delete_level(activeLongEntryLine)
    activeLongStopLine  := f_delete_level(activeLongStopLine)
    activeLongTPLine    := f_delete_level(activeLongTPLine)
    activeLongBELine    := f_delete_level(activeLongBELine)

    activeShortEntryLine := f_delete_level(activeShortEntryLine)
    activeShortStopLine  := f_delete_level(activeShortStopLine)
    activeShortTPLine    := f_delete_level(activeShortTPLine)
    activeShortBELine    := f_delete_level(activeShortBELine)

//--------------------------------------------------
// Build pending manual setups
//--------------------------------------------------
if bullSignal
    signalHigh = is1H ? high : h1HighConfirmed
    signalLow  = is1H ? low  : h1LowConfirmed
    signalAtr  = is1H ? atr1H_local : h1AtrConfirmed

    pendingLong := true
    longSignalBar := bar_index

    signalRange = signalHigh - signalLow
    if entryMode == "Breakout"
        longEntryPrice := signalHigh
    else
        longEntryPrice := signalHigh - signalRange * (pullbackPct / 100.0)

    if slMode == "Engulfing Candle"
        longStopPrice := signalLow * (1.0 - slBufferPercent / 100.0)
    else
        longStopPrice := signalHigh - signalAtr * atrStopMult

    longRiskTmp = longEntryPrice - longStopPrice
    if longRiskTmp > 0
        longTakeProfit := longEntryPrice + longRiskTmp * rr
        longBreakEvenTrigger := longEntryPrice + longRiskTmp * breakEvenRR

        if showPendingLevels
            pendingLongEntryLine := f_draw_level(pendingLongEntryLine, longEntryPrice, levelLengthBars, entryColor, 2)
            pendingLongStopLine  := f_draw_level(pendingLongStopLine, longStopPrice, levelLengthBars, stopColor, 2)
            pendingLongTPLine    := f_draw_level(pendingLongTPLine, longTakeProfit, levelLengthBars, tpColor, 2)
            if showBreakEven
                pendingLongBELine := f_draw_level(pendingLongBELine, longBreakEvenTrigger, levelLengthBars, beColor, 1)
    else
        pendingLong := false
        longEntryPrice := na
        longStopPrice := na
        longTakeProfit := na
        longBreakEvenTrigger := na
        longSignalBar := na

    if cancelOpposite
        pendingShort := false
        shortEntryPrice := na
        shortStopPrice := na
        shortTakeProfit := na
        shortBreakEvenTrigger := na
        shortSignalBar := na
        pendingShortEntryLine := f_delete_level(pendingShortEntryLine)
        pendingShortStopLine  := f_delete_level(pendingShortStopLine)
        pendingShortTPLine    := f_delete_level(pendingShortTPLine)
        pendingShortBELine    := f_delete_level(pendingShortBELine)

        activeShort := false
        activeShortEntry := na
        activeShortStop := na
        activeShortTP := na
        activeShortBE := na
        activeShortEntryLine := f_delete_level(activeShortEntryLine)
        activeShortStopLine  := f_delete_level(activeShortStopLine)
        activeShortTPLine    := f_delete_level(activeShortTPLine)
        activeShortBELine    := f_delete_level(activeShortBELine)

if bearSignal
    signalHigh = is1H ? high : h1HighConfirmed
    signalLow  = is1H ? low  : h1LowConfirmed
    signalAtr  = is1H ? atr1H_local : h1AtrConfirmed

    pendingShort := true
    shortSignalBar := bar_index

    signalRange = signalHigh - signalLow
    if entryMode == "Breakout"
        shortEntryPrice := signalLow
    else
        shortEntryPrice := signalLow + signalRange * (pullbackPct / 100.0)

    if slMode == "Engulfing Candle"
        shortStopPrice := signalHigh * (1.0 + slBufferPercent / 100.0)
    else
        shortStopPrice := signalLow + signalAtr * atrStopMult

    shortRiskTmp = shortStopPrice - shortEntryPrice
    if shortRiskTmp > 0
        shortTakeProfit := shortEntryPrice - shortRiskTmp * rr
        shortBreakEvenTrigger := shortEntryPrice - shortRiskTmp * breakEvenRR

        if showPendingLevels
            pendingShortEntryLine := f_draw_level(pendingShortEntryLine, shortEntryPrice, levelLengthBars, entryColor, 2)
            pendingShortStopLine  := f_draw_level(pendingShortStopLine, shortStopPrice, levelLengthBars, stopColor, 2)
            pendingShortTPLine    := f_draw_level(pendingShortTPLine, shortTakeProfit, levelLengthBars, tpColor, 2)
            if showBreakEven
                pendingShortBELine := f_draw_level(pendingShortBELine, shortBreakEvenTrigger, levelLengthBars, beColor, 1)
    else
        pendingShort := false
        shortEntryPrice := na
        shortStopPrice := na
        shortTakeProfit := na
        shortBreakEvenTrigger := na
        shortSignalBar := na

    if cancelOpposite
        pendingLong := false
        longEntryPrice := na
        longStopPrice := na
        longTakeProfit := na
        longBreakEvenTrigger := na
        longSignalBar := na
        pendingLongEntryLine := f_delete_level(pendingLongEntryLine)
        pendingLongStopLine  := f_delete_level(pendingLongStopLine)
        pendingLongTPLine    := f_delete_level(pendingLongTPLine)
        pendingLongBELine    := f_delete_level(pendingLongBELine)

        activeLong := false
        activeLongEntry := na
        activeLongStop := na
        activeLongTP := na
        activeLongBE := na
        activeLongEntryLine := f_delete_level(activeLongEntryLine)
        activeLongStopLine  := f_delete_level(activeLongStopLine)
        activeLongTPLine    := f_delete_level(activeLongTPLine)
        activeLongBELine    := f_delete_level(activeLongBELine)

//--------------------------------------------------
// Expire pending setups
//--------------------------------------------------
if pendingLong and not na(longSignalBar) and bar_index - longSignalBar > expireAfterBars
    pendingLong := false
    longEntryPrice := na
    longStopPrice := na
    longTakeProfit := na
    longBreakEvenTrigger := na
    longSignalBar := na
    pendingLongEntryLine := f_delete_level(pendingLongEntryLine)
    pendingLongStopLine  := f_delete_level(pendingLongStopLine)
    pendingLongTPLine    := f_delete_level(pendingLongTPLine)
    pendingLongBELine    := f_delete_level(pendingLongBELine)

if pendingShort and not na(shortSignalBar) and bar_index - shortSignalBar > expireAfterBars
    pendingShort := false
    shortEntryPrice := na
    shortStopPrice := na
    shortTakeProfit := na
    shortBreakEvenTrigger := na
    shortSignalBar := na
    pendingShortEntryLine := f_delete_level(pendingShortEntryLine)
    pendingShortStopLine  := f_delete_level(pendingShortStopLine)
    pendingShortTPLine    := f_delete_level(pendingShortTPLine)
    pendingShortBELine    := f_delete_level(pendingShortBELine)

//--------------------------------------------------
// Trigger checks for manual execution
//--------------------------------------------------
longTriggered = false
shortTriggered = false

if entryMode == "Breakout"
    longTriggered := pendingLong and not na(longEntryPrice) and high >= longEntryPrice
    shortTriggered := pendingShort and not na(shortEntryPrice) and low <= shortEntryPrice
else
    longTriggered := pendingLong and not na(longEntryPrice) and low <= longEntryPrice
    shortTriggered := pendingShort and not na(shortEntryPrice) and high >= shortEntryPrice

if longTriggered
    if showTriggeredInfo
        label.new(bar_index, high, "Long " + entryMode, style=label.style_label_down, color=entryColor, textcolor=color.white, size=size.small)

    activeLong := true
    activeShort := false

    activeLongEntry := longEntryPrice
    activeLongStop := longStopPrice
    activeLongTP := longTakeProfit
    activeLongBE := longBreakEvenTrigger

    pendingLong := false
    longSignalBar := na

    pendingLongEntryLine := f_delete_level(pendingLongEntryLine)
    pendingLongStopLine  := f_delete_level(pendingLongStopLine)
    pendingLongTPLine    := f_delete_level(pendingLongTPLine)
    pendingLongBELine    := f_delete_level(pendingLongBELine)

    if showActiveLevels
        activeLongEntryLine := f_draw_level(activeLongEntryLine, activeLongEntry, levelLengthBars, entryColor, 2)
        activeLongStopLine  := f_draw_level(activeLongStopLine, activeLongStop, levelLengthBars, stopColor, 2)
        activeLongTPLine    := f_draw_level(activeLongTPLine, activeLongTP, levelLengthBars, tpColor, 2)
        if showBreakEven
            activeLongBELine := f_draw_level(activeLongBELine, activeLongBE, levelLengthBars, beColor, 1)

if shortTriggered
    if showTriggeredInfo
        label.new(bar_index, low, "Short " + entryMode, style=label.style_label_up, color=entryColor, textcolor=color.white, size=size.small)

    activeShort := true
    activeLong := false

    activeShortEntry := shortEntryPrice
    activeShortStop := shortStopPrice
    activeShortTP := shortTakeProfit
    activeShortBE := shortBreakEvenTrigger

    pendingShort := false
    shortSignalBar := na

    pendingShortEntryLine := f_delete_level(pendingShortEntryLine)
    pendingShortStopLine  := f_delete_level(pendingShortStopLine)
    pendingShortTPLine    := f_delete_level(pendingShortTPLine)
    pendingShortBELine    := f_delete_level(pendingShortBELine)

    if showActiveLevels
        activeShortEntryLine := f_draw_level(activeShortEntryLine, activeShortEntry, levelLengthBars, entryColor, 2)
        activeShortStopLine  := f_draw_level(activeShortStopLine, activeShortStop, levelLengthBars, stopColor, 2)
        activeShortTPLine    := f_draw_level(activeShortTPLine, activeShortTP, levelLengthBars, tpColor, 2)
        if showBreakEven
            activeShortBELine := f_draw_level(activeShortBELine, activeShortBE, levelLengthBars, beColor, 1)

//--------------------------------------------------
// Alerts
//--------------------------------------------------
alertcondition(bullSignal, "Bullish signal", "Bullish 1H engulfing setup detected")
alertcondition(bearSignal, "Bearish signal", "Bearish 1H engulfing setup detected")
alertcondition(longTriggered, "Long triggered", "Long entry triggered by break of signal high")
alertcondition(shortTriggered, "Short triggered", "Short entry triggered by break of signal low")
````
