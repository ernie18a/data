# Ram-ban Support & Resistance System [% Adaptive for Stocks]

- url: https://www.tradingview.com/script/C0I2BDTq-Ram-ban-Support-Resistance-System-Adaptive-for-Stocks/
- type: indicator
- pine_id: PUB;7b90a2394fe445a9a07bc8103eebc682
- version: 1.0

## Description

📌 Overview
The Ram-ban Support & Resistance System is an advanced, fully dynamic mapping tool engineered to identify crucial market turning points without cluttering your chart. By referencing higher timeframe (HTF) pivot structures and utilizing a percentage-based mapping logic, this indicator seamlessly scales to any asset class—from Crypto and Forex to Equities and Indices—without the need for manual point adjustments.

🚀 Key Features

Adaptive % Model: Forget rigid point values. Settings for spacing, signals, and stop-loss are percentage-based, ensuring the indicator works flawlessly on BTCUSD just as well as it does on AAPL or NIFTY.

Dynamic Consolidation Heatmap: Not all levels are created equal. As price consolidates around a specific support or resistance zone, the line dynamically increases in thickness. A thicker line represents a heavily tested zone with stronger historical relevance.

Intelligent "Option Mode" (Fading): Keep your focus where the action is. Levels that are far from the current market price will automatically fade out, keeping your chart clean and eliminating noise.

Wick-Based Signal Engine: Captures sniper-like entries by looking for wick rejections at key levels. When price reaches a specified tolerance zone (%) of a major level, a Buy or Sell signal is generated.

Built-in Risk Management: Automatically calculates a dynamic Stop Loss based on your preset percentage. Visual labels tell you exactly where your invalidation point is upon entry.

Session Filtering: Confine your trading signals strictly to active market hours, filtering out erratic overnight or pre-market moves.

🛠️ How to Use

Trend Context: Use the HTF Support/Resistance rails as major boundaries. Green rails act as support (demand), red rails act as resistance (supply).

Observe the Line Thickness: A very thin line is a fresh level. A thick, bold line indicates high historical contention. Treat thick lines as high-probability reversal zones.

Trading Signals: Look for the "BUY" labels (with attached SL values) as price taps support rails. The "BOOK PROFIT" label triggers when a loaded position touches the upper resistance boundary.

Alerts: Create alerts directly from the indicator to be notified of "BUY", "BOOK PROFIT", or "SL HIT" events instantly.

⚙️ Core Settings Overview

HTF for Pivots: The default is 60 (1 Hour) to capture macro swings on lower timeframe charts (like 5m or 15m).

Min Distance Between Levels (%): Prevents the indicator from drawing too many lines close together. Adjust based on asset volatility.

Consolidation Zone Tolerance (%): How close a candle needs to close near a line to "thicken" it.

Stop Loss (%): Defines the dynamic Stop Loss label printed alongside entry signals.

⚠️ Disclaimer
This script is provided for educational and informational purposes only. It does not constitute financial, investment, or trading advice. Past performance is not indicative of future results. Trading in financial markets involves a high degree of risk. Always conduct your own research (DYOR), backtest thoroughly, and use proper risk management before putting real capital on the line. The author assumes no responsibility for any trading losses incurred.

SupportAndResistance, PriceAction, PivotPoints, DynamicLevels, DayTrading, Scalping, RiskManagement, StopLoss, Breakout, Reversal, MultiTimeframe, MTF

## Source Code

````pine
//@version=6
// -----------------------------------------------------------------------------------------
// 
//     Title: Ram-ban Support & Resistance System [% Adaptive]
//     Description: A dynamic support and resistance indicator utilizing HTF pivots, 
//                  consolidation-based visual weighting, and %-based level filtering.
//                  Includes wick-based signal generation and automated position tracking.
//
// -----------------------------------------------------------------------------------------
indicator("Ram-ban Support & Resistance [%]", shorttitle="Ram-ban S/R", overlay = true, max_lines_count = 200, max_labels_count = 400)

// =========================================================================================
// INPUTS
// =========================================================================================
grp_main = "Main Settings"
htfTf         = input.timeframe("60", "HTF for Pivots (1H)", group=grp_main)
leftBars      = input.int(3,  "Pivot Left Bars",  minval = 1, group=grp_main)
rightBars     = input.int(3,  "Pivot Right Bars", minval = 1, group=grp_main)

grp_levels = "Level Filtering & Aesthetics"
// Default 0.15% is roughly equivalent to 30 pts on a 20,000 index, but scales to all assets.
minStepPct    = input.float(0.15, "Min Distance Between Any Levels (%)", minval = 0.0, step = 0.05, group=grp_levels)
maxHighLevels = input.int(7, "Max High Levels", minval = 1, maxval = 50, group=grp_levels)
maxLowLevels  = input.int(7, "Max Low Levels",  minval = 1, maxval = 50, group=grp_levels)

isOptionMode  = input.bool(true,  "Option Mode: Fade distant levels", group=grp_levels)
minDistPct    = input.float(0.15, "Fade Distance from Close (%)", minval = 0.0, step = 0.05, group=grp_levels)

grpConsolidation = "Consolidation Strength (Line Width)"
consolidationTolPct = input.float(0.1, "Consolidation Zone Tolerance (%)", group=grpConsolidation, tooltip="Percentage distance from line to count a candle as consolidating.", step=0.05)
candlesPerWidth  = input.int(3, "Candles per Width Increment", minval=1, group=grpConsolidation)
minLineWidth     = input.int(1, "Minimum Line Width", minval=1, maxval=20, group=grpConsolidation)
maxLineWidth     = input.int(8, "Maximum Line Width", minval=1, maxval=20, group=grpConsolidation)

grp_signals = "Signals & Risk Management"
enableSignals    = input.bool(true, "Enable BUY/SELL Signals", group=grp_signals)
signalProxPct    = input.float(0.05, "Signal Tolerance from Level (%)", minval = 0.0, step = 0.01, group=grp_signals)
slPct            = input.float(0.5, "Stop Loss (%)", minval = 0.1, step = 0.1, group=grp_signals) 

useSessionFilter = input.bool(true, "Use Signal Session Filter", group=grp_signals)
signalSession    = input.session("0915-1530", "Signal Session (Exchange Time)", group=grp_signals)
debugMode        = input.bool(false, "Debug Mode (Extra Markers)", group=grp_signals)

// =========================================================================================
// LOGIC & CALCULATIONS
// =========================================================================================
bool inSession = useSessionFilter ? not na(time(timeframe.period, signalSession)) : true

// HTF Pivots
float htfPH = request.security(syminfo.tickerid, htfTf, ta.pivothigh(high, leftBars, rightBars), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
float htfPL = request.security(syminfo.tickerid, htfTf, ta.pivotlow(low,  leftBars, rightBars), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

bool newHigh = not na(htfPH) and na(htfPH[1])
bool newLow  = not na(htfPL) and na(htfPL[1])

// Storage arrays
var line[]  hiLines   = array.new_line()
var line[]  loLines   = array.new_line()
var label[] hiLabels  = array.new_label()
var label[] loLabels  = array.new_label()
var float[] hiPrices  = array.new_float()
var float[] loPrices  = array.new_float()
var int[]   hiTouches = array.new_int() 
var int[]   loTouches = array.new_int()

// Helpers
f_priceText(float v) => str.tostring(v, format.mintick)

f_farFromAll(float price, float[] A, float[] B, float pctStep) =>
    bool ok = true
    float stepPts = price * (pctStep / 100) 
    int nA = array.size(A)
    if nA > 0
        for i = 0 to nA - 1
            float v = array.get(A, i)
            if math.abs(price - v) < stepPts
                ok := false
    int nB = array.size(B)
    if nB > 0
        for i = 0 to nB - 1
            float v = array.get(B, i)
            if math.abs(price - v) < stepPts
                ok := false
    ok

f_valid(float price) =>
    float distPts = price * (minDistPct / 100)
    not isOptionMode or math.abs(price - close) >= distPts

f_nearest(float price, float[] arr, float pctTol) =>
    float lvl = na
    float tolPts = price * (pctTol / 100)
    int cnt = array.size(arr)
    if cnt > 0
        float bestDiff = 1e10
        for i = 0 to cnt - 1
            float v = array.get(arr, i)
            float d = math.abs(price - v)
            if d <= tolPts and d < bestDiff
                bestDiff := d
                lvl := v
    lvl

// =========================================================================================
// RENDER LEVELS (Support & Resistance)
// =========================================================================================
// Resistances
if newHigh and f_farFromAll(htfPH, hiPrices, loPrices, minStepPct)
    color base = htfPH > close ? color.red : color.green
    color bgcol = color.new(base, 0)
    line ln = line.new(bar_index, htfPH, bar_index + 1, htfPH, extend = extend.right)
    line.set_width(ln, minLineWidth)
    line.set_color(ln, f_valid(htfPH) ? base : color.new(base, 80))

    label lb = label.new(bar_index, htfPH, f_priceText(htfPH),
                         xloc = xloc.bar_index, yloc = yloc.price,
                         style = label.style_label_right, size = size.tiny,
                         color = bgcol, textcolor = color.white)

    array.push(hiLines, ln)
    array.push(hiLabels, lb)
    array.push(hiPrices, htfPH)
    array.push(hiTouches, 0) 

    if array.size(hiLines) > maxHighLevels
        line.delete(array.shift(hiLines))
        label.delete(array.shift(hiLabels))
        array.shift(hiPrices)
        array.shift(hiTouches)

// Supports
if newLow and f_farFromAll(htfPL, hiPrices, loPrices, minStepPct)
    color base = htfPL < close ? color.green : color.red
    color bgcol = color.new(base, 0)
    line ln = line.new(bar_index, htfPL, bar_index + 1, htfPL, extend = extend.right)
    line.set_width(ln, minLineWidth)
    line.set_color(ln, f_valid(htfPL) ? base : color.new(base, 80))

    label lb = label.new(bar_index, htfPL, f_priceText(htfPL),
                         xloc = xloc.bar_index, yloc = yloc.price,
                         style = label.style_label_right, size = size.tiny,
                         color = bgcol, textcolor = color.white)

    array.push(loLines, ln)
    array.push(loLabels, lb)
    array.push(loPrices, htfPL)
    array.push(loTouches, 0) 

    if array.size(loLines) > maxLowLevels
        line.delete(array.shift(loLines))
        label.delete(array.shift(loLabels))
        array.shift(loPrices)
        array.shift(loTouches)

// Update rails every bar: color & dynamic width
int hiCnt = array.size(hiLines)
if hiCnt > 0
    for i = 0 to hiCnt - 1
        line ln = array.get(hiLines, i)
        label lb = array.get(hiLabels, i)
        float y = array.get(hiPrices, i)
        int touches = array.get(hiTouches, i)
        
        float tolPts = y * (consolidationTolPct / 100)
        
        if high >= y - tolPts and low <= y + tolPts
            touches += 1
            array.set(hiTouches, i, touches)
            
        int dynamicWidth = minLineWidth + math.floor(touches / candlesPerWidth)
        int finalWidth = math.min(dynamicWidth, maxLineWidth)

        color base = y > close ? color.red : color.green
        color col  = f_valid(y) ? base : color.new(base, 80)
        
        line.set_color(ln, col)
        line.set_width(ln, finalWidth) 
        label.set_x(lb, bar_index)
        label.set_y(lb, y)
        label.set_text(lb, f_priceText(y))
        label.set_color(lb, color.new(base, f_valid(y) ? 0 : 80))

int loCnt = array.size(loLines)
if loCnt > 0
    for i = 0 to loCnt - 1
        line ln = array.get(loLines, i)
        label lb = array.get(loLabels, i)
        float y = array.get(loPrices, i)
        int touches = array.get(loTouches, i)
        
        float tolPts = y * (consolidationTolPct / 100)
        
        if high >= y - tolPts and low <= y + tolPts
            touches += 1
            array.set(loTouches, i, touches)
            
        int dynamicWidth = minLineWidth + math.floor(touches / candlesPerWidth)
        int finalWidth = math.min(dynamicWidth, maxLineWidth)

        color base = y < close ? color.green : color.red
        color col  = f_valid(y) ? base : color.new(base, 80)
        
        line.set_color(ln, col)
        line.set_width(ln, finalWidth) 
        label.set_x(lb, bar_index)
        label.set_y(lb, y)
        label.set_text(lb, f_priceText(y))
        label.set_color(lb, color.new(base, f_valid(y) ? 0 : 80))

// =========================================================================================
// SIGNALS & POSITION MANAGEMENT
// =========================================================================================
float sLvl = na
if enableSignals
    sLvl := f_nearest(low, loPrices, signalProxPct)
    if na(sLvl)
        sLvl := f_nearest(low, hiPrices, signalProxPct)

float rLvl = na
if enableSignals
    rLvl := f_nearest(high, hiPrices, signalProxPct)
    if na(rLvl)
        rLvl := f_nearest(high, loPrices, signalProxPct)

bool nearS = not na(sLvl)
bool nearR = not na(rLvl)

bool wickNowS  = nearS and low  <= sLvl + (sLvl * (signalProxPct / 100))
bool wickNowR  = nearR and high >= rLvl - (rLvl * (signalProxPct / 100))

bool rawBuy  = enableSignals and wickNowS and inSession
bool rawSell = enableSignals and wickNowR and inSession

var int pos = 0
var float slPrice = na

if useSessionFilter and not inSession and inSession[1]
    pos := 0
    slPrice := na

bool buySignal  = false
bool sellSignal = false
bool slSignal   = false

if barstate.isconfirmed
    // Exits 
    if pos == 1
        if low <= slPrice 
            slSignal := true
            pos := 0
            slPrice := na
        else if rawSell 
            sellSignal := true
            pos := 0
            slPrice := na
    // Entries
    if pos == 0
        if rawBuy
            buySignal := true
            pos := 1
            slPrice := close - (close * (slPct / 100)) 

// =========================================================================================
// PLOTS & ALERTS
// =========================================================================================
if buySignal
    label.new(bar_index, low, "BUY\nSL: " + str.tostring(slPrice, format.mintick),
              xloc = xloc.bar_index, yloc = yloc.price,
              style = label.style_label_up, size = size.small,
              color = color.new(color.green, 0), textcolor = color.white)

if sellSignal
    label.new(bar_index, high, "BOOK PROFIT",
              xloc = xloc.bar_index, yloc = yloc.price,
              style = label.style_label_down, size = size.small,
              color = color.new(color.blue, 0), textcolor = color.white)

if slSignal
    label.new(bar_index, low, "SL HIT",
              xloc = xloc.bar_index, yloc = yloc.price,
              style = label.style_label_up, size = size.small,
              color = color.new(color.gray, 0), textcolor = color.white)

// Debug
plotshape(debugMode and wickNowS, title = "Debug Wick Support",
          style = shape.triangleup, location = location.belowbar,
          size = size.tiny, color = color.new(color.green, 70))
plotshape(debugMode and wickNowR, title = "Debug Wick Resistance",
          style = shape.triangledown, location = location.abovebar,
          size = size.tiny, color = color.new(color.red, 70))

// Alerts
alertcondition(buySignal,  title = "BUY",  message = "BUY near Support")
alertcondition(sellSignal, title = "BOOK PROFIT", message = "Booked profit near Resistance")
alertcondition(slSignal,   title = "SL HIT", message = "Stop loss hit")
````
