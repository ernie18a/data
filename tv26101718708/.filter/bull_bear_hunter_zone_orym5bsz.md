#  Bull & Bear hunter zone 

- url: https://www.tradingview.com/script/OrYm5bsZ/
- type: indicator
- pine_id: PUB;7416a0fcb00148f0902fea2a6ba28a3f
- version: 1.0

## Description

Bull & Bear hunter zone 
วิเคราะห์ XAUUSD และ Forex ด้วย Price Action, Market Structure, Order Block, FVG และ Liquidity Zone เพื่อหาโซน Bullish / Bearish ที่มีความได้เปรียบในการเทรด

ระบบวิเคราะห์เน้น BOS, MSS, OB, FVG, Supply & Demand และการจัดระดับโซน Grade A / B / C เพื่อช่วยวางแผนจุดเข้า จุดออก และบริหารความเสี่ยงอย่างเป็นระบบ

ทุกไอเดียเป็นการวิเคราะห์ส่วนตัว ไม่ใช่คำแนะนำทางการเงิน โปรดบริหารความเสี่ยงก่อนเข้าเทรดทุกครั้ง.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ICT_Insight_Hub

// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © KULDEEP157

//@version=6
indicator(" Bull & Bear hunter zone ", overlay=true, max_boxes_count=500)

BULLISH_LEG = 1
BEARISH_LEG = 0
BULLISH = +1
BEARISH = -1
GREEN = #089981
RED = #F23645
BLUE = #2157f3
GRAY = #878b94
MONO_BULLISH = #b2b5be
MONO_BEARISH = #5d606b
HISTORICAL = 'Historical'
PRESENT = 'Present'
ALL = 'All'
BOS = 'BOS'
CHOCH = 'CHoCH'
TINY = size.tiny
SMALL = size.small
NORMAL = size.normal
SOLID = '⎯⎯⎯'
DASHED = '----'
DOTTED = '····'

modeInput = PRESENT

showInternalsInput = true
showInternalBullInput = ALL
internalBullColorInput = GREEN
showInternalBearInput = ALL
internalBearColorInput = RED
internalStructureSize = TINY

showStructureInput = true
showSwingBullInput = ALL
swingBullColorInput = GREEN
showSwingBearInput = ALL
swingBearColorInput = RED
swingStructureSize = SMALL
swingsLengthInput = 50

showEqualHighsLowsInput = true
equalHighsLowsLengthInput = 3
equalHighsLowsThresholdInput = 0.1
equalHighsLowsSizeInput = TINY

showFairValueGapsInput = true
fairValueGapsThresholdInput = true
fairValueGapsTimeframe = ""
fairValueGapsExtendInput = 1

showInternalOrderBlocksInput = true
internalOrderBlocksSizeInput = 6
showSwingOrderBlocksInput = false
swingOrderBlocksSizeInput = 2
orderBlockFilterInput = "Atr"
orderBlockMitigationInput = "High/Low"

bullishGradeAColor = color.rgb(30, 255, 0)
bullishGradeBColor = color.rgb(30, 255, 0)
bullishGradeCColor = color.rgb(30, 255, 0)

bearishGradeAColor = color.rgb(255, 0, 0)
bearishGradeBColor = color.rgb(255, 0, 0)
bearishGradeCColor = color.rgb(255, 0, 0)

bullishLabelBg = color.rgb(0, 4, 1)
bearishLabelBg = color.rgb(0, 4, 1)

type alerts
    bool internalBullishBOS = false
    bool internalBearishBOS = false
    bool internalBullishCHoCH = false
    bool internalBearishCHoCH = false
    bool swingBullishBOS = false
    bool swingBearishBOS = false
    bool swingBullishCHoCH = false
    bool swingBearishCHoCH = false
    bool equalHighs = false
    bool equalLows = false
    bool bullishFairValueGap = false
    bool bearishFairValueGap = false

type fairValueGap
    float top
    float bottom
    int bias
    box topBox
    box bottomBox

type trend
    int bias

type equalDisplay
    line l_ine = na
    label l_abel = na

type pivot
    float currentLevel
    float lastLevel
    bool crossed
    int barTime = time
    int barIndex = bar_index

type orderBlock
    float barHigh
    float barLow
    int barTime    
    int bias
    string grade

type trailingExtremes
    float top
    float bottom
    int barTime
    int barIndex
    int lastTopTime
    int lastBottomTime

var pivot swingHigh = pivot.new(na, na, false)
var pivot swingLow = pivot.new(na, na, false)
var pivot internalHigh = pivot.new(na, na, false)
var pivot internalLow = pivot.new(na, na, false)
var pivot equalHigh = pivot.new(na, na, false)
var pivot equalLow = pivot.new(na, na, false)

var trend swingTrend = trend.new(0)
var trend internalTrend = trend.new(0)

var equalDisplay equalHighDisplay = equalDisplay.new()
var equalDisplay equalLowDisplay = equalDisplay.new()

var array<fairValueGap> fairValueGaps = array.new<fairValueGap>()

var array<float> parsedHighs = array.new<float>()
var array<float> parsedLows = array.new<float>()
var array<float> highs = array.new<float>()
var array<float> lows = array.new<float>()
var array<int> times = array.new<int>()

var swingBullishColor = swingBullColorInput
var swingBearishColor = swingBearColorInput
var fairValueGapBullishColor = color.new(#00ff68, 70)
var fairValueGapBearishColor = color.new(#ff0008, 70)

varip int currentBarIndex = bar_index
varip int lastBarIndex = bar_index
alerts currentAlerts = alerts.new()
var int initialTime = time

var trailingExtremes trailing = trailingExtremes.new()
var array<orderBlock> swingOrderBlocks = array.new<orderBlock>()
var array<orderBlock> internalOrderBlocks = array.new<orderBlock>()
var array<box> swingOrderBlocksBoxes = array.new<box>()
var array<box> internalOrderBlocksBoxes = array.new<box>()
var array<label> swingOrderBlocksLabels = array.new<label>()
var array<label> internalOrderBlocksLabels = array.new<label>()

atrMeasure = ta.atr(200)

f_timeToString(timestamp) =>
    string h = str.tostring(hour(timestamp))
    string m = str.tostring(minute(timestamp))
    string timeStr = h + ":" + (str.length(m) == 1 ? "0" + m : m)
    timeStr

f_dateToString(timestamp) =>
    string day = str.tostring(dayofmonth(timestamp))
    string month = str.tostring(month(timestamp))
    string year = str.tostring(year(timestamp))
    string dateStr = day + "/" + month + "/" + year
    dateStr

getGrade(float volSpike) =>
    string grade = "C"
    string gradeText = "C"
    
    if volSpike > 1.5
        grade := "A"
        gradeText := "A"
    else if volSpike > 1.2
        grade := "B"
        gradeText := "B"
    else
        grade := "C"
        gradeText := "C"
    
    [grade, gradeText]

getBoxColor(int bias, string grade) =>
    color boxColor = na
    
    if bias == BULLISH
        if grade == "A"
            boxColor := bullishGradeAColor
        else if grade == "B"
            boxColor := bullishGradeBColor
        else
            boxColor := bullishGradeCColor
    else
        if grade == "A"
            boxColor := bearishGradeAColor
        else if grade == "B"
            boxColor := bearishGradeBColor
        else
            boxColor := bearishGradeCColor
    
    boxColor

leg(int size) =>
    var leg = 0
    newLegHigh = high[size] > ta.highest(size)
    newLegLow = low[size] < ta.lowest(size)
    if newLegHigh
        leg := BEARISH_LEG
    else if newLegLow
        leg := BULLISH_LEG
    leg

startOfNewLeg(int leg) => ta.change(leg) != 0
startOfBearishLeg(int leg) => ta.change(leg) == -1
startOfBullishLeg(int leg) => ta.change(leg) == +1

drawEqualHighLow(pivot p_ivot, float level, int size, bool equalHigh) =>
    equalDisplay e_qualDisplay = equalHigh ? equalHighDisplay : equalLowDisplay
    string tag = equalHigh ? 'EQH' : 'EQL'
    color equalColor = equalHigh ? swingBearishColor : swingBullishColor
    string labelStyle = equalHigh ? label.style_label_down : label.style_label_up
    if modeInput == PRESENT
        line.delete(e_qualDisplay.l_ine)
        label.delete(e_qualDisplay.l_abel)
    e_qualDisplay.l_ine := line.new(chart.point.new(p_ivot.barTime, na, p_ivot.currentLevel), chart.point.new(time[size], na, level), xloc = xloc.bar_time, color = equalColor, style = line.style_dotted)
    labelPosition = math.round(0.5 * (p_ivot.barIndex + bar_index - size))
    e_qualDisplay.l_abel := label.new(chart.point.new(na, labelPosition, level), tag, xloc.bar_index, color = color(na), textcolor = equalColor, style = labelStyle, size = equalHighsLowsSizeInput)
    e_qualDisplay.l_abel

getCurrentStructure(int size, bool equalHighLow = false, bool internal = false) =>
    currentLeg = leg(size)
    newPivot = startOfNewLeg(currentLeg)
    pivotLow = startOfBullishLeg(currentLeg)
    pivotHigh = startOfBearishLeg(currentLeg)
    if newPivot
        if pivotLow
            pivot p_ivot = equalHighLow ? equalLow : internal ? internalLow : swingLow
            if equalHighLow and math.abs(p_ivot.currentLevel - low[size]) < equalHighsLowsThresholdInput * atrMeasure
                drawEqualHighLow(p_ivot, low[size], size, false)
                currentAlerts.equalLows := true
            p_ivot.lastLevel := p_ivot.currentLevel
            p_ivot.currentLevel := low[size]
            p_ivot.crossed := false
            p_ivot.barTime := time[size]
            p_ivot.barIndex := bar_index[size]
            if not internal and not equalHighLow
                trailing.bottom := p_ivot.currentLevel
                trailing.barTime := p_ivot.barTime
                trailing.barIndex := p_ivot.barIndex
                trailing.lastBottomTime := p_ivot.barTime
        else
            pivot p_ivot = equalHighLow ? equalHigh : internal ? internalHigh : swingHigh
            if equalHighLow and math.abs(p_ivot.currentLevel - high[size]) < equalHighsLowsThresholdInput * atrMeasure
                drawEqualHighLow(p_ivot, high[size], size, true)
                currentAlerts.equalHighs := true
            p_ivot.lastLevel := p_ivot.currentLevel
            p_ivot.currentLevel := high[size]
            p_ivot.crossed := false
            p_ivot.barTime := time[size]
            p_ivot.barIndex := bar_index[size]
            if not internal and not equalHighLow
                trailing.top := p_ivot.currentLevel
                trailing.barTime := p_ivot.barTime
                trailing.barIndex := p_ivot.barIndex
                trailing.lastTopTime := p_ivot.barTime

drawStructure(pivot p_ivot, string tag, color structureColor, string lineStyle, string labelStyle, string labelSize) =>
    var line l_ine = line.new(na, na, na, na, xloc = xloc.bar_time)
    var label l_abel = label.new(na, na)
    if modeInput == PRESENT
        l_ine.delete()
        l_abel.delete()
    l_ine := line.new(chart.point.new(p_ivot.barTime, na, p_ivot.currentLevel), chart.point.new(time, na, p_ivot.currentLevel), xloc.bar_time, color = structureColor, style = lineStyle)
    l_abel := label.new(chart.point.new(na, math.round(0.5 * (p_ivot.barIndex + bar_index)), p_ivot.currentLevel), tag, xloc.bar_index, color = color(na), textcolor = structureColor, style = labelStyle, size = labelSize)
    l_abel

deleteOrderBlocks(bool internal = false) =>
    array<orderBlock> orderBlocks = internal ? internalOrderBlocks : swingOrderBlocks
    array<label> orderLabels = internal ? internalOrderBlocksLabels : swingOrderBlocksLabels
    string mitSource = orderBlockMitigationInput
    bool isCloseMitigation = mitSource == "Close"
    
    for [index, eachOrderBlock] in orderBlocks
        bool crossedOderBlock = false
        if eachOrderBlock.bias == BEARISH
            float bearishSource = isCloseMitigation ? close : high
            if bearishSource > eachOrderBlock.barHigh
                crossedOderBlock := true
        else if eachOrderBlock.bias == BULLISH
            float bullishSource = isCloseMitigation ? close : low
            if bullishSource < eachOrderBlock.barLow
                crossedOderBlock := true
        if crossedOderBlock
            label lbl = orderLabels.get(index)
            if not na(lbl)
                label.delete(lbl)
            orderBlocks.remove(index)
            orderLabels.remove(index)

storeOrderBlock(pivot p_ivot, bool internal = false, int bias) =>
    if (not internal and showSwingOrderBlocksInput) or (internal and showInternalOrderBlocksInput)
        array<float> a_rray = na
        int parsedIndex = na
        float volSpikeRatio = volume / ta.sma(volume, 20)
        
        if bias == BEARISH
            a_rray := parsedHighs.slice(p_ivot.barIndex, bar_index)
            parsedIndex := p_ivot.barIndex + a_rray.indexof(a_rray.max())
        else
            a_rray := parsedLows.slice(p_ivot.barIndex, bar_index)
            parsedIndex := p_ivot.barIndex + a_rray.indexof(a_rray.min())
        
        [grade, gradeText] = getGrade(volSpikeRatio)
        
        orderBlock o_rderBlock = orderBlock.new(parsedHighs.get(parsedIndex), parsedLows.get(parsedIndex), times.get(parsedIndex), bias, grade)
        array<orderBlock> orderBlocks = internal ? internalOrderBlocks : swingOrderBlocks
        array<label> orderLabels = internal ? internalOrderBlocksLabels : swingOrderBlocksLabels
        array<box> orderBoxes = internal ? internalOrderBlocksBoxes : swingOrderBlocksBoxes
        
        if orderBlocks.size() >= 100
            label oldLbl = orderLabels.pop()
            if not na(oldLbl)
                label.delete(oldLbl)
            box oldBox = orderBoxes.pop()
            if not na(oldBox)
                box.delete(oldBox)
            orderBlocks.pop()
        orderBlocks.unshift(o_rderBlock)
        orderLabels.unshift(na)
        orderBoxes.unshift(na)

drawOrderBlocks(bool internal = false) =>
    array<orderBlock> orderBlocks = internal ? internalOrderBlocks : swingOrderBlocks
    array<box> b_oxes = internal ? internalOrderBlocksBoxes : swingOrderBlocksBoxes
    array<label> b_labels = internal ? internalOrderBlocksLabels : swingOrderBlocksLabels
    
    orderBlocksSize = orderBlocks.size()
    if orderBlocksSize > 0
        maxOrderBlocks = internal ? internalOrderBlocksSizeInput : swingOrderBlocksSizeInput
        array<orderBlock> parsedOrdeBlocks = orderBlocks.slice(0, math.min(maxOrderBlocks, orderBlocksSize))
        
        for [index, eachOrderBlock] in parsedOrdeBlocks
            [grade, gradeText] = getGrade(volume / ta.sma(volume, 20))
            
            color boxColor = getBoxColor(eachOrderBlock.bias, eachOrderBlock.grade)
            
            box b_ox = b_oxes.get(index)
            if na(b_ox)
                b_ox := box.new(chart.point.new(eachOrderBlock.barTime, na, eachOrderBlock.barHigh), chart.point.new(time, na, eachOrderBlock.barLow), xloc = xloc.bar_time, border_color = boxColor, bgcolor = color.new(boxColor, 80), border_width = 1, border_style = line.style_dotted)
                b_oxes.set(index, b_ox)
            else
                b_ox.set_top_left_point(chart.point.new(eachOrderBlock.barTime, na, eachOrderBlock.barHigh))
                b_ox.set_bottom_right_point(chart.point.new(time, na, eachOrderBlock.barLow))
                b_ox.set_border_color(boxColor)
                b_ox.set_bgcolor(color.new(boxColor, 80))
            
            label lbl = b_labels.get(index)
            float labelY = eachOrderBlock.bias == BULLISH ? eachOrderBlock.barLow : eachOrderBlock.barHigh
            string timeStr = f_timeToString(eachOrderBlock.barTime)
            string dateStr = f_dateToString(eachOrderBlock.barTime)
            
            string gradeSymbol = eachOrderBlock.grade == "A" ? "🔴" : eachOrderBlock.grade == "B" ? "🟡" : "⚪"
            string gradeText_label = eachOrderBlock.grade == "A" ? "GRADE A" : eachOrderBlock.grade == "B" ? "GRADE B" : "GRADE C"
            string gradeEmoji = eachOrderBlock.grade == "A" ? "💪" : eachOrderBlock.grade == "B" ? "👍" : "📌"
            
            string biasText = eachOrderBlock.bias == BULLISH ? "BULLISH" : "BEARISH"
            string biasEmoji = eachOrderBlock.bias == BULLISH ? "🟢" : "🔴"
            
            string labelText = biasEmoji + " " + biasText + " " + gradeSymbol + " " + gradeText_label + " " + gradeEmoji + "\n" + timeStr + " | " + dateStr + "\n" + "Zone: " + str.tostring(math.round(eachOrderBlock.barLow, 2)) + " - " + str.tostring(math.round(eachOrderBlock.barHigh, 2))
            
            color labelBgColor = eachOrderBlock.bias == BULLISH ? bullishLabelBg : bearishLabelBg
            color labelTextColor = eachOrderBlock.bias == BULLISH ? color.new(#00ff00, 0) : color.new(#ff4444, 0)
            
            if na(lbl)
                lbl := label.new(chart.point.new(time, na, labelY), text = labelText, color = labelBgColor, textcolor = labelTextColor, style = label.style_label_left, size = size.small, xloc = xloc.bar_time)
                b_labels.set(index, lbl)
            else
                label.set_point(lbl, chart.point.new(time, na, labelY))
                label.set_text(lbl, labelText)
                label.set_color(lbl, labelBgColor)
                label.set_textcolor(lbl, labelTextColor)

displayStructure(bool internal = false) =>
    var bullishBar = true
    var bearishBar = true
    pivot p_ivot = internal ? internalHigh : swingHigh
    trend t_rend = internal ? internalTrend : swingTrend
    lineStyle = internal ? line.style_dashed : line.style_solid
    labelSize = internal ? internalStructureSize : swingStructureSize
    extraCondition = internal ? internalHigh.currentLevel != swingHigh.currentLevel : true
    bullishColor = internal ? internalBullColorInput : swingBullColorInput
    
    if ta.crossover(close, p_ivot.currentLevel) and not p_ivot.crossed and extraCondition
        string tag = t_rend.bias == BEARISH ? CHOCH : BOS
        if internal
            currentAlerts.internalBullishCHoCH := tag == CHOCH
            currentAlerts.internalBullishBOS := tag == BOS
        else
            currentAlerts.swingBullishCHoCH := tag == CHOCH
            currentAlerts.swingBullishBOS := tag == BOS
        p_ivot.crossed := true
        t_rend.bias := BULLISH
        
        if (internal and showInternalOrderBlocksInput) or (not internal and showSwingOrderBlocksInput)
            storeOrderBlock(p_ivot, internal, BULLISH)
        
        displayCondition = internal ? showInternalsInput and (showInternalBullInput == ALL or showInternalBullInput == BOS and tag != CHOCH or showInternalBullInput == CHOCH and tag == CHOCH) : showStructureInput and (showSwingBullInput == ALL or showSwingBullInput == BOS and tag != CHOCH or showSwingBullInput == CHOCH and tag == CHOCH)
        if displayCondition
            drawStructure(p_ivot, tag, bullishColor, lineStyle, label.style_label_down, labelSize)

    p_ivot := internal ? internalLow : swingLow
    extraCondition := internal ? internalLow.currentLevel != swingLow.currentLevel : true
    bearishColor = internal ? internalBearColorInput : swingBearColorInput
    
    if ta.crossunder(close, p_ivot.currentLevel) and not p_ivot.crossed and extraCondition
        string tag = t_rend.bias == BULLISH ? CHOCH : BOS
        if internal
            currentAlerts.internalBearishCHoCH := tag == CHOCH
            currentAlerts.internalBearishBOS := tag == BOS
        else
            currentAlerts.swingBearishCHoCH := tag == CHOCH
            currentAlerts.swingBearishBOS := tag == BOS
        p_ivot.crossed := true
        t_rend.bias := BEARISH
        
        if (internal and showInternalOrderBlocksInput) or (not internal and showSwingOrderBlocksInput)
            storeOrderBlock(p_ivot, internal, BEARISH)
        
        displayCondition = internal ? showInternalsInput and (showInternalBearInput == ALL or showInternalBearInput == BOS and tag != CHOCH or showInternalBearInput == CHOCH and tag == CHOCH) : showStructureInput and (showSwingBearInput == ALL or showSwingBearInput == BOS and tag != CHOCH or showSwingBearInput == CHOCH and tag == CHOCH)
        if displayCondition
            drawStructure(p_ivot, tag, bearishColor, lineStyle, label.style_label_up, labelSize)

fairValueGapBox(leftTime, rightTime, topPrice, bottomPrice, boxColor) =>
    box.new(chart.point.new(leftTime, na, topPrice), chart.point.new(rightTime + fairValueGapsExtendInput * (time - time[1]), na, bottomPrice), xloc = xloc.bar_time, border_color = boxColor, bgcolor = boxColor)

deleteFairValueGaps() =>
    for [index, eachFairValueGap] in fairValueGaps
        if low < eachFairValueGap.bottom and eachFairValueGap.bias == BULLISH or high > eachFairValueGap.top and eachFairValueGap.bias == BEARISH
            eachFairValueGap.topBox.delete()
            eachFairValueGap.bottomBox.delete()
            fairValueGaps.remove(index)

drawFairValueGaps() =>
    fvgTF = fairValueGapsTimeframe == "" ? timeframe.period : fairValueGapsTimeframe
    [lastClose, lastOpen, lastTime, currentHigh, currentLow, currentTime, last2High, last2Low] = request.security(syminfo.tickerid, fvgTF, [close[1], open[1], time[1], high[0], low[0], time[0], high[2], low[2]], lookahead = barmerge.lookahead_on)
    barDeltaPercent = (lastClose - lastOpen) / (lastOpen * 100)
    newTimeframe = timeframe.change(fvgTF)
    threshold = fairValueGapsThresholdInput ? ta.cum(math.abs(newTimeframe ? barDeltaPercent : 0)) / bar_index * 2 : 0
    
    bullishFairValueGap = currentLow > last2High and lastClose > last2High and barDeltaPercent > threshold and newTimeframe
    
    bearishFairValueGap = currentHigh < last2Low and lastClose < last2Low and -barDeltaPercent > threshold and newTimeframe
    
    if bullishFairValueGap
        currentAlerts.bullishFairValueGap := true
        fairValueGaps.unshift(fairValueGap.new(currentLow, last2High, BULLISH, 
            fairValueGapBox(lastTime, currentTime, currentLow, math.avg(currentLow, last2High), fairValueGapBullishColor), 
            fairValueGapBox(lastTime, currentTime, math.avg(currentLow, last2High), last2High, fairValueGapBullishColor)))
    
    if bearishFairValueGap
        currentAlerts.bearishFairValueGap := true
        fairValueGaps.unshift(fairValueGap.new(currentHigh, last2Low, BEARISH, 
            fairValueGapBox(lastTime, currentTime, currentHigh, math.avg(currentHigh, last2Low), fairValueGapBearishColor), 
            fairValueGapBox(lastTime, currentTime, math.avg(currentHigh, last2Low), last2Low, fairValueGapBearishColor)))

updateTrailingExtremes() =>
    trailing.top := math.max(high, trailing.top)
    trailing.lastTopTime := trailing.top == high ? time : trailing.lastTopTime
    trailing.bottom := math.min(low, trailing.bottom)
    trailing.lastBottomTime := trailing.bottom == low ? time : trailing.lastBottomTime

if barstate.isfirst
    if showSwingOrderBlocksInput
        for index = 1 to swingOrderBlocksSizeInput
            swingOrderBlocksBoxes.push(box.new(na, na, na, na, xloc = xloc.bar_time, extend = extend.none))
            swingOrderBlocksLabels.push(label.new(na, na, na, xloc = xloc.bar_time))
    if showInternalOrderBlocksInput
        for index = 1 to internalOrderBlocksSizeInput
            internalOrderBlocksBoxes.push(box.new(na, na, na, na, xloc = xloc.bar_time, extend = extend.none))
            internalOrderBlocksLabels.push(label.new(na, na, na, xloc = xloc.bar_time))

float volatilityMeasure = orderBlockFilterInput == "Atr" ? atrMeasure : ta.cum(ta.tr) / bar_index
bool highVolatilityBar = (high - low) >= (2 * volatilityMeasure)
float parsedHigh = highVolatilityBar ? low : high
float parsedLow = highVolatilityBar ? high : low

parsedHighs.push(parsedHigh)
parsedLows.push(parsedLow)
highs.push(high)
lows.push(low)
times.push(time)

updateTrailingExtremes()

getCurrentStructure(swingsLengthInput, false)       
getCurrentStructure(5, false, true)                  

if showEqualHighsLowsInput
    getCurrentStructure(equalHighsLowsLengthInput, true)

if showInternalsInput
    displayStructure(true)    
if showStructureInput
    displayStructure()        

deleteOrderBlocks(true)
deleteOrderBlocks(false)

if barstate.islastconfirmedhistory or barstate.islast
    if showInternalOrderBlocksInput
        drawOrderBlocks(true)
    if showSwingOrderBlocksInput
        drawOrderBlocks(false)

if showFairValueGapsInput
    deleteFairValueGaps()
    drawFairValueGaps()

alertcondition(currentAlerts.internalBullishBOS, 'Internal Bullish BOS', 'Internal Bullish BOS formed')
alertcondition(currentAlerts.internalBullishCHoCH, 'Internal Bullish CHoCH', 'Internal Bullish CHoCH formed')
alertcondition(currentAlerts.internalBearishBOS, 'Internal Bearish BOS', 'Internal Bearish BOS formed')
alertcondition(currentAlerts.internalBearishCHoCH, 'Internal Bearish CHoCH', 'Internal Bearish CHoCH formed')
alertcondition(currentAlerts.swingBullishBOS, 'Bullish BOS', 'Bullish BOS formed')
alertcondition(currentAlerts.swingBullishCHoCH, 'Bullish CHoCH', 'Bullish CHoCH formed')
alertcondition(currentAlerts.swingBearishBOS, 'Bearish BOS', 'Bearish BOS formed')
alertcondition(currentAlerts.swingBearishCHoCH, 'Bearish CHoCH', 'Bearish CHoCH formed')
alertcondition(currentAlerts.equalHighs, 'Equal Highs', 'Equal highs detected')
alertcondition(currentAlerts.equalLows, 'Equal Lows', 'Equal lows detected')
alertcondition(currentAlerts.bullishFairValueGap, 'Bullish FVG', 'Bullish FVG formed')
alertcondition(currentAlerts.bearishFairValueGap, 'Bearish FVG', 'Bearish FVG formed')

o          = 'Options'
sp1        = '       '
sp2        = '              '
hl         = 'High / Low    ' + sp1

i_mode     = input.string(         'Present'      , title = 'Mode'                   , options =['Present', 'Historical']                                              )

showMS     = true
len        = 5

iMSS       = input.bool  (           true         , title = '       MSS'     +sp1    ,   group = 'Market Structures', inline = 'M1'                                    )
cMSSbl     = input.color (color.new(#04e600, 0), title = 'bullish'                ,   group = 'Market Structures', inline = 'M1'                                    )
cMSSbr     = input.color (color.new(#ff0400, 0), title = 'bearish'                ,   group = 'Market Structures', inline = 'M1'                                    )

iBOS       = input.bool  (           true         , title = '       BOS'     +sp1    ,   group = 'Market Structures', inline = 'BS'                                    )
cBOSbl     = input.color (color.new(#04ff00, 0), title = 'bullish'                ,   group = 'Market Structures', inline = 'BS'                                    )
cBOSbr     = input.color (color.new(#ff0400, 0), title = 'bearish'                ,   group = 'Market Structures', inline = 'BS'                                    )

perc_Body  = 0.36 
bxBack     = 10   

sVimbl     = input.bool  (           true         , title = ''                       ,   group = 'Volume Imbalance' , inline = 'VI'                                    )
visVim     = 2
cVimbl     = input.color (color.new(#06b2d0,  0), title = ''                       ,   group = 'Volume Imbalance' , inline = 'VI'                                    )

showOB     = input.bool  (           true         , title = 'Show Order Blocks'      ,   group = 'Order Blocks'                                                        )
length     = 10
showBull   = 1
showBear   = 1
useBody    = input.bool  (           true         , title = 'Use Candle Body'                                                                                          )

bullCss    = input.color (color.new(#3e89fa,  0), title = 'Bullish OB  '           ,   group = 'Order Blocks'     , inline = 'bullcss'                               )
bullBrkCss = input.color (color.new(#4785f9, 85), title = 'Bullish Break  '        ,   group = 'Order Blocks'     , inline = 'bullcss'                               )

bearCss    = input.color (color.new(#FF3131,  0), title = 'Bearish OB'             ,   group = 'Order Blocks'     , inline = 'bearcss'                               )
bearBrkCss = input.color (color.new(#f9ff57, 85), title = 'Bearish Break'          ,   group = 'Order Blocks'     , inline = 'bearcss'                               )

showLabels = false
  
showLq     = input.bool  (           true         , title = 'Show Liquidity'         ,   group = 'Liquidity'                                                           )
a     = 4
visLiq     = 2
cLIQ_B     = input.color (color.rgb(255, 0, 0), title = 'Buyside Liquidity  '    ,   group = 'Liquidity'                                                           )
cLIQ_S     = input.color (color.rgb(0, 255, 4), title = 'Sellside Liquidity'     ,   group = 'Liquidity'                                                           )
      
shwFVG     = input.bool  (           true         , title = 'Show FVGs'              ,   group = 'Fair Value Gaps'                                                     )
i_BPR      = false
i_FVG      = input.string(           'FVG'        , title = o                        ,   group = 'Fair Value Gaps'  , options=['FVG', 'IFVG']                           
           ,                                                                           tooltip = 'Fair Value Gaps\nor\nImplied Fair Value Gaps'                        )
visBxs     = 2

cFVGbl     = input.color (color.new(#00e676,  0), title = 'Bullish FVG  '          ,   group = 'Fair Value Gaps'  , inline = 'FVGbl'                                 )
cFVGblBR   = input.color (color.new(#00e676,  50), title = 'Break'                  ,   group = 'Fair Value Gaps'  , inline = 'FVGbl'                                 )
cFVGbr     = input.color (color.new(#ff5252,  0), title = 'Bearish FVG '           ,   group = 'Fair Value Gaps'  , inline = 'FVGbr'                                 )
cFVGbrBR   = input.color (color.new(#FF0000,  50), title = 'Break'                  ,   group = 'Fair Value Gaps'  , inline = 'FVGbr'                                 )

n          =                      bar_index
hi         =                      high  
lo         =                      low   
tf_msec    = timeframe.in_seconds(timeframe.period) * 1000
maxSize    =        50
atr        = ta.atr(10)
per        = i_mode == 'Present' ? last_bar_index - bar_index <=  500 : true
perB       = last_bar_index - bar_index <= 1000  ? true : false
mx         = math.max(close , open)
mn         = math.min(close , open)
body       = math.abs(close - open)
meanBody   = ta.sma  (body  ,  len)
max        = useBody ?  mx  : high
min        = useBody ?  mn  : low
blBrkConf  = 0
brBrkConf  = 0
r          = color.r(chart.bg_color)
g          = color.g(chart.bg_color)
b          = color.b(chart.bg_color)
isDark     = r < 80 and g < 80 and b < 80

type ZZ 
    int   [] d
    int   [] x 
    float [] y 
    bool  [] b

type ln_d
    line  l
    int   d

type _2ln_lb
    line  l1
    line  l2
    label lb

type bx_ln
    box   b 
    line  l 

type bx_ln_lb
    box   bx
    line  ln
    label lb 

type mss 
    int     dir
    line [] l_mssBl
    line [] l_mssBr
    line [] l_bosBl
    line [] l_bosBr
    label[] lbMssBl
    label[] lbMssBr
    label[] lbBosBl
    label[] lbBosBr

type liq
    box   bx
    bool  broken
    bool  brokenTop
    bool  brokenBtm
    line  ln

type ob
    float   top       = na
    float   btm       = na
    int     loc       = bar_index
    bool    breaker   = false
    int     break_loc = na

type swing
    float y = na
    int   x = na
    bool  crossed = false

type FVG 
    box box 
    bool active = false
    int  pos = 0 

var mss MSS = mss.new(
 0
 , array.new < line  >()
 , array.new < line  >() 
 , array.new < line  >()
 , array.new < line  >()
 , array.new < label >() 
 , array.new < label >()
 , array.new < label >()
 , array.new < label >()
 )

maxVimb = 2

var _2ln_lb [] Vimbal     = array.new<  _2ln_lb >() 

var   liq   [] b_liq_B    = array.new<    liq   >(1, liq.new(box(na), false, false, false, line(na)))
var   liq   [] b_liq_S    = array.new<    liq   >(1, liq.new(box(na), false, false, false, line(na)))

var    ob   [] bullish_ob = array.new<    ob    >()
var    ob   [] bearish_ob = array.new<    ob    >()

var bx_ln_lb[] a_bx_ln_lb = array.new< bx_ln_lb >()

var FVG     [] bFVG_UP    = array.new<    FVG   >()
var FVG     [] bFVG_DN    = array.new<    FVG   >()

var FVG     [] bBPR_UP    = array.new<    FVG   >()
var FVG     [] bBPR_DN    = array.new<    FVG   >()

var  ZZ         aZZ       = 
 ZZ.new(
 array.new < int    >(maxSize,  0), 
 array.new < int    >(maxSize,  0), 
 array.new < float  >(maxSize, na),
 array.new < bool   >(maxSize, false))

method in_out(ZZ aZZ, int d, int x1, float y1, int x2, float y2, color col, bool b) =>
    aZZ.d.unshift(d), aZZ.x.unshift(x2), aZZ.y.unshift(y2), aZZ.b.unshift(b), aZZ.d.pop(), aZZ.x.pop(), aZZ.y.pop(), aZZ.b.pop()

method timeinrange(string res, string sess) => not na(time(timeframe.period, res, sess))

method setLine(line ln, int x1, float y1, int x2, float y2) => ln.set_xy1(x1, y1), ln.set_xy2(x2, y2)

method clear_aLine(line[] l) =>
    if l.size() > 0
        for i = l.size() -1 to 0
            l.pop().delete()

method clear_aLabLin(label[] l) =>
    if l.size() > 0
        for i = l.size() -1 to 0
            l.pop().delete()

method clear_aLabLin(line[] l) =>
    if l.size() > 0
        for i = l.size() -1 to 0
            l.pop().delete()

method notransp(color css) => color.rgb(color.r(css), color.g(css), color.b(css))

method display(ob id, css, break_css, str)=>
    if showOB
        if id.breaker
            a_bx_ln_lb.unshift(
             bx_ln_lb.new(
               box.new(id.loc, id.top, timenow + (tf_msec * 10), id.btm, na 
             , bgcolor = break_css
             , extend  = extend.none
             , xloc    = xloc.bar_time)
             , line (na)
             , label(na))
             )
        else
            y  = str == 'bl' ? id.btm : id.top
            s  = str == 'bl' ? label.style_label_up : label.style_label_down
            a_bx_ln_lb.unshift(
             bx_ln_lb.new(
               box(na)
             , line.new(id.loc,   y  , id.loc  + (tf_msec * 10),    y  
             , xloc    = xloc.bar_time, color=css, width=2)
             , label.new(              id.loc  + (tf_msec * 10),    y
             , text  = str == 'bl' ? '+OB' : '-OB'
             , xloc  = xloc.bar_time
             , style = s    , color = color(na)
             , textcolor=css, size  = size.small))
             )

swings(len)=>
    var os = 0
    var swing top = swing.new(na, na)
    var swing btm = swing.new(na, na)
    
    upper = ta.highest(len)
    lower = ta.lowest(len)

    os := high[len] > upper ? 0 
       :  low [len] < lower ? 1 : os

    if os == 0 and os[1] != 0
        top := swing.new(high[length], bar_index[length])
    
    if os == 1 and os[1] != 1
        btm := swing.new(low[length], bar_index[length])

    [top, btm]
            
set_lab(i, str) =>
    style = str == 'Bl' ? label.style_label_down : label.style_label_up
    txcol = str == 'Bl' ? color.lime : color.red
    label.new(math.round(math.avg(aZZ.x.get(i), n)), aZZ.y.get(i), text='BOS'
     , style=style, color=color(na), textcolor=txcol, size=size.tiny)
set_lin(i, str) =>
    color = str == 'Bl' ? color.lime : color.red
    line.new(aZZ.x.get(i), aZZ.y.get(i), n, aZZ.y.get(i), color=color, style=line.style_dotted)

draw(left, col) =>
  
    max_bars_back(time, 1000)
    var int dir= na, var int x1= na, var float y1= na, var int x2= na, var float y2= na
    
    sz       = aZZ.d.size( )
    x2      := bar_index -1
    ph       = ta.pivothigh(hi, left, 1)
    pl       = ta.pivotlow (lo, left, 1)
    if not na(ph)   
        dir := aZZ.d.get (0) 
        x1  := aZZ.x.get (0) 
        y1  := aZZ.y.get (0) 
        y2  :=      nz(hi[1])
        
        if dir <  1  
            aZZ.in_out( 1, x1, y1, x2, y2, col, true)
        else
            if dir ==  1 and ph > y1 
                aZZ.x.set(0, x2), aZZ.y.set(0, y2)
      
        if showLq and per and sz > 0
            count = 0
            st_P  = 0.
            st_B  = 0
            minP  = 0.
            maxP  = 10e6
            for i = 0 to math.min(sz, 50) -1
                if aZZ.d.get(i) ==  1 
                    if aZZ.y.get(i) > ph + (atr/a)
                        break
                    else
                        if aZZ.y.get(i) > ph - (atr/a) and aZZ.y.get(i) < ph + (atr/a)
                            count += 1
                            st_B := aZZ.x.get(i)
                            st_P := aZZ.y.get(i)
                            if aZZ.y.get(i) > minP
                                minP := aZZ.y.get(i)
                            if aZZ.y.get(i) < maxP 
                                maxP := aZZ.y.get(i)
            if count > 2
                getB = b_liq_B.get(0)
                if st_B == getB.bx.get_left()
                    getB.bx.set_top(math.avg(minP, maxP) + (atr/a))
                    getB.bx.set_rightbottom(n +10, math.avg(minP, maxP) - (atr/a))
                else
                    b_liq_B.unshift(liq.new(
                     box.new(
                       st_B, math.avg(minP, maxP) + (atr/a), n +10, math.avg(minP, maxP) - (atr/a)
                     , text = 'Buyside liquidity', text_size = size.tiny, text_halign = text.align_left
                     , text_valign = text.align_bottom, text_color = color.new(cLIQ_B, 25)
                     , bgcolor=color(na), border_color=color(na)
                      )
                     , false
                     , false
                     , false
                     , line.new(st_B, st_P, n -1, st_P, color = color.new(cLIQ_B, 0))
                      )
                     )      
                if b_liq_B.size() > visLiq
                    getLast = b_liq_B.pop()
                    getLast.bx.delete()
                    getLast.ln.delete()               
    
    if not na(pl)
        dir := aZZ.d.get (0) 
        x1  := aZZ.x.get (0) 
        y1  := aZZ.y.get (0) 
        y2  :=      nz(lo[1])
    
        if dir > -1  
            aZZ.in_out(-1, x1, y1, x2, y2, col, true)
        else
            if dir == -1 and pl < y1 
                aZZ.x.set(0, x2), aZZ.y.set(0, y2)
  
        if showLq and per and sz > 0
            count = 0
            st_P  = 0.
            st_B  = 0
            minP  = 0.
            maxP  = 10e6
            for i = 0 to math.min(sz, 50) -1
                if aZZ.d.get(i) == -1 
                    if aZZ.y.get(i) < pl - (atr/a)
                        break
                    else
                        if aZZ.y.get(i) > pl - (atr/a) and aZZ.y.get(i) < pl + (atr/a)
                            count += 1
                            st_B := aZZ.x.get(i)
                            st_P := aZZ.y.get(i)
                            if aZZ.y.get(i) > minP
                                minP := aZZ.y.get(i)
                            if aZZ.y.get(i) < maxP 
                                maxP := aZZ.y.get(i)
            if count > 2
                getB = b_liq_S.get(0)
                if st_B == getB.bx.get_left()
                    getB.bx.set_top(math.avg(minP, maxP) + (atr/a))
                    getB.bx.set_rightbottom(n +10, math.avg(minP, maxP) - (atr/a))
                else
                    b_liq_S.unshift(liq.new(
                      box.new(
                       st_B, math.avg(minP, maxP) + (atr/a), n +10, math.avg(minP, maxP) - (atr/a)
                     , text = 'Sellside liquidity', text_size = size.tiny, text_halign = text.align_left
                     , text_valign = text.align_bottom, text_color = color.new(cLIQ_S, 25)
                     , bgcolor=color(na), border_color=color(na)
                      )
                     , false
                     , false
                     , false
                     , line.new(st_B, st_P, n -1, st_P, color = color.new(cLIQ_S, 0))
                      )
                     )  
                if b_liq_S.size() > visLiq
                    getLast = b_liq_S.pop()
                    getLast.bx.delete()
                    getLast.ln.delete()            
    
    if showMS 
     
        iH = aZZ.d.get(2) ==  1 ? 2 : 1
        iL = aZZ.d.get(2) == -1 ? 2 : 1
     
        switch
          
            close > aZZ.y.get(iH) and aZZ.d.get(iH) ==  1 and MSS.dir <  1 =>
                MSS.dir :=  1 
                if i_mode == 'Present'
                    MSS.l_bosBl.clear_aLabLin(), MSS.l_bosBr.clear_aLabLin()   
                    MSS.lbBosBl.clear_aLabLin(), MSS.lbBosBr.clear_aLabLin()  
                    MSS.l_mssBl.clear_aLabLin(), MSS.l_mssBr.clear_aLabLin() 
                    MSS.lbMssBl.clear_aLabLin(), MSS.lbMssBr.clear_aLabLin() 
                
                MSS.l_mssBl.unshift(line.new (
                  aZZ.x.get(iH), aZZ.y.get(iH), n, aZZ.y.get(iH), color=cMSSbl))
                MSS.lbMssBl.unshift(label.new(
                  math.round(math.avg(aZZ.x.get(iH), n)), aZZ.y.get(iH), text ='MSS'
                  , style=label.style_label_down, size=size.tiny, color=color(na), textcolor=cMSSbl))
         
            close < aZZ.y.get(iL) and aZZ.d.get(iL) == -1 and MSS.dir > -1 =>
                MSS.dir := -1 
                if i_mode == 'Present'
                    MSS.l_bosBl.clear_aLabLin(), MSS.l_bosBr.clear_aLabLin()   
                    MSS.lbBosBl.clear_aLabLin(), MSS.lbBosBr.clear_aLabLin()  
                    MSS.l_mssBl.clear_aLabLin(), MSS.l_mssBr.clear_aLabLin() 
                    MSS.lbMssBl.clear_aLabLin(), MSS.lbMssBr.clear_aLabLin()
           
                MSS.l_mssBr.unshift(line.new (
                  aZZ.x.get(iL), aZZ.y.get(iL), n, aZZ.y.get(iL), color=cMSSbr))
                MSS.lbMssBr.unshift(label.new(
                  math.round(math.avg(aZZ.x.get(iL), n)), aZZ.y.get(iL), text ='MSS'
                  , style=label.style_label_up  , size=size.tiny, color=color(na), textcolor=cMSSbr))
            
            MSS.dir ==  1 and close > aZZ.y.get(iH) and iBOS =>
                if MSS.l_bosBl.size() > 0
                    if aZZ.y.get(iH) != MSS.l_bosBl.get(0).get_y2() and
                       aZZ.y.get(iH) != MSS.l_mssBl.get(0).get_y2()
                        MSS.l_bosBl.unshift(set_lin(iH, 'Bl')), MSS.lbBosBl.unshift(set_lab(iH, 'Bl'))
                else  
                    if aZZ.y.get(iH) != MSS.l_mssBl.get(0).get_y2()                     
                        MSS.l_bosBl.unshift(set_lin(iH, 'Bl')), MSS.lbBosBl.unshift(set_lab(iH, 'Bl'))
           
            MSS.dir == -1 and close < aZZ.y.get(iL) and iBOS =>
                if MSS.l_bosBr.size() > 0
                    if aZZ.y.get(iL) != MSS.l_bosBr.get(0).get_y2() and
                       aZZ.y.get(iL) != MSS.l_mssBr.get(0).get_y2()
                        MSS.l_bosBr.unshift(set_lin(iL, 'Br')), MSS.lbBosBr.unshift(set_lab(iL, 'Br'))
                else
                    if aZZ.y.get(iL) != MSS.l_mssBr.get(0).get_y2()                     
                        MSS.l_bosBr.unshift(set_lin(iL, 'Br')), MSS.lbBosBr.unshift(set_lab(iL, 'Br'))
        if not iMSS
            MSS.l_mssBl.get(0).set_color(color(na)), MSS.lbMssBl.get(0).set_textcolor(color(na))
            MSS.l_mssBr.get(0).set_color(color(na)), MSS.lbMssBr.get(0).set_textcolor(color(na))

draw(len, color.yellow)             

if MSS.l_bosBl.size() > 200
    MSS.l_bosBl.pop().delete()
    MSS.lbBosBl.pop().delete()

if MSS.l_bosBr.size() > 200
    MSS.l_bosBr.pop().delete()
    MSS.lbBosBr.pop().delete()

ph          = ta.pivothigh(3, 1), lPh = fixnan(ph)
pl          = ta.pivotlow (3, 1), lPl = fixnan(pl)

L_body      = 
 high - mx  < body * perc_Body and 
 mn - low   < body * perc_Body

L_bodyUP    =   body > meanBody  and L_body and close > open
L_bodyDN    =   body > meanBody  and L_body and close < open

bsNOTbodyUP = ta.barssince(not L_bodyUP)
bsNOTbodyDN = ta.barssince(not L_bodyDN)

bsIs_bodyUP = ta.barssince(    L_bodyUP)
bsIs_bodyDN = ta.barssince(    L_bodyDN)

lwst        = math.min(lPh [bsNOTbodyUP[1]], low[bsNOTbodyUP[1]])
hgst        = math.max(high[bsNOTbodyDN[1]], lPl[bsNOTbodyDN[1]])

imbalanceUP = L_bodyUP[1] and (i_FVG == 'FVG' ? low  > high[2] : low  < high[2])
imbalanceDN = L_bodyDN[1] and (i_FVG == 'FVG' ? high < low [2] : high > low [2])

vImb_Bl     = open > close[1] and high[1] > low  and close > close[1] and open > open[1] and high[1] < mn
vImb_Br     = open < close[1] and low [1] < high and close < close[1] and open < open[1] and low [1] > mx

if sVimbl
    if vImb_Bl
        Vimbal.unshift(
         _2ln_lb.new(
          line.new (n -1, mx[1], n +3, mx[1], color=cVimbl)
         , line.new (n   , mn   , n +3, mn   , color=cVimbl)
          , label.new(n +3, math.avg    (mx[1], mn), text='VI'
         , color=color(na) , textcolor=cVimbl, style=label.style_label_left)
          )
         )
    if vImb_Br
        Vimbal.unshift(
         _2ln_lb.new(
          line.new (n -1, mn[1], n +3, mn[1], color=cVimbl)
         , line.new (n   , mx   , n +3, mx   , color=cVimbl)
          , label.new(n +3, math.avg    (mn[1], mx), text='VI'
         , color=color(na) , textcolor=cVimbl, style=label.style_label_left)
          )
         )
    if Vimbal.size() > visVim 
        pop = Vimbal.pop()
        pop.l1.delete()
        pop.l2.delete()
        pop.lb.delete()

if barstate.isfirst
    for i = 0 to visBxs -1
        bFVG_UP.unshift(FVG.new(box(na), false))
        bFVG_DN.unshift(FVG.new(box(na), false))
        if i_BPR
            bBPR_UP.unshift(FVG.new(box(na), false))
            bBPR_DN.unshift(FVG.new(box(na), false))

if imbalanceUP and per and shwFVG 
    if imbalanceUP[1]
        bFVG_UP.get(0).box.set_lefttop    (n -2, low    )
        bFVG_UP.get(0).box.set_rightbottom(n +8, high[2])
    else
        bFVG_UP.unshift(FVG.new(
          box.new(
           n -2
         ,    i_FVG == 'FVG' ? low : high[2]
         , n, i_FVG == 'FVG' ? high[2] : low
         , bgcolor     = i_BPR ? color(na) : color.new(cFVGbl, 90)
         , border_color= i_BPR ? color(na) : color.new(cFVGbl, 65)
         , text_color  = i_BPR ? color(na) : color.new(cFVGbl, 65)
         , text_size=size.small
         , text=i_FVG
         )
         , true)
         )
        bFVG_UP.pop().box.delete()

if imbalanceDN and per and shwFVG 
    if imbalanceDN[1]
        bFVG_DN.get(0).box.set_lefttop    (n -2, low[2])
        bFVG_DN.get(0).box.set_rightbottom(n +8, high  )
    else
        bFVG_DN.unshift(FVG.new(
         box.new(
           n -2
         ,    i_FVG == 'FVG' ? low[2] : high
         , n, i_FVG == 'FVG' ? high   : low[2]
         , bgcolor     = i_BPR ? color(na) : color.new(cFVGbr, 90)
         , border_color= i_BPR ? color(na) : color.new(cFVGbr, 65)
         , text_color  = i_BPR ? color(na) : color.new(cFVGbr, 65)
         , text_size=size.small
         , text=i_FVG
         )
         , true)
         )
        bFVG_DN.pop().box.delete()

if i_BPR and bFVG_UP.size() > 0 and bFVG_DN.size() > 0
    bxUP    = bFVG_UP.get(0)
    bxDN    = bFVG_DN.get(0)
    bxUPbtm = bxUP.box.get_bottom()
    bxDNbtm = bxDN.box.get_bottom()
    bxUPtop = bxUP.box.get_top()
    bxDNtop = bxDN.box.get_top()
    left    = math.min(bxUP.box.get_left (), bxDN.box.get_left ())
    right   = math.max(bxUP.box.get_right(), bxDN.box.get_right())
   
    if bxUPbtm < bxDNtop and 
       bxDNbtm < bxUPbtm
        if left == bBPR_UP.get(0).box.get_left() 
            if  bBPR_UP.get(0).active
                bBPR_UP.get(0).box.set_right(right)
        else
            bBPR_UP.unshift(FVG.new(
             box.new(
              left, bxDNtop, right, bxUPbtm
              , bgcolor     = i_BPR ? color.new(cFVGbl, 90) : color(na)
              , border_color= i_BPR ? color.new(cFVGbl, 65) : color(na)
              , text_color  = i_BPR ? color.new(cFVGbl, 65) : color(na)
              , text_size=size.small
              , text= 'BPR'
              ) 
              , true
              , close > bxUPbtm ? 1 : close < bxDNtop ? -1 : 0
              )
             )
            bBPR_UP.pop().box.delete()
    
    if bxDNbtm < bxUPtop and 
       bxUPbtm < bxDNbtm 
        if left == bBPR_DN.get(0).box.get_left() 
            if  bBPR_DN.get(0).active
                bBPR_DN.get(0).box.set_right(right)
        else
            bBPR_DN.unshift(FVG.new(
             box.new(
              left, bxUPtop, right, bxDNbtm
              , bgcolor     = i_BPR ? color.new(cFVGbr, 90) : color(na)
              , border_color= i_BPR ? color.new(cFVGbr, 65) : color(na)
              , text_color  = i_BPR ? color.new(cFVGbr, 65) : color(na)
              , text_size=size.small
              , text= 'BPR'
              ) 
              , true
              , close > bxDNbtm ? 1 : close < bxUPtop ? -1 : 0
              )
             )
            bBPR_DN.pop().box.delete()

for i = 0 to math.min(bxBack, bFVG_UP.size() -1)
    getUPi = bFVG_UP.get(i)
    if getUPi.active
        getUPi.box.set_right(bar_index +8)
        if low  < getUPi.box.get_top() and not i_BPR
            getUPi.box.set_border_style(line.style_dashed)
        if low  < getUPi.box.get_bottom()
            if not i_BPR
                getUPi.box.set_bgcolor(color.new(cFVGblBR, 95))
                getUPi.box.set_border_style(line.style_dotted)
            getUPi.box.set_right(bar_index)
            getUPi.active := false

for i = 0 to math.min(bxBack, bFVG_DN.size() -1)
    getDNi = bFVG_DN.get(i)
    if getDNi.active
        getDNi.box.set_right(bar_index +8)
        if high > getDNi.box.get_bottom() and not i_BPR
            getDNi.box.set_border_style(line.style_dashed)
        if high > getDNi.box.get_top()
            if not i_BPR
                getDNi.box.set_bgcolor(color.new(cFVGbrBR, 95))
                getDNi.box.set_border_style(line.style_dotted)
            getDNi.box.set_right(bar_index)
            getDNi.active := false

if i_BPR
    for i = 0 to math.min(bxBack, bBPR_UP.size() -1)
        getUPi = bBPR_UP.get(i)
        if getUPi.active
            getUPi.box.set_right(bar_index +8)
            switch getUPi.pos 
                -1 =>
                    if high > getUPi.box.get_bottom()
                        getUPi.box.set_border_style(line.style_dashed)
                    if high > getUPi.box.get_top   ()
                        getUPi.box.set_bgcolor(color.new(cFVGblBR, 95))
                        getUPi.box.set_border_style(line.style_dotted)
                        getUPi.box.set_right(bar_index)
                        getUPi.active := false
                1 =>
                    if low  < getUPi.box.get_top   ()
                        getUPi.box.set_border_style(line.style_dashed)
                    if low  < getUPi.box.get_bottom()
                        getUPi.box.set_bgcolor(color.new(cFVGblBR, 95))
                        getUPi.box.set_border_style(line.style_dotted)
                        getUPi.box.set_right(bar_index)
                        getUPi.active := false
    
    for i = 0 to math.min(bxBack, bBPR_DN.size() -1)
        getDNi = bBPR_DN.get(i)
        if getDNi.active
            getDNi.box.set_right(bar_index +8)
            switch getDNi.pos 
                -1 =>
                    if high > getDNi.box.get_bottom()
                        getDNi.box.set_border_style(line.style_dashed)
                    if high > getDNi.box.get_top   ()
                        getDNi.box.set_bgcolor(color.new(cFVGbrBR, 95))
                        getDNi.box.set_border_style(line.style_dotted)
                        getDNi.box.set_right(bar_index)
                        getDNi.active := false
                1 =>
                    if low  < getDNi.box.get_top   ()
                        getDNi.box.set_border_style(line.style_dashed)
                    if low  < getDNi.box.get_bottom()
                        getDNi.box.set_bgcolor(color.new(cFVGbrBR, 95))
                        getDNi.box.set_border_style(line.style_dotted)
                        getDNi.box.set_right(bar_index)
                        getDNi.active := false

for i = 0 to b_liq_B.size() -1
    x = b_liq_B.get(i)
    if not x.broken
        x.bx.set_right(n +3)
        x.ln.set_x2   (n +3)
        if not x.brokenTop
            if close > x.bx.get_top   ()
                x.brokenTop := true
        if not x.brokenBtm
            if close > x.bx.get_bottom()
                x.brokenBtm := true             
        if x.brokenBtm 
            x.bx.set_bgcolor(color.new(cLIQ_B, 90))
            x.ln.delete()
            if x.brokenTop 
                x.broken := true
                x.bx.set_right(n)

for i = 0 to b_liq_S.size() -1
    x = b_liq_S.get(i)
    if not x.broken
        x.bx.set_right(n +3)
        x.ln.set_x2   (n +3)
        if not x.brokenTop
            if close < x.bx.get_top   ()
                x.brokenTop := true
        if not x.brokenBtm
            if close < x.bx.get_bottom()
                x.brokenBtm := true             
        if x.brokenTop 
            x.bx.set_bgcolor(color.new(cLIQ_S, 90))
            x.ln.delete()
            if x.brokenBtm
                x.broken := true
                x.bx.set_right(n)

[top, btm] = swings(length)

if showOB and per
    if close > top.y and not top.crossed 
        top.crossed := true
        
        minima = max[1]
        maxima = min[1]
        loc = time[1]
        
        for i = 1 to (n - top.x)-1
            minima := math.min(min[i], minima)
            maxima := minima == min[i] ? max[i] : maxima
            loc := minima == min[i] ? time[i] : loc
        bullish_ob.unshift(ob.new(maxima, minima, loc))
    
    if bullish_ob.size() > 0 
        for i = bullish_ob.size()-1 to 0
            element = bullish_ob.get(i)
            
            if not element.breaker 
                if math.min(close, open) < element.btm
                    element.breaker := true
                    element.break_loc := time
            else
                if close > element.top
                    bullish_ob.remove(i)
                else if i < showBull and top.y < element.top and top.y > element.btm 
                    blBrkConf := 1

    if blBrkConf > blBrkConf[1] and showLabels
        label.new(top.x, top.y, '▼', color = na
          , textcolor = bearCss.notransp()
          , style = label.style_label_down
          , size = size.tiny)

if showOB and per
    if close < btm.y and not btm.crossed 
        btm.crossed := true

        minima = min[1]
        maxima = max[1]
        loc = time[1]

        for i = 1 to (n - btm.x)-1
            maxima := math.max(max[i], maxima)
            minima := maxima == max[i] ? min[i] : minima
            loc := maxima == max[i] ? time[i] : loc
        bearish_ob.unshift(ob.new(maxima, minima, loc))

    if bearish_ob.size() > 0 
        for i = bearish_ob.size()-1 to 0
            element = bearish_ob.get(i)

            if not element.breaker 
                if math.max(close, open) > element.top
                    element.breaker := true
                    element.break_loc := time
            else
                if close < element.btm
                    bearish_ob.remove(i)
                else if i < showBear and btm.y > element.btm and btm.y < element.top 
                    brBrkConf := 1

    if brBrkConf > brBrkConf[1] and showLabels 
        label.new(btm.x, btm.y, '▲', color = na
          , textcolor = bullCss.notransp()
          , style = label.style_label_up
          , size = size.tiny)

if barstate.islast and showOB 
    if a_bx_ln_lb.size() > 0
        for i = a_bx_ln_lb.size() -1 to 0 
            item = a_bx_ln_lb.remove(i)
            item.bx.delete()
            item.ln.delete()
            item.lb.delete()
 
    if showBull > 0
        blSz = bullish_ob.size()
        if blSz > 0
            for i = 0 to math.min(showBull, bullish_ob.size()) -1
                get_ob = bullish_ob.get(i)
                get_ob.display(bullCss, bullBrkCss, 'bl')
   
    if showBear > 0
        brSz = bearish_ob.size()
        if brSz > 0
            for i = 0 to math.min(showBear, bearish_ob.size()) -1
                get_ob = bearish_ob.get(i)
                get_ob.display(bearCss, bearBrkCss, 'br')

emaShortLength = 20
emaLongLength = 34

ema20 = ta.ema(close, emaShortLength)
ema34 = ta.ema(close, emaLongLength)

ema20Color = close > ema20 ? color.rgb(0, 255, 0) : color.rgb(255, 0, 0)
ema34Color = close > ema34 ? color.rgb(0, 255, 0) : color.rgb(255, 0, 0)

plot(ema20, title='EMA 20', linewidth=2, color=ema20Color, force_overlay=true)
plot(ema34, title='EMA 34', linewidth=2, color=ema34Color, force_overlay=true)

showVWAP = input.bool(true, "Show VWAP", group = "VWAP Settings")
isNewSession = ta.change(time('D')) != 0

var float cumulativeVolume = na
var float cumulativePV = na
var float vwapValue = na

if bool(isNewSession)
    cumulativeVolume := volume
    cumulativePV := hl2 * volume
else
    cumulativeVolume := cumulativeVolume[1] + volume
    cumulativePV := cumulativePV[1] + hl2 * volume

vwapValue := cumulativePV / cumulativeVolume
plot(showVWAP ? vwapValue : na, title = 'VWAP', color = color.rgb(0, 0, 0), linewidth = 2, force_overlay=true)
````
