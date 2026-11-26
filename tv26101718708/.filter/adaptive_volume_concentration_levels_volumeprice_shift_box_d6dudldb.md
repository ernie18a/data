# Adaptive Volume Concentration Levels + Volume-Price Shift Box

- url: https://www.tradingview.com/script/d6dUdldb-Adaptive-Volume-Concentration-Levels-Volume-Price-Shift-Box/
- type: indicator
- pine_id: PUB;5e0875b56e1b477c99864585c3026e3e
- version: 2.0

## Description

[b]Description[/b]

Adaptive Volume Concentration Levels + Volume-Price Shift Box combines two powerful market analysis concepts into one streamlined tool: adaptive volume-based support and resistance mapping, and a real-time volume-price flow dashboard.

The script identifies the most meaningful price zones based on where volume has concentrated over a chosen lookback range, helping highlight areas where the market has shown strong interest. At the same time, it displays a compact shift box that evaluates price, volume, VWAP, OBV, A/D behavior, and momentum to estimate whether market pressure is currently bullish, bearish, or neutral.

This makes the script useful for traders who want both structural levels and contextual order-flow style bias in a single indicator.

[b]How It Works[/b]

The script has two main components:

 -Adaptive Volume Concentration Levels
[list]
[*]It scans historical price action over a customizable lookback period.
[*]Price is divided into bins, and volume is accumulated into those bins.
[*]The script then selects the highest-volume zones and converts them into horizontal support/resistance levels.
[*]A higher timeframe option and smoothing feature can be used to reduce noise and reveal more stable levels.
[*]Levels can be displayed with custom colors, line styles, transparency, and optional percentage labels.
[/list]

- Volume-Price Shift Box
[list]
[*]The dashboard evaluates several internal conditions:
[list]
[*]VWAP trend and price distance from VWAP
[*]OBV trend and OBV acceleration
[*]A/D line trend
[*]Relative volume versus average volume
[*]Price momentum
[/list]
[*]Weighted bullish and bearish scores are calculated from these components.
[*]The final shift score determines whether the current state is:
[list]
[*]Bullish
[*]Bearish
[*]Neutral
[/list]
[*]The box then displays key readings such as shift strength, volume vs average, VWAP distance, shift duration, and OBV state.
[/list]
[b]Key Features[/b]
[list]
[*]Adaptive volume-based support and resistance detection
[*]Dual SR logic for identifying important high-volume price zones
[*]Optional higher timeframe processing for cleaner structure
[*]Price smoothing to reduce noise in level calculation
[*]Customizable level count, bin density, transparency, labels, and styling
[*]Real-time shift box with bullish, bearish, or neutral bias
[*]Weighted scoring model using VWAP, OBV, A/D, volume, and momentum
[*]Shift strength readout for quick bias confirmation
[*]Shift duration tracking to show how long the current condition has persisted
[*]Clean visual layout that combines structure and flow into one script
[/list]

[b]How to Use[/b]

Start by applying the indicator to your chart and adjusting the level settings based on your trading style.

For the volume concentration levels:

[list]
[*]Increase the lookback if you want broader, more established levels.
[*]Increase the number of bins for finer price granularity.
[*]Use the minimum volume filter to remove weaker levels.
[*]Turn on the higher timeframe option if you want more stable zones from a broader market perspective.
[/list]

For the shift box:

[list]
[*]Use the default settings first, then adjust sensitivity and component weights to better match your market and timeframe.
[*]Watch for bullish or bearish shifts when price approaches one of the plotted volume levels.
[*]Use the strength reading to judge whether the bias is weak or decisive.
[*]Monitor duration to see whether the current directional pressure is fresh or extended.
[/list]

A practical workflow is:

[list]
[*]Use the horizontal levels as reaction zones
[*]Use the box to judge whether current pressure supports continuation or rejection from those zones
[*]Combine both with your existing entry and risk management rules
[/list]

[b]How It Helps[/b]
How It Helps

This script helps simplify decision-making by combining where price is likely to react with how price and volume are behaving right now.

The volume concentration levels help traders identify:

[list]
[*]likely support and resistance
[*]potential reaction zones
[*]areas of prior market agreement or interest
[/list]

The shift box helps traders evaluate:

[list]
[*]whether buyers or sellers currently have control
[*]whether momentum and volume are aligned
[*]whether market pressure is strengthening or fading
[/list]

Used together, the tool can help with:

[list]
[*]trade location
[*]directional confirmation
[*]filtering weak setups
[*]improving timing around important price zones
[/list]

It is especially useful for traders who want a clearer view of both market structure and current flow conditions without cluttering the chart with multiple separate indicators.

[b]Disclaimer[/b]

This indicator is provided for informational and educational purposes only. It does not constitute financial advice, investment advice, trading recommendations, or an offer or solicitation to buy or sell any financial instrument.

All indicator outputs, classifications (including bullish, bearish, or neutral states), and visual elements are derived from historical market data using user-defined parameters. These outputs are interpretive in nature and do not predict future market performance or guarantee any specific result.

Trading financial instruments involves substantial risk, including the risk of loss exceeding initial capital. Market conditions may change rapidly due to factors outside the scope of this indicator, including but not limited to economic events, news releases, liquidity conditions, execution quality, and slippage.

The developer assumes no responsibility or liability for any trading decisions, losses, or damages arising directly or indirectly from the use of this indicator. Users are solely responsible for evaluating the suitability of this tool for their own trading objectives, risk tolerance, and market conditions.

Past performance, indicator behavior, or historical alignment of signals does not guarantee future results. Use of this indicator constitutes acceptance of these terms.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © IndicatorEliteFlow
//@version=6
indicator("Adaptive Volume Concentration Levels + Volume-Price Shift Box", shorttitle="VolSR + Shift", overlay=true, max_lines_count=200, max_labels_count=200, max_bars_back=5000)

//────────────────────────────────────────────
// TYPE
//────────────────────────────────────────────
type LevelNode
    float price
    float vol

//────────────────────────────────────────────
// INPUTS
//────────────────────────────────────────────

// Adaptive Volume Concentration Levels
group_calc_1   = "Calculation Settings"
lookbackBars_1 = input.int(300, "Lookback Bars", minval=20, maxval=5000, group=group_calc_1, tooltip="Number of historical bars to analyze.")
bins_1         = input.int(50, "Price Bins", minval=10, maxval=400, group=group_calc_1, tooltip="Granularity of the volume profile.")
topLevels_1    = input.int(6, "Max SR Lines", minval=1, maxval=20, group=group_calc_1, tooltip="Number of key levels to display.")
minVolumePct_1 = input.float(1.0, "Min Volume % Filter", step=0.1, group=group_calc_1, tooltip="Minimum volume weight required to show a level.")

group_mtf_1    = "MTF & Smoothing"
useHTF_1       = input.bool(true, "Enable Higher Timeframe?", group=group_mtf_1)
htf_tf_1       = input.timeframe("60", "HTF Selection", group=group_mtf_1)
smoothLen_1    = input.int(1, "Price Smoothing (0=None)", minval=0, maxval=50, group=group_mtf_1)

group_vis_1    = "Adaptive Levels Visuals"
colStrong_1    = input.color(#26a69a, "Strongest Level", group=group_vis_1)
colMedium_1    = input.color(#ff9800, "Medium Level", group=group_vis_1)
colWeak_1      = input.color(#f44336, "Weakest Level", group=group_vis_1)
lineWidth_1    = input.int(2, "Line Width", minval=1, maxval=5, group=group_vis_1)
extendLines_1  = input.string("Right", "Extend Style", options=["None", "Right", "Left", "Both"], group=group_vis_1)
lineStyle_1    = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group=group_vis_1)
showLabels_1   = input.bool(true, "Show Labels", group=group_vis_1)
showPrice_1    = input.bool(true, "Show price in labels", group=group_vis_1, tooltip="Include the level price beside its volume percentage, formatted to the symbol tick size.")
labelPrefix_1  = input.string("Vol:", "Label Text", group=group_vis_1)
transp_1       = input.int(50, "Transparency", minval=0, maxval=100, group=group_vis_1, tooltip="Adjust transparency for lines and labels (0 = Solid, 100 = Invisible).")

// Secondary Volume SR Levels
group_levels_2  = "Volume SR Levels"
lookbackBars_2  = input.int(300, "SR Lookback Bars", minval=20, maxval=5000, group=group_levels_2)
bins_2          = input.int(50, "Price Bins", minval=10, maxval=400, group=group_levels_2)
topLevels_2     = input.int(6, "Max SR Lines", minval=1, maxval=20, group=group_levels_2)
minVolumePct_2  = input.float(1.0, "Min Vol % Filter", step=0.1, group=group_levels_2)
lineTransp_2    = input.int(50, "Line Transparency", minval=0, maxval=100, group=group_levels_2)

// ✅ FIX: These two color inputs were missing — they are used in Script 2's drawing block
colStrong_2     = input.color(#26a69a, "SR Support Color", group=group_levels_2)
colWeak_2       = input.color(#f44336, "SR Resistance Color", group=group_levels_2)

// Integrated Box Inputs
boxPosition = input.string('Top Right', 'Box Position', options = ['Top Right', 'Top Left', 'Bottom Right', 'Bottom Left', 'Middle Right'])
boxSize = input.string('Normal', 'Box Size', options = ['Small', 'Normal', 'Large'])
lookbackPeriod = input.int(20, 'Lookback Period', minval = 5, maxval = 200)
vwapLength = input.int(20, 'VWAP Lookback (for Distance)', minval = 5, maxval = 500)
sensitivity = input.float(1.0, 'Shift Sensitivity', minval = 0.1, maxval = 3.0, step = 0.1)
neutralThreshold = input.float(0.5, 'Neutral Zone Threshold', minval = 0.1, maxval = 3.0, step = 0.1)
useEMA = input.bool(true, 'Use EMA instead of SMA')

// Component Weights
vwWeight = input.float(1.0, 'VWAP Weight', step = 0.1)
obvWeight = input.float(1.0, 'OBV Weight', step = 0.1)
adWeight = input.float(1.0, 'A/D Weight', step = 0.1)
volWeight = input.float(1.0, 'Volume Weight', step = 0.1)
momWeight = input.float(1.0, 'Momentum Weight', step = 0.1)

// Display Options
showStrength = input.bool(true, 'Show Shift Strength')
showVolume = input.bool(true, 'Show Volume vs Average')
showVWAP = input.bool(true, 'Show VWAP Distance')
showOBV = input.bool(true, 'Show OBV Trend')
showDuration = input.bool(true, 'Show Shift Duration')

// Colors
bullishColor = input.color(color.new(color.green, 10), 'Bullish Header Color')
bearishColor = input.color(color.new(color.red, 10), 'Bearish Header Color')
neutralColor = input.color(color.new(color.gray, 10), 'Neutral Header Color')

rowBull = color.new(color.green, 70)
rowBear = color.new(color.red, 70)
rowNeutral = color.new(color.gray, 80)

//────────────────────────────────────────────
// HELPER
//────────────────────────────────────────────
ma(src, len) =>
    useEMA ? ta.ema(src, len) : ta.sma(src, len)

//────────────────────────────────────────────
// DATA
//────────────────────────────────────────────

// Script 1 data
tf_1 = useHTF_1 ? htf_tf_1 : timeframe.period
[htf_h_1, htf_l_1, htf_c_1, htf_v_1] = request.security(syminfo.tickerid, tf_1, [high, low, close, volume])
globalMax_1 = ta.highest(htf_h_1, lookbackBars_1)
globalMin_1 = ta.lowest(htf_l_1, lookbackBars_1)
closeSource_1 = smoothLen_1 > 0 ? ta.sma(htf_c_1, smoothLen_1) : htf_c_1

// Script 2 data
[htf_h_2, htf_l_2, htf_c_2, htf_v_2] = request.security(syminfo.tickerid, timeframe.period, [high, low, close, volume])
globalMax_2 = ta.highest(htf_h_2, lookbackBars_2)
globalMin_2 = ta.lowest(htf_l_2, lookbackBars_2)

//────────────────────────────────────────────
// BOX LOGIC
//────────────────────────────────────────────

// VWAP
vwapValue = ta.vwap(close)
vwapDist = (close - vwapValue) / vwapValue * 100
vwapTrend = vwapValue > vwapValue[1]

// OBV
obvValue = ta.cum(math.sign(ta.change(close)) * volume)
obvAvg = ma(obvValue, lookbackPeriod)
obvTrend = obvValue > obvAvg
obvMomentum = ta.change(obvValue, 5)
obvMomentumPrev = ta.change(obvValue[1], 5)
obvAccelerating = math.abs(obvMomentum) > math.abs(obvMomentumPrev)

// Volume
avgVolume = ma(volume, lookbackPeriod)
volRatio = avgVolume != 0 ? (volume / avgVolume - 1) * 100 : 0.0
volumeTrend = volume > avgVolume

// A/D Line
adStep = high != low ? (close - low - (high - close)) / (high - low) * volume : 0.0
adValue = ta.cum(adStep)
adAvg = ma(adValue, lookbackPeriod)
adTrend = adValue > adAvg

// Momentum
priceMomentum = ta.change(close, lookbackPeriod)
priceStrength = close[lookbackPeriod] != 0 ? priceMomentum / close[lookbackPeriod] * 100 : 0.0
momentumUp = priceMomentum > 0

// Shift Calculation
bullScore = 0.0
bearScore = 0.0
bullScore += (vwapTrend ? vwWeight : 0)
bearScore += (not vwapTrend ? vwWeight : 0)
bullScore += (obvTrend ? obvWeight : 0)
bearScore += (not obvTrend ? obvWeight : 0)
bullScore += (adTrend ? adWeight : 0)
bearScore += (not adTrend ? adWeight : 0)
bullScore += (volumeTrend and close > open ? volWeight : 0)
bearScore += (volumeTrend and close < open ? volWeight : 0)
bullScore += (momentumUp and vwapDist > 0 ? momWeight : 0)
bearScore += (not momentumUp and vwapDist < 0 ? momWeight : 0)

shiftScore = (bullScore - bearScore) * sensitivity
isBullish = shiftScore > neutralThreshold
isBearish = shiftScore < -neutralThreshold
isNeutral = not isBullish and not isBearish
strength = math.min(100, math.abs(shiftScore) * 20)

// Shift Duration
var int shiftBars = 0
var int prevState = 0
currState = isBullish ? 1 : isBearish ? -1 : 0
if currState == prevState and currState != 0
    shiftBars += 1
else if currState != prevState and currState != 0
    shiftBars := 1
else if currState == 0
    shiftBars := 0
prevState := currState

//────────────────────────────────────────────
// OBJECT STORAGE
//────────────────────────────────────────────
var line[]  allLines_1  = array.new_line()
var label[] allLabels_1 = array.new_label()
var line[]  allLines_2  = array.new_line()
var label[] allLabels_2 = array.new_label()

//────────────────────────────────────────────
// DRAWING ON LAST BAR
//────────────────────────────────────────────
if barstate.islast
    // Cleanup script 1
    if array.size(allLines_1) > 0
        for i = 0 to array.size(allLines_1) - 1
            line.delete(array.get(allLines_1, i))
        array.clear(allLines_1)

    if array.size(allLabels_1) > 0
        for i = 0 to array.size(allLabels_1) - 1
            label.delete(array.get(allLabels_1, i))
        array.clear(allLabels_1)

    // Cleanup script 2
    if array.size(allLines_2) > 0
        for i = 0 to array.size(allLines_2) - 1
            line.delete(array.get(allLines_2, i))
        array.clear(allLines_2)

    if array.size(allLabels_2) > 0
        for i = 0 to array.size(allLabels_2) - 1
            label.delete(array.get(allLabels_2, i))
        array.clear(allLabels_2)

    //────────────────────────────────────────
    // SCRIPT 1: Adaptive Volume Concentration
    //────────────────────────────────────────
    priceRange_1 = globalMax_1 - globalMin_1
    binSize_1 = priceRange_1 > 0 ? priceRange_1 / bins_1 : syminfo.mintick

    if priceRange_1 > 0
        binVol_1 = array.new_float(bins_1, 0.0)
        totalVol_1 = 0.0
        actualLookback_1 = math.min(lookbackBars_1, bar_index + 1)

        for i = 0 to actualLookback_1 - 1
            p = closeSource_1[i]
            v = htf_v_1[i]
            if not na(p) and not na(v)
                idx = int(math.floor((p - globalMin_1) / binSize_1))
                idx := idx < 0 ? 0 : idx >= bins_1 ? bins_1 - 1 : idx
                array.set(binVol_1, idx, array.get(binVol_1, idx) + v)
                totalVol_1 += v

        nodes_1 = array.new<LevelNode>()
        for i = 0 to bins_1 - 1
            v = array.get(binVol_1, i)
            volPct = totalVol_1 > 0 ? (v / totalVol_1) * 100.0 : 0.0
            if volPct >= minVolumePct_1
                centerPrice = globalMin_1 + (i + 0.5) * binSize_1
                array.push(nodes_1, LevelNode.new(centerPrice, v))

        if array.size(nodes_1) > 1
            for i = 0 to array.size(nodes_1) - 2
                maxIdx = i
                for j = i + 1 to array.size(nodes_1) - 1
                    if array.get(nodes_1, j).vol > array.get(nodes_1, maxIdx).vol
                        maxIdx := j
                if maxIdx != i
                    temp = array.get(nodes_1, i)
                    array.set(nodes_1, i, array.get(nodes_1, maxIdx))
                    array.set(nodes_1, maxIdx, temp)

        finalPrices_1 = array.new_float()
        if array.size(nodes_1) > 0
            for i = 0 to array.size(nodes_1) - 1
                if array.size(finalPrices_1) >= topLevels_1
                    break

                currP = array.get(nodes_1, i).price
                isUnique_1 = true

                if array.size(finalPrices_1) > 0
                    for j = 0 to array.size(finalPrices_1) - 1
                        if math.abs(array.get(finalPrices_1, j) - currP) <= binSize_1
                            isUnique_1 := false
                            break

                if isUnique_1
                    array.push(finalPrices_1, currP)

        extStyle_1 = extendLines_1 == "Right" ? extend.right : extendLines_1 == "Left" ? extend.left : extendLines_1 == "Both" ? extend.both : extend.none
        lStyle_1   = lineStyle_1 == "Dashed" ? line.style_dashed : lineStyle_1 == "Dotted" ? line.style_dotted : line.style_solid

        if array.size(finalPrices_1) > 0
            for i = 0 to array.size(finalPrices_1) - 1
                price_1 = array.get(finalPrices_1, i)
                currentCol_1 = i == 0 ? colStrong_1 : i < math.ceil(topLevels_1 / 3.0) ? colMedium_1 : colWeak_1
                startBar_1 = bar_index - actualLookback_1 + 1

                ln1 = line.new(
                     x1=startBar_1,
                     y1=price_1,
                     x2=bar_index,
                     y2=price_1,
                     xloc=xloc.bar_index,
                     extend=extStyle_1,
                     color=color.new(currentCol_1, transp_1),
                     width=lineWidth_1,
                     style=lStyle_1)
                array.push(allLines_1, ln1)

                if showLabels_1
                    bIdx_1 = int(math.floor((price_1 - globalMin_1) / binSize_1))
                    bIdx_1 := bIdx_1 < 0 ? 0 : bIdx_1 >= bins_1 ? bins_1 - 1 : bIdx_1
                    pVal_1 = totalVol_1 > 0 ? (array.get(binVol_1, bIdx_1) / totalVol_1) * 100.0 : 0.0
                    txt_1 = (showPrice_1 ? str.tostring(price_1, format.mintick) + " | " : "") + labelPrefix_1 + " " + str.tostring(pVal_1, "#.#") + "%"

                    lb1 = label.new(
                         x=bar_index,
                         y=price_1,
                         text=txt_1,
                         xloc=xloc.bar_index,
                         yloc=yloc.price,
                         color=color.new(currentCol_1, transp_1),
                         style=label.style_label_left,
                         textcolor=color.white,
                         size=size.small)
                    array.push(allLabels_1, lb1)

    //────────────────────────────────────────
    // SCRIPT 2: Secondary Volume SR Levels
    //────────────────────────────────────────
    priceRange_2 = globalMax_2 - globalMin_2
    binSize_2 = priceRange_2 > 0 ? priceRange_2 / bins_2 : syminfo.mintick

    if priceRange_2 > 0
        binVol_2 = array.new_float(bins_2, 0.0)
        totalVol_2 = 0.0
        actualLookback_2 = math.min(lookbackBars_2, bar_index + 1)

        for i = 0 to actualLookback_2 - 1
            p = htf_c_2[i]
            v = htf_v_2[i]
            if not na(p) and not na(v)
                idx = int(math.floor((p - globalMin_2) / binSize_2))
                idx := idx < 0 ? 0 : idx >= bins_2 ? bins_2 - 1 : idx
                array.set(binVol_2, idx, array.get(binVol_2, idx) + v)
                totalVol_2 += v

        nodes_2 = array.new<LevelNode>()
        for i = 0 to bins_2 - 1
            v = array.get(binVol_2, i)
            pct = totalVol_2 > 0 ? (v / totalVol_2) * 100.0 : 0.0
            if pct >= minVolumePct_2
                array.push(nodes_2, LevelNode.new(globalMin_2 + (i + 0.5) * binSize_2, v))

        if array.size(nodes_2) > 1
            for i = 0 to array.size(nodes_2) - 2
                m = i
                for j = i + 1 to array.size(nodes_2) - 1
                    if array.get(nodes_2, j).vol > array.get(nodes_2, m).vol
                        m := j
                if m != i
                    temp = array.get(nodes_2, i)
                    array.set(nodes_2, i, array.get(nodes_2, m))
                    array.set(nodes_2, m, temp)

        drawn_2 = 0
        drawnPrices_2 = array.new_float()

        if array.size(nodes_2) > 0
            for i = 0 to array.size(nodes_2) - 1
                if drawn_2 >= topLevels_2
                    break

                p = array.get(nodes_2, i).price
                unique_2 = true

                if array.size(drawnPrices_2) > 0
                    for j = 0 to array.size(drawnPrices_2) - 1
                        if math.abs(array.get(drawnPrices_2, j) - p) <= binSize_2
                            unique_2 := false
                            break

                if unique_2
                    // ✅ FIX: colStrong_2 / colWeak_2 now resolve correctly
                    lCol = p > close ? colWeak_2 : colStrong_2
                    ln2 = line.new(
                         x1=bar_index - actualLookback_2 + 1,
                         y1=p,
                         x2=bar_index,
                         y2=p,
                         xloc=xloc.bar_index,
                         color=color.new(lCol, lineTransp_2),
                         width=2,
                         extend=extend.right)
                    array.push(allLines_2, ln2)
                    array.push(drawnPrices_2, p)
                    drawn_2 += 1

//────────────────────────────────────────────
// BUILD TABLE
//────────────────────────────────────────────

// ✅ FIX: cleaner table initialisation — avoids na-check pattern that can
//    misfire on replay/realtime bar transitions in Pine v6
var table infoBox = table.new(
     position.top_right, 2, 10,
     border_width = 2)

pos = boxPosition == 'Top Right' ? position.top_right : boxPosition == 'Top Left' ? position.top_left : boxPosition == 'Bottom Right' ? position.bottom_right : boxPosition == 'Bottom Left' ? position.bottom_left : position.middle_right

boxColor = isNeutral ? neutralColor : isBullish ? bullishColor : bearishColor
textColor = color.white
txtSize = boxSize == 'Small' ? size.small : boxSize == 'Large' ? size.large : size.normal
headerSize = boxSize == 'Small' ? size.normal : boxSize == 'Large' ? size.huge : size.large

table.clear(infoBox, 0, 0, 1, 9)

// Header
shiftText = isBullish ? 'BULLISH SHIFT ↑' : isBearish ? 'BEARISH SHIFT ↓' : 'NEUTRAL →'
table.cell(infoBox, 0, 0, shiftText, bgcolor = boxColor, text_color = textColor, text_size = headerSize, width = 20)
table.merge_cells(infoBox, 0, 0, 1, 0)

row = 1

// Strength
if showStrength
    strengthText = 'Strength: ' + str.tostring(math.round(strength, 1)) + '%'
    table.cell(infoBox, 0, row, strengthText, bgcolor = rowNeutral, text_color = textColor, text_size = txtSize)
    table.merge_cells(infoBox, 0, row, 1, row)
    row += 1

// Volume
if showVolume
    volRowColor = volumeTrend ? close > open ? rowBull : rowBear : rowNeutral
    volText = 'Vol vs Avg: ' + (volRatio > 0 ? '+' : '') + str.tostring(math.round(volRatio, 1)) + '%'
    table.cell(infoBox, 0, row, volText, bgcolor = volRowColor, text_color = textColor, text_size = txtSize)
    table.merge_cells(infoBox, 0, row, 1, row)
    row += 1

// VWAP
if showVWAP
    vwapRowColor = vwapTrend ? rowBull : rowBear
    vwapText = 'VWAP: ' + (vwapDist > 0 ? '+' : '') + str.tostring(math.round(vwapDist, 2)) + '% ' + (vwapTrend ? '↑' : '↓')
    table.cell(infoBox, 0, row, vwapText, bgcolor = vwapRowColor, text_color = textColor, text_size = txtSize)
    table.merge_cells(infoBox, 0, row, 1, row)
    row += 1

// Duration
if showDuration
    table.cell(infoBox, 0, row, 'Duration: ' + str.tostring(shiftBars) + ' bars', bgcolor = rowNeutral, text_color = textColor, text_size = txtSize)
    table.merge_cells(infoBox, 0, row, 1, row)
    row += 1

// OBV
if showOBV
    obvDirection = obvValue > obvValue[1]
    obvArrow = obvDirection and obvAccelerating ? '↑↑' : obvDirection ? '↑' : not obvDirection and obvAccelerating ? '↓↓' : '↓'
    obvStatusText = obvTrend ? 'Accumulating' : 'Distributing'
    obvRowColor = obvTrend ? rowBull : rowBear
    obvText = 'OBV: ' + obvStatusText + ' ' + obvArrow
    table.cell(infoBox, 0, row, obvText, bgcolor = obvRowColor, text_color = textColor, text_size = txtSize)
    table.merge_cells(infoBox, 0, row, 1, row)
    row += 1

//────────────────────────────────────────────
// DEBUG
//────────────────────────────────────────────
plot(shiftScore, 'Shift Score', display = display.none)
plot(strength, 'Strength', display = display.none)
````
