# Universal Bias Evaluator

- url: https://www.tradingview.com/script/ozbKHkIN-Universal-Bias-Evaluator/
- type: indicator
- pine_id: PUB;9f5e5d37db574015960505bfe77f11f9
- version: 2.0

## Description

Universal Bias Evaluator

Description:
The Universal Bias Evaluator is a clean and efficient Pine Script v6 indicator that provides a clear directional bias on your chosen timeframe. It analyzes current price action against the previous period's high low and midpoint then applies an optional filter to improve reliability. The result is a simple Bullish Bearish or Neutral reading with the logic explained directly in the table. This is especially useful on intraday charts.

Core Logic:
The indicator evaluates how price interacts with the prior period:
Bull Sweep occurs when price sweeps below the previous low but closes above it
Bear Sweep occurs when price sweeps above the previous high but closes below it
Double Sweep happens when both sides are swept with bias decided by close relative to the previous midpoint
No sweep defaults to close versus previous midpoint

Optional Trend Filter:
Users can enable either a single Moving Average filter or a Fast/Slow Cloud filter. When enabled any signal running against the filter direction is neutralized to gray reducing whipsaws in ranging markets.

Bias Output:
The final bias is displayed as Bullish in green Bearish in red or Neutral in gray. The table also shows the exact reason for the current reading.

Key Features:
Timeframe selection between Daily and Weekly
Three filter modes None, M.A., or Cloud
Multiple MA types including EMA, SMA, WMA, and HMA
Flexible cloud lengths for the dual MA filter
Nine table position options
Clean single security call for optimal performance

The indicator is designed for traders who want a fast unbiased view of higher timeframe direction without cluttering the chart.

## Source Code

````pine
//@version=6
indicator("Universal Bias Evaluator", shorttitle="Universal Bias", overlay=true, max_bars_back=500)

// ---- Inputs ----
timeframeRes   = input.string("D", "Bias Period", options=["D", "W"], group="Timeframe")
allowExt       = input.bool(true, "Allow extended hours?", tooltip="If checked, extended hours bars are actively evaluated against the prior day's RTH levels. If unchecked, extended hours calculation is paused, holding the previous regular session's status.", group="Session Handling")
f_type         = input.string("None", "Filter Type", options=["None", "M.A.", "Cloud"], group="Strategy")
ma_type        = input.string("EMA", "MA Method", options=["EMA", "SMA", "WMA", "HMA"], group="Strategy")
lineLen        = input.int(8, "MA Line Length", minval=1, group="Strategy")
cFastLen       = input.int(7, "Cloud Fast Length", minval=1, group="Strategy")
cSlowLen       = input.int(9, "Cloud Slow Length", minval=1, group="Strategy")
tablePos       = input.string(position.top_right, "Table Position", options=[position.top_left, position.top_center, position.top_right, position.middle_left, position.middle_center, position.middle_right, position.bottom_left, position.bottom_center, position.bottom_right], group="UI")

// ---- MA Calc ----
get_ma(src, len, type) =>
    float res = 0.0
    if type == "SMA"
        res := ta.sma(src, len)
    else if type == "WMA"
        res := ta.wma(src, len)
    else if type == "HMA"
        res := ta.hma(src, len)
    else
        res := ta.ema(src, len)
    res

// ---- Data Gathering ----
calc_data() =>
    _close = close
    _high  = high
    _low   = low
    _ph    = high[1]
    _pl    = low[1]
    _ma    = get_ma(_close, lineLen, ma_type)
    _cf    = get_ma(_close, cFastLen, ma_type)
    _cs    = get_ma(_close, cSlowLen, ma_type)
    _cm    = (_cf + _cs) / 2
    [_close, _high, _low, _ph, _pl, _ma, _cs, _cm]

// Pull data from clean RTH profile for historical reference
rthTicker = ticker.modify(syminfo.tickerid, session=session.regular)
[secClose, secHigh, secLow, secPH, secPL, secMa, secSlow, secMid] = request.security(rthTicker, timeframeRes, calc_data(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

// ---- Logic Evaluation ----
f_limit   = f_type == "M.A." ? secMa : secSlow

// Tracking if the current chart bar is within regular hours
isRTH = session.ismarket

// DYNAMIC HTF REFERENCE:
targetPH = isRTH ? secPH : secHigh
targetPL = isRTH ? secPL : secLow
targetPrevMid = (targetPH + targetPL) / 2

// --- ROBUST SESSION MEMORY TRACKING ---
// Detect when a new Higher Timeframe period (Day or Week) begins and ensure it evaluates to a bool
isNewPeriod = nz(ta.change(time(timeframeRes))) != 0

var bool hasSweptHi = false
var bool hasSweptLo = false

// Reset memory clean when the new period opens
if isNewPeriod
    hasSweptHi := false
    hasSweptLo := false

// Update memory flags if a sweep occurs at any point during this period
if high >= targetPH
    hasSweptHi := true
if low <= targetPL
    hasSweptLo := true

// Evaluate standard parameters against historical RTH structural boundaries using the Session Memory
isSweepHi  = hasSweptHi
isSweepLo  = hasSweptLo
isBoth     = isSweepHi and isSweepLo
bear_sweep = isSweepHi and close < targetPH
bull_sweep = isSweepLo and close > targetPL

color baseColor = color.gray
string reason   = ""

if isBoth
    if close > targetPH
        baseColor := color.green
        reason    := "both sides: bull"
    else if close < targetPL
        baseColor := color.red
        reason    := "both sides: bear"
    else
        if close > targetPrevMid
            baseColor := color.green
            reason    := "both: > prev. mid"
        else
            baseColor := color.red
            reason    := "both: < prev. mid"
else if bear_sweep
    baseColor := color.red
    reason    := "bear_sweep"
else if bull_sweep
    baseColor := color.green
    reason    := "bull_sweep"
else if close < targetPrevMid
    baseColor := color.red
    reason    := "< prev. mid"
else if close > targetPrevMid
    baseColor := color.green
    reason    := "> prev. mid"
else
    baseColor := color.gray
    reason    := "neutral"
    
// ---- Trend Filtering ----
filtGrn = (f_type != "None") and secClose < f_limit
filtRed = (f_type != "None") and secClose > f_limit

finalColor = baseColor
if baseColor == color.green and filtGrn
    finalColor := color.gray
if baseColor == color.red and filtRed
    finalColor := color.gray

calculatedBias = finalColor == color.green ? "Bullish" : finalColor == color.red ? "Bearish" : "Neutral"

// ---- Persistent State Management ----
var string dynamicBias   = "Neutral"
var string dynamicReason = "neutral"

if isRTH or allowExt
    dynamicBias   := calculatedBias
    dynamicReason := reason

// ---- Table Display ----
var table biasTable = table.new(tablePos, 1, 4, border_width=1, frame_color=color.gray, bgcolor=color.new(color.black, 100))

if barstate.islast
    biasCol      = dynamicBias == "Bullish" ? color.green : dynamicBias == "Bearish" ? color.red : color.gray
    filterStatus = "filter: " + (f_type == "None" ? "off" : str.lower(f_type))
    timeframeLab = timeframeRes == "D" ? "Daily" : "Weekly"
    
    table.cell(biasTable, 0, 0, timeframeLab + " Bias: ", text_color=color.black, text_size=size.small)
    table.cell(biasTable, 0, 1, dynamicBias, text_color=biasCol, text_size=size.large)
    table.cell(biasTable, 0, 2, filterStatus, text_color=color.black, text_size=size.small)
    table.cell(biasTable, 0, 3, dynamicReason, text_color=color.black, text_size=size.small, bgcolor=color.new(color.black, 100))
````
