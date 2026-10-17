# 7Hour_Levels

- url: https://www.tradingview.com/script/KXQfNGf1-7Hour-Levels/
- type: indicator
- pine_id: PUB;2bd624b0be914a06b2775c0425d63ba3
- version: 1.0

## Description

7Hour_Levels

7Hour_Levels is a time-based market structure tool built around four key reference points of the trading day:

Asia 18:00 → London 01:00 → NYAM 08:00 → NYPM 15:00 (New York time)

The trading day begins at 18:00 New York time, and each level is anchored precisely to the Open of the first candle at its corresponding session time.

From each Open, the indicator creates a clean crosshair-style reference:

* a horizontal level extending forward from the session Open;
* a vertical level extending downward from the same point;
* a clear session label positioned at the bottom of the vertical level.

## Source Code

````pine
//@version=6
indicator("7Hour_Levels", overlay = true, max_lines_count = 500, max_labels_count = 500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TIMEZONE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string TZ = "America/New_York"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DISPLAY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

displayGroup = "Display"

showPreviousDay = input.bool(
     false,
     "Show Previous Day",
     group = displayGroup)

lookBackDays = input.int(
     0,
     "Look Back Days",
     minval = 0,
     maxval = 10,
     group = displayGroup,
     tooltip = "Additional trading days before yesterday.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LABEL SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

labelGroup = "Labels"

labelSizeInput = input.string(
     "Normal",
     "Label Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     group = labelGroup)

labelBold = input.bool(
     true,
     "Bold",
     group = labelGroup)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ASIA 18:00
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

asiaGroup = "01 — Asia 18:00"

showAsia = input.bool(
     true,
     "Show Asia 18:00",
     group = asiaGroup)

asiaColor = input.color(
     color.black,
     "Color",
     group = asiaGroup)

asiaWidth = input.int(
     1,
     "Line Width",
     minval = 1,
     maxval = 5,
     group = asiaGroup)

asiaStyle = input.string(
     "Dotted",
     "Line Style",
     options = ["Solid", "Dashed", "Dotted"],
     group = asiaGroup)

asiaVerticalLength = input.float(
     100.0,
     "Vertical Length",
     minval = 0.0,
     step = 0.1,
     group = asiaGroup)

asiaHorizontalLength = input.int(
     30,
     "Horizontal Length (bars)",
     minval = 1,
     maxval = 500,
     group = asiaGroup)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LONDON 01:00
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

londonGroup = "02 — London 1:00"

showLondon = input.bool(
     true,
     "Show London 1:00",
     group = londonGroup)

londonColor = input.color(
     color.black,
     "Color",
     group = londonGroup)

londonWidth = input.int(
     1,
     "Line Width",
     minval = 1,
     maxval = 5,
     group = londonGroup)

londonStyle = input.string(
     "Dotted",
     "Line Style",
     options = ["Solid", "Dashed", "Dotted"],
     group = londonGroup)

londonVerticalLength = input.float(
     100.0,
     "Vertical Length",
     minval = 0.0,
     step = 0.1,
     group = londonGroup)

londonHorizontalLength = input.int(
     30,
     "Horizontal Length (bars)",
     minval = 1,
     maxval = 500,
     group = londonGroup)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NYAM 08:00
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

nyamGroup = "03 — NYAM 8:00"

showNYAM = input.bool(
     true,
     "Show NYAM 8:00",
     group = nyamGroup)

nyamColor = input.color(
     color.black,
     "Color",
     group = nyamGroup)

nyamWidth = input.int(
     1,
     "Line Width",
     minval = 1,
     maxval = 5,
     group = nyamGroup)

nyamStyle = input.string(
     "Dotted",
     "Line Style",
     options = ["Solid", "Dashed", "Dotted"],
     group = nyamGroup)

nyamVerticalLength = input.float(
     100.0,
     "Vertical Length",
     minval = 0.0,
     step = 0.1,
     group = nyamGroup)

nyamHorizontalLength = input.int(
     30,
     "Horizontal Length (bars)",
     minval = 1,
     maxval = 500,
     group = nyamGroup)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NYPM 15:00
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

nypmGroup = "04 — NYPM 15:00"

showNYPM = input.bool(
     true,
     "Show NYPM 15:00",
     group = nypmGroup)

nypmColor = input.color(
     color.black,
     "Color",
     group = nypmGroup)

nypmWidth = input.int(
     1,
     "Line Width",
     minval = 1,
     maxval = 5,
     group = nypmGroup)

nypmStyle = input.string(
     "Dotted",
     "Line Style",
     options = ["Solid", "Dashed", "Dotted"],
     group = nypmGroup)

nypmVerticalLength = input.float(
     100.0,
     "Vertical Length",
     minval = 0.0,
     step = 0.1,
     group = nypmGroup)

nypmHorizontalLength = input.int(
     30,
     "Horizontal Length (bars)",
     minval = 1,
     maxval = 500,
     group = nypmGroup)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

getLineStyle(string style) =>
    switch style
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

getLabelSize(string size) =>
    switch size
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Large"  => size.large
        "Huge"   => size.huge
        => size.normal

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRADING DAY
//
// Trading day starts at 18:00 NY.
// 18:00 → next 17:59 = one trading day.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

getTradingDay(int t) =>
    int y = year(t, TZ)
    int m = month(t, TZ)
    int d = dayofmonth(t, TZ)
    int h = hour(t, TZ)

    h >= 18
         ? timestamp(TZ, y, m, d, 0, 0)
         : timestamp(TZ, y, m, d - 1, 0, 0)

// Current trading day
currentTradingDay = getTradingDay(timenow)

// Trading day of current bar
barTradingDay = getTradingDay(time)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRADING DAY DIFFERENCE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

daysAgo = math.round(
     (currentTradingDay - barTradingDay) / 86400000)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VISIBILITY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

isToday = daysAgo == 0

isPreviousDay = daysAgo == 1

isLookBackDay =
     daysAgo >= 2 and
     daysAgo <= lookBackDays + 1

showThisDay =
     isToday or
     (isPreviousDay and showPreviousDay) or
     isLookBackDay

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NEW YORK TIME
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

nyHour   = hour(time, TZ)
nyMinute = minute(time, TZ)

// Exact session candles
isAsia   = nyHour == 18 and nyMinute == 0
isLondon = nyHour == 1  and nyMinute == 0
isNYAM   = nyHour == 8  and nyMinute == 0
isNYPM   = nyHour == 15 and nyMinute == 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAW CROSS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

drawCross(
     bool enabled,
     string sessionName,
     color sessionColor,
     int lineWidth,
     string lineStyle,
     float verticalLength,
     int horizontalLength) =>

    if enabled and showThisDay

        //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // CROSS CENTER
        // Exact session candle + exact OPEN
        //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        int crossX = bar_index
        float crossY = open

        //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // VERTICAL LINE
        // From OPEN downward
        //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        float verticalEnd = crossY - verticalLength

        line.new(
             x1 = crossX,
             y1 = crossY,
             x2 = crossX,
             y2 = verticalEnd,
             xloc = xloc.bar_index,
             extend = extend.none,
             color = sessionColor,
             style = getLineStyle(lineStyle),
             width = lineWidth)

        //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // HORIZONTAL LINE
        // From OPEN to the right
        //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        int horizontalEnd = crossX + horizontalLength

        line.new(
             x1 = crossX,
             y1 = crossY,
             x2 = horizontalEnd,
             y2 = crossY,
             xloc = xloc.bar_index,
             extend = extend.none,
             color = sessionColor,
             style = getLineStyle(lineStyle),
             width = lineWidth)

        //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // LABEL
        //
        // Exactly centered under the vertical line.
        // 10% gap below the line.
        // No background.
        //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        float labelGap = math.max(
             verticalLength * 0.10,
             syminfo.mintick * 20)

        label.new(
             x = crossX,
             y = verticalEnd - labelGap,
             xloc = xloc.bar_index,
             yloc = yloc.price,
             text = sessionName,
             style = label.style_none,
             color = color(na),
             textcolor = color.black,
             size = getLabelSize(labelSizeInput),
             textalign = text.align_center,
             text_formatting = labelBold ? text.format_bold : text.format_none)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ASIA 18:00
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if isAsia
    drawCross(
         showAsia,
         "Asia 18:00",
         asiaColor,
         asiaWidth,
         asiaStyle,
         asiaVerticalLength,
         asiaHorizontalLength)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LONDON 01:00
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if isLondon
    drawCross(
         showLondon,
         "London 1:00",
         londonColor,
         londonWidth,
         londonStyle,
         londonVerticalLength,
         londonHorizontalLength)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NYAM 08:00
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if isNYAM
    drawCross(
         showNYAM,
         "NYAM 8:00",
         nyamColor,
         nyamWidth,
         nyamStyle,
         nyamVerticalLength,
         nyamHorizontalLength)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NYPM 15:00
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if isNYPM
    drawCross(
         showNYPM,
         "NYPM 15:00",
         nypmColor,
         nypmWidth,
         nypmStyle,
         nypmVerticalLength,
         nypmHorizontalLength)
````
