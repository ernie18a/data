# ITH / ITL By SAJID  [Core Structure]

- url: https://www.tradingview.com/script/e9V3ilPc-ITH-ITL-By-SAJID-Core-Structure/
- type: indicator
- pine_id: PUB;9c732df9d2f740b0aa5fc16d9363bec8
- version: 1.0

## Description

Guide to Identifying and Trading ITL/ITH
1. Definition of ITL (Intermediate Term Low): An ITL is a mid-swing low that must have a Short Term Low (STL) on both its left and right sides
. The mid-swing must be the lowest point, while the left and right STLs must be higher than the mid-swing
.
2. Definition of ITH (Intermediate Term High): An ITH is a mid-swing high characterized by having a Short Term High (STH) on both its left and right sides
. The mid-swing must be the highest point, with the flanking STHs positioned lower than the mid-swing
.
3. The Role of ITL/ITH in Market Bias:
Guards of Bias: ITL and ITH act as the "guards" of the market direction
.
Bias Protection: In a bullish market, the ITL should not be broken; only STLs might be hunted for liquidity
. If a strong ITL is broken, it signal a potential shift in bias or that the market has reached its destination
.
Confirmation: Breaking an ITH in a bearish trend suggests that the bearish bias is either wrong or has completed
.
4. Timeframe Hierarchy:
The "King" Timeframes: The 4-Hour (4H) and Daily ITL/ITH are considered the "Kings" as they dictate the overall institutional narrative
.
Lower Timeframes (LTF): ITL/ITH on 15m or 5m are for internal structure and intraday entries
. An LTF break does not change the HTF (4H/Daily) bias; it only indicates a temporary or internal move
.
5. Trading Strategy using ITL/ITH:
Identify the HTF ITL/ITH to confirm the major direction
.
Look for price to reach a POI (Order Block or FVG) located within the Discount Zone (for buys) or Premium Zone (for sells)
.
Use the protection of an ITL/ITH to place logical stop losses and target External Liquidity

## Source Code

````pine
//@version=5
indicator("Institutional Narrative Engine V1 [Core Structure]", overlay = true, max_labels_count = 500, max_lines_count = 500)

//====================================================
// INPUTS
//====================================================
pivotLen      = input.int(2, "Base Pivot Strength", minval = 1)
atrLen        = input.int(14, "ATR Length")
atrMultiplier = input.float(0.4, "Minimum Swing ATR Filter", step = 0.1)

showST        = input.bool(true, "Show STH/STL")
showIT        = input.bool(true, "Show ITH/ITL")
showProtected = input.bool(true, "Show Protected Levels")

//====================================================
// ATR FILTER
//====================================================
atr = ta.atr(atrLen)
minSwing = atr * atrMultiplier

//====================================================
// ADAPTIVE SHORT TERM SWING DETECTION
//====================================================
pLow  = ta.pivotlow(low, pivotLen, pivotLen)
pHigh = ta.pivothigh(high, pivotLen, pivotLen)

var float lastSTLLow = na
var float lastSTHHigh = na

isValidSTL = not na(pLow) and (na(lastSTHHigh) or math.abs(lastSTHHigh - pLow) > minSwing)
isValidSTH = not na(pHigh) and (na(lastSTLLow) or math.abs(pHigh - lastSTLLow) > minSwing)

if isValidSTL
    lastSTLLow := pLow

if isValidSTH
    lastSTHHigh := pHigh

//====================================================
// STORE STL/STH ARRAYS
//====================================================
var float[] stlPrices = array.new_float()
var int[]   stlBars   = array.new_int()

var float[] sthPrices = array.new_float()
var int[]   sthBars   = array.new_int()

if isValidSTL
    array.push(stlPrices, pLow)
    array.push(stlBars, bar_index - pivotLen)

if isValidSTH
    array.push(sthPrices, pHigh)
    array.push(sthBars, bar_index - pivotLen)

//====================================================
// PLOT STL / STH
//====================================================
if showST and isValidSTL
    label.new(bar_index - pivotLen, pLow, "STL", style = label.style_label_up, size = size.tiny, color = color.lime, textcolor = color.black)

if showST and isValidSTH
    label.new(bar_index - pivotLen, pHigh, "STH", style = label.style_label_down, size = size.tiny, color = color.red, textcolor = color.white)

//====================================================
// INTERMEDIATE TERM LOW/HIGH DETECTION
//====================================================
var float activeITL = na
var float activeITH = na

if array.size(stlPrices) >= 3
    leftSTL  = array.get(stlPrices, array.size(stlPrices)-3)
    midSTL   = array.get(stlPrices, array.size(stlPrices)-2)
    rightSTL = array.get(stlPrices, array.size(stlPrices)-1)

    midBar   = array.get(stlBars, array.size(stlBars)-2)

    if midSTL < leftSTL and midSTL < rightSTL
        activeITL := midSTL
        if showIT
            label.new(midBar, midSTL, "ITL", style = label.style_label_up, size = size.small, color = color.blue, textcolor = color.white)

if array.size(sthPrices) >= 3
    leftSTH  = array.get(sthPrices, array.size(sthPrices)-3)
    midSTH   = array.get(sthPrices, array.size(sthPrices)-2)
    rightSTH = array.get(sthPrices, array.size(sthPrices)-1)

    midBarH  = array.get(sthBars, array.size(sthBars)-2)

    if midSTH > leftSTH and midSTH > rightSTH
        activeITH := midSTH
        if showIT
            label.new(midBarH, midSTH, "ITH", style = label.style_label_down, size = size.small, color = color.orange, textcolor = color.white)

//====================================================
// PROTECTED LEVEL VISUALIZATION
//====================================================
var line itlLine = na
var line ithLine = na

if showProtected and not na(activeITL)
    line.delete(itlLine)
    itlLine := line.new(bar_index-50, activeITL, bar_index+20, activeITL, extend = extend.right, color = color.blue, width = 2)

if showProtected and not na(activeITH)
    line.delete(ithLine)
    ithLine := line.new(bar_index-50, activeITH, bar_index+20, activeITH, extend = extend.right, color = color.orange, width = 2)

//====================================================
// INTERNAL BIAS ENGINE
//====================================================
var string internalBias = "Neutral"

if not na(activeITL) and close > activeITL
    internalBias := "Bullish Protected"

if not na(activeITH) and close < activeITH
    internalBias := "Bearish Protected"

if not na(activeITL) and close < activeITL
    internalBias := "Bullish ITL Broken"

if not na(activeITH) and close > activeITH
    internalBias := "Bearish ITH Broken"

//====================================================
// BIAS DASHBOARD
//====================================================
var table dash = table.new(position.top_right, 1, 1)

if barstate.islast
    table.cell(dash, 0, 0, "Internal Bias: " + internalBias, bgcolor = color.black, text_color = color.white)
````
