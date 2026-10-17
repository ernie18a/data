# McNamee Auto-Trade

- url: https://www.tradingview.com/script/jRPl0Fby-McNamee-Auto-Trade/
- type: indicator
- pine_id: PUB;185b4ec5283244f99fe4326b5696a542
- version: 1.0

## Description

NQ Script Coded specifically for automated Order Block probability and variance.

## Source Code

````pine
// MSB Order Block Auto-Trader — Companion Script
// Designed to work alongside: LuxAlgo - Market Structure Break & OB Probability Toolkit
// Timeframe: 1 Minute | Instrument: NQ | Session: 9:10 AM – 2:30 PM Central
// Rules: 2-candle wait, first OB touched = trade, 1 trade/day, 25pt SL & TP

//@version=6
indicator("MSB OB Auto-Trader Signal", overlay = true)

//--------------------------------------------------------------------
// SETTINGS
//--------------------------------------------------------------------
pivotLenInput    = input.int(7,   "Pivot Lookback",         minval = 1)
msbZScoreInput   = input.float(0.5, "MSB Momentum Z-Score", minval = 0.1, step = 0.1)
candleWait       = input.int(2,   "Candle Wait After OB",   minval = 1)
slPoints         = input.float(25.0, "Stop Loss (NQ Points)")
tpPoints         = input.float(25.0, "Take Profit (NQ Points)")

//--------------------------------------------------------------------
// SESSION FILTER — 9:10 AM to 2:30 PM Central (= 10:10 AM – 3:30 PM ET)
//--------------------------------------------------------------------
inSession = not na(time("1", "1010-1530:23456", "America/New_York"))

//--------------------------------------------------------------------
// CORE CALCULATIONS (mirrors LuxAlgo logic exactly)
//--------------------------------------------------------------------
float priceChange = ta.change(close)
float avgChange   = ta.sma(priceChange, 50)
float stdChange   = ta.stdev(priceChange, 50)
float momentumZ   = (priceChange - avgChange) / stdChange

float ph = ta.pivothigh(high, pivotLenInput, pivotLenInput)
float pl = ta.pivotlow(low,  pivotLenInput, pivotLenInput)

var float lastPh = na
var float lastPl = na

if not na(ph)
    lastPh := ph
if not na(pl)
    lastPl := pl

// MSB Conditions (identical to LuxAlgo)
bool isMSBBull = close > lastPh and close[1] <= lastPh and momentumZ >  msbZScoreInput
bool isMSBBear = close < lastPl and close[1] >= lastPl and momentumZ < -msbZScoreInput

//--------------------------------------------------------------------
// ORDER BLOCK DETECTION
//--------------------------------------------------------------------
getOBIndex(bool isBull) =>
    int obIdx = 0
    for i = 1 to 10
        if (isBull and close[i] < open[i]) or (not isBull and close[i] > open[i])
            obIdx := i
            break
    obIdx

//--------------------------------------------------------------------
// STATE TRACKING
//--------------------------------------------------------------------
var float obTop           = na
var float obBottom        = na
var bool  obIsBull        = false
var int   obBarIndex      = na
var bool  obMitigated     = false
var bool  tradeTakenToday = false

// Reset trade flag on new day
isNewDay = dayofweek != dayofweek[1] or (hour == 0 and minute == 0)
if isNewDay
    tradeTakenToday := false

//--------------------------------------------------------------------
// OB CREATION
//--------------------------------------------------------------------
if (isMSBBull or isMSBBear) and not tradeTakenToday
    int obIdx  = getOBIndex(isMSBBull)
    obTop      := high[obIdx]
    obBottom   := low[obIdx]
    obIsBull   := isMSBBull
    obBarIndex := bar_index
    obMitigated := false

    if isMSBBull
        lastPh := na
    else
        lastPl := na

//--------------------------------------------------------------------
// MITIGATION CHECK
//--------------------------------------------------------------------
if not na(obTop) and not obMitigated
    if obIsBull and low < obBottom
        obMitigated := true
    if not obIsBull and high > obTop
        obMitigated := true

//--------------------------------------------------------------------
// ENTRY LOGIC
//--------------------------------------------------------------------
bool obReady     = not na(obTop) and not obMitigated and (bar_index - obBarIndex >= candleWait)
bool touchedBull = obReady and obIsBull       and low  <= obTop    and high >= obBottom
bool touchedBear = obReady and not obIsBull   and high >= obBottom and low  <= obTop

bool longSignal  = touchedBull and not tradeTakenToday and inSession
bool shortSignal = touchedBear and not tradeTakenToday and inSession

if longSignal
    tradeTakenToday := true
    obMitigated     := true

if shortSignal
    tradeTakenToday := true
    obMitigated     := true

//--------------------------------------------------------------------
// VISUALS
//--------------------------------------------------------------------
plotshape(longSignal,  title = "LONG Entry",  location = location.belowbar, style = shape.triangleup,   color = #089981, size = size.normal, text = "LONG")
plotshape(shortSignal, title = "SHORT Entry", location = location.abovebar, style = shape.triangledown, color = #f23645, size = size.normal, text = "SHORT")

bgcolor(obReady and obIsBull ? color.new(#089981, 92) : na, title = "Bull OB Zone")
bgcolor(obReady and not obIsBull and not na(obTop) ? color.new(#f23645, 92) : na, title = "Bear OB Zone")

//--------------------------------------------------------------------
// ALERT CONDITIONS
//--------------------------------------------------------------------
alertcondition(longSignal,  "LONG Entry Signal",  "LONG")
alertcondition(shortSignal, "SHORT Entry Signal", "SHORT")
alertcondition(longSignal or shortSignal, "MSB OB Trade Signal", '{"side": "{{longSignal ? "BUY" : "SELL"}}", "symbol": "NQM5", "sl_points": 25, "tp_points": 25, "qty": 1}')
````
