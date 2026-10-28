# OHLC Touch Levels

- url: https://www.tradingview.com/script/9aHyjbes-OHLC-Touch-Levels/
- type: indicator
- pine_id: PUB;f9dd1d5ddde245939e9e310ab0821d54
- version: 2.0

## Description

The indicator collects all Open, High, Low, and Close values from tens of thousands of historical bars and groups them into price zones. When many OHLC values from different bars fall within the same price range, they merge into a single zone. The more unique bars that contributed prices to a zone, the stronger it is considered. The idea is that a price the market repeatedly chose to open at, close at, or reach as an extreme carries significance — and the market is likely to react to it again in the future.

## Source Code

````pine
//@version=6
indicator("Previous Day High / Low / Close", "PD HLC", overlay=true)

// ─────────── Inputs ───────────
onlyLast   = input.bool(false, "Show Only Current Day")
showPDH    = input.bool(true,  "Show Prev Day High")
showPDL    = input.bool(true,  "Show Prev Day Low")
showPDC    = input.bool(true,  "Show Prev Day Close")
showLabels = input.bool(true,  "Show Labels")

colPDH = input.color(color.new(color.green, 0), "PDH Color")
colPDL = input.color(color.new(color.red, 0),   "PDL Color")
colPDC = input.color(color.new(color.blue, 0),  "PDC Color")

lineW  = input.int(1, "Line Width", minval=1, maxval=4)

// ─────────── Previous-day data taken DIRECTLY from chart bars (exact match) ───────────
newDay = ta.change(time("D")) != 0

var float curHigh = na
var float curLow  = na
var float pdh = na
var float pdl = na
var float pdc = na

if newDay
    pdh := curHigh      // high of the day that just ended
    pdl := curLow       // low  of the day that just ended
    pdc := close[1]     // close of the last bar of the previous day
    curHigh := high     // start tracking the new day
    curLow  := low
else
    curHigh := na(curHigh) ? high : math.max(curHigh, high)
    curLow  := na(curLow)  ? low  : math.min(curLow, low)

// ─────────── Mode 1: plots for all days (hidden when "Only Current Day" is on) ───────────
plot(newDay or onlyLast or not showPDH ? na : pdh, "Prev Day High",  colPDH, lineW, plot.style_linebr)
plot(newDay or onlyLast or not showPDL ? na : pdl, "Prev Day Low",   colPDL, lineW, plot.style_linebr)
plot(newDay or onlyLast or not showPDC ? na : pdc, "Prev Day Close", colPDC, lineW, plot.style_linebr)

// ─────────── Mode 2: lines for current day only + labels (always on last bar) ───────────
var line[]  lns  = array.new_line()
var label[] lbls = array.new_label()

if barstate.islast
    while array.size(lns) > 0
        line.delete(array.pop(lns))
    while array.size(lbls) > 0
        label.delete(array.pop(lbls))

    t1 = time("D")  // start of the current trading day
    t2 = time

    if onlyLast
        if showPDH
            array.push(lns, line.new(t1, pdh, t2, pdh, xloc=xloc.bar_time, extend=extend.none, color=colPDH, width=lineW))
        if showPDL
            array.push(lns, line.new(t1, pdl, t2, pdl, xloc=xloc.bar_time, extend=extend.none, color=colPDL, width=lineW))
        if showPDC
            array.push(lns, line.new(t1, pdc, t2, pdc, xloc=xloc.bar_time, extend=extend.none, color=colPDC, width=lineW))

    if showLabels
        if showPDH
            array.push(lbls, label.new(t2, pdh, "PDH " + str.tostring(pdh, format.mintick), xloc=xloc.bar_time, style=label.style_label_left, color=color.new(colPDH, 85), textcolor=colPDH, size=size.small))
        if showPDL
            array.push(lbls, label.new(t2, pdl, "PDL " + str.tostring(pdl, format.mintick), xloc=xloc.bar_time, style=label.style_label_left, color=color.new(colPDL, 85), textcolor=colPDL, size=size.small))
        if showPDC
            array.push(lbls, label.new(t2, pdc, "PDC " + str.tostring(pdc, format.mintick), xloc=xloc.bar_time, style=label.style_label_left, color=color.new(colPDC, 85), textcolor=colPDC, size=size.small))
````
