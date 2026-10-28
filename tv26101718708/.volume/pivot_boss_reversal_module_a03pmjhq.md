# Pivot Boss - Reversal Module

- url: https://www.tradingview.com/script/a03PmjHq-Pivot-Boss-Reversal-Module/
- type: indicator
- pine_id: PUB;d711f8fabcc243daa980558444481386
- version: 1.0

## Description

Reversal candlestick patterns + Relative volume + Volume spike

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © anandgmax

// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © anandgmax

//@version=6
indicator("Pivot Boss - Reversal Module", overlay=true, max_labels_count=500)

showLegend = input.bool(true, "Show Pattern Legend")

//=====================================================
// INPUTS
//=====================================================

wickMultiplier = input.float(2.5, "Wick Multiplier", step=0.1)
bodyPct = input.float(0.25, "Body Position %", step=0.01)
showLabels = input.bool(true, "Show Labels")
paintBars = input.bool(true, "Color Bars")

//=====================================================
// VOLUME SETTINGS
//=====================================================

showVolumePanel = input.bool(true, "Show Volume Dashboard")
useVolumeFilter = input.bool(false, "Filter Signals By RVOL")
rvolLength      = input.int(20, "RVOL Length", minval=5)
rvolThreshold   = input.float(1.5, "RVOL Threshold", step=0.1)
spikeMultiplier = input.float(1.5, "Volume Spike Multiplier", step=0.1)

//=====================================================
// LABEL COLORS
//=====================================================

// Bullish gradient
bullWickColor    = color.new(color.lime, 0)    // Bright Green
bullExtremeColor = color.new(color.green, 10)  // Medium Green
bullOutsideColor = color.new(color.green, 20)  // Darker Green
bullDojiColor    = color.new(color.green, 30)  // Light Green

// Bearish gradient
bearWickColor    = color.new(color.red, 0)     // Bright Red
bearExtremeColor = color.new(color.red, 10)    // Medium Red
bearOutsideColor = color.new(color.red, 20)    // Darker Red
bearDojiColor    = color.new(color.red, 30)    // Light Red

//=====================================================
// BASIC CANDLE DATA
//=====================================================

rng = high - low
body = math.abs(close - open)

upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

closeNearHigh = close >= low + rng * (1 - bodyPct)
closeNearLow  = close <= low + rng * bodyPct

//=====================================================
// WICK REVERSAL
//=====================================================

bullWickRev =
     lowerWick >= body * wickMultiplier and
     upperWick <= body and
     closeNearHigh

bearWickRev =
     upperWick >= body * wickMultiplier and
     lowerWick <= body and
     closeNearLow

//=====================================================
// EXTREME REVERSAL
//=====================================================

bullExtreme =
     low < low[1] and
     close > high[1]

bearExtreme =
     high > high[1] and
     close < low[1]

//=====================================================
// OUTSIDE REVERSAL
//=====================================================

outsideBar =
     high > high[1] and
     low < low[1]

bullOutside =
     outsideBar and
     close > open and
     close > (high + low) / 2

bearOutside =
     outsideBar and
     close < open and
     close < (high + low) / 2

//=====================================================
// DOJI REVERSAL
//=====================================================

doji =
     rng > 0 and
     body / rng <= 0.10

bullDoji =
     doji and
     close > close[1]

bearDoji =
     doji and
     close < close[1]

    //=====================================================
// VOLUME ANALYSIS
//=====================================================

avgVol = ta.sma(volume, rvolLength)
rvol = avgVol > 0 ? volume / avgVol : 0

highVolume = rvol >= rvolThreshold
volSpike = volume > avgVol * spikeMultiplier

//=====================================================
// SIGNAL STRENGTH
//=====================================================

signalPresent =
     bullWickRev or bearWickRev or
     bullExtreme or bearExtreme or
     bullOutside or bearOutside or
     bullDoji or bearDoji

strength =
     (signalPresent ? 1 : 0) +
     (highVolume ? 1 : 0) +
     (volSpike ? 1 : 0)

string stars = ""

if strength == 3
    stars := "★★★"
else if strength == 2
    stars := "★★☆"
else if strength == 1
    stars := "★☆☆"
//=====================================================
// LABELS
//=====================================================

if showLabels

    if bullWickRev
        label.new(
             bar_index,
             low,
             "BWR " + stars,
             style=label.style_label_up,
             color=bullWickColor,
             textcolor=color.white,
             tooltip="Bullish Wick Reversal")

    if bearWickRev
        label.new(
             bar_index,
             high,
             "SWR " + stars,
             style=label.style_label_down,
             color=bearWickColor,
             textcolor=color.white,
             tooltip="Bearish Wick Reversal")

    if bullExtreme
        label.new(
             bar_index,
             low,
             "BER " + stars,
             style=label.style_label_up,
             color=bullExtremeColor,
             textcolor=color.white,
             tooltip="Bullish Extreme Reversal")

    if bearExtreme
        label.new(
             bar_index,
             high,
             "SER" + stars,
             style=label.style_label_down,
             color=bearExtremeColor,
             textcolor=color.white,
             tooltip="Bearish Extreme Reversal")

    if bullOutside
        label.new(
             bar_index,
             low,
             "BOR"+ stars,
             style=label.style_label_up,
             color=bullOutsideColor,
             textcolor=color.white,
             tooltip="Bullish Outside Reversal")

    if bearOutside
        label.new(
             bar_index,
             high,
             "SOR"+ stars,
             style=label.style_label_down,
             color=bearOutsideColor,
             textcolor=color.white,
             tooltip="Bearish Outside Reversal")

    if bullDoji
        label.new(
             bar_index,
             low,
             "BDR"+ stars,
             style=label.style_label_up,
             color=bullDojiColor,
             textcolor=color.white,
             tooltip="Bullish Doji Reversal")

    if bearDoji
        label.new(
             bar_index,
             high,
             "SDR"+ stars,
             style=label.style_label_down,
             color=bearDojiColor,
             textcolor=color.white,
             tooltip="Bearish Doji Reversal")

//=====================================================
// BAR COLORING
//=====================================================

barcolor(
     paintBars ?
     bullWickRev ? bullWickColor :
     bearWickRev ? bearWickColor :
     bullExtreme ? bullExtremeColor :
     bearExtreme ? bearExtremeColor :
     bullOutside ? bullOutsideColor :
     bearOutside ? bearOutsideColor :
     bullDoji ? bullDojiColor :
     bearDoji ? bearDojiColor :
     na
     : na)
     
//=====================================================
// ALERTS
//=====================================================

alertcondition(bullWickRev, "Bullish Wick Reversal", "BWR detected")
alertcondition(bearWickRev, "Bearish Wick Reversal", "SWR detected")

alertcondition(bullExtreme, "Bullish Extreme Reversal", "BER detected")
alertcondition(bearExtreme, "Bearish Extreme Reversal", "SER detected")

alertcondition(bullOutside, "Bullish Outside Reversal", "BOR detected")
alertcondition(bearOutside, "Bearish Outside Reversal", "SOR detected")

alertcondition(bullDoji, "Bullish Doji Reversal", "BDR detected")
alertcondition(bearDoji, "Bearish Doji Reversal", "SDR detected")

//=====================================================
// LEGEND TABLE
//=====================================================

var table legend = table.new(position.top_right, 2, 9, border_width=1)

if barstate.isfirst
    table.cell(legend, 0, 0, "Label")
    table.cell(legend, 1, 0, "Meaning")

if showLegend
    table.cell(legend, 0, 1, "BWR")
    table.cell(legend, 1, 1, "Bullish Wick Reversal")

    table.cell(legend, 0, 2, "SWR")
    table.cell(legend, 1, 2, "Bearish Wick Reversal")

    table.cell(legend, 0, 3, "BER")
    table.cell(legend, 1, 3, "Bullish Extreme Reversal")

    table.cell(legend, 0, 4, "SER")
    table.cell(legend, 1, 4, "Bearish Extreme Reversal")

    table.cell(legend, 0, 5, "BOR")
    table.cell(legend, 1, 5, "Bullish Outside Reversal")

    table.cell(legend, 0, 6, "SOR")
    table.cell(legend, 1, 6, "Bearish Outside Reversal")

    table.cell(legend, 0, 7, "BDR")
    table.cell(legend, 1, 7, "Bullish Doji Reversal")

    table.cell(legend, 0, 8, "SDR")
    table.cell(legend, 1, 8, "Bearish Doji Reversal")

else
    for row = 0 to 8
        table.cell(legend, 0, row, "")
        table.cell(legend, 1, row, "")

    //=====================================================
// VOLUME DASHBOARD
//=====================================================

var table volTable = table.new(position.bottom_right, 2, 5, border_width=1)

if showVolumePanel
    table.cell(volTable, 0, 0, "Metric")
    table.cell(volTable, 1, 0, "Value")

    table.cell(volTable, 0, 1, "RVOL")
    table.cell(volTable, 1, 1, str.tostring(rvol, "#.##"))

    table.cell(volTable, 0, 2, "Volume")
    table.cell(volTable, 1, 2, highVolume ? "HIGH" : "NORMAL")

    table.cell(volTable, 0, 3, "Spike")
    table.cell(volTable, 1, 3, volSpike ? "YES" : "NO")

    table.cell(volTable, 0, 4, "Strength")
    table.cell(volTable, 1, 4, stars)
else
    table.clear(volTable, 0, 0, 1, 4)
````
