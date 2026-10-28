# STOC - Adaptive Opening Range Breakout

- url: https://www.tradingview.com/script/n2ek5IqR-STOC-Adaptive-Opening-Range-Breakout/
- type: indicator
- pine_id: PUB;7a030c3c35d14fb8a7a90fbb16f54a66
- version: 1.0

## Description

[b]STOC Adaptive ORB[/b] is an Opening Range Breakout indicator designed to automatically build the opening range based on the active chart, market timing, and selected timeframe.

The indicator identifies the market’s opening range, plots the ORB high, ORB low, midpoint, breakout levels, and projected bullish/bearish targets. It is built for traders who want a clean, rule-based view of intraday breakout structure without manually adjusting the ORB session every time they switch symbols or timeframes.

[b]Key Features[/b]

[b]Adaptive Opening Range[/b]

The indicator automatically detects the market/session logic and builds the ORB from the opening period. It can be used across crypto, Indian markets, US stocks, and custom sessions.

[b]Timeframe-Based ORB Length[/b]

The ORB duration adapts based on the chart timeframe. Lower timeframes use shorter ORB periods, while higher intraday timeframes use wider ORB windows.

[b]Bullish and Bearish Breakout Detection[/b]

The indicator highlights when price breaks above the ORB high or below the ORB low.

[b]Target Projection[/b]

The dashboard displays projected target values:

Bull T1, T2, T3
Bear T1, T2, T3

Targets are calculated using the opening range size as the base.

[b]Clean Dashboard[/b]

The dashboard shows:

Market mode
Timezone
Open time
ORB length
ORB range
Bullish target values
Bearish target values
Bull breakout rate
Bear breakout rate

Visual ORB Zone

The opening range is clearly marked on the chart with a filled range box, making it easier to identify the breakout zone.

Multi-Market Use

[b]Suitable for:[/b]
Crypto
NSE / BSE
US stocks
London market
Custom open sessions

[b]How to Use[/b]

Use the ORB high and ORB low as the main breakout levels.

A bullish breakout happens when price moves above the ORB high.

A bearish breakout happens when price moves below the ORB low.

Bullish targets are plotted above the ORB high. Bearish targets are plotted below the ORB low.

The indicator is best used with additional confirmation such as trend, volume, VWAP, CPR, or higher-timeframe market structure.

[b]Suggested Use Cases[/b]
Intraday breakout trading
Crypto session breakout tracking
Stock market opening range analysis
Backtesting ORB behavior across symbols
Identifying high-probability breakout zones
Tracking target levels after an ORB breakout
Best Timeframes

[b]Recommended timeframes:[/b]

5m
15m
30m
1H

For crypto, it can also be used on 2H or 4H charts with wider ORB logic.

[b]Disclaimer[/b]

This indicator is the intellectual property of Systematic Traders Official Club.Distribution, modification, or commercial use without permission is prohibited.

This indicator is provided for educational and informational purposes only. It does not constitute financial advice, investment recommendations, or trade signals.

The creator and Systematic Traders Official Club are not responsible for any financial losses resulting from the use of this indicator. Trading involves risk, and users should do their own research before making any trading decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BoobeshDasarath93

// This Pine Script® code is an original adaptive ORB implementation
// built for Systematic Traders Official Club.
// Inspired by the user-provided ORB reference concept.

//@version=6
indicator("STOC - Adaptive Opening Range Breakout", shorttitle = "STOC - Adaptive ORB", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 100)

//────────────────────────────────────
// INPUTS
//────────────────────────────────────
grpCore = "Core Settings"
modeMarket = input.string(
     defval = "Auto",
     title = "Market Open Mode",
     options = ["Auto", "NSE / BSE", "US Stocks", "Crypto", "London", "Custom"],
     group = grpCore
)

useExchangeTimezone = input.bool(true, "Use Exchange Timezone", group = grpCore)
customTimezone = input.string(
     "Asia/Kolkata",
     "Custom Timezone",
     options = [
         "Asia/Kolkata",
         "America/New_York",
         "Europe/London",
         "Etc/UTC",
         "Asia/Dubai",
         "Asia/Singapore",
         "Asia/Tokyo",
         "Australia/Sydney"
     ],
     group = grpCore
)

autoOrbLength = input.bool(true, "Auto ORB Length Based On Chart Timeframe", group = grpCore)
manualOrbMinutes = input.int(15, "Manual ORB Length Minutes", minval = 1, maxval = 240, group = grpCore)

customOpenHour = input.int(9, "Custom Open Hour", minval = 0, maxval = 23, group = grpCore)
customOpenMinute = input.int(15, "Custom Open Minute", minval = 0, maxval = 59, group = grpCore)

rangeSource = input.string("High / Low", "Opening Range Source", options = ["High / Low", "Body"], group = grpCore)

grpVisual = "Visual Settings"
showRangeBox = input.bool(true, "Show Opening Range Box", group = grpVisual)
showMidline = input.bool(true, "Show ORB Midline", group = grpVisual)
showTargets = input.bool(true, "Show Target Extensions", group = grpVisual)
showBreakoutLabels = input.bool(true, "Show Breakout Labels", group = grpVisual)
showDashboard = input.bool(true, "Show Dashboard", group = grpVisual)

bullColor = input.color(#089981, "Bullish Color", group = grpVisual)
bearColor = input.color(#f23645, "Bearish Color", group = grpVisual)
rangeColor = input.color(#5b9cf6, "Range Color", group = grpVisual)
bgTransp = input.int(85, "Range Fill Transparency", minval = 0, maxval = 100, group = grpVisual)

grpTargets = "Targets"
target1Mult = input.float(1.0, "Target 1 × OR Range", minval = 0.1, step = 0.1, group = grpTargets)
target2Mult = input.float(2.0, "Target 2 × OR Range", minval = 0.1, step = 0.1, group = grpTargets)
target3Mult = input.float(3.0, "Target 3 × OR Range", minval = 0.1, step = 0.1, group = grpTargets)

grpFilter = "Signal Filters"
oneSignalPerSide = input.bool(true, "Only One Bull/Bear Signal Per Day", group = grpFilter)
confirmClose = input.bool(true, "Breakout Must Close Outside Range", group = grpFilter)
useVolumeFilter = input.bool(false, "Use Volume Filter", group = grpFilter)
volumeLength = input.int(20, "Volume SMA Length", minval = 1, group = grpFilter)
volumeMultiplier = input.float(1.2, "Volume Multiplier", minval = 0.1, step = 0.1, group = grpFilter)

//────────────────────────────────────
// TIMEZONE LOGIC
//────────────────────────────────────
string activeTimezone = useExchangeTimezone ? syminfo.timezone : customTimezone

//────────────────────────────────────
// AUTO MARKET DETECTION
//────────────────────────────────────
string exch = str.upper(syminfo.prefix)
string tickerType = str.upper(syminfo.type)

bool isCrypto = syminfo.type == "crypto"
bool isNSE = str.contains(exch, "NSE") or str.contains(exch, "BSE")
bool isUS = str.contains(exch, "NASDAQ") or str.contains(exch, "NYSE") or str.contains(exch, "AMEX") or str.contains(exch, "ARCA") or str.contains(exch, "CBOE")
bool isLondon = str.contains(exch, "LSE") or str.contains(exch, "LON")

int autoOpenHour = 0
int autoOpenMinute = 0

if modeMarket == "NSE / BSE"
    autoOpenHour := 9
    autoOpenMinute := 15
else if modeMarket == "US Stocks"
    autoOpenHour := 9
    autoOpenMinute := 30
else if modeMarket == "Crypto"
    autoOpenHour := 0
    autoOpenMinute := 0
else if modeMarket == "London"
    autoOpenHour := 8
    autoOpenMinute := 0
else if modeMarket == "Custom"
    autoOpenHour := customOpenHour
    autoOpenMinute := customOpenMinute
else
    if isNSE
        autoOpenHour := 9
        autoOpenMinute := 15
    else if isUS
        autoOpenHour := 9
        autoOpenMinute := 30
    else if isLondon
        autoOpenHour := 8
        autoOpenMinute := 0
    else if isCrypto
        autoOpenHour := 0
        autoOpenMinute := 0
    else
        autoOpenHour := customOpenHour
        autoOpenMinute := customOpenMinute

//────────────────────────────────────
// AUTO ORB LENGTH BASED ON TIMEFRAME
//────────────────────────────────────
int tfSeconds = timeframe.in_seconds(timeframe.period)
float tfMinutesFloat = tfSeconds / 60.0

int autoLength = 15

if tfSeconds <= 60
    autoLength := 5
else if tfSeconds <= 300
    autoLength := 15
else if tfSeconds <= 900
    autoLength := 30
else if tfSeconds <= 3600
    autoLength := 60
else if tfSeconds <= 14400
    autoLength := 120
else
    autoLength := 240

int orbMinutes = autoOrbLength ? autoLength : manualOrbMinutes

bool isIntraday = timeframe.isintraday

//────────────────────────────────────
// SESSION / OPENING RANGE LOGIC
//────────────────────────────────────
int currentHour = hour(time, activeTimezone)
int currentMinute = minute(time, activeTimezone)
int currentMinuteOfDay = currentHour * 60 + currentMinute

int openMinuteOfDay = autoOpenHour * 60 + autoOpenMinute
int orbEndMinuteOfDay = openMinuteOfDay + orbMinutes

bool inOpeningRange = isIntraday and currentMinuteOfDay >= openMinuteOfDay and currentMinuteOfDay < orbEndMinuteOfDay
bool afterOpeningRange = isIntraday and currentMinuteOfDay >= orbEndMinuteOfDay

bool isNewDay = ta.change(time("D", "", activeTimezone)) != 0
bool orbJustStarted = inOpeningRange and not inOpeningRange[1]
bool orbJustEnded = not inOpeningRange and inOpeningRange[1]

//────────────────────────────────────
// ORB STATE
//────────────────────────────────────
var float orHigh = na
var float orLow = na
var float orMid = na
var bool orbLocked = false

var bool bullSignalDone = false
var bool bearSignalDone = false

var int totalDays = 0
var int bullBreakouts = 0
var int bearBreakouts = 0

var box orbBox = na

// Reset at new trading day / new ORB
if isNewDay or orbJustStarted
    orHigh := na
    orLow := na
    orMid := na
    orbLocked := false
    bullSignalDone := false
    bearSignalDone := false

    if not na(orbBox)
        box.delete(orbBox)
        orbBox := na

// Build opening range
if inOpeningRange
    float srcHigh = rangeSource == "High / Low" ? high : math.max(open, close)
    float srcLow = rangeSource == "High / Low" ? low : math.min(open, close)

    orHigh := na(orHigh) ? srcHigh : math.max(orHigh, srcHigh)
    orLow := na(orLow) ? srcLow : math.min(orLow, srcLow)
    orMid := (orHigh + orLow) / 2.0

    if showRangeBox
        if na(orbBox)
            orbBox := box.new(
                 left = bar_index,
                 top = orHigh,
                 right = bar_index,
                 bottom = orLow,
                 bgcolor = color.new(rangeColor, bgTransp),
                 border_color = color.new(rangeColor, 25)
            )
        else
            box.set_right(orbBox, bar_index)
            box.set_top(orbBox, orHigh)
            box.set_bottom(orbBox, orLow)

if orbJustEnded
    orbLocked := true
    totalDays += 1

//────────────────────────────────────
// LEVELS
//────────────────────────────────────
float orRange = orHigh - orLow

float bullT1 = orHigh + orRange * target1Mult
float bullT2 = orHigh + orRange * target2Mult
float bullT3 = orHigh + orRange * target3Mult

float bearT1 = orLow - orRange * target1Mult
float bearT2 = orLow - orRange * target2Mult
float bearT3 = orLow - orRange * target3Mult

//────────────────────────────────────
// BREAKOUT CONDITIONS
//────────────────────────────────────
float volSma = ta.sma(volume, volumeLength)
bool volumeOkay = not useVolumeFilter or volume > volSma * volumeMultiplier

bool bullBreak = false
bool bearBreak = false

if confirmClose
    bullBreak := afterOpeningRange and orbLocked and not na(orHigh) and close > orHigh and close[1] <= orHigh and volumeOkay
    bearBreak := afterOpeningRange and orbLocked and not na(orLow) and close < orLow and close[1] >= orLow and volumeOkay
else
    bullBreak := afterOpeningRange and orbLocked and not na(orHigh) and high > orHigh and high[1] <= orHigh and volumeOkay
    bearBreak := afterOpeningRange and orbLocked and not na(orLow) and low < orLow and low[1] >= orLow and volumeOkay

bool allowBullSignal = oneSignalPerSide ? not bullSignalDone : true
bool allowBearSignal = oneSignalPerSide ? not bearSignalDone : true

bool finalBullBreak = bullBreak and allowBullSignal
bool finalBearBreak = bearBreak and allowBearSignal

if finalBullBreak
    bullBreakouts += 1
    bullSignalDone := true

if finalBearBreak
    bearBreakouts += 1
    bearSignalDone := true

//────────────────────────────────────
// PLOTS
//────────────────────────────────────
plotORHigh = plot(isIntraday ? orHigh : na, "ORB High", color.new(rangeColor, 0), 2, plot.style_linebr)
plotORLow = plot(isIntraday ? orLow : na, "ORB Low", color.new(rangeColor, 0), 2, plot.style_linebr)
plotORMid = plot(isIntraday and showMidline ? orMid : na, "ORB Midline", color.new(rangeColor, 50), 1, plot.style_linebr)

fill(plotORHigh, plotORLow, color.new(rangeColor, bgTransp), title = "ORB Fill")

plot(showTargets and isIntraday and orbLocked ? bullT1 : na, "Bull Target 1", color.new(bullColor, 35), 1, plot.style_linebr)
plot(showTargets and isIntraday and orbLocked ? bullT2 : na, "Bull Target 2", color.new(bullColor, 45), 1, plot.style_linebr)
plot(showTargets and isIntraday and orbLocked ? bullT3 : na, "Bull Target 3", color.new(bullColor, 55), 1, plot.style_linebr)

plot(showTargets and isIntraday and orbLocked ? bearT1 : na, "Bear Target 1", color.new(bearColor, 35), 1, plot.style_linebr)
plot(showTargets and isIntraday and orbLocked ? bearT2 : na, "Bear Target 2", color.new(bearColor, 45), 1, plot.style_linebr)
plot(showTargets and isIntraday and orbLocked ? bearT3 : na, "Bear Target 3", color.new(bearColor, 55), 1, plot.style_linebr)

bgcolor(inOpeningRange ? color.new(rangeColor, 92) : na, title = "Opening Range Background")

//────────────────────────────────────
// LABELS
//────────────────────────────────────
if showBreakoutLabels and finalBullBreak
    label.new(
         bar_index,
         high,
         "BULL ORB\nAbove: " + str.tostring(orHigh, format.mintick),
         style = label.style_label_down,
         color = bullColor,
         textcolor = color.white,
         size = size.small
    )

if showBreakoutLabels and finalBearBreak
    label.new(
         bar_index,
         low,
         "BEAR ORB\nBelow: " + str.tostring(orLow, format.mintick),
         style = label.style_label_up,
         color = bearColor,
         textcolor = color.white,
         size = size.small
    )

//────────────────────────────────────
// DASHBOARD
//────────────────────────────────────

dashboardPosition = input.string(
     "Top Right",
     "Dashboard Position",
     options = ["Top Right", "Bottom Right", "Bottom Left", "Top Left"],
     group = grpVisual
)

dashPos = switch dashboardPosition
    "Top Right"    => position.top_right
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    "Top Left"     => position.top_left

dashBg      = color.new(color.black, 10)
dashHeader  = color.new(rangeColor, 0)
dashBorder  = color.new(color.gray, 40)
dashText    = color.white
dashMuted   = color.new(color.white, 20)

var table dash = table.new(
     dashPos,
     2,
     14,
     bgcolor = dashBg,
     frame_color = dashBorder,
     frame_width = 1,
     border_color = dashBorder,
     border_width = 1
)

dashCell(int col, int row, string txt, color txtColor = color.white, color bgColor = na) =>
    table.cell(
         dash,
         col,
         row,
         txt,
         text_color = txtColor,
         bgcolor = na(bgColor) ? dashBg : bgColor,
         text_size = size.small
    )

if showDashboard and barstate.islast
    string openText = str.tostring(autoOpenHour, "00") + ":" + str.tostring(autoOpenMinute, "00")
    string orbText = str.tostring(orbMinutes) + " min"
    string marketText = modeMarket == "Auto" ? "Auto" : modeMarket
    string statusText = inOpeningRange ? "Building ORB" : orbLocked ? "ORB Locked" : "Waiting"

    float bullRate = totalDays > 0 ? bullBreakouts / totalDays * 100.0 : na
    float bearRate = totalDays > 0 ? bearBreakouts / totalDays * 100.0 : na

    string orbRangeText = na(orRange) ? "NA" : str.tostring(orRange, format.mintick)

    string bullT1Text = na(bullT1) ? "NA" : str.tostring(bullT1, format.mintick)
    string bullT2Text = na(bullT2) ? "NA" : str.tostring(bullT2, format.mintick)
    string bullT3Text = na(bullT3) ? "NA" : str.tostring(bullT3, format.mintick)

    string bearT1Text = na(bearT1) ? "NA" : str.tostring(bearT1, format.mintick)
    string bearT2Text = na(bearT2) ? "NA" : str.tostring(bearT2, format.mintick)
    string bearT3Text = na(bearT3) ? "NA" : str.tostring(bearT3, format.mintick)

    dashCell(0, 0, "STOC Adaptive ORB", color.white, dashHeader)
    dashCell(1, 0, statusText, color.white, dashHeader)

    dashCell(0, 1, "Market", dashMuted)
    dashCell(1, 1, marketText, dashText)

    dashCell(0, 2, "Timezone", dashMuted)
    dashCell(1, 2, activeTimezone, dashText)

    dashCell(0, 3, "Open Time", dashMuted)
    dashCell(1, 3, openText, dashText)

    dashCell(0, 4, "ORB Length", dashMuted)
    dashCell(1, 4, orbText, dashText)

    dashCell(0, 5, "ORB Range", dashMuted)
    dashCell(1, 5, orbRangeText, dashText)

    dashCell(0, 6, "Bull T1", bullColor)
    dashCell(1, 6, bullT1Text, bullColor)

    dashCell(0, 7, "Bull T2", bullColor)
    dashCell(1, 7, bullT2Text, bullColor)

    dashCell(0, 8, "Bull T3", bullColor)
    dashCell(1, 8, bullT3Text, bullColor)

    dashCell(0, 9, "Bear T1", bearColor)
    dashCell(1, 9, bearT1Text, bearColor)

    dashCell(0, 10, "Bear T2", bearColor)
    dashCell(1, 10, bearT2Text, bearColor)

    dashCell(0, 11, "Bear T3", bearColor)
    dashCell(1, 11, bearT3Text, bearColor)

    dashCell(0, 12, "Bull Break Rate", dashMuted)
    dashCell(1, 12, na(bullRate) ? "NA" : str.tostring(bullRate, "#.##") + "%", bullColor)

    dashCell(0, 13, "Bear Break Rate", dashMuted)
    dashCell(1, 13, na(bearRate) ? "NA" : str.tostring(bearRate, "#.##") + "%", bearColor)

//────────────────────────────────────
// WARNINGS
//────────────────────────────────────
if barstate.islast and not isIntraday
    label.new(
         bar_index,
         high,
         "STOC Adaptive ORB works best on intraday charts.\nSwitch to 1m, 5m, 15m, 30m, 1H, 2H, or 4H.",
         style = label.style_label_down,
         color = color.orange,
         textcolor = color.white,
         size = size.small
    )

//────────────────────────────────────
// ALERTS
//────────────────────────────────────
alertcondition(finalBullBreak, "Bullish ORB Breakout", "Price broke above the adaptive opening range.")
alertcondition(finalBearBreak, "Bearish ORB Breakout", "Price broke below the adaptive opening range.")
alertcondition(ta.cross(close, bullT1), "Bull Target 1 Hit", "Price reached Bull Target 1.")
alertcondition(ta.cross(close, bullT2), "Bull Target 2 Hit", "Price reached Bull Target 2.")
alertcondition(ta.cross(close, bullT3), "Bull Target 3 Hit", "Price reached Bull Target 3.")
alertcondition(ta.cross(close, bearT1), "Bear Target 1 Hit", "Price reached Bear Target 1.")
alertcondition(ta.cross(close, bearT2), "Bear Target 2 Hit", "Price reached Bear Target 2.")
alertcondition(ta.cross(close, bearT3), "Bear Target 3 Hit", "Price reached Bear Target 3.")
````
