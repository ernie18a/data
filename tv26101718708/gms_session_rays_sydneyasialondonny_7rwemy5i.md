# GMS Session Rays (Sydney/Asia/London/NY)

- url: https://www.tradingview.com/script/7RWeMy5i-GMS-Session-Rays-Sydney-Asia-London-NY/
- type: indicator
- pine_id: PUB;98c0ad0914024d4b8b34bd677e382afc
- version: 3.0

## Description

A lightweight Pine v6 indicator that plots the previous completed session’s High and Low for the four major sessions—Sydney, Asia, London, New York—so you always see the most actionable structure levels without chart clutter. Lines auto-update at the end of each session and extend right as horizontal rays. Labels are clean, stack automatically to avoid overlap, and can be placed on the left or right side of the chart.
What it shows
Previous session High/Low for each enabled session (not the current live session).
Right-extended rays at those prices, updated when the session closes.
Optional labels per session (e.g., “sydney high”, “london low”), with auto-stacking to prevent overlaps.
Customization
Per-session toggles: show/hide each session; show/hide labels per session.
Style controls: color, width, and line style (Solid/Dotted/Dashed) per session.
Label controls: global on/off, Left/Right placement, bars offset, Y-offset (in ticks), size (Tiny/Small/Normal), auto-stacking with adjustable step.
Session windows: editable HHMM-HHMM for Sydney/Asia/London/NY.
Timezone: set a single indicator timezone (default America/New_York).
Only Today mode: clears older rays daily to keep charts minimal.
How it works (under the hood)
Tracks High/Low only while a session is active; when it ends, those values are frozen and plotted as the previous session levels.

## Source Code

````pine
//@version=6
indicator(
     "Session Rays – Previous Session Only (Sydney/Asia/London/NY)",
     overlay = true,
     max_lines_count = 500,
     max_labels_count = 500
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GENERAL SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

tz = input.string(
     "America/New_York",
     "Timezone"
)

onlyToday = input.bool(
     false,
     "Only Show Today"
)

// Global label settings
showLabelsGlobal = input.bool(
     true,
     "Show Labels (Global)"
)

labelSide = input.string(
     "Right",
     "Label Side",
     options = ["Right", "Left"]
)

labelBarsOffset = input.int(
     4,
     "Label Bars Offset",
     minval = 0,
     maxval = 50
)

labelYOffsetTicks = input.int(
     8,
     "Label Y Offset (ticks)",
     minval = 0,
     maxval = 200
)

labelSize = input.string(
     "Small",
     "Label Size",
     options = ["Tiny", "Small", "Normal"]
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HELPER FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_label_size(string selectedSize) =>
    result = size.small

    if selectedSize == "Tiny"
        result := size.tiny
    else if selectedSize == "Normal"
        result := size.normal

    result

lblSize = f_label_size(labelSize)

f_y_offset(bool isHigh) =>
    direction = isHigh ? 1.0 : -1.0

    float(labelYOffsetTicks) *
         syminfo.mintick *
         direction

f_in_session(
     string sessionString,
     string timezoneString
) =>
    not na(
         time(
             timeframe.period,
             sessionString,
             timezoneString
         )
    )

f_line_style(string selectedStyle) =>
    result = line.style_solid

    if selectedStyle == "Dotted"
        result := line.style_dotted
    else if selectedStyle == "Dashed"
        result := line.style_dashed

    result

f_new_calendar_day(string timezoneString) =>
    not na(time[1]) and
     dayofmonth(time, timezoneString) !=
     dayofmonth(time[1], timezoneString)

f_make_label(
     int barsOffset,
     float price,
     string labelText,
     color textColor
) =>
    label createdLabel = na

    if labelText != "" and showLabelsGlobal
        sideMultiplier =
             labelSide == "Right" ? 1 : -1

        labelX =
             bar_index +
             sideMultiplier * barsOffset

        selectedLabelStyle =
             labelSide == "Right" ?
             label.style_label_right :
             label.style_label_left

        selectedTextAlignment =
             labelSide == "Right" ?
             text.align_left :
             text.align_right

        createdLabel := label.new(
             x = labelX,
             y = price,
             text = labelText,
             xloc = xloc.bar_index,
             yloc = yloc.price,
             color = color.new(color.white, 100),
             style = selectedLabelStyle,
             textcolor = textColor,
             size = lblSize,
             textalign = selectedTextAlignment,
             tooltip = ""
        )

    createdLabel

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SYDNEY SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

grpSYD = "Sydney"

showSYD = input.bool(
     true,
     "Show Sydney",
     group = grpSYD
)

sydSess = input.session(
     "1700-0200",
     "Session (HHMM-HHMM)",
     group = grpSYD
)

sydHCol = input.color(
     color.teal,
     "High Color",
     group = grpSYD
)

sydLCol = input.color(
     color.teal,
     "Low Color",
     group = grpSYD
)

sydStyleStr = input.string(
     "Solid",
     "Line Style",
     options = ["Solid", "Dotted", "Dashed"],
     group = grpSYD
)

sydWidth = input.int(
     2,
     "Line Width",
     minval = 1,
     maxval = 4,
     group = grpSYD
)

sydShowPrev = input.bool(
     true,
     "Show Previous Sydney Session Levels",
     group = grpSYD
)

sydShowLbl = input.bool(
     true,
     "Show Sydney Labels",
     group = grpSYD
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ASIA SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

grpAS = "Asia"

showAS = input.bool(
     true,
     "Show Asia",
     group = grpAS
)

// Current summer/New York daylight-saving default.
// Change to 1900-0400 during New York standard time if desired.
asiaSess = input.session(
     "2000-0500",
     "Session (HHMM-HHMM)",
     group = grpAS
)

asiaHCol = input.color(
     color.blue,
     "High Color",
     group = grpAS
)

asiaLCol = input.color(
     color.blue,
     "Low Color",
     group = grpAS
)

asiaStyleStr = input.string(
     "Solid",
     "Line Style",
     options = ["Solid", "Dotted", "Dashed"],
     group = grpAS
)

asiaWidth = input.int(
     2,
     "Line Width",
     minval = 1,
     maxval = 4,
     group = grpAS
)

asiaShowPrev = input.bool(
     true,
     "Show Previous Asia Session Levels",
     group = grpAS
)

asiaShowLbl = input.bool(
     true,
     "Show Asia Labels",
     group = grpAS
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LONDON SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

grpLON = "London"

showLON = input.bool(
     true,
     "Show London",
     group = grpLON
)

lonSess = input.session(
     "0300-1100",
     "Session (HHMM-HHMM)",
     group = grpLON
)

lonHCol = input.color(
     color.orange,
     "High Color",
     group = grpLON
)

lonLCol = input.color(
     color.orange,
     "Low Color",
     group = grpLON
)

lonStyleStr = input.string(
     "Solid",
     "Line Style",
     options = ["Solid", "Dotted", "Dashed"],
     group = grpLON
)

lonWidth = input.int(
     2,
     "Line Width",
     minval = 1,
     maxval = 4,
     group = grpLON
)

lonShowPrev = input.bool(
     true,
     "Show Previous London Session Levels",
     group = grpLON
)

lonShowLbl = input.bool(
     true,
     "Show London Labels",
     group = grpLON
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NEW YORK SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

grpNY = "New York"

showNY = input.bool(
     true,
     "Show New York",
     group = grpNY
)

nySess = input.session(
     "0800-1700",
     "Session (HHMM-HHMM)",
     group = grpNY
)

nyHCol = input.color(
     color.red,
     "High Color",
     group = grpNY
)

nyLCol = input.color(
     color.red,
     "Low Color",
     group = grpNY
)

nyStyleStr = input.string(
     "Solid",
     "Line Style",
     options = ["Solid", "Dotted", "Dashed"],
     group = grpNY
)

nyWidth = input.int(
     2,
     "Line Width",
     minval = 1,
     maxval = 4,
     group = grpNY
)

nyShowPrev = input.bool(
     true,
     "Show Previous New York Session Levels",
     group = grpNY
)

nyShowLbl = input.bool(
     true,
     "Show New York Labels",
     group = grpNY
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PREVIOUS COMPLETED SESSION ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_prev_session_block(
     bool enabled,
     string sessionString,
     color highColor,
     color lowColor,
     string styleString,
     int lineWidth,
     string sessionName,
     bool showPrevious,
     bool showSessionLabels
) =>
    // Current developing session values
    var float currentHigh = na
    var float currentLow = na

    // Candles that created the current session extremes
    var int currentHighBar = na
    var int currentLowBar = na

    // Most recently completed session values
    var float previousHigh = na
    var float previousLow = na

    // Candles that created the completed session extremes
    var int previousHighBar = na
    var int previousLowBar = na

    // Drawing objects
    var line previousHighLine = na
    var line previousLowLine = na

    var label previousHighLabel = na
    var label previousLowLabel = na

    rawInSession =
         f_in_session(
             sessionString,
             tz
         )

    previousBarInSession =
         rawInSession[1]

    inSession =
         enabled and rawInSession

    sessionStarted =
         enabled and
         rawInSession and
         not previousBarInSession

    sessionEnded =
         enabled and
         not rawInSession and
         previousBarInSession

    newCalendarDay =
         f_new_calendar_day(tz)

    sessionCompleted = false

    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // ONLY-TODAY RESET
    //
    // Clears completed levels at midnight in the selected timezone.
    // It does not clear an active Sydney or Asia session.
    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    if onlyToday and newCalendarDay
        previousHigh := na
        previousLow := na

        previousHighBar := na
        previousLowBar := na

        if not na(previousHighLine)
            line.delete(previousHighLine)
            previousHighLine := na

        if not na(previousLowLine)
            line.delete(previousLowLine)
            previousLowLine := na

        if not na(previousHighLabel)
            label.delete(previousHighLabel)
            previousHighLabel := na

        if not na(previousLowLabel)
            label.delete(previousLowLabel)
            previousLowLabel := na

    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // ACTIVE SESSION TRACKING
    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    if not enabled
        currentHigh := na
        currentLow := na

        currentHighBar := na
        currentLowBar := na

    if sessionStarted
        currentHigh := high
        currentLow := low

        currentHighBar := bar_index
        currentLowBar := bar_index

    // Safety initialization if the indicator is added while
    // a session is already active.
    if inSession and (
         na(currentHigh) or
         na(currentLow)
    )
        currentHigh := high
        currentLow := low

        currentHighBar := bar_index
        currentLowBar := bar_index

    // Record each new session high and the candle that made it.
    if inSession and (
         na(currentHigh) or
         high > currentHigh
    )
        currentHigh := high
        currentHighBar := bar_index

    // Record each new session low and the candle that made it.
    if inSession and (
         na(currentLow) or
         low < currentLow
    )
        currentLow := low
        currentLowBar := bar_index

    // Finalize the session on the first available bar outside it.
    if sessionEnded and
       not na(currentHigh) and
       not na(currentLow) and
       not na(currentHighBar) and
       not na(currentLowBar)

        previousHigh := currentHigh
        previousLow := currentLow

        previousHighBar := currentHighBar
        previousLowBar := currentLowBar

        currentHigh := na
        currentLow := na

        currentHighBar := na
        currentLowBar := na

        sessionCompleted := true

    // Delete the old drawings when a newer session completes.
    if sessionCompleted
        if not na(previousHighLine)
            line.delete(previousHighLine)
            previousHighLine := na

        if not na(previousLowLine)
            line.delete(previousLowLine)
            previousLowLine := na

        if not na(previousHighLabel)
            label.delete(previousHighLabel)
            previousHighLabel := na

        if not na(previousLowLabel)
            label.delete(previousLowLabel)
            previousLowLabel := na

    shouldDisplay =
         enabled and
         showPrevious and
         not na(previousHigh) and
         not na(previousLow) and
         not na(previousHighBar) and
         not na(previousLowBar)

    selectedLineStyle =
         f_line_style(styleString)

    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // DRAW PREVIOUS SESSION HIGH
    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    if shouldDisplay
        if na(previousHighLine)
            previousHighLine := line.new(
                 x1 = previousHighBar,
                 y1 = previousHigh,
                 x2 = previousHighBar + 1,
                 y2 = previousHigh,
                 xloc = xloc.bar_index,
                 extend = extend.right,
                 color = highColor,
                 style = selectedLineStyle,
                 width = lineWidth
            )
        else
            line.set_x1(
                 previousHighLine,
                 previousHighBar
            )

            line.set_x2(
                 previousHighLine,
                 previousHighBar + 1
            )

            line.set_y1(
                 previousHighLine,
                 previousHigh
            )

            line.set_y2(
                 previousHighLine,
                 previousHigh
            )

            line.set_color(
                 previousHighLine,
                 highColor
            )

            line.set_style(
                 previousHighLine,
                 selectedLineStyle
            )

            line.set_width(
                 previousHighLine,
                 lineWidth
            )

            line.set_extend(
                 previousHighLine,
                 extend.right
            )

        //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // DRAW PREVIOUS SESSION LOW
        //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        if na(previousLowLine)
            previousLowLine := line.new(
                 x1 = previousLowBar,
                 y1 = previousLow,
                 x2 = previousLowBar + 1,
                 y2 = previousLow,
                 xloc = xloc.bar_index,
                 extend = extend.right,
                 color = lowColor,
                 style = selectedLineStyle,
                 width = lineWidth
            )
        else
            line.set_x1(
                 previousLowLine,
                 previousLowBar
            )

            line.set_x2(
                 previousLowLine,
                 previousLowBar + 1
            )

            line.set_y1(
                 previousLowLine,
                 previousLow
            )

            line.set_y2(
                 previousLowLine,
                 previousLow
            )

            line.set_color(
                 previousLowLine,
                 lowColor
            )

            line.set_style(
                 previousLowLine,
                 selectedLineStyle
            )

            line.set_width(
                 previousLowLine,
                 lineWidth
            )

            line.set_extend(
                 previousLowLine,
                 extend.right
            )

        //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // LABELS
        //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        if showSessionLabels and showLabelsGlobal
            sideMultiplier =
                 labelSide == "Right" ? 1 : -1

            currentLabelX =
                 bar_index +
                 sideMultiplier * labelBarsOffset

            highLabelPrice =
                 previousHigh +
                 f_y_offset(true)

            lowLabelPrice =
                 previousLow +
                 f_y_offset(false)

            if na(previousHighLabel)
                previousHighLabel := f_make_label(
                     labelBarsOffset,
                     highLabelPrice,
                     sessionName + " high",
                     highColor
                )
            else
                label.set_xy(
                     previousHighLabel,
                     currentLabelX,
                     highLabelPrice
                )

                label.set_text(
                     previousHighLabel,
                     sessionName + " high"
                )

                label.set_textcolor(
                     previousHighLabel,
                     highColor
                )

                label.set_size(
                     previousHighLabel,
                     lblSize
                )

            if na(previousLowLabel)
                previousLowLabel := f_make_label(
                     labelBarsOffset,
                     lowLabelPrice,
                     sessionName + " low",
                     lowColor
                )
            else
                label.set_xy(
                     previousLowLabel,
                     currentLabelX,
                     lowLabelPrice
                )

                label.set_text(
                     previousLowLabel,
                     sessionName + " low"
                )

                label.set_textcolor(
                     previousLowLabel,
                     lowColor
                )

                label.set_size(
                     previousLowLabel,
                     lblSize
                )

        else
            if not na(previousHighLabel)
                label.delete(previousHighLabel)
                previousHighLabel := na

            if not na(previousLowLabel)
                label.delete(previousLowLabel)
                previousLowLabel := na

    else
        if not na(previousHighLine)
            line.delete(previousHighLine)
            previousHighLine := na

        if not na(previousLowLine)
            line.delete(previousLowLine)
            previousLowLine := na

        if not na(previousHighLabel)
            label.delete(previousHighLabel)
            previousHighLabel := na

        if not na(previousLowLabel)
            label.delete(previousLowLabel)
            previousLowLabel := na

    // Enforces one consistent function return type.
    true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BUILD EACH SESSION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_prev_session_block(
     showSYD,
     sydSess,
     sydHCol,
     sydLCol,
     sydStyleStr,
     sydWidth,
     "sydney",
     sydShowPrev,
     sydShowLbl
)

f_prev_session_block(
     showAS,
     asiaSess,
     asiaHCol,
     asiaLCol,
     asiaStyleStr,
     asiaWidth,
     "asia",
     asiaShowPrev,
     asiaShowLbl
)

f_prev_session_block(
     showLON,
     lonSess,
     lonHCol,
     lonLCol,
     lonStyleStr,
     lonWidth,
     "london",
     lonShowPrev,
     lonShowLbl
)

f_prev_session_block(
     showNY,
     nySess,
     nyHCol,
     nyLCol,
     nyStyleStr,
     nyWidth,
     "new york",
     nyShowPrev,
     nyShowLbl
)
````
