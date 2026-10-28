# Auto FIBB by Vamshi Varsa

- url: https://www.tradingview.com/script/VKsBoc2g-Auto-FIBB-by-Vamshi-Varsa/
- type: indicator
- pine_id: PUB;f326517be26b47e8a8fc768ea4574686
- version: 4.0

## Description

This Indicator will automatically mark the FIBB with Displacements, once Price retraces to 0.71 levels of FIBB there is a high chance of reversal. SL should be at FIBB level 1 and TP should be at FIBB level 0

## Source Code

````pine
//@version=6
indicator("Auto FIBB by VamshiVarsa", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// --- Force Pine Script to keep a deep memory buffer ---
max_bars_back(high, 1000)
max_bars_back(low, 1000)

// --- Inputs ---
sensitivity = input.int(7, "Swing Sensitivity", group="Market Structure")

fibLevel1     = input.float(0.71, "Entry Level 1", group="Fibonacci")
fibLevel2     = input.float(0.79, "Entry Level 2", group="Fibonacci")
fibLength     = input.int(20, "Fib Extension (Bars)", group="Fibonacci") 
fibColorBase  = input.color(color.gray, "Base Levels Color (0 & 1)", group="Fibonacci")
fibColorEntry = input.color(color.yellow, "Entry Levels Color (0.71 & 0.79)", group="Fibonacci")

fvgColor    = input.color(color.new(color.gray, 85), "FVG Box Color", group="Imbalance")
fvgLength   = input.int(20, "FVG Box Extension (Bars)", group="Imbalance")

emaLength   = input.int(200, "HTF Trend EMA", group="Checklist Logic")

showDaily   = input.bool(true, "Show Prev Daily High/Low", group="HTF Liquidity")
showWeekly  = input.bool(true, "Show Prev Weekly High/Low", group="HTF Liquidity")
htfLineColor = input.color(color.gray, "HTF Line Color", group="HTF Liquidity")

// Alert Requirements toggles
reqHTF     = input.bool(false, "Require HTF Alignment", group="Alert Conditions")
reqSweep   = input.bool(true,  "Require Liquidity Sweep", group="Alert Conditions")
reqBOS     = input.bool(true,  "Require BOS + Imbalance", group="Alert Conditions")
reqRetrace = input.bool(true,  "Require 71% Retracement", group="Alert Conditions")

// MTF Tracker Inputs
showMtfTracker = input.bool(true, "Show MTF Tracker Table", group="MTF Retracement Tracker")
tf1 = input.timeframe("15", "Timeframe 1", group="MTF Retracement Tracker")
tf2 = input.timeframe("60", "Timeframe 2", group="MTF Retracement Tracker")
tf3 = input.timeframe("240", "Timeframe 3", group="MTF Retracement Tracker")

// --- Stateful Fib Lines & Labels ---
var line line1  = line.new(na, na, na, na, color=fibColorBase)
var line line71 = line.new(na, na, na, na, color=fibColorEntry, width=2)
var line line79 = line.new(na, na, na, na, color=fibColorEntry, width=2)
var line line0  = line.new(na, na, na, na, color=fibColorBase)

var label lbl1  = label.new(na, na, "1", style=label.style_none, textcolor=fibColorBase)
var label lbl71 = label.new(na, na, "0.71", style=label.style_none, textcolor=fibColorEntry)
var label lbl79 = label.new(na, na, "0.79", style=label.style_none, textcolor=fibColorEntry)
var label lbl0  = label.new(na, na, "0", style=label.style_none, textcolor=fibColorBase)

// --- State Variables (Sequence Engine) ---
var int   activeTrend   = 0  
var float fibOrigin     = na 
var int   fibOriginIdx  = na
var float fibExtreme    = na 
var bool  fibLocked     = false
var bool  setupAlerted  = false 

// Checklist States
var bool sweepBullReady = false
var bool sweepBearReady = false
var bool chk_htf        = false
var bool chk_sweep      = false
var bool chk_bos        = false
var bool chk_retrace    = false

// --- FVG Arrays (For tracking mitigation) ---
var box[] bullFVGs = array.new_box()
var box[] bearFVGs = array.new_box()

// --- Absolute Extreme Finders ---
get_origin_bull(hiIdx) =>
    float minL = low
    int minIdx = bar_index
    int lookback = bar_index - hiIdx
    if lookback > 0 and lookback < 1000
        for i = 0 to lookback
            if low[i] < minL
                minL := low[i]
                minIdx := bar_index[i]
    [minL, minIdx]

get_origin_bear(loIdx) =>
    float maxH = high
    int maxIdx = bar_index
    int lookback = bar_index - loIdx
    if lookback > 0 and lookback < 1000
        for i = 0 to lookback
            if high[i] > maxH
                maxH := high[i]
                maxIdx := bar_index[i]
    [maxH, maxIdx]

// --- HTF Data & Alignment ---
htfEma = ta.ema(close, emaLength)
d_h = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
d_l = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)
w_h = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_on)
w_l = request.security(syminfo.tickerid, "W", low[1], lookahead=barmerge.lookahead_on)

var line pdhLine = line.new(na, na, na, na, color=htfLineColor, style=line.style_dashed)
var line pdlLine = line.new(na, na, na, na, color=htfLineColor, style=line.style_dashed)
var label pdhLbl = label.new(na, na, "PDH", style=label.style_none, textcolor=htfLineColor, size=size.small)
var label pdlLbl = label.new(na, na, "PDL", style=label.style_none, textcolor=htfLineColor, size=size.small)

var line pwhLine = line.new(na, na, na, na, color=htfLineColor, style=line.style_dotted, width=2)
var line pwlLine = line.new(na, na, na, na, color=htfLineColor, style=line.style_dotted, width=2)
var label pwhLbl = label.new(na, na, "PWH", style=label.style_none, textcolor=htfLineColor, size=size.small)
var label pwlLbl = label.new(na, na, "PWL", style=label.style_none, textcolor=htfLineColor, size=size.small)

if barstate.islast
    if showDaily
        line.set_xy1(pdhLine, bar_index - 20, d_h), line.set_xy2(pdhLine, bar_index + 10, d_h), label.set_xy(pdhLbl, bar_index + 10, d_h)
        line.set_xy1(pdlLine, bar_index - 20, d_l), line.set_xy2(pdlLine, bar_index + 10, d_l), label.set_xy(pdlLbl, bar_index + 10, d_l)
    if showWeekly
        line.set_xy1(pwhLine, bar_index - 20, w_h), line.set_xy2(pwhLine, bar_index + 10, w_h), label.set_xy(pwhLbl, bar_index + 10, w_h)
        line.set_xy1(pwlLine, bar_index - 20, w_l), line.set_xy2(pwlLine, bar_index + 10, w_l), label.set_xy(pwlLbl, bar_index + 10, w_l)

// --- Market Structure ---
hi = ta.pivothigh(high, sensitivity, sensitivity)
lo = ta.pivotlow(low, sensitivity, sensitivity)

var float lastHi = na
var float lastLo = na
var int lastHiIdx = na
var int lastLoIdx = na

if not na(hi)
    lastHi := hi
    lastHiIdx := bar_index[sensitivity]
if not na(lo)
    lastLo := lo
    lastLoIdx := bar_index[sensitivity]

// --- Dynamic FVG Engine ---
isBullFVG = low[0] > high[2]
if isBullFVG
    b = box.new(bar_index[2], low[0], bar_index + fvgLength, high[2], bgcolor=fvgColor, border_color=na)
    array.push(bullFVGs, b)
    if array.size(bullFVGs) > 50
        box.delete(array.shift(bullFVGs))

isBearFVG = high[0] < low[2]
if isBearFVG
    b = box.new(bar_index[2], low[2], bar_index + fvgLength, high[0], bgcolor=fvgColor, border_color=na)
    array.push(bearFVGs, b)
    if array.size(bearFVGs) > 50
        box.delete(array.shift(bearFVGs))

if array.size(bullFVGs) > 0
    for i = array.size(bullFVGs) - 1 to 0
        b = array.get(bullFVGs, i)
        if low <= box.get_bottom(b)
            box.delete(b), array.remove(bullFVGs, i)
        else
            box.set_right(b, bar_index + fvgLength)
            if low < box.get_top(b) 
                box.set_top(b, low)

if array.size(bearFVGs) > 0
    for i = array.size(bearFVGs) - 1 to 0
        b = array.get(bearFVGs, i)
        if high >= box.get_top(b) 
            box.delete(b), array.remove(bearFVGs, i)
        else
            box.set_right(b, bar_index + fvgLength)
            if high > box.get_bottom(b) 
                box.set_bottom(b, high)

// --- Sweeps Tracking ---
isBullSweep = low < lastLo and close > lastLo
isBearSweep = high > lastHi and close < lastHi

if isBullSweep
    sweepBullReady := true
    line.new(lastLoIdx, lastLo, bar_index, lastLo, color=color.yellow, style=line.style_dotted)
    int midIdx = lastLoIdx + int((bar_index - lastLoIdx) / 2)
    label.new(midIdx, lastLo, "LQS", style=label.style_none, textcolor=color.yellow, size=size.small)

if isBearSweep
    sweepBearReady := true
    line.new(lastHiIdx, lastHi, bar_index, lastHi, color=color.yellow, style=line.style_dotted)
    int midIdx = lastHiIdx + int((bar_index - lastHiIdx) / 2)
    label.new(midIdx, lastHi, "LQS", style=label.style_none, textcolor=color.yellow, size=size.small)

// --- BOS Logic ---
var int lastBullBOS = 0
var int lastBearBOS = 0

bullCross = ta.crossover(close, lastHi)
bearCross = ta.crossunder(close, lastLo)

bullBOS = isBullFVG and (bullCross or bullCross[1] or bullCross[2]) and (bar_index - lastBullBOS > 2)
bearBOS = isBearFVG and (bearCross or bearCross[1] or bearCross[2]) and (bar_index - lastBearBOS > 2)

if bullBOS
    lastBullBOS := bar_index
if bearBOS
    lastBearBOS := bar_index

// --- Register New Setup & Update Checklist State ---
if bullBOS
    activeTrend := 1
    [o_price, o_idx] = get_origin_bull(lastHiIdx)
    fibOrigin := o_price
    fibOriginIdx := o_idx
    fibExtreme := high
    fibLocked := false
    setupAlerted := false 
    
    chk_bos := true
    chk_sweep := sweepBullReady
    chk_retrace := false
    sweepBullReady := false 
    sweepBearReady := false 
    
    int midIdx = lastHiIdx + int((bar_index - lastHiIdx) / 2)
    line.new(lastHiIdx, lastHi, bar_index, lastHi, color=color.blue, style=line.style_dashed)
    label.new(midIdx, lastHi, "BOS", style=label.style_none, textcolor=color.blue, size=size.small)

if bearBOS
    activeTrend := -1
    [o_price, o_idx] = get_origin_bear(lastLoIdx)
    fibOrigin := o_price
    fibOriginIdx := o_idx
    fibExtreme := low
    fibLocked := false
    setupAlerted := false 
    
    chk_bos := true
    chk_sweep := sweepBearReady
    chk_retrace := false
    sweepBullReady := false 
    sweepBearReady := false 
    
    int midIdx = lastLoIdx + int((bar_index - lastLoIdx) / 2)
    line.new(lastLoIdx, lastLo, bar_index, lastLo, color=color.red, style=line.style_dashed)
    label.new(midIdx, lastLo, "BOS", style=label.style_none, textcolor=color.red, size=size.small)

// --- Lock & Trail Extreme ---
if activeTrend == 1 and not na(hi)
    fibLocked := true
if activeTrend == -1 and not na(lo)
    fibLocked := true

if activeTrend == 1 and not fibLocked
    if high > fibExtreme
        fibExtreme := high
else if activeTrend == -1 and not fibLocked
    if low < fibExtreme
        fibExtreme := low

// --- Checklist Retracement & HTF Logic ---
if activeTrend == 1
    chk_htf := close > htfEma // Bullish alignment
    float current_lvl71 = fibExtreme - (fibExtreme - fibOrigin) * fibLevel1
    if low <= current_lvl71 and close >= fibOrigin
        chk_retrace := true

else if activeTrend == -1
    chk_htf := close < htfEma // Bearish alignment
    float current_lvl71 = fibExtreme + (fibOrigin - fibExtreme) * fibLevel1
    if high >= current_lvl71 and close <= fibOrigin
        chk_retrace := true

// --- Invalidation Logic ---
var bool invalidated = false
if activeTrend == 1 and close < fibOrigin
    activeTrend := 0
    invalidated := true
else if activeTrend == -1 and close > fibOrigin
    activeTrend := 0
    invalidated := true

if invalidated
    line.set_xy1(line1, na, na), line.set_xy2(line1, na, na)
    line.set_xy1(line71, na, na), line.set_xy2(line71, na, na)
    line.set_xy1(line79, na, na), line.set_xy2(line79, na, na)
    line.set_xy1(line0, na, na), line.set_xy2(line0, na, na)
    
    label.set_xy(lbl1, na, na), label.set_xy(lbl71, na, na)
    label.set_xy(lbl79, na, na), label.set_xy(lbl0, na, na)
    
    chk_htf := false
    chk_sweep := false
    chk_bos := false
    chk_retrace := false
    setupAlerted := false
    invalidated := false

// --- Alert Engine ---
bool triggerAlert = false
if activeTrend != 0 and not setupAlerted
    triggerAlert := true
    if reqHTF and not chk_htf
        triggerAlert := false
    if reqSweep and not chk_sweep
        triggerAlert := false
    if reqBOS and not chk_bos
        triggerAlert := false
    if reqRetrace and not chk_retrace
        triggerAlert := false

if triggerAlert
    setupAlerted := true
    alert("SMC A+ Setup Confirmed on " + syminfo.ticker + " (" + timeframe.period + ")", alert.freq_once_per_bar)

alertcondition(triggerAlert, title="SMC Master Alert", message="An SMC Setup met all active checklist requirements.")

// --- Calculate Global 0.71 Level for MTF Retrieval ---
float global_lvl71 = na
if activeTrend != 0
    float lvl1 = fibOrigin
    float lvl0 = fibExtreme
    global_lvl71 := activeTrend == 1 ? lvl0 - (lvl0 - lvl1) * fibLevel1 : lvl0 + (lvl1 - lvl0) * fibLevel1

// --- Fetch MTF Data ---
lvl71_tf1 = request.security(syminfo.tickerid, tf1, global_lvl71)
lvl71_tf2 = request.security(syminfo.tickerid, tf2, global_lvl71)
lvl71_tf3 = request.security(syminfo.tickerid, tf3, global_lvl71)

// --- Update Fibonacci Coordinates & Colors (Current TF) ---
if activeTrend != 0
    float lvl1 = fibOrigin
    float lvl0 = fibExtreme
    float lvl71 = activeTrend == 1 ? lvl0 - (lvl0 - lvl1) * fibLevel1 : lvl0 + (lvl1 - lvl0) * fibLevel1
    float lvl79 = activeTrend == 1 ? lvl0 - (lvl0 - lvl1) * fibLevel2 : lvl0 + (lvl1 - lvl0) * fibLevel2
    
    int endX = bar_index + fibLength 
    
    line.set_color(line1, fibColorBase), line.set_xy1(line1, fibOriginIdx, lvl1), line.set_xy2(line1, endX, lvl1)
    line.set_color(line71, fibColorEntry), line.set_xy1(line71, fibOriginIdx, lvl71), line.set_xy2(line71, endX, lvl71)
    line.set_color(line79, fibColorEntry), line.set_xy1(line79, fibOriginIdx, lvl79), line.set_xy2(line79, endX, lvl79)
    line.set_color(line0, fibColorBase), line.set_xy1(line0, fibOriginIdx, lvl0), line.set_xy2(line0, endX, lvl0)
    
    label.set_textcolor(lbl1, fibColorBase), label.set_xy(lbl1, endX, lvl1)
    label.set_textcolor(lbl71, fibColorEntry), label.set_xy(lbl71, endX, lvl71)
    label.set_textcolor(lbl79, fibColorEntry), label.set_xy(lbl79, endX, lvl79)
    label.set_textcolor(lbl0, fibColorBase), label.set_xy(lbl0, endX, lvl0)

// --- Live Table Rendering (Top Right Checklist) ---
var table checklist = table.new(position.top_right, 2, 5, bgcolor=color.new(color.black, 70), border_width=1)
if barstate.islast
    table.cell(checklist, 0, 0, "Checklist", text_color=color.white)
    
    table.cell(checklist, 0, 1, "HTF Alignment", text_color=color.white)
    table.cell(checklist, 1, 1, chk_htf ? "✅" : "❌", text_color=chk_htf ? color.green : color.red)
    
    table.cell(checklist, 0, 2, "Liquidity Sweep", text_color=color.white)
    table.cell(checklist, 1, 2, chk_sweep ? "✅" : "❌", text_color=chk_sweep ? color.green : color.red)
    
    table.cell(checklist, 0, 3, "BOS + Imbalance", text_color=color.white)
    table.cell(checklist, 1, 3, chk_bos ? "✅" : "❌", text_color=chk_bos ? color.green : color.red)
    
    table.cell(checklist, 0, 4, "71% Retracement", text_color=color.white)
    table.cell(checklist, 1, 4, chk_retrace ? "✅" : "❌", text_color=chk_retrace ? color.green : color.red)

// --- MTF Retracement Tracker Table (Bottom Right) ---
var table mtfTable = table.new(position.bottom_right, 2, 4, bgcolor=color.new(color.black, 70), border_width=1)
if barstate.islast and showMtfTracker
    table.cell(mtfTable, 0, 0, "Timeframe", text_color=color.white)
    table.cell(mtfTable, 1, 0, "Points to 0.71", text_color=color.white)
    
    // TF 1
    table.cell(mtfTable, 0, 1, tf1, text_color=color.white)
    table.cell(mtfTable, 1, 1, na(lvl71_tf1) ? "No Setup" : str.tostring(math.abs(close - lvl71_tf1), format.mintick) + " pts", text_color=na(lvl71_tf1) ? color.gray : color.yellow)
    
    // TF 2
    table.cell(mtfTable, 0, 2, tf2, text_color=color.white)
    table.cell(mtfTable, 1, 2, na(lvl71_tf2) ? "No Setup" : str.tostring(math.abs(close - lvl71_tf2), format.mintick) + " pts", text_color=na(lvl71_tf2) ? color.gray : color.yellow)
    
    // TF 3
    table.cell(mtfTable, 0, 3, tf3, text_color=color.white)
    table.cell(mtfTable, 1, 3, na(lvl71_tf3) ? "No Setup" : str.tostring(math.abs(close - lvl71_tf3), format.mintick) + " pts", text_color=na(lvl71_tf3) ? color.gray : color.yellow)
````
