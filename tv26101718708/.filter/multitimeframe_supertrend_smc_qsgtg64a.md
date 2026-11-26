# Multi-Timeframe Supertrend + SMC

- url: https://www.tradingview.com/script/qsGtG64a-Multi-Timeframe-Supertrend-SMC/
- type: indicator
- pine_id: PUB;e227306deca3447e80ebd01e75ad29d9
- version: 3.0

## Description

Multi-Timeframe Supertrend + SMC

Shows the higher timeframe supertrend with a colour changing EMA and shows the structure on the current timeframe all in a dashboard

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Multi-Timeframe Supertrend + MTF SMC", overlay = true, max_lines_count = 500, max_labels_count = 500)

// --- Groups ---
string G_ST = "Supertrend Settings"
string G_TF = "Timeframe Settings"
string G_TBL = "Dashboard Settings"
string G_SMC = "SMC Structure Settings"
string G_LINE = "SMC Line Settings"
string G_EMA = "200 EMA Settings"
string G_HTF_EMA = "Higher Timeframe EMA Settings"

// --- Supertrend Inputs ---
int atrLenInput = input.int(10, "ATR Length", minval = 1, group = G_ST, tooltip = "ATR period used by the Supertrend calculations.")
float factorInput = input.float(3.0, "Factor", minval = 0.01, step = 0.01, group = G_ST, tooltip = "Multiplier applied to the ATR bands.")
bool showLinesInput = input.bool(true, "Show Current Supertrend Line", group = G_ST, tooltip = "Show the Supertrend line for the active chart timeframe.")

// --- Timeframe Inputs ---
string tf1Input = input.timeframe("15", "Timeframe 1", group = G_TF, tooltip = "First timeframe used by the Supertrend dashboard.")
string tf2Input = input.timeframe("60", "Timeframe 2", group = G_TF, tooltip = "Second timeframe used by the Supertrend dashboard.")
string tf3Input = input.timeframe("240", "Timeframe 3", group = G_TF, tooltip = "Third timeframe used by the Supertrend dashboard.")
string tf4Input = input.timeframe("D", "Timeframe 4", group = G_TF, tooltip = "Fourth timeframe used by the Supertrend dashboard.")

// --- Dashboard Inputs ---
string tablePosInput = input.string("top_right", "Position", options = ["top_right", "bottom_right", "top_left", "bottom_left", "top_center", "bottom_center", "middle_right", "middle_left"], group = G_TBL, tooltip = "Dashboard location on the chart.")
color bullColorInput = input.color(#089981, "Bullish Color", group = G_TBL, tooltip = "Color used for bullish readings.")
color bearColorInput = input.color(#f23645, "Bearish Color", group = G_TBL, tooltip = "Color used for bearish readings.")
color headerBgInput = input.color(color.new(color.gray, 50), "Header Background", group = G_TBL, tooltip = "Dashboard header background color.")
color headerTxtInput = input.color(color.white, "Header Text", group = G_TBL, tooltip = "Dashboard header text color.")
color cellBgInput = input.color(color.new(color.gray, 80), "Cell Background", group = G_TBL, tooltip = "Dashboard cell background color.")
color cellTxtInput = input.color(color.white, "Cell Text", group = G_TBL, tooltip = "Dashboard cell text color.")
color borderInput = input.color(color.gray, "Border Color", group = G_TBL, tooltip = "Dashboard border color.")
string textSizeInput = input.string("small", "Text Size", options = ["tiny", "small", "normal", "large", "huge"], group = G_TBL, tooltip = "Dashboard text size.")

// --- SMC Structure Inputs ---
string smcTfInput = input.timeframe("", "SMC Timeframe", group = G_SMC, tooltip = "Timeframe used for SMC structure. Leave blank to use the chart timeframe.")
int swingLen = input.int(10, "Swing Lookback", minval = 2, maxval = 50, group = G_SMC, tooltip = "Bars left and right required to confirm a swing high or low on the SMC timeframe.")
string breakMethodInput = input.string("Candle close", "Structure Break Method", options = ["Candle close", "Wick"], group = G_SMC, tooltip = "Use a candle close or a wick through the protected structure level.")
bool showBOS = input.bool(true, "Show BOS", group = G_SMC, tooltip = "Show continuation breaks of structure.")
bool showCHoCH = input.bool(true, "Show CHoCH", group = G_SMC, tooltip = "Show the first break against the current structural trend.")
bool showMSB = input.bool(true, "Show MSB", group = G_SMC, tooltip = "Show MSB alongside a CHoCH structural reversal.")
bool showLabels = input.bool(true, "Show Labels", group = G_SMC, tooltip = "Show text labels at structure events.")
bool showOnlyLast = input.bool(false, "Show Only Most Recent of Each", group = G_SMC, tooltip = "Keep only the latest line and label for each event type.")

// --- SMC Line Inputs ---
color bosColor = input.color(#089981, "BOS Color", group = G_LINE, tooltip = "Color used for BOS lines.")
color chochColor = input.color(#f23645, "CHoCH Color", group = G_LINE, tooltip = "Color used for CHoCH lines.")
color msbColor = input.color(#f7a600, "MSB Color", group = G_LINE, tooltip = "Color used for MSB lines.")
string bosStyle = input.string("solid", "BOS Line Style", options = ["solid", "dashed", "dotted"], group = G_LINE, tooltip = "Line style used for BOS events.")
string chochStyle = input.string("dashed", "CHoCH Line Style", options = ["solid", "dashed", "dotted"], group = G_LINE, tooltip = "Line style used for CHoCH events.")
string msbStyle = input.string("dashed", "MSB Line Style", options = ["solid", "dashed", "dotted"], group = G_LINE, tooltip = "Line style used for MSB events.")
int lineWidth = input.int(1, "Line Width", minval = 1, maxval = 4, group = G_LINE, tooltip = "Width of structure lines.")
int lineExtBars = input.int(40, "Line Extension (bars)", minval = 1, maxval = 500, group = G_LINE, tooltip = "Number of active chart bars for which a structure line extends to the right.")

// --- 200 EMA Inputs ---
bool showEMA = input.bool(true, "Show 200 EMA", group = G_EMA, tooltip = "Show the EMA on the active chart timeframe.")
int emaLength = input.int(200, "EMA Length", minval = 1, group = G_EMA, tooltip = "EMA period.")
string emaSource = input.string("close", "EMA Source", options = ["close", "open", "high", "low", "hl2", "hlc3", "ohlc4"], group = G_EMA, tooltip = "Price source used for the EMA and all higher timeframe EMAs.")
color emaBullColor = input.color(#089981, "EMA Color (Price Above)", group = G_EMA, tooltip = "EMA color when price is above it.")
color emaBearColor = input.color(#f23645, "EMA Color (Price Below)", group = G_EMA, tooltip = "EMA color when price is below it.")
bool emaColorMode = input.bool(true, "Dynamic Color (above/below)", group = G_EMA, tooltip = "Change EMA color according to the current price position.")
int emaWidth = input.int(2, "EMA Line Width", minval = 1, maxval = 4, group = G_EMA, tooltip = "EMA line width.")
bool showEMACloud = input.bool(false, "Show Price/EMA Cloud", group = G_EMA, tooltip = "Fill the area between price and the EMA.")
color emaCloudBull = input.color(color.new(#089981, 85), "Cloud Color (Above)", group = G_EMA, tooltip = "Cloud color when price is above the EMA.")
color emaCloudBear = input.color(color.new(#f23645, 85), "Cloud Color (Below)", group = G_EMA, tooltip = "Cloud color when price is below the EMA.")

// --- Higher Timeframe EMA Inputs ---
bool showHtfEma1 = input.bool(false, "Show HTF EMA 1", group = G_HTF_EMA, inline = "htfEma1", tooltip = "Show the first higher timeframe EMA.")
string htfEma1Tf = input.timeframe("60", "Timeframe", group = G_HTF_EMA, inline = "htfEma1", tooltip = "Timeframe used to calculate higher timeframe EMA 1.")
int htfEma1Length = input.int(200, "Length", minval = 1, group = G_HTF_EMA, inline = "htfEma1", tooltip = "Length used by higher timeframe EMA 1.")

bool showHtfEma2 = input.bool(false, "Show HTF EMA 2", group = G_HTF_EMA, inline = "htfEma2", tooltip = "Show the second higher timeframe EMA.")
string htfEma2Tf = input.timeframe("240", "Timeframe", group = G_HTF_EMA, inline = "htfEma2", tooltip = "Timeframe used to calculate higher timeframe EMA 2.")
int htfEma2Length = input.int(200, "Length", minval = 1, group = G_HTF_EMA, inline = "htfEma2", tooltip = "Length used by higher timeframe EMA 2.")

bool showHtfEma3 = input.bool(false, "Show HTF EMA 3", group = G_HTF_EMA, inline = "htfEma3", tooltip = "Show the third higher timeframe EMA.")
string htfEma3Tf = input.timeframe("D", "Timeframe", group = G_HTF_EMA, inline = "htfEma3", tooltip = "Timeframe used to calculate higher timeframe EMA 3.")
int htfEma3Length = input.int(200, "Length", minval = 1, group = G_HTF_EMA, inline = "htfEma3", tooltip = "Length used by higher timeframe EMA 3.")

bool showHtfEma4 = input.bool(false, "Show HTF EMA 4", group = G_HTF_EMA, inline = "htfEma4", tooltip = "Show the fourth higher timeframe EMA.")
string htfEma4Tf = input.timeframe("W", "Timeframe", group = G_HTF_EMA, inline = "htfEma4", tooltip = "Timeframe used to calculate higher timeframe EMA 4.")
int htfEma4Length = input.int(200, "Length", minval = 1, group = G_HTF_EMA, inline = "htfEma4", tooltip = "Length used by higher timeframe EMA 4.")

bool htfEmaColorMode = input.bool(true, "Dynamic HTF Colors", group = G_HTF_EMA, tooltip = "Change each higher timeframe EMA color according to whether chart price is above or below it.")
color htfEmaBullColor = input.color(#089981, "HTF Color (Price Above)", group = G_HTF_EMA, tooltip = "Color used when chart price is above a higher timeframe EMA.")
color htfEmaBearColor = input.color(#f23645, "HTF Color (Price Below)", group = G_HTF_EMA, tooltip = "Color used when chart price is below a higher timeframe EMA.")
int htfEmaWidth = input.int(2, "HTF EMA Line Width", minval = 1, maxval = 4, group = G_HTF_EMA, tooltip = "Line width used by all higher timeframe EMAs.")

// --- Helpers ---
styleFrom(string styleInput) =>
    styleInput == "dashed" ? line.style_dashed : styleInput == "dotted" ? line.style_dotted : line.style_solid

calcSupertrend(int len, float factor) =>
    [_, direction] = ta.supertrend(factor, len)
    direction < 0 ? 1 : -1

// Event codes: 1 bullish BOS, -1 bearish BOS, 2 bullish CHoCH, -2 bearish CHoCH.
// The function runs in the requested SMC timeframe context.
calcSmc(int len, string breakMethod) =>
    float pivotHigh = ta.pivothigh(high, len, len)
    float pivotLow = ta.pivotlow(low, len, len)

    var float protectedHigh = na
    var float protectedLow = na
    var int protectedHighTime = na
    var int protectedLowTime = na
    var int state = 0
    var bool highBroken = false
    var bool lowBroken = false

    int event = 0
    float eventLevel = na
    int eventTime = na
    bool useClose = breakMethod == "Candle close"

    // Only commit pivots and breaks on a completed SMC candle.
    if barstate.isconfirmed
        if not na(pivotHigh)
            protectedHigh := pivotHigh
            protectedHighTime := time[len]
            highBroken := false

        if not na(pivotLow)
            protectedLow := pivotLow
            protectedLowTime := time[len]
            lowBroken := false

        bool breaksHigh = not na(protectedHigh) and not highBroken and (useClose ? close > protectedHigh : high > protectedHigh)
        bool breaksLow = not na(protectedLow) and not lowBroken and (useClose ? close < protectedLow : low < protectedLow)

        if state == 0
            if breaksHigh
                state := 1
                highBroken := true
            else if breaksLow
                state := -1
                lowBroken := true
        else if state == 1
            if breaksLow
                event := -2
                eventLevel := protectedLow
                eventTime := protectedLowTime
                state := -1
                lowBroken := true
            else if breaksHigh
                event := 1
                eventLevel := protectedHigh
                eventTime := protectedHighTime
                highBroken := true
        else
            if breaksHigh
                event := 2
                eventLevel := protectedHigh
                eventTime := protectedHighTime
                state := 1
                highBroken := true
            else if breaksLow
                event := -1
                eventLevel := protectedLow
                eventTime := protectedLowTime
                lowBroken := true

    [state, event, eventLevel, eventTime]

// --- EMA Calculation ---
emaSourceSeries = emaSource == "open" ? open : emaSource == "high" ? high : emaSource == "low" ? low : emaSource == "hl2" ? hl2 : emaSource == "hlc3" ? hlc3 : emaSource == "ohlc4" ? ohlc4 : close
emaValue = ta.ema(emaSourceSeries, emaLength)
bool aboveEMA = close >= emaValue
emaColor = emaColorMode ? (aboveEMA ? emaBullColor : emaBearColor) : emaBullColor
emaPlotMain = plot(showEMA ? emaValue : na, title = "EMA", color = emaColor, linewidth = emaWidth, style = plot.style_line)

closePlot = plot(showEMA and showEMACloud ? close : na, display = display.none)
emaCloudPlot = plot(showEMA and showEMACloud ? emaValue : na, display = display.none)
fill(closePlot, emaCloudPlot, color = showEMACloud ? (aboveEMA ? emaCloudBull : emaCloudBear) : na)

// --- Higher Timeframe EMA Calculations ---
htfEma1 = request.security(syminfo.tickerid, htfEma1Tf, ta.ema(emaSourceSeries, htfEma1Length), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
htfEma2 = request.security(syminfo.tickerid, htfEma2Tf, ta.ema(emaSourceSeries, htfEma2Length), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
htfEma3 = request.security(syminfo.tickerid, htfEma3Tf, ta.ema(emaSourceSeries, htfEma3Length), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
htfEma4 = request.security(syminfo.tickerid, htfEma4Tf, ta.ema(emaSourceSeries, htfEma4Length), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

bool aboveHtfEma1 = close >= htfEma1
bool aboveHtfEma2 = close >= htfEma2
bool aboveHtfEma3 = close >= htfEma3
bool aboveHtfEma4 = close >= htfEma4
color htfEma1Color = htfEmaColorMode ? (aboveHtfEma1 ? htfEmaBullColor : htfEmaBearColor) : htfEmaBullColor
color htfEma2Color = htfEmaColorMode ? (aboveHtfEma2 ? htfEmaBullColor : htfEmaBearColor) : htfEmaBullColor
color htfEma3Color = htfEmaColorMode ? (aboveHtfEma3 ? htfEmaBullColor : htfEmaBearColor) : htfEmaBullColor
color htfEma4Color = htfEmaColorMode ? (aboveHtfEma4 ? htfEmaBullColor : htfEmaBearColor) : htfEmaBullColor

plot(showHtfEma1 ? htfEma1 : na, title = "HTF EMA 1", color = htfEma1Color, linewidth = htfEmaWidth, style = plot.style_line)
plot(showHtfEma2 ? htfEma2 : na, title = "HTF EMA 2", color = htfEma2Color, linewidth = htfEmaWidth, style = plot.style_line)
plot(showHtfEma3 ? htfEma3 : na, title = "HTF EMA 3", color = htfEma3Color, linewidth = htfEmaWidth, style = plot.style_line)
plot(showHtfEma4 ? htfEma4 : na, title = "HTF EMA 4", color = htfEma4Color, linewidth = htfEmaWidth, style = plot.style_line)

// --- Supertrend MTF ---
st1 = request.security(syminfo.tickerid, tf1Input, calcSupertrend(atrLenInput, factorInput), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
st2 = request.security(syminfo.tickerid, tf2Input, calcSupertrend(atrLenInput, factorInput), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
st3 = request.security(syminfo.tickerid, tf3Input, calcSupertrend(atrLenInput, factorInput), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
st4 = request.security(syminfo.tickerid, tf4Input, calcSupertrend(atrLenInput, factorInput), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

// --- MTF SMC Calculation ---
[smcState, smcEvent, smcEventLevel, smcEventTime] = request.security(syminfo.tickerid, smcTfInput, calcSmc(swingLen, breakMethodInput), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
string smcTfDisplay = smcTfInput == "" ? timeframe.period : smcTfInput

// --- SMC Visuals ---
var line lastBOSLine = na
var line lastCHoCHLine = na
var line lastMSBLine = na
var label lastBOSLabel = na
var label lastCHoCHLabel = na
var label lastMSBLabel = na
var int lastBOSLabelBar = na
var int lastCHoCHLabelBar = na
var int lastMSBLabelBar = na

drawStructureLine(float level, color lineColor, lineStyle, string labelText, line previousLine, label previousLabel, int previousLabelBar) =>
    line newLine = na
    label newLabel = na
    if not na(level)
        if showOnlyLast
            line.delete(previousLine)
            label.delete(previousLabel)
        newLine := line.new(bar_index, level, bar_index + lineExtBars, level, color = lineColor, width = lineWidth, style = lineStyle)
        bool drawLabel = showLabels and (na(previousLabelBar) or bar_index - previousLabelBar >= 1)
        if drawLabel
            newLabel := label.new(bar_index + lineExtBars, level, labelText, color = color.new(lineColor, 80), textcolor = color.white, style = label.style_label_left, size = size.small)
    [newLine, newLabel, not na(newLabel)]

bool newSmcEvent = smcEvent != 0 and (na(smcEvent[1]) or smcEvent[1] == 0 or smcEventTime != smcEventTime[1])

if newSmcEvent
    if smcEvent == 1 or smcEvent == -1
        if showBOS
            [newLine, newLabel, drewLabel] = drawStructureLine(smcEventLevel, bosColor, styleFrom(bosStyle), "BOS", lastBOSLine, lastBOSLabel, lastBOSLabelBar)
            lastBOSLine := newLine
            lastBOSLabel := newLabel
            if drewLabel
                lastBOSLabelBar := bar_index
    else if smcEvent == 2 or smcEvent == -2
        if showCHoCH
            [newLine, newLabel, drewLabel] = drawStructureLine(smcEventLevel, chochColor, styleFrom(chochStyle), "CHoCH", lastCHoCHLine, lastCHoCHLabel, lastCHoCHLabelBar)
            lastCHoCHLine := newLine
            lastCHoCHLabel := newLabel
            if drewLabel
                lastCHoCHLabelBar := bar_index
        if showMSB
            [msbLine, msbLabel, msbDrewLabel] = drawStructureLine(smcEventLevel, msbColor, styleFrom(msbStyle), "MSB", lastMSBLine, lastMSBLabel, lastMSBLabelBar)
            lastMSBLine := msbLine
            lastMSBLabel := msbLabel
            if msbDrewLabel
                lastMSBLabelBar := bar_index

// --- Dashboard ---
var tablePos = tablePosInput == "top_right" ? position.top_right : tablePosInput == "bottom_right" ? position.bottom_right : tablePosInput == "top_left" ? position.top_left : tablePosInput == "bottom_left" ? position.bottom_left : tablePosInput == "top_center" ? position.top_center : tablePosInput == "bottom_center" ? position.bottom_center : tablePosInput == "middle_right" ? position.middle_right : position.middle_left
var textSize = textSizeInput == "tiny" ? size.tiny : textSizeInput == "small" ? size.small : textSizeInput == "normal" ? size.normal : textSizeInput == "large" ? size.large : size.huge
var table dashboard = table.new(tablePos, 2, 7, border_width = 1, border_color = borderInput)

if barstate.islast
    table.cell(dashboard, 0, 0, "Timeframe", bgcolor = headerBgInput, text_color = headerTxtInput, text_size = textSize)
    table.cell(dashboard, 1, 0, "Trend", bgcolor = headerBgInput, text_color = headerTxtInput, text_size = textSize)

    table.cell(dashboard, 0, 1, tf1Input, bgcolor = cellBgInput, text_color = cellTxtInput, text_size = textSize)
    table.cell(dashboard, 1, 1, st1 > 0 ? "Bullish" : "Bearish", bgcolor = st1 > 0 ? bullColorInput : bearColorInput, text_color = color.white, text_size = textSize)
    table.cell(dashboard, 0, 2, tf2Input, bgcolor = cellBgInput, text_color = cellTxtInput, text_size = textSize)
    table.cell(dashboard, 1, 2, st2 > 0 ? "Bullish" : "Bearish", bgcolor = st2 > 0 ? bullColorInput : bearColorInput, text_color = color.white, text_size = textSize)
    table.cell(dashboard, 0, 3, tf3Input, bgcolor = cellBgInput, text_color = cellTxtInput, text_size = textSize)
    table.cell(dashboard, 1, 3, st3 > 0 ? "Bullish" : "Bearish", bgcolor = st3 > 0 ? bullColorInput : bearColorInput, text_color = color.white, text_size = textSize)
    table.cell(dashboard, 0, 4, tf4Input, bgcolor = cellBgInput, text_color = cellTxtInput, text_size = textSize)
    table.cell(dashboard, 1, 4, st4 > 0 ? "Bullish" : "Bearish", bgcolor = st4 > 0 ? bullColorInput : bearColorInput, text_color = color.white, text_size = textSize)

    string smcTxt = smcState == 1 ? "Bullish" : smcState == -1 ? "Bearish" : "Neutral"
    color smcClr = smcState == 1 ? bullColorInput : smcState == -1 ? bearColorInput : color.new(color.gray, 50)
    table.cell(dashboard, 0, 5, "SMC " + smcTfDisplay, bgcolor = cellBgInput, text_color = cellTxtInput, text_size = textSize)
    table.cell(dashboard, 1, 5, smcTxt, bgcolor = smcClr, text_color = color.white, text_size = textSize)

    string emaTxt = showEMA ? (aboveEMA ? "Above EMA" : "Below EMA") : "EMA off"
    color emaRowClr = showEMA ? (aboveEMA ? bullColorInput : emaBearColor) : color.new(color.gray, 50)
    table.cell(dashboard, 0, 6, "EMA " + str.tostring(emaLength), bgcolor = cellBgInput, text_color = cellTxtInput, text_size = textSize)
    table.cell(dashboard, 1, 6, emaTxt, bgcolor = emaRowClr, text_color = color.white, text_size = textSize)

// --- Current-Timeframe Supertrend Line ---
[stValueCurrent, stDirCurrent] = ta.supertrend(factorInput, atrLenInput)
plot(showLinesInput ? stValueCurrent : na, "Supertrend", color = stDirCurrent < 0 ? bullColorInput : bearColorInput, linewidth = 2, style = plot.style_linebr)

// --- Alerts ---
alertcondition(newSmcEvent and smcEvent == 1, "Bullish BOS", "Bullish BOS on the selected SMC timeframe.")
alertcondition(newSmcEvent and smcEvent == -1, "Bearish BOS", "Bearish BOS on the selected SMC timeframe.")
alertcondition(newSmcEvent and smcEvent == 2, "Bullish CHoCH", "Bullish CHoCH on the selected SMC timeframe.")
alertcondition(newSmcEvent and smcEvent == -2, "Bearish CHoCH", "Bearish CHoCH on the selected SMC timeframe.")
````
