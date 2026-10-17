# RCS Sessions Full

- url: https://www.tradingview.com/script/P3e4SFx9-RCS-Sessions-Full/
- type: indicator
- pine_id: PUB;4f9145d289e1465ba36bac0d54e43c4f
- version: 1.0

## Description

# RCS Sessions

RCS Sessions is a session-based timing indicator designed to help traders visualize key institutional reference points throughout the trading day.

The indicator automatically plots important session opens, closes, institutional print times, news windows, and delivery periods directly on the chart. All levels are displayed in advance for the current trading day while also preserving historical references from previous days for review and study.

The framework is built around the RCS Execution methodology, which emphasizes timing, positioning, liquidity, and institutional delivery rather than traditional retail indicators.

## Key Session Markers

* 00:00 – Midnight
* 03:00 – Asia Open
* 07:00 – New York Midnight
* 08:00 – 7H Print
* 09:00 – Sydney End / 4H Print
* 10:00 – London Open
* 12:00 – Asia End
* 13:00 – 4H Print
* 15:00 – 7H Print / New York Open
* 15:30 – News
* 16:00 – News Wave
* 16:30 – New York Open
* 17:00 – 4H Print / Order Delivery
* 19:00 – London End
* 21:00 – New York PM / 4H Print
* 22:00 – End of Day / 7H Print

## Features

* Displays the complete trading day in advance.
* Preserves previous session references for historical analysis.
* Fully customizable timezone support.
* Adjustable line colors, styles, labels, and visibility.
* Designed for futures, indices, forex, and other liquid markets.
* Lightweight and easy to read.
* Suitable for discretionary and rule-based execution models.

## Intended Use

This indicator does not generate buy or sell signals.

Its purpose is to provide a structured timing framework that helps traders organize market analysis around major institutional session transitions, liquidity events, and delivery windows.

## Recommended Usage

For best results, combine the session framework with:

* Market structure analysis
* Liquidity identification
* Session-based execution
* News awareness
* Risk management
* Institutional confirmation models

Trade the system – not the emotion.

© Raul Cristian Sararu

## Source Code

````pine
//@version=6
indicator("RCS Sessions", overlay=true, max_lines_count=500, max_labels_count=500)

// ===== GROUPS =====
groupInputs = "Inputs"
groupStyle = "Style"
groupText = "Text"
groupVisibility = "Visibility"

// ===== INPUTS =====
tz = input.string("GMT+3", "Timezone", options=["GMT+3", "GMT+2", "Europe/Bucharest", "Etc/UTC", "America/New_York", "Europe/London", "Europe/Athens", "Asia/Tokyo", "Australia/Sydney"], group=groupInputs)
historyDays = input.int(7, "Previous Days To Show", minval=1, maxval=20, group=groupInputs)

// ===== STYLE =====
lineWidth = input.int(1, "Line Width", minval=1, maxval=5, group=groupStyle)
lineStyleInput = input.string("Dotted", "Line Style", options=["Solid", "Dashed", "Dotted"], group=groupStyle)

sessionColor = input.color(color.gray, "Session Line Color", group=groupStyle)

// ===== TEXT =====
textColor = input.color(color.black, "Text Color", group=groupText)
textBgColor = input.color(color.new(color.white, 100), "Text Background", group=groupText)
textSizeInput = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal", "Large"], group=groupText)
textVerticalAlign = input.string("Top", "Text Vertical Alignment", options=["Top", "Middle", "Bottom"], group=groupText)
textHorizontalAlign = input.string("Right", "Text Horizontal Alignment", options=["Left", "Center", "Right"], group=groupText)
textOrientation = input.string("Horizontal", "Text Orientation", options=["Horizontal", "Vertical"], group=groupText)
textLookback = input.int(5000, "Text Position Lookback Bars", minval=100, maxval=10000, group=groupText)
textOffsetPercent = input.float(0.03, "Top/Bottom Offset", minval=0.00, maxval=0.50, step=0.01, group=groupText)

// ===== TEXT LABELS =====
text0000 = input.string("Midnight", "00:00 Text", group=groupText)
text0300 = input.string("Asia Open", "03:00 Text", group=groupText)
text0700 = input.string("New York Midnight", "07:00 Text", group=groupText)
text0800 = input.string("7H Print", "08:00 Text", group=groupText)
text0900 = input.string("Sydney End / 4H Print", "09:00 Text", group=groupText)
text1000 = input.string("London Open", "10:00 Text", group=groupText)
text1200 = input.string("Asia End", "12:00 Text", group=groupText)
text1300 = input.string("4H Print", "13:00 Text", group=groupText)
text1500 = input.string("7H Print / NY Open", "15:00 Text", group=groupText)
text1530 = input.string("News", "15:30 Text", group=groupText)
text1600 = input.string("News Wave", "16:00 Text", group=groupText)
text1630 = input.string("New York Open", "16:30 Text", group=groupText)
text1700 = input.string("4H Print / Order Delivery", "17:00 Text", group=groupText)
text1900 = input.string("London End", "19:00 Text", group=groupText)
text2100 = input.string("NY PM / 4H Print", "21:00 Text", group=groupText)
text2200 = input.string("End of Day / 7H Print", "22:00 Text", group=groupText)

// ===== VISIBILITY =====
showLine0000 = input.bool(true, "00:00 Show Line", inline="0000", group=groupVisibility)
showText0000 = input.bool(false, "Show Text", inline="0000", group=groupVisibility)

showLine0300 = input.bool(true, "03:00 Show Line", inline="0300", group=groupVisibility)
showText0300 = input.bool(false, "Show Text", inline="0300", group=groupVisibility)

showLine0700 = input.bool(true, "07:00 Show Line", inline="0700", group=groupVisibility)
showText0700 = input.bool(false, "Show Text", inline="0700", group=groupVisibility)

showLine0800 = input.bool(true, "08:00 Show Line", inline="0800", group=groupVisibility)
showText0800 = input.bool(false, "Show Text", inline="0800", group=groupVisibility)

showLine0900 = input.bool(true, "09:00 Show Line", inline="0900", group=groupVisibility)
showText0900 = input.bool(false, "Show Text", inline="0900", group=groupVisibility)

showLine1000 = input.bool(true, "10:00 Show Line", inline="1000", group=groupVisibility)
showText1000 = input.bool(false, "Show Text", inline="1000", group=groupVisibility)

showLine1200 = input.bool(true, "12:00 Show Line", inline="1200", group=groupVisibility)
showText1200 = input.bool(false, "Show Text", inline="1200", group=groupVisibility)

showLine1300 = input.bool(true, "13:00 Show Line", inline="1300", group=groupVisibility)
showText1300 = input.bool(false, "Show Text", inline="1300", group=groupVisibility)

showLine1500 = input.bool(true, "15:00 Show Line", inline="1500", group=groupVisibility)
showText1500 = input.bool(false, "Show Text", inline="1500", group=groupVisibility)

showLine1530 = input.bool(true, "15:30 Show Line", inline="1530", group=groupVisibility)
showText1530 = input.bool(false, "Show Text", inline="1530", group=groupVisibility)

showLine1600 = input.bool(true, "16:00 Show Line", inline="1600", group=groupVisibility)
showText1600 = input.bool(false, "Show Text", inline="1600", group=groupVisibility)

showLine1630 = input.bool(true, "16:30 Show Line", inline="1630", group=groupVisibility)
showText1630 = input.bool(false, "Show Text", inline="1630", group=groupVisibility)

showLine1700 = input.bool(true, "17:00 Show Line", inline="1700", group=groupVisibility)
showText1700 = input.bool(false, "Show Text", inline="1700", group=groupVisibility)

showLine1900 = input.bool(true, "19:00 Show Line", inline="1900", group=groupVisibility)
showText1900 = input.bool(false, "Show Text", inline="1900", group=groupVisibility)

showLine2100 = input.bool(true, "21:00 Show Line", inline="2100", group=groupVisibility)
showText2100 = input.bool(false, "Show Text", inline="2100", group=groupVisibility)

showLine2200 = input.bool(true, "22:00 Show Line", inline="2200", group=groupVisibility)
showText2200 = input.bool(false, "Show Text", inline="2200", group=groupVisibility)

// ===== CONVERSIONS =====
lineStyle = lineStyleInput == "Solid" ? line.style_solid : lineStyleInput == "Dotted" ? line.style_dotted : line.style_dashed
textSize = textSizeInput == "Tiny" ? size.tiny : textSizeInput == "Normal" ? size.normal : textSizeInput == "Large" ? size.large : size.small

// ===== STORAGE =====
var lines = array.new_line()
var labels = array.new_label()

// ===== FUNCTIONS =====
makeVerticalText(txt) =>
    result = ""
    for i = 0 to str.length(txt) - 1
        result := result + str.substring(txt, i, i + 1)
        if i < str.length(txt) - 1
            result := result + "\n"
    result

formatText(txt) =>
    textOrientation == "Vertical" ? makeVerticalText(txt) : txt

getLabelXOffsetMs() =>
    textHorizontalAlign == "Left" ? -5 * 60 * 1000 : textHorizontalAlign == "Right" ? 5 * 60 * 1000 : 0

getLabelY() =>
    hi = ta.highest(high, textLookback)
    lo = ta.lowest(low, textLookback)
    rng = hi - lo
    topY = hi + rng * textOffsetPercent
    midY = (hi + lo) / 2
    botY = lo - rng * textOffsetPercent
    textVerticalAlign == "Top" ? topY : textVerticalAlign == "Bottom" ? botY : midY

getLabelStyle() =>
    textVerticalAlign == "Bottom" ? label.style_label_up : label.style_label_down

clearDrawings() =>
    while array.size(lines) > 0
        line.delete(array.pop(lines))
    while array.size(labels) > 0
        label.delete(array.pop(labels))

drawSessionAtTime(dayTs, h, m, showLine, showText, txt) =>
    sessionTs = timestamp(tz, year(dayTs, tz), month(dayTs, tz), dayofmonth(dayTs, tz), h, m)

    if showLine
        ln = line.new(
             sessionTs,
             low,
             sessionTs,
             high,
             xloc=xloc.bar_time,
             extend=extend.both,
             color=sessionColor,
             style=lineStyle,
             width=lineWidth
        )
        array.push(lines, ln)

    if showText
        lb = label.new(
             sessionTs + getLabelXOffsetMs(),
             getLabelY(),
             formatText(txt),
             xloc=xloc.bar_time,
             yloc=yloc.price,
             style=getLabelStyle(),
             textcolor=textColor,
             color=textBgColor,
             size=textSize
        )
        array.push(labels, lb)

drawFullDay(dayTs) =>
    drawSessionAtTime(dayTs, 0, 0, showLine0000, showText0000, text0000)
    drawSessionAtTime(dayTs, 3, 0, showLine0300, showText0300, text0300)
    drawSessionAtTime(dayTs, 7, 0, showLine0700, showText0700, text0700)
    drawSessionAtTime(dayTs, 8, 0, showLine0800, showText0800, text0800)
    drawSessionAtTime(dayTs, 9, 0, showLine0900, showText0900, text0900)
    drawSessionAtTime(dayTs, 10, 0, showLine1000, showText1000, text1000)
    drawSessionAtTime(dayTs, 12, 0, showLine1200, showText1200, text1200)
    drawSessionAtTime(dayTs, 13, 0, showLine1300, showText1300, text1300)
    drawSessionAtTime(dayTs, 15, 0, showLine1500, showText1500, text1500)
    drawSessionAtTime(dayTs, 15, 30, showLine1530, showText1530, text1530)
    drawSessionAtTime(dayTs, 16, 0, showLine1600, showText1600, text1600)
    drawSessionAtTime(dayTs, 16, 30, showLine1630, showText1630, text1630)
    drawSessionAtTime(dayTs, 17, 0, showLine1700, showText1700, text1700)
    drawSessionAtTime(dayTs, 19, 0, showLine1900, showText1900, text1900)
    drawSessionAtTime(dayTs, 21, 0, showLine2100, showText2100, text2100)
    drawSessionAtTime(dayTs, 22, 0, showLine2200, showText2200, text2200)

// ===== DRAW TODAY IN ADVANCE + PREVIOUS WEEK =====
if barstate.islast
    clearDrawings()

    dayMs = 24 * 60 * 60 * 1000
    todayTs = timestamp(tz, year(timenow, tz), month(timenow, tz), dayofmonth(timenow, tz), 12, 0)

    for i = historyDays to 0
        dayTs = todayTs - i * dayMs
        drawFullDay(dayTs)
````
