# CME Trading Day Separator

- url: https://www.tradingview.com/script/ao1JatCV-CME-Trading-Day-Separator/
- type: indicator
- pine_id: PUB;cbcc725a85ad4842879a34146a9dae02
- version: 1.0

## Description

CME Trading Day Separator helps visualize the start of each CME trading day by drawing clean vertical dashed separator lines on intraday charts.

By default, the indicator uses the official CME futures session rollover at 18:00 New York time (America/New_York), automatically handling Daylight Saving Time (DST). This makes it ideal for traders analyzing Nasdaq (NQ), S&P 500 (ES), Gold (GC), Crude Oil (CL), and other CME futures.

Features:
📅 Draws a vertical dashed line at the beginning of every CME trading day.
🕕 Default session start at 18:00 New York time, fully customizable.
🌎 Uses the America/New_York timezone to automatically adjust for DST.
🎨 Customize line color and line width.
🗓️ Optionally display weekday labels.
🔤 Choose between short (Mon, Tue, Wed...) or full (Monday, Tuesday...) weekday names.
📉 Option to display only Monday–Friday trading days.
⚡ Lightweight and optimized for intraday trading.

This indicator is designed to provide a clean visual separation between trading days without cluttering your charts, making session analysis, ICT concepts, and daily market structure significantly easier.

## Source Code

````pine
//@version=6
indicator(
     title            = "CME Trading Day Separator",
     shorttitle       = "CME Day Separator",
     overlay          = true,
     max_lines_count  = 500,
     max_labels_count = 500
)

// ─────────────────────────────────────────────────────────────────────────────
// Trading day start
// ─────────────────────────────────────────────────────────────────────────────

string timeZone = "America/New_York"

groupTime = "Trading Day Start"

startHour = input.int(
     defval  = 18,
     title   = "Hour",
     minval  = 0,
     maxval  = 23,
     group   = groupTime,
     tooltip = "Trading day start hour in New York time."
)

startMinute = input.int(
     defval  = 0,
     title   = "Minute",
     minval  = 0,
     maxval  = 59,
     group   = groupTime,
     tooltip = "The default CME trading day starts at 18:00 New York time."
)

// ─────────────────────────────────────────────────────────────────────────────
// Line settings
// ─────────────────────────────────────────────────────────────────────────────

groupLines = "Separator Lines"

lineColor = input.color(
     defval = color.new(color.gray, 50),
     title  = "Line Color",
     group  = groupLines
)

lineWidth = input.int(
     defval = 1,
     title  = "Line Width",
     minval = 1,
     maxval = 4,
     group  = groupLines
)

weekdaysOnly = input.bool(
     defval  = true,
     title   = "Weekdays Only",
     group   = groupLines,
     tooltip = "Only draws separators for Monday through Friday trading days."
)

maxSeparators = input.int(
     defval  = 250,
     title   = "Maximum Separators",
     minval  = 20,
     maxval  = 450,
     group   = groupLines,
     tooltip = "Older separator lines and labels are deleted automatically."
)

// ─────────────────────────────────────────────────────────────────────────────
// Weekday label settings
// ─────────────────────────────────────────────────────────────────────────────

groupLabels = "Weekday Labels"

showDayNames = input.bool(
     defval = false,
     title  = "Show Weekday Names",
     group  = groupLabels
)

dayNameFormat = input.string(
     defval  = "Short",
     title   = "Name Format",
     options = ["Short", "Full"],
     group   = groupLabels
)

dayNameColor = input.color(
     defval = color.new(color.gray, 40),
     title  = "Text Color",
     group  = groupLabels
)

dayNameSize = input.string(
     defval  = "Tiny",
     title   = "Text Size",
     options = ["Tiny", "Small", "Normal"],
     group   = groupLabels
)

// ─────────────────────────────────────────────────────────────────────────────
// Helper functions
// ─────────────────────────────────────────────────────────────────────────────

getTradingDayOfWeek(int startTimestamp) =>
    // The CME trading day beginning Sunday at 18:00 belongs to Monday.
    // Adding six hours moves the timestamp into the following calendar day.
    dayofweek(startTimestamp + 6 * 60 * 60 * 1000, timeZone)

getDayName(int tradingDay, string nameFormat) =>
    bool useShortName = nameFormat == "Short"

    switch tradingDay
        dayofweek.monday =>
            useShortName ? "Mon" : "Monday"

        dayofweek.tuesday =>
            useShortName ? "Tue" : "Tuesday"

        dayofweek.wednesday =>
            useShortName ? "Wed" : "Wednesday"

        dayofweek.thursday =>
            useShortName ? "Thu" : "Thursday"

        dayofweek.friday =>
            useShortName ? "Fri" : "Friday"

        dayofweek.saturday =>
            useShortName ? "Sat" : "Saturday"

        dayofweek.sunday =>
            useShortName ? "Sun" : "Sunday"

        => ""

getTextSize(string selectedSize) =>
    switch selectedSize
        "Small"  => size.small
        "Normal" => size.normal
        => size.tiny

isWeekday(int tradingDay) =>
    tradingDay >= dayofweek.monday and tradingDay <= dayofweek.friday

// ─────────────────────────────────────────────────────────────────────────────
// Calculate current CME trading-day start
// ─────────────────────────────────────────────────────────────────────────────

int currentYear  = year(time, timeZone)
int currentMonth = month(time, timeZone)
int currentDay   = dayofmonth(time, timeZone)

int todayStart = timestamp(
     timeZone,
     currentYear,
     currentMonth,
     currentDay,
     startHour,
     startMinute
)

// Bars before the configured start time still belong to the trading day
// that began on the previous calendar date.
int tradingDayStart = time >= todayStart
     ? todayStart
     : timestamp(
         timeZone,
         currentYear,
         currentMonth,
         currentDay - 1,
         startHour,
         startMinute
     )

bool newTradingDay = not na(tradingDayStart[1]) and
                     tradingDayStart != tradingDayStart[1]

// ─────────────────────────────────────────────────────────────────────────────
// Store drawings
// ─────────────────────────────────────────────────────────────────────────────

var array<line> separatorLines = array.new_line()
var array<label> weekdayLabels = array.new_label()

// ─────────────────────────────────────────────────────────────────────────────
// Draw separators
// ─────────────────────────────────────────────────────────────────────────────

if timeframe.isintraday and newTradingDay
    int tradingDay = getTradingDayOfWeek(tradingDayStart)

    bool validTradingDay = not weekdaysOnly or isWeekday(tradingDay)

    if validTradingDay
        line separator = line.new(
             x1     = tradingDayStart,
             y1     = low,
             x2     = tradingDayStart,
             y2     = high,
             xloc   = xloc.bar_time,
             extend = extend.both,
             color  = lineColor,
             style  = line.style_dashed,
             width  = lineWidth
        )

        array.push(separatorLines, separator)

        if showDayNames
            string weekdayName = getDayName(
                 tradingDay,
                 dayNameFormat
            )

            label weekdayLabel = label.new(
                 x         = tradingDayStart,
                 y         = low,
                 text      = weekdayName,
                 xloc      = xloc.bar_time,
                 yloc      = yloc.belowbar,
                 style     = label.style_none,
                 textcolor = dayNameColor,
                 size      = getTextSize(dayNameSize),
                 textalign = text.align_center
            )

            array.push(weekdayLabels, weekdayLabel)

// ─────────────────────────────────────────────────────────────────────────────
// Delete older drawings
// ─────────────────────────────────────────────────────────────────────────────

while array.size(separatorLines) > maxSeparators
    line.delete(array.shift(separatorLines))

while array.size(weekdayLabels) > maxSeparators
    label.delete(array.shift(weekdayLabels))
````
