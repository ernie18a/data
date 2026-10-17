# Attique Golden Pocket Indicator

- url: https://www.tradingview.com/script/KMiDOjoq-Attique-Golden-Pocket-Indicator/
- type: indicator
- pine_id: PUB;46e142b3746948a4903364ebcaed687e
- version: 1.0

## Description

What this indicator does
Swing Fib draws a swing-based Fibonacci retracement grid on the price chart after the script decides there is a completed impulse leg between two anchored pivots. It is not a manual Fib tool: the anchors, direction (bull vs bear leg), and whether anything is drawn are all rule-based from pivot logic and a volatility filter.

The overlay includes:

A dashed blue line between the two swing anchors (the impulse leg).
Horizontal levels for a fixed set of retracement ratios (see below).
Optional Golden Pocket (GP) zone: two gold boundary lines (defaults 61.8% and 78.6% between the same anchors) and optional shading between them.
Optional retention of the previous fib when a new valid leg appears (prior leg is dimmed rather than deleted immediately).
How the anchors and “impulse” are defined
Pivots
The script uses TradingView’s standard pivothigh / pivotlow with configurable left and right bar counts:

Chart timeframe = Fib pivot timeframe (see next section): pivots use liqLeft / liqRight on the chart series.
Fib pivot timeframe higher than chart: pivots are read from the higher timeframe via request.security using fibPivotL / fibPivotR.
A pivot is only confirmed after right bars have printed to the right of the swing. Until then, the pivot can change or disappear on history as new bars form. That is normal pivot behavior, not a bug.

Bull vs bear leg (which fib you get)
Bullish fib leg: the script uses the most recently confirmed swing high and swing low such that the high pivot occurs after the low pivot in time, and high price > low price. Conceptually this is a push up from the swing low toward the swing high; retracements are measured back down from the high toward the low.
Bearish fib leg: the low pivot occurs after the high pivot, still with high price > low price (the swing high is the structural high of the leg). Conceptually a push down from the swing high toward the swing low; retracements are measured back up from the low toward the high.
ATR minimum range filter
Even if pivot structure qualifies, the fib does not draw unless the impulse range (high minus low of the anchored leg) is at least:

fibMinRangeAtrCh × ATR(atrLen)

This suppresses tiny, noisy swings. If the chart looks “empty,” lower fibMinRangeAtrCh slightly; if it is too busy, raise it.

How Fib prices are computed (important for reading the levels)
For both directions the math is anchored as:

0% = impulse high price, 100% = impulse low price

So the same formula maps ratios into the range between the two swing prices, with 0% at the top of the leg and 100% at the bottom. The BULLISH FIB vs BEARISH FIB title tells you which time ordering of pivots was used; the numeric labels still refer to that high → low retracement scale.

Standard levels drawn (labels match these ratios)
Between the anchored high and low, the script plots (from the high toward the low):

0%, 23.6%, 38.2%, 50%, 61.8%, 78.6%, 88.6%, then extension-style ratios −61.8%, −27.2%, −12.7%, and 100%.

You will also see two gold “GP” lines at the Golden Pocket inputs (defaults 61.8% and 78.6%). Because those defaults overlap the standard grid, you may see two lines near the same prices (one from the standard set, one from GP styling). That is intentional: GP is visually emphasized.

Chart timeframe vs higher-timeframe Fib
The script compares the chart period to fibAnchorTf using seconds, not fragile string matching.

Match (same duration as chart): anchors use xloc.bar_index (bar indices). The fib aligns exactly with how you see swings on that timeframe.
Higher fibAnchorTf than chart: anchors use higher-timeframe pivot prices and the pivot bar’s time on that HTF, and drawings use xloc.bar_time so the grid lines up in time on your lower chart.
Practical rule: If you want the fib to match what you see on the current chart swings, set fibAnchorTf = your chart timeframe. If you want a structure map from a slower TF (for example 15m or 1h swings on a 1m or 2m chart), set fibAnchorTf higher and accept that the leg definition is HTF pivot-based, not the same as every small chart swing.

Visual and UX options
Extend levels right: horizontal lines extend to the right by fibExtendBarsCh bars (and update as bar_index advances).
Level labels: optional text for each ratio; position Right, Left, or Middle along the span.
Prior fib: optional freeze + dim of the last fib when a new valid leg forms, useful for comparing previous vs current swing context.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Standalone swing Fib retracement — same levels/features as VWAP+LX Fib block (chart/HTF parity with v18+).
// Chart TF = Fib TF: bar_index anchors. Else: HTF pivots anchored with pivot bar *time* (xloc.bar_time) so drawings align to the chart.
// Levels (0% = impulse high, 100% = impulse low): 0%, 23.6%, 38.2%, 50%, 61.8%, 78.6%, 88.6%, −61.8%, −27.2%, −12.7%, 100%,
// plus Golden Pocket boundaries from inputs (default 61.8%–78.6%, drawn in gold as “GP”).

//@version=6
indicator(
     "Swing Fib (VWAP+LX parity)",
     shorttitle = "SwingFib",
     overlay = true,
     max_labels_count = 500,
     max_lines_count = 500,
     max_boxes_count = 120
 )

const string G_ATR = "Sizing"
const string G_ANCHOR = "Chart anchor pivots (when Fib TF = chart)"
const string G_GP = "Golden pocket (Fib lines)"
const string G_FIB = "Fib retracement (chart)"

atrLen = input.int(14, "ATR length (min impulse filter)", minval = 1, group = G_ATR, tooltip = "Same as VWAP+LX: impulse leg must span at least fibMinRangeAtrCh × this ATR.")

liqLeft = input.int(5, "Pivot left bars", minval = 1, maxval = 15, group = G_ANCHOR, tooltip = "When Fib pivot timeframe matches the chart, swing highs/lows use these widths — same as liquidity pivot inputs on VWAP+LX.")
liqRight = input.int(5, "Pivot right bars", minval = 1, maxval = 15, group = G_ANCHOR)

gpFibShallow = input.float(0.618, "Shallow retracement (from impulse extreme)", minval = 0.5, maxval = 0.79, step = 0.001, group = G_GP)
gpFibDeep = input.float(0.786, "Deep retracement (from impulse extreme)", minval = 0.51, maxval = 0.9, step = 0.001, group = G_GP)

showFibRetrace = input.bool(true, "Draw Fib on chart", group = G_FIB, tooltip = "Swing impulse legs from pivots; extends levels to the right each bar.")
fibAnchorTf = input.timeframe("5", "Fib pivot timeframe", group = G_FIB, tooltip = "Set to the same timeframe as the chart for bar-index anchors (script matches by seconds, not string). Any higher TF: pivots come from request.security; anchors use pivot bar time (xloc.bar_time).")
fibPivotL = input.int(5, "Fib pivot left bars (HTF)", minval = 1, maxval = 15, group = G_FIB, tooltip = "Used when Fib TF differs from chart (request.security pivots).")
fibPivotR = input.int(5, "Fib pivot right bars (HTF)", minval = 1, maxval = 15, group = G_FIB)
fibExtendBarsCh = input.int(40, "Extend levels right (bars)", minval = 10, maxval = 200, group = G_FIB)
fibMinRangeAtrCh = input.float(0.06, "Min impulse range (x ATR)", minval = 0.01, step = 0.01, group = G_FIB, tooltip = "Leg must span at least this multiple of ATR. Raise if too many small swings draw; lower if nothing appears.")
showFibLevelLabels = input.bool(true, "Level labels (% + GP)", group = G_FIB, tooltip = "Per-level tags. Golden pocket boundaries show as GP. Standard set: 0% … 100% plus extensions (see script header).")
fibLabelHoriz = input.string("Right", "Level labels: horizontal position", options = ["Right", "Left", "Middle"], group = G_FIB, tooltip = "Right = at extension edge (updates as levels extend). Left = at swing anchor side. Middle = centered between left anchor and current extension.")
showFibGpShade = input.bool(true, "Shade Golden Pocket zone", group = G_FIB, tooltip = "Between shallow and deep GP inputs.")
gpFibLineCol = input.color(color.rgb(255, 193, 7), "GP line / zone (golden)", group = G_FIB)
fibRetainPrior = input.bool(true, "Keep prior fib when leg changes", group = G_FIB, tooltip = "Freeze the last fib when a new impulse forms; prior is dimmed.")
fibPriorDim = input.int(58, "Prior fib dim (transparency)", minval = 0, maxval = 92, group = G_FIB, tooltip = "Higher = more faded vs the active fib.")

atr = ta.atr(atrLen)

// --- Chart pivots (same series as VWAP+LX Golden pocket when Fib TF = chart)
ph = ta.pivothigh(high, liqLeft, liqRight)
pl = ta.pivotlow(low, liqLeft, liqRight)

var float gpLastPH = na
var float gpLastPL = na
var int gpLastPHBar = na
var int gpLastPLBar = na

if not na(ph)
    gpLastPH := ph
    gpLastPHBar := bar_index - liqRight

if not na(pl)
    gpLastPL := pl
    gpLastPLBar := bar_index - liqRight

bullImpulseGp = not na(gpLastPH) and not na(gpLastPL) and gpLastPHBar > gpLastPLBar and gpLastPH > gpLastPL
bearImpulseGp = not na(gpLastPH) and not na(gpLastPL) and gpLastPLBar > gpLastPHBar and gpLastPH > gpLastPL

// --- Fib anchors: chart pivots when Fib TF = chart; else MTF pivots (price + pivot bar time on HTF)
// Four security calls (same TF) — avoids tuple/list syntax some compilers reject (CE10156 on "]").
vHtfPh = request.security(syminfo.tickerid, fibAnchorTf, ta.pivothigh(high, fibPivotL, fibPivotR), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
tHtfPh = request.security(syminfo.tickerid, fibAnchorTf, not na(ta.pivothigh(high, fibPivotL, fibPivotR)) ? time[fibPivotR] : na, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
vHtfPl = request.security(syminfo.tickerid, fibAnchorTf, ta.pivotlow(low, fibPivotL, fibPivotR), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
tHtfPl = request.security(syminfo.tickerid, fibAnchorTf, not na(ta.pivotlow(low, fibPivotL, fibPivotR)) ? time[fibPivotR] : na, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

fibIsChartTf = timeframe.in_seconds(timeframe.period) == timeframe.in_seconds(fibAnchorTf)

var float fibHtfPH = na
var float fibHtfPL = na
var int fibHtfPHTime = na
var int fibHtfPLTime = na

if not fibIsChartTf
    if not na(vHtfPh)
        fibHtfPH := vHtfPh
        fibHtfPHTime := tHtfPh
    if not na(vHtfPl)
        fibHtfPL := vHtfPl
        fibHtfPLTime := tHtfPl

fibPivotHi = fibIsChartTf ? gpLastPH : fibHtfPH
fibPivotLo = fibIsChartTf ? gpLastPL : fibHtfPL
fibPivotHiBar = fibIsChartTf ? gpLastPHBar : na
fibPivotLoBar = fibIsChartTf ? gpLastPLBar : na

bullImpulseFib = fibIsChartTf ? bullImpulseGp : not na(fibHtfPH) and not na(fibHtfPL) and not na(fibHtfPHTime) and not na(fibHtfPLTime) and fibHtfPHTime > fibHtfPLTime and fibHtfPH > fibHtfPL
bearImpulseFib = fibIsChartTf ? bearImpulseGp : not na(fibHtfPH) and not na(fibHtfPL) and not na(fibHtfPHTime) and not na(fibHtfPLTime) and fibHtfPLTime > fibHtfPHTime and fibHtfPH > fibHtfPL

// --- Fib math (0% = impulse high, 100% = impulse low). GP lines use Golden pocket inputs.
fibPriceAtCoeff(hiPrice, loPrice, coeff) =>
    rng = hiPrice - loPrice
    hiPrice - coeff * rng

var array<line> fibHLines = array.new_line()
var array<label> fibLvlLbls = array.new_label()
var line fibTrendLn = na
var label fibTitleLbl = na
var box fibGpBox = na
var string fibChartLastKey = ""

var array<line> fibPrevLines = array.new_line()
var array<label> fibPrevLbls = array.new_label()
var line fibPrevTrend = na
var label fibPrevTitle = na
var box fibPrevBox = na

var int fibSnapMidX = na
var int fibSnapMidT = na
var float fibSnapLblY = na

fibCoeffsStd = array.from(0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 0.886, -0.618, -0.272, -0.127, 1.0)
fibLblsStd = array.from("0%", "23.6%", "38.2%", "50%", "61.8%", "78.6%", "88.6%", "-61.8%", "-27.2%", "-12.7%", "100%")
fibColsStd = array.from(color.black, color.red, color.red, color.red, color.red, color.blue, color.green, color.red, color.blue, color.green, color.green)

fibRangeCh = fibPivotHi - fibPivotLo
fibRangeOkCh = not na(atr) and fibRangeCh >= fibMinRangeAtrCh * atr
fibBullLeg = showFibRetrace and bullImpulseFib and fibRangeOkCh
fibBearLeg = showFibRetrace and bearImpulseFib and fibRangeOkCh

fibShowChart = fibBullLeg or fibBearLeg

fibChartKey =
     not fibShowChart ? "" :
     fibIsChartTf ? str.tostring(fibPivotHiBar) + "|" + str.tostring(fibPivotLoBar) + "|" + str.tostring(fibPivotHi, format.mintick) + "|" + str.tostring(fibPivotLo, format.mintick) + "|" + (fibBullLeg ? "B" : "E") :
     str.tostring(fibHtfPHTime) + "|" + str.tostring(fibHtfPLTime) + "|" + str.tostring(fibPivotHi, format.mintick) + "|" + str.tostring(fibPivotLo, format.mintick) + "|" + (fibBullLeg ? "B" : "E")

fibLblGpS() =>
    "GP"
fibLblGpD() =>
    "GP"

if not fibShowChart
    if fibChartLastKey != ""
        while array.size(fibHLines) > 0
            line.delete(array.pop(fibHLines))
        while array.size(fibLvlLbls) > 0
            label.delete(array.pop(fibLvlLbls))
        if not na(fibTrendLn)
            line.delete(fibTrendLn)
            fibTrendLn := na
        if not na(fibTitleLbl)
            label.delete(fibTitleLbl)
            fibTitleLbl := na
        if not na(fibGpBox)
            box.delete(fibGpBox)
            fibGpBox := na
        while array.size(fibPrevLines) > 0
            line.delete(array.pop(fibPrevLines))
        while array.size(fibPrevLbls) > 0
            label.delete(array.pop(fibPrevLbls))
        if not na(fibPrevTrend)
            line.delete(fibPrevTrend)
            fibPrevTrend := na
        if not na(fibPrevTitle)
            label.delete(fibPrevTitle)
            fibPrevTitle := na
        if not na(fibPrevBox)
            box.delete(fibPrevBox)
            fibPrevBox := na
        fibChartLastKey := ""
else
    archMidX = fibSnapMidX
    archMidT = fibSnapMidT
    archLblY = fibSnapLblY

    hiF = fibPivotHi
    loF = fibPivotLo
    rngF = hiF - loF

    fibXloc = fibIsChartTf ? xloc.bar_index : xloc.bar_time
    chartBarMs = int(timeframe.in_seconds(timeframe.period) * 1000)
    fibLeftX = fibIsChartTf ? math.min(fibPivotLoBar, fibPivotHiBar) : math.min(fibHtfPLTime, fibHtfPHTime)
    fibRightX = fibIsChartTf ? (bar_index + fibExtendBarsCh) : (time_close + fibExtendBarsCh * chartBarMs)
    fibPriorX = fibIsChartTf ? math.max(0, bar_index - 1) : (bar_index > 0 ? time_close[1] : time_close)
    fibMidTitleX = int(math.round((fibLeftX + fibRightX) / 2.0))
    fibLblX = fibLabelHoriz == "Left" ? fibLeftX : fibLabelHoriz == "Middle" ? fibMidTitleX : fibRightX
    fibLvlLblStyle = fibLabelHoriz == "Left" ? label.style_label_right : fibLabelHoriz == "Middle" ? label.style_label_center : label.style_label_left
    fibLvlLblAlign = fibLabelHoriz == "Left" ? text.align_right : fibLabelHoriz == "Middle" ? text.align_center : text.align_left

    lblY = hiF + 0.618 * rngF
    fibTitleTxt =
         (fibBullLeg ? "BULLISH FIB" : "BEARISH FIB") + " · " + fibAnchorTf

    keyNew = fibChartKey != fibChartLastKey
    fibChartLastKey := fibChartKey

    haveActiveFib = array.size(fibHLines) > 0 or not na(fibTrendLn)

    if keyNew
        if fibRetainPrior and haveActiveFib
            while array.size(fibPrevLines) > 0
                line.delete(array.pop(fibPrevLines))
            while array.size(fibPrevLbls) > 0
                label.delete(array.pop(fibPrevLbls))
            if not na(fibPrevTrend)
                line.delete(fibPrevTrend)
                fibPrevTrend := na
            if not na(fibPrevTitle)
                label.delete(fibPrevTitle)
                fibPrevTitle := na
            if not na(fibPrevBox)
                box.delete(fibPrevBox)
                fibPrevBox := na

            while array.size(fibHLines) > 0
                lnMv = array.pop(fibHLines)
                line.set_x2(lnMv, fibPriorX)
                array.push(fibPrevLines, lnMv)
            while array.size(fibLvlLbls) > 0
                lbMv = array.pop(fibLvlLbls)
                lyMv = label.get_y(lbMv)
                label.set_xy(lbMv, fibPriorX, lyMv)
                array.push(fibPrevLbls, lbMv)
            if not na(fibTrendLn)
                line.set_x2(fibTrendLn, fibPriorX)
                fibPrevTrend := fibTrendLn
                fibTrendLn := na
            if not na(fibTitleLbl)
                txFr = fibIsChartTf ? (na(archMidX) ? fibMidTitleX : archMidX) : (na(archMidT) ? fibMidTitleX : archMidT)
                tyFr = na(archLblY) ? lblY : archLblY
                label.set_xy(fibTitleLbl, txFr, tyFr)
                fibPrevTitle := fibTitleLbl
                fibTitleLbl := na
            if not na(fibGpBox)
                box.set_right(fibGpBox, fibPriorX)
                fibPrevBox := fibGpBox
                fibGpBox := na

            nStdLines = array.size(fibCoeffsStd)
            szPr = array.size(fibPrevLines)
            for pi = 0 to szPr - 1
                lnP = array.get(fibPrevLines, pi)
                lnBase = pi < nStdLines ? array.get(fibColsStd, pi) : gpFibLineCol
                line.set_color(lnP, color.new(lnBase, fibPriorDim))
            if not na(fibPrevTrend)
                line.set_color(fibPrevTrend, color.new(color.blue, fibPriorDim))

            szLb = array.size(fibPrevLbls)
            if showFibLevelLabels
                for pi = 0 to szLb - 1
                    lbP = array.get(fibPrevLbls, pi)
                    if pi < nStdLines
                        label.set_textcolor(lbP, color.new(array.get(fibColsStd, pi), fibPriorDim))
                    else
                        label.set_textcolor(lbP, color.new(color.black, fibPriorDim))
                        label.set_color(lbP, color.new(gpFibLineCol, math.min(92, 78 + fibPriorDim)))
            else
                for pi = 0 to szLb - 1
                    lbP = array.get(fibPrevLbls, pi)
                    label.set_textcolor(lbP, color.new(color.black, fibPriorDim))
                    label.set_color(lbP, color.new(gpFibLineCol, math.min(92, 78 + fibPriorDim)))

            if not na(fibPrevTitle)
                label.set_color(fibPrevTitle, color.new(color.blue, math.min(92, 72 + fibPriorDim)))
                label.set_textcolor(fibPrevTitle, color.new(color.white, fibPriorDim))

            if not na(fibPrevBox)
                box.set_border_color(fibPrevBox, color.new(gpFibLineCol, math.min(92, 35 + fibPriorDim)))
                box.set_bgcolor(fibPrevBox, color.new(gpFibLineCol, math.min(96, 88 + fibPriorDim)))
        else
            while array.size(fibHLines) > 0
                line.delete(array.pop(fibHLines))
            while array.size(fibLvlLbls) > 0
                label.delete(array.pop(fibLvlLbls))
            if not na(fibTrendLn)
                line.delete(fibTrendLn)
                fibTrendLn := na
            if not na(fibTitleLbl)
                label.delete(fibTitleLbl)
                fibTitleLbl := na
            if not na(fibGpBox)
                box.delete(fibGpBox)
                fibGpBox := na

        trX1 = fibBullLeg ? (fibIsChartTf ? fibPivotLoBar : fibHtfPLTime) : (fibIsChartTf ? fibPivotHiBar : fibHtfPHTime)
        trY1 = fibBullLeg ? loF : hiF
        trX2 = fibBullLeg ? (fibIsChartTf ? fibPivotHiBar : fibHtfPHTime) : (fibIsChartTf ? fibPivotLoBar : fibHtfPLTime)
        trY2 = fibBullLeg ? hiF : loF

        fibTrendLn := line.new(trX1, trY1, trX2, trY2, xloc = fibXloc, color = color.new(color.blue, 0), width = 2, style = line.style_dashed)

        nStd = array.size(fibCoeffsStd)
        for fi = 0 to nStd - 1
            coeff = array.get(fibCoeffsStd, fi)
            col = array.get(fibColsStd, fi)
            yLvl = fibPriceAtCoeff(hiF, loF, coeff)
            lnH = line.new(fibLeftX, yLvl, fibRightX, yLvl, xloc = fibXloc, color = col, width = 2, style = line.style_solid)
            array.push(fibHLines, lnH)
            if showFibLevelLabels
                lbTxt = array.get(fibLblsStd, fi)
                lb = label.new(fibLblX, yLvl, lbTxt, xloc = fibXloc, yloc = yloc.price, style = fibLvlLblStyle, color = color(na), textcolor = col, size = size.small, textalign = fibLvlLblAlign)
                array.push(fibLvlLbls, lb)

        yGpS = fibPriceAtCoeff(hiF, loF, gpFibShallow)
        yGpD = fibPriceAtCoeff(hiF, loF, gpFibDeep)
        gpGold = gpFibLineCol
        gpDup = math.abs(gpFibShallow - gpFibDeep) < 0.00005

        lnGs = line.new(fibLeftX, yGpS, fibRightX, yGpS, xloc = fibXloc, color = gpGold, width = 3, style = line.style_solid)
        array.push(fibHLines, lnGs)
        if showFibLevelLabels
            lgS = label.new(fibLblX, yGpS, fibLblGpS(), xloc = fibXloc, yloc = yloc.price, style = fibLvlLblStyle, color = color.new(gpGold, 78), textcolor = color.black, size = size.small, textalign = fibLvlLblAlign)
            array.push(fibLvlLbls, lgS)

        if not gpDup
            lnGd = line.new(fibLeftX, yGpD, fibRightX, yGpD, xloc = fibXloc, color = gpGold, width = 3, style = line.style_solid)
            array.push(fibHLines, lnGd)
            if showFibLevelLabels
                lgD = label.new(fibLblX, yGpD, fibLblGpD(), xloc = fibXloc, yloc = yloc.price, style = fibLvlLblStyle, color = color.new(gpGold, 78), textcolor = color.black, size = size.small, textalign = fibLvlLblAlign)
                array.push(fibLvlLbls, lgD)

        if showFibGpShade and not gpDup
            gpTop = math.max(yGpS, yGpD)
            gpBot = math.min(yGpS, yGpD)
            fibGpBox := box.new(fibLeftX, gpTop, fibRightX, gpBot, xloc = fibXloc, border_color = color.new(gpGold, 35), bgcolor = color.new(gpGold, 88), border_width = 1, text = "GP", text_size = size.small, text_color = color.new(color.black, 0))

        fibTitleLbl :=
             label.new(fibMidTitleX, lblY, fibTitleTxt, xloc = fibXloc, yloc = yloc.price, style = label.style_label_down, color = color.new(color.blue, 75), textcolor = color.white, size = size.normal)
    else
        sz = array.size(fibHLines)
        for fi = 0 to sz - 1
            lnU = array.get(fibHLines, fi)
            line.set_x2(lnU, fibRightX)
        nlbl = array.size(fibLvlLbls)
        for fi = 0 to nlbl - 1
            lbU = array.get(fibLvlLbls, fi)
            ly = label.get_y(lbU)
            label.set_xy(lbU, fibLblX, ly)
        if not na(fibTitleLbl)
            label.set_xy(fibTitleLbl, fibMidTitleX, lblY)
        if not na(fibGpBox)
            box.set_right(fibGpBox, fibRightX)

    fibSnapMidX := fibIsChartTf ? fibMidTitleX : na
    fibSnapMidT := fibIsChartTf ? na : fibMidTitleX
    fibSnapLblY := lblY
````
