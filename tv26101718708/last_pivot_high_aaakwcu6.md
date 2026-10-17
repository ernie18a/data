# Last pivot high

- url: https://www.tradingview.com/script/aaaKWCu6-Last-pivot-high/
- type: indicator
- pine_id: PUB;7a92449e08d94fc289f0358fad0d64fe
- version: 1.0

## Description

To be used in conjunction with my HH Indicators for ASX sectors. This indicator marks the last pivot high that the HH Indicators are comparing the current price against. 

The price of the last pivot high is determined by the top of the candle body.

The indicator can be used on any timeframe - it will pick up the last pivot high based on that timeframe.

## Source Code

````pine
//@version=5
indicator("Last pivot high - body top", overlay=true)

// --- 1. SETTINGS ---
lookback   = input.int(3, "Pivot Strength", minval=1)
lineColor  = input.color(color.teal, "Line Color")
sigColor   = input.color(color.green, "Signal Color")
maxSignals = 10 

// --- 2. BODY TOP LOGIC ---
// We calculate the top of the body for every bar
bodyTop = math.max(open, close)
bodyBtm = math.min(open, close)

pHighFound = true
// Check neighbors using bodyTop instead of Close or High
for i = 0 to (lookback * 2)
    if i != lookback
        if not (bodyTop[lookback] >= bodyTop[i])
            pHighFound := false

// --- 3. STORAGE & LINE VISUALS ---
var float lastPH = na
var line phLine = line.new(x1=na, y1=na, x2=na, y2=na, color=lineColor, width=1, style=line.style_dashed)
var label phValueLabel = label.new(x=na, y=na, text="", color=lineColor, textcolor=color.white, style=label.style_label_down, size=size.small)

if pHighFound
    lastPH := bodyTop[lookback]
    line.set_xy1(phLine, bar_index[lookback], lastPH)
    line.set_xy2(phLine, bar_index, lastPH)
    label.set_xy(phValueLabel, bar_index[lookback], lastPH)
    label.set_text(phValueLabel, "Pivot: " + str.tostring(lastPH))

if not na(lastPH)
    line.set_x2(phLine, bar_index)

// --- 4. SIGNAL QUEUE (LAST 10 BREAKOUTS) ---
var label[] signalQueue = array.new_label()

// Trigger: Current CLOSE clears the Last Body-Top Pivot
isBreakout = ta.crossover(close, lastPH)

if isBreakout
    newSig = label.new(bar_index, low, 
         text="▲", 
         color=color.new(color.white, 100), 
         textcolor=sigColor, 
         style=label.style_label_up, 
         size=size.small)
    
    array.push(signalQueue, newSig)
    
    if array.size(signalQueue) > maxSignals
        label.delete(array.shift(signalQueue))
````
