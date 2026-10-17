# 7 Figures

- url: https://www.tradingview.com/script/rimRTG2q/
- type: indicator
- pine_id: PUB;ddf8b33b19194ef9beecc418ca483a83
- version: 1.0

## Description

Market Structure Breaks (MSB): Identifies breaks in structure with a momentum-based filtering system (Z-Score).
Institutional Order Blocks: Highlights potential reversal zones with a quality score (0-100%) based on momentum and volume.
High-Probability Zones (HPZ): Identifies order blocks with a score over 80% as high-probability setups.
Advanced Analytics Dashboard: Provides real-time statistics on the reliability of the signals and the count of active high-probability zones.
Session Ranges: Optional visualization for London, New York, Tokyo, and Sydney trading sessions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Michael_Meier

//@version=6
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © LuxAlgo

//@version=6
indicator("Market Structure & Fib Equilibrium [LuxAlgo]", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

//---------------------------------------------------------------------------------------------------------------------}
// Constants
//---------------------------------------------------------------------------------------------------------------------{
color BULL_COLOR      = #089981
color BEAR_COLOR      = #f23645
color YELLOW_COLOR    = #eab308
color FIB_COLOR       = color.gray

//---------------------------------------------------------------------------------------------------------------------}
// Inputs
//---------------------------------------------------------------------------------------------------------------------{
MS_GROUP                = "Market Structure"
EQ_GROUP                = "Equilibrium Zones"
TREND_GROUP             = "Overall Trend"
TRADE_GROUP             = "Trade Execution"
ALERT_GROUP             = "Alerts"

// Market Structure
pivotLenInput           = input.int(7, "MSB Pivot Lookback", minval = 1, group = MS_GROUP)
msbZScoreInput          = input.float(0.5, "MSB Momentum Z-Score", minval = 0.1, step = 0.1, group = MS_GROUP)

// Equilibrium Zones
sigPivotLenInput        = input.int(21, "Significant Pivot Lookback", minval = 1, group = EQ_GROUP)
zoneHeightPctInput      = input.float(10.0, "Zone Height % of Leg", minval = 1.0, maxval = 50.0, step = 0.5, group = EQ_GROUP)
projectBarsInput        = input.int(60, "Projection Distance", minval = 0, group = EQ_GROUP)

// Trend Settings
showTrendInput          = input.bool(true, "Show Trend Dashboard", group = TREND_GROUP)
emaFilterInput          = input.int(200, "Trend Filter EMA", minval = 1, group = TREND_GROUP)

// Trade Settings
showTradesInput         = input.bool(true, "Show Auto TP/SL Boxes", group = TRADE_GROUP)

// Alert Settings
alertSetupInput         = input.bool(true, "Trade Setup Triggered", group = ALERT_GROUP)
alertRetraceInput       = input.bool(true, "Price Hits 50% Level", group = ALERT_GROUP)
alertMSBInput           = input.bool(true, "MSB Forms", group = ALERT_GROUP)
alertTrendInput         = input.bool(true, "Trend Change", group = ALERT_GROUP)

//---------------------------------------------------------------------------------------------------------------------}
// Core Calculations
//---------------------------------------------------------------------------------------------------------------------{
// --- Trend & Momentum ---
float ema200 = ta.ema(close, emaFilterInput)

// --- Significant Pivot Detection (Fib Leg & Trend) ---
float ph_sig = ta.pivothigh(high, sigPivotLenInput, sigPivotLenInput)
float pl_sig = ta.pivotlow(low, sigPivotLenInput, sigPivotLenInput)

var float sigH     = na
var float prevSigH = na
var int   sigHIdx  = na
var float sigL     = na
var float prevSigL = na
var int   sigLIdx  = na
var bool  isTouched = false
var bool  hasTradedThisRetrace = false

if not na(ph_sig)
    prevSigH  := sigH
    sigH      := ph_sig
    sigHIdx   := bar_index - sigPivotLenInput
    isTouched := false 
    hasTradedThisRetrace := false

if not na(pl_sig)
    prevSigL  := sigL
    sigL      := pl_sig
    sigLIdx   := bar_index - sigPivotLenInput
    isTouched := false 
    hasTradedThisRetrace := false 

// Determine Trend
string trendStatus = "NEUTRAL"
color  trendColor  = color.gray

bool structureBull = sigH > prevSigH and sigL > prevSigL
bool structureBear = sigH < prevSigH and sigL < prevSigL

if structureBull and close > ema200
    trendStatus := "STRONG BULLISH", trendColor := BULL_COLOR
else if structureBull
    trendStatus := "BULLISH", trendColor := BULL_COLOR
else if structureBear and close < ema200
    trendStatus := "STRONG BEARISH", trendColor := BEAR_COLOR
else if structureBear
    trendStatus := "BEARISH", trendColor := BEAR_COLOR

// Trend Change Alert
var string lastTrend = trendStatus
if alertTrendInput and trendStatus != lastTrend
    alert("Trend changed to: " + trendStatus, alert.freq_once_per_bar)
    lastTrend := trendStatus

// EMA Plot
plot(ema200, "Trend Filter EMA", color = color.new(trendColor, 50), linewidth = 2)

// --- Visual Objects (Fib) ---
var line  diagLine  = line.new(na, na, na, na, color = FIB_COLOR, style = line.style_dashed)
var line  highLine  = line.new(na, na, na, na, color = FIB_COLOR, style = line.style_dashed)
var line  lowLine   = line.new(na, na, na, na, color = FIB_COLOR, style = line.style_dashed)
var line  midLine   = line.new(na, na, na, na, color = FIB_COLOR, style = line.style_dashed, width = 1)
var box   eqBox     = box.new(na, na, na, na,  bgcolor = color.new(FIB_COLOR, 85), border_color = FIB_COLOR)
var label highLabel = label.new(na, na, "", style = label.style_label_left, textcolor = FIB_COLOR, size = size.small, color = #00000000)
var label lowLabel  = label.new(na, na, "", style = label.style_label_left, textcolor = FIB_COLOR, size = size.small, color = #00000000)
var label midLabel  = label.new(na, na, "", style = label.style_label_left, textcolor = FIB_COLOR, size = size.small, color = #00000000)

float midPrice    = math.avg(sigH, sigL)
float legRange    = math.abs(sigH - sigL)
float zoneOffset  = legRange * (zoneHeightPctInput / 200.0)
float boxTopVal   = midPrice + zoneOffset
float boxBottomVal = midPrice - zoneOffset

updateFib(float startY, int startX, float endY, int endX, float bTop, float bBottom, bool touched, string currentTrend, bool isDownwardLeg) =>
    float hi     = math.max(startY, endY)
    float lo     = math.min(startY, endY)
    float mid    = math.avg(startY, endY)
    int   right  = bar_index + projectBarsInput
    color activeColor = touched ? YELLOW_COLOR : FIB_COLOR
    color legColor    = isDownwardLeg ? BEAR_COLOR : BULL_COLOR
    string labelExtra = ""
    bool tBull = currentTrend == "BULLISH" or currentTrend == "STRONG BULLISH"
    bool tBear = currentTrend == "BEARISH" or currentTrend == "STRONG BEARISH"

    if touched
        if currentTrend == "NEUTRAL"
            labelExtra  := " - ❌ DO NOT TRADE (NEUTRAL TREND)", activeColor := color.new(BEAR_COLOR, 30)
        else if isDownwardLeg and tBear
            labelExtra  := " - READY ✅ Look for Bearish MSB"
        else if not isDownwardLeg and tBull
            labelExtra  := " - READY ✅ Look for Bullish MSB"
        else
            labelExtra  := " - ❌ DO NOT TRADE (COUNTER-TREND)", activeColor := color.new(BEAR_COLOR, 30)

    diagLine.set_xy1(startX, startY), diagLine.set_xy2(endX, endY), diagLine.set_color(legColor)
    highLine.set_xy1(startX, hi), highLine.set_xy2(right, hi), highLine.set_color(legColor)
    lowLine.set_xy1(startX, lo), lowLine.set_xy2(right, lo), lowLine.set_color(legColor)
    midLine.set_xy1(endX, mid), midLine.set_xy2(right, mid), midLine.set_color(activeColor)
    eqBox.set_lefttop(endX, bTop), eqBox.set_rightbottom(right, bBottom), eqBox.set_bgcolor(color.new(activeColor, 85)), eqBox.set_border_color(activeColor)
    highLabel.set_xy(right, hi), highLabel.set_text("1 (" + str.tostring(hi, format.mintick) + ")"), highLabel.set_textcolor(legColor)
    lowLabel.set_xy(right, lo), lowLabel.set_text("0 (" + str.tostring(lo, format.mintick) + ")"), lowLabel.set_textcolor(legColor)
    midLabel.set_xy(right, mid), midLabel.set_text("0.5 (" + str.tostring(mid, format.mintick) + ")" + labelExtra), midLabel.set_textcolor(activeColor)

if not na(sigH) and not na(sigL)
    if not isTouched and low <= boxTopVal and high >= boxBottomVal
        isTouched := true
        if alertRetraceInput
            alert("Price has reached the 50% Equilibrium Zone", alert.freq_once_per_bar)

    bool isDownLeg = sigHIdx < sigLIdx
    updateFib(isDownLeg ? sigH : sigL, isDownLeg ? sigHIdx : sigLIdx, isDownLeg ? sigL : sigH, isDownLeg ? sigLIdx : sigHIdx, boxTopVal, boxBottomVal, isTouched, trendStatus, isDownLeg)

// --- MSB Detection ---
float ph = ta.pivothigh(high, pivotLenInput, pivotLenInput)
float pl = ta.pivotlow(low, pivotLenInput, pivotLenInput)
var float lastPh = na, var float lastPl = na
var int lastPhIdx = na, var int lastPlIdx = na
if not na(ph)
    lastPh := ph, lastPhIdx := bar_index - pivotLenInput
if not na(pl)
    lastPl := pl, lastPlIdx := bar_index - pivotLenInput

float priceChange = ta.change(close)
float avgChange   = ta.sma(priceChange, 50)
float stdChange   = ta.stdev(priceChange, 50)
float momentumZ   = (priceChange - avgChange) / stdChange
bool isMSBBull = close > lastPh and close[1] <= lastPh and momentumZ > msbZScoreInput
bool isMSBBear = close < lastPl and close[1] >= lastPl and momentumZ < -msbZScoreInput

if alertMSBInput
    if isMSBBull
        alert("Bullish Market Structure Break detected", alert.freq_once_per_bar)
    if isMSBBear
        alert("Bearish Market Structure Break detected", alert.freq_once_per_bar)

// --- Trade Management ---
var bool  inTrade = false
var bool  tradeIsLong = false
var float tradeTP = na
var float tradeSL = na
var box   tpBox   = na
var box   slBox   = na

// Exit Logic
if inTrade
    // Project active boxes forward
    tpBox.set_right(bar_index + 10)
    slBox.set_right(bar_index + 10)

    bool tpTrigger = tradeIsLong ? high >= tradeTP : low <= tradeTP
    bool slTrigger = tradeIsLong ? low <= tradeSL : high >= tradeSL
    
    if tpTrigger or slTrigger
        inTrade := false
        // Finalize boxes at the trigger bar
        tpBox.set_right(bar_index)
        slBox.set_right(bar_index)
        tpBox.set_bgcolor(color.new(BULL_COLOR, tpTrigger ? 70 : 90))
        slBox.set_bgcolor(color.new(BEAR_COLOR, slTrigger ? 70 : 90))

// Entry Logic
if not inTrade and not hasTradedThisRetrace and showTradesInput and isTouched
    // Long Entry: Must be an Upward Leg (sigLIdx < sigHIdx) and Bullish Trend
    if isMSBBull and (trendStatus == "BULLISH" or trendStatus == "STRONG BULLISH") and (sigLIdx < sigHIdx)
        if close > boxBottomVal
            inTrade     := true
            hasTradedThisRetrace := true
            tradeIsLong := true
            tradeTP     := sigH
            tradeSL     := boxBottomVal
            tpBox       := box.new(bar_index, tradeTP, bar_index + 10, close, bgcolor = color.new(BULL_COLOR, 85), border_color = na)
            slBox       := box.new(bar_index, close, bar_index + 10, tradeSL, bgcolor = color.new(BEAR_COLOR, 85), border_color = na)
            if alertSetupInput
                alert("Long Trade Setup Triggered!", alert.freq_once_per_bar)
    
    // Short Entry: Must be a Downward Leg (sigHIdx < sigLIdx) and Bearish Trend
    else if isMSBBear and (trendStatus == "BEARISH" or trendStatus == "STRONG BEARISH") and (sigHIdx < sigLIdx)
        if close < boxTopVal
            inTrade     := true
            hasTradedThisRetrace := true
            tradeIsLong := false
            tradeTP     := sigL
            tradeSL     := boxTopVal
            tpBox       := box.new(bar_index, close, bar_index + 10, tradeTP, bgcolor = color.new(BULL_COLOR, 85), border_color = na)
            slBox       := box.new(bar_index, tradeSL, bar_index + 10, close, bgcolor = color.new(BEAR_COLOR, 85), border_color = na)
            if alertSetupInput
                alert("Short Trade Setup Triggered!", alert.freq_once_per_bar)

// Final MSB Drawing
if isMSBBull
    line.new(lastPhIdx, lastPh, bar_index, lastPh, color = BULL_COLOR, width = 1)
    label.new(math.round(math.avg(lastPhIdx, bar_index)), lastPh, "MSB", color = #00000000, textcolor = BULL_COLOR, style = label.style_label_down, size = size.small), lastPh := na
if isMSBBear
    line.new(lastPlIdx, lastPl, bar_index, lastPl, color = BEAR_COLOR, width = 1)
    label.new(math.round(math.avg(lastPlIdx, bar_index)), lastPl, "MSB", color = #00000000, textcolor = BEAR_COLOR, style = label.style_label_up, size = size.small), lastPl := na

// Dashboard
var table dash = table.new(position.top_right, 2, 1, bgcolor = #161616, border_color = #2E2E2E, border_width = 1)
if showTrendInput and barstate.islast
    table.cell(dash, 0, 0, "Overall Trend", text_color = #808080, text_size = size.small)
    table.cell(dash, 1, 0, trendStatus, text_color = trendColor, text_size = size.small)

//---------------------------------------------------------------------------------------------------------------------}
````
