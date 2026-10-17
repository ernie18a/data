# Dynamic Take Profit Stop Loss

- url: https://www.tradingview.com/script/ACLZpj5Q-Dynamic-Take-Profit-Stop-Loss/
- type: indicator
- pine_id: PUB;ea710055fb0f4e3cb1515cbb26b9fd4a
- version: 1.0

## Description

Dynamic Take Profit Stop Loss

Dynamic Take Profit Stop Loss is designed to move beyond static take profit levels by dynamically adapting profit projections to changing market conditions.

Instead of relying on fixed R:R targets or ATR values alone, this indicator uses an internal Efficiency Engine to measure how effectively price is moving and adjusts projected targets accordingly.

As market efficiency strengthens, targets can expand. As efficiency weakens or deteriorates, targets can tighten to help preserve gains and reduce exposure.

Key Features

• Adaptive TP projections based on market efficiency
• SL-based R:R projection mode
• ATR-based projection mode
• Dynamic TP expansion and contraction logic
• Automatic Optimal TP selection (TP1 / TP2 / TP3)
• Local High / Low stop-loss calculation with adjustable buffers
• Optional manual entry price input
• Multiple TP display combinations:

TP1 Only
TP2 Only
TP3 Only
Optimal Only
TP + Optimal combinations
Multi-TP combinations
Show All

• Long and Short trade projections
• Dynamic TP multiplier engine
• Efficiency state analysis:

Improving
Mixed
Worsening

• Live information table showing:

Efficiency Score
Market State
TP Multiplier
Optimal TP
Long SL Distance
Short SL Distance

• Adjustable colors, table placement, text sizing, labels, and projection length

How It Works

The internal Efficiency Engine analyzes recent price behavior by comparing:

• Net directional movement
• Total movement path traveled
• Historical improvement or deterioration in efficiency

A weighted score is generated and translated into a dynamic TP multiplier.

Typical behavior:

Strong efficiency + improving conditions
→ Expand targets

Neutral conditions
→ Hold targets

Weakening efficiency
→ Tighten targets

Weak and deteriorating conditions
→ Exit or reduce exposure

Example Use

A standard 2R target may become:

Strong conditions:
2R → 3R+

Weak conditions:
2R → 1.2R–1.5R

The goal is to align profit expectations with how price is actually behaving instead of assuming all trades deserve identical targets.

Best Used For

• Trend continuation trading
• Breakout strategies
• Intraday trading
• Swing trading
• Futures
• Forex
• Indices
• Crypto
• Stocks

About TrendGenY Indicators

[i]TrendGenY indicators are built from market experience, creative concepts, and a constant pursuit of unique perspectives. Rather than following conventional ideas, the focus is on uncovering alternative insights and viewing market behavior through different angles to reveal information that traditional tools may overlook and help traders build a more meaningful edge in the market.[/i]

## Source Code

````pine
//@version=5
indicator("TrendGenY Dynamic Take Profit Stop Loss", shorttitle="TGY Adaptive TP v2.2", overlay=true, max_lines_count=100, max_labels_count=100)

//====================================================
// Inputs
//====================================================
grpCore = "Core"
calcTF        = input.timeframe("", "Calculation Timeframe", group=grpCore)
waitClose     = input.bool(true, "Wait Until Bar Close", group=grpCore)

grpMode = "Projection Mode"
projectionMode = input.string("SL R:R", "TP Projection Type", options=["SL R:R", "ATR"], group=grpMode)
tradeSide      = input.string("Both", "Trade Side", options=["Both", "Long Only", "Short Only"], group=grpMode)
useManualEntry = input.bool(false, "Use Manual Entry Price", group=grpMode)
manualEntry    = input.float(0.0, "Manual Entry Price", step=0.01, group=grpMode)

grpSL = "Local High/Low Stop Logic"
lookback      = input.int(20, "Local High/Low Lookback", minval=2, group=grpSL)
bufferMode    = input.string("Ticks", "Buffer Mode", options=["None", "Ticks", "ATR", "Percent"], group=grpSL)
bufferTicks   = input.int(5, "Buffer Ticks", minval=0, group=grpSL)
slAtrLen      = input.int(14, "SL ATR Length", minval=1, group=grpSL)
slAtrMult     = input.float(0.25, "SL ATR Multiplier", minval=0.0, step=0.05, group=grpSL)
percentBuffer = input.float(0.10, "Percent Buffer", minval=0.0, step=0.01, group=grpSL)

grpRR = "R:R Targets"
rr1 = input.float(1.0, "TP1 R:R", minval=0.1, step=0.25, group=grpRR)
rr2 = input.float(1.5, "TP2 R:R", minval=0.1, step=0.25, group=grpRR)
rr3 = input.float(2.0, "TP3 R:R", minval=0.1, step=0.25, group=grpRR)

grpOptimal = "Optimal TP"
optimalTPMode = input.string("Auto", "Optimal TP Selection", options=["Auto", "TP1", "TP2", "TP3"], group=grpOptimal)

grpATR = "ATR Alternative"
atrLen  = input.int(14, "ATR Length", minval=1, group=grpATR)
atrTP1  = input.float(0.75, "ATR TP1", step=0.25, group=grpATR)
atrTP2  = input.float(1.25, "ATR TP2", step=0.25, group=grpATR)
atrTP3  = input.float(2.00, "ATR TP3", step=0.25, group=grpATR)

grpEff = "Efficiency Engine"
segmentLen    = input.int(20, "Segment Length", minval=5, group=grpEff)
segmentCount  = input.int(3, "Lookback Segments", minval=2, maxval=5, group=grpEff)
compWeight    = input.float(0.70, "Composite Weight", minval=0.0, maxval=1.0, step=0.05, group=grpEff)
improveWeight = input.float(0.30, "Improvement Weight", minval=0.0, maxval=1.0, step=0.05, group=grpEff)

grpDynamic = "Dynamic TP Adjustment"
lowScore      = input.float(40.0, "Low Score", minval=0, maxval=100, group=grpDynamic)
highScore     = input.float(80.0, "High Score", minval=0, maxval=100, group=grpDynamic)
minMult       = input.float(0.50, "Minimum TP Multiplier", step=0.05, group=grpDynamic)
maxMult       = input.float(1.75, "Maximum TP Multiplier", step=0.05, group=grpDynamic)
improveBoost  = input.float(0.20, "Improving Boost", step=0.05, group=grpDynamic)
worsenPenalty = input.float(0.25, "Worsening Penalty", step=0.05, group=grpDynamic)

grpFilter = "Invalid Projection Filter"
hideInvalidSides = input.bool(true, "Hide Invalid Side", group=grpFilter)
minDistanceTicks = input.int(5, "Minimum TP Distance From Entry In Ticks", minval=0, group=grpFilter)

grpDisplay = "Display"
showTable  = input.bool(true, "Show Table", group=grpDisplay)
showLines  = input.bool(true, "Show TP/SL Lines", group=grpDisplay)
showLabels = input.bool(true, "Show Labels", group=grpDisplay)
lineBars   = input.int(50, "Projection Bars", minval=5, group=grpDisplay)

tpDisplayMode = input.string("All", "TP Display Mode", options=["All", "TP1 Only", "TP2 Only", "TP3 Only", "Optimal Only", "TP1 + Optimal", "TP2 + Optimal", "TP3 + Optimal", "TP1 + TP2", "TP1 + TP3", "TP2 + TP3"], group=grpDisplay)

tblPosIn   = input.string("Top Right", "Table Location", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=grpDisplay)
tblSizeIn  = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal", "Large"], group=grpDisplay)

grpColors = "Colors"
longTPColor      = input.color(color.lime, "Long TP Color", group=grpColors)
shortTPColor     = input.color(color.orange, "Short TP Color", group=grpColors)
longSLColor      = input.color(color.red, "Long SL Color", group=grpColors)
shortSLColor     = input.color(color.fuchsia, "Short SL Color", group=grpColors)
optimalTPColor   = input.color(color.aqua, "Optimal TP Highlight Color", group=grpColors)
labelTextColor   = input.color(color.white, "Label Text Color", group=grpColors)

//====================================================
// Helpers
//====================================================
tfToUse = calcTF == "" ? timeframe.period : calcTF
lookaheadMode = waitClose ? barmerge.lookahead_off : barmerge.lookahead_on

clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))

fmt(v) =>
    na(v) ? "na" : str.tostring(v, format.mintick)

fmt2(v) =>
    na(v) ? "na" : str.tostring(v, "#.##")

fmtTicks(v) =>
    na(v) ? "na" : str.tostring(v / syminfo.mintick, "#.##")

tblPos =
     tblPosIn == "Top Left" ? position.top_left :
     tblPosIn == "Top Center" ? position.top_center :
     tblPosIn == "Top Right" ? position.top_right :
     tblPosIn == "Middle Left" ? position.middle_left :
     tblPosIn == "Middle Center" ? position.middle_center :
     tblPosIn == "Middle Right" ? position.middle_right :
     tblPosIn == "Bottom Left" ? position.bottom_left :
     tblPosIn == "Bottom Center" ? position.bottom_center :
     position.bottom_right

tblSize =
     tblSizeIn == "Tiny" ? size.tiny :
     tblSizeIn == "Small" ? size.small :
     tblSizeIn == "Normal" ? size.normal :
     size.large

deleteLine(l) =>
    if not na(l)
        line.delete(l)

deleteLabel(lb) =>
    if not na(lb)
        label.delete(lb)

//====================================================
// Data
//====================================================
src    = request.security(syminfo.tickerid, tfToUse, close, barmerge.gaps_off, lookaheadMode)
tfLow  = request.security(syminfo.tickerid, tfToUse, ta.lowest(low, lookback), barmerge.gaps_off, lookaheadMode)
tfHigh = request.security(syminfo.tickerid, tfToUse, ta.highest(high, lookback), barmerge.gaps_off, lookaheadMode)
tfATR  = request.security(syminfo.tickerid, tfToUse, ta.atr(slAtrLen), barmerge.gaps_off, lookaheadMode)
atr    = request.security(syminfo.tickerid, tfToUse, ta.atr(atrLen), barmerge.gaps_off, lookaheadMode)

bufferValue(_price) =>
    bufferMode == "None" ? 0.0 :
     bufferMode == "Ticks" ? bufferTicks * syminfo.mintick :
     bufferMode == "ATR" ? tfATR * slAtrMult :
     _price * (percentBuffer / 100.0)

longSL = tfLow - bufferValue(tfLow)
shortSL = tfHigh + bufferValue(tfHigh)

//====================================================
// Efficiency Engine
//====================================================
segmentEfficiency(_src, segLen, segNumber) =>
    startOffset = (segNumber - 1) * segLen
    float path = 0.0
    bool valid = true

    if na(_src[startOffset]) or na(_src[startOffset + segLen])
        valid := false

    for i = 0 to segLen - 1
        step = math.abs(_src[startOffset + i] - _src[startOffset + i + 1])
        if na(step)
            valid := false
        else
            path += step

    netMove = math.abs(_src[startOffset] - _src[startOffset + segLen])
    valid and path != 0 ? netMove / path : na

compositeEfficiency(s1, s2, s3, s4, s5, segCount) =>
    w1 = segCount >= 1 and not na(s1) ? segCount : 0
    w2 = segCount >= 2 and not na(s2) ? segCount - 1 : 0
    w3 = segCount >= 3 and not na(s3) ? segCount - 2 : 0
    w4 = segCount >= 4 and not na(s4) ? segCount - 3 : 0
    w5 = segCount >= 5 and not na(s5) ? segCount - 4 : 0
    weightSum = w1 + w2 + w3 + w4 + w5
    weighted = nz(s1) * w1 + nz(s2) * w2 + nz(s3) * w3 + nz(s4) * w4 + nz(s5) * w5
    weightSum > 0 ? weighted / weightSum : na

improvementScore(s1, s2, s3, s4, s5, segCount) =>
    d1 = segCount >= 2 and not na(s1) and not na(s2) ? s1 - s2 : na
    d2 = segCount >= 3 and not na(s2) and not na(s3) ? s2 - s3 : na
    d3 = segCount >= 4 and not na(s3) and not na(s4) ? s3 - s4 : na
    d4 = segCount >= 5 and not na(s4) and not na(s5) ? s4 - s5 : na

    pairs = (not na(d1) ? 1 : 0) + (not na(d2) ? 1 : 0) + (not na(d3) ? 1 : 0) + (not na(d4) ? 1 : 0)
    avgDiff = pairs > 0 ? (nz(d1) + nz(d2) + nz(d3) + nz(d4)) / pairs : na

    improving =
         (segCount == 2 and not na(d1) and d1 > 0) or
         (segCount == 3 and not na(d1) and not na(d2) and d1 > 0 and d2 > 0) or
         (segCount == 4 and not na(d1) and not na(d2) and not na(d3) and d1 > 0 and d2 > 0 and d3 > 0) or
         (segCount == 5 and not na(d1) and not na(d2) and not na(d3) and not na(d4) and d1 > 0 and d2 > 0 and d3 > 0 and d4 > 0)

    worsening =
         (segCount == 2 and not na(d1) and d1 < 0) or
         (segCount == 3 and not na(d1) and not na(d2) and d1 < 0 and d2 < 0) or
         (segCount == 4 and not na(d1) and not na(d2) and not na(d3) and d1 < 0 and d2 < 0 and d3 < 0) or
         (segCount == 5 and not na(d1) and not na(d2) and not na(d3) and not na(d4) and d1 < 0 and d2 < 0 and d3 < 0 and d4 < 0)

    normImprove = not na(avgDiff) ? clamp((avgDiff + 1.0) / 2.0, 0.0, 1.0) : na
    state = improving ? "Improving" : worsening ? "Worsening" : "Mixed"

    [normImprove, state]

finalScore(comp, normImprove, cw, iw) =>
    totalW = cw + iw
    totalW > 0 and not na(comp) and not na(normImprove) ? 100 * ((comp * cw + normImprove * iw) / totalW) : na

s1 = segmentEfficiency(src, segmentLen, 1)
s2 = segmentEfficiency(src, segmentLen, 2)
s3 = segmentEfficiency(src, segmentLen, 3)
s4 = segmentEfficiency(src, segmentLen, 4)
s5 = segmentEfficiency(src, segmentLen, 5)

comp = compositeEfficiency(s1, s2, s3, s4, s5, segmentCount)
[imp, state] = improvementScore(s1, s2, s3, s4, s5, segmentCount)
score = finalScore(comp, imp, compWeight, improveWeight)

//====================================================
// Dynamic Multiplier
//====================================================
scoreNorm = na(score) ? na : clamp((score - lowScore) / math.max(highScore - lowScore, 1), 0.0, 1.0)
rawMult = na(scoreNorm) ? na : minMult + scoreNorm * (maxMult - minMult)

stateAdj =
     state == "Improving" ? improveBoost :
     state == "Worsening" ? -worsenPenalty :
     0.0

dynMult = na(rawMult) ? na : clamp(rawMult + stateAdj, minMult, maxMult)

//====================================================
// TP Logic
//====================================================
anchor = useManualEntry and manualEntry > 0 ? manualEntry : close
minDist = minDistanceTicks * syminfo.mintick

longRiskRaw = anchor - longSL
shortRiskRaw = shortSL - anchor

longRisk = longRiskRaw > minDist ? longRiskRaw : na
shortRisk = shortRiskRaw > minDist ? shortRiskRaw : na

useRR = projectionMode == "SL R:R"

longTP1 = useRR ? anchor + longRisk * rr1 * dynMult : anchor + atr * atrTP1 * dynMult
longTP2 = useRR ? anchor + longRisk * rr2 * dynMult : anchor + atr * atrTP2 * dynMult
longTP3 = useRR ? anchor + longRisk * rr3 * dynMult : anchor + atr * atrTP3 * dynMult

shortTP1 = useRR ? anchor - shortRisk * rr1 * dynMult : anchor - atr * atrTP1 * dynMult
shortTP2 = useRR ? anchor - shortRisk * rr2 * dynMult : anchor - atr * atrTP2 * dynMult
shortTP3 = useRR ? anchor - shortRisk * rr3 * dynMult : anchor - atr * atrTP3 * dynMult

longValid =
     not hideInvalidSides or
     not na(longRisk) and longSL < anchor and longTP1 > anchor + minDist and longTP2 > anchor + minDist and longTP3 > anchor + minDist

shortValid =
     not hideInvalidSides or
     not na(shortRisk) and shortSL > anchor and shortTP1 < anchor - minDist and shortTP2 < anchor - minDist and shortTP3 < anchor - minDist

showLong = (tradeSide == "Both" or tradeSide == "Long Only") and longValid
showShort = (tradeSide == "Both" or tradeSide == "Short Only") and shortValid

autoOptimal =
     state == "Improving" and score >= highScore ? "TP3" :
     state == "Worsening" or score < lowScore ? "TP1" :
     "TP2"

optimalTP = optimalTPMode == "Auto" ? autoOptimal : optimalTPMode

isOptimal(tpName) =>
    optimalTP == tpName

showTP(tpName) =>
    tpDisplayMode == "All" or
     tpDisplayMode == tpName + " Only" or
     tpDisplayMode == "Optimal Only" and isOptimal(tpName) or
     tpDisplayMode == "TP1 + Optimal" and (tpName == "TP1" or isOptimal(tpName)) or
     tpDisplayMode == "TP2 + Optimal" and (tpName == "TP2" or isOptimal(tpName)) or
     tpDisplayMode == "TP3 + Optimal" and (tpName == "TP3" or isOptimal(tpName)) or
     tpDisplayMode == "TP1 + TP2" and (tpName == "TP1" or tpName == "TP2") or
     tpDisplayMode == "TP1 + TP3" and (tpName == "TP1" or tpName == "TP3") or
     tpDisplayMode == "TP2 + TP3" and (tpName == "TP2" or tpName == "TP3")

//====================================================
// Lines + Labels
//====================================================
var line lLongSL = na
var line lShortSL = na
var line lLong1 = na
var line lLong2 = na
var line lLong3 = na
var line lShort1 = na
var line lShort2 = na
var line lShort3 = na

var label labLongSL = na
var label labShortSL = na
var label labLong1 = na
var label labLong2 = na
var label labLong3 = na
var label labShort1 = na
var label labShort2 = na
var label labShort3 = na

makeOrUpdateLine(l, y, col, w) =>
    line result = l
    if na(result)
        result := line.new(bar_index, y, bar_index + lineBars, y, xloc=xloc.bar_index, extend=extend.none, color=col, width=w)
    else
        line.set_xy1(result, bar_index, y)
        line.set_xy2(result, bar_index + lineBars, y)
        line.set_color(result, col)
        line.set_width(result, w)
    result

makeOrUpdateLabel(lb, y, txt, col) =>
    label result = lb
    if na(result)
        result := label.new(bar_index + lineBars, y, txt, style=label.style_label_left, color=col, textcolor=labelTextColor)
    else
        label.set_x(result, bar_index + lineBars)
        label.set_y(result, y)
        label.set_text(result, txt)
        label.set_color(result, col)
        label.set_textcolor(result, labelTextColor)
    result

if barstate.islast
    if not showLong
        deleteLine(lLongSL), deleteLine(lLong1), deleteLine(lLong2), deleteLine(lLong3)
        deleteLabel(labLongSL), deleteLabel(labLong1), deleteLabel(labLong2), deleteLabel(labLong3)
        lLongSL := na, lLong1 := na, lLong2 := na, lLong3 := na
        labLongSL := na, labLong1 := na, labLong2 := na, labLong3 := na

    if not showShort
        deleteLine(lShortSL), deleteLine(lShort1), deleteLine(lShort2), deleteLine(lShort3)
        deleteLabel(labShortSL), deleteLabel(labShort1), deleteLabel(labShort2), deleteLabel(labShort3)
        lShortSL := na, lShort1 := na, lShort2 := na, lShort3 := na
        labShortSL := na, labShort1 := na, labShort2 := na, labShort3 := na

    if showLines and not na(dynMult)
        if showLong
            lLongSL := makeOrUpdateLine(lLongSL, longSL, longSLColor, 2)

            if showTP("TP1")
                lLong1 := makeOrUpdateLine(lLong1, longTP1, isOptimal("TP1") ? optimalTPColor : longTPColor, isOptimal("TP1") ? 4 : 2)
                if showLabels
                    labLong1 := makeOrUpdateLabel(labLong1, longTP1, (isOptimal("TP1") ? "OPTIMAL " : "") + "Long TP1: " + fmt(longTP1), isOptimal("TP1") ? optimalTPColor : longTPColor)
            else
                deleteLine(lLong1), deleteLabel(labLong1), lLong1 := na, labLong1 := na

            if showTP("TP2")
                lLong2 := makeOrUpdateLine(lLong2, longTP2, isOptimal("TP2") ? optimalTPColor : color.new(longTPColor, 20), isOptimal("TP2") ? 4 : 2)
                if showLabels
                    labLong2 := makeOrUpdateLabel(labLong2, longTP2, (isOptimal("TP2") ? "OPTIMAL " : "") + "Long TP2: " + fmt(longTP2), isOptimal("TP2") ? optimalTPColor : longTPColor)
            else
                deleteLine(lLong2), deleteLabel(labLong2), lLong2 := na, labLong2 := na

            if showTP("TP3")
                lLong3 := makeOrUpdateLine(lLong3, longTP3, isOptimal("TP3") ? optimalTPColor : color.new(longTPColor, 40), isOptimal("TP3") ? 4 : 2)
                if showLabels
                    labLong3 := makeOrUpdateLabel(labLong3, longTP3, (isOptimal("TP3") ? "OPTIMAL " : "") + "Long TP3: " + fmt(longTP3), isOptimal("TP3") ? optimalTPColor : longTPColor)
            else
                deleteLine(lLong3), deleteLabel(labLong3), lLong3 := na, labLong3 := na

            if showLabels
                labLongSL := makeOrUpdateLabel(labLongSL, longSL, "Long SL: " + fmt(longSL), longSLColor)

        if showShort
            lShortSL := makeOrUpdateLine(lShortSL, shortSL, shortSLColor, 2)

            if showTP("TP1")
                lShort1 := makeOrUpdateLine(lShort1, shortTP1, isOptimal("TP1") ? optimalTPColor : shortTPColor, isOptimal("TP1") ? 4 : 2)
                if showLabels
                    labShort1 := makeOrUpdateLabel(labShort1, shortTP1, (isOptimal("TP1") ? "OPTIMAL " : "") + "Short TP1: " + fmt(shortTP1), isOptimal("TP1") ? optimalTPColor : shortTPColor)
            else
                deleteLine(lShort1), deleteLabel(labShort1), lShort1 := na, labShort1 := na

            if showTP("TP2")
                lShort2 := makeOrUpdateLine(lShort2, shortTP2, isOptimal("TP2") ? optimalTPColor : color.new(shortTPColor, 20), isOptimal("TP2") ? 4 : 2)
                if showLabels
                    labShort2 := makeOrUpdateLabel(labShort2, shortTP2, (isOptimal("TP2") ? "OPTIMAL " : "") + "Short TP2: " + fmt(shortTP2), isOptimal("TP2") ? optimalTPColor : shortTPColor)
            else
                deleteLine(lShort2), deleteLabel(labShort2), lShort2 := na, labShort2 := na

            if showTP("TP3")
                lShort3 := makeOrUpdateLine(lShort3, shortTP3, isOptimal("TP3") ? optimalTPColor : color.new(shortTPColor, 40), isOptimal("TP3") ? 4 : 2)
                if showLabels
                    labShort3 := makeOrUpdateLabel(labShort3, shortTP3, (isOptimal("TP3") ? "OPTIMAL " : "") + "Short TP3: " + fmt(shortTP3), isOptimal("TP3") ? optimalTPColor : shortTPColor)
            else
                deleteLine(lShort3), deleteLabel(labShort3), lShort3 := na, labShort3 := na

            if showLabels
                labShortSL := makeOrUpdateLabel(labShortSL, shortSL, "Short SL: " + fmt(shortSL), shortSLColor)

//====================================================
// Table
//====================================================
scoreColor =
     na(score) ? color.gray :
     score >= highScore ? color.lime :
     score >= lowScore ? color.orange :
     color.red

stateColor =
     state == "Improving" ? color.lime :
     state == "Mixed" ? color.yellow :
     state == "Worsening" ? color.red :
     color.gray

var table t = table.new(tblPos, 2, 7)

if barstate.islast
    table.clear(t, 0, 0, 1, 6)

    if showTable
        table.cell(t, 0, 0, "Mode", text_color=color.white, bgcolor=color.black, text_size=tblSize)
        table.cell(t, 1, 0, projectionMode, text_color=color.white, bgcolor=color.new(color.blue, 0), text_size=tblSize)

        table.cell(t, 0, 1, "Efficiency", text_color=color.white, bgcolor=color.black, text_size=tblSize)
        table.cell(t, 1, 1, fmt2(score), text_color=color.black, bgcolor=scoreColor, text_size=tblSize)

        table.cell(t, 0, 2, "State", text_color=color.white, bgcolor=color.black, text_size=tblSize)
        table.cell(t, 1, 2, state, text_color=color.black, bgcolor=stateColor, text_size=tblSize)

        table.cell(t, 0, 3, "TP Mult", text_color=color.white, bgcolor=color.black, text_size=tblSize)
        table.cell(t, 1, 3, fmt2(dynMult) + "x", text_color=color.white, bgcolor=color.new(color.blue, 20), text_size=tblSize)

        table.cell(t, 0, 4, "Optimal TP", text_color=color.white, bgcolor=color.black, text_size=tblSize)
        table.cell(t, 1, 4, optimalTP, text_color=color.black, bgcolor=optimalTPColor, text_size=tblSize)

        table.cell(t, 0, 5, "Long SL Ticks/Pips", text_color=color.white, bgcolor=color.black, text_size=tblSize)
        table.cell(t, 1, 5, fmtTicks(longRisk), text_color=color.white, bgcolor=color.new(color.gray, 50), text_size=tblSize)

        table.cell(t, 0, 6, "Short SL Ticks/Pips", text_color=color.white, bgcolor=color.black, text_size=tblSize)
        table.cell(t, 1, 6, fmtTicks(shortRisk), text_color=color.white, bgcolor=color.new(color.gray, 50), text_size=tblSize)

//====================================================
// Alerts
//====================================================
alertcondition(state == "Improving" and score >= highScore, "Expand TP", "Efficiency is strong and improving. Consider expanding TP.")
alertcondition(state == "Worsening", "Tighten TP", "Efficiency is worsening. Consider tightening TP.")
alertcondition(state == "Worsening" and score < lowScore, "Exit Warning", "Efficiency is weak and worsening. Consider partial or full exit.")
alertcondition(showLong and close < longSL, "Long SL Broken", "Price broke below Local Low SL.")
alertcondition(showShort and close > shortSL, "Short SL Broken", "Price broke above Local High SL.")
````
