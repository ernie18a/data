# s77-gold

- url: https://www.tradingview.com/script/yc3bSGnN-s77-gold/
- type: indicator
- pine_id: PUB;06a0662b170442bc9805615a4b0aba06
- version: 1.0

## Description

Gold Scalping indicator designed for the 5-minute timeframe.

Features:
- Buy and Sell signals
- Trend detection
- Dynamic Trend Lines
- Order Block detection
- Stop Loss
- Take Profit 1
- Take Profit 2
- Automatic chart updates

Recommended for XAUUSD 5M.

## Source Code

````pine
//@version=6
indicator('Ismail Gold Scalp Pro 5M', overlay = true, max_boxes_count = 20, max_labels_count = 50, max_lines_count = 50)

// Settings
ema200 = ta.ema(close, 200)
atr = ta.atr(14)
pivotLen = input.int(5, 'Trend Pivot Length')

plot(ema200, 'EMA 200', color = color.orange, linewidth = 2)

// Trend Filter
bullTrend = close > ema200
bearTrend = close < ema200

// BOS
bosHigh = ta.crossover(close, ta.highest(high, 10)[1])
bosLow = ta.crossunder(close, ta.lowest(low, 10)[1])

// Order Block
bullOB = close[1] < open[1] and bosHigh
bearOB = close[1] > open[1] and bosLow

buySignal = bullTrend and bullOB
sellSignal = bearTrend and bearOB

// Delete old signal tools
var label signalLabel = na
var box obBox = na
var line entryLine = na
var line slLine = na
var line tp1Line = na
var line tp2Line = na

deleteOld() =>
    if not na(signalLabel)
        label.delete(signalLabel)
    if not na(obBox)
        box.delete(obBox)
    if not na(entryLine)
        line.delete(entryLine)
    if not na(slLine)
        line.delete(slLine)
    if not na(tp1Line)
        line.delete(tp1Line)
    if not na(tp2Line)
        line.delete(tp2Line)

// BUY
if buySignal
    deleteOld()

    entry = close
    sl = low[1] - atr * 0.3
    risk = entry - sl
    tp1 = entry + risk * 2
    tp2 = entry + risk * 4

    obBox := box.new(bar_index - 1, high[1], bar_index + 20, low[1], bgcolor = color.new(color.green, 85), border_color = color.green)

    entryLine := line.new(bar_index, entry, bar_index + 20, entry, color = color.blue, width = 2)
    slLine := line.new(bar_index, sl, bar_index + 20, sl, color = color.red, width = 2)
    tp1Line := line.new(bar_index, tp1, bar_index + 20, tp1, color = color.green, width = 2)
    tp2Line := line.new(bar_index, tp2, bar_index + 20, tp2, color = color.green, width = 2)

    signalLabel := label.new(bar_index, low, 'BUY\nEntry: ' + str.tostring(entry) + '\nSL: ' + str.tostring(sl) + '\nTP1: ' + str.tostring(tp1) + '\nTP2: ' + str.tostring(tp2), style = label.style_label_up, color = color.green, textcolor = color.white)
    signalLabel

// SELL
if sellSignal
    deleteOld()

    entry = close
    sl = high[1] + atr * 0.3
    risk = sl - entry
    tp1 = entry - risk * 2
    tp2 = entry - risk * 4

    obBox := box.new(bar_index - 1, high[1], bar_index + 20, low[1], bgcolor = color.new(color.red, 85), border_color = color.red)

    entryLine := line.new(bar_index, entry, bar_index + 20, entry, color = color.blue, width = 2)
    slLine := line.new(bar_index, sl, bar_index + 20, sl, color = color.red, width = 2)
    tp1Line := line.new(bar_index, tp1, bar_index + 20, tp1, color = color.green, width = 2)
    tp2Line := line.new(bar_index, tp2, bar_index + 20, tp2, color = color.green, width = 2)

    signalLabel := label.new(bar_index, high, 'SELL\nEntry: ' + str.tostring(entry) + '\nSL: ' + str.tostring(sl) + '\nTP1: ' + str.tostring(tp1) + '\nTP2: ' + str.tostring(tp2), style = label.style_label_down, color = color.red, textcolor = color.white)
    signalLabel

// Auto Trend Lines
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float lastHigh1 = na
var float lastHigh2 = na
var int lastHighBar1 = na
var int lastHighBar2 = na

var float lastLow1 = na
var float lastLow2 = na
var int lastLowBar1 = na
var int lastLowBar2 = na

var line downTrendLine = na
var line upTrendLine = na

if not na(ph)
    lastHigh2 := lastHigh1
    lastHighBar2 := lastHighBar1
    lastHigh1 := ph
    lastHighBar1 := bar_index - pivotLen

    if not na(downTrendLine)
        line.delete(downTrendLine)

    if not na(lastHigh2)
        downTrendLine := line.new(lastHighBar2, lastHigh2, lastHighBar1, lastHigh1, extend = extend.right, color = color.red, width = 2)
        downTrendLine

if not na(pl)
    lastLow2 := lastLow1
    lastLowBar2 := lastLowBar1
    lastLow1 := pl
    lastLowBar1 := bar_index - pivotLen

    if not na(upTrendLine)
        line.delete(upTrendLine)

    if not na(lastLow2)
        upTrendLine := line.new(lastLowBar2, lastLow2, lastLowBar1, lastLow1, extend = extend.right, color = color.green, width = 2)
        upTrendLine

// Alerts
alertcondition(buySignal, 'BUY Signal', 'Gold BUY Signal 5M')
alertcondition(sellSignal, 'SELL Signal', 'Gold SELL Signal 5M')
````
