# SMC FVG Pro - Liquidity + Confluence

- url: https://www.tradingview.com/script/ep5CrmwI-SMC-FVG-Pro-Liquidity-Confluence/
- type: indicator
- pine_id: PUB;dfeec44822c64701b2023ac54001f29c
- version: 1.0

## Description

SMC FVG Pro - Liquidity + Confluence is a Smart Money Concepts indicator designed to identify active market imbalances, structure breaks, liquidity levels, and high-probability Fair Value Gap zones.

It automatically detects bullish and bearish FVGs, ranks them by strength, shows mitigation percentage, tracks how old each FVG is, and removes zones once they are fully filled. The indicator also marks swing highs and swing lows as liquidity points and removes them once price mitigates those levels.

For market structure, it identifies BOS and CHoCH events using swing-based breaks. Instead of cluttering the chart with repeated labels, it draws a clean horizontal line from the broken swing level to the candle that caused the break, with the BOS or CHoCH label centered above the line.

Main functions:

Detects bullish and bearish Fair Value Gaps.
Removes fully filled FVGs automatically.
Displays FVG strength: Weak, Medium, or Strong.
Shows confidence score from 0/10 to 10/10.
Shows FVG mitigation percentage and age.
Marks swing highs and swing lows.
Removes mitigated swing liquidity levels.
Detects BOS and CHoCH.
Draws structure-break lines instead of repeated labels.
Includes optional higher-timeframe FVG overlay.

The purpose of the indicator is to help filter trades by showing where price may react, where liquidity is resting, and whether structure supports continuation or reversal.

## Source Code

````pine
//@version=6
indicator("SMC FVG Pro - Liquidity + Confluence", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

//====================
// INPUTS
//====================
swingLen        = input.int(3, "Swing Length", minval=1)
showSwings      = input.bool(true, "Show Swing High/Low")
showFVG         = input.bool(true, "Show Current TF FVG")
showHTF         = input.bool(false, "Show HTF FVG")
htfTF           = input.timeframe("60", "HTF Timeframe")
removeFilled    = input.bool(true, "Remove Fully Filled FVG")
showMitigation  = input.bool(true, "Show Mitigation %")
showLiquidity   = input.bool(true, "Show Liquidity Levels")
showScore       = input.bool(true, "Show FVG Confidence Score")
showStructureLines = input.bool(true, "Show BOS / CHoCH Lines")
bosLabelOffsetTicks = input.int(10, "BOS Label Offset In Ticks", minval=1)
minFvgTicks     = input.int(2, "Minimum FVG Size In Ticks", minval=1)

bullColor       = input.color(color.new(color.lime, 80), "Bullish FVG Color")
bearColor       = input.color(color.new(color.red, 80), "Bearish FVG Color")
htfBullColor    = input.color(color.new(color.aqua, 85), "HTF Bullish FVG Color")
htfBearColor    = input.color(color.new(color.orange, 85), "HTF Bearish FVG Color")

//====================
// ARRAYS
//====================
var box[]   fvgBoxes     = array.new_box()
var label[] fvgLabels    = array.new_label()
var float[] fvgTopArr    = array.new_float()
var float[] fvgBotArr    = array.new_float()
var int[]   fvgDirArr    = array.new_int()
var int[]   fvgScoreArr  = array.new_int()
var int[]   fvgBirthArr  = array.new_int()

var label[] swingLabels = array.new_label()
var line[]  swingLines  = array.new_line()
var float[] swingPrices = array.new_float()
var int[]   swingDirs   = array.new_int()

//====================
// SWINGS
//====================
swingHigh = ta.pivothigh(high, swingLen, swingLen)
swingLow  = ta.pivotlow(low, swingLen, swingLen)

var float activeSwingHigh = na
var float activeSwingLow  = na
var int activeSwingHighBar = na
var int activeSwingLowBar  = na
var int trend = 0

if not na(swingHigh)
    activeSwingHigh := swingHigh
    activeSwingHighBar := bar_index - swingLen

    lbl = showSwings ? label.new(bar_index - swingLen, swingHigh, "SH", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.tiny) : na
    ln  = showLiquidity ? line.new(bar_index - swingLen, swingHigh, bar_index, swingHigh, extend=extend.right, color=color.new(color.red, 40), style=line.style_dotted) : na

    array.push(swingLabels, lbl)
    array.push(swingLines, ln)
    array.push(swingPrices, swingHigh)
    array.push(swingDirs, 1)

if not na(swingLow)
    activeSwingLow := swingLow
    activeSwingLowBar := bar_index - swingLen

    lbl = showSwings ? label.new(bar_index - swingLen, swingLow, "SL", style=label.style_label_up, color=color.aqua, textcolor=color.black, size=size.tiny) : na
    ln  = showLiquidity ? line.new(bar_index - swingLen, swingLow, bar_index, swingLow, extend=extend.right, color=color.new(color.aqua, 40), style=line.style_dotted) : na

    array.push(swingLabels, lbl)
    array.push(swingLines, ln)
    array.push(swingPrices, swingLow)
    array.push(swingDirs, -1)

//====================
// REMOVE MITIGATED SWINGS
//====================
if array.size(swingPrices) > 0
    for i = array.size(swingPrices) - 1 to 0
        price = array.get(swingPrices, i)
        dir   = array.get(swingDirs, i)
        lbl   = array.get(swingLabels, i)
        ln    = array.get(swingLines, i)

        mitigated = dir == 1 ? high >= price : low <= price

        if mitigated
            if not na(lbl)
                label.delete(lbl)

            if not na(ln)
                line.delete(ln)

            array.remove(swingLabels, i)
            array.remove(swingLines, i)
            array.remove(swingPrices, i)
            array.remove(swingDirs, i)

//====================
// CLEAN BOS / CHoCH
//====================
bosBull = not na(activeSwingHigh) and ta.crossover(close, activeSwingHigh)
bosBear = not na(activeSwingLow) and ta.crossunder(close, activeSwingLow)

chochBull = trend == -1 and bosBull
chochBear = trend == 1 and bosBear

//====================
// DRAW BOS / CHoCH LINES
//====================
f_drawStructure(_x1, _x2, _y, _txt, _isBull) =>
    lineColor = _isBull ? color.lime : color.red
    labelColor = _isBull ? color.lime : color.red
    midX = math.round((_x1 + _x2) / 2)
    labelY = _isBull ? _y + syminfo.mintick * bosLabelOffsetTicks : _y - syminfo.mintick * bosLabelOffsetTicks

    line.new(
         x1=_x1,
         y1=_y,
         x2=_x2,
         y2=_y,
         color=lineColor,
         width=2,
         style=line.style_solid
     )

    label.new(
         x=midX,
         y=labelY,
         text=_txt,
         style=_isBull ? label.style_label_down : label.style_label_up,
         color=labelColor,
         textcolor=_isBull ? color.black : color.white,
         size=size.tiny
     )

if showStructureLines and bosBull
    txt = chochBull ? "CHoCH" : "BOS"
    f_drawStructure(activeSwingHighBar, bar_index, activeSwingHigh, txt, true)

if showStructureLines and bosBear
    txt = chochBear ? "CHoCH" : "BOS"
    f_drawStructure(activeSwingLowBar, bar_index, activeSwingLow, txt, false)

if bosBull
    trend := 1
    activeSwingHigh := na
    activeSwingHighBar := na

if bosBear
    trend := -1
    activeSwingLow := na
    activeSwingLowBar := na

//====================
// FVG CONDITIONS
//====================
tickSize = syminfo.mintick
minGap = minFvgTicks * tickSize

bullFVG = low > high[2] and (low - high[2]) >= minGap
bearFVG = high < low[2] and (low[2] - high) >= minGap

//====================
// SCORE FUNCTION
//====================
f_score(_dir, _top, _bot) =>
    score = 0

    gapSize = math.abs(_top - _bot)
    avgRange = ta.sma(high - low, 20)

    displacement = (high - low) > avgRange * 1.5
    volConfirm = volume > ta.sma(volume, 20)
    bosConfirm = _dir == 1 ? bosBull : bosBear
    chochConfirm = _dir == 1 ? chochBull : chochBear
    trendConfirm = _dir == trend

    if displacement
        score += 2
    if volConfirm
        score += 2
    if bosConfirm
        score += 2
    if chochConfirm
        score += 2
    if trendConfirm
        score += 2
    if gapSize > avgRange * 0.4
        score += 1

    math.min(score, 10)

f_quality(_score) =>
    _score >= 8 ? "Strong" : _score >= 5 ? "Medium" : "Weak"

//====================
// CREATE FVG
//====================
f_createFVG(_top, _bot, _dir, _color) =>
    score = f_score(_dir, _top, _bot)
    quality = f_quality(score)

    b = box.new(
         left=bar_index - 2,
         top=_top,
         right=bar_index,
         bottom=_bot,
         extend=extend.right,
         bgcolor=_color,
         border_color=color.new(_dir == 1 ? color.lime : color.red, 20)
     )

    txt = showScore ? "FVG\n" + quality + "\nScore: " + str.tostring(score) + "/10" : "FVG"

    l = label.new(
         bar_index,
         (_top + _bot) / 2,
         txt,
         style=label.style_label_left,
         textcolor=color.white,
         color=color.new(color.black, 65),
         size=size.tiny
     )

    array.push(fvgBoxes, b)
    array.push(fvgLabels, l)
    array.push(fvgTopArr, _top)
    array.push(fvgBotArr, _bot)
    array.push(fvgDirArr, _dir)
    array.push(fvgScoreArr, score)
    array.push(fvgBirthArr, bar_index)

//====================
// CURRENT TF FVG
//====================
if showFVG and bullFVG
    f_createFVG(low, high[2], 1, bullColor)

if showFVG and bearFVG
    f_createFVG(low[2], high, -1, bearColor)

//====================
// UPDATE / REMOVE FVGs
//====================
if array.size(fvgBoxes) > 0
    for i = array.size(fvgBoxes) - 1 to 0
        b     = array.get(fvgBoxes, i)
        l     = array.get(fvgLabels, i)
        top   = array.get(fvgTopArr, i)
        bot   = array.get(fvgBotArr, i)
        dir   = array.get(fvgDirArr, i)
        score = array.get(fvgScoreArr, i)
        birth = array.get(fvgBirthArr, i)

        height = top - bot
        filled = dir == 1 ? low <= bot : high >= top

        mitigation = dir == 1
             ? math.max(0, math.min(100, ((top - low) / height) * 100))
             : math.max(0, math.min(100, ((high - bot) / height) * 100))

        quality = f_quality(score)

        txt = showScore ? "FVG\n" + quality + "\nScore: " + str.tostring(score) + "/10" : "FVG"

        if showMitigation
            txt += "\nFilled: " + str.tostring(math.round(mitigation)) + "%"
            txt += "\nAge: " + str.tostring(bar_index - birth) + " bars"

        label.set_text(l, txt)
        label.set_x(l, bar_index)
        label.set_y(l, (top + bot) / 2)

        if removeFilled and filled
            box.delete(b)
            label.delete(l)

            array.remove(fvgBoxes, i)
            array.remove(fvgLabels, i)
            array.remove(fvgTopArr, i)
            array.remove(fvgBotArr, i)
            array.remove(fvgDirArr, i)
            array.remove(fvgScoreArr, i)
            array.remove(fvgBirthArr, i)

//====================
// HTF FVG OVERLAY
//====================
htfHigh2 = request.security(syminfo.tickerid, htfTF, high[2])
htfLow2  = request.security(syminfo.tickerid, htfTF, low[2])
htfHigh  = request.security(syminfo.tickerid, htfTF, high)
htfLow   = request.security(syminfo.tickerid, htfTF, low)

htfBullFVG = htfLow > htfHigh2
htfBearFVG = htfHigh < htfLow2

if showHTF and htfBullFVG
    box.new(left=bar_index, top=htfLow, right=bar_index + 20, bottom=htfHigh2, bgcolor=htfBullColor, border_color=color.aqua, extend=extend.right)

if showHTF and htfBearFVG
    box.new(left=bar_index, top=htfLow2, right=bar_index + 20, bottom=htfHigh, bgcolor=htfBearColor, border_color=color.orange, extend=extend.right)
````
