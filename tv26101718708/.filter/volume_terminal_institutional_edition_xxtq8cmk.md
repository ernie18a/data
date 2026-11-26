# Volume Terminal [Institutional Edition]

- url: https://www.tradingview.com/script/XxTq8cmk/
- type: indicator
- pine_id: PUB;f86c432a27694f96be4ec250a7317100
- version: 1.0

## Description

VOLUME TERMINAL PRO is a volume analysis tool designed to help users interpret participation, activity shifts, and relative market interest through a structured dashboard-style interface.

The script focuses on how trading volume changes over time and how unusual increases or decreases may provide additional context to price movement.

Rather than viewing raw volume bars alone, this tool organizes volume behavior into a cleaner workflow that may help users evaluate momentum participation, breakout interest, and quiet market phases.

It is intended for traders who use volume as part of their chart analysis and prefer a more efficient way to monitor market activity across multiple assets and timeframes.

The focus is clarity, structured observation, and practical volume-based chart workflow.

This tool may help users with:

Monitoring rising or falling participation levels
Identifying unusual volume spikes
Supporting breakout confirmation analysis
Detecting low-activity consolidation phases
Comparing current volume vs average activity
Organizing volume data in one interface

Suitable for:

Volume traders
Breakout traders
Swing traders
Intraday traders
Momentum traders
Users seeking cleaner dashboard tools

If structured market activity tools and dashboard-style analysis are part of your workflow, you may also find additional research tools available on this profile useful.

## Source Code

````pine
//@version=6
indicator("VOLUME TERMINAL PRO", shorttitle="VOL PRO", overlay=false, max_labels_count=500)

//=====================================================
// INPUTS
//=====================================================
group_core  = "Core Settings"
group_style = "Style"

volLen        = input.int(20, "Average Volume Length", minval=1, group=group_core)
strongRatio   = input.float(1.50, "Strong Volume Ratio", step=0.05, group=group_core)
extremeRatio  = input.float(2.50, "Extreme Volume Ratio", step=0.05, group=group_core)
showDashboard = input.bool(true, "Show Dashboard", group=group_style)
showLabels    = input.bool(true, "Show Spike Labels", group=group_style)

//=====================================================
// CUSTOM COLORS
//=====================================================
goldColor = color.rgb(255, 215, 0)

//=====================================================
// CORE CALCULATIONS
//=====================================================
avgVol   = ta.sma(volume, volLen)
volRatio = avgVol != 0 ? volume / avgVol : 1.0

isBull = close > open
isBear = close < open
isDoji = close == open

strongVol  = volRatio >= strongRatio
extremeVol = volRatio >= extremeRatio
lowVol     = volRatio < 0.80
spikeEvent = strongVol

//=====================================================
// BUY / SELL VOLUME ESTIMATION
//=====================================================
barRange = math.max(high - low, syminfo.mintick)
rawClosePos = (close - low) / barRange
closePos = math.max(0.0, math.min(1.0, rawClosePos))

buyVol   = volume * closePos
sellVol  = volume * (1.0 - closePos)
deltaVol = buyVol - sellVol

buyPressureScore  = volRatio * closePos * 100.0
sellPressureScore = volRatio * (1.0 - closePos) * 100.0

//=====================================================
// PRESSURE ENGINE
//=====================================================
string pressure = "NEUTRAL"

if buyPressureScore > sellPressureScore * 1.15 and strongVol
    pressure := "BUY PRESSURE"
else if sellPressureScore > buyPressureScore * 1.15 and strongVol
    pressure := "SELL PRESSURE"
else if buyPressureScore > sellPressureScore
    pressure := "LIGHT BUY"
else if sellPressureScore > buyPressureScore
    pressure := "LIGHT SELL"

//=====================================================
// STRENGTH ENGINE
//=====================================================
string strength = "WEAK"

if extremeVol
    strength := "EXTREME"
else if strongVol
    strength := "STRONG"
else if lowVol
    strength := "LOW"
else
    strength := "NORMAL"

//=====================================================
// TREND PARTICIPATION
//=====================================================
ema50 = ta.ema(close, 50)

string trendPart = "SIDEWAYS"

if close > ema50 and pressure == "BUY PRESSURE"
    trendPart := "BULL CONFIRMED"
else if close < ema50 and pressure == "SELL PRESSURE"
    trendPart := "BEAR CONFIRMED"
else if close > ema50
    trendPart := "UPTREND"
else if close < ema50
    trendPart := "DOWNTREND"

//=====================================================
// LAST SPIKE TRACKING
//=====================================================
lastSpikePrice  = ta.valuewhen(spikeEvent, close, 0)
lastSpikeHour   = ta.valuewhen(spikeEvent, hour(time), 0)
lastSpikeMinute = ta.valuewhen(spikeEvent, minute(time), 0)

f2(x) =>
    x < 10 ? "0" + str.tostring(x) : str.tostring(x)

lastSpikeTimeText = na(lastSpikeHour) or na(lastSpikeMinute) ? "N/A" : f2(lastSpikeHour) + ":" + f2(lastSpikeMinute)

//=====================================================
// COLORS
//=====================================================
barColor =
     extremeVol and pressure == "BUY PRESSURE" ? goldColor :
     extremeVol and pressure == "SELL PRESSURE" ? color.orange :
     strongVol and pressure == "BUY PRESSURE" ? color.lime :
     strongVol and pressure == "SELL PRESSURE" ? color.red :
     buyPressureScore > sellPressureScore ? color.new(color.green, 35) :
     sellPressureScore > buyPressureScore ? color.new(color.red, 35) :
     color.gray

pressureColor =
     str.contains(pressure, "BUY") ? color.lime :
     str.contains(pressure, "SELL") ? color.red :
     color.gray

strengthColor =
     strength == "EXTREME" ? goldColor :
     strength == "STRONG" ? color.lime :
     strength == "LOW" ? color.orange :
     color.silver

trendColor =
     str.contains(trendPart, "BULL") ? color.lime :
     str.contains(trendPart, "BEAR") ? color.red :
     trendPart == "UPTREND" ? color.green :
     trendPart == "DOWNTREND" ? color.orange :
     color.gray

deltaColor = deltaVol > 0 ? color.lime : deltaVol < 0 ? color.red : color.gray

//=====================================================
// PLOTS
//=====================================================
plot(volume, title="Volume", style=plot.style_columns, color=barColor, linewidth=2)
plot(avgVol, title="Average Volume", color=color.aqua, linewidth=2)

//=====================================================
// LABELS
//=====================================================
if showLabels and extremeVol
    label.new(
         bar_index,
         volume,
         pressure == "BUY PRESSURE" ? "BUY SPIKE" : pressure == "SELL PRESSURE" ? "SELL SPIKE" : "SPIKE",
         style=label.style_label_down,
         color=barColor,
         textcolor=color.black,
         size=size.small)

//=====================================================
// DASHBOARD
//=====================================================
var table dash = table.new(position.top_right, 2, 13, border_width=1)

bgHeader = color.black
bgCell   = color.new(color.black, 10)

if barstate.islast and showDashboard
    table.cell(dash, 0, 0, "VOLUME", bgcolor=bgHeader, text_color=color.white)
    table.cell(dash, 1, 0, "PRO", bgcolor=bgHeader, text_color=color.yellow)

    table.cell(dash, 0, 1, "Current Vol", bgcolor=bgCell, text_color=color.white)
    table.cell(dash, 1, 1, str.tostring(volume, format.volume), bgcolor=bgCell, text_color=color.white)

    table.cell(dash, 0, 2, "Avg Vol", bgcolor=bgCell, text_color=color.white)
    table.cell(dash, 1, 2, str.tostring(avgVol, format.volume), bgcolor=bgCell, text_color=color.aqua)

    table.cell(dash, 0, 3, "Vol Ratio", bgcolor=bgCell, text_color=color.white)
    table.cell(dash, 1, 3, str.tostring(volRatio, "#.##") + "x", bgcolor=bgCell, text_color=color.yellow)

    table.cell(dash, 0, 4, "Buy Vol", bgcolor=bgCell, text_color=color.white)
    table.cell(dash, 1, 4, str.tostring(buyVol, format.volume), bgcolor=bgCell, text_color=color.lime)

    table.cell(dash, 0, 5, "Sell Vol", bgcolor=bgCell, text_color=color.white)
    table.cell(dash, 1, 5, str.tostring(sellVol, format.volume), bgcolor=bgCell, text_color=color.red)

    table.cell(dash, 0, 6, "Delta", bgcolor=bgCell, text_color=color.white)
    table.cell(dash, 1, 6, str.tostring(deltaVol, format.volume), bgcolor=bgCell, text_color=deltaColor)

    table.cell(dash, 0, 7, "Pressure", bgcolor=bgCell, text_color=color.white)
    table.cell(dash, 1, 7, pressure, bgcolor=bgCell, text_color=pressureColor)

    table.cell(dash, 0, 8, "Strength", bgcolor=bgCell, text_color=color.white)
    table.cell(dash, 1, 8, strength, bgcolor=bgCell, text_color=strengthColor)

    table.cell(dash, 0, 9, "Trend", bgcolor=bgCell, text_color=color.white)
    table.cell(dash, 1, 9, trendPart, bgcolor=bgCell, text_color=trendColor)

    table.cell(dash, 0, 10, "Buy Score", bgcolor=bgCell, text_color=color.white)
    table.cell(dash, 1, 10, str.tostring(buyPressureScore, "#.##"), bgcolor=bgCell, text_color=color.lime)

    table.cell(dash, 0, 11, "Sell Score", bgcolor=bgCell, text_color=color.white)
    table.cell(dash, 1, 11, str.tostring(sellPressureScore, "#.##"), bgcolor=bgCell, text_color=color.red)

    table.cell(dash, 0, 12, "Last Spike", bgcolor=bgCell, text_color=color.white)
    table.cell(dash, 1, 12, na(lastSpikePrice) ? "N/A" : str.tostring(lastSpikePrice, format.mintick) + " @ " + lastSpikeTimeText, bgcolor=bgCell, text_color=goldColor)
````
