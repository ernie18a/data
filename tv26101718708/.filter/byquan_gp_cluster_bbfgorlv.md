# byquan GP + Cluster

- url: https://www.tradingview.com/script/bbfgOrlv/
- type: indicator
- pine_id: PUB;c73652df40d9470682ed9c92b6bf2290
- version: 1.0

## Description

GP + Cluster
This indicator is a multi-timeframe Stochastic RSI (SRSI) channel designed to help traders identify dynamic support/resistance zones, filtered reversal points, and high-probability cluster formations.
Key Features:

Multi-Timeframe SRSI Channel: Combines Stochastic RSI from 4 different hourly timeframes (default: 3H, 6H, 12H, 24H) to create a smoothed channel showing collective momentum behavior.
Filtered Local Extremes: Detects significant local highs and lows with a minimum price difference filter to reduce noise and highlight only meaningful turning points.
Cluster Detection: Automatically identifies MIN-MAX-MIN and MAX-MIN-MAX patterns within a user-defined window (default 200 bars). These clusters often indicate areas of strong momentum exhaustion or potential reversals.
Extreme Confirmation System: Tracks price action after crossing key levels (20/80) and confirms reversals after a user-defined number of bars.
Visual Zones: Clear color-coded background zones (Oversold, Neutral, Overbought) and channel fill for better readability.

How to Use:

Channel Analysis:
The channel (Min/Max) represents broader momentum. Price near the upper band (green) suggests strength, while near the lower band (red) suggests weakness.

Filtered Extremes:
Red "MAX" and Lime "MIN" labels mark high-probability swing points.

Cluster Signals:
Background color + labels highlight MIN-MAX-MIN (lime) and MAX-MIN-MAX (red) clusters. These are often strong inflection zones.

Confirmed Reversals:
Yellow circles show initial crosses through the mid-level (50).
Lime/Red circles mark confirmed extremes after sustained momentum in one direction.


Settings:

Adjustable K/D smoothing, RSI & Stoch lengths
Customizable multi-timeframe inputs (in hours)
Watch levels (20/50/80), confirmation bars, lookback periods, and cluster window

This tool works on all timeframes but performs best when used on lower timeframes while referencing higher hourly momentum.

Disclaimer: This indicator is provided for educational and informational purposes only. It does not constitute financial advice. Always do your own research and backtest thoroughly before using any trading strategy.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
//@version=6
indicator("byquan GP - SRSI Channel (Hour TF) + Filtered Local Extremes + Cluster", shorttitle="GP - SRSI H + Ext + Cluster", overlay=false)

// =====================================================
// INPUTS
// =====================================================
smoothK   = input.int(3,  "K", minval=1)
smoothD   = input.int(3,  "D", minval=1)
lengthRSI = input.int(14, "RSI Length", minval=1)
lengthS   = input.int(14, "Stoch Length", minval=1)

// ==== Timeframes in HOURS ====
tf1_h = input.int(3,  "Time 1 (hours)", minval=1)
tf2_h = input.int(6,  "Time 2 (hours)", minval=1)
tf3_h = input.int(12, "Time 3 (hours)", minval=1)
tf4_h = input.int(24, "Time 4 (hours)", minval=1)

// =====================================================
// LEVEL INPUTS
// =====================================================
watchLow    = input.int(20, "Watch Low Level")
watchHigh   = input.int(80, "Watch High Level")
midLevel    = input.int(50, "Mid Level")
confirmBars = input.int(10, "Confirm bars", minval=1)

extremeLookback = input.int(25, "Local Extreme Lookback (bars each side)", minval=5)
minDiff         = input.int(10, "Minimum Difference between adjacent Min-Max", minval=5)

// ==== Cluster ====
clusterWindow = input.int(200, "Cluster max bars (span)", minval=10)

// =====================================================
// CONVERT HOURS → MINUTES
// =====================================================
tf1 = str.tostring(tf1_h * 60)
tf2 = str.tostring(tf2_h * 60)
tf3 = str.tostring(tf3_h * 60)
tf4 = str.tostring(tf4_h * 60)

// =====================================================
// FUNCTION: SRSI
// =====================================================
f_srsi(_src) =>
    rsiVal = ta.rsi(_src, lengthRSI)
    k = ta.sma(ta.stoch(rsiVal, rsiVal, rsiVal, lengthS), smoothK)
    d = ta.sma(k, smoothD)
    k + d

// =====================================================
// CALCULATE SRSI + ORAN
// =====================================================
ds_open  = f_srsi(open)
ds_high  = f_srsi(high)
ds_low   = f_srsi(low)
ds_close = f_srsi(close)

stArr = array.from(ds_open, ds_high, ds_low, ds_close)
stMin = array.min(stArr)
stMax = array.max(stArr)

a1 = request.security(syminfo.tickerid, tf1, stMin)
a2 = request.security(syminfo.tickerid, tf2, stMin)
a3 = request.security(syminfo.tickerid, tf3, stMin)
a4 = request.security(syminfo.tickerid, tf4, stMin)

b1 = request.security(syminfo.tickerid, tf1, stMax)
b2 = request.security(syminfo.tickerid, tf2, stMax)
b3 = request.security(syminfo.tickerid, tf3, stMax)
b4 = request.security(syminfo.tickerid, tf4, stMax)

c1 = request.security(syminfo.tickerid, tf1, ds_close)
c2 = request.security(syminfo.tickerid, tf2, ds_close)
c3 = request.security(syminfo.tickerid, tf3, ds_close)
c4 = request.security(syminfo.tickerid, tf4, ds_close)

oranMin   = (a1 + a2 + a3 + a4) * 100 / 800
oranMax   = (b1 + b2 + b3 + b4) * 100 / 800
oranClose = (c1 + c2 + c3 + c4) * 100 / 800

// =====================================================
// ZONES
// =====================================================
h0   = hline(0)
h20  = hline(20)
h50  = hline(50)
h80  = hline(80)
h100 = hline(100)

fill(h0,  h20,  color=color.new(color.green, 88))
fill(h20, h50,  color=color.new(color.blue, 90))
fill(h50, h80,  color=color.new(color.orange, 90))
fill(h80, h100, color=color.new(color.red, 88))

// =====================================================
// PLOTS CHANNEL
// =====================================================
pMin = plot(oranMin, title="Min", color=color.red)
pMax = plot(oranMax, title="Max", color=color.green)
plot(oranClose, title="Close", color=color.white, linewidth=2)
fill(pMin, pMax, color=color.new(color.gray, 85))

// =====================================================
// FILTERED LOCAL EXTREMES (Min-Max adjacent + diff >= 10)
// =====================================================
localMaxRaw = ta.pivothigh(oranClose, extremeLookback, extremeLookback)
localMinRaw = ta.pivotlow(oranClose, extremeLookback, extremeLookback)

var float  lastPivotValue = na
var bool   lastWasMax     = false
var int    lastPivotBar   = na

bool showMax = false
bool showMin = false
float plotMaxVal = na
float plotMinVal = na

if not na(localMaxRaw)
    if not na(lastPivotValue) and not lastWasMax
        diff = localMaxRaw - lastPivotValue
        if diff >= minDiff
            showMax := true
            plotMaxVal := localMaxRaw
    // Cập nhật last pivot
    lastPivotValue := localMaxRaw
    lastWasMax     := true
    lastPivotBar   := bar_index

if not na(localMinRaw)
    if not na(lastPivotValue) and lastWasMax
        diff = lastPivotValue - localMinRaw
        if diff >= minDiff
            showMin := true
            plotMinVal := localMinRaw
    // Cập nhật last pivot
    lastPivotValue := localMinRaw
    lastWasMax     := false
    lastPivotBar   := bar_index

// Plot only filtered extremes
plotshape(showMax ? plotMaxVal : na, title="Filtered Local Max", 
     location=location.absolute, color=color.red, style=shape.labeldown, 
     text="MAX", textcolor=color.white, size=size.small)

plotshape(showMin ? plotMinVal : na, title="Filtered Local Min", 
     location=location.absolute, color=color.lime, style=shape.labelup, 
     text="MIN", textcolor=color.black, size=size.small)

// =====================================================
// CLUSTER DETECTION: MIN-MAX-MIN / MAX-MIN-MAX trong 200 nến
// =====================================================
// Lưu 3 tín hiệu gần nhất: bar_index xác nhận + loại (true=MAX, false=MIN)
var array<int>  sigBars  = array.new_int()
var array<bool> sigIsMax = array.new_bool()

bool newSignal = showMax or showMin
if newSignal
    array.push(sigBars,  bar_index)
    array.push(sigIsMax, showMax)            // showMax=true => MAX, ngược lại MIN
    if array.size(sigBars) > 3
        array.shift(sigBars)
        array.shift(sigIsMax)

bool clusterMinMaxMin = false   // MIN - MAX - MIN
bool clusterMaxMinMax = false   // MAX - MIN - MAX
int  clusterSpan      = na

if newSignal and array.size(sigBars) == 3
    b0 = array.get(sigBars, 0)
    b2c = array.get(sigBars, 2)
    t0 = array.get(sigIsMax, 0)
    t1 = array.get(sigIsMax, 1)
    t2 = array.get(sigIsMax, 2)
    span = b2c - b0
    if span <= clusterWindow
        clusterSpan := span
        if (not t0) and t1 and (not t2)
            clusterMinMaxMin := true
        if t0 and (not t1) and t2
            clusterMaxMinMax := true

bool clusterFound = clusterMinMaxMin or clusterMaxMinMax

// ----- Đánh dấu cụm trên chart -----
bgcolor(clusterMinMaxMin ? color.new(color.lime, 85) : na, title="Cluster MIN-MAX-MIN")
bgcolor(clusterMaxMinMax ? color.new(color.red,  85) : na, title="Cluster MAX-MIN-MAX")

if clusterFound
    string txt = clusterMinMaxMin ? "MIN-MAX-MIN" : "MAX-MIN-MAX"
    label.new(bar_index, oranClose,
         text=txt + "\n(" + str.tostring(clusterSpan) + " bars)",
         color=clusterMinMaxMin ? color.lime : color.red,
         textcolor=color.black, style=label.style_label_down, size=size.small)

// ----- Cảnh báo cụm -----
alertcondition(clusterFound,     title="SRSI Cluster (any)",        message="SRSI cụm Min-Max xuất hiện: {{ticker}} | TF {{interval}}")
alertcondition(clusterMinMaxMin, title="SRSI Cluster MIN-MAX-MIN",  message="SRSI cụm MIN-MAX-MIN: {{ticker}} | TF {{interval}}")
alertcondition(clusterMaxMinMax, title="SRSI Cluster MAX-MIN-MAX",  message="SRSI cụm MAX-MIN-MAX: {{ticker}} | TF {{interval}}")

if clusterFound
    alert("SRSI cụm " + (clusterMinMaxMin ? "MIN-MAX-MIN" : "MAX-MIN-MAX") + " xuất hiện (span " + str.tostring(clusterSpan) + " bars)", alert.freq_once_per_bar)

// =====================================================
// MID SIGNAL & EXTREME CONFIRMATION
// =====================================================
var bool watchFromLow  = false
var bool watchFromHigh = false

if oranClose <= watchLow and not watchFromLow and not watchFromHigh
    watchFromLow := true

if oranClose >= watchHigh and not watchFromHigh and not watchFromLow
    watchFromHigh := true

triggerFromLow  = watchFromLow and oranClose >= midLevel
triggerFromHigh = watchFromHigh and oranClose <= midLevel

if triggerFromLow or triggerFromHigh
    watchFromLow := false
    watchFromHigh := false

plot((triggerFromLow or triggerFromHigh) ? midLevel : na, style=plot.style_circles, linewidth=3, color=color.yellow)

// Extreme Confirmation
var float Dec = na
var float Inc = na
var bool trackingDec = false
var bool trackingInc = false
var int decCount = 0
var int incCount = 0

if triggerFromHigh
    Dec := oranClose
    trackingDec := true
    decCount := 0

if triggerFromLow
    Inc := oranClose
    trackingInc := true
    incCount := 0

confirmedMin = false
if trackingDec
    if oranClose < Dec
        Dec := oranClose
        decCount := 0
    else
        decCount += 1
    if decCount >= confirmBars
        trackingDec := false
        confirmedMin := true

confirmedMax = false
if trackingInc
    if oranClose > Inc
        Inc := oranClose
        incCount := 0
    else
        incCount += 1
    if incCount >= confirmBars
        trackingInc := false
        confirmedMax := true

plot(confirmedMin ? Dec : na, style=plot.style_circles, linewidth=3, color=color.lime)
plot(confirmedMax ? Inc : na, style=plot.style_circles, linewidth=3, color=color.red)

// =====================================================
// ALERT
// =====================================================
alertcondition(confirmedMin or confirmedMax, title="SRSI Confirmed Extreme", message="SRSI xác nhận đảo chiều: {{ticker}} | TF {{interval}}")
````
