# Relevant Swings ICT (Full Coverage)

- url: https://www.tradingview.com/script/YnC6RHPS-Relevant-Swings-ICT-Full-Coverage/
- type: indicator
- pine_id: PUB;bce8863883754f289b286262f051799f
- version: 1.0

## Description

It can Identify Relevant Swings, like swing high and low.

## Source Code

````pine
//@version=5
indicator("Relevant Swings ICT (Full Coverage)", overlay=true, max_lines_count=500)

// ===== INPUTS =====
pivotLen    = input.int(2, "Pivot Sensitivity", minval=1)
useCloseMit = input.bool(false, "Mitigation on Close")

// ===== PIVOTS (HIGH SENSITIVITY) =====
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

// ===== STORAGE =====
var float[] highs = array.new_float()
var float[] lows  = array.new_float()
var line[] highLines = array.new_line()
var line[] lowLines  = array.new_line()

var float prevHigh = na
var float prevLow  = na

// ===== CLASSIFICATION =====

// Higher High OR inducement high
isHigh = not na(ph)

// Lower Low OR inducement low
isLow  = not na(pl)

// ===== ADD ALL IMPORTANT SWINGS =====
if isHigh
    lnH = line.new(bar_index[pivotLen], ph, bar_index, ph, extend=extend.right, color=color.red)
    array.push(highs, ph)
    array.push(highLines, lnH)
    prevHigh := ph

if isLow
    lnL = line.new(bar_index[pivotLen], pl, bar_index, pl, extend=extend.right, color=color.green)
    array.push(lows, pl)
    array.push(lowLines, lnL)
    prevLow := pl

// ===== REMOVE MITIGATED HIGHS =====
int iHigh = array.size(highs) - 1
while iHigh >= 0
    levelH = array.get(highs, iHigh)
    lineH  = array.get(highLines, iHigh)

    condHigh = false
    if useCloseMit
        if close >= levelH
            condHigh := true
    else
        if high >= levelH
            condHigh := true

    if condHigh
        line.delete(lineH)
        array.remove(highs, iHigh)
        array.remove(highLines, iHigh)

    iHigh -= 1

// ===== REMOVE MITIGATED LOWS =====
int iLow = array.size(lows) - 1
while iLow >= 0
    levelL = array.get(lows, iLow)
    lineL  = array.get(lowLines, iLow)

    condLow = false
    if useCloseMit
        if close <= levelL
            condLow := true
    else
        if low <= levelL
            condLow := true

    if condLow
        line.delete(lineL)
        array.remove(lows, iLow)
        array.remove(lowLines, iLow)

    iLow -= 1
````
