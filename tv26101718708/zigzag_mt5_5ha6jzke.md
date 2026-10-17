# ZigZag MT5

- url: https://www.tradingview.com/script/5Ha6JzKe-ZigZag-MT5/
- type: indicator
- pine_id: PUB;6947a41fe35346a7abe7d42b74f21af2
- version: 2.0

## Description

[b]ZigZag MT5 — 1:1 Port[/b]
A faithful port of the MetaTrader 5 standard ZigZag indicator to Pine Script v6. Same algorithm, same parameters, same output — just on TradingView.
Parameters (MT5 defaults):

[b]Depth (12)[/b] — minimum bars between extrema; the lookback window for the Lowest/Highest scan
[b]Deviation (5)[/b] — minimum price deviation in points (uses syminfo.mintick) before a new extremum is accepted
[b]Backstep (3)[/b] — minimum bars between adjacent pivots; cleans up clustered extrema

[b]How it works:[/b]
Mirrors MT5's two-buffer approach (ExtHighBuffer / ExtLowBuffer). For each bar it runs the Lowest/Highest scan, applies the deviation filter, removes weaker neighboring pivots within the backstep window, and finally alternates highs and lows in a second pass — including outside-bar handling.
Note: Like every ZigZag, the last segment repaints until a new opposing pivot is confirmed. By design.
Useful as a drop-in replacement if you're migrating strategies from MT5 to TradingView and need pivot points that match exactly.

## Source Code

````pine
//@version=6
// ZigZag MT5 - 1:1 port of the MetaTrader 5 standard indicator (ZigZag.mq5)
// Source verified against: github.com/Endt4sk/MQL5/blob/master/Indicators/Examples/ZigZag.mq5
indicator("ZigZag MT5", "ZZ MT5", overlay = true, max_lines_count = 500)

depth     = input.int(12, "Depth",              minval = 1)
deviation = input.int(5,  "Deviation (Points)", minval = 0)
backstep  = input.int(3,  "Backstep",           minval = 0)
col       = input.color(color.red, "Color")
wd        = input.int(2,  "Line width",         minval = 1)

if backstep >= depth
    runtime.error("Backstep must be less than Depth")

devPx = deviation * syminfo.mintick

// ta.* called on every bar (Pine requires consistent evaluation)
lowestL  = ta.lowest(low,  depth)
highestH = ta.highest(high, depth)

// Persistent buffers (mirroring MT5 HighMapBuffer / LowMapBuffer)
var hiBuf = array.new_float()
var loBuf = array.new_float()
var tBuf  = array.new_int()
var float lastHi = 0.0
var float lastLo = 0.0

array.push(hiBuf, 0.0)
array.push(loBuf, 0.0)
array.push(tBuf,  time)

// MT5: for(shift=limit; shift<rates_total; ...) with limit=ExtDepth
if bar_index >= depth
    // --- LOWS (mirrors MT5 main loop, low side) ---
    vL = lowestL
    if vL == lastLo
        vL := 0.0
    else
        lastLo := vL
        if low - vL > devPx
            vL := 0.0
        else
            for b = 1 to backstep
                idx = bar_index - b
                if idx >= 0 and array.get(loBuf, idx) != 0 and array.get(loBuf, idx) > vL
                    array.set(loBuf, idx, 0.0)
    array.set(loBuf, bar_index, low == vL ? vL : 0.0)

    // --- HIGHS (mirror of the low logic) ---
    vH = highestH
    if vH == lastHi
        vH := 0.0
    else
        lastHi := vH
        if vH - high > devPx
            vH := 0.0
        else
            for b = 1 to backstep
                idx = bar_index - b
                if idx >= 0 and array.get(hiBuf, idx) != 0 and array.get(hiBuf, idx) < vH
                    array.set(hiBuf, idx, 0.0)
    array.set(hiBuf, bar_index, high == vH ? vH : 0.0)

// --- Final rejection pass: faithful port of MT5 switch(whatlookfor) ---
// States: 0 = uncertain (initial), 1 = Pike (looking for next high after low),
//        -1 = Sill (looking for next low after high).
// Outside bars (both HighMap and LowMap non-zero) are intentionally ignored
// in Pike/Sill states because MT5 conditions require the opposite buffer == 0.
var lines = array.new_line()

if barstate.islast
    pTimes = array.new_int()
    pVals  = array.new_float()

    int   wlf      = 0
    float lastlow  = 0.0
    float lasthigh = 0.0

    for shift = 0 to array.size(hiBuf) - 1
        h = array.get(hiBuf, shift)
        l = array.get(loBuf, shift)
        t = array.get(tBuf,  shift)

        if wlf == 0
            // MT5 case 0: both ifs run independently; second overwrites first
            if h != 0
                lasthigh := h
                wlf := -1
                array.push(pTimes, t)
                array.push(pVals,  h)
            if l != 0
                lastlow := l
                if h != 0
                    // outside bar at init: low overwrites the just-pushed high
                    array.set(pVals, array.size(pVals) - 1, l)
                else
                    array.push(pTimes, t)
                    array.push(pVals,  l)
                wlf := 1

        else if wlf == 1
            // MT5 case Pike: replace deeper low, transition on isolated high
            if l != 0 and l < lastlow and h == 0
                array.set(pTimes, array.size(pTimes) - 1, t)
                array.set(pVals,  array.size(pVals)  - 1, l)
                lastlow := l
            if h != 0 and l == 0
                lasthigh := h
                array.push(pTimes, t)
                array.push(pVals,  h)
                wlf := -1

        else
            // MT5 case Sill: replace higher high, transition on isolated low
            if h != 0 and h > lasthigh and l == 0
                array.set(pTimes, array.size(pTimes) - 1, t)
                array.set(pVals,  array.size(pVals)  - 1, h)
                lasthigh := h
            if l != 0 and h == 0
                lastlow := l
                array.push(pTimes, t)
                array.push(pVals,  l)
                wlf := 1

    // redraw
    for ln in lines
        line.delete(ln)
    array.clear(lines)

    for k = 1 to array.size(pTimes) - 1
        array.push(lines, line.new(array.get(pTimes, k - 1), array.get(pVals, k - 1),
                                   array.get(pTimes, k),     array.get(pVals, k),
                                   xloc = xloc.bar_time, color = col, width = wd))
````
