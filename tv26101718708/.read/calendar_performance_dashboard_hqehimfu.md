# Calendar Performance Dashboard

- url: https://www.tradingview.com/script/HQEhiMfu-Calendar-Performance-Dashboard/
- type: indicator
- pine_id: PUB;65c2ff32fbc940fd95f6e0da26c63a1f
- version: 1.0

## Description

Calendar Performance Dashboard
Overview

Calendar Performance Dashboard is a professional performance analysis tool that measures an asset's price performance across the current calendar year using meaningful time periods instead of arbitrary lookback windows.

Rather than showing only today's price change or the last 24 hours, this indicator helps investors understand how an asset has performed during the current trading day, week, month, year, and each individual calendar quarter.

It is designed for investors, swing traders, portfolio managers, and anyone who wants a quick overview of an asset's performance without changing chart timeframes.

Features
📅 Today Performance

Measures the percentage change from today's opening price to the current price.

Formula

Current Price vs Today's Open

📅 Week Performance

Measures performance from the opening of the current trading week.

📅 Month Performance

Measures performance from the first trading day of the current month.

📈 Year To Date (YTD)

Shows the total return since the first trading day of the current calendar year.

This allows you to quickly determine whether an asset is outperforming or underperforming during the year.

📊 Calendar Quarter Performance

The indicator automatically divides the current year into four calendar quarters.

Q1

January 1 → March 31

Q2

April 1 → June 30

Q3

July 1 → September 30

Q4

October 1 → December 31

Completed quarters display their final performance, while the current quarter updates in real time.

Future quarters are marked as Not Started.

Status System

Each period has its own status.

🟢 Completed

The period has finished and its performance is fixed.

🟡 Current

The period is still active and updates every bar.

⚪ Not Started

The period has not begun yet.

Dashboard Information

The dashboard displays:

Period
Start Price
End Price / Current Price
Percentage Change
Status

All information is updated automatically without changing chart timeframes.

Why use Calendar Performance instead of Rolling Performance?

Most indicators use rolling periods such as:

Last 30 Days
Last 90 Days
Last 365 Days

While useful, these periods make it difficult to compare true calendar performance.

This indicator instead uses calendar periods, making it ideal for:

Annual performance analysis
Quarterly performance comparison
Portfolio reviews
Institutional-style reporting
Long-term investment monitoring
Suitable Markets
Cryptocurrency
Stocks
ETFs
Forex
Commodities
Indices
Ideal For
Long-term Investors
Swing Traders
Portfolio Managers
Market Analysts
Financial Reporting
Performance Comparison
Notes
Performance calculations are based on calendar periods rather than rolling lookback windows.
Completed quarters remain fixed after they end.
The current quarter updates continuously until the quarter closes.
YTD always measures performance from the first trading day of the current year.

Calendar Performance Dashboard provides a clean, intuitive way to understand an asset's performance across the most meaningful calendar periods—all in a single dashboard.

## Source Code

````pine
//@version=6
indicator(
     "Calendar Performance Dashboard",
     shorttitle = "Calendar Performance",
     overlay = true
)

//=============================================================================
// Settings
//=============================================================================

groupDashboard = "Dashboard Settings"

tablePositionInput = input.string(
     "Top Right",
     "Table Position",
     options = [
         "Top Right",
         "Top Left",
         "Bottom Right",
         "Bottom Left",
         "Middle Right",
         "Middle Left"
     ],
     group = groupDashboard
)

textSizeInput = input.string(
     "Small",
     "Text Size",
     options = ["Tiny", "Small", "Normal", "Large"],
     group = groupDashboard
)

groupColors = "Color Settings"

positiveColor = input.color(
     color.rgb(20, 190, 125),
     "Positive Change",
     group = groupColors
)

negativeColor = input.color(
     color.rgb(225, 65, 85),
     "Negative Change",
     group = groupColors
)

neutralColor = input.color(
     color.rgb(135, 140, 150),
     "Neutral Change",
     group = groupColors
)

currentColor = input.color(
     color.rgb(230, 170, 35),
     "Current Status",
     group = groupColors
)

completedColor = input.color(
     color.rgb(40, 175, 120),
     "Completed Status",
     group = groupColors
)

notStartedColor = input.color(
     color.rgb(135, 140, 150),
     "Not Started Status",
     group = groupColors
)

headerColor = input.color(
     color.rgb(35, 38, 47),
     "Header Background",
     group = groupColors
)

bodyColor = input.color(
     color.rgb(23, 25, 31),
     "Body Background",
     group = groupColors
)

borderColor = input.color(
     color.rgb(80, 85, 95),
     "Border Color",
     group = groupColors
)

//=============================================================================
// Table configuration
//=============================================================================

tablePosition = switch tablePositionInput
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    "Middle Right" => position.middle_right
    "Middle Left"  => position.middle_left
    => position.top_right

tableTextSize = switch textSizeInput
    "Tiny"   => size.tiny
    "Normal" => size.normal
    "Large"  => size.large
    => size.small

//=============================================================================
// Current price
//=============================================================================

float currentPrice = close

//=============================================================================
// Today, Week, Month and YTD
//=============================================================================

float todayOpen = request.security(
     syminfo.tickerid,
     "D",
     open,
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on
)

float weekOpen = request.security(
     syminfo.tickerid,
     "W",
     open,
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on
)

float monthOpen = request.security(
     syminfo.tickerid,
     "M",
     open,
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on
)

// افتتاح السنة الحالية - 1 يناير
float yearOpen = request.security(
     syminfo.tickerid,
     "12M",
     open,
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on
)

//=============================================================================
// Calendar quarters
//=============================================================================

float currentQuarterOpen = request.security(
     syminfo.tickerid,
     "3M",
     open,
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on
)

float previousQuarterOpen1 = request.security(
     syminfo.tickerid,
     "3M",
     open[1],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on
)

float previousQuarterOpen2 = request.security(
     syminfo.tickerid,
     "3M",
     open[2],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on
)

float previousQuarterOpen3 = request.security(
     syminfo.tickerid,
     "3M",
     open[3],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on
)

float previousQuarterClose1 = request.security(
     syminfo.tickerid,
     "3M",
     close[1],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on
)

float previousQuarterClose2 = request.security(
     syminfo.tickerid,
     "3M",
     close[2],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on
)

float previousQuarterClose3 = request.security(
     syminfo.tickerid,
     "3M",
     close[3],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on
)

// رقم الربع الحالي
int currentQuarterNumber = int(math.ceil(month / 3.0))

//=============================================================================
// Assign quarter values
//=============================================================================

float q1Start = na
float q1End   = na

float q2Start = na
float q2End   = na

float q3Start = na
float q3End   = na

float q4Start = na
float q4End   = na

// Q1
if currentQuarterNumber == 1
    q1Start := currentQuarterOpen
    q1End   := currentPrice
else if currentQuarterNumber == 2
    q1Start := previousQuarterOpen1
    q1End   := previousQuarterClose1
else if currentQuarterNumber == 3
    q1Start := previousQuarterOpen2
    q1End   := previousQuarterClose2
else
    q1Start := previousQuarterOpen3
    q1End   := previousQuarterClose3

// Q2
if currentQuarterNumber == 2
    q2Start := currentQuarterOpen
    q2End   := currentPrice
else if currentQuarterNumber == 3
    q2Start := previousQuarterOpen1
    q2End   := previousQuarterClose1
else if currentQuarterNumber == 4
    q2Start := previousQuarterOpen2
    q2End   := previousQuarterClose2

// Q3
if currentQuarterNumber == 3
    q3Start := currentQuarterOpen
    q3End   := currentPrice
else if currentQuarterNumber == 4
    q3Start := previousQuarterOpen1
    q3End   := previousQuarterClose1

// Q4
if currentQuarterNumber == 4
    q4Start := currentQuarterOpen
    q4End   := currentPrice

//=============================================================================
// Calculations
//=============================================================================

calculateChange(float endValue, float startValue) =>
    not na(endValue) and not na(startValue) and startValue != 0
         ? ((endValue / startValue) - 1.0) * 100.0
         : na

float todayChange = calculateChange(currentPrice, todayOpen)
float weekChange  = calculateChange(currentPrice, weekOpen)
float monthChange = calculateChange(currentPrice, monthOpen)
float ytdChange   = calculateChange(currentPrice, yearOpen)

float q1Change = calculateChange(q1End, q1Start)
float q2Change = calculateChange(q2End, q2Start)
float q3Change = calculateChange(q3End, q3Start)
float q4Change = calculateChange(q4End, q4Start)

//=============================================================================
// Formatting
//=============================================================================

getChangeColor(float value) =>
    na(value)
         ? neutralColor
         : value > 0
         ? positiveColor
         : value < 0
         ? negativeColor
         : neutralColor

formatPrice(float value) =>
    na(value)
         ? "—"
         : str.tostring(value, format.mintick)

formatChange(float value) =>
    if na(value)
        "—"
    else
        string icon = value > 0 ? "●" : value < 0 ? "▼" : "●"
        string sign = value > 0 ? "+" : ""
        icon + " " + sign + str.tostring(value, "#.##") + "%"

getQuarterStatus(int quarterNumber) =>
    quarterNumber < currentQuarterNumber
         ? "Completed"
         : quarterNumber == currentQuarterNumber
         ? "Current"
         : "Not Started"

getStatusColor(int quarterNumber) =>
    quarterNumber < currentQuarterNumber
         ? completedColor
         : quarterNumber == currentQuarterNumber
         ? currentColor
         : notStartedColor

//=============================================================================
// Drawing function
//=============================================================================

drawPerformanceRow(
     table tableId,
     int row,
     string periodName,
     float startValue,
     float endValue,
     float changeValue,
     string statusText,
     color statusTextColor
) =>
    color changeTextColor = getChangeColor(changeValue)

    table.cell(
         tableId,
         0,
         row,
         periodName,
         text_color = color.white,
         bgcolor = bodyColor,
         text_size = tableTextSize
    )

    table.cell(
         tableId,
         1,
         row,
         formatPrice(startValue),
         text_color = color.white,
         bgcolor = bodyColor,
         text_size = tableTextSize
    )

    table.cell(
         tableId,
         2,
         row,
         formatPrice(endValue),
         text_color = color.white,
         bgcolor = bodyColor,
         text_size = tableTextSize
    )

    table.cell(
         tableId,
         3,
         row,
         formatChange(changeValue),
         text_color = changeTextColor,
         bgcolor = color.new(changeTextColor, 87),
         text_size = tableTextSize
    )

    table.cell(
         tableId,
         4,
         row,
         statusText,
         text_color = statusTextColor,
         bgcolor = bodyColor,
         text_size = tableTextSize
    )

//=============================================================================
// Dashboard
//=============================================================================

var table dashboard = table.new(
     tablePosition,
     5,
     10,
     bgcolor = bodyColor,
     frame_color = borderColor,
     frame_width = 1,
     border_color = borderColor,
     border_width = 1
)

if barstate.islast
    table.clear(dashboard, 0, 0, 4, 9)

    // Main title
    table.cell(
         dashboard,
         0,
         0,
         "PERFORMANCE",
         text_color = color.white,
         bgcolor = headerColor,
         text_size = tableTextSize
    )

    table.cell(
         dashboard,
         1,
         0,
         syminfo.ticker,
         text_color = color.white,
         bgcolor = headerColor,
         text_size = tableTextSize
    )

    table.cell(
         dashboard,
         2,
         0,
         str.tostring(year),
         text_color = color.silver,
         bgcolor = headerColor,
         text_size = tableTextSize
    )

    table.cell(
         dashboard,
         3,
         0,
         timeframe.period,
         text_color = color.silver,
         bgcolor = headerColor,
         text_size = tableTextSize
    )

    table.cell(
         dashboard,
         4,
         0,
         "CALENDAR",
         text_color = color.silver,
         bgcolor = headerColor,
         text_size = tableTextSize
    )

    // Column headers
    table.cell(
         dashboard,
         0,
         1,
         "Period",
         text_color = color.silver,
         bgcolor = headerColor,
         text_size = tableTextSize
    )

    table.cell(
         dashboard,
         1,
         1,
         "Start Price",
         text_color = color.silver,
         bgcolor = headerColor,
         text_size = tableTextSize
    )

    table.cell(
         dashboard,
         2,
         1,
         "End / Current",
         text_color = color.silver,
         bgcolor = headerColor,
         text_size = tableTextSize
    )

    table.cell(
         dashboard,
         3,
         1,
         "Change",
         text_color = color.silver,
         bgcolor = headerColor,
         text_size = tableTextSize
    )

    table.cell(
         dashboard,
         4,
         1,
         "Status",
         text_color = color.silver,
         bgcolor = headerColor,
         text_size = tableTextSize
    )

    // Today
    drawPerformanceRow(
         dashboard,
         2,
         "Today",
         todayOpen,
         currentPrice,
         todayChange,
         "Current",
         currentColor
    )

    // Week
    drawPerformanceRow(
         dashboard,
         3,
         "Week",
         weekOpen,
         currentPrice,
         weekChange,
         "Current",
         currentColor
    )

    // Month
    drawPerformanceRow(
         dashboard,
         4,
         "Month",
         monthOpen,
         currentPrice,
         monthChange,
         "Current",
         currentColor
    )

    // YTD
    drawPerformanceRow(
         dashboard,
         5,
         "YTD",
         yearOpen,
         currentPrice,
         ytdChange,
         "Current",
         currentColor
    )

    // Q1
    drawPerformanceRow(
         dashboard,
         6,
         "Q1",
         q1Start,
         q1End,
         q1Change,
         getQuarterStatus(1),
         getStatusColor(1)
    )

    // Q2
    drawPerformanceRow(
         dashboard,
         7,
         "Q2",
         q2Start,
         q2End,
         q2Change,
         getQuarterStatus(2),
         getStatusColor(2)
    )

    // Q3
    drawPerformanceRow(
         dashboard,
         8,
         "Q3",
         q3Start,
         q3End,
         q3Change,
         getQuarterStatus(3),
         getStatusColor(3)
    )

    // Q4
    drawPerformanceRow(
         dashboard,
         9,
         "Q4",
         q4Start,
         q4End,
         q4Change,
         getQuarterStatus(4),
         getStatusColor(4)
    )
````
