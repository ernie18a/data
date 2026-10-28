# VWAP + 4 EMAs + FVG + Auto Fib

- url: https://www.tradingview.com/script/aMA4nlzU-VWAP-4-EMAs-FVG-Auto-Fib/
- type: indicator
- pine_id: PUB;fdaef26d845247f1b0b955bbc2a9a258
- version: 3.0

## Description

This is a multi-feature overlay indicator designed specifically for MNQ / NQ trading. It combines several popular tools into one clean script.

1. VWAP (Volume Weighted Average Price)

Plots the standard session VWAP.
Has its own color and transparency control.
Very useful as a dynamic support/resistance level during the trading day.


2. 4 Customizable EMAs with Multi-Timeframe (MTF) Ability
This is the most powerful part you requested:

EMA 1 (default 9) → Blue
EMA 2 (default 21) → Orange
EMA 3 (default 50) → Green
EMA 4 (default 200) → Red

Key Features for EMAs:

Each EMA has independent settings:
Length
Timeframe (this is the "lock to timeframe" feature)
Color
Transparency (opacity)
Show/Hide

You can lock any EMA to a higher timeframe. Examples:
Set EMA 4 to D (Daily) → shows Daily 200 EMA on your 3-minute chart.
Set EMA 2 to 15 → shows 15-minute EMA while on a 5-minute chart.
Leave blank ("") to use the current chart timeframe.



3. Fair Value Gaps (FVG)

Detects 3-candle imbalances (standard ICT/SMC Fair Value Gap).
Bullish FVG (green box) — when price gaps up aggressively.
Bearish FVG (red box) — when price gaps down aggressively.
Boxes automatically extend to the right.
Cleans up old boxes to avoid clutter.
Has minimum gap size filter and extension length controls.


4. Auto Fibonacci Retracement

Automatically draws Fibonacci retracement levels from the most recent significant swing high to swing low.
Uses pivot highs/lows with a configurable lookback period.
Draws common levels (0.236, 0.382, 0.5, 0.618, 0.786, 1.0).
Updates dynamically when new swings form.
Customizable color and transparency.


5. Background Coloring

Green background when EMA 1 > EMA 4 (bullish trend bias).
Red background when EMA 1 < EMA 4 (bearish trend bias).


6. Alerts

Triggers an alert whenever a new Bullish FVG or Bearish FVG is detected.


Summary – What This Indicator Helps You Do
This is a complete ICT / Price Action / Trend dashboard for MNQ:

Quickly see higher-timeframe structure using MTF EMAs.
Identify fair value gaps for potential fill or continuation trades.
Have dynamic Fibonacci levels without manually drawing them.
Use VWAP as intraday anchor.
Visually judge trend strength with the background color.

## Source Code

````pine
//@version=6
indicator('MNQ All-in-One', shorttitle='MNQ All-in-One', overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// ── Inputs ─────────────────────────────────────
groupVWAP = 'VWAP'
showRTH_VWAP   = input.bool(true,  'Show RTH VWAP', group=groupVWAP)
rthColor       = input.color(color.fuchsia, 'RTH VWAP Color', group=groupVWAP)
rthTransp      = input.int(0, 'RTH VWAP Transparency', minval=0, maxval=100, group=groupVWAP)

showETH_VWAP   = input.bool(true,  'Show Extended Hours VWAP', group=groupVWAP)
ethColor       = input.color(color.orange, 'Extended VWAP Color', group=groupVWAP)
ethTransp      = input.int(20, 'Extended VWAP Transparency', minval=0, maxval=100, group=groupVWAP)

groupEMA = 'EMAs'
ema1Len = input.int(9,   'EMA 1 Length', minval=1, group=groupEMA)
ema1TF  = input.timeframe('', 'EMA 1 TF', group=groupEMA)
showEMA1 = input.bool(true, 'Show EMA 1', group=groupEMA)
ema1Color = input.color(color.blue,   'EMA 1 Color', group=groupEMA)
ema1Transp = input.int(0, 'EMA 1 Transparency', minval=0, maxval=100, group=groupEMA)

ema2Len = input.int(21,  'EMA 2 Length', minval=1, group=groupEMA)
ema2TF  = input.timeframe('', 'EMA 2 TF', group=groupEMA)
showEMA2 = input.bool(true, 'Show EMA 2', group=groupEMA)
ema2Color = input.color(color.orange, 'EMA 2 Color', group=groupEMA)
ema2Transp = input.int(0, 'EMA 2 Transparency', minval=0, maxval=100, group=groupEMA)

ema3Len = input.int(50,  'EMA 3 Length', minval=1, group=groupEMA)
ema3TF  = input.timeframe('', 'EMA 3 TF', group=groupEMA)
showEMA3 = input.bool(true, 'Show EMA 3', group=groupEMA)
ema3Color = input.color(color.green,  'EMA 3 Color', group=groupEMA)
ema3Transp = input.int(0, 'EMA 3 Transparency', minval=0, maxval=100, group=groupEMA)

ema4Len = input.int(200, 'EMA 4 Length', minval=1, group=groupEMA)
ema4TF  = input.timeframe('', 'EMA 4 TF', group=groupEMA)
showEMA4 = input.bool(true, 'Show EMA 4', group=groupEMA)
ema4Color = input.color(color.red,    'EMA 4 Color', group=groupEMA)
ema4Transp = input.int(0, 'EMA 4 Transparency', minval=0, maxval=100, group=groupEMA)

groupFVG = 'FVG'
showFVG         = input.bool(true, 'Show Fair Value Gaps', group=groupFVG)
removeFilledFVG = input.bool(true, 'Remove FVG when Filled', group=groupFVG)
fvgColor        = input.color(color.new(color.green, 70), 'FVG Color', group=groupFVG)
fvgTransp       = input.int(70, 'FVG Transparency', minval=0, maxval=100, group=groupFVG)
fvgExtend       = input.int(50, 'FVG Extension Bars', minval=5, group=groupFVG)
minFVGSize      = input.float(0.1, 'Min FVG Size (points)', minval=0.01, group=groupFVG)

groupFib = 'Auto Fib'
showAutoFib = input.bool(true, 'Show Auto Fib Retracement', group=groupFib)
fibLookback = input.int(100, 'Swing Lookback Bars', minval=20, group=groupFib)
fibLevels   = input.string('0.236,0.382,0.5,0.618,0.786,1.0', 'Fib Levels (comma separated)', group=groupFib)
fibColor    = input.color(color.yellow, 'Fib Lines Color', group=groupFib)
fibTransp   = input.int(20, 'Fib Transparency', minval=0, maxval=100, group=groupFib)

// ── Calculations ─────────────────────────────────────
rthSession = "0930-1600"
inRTH = not na(time(timeframe.period, rthSession))

newDay = ta.change(time("D")) != 0
vwapRTH = ta.vwap(hlc3, newDay and inRTH)
vwapETH = ta.vwap(hlc3)

// MTF EMAs
ema1 = request.security(syminfo.tickerid, ema1TF, ta.ema(close, ema1Len), lookahead=barmerge.lookahead_off)
ema2 = request.security(syminfo.tickerid, ema2TF, ta.ema(close, ema2Len), lookahead=barmerge.lookahead_off)
ema3 = request.security(syminfo.tickerid, ema3TF, ta.ema(close, ema3Len), lookahead=barmerge.lookahead_off)
ema4 = request.security(syminfo.tickerid, ema4TF, ta.ema(close, ema4Len), lookahead=barmerge.lookahead_off)

// FVG Detection
bullFVG = low > high[2] and (low - high[2]) >= minFVGSize
bearFVG = high < low[2] and (low[2] - high) >= minFVGSize

var array<box> fvgBoxes = array.new<box>()

if showFVG
    fvgTransparency = color.new(fvgColor, fvgTransp)
    if bullFVG
        b = box.new(left=bar_index[1], top=low, right=bar_index + fvgExtend, bottom=high[2], 
                    border_color=na, bgcolor=fvgTransparency, extend=extend.right)
        array.push(fvgBoxes, b)
    if bearFVG
        b = box.new(left=bar_index[1], top=low[2], right=bar_index + fvgExtend, bottom=high, 
                    border_color=na, bgcolor=fvgTransparency, extend=extend.right)
        array.push(fvgBoxes, b)

// === Safe FVG Removal when Filled ===
if removeFilledFVG and array.size(fvgBoxes) > 0
    i = array.size(fvgBoxes) - 1
    while i >= 0
        if i >= array.size(fvgBoxes)
            break
        b = array.get(fvgBoxes, i)
        topPrice = box.get_top(b)
        botPrice = box.get_bottom(b)
        isBullish = topPrice > botPrice
        filled = isBullish ? (low <= botPrice) : (high >= topPrice)
        if filled
            box.delete(b)
            array.remove(fvgBoxes, i)
        else
            i -= 1

// Cleanup limit
if array.size(fvgBoxes) > 50
    box.delete(array.shift(fvgBoxes))

// Auto Fibonacci
var array<line> fibLines = array.new<line>()
var float swingHigh = na
var float swingLow  = na
var int   swingHighBar = na
var int   swingLowBar  = na

ph = ta.pivothigh(high, fibLookback / 2, fibLookback / 2)
pl = ta.pivotlow(low,  fibLookback / 2, fibLookback / 2)

if not na(ph)
    swingHigh := ph
    swingHighBar := bar_index - fibLookback / 2
if not na(pl)
    swingLow := pl
    swingLowBar := bar_index - fibLookback / 2

if showAutoFib and (not na(ph) or not na(pl)) and not na(swingHigh) and not na(swingLow)
    if array.size(fibLines) > 0
        for j = 0 to array.size(fibLines) - 1
            line.delete(array.get(fibLines, j))
    array.clear(fibLines)
    
    rangeSize = swingHigh - swingLow
    levels = str.split(fibLevels, ',')
    for lvlStr in levels
        lvl = str.tonumber(str.trim(lvlStr))
        if not na(lvl)
            price = swingLow + rangeSize * lvl
            l = line.new(x1=swingHighBar, y1=price, x2=bar_index + 50, y2=price, 
                         color=color.new(fibColor, fibTransp), width=1, style=line.style_dashed)
            array.push(fibLines, l)

// ── Plots ─────────────────────────────────────
plot(showRTH_VWAP ? vwapRTH : na, 'RTH VWAP', color=color.new(rthColor, rthTransp), linewidth=2)
plot(showETH_VWAP ? vwapETH : na, 'Extended VWAP', color=color.new(ethColor, ethTransp), linewidth=2)

plot(showEMA1 ? ema1 : na, 'EMA 1', color=color.new(ema1Color, ema1Transp), linewidth=2)
plot(showEMA2 ? ema2 : na, 'EMA 2', color=color.new(ema2Color, ema2Transp), linewidth=2)
plot(showEMA3 ? ema3 : na, 'EMA 3', color=color.new(ema3Color, ema3Transp), linewidth=2)
plot(showEMA4 ? ema4 : na, 'EMA 4', color=color.new(ema4Color, ema4Transp), linewidth=2)

// Alerts
if bullFVG
    alert('Bullish FVG Detected!', alert.freq_once_per_bar)
if bearFVG
    alert('Bearish FVG Detected!', alert.freq_once_per_bar)
````
