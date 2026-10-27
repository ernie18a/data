# Pivot Points with CPR by KC

- url: https://www.tradingview.com/script/oLyR1Ryq-Pivot-Points-with-CPR-by-KC/
- type: indicator
- pine_id: PUB;0b07d7db4050406e8a7f7c4c257b5a8b
- version: 1.0

## Description

Pivot Points with CPR by KC

Daily, Weekly, Monthly CPR

## Source Code

````pine
//@version=6
indicator("Pivot Points with CPR by KC", "Pivot Points with CPR by KC", overlay=true, max_lines_count=500, max_labels_count=500)

pivotTypeInput           = input.string(title="Type", defval="Traditional", options=["Traditional", "Fibonacci", "Woodie", "Classic", "DM", "Camarilla"])
pivotAnchorInput         = input.string(title="Pivots Timeframe", defval="Auto", options=["Auto", "Daily", "Weekly", "Monthly", "Quarterly", "Yearly", "Biyearly", "Triyearly", "Quinquennially", "Decennially"])
maxHistoricalPivotsInput = input.int(title="Number of Pivots Back", defval=15, minval=1, maxval=200, display = display.data_window)
isDailyBasedInput        = input.bool(title="Use Daily-based Values", defval=true, display = display.data_window, tooltip="When this option is unchecked, Pivot Points will use intraday data while calculating on intraday charts. If Extended Hours are displayed on the chart, they will be taken into account during the pivot level calculation. If intraday OHLC values are different from daily-based values (normal for stocks), the pivot levels will also differ.")

// ----------------------
// VWAP & EMA Options
// ----------------------
showVWAP = input.bool(title="Show VWAP", defval=false, group="VWAP/EMA")
showEMA  = input.bool(title="Show EMA (9 & 15)", defval=false, group="VWAP/EMA")

// Calculate Indicators
vwapVal = ta.vwap
ema9    = ta.ema(close, 9)
ema15   = ta.ema(close, 15)

// Plot when selected
plot(showVWAP ? vwapVal : na, title="VWAP", color=color.new(color.blue, 0), linewidth=2)
plot(showEMA  ? ema9    : na, title="EMA 9", color=color.new(color.green, 0), linewidth=2)
plot(showEMA  ? ema15   : na, title="EMA 15", color=color.new(color.orange, 0), linewidth=2)


showLabelsInput          = input.bool(title="Show Labels", defval=true, group="labels", display = display.data_window)
showPricesInput          = input.bool(title="Show Prices", defval=true, group="labels", display = display.data_window)
positionLabelsInput      = input.string("Left", "Labels Position", options=["Left", "Right"], group="labels", display = display.data_window, active = showLabelsInput or showPricesInput)
linewidthInput           = input.int(title="Line Width", defval=1, minval=1, maxval=100, group="levels", display = display.data_window)


// Next Day Pivot Settings
showNextDayPivots        = input.bool(title="Show Next Day Pivots", defval=false, group="Next Day Pivots", display = display.data_window)
nextDayColorInput        = input.color(title="Next Day Color", defval=#00FF88, group="Next Day Pivots", display = display.data_window)
nextDayWidthInput        = input.int(title="Next Day Line Width", defval=1, minval=1, maxval=10, group="Next Day Pivots", display = display.data_window)
nextDayStyleInput        = input.string(title="Next Day Line Style", defval="Dashed", options=["Solid", "Dotted", "Dashed"], group="Next Day Pivots", display = display.data_window)

// CPR Settings
showCPRInput             = input.bool(title="Show CPR", defval=true, group="CPR", display = display.data_window)
cprColorInput            = input.color(title="CPR Color", defval=#FF6B35, group="CPR", display = display.data_window)
cprWidthInput            = input.int(title="CPR Line Width", defval=2, minval=1, maxval=10, group="CPR", display = display.data_window)
cprLineStyleInput        = input.string(title="CPR Line Style", defval="Solid", options=["Solid", "Dotted", "Dashed"], group="CPR", display = display.data_window)
fillCPRInput             = input.bool(title="Fill CPR Zone", defval=true, group="CPR", display = display.data_window)
cprTransparencyInput     = input.int(title="CPR Fill Transparency", defval=85, minval=0, maxval=100, group="CPR", display = display.data_window)

// Individual CPR Level Controls
showTCInput              = input.bool(title="Show TC (Top Central)", defval=true, group="CPR Levels", display = display.data_window)
showPPInput              = input.bool(title="Show PP (Pivot Point)", defval=true, group="CPR Levels", display = display.data_window) 
showBCInput              = input.bool(title="Show BC (Bottom Central)", defval=true, group="CPR Levels", display = display.data_window)
tcColorInput             = input.color(title="TC Color", defval=#FF6B35, group="CPR Levels", display = display.data_window)
ppColorInput             = input.color(title="PP Color", defval=#FF6B35, group="CPR Levels", display = display.data_window)
bcColorInput             = input.color(title="BC Color", defval=#FF6B35, group="CPR Levels", display = display.data_window)

DEFAULT_COLOR = #FB8C00

showLevel2and3 = pivotTypeInput != "DM"
showLevel4 = pivotTypeInput != "DM" and pivotTypeInput != "Fibonacci"
showLevel5 = pivotTypeInput == "Traditional" or pivotTypeInput == "Camarilla"

pColorInput = input.color(DEFAULT_COLOR, "P‏  ‏  ‏", inline="P", group="levels", display = display.data_window)
pShowInput = input.bool(true, "", inline="P", group="levels", display = display.data_window)
s1ColorInput = input.color(DEFAULT_COLOR, "S1", inline="S1/R1" , group="levels", display = display.data_window)
s1ShowInput = input.bool(true, "", inline="S1/R1", group="levels", display = display.data_window)
r1ColorInput = input.color(DEFAULT_COLOR, "‏  ‏  ‏  ‏  ‏  ‏  ‏  ‏R1", inline="S1/R1", group="levels", display = display.data_window)
r1ShowInput = input.bool(true, "", inline="S1/R1", group="levels", display = display.data_window)
s2ColorInput = input.color(DEFAULT_COLOR, "S2", inline="S2/R2", group="levels", display = display.data_window, active = showLevel2and3)
s2ShowInput = input.bool(true, "", inline="S2/R2", group="levels", display = display.data_window, active = showLevel2and3)
r2ColorInput = input.color(DEFAULT_COLOR, "‏  ‏  ‏  ‏  ‏  ‏  ‏  ‏R2", inline="S2/R2", group="levels", display = display.data_window, active = showLevel2and3)
r2ShowInput = input.bool(true, "", inline="S2/R2", group="levels", display = display.data_window, active = showLevel2and3)
s3ColorInput = input.color(DEFAULT_COLOR, "S3", inline="S3/R3", group="levels", display = display.data_window, active = showLevel2and3)
s3ShowInput = input.bool(true, "", inline="S3/R3", group="levels", display = display.data_window, active = showLevel2and3)
r3ColorInput = input.color(DEFAULT_COLOR, "‏  ‏  ‏  ‏  ‏  ‏  ‏  ‏R3", inline="S3/R3", group="levels", display = display.data_window, active = showLevel2and3)
r3ShowInput = input.bool(true, "", inline="S3/R3", group="levels", display = display.data_window, active = showLevel2and3)
s4ColorInput = input.color(DEFAULT_COLOR, "S4", inline="S4/R4", group="levels", display = display.data_window, active = showLevel4)
s4ShowInput = input.bool(true, "", inline="S4/R4", group="levels", display = display.data_window, active = showLevel4)
r4ColorInput = input.color(DEFAULT_COLOR, "‏  ‏  ‏  ‏  ‏  ‏  ‏  ‏R4", inline="S4/R4", group="levels", display = display.data_window, active = showLevel4)
r4ShowInput = input.bool(true, "", inline="S4/R4", group="levels", display = display.data_window, active = showLevel4)
s5ColorInput = input.color(DEFAULT_COLOR, "S5", inline="S5/R5", group="levels", display = display.data_window, active = showLevel5)
s5ShowInput = input.bool(true, "", inline="S5/R5", group="levels", display = display.data_window, active = showLevel5)
r5ColorInput = input.color(DEFAULT_COLOR, "‏  ‏  ‏  ‏  ‏  ‏  ‏  ‏R5", inline="S5/R5", group="levels", display = display.data_window, active = showLevel5)
r5ShowInput = input.bool(true, "", inline="S5/R5", group="levels", display = display.data_window, active = showLevel5)

type graphicSettings
    string levelName
    color levelColor
    bool showLevel

var graphicSettingsArray = array.from(
      graphicSettings.new(" P", pColorInput, pShowInput),
      graphicSettings.new("R1", r1ColorInput, r1ShowInput), graphicSettings.new("S1", s1ColorInput, s1ShowInput),
      graphicSettings.new("R2", r2ColorInput, r2ShowInput), graphicSettings.new("S2", s2ColorInput, s2ShowInput),
      graphicSettings.new("R3", r3ColorInput, r3ShowInput), graphicSettings.new("S3", s3ColorInput, s3ShowInput),
      graphicSettings.new("R4", r4ColorInput, r4ShowInput), graphicSettings.new("S4", s4ColorInput, s4ShowInput),
      graphicSettings.new("R5", r5ColorInput, r5ShowInput), graphicSettings.new("S5", s5ColorInput, s5ShowInput),
      // Added Previous High & Low
      graphicSettings.new("Prev High", color.new(color.black, 0), true),
      graphicSettings.new("Prev Low", color.new(color.black, 0), true))

// Next Day graphic settings
var nextDayGraphicSettingsArray = array.from(
      graphicSettings.new("NP", nextDayColorInput, showNextDayPivots),
      graphicSettings.new("NR1", nextDayColorInput, showNextDayPivots), graphicSettings.new("NS1", nextDayColorInput, showNextDayPivots),
      graphicSettings.new("NR2", nextDayColorInput, showNextDayPivots), graphicSettings.new("NS2", nextDayColorInput, showNextDayPivots),
      graphicSettings.new("NR3", nextDayColorInput, showNextDayPivots), graphicSettings.new("NS3", nextDayColorInput, showNextDayPivots),
      graphicSettings.new("NR4", nextDayColorInput, showNextDayPivots), graphicSettings.new("NS4", nextDayColorInput, showNextDayPivots),
      graphicSettings.new("NR5", nextDayColorInput, showNextDayPivots), graphicSettings.new("NS5", nextDayColorInput, showNextDayPivots))

// CPR graphic settings
var cprGraphicSettings = array.from(
      graphicSettings.new("TC", cprColorInput, showCPRInput),
      graphicSettings.new("PP", cprColorInput, showCPRInput),
      graphicSettings.new("BC", cprColorInput, showCPRInput))

autoAnchor = switch
    timeframe.isintraday => timeframe.multiplier <= 15 ? "1D" : "1W"
    timeframe.isdaily    => "1M"
    => "12M"

pivotTimeframe = switch pivotAnchorInput
    "Auto"      => autoAnchor
    "Daily"     => "1D"
    "Weekly"    => "1W"
    "Monthly"   => "1M"
    "Quarterly" => "3M"
    => "12M"

//@variable The number of years in the selected Pivot period
pivotYearMultiplier = switch pivotAnchorInput
    "Biyearly"       => 2
    "Triyearly"      => 3
    "Quinquennially" => 5
    "Decennially"    => 10
    => 1

//@variable The number of values in the pivots of the selected type
numOfPivotLevels = switch pivotTypeInput
    "Traditional" => 11
    "Camarilla"   => 11
    "Woodie"      => 9
    "Classic"     => 9
    "Fibonacci"   => 7
    "DM"          => 3

type pivotGraphic
    line pivotLine
    label pivotLabel
    linefill pivotFill    // new field

type cprGraphic
    line tcLine
    line ppLine  
    line bcLine
    label tcLabel
    label ppLabel
    label bcLabel
    linefill cprFill

method delete(pivotGraphic graphic) =>
    graphic.pivotLine.delete()
    graphic.pivotLabel.delete()

method delete(cprGraphic graphic) =>
    if not na(graphic.tcLine)
        graphic.tcLine.delete()
    if not na(graphic.ppLine)
        graphic.ppLine.delete()
    if not na(graphic.bcLine)
        graphic.bcLine.delete()
    if not na(graphic.tcLabel)
        graphic.tcLabel.delete()
    if not na(graphic.ppLabel)
        graphic.ppLabel.delete()
    if not na(graphic.bcLabel)
        graphic.bcLabel.delete()
    if not na(graphic.cprFill)
        graphic.cprFill.delete()

var drawnGraphics = matrix.new<pivotGraphic>()
var drawnCPRGraphics = array.new<cprGraphic>()
var drawnNextDayGraphics = array.new<pivotGraphic>()

// Get line style for CPR
getCPRLineStyle() =>
    switch cprLineStyleInput
        "Solid" => line.style_solid
        "Dotted" => line.style_dotted
        "Dashed" => line.style_dashed
        => line.style_solid

// Get line style for Next Day
getNextDayLineStyle() =>
    switch nextDayStyleInput
        "Solid" => line.style_solid
        "Dotted" => line.style_dotted
        "Dashed" => line.style_dashed
        => line.style_solid

calculateCPR(h, l, c) =>
    pp = (h + l + c) / 3
    tc = (h + l) / 2
    bc = (pp - tc) + pp
    array.from(tc, pp, bc)

localPivotTimeframeChange = timeframe.change(pivotTimeframe) and year % pivotYearMultiplier == 0
securityPivotTimeframeChange = timeframe.change(timeframe.period) and year % pivotYearMultiplier == 0

pivotTimeframeChangeCounter(condition) => 
    var count = 0
    if condition and bar_index > 0
        count += 1
    count

localPivots = ta.pivot_point_levels(pivotTypeInput, localPivotTimeframeChange)
securityPivotPointsArray = ta.pivot_point_levels(pivotTypeInput, securityPivotTimeframeChange)

securityTimeframe = timeframe.isintraday ? "1D" : timeframe.period

// Get OHLC data for CPR calculation
securityHigh = request.security(syminfo.tickerid, pivotTimeframe, high[1], lookahead = barmerge.lookahead_on)
securityLow = request.security(syminfo.tickerid, pivotTimeframe, low[1], lookahead = barmerge.lookahead_on)
securityClose = request.security(syminfo.tickerid, pivotTimeframe, close[1], lookahead = barmerge.lookahead_on)
localHigh = high[1]
localLow = low[1]
localClose = close[1]

// Get current day's OHLC for next day pivot calculation
currentHigh = isDailyBasedInput ? request.security(syminfo.tickerid, pivotTimeframe, high, lookahead = barmerge.lookahead_on) : high
currentLow = isDailyBasedInput ? request.security(syminfo.tickerid, pivotTimeframe, low, lookahead = barmerge.lookahead_on) : low
currentClose = isDailyBasedInput ? request.security(syminfo.tickerid, pivotTimeframe, close, lookahead = barmerge.lookahead_on) : close

//[securityPivots, securityPivotCounter] = request.security(syminfo.tickerid, pivotTimeframe, [securityPivotPointsArray, pivotTimeframeChangeCounter(securityPivotTimeframeChange)], lookahead = barmerge.lookahead_on)

//START

// Build pivots array and extend with previous high/low
pivotArr = ta.pivot_point_levels(pivotTypeInput, securityPivotTimeframeChange)
array.push(pivotArr, high[1])  // Previous High
array.push(pivotArr, low[1])   // Previous Low

security_pivots_with_prevhl() =>
    pivots = ta.pivot_point_levels(pivotTypeInput, securityPivotTimeframeChange)
    newArr = array.new<float>()
    // copy existing pivot levels
    for i = 0 to array.size(pivots) - 1
        array.push(newArr, array.get(pivots, i))
    // add previous high/low
    array.push(newArr, high[1])
    array.push(newArr, low[1])
    newArr


[securityPivots, securityPivotCounter] = request.security(syminfo.tickerid,pivotTimeframe,[ security_pivots_with_prevhl(), pivotTimeframeChangeCounter(securityPivotTimeframeChange) ],lookahead = barmerge.lookahead_on)




//END

pivotPointsArray = isDailyBasedInput ? securityPivots : localPivots

//START

prevHigh_val = array.get(securityPivots, array.size(securityPivots) - 2)
prevLow_val  = array.get(securityPivots, array.size(securityPivots) - 1)

//END

	
// Calculate next day pivot points manually using current day's HLC
calculateNextDayPivots(h, l, c, pivotType) =>
    var pivot = 0.0
    var r1 = 0.0
    var s1 = 0.0
    var r2 = 0.0
    var s2 = 0.0
    var r3 = 0.0
    var s3 = 0.0
    var r4 = 0.0
    var s4 = 0.0
    var r5 = 0.0
    var s5 = 0.0
    
    pivot := (h + l + c) / 3
    
    if pivotType == "Traditional"
        r1 := 2 * pivot - l
        s1 := 2 * pivot - h
        r2 := pivot + (h - l)
        s2 := pivot - (h - l)
        r3 := h + 2 * (pivot - l)
        s3 := l - 2 * (h - pivot)
        r4 := r3 + (h - l)
        s4 := s3 - (h - l)
        r5 := r4 + (h - l)
        s5 := s4 - (h - l)
        array.from(pivot, r1, s1, r2, s2, r3, s3, r4, s4, r5, s5)
    else if pivotType == "Fibonacci"
        r1 := pivot + 0.382 * (h - l)
        s1 := pivot - 0.382 * (h - l)
        r2 := pivot + 0.618 * (h - l)
        s2 := pivot - 0.618 * (h - l)
        r3 := pivot + (h - l)
        s3 := pivot - (h - l)
        array.from(pivot, r1, s1, r2, s2, r3, s3, na, na, na, na)
    else if pivotType == "Woodie"
        pivot := (h + l + 2 * c) / 4
        r1 := 2 * pivot - l
        s1 := 2 * pivot - h
        r2 := pivot + (h - l)
        s2 := pivot - (h - l)
        r3 := h + 2 * (pivot - l)
        s3 := l - 2 * (h - pivot)
        r4 := r3 + (h - l)
        s4 := s3 - (h - l)
        array.from(pivot, r1, s1, r2, s2, r3, s3, r4, s4, na, na)
    else if pivotType == "Classic"
        r1 := 2 * pivot - l
        s1 := 2 * pivot - h
        r2 := pivot + (h - l)
        s2 := pivot - (h - l)
        r3 := h + 2 * (pivot - l)
        s3 := l - 2 * (h - pivot)
        r4 := r3 + (h - l)
        s4 := s3 - (h - l)
        array.from(pivot, r1, s1, r2, s2, r3, s3, r4, s4, na, na)
    else if pivotType == "DM"
        x = h + l + c
        r1 := (x / 2) - l
        s1 := (x / 2) - h
        array.from(pivot, r1, s1, na, na, na, na, na, na, na, na)
    else if pivotType == "Camarilla"
        r1 := c + (h - l) * 0.0916
        s1 := c - (h - l) * 0.0916
        r2 := c + (h - l) * 0.1833
        s2 := c - (h - l) * 0.1833
        r3 := c + (h - l) * 0.275
        s3 := c - (h - l) * 0.275
        r4 := c + (h - l) * 0.55
        s4 := c - (h - l) * 0.55
        r5 := h / l * c
        s5 := c - (r5 - c)
        array.from(pivot, r1, s1, r2, s2, r3, s3, r4, s4, r5, s5)
    else
        array.from(pivot, na, na, na, na, na, na, na, na, na, na)

nextDayPivotLevels = calculateNextDayPivots(currentHigh, currentLow, currentClose, pivotTypeInput)
nextDayPivotPointsArray = array.new<float>()

// Convert to indexed array format like ta.pivot_point_levels
for i = 0 to array.size(nextDayPivotLevels) - 1
    array.push(nextDayPivotPointsArray, array.get(nextDayPivotLevels, i))

// Debug: Plot next day pivot point for testing
plotchar(showNextDayPivots and barstate.islast ? array.get(nextDayPivotPointsArray, 0) : na, "Next Day Pivot", "•", location.absolute, color.green, size=size.small)

// Calculate CPR levels
cprLevels = isDailyBasedInput ? calculateCPR(securityHigh, securityLow, securityClose) : calculateCPR(localHigh, localLow, localClose)
tcLevel = array.get(cprLevels, 0)
ppLevel = array.get(cprLevels, 1) 
bcLevel = array.get(cprLevels, 2)

//@function Sets the ending points of the currently active pivots to `endTime`.
affixOldPivots(endTime) =>
    if drawnGraphics.rows() > 0
        lastGraphics = drawnGraphics.row(drawnGraphics.rows() - 1)

        for graphic in lastGraphics
            graphic.pivotLine.set_x2(endTime)
            if positionLabelsInput == "Right"
                graphic.pivotLabel.set_x(endTime)

//@function Sets the ending points of the currently active CPR to `endTime`.
affixOldCPR(endTime) =>
    if array.size(drawnCPRGraphics) > 0
        lastCPR = array.get(drawnCPRGraphics, array.size(drawnCPRGraphics) - 1)
        if not na(lastCPR.tcLine)
            lastCPR.tcLine.set_x2(endTime)
        if not na(lastCPR.ppLine)
            lastCPR.ppLine.set_x2(endTime)
        if not na(lastCPR.bcLine)
            lastCPR.bcLine.set_x2(endTime)
        if positionLabelsInput == "Right"
            if not na(lastCPR.tcLabel)
                lastCPR.tcLabel.set_x(endTime)
            if not na(lastCPR.ppLabel)
                lastCPR.ppLabel.set_x(endTime)
            if not na(lastCPR.bcLabel)
                lastCPR.bcLabel.set_x(endTime)

//@function Delete old next day graphics
affixOldNextDayPivots() =>
    for graphic in drawnNextDayGraphics
        graphic.delete()
    array.clear(drawnNextDayGraphics)

//@function Draws pivot lines and labels from `startTime` to the approximate end of the period.
drawNewPivots(startTime) =>
    newGraphics = array.new<pivotGraphic>()

    // keep references for the lines/labels we need to shorten / fill
    var line r1Line = na
    var line s1Line = na
    var line prevHighLine = na
    var line prevLowLine  = na
    var label prevHighLabel = na
    var label prevLowLabel  = na

    // default end for normal pivot lines (as before)
    defaultLineEnd = startTime + timeframe.in_seconds(pivotTimeframe) * 1000 * pivotYearMultiplier

    for [index, coord] in pivotPointsArray
        levelSettings = graphicSettingsArray.get(index)
        if not na(coord) and levelSettings.showLevel
            pivotLine = line.new(startTime, coord, defaultLineEnd, coord, xloc = xloc.bar_time, color=levelSettings.levelColor, width=linewidthInput)
            pivotLabel = label.new(x = positionLabelsInput == "Left" ? startTime : defaultLineEnd,
                               y = coord,
                               text = (showLabelsInput ? levelSettings.levelName + " " : "") + (showPricesInput ? "(" + str.tostring(coord, format.mintick) + ")" : ""),
                               style = positionLabelsInput == "Left" ? label.style_label_right : label.style_label_left,
                               textcolor = levelSettings.levelColor,
                               color = #00000000,
                               xloc = xloc.bar_time)

            // Track references for prevHigh/prevLow and R1/S1
            if levelSettings.levelName == "R1"
                r1Line := pivotLine
            if levelSettings.levelName == "S1"
                s1Line := pivotLine
            if levelSettings.levelName == "Prev High"
                prevHighLine := pivotLine
                prevHighLabel := pivotLabel
            if levelSettings.levelName == "Prev Low"
                prevLowLine := pivotLine
                prevLowLabel := pivotLabel

            array.push(newGraphics, pivotGraphic.new(pivotLine, pivotLabel, na))

    // --- AFTER the loop: shorten Prev High / Prev Low to end same day ---
    // make prev lines end at the day boundary (startTime + 1 day)
    prevDayEnd = startTime + timeframe.in_seconds(pivotTimeframe) * 1000 * pivotYearMultiplier

    if not na(prevHighLine)
        prevHighLine.set_x2(prevDayEnd)
        if positionLabelsInput == "Right" and not na(prevHighLabel)
            prevHighLabel.set_x(prevDayEnd)

    if not na(prevLowLine)
        prevLowLine.set_x2(prevDayEnd)
        if positionLabelsInput == "Right" and not na(prevLowLabel)
            prevLowLabel.set_x(prevDayEnd)

    // Create fills (they will be limited because prevHigh/prevLow now end at day end)
    if not na(prevHighLine) and not na(r1Line)
        linefill.new(prevHighLine, r1Line, color.new(color.red, 85))  // light red fill
    if not na(prevLowLine) and not na(s1Line)
        linefill.new(prevLowLine, s1Line, color.new(color.green, 85)) // light green fill

    drawnGraphics.add_row(array_id = newGraphics)

    if drawnGraphics.rows() > maxHistoricalPivotsInput
        oldGraphics = drawnGraphics.remove_row(0)

        for graphic in oldGraphics
            graphic.delete()

//@function Draws next day pivot lines and labels
drawNextDayPivots() =>
    if showNextDayPivots
        // Clear previous next day graphics only on last bar
        if barstate.islast
            affixOldNextDayPivots()
        
        // Calculate tomorrow's start and end time - extend lines further into the future
        tomorrowStart = time
        tomorrowEnd = time + timeframe.in_seconds(pivotTimeframe) * 1000 * 2  // Extend 2 periods ahead
        
        nextDayLineStyle = getNextDayLineStyle()
        
        if barstate.islast
            for index = 0 to array.size(nextDayPivotPointsArray) - 1
                coord = array.get(nextDayPivotPointsArray, index)
                if not na(coord) and index < array.size(nextDayGraphicSettingsArray)
                    levelSettings = nextDayGraphicSettingsArray.get(index)
                    if levelSettings.showLevel and index < array.size(graphicSettingsArray)
                        regularLevelSettings = graphicSettingsArray.get(index)
                        if regularLevelSettings.showLevel
                            // Create the line first
                            pivotLine = line.new(tomorrowStart, coord, tomorrowEnd, coord, 
                                               xloc = xloc.bar_time, 
                                               color = levelSettings.levelColor, 
                                               width = nextDayWidthInput, 
                                               style = nextDayLineStyle,
                                               extend = extend.right)  // Extend line to the right
                            
                            // Create the label
                            pivotLabel = label.new(x = positionLabelsInput == "Left" ? tomorrowStart : tomorrowEnd,
                                                 y = coord,
                                                 text = (showLabelsInput ? levelSettings.levelName + " " : "") + (showPricesInput ? "(" + str.tostring(coord, format.mintick) + ")" : ""),
                                                 style = positionLabelsInput == "Left" ? label.style_label_right : label.style_label_left,
                                                 textcolor = levelSettings.levelColor,
                                                 color = color.new(color.white, 80),  // Semi-transparent background
                                                 xloc = xloc.bar_time)
                            
                            // Store the graphics
                            drawnNextDayGraphics.push(pivotGraphic.new(pivotLine, pivotLabel))

//@function Draws CPR lines and labels from `startTime` to the approximate end of the period.
drawNewCPR(startTime) =>
    if showCPRInput and not na(tcLevel) and not na(ppLevel) and not na(bcLevel)
        lineEndTime = startTime + timeframe.in_seconds(pivotTimeframe) * 1000 * pivotYearMultiplier
        lineStyle = getCPRLineStyle()
        
        // Create CPR lines with individual controls
        tcLine = showTCInput ? line.new(startTime, tcLevel, lineEndTime, tcLevel, xloc = xloc.bar_time, color=cprColorInput, width=cprWidthInput, style=lineStyle) : na
        ppLine = showPPInput ? line.new(startTime, ppLevel, lineEndTime, ppLevel, xloc = xloc.bar_time, color=cprColorInput, width=cprWidthInput, style=lineStyle) : na
        bcLine = showBCInput ? line.new(startTime, bcLevel, lineEndTime, bcLevel, xloc = xloc.bar_time, color=cprColorInput, width=cprWidthInput, style=lineStyle) : na
        
        // Create CPR labels
        tcLabel = showTCInput and (showLabelsInput or showPricesInput) ? label.new(x = positionLabelsInput == "Left" ? startTime : lineEndTime,
                           y = tcLevel,
                           text = (showLabelsInput ? "TC " : "") + (showPricesInput ? "(" + str.tostring(tcLevel, format.mintick) + ")" : ""),
                           style = positionLabelsInput == "Left" ? label.style_label_right : label.style_label_left,
                           textcolor = tcColorInput,
                           color = #00000000,
                           xloc=xloc.bar_time) : na
        
        ppLabel = showPPInput and (showLabelsInput or showPricesInput) ? label.new(x = positionLabelsInput == "Left" ? startTime : lineEndTime,
                           y = ppLevel,
                           text = (showLabelsInput ? "PP " : "") + (showPricesInput ? "(" + str.tostring(ppLevel, format.mintick) + ")" : ""),
                           style = positionLabelsInput == "Left" ? label.style_label_right : label.style_label_left,
                           textcolor = ppColorInput,
                           color = #00000000,
                           xloc=xloc.bar_time) : na
        
        bcLabel = showBCInput and (showLabelsInput or showPricesInput) ? label.new(x = positionLabelsInput == "Left" ? startTime : lineEndTime,
                           y = bcLevel,
                           text = (showLabelsInput ? "BC " : "") + (showPricesInput ? "(" + str.tostring(bcLevel, format.mintick) + ")" : ""),
                           style = positionLabelsInput == "Left" ? label.style_label_right : label.style_label_left,
                           textcolor = bcColorInput,
                           color = #00000000,
                           xloc=xloc.bar_time) : na
        
        // Create CPR fill (only if both TC and BC lines are visible)
        cprFill = fillCPRInput and showTCInput and showBCInput and not na(tcLine) and not na(bcLine) ? linefill.new(tcLine, bcLine, color.new(cprColorInput, cprTransparencyInput)) : na
        
        // Store CPR graphics
        newCPR = cprGraphic.new(tcLine, ppLine, bcLine, tcLabel, ppLabel, bcLabel, cprFill)
        array.push(drawnCPRGraphics, newCPR)
        
        // Limit historical CPR graphics
        if array.size(drawnCPRGraphics) > maxHistoricalPivotsInput
            oldCPR = array.shift(drawnCPRGraphics)
            oldCPR.delete()

localPivotDrawConditionStatic = not isDailyBasedInput and localPivotTimeframeChange
securityPivotDrawConditionStatic = isDailyBasedInput and securityPivotCounter != securityPivotCounter[1]

var isMultiYearly = array.from("Biyearly", "Triyearly", "Quinquennially", "Decennially").includes(pivotAnchorInput)
localPivotDrawConditionDeveloping = not isDailyBasedInput and time_close == time_close(pivotTimeframe) and not isMultiYearly 
securityPivotDrawConditionDeveloping = false

if (securityPivotDrawConditionStatic or localPivotDrawConditionStatic)
    affixOldPivots(time)
    affixOldCPR(time)
    drawNewPivots(time)
    drawNewCPR(time)

// Draw next day pivots on last bar only
if barstate.islast
    drawNextDayPivots()

// If possible, draw pivots from the beginning of the chart if none were found
var FIRST_BAR_TIME = time
if (barstate.islastconfirmedhistory and drawnGraphics.columns() == 0)

    if not na(securityPivots) and securityPivotCounter > 0
        if isDailyBasedInput
            drawNewPivots(FIRST_BAR_TIME)
            drawNewCPR(FIRST_BAR_TIME)
        else 
            runtime.error("Not enough intraday data to calculate Pivot Points. Lower the Pivots Timeframe or turn on the 'Use Daily-based Values' option in the indicator settings.")
    else
        runtime.error("Not enough data to calculate Pivot Points. Lower the Pivots Timeframe in the indicator settings.")
````
