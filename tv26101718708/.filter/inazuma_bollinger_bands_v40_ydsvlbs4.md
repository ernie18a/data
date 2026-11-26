# INAZUMA Bollinger Bands [v4.0]

- url: https://www.tradingview.com/script/ydsVlbS4/
- type: indicator
- pine_id: PUB;8a8d80cf29444ffda3941510da22c8f3
- version: 1.0

## Description

[b]Overview[/b]
 This indicator detects Bollinger Band ±2σ breaks ("Band Walk") and visualizes trend initiation and continuation with "Lightning/Magma" effects and count labels. v4.0 introduces the new "Squeeze (Rocket/Waterfall)" logic to capture strong trend continuations, complete with new dynamic visual effects.

v4.0 Updates 
Squeeze (Rocket) Detection & Visuals: 
Added logic to detect strong momentum (such as short squeezes) where the price pulls back from the 2σ band but continues to push beyond the 1σ band.

Rocket Flames (Uptrend):
 Visualizes upward squeezes with a high-heat gradient (White/Yellow/Orange/Red) between the candle low and the Upper 1σ band, resembling a rocket launch.
Blue Waterfall (Downtrend): 
Visualizes downward squeezes with a dynamic blue gradient between the candle high and the Lower 1σ band.

Squeeze Counter:
 Displays the consecutive number of squeeze bars directly on the chart, utilizing a memory-efficient single-label tracking system.

[b]Features[/b]
Visual Effects:
 Draws distinct gradients for both ±2σ Band Walks (Lightning/Magma) and ±1σ Squeezes (Rocket/Waterfall).
Consecutive Count Labels: Displays the number of consecutive band walks and squeezes directly on the chart.
Smart Alerts: Built-in alerts for 3-bar consecutive squeezes to notify you of strong trend formations.
Multi-Timeframe Settings (for Screener): You can change the timeframe used for screener calculations (1D, 1W, 1M) via "Filter Timeframe" in the settings.

[b]How to use with Screener[/b]
Select this indicator in the Pine Screener.
Add "MTF Up Bandwalk Count" or "MTF Down Bandwalk Count" to your columns.
Set the desired timeframe (default: "1M") in the "Filter Timeframe" setting of the indicator.
Calculations are performed in real-time without waiting for the bar to close.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © maru_jp
//@version=6
indicator("INAZUMA Bollinger Bands [v4.0]", overlay=true, max_labels_count=500)

// =============== Settings ===============
group_bb = "Bollinger Bands Settings"
len  = input.int(20, "Length", minval=1, group=group_bb)
mult = input.float(2.0, "StdDev", minval=0.001, maxval=50, group=group_bb)
src  = input.source(close, "Source", group=group_bb)
tf_filter = input.string("1M", "Filter Timeframe", options=["1D", "1W", "1M"], group=group_bb, tooltip="Timeframe used for screener filter calculation")

// =============== Calculations ===============
basis = ta.sma(src, len)
dev   = ta.stdev(src, len)

// 2σ (Main Bands)
upper = basis + mult * dev
lower = basis - mult * dev

// 1σ (Inner Bands for Reference)
upper1 = basis + dev
lower1 = basis - dev

// =============== Plotting Standard Bands ===============
plot(basis, "Basis", color=color.new(#bba800, 75))
plot(upper1, "Upper 1σ", color=color.new(color.green, 75))
plot(lower1, "Lower 1σ", color=color.new(color.red, 75))
plot(upper, "Upper Band", color=color.new(color.green, 50))
plot(lower, "Lower Band", color=color.new(color.red, 50))

// =============== Bandwalk Counter Logic ===============
var int upCount = 0
var int dnCount = 0
var label upLabel = na
var label dnLabel = na

isUpWalk = high > upper
isDnWalk = low < lower

upCount := isUpWalk ? upCount + 1 : 0
dnCount := isDnWalk ? dnCount + 1 : 0

// =============== Squeeze (Rocket) Logic ===============
var bool isUpSqueeze = false
var bool isDnSqueeze = false

if isUpWalk
    isUpSqueeze := false
else if (upCount[1] > 0 or isUpSqueeze[1]) and low > upper1
    isUpSqueeze := true
else
    isUpSqueeze := false

if isDnWalk
    isDnSqueeze := false
else if (dnCount[1] > 0 or isDnSqueeze[1]) and high < lower1
    isDnSqueeze := true
else
    isDnSqueeze := false

var int upSqCount = 0
var int dnSqCount = 0
var label upSqLabel = na
var label dnSqLabel = na

upSqCount := isUpSqueeze ? upSqCount + 1 : 0
dnSqCount := isDnSqueeze ? dnSqCount + 1 : 0

// --- MTF Filter Data Output (e.g., Monthly) ---
// Calculates Bandwalk Count for the specified timeframe (default: Monthly)
calc_bandwalk(_len, _mult) =>
    _basis = ta.sma(close, _len)
    _dev   = ta.stdev(close, _len)
    _upper = _basis + _mult * _dev
    _lower = _basis - _mult * _dev
    _isUp  = high > _upper
    _isDn  = low < _lower
    // barstate.isconfirmed is intentionally avoided here.
    // Using it would prevent values from updating until the bar closes (e.g., end of month), preventing real-time screening.
    var int _uc = 0
    var int _dc = 0
    _uc := _isUp ? _uc + 1 : 0
    _dc := _isDn ? _dc + 1 : 0
    [_uc, _dc]

[mtfUp, mtfDn] = request.security(syminfo.tickerid, tf_filter, calc_bandwalk(len, mult))
plot(mtfUp, "MTF Up Bandwalk Count", display=display.none)
plot(mtfDn, "MTF Down Bandwalk Count", display=display.none)

// --- Label Logic (Latest Only) ---
if upCount > 0
    float labelY = upper + (high - upper) * (high / upper) * 4.5
    if upCount == 1
        upLabel := label.new(bar_index, labelY, text=str.tostring(upCount), style=label.style_label_down, color=color.new(color.green, 20), textcolor=color.white, size=size.tiny)
    else
        label.set_xy(upLabel, bar_index, labelY)
        label.set_text(upLabel, str.tostring(upCount))
else
    upLabel := na

if dnCount > 0
    float labelY = lower - (lower - low) * (lower / low) * 4.5
    if dnCount == 1
        dnLabel := label.new(bar_index, labelY, text=str.tostring(dnCount), style=label.style_label_up, color=color.new(color.red, 20), textcolor=color.white, size=size.tiny)
    else
        label.set_xy(dnLabel, bar_index, labelY)
        label.set_text(dnLabel, str.tostring(dnCount))
else
    dnLabel := na

// --- Squeeze Label Logic ---
if upSqCount > 0
    float labelY = upper1 - dev * 0.5
    if upSqCount == 1
        upSqLabel := label.new(bar_index, labelY, text=str.tostring(upSqCount), style=label.style_label_up, color=color.new(#ffab66, 20), textcolor=color.white, size=size.tiny)
    else
        label.set_xy(upSqLabel, bar_index, labelY)
        label.set_text(upSqLabel, str.tostring(upSqCount))
else
    upSqLabel := na

if dnSqCount > 0
    float labelY = lower1 + dev * 0.5
    if dnSqCount == 1
        dnSqLabel := label.new(bar_index, labelY, text=str.tostring(dnSqCount), style=label.style_label_down, color=color.new(#00bfff, 20), textcolor=color.white, size=size.tiny)
    else
        label.set_xy(dnSqLabel, bar_index, labelY)
        label.set_text(dnSqLabel, str.tostring(dnSqCount))
else
    dnSqLabel := na

// =============== Upper Side (Green Base / Flare) ===============
condHigh  = isUpWalk ? high : na
condUpper = isUpWalk ? upper : na
HighDeviationRatio = high / upper
diffUpper = (condHigh - condUpper) * HighDeviationRatio

pHigh   = plot(condHigh, color=color.rgb(0, 200, 0, 95), style=plot.style_linebr, title="High > Upper")
pUpper  = plot(condUpper + diffUpper,     color=color.new(#145a32, 95), style=plot.style_linebr)
pUpper2 = plot(condUpper + diffUpper * 2, color=color.new(#145a32, 95), style=plot.style_linebr)
pUpper3 = plot(condUpper + diffUpper * 3, color=color.new(#145a32, 95), style=plot.style_linebr)
pUpper4 = plot(condUpper + diffUpper * 4, color=color.new(#145a32, 95), style=plot.style_linebr)

fill(pHigh,   pUpper,  color=color.new(#ccffcc, 10), title="Fill L1") 
fill(pUpper,  pUpper2, color=color.new(#66ff66, 20), title="Fill L2") 
fill(pUpper2, pUpper3, color=color.new(#00cc44, 30), title="Fill L3") 
fill(pUpper3, pUpper4, color=color.new(#00ff6e, 75), title="Fill L4") 

// =============== Lower Side (Red Base / Magma) ===============
condLow   = isDnWalk ? low : na
condLower = isDnWalk ? lower : na
LowDeviationRatio = lower / low
diffLower = (condLower - condLow) * LowDeviationRatio

pLow    = plot(condLow, color=color.rgb(255, 0, 0, 95), style=plot.style_linebr, title="Low < Lower")
pLower  = plot(condLower - diffLower,     color=color.new(#7b241c, 95), style=plot.style_linebr)
pLower2 = plot(condLower - diffLower * 2, color=color.new(#7b241c, 95), style=plot.style_linebr)
pLower3 = plot(condLower - diffLower * 3, color=color.new(#7b241c, 95), style=plot.style_linebr)
pLower4 = plot(condLower - diffLower * 4, color=color.new(#7b241c, 95), style=plot.style_linebr)

fill(pLow,    pLower,  color=color.new(#ffcccc, 10), title="Fill S1") 
fill(pLower,  pLower2, color=color.new(#ff6666, 20), title="Fill S2") 
fill(pLower2, pLower3, color=color.new(#cc0000, 30), title="Fill S3") 
fill(pLower3, pLower4, color=color.new(#ff0101, 75), title="Fill S4")

// =============== Upper Squeeze (Rocket Flames) ===============
// Fills the area between the candle low and 1σ with an orange gradient
condSqLow    = isUpSqueeze ? low : na
condSqUpper1 = isUpSqueeze ? upper1 : na
diffUpSq     = (condSqLow - condSqUpper1) / 4

pSqUp0 = plot(condSqLow, color=color.rgb(255, 255, 255, 90), style=plot.style_linebr, title="Sq Up Low")
pSqUp1 = plot(condSqLow - diffUpSq,     color=na, style=plot.style_linebr)
pSqUp2 = plot(condSqLow - diffUpSq * 2, color=na, style=plot.style_linebr)
pSqUp3 = plot(condSqLow - diffUpSq * 3, color=na, style=plot.style_linebr)
pSqUp4 = plot(condSqUpper1,             color=na, style=plot.style_linebr)

fill(pSqUp0, pSqUp1, color=color.new(#ffcccc, 10), title="Sq Up L1") // Near the candle (White / Extreme Heat)
fill(pSqUp1, pSqUp2, color=color.new(#ffab66, 0),  title="Sq Up L2") // (Yellow)
fill(pSqUp2, pSqUp3, color=#ff9114b9,              title="Sq Up L3") // (Orange)
fill(pSqUp3, pSqUp4, color=color.new(#ff0101, 75), title="Sq Up L4") // Near 1σ (Red / Light)

// =============== Lower Squeeze (Blue Waterfall) ===============
// Fills the area between the candle high and -1σ with a blue gradient
condSqHigh   = isDnSqueeze ? high : na
condSqLower1 = isDnSqueeze ? lower1 : na
diffDnSq     = (condSqLower1 - condSqHigh) / 4

pSqDn0 = plot(condSqHigh, color=color.rgb(0, 200, 255, 95), style=plot.style_linebr, title="Sq Dn High")
pSqDn1 = plot(condSqHigh + diffDnSq,     color=na, style=plot.style_linebr)
pSqDn2 = plot(condSqHigh + diffDnSq * 2, color=na, style=plot.style_linebr)
pSqDn3 = plot(condSqHigh + diffDnSq * 3, color=na, style=plot.style_linebr)
pSqDn4 = plot(condSqLower1,              color=na, style=plot.style_linebr)

fill(pSqDn0, pSqDn1, color=color.new(#00ffff, 40), title="Sq Dn L1") 
fill(pSqDn1, pSqDn2, color=color.new(#00bfff, 55), title="Sq Dn L2") 
fill(pSqDn2, pSqDn3, color=color.new(#0080ff, 70), title="Sq Dn L3") 
fill(pSqDn3, pSqDn4, color=color.new(#0000ff, 85), title="Sq Dn L4")
````
