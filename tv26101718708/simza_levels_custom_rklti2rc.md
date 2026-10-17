# Simza Levels Custom

- url: https://www.tradingview.com/script/RkLTI2RC-Simza-Levels-Custom/
- type: indicator
- pine_id: PUB;e4455a0bb6e04fa5aa8e8e6245f0f585
- version: 1.0

## Description

A multi-timeframe support/resistance indicator that draws horizontal percentage levels from any candle source.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Daily Open Levels - Custom

//@version=6
indicator("Daily Open Levels - Custom", overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=500)

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
showVerticalLine = input.bool(true, "Show Vertical Line on Open Candle", group="Vertical Line")
verticalLineColor = input.color(color.new(color.gray, 50), "Vertical Line Color", group="Vertical Line")
verticalLineWidth = input.int(2, "Vertical Line Width", minval=1, maxval=4, group="Vertical Line")
verticalLineStyle = input.string("Dashed", "Vertical Line Style", options=["Solid", "Dashed", "Dotted"], group="Vertical Line")

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

// ─── CALCULATE BASE VALUE ───
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
var line verticalLine = na

// ─── TRACK PREVIOUS CLOSE FOR CROSS DETECTION ───
var float prevClose = na

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

// ─── DYNAMIC ALERT MESSAGE (using alert() function) ───
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

// ─── STATIC ALERTCONDITION (for manual alert setup) ───
alertcondition(anyAlert, title="Level Cross Alert", message="Level Crossed! Check chart for details. Symbol: {{ticker}} | Price: {{close}}")

// ─── UPDATE LINES ON NEW PERIOD ───
newPeriod = ta.change(time(timeframe)) != 0

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
    
    // Delete old vertical line
    if not na(verticalLine)
        line.delete(verticalLine)
    
    // Draw new vertical line on opening candle
    if showVerticalLine
        verticalLine := line.new(
             bar_index, 
             low, 
             bar_index, 
             high,
             color=verticalLineColor,
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

// ─── UPDATE PREVIOUS CLOSE ───
prevClose := close

// ─── INFO LABEL ───
var label infoLabel = na
if newPeriod
    label.delete(infoLabel)
    infoLabel := label.new(bar_index, baseValue, candleSource + ": " + str.tostring(baseValue, format.mintick) + "\n+" + str.tostring(level1Pct) + "%: " + str.tostring(up1, format.mintick) + "\n-" + str.tostring(level1Pct) + "%: " + str.tostring(down1, format.mintick), color=color.new(color.black, 80), textcolor=color.white, size=size.small, style=label.style_label_down)

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
