# Nilesh MTF Liquidity Levels

- url: https://www.tradingview.com/script/Q0aAz6MA-Nilesh-MTF-Liquidity-Levels/
- type: indicator
- pine_id: PUB;6c206304b7b14d96a14a04492b3e7fb3
- version: 1.0

## Description

Overview
This indicator plots multi‑timeframe liquidity levels (highs and lows) on the chart and removes them once price sweeps the level. It is designed to help traders see where liquidity may be resting above or below current price.

How it works
The script tracks the previous candle’s high and low on several higher timeframes (15m, 30m, 1H, 4H, Daily) and draws horizontal lines from those levels into the future. When price makes a wick or close beyond a level (depending on the user setting), that level is considered swept and its line is removed from the chart.

Inputs & customization

Toggle each timeframe: Show 15m, 30m, 1H, 4H, Daily

Max levels per timeframe to control how many lines stay on the chart

Separate line width settings for each timeframe

Individual colors for each timeframe

Optional “Require close beyond level” to use candle close instead of wick for sweeps

Usage notes
These levels are not signals on their own. They are intended to be used together with your own price action, liquidity or S/R strategy. Always manage your risk and test on replay or demo before using in live trading.

## Source Code

````pine
//@version=5
indicator("Nilesh MTF Liquidity Levels", overlay=true, max_lines_count=500)

// ================= INPUTS =================

// Timeframe toggles
show15m = input.bool(true, "Show 15 Min")
show30m = input.bool(true, "Show 30 Min")
show1h  = input.bool(true, "Show 1 Hour")
show4h  = input.bool(true, "Show 4 Hour")
showD   = input.bool(true, "Show Daily")

// General settings
maxLevels = input.int(150, "Max levels per TF", minval=20, maxval=300)

// Individual line widths
width15m = input.int(1, "15m Line Width", minval=1, maxval=5)
width30m = input.int(1, "30m Line Width", minval=1, maxval=5)
width1h  = input.int(2, "1H Line Width", minval=1, maxval=5)
width4h  = input.int(2, "4H Line Width", minval=1, maxval=5)
widthD   = input.int(3, "Daily Line Width", minval=1, maxval=5)

// Colors
col15m = input.color(color.new(color.blue, 20), "15m Color")
col30m = input.color(color.new(color.green, 20), "30m Color")
col1h  = input.color(color.new(color.white, 0), "1H Color")
col4h  = input.color(color.new(color.orange, 0), "4H Color")
colD   = input.color(color.new(color.yellow, 0), "Daily Color")

// Sweep logic
useCloseSweep = input.bool(false, "Require close beyond level")

// ================= FUNCTIONS =================

f_swept_up(h, c, lvl) =>
    useCloseSweep ? c > lvl : h > lvl

f_swept_dn(l, c, lvl) =>
    useCloseSweep ? c < lvl : l < lvl

f_process(tf, show, col, lineWidth, linesH, lvlsH, liveH, linesL, lvlsL, liveL) =>
    tfHigh = request.security(syminfo.tickerid, tf, high)
    tfLow  = request.security(syminfo.tickerid, tf, low)
    tfTime = request.security(syminfo.tickerid, tf, time)

    newTF = ta.change(tfTime)

    if show and newTF and not na(tfHigh[1])
        // High
        lnH = line.new(
             tfTime[1], tfHigh[1],
             tfTime[1] + 1, tfHigh[1],
             xloc = xloc.bar_time,
             extend = extend.right,
             color = col,
             width = lineWidth)
        array.unshift(linesH, lnH)
        array.unshift(lvlsH, tfHigh[1])
        array.unshift(liveH, true)

        // Low
        lnL = line.new(
             tfTime[1], tfLow[1],
             tfTime[1] + 1, tfLow[1],
             xloc = xloc.bar_time,
             extend = extend.right,
             color = col,
             width = lineWidth)
        array.unshift(linesL, lnL)
        array.unshift(lvlsL, tfLow[1])
        array.unshift(liveL, true)

    // Limit size
    if array.size(linesH) > maxLevels
        line.delete(array.pop(linesH))
        array.pop(lvlsH)
        array.pop(liveH)

    if array.size(linesL) > maxLevels
        line.delete(array.pop(linesL))
        array.pop(lvlsL)
        array.pop(liveL)

    // Sweep check HIGH
    nH = array.size(linesH)
    if nH > 0
        for i = nH - 1 to 0
            if array.get(liveH, i)
                lvl = array.get(lvlsH, i)
                if f_swept_up(high, close, lvl)
                    line.delete(array.get(linesH, i))
                    array.set(liveH, i, false)

    // Sweep check LOW
    nL = array.size(linesL)
    if nL > 0
        for i = nL - 1 to 0
            if array.get(liveL, i)
                lvl = array.get(lvlsL, i)
                if f_swept_dn(low, close, lvl)
                    line.delete(array.get(linesL, i))
                    array.set(liveL, i, false)

// ================= STORAGE =================

// 15m
var line[]  h15   = array.new_line()
var float[] h15v  = array.new_float()
var bool[]  h15b  = array.new_bool()

var line[]  l15   = array.new_line()
var float[] l15v  = array.new_float()
var bool[]  l15b  = array.new_bool()

// 30m
var line[]  h30   = array.new_line()
var float[] h30v  = array.new_float()
var bool[]  h30b  = array.new_bool()

var line[]  l30   = array.new_line()
var float[] l30v  = array.new_float()
var bool[]  l30b  = array.new_bool()

// 1H
var line[]  h1    = array.new_line()
var float[] h1v   = array.new_float()
var bool[]  h1b   = array.new_bool()

var line[]  l1    = array.new_line()
var float[] l1v   = array.new_float()
var bool[]  l1b   = array.new_bool()

// 4H
var line[]  h4    = array.new_line()
var float[] h4v   = array.new_float()
var bool[]  h4b   = array.new_bool()

var line[]  l4    = array.new_line()
var float[] l4v   = array.new_float()
var bool[]  l4b   = array.new_bool()

// Daily
var line[]  hD    = array.new_line()
var float[] hDv   = array.new_float()
var bool[]  hDb   = array.new_bool()

var line[]  lD    = array.new_line()
var float[] lDv   = array.new_float()
var bool[]  lDb   = array.new_bool()

// ================= EXECUTION =================

f_process("15",  show15m, col15m, width15m, h15, h15v, h15b, l15, l15v, l15b)
f_process("30",  show30m, col30m, width30m, h30, h30v, h30b, l30, l30v, l30b)
f_process("60",  show1h,  col1h,  width1h,  h1,  h1v,  h1b,  l1,  l1v,  l1b)
f_process("240", show4h,  col4h,  width4h,  h4,  h4v,  h4b,  l4,  l4v,  l4b)
f_process("D",   showD,   colD,   widthD,   hD,  hDv,  hDb,  lD,  lDv,  lDb)
````
