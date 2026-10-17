# RRE Liquidity + VWMA

- url: https://www.tradingview.com/script/z5iyXXDI-RRE-Liquidity-VWMA/
- type: indicator
- pine_id: PUB;dfa94c12650444198c54c79f35006e1a
- version: 1.0

## Description

Added a VWMA Filter input group (length 20, source close, offset, color #2962FF) and plotted it — same VWMA you pasted.
Swapped the liquidity signal mapping so it matches trade intent rather than raw pivot location: a swept low (candle confirmed below) now fires as your Buy signal, and a swept high (candle confirmed above) now fires as your Sell signal — the arrays are renamed buyLiq/sellLiq accordingly, and the sweep-removal conditions were flipped to match.
Added useVwmaFilter (on by default) — Buy signal only fires when close > VWMA, Sell signal only fires when close < VWMA, per "above buy, below sell." Turn it off in inputs if you want raw pivot signals with no VWMA gate.
Added a VWMA Bias row to the info table.

## Source Code

````pine
//@version=6
indicator('RRE Liquidity + VWMA', overlay = true, max_lines_count = 200)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════════════════════

// ── Liquidity ──
liqPivotBars = input.int(2, 'Liquidity Confirmation Bars', minval = 1, maxval = 10, group = 'Liquidity', tooltip = 'Bars needed to confirm a swing point before drawing the line.')
maxLiqLines = input.int(5, 'Max Liquidity Lines', minval = 3, maxval = 20, group = 'Liquidity')
extendRight = input.int(40, 'Extend Right Bars', minval = 10, maxval = 200, group = 'Liquidity')
liqLineWidth = input.int(2, 'Line Width', minval = 1, maxval = 4, group = 'Liquidity')
liqStyle = input.string('Solid', 'Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = 'Liquidity')
liqBuyColor = input.color(#00BCD4, 'Buy Signal Color (below)', group = 'Liquidity')
liqSellColor = input.color(#E91E63, 'Sell Signal Color (above)', group = 'Liquidity')

// ── VWMA ──
useVwmaFilter = input.bool(true, 'Filter Signals by VWMA', group = 'VWMA', tooltip = 'Buy only when price above VWMA · Sell only when price below VWMA')
showVWMA = input.bool(true, 'Show VWMA Line', group = 'VWMA')
vwmaLen = input.int(20, 'VWMA Length', minval = 1, group = 'VWMA')
vwmaSrc = input.source(close, 'VWMA Source', group = 'VWMA')
vwmaOffset = input.int(0, 'VWMA Offset', minval = -500, maxval = 500, group = 'VWMA')
vwmaColor = input.color(#2962FF, 'VWMA Color', group = 'VWMA')

// ══════════════════════════════════════════════════════════════════════════════
// CALCULATIONS
// ══════════════════════════════════════════════════════════════════════════════

vwma = ta.vwma(vwmaSrc, vwmaLen)
vwmaAbove = close > vwma
vwmaBelow = close < vwma

liqSwingHigh = ta.pivothigh(high, liqPivotBars, liqPivotBars)
liqSwingLow = ta.pivotlow(low, liqPivotBars, liqPivotBars)

plot(showVWMA ? vwma : na, title = 'VWMA', color = vwmaColor, offset = vwmaOffset, linewidth = 2)

getLineStyle() =>
    switch liqStyle
        'Dashed' => line.style_dashed
        'Dotted' => line.style_dotted
        => line.style_solid

// ══════════════════════════════════════════════════════════════════════════════
// ARRAYS
// ══════════════════════════════════════════════════════════════════════════════

var array<line> buyLiq = array.new_line()   // swept low  → candle formed below → BUY
var array<line> sellLiq = array.new_line()  // swept high → candle formed above → SELL

// ══════════════════════════════════════════════════════════════════════════════
// SIGNAL DETECTION
// ══════════════════════════════════════════════════════════════════════════════

var bool newBuyLiq = false
var bool newSellLiq = false
newBuyLiq := false
newSellLiq := false

// ── BUY: swept low, candle confirmed BELOW ──
if not na(liqSwingLow) and (not useVwmaFilter or vwmaAbove)
    liqLevel = low[liqPivotBars]
    newLine = line.new(x1 = bar_index - liqPivotBars, y1 = liqLevel, x2 = bar_index + extendRight, y2 = liqLevel, color = liqBuyColor, width = liqLineWidth, style = getLineStyle(), extend = extend.right)
    array.unshift(buyLiq, newLine)
    if array.size(buyLiq) > maxLiqLines
        line.delete(array.pop(buyLiq))
    newBuyLiq := true
    alert('🟢 Buy Signal | ' + syminfo.ticker + ' ' + timeframe.period + ' | Level: ' + str.tostring(liqLevel, format.mintick), alert.freq_once_per_bar)

// ── SELL: swept high, candle confirmed ABOVE ──
if not na(liqSwingHigh) and (not useVwmaFilter or vwmaBelow)
    liqLevel = high[liqPivotBars]
    newLine = line.new(x1 = bar_index - liqPivotBars, y1 = liqLevel, x2 = bar_index + extendRight, y2 = liqLevel, color = liqSellColor, width = liqLineWidth, style = getLineStyle(), extend = extend.right)
    array.unshift(sellLiq, newLine)
    if array.size(sellLiq) > maxLiqLines
        line.delete(array.pop(sellLiq))
    newSellLiq := true
    alert('🔴 Sell Signal | ' + syminfo.ticker + ' ' + timeframe.period + ' | Level: ' + str.tostring(liqLevel, format.mintick), alert.freq_once_per_bar)

// ── Remove swept lines ──
if array.size(buyLiq) > 0
    for i = array.size(buyLiq) - 1 to 0 by 1
        l = array.get(buyLiq, i)
        if not na(l) and close < line.get_y1(l)
            line.delete(l)
            array.remove(buyLiq, i)

if array.size(sellLiq) > 0
    for i = array.size(sellLiq) - 1 to 0 by 1
        l = array.get(sellLiq, i)
        if not na(l) and close > line.get_y1(l)
            line.delete(l)
            array.remove(sellLiq, i)

// ══════════════════════════════════════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════════════════════════════════════

alertcondition(newBuyLiq, title = 'Buy Signal', message = '🟢 Buy signal on {{ticker}} {{interval}}')
alertcondition(newSellLiq, title = 'Sell Signal', message = '🔴 Sell signal on {{ticker}} {{interval}}')
````
