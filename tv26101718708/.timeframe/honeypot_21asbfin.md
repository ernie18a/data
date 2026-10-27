# HoneyPot

- url: https://www.tradingview.com/script/21AsBfIN-HoneyPot/
- type: indicator
- pine_id: PUB;f22ece5a811f4f6895242b28439546c9
- version: 1.0

## Description

FVGs, IFVGs, Order Blocks. The script was created to help aid in the right direction for entering a trade off of an order block or FVGs

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Liquidity Sweeps, IFVGs & Order Blocks", overlay = true, max_boxes_count = 500, max_lines_count = 500)

// --- Groups ---
group_fvg     = "Fair Value Gaps (FVG) & IFVG"
group_ob      = "Order Blocks (OB)"
group_sweep   = "Liquidity Sweeps"
group_cons    = "Consolidation"
group_swings  = "Swing Points"
group_4h      = "4H Candle Direction"

// --- Inputs ---
fvgBullColor  = input.color(color.new(#089981, 70), "Bullish IFVG Color", group = group_fvg, tooltip = "Only visible on 15m timeframe.")
fvgBearColor  = input.color(color.new(#f23645, 70), "Bearish IFVG Color", group = group_fvg, tooltip = "Only visible on 15m timeframe.")

obBullColor   = input.color(color.new(#089981, 80), "Bullish OB Color", group = group_ob)
obBearColor   = input.color(color.new(#f23645, 80), "Bearish OB Color", group = group_ob)
obShowLabels  = input.bool(true, "Show OB Labels", group = group_ob)

sweepLen      = input.int(20, "Pivot Lookback", minval = 1, group = group_sweep)
sweepWidth    = input.int(2, "Sweep Line Width", minval = 1, group = group_sweep)

consBars      = input.int(20, "Consolidation Bars", minval = 5, group = group_cons)
consThreshold = input.float(0.15, "Consolidation Range %", minval = 0.01, step = 0.01, group = group_cons)
consColor     = input.color(color.new(color.purple, 90), "Consolidation Color", group = group_cons)

swingLen      = input.int(3, "Swing Lookback", minval = 1, group = group_swings)
swingHiColor  = input.color(color.red, "Swing High Dot", group = group_swings)
swingLoColor  = input.color(color.green, "Swing Low Dot", group = group_swings)

dirColorBull  = input.color(#089981, "4H Bullish Color", group = group_4h)
dirColorBear  = input.color(#f23645, "4H Bearish Color", group = group_4h)

// --- Types ---
type FVG
    float top
    float bottom
    int   startBar
    bool  isBullish
    bool  isMitigated = false

type OB
    float top
    float bottom
    int   startBar
    bool  isBullish
    bool  isMitigated = false

// --- State Variables ---
var fvgArray = array.new<FVG>()
var obArray  = array.new<OB>()

// --- Swing Points ---
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

plotshape(ph, "Swing High", shape.circle, location.abovebar, color = swingHiColor, offset = -swingLen, size = size.tiny)
plotshape(pl, "Swing Low", shape.circle, location.belowbar, color = swingLoColor, offset = -swingLen, size = size.tiny)

// --- FVG & OB Detection ---
bullFVG = low[0] > high[2]
bearFVG = high[0] < low[2]

// Add to FVG Array
if bullFVG
    array.push(fvgArray, FVG.new(low[0], high[2], bar_index - 1, true))
    // Potential Bullish OB: The candle that caused the gap (index 1 or 2)
    array.push(obArray, OB.new(high[2], low[2], bar_index - 2, true))
    
if bearFVG
    array.push(fvgArray, FVG.new(low[2], high[0], bar_index - 1, false))
    // Potential Bearish OB
    array.push(obArray, OB.new(high[2], low[2], bar_index - 2, false))

// --- IFVG Logic (Restricted to 15m) ---
is15m = timeframe.isintraday and timeframe.multiplier == 15

if array.size(fvgArray) > 0
    for i = array.size(fvgArray) - 1 to 0
        fvg = array.get(fvgArray, i)
        
        if not fvg.isMitigated
            if fvg.isBullish
                if close < fvg.bottom
                    if is15m
                        box.new(fvg.startBar, fvg.top, bar_index, fvg.bottom, border_color = na, bgcolor = fvgBearColor)
                    fvg.isMitigated := true
            else
                if close > fvg.top
                    if is15m
                        box.new(fvg.startBar, fvg.top, bar_index, fvg.bottom, border_color = na, bgcolor = fvgBullColor)
                    fvg.isMitigated := true

// --- Order Block Visuals ---
if array.size(obArray) > 0
    for i = array.size(obArray) - 1 to 0
        ob = array.get(obArray, i)
        if not ob.isMitigated           
            if ob.isBullish
                if low < ob.bottom
                    ob.isMitigated := true
                else
                    box.new(math.max(ob.startBar, bar_index - 5000), ob.top, bar_index, ob.bottom, border_color = color.new(obBullColor, 50), bgcolor = obBullColor, text = obShowLabels ? "Bull OB" : "")
            else
                if high > ob.top
                    ob.isMitigated := true
                else
                    box.new(math.max(ob.startBar, bar_index - 5000), ob.top, bar_index, ob.bottom, border_color = color.new(obBearColor, 50), bgcolor = obBearColor, text = obShowLabels ? "Bear OB" : "")
// --- Liquidity Sweeps Logic ---
hiPivot = ta.pivothigh(high, sweepLen, sweepLen)
loPivot = ta.pivotlow(low, sweepLen, sweepLen)
var float lastHi = na
var float lastLo = na
if not na(hiPivot)
    lastHi := hiPivot
if not na(loPivot)
    lastLo := loPivot

sweepHigh = high > lastHi and close < lastHi
sweepLow  = low < lastLo and close > lastLo

if sweepHigh
    line.new(bar_index, lastHi, bar_index + 5, lastHi, color = color.black, width = sweepWidth)
if sweepLow
    line.new(bar_index, lastLo, bar_index + 5, lastLo, color = color.black, width = sweepWidth)

// --- 4H Candle Direction ---
[h4Open, h4Close] = request.security(syminfo.tickerid, "240", [open, close], lookahead = barmerge.lookahead_on)
is4HBull = h4Close >= h4Open

var table dirTable = table.new(position.top_right, 1, 1)
if barstate.islast
    table.cell(dirTable, 0, 0, "4H: " + (is4HBull ? "BULL" : "BEAR"), bgcolor = is4HBull ? dirColorBull : dirColorBear, text_color = color.white, text_size = size.small)

// --- Consolidation Logic ---
isLowerTF = timeframe.isintraday and timeframe.multiplier <= 15
hRange = ta.highest(high, consBars)
lRange = ta.lowest(low, consBars)
isInCons = (hRange - lRange) / lRange * 100 <= consThreshold

var box cBox = na
if isLowerTF and isInCons
    if na(cBox) or bar_index % consBars == 0
        cBox := box.new(bar_index - consBars + 1, hRange, bar_index, lRange, border_color = na, bgcolor = consColor)
    else
        box.set_right(cBox, bar_index)
        box.set_top(cBox, hRange)
        box.set_bottom(cBox, lRange)
else
    cBox := na
````
