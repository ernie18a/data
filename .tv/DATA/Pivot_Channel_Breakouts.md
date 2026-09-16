<!-- tradingview-pine-id: PUB;11af3e760e1e4325a87ef1bb4bc4e498 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Pivot Channel Breakouts

Source: https://www.tradingview.com/script/sSdDbqIM/

## Description

█ OVERVIEW
Pivot Channel Breakouts is an adaptive market-structure indicator. It automatically builds a sloped channel from confirmed High and Low pivots, checks the geometry of the formation, and marks a breakout only when the close moves beyond the channel by a minimum ATR margin.
After a breakout the channel is moved into history, and an optional TP/SL module draws Entry, Stop Loss and up to three Risk:Reward targets. The indicator can be used both to read structure and to plan a potential trade after the breakout.

█ CONCEPTS
The indicator automatically detects pivots and builds the widest possible price channel that still contains all remaining points and candle closes. The goal is to recognize channel formations quickly without drawing the lines by hand.

Pivot-Based Channel Structure
The channel has two independent boundaries:
- Resistance — the upper line from High pivots.
- Support — the lower line from Low pivots.

The channel is drawn only when both sides of the buffer hold the required number of pivots. With the default setting that means at least two High pivots and two Low pivots. Until one side is incomplete, no formation is created.

Each boundary needs at least two pivots. With more points the indicator does not require collinearity. It searches pairs and keeps the pair with the greatest span, provided the remaining pivots and the candle closes stay on the correct side of the line. The first two pivots of the formation must be opposite — one High and one Low — so the channel starts from an alternating structure rather than two extremes of the same side. Envelope fit describes the price structure, not a perfect straight line through every point.

Pivot Detection
Pivot Left is the number of bars before the extreme, Pivot Right is the number of bars after it required for confirmation. Smaller values detect more local turns, larger values produce fewer and usually more significant pivots. A pivot is confirmed only after Pivot Right bars, so detection has a built-in delay.

Pivot Count
This parameter sets how many of the most recent High and Low pivots are kept in the buffer. A value of 2 builds a segment through two points on each side. Higher values increase selectivity: a line is created only when a pair meeting the structural rules can be found. The channel does not appear until both sides have collected the same required number of pivots.

Pivot Age and Channel Width
Max Pivot Age removes old points so a fresh pivot is not paired with a stale extreme. Minimum Channel Width rejects formations that are too short and accidental.

Dynamic Channel Adjustment
Until a confirmed breakout, a wick can bend the active boundary toward the new extreme. A temporary wick pierce does not end the channel. A breakout still requires a close beyond the line with an ATR margin.

ATR-Based Breakout and Close-Based Confirmation
A breakout is valid on the close only:
- above resistance + ATR × multiplier — long,
- below support − ATR × multiplier — short.

A wick alone does not generate a signal. The threshold scales with volatility: a higher multiplier cuts false breakouts, a lower one produces more signals.

Channel History and Pivot Reset
After a breakout the active channel is cut at the breakout bar and moved into history. Max Channels Shown limits how many old formations remain on the chart.
Reset Pivots on Breakout off: the next channel can form immediately from a mix of old and new pivots. On: both buffers are cleared and a completely new set of points must be collected.

TP/SL Framework
Each new breakout can draw:
- Entry — the close of the breakout candle,
- SL — ATR × multiplier or a fixed percent from entry,
- TP1 / TP2 / TP3 — targets as multiples of the Entry–SL distance (RR).

The layout moves with the chart and is closed when price hits SL or the farthest enabled TP.

█ FEATURES
General
- Max channels shown (history) — how many completed channels stay on the chart. Older ones are removed after the limit is exceeded.

Pivots
- Pivot Left / Pivot Right — sensitivity and confirmation delay of pivot detection.
- Pivots required to define a line — number of points in the buffer (2–6) on each side. The channel appears only after that many High pivots and that many Low pivots have been collected.
- Max pivot age (bars) — maximum age of a point.
- Minimum channel width (bars) — minimum length of the formation.
- Line extension to the right (bars) — visual extension of the lines to the right only; it does not affect detection.

Breakout
- ATR Period — ATR length used for the minimum breakout size.
- Minimum breakout size (x ATR), close only — required distance beyond the line on the close.
- Reset pivots on breakout — clears the buffers after a signal.

Appearance
- Resistance / Support Color — boundary colors.
- Trend line transparency — transparency of the channel lines.
- Channel fill color + Fill transparency — fill between the boundaries.
- Show breakout signals — triangles below/above the bar.
- Show dots on pivots — markers on every newly confirmed pivot.
- Dot color — resistance / support pivots.

TP/SL
- Show TP/SL Levels — enables the full layout.
- SL = ATR — SL from ATR or from a percentage.
- ATR Period (TP/SL) — separate ATR for the targets.
- ATR Multiplier for SL / SL % from Entry.
- RR for TP1 / TP2 / TP3.

TP/SL Display
- Show SL / TP1 / TP2 / TP3 Level — independent display of each level and its label.

█ APPLICATIONS
Channel Structure Analysis
Automatic drawing of sloped boundaries instead of connecting pivots by hand. Useful in trends, pullbacks and periods when price respects two parallel or near-parallel edges.

Breakout Confirmation
A triangle marks a close outside the channel with an ATR filter, not a mere line pierce. It is a starting point for further analysis of direction, momentum and context — not a standalone entry signal.

Risk/Reward Planning
After a breakout, Entry, SL and three targets are visible at once. SL can be based on volatility (ATR) or on a fixed percentage.

█ NOTES
- Larger Pivot Left/Right values mean slower, more selective detection.
- The signal is close-only; a wick can only bend the line.
- The breakout threshold scales with ATR.
- After a breakout the channel is archived; the pivot reset setting decides whether the next formation starts from scratch.
- TP/SL is visual R:R planning, not an assessment of trade quality.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Uncle_the_shooter

//@version=6
indicator('Pivot Channel Breakouts', overlay = true, max_lines_count = 500, max_labels_count = 500)

// INPUTS
maxChannelsShown = input.int(200, 'Max channels shown (history)', minval = 1, maxval = 249, group = 'General', tooltip = 'How many of the most recent breakout-completed channels remain drawn on the chart. Older ones are removed to stay within the line limit.')

// Pivots
left            = input.int(7, 'Pivot Left', group = 'Pivots', tooltip = 'Number of bars BEFORE a potential pivot that must have a lower high / higher low. A higher value means fewer, but more reliable, pivots.')
right           = input.int(7, 'Pivot Right', group = 'Pivots', tooltip = 'Number of bars AFTER a potential pivot that must have a lower high / higher low. A pivot is only confirmed after this many bars — this is an inherent detection delay.')
pivotCount      = input.int(2, 'Pivots required to define a line', minval = 2, maxval = 6, group = 'Pivots', tooltip = 'How many of the most recent high and low pivots are kept for building the lines. 2 = a segment through those two points. 3+ = an envelope: the pair with the greatest span is chosen, provided the remaining pivots and all closes lie on the correct side of the line. Pivots do not need to be collinear.')
maxPivotAge     = input.int(150, 'Max pivot age (bars) — older pivots are discarded', minval = 10, group = 'Pivots', tooltip = 'Pivots older than this many bars are removed from the array on every bar, regardless of whether a new pivot has appeared. This prevents pairing an old, stale point with a fresh pivot on the opposite side. The same value limits how many bars are checked when validating a line against closes.')
minChannelBars  = input.int(15, 'Minimum channel width (bars)', minval = 5, group = 'Pivots', tooltip = 'Minimum number of bars from the oldest pivot in the buffer (not necessarily the points the line actually passes through) to the current bar. Narrower formations are rejected as too short.')
extendBars      = input.int(15, 'Line extension to the right (bars)', minval = 1, group = 'Pivots', tooltip = 'How many bars into the future (to the right of the current bar) the resistance/support lines are drawn. Purely visual — has no effect on detection or breakouts.')

// Breakout
atrPeriod       = input.int(14, 'ATR Period', group = 'Breakout', tooltip = 'ATR period used to compute the minimum breakout size.')
minBreakoutATR  = input.float(0.0, 'Minimum breakout size (x ATR), close only', step = 0.05, minval = 0.0, group = 'Breakout', tooltip = 'Breakout is confirmed on close only: the close must move beyond the line by at least ATR × this value. Wicks alone do not trigger a signal, but if they pierce the line without a close-based breakout, the line is bent from its anchor toward that wick. A lower value means more frequent breakouts that are more prone to false signals.')
resetPivotsOnBreakout = input.bool(false, 'Reset pivots on breakout', group = 'Breakout', tooltip = 'Disabled (default): after a breakout the pivot arrays are kept — the next channel can form immediately from a mix of old and new points. Enabled: both arrays are cleared; a new channel must wait for a completely new set of pivots (less overlap between formations).')

// Appearance
resColor        = input.color(#ef5350, 'Resistance Color', group = 'Appearance')
supColor        = input.color(#26a69a, 'Support Color', group = 'Appearance')
lineTransp      = input.int(0, 'Trend line transparency (0-100)', minval = 0, maxval = 100, group = 'Appearance', tooltip = 'Transparency of the resistance/support lines (0 = fully opaque, 100 = invisible). Independent of the fill transparency.')
gradientColor   = input.color(#787b86, 'Channel fill color', group = 'Appearance', tooltip = 'A single, fixed fill color for the area between the channel lines, independent of its direction.')
fillTransp      = input.int(85, 'Fill transparency (0-100)', minval = 0, maxval = 100, group = 'Appearance')
showBreakSignals = input.bool(true, 'Show breakout signals (triangles)', group = 'Appearance')
showPivotMarkers = input.bool(false, 'Show dots on pivots used in the channel', group = 'Appearance', tooltip = 'Dots on every newly confirmed pivot (high/low), not only the ones that ultimately entered the current line pair.')
pivotMarkerColorRes = input.color(#ef5350, 'Dot color — resistance pivots', group = 'Appearance')
pivotMarkerColorSup = input.color(#26a69a, 'Dot color — support pivots', group = 'Appearance')

// TP/SL
showTargets     = input.bool(true, 'Show TP/SL Levels', group = 'TP/SL', tooltip = 'Draws Entry, Stop Loss and Take Profit levels for every new breakout signal.')
useAtrSL        = input.bool(true, 'SL = ATR', group = 'TP/SL', tooltip = 'When enabled, the Stop Loss distance from the entry price is calculated based on ATR (ATR Multiplier for SL).\nWhen disabled, a fixed percentage value is used (SL % from Entry).')
tpAtrPeriod     = input.int(14, 'ATR Period (TP/SL)', minval = 1, group = 'TP/SL', tooltip = 'ATR period used to determine the Stop Loss distance and the Take Profit levels. Independent from the Breakout ATR Period above.')
slAtrMult       = input.float(1.5, 'ATR Multiplier for SL', step = 0.1, group = 'TP/SL', tooltip = 'ATR multiplier determining the Stop Loss distance from the entry price, active when SL = ATR is enabled.')
slPercent       = input.float(1.0, 'SL % from Entry', step = 0.1, group = 'TP/SL', tooltip = 'Percentage distance of the Stop Loss from the entry price, used when SL = ATR is disabled.')
rrTP1           = input.float(1.0, 'RR for TP1', step = 0.1, group = 'TP/SL', tooltip = 'Risk:Reward ratio for Take Profit level 1. A value of 1.0 means TP1 sits at a distance equal to the risk (SL) from the entry price.')
rrTP2           = input.float(2.0, 'RR for TP2', step = 0.1, group = 'TP/SL', tooltip = 'Risk:Reward ratio for Take Profit level 2.')
rrTP3           = input.float(3.0, 'RR for TP3', step = 0.1, group = 'TP/SL', tooltip = 'Risk:Reward ratio for Take Profit level 3.')

// TP/SL Display
showSlLevel     = input.bool(true, 'Show SL Level', group = 'TP/SL Display', tooltip = 'Draws the Stop Loss line and label for the active signal.')
showTp1Level    = input.bool(true, 'Show TP1 Level', group = 'TP/SL Display', tooltip = 'Draws the Take Profit 1 line and label for the active signal.')
showTp2Level    = input.bool(true, 'Show TP2 Level', group = 'TP/SL Display', tooltip = 'Draws the Take Profit 2 line and label for the active signal.')
showTp3Level    = input.bool(true, 'Show TP3 Level', group = 'TP/SL Display', tooltip = 'Draws the Take Profit 3 line and label for the active signal.')

// HELPERS

lineHoldsAllBars(int startX, float slope, float intercept, bool upper, float tolerance) =>
    span = bar_index - startX
    bool ok = true
    if span >= 0
        checkSpan = math.min(span, maxPivotAge)
        for k = 0 to checkSpan
            idx = bar_index - k
            if idx >= startX
                lineY = slope * idx + intercept
                barVal = close[k]
                if upper and barVal > lineY + tolerance
                    ok := false
                if not upper and barVal < lineY - tolerance
                    ok := false
    ok

envelopeFit(array<float> xs, array<float> ys, bool upper) =>
    n = array.size(xs)
    float bestSlope = na
    float bestIntercept = na
    float bestSpan = -1.0
    int bestLocalStart = na
    float bestX1 = na
    float bestX2 = na
    tolerance = syminfo.mintick * 2
    for i = 0 to n - 2
        for j = i + 1 to n - 1
            x1 = array.get(xs, i)
            y1 = array.get(ys, i)
            x2 = array.get(xs, j)
            y2 = array.get(ys, j)
            dx = x2 - x1
            slope = dx != 0 ? (y2 - y1) / dx : 0.0
            intercept = y1 - slope * x1
            bool valid = true
            for k = 0 to n - 1
                if k != i and k != j
                    xk = array.get(xs, k)
                    yk = array.get(ys, k)
                    lineY = slope * xk + intercept
                    if upper and yk > lineY + 1e-8
                        valid := false
                    if not upper and yk < lineY - 1e-8
                        valid := false
            localStartX = int(math.min(x1, x2))
            if valid
                valid := lineHoldsAllBars(localStartX, slope, intercept, upper, tolerance)
            if valid
                span = math.abs(x2 - x1)
                if span > bestSpan
                    bestSpan := span
                    bestSlope := slope
                    bestIntercept := intercept
                    bestLocalStart := localStartX
                    bestX1 := x1
                    bestX2 := x2
    [bestSlope, bestIntercept, bestLocalStart, bestX1, bestX2]

pivotOrderValid(float rx1, float rx2, float sx1, float sx2) =>
    xs = array.from(rx1, rx2, sx1, sx2)
    isHigh = array.from(true, true, false, false)
    minIdx = 0
    for k = 1 to 3
        if array.get(xs, k) < array.get(xs, minIdx)
            minIdx := k
    secondIdx = -1
    float secondVal = na
    for k = 0 to 3
        if k != minIdx and (na(secondVal) or array.get(xs, k) < secondVal)
            secondVal := array.get(xs, k)
            secondIdx := k
    array.get(isHigh, minIdx) != array.get(isHigh, secondIdx)

// STATE
atr_val = ta.atr(atrPeriod)
atrTP   = ta.atr(tpAtrPeriod)

var array<float> hiX = array.new_float()
var array<float> hiY = array.new_float()
var array<float> loX = array.new_float()
var array<float> loY = array.new_float()

var float pSlopeRes = na
var float pInterceptRes = na
var float pSlopeSup = na
var float pInterceptSup = na

var float pRefStartRes = na
var float pRefStartSup = na
var float pAnchorYRes = na
var float pAnchorYSup = na
var bool  channelValid = false

var line  curResLine = na
var line  curSupLine = na
var linefill curFill = na

var array<line> histRes = array.new_line()
var array<line> histSup = array.new_line()
var array<linefill> histFill = array.new_linefill()

// TP/SL state
var int      tpslDir        = 0
var float    tpslSL         = na
var float    tpslExtreme    = na
var line     tpslEntryLn    = na
var label    tpslEntryLb    = na
var line     tpslSlLn       = na
var label    tpslSlLb       = na
var line     tpslTp1Ln      = na
var label    tpslTp1Lb      = na
var line     tpslTp2Ln      = na
var label    tpslTp2Lb      = na
var line     tpslTp3Ln      = na
var label    tpslTp3Lb      = na
var line     tpslExtLn      = na
var linefill tpslRiskFill   = na
var linefill tpslRewardFill = na
var int      tpslEntryBar   = na

cleanupHistory() =>
    if maxChannelsShown > 0 and array.size(histRes) > maxChannelsShown
        while array.size(histRes) > maxChannelsShown
            line.delete(array.shift(histRes))
            line.delete(array.shift(histSup))
            linefill.delete(array.shift(histFill))

// PIVOT CAPTURE
ph = ta.pivothigh(high, left, right)
pl = ta.pivotlow(low, left, right)

bool newHigh = false
bool newLow  = false

if not na(ph)
    array.push(hiX, float(bar_index - right))
    array.push(hiY, ph)
    if array.size(hiX) > pivotCount
        array.shift(hiX)
        array.shift(hiY)
    newHigh := true

if not na(pl)
    array.push(loX, float(bar_index - right))
    array.push(loY, pl)
    if array.size(loX) > pivotCount
        array.shift(loX)
        array.shift(loY)
    newLow := true

while array.size(hiX) > 0 and bar_index - array.get(hiX, 0) > maxPivotAge
    array.shift(hiX)
    array.shift(hiY)
while array.size(loX) > 0 and bar_index - array.get(loX, 0) > maxPivotAge
    array.shift(loX)
    array.shift(loY)

// BUILD CHANNEL (envelope / pivots only)
if newHigh or newLow
    if array.size(hiX) >= pivotCount and array.size(loX) >= pivotCount
        refStart = math.min(array.first(hiX), array.first(loX))
        channelBars = bar_index - refStart

        if channelBars >= minChannelBars
            [slopeRes, interceptRes, startRes, resX1, resX2] = envelopeFit(hiX, hiY, true)
            [slopeSup, interceptSup, startSup, supX1, supX2] = envelopeFit(loX, loY, false)

            if not na(slopeRes) and not na(slopeSup)
                commonStart = math.max(startRes, startSup)
                resAtCommon = slopeRes * commonStart + interceptRes
                supAtCommon = slopeSup * commonStart + interceptSup
                resAtNow    = slopeRes * bar_index + interceptRes
                supAtNow    = slopeSup * bar_index + interceptSup
                gapCommon = resAtCommon - supAtCommon
                gapNow    = resAtNow - supAtNow

                if gapCommon > 0 and gapNow > 0 and pivotOrderValid(resX1, resX2, supX1, supX2)
                    pSlopeRes := slopeRes
                    pInterceptRes := interceptRes
                    pSlopeSup := slopeSup
                    pInterceptSup := interceptSup
                    pRefStartRes := float(startRes)
                    pRefStartSup := float(startSup)
                    pAnchorYRes := slopeRes * startRes + interceptRes
                    pAnchorYSup := slopeSup * startSup + interceptSup
                    channelValid := true

// DRAW / UPDATE ACTIVE CHANNEL
bool breakUp = false
bool breakDown = false

if channelValid
    resNowPre = pSlopeRes * bar_index + pInterceptRes
    supNowPre = pSlopeSup * bar_index + pInterceptSup
    breakoutMargin = atr_val * minBreakoutATR

    if close > resNowPre + breakoutMargin
        breakUp := true
    else if close < supNowPre - breakoutMargin
        breakDown := true

    if not breakUp and not breakDown
        dxAnchorRes = bar_index - pRefStartRes
        dxAnchorSup = bar_index - pRefStartSup
        if dxAnchorRes > 0 and high > resNowPre
            pSlopeRes := (high - pAnchorYRes) / dxAnchorRes
            pInterceptRes := pAnchorYRes - pSlopeRes * pRefStartRes
        if dxAnchorSup > 0 and low < supNowPre
            pSlopeSup := (low - pAnchorYSup) / dxAnchorSup
            pInterceptSup := pAnchorYSup - pSlopeSup * pRefStartSup

    x1Res = int(pRefStartRes)
    x1Sup = int(pRefStartSup)
    y1res = pSlopeRes * pRefStartRes + pInterceptRes
    y1sup = pSlopeSup * pRefStartSup + pInterceptSup
    x2 = bar_index + extendBars
    y2res = pSlopeRes * x2 + pInterceptRes
    y2sup = pSlopeSup * x2 + pInterceptSup

    fillCol = color.new(gradientColor, fillTransp)

    if na(curResLine)
        curResLine := line.new(x1Res, y1res, x2, y2res, color = color.new(resColor, lineTransp), width = 2)
        curSupLine := line.new(x1Sup, y1sup, x2, y2sup, color = color.new(supColor, lineTransp), width = 2)
        curFill := linefill.new(curResLine, curSupLine, fillCol)
    else
        line.set_xy1(curResLine, x1Res, y1res)
        line.set_xy2(curResLine, x2, y2res)
        line.set_xy1(curSupLine, x1Sup, y1sup)
        line.set_xy2(curSupLine, x2, y2sup)

    if breakUp or breakDown
        line.set_xy2(curResLine, bar_index, resNowPre)
        line.set_xy2(curSupLine, bar_index, supNowPre)
        array.push(histRes, curResLine)
        array.push(histSup, curSupLine)
        array.push(histFill, curFill)
        cleanupHistory()

        curResLine := na
        curSupLine := na
        curFill := na
        channelValid := false

        if resetPivotsOnBreakout
            array.clear(hiX)
            array.clear(hiY)
            array.clear(loX)
            array.clear(loY)

// TP/SL — STATE AND DRAWING
// Colors follow the resistance/support scheme: bullish (breakUp) uses the support color, bearish (breakDown) uses the resistance color,
// matching the breakout triangle colors below.
if showTargets and (breakUp or breakDown)
    bool isBuyTrade = breakUp

    line.delete(tpslEntryLn)
    label.delete(tpslEntryLb)
    line.delete(tpslSlLn)
    label.delete(tpslSlLb)
    line.delete(tpslTp1Ln)
    label.delete(tpslTp1Lb)
    line.delete(tpslTp2Ln)
    label.delete(tpslTp2Lb)
    line.delete(tpslTp3Ln)
    label.delete(tpslTp3Lb)
    line.delete(tpslExtLn)
    linefill.delete(tpslRiskFill)
    linefill.delete(tpslRewardFill)

    tpslDir      := isBuyTrade ? 1 : -1
    tpslEntryBar := bar_index

    float entryP   = close
    float riskDist = useAtrSL ? atrTP * slAtrMult : entryP * (slPercent / 100.0)

    // Entry, SL, TP1-3 lines/labels: transparency 40
    // Gradient fills (risk/reward fill): transparency 80
    color entryCol    = color.new(isBuyTrade ? supColor : resColor, 40)
    color slCol       = color.new(isBuyTrade ? resColor : supColor, 40)
    color tpCol       = color.new(isBuyTrade ? supColor : resColor, 40)
    color riskFillC   = color.new(isBuyTrade ? resColor : supColor, 80)
    color rewardFillC = color.new(isBuyTrade ? supColor : resColor, 80)

    float slP  = isBuyTrade ? entryP - riskDist : entryP + riskDist
    float tp1P = isBuyTrade ? entryP + riskDist * rrTP1 : entryP - riskDist * rrTP1
    float tp2P = isBuyTrade ? entryP + riskDist * rrTP2 : entryP - riskDist * rrTP2
    float tp3P = isBuyTrade ? entryP + riskDist * rrTP3 : entryP - riskDist * rrTP3

    tpslSL      := slP
    tpslExtreme := showTp3Level ? tp3P : showTp2Level ? tp2P : showTp1Level ? tp1P : na

    tpslEntryLn := line.new(bar_index, entryP, bar_index + 1, entryP,
         color = entryCol, width = 2, extend = extend.none)
    tpslEntryLb := label.new(bar_index, entryP,
         (isBuyTrade ? 'BUY ' : 'SELL ') + str.tostring(entryP, format.mintick),
         style = label.style_label_left, color = entryCol,
         textcolor = color.white, size = size.small)

    if showSlLevel
        tpslSlLn := line.new(bar_index, slP, bar_index + 1, slP,
             color = slCol, width = 1, style = line.style_dashed, extend = extend.none)
        tpslSlLb := label.new(bar_index, slP,
             'SL ' + str.tostring(slP, format.mintick),
             style = label.style_label_left, color = slCol,
             textcolor = color.white, size = size.small)

    if showTp1Level
        tpslTp1Ln := line.new(bar_index, tp1P, bar_index + 1, tp1P,
             color = tpCol, width = 1, extend = extend.none)
        tpslTp1Lb := label.new(bar_index, tp1P,
             'TP1 ' + str.tostring(tp1P, format.mintick),
             style = label.style_label_left, color = tpCol,
             textcolor = color.white, size = size.small)

    if showTp2Level
        tpslTp2Ln := line.new(bar_index, tp2P, bar_index + 1, tp2P,
             color = tpCol, width = 1, extend = extend.none)
        tpslTp2Lb := label.new(bar_index, tp2P,
             'TP2 ' + str.tostring(tp2P, format.mintick),
             style = label.style_label_left, color = tpCol,
             textcolor = color.white, size = size.small)

    if showTp3Level
        tpslTp3Ln := line.new(bar_index, tp3P, bar_index + 1, tp3P,
             color = tpCol, width = 1, style = line.style_dotted, extend = extend.none)
        tpslTp3Lb := label.new(bar_index, tp3P,
             'TP3 ' + str.tostring(tp3P, format.mintick),
             style = label.style_label_left, color = tpCol,
             textcolor = color.white, size = size.small)

    if showSlLevel
        tpslRiskFill := linefill.new(tpslEntryLn, tpslSlLn, riskFillC)

    float fillExtreme = entryP
    if isBuyTrade
        if showTp1Level
            fillExtreme := math.max(fillExtreme, tp1P)
        if showTp2Level
            fillExtreme := math.max(fillExtreme, tp2P)
        if showTp3Level
            fillExtreme := math.max(fillExtreme, tp3P)
        if fillExtreme > entryP
            tpslExtLn      := line.new(bar_index, fillExtreme, bar_index + 1, fillExtreme, color = na, extend = extend.none)
            tpslRewardFill := linefill.new(tpslEntryLn, tpslExtLn, rewardFillC)
    else
        if showTp1Level
            fillExtreme := math.min(fillExtreme, tp1P)
        if showTp2Level
            fillExtreme := math.min(fillExtreme, tp2P)
        if showTp3Level
            fillExtreme := math.min(fillExtreme, tp3P)
        if fillExtreme < entryP
            tpslExtLn      := line.new(bar_index, fillExtreme, bar_index + 1, fillExtreme, color = na, extend = extend.none)
            tpslRewardFill := linefill.new(tpslEntryLn, tpslExtLn, rewardFillC)

// TP/SL — updating line/label positions and detecting SL/TP hits
if tpslDir != 0
    if not na(tpslEntryLb)
        label.set_x(tpslEntryLb, bar_index)
    if not na(tpslSlLb)
        label.set_x(tpslSlLb, bar_index)
    if not na(tpslTp1Lb)
        label.set_x(tpslTp1Lb, bar_index)
    if not na(tpslTp2Lb)
        label.set_x(tpslTp2Lb, bar_index)
    if not na(tpslTp3Lb)
        label.set_x(tpslTp3Lb, bar_index)

    if not na(tpslEntryLn)
        line.set_x2(tpslEntryLn, bar_index + 1)
    if not na(tpslSlLn)
        line.set_x2(tpslSlLn, bar_index + 1)
    if not na(tpslTp1Ln)
        line.set_x2(tpslTp1Ln, bar_index + 1)
    if not na(tpslTp2Ln)
        line.set_x2(tpslTp2Ln, bar_index + 1)
    if not na(tpslTp3Ln)
        line.set_x2(tpslTp3Ln, bar_index + 1)
    if not na(tpslExtLn)
        line.set_x2(tpslExtLn, bar_index + 1)

    bool slHit = tpslDir == 1 ? low <= tpslSL : high >= tpslSL
    bool tpHit = not na(tpslExtreme) and
         (tpslDir == 1 ? high >= tpslExtreme : low <= tpslExtreme)

    if bar_index > tpslEntryBar and (slHit or tpHit)
        if not na(tpslEntryLn)
            line.set_x2(tpslEntryLn, bar_index)
        if not na(tpslSlLn)
            line.set_x2(tpslSlLn, bar_index)
        if not na(tpslTp1Ln)
            line.set_x2(tpslTp1Ln, bar_index)
        if not na(tpslTp2Ln)
            line.set_x2(tpslTp2Ln, bar_index)
        if not na(tpslTp3Ln)
            line.set_x2(tpslTp3Ln, bar_index)
        if not na(tpslExtLn)
            line.set_x2(tpslExtLn, bar_index)
        tpslDir := 0

// SIGNALS
plotshape(showBreakSignals and breakUp,   style = shape.triangleup,   location = location.belowbar, color = supColor, size = size.tiny)
plotshape(showBreakSignals and breakDown, style = shape.triangledown, location = location.abovebar, color = resColor, size = size.tiny)

plotshape(showPivotMarkers and not na(ph), style = shape.circle, location = location.abovebar, color = pivotMarkerColorRes, size = size.tiny, offset = -right)
plotshape(showPivotMarkers and not na(pl), style = shape.circle, location = location.belowbar, color = pivotMarkerColorSup, size = size.tiny, offset = -right)

plot(breakUp   ? 1 : na, "bt_buy_score",  display = display.none)
plot(breakDown ? 1 : na, "bt_sell_score", display = display.none)

// ALERTS
alertcondition(breakUp,   title = 'Channel breakout up',        message = 'Pivot Channel: breakout UP — {{ticker}} {{interval}} @ {{close}}')
alertcondition(breakDown, title = 'Channel breakout down',      message = 'Pivot Channel: breakout DOWN — {{ticker}} {{interval}} @ {{close}}')
alertcondition(breakUp or breakDown, title = 'Channel breakout (up or down)', message = 'Pivot Channel: breakout — {{ticker}} {{interval}} @ {{close}}')
````
