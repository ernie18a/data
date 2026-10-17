# FVG + Order Block Toolkit [ForexCracked]

- url: https://www.tradingview.com/script/y56P9L6q-FVG-Order-Block-Toolkit-ForexCracked/
- type: indicator
- pine_id: PUB;444330efee19483bb6eb0d70d32dc41a
- version: 1.0

## Description

🔷 OVERVIEW

Two of the most-watched smart money footprints on one clean chart. This toolkit auto-draws Fair Value Gaps and Order Blocks as zones, keeps only the ones that still matter, and shows a live count in a compact dashboard. Fair value gaps are drawn as soft fills and order blocks as bordered blocks, so you can tell the two apart at a glance. It is free and open-source.

🔷 HOW IT DETECTS THE ZONES

Fair Value Gaps: a three-candle imbalance. A bullish FVG is marked when the low of the current candle sits above the high of the candle two bars back, leaving an untraded gap. A bearish FVG is the mirror. Gaps smaller than your Min FVG size (measured in ATR) are filtered out so the chart stays clean.

Order Blocks: displacement based. When a candle closes with a body larger than your Displacement setting (in ATR), the toolkit marks the last opposing candle before that move as the order block. A strong bullish move leaves a bullish order block on the last down candle, and the reverse for bearish.

🔷 ZONE MANAGEMENT

Every zone extends to the right until price closes through it (mitigated) or it passes the Max zone age. That means the boxes on your chart are the ones that are still unmitigated, not old clutter.

🔷 THE DASHBOARD

A compact, positionable panel shows the live count of unmitigated bullish and bearish Fair Value Gaps and Order Blocks, plus a total. Drop it in any corner.

🔷 HOW TO USE

Treat the zones as areas of interest, not automatic trades. Watch for price to return to an unmitigated order block or fair value gap in the direction of your higher-timeframe bias, then confirm with your own analysis and use a stop. Higher timeframes produce fewer and stronger zones.

🔷 SETTINGS

Fair Value Gaps: show on/off, Min FVG size (x ATR), colours. Order Blocks: show on/off, Displacement (x ATR), OB lookback, colours. General: Max zone age, Extend right, Info panel + position.

🔷 ALERTS

New Fair Value Gap, and New Order Block.

Free and open-source. Educational tool, not financial advice.

## Source Code

````pine
//@version=6
// © ForexCracked  —  free & open-source  —  Licensed under CC BY-NC-SA 4.0
// https://creativecommons.org/licenses/by-nc-sa/4.0/

indicator("FVG + Order Block Toolkit [ForexCracked]", "FVG+OB [Forexcracked]", overlay = true, max_boxes_count = 500)

//=====================================================================================================================
// INPUTS
//=====================================================================================================================
gF = "Fair Value Gaps"
showFVG    = input.bool(true,  "Show Fair Value Gaps", group = gF)
fvgMinATR  = input.float(0.25, "Min FVG size (x ATR)", minval = 0, step = 0.05, group = gF, tooltip = "Ignore gaps smaller than this fraction of ATR.")
fvgBullCol = input.color(color.new(#2dd4bf, 86), "Bullish FVG", inline = "fc", group = gF, tooltip = "FVGs draw as a soft fill with no border.")
fvgBearCol = input.color(color.new(#e84e89, 86), "Bearish FVG", inline = "fc", group = gF)

gO = "Order Blocks"
showOB   = input.bool(true, "Show Order Blocks", group = gO)
obFactor = input.float(1.3, "Displacement (x ATR)", minval = 0.2, step = 0.1, group = gO, tooltip = "How strong the move must be to leave an order block.")
obLook   = input.int(5, "OB lookback (bars)", minval = 1, maxval = 20, group = gO, tooltip = "How far back to find the last opposing candle before the move.")
obBullCol = input.color(color.new(#2dd4bf, 68), "Bullish OB", inline = "oc", group = gO, tooltip = "OBs draw more solid with a colored border, so they stand out from FVGs.")
obBearCol = input.color(color.new(#e84e89, 68), "Bearish OB", inline = "oc", group = gO)

gG = "General"
maxAge   = input.int(300, "Max zone age (bars)", minval = 20, group = gG)
extendN  = input.int(20,  "Extend right (bars)", minval = 0, group = gG)
showTbl  = input.bool(true, "Info panel", group = gG)
tblPosIn = input.string("Top Right", "Panel position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = gG)
tblPos = tblPosIn == "Top Left" ? position.top_left : tblPosIn == "Bottom Right" ? position.bottom_right : tblPosIn == "Bottom Left" ? position.bottom_left : position.top_right

atr = ta.atr(14)

//=====================================================================================================================
// STATE (one box array + one direction array per zone type)
//=====================================================================================================================
var array<box> fvgBoxes = array.new<box>()
var array<int> fvgDir   = array.new<int>()
var array<box> obBoxes  = array.new<box>()
var array<int> obDir    = array.new<int>()

// extend active zones, delete when price closes through them (mitigated) or when they age out
manageZones(array<box> boxes, array<int> dirs) =>
    n = array.size(boxes)
    if n > 0
        i = n - 1
        while i >= 0
            b   = array.get(boxes, i)
            d   = array.get(dirs, i)
            top = box.get_top(b)
            bot = box.get_bottom(b)
            lft = box.get_left(b)
            mitigated = (d > 0 and close < bot) or (d < 0 and close > top)
            aged      = (bar_index - lft) > maxAge
            if mitigated or aged
                box.delete(b)
                array.remove(boxes, i)
                array.remove(dirs, i)
            else
                box.set_right(b, bar_index + extendN)
            i := i - 1

//=====================================================================================================================
// FAIR VALUE GAPS (3-candle imbalance; current bar completes the pattern)
//=====================================================================================================================
if showFVG and not na(atr)
    if low > high[2] and (low - high[2]) > fvgMinATR * atr
        bx = box.new(bar_index - 2, low, bar_index + extendN, high[2], border_color = na, bgcolor = fvgBullCol)
        array.push(fvgBoxes, bx)
        array.push(fvgDir, 1)
    if high < low[2] and (low[2] - high) > fvgMinATR * atr
        bx = box.new(bar_index - 2, low[2], bar_index + extendN, high, border_color = na, bgcolor = fvgBearCol)
        array.push(fvgBoxes, bx)
        array.push(fvgDir, -1)

//=====================================================================================================================
// ORDER BLOCKS (strong displacement candle -> last opposing candle before it)
//=====================================================================================================================
if showOB and not na(atr)
    body = math.abs(close - open)
    // bullish displacement -> bullish order block = last bearish candle in lookback
    if close > open and body > obFactor * atr
        idx = 0
        for k = 1 to obLook
            if close[k] < open[k]
                idx := k
                break
        if idx > 0
            bx = box.new(bar_index - idx, high[idx], bar_index + extendN, low[idx], border_color = color.new(#2dd4bf, 10), border_width = 1, bgcolor = obBullCol)
            array.push(obBoxes, bx)
            array.push(obDir, 1)
    // bearish displacement -> bearish order block = last bullish candle in lookback
    if close < open and body > obFactor * atr
        idx = 0
        for k = 1 to obLook
            if close[k] > open[k]
                idx := k
                break
        if idx > 0
            bx = box.new(bar_index - idx, high[idx], bar_index + extendN, low[idx], border_color = color.new(#e84e89, 10), border_width = 1, bgcolor = obBearCol)
            array.push(obBoxes, bx)
            array.push(obDir, -1)

manageZones(fvgBoxes, fvgDir)
manageZones(obBoxes, obDir)

//=====================================================================================================================
// INFO PANEL
//=====================================================================================================================
if showTbl and barstate.islast
    bg  = #1a2c4c
    lbl = #9fb0c4
    nFvgB = 0
    nFvgS = 0
    nObB  = 0
    nObS  = 0
    if array.size(fvgDir) > 0
        for i = 0 to array.size(fvgDir) - 1
            if array.get(fvgDir, i) > 0
                nFvgB := nFvgB + 1
            else
                nFvgS := nFvgS + 1
    if array.size(obDir) > 0
        for i = 0 to array.size(obDir) - 1
            if array.get(obDir, i) > 0
                nObB := nObB + 1
            else
                nObS := nObS + 1
    hd    = #1f3a63
    tealC = #2dd4bf
    pinkC = #e84e89
    var table t = table.new(tblPos, 3, 4, bgcolor = bg, frame_color = color.new(color.gray, 55), frame_width = 1, border_color = color.new(#2a3d63, 25), border_width = 1)
    table.cell(t, 0, 0, " FVG + OB ", text_color = color.white, bgcolor = hd, text_size = size.normal)
    table.cell(t, 1, 0, "Bull", text_color = tealC, bgcolor = hd, text_size = size.small)
    table.cell(t, 2, 0, "Bear", text_color = pinkC, bgcolor = hd, text_size = size.small)
    table.cell(t, 0, 1, "FVG", text_color = lbl, text_size = size.small)
    table.cell(t, 1, 1, str.tostring(nFvgB), text_color = tealC, text_size = size.normal)
    table.cell(t, 2, 1, str.tostring(nFvgS), text_color = pinkC, text_size = size.normal)
    table.cell(t, 0, 2, "OB", text_color = lbl, text_size = size.small)
    table.cell(t, 1, 2, str.tostring(nObB), text_color = tealC, text_size = size.normal)
    table.cell(t, 2, 2, str.tostring(nObS), text_color = pinkC, text_size = size.normal)
    table.cell(t, 0, 3, "Total", text_color = color.white, text_size = size.small)
    table.cell(t, 1, 3, str.tostring(nFvgB + nObB), text_color = tealC, text_size = size.normal)
    table.cell(t, 2, 3, str.tostring(nFvgS + nObS), text_color = pinkC, text_size = size.normal)

//=====================================================================================================================
// ALERTS
//=====================================================================================================================
newFvg = showFVG and ((low > high[2] and (low - high[2]) > fvgMinATR * atr) or (high < low[2] and (low[2] - high) > fvgMinATR * atr))
newOb  = showOB and (math.abs(close - open) > obFactor * atr)
alertcondition(newFvg, "New Fair Value Gap", "A new fair value gap formed")
alertcondition(newOb,  "New Order Block", "A displacement candle left a new order block")
````
