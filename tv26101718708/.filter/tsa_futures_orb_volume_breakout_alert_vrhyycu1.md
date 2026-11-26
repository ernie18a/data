# TSA futures ORB Volume Breakout Alert

- url: https://www.tradingview.com/script/vrHyyCU1-TSA-futures-ORB-Volume-Breakout-Alert/
- type: indicator
- pine_id: PUB;ca4e0ccf202f4f7aab0bbd750dafcaec
- version: 4.0

## Description

15/30 Minute ORB Volume Breakout

This indicator is built for traders who use the Opening Range Breakout strategy and want volume confirmation before acting on a move.

It plots a selectable 15-minute or 30-minute Opening Range for the NY, London, or Asia session, then watches for breakouts using 5-minute volume confirmation. When price breaks above the ORB high or below the ORB low with increased volume, the indicator marks the chart with ORB VOL BUY or ORB VOL SELL and can trigger TradingView alerts.

Features include:
[list]
[*]Selectable 15m or 30m ORB
[*]Session dropdown for NY, London, and Asia
[*]Breakout signals based on 5-minute volume expansion
[*]ORB HIGH, ORB LOW, and MID ORB levels
[*]3 upside and 3 downside profit targets based on ORB range
[*]NY-only PMH/PML and PDH/PDL levels
[*]FTFC dashboard showing 1H, 4H, Daily, Weekly, and Monthly direction
[*]Dashboard placement options
[*]TradingView alert support for breakout-volume buy/sell signals
[/list]

This script is intended to help identify high-volume ORB breakout opportunities while keeping key session levels, targets, and higher-timeframe context visible on the chart.

This indicator is best used for [symbol="SEED_ALEXDRAYM_SHORTINTEREST2:NQ"]SEED_ALEXDRAYM_SHORTINTEREST2:NQ[/symbol], $MNQ, [symbol="NYSE:ES"]NYSE:ES[/symbol], [symbol="MSTAR:MES"]MSTAR:MES[/symbol], [symbol="CSE:GC"]CSE:GC[/symbol], [symbol="AMEX:MGC"]AMEX:MGC[/symbol], but can also be used for others at your discretion. 

*Feedback is welcome

## Source Code

````pine
// Custom ORB Volume Alert
//@version=6
indicator("ORB Volume Breakout Alert", shorttitle="ORB Vol Alert", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=50)

// === Inputs ===
tz                 = input.string("America/New_York", "Timezone")
marketSession      = input.string("NY", "Market Session", options=["NY", "ASIA", "London"])
orbType            = input.string("30", "ORB Length", options=["30", "15"])
dashboardLocation  = input.string("Top Right", "Dashboard Location", options=["Top Right", "Bottom Right"])

volLen             = input.int(20, "Volume Average Length", minval=1)
volMult            = input.float(1.5, "Breakout Volume Multiplier", minval=0.1, step=0.1)

tpStep             = input.float(0.5, "Target Step - ORB Range Multiple", minval=0.1, step=0.1)
labelOffset        = input.int(1, "Target Labels Left Of ORB Start", minval=0, maxval=20)

showMid            = input.bool(true, "Show ORB Midpoint")
showTargets        = input.bool(true, "Show 3 Profit Targets")
showSignals        = input.bool(true, "Show Breakout Labels")
showDashboard      = input.bool(true, "Show Dashboard")

showFvgOnCandles   = input.bool(true, "Show Current Timeframe FVG")
fvgDisplayCount    = input.string("3", "FVGs To Show", options=["1", "2", "3", "4", "5"])
removeFilledFvgs   = input.bool(true, "Remove Filled FVGs")
showFvgMidpoint    = input.bool(true, "Show FVG Midpoint")
fvgFillTransp      = input.int(88, "FVG Fill Transparency", minval=0, maxval=100)
fvgBorderTransp    = input.int(35, "FVG Border Transparency", minval=0, maxval=100)

fvgMaxCount = fvgDisplayCount == "1" ? 1 : fvgDisplayCount == "2" ? 2 : fvgDisplayCount == "3" ? 3 : fvgDisplayCount == "4" ? 4 : 5

// === Helpers ===
priceText(_name, _price) =>
    _name + "  " + (na(_price) ? "-" : str.tostring(_price, format.mintick))

clearTargets(_lines, _labels) =>
    if array.size(_lines) > 0
        for i = 0 to array.size(_lines) - 1
            line.delete(array.get(_lines, i))
    if array.size(_labels) > 0
        for i = 0 to array.size(_labels) - 1
            label.delete(array.get(_labels, i))
    array.clear(_lines)
    array.clear(_labels)

addTarget(_lines, _labels, _x, _price, _text, _color) =>
    newLine = line.new(_x, _price, bar_index, _price, extend=extend.right, color=_color, style=line.style_dashed, width=1)
    newLabel = label.new(_x, _price, _text, style=label.style_label_right, color=_color, textcolor=color.white, size=size.small, textalign=text.align_center)
    array.push(_lines, newLine)
    array.push(_labels, newLabel)

updateRightLabel(_label, _price, _text) =>
    if not na(_label)
        label.set_x(_label, bar_index + 1)
        label.set_y(_label, _price)
        label.set_text(_label, _text)

chartTfName() =>
    timeframe.isminutes and timeframe.multiplier < 60 ? str.tostring(timeframe.multiplier) + "m" :
     timeframe.isminutes ? str.tostring(timeframe.multiplier / 60.0, "#.##") + "H" :
     timeframe.isdaily ? "D" :
     timeframe.isweekly ? "W" :
     timeframe.ismonthly ? "M" :
     timeframe.period

ftfcDir(_open) =>
    na(_open) ? 0 : close >= _open ? 1 : -1

ftfcText(_dir) =>
    _dir == 1 ? "UP" : _dir == -1 ? "DOWN" : "-"

ftfcBg(_dir) =>
    _dir == 1 ? color.new(color.green, 15) : _dir == -1 ? color.new(color.red, 15) : color.new(color.gray, 45)

dashInfoRow(_tbl, _row, _name, _value) =>
    table.cell(_tbl, 0, _row, _name, text_color=color.white, bgcolor=color.new(color.black, 30), text_size=size.small)
    table.cell(_tbl, 1, _row, _value, text_color=color.white, bgcolor=color.new(color.black, 45), text_size=size.small)
    for c = 2 to 6
        table.cell(_tbl, c, _row, "", bgcolor=color.new(color.black, 45))

dashFtfcValue(_tbl, _col, _dir) =>
    table.cell(_tbl, _col, 4, ftfcText(_dir), text_color=color.white, bgcolor=ftfcBg(_dir), text_size=size.small)

// === FVG Storage ===
var box[] fvgBoxes = array.new_box()
var label[] fvgLabels = array.new_label()
var line[] fvgMidLines = array.new_line()
var int[] fvgDirs = array.new_int()
var float[] fvgTops = array.new_float()
var float[] fvgBottoms = array.new_float()
var int[] fvgLeftTimes = array.new_int()

deleteFvgAt(_idx) =>
    curBox = array.get(fvgBoxes, _idx)
    curLabel = array.get(fvgLabels, _idx)
    curMidLine = array.get(fvgMidLines, _idx)

    if not na(curBox)
        box.delete(curBox)
    if not na(curLabel)
        label.delete(curLabel)
    if not na(curMidLine)
        line.delete(curMidLine)

    array.remove(fvgBoxes, _idx)
    array.remove(fvgLabels, _idx)
    array.remove(fvgMidLines, _idx)
    array.remove(fvgDirs, _idx)
    array.remove(fvgTops, _idx)
    array.remove(fvgBottoms, _idx)
    array.remove(fvgLeftTimes, _idx)

clearAllFvgs() =>
    while array.size(fvgBoxes) > 0
        deleteFvgAt(0)

trimFvgsToMax(_maxCount) =>
    while array.size(fvgBoxes) > _maxCount
        deleteFvgAt(array.size(fvgBoxes) - 1)

addFvg(_dir, _top, _bottom, _leftTime) =>
    fvgColor = _dir == 1 ? color.green : color.red
    fvgText = chartTfName() + (_dir == 1 ? " B FVG" : " S FVG")
    mid = (_top + _bottom) / 2.0

    newBox = box.new(left=_leftTime, top=_top, right=time, bottom=_bottom, xloc=xloc.bar_time, extend=extend.right, bgcolor=color.new(fvgColor, fvgFillTransp), border_color=color.new(fvgColor, fvgBorderTransp), border_width=1)
    newLabel = label.new(bar_index + 1, mid, fvgText, style=label.style_label_left, color=fvgColor, textcolor=color.white, size=size.tiny)

    line newMidLine = na
    if showFvgMidpoint
        newMidLine := line.new(_leftTime, mid, time, mid, xloc=xloc.bar_time, extend=extend.right, color=color.new(fvgColor, 0), style=line.style_dashed, width=1)

    array.unshift(fvgBoxes, newBox)
    array.unshift(fvgLabels, newLabel)
    array.unshift(fvgMidLines, newMidLine)
    array.unshift(fvgDirs, _dir)
    array.unshift(fvgTops, _top)
    array.unshift(fvgBottoms, _bottom)
    array.unshift(fvgLeftTimes, _leftTime)

updateFvgs() =>
    i = array.size(fvgBoxes) - 1

    while i >= 0
        curBox = array.get(fvgBoxes, i)
        curLabel = array.get(fvgLabels, i)
        curMidLine = array.get(fvgMidLines, i)
        dir = array.get(fvgDirs, i)
        top = array.get(fvgTops, i)
        bottom = array.get(fvgBottoms, i)
        leftTime = array.get(fvgLeftTimes, i)
        filled = removeFilledFvgs and ((dir == 1 and low <= bottom) or (dir == -1 and high >= top))

        if filled
            deleteFvgAt(i)
        else
            fvgColor = dir == 1 ? color.green : color.red
            fvgText = chartTfName() + (dir == 1 ? " B FVG" : " S FVG")
            mid = (top + bottom) / 2.0

            if not na(curBox)
                box.set_right(curBox, time)
                box.set_bgcolor(curBox, color.new(fvgColor, fvgFillTransp))
                box.set_border_color(curBox, color.new(fvgColor, fvgBorderTransp))

            if not na(curLabel)
                label.set_x(curLabel, bar_index + 1)
                label.set_y(curLabel, mid)
                label.set_text(curLabel, fvgText)
                label.set_color(curLabel, fvgColor)

            if showFvgMidpoint
                if na(curMidLine)
                    curMidLine := line.new(leftTime, mid, time, mid, xloc=xloc.bar_time, extend=extend.right, color=color.new(fvgColor, 0), style=line.style_dashed, width=1)
                    array.set(fvgMidLines, i, curMidLine)
                else
                    line.set_y1(curMidLine, mid)
                    line.set_y2(curMidLine, mid)
                    line.set_x2(curMidLine, time)
                    line.set_color(curMidLine, color.new(fvgColor, 0))
            else
                if not na(curMidLine)
                    line.delete(curMidLine)
                    array.set(fvgMidLines, i, na)

        i -= 1

// === Current Timeframe FVG Detection ===
if not showFvgOnCandles
    clearAllFvgs()
else
    updateFvgs()

    bullFvg = barstate.isconfirmed and not na(high[2]) and low > high[2]
    bearFvg = barstate.isconfirmed and not na(low[2]) and high < low[2]

    if bullFvg
        addFvg(1, low, high[2], time[2])

    if bearFvg
        addFvg(-1, low[2], high, time[2])

    trimFvgsToMax(fvgMaxCount)

// === Session Windows ===
orbWindow = marketSession == "NY" ? (orbType == "30" ? "0930-1000" : "0930-0945") :
     marketSession == "London" ? (orbType == "30" ? "0300-0330" : "0300-0315") :
     orbType == "30" ? "2000-2030" : "2000-2015"

tradeWindow = marketSession == "NY" ? "0930-1600" :
     marketSession == "London" ? "0300-1130" :
     ""

asiaTrade1 = "2000-2359"
asiaTrade2 = "0000-0200"

inOrb = not na(time(timeframe.period, orbWindow, tz))
inTrade = marketSession == "ASIA" ?
     (not na(time(timeframe.period, asiaTrade1, tz)) or not na(time(timeframe.period, asiaTrade2, tz))) :
     not na(time(timeframe.period, tradeWindow, tz))

newSession = inTrade and not inTrade[1]
orbJustStarted = inOrb and not inOrb[1]
orbJustEnded = not inOrb and inOrb[1]

// === Previous Day High / Low, NY Only ===
pdHighRaw = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_off)
pdLowRaw = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_off)

dayChange = ta.change(time("D"))
newDay = not na(dayChange) and dayChange != 0

var line pdHighLine = na
var line pdLowLine = na
var label pdHighLabel = na
var label pdLowLabel = na

newNyDailyLevels = marketSession == "NY" and (newDay or na(pdHighLine)) and not na(pdHighRaw) and not na(pdLowRaw)

if newNyDailyLevels
    if not na(pdHighLine)
        line.delete(pdHighLine)
    if not na(pdLowLine)
        line.delete(pdLowLine)
    if not na(pdHighLabel)
        label.delete(pdHighLabel)
    if not na(pdLowLabel)
        label.delete(pdLowLabel)

    pdHighLine := line.new(bar_index, pdHighRaw, bar_index, pdHighRaw, extend=extend.right, color=color.new(color.blue, 0), style=line.style_dashed, width=1)
    pdLowLine := line.new(bar_index, pdLowRaw, bar_index, pdLowRaw, extend=extend.right, color=color.new(color.orange, 0), style=line.style_dashed, width=1)

    pdHighLabel := label.new(bar_index + 1, pdHighRaw, priceText("PDH", pdHighRaw), style=label.style_label_left, color=color.new(color.blue, 0), textcolor=color.white, size=size.small, textalign=text.align_center)
    pdLowLabel := label.new(bar_index + 1, pdLowRaw, priceText("PDL", pdLowRaw), style=label.style_label_left, color=color.new(color.orange, 0), textcolor=color.white, size=size.small, textalign=text.align_center)

if marketSession == "NY" and not na(pdHighLine)
    line.set_y1(pdHighLine, pdHighRaw)
    line.set_y2(pdHighLine, pdHighRaw)
    line.set_y1(pdLowLine, pdLowRaw)
    line.set_y2(pdLowLine, pdLowRaw)
    updateRightLabel(pdHighLabel, pdHighRaw, priceText("PDH", pdHighRaw))
    updateRightLabel(pdLowLabel, pdLowRaw, priceText("PDL", pdLowRaw))

// === NY Premarket High / Low ===
inPremarket = marketSession == "NY" and not na(time(timeframe.period, "0400-0930", tz))
pmJustStarted = inPremarket and not inPremarket[1]
pmJustEnded = not inPremarket and inPremarket[1]

var float pmHigh = na
var float pmLow = na
var bool pmLocked = false
var int pmStartBar = na
var line pmHighLine = na
var line pmLowLine = na
var label pmHighLabel = na
var label pmLowLabel = na

if pmJustStarted
    pmHigh := high
    pmLow := low
    pmLocked := false
    pmStartBar := bar_index

    if not na(pmHighLine)
        line.delete(pmHighLine)
    if not na(pmLowLine)
        line.delete(pmLowLine)
    if not na(pmHighLabel)
        label.delete(pmHighLabel)
    if not na(pmLowLabel)
        label.delete(pmLowLabel)

    pmHighLine := na
    pmLowLine := na
    pmHighLabel := na
    pmLowLabel := na

if inPremarket
    pmHigh := na(pmHigh) ? high : math.max(pmHigh, high)
    pmLow := na(pmLow) ? low : math.min(pmLow, low)

if pmJustEnded and not na(pmHigh) and not na(pmLow)
    pmLocked := true
    lineStart = na(pmStartBar) ? bar_index : pmStartBar

    pmHighLine := line.new(lineStart, pmHigh, bar_index, pmHigh, extend=extend.right, color=color.new(color.aqua, 0), style=line.style_dashed, width=1)
    pmLowLine := line.new(lineStart, pmLow, bar_index, pmLow, extend=extend.right, color=color.new(color.fuchsia, 0), style=line.style_dashed, width=1)

    pmHighLabel := label.new(bar_index + 1, pmHigh, priceText("PMH", pmHigh), style=label.style_label_left, color=color.new(color.aqua, 0), textcolor=color.black, size=size.small, textalign=text.align_center)
    pmLowLabel := label.new(bar_index + 1, pmLow, priceText("PML", pmLow), style=label.style_label_left, color=color.new(color.fuchsia, 0), textcolor=color.white, size=size.small, textalign=text.align_center)

if pmLocked
    updateRightLabel(pmHighLabel, pmHigh, priceText("PMH", pmHigh))
    updateRightLabel(pmLowLabel, pmLow, priceText("PML", pmLow))

// === ORB State ===
var float orbHigh = na
var float orbLow = na
var bool orbLocked = false
var bool alertedLong = false
var bool alertedShort = false
var int orbStartBar = na
var int orbEndBar = na

var box orbBox = na
var line orbHighLine = na
var line orbLowLine = na
var line orbMidLine = na
var label orbHighLabel = na
var label orbLowLabel = na
var label orbMidLabel = na
var line[] targetLines = array.new_line()
var label[] targetLabels = array.new_label()

// === Reset At New Session ===
if newSession
    orbHigh := na
    orbLow := na
    orbLocked := false
    alertedLong := false
    alertedShort := false
    orbStartBar := na
    orbEndBar := na

    if not na(orbBox)
        box.delete(orbBox)
    if not na(orbHighLine)
        line.delete(orbHighLine)
    if not na(orbLowLine)
        line.delete(orbLowLine)
    if not na(orbMidLine)
        line.delete(orbMidLine)
    if not na(orbHighLabel)
        label.delete(orbHighLabel)
    if not na(orbLowLabel)
        label.delete(orbLowLabel)
    if not na(orbMidLabel)
        label.delete(orbMidLabel)

    clearTargets(targetLines, targetLabels)

    orbBox := na
    orbHighLine := na
    orbLowLine := na
    orbMidLine := na
    orbHighLabel := na
    orbLowLabel := na
    orbMidLabel := na

// === Build ORB Range ===
if orbJustStarted
    orbStartBar := bar_index
    orbHigh := high
    orbLow := low
    orbLocked := false

if inOrb
    orbHigh := na(orbHigh) ? high : math.max(orbHigh, high)
    orbLow := na(orbLow) ? low : math.min(orbLow, low)
    orbLocked := false

    if na(orbBox)
        orbBox := box.new(left=orbStartBar, top=orbHigh, right=bar_index, bottom=orbLow, bgcolor=color.new(color.yellow, 90), border_color=color.new(color.yellow, 35), border_width=1)
    else
        box.set_right(orbBox, bar_index)
        box.set_top(orbBox, orbHigh)
        box.set_bottom(orbBox, orbLow)

if orbJustEnded and not na(orbHigh) and not na(orbLow)
    orbLocked := true
    orbEndBar := bar_index - 1
    if not na(orbBox)
        box.set_right(orbBox, orbEndBar)

// === ORB Calculations ===
afterOrb = inTrade and orbLocked and not inOrb
orbRange = orbHigh - orbLow
orbMid = (orbHigh + orbLow) / 2.0

longTP1 = orbHigh + orbRange * tpStep
longTP2 = orbHigh + orbRange * tpStep * 2.0
longTP3 = orbHigh + orbRange * tpStep * 3.0

shortTP1 = orbLow - orbRange * tpStep
shortTP2 = orbLow - orbRange * tpStep * 2.0
shortTP3 = orbLow - orbRange * tpStep * 3.0

// === Draw ORB Lines And Target Labels ===
if orbLocked and na(orbHighLine)
    lineStart = na(orbStartBar) ? bar_index : orbStartBar
    targetX = math.max(0, lineStart - labelOffset)

    orbHighLine := line.new(lineStart, orbHigh, bar_index, orbHigh, extend=extend.right, color=color.green, width=2)
    orbLowLine := line.new(lineStart, orbLow, bar_index, orbLow, extend=extend.right, color=color.red, width=2)

    orbHighLabel := label.new(bar_index + 1, orbHigh, priceText("ORB HIGH", orbHigh), style=label.style_label_left, color=color.green, textcolor=color.white, size=size.small, textalign=text.align_center)
    orbLowLabel := label.new(bar_index + 1, orbLow, priceText("ORB LOW", orbLow), style=label.style_label_left, color=color.red, textcolor=color.white, size=size.small, textalign=text.align_center)

    if showMid
        orbMidLine := line.new(lineStart, orbMid, bar_index, orbMid, extend=extend.right, color=color.gray, style=line.style_dashed, width=2)
        orbMidLabel := label.new(bar_index + 1, orbMid, priceText("MID ORB", orbMid), style=label.style_label_left, color=color.gray, textcolor=color.white, size=size.small, textalign=text.align_center)

    if showTargets
        addTarget(targetLines, targetLabels, targetX, longTP1, "1  " + str.tostring(longTP1, format.mintick), color.green)
        addTarget(targetLines, targetLabels, targetX, longTP2, "2  " + str.tostring(longTP2, format.mintick), color.green)
        addTarget(targetLines, targetLabels, targetX, longTP3, "3  " + str.tostring(longTP3, format.mintick), color.green)
        addTarget(targetLines, targetLabels, targetX, shortTP1, "1  " + str.tostring(shortTP1, format.mintick), color.red)
        addTarget(targetLines, targetLabels, targetX, shortTP2, "2  " + str.tostring(shortTP2, format.mintick), color.red)
        addTarget(targetLines, targetLabels, targetX, shortTP3, "3  " + str.tostring(shortTP3, format.mintick), color.red)

if orbLocked
    updateRightLabel(orbHighLabel, orbHigh, priceText("ORB HIGH", orbHigh))
    updateRightLabel(orbLowLabel, orbLow, priceText("ORB LOW", orbLow))
    updateRightLabel(orbMidLabel, orbMid, priceText("MID ORB", orbMid))

plot(orbLocked ? orbHigh : na, title="ORB HIGH Price Tag", color=color.green, display=display.price_scale)
plot(orbLocked ? orbLow : na, title="ORB LOW Price Tag", color=color.red, display=display.price_scale)
plot(orbLocked and showMid ? orbMid : na, title="MID ORB Price Tag", color=color.gray, display=display.price_scale)
plot(marketSession == "NY" and pmLocked ? pmHigh : na, title="PMH Price Tag", color=color.aqua, display=display.price_scale)
plot(marketSession == "NY" and pmLocked ? pmLow : na, title="PML Price Tag", color=color.fuchsia, display=display.price_scale)
plot(marketSession == "NY" ? pdHighRaw : na, title="PDH Price Tag", color=color.blue, display=display.price_scale)
plot(marketSession == "NY" ? pdLowRaw : na, title="PDL Price Tag", color=color.orange, display=display.price_scale)

// === Breakout Volume Logic ===
volAvg = ta.sma(volume[1], volLen)
volRatio = not na(volAvg) and volAvg > 0 ? volume / volAvg : na
breakoutVolume = afterOrb and barstate.isconfirmed and not na(volRatio) and volRatio >= volMult

reenteredOrb = afterOrb and close <= orbHigh and close >= orbLow

if reenteredOrb
    alertedLong := false
    alertedShort := false

longVolumeBreakout = breakoutVolume and close > orbHigh and not alertedLong
shortVolumeBreakout = breakoutVolume and close < orbLow and not alertedShort
anyVolumeBreakout = longVolumeBreakout or shortVolumeBreakout

if longVolumeBreakout
    alertedLong := true
    alertedShort := false

if shortVolumeBreakout
    alertedShort := true
    alertedLong := false

plotshape(showSignals and longVolumeBreakout, title="ORB VOL BUY", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white, text="ORB VOL BUY", size=size.small)
plotshape(showSignals and shortVolumeBreakout, title="ORB VOL SELL", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, text="ORB VOL SELL", size=size.small)

// === Alerts ===
alertcondition(anyVolumeBreakout, "ORB Breakout Volume Alert", "ORB breakout volume on {{ticker}}. Close: {{close}} Volume: {{volume}}")
alertcondition(longVolumeBreakout, "ORB VOL BUY", "ORB VOL BUY on {{ticker}}. Close: {{close}} Volume: {{volume}}")
alertcondition(shortVolumeBreakout, "ORB VOL SELL", "ORB VOL SELL on {{ticker}}. Close: {{close}} Volume: {{volume}}")

if longVolumeBreakout
    alert("ORB VOL BUY: " + syminfo.ticker + " | Close: " + str.tostring(close, format.mintick) + " | Volume: " + str.tostring(volRatio, "#.##") + "x avg", alert.freq_once_per_bar_close)

if shortVolumeBreakout
    alert("ORB VOL SELL: " + syminfo.ticker + " | Close: " + str.tostring(close, format.mintick) + " | Volume: " + str.tostring(volRatio, "#.##") + "x avg", alert.freq_once_per_bar_close)

// === FTFC Dashboard Data ===
m30Open = request.security(syminfo.tickerid, "30", open, lookahead=barmerge.lookahead_off)
h1Open = request.security(syminfo.tickerid, "60", open, lookahead=barmerge.lookahead_off)
h4Open = request.security(syminfo.tickerid, "240", open, lookahead=barmerge.lookahead_off)
dOpen = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_off)
wOpen = request.security(syminfo.tickerid, "W", open, lookahead=barmerge.lookahead_off)
mOpen = request.security(syminfo.tickerid, "M", open, lookahead=barmerge.lookahead_off)

m30Dir = ftfcDir(m30Open)
h1Dir = ftfcDir(h1Open)
h4Dir = ftfcDir(h4Open)
dDir = ftfcDir(dOpen)
wDir = ftfcDir(wOpen)
mDir = ftfcDir(mOpen)

// === Combined Dashboard ===
dashPos = dashboardLocation == "Top Right" ? position.top_right : position.bottom_right
var table dashboard = table.new(dashPos, 7, 5, border_width=1)

if showDashboard and barstate.islast
    table.cell(dashboard, 0, 0, "Session:", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=size.small)
    table.cell(dashboard, 1, 0, marketSession, text_color=color.white, bgcolor=color.new(color.black, 30), text_size=size.small)
    table.cell(dashboard, 2, 0, "ORB:", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=size.small)
    table.cell(dashboard, 3, 0, orbType + " min", text_color=color.white, bgcolor=color.new(color.black, 30), text_size=size.small)
    table.cell(dashboard, 4, 0, "", bgcolor=color.new(color.black, 30))
    table.cell(dashboard, 5, 0, "", bgcolor=color.new(color.black, 30))
    table.cell(dashboard, 6, 0, "", bgcolor=color.new(color.black, 30))

    dashInfoRow(dashboard, 1, "High:", na(orbHigh) ? "-" : str.tostring(orbHigh, format.mintick))
    dashInfoRow(dashboard, 2, "Low:", na(orbLow) ? "-" : str.tostring(orbLow, format.mintick))

    table.cell(dashboard, 0, 3, "FTFC", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=size.small)
    table.cell(dashboard, 1, 3, "30m", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=size.small)
    table.cell(dashboard, 2, 3, "1H", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=size.small)
    table.cell(dashboard, 3, 3, "4H", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=size.small)
    table.cell(dashboard, 4, 3, "D", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=size.small)
    table.cell(dashboard, 5, 3, "W", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=size.small)
    table.cell(dashboard, 6, 3, "M", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=size.small)

    table.cell(dashboard, 0, 4, "", bgcolor=color.new(color.black, 0))
    dashFtfcValue(dashboard, 1, m30Dir)
    dashFtfcValue(dashboard, 2, h1Dir)
    dashFtfcValue(dashboard, 3, h4Dir)
    dashFtfcValue(dashboard, 4, dDir)
    dashFtfcValue(dashboard, 5, wDir)
    dashFtfcValue(dashboard, 6, mDir)
````
