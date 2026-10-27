# Volume Pro

- url: https://www.tradingview.com/script/gocpz0ag-Volume-Pro/
- type: indicator
- pine_id: PUB;798e7bdf110740969273caa9aa0b0148
- version: 2.0

## Description

This script is based on the original "MarketSmith Volumes" script from Fred6724

I modified a few things to tailor it to my needs.

Script uses the chart-timeframe.

choose volume moving average period
choose five volume thresholds (% above volume moving average) for colored dots to appear above the bars. You can set the %-thresholds and the color for each %-threshold. E.g. above 40% = yellow dot, above 100% = red dot etc.
(You can also choose to show the % figure above the avg volume instead of colored dots (the  percentage figures will appear in the chosen colors chosen for the thresholds))
Highest volume in 1 year shows "HY1" above bar.
Highest volume ever shows "HVE" above bar.
Highlight volume dry-up: Set volume % of MA volume to highlight bar: e.g. choose 30% and choose color, it will highlight the volume bars that are below or equal to 30% of the average volume in the chosen color.
Peak volume: choose peak length; e.g. peak length = 9 then it will show green/yellow arrows on the bar if the bar's volume is greater/lower than the previous 9 bars and the next 9 bars. The arrows will only start to show once the final bar is closed, e.g. Highest down volume with peak length 9 will only show if the 9th bar after the relevant bar has been closed. (If you don't need this feature you can comment it out in the script by putting // before the relevant lines at the bottom)

Option to add table with volume statistics:
avg volume: average volume (based on chosen avg length)
avg $ volume: average Dollar-volume (avg volume * (based on chosen avg length)
Up / Down volume ratio (based on chosen avg length)
Up / Down days counter, e.g. 33/17 (based on chosen avg length)
Vol shows volume of the last bar
Rel Vol: relative volume vs average volume, e.g. 49% means current bar's volume is 49% above MA volume; -39% would mean it's 39% below avg volume.

## Source Code

````pine
//Volume bars above MA (colored dots, or colored %-figures); highlight volume bars x% below MA; volumes below MA dark grey; volume peak lookback period;
//table: avg vol; avg $ vol, U/D vol, U/D days, vol, rel vol.
//@version=6
indicator("Volume Pro", format=format.volume, max_labels_count=500)

// Inputs
usePrevCloseColor = input.bool(false, "Color based on previous close")
txtColor = input.color(color.white, "Text Color")
maLength = input.int(50, "Volume MA Length")
colUp = input.color(color.rgb(63,223,23,23), "Up Volume Color")
colDn = input.color(color.rgb(219,24,24,15), "Down Volume Color")
maColor = input.color(color.white, "MA Color")
showPercent = input.bool(false, "Show percentage instead of dots")
showLabels = input.bool(true, "Show All Labels (Dots / % / HVE / HV1 / Peak)")

thr1 = input.float(30.0, "Volume above MA (%)", inline="t1")
dot1Color = input.color(color.rgb(15,250,238), "", inline="t1")
thr2 = input.float(40.0, "Volume above MA (%)", inline="t2")
dot2Color = input.color(color.rgb(255,235,29), "", inline="t2")
thr3 = input.float(100.0, "Volume above MA (%)", inline="t3")
dot3Color = input.color(color.rgb(60,255,0), "", inline="t3")
thr4 = input.float(200.0, "Volume above MA (%)", inline="t4")
dot4Color = input.color(color.rgb(255,0,0), "", inline="t4")
thr5 = input.float(300.0, "Volume above MA (%)", inline="t5")
dot5Color = input.color(color.rgb(255,0,221), "", inline="t5")

// Low-volume highlight inputs
enableLowVolHighlight = input.bool(false, "Highlight Low Volume Bars")
lowVolThreshold = input.float(25.0, "Volume % of MA Volume")
lowVolColor = input.color(color.orange, "Low Volume Highlight Color")
// NEW — Below-MA coloring
enableBelowMAColor = input.bool(false, "Color bars below MA (dark grey)")
belowMAColor = input.color(color.rgb(80,80,80), "Below MA Color")



// Table inputs
showTable = input.bool(true, "Show Table")
tableColor = input.color(color.rgb(59,60,66,100), "Table Color")
tableTextColor = input.color(color.white, "Info Color")

// Volume source
vol = volume

// MA
ma = ta.sma(vol, maLength)

// Low-volume highlight condition
isLowVol = vol <= ma * (lowVolThreshold / 100)
// NEW — Below-MA condition
isBelowMA = vol < ma

// Base bar color (normal behavior)
baseColor = usePrevCloseColor ? (close >= close[1] ? colUp : colDn) : (close > open ? colUp : colDn)

// Start from base color
barColor = baseColor

// Priority 2 → Below-MA grey (only if enabled)
if enableBelowMAColor and isBelowMA
    barColor := belowMAColor
    
// Priority 1 → Low-volume highlight (must override everything else)
if enableLowVolHighlight and isLowVol
    barColor := lowVolColor

plot(vol, "Volume", barColor, style=plot.style_columns, linewidth=3)
plot(ma, "MA", maColor)

// Highest Volume Ever
var float hve = na
hve := na(hve) ? vol : math.max(hve, vol)

// Highest Volume in 1 Year
oneYear = timeframe.isweekly ? 52 : timeframe.ismonthly ? 12 : 252
hv1 = ta.highest(vol, oneYear)

// HVE / HV1 Labels (Lane 3)
if showLabels
    if vol == hve
        label.new(bar_index, vol * 1.1, "HVE", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=txtColor, size=size.small)
    if vol == hv1 and vol < hve
        label.new(bar_index, vol * 1.1, "HV1", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=txtColor, size=size.small)

// Volume % above MA
volBuzz = (vol / ma-1) * 100.0
dotY = vol * 1.02

// Relative Volume (Rel Vol)
RelVol = (vol / ma) * 100.0
RelVolFormatted = str.tostring(math.round(RelVol)) + " %"

// Determine which threshold applies
color thrColor = na
float thrHit = na
if volBuzz >= thr5
    thrColor := dot5Color
    thrHit := thr5
else if volBuzz >= thr4
    thrColor := dot4Color
    thrHit := thr4
else if volBuzz >= thr3
    thrColor := dot3Color
    thrHit := thr3
else if volBuzz >= thr2
    thrColor := dot2Color
    thrHit := thr2
else if volBuzz >= thr1
    thrColor := dot1Color
    thrHit := thr1

// Threshold Dots / Percentages (Lane 2)
if showLabels and not na(thrHit)
    if showPercent
        label.new(bar_index, dotY, str.tostring(math.round(volBuzz)), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=thrColor, size=size.small)
    else
        label.new(bar_index, dotY, "●", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=thrColor, size=size.small)

// Up/Down Volume Ratio
upVol = close > close[1] ? vol : 0
dnVol = close < close[1] ? vol : 0
sumUp = math.sum(upVol, maLength)
sumDn = math.sum(dnVol, maLength)
upDnVolRatio = sumUp / sumDn

// Up/Down Day Count
upDayCount = math.sum(close > close[1] ? 1 : 0, maLength)
dnDayCount = math.sum(close < close[1] ? 1 : 0, maLength)

// Modern formatter (K / M / B)
f_fmt(v) =>
    float vFmt = v
    string u = ""
    if v >= 1e9
        vFmt := v / 1e9
        u := "B"
    else if v >= 1e6
        vFmt := v / 1e6
        u := "M"
    else if v >= 1e3
        vFmt := v / 1e3
        u := "K"
    str.tostring(vFmt, "0.##") + u

// Formatted values
volFormatted = f_fmt(vol)
avgVolFormatted = f_fmt(ma)
avgDol = close * ma
avgDolFormatted = f_fmt(avgDol)

// Table
var table t = table.new(position.top_right, 2, 6, bgcolor=tableColor)
if barstate.islast and showTable
    // Row 0 — Rel Vol
    table.cell(t, 0, 0, "Rel Vol", text_color=tableTextColor, text_size=size.small, text_halign=text.align_right)
    table.cell(t, 1, 0, RelVolFormatted, text_color=tableTextColor, text_size=size.small, text_halign=text.align_right)
    // Row 1 — Vol
    table.cell(t, 0, 1, "Vol", text_color=tableTextColor, text_size=size.small, text_halign=text.align_right)
    table.cell(t, 1, 1, volFormatted, text_color=tableTextColor, text_size=size.small, text_halign=text.align_right)
    // Row 2 — Avg Vol
    table.cell(t, 0, 2, "Avg Vol", text_color=tableTextColor, text_size=size.small, text_halign=text.align_right)
    table.cell(t, 1, 2, avgVolFormatted, text_color=tableTextColor, text_size=size.small, text_halign=text.align_right)
    // Row 3 — U/D Vol
    table.cell(t, 0, 3, "U/D Vol", text_color=tableTextColor, text_size=size.small, text_halign=text.align_right)
    table.cell(t, 1, 3, str.tostring(upDnVolRatio, "0.0"), text_color=tableTextColor, text_size=size.small, text_halign=text.align_right)
    // Row 4 — U/D Days
    table.cell(t, 0, 4, "U/D Days", text_color=tableTextColor, text_size=size.small, text_halign=text.align_right)
    table.cell(t, 1, 4, str.tostring(upDayCount) + " / " + str.tostring(dnDayCount), text_color=tableTextColor, text_size=size.small, text_halign=text.align_right)
    // Row 5 — Avg $ Vol
    table.cell(t, 0, 5, "Avg $ Vol", text_color=tableTextColor, text_size=size.small, text_halign=text.align_right)
    table.cell(t, 1, 5, avgDolFormatted, text_color=tableTextColor, text_size=size.small, text_halign=text.align_right)

// Peak Length logic (Lane 1)
peakLength = input.int(9, "Peak Length")
showPeakLength = input.bool(true, "Show Peak Length Labels")

peakVol = ta.pivothigh(vol, peakLength, peakLength)

if showLabels and showPeakLength and not na(peakVol)
    isBull = close[peakLength] > open[peakLength]
    string peakSymbol = isBull ? "▲" : "▼"
    color peakColor = isBull ? color.rgb(157, 255, 0) : color.rgb(255, 255, 255)
    label.new(
        bar_index - peakLength,
        vol[peakLength] * 0.9,
        peakSymbol,
        xloc = xloc.bar_index,
        yloc = yloc.price,
        style = label.style_none,
        textcolor = peakColor,
        size = size.small
    )
````
