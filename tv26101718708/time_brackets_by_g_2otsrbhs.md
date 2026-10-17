# Time Brackets by G

- url: https://www.tradingview.com/script/2otsRbhS-Time-Brackets-by-G/
- type: indicator
- pine_id: PUB;eb9309e800844a16951a4d0342889b10
- version: 1.0

## Description

Time Brackets

Time Brackets highlights up to 8 configurable time-of-day windows directly on the chart, drawing a bracket around the price action inside each window and marking its highest high.

How it works

Define up to 8 independent "brackets," each with its own start/end minute (0–59), based on the Europe/Zurich timezone.
Each bracket can wrap across the hour (e.g., 59 → 00), so windows that span an hour boundary work correctly.
When a bracket's end minute is reached, the indicator scans back through the window, finds the highest high, and draws:
A horizontal line across the top of the bracket, offset above the high by a user-defined multiple of ATR
Dotted vertical lines marking the left and right edges of the window
A label showing the bracket's start and end minutes (e.g., "41 (44)")
Any bracket can be flagged "Special," rendering it in a distinct color to highlight higher-priority windows.

Customization

Toggle brackets, top lines, vertical lines, and labels independently
Adjust line width, label size, ATR length, and vertical offset
Set custom normal/special colors
Enable/disable each of the 8 brackets and set its own start/end minute and color mode

Use case
Useful for traders who track recurring intraday time windows (e.g., session opens, common reversal minutes, or model-specific timing windows) and want an automatic visual marker of the price range and high formed during each window, without manually drawing boxes every session.

Note: Drawing objects are limited to 500 lines and 500 labels; older brackets will be pruned by TradingView as new ones are drawn.
[url=https://www.tradingview.com/x/FyjGrHM7/]https://www.tradingview.com/x/FyjGrHM7/[/url]

## Source Code

````pine
//@version=6
indicator("Time Brackets", overlay=true, max_lines_count=500, max_labels_count=500)

//=============================================================================
// TIMEZONE
//=============================================================================

string TZ = "Europe/Zurich"

//=============================================================================
// GENERAL SETTINGS
//=============================================================================

groupGeneral = "General"

showBrackets = input.bool(true, "Show Brackets", group=groupGeneral)

showTopLine = input.bool(true, "Show Top Line", group=groupGeneral)

showVerticalLines = input.bool(true, "Show Vertical Lines", group=groupGeneral)

showLabels = input.bool(true, "Show Labels", group=groupGeneral)

lineWidth = input.int(
     1,
     "Line Width",
     minval=1,
     maxval=4,
     group=groupGeneral
)

verticalOffsetATR = input.float(
     0.30,
     "Distance Above High (ATR)",
     minval=0.0,
     step=0.05,
     group=groupGeneral
)

atrLength = input.int(
     14,
     "ATR Length",
     minval=1,
     group=groupGeneral
)

normalColor = input.color(
     color.gray,
     "Normal Bracket Color",
     group=groupGeneral
)

specialColor = input.color(
     color.red,
     "Special Bracket Color",
     group=groupGeneral
)

labelSizeInput = input.string(
     "Small",
     "Label Size",
     options=["Tiny", "Small", "Normal"],
     group=groupGeneral
)


//=============================================================================
// LABEL SIZE
//=============================================================================

labelSize = switch labelSizeInput
    "Tiny"   => size.tiny
    "Normal" => size.normal
    => size.small


//=============================================================================
// BRACKET 1
//=============================================================================

group1 = "Bracket 1"

enable1 = input.bool(true, "Enable", group=group1)

start1 = input.int(
     41,
     "Start Minute",
     minval=0,
     maxval=59,
     group=group1
)

end1 = input.int(
     44,
     "End Minute",
     minval=0,
     maxval=59,
     group=group1
)

special1 = input.bool(false, "Use Special Color", group=group1)


//=============================================================================
// BRACKET 2
//=============================================================================

group2 = "Bracket 2"

enable2 = input.bool(true, "Enable", group=group2)

start2 = input.int(
     11,
     "Start Minute",
     minval=0,
     maxval=59,
     group=group2
)

end2 = input.int(
     14,
     "End Minute",
     minval=0,
     maxval=59,
     group=group2
)

special2 = input.bool(false, "Use Special Color", group=group2)


//=============================================================================
// BRACKET 3
//=============================================================================

group3 = "Bracket 3"

enable3 = input.bool(true, "Enable", group=group3)

start3 = input.int(
     17,
     "Start Minute",
     minval=0,
     maxval=59,
     group=group3
)

end3 = input.int(
     23,
     "End Minute",
     minval=0,
     maxval=59,
     group=group3
)

special3 = input.bool(false, "Use Special Color", group=group3)


//=============================================================================
// BRACKET 4
//=============================================================================

group4 = "Bracket 4"

enable4 = input.bool(true, "Enable", group=group4)

start4 = input.int(
     29,
     "Start Minute",
     minval=0,
     maxval=59,
     group=group4
)

end4 = input.int(
     35,
     "End Minute",
     minval=0,
     maxval=59,
     group=group4
)

special4 = input.bool(true, "Use Special Color", group=group4)


//=============================================================================
// BRACKET 5
//=============================================================================

group5 = "Bracket 5"

enable5 = input.bool(true, "Enable", group=group5)

start5 = input.int(
     3,
     "Start Minute",
     minval=0,
     maxval=59,
     group=group5
)

end5 = input.int(
     7,
     "End Minute",
     minval=0,
     maxval=59,
     group=group5
)

special5 = input.bool(true, "Use Special Color", group=group5)


//=============================================================================
// BRACKET 6
//=============================================================================

group6 = "Bracket 6"

enable6 = input.bool(true, "Enable", group=group6)

start6 = input.int(
     50,
     "Start Minute",
     minval=0,
     maxval=59,
     group=group6
)

end6 = input.int(
     56,
     "End Minute",
     minval=0,
     maxval=59,
     group=group6
)

special6 = input.bool(false, "Use Special Color", group=group6)


//=============================================================================
// BRACKET 7
//=============================================================================

group7 = "Bracket 7"

enable7 = input.bool(false, "Enable", group=group7)

start7 = input.int(
     59,
     "Start Minute",
     minval=0,
     maxval=59,
     group=group7
)

end7 = input.int(
     0,
     "End Minute",
     minval=0,
     maxval=59,
     group=group7
)

special7 = input.bool(true, "Use Special Color", group=group7)


//=============================================================================
// BRACKET 8
//=============================================================================

group8 = "Bracket 8"

enable8 = input.bool(false, "Enable", group=group8)

start8 = input.int(
     0,
     "Start Minute",
     minval=0,
     maxval=59,
     group=group8
)

end8 = input.int(
     3,
     "End Minute",
     minval=0,
     maxval=59,
     group=group8
)

special8 = input.bool(false, "Use Special Color", group=group8)


//=============================================================================
// CALCULATIONS
//=============================================================================

atr = ta.atr(atrLength)

zurichMinute = minute(time, TZ)
zurichHour = hour(time, TZ)


//=============================================================================
// BRACKET FUNCTION
//=============================================================================
//
// The function checks whether the current candle is the END candle.
// If yes, it looks backward through the bracket and finds the highest high.
//
// This works for:
//     41 -> 44
//     11 -> 14
//     17 -> 23
//     03 -> 07
//     50 -> 56
//     59 -> 00
//
//=============================================================================

drawBracket(
     bool enabled,
     int startMinute,
     int endMinute,
     bool isSpecial
     ) =>

    // Number of minutes contained in the bracket.
    int duration = endMinute >= startMinute ?
         endMinute - startMinute :
         (60 - startMinute) + endMinute

    // The end candle is where we finalize the bracket.
    bool isEnd = enabled and zurichMinute == endMinute

    if showBrackets and isEnd and bar_index >= duration

        //------------------------------------------------------------------------
        // Find highest high inside the bracket
        //------------------------------------------------------------------------

        float bracketHigh = high

        for i = 0 to duration
            bracketHigh := math.max(bracketHigh, high[i])

        //------------------------------------------------------------------------
        // Bracket coordinates
        //------------------------------------------------------------------------

        int leftBar = bar_index - duration
        int rightBar = bar_index

        float bracketY = bracketHigh + atr * verticalOffsetATR

        //------------------------------------------------------------------------
        // Color
        //------------------------------------------------------------------------

        color bracketColor = isSpecial ? specialColor : normalColor

        //------------------------------------------------------------------------
        // Top horizontal line
        //------------------------------------------------------------------------

        if showTopLine
            line.new(
                 x1=leftBar,
                 y1=bracketY,
                 x2=rightBar,
                 y2=bracketY,
                 xloc=xloc.bar_index,
                 color=bracketColor,
                 width=lineWidth
            )

        //------------------------------------------------------------------------
        // Left vertical dotted line
        //------------------------------------------------------------------------

        if showVerticalLines
            line.new(
                 x1=leftBar,
                 y1=high[duration],
                 x2=leftBar,
                 y2=bracketY,
                 xloc=xloc.bar_index,
                 color=bracketColor,
                 width=lineWidth,
                 style=line.style_dotted
            )

            //------------------------------------------------------------------------
            // Right vertical dotted line
            //------------------------------------------------------------------------

            line.new(
                 x1=rightBar,
                 y1=high,
                 x2=rightBar,
                 y2=bracketY,
                 xloc=xloc.bar_index,
                 color=bracketColor,
                 width=lineWidth,
                 style=line.style_dotted
            )

        //------------------------------------------------------------------------
        // Automatic label
        //------------------------------------------------------------------------

        if showLabels

            string startText = startMinute < 10 ?
                 "0" + str.tostring(startMinute) :
                 str.tostring(startMinute)

            string endText = endMinute < 10 ?
                 "0" + str.tostring(endMinute) :
                 str.tostring(endMinute)

            string bracketText =
                 startText + " (" + endText + ")"

            int centerBar =
                 leftBar + int(math.round(duration / 2.0))

            label.new(
                 x=centerBar,
                 y=bracketY,
                 text=bracketText,
                 xloc=xloc.bar_index,
                 yloc=yloc.price,
                 style=label.style_label_down,
                 textcolor=bracketColor,
                 color=color.new(bracketColor, 100),
                 size=labelSize
            )


//=============================================================================
// DRAW ALL BRACKETS
//=============================================================================

drawBracket(enable1, start1, end1, special1)

drawBracket(enable2, start2, end2, special2)

drawBracket(enable3, start3, end3, special3)

drawBracket(enable4, start4, end4, special4)

drawBracket(enable5, start5, end5, special5)

drawBracket(enable6, start6, end6, special6)

drawBracket(enable7, start7, end7, special7)

drawBracket(enable8, start8, end8, special8)
````
