# Automatic HTF Open

- url: https://www.tradingview.com/script/JcotCBzE-Automatic-HTF-Open/
- type: indicator
- pine_id: PUB;2ab16d0cd6904f18a1a56bbb7184f23a
- version: 1.0

## Description

Automatic Higher Timeframe Open
Automatically displays the relevant higher-timeframe opening price based on the current chart timeframe:
- 15-minute chart → Daily Open (D)
- 1-hour chart → Weekly Open (W)
- 4-hour chart → Monthly Open (M)
The indicator automatically switches the open level when the chart timeframe changes, eliminating the need to manually enable or disable Daily, Weekly, and Monthly opens.
Each opening price is displayed as a horizontal level with its corresponding D, W, or M label and extends to the right for easy reference.
Based on the Daily, Weekly, and Monthly open levels provided by the original indicator.    Pasted markdown

## Source Code

````pine
//@version=6
indicator("Automatic HTF Open", "Auto Open", overlay=true, max_lines_count=500, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

dailyColor   = input.color(color.green,  "Daily Open Color", group="STYLE")
weeklyColor  = input.color(color.orange, "Weekly Open Color", group="STYLE")
monthlyColor = input.color(color.red,    "Monthly Open Color", group="STYLE")

lineWidth = input.int(1, "Line Width", minval=1, maxval=5, group="STYLE")

showLabel = input.bool(true, "Show Label", group="STYLE")

rightOffset = input.int(
     20,
     "Right Offset",
     minval=1,
     maxval=100,
     group="STYLE")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// AUTOMATIC TIMEFRAME SELECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bool is15m = timeframe.isminutes and timeframe.multiplier == 15
bool is1H  = timeframe.isminutes and timeframe.multiplier == 60
bool is4H  = timeframe.isminutes and timeframe.multiplier == 240

string selectedTF = is15m ? "D" : is1H ? "W" : is4H ? "M" : ""

string selectedName = is15m ? "D" : is1H ? "W" : is4H ? "M" : ""

color selectedColor = is15m ? dailyColor : is1H ? weeklyColor : monthlyColor

bool validTF = is15m or is1H or is4H

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// REQUEST HTF OPEN
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

float htfOpen = na
int htfTime = na

if validTF
    htfOpen := request.security(
         syminfo.tickerid,
         selectedTF,
         open,
         lookahead=barmerge.lookahead_on)

    htfTime := request.security(
         syminfo.tickerid,
         selectedTF,
         time,
         lookahead=barmerge.lookahead_on)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DETECT NEW HTF PERIOD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bool newPeriod = validTF and ta.change(htfTime) != 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAWING OBJECTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var line openLine = na
var label openLabel = na

var int openStartBar = na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INITIALIZE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if validTF and na(openStartBar)

    openStartBar := bar_index

    openLine := line.new(
         x1=openStartBar,
         y1=htfOpen,
         x2=bar_index + rightOffset,
         y2=htfOpen,
         color=selectedColor,
         width=lineWidth)

    if showLabel
        openLabel := label.new(
             x=bar_index + rightOffset,
             y=htfOpen,
             text=selectedName,
             style=label.style_none,
             textcolor=selectedColor,
             size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NEW PERIOD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if newPeriod

    if not na(openLine)
        line.set_x2(
             openLine,
             bar_index - 1)

    openStartBar := bar_index

    openLine := line.new(
         x1=openStartBar,
         y1=htfOpen,
         x2=bar_index + rightOffset,
         y2=htfOpen,
         color=selectedColor,
         width=lineWidth)

    if showLabel

        if not na(openLabel)
            label.delete(openLabel)

        openLabel := label.new(
             x=bar_index + rightOffset,
             y=htfOpen,
             text=selectedName,
             style=label.style_none,
             textcolor=selectedColor,
             size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// UPDATE CURRENT OPEN
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if validTF and not na(openLine)

    line.set_x2(
         openLine,
         bar_index + rightOffset)

    line.set_y1(
         openLine,
         htfOpen)

    line.set_y2(
         openLine,
         htfOpen)

    line.set_color(
         openLine,
         selectedColor)

    line.set_width(
         openLine,
         lineWidth)

    if showLabel

        if na(openLabel)
            openLabel := label.new(
                 x=bar_index + rightOffset,
                 y=htfOpen,
                 text=selectedName,
                 style=label.style_none,
                 textcolor=selectedColor,
                 size=size.small)

        label.set_xy(
             openLabel,
             bar_index + rightOffset,
             htfOpen)

        label.set_text(
             openLabel,
             selectedName)

        label.set_textcolor(
             openLabel,
             selectedColor)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HIDE ON OTHER TIMEFRAMES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if not validTF

    if not na(openLine)
        line.delete(openLine)
        openLine := na

    if not na(openLabel)
        label.delete(openLabel)
        openLabel := na

    openStartBar := na
````
