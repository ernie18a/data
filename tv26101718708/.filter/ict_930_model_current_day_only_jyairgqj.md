# ICT 9:30 Model - Current Day Only

- url: https://www.tradingview.com/script/JyAirGqj-ICT-9-30-Model-Current-Day-Only/
- type: indicator
- pine_id: PUB;326264688f9d43639ece5c0cf00d0d13
- version: 4.0

## Description

This model is designed to trade only during the New York morning session by combining:

Previous Day High (PDH)
Previous Day Low (PDL)
Previous Session High (PSH)
Previous Session Low (PSL)
Midnight Open (12M)
Liquidity Sweeps
Fair Value Gaps (FVG)
Displacement
Premium / Discount Arrays

The goal is to identify institutional liquidity grabs followed by displacement and enter on a retracement into a Fair Value Gap.

## Source Code

````pine
//@version=6
indicator("ICT 9:30 Model + Checklist - True Rejection Sweep", overlay=true, max_lines_count=200, max_labels_count=200, max_boxes_count=100, max_bars_back=5000)

tz = input.string("America/New_York", "Timezone")
prevSession = input.session("0200-0900", "PSH / PSL Session")
tradeSession = input.session("0930-1100", "Trade Window")
openingRangeSession = input.session("0930-0945", "Opening Range")

fvgExtendBars = input.int(30, "FVG Extend Bars", minval=5)
atrMultiplier = input.float(0.75, "Displacement ATR Multiplier", minval=0.1, step=0.05)

showChecklist = input.bool(true, "Show Checklist")
requireDisplacement = input.bool(false, "Require Displacement Candle")
requirePremiumDiscount = input.bool(false, "Require Premium / Discount")
oneFVGPerSweep = input.bool(true, "Only One FVG Per Sweep")

dateKey = year(time, tz) * 10000 + month(time, tz) * 100 + dayofmonth(time, tz)
newDate = ta.change(dateKey) != 0

isMidnight = hour(time, tz) == 0 and minute(time, tz) == 0
is930Open = hour(time, tz) == 9 and minute(time, tz) == 30
beforeNoon = hour(time, tz) < 12

inPrevSession = not na(time(timeframe.period, prevSession, tz))
inTradeWindow = not na(time(timeframe.period, tradeSession, tz))
inOpeningRange = not na(time(timeframe.period, openingRangeSession, tz))

isWeekday = dayofweek(time, tz) != dayofweek.saturday and dayofweek(time, tz) != dayofweek.sunday
prevBarWeekday = bar_index > 0 ? dayofweek(time[1], tz) != dayofweek.saturday and dayofweek(time[1], tz) != dayofweek.sunday : false

var float currentDayHigh = na
var float currentDayLow = na
var int currentDayHighTime = na
var int currentDayLowTime = na

var float pdh = na
var float pdl = na
var int pdhTime = na
var int pdlTime = na

if barstate.isfirst and isWeekday
    currentDayHigh := high
    currentDayLow := low
    currentDayHighTime := time
    currentDayLowTime := time

if newDate
    if prevBarWeekday and not na(currentDayHigh)
        pdh := currentDayHigh
        pdl := currentDayLow
        pdhTime := currentDayHighTime
        pdlTime := currentDayLowTime

    if isWeekday
        currentDayHigh := high
        currentDayLow := low
        currentDayHighTime := time
        currentDayLowTime := time
    else
        currentDayHigh := na
        currentDayLow := na
        currentDayHighTime := na
        currentDayLowTime := na

if isWeekday and not newDate
    if na(currentDayHigh) or high > currentDayHigh
        currentDayHigh := high
        currentDayHighTime := time

    if na(currentDayLow) or low < currentDayLow
        currentDayLow := low
        currentDayLowTime := time

var float midnightOpen = na

var float sessionHigh = na
var float sessionLow = na
var int sessionHighTime = na
var int sessionLowTime = na

var float orHigh = na
var float orLow = na
var int orHighTime = na
var int orLowTime = na

var bool bullishSweepActive = false
var bool bearishSweepActive = false
var int bullSweepBar = na
var int bearSweepBar = na
var bool bullFVGPrintedForSweep = false
var bool bearFVGPrintedForSweep = false

var line vLine12AM = na
var label lbl12AM = na
var line vLine930 = na
var label lbl930 = na

var line line12M = na
var label lbl12M = na

var line pdhLine = na
var label pdhLabel = na
var line pdlLine = na
var label pdlLabel = na

var line pshLine = na
var label pshLabel = na
var line pslLine = na
var label pslLabel = na

var line orhLine = na
var label orhLabel = na
var line orlLine = na
var label orlLabel = na

var array<label> sweepLabels = array.new_label()
var array<box> fvgBoxes = array.new_box()
var array<line> fvgMidLines = array.new_line()
var array<label> fvgLabels = array.new_label()

futureTime = time + timeframe.in_seconds(timeframe.period) * 1000 * 10

if newDate
    if not na(vLine12AM)
        line.delete(vLine12AM)
    if not na(lbl12AM)
        label.delete(lbl12AM)
    if not na(vLine930)
        line.delete(vLine930)
    if not na(lbl930)
        label.delete(lbl930)

    if not na(line12M)
        line.delete(line12M)
    if not na(lbl12M)
        label.delete(lbl12M)

    if not na(pdhLine)
        line.delete(pdhLine)
    if not na(pdhLabel)
        label.delete(pdhLabel)
    if not na(pdlLine)
        line.delete(pdlLine)
    if not na(pdlLabel)
        label.delete(pdlLabel)

    if not na(pshLine)
        line.delete(pshLine)
    if not na(pshLabel)
        label.delete(pshLabel)
    if not na(pslLine)
        line.delete(pslLine)
    if not na(pslLabel)
        label.delete(pslLabel)

    if not na(orhLine)
        line.delete(orhLine)
    if not na(orhLabel)
        label.delete(orhLabel)
    if not na(orlLine)
        line.delete(orlLine)
    if not na(orlLabel)
        label.delete(orlLabel)

    while array.size(sweepLabels) > 0
        label.delete(array.pop(sweepLabels))

    while array.size(fvgBoxes) > 0
        box.delete(array.pop(fvgBoxes))

    while array.size(fvgMidLines) > 0
        line.delete(array.pop(fvgMidLines))

    while array.size(fvgLabels) > 0
        label.delete(array.pop(fvgLabels))

    vLine12AM := na
    lbl12AM := na
    vLine930 := na
    lbl930 := na
    line12M := na
    lbl12M := na
    pdhLine := na
    pdhLabel := na
    pdlLine := na
    pdlLabel := na
    pshLine := na
    pshLabel := na
    pslLine := na
    pslLabel := na
    orhLine := na
    orhLabel := na
    orlLine := na
    orlLabel := na

    sessionHigh := na
    sessionLow := na
    sessionHighTime := na
    sessionLowTime := na

    orHigh := na
    orLow := na
    orHighTime := na
    orLowTime := na

    bullishSweepActive := false
    bearishSweepActive := false
    bullSweepBar := na
    bearSweepBar := na
    bullFVGPrintedForSweep := false
    bearFVGPrintedForSweep := false

if inPrevSession
    if na(sessionHigh) or high > sessionHigh
        sessionHigh := high
        sessionHighTime := time

    if na(sessionLow) or low < sessionLow
        sessionLow := low
        sessionLowTime := time

if inOpeningRange
    if na(orHigh) or high > orHigh
        orHigh := high
        orHighTime := time

    if na(orLow) or low < orLow
        orLow := low
        orLowTime := time

if isMidnight
    midnightOpen := open

    vLine12AM := line.new(bar_index, low, bar_index, high, extend=extend.both, color=color.white, width=2, style=line.style_dashed)
    lbl12AM := label.new(bar_index, low, "12AM", yloc=yloc.belowbar, style=label.style_label_up, color=color.white, textcolor=color.black, size=size.small)

    line12M := line.new(bar_index, midnightOpen, bar_index, midnightOpen, color=color.yellow, width=2)
    lbl12M := label.new(bar_index, midnightOpen, "12M", style=label.style_label_left, color=color.yellow, textcolor=color.black)

    if not na(pdh) and not na(pdhTime)
        pdhLine := line.new(x1=pdhTime, y1=pdh, x2=futureTime, y2=pdh, xloc=xloc.bar_time, color=color.white, width=2)
        pdhLabel := label.new(bar_index + 10, pdh, "PDH", style=label.style_label_left, color=color.white, textcolor=color.black)

    if not na(pdl) and not na(pdlTime)
        pdlLine := line.new(x1=pdlTime, y1=pdl, x2=futureTime, y2=pdl, xloc=xloc.bar_time, color=color.white, width=2)
        pdlLabel := label.new(bar_index + 10, pdl, "PDL", style=label.style_label_left, color=color.white, textcolor=color.black)

if is930Open
    vLine930 := line.new(bar_index, low, bar_index, high, extend=extend.both, color=color.white, width=2, style=line.style_dashed)
    lbl930 := label.new(bar_index, low, "9:30 OPEN", yloc=yloc.belowbar, style=label.style_label_up, color=color.white, textcolor=color.black, size=size.small)

if not na(line12M) and beforeNoon
    line.set_xy2(line12M, bar_index, midnightOpen)
    label.set_xy(lbl12M, bar_index + 5, midnightOpen)

if not na(pdhLine)
    line.set_xy1(pdhLine, pdhTime, pdh)
    line.set_xy2(pdhLine, futureTime, pdh)
    label.set_xy(pdhLabel, bar_index + 10, pdh)

if not na(pdlLine)
    line.set_xy1(pdlLine, pdlTime, pdl)
    line.set_xy2(pdlLine, futureTime, pdl)
    label.set_xy(pdlLabel, bar_index + 10, pdl)

if not na(sessionHigh) and not na(sessionHighTime)
    if na(pshLine)
        pshLine := line.new(x1=sessionHighTime, y1=sessionHigh, x2=futureTime, y2=sessionHigh, xloc=xloc.bar_time, color=color.blue, width=2)
        pshLabel := label.new(bar_index + 10, sessionHigh, "PSH", style=label.style_label_left, color=color.blue, textcolor=color.white)
    else
        line.set_xy1(pshLine, sessionHighTime, sessionHigh)
        line.set_xy2(pshLine, futureTime, sessionHigh)
        label.set_xy(pshLabel, bar_index + 10, sessionHigh)

if not na(sessionLow) and not na(sessionLowTime)
    if na(pslLine)
        pslLine := line.new(x1=sessionLowTime, y1=sessionLow, x2=futureTime, y2=sessionLow, xloc=xloc.bar_time, color=color.blue, width=2)
        pslLabel := label.new(bar_index + 10, sessionLow, "PSL", style=label.style_label_left, color=color.blue, textcolor=color.white)
    else
        line.set_xy1(pslLine, sessionLowTime, sessionLow)
        line.set_xy2(pslLine, futureTime, sessionLow)
        label.set_xy(pslLabel, bar_index + 10, sessionLow)

if not na(orHigh) and not na(orHighTime)
    if na(orhLine)
        orhLine := line.new(x1=orHighTime, y1=orHigh, x2=futureTime, y2=orHigh, xloc=xloc.bar_time, color=color.purple, width=2)
        orhLabel := label.new(bar_index + 10, orHigh, "ORH", style=label.style_label_left, color=color.purple, textcolor=color.white)
    else
        line.set_xy1(orhLine, orHighTime, orHigh)
        line.set_xy2(orhLine, futureTime, orHigh)
        label.set_xy(orhLabel, bar_index + 10, orHigh)

if not na(orLow) and not na(orLowTime)
    if na(orlLine)
        orlLine := line.new(x1=orLowTime, y1=orLow, x2=futureTime, y2=orLow, xloc=xloc.bar_time, color=color.purple, width=2)
        orlLabel := label.new(bar_index + 10, orLow, "ORL", style=label.style_label_left, color=color.purple, textcolor=color.white)
    else
        line.set_xy1(orlLine, orLowTime, orLow)
        line.set_xy2(orlLine, futureTime, orLow)
        label.set_xy(orlLabel, bar_index + 10, orLow)

above12M = not na(midnightOpen) and close > midnightOpen
below12M = not na(midnightOpen) and close < midnightOpen

// TRUE REJECTION SWEEP ONLY
// Bull reject = previous close above level, open above level, wick below level, close back above level.
bullRejectPDL = inTradeWindow and not bullishSweepActive and not bearishSweepActive and not na(pdl) and close[1] > pdl and open > pdl and low < pdl and close > pdl
bullRejectPSL = inTradeWindow and not bullishSweepActive and not bearishSweepActive and not na(sessionLow) and close[1] > sessionLow and open > sessionLow and low < sessionLow and close > sessionLow

// Bear reject = previous close below level, open below level, wick above level, close back below level.
bearRejectPDH = inTradeWindow and not bullishSweepActive and not bearishSweepActive and not na(pdh) and close[1] < pdh and open < pdh and high > pdh and close < pdh
bearRejectPSH = inTradeWindow and not bullishSweepActive and not bearishSweepActive and not na(sessionHigh) and close[1] < sessionHigh and open < sessionHigh and high > sessionHigh and close < sessionHigh

bullSweep = bullRejectPDL or bullRejectPSL
bearSweep = bearRejectPDH or bearRejectPSH

if bullSweep
    bullishSweepActive := true
    bearishSweepActive := false
    bullSweepBar := bar_index
    bullFVGPrintedForSweep := false

    bullLabelText = bullRejectPDL ? "Bull Reject PDL" : "Bull Reject PSL"
    bullLabel = label.new(bar_index, low, bullLabelText, yloc=yloc.belowbar, style=label.style_label_up, color=color.green, textcolor=color.white, size=size.small)
    array.push(sweepLabels, bullLabel)

if bearSweep
    bearishSweepActive := false
    bearishSweepActive := true
    bullSweepBar := na
    bearSweepBar := bar_index
    bearFVGPrintedForSweep := false

    bearLabelText = bearRejectPDH ? "Bear Reject PDH" : "Bear Reject PSH"
    bearLabel = label.new(bar_index, high, bearLabelText, yloc=yloc.abovebar, style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)
    array.push(sweepLabels, bearLabel)

bullFVG = low > high[2]
bearFVG = high < low[2]

atrValue = ta.atr(14)
middleCandleRange = high[1] - low[1]

bullDisplacement = close[1] > open[1] and middleCandleRange > atrValue[1] * atrMultiplier
bearDisplacement = close[1] < open[1] and middleCandleRange > atrValue[1] * atrMultiplier

sessionMid = not na(sessionHigh) and not na(sessionLow) ? (sessionHigh + sessionLow) / 2 : na

bullDiscount = not na(sessionMid) and low < sessionMid
bearPremium = not na(sessionMid) and high > sessionMid

validBullDisplacement = not requireDisplacement or bullDisplacement
validBearDisplacement = not requireDisplacement or bearDisplacement

validBullPD = not requirePremiumDiscount or bullDiscount
validBearPD = not requirePremiumDiscount or bearPremium

validBullFVG = inTradeWindow and bullishSweepActive and not na(bullSweepBar) and bar_index > bullSweepBar and bullFVG and validBullDisplacement and validBullPD and (not oneFVGPerSweep or not bullFVGPrintedForSweep)
validBearFVG = inTradeWindow and bearishSweepActive and not na(bearSweepBar) and bar_index > bearSweepBar and bearFVG and validBearDisplacement and validBearPD and (not oneFVGPerSweep or not bearFVGPrintedForSweep)

if validBullFVG
    fvgTop = low
    fvgBottom = high[2]
    fvgMid = (fvgTop + fvgBottom) / 2

    newBox = box.new(bar_index - 2, fvgTop, bar_index + fvgExtendBars, fvgBottom, bgcolor=color.new(color.green, 85), border_color=color.green)
    newLine = line.new(bar_index - 2, fvgMid, bar_index + fvgExtendBars, fvgMid, color=color.green, width=2, style=line.style_dashed)
    newLabel = label.new(bar_index, fvgMid, "Bull FVG 50%", style=label.style_label_up, color=color.green, textcolor=color.white)

    array.push(fvgBoxes, newBox)
    array.push(fvgMidLines, newLine)
    array.push(fvgLabels, newLabel)

    bullFVGPrintedForSweep := true
    if oneFVGPerSweep
        bullishSweepActive := false

if validBearFVG
    fvgTop = low[2]
    fvgBottom = high
    fvgMid = (fvgTop + fvgBottom) / 2

    newBox = box.new(bar_index - 2, fvgTop, bar_index + fvgExtendBars, fvgBottom, bgcolor=color.new(color.red, 85), border_color=color.red)
    newLine = line.new(bar_index - 2, fvgMid, bar_index + fvgExtendBars, fvgMid, color=color.red, width=2, style=line.style_dashed)
    newLabel = label.new(bar_index, fvgMid, "Bear FVG 50%", style=label.style_label_down, color=color.red, textcolor=color.white)

    array.push(fvgBoxes, newBox)
    array.push(fvgMidLines, newLine)
    array.push(fvgLabels, newLabel)

    bearFVGPrintedForSweep := true
    if oneFVGPerSweep
        bearishSweepActive := false

var table checklist = table.new(position.top_right, 3, 9, border_width=1)

checkmark(condition) =>
    condition ? "✅" : "❌"

statusColor(condition) =>
    condition ? color.new(color.green, 0) : color.new(color.red, 0)

bullSetup = validBullFVG
bearSetup = validBearFVG
highProbability = bullSetup or bearSetup

if showChecklist
    table.cell(checklist, 0, 0, "ICT 9:30 Checklist", text_color=color.white, bgcolor=color.black)
    table.cell(checklist, 1, 0, "Bullish", text_color=color.white, bgcolor=color.black)
    table.cell(checklist, 2, 0, "Bearish", text_color=color.white, bgcolor=color.black)

    table.cell(checklist, 0, 1, "Trading Window", text_color=color.white)
    table.cell(checklist, 1, 1, checkmark(inTradeWindow), bgcolor=statusColor(inTradeWindow))
    table.cell(checklist, 2, 1, checkmark(inTradeWindow), bgcolor=statusColor(inTradeWindow))

    table.cell(checklist, 0, 2, "12M Info", text_color=color.white)
    table.cell(checklist, 1, 2, checkmark(above12M), bgcolor=statusColor(above12M))
    table.cell(checklist, 2, 2, checkmark(below12M), bgcolor=statusColor(below12M))

    table.cell(checklist, 0, 3, "True Reject Level", text_color=color.white)
    table.cell(checklist, 1, 3, checkmark(bullSweep or bullishSweepActive), bgcolor=statusColor(bullSweep or bullishSweepActive))
    table.cell(checklist, 2, 3, checkmark(bearSweep or bearishSweepActive), bgcolor=statusColor(bearSweep or bearishSweepActive))

    table.cell(checklist, 0, 4, "Displacement", text_color=color.white)
    table.cell(checklist, 1, 4, checkmark(bullDisplacement), bgcolor=statusColor(bullDisplacement))
    table.cell(checklist, 2, 4, checkmark(bearDisplacement), bgcolor=statusColor(bearDisplacement))

    table.cell(checklist, 0, 5, "FVG Formed", text_color=color.white)
    table.cell(checklist, 1, 5, checkmark(bullFVG), bgcolor=statusColor(bullFVG))
    table.cell(checklist, 2, 5, checkmark(bearFVG), bgcolor=statusColor(bearFVG))

    table.cell(checklist, 0, 6, "Premium / Discount", text_color=color.white)
    table.cell(checklist, 1, 6, checkmark(bullDiscount), bgcolor=statusColor(bullDiscount))
    table.cell(checklist, 2, 6, checkmark(bearPremium), bgcolor=statusColor(bearPremium))

    table.cell(checklist, 0, 7, "Final Result", text_color=color.white, bgcolor=color.black)
    table.cell(checklist, 1, 7, bullSetup ? "HIGH PROB BUY" : "NOT READY", text_color=color.white, bgcolor=bullSetup ? color.green : color.gray)
    table.cell(checklist, 2, 7, bearSetup ? "HIGH PROB SELL" : "NOT READY", text_color=color.white, bgcolor=bearSetup ? color.red : color.gray)

    table.cell(checklist, 0, 8, "Decision", text_color=color.white, bgcolor=color.black)
    table.cell(checklist, 1, 8, highProbability ? "SETUP VALID" : "WAIT / AVOID", text_color=color.white, bgcolor=highProbability ? color.green : color.red)
    table.cell(checklist, 2, 8, highProbability ? "SETUP VALID" : "WAIT / AVOID", text_color=color.white, bgcolor=highProbability ? color.green : color.red)

alertcondition(validBullFVG, "Bullish Setup Ready", "Bullish FVG after true PDL/PSL rejection.")
alertcondition(validBearFVG, "Bearish Setup Ready", "Bearish FVG after true PDH/PSH rejection.")
````
