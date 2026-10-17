# ClickDrag Gann Dates

- url: https://www.tradingview.com/script/NSmhkjmK-ClickDrag-Gann-Dates/
- type: indicator
- pine_id: PUB;a4cae7f6455042cab473fe65b062ef3a
- version: 1.0

## Description

Plots a selected start date, fixed annual calendar dates, calendar-day counts, and trading-day counts as vertical chart lines. The date calculations use the New York time zone and a built-in weekday and market-holiday schedule for trading-day counts. Click the handle to move the Start date.

This overlay marks calendar dates measured from a user-selected start date. It draws a vertical line for the start date and, when enabled, lines for selected annual dates, calendar-day counts, and trading-day counts. Labels identify the start date or the corresponding date/count category.

Date calculations
The Start Date input sets the anchor calendar date, interpreted in the America/New_York time zone. The start date is labeled “Start” when its label is enabled.

Annual Dates marks the next occurrence on or after the start date of four fixed month-and-day dates: December 22, March 21, June 22, and September 21. These are fixed calendar dates; they are not calculated from astronomical events.

Calendar Days marks 30, 45, 60, 90, 135, 150, 180, 210, 225, 315, 330, and 360 days. The start date is counted as day 1, so an “N D” line is placed N minus 1 calendar days after the start date.

Trading Days marks counts of 11, 22, 33, 45, 56, 67, 78, 90, 101, 112, 123, 135, 146, 157, 168, and 180. The start date is the measurement anchor, or trading day 0. Counting begins with the next calendar date and includes dates that the script classifies as trading days.

The trading-day schedule excludes weekends and applies coded rules for New Year’s Day, Martin Luther King Jr. Day, Washington’s Birthday, Good Friday, Memorial Day, Juneteenth beginning in 2022, Independence Day, Labor Day, Thanksgiving, and Christmas. It also excludes December 5, 2018, and January 9, 2025, as full-day closures.

Inputs and appearance
Annual dates, calendar-day counts, and trading-day counts can each be shown or hidden. For the start-date line and each date category, settings control line color, opacity, thickness, and style. Labels can be shown or hidden; their background color and text size are adjustable.

Lines span the price range accumulated from chart bars on or after the selected start date. Labels are positioned at different levels within that range to separate the categories: start and calendar-day labels near the top, annual-date labels about one-third of the way up from the bottom, and trading-day labels near the bottom.

Usage Notes and Limitations
Trading-day counts use the script’s built-in calendar, not a live exchange schedule. The rules do not account for early closes or every possible exceptional closure, and the calendar may not match the trading schedule of instruments outside the U.S. market context.

The script scans at most 500 calendar dates when locating trading-day markers. Its displayed price range depends on the chart data available from the selected start date onward.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
// © triplej333

//@version=6
indicator(
     "ClickDrag Gann Dates",
     overlay = true,
     max_lines_count = 100,
     max_labels_count = 100
)

// ============================================================================
// Constants
// ============================================================================

string MARKET_TZ = "America/New_York"
int MAX_TRADING_SCAN_DAYS = 500

string GROUP_START     = "Start Date"
string GROUP_ANNUAL_DATES = "Annual Dates"
string GROUP_CALENDAR_DAYS = "Calendar Days"
string GROUP_TRADING_DAYS = "Trading Days"

string STYLE_SOLID       = "Solid"
string STYLE_DASHED      = "Dashed"
string STYLE_DOTTED      = "Dotted"
string STYLE_ARROW_LEFT  = "Arrow Left"
string STYLE_ARROW_RIGHT = "Arrow Right"
string STYLE_ARROW_BOTH  = "Arrow Both"

string LABEL_SIZE_AUTO   = "Auto"
string LABEL_SIZE_TINY   = "Tiny"
string LABEL_SIZE_SMALL  = "Small"
string LABEL_SIZE_NORMAL = "Normal"
string LABEL_SIZE_LARGE  = "Large"
string LABEL_SIZE_HUGE   = "Huge"

// ============================================================================
// Inputs
// ============================================================================

// ----------------------------------------------------------------------------
// Start-date inputs
// ----------------------------------------------------------------------------

int startDateInput = input.time(
     timestamp("26 Sep 2026 00:00 -0400"),
     "Start Date",
     group = GROUP_START,
     display = display.none
)

color startColorInput = input.color(
     color.black,
     "Line color",
     inline = "startLine",
     group = GROUP_START,
     display = display.none
)

int startOpacityInput = input.int(
     100,
     "Opacity %",
     minval = 0,
     maxval = 100,
     inline = "startLine",
     group = GROUP_START,
     display = display.none
)

int startWidthInput = input.int(
     2,
     "Thickness",
     minval = 1,
     maxval = 10,
     inline = "startLine",
     group = GROUP_START,
     display = display.none
)

string startStyleInput = input.string(
     STYLE_SOLID,
     "Line style",
     options = [
         STYLE_SOLID,
         STYLE_DASHED,
         STYLE_DOTTED,
         STYLE_ARROW_LEFT,
         STYLE_ARROW_RIGHT,
         STYLE_ARROW_BOTH
     ],
     inline = "startStyle",
     group = GROUP_START,
     display = display.none
)

bool showStartLabels = input.bool(
     true,
     "Show labels",
     inline = "startLabel",
     group = GROUP_START,
     display = display.none
)

color startLabelBackgroundInput = input.color(
     color.white,
     "Background",
     inline = "startLabel",
     group = GROUP_START,
     display = display.none
)

string startLabelSizeInput = input.string(
     LABEL_SIZE_SMALL,
     "Text size",
     options = [
         LABEL_SIZE_AUTO,
         LABEL_SIZE_TINY,
         LABEL_SIZE_SMALL,
         LABEL_SIZE_NORMAL,
         LABEL_SIZE_LARGE,
         LABEL_SIZE_HUGE
     ],
     inline = "startLabel",
     group = GROUP_START,
     display = display.none
)

// ----------------------------------------------------------------------------
// Annual-date inputs
// ----------------------------------------------------------------------------

bool includeAnnualDates = input.bool(
     true,
     "Show annual dates",
     tooltip = "Include significant dates in the annual cycle.",
     group = GROUP_ANNUAL_DATES,
     display = display.none
)

color annualColorInput = input.color(
     color.blue,
     "Line color",
     inline = "annualLine",
     group = GROUP_ANNUAL_DATES,
     display = display.none
)

int annualOpacityInput = input.int(
     100,
     "Opacity %",
     minval = 0,
     maxval = 100,
     inline = "annualLine",
     group = GROUP_ANNUAL_DATES,
     display = display.none
)

int annualWidthInput = input.int(
     1,
     "Thickness",
     minval = 1,
     maxval = 10,
     inline = "annualLine",
     group = GROUP_ANNUAL_DATES,
     display = display.none
)

string annualStyleInput = input.string(
     STYLE_DOTTED,
     "Line style",
     options = [
         STYLE_SOLID,
         STYLE_DASHED,
         STYLE_DOTTED,
         STYLE_ARROW_LEFT,
         STYLE_ARROW_RIGHT,
         STYLE_ARROW_BOTH
     ],
     inline = "annualStyle",
     group = GROUP_ANNUAL_DATES,
     display = display.none
)

bool showAnnualDateLabels = input.bool(
     true,
     "Show labels",
     inline = "annualLabel",
     group = GROUP_ANNUAL_DATES,
     display = display.none
)

color annualLabelBackgroundInput = input.color(
     color.white,
     "Background",
     inline = "annualLabel",
     group = GROUP_ANNUAL_DATES,
     display = display.none
)

string annualLabelSizeInput = input.string(
     LABEL_SIZE_SMALL,
     "Text size",
     options = [
         LABEL_SIZE_AUTO,
         LABEL_SIZE_TINY,
         LABEL_SIZE_SMALL,
         LABEL_SIZE_NORMAL,
         LABEL_SIZE_LARGE,
         LABEL_SIZE_HUGE
     ],
     inline = "annualLabel",
     group = GROUP_ANNUAL_DATES,
     display = display.none
)

// ----------------------------------------------------------------------------
// Calendar-day inputs
// ----------------------------------------------------------------------------

bool includeCalendarDays = input.bool(
     true,
     "Show calendar days",
     tooltip = "Include Gann calendar-day counts.",
     group = GROUP_CALENDAR_DAYS,
     display = display.none
)

color calendarDayColorInput = input.color(
     color.red,
     "Line color",
     inline = "calendarDayLine",
     group = GROUP_CALENDAR_DAYS,
     display = display.none
)

int calendarDayOpacityInput = input.int(
     100,
     "Opacity %",
     minval = 0,
     maxval = 100,
     inline = "calendarDayLine",
     group = GROUP_CALENDAR_DAYS,
     display = display.none
)

int calendarDayWidthInput = input.int(
     1,
     "Thickness",
     minval = 1,
     maxval = 10,
     inline = "calendarDayLine",
     group = GROUP_CALENDAR_DAYS,
     display = display.none
)

string calendarDayStyleInput = input.string(
     STYLE_DASHED,
     "Line style",
     options = [
         STYLE_SOLID,
         STYLE_DASHED,
         STYLE_DOTTED,
         STYLE_ARROW_LEFT,
         STYLE_ARROW_RIGHT,
         STYLE_ARROW_BOTH
     ],
     inline = "calendarDayStyle",
     group = GROUP_CALENDAR_DAYS,
     display = display.none
)

bool showCalendarDayLabels = input.bool(
     true,
     "Show labels",
     inline = "calendarDayLabel",
     group = GROUP_CALENDAR_DAYS,
     display = display.none
)

color calendarDayLabelBackgroundInput = input.color(
     color.white,
     "Background",
     inline = "calendarDayLabel",
     group = GROUP_CALENDAR_DAYS,
     display = display.none
)

string calendarDayLabelSizeInput = input.string(
     LABEL_SIZE_SMALL,
     "Text size",
     options = [
         LABEL_SIZE_AUTO,
         LABEL_SIZE_TINY,
         LABEL_SIZE_SMALL,
         LABEL_SIZE_NORMAL,
         LABEL_SIZE_LARGE,
         LABEL_SIZE_HUGE
     ],
     inline = "calendarDayLabel",
     group = GROUP_CALENDAR_DAYS,
     display = display.none
)

// ----------------------------------------------------------------------------
// Trading-day inputs
// ----------------------------------------------------------------------------

bool includeTradingDays = input.bool(
     true,
     "Show trading days",
     tooltip = "Include Gann trading-day counts using the NYSE holiday calendar.",
     group = GROUP_TRADING_DAYS,
     display = display.none
)

color tradingDaysColorInput = input.color(
     color.green,
     "Line color",
     inline = "tradingDaysLine",
     group = GROUP_TRADING_DAYS,
     display = display.none
)

int tradingDaysOpacityInput = input.int(
     100,
     "Opacity %",
     minval = 0,
     maxval = 100,
     inline = "tradingDaysLine",
     group = GROUP_TRADING_DAYS,
     display = display.none
)

int tradingDaysWidthInput = input.int(
     1,
     "Thickness",
     minval = 1,
     maxval = 10,
     inline = "tradingDaysLine",
     group = GROUP_TRADING_DAYS,
     display = display.none
)

string tradingDaysStyleInput = input.string(
     STYLE_DASHED,
     "Line style",
     options = [
         STYLE_SOLID,
         STYLE_DASHED,
         STYLE_DOTTED,
         STYLE_ARROW_LEFT,
         STYLE_ARROW_RIGHT,
         STYLE_ARROW_BOTH
     ],
     inline = "tradingDaysStyle",
     group = GROUP_TRADING_DAYS,
     display = display.none
)

bool showTradingDayLabels = input.bool(
     true,
     "Show labels",
     inline = "tradingDaysLabel",
     group = GROUP_TRADING_DAYS,
     display = display.none
)

color tradingDaysLabelBackgroundInput = input.color(
     color.white,
     "Background",
     inline = "tradingDaysLabel",
     group = GROUP_TRADING_DAYS,
     display = display.none
)

string tradingDaysLabelSizeInput = input.string(
     LABEL_SIZE_SMALL,
     "Text size",
     options = [
         LABEL_SIZE_AUTO,
         LABEL_SIZE_TINY,
         LABEL_SIZE_SMALL,
         LABEL_SIZE_NORMAL,
         LABEL_SIZE_LARGE,
         LABEL_SIZE_HUGE
     ],
     inline = "tradingDaysLabel",
     group = GROUP_TRADING_DAYS,
     display = display.none
)

// ============================================================================
// Style helpers
// ============================================================================

lineStyleFrom(string styleName) =>
    switch styleName
        STYLE_DASHED      => line.style_dashed
        STYLE_DOTTED      => line.style_dotted
        STYLE_ARROW_LEFT  => line.style_arrow_left
        STYLE_ARROW_RIGHT => line.style_arrow_right
        STYLE_ARROW_BOTH  => line.style_arrow_both
        => line.style_solid

labelSizeFrom(string sizeName) =>
    switch sizeName
        LABEL_SIZE_AUTO   => size.auto
        LABEL_SIZE_TINY   => size.tiny
        LABEL_SIZE_NORMAL => size.normal
        LABEL_SIZE_LARGE  => size.large
        LABEL_SIZE_HUGE   => size.huge
        => size.small

applyOpacity(color baseColor, int opacityPercent) =>
    float pickerTransparency = color.t(baseColor)

    float visibleColorPercent =
         (100.0 - pickerTransparency) * opacityPercent / 100.0

    int finalTransparency = int(
         math.round(100.0 - visibleColorPercent)
    )

    color.new(baseColor, finalTransparency)

// Converted line styles.
startLineStyle = lineStyleFrom(startStyleInput)
annualLineStyle = lineStyleFrom(annualStyleInput)
calendarDayLineStyle = lineStyleFrom(calendarDayStyleInput)
tradingDaysLineStyle = lineStyleFrom(tradingDaysStyleInput)

// Converted label sizes.
startLabelSize = labelSizeFrom(startLabelSizeInput)
annualLabelSize = labelSizeFrom(annualLabelSizeInput)
calendarDayLabelSize = labelSizeFrom(calendarDayLabelSizeInput)
tradingDaysLabelSize = labelSizeFrom(tradingDaysLabelSizeInput)

// Colors with opacity applied.
startColor = applyOpacity(startColorInput, startOpacityInput)
annualColor = applyOpacity(annualColorInput, annualOpacityInput)
calendarDayColor = applyOpacity(calendarDayColorInput, calendarDayOpacityInput)
tradingDaysColor = applyOpacity(tradingDaysColorInput, tradingDaysOpacityInput)

// ============================================================================
// Calendar helpers
// ============================================================================

dateTimestamp(int yearNumber, int monthNumber, int dayNumber) =>
    timestamp(
         MARKET_TZ,
         yearNumber,
         monthNumber,
         dayNumber,
         0,
         0,
         0
    )

isLeapYear(int yearNumber) =>
    yearNumber % 400 == 0 or
     (yearNumber % 4 == 0 and yearNumber % 100 != 0)

daysInMonth(int yearNumber, int monthNumber) =>
    int result = switch monthNumber
        2  => isLeapYear(yearNumber) ? 29 : 28
        4  => 30
        6  => 30
        9  => 30
        11 => 30
        => 31

    result

nextCalendarDate(int yearNumber, int monthNumber, int dayNumber) =>
    int nextYear = yearNumber
    int nextMonth = monthNumber
    int nextDay = dayNumber + 1

    if nextDay > daysInMonth(nextYear, nextMonth)
        nextDay := 1
        nextMonth := nextMonth + 1

        if nextMonth > 12
            nextMonth := 1
            nextYear := nextYear + 1

    [nextYear, nextMonth, nextDay]

previousCalendarDate(int yearNumber, int monthNumber, int dayNumber) =>
    int previousYear = yearNumber
    int previousMonth = monthNumber
    int previousDay = dayNumber - 1

    if previousDay < 1
        previousMonth := previousMonth - 1

        if previousMonth < 1
            previousMonth := 12
            previousYear := previousYear - 1

        previousDay := daysInMonth(previousYear, previousMonth)

    [previousYear, previousMonth, previousDay]

addCalendarDays(int baseTimestamp, int numberOfDays) =>
    int resultYear = year(baseTimestamp, MARKET_TZ)
    int resultMonth = month(baseTimestamp, MARKET_TZ)
    int resultDay = dayofmonth(baseTimestamp, MARKET_TZ)

    int daysToMove = math.abs(numberOfDays)

    if daysToMove > 0
        for dayIndex = 1 to daysToMove
            if numberOfDays > 0
                [nextYear, nextMonth, nextDay] = nextCalendarDate(
                     resultYear,
                     resultMonth,
                     resultDay
                )

                resultYear := nextYear
                resultMonth := nextMonth
                resultDay := nextDay
            else
                [previousYear, previousMonth, previousDay] =
                     previousCalendarDate(
                         resultYear,
                         resultMonth,
                         resultDay
                     )

                resultYear := previousYear
                resultMonth := previousMonth
                resultDay := previousDay

    dateTimestamp(resultYear, resultMonth, resultDay)

nthWeekdayOfMonth(
     int yearNumber,
     int monthNumber,
     int targetWeekday,
     int occurrence
) =>
    int firstDayTimestamp = dateTimestamp(
         yearNumber,
         monthNumber,
         1
    )

    int firstWeekday = dayofweek(
         firstDayTimestamp,
         MARKET_TZ
    )

    int weekdayOffset =
         (targetWeekday - firstWeekday + 7) % 7

    1 + weekdayOffset + 7 * (occurrence - 1)

lastWeekdayOfMonth(
     int yearNumber,
     int monthNumber,
     int targetWeekday
) =>
    int finalDay = daysInMonth(yearNumber, monthNumber)

    int finalDayTimestamp = dateTimestamp(
         yearNumber,
         monthNumber,
         finalDay
    )

    int finalWeekday = dayofweek(
         finalDayTimestamp,
         MARKET_TZ
    )

    int weekdayOffset =
         (finalWeekday - targetWeekday + 7) % 7

    finalDay - weekdayOffset

// Gregorian Easter Sunday calculation.
easterSunday(int yearNumber) =>
    int a = yearNumber % 19
    int b = int(math.floor(yearNumber / 100))
    int c = yearNumber % 100
    int d = int(math.floor(b / 4))
    int e = b % 4
    int f = int(math.floor((b + 8) / 25))
    int g = int(math.floor((b - f + 1) / 3))
    int h = (19 * a + b - d - g + 15) % 30
    int i = int(math.floor(c / 4))
    int k = c % 4
    int l = (32 + 2 * e + 2 * i - h - k) % 7
    int m = int(math.floor((a + 11 * h + 22 * l) / 451))

    int easterMonth =
         int(math.floor((h + l - 7 * m + 114) / 31))

    int easterDay =
         ((h + l - 7 * m + 114) % 31) + 1

    dateTimestamp(
         yearNumber,
         easterMonth,
         easterDay
    )

// ============================================================================
// Market holiday helpers
// ============================================================================

isObservedFixedHoliday(
     int testTimestamp,
     int yearNumber,
     int holidayMonth,
     int holidayDay,
     bool observeSaturday
) =>
    int holidayTimestamp = dateTimestamp(
         yearNumber,
         holidayMonth,
         holidayDay
    )

    int holidayWeekday = dayofweek(
         holidayTimestamp,
         MARKET_TZ
    )

    bool result = testTimestamp == holidayTimestamp

    // NYSE generally observes Saturday holidays on Friday for most
    // fixed-date holidays, except where a specific exchange rule differs.
    if holidayWeekday == dayofweek.saturday and observeSaturday
        int observedTimestamp = dateTimestamp(
             yearNumber,
             holidayMonth,
             holidayDay - 1
        )

        result := result or testTimestamp == observedTimestamp

    if holidayWeekday == dayofweek.sunday
        int observedTimestamp = dateTimestamp(
             yearNumber,
             holidayMonth,
             holidayDay + 1
        )

        result := result or testTimestamp == observedTimestamp

    result

isRegularMarketHoliday(int testTimestamp) =>
    int testYear = year(
         testTimestamp,
         MARKET_TZ
    )

    bool newYearsDay = isObservedFixedHoliday(
         testTimestamp,
         testYear,
         1,
         1,
         false
    )

    bool juneteenth =
         testYear >= 2022 and
         isObservedFixedHoliday(
             testTimestamp,
             testYear,
             6,
             19,
             true
         )

    bool independenceDay = isObservedFixedHoliday(
         testTimestamp,
         testYear,
         7,
         4,
         true
    )

    bool christmasDay = isObservedFixedHoliday(
         testTimestamp,
         testYear,
         12,
         25,
         true
    )

    int martinLutherKingDay = dateTimestamp(
         testYear,
         1,
         nthWeekdayOfMonth(
             testYear,
             1,
             dayofweek.monday,
             3
         )
    )

    int washingtonBirthday = dateTimestamp(
         testYear,
         2,
         nthWeekdayOfMonth(
             testYear,
             2,
             dayofweek.monday,
             3
         )
    )

    int memorialDay = dateTimestamp(
         testYear,
         5,
         lastWeekdayOfMonth(
             testYear,
             5,
             dayofweek.monday
         )
    )

    int laborDay = dateTimestamp(
         testYear,
         9,
         nthWeekdayOfMonth(
             testYear,
             9,
             dayofweek.monday,
             1
         )
    )

    int thanksgivingDay = dateTimestamp(
         testYear,
         11,
         nthWeekdayOfMonth(
             testYear,
             11,
             dayofweek.thursday,
             4
         )
    )

    int goodFriday = addCalendarDays(
         easterSunday(testYear),
         -2
    )

    newYearsDay or
     testTimestamp == martinLutherKingDay or
     testTimestamp == washingtonBirthday or
     testTimestamp == goodFriday or
     testTimestamp == memorialDay or
     juneteenth or
     independenceDay or
     testTimestamp == laborDay or
     testTimestamp == thanksgivingDay or
     christmasDay

// Extraordinary full-day closures.
isExtraordinaryMarketClosure(int testTimestamp) =>
    testTimestamp == dateTimestamp(2018, 12, 5) or
     testTimestamp == dateTimestamp(2025, 1, 9)

isTradingDay(int testTimestamp) =>
    int weekday = dayofweek(
         testTimestamp,
         MARKET_TZ
    )

    bool isWeekday =
         weekday != dayofweek.saturday and
         weekday != dayofweek.sunday

    isWeekday and
     not isRegularMarketHoliday(testTimestamp) and
     not isExtraordinaryMarketClosure(testTimestamp)

annualDateOnOrAfter(
     int baseTimestamp,
     int targetMonth,
     int targetDay
) =>
    int baseYear = year(
         baseTimestamp,
         MARKET_TZ
    )

    int candidate = dateTimestamp(
         baseYear,
         targetMonth,
         targetDay
    )

    if candidate < baseTimestamp
        candidate := dateTimestamp(
             baseYear + 1,
             targetMonth,
             targetDay
        )

    candidate

// ============================================================================
// Drawing helper
// ============================================================================

drawDateLine(
     int lineTimestamp,
     float rangeLow,
     float rangeHigh,
     float labelPrice,
     string labelText,
     color lineColor,
     int lineWidth,
     string lineStyle,
     bool showLabel,
     color labelBackground,
     string labelTextSize
) =>
    line newLine = line.new(
         x1 = lineTimestamp,
         y1 = rangeLow,
         x2 = lineTimestamp,
         y2 = rangeHigh,
         xloc = xloc.bar_time,
         extend = extend.none,
         color = lineColor,
         style = lineStyle,
         width = lineWidth
    )

    label newLabel = na

    if showLabel
        newLabel := label.new(
             x = lineTimestamp,
             y = labelPrice,
             text = labelText,
             xloc = xloc.bar_time,
             yloc = yloc.price,
             color = labelBackground,
             style = label.style_label_center,
             textcolor = lineColor,
             size = labelTextSize,
             textalign = text.align_center
        )

    [newLine, newLabel]

// ============================================================================
// Date definitions
// ============================================================================

int startDate = dateTimestamp(
     year(startDateInput, MARKET_TZ),
     month(startDateInput, MARKET_TZ),
     dayofmonth(startDateInput, MARKET_TZ)
)

var array<int> calendarDayOffsets = array.from(
     30,
     45,
     60,
     90,
     135,
     150,
     180,
     210,
     225,
     315,
     330,
     360
)

var array<int> tradingDays = array.from(
     11,
     22,
     33,
     45,
     56,
     67,
     78,
     90,
     101,
     112,
     123,
     135,
     146,
     157,
     168,
     180
)

var array<string> annualDateLabels = array.from(
     "Dec. 22",
     "Mar. 21",
     "Jun. 22",
     "Sep. 21"
)

var array<int> annualMonths = array.from(
     12,
     3,
     6,
     9
)

var array<int> annualMonthDays = array.from(
     22,
     21,
     22,
     21
)

// ============================================================================
// Price range beginning at the selected start date
// ============================================================================

var float rangeLow = na
var float rangeHigh = na

if time >= startDate
    rangeLow := na(rangeLow) ?
         low :
         math.min(rangeLow, low)

    rangeHigh := na(rangeHigh) ?
         high :
         math.max(rangeHigh, high)

float chartLow = na(rangeLow) ? low : rangeLow
float chartHigh = na(rangeHigh) ? high : rangeHigh

float chartDelta = math.max(
     chartHigh - chartLow,
     syminfo.mintick
)

float labelLocationCalendarDays = chartHigh
float labelLocationAnnualDates = chartLow + chartDelta / 3.0
float labelLocationTradingDays = chartLow

// ============================================================================
// Persistent drawing collections
// ============================================================================

var array<line> drawnLines = array.new<line>()
var array<label> drawnLabels = array.new<label>()

// ============================================================================
// Drawing
// ============================================================================

if barstate.islast
    // Remove the previous drawing set.
    while array.size(drawnLines) > 0
        line.delete(array.pop(drawnLines))

    while array.size(drawnLabels) > 0
        label.delete(array.pop(drawnLabels))

    // ------------------------------------------------------------------------
    // Start date
    // ------------------------------------------------------------------------

    [startLine, startLabel] = drawDateLine(
         startDateInput,
         chartLow,
         chartHigh,
         chartHigh,
         "Start",
         startColor,
         startWidthInput,
         startLineStyle,
         showStartLabels,
         startLabelBackgroundInput,
         startLabelSize
    )

    array.push(drawnLines, startLine)

    if not na(startLabel)
        array.push(drawnLabels, startLabel)

    // ------------------------------------------------------------------------
     // Calendar days
    //
    // The input date is calendar day 1, so N D is placed at N - 1
    // calendar days after the input date.
    // ------------------------------------------------------------------------

    if includeCalendarDays
        for index = 0 to array.size(calendarDayOffsets) - 1
            int numberOfDays = array.get(
                 calendarDayOffsets,
                 index
            )

            int calendarDayTimestamp = addCalendarDays(
                 startDate,
                 numberOfDays - 1
            )

            string calendarDayLabel =
                 str.tostring(numberOfDays) + " D"

            [dateLine, dateLabel] = drawDateLine(
                 calendarDayTimestamp,
                 chartLow,
                 chartHigh,
                 labelLocationCalendarDays,
                 calendarDayLabel,
                 calendarDayColor,
                 calendarDayWidthInput,
                 calendarDayLineStyle,
                 showCalendarDayLabels,
                 calendarDayLabelBackgroundInput,
                 calendarDayLabelSize
            )

            array.push(drawnLines, dateLine)

            if not na(dateLabel)
                array.push(drawnLabels, dateLabel)

    // ------------------------------------------------------------------------
     // Annual dates
    // ------------------------------------------------------------------------

    if includeAnnualDates
        for index = 0 to array.size(annualDateLabels) - 1
            string annualDateLabel = array.get(
                 annualDateLabels,
                 index
            )

            int annualMonth = array.get(
                 annualMonths,
                 index
            )

            int annualDay = array.get(
                 annualMonthDays,
                 index
            )

            int annualTimestamp = annualDateOnOrAfter(
                 startDate,
                 annualMonth,
                 annualDay
            )

            [dateLine, dateLabel] = drawDateLine(
                 annualTimestamp,
                 chartLow,
                 chartHigh,
                 labelLocationAnnualDates,
                 annualDateLabel,
                 annualColor,
                 annualWidthInput,
                 annualLineStyle,
                 showAnnualDateLabels,
                 annualLabelBackgroundInput,
                 annualLabelSize
            )

            array.push(drawnLines, dateLine)

            if not na(dateLabel)
                array.push(drawnLabels, dateLabel)

    // ------------------------------------------------------------------------
     // Trading days
    //
     // The input date is the measurement anchor (trading day 0). Counting
     // begins with the next calendar date that is a valid trading day.
    // ------------------------------------------------------------------------

	if includeTradingDays
        int currentYear = year(
             startDate,
             MARKET_TZ
        )

        int currentMonth = month(
             startDate,
             MARKET_TZ
        )

        int currentDay = dayofmonth(
             startDate,
             MARKET_TZ
        )

        int currentTimestamp = startDate
        int tradingDayCount = 0
        int targetIndex = 0
        int calendarDaysScanned = 0

        while targetIndex < array.size(tradingDays) and
             calendarDaysScanned < MAX_TRADING_SCAN_DAYS

            [nextYear, nextMonth, nextDay] = nextCalendarDate(
                 currentYear,
                 currentMonth,
                 currentDay
            )

            currentYear := nextYear
            currentMonth := nextMonth
            currentDay := nextDay

            currentTimestamp := dateTimestamp(
                 currentYear,
                 currentMonth,
                 currentDay
            )

            if isTradingDay(currentTimestamp)
                tradingDayCount := tradingDayCount + 1

                int targetTradingDay = array.get(
                     tradingDays,
                     targetIndex
                )

                if tradingDayCount == targetTradingDay
                    string tradingDayLabel =
                         str.tostring(targetTradingDay) + " TD"

                    [dateLine, dateLabel] = drawDateLine(
                         currentTimestamp,
                         chartLow,
                         chartHigh,
                         labelLocationTradingDays,
                         tradingDayLabel,
                         tradingDaysColor,
                         tradingDaysWidthInput,
                         tradingDaysLineStyle,
                         showTradingDayLabels,
                         tradingDaysLabelBackgroundInput,
                         tradingDaysLabelSize
                    )

                    array.push(drawnLines, dateLine)

                    if not na(dateLabel)
                        array.push(drawnLabels, dateLabel)

                    targetIndex := targetIndex + 1

            calendarDaysScanned := calendarDaysScanned + 1
````
