# Institutional Sessions Overlay (Asia/London/NY)

- url: https://www.tradingview.com/script/UzpNlKcQ/
- type: indicator
- pine_id: PUB;634544e79dbb4aae92317cfeacefd288
- version: 4.0

## Description

[b]Institutional Sessions Overlay[/b] is a professional TradingView indicator that visually highlights the main trading sessions (Asia, London, and New York) directly on your chart.

[list]
[*][b]Customizable:[/b] Easily adjust session start and end times (including minutes) for each market.
[*][b]Timezone Alignment:[/b] Shift session boxes using the timezone offset parameter so sessions match your chart’s timezone exactly.
[*][b]Clear Visuals: [/b]Colored boxes and optional labels display session opens and closes for fast institutional market structure reference.
[*][b]Toggle Labels:[/b] Show or hide session open/close labels with a single click for a clean or detailed look.
[*][b]Intuitive UI:[/b] User-friendly grouped settings for efficient configuration.
[/list]

This tool is designed for day traders, institutional traders, and anyone who wants to instantly recognize global session timing and ranges for SMC, ICT, and other session-based strategies.

[b]How to use:[/b]

[list]
[*]Set your chart to your local timezone.
[*]Use the "Session timezone offset" setting if session boxes do not match actual session opens on your chart.
[*]Adjust the hours and minutes for each session as needed.
[*]Enable or disable labels in the “Display” settings group.
[/list]

[b]Tip:[/b] Use the overlay to spot session highs and lows, volatility windows, and institutional liquidity sweeps.

## Source Code

````pine
//@version=6
indicator(
     "Institutional sessions overlay (Asia/London/New York)",
     overlay=true,
     shorttitle="SMC sessions overlay",
     max_boxes_count=300,
     max_labels_count=400,
     max_lines_count=300
)

// ===================== Helpers =====================
f_getBorderColor(showBorder, borderColor) =>
    showBorder ? borderColor : na

f_getFillColor(showFill, fillColor) =>
    showFill ? fillColor : na

f_getLabelColor(showFill, fillColor, showBorder, borderColor) =>
    showFill ? color.new(fillColor, 0) : showBorder ? color.new(borderColor, 0) : color.new(fillColor, 0)

f_getBaseLevelColor(fillColor, showBorder, borderColor) =>
    showBorder ? color.new(borderColor, 0) : color.new(fillColor, 0)

f_getLabelSize(labelSizeOption) =>
    labelSizeOption == "Tiny" ? size.tiny :
     labelSizeOption == "Small" ? size.small :
     labelSizeOption == "Normal" ? size.normal :
     size.tiny

f_getReadableTextColor(bgColor) =>
    r = color.r(bgColor)
    g = color.g(bgColor)
    b = color.b(bgColor)
    luminance = 0.299 * r + 0.587 * g + 0.114 * b
    luminance < 140 ? color.white : color.black

f_getLineStyle(styleOption) =>
    styleOption == "Solid" ? line.style_solid :
     styleOption == "Dashed" ? line.style_dashed :
     line.style_dotted

f_adjustSession(sh, sm, eh, em, offset) =>
    sH = (sh - offset) % 24
    eH = (eh - offset) % 24
    s = str.tostring(sH, "00") + str.tostring(sm, "00")
    e = str.tostring(eH, "00") + str.tostring(em, "00")
    s + "-" + e

f_updateLevelLine(line existingLine, bool show, int startX, float y, color lineColor, lineStyle, int lineWidth) =>
    line result = existingLine
    int finalStartX = startX
    int finalEndX = math.max(bar_index + 1, finalStartX + 1)

    if show
        if na(result)
            result := line.new(
                 x1=finalStartX,
                 y1=y,
                 x2=finalEndX,
                 y2=y,
                 xloc=xloc.bar_index,
                 extend=extend.right,
                 color=lineColor,
                 style=lineStyle,
                 width=lineWidth
             )
        else
            line.set_x1(result, finalStartX)
            line.set_y1(result, y)
            line.set_x2(result, finalEndX)
            line.set_y2(result, y)
            line.set_extend(result, extend.right)
            line.set_color(result, lineColor)
            line.set_style(result, lineStyle)
            line.set_width(result, lineWidth)
    else
        if not na(result)
            line.delete(result)
            result := na

    result

f_updateLevelLabel(label existingLabel, bool show, int x, float y, string txt, color txtColor, string sizeOption) =>
    label result = existingLabel
    labelSize = f_getLabelSize(sizeOption)

    if show
        if na(result)
            result := label.new(
                 x=x,
                 y=y,
                 xloc=xloc.bar_index,
                 text=txt,
                 style=label.style_none,
                 textcolor=txtColor,
                 size=labelSize
             )
        else
            label.set_x(result, x)
            label.set_y(result, y)
            label.set_text(result, txt)
            label.set_textcolor(result, txtColor)
            label.set_style(result, label.style_none)
            label.set_size(result, labelSize)
    else
        if not na(result)
            label.delete(result)
            result := na

    result

// ===================== 01. General =====================
timezoneOffset = input.int(
     -7,
     "Chart alignment offset (hours)",
     group="01. General",
     tooltip="Use this only if the session boxes do not align with your chart time.\n\nIf the boxes are shifted, adjust this value until Asia, London and New York sessions open at the expected time on your chart."
)

showSessionAreasGlobal = input.bool(true, "Show session areas", group="01. General")
showSessionOpenCloseLabelsGlobal = input.bool(true, "Show session open/close labels", group="01. General")
showSessionLevelLinesGlobal = input.bool(true, "Show session high/low lines", group="01. General")
showSessionLevelTextGlobal = input.bool(true, "Show session high/low labels", group="01. General")

labelMode = input.string(
     "Open + close",
     "Label mode",
     options=["Open only", "Close only", "Open + close"],
     group="01. General",
     active=showSessionOpenCloseLabelsGlobal
)

// ===================== 02. Visual =====================
labelSizeOption = input.string(
     "Tiny",
     "Label size",
     options=["Tiny", "Small", "Normal"],
     group="02. Visual"
)

priorLineStyleOption = input.string(
     "Solid",
     "Prior line style",
     options=["Solid", "Dashed", "Dotted"],
     group="02. Visual"
)

currentLineStyleOption = input.string(
     "Dashed",
     "Current line style",
     options=["Solid", "Dashed", "Dotted"],
     group="02. Visual"
)

priorLineWidth = input.int(1, "Prior line width", minval=1, maxval=4, group="02. Visual")
currentLineWidth = input.int(1, "Current line width", minval=1, maxval=4, group="02. Visual")
levelTextOffsetBars = input.int(8, "Level text offset (bars)", minval=1, maxval=50, group="02. Visual")
levelLabelVerticalOffsetTicks = input.int(8, "Level label vertical offset (ticks)", minval=1, maxval=100, group="02. Visual")

labelSizeFinal = f_getLabelSize(labelSizeOption)
showOpenLabels = showSessionOpenCloseLabelsGlobal and (labelMode == "Open only" or labelMode == "Open + close")
showCloseLabels = showSessionOpenCloseLabelsGlobal and (labelMode == "Close only" or labelMode == "Open + close")
priorLineStyle = f_getLineStyle(priorLineStyleOption)
currentLineStyle = f_getLineStyle(currentLineStyleOption)

// ===================== 03. Asia session =====================
showAsia = input.bool(true, "Enable Asia session", group="03. Asia session")

showAsiaFill = input.bool(true, "↳ Show fill", inline="asiaBoxFill", group="03. Asia session", active=showAsia)
asiaFillColor = input.color(color.new(color.teal, 85), "Color", inline="asiaBoxFill", group="03. Asia session", active=showAsia)

showAsiaBorder = input.bool(true, "↳ Show border", inline="asiaBoxBorder", group="03. Asia session", active=showAsia)
asiaBorderColor = input.color(color.teal, "Color", inline="asiaBoxBorder", group="03. Asia session", active=showAsia)

asiaStartHour = input.int(19, "↳ Start hour", minval=0, maxval=23, inline="asiaStart", group="03. Asia session", active=showAsia)
asiaStartMin  = input.int(0, "Min", minval=0, maxval=59, inline="asiaStart", group="03. Asia session", active=showAsia)
asiaEndHour   = input.int(5, "↳ End hour", minval=0, maxval=23, inline="asiaEnd", group="03. Asia session", active=showAsia)
asiaEndMin    = input.int(0, "Min", minval=0, maxval=59, inline="asiaEnd", group="03. Asia session", active=showAsia)

showAsiaKillZone = input.bool(false, "Show Asia kill zone", group="03. Asia session")

showAsiaKillZoneFill = input.bool(true, "↳ Show fill", inline="asiaKzFill", group="03. Asia session", active=showAsiaKillZone)
asiaKillZoneFillColor = input.color(color.new(color.teal, 90), "Color", inline="asiaKzFill", group="03. Asia session", active=showAsiaKillZone)

showAsiaKillZoneBorder = input.bool(true, "↳ Show border", inline="asiaKzBorder", group="03. Asia session", active=showAsiaKillZone)
asiaKillZoneBorderColor = input.color(color.teal, "Color", inline="asiaKzBorder", group="03. Asia session", active=showAsiaKillZone)

asiaKillZoneStartHour = input.int(19, "↳ Start hour", minval=0, maxval=23, inline="asiaKzStart", group="03. Asia session", active=showAsiaKillZone)
asiaKillZoneStartMin  = input.int(0, "Min", minval=0, maxval=59, inline="asiaKzStart", group="03. Asia session", active=showAsiaKillZone)
asiaKillZoneEndHour   = input.int(22, "↳ End hour", minval=0, maxval=23, inline="asiaKzEnd", group="03. Asia session", active=showAsiaKillZone)
asiaKillZoneEndMin    = input.int(0, "Min", minval=0, maxval=59, inline="asiaKzEnd", group="03. Asia session", active=showAsiaKillZone)

showAsiaLevels = input.bool(false, "Show session highs and lows", group="03. Asia session")
showAsiaPriorLevels = input.bool(true, "↳ Show prior", inline="asiaLevelsMode", group="03. Asia session", active=showAsiaLevels)
showAsiaCurrentLevels = input.bool(false, "Show current", inline="asiaLevelsMode", group="03. Asia session", active=showAsiaLevels)
showAsiaLevelHighs = input.bool(true, "↳ Show highs", inline="asiaLevelsSide", group="03. Asia session", active=showAsiaLevels)
showAsiaLevelLows = input.bool(true, "Show lows", inline="asiaLevelsSide", group="03. Asia session", active=showAsiaLevels)

// ===================== 04. London session =====================
showLondon = input.bool(true, "Enable London session", group="04. London session")

showLondonFill = input.bool(true, "↳ Show fill", inline="londonBoxFill", group="04. London session", active=showLondon)
londonFillColor = input.color(color.new(color.blue, 85), "Color", inline="londonBoxFill", group="04. London session", active=showLondon)

showLondonBorder = input.bool(true, "↳ Show border", inline="londonBoxBorder", group="04. London session", active=showLondon)
londonBorderColor = input.color(color.blue, "Color", inline="londonBoxBorder", group="04. London session", active=showLondon)

londonStartHour = input.int(3, "↳ Start hour", minval=0, maxval=23, inline="londonStart", group="04. London session", active=showLondon)
londonStartMin  = input.int(0, "Min", minval=0, maxval=59, inline="londonStart", group="04. London session", active=showLondon)
londonEndHour   = input.int(12, "↳ End hour", minval=0, maxval=23, inline="londonEnd", group="04. London session", active=showLondon)
londonEndMin    = input.int(0, "Min", minval=0, maxval=59, inline="londonEnd", group="04. London session", active=showLondon)

showLondonKillZone = input.bool(false, "Show London kill zone", group="04. London session")

showLondonKillZoneFill = input.bool(true, "↳ Show fill", inline="londonKzFill", group="04. London session", active=showLondonKillZone)
londonKillZoneFillColor = input.color(color.new(color.blue, 90), "Color", inline="londonKzFill", group="04. London session", active=showLondonKillZone)

showLondonKillZoneBorder = input.bool(true, "↳ Show border", inline="londonKzBorder", group="04. London session", active=showLondonKillZone)
londonKillZoneBorderColor = input.color(color.blue, "Color", inline="londonKzBorder", group="04. London session", active=showLondonKillZone)

londonKillZoneStartHour = input.int(2, "↳ Start hour", minval=0, maxval=23, inline="londonKzStart", group="04. London session", active=showLondonKillZone)
londonKillZoneStartMin  = input.int(0, "Min", minval=0, maxval=59, inline="londonKzStart", group="04. London session", active=showLondonKillZone)
londonKillZoneEndHour   = input.int(5, "↳ End hour", minval=0, maxval=23, inline="londonKzEnd", group="04. London session", active=showLondonKillZone)
londonKillZoneEndMin    = input.int(0, "Min", minval=0, maxval=59, inline="londonKzEnd", group="04. London session", active=showLondonKillZone)

showLondonLevels = input.bool(false, "Show session highs and lows", group="04. London session")
showLondonPriorLevels = input.bool(true, "↳ Show prior", inline="londonLevelsMode", group="04. London session", active=showLondonLevels)
showLondonCurrentLevels = input.bool(false, "Show current", inline="londonLevelsMode", group="04. London session", active=showLondonLevels)
showLondonLevelHighs = input.bool(true, "↳ Show highs", inline="londonLevelsSide", group="04. London session", active=showLondonLevels)
showLondonLevelLows = input.bool(true, "Show lows", inline="londonLevelsSide", group="04. London session", active=showLondonLevels)

// ===================== 05. New York session =====================
showNY = input.bool(true, "Enable New York session", group="05. New York session")

showNYFill = input.bool(true, "↳ Show fill", inline="nyBoxFill", group="05. New York session", active=showNY)
nyFillColor = input.color(color.new(color.orange, 85), "Color", inline="nyBoxFill", group="05. New York session", active=showNY)

showNYBorder = input.bool(true, "↳ Show border", inline="nyBoxBorder", group="05. New York session", active=showNY)
nyBorderColor = input.color(color.orange, "Color", inline="nyBoxBorder", group="05. New York session", active=showNY)

nyStartHour = input.int(8, "↳ Start hour", minval=0, maxval=23, inline="nyStart", group="05. New York session", active=showNY)
nyStartMin  = input.int(0, "Min", minval=0, maxval=59, inline="nyStart", group="05. New York session", active=showNY)
nyEndHour   = input.int(17, "↳ End hour", minval=0, maxval=23, inline="nyEnd", group="05. New York session", active=showNY)
nyEndMin    = input.int(0, "Min", minval=0, maxval=59, inline="nyEnd", group="05. New York session", active=showNY)

showNYKillZone = input.bool(false, "Show New York kill zone", group="05. New York session")

showNYKillZoneFill = input.bool(true, "↳ Show fill", inline="nyKzFill", group="05. New York session", active=showNYKillZone)
nyKillZoneFillColor = input.color(color.new(color.orange, 90), "Color", inline="nyKzFill", group="05. New York session", active=showNYKillZone)

showNYKillZoneBorder = input.bool(true, "↳ Show border", inline="nyKzBorder", group="05. New York session", active=showNYKillZone)
nyKillZoneBorderColor = input.color(color.orange, "Color", inline="nyKzBorder", group="05. New York session", active=showNYKillZone)

nyKillZoneStartHour = input.int(7, "↳ Start hour", minval=0, maxval=23, inline="nyKzStart", group="05. New York session", active=showNYKillZone)
nyKillZoneStartMin  = input.int(0, "Min", minval=0, maxval=59, inline="nyKzStart", group="05. New York session", active=showNYKillZone)
nyKillZoneEndHour   = input.int(10, "↳ End hour", minval=0, maxval=23, inline="nyKzEnd", group="05. New York session", active=showNYKillZone)
nyKillZoneEndMin    = input.int(0, "Min", minval=0, maxval=59, inline="nyKzEnd", group="05. New York session", active=showNYKillZone)

showNYLevels = input.bool(false, "Show session highs and lows", group="05. New York session")
showNYPriorLevels = input.bool(true, "↳ Show prior", inline="nyLevelsMode", group="05. New York session", active=showNYLevels)
showNYCurrentLevels = input.bool(false, "Show current", inline="nyLevelsMode", group="05. New York session", active=showNYLevels)
showNYLevelHighs = input.bool(true, "↳ Show highs", inline="nyLevelsSide", group="05. New York session", active=showNYLevels)
showNYLevelLows = input.bool(true, "Show lows", inline="nyLevelsSide", group="05. New York session", active=showNYLevels)

// ===================== Session strings =====================
asiaSession   = f_adjustSession(asiaStartHour, asiaStartMin, asiaEndHour, asiaEndMin, timezoneOffset)
londonSession = f_adjustSession(londonStartHour, londonStartMin, londonEndHour, londonEndMin, timezoneOffset)
nySession     = f_adjustSession(nyStartHour, nyStartMin, nyEndHour, nyEndMin, timezoneOffset)

// ===================== Kill zone strings =====================
asiaKillZoneSession   = f_adjustSession(asiaKillZoneStartHour, asiaKillZoneStartMin, asiaKillZoneEndHour, asiaKillZoneEndMin, timezoneOffset)
londonKillZoneSession = f_adjustSession(londonKillZoneStartHour, londonKillZoneStartMin, londonKillZoneEndHour, londonKillZoneEndMin, timezoneOffset)
nyKillZoneSession     = f_adjustSession(nyKillZoneStartHour, nyKillZoneStartMin, nyKillZoneEndHour, nyKillZoneEndMin, timezoneOffset)

// ===================== Final colors =====================
asiaBgColorFinal = showSessionAreasGlobal ? f_getFillColor(showAsiaFill, asiaFillColor) : na
londonBgColorFinal = showSessionAreasGlobal ? f_getFillColor(showLondonFill, londonFillColor) : na
nyBgColorFinal = showSessionAreasGlobal ? f_getFillColor(showNYFill, nyFillColor) : na

asiaBorderFinal = showSessionAreasGlobal ? f_getBorderColor(showAsiaBorder, asiaBorderColor) : na
londonBorderFinal = showSessionAreasGlobal ? f_getBorderColor(showLondonBorder, londonBorderColor) : na
nyBorderFinal = showSessionAreasGlobal ? f_getBorderColor(showNYBorder, nyBorderColor) : na

asiaLabelColor = f_getLabelColor(showAsiaFill, asiaFillColor, showAsiaBorder, asiaBorderColor)
londonLabelColor = f_getLabelColor(showLondonFill, londonFillColor, showLondonBorder, londonBorderColor)
nyLabelColor = f_getLabelColor(showNYFill, nyFillColor, showNYBorder, nyBorderColor)

asiaLabelTextColor = f_getReadableTextColor(asiaLabelColor)
londonLabelTextColor = f_getReadableTextColor(londonLabelColor)
nyLabelTextColor = f_getReadableTextColor(nyLabelColor)

// ===================== Kill zone final colors =====================
asiaKillZoneBgColorFinal = showSessionAreasGlobal ? f_getFillColor(showAsiaKillZoneFill, asiaKillZoneFillColor) : na
londonKillZoneBgColorFinal = showSessionAreasGlobal ? f_getFillColor(showLondonKillZoneFill, londonKillZoneFillColor) : na
nyKillZoneBgColorFinal = showSessionAreasGlobal ? f_getFillColor(showNYKillZoneFill, nyKillZoneFillColor) : na

asiaKillZoneBorderFinal = showSessionAreasGlobal ? f_getBorderColor(showAsiaKillZoneBorder, asiaKillZoneBorderColor) : na
londonKillZoneBorderFinal = showSessionAreasGlobal ? f_getBorderColor(showLondonKillZoneBorder, londonKillZoneBorderColor) : na
nyKillZoneBorderFinal = showSessionAreasGlobal ? f_getBorderColor(showNYKillZoneBorder, nyKillZoneBorderColor) : na

// ===================== Level colors =====================
asiaLevelColor = f_getBaseLevelColor(asiaFillColor, showAsiaBorder, asiaBorderColor)
londonLevelColor = f_getBaseLevelColor(londonFillColor, showLondonBorder, londonBorderColor)
nyLevelColor = f_getBaseLevelColor(nyFillColor, showNYBorder, nyBorderColor)

// ===================== Raw session logic =====================
asiaActiveRaw   = time(timeframe.period, asiaSession) != 0
londonActiveRaw = time(timeframe.period, londonSession) != 0
nyActiveRaw     = time(timeframe.period, nySession) != 0

startAsiaRaw   = asiaActiveRaw and not asiaActiveRaw[1]
endAsiaRaw     = not asiaActiveRaw and asiaActiveRaw[1]
startLondonRaw = londonActiveRaw and not londonActiveRaw[1]
endLondonRaw   = not londonActiveRaw and londonActiveRaw[1]
startNYRaw     = nyActiveRaw and not nyActiveRaw[1]
endNYRaw       = not nyActiveRaw and nyActiveRaw[1]

// ===================== Session box logic =====================
inAsia   = showAsia and asiaActiveRaw
inLondon = showLondon and londonActiveRaw
inNY     = showNY and nyActiveRaw

startAsia = inAsia and not inAsia[1]
endAsia   = not inAsia and inAsia[1]
startLondon = inLondon and not inLondon[1]
endLondon   = not inLondon and inLondon[1]
startNY = inNY and not inNY[1]
endNY   = not inNY and inNY[1]

// ===================== Kill zone logic =====================
asiaKillZoneActiveRaw   = showAsiaKillZone and time(timeframe.period, asiaKillZoneSession) != 0
londonKillZoneActiveRaw = showLondonKillZone and time(timeframe.period, londonKillZoneSession) != 0
nyKillZoneActiveRaw     = showNYKillZone and time(timeframe.period, nyKillZoneSession) != 0

startAsiaKillZone   = asiaKillZoneActiveRaw and not asiaKillZoneActiveRaw[1]
endAsiaKillZone     = not asiaKillZoneActiveRaw and asiaKillZoneActiveRaw[1]
startLondonKillZone = londonKillZoneActiveRaw and not londonKillZoneActiveRaw[1]
endLondonKillZone   = not londonKillZoneActiveRaw and londonKillZoneActiveRaw[1]
startNYKillZone     = nyKillZoneActiveRaw and not nyKillZoneActiveRaw[1]
endNYKillZone       = not nyKillZoneActiveRaw and nyKillZoneActiveRaw[1]

// ===================== Session box vars =====================
var box asiaBox = na
var float highAsia = na
var float lowAsia = na
var int asiaStartBar = na
var int asiaEndBar = na

var box londonBox = na
var float highLondon = na
var float lowLondon = na
var int londonStartBar = na
var int londonEndBar = na

var box nyBox = na
var float highNY = na
var float lowNY = na
var int nyStartBar = na
var int nyEndBar = na

// ===================== Kill zone vars =====================
var box asiaKillZoneBox = na
var float asiaKillZoneHigh = na
var float asiaKillZoneLow = na

var box londonKillZoneBox = na
var float londonKillZoneHigh = na
var float londonKillZoneLow = na

var box nyKillZoneBox = na
var float nyKillZoneHigh = na
var float nyKillZoneLow = na

// ===================== Level tracking vars =====================
var float asiaTrackedHigh = na
var float asiaTrackedLow = na
var int asiaTrackedHighBar = na
var int asiaTrackedLowBar = na
var float asiaPriorHigh = na
var float asiaPriorLow = na
var int asiaPriorHighBar = na
var int asiaPriorLowBar = na

var float londonTrackedHigh = na
var float londonTrackedLow = na
var int londonTrackedHighBar = na
var int londonTrackedLowBar = na
var float londonPriorHigh = na
var float londonPriorLow = na
var int londonPriorHighBar = na
var int londonPriorLowBar = na

var float nyTrackedHigh = na
var float nyTrackedLow = na
var int nyTrackedHighBar = na
var int nyTrackedLowBar = na
var float nyPriorHigh = na
var float nyPriorLow = na
var int nyPriorHighBar = na
var int nyPriorLowBar = na

// ===================== Level object vars =====================
var line asiaPriorHighLine = na
var line asiaPriorLowLine = na
var label asiaPriorHighLabel = na
var label asiaPriorLowLabel = na

var line asiaCurrentHighLine = na
var line asiaCurrentLowLine = na
var label asiaCurrentHighLabel = na
var label asiaCurrentLowLabel = na

var line londonPriorHighLine = na
var line londonPriorLowLine = na
var label londonPriorHighLabel = na
var label londonPriorLowLabel = na

var line londonCurrentHighLine = na
var line londonCurrentLowLine = na
var label londonCurrentHighLabel = na
var label londonCurrentLowLabel = na

var line nyPriorHighLine = na
var line nyPriorLowLine = na
var label nyPriorHighLabel = na
var label nyPriorLowLabel = na

var line nyCurrentHighLine = na
var line nyCurrentLowLine = na
var label nyCurrentHighLabel = na
var label nyCurrentLowLabel = na

//---------------------------------------------------------------------
// === Session boxes ===
if startAsia
    highAsia := high
    lowAsia := low
    asiaStartBar := bar_index
    asiaBox := box.new(left=bar_index, right=bar_index, top=high, bottom=low, bgcolor=asiaBgColorFinal, border_color=asiaBorderFinal)

if inAsia
    highAsia := math.max(highAsia, high)
    lowAsia := math.min(lowAsia, low)
    box.set_right(asiaBox, bar_index)
    box.set_top(asiaBox, highAsia)
    box.set_bottom(asiaBox, lowAsia)
    box.set_bgcolor(asiaBox, asiaBgColorFinal)
    box.set_border_color(asiaBox, asiaBorderFinal)
    asiaEndBar := bar_index

if endAsia and not na(asiaBox)
    box.set_right(asiaBox, bar_index)
    box.set_top(asiaBox, highAsia)
    box.set_bottom(asiaBox, lowAsia)

    if showOpenLabels
        label.new(asiaStartBar, highAsia + (highAsia - lowAsia) * 0.03, "Asia open " + str.tostring(asiaStartHour, "00") + ":" + str.tostring(asiaStartMin, "00"), color=asiaLabelColor, textcolor=asiaLabelTextColor, size=labelSizeFinal)

    if showCloseLabels
        label.new(asiaEndBar, lowAsia - (highAsia - lowAsia) * 0.03, "Asia close " + str.tostring(asiaEndHour, "00") + ":" + str.tostring(asiaEndMin, "00"), color=asiaLabelColor, textcolor=asiaLabelTextColor, size=labelSizeFinal, style=label.style_label_up)

    asiaBox := na
    highAsia := na
    lowAsia := na
    asiaStartBar := na
    asiaEndBar := na

if startLondon
    highLondon := high
    lowLondon := low
    londonStartBar := bar_index
    londonBox := box.new(left=bar_index, right=bar_index, top=high, bottom=low, bgcolor=londonBgColorFinal, border_color=londonBorderFinal)

if inLondon
    highLondon := math.max(highLondon, high)
    lowLondon := math.min(lowLondon, low)
    box.set_right(londonBox, bar_index)
    box.set_top(londonBox, highLondon)
    box.set_bottom(londonBox, lowLondon)
    box.set_bgcolor(londonBox, londonBgColorFinal)
    box.set_border_color(londonBox, londonBorderFinal)
    londonEndBar := bar_index

if endLondon and not na(londonBox)
    box.set_right(londonBox, bar_index)
    box.set_top(londonBox, highLondon)
    box.set_bottom(londonBox, lowLondon)

    if showOpenLabels
        label.new(londonStartBar, highLondon + (highLondon - lowLondon) * 0.03, "London open " + str.tostring(londonStartHour, "00") + ":" + str.tostring(londonStartMin, "00"), color=londonLabelColor, textcolor=londonLabelTextColor, size=labelSizeFinal)

    if showCloseLabels
        label.new(londonEndBar, lowLondon - (highLondon - lowLondon) * 0.03, "London close " + str.tostring(londonEndHour, "00") + ":" + str.tostring(londonEndMin, "00"), color=londonLabelColor, textcolor=londonLabelTextColor, size=labelSizeFinal, style=label.style_label_up)

    londonBox := na
    highLondon := na
    lowLondon := na
    londonStartBar := na
    londonEndBar := na

if startNY
    highNY := high
    lowNY := low
    nyStartBar := bar_index
    nyBox := box.new(left=bar_index, right=bar_index, top=high, bottom=low, bgcolor=nyBgColorFinal, border_color=nyBorderFinal)

if inNY
    highNY := math.max(highNY, high)
    lowNY := math.min(lowNY, low)
    box.set_right(nyBox, bar_index)
    box.set_top(nyBox, highNY)
    box.set_bottom(nyBox, lowNY)
    box.set_bgcolor(nyBox, nyBgColorFinal)
    box.set_border_color(nyBox, nyBorderFinal)
    nyEndBar := bar_index

if endNY and not na(nyBox)
    box.set_right(nyBox, bar_index)
    box.set_top(nyBox, highNY)
    box.set_bottom(nyBox, lowNY)

    if showOpenLabels
        label.new(nyStartBar, highNY + (highNY - lowNY) * 0.03, "New York open " + str.tostring(nyStartHour, "00") + ":" + str.tostring(nyStartMin, "00"), color=nyLabelColor, textcolor=nyLabelTextColor, size=labelSizeFinal)

    if showCloseLabels
        label.new(nyEndBar, lowNY - (highNY - lowNY) * 0.03, "New York close " + str.tostring(nyEndHour, "00") + ":" + str.tostring(nyEndMin, "00"), color=nyLabelColor, textcolor=nyLabelTextColor, size=labelSizeFinal, style=label.style_label_up)

    nyBox := na
    highNY := na
    lowNY := na
    nyStartBar := na
    nyEndBar := na

//---------------------------------------------------------------------
// === Kill zones ===
if startAsiaKillZone
    asiaKillZoneHigh := high
    asiaKillZoneLow := low
    asiaKillZoneBox := box.new(left=bar_index, right=bar_index, top=high, bottom=low, bgcolor=asiaKillZoneBgColorFinal, border_color=asiaKillZoneBorderFinal)

if asiaKillZoneActiveRaw
    asiaKillZoneHigh := math.max(asiaKillZoneHigh, high)
    asiaKillZoneLow := math.min(asiaKillZoneLow, low)
    box.set_right(asiaKillZoneBox, bar_index)
    box.set_top(asiaKillZoneBox, asiaKillZoneHigh)
    box.set_bottom(asiaKillZoneBox, asiaKillZoneLow)
    box.set_bgcolor(asiaKillZoneBox, asiaKillZoneBgColorFinal)
    box.set_border_color(asiaKillZoneBox, asiaKillZoneBorderFinal)

if endAsiaKillZone and not na(asiaKillZoneBox)
    asiaKillZoneBox := na
    asiaKillZoneHigh := na
    asiaKillZoneLow := na

if startLondonKillZone
    londonKillZoneHigh := high
    londonKillZoneLow := low
    londonKillZoneBox := box.new(left=bar_index, right=bar_index, top=high, bottom=low, bgcolor=londonKillZoneBgColorFinal, border_color=londonKillZoneBorderFinal)

if londonKillZoneActiveRaw
    londonKillZoneHigh := math.max(londonKillZoneHigh, high)
    londonKillZoneLow := math.min(londonKillZoneLow, low)
    box.set_right(londonKillZoneBox, bar_index)
    box.set_top(londonKillZoneBox, londonKillZoneHigh)
    box.set_bottom(londonKillZoneBox, londonKillZoneLow)
    box.set_bgcolor(londonKillZoneBox, londonKillZoneBgColorFinal)
    box.set_border_color(londonKillZoneBox, londonKillZoneBorderFinal)

if endLondonKillZone and not na(londonKillZoneBox)
    londonKillZoneBox := na
    londonKillZoneHigh := na
    londonKillZoneLow := na

if startNYKillZone
    nyKillZoneHigh := high
    nyKillZoneLow := low
    nyKillZoneBox := box.new(left=bar_index, right=bar_index, top=high, bottom=low, bgcolor=nyKillZoneBgColorFinal, border_color=nyKillZoneBorderFinal)

if nyKillZoneActiveRaw
    nyKillZoneHigh := math.max(nyKillZoneHigh, high)
    nyKillZoneLow := math.min(nyKillZoneLow, low)
    box.set_right(nyKillZoneBox, bar_index)
    box.set_top(nyKillZoneBox, nyKillZoneHigh)
    box.set_bottom(nyKillZoneBox, nyKillZoneLow)
    box.set_bgcolor(nyKillZoneBox, nyKillZoneBgColorFinal)
    box.set_border_color(nyKillZoneBox, nyKillZoneBorderFinal)

if endNYKillZone and not na(nyKillZoneBox)
    nyKillZoneBox := na
    nyKillZoneHigh := na
    nyKillZoneLow := na

//---------------------------------------------------------------------
// === Track session highs/lows ===
if startAsiaRaw
    asiaTrackedHigh := high
    asiaTrackedLow := low
    asiaTrackedHighBar := bar_index
    asiaTrackedLowBar := bar_index

if asiaActiveRaw
    if na(asiaTrackedHigh) or high > asiaTrackedHigh
        asiaTrackedHigh := high
        asiaTrackedHighBar := bar_index
    if na(asiaTrackedLow) or low < asiaTrackedLow
        asiaTrackedLow := low
        asiaTrackedLowBar := bar_index

if endAsiaRaw
    asiaPriorHigh := asiaTrackedHigh
    asiaPriorLow := asiaTrackedLow
    asiaPriorHighBar := asiaTrackedHighBar
    asiaPriorLowBar := asiaTrackedLowBar
    asiaTrackedHigh := na
    asiaTrackedLow := na
    asiaTrackedHighBar := na
    asiaTrackedLowBar := na

if startLondonRaw
    londonTrackedHigh := high
    londonTrackedLow := low
    londonTrackedHighBar := bar_index
    londonTrackedLowBar := bar_index

if londonActiveRaw
    if na(londonTrackedHigh) or high > londonTrackedHigh
        londonTrackedHigh := high
        londonTrackedHighBar := bar_index
    if na(londonTrackedLow) or low < londonTrackedLow
        londonTrackedLow := low
        londonTrackedLowBar := bar_index

if endLondonRaw
    londonPriorHigh := londonTrackedHigh
    londonPriorLow := londonTrackedLow
    londonPriorHighBar := londonTrackedHighBar
    londonPriorLowBar := londonTrackedLowBar
    londonTrackedHigh := na
    londonTrackedLow := na
    londonTrackedHighBar := na
    londonTrackedLowBar := na

if startNYRaw
    nyTrackedHigh := high
    nyTrackedLow := low
    nyTrackedHighBar := bar_index
    nyTrackedLowBar := bar_index

if nyActiveRaw
    if na(nyTrackedHigh) or high > nyTrackedHigh
        nyTrackedHigh := high
        nyTrackedHighBar := bar_index
    if na(nyTrackedLow) or low < nyTrackedLow
        nyTrackedLow := low
        nyTrackedLowBar := bar_index

if endNYRaw
    nyPriorHigh := nyTrackedHigh
    nyPriorLow := nyTrackedLow
    nyPriorHighBar := nyTrackedHighBar
    nyPriorLowBar := nyTrackedLowBar
    nyTrackedHigh := na
    nyTrackedLow := na
    nyTrackedHighBar := na
    nyTrackedLowBar := na

//---------------------------------------------------------------------
// === Render prior/current levels ===
labelYOffsetPrice = syminfo.mintick * levelLabelVerticalOffsetTicks

// Asia prior
showAsiaPriorHigh = showAsiaLevels and showAsiaPriorLevels and showAsiaLevelHighs and not na(asiaPriorHigh)
showAsiaPriorLow = showAsiaLevels and showAsiaPriorLevels and showAsiaLevelLows and not na(asiaPriorLow)

asiaPriorHighLine := f_updateLevelLine(asiaPriorHighLine, showAsiaPriorHigh and showSessionLevelLinesGlobal, asiaPriorHighBar, asiaPriorHigh, asiaLevelColor, priorLineStyle, priorLineWidth)
asiaPriorLowLine := f_updateLevelLine(asiaPriorLowLine, showAsiaPriorLow and showSessionLevelLinesGlobal, asiaPriorLowBar, asiaPriorLow, asiaLevelColor, priorLineStyle, priorLineWidth)

asiaPriorHighLabel := f_updateLevelLabel(asiaPriorHighLabel, showAsiaPriorHigh and showSessionLevelTextGlobal, bar_index + levelTextOffsetBars, asiaPriorHigh + labelYOffsetPrice, "Asia prior high", asiaLevelColor, labelSizeOption)
asiaPriorLowLabel := f_updateLevelLabel(asiaPriorLowLabel, showAsiaPriorLow and showSessionLevelTextGlobal, bar_index + levelTextOffsetBars, asiaPriorLow + labelYOffsetPrice, "Asia prior low", asiaLevelColor, labelSizeOption)

// Asia current
showAsiaCurrentHigh = showAsiaLevels and showAsiaCurrentLevels and showAsiaLevelHighs and asiaActiveRaw and not na(asiaTrackedHigh)
showAsiaCurrentLow = showAsiaLevels and showAsiaCurrentLevels and showAsiaLevelLows and asiaActiveRaw and not na(asiaTrackedLow)

asiaCurrentHighLine := f_updateLevelLine(asiaCurrentHighLine, showAsiaCurrentHigh and showSessionLevelLinesGlobal, asiaTrackedHighBar, asiaTrackedHigh, asiaLevelColor, currentLineStyle, currentLineWidth)
asiaCurrentLowLine := f_updateLevelLine(asiaCurrentLowLine, showAsiaCurrentLow and showSessionLevelLinesGlobal, asiaTrackedLowBar, asiaTrackedLow, asiaLevelColor, currentLineStyle, currentLineWidth)

asiaCurrentHighLabel := f_updateLevelLabel(asiaCurrentHighLabel, showAsiaCurrentHigh and showSessionLevelTextGlobal, bar_index + levelTextOffsetBars, asiaTrackedHigh + labelYOffsetPrice, "Asia current high", asiaLevelColor, labelSizeOption)
asiaCurrentLowLabel := f_updateLevelLabel(asiaCurrentLowLabel, showAsiaCurrentLow and showSessionLevelTextGlobal, bar_index + levelTextOffsetBars, asiaTrackedLow + labelYOffsetPrice, "Asia current low", asiaLevelColor, labelSizeOption)

// London prior
showLondonPriorHigh = showLondonLevels and showLondonPriorLevels and showLondonLevelHighs and not na(londonPriorHigh)
showLondonPriorLow = showLondonLevels and showLondonPriorLevels and showLondonLevelLows and not na(londonPriorLow)

londonPriorHighLine := f_updateLevelLine(londonPriorHighLine, showLondonPriorHigh and showSessionLevelLinesGlobal, londonPriorHighBar, londonPriorHigh, londonLevelColor, priorLineStyle, priorLineWidth)
londonPriorLowLine := f_updateLevelLine(londonPriorLowLine, showLondonPriorLow and showSessionLevelLinesGlobal, londonPriorLowBar, londonPriorLow, londonLevelColor, priorLineStyle, priorLineWidth)

londonPriorHighLabel := f_updateLevelLabel(londonPriorHighLabel, showLondonPriorHigh and showSessionLevelTextGlobal, bar_index + levelTextOffsetBars, londonPriorHigh + labelYOffsetPrice, "London prior high", londonLevelColor, labelSizeOption)
londonPriorLowLabel := f_updateLevelLabel(londonPriorLowLabel, showLondonPriorLow and showSessionLevelTextGlobal, bar_index + levelTextOffsetBars, londonPriorLow + labelYOffsetPrice, "London prior low", londonLevelColor, labelSizeOption)

// London current
showLondonCurrentHigh = showLondonLevels and showLondonCurrentLevels and showLondonLevelHighs and londonActiveRaw and not na(londonTrackedHigh)
showLondonCurrentLow = showLondonLevels and showLondonCurrentLevels and showLondonLevelLows and londonActiveRaw and not na(londonTrackedLow)

londonCurrentHighLine := f_updateLevelLine(londonCurrentHighLine, showLondonCurrentHigh and showSessionLevelLinesGlobal, londonTrackedHighBar, londonTrackedHigh, londonLevelColor, currentLineStyle, currentLineWidth)
londonCurrentLowLine := f_updateLevelLine(londonCurrentLowLine, showLondonCurrentLow and showSessionLevelLinesGlobal, londonTrackedLowBar, londonTrackedLow, londonLevelColor, currentLineStyle, currentLineWidth)

londonCurrentHighLabel := f_updateLevelLabel(londonCurrentHighLabel, showLondonCurrentHigh and showSessionLevelTextGlobal, bar_index + levelTextOffsetBars, londonTrackedHigh + labelYOffsetPrice, "London current high", londonLevelColor, labelSizeOption)
londonCurrentLowLabel := f_updateLevelLabel(londonCurrentLowLabel, showLondonCurrentLow and showSessionLevelTextGlobal, bar_index + levelTextOffsetBars, londonTrackedLow + labelYOffsetPrice, "London current low", londonLevelColor, labelSizeOption)

// New York prior
showNYPriorHigh = showNYLevels and showNYPriorLevels and showNYLevelHighs and not na(nyPriorHigh)
showNYPriorLow = showNYLevels and showNYPriorLevels and showNYLevelLows and not na(nyPriorLow)

nyPriorHighLine := f_updateLevelLine(nyPriorHighLine, showNYPriorHigh and showSessionLevelLinesGlobal, nyPriorHighBar, nyPriorHigh, nyLevelColor, priorLineStyle, priorLineWidth)
nyPriorLowLine := f_updateLevelLine(nyPriorLowLine, showNYPriorLow and showSessionLevelLinesGlobal, nyPriorLowBar, nyPriorLow, nyLevelColor, priorLineStyle, priorLineWidth)

nyPriorHighLabel := f_updateLevelLabel(nyPriorHighLabel, showNYPriorHigh and showSessionLevelTextGlobal, bar_index + levelTextOffsetBars, nyPriorHigh + labelYOffsetPrice, "New York prior high", nyLevelColor, labelSizeOption)
nyPriorLowLabel := f_updateLevelLabel(nyPriorLowLabel, showNYPriorLow and showSessionLevelTextGlobal, bar_index + levelTextOffsetBars, nyPriorLow + labelYOffsetPrice, "New York prior low", nyLevelColor, labelSizeOption)

// New York current
showNYCurrentHigh = showNYLevels and showNYCurrentLevels and showNYLevelHighs and nyActiveRaw and not na(nyTrackedHigh)
showNYCurrentLow = showNYLevels and showNYCurrentLevels and showNYLevelLows and nyActiveRaw and not na(nyTrackedLow)

nyCurrentHighLine := f_updateLevelLine(nyCurrentHighLine, showNYCurrentHigh and showSessionLevelLinesGlobal, nyTrackedHighBar, nyTrackedHigh, nyLevelColor, currentLineStyle, currentLineWidth)
nyCurrentLowLine := f_updateLevelLine(nyCurrentLowLine, showNYCurrentLow and showSessionLevelLinesGlobal, nyTrackedLowBar, nyTrackedLow, nyLevelColor, currentLineStyle, currentLineWidth)

nyCurrentHighLabel := f_updateLevelLabel(nyCurrentHighLabel, showNYCurrentHigh and showSessionLevelTextGlobal, bar_index + levelTextOffsetBars, nyTrackedHigh + labelYOffsetPrice, "New York current high", nyLevelColor, labelSizeOption)
nyCurrentLowLabel := f_updateLevelLabel(nyCurrentLowLabel, showNYCurrentLow and showSessionLevelTextGlobal, bar_index + levelTextOffsetBars, nyTrackedLow + labelYOffsetPrice, "New York current low", nyLevelColor, labelSizeOption)
````
