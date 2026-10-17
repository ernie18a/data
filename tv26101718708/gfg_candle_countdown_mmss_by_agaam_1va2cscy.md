# GFG Candle Countdown MM:SS by Agaam

- url: https://www.tradingview.com/script/1va2CScy-GFG-Candle-Countdown-MM-SS-by-Agaam/
- type: indicator
- pine_id: PUB;1bbbc848d23046efa430296da77d45fc
- version: 1.0

## Description

## GFG Candle Countdown MM:SS

**GFG Candle Countdown MM:SS** is a clean chart utility that displays the remaining time of the current candle in a simple **minutes:seconds** format.

The purpose of this script is to help traders quickly see how much time is left before the current candle closes without adding extra labels, signals, arrows, or unnecessary chart clutter. The countdown is displayed in a table on the top-right side of the chart and can be moved lower using the vertical offset settings.

## What This Indicator Does

This indicator calculates the time remaining until the current candle closes by comparing the candle close time with the current real-time clock. The result is shown as a simple countdown in this format:

**MM:SS**

For example:

**02:45**
means there are 2 minutes and 45 seconds left before the current candle closes.

## Why This Script Is Useful

Many traders make decisions near candle close, especially when waiting for confirmation from the current bar. This countdown helps traders see the remaining candle time clearly without needing to look away from the chart.

It can be useful for:

* Waiting for candle close confirmation
* Managing entries near the end of a bar
* Avoiding rushed decisions before a candle finishes
* Monitoring short timeframes during active trading
* Keeping the chart clean while still showing important timing information

## Clean Chart Design

This script is intentionally simple. It does not print candle labels, buy signals, sell signals, trend signals, or extra text. It only shows the countdown timer.

The visual design is meant to stay clean and easy to read:

* Right-side table display
* Only MM:SS text
* Adjustable size
* Adjustable cell width and height
* Adjustable vertical position
* Custom background color
* Custom number color

## Warning Color Option

The indicator includes optional warning colors for traders who want the countdown to change color as the candle gets close to closing.

Users can set:

* Warning color
* Danger color
* Warning seconds
* Danger seconds

For example, the countdown can turn yellow when less than 30 seconds remain and red when less than 10 seconds remain.

This feature is optional and can be turned off for a simple one-color countdown.

## Customization

Users can customize:

* Show or hide the countdown
* Countdown text size
* Table cell width
* Table cell height
* Vertical offset position
* Background color
* Countdown number color
* Warning and danger colors
* Warning and danger timing thresholds

These options allow traders to place the countdown where it fits best on their chart layout.

## Important Notes

This script is a timing utility only. It does not predict price direction, generate trade signals, or provide buy/sell recommendations.

The countdown works on time-based charts where candle close time is available. On chart types where candle close time is not available, the script may display **N/A**.

## Disclaimer

This indicator is for educational and informational purposes only. It is not financial advice and does not guarantee trading results. Trading involves risk, and every trader is responsible for their own decisions.

## Source Code

````pine
//@version=5
indicator("GFG Candle Countdown MM:SS by Agaam", overlay=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupMain = "Countdown"

showCountdown = input.bool(true, "Show Countdown", group=groupMain)
countdownSizeInput = input.string("Large", "Countdown Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=groupMain)

cellWidth = input.float(8.0, "Countdown Cell Width", minval=2.0, maxval=25.0, step=0.5, group=groupMain)
cellHeight = input.float(3.0, "Countdown Cell Height", minval=1.0, maxval=15.0, step=0.5, group=groupMain)

verticalOffsetRows = input.int(9, "Vertical Offset Rows Down", minval=0, maxval=50, group=groupMain)
offsetRowHeight = input.float(2.2, "Offset Row Height", minval=0.1, maxval=10.0, step=0.1, group=groupMain)

groupColors = "Colors"

bgColor = input.color(color.rgb(20, 20, 20), "Background Color", group=groupColors)
numberTextColor = input.color(color.white, "Countdown Numbers Color", group=groupColors)

useWarningColors = input.bool(false, "Use Warning Colors", group=groupColors)
warningColor = input.color(color.yellow, "Warning Color", group=groupColors)
dangerColor = input.color(color.red, "Danger Color", group=groupColors)
warningSeconds = input.int(30, "Warning Under Seconds", minval=1, maxval=300, group=groupColors)
dangerSeconds = input.int(10, "Danger Under Seconds", minval=1, maxval=300, group=groupColors)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_size(_s) =>
    result = size.normal
    if _s == "Tiny"
        result := size.tiny
    else if _s == "Small"
        result := size.small
    else if _s == "Normal"
        result := size.normal
    else if _s == "Large"
        result := size.large
    else
        result := size.huge
    result

f_twoDigits(_n) =>
    _n < 10 ? "0" + str.tostring(_n) : str.tostring(_n)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COUNTDOWN LOGIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

isTimeChart = not na(time_close)

remainingMsRaw = isTimeChart ? time_close - timenow : 0
remainingMs = math.max(remainingMsRaw, 0)
remainingSeconds = int(math.floor(remainingMs / 1000.0))

minutesLeft = int(math.floor(remainingSeconds / 60.0))
secondsLeft = remainingSeconds % 60

countdownText = isTimeChart ? f_twoDigits(minutesLeft) + ":" + f_twoDigits(secondsLeft) : "N/A"
countdownSize = f_size(countdownSizeInput)

color finalTextColor = numberTextColor

if useWarningColors and isTimeChart
    if remainingSeconds <= dangerSeconds
        finalTextColor := dangerColor
    else if remainingSeconds <= warningSeconds
        finalTextColor := warningColor
    else
        finalTextColor := numberTextColor

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RIGHT SIDE COUNTDOWN WITH LOWER OFFSET
// No candle label. No words. Only MM:SS.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table countdownTable = table.new(position.top_right, 1, 51, border_width=0)

if barstate.islast
    for r = 0 to 50
        if showCountdown and r < verticalOffsetRows
            table.cell(countdownTable, 0, r, "", text_color=color.new(numberTextColor, 100), bgcolor=color.new(bgColor, 100), text_size=countdownSize, width=cellWidth, height=offsetRowHeight)
        else if showCountdown and r == verticalOffsetRows
            table.cell(countdownTable, 0, r, countdownText, text_color=finalTextColor, bgcolor=bgColor, text_size=countdownSize, width=cellWidth, height=cellHeight)
        else
            table.cell(countdownTable, 0, r, "", text_color=color.new(numberTextColor, 100), bgcolor=color.new(bgColor, 100), text_size=countdownSize, width=cellWidth, height=0.01)
````
