# MGC SMA Gravity + Extreme Stretch + Joe Dirt Scanner

- url: https://www.tradingview.com/script/xw3r1RJ1-MGC-SMA-Gravity-Extreme-Stretch-Joe-Dirt-Scanner/
- type: indicator
- pine_id: PUB;72e7eaa6e19f420dba155e973f842704
- version: 1.0

## Description

MGC SMA Gravity + Extreme Stretch + Joe Dirt Scanner is a multi-timeframe moving average confluence tool built to help traders identify support/resistance clusters, mean reversion extremes, and “gravity zones” where price often reacts.

This indicator plots a layered SMA ladder using:

5-minute 20 SMA and 100 SMA
15-minute 20 SMA and 100 SMA
1-hour 20 SMA and 100 SMA
4-hour 20 SMA
Core Features

SMA Gravity Cluster Heat Map
Detects when multiple SMAs compress within a user-defined tick distance, creating a potential “gravity zone” where price may be drawn, stall, bounce, or reverse.

Dynamic heat map shows cluster strength
Color-coded confluence zones:
Yellow = 3 SMA cluster
Orange = 4 SMA cluster
Red = 5 SMA cluster
Purple = 6+ SMA cluster

A dashed “magnet line” marks the center of the cluster as a potential mean reversion target.

Multi-Timeframe SMA Ladder
Projects higher-timeframe SMA levels directly onto the active chart using horizontal rays and labels, creating a visual map of stacked support and resistance.

Extreme Stretch Scanner (Mean Reversion Signals)
Measures price distance from the average of all tracked SMAs.
When price extends beyond a user-defined threshold:

OB = Extreme Overbought condition
OS = Extreme Oversold condition

Designed to help identify exhaustion moves where price may revert back toward the SMA mean.

Customizable Inputs

Cluster distance in ticks
Minimum SMA spacing filter
Extreme stretch threshold
Heat map on/off
Heat map legend on/off

Alerts Included

Extreme Overbought alert
Extreme Oversold alert
Intended Use

This tool is designed for:

Mean reversion traders
Futures traders (especially MGC/GC)
Confluence-based support/resistance analysis
Identifying “stretched” conditions away from equilibrium
Spotting areas where multiple moving averages act as a price magnet

This is not a standalone buy/sell system, but a decision-support tool meant to improve context, location awareness, and timing around SMA structure.

## Source Code

````pine
 //@version=6
indicator("MGC SMA Gravity + Extreme Stretch + Joe Dirt Scanner", overlay=true, max_labels_count=100)

// =============================================
// === SMA GRAVITY + EXTREME STRETCH SECTION ===
// =============================================

// SETTINGS
fast = 20
slow = 100

clusterTicks = input.int(15, "Cluster Distance (Ticks)", group="SMA Gravity")
minSmaDistanceTicks = input.int(8, "Min Distance Between 20/100 For Bounce", group="SMA Gravity")
extremeStretchTicks = input.int(50, "Extreme Stretch from SMA Mean (Ticks)", group="SMA Gravity")

showHeatMap = input.bool(true, "Show SMA Heat Map", group="SMA Gravity")
showHeatLegend = input.bool(true, "Show Heat Map Legend", group="SMA Gravity")

tickSize = syminfo.mintick
clusterDistance = clusterTicks * tickSize
minSmaDistance = minSmaDistanceTicks * tickSize
extremeDistance = extremeStretchTicks * tickSize

// COLORS
c20 = color.white
c100_5 = color.orange
c100_15 = color.blue
c100_1h = color.purple
lblbg = color.new(color.black,90)

// =======================
// SMA CALCULATIONS
// =======================

sma20_5 = ta.sma(close, fast)
sma100_5 = ta.sma(close, slow)

sma20_15 = request.security(syminfo.tickerid, "15", ta.sma(close, fast))
sma100_15 = request.security(syminfo.tickerid, "15", ta.sma(close, slow))

sma20_1h = request.security(syminfo.tickerid, "60", ta.sma(close, fast))
sma100_1h = request.security(syminfo.tickerid, "60", ta.sma(close, slow))

sma20_4h = request.security(syminfo.tickerid, "240", ta.sma(close, fast))

// =======================
// LADDER RAYS
// =======================

var line l5_20 = line.new(na,na,na,na,extend=extend.right,color=c20,width=1)
var line l5_100 = line.new(na,na,na,na,extend=extend.right,color=c100_5,width=1)

var line l15_20 = line.new(na,na,na,na,extend=extend.right,color=c20,width=2)
var line l15_100 = line.new(na,na,na,na,extend=extend.right,color=c100_15,width=2)

var line l1h_20 = line.new(na,na,na,na,extend=extend.right,color=c20,width=3)
var line l1h_100 = line.new(na,na,na,na,extend=extend.right,color=c100_1h,width=3)

var line l4h_20 = line.new(na,na,na,na,extend=extend.right,color=c20,width=4)

// UPDATE RAYS

line.set_xy1(l5_20, bar_index-2, sma20_5)
line.set_xy2(l5_20, bar_index, sma20_5)

line.set_xy1(l5_100, bar_index-2, sma100_5)
line.set_xy2(l5_100, bar_index, sma100_5)

line.set_xy1(l15_20, bar_index-2, sma20_15)
line.set_xy2(l15_20, bar_index, sma20_15)

line.set_xy1(l15_100, bar_index-2, sma100_15)
line.set_xy2(l15_100, bar_index, sma100_15)

line.set_xy1(l1h_20, bar_index-2, sma20_1h)
line.set_xy2(l1h_20, bar_index, sma20_1h)

line.set_xy1(l1h_100, bar_index-2, sma100_1h)
line.set_xy2(l1h_100, bar_index, sma100_1h)

line.set_xy1(l4h_20, bar_index-2, sma20_4h)
line.set_xy2(l4h_20, bar_index, sma20_4h)

// =======================
// LABELS
// =======================

var label lb5_20 = label.new(na,na,"5m 20",style=label.style_label_right,color=lblbg,textcolor=c20)
var label lb5_100 = label.new(na,na,"5m 100",style=label.style_label_right,color=lblbg,textcolor=c100_5)

var label lb15_20 = label.new(na,na,"15m 20",style=label.style_label_right,color=lblbg,textcolor=c20)
var label lb15_100 = label.new(na,na,"15m 100",style=label.style_label_right,color=lblbg,textcolor=c100_15)

var label lb1h_20 = label.new(na,na,"1h 20",style=label.style_label_right,color=lblbg,textcolor=c20)
var label lb1h_100 = label.new(na,na,"1h 100",style=label.style_label_right,color=lblbg,textcolor=c100_1h)

var label lb4h_20 = label.new(na,na,"4h 20",style=label.style_label_right,color=lblbg,textcolor=c20)

label.set_xy(lb5_20, bar_index, sma20_5)
label.set_xy(lb5_100, bar_index, sma100_5)

label.set_xy(lb15_20, bar_index, sma20_15)
label.set_xy(lb15_100, bar_index, sma100_15)

label.set_xy(lb1h_20, bar_index, sma20_1h)
label.set_xy(lb1h_100, bar_index, sma100_1h)

label.set_xy(lb4h_20, bar_index, sma20_4h)

// =======================
// GRAVITY CLUSTER
// =======================

s = array.from(
sma20_5,
sma100_5,
sma20_15,
sma100_15,
sma20_1h,
sma100_1h,
sma20_4h)

sma_mean = array.sum(s) / array.size(s)

float clusterTop = na
float clusterBot = na
clusterCount = 0

for i = 0 to 5
    for j = i + 1 to 6
        a = array.get(s,i)
        b = array.get(s,j)

        if math.abs(a-b) <= clusterDistance
            clusterTop := na(clusterTop) ? math.max(a,b) : math.max(clusterTop, math.max(a,b))
            clusterBot := na(clusterBot) ? math.min(a,b) : math.min(clusterBot, math.min(a,b))
            clusterCount += 1

var box clusterBox = box.new(na,na,na,na,border_color=color.yellow,bgcolor=color.new(color.yellow,85))
var line magnetLine = line.new(na,na,na,na,color=color.yellow,width=2,style=line.style_dashed)

// HEAT MAP CLUSTER

if clusterCount >= 3 and showHeatMap
    box.set_top(clusterBox, clusterTop)
    box.set_bottom(clusterBox, clusterBot)
    box.set_left(clusterBox, bar_index-5)
    box.set_right(clusterBox, bar_index+60)

    magnet = (clusterTop + clusterBot) / 2

    line.set_xy1(magnetLine, bar_index-1, magnet)
    line.set_xy2(magnetLine, bar_index+60, magnet)

    heatColor =
         clusterCount >= 6 ? color.new(color.purple,80) :
         clusterCount == 5 ? color.new(color.red,80) :
         clusterCount == 4 ? color.new(color.orange,80) :
         color.new(color.yellow,85)

    box.set_bgcolor(clusterBox, heatColor)

else
    box.set_top(clusterBox, na)
    line.set_xy1(magnetLine, na, na)

// =======================
// HEAT MAP LEGEND
// =======================

if showHeatLegend
    var table legend = table.new(position.bottom_right, 2, 5)

    if barstate.islast
        table.cell(legend,0,0,"Cluster Strength",text_color=color.white,bgcolor=color.black)
        table.cell(legend,1,0,"")

        table.cell(legend,0,1,"3 SMA",text_color=color.white)
        table.cell(legend,1,1,"",bgcolor=color.new(color.yellow,85))

        table.cell(legend,0,2,"4 SMA",text_color=color.white)
        table.cell(legend,1,2,"",bgcolor=color.new(color.orange,80))

        table.cell(legend,0,3,"5 SMA",text_color=color.white)
        table.cell(legend,1,3,"",bgcolor=color.new(color.red,80))

        table.cell(legend,0,4,"6+ SMA",text_color=color.white)
        table.cell(legend,1,4,"",bgcolor=color.new(color.purple,80))

// =======================
// EXTREME STRETCH
// =======================

isOverbought = close > sma_mean + extremeDistance
isOversold = close < sma_mean - extremeDistance

var bool prevOverbought = false
var bool prevOversold = false

enterOverbought = isOverbought and not prevOverbought
enterOversold = isOversold and not prevOversold

prevOverbought := isOverbought
prevOversold := isOversold

plotshape(enterOverbought, location=location.abovebar, style=shape.labeldown, color=color.red, text="OB", size=size.large)
plotshape(enterOversold, location=location.belowbar, style=shape.labelup, color=color.green, text="OS", size=size.large)

// ALERTS

alertcondition(enterOverbought, "Extreme Overbought", "Price extremely above SMA mean")
alertcondition(enterOversold, "Extreme Oversold", "Price extremely below SMA mean")
````
