# Automated Orderflow - FVG BAG ERL

- url: https://www.tradingview.com/script/OEQTE9It-Automated-Orderflow-FVG-BAG-ERL/
- type: indicator
- pine_id: PUB;0946391e278b46c080ba57e97866f493
- version: 1.0

## Description

Updated it. The new script no longer changes candle colors and is more focused on matching the video indicator overlay: soft gray FVG/BAG zones, retained recent BAG arrays, right-side tiny labels, HTF bias FVG, context area, ERL target lines, and thin orderflow-leg brackets.

## Source Code

````pine
//@version=6
// Paste the entire script into a blank Pine Editor tab. The version line above must be line 1.
indicator("Automated Orderflow - FVG BAG ERL", overlay=true, max_boxes_count=80, max_lines_count=80, max_labels_count=80)

// Inputs
swingLen = input.int(3, "Swing Length", minval=1, maxval=50)
extendBars = input.int(80, "Right Extension Bars", minval=10, maxval=450)
keepBAGZones = input.int(8, "Keep Recent BAG Zones", minval=1, maxval=20)
showFVG = input.bool(true, "Show Narrative FVG")
showBAG = input.bool(true, "Show BAG / Respected FVG")
showHTFZone = input.bool(true, "Show Higher Timeframe Bias FVG")
showContext = input.bool(true, "Show Context Area")
showSwings = input.bool(true, "Show ERL Targets")
showLeg = input.bool(true, "Show Orderflow Leg Bracket")
showPanel = input.bool(false, "Show Small Bias Panel")
useHTF = input.bool(true, "Use Higher Timeframe Bias")
htf = input.timeframe("240", "Higher Timeframe")
ltfTag = input.string("1h", "Narrative Label Tag")
htfTag = input.string("4h", "Bias Label Tag")

// Video-style overlay colors. Candles are intentionally not recolored.
zoneGray = color.new(color.rgb(202, 205, 209), 47)
zoneGraySoft = color.new(color.rgb(202, 205, 209), 61)
biasBull = color.new(color.rgb(194, 238, 202), 66)
biasBear = color.new(color.rgb(244, 188, 192), 68)
contextBull = color.new(color.rgb(190, 238, 202), 75)
contextBear = color.new(color.rgb(244, 190, 194), 76)
borderClear = color.new(color.rgb(180, 183, 188), 100)
lineSoft = color.new(color.rgb(145, 148, 154), 22)
lineFaint = color.new(color.rgb(172, 175, 180), 36)
textGray = color.rgb(102, 105, 111)

// Swing High / Low
swingHigh = ta.pivothigh(high, swingLen, swingLen)
swingLow = ta.pivotlow(low, swingLen, swingLen)

var float lastSwingHigh = na
var float lastSwingLow = na
var int lastSwingHighBar = na
var int lastSwingLowBar = na
var line swingHighLine = na
var line swingLowLine = na
var label swingHighLabel = na
var label swingLowLabel = na

zoneRight = bar_index + extendBars
labelRight = zoneRight + 2

if not na(swingHigh)
    lastSwingHigh := swingHigh
    lastSwingHighBar := bar_index - swingLen
    if showSwings
        if not na(swingHighLine)
            line.delete(swingHighLine)
        if not na(swingHighLabel)
            label.delete(swingHighLabel)
        swingHighLine := line.new(lastSwingHighBar, swingHigh, zoneRight, swingHigh, color=lineSoft, style=line.style_dashed)
        swingHighLabel := label.new(labelRight, swingHigh, "Swing High (ERL/Target)", style=label.style_none, textcolor=textGray, size=size.small)

if not na(swingLow)
    lastSwingLow := swingLow
    lastSwingLowBar := bar_index - swingLen
    if showSwings
        if not na(swingLowLine)
            line.delete(swingLowLine)
        if not na(swingLowLabel)
            label.delete(swingLowLabel)
        swingLowLine := line.new(lastSwingLowBar, swingLow, zoneRight, swingLow, color=lineSoft, style=line.style_dashed)
        swingLowLabel := label.new(labelRight, swingLow, "Swing Low (ERL/Target)", style=label.style_none, textcolor=textGray, size=size.small)

if not na(swingHighLine)
    line.set_x2(swingHighLine, zoneRight)
if not na(swingHighLabel)
    label.set_x(swingHighLabel, labelRight)
if not na(swingLowLine)
    line.set_x2(swingLowLine, zoneRight)
if not na(swingLowLabel)
    label.set_x(swingLowLabel, labelRight)

// Fair Value Gap logic
bullFVG = bar_index >= 2 and low > high[2]
bearFVG = bar_index >= 2 and high < low[2]

bullTop = low
bullBottom = high[2]
bearTop = low[2]
bearBottom = high

var box bullBox = na
var box bearBox = na
var box bullBagBox = na
var box bearBagBox = na
var label bullLabel = na
var label bearLabel = na
var label bullBagLabel = na
var label bearBagLabel = na
var label narrativeLabel = na
var box[] savedBagBoxes = array.new_box()
var label[] savedBagLabels = array.new_label()

var int bullBoxBar = na
var int bearBoxBar = na
var bool bullBagMarked = false
var bool bearBagMarked = false
var int bias = 0

// Orderflow leg bracket objects
var line legTopLine = na
var line legBottomLine = na
var line legLeftLine = na
var line legRightLine = na
var label legLabel = na

if showFVG and bullFVG
    if not na(bullBox)
        box.delete(bullBox)
    if not na(bullLabel)
        label.delete(bullLabel)
    if not na(narrativeLabel)
        label.delete(narrativeLabel)
    bullBox := box.new(bar_index - 2, bullTop, zoneRight, bullBottom, bgcolor=zoneGray, border_color=borderClear)
    bullLabel := label.new(labelRight, (bullTop + bullBottom) / 2.0, "^ " + ltfTag + " FVG", style=label.style_none, textcolor=textGray, size=size.tiny)
    narrativeLabel := label.new(bar_index + 5, (bullTop + bullBottom) / 2.0, "Narrative PDA (FVG)", style=label.style_none, textcolor=textGray, size=size.small)
    bullBoxBar := bar_index
    bullBagMarked := false
    bias := 1
    if showLeg
        if not na(legTopLine)
            line.delete(legTopLine)
        if not na(legBottomLine)
            line.delete(legBottomLine)
        if not na(legLeftLine)
            line.delete(legLeftLine)
        if not na(legRightLine)
            line.delete(legRightLine)
        if not na(legLabel)
            label.delete(legLabel)
        legStartBar = not na(lastSwingLowBar) ? lastSwingLowBar : bar_index - 2
        legLow = not na(lastSwingLow) ? lastSwingLow : low[2]
        legHigh = math.max(high, high[1])
        legTopLine := line.new(legStartBar, legHigh, zoneRight, legHigh, color=lineFaint)
        legBottomLine := line.new(legStartBar, legLow, zoneRight, legLow, color=lineFaint)
        legLeftLine := line.new(legStartBar, legLow, legStartBar, legHigh, color=lineFaint)
        legRightLine := line.new(bar_index, legLow, bar_index, legHigh, color=lineFaint)
        legLabel := label.new(labelRight, legHigh, "Bullish Orderflow", style=label.style_none, textcolor=textGray, size=size.small)

if showFVG and bearFVG
    if not na(bearBox)
        box.delete(bearBox)
    if not na(bearLabel)
        label.delete(bearLabel)
    if not na(narrativeLabel)
        label.delete(narrativeLabel)
    bearBox := box.new(bar_index - 2, bearTop, zoneRight, bearBottom, bgcolor=zoneGray, border_color=borderClear)
    bearLabel := label.new(labelRight, (bearTop + bearBottom) / 2.0, "v " + ltfTag + " FVG", style=label.style_none, textcolor=textGray, size=size.tiny)
    narrativeLabel := label.new(bar_index + 5, (bearTop + bearBottom) / 2.0, "Narrative PDA (FVG)", style=label.style_none, textcolor=textGray, size=size.small)
    bearBoxBar := bar_index
    bearBagMarked := false
    bias := -1
    if showLeg
        if not na(legTopLine)
            line.delete(legTopLine)
        if not na(legBottomLine)
            line.delete(legBottomLine)
        if not na(legLeftLine)
            line.delete(legLeftLine)
        if not na(legRightLine)
            line.delete(legRightLine)
        if not na(legLabel)
            label.delete(legLabel)
        legStartBar = not na(lastSwingHighBar) ? lastSwingHighBar : bar_index - 2
        legHigh = not na(lastSwingHigh) ? lastSwingHigh : high[2]
        legLow = math.min(low, low[1])
        legTopLine := line.new(legStartBar, legHigh, zoneRight, legHigh, color=lineFaint)
        legBottomLine := line.new(legStartBar, legLow, zoneRight, legLow, color=lineFaint)
        legLeftLine := line.new(legStartBar, legLow, legStartBar, legHigh, color=lineFaint)
        legRightLine := line.new(bar_index, legLow, bar_index, legHigh, color=lineFaint)
        legLabel := label.new(labelRight, legLow, "Bearish Orderflow", style=label.style_none, textcolor=textGray, size=size.small)

// Keep active drawings extended to the current right edge.
if not na(bullBox)
    box.set_right(bullBox, zoneRight)
if not na(bullLabel)
    label.set_x(bullLabel, labelRight)
    label.set_y(bullLabel, (box.get_top(bullBox) + box.get_bottom(bullBox)) / 2.0)
if not na(bearBox)
    box.set_right(bearBox, zoneRight)
if not na(bearLabel)
    label.set_x(bearLabel, labelRight)
    label.set_y(bearLabel, (box.get_top(bearBox) + box.get_bottom(bearBox)) / 2.0)
if not na(narrativeLabel)
    label.set_x(narrativeLabel, bar_index + 5)
if not na(legTopLine)
    line.set_x2(legTopLine, zoneRight)
if not na(legBottomLine)
    line.set_x2(legBottomLine, zoneRight)
if not na(legLabel)
    label.set_x(legLabel, labelRight)

// Zone tests
hasBullBox = not na(bullBox) and not na(bullBoxBar)
hasBearBox = not na(bearBox) and not na(bearBoxBar)

bullRespected = hasBullBox and bar_index > bullBoxBar and low <= box.get_top(bullBox) and close > box.get_bottom(bullBox)
bearRespected = hasBearBox and bar_index > bearBoxBar and high >= box.get_bottom(bearBox) and close < box.get_top(bearBox)

bullFailed = hasBullBox and bar_index > bullBoxBar and close < box.get_bottom(bullBox)
bearFailed = hasBearBox and bar_index > bearBoxBar and close > box.get_top(bearBox)

bullBAGSignal = showBAG and bullRespected and not bullBagMarked
bearBAGSignal = showBAG and bearRespected and not bearBagMarked

if bullBAGSignal
    bullBagBox := box.new(bar_index, box.get_top(bullBox), zoneRight, box.get_bottom(bullBox), bgcolor=zoneGraySoft, border_color=borderClear)
    bullBagLabel := label.new(labelRight, (box.get_top(bullBox) + box.get_bottom(bullBox)) / 2.0, "^ " + ltfTag + " BAG", style=label.style_none, textcolor=textGray, size=size.tiny)
    array.push(savedBagBoxes, bullBagBox)
    array.push(savedBagLabels, bullBagLabel)
    if array.size(savedBagBoxes) > keepBAGZones
        oldBox = array.shift(savedBagBoxes)
        box.delete(oldBox)
    if array.size(savedBagLabels) > keepBAGZones
        oldLabel = array.shift(savedBagLabels)
        label.delete(oldLabel)
    bullBagMarked := true

if bearBAGSignal
    bearBagBox := box.new(bar_index, box.get_top(bearBox), zoneRight, box.get_bottom(bearBox), bgcolor=zoneGraySoft, border_color=borderClear)
    bearBagLabel := label.new(labelRight, (box.get_top(bearBox) + box.get_bottom(bearBox)) / 2.0, "v " + ltfTag + " BAG", style=label.style_none, textcolor=textGray, size=size.tiny)
    array.push(savedBagBoxes, bearBagBox)
    array.push(savedBagLabels, bearBagLabel)
    if array.size(savedBagBoxes) > keepBAGZones
        oldBox = array.shift(savedBagBoxes)
        box.delete(oldBox)
    if array.size(savedBagLabels) > keepBAGZones
        oldLabel = array.shift(savedBagLabels)
        label.delete(oldLabel)
    bearBagMarked := true

if not na(bullBagBox)
    box.set_right(bullBagBox, zoneRight)
if not na(bullBagLabel)
    label.set_x(bullBagLabel, labelRight)
if not na(bearBagBox)
    box.set_right(bearBagBox, zoneRight)
if not na(bearBagLabel)
    label.set_x(bearBagLabel, labelRight)

if bullFailed
    bias := -1

if bearFailed
    bias := 1

// Higher timeframe bias FVG
htfBullFVG = request.security(syminfo.tickerid, htf, low > high[2])
htfBearFVG = request.security(syminfo.tickerid, htf, high < low[2])
htfBullTop = request.security(syminfo.tickerid, htf, low)
htfBullBottom = request.security(syminfo.tickerid, htf, high[2])
htfBearTop = request.security(syminfo.tickerid, htf, low[2])
htfBearBottom = request.security(syminfo.tickerid, htf, high)
htfTime = time(htf)
newHTFBar = ta.change(htfTime) != 0

var int htfBias = 0
var box htfBox = na
var label htfLabel = na
var label htfNameLabel = na

if useHTF and newHTFBar and htfBullFVG
    htfBias := 1

if useHTF and newHTFBar and htfBearFVG
    htfBias := -1

if useHTF and showHTFZone and newHTFBar and htfBullFVG
    if not na(htfBox)
        box.delete(htfBox)
    if not na(htfLabel)
        label.delete(htfLabel)
    if not na(htfNameLabel)
        label.delete(htfNameLabel)
    htfBox := box.new(bar_index, htfBullTop, zoneRight, htfBullBottom, bgcolor=biasBull, border_color=borderClear)
    htfLabel := label.new(labelRight, (htfBullTop + htfBullBottom) / 2.0, "^ " + htfTag + " FVG", style=label.style_none, textcolor=color.rgb(91, 166, 104), size=size.tiny)
    htfNameLabel := label.new(bar_index + 4, htfBullBottom, "Higher Timeframe Bias FVG", style=label.style_none, textcolor=textGray, size=size.small)

if useHTF and showHTFZone and newHTFBar and htfBearFVG
    if not na(htfBox)
        box.delete(htfBox)
    if not na(htfLabel)
        label.delete(htfLabel)
    if not na(htfNameLabel)
        label.delete(htfNameLabel)
    htfBox := box.new(bar_index, htfBearTop, zoneRight, htfBearBottom, bgcolor=biasBear, border_color=borderClear)
    htfLabel := label.new(labelRight, (htfBearTop + htfBearBottom) / 2.0, "v " + htfTag + " FVG", style=label.style_none, textcolor=color.rgb(198, 76, 88), size=size.tiny)
    htfNameLabel := label.new(bar_index + 4, htfBearTop, "Higher Timeframe Bias FVG", style=label.style_none, textcolor=textGray, size=size.small)

if not na(htfBox)
    box.set_right(htfBox, zoneRight)
if not na(htfLabel)
    label.set_x(htfLabel, labelRight)
if not na(htfNameLabel)
    label.set_x(htfNameLabel, bar_index + 4)

finalBias = useHTF and htfBias != 0 ? htfBias : bias

// Context area from the narrative PDA toward the next ERL target.
var box contextBox = na
var label contextLabel = na

validBullContext = showContext and finalBias == 1 and hasBullBox and not na(lastSwingHigh) and lastSwingHigh > box.get_top(bullBox)
validBearContext = showContext and finalBias == -1 and hasBearBox and not na(lastSwingLow) and lastSwingLow < box.get_bottom(bearBox)

if validBullContext
    if na(contextBox)
        contextBox := box.new(bar_index + 8, lastSwingHigh, zoneRight, box.get_top(bullBox), bgcolor=contextBull, border_color=borderClear)
        contextLabel := label.new(bar_index + 10, (lastSwingHigh + box.get_top(bullBox)) / 2.0, "Context Area\nArea to trade within", style=label.style_none, textcolor=color.rgb(91, 166, 104), size=size.tiny)
    else
        box.set_left(contextBox, bar_index + 8)
        box.set_right(contextBox, zoneRight)
        box.set_top(contextBox, lastSwingHigh)
        box.set_bottom(contextBox, box.get_top(bullBox))
        label.set_x(contextLabel, bar_index + 10)
        label.set_y(contextLabel, (lastSwingHigh + box.get_top(bullBox)) / 2.0)
        label.set_text(contextLabel, "Context Area\nArea to trade within")
        label.set_textcolor(contextLabel, color.rgb(91, 166, 104))

if validBearContext
    if na(contextBox)
        contextBox := box.new(bar_index + 8, box.get_bottom(bearBox), zoneRight, lastSwingLow, bgcolor=contextBear, border_color=borderClear)
        contextLabel := label.new(bar_index + 10, (box.get_bottom(bearBox) + lastSwingLow) / 2.0, "Context Area\nArea to trade within", style=label.style_none, textcolor=color.rgb(198, 76, 88), size=size.tiny)
    else
        box.set_left(contextBox, bar_index + 8)
        box.set_right(contextBox, zoneRight)
        box.set_top(contextBox, box.get_bottom(bearBox))
        box.set_bottom(contextBox, lastSwingLow)
        label.set_x(contextLabel, bar_index + 10)
        label.set_y(contextLabel, (box.get_bottom(bearBox) + lastSwingLow) / 2.0)
        label.set_text(contextLabel, "Context Area\nArea to trade within")
        label.set_textcolor(contextLabel, color.rgb(198, 76, 88))

if showContext and not validBullContext and not validBearContext and not na(contextBox)
    box.delete(contextBox)
    contextBox := na
    if not na(contextLabel)
        label.delete(contextLabel)
        contextLabel := na

// Optional compact status panel
string biasText = finalBias == 1 ? "Bias: Bullish" : finalBias == -1 ? "Bias: Bearish" : "Bias: Neutral"
string narrativeText = finalBias == 1 ? "Narrative: Long from FVG/BAG toward ERL" : finalBias == -1 ? "Narrative: Short from FVG/BAG toward ERL" : "Narrative: Wait"
string targetText = "Target: Waiting"

if finalBias == 1 and not na(lastSwingHigh)
    targetText := "Target: Swing High " + str.tostring(lastSwingHigh, format.mintick)

if finalBias == -1 and not na(lastSwingLow)
    targetText := "Target: Swing Low " + str.tostring(lastSwingLow, format.mintick)

var table dash = table.new(position.top_right, 1, 4, border_width=1)

if barstate.islast and showPanel
    table.cell(dash, 0, 0, "Orderflow", text_color=color.white, bgcolor=color.rgb(45, 45, 45))
    table.cell(dash, 0, 1, biasText, text_color=color.white, bgcolor=finalBias == 1 ? color.rgb(74, 166, 91) : finalBias == -1 ? color.rgb(198, 76, 88) : color.gray)
    table.cell(dash, 0, 2, narrativeText, text_color=color.white, bgcolor=color.new(color.rgb(45, 45, 45), 15))
    table.cell(dash, 0, 3, targetText, text_color=color.white, bgcolor=color.new(color.rgb(45, 45, 45), 15))

// Alerts
alertcondition(finalBias == 1 and bullFVG, "Bullish Orderflow FVG", "Bullish orderflow FVG formed.")
alertcondition(finalBias == -1 and bearFVG, "Bearish Orderflow FVG", "Bearish orderflow FVG formed.")
alertcondition(bullBAGSignal, "Bullish FVG Respected", "Bullish FVG respected / BAG marked.")
alertcondition(bearBAGSignal, "Bearish FVG Respected", "Bearish FVG respected / BAG marked.")
alertcondition(bullFailed, "Bullish FVG Failed", "Bullish FVG failed. Bias may flip bearish.")
alertcondition(bearFailed, "Bearish FVG Failed", "Bearish FVG failed. Bias may flip bullish.")
````
