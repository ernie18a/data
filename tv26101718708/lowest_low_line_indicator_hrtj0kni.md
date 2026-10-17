# Lowest Low Line Indicator

- url: https://www.tradingview.com/script/HRTj0KNI/
- type: indicator
- pine_id: PUB;eaf5e87a2dd64028b380d0a6b1fc640e
- version: 3.0

## Description

Lowest Low Line Indicator

This indicator plots a line on the chart to highlight the lowest low value within a specified look-back period. The line is updated in real-time as new bars form, and it is deleted and recreated when a new lower low is found.

Key Features:

Plots a line from the lowest low value to the current bar
Updates the line in real-time as new bars form
Deletes and recreates the line when a new lower low is found
Displays a label beside the line with the lowest value
Allows the user to specify the look-back period (default is 1000 bars)
Line color is blue, and the line width is adjustable (default is 4)


Use Cases:

Identifying support levels: The lowest low line can be used to identify potential support levels in the market.
Confirming trends: The line can be used to confirm the direction of a trend by looking for higher highs or lower lows.
Setting stop-loss levels: The line can be used to set stop-loss levels based on the lowest low value.

## Source Code

````pine
//@version=6
indicator("Lowest Low Line + Smart Alerts", overlay=true)

//════════════════════════════════════════════════════════════
// INPUT
//════════════════════════════════════════════════════════════

length = input.int(1000, title="Look-back period", minval=1)


//════════════════════════════════════════════════════════════
// VARIABLES
//════════════════════════════════════════════════════════════

var float lowestLow = na
var line lowestLine = na
var label lowestLabel = na


//════════════════════════════════════════════════════════════
// LOWEST LOW CALCULATION
//════════════════════════════════════════════════════════════

lowestLowValue = ta.lowest(low, length)
lowestLowIndex = ta.lowestbars(low, length)


//════════════════════════════════════════════════════════════
// CASE 1
// NEW LOW BELOW PREVIOUSLY DETECTED LOW
//════════════════════════════════════════════════════════════

newLowestLow = lowestLowIndex == 0 and (na(lowestLow) or low < lowestLow)


//════════════════════════════════════════════════════════════
// SAVE THE PREVIOUS LINE VALUE BEFORE UPDATING
//════════════════════════════════════════════════════════════

previousLowestLow = lowestLowValue


//════════════════════════════════════════════════════════════
// UPDATE LOWEST LOW LINE
//════════════════════════════════════════════════════════════

if newLowestLow

    if not na(lowestLine)
        line.delete(lowestLine)

    if not na(lowestLabel)
        label.delete(lowestLabel)

    lowestLow := low

    lowestLine := line.new(
         bar_index - length + 1,
         lowestLow,
         bar_index,
         lowestLow,
         extend=extend.none,
         color=color.blue,
         style=line.style_dashed,
         width=4)

    lowestLabel := label.new(
         bar_index,
         lowestLow,
         text=str.tostring(lowestLow),
         yloc=yloc.belowbar,
         color=color.blue,
         style=label.style_label_up)

else

    if not na(lowestLine)

        line.set_xy1(
             lowestLine,
             bar_index - length + 1,
             lowestLowValue)

        line.set_xy2(
             lowestLine,
             bar_index,
             lowestLowValue)

        line.set_color(
             lowestLine,
             color.blue)

        line.set_width(
             lowestLine,
             4)

        line.set_style(
             lowestLine,
             line.style_dashed)

    if not na(lowestLabel)

        label.set_xy(
             lowestLabel,
             bar_index,
             lowestLowValue)

        label.set_text(
             lowestLabel,
             str.tostring(lowestLowValue))


//════════════════════════════════════════════════════════════
// CURRENT BLUE LINE
//════════════════════════════════════════════════════════════

currentLowestLine = lowestLowValue


//════════════════════════════════════════════════════════════
// CASE 2
// TOUCH LOWEST-LOW LINE
//
// Price reaches the blue line but does NOT go below it.
//════════════════════════════════════════════════════════════

touchLowestLine =
     not newLowestLow and
     not na(currentLowestLine) and
     low <= currentLowestLine and
     low >= currentLowestLine


//════════════════════════════════════════════════════════════
// CASE 3
// BREAK BELOW LOWEST-LOW LINE
//
// Price moves below the blue line.
//════════════════════════════════════════════════════════════

breakBelowLowestLine =
     not newLowestLow and
     not na(currentLowestLine) and
     low < currentLowestLine


//════════════════════════════════════════════════════════════
// DETERMINE WHICH CASE OCCURRED
//════════════════════════════════════════════════════════════

caseNumber = 
     newLowestLow ? 1 :
     breakBelowLowestLine ? 3 :
     touchLowestLine ? 2 :
     0


//════════════════════════════════════════════════════════════
// DYNAMIC ALERT MESSAGE
//════════════════════════════════════════════════════════════

if caseNumber > 0

    string alertMessage = ""

    if caseNumber == 1
        alertMessage :=
             "CASE 1 - NEW LOWEST LOW\n" +
             "Symbol: " + syminfo.ticker + "\n" +
             "Price: " + str.tostring(close) + "\n" +
             "Lowest Low: " + str.tostring(low) + "\n" +
             "Time: " + str.tostring(time)

    else if caseNumber == 2
        alertMessage :=
             "CASE 2 - TOUCH LOWEST-LOW LINE\n" +
             "Symbol: " + syminfo.ticker + "\n" +
             "Price: " + str.tostring(close) + "\n" +
             "Lowest-Low Line: " + str.tostring(currentLowestLine) + "\n" +
             "Time: " + str.tostring(time)

    else if caseNumber == 3
        alertMessage :=
             "CASE 3 - BREAK BELOW LOWEST-LOW LINE\n" +
             "Symbol: " + syminfo.ticker + "\n" +
             "Price: " + str.tostring(close) + "\n" +
             "Lowest-Low Line: " + str.tostring(currentLowestLine) + "\n" +
             "Time: " + str.tostring(time)

    alert(alertMessage, alert.freq_once_per_bar)


//════════════════════════════════════════════════════════════
// OPTIONAL ALERT CONDITION
//════════════════════════════════════════════════════════════

anyLowestLowEvent =
     caseNumber > 0

alertcondition(
     anyLowestLowEvent,
     title="Lowest Low Event",
     message="Lowest Low event detected. Open the indicator alert using 'Any alert() function call' for the detailed Case 1, Case 2, or Case 3 message.")
````
