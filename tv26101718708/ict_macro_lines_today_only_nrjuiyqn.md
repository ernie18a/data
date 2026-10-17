# ICT Macro Lines - Today Only

- url: https://www.tradingview.com/script/NRjuIYQN/
- type: indicator
- pine_id: PUB;219c8a2e5bee42bbad85ed424e74b29c
- version: 1.0

## Description

ICT Macro Lines - Today Only is a visual intraday timing tool that marks selected ICT-style macro windows on the current trading day only.

The script draws vertical Start, Mid and End markers for predefined New York session windows, including selected NY Macro windows, the NY AM Silver Bullet window, the Dangerous Lunch Macro, the PM Macro and the Power Hour window.

The purpose of this indicator is to help intraday traders keep important time-based windows visible directly on the chart without manually drawing the same timing lines every day.

This indicator does not generate buy or sell signals. It does not predict direction, measure trend strength, detect entries, or provide automated trade confirmation. It is a chart-organization tool focused only on time structure.

How it works:

The script uses the selected timezone, set by default to America/New_York, and calculates today’s timestamps for each enabled macro window.

For each enabled window, it can draw three vertical markers:

S = Start of the window
M = Middle of the window
E = End of the window

The indicator can optionally hide time markers that have already passed during the current day. This keeps the chart cleaner during live intraday analysis.

It can also display a compact table showing the enabled macro windows and their Start, Mid and End times.

Dangerous Lunch Macro:

The Lunch Macro window from 11:50 to 12:10 New York time is intentionally highlighted in red and labeled as Dangerous Lunch Macro. In this implementation, it is treated as a higher-risk ICT-style timing window. The red color is fixed and cannot be changed in the script settings.

This red highlight is only a visual warning. It is not a buy signal, sell signal, entry confirmation or trade recommendation.

Main features:

- Today-only macro markers based on New York time.
- Optional NY Macro windows.
- Optional NY AM Silver Bullet window.
- Optional Dangerous Lunch Macro window.
- Optional PM Macro and Power Hour window.
- Start / Mid / End vertical line markers.
- Optional line labels: S/M/E, time, or full description.
- Optional subtle background shading for active macro windows.
- Optional macro table with window times.
- Fixed red color for the Dangerous Lunch Macro.
- Customizable line color for all other macro windows.
- Customizable line style, width, text size and table position.
- Designed for intraday charts.

Suggested use:

Use the script on clean intraday charts such as 1-minute, 3-minute, 5-minute or 15-minute charts.

The markers are intended to help traders observe price behavior around specific time windows. Any trading decision should be based on the trader’s own trading model, risk management and market context.

Originality and usefulness:

This script is not a combination of unrelated indicators. Its purpose is to consolidate recurring ICT-style intraday time windows into a clean, configurable, today-only visual layout.

Instead of manually drawing macro timing lines each session, the script automatically places the selected windows using New York time and lets the user control visibility, labels, background shading and the summary table.

Limitations:

- The script is intended for intraday timeframes.
- It is a visual timing reference only.
- It does not provide trade signals.
- It does not determine market bias.
- It does not include backtesting or performance claims.
- It does not predict price direction.
- Time windows are fixed and should be interpreted by the user within their own trading model.

This publication is for educational and chart-organization purposes only.

## Source Code

````pine
//@version=6
indicator("ICT Macro Lines - Today Only", shorttitle = "ICT Macro Lines", overlay = true, max_lines_count = 300, max_labels_count = 200, max_boxes_count = 50)

// =====================================================
// 01. VISIBILITY
// =====================================================
visibilityGroup = "01. Visibility"

showAll = input.bool(true, "Show ICT Macro Lines", group = visibilityGroup)

showMacro0950 = input.bool(true,  "NY Macro 09:50 - 10:10", group = visibilityGroup)
showSBAM      = input.bool(true,  "NY AM Silver Bullet 10:00 - 11:00", group = visibilityGroup)
showMacro1050 = input.bool(true,  "NY Macro 10:50 - 11:10", group = visibilityGroup)
showMacro1150 = input.bool(false, "Dangerous Lunch Macro 11:50 - 12:10", group = visibilityGroup)
showMacro1310 = input.bool(false, "PM Macro 13:10 - 13:40", group = visibilityGroup)
showMacro1515 = input.bool(false, "Power Hour 15:15 - 15:45", group = visibilityGroup)

hidePastLines = input.bool(true, "Hide lines that have already passed today", group = visibilityGroup)


// =====================================================
// 02. LINES
// =====================================================
linesGroup = "02. Lines"

lineColor = input.color(color.new(color.blue, 0), "Line color", group = linesGroup)

lineStyleInput = input.string(
     "Dotted",
     "Line style",
     options = ["Solid", "Dashed", "Dotted"],
     group = linesGroup
)

lineWidth = input.int(1, "Line width", minval = 1, maxval = 5, group = linesGroup)


// =====================================================
// 03. MACRO WINDOW BACKGROUND
// =====================================================
backgroundGroup = "03. Macro window background"

showMacroBackground = input.bool(false, "Show subtle macro background", group = backgroundGroup)
macroBackgroundColor = input.color(color.new(color.blue, 94), "Macro background color", group = backgroundGroup)


// =====================================================
// 04. LINE LABELS
// =====================================================
labelsGroup = "04. Line labels"

labelMode = input.string(
     "None",
     "What to show near the lines",
     options = ["None", "S/M/E", "Time", "Full description"],
     group = labelsGroup
)

labelPosition = input.string(
     "Bottom",
     "Label position",
     options = ["Bottom", "Top"],
     group = labelsGroup
)

labelMargin = input.float(
     1.0,
     "Label margin from price range edge [%]",
     minval = 0.0,
     maxval = 20.0,
     step = 0.5,
     group = labelsGroup
)

labelOffsetMinutes = input.float(
     0.50,
     "Label horizontal offset [minutes]",
     minval = -5.0,
     maxval = 5.0,
     step = 0.25,
     group = labelsGroup
)

textColor = input.color(color.new(color.black, 0), "Text color", group = labelsGroup)

textSizeInput = input.string(
     "Small",
     "Text size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     group = labelsGroup
)

fontInput = input.string(
     "Monospace",
     "Font type",
     options = ["Default", "Monospace"],
     group = labelsGroup
)

priceRangeLookback = input.int(80, "Price range lookback for labels", minval = 20, maxval = 500, group = labelsGroup)


// =====================================================
// 05. MACRO TABLE
// =====================================================
tableGroup = "05. Macro table"

showTable = input.bool(true, "Show macro table", group = tableGroup)

tableSideInput = input.string(
     "Left",
     "Table side",
     options = ["Right", "Left"],
     group = tableGroup
)

tableVerticalInput = input.string(
     "Bottom",
     "Table position",
     options = ["Top", "Bottom"],
     group = tableGroup
)

tableBackgroundColor = input.color(color.new(color.white, 10), "Table background", group = tableGroup)
tableTextColor = input.color(color.new(color.black, 0), "Table text", group = tableGroup)

tableTextSizeInput = input.string(
     "Small",
     "Table text size",
     options = ["Tiny", "Small", "Normal", "Large"],
     group = tableGroup
)


// =====================================================
// 06. TIME
// =====================================================
timeGroup = "06. Time"

macroTimezone = input.string("America/New_York", "ICT Macro timezone", group = timeGroup)


// =====================================================
// FIXED VALUES
// =====================================================
color lunchMacroLineColor = color.new(color.red, 0)
color lunchTableBackground = color.new(color.red, 88)

int tableColumns = 4
int tableRows = 9
int firstBottomSpacerRow = 7
int secondBottomSpacerRow = 8


// =====================================================
// HELPER FUNCTIONS
// =====================================================
f_line_style(string styleInput) =>
    switch styleInput
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        => line.style_dotted


f_size(string sizeInput) =>
    switch sizeInput
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.small


f_font(string fontChoice) =>
    switch fontChoice
        "Monospace" => font.family_monospace
        => font.family_default


f_table_position(string side, string vertical) =>
    if side == "Right" and vertical == "Top"
        position.top_right
    else if side == "Right" and vertical == "Bottom"
        position.bottom_right
    else if side == "Left" and vertical == "Top"
        position.top_left
    else
        position.bottom_left


f_two_digits(int value) =>
    value < 10 ? "0" + str.tostring(value) : str.tostring(value)


f_time_text(int hourValue, int minuteValue) =>
    f_two_digits(hourValue) + ":" + f_two_digits(minuteValue)


f_today_ny_time(int hourValue, int minuteValue) =>
    int yearNY = year(timenow, macroTimezone)
    int monthNY = month(timenow, macroTimezone)
    int dayNY = dayofmonth(timenow, macroTimezone)

    timestamp(macroTimezone, yearNY, monthNY, dayNY, hourValue, minuteValue)


f_current_ny_minute_time() =>
    int yearNY = year(timenow, macroTimezone)
    int monthNY = month(timenow, macroTimezone)
    int dayNY = dayofmonth(timenow, macroTimezone)
    int hourNY = hour(timenow, macroTimezone)
    int minuteNY = minute(timenow, macroTimezone)

    timestamp(macroTimezone, yearNY, monthNY, dayNY, hourNY, minuteNY)


f_label_text(string timeText, string macroName, string phase) =>
    switch labelMode
        "S/M/E"            => phase
        "Time"             => timeText
        "Full description" => timeText + "\n" + macroName + "\n" + phase
        => ""


f_show_element(int elementTime, int currentTime) =>
    not hidePastLines or elementTime >= currentTime


f_show_macro_in_table(int endTime, int currentTime) =>
    not hidePastLines or endTime >= currentTime


// =====================================================
// OBJECTS
// =====================================================
var line[] macroLines = array.new_line()
var label[] macroLabels = array.new_label()
var box[] macroBoxes = array.new_box()

var table macroTable = table.new(f_table_position(tableSideInput, tableVerticalInput), tableColumns, tableRows, border_width = 1)


// =====================================================
// OBJECT CLEANUP
// =====================================================
f_delete_objects() =>
    while array.size(macroLines) > 0
        line.delete(array.pop(macroLines))

    while array.size(macroLabels) > 0
        label.delete(array.pop(macroLabels))

    while array.size(macroBoxes) > 0
        box.delete(array.pop(macroBoxes))


f_clear_table() =>
    for column = 0 to tableColumns - 1
        for row = 0 to tableRows - 1
            table.cell(
                 table_id = macroTable,
                 column = column,
                 row = row,
                 text = "",
                 text_color = color.new(color.white, 100),
                 bgcolor = color.new(color.white, 100),
                 text_size = f_size(tableTextSizeInput),
                 text_font_family = f_font(fontInput)
            )


// =====================================================
// SINGLE LINE MARKER
// =====================================================
f_add_marker(
     int markerTime,
     string timeText,
     string macroName,
     string phase,
     int currentTime,
     float labelY,
     color markerColor
) =>
    if f_show_element(markerTime, currentTime)
        line newLine = line.new(
             x1 = markerTime,
             y1 = close,
             x2 = markerTime,
             y2 = close + syminfo.mintick,
             xloc = xloc.bar_time,
             extend = extend.both,
             color = markerColor,
             style = f_line_style(lineStyleInput),
             width = lineWidth
        )

        array.push(macroLines, newLine)

        string labelText = f_label_text(timeText, macroName, phase)
        int labelOffsetMs = int(labelOffsetMinutes * 60.0 * 1000.0)

        if labelText != ""
            label newLabel = label.new(
                 x = markerTime + labelOffsetMs,
                 y = labelY,
                 text = labelText,
                 xloc = xloc.bar_time,
                 yloc = yloc.price,
                 style = label.style_none,
                 color = color.new(color.white, 100),
                 textcolor = textColor,
                 size = f_size(textSizeInput),
                 textalign = text.align_center,
                 text_font_family = f_font(fontInput)
            )

            array.push(macroLabels, newLabel)


// =====================================================
// MACRO WINDOW BACKGROUND
// =====================================================
f_add_macro_background(int startTime, int endTime, int currentTime, float topPrice, float bottomPrice) =>
    bool showBackground = showMacroBackground and (not hidePastLines or endTime >= currentTime)

    if showBackground
        int leftEdge = hidePastLines ? math.max(startTime, currentTime) : startTime

        box newBox = box.new(
             left = leftEdge,
             top = topPrice,
             right = endTime,
             bottom = bottomPrice,
             xloc = xloc.bar_time,
             bgcolor = macroBackgroundColor,
             border_color = color.new(color.white, 100),
             border_width = 0
        )

        array.push(macroBoxes, newBox)


// =====================================================
// FULL MACRO WINDOW
// =====================================================
f_add_macro(
     int startH,
     int startM,
     int midH,
     int midM,
     int endH,
     int endM,
     string macroName,
     int currentTime,
     float labelY,
     float zoneTop,
     float zoneBottom,
     color macroLineColor
) =>
    int startTime = f_today_ny_time(startH, startM)
    int midTime = f_today_ny_time(midH, midM)
    int endTime = f_today_ny_time(endH, endM)

    string startText = f_time_text(startH, startM)
    string midText = f_time_text(midH, midM)
    string endText = f_time_text(endH, endM)

    f_add_macro_background(startTime, endTime, currentTime, zoneTop, zoneBottom)

    f_add_marker(startTime, startText, macroName, "S", currentTime, labelY, macroLineColor)
    f_add_marker(midTime,   midText,   macroName, "M", currentTime, labelY, macroLineColor)
    f_add_marker(endTime,   endText,   macroName, "E", currentTime, labelY, macroLineColor)


// =====================================================
// MACRO TABLE
// =====================================================
f_table_cell(int column, int row, string textValue, color backgroundColor) =>
    table.cell(
         table_id = macroTable,
         column = column,
         row = row,
         text = textValue,
         text_color = tableTextColor,
         text_size = f_size(tableTextSizeInput),
         bgcolor = backgroundColor,
         text_font_family = f_font(fontInput)
    )


f_table_row(int row, string macroName, string startText, string midText, string endText, color rowBackgroundColor) =>
    f_table_cell(0, row, macroName, rowBackgroundColor)
    f_table_cell(1, row, startText, rowBackgroundColor)
    f_table_cell(2, row, midText, rowBackgroundColor)
    f_table_cell(3, row, endText, rowBackgroundColor)


f_table_bottom_spacer(int row) =>
    for column = 0 to tableColumns - 1
        table.cell(
             table_id = macroTable,
             column = column,
             row = row,
             text = " ",
             text_color = color.new(color.white, 100),
             text_size = f_size(tableTextSizeInput),
             bgcolor = color.new(color.white, 100),
             text_font_family = f_font(fontInput)
        )


// =====================================================
// PRICE RANGE FOR LABEL POSITION
// =====================================================
float rawHighestRange = ta.highest(high, priceRangeLookback)
float rawLowestRange = ta.lowest(low, priceRangeLookback)

float highestRange = na(rawHighestRange) ? high : rawHighestRange
float lowestRange = na(rawLowestRange) ? low : rawLowestRange

float priceRange = math.max(highestRange - lowestRange, syminfo.mintick)

float labelY = labelPosition == "Bottom"
     ? lowestRange + priceRange * labelMargin / 100.0
     : highestRange - priceRange * labelMargin / 100.0

float zoneTop = highestRange
float zoneBottom = lowestRange


// =====================================================
// MAIN LOGIC — TODAY ONLY, NEW YORK TIME
// =====================================================
if barstate.islast
    f_delete_objects()
    f_clear_table()

    if showAll and timeframe.isintraday
        int currentTime = f_current_ny_minute_time()

        if showMacro0950
            f_add_macro(9, 50, 10, 0, 10, 10, "NY Macro", currentTime, labelY, zoneTop, zoneBottom, lineColor)

        if showSBAM
            f_add_macro(10, 0, 10, 30, 11, 0, "NY AM Silver Bullet", currentTime, labelY, zoneTop, zoneBottom, lineColor)

        if showMacro1050
            f_add_macro(10, 50, 11, 0, 11, 10, "NY Macro", currentTime, labelY, zoneTop, zoneBottom, lineColor)

        if showMacro1150
            f_add_macro(11, 50, 12, 0, 12, 10, "Dangerous Lunch Macro", currentTime, labelY, zoneTop, zoneBottom, lunchMacroLineColor)

        if showMacro1310
            f_add_macro(13, 10, 13, 25, 13, 40, "PM Macro", currentTime, labelY, zoneTop, zoneBottom, lineColor)

        if showMacro1515
            f_add_macro(15, 15, 15, 30, 15, 45, "Power Hour", currentTime, labelY, zoneTop, zoneBottom, lineColor)

        if showTable
            color headerBackground = color.new(tableBackgroundColor, 0)

            f_table_cell(0, 0, "ICT Macro", headerBackground)
            f_table_cell(1, 0, "Start", headerBackground)
            f_table_cell(2, 0, "Mid", headerBackground)
            f_table_cell(3, 0, "End", headerBackground)

            int row = 1

            if showMacro0950 and f_show_macro_in_table(f_today_ny_time(10, 10), currentTime)
                f_table_row(row, "NY", "09:50", "10:00", "10:10", tableBackgroundColor)
                row += 1

            if showSBAM and f_show_macro_in_table(f_today_ny_time(11, 0), currentTime)
                f_table_row(row, "NY AM SB", "10:00", "10:30", "11:00", tableBackgroundColor)
                row += 1

            if showMacro1050 and f_show_macro_in_table(f_today_ny_time(11, 10), currentTime)
                f_table_row(row, "NY", "10:50", "11:00", "11:10", tableBackgroundColor)
                row += 1

            if showMacro1150 and f_show_macro_in_table(f_today_ny_time(12, 10), currentTime)
                f_table_row(row, "Danger Lunch", "11:50", "12:00", "12:10", lunchTableBackground)
                row += 1

            if showMacro1310 and f_show_macro_in_table(f_today_ny_time(13, 40), currentTime)
                f_table_row(row, "PM", "13:10", "13:25", "13:40", tableBackgroundColor)
                row += 1

            if showMacro1515 and f_show_macro_in_table(f_today_ny_time(15, 45), currentTime)
                f_table_row(row, "Power", "15:15", "15:30", "15:45", tableBackgroundColor)
                row += 1

            f_table_bottom_spacer(firstBottomSpacerRow)
            f_table_bottom_spacer(secondBottomSpacerRow)
````
