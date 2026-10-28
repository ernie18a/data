# MTF EMA 200 Cloud - Smart Range

- url: https://www.tradingview.com/script/9gIqWLo5-MTF-EMA-200-Cloud-Smart-Range/
- type: indicator
- pine_id: PUB;cd51555aa3ff4ca3a85d8036ae06f53c
- version: 1.0

## Description

This indicator overlays a multi-timeframe EMA 200 cloud directly onto your chart to help identify higher timeframe trend structure, dynamic support/resistance, and momentum shifts without constantly switching charts.

Key Features:
• Multi-timeframe EMA 200 projection  
• Cloud visualization for trend bias  
• Acts as dynamic support and resistance  
• Helps identify trend continuation vs reversal zones  
• Clean overlay designed for intraday and swing trading  
• Useful for confluence with consolidation zones, volume profile, and price action

How I Use It:
• Price above the cloud = bullish bias  
• Price below the cloud = bearish bias  
• Compression inside the cloud often signals indecision or upcoming expansion  
• Strong reactions at cloud boundaries can provide high-probability entries/exits

The goal was to create a simple visual framework that keeps higher timeframe structure visible at all times while reducing chart clutter and timeframe hopping.

Works especially well for SPY, QQQ, futures, and momentum stocks.

Not financial advice — always combine with proper risk management and confirmation.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RiskReaperReward

//@version=6
indicator("MTF EMA 200 Cloud - Smart Range", overlay=true, max_bars_back=5000)

//----------------------------------------------------
// Inputs
//----------------------------------------------------
emaLen = input.int(200, "EMA Length", minval=1)

tf1 = input.timeframe("5", "Timeframe 1")
tf2 = input.timeframe("15", "Timeframe 2")
tf3 = input.timeframe("60", "Timeframe 3")
tf4 = input.timeframe("240", "Timeframe 4")
tf5 = input.timeframe("D", "Timeframe 5")
tf6 = input.timeframe("W", "Timeframe 6")

show1 = input.bool(true, "Show TF1")
show2 = input.bool(true, "Show TF2")
show3 = input.bool(true, "Show TF3")
show4 = input.bool(true, "Show TF4")
show5 = input.bool(true, "Show TF5")
show6 = input.bool(true, "Show TF6")

channelMode = input.string("ATR", "Channel Mode", options=["ATR", "Percent"])
atrLen      = input.int(14, "ATR Length", minval=1)
atrMult     = input.float(0.50, "ATR Multiplier", step=0.1)
pctWidth    = input.float(0.25, "Percent Width", step=0.01)

showMidline = input.bool(true, "Show EMA Midline")
showLabels  = input.bool(true, "Show Labels")
cloudTransp = input.int(88, "Cloud Transparency", minval=0, maxval=100)

// Smart visibility
useDistanceFilter = input.bool(true, "Hide Clouds Far From Price")
maxDistancePct    = input.float(2.0, "Max Distance % From Price", step=0.1)

// Optional: show only closest clouds
limitNearestOnly  = input.bool(false, "Only Show Nearest Clouds")
nearestCount      = input.int(3, "Nearest Clouds To Show", minval=1, maxval=6)

//----------------------------------------------------
// Functions
//----------------------------------------------------
f_ema(tf) =>
    request.security(syminfo.tickerid, tf, ta.ema(close, emaLen), barmerge.gaps_off, barmerge.lookahead_off)

f_atr(tf) =>
    request.security(syminfo.tickerid, tf, ta.atr(atrLen), barmerge.gaps_off, barmerge.lookahead_off)

f_upper(emaVal, atrVal) =>
    channelMode == "ATR" ? emaVal + (atrVal * atrMult) : emaVal * (1 + pctWidth / 100.0)

f_lower(emaVal, atrVal) =>
    channelMode == "ATR" ? emaVal - (atrVal * atrMult) : emaVal * (1 - pctWidth / 100.0)

f_distPct(val) =>
    math.abs(close - val) / close * 100.0

f_inRange(val) =>
    not useDistanceFilter or f_distPct(val) <= maxDistancePct

f_colorLine(val) =>
    close >= val ? color.lime : color.red

//----------------------------------------------------
// MTF Values
//----------------------------------------------------
ema1 = f_ema(tf1)
ema2 = f_ema(tf2)
ema3 = f_ema(tf3)
ema4 = f_ema(tf4)
ema5 = f_ema(tf5)
ema6 = f_ema(tf6)

atr1 = f_atr(tf1)
atr2 = f_atr(tf2)
atr3 = f_atr(tf3)
atr4 = f_atr(tf4)
atr5 = f_atr(tf5)
atr6 = f_atr(tf6)

up1 = f_upper(ema1, atr1)
dn1 = f_lower(ema1, atr1)

up2 = f_upper(ema2, atr2)
dn2 = f_lower(ema2, atr2)

up3 = f_upper(ema3, atr3)
dn3 = f_lower(ema3, atr3)

up4 = f_upper(ema4, atr4)
dn4 = f_lower(ema4, atr4)

up5 = f_upper(ema5, atr5)
dn5 = f_lower(ema5, atr5)

up6 = f_upper(ema6, atr6)
dn6 = f_lower(ema6, atr6)

//----------------------------------------------------
// Distance ranking
//----------------------------------------------------
d1 = f_distPct(ema1)
d2 = f_distPct(ema2)
d3 = f_distPct(ema3)
d4 = f_distPct(ema4)
d5 = f_distPct(ema5)
d6 = f_distPct(ema6)

isNearest1 = not limitNearestOnly or (
     (d1 <= d2 ? 1 : 0) + (d1 <= d3 ? 1 : 0) + (d1 <= d4 ? 1 : 0) + (d1 <= d5 ? 1 : 0) + (d1 <= d6 ? 1 : 0)
    ) >= (6 - nearestCount)

isNearest2 = not limitNearestOnly or (
     (d2 <= d1 ? 1 : 0) + (d2 <= d3 ? 1 : 0) + (d2 <= d4 ? 1 : 0) + (d2 <= d5 ? 1 : 0) + (d2 <= d6 ? 1 : 0)
    ) >= (6 - nearestCount)

isNearest3 = not limitNearestOnly or (
     (d3 <= d1 ? 1 : 0) + (d3 <= d2 ? 1 : 0) + (d3 <= d4 ? 1 : 0) + (d3 <= d5 ? 1 : 0) + (d3 <= d6 ? 1 : 0)
    ) >= (6 - nearestCount)

isNearest4 = not limitNearestOnly or (
     (d4 <= d1 ? 1 : 0) + (d4 <= d2 ? 1 : 0) + (d4 <= d3 ? 1 : 0) + (d4 <= d5 ? 1 : 0) + (d4 <= d6 ? 1 : 0)
    ) >= (6 - nearestCount)

isNearest5 = not limitNearestOnly or (
     (d5 <= d1 ? 1 : 0) + (d5 <= d2 ? 1 : 0) + (d5 <= d3 ? 1 : 0) + (d5 <= d4 ? 1 : 0) + (d5 <= d6 ? 1 : 0)
    ) >= (6 - nearestCount)

isNearest6 = not limitNearestOnly or (
     (d6 <= d1 ? 1 : 0) + (d6 <= d2 ? 1 : 0) + (d6 <= d3 ? 1 : 0) + (d6 <= d4 ? 1 : 0) + (d6 <= d5 ? 1 : 0)
    ) >= (6 - nearestCount)

//----------------------------------------------------
// Final visibility
//----------------------------------------------------
show_tf1 = show1 and f_inRange(ema1) and isNearest1
show_tf2 = show2 and f_inRange(ema2) and isNearest2
show_tf3 = show3 and f_inRange(ema3) and isNearest3
show_tf4 = show4 and f_inRange(ema4) and isNearest4
show_tf5 = show5 and f_inRange(ema5) and isNearest5
show_tf6 = show6 and f_inRange(ema6) and isNearest6

//----------------------------------------------------
// Colors
//----------------------------------------------------
c1 = color.new(color.blue,   0)
c2 = color.new(color.green,  0)
c3 = color.new(color.orange, 0)
c4 = color.new(color.purple, 0)
c5 = color.new(color.red,    0)
c6 = color.new(color.teal,   0)

//----------------------------------------------------
// Plots
//----------------------------------------------------
p1u = plot(show_tf1 ? up1 : na, "TF1 Upper", color=color.new(c1, 35), linewidth=1)
p1d = plot(show_tf1 ? dn1 : na, "TF1 Lower", color=color.new(c1, 35), linewidth=1)
p1m = plot(show_tf1 and showMidline ? ema1 : na, "TF1 EMA", color=f_colorLine(ema1), linewidth=2)
fill(p1u, p1d, color=color.new(c1, cloudTransp), title="TF1 Cloud")

p2u = plot(show_tf2 ? up2 : na, "TF2 Upper", color=color.new(c2, 35), linewidth=1)
p2d = plot(show_tf2 ? dn2 : na, "TF2 Lower", color=color.new(c2, 35), linewidth=1)
p2m = plot(show_tf2 and showMidline ? ema2 : na, "TF2 EMA", color=f_colorLine(ema2), linewidth=2)
fill(p2u, p2d, color=color.new(c2, cloudTransp), title="TF2 Cloud")

p3u = plot(show_tf3 ? up3 : na, "TF3 Upper", color=color.new(c3, 35), linewidth=1)
p3d = plot(show_tf3 ? dn3 : na, "TF3 Lower", color=color.new(c3, 35), linewidth=1)
p3m = plot(show_tf3 and showMidline ? ema3 : na, "TF3 EMA", color=f_colorLine(ema3), linewidth=2)
fill(p3u, p3d, color=color.new(c3, cloudTransp), title="TF3 Cloud")

p4u = plot(show_tf4 ? up4 : na, "TF4 Upper", color=color.new(c4, 35), linewidth=1)
p4d = plot(show_tf4 ? dn4 : na, "TF4 Lower", color=color.new(c4, 35), linewidth=1)
p4m = plot(show_tf4 and showMidline ? ema4 : na, "TF4 EMA", color=f_colorLine(ema4), linewidth=2)
fill(p4u, p4d, color=color.new(c4, cloudTransp), title="TF4 Cloud")

p5u = plot(show_tf5 ? up5 : na, "TF5 Upper", color=color.new(c5, 35), linewidth=1)
p5d = plot(show_tf5 ? dn5 : na, "TF5 Lower", color=color.new(c5, 35), linewidth=1)
p5m = plot(show_tf5 and showMidline ? ema5 : na, "TF5 EMA", color=f_colorLine(ema5), linewidth=2)
fill(p5u, p5d, color=color.new(c5, cloudTransp), title="TF5 Cloud")

p6u = plot(show_tf6 ? up6 : na, "TF6 Upper", color=color.new(c6, 35), linewidth=1)
p6d = plot(show_tf6 ? dn6 : na, "TF6 Lower", color=color.new(c6, 35), linewidth=1)
p6m = plot(show_tf6 and showMidline ? ema6 : na, "TF6 EMA", color=f_colorLine(ema6), linewidth=2)
fill(p6u, p6d, color=color.new(c6, cloudTransp), title="TF6 Cloud")

//----------------------------------------------------
// Labels on last bar only
//----------------------------------------------------
if barstate.islast and showLabels
    if show_tf1
        label.new(bar_index, ema1, "EMA 200 " + tf1, style=label.style_label_left, textcolor=color.white, color=color.new(c1, 65))
    if show_tf2
        label.new(bar_index, ema2, "EMA 200 " + tf2, style=label.style_label_left, textcolor=color.white, color=color.new(c2, 65))
    if show_tf3
        label.new(bar_index, ema3, "EMA 200 " + tf3, style=label.style_label_left, textcolor=color.white, color=color.new(c3, 65))
    if show_tf4
        label.new(bar_index, ema4, "EMA 200 " + tf4, style=label.style_label_left, textcolor=color.white, color=color.new(c4, 65))
    if show_tf5
        label.new(bar_index, ema5, "EMA 200 " + tf5, style=label.style_label_left, textcolor=color.white, color=color.new(c5, 65))
    if show_tf6
        label.new(bar_index, ema6, "EMA 200 " + tf6, style=label.style_label_left, textcolor=color.white, color=color.new(c6, 65))
````
