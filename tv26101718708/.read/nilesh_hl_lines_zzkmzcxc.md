# Nilesh HL Lines

- url: https://www.tradingview.com/script/zZKMZCxc-Nilesh-HL-Lines/
- type: indicator
- pine_id: PUB;c98c880cea454f20b979e3ddf90cab00
- version: 1.0

## Description

Nilesh HL Lines is a liquidity-based indicator that plots previous hourly and daily highs and lows as extended horizontal levels. These levels represent potential liquidity zones where price may react.

The script automatically tracks and removes levels once they are swept, helping traders focus only on active liquidity.

Key features:

Tracks hourly and daily high/low levels
Automatic removal after liquidity sweep
Custom color and opacity settings
Adjustable lookback for hours and days
Optional close confirmation for sweeps
Lightweight and optimized for lower timeframes

This tool is ideal for traders using liquidity concepts, price action, or ICT-style analysis to identify stop hunts and reaction points.

## Source Code

````pine
//@version=5
indicator("Nilesh HL Lines", overlay=true, max_lines_count=500, max_labels_count=10)

// ================= INPUTS =================

// Hourly settings
maxHours      = input.int(200, "Max hours to track", minval=10, maxval=400)
hourColor     = input.color(color.white, "Hourly Line Color")
hourOpacity   = input.int(0, "Hourly Line Opacity (0-100)", minval=0, maxval=100)

// Daily settings
showDaily     = input.bool(true, "Show Daily High/Low")
maxDays       = input.int(20, "Max days to track", minval=1, maxval=50)
dailyColor    = input.color(color.yellow, "Daily Line Color")
dailyOpacity  = input.int(0, "Daily Line Opacity (0-100)", minval=0, maxval=100)

// Sweep logic
useCloseSweep = input.bool(false, "Require close beyond level for sweep")
equalCounts   = input.bool(false, "Treat equal high/low as sweep")

// ================= HOURLY DATA =================

tfH = "60"
h1High = request.security(syminfo.tickerid, tfH, high)
h1Low  = request.security(syminfo.tickerid, tfH, low)
h1Time = request.security(syminfo.tickerid, tfH, time)
newHour = ta.change(h1Time)

// ================= DAILY DATA =================

tfD = "D"
dHigh = request.security(syminfo.tickerid, tfD, high)
dLow  = request.security(syminfo.tickerid, tfD, low)
dTime = request.security(syminfo.tickerid, tfD, time)
newDay = ta.change(dTime)

// ================= STORAGE =================

// Hourly
var line[] hiLines = array.new_line()
var float[] hiLvls = array.new_float()
var bool[] hiLive  = array.new_bool()

var line[] loLines = array.new_line()
var float[] loLvls = array.new_float()
var bool[] loLive  = array.new_bool()

// Daily
var line[] dhiLines = array.new_line()
var float[] dhiLvls = array.new_float()
var bool[] dhiLive  = array.new_bool()

var line[] dloLines = array.new_line()
var float[] dloLvls = array.new_float()
var bool[] dloLive  = array.new_bool()

// ================= FUNCTIONS =================

// Add line
f_addLine(_lvl, _isHigh, _t, _isDaily) =>
    t1 = _t
    t2 = _t + 1

    col = _isDaily ? color.new(dailyColor, dailyOpacity) : color.new(hourColor, hourOpacity)

    ln = line.new(t1, _lvl, t2, _lvl, xloc=xloc.bar_time, extend=extend.right, color=col, width=1)

    if not _isDaily
        if _isHigh
            array.unshift(hiLines, ln)
            array.unshift(hiLvls, _lvl)
            array.unshift(hiLive, true)
            if array.size(hiLines) > maxHours
                line.delete(array.pop(hiLines))
                array.pop(hiLvls)
                array.pop(hiLive)
        else
            array.unshift(loLines, ln)
            array.unshift(loLvls, _lvl)
            array.unshift(loLive, true)
            if array.size(loLines) > maxHours
                line.delete(array.pop(loLines))
                array.pop(loLvls)
                array.pop(loLive)
    else
        if _isHigh
            array.unshift(dhiLines, ln)
            array.unshift(dhiLvls, _lvl)
            array.unshift(dhiLive, true)
            if array.size(dhiLines) > maxDays
                line.delete(array.pop(dhiLines))
                array.pop(dhiLvls)
                array.pop(dhiLive)
        else
            array.unshift(dloLines, ln)
            array.unshift(dloLvls, _lvl)
            array.unshift(dloLive, true)
            if array.size(dloLines) > maxDays
                line.delete(array.pop(dloLines))
                array.pop(dloLvls)
                array.pop(dloLive)

// Sweep logic
f_swept_up(h, c, lvl) =>
    eq = equalCounts ? h >= lvl : h > lvl
    useCloseSweep ? (equalCounts ? c >= lvl : c > lvl) : eq

f_swept_dn(l, c, lvl) =>
    eq = equalCounts ? l <= lvl : l < lvl
    useCloseSweep ? (equalCounts ? c <= lvl : c < lvl) : eq

// ================= CREATE LINES =================

// Hourly
if newHour and not na(h1High[1])
    f_addLine(h1High[1], true,  h1Time[1], false)
    f_addLine(h1Low[1],  false, h1Time[1], false)

// Daily
if showDaily and newDay and not na(dHigh[1])
    f_addLine(dHigh[1], true,  dTime[1], true)
    f_addLine(dLow[1],  false, dTime[1], true)

// ================= SWEEP CHECK =================

// Hourly High
hiN = array.size(hiLines)
if hiN > 0
    for i = hiN - 1 to 0
        if array.get(hiLive, i)
            lvl = array.get(hiLvls, i)
            if f_swept_up(high, close, lvl)
                line.delete(array.get(hiLines, i))
                array.set(hiLive, i, false)

// Hourly Low
loN = array.size(loLines)
if loN > 0
    for i = loN - 1 to 0
        if array.get(loLive, i)
            lvl = array.get(loLvls, i)
            if f_swept_dn(low, close, lvl)
                line.delete(array.get(loLines, i))
                array.set(loLive, i, false)

// Daily High
dhiN = array.size(dhiLines)
if dhiN > 0
    for i = dhiN - 1 to 0
        if array.get(dhiLive, i)
            lvl = array.get(dhiLvls, i)
            if f_swept_up(high, close, lvl)
                line.delete(array.get(dhiLines, i))
                array.set(dhiLive, i, false)

// Daily Low
dloN = array.size(dloLines)
if dloN > 0
    for i = dloN - 1 to 0
        if array.get(dloLive, i)
            lvl = array.get(dloLvls, i)
            if f_swept_dn(low, close, lvl)
                line.delete(array.get(dloLines, i))
                array.set(dloLive, i, false)
````
