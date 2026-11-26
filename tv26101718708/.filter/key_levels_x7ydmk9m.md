# Key Levels 

- url: https://www.tradingview.com/script/x7YDmk9M-Key-Levels/
- type: indicator
- pine_id: PUB;f300cc87e5d54cc580fbf961108ff5e5
- version: 1.0

## Description

🔑 Levels  is a clean intraday trading indicator designed to highlight key session levels, previous day high/low, liquidity zones, FVGs, skips, and Balanced Price Ranges.

It plots Asian and London session highs/lows, PDH/PDL, optional EMA 21/50, and a vertical PDH/PDL range HUD showing where price is located inside the previous day range. The indicator also includes a first 15-minute range breakout tool for Asian, London, and New York sessions, with breakout FVG candle coloring, entry/SL guide lines, and customizable visual settings.

Built for traders who focus on session levels, liquidity, fair value gaps, and intraday breakout/retest setups.

## Source Code

````pine
//@version=6
indicator("🔑 Levels ", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupEMA = "EMA"
showEMA21   = input.bool(true, "Show EMA 21", group=groupEMA)
ema21Length = input.int(21, "EMA 21 Length", minval=1, maxval=500, group=groupEMA)
ema21Color  = input.color(color.new(color.navy, 50), "EMA 21 Color", group=groupEMA)
ema21Width  = input.int(1, "EMA 21 Width", minval=1, maxval=5, group=groupEMA)

showEMA50   = input.bool(false, "Show EMA 50", group=groupEMA)
ema50Length = input.int(50, "EMA 50 Length", minval=1, maxval=500, group=groupEMA)
ema50Color  = input.color(color.new(color.orange, 0), "EMA 50 Color", group=groupEMA)
ema50Width  = input.int(2, "EMA 50 Width", minval=1, maxval=5, group=groupEMA)

groupSessions = "Session Levels"
showSessionLevels = input.bool(true, "Show Session Levels", group=groupSessions)
asianSess  = input.session("1800-0000", "Asian Session", group=groupSessions)
londonSess = input.session("0000-0600", "London Session", group=groupSessions)
sessTz     = input.string("America/New_York", "Session Timezone", group=groupSessions)
forwardBars = input.int(15, "Extend Lines N Candles Ahead", minval=1, maxval=500, group=groupSessions)

sessionLineColor = input.color(color.new(color.gray, 0), "Session Line Color", group=groupSessions)
sessionLineWidth = input.int(1, "Session Line Width", minval=1, maxval=5, group=groupSessions)
showSessionLabels = input.bool(true, "Show Session Labels", group=groupSessions)

groupPD = "Previous Day High / Low"
showPDH_PDL = input.bool(true, "Show PDH / PDL", group=groupPD)
pdhpdlColor = input.color(color.red, "PDH / PDL Color", group=groupPD)
pdhpdlWidth = input.int(1, "PDH / PDL Width", minval=1, maxval=5, group=groupPD)
showPDH_PDL_HUD = input.bool(true, "Show PDH / PDL HUD Corners", group=groupPD)
hudTextSizeStr = input.string("small", "HUD Font Size", options=["tiny", "small", "normal"], group=groupPD)

groupZones = "Skips / FVG"
showSkips = input.bool(true, "Show Skips", group=groupZones)
showFVGs  = input.bool(true, "Show FVGs", group=groupZones)

skipBullFill = input.color(color.new(color.green, 50), "Skip Bullish Fill", group=groupZones)
skipBearFill = input.color(color.new(color.red, 50), "Skip Bearish Fill", group=groupZones)

fvgBullFill = input.color(color.new(color.green, 85), "FVG Bullish Fill", group=groupZones)
fvgBearFill = input.color(color.new(color.red, 85), "FVG Bearish Fill", group=groupZones)

groupBPR = "Balanced Price Range"
showBPR = input.bool(true, "Show BPR Boxes", group=groupBPR)
bprLookbackBars = input.int(20, "Bars To Look Back", minval=1, maxval=500, group=groupBPR)
bprExtendBars = input.int(1, "BPR Length / Extension Bars", minval=1, maxval=500, group=groupBPR)
deleteInvalidBPR = input.bool(false, "Delete Invalidated BPR", group=groupBPR)
showBprTime = input.bool(true, "Show BPR Time Length", group=groupBPR)
timeTextColor = input.color(color.white, "BPR Timer Text Color", group=groupBPR)

bullBprColor = input.color(color.new(color.green, 75), "Bullish BPR Color", group=groupBPR)
bearBprColor = input.color(color.new(color.red, 75), "Bearish BPR Color", group=groupBPR)

maxBoxes = input.int(300, "Max Visual Boxes", minval=50, maxval=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SESSION 15-MIN RANGE BREAKOUT ADD-ON
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupInitialRange = "Session 15-Min Range Breakout Add-On"
showInitialRange = input.bool(true, "Show First 15-Min Session High / Low", group=groupInitialRange)
useAsianInitialRange = input.bool(true, "Use Asian Session", group=groupInitialRange)
useLondonInitialRange = input.bool(true, "Use London Session", group=groupInitialRange)
useNYInitialRange = input.bool(true, "Use New York Session", group=groupInitialRange)

nyRangeSess = input.session("0930-1700", "New York Session", group=groupInitialRange)
initialRangeTz = input.string("America/New_York", "Range Timezone", group=groupInitialRange)
initialRangeLenMin = input.int(15, "Range Length Minutes", minval=1, maxval=120, group=groupInitialRange)
initialEarlyTouchMin = input.int(2, "Dotted Prep Window Minutes Before Lock", minval=0, maxval=10, group=groupInitialRange)

initialRangeColor = input.color(color.fuchsia, "Purple Range Line Color", group=groupInitialRange)
initialRangeWidth = input.int(2, "Locked Range Line Width", minval=1, maxval=5, group=groupInitialRange)
initialTempWidth = input.int(1, "Dotted Prep Line Width", minval=1, maxval=5, group=groupInitialRange)
showInitialTempLines = input.bool(true, "Show Dotted Prep Lines", group=groupInitialRange)

showBreakoutFvgCandle = input.bool(true, "Color Breakout FVG Candles", group=groupInitialRange)
maxBreakoutTriggersPerSession = input.int(3, "Max Breakout Triggers Per Session", minval=1, maxval=50, group=groupInitialRange)
tolTicksBO = input.int(1, "Breakout Touch Tolerance Ticks", minval=0, maxval=10, group=groupInitialRange)
bullColorBO = input.color(color.new(color.green, 0), "Green Bull Break Candle", group=groupInitialRange)
bearColorBO = input.color(color.new(color.red, 0), "Red Bear Break Candle", group=groupInitialRange)

showFvg1Measure = input.bool(true, "1st FVG Entry/SL", group=groupInitialRange, inline="m1")
fvg1EntryPctBO = input.float(50.0, "Bear Entry %", minval=0, maxval=100, step=0.1, group=groupInitialRange, inline="m1")
fvg1SlExtPctBO = input.float(0.0, "SL Offset %", minval=0, maxval=200, step=0.1, group=groupInitialRange, inline="m1")
fvg1SlModeBO = input.string("Middle Candle Extreme", "1st FVG SL Mode", options=["Middle Candle Extreme", "FVG Edge"], group=groupInitialRange)

showFvg2Measure = input.bool(true, "2nd FVG Entry/SL", group=groupInitialRange, inline="m2")
fvg2EntryPctBO = input.float(50.0, "Bear Entry %", minval=0, maxval=100, step=0.1, group=groupInitialRange, inline="m2")
fvg2SlExtPctBO = input.float(0.0, "SL Offset %", minval=0, maxval=200, step=0.1, group=groupInitialRange, inline="m2")
fvg2SlModeBO = input.string("FVG Edge", "2nd FVG SL Mode", options=["Middle Candle Extreme", "FVG Edge"], group=groupInitialRange)

measureLineExtendBars = input.int(3, "Entry / SL Line Extend Bars", minval=0, maxval=500, group=groupInitialRange)
measureLabelOffsetBars = input.int(3, "Entry / SL Label Offset Bars", minval=0, maxval=500, group=groupInitialRange)
bullEntryColorBO = input.color(color.green, "Bull Entry Line/Text", group=groupInitialRange)
bullSlColorBO = input.color(color.new(color.green, 0), "Bull SL Line/Text", group=groupInitialRange)
bearEntryColorBO = input.color(color.red, "Bear Entry Line/Text", group=groupInitialRange)
bearSlColorBO = input.color(color.new(color.red, 0), "Bear SL Line/Text", group=groupInitialRange)
measureLineWidth = input.int(1, "Entry / SL Line Width", minval=1, maxval=5, group=groupInitialRange)

maxLabelMs = 23 * 60 * 60 * 1000

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bodyHi(i) => math.max(open[i], close[i])
bodyLo(i) => math.min(open[i], close[i])

formatDuration(ms) =>
    totalMinutes = math.floor(ms / 60000)
    hours = math.floor(totalMinutes / 60)
    minutes = totalMinutes % 60
    hours > 0 ? str.tostring(hours) + "h " + str.tostring(minutes) + "m" : str.tostring(minutes) + "m"

measureSizeOf(s) =>
    s == "tiny" ? size.tiny : s == "small" ? size.small : size.normal

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ema21Value = ta.ema(close, ema21Length)
ema50Value = ta.ema(close, ema50Length)

plot(showEMA21 ? ema21Value : na, title="EMA 21", color=ema21Color, linewidth=ema21Width)
plot(showEMA50 ? ema50Value : na, title="EMA 50", color=ema50Color, linewidth=ema50Width)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SESSION HIGH / LOW STATE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
inAsia   = not na(time(timeframe.period, asianSess, sessTz))
inLondon = not na(time(timeframe.period, londonSess, sessTz))

enterAsia   = inAsia and not inAsia[1]
enterLondon = inLondon and not inLondon[1]

var float asianHigh = na
var float asianLow = na
var int asianHighBar = na
var int asianLowBar = na

var float londonHigh = na
var float londonLow = na
var int londonHighBar = na
var int londonLowBar = na

var line asianHighLine = na
var line asianLowLine = na
var line londonHighLine = na
var line londonLowLine = na

var label asianHighLabel = na
var label asianLowLabel = na
var label londonHighLabel = na
var label londonLowLabel = na

if enterAsia
    asianHigh := high
    asianLow := low
    asianHighBar := bar_index
    asianLowBar := bar_index

if enterLondon
    londonHigh := high
    londonLow := low
    londonHighBar := bar_index
    londonLowBar := bar_index

if inAsia
    if na(asianHigh) or high > asianHigh
        asianHigh := high
        asianHighBar := bar_index
    if na(asianLow) or low < asianLow
        asianLow := low
        asianLowBar := bar_index

if inLondon
    if na(londonHigh) or high > londonHigh
        londonHigh := high
        londonHighBar := bar_index
    if na(londonLow) or low < londonLow
        londonLow := low
        londonLowBar := bar_index

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PREVIOUS DAY HIGH / LOW STATE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
newDay = ta.change(time("D")) != 0

var float curDayHigh = na
var float curDayLow = na
var int curDayHighBar = na
var int curDayLowBar = na

var float pdh = na
var float pdl = na
var int pdhBar = na
var int pdlBar = na

var line pdhLine = na
var line pdlLine = na
var label pdhLabel = na
var label pdlLabel = na

if barstate.isfirst
    curDayHigh := high
    curDayLow := low
    curDayHighBar := bar_index
    curDayLowBar := bar_index
else
    if newDay
        pdh := curDayHigh
        pdl := curDayLow
        pdhBar := curDayHighBar
        pdlBar := curDayLowBar

        curDayHigh := high
        curDayLow := low
        curDayHighBar := bar_index
        curDayLowBar := bar_index
    else
        if high > curDayHigh
            curDayHigh := high
            curDayHighBar := bar_index
        if low < curDayLow
            curDayLow := low
            curDayLowBar := bar_index

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAW HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
drawLine(_ln, _x1, _y, _col, _width) =>
    line result = _ln

    int safeX1 = math.max(_x1, bar_index - 1500)

    if na(result)
        result := line.new(safeX1, _y, bar_index + forwardBars, _y, extend=extend.none, color=_col, width=_width)
    else
        line.set_xy1(result, safeX1, _y)
        line.set_xy2(result, bar_index + forwardBars, _y)
        line.set_color(result, _col)
        line.set_width(result, _width)
    result

drawLabel(_lb, _txt, _y, _col) =>
    label result = _lb
    if showSessionLabels
        if na(result)
            result := label.new(bar_index + forwardBars, _y, _txt, style=label.style_label_left, textcolor=_col, color=color.new(color.white, 100), size=size.small)
        else
            label.set_x(result, bar_index + forwardBars)
            label.set_y(result, _y)
            label.set_text(result, _txt)
            label.set_textcolor(result, _col)
            label.set_color(result, color.new(color.white, 100))
    else
        if not na(result)
            label.set_text(result, "")
    result

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAW SESSION HIGH / LOW + PDH / PDL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if showSessionLevels
    if not na(asianHigh)
        asianHighLine := drawLine(asianHighLine, asianHighBar, asianHigh, sessionLineColor, sessionLineWidth)
        asianHighLabel := drawLabel(asianHighLabel, "Asian High", asianHigh, sessionLineColor)

    if not na(asianLow)
        asianLowLine := drawLine(asianLowLine, asianLowBar, asianLow, sessionLineColor, sessionLineWidth)
        asianLowLabel := drawLabel(asianLowLabel, "Asian Low", asianLow, sessionLineColor)

    if not na(londonHigh)
        londonHighLine := drawLine(londonHighLine, londonHighBar, londonHigh, sessionLineColor, sessionLineWidth)
        londonHighLabel := drawLabel(londonHighLabel, "London High", londonHigh, sessionLineColor)

    if not na(londonLow)
        londonLowLine := drawLine(londonLowLine, londonLowBar, londonLow, sessionLineColor, sessionLineWidth)
        londonLowLabel := drawLabel(londonLowLabel, "London Low", londonLow, sessionLineColor)

if showPDH_PDL
    if not na(pdh)
        pdhLine := drawLine(pdhLine, pdhBar, pdh, pdhpdlColor, pdhpdlWidth)
        pdhLabel := drawLabel(pdhLabel, "PDH", pdh, pdhpdlColor)

    if not na(pdl)
        pdlLine := drawLine(pdlLine, pdlBar, pdl, pdhpdlColor, pdhpdlWidth)
        pdlLabel := drawLabel(pdlLabel, "PDL", pdl, pdhpdlColor)
        //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NEW PDH / PDL VERTICAL RANGE HUD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupHudNew = "PDH / PDL Vertical HUD"

showVerticalHud = input.bool(true, "Show Vertical PDH / PDL HUD", group=groupHudNew)
hudRows = input.int(17, "HUD Height Rows", minval=11, maxval=23, group=groupHudNew)

hudBarWidth = input.int(1, "HUD Bar Thickness", minval=1, maxval=5, group=groupHudNew)

hudAttractionZonePct = input.float(
     25.0,
     "Attraction Zone Percentage",
     minval=1,
     maxval=49,
     step=0.5,
     group=groupHudNew)

hudGreen    = input.color(color.new(color.green, 0), "PDH Attraction Color", group=groupHudNew)
hudRed      = input.color(color.new(color.red, 0), "PDL Attraction Color", group=groupHudNew)
hudGray     = input.color(color.new(color.gray, 88), "Middle Color", group=groupHudNew)
hudTextGray = input.color(color.gray, "Outside / Middle Text", group=groupHudNew)

var table rangeHud = table.new(position.middle_right, 2, 29, frame_width=0, border_width=0)

if barstate.islast
    color blankBg = color.new(color.white, 100)
    color labelBg = color.white

    for r = 0 to 28
        table.cell(rangeHud, 0, r, "", width=4, bgcolor=blankBg)
        table.cell(rangeHud, 1, r, "", width=hudBarWidth, bgcolor=blankBg)

    if showVerticalHud and showPDH_PDL and not na(pdh) and not na(pdl) and pdh != pdl
        float pdhPdlRange = pdh - pdl
        float posPctRaw = (close - pdl) / pdhPdlRange * 100.0
        float posPctClamped = math.max(0.0, math.min(100.0, posPctRaw))

        bool abovePDH = posPctRaw > 100.0
        bool belowPDL = posPctRaw < 0.0
        bool outsideRange = abovePDH or belowPDL

        float distanceToPDH = math.abs(100.0 - posPctRaw)
        float distanceToPDL = math.abs(posPctRaw)
        float nearestPct = posPctRaw >= 50.0 ? distanceToPDH : distanceToPDL

        int totalRows = 29
        int barTopRow = int(math.floor((totalRows - hudRows) / 2))
        int barBottomRow = barTopRow + hudRows - 1

        int pdhLabelRow = math.max(barTopRow - 1, 0)
        int pdlLabelRow = math.min(barBottomRow + 1, totalRows - 1)

        int arrowRow =
             abovePDH ? barTopRow :
             belowPDL ? barBottomRow :
             int(math.round((100.0 - posPctClamped) / 100.0 * (hudRows - 1))) + barTopRow

        bool nearPDH = not outsideRange and posPctRaw >= 100.0 - hudAttractionZonePct
        bool nearPDL = not outsideRange and posPctRaw <= hudAttractionZonePct

        color pctColor =
             outsideRange ? hudTextGray :
             nearPDH ? hudGreen :
             nearPDL ? hudRed :
             hudTextGray

        string pctText =
             outsideRange ? str.tostring(nearestPct, "#.0") + "% outside" :
             str.tostring(nearestPct, "#.0") + "%"

        string arrowText = pctText + " ▶"

        string labelTextPDH = hudBarWidth <= 1 ? "H" : "PDH"
        string labelTextPDL = hudBarWidth <= 1 ? "L" : "PDL"

        string labelSize =
             hudBarWidth <= 2 ? size.tiny :
             hudBarWidth <= 4 ? size.small :
             size.normal

        table.cell(
             rangeHud,
             1,
             pdhLabelRow,
             labelTextPDH,
             width=hudBarWidth,
             bgcolor=labelBg,
             text_color=hudGreen,
             text_halign=text.align_center,
             text_size=labelSize)

        table.cell(
             rangeHud,
             1,
             pdlLabelRow,
             labelTextPDL,
             width=hudBarWidth,
             bgcolor=labelBg,
             text_color=hudRed,
             text_halign=text.align_center,
             text_size=labelSize)

        for r = 0 to hudRows - 1
            int tableRow = r + barTopRow
            float rowPct = 100.0 - (float(r) / math.max(float(hudRows - 1), 1.0)) * 100.0

            bool rowPDHZone = rowPct >= 100.0 - hudAttractionZonePct
            bool rowPDLZone = rowPct <= hudAttractionZonePct

            bool fillGreen = nearPDH and rowPDHZone
            bool fillRed = nearPDL and rowPDLZone

            color barBg =
                 rowPDHZone ? (fillGreen ? hudGreen : color.new(hudGreen, 92)) :
                 rowPDLZone ? (fillRed ? hudRed : color.new(hudRed, 92)) :
                 hudGray

            table.cell(
                 rangeHud,
                 0,
                 tableRow,
                 tableRow == arrowRow ? arrowText : "",
                 width=4,
                 bgcolor=blankBg,
                 text_color=pctColor,
                 text_halign=text.align_right,
                 text_size=size.tiny)

            table.cell(
                 rangeHud,
                 1,
                 tableRow,
                 "",
                 width=hudBarWidth,
                 bgcolor=barBg)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FIRST 15-MIN RANGE FOR ASIAN / LONDON / NEW YORK
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
rangeInAsia = showInitialRange and useAsianInitialRange and not na(time(timeframe.period, asianSess, initialRangeTz))
rangeInLondon = showInitialRange and useLondonInitialRange and not na(time(timeframe.period, londonSess, initialRangeTz))
rangeInNY = showInitialRange and useNYInitialRange and not na(time(timeframe.period, nyRangeSess, initialRangeTz))

rangeSessIdNow = rangeInAsia ? 1 : rangeInLondon ? 2 : rangeInNY ? 3 : 0
rangeSessChanged = rangeSessIdNow != rangeSessIdNow[1]
rangeSessStarted = rangeSessIdNow != 0 and rangeSessIdNow != rangeSessIdNow[1]

var int activeRangeSessId = 0
var int initialStartBar = na
var int initialStartTime = na
var float initialRangeHigh = na
var float initialRangeLow = na
var bool initialRangeLocked = false

var line initialHighLineLocked = na
var line initialLowLineLocked = na
var line initialHighLineTemp = na
var line initialLowLineTemp = na

var label initialHighPctLabel = na
var label initialLowPctLabel = na

purplePctText(_level) =>
    result = ""
    if not na(pdh) and not na(pdl) and pdh != pdl
        posPctRaw = (_level - pdl) / (pdh - pdl) * 100.0
        outsideRange = posPctRaw > 100.0 or posPctRaw < 0.0
        distanceToPDH = math.abs(100.0 - posPctRaw)
        distanceToPDL = math.abs(posPctRaw)
        nearestPct = posPctRaw >= 50.0 ? distanceToPDH : distanceToPDL
        result := outsideRange ? "outside" : str.tostring(nearestPct, "#.0") + "%"
    result

purplePctColor(_level) =>
    result = initialRangeColor
    if not na(pdh) and not na(pdl) and pdh != pdl
        posPctRaw = (_level - pdl) / (pdh - pdl) * 100.0
        outsideRange = posPctRaw > 100.0 or posPctRaw < 0.0
        nearPDH = not outsideRange and posPctRaw >= 100.0 - hudAttractionZonePct
        nearPDL = not outsideRange and posPctRaw <= hudAttractionZonePct
        result := outsideRange ? hudTextGray : nearPDH ? hudGreen : nearPDL ? hudRed : initialRangeColor
    result

if rangeSessChanged
    activeRangeSessId := rangeSessIdNow
    initialStartBar := rangeSessIdNow != 0 ? bar_index : na
    initialStartTime := rangeSessIdNow != 0 ? time : na
    initialRangeHigh := rangeSessIdNow != 0 ? high : na
    initialRangeLow := rangeSessIdNow != 0 ? low : na
    initialRangeLocked := false

    if not na(initialHighLineLocked)
        line.delete(initialHighLineLocked)
    if not na(initialLowLineLocked)
        line.delete(initialLowLineLocked)
    if not na(initialHighLineTemp)
        line.delete(initialHighLineTemp)
    if not na(initialLowLineTemp)
        line.delete(initialLowLineTemp)
    if not na(initialHighPctLabel)
        label.delete(initialHighPctLabel)
    if not na(initialLowPctLabel)
        label.delete(initialLowPctLabel)

    initialHighLineLocked := na
    initialLowLineLocked := na
    initialHighLineTemp := na
    initialLowLineTemp := na
    initialHighPctLabel := na
    initialLowPctLabel := na

initialRangeEndTime = not na(initialStartTime) ? initialStartTime + initialRangeLenMin * 60 * 1000 : na
initialEarlyStart = not na(initialRangeEndTime) ? initialRangeEndTime - initialEarlyTouchMin * 60 * 1000 : na

initialInWindow = activeRangeSessId != 0 and not na(initialRangeEndTime) and time < initialRangeEndTime
initialInPrepWindow = activeRangeSessId != 0 and showInitialTempLines and not initialRangeLocked and not na(initialEarlyStart) and time >= initialEarlyStart and time < initialRangeEndTime
initialAfterWindow = activeRangeSessId != 0 and not na(initialRangeEndTime) and time >= initialRangeEndTime

if initialInWindow
    initialRangeHigh := na(initialRangeHigh) ? high : math.max(initialRangeHigh, high)
    initialRangeLow := na(initialRangeLow) ? low : math.min(initialRangeLow, low)

if initialInPrepWindow and not na(initialRangeHigh) and not na(initialRangeLow)
    if na(initialHighLineTemp)
        initialHighLineTemp := line.new(bar_index - 1, initialRangeHigh, bar_index, initialRangeHigh, xloc=xloc.bar_index, extend=extend.none, color=initialRangeColor, width=initialTempWidth, style=line.style_dotted)
    if na(initialLowLineTemp)
        initialLowLineTemp := line.new(bar_index - 1, initialRangeLow, bar_index, initialRangeLow, xloc=xloc.bar_index, extend=extend.none, color=initialRangeColor, width=initialTempWidth, style=line.style_dotted)

    line.set_xy1(initialHighLineTemp, bar_index - 1, initialRangeHigh)
    line.set_xy2(initialHighLineTemp, bar_index, initialRangeHigh)
    line.set_xy1(initialLowLineTemp, bar_index - 1, initialRangeLow)
    line.set_xy2(initialLowLineTemp, bar_index, initialRangeLow)

if initialAfterWindow and not initialRangeLocked and not na(initialRangeHigh) and not na(initialRangeLow)
    initialRangeLocked := true

    if not na(initialHighLineTemp)
        line.delete(initialHighLineTemp)
    if not na(initialLowLineTemp)
        line.delete(initialLowLineTemp)

    initialHighLineTemp := na
    initialLowLineTemp := na

    initialHighLineLocked := line.new(initialStartBar, initialRangeHigh, bar_index + forwardBars, initialRangeHigh, xloc=xloc.bar_index, extend=extend.none, color=initialRangeColor, width=initialRangeWidth)
    initialLowLineLocked := line.new(initialStartBar, initialRangeLow, bar_index + forwardBars, initialRangeLow, xloc=xloc.bar_index, extend=extend.none, color=initialRangeColor, width=initialRangeWidth)

if initialRangeLocked and activeRangeSessId != 0 and not na(initialHighLineLocked) and not na(initialLowLineLocked)
    line.set_xy1(initialHighLineLocked, initialStartBar, initialRangeHigh)
    line.set_xy2(initialHighLineLocked, bar_index + forwardBars, initialRangeHigh)
    line.set_xy1(initialLowLineLocked, initialStartBar, initialRangeLow)
    line.set_xy2(initialLowLineLocked, bar_index + forwardBars, initialRangeLow)

    highPctText = purplePctText(initialRangeHigh)
    lowPctText = purplePctText(initialRangeLow)
    highPctColor = purplePctColor(initialRangeHigh)
    lowPctColor = purplePctColor(initialRangeLow)

    if highPctText != ""
        if na(initialHighPctLabel)
            initialHighPctLabel := label.new(bar_index + forwardBars, initialRangeHigh, highPctText, style=label.style_label_left, textcolor=highPctColor, color=color.new(color.white, 100), size=size.tiny)
        else
            label.set_x(initialHighPctLabel, bar_index + forwardBars)
            label.set_y(initialHighPctLabel, initialRangeHigh)
            label.set_text(initialHighPctLabel, highPctText)
            label.set_textcolor(initialHighPctLabel, highPctColor)
            label.set_color(initialHighPctLabel, color.new(color.white, 100))
            label.set_size(initialHighPctLabel, size.tiny)

    if lowPctText != ""
        if na(initialLowPctLabel)
            initialLowPctLabel := label.new(bar_index + forwardBars, initialRangeLow, lowPctText, style=label.style_label_left, textcolor=lowPctColor, color=color.new(color.white, 100), size=size.tiny)
        else
            label.set_x(initialLowPctLabel, bar_index + forwardBars)
            label.set_y(initialLowPctLabel, initialRangeLow)
            label.set_text(initialLowPctLabel, lowPctText)
            label.set_textcolor(initialLowPctLabel, lowPctColor)
            label.set_color(initialLowPctLabel, color.new(color.white, 100))
            label.set_size(initialLowPctLabel, size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SKIPS — NO BORDERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var box[] skipBoxes = array.new_box()

if showSkips and bar_index > 0
    if bodyHi(1) < bodyLo(0)
        box b = box.new(bar_index - 1, bodyLo(0), bar_index, bodyHi(1), bgcolor=skipBullFill, border_color=color.new(skipBullFill, 100))
        array.push(skipBoxes, b)

    if bodyLo(1) > bodyHi(0)
        box b = box.new(bar_index - 1, bodyLo(1), bar_index, bodyHi(0), bgcolor=skipBearFill, border_color=color.new(skipBearFill, 100))
        array.push(skipBoxes, b)

    while array.size(skipBoxes) > maxBoxes
        box.delete(array.shift(skipBoxes))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FVG DETECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bullFVG = bar_index > 2 and high[2] < low
bearFVG = bar_index > 2 and low[2] > high

bullFvgLow = high[2]
bullFvgHigh = low

bearFvgLow = high
bearFvgHigh = low[2]

curType = bullFVG ? 1 : bearFVG ? -1 : 0
curLow = bullFVG ? bullFvgLow : bearFVG ? bearFvgLow : na
curHigh = bullFVG ? bullFvgHigh : bearFVG ? bearFvgHigh : na
curStartBar = bar_index - 2
curEndBar = bar_index
curStartTime = time[2]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FVG VISUALS — NO BORDERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var box[] fvgBoxes = array.new_box()

if showFVGs and bullFVG
    box b = box.new(bar_index - 1, bullFvgHigh, bar_index, bullFvgLow, bgcolor=fvgBullFill, border_color=color.new(fvgBullFill, 100))
    array.push(fvgBoxes, b)

if showFVGs and bearFVG
    box b = box.new(bar_index - 1, bearFvgHigh, bar_index, bearFvgLow, bgcolor=fvgBearFill, border_color=color.new(fvgBearFill, 100))
    array.push(fvgBoxes, b)

while array.size(fvgBoxes) > maxBoxes
    box.delete(array.shift(fvgBoxes))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SAVED FVGs FOR BPR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var int[] fvgTypes = array.new_int()
var float[] fvgLows = array.new_float()
var float[] fvgHighs = array.new_float()
var int[] fvgStartBars = array.new_int()
var int[] fvgEndBars = array.new_int()
var int[] fvgStartTimes = array.new_int()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BPR STORAGE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var box[] bprBoxes = array.new_box()
var int[] bprTypes = array.new_int()
var int[] bprCreatedBars = array.new_int()
var int[] bprStartTimes = array.new_int()
var label[] bprLabels = array.new_label()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EXTEND / INVALIDATE BPR + TIMER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if array.size(bprBoxes) > 0
    int x = array.size(bprBoxes) - 1

    while x >= 0
        box bx = array.get(bprBoxes, x)
        int typ = array.get(bprTypes, x)
        int made = array.get(bprCreatedBars, x)
        int startTime = array.get(bprStartTimes, x)
        label lb = array.get(bprLabels, x)

        float top = box.get_top(bx)
        float bot = box.get_bottom(bx)
        float mid = (top + bot) / 2.0

        int durationMs = time - startTime

        bool bullInvalid = typ == 1 and bar_index > made and low < bot
        bool bearInvalid = typ == -1 and bar_index > made and high > top
        bool invalidated = bullInvalid or bearInvalid

        if not showBPR
            box.set_bgcolor(bx, color.new(color.white, 100))
            box.set_border_color(bx, color.new(color.white, 100))
            box.set_right(bx, bar_index + bprExtendBars)

            if not na(lb)
                label.delete(lb)
                array.set(bprLabels, x, na)

        else if invalidated
            box.set_right(bx, bar_index)

            if not na(lb)
                label.delete(lb)

            if deleteInvalidBPR
                box.delete(bx)

            array.remove(bprBoxes, x)
            array.remove(bprTypes, x)
            array.remove(bprCreatedBars, x)
            array.remove(bprStartTimes, x)
            array.remove(bprLabels, x)

        else
            color liveColor = typ == 1 ? bullBprColor : bearBprColor
            box.set_bgcolor(bx, liveColor)
            box.set_border_color(bx, liveColor)
            box.set_right(bx, bar_index + bprExtendBars)

            bool showLabelNow = showBprTime and durationMs < maxLabelMs

            if showLabelNow
                if na(lb)
                    lb := label.new(bar_index, mid, formatDuration(durationMs), style=label.style_none, textcolor=timeTextColor, size=size.tiny)
                    array.set(bprLabels, x, lb)
                else
                    label.set_x(lb, bar_index)
                    label.set_y(lb, mid)
                    label.set_text(lb, formatDuration(durationMs))
                    label.set_textcolor(lb, timeTextColor)
            else
                if not na(lb)
                    label.delete(lb)
                    array.set(bprLabels, x, na)

        x -= 1
        //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BPR DETECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if showBPR and curType != 0 and array.size(fvgTypes) > 0
    int x = array.size(fvgTypes) - 1

    while x >= 0
        int oldType = array.get(fvgTypes, x)
        float oldLow = array.get(fvgLows, x)
        float oldHigh = array.get(fvgHighs, x)
        int oldStartBar = array.get(fvgStartBars, x)
        int oldEndBar = array.get(fvgEndBars, x)
        int oldStartTime = array.get(fvgStartTimes, x)

        int distance = curEndBar - oldEndBar

        if oldType == -curType and distance <= bprLookbackBars
            float bprLow = math.max(curLow, oldLow)
            float bprHigh = math.min(curHigh, oldHigh)

            bool validBPR = bprHigh > bprLow

            if validBPR
                int checkStart = oldEndBar + 1
                int checkEnd = curStartBar - 1

                if checkEnd >= checkStart
                    for testBar = checkStart to checkEnd
                        int barsAgo = bar_index - testBar
                        float candleHigh = high[barsAgo]
                        float candleLow = low[barsAgo]

                        bool touchesZone = candleHigh > bprLow and candleLow < bprHigh

                        if touchesZone
                            if candleLow <= bprLow and candleHigh < bprHigh
                                bprLow := math.max(bprLow, candleHigh)
                            else if candleHigh >= bprHigh and candleLow > bprLow
                                bprHigh := math.min(bprHigh, candleLow)
                            else
                                validBPR := false

                        if bprHigh <= bprLow
                            validBPR := false

                if validBPR
                    color colorUsed = curType == 1 ? bullBprColor : bearBprColor

                    box bx = box.new(oldStartBar, bprHigh, bar_index + bprExtendBars, bprLow, border_color=colorUsed, bgcolor=colorUsed)

                    int durationMs = time - oldStartTime
                    label lb = showBprTime and durationMs < maxLabelMs ? label.new(bar_index, (bprHigh + bprLow) / 2.0, formatDuration(durationMs), style=label.style_none, textcolor=timeTextColor, size=size.tiny) : na

                    array.push(bprBoxes, bx)
                    array.push(bprTypes, curType)
                    array.push(bprCreatedBars, bar_index)
                    array.push(bprStartTimes, oldStartTime)
                    array.push(bprLabels, lb)

                    while array.size(bprBoxes) > maxBoxes
                        box oldBox = array.shift(bprBoxes)
                        box.delete(oldBox)

                        label oldLabel = array.shift(bprLabels)
                        if not na(oldLabel)
                            label.delete(oldLabel)

                        array.shift(bprTypes)
                        array.shift(bprCreatedBars)
                        array.shift(bprStartTimes)

        x -= 1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SAVE CURRENT FVG FOR FUTURE BPR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if curType != 0
    array.push(fvgTypes, curType)
    array.push(fvgLows, curLow)
    array.push(fvgHighs, curHigh)
    array.push(fvgStartBars, curStartBar)
    array.push(fvgEndBars, curEndBar)
    array.push(fvgStartTimes, curStartTime)

    if array.size(fvgTypes) > 500
        array.shift(fvgTypes)
        array.shift(fvgLows)
        array.shift(fvgHighs)
        array.shift(fvgStartBars)
        array.shift(fvgEndBars)
        array.shift(fvgStartTimes)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PART 6A — BREAKOUT ARMING + VALID FVG FILTER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

tolBO = tolTicksBO * syminfo.mintick

boReady =
     activeRangeSessId != 0 and
     initialRangeLocked and
     not na(initialRangeHigh) and
     not na(initialRangeLow) and
     bar_index >= 2

var bool bullScenarioArmed = false
var bool bearScenarioArmed = false

var int measuredFvgCount = 0

var bool tradedAbovePurple = false
var bool tradedBelowPurple = false

if rangeSessStarted
    bullScenarioArmed := false
    bearScenarioArmed := false

    tradedAbovePurple := false
    tradedBelowPurple := false

    measuredFvgCount := 0

if boReady
    if high > initialRangeHigh
        tradedAbovePurple := true

    if low < initialRangeLow
        tradedBelowPurple := true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BULLISH WICK RETEST
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullRetest =
     boReady and
     tradedAbovePurple and
     low <= initialRangeHigh and
     close > initialRangeHigh

if bullRetest
    bullScenarioArmed := true
    bearScenarioArmed := false

    measuredFvgCount := 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BEARISH WICK RETEST
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bearRetest =
     boReady and
     tradedBelowPurple and
     high >= initialRangeLow and
     close < initialRangeLow

if bearRetest
    bearScenarioArmed := true
    bullScenarioArmed := false

    measuredFvgCount := 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FVG DETECTION FOR BREAKOUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Bullish FVG boundaries
bullFvgBottomBO = high[2]
bullFvgTopBO    = low

// Bearish FVG boundaries
bearFvgTopBO    = low[2]
bearFvgBottomBO = high

rawBullBreakFvg =
     boReady and
     bullScenarioArmed and
     low > high[2]

rawBearBreakFvg =
     boReady and
     bearScenarioArmed and
     high < low[2]

// Bullish FVG must touch or be above the upper purple line
bullFvgTouchesUpper =
     (bullFvgBottomBO - tolBO) <= initialRangeHigh and
     initialRangeHigh <= (bullFvgTopBO + tolBO)

bullFvgFullyAbove =
     bullFvgBottomBO >= initialRangeHigh - tolBO

validBullBreakFvg =
     rawBullBreakFvg and
     (bullFvgTouchesUpper or bullFvgFullyAbove)

// Bearish FVG must touch or be below the lower purple line
bearFvgTouchesLower =
     (bearFvgBottomBO - tolBO) <= initialRangeLow and
     initialRangeLow <= (bearFvgTopBO + tolBO)

bearFvgFullyBelow =
     bearFvgTopBO <= initialRangeLow + tolBO

validBearBreakFvg =
     rawBearBreakFvg and
     (bearFvgTouchesLower or bearFvgFullyBelow)

// Final breakout triggers
bullBreakFvg =
     validBullBreakFvg

bearBreakFvg =
     validBearBreakFvg

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLOR BREAKOUT CANDLES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

barcolor(
     showBreakoutFvgCandle ?
     bullBreakFvg ? bullColorBO :
     bearBreakFvg ? bearColorBO :
     na
     : na
)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PART 6B — CORRECTED FVG MEASUREMENTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var line fvg1EntryLine = na
var line fvg1SlLine = na
var label fvg1EntryLabel = na
var label fvg1SlLabel = na

var line fvg2EntryLine = na
var line fvg2SlLine = na
var label fvg2EntryLabel = na
var label fvg2SlLabel = na

if bullRetest or bearRetest or rangeSessStarted

    if not na(fvg1EntryLine)
        line.delete(fvg1EntryLine)
    if not na(fvg1SlLine)
        line.delete(fvg1SlLine)
    if not na(fvg1EntryLabel)
        label.delete(fvg1EntryLabel)
    if not na(fvg1SlLabel)
        label.delete(fvg1SlLabel)

    if not na(fvg2EntryLine)
        line.delete(fvg2EntryLine)
    if not na(fvg2SlLine)
        line.delete(fvg2SlLine)
    if not na(fvg2EntryLabel)
        label.delete(fvg2EntryLabel)
    if not na(fvg2SlLabel)
        label.delete(fvg2SlLabel)

    fvg1EntryLine := na
    fvg1SlLine := na
    fvg1EntryLabel := na
    fvg1SlLabel := na

    fvg2EntryLine := na
    fvg2SlLine := na
    fvg2EntryLabel := na
    fvg2SlLabel := na

newMeasuredFvg =
     (bullBreakFvg or bearBreakFvg) and
     measuredFvgCount < 2

if newMeasuredFvg

    int fvgNumber = measuredFvgCount + 1

    bool showMeasurement =
         fvgNumber == 1 ? showFvg1Measure :
         fvgNumber == 2 ? showFvg2Measure :
         false

    if showMeasurement

        float entryLevel = na
        float slLevel = na

        float bearEntryPctUsed = fvgNumber == 1 ? fvg1EntryPctBO : fvg2EntryPctBO
        float bullEntryPctUsed = 100.0 - bearEntryPctUsed
        float slOffsetPctUsed = fvgNumber == 1 ? fvg1SlExtPctBO : fvg2SlExtPctBO
        string slModeUsed = fvgNumber == 1 ? fvg1SlModeBO : fvg2SlModeBO

        string tradeText = ""

        color entryColor = na
        color slColor = na

        if bullBreakFvg

            float fvgBottom = high[2]
            float fvgTop = low
            float fvgSize = fvgTop - fvgBottom

            entryLevel :=
                 fvgBottom + (fvgSize * bullEntryPctUsed / 100.0)

            float slBase =
                 slModeUsed == "Middle Candle Extreme" ? low[1] :
                 fvgBottom

            slLevel :=
                 slBase - (fvgSize * slOffsetPctUsed / 100.0)

            tradeText := "BUY"
            entryColor := bullEntryColorBO
            slColor := bullSlColorBO

        if bearBreakFvg

            float fvgTop = low[2]
            float fvgBottom = high
            float fvgSize = fvgTop - fvgBottom

            entryLevel :=
                 fvgBottom + (fvgSize * bearEntryPctUsed / 100.0)

            float slBase =
                 slModeUsed == "Middle Candle Extreme" ? high[1] :
                 fvgTop

            slLevel :=
                 slBase + (fvgSize * slOffsetPctUsed / 100.0)

            tradeText := "SELL"
            entryColor := bearEntryColorBO
            slColor := bearSlColorBO

        int x1 = bar_index - 2
        int x2 = bar_index + measureLineExtendBars
        int labelX = bar_index + measureLabelOffsetBars

        line entryLine =
             line.new(
                 x1,
                 entryLevel,
                 x2,
                 entryLevel,
                 xloc=xloc.bar_index,
                 color=entryColor,
                 width=measureLineWidth)

        line slLine =
             line.new(
                 x1,
                 slLevel,
                 x2,
                 slLevel,
                 xloc=xloc.bar_index,
                 color=slColor,
                 width=measureLineWidth)

        label entryLabel =
             label.new(
                 labelX,
                 entryLevel,
                 tradeText,
                 style=label.style_label_left,
                 textcolor=entryColor,
                 color=color.new(color.white,100),
                 size=size.tiny)

        label stopLabel =
             label.new(
                 labelX,
                 slLevel,
                 "SL",
                 style=label.style_label_left,
                 textcolor=slColor,
                 color=color.new(color.white,100),
                 size=size.tiny)

        if fvgNumber == 1

            fvg1EntryLine := entryLine
            fvg1SlLine := slLine
            fvg1EntryLabel := entryLabel
            fvg1SlLabel := stopLabel

        if fvgNumber == 2

            fvg2EntryLine := entryLine
            fvg2SlLine := slLine
            fvg2EntryLabel := entryLabel
            fvg2SlLabel := stopLabel

    measuredFvgCount += 1

    if measuredFvgCount >= 2
        bullScenarioArmed := false
        bearScenarioArmed := false
````
