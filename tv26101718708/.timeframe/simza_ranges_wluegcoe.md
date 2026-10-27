# Simza Ranges 

- url: https://www.tradingview.com/script/WLuEGCoe-Simza-Ranges/
- type: indicator
- pine_id: PUB;c22bc155517d4f76b5fa957848de7ef9
- version: 3.0

## Description

Multi-timeframe percentage-based support/resistance levels with period tracking.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Daily Open Levels - Custom with Statistics

//@version=6
indicator("Daily Open Levels - Stats", overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=500)

// ─── TIMEFRAME INPUT ───
timeframe = input.timeframe("D", "Timeframe", group="Timeframe")

// ─── CANDLE SOURCE INPUT ───
candleSource = input.string("Open", "Calculate On", options=["Open", "High", "Low", "Close", "HL2", "HLC3", "OHLC4", "Median"], group="Source")

// ─── PERCENTAGE LEVEL INPUTS (FULLY CUSTOM) ───
useLevel1 = input.bool(true, "Enable Level 1", group="Level 1")
level1Pct = input.float(1.0, "Level 1 %", minval=0.01, maxval=100.0, step=0.01, group="Level 1")
level1Color = input.color(color.new(color.blue, 0), "Level 1 Color", group="Level 1")

useLevel2 = input.bool(true, "Enable Level 2", group="Level 2")
level2Pct = input.float(2.0, "Level 2 %", minval=0.01, maxval=100.0, step=0.01, group="Level 2")
level2Color = input.color(color.new(color.purple, 0), "Level 2 Color", group="Level 2")

useLevel3 = input.bool(true, "Enable Level 3", group="Level 3")
level3Pct = input.float(3.0, "Level 3 %", minval=0.01, maxval=100.0, step=0.01, group="Level 3")
level3Color = input.color(color.new(color.red, 0), "Level 3 Color", group="Level 3")

useLevel4 = input.bool(false, "Enable Level 4", group="Level 4")
level4Pct = input.float(5.0, "Level 4 %", minval=0.01, maxval=100.0, step=0.01, group="Level 4")
level4Color = input.color(color.new(color.orange, 0), "Level 4 Color", group="Level 4")

useLevel5 = input.bool(false, "Enable Level 5", group="Level 5")
level5Pct = input.float(10.0, "Level 5 %", minval=0.01, maxval=100.0, step=0.01, group="Level 5")
level5Color = input.color(color.new(color.maroon, 0), "Level 5 Color", group="Level 5")

// ─── VERTICAL LINE INPUTS ───
showStartLine = input.bool(true, "Show Start Vertical Line", group="Vertical Lines")
showEndLine = input.bool(true, "Show End Vertical Line", group="Vertical Lines")
startLineColor = input.color(color.new(color.green, 50), "Start Line Color", group="Vertical Lines")
endLineColor = input.color(color.new(color.red, 50), "End Line Color", group="Vertical Lines")
verticalLineWidth = input.int(2, "Vertical Line Width", minval=1, maxval=4, group="Vertical Lines")
verticalLineStyle = input.string("Dashed", "Vertical Line Style", options=["Solid", "Dashed", "Dotted"], group="Vertical Lines")

// ─── TIMER INPUTS ───
showTimer = input.bool(true, "Show Timer", group="Timer")
timerPosition = input.string("Top Right", "Timer Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group="Timer")
timerColor = input.color(color.new(color.white, 0), "Timer Color", group="Timer")
timerBgColor = input.color(color.new(color.black, 80), "Timer Background", group="Timer")

// ─── STATISTICS INPUTS ───
showStats = input.bool(true, "Show Statistics Table", group="Statistics")
statsPosition = input.string("Bottom Left", "Stats Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group="Statistics")
touchThreshold = input.float(0.3, "Touch Threshold (%)", minval=0.05, maxval=2.0, step=0.05, group="Statistics")

// ─── STYLE INPUTS ───
showBaseLine = input.bool(true, "Show Base Line", group="Style")
baseLineColor = input.color(color.new(color.white, 0), "Base Line Color", group="Style")
lineWidth = input.int(2, "Line Width", minval=1, maxval=4, group="Style")
extendRight = input.bool(true, "Extend Lines to Right", group="Style")
baseLineStyle = input.string("Solid", "Base Line Style", options=["Solid", "Dashed", "Dotted"], group="Style")
levelLineStyle = input.string("Dashed", "Level Line Style", options=["Solid", "Dashed", "Dotted"], group="Style")

// ─── ALERT INPUTS ───
alertOnLevel1 = input.bool(true, "Alert on Level 1", group="Alerts")
alertOnLevel2 = input.bool(false, "Alert on Level 2", group="Alerts")
alertOnLevel3 = input.bool(false, "Alert on Level 3", group="Alerts")
alertOnLevel4 = input.bool(false, "Alert on Level 4", group="Alerts")
alertOnLevel5 = input.bool(false, "Alert on Level 5", group="Alerts")
alertOnBase = input.bool(false, "Alert on Base Line", group="Alerts")
alertDirection = input.string("Both", "Alert Direction", options=["Cross Up", "Cross Down", "Both"], group="Alerts")

// ─── GET CANDLE VALUE ───
getCandleValue(source) =>
    switch source
        "Open" => open
        "High" => high
        "Low" => low
        "Close" => close
        "HL2" => hl2
        "HLC3" => hlc3
        "OHLC4" => ohlc4
        "Median" => (high + low) / 2
        => open

// ─── GET LINE STYLE ───
getLineStyle(styleString) =>
    switch styleString
        "Solid" => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

// ─── GET TIMER POSITION ───
getTimerPos(posString) =>
    switch posString
        "Top Left" => position.top_left
        "Top Right" => position.top_right
        "Bottom Left" => position.bottom_left
        "Bottom Right" => position.bottom_right
        => position.top_right

// ─── GET STATS POSITION ───
getStatsPos(posString) =>
    switch posString
        "Top Left" => position.top_left
        "Top Right" => position.top_right
        "Bottom Left" => position.bottom_left
        "Bottom Right" => position.bottom_right
        => position.bottom_left

// ─── CALCULATE BASE VALUE FROM CURRENT PERIOD OPEN ───
baseValue = request.security(syminfo.tickerid, timeframe, getCandleValue(candleSource), lookahead=barmerge.lookahead_on)

// ─── CALCULATE LEVELS ───
up1 = baseValue * (1 + level1Pct / 100)
up2 = baseValue * (1 + level2Pct / 100)
up3 = baseValue * (1 + level3Pct / 100)
up4 = baseValue * (1 + level4Pct / 100)
up5 = baseValue * (1 + level5Pct / 100)

down1 = baseValue * (1 - level1Pct / 100)
down2 = baseValue * (1 - level2Pct / 100)
down3 = baseValue * (1 - level3Pct / 100)
down4 = baseValue * (1 - level4Pct / 100)
down5 = baseValue * (1 - level5Pct / 100)

// ─── LINE STYLE FUNCTION ───
drawLine(level, lineColor, lineStyle) =>
    line.new(bar_index, level, bar_index, level, color=lineColor, width=lineWidth, style=lineStyle, extend=extendRight ? extend.right : extend.none)

// ─── MANAGE LINES ───
var line baseLine = na
var line up1Line = na
var line up2Line = na
var line up3Line = na
var line up4Line = na
var line up5Line = na
var line down1Line = na
var line down2Line = na
var line down3Line = na
var line down4Line = na
var line down5Line = na

// ─── MANAGE VERTICAL LINES ───
var line startLine = na
var line endLine = na

// ─── TRACK PREVIOUS CLOSE FOR CROSS DETECTION ───
var float prevClose = na

// ─── STATISTICS VARIABLES ───
var int up1Touches = 0
var int up1Breaks = 0
var int up2Touches = 0
var int up2Breaks = 0
var int up3Touches = 0
var int up3Breaks = 0
var int up4Touches = 0
var int up4Breaks = 0
var int up5Touches = 0
var int up5Breaks = 0
var int down1Touches = 0
var int down1Breaks = 0
var int down2Touches = 0
var int down2Breaks = 0
var int down3Touches = 0
var int down3Breaks = 0
var int down4Touches = 0
var int down4Breaks = 0
var int down5Touches = 0
var int down5Breaks = 0
var int baseTouches = 0
var int baseBreaks = 0

// ─── TOUCH DETECTION FUNCTION ───
detectTouchBreak(level, isUp) =>
    threshold = level * touchThreshold / 100
    touched = false
    broke = false
    if isUp
        if high >= level - threshold and high <= level + threshold and close < level
            touched := true
        if close > level and prevClose <= level
            broke := true
    else
        if low <= level + threshold and low >= level - threshold and close > level
            touched := true
        if close < level and prevClose >= level
            broke := true
    [touched, broke]

// ─── DETECT TOUCHES/BREAKS ───
[up1Touched, up1Broke] = detectTouchBreak(up1, true)
[up2Touched, up2Broke] = detectTouchBreak(up2, true)
[up3Touched, up3Broke] = detectTouchBreak(up3, true)
[up4Touched, up4Broke] = detectTouchBreak(up4, true)
[up5Touched, up5Broke] = detectTouchBreak(up5, true)
[down1Touched, down1Broke] = detectTouchBreak(down1, false)
[down2Touched, down2Broke] = detectTouchBreak(down2, false)
[down3Touched, down3Broke] = detectTouchBreak(down3, false)
[down4Touched, down4Broke] = detectTouchBreak(down4, false)
[down5Touched, down5Broke] = detectTouchBreak(down5, false)

// ─── BASE LINE TOUCH/BREAK ───
baseThreshold = baseValue * touchThreshold / 100
baseTouched = (high >= baseValue - baseThreshold and high <= baseValue + baseThreshold) or (low <= baseValue + baseThreshold and low >= baseValue - baseThreshold)
baseBroke = (close > baseValue and prevClose <= baseValue) or (close < baseValue and prevClose >= baseValue)

// ─── UPDATE STATISTICS ───
if useLevel1 and up1Touched
    up1Touches += 1
if useLevel1 and up1Broke
    up1Breaks += 1
if useLevel2 and up2Touched
    up2Touches += 1
if useLevel2 and up2Broke
    up2Breaks += 1
if useLevel3 and up3Touched
    up3Touches += 1
if useLevel3 and up3Broke
    up3Breaks += 1
if useLevel4 and up4Touched
    up4Touches += 1
if useLevel4 and up4Broke
    up4Breaks += 1
if useLevel5 and up5Touched
    up5Touches += 1
if useLevel5 and up5Broke
    up5Breaks += 1
if useLevel1 and down1Touched
    down1Touches += 1
if useLevel1 and down1Broke
    down1Breaks += 1
if useLevel2 and down2Touched
    down2Touches += 1
if useLevel2 and down2Broke
    down2Breaks += 1
if useLevel3 and down3Touched
    down3Touches += 1
if useLevel3 and down3Broke
    down3Breaks += 1
if useLevel4 and down4Touched
    down4Touches += 1
if useLevel4 and down4Broke
    down4Breaks += 1
if useLevel5 and down5Touched
    down5Touches += 1
if useLevel5 and down5Broke
    down5Breaks += 1
if showBaseLine and baseTouched
    baseTouches += 1
if showBaseLine and baseBroke
    baseBreaks += 1

// ─── NEW PERIOD DETECTION ───
newPeriod = ta.change(time(timeframe)) != 0

// ─── RESET STATS ON NEW PERIOD ───
if newPeriod
    up1Touches := 0
    up1Breaks := 0
    up2Touches := 0
    up2Breaks := 0
    up3Touches := 0
    up3Breaks := 0
    up4Touches := 0
    up4Breaks := 0
    up5Touches := 0
    up5Breaks := 0
    down1Touches := 0
    down1Breaks := 0
    down2Touches := 0
    down2Breaks := 0
    down3Touches := 0
    down3Breaks := 0
    down4Touches := 0
    down4Breaks := 0
    down5Touches := 0
    down5Breaks := 0
    baseTouches := 0
    baseBreaks := 0

// ─── ALERT CONDITIONS ───
crossUp(level) => close > level and prevClose <= level
crossDown(level) => close < level and prevClose >= level

alertLevel1 = (alertDirection == "Cross Up" or alertDirection == "Both") and crossUp(up1) or (alertDirection == "Cross Down" or alertDirection == "Both") and crossDown(down1)
alertLevel2 = (alertDirection == "Cross Up" or alertDirection == "Both") and crossUp(up2) or (alertDirection == "Cross Down" or alertDirection == "Both") and crossDown(down2)
alertLevel3 = (alertDirection == "Cross Up" or alertDirection == "Both") and crossUp(up3) or (alertDirection == "Cross Down" or alertDirection == "Both") and crossDown(down3)
alertLevel4 = (alertDirection == "Cross Up" or alertDirection == "Both") and crossUp(up4) or (alertDirection == "Cross Down" or alertDirection == "Both") and crossDown(down4)
alertLevel5 = (alertDirection == "Cross Up" or alertDirection == "Both") and crossUp(up5) or (alertDirection == "Cross Down" or alertDirection == "Both") and crossDown(down5)
alertBase = (alertDirection == "Cross Up" or alertDirection == "Both") and crossUp(baseValue) or (alertDirection == "Cross Down" or alertDirection == "Both") and crossDown(baseValue)

// ─── COMBINED ALERT ───
anyAlert = (alertOnLevel1 and alertLevel1) or (alertOnLevel2 and alertLevel2) or (alertOnLevel3 and alertLevel3) or (alertOnLevel4 and alertLevel4) or (alertOnLevel5 and alertLevel5) or (alertOnBase and alertBase)

// ─── DYNAMIC ALERT MESSAGE ───
if anyAlert
    alertMsg = ""
    if alertOnLevel1 and alertLevel1
        alertMsg += "Level 1 (" + str.tostring(level1Pct) + "%) crossed! "
    if alertOnLevel2 and alertLevel2
        alertMsg += "Level 2 (" + str.tostring(level2Pct) + "%) crossed! "
    if alertOnLevel3 and alertLevel3
        alertMsg += "Level 3 (" + str.tostring(level3Pct) + "%) crossed! "
    if alertOnLevel4 and alertLevel4
        alertMsg += "Level 4 (" + str.tostring(level4Pct) + "%) crossed! "
    if alertOnLevel5 and alertLevel5
        alertMsg += "Level 5 (" + str.tostring(level5Pct) + "%) crossed! "
    if alertOnBase and alertBase
        alertMsg += "Base Line crossed! "
    alertMsg += "Price: " + str.tostring(close, format.mintick) + " | Symbol: " + syminfo.ticker
    alert(alertMsg, alert.freq_once_per_bar_close)

// ─── PLOT ALERT SHAPES ───
plotshape(anyAlert, title="Alert Signal", style=shape.triangleup, location=location.belowbar, color=color.yellow, size=size.small)

// ─── STATIC ALERTCONDITION ───
alertcondition(anyAlert, title="Level Cross Alert", message="Level Crossed! Check chart for details. Symbol: {{ticker}} | Price: {{close}}")

// ─── UPDATE LINES ON NEW PERIOD ───
if newPeriod
    // Delete old horizontal lines
    if not na(baseLine)
        line.delete(baseLine)
        line.delete(up1Line)
        line.delete(up2Line)
        line.delete(up3Line)
        line.delete(up4Line)
        line.delete(up5Line)
        line.delete(down1Line)
        line.delete(down2Line)
        line.delete(down3Line)
        line.delete(down4Line)
        line.delete(down5Line)
    
    // Delete old vertical lines
    if not na(startLine)
        line.delete(startLine)
    if not na(endLine)
        line.delete(endLine)
    
    // Draw new start vertical line on opening candle
    if showStartLine
        startLine := line.new(
             bar_index, 
             low, 
             bar_index, 
             high,
             color=startLineColor,
             width=verticalLineWidth,
             style=getLineStyle(verticalLineStyle),
             extend=extend.both
        )
    
    // Draw end vertical line
    if showEndLine
        endLine := line.new(
             bar_index, 
             low, 
             bar_index, 
             high,
             color=endLineColor,
             width=verticalLineWidth,
             style=getLineStyle(verticalLineStyle),
             extend=extend.both
        )
    
    // Draw base line
    if showBaseLine
        baseLine := drawLine(baseValue, baseLineColor, getLineStyle(baseLineStyle))
    
    // Draw level 1
    if useLevel1
        up1Line := drawLine(up1, level1Color, getLineStyle(levelLineStyle))
        down1Line := drawLine(down1, level1Color, getLineStyle(levelLineStyle))
    
    // Draw level 2
    if useLevel2
        up2Line := drawLine(up2, level2Color, getLineStyle(levelLineStyle))
        down2Line := drawLine(down2, level2Color, getLineStyle(levelLineStyle))
    
    // Draw level 3
    if useLevel3
        up3Line := drawLine(up3, level3Color, getLineStyle(levelLineStyle))
        down3Line := drawLine(down3, level3Color, getLineStyle(levelLineStyle))
    
    // Draw level 4
    if useLevel4
        up4Line := drawLine(up4, level4Color, getLineStyle(levelLineStyle))
        down4Line := drawLine(down4, level4Color, getLineStyle(levelLineStyle))
    
    // Draw level 5
    if useLevel5
        up5Line := drawLine(up5, level5Color, getLineStyle(levelLineStyle))
        down5Line := drawLine(down5, level5Color, getLineStyle(levelLineStyle))

// ─── EXTEND EXISTING HORIZONTAL LINES ───
if not newPeriod and not na(baseLine)
    line.set_x2(baseLine, bar_index)
    
    if useLevel1 and not na(up1Line)
        line.set_x2(up1Line, bar_index)
        line.set_x2(down1Line, bar_index)
    
    if useLevel2 and not na(up2Line)
        line.set_x2(up2Line, bar_index)
        line.set_x2(down2Line, bar_index)
    
    if useLevel3 and not na(up3Line)
        line.set_x2(up3Line, bar_index)
        line.set_x2(down3Line, bar_index)
    
    if useLevel4 and not na(up4Line)
        line.set_x2(up4Line, bar_index)
        line.set_x2(down4Line, bar_index)
    
    if useLevel5 and not na(up5Line)
        line.set_x2(up5Line, bar_index)
        line.set_x2(down5Line, bar_index)

// ─── UPDATE END VERTICAL LINE POSITION ───
if not newPeriod and showEndLine and not na(endLine)
    line.set_x1(endLine, bar_index)
    line.set_x2(endLine, bar_index)

// ─── UPDATE PREVIOUS CLOSE ───
prevClose := close

// ─── TIMER CALCULATION ───
timeRemaining = time_close(timeframe) - time
minutesRemaining = int(timeRemaining / 60000)
secondsRemaining = int((timeRemaining % 60000) / 1000)
hoursRemaining = int(minutesRemaining / 60)
displayMinutes = minutesRemaining % 60

timerText = hoursRemaining > 0 ? str.tostring(hoursRemaining) + "h " + str.tostring(displayMinutes) + "m " + str.tostring(secondsRemaining) + "s" : str.tostring(minutesRemaining) + "m " + str.tostring(secondsRemaining) + "s"

// ─── TIMER TABLE ───
var table timerTable = table.new(getTimerPos(timerPosition), 1, 1, bgcolor=timerBgColor, frame_width=1, frame_color=timerColor)

if showTimer and barstate.islast
    table.cell(timerTable, 0, 0, "⏱ " + timeframe + " | " + timerText, text_color=timerColor, text_size=size.small)

// ─── STATISTICS TABLE ───
var table statsTable = table.new(getStatsPos(statsPosition), 4, 8, bgcolor=color.new(color.black, 85), frame_width=1, frame_color=color.gray)

// ─── CALCULATE WIN RATES ───
getWinRate(touches, breaks) => touches > 0 ? str.tostring(100 - (breaks * 100 / touches), "#.#") + "%" : "N/A"
getTotalTouches(touches, breaks) => str.tostring(touches + breaks)

if showStats and barstate.islast
    // Header
    table.cell(statsTable, 0, 0, "Level", text_color=color.gray, text_size=size.tiny)
    table.cell(statsTable, 1, 0, "Touches", text_color=color.gray, text_size=size.tiny)
    table.cell(statsTable, 2, 0, "Breaks", text_color=color.gray, text_size=size.tiny)
    table.cell(statsTable, 3, 0, "Respect %", text_color=color.gray, text_size=size.tiny)
    
    row = 1
    
    if useLevel5
        table.cell(statsTable, 0, row, "+/-" + str.tostring(level5Pct) + "%", text_color=level5Color, text_size=size.small)
        table.cell(statsTable, 1, row, getTotalTouches(up5Touches, up5Breaks), text_color=color.white, text_size=size.small)
        table.cell(statsTable, 2, row, str.tostring(up5Breaks + down5Breaks), text_color=color.red, text_size=size.small)
        table.cell(statsTable, 3, row, getWinRate(up5Touches + down5Touches, up5Breaks + down5Breaks), text_color=color.green, text_size=size.small)
        row += 1
    
    if useLevel4
        table.cell(statsTable, 0, row, "+/-" + str.tostring(level4Pct) + "%", text_color=level4Color, text_size=size.small)
        table.cell(statsTable, 1, row, getTotalTouches(up4Touches, up4Breaks), text_color=color.white, text_size=size.small)
        table.cell(statsTable, 2, row, str.tostring(up4Breaks + down4Breaks), text_color=color.red, text_size=size.small)
        table.cell(statsTable, 3, row, getWinRate(up4Touches + down4Touches, up4Breaks + down4Breaks), text_color=color.green, text_size=size.small)
        row += 1
    
    if useLevel3
        table.cell(statsTable, 0, row, "+/-" + str.tostring(level3Pct) + "%", text_color=level3Color, text_size=size.small)
        table.cell(statsTable, 1, row, getTotalTouches(up3Touches, up3Breaks), text_color=color.white, text_size=size.small)
        table.cell(statsTable, 2, row, str.tostring(up3Breaks + down3Breaks), text_color=color.red, text_size=size.small)
        table.cell(statsTable, 3, row, getWinRate(up3Touches + down3Touches, up3Breaks + down3Breaks), text_color=color.green, text_size=size.small)
        row += 1
    
    if useLevel2
        table.cell(statsTable, 0, row, "+/-" + str.tostring(level2Pct) + "%", text_color=level2Color, text_size=size.small)
        table.cell(statsTable, 1, row, getTotalTouches(up2Touches, up2Breaks), text_color=color.white, text_size=size.small)
        table.cell(statsTable, 2, row, str.tostring(up2Breaks + down2Breaks), text_color=color.red, text_size=size.small)
        table.cell(statsTable, 3, row, getWinRate(up2Touches + down2Touches, up2Breaks + down2Breaks), text_color=color.green, text_size=size.small)
        row += 1
    
    if useLevel1
        table.cell(statsTable, 0, row, "+/-" + str.tostring(level1Pct) + "%", text_color=level1Color, text_size=size.small)
        table.cell(statsTable, 1, row, getTotalTouches(up1Touches, up1Breaks), text_color=color.white, text_size=size.small)
        table.cell(statsTable, 2, row, str.tostring(up1Breaks + down1Breaks), text_color=color.red, text_size=size.small)
        table.cell(statsTable, 3, row, getWinRate(up1Touches + down1Touches, up1Breaks + down1Breaks), text_color=color.green, text_size=size.small)
        row += 1
    
    if showBaseLine
        table.cell(statsTable, 0, row, "BASE", text_color=baseLineColor, text_size=size.small)
        table.cell(statsTable, 1, row, getTotalTouches(baseTouches, baseBreaks), text_color=color.white, text_size=size.small)
        table.cell(statsTable, 2, row, str.tostring(baseBreaks), text_color=color.red, text_size=size.small)
        table.cell(statsTable, 3, row, getWinRate(baseTouches, baseBreaks), text_color=color.green, text_size=size.small)

// ─── TABLE WITH PRICES ───
var table priceTable = table.new(position.top_right, 2, 12, bgcolor=color.new(color.black, 85), frame_width=1, frame_color=color.gray)

if barstate.islast
    row = 0
    table.cell(priceTable, 0, row, "TF: " + timeframe + " | " + candleSource, text_color=color.white, text_size=size.small)
    table.cell(priceTable, 1, row, str.tostring(baseValue, format.mintick), text_color=color.white, text_size=size.small)
    row += 1
    
    if useLevel5
        table.cell(priceTable, 0, row, "+" + str.tostring(level5Pct) + "%", text_color=level5Color, text_size=size.small)
        table.cell(priceTable, 1, row, str.tostring(up5, format.mintick), text_color=color.white, text_size=size.small)
        row += 1
        table.cell(priceTable, 0, row, "-" + str.tostring(level5Pct) + "%", text_color=level5Color, text_size=size.small)
        table.cell(priceTable, 1, row, str.tostring(down5, format.mintick), text_color=color.white, text_size=size.small)
        row += 1
    
    if useLevel4
        table.cell(priceTable, 0, row, "+" + str.tostring(level4Pct) + "%", text_color=level4Color, text_size=size.small)
        table.cell(priceTable, 1, row, str.tostring(up4, format.mintick), text_color=color.white, text_size=size.small)
        row += 1
        table.cell(priceTable, 0, row, "-" + str.tostring(level4Pct) + "%", text_color=level4Color, text_size=size.small)
        table.cell(priceTable, 1, row, str.tostring(down4, format.mintick), text_color=color.white, text_size=size.small)
        row += 1
    
    if useLevel3
        table.cell(priceTable, 0, row, "+" + str.tostring(level3Pct) + "%", text_color=level3Color, text_size=size.small)
        table.cell(priceTable, 1, row, str.tostring(up3, format.mintick), text_color=color.white, text_size=size.small)
        row += 1
        table.cell(priceTable, 0, row, "-" + str.tostring(level3Pct) + "%", text_color=level3Color, text_size=size.small)
        table.cell(priceTable, 1, row, str.tostring(down3, format.mintick), text_color=color.white, text_size=size.small)
        row += 1
    
    if useLevel2
        table.cell(priceTable, 0, row, "+" + str.tostring(level2Pct) + "%", text_color=level2Color, text_size=size.small)
        table.cell(priceTable, 1, row, str.tostring(up2, format.mintick), text_color=color.white, text_size=size.small)
        row += 1
        table.cell(priceTable, 0, row, "-" + str.tostring(level2Pct) + "%", text_color=level2Color, text_size=size.small)
        table.cell(priceTable, 1, row, str.tostring(down2, format.mintick), text_color=color.white, text_size=size.small)
        row += 1
    
    if useLevel1
        table.cell(priceTable, 0, row, "+" + str.tostring(level1Pct) + "%", text_color=level1Color, text_size=size.small)
        table.cell(priceTable, 1, row, str.tostring(up1, format.mintick), text_color=color.white, text_size=size.small)
        row += 1
        table.cell(priceTable, 0, row, "-" + str.tostring(level1Pct) + "%", text_color=level1Color, text_size=size.small)
        table.cell(priceTable, 1, row, str.tostring(down1, format.mintick), text_color=color.white, text_size=size.small)
        row += 1
    
    if showBaseLine
        table.cell(priceTable, 0, row, "BASE", text_color=baseLineColor, text_size=size.small)
        table.cell(priceTable, 1, row, str.tostring(baseValue, format.mintick), text_color=color.white, text_size=size.small)
````
