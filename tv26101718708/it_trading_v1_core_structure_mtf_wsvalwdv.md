# IT TRADING V1 [Core Structure + MTF]

- url: https://www.tradingview.com/script/wSValWDv-IT-TRADING-V1-Core-Structure-MTF/
- type: indicator
- pine_id: PUB;095a2ffe1a7c487aa309df6db110b53f
- version: 1.0

## Description

IT TRADING V1 maps market structure across swing degrees and lets you view the structure of any timeframe you choose, directly on your current chart.

WHAT IT DOES
The script detects swing points, groups them into short-term and intermediate-term structure, marks the intermediate levels as protected levels, and shows a simple internal bias based on how price is trading relative to those levels.

HOW IT WORKS
1. Short-term swings (STH / STL): Pivot highs and lows are detected using the Base Pivot Strength setting. A swing is only accepted if its distance from the previous opposite swing is larger than an ATR-based minimum, which filters out small noise swings.
2. Intermediate-term points (ITH / ITL): An ITL is a short-term low that sits below both the short-term low before it and the one after it. An ITH is the mirror case on the high side.
3. Protected levels: The latest ITL and ITH are drawn as horizontal lines extending to the right, starting from the swing where they formed.
4. Internal bias: Price is compared with the latest ITL and ITH, and the dashboard shows one of: Neutral, Bullish Protected, Bearish Protected, Bullish ITL Broken, Bearish ITH Broken.
5. Multi-timeframe mapping: Use the Structure Timeframe input to calculate all of the above on a different timeframe, for example a 4H structure on a 5m chart. Leave it blank to use the chart timeframe.

SETTINGS
- Structure Timeframe: the timeframe used for structure mapping (blank = chart timeframe)
- Base Pivot Strength: number of bars on each side of a pivot
- ATR Length / Minimum Swing ATR Filter: controls how large a swing must be to count
- Show STH/STL, Show ITH/ITL, Show Protected Levels: toggle each layer

HOW TO USE
- Choose a structure timeframe higher than your chart timeframe.
- Use ITL/ITH lines as reference levels for structure, and the dashboard as a quick read on bias.
- A lower pivot strength gives more swings; a higher one gives fewer, more significant swings.

IMPORTANT NOTES
- Pivots are confirmed only after the pivot-strength number of bars has closed on the selected timeframe, so labels appear with a delay. This is how pivot detection works, not a bug.
- The higher-timeframe data is requested without lookahead.
- If the selected timeframe is lower than the chart timeframe, a warning appears in the dashboard.
- This tool is for analysis and education only. It does not generate buy or sell signals and is not financial advice. Past structure does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("IT TRADING V1 [Core Structure + MTF]", overlay = true, max_labels_count = 500, max_lines_count = 500)

//====================================================
// INPUTS
//====================================================
structTF      = input.timeframe("", "Structure Timeframe (blank = chart TF)", tooltip = "Jis timeframe ki structure mapping dekhni hai wo yahan select karein. Khali chhorne par current chart timeframe use hoga.")

pivotLen      = input.int(2, "Base Pivot Strength", minval = 1)
atrLen        = input.int(14, "ATR Length")
atrMultiplier = input.float(0.4, "Minimum Swing ATR Filter", step = 0.1)

showST        = input.bool(true, "Show STH/STL")
showIT        = input.bool(true, "Show ITH/ITL")
showProtected = input.bool(true, "Show Protected Levels")

//====================================================
// STRUCTURE ENGINE (runs inside the selected timeframe)
// Returns the latest confirmed STL / STH / ITL / ITH
// as [price, time] pairs.
//====================================================
structureCalc(int pLen, int aLen, float aMult) =>
    atr_      = ta.atr(aLen)
    minSwing_ = atr_ * aMult

    pLow_  = ta.pivotlow(low, pLen, pLen)
    pHigh_ = ta.pivothigh(high, pLen, pLen)

    var float lastSTLLow  = na
    var float lastSTHHigh = na

    var float[] stlPrices = array.new_float()
    var int[]   stlTimes  = array.new_int()
    var float[] sthPrices = array.new_float()
    var int[]   sthTimes  = array.new_int()

    var float stlP = na
    var int   stlT = na
    var float sthP = na
    var int   sthT = na
    var float itlP = na
    var int   itlT = na
    var float ithP = na
    var int   ithT = na

    validSTL = not na(pLow_)  and (na(lastSTHHigh) or math.abs(lastSTHHigh - pLow_) > minSwing_)
    validSTH = not na(pHigh_) and (na(lastSTLLow)  or math.abs(pHigh_ - lastSTLLow) > minSwing_)

    if validSTL
        lastSTLLow := pLow_
        array.push(stlPrices, pLow_)
        array.push(stlTimes, time[pLen])
        stlP := pLow_
        stlT := time[pLen]

        // ITL: middle STL lower than both neighbours
        n = array.size(stlPrices)
        if n >= 3
            leftS  = array.get(stlPrices, n - 3)
            midS   = array.get(stlPrices, n - 2)
            rightS = array.get(stlPrices, n - 1)
            if midS < leftS and midS < rightS
                itlP := midS
                itlT := array.get(stlTimes, n - 2)

    if validSTH
        lastSTHHigh := pHigh_
        array.push(sthPrices, pHigh_)
        array.push(sthTimes, time[pLen])
        sthP := pHigh_
        sthT := time[pLen]

        // ITH: middle STH higher than both neighbours
        m = array.size(sthPrices)
        if m >= 3
            leftH  = array.get(sthPrices, m - 3)
            midH   = array.get(sthPrices, m - 2)
            rightH = array.get(sthPrices, m - 1)
            if midH > leftH and midH > rightH
                ithP := midH
                ithT := array.get(sthTimes, m - 2)

    [stlP, stlT, sthP, sthT, itlP, itlT, ithP, ithT]

//====================================================
// REQUEST SELECTED TIMEFRAME
//====================================================
[stlP, stlT, sthP, sthT, itlP, itlT, ithP, ithT] =
     request.security(syminfo.tickerid, structTF, structureCalc(pivotLen, atrLen, atrMultiplier), lookahead = barmerge.lookahead_off)

tfIsLower = timeframe.in_seconds(structTF == "" ? timeframe.period : structTF) < timeframe.in_seconds(timeframe.period)

//====================================================
// DRAW STL / STH
//====================================================
var int lastSTLT = na
var int lastSTHT = na

newSTL = not na(stlT) and (na(lastSTLT) or stlT != lastSTLT)
newSTH = not na(sthT) and (na(lastSTHT) or sthT != lastSTHT)

if newSTL
    lastSTLT := stlT
    if showST
        label.new(stlT, stlP, "STL", xloc = xloc.bar_time, style = label.style_label_up, size = size.tiny, color = color.lime, textcolor = color.black)

if newSTH
    lastSTHT := sthT
    if showST
        label.new(sthT, sthP, "STH", xloc = xloc.bar_time, style = label.style_label_down, size = size.tiny, color = color.red, textcolor = color.white)

//====================================================
// DRAW ITL / ITH + PROTECTED LEVELS
//====================================================
var int lastITLT = na
var int lastITHT = na
var line itlLine = na
var line ithLine = na

newITL = not na(itlT) and (na(lastITLT) or itlT != lastITLT)
newITH = not na(ithT) and (na(lastITHT) or ithT != lastITHT)

if newITL
    lastITLT := itlT
    if showIT
        label.new(itlT, itlP, "ITL", xloc = xloc.bar_time, style = label.style_label_up, size = size.small, color = color.blue, textcolor = color.white)
    if showProtected
        line.delete(itlLine)
        itlLine := line.new(itlT, itlP, time, itlP, xloc = xloc.bar_time, extend = extend.right, color = color.blue, width = 2)

if newITH
    lastITHT := ithT
    if showIT
        label.new(ithT, ithP, "ITH", xloc = xloc.bar_time, style = label.style_label_down, size = size.small, color = color.orange, textcolor = color.white)
    if showProtected
        line.delete(ithLine)
        ithLine := line.new(ithT, ithP, time, ithP, xloc = xloc.bar_time, extend = extend.right, color = color.orange, width = 2)

//====================================================
// INTERNAL BIAS ENGINE
//====================================================
var string internalBias = "Neutral"

if not na(itlP) and close > itlP
    internalBias := "Bullish Protected"

if not na(ithP) and close < ithP
    internalBias := "Bearish Protected"

if not na(itlP) and close < itlP
    internalBias := "Bullish ITL Broken"

if not na(ithP) and close > ithP
    internalBias := "Bearish ITH Broken"

//====================================================
// BIAS DASHBOARD
//====================================================
var table dash = table.new(position.top_right, 1, 3)

if barstate.islast
    shownTF = structTF == "" ? timeframe.period : structTF
    table.cell(dash, 0, 0, "Structure TF: " + shownTF, bgcolor = color.new(color.gray, 20), text_color = color.white)
    table.cell(dash, 0, 1, "Internal Bias: " + internalBias, bgcolor = color.black, text_color = color.white)
    table.cell(dash, 0, 2, tfIsLower ? "Warning: selected TF chart TF se chhota hai" : "", bgcolor = tfIsLower ? color.maroon : na, text_color = color.white)
````
