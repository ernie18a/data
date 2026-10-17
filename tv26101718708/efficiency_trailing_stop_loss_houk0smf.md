# Efficiency Trailing Stop Loss

- url: https://www.tradingview.com/script/HoUk0SMF-Efficiency-Trailing-Stop-Loss/
- type: indicator
- pine_id: PUB;5387837e27ac4a949137733012b536c0
- version: 3.0

## Description

Efficiency TSL is an adaptive trailing stop framework designed to dynamically follow market movement while continuously adjusting stop behavior based on changing price efficiency and directional conditions.

Unlike traditional trailing stop systems that rely on static ATR values or fixed structure levels, Flip TSL evaluates how effectively price is moving and uses that information to expand, tighten, or aggressively reduce risk as market behavior evolves.

The objective is not simply to trail price, but to adapt risk management according to changing market conditions beneath the surface.

By combining market efficiency analysis, directional state detection, adaptive stop expansion logic, and automatic long/short transition behavior into a unified framework, the indicator is designed to provide additional context for trade management and evolving market structure.

Features

• Single adaptive trailing stop line
• Automatic Long ↔ Short transition system
• Dynamic stop expansion and tightening engine
• Market efficiency analysis
• Improvement / deterioration detection
• Automatic direction logic modes:

• Stop Cross
• SMA Direction
• Candle Direction

• Structure Step stop logic
• Swing High / Low fallback logic
• Multi-timeframe calculations
• Adjustable timeframe selection
• Wait-until-close confirmation option
• Dynamic ATR stop sizing
• Real-time dashboard
• Fully customizable colors and display settings

Dashboard Includes

• Current direction mode
• Auto direction method
• Efficiency score
• Market state
• Stop mode
• Active ATR multiplier
• Current trailing stop value

Alerts Included

• Flipped Long
• Flipped Short
• Efficiency crossed below threshold
• Long Mode Activated
• Short Mode Activated

Potential Use Cases

• Dynamically manage open positions
• Adapt stop placement to changing conditions
• Reduce risk during deteriorating environments
• Hold stronger trends longer
• Filter lower-quality market conditions
• Add confluence to existing systems
• Study changing market behavior

Interpretation

Expanded

Market efficiency is elevated and conditions remain supportive of directional continuation.

The trailing stop expands and provides additional room for price movement.

Tightening

Market conditions begin slowing or losing efficiency.

The trailing stop contracts and moves closer to price action.

Cut / Take Profit

Market efficiency falls beneath the defined threshold.

The stop may aggressively tighten or move toward current price to reduce exposure and protect gains.

Direction Modes

Stop Cross
Direction flips when price crosses the active trailing stop.

SMA Direction
Direction follows price relative to moving average positioning.

Candle Direction
Direction adapts based on bullish and bearish candle behavior.

About TrendGenY Indicators

[i]TrendGenY indicators are built from market experience, creative concepts, and a constant pursuit of unique perspectives. Rather than following conventional ideas, the focus is on uncovering alternative insights and viewing market behavior through different angles to reveal information that traditional tools may overlook and help traders build a more meaningful edge in the market.[/i]

## Source Code

````pine
//@version=5
indicator("TrendGenY Efficiency Trailing Stop", shorttitle="TGY Efficiency TSL", overlay=true)

//====================================================
// Inputs
//====================================================
grpCore = "Core"
calcTF    = input.timeframe("", "Calculation Timeframe", group=grpCore)
waitClose = input.bool(true, "Wait Until Bar Close", group=grpCore)
startSide = input.string("Auto", "Starting Side", options=["Auto", "Long", "Short"], group=grpCore)
autoDirectionMode = input.string("SMA Direction", "Auto Direction Mode", options=["Stop Cross", "SMA Direction", "Candle Direction"], group=grpCore)

grpTSL = "Trailing Stop Logic"
useKivancBase = input.bool(true, "Use Structure Step Logic", group=grpTSL)
lookback      = input.int(10, "Fallback Local High/Low Lookback", minval=2, group=grpTSL)
allowLoosen   = input.bool(true, "Allow Stop To Loosen / Expand Away From Price", group=grpTSL)

grpBuffer = "Stop Expansion / Tightening"
atrLen        = input.int(14, "ATR Length", minval=1, group=grpBuffer)
expandedATR   = input.float(1.25, "Expanded Stop ATR Multiplier", minval=0.0, step=0.05, group=grpBuffer)
normalATR     = input.float(1.00, "Normal Stop ATR Multiplier", minval=0.0, step=0.05, group=grpBuffer)
tightATR      = input.float(0.25, "Tight Stop ATR Multiplier", minval=0.0, step=0.05, group=grpBuffer)
cutOnLowCross = input.bool(true, "Cut / Take Profit On Low Threshold Cross", group=grpBuffer)
invertEfficiencyBehavior = input.bool(false, "Invert Efficiency Behavior", group=grpBuffer)

grpEff = "Efficiency Engine"
segmentLen    = input.int(20, "Segment Length", minval=5, group=grpEff)
segmentCount  = input.int(3, "Lookback Segments", minval=2, maxval=5, group=grpEff)
compWeight    = input.float(0.40, "Composite Weight", minval=0.0, maxval=1.0, step=0.05, group=grpEff)
improveWeight = input.float(0.60, "Improvement Weight", minval=0.0, maxval=1.0, step=0.05, group=grpEff)

grpThresh = "Efficiency Thresholds"
lowScore  = input.float(35.0, "Low Efficiency Threshold", minval=0, maxval=100, group=grpThresh)
highScore = input.float(45.0, "High Efficiency Threshold", minval=0, maxval=100, group=grpThresh)

grpDisplay = "Display"
showTable = input.bool(true, "Show Table", group=grpDisplay)
tblPosIn  = input.string("Top Right", "Table Location", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=grpDisplay)
tblSizeIn = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal", "Large"], group=grpDisplay)

grpColors = "Colors"
longColor    = input.color(color.lime, "Long Mode Color", group=grpColors)
shortColor   = input.color(color.fuchsia, "Short Mode Color", group=grpColors)
cutColor     = input.color(color.rgb(140, 20, 20), "Cut / TP Color", group=grpColors)
expandColor  = input.color(color.rgb(0, 255, 0), "Expanded State Color", group=grpColors)
tightenColor = input.color(color.orange, "Tightening State Color", group=grpColors)
tableText    = input.color(color.white, "Table Text Color", group=grpColors)

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

//====================================================
// Timeframe Data
//====================================================
tfClose = request.security(syminfo.tickerid, tfToUse, close, barmerge.gaps_off, lookaheadMode)
tfOpen  = request.security(syminfo.tickerid, tfToUse, open, barmerge.gaps_off, lookaheadMode)
tfLow   = request.security(syminfo.tickerid, tfToUse, low, barmerge.gaps_off, lookaheadMode)
tfHigh  = request.security(syminfo.tickerid, tfToUse, high, barmerge.gaps_off, lookaheadMode)
tfATR   = request.security(syminfo.tickerid, tfToUse, ta.atr(atrLen), barmerge.gaps_off, lookaheadMode)
tfSMA   = request.security(syminfo.tickerid, tfToUse, ta.sma(close, lookback), barmerge.gaps_off, lookaheadMode)

structureStepLongBase  = request.security(syminfo.tickerid, tfToUse, ta.valuewhen(low > low[1], low[1], 1), barmerge.gaps_off, lookaheadMode)
structureStepShortBase = request.security(syminfo.tickerid, tfToUse, ta.valuewhen(high < high[1], high[1], 1), barmerge.gaps_off, lookaheadMode)

fallbackLongBase  = request.security(syminfo.tickerid, tfToUse, ta.lowest(low, lookback), barmerge.gaps_off, lookaheadMode)
fallbackShortBase = request.security(syminfo.tickerid, tfToUse, ta.highest(high, lookback), barmerge.gaps_off, lookaheadMode)

longBase  = useKivancBase ? structureStepLongBase : fallbackLongBase
shortBase = useKivancBase ? structureStepShortBase : fallbackShortBase

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

s1 = segmentEfficiency(tfClose, segmentLen, 1)
s2 = segmentEfficiency(tfClose, segmentLen, 2)
s3 = segmentEfficiency(tfClose, segmentLen, 3)
s4 = segmentEfficiency(tfClose, segmentLen, 4)
s5 = segmentEfficiency(tfClose, segmentLen, 5)

comp = compositeEfficiency(s1, s2, s3, s4, s5, segmentCount)
[imp, state] = improvementScore(s1, s2, s3, s4, s5, segmentCount)
score = finalScore(comp, imp, compWeight, improveWeight)

//====================================================
// Stop Behavior
//====================================================
aboveHigh = score >= highScore
betweenHighLow = score < highScore and score >= lowScore
belowLow = score < lowScore
crossBelowLow = ta.crossunder(score, lowScore)

stopMode =
     invertEfficiencyBehavior ?
     (
         aboveHigh ? "Tightening" :
         betweenHighLow ? "Normal" :
         belowLow ? "Expanded" :
         "Neutral"
     ) :
     (
         aboveHigh ? "Expanded" :
         betweenHighLow ? "Tightening" :
         belowLow ? "Cut / TP" :
         "Neutral"
     )

atrMult =
     invertEfficiencyBehavior ?
     (
         aboveHigh ? tightATR :
         betweenHighLow ? normalATR :
         belowLow ? expandedATR :
         normalATR
     ) :
     (
         aboveHigh ? expandedATR :
         betweenHighLow ? tightATR :
         belowLow ? 0.0 :
         normalATR
     )

rawLongStop =
     cutOnLowCross and crossBelowLow and not invertEfficiencyBehavior ? tfClose :
     belowLow and not invertEfficiencyBehavior ? tfClose :
     longBase - tfATR * atrMult

rawShortStop =
     cutOnLowCross and crossBelowLow and not invertEfficiencyBehavior ? tfClose :
     belowLow and not invertEfficiencyBehavior ? tfClose :
     shortBase + tfATR * atrMult

//====================================================
// Single Line Direction Logic
//====================================================
var int direction = 0
var float tsl = na

autoDirection =
     autoDirectionMode == "SMA Direction" ? (tfClose >= tfSMA ? 1 : -1) :
     autoDirectionMode == "Candle Direction" ? (tfClose >= tfOpen ? 1 : -1) :
     direction

if direction == 0
    direction :=
         startSide == "Long" ? 1 :
         startSide == "Short" ? -1 :
         autoDirectionMode == "Stop Cross" ? (tfClose >= tfSMA ? 1 : -1) :
         autoDirection

if startSide == "Auto" and autoDirectionMode != "Stop Cross"
    direction := autoDirection

if autoDirectionMode == "Stop Cross"
    if direction == 1 and not na(tsl) and tfClose < tsl
        direction := -1
        tsl := rawShortStop

    if direction == -1 and not na(tsl) and tfClose > tsl
        direction := 1
        tsl := rawLongStop

if direction == 1
    newLongTSL = rawLongStop
    tsl := na(tsl) or direction[1] != 1 ? newLongTSL : allowLoosen ? newLongTSL : math.max(tsl, newLongTSL)

if direction == -1
    newShortTSL = rawShortStop
    tsl := na(tsl) or direction[1] != -1 ? newShortTSL : allowLoosen ? newShortTSL : math.min(tsl, newShortTSL)

//====================================================
// Plot
//====================================================
activeColor =
     stopMode == "Expanded" ? expandColor :
     stopMode == "Tightening" ? tightenColor :
     stopMode == "Cut / TP" ? cutColor :
     direction == 1 ? longColor :
     shortColor

plot(tsl, "Efficiency Flip TSL", color=activeColor, linewidth=2, style=plot.style_linebr)

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

modeColor =
     stopMode == "Expanded" ? expandColor :
     stopMode == "Tightening" ? tightenColor :
     stopMode == "Cut / TP" ? cutColor :
     color.gray

dirText = direction == 1 ? "Long Mode" : "Short Mode"
behaviorText = invertEfficiencyBehavior ? "Inverted" : "Standard"

var table t = table.new(tblPos, 2, 8)

if barstate.islast
    table.clear(t, 0, 0, 1, 7)

    if showTable
        table.cell(t, 0, 0, "Direction", text_color=tableText, bgcolor=color.black, text_size=tblSize)
        table.cell(t, 1, 0, dirText, text_color=color.black, bgcolor=direction == 1 ? longColor : shortColor, text_size=tblSize)

        table.cell(t, 0, 1, "Behavior", text_color=tableText, bgcolor=color.black, text_size=tblSize)
        table.cell(t, 1, 1, behaviorText, text_color=tableText, bgcolor=color.new(color.blue, 30), text_size=tblSize)

        table.cell(t, 0, 2, "Auto Mode", text_color=tableText, bgcolor=color.black, text_size=tblSize)
        table.cell(t, 1, 2, autoDirectionMode, text_color=tableText, bgcolor=color.new(color.blue, 30), text_size=tblSize)

        table.cell(t, 0, 3, "Efficiency", text_color=tableText, bgcolor=color.black, text_size=tblSize)
        table.cell(t, 1, 3, fmt2(score), text_color=color.black, bgcolor=scoreColor, text_size=tblSize)

        table.cell(t, 0, 4, "State", text_color=tableText, bgcolor=color.black, text_size=tblSize)
        table.cell(t, 1, 4, state, text_color=color.black, bgcolor=stateColor, text_size=tblSize)

        table.cell(t, 0, 5, "Stop Mode", text_color=tableText, bgcolor=color.black, text_size=tblSize)
        table.cell(t, 1, 5, stopMode, text_color=color.black, bgcolor=modeColor, text_size=tblSize)

        table.cell(t, 0, 6, "ATR Mult", text_color=tableText, bgcolor=color.black, text_size=tblSize)
        table.cell(t, 1, 6, fmt2(atrMult) + "x", text_color=tableText, bgcolor=color.new(color.blue, 30), text_size=tblSize)

        table.cell(t, 0, 7, "TSL", text_color=tableText, bgcolor=color.black, text_size=tblSize)
        table.cell(t, 1, 7, fmt(tsl), text_color=tableText, bgcolor=color.new(color.gray, 50), text_size=tblSize)

//====================================================
// Alerts
//====================================================
flipLong  = direction == 1 and direction[1] == -1
flipShort = direction == -1 and direction[1] == 1

longCloseSignal  = direction == 1 and ta.crossunder(tfClose, tsl)
shortCloseSignal = direction == -1 and ta.crossover(tfClose, tsl)

priceCrossTSL = ta.cross(tfClose, tsl)

alertcondition(flipLong, "Flipped Long", "Efficiency TSL flipped into Long Mode.")
alertcondition(flipShort, "Flipped Short", "Efficiency TSL flipped into Short Mode.")

alertcondition(longCloseSignal, "Close Long", "Price crossed below the Efficiency TSL. Consider closing long position.")
alertcondition(shortCloseSignal, "Close Short", "Price crossed above the Efficiency TSL. Consider closing short position.")

alertcondition(priceCrossTSL, "Price Crossed TSL", "Price crossed the Efficiency TSL.")
alertcondition(crossBelowLow, "Efficiency Crossed Below Low Threshold", "Efficiency crossed below the low threshold.")
````
