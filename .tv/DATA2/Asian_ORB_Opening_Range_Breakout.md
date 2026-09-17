<!-- tradingview-pine-id: PUB;ecbf9f42bb444594b0a63ef6cfc3dc56 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Asian ORB - Opening Range Breakout

Source: https://www.tradingview.com/script/y1fLYYmF-Asian-ORB-Opening-Range-Breakout-With-Midpoint/

## Description

Asian ORB — Opening Range Breakout

This indicator calculates the opening range for the Asian trading session and plots the session high, low, midpoint, and range area on the chart.

By default, the Asian ORB begins at 8:00 PM New York time and measures the first 15 minutes of trading. The levels are then extended until 2:00 AM New York time.

The indicator includes:

Asian session high and low
Opening-range midpoint
Optional range shading
Long and short breakout labels
Breakout alerts
Custom session times
Custom colors and line styles
Support for futures such as MNQ, NQ, MES, ES, YM, and GC

A long signal appears when price closes above the Asian ORB high. A short signal appears when price closes below the Asian ORB low.

For stronger confirmation, combine the signals with VWAP, moving averages, liquidity levels, market structure, or your preferred trading strategy. This indicator is designed as a breakout tool and should not be used as a standalone trading system.

Recommended timeframe: 5-minute chart.

This script is for educational purposes only and does not constitute financial advice.

---

## Source Code

````pine
//@version=6
indicator("Asian ORB - Opening Range Breakout", "Asian ORB", overlay=true,
     max_lines_count=500, max_boxes_count=500, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Asian ORB Settings
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupSession = "Asian ORB Session"

timezoneInput = input.string(
     "America/New_York",
     "Session Time Zone",
     options=["America/New_York", "America/Chicago", "America/Los_Angeles", "UTC"],
     group=groupSession)

asiaStartHour = input.int(20, "Asian Session Start Hour", minval=0, maxval=23, group=groupSession)
asiaStartMin  = input.int(0, "Asian Session Start Minute", minval=0, maxval=59, group=groupSession)

rangeDuration = input.int(15, "Asian ORB Duration Minutes", minval=1, group=groupSession)

asiaEndHour = input.int(2, "Level Extension End Hour", minval=0, maxval=23, group=groupSession)
asiaEndMin  = input.int(0, "Level Extension End Minute", minval=0, maxval=59, group=groupSession)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Display Settings
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupDisplay = "Display Settings"

showAlerts      = input.bool(true, "Show Breakout Labels", group=groupDisplay)
showPriceLabels = input.bool(true, "Show Price Labels on Scale", group=groupDisplay)
showRangeFill   = input.bool(true, "Show Range Fill", group=groupDisplay)

fillColor = input.color(
     color.new(color.blue, 90),
     "Range Fill Color",
     group=groupDisplay)

highColor = input.color(
     color.new(color.aqua, 0),
     "Asian Range High Color",
     group=groupDisplay)

lowColor = input.color(
     color.new(color.aqua, 0),
     "Asian Range Low Color",
     group=groupDisplay)

highThickness = input.int(3, "Range High Thickness", minval=1, group=groupDisplay)
lowThickness  = input.int(3, "Range Low Thickness", minval=1, group=groupDisplay)

showMid = input.bool(true, "Show Range Midpoint", group=groupDisplay)

midColor = input.color(
     color.new(color.yellow, 20),
     "Range Mid Color",
     group=groupDisplay)

midThickness = input.int(2, "Range Mid Thickness", minval=1, group=groupDisplay)

midStyle = input.string(
     "Dashed",
     "Range Mid Style",
     options=["Solid", "Dashed", "Dotted"],
     group=groupDisplay)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Build Asian Session Times
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Today's Asian session start
todayStart = timestamp(
     timezoneInput,
     year,
     month,
     dayofmonth,
     asiaStartHour,
     asiaStartMin)

// Yesterday's Asian session start
yesterdayStart = timestamp(
     timezoneInput,
     year,
     month,
     dayofmonth - 1,
     asiaStartHour,
     asiaStartMin)

// If current time is before today's Asian open,
// use yesterday's session as the active session.
activeSessionStart = time >= todayStart ? todayStart : yesterdayStart

sessionEndTime = activeSessionStart + rangeDuration * 60 * 1000

// Extension end time
sessionCloseTime = timestamp(
     timezoneInput,
     year(activeSessionStart),
     month(activeSessionStart),
     dayofmonth(activeSessionStart),
     asiaEndHour,
     asiaEndMin)

// If the extension end is technically before the session start,
// move it to the following day.
sessionCloseTime := sessionCloseTime <= activeSessionStart ?
     sessionCloseTime + 24 * 60 * 60 * 1000 :
     sessionCloseTime

newAsianSession = na(activeSessionStart[1]) or
     activeSessionStart != activeSessionStart[1]

isInOpeningRange =
     time >= activeSessionStart and
     time < sessionEndTime

isOpeningRangeEnd =
     isInOpeningRange[1] and not isInOpeningRange

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Variables
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float openingHigh = na
var float openingLow  = na
var float openingMid  = na

var int highBarTime = na
var int lowBarTime  = na

var line highRay = na
var line lowRay  = na
var line midRay  = na

var box rangeBox = na
var label breakoutLabel = na
var label missingLabel = na

var bool longTriggered  = false
var bool shortTriggered = false

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Reset for New Asian Session
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if newAsianSession
    openingHigh := na
    openingLow  := na
    openingMid  := na

    highBarTime := na
    lowBarTime  := na

    longTriggered  := false
    shortTriggered := false

    highRay := na
    lowRay  := na
    midRay  := na

    rangeBox := na
    breakoutLabel := na
    missingLabel := na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Capture Asian Opening Range
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if isInOpeningRange
    if na(openingHigh) or high > openingHigh
        openingHigh := high
        highBarTime := time

    if na(openingLow) or low < openingLow
        openingLow := low
        lowBarTime := time

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Draw Asian ORB Levels
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if isOpeningRangeEnd
    if na(openingHigh) or na(openingLow)
        missingLabel := label.new(
             bar_index,
             high,
             "Missing Asian ORB Data",
             color=color.red,
             textcolor=color.white,
             style=label.style_label_down)

    if not na(openingHigh)
        highRay := line.new(
             highBarTime,
             openingHigh,
             sessionCloseTime,
             openingHigh,
             xloc=xloc.bar_time,
             color=highColor,
             width=highThickness)

    if not na(openingLow)
        lowRay := line.new(
             lowBarTime,
             openingLow,
             sessionCloseTime,
             openingLow,
             xloc=xloc.bar_time,
             color=lowColor,
             width=lowThickness)

    if showMid and not na(openingHigh) and not na(openingLow)
        openingMid := (openingHigh + openingLow) / 2

        midLineStyle =
             midStyle == "Solid" ?
             line.style_solid :
             midStyle == "Dotted" ?
             line.style_dotted :
             line.style_dashed

        midRay := line.new(
             activeSessionStart,
             openingMid,
             sessionCloseTime,
             openingMid,
             xloc=xloc.bar_time,
             color=midColor,
             width=midThickness,
             style=midLineStyle)

    if showRangeFill and not na(openingHigh) and not na(openingLow)
        rangeBox := box.new(
             left=activeSessionStart,
             top=openingHigh,
             right=sessionCloseTime,
             bottom=openingLow,
             xloc=xloc.bar_time,
             bgcolor=fillColor,
             border_width=0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Price Scale Labels
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plotHigh =
     showPriceLabels and not na(openingHigh) and barstate.islast ?
     openingHigh :
     na

plotLow =
     showPriceLabels and not na(openingLow) and barstate.islast ?
     openingLow :
     na

plotMid =
     showPriceLabels and showMid and not na(openingMid) and barstate.islast ?
     openingMid :
     na

plot(
     plotHigh,
     title="Asian ORB High",
     color=color.new(highColor, 95),
     linewidth=1,
     show_last=1)

plot(
     plotLow,
     title="Asian ORB Low",
     color=color.new(lowColor, 95),
     linewidth=1,
     show_last=1)

plot(
     plotMid,
     title="Asian ORB Midpoint",
     color=color.new(midColor, 95),
     linewidth=1,
     show_last=1)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Breakout Detection
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
longBreakoutSignal =
     not na(openingHigh) and close > openingHigh

shortBreakoutSignal =
     not na(openingLow) and close < openingLow

bool longBreakout = false
bool shortBreakout = false

afterOpeningRange =
     time >= sessionEndTime and
     time <= sessionCloseTime

if afterOpeningRange and barstate.isconfirmed
    if longBreakoutSignal and not longTriggered
        longTriggered := true
        shortTriggered := false
        longBreakout := true

        if showAlerts
            breakoutLabel := label.new(
                 bar_index,
                 openingHigh,
                 "ASIA LONG",
                 color=color.green,
                 textcolor=color.white,
                 style=label.style_label_right,
                 size=size.large)

    if shortBreakoutSignal and not shortTriggered
        shortTriggered := true
        longTriggered := false
        shortBreakout := true

        if showAlerts
            breakoutLabel := label.new(
                 bar_index,
                 openingLow,
                 "ASIA SHORT",
                 color=color.red,
                 textcolor=color.white,
                 style=label.style_label_right,
                 size=size.large)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alerts
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(
     longBreakout,
     title="Asian ORB Long Breakout",
     message="Asian ORB LONG breakout at {{close}}")

alertcondition(
     shortBreakout,
     title="Asian ORB Short Breakout",
     message="Asian ORB SHORT breakout at {{close}}")
````
