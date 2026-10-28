# UTC-4 Session levels 

- url: https://www.tradingview.com/script/hEK4fENw-UTC-4-Session-levels/
- type: indicator
- pine_id: PUB;dd6000c867214387b9e8146580618461
- version: 3.0

## Description

Asia London NewYork h/l line stops at mitigation. Labeled

## Source Code

````pine
//@version=6
indicator(
    "UTC-4 Session High/Low Mitigation Levels",
    overlay=true,
    max_bars_back=5000,
    max_lines_count=500,
    max_labels_count=500
)

sessionTimezone = "GMT-4"

defaultSession1 = "2000-0200"
defaultSession2 = "0300-0930"
defaultSession3 = "0930-1600"

customSessionsGroup = "Custom Sessions"
developingSessionsGroup = "Developing Sessions"
previousLevelsGroup = "Previous Periods"
colorsGroup = "Colors"
lineStyleGroup = "Line Style"
labelsGroup = "Labels"
watermarkGroup = "Watermark"

useCustomSessionTimes = input.bool(
    false,
    "Use Custom Session Times",
    group=customSessionsGroup,
    tooltip="Turn this on to replace the default Tokyo/London/New York windows with your own session times, such as 1600-2200."
)
customSession1 = input.session(defaultSession1, "Custom Session 1 (UTC-4)", group=customSessionsGroup)
customSession2 = input.session(defaultSession2, "Custom Session 2 (UTC-4)", group=customSessionsGroup)
customSession3 = input.session(defaultSession3, "Custom Session 3 (UTC-4)", group=customSessionsGroup)

showDevelopingSessionLevels = input.bool(
    true,
    "Show Developing Session Levels",
    group=developingSessionsGroup,
    tooltip="While a session is still expanding, the most recently extended side stays hidden until price pulls away from it. Example: if price keeps pushing higher, only the session low stays visible until price pulls back and confirms the high."
)

showPreviousDayLevels = input.bool(false, "Show Previous Day High/Low", group=previousLevelsGroup)
showPreviousWeekLevels = input.bool(false, "Show Previous Week High/Low", group=previousLevelsGroup)
showPreviousMonthLevels = input.bool(false, "Show Previous Month High/Low", group=previousLevelsGroup)

session1Tag = input.string("TKO", "Session 1 Tag", group=labelsGroup)
session2Tag = input.string("LDN", "Session 2 Tag", group=labelsGroup)
session3Tag = input.string("NY", "Session 3 Tag", group=labelsGroup)
finalizedHighSuffix = input.string("H", "Finalized High Suffix", group=labelsGroup)
finalizedLowSuffix = input.string("L", "Finalized Low Suffix", group=labelsGroup)
developingHighSuffix = input.string("Dev H", "Developing High Suffix", group=labelsGroup)
developingLowSuffix = input.string("Dev L", "Developing Low Suffix", group=labelsGroup)
previousDayHighLabelText = input.string("PDH", "Previous Day High Label", group=labelsGroup)
previousDayLowLabelText = input.string("PDL", "Previous Day Low Label", group=labelsGroup)
previousWeekHighLabelText = input.string("PWH", "Previous Week High Label", group=labelsGroup)
previousWeekLowLabelText = input.string("PWL", "Previous Week Low Label", group=labelsGroup)
previousMonthHighLabelText = input.string("PMH", "Previous Month High Label", group=labelsGroup)
previousMonthLowLabelText = input.string("PML", "Previous Month Low Label", group=labelsGroup)

session1Window = useCustomSessionTimes ? customSession1 : defaultSession1
session2Window = useCustomSessionTimes ? customSession2 : defaultSession2
session3Window = useCustomSessionTimes ? customSession3 : defaultSession3

session1Label = session1Tag
session2Label = session2Tag
session3Label = session3Tag

session1Color = input.color(color.yellow, "Session 1 Color", group=colorsGroup)
session1TextColor = color.black
session2Color = input.color(color.purple, "Session 2 Color", group=colorsGroup)
session2TextColor = color.white
session3Color = input.color(color.blue, "Session 3 Color", group=colorsGroup)
session3TextColor = color.white
previousDayColor = input.color(color.red, "Previous Day Color", group=colorsGroup)
previousWeekColor = input.color(color.orange, "Previous Week Color", group=colorsGroup)
previousMonthColor = input.color(color.fuchsia, "Previous Month Color", group=colorsGroup)

finalizedLineStyleInput = input.string("Solid", "Finalized Session Line Style", options=["Solid", "Dashed", "Dotted"], group=lineStyleGroup)
finalizedLineWidth = input.int(1, "Finalized Session Line Thickness", minval=1, maxval=5, group=lineStyleGroup)
developingLineStyleInput = input.string("Dashed", "Developing Session Line Style", options=["Solid", "Dashed", "Dotted"], group=lineStyleGroup)
developingLineWidth = input.int(1, "Developing Session Line Thickness", minval=1, maxval=5, group=lineStyleGroup)
previousPeriodLineStyleInput = input.string("Solid", "Previous Period Line Style", options=["Solid", "Dashed", "Dotted"], group=lineStyleGroup)
previousPeriodLineWidth = input.int(1, "Previous Period Line Thickness", minval=1, maxval=5, group=lineStyleGroup)

showWatermark = input.bool(true, "Show Watermark", group=watermarkGroup)
watermarkText = input.string("Lord let your will be done", "Watermark Text", group=watermarkGroup)
watermarkColor = input.color(color.new(color.silver, 70), "Watermark Color", group=watermarkGroup)
watermarkPositionInput = input.string(
    "Bottom Right",
    "Watermark Position",
    options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"],
    group=watermarkGroup
)

levelSourceTimeframe = input.timeframe("1", "Level Detection Timeframe")

resolveLineStyle(styleInput) =>
    switch styleInput
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

finalizedLineStyle = resolveLineStyle(finalizedLineStyleInput)
developingLineStyle = resolveLineStyle(developingLineStyleInput)
previousPeriodLineStyle = resolveLineStyle(previousPeriodLineStyleInput)

watermarkPosition = switch watermarkPositionInput
    "Top Left" => position.top_left
    "Top Center" => position.top_center
    "Top Right" => position.top_right
    "Middle Left" => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right" => position.middle_right
    "Bottom Left" => position.bottom_left
    "Bottom Center" => position.bottom_center
    => position.bottom_right

var table watermarkTable = table.new(watermarkPosition, 1, 1, border_width=0)

var line[] activeLines = array.new_line()
var label[] activeLabels = array.new_label()
var float[] activePrices = array.new_float()
var bool[] activeIsHigh = array.new_bool()
var int[] activeEligibleBars = array.new_int()

trackFinalizedSessionLevels(sessionValue, timezoneValue) =>
    bool inSession = not na(time("", sessionValue, timezoneValue))
    bool sessionStart = inSession and not inSession[1]
    bool sessionEnd = not inSession and inSession[1]

    var float highWorking = na
    var float lowWorking = na
    var int highTimeWorking = na
    var int lowTimeWorking = na
    var float finalizedHigh = na
    var float finalizedLow = na
    var int finalizedHighTime = na
    var int finalizedLowTime = na
    var int sessionToken = 0

    if sessionStart
        highWorking := high
        lowWorking := low
        highTimeWorking := time
        lowTimeWorking := time
    else if inSession
        if na(highWorking) or high > highWorking
            highWorking := high
            highTimeWorking := time
        if na(lowWorking) or low < lowWorking
            lowWorking := low
            lowTimeWorking := time

    if sessionEnd
        finalizedHigh := highWorking
        finalizedLow := lowWorking
        finalizedHighTime := highTimeWorking
        finalizedLowTime := lowTimeWorking
        sessionToken += 1

    [sessionToken, finalizedHigh, finalizedHighTime, finalizedLow, finalizedLowTime]

trackDevelopingSessionLevels(sessionValue, timezoneValue) =>
    bool inSession = not na(time("", sessionValue, timezoneValue))
    bool sessionStart = inSession and not inSession[1]

    var float highWorking = na
    var float lowWorking = na
    var int sessionStartTime = na
    var bool highConfirmed = false
    var bool lowConfirmed = false
    var int lastExpansionDirection = 0

    if sessionStart
        highWorking := high
        lowWorking := low
        sessionStartTime := time
        highConfirmed := false
        lowConfirmed := false
        lastExpansionDirection := 0
    else if inSession
        bool madeNewHigh = na(highWorking) or high > highWorking
        bool madeNewLow = na(lowWorking) or low < lowWorking

        if madeNewHigh
            highWorking := high
            highConfirmed := false
        if madeNewLow
            lowWorking := low
            lowConfirmed := false

        if madeNewHigh and not madeNewLow
            lastExpansionDirection := 1
        else if madeNewLow and not madeNewHigh
            lastExpansionDirection := -1
        else if madeNewHigh and madeNewLow
            lastExpansionDirection := close >= open ? 1 : -1

        if lastExpansionDirection == 1 and not highConfirmed and not madeNewHigh and close < highWorking
            highConfirmed := true
        if lastExpansionDirection == -1 and not lowConfirmed and not madeNewLow and close > lowWorking
            lowConfirmed := true
    else
        highWorking := na
        lowWorking := na
        sessionStartTime := na
        highConfirmed := false
        lowConfirmed := false
        lastExpansionDirection := 0

    bool showHigh = inSession and (lastExpansionDirection != 1 or highConfirmed)
    bool showLow = inSession and (lastExpansionDirection != -1 or lowConfirmed)

    [sessionStartTime, highWorking, lowWorking, showHigh, showLow]

composeLabel(baseText, suffixText) =>
    suffixText == "" ? baseText : baseText == "" ? suffixText : baseText + " " + suffixText

createLevel(startTime, levelPrice, levelColor, textColor, labelText, isHigh, lineStyleValue, lineWidthValue) =>
    line levelLine = line.new(
        startTime,
        levelPrice,
        time,
        levelPrice,
        xloc=xloc.bar_time,
        extend=extend.right,
        color=levelColor,
        style=lineStyleValue,
        width=lineWidthValue
    )
    label levelLabel = label.new(
        bar_index + 3,
        levelPrice,
        labelText,
        xloc=xloc.bar_index,
        style=label.style_label_left,
        color=levelColor,
        textcolor=textColor,
        size=size.tiny
    )
    array.push(activeLines, levelLine)
    array.push(activeLabels, levelLabel)
    array.push(activePrices, levelPrice)
    array.push(activeIsHigh, isHigh)
    array.push(activeEligibleBars, bar_index + 1)

upsertSpanLevel(showLevel, startTime, levelPrice, levelColor, textColor, labelText, lineStyleValue, lineWidthValue, existingLine, existingLabel) =>
    line updatedLine = existingLine
    label updatedLabel = existingLabel
    bool hasObjects = not na(updatedLine) and not na(updatedLabel)

    if showLevel and not na(startTime) and not na(levelPrice)
        if not hasObjects
            if not na(updatedLine)
                line.delete(updatedLine)
            if not na(updatedLabel)
                label.delete(updatedLabel)
            updatedLine := line.new(
                startTime,
                levelPrice,
                time,
                levelPrice,
                xloc=xloc.bar_time,
                extend=extend.none,
                color=levelColor,
                style=lineStyleValue,
                width=lineWidthValue
            )
            updatedLabel := label.new(
                bar_index + 1,
                levelPrice,
                labelText,
                xloc=xloc.bar_index,
                style=label.style_label_left,
                color=levelColor,
                textcolor=textColor,
                size=size.tiny
            )
        else
            line.set_x1(updatedLine, startTime)
            line.set_y1(updatedLine, levelPrice)
            line.set_x2(updatedLine, time)
            line.set_y2(updatedLine, levelPrice)
            line.set_color(updatedLine, levelColor)
            line.set_style(updatedLine, lineStyleValue)
            line.set_width(updatedLine, lineWidthValue)
            label.set_x(updatedLabel, bar_index + 1)
            label.set_y(updatedLabel, levelPrice)
            label.set_text(updatedLabel, labelText)
            label.set_color(updatedLabel, levelColor)
            label.set_textcolor(updatedLabel, textColor)
    else
        if not na(updatedLine)
            line.delete(updatedLine)
            updatedLine := na
        if not na(updatedLabel)
            label.delete(updatedLabel)
            updatedLabel := na

    [updatedLine, updatedLabel]

[session1Token, session1HighLevel, session1HighTime, session1LowLevel, session1LowTime] = request.security(
    syminfo.tickerid,
    levelSourceTimeframe,
    trackFinalizedSessionLevels(session1Window, sessionTimezone)
)

if session1Token != nz(session1Token[1])
    if not na(session1HighLevel) and not na(session1HighTime)
        createLevel(session1HighTime, session1HighLevel, session1Color, session1TextColor, composeLabel(session1Label, finalizedHighSuffix), true, finalizedLineStyle, finalizedLineWidth)
    if not na(session1LowLevel) and not na(session1LowTime)
        createLevel(session1LowTime, session1LowLevel, session1Color, session1TextColor, composeLabel(session1Label, finalizedLowSuffix), false, finalizedLineStyle, finalizedLineWidth)

[session2Token, session2HighLevel, session2HighTime, session2LowLevel, session2LowTime] = request.security(
    syminfo.tickerid,
    levelSourceTimeframe,
    trackFinalizedSessionLevels(session2Window, sessionTimezone)
)

if session2Token != nz(session2Token[1])
    if not na(session2HighLevel) and not na(session2HighTime)
        createLevel(session2HighTime, session2HighLevel, session2Color, session2TextColor, composeLabel(session2Label, finalizedHighSuffix), true, finalizedLineStyle, finalizedLineWidth)
    if not na(session2LowLevel) and not na(session2LowTime)
        createLevel(session2LowTime, session2LowLevel, session2Color, session2TextColor, composeLabel(session2Label, finalizedLowSuffix), false, finalizedLineStyle, finalizedLineWidth)

[session3Token, session3HighLevel, session3HighTime, session3LowLevel, session3LowTime] = request.security(
    syminfo.tickerid,
    levelSourceTimeframe,
    trackFinalizedSessionLevels(session3Window, sessionTimezone)
)

if session3Token != nz(session3Token[1])
    if not na(session3HighLevel) and not na(session3HighTime)
        createLevel(session3HighTime, session3HighLevel, session3Color, session3TextColor, composeLabel(session3Label, finalizedHighSuffix), true, finalizedLineStyle, finalizedLineWidth)
    if not na(session3LowLevel) and not na(session3LowTime)
        createLevel(session3LowTime, session3LowLevel, session3Color, session3TextColor, composeLabel(session3Label, finalizedLowSuffix), false, finalizedLineStyle, finalizedLineWidth)

[session1DevelopingStartTime, session1DevelopingHigh, session1DevelopingLow, session1ShowDevelopingHigh, session1ShowDevelopingLow] = request.security(
    syminfo.tickerid,
    levelSourceTimeframe,
    trackDevelopingSessionLevels(session1Window, sessionTimezone)
)
[session2DevelopingStartTime, session2DevelopingHigh, session2DevelopingLow, session2ShowDevelopingHigh, session2ShowDevelopingLow] = request.security(
    syminfo.tickerid,
    levelSourceTimeframe,
    trackDevelopingSessionLevels(session2Window, sessionTimezone)
)
[session3DevelopingStartTime, session3DevelopingHigh, session3DevelopingLow, session3ShowDevelopingHigh, session3ShowDevelopingLow] = request.security(
    syminfo.tickerid,
    levelSourceTimeframe,
    trackDevelopingSessionLevels(session3Window, sessionTimezone)
)

var line session1DevelopingHighLine = na
var line session1DevelopingLowLine = na
var label session1DevelopingHighLabel = na
var label session1DevelopingLowLabel = na

var line session2DevelopingHighLine = na
var line session2DevelopingLowLine = na
var label session2DevelopingHighLabel = na
var label session2DevelopingLowLabel = na

var line session3DevelopingHighLine = na
var line session3DevelopingLowLine = na
var label session3DevelopingHighLabel = na
var label session3DevelopingLowLabel = na

[session1DevelopingHighLineNext, session1DevelopingHighLabelNext] = upsertSpanLevel(
    showDevelopingSessionLevels and session1ShowDevelopingHigh,
    session1DevelopingStartTime,
    session1DevelopingHigh,
    session1Color,
    session1TextColor,
    composeLabel(session1Label, developingHighSuffix),
    developingLineStyle,
    developingLineWidth,
    session1DevelopingHighLine,
    session1DevelopingHighLabel
)
session1DevelopingHighLine := session1DevelopingHighLineNext
session1DevelopingHighLabel := session1DevelopingHighLabelNext

[session1DevelopingLowLineNext, session1DevelopingLowLabelNext] = upsertSpanLevel(
    showDevelopingSessionLevels and session1ShowDevelopingLow,
    session1DevelopingStartTime,
    session1DevelopingLow,
    session1Color,
    session1TextColor,
    composeLabel(session1Label, developingLowSuffix),
    developingLineStyle,
    developingLineWidth,
    session1DevelopingLowLine,
    session1DevelopingLowLabel
)
session1DevelopingLowLine := session1DevelopingLowLineNext
session1DevelopingLowLabel := session1DevelopingLowLabelNext

[session2DevelopingHighLineNext, session2DevelopingHighLabelNext] = upsertSpanLevel(
    showDevelopingSessionLevels and session2ShowDevelopingHigh,
    session2DevelopingStartTime,
    session2DevelopingHigh,
    session2Color,
    session2TextColor,
    composeLabel(session2Label, developingHighSuffix),
    developingLineStyle,
    developingLineWidth,
    session2DevelopingHighLine,
    session2DevelopingHighLabel
)
session2DevelopingHighLine := session2DevelopingHighLineNext
session2DevelopingHighLabel := session2DevelopingHighLabelNext

[session2DevelopingLowLineNext, session2DevelopingLowLabelNext] = upsertSpanLevel(
    showDevelopingSessionLevels and session2ShowDevelopingLow,
    session2DevelopingStartTime,
    session2DevelopingLow,
    session2Color,
    session2TextColor,
    composeLabel(session2Label, developingLowSuffix),
    developingLineStyle,
    developingLineWidth,
    session2DevelopingLowLine,
    session2DevelopingLowLabel
)
session2DevelopingLowLine := session2DevelopingLowLineNext
session2DevelopingLowLabel := session2DevelopingLowLabelNext

[session3DevelopingHighLineNext, session3DevelopingHighLabelNext] = upsertSpanLevel(
    showDevelopingSessionLevels and session3ShowDevelopingHigh,
    session3DevelopingStartTime,
    session3DevelopingHigh,
    session3Color,
    session3TextColor,
    composeLabel(session3Label, developingHighSuffix),
    developingLineStyle,
    developingLineWidth,
    session3DevelopingHighLine,
    session3DevelopingHighLabel
)
session3DevelopingHighLine := session3DevelopingHighLineNext
session3DevelopingHighLabel := session3DevelopingHighLabelNext

[session3DevelopingLowLineNext, session3DevelopingLowLabelNext] = upsertSpanLevel(
    showDevelopingSessionLevels and session3ShowDevelopingLow,
    session3DevelopingStartTime,
    session3DevelopingLow,
    session3Color,
    session3TextColor,
    composeLabel(session3Label, developingLowSuffix),
    developingLineStyle,
    developingLineWidth,
    session3DevelopingLowLine,
    session3DevelopingLowLabel
)
session3DevelopingLowLine := session3DevelopingLowLineNext
session3DevelopingLowLabel := session3DevelopingLowLabelNext

currentDayToken = year(time, sessionTimezone) * 10000 + month(time, sessionTimezone) * 100 + dayofmonth(time, sessionTimezone)
currentWeekToken = year(time, sessionTimezone) * 100 + weekofyear(time, sessionTimezone)
currentMonthToken = year(time, sessionTimezone) * 100 + month(time, sessionTimezone)

isNewDay = na(currentDayToken[1]) or currentDayToken != currentDayToken[1]
isNewWeek = na(currentWeekToken[1]) or currentWeekToken != currentWeekToken[1]
isNewMonth = na(currentMonthToken[1]) or currentMonthToken != currentMonthToken[1]

var float currentDayHighWorking = na
var float currentDayLowWorking = na
var float previousDayHighLevel = na
var float previousDayLowLevel = na
var int currentDayStartTime = na

var float currentWeekHighWorking = na
var float currentWeekLowWorking = na
var float previousWeekHighLevel = na
var float previousWeekLowLevel = na
var int currentWeekStartTime = na

var float currentMonthHighWorking = na
var float currentMonthLowWorking = na
var float previousMonthHighLevel = na
var float previousMonthLowLevel = na
var int currentMonthStartTime = na

if isNewDay
    previousDayHighLevel := currentDayHighWorking
    previousDayLowLevel := currentDayLowWorking
    currentDayHighWorking := high
    currentDayLowWorking := low
    currentDayStartTime := time
else
    currentDayHighWorking := na(currentDayHighWorking) ? high : math.max(currentDayHighWorking, high)
    currentDayLowWorking := na(currentDayLowWorking) ? low : math.min(currentDayLowWorking, low)

if isNewWeek
    previousWeekHighLevel := currentWeekHighWorking
    previousWeekLowLevel := currentWeekLowWorking
    currentWeekHighWorking := high
    currentWeekLowWorking := low
    currentWeekStartTime := time
else
    currentWeekHighWorking := na(currentWeekHighWorking) ? high : math.max(currentWeekHighWorking, high)
    currentWeekLowWorking := na(currentWeekLowWorking) ? low : math.min(currentWeekLowWorking, low)

if isNewMonth
    previousMonthHighLevel := currentMonthHighWorking
    previousMonthLowLevel := currentMonthLowWorking
    currentMonthHighWorking := high
    currentMonthLowWorking := low
    currentMonthStartTime := time
else
    currentMonthHighWorking := na(currentMonthHighWorking) ? high : math.max(currentMonthHighWorking, high)
    currentMonthLowWorking := na(currentMonthLowWorking) ? low : math.min(currentMonthLowWorking, low)

var line previousDayHighLine = na
var line previousDayLowLine = na
var label previousDayHighLabel = na
var label previousDayLowLabel = na

var line previousWeekHighLine = na
var line previousWeekLowLine = na
var label previousWeekHighLabel = na
var label previousWeekLowLabel = na

var line previousMonthHighLine = na
var line previousMonthLowLine = na
var label previousMonthHighLabel = na
var label previousMonthLowLabel = na

[previousDayHighLineNext, previousDayHighLabelNext] = upsertSpanLevel(
    showPreviousDayLevels,
    currentDayStartTime,
    previousDayHighLevel,
    previousDayColor,
    color.white,
    previousDayHighLabelText,
    previousPeriodLineStyle,
    previousPeriodLineWidth,
    previousDayHighLine,
    previousDayHighLabel
)
previousDayHighLine := previousDayHighLineNext
previousDayHighLabel := previousDayHighLabelNext

[previousDayLowLineNext, previousDayLowLabelNext] = upsertSpanLevel(
    showPreviousDayLevels,
    currentDayStartTime,
    previousDayLowLevel,
    previousDayColor,
    color.white,
    previousDayLowLabelText,
    previousPeriodLineStyle,
    previousPeriodLineWidth,
    previousDayLowLine,
    previousDayLowLabel
)
previousDayLowLine := previousDayLowLineNext
previousDayLowLabel := previousDayLowLabelNext

[previousWeekHighLineNext, previousWeekHighLabelNext] = upsertSpanLevel(
    showPreviousWeekLevels,
    currentWeekStartTime,
    previousWeekHighLevel,
    previousWeekColor,
    color.white,
    previousWeekHighLabelText,
    previousPeriodLineStyle,
    previousPeriodLineWidth,
    previousWeekHighLine,
    previousWeekHighLabel
)
previousWeekHighLine := previousWeekHighLineNext
previousWeekHighLabel := previousWeekHighLabelNext

[previousWeekLowLineNext, previousWeekLowLabelNext] = upsertSpanLevel(
    showPreviousWeekLevels,
    currentWeekStartTime,
    previousWeekLowLevel,
    previousWeekColor,
    color.white,
    previousWeekLowLabelText,
    previousPeriodLineStyle,
    previousPeriodLineWidth,
    previousWeekLowLine,
    previousWeekLowLabel
)
previousWeekLowLine := previousWeekLowLineNext
previousWeekLowLabel := previousWeekLowLabelNext

[previousMonthHighLineNext, previousMonthHighLabelNext] = upsertSpanLevel(
    showPreviousMonthLevels,
    currentMonthStartTime,
    previousMonthHighLevel,
    previousMonthColor,
    color.white,
    previousMonthHighLabelText,
    previousPeriodLineStyle,
    previousPeriodLineWidth,
    previousMonthHighLine,
    previousMonthHighLabel
)
previousMonthHighLine := previousMonthHighLineNext
previousMonthHighLabel := previousMonthHighLabelNext

[previousMonthLowLineNext, previousMonthLowLabelNext] = upsertSpanLevel(
    showPreviousMonthLevels,
    currentMonthStartTime,
    previousMonthLowLevel,
    previousMonthColor,
    color.white,
    previousMonthLowLabelText,
    previousPeriodLineStyle,
    previousPeriodLineWidth,
    previousMonthLowLine,
    previousMonthLowLabel
)
previousMonthLowLine := previousMonthLowLineNext
previousMonthLowLabel := previousMonthLowLabelNext

if barstate.islast
    table.cell(
        watermarkTable,
        0,
        0,
        showWatermark ? watermarkText : "",
        text_color=watermarkColor,
        text_size=size.large,
        bgcolor=color.new(color.black, 100)
    )

if array.size(activeLines) > 0
    int index = array.size(activeLines) - 1
    while index >= 0
        line levelLine = array.get(activeLines, index)
        label levelLabel = array.get(activeLabels, index)
        float levelPrice = array.get(activePrices, index)
        bool isHigh = array.get(activeIsHigh, index)
        int eligibleBar = array.get(activeEligibleBars, index)
        bool canMitigate = bar_index >= eligibleBar
        bool mitigated = canMitigate and (isHigh ? high >= levelPrice : low <= levelPrice)

        label.set_x(levelLabel, bar_index + 3)
        label.set_y(levelLabel, levelPrice)

        if mitigated
            line.set_x2(levelLine, time)
            line.set_extend(levelLine, extend.none)
            label.delete(levelLabel)
            array.remove(activeLines, index)
            array.remove(activeLabels, index)
            array.remove(activePrices, index)
            array.remove(activeIsHigh, index)
            array.remove(activeEligibleBars, index)

        index -= 1
````
