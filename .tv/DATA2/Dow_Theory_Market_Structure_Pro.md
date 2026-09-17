<!-- tradingview-pine-id: PUB;2cb784d0baf740da91120e51e4dbcf00 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Dow Theory Market Structure Pro

Source: https://www.tradingview.com/script/1mry29TH-Dow-Theory-Market-Structure-Pro/

## Description

Dow Theory Market Structure Pro is a price-action indicator designed to help traders identify and interpret market trends using classic Dow Theory principles.

The indicator automatically detects confirmed swing highs and swing lows and classifies the evolving market structure as:

[*]HH: Higher High
[*]HL: Higher Low
[*]LH: Lower High
[*]LL: Lower Low

A sequence of Higher Highs and Higher Lows indicates a bullish structure, while Lower Highs and Lower Lows indicate a bearish structure. Mixed structures are classified as a range or transition phase.

Key Features

[*]Automatic HH, HL, LH and LL identification
[*]Swing-high and swing-low trend lines
[*]Dynamic support and resistance levels
[*]Bullish breakout and bearish breakdown signals
[*]Bull, bear and range market classification
[*]Trend-strength score from -2 to +2
[*]Daily and weekly market-structure comparison
[*]Multi-timeframe trend-alignment status
[*]Price position within the current support-resistance range
[*]Upside-to-downside distance calculation
[*]Customisable dashboard, colours and display settings
[*]Alert conditions for structural changes, breakouts and breakdowns
[*]Trend-Strength Framework
[*]

The indicator assigns one point to each bullish structural condition and subtracts one point for each bearish condition:

[*]+2: Strong Bull, with HH and HL
[*]+1: Bullish Bias
[*]0: Range or Transition
[*]-1: Bearish Bias
[*]-2: Strong Bear, with LH and LL
[*]Support and Resistance

The latest confirmed swing high is displayed as resistance, while the latest confirmed swing low is displayed as support. These levels automatically update when a new pivot is confirmed.

A breakout signal occurs when price closes above the current confirmed resistance. A breakdown signal occurs when price closes below the current confirmed support.

Multi-Timeframe View

The dashboard compares Daily and Weekly Dow Theory structures to indicate whether the two timeframes are bullishly aligned, bearishly aligned or mixed.

Important Note

Swing points are confirmed using a user-defined Pivot Length. Because confirmation requires additional bars to form after a potential turning point, swing labels and structure changes appear with an intentional delay. Increasing Pivot Length identifies fewer, more significant swings, while decreasing it produces faster but more sensitive signals.

This indicator is intended for market-structure analysis and trend confirmation. It does not predict future price movements or provide standalone buy or sell recommendations.

Disclaimer

This script is provided for educational and analytical purposes only and does not constitute financial advice. Market-structure signals, support and resistance levels, breakouts, breakdowns and multi-timeframe readings may produce false or delayed signals. Users should perform independent analysis and apply appropriate risk management before making investment or trading decisions.

---

## Source Code

````pine
//@version=6
indicator("Dow Theory Market Structure Pro", shorttitle="Dow Structure Pro", overlay=true, max_lines_count=100, max_labels_count=500)

// =====================================================================
// INPUTS
// =====================================================================

pivotLen = input.int(5, "Pivot Length", minval=1)

showSwingLabels = input.bool(true, "Show HH, HL, LH and LL")
showTrendLines = input.bool(true, "Show Swing Trend Lines")
showLevels = input.bool(true, "Show Support and Resistance")
showSignals = input.bool(true, "Show Breakout and Breakdown")
showBackground = input.bool(true, "Show Trend Background")
showDashboard = input.bool(true, "Show Dashboard")
showMTF = input.bool(true, "Show Daily and Weekly Structure")

resistanceColor = input.color(color.red, "Resistance Colour")
supportColor = input.color(color.lime, "Support Colour")
bullColor = input.color(color.green, "Bullish Colour")
bearColor = input.color(color.red, "Bearish Colour")
rangeColor = input.color(color.gray, "Range Colour")

// =====================================================================
// CONFIRMED PIVOTS
// =====================================================================

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

newHighPivot = not na(ph)
newLowPivot = not na(pl)

highPivotBar = bar_index - pivotLen
lowPivotBar = bar_index - pivotLen

// =====================================================================
// STORE SWING HIGHS AND LOWS
// =====================================================================

var float previousHigh = na
var float latestHigh = na
var int previousHighBar = na
var int latestHighBar = na

var float previousLow = na
var float latestLow = na
var int previousLowBar = na
var int latestLowBar = na

var string latestHighType = "Waiting"
var string latestLowType = "Waiting"

// =====================================================================
// LINES
// =====================================================================

var line highTrendLine = na
var line lowTrendLine = na
var line resistanceLine = na
var line supportLine = na

// =====================================================================
// PROCESS NEW SWING HIGH
// =====================================================================

if newHighPivot
    previousHigh := latestHigh
    previousHighBar := latestHighBar
    latestHigh := ph
    latestHighBar := highPivotBar
    latestHighType := "H"

    if not na(previousHigh)
        if latestHigh > previousHigh
            latestHighType := "HH"
        else
            latestHighType := "LH"

    if showSwingLabels
        if latestHighType == "HH"
            label.new(latestHighBar, latestHigh, "HH", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=bullColor, textcolor=color.white, size=size.small)
        else if latestHighType == "LH"
            label.new(latestHighBar, latestHigh, "LH", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=bearColor, textcolor=color.white, size=size.small)
        else
            label.new(latestHighBar, latestHigh, "H", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=rangeColor, textcolor=color.white, size=size.small)

    if showTrendLines and not na(previousHigh)
        line.delete(highTrendLine)
        highTrendLine := line.new(previousHighBar, previousHigh, latestHighBar, latestHigh, xloc=xloc.bar_index, extend=extend.right, color=latestHigh > previousHigh ? bullColor : bearColor, width=2)

    if showLevels
        line.delete(resistanceLine)
        resistanceLine := line.new(latestHighBar, latestHigh, bar_index, latestHigh, xloc=xloc.bar_index, extend=extend.right, color=resistanceColor, width=2, style=line.style_dashed)

// =====================================================================
// PROCESS NEW SWING LOW
// =====================================================================

if newLowPivot
    previousLow := latestLow
    previousLowBar := latestLowBar
    latestLow := pl
    latestLowBar := lowPivotBar
    latestLowType := "L"

    if not na(previousLow)
        if latestLow > previousLow
            latestLowType := "HL"
        else
            latestLowType := "LL"

    if showSwingLabels
        if latestLowType == "HL"
            label.new(latestLowBar, latestLow, "HL", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=bullColor, textcolor=color.white, size=size.small)
        else if latestLowType == "LL"
            label.new(latestLowBar, latestLow, "LL", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=bearColor, textcolor=color.white, size=size.small)
        else
            label.new(latestLowBar, latestLow, "L", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=rangeColor, textcolor=color.white, size=size.small)

    if showTrendLines and not na(previousLow)
        line.delete(lowTrendLine)
        lowTrendLine := line.new(previousLowBar, previousLow, latestLowBar, latestLow, xloc=xloc.bar_index, extend=extend.right, color=latestLow > previousLow ? bullColor : bearColor, width=2)

    if showLevels
        line.delete(supportLine)
        supportLine := line.new(latestLowBar, latestLow, bar_index, latestLow, xloc=xloc.bar_index, extend=extend.right, color=supportColor, width=2, style=line.style_dashed)

// =====================================================================
// CURRENT MARKET STRUCTURE
// =====================================================================

structureReady = not na(previousHigh) and not na(latestHigh) and not na(previousLow) and not na(latestLow)

higherHigh = structureReady and latestHigh > previousHigh
lowerHigh = structureReady and latestHigh < previousHigh
higherLow = structureReady and latestLow > previousLow
lowerLow = structureReady and latestLow < previousLow

bullTrend = higherHigh and higherLow
bearTrend = lowerHigh and lowerLow
transitionTrend = structureReady and not bullTrend and not bearTrend

// =====================================================================
// TREND-STRENGTH SCORE
// HH = +1, HL = +1, LH = -1, LL = -1
// =====================================================================

int trendScore = 0

if higherHigh
    trendScore += 1

if lowerHigh
    trendScore -= 1

if higherLow
    trendScore += 1

if lowerLow
    trendScore -= 1

var string strengthText = "Waiting"

if structureReady
    strengthText := "Range"

    if trendScore == 2
        strengthText := "Strong Bull"

    if trendScore == 1
        strengthText := "Bullish Bias"

    if trendScore == 0
        strengthText := "Range / Transition"

    if trendScore == -1
        strengthText := "Bearish Bias"

    if trendScore == -2
        strengthText := "Strong Bear"

// =====================================================================
// SUPPORT AND RESISTANCE
// =====================================================================

currentResistance = latestHigh
currentSupport = latestLow

// =====================================================================
// BREAKOUT AND BREAKDOWN
// Signals require the closing price to cross the current level.
// =====================================================================

bullishBreakout = not na(currentResistance) and ta.crossover(close, currentResistance)
bearishBreakdown = not na(currentSupport) and ta.crossunder(close, currentSupport)

if showSignals and bullishBreakout
    label.new(bar_index, low, "BREAKOUT", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=bullColor, textcolor=color.white, size=size.small)

if showSignals and bearishBreakdown
    label.new(bar_index, high, "BREAKDOWN", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, color=bearColor, textcolor=color.white, size=size.small)

// =====================================================================
// DECISION-SUPPORT SIGNAL
// =====================================================================

var string signalText = "Waiting for structure"

if structureReady
    signalText := "Range: wait for confirmation"

    if bullTrend
        signalText := "Bull trend: monitor support"

    if bearTrend
        signalText := "Bear trend: monitor resistance"

    if transitionTrend and latestHighType == "LH"
        signalText := "Caution: Lower High"

    if transitionTrend and latestLowType == "HL"
        signalText := "Watch resistance breakout"

    if bullishBreakout
        signalText := "Bullish breakout confirmed"

    if bearishBreakdown
        signalText := "Bearish breakdown confirmed"

// =====================================================================
// POSITION WITHIN CURRENT RANGE
// =====================================================================

float rangePosition = na
float upsideDistance = na
float downsideDistance = na
float rewardRisk = na

if not na(currentResistance) and not na(currentSupport) and currentResistance > currentSupport
    rangePosition := 100 * (close - currentSupport) / (currentResistance - currentSupport)
    upsideDistance := currentResistance - close
    downsideDistance := close - currentSupport

    if downsideDistance > 0 and upsideDistance > 0
        rewardRisk := upsideDistance / downsideDistance

// =====================================================================
// MULTI-TIMEFRAME DOW STRUCTURE FUNCTION
// =====================================================================

dowState(length) =>
    mtfHigh = ta.pivothigh(high, length, length)
    mtfLow = ta.pivotlow(low, length, length)

    mtfLatestHigh = ta.valuewhen(not na(mtfHigh), mtfHigh, 0)
    mtfPreviousHigh = ta.valuewhen(not na(mtfHigh), mtfHigh, 1)

    mtfLatestLow = ta.valuewhen(not na(mtfLow), mtfLow, 0)
    mtfPreviousLow = ta.valuewhen(not na(mtfLow), mtfLow, 1)

    mtfBull = not na(mtfPreviousHigh) and not na(mtfPreviousLow) and mtfLatestHigh > mtfPreviousHigh and mtfLatestLow > mtfPreviousLow
    mtfBear = not na(mtfPreviousHigh) and not na(mtfPreviousLow) and mtfLatestHigh < mtfPreviousHigh and mtfLatestLow < mtfPreviousLow

    mtfBull ? 1 : mtfBear ? -1 : 0

dailyState = request.security(syminfo.tickerid, "D", dowState(pivotLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
weeklyState = request.security(syminfo.tickerid, "W", dowState(pivotLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

var string dailyText = "Range"
var string weeklyText = "Range"

if dailyState == 1
    dailyText := "Bull"

if dailyState == -1
    dailyText := "Bear"

if dailyState == 0
    dailyText := "Range"

if weeklyState == 1
    weeklyText := "Bull"

if weeklyState == -1
    weeklyText := "Bear"

if weeklyState == 0
    weeklyText := "Range"

// =====================================================================
// MULTI-TIMEFRAME ALIGNMENT
// =====================================================================

var string alignmentText = "Mixed"

if dailyState == 1 and weeklyState == 1
    alignmentText := "Bull aligned"

if dailyState == -1 and weeklyState == -1
    alignmentText := "Bear aligned"

if dailyState != weeklyState
    alignmentText := "Mixed timeframes"

// =====================================================================
// BACKGROUND
// =====================================================================

color backgroundColour = na

if bullTrend
    backgroundColour := color.new(bullColor, 92)

if bearTrend
    backgroundColour := color.new(bearColor, 92)

if transitionTrend
    backgroundColour := color.new(rangeColor, 95)

bgcolor(showBackground ? backgroundColour : na)

// =====================================================================
// DASHBOARD TEXT
// =====================================================================

var string chartTrendText = "Waiting"
var color chartTrendColour = rangeColor

if bullTrend
    chartTrendText := "BULL"
    chartTrendColour := bullColor
else if bearTrend
    chartTrendText := "BEAR"
    chartTrendColour := bearColor
else if transitionTrend
    chartTrendText := "RANGE / TRANSITION"
    chartTrendColour := rangeColor

var string resistanceText = "N/A"
var string supportText = "N/A"
var string rangePositionText = "N/A"
var string rewardRiskText = "N/A"

if not na(currentResistance)
    resistanceText := str.tostring(currentResistance, format.mintick)

if not na(currentSupport)
    supportText := str.tostring(currentSupport, format.mintick)

if not na(rangePosition)
    rangePositionText := str.tostring(rangePosition, "#.0") + "%"

if not na(rewardRisk)
    rewardRiskText := str.tostring(rewardRisk, "#.00")

// =====================================================================
// DASHBOARD
// =====================================================================

var table dashboard = table.new(position.top_right, 2, 11, border_width=1)

if barstate.islast and showDashboard
    table.cell(dashboard, 0, 0, "DOW THEORY", text_color=color.white, bgcolor=color.black)
    table.cell(dashboard, 1, 0, syminfo.ticker, text_color=color.white, bgcolor=color.black)

    table.cell(dashboard, 0, 1, "Chart trend", text_color=color.white, bgcolor=color.new(color.black, 20))
    table.cell(dashboard, 1, 1, chartTrendText, text_color=color.white, bgcolor=chartTrendColour)

    table.cell(dashboard, 0, 2, "High structure", text_color=color.white, bgcolor=color.new(color.black, 20))
    table.cell(dashboard, 1, 2, latestHighType, text_color=color.white, bgcolor=latestHighType == "HH" ? bullColor : latestHighType == "LH" ? bearColor : rangeColor)

    table.cell(dashboard, 0, 3, "Low structure", text_color=color.white, bgcolor=color.new(color.black, 20))
    table.cell(dashboard, 1, 3, latestLowType, text_color=color.white, bgcolor=latestLowType == "HL" ? bullColor : latestLowType == "LL" ? bearColor : rangeColor)

    table.cell(dashboard, 0, 4, "Resistance", text_color=color.white, bgcolor=color.new(color.black, 20))
    table.cell(dashboard, 1, 4, resistanceText, text_color=color.white, bgcolor=resistanceColor)

    table.cell(dashboard, 0, 5, "Support", text_color=color.white, bgcolor=color.new(color.black, 20))
    table.cell(dashboard, 1, 5, supportText, text_color=color.white, bgcolor=supportColor)

    table.cell(dashboard, 0, 6, "Strength", text_color=color.white, bgcolor=color.new(color.black, 20))
    table.cell(dashboard, 1, 6, strengthText + " (" + str.tostring(trendScore) + ")", text_color=color.white, bgcolor=chartTrendColour)

    table.cell(dashboard, 0, 7, "Range position", text_color=color.white, bgcolor=color.new(color.black, 20))
    table.cell(dashboard, 1, 7, rangePositionText, text_color=color.white, bgcolor=rangeColor)

    table.cell(dashboard, 0, 8, "Upside / downside", text_color=color.white, bgcolor=color.new(color.black, 20))
    table.cell(dashboard, 1, 8, rewardRiskText, text_color=color.white, bgcolor=rangeColor)

    table.cell(dashboard, 0, 9, "Daily / Weekly", text_color=color.white, bgcolor=color.new(color.black, 20))
    table.cell(dashboard, 1, 9, showMTF ? dailyText + " / " + weeklyText : "Hidden", text_color=color.white, bgcolor=rangeColor)

    table.cell(dashboard, 0, 10, "Signal", text_color=color.white, bgcolor=color.new(color.black, 20))
    table.cell(dashboard, 1, 10, signalText, text_color=color.white, bgcolor=chartTrendColour)

// =====================================================================
// ALERT CONDITIONS
// =====================================================================

newHigherHigh = newHighPivot and latestHighType == "HH"
newLowerHigh = newHighPivot and latestHighType == "LH"
newHigherLow = newLowPivot and latestLowType == "HL"
newLowerLow = newLowPivot and latestLowType == "LL"

bullTrendStarted = bullTrend and not bullTrend[1]
bearTrendStarted = bearTrend and not bearTrend[1]

alertcondition(newHigherHigh, title="New Higher High", message="Confirmed Higher High on {{ticker}} at {{close}}.")
alertcondition(newLowerHigh, title="New Lower High", message="Confirmed Lower High on {{ticker}} at {{close}}.")
alertcondition(newHigherLow, title="New Higher Low", message="Confirmed Higher Low on {{ticker}} at {{close}}.")
alertcondition(newLowerLow, title="New Lower Low", message="Confirmed Lower Low on {{ticker}} at {{close}}.")

alertcondition(bullishBreakout, title="Resistance Breakout", message="Price closed above confirmed resistance on {{ticker}} at {{close}}.")
alertcondition(bearishBreakdown, title="Support Breakdown", message="Price closed below confirmed support on {{ticker}} at {{close}}.")

alertcondition(bullTrendStarted, title="Dow Bull Trend Confirmed", message="Dow Theory bull trend confirmed on {{ticker}}: Higher High and Higher Low.")
alertcondition(bearTrendStarted, title="Dow Bear Trend Confirmed", message="Dow Theory bear trend confirmed on {{ticker}}: Lower High and Lower Low.")

// Invisible anchor to keep the indicator attached to the main price chart
plot(close, title="Price Anchor", color=color.new(color.white, 100), display=display.none)
````
