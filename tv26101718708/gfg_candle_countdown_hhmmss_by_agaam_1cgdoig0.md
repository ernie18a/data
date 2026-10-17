# GFG Candle Countdown HH:MM:SS by Agaam

- url: https://www.tradingview.com/script/1Cgdoig0-GFG-Candle-Countdown-HH-MM-SS-by-Agaam/
- type: indicator
- pine_id: PUB;20301082bde6471a85d4203d8ff25ac0
- version: 1.0

## Description

## GFG Candle Countdown HH:MM:SS

**GFG Candle Countdown HH:MM:SS** is a clean chart utility that displays the remaining time before the current candle closes in **hours:minutes:seconds** format.

The purpose of this script is to help traders clearly see how much time is left in the active candle without adding signals, arrows, chart labels, or extra visual clutter. The countdown is displayed in a simple table on the top-right side of the chart and can be moved lower using the vertical offset settings.

## What This Indicator Does

This indicator calculates the remaining time until the current candle closes by comparing the candle’s close time with the current real-time clock. The result is displayed in this format:

**HH:MM:SS**

For example:

**01:24:35**

means there is 1 hour, 24 minutes, and 35 seconds left before the current candle closes.

This version is useful not only for short intraday charts, but also for higher timeframes where candles may have more than one hour remaining.

## Why This Script Is Useful

Many traders prefer to wait for candle close confirmation before making a decision. This script helps make candle timing easier to see directly on the chart.

It can be useful for:

* Waiting for candle close confirmation
* Monitoring higher-timeframe candle closes
* Avoiding early entries before a candle is finished
* Managing trades around candle close
* Watching active bars without cluttering the chart
* Keeping timing visible while focusing on price action

## Clean Chart Design

This indicator is intentionally simple. It does not generate buy signals, sell signals, trend signals, alerts, arrows, or candle labels.

It only displays the candle countdown timer.

The visual layout is designed to stay clean:

* Right-side table display
* Only HH:MM:SS numbers
* No extra words on the chart
* Adjustable size
* Adjustable cell width and height
* Adjustable vertical position
* Custom background color
* Custom number color

This keeps the chart clean while still giving the trader important timing information.

## Warning Color Option

The script includes optional warning colors for traders who want the countdown to visually change as the candle gets closer to closing.

Users can customize:

* Warning color
* Danger color
* Warning seconds threshold
* Danger seconds threshold

For example, the countdown can turn yellow when fewer than 30 seconds remain and red when fewer than 10 seconds remain.

This feature is optional and can be turned off for a simple one-color timer.

## Customization

Users can adjust:

* Show or hide the countdown
* Countdown text size
* Countdown cell width
* Countdown cell height
* Vertical offset rows
* Offset row height
* Background color
* Countdown number color
* Warning color
* Danger color
* Warning and danger timing levels

These settings allow the timer to be positioned and styled to fit different chart layouts.

## How Traders Can Use It

A simple way to use this indicator:

1. Add it to the chart.
2. Place the countdown where it is easy to see.
3. Watch the remaining candle time before making candle-close-based decisions.
4. Use it as a timing tool together with your own trading plan.

This script does not predict price direction. It is only designed to show candle time remaining.

## Important Notes

The countdown works on time-based charts where candle close time is available. On chart types where candle close time is not available, the script may display **N/A**.

The countdown is based on the chart’s active candle close time and updates on the latest bar.

## Disclaimer

This indicator is for educational and informational purposes only. It is not financial advice, investment advice, or a guaranteed trading system. Trading involves risk, and every trader is responsible for their own decisions.

## Source Code

````pine
//@version=5
indicator("GFG Candle Countdown HH:MM:SS by Agaam", overlay=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupMain = "Countdown"

showCountdown = input.bool(true, "Show Countdown", group=groupMain)
countdownSizeInput = input.string("Large", "Countdown Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=groupMain)

cellWidth = input.float(10.0, "Countdown Cell Width", minval=2.0, maxval=30.0, step=0.5, group=groupMain)
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
// COUNTDOWN LOGIC — HH:MM:SS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

isTimeChart = not na(time_close)

remainingMsRaw = isTimeChart ? time_close - timenow : 0
remainingMs = math.max(remainingMsRaw, 0)
remainingSeconds = int(math.floor(remainingMs / 1000.0))

hoursLeft = int(math.floor(remainingSeconds / 3600.0))
minutesLeft = int(math.floor((remainingSeconds % 3600) / 60.0))
secondsLeft = remainingSeconds % 60

countdownText = isTimeChart ? f_twoDigits(hoursLeft) + ":" + f_twoDigits(minutesLeft) + ":" + f_twoDigits(secondsLeft) : "N/A"
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
// No candle label. No words. Only HH:MM:SS.
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
